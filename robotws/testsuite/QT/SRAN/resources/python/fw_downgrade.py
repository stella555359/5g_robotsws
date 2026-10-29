import requests
import os
import paramiko
import socket
import time

FILES_PATH_LIST = [
    "prepare-firmware-core-manager.sh",
    "prepare-firmware-common.sh",
    "prepare-firmware-manager.sh",
    "prepare-firmware.sh"
]

LOCAL_DIR_PATH = "/home/ute/fw_downgrade/"

HOST = "192.168.255.129"
PORT = 22
USERNAME = "toor4nsn"
PASSWORD = "oZPS0POrRieRtu"


def download_gitlab_file(file_name, dir_path):
    """
    Download file from gitlab repository

    :param file_name: name of the script
    :param dir_path: path to the direcotry where file is downloaded
    """
    gitlab_url = "https://gitlabe1.ext.net.nokia.com"
    project_id = 70751
    branch = "master"
    private_token = "glpat-xDj16Bi1JqJyhztLXt2z"
    url = f"{gitlab_url}/api/v4/projects/{project_id}/repository/files/{file_name}/raw?ref={branch}"
    local_path = dir_path + file_name
    headers = {
        "PRIVATE-TOKEN": private_token
    }

    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        with open(local_path, "wb") as f:
            f.write(response.content)
        print(
            f"Script '{file_name}' has been downloaded successfully to path: '{local_path}'")
    else:
        print("Fail:", response.status_code, response.text)


def remove_known_hosts():
    """
    Remove known hosts from /user/toor4nsn/.ssh
    """
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=HOST, port=PORT, username=USERNAME, password=PASSWORD)
    ssh.exec_command(f"rm /user/toor4nsn/.ssh/known_hosts")
    print("Known Hosts has been removed")
    ssh.close()


def upload_file(file_name, local_dir_path):
    """
    Upload file via SSH

    :param file_name: filanem
    :param local_dir_path: path to the local directory on VM
    """
    local_file = local_dir_path + file_name
    remote_file = "/ffs/run/" + file_name
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    ssh.connect(hostname=HOST, port=PORT, username=USERNAME, password=PASSWORD)

    sftp = ssh.open_sftp()
    sftp.put(local_file, remote_file)
    print(
        f"File '{file_name}' sent to server: {HOST}, to the path: '{remote_file}'")
    ssh.exec_command(f"chmod +x {remote_file}")
    print(f"File '{file_name}' permissions have been changed to: +x\n")
    sftp.close()
    ssh.close()


def check_ssh_connection(host, port=22, timeout=400, retry_interval=40):
    """
    Wait for the host:port to respond

    :param host: host address
    :param port: TCP port
    :param timeout: maximum waiting time(s)
    :param retry_interval: intervals between attempts
    """

    end_time = time.time() + timeout

    while time.time() < end_time:
        try:
            with socket.create_connection((host, port), timeout=5):
                print("Connection estabilished")
                time.sleep(600)
                return True
        except (socket.timeout, ConnectionRefusedError, OSError):
            print(f"Destination Host: {host} Unreachable, trying again...")
            time.sleep(retry_interval)

    print("Timeout – failed to connect at any time")
    return False


def perform_gnb_reboot():
    """
    Perform reboot on gNB

    :param hostname: IP address or hostname server
    :param username: login
    :param password: password
    :param port: port SSH (default: 22)
    """
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(
        hostname=HOST,
        port=PORT,
        username=USERNAME,
        password=PASSWORD
    )

    ssh.exec_command("reboot")
    time.sleep(10)


def run_fw_downgrade_script_with_args(args=None):
    """
    Run a script on a remote server with optional parameters

    :param host: IP address or hostname server
    :param username: login
    :param password: password
    :param script_path: full path to the script on remote server
    :param args: list of additional parameters
    :param port: port SSH (default: 22)
    :return: exit_code, stdout, stderr
    """
    script_path = "/ffs/run/prepare-firmware-core-manager.sh"

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(
        hostname=HOST,
        port=PORT,
        username=USERNAME,
        password=PASSWORD
    )
    ssh.exec_command(f"rm /user/toor4nsn/.ssh/known_hosts")
    print("Known Hosts has been removed")

    if args:
        if isinstance(args, list):
            args_str = " ".join(args)
        else:
            args_str = str(args)
    else:
        args_str = ""

    command = f"bash {script_path} {args_str} -p {PASSWORD}"

    stdin, stdout, stderr = ssh.exec_command(command, timeout=100)

    exit_code = stdout.channel.recv_exit_status()
    output = stdout.read().decode()
    error = stderr.read().decode()

    ssh.close()
    return exit_code, output, error


def upload_fw_downgrade_scripts_on_bts():
    """
    Downlad and upload Firmware Downgrade scripts on bts

    :param LOCAL_DIR_PATH: path to the local directory, where scripts are downloaded
    :param file_name: name of the script, from FILES_PATH_LIST
    """
    os.makedirs(LOCAL_DIR_PATH, exist_ok=True)
    for file_name in FILES_PATH_LIST:
        download_gitlab_file(
            file_name,
            LOCAL_DIR_PATH
        )
    print("\n")
    for file_name in FILES_PATH_LIST:
        upload_file(
            file_name,
            LOCAL_DIR_PATH
        )
