#!/opt/ute/python/bin/python
# -*- coding: utf-8 -*-
"""
    This scripts runs the robot-framework workspace test suites and sent results to reporting portal.

    usage: cli_dcm_pybot_rp.py -a "--variable CONFIGURATION:<testlineConfig> <dataSources>"
    [options]

    <testlineConfig>          : python module import path to testline config
                                directory e.g. Wroclaw.test

    <dataSources>             : the robot test case to be started or the directory
                                containing the robot test cases to be started
                                e.g. test.tsv or test case files path

    Options:

       The same options as robot offers, for detailed information please run
       robot --help or python runRobot --help (or also -h -?).

       If no options are give, the following default settings will be used.
        --loglevel  TRACE
        --monitorcolors on
        --monitormarkers on
except Exception as e:

:copyright: NSB
:author: yaoking, huijun
:contact: yaoking.sui@nokia-sbell.com, huijun.rong@nokia-sbell.com

"""
import argparse
import os
import re
import sys
import time
import paramiko


def execute_this_script(args):
    """
    Execute reporting portal script
    :param args    args: robot command
    """
    execute_robot(args.robot_args)
    execute_reporting_portal(args.robot_args)


def execute_robot(robot_args):
    """
    Execute robot command
    :param robot_args    robot_args: robot command
    """
    try:
        os.system('robot %s' % robot_args)
    except Exception as e:
        print(e)


def add_path(robot_args):
    """
    add path
    :param robot_args    robot_args: robot command
    """
    print(robot_args)
    pattern1 = r'-V\s+(.*config/Beijing/.*/__init__.py)\s+'
    pattern2 = r'--variablefile\s+(\S+config/Beijing/.*/__init__.py)\s+'
    pattern3 = r'-V\s+(.*5_3_UTE5GFT\S+\d+)\s+'
    pattern4 = r'--variablefile\s+(.*config/Beijing/5_3_UTE5G\S+\d+)\s+'
    m1 = re.search(pattern1, robot_args)
    m2 = re.search(pattern2, robot_args)
    m3 = re.search(pattern3, robot_args)
    m4 = re.search(pattern4, robot_args)
    if m1:
        re_config_path = os.path.split(m1.group(1))[0]
    elif m2:
        re_config_path = os.path.split(m2.group(1))[0]
    elif m3:
        re_config_path = m3.group(1)
    elif m4:
        re_config_path = m4.group(1)
    else:
        raise AssertionError('invalid testline info in robot command lines', robot_args)
    cur_path = os.getcwd()
    config_path = re_config_path
    if cur_path not in re_config_path:
        config_path = os.path.join(cur_path, re_config_path)
    print(config_path)
    if config_path not in sys.path:
        sys.path.append(config_path)

    if 'dcm_variable' not in sys.modules:
        dcm_variable = __import__('dcm_variable')
    else:
        eval('import dcm_variable')
        dcm_variable = eval('reload(dcm_variable)')
        execute_reporting_portal(robot_args)
    return dcm_variable


def extend_rp_cmd(rp_cmd, dcm_variable, sw_version, load_prefix):
    """
    add more cmd if needed
    :return:
    """
    rp_cmd += \
        get_sw_version(dcm_variable, sw_version) + \
        get_load_prefix(dcm_variable, load_prefix) + \
        get_qc_file_path(dcm_variable) + \
        get_label_def(dcm_variable)
    print(rp_cmd)
    return rp_cmd


def get_sw_version(dcm_variable, input_sw_version):
    if input_sw_version is not None:
        return " --sw_version " + input_sw_version
    return " --sw_version " + dcm_variable.Reporting_portal['software_version'].strip()


def get_load_prefix(dcm_variable, input_load_prefix):
    if input_load_prefix is not None:
        return " --load_prefix " + input_load_prefix
    return " --load_prefix " + dcm_variable.Reporting_portal['load_prefix'].strip()


def get_qc_file_path(dcm_variable):
    if 'qc' in dcm_variable.Reporting_portal:
        return " -qc " + dcm_variable.Reporting_portal['qc'].strip()
    return ''


def get_label_def(dcm_variable):
    if 'label' in dcm_variable.Reporting_portal:
        return " -l " + dcm_variable.Reporting_portal['label'].strip()
    return ' -l LABEL_Not_defined'


