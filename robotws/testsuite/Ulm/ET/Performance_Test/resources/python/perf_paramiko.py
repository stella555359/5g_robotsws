import paramiko
import fnmatch
import os
import pathlib


from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()

console_debug = False
_DEFAULT_GNB_IP = '192.168.255.129'


def setup_connection(source_ip=_DEFAULT_GNB_IP, source_username='toor4nsn', source_password='oZPS0POrRieRtu'):
    # Establishing an SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(source_ip, username=source_username, password=source_password)
    return ssh


def run_smod_cmd(command):
    run_cmd(command, source_ip=_DEFAULT_GNB_IP,
            source_username='toor4nsn', source_password='oZPS0POrRieRtu')


def run_cmd(command, source_ip, source_username, source_password):
    with setup_connection(source_ip=source_ip, source_username=source_username,
                          source_password=source_password) as ssh:
        rbi.log(f"[paramiko] [{source_ip}] {command}", console=console_debug)
        stdin, stdout, stderr = ssh.exec_command(command)
        for line in stdout.readlines():
            rbi.log(f"    - {line}")
        rbi.log(f"    -{stdin}, {stdout}, {stderr}", level="DEBUG")


def transfer_file_to_smod(local, remote):
    transfer_file_to(local, remote, source_ip=_DEFAULT_GNB_IP,
                     source_username='toor4nsn', source_password='oZPS0POrRieRtu')


def transfer_file_from_smod(remote, local):
    transfer_file_from(remote, local,
                       source_ip=_DEFAULT_GNB_IP, source_username='toor4nsn', source_password='oZPS0POrRieRtu')


def transfer_file_to(
        local,
        remote, source_ip=_DEFAULT_GNB_IP, source_username='toor4nsn', source_password='oZPS0POrRieRtu'):

    with setup_connection(
            source_ip=source_ip, source_username=source_username, source_password=source_password) as ssh:
        with ssh.open_sftp() as sftp:
            parent_dir = str(pathlib.Path(local).parent)
            fname = str(pathlib.Path(local).name)
            for filename in os.listdir(parent_dir):
                if fnmatch.fnmatch(filename, fname):
                    full_path = str(pathlib.Path(
                        parent_dir).joinpath(filename))
                    rbi.log(f"[paramiko] Transfering to: {source_ip}:{remote} <= {full_path}",
                            console=console_debug)
                    sftp.put(full_path, f"{remote}")


def transfer_file_from(
        remote, local,
        source_ip=_DEFAULT_GNB_IP, source_username='toor4nsn', source_password='oZPS0POrRieRtu'):

    with setup_connection(
            source_ip=source_ip, source_username=source_username, source_password=source_password) as ssh:
        with ssh.open_sftp() as sftp:
            parent_dir = str(pathlib.Path(remote).parent)
            fname = str(pathlib.Path(remote).name)
            for filename in sftp.listdir(parent_dir):
                if fnmatch.fnmatch(filename, fname):
                    full_path = str(pathlib.Path(
                        parent_dir).joinpath(filename))
                    rbi.log(f"[paramiko] Transfering from: {source_ip}:{full_path} => {local}/{filename}",
                            console=console_debug)
                    sftp.get(full_path, f"{local}/{filename}")
