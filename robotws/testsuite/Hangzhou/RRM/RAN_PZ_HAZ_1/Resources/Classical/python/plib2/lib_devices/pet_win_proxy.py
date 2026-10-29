"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""

from distutils import command
import os
import time
import logging
from lxml import etree
try:
    from pet_ssh import cpc_windows
except Exception:
    from .pet_ssh import cpc_windows

logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                    level=logging.DEBUG)
WinProxy_List = ['10.56.221.25', '10.69.82.136', '10.69.2.153']


class c_win_proxy(cpc_windows):

    def _cmd_prompt(self, **kwargs):
        host = kwargs.get('host')
        username = kwargs.get('username', r'noklab\csv5-tester')
        password = kwargs.get('password', r'Nokia123!')
        wait_done = kwargs.get('wait_done', True)
        use_session = kwargs.get('use_session', False)
        session = kwargs.get('session', 0)
        # -s means use system account;
        # -d means does not wait command done, used for gui;
        # -i means use session;
        cmd = 'psexec \\\\{} -u "{}" -p {} -s '.format(host, username, password)
        cmd = cmd + '-d ' if not wait_done else cmd
        if use_session:
            cmd = cmd + '-i {} '.format(session)
        return cmd

    def exec_console_command(self, **kwargs):
        cmd = self._cmd_prompt(**kwargs) + 'cmd.exe /c "{}"'.format(kwargs.get('command'))
        return self.exec_command(cmd, get_pty=True)

    def exec_gui_command(self, **kwargs):
        kwargs['wait_done'] = False
        cmd = self._cmd_prompt(**kwargs) + kwargs.get('command')
        return self.exec_command(cmd, get_pty=True)

    def get_rdp_session(self, **kwargs):
        kwargs['command'] = 'query session'
        output = self.exec_console_command(**kwargs).splitlines()
        output = [x for x in output if kwargs.get('username', r'noklab\csv5-tester').split('\\')[-1] in x]
        if output:
            return output[0].split()[2]
        return 0

    def kill_process(self, **kwargs):
        # rep = WinProxy.kill_process(host='10.69.65.112', process='TmaApplication.exe')
        process = kwargs.get('process')
        kwargs['command'] = 'taskkill /f /im ' + kwargs.get('process')
        return self.exec_console_command(**kwargs)

    def start_tma(self, **kwargs):
        # rep = WinProxy.start_tma(host='10.69.65.112'
        # tma_path='"C:\Program Files (x86)\Aeroflex\TM500\LTE - LMF 9.30.0\Test Mobile Application\TMA.exe"')
        tma_path = kwargs.get('tma_path')
        kwargs['command'] = tma_path + ' /u "Default User" /c y /p 5003 /a n'
        return self.exec_gui_command(**kwargs)

    def stop_tma(self, **kwargs):
        kwargs['process'] = 'TmaApplication.exe'
        self.kill_process(**kwargs)

    def start_btslog(self, **kwargs):
        # rep = WinProxy.start_btslog(host='10.108.184.203')
        kwargs['command'] = 'cd c:/python27 && python.exe btslog_pcap.py -i ' + kwargs.get('intf', 'LMP')
        kwargs['wait_done'] = False
        return self.exec_console_command(**kwargs)

    def port_is_listening(self, **kwargs):
        kwargs['command'] = 'netstat -na|findstr ' + str(kwargs.get('port'))
        rep = self.exec_console_command(**kwargs)
        return 'LISTEN' in rep.upper()

    def deploy_file(self, **kwargs):
        # rep = WinProxy.deploy_file(host='10.108.184.203', src_host='10.69.82.132', src_username='ute',
        # src_password='qqwweeRR0-', src_file='/home/ute/temp/pi.html',
        # dst_file='c:/ta/')

        src_host = kwargs.get('src_host', '10.69.82.132')
        src_host_username = kwargs.get('src_host_username', 'ute')
        src_host_password = kwargs.get('src_host_password', 'qqwweeRR0-')
        src_file = kwargs.get('src_file')
        dst_file = kwargs.get('dst_file')
        cmd = self._cmd_prompt(**kwargs)
        cp_cmd = 'echo y|pscp -2 -pw {} -r {}@{}:{} {}'.format(src_host_password,
                                                               src_host_username,
                                                               src_host,
                                                               src_file,
                                                               dst_file)
        cmd = '{}cmd.exe /c "{}"'.format(self._cmd_prompt(**kwargs), cp_cmd)
        return self.exec_command(cmd, get_pty=True)


def ssh_is_ok(**kwargs):
    host = kwargs.get('host')
    port = int(kwargs.get('port', 22))
    username = kwargs.get('username', r'noklab\csv5-tester')
    password = kwargs.get('password', r'Nokia123!')

    import paramiko
    conn = paramiko.SSHClient()
    conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        conn.connect(host, port=port, username=username, password=password, timeout=20)
        conn.close()
        return True
    except Exception as E:
        return False


def get_live_proxy():
    for proxy_ip in WinProxy_List:
        logging.info('Detect ssh for {} ...'.format(proxy_ip))
        if ssh_is_ok(host=proxy_ip):
            logging.info('WinProxy {} ssh is ok, use it.'.format(proxy_ip))
            return c_win_proxy(host=proxy_ip)
        else:
            logging.error('SSH on {} is unavailable!!!'.format(proxy_ip))


if __name__ == '__main__':
    import logging
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)

    WinProxy = get_live_proxy()
    logging.info('OK')
    WinProxy.connect()
    rep = ''
    logging.info(rep)
    WinProxy.disconnect()
