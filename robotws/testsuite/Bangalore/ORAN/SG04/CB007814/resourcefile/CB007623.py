#################################
# Author : Rakshith.b@nokia.com
# Python Version : 3
# Maintainer : I_MN_RAN_PZ_BLR_SG6_GMS
#################################

import os
import csv
import sys
import zipfile
import tarfile
import subprocess

Error_prints = [
    "fatality",
    "FATAL",
    "Error Handler exception report",
    "Please contact the owner of",
]

Ignore_prints = ["NON_FATAL", "Unable to parse input tree"]


def Parse_Emil_Csv_File_For_Message(path, msg, msg_col, con_col=0):
    # Validate the message content in EMIL logs
    # Input : Log path <Message1>::<content1>,<content2>|<Message2>::<content1>,<content2> Message_col Content_col
    # Output : Msg content, True/False
    # Usage : /home/ute	  E2setupRequest::ranFunctionID11,ORAN-E2SM-RC-CA|E2setupResponse::ranFunctionID11 3 24
    print("Searching EMIL files in path:", path)
    msg_col = int(msg_col)
    con_col = int(con_col)
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
    message = msg.split("|")
    Messages = []
    status = []
    for i in message:
        Messages.append(i.split("::")[0])
    filetype = ".csv"
    for r, d, f in os.walk(path):
        for file in f:
            if filetype in file:
                status = []
                for i in message:
                    src = csv.reader(
                        open(os.path.join(r, file), "r", encoding="utf-8"))
                    print("\nSearching for message",
                          i.split("::")[0], "in file", file)
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
                                if len(check) != 0:
                                    print("Message content found :\n\t\t",
                                          row[con_col])
                                else:
                                    print("\nNo message content to check")
                                status.append(val)
                                break
                if sorted(Messages) == sorted(status):
                    return True

    print("\nMessages to search :")
    print(Messages)
    print("\nMessages Found :")
    print(status)
    print("\nMessages not found :")
    for i in Messages:
        if i not in status:
            print("\t", i)
    return False


def Validate_syslog(path):
    # Check syslog for DSP crash
    # Input : Syslog file path
    # Output :	 Trur or False
    # Usage : Validate_syslog	  /home/ute/syslog.log
    print("Checking for Error prints:", Error_prints)
    res = []
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
                            res.append(line)
    for line in res:
        for igr in Ignore_prints:
            if igr in line:
                res.remove(line)
    if len(res) != 0:
        for i in res:
            print(res)
        return False
    else:
        print("No error prints found")
        return True


def Convert_pcap_files(file):
    # Check pcap files to txt file
    # Input : Pcap file path
    # Output : None
    # Usage : convert_pcap_files /home/ute/tshark.pcap
    subprocess.call(
        "sudo tshark -V -r " + file + " > " + file.strip(".pcap") + ".txt", shell=True
    )


def Check_bts_logs(path):
    # Extract syslog file and check
    # Input : Syslog compressed path
    # Output : True or False
    # Usage : Check_bts_logs /home/ute/syslog.tgz
    my_tar = tarfile.open(os.path.join(path, "syslog_files.tgz"))
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
    # Usage: Extract_zip	/home/ute/dcap.zip	  /home/ute
    f = zipfile.ZipFile(zip_path, "r")
    f.extractall(Extraction_path)
    print("Zip files extracted to path : " + Extraction_path)


def Get_counter_list(val, counter, cell="Null"):
    # Get counter dist value
    # Input: val,counter,cell
    # Output: cell dist for counter
    # Usage: Get_counter_list	['BTS']['LNBTS-1'][['LNCEL-1']['M5501']   M5501   1
    value = ""
    for i in str(val).split(":"):
        value = value + "['" + (i.strip(" {").strip("'")) + "']"
        if counter in i:
            break
    if cell != "Null":
        for i in value.split("]"):
            if "CEL" in i:
                get = i
                i = i.split("-")[0]
                rep = i + "-" + cell + "'"
        value = value.replace(get, rep)
    return value
