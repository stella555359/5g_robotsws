import paramiko
from datetime import datetime
from robot.api import logger

"""
Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    MN_RAN_RD_VRF_WRO3_1
...  *****************
...  Basic information
...  *****************
...  New scenario introduced based on https://jiradc.ext.net.nokia.com/browse/MNRCA-67334
...  Pronto related with EDA action: 03275309
...  ******************
...  History of changes
...  ******************
...  05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-574 - resource creation
"""


def get_log_file_list():
    host = "192.168.255.129"
    port = 22
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"
    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, port, username, password)
        command = (
            '''find / -type f -name "*.log" ! -path "/tmp/*" 2>/dev/null | '''
            '''while read -r file; do '''
            '''file_date=$(date -r "$file" "+%Y.%m.%d %H:%M:%S" 2>/dev/null); '''
            '''if [ ! -z "$file_date" ]; then '''
            '''echo "$file_date $(ls -lh "$file" | awk '{print $5}') $file"; '''
            '''fi; done | sort -r'''
        )
        (stdin, stdout, stderr) = ssh.exec_command(command)
        output = stdout.readlines()
        print(output)
        return output
    except Exception as e:
        return f"Error during SSH connection: {str(e)}"


def convert_to_mb(size, unit):
    """Convert size from various units to megabytes."""
    units = {"": 1 / (1024 * 1024), "K": 1 / 1024, "M": 1, "G": 1024}
    return size * units[unit]


def parse_line(line):
    """Parse a line of data and return file path and its size in MB."""
    try:
        parts = line.strip().split()
        timestamp = datetime.strptime(' '.join(parts[:2]), '%Y.%m.%d %H:%M:%S')
        size_part = parts[2]
        if size_part[-1].isdigit():
            size = float(size_part)
            unit = ""
        else:
            size = float(size_part[:-1])
            unit = size_part[-1]
        file_path = ' '.join(parts[3:])
        return file_path, convert_to_mb(size, unit), timestamp
    except ValueError as e:
        logger.warn(f'Error while parsing a line: {line}. Error: {str(e)}')
        return None


def compare_file_sizes(first_list, second_list):
    first_files = {file_path: (size, timestamp) for file_path, size, timestamp in map(parse_line, first_list)}
    second_files = {file_path: (size, timestamp) for file_path, size, timestamp in map(parse_line, second_list)}
    all_files_sorted = sorted(set(first_files) | set(second_files))
    test_failed = False
    for file_path in all_files_sorted:
        if file_path in first_files and file_path in second_files:
            size_diff = second_files[file_path][0] - first_files[file_path][0]
            time_diff = second_files[file_path][1] - first_files[file_path][1]
            msg = f'File {file_path} detected with a size of {second_files[file_path][0]:.3f}MB.' \
                  f' Size increase: {size_diff:.3f}MB, within: {time_diff}.'
            logger.trace(msg)
            logger.console(msg)
            if second_files[file_path][0] >= 1 or first_files[file_path][0] >= 1:
                test_failed = True
        elif file_path in second_files:
            msg = f'File {file_path} detected with a size of {second_files[file_path][0]:.3f}MB.' \
                  f' Size increase: unknown, within: unknown (the file was created after the first checkpoint).'
            logger.trace(msg)
            logger.console(msg)
            if second_files[file_path][0] >= 1:
                test_failed = True
        elif file_path in first_files:
            msg = f'File {file_path} detected with a size of {first_files[file_path][0]:.3f}MB,' \
                  f' but it was deleted during the test suite execution.'
            logger.trace(msg)
            logger.console(msg)
            if first_files[file_path][0] >= 1:
                test_failed = True
    if test_failed:
        logger.warn('At least one file *.log with a size >= 1MB was detected.')
        raise Exception('Test failure due to excessive file size.')
