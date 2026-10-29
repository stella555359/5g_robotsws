from taf.transport.ssh import ssh
from taf.sbts.oam.coam.admin import admin
from taf.gnb.oam.coam.cu import cu as cu_admin
from taf.gnb.oam.coam.vdu import Vdu as vdu_admin
from selenium.common.exceptions import WebDriverException
from taf.selenium.sbts import sbts
import re
import subprocess
import os
from contextlib import contextmanager


class AgentFailureEvidenceCollector():

    def __init__(self, installation_log_file=None, output_path='/tmp'):
        self.ap = Airphone(output_path)
        self.gnb = GNB(output_path)
        self.vran = VRAN(output_path)
        self.save_screenshot = SaveScreenshot(output_path)
        self.installation_log_file = installation_log_file

    def collect_symptoms(self):
        error = self.get_error_prefix()
        self.ap.collect_evidence(error)
        if self.is_IP_alive(self.vran.VCU_IP):
            self.vran.collect_evidence(error)
        else:
            self.gnb.collect_evidence(error)
            self.save_screenshot.login_to_gnb_and_capture_screenshot()
        return

    def is_IP_alive(self, ip_addr):
        if subprocess.call('ping -c 5 {} > /dev/null 2>&1'.format(ip_addr), shell=True) == 0:
            return True
        return False

    def is_execution_successful(self):
        with open(self.installation_log_file) as install_log:
            log_data = install_log.read()
            if 'EXECUTION SUCCESSFUL' in log_data:
                return True
        return False

    def get_installation_error(self):
        with open(self.installation_log_file) as install_log:
            log_data = install_log.read()
            install_error = re.findall(r'ERROR.*?(\w+):', log_data, re.MULTILINE)
            if install_error:
                return install_error[-1]
        return 'General'

    def get_error_prefix(self):
        if self.installation_log_file:
            error = self.get_installation_error()
        else:
            error = 'General'
        return error


