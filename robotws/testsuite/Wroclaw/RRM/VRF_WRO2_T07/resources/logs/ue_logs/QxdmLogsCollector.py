import re
import os
import time
import logging
from moler.exceptions import CommandFailure
from taf.transport.ssh import ssh
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections import connect_to_uepc
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals

_ssh = ssh()


class QxdmLogsCollector(object):
    def __init__(self, script_name='QxdmCommand.py', ue_pc_dir_path='c:/auto/'):
        self.script_name = script_name
        self.ue_pc_dir_path = ue_pc_dir_path
        self.ue_pc_logs_dir = os.path.join(self.ue_pc_dir_path, 'logs')
        self.script_path = os.path.join(self.ue_pc_dir_path, self.script_name)
        self._hdf_log_file = None
        self._txt_log_file = None

    def upload_qxdmlogcatch_script(self, ue_id=0):
        """
        Upload script to UE PC.
        The script allows to collect QXDM logs and save them to *.hdf format.
        :param ue_id: ID of UE
        :return: None
        """
        _ssh.upload_file(local_path=self._get_scripts_dir_path(),
                         remote_path=self._convert_to_cygpath(self.ue_pc_dir_path),
                         connection=connect_to_uepc())

    def collect_and_save_qxdm_hdf_log(self, log_file=None, ue_id=0, duration=60, dmc_file=None, com_port=None,
                                      python_path=None, mode='start'):
        """
        Keyword for start collecting QXDM hdf log in the background.

        :param ue_id:               UE id - related to Test Line configuration - tl.ues.
        :type dmc_file:             path to dmc configuration file
        :param com_port:            UE COM port number eg: 9, or for QXDM5 could be 'MDM'
        :type log_file:             path to log
        :param duration:            duration of collecting log
        :type python_path:          path to python eg: ''C:/Python27/python.exe''
        :param mode:                start or stop collecting logs
        :return: None
        Sample Android configuration from __init__.py
        _android_ue = Android(
            ssh_connection_details=_ue_pc_ssh,
            serial_number="7d586bb0",
            server_dir="/cygdrive/c/pyro_server",
            python_path="C:/Python27/python.exe",
            qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
            diag_cfg_path="C:/pyro_server/DIAG.cfg",
            dmc_path="c:/usb/Config-4G-5G-SDx55-RFP_v0.4.dmc",
            diag_com="COM20",
            iperf_details=_android_iperf,
            capabilities=["REAL_ANDROID_UE"],
        )
        """
        if not log_file:
            log_file = os.path.join(self.ue_pc_logs_dir, 'qxdm.hdf')
        if not python_path:
            python_path = tl.ues[ue_id].python_path
        if not com_port:
            com_port = tl.ues[ue_id].diag_com
        if not dmc_file:
            dmc_file = tl.ues[ue_id].dmc_path

        self._hdf_log_file = log_file

        cmd = ''
        if mode == 'start':
            cmd = '{} "{}" -t {} -p "{}" -c "{}" -s "{}"'.format(python_path, self.script_path, duration,
                                                                 com_port, dmc_file, self._hdf_log_file)
        elif mode == 'stop':
            cmd = '{} "{}" -t {} -p "{}" -c "{}" -s "{}" -x'.format(python_path, self.script_path, duration,
                                                                    com_port, dmc_file, self._hdf_log_file)

        self._execute_ue_pc_cmd(ue_id=ue_id, cmd=cmd, timeout=int(duration) + 20, background=True)

    def convert_hdf_log_to_txt(self, hdf_log=None, ue_id=0, qcat_path=None, timeout=120):
        """
        Keyword for converting hdf log to txt format.

        :param ue_id:           UE id - related to Test Line configuration - tl.ues
        :param hdf_log:         path to hdf log
        :param qcat_path:       path to QCAT.exe eg: ''C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe''
        :param timeout:         timeout for converting isf --> txt
        """
        if not qcat_path:
            qcat_path = tl.ues[ue_id].qcat_path
        if not hdf_log:
            hdf_log = self._hdf_log_file

        self._txt_log_file = hdf_log.replace('.hdf', '.txt')

        cmd = '"{}" -txt "{}"'.format(qcat_path, hdf_log)
        try:
            self._execute_ue_pc_cmd(ue_id=ue_id, cmd=cmd, timeout=timeout)
        except CommandFailure as e:
            if r'The remote server returned an error: (404) Not Found' not in repr(e):
                raise e

        return self._txt_log_file

    def download_qxdm_logs(self, download_dir=None, log_file=None, ue_id=0, timeout=60):
        """
        Download all logs from UE_PC to local PC.

        :param download_dir: path to directory where file will be downloaded. If not passed Robot
                             output dir will be used.
        :param log_file:     path to logs located on UE_PC - could pass many separated by comma
        :param ue_id:        UE id - related to Test Line configuration - tl.ues.
        :param timeout:      timeout for downloading file
        """

        if download_dir is None:
            download_dir = robot_globals.outputdir()

        if log_file is None:
            log_file = ",".join([os.path.basename(self._hdf_log_file), os.path.basename(self._txt_log_file)])
            remote_dir = os.path.dirname(self._hdf_log_file)
        else:
            files = log_file.split(',')
            remote_dir = os.path.dirname(files[0])

        _ssh.download_file(local_path=download_dir,
                           remote_path=os.path.join(remote_dir, log_file),
                           connection=connect_to_uepc())

    def kill_all_qxdm_processes(self, ue_id=0):
        """
        Keyword for kill QXDM.exe process.

        :param ue_id:           UE id - related to Test Line configuration - tl.ues.
        """
        self.kill_qxdm_process(ue_id=ue_id)
        self.kill_qxdm_server_process(ue_id=ue_id)

    def kill_qxdm_process(self, ue_id=0):
        """
        Keyword for kill QXDM.exe process.

        :param ue_id:           UE id - related to Test Line configuration - tl.ues.
        """
        self._kill_ue_pc_process(process_name='QXDM.exe', ue_id=ue_id)

    def kill_qcat_process(self, ue_id=0):
        """
        Keyword for kill QCAT.exe process.

        :param ue_id:           UE id - related to Test Line configuration - tl.ues.
        """
        self._kill_ue_pc_process(process_name='QCAT.exe', ue_id=ue_id)

    def kill_qxdm_server_process(self, ue_id=0):
        """
        Keyword for kill QPSTServer.exe process.

        :param ue_id:           UE id - related to Test Line configuration - tl.ues.
        """
        self._kill_ue_pc_process(process_name='QPSTServer.exe', ue_id=ue_id)

    def kill_quts_process(self, ue_id=0):
        """
        Keyword for kill QUTSService.exe process.

        :param ue_id:           UE id - related to Test Line configuration - tl.ues.
        """
        self._kill_ue_pc_process(process_name='QUTSService.exe', ue_id=ue_id)

    def clear_log_directory(self, log_dir=None, ue_id=0):
        """
        Keyword for clear log directory on UE PC.

        :param ue_id:       UE id - related to Test Line configuration - tl.ues.
        :param log_dir:     log directory path to clear
        :return: None
        """
        if log_dir is None:
            log_dir = self.ue_pc_logs_dir

        _ssh.execute(command='rm -rf {}'.format(os.path.join(log_dir, '*')), connection=connect_to_uepc(ue_id=ue_id))

    @staticmethod
    def _get_scripts_dir_path():
        current_dir = os.path.dirname(os.path.abspath(__file__))
        config_dir = os.path.abspath(os.path.join(current_dir, 'scripts'))
        return config_dir

    @staticmethod
    def _convert_to_cygpath(dir_path):
        return dir_path.replace('c:', '/cygdrive/c')

    @staticmethod
    def _execute_ue_pc_cmd(ue_id, cmd, timeout=60, background=False):
        """
            Execute any Windows command on UEPC device.

            :param ue_id:           UE id - related to Test Line configuration - tl.ues.
            :param cmd:             Command to execute
            :param timeout:         Command timeout
            :param background:      True/False - run command in the background
            :return: None
            """

        if background:
            _ssh.send_command(command=cmd, connection=connect_to_uepc(ue_id=ue_id), timeout=timeout)
        else:
            _ssh.execute(command=cmd, connection=connect_to_uepc(), timeout=timeout)
            time.sleep(0.5)

    def _kill_ue_pc_process(self, process_name, ue_id=0):
        try:
            self._execute_ue_pc_cmd(ue_id=ue_id, cmd='taskkill /F /IM {}'.format(process_name))
        except CommandFailure as error:
            if 'ERROR: The process "{}" not found.'.format(process_name) in repr(error):
                logging.debug("{} process not exists".format(process_name))
            else:
                raise error
