"""
:author: Anna Bien
:maintainer: Anna Bien
:owner_email: anna.bien@nokia.com
:team: I_5G_SW_MMW_PLKRK_04
:email: I_5G_SW_MMW_PLKRK_04@nokia.com
:description: Logs collector for testcases executed on 2xgNB TLs
"""

import os
import traceback
import paramiko
import datetime
import shutil
import signal
import functools
import subprocess as sp

from gzip import open as gzip_open
from shutil import copyfileobj
from ute_syslog import ute_syslog
from ute_syslog.exception import SyslogException
from ute_common_store.exception import AliasError
from ute_common_admin.exception import (
    AdminApiProcedureFailureException, AdminApiProcedureTimeoutException
)
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.transport.ssh import ssh
from taf.converters.eventdecoder import eventdecoder
from taf.internal.sw.dcap.rd.client.dcap_lite.v3.exceptions import ApiException
from ta5g_iphy import ta5g_iphy
from ta5g_tshark import ta5g_tshark
from ta5g_pm_counters import ta5g_pm_counters

from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import (
    logger_console_info, logger_info, logger_warning
)
from testsuite.Krakow.RRM.Airphone.resources.Python.common_gnb import (
    handle_admin, collect_scf_file, run_on_gnb, wait_till_admin_is_online
)
from testsuite.Krakow.RRM.Airphone.resources.Python.sherpa_logs import (
    configure_sherpa_application, activate_sherpa_traces, deactivate_sherpa_traces, convert_sherpa_to_csv
)
from testsuite.Krakow.RRM.Airphone.resources.Python.common_wts import collect_sos_report_log
from testsuite.Krakow.RRM.Airphone.resources.Python.sw_config_modifier import SwConfigModifier
from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import download_files_from
from testsuite.Krakow.RRM.Airphone.resources.Python.bip_management import (
    start_bip_sniffing, stop_bip_sniffing
)
from testsuite.Krakow.RRM.Airphone.resources.Python.dcap import Dcap
from testsuite.Krakow.RRM.Airphone.resources.Python.dcap_utilities import find_pcaps_in_dcap_result_dir
from testsuite.Krakow.RRM.Airphone.resources.Python.KPI_calculation import KpiCalculation


def timeout(seconds, error_message='Function call timed out'):
    """
    Use as decorator to timeout a function.

    :param seconds: (int) Number of seconds before TimeoutError is raised.
    :param error_message: (string) TimeoutError message
    """

    def decorated(func):

        def _handle_timeout(signum, frame):
            raise TimeoutError(error_message)

        def wrapper(*args, **kwargs):
            signal.signal(signal.SIGALRM, _handle_timeout)
            signal.alarm(seconds)
            try:
                result = func(*args, **kwargs)
            finally:
                signal.alarm(0)
            return result

        return functools.wraps(func)(wrapper)

    return decorated


