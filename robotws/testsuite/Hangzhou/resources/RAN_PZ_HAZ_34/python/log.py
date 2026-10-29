# -*- coding: utf-8 -*-
"""
Generic keywords for BTS.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
import os
import re
import time
import datetime
import logging
import zipfile
from io import BytesIO
try:
    import lzma
except ImportError:
    from backports import lzma

from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from moler.exceptions import CommandFailure
from taf.internal.robot_typecasts import time_to_seconds
from taf.converters.sherpa.interface import sherpa
from taf.ul.sc.util.helpers import generate_unix_remote_device
from taf.rfrl.bts.connections import device_aliases
from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout, login_logout_GUI
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.test_config import get_log_path
from taf.rfrl.utilities.robot.general import get_builtin_value, get_builtin_instance
from taf.rfrl.bts.devices.exceptions import FileNotFound
from taf.rfrl.utilities.transfer_files import upload_files, download_files
from taf.rfrl.utilities import tl_config
from taf.rfrl.bts.devices.exceptions import SnapshotNotCollectedInTime


class GenericLog(GenericBts):
    """Logs collecting keywords for eNB and gNB"""

    @login_logout
    def collect_snapshot(self, bts_id=0, log_dir=None, timeout=900, du_id=0, snapshot_coverage="Full"):
        """
        Collect snapshot via API and save to local machine.

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param log_dir: Directory where snapshot will be collected
        :param timeout: Timeout for collecting snapshot
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param snapshot_coverage: Full or Minor snapshot scope
        :return: Full snapshot path
        """
        return self._collect_log(bts_id=bts_id, log_dir=log_dir, timeout=timeout,
                                 file_prefix="Snapshot", extension_file='zip',
                                 method=self.admin.get_snapshot, du_id=du_id, coverage=snapshot_coverage)

    @login_logout
    def collect_im_snapshot(self, bts_id=0, log_dir=None, timeout=900, du_id=0):
        """
        Collect snapshot via API and save to local machine.

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param log_dir: Directory where snapshot will be collected
        :param timeout: Timeout for collecting snapshot
        :return: Full snapshot path
        """
        return self._collect_log(bts_id=bts_id, log_dir=log_dir, timeout=timeout,
                                 file_prefix="IM_Snapshot", extension_file='ims2',
                                 method=self.admin.collect_im_snapshot, du_id=du_id)

    @login_logout
    def collect_ims_log(self, bts_id=0, log_dir=None, timeout=900, du_id=0):
        """
        Collect snapshot via API and save to local machine.

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param log_dir: Directory where snapshot will be collected
        :param timeout: Timeout for collecting snapshot
        :return: Full snapshot path
        """
        return self._collect_log(bts_id=bts_id, log_dir=log_dir, timeout=timeout,
                                 file_prefix="IMS_Log", extension_file='bin',
                                 method=self.admin.collect_infomodel_log_from_current_session, du_id=du_id)

    def _collect_log(self, bts_id, log_dir, timeout, file_prefix, method, extension_file='bin', du_id=0, **kwargs):
        """
        Collect snapshot via API and save to local machine.

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param log_dir: Directory where snapshot will be collected
        :param timeout: Timeout for collecting snapshot
        :param file_prefix: Prefix for file name
        :param method: method object for collecting snapshot
        :param extension_file: extension of the file
        :return: Full snapshot path
        """
        timeout = time_to_seconds(time=timeout)

        if log_dir is None:
            log_dir = get_log_path()

        sw_ver = self.admin.get_sw_version(connection=self.rest_alias.format(bts_id, du_id))
        now = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
        snapshot_file_name = "{}_{}_{}_{}.{}".format(file_prefix, self._get_log_prefix(),
                                                     sw_ver, now, extension_file)
        snapshot_path = os.path.join(log_dir, snapshot_file_name)
        method(connection=self.rest_alias.format(bts_id, du_id), target_file_name=snapshot_path, timeout=timeout,
               **kwargs)

        return snapshot_path

    def _get_log_prefix(self, bts_id=0, du_id=0):
        """
        Collect snapshot via API and save to local machine.

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: log_prefix
        """
        bts_id = int(bts_id)
        log_prefix = "{}_{}_{}".format(self.rest_alias.format(bts_id, du_id), self.get_bts_instance_id(bts_id, du_id),
                                       self.get_global_bts_id(bts_id, du_id))
        return log_prefix

    @load_moler_configuration_from_tl()
    def get_core_files_list(self, bts_id=0, path="/", find_timeout=10, du_id=0):
        """
        Method for checking core log files on gNB.

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :type bts_id:                   int or str
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :type du_id:                   int or str
        :param path:                    path to begin find command from, default: /
        :type path:                     str
        :param find_timeout:            timeout for the find command in seconds, default 10
        :type find_timeout:             float
        :return:
        """
        gnb_device = DeviceFactory.get_device(name=self.ssh_alias.format(bts_id, du_id))
        gnb_device.goto_state("FCT")

        files_to_look_for = ["*core.xz*",
                             "*linux_logs.tar",
                             "dumps.tar",
                             "*crashdump*.tar"]

        merged_names = r'-type f \( -name "{}" \) 2>/dev/null'.format('" -o -name "'.join(files_to_look_for))
        find_command = gnb_device.get_cmd(cmd_name="find",
                                          cmd_params={
                                              "paths": path,
                                              "operators": merged_names
                                          })
        find_results = find_command(timeout=float(find_timeout))
        return find_results["RESULT"]

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def collect_aashell_snapshot(self, bts_id=0, snapshot_name="aashell_snapshot.zip", logs_path=None, du_id=0):
        """
        Collect snapshot via bts aashell console
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param logs_path:
        :param snapshot_name:
        :return: None
        """
        bts = DeviceFactory.get_device(self.ssh_alias.format(bts_id, du_id))
        bts_workstation = DeviceFactory.get_device(self.ws_du_alias.format(bts_id, du_id))
        MolerTest.info("Trying to get snapshot via AaShell")

        if logs_path is None:
            logs_path = get_builtin_value('OUTPUT DIR')

        bts.goto_state(state="FCT", rerun=15)

        MolerTest.info("Remove old snapshot file if exists")
        rm = bts.get_cmd(
            cmd_name="rm",
            cmd_params={
                "file": "/ram/{}".format(snapshot_name)
            }
        )

        try:
            rm()
        except CommandFailure as e:
            MolerTest.info("Probably snapshot doesn't exist: {}".format(repr(e)))

        bts.goto_state(state="AASHELL")
        MolerTest.info("Prepare snapshot zip file")

        log_snapshot = bts.get_cmd(
            cmd_name="log",
            cmd_params={
                "filename": snapshot_name,
                "options": "-a -z"
            }
        )

        log_ret = log_snapshot(timeout=120)
        if len(log_ret['error_files']) > 0:
            MolerTest.warning("There are several files with an opening error: ", dump=log_ret['error_files'])
        MolerTest.info("SNAPSHOT AASHELL info: {}", dump=log_ret)

        bts.goto_state(state="FCT")

        MolerTest.info("Check if snapshot package exists.")
        snapshot_gnb_path = "/ram/{}".format(snapshot_name)
        ls = bts.get_cmd(
            cmd_name="ls",
            cmd_params={
                "options": snapshot_gnb_path
            }
        )

        ls_ret = ls()
        if snapshot_gnb_path in ls_ret['files']:
            MolerTest.info("Found '{}' in ls output. File exists.".format(snapshot_gnb_path))
        else:
            MolerTest.error("Cannot found '{}' in ls ret '{}'. File does not exist.".format(
                snapshot_gnb_path, ls_ret))

        MolerTest.info("Scp snapshot package from enb to host")
        bts_workstation.goto_state(state="UNIX_REMOTE")

        download_files(local_dir=logs_path,
                       remote_file=os.path.basename(snapshot_gnb_path),
                       remote_dir=os.path.dirname(snapshot_gnb_path),
                       device_name=self.ssh_alias.format(bts_id, du_id),
                       timeout=60
                       )

        MolerTest.steps_end()

    @login_logout_GUI
    def collect_snapshot_via_gui(self, bts_id=0, du_id=0):
        """
        Collect snapshot via GUI and save to local machine.
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: path to collected snapshot
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.snapshot_collection_settings(coverage="All log files", save_location="Local",
                                                   sbts=gui_alias)
        path = self.gui_coam.collect_snapshot(sbts=gui_alias)
        return path

    @login_logout_GUI
    def start_and_cancel_snapshot_collection(self, bts_id=0, du_id=0):
        """
        Start to collect snapshot via GUI and cancel it during creation
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: path to collected snapshot
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.snapshot_collection_settings(coverage="All log files", save_location="Local", sbts=gui_alias)
        self.gui_coam.collect_snapshot(snapshot_waiting_timeout=10, sbts=gui_alias)
        self.gui_coam.cancel_collect_snapshot(sbts=gui_alias)

    def find_mandatory_rfsw_logs_in_snapshot(self, directory):
        """
        Search for RFSW files in snapshot
        :param directory: path to directory with snapshot
        :return: None
        """
        file_list = self.find_mandatory_files_in_snapshot(directory)
        mandatory_log_list = ["journal", "hlapi", "runtime", "startup", "ps", "fault_history", "RP1OM"]
        for mandatory_log in mandatory_log_list:
            regex_file_list = re.compile(r'BTS.*RMOD_.*{}'.format(mandatory_log))
            if not list(filter(regex_file_list.match, file_list)):
                raise FileNotFound("Mandatory RFSW file containing name {} "
                                   "not found in snapshot".format(mandatory_log))

    def find_mandatory_files_in_snapshot(self, directory):
        """
        Search for RMOD files in snapshot
        :param directory: path to directory with snapshot
        :return: list of files with BTS_RMOD in name
        """
        bts_part_files = self._get_bts_zip_files_list(directory)
        file_list = self._get_files_from_zipfile_objects(bts_part_files)
        regex = re.compile(r'BTS.*RMOD_.*_UnitOAM_SOAP_Log\.zip')
        if not list(filter(regex.match, file_list)):
            raise FileNotFound("Snapshot doesn't contain demanded files - UnitOAM_SOAP")
        regex_files = re.compile(r'BTS.*RMOD_.*\.zip')
        if not list(filter(regex_files.match, file_list)):
            raise FileNotFound("Snapshot doesn't contain demanded RMOD files")
        return file_list

    def get_latest_gnb_swupdate_time_from_snapshot(self, directory):
        """
        Get latest gNB software update time from SWDL file included in Snapshot.
        :param directory: path to Snapshot file.
        :return: latest swupdate time in datetime format, time in seconds passed since last swupdate.
        """
        bts_part_files = self._get_bts_zip_files_list(directory)
        swdl_zipfile = self._get_specific_snapshot_file(bts_part_files, "SWDLreport")
        with lzma.open(swdl_zipfile) as swdl_file:
            for line in swdl_file:
                if "Finished Activation" in line:
                    swupdate_time = datetime.datetime.strptime(line[0:16], '%Y-%m-%dT%H:%M')
        current_time = datetime.datetime.now()
        time_since_last_swupdate = (current_time - swupdate_time).total_seconds()
        logging.info("Latest software update time:{}".format(swupdate_time))
        logging.info("Time since last software update:{}".format(time_since_last_swupdate))
        return swupdate_time, time_since_last_swupdate

    def _get_bts_zip_files_list(self, directory):
        """
        Makes a list of objects from zip file
        :param directory: path to directory with snapshot
        :return: bts_part_files: object list taken from zip file
        """
        bts_part_files = []
        with zipfile.ZipFile(directory, "r") as snapshot:
            for name in snapshot.namelist():
                if re.search(r'BTS(?:\d+(_\d+)?)?_part(?:_)?\d+\.zip', name) is not None:
                    snapshot_file = BytesIO(snapshot.read(name))
                    bts_part_files.append(snapshot_file)
        if not bts_part_files:
            raise FileNotFound("The snapshot doesn't contain BTS logs.")
        return bts_part_files

    def _get_files_from_zipfile_objects(self, zipfile_list):
        """
        Get list of all files from given zipfile objects.
        :param zipfile_list: list: List of zipfile objects.
        :return file_list: list: List of all files which are included in zipfile objects archives.
        """
        file_list = []
        for i in zipfile_list:
            with zipfile.ZipFile(i) as snapshot_bts:
                for name in snapshot_bts.namelist():
                    file_list.append(name)
        return file_list

    def _get_specific_snapshot_file(self, zipfile_list, filename_part):
        """
        Search for specific file zipped in Snapshot file.
        :param zipfile_list: list: List of zipfile objects.
        :param filename_part: string with wanted file from Snapshot.
        :return: BytesIO: wanted file object from Snapshot
        """
        for snapshot_file in zipfile_list:
            with zipfile.ZipFile(snapshot_file) as snapshot_part:
                for name in snapshot_part.namelist():
                    if filename_part in name:
                        wanted_file = BytesIO(snapshot_part.read(name))
                        logging.info("File: {} found in Snapshot!".format(name))
                        return wanted_file
        raise FileNotFound("The snapshot does not contain the file with '{}' in name!".format(filename_part))

    @load_moler_configuration_from_tl()
    def start_collecting_syslog(self, bts_id=0, du_id=0):
        """
        Base KW for collecting btslog is still 'start_collecting_btslog' and should be used always when
        you need btslog from gNB.
        Keyword 'start_collecting_syslog' should be used only when you need run some moler observers like:
        attach verification, calculate cells startup etc.
        Actually 'start_collecting_syslog' perform only tail -f command on the latest syslog file
        produced by 'start_collecting_btslog' keyword
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:
        """
        self.start_collecting_btslog(bts_id, du_id)
        syslog_device = DeviceFactory.get_device(name=self.syslog_alias.format(bts_id, du_id))
        syslog_device.goto_state("SYSLOG", keep_state=False)

    @load_moler_configuration_from_tl()
    def stop_collecting_syslog(self, bts_id=0, du_id=0):
        """
        Stop collecting syslog - optional keyword for manually stop syslog during test.
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:
        """
        syslog_device = DeviceFactory.get_device(name=self.syslog_alias.format(bts_id, du_id))
        syslog_device.goto_state("UNIX_REMOTE")

    def setup_btslog_collector(self, bts_id=0, du_id=0, common_unit_id=0, target_file_name='syslog_files.tgz'):
        """
        Setup BtsLog collector - using taf.collectors
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param common_unit_id: Id of CommonUnit
        :param target_file_name: file_name.tgz format, its part of the path under which syslog file
                                 stored locally during collect_collectors
        :return:
        """
        core = get_builtin_instance('core')
        btslog = get_builtin_instance('btslog')
        name = "btslog_{}".format(self._get_log_prefix(bts_id, du_id))
        ws_credentials = tl_config.get_bts_ws_credentials(int(bts_id), int(du_id), int(common_unit_id), self.bts_type)
        btslog.create_btslog_collector(name=name, executor=ws_credentials, target_file_name=target_file_name)
        btslog.set_suite_alias(alias=name)
        core.setup_collectors(names=name)

    def start_collecting_btslog(self, bts_id=0, du_id=0, common_unit_id=0):
        """
        Start collecting btslog - using taf.collectors
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param common_unit_id: Id of CommonUnit
        :return:
        """
        core = get_builtin_instance('core')
        name = "btslog_{}".format(self._get_log_prefix(bts_id, du_id))
        btslog_collector = core.get_alias_value(alias=name)
        if not btslog_collector:
            self.setup_btslog_collector(bts_id, du_id, common_unit_id)
        elif btslog_collector._is_started:
            logging.debug("BtsLog for {} is already started. Skipping starting procedure".format(name))
            return
        core.start_collectors(names=name)

    @load_moler_configuration_from_tl()
    def stop_collecting_btslog(self, bts_id=0, du_id=0, log_dir=None, file_prefix=None):
        """
        Stop collecting btslog - using taf.collectors
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param log_dir: Directory where btslog will be collected
        :param file_prefix: By default syslog files are packed and keep in tgz file wilth name: syslog_files.tgz
                            To avoid overwrite this file, please use unique prefix.
        :return:
        """
        core = get_builtin_instance('core')
        name = "btslog_{}".format(self._get_log_prefix(bts_id, du_id))
        btslog_collector = core.get_alias_value(alias=name)
        if btslog_collector and not btslog_collector._is_started:
            logging.debug("BtsLog for {} is not started. Skipping stopping procedure".format(name))
            return

        if log_dir is None:
            log_dir = get_log_path()

        core.stop_collectors(names=name)
        core.collect_collectors(names=name, target_dir=log_dir)
        unix_local = DeviceFactory.get_device(name='UnixLocal')
        if file_prefix:
            source_file = os.path.join(log_dir, name, btslog_collector._target_file_name)
            destination_file = os.path.join(log_dir, name, "{}_{}".format(file_prefix,
                                                                          btslog_collector._target_file_name))
            change_name = unix_local.get_cmd(cmd_name='mv',
                                             cmd_params={'src': "'{}'".format(source_file),
                                                         'dst': "'{}'".format(destination_file)})
            change_name()

        ws_du_device = DeviceFactory.get_device(name=self.ws_du_alias.format(bts_id, du_id))
        logs_to_remove = os.path.join(btslog_collector._log_dir, "SYSLOG_*")
        rm_old_logs = ws_du_device.get_cmd(cmd_name='rm',
                                           cmd_params={'file': logs_to_remove,
                                                       'options': '-rf'})
        try:
            rm_old_logs()
        except CommandFailure as e:
            logging.debug("Cannot clear logs dir {}. {}".format(logs_to_remove, repr(e)))

    def teardown_btslog_collector(self, bts_id=0, du_id=0):
        """
        Teardown btslog collector - using taf.collectors
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:
        """
        core = get_builtin_instance('core')
        name = "btslog_{}".format(self._get_log_prefix(bts_id, du_id))

        core.teardown_collectors(names=name)

    @login_logout_GUI
    def collect_ims2_log_via_gui(self, bts_id=0, timeout=60, local_dir=None, du_id=0):
        """
        Collect IMS log from webui.

        :param local_dir: local directory where log file is copied to. If None file stays in default directory.
        :param timeout: timeout for waiting for ims2 log collection. Default: 60s.
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: local path to log file
        """
        path_to_file = self.gui_coam.save_ims2(waiting_timeout=timeout, sbts=self.gui_alias.format(bts_id, du_id))
        if local_dir is not None:
            index = path_to_file.rfind('/')
            filename = path_to_file[index:]
            local_machine = DeviceFactory.get_device(device_class='moler.device.unixlocal.UnixLocal')
            cp_cmd = local_machine.get_cmd(cmd_name="cp", cmd_params={
                'src': path_to_file,
                'dst': local_dir + filename
            })
            cp_cmd()
            path_to_file = local_dir + filename
        return path_to_file

    @login_logout_GUI
    def start_streaming_sherpa_logs_via_gui(self, cells_list=[], bts_id=0, timeout=60, du_id=0):
        """
        Start streaming Sherpa logs.
        :param cells_list: list of cells for LO and PS tracing. If empty all available cells are traced.
        :param timeout: timeout for waiting for single sherpa log collection. Default: 60s.
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        timeout = time_to_seconds(timeout)
        status_l2hi = self.gui_coam.start_l2_hi_pdcp_sherpa_trace_and_return_result(timeout=timeout, sbts=gui_alias)
        logging.info("Start L2 HI PDCP sherpa trace status: {}".format(status_l2hi))
        status_l2lo = self.gui_coam.start_l2_lo_sherpa_trace_and_return_result(cells_list=cells_list, timeout=timeout,
                                                                               sbts=gui_alias)
        logging.info("Start L2 LO sherpa trace status: {}".format(status_l2lo))
        status_l2ps = self.gui_coam.start_l2_ps_sherpa_trace_and_return_result(cells_list=cells_list, timeout=timeout,
                                                                               sbts=gui_alias)
        logging.info("Start L2 PS sherpa trace status: {}".format(status_l2ps))

    @login_logout_GUI
    def stop_streaming_sherpa_logs_via_gui(self, bts_id=0, du_id=0):
        """
        Stop streaming Sherpa logs.
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.stop_sherpa_trace(uplane_sherpa_name="L2-HI", source="PDCP", sbts=gui_alias)
        self.gui_coam.stop_sherpa_trace(uplane_sherpa_name="L2-LO", sbts=gui_alias)
        self.gui_coam.stop_sherpa_trace(uplane_sherpa_name="L2-PS", sbts=gui_alias)

    def setup_tcpdump_collector(self, options="", bts_id=0, du_id=0, common_unit_id=0):
        """
        Setup tcpdump collector - using taf.collectors
        :param options: (optional) tcpdump options (except -w), default: empty string
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param common_unit_id: Id of CommonUnit
        :return: None
        """
        core = get_builtin_instance('core')
        tcpdump = get_builtin_instance('tcpdump')
        name = "tcpdump_{}".format(self._get_log_prefix(bts_id, du_id))
        ws_credentials = tl_config.get_bts_ws_credentials(int(bts_id), int(du_id), int(common_unit_id), self.bts_type)

        tcpdump.create_tcpdump_collector(name=name, options=options, executor=ws_credentials)
        tcpdump.set_suite_alias(alias=name)
        core.setup_collectors(names=name)

    def start_collecting_tcpdump(self, options="", bts_id=0, du_id=0, common_unit_id=0):
        """
        Start collecting tcpdump - using taf.collectors
        :param options: (optional) tcpdump options (except for -w), default: empty string
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param common_unit_id: Id of CommonUnit
        :return: None
        """
        core = get_builtin_instance('core')
        name = "tcpdump_{}".format(self._get_log_prefix(bts_id, du_id))
        if not core.get_alias_value(alias=name):
            self.setup_tcpdump_collector(options, bts_id, du_id, common_unit_id)
        core.start_collectors(names=name)

    @load_moler_configuration_from_tl()
    def stop_collecting_tcpdump(self, bts_id=0, du_id=0, log_dir=None):
        """
        Stop collecting tcpdump - using taf.collectors
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param log_dir: Directory where tcpdump will be collected. If None default robot log path is used.
        :return: path to tcpdump pcap file
        """
        core = get_builtin_instance('core')
        name = "tcpdump_{}".format(self._get_log_prefix(bts_id, du_id))

        if log_dir is None:
            log_dir = os.path.join(get_log_path(), "tcpdump", "tcpdump_{}".format(time.time()))
        core.stop_collectors(names=name)
        core.collect_collectors(names=name, target_dir=log_dir)
        log_path = os.path.join(log_dir, name)
        return log_path

    def teardown_tcpdump_collector(self, bts_id=0, du_id=0):
        """
        Teardown tcpdump collector - using taf.collectors
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """
        core = get_builtin_instance('core')
        name = "tcpdump_{}".format(self._get_log_prefix(bts_id, du_id))

        core.teardown_collectors(names=name)

    def convert_sherpa_pcap_log_to_csv(self, path_to_pcap, output_dir, bts_id=0, du_id=0, common_unit_id=0):
        """
        Generate set of .csv files from sherpa .pcap log file
        :param path_to_pcap: local path to .pcap file
        :param output_dir: local directory where csv files are stored
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param common_unit_id: Id of CommonUnit - related to Test Line configuration
        :return: None
        """
        sherpa_converter = sherpa()
        ws_credentials = tl_config.get_bts_ws_credentials(int(bts_id), int(du_id), int(common_unit_id), self.bts_type)
        sherpa_converter.create_sherpa_converter(name="sherpa", executor=ws_credentials,
                                                 file_path_pattern=path_to_pcap, output_path=output_dir)
        sherpa_converter.setup(alias="sherpa")
        sherpa_converter.convert(name="sherpa")
        sherpa_converter.teardown(alias="sherpa")

    def verify_snapshot_collection_time(self, bts_id=0, du_id=0, runs=1, location=None,
                                        avg_snapshot_size=96870835, avg_time_delta=300, max_time_delta=600):
        """
        Perform collect snapshot and save to local machine a number of times and check snapshot collection time.
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param runs: amount of runs
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param location: location of saved snapshot
        :param avg_snapshot_size: average snapshot size
        :param avg_time_delta: maximum collection time for average size snapshot
        :param max_time_delta: maximum collection time for above average size snapshot
        :return: None
        """
        run_data = {}
        for run in range(int(runs)):
            start_time = time.time()
            snapshot_path = self.collect_snapshot(log_dir=location)
            end_time = time.time()
            total_size = os.path.getsize(snapshot_path)
            time_delta = end_time - start_time
            run_data[time_delta] = total_size
            if total_size <= avg_snapshot_size:
                if time_delta < avg_time_delta:
                    logging.info('Snapshot {} was saved in correct time'.format(snapshot_path))
                else:
                    raise SnapshotNotCollectedInTime('Snapshot was not saved in correct time')
            elif total_size > avg_snapshot_size:
                if time_delta < max_time_delta:
                    logging.info('Snapshot {} was saved in correct time'.format(snapshot_path))
                else:
                    raise SnapshotNotCollectedInTime('Snapshot was not saved in correct time')

        avg_time = sum(run_data.keys()) / len(run_data)
        avg_size = sum(run_data.values()) / len(run_data)
        logging.info('Time:size {}'.format(str(run_data)))
        logging.info('Average time: {}'.format(avg_time))
        logging.info('Average snapshot size {}'.format(avg_size))

    def check_if_external_snapshot_collected(self, snapshot_name, host, login, password, device_name):
        """
         Verifies if snapshot file is collected on LSS by finding metadata.txt file within current snapshot files.
        :param device_name: Name of the LSS device
        :param snapshot_name: Name of the snapshot file to be collected on LSS
        :param host: Ip address of the remote server where snapshots are stored
        :param login: SHH username for the remote server
        :param password: SHH password for the remote server
        :return: None
        """
        generate_unix_remote_device(device_name, host, login, password)
        logging.info('Snapshot name ' + snapshot_name)
        lss = DeviceFactory.get_device(device_name)
        lss.goto_state("UNIX_REMOTE")
        find_metadata = lss.get_cmd(cmd_name="find",
                                    cmd_params={"options": '/home/coam/{}/ -name *metadata.txt'.format(snapshot_name)})
        find_cmd = lss.get_cmd(cmd_name="sudo",
                                        cmd_params={
                                           "password": password,
                                           "cmd_object": find_metadata})
        if find_cmd()['RESULT'][0]:
            logging.info("Metadata file collected on LSS within {}".format(snapshot_name))
        else:
            raise Exception("Metadata file could not be found on LSS.")

    def remove_external_snapshot(self, snapshot_name, host, login, password, device_name):
        generate_unix_remote_device(device_name, host, login, password)
        logging.info('Snapshot name ' + snapshot_name)
        lss = DeviceFactory.get_device(device_name)
        lss.goto_state("UNIX_REMOTE")
        lss_files = lss.get_cmd(cmd_name="ls")
        snapshot_removal = ""
        if snapshot_name in lss_files()['files'].keys():
            logging.info("Found '{}' in ls output. Snapshot file exists.".format(snapshot_name))
            remove_snapshot = lss.get_cmd(cmd_name='rm',
                                          cmd_params={
                                              'options': '-r',
                                              'file': '{}'.format(snapshot_name)
                                          })
            snapshot_removal = remove_snapshot()
        if snapshot_removal:
            raise Exception("Snapshot could not be removed with status '{}'.".format(snapshot_removal))


class EnbLog(GenericLog):
    """Class contains logs collecting keywords for eNB"""

    bts_type = 'ENB'

    def __init__(self):
        """
        Constructor of Enb class.

        """

        super(EnbLog, self).__init__(bts_type=EnbLog.bts_type)


class GnbLog(GenericLog):
    """Class contains logs collecting keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.

        """
        super(GnbLog, self).__init__(bts_type=GnbLog.bts_type)

    @load_moler_configuration_from_tl()
    def _start_tcpdump_collection_on_cpif_interface(self, interface, capture_file, count=0,
                                                    duration=0, background=False, timeout=300, bts_id=0,
                                                    additional_options=None):
        """
        Start tcpdump collection on the selected interface of the CPIF Virtual Machine
        :param interface:       CPIF VM interface
        :param capture_file:    Name of the capture file
        :param count:           Number of packets to be captured
        :param duration:        Duration of tcpdump in seconds
        :param background:      Flag if tcpdump should run in the background
        :param timeout:         Timeout in seconds to be set for the tcpdump command
        :param bts_id:          BTS ID - related to TestLine configuration
        :param additional_options: options be added to tcpdump command
        """
        options = "-i {} -w {}".format(interface, capture_file)
        if duration:
            options = options + ' -Z root -G {} -W 1'.format(duration)
            if timeout < duration:
                timeout = duration
        elif count:
            options = options + ' -c {}'.format(count)

        if additional_options:
            options = options + ' {}'.format(additional_options)

        if background:
            options = options + '&'

        gnb = DeviceFactory.get_device(format(device_aliases.ssh_gnb_cu.format(bts_id)))
        gnb.goto_state("CPIF")

        tcpdump_cmd = gnb.get_cmd(cmd_name='tcpdump',
                                  cmd_params={
                                      'options': options
                                  })

        sudo_cmd = gnb.get_cmd(cmd_name='sudo',
                               cmd_params={
                                   'cmd_object': tcpdump_cmd
                               })
        sudo_cmd(timeout=timeout)

    def start_tcpdump_collection_on_x2_cpif_interface(self, capture_file, count=0, duration=0,
                                                      background=False, timeout=300, bts_id=0,
                                                      additional_options=None):

        self._start_tcpdump_collection_on_cpif_interface(interface='x2', capture_file=capture_file, count=count,
                                                         duration=duration, background=background,
                                                         timeout=timeout, bts_id=bts_id,
                                                         additional_options=additional_options)

    def start_tcpdump_collection_on_fronthaul_cpif_interface(self, capture_file, count=0, duration=0,
                                                             background=False, timeout=300, bts_id=0,
                                                             additional_options=None):

        self._start_tcpdump_collection_on_cpif_interface(interface='fronthaul', capture_file=capture_file, count=count,
                                                         duration=duration, background=background,
                                                         timeout=timeout, bts_id=bts_id,
                                                         additional_options=additional_options)

    @load_moler_configuration_from_tl()
    def stop_tcpdump_collection_on_cpif_interface(self, bts_id=0):
        """
        Optional keyword for stopping the tcpdump collection on the CPIF interface in the chosen moment
        :param bts_id:    BTS ID - related to TestLine configuration
        """
        gnb = DeviceFactory.get_device(format(device_aliases.ssh_gnb_cu.format(bts_id)))
        ps_cmd = gnb.get_cmd(cmd_name='ps',
                             cmd_params={
                                 'options': '-ef'
                             })
        processes_to_kill = " ".join([str(process['PID']) for process in ps_cmd() if 'tcpdump' in process['CMD']])
        kill_cmd = gnb.get_cmd(cmd_name='kill',
                               cmd_params={'options': '-9', 'pid': processes_to_kill})

        sudo_kill = gnb.get_cmd(cmd_name='sudo',
                                cmd_params={
                                    'cmd_object': kill_cmd
                                })
        sudo_kill()

    @load_moler_configuration_from_tl()
    def upload_bip_mirroring_scripts(self, gnb_id=0, local_scripts_dir=None, du_id=0):
        """
        Upload all scripts needed for capture BIP logs.

        :param gnb_id: BTS(gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param local_scripts_dir: path to directory where BIP scripts are located.
        """
        bip_collector = BipCollecting(bts_device_name=self.ssh_alias.format(gnb_id, du_id),
                                      bts_id=gnb_id, du_id=du_id)
        bip_collector.upload_mirroring_scripts(local_scripts_dir=local_scripts_dir)

    @load_moler_configuration_from_tl()
    def enable_bip_remote_streaming(self, gnb_id=0, du_id=0):
        """
        Enable remote streaming BIP logs.

        :param gnb_id: BTS(gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        bip_collector = BipCollecting(bts_device_name=self.ssh_alias.format(gnb_id, du_id),
                                      bts_id=gnb_id, du_id=du_id)
        bip_collector.enable_remote_streaming()

    @load_moler_configuration_from_tl()
    def disable_bip_remote_streaming(self, gnb_id=0, du_id=0):
        """
        Disable remote streaming BIP logs.

        :param gnb_id: BTS(gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        bip_collector = BipCollecting(bts_device_name=self.ssh_alias.format(gnb_id, du_id),
                                      bts_id=gnb_id, du_id=du_id)
        bip_collector.disable_remote_streaming()

    @load_moler_configuration_from_tl()
    def start_bip_trace_log_capturing(self, gnb_id=0, mode='background', timeout=60 * 60, mirroring_script_params={},
                                      du_id=0):
        """
        Start capturing BIP logs.
        :param gnb_id: BTS(gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param mode: mode of running script, default background. Possible values: foreground/background
        :param timeout: timeout for running command
        :param mirroring_script_params: All available params are in gnbMirroringConfig.sh file. If some
            of params is not passed then will be get directly from gnbMirroringConfig.sh file

            Eg:
            mirroring_script_params = {
                'filtering'='off',
                'syscom_mirroring'='true',
                'carrier_aggregation'='true',
                'mirroring_mode'='local'
            }
        """
        bip_collector = BipCollecting(bts_device_name=self.ssh_alias.format(gnb_id, du_id),
                                      bts_id=gnb_id, du_id=du_id)
        bip_collector.start_log_capturing(mode, int(timeout), mirroring_script_params)

    @load_moler_configuration_from_tl()
    def stop_bip_trace_log_capturing(self, gnb_id=0, du_id=0):
        """
        Stop gnbMirroring.sh script and check if all processes are killed.

        :param gnb_id: BTS(gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        bip_collector = BipCollecting(bts_device_name=self.ssh_alias.format(gnb_id, du_id),
                                      bts_id=gnb_id, du_id=du_id)
        bip_collector.stop_log_capturing()

    @load_moler_configuration_from_tl()
    def download_bip_logs(self, gnb_id=0, download_dir=None, new_file_name=None, timeout=5 * 60, du_id=0):
        """
        Download pcap bib logs from gNB to local machine.

        :param gnb_id: BTS(gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param download_dir: path to directory where file will be downloaded. If not passed Robot
                             output dir will be used.
        :param new_file_name: set if you would like scp file with new name.
        :param timeout: timeout for scp.
        """
        if download_dir is None:
            download_dir = get_builtin_value('OUTPUT DIR')
        timeout = time_to_seconds(time=timeout)

        bip_collector = BipCollecting(bts_device_name=self.ssh_alias.format(gnb_id, du_id),
                                      bts_id=gnb_id, du_id=du_id)
        bip_collector.download_bip_logs(download_dir=download_dir, new_file_name=new_file_name, timeout=timeout)

    @load_moler_configuration_from_tl()
    def start_collecting_tti_trace(self, gnb_id=0, capacity_unit_id=0, common_unit_id=0, du_id=0):
        """
        Start collecting L2TtiTrace_EventsSnapshot files.

        :param gnb_id: BTS(gNB) id - related to Test Line configuration
        :param capacity_unit_id: Capacity Unit ID - related to  Test Line configuration
        :param common_unit_id: Common Unit ID - related to  Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        capacity_unit_device_name = self.ssh_cap_unit_alias.format(gnb_id, du_id, common_unit_id, capacity_unit_id)

        tti_collector = TTITraceCollector(capacity_unit_device_name=capacity_unit_device_name,
                                          bts_id=gnb_id, du_id=du_id)
        tti_collector.start_log_capturing()

    @load_moler_configuration_from_tl()
    def stop_collecting_tti_trace(self, gnb_id=0, capacity_unit_id=0, common_unit_id=0, du_id=0):
        """
        Stop collecting L2TtiTrace_EventsSnapshot files.

        :param gnb_id: BTS(gNB) id - related to Test Line configuration
        :param capacity_unit_id: Capacity Unit ID - related to  Test Line configuration
        :param common_unit_id: Common Unit ID - related to  Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        capacity_unit_device_name = self.ssh_cap_unit_alias.format(gnb_id, du_id, common_unit_id, capacity_unit_id)

        tti_collector = TTITraceCollector(capacity_unit_device_name=capacity_unit_device_name,
                                          bts_id=gnb_id, du_id=du_id)
        tti_collector.stop_log_capturing()

    @load_moler_configuration_from_tl()
    def convert_tti_traces_to_csv(self, gnb_id=0, capacity_unit_id=0, common_unit_id=0, du_id=0):
        """
        Stop collecting L2TtiTrace_EventsSnapshot files.

        :param gnb_id: BTS(gNB) id - related to Test Line configuration
        :param capacity_unit_id: Capacity Unit ID - related to  Test Line configuration
        :param common_unit_id: Common Unit ID - related to  Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        capacity_unit_device_name = self.ssh_cap_unit_alias.format(gnb_id, du_id, common_unit_id, capacity_unit_id)

        tti_collector = TTITraceCollector(capacity_unit_device_name=capacity_unit_device_name,
                                          bts_id=gnb_id, du_id=du_id)
        tti_collector.convert_to_csv()

    @load_moler_configuration_from_tl()
    def download_tti_trace_csv_logs(self, gnb_id=0, capacity_unit_id=0, common_unit_id=0, du_id=0, download_dir=None,
                                    timeout=180):
        """
        Download converted CSV files to local machine.

        :param gnb_id: BTS(gNB) id - related to Test Line configuration
        :param capacity_unit_id: Capacity Unit ID - related to  Test Line configuration
        :param common_unit_id: Common Unit ID - related to  Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param download_dir: path to directory where file will be downloaded. If not passed Robot
                                     output dir will be used.
        :param timeout: timeout for scp.

        """
        timeout = time_to_seconds(time=timeout)
        capacity_unit_device_name = self.ssh_cap_unit_alias.format(gnb_id, du_id, common_unit_id, capacity_unit_id)

        tti_collector = TTITraceCollector(capacity_unit_device_name=capacity_unit_device_name,
                                          bts_id=gnb_id, du_id=du_id)

        if download_dir is None:
            download_dir = get_builtin_value('OUTPUT DIR')
        tti_collector.download_logs(download_dir=download_dir, timeout=timeout)

    def collect_lococtl_logs(self, gnb_id=0, du_id=0, common_unit_id=0, capacity_unit_id=None, log_dir=None):
        """
        Collect lococtl logs from Capacity Unit.
        :param gnb_id:              gNB id - related to Test Line configuration. Default: 0
        :param du_id:               DU id(Distributed Unit) - id related to Test Line configuration. Default: 0
        :param common_unit_id:      Common Unit ID - related to  Test Line configuration. Default: 0
        :param capacity_unit_id:    Capacity Unit ID - related to  Test Line configuration.
                                    If None - collect from all capacity units
        :param log_dir:             local directory path where logs will be downloaded.
                                    If None - default logs dir will be used: ${OUTPUT DIR}/Logs/<timestamp>
        """
        if capacity_unit_id is not None:
            capacity_unit_ids = [capacity_unit_id]
        else:
            capacity_unit_ids = range(tl_config.get_count_of_capacity_units(bts_id=gnb_id, du_id=du_id,
                                                                            common_unit_id=common_unit_id,
                                                                            bts_type=self.bts_type))
        if log_dir is None:
            log_dir = get_log_path()

        for _capacity_unit_id in capacity_unit_ids:
            cap_unit_device_name = self.ssh_cap_unit_alias.format(gnb_id, du_id, common_unit_id, _capacity_unit_id)
            remote_file = self._collect_lococtl_logs(gnb_id, du_id, common_unit_id, _capacity_unit_id)
            download_files(local_dir=log_dir,
                           remote_file=os.path.basename(remote_file),
                           remote_dir=os.path.dirname(remote_file),
                           device_name=cap_unit_device_name)

    @load_moler_configuration_from_tl()
    def _collect_lococtl_logs(self, gnb_id=0, du_id=0, common_unit_id=0, capacity_unit_id=0, timeout=60):
        """
        Collect lococtl logs from Capacity Unit.
        :param gnb_id:              gNB id - related to Test Line configuration. Default: 0
        :param du_id:               DU id(Distributed Unit) - id related to Test Line configuration. Default: 0
        :param common_unit_id:      Common Unit ID - related to  Test Line configuration. Default: 0
        :param capacity_unit_id:    Capacity Unit ID - related to  Test Line configuration. Default: 0
        :param timeout:             timeout for collecting logs
        """

        capacity_unit_device_name = self.ssh_cap_unit_alias.format(gnb_id, du_id, common_unit_id, capacity_unit_id)
        cap_device = DeviceFactory.get_device(capacity_unit_device_name)
        cap_device.goto_state("FSP")

        file_name = '{}_lococtl_loner.tgz'.format(capacity_unit_device_name)
        log_path = os.path.join('/tmp', file_name)
        collect_logs = cap_device.get_cmd(cmd_name="run_script",
                                          cmd_params={
                                              'script_command': 'lococtl -tar {}'.format(
                                                  os.path.splitext(log_path)[0])})
        collect_logs(timeout=timeout)
        return log_path

    @load_moler_configuration_from_tl()
    def collect_swdl_report(self, gnb_id=0, du_id=0, log_dir=None):
        """
        Collect SWDLreport.txt from DU.
        :param gnb_id:      gNB id - related to Test Line configuration. Default: 0
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration. Default: 0
        :param log_dir:     local directory path where logs will be downloaded.
                            If None - default logs dir will be used: ${OUTPUT DIR}/Logs/<timestamp>
        """

        if log_dir is None:
            log_dir = get_log_path()

        gnb_device_name = self.ssh_alias.format(gnb_id, du_id)
        gnb_device = DeviceFactory.get_device(name=gnb_device_name)
        gnb_device.goto_state("FCT")

        download_files(local_dir=log_dir,
                       remote_file='SWDLreport.txt',
                       remote_dir='/rom/config/',
                       device_name=gnb_device_name)


class BipCollecting(object):
    script_name = 'gnbMirroring.sh'
    config_name = 'gnbMirroringConfig.sh'
    gulp = 'gulp'
    remote_log_dir = '/tmp/'

    def __init__(self, bts_device_name, remote_dir='/ffs/run/config/scripts/', bts_id=None, du_id=None):

        self.bts_name = bts_device_name
        self.bts = DeviceFactory.get_device(bts_device_name)
        self.remote_dir = remote_dir

        self.bts_id = bts_id
        self.du_id = du_id

    def upload_mirroring_scripts(self, local_scripts_dir=None):
        r"""
        Start BIP capture on gnb ASIK to support for 19A, 19B and trunk. Also support feature 1514.
        The scripts location: \\eseefsn50.emea.nsn-net.net\rotta4internal\5G\Oulu_L3_CAMP\gnbMirroring\V23
        The binary file should not be uploaded to robotws5g, so if gulp engine is needed for capturing
        instead of tcpdump, gulp file should be uploaded from other path.

        :param local_scripts_dir: default path is resources/Macro/Python/bts/scripts//BIP/
        """
        # TODO Add support for gulp

        if local_scripts_dir is None:
            local_scripts_dir = self._get_default_scripts_path()

        upload_files(local_dir=local_scripts_dir,
                     local_file='{},{}'.format(self.script_name, self.config_name),
                     remote_dir=self.remote_dir,
                     device_name=self.bts_name,
                     )

        chmod = self.bts.get_cmd(cmd_name='chmod',
                                 cmd_params={'permission': '777', 'filename': "{}/*.sh".format(self.remote_dir)})

        chmod()

        try:
            self._clear_tcpdump_logs()
        except CommandFailure:
            logging.debug("No files to remove")

    @staticmethod
    def _get_default_scripts_path():
        return os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'scripts', 'BIP'))

    def enable_remote_streaming(self):
        """
        Enable remote streaming.
        :return: None
        """
        self._run_mirroring_script(mode='foreground', mirroring_script_params={'mirroring_mode': 'remote'},
                                   timeout=60)

    def disable_remote_streaming(self):
        """
        Disable remote streaming.
        :return: None
        """
        self._run_mirroring_script(mode='foreground', mirroring_script_params={'mirroring_mode': 'local',
                                                                               'capturing_time_seconds': '1'},
                                   timeout=60)

    def start_log_capturing(self, mode='background', timeout=60 * 60, mirroring_script_params={}):
        """
        Start capturing BIP logs.
        :param mode: mode of running script, default background. Possible values: foreground/background
        :param timeout: timeout for running command
        :param mirroring_script_params: All available params are in gnbMirroringConfig.sh file. If some
            of params is not passed then will be get directly from gnbMirroringConfig.sh file

            Eg:
            mirroring_script_params = {
                'filtering'='off',
                'syscom_mirroring'='true',
                'carrier_aggregation'='true',
                'mirroring_mode'='local'
            }
        """
        self._run_mirroring_script(mode=mode, timeout=timeout, mirroring_script_params=mirroring_script_params)

    def _run_mirroring_script(self, mode='background', timeout=60 * 60, mirroring_script_params={}):
        """
        Run gnbMirroring.sh script with passed mirroring_script_params params.
        :param mode: mode of running script, default background. Possible values: foreground/background
        :param timeout: timeout for running command
        :param mirroring_script_params: All available params are in gnbMirroringConfig.sh file. If some
            of params is not passed then will be get directly from gnbMirroringConfig.sh file

            Eg:
            mirroring_script_params = {
                'filtering'='off',
                'syscom_mirroring'='true',
                'carrier_aggregation'='true',
                'mirroring_mode'='local'
            }
        """
        options = self._get_bip_options(mirroring_script_params)
        cmd_string = "sh {} {}".format(os.path.join(self.remote_dir, self.script_name), options)

        self.bts.goto_state(state=self.bts.initial_state)
        collect_bip = self.bts.get_cmd(cmd_name='run_script', cmd_params={'script_command': cmd_string})

        if mode == 'background':
            pattern = r'.*Can be stopped with Ctrl-[cC]. Output is saved to .*'
            verify_script_started = self.bts.get_event(event_name="wait4",
                                                       event_params={
                                                           "detect_patterns": [pattern],
                                                           "till_occurs_times": 1}
                                                       )
            verify_script_started.start()
            collect_bip.start(timeout=timeout)
            verify_script_started.await_done(timeout=20)
        else:
            collect_bip(timeout=timeout)

    @staticmethod
    def _get_bip_options(mirroring_script_params):
        options = ''
        if mirroring_script_params:
            for param in mirroring_script_params:
                options = "{} --{}='{}'".format(options, param, mirroring_script_params[param])

        return options

    def stop_log_capturing(self):
        """
        Stop gnbMirroring.sh script and check if all processes are killed.
        """
        self.bts.io_connection.moler_connection.sendline(data=chr(3))
        pids = self._get_script_pid()
        if pids:
            self._kill_process(pids=pids)

    def _get_script_pid(self):
        script_process = []
        ps = self.bts.get_cmd(cmd_name='ps', cmd_params={'options': '-ef'})
        running_proccess = ps()
        for process in running_proccess:
            if self.script_name in process['CMD'] or 'tcpdump' in process['CMD']:
                logging.debug("PID: {}, CMD {}".format(process['PID'], process['CMD']))
                script_process.append(process['PID'])

        return script_process

    def _kill_process(self, pids):
        pid_str = " ".join([str(pid) for pid in pids])
        kill = self.bts.get_cmd(cmd_name='kill', cmd_params={'pid': pid_str})
        kill()

    def download_bip_logs(self, download_dir, new_file_name=None, timeout=120):
        """
        Download pcap bib logs from gNB to local machine.(Works only for local mode)

        :param download_dir: path to directory where file will be downloaded.
        :param new_file_name: set if you would like scp file with new name.
        :param timeout: timeout for scp.

        """
        download_files(local_dir=download_dir,
                       remote_file='tcpdump*L2L1*',
                       remote_dir=self.remote_log_dir,
                       device_name=self.bts_name,
                       new_file_name=new_file_name,
                       timeout=timeout
                       )

        self._clear_tcpdump_logs()

    def _clear_tcpdump_logs(self):
        self.bts.goto_state(state=self.bts.initial_state)
        rm = self.bts.get_cmd(cmd_name='rm', cmd_params={'file': '{}tcpdump*L2L1*'.format(self.remote_log_dir),
                                                         'options': '-f'})
        rm()


class TTITraceCollector(object):
    """
    Class for Collecting TTI Traces on ABIL.
    """

    tti_trace_log_dir = '/var/eventsTrace/'
    tti_trace_tool_dir = '/opt/tools/ttiTrace/'
    collect_script_path = os.path.join(tti_trace_tool_dir, 'eventsCollect.sh')
    decoder_script_path = os.path.join(tti_trace_tool_dir, 'eventDecoder')
    csv_log_dir = os.path.join(tti_trace_log_dir, 'TTI_CSV')
    # TODO Add daemon_path -- eventsTraceStart.sh
    # TODO Add possibility convert locally
    _re_index_file_name = re.compile(r'L2TtiTrace_EventsSnapshot.bin.(?P<INDEX>\d+)')

    def __init__(self, capacity_unit_device_name, bts_id=0, du_id=0):
        self.bts_cap_unit_name = capacity_unit_device_name
        self.bts_cap_unit = DeviceFactory.get_device(capacity_unit_device_name)
        self.bts_cap_unit.goto_state("FSP")

        self.bts_id = bts_id
        self.du_id = du_id

    def start_log_capturing(self):
        """
        Start collecting TTI Trace logs by use eventsCollect.sh script
        """
        self._clear_logs()
        self._kill_script_process()

        cmd = "{} > out.txt 2>&1 &".format(self.collect_script_path)
        start_collecting = self.bts_cap_unit.get_cmd(cmd_name='run_script',
                                                     cmd_params={'script_command': cmd})
        start_collecting()
        MolerTest.sleep(seconds=0.5)
        self._verify_script_is_running()

    def _clear_logs(self):
        rm_log = self.bts_cap_unit.get_cmd(cmd_name='rm',
                                           cmd_params={'file': os.path.join(self.tti_trace_log_dir, "*"),
                                                       'options': '-rf'})
        try:
            rm_log()
        except CommandFailure as e:
            logging.debug("Cannot clear logs dir {}. {}".format(self.tti_trace_log_dir, repr(e)))

    def _run_daemon_if_needed(self):
        pass

    def stop_log_capturing(self):
        """
        Stop collecting TTI traces by killing script process.
        """
        self._kill_script_process()

    def _kill_script_process(self):
        script_process = self._get_running_process(script=self.collect_script_path)
        if script_process:
            kill = self.bts_cap_unit.get_cmd(cmd_name='kill',
                                             cmd_params={'options': '-9', 'pid': " ".join(script_process)})

            kill()
            self.bts_cap_unit.io_connection.moler_connection.sendline(data="")

    def _get_running_process(self, script):
        cmd_ps = self.bts_cap_unit.get_cmd(cmd_name="ps",
                                           cmd_params={"options": '-ef'})
        processes = cmd_ps()
        script_process = [str(process['PID']) for process in processes if script in process['CMD']]
        logging.debug("Running process for script {}: {}".format(script, script_process))
        return script_process

    def _verify_script_is_running(self):
        script_process = self._get_running_process(script=self.collect_script_path)
        if not script_process:
            raise EnvironmentError("Fail to start TTI trace script")

    def convert_to_csv(self):
        """
        Convert collected L2TtiTrace_EventsSnapshot.bin* files to csv format and merge to one CSV file(for DL and UL)
        """
        self._convert_tti_trace_to_csv()
        now = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        ul_csv_file = self._merge_csv(direction='ul', timestamp=now)
        dl_csv_file = self._merge_csv(direction='dl', timestamp=now)

        return ul_csv_file, dl_csv_file

    def _convert_tti_trace_to_csv(self):
        """
        Convert packed L2TtiTrace_EventsSnapshot.bin* files to csv format
        """
        event_snapshot_files = self._get_packed_event_snapshot_files()
        logging.debug("All tti trace files: {}".format(event_snapshot_files))
        if not event_snapshot_files:
            raise Exception("There is no TTI trace log found, convert operation stopped")

        self.bts_cap_unit.run(cmd_name='mkdir', cmd_params={"path": self.csv_log_dir, "options": '-p'})
        self.bts_cap_unit.run(cmd_name='cd', cmd_params={'path': self.tti_trace_log_dir})

        for packed_event_snapshot in event_snapshot_files:
            self.bts_cap_unit.run(cmd_name='tar', cmd_params={'options': '-zvxf', 'file': packed_event_snapshot})
            bin_event_snapshot = os.path.basename(packed_event_snapshot.replace('.tar.gz', ''))
            decode_file = self.bts_cap_unit.get_cmd(cmd_name='run_script',
                                                    cmd_params={
                                                        'script_command': '{} {} {}'.format(self.decoder_script_path,
                                                                                            bin_event_snapshot,
                                                                                            os.path.join(
                                                                                                self.csv_log_dir,
                                                                                                bin_event_snapshot))})
            decode_file(timeout=120)

        self.bts_cap_unit.run(cmd_name='rm',
                              cmd_params={
                                  'file': os.path.join(self.tti_trace_log_dir, "L2TtiTrace_EventsSnapshot.bin*"),
                                  'options': '-rf'})

    def _get_packed_event_snapshot_files(self):
        return self._get_files_list(path=os.path.join(self.tti_trace_log_dir, '*.tar.gz'))

    def _get_files_list(self, path):
        cmd_ls = self.bts_cap_unit.get_cmd(cmd_name="ls",
                                           cmd_params={"path": path,
                                                       "options": '-ltr'})
        try:
            ls_output = cmd_ls()
        except CommandFailure:
            logging.warning("File {} doesn't exists on {} device".format(path, self.bts_cap_unit_name))
            return []

        files = list(ls_output['files'].keys())
        sorted_files = sorted(files, key=self._get_index_from_file)
        return sorted_files

    def _get_index_from_file(self, file_name):
        match = self._re_index_file_name.search(file_name)
        if match:
            return int(match.group('INDEX'))

    def _merge_csv(self, direction, timestamp):
        converted_csv_files = self._get_converted_csv_files(direction)
        logging.debug("Converted CSV files for {}: {}".format(direction, converted_csv_files))
        combine_csv_file = os.path.join(self.csv_log_dir, "TA_Combine_{}_Full_{}.csv".format(direction, timestamp))
        for converted_csv_file in converted_csv_files:
            self.bts_cap_unit.run(cmd_name='cat',
                                  cmd_params={'path': converted_csv_file, 'options': '>> {}'.format(combine_csv_file)})

        return combine_csv_file

    def _get_converted_csv_files(self, direction):
        return self._get_files_list(path=os.path.join(self.csv_log_dir,
                                                      'L2TtiTrace_EventsSnapshot*{}.csv'.format(direction)))

    def download_logs(self, download_dir, timeout=180):
        """
        Download Merged TA_Combine*.csv files to log directory on the local machine.

        :param download_dir: path to directory where file will be downloaded.
        :param timeout: timeout for scp.
        """
        download_files(local_dir=download_dir,
                       remote_file='TA_Combine*.csv',
                       remote_dir=self.csv_log_dir,
                       device_name=self.bts_cap_unit_name,
                       timeout=timeout
                       )

        self._clear_logs()