class Airphone():
    AP_IP = '192.168.200.1'
    AP_ADET = 'export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -n {}'
    AP_GPS = ('/opt/hwmt/python/sendommessage.sh -s 0x04cb -d HWAGNSS-1/DEVICE-1/STATUS-1 --proto '
              'GNSS/status -t query')
    ASIK_DIAG_COMMAND = 'python3 /opt/airphone_irfhead/cgi-bin/diag.py --nocolor'
    UE_APP_OAM_COMMAND = 'cd /opt/UE_APP_OAM/target_test/;bash /opt/UE_APP_OAM/target_test/E2E_target.sh'

    ERROR_TO_COLLECTOR = {'RuStateError': 'collect_ru_state_evidence'}
    AP_CRASH_LOGS_PATH = '/ffs/run/logs'

    def __init__(self, output_path):
        self.ssh = ssh()
        self.output_path = output_path
        self.initialise_diag_command()

    def initialise_diag_command(self):
        with self.airphone_connection() as connection:
            if self.ssh.file_exists('/opt/airphone_irfhead/cgi-bin/diag.py', connection='AP'):
                self.diag_command = self.ASIK_DIAG_COMMAND
            else:
                self.diag_command = self.UE_APP_OAM_COMMAND
        return

    def collect_evidence(self, error):
        self.create_airphone_evidence_file(error)
        if self.is_airphone_reachable():
            self.evidence_file.write('Airphone Status : Reachable\n\n')
            self.collect_default_evidence()
            # we need to add condition for checking if its APoABIL or APoABIO
            # if error in self.ERROR_TO_COLLECTOR:
            #    symptom_collector = getattr(self, self.ERROR_TO_COLLECTOR[error])()
        else:
            self.evidence_file.write('=== Airphone is Not Up during Evidence Collection ===\n')
        self.close_evidence_file()
        return

    def create_airphone_evidence_file(self, error):
        evidence_file_path = os.path.join(self.output_path, '{}_Evidence_AP.txt'.format(error))
        self.evidence_file = open(evidence_file_path, 'w')
        return

    def close_evidence_file(self):
        self.evidence_file.close()
        return

    @contextmanager
    def airphone_connection(self):
        try:
            yield self.ssh.connect_to(self.AP_IP, 'toor4nsn', 'oZPS0POrRieRtu', alias='AP')
        finally:
            self.ssh.disconnect(connection='AP')

    def collect_default_evidence(self):
        self.log_airphone_datetime()
        self.log_uptime_airphone()
        self.log_airphone_reboot_info()
        self.l2rt_chk_lx_airphone()
        self.log_adet_airphone()
        self.log_gps_status_airphone()
        self.log_diag_output()
        self.log_airphone_crash_logs()
        return

    def write_airphone_command_output_to_evidence(self, command, command_header):
        self.evidence_file.write('==== {} ====\n'.format(command_header))
        self.evidence_file.write(self.ssh.execute(command, connection='AP').replace('\r\n', '\n'))
        self.evidence_file.write('========\n\n')
        return

    def collect_ru_state_evidence(self):
        self.collect_fpga_from_phoner()
        return

    def collect_fpga_from_phoner(self):
        self.evidence_file.write('===== Start FPGA Command Output From Phoner =====\n')
        self.execute_commands_in_abil_and_write_to_evidence('fpga_rw ra 0xdf201000', 'fpga_rw ra 0xdf201004',
                                                            'fpga_rw ra 0xdf201008', 'fpga_rw ra 0xdf20100C',
                                                            'fpga_rw ra 0xdf201020', 'fpga_rw ra 0xdf201024',
                                                            'fpga_rw ra 0xdf201028')
        self.evidence_file.write('===== End FPGA Command Output From Phoner =====\n')
        return

    def execute_commands_in_abil_and_write_to_evidence(self, *commands):
        with self.airphone_connection() as connection:
            for command in commands:
                self.evidence_file.write(command + '\n')
                command_output = self.ssh.execute('bsh 1:2 {} 2>/dev/null'.format(command),
                                                  connection='AP').replace('\r\n', '\n')
                self.evidence_file.write(command_output)
        return

    def is_airphone_reachable(self):
        if subprocess.call('ping -c 5 {} > /dev/null 2>&1'.format(self.AP_IP), shell=True) == 0:
            return True
        return False

    def log_uptime_airphone(self):
        with self.airphone_connection() as connection:
            self.write_airphone_command_output_to_evidence(command='uptime',
                                                           command_header='Uptime Of Airphone')
        return

    def l2rt_chk_lx_airphone(self):
        with self.airphone_connection() as connection:
            self.write_airphone_command_output_to_evidence(command='chk lx',
                                                           command_header='L2RT chk lx command Of Airphone')
        return

    def get_airphone_nodeid(self, connection):
        nodeid = self.ssh.execute("ownnid", connection='AP')
        nodeid = nodeid.strip()
        return nodeid

    def log_adet_airphone(self):
        with self.airphone_connection() as connection:
            ap_nodeid = self.get_airphone_nodeid(connection)
            self.write_airphone_command_output_to_evidence(command=self.AP_ADET.format(ap_nodeid),
                                                           command_header='Adet Of Airphone')
        return

    def log_airphone_datetime(self):
        with self.airphone_connection() as connection:
            self.write_airphone_command_output_to_evidence('date',
                                                           command_header='Date in Airphone')
        return

    def log_gps_status_airphone(self):
        with self.airphone_connection() as connection:
            self.write_airphone_command_output_to_evidence(self.AP_GPS,
                                                           command_header='GPS Status in Airphone')
        return

    def log_diag_output(self):
        with self.airphone_connection() as connection:
            command_header = 'Diag Output in Airphone'
            self.evidence_file.write('==== {} ====\n'.format(command_header))
            command_output = self.ssh.execute(self.diag_command, connection='AP').replace('\r\n', '\n')
            ascii_color_code_pattern = re.compile(r'\x1b\[\d+m')
            command_output = ascii_color_code_pattern.sub('', command_output)
            self.evidence_file.write(command_output)
            self.evidence_file.write('========\n\n')
        return

    def log_route_output(self):
        with self.airphone_connection() as connection:
            self.write_airphone_command_output_to_evidence('ip addr show',
                                                           command_header='IP Addr command')
            self.write_airphone_command_output_to_evidence('route -n',
                                                           command_header='Route Command')
        return

    def log_port_status(self):
        with self.airphone_connection() as connection:
            self.write_airphone_command_output_to_evidence('ethtool etha01.225',
                                                           command_header='Ethtool output')
            self.write_airphone_command_output_to_evidence('ifconfig etha01.225',
                                                           command_header='Ifconfig')
            self.write_airphone_command_output_to_evidence('dbgrrc phy status port 15',
                                                           command_header='Port status')
            self.write_airphone_command_output_to_evidence('dbgrrc show port 15',
                                                           command_header='Port Show')
            self.write_airphone_command_output_to_evidence('echo aasyscomkernelgw -r | nc 0 -w 60 15007',
                                                           command_header='Syscom Asik Master')
            self.write_airphone_command_output_to_evidence('bsh 0:1 "echo aasyscomkernelgw -r | nc\
                 0 -w 60 15007"',
                                                           command_header='Syscom Asik Slave')
            self.write_airphone_command_output_to_evidence('bsh 1:0 "echo aasyscomkernelgw -r | nc\
                 0 -w 60 15007"',
                                                           command_header='Syscom ABIL Master')
            self.write_airphone_command_output_to_evidence('bsh 1:1 "echo aasyscomkernelgw -r | nc\
                 0 -w 60 15007"',
                                                           command_header='Syscom Abil Slave')
        return

    def get_airphone_crash_logs(self, connection):
        command = r"find {} -type f \( -name '*0x*' -o -name '*core*' \)".format(self.AP_CRASH_LOGS_PATH)
        crash_logs_status = self.ssh.execute(command=command, connection=connection).replace('\r\n', '\n')
        return crash_logs_status

    def log_airphone_crash_logs(self):
        with self.airphone_connection() as connection:
            crash_logs_collected = self.get_airphone_crash_logs(connection)
            if crash_logs_collected:
                self.evidence_file.write('===== AP Crash Logs =====\n')
                self.evidence_file.write(crash_logs_collected)
                self.evidence_file.write('========\n\n')
        return

    def log_airphone_reboot_info(self):
        with self.airphone_connection() as connection:
            self.write_airphone_command_output_to_evidence(command='journalctl -b -1 -n',
                                                           command_header='journal reboot entries of AP')
            self.write_airphone_command_output_to_evidence(command='last -x reboot',
                                                           command_header='List reboot entries of AP')
            self.write_airphone_command_output_to_evidence(command='last -x shutdown',
                                                           command_header='List shutdown entries of AP')
            self.write_airphone_command_output_to_evidence(command='who -b',
                                                           command_header='time of last reboot of AP')
        return


