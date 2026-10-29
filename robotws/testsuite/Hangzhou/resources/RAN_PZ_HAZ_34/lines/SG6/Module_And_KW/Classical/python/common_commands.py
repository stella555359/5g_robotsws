# -*- coding: utf-8 -*
from taf.transport.ssh import ssh
import logging
import time
from robot.libraries.OperatingSystem import OperatingSystem
import openpyxl
from openpyxl import load_workbook
from robot.libraries.BuiltIn import BuiltIn
import os

"""
Author: Yang Mengli
Contacts: mengli.yang@nokia-sbell.com
Description: This is for common keywords
"""
ssh = ssh()


def is_process_exist(process_name, connection, is_checking_on_windows=False):
    """
    Check if process exists, if exists return true, otherwise return false
    :param process_name:
    :param connection: connection alias must be given
    :param is_checking_on_windows: Default to support for linux, if set to True, then cygwin must be installed
    :return:
    """
    if is_checking_on_windows:
        cmd_check_process = "ps -Wef | grep -v 'grep'|grep '{}'".format(process_name)
    else:
        cmd_check_process = "ps -ef | grep -v 'grep'|grep '{}'".format(process_name)
    logging.debug("Execute command: {}".format(cmd_check_process))
    output_check_process = ssh.execute(
        command=cmd_check_process,
        connection=connection).strip()
    logging.info("Output for checking process: {}".format(output_check_process))
    if len(output_check_process) > 0:
        return True
    else:
        return False


def kill_process_by_name(process_name, connection, is_sudo_used_for_kill=True, timeout=5):
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
        else:
            raise Exception("Fail to kill process {} after waiting for {} seconds, "
                            "output value for command {} is {}".format(process_name,
                                                                       timeout, cmd_kill_process,
                                                                       output_kill_process))
    else:
        logging.info("Process {} is not found, no need to kill".format(process_name))


def get_file_names_under_directory(directory, connection, file_indicator='*'):
    """
    Description: Get all file names from an existing directory
    :param directory: folder path, example input can be: /XXX/XXX
    :param file_indicator: regular expression to identify the files. Default to list all files.
                           Example input: 5GTtiTrace.bin.[0-9]*{}.csv
    :param connection:
    :return: Return a list which includes all file names
    """
    cmd_list_file_name = "cd {};ls {}".format(directory, file_indicator)
    output = ssh.execute(cmd_list_file_name, connection=connection).strip()
    logging.debug("cmd:{}, output:{}".format(cmd_list_file_name, output))
    list_file_names = []
    if output.find('No such file or directory') == -1:
        list_file_names = output.split()
    else:
        logging.info("No file found under folder {}".format(directory))
    return list_file_names


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


def is_file_empty(file_path, connection):
    """
    Description: Verify if file content is empty. Will return True if file content is empty, otherwise return False
    :param file_path:
    :param connection:
    :return:
    """
    is_file_exists = ssh.file_exists(remote_path=file_path, connection=connection)
    if is_file_exists:
        cmd_check_if_file_not_empty = "test -s {} && echo True||echo False".format(file_path)
        is_file_not_empty = ssh.execute(command=cmd_check_if_file_not_empty, connection=connection).strip()
        if is_file_not_empty == "True":
            return False
        else:
            return True
    else:
        logging.error(msg="File {} does not exist on {}".format(file_path, connection))
        return True


def get_nidd_counters(file_dir):
    """Get all counter id from excel file(it is defined from nidd and user input the excel).
      *AUTHOR* mengli.yang@nokia-sbell.com
    """
    os_obj = OperatingSystem()
    file_list = os_obj.list_directory(file_dir)
    counter_id_list = []
    measurement_id_list = []
    for file_name in file_list:
        file_location = file_dir + "/" + file_name
        workbook = openpyxl.load_workbook(file_location, read_only=True)
        worksheet = workbook.get_sheet_by_name("counters")
        for row in worksheet.iter_rows():
            for cell in row:
                counter_id_list.append(cell.value)
                measurement_id = cell.value[0:6]
                measurement_id_list.append(measurement_id)
    return list(set(measurement_id_list)), list(set(counter_id_list))


def write_counters_to_excel(file_path, counter_value_list):
    """ Write counters id to excel file in one column.
      *AUTHOR* mengli.yang@nokia-sbell.com
    """
    wb = openpyxl.Workbook()
    sheet = wb.active
    i = 0
    for value in counter_value_list:
        i = i + 1
        c1 = sheet.cell(row=i, column=1)
        c1.value = value
    wb.save(file_path)


