# -*- coding: utf-8 -*-

from ftplib import FTP
import logging
import os
import sys
from hzdu1_fv_get_env_info import get_bts_version

ip = '10.108.231.196'
user = 'tdlte'
password = 'ftp@2019'


def log_in():
    ftp = FTP()
    ftp.connect(host=ip)
    ftp.login(user=user, passwd=password)
    # ftp.set_debuglevel(2)
    logging.info(ftp.getwelcome())
    return ftp


def upload_file(ftp, localFile):
    flag = False
    ftp.cwd('temp_log')
    d_list = ftp.nlst()
    if 'ta_log' not in d_list:
        ftp.mkd('ta_log')
    ftp.cwd('ta_log')
    uf = open(localFile, 'rb')
    bufsize = 1024
    filepath, remoteFile = os.path.split(localFile)
    try:
        ftp.storbinary('STOR ' + remoteFile, uf, bufsize)
        version = get_bts_version()
        str = '='*(len("File has upload success:ftp://10.108.231.196/temp_log/ta_log/{}".format(remoteFile))+5)
        logging.warning("{}\n"
                        "sw_version:{}\n"
                        "File has upload success:ftp://10.108.231.196/temp_log/ta_log/{}\n"
                        "{}\n".format(str, version, remoteFile, str))
        flag = True
    except Exception as result:
        logging.info("File Upload Fail!:{}".format(remoteFile))
    if flag:
        os.remove(localFile)
        logging.info("Remove local file:{}".format(localFile))


def teardown(ftp):
    ftp.quit()
    ftp.close()


def upload_file_to_ftp(localFile):
    ftp = log_in()
    upload_file(ftp, localFile)
    teardown(ftp)


if __name__ == '__main__':
    upload_file_to_ftp(sys.argv[1])
