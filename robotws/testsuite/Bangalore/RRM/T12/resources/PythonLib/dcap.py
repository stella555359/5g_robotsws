import os
import zipfile
import tarfile
import subprocess
from SSHLibrary import SSHLibrary
import paramiko
import json

Error_prints = [
    'fatality',
    'FATAL',
    'Error Handler exception report',
    'Please contact the owner of']


def Parse_Emil_Json_File_For_Message(json_file_path, pattern):
    # Load JSON data from the file
    with open(json_file_path, 'r') as file:
        data = json.load(file)
    # Function to recursively search for the pattern and extract "time" field

    def search_pattern(data, pattern, matched_rows):
        if isinstance(data, dict):
            for key, value in data.items():
                if isinstance(value, str) and pattern.lower() in value.lower():
                    time = find_timestamp(data)
                    if time:
                        matched_rows.append((time, data))  # Append the time and matched row
                search_pattern(value, pattern, matched_rows)
        elif isinstance(data, list):
            for item in data:
                search_pattern(item, pattern, matched_rows)
    # Function to retrieve timestamp from JSON

    def find_timestamp(data):
        if isinstance(data, dict):
            for key, value in data.items():
                if key.lower() == 'time':
                    return value
                elif isinstance(value, (dict, list)):
                    result = find_timestamp(value)
                    if result:
                        return result
        elif isinstance(data, list):
            for item in data:
                result = find_timestamp(item)
                if result:
                    return result
        return None
    # Initialize list to store matched rows
    matched_rows = []
    # Search for the pattern in the JSON data and extract "time" field
    search_pattern(data, pattern, matched_rows)
    # If pattern found, return the matched rows
    if matched_rows:
        return matched_rows
    else:
        return None


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


def Extract_zip(zip_path, Extraction_path):
    # Extract the required file from dcap
    # Input: zip file path,Extraction path
    # Output: None
    # Usage: Extract_zip    /home/ute/dcap.zip    /home/ute
    f = zipfile.ZipFile(zip_path, 'r')
    f.extractall(Extraction_path)
    print("Zip files extracted to path : " + Extraction_path)


def Extract_zip_up(zip_path, extraction_path):
    """
    Extracts the required file from a zip archive.

    Args:
        zip_path (str): Path to the zip file.
        extraction_path (str): Path to extract the files to.

    Returns:
        str: Path to the extracted .5gm file.
    """
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extraction_path)

    extracted_file = None
    for root, dirs, files in os.walk(extraction_path):
        for file in files:
            if file.endswith(".5gm"):
                extracted_file = os.path.join(root, file)
                break
        if extracted_file:
            break

    if extracted_file:
        print("Zip files extracted to path:", extraction_path)
        return extracted_file
    else:
        print("No .5gm file found after extraction.")
        return None


# Example usage:
# extracted_file_path = Extract_zip("/home/ute/dcap.zip", "/home/ute")
# print("Extracted .5gm file path:", extracted_file_path)