class GNB():
    GNB_IP = '192.168.255.1'
    GNB_IP_4G5GCOMBO = '192.168.255.119'
    GNB_ADET = 'export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -n {}'
    GNB_CRASH_LOGS_PATH = '/ffs/run/logs'

    def __init__(self, output_path):
        self.ssh = ssh()
        self.admin = admin()
        self.output_path = output_path
        self.set_gNB_IP_of_system()

    def set_gNB_IP_of_system(self):
        if subprocess.call('ping -c 5 {} > /dev/null 2>&1'.format(self.GNB_IP_4G5GCOMBO), shell=True) == 0:
            self.GNB_IP = self.GNB_IP_4G5GCOMBO
        print('GNB_IP is : ', self.GNB_IP)
        return

    def collect_evidence(self, error):
        self.create_gnb_evidence_file(error)
        if self.is_gnb_reachable():
            self.evidence_file.write('GNB Status : Reachable\n\n')
            self.collect_default_evidence()
            if self.is_gnb_admin_connection():
                self.collect_admin_evidence()
                self.close_admin()
            else:
                self.evidence_file.write('Admin on GNB is down\n\n')
        else:
            self.evidence_file.write('=== GNB is Not Up during Evidence Collection ===\n')
        self.close_evidence_file()
        return

    def create_gnb_evidence_file(self, error):
        evidence_file_path = os.path.join(self.output_path, '{}_Evidence_GNB.txt'.format(error))
        self.evidence_file = open(evidence_file_path, 'w')
        return

    def close_evidence_file(self):
        self.evidence_file.close()
        return

    @contextmanager
    def gnb_connection(self):
        try:
            yield self.ssh.connect_to(self.GNB_IP, 'toor4nsn', 'oZPS0POrRieRtu', alias='GNB')
        finally:
            self.ssh.disconnect(connection='GNB')

    def collect_default_evidence(self):
        self.log_gnb_datetime()
        self.log_gnb_uptime()
        self.log_gnb_reboot_info()
        self.log_gnb_adet()
        self.log_gnb_crash_logs()
        return

    def write_gnb_command_output_to_evidence(self, command, command_header):
        self.evidence_file.write('==== {} ====\n'.format(command_header))
        self.evidence_file.write(self.ssh.execute(command, connection='GNB').replace('\r\n', '\n'))
        self.evidence_file.write('========\n\n')
        return

    def is_gnb_reachable(self):
        if subprocess.call('ping -c 5 {} > /dev/null 2>&1'.format(self.GNB_IP), shell=True) == 0:
            return True
        return False

    def is_gnb_admin_connection(self):
        try:
            self.admin.connect_to(bts_host=self.GNB_IP)
        except Exception as e:
            print('Exception hit while establishing Admin {}'.format(str(e)))
            return False
        return True

    def close_admin(self):
        try:
            self.admin.teardown()
        except Exception as e:
            print('Exception hit while tearing down Admin {}'.format(str(e)))
        return

    def collect_admin_evidence(self):
        self.log_gnb_state()
        self.log_gnb_ru_state()
        self.log_gnb_active_alarms()
        return

    def log_gnb_uptime(self):
        with self.gnb_connection() as connection:
            self.write_gnb_command_output_to_evidence(command='uptime',
                                                      command_header='Uptime Of GNB')
        return

    def log_gnb_reboot_info(self):
        with self.gnb_connection() as connection:
            self.write_gnb_command_output_to_evidence(command='journalctl -b -1 -n',
                                                      command_header='journal reboot entries of GNB')
            self.write_gnb_command_output_to_evidence(command='last -x reboot',
                                                      command_header='List reboot entries of GNB')
            self.write_gnb_command_output_to_evidence(command='last -x shutdown',
                                                      command_header='List shutdown entries of GNB')
            self.write_gnb_command_output_to_evidence(command='who -b',
                                                      command_header='time of last reboot of GNB')
        return

    def get_gnb_nodeid(self, connection):
        nodeid = self.ssh.execute("ownnid", connection='GNB')
        nodeid = nodeid.strip()
        return nodeid

    def log_gnb_adet(self):
        with self.gnb_connection() as connection:
            gnb_nodeid = self.get_gnb_nodeid(connection)
            self.write_gnb_command_output_to_evidence(command=self.GNB_ADET.format(gnb_nodeid),
                                                      command_header='Adet Of GNB')
        return

    def log_gnb_datetime(self):
        with self.gnb_connection() as connection:
            self.write_gnb_command_output_to_evidence('date',
                                                      command_header='Date in GNB')
        return

    def log_gnb_state(self):
        self.evidence_file.write('==== {} ====\n'.format('GNB MRBTS State'))
        self.evidence_file.write(self.admin.get_mrbts_state())
        self.evidence_file.write('\n')
        self.evidence_file.write('========\n\n')
        return

    def log_gnb_ru_state(self):
        rmod = self.admin.get_bts_info()['radioModules']['rmod']
        self.evidence_file.write('==== {} ====\n'.format('GNB RU State'))
        self.evidence_file.write(rmod[0]['status']['operationalState'])
        self.evidence_file.write('\n')
        self.evidence_file.write('========\n\n')
        return

    def log_gnb_active_alarms(self):
        alarms = self.admin.get_active_alarms()
        self.evidence_file.write('==== {} ====\n'.format('GNB Active Alarms'))
        for alarm in alarms:
            alarm_id = str(alarm['alarmId'])
            self.evidence_file.write(",".join([alarm_id, alarm['faultName']]))
            self.evidence_file.write('\n')
        self.evidence_file.write('========\n\n')
        return

    def get_gnb_crash_logs(self, connection):
        command = r"find {} -type f \( -name '*0x*' -o -name '*core*' \)".format(self.GNB_CRASH_LOGS_PATH)
        crash_logs_status = self.ssh.execute(command=command, connection=connection).replace('\r\n', '\n')
        return crash_logs_status

    def log_gnb_crash_logs(self):
        with self.gnb_connection() as connection:
            crash_logs_collected = self.get_gnb_crash_logs(connection)
            if crash_logs_collected:
                self.evidence_file.write('===== GNB Crash Logs =====\n')
                self.evidence_file.write(crash_logs_collected)
                self.evidence_file.write('========\n\n')
        return

    def log_port_status(self):
        with self.gnb_connection() as connection:
            self.write_gnb_command_output_to_evidence('ethtool etha01.225',
                                                      command_header='Ethtool output')
            self.write_gnb_command_output_to_evidence('ifconfig etha01.225',
                                                      command_header='Ifconfig')
            self.write_gnb_command_output_to_evidence('dbgrrc phy status port 15',
                                                      command_header='Port status')
            self.write_gnb_command_output_to_evidence('dbgrrc show port 15',
                                                      command_header='Port Show')
            self.write_gnb_command_output_to_evidence('echo aasyscomkernelgw -r | nc 0 -w 60 15007',
                                                      command_header='Syscom Asik Master')
            self.write_gnb_command_output_to_evidence('bsh 0:1 "echo aasyscomkernelgw -r | nc\
                 -w 60 0 15007"',
                                                      command_header='Syscom ASIK Slave')
            self.write_gnb_command_output_to_evidence('bsh 1:0 "echo aasyscomkernelgw -r | nc\
                 -w 60 0 15007"',
                                                      command_header='Syscom ABIL Master')
            self.write_gnb_command_output_to_evidence('bsh 1:1 "echo aasyscomkernelgw -r | nc\
                 -w 60 0 15007"',
                                                      command_header='Syscom ABIL Slave')
        return


