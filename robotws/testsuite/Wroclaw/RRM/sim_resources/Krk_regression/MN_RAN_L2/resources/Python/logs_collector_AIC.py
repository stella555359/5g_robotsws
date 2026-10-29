# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska, Beata Kapusta
:maintainer:  Adrianna Pienkowska, Beata Kapusta
:contact: adrianna.pienkowska@nokia.com, beata.kapusta@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
import os
import re
import json
import subprocess

from robot.api import logger

from file_management import (
    ssh_session, upload_file_to, download_files_from)
from utilities import (
    download_file_from_url, logger_console_info, logger_warning)
from common_gnb import execute_command_on_the_remote
from shell_management import (
    shell_session_vdu, shell_session_vcu, get_vdu_namespace, get_vdu_connection_params,  get_vcu_connection_params)


def run_on_vdu(cmd, hostname=None, username=None, password=None):
    """Execute command on vDU

    :param cmd: command
    :param hostname: vDU hostname
    :param username: vDU username
    :param password: vDU password
    :return: Tuple(exit_code, output)
    """
    if not all([hostname, username, password]):
        hostname, username, password = get_vdu_connection_params()
    cmd = cmd.strip()
    return execute_command_on_the_remote(cmd, hostname, username, password)


def run_on_vcu(cmd, hostname=None, username=None, password=None):
    """Execute command on vCU

    :param cmd: command
    :param hostname: vCU hostname
    :param username: vCU username
    :param password: vCU password
    :return: Tuple(exit_code, output)
    """
    if not all([hostname, username, password]):
        hostname, username, password = get_vcu_connection_params()
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
        handler.execute(cmd=f"cd {path} ; sed -i 's/namespace=.*/namespace={container}/' {file_name}")


def modify_build_vdu(path, file_name, build):
    """Modify build in config file

    :param path: path to folder containing vdu_config.ini
    :param file_name: file to change
    :param build: SW build e.g. 0.300.4386 or vDUCNF22R4_0.300.7022
    :return: nothing
    """
    build = build.split('_')[-1]
    with shell_session_vdu() as handler:
        handler.execute(cmd="cd {} ; sed -i 's/build_version=.*/build_version={}/' {}".format(path, build, file_name))


def modify_namespace_vcu(path, file_name):
    """Modify namespace in config file

    :param path: path to folder containing vcu_config.ini
    :param file_name: file to change
    :return: nothing
    """
    with shell_session_vdu() as du_handler:
        container = get_vdu_namespace()
    with shell_session_vcu() as cu_handler:
        cu_handler.execute(cmd=f"cd {path} ; sed -i 's/namespace=.*/namespace={container}/' {file_name}")


def modify_build_vcu(path, file_name, build):
    """Modify build id in config file

    :param path: path to folder containing vdu_config.ini
    :param file_name: file to change
    :param build: SW build e.g. 0.300.4386 or vCUCNF22R4_0.300.7022
    :return: nothing
    """
    build = build.split('_')[-1]
    with shell_session_vcu() as handler:
        handler.execute(cmd="cd {} ; sed -i 's/build_version=.*/build_version={}/' {}".format(path, build, file_name))


def modify_trunk_build_str(cu_build=None, du_build=None):
    cu_build = 'vCUCNF00' + cu_build[10:] if '_0.250' in cu_build else cu_build
    du_build = 'vDUCNF00' + du_build[10:] if '_0.300' in du_build else du_build
    return cu_build, du_build


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
    os.system('curl https://gitlabe2.ext.net.nokia.com/api/v4/projects/29103/repository/tags > tags.json')
    tags_list = []
    f = open('tags.json')
    tags = json.load(f)
    for tag in tags:
        tags_list.append(tag['name'])
    version = max(tags_list, key=major_minor_micro)
    return version


