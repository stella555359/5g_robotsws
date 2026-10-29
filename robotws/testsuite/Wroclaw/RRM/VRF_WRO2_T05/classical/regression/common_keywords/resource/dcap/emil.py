import os
import sys
import subprocess
import shlex


def extract_msg_id_with_msg_name_as_NA(log_path):
    emil_path = get_emil_windows_path()
    emil_path = emil_path.encode('unicode_escape')
    log_path = str(log_path)
    # log_path = log_path.encode('unicode_escape')
    # copy_5gm_files = 'find ' + log_path + ' -iname *.5gm -exec mv {} '+ log_path + ' \;'
    # subprocess.check_output(copy_5gm_files, shell=True)
    output = subprocess.check_output('find . -iname "*.5gm"', shell=True)
    output = output.decode('utf-8')
    for file in output.split('\n'):
        if file != "":
            to_csv = r'"C:\Program Files\Emil\Emil.exe" ' + log_path + file.replace("./", "") + " -ToCSV -AutoClose "
            Po = subprocess.Popen(shlex.split(to_csv), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            print(Po.communicate())
            output, error = Po.communicate()
    csv_output = subprocess.check_output('find . -iname "*.csv"', shell=True)
    csv_output = csv_output.decode('utf-8')
    csv_output = csv_output.split("\n")
    csv_output.pop(-1)
    for csv_file in csv_output:
        if csv_file != "merged.csv":
            merge_csv = "cat " + csv_file + " >> merged.csv"
            subprocess.check_output(merge_csv, shell=True)
    return output.decode('utf-8')


def check_if_message_exist(msg):
    print(msg)
    msg_cnt = os.popen("grep -c -i -z " + "'" + msg + "'" + " ./merged.csv").read()
    print(msg_cnt)
    if msg_cnt == '0\n':
        print("Mesage {} not exits.".format(msg))
        raise "No_message_found_error"


def get_emil_windows_path():
    possible_paths = ['D:\\Program Files', 'C:\\Program Files']
    for path in possible_paths:
        path = os.path.join(path, 'Emil', 'Emil.exe')
        if os.path.exists(path):
            print("FOUND")
            return path
    raise AssertionError("Emil.exe is not found please check")


if __name__ == "__main__":
    if len(sys.argv) > 2:
        check_if_message_exist(sys.argv[2])
    else:
        extract_msg_id_with_msg_name_as_NA(sys.argv[1])
