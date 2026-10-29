# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import time
import re
import json
import logging
from pprint import pprint
from lxml import etree
from typing import Union, Literal
from types import SimpleNamespace
from robot.utils.robottime import timestr_to_secs

try:
    from uepc import WinPC, LinuxPC
    from ultracaller import UltraCallerServer
except Exception:
    from .uepc import WinPC, LinuxPC
    from .ultracaller import UltraCallerServer


def load_config():
    def read_file(fname):
        if os.path.exists(fname):
            try:
                return json.load(open(fname))
            except Exception as e:
                raise Exception(f'Failed to load file {fname}, {e}')
        else:
            return {}
    # path = os.sep.join(os.path.dirname(os.path.abspath(__file__)).split(os.sep)[:-2]) + '/config/commercial_ue'
    path = os.path.dirname(os.path.abspath(__file__)) + '/config'
    config = {}
    config['uc servers'] = read_file(path + '/ultracaller.json')
    config['models'] = read_file(path + '/models.json')
    config['control pcs'] = {}
    for fname in [x for x in os.listdir(path) if x.startswith('cpc_') and x.endswith('.json')]:
        pcinfo = read_file(path + '/' + fname)
        config['control pcs'][pcinfo['hostname']] = pcinfo
    return config


class AndroidUE(object):

    def __init__(self, serialno: str, logger: logging.Logger = None) -> None:
        self.serialno = serialno
        self.logger = logger or logging.getLogger(__file__)
        self.load_config()
        self.cpc: Union[WinPC, LinuxPC] = None
        self._ucs = None
        self._running_tests = {}
        self.debug = False
        self._started_test = []

    def load_config(self) -> None:
        config = load_config()
        self.all_config = config
        for pcip in config.get('control pcs', {}):
            pcinfo = config['control pcs'][pcip]
            if self.serialno in pcinfo['ues']:
                self.config = pcinfo['ues'][self.serialno]
                self.pcconfig = pcinfo
                self.modleconfig = config['models'].get(self.config['model'], {})
                self.config['config_app'] = self.modleconfig.get('config_app', 'com.android.settings')
                self.config['config_activity'] = self.modleconfig.get('config_app', 'com.android.settings/.Settings')
                self.config['airplan_app'] = self.modleconfig.get('airplan_activity',
                                                                  'android.settings.AIRPLANE_MODE_SETTINGS')
                self._imei = self.config.get('imei', '')
                self.logger.info(f'module config: {str(self.modleconfig)}')
                return
        raise Exception(f'Could not find UE {self.serialno} in config json file, please check it.')

    def __str__(self) -> None:
        return f'PC: {self.pcconfig["hostname"]},  Serialno: {self.serialno}'

    def __repr__(self) -> None:
        return self.__str__()

    @property
    def imei(self) -> str:
        if self._imei:
            return self._imei
        else:
            self.logger.info('Search IMEI from Ultracaller')
            p = self.ucs.search_ue_by_serialno(self.serialno)['data']
            if p:
                self._imei = p[0]['imei']
            else:
                self.logger.info('Search IMEI from Ultracaller, failed, try adb')
                self._imei = self._get_imei_adb()
        return self._imei

    @property
    def ucs(self) -> UltraCallerServer:
        if self._ucs is None:
            uc_server = self.config.get('uc server', '') or '10.69.69.234'
            self._ucs = UltraCallerServer(host=uc_server,
                                          token=self.all_config['uc servers'][uc_server]['token'],
                                          logger=self.logger)
            self._prepare_ucs()
        return self._ucs

    def log(self, msg: str) -> None:
        self.logger.info('*****  {}:  {}'.format(self, msg))

    def setup(self) -> None:
        self.log('Setup')
        self.cpc.setup()
        if self.cpc.os == 'windows':
            # 对windows的平台的adb，查看是否是server模式启动，如果不是，杀掉adb，然后以server模式启动；
            lines = self.cpc.exec_command('wmic process get caption,commandline /value|findstr adb').splitlines()
            lines = [x for x in lines if x.strip() and 'fork-server' in x]
            if lines:
                self.log('CPC ADB is in server mode')
            else:
                self.log('!!! CPC ADB is not in server mode')
                self.cpc.exec_command('taskkill /f /im adb.exe')
                self.cpc.start_application('adb', 'start-server')
        self.cpc.exec_command('adb devices -l')
        self.disable_rotation()

    def is_available(self) -> bool:
        lines = self.cpc.exec_command('adb devices -l')
        serialnos = [x.split()[0].strip() for x in lines.splitlines() if x.strip() and 'device ' in x]
        return self.serialno in serialnos

    def teardown(self) -> None:
        if self.cpc:
            self.cpc.teardown()

    def exec_adb_command(self, command: str) -> str:
        cmd = 'adb -s {} {}'.format(self.serialno, command)
        self.log('ADB CMD: [{}]'.format(cmd))
        return self.cpc.exec_command(cmd)

    def exec_adb_shell_command(self, command: str, log: bool = True) -> str:
        cmd = 'adb -s {} shell {}'.format(self.serialno, command)
        self.log('ADB Shell CMD: [{}]'.format(cmd))
        return self.cpc.exec_command(cmd, log=log)

    def _attached(self) -> bool:
        self.log('**** Check if UE is attached')
        output = self.exec_adb_shell_command('settings get global airplane_mode_on')
        output = [x for x in output.splitlines() if x.strip()]
        if output:
            return output[0][0].strip() != '1'
        else:
            self.log('**** Could not get the air plane mode.')

    def is_screen_on(self) -> bool:
        output = self.exec_adb_shell_command('"dumpsys window policy|grep interactiveState"')
        return 'interactiveState=INTERACTIVE_STATE_AWAKE' in output

    def blink_screen(self) -> None:
        if not self.is_screen_on():
            self.log('**** Screen is off, I will turn it on')
            self.exec_adb_shell_command('input keyevent 26')
        else:
            self.log('**** Screen is On')

    def turn_off_screen(self) -> None:
        if self.is_screen_on():
            self.log('**** Screen is on, I will turn it off')
            self.exec_adb_shell_command('input keyevent 26')
        else:
            self.log('**** Screen is off')

    def is_screen_locked(self) -> bool:
        response = self.exec_adb_shell_command('"dumpsys window|grep mShowing"')
        return 'mDreamingLockscreen=true' in response

    def unlock_screen(self) -> None:
        if self.is_screen_locked():
            self.log('**** Screen is locked, need unlock screen...')
            width, height = self.get_screen_size()
            botton_center_x = int(width) / 2
            botton_center_y = int(height) - 300
            self.exec_adb_shell_command('input swipe {} {} {} 0 1200'.format(
                botton_center_x, botton_center_y, botton_center_x))
        else:
            self.log('**** Screen is unlocked')

    def get_screen_size(self) -> tuple:
        output = self.exec_adb_shell_command('wm size')
        if 'Override' in output:
            output = [x for x in output.splitlines() if 'Override' in x]
        else:
            output = [x for x in output.splitlines() if 'size:' in x]
        if output:
            return output[0].split()[-1].split('x')[0], output[0].split()[-1].split('x')[1]
        else:
            raise Exception('failed to get screen size.')

    def wakeup(self) -> None:
        self.blink_screen()
        self.unlock_screen()

    def wait_until_airplan(self, timeout: int = 10, airplan: bool = True) -> None:
        for _ in range(timeout):
            if airplan:
                if self._attached():
                    return True
                else:
                    time.sleep(1)
            else:
                if not self._attached():
                    return True
                else:
                    time.sleep(1)
        return False

    def enable_airplan(self, points: list = None) -> None:
        self.log('Enable air plane')
        if self._attached():
            self.log('Already in air plane')
        else:
            self._enter_config_app()
            self._touch_points(points)
            self.wait_until_airplan(airplan=True)
            if not self._attached():
                raise Exception('Enable air plane failed')
            else:
                self.log('Enable airplane done.')
            self.exec_adb_shell_command('input keyevent 4')
            self.kill_setting()
        self.launch_naa()

    def disable_airplan(self, points: list = None) -> None:
        self.log('Disable air plane')
        if not self._attached():
            self.log('Already not in air plane')
            return 0

        self._enter_config_app()
        self._touch_points(points)
        self.wait_until_airplan(airplan=False)
        if self._attached():
            raise Exception('Disable air plane failed')
        else:
            self.log('Disable airplane done.')
        self.launch_naa()

    def reboot(self, timeout: str = '60s') -> None:
        ntimeout = timestr_to_secs(str(timeout))
        self.exec_adb_command('reboot')
        st = time.time()
        while True:
            if time.time() - st > ntimeout:
                raise Exception(f'Reboot timeout, could not find ue in {timeout}')
            if self.is_available():
                break
            time.sleep(3)

    def _enter_config_app(self) -> None:
        self.wakeup()
        # self.exec_adb_shell_command('am start -a android.settings.AIRPLANE_MODE_SETTINGS --activity-clear-task')
        self.kill_setting()
        self.launch_app(self.config["config_activity"])

    def launch_setting(self) -> None:
        self.wakeup()
        self._enter_config_app()

    def _kill_package(self, package) -> None:
        self.exec_adb_shell_command('am force-stop {}'.format(package))

    def kill_ultracaller(self) -> None:
        self._kill_package('com.nokia.ultracall')

    def kill_setting(self) -> None:
        return self._kill_package(self.config["config_activity"])

    def launch_app(self, activity):
        return self.exec_adb_shell_command('am start -n {}'.format(activity))

    def launch_ultracaller(self):
        return self.launch_app('com.nokia.ultracall/.UCActivity')

    def launch_naa(self):
        return self.launch_app('com.nokia.android.application/.NaaActivity')

    def launch_config_app(self):
        if self.package_is_running(self.config_app):
            self.kill_setting()
        self.launch_app(self.config_activity)

    def package_is_running(self, package):
        output = self.exec_adb_shell_command('ps|grep {}'.format(package))
        if package in output:
            return True
        else:
            output = self.exec_adb_shell_command('ps -A|grep ultra')
            return package in output

    def _filter_ip_addr(self, lines):
        ip_addr = re.findall(r'addr:([\d]{1,3}[.][\d]{1,3}[.][\d]{1,3}[.][\d]{1,3})', lines)
        ip_addr = [x for x in ip_addr if '127.0.0.1' not in x and '0.0.0.0' not in x]
        if ip_addr:
            return ip_addr[0].strip()
        else:
            return ''

    def _get_ip_by_ifconfig(self):
        lines = self.exec_adb_shell_command('ifconfig|grep Mask')
        return self._filter_ip_addr(lines)

    def _get_ip_by_netcfg(self):
        lines = self.exec_adb_shell_command('netcfg|grep UP')
        return self._filter_ip_addr(lines)

    def _get_ip_by_address(self, intf_name=''):
        lines = self.exec_adb_shell_command('"ip address show|grep inet"').splitlines()
        if intf_name:
            lines = [x for x in lines if intf_name in x]
        lines = '\n'.join(lines)
        ip_addr = re.findall(r'([\d]{1,3}[.][\d]{1,3}[.][\d]{1,3}[.][\d]{1,3})', lines)
        ip_addr = [x for x in ip_addr if '127.0.0.1' not in x and '0.0.0.0' not in x]
        if ip_addr:
            return ip_addr[0].strip()
        else:
            return ''

    def get_ueip(self, work_mode: Literal['adb', 'naa'] = 'adb', intf_name: str = '') -> str:
        self.log(f'**** Get UE IP, work_mode: {work_mode}')
        ipaddr = ''
        if work_mode not in ['adb', 'naa']:
            raise ValueError("work_mode must be 'adb' or 'naa'")
        if work_mode == 'adb':
            ipaddr = self._get_ip_by_address(intf_name)
        if work_mode == 'naa':
            ipaddr = self._get_naa_signal_info().get('ipv4addr', '')

        if ipaddr:
            self.log('**** Found UE ipaddr: {}'.format(ipaddr))
            return ipaddr
        else:
            self.log('**** Could not found UE ipaddr')
            raise Exception('Failed to get UE IP')

    def _try_ui_dump(self) -> None:
        for _ in range(20):
            output = self.exec_adb_shell_command('/system/bin/uiautomator dump')
            if 'window_dump.xml' in output:
                break

    def _click_text(self, text: str) -> bool:
        self.exec_adb_shell_command('rm -rf /sdcard/window_dump.xml')
        self._try_ui_dump()
        output = self.exec_adb_shell_command('cat /sdcard/window_dump.xml', log=False)
        # with open('a.xml', 'w', encoding='utf-8') as f:
        #     f.write(output)
        tree = etree.fromstring(output.encode())
        node = tree.xpath(f'//node[@text="{text}"]/following::*[2]')
        # node = [x for x in nodes if x.get('text') == text]
        if node:
            self.log('Found text {}, node: {}'.format(text, node[0].get('bounds')))
            node = node[0]
            if node is not None:
                x1, y1, x2, y2 = re.findall(r'[\d]+', node.get('bounds'))
                cx = int((int(x1) + int(x2)) / 2)
                cy = int((int(y1) + int(y2)) / 2)
                self.exec_adb_shell_command('input tap {} {}'.format(cx, cy))
                return True
        else:
            self.log('could not found node for text {} '.format(text))
            return False

    def _click_ui_node(self, resourceid: str = '', text: str = '') -> bool:
        self.exec_adb_shell_command('rm -rf /sdcard/window_dump.xml')
        self._try_ui_dump()
        output = self.exec_adb_shell_command('cat /sdcard/window_dump.xml', log=False)

        tree = etree.fromstring(output.encode())
        if resourceid:
            nodes = tree.xpath(f'//node[@resource-id="{resourceid}"]')
        elif text:
            nodes = tree.xpath(f'//node[@text="{text}"]')
        else:
            nodes = []
        if nodes:
            node = nodes[0]
            if node is not None:
                x1, y1, x2, y2 = re.findall(r'[\d]+', node.get('bounds'))
                cx = int((int(x1) + int(x2)) / 2)
                cy = int((int(y1) + int(y2)) / 2)
                self.exec_adb_shell_command('input tap {} {}'.format(cx, cy))
                return True
        else:
            self.log('Could not find the required node')
            return False

    def _touch_points(self, points: str = '') -> None:
        def _point_is_xy(point):
            return len(re.findall(r'([\d]+)[\s\,]+([\d]+)', point.strip())) > 0

        for tap_position in points.split(';'):
            if tap_position.strip():
                if _point_is_xy(tap_position):
                    x, y = tap_position.strip().split(',')
                    self.exec_adb_shell_command('input tap {} {}'.format(x, y))
                elif tap_position.lower() == 'scroll_up':
                    self.scroll_up()
                elif tap_position.lower() == 'scroll_down':
                    self.scroll_down()
                else:
                    self._click_text(tap_position.strip())

    def click(self, points: str = '') -> None:
        self._touch_points(points)

    def attach(self, forced: bool = False, expected_pci: str = '', expected_cellid: str = '',) -> None:
        self.log('**** Attach...')
        attached = self._attached()
        if attached:
            self.log('**** Already attached')
            if forced:
                self.detach()
                time.sleep(5)
                self.exec_adb_shell_command(f'am start -a {self.config["airplan_app"]}')
                self._touch_points(self.modleconfig.get('attach_point', '飞行模式'))
                time.sleep(10)
                self.log('**** Attach done')
        else:
            self.log('**** Has not attached')
            self.wakeup()
            self.exec_adb_shell_command(f'am start -a {self.config["airplan_app"]}')
            self._touch_points(self.modleconfig.get('attach_point', '飞行模式'))
            time.sleep(10)
        if expected_pci or expected_cellid:
            self.log('**** Check Expected PCI/CellID')
            # info = self._get_naa_signal_info()
            self.ucs.stop_all(self.imei)
            info = self.ucs.get_ue_info(self.imei)['data'][0]['location']['signalInfo']
            if expected_pci and str(info['Pci']) != str(expected_pci):
                raise Exception(f'PCI is not expected, expect {expected_pci}, but got {info["Pci"]}')
            if expected_cellid and str(info['CID']) != str(expected_cellid):
                raise Exception(f'CellID is not expected, expect {expected_cellid}, but got {info["CID"]}')
            self.log('**** Check Expected PCI/CellID done.')

    def detach(self) -> None:
        self.log('**** Detach ... ')
        self.wakeup()
        self.exec_adb_shell_command(f'am start -a {self.config["airplan_app"]}')
        self._touch_points(self.modleconfig.get('attach_point', '飞行模式'))
        self.log('**** Detach done')

    def _launch_magic_iperf(self) -> None:
        self.launch_app('com.nextdoordeveloper.miperf.miperf/.MainActivity')

    def _kill_magic_iperf(self) -> None:
        self._kill_package('com.nextdoordeveloper.miperf.miperf')

    def _clear_magic_iperf_inputbox(self) -> None:
        for _ in range(5):
            self.exec_adb_shell_command('input keyevent KEYCODE_MOVE_END {}'.format(
                'KEYCODE_DEL ' * 25))

    def _reload_miperf(self) -> None:
        self.wakeup()
        self._kill_magic_iperf()
        self._launch_magic_iperf()

    def _input_long_text(self, text: str) -> None:
        for word in text.split():
            for c in word:
                self.exec_adb_shell_command('input text ' + c)
            self.exec_adb_shell_command('input text ' + r'%s')

    def _start_iperf_with_magic_iperf(self, **kwargs) -> None:
        iperf_option = kwargs.get('option', '')
        start_point = kwargs.get('point')
        self._reload_miperf()
        self.exec_adb_shell_command('input tap 770 550')
        self._clear_magic_iperf_inputbox()
        self._input_long_text(iperf_option)
        if start_point:
            self._touch_points(start_point)

    def _stop_iperf_with_magic_iperf(self, **kwargs) -> None:
        point = kwargs.get('point', '')
        if point:
            self._touch_points(point)

    def _make_call(self, dial_number: str = '') -> None:
        self.wakeup()
        self.exec_adb_shell_command('am start -a android.intent.action.CALL -d tel:{}'.format(
            dial_number.strip()))

    def _cancel_call(self, timeout='30s') -> None:
        if self.is_calling():
            self.exec_adb_shell_command('input keyevent KEYCODE_ENDCALL')
            ntimeout = timestr_to_secs(str(timeout))
            st = time.time()
            while True:
                if time.time() - st > ntimeout:
                    raise Exception(f'Cancel call timeout, could not cancel call in {timeout}')
                if not self.is_calling():
                    break
                time.sleep(3)

    def start_call(self, dial_number: str, timeout: str = '30s') -> None:
        self.log('*** Make call')
        self._cancel_call()
        self._make_call(dial_number)
        ntimeout = timestr_to_secs(str(timeout))
        st = time.time()
        self.log('*** Check is in call')
        while True:
            if time.time() - st > ntimeout:
                raise Exception(f'Make call timeout, could not make call in {timeout}')
            if self.is_calling():
                break
            time.sleep(3)
        self.log('*** Make call done')

    def stop_call(self) -> None:
        self.log('*** Stop call')
        self._cancel_call()
        self.log('*** Stop call done')

    def start_uc_test_or_sequence(self, test_name: str = '', sequence_name: str = '') -> dict:
        if test_name:
            self.log(f'Start UC Test {test_name}')
            testid = self.ucs.start_test(self.imei, test_name)
            self.log(f'Wait until UC Test {test_name} done')
            self.ucs.wait_until_test_started(testid)
            self.log(f'UC Test {test_name} done')
            return testid
        if sequence_name:
            self.log(f'Start UC Sequence {sequence_name}')
            seqid = self.ucs.start_test_sequence(self.imei, sequence_name)
            self.log(f'Wait until Sequence {sequence_name} done')
            self.ucs.wait_until_sequence_started(seqid)
            self.log(f'UC Sequence {test_name} done')

    def stop_uc_test_or_sequence(self, test_name: str = '', sequence_name: str = '') -> dict:
        if test_name:
            running = self.ucs.get_running_test(self.imei)
            running = [x for x in running if x['name'].lower() == test_name.lower()]
            if running:
                testId = running[0]['testId']
                self.log(f'Stop UC Test {sequence_name}')
                self.ucs.stop_test(self.imei, testId)
                self.log(f'Wait Test {test_name} stop done')
                self.ucs.wait_until_test_stopped(testId)
                self.log(f'Test {test_name} stop done')

        if sequence_name:
            running = self.ucs.get_running_sequence(self.imei)
            running = [x for x in running if x['name'] == sequence_name]
            if running:
                seqid = running[0]['testSequenceId']
                self.log(f'Stop UC Sequence {sequence_name}')
                self.ucs.stop_test_sequence(self.imei, seqid)
                self.log(f'Wait Sequence {sequence_name} stop done')
                self.ucs.wait_until_sequence_stoped(seqid)
                self.log(f'Sequence {sequence_name} stop done')

    def stop_uc_all(self):
        self.log('Stop All test/sequence')
        self.ucs.stop_all(self.imei)
        self.log('Wait for stop All test/sequence done')
        self.ucs.wait_until_all_stoped(self.imei)
        self.log('Stop All test/sequence done')

    def kill_naa(self):
        return self._kill_package('com.nokia.android.application')

    def start_naa_iperf_cli(self, **kwargs):
        self.exec_adb_command('root')
        time.sleep(5)
        option = kwargs.get('option')
        iperf_path = '/data/data/com.nokia.android.application/'

        cmd = 'psexec -u {cpc.username_p} -p {cpc.password} -i {cpc.rdp_session_id} -d cmd /c ' \
              'adb -s {ue.serialno} shell "cd {iperf_path}; ./iperf {option} 2>&1'.format(
                  cpc=self.cpc,
                  ue=self,
                  iperf_path=iperf_path,
                  option=option)
        self.cpc.exec_command(cmd)

    def stop_naa_iperf_cli(self, **kwargs):
        self.exec_adb_shell_command('pkill iperf')

    def is_calling(self):
        cmd = 'dumpsys telephony.registry |findstr mCallState=2'
        output = self.exec_adb_shell_command(cmd).splitlines()
        output = [x.strip() for x in output if x.strip()]
        return bool(output)

    def stop_iperf_listen_on(self, port, use_iperf3=True):
        if use_iperf3:
            cmd = f"ps -ef|grep iperf3|grep -v grep|grep {port}|awk " + "'{print $2}'" + "| xargs kill -9"
        else:
            cmd = f"ps -ef|grep iperf|grep -v grep|grep {port}|awk " + "'{print $2}'" + "| xargs kill -9"
        return self.exec_adb_shell_command(f'"{cmd}"')

    def start_iperf_listen_on(self, port, use_iperf3=True):
        if use_iperf3:
            cmd = f"cd /data/data/com.nokia.android.application/ && iperf3 -s -p {port} -D"
        else:
            cmd = f"cd /data/data/com.nokia.android.application/ && iperf -s -p {port} -D"
        return self.exec_adb_shell_command(f'"{cmd}"')

    def _get_app_server(self):
        from robot.libraries.BuiltIn import BuiltIn
        robot_obj = BuiltIn()
        tl = robot_obj.get_variable_value('${tl}')
        ssh = tl.appserver.iperf_details.ssh_connection_details
        return ssh.addr, ssh.username, ssh.password, ssh.port

    def _start_test_iperfserver(self):
        pass

    def _prepare_ucs(self):
        if self.cpc.os.lower() == 'windows':
            if not self.debug:
                self.cpc.start_uc_proxy(self.pcconfig['ucproxy_app'], True)
            self.launch_naa()

    def start_remote_iperf_server(self,
                                  hostname: str,
                                  username: str,
                                  password: str,
                                  port: int = 22,
                                  is_iperf2: bool = True,
                                  is_udp: bool = True,
                                  iperf_port: int = 5001,
                                  restart: bool = False) -> None:
        self.logger.info(f'Start iperf server on {hostname}:{port}')
        from taf.transport.ssh import ssh
        remote = ssh()
        remote.connect_to(hostname=hostname, username=username, password=password, port=port, alias=hostname)
        cmd = 'ps -ef|grep iperf|grep -v grep'
        self.logger.info(cmd)
        lines = [x for x in remote.execute(cmd, connection=hostname).splitlines() if x.strip()]
        lines = [x for x in lines if str(iperf_port) in x and '-s' in x]
        if is_udp:
            lines = [x for x in lines if '-u' in x]
        else:
            lines = [x for x in lines if '-u' not in x]
        if not is_iperf2:
            lines = [x for x in lines if 'iperf3' in x]

        for line in lines:
            print(line)

        if lines:
            pid = lines[0].split()[1]
            self.logger.info(f'iperf server already started, pid: {pid}')
            if restart:
                self.logger.info(f'Kill iperf server {pid} because restart is needed')
                remote.execute(f'sudo kill -9 {pid}', connection=hostname)
            else:
                self.logger.info('iperf server does not need to restart because restart is not needed')
                remote.disconnect(connection=hostname)
                return 0

        cmd = '{} -s -p {} -D '.format('iperf' if is_iperf2 else 'iperf3', iperf_port)
        cmd += ' -u' if is_udp else ''
        self.logger.info(cmd)
        remote.execute(cmd, connection=hostname)
        self.logger.info(remote.execute(f'ps -ef|grep iperf|grep {iperf_port}|grep -v grep', connection=hostname))
        remote.disconnect(connection=hostname)

    def _start_ul_traffic(self, IperfOptions: str = '',
                          remote_hostname: str = '',
                          remote_username: str = '',
                          remote_password: str = '',
                          remote_port: int = 22) -> None:

        if remote_hostname == '':
            remote_hostname, remote_username, remote_password, remote_port = self._get_app_server()

        isudp = '-u' in IperfOptions
        iperf_port = re.findall(r'-p\s?(\d+)', IperfOptions)[0] if '-p' in IperfOptions else 5001
        self.start_remote_iperf_server(remote_hostname, remote_username, remote_password, remote_port,
                                       is_udp=isudp, iperf_port=iperf_port)

        # self.kill_naa()
        # self.launch_naa()
        # self.ucs.stop_all(self.imei)
        # self.ucs.wait_until_idle(self.imei)
        cmd = f'iperf -c {remote_hostname} {IperfOptions}'
        testname = self._uc_testname('ul', IperfOptions)
        self._stop_testname(testname)

        self.ucs.recreat_iperf_test(testname, cmd)
        time.sleep(10)
        testId = self.ucs.start_test(self.imei, testname)
        self.ucs.wait_until_test_started(testId)

    def _uc_testname(self, direction: str = 'dl', IperfOptions: str = '') -> str:
        isudp = '-u' in IperfOptions
        iperf_port = re.findall(r'-p\s?(\d+)', IperfOptions)[0] if '-p' in IperfOptions else 5001
        testname = f'{self.serialno}_{direction}_{iperf_port}_' + 'udp' if isudp else 'tcp'
        return testname

    def _stop_testname(self, testname):
        for testId in [x['testId'] for x in self.ucs.get_running_test(self.imei) if x['name'] == testname]:
            self.ucs.stop_test(self.imei, testId)
            self.ucs.wait_until_test_stopped(testId)

    def _stop_ul_traffic(self, IperfOptions: str = '') -> None:
        self._stop_testname(self._uc_testname('ul', IperfOptions))

    def _start_dl_traffic(self,
                          IperfOptions: str = '',
                          ueip: str = '',
                          intf_name: str = '',
                          remote_hostname: str = "",
                          remote_username: str = "",
                          remote_password: str = "",
                          remote_port: int = 22) -> str:
        # ex: iperf -c 172.251.60.1 -u -P 1 -i 1 -p 5265 -l 1400.0b -f k -b 800M -t 3600 -T 1
        # IperfOption is like: -u -P 1 -i 1 -p 5265 -l 1400.0b -f k -b 800M -t 3600 -T 1
        # Option Params: ueip, intf_name
        if remote_hostname == '':
            remote_hostname, remote_username, remote_password, remote_port = self._get_app_server()

        isudp = '-u' in IperfOptions
        iperf_port = re.findall(r'-p\s?(\d+)', IperfOptions)[0] if '-p' in IperfOptions else 5001
        testname = self._uc_testname('dl', IperfOptions)
        self._stop_testname(testname)

        cmd = f'iperf -i 1 -s -p {iperf_port} ' + '-u' if isudp else ''
        self.ucs.recreat_iperf_test(testname, cmd)
        self.logger.info(f'Start Iperf Server in NAA {testname}')
        testId = self.ucs.start_test(self.imei, testname)
        self.logger.info(f'Wait until test started, testname: {testname}')
        self.ucs.wait_until_test_started(testId)

        ueip = ueip or self.get_ueip(work_mode='adb', intf_name=intf_name)
        output_fname = '~/ta_iperf.log'

        from taf.transport.ssh import ssh
        remote = ssh()
        remote.connect_to(hostname=remote_hostname, username=remote_username,
                          password=remote_password, port=remote_port, alias=remote_hostname)
        remote.execute(f'sudo pkill -f "{ueip}"', connection=remote_hostname)
        cmd = f'nohup iperf -c {ueip} {IperfOptions} >{output_fname} &'
        self.logger.info(cmd)
        remote.send_command(cmd, connection=remote_hostname)
        remote.disconnect(connection=remote_hostname)
        return output_fname

    def _stop_dl_traffic(self,
                         IperfOptions: str,
                         ueip: str = '',
                         intf_name: str = '',
                         remote_hostname: str = "",
                         remote_username: str = "",
                         remote_password: str = "",
                         remote_port: int = 22) -> str:

        if remote_hostname == '':
            remote_hostname, remote_username, remote_password, remote_port = self._get_app_server()
        ueip = ueip or self.get_ueip(work_mode='adb', intf_name=intf_name)

        from taf.transport.ssh import ssh
        remote = ssh()
        remote.connect_to(hostname=remote_hostname, username=remote_username, port=remote_port,
                          password=remote_password, alias=remote_hostname)
        cmd = f'kill -9 $(pgrep -f {ueip})'
        self.logger.info(cmd)
        remote.execute(cmd, connection=remote_hostname)
        remote.disconnect(connection=remote_hostname)

        testname = self._uc_testname('dl', IperfOptions)
        self._stop_testname(testname)

    def start_traffic(self,
                      IperfOptions: str,
                      direction: Literal['upload', 'download'] = 'download',
                      ueip: str = '',
                      intf_name: str = '',
                      remote_hostname: str = "",
                      remote_username: str = "",
                      remote_password: str = "",
                      remote_port: int = 22) -> None:
        direction = direction.lower()
        if direction not in ['ul', 'dl']:
            raise ValueError("direction must be 'ul' or 'dl'")

        if direction == 'dl':
            self._start_dl_traffic(IperfOptions, ueip=ueip, intf_name=intf_name,
                                   remote_hostname=remote_hostname,
                                   remote_username=remote_username,
                                   remote_password=remote_password,
                                   remote_port=remote_port)
        elif direction == 'ul':
            self._start_ul_traffic(
                IperfOptions, remote_hostname=remote_hostname, remote_username=remote_username,
                remote_password=remote_password, remote_port=remote_port)

    def stop_traffic(self,
                     IperfOptions: str,
                     direction: Literal['ul', 'dl'] = 'dl',
                     ueip: str = '',
                     intf_name: str = '',
                     remote_hostname: str = "",
                     remote_username: str = "",
                     remote_password: str = "",
                     remote_port: int = 22) -> None:
        direction = direction.lower()
        if direction not in ['ul', 'dl']:
            raise ValueError("direction must be 'ul' or 'dl'")

        if direction == 'dl':
            self._stop_dl_traffic(ueip=ueip, intf_name=intf_name, IperfOptions=IperfOptions,
                                  remote_hostname=remote_hostname,
                                  remote_username=remote_username,
                                  remote_password=remote_password,
                                  remote_port=remote_port)
        if direction == 'ul':
            self._stop_ul_traffic(IperfOptions=IperfOptions,)

    def _wait_until_idle_in_ucs(self, timeout: int = 900) -> None:
        st = time.time()
        while True:
            if time.time() - st > timeout:
                raise Exception(f'UCS is not idle in {timeout} seconds')
            if self.ucs.is_idle(self.imei):
                break
            time.sleep(5)

    def _get_imei_adb(self):
        lines = self.exec_adb_shell_command('service call iphonesubinfo 1').splitlines()
        lines = [x for x in lines if "0x0000" in x]
        imei = ''
        for line in lines:
            line = line.replace(')', '').replace("'", '').replace('.', '').strip()
            imei += line.split()[-1]
        return imei

    def naa_click_network_info(self):
        self.launch_naa()
        self._click_text('Network Info')

    def _get_naa_signal_info(self):
        self.log('**** Get NAA Signal info')
        app = 'com.nokia.android.application'
        self.launch_naa()
        self._click_ui_node(resourceid=f"{app}:id/network_info")
        output = self.exec_adb_shell_command('cat /sdcard/window_dump.xml', log=False)
        tree = etree.fromstring(output.encode())
        selected = tree.xpath('//node[@text="Network Info"]/@selected')[0] == 'true'
        if not selected:
            self._try_ui_dump()
            output = self.exec_adb_shell_command('cat /sdcard/window_dump.xml', log=False)
            tree = etree.fromstring(output.encode())
        network = tree.xpath(f'//node[@resource-id="{app}:id/nr_overview_cell_type_value"]/@text')
        network += tree.xpath(f'//node[@resource-id="{app}:id/lte_overview_cell_type_value"]/@text')
        cell = tree.xpath(f'//node[@resource-id="{app}:id/nr_overview_cell_id_value"]/@text')
        cell += tree.xpath(f'//node[@resource-id="{app}:id/lte_overview_cell_id_value"]/@text')
        signal = tree.xpath(f'//node[@resource-id="{app}:id/nr_overview_signal_strength_value"]/@text')
        signal += tree.xpath(f'//node[@resource-id="{app}:id/lte_overview_signal_strength_value"]/@text')
        ipv4addr = tree.xpath(f'//node[@resource-id="{app}:id/network_interfaces_ipv4_value"]/@text')
        return dict(
            network=network[0] if network else '',
            cellid=cell[0].split('/')[0].strip() if cell and '/' in cell[0] else '',
            pci=cell[0].split('/')[1].strip() if cell and '/' in cell[0] else '',
            signal=signal[0] if signal else '',
            ipv4addr=ipv4addr[0] if ipv4addr else '',
            )

    def get_naa_throughput(self):
        self.launch_naa()
        self._click_ui_node(resourceid="com.nokia.android.application:id/charts")
        output = self.exec_adb_shell_command('cat /sdcard/window_dump.xml', log=False)
        tree = etree.fromstring(output.encode())
        selected = tree.xpath('//node[@text="Charts"]/@selected')[0] == 'true'
        with open('a.xml', 'w', encoding='utf-8') as f:
            f.write(output)
        if not selected:
            self._try_ui_dump()
            output = self.exec_adb_shell_command('cat /sdcard/window_dump.xml', log=False)
            tree = etree.fromstring(output.encode())
        app = 'com.nokia.android.application'
        totalul = tree.xpath(f'//node[@resource-id="{app}:id/total_ul_value"]/@text')
        totaldl = tree.xpath(f'//node[@resource-id="{app}:id/total_dl_value"]/@text')
        mobelul = tree.xpath(f'//node[@resource-id="{app}:id/mobile_ul_value"]/@text')
        mobeldl = tree.xpath(f'//node[@resource-id="{app}:id/mobile_dl_value"]/@text')
        return dict(
            totalul=totalul[0] if totalul else '',
            totaldl=totaldl[0] if totaldl else '',
            mobelul=mobelul[0] if mobelul else '',
            mobeldl=mobeldl[0] if mobeldl else '',
            )

    def disable_rotation(self):
        self.log('关闭屏幕旋转')
        self.exec_adb_shell_command('settings put system accelerometer_rotation 0')
        self.exec_adb_shell_command('settings put system user_rotation 0')

    def _start_uc_proxy(self, forced: bool = False) -> None:
        app_path = self.pcconfig.get('ucproxy_app', '')
        if app_path:
            self.cpc.start_uc_proxy(self.pcconfig['ucproxy_app'], forced)
        else:
            raise Exception('UC Proxy app path is not set in config json file, please check it.')

    def get_naastatus(self):
        return self.ucs.get_ue_info(self.imei)

    def get_dltput(self):
        return self.ucs.get_ue_info(self.imei)['data'][0]['tputDl']

    def get_ultput(self):
        return self.ucs.get_ue_info(self.imei)['data'][0]['tputUl']

    def import_uc_test_from_file(self, test_file: str, test_name: str = '') -> None:
        return self.ucs.import_test_from_file(test_file, test_name)

    def import_uc_sequence_from_file(self, sequence_file: str, sequence_name: str = '', replace: bool = False) -> None:
        return self.ucs.import_sequence_from_file(sequence_file, sequence_name, replace)

    def scroll_up(self):
        self.log_info('scoll up')
        return self.exec_adb_shell_command('input swipe 250 800 250 400 300')

    def scroll_down(self):
        self.log_info('scoll up')
        return self.exec_adb_shell_command('input swipe 250 400 250 800 300')


