# -*- coding: utf-8 -*
from taf.transport.ssh import ssh
import logging
import time
import datetime

'''
Author:
Description: This is for common keyword
'''
ssh = ssh()


def is_process_exist(process_name, connection):
    '''
    Check if process exists, if exists return true, otherwise return false
    :param process_name:
    :param connection: connection alias must be given
    :return:
    '''
    cmd_check_process = "ps -ef | grep -v 'grep'|grep {}".format(process_name)
    output_check_process = ssh.execute(
        command=cmd_check_process,
        connection=connection).strip()
    logging.info("Output for checking process: {}".format(output_check_process))
    if len(output_check_process) > 0:
        return True
    else:
        return False


def kill_process_if_exist(process_name, connection):
    '''
    Check if process exists, if exists return true, otherwise return false
    :param process_name:
    :param connection: connection alias must be given
    :return:
    '''
    if is_process_exist(process_name, connection):
        logging.info("Process {} exists on {}, start to kill".format(process_name, connection))
        cmd_check_process = "ps -ef | grep -v 'grep'|grep {}| awk '{print $2}'|xargs kill -9".format(process_name)
        output_check_process = ssh.execute(
            command=cmd_check_process,
            connection=connection).strip()
        logging.info("Output for checking process: {}".format(output_check_process))
        if len(output_check_process) > 0:
            return True
        else:
            return False
    return True


def kill_process_by_name_2(process_name, connection, is_sudo_used_for_kill=True):
    '''

    :param process_name:
    :param connection:
    :param is_sudo_used_for_kill:Default to use sudo for killing the process, if not, you can input it as False
    :return:
    '''
    if is_process_exist(process_name, connection):
        logging.info("Process {} exists on {}, start to kill".format(process_name, connection))
        if is_sudo_used_for_kill:
            cmd_kill_process = "sudo killall {}".format(process_name)
        else:
            cmd_kill_process = "killall {}".format(process_name)
        output_kill_process = ssh.execute(command=cmd_kill_process, connection=connection)
        time.sleep(5)
        if is_process_exist(process_name, connection) is False:
            logging.info("Process {} is killed successfully.".format(process_name))
        else:
            raise Exception("Fail to kill process {}, output value for command {} is {}".format(
                process_name, cmd_kill_process, output_kill_process))
    else:
        logging.info("Process {} is not found, no need to kill".format(process_name))


def kill_process_by_name(process_name, connection, is_sudo_used_for_kill=False, timeout=5):
    """
    Use killall command to kill the process
    :param process_name:
    :param connection:
    :param is_sudo_used_for_kill:Default to use sudo for killing the process, if not, you can input it as False
    :param timeout: timeout for waiting process to be killed. Default to 5 seconds
    :return:
    """
    if is_process_exist(process_name, connection):
        logging.info("Process {} exists on {}, start to kill".format(process_name, connection))
        if is_sudo_used_for_kill:
            cmd_kill_process = "ps -ef | grep -v 'grep' | grep {} | awk '{{print $2}}' | sudo xargs kill -9".format(
                process_name)
        else:
            cmd_kill_process = "ps -ef | grep -v 'grep' | grep {} | awk '{{print $2}}' | xargs kill -9".format(
                process_name)
        output_kill_process = ssh.execute(command=cmd_kill_process, connection=connection)
        end_time = time.time() + int(timeout)
        while time.time() < end_time:
            process_status = is_process_exist(process_name, connection=connection)
            if process_status is False:
                logging.info("Process {} is killed successfully".format(process_name))
                break
            else:
                time.sleep(0.2)
        if process_status is False:
            return True
        else:
            raise Exception("Fail to kill process {} after waiting for {} seconds, "
                            "output value for command {} is {}".format(process_name,
                                                                       timeout, cmd_kill_process,
                                                                       output_kill_process))
            return False
    else:
        logging.info("Process {} is not found, no need to kill".format(process_name))
        return True


def try_command(command, connection, retry_time=1):
    """
    :param command: command for execution
    :param connection: alias for connection
    :param retry_time: time for retry, must be int type
    :return: No return for this method
    """
    i = 0
    while i < retry_time:
        output = ssh.execute(command=command, connection=connection)
        if len(output) != 0:
            i = i + 1
            logging.error("Fail to execute command {}, output message is: {}, Executed time is {}".format(
                command, output, i))
            time.sleep(1)
        else:
            break
    if i == retry_time:
        raise Exception("Already tried {} times for command {} on {}, but still failed. Please check manually".
                        format(i, command, connection))


def start_nc_aasyslog(connection):
    timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    grep_command = 'nc -u -w 100 -l 127.0.0.1 51000 | grep -aE "UlCounterUpdate|SentDataMeasurementCounting" >{}'
    saved_tput_file_path = '/tmp/Tput_DL_UL_{}.txt'.format(timestamp)
    logging.info('save tput file path is:{}'.format(saved_tput_file_path))
    ssh.send_command(command=grep_command.format(saved_tput_file_path), connection=connection)
    return saved_tput_file_path


def start_nc_aasyslog_sav(connection):
    timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    grep_command = 'nc -u -w 100 -l 127.0.0.1 51000 | grep -aE "UlCounterUpdate|SentDataMeasurementCounting" >{} &'
    saved_tput_file_path = '/tmp/Tput_DL_UL_{}.txt'.format(timestamp)
    logging.info('save tput file path is:{}'.format(saved_tput_file_path))
    ssh.send_command(command=grep_command.format(saved_tput_file_path), connection=connection)