def execute_reporting_portal(robot_args):
    """
    Execute reporting portal command
    :param robot_args    robot_args: robot command
    """
    dcm_variable = add_path(robot_args)
    testing_phase = dcm_variable.Reporting_portal['testing_phase']
    competence_area = dcm_variable.Reporting_portal['competence_area']
    test_line = dcm_variable.Reporting_portal['test_line']
    load_prefix = dcm_variable.Reporting_portal['load_prefix']
    output_dir = re.search(r'\s+?-d\s+?(\S+?)\s+?', robot_args)
    hostname = get_test_line_hostname()
    if hostname != test_line:
        print('get test line name mismatch from config file:{} VS by command {}, '
              'will use {} as testline name'.format(test_line, hostname, test_line))
    sw_version = get_sw_version_with_load_prefix(load_prefix)
    try:
        rp_cmd = 'ute_reporting_portal send -nc -p %s -ca %s -tl %s --type dcm ' % (
                 testing_phase,
                 competence_area,
                 test_line)
        if output_dir is None:
            get_dir = os.getcwd()
        else:
            get_dir = os.path.abspath(output_dir.groups()[0])
        output_file_name = get_output_file_name(get_dir, robot_args)
        output_file_path = os.path.join(get_dir, output_file_name)
        print('output file to upload: {}'.format(output_file_path))
        rp_cmd += ' -ro {}'.format(output_file_path)
        # to avoid McCabe code complexity FAILURES use another function to extend rp_cmd
        rp_cmd = extend_rp_cmd(rp_cmd, dcm_variable, sw_version, load_prefix)
        os.system(rp_cmd)
    except Exception as e:
        print(e)
        raise Exception('load reporting portal fail.')


def get_output_file_name(output_dir, robot_args):
    """Get output xml file name"""
    is_time_stamp_output = re.search(r'\s+(-T|--timestampoutputs)\s+', robot_args)
    if not is_time_stamp_output:
        return 'output.xml'
    file_names = list(filter(lambda item: re.compile(r'^output-.*\.xml$').search(item), os.listdir(output_dir)))
    if file_names:
        file_names.sort()
        return file_names[-1]
    else:
        raise Exception('No output file found.')


def wait_for_condition(condition, check_interval=0):
    """
    Wait for condition to be true, check regularly by check_interval, return False if timeout happens
        condition can be a function or a var which can indicate true or false
    """
    if not check_interval:
        return False
    time.sleep(check_interval)
    return condition()


def ssh_login(proc_ip='', username='', password='', timeout=5):
    """
    ssh_login(proc_ip='', username='', password='', timeout=5)
    """
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    port = 22
    ip = proc_ip
    if ':' in proc_ip:
        ip = proc_ip.split(':')[0]
        port = proc_ip.split(':')[1]
    try:
        ssh.connect(ip, port, username, password, timeout=timeout)
    except Exception as e:
        print(e)
        print('ssh connection setup failed when using: {} and port {}'.format(ip, port))
        ssh = None
    return ssh


def ssh_cmd(ssh=None, cmd_list=None, timeout=5, continue_on_failure=True):
    """
    ssh_cmd(ssh=None, cmd_list=[], timeout=5, continue_on_failure=True)
    """
    if ssh is None or cmd_list is None:
        return False, ""
    if cmd_list is None:
        cmd_list = []
    result = True
    out = ''
    for cmd in cmd_list:
        exit_status, out = execute_ssh_cmd(ssh, cmd, timeout)
        if exit_status != 0:
            result = False
            log = 'Command "%s" execution with exit code %d' % (cmd, exit_status)
            print(log)
            if not continue_on_failure:
                break
    return result, out


def execute_ssh_cmd(ssh_session, cmd, timeout=5):
    """
    execute_ssh_cmd(ssh, cmd, timeout=5)
    """
    out = ''
    exit_status = -9999
    stdin, stdout, stderr = ssh_session.exec_command(cmd, timeout)
    if cmd.strip().endswith('&'):
        print('This is a background command')
        exit_status = 0
    else:
        chan = stdout.channel
        if wait_for_condition(chan.exit_status_ready, 1):
            exit_status = stdout.channel.recv_exit_status()
            try:
                stdoutdata = stdout.read() + stderr.read()
            except Exception as e:
                print('exception found:', e)
                stdoutdata = "----- Something wrong with stdout_err.read ----!!! "
            out = out + stdoutdata.decode()
    return exit_status, out