class AndroidUeManager(object):

    def __init__(self, logger: logging.Logger = None) -> None:
        self.logger = logger
        self._ues = {}
        self._cpcs = {}
        self.config = load_config()

    def cpc(self, hostname: str) -> Union[LinuxPC, WinPC]:
        if hostname not in self._cpcs:
            pcinfo = self.config['control pcs'].get(hostname, {})
            if pcinfo:
                options = SimpleNamespace(**pcinfo)
                if options.os == 'windows':
                    pc = WinPC(hostname=options.hostname, username=options.username,
                               password=options.password, port=options.port, os=options.os,
                               logger=self.logger)
                else:
                    pc = LinuxPC(hostname=options.hostname, username=options.username,
                                 password=options.password, port=options.port, os=options.os,
                                 logger=self.logger)
                pc.setup()
                self._cpcs.update({hostname: pc})
                return pc
            else:
                raise Exception(f'UEPC {hostname} is not in config json file, please check it.')
        else:
            return self._cpcs[hostname]

    def ue(self, serialno: str) -> AndroidUE:
        if serialno not in self._ues:
            ue = AndroidUE(serialno=serialno, logger=self.logger)
            ue.cpc = self.cpc(ue.pcconfig['hostname'])
            self._ues.update({serialno: ue})
            return ue
        else:
            return self._ues[serialno]