def get_Column_Values(filepath, sheet, column):
    """
    get all values of selected column.
    *AUTHOR* mengli.yang@nokia-sbell.com
    :param filepath: path of excel. eg. excel.xlsx
    :param sheet: sheet name.
    :param column: int type, selected column.

    *RETURN VALUE*
    string

    Example:
    | ${column_data}  | get_Column_Values | filepath | counter | 1 |
    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    rows = ws.max_row
    column_data = []
    for i in range(1, rows + 1):
        cellvalue = ws.cell(row=i, column=int(column)).value
        if cellvalue is not None:
            column_data.append(cellvalue)
    return column_data


def get_Row_Values(filepath, sheet, row):
    """
    get all values of selected row.
    *AUTHOR* mengli.yang@nokia-sbell.com
    :param filepath: path of excel. eg. excel.xlsx
    :param sheet: sheet name.
    :param row: int type, selected row.

    *RETURN VALUE*
    string

    Example:
    | ${row_data}  | get_Row_Values | filepath | counter | 1 |
    """
    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    columns = ws.max_column
    row_data = []
    for i in range(1, columns + 1):
        cellvalue = ws.cell(row=int(row), column=i).value
        if cellvalue is not None:
            row_data.append(cellvalue)
    return row_data


def get_CellValue(filepath, sheet, row, column):
    """
    get cell vaule based on row and column.
    *AUTHOR* mengli.yang@nokia-sbell.com
    :param filepath: path of excel. eg. excel.xlsx
    :param sheet: sheet name.
    :param row: int type, which row.
    :param column: int type, which column.

    *RETURN VALUE*
    string

    Example:
    | ${cellvalue}  | get_CellValue | filepath | counter | 1 | 1 |
    """

    wb = load_workbook(filepath)
    ws = wb.get_sheet_by_name(sheet)
    cellvalue = ws.cell(row=int(row), column=int(column)).value
    return cellvalue


def get_sheet_names(filepath):
    """
    get all sheet names.
    *AUTHOR* mengli.yang@nokia-sbell.com
    :param filepath: path of excel. eg. excel.xlsx

    *RETURN VALUE*
    string

    Example:
    | ${sheet_names}  | get_sheet_names | filepath |
    """

    wb = load_workbook(filepath)
    sheet_names = wb.sheetnames
    return sheet_names


def get_a_file(log_path, file_name):
    """get a file name with absolute path,Raise exception if failed to generate a file name.
    *AUTHOR* mengli.yang@nokia-sbell.com
    history change, <date>,<who>,<what and how>
    | Input Parameters  | Man. | Description |
    | path            | Yes  |   list type, e.g, ["folder1", "fold2", "filename.txt"] |
    *RETURN VALUE*
    string

    Example:
    | ${file_name}  | get_a_file | folder1 | folder2 | filename.txt |
    """
    builtin_obj = BuiltIn()
    rtn = ""
    try:
        file_abs_path = os.path.join(log_path, file_name)
        builtin_obj.log(file_abs_path, "INFO")
        file_dir, file_name = os.path.split(file_abs_path)
        if not os.path.exists(file_dir):
            os.makedirs(file_dir)
        if not os.path.exists(file_abs_path):
            os.system("touch %s" % file_abs_path)
        rtn = file_abs_path
    except Exception as e:
        builtin_obj.log(e, "ERROR")
    if len(rtn) == 0:
        raise RuntimeError("get_a_file(): fail!!")
    return rtn


def get_a_directory(log_path, directory_name):
    """get a directory name with absolute path,Raise exception if failed to generate a folder name.

    *AUTHOR* mengli.yang@nokia-sbell.com
     history change, <date>,<who>,<what and how>

    | Input Parameters  | Man. | Description |
    | path            | Yes  |   list type, e.g, ["folder1", "fold2"] |

    *RETURN VALUE*
    string

    Example:
    | ${folder_name}  | get_a_directory | folder1 | folder2 |
    """
    builtin_obj = BuiltIn()
    rtn = ""
    try:
        builtin_obj.log("Start get a directory", "INFO")
        builtin_obj.log("general log path" + log_path, "INFO")
        abs_path = os.path.join(log_path, directory_name)
        builtin_obj.log(abs_path, "INFO")
        if not os.path.exists(abs_path):
            os.makedirs(abs_path)
        rtn = abs_path
    except Exception as e:
        builtin_obj.log(e, "ERROR")
    if len(rtn) == 0:
        raise RuntimeError("get_a_directory(): fail!!")
    return rtn
