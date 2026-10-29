import logging
import paramiko
import sys
import datetime
import random
import string
# import exceptions
import socket
import time
# import pandas
import csv
# import wget
import zipfile
import os


class emil_decoder(object):
    """docstring for emil_decoder"""
    hostname = '',
    username = 'oper3'
    password = 'Nokia@123'
    emil_path = '"C:\\Program Files\\Emil\\Emil.exe"'
    rs = ''.join(random.sample(string.ascii_letters + string.digits, 8))
    emil_log_dir = '/Temp/' + datetime.datetime.now().strftime('%Y%m%d%H%M%S') + '_' + rs + '/'
    # emil_log_dir=datetime.datetime.now().strftime('%Y%m%d%H%M%S')+'_'+rs+'/'
    emil_log_file_name = ''
    local_log_dir = '/tmp/'
    local_log_list = []
    decoded_file = '*.csv'
    local_log_path = ''
    log_dir_l3dc = '/sharedvolume/ltetracer/traces/CellTrace/'
    decoded_logs = []
    # default_sack='\"C:\\Sacks\\LN21.0_Cell_Trace\"'
    default_sack = '\"C:\\Sacks\\LN26.0_Cell_Trace\"'

    def __init__(self,
                 host_name='10.56.111.77',
                 username='hoam-tester',
                 password='Nokia123!',
                 emil_path='C:\\\"Program Files\"\\Emil\\Emil.exe',
                 host_name_l3dc='10.97.92.238',
                 username_l3dc='dcapuser',
                 password_l3dc='dcapuser123',
                 log_dir_l3dc='/sharedvolume/ltetracer/traces/CellTrace/'
                 ):
        super(emil_decoder, self).__init__()
        self.host_name = host_name
        self.username = username
        self.password = password
        self.emil_path = emil_path
        self.host_name_l3dc = host_name_l3dc
        self.username_l3dc = username_l3dc
        self.password_l3dc = password_l3dc
        self.log_dir_l3dc = log_dir_l3dc
        # self.kill_emil_process()

    def setup(self):
        self.ssh_l3dc, self.sftp_l3dc = self.connect_to_server(
            self.host_name_l3dc, self.username_l3dc, self.password_l3dc
        )
        self.ssh_emil, self.sftp_emil = self.connect_to_server(
            self.host_name, self.username, self.password
        )

    def teardown(self):
        self.ssh_l3dc.close()
        self.sftp_l3dc.close()
        self.ssh_emil.close()
        self.sftp_emil.close()

    def kill_emil_process(self):
        '''
        Kill the running processes of Emil.
        '''
        cmd = 'tasklist | find /I "emil" |awk -F " " "{print $2}"'
        stdin, stdout, stderr = self.ssh_emil.exec_command(cmd)
        output = stdout.read().decode()
        logging.info('Emil processes: ' + output.replace('\r\n', ' '))
        tasklist = output.split('\n')
        tasklist.pop()
        logging.info('Emil task list: ' + str(tasklist))
        for task in tasklist:
            cmd = 'TASKKILL /F /PID ' + task
            self.ssh_emil.exec_command(cmd)
        pass

    def connect_to_server(self, host_name, username, password):
        know_host = paramiko.AutoAddPolicy()
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(know_host)
        try:
            ssh.connect(
                hostname=host_name,
                port=22,
                username=username,
                password=password,
                timeout=60
            )
        except paramiko.AuthenticationException:
            logging.error('Bad password! ' + username + '/' + password)
        except Exception as e:
            logging.error('Connect to server via ssh: ' + host_name + ' failed! Exception:' + str(e))
            sys.exit()
        host_ip = ssh.get_transport().sock.getpeername()[0]
        logging.info('Login to ' + host_ip + ' via ssh succeed!')

        try:
            sftp = paramiko.SFTPClient.from_transport(ssh.get_transport())
        except Exception as e:
            logging.error('Connect to server via sftp: ' + host_name + ' failed! Exception:' + str(e))
            sys.exit()
        logging.info('Login to ' + host_ip + ' via sftp succeed!')
        return ssh, sftp

    def decode_local_emil_log(self, sack_name='SBTS20C_ENB_0000_000982_000000',
                              local_emil_log_path='/tmp/Lte_MRBTS-22264_201020_0512.emil'):
        '''
        1. Create new directory under /Temp/ for decoding
        2. Uplaod sacke file
        3. upload emil log file
        4. decode emil log file with the uploaded sack
        '''
        self.create_new_dir_at_emil_server(dir=self.emil_log_dir)
        bts_build = self.fetch_bts_build(bts_ip='10.97.91.20')
        sack_folder = self.fetch_sack(sack_name=bts_build)

        sack_folder = sack_name
        self.create_new_dir_at_emil_server(dir=self.emil_log_dir + sack_folder)
        self.upload_sack(self.local_log_dir + sack_folder, self.emil_log_dir + sack_folder)
        sack_file_name = sack_name + '_ida.zip'
        remote_sack_path = self.emil_log_dir + sack_folder
        log_file_name = local_emil_log_path.split('/')[-1]
        self.upload_file_to_emil_server(self.sftp_emil, local_log_path=local_emil_log_path,
                                        remote_dir=self.emil_log_dir + log_file_name)
        self.decode_log(sack=remote_sack_path, log_dir=self.emil_log_dir)
        self.download_logs(self.sftp_emil, path_to_log=self.emil_log_dir + self.decoded_file,
                           local_log_path=self.local_log_path)
        self.read_decoded_logs(csv_file=self.local_log_path)
        return self.decoded_logs

    def upload_sack(self, sack_path='/tmp/SBTS20C_ENB_0000_001079_000000',
                    remote_sack_path='/Temp/SBTS20C_IDA_0000_001079_000000'):
        for item in os.listdir(sack_path):
            local_file = os.path.join(sack_path, item)
            remote_file = os.path.join(remote_sack_path, item)
            logging.info('uploading file ' + local_file + ' to ' + remote_file)
            self.sftp_emil.put(local_file, remote_file)
            logging.info('Uploaded sack file: ' + item)
        pass

    def fetch_sack(self, sack_name='SBTS20C_ENB_0000_001079_000000',
                   url='http://files.ute.nsn-rdnet.net/builds/enb/base/'):
        sack_url = url + sack_name + '/' + sack_name + '_ida.zip'
        logging.info('Download sack from ' + sack_url)
        out_path = self.local_log_dir + sack_name + '_ida.zip'
        file_name = wget.download(sack_url, out=out_path)
        logging.info('Download sack complete! ' + out_path)
        extract_folder = zipfile.ZipFile(out_path).namelist()[0]
        zipfile.ZipFile(out_path).extractall(self.local_log_dir)
        logging.info('sack folder name: ' + extract_folder)
        return extract_folder

    def fetch_bts_build(self, bts_ip='10.97.91.20', username='toor4nsn', password='oZPS0POrRieRtu'):
        ssh, sftp = self.connect_to_server(bts_ip, username, password)
        stdin, stdout, stderr = ssh.exec_command('ls /ffs/run/TargetBD*xml')
        output = stdout.read().decode().replace('\r', '').replace('\n', '')
        logging.info('SBTS build info: ' + output)
        if 'TargetBD' in output:
            bts_build = output.replace('/ffs/run/TargetBD_', '').replace('.xml', '')
            return bts_build
        else:
            raise Exception('Fetch SBTS build failed!')

    def decode_recent_logs(self, sack='\"C:\\Sacks\\LN23.0_Cell_Trace\"', count=4, ne='22264'):
        '''
        Decode recent log of L3DC.
        1. Transfer recent files L3DC->Local->Emil server
        2. Decode files at Emil server
            Decode ommand example: Emil.exe -EmilLogs C:\\Temp\\test\\test.lcbin
            -SubDirs -SackPath C:\\Sacks\\LN21.0_Cell_Trace -ToCSV
        3. download decoded csv file
        4. read csv file aand return the decoded message list
        '''
        self.rs = ''.join(random.sample(string.ascii_letters + string.digits, 8))
        self.emil_log_dir = '/Temp/' + datetime.datetime.now().strftime('%Y%m%d%H%M%S') + '_' + self.rs + '/'
        self.transfer_file(count=count, ne=ne)
        self.decode_log(sack=sack, log_dir=self.emil_log_dir)
        self.download_logs(self.sftp_emil, path_to_log=self.emil_log_dir + self.decoded_file,
                           local_log_path=self.local_log_path)
        self.read_decoded_logs(csv_file=self.local_log_path)
        return self.decoded_logs

    def decode_log(self, sack='\"C:\\Sacks\\LN23.0_Cell_Trace\"', log_dir='C:\\Temp\\test\\*'):
        emil_log_dir_converted = '\"C:' + log_dir.replace('/', '\\') + '*\"'
        cmd = self.emil_path + ' -EmilLogs ' + emil_log_dir_converted + ' -SubDirs -SackPath ' + sack + ' -ToCSV'
        logging.info('Decode command: ' + cmd)
        self.ssh_emil.exec_command(cmd, timeout=10)
        logging.info('Decode command executed')
        self.decoded_log_verfication()
        pass

    def read_decoded_logs(self, csv_file):
        logging.info('Reading decoded log')
        csv.field_size_limit(500 * 1024 * 1024)
        with open(csv_file) as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                logging.info(row)
                self.decoded_logs.append(row)
        logging.info('Reading decoded log complete')

    def decoded_log_verfication(self, timeout=60):
        '''
        Verfify if csv file is generated whithin defined timeout.
        Kill Emil process
        '''
        i = 0
        while i < 30:
            stdin, stdout, stderr = self.ssh_emil.exec_command('ls -l ' + self.emil_log_dir + '*csv')
            output = stdout.read().decode().replace('\r\n', '')

            logging.info('list decoded file: ' + output)
            # stdin, stdout, stderr = self.ssh_emil.exec_command('ls '+self.emil_log_dir+'*csv')
            # output=stdout.read().decode().replace('\r','').replace('\n','')

            if 'csv' in output and int(output.split()[4]) > 0:
                '''
                csv in output and file size shall exceed 0
                '''
                logging.info('decoded file info: ' + output)
                self.decoded_file = output.split()[7].split('/')[-1]
                time.sleep(10)
                self.local_log_path = self.local_log_dir + self.decoded_file
                self.kill_emil_process()
                return True
            else:
                time.sleep(10)
                i = i + 1
                continue
        self.kill_emil_process()
        raise Exception('Check decoded csv file exception!')

    def upload_file_to_emil_server(self, sftp, local_log_path='/Temp/test/ne22264.lcbin',
                                   remote_dir='/Temp/ne22264.lcbin'):
        '''
        Upload files.
        '''
        logging.info('Upload log from ' + local_log_path + ' to ' + remote_dir)
        sftp.put(local_log_path, remote_dir)
        pass

    def download_logs(self, sftp,
                      path_to_log='/sharedvolume/ltetracer/traces/CellTrace \
                       /20201027/2345/ne22264_::ffff:10.97.92.213_15013_20201027T234536_gNB001.lcbin',
                      local_log_path='/Temp/test/ne22264.lcbin'):
        '''
        Download file from server. ':' in file name will be replaced with '_'
        '''
        logging.info('download file from ' + path_to_log + ' to ' + local_log_path)
        self.emil_log_file_name = path_to_log.split('/')[-1].replace(':', '_')
        sftp.get(path_to_log, local_log_path)
        pass

    def transfer_file(self, count=3, ne='22264'):
        '''
        Latest files(default is 3) will be transfered to Emil server. (download to local and upload to Emil server)
        '''
        self.create_new_dir_at_emil_server(dir=self.emil_log_dir)
        trace_file_list = self.list_files(self.ssh_l3dc, ne=ne)
        count = len(trace_file_list) if count > len(trace_file_list) else count
        for index in range(0, count):
            logging.info(trace_file_list[-1])
            file_name = trace_file_list[-1].split('/')[-1].replace(':', '_')
            local_log_path = self.local_log_dir + file_name
            self.download_logs(self.sftp_l3dc, path_to_log=trace_file_list[-1], local_log_path=local_log_path)
            self.local_log_list.append(trace_file_list[-1])
            self.upload_file_to_emil_server(self.sftp_emil, local_log_path=local_log_path,
                                            remote_dir=self.emil_log_dir + self.emil_log_file_name)
            trace_file_list.pop()
        pass

    def create_new_dir_at_emil_server(self, dir=''):
        cmd = 'mkdir ' + dir.replace('/', '\\')
        logging.info('make dir command: ' + cmd)
        stdin, stdout, stderr = self.ssh_emil.exec_command(cmd)
        stdin, stdout, stderr = self.ssh_emil.exec_command('ls -d ' + dir)
        output = stdout.read().decode().replace('\r', '').replace('\n', '')
        logging.info('Show new created directory: ' + output)
        if dir not in output:
            raise Exception('Directory ' + dir + ' creation failure')
        pass

    def list_files(self, ssh, ne='22264', recent_days=2):
        cmd = 'find ' + self.log_dir_l3dc + \
              ' -maxdepth 10 -newermt \"`date -d \'-2 day\' +\"%Y-%m-%d %H:%M:%S\"`" | grep ne' + str(ne) + '_'
        logging.info('list files command: ' + cmd)
        stdin, stdout, stderr = ssh.exec_command(cmd)
        file_list = stdout.read().decode().split('\n')
        file_list.pop()
        logging.info(file_list)
        return file_list


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, filename='emil.log', filemode='w',
                        format='%(asctime)s - %(pathname)s[line:%(lineno)d] - %(levelname)s: %(funcName)s %(message)s.')
    logging.info('')
    logging.basicConfig(level=logging.INFO, filename='emil.log', filemode='a',
                        format='%(asctime)s - %(pathname)s[line:%(lineno)d] - %(levelname)s: %(funcName)s %(message)s.')
    decoder = emil_decoder()

    # trace_file_list=decoder.list_files(decoder.ssh_l3dc)
    # logging.info(trace_file_list[-1])
    # file_name=trace_file_list[-1].split('/')[-1].replace(':','_')
    # local_log_path='/Temp/'+file_name
    # cmd='C:\"Program Files"\Emil\Emil.exe
    # -EmilLogs "C:\Temp\20201029212016_ZxEDpFjL\*" -SubDirs -SackPath LN21.0_Cell_Trace -ToCSV'
    # decoder.ssh_emil.exec_command(cmd)
    # decoder.decode_log(log_dir='/Temp/20201029212016_ZxEDpFjL/')

    # build=decoder.fetch_bts_build(bts_ip='10.97.91.20')
    # decoder.fetch_sack()

    # decoder.download_logs(decoder.sftp_emil, path_to_log=decoder.decoded_file, local_log_path=decoder.local_log_path)

    # decoder.download_logs(decoder.sftp_emil, path_to_log=decoder.
    # decoded_file, local_log_path='C:'+decoder.local_log_dir+decoder.decoded_file.split('/')[-1])

    # decoder.decode_recent_logs(count=6)
    decoder.decode_local_emil_log()