class VRAN():
    VDU_IP = '192.168.255.129'
    VCU_IP = '192.168.100.129'
    VDU_SSH_IP = '192.168.2.124'

    def __init__(self, output_path):
        self.ssh = ssh()
        self.cu_admin = cu_admin()
        self.vdu_admin = vdu_admin()
        self.output_path = output_path

    def collect_evidence(self, error):
        self.create_gnb_evidence_file(error)
        if self.is_vDU_reachable():
            self.evidence_file.write('VDU Status : Reachable\n\n')
            self.collect_default_evidence()
        else:
            self.evidence_file.write('=== VDU is Not Up during Evidence Collection ===\n')
        if self.is_vdu_admin_connection():
            try:
                self.collect_du_admin_evidence()
            finally:
                self.close_vdu_admin()
        else:
            self.evidence_file.write('Admin on VDU is down\n\n')
        if self.is_cu_admin_connection():
            try:
                self.collect_cu_admin_evidence()
            finally:
                self.close_cu_admin()
        else:
            self.evidence_file.write('Admin on CU is down\n\n')
        self.close_evidence_file()
        return

    def create_gnb_evidence_file(self, error):
        evidence_file_path = os.path.join(self.output_path, '{}_Evidence_GNB.txt'.format(error))
        self.evidence_file = open(evidence_file_path, 'w')
        return

    def close_evidence_file(self):
        self.evidence_file.close()
        return

    @contextmanager
    def vdu_connection(self):
        try:
            yield self.ssh.connect_to(self.VDU_SSH_IP, 'core', 'system123', alias='VDU')
        finally:
            self.ssh.disconnect(connection='VDU')

    def collect_default_evidence(self):
        self.log_vdu_datetime()
        self.log_vdu_uptime()
        self.log_vdu_reboot_info()
        return

    def write_vdu_command_output_to_evidence(self, command, command_header):
        self.evidence_file.write('==== {} ====\n'.format(command_header))
        if command == 'journalctl -b -1 -n':
            self.ssh.send_command(command, connection='VDU')
            output = self.ssh.read_output(connection='VDU')
            self.evidence_file.write(str(output).replace('\r\n', '\n'))
        else:
            self.evidence_file.write(self.ssh.execute(command, connection='VDU').replace('\r\n', '\n'))
        self.evidence_file.write('========\n\n')
        return

    def is_vDU_reachable(self):
        if subprocess.call('ping -c 5 {} > /dev/null 2>&1'.format(self.VDU_SSH_IP), shell=True) == 0:
            return True
        return False

    def is_cu_admin_connection(self):
        try:
            self.cu_admin.connect_to(host=self.VCU_IP, port=443, username='Nemuadmin',
                                     password='nemuuser', secure=True)
        except Exception as e:
            print('Exception hit while establishing Admin {}'.format(str(e)))
            return False
        return True

    def is_vdu_admin_connection(self):
        try:
            self.vdu_admin.connect_to(host=self.VDU_IP, port=443, username='Nemuadmin',
                                      password='nemuuser', secure=True)
        except Exception as e:
            print('Exception hit while establishing Admin {}'.format(str(e)))
            return False
        return True

    def close_cu_admin(self):
        try:
            self.cu_admin.disconnect()
        except Exception as e:
            print('Exception hit while tearing down Admin {}'.format(str(e)))
        return

    def close_vdu_admin(self):
        try:
            self.vdu_admin.disconnect()
        except Exception as e:
            print('Exception hit while tearing down Admin {}'.format(str(e)))
        return

    def collect_du_admin_evidence(self):
        self.log_vdu_state()
        self.log_vdu_ru_state()
        self.log_vdu_active_alarms()
        return

    def collect_cu_admin_evidence(self):
        self.log_cu_state()
        self.log_cu_vnf_state()
        self.log_cu_active_alarms()

    def log_vdu_datetime(self):
        with self.vdu_connection() as connection:
            self.write_vdu_command_output_to_evidence('date',
                                                      command_header='Date in VDU')
        return

    def log_vdu_uptime(self):
        with self.vdu_connection() as connection:
            self.write_vdu_command_output_to_evidence(command='uptime',
                                                      command_header='Uptime Of VDU')
        return

    def log_vdu_reboot_info(self):
        with self.vdu_connection() as connection:
            self.write_vdu_command_output_to_evidence(command='journalctl -b -1 -n',
                                                      command_header='journal reboot entries of AP')
            self.write_vdu_command_output_to_evidence(command='last -x reboot',
                                                      command_header='List reboot entries of VDU')
            self.write_vdu_command_output_to_evidence(command='last -x shutdown',
                                                      command_header='List shutdown entries of VDU')
            self.write_vdu_command_output_to_evidence(command='who -b',
                                                      command_header='time of last reboot of VDU')
        return

    def log_vdu_state(self):
        vdu_data = self.vdu_admin.get_vdu_state_data()
        self.evidence_file.write('==== {} ====\n'.format('VDU MRBTS State'))
        self.evidence_file.write(vdu_data['operational_state'])
        self.evidence_file.write('\n')
        self.evidence_file.write('========\n\n')
        return

    def log_vdu_ru_state(self):
        rmod = self.vdu_admin.get_rmods_status()
        self.evidence_file.write('==== {} ====\n'.format('VDU RU State'))
        self.evidence_file.write(rmod[0]['operational_state'])
        self.evidence_file.write('\n')
        self.evidence_file.write('========\n\n')
        return

    def log_vdu_active_alarms(self):
        vdu_alarms_dict = self.vdu_admin.vdu_get_active_alarms()
        vdu_alarms = vdu_alarms_dict["alarms"]
        self.evidence_file.write('==== {} ====\n'.format('VDU Active Alarms'))
        for alarm in vdu_alarms:
            alarm_id = str(alarm['alarm_id'])
            self.evidence_file.write(",".join([alarm_id, alarm['fault_name']]))
            self.evidence_file.write('\n')
        self.evidence_file.write('========\n\n')
        return

    def log_cu_state(self):
        cu_state = self.cu_admin.get_cu_state()
        self.evidence_file.write('==== {} ====\n'.format('CU State'))
        self.evidence_file.write(cu_state['operational_state'])
        self.evidence_file.write('\n')
        self.evidence_file.write('========\n\n')
        return

    def log_cu_vnf_state(self):
        state = self.cu_admin.get_cu_vnf()
        self.evidence_file.write('==== {} ====\n'.format('CU VNFCS State'))
        self.evidence_file.write(state.get('activity_mode'))
        self.evidence_file.write('\n')
        self.evidence_file.write('========\n\n')
        return

    def log_cu_active_alarms(self):
        vcu_alarms_dict = self.cu_admin.get_active_alarms()
        vcu_alarms = vcu_alarms_dict["alarms"]
        self.evidence_file.write('==== {} ====\n'.format('CU Active Alarms'))
        for alarm in vcu_alarms:
            alarm_id = str(alarm['alarm_id'])
            self.evidence_file.write(",".join([alarm_id, alarm['fault_name']]))
            self.evidence_file.write('\n')
        self.evidence_file.write('========\n\n')
        return


