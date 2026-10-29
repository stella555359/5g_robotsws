# -*- coding: utf-8 -*-
"""
:created on: 25-04-2021

:copyright: Nokia
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""

from ute_common_store import Store
from .qualcomm_ue import QualcommUe


class tak_qualcomm(object):
    """
    | Qualcomm control PC install way:
    |
    | 1. Install or copy six, ute_common_store and ute_core to python\\Lib\\site-packages
    |
    | 2. Download adb.exe and related dlls then add to environment variables, self check 'adb devices' can work
    |
    | 3. Download pywin32-xxx-pyxxx.exe from https://github.com/mhammond/pywin32/releases to install
    |
    | 4. Copy tak_qualcomm_local\tak_qualcomm_local to qualcomm_control pc->site-packages, download psexec.exe
    |    put into site-packages\\tak_qualcomm_local\\, double click psexec.exe and choose "Agree"
    |
    | 5. Self check 'python -c "import tak_qualcomm_local"' normal will back up prompt
    |
    | 6. Install iperf on UE with 'adb install iperf.apk'
    |
    | 7. Create C:\\tmp\\Qualcomm folder
    |
    | 8. Make sure QXDM.QXDM5AutoApplication should be found from
    |    Computer\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Classes\\ in Registry Editor
    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.store = Store()

    def qualcomm_setup(self, domain='noklab\\', config_file=None, reboot=True, alias='default'):
        """Setup qualcomm, this keyword must be called before any other keyword in this library

        :param domain: ue pc domain name, default is noklab\\, some ue pc domain name need noklab\\\\
        :param config_file: config file, default is None, read from UE_CONFIG
        :param reboot: reboot PSEXESVC.exe or not if psexec failed to start python, default is to reboot PSEXESVC.exe
        :param alias: Name of execution context
        """
        qualcomm_ue_control = QualcommUe()
        self.store.add(qualcomm_ue_control, alias)
        self.store.get(alias).setup(domain, reboot, config_file)

    def qualcomm_attach_with_adb(self, device_id, alias='default'):
        """Qualcomm attach ue, use adb command

        :param device_id: get from (adb devices) command
        :param alias: Name of execution context
        :return:
        """
        return self.store.get(alias).attach_with_adb(device_id)

    def qualcomm_execute_adb_cmd(self, device_id, cmd, alias='default'):
        """Qualcomm execute adb cmd

        :param device_id: get from (adb devices) command
        :param cmd: command content
        :param alias: Name of execution context
        :return:
        """
        return self.store.get(alias).exec_adb_cmd(device_id, cmd)

    def qualcomm_get_ip_with_adb(self, device_id, alias='default'):
        """Qualcomm get ue ip, use adb command

        :param device_id: get from (adb devices) command
        :param alias: Name of execution context
        :return:
        """
        return self.store.get(alias).get_ip_with_adb(device_id)

    def qualcomm_detach_with_adb(self, device_id, alias='default'):
        """Qualcomm detach ue, use adb command

        :param device_id: get from (adb devices) command
        :param alias: Name of execution context
        :return:
        """
        self.store.get(alias).detach_with_adb(device_id)

    def qualcomm_start_iperf_server_on_ue(self, device_id, port,
                                          iperf_path='/data/data/com.magicandroidapps.iperf/bin/iperf',
                                          log_path='/tmp/iperf_server_on_ue_log.txt',
                                          extra_cmd='-u -i 1 -P 0 -f m -l 2400B -w 41.0K',
                                          alias='default'):
        """Qualcomm start iperf server on ue side

        :param device_id: ue device_id, get from (adb devices) command
        :param port: iperf port
        :param iperf_path: iperf install path on ue
        :param log_path: iperf log store path
        :param extra_cmd:
        :param alias: Name of execution context
        :return:
        """
        self.store.get(alias).start_iperf_server_on_ue(device_id, port, iperf_path, log_path, extra_cmd)

    def qualcomm_start_iperf_server_on_pc(self, port, log_path='/tmp/iperf_server_on_pc_log.txt',
                                          extra_cmd='-u -i 1 -P 0 -f m -l 2400B -w 41.0K',
                                          alias='default'):
        """Qualcomm start iperf server on iperf pc side

        :param port: iperf port
        :param log_path: iperf log store path
        :param extra_cmd:
        :param alias: Name of execution context
        :return:
        """
        self.store.get(alias).start_iperf_server_on_pc(port, log_path, extra_cmd)

    def qualcomm_stop_iperf_server_on_ue(self, device_id, port, alias='default'):
        """Qualcomm stop iperf server on ue side

        :param device_id: ue device_id, get from (adb devices) command
        :param port: iperf port
        :param alias: Name of execution context
        :return:
        """
        self.store.get(alias).stop_iperf_server_on_ue(device_id, port)

    def qualcomm_stop_iperf_server_on_pc(self, port, alias='default'):
        """Qualcomm stop iperf server on iperf pc side

        :param port: iperf port
        :param alias: Name of execution context
        :return:
        """
        self.store.get(alias).stop_iperf_server_on_pc(port)

    def qualcomm_start_iperf_client_on_pc(self, port, ue_ip,
                                          extra_cmd='-u -t 3600 -i 1 -P 1 -f m -b 740.00M -l 2400B -T 64',
                                          iperfpc_ip=None,
                                          iperfpc_username=None,
                                          iperfpc_pwd=None,
                                          alias='default'):
        """Qualcomm start iperf client on iperf pc side

        :param port: iperf port, sync with start iperf server
        :param ue_ip: ue ip
        :param extra_cmd:
        :param iperfpc_ip:
        :param iperfpc_username:
        :param iperfpc_pwd:
        :param alias: Name of execution context
        :return:
        """
        self.store.get(alias).start_iperf_client_on_pc(port, ue_ip, extra_cmd, iperfpc_ip, iperfpc_username,
                                                       iperfpc_pwd)

    def qualcomm_start_iperf_client_on_ue(self, device_id, port,
                                          iperf_path='/data/data/com.magicandroidapps.iperf/bin/iperf',
                                          extra_cmd='-u -t 3600 -i 1 -P 1 -f m -b 740.00M -l 2400B -T 64',
                                          alias='default'):
        """Qualcomm start iperf client on ue side

        :param device_id: ue device_id, get from (adb devices) command
        :param port: iperf port, sync with start iperf server
        :param extra_cmd:
        :param alias: Name of execution context
        :return:
        """
        self.store.get(alias).start_iperf_client_on_ue(device_id, port, iperf_path, extra_cmd)

    def qualcomm_stop_iperf_client_on_pc(self, port, iperfpc_ip=None, iperfpc_username=None, iperfpc_pwd=None,
                                         alias='default'):
        """Qualcomm stop iperf client on iperf pc side

        :param port: iperf port
        :param iperfpc_ip:
        :param iperfpc_username:
        :param iperfpc_pwd:
        :param alias: Name of execution context
        :return:
        """
        self.store.get(alias).stop_iperf_client_on_pc(port, iperfpc_ip, iperfpc_username, iperfpc_pwd)

    def qualcomm_stop_iperf_client_on_ue(self, device_id, port, alias='default'):
        """Qualcomm stop iperf client on ue side

        :param device_id: ue device_id, get from (adb devices) command
        :param port: iperf port
        :param alias: Name of execution context
        :return:
        """
        self.store.get(alias).stop_iperf_client_on_ue(device_id, port)

    def qualcomm_get_throughput(self, server='ue', log_path='/tmp/iperf_server_on_ue_log.txt', alias='default'):
        """Qualcomm get throughput

        :param server: iperf server is ue or iperf_pc
        :param log_path: iperf log store path, the same with start_iperf_server_on_xx
        :param alias: Name of execution context
        :return:
        """
        return self.store.get(alias).get_throughput(server, log_path)

    def qualcomm_start_qxdm_trace(self, device_id, dmc_file=None, alias='default'):
        """Qualcomm start qxdm trace

        :param device_id: ue device_id, get from (adb devices) command
        :param dmc_file: support use specific dmc file, such as:/home/ute/robotws/testsuite/Hangzhou/RRM/
                        RAN_L2_SW_CN_3/CB007922/config/qualcomm_config/NR5G_Debugging_TP.dmc
        :param alias: Name of execution context
        :return:
        """
        return self.store.get(alias).start_qxdm_trace(device_id, dmc_file)

    def qualcomm_stop_qxdm_trace(self, device_id, save_path, quit_app=True, alias='default'):
        """Qualcomm stop qxdm trace

        :param device_id: ue device_id, get from (adb devices) command
        :param save_path: trace file store path, such as: C:\\tmp\\Qualcomm\\
        :param quit_app: quit qxdm app or not, default is to quit qxdm app.
                         If there are more than 1 qualcomm_stop_qxdm_trace, set True at the last stop, others set False
        :param alias: Name of execution context
        :return: The full path of stored file without filename suffix,
                 such as: C:\\tmp\\Qualcomm\\95fe0e6e_qxdmlog_2021-04-28_14-53-01
        """
        return self.store.get(alias).stop_qxdm_trace(device_id, save_path, quit_app)

    def qualcomm_get_field_value(self, field_name, trace_file, index=1, timeout=5, alias='default'):
        """Qualcomm get field value

        :param field_name: Field name
        :param trace_file: trace file store path, such as: C:\\xxx\\xxx.hdf
        :param index: the index times field_name appear, default 1 mean the first time field_name appear in trace_file
        :param alias: Name of execution context
        :return: field value
        """
        return self.store.get(alias).get_field_value(field_name, trace_file, index, timeout)

    def qualcomm_export_to_txt_with_qcat(self, input_file, output_path,
                                         filter=';LTE;Time Grids;Physical Grid;LTE Serving Cell Meas vs. Time',
                                         alias='default'):
        """Qualcomm export to txt with qcat

        :param input_file: input file to export, such as: C:\\xxx\\xxx.hdf
        :param output_path: output file path, such as: C:\\xxx
        :param filter: set filter then export, default is; LTE;Time Grids;Physical Grid;LTE Serving Cell Meas vs. Time
                       if give None, it will export entire txt
        :param alias: Name of execution context
        :return:
        """
        return self.store.get(alias).export_to_txt(input_file, output_path, filter)

    def qualcomm_get_software_version(self, device_id, alias='default'):
        """Qualcomm get software version

        :param device_id: get from (adb devices) command
        :param alias: Name of execution context
        :return:
        """
        return self.store.get(alias).get_software_version(device_id)

    def qualcomm_get_physical_cell_id(self, device_id, alias='default'):
        """Qualcomm get physical cell id

        :param device_id: get from (adb devices) command
        :param alias: Name of execution context
        :return:
        """
        return self.store.get(alias).get_physical_cell_id(device_id)

    def qualcomm_read_nvitem(self, device_id, item_name_or_id, subscription_id=-1, index=1, alias='default'):
        """Qualcomm read nv item

        :param device_id: get from (adb devices) command
        :param item_name_or_id: item name or id, e.g. /nv/item_files/modem/mmode/nr_nsa_band_pref, 65633
        :param subscription_id: subscription id, default is -1
        :param index: read which line, if read the second line index=2, default is 1 means read the first line
        :param alias:
        :return:
        """
        return self.store.get(alias).read_nvitem(device_id, item_name_or_id, subscription_id, index)

    def qualcomm_write_nvitem(self, device_id, item_name_or_id, value_list, subscription_id=-1, alias='default'):
        """Qualcomm write nv item

        :param device_id: get from (adb devices) command
        :param item_name_or_id: item name or id, e.g. /nv/item_files/modem/mmode/nr_nsa_band_pref or 65633
        :param value_list: value list, e.g. 0,8192 (the first line keep 0, write 8192 to the second line);
                                       e.g. 64 (write 64 to the first line)
        :param subscription_id: subscription id, default is -1
        :param alias:
        :return:
        """
        self.store.get(alias).write_nvitem(device_id, item_name_or_id, value_list, subscription_id)

    def qualcomm_set_apn(self, device_id, name, apn, mcc='262', mnc='03', alias='default'):
        """ Set apn

        :param device_id: get from (adb devices) command
        :param name: apn name
        :param apn: apn, such as:123.nsn.com
        :param mcc: mcc, default is 262
        :param mnc: mnc, default is 03
        :param alias:
        :return: True or False
        """
        return self.store.get(alias).set_apn(device_id, name, apn, mcc, mnc)

    def qualcomm_send_qxdm_command(self, device_id, cmd, alias='default'):
        """ Send qxdm command

        :param device_id: get from (adb devices) command
        :param cmd: command
        :param alias:
        :return:
        """
        return self.store.get(alias).send_qxdm_command(device_id, cmd)

    def qualcomm_teardown(self, alias='default'):
        """Qualcomm teardown, need to be called at the end of test

        :param alias: Name of execution context
        :return:
        """
        self.store.get(alias).teardown()
        self.store.remove(alias)
