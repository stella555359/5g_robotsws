# -*- coding: utf-8 -*-
"""
Author: Sudi Lou
Contacts: sudi.lou@nokia-sbell.com
Description: scripts are used to parse emil log

"""

import logging
import os
import time
from taf.transport.ssh import ssh

sshlib = ssh()


def creat_bat_file(local_file_path, emil_log_name, emil_log_win_dir, emil_tool_win_path, profile_path):
    curr_time = time.strftime("%Y%m%d_%H%M%S", time.localtime())
    bat_file_name = 'emil_parser_' + curr_time + '.bat'
    bat_file_path = os.path.join(local_file_path, bat_file_name)
    csv_file_name = 'emil_parser_output_' + curr_time + '.csv'
    logging.debug('Bat file name is: {}, Bat file path is: {}, and csv file name is: {}'.format(
        bat_file_name, bat_file_path, csv_file_name))
    content = 'start /wait Emil.exe' + ' \"' + emil_log_win_dir + '\\\\' + emil_log_name + '\" ' + \
              '-tocsv onefile -destination' + ' \"' + emil_log_win_dir + '\\\\' + csv_file_name + '\" ' + \
              '-autoclose -Profile SourceProfileUser.ini -ProfilePath ' + '\"' + \
              emil_tool_win_path + '\\\\' + 'profiles' + '\\\\' + profile_path + '\"'
    logging.info('The content of bat file is: {}'.format(content))

    with open(bat_file_path, 'w') as f:
        f.write(content)
    return bat_file_name, csv_file_name


def upload_log_and_bat_files(local_file_path, emil_log_name, bat_file_name, emil_log_dir, connection=None):
    emil_log_local_path = os.path.join(local_file_path, emil_log_name)
    bat_file_local_path = os.path.join(local_file_path, bat_file_name)
    sshlib.upload_file(local_path=emil_log_local_path,
                       remote_path=emil_log_dir + '/' + emil_log_name,
                       connection=connection)
    sshlib.upload_file(local_path=bat_file_local_path,
                       remote_path=emil_log_dir + '/' + bat_file_name,
                       connection=connection)


def convert_log_to_csv(emil_tool_path, emil_log_win_dir, bat_file_name, connection=None):
    """
    this function is used to create one csv file from source log file.

    Parameters:
        emil_tool_path(str): emil tool path.
        emil_log_win_dir(str): emil log win dir.
        bat_file_name(str): the bat file name. Name will be returned from creat_bat_file keyword.
        connection(str): Unique identifier for an emil parser server connections.
    """
    cd_cmd = 'cd ' + '\"' + emil_tool_path + '\"'
    exe_cmd = 'cmd.exe /c ' + '\"' + emil_log_win_dir + '\\\\' + bat_file_name + '\"'
    parse_cmd = cd_cmd + ';' + exe_cmd
    logging.info('the parse cmd is: {}'.format(parse_cmd))
    res = sshlib.execute(parse_cmd, connection=connection)
    logging.debug('the response is: {}'.format(res))


def download_output_file(emil_log_dir, local_file_path, csv_file_name, connection=None):
    sshlib.download_file(remote_path=emil_log_dir + '/' + csv_file_name,
                         local_path=local_file_path + '/' + csv_file_name,
                         connection=connection)


def remove_log_files(emil_log_dir, emil_log_name, bat_file_name, csv_file_name, connection=None):
    remove_emil_log_cmd = 'cd ' + '\"' + emil_log_dir + '\"' + ';' + 'rm -f ' + emil_log_name
    remove_bat_cmd = 'cd ' + '\"' + emil_log_dir + '\"' + ';' + 'rm -f ' + bat_file_name
    remove_csv_file_cmd = 'cd ' + '\"' + emil_log_dir + '\"' + ';' + 'rm -f ' + csv_file_name
    logging.debug('remove_emil_log_cmd is: {}, remove_bat_cmd is:{}, remove_csv_file_cmd is: {}'.
                  format(remove_emil_log_cmd, remove_bat_cmd, remove_csv_file_cmd))
    sshlib.execute(command=remove_emil_log_cmd, connection=connection)
    sshlib.execute(command=remove_bat_cmd, connection=connection)
    sshlib.execute(command=remove_csv_file_cmd, connection=connection)
