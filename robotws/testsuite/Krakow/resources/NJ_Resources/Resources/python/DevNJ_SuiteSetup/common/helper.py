import os
import re
import time
import subprocess

from robot.api import logger


def run(cmd):
    logger.info(cmd)
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
    stdout = []
    while True:
        line = p.stdout.readline()
        stdout.append(line)
        logger.info(line)

        # poll has a bug: http://bbs.chinaunix.net/thread-3775926-1-1.html
        if line == "" and p.poll() is not None:
            break

    return "".join(stdout)


def get_files(path, suffix=""):
    if not os.path.exists(path):
        return None

    file_lst = list()
    get_dir_files(file_lst, path)
    if suffix == "":
        return file_lst

    files = list()
    for file in file_lst:
        _, ext = os.path.splitext(file)
        if suffix == ext:
            files.append(file)

    return files


def get_dir_files(file_list, path):
    files = os.listdir(path)
    for file in files:
        item = os.path.join(path, file)
        if os.path.isdir(item):
            get_dir_files(file_list, item)
        else:
            file_list.append(os.path.join(path, file))


def wait_device_pingable(host, times, peroid):
    i = 0
    while i < times:
        i += 1
        output = subprocess.Popen(
            ["sudo", "ping", "-c", "1", host], stdout=subprocess.PIPE, universal_newlines=True
        ).communicate()[0]
        logger.info(output)
        if "bytes from" in output:
            logger.info("ping is reachable.")
            return True
        time.sleep(peroid)

    logger.info("ping is unreachable.")
    return False


def wait_device_portopen(host, port, times, peroid):
    i = 0
    while i < times:
        i += 1
        output = run("nmap -Pn -open {} -p {}".format(host, str(port)))
        if "open" in output:
            logger.info("{} port {} is opened.".format(host, port))
            return True
        time.sleep(peroid)

    logger.info("{} port {} is closed.".format(host, port))
    return False


def is_4g_of_nsa(product, type):
    if "5G" in product.upper() and type.upper() == "LTE":
        return True

    return False


def is_rfs_of_nsa(product, type, labels):
    if is_4g_of_nsa(product, type) and "rfs_all" in labels:
        return True

    return False


def get_os_info():
    os_info = {}
    res = os.popen('hostnamectl ;echo exit_code:$?').read()
    exit_code = None
    if res:
        regix_ = re.search(r'exit_code:(\d+)', res, re.I | re.M)
        if regix_:
            exit_code = regix_.groups()[0]
    if exit_code == "0":
        for i in res.split('\n'):
            tmp = i.split(':')
            os_info[tmp[0].strip().replace(' ', '_').lower()] = tmp[-1].strip()
    return os_info
