import os
import csv
import zipfile
import tarfile
import paramiko
import subprocess

Error_prints = [
    'fatality',
    'FATAL',
    'Error Handler exception report',
    'Please contact the owner of']


def Verify_Biplog_content(Bip_csv_file, column_name, count_match):
    data = []
    rep = []
    non_rep = []
    input_file = open(Bip_csv_file, 'r')
    file = csv.DictReader(input_file)
    print("Checking columns :", column_name)
    print("Checking repetition count :", count_match)
    for col in file:
        temp = []
        for val in column_name:
            temp.append(col[val])
        data.append(temp)
    print(data)

    for value in range(0, len(data)):
        try:
            validate = False
            for check_count in range(1, int(count_match)):
                if data[value] == data[value + check_count]:
                    validate = True
                else:
                    validate = False
            if validate and data[value] not in rep:
                rep.append(data[value])
            elif data[value] not in rep and data[value] not in non_rep:
                non_rep.append(data[value])
        except BaseException:
            pass
    if data[len(data) - 1] not in rep and data[len(data) - 1] not in non_rep:
        non_rep.append(data[len(data) - 1])
    print("Repeated values: ")
    for val in rep:
        print(val)
    print("Non repeated values: ")
    for val in non_rep:
        print(val)
    print("Repeated values count:", len(rep))
    print("Non repeated values count:", len(non_rep))
    if len(rep) > 0:
        return True
    return False


def Validate_syslog(path):
    # Check syslog for DSP crash
    # Input : Syslog file path
    # Output : True or False
    # Usage : Validate_syslog     /home/ute/syslog.log
    print("Checking for Error prints:", Error_prints)
    res = True
    filetype = ".LOG"
    for r, d, f in os.walk(path):
        for file in f:
            file = os.path.join(r, file)
            if filetype in file:
                print("Checking file:", file)
                textFile = open(file, "r")
                for line in textFile:
                    for err in Error_prints:
                        if err in line:
                            res = False
                            print(line)
    if res:
        print("No error prints found")
    return res


def Check_bts_logs(path):
    # Extract syslog file and check
    # Input : Syslog compressed path
    # Output : True or False
    # Usage : Check_bts_logs /home/ute/syslog.tgz
    my_tar = tarfile.open(os.path.join(path, 'syslog_files.tgz'))
    my_tar.extractall(path)
    my_tar.close()
    Val = Validate_syslog(path)
    for file in os.listdir(path):
        if ".LOG" in file:
            os.remove(os.path.join(path, file))
    return Val


def start_proxy(MCG_IP, username, password, path):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(MCG_IP, username=username, password=password)
    cmd = 'cd ' + path + ' && Start proxy.exe'
    print(cmd)
    ssh.exec_command(command=cmd)
    cmd = 'cd ' + path + ' && proxy.exe'
    print(cmd)
    ssh.exec_command(command=cmd)
