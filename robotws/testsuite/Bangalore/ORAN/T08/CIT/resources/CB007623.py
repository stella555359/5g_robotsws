#################################
# Author : Rakshith.b@nokia.com
# Python Version : 3.6
#################################

import os
import sys
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

Exclude_prints = [
    'FATAL: Module nft_counter not found in directory /lib/modules/6.1.67-621a03426d-nokia_sm_x86']


def Parse_Emil_Csv_File_For_Message(msg_col, con_col, path, msg):
    # Validate the message content in EMIL logs
    # Input : Log path, <Message1>::<content1>,<content2>|<Message2>::<content1>,<content2>
    # Output : Msg content, True/False
    # Usage : /home/ute   E2setupRequest::ranFunctionID
    # 11,ORAN-E2SM-RC-CA|E2setupResponse::ranFunctionID 11
    maxInt = sys.maxsize
    while True:
        # decrease the maxInt value by factor 10
        # as long as the OverflowError occurs.

        try:
            csv.field_size_limit(maxInt)
            break
        except OverflowError:
            maxInt = int(maxInt / 10)
    csv.field_size_limit(maxInt)
    messages = msg.split("|")
    print(msg_col, con_col)
    status = []
    Messages = []
    for i in messages:
        Messages.append(i.split("::")[0])
    filetype = ".csv"
    for r, d, f in os.walk(path):
        for file in f:
            if filetype in file:
                src1 = open(os.path.join(r, file), 'r', encoding="utf-8")
                src = csv.reader(src1)
                status = []
                for i in messages:
                    print(
                        "\nSearching for message",
                        i.split("::")[0],
                        "in file",
                        file)
                    try:
                        val, strings = i.split("::")
                        check = strings.split(",")
                    except BaseException:
                        val = i.split("::")[0]
                        check = []
                    for row in src:
                        temp = []
                        if val in str(row[msg_col]):
                            print("Message found :\n\t", row[msg_col])
                            for content in check:
                                if content in str(row[con_col]):
                                    if content not in temp:
                                        temp.append(content)
                        if sorted(temp) == sorted(check):
                            print("Message content found :\n\t\t", row[con_col])
                            status.append(val)
                            break
                if sorted(Messages) == sorted(status):
                    return True
    print("\nMessages to search :")
    print(sorted(Messages))
    print("\nMessages Found :")
    print(sorted(status))
    print("\nMessages not found :")
    for i in Messages:
        if i not in status:
            print("\t", i)
    return False


def Validate_syslog(path):
    # Check syslog for DSP crash
    # Input : Syslog file path
    # Output :   Trur or False
    # Usage : Validate_syslog     /home/ute/syslog.log
    print("Checking for Error prints:", Error_prints)
    print("checking for exclude prints:", Exclude_prints)
    res = True
    filetype = ".LOG"
    for r, d, f in os.walk(path):
        for file in f:
            if file.lower().endswith(filetype):
                file_path = os.path.join(r, file)
                print("Checking file:", file_path)
                try:
                    # Open the file and read it line by line
                    with open(file_path, "r") as textFile:
                        for line in textFile:
                            # Skip lines containing any message in the Exclude_prints list
                            if any(exclude in line for exclude in Exclude_prints):
                                continue
                            # Check for each error message in the line
                            if any(err in line for err in Error_prints):
                                res = False
                                print("Error found:", line.strip())
                                # Break out of the line loop for this file as we have found an error
                                break
                except IOError as e:
                    print(f"Error opening or reading file {file_path}: {e}")
                    res = False  # Consider file read errors as potential problems
                    continue  # Continue with the next file

    if res:
        print("No error prints found")
    return res


def convert_pcap_files(file):
    # Check pcap files to txt file
    # Input : Pcap file path
    # Output : None
    # Usage : convert_pcap_files /home/ute/tshark.pcap
    subprocess.call(
        'sudo tshark -V -r ' +
        file +
        ' > ' +
        file.strip('.pcap') +
        '.txt',
        shell=True)


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


def Extract_zip(zip_path, Extraction_path):
    # Extract the required file from dcap
    # Input: zip file path,Extraction path
    # Output: None
    # Usage: Extract_zip    /home/ute/dcap.zip    /home/ute
    f = zipfile.ZipFile(zip_path, 'r')
    f.extractall(Extraction_path)
    print("Zip files extracted to path : " + Extraction_path)


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
