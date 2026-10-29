# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Xiang Liang
:contact: liang.xiang@nokia-sbell.com
"""
import os
import re
import time
import datetime
import fnmatch
import paramiko
import logging
from .pcmd_compare_check import compare_pcmd, change_unicode
from .find_save_pcmd import get_pcmd_record, find_record, conver_timStr_to_time, download_log_from_pcmd


class rrm_pcmd(object):
    logger = logging.getLogger('RRM')
    logger.setLevel(logging.DEBUG)
    console_handler = logging.StreamHandler()
    format = logging.Formatter("%(asctime)s |%(name)s|%(levelname)5s|%(message)s")
    console_handler.setFormatter(format)
    logger.addHandler(console_handler)

    def __init__(self):
        self.logger = rrm_pcmd.logger
        self.MakeAnaModiBearer = 1
        self.DelBearer = 2
        self.MME = '10_107_182_64'
        self.PCMD_LOG_EXPIR_TIMER = 5

    def make_ue_bearer(self, UE_IMSI, ue_ip, QCI, QCI_server, bear_action, bear_ip='10.56.221.181'):
        command = "ls -l"
        username = 'tpaadmin'
        password = 'Transformer&Wisdom123'
        pcrf_server = paramiko.SSHClient()
        pcrf_server.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        pcrf_server.connect(bear_ip, 22, username, password)
        time.sleep(2)
        if int(bear_action) is self.MakeAnaModiBearer:
            if int(QCI) > 4:
                command = ("./" + self.MME + "sbear -i " + UE_IMSI + " -a " + ue_ip + " -q " + QCI
                           + " -d 21000000 -u 10000000 -s " + QCI_server)
            if int(QCI) <= 4:
                command = ("./" + self.MME + "sbear -i " + UE_IMSI + " -a " + ue_ip + " -q " + QCI
                           + " -d 20000 -u 10000 -s " + QCI_server)
        if int(bear_action) is self.DelBearer:
            self.logger.info('type imsi = {} is waiting delete'.format(UE_IMSI))
            self.logger.info('type QCI = {} is waiting delete'.format(QCI))
            command = "./" + self.MME + "sbear -i " + UE_IMSI + " -q " + QCI + " -de"
        stdin, stdout, stderr = pcrf_server.exec_command(command)
        result = stdout.read()
        self.logger.info('result = {}'.format(result))
        self.logger.info('Delete bear command :{}'.format(command))
        time.sleep(3)
        pcrf_server.close()

    def clear_pcmd_record(self, filepath):
        filenames = os.listdir(filepath)
        if not filenames:
            self.logger.info('No PCMD record need to be cleared,path=%s' % filepath)
        else:
            for filename in filenames:
                if filename[-8:] == 'pcmd.txt':
                    record_file = filepath + '/' + filename
                    pcmd_record_saved_log = filepath + '/PcmdRecordbak.log'
                    if os.path.getsize(record_file):
                        with open(record_file, 'r') as f1:
                            for lines in f1.readlines():
                                with open(pcmd_record_saved_log, 'a') as f2:
                                    f2.write(lines)
                            with open(pcmd_record_saved_log, 'a') as f3:
                                f3.write("\r\n")
                        self.logger.info('PCMD record in %s has been saved to PcmdRecordbak.log' % filename)
                        with open(record_file, 'w') as f:  # clear PCMD record
                            f.truncate()
        return

    def check_pcmd_record(self, filepath, input_pcmd_array, **kwargs):
        for key, value in kwargs.items():
            print(key, value)
        # input_pcmd_array=[[PRIMARY,90,CPLANE,0,58],[PRIMARY,88,CPLANE,0,1]]
        check_flag = False
        pcmd_record = get_pcmd_record(filepath)
        self.logger.info("pcmd_record: %s" % pcmd_record)
        if pcmd_record == [] or pcmd_record is False:
            self.logger.info('No record input for check')
            return check_flag
        else:
            self.logger.info("One pcmd record for check")
            self.logger.info("sum_list: %s" % input_pcmd_array)
            input_pcmd_array = change_unicode(input_pcmd_array)
            check_flag = compare_pcmd(input_pcmd_array, pcmd_record[0])
            return check_flag

    def save_pcmd_log(self, gummei, local_log_dir, t_detach, cell_id, record_type, **kwargs):
        self.logger.info("start Save_pcmd_log")
        if kwargs:
            check_dic = kwargs
            self.logger.info("check_dic=%s" % check_dic)
        else:
            self.logger.info('Please input at least one filter')
            return
        time.sleep(100)  # wait last pcmd record file generate on npc
        self.clear_pcmd_record(local_log_dir)
        t_now = datetime.datetime.now()
        deadline = t_now + datetime.timedelta(minutes=self.PCMD_LOG_EXPIR_TIMER)
        self.logger.info('save_pcmd_log => deadline = %s' % deadline)
        succ_found = False
        download_times = 0
        while datetime.datetime.now() < deadline:
            self.logger.info('datetime.datetime.now()=%s' % t_now)
            download_log_from_pcmd(gummei, local_log_dir, record_type)
            download_times += 1
            find_result = 0
            new_cellidhex = hex(int(cell_id))
            self.logger.info('changenew_cellid = %s' % new_cellidhex)
            exe_path = os.path.dirname(os.path.realpath(__file__))
            sh_command = 'cd ' + exe_path + ' && bash ../../shell/pcmd.sh ' + local_log_dir + ' ' + new_cellidhex[2:]
            val = os.system(sh_command)
            for root, subdirs, files in os.walk(local_log_dir):
                file_pcmd = fnmatch.filter(files, '[2]*pcmd.gz')  # 2017-02-24.10:44.+0800.MMEpcmd.gz
                self.logger.info('file_pcmd=%s' % file_pcmd)
                list_len = 0
                for correct_file in file_pcmd:
                    list_len += 1
                    digit_fn = re.findall('\\d+', correct_file)  # digit_fn=['2017', '02', '25', '09', '41', '0800']
                    str_fname = (''.join(digit_fn))[0:12]  # format: 201702250821
                    t_pcmd = conver_timStr_to_time(str_fname)
                    self.logger.info("pcmd_time:%s" % t_pcmd)
                    self.logger.info("attach_time:%s" % t_detach)
                    if t_pcmd >= t_detach:  # t_pcmd=2017-02-25 12:43  ; t_detach=2017-02-25 14:58
                        find_result = find_result + find_record(os.path.join(root, correct_file), cell_id, check_dic)
                        self.logger.info("%s PCMD record collected!" % find_result)
                    os.remove(os.path.join(root, correct_file))
            if find_result >= 1:
                succ_found = True
                self.logger.info('%s times download' % download_times)
                break
            time.sleep(60)
        if not succ_found:
            self.logger.info('timer expired,no pcmd log generated!!!')

    def get_sys_time(self):
        now = datetime.datetime.now()
        now = now.strftime('%Y-%m-%d %H:%M')
        self.logger.info('system_time1=%s' % now)
        return now
