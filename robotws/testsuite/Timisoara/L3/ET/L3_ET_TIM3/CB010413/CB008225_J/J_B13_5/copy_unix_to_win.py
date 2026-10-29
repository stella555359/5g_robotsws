import os
import paramiko


def copy_files_to_windows1(source_dir_5gm, user, ip, destination_5gm_dir, password):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(hostname=ip, username=user, password=password)

    sftp_client = ssh_client.open_sftp()

    for filename in os.listdir(source_dir_5gm):
        if os.path.isfile(os.path.join(source_dir_5gm, filename)):
            source_path = os.path.join(source_dir_5gm, filename)
            destination_path = os.path.join(destination_5gm_dir, filename)
            sftp_client.put(source_path, destination_path)

    sftp_client.close()
    ssh_client.close()


def copy_files_to_windows2(source_dir_lcbin, user, ip, destination_lcbin_dir, password):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(hostname=ip, username=user, password=password)

    sftp_client = ssh_client.open_sftp()

    for filename in os.listdir(source_dir_lcbin):
        if os.path.isfile(os.path.join(source_dir_lcbin, filename)):
            source_path = os.path.join(source_dir_lcbin, filename)
            destination_path = os.path.join(destination_lcbin_dir, filename)
            sftp_client.put(source_path, destination_path)

    sftp_client.close()
    ssh_client.close()
