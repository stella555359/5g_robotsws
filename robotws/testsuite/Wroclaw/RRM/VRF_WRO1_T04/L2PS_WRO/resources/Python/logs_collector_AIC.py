# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""
import os
import re
import json
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_gnb import execute_command_on_the_remote
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.file_management import (
    ssh_session, upload_file_to, download_files_from)
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.shell_management import (
    shell_session_vdu, shell_session_vcu, get_vdu_namespace, get_vcu_master_ip)
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.utilities import download_file_from_url


def run_on_vdu(cmd, hostname="192.168.2.124", username="core", password="system123"):
    """Execute command on vDU

    :param cmd: command
    :param hostname: vDU hostname
    :param username: vDU username
    :param password: vDU password
    :return: Tuple(exit_code, output)
    """
    cmd = cmd.strip()
    return execute_command_on_the_remote(cmd, hostname, username, password)


def run_on_vcu(cmd, hostname="etcd-1.ska-rm17-3-27.ska-lab.nsn-rdnet.net", username="core", password="system123"):
    """Execute command on vCU

    :param cmd: command
    :param hostname: vCU hostname
    :param username: vCU username
    :param password: vCU password
    :return: Tuple(exit_code, output)
    """
    cmd = cmd.strip()
    return execute_command_on_the_remote(cmd, hostname, username, password)


def modify_namespace_vdu(path, file_name):
    """Modify namespace in config file

    :param path: path to folder containing vdu_config.ini
    :param file_name: file to change
    :return: nothing
    """
    with shell_session_vdu() as handler:
        container = get_vdu_namespace()
        handler.execute(cmd="cd {} ; sed -i 's/namespace=/namespace={}/' {}".format(path, container, file_name))


def modify_namespace_vcu(path, file_name):
    """Modify namespace in config file

    :param path: path to folder containing vcu_config.ini
    :param file_name: file to change
    :return: nothing
    """
    with shell_session_vdu() as du_handler:
        container = get_vdu_namespace()
    with shell_session_vcu(host=get_vcu_master_ip()) as cu_handler:
        cu_handler.execute(cmd="cd {} ; sed -i 's/namespace=/namespace={}/' {}".format(path, container, file_name))


def get_newest_file_in_directory(directory, ip_addr, username, password):
    """Get newest file in directory

    :param directory
    :param ip_addr: ip_addr where directory is
    :param username: username
    :param password: password
    :return: output with newest file in directory
    """
    with ssh_session(ip_addr, username, password) as ssh:
        output = (ssh.execute('cd {}; ls -t | head -n1'.format(directory)))
        return output


def check_script_is_on_remote(ip_addr, username, password, version, script):
    """Check script is on remote

    :param ip_addr: ip_addr
    :param username: username
    :param password: password
    :param version: version of the script
    :param script: script
    :return: nothing
    """
    with ssh_session(ip_addr, username, password) as ssh:
        path = list()
        path.append(ssh.execute('ls /var/home/core/ | grep kuafu-{}-'.format(version)).strip())
        return ssh.execute('[ -f {}/ ] && echo "Script is on remote." '.format(path, script))


def download_kuafu_scripts(version):
    """Download kuafu scripts

    :param version: version of kuafu script
    :return: nothing
    """
    if os.path.exists('/home/ute/kuafu-{}.tar.gz'.format(version)):
        logger.info('Kuafu-{} already on VM, skipping download.'.format(version))
        return
    download_file_from_url('https://gitlabe2.ext.net.nokia.com/kuafu/kuafu/-/archive/{}/kuafu-{}.tar.gz'.format(
        version, version), '/home/ute/kuafu-{}.tar.gz'.format(version))


def major_minor_micro(version):
    """
    Function that has regex key for checking newest version of kuafu script

    :param version: version of kuafu script
    :return: nothing
    """
    major, minor, micro = re.search(r'(\d+)\.(\d+)\.(\d+)', version).groups()
    return int(major), int(minor), int(micro)


def check_newest_version_kuafu():
    """Check newest version of kuafu script

    :return: newest version of kuafu script
    """
    # CA UTE Token cannot be used for this curl request - 401 Unauthorized (10.03.2026)
    os.system('curl https://gitlabe2.ext.net.nokia.com/api/v4/projects/29103/repository/tags > tags.json')
    tags_list = []
    f = open('tags.json')
    tags = json.load(f)
    for tag in tags:
        tags_list.append(tag['name'])
    version = max(tags_list, key=major_minor_micro)
    return version