def get_test_line_hostname():
    """
    get test line host name
    :return: host_name
    """
    ssh = ssh_login('127.0.0.1', 'ute', 'ute')
    result, hostname = ssh_cmd(ssh, ['hostname'])
    return hostname.replace('-', '_').strip()


def get_sw_version_with_load_prefix(load_prefix):
    """
    get_sw_version
    """
    if re.match('DNH.*', load_prefix):
        sw_version = get_lrc_sw_version()
    elif re.match('DNAF.*', load_prefix) or re.match('DF.*', load_prefix):
        sw_version = get_airframe_sw_version()
    elif re.match('SBTS.*', load_prefix):
        sw_version = get_airscale_sw_version()
    else:
        raise Exception('Load prefix not invalid:{}, '
                        'valid load prefix:{}'.format(load_prefix, 'DNHxx, DNAFxx, DFxx'))
    if re.match(load_prefix, sw_version):
        return sw_version
    else:
        raise Exception('Got version {} not match the prefix as setting {}'.format(sw_version, load_prefix))


def get_lrc_sw_version():
    """
    get_lrc_sw_version
    """
    sw_version = None
    get_ver_cmd = 'cd /pns/sdm_selected && ls *.ver'
    shp_ip_list_to_try = ['192.168.129.2', '192.168.130.10']
    for shp_ip in shp_ip_list_to_try:
        try:
            ssh = ssh_login(shp_ip, 'toor4nsn', 'oZPS0POrRieRtu')
            result, out = ssh_cmd(ssh, [get_ver_cmd])
            ssh.close()
            if result:
                sw_version = out[:out.find('.ver')]
                break
        except Exception as e:
            print('exception found:', e)
            pass
    if sw_version is None:
        raise Exception('Could not find .ver file for lrc use ip {} via cmd {}'.format(shp_ip_list_to_try, get_ver_cmd))
    return sw_version


def get_airframe_sw_version():
    """
    get_airframe_sw_version
    """
    sw_version = None
    sdm_default = 'sdm_a'
    shp_ip_list_to_try = ['192.168.129.3', '127.0.0.1:44022']
    for shp_ip in shp_ip_list_to_try:
        try:
            ssh = ssh_login(shp_ip, 'toor4nsn', 'oZPS0POrRieRtu')
            check_sdm_select_cmd = 'cat /vendorFM/resetInfo/sdm_selection.txt'  # AN means sdm_a , BE means sdm_b
            result_sdm_check, out_sdm_check = ssh_cmd(ssh, [check_sdm_select_cmd])
            if not result_sdm_check:
                continue
            if 'BE' in out_sdm_check:
                sdm_default = 'sdm_b'
            get_ver_cmd = 'cd /{} && ls *.ver'.format(sdm_default)
            result, out = ssh_cmd(ssh, [get_ver_cmd])
            ssh.close()
            sw_version = out[:out.find('.ver')]
            break
        except Exception as e:
            print('exception found:', e)
            pass
    if sw_version is None:
        raise Exception('Could not find .ver file on airframe with ip {}'.format(shp_ip_list_to_try))
    return sw_version


def get_airscale_sw_version():
    """
    get_airscale_sw_version
    """
    sw_version = None
    ssh = ssh_login('127.0.0.1', 'ute', 'ute')
    find_as_ver_file = 'cd /opt/ute/airscale_version/ && ls *.ver'  # AN means sdm_a , BE means sdm_b
    result_cmd_exec, as_ver_file = ssh_cmd(ssh, [find_as_ver_file])
    ssh.close()
    if result_cmd_exec:
        sw_version = as_ver_file[:as_ver_file.find('.ver')]
    if sw_version is None:
        raise Exception('Could not find .ver file on /opt/ute/airscale_version/')
    print('sw_version:', sw_version)
    return sw_version


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='run test case and send result to Reporting Portal')
    parser.add_argument('-a', dest="robot_args", required=True,
                        help="arguments for robot")
    parser.set_defaults(func=execute_this_script)
    cl_args = parser.parse_args()
    cl_args.func(cl_args)