def collect_basic_logs_vdu(du_sw, local_path='/home/ute/results'):
    """
    Gather basic logs: syslog, journal log and startup log in zipped file

    :param du_sw: (str) vDU SW build e.g. 0.300.4386 or vDUCNF22R4_0.300.7022
    :param local_path: (str) Path to directory where logs will be stored.
    :return: nothing
    """
    try:
        vdu_ip, vdu_user, vdu_pass = get_vdu_connection_params()
        version = check_newest_version_kuafu()
        if check_script_is_on_remote(vdu_ip, vdu_user, vdu_pass, version, '10-vdu-l3call-test.sh'):
            logger.info("Script already is on remote!", also_console=True)
        else:
            download_kuafu_scripts(version)
            path_to_script = ['/home/ute/kuafu-{}.tar.gz'.format(version)]
            upload_file_to(vdu_ip, vdu_user, vdu_pass, path_to_script, '/var/home/core/')
            logger.info("Uploading script to vDU", also_console=True)
            run_on_vdu('tar -xif kuafu-{}.tar.gz'.format(version))

        kuafu_path = '/var/home/core/kuafu-{}'.format(version)
        with ssh_session(ip_addr=vdu_ip, username=vdu_user, password=vdu_pass) as ssh:
            modify_namespace_vdu(
                path='/var/home/core/kuafu-{}/templates'.format(version), file_name="vdu_config.template")
            modify_build_vdu(
                path='/var/home/core/kuafu-{}/templates'.format(version), file_name="vdu_config.template", build=du_sw)
            logger.info("Starting collecting basic logs from vDU...", also_console=True)
            ssh.execute(
                'cd /var/home/core/kuafu-{}/ ; . 10-vdu-l3call-test.sh ; ./90-collect-vdu-logs.sh'.format(version))

        remote_path = os.path.join(kuafu_path, "logs/vdu", "")
        log_file = get_newest_file_in_directory(remote_path, vdu_ip, vdu_user, vdu_pass)
        remote_path_to_file = [os.path.join(remote_path, log_file).strip()]
        download_files_from(vdu_ip, vdu_user, vdu_pass, remote_path_to_file, local_path)
        run_on_vdu('rm {}'.format(remote_path_to_file[0]))
        logger.info("Logs collected from vDU.", also_console=True)
    except Exception as err:
        logger.error("Collecting logs failed.")
        raise err


def collect_basic_logs_vcu(cu_sw, local_path='/home/ute/results'):
    """
    Gather basic logs: syslog, journal log and startup log in zipped file from vCU

    :param cu_sw: (str) vDU SW build e.g. 0.300.4386 or vCUCNF22R4_0.300.7022
    :param local_path: (str) Path to directory where logs will be stored.
    :return: nothing
    """

    try:
        vcu_ip, vcu_user, vcu_pass = get_vcu_connection_params()
        version = check_newest_version_kuafu()

        download_kuafu_scripts(version)
        path_to_script = ['/home/ute/kuafu-{}.tar.gz'.format(version)]
        upload_file_to(vcu_ip, vcu_user, vcu_pass, path_to_script, '/var/home/core/')
        logger.info("Uploading script to vCU", also_console=True)
        run_on_vcu('mkdir kuafu_syslog')
        run_on_vcu('tar -xif kuafu-{}.tar.gz -C kuafu_syslog/'.format(version))

        kuafu_path = '/var/home/core/kuafu_syslog/kuafu-{}'.format(version)
        with ssh_session(vcu_ip, username=vcu_user, password=vcu_pass) as ssh:
            modify_namespace_vcu(
                path='/var/home/core/kuafu_syslog/kuafu-{}/templates'.format(version), file_name="vcu_config.template")
            modify_build_vcu(
                path='/var/home/core/kuafu_syslog/kuafu-{}/templates'.format(version),
                file_name="vcu_config.template", build=cu_sw)
            logger.info("Starting collecting basic logs from vCU...", also_console=True)
            ssh.execute(
                f'cd /var/home/core/kuafu_syslog/kuafu-{version}/ ; . 20-vcu-l3call-test.sh ; ./90-collect-vcu-logs.sh'
            )

        remote_path = os.path.join(kuafu_path, "logs/vcu", "")
        log_file = get_newest_file_in_directory(remote_path, vcu_ip, vcu_user, vcu_pass)
        remote_path_to_file = [os.path.join(remote_path, log_file).strip()]
        download_files_from(vcu_ip, vcu_user, vcu_pass, remote_path_to_file, local_path)
        run_on_vcu('rm -R kuafu_syslog/ ; rm kuafu-{}.tar.gz'.format(version))
        logger.info("Logs collected from vCU.", also_console=True)
    except Exception as err:
        logger.error("Collecting logs failed.")
        raise err


