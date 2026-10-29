#################################
# Author : Rakshith.b@nokia.com
# Python Version : 3.6
#################################

import os
import zipfile
import tarfile
import subprocess
from SSHLibrary import SSHLibrary
import paramiko

Error_prints = [
    'fatality',
    'FATAL',
    'Error Handler exception report',
    'Please contact the owner of']


def Parse_Emil_Csv_File_For_Message(path, msg, log='EMIL'):
    # Validate the message content in EMIL logs
    # Input : Log path, <Message1>::<content1>,<content2>|<Message2>::<content1>,<content2>
    # Output : Msg content, True/False
    # Usage : /home/ute   E2setupRequest::ranFunctionID 11,ORAN-E2SM-RC-CA|E2setupResponse::ranFunctionID 11
    messages = msg.split("|")
    status = []
    if log == 'EMIL':
        filetype = ".csv"
    else:
        filetype = ".pcap"
    End_msg = '}"'
    for r, d, f in os.walk(path):
        for file in f:
            if filetype in file:
                file = os.path.join(r, file)
                if log != "EMIL":
                    subprocess.call(
                        'sudo tshark -V -r ' +
                        file +
                        ' > ' +
                        file.replace(
                            'pcap',
                            'txt'),
                        shell=True)
                    file = file.replace('pcap', 'txt')
                src = open(file).readlines()
                remove_list = []
                for i in messages:
                    print(
                        "\nSearching for message",
                        i.split("::")[0],
                        "in file",
                        file)
                    Flag = False
                    try:
                        val, strings = i.split("::")
                        check = strings.split(",")
                    except BaseException:
                        val = i
                        check = []
                    if log == 'EMIL':
                        val = '"' + val + '"'
                    for j in range(0, len(src)):
                        temp = []
                        if (val in src[j] and log == 'EMIL') or (
                                val in src[j] and 'Frame' in src[j]
                                and 'captured' in src[j] and log == 'tshark'):
                            print("\n\tMessage found:\n\t", src[j])
                            for k in range(j, len(src)):
                                temp.append(src[k])
                                if End_msg in src[k] or src[k] in [
                                        '\n', '\r\n']:
                                    break
                            count = []
                            for item in range(0, len(temp)):
                                for m in check:
                                    name = m.split(",")
                                    for n in name:
                                        if n in temp[item]:
                                            print("\tMessage content found :")
                                            count.append(n)
                                            print(temp[item])
                            if all([item in count for item in check]):
                                status.append(i)
                                remove_list.append(i)
                                print("\nMessage: \n")
                                for text in temp:
                                    print(text.strip('\n'))
                                break
                for rem in remove_list:
                    messages.remove(rem)
                if sorted(msg.split("|")) == sorted(status):
                    return True
    print("\nBelow messages or it's content not found :")
    for i in set(msg.split("|")) - set(status):
        print("\t", i)
    return False


def findEmilFileFromList(FileList):
    File_Emil_Content = []
    for file_item in FileList:
        if (".emil" in file_item) or (".5gm" in file_item):
            File_Emil_Content.append(file_item)
    return File_Emil_Content


def Validate_syslog(path):
    # Check syslog for DSP crash
    # Input : Syslog file path
    # Output :   Trur or False
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
