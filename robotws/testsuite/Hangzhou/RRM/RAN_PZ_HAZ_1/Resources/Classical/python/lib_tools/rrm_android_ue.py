

import os
import time
import re
import sys
import six
import logging
from lxml import etree


try:
    from .rrm_ssh import c_rrm_win_cpc as cpc
except Exception:
    from rrm_ssh import c_rrm_win_cpc as cpc


class c_rrm_android_ue(object):

    def __init__(self, uedb={}, logger=None):
        '''Parameter example:
        uedb is a dict to save config info for ue ex;
            uedb = {
                'serialno': 'b2091cdd',
                'host': '10.106.212.201',
                'password': 'Nokia123!',
                'os': 'windows',
            }

        '''
        self.logger = logger or logging.getLogger('RRM')
        self.db = uedb
        self.serialno = self.db.get('serialno')
        self.cpc = None

    def setup(self):
        self.cpc = cpc(host=self.db.get('host'))
        self.cpc.connect()
        self.cpc.execute_command('adb devices -l')

    def teardown(self):
        if self.cpc:
            self.cpc.disconnect()

    def exec_adb_command(self, command):
        return self.cpc.execute_command('adb -s {} {}'.format(self.serialno, command))

    def exec_adb_shell_command(self, command):
        return self.cpc.execute_command('adb -s {} shell {}'.format(self.serialno, command))

    def is_air_plane(self):
        output = self.exec_adb_shell_command('settings get global airplane_mode_on')
        output = [x for x in output.splitlines() if x.strip()]
        if output:
            return output[0][0].strip() == '1'
        else:
            self.logger.error('Could not get the air plane mode.')

    def is_screen_on(self):
        output = self.exec_adb_shell_command('dumpsys window policy|grep mScreen')
        if output.strip():
            return 'mScreenOnEarly=true' in output and 'mScreenOnFully=true' in output
        else:
            output = self.exec_adb_shell_command('dumpsys window policy|grep interactiveState')
            return 'interactiveState=INTERACTIVE_STATE_AWAKE' in output

    def blink_screen(self):
        if not self.is_screen_on():
            self.logger.info('Screen is off, I will turn it on')
            return self.exec_adb_shell_command('input keyevent 26')
        else:
            self.logger.info('Screen is On')

    def is_screen_locked(self):
        response = self.exec_adb_shell_command('dumpsys window|grep mShowing')
        return 'mDreamingLockscreen=true' in response

    def unlock_screen(self):
        if self.is_screen_locked():
            self.logger.info('Screen is locked, need unlock screen...')
            width, height = self.get_screen_size()
            botton_center_x = int(width) / 2
            botton_center_y = int(height) - 300
            return self.exec_adb_shell_command('input swipe {} {} {} 0 1200'.format(
                botton_center_x, botton_center_y, botton_center_x))
        else:
            self.logger.info('Screen is unlocked')

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

    def enable_airplan(self):
        self.logger.info('Enable air plane')
        if self.is_air_plane():
            self.logger.info('Already in air plane')
        else:
            self._enter_config_app()
            self._touch_points(self.db['enable_air_plane'])
            self.wait_until_airplan(airplan=True)
            if not self.is_air_plane():
                self.logger.error('Enable air plane failed')
            else:
                self.logger.info('Enable airplane done.')
            self.exec_adb_shell_command('input keyevent 4')
            self.kill_config_app()

    def disable_airplan(self):
        self.logger.info('Disable air plane')
        if not self.is_air_plane():
            self.logger.info('Already not in air plane')
            return 0
        else:
            self._enter_config_app()
            self._touch_points(self.db['disable_air_plane'])
            self.wait_until_airplan(airplan=False)
            if self.is_air_plane():
                self.logger.error('Disable air plane failed')
            else:
                self.logger.info('Disable airplane done.')
            self.kill_config_app()

    def re_attach(self):
        self.logger.info('re-attach')
        points = self.db['disable_air_plane'].split(';')
        if not self.is_air_plane():
            points.append(points[-1])
        self._enter_config_app()
        self._touch_points(';'.join(points))
        self.wait_until_airplan(airplan=False)
        if self.is_air_plane():
            self.logger.error('Disable air plane failed')
        else:
            self.logger.info('Disable airplane done.')

    def _enter_config_app(self):
        self.wakeup()
        self.kill_config_app()
        self.launch_config_app()

    def kill_package(self, package):
        return self.exec_adb_shell_command('am force-stop {}'.format(package))

    def kill_ultracaller(self):
        return self.kill_package('com.nokia.ultracall')

    def kill_config_app(self):
        return self.kill_package('com.android.settings')

    def launch_app(self, activity):
        return self.exec_adb_shell_command('am start -n {}'.format(activity))

    def launch_ultracaller(self):
        return self.launch_app('com.nokia.ultracall/.UCActivity')

    def launch_config_app(self):
        if self.package_is_running('com.android.settings'):
            self.kill_config_app()
        self.launch_app('com.android.settings/.Settings')

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

    def _get_ip_by_address(self):
        lines = self.exec_adb_shell_command('ip address show|grep inet')
        ip_addr = re.findall(r'([\d]{1,3}[.][\d]{1,3}[.][\d]{1,3}[.][\d]{1,3})', lines)
        ip_addr = [x for x in ip_addr if '127.0.0.1' not in x and '0.0.0.0' not in x]
        if ip_addr:
            return ip_addr[0].strip()
        else:
            return ''

    def get_ip_address(self):
        if self.db.get('fixed_ip', ''):
            return self.db.get('fixed_ip', '')
        ipaddr = self._get_ip_by_ifconfig() or self._get_ip_by_netcfg() or self._get_ip_by_address()
        if ipaddr:
            self.logger.debug('Found UE ipaddr: {}'.format(ipaddr))
        else:
            self.logger.debug('Could not found UE ipaddr')
            return ''
        return ipaddr

    def wait_until_found_ip_of_ue(self, timeout=30, interval=3):
        for i in range(int(int(timeout) / interval)):
            ipaddr = self.get_ip_address()
            if ipaddr.strip():
                return True
            else:
                time.sleep(interval)
        return False

    def is_reacable(self):
        ipaddr = self.get_ip_address()
        if ipaddr.strip():
            lines = os.popen("sudo ping -c 3 -w 10 {}".format(ipaddr)).read()
            self.logger.debug('Ping Result: {}'.format(lines))
            return r'ttl='.upper() in lines.upper()
        else:
            self.logger.info('Could not find ip address of UE.')
            return False

    def start_long_ping_to_ue(self, background=False, ipaddr=''):
        ipaddr = ipaddr or self.get_ip_address()
        self.is_reacable()
        if ipaddr:
            if self.is_reacable():
                cmd = 'nohup ping -W 1 ' + ipaddr
                if background:
                    cmd += ' 2>/dev/null &'
                self.logger.info('Start ping to ue: [{}]'.format(cmd))
                os.system(cmd)
            else:
                raise Exception('UE IP is not reachable, case will failed.')
        else:
            raise Exception('Could not find ip of ue.')

    def file_exists(self, filename):
        return 'File Not Found' not in self.cpc.execute_command('dir {}'.format(filename))

    def _ui_dump(self, filename):
        if os.path.exists(filename):
            os.remove(filename)
        if self.file_exists(r'c:\window_dump.xml'):
            self.cpc.execute_command(r'del c:\window_dump.xml')
        for i in range(20):
            self.exec_adb_shell_command('/system/bin/uiautomator dump')
            self.exec_adb_command('pull /sdcard/window_dump.xml c:/window_dump.xml')
            if self.file_exists(r'c:\window_dump.xml'):
                break
            else:
                time.sleep(1)
        if self.file_exists(r'c:\window_dump.xml'):
            self.cpc.get_file_from_cpc('c:/window_dump.xml', filename)
        else:
            raise Exception('Dump UE UI failed.')

    def _click_text(self, text):
        filename = '/tmp/uilayout.xml'
        self._ui_dump(filename)
        if six.PY3:
            nodes = etree.fromstring(open(filename).read().encode('utf-8')).xpath('//node')
        else:
            nodes = etree.fromstring(open(filename).read()).xpath('//node')
        node = [x for x in nodes if x.get('text') == text]
        if node:
            self.logger.info('Found text {}, node: {}'.format(text, node[0].get('bounds')))
            node = node[0]
            if node is not None:
                x1, y1, x2, y2 = re.findall(r'[\d]+', node.get('bounds'))
                cx = (int(x1) + int(x2)) / 2
                cy = (int(y1) + int(y2)) / 2
                self.exec_adb_shell_command('input tap {} {}'.format(cx, cy))
                return True
        else:
            self.logger.error('could not found node for text {} '.format(text))
            return False

    def _touch_points(self, points):
        def _point_is_xy(point):
            return len(re.findall(r'([\d]+)[\s\,]+([\d]+)', point.strip())) > 0

        for tap_position in points.split(';'):
            if tap_position.strip():
                if _point_is_xy(tap_position):
                    x, y = tap_position.strip().split(',')
                    self.exec_adb_shell_command('input tap {} {}'.format(x, y))
                else:
                    self._click_text(tap_position.strip())

    def enter_airplan_latest_ui(self):
        self.logger.info('Disable air plane')
        self._enter_config_app()
        points = ';'.join(self.db['enable_air_plane'].split(';')[:-1])
        self._touch_points(points)

    def disable_airplan_latest_click(self):
        points = self.db['enable_air_plane'].split(';')[-1]
        self._touch_points(points)
        self.wait_until_airplan(airplan=False)