def disable_gnb_sosreport():
    logger_console_info('Disabling gNB SosReport')
    gnb_bip_str = 'kill_bip_pcap_process "$BTS_IP_1"'
    gnb_conf_str = 'find_conf "$BTS_IP_1" GNB'
    gnb_pcap_str = 'kill_pcap_process "$BTS_IP_1"'
    gnb_log_str_tabbed = '\'  get_bts_log\''
    gnb_conf_str_tabbed = '\'  find_conf $BTS_IP GNB\''
    mirroring_str_tabbed = '\'  disablePortMirroring "$BTS_IP_1"\''

    echo_null = '\'echo ""\''
    cmds = [
        ['sed', '-i', f's/{gnb_log_str_tabbed}/{echo_null}/g', '/opt/wts/latest/sosReport_ASIK_ASIL.sh'],
        ['sed', '-i', f's/{gnb_conf_str_tabbed}/{echo_null}/g', '/opt/wts/latest/sosReport_ASIL/sosReport_ASIL.sh'],
        ['sed', '-i', 's/GNB_LOG=true/GNB_LOG=false/', '/opt/wts/latest/sosReport_ASIL/sosReport_ASIL.sh'],
        ['sed', '-i', 's/GNB_LOG=true/GNB_LOG=false/', '/opt/wts/latest/sosReport_ASIL/startTest_ASIL.sh'],
        ['sed', '-i', 's/GNB_LOG=true/GNB_LOG=false/', '/opt/wts/latest/sosReport_ASIL/stopTest_ASIL.sh'],
        ['sed', '-i', f's/{gnb_conf_str}/{echo_null}/g', '/opt/wts/latest/sosReport_ASIL/startTest_ASIL.sh'],
        ['sed', '-i', f's/{gnb_conf_str}/{echo_null}/g', '/opt/wts/latest/sosReport_ASIL/stopTest_ASIL.sh'],
        ['sed', '-i', f's/{gnb_pcap_str}/{echo_null}/g', '/opt/wts/latest/sosReport_ASIL/stopTest_ASIL.sh'],
        ['sed', '-i', f's/{gnb_bip_str}/{echo_null}/g', '/opt/wts/latest/sosReport_ASIL/stopTest_ASIL.sh'],
        ['sed', '-i', f's/{mirroring_str_tabbed}/{echo_null}/g', '/opt/wts/latest/sosReport_ASIL/stopTest_ASIL.sh']
    ]
    for cmd in cmds:
        result = subprocess.run(cmd, shell=False, cwd='/opt/wts/latest/', stderr=subprocess.PIPE)
        if result.stderr:
            logger_warning(f'\nFailed to modify: {cmd[-1]}\nCMD:{cmd[2]}\nRESULT: {result.stderr}')


def collect_sosreport_aic(local_path='/home/ute/results'):
    logger.info('Collecting SosReport', also_console=True)
    cmds = [['./sosReport_ASIK_ASIL.sh', '-c', '-s'], 'mv SosReport* {}/'.format(local_path)]
    for cmd in cmds:
        subprocess.call(cmd, shell=True, cwd='/opt/wts/latest/', stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
