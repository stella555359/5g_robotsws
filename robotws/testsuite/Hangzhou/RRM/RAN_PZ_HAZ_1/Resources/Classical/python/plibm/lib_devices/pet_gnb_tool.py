# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import time
import logging
import os
import paramiko
try:
    from common import timeout
except Exception:
    from .common import timeout


class gnb_tool(object):

    def __init__(self, logger=None):
        self.tool_location = '/tmp/gnb_logs_tool'
        self.logger = logger or logging.getLogger('PetTA')
        self.app_path = ''
        self.log_path = ''
        self.ssh_shell = None
        self.ssh = None
        self.file_server = '10.56.111.190'

    def _exec_local_command(self, command):
        self.logger.info('Run command: {}'.format(command))
        return os.popen(command).read()

    def setup(self):
        self._exec_local_command('mkdir -p ~/tools')
        if not os.path.exists('~/tools/gnb_logs'):
            self.logger.info('gnb_logs_tool does not exist.')
            cmd = f'sshpass -p qqwweeRR0- scp -r ute@{self.file_server}:/home/ute/store/gnb_logs/ ~/tools/'
            self._exec_local_command(cmd)
        else:
            self.logger.info('gnb_logs_tool already exists')
        self.app_path = '~/tools/gnb_logs/gnb_logs'
        self._exec_local_command(f'sudo chmod +x {self.app_path}')
        self._exec_local_command(f'sudo {self.app_path} -V')
        self.logger.info('gnb log app path: ' + self.app_path)

    @timeout(300, 'Timeout happened on gnb tool start')
    def start(self, host='127.0.0.1', port=22, username='ute', password='uteUTE!', dest_ip='',
              log_dire='', option='', stop_keyword='Press'):
        self.log_dire = log_dire
        if not os.path.exists(log_dire):
            os.mkdir(log_dire)

        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.ssh.connect(host, port, username, password)

        cmd = 'cd {};sudo {} --ip {} {}'.format(log_dire, self.app_path, dest_ip, option)
        self.logger.info(cmd)
        self.ssh_shell = self.ssh.invoke_shell()
        self.ssh_shell.send(cmd + '\n')

        exp_str = 'Wait for Press <Enter> again to stop and dump logs' if not stop_keyword else stop_keyword
        output = ''
        start_time = time.time()
        while exp_str.lower() not in output.lower() and time.time() < start_time + 60:
            lines = self.ssh_shell.recv(9999).decode()
            if lines:
                output += lines
            time.sleep(1)
        self.start_filelist = os.listdir(log_dire)

    @timeout(600, 'Timeout happened on gnb tool stop')
    def stop(self):
        if os.popen('ps -ef|grep gnb_logs|grep -v grep').read().splitlines():
            self.ssh_shell.send('\n')
            tool_log = os.path.join(self.log_dire, 'tool.log')
            exp_str = 'Duration seconds'
            start_time = time.time()
            logfilename = ''
            while time.time() < start_time + 1200:
                if exp_str.lower() in open(tool_log).read().lower():
                    break
                else:
                    time.sleep(1)
            self.ssh.close()

            self.end_filelist = os.listdir(self.log_dire)
            logfilename = [x for x in self.end_filelist if x not in self.start_filelist and x.endswith('.zip')]
            if logfilename:
                logfilename = logfilename[0]
            else:
                raise Exception('No new log file name found.')
            logfilename = os.path.join(self.log_dire, logfilename)
            self.logger.info('Log file is: {}'.format(logfilename))
            return logfilename
        else:
            return ''

    def unzip_logfile(self, logfile):
        dire = os.path.dirname(logfile)
        fname = os.path.basename(logfile)
        self._exec_local_command('cd {} && unzip {}'.format(dire, fname))

    def analysis_logfiles(self, logfile):
        dire = os.path.dirname(logfile)
        fname = os.path.basename(logfile)
        log_path = os.path.join(dire, os.path.splitext(fname)[0])

        tti_path = os.path.join(log_path, 'tti_packed')
        tti_csv_files = []
        if os.path.exists(tti_path):
            for p in os.listdir(tti_path):
                if os.path.isdir(os.path.join(tti_path, p)):
                    tti_csv_path = os.path.join(tti_path, p)
                    for csv in os.listdir(tti_csv_path):
                        tti_csv_files.append(os.path.join(tti_csv_path, csv))

        sherpa_files = []
        sherpa_path = os.path.join(log_path, 'L2_trace')
        for pcapfile in os.listdir(sherpa_path):
            if pcapfile.endswith('.pcap'):
                sherpa_files.append(os.path.join(sherpa_path, pcapfile))
        return dict(sherpa_pcap_files=sherpa_files, tti_csv_files=tti_csv_files)

    def convert_sherpa_file(self, pcapfile, dst_csv_dire):
        #  pcapfile and dst_csv_dire need full absolutate path
        if not os.path.exists(dst_csv_dire):
            os.mkdir(dst_csv_dire)
        cmd = '/opt/Nokia/Sherpa_5G_18/Sherpa.run -d 3000 -o {} {}'.format(dst_csv_dire, pcapfile)
        self._exec_local_command(cmd)


if __name__ == '__main__':
    import logging
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)
    logging.info('OK')
    gt = gnb_tool()
    gt.setup()
    # print(gt.analysis_logfiles('/home/ute/temp/bantao/gNB_10.108.231.208_20220822_142346_m.zip'))
