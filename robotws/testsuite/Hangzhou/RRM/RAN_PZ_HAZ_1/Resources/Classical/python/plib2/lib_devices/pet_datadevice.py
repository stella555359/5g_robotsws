# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import sys
import time
import logging

try:
    from pet_ssh import cpc_linux
except Exception:
    from .pet_ssh import cpc_linux


class TputDevice(cpc_linux):

    def kill_all_iperf(self):
        self.logger.info(self.exec_command('ps -ef|grep iperf|grep -v iperf_server'))
        self.exec_command('sudo killall iperf')
        time.sleep(1)
        self.logger.info(self.exec_command('ps -ef|grep iperf|grep -v iperf_server'))

    def start_iperf_to_ip(self, destip='', band='300m', timeout=60 * 60 * 24, packet_size=1024):
        self.exec_command_background(
            'nohup iperf -c {} -u -b {} -l {} -t {} -i 1 >/dev/null 2>/dev/null &'.format(
                destip, band, packet_size, timeout))

    def start_iperf_to_ip_with_option(self, destip, option):
        self.exec_command_background('nohup iperf -c {} {} >/dev/null 2>/dev/null &'.format(
            destip, option))

    def start_iperf_to_ip_with_option3(self, destip, option):
        self.exec_command_background('nohup iperf3 -c {} {} >/dev/null 2>/dev/null &'.format(
            destip, option))

    def kill_iperf_for_specific_ipaddr(self, ipaddr):
        lines = self.exec_command('ps -ef|grep iperf|grep {}'.format(ipaddr)).splitlines()
        lines = [x for x in lines if x.strip() and '-b' in x]
        for line in lines:
            pid = line.split()[1].strip()
            self.exec_command('sudo kill -9 {}'.format(pid))

    def makesure_iperf_download_is_alive(self, ipaddr, option):
        lines = self.exec_command('ps -ef|grep iperf|grep {}'.format(ipaddr)).splitlines()
        lines = [x for x in lines if x.strip() and '-b' in x]
        if lines:
            self.logger.info('iperf to {} is alive'.format(ipaddr))
        else:
            self.logger.warning('!!!! iperf to {} is dead, rebuild it...'.format(ipaddr))
            self.start_iperf_to_ip_with_option(ipaddr, option)

    def start_iperf_as_server(self, port=50001):
        self.exec_command(f'sudo iperf_server -s -p {port} -D')

    def show_process(self):
        self.exec_command('ps -ef|grep iperf')
        self.exec_command('ps -ef|grep iperf|grep -v iperf_server|grep -v color')
        self.exec_command('ps -ef|grep iperf|grep -v iperf_server|grep -v color|wc -l')
        lines = self.execute_command('ps -ef|grep iperf').splitlines()
        for line in lines:
            if line.strip():
                self.logger.info('IPERF -----:  ' + line)

    def restart_iperf_server(self, ip=''):
        cmd = 'ps -ef|grep iperf|grep -e -s|grep -v grep'
        lines = self.exec_command(cmd).splitlines()
        lines = [x for x in lines if x.strip()]
        for line in lines:
            self.logger.info('Found old iperf server ' + line)
            pid = line.split()[1].strip()
            self.exec_command('sudo kill -9 ' + pid)
        if ip:
            cmd = 'nohup iperf -s -u -B {} -i 1 2>/tmp/iperf.log &'.format(ip)
            # cmd = 'iperf -s -u -B {} -D'.format(ip)
        else:
            cmd = 'nohup iperf -s -u -i 1 2>/dev/null &'
        self.exec_command_background(cmd)
        self.exec_command('ps -ef|grep iperf|grep -v grep')


if __name__ == '__main__':
    import logging
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)

    logging.info('OK')
    td = TputDevice(host='10.69.9.58', os='Linux', username='ute', password='qqwweeRR0-')
    td.connect()
    td.read_shell_response()
    output = td.exec_shell_command('iperf3 -c 10.69.9.57 -i 1 -P 10 -p 50001 -t 10 > a.txt &')
    print('process: ', output)
    time.sleep(20)
    output += td.exec_command('cat a.txt')
    for line in output.splitlines():
        print(line)
    td.disconnect()
