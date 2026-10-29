# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import time
import re
import logging
from lxml import etree

try:
    from .pet_ssh import cpc_factory
except Exception as E:
    from pet_ssh import cpc_factory


class c_android_ue(object):

    def __init__(self, **kwargs):
        self.ue_type = 'android'
        self.host = kwargs.get('host', '')
        self.os = kwargs.get('os', 'windows')
        self.serialno = kwargs.get('serialno', '')
        self.model = kwargs.get('model', 'xiaomi').lower()
        self.logger = kwargs.get('logger', logging.getLogger(__file__))
        self.cpc = cpc_factory(**kwargs)
        self.log('Initlizate: {} {} {}'.format(self.host, self.os, self.serialno))
        self.alias = str(self)
        self.config_app = kwargs.get('config_app', 'com.android.settings')
        self.config_activity = kwargs.get('config_activity', 'com.android.settings/.Settings')
        if self.model == 'huawei':
            self.config_activity = 'com.android.settings/com.android.settings.HWSettings'

    def __str__(self):
        return 'Android_UE_' + self.serialno

    def __repr__(self):
        return self.__str__()

    def log(self, msg=[]):
        self.logger.info('Android UE {}:  {}'.format(self.serialno, msg))

    def setup(self):
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

    def teardown(self):
        if self.cpc:
            self.cpc.teardown()

    def exec_adb_command(self, command):
        cmd = 'adb -s {} {}'.format(self.serialno, command)
        self.log('ADB CMD: [{}]'.format(cmd))
        return self.cpc.exec_command(cmd)

    def exec_adb_shell_command(self, command, log=True):
        cmd = 'adb -s {} shell {}'.format(self.serialno, command)
        self.log('ADB Shell CMD: [{}]'.format(cmd))
        return self.cpc.exec_command(cmd, log=log)

    def is_air_plane(self):
        output = self.exec_adb_shell_command('settings get global airplane_mode_on')
        output = [x for x in output.splitlines() if x.strip()]
        if output:
            return output[0][0].strip() == '1'
        else:
            self.log('Could not get the air plane mode.')

    def is_screen_on(self):
        output = self.exec_adb_shell_command('"dumpsys window policy|grep interactiveState"')
        return 'interactiveState=INTERACTIVE_STATE_AWAKE' in output

    def blink_screen(self):
        if not self.is_screen_on():
            self.log('Screen is off, I will turn it on')
            return self.exec_adb_shell_command('input keyevent 26')
        else:
            self.log('Screen is On')

    def turn_off_screen(self):
        if self.is_screen_on():
            self.log('Screen is on, I will turn it off')
            return self.exec_adb_shell_command('input keyevent 26')
        else:
            self.log('Screen is off')

    def is_screen_locked(self):
        response = self.exec_adb_shell_command('"dumpsys window|grep mShowing"')
        return 'mDreamingLockscreen=true' in response

    def unlock_screen(self):
        if self.is_screen_locked():
            self.log('Screen is locked, need unlock screen...')
            width, height = self.get_screen_size()
            botton_center_x = int(width) / 2
            botton_center_y = int(height) - 300
            return self.exec_adb_shell_command('input swipe {} {} {} 0 1200'.format(
                botton_center_x, botton_center_y, botton_center_x))
        else:
            self.log('Screen is unlocked')

    def get_screen_size(self):
        output = self.exec_adb_shell_command('wm size')
        if 'Override' in output:
            output = [x for x in output.splitlines() if 'Override' in x]
        else:
            output = [x for x in output.splitlines() if 'size:' in x]
        if output:
            return output[0].split()[-1].split('x')[0], output[0].split()[-1].split('x')[1]
        else:
            raise Exception('failed to get screen size.')

    def wakeup(self):
        self.blink_screen()
        self.unlock_screen()

    def wait_until_airplan(self, timeout=10, airplan=True):
        for i in range(timeout):
            if airplan:
                if self.is_air_plane():
                    return True
                else:
                    time.sleep(1)
            else:
                if not self.is_air_plane():
                    return True
                else:
                    time.sleep(1)
        return False

    def enable_airplan(self, points=[]):
        self.log('Enable air plane')
        if self.is_air_plane():
            self.log('Already in air plane')
        else:
            self._enter_config_app()
            self._touch_points(points)
            self.wait_until_airplan(airplan=True)
            if not self.is_air_plane():
                raise Exception('Enable air plane failed')
            else:
                self.log('Enable airplane done.')
            self.exec_adb_shell_command('input keyevent 4')
            self.kill_config_app()
        self.launch_naa()

    def disable_airplan(self, points):
        self.log('Disable air plane')
        if not self.is_air_plane():
            self.log('Already not in air plane')
            return 0

        self._enter_config_app()
        self._touch_points(points)
        self.wait_until_airplan(airplan=False)
        if self.is_air_plane():
            raise Exception('Disable air plane failed')
        else:
            self.log('Disable airplane done.')
        self.launch_naa()

    def re_attach(self, points=[]):
        self.log('re-attach')
        if not self.is_air_plane():
            points.append(points[-1])
        self._enter_config_app()
        self._touch_points(';'.join(points))
        self.wait_until_airplan(airplan=False)
        if self.is_air_plane():
            self.log('Disable air plane failed')
        else:
            self.log('Disable airplane done.')

    def reboot(self):
        return self.exec_adb_command('reboot')

    def _enter_config_app(self):
        self.wakeup()
        # self.exec_adb_shell_command('am start -a android.settings.AIRPLANE_MODE_SETTINGS --activity-clear-task')
        self.kill_config_app()
        self.launch_app(self.config_activity)

    def kill_package(self, package):
        return self.exec_adb_shell_command('am force-stop {}'.format(package))

    def kill_ultracaller(self):
        return self.kill_package('com.nokia.ultracall')

    def kill_config_app(self):
        # return self.kill_package('com.android.settings')
        if self.model == 'huawei':
            self.kill_package(self.config_app)
        else:
            output = self.exec_adb_shell_command('pm disable {}'.format(self.config_app))
            output += self.exec_adb_shell_command('pm enable {}'.format(self.config_app))
            if 'Exception:' in output:
                return self.kill_package('com.android.settings')
            else:
                return output

    def launch_app(self, activity):
        return self.exec_adb_shell_command('am start -n {}'.format(activity))

    def launch_ultracaller(self):
        return self.launch_app('com.nokia.ultracall/.UCActivity')

    def launch_naa(self):
        return self.launch_app('com.nokia.android.application/.NaaActivity')

    def launch_config_app(self):
        if self.package_is_running(self.config_app):
            self.kill_config_app()
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

    def get_ueip(self, intf_name='', mode='normal'):
        if mode == 'normal':
            ipaddr = self._get_ip_by_address(intf_name)
            if ipaddr:
                self.log('Found UE ipaddr: {}'.format(ipaddr))
            else:
                self.log('Could not found UE ipaddr')
                raise Exception('Failed to get UE IP')
            return ipaddr

    def wait_until_found_ip_of_ue(self, timeout=30, interval=3):
        for i in range(int(int(timeout) / interval)):
            ipaddr = self.get_ueip()
            if ipaddr.strip():
                return True
            else:
                time.sleep(interval)
        return False

    def is_reacable(self):
        ipaddr = self.get_ueip()
        if ipaddr.strip():
            lines = os.popen("sudo ping -c 3 -w 10 {}".format(ipaddr)).read()
            self.log('Ping Result: {}'.format(lines))
            return r'ttl='.upper() in lines.upper()
        else:
            self.log('Could not find ip address of UE.')
            return False

    def start_long_ping_to_ue(self, background=False, ipaddr=''):
        ipaddr = ipaddr or self.get_ueip()
        self.is_reacable()
        if ipaddr:
            if self.is_reacable():
                cmd = 'nohup ping -W 1 ' + ipaddr
                if background:
                    cmd += ' 2>/dev/null &'
                self.log('Start ping to ue: [{}]'.format(cmd))
                os.system(cmd)
            else:
                raise Exception('UE IP is not reachable, case will failed.')
        else:
            raise Exception('Could not find ip of ue.')

    def stop_long_ping_to_ue(self, ipaddr=''):
        ipaddr = ipaddr or self.get_ueip()
        cmd = 'ps -ef|grep ping|grep -v grep|grep {}|'.format(ipaddr)
        cmd += " {print $2}" + '|xargs kill -9'
        self.log(cmd)
        os.system(cmd)

    def file_exists(self, filename):
        return 'File Not Found' not in self.cpc.exec_command('dir {}'.format(filename))

    def _ui_dump(self, filename):
        if os.path.exists(filename):
            os.remove(filename)
        rfile1 = 'c:\\ta\\window_dump.xml'
        if self.file_exists(rfile1):
            self.cpc.exec_command('del ' + rfile1)

        for i in range(20):
            # self.exec_adb_shell_command('rm -rf /sdcard/window_dump.xml')
            self.exec_adb_shell_command('/system/bin/uiautomator dump')
            self.exec_adb_command('pull /sdcard/window_dump.xml c:\\ta')
            if self.file_exists(rfile1):
                self.cpc.get_file_from_cpc('c:/ta/window_dump.xml', filename)
                return filename
            else:
                self.log('Dump UI failed')
        raise Exception('Dump UE UI failed.')

    def _try_ui_dump(self):
        for _ in range(20):
            output = self.exec_adb_shell_command('/system/bin/uiautomator dump')
            if 'window_dump.xml' in output:
                break

    def _click_text(self, text):
        self.exec_adb_shell_command('rm -rf /sdcard/window_dump.xml')
        self._try_ui_dump()
        output = self.exec_adb_shell_command('cat /sdcard/window_dump.xml', log=False)
        # with open('/home/ute/tarun/dump.xml', 'a', encoding='utf-8') as f:
        #     f.write(output)
        nodes = etree.fromstring(output.encode()).xpath('//node')

        node = [x for x in nodes if x.get('text') == text]
        if node:
            self.log('Found text {}, node: {}'.format(text, node[0].get('bounds')))
            node = node[0]
            if node is not None:
                x1, y1, x2, y2 = re.findall(r'[\d]+', node.get('bounds'))
                cx = (int(x1) + int(x2)) / 2
                cy = (int(y1) + int(y2)) / 2
                self.exec_adb_shell_command('input tap {} {}'.format(cx, cy))
                return True
        else:
            self.log('could not found node for text {} '.format(text))
            return False

    def _click_ui_node(self, resourceid='', text=''):
        self.exec_adb_shell_command('rm -rf /sdcard/window_dump.xml')
        self._try_ui_dump()
        output = self.exec_adb_shell_command('cat /sdcard/window_dump.xml', log=False)
        # with open('/home/ute/tarun/dump.xml', 'a', encoding='utf-8') as f:
        #     f.write(output)
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
                cx = (int(x1) + int(x2)) / 2
                cy = (int(y1) + int(y2)) / 2
                self.exec_adb_shell_command('input tap {} {}'.format(cx, cy))
                return True
        else:
            self.log('Could not find the required node')
            return False

    def _touch_points(self, points=''):
        def _point_is_xy(point):
            return len(re.findall(r'([\d]+)[\s\,]+([\d]+)', point.strip())) > 0

        for tap_position in points.split(';'):
            if tap_position.strip():
                if _point_is_xy(tap_position):
                    x, y = tap_position.strip().split(',')
                    self.exec_adb_shell_command('input tap {} {}'.format(x, y))
                else:
                    self._click_text(tap_position.strip())

    def enter_airplan_latest_ui(self, points=''):
        self.log('Disable air plane')
        self._enter_config_app()
        self._touch_points(points)

    def disable_airplan_latest_click(self, points=''):
        self._touch_points(points)
        self.wait_until_airplan(airplan=False)

    def attach(self, **kwargs):
        self.log('Attach...')
        points = kwargs.get('points', '')
        self.disable_airplan(points)

    def deattach(self, **kwargs):
        self.log('Deattach ... ')
        points = kwargs.get('points', '')
        self.enable_airplan(points)

    def launch_miperf(self):
        self.launch_app('com.nextdoordeveloper.miperf.miperf/.MainActivity')

    def kill_miperf(self):
        self.kill_package('com.nextdoordeveloper.miperf.miperf')

    def clear_miperf_inputbox(self):
        for i in range(5):
            self.exec_adb_shell_command('input keyevent KEYCODE_MOVE_END {}'.format(
                'KEYCODE_DEL ' * 25))

    def reload_miperf(self):
        self.wakeup()
        self.kill_miperf()
        self.launch_miperf()

    def input_long_text(self, text):
        for word in text.split():
            for c in word:
                self.exec_adb_shell_command('input text ' + c)
            self.exec_adb_shell_command('input text ' + r'%s')

    def start_iperf_with_miperf(self, **kwargs):
        iperf_option = kwargs.get('option', '')
        start_point = kwargs.get('point')
        self.reload_miperf()
        self.exec_adb_shell_command('input tap 770 550')
        self.clear_miperf_inputbox()
        self.input_long_text(iperf_option)
        if start_point:
            self._touch_points(start_point)

    def stop_iperf_with_miperf(self, **kwargs):
        point = kwargs.get('point', '')
        if point:
            self._touch_points(point)

    def make_vocie_call(self, number=''):
        self.wakeup()
        self.cancel_voice_call()
        self.exec_adb_shell_command('am start -a android.intent.action.CALL -d tel:{}'.format(
            number.strip()))

    def cancel_voice_call(self):
        self.exec_adb_shell_command('input keyevent KEYCODE_ENDCALL')

    def kill_naa(self):
        return self.kill_package('com.nokia.android.application')

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

    def naa_click_network_info(self):
        self.launch_naa()
        self._click_text('Network Info')

    def get_naa_signal_info(self):
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
        if not selected:
            self._try_ui_dump()
            output = self.exec_adb_shell_command('cat /sdcard/window_dump.xml', log=False)
            tree = etree.fromstring(output.encode())
        app = 'com.nokia.android.application'
        totalul = tree.xpath(f'//node[@resource-id="{app}:id/total_ul_value"]/@text')
        mobelul = tree.xpath(f'//node[@resource-id="{app}:id/mobile_ul_value"]/@text')
        totaldl = tree.xpath(f'//node[@resource-id="{app}:id/total_dl_value"]/@text')
        mobeldl = tree.xpath(f'//node[@resource-id="{app}:id/mobile_dl_value"]/@text')
        return dict(
            totalul=totalul[0] if totalul else '',
            mobelul=mobelul[0] if mobelul else '',
            totaldl=totaldl[0] if totaldl else '',
            mobeldl=mobelul[0] if mobeldl else '',
            )

    def disable_rotation(self):
        self.log('关闭屏幕旋转')
        self.exec_adb_shell_command('settings put system accelerometer_rotation 0')
        self.exec_adb_shell_command('settings put system user_rotation 0')


