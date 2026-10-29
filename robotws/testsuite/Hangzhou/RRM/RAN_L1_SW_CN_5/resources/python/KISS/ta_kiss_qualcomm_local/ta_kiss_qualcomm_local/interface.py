# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
from .qualcomm_sw_control import QualcommSwControl
from .adb_control import AdbControl


class ta_kiss_qualcomm_local(object):
    """
    | Qualcomm control PC install way:
    |
    | 1. Install or copy six, ute_common_store and ute_core to python\\Lib\\site-packages
    |
    | 2. Download adb.exe and related dlls then add to environment variables, self check 'adb devices' can work
    |
    | 3. Download pywin32-xxx-pyxxx.exe from https://github.com/mhammond/pywin32/releases to install
    |
    | 4. Install ta_kiss_qualcomm_local, download psexec.exe put into site-packages\\ta_kiss_qualcomm_local\\,
    |    double click psexec.exe and choose "Agree"
    |
    | 5. Self check 'python -c "import ta_kiss_qualcomm_local"' normal will back up prompt
    |
    | 6. Install iperf on UE with 'adb install iperf.apk'
    |
    | 7. Create C:\\tmp\\Qualcomm folder
    |
    | 8. Make sure QXDM.QXDM5AutoApplication should be found from
    |    Computer\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Classes\\ in Registry Editor
    """

    def __init__(self):
        self.adb_control = AdbControl()
        self.qualcomm_sw_control = QualcommSwControl()

    def attach_with_adb(self, device_id):
        """ Attach

        :param device_id: device id
        :return:
        """
        return self.adb_control.attach(device_id)

    def exec_adb_cmd(self, device_id, cmd):
        """ Exec cmd

        :param device_id: device id
        :param cmd: cmd
        :return:
        """
        self.adb_control.exec_cmd(device_id, cmd)

    def get_ip_with_adb(self, device_id):
        """ Get ip

        :param device_id: device id
        :return:
        """
        return self.adb_control.get_ip(device_id)

    def start_iperf_server_on_ue(self, device_id, port, iperf_path, log_path, extra_cmd):
        """ Start iperf server on ue side

        :param device_id: ue device_id, get from (adb devices) command
        :param port: iperf port
        :param iperf_path: iperf install path on ue
        :param log_path: iperf log store path
        :param extra_cmd:
        :return:
        """
        self.adb_control.start_iperf_server(device_id, port, iperf_path, log_path, extra_cmd)

    def stop_iperf_server_on_ue(self, device_id, port):
        """ Stop iperf server on ue side

        :param device_id: ue device_id, get from (adb devices) command
        :param port: iperf port
        :return:
        """
        self.adb_control.stop_iperf_server(device_id, port)

    def start_iperf_client_on_ue(self, device_id, port, pc_ip, iperf_path, extra_cmd):
        """ Qualcomm start iperf client on ue side

        :param device_id: ue device_id, get from (adb devices) command
        :param port: iperf port, sync with start iperf server
        :param pc_ip: pc ip
        :param iperf_path: iperf path
        :param extra_cmd:
        :return:
        """
        self.adb_control.start_iperf_client(device_id, port, pc_ip, iperf_path, extra_cmd)

    def stop_iperf_client_on_ue(self, device_id, port):
        """ Qualcomm stop iperf client on ue side

        :param device_id: ue device_id, get from (adb devices) command
        :param port: iperf port
        :return:
        """
        self.adb_control.stop_iperf_client(device_id, port)

    def detach_with_adb(self, device_id):
        """ Detach

        :param device_id: ue device_id, get from (adb devices) command
        :return:
        """
        self.adb_control.detach(device_id)

    def start_qxdm_trace(self, device_id, dmc_file):
        """ Start qxdm trace

        :param device_id: ue device_id, get from (adb devices) command
        :return:"""
        self.qualcomm_sw_control.qxdm_connect_to_device(device_id, dmc_file)

    def stop_qxdm_trace(self, device_id, save_path, quit_app):
        """ Stop qxdm trace

        :param device_id: ue device_id, get from (adb devices) command
        :param save_path: trace file store path, such as: C:\\tmp\\Qualcomm\\
        :param quit_app: quit qxdm app or not, default is to quit qxdm app.
                         If there are more than 1 qualcomm_stop_qxdm_trace, set True at the last stop, others set False
        :return: The full path of stored file without filename suffix,
                 such as: C:\\tmp\\Qualcomm\\95fe0e6e_qxdmlog_2021-04-28_14-53-01"""
        return self.qualcomm_sw_control.qxdm_save_trace(device_id, save_path, quit_app)

    def get_field_value(self, field_name, trace_file, index, timeout):
        """ Get field value

        :param field_name: Field name
        :param trace_file: trace file store path, such as: C:\\xxx\\xxx.hdf
        :param index: the index times field_name appear, default 1 mean the first time field_name appear in trace_file
        :return: field value"""
        return self.qualcomm_sw_control.get_field_value(field_name, trace_file, index, timeout)

    def export_to_txt(self, input_file, output_path, filter):
        """ Export to txt with qcat

        :param input_file: input file to export, such as: C:\\xxx\\xxx.hdf
        :param output_path: output file path, such as: C:\\xxx
        :param filter: set filter then export, default is; LTE;Time Grids;Physical Grid;LTE Serving Cell Meas vs. Time
        :return:
        """
        return self.qualcomm_sw_control.qcat_export_txt(input_file, output_path, filter)

    def get_software_version(self, device_id):
        """ Get software version

        :param device_id: get from (adb devices) command
        :return:
        """
        return self.adb_control.get_sw_version(device_id)

    def get_physical_cell_id(self, device_id):
        """ Get physical cell id

        :param device_id: get from (adb devices) command
        :return:
        """
        return self.adb_control.get_physical_cell_id(device_id)

    def read_nvitem(self, device_id, item_name_or_id, subscription_id, index):
        """ Read nv item

        :param device_id: get from (adb devices) command
        :param item_name_or_id: item name or id, e.g. ‘/nv/item_files/modem/mmode/nr_nsa_band_pref’, '65633'
        :param subscription_id: subscription id, default is -1
        :param index:
        :return:
        """
        return self.qualcomm_sw_control.read_nvitem(device_id, item_name_or_id, subscription_id, index)

    def write_nvitem(self, device_id, item_name_or_id, value_list, subscription_id):
        """ Write nv item

        :param device_id: get from (adb devices) command
        :param item_name_or_id: item name or id, e.g. ‘/nv/item_files/modem/mmode/nr_nsa_band_pref’, '65633'
        :param value_list: value list, e.g. “0,0,0,0,0,0,0”
        :param subscription_id: subscription id, default is -1
        :return:
        """
        self.qualcomm_sw_control.write_nvitem(device_id, item_name_or_id, value_list, subscription_id)

    def set_apn(self, device_id, name, apn, mcc, mnc):
        """ Set apn

        :param device_id: get from (adb devices) command
        :param name: apn name
        :param apn: apn, such as:123.nsn.com
        :param mcc: mcc, default is 262
        :param mnc: mnc, default is 03
        :return: True or False
        """
        return self.adb_control.set_apn(device_id, name, apn, mcc, mnc)

    def send_qxdm_command(self, device_id, cmd):
        """ Send qxdm command

        :param device_id: get from (adb devices) command
        :param cmd: command
        :return:
        """
        self.qualcomm_sw_control.qxdm_send_cmd(device_id, cmd)
