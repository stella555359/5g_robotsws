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
from taf.sw.dcap.rd import rd
import logging
from concurrent.futures import ThreadPoolExecutor
import json

sshlib = ssh()
dcap_object = rd()


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


def creat_bat_file_for_ascii(local_file_path, emil_log_name, emil_log_win_dir, emil_tool_win_path, profile_path):
    curr_time = time.strftime("%Y%m%d_%H%M%S", time.localtime())
    bat_file_name = 'emil_parser_' + curr_time + '.bat'
    bat_file_path = os.path.join(local_file_path, bat_file_name)
    target_file_name = emil_log_name + '.ascii'
    logging.debug('Bat file name is: {}, Bat file path is: {}, and target file name is: {}'.format(
        bat_file_name, bat_file_path, target_file_name))
    content = 'start /wait Emil.exe' + ' \"' + emil_log_win_dir + '\\\\' + emil_log_name + '\" ' + \
              ' -autoclose -Profile SourceProfileUser.ini -ProfilePath ' + '\"' + \
              emil_tool_win_path + '\\\\' + 'profiles' + '\\\\' + profile_path + '\"'
    logging.info('The content of bat file is: {}'.format(content))

    with open(bat_file_path, 'w') as f:
        f.write(content)
    return bat_file_name, target_file_name


def upload_log_and_bat_files(local_file_path, emil_log_name, bat_file_name, emil_log_dir, connection=None):
    emil_log_local_path = os.path.join(local_file_path, emil_log_name)
    bat_file_local_path = os.path.join(local_file_path, bat_file_name)
    sshlib.upload_file(local_path=emil_log_local_path,
                       remote_path=emil_log_dir + '/' + emil_log_name,
                       connection=connection)
    sshlib.upload_file(local_path=bat_file_local_path,
                       remote_path=emil_log_dir + '/' + bat_file_name,
                       connection=connection)


def convert_log_to_csv(emil_tool_path, emil_log_win_dir, bat_file_name, connection=None, timeout=60):
    """
    this function is used to create one csv file from source log file.

    Parameters:
        emil_tool_path(str): emil tool path.
        emil_log_win_dir(str): emil log win dir.
        bat_file_name(str): the bat file name. Name will be returned from creat_bat_file keyword.
        connection(str): Unique identifier for an emil parser server connections.
        timeout(str):(optional) Timeout for the operation default 60s.
    """
    cd_cmd = 'cd ' + '\"' + emil_tool_path + '\"'
    exe_cmd = 'cmd.exe /c ' + '\"' + emil_log_win_dir + '\\\\' + bat_file_name + '\"'
    parse_cmd = cd_cmd + ';' + exe_cmd
    logging.info('the parse cmd is: {}'.format(parse_cmd))
    res = sshlib.execute(parse_cmd, connection=connection, timeout=timeout)
    logging.debug('the response is: {}'.format(res))
    parse_cmd = 'cmd.exe /c ' + '\"' + emil_log_win_dir + '\\\\' + bat_file_name + '\"'
    logging.info('the parse cmd is: {}'.format(parse_cmd))
    res = sshlib.execute(parse_cmd, connection=connection, timeout=timeout)
    logging.debug('the response is: {}'.format(res))


def download_output_file(emil_log_dir, local_file_path, csv_file_name, connection=None):
    sshlib.download_file(remote_path=emil_log_dir + '/' + csv_file_name,
                         local_path=local_file_path + '/' + csv_file_name,
                         connection=connection)


def remove_log_files(emil_log_dir, emil_log_name, bat_file_name, csv_file_name, connection=None, timeout=30):
    remove_emil_log_cmd = 'cd ' + '\"' + emil_log_dir + '\"' + ';' + 'rm -f ' + emil_log_name
    remove_bat_cmd = 'cd ' + '\"' + emil_log_dir + '\"' + ';' + 'rm -f ' + bat_file_name
    remove_csv_file_cmd = 'cd ' + '\"' + emil_log_dir + '\"' + ';' + 'rm -f ' + csv_file_name
    logging.debug('remove_emil_log_cmd is: {}, remove_bat_cmd is:{}, remove_csv_file_cmd is: {}'.
                  format(remove_emil_log_cmd, remove_bat_cmd, remove_csv_file_cmd))
    sshlib.execute(command=remove_emil_log_cmd, connection=connection, timeout=timeout)
    sshlib.execute(command=remove_bat_cmd, connection=connection, timeout=timeout)
    sshlib.execute(command=remove_csv_file_cmd, connection=connection, timeout=timeout)


def get_emil_data_in_csv_via_webemil(file_name, what, connection, **kwargs):
    uploaded_file_info = dcap_object.upload_encoded_file(file_name=file_name, username='ta_user', connection=connection)
    assert uploaded_file_info['operation_status'].lower() == 'success', 'Upload encoded file operation is not success'

    output_file_name_list = []
    file_name_list = [file_name] if isinstance(file_name, str) else file_name
    session_id = uploaded_file_info['session_id']
    data_source_id_list = uploaded_file_info.get('source_ids' if what == 'source' else 'grid_ids', [])
    unique_data_source_id = list(set(data_source_id_list))  # to get a list with unique data source id
    for index, ds_id in enumerate(unique_data_source_id):
        emil_data_rows_in_csv = dcap_object.get_decoded_file_contents_in_csv(session_id=session_id,
                                                                             data_source_id=ds_id,
                                                                             what=what,
                                                                             connection=connection,
                                                                             **kwargs)
        log_path, log_name = os.path.split(file_name_list[index])
        log_name_root, log_name_suffix = os.path.splitext(log_name)
        output_log_name_suffix = '_source_grid.csv' if what == 'source' else '_call_grid.csv'
        output_file_name = log_path + '/' + log_name_root + output_log_name_suffix

        with open(output_file_name, 'w') as file:
            file.write(emil_data_rows_in_csv)

        output_file_name_list.append(output_file_name)

    dcap_object.delete_session_data(session_id=session_id, connection=connection)
    assert len(output_file_name_list) > 0, 'There is no output file generated'

    return output_file_name_list


def save_content_to_json_file(content, file_path):
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(content, f, indent=4, ensure_ascii=False)