if __name__ == '__main__':
    import logging
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)

    logging.info('OK')
    ue = c_android_ue(host='10.106.230.137', os='windows', serialno='93c03018')
    cpc = ue.cpc
    # cpc.setup()
    # ue._ui_dump('/tmp/ui.xml')
    # ue.exec_adb_shell_command('cat /sdcard/window_dump.xml', False)
    from pprint import pprint
    pprint(ue.get_naa_throughput())
    pprint(ue.get_naa_signal_info())
    # pprint(ue._click_ui_node(resourceid="com.nokia.android.application:id/network_info"))
    # ue._try_ui_dump()
    # ue.stop_iperf_listen_on(50001)
    # ue.start_iperf_listen_on(50001)
    # print(cpc.exec_command('adb shell "ps -ef|grep iperf3"'))
    # print(11111111111111, ue.exec_adb_shell_command('"ps -ef|grep iperf3"'))
    # ue.setup()
    # lines = cpc.exec_command('wmic process get caption,commandline /value|findstr adb').splitlines()
    # for line in [x for x in lines if x.strip() and 'fork-server' in x]:
    #     print(f'!!!!!   {line}')
    # print(ue.is_calling())
    # points = '500,950;950,1400'
    # ue.enable_airplan(points)
    # time.sleep(5)
    # ue.disable_airplan(points)

    # ue = c_android_ue(host='10.108.230.89', os='windows', serialno='H4K5T21107016538', model='huawei')
    # ue._enter_config_app()
    # # ue.wakeup()
    # ue.enable_airplan('450,1350;986,383')
    # time.sleep(5)
    # ue.disable_airplan('450,1350;986,383')