class SaveScreenshot():
    def __init__(self, output_path="/tmp/"):
        self.output_path = output_path
        self.sbts_obj = sbts()
        self.gNB_url = "https://192.168.255.1/#/login"
        self.username = "Nemuadmin"
        self.password = "nemuuser"
        self.site_view_screenshot = "site_view_screenshot"
        self.alarm_page_screenshot = "alarm_page_screenshot"
        self.detail_site_view_screenshot = "detail_site_view_screenshot"

    def login_to_gnb_and_capture_screenshot(self):
        try:
            self.sbts_obj.enable_virtual_display()
            self.sbts_obj.login(url=self.gNB_url, username=self.username, password=self.password)
            self.get_site_view_screenshot()
            self.get_alarm_page_screenshot()
            self.get_detailed_site_view_screenshot()
        except WebDriverException as e:
            self.sbts_obj.disable_virtual_display()
            print("GUI screenshot collection failed:", e)
        except Exception as e:
            self.sbts_obj.close_browser()
            self.sbts_obj.disable_virtual_display()
            print("GUI screenshot collection failed:", e)
        finally:
            self.sbts_obj.logout()
            self.sbts_obj.close_browser()
            self.sbts_obj.disable_virtual_display()

    def get_detailed_site_view_screenshot(self):
        self.sbts_obj.get_gnss_info(type_='GNSSE', gnss_index=1, sbts=None)
        self.sbts_obj.save_screenshot(self.detail_site_view_screenshot, screenshot_dir=self.output_path)

    def get_alarm_page_screenshot(self):
        self.sbts_obj.get_active_alarm_info(alarm_filter=None, timeout=10, sbts=None)
        self.sbts_obj.save_screenshot(self.alarm_page_screenshot, screenshot_dir=self.output_path)

    def get_site_view_screenshot(self):
        self.sbts_obj.save_screenshot(self.site_view_screenshot, screenshot_dir=self.output_path)


if __name__ == "__main__":
    import argparse
    import sys
    parser = argparse.ArgumentParser(description='Script to Collect Evident Post Agent Installation')
    parser.add_argument('--installation_log_file', required=False, default=None, help='Installation log File')
    parser.add_argument('--output_path', required=False, default='/tmp',
                        help='Output Path to store the report')
    args = parser.parse_args()
    try:
        AgentFailureEvidenceCollector(args.installation_log_file, args.output_path).collect_symptoms()
    except Exception as e:
        print(str(e))
    sys.exit(0)
