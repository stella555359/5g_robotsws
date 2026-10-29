from taf.transport.ssh import ssh
import sys
import os
import re

csn = ssh()


def monitor_and_download_file(ip, username, password, remotePath, localPath):
    command = "ls -lt " + remotePath + "|grep -v grep| awk '{print $9}'"
    try:
        csn.connect_to(hostname=ip, username=username, password=password, alias='COAM')
        while True:
            filename = csn.execute(command=command, connection='COAM', timeout=60)
            filePath = filename.rsplit("\r\n")
            file = re.search(r"No such file or directory", filePath[0], flags=0)
            if not file:
                csn.download_file(remote_path=filePath[0], local_path=localPath, connection='COAM', timeout=60)
                break
    finally:
        csn.disconnect(connection='COAM')


if __name__ == "__main__":
    ip = sys.argv[1]
    username = sys.argv[2]
    password = sys.argv[3]
    remotePath = sys.argv[4]
    localPath = sys.argv[5]
    print("monitor and download file...")
    monitor_and_download_file(ip, username, password, remotePath, localPath)
