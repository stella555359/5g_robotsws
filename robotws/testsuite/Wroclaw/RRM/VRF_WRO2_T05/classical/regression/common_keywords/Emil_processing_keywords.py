import os
from subprocess import Popen, PIPE
import shlex


def extract_msg_id_with_msg_name_as_NA(log_path, end_file):
    emil_path = get_emil_windows_path()
    emil_path = emil_path.encode('unicode_escape')
    log_path = str(log_path)
    log_path = log_path.encode('unicode_escape')
    cmd = emil_path + " " + log_path + end_file + " -ToCSV -AutoClose "
    print("cmd: ", cmd)
    Po = Popen(shlex.split(cmd), stdout=PIPE, stderr=PIPE)
    output, error = Po.communicate()
    Po.terminate()
    print("output: ", output)
    return output


def get_emil_msg_from_CSV(log_path):
    log_path = str(log_path)
    log_path = log_path.encode('unicode_escape')
    output = os.popen('grep freqPriorityListNR /cygdrive/c/robot_script/*.csv').read()
    print("output: ", output)
    return output


def get_emil_msg_from_CSV_sCellIndex(log_path):
    log_path = str(log_path)
    log_path = log_path.encode('unicode_escape')
    output = os.popen('grep "sCellIndex 2" /cygdrive/c/robot_script/*.csv').read()
    print("output: ", output)
    return output


def get_emil_windows_path():
    possible_paths = ['D:\\Program Files', 'C:\\Program Files']
    for path in possible_paths:
        path = os.path.join(path, 'Emil', 'Emil.exe')
        if os.path.exists(path):
            return path
    raise AssertionError("Emil.exe is not found please check")
