import sys
import re
import os
from ftplib import *

regex = r"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"


def check_file(f):
    if f.find(source_filename) > -1:
        global exist
        exist = True


def download_file(source, destination):
    global exist
    source_directory, source_filename = os.path.split(source)
    # destination_directory, destination_filename = os.path.split(destination)
    remote_pwd = ftp.pwd()
    if remote_pwd != source_directory:
        ftp.cwd(source_directory)
    ftp.retrlines('LIST', check_file)
    if exist:
        with open(destination, "wb") as file:
            ftp.retrbinary('RETR ' + source_filename, file.write)


def upload_file(source, destination):
    destination_directory, destination_filename = os.path.split(destination)
    remote_pwd = ftp.pwd()
    if remote_pwd != destination_directory:
        ftp.cwd(destination_directory)
    with open(source, "rb") as file:
        ftp.storbinary('STOR ' + destination_filename, file)


if len(sys.argv) == 5:
    operation = sys.argv[1]
    ip = sys.argv[2]
    source = sys.argv[3]
    destination = sys.argv[4]
    exist = False

    # if operation != '-u' or operation != '-d':
    #     print("Operation flag is not valid")
    #     return 1

    source_filename = os.path.basename(source)
    # source_directory = os.path.dirname(source)
    # destination_filename = os.path.basename(destination)
    # destination_directory = os.path.dirname(destination)

    if re.match(regex, ip) is not None:
        ftp = FTP(ip)
        ftp.login()
        if operation == '-d':
            download_file(source, destination)
        elif operation == '-u':
            upload_file(source, destination)
        else:
            print("Operation flag is not valid")
            sys.exit(0)
        ftp.quit()
        print("Operation done")
    else:
        print("Wrong ip address")
else:
    print("Wrong arguments")
