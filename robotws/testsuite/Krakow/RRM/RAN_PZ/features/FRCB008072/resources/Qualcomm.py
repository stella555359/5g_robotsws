from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
import paramiko
import time


class Qualcomm:

    def __init__(self, ue_id=0, ue_type='sdx60', ssh_port=22):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.uepc_ipaddr = tl.ues[ue_id].ssh_connection_details.addr
        self.uepc_username = tl.ues[ue_id].ssh_connection_details.username
        self.uepc_password = tl.ues[ue_id].ssh_connection_details.password
        self.ue_serial = tl.ues[ue_id].serial_number
        self.ue_type = ue_type
        self.ssh_port = ssh_port
        self.paramiko_client = None
        self.supported_ues = ['sdx60']

    def _connect_paramiko(self):
        self.paramiko_client = paramiko.SSHClient()
        self.paramiko_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.paramiko_client.connect(self.uepc_ipaddr, self.ssh_port, self.uepc_username, self.uepc_password)

    def _disconnect_paramiko(self):
        self.paramiko_client.close()

    @MolerTest.raise_background_exceptions()
    def switch_apn(self, apn_name):
        self._connect_paramiko()
        apn_index = None
        supported_apn = ['5gkrk', '5gsakrk']
        if apn_name == supported_apn[0]:
            apn_index = 0
        elif apn_name == supported_apn[1]:
            apn_index = 1
        else:
            MolerTest.error('APN {} is not supported.\n'
                            'Supported APNs: {}'.format(apn_name, [apn for apn in supported_apn]),
                            raise_exception=True)
        apn_position = 800 + apn_index * 200

        cmd_raw = "adb -s {} shell 'input keyevent 26;sleep 1;input keyevent 82;sleep 1;" \
                  "am force-stop com.android.settings;sleep 1;am start -a android.settings.DATA_ROAMING_SETTINGS;" \
                  "sleep 3;input swipe 500 2000 300 300;sleep 5;input tap 500 1900;sleep 2;input tap 950 {};sleep 2;" \
                  "am force-stop com.android.settings;sleep 2;input keyevent 26'"

        if self.ue_type == 'sdx60':
            cmd_apn = cmd_raw.format(self.ue_serial, apn_position)
        else:
            cmd_apn = None
            MolerTest.error('UE type {} is not supported.'
                            '\nSupported UEs: {}'.format(self.ue_type, [ue for ue in self.supported_ues]))

        self.paramiko_client.exec_command(cmd_apn)
        time.sleep(30)  # Wait until cmd execution finishes
        self._disconnect_paramiko()

    def switch_airplane_mode(self):
        self._connect_paramiko()
        cmd_raw = "adb -s {} shell 'input keyevent 26;sleep 1;input keyevent 82;sleep 1;{}" \
                  "am force-stop com.android.settings;sleep 1;am start -a android.settings.AIRPLANE_MODE_SETTINGS;" \
                  "sleep 5;input tap 900 1250;sleep 5;input tap 900 1250;sleep 5;" \
                  "am force-stop com.android.settings;sleep 2;input keyevent 26'"

        if self.ue_type == 'sdx60':
            cmd_airplane_mode = cmd_raw.format(self.ue_serial, '')
        else:
            cmd_airplane_mode = None
            MolerTest.error('UE type {} is not supported.'
                            '\nSupported UEs: {}'.format(self.ue_type, [ue for ue in self.supported_ues]))

        self.paramiko_client.exec_command(cmd_airplane_mode)
        time.sleep(30)  # Wait until cmd execution finishes
        self._disconnect_paramiko()

    def enter_home_button(self):
        self._connect_paramiko()
        cmd_home = "adb -s {} shell 'input keyevent 3;sleep 2;input keyevent 26'".format(self.ue_serial)
        self.paramiko_client.exec_command(cmd_home)
        time.sleep(20)  # Wait until cmd execution finishes
        self._disconnect_paramiko()

    @MolerTest.raise_background_exceptions()
    def switch_preferred_network_type(self, network_type):
        self._connect_paramiko()
        supported_types = ['NR_only', 'NR_LTE']
        cmd_network_type = None
        position_index = None
        if network_type == supported_types[0]:
            position_index = 600
        elif network_type == supported_types[1]:
            position_index = 750
        else:
            MolerTest.error('Given network type: {} not supported. Supported network types: {}'.format(
                network_type, [n_type for n_type in supported_types], raise_exception=True))

        cmd_raw = "adb -s {} shell 'input keyevent 26;sleep 1;input keyevent 82;sleep 1;{}" \
                  "am force-stop com.android.settings;sleep 1;am start -a android.settings.DATA_ROAMING_SETTINGS;" \
                  "sleep 2;input swipe 400 1900 200 200;sleep 5;input tap 500 500;sleep 3;" \
                  "input swipe 400 1900 200 200;sleep 5;input tap 180 {};sleep 3;am force-stop com.android.settings;" \
                  "sleep 2;input keyevent 26'"

        if self.ue_type == 'sdx60':
            cmd_network_type = cmd_raw.format(self.ue_serial, '', str(position_index))
        else:
            MolerTest.error('UE type {} is not supported.'
                            '\nSupported UEs: {}'.format(self.ue_type, 'sdx60'))

        self.paramiko_client.exec_command(cmd_network_type)
        time.sleep(40)  # Wait until cmd execution finishes
        self._disconnect_paramiko()
