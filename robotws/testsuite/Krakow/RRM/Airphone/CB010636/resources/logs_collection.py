"""
:author: Anna Bien
:maintainer: Anna Bien, Michal Obszarny
:owner_email: anna.bien@nokia.com, michal.obszarny@nokia.com
:team: I_5G_SW_MMW_PLKRK_04
:email: I_5G_SW_MMW_PLKRK_04@nokia.com
"""

import os
import shutil
import re
import time
import subprocess
import glob
from gzip import open as gzip_open
from ta5g_iphy import ta5g_iphy
from ta5g_pm_counters import ta5g_pm_counters
from taf.sbts.oam.coam.admin import admin
from taf.converters.twdecoder import twdecoder
from ute_syslog.exception import SyslogException
from ute_common_store.exception import AliasError

from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.RRM.Airphone.resources.Python.logs_collector_2xgnb import LogsCollector
from testsuite.Krakow.RRM.Airphone.resources.Python.common_gnb import (
    handle_admin, collect_scf_file, wait_for_requested_bts_state, run_on_gnb
)
from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import (
    download_files_from, change_file_name, unzip_file
)
from testsuite.Krakow.RRM.Airphone.resources.Python.sw_config_modifier import SwConfigModifier
from testsuite.Krakow.RRM.Airphone.resources.Python.dcap_utilities import find_pcaps_in_dcap_result_dir
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import (
    logger_info, logger_warning, logger_console_info
)
from testsuite.Krakow.RRM.Airphone.CB010636.resources.utilities import get_test_prefix

from testsuite.Krakow.RRM.Airphone.CB010636.resources.variables import (
    GNB_IP, GNB2_IP, NOKIA_LOGIN, NOKIA_PASS, SYSCOM_TCS
)


def _use_legacy_if_gnb2(func):
    """
    Decorator to use legacy implementation from LogsCollector class if gNB2 is available.
    """

    def wrapper(*args, **kwargs):
        if GNB2_IP:
            try:
                return getattr(LogsCollector, func.__name__)(*args, **kwargs)
            except AttributeError:
                logger_warning(f'Legacy method {func.__name__} is not defined in LogsCollector class. '
                               f'Executing method from LogsCollectorWrapper class.')
        return func(*args, **kwargs)
    return wrapper


