# -*- coding: utf-8 -*-
"""
Keywords for collecting/converting QXDM logs.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
import re
import os
import yaml
import time
import logging
from moler.device import DeviceFactory
from moler.exceptions import CommandFailure
from licence_keeper import licence_keeper
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.utilities \
    import load_moler_configuration_from_tl, get_builtin_value
from testsuite.Bangalore.ORAN.resources.python.Macro.\
    Python.helpers.tl_config import get_ue_pc_credentials
from testsuite.Bangalore.ORAN.resources.python.Macro.\
    Python.transfer_files import upload_files, download_files
from testsuite.Bangalore.ORAN.resources.python.Macro.Python\
       import connection_names


class QxdmLogsCollector(object):
    def __init__(
      self, script_name='QXDM5LogCatch.py',
            ue_pc_dir_path='c:/auto/'):
        self.script_name = script_name
        self.ue_pc_dir_path = ue_pc_dir_path
        self.ue_pc_logs_dir = os.path.join(
             self.ue_pc_dir_path, 'logs')
        self.script_path = os.path.join(
             self.ue_pc_dir_path, self.script_name)
        self._hdf_log_file = None
        self._txt_log_file = None

    @load_moler_configuration_from_tl()
    def upload_qxdmlogcatch_script(self, ue_id=0):
        """
        Upload QXDM5LogCatch.py to UE PC.
        QXDM5LogCatch.py allows collect QXDM logs and save it to *.hdf format.
        :param ue_id: ID of UE
        :return: None
        """
        upload_files(local_dir=self._get_scripts_dir_path(),
                     local_file=self.script_name,
                     remote_dir=self._convert_to_cygpath(self.ue_pc_dir_path),
                     device_name=connection_names.ue_pc.format(ue_id),
                     )

    def collect_qxdm_hdf_log(
            self,
            log_file=None,
            ue_id=0,
            duration=60,
            dmc_file=None,
            com_port=None,
            python_path=None):
        """
        Keyword for start collecting QXDM hdf log in the background.

        :param ue_id:
             UE id - related to Test Line configuration - tl.ues.
        :type dmc_file:
           path to dmc configuration file
        :param com_port:
            UE COM port number eg: 9, or for QXDM5 could be 'MDM'
        :type log_file:
           path to log
        :param duration:
          duration of collecting log
        :type python_path:
           path to python eg:
            ''C:/Python27/python.exe''
        :return: None
        Sample Android configuration from __init__.py
        _android_ue = Android(
            ssh_connection_details=_ue_pc_ssh,
            serial_number="7d586bb0",
            server_dir="/cygdrive/c/pyro_server",
            python_path="C:/Python27/python.exe",
            qcat_path=
              "C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
            diag_cfg_path="C:/pyro_server/DIAG.cfg",
            dmc_path="c:/usb/Config-4G-5G-SDx55-RFP_v0.4.dmc",
            diag_com="MDM",
            iperf_details=_android_iperf,
            capabilities=["REAL_ANDROID_UE"],
        )
        """
        if not log_file:
            log_file = os.path.join(self.ue_pc_logs_dir, 'qxdm.hdf')
        if not python_path:
            python_path = get_builtin_value(
                'tl.ues[{}].python_path'.format(ue_id))
        if not com_port:
            com_port = get_builtin_value('tl.ues[{}].diag_com'.format(ue_id))
        if not dmc_file:
            dmc_file = get_builtin_value('tl.ues[{}].dmc_path'.format(ue_id))

        self._hdf_log_file = log_file

        cmd = "{} '{}' -t {} -p {} -c '{}' -s '{}'".format(
            python_path,
            self.script_path,
            duration,
            com_port, dmc_file,
            self._hdf_log_file)

        self._execute_ue_pc_cmd(
            ue_id=ue_id, cmd=cmd,
            timeout=int(duration) + 20, background=True,
            error_regex=re.compile(r'(Fail to connect port COM)|'
                                   r'(Unable to obtain ISF interface)|'
                                   r'(Unable to load the dmc)'))

    def convert_hdf_log_to_txt(
            self, hdf_log=None,
            ue_id=0, qcat_path=None,
            timeout=120):
        """
        Keyword for converting hdf log to txt format.

        :param ue_id:
            UE id - related to Test
             Line configuration - tl.ues
        :param hdf_log:
             path to hdf log
        :param qcat_path:
           path to QCAT.exe eg:
            ''C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe''
        :param timeout:
               timeout for converting isf --> txt
        """
        if not qcat_path:
            qcat_path = get_builtin_value(
                'tl.ues[{}].qcat_path'.format(ue_id))
        if not hdf_log:
            hdf_log = self._hdf_log_file

        self._txt_log_file = hdf_log.replace('.hdf', '.txt')

        cmd = "'{}' -txt '{}'".format(qcat_path, hdf_log)
        try:
            self._execute_ue_pc_cmd(
                ue_id=ue_id, cmd=cmd,
                timeout=timeout)
        except CommandFailure as e:
            if r'The remote server returned an error: (404) Not Found' \
                    not in repr(e):
                raise e

        return self._txt_log_file

    def download_qxdm_logs(
            self, download_dir=None,
            log_file=None,
            ue_id=0,
            timeout=60):
        """
        Download all logs from UE_PC to local PC.

        :param download_dir:
         path to directory where file will
           be downloaded. If not passed Robot

                             output dir will be used.
        :param log_file:
          path to logs located on
           UE_PC - could pass many separated by comma
        :param ue_id:
             UE id - related
              to Test Line configuration - tl.ues.
        :param timeout:      timeout for downloading file
        """

        if download_dir is None:
            download_dir = get_builtin_value('OUTPUT DIR')

        if log_file is None:
            log_file = ",".join(
                [os.path.basename(self._hdf_log_file),
                 os.path.basename(self._txt_log_file)])
            remote_dir = os.path.dirname(self._hdf_log_file)
        else:
            files = log_file.split(',')
            remote_dir = os.path.dirname(files[0])

        download_files(local_dir=download_dir,
                       remote_file=log_file,
                       remote_dir=remote_dir,
                       device_name=connection_names.ue_pc.format(ue_id),
                       remove_source_file=True,
                       timeout=timeout
                       )

    def kill_all_qxdm_processes(self, ue_id=0):
        """
        Keyword for kill QXDM.exe process.

        :param ue_id:
            UE id - related to Test Line configuration - tl.ues.
        """
        self.kill_qxdm_process(ue_id=ue_id)
        self.kill_qxdm_server_process(ue_id=ue_id)

    def kill_qxdm_process(self, ue_id=0):
        """
        Keyword for kill QXDM.exe process.

        :param ue_id:
           UE id - related to Test Line configuration - tl.ues.
        """
        self._kill_ue_pc_process(
             process_name="QXDM.exe", ue_id=ue_id)

    def kill_qcat_process(self, ue_id=0):
        """
        Keyword for kill QCAT.exe process.

        :param ue_id:
          UE id - related to Test Line configuration - tl.ues.
        """
        self._kill_ue_pc_process(
             process_name="QCAT.exe", ue_id=ue_id)

    def kill_qxdm_server_process(self, ue_id=0):
        """
        Keyword for kill QPSTServer.exe process.

        :param ue_id:
           UE id - related to Test Line configuration - tl.ues.
        """
        self._kill_ue_pc_process(
            process_name="QPSTServer.exe", ue_id=ue_id)

    def kill_quts_process(self, ue_id=0):
        """
        Keyword for kill
          QUTSService.exe process.

        :param ue_id:
             UE id - related to Test Line configuration - tl.ues.
        """
        self._kill_ue_pc_process(process_name="QUTSService.exe", ue_id=ue_id)

    @load_moler_configuration_from_tl()
    def clear_log_directory(self, log_dir=None, ue_id=0):
        """
        Keyword for clear
         log directory on UE PC.

        :param ue_id:
            UE id - related to Test Line configuration - tl.ues.
        :param log_dir:
          log directory path to clear
        :return: None
        """
        if log_dir is None:
            log_dir = self.ue_pc_logs_dir
        ue_pc_device_name = connection_names.ue_pc.format(ue_id)
        ue_pc = DeviceFactory.get_device(name=ue_pc_device_name)
        rm = ue_pc.get_cmd(
            cmd_name="rm", cmd_params={
                'file': os.path.join(log_dir, "*"),
                'options': '-rf'})
        rm()

    @staticmethod
    def _get_scripts_dir_path():
        current_dir = os.path.dirname(os.path.abspath(__file__))
        config_dir = os.path.abspath(os.path.join(current_dir, 'scripts'))
        return config_dir

    @staticmethod
    def _convert_to_cygpath(dir_path):
        return dir_path.replace('c:', '/cygdrive/c')

    @staticmethod
    @load_moler_configuration_from_tl()
    def _execute_ue_pc_cmd(
            ue_id, cmd,
            timeout=60,
            error_regex=re.compile(
                "error",
                re.IGNORECASE),
            background=False):
        """
            Execute any Windows
             command on UEPC device.

            :param ue_id:
                  UE id - related to Test
                   Line configuration - tl.ues.
            :param cmd:
                  Command to execute
            :param timeout:
                 Command timeout
            :param error_regex:
              Regex for failure command
            :param background:
               True/False - run command in the background
            :return: None
            """
        ue_pc_device_name = connection_names.ue_pc.format(ue_id)
        ue_pc = DeviceFactory.get_device(name=ue_pc_device_name)
        time.sleep(0.5)
        _cmd = ue_pc.get_cmd(
            cmd_name="run_script",
            cmd_params={'script_command': cmd, 'error_regex': error_regex})
        if background:
            _cmd.start(timeout=timeout)
        else:
            _cmd(timeout=timeout)
            time.sleep(0.5)

    def _kill_ue_pc_process(self, process_name, ue_id=0):
        try:
            self._execute_ue_pc_cmd(
                ue_id=ue_id,
                cmd="taskkill /F /IM {}".format(process_name))
        except CommandFailure as error:
            if 'ERROR: The process "{}" not found.'\
                    .format(process_name) in repr(error):
                logging.debug("{} process not exists".format(process_name))
            else:
                raise error


class LicenseKeeperKeywords(object):
    def __init__(self, alias='lkc', login=None, password=None):
        self.alias = alias
        self.lkc = licence_keeper()
        self.login = login
        self.password = password

    def connect_to_license_keeper_client(
            self, login=None,
            password=None,
            lkc_path='/cygdrive/c/QPM_LK1.4',
            port=6006, ue_id=0):
        """
        Start client and log to the server.

        :param login:
           login to license keeper - eg. name.surname@nokia.com.
        :param password:
         password to license keeper
        :param lkc_path:
         path to license keeper client located on UEPC.
        :param port:
          license keeper client port.
        :param ue_id:
           UE id - related to Test Line configuration - tl.ues.
        """
        if login and password:
            self.login = login
            self.password = password
        elif (self.login is None or self.login is None) and \
                (login is None or password is None):
            credentials = \
                self._get_credentials_from_file(
                    file_path=os.path.join(lkc_path, 'credentials.yaml'),
                    ue_id=ue_id)
            self.login = credentials['user']
            self.password = credentials['password']

        host, username, ue_pc_password = get_ue_pc_credentials(ue_id)

        self.lkc.create_ssh_runner(
            host=host,
            username=username,
            password=ue_pc_password,
            alias=self.alias)
        if self.lkc.licence_keeper_client_is_running(alias=self.alias):
            self.lkc.stop_licence_keeper_client(alias=self.alias)
        self.lkc.start_licence_keeper_client(path=lkc_path, alias=self.alias)
        time.sleep(5)
        self.lkc.connect(host=host, port=port)
        self.lkc.login(username=self.login, password=self.password)

    def get_qxdm_and_qcat_licence(self):
        """
        Get 5G QXDM and QCAT License
        """
        self.lkc.get_licence_qxdm_5g()
        self.lkc.get_licence_qcat_5g()

    def release_qxdm_and_qcat_licence(self, ue_id=0):
        """
        Release QXDM and QCAT license.

        :param ue_id:
            UE id - related to Test Line configuration - tl.ues.
        """
        host, username, ue_pc_password = get_ue_pc_credentials(ue_id)

        self.lkc.create_ssh_runner(
            host=host,
            username=username,
            password=ue_pc_password,
            alias=self.alias)
        self._release_licence(
             release_method=self.lkc.release_licence_qxdm_5g)
        self._release_licence(
            release_method=self.lkc.release_licence_qcat_5g)
        self.lkc.disconnect()
        self.lkc.disconnect_ssh_runner(alias=self.alias)

    @staticmethod
    def _release_licence(release_method):
        try:
            release_method()
        except Exception as e:
            logging.warn("{}: {}".format(release_method.__name__, repr(e)))

    def kill_license_client_process(self, ue_id=0):
        """
        Kill license Client process on UEPC

        :param ue_id:
             UE id - related to Test Line configuration - tl.ues.
        """
        host, username, ue_pc_password = get_ue_pc_credentials(ue_id)

        self.lkc.create_ssh_runner(
            host=host,
            username=username,
            password=ue_pc_password,
            alias=self.alias)
        if self.lkc.licence_keeper_client_is_running(alias=self.alias):
            self.lkc.stop_licence_keeper_client(alias=self.alias)
        self.lkc.disconnect_ssh_runner(alias=self.alias)

    @staticmethod
    @load_moler_configuration_from_tl()
    def _get_credentials_from_file(
            file_path='/cygdrive/c/QPM_LK1.4/credentials.yaml', ue_id=0):
        """
        Read configuration file
         located on UEPC and return dict.

        :param ue_id:
             UE id - related to Test Line configuration - tl.ues.
        :param file_path:
          path to file with credentials located on UE_PC
        :return: credentials:
            dict

        credentials.yaml file should be in format as below:
        user: project_account@nokia.com
        password: GiveMeLicence
        """
        ue_pc_device_name = connection_names.ue_pc.format(ue_id)
        ue_pc = DeviceFactory.get_device(name=ue_pc_device_name)
        cat = ue_pc.get_cmd(cmd_name="cat", cmd_params={'path': file_path})
        file_content = cat()
        credentials = yaml.load(
            "\n".join(file_content['LINES']), Loader=yaml.FullLoader)
        return credentials
