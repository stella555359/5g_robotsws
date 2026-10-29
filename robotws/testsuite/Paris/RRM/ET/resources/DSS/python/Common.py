# -*- coding: utf-8 -*
from taf.transport.ssh import ssh
import logging
import time
import datetime
from datetime import datetime

from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from io import BytesIO
import zipfile
import tarfile
import os
import re
import os.path

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


def get_path_with_dropped_extensions(path):
    extension_regex = r'(.*)((\.tar\.gz)|(\.tar)|(\.zip)|(\.xz)|(\.tgz)|(\.gz)|(\.\w{0,3}))$'
    elements = path.split("/")
    directories = []
    for elem in elements:
        if elem == ".":
            continue
        match = re.search(extension_regex, elem)
        if match:
            directories.append(match.group(1))
        else:
            directories.append(elem)
    return os.path.join(*directories)


def create_directories_from_path(path):
    if not os.path.exists(os.path.dirname(path)):
        try:
            os.makedirs(os.path.dirname(path))
        except OSError as exc:
            if exc.errno != errno.EEXIST:
                raise


def establish_file_extension(name):
    is_zip = re.search(r'.*\.zip$', name)
    is_tar = re.search(r'.*\.tar$', name)
    is_tgz_or_tar_gz = re.search(r'.*\.tar\.gz$', name) or re.search(r'.*\.tgz$', name)
    return is_zip, is_tar, is_tgz_or_tar_gz


def logger_console(msg, prefix=" [Console] ", timestamp=True):
    date = datetime.today().strftime('%Y/%m/%d %H:%M:%S') if timestamp is True else ""
    msg_final = "{}{}{}".format(date, prefix, msg)
    logger.console(msg_final)


def logger_console_info(msg, prefix_console=" [Console] ", prefix_info="[Info] ", timestamp=True):
    logger_console(msg, prefix=prefix_console, timestamp=timestamp)
    logger.info("{}{}".format(prefix_info, msg))


def assert_crash_file_is_present_in_snapshot(snapshot_zip_path, pattern='failurehandler'):
    # pattern1 = r'failurehandler'
    file_list = check_if_file_is_present_in_snapshot(pattern=pattern, file_name=snapshot_zip_path)
    assert len(file_list) > 0, "Did not find any files matching pattern: {}".format(pattern)
    logger_console_info("Saved files from snapshot: {}".format(file_list))
    return file_list


def check_if_file_is_present_in_snapshot(pattern, file_name, file_obj=None, path=None):
    output_dir = BuiltIn().get_variable_value("${testCaseDir}")
    if file_obj is None:
        file_obj = file_name
    file_list = []
    is_zip, is_tar, is_tgz_or_tar_gz = establish_file_extension(file_name)
    try:
        if is_zip:
            with zipfile.ZipFile(file_obj, "r") as file_instance:
                for name in file_instance.namelist():
                    logger.info("ZIP: {} --- {}".format(file_name, name))
                    try:
                        is_zip, is_tar, is_tgz_or_tar_gz = establish_file_extension(name)
                        if is_zip or is_tar or is_tgz_or_tar_gz:
                            inner_compressed_file = BytesIO(file_instance.read(name))
                            matched_files = check_if_file_is_present_in_snapshot(pattern, name,
                                                                                 inner_compressed_file,
                                                                                 path=file_name)
                            file_list.extend(matched_files)
                            logger.info("file_list: {} --- matched_files={}".format(file_list, matched_files))
                    except zipfile.BadZipfile:
                        logger.info("\nBadZipFile: {} BadZipOuterFile: {}".format(inner_compressed_file, name),
                                    also_console=True)
                    logger.info("pattern: {} --- name={}".format(pattern, name))
                    # if re.search(pattern, name):
                    if re.search(r'{}'.format(pattern), name):
                        logger_console_info("Found file: {}".format(os.path.join(path, name)))
                        out_file_path = os.path.join(output_dir, get_path_with_dropped_extensions(path), name)
                        create_directories_from_path(out_file_path)
                        with open(out_file_path, 'wb') as f:
                            f.write(file_instance.read(name))
                        file_list.append(out_file_path)
        elif is_tar or is_tgz_or_tar_gz:
            mode = "r:" if is_tar else "r:gz"
            with tarfile.open(fileobj=file_obj, mode=mode) as file_instance:
                for name in file_instance.getnames():
                    logger.info("TAR: {} --- {}".format(file_name, name))
                    try:
                        is_zip, is_tar, is_tgz_or_tar_gz = establish_file_extension(name)
                        if is_zip or is_tar or is_tgz_or_tar_gz:
                            inner_compressed_file = BytesIO(file_instance.extractfile(name).read())
                            matched_files = check_if_file_is_present_in_snapshot(pattern, name,
                                                                                 inner_compressed_file,
                                                                                 path=file_name)
                            file_list.extend(matched_files)
                    except zipfile.BadZipfile:
                        logger.info("\nBadZipFile: {} BadZipOuterFile: {}".format(inner_compressed_file, name),
                                    also_console=True)
                    # if re.search(pattern, name):
                    if re.search(r'{}'.format(pattern), name):
                        logger_console_info("Found file: {}".format(os.path.join(path, name)))
                        isdir = os.path.isdir(os.path.join(path, name))
                        logger.info("isdir: {} --- name={}".format(isdir, name))
                        if isdir:
                            logger.info("bypass as is not a file: {} --- name={}".format(path, name))
                            continue
                        extension = os.path.splitext(name)[1][1:]
                        if extension == '':
                            logger.info("bypass as is not a file: {} --- name={}".format(path, name))
                            continue
                        out_file_path = os.path.join(output_dir, get_path_with_dropped_extensions(path), name)
                        create_directories_from_path(out_file_path)
                        with open(out_file_path, 'wb') as f:
                            f.write(file_instance.extractfile(name).read())
                        file_list.append(out_file_path)
    except tarfile.ReadError:
        logger.info("{} is empty!".format(file_name))
    return file_list