class LogsCollectorWrapper(LogsCollector):
    """
    Inherits from LogsCollector class and provides overridden methods for single gNB.
    """

    def __init__(self):
        super().__init__(GNB2_IP)
        self.default_scf1_filename = 'default_scf_gnb1.xml'
        self.default_scf2_filename = 'default_scf_gnb2.xml'
        self.default_iphy_filename = 'default_iphy.xml'

    @_use_legacy_if_gnb2
    def _get_swconfigs(self, log_dir):
        """
        Download swconfig files.

        :param log_dir: (str)
        """

        download_files_from(
            ip_addr=self.gnb1_ip, username=self.username, password=self.password,
            files='/rom/swconfig.txt', local_path=os.path.join(log_dir, 'swconfig_gnb.txt')
        )
        download_files_from(
            ip_addr=self.ap_ip, username=self.username, password=self.password,
            files='/rom/swconfig.txt', local_path=os.path.join(log_dir, 'swconfig_ap.txt')
        )
        self._validate_if_log_files_exist(['swconfig_gnb.txt', 'swconfig_ap.txt'])
        logger_info('Swconfig files download - success')

    @_use_legacy_if_gnb2
    @handle_admin
    def _collect_snapshots(self, log_dir, **kwargs):
        """
        Collect snapshots for both gNB and Airphone.
        """

        try:
            ta5g_iphy().get_iphy_snapshot(
                output_filepath=os.path.join(log_dir, 'snapshot_ap.zip'),
                all_nodes=True
            )
            self._validate_if_log_files_exist(['snapshot_ap.zip'])
        except (AliasError, AssertionError):
            logger_warning('Could not collect AP snapshot')

        kwargs['connection'].get_snapshot(
            target_file_name=os.path.join(log_dir, 'snapshot_gnb.zip')
        )
        self._validate_if_log_files_exist(['snapshot_gnb.zip'])
        logger_info('Snapshot files download - success')

    @_use_legacy_if_gnb2
    def collect_scfs(self, log_dir=None, scf_gnb1_filename=None, scf_gnb2_filename=None):
        log_dir = log_dir if log_dir else self._get_log_dir()
        scf_gnb1_filename = scf_gnb1_filename if scf_gnb1_filename else self.scf_gnb1_filename
        collect_scf_file(final_path=os.path.join(log_dir, scf_gnb1_filename))

    def collect_default_scfs(self):
        """
        Save default scfs in suite logs directory.
        Note: Function needs to be called in suite setup.
        """

        self.collect_scfs(
            scf_gnb1_filename=self.default_scf1_filename,
            scf_gnb2_filename=self.default_scf2_filename
        )

    def collect_default_iphy(self):
        """
        Save default iphy in suite logs directory.
        """

        log_dir = self._get_log_dir(suite_log_dir=True)
        self._get_iphy(log_dir)
        change_file_name(
            old_name=os.path.join(log_dir, 'iphy.xml'),
            new_name=os.path.join(log_dir, self.default_iphy_filename)
        )

    @_use_legacy_if_gnb2
    def start_collecting_syslog(self):
        try:
            self.syslog_instance.start_syslog(
                log_dir=self._get_log_dir(),
                log_name='syslog.log',
                alias='syslog'
            )
        except SyslogException as exc:
            logger_warning(f'Collecting syslog has failed to start: {exc}')

    @_use_legacy_if_gnb2
    def stop_collecting_syslog_and_download_files(self):
        try:
            self.syslog_instance.stop_syslog(alias='syslog')
        except SyslogException as exc:
            logger_warning(f'Collecting syslog.log has failed: {exc}')
        self._validate_if_log_files_exist(filenames=['syslog.log'])

    @_use_legacy_if_gnb2
    def download_counters_reports(self, counters_type='pm', wait_for_next_interval=True):
        """
        Download RD or PM reports from gNB, e.g. RD.BTS-1.20220929.075500.ANY.xml.gz

        :param counters_type: (str) 'rd' or 'pm'
        :param wait_for_next_interval: (bool)
        """

        pm_counters_instance = ta5g_pm_counters()
        counters_type = counters_type.lower()
        if counters_type == 'rd':
            report_filepath_gnb1 = pm_counters_instance.get_next_unpacked_raw_rd_counters_file(
                output_dirpath=os.path.join(self._get_log_dir(), f'{counters_type}_counters_gnb1'))
        elif counters_type == 'pm':
            if wait_for_next_interval:
                pm_counters_instance.wait_for_next_full_pm_interval()
            report_filepath_gnb1 = pm_counters_instance.get_latest_unpacked_full_pm_counters_file(
                output_dirpath=os.path.join(self._get_log_dir(), f'{counters_type}_counters_gnb1'))
        else:
            raise ValueError(f'Not supported value for parameter counters_type: {counters_type}')
        self._validate_if_log_files_exist(
            [f'{counters_type}_counters_gnb1/{os.path.basename(report_filepath_gnb1)}']
        )
        return report_filepath_gnb1

    def start_tti_traces_collection(self, provided_gnb1_ip=None, provided_gnb2_ip=None):
        """
        Start collecting TTI traces with UTF Lab (Dcap).

        This function initiates the collection of TTI traces for gNB components using the DCAP.
        It supports optional IP addresses for two gNBs.

        :param provided_gnb1_ip: (str, optional) IP address for the first gNB.
        If provided, it will be used to collect TTI traces for 'gnb1'.

        :param provided_gnb2_ip: (str, optional) IP address for the second gNB.
        If provided, it will be used to collect TTI traces for 'gnb2'.

        If not provided, a default method for obtaining the IP will be used.
        """

        if provided_gnb1_ip:
            self.start_collecting_tti_traces(
                gnb='gnb1', gnb_custom_profile=['L2HiRlc_Component', 'L2Lo_Component'], gnb_ip=provided_gnb1_ip
            )
            logger_console_info(f'Start collecting tti traces for {provided_gnb1_ip}')
        elif GNB_IP:
            self.start_collecting_tti_traces(gnb='gnb1', gnb_custom_profile=['L2HiRlc_Component', 'L2Lo_Component'])

        if provided_gnb2_ip:
            self.start_collecting_tti_traces(
                gnb='gnb1', gnb_custom_profile=['L2HiRlc_Component', 'L2Lo_Component'], gnb_ip=provided_gnb2_ip
            )
        elif GNB2_IP:
            self.start_collecting_tti_traces(gnb='gnb2', gnb_custom_profile=['L2HiRlc_Component', 'L2Lo_Component'])

    def stop_tti_traces_collection(self, filename_prefix='dcap_result', provided_gnb1_ip=None, provided_gnb2_ip=None):
        """
        Stop collecting TTI traces with UTF Lab (Dcap).

        This function stops the collection of TTI traces for specified gNB components using the DCAP and saves the
        results to the logs directory with a specified filename prefix.

        :param filename_prefix: (str) Prefix for the filename of the DCAP zip files. Default is 'dcap_result'.

        :param provided_gnb1_ip: (str, optional) Custom IP address for the first gNB ('gnb1').
        If not provided, the default method will be used to obtain the IP.

        :param provided_gnb2_ip: (str, optional) Custom IP address for the second gNB ('gnb2').
        If not provided, the default method will be used to obtain the IP.

        :return: (tuple) Paths to the saved DCAP result zip files for 'gnb1' and 'gnb2'.
        If a gNB is not provided, its corresponding path will be None.
        """

        logs_filepath_gnb2 = None
        if provided_gnb1_ip:
            logs_filepath_gnb1 = self.stop_collecting_dcap(gnb='gnb1', filename=filename_prefix,
                                                           gnb_ip=provided_gnb1_ip)
        else:
            logs_filepath_gnb1 = self.stop_collecting_dcap(gnb='gnb1', filename=filename_prefix)

        if provided_gnb2_ip:
            logs_filepath_gnb2 = self.stop_collecting_dcap(gnb='gnb2', filename=filename_prefix,
                                                           gnb_ip=provided_gnb2_ip)
        elif GNB2_IP:
            logs_filepath_gnb2 = self.stop_collecting_dcap(gnb='gnb2', filename=filename_prefix)

        return logs_filepath_gnb1, logs_filepath_gnb2

    def extract_csv_from_tti_trace(self, tti_trace_filename_gnb1='dcap_result_gnb1.zip',
                                   tti_trace_filename_gnb2='dcap_result_gnb2.zip'):
        """
        Extract zip with TTI Traces and convert .pcap log to .csv
        """

        def convert_pcap_to_csv(dir_path):
            pcap_file_paths = find_pcaps_in_dcap_result_dir(dir_path)
            if len(pcap_file_paths) > 1:
                logger_console_info("Merging pcap files")
                os.system(f'cd {dir_path} ; mergecap -a {" ".join(sorted(pcap_file_paths))} -w tti_trace.pcap')
            else:
                os.system(f'cd {dir_path} ; mv  {pcap_file_paths[0]} tti_trace.pcap')
            self.convert_tti_to_csv(input_file_path=f'{dir_path}/tti_trace.pcap',
                                    output_file_path=f'{dir_path}/csv_1/')

        # def get_latest_dcap_result_file():
        #     zip_files = glob.glob(os.path.join(glob.escape(self._get_log_dir()), "UTFLab*.zip"))
        #     return max(zip_files, key=os.path.getmtime)
        #
        # tti_trace_filename_gnb1 = get_latest_dcap_result_file()
        logger_console_info(f'Extracting {tti_trace_filename_gnb1}')
        utf_lab_output_dir_gnb1 = os.path.join(self._get_log_dir(), os.path.splitext(tti_trace_filename_gnb1)[0])
        unzip_file(os.path.join(self._get_log_dir(), tti_trace_filename_gnb1), utf_lab_output_dir_gnb1)
        convert_pcap_to_csv(dir_path=utf_lab_output_dir_gnb1)
        if GNB2_IP:
            logger_console_info(f'Extracting {tti_trace_filename_gnb2}')
            utf_lab_output_dir_gnb2 = os.path.join(self._get_log_dir(), os.path.splitext(tti_trace_filename_gnb2)[0])
            unzip_file(os.path.join(self._get_log_dir(), tti_trace_filename_gnb2), utf_lab_output_dir_gnb2)
            convert_pcap_to_csv(dir_path=utf_lab_output_dir_gnb2)
        #     return utf_lab_output_dir_gnb1, utf_lab_output_dir_gnb2
        # else:
        #     return utf_lab_output_dir_gnb1

    @staticmethod
    def convert_tti_to_csv(input_file_path, output_file_path, output_file_format='legacyCsv',
                           excel_csv_options='-d combineDlAndUl'):
        logger_console_info(f'Converting {input_file_path} to {output_file_path}')
        excel_csv_options = (f"legacyCsv --combineDlAndUl --timeout 300 -o csv_1"
                             f" --nopcapsplit --maxpcapsize 1000")
        tct = twdecoder()
        tct.create_twdecoder_converter(
            name="twconverter",
            input_file_path=input_file_path,
            tti_trace_decoder_options=excel_csv_options,
        )
        tct.convert(name="twconverter")

    @staticmethod
    def add_swconfig_flags_for_tti_traces(reboot=False, local_swconfig_path='/tmp/swconfig.txt', wait_for_state=True):

        swconfig_flags = {
            '0x5B0613': '1', '0x5a0619': '1', '0x57000B': '0xFFFFFFFF'
        }
        swconfig_modifier_instance = SwConfigModifier()
        swconfig_modifier_instance.add_flags_to_swconfig(
            flags=swconfig_flags,
            host=GNB_IP,
            nokia_login=NOKIA_LOGIN,
            nokia_pass=NOKIA_PASS,
            local_swconfig_path=local_swconfig_path,
            reboot=reboot
        )
        if GNB2_IP:
            swconfig_modifier_instance.add_flags_to_swconfig(
                flags=swconfig_flags,
                host=GNB2_IP,
                nokia_login=NOKIA_LOGIN,
                nokia_pass=NOKIA_PASS,
                local_swconfig_path=local_swconfig_path,
                reboot=reboot
            )
        if wait_for_state:
            wait_for_requested_bts_state(bts_state='Configured', bts_host_ip=GNB_IP)

    @staticmethod
    def add_swconfig_flags_for_locall2lobursts(reboot=False, local_swconfig_path='/tmp/swconfig.txt',
                                               wait_for_state=True):
        """
        Adds swconfig flags needed for -B subfeature. With this, LocalL2LoBurstsTx.csv file is created

        Args:
            reboot (bool, optional): Whether to reboot after adding the flags. Defaults to False.
            local_swconfig_path (str, optional): The local path of the swconfig file. Defaults to '/tmp/swconfig.txt'.
            wait_for_state (bool, optional): Whether to wait for the requested BTS state. Defaults to True.
        """

        swconfig_flags = {
            '0x570030': '1',
        }
        suite_prefix = BuiltIn().get_variable_value("${SUITE_NAME}")
        swconfig_modifier_instance = SwConfigModifier()
        if 'CB010636-B' in suite_prefix or 'CB010636-E' in suite_prefix or 'CB010636-C':
            swconfig_modifier_instance.add_flags_to_swconfig(
                flags=swconfig_flags,
                host=GNB_IP,
                nokia_login=NOKIA_LOGIN,
                nokia_pass=NOKIA_PASS,
                local_swconfig_path=local_swconfig_path,
                reboot=reboot
            )
            if GNB2_IP:
                swconfig_modifier_instance.add_flags_to_swconfig(
                    flags=swconfig_flags,
                    host=GNB2_IP,
                    nokia_login=NOKIA_LOGIN,
                    nokia_pass=NOKIA_PASS,
                    local_swconfig_path=local_swconfig_path,
                    reboot=reboot
                )
        if wait_for_state:
            wait_for_requested_bts_state(bts_state='Configured', bts_host_ip=GNB_IP)

    def start_syscom_collection(self, file_name_prefix='xp_syscom'):
        """
        Start collecting SysCom on gnb1.
        :param file_name_prefix: (str)
        """

        self._send_command(cmd=f'nohup syscomdump -w /rom/logs/{file_name_prefix}_gnb1.pcap >/dev/null 2>&1 &',
                           hostname=self.gnb1_ip, get_pty=False)

    def stop_syscom_collection(self, file_name_prefix='xp_syscom'):
        """
        Stop collecting SysCom and download files to VM.
        :param file_name_prefix: (str)
        """

        run_on_gnb(cmd='pkill -f syscomdump')
        self.download_file_from_unit(f'{file_name_prefix}_gnb1.pcap', hostname=self.gnb1_ip)
        self._validate_if_log_files_exist([f'{file_name_prefix}_gnb1.pcap'])

    def start_syscom_collection_for_selected_tcs(self):
        test_prefix = get_test_prefix()
        if test_prefix in SYSCOM_TCS:
            self.start_syscom_collection()

    def stop_syscom_collection_for_selected_tcs(self):
        test_prefix = get_test_prefix()
        if test_prefix in SYSCOM_TCS:
            self.stop_syscom_collection()

    def create_test_log_directory(self):
        """
        Clear test log directory if exists.
        Note: Must be executed within test case working space
        """

        logs_path = self._get_log_dir()
        if os.path.exists(logs_path):
            shutil.rmtree(logs_path)
        os.mkdir(logs_path)

    @staticmethod
    def start_ip_traffic_capturing(measurement_point, uplane_capturing):
        admin_obj = admin()
        admin_connection = admin_obj.connect_to()
        admin_obj.start_ip_capture_file(measurement_point, uplane_capturing, connection=admin_connection)
        admin_obj.teardown_admin()

    @staticmethod
    def stop_ip_traffic_capturing_and_download_file(file_name):
        admin_obj = admin()
        admin_connection = admin_obj.connect_to()
        admin_obj.stop_ip_capture_file(connection=admin_connection)
        admin_obj.generate_ip_capture_file(connection=admin_connection)
        admin_obj.download_ip_capture_file(file_name, connection=admin_connection)
        admin_obj.teardown_admin()

    def collect_ip_traffic_capturing_traces_to_file(self, time, measurement_point, uplane_capturing, file_name):
        self.start_ip_traffic_capturing(measurement_point, uplane_capturing)
        time.sleep(int(time))
        self.stop_ip_traffic_capturing_and_download_file(f'{file_name}.pcap.gz')

        with gzip_open(f'{file_name}.pcap.gz', 'rb') as gzip_file:
            with open(f'{file_name}.pcap', 'wb') as pcap_file:
                shutil.copyfileobj(gzip_file, pcap_file)

    def update_utf_lab(self):
        os.system(r'utf_lab-updates')
        os.system(r'sudo UTE_CLOUD=1 bash /home/ute/Downloads/utf_lab_installer.latest.sh $(ip address show dev eth0 '
                  r'| grep -oP "\d+\.\d+\.\d+\.\d+(?=/)")')

    def get_testline_name(self):
        with open('/home/ute/testline_init_results/agent.log', "r", encoding="utf-8") as file:
            log_text = file.read()
        hostname_match = re.search(r'HOSTNAME:\s+(\S+)', log_text)
        return hostname_match.group(1)

    def activate_scout_cli(self):
        command = "source $(pyenv root)/versions/agent_scout_env/bin/activate && scout-cli testline " \
                  "-c /home/ute/testline_init_results/agent_scout/results/config_files/scout.conf start"
        subprocess.run(command, shell=True, executable="/bin/bash")