def collect_basic_logs_vdu(local_path='/home/ute/results'):
    """
    Gather basic logs: syslog, journal log and startup log in zipped file

    :param local_path: (str) Path to directory where logs will be stored.
    :return: nothing
    """
    try:
        version = check_newest_version_kuafu()
        if check_script_is_on_remote('192.168.2.124', 'core', 'system123', version, '10-vdu-l3call-test.sh'):
            logger.info("Script already is on remote!", also_console=True)
        else:
            download_kuafu_scripts(version)
            path_to_script = ['/home/ute/kuafu-{}.tar.gz'.format(version)]
            upload_file_to('192.168.2.124', 'core', 'system123', path_to_script, '/var/home/core/')
            logger.info("Uploading script to vDU", also_console=True)
            run_on_vdu('tar -xif kuafu-{}.tar.gz'.format(version))

        kuafu_path = '/var/home/core/kuafu-{}'.format(version)
        with ssh_session(ip_addr='192.168.2.124', username='core', password='system123') as ssh:
            modify_namespace_vdu(path='/var/home/core/kuafu-{}/templates'.format(version),
                                 file_name="vdu_config.template")
            logger.info("Starting collecting basic logs from vDU...", also_console=True)
            ssh.execute(
                'cd /var/home/core/kuafu-{}/ ; . 10-vdu-l3call-test.sh ; ./90-collect-vdu-logs.sh'.format(version))

        remote_path = os.path.join(kuafu_path, "logs/vdu", "")
        log_file = get_newest_file_in_directory(remote_path, '192.168.2.124', 'core', 'system123')
        remote_path_to_file = [os.path.join(remote_path, log_file).strip()]
        download_files_from('192.168.2.124', 'core', 'system123', remote_path_to_file, local_path)
        run_on_vdu('rm {}'.format(remote_path_to_file[0]))
        logger.info("Logs collected from vDU.", also_console=True)
    except Exception as err:
        logger.error("Collecting logs failed.")
        raise err


def collect_basic_logs_vcu(local_path='/home/ute/results', vcu_ip='etcd-1.ska-rm17-3-27.ska-lab.nsn-rdnet.net'):
    """
    Gather basic logs: syslog, journal log and startup log in zipped file from vCU

    :param local_path: (str) Path to directory where logs will be stored.
    :param vcu_ip: vCU hostname
    :return: nothing
    """

    try:
        version = check_newest_version_kuafu()

        download_kuafu_scripts(version)
        path_to_script = ['/home/ute/kuafu-{}.tar.gz'.format(version)]
        upload_file_to(vcu_ip, 'core', 'system123', path_to_script, '/var/home/core/')
        logger.info("Uploading script to vCU", also_console=True)
        run_on_vcu('mkdir kuafu_syslog')
        run_on_vcu('tar -xif kuafu-{}.tar.gz -C kuafu_syslog/'.format(version))

        kuafu_path = '/var/home/core/kuafu_syslog/kuafu-{}'.format(version)
        with ssh_session(vcu_ip, username='core', password='system123') as ssh:
            modify_namespace_vcu(path='/var/home/core/kuafu_syslog/kuafu-{}/templates'.format(version),
                                 file_name="vcu_config.template")
            logger.info("Starting collecting basic logs from vCU...", also_console=True)
            ssh.execute(
                'cd /var/home/core/kuafu_syslog/kuafu-{}/ ; . 20-vcu-l3call-test.sh ; ./90-collect-vcu-logs.sh'.format(
                    version))

        remote_path = os.path.join(kuafu_path, "logs/vcu", "")
        log_file = get_newest_file_in_directory(remote_path, vcu_ip, 'core', 'system123')
        remote_path_to_file = [os.path.join(remote_path, log_file).strip()]
        download_files_from(vcu_ip, 'core', 'system123', remote_path_to_file, local_path)
        run_on_vcu('rm -R kuafu_syslog/ ; rm kuafu-{}.tar.gz'.format(version))
        logger.info("Logs collected from vCU.", also_console=True)
    except Exception as err:
        logger.error("Collecting logs failed.")
        raise err
