import os
from subprocess import Popen, PIPE
import shlex


def get_fivegm_files(file_output):
    file_output = str(file_output)
    output_list = file_output.split('\r\n')
    output_list.pop(-1)
    return output_list


def extract_msg_id_with_msg_name_as_NA(log_path, end_file):
    output_msg = ''
    emil_path = get_emil_windows_path()
    emil_path = emil_path.encode('unicode_escape')
    log_path = str(log_path)
    for filename in os.listdir(log_path):
        file, extension = os.path.splitext(filename)
        if extension == '.5gm':
            log_path = log_path.encode('unicode_escape')
            cmd = emil_path + " " + log_path + end_file + " -ToCSV -AutoClose "
            print("cmd: ", cmd)
            Po = Popen(shlex.split(cmd), stdout=PIPE, stderr=PIPE)
            output, error = Po.communicate()
            Po.terminate()
            output_msg += output
    print("output: ", output_msg)
    return output_msg


def get_emil_msg_from_CSV_sCellIndex(log_path):
    log_path = str(log_path)
    log_path = log_path.encode('unicode_escape')
    output = os.popen('grep "sCellIndex 3" /cygdrive/c/robot_script/*.csv').read()
    if bool(output) is False:
        output = os.popen('grep "sCellIndex 2" /cygdrive/c/robot_script/*.csv').read()
    print("output: ", output)
    return output


def get_emil_msg_from_CSV_sCellRelease(log_path):
    log_path = str(log_path)
    log_path = log_path.encode('unicode_escape')
    output = os.popen('grep -iA1 -m1 "sCellToReleaseList" /cygdrive/c/robot_script/*.csv').read()
    print("output: ", output)
    return output


def get_emil_windows_path():
    possible_paths = ['D:\\Program Files', 'C:\\Program Files']
    for path in possible_paths:
        path = os.path.join(path, 'Emil', 'Emil.exe')
        if os.path.exists(path):
            return path
    raise AssertionError("Emil.exe is not found please check")
