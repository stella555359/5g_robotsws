import os
import tarfile

from taf.collectors.btslog import btslog

btslog = btslog()


def start_bts_log(log_name, host_ip=None, user='ute', password='ute'):
    if host_ip:
        executor = {"host": host_ip,
                    "user": user,
                    "password": password}
    btslog.create_btslog_collector(name=log_name,
                                   target_file_name=log_name + '.tgz',
                                   executor=executor if host_ip else None)
    btslog.setup_collectors(log_name)
    btslog.start_collectors(log_name)
    btslog.set_global_alias(log_name)


def stop_and_collect_btslog(log_name, dir_name):
    btslog.stop_collectors(log_name)
    btslog.collect_collectors(log_name, target_dir=dir_name)
    btslog.teardown_collectors(log_name)
    files_dir = dir_name + '/' + log_name
    extract_file(files_dir, log_name)
    return [files_dir + '/' + filename for filename in os.listdir(files_dir)]


def extract_file(dir_name, log_name):
    with tarfile.open(dir_name + '/' + log_name + '.tgz', 'r') as tar:
        tar.extractall(dir_name)
    os.remove(dir_name + '/' + log_name + '.tgz')