if __name__ == '__main__':
    import logging
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)
    AUM = AndroidUeManager(logging.getLogger('Commercial UE'))

    logging.info('OK')
    # load_config()
    # ue = AUM.ue('7TD0221525014570')
    ue = AUM.ue('8885dec7')
    ue = AUM.ue('8885dec7')
    ue.debug = True
    pprint(ue.get_naastatus())
    # pprint(ue.ucs.get_tests_of_type('FTP'))
    # ue.start_uc_test_or_sequence(test_name='Iperf3Server')
    # time.sleep(10)
    # ue.stop_uc_test_or_sequence(test_name='Iperf3Server')

    # ue.start_uc_test_or_sequence(sequence_name='tq')
    # time.sleep(10)
    # ue.stop_uc_test_or_sequence(sequence_name='tq')

    # ue.stop_uc_all()

    # pprint(ue.stop_uc_test_or_sequence(ue.imei))
    # ue.ucs.stop_test(ue.imei, 'Iperf3Server')
    # pprint(ue.ucs.get_running_test(ue.imei))
    # ue.start_uc_test_or_sequence(sequence_name='tq')
    # ue.stop_uc_test_or_sequence(test_name='Iperf3Server')
    # pprint(ue.stop_uc_test_or_sequence(sequence='tq'))
    # ue.attach(forced=True)
    # pprint(ue.ucs.import_test_sequence('/home/ute/seq.json', sequence_name='JuSeq', replace=True))
    # pprint(ue.ucs.import_test_from_file('/home/ute/test.uct', test_name='juftp', replace=True))
    # ue = AUM.ue('96bd4b36')  # linux ue
    # ue.wakeup()