class LogsCollector:
    """
    Functionality to collect logs from gNB#1, gNB#2 and Airphone
    Logs collected in real time: syslog, biplog, sherpa, PM counters
    Logs collected after test: swconfig.txt, iphy.xml, Snapshot, SCF, Sosreport.
    """

    def __init__(self, gnb2_ip_address=''):
        tl_cfg = get_builtin_value(param_name="tl")
        self.gnb1_ip = tl_cfg.gnbs[0].cu.backhaul_site_oam_ip
        self.gnb2_ip = gnb2_ip_address if gnb2_ip_address != '' \
            else tl_cfg.gnbs[1].cu.backhaul_site_oam_ip
        self.ap_ip = tl_cfg.ues[0].l1.common_units[0].lmp_connection.addr
        self.username = tl_cfg.gnbs[0].cu.oam_ssh_connection_details.username
        self.password = tl_cfg.gnbs[0].cu.oam_ssh_connection_details.password
        self.vm2_address = None if self.gnb2_ip is None \
            else tl_cfg.test_pcs[1].default_ssh_connection_details.addr
        self.vm_username = tl_cfg.test_pcs[0].default_ssh_connection_details.username
        self.vm_password = tl_cfg.test_pcs[0].default_ssh_connection_details.password
        self.webem_username = tl_cfg.gnbs[0].cu.oam_http_connection_details.username
        self.webem_password = tl_cfg.gnbs[0].cu.oam_http_connection_details.password
        self.dcap_instance = Dcap()
        self.syslog_instance = ute_syslog()
        self.scf_gnb1_filename = 'scf_gnb1.xml'
        self.scf_gnb2_filename = 'scf_gnb2.xml'

    def collect_logs_after_test(self, sos_report=False):
        """
        Collect basic log set for all units in TL:
                - swconfig.txt
                - iphy.xml
                - SCF
                - Snapshot
                Only on demand:
                - Sosreport
        """

        logger_info('Logs collection has started')
        log_dir = self._get_log_dir()
        self._get_swconfigs(log_dir)
        self._get_iphy(log_dir)
        self.collect_scfs(log_dir)
        self._collect_snapshots(log_dir)
        if sos_report:
            collect_sos_report_log(prefix='full_ap', log_output_dir=log_dir)
            logger_info('SosReport file download - success')
        logger_console_info('Logs collection has finished successfully')

    def _get_swconfigs(self, log_dir):
        """
        Download swconfig files.

        :param log_dir: (str)
        """

        download_files_from(
            ip_addr=self.gnb1_ip, username=self.username, password=self.password,
            files='/rom/swconfig.txt', local_path=os.path.join(log_dir, 'swconfig_gnb1.txt')
        )
        download_files_from(
            ip_addr=self.gnb2_ip, username=self.username, password=self.password,
            files='/rom/swconfig.txt', local_path=os.path.join(log_dir, 'swconfig_gnb2.txt')
        )
        download_files_from(
            ip_addr=self.ap_ip, username=self.username, password=self.password,
            files='/rom/swconfig.txt', local_path=os.path.join(log_dir, 'swconfig_ap.txt')
        )
        self._validate_if_log_files_exist(['swconfig_gnb1.txt', 'swconfig_gnb2.txt', 'swconfig_ap.txt'])
        logger_info('Swconfig files download - success')

    def _get_iphy(self, log_dir):
        """
        Download iphy file.

        :param log_dir: (str)
        """

        download_files_from(
            ip_addr=self.ap_ip, username=self.username, password=self.password,
            files='/rom/simmode/iphy.xml', local_path=os.path.join(log_dir, 'iphy.xml')
        )
        self._validate_if_log_files_exist('iphy.xml')
        logger_info('Iphy file download - success')

    def _collect_snapshots(self, log_dir):
        """
        Collect snapshots for both gNBs and Airphone.

        :param log_dir: (str)
        """

        @handle_admin
        def snapshot_collector(**kwargs):
            snapshot_path = os.path.join(log_dir, kwargs['snapshot_filename'])
            wait_till_admin_is_online()
            kwargs['connection'].get_snapshot(target_file_name=snapshot_path)

        snapshot_collector(bts_host_ip=self.gnb1_ip, snapshot_filename='snapshot_gnb1.zip')
        snapshot_collector(bts_host_ip=self.gnb2_ip, snapshot_filename='snapshot_gnb2.zip')
        try:
            ta5g_iphy().get_iphy_snapshot(output_filepath=os.path.join(log_dir, 'snapshot_ap.zip'), all_nodes=True)
            self._validate_if_log_files_exist(['snapshot_ap.zip'])
        except (AliasError, AssertionError):
            logger_warning('Could not collect AP snapshot')
        self._validate_if_log_files_exist(['snapshot_gnb1.zip', 'snapshot_gnb2.zip'])
        logger_info('Snapshot files download - success')

    def collect_scfs(self, log_dir=None, scf_gnb1_filename=None, scf_gnb2_filename=None):
        """
        Collect SCF files for both gNBs.

        :param log_dir: (str) Default value: output from self._get_log_dir()
        :param scf_gnb1_filename: (str) Default value: self.scf_gnb1_filename
        :param scf_gnb2_filename: (str) Default value: self.scf_gnb2_filename
        """

        log_dir = log_dir if log_dir is not None else self._get_log_dir()
        scf_gnb1_filename = scf_gnb1_filename if scf_gnb1_filename is not None else self.scf_gnb1_filename
        scf_gnb2_filename = scf_gnb2_filename if scf_gnb2_filename is not None else self.scf_gnb2_filename

        collect_scf_file(bts_host_ip=self.gnb1_ip, final_path=os.path.join(log_dir, scf_gnb1_filename))
        collect_scf_file(bts_host_ip=self.gnb2_ip, final_path=os.path.join(log_dir, scf_gnb2_filename))
        self._validate_if_log_files_exist(filenames=[scf_gnb1_filename, scf_gnb2_filename], log_dir=log_dir)
        logger_info('SCF files download - success')

    def _validate_if_log_files_exist(self, filenames, log_dir=None):
        """
        Check if path to log exist on local VM.

        :param filenames: (list or str)
        :param log_dir: (str)
        """

        log_dir = log_dir if log_dir is not None else self._get_log_dir()
        filenames = filenames if isinstance(filenames, list) else [filenames]
        for filename in filenames:
            assert os.path.exists(os.path.join(log_dir, filename)), \
                f'File: {os.path.join(log_dir, filename)} does not exist!'
            logger_info(f'File: {os.path.join(log_dir, filename)} exists')

    def start_collecting_syslog(self, log_dir=None, virt_env='/home/ute/test_repo'):
        """
        Collect syslogs for both gNBs.
        Syslog files are stored on gNB's corresponding VMs in location specified by 'log_dir'.

        :param log_dir: (str)
        :param virt_env: (str) Path to virtual python environment directory
        """

        def start_syslog(unit, host_ip):
            """
            Start syslog for single unit.

            :param unit: (str) 'gnb1' or 'gnb2'
            :param host_ip: (str) VM IP address
            """

            logger_info(f'Starting syslog_{unit}')
            try:
                self.syslog_instance.start_syslog(
                    log_dir=log_dir,
                    log_name=f'syslog_{unit}.log',
                    host_ip=host_ip,
                    virtualenv_dir=virt_env,
                    alias=f'syslog_{unit}'
                )
            except SyslogException as exc:
                logger_info(traceback.format_exc())
                logger_warning(f'Collecting syslog_{unit} has failed to start: {exc}')

        log_dir = log_dir if log_dir else self._get_log_dir()
        try:
            assert os.path.exists(virt_env), f'Virt_env directory: {virt_env} does not exist!'
        except AssertionError as exception:
            logger_warning(exception)
        start_syslog(unit='gnb1', host_ip='127.0.0.1')
        start_syslog(unit='gnb2', host_ip=self.vm2_address)

    def stop_collecting_syslog_and_download_files(self, log_dir=None):
        """
        Stop collecting syslog for both gNBs and copy files.

        :param log_dir: (str) path (on VM1) where syslog from gNB2 will be copied to
        """

        log_dir = log_dir if log_dir is not None else self._get_log_dir()
        try:
            self.syslog_instance.stop_syslog(alias='syslog_gnb1')
        except SyslogException as exc:
            logger_info(traceback.format_exc())
            logger_warning(f'Collecting syslog_gnb1.log has failed: {exc}')
        try:
            self.syslog_instance.stop_syslog(alias='syslog_gnb2')
        except SyslogException as exc:
            logger_info(traceback.format_exc())
            logger_warning(f'Collecting syslog_gnb2.log has failed: {exc}')
        try:
            download_files_from(
                ip_addr=self.vm2_address, username=self.vm_username, password=self.vm_password,
                files=os.path.join(log_dir, 'syslog_gnb2.log'), local_path=os.path.join(log_dir, 'syslog_gnb2.log')
            )
        except IOError:
            logger_warning('Could not download syslog_gnb2.log file.')
        self._validate_if_log_files_exist(filenames=['syslog_gnb1.log', 'syslog_gnb2.log'])

    def start_collecting_biplog(self, alias=None):
        """
        Start collecting Biplogs for both gNBs.
            This function must be placed within test case body along with 'stop_collecting_biplog'.
            Calling functions from separate e.g. test setup and teardown will result in AttributeError failure.

        :param alias: (str) Optional: Additional alias suffix.
        """

        gnb1_alias = f"gnb1{'_' + alias if alias is not None else ''}"
        gnb2_alias = f"gnb2{'_' + alias if alias is not None else ''}"
        start_bip_sniffing(host_ip=self.gnb1_ip, pcap_file_name=f'bip_{gnb1_alias}.pcap')
        start_bip_sniffing(host_ip=self.gnb2_ip, pcap_file_name=f'bip_{gnb2_alias}.pcap')

    def stop_collecting_biplog(self, alias=None):
        """
        Stop collecting biplog on both gNBs. Download .pcap files.

        :param alias: (str) Optional: Additional alias suffix.
        """

        gnb1_alias = f"gnb1{'_' + alias if alias is not None else ''}"
        gnb2_alias = f"gnb2{'_' + alias if alias is not None else ''}"
        stop_bip_sniffing(
            host_ip=self.gnb1_ip, pcap_file_name=f'bip_{gnb1_alias}.pcap', output_pcap_path=self._get_log_dir()
        )
        stop_bip_sniffing(
            host_ip=self.gnb2_ip, pcap_file_name=f'bip_{gnb2_alias}.pcap', output_pcap_path=self._get_log_dir()
        )

    @staticmethod
    @timeout(600)
    @handle_admin
    def get_pm_counter_value(counter_id, dist_name, timestamp_interval=None, pm_interval=300, **kwargs):
        """
        Get counter values using Admin library and parse output. Specify the timestamp of the interval's start.
        Get PM counter value from specific interval based on time difference.
        If timestamp is not defined counter value from the last PM interval is picked.

        :param counter_id: (str) Counter ID
        :param dist_name: (str) e.g. 'BTS/CELLS/NRCELL-1/NCAC'
        :param timestamp_interval: (datetime.datetime) Timestamp collected within PM Interval
        :param pm_interval: (int) Duration of PM interval in seconds
        :return counter_value: (int) Counter value
        """

        counter_output = kwargs["connection"].get_pm_counters(couter_ids=counter_id, timeout=120)
        selected_key = ''
        for component in dist_name.split('/'):
            counter_output = counter_output[component]
        counter_keys = [int(key) for key in counter_output[counter_id].keys()]
        if not timestamp_interval:
            selected_key = max(counter_keys)
        else:
            counter_keys.sort()
            for counter_key in counter_keys:
                timestamp_interval_start = datetime.datetime.fromtimestamp(counter_key)
                delta = timestamp_interval - timestamp_interval_start
                try:
                    assert 0 < delta.total_seconds() < pm_interval
                    selected_key = counter_key
                    logger.debug(f'Selected epoch: {selected_key}')
                    break
                except AssertionError:
                    continue
        counter_value = int(counter_output[counter_id][str(selected_key)])
        logger_info(f'{dist_name}/{counter_id} has value {counter_value}')
        return counter_value

    def _download_gnb2_counters_report(self, report_filename, counters_type):
        """
        Download RD or PM counter report directly from gNB2 based on filename.

        :param report_filename: (str) Name of the file that will be downloaded
        :param counters_type: (str) 'rd' or 'pm'
        """

        report_filepath = os.path.join(self._get_log_dir(), f'{counters_type}_counters_gnb2', report_filename)
        try:
            os.makedirs(os.path.join(self._get_log_dir(), f'{counters_type}_counters_gnb2'))
        except FileExistsError:
            pass
        download_files_from(
            ip_addr=self.gnb2_ip, username=self.username, password=self.password,
            files=f'/tmp/{report_filename}.gz', local_path=f'{report_filepath}.gz'
        )
        with gzip_open(f'{report_filepath}.gz', 'rb') as gzip_file:
            with open(report_filepath, 'wb') as xml_file:
                copyfileobj(gzip_file, xml_file)
        return report_filepath

    def download_counters_reports(self, counters_type='pm', wait_for_next_interval=True):
        """
        Download RD or PM reports from both gNBs, e.g. RD.BTS-1.20220929.075500.ANY.xml.gz
        Report from gNB1 is downloaded with use of ta5g_pm_counters library.
        Corresponding report is downloaded from gNB2 (files have the same name).

        :param counters_type: (str) 'rd' or 'pm'
        :param wait_for_next_interval: (bool)
        """

        pm_counters_instance = ta5g_pm_counters()

        if counters_type.lower() == 'rd':
            report_filepath_gnb1 = pm_counters_instance.get_next_unpacked_raw_rd_counters_file(
                output_dirpath=os.path.join(self._get_log_dir(), f'{counters_type}_counters_gnb1'))
        elif counters_type.lower() == 'pm':
            if wait_for_next_interval:
                pm_counters_instance.wait_for_next_raw_pm_interval()
            report_filepath_gnb1 = pm_counters_instance.get_latest_unpacked_raw_pm_counters_file(
                output_dirpath=os.path.join(self._get_log_dir(), f'{counters_type}_counters_gnb1'))
        else:
            raise ValueError(f'Not supported value for parameter counters_type: {counters_type}')

        report_filename = os.path.basename(report_filepath_gnb1)
        report_filepath_gnb2 = self._download_gnb2_counters_report(report_filename, counters_type)
        self._validate_if_log_files_exist(
            [f'{counters_type}_counters_gnb1/{report_filename}', f'{counters_type}_counters_gnb2/{report_filename}']
        )
        return report_filepath_gnb1, report_filepath_gnb2

    @staticmethod
    def _configure_sherpa_traces(gnb_ip, components):
        """
        Configure Sherpa traces.

        :param gnb_ip: (str) gNB IP address
        :param components: (list) Sherpa types to be activated
        """

        for component in components:
            try:
                activate_sherpa_traces(component, bts_host_ip=gnb_ip, source_ip=gnb_ip)
            except (AdminApiProcedureTimeoutException, AdminApiProcedureFailureException):
                deactivate_sherpa_traces(component, bts_host_ip=gnb_ip)
                activate_sherpa_traces(component, bts_host_ip=gnb_ip, source_ip=gnb_ip)
            logger_info(f'Activate sherpa traces: dst IP 10.0.1.1, src IP {gnb_ip}')

    def start_collecting_sherpa_traces(self, components=None, alias='sherpa', eth_int='eth3'):
        """
        Start collecting sherpa traces for both gNBs in single log file.

        :param components: (list) e.g. ['L2HiPdcp', 'L2Ps']
        :param alias: (str) Tshark alias, also filename of collected log
        :param eth_int: (str) Interface name, default: eth3
        """

        configure_sherpa_application()
        logger_console_info('Starting sherpa traces')
        components = components if components is not None else ['L2Ps']
        self._configure_sherpa_traces(components=components, gnb_ip=self.gnb1_ip)
        self._configure_sherpa_traces(components=components, gnb_ip=self.gnb2_ip)
        ute_tshark = BuiltIn().get_library_instance('ute_tshark')
        ute_tshark.setup_tshark(interface=eth_int, log_dir=self._get_log_dir(),
                                log_name=f'{alias}.pcap', alias=alias)
        ute_tshark.start_capturing(alias=alias)

    def stop_collecting_sherpa_traces(self, components=None, alias='sherpa', convert_to_csv=False):
        """
        Stop sherpa traces and teardown tshark.

        :param components: (list) e.g. ['L2HiPdcp', 'L2Ps']
        :param alias: (str) Tshark alias, also filename of collected log
        :param convert_to_csv: (bool) If function should convert .pcap to .csv for further validation
        """

        components = components if components is not None else ['L2Ps']
        ute_tshark = BuiltIn().get_library_instance('ute_tshark')
        try:
            ute_tshark.stop_capturing(alias=alias)
            ute_tshark.teardown_tshark(alias=alias)
            logger_console_info('Collecting sherpa traces stopped')
        except AliasError:
            logger_warning(f'AliasError: There is no Sherpa Traces running with alias {alias}')
        for component in components:
            try:
                deactivate_sherpa_traces(component, bts_host_ip=self.gnb1_ip)
            except AdminApiProcedureFailureException:
                logger_console_info(f'gNB1 Sherpa Traces already deactivated')
            try:
                deactivate_sherpa_traces(component, bts_host_ip=self.gnb2_ip)
            except AdminApiProcedureFailureException:
                logger_console_info(f'gNB2 Sherpa Traces already deactivated')
            logger_info(f'Sherpa Traces have been deactivated successfully')
        self._validate_if_log_files_exist(f'{alias}.pcap')
        if convert_to_csv:
            self.convert_sherpa_pcap_to_csv(alias)

    def convert_sherpa_pcap_to_csv(self, alias='sherpa'):
        """
        To convert Sherpa Trace DCAP must be disabled.
        """

        Dcap().stop_dcap_basic_controller()
        convert_sherpa_to_csv(os.path.join(self._get_log_dir(), f'{alias}.pcap'), self._get_log_dir())
        Dcap().start_dcap_basic_controller()

    def start_collecting_tcpdump(self):
        """
        Collect tcpdump on all gNB1, gNB2 and AP interfaces.
        """

        tshark_instance = ta5g_tshark()
        tshark_instance.start_tcpdump_on_remote_interface(
            log_filename_prefix='tcpdump_gnb1',
            log_dirpath=self._get_log_dir(),
            alias='tcpdump_gnb1',
            eth_interface='any sctp',
            ssh_ip=self.gnb1_ip
        )
        tshark_instance.start_tcpdump_on_remote_interface(
            log_filename_prefix='tcpdump_gnb2',
            log_dirpath=self._get_log_dir(),
            alias='tcpdump_gnb2',
            eth_interface='any sctp',
            ssh_ip=self.gnb2_ip
        )
        tshark_instance.start_tcpdump_on_remote_interface(
            log_filename_prefix='tcpdump_ap',
            log_dirpath=self._get_log_dir(),
            alias='tcpdump_ap',
            eth_interface='any sctp',
            ssh_ip=self.ap_ip
        )

    @staticmethod
    def stop_collecting_tcpdump():
        """
        Kill all tcpdump processes.
        """

        tshark_instance = ta5g_tshark()
        tshark_instance.stop_tcpdump_on_remote_interface()
        ute_tshark = BuiltIn().get_library_instance('ute_tshark')
        ute_tshark.teardown_all_aliases_for_tshark()
        sp.call(['sudo', 'pkill', '-f', 'pcap'])

    def start_collecting_syscom(self, file_name_prefix='xp_syscom'):
        """
        Start collecting SysCom on gnb1 and gnb2.

        :param file_name_prefix: (str)
        """

        self._send_command(cmd=f'nohup syscomdump -w /rom/logs/{file_name_prefix}_gnb1.pcap >/dev/null 2>&1 &',
                           hostname=self.gnb1_ip, get_pty=False)
        self._send_command(cmd=f'nohup syscomdump -w /rom/logs/{file_name_prefix}_gnb2.pcap >/dev/null 2>&1 &',
                           hostname=self.gnb2_ip, get_pty=False)

    def stop_collecting_syscom(self, file_name_prefix='xp_syscom'):
        """
        Stop collecting SysCom and download files to VM.

        :param file_name_prefix: (str)
        """

        run_on_gnb(cmd='pkill -f syscomdump')
        run_on_gnb(cmd='pkill -f syscomdump', hostname=self.gnb2_ip)
        self.download_file_from_unit(f'{file_name_prefix}_gnb1.pcap', hostname=self.gnb1_ip)
        self.download_file_from_unit(f'{file_name_prefix}_gnb2.pcap', hostname=self.gnb2_ip)
        self._validate_if_log_files_exist([f'{file_name_prefix}_gnb1.pcap', f'{file_name_prefix}_gnb2.pcap'])

    def _send_command(self, cmd, hostname, get_pty=True):
        """
        Open ssh connection and execute command on remote.

        :param cmd: (str) Command
        :param hostname: (str) Ip address
        :param get_pty: (bool) Execute command in pseudo-terminal
        """

        ssh_instance = ssh()
        ssh_instance.connect_to(hostname=hostname, username=self.username, password=self.password)
        logger_info(f'Sending command to {hostname}: {cmd}')
        ssh_instance.send_command(command=cmd, get_pty=get_pty)
        logger_console_info(ssh_instance.read_output())

    def download_file_from_unit(self, filename, hostname, file_remote_dir='/rom/logs'):
        """
        Paramiko library is used for connection establishment.

        :param filename: (str)
        :param hostname: (str)
        :param file_remote_dir: (str)
        """

        try:
            paramiko_trs = paramiko.Transport((hostname, 22))
            paramiko_trs.connect(username=self.username, password=self.password)
            sftp = paramiko.SFTPClient.from_transport(paramiko_trs)
            file_status = sftp.stat(os.path.join(file_remote_dir, filename))
            if file_status.st_size > 0:
                sftp.get(remotepath=os.path.join(file_remote_dir, filename),
                         localpath=os.path.join(self._get_log_dir(), filename))
            else:
                logger_info(f'{os.path.join(file_remote_dir, filename)} is empty or does not exist! Skipping download')
                return False
        except IOError:
            logger_info(f'{os.path.join(file_remote_dir, filename)} is empty or does not exist! Skipping download')
            return False
        return True

    @staticmethod
    def _get_log_dir(suite_log_dir=False):
        """
        Get default directory for storing logs.
        """

        output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
        if not suite_log_dir:
            try:
                return os.path.join(output_dir, BuiltIn().get_variable_value("${TEST_NAME}"))
            except TypeError:
                logger_info(f'Logs collected in suite logs dir.')
        return os.path.join(output_dir, BuiltIn().get_variable_value("${SUITE_NAME}"))

    def delete_pcap_logs_from_units(self):
        run_on_gnb('rm /rom/logs/*.pcap*')
        run_on_gnb('rm /rom/logs/*.pcap*', hostname=self.gnb2_ip)

    def enable_dcap(self):
        """
        Start DCAP application with cmd 'DCAP_Basic_controller start'
        """

        self.dcap_instance.start_dcap_basic_controller()

    def restart_dcap(self):
        """
        Restart DCAP application with cmd 'DCAP_Basic_controller restart'
        """
        self.dcap_instance.restart_dcap_basic_controller()

    def configure_bts_in_dcap(self, gnb_ip):
        """
        Check ig BTS in configured in DCAP, if not perform configuration.

        :param gnb_ip: (str) IP address of gNB
        """

        self.dcap_instance.create_dcap_session()
        self.dcap_instance.check_if_bts_is_configured_in_dcap(ip=gnb_ip)

    def start_collecting_tti_traces(self, port='443', gnb='gnb2', gnb_custom_profile=['L2Ps_Component'], gnb_ip=None):
        """
        Start collecting TTI traces with DCAP on a single gNB.

        :param port: (str) Port number to be used for the connection. Default is '443'.
        :param gnb: (str) Identifier for the gNB. Should be 'gnb1' or 'gnb2'. Default is 'gnb2'.
        :param gnb_custom_profile: (list) List of custom profiles to be used for the gNB. Default is ['L2Ps_Component'].
        :param gnb_ip: (str, optional) Custom IP address for the gNB. If not provided, the IP will be
        fetched using _get_gnb_ip.
        """

        if gnb_ip:
            self.configure_bts_in_dcap(gnb_ip)
        else:
            self.configure_bts_in_dcap(gnb_ip=self._get_gnb_ip(gnb))
        bts_details = {'host': gnb_ip or self._get_gnb_ip(gnb),
                       'username': self.webem_username,
                       'password': self.webem_password,
                       'port': port}
        self.dcap_instance.create_dcap_session()
        try:
            self.dcap_instance.start_new_trace(bts_details=bts_details, gnb_custom_profile=gnb_custom_profile)
        except (RuntimeError, ApiException) as trace_failure:
            logger_warning(f'Starting tew trace has failed: {trace_failure}. Performing second attempt...')
            bts = self.dcap_instance.get_dcap_bts_id(ip=self._get_gnb_ip(gnb))
            self.dcap_instance.delete_bts_from_dcap(bts_id=bts)
            self.configure_bts_in_dcap(gnb_ip=self._get_gnb_ip(gnb))
            trace_id = \
                self.dcap_instance.start_new_trace(bts_details=bts_details, gnb_custom_profile=gnb_custom_profile)
            logger_console_info(f'Trace status: {self.dcap_instance.get_trace_status(trace_id)}')

    def stop_collecting_dcap(self, gnb='gnb2', filename=None, gnb_ip=None):
        """
        Stop collecting DCAP traces and save results to logs directory.

        This function stops the collection of DCAP traces for a specified gNB and saves the results to a zip file
        in the logs directory. If a filename is provided, it will be used as the base name for the zip file; otherwise,
        a default name will be used.

        :param gnb: (str) Identifier for the gNB. Should be 'gnb1' or 'gnb2'. Default is 'gnb2'.
        :param filename: (str, optional) Name of the DCAP zip file. If not provided, a default name will be used.
        :param gnb_ip: (str, optional) Custom IP address for the gNB. If not provided, the IP will be fetched
        using _get_gnb_ip.

        :return: (str) Path to the saved DCAP result zip file.
        """

        target_dir = self._get_log_dir()

        if filename:
            filename = f'{filename}_{gnb}'
        else:
            filename = f'dcap_result_{gnb}'

        self.dcap_instance.create_dcap_session()
        self.dcap_instance.stop_trace(ip=gnb_ip or self._get_gnb_ip(gnb))
        result_file_path = self.dcap_instance.get_result_file(
            target_dir=target_dir,
            ip=gnb_ip or self._get_gnb_ip(gnb),
            target_file_name=filename
        )
        return result_file_path

    def _extract_dcap_zip(self, filename=None, gnb='gnb2'):
        """
        Unpack DCAP results .zip file

        :param filename: (str) Name of DCAP results .zip file
        :param gnb: (str) 'gnb1' or 'gnb2'
        """

        dcap_zip_file_path = os.path.join(self._get_log_dir(), f'{filename}_{gnb}.zip') if filename \
            else os.path.join(self._get_log_dir(), f'dcap_result_{gnb}.zip')
        extract_dir = dcap_zip_file_path.replace('.zip', '')
        shutil.unpack_archive(dcap_zip_file_path, extract_dir=extract_dir)
        return extract_dir

    def extract_tti_from_dcap_zip(self, filename=None, output_file_format='legacyCsv',
                                  excel_csv_options='-d combineDlAndUl', gnb='gnb2'):
        """
        Convert TTI traces from .pcap to .csv

        :param filename: (str) Name of DCAP results .zip file
        :param output_file_format: (str) e.g. 'json', 'legacyCsv' or 'excelCsv'
        :param excel_csv_options: (str)
        :param gnb: (str) 'gnb1' or 'gnb2'
        """

        extract_dir = self._extract_dcap_zip(filename, gnb)
        pcap_filepaths = find_pcaps_in_dcap_result_dir(extract_dir)
        ed = eventdecoder()
        for i in range(len(pcap_filepaths)):
            ed.create_eventdecoder_converter(
                name='ttitrace_converter',
                input_file_path=pcap_filepaths[i],
                output_file_format=output_file_format,
                output_file_path=os.path.join(extract_dir, f'tti_trace{str(i)}'),
                excel_csv_options=excel_csv_options
            )
            ed.convert(name='ttitrace_converter')

    def activate_l2_ps_logging(self):
        """
        Add R&D flags that enable L2-PS debug logging to gNBs' swconfigs.
        Save backup swconfig files in suite logs dir.
        """

        config_modifier = SwConfigModifier()
        config_modifier.activate_l2_ps_debug_logging(
            host=self.gnb1_ip,
            reboot=False,
            local_swconfig_path=os.path.join(self._get_log_dir(), 'backup_swconfig_gnb1.txt')
        )
        config_modifier.activate_l2_ps_debug_logging(
            host=self.gnb2_ip,
            reboot=False,
            local_swconfig_path=os.path.join(self._get_log_dir(), 'backup_swconfig_gnb2.txt')
        )

    def _get_gnb_ip(self, gnb):
        if gnb == 'gnb1':
            return self.gnb1_ip
        else:
            return self.gnb2_ip

    def get_nr_70b_kpi_value(self):
        """
        Wait for next PM counters interval, download PM counters file and calculate KPI NR_70B value.

        :return: (float)
        """

        kpi_calc_instance = KpiCalculation()
        kpi_calc_instance.set_counter_file_path(log_dir=self._get_log_dir())
        nr_70b = kpi_calc_instance.calculate_nr_70b_value()
        logger_console_info(f'NR_70B KPI value: {nr_70b}')
        return nr_70b
