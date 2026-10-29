import os
import subprocess
import paramiko
import time
import logging
from datetime import datetime, timedelta
import threading
import re


def connect_to_uepc(ip, user, password, ssh_port=22, timeout=30):
    """Establish an SSH connection to UEPC with a timeout."""
    print("Connecting to UEPC...")
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh_client.connect(
            ip, username=user, password=password, port=ssh_port, timeout=timeout
        )
        print(f"SSH connection to {ip} successful")
        return ssh_client
    except paramiko.SSHException as e:
        raise Exception(f"SSH connection failed: {str(e)}")
    except Exception as e:
        raise Exception(f"SSH connection error: {str(e)}")


def disconnect_uepc(ssh_client):
    """Close the SSH connection to UEPC."""
    if ssh_client:
        try:
            ssh_client.close()
            print("SSH connection closed successfully")
        except Exception as e:
            print(f"Error closing SSH connection: {str(e)}")
    else:
        print("No SSH client to close")


def run_single_script(ssh_client, path, name, result_list, idx):
    print(f"Running script on remote machine: {path}")
    current_timestamp = datetime.now() + timedelta(hours=8)
    summary_filename = f"Summary_{current_timestamp.strftime('%Y%m%d_%H%M%S')}.log"
    try:
        command = f'cmd /c "cd {path} && bash {name}"'
        print(f"Executing command: {command}")
        stdin, stdout, stderr = ssh_client.exec_command(command)
        print(stdout.read().decode('utf-8').strip())
        while not stdout.channel.exit_status_ready():
            if stdout.channel.recv_ready():
                output = stdout.channel.recv(1024).decode('utf-8')
                print(output, end="")
            if stderr.channel.recv_ready():
                error = stderr.channel.recv(1024).decode('utf-8')
                print(error, end="")
        print(stdout.read().decode('utf-8').strip())
        print(stderr.read().decode('utf-8').strip())
    except Exception as e:
        print(f"Failed to execute script: {e}")
    result_list[idx] = summary_filename


def run_script_via_ssh(ssh_client, script_paths, script_names):
    """Run multiple scripts on the remote machine via SSH with real-time log output."""
    threads = []
    results = [None] * len(script_paths)
    for i, (path, name) in enumerate(zip(script_paths, script_names)):
        t = threading.Thread(
            target=run_single_script, args=(ssh_client, path, name, results, i)
        )
        threads.append(t)
        t.start()
    for t in threads:
        t.join()
    return results


def get_summary_file(ssh_client, remote_directory, local_directory, summary_filename, device_name=None):
    """Retrieve all file names in the specified directory on a Windows machine.
    Optionally rename local file with device_name prefix."""
    try:
        # Create an SFTP client
        sftp = ssh_client.open_sftp()

        # Construct the command to list files in the directory
        command = f'dir "{remote_directory}" /b /a-d'
        print(f"Executing command to list files: {command}")
        stdin, stdout, stderr = ssh_client.exec_command(command)

        # Read the output and split into a list of file names
        raw_output = stdout.read().decode('utf-8').strip()
        print(f"Raw output from dir command:\n{raw_output}")

        # Remove the first line if it contains the directory path
        lines = raw_output.splitlines()
        if lines and ':' in lines[0]:
            lines = lines[1:]

        # Split lines into individual file names, handling tabs and spaces
        file_list = []
        for line in lines:
            file_list.extend([file.strip() for file in line.split() if file.strip()])

        print(f"Files in directory '{remote_directory}': {file_list}")

        # Extract the base name and timestamp from the expected summary file name
        base_name, expected_timestamp = summary_filename.rsplit('_', 1)
        print(f"Base name: {base_name}, Expected timestamp: {expected_timestamp}")
        expected_timestamp = expected_timestamp.split('.')[0].strip()
        print(f"Extracted timestamp: {expected_timestamp}")

        # Prepend the date portion from the base name to the extracted timestamp
        date_portion = base_name.split('_')[1]
        full_timestamp = f"{date_portion}_{expected_timestamp}"
        print(f"Full timestamp for parsing: {full_timestamp}")

        # Generate a range of possible timestamps (±5 seconds)
        possible_timestamps = [
            (
                    datetime.strptime(full_timestamp, '%Y%m%d_%H%M%S') + timedelta(seconds=offset)
            ).strftime('%Y%m%d_%H%M%S')
            for offset in range(-5, 6)
        ]
        print(f"Possible timestamps: {possible_timestamps}")

        # Check for matching files
        for file in file_list:
            if any(f"Summary_{timestamp}.log" == file for timestamp in possible_timestamps):
                remote_file_path = f"{remote_directory}\\{file}"
                if device_name:
                    local_file_path = os.path.join(local_directory, f"{device_name}_{file}")
                else:
                    local_file_path = os.path.join(local_directory, file)
                sftp.get(remote_file_path, local_file_path)
                print(f"File copied successfully: {local_file_path}")
                sftp.close()
                return True

        print(f"Summary file not found: {summary_filename}")
        return False
    except Exception as e:
        print(f"Failed to retrieve file list: {e}")
        return []


def main_execute_traffic_script(ip, user, password, script_path, script_name):
    ssh_client = connect_to_uepc(ip, user, password)
    summary_filenames = run_script_via_ssh(ssh_client, script_path, script_name)
    device_names = []
    for path in script_path:
        norm_path = path.replace('\\', '/').rstrip('/')
        norm_path = re.split(r'[\\/]', norm_path)[-1]
        device_names.append(norm_path)
    for i in range(len(script_path)):
        for _ in range(3):
            check_file_result = get_summary_file(
                ssh_client,
                remote_directory=script_path[i],
                local_directory='./',
                summary_filename=summary_filenames[i],
                device_name=device_names[i]
            )
            if check_file_result:
                break
            print(
                f"Log file not found for script {script_name[i]}. Retrying in 10 seconds..."
            )
            time.sleep(3)
    disconnect_uepc(ssh_client)
    print("SSH connection closed")


if __name__ == "__main__":
    ip = "10.106.243.221"
    user = r"rr3-tester"
    password = "Nokia123!"
    script_path = [
        r"C:\\Users\\rr3-tester\\Desktop\\UE_control\\TA_debug\\UE2",
        r"C:\\Users\\rr3-tester\\Desktop\\UE_control\\TA_debug\\UE3"
    ]
    script_name = [
        "main_controller_mate60pro.sh",
        "main_controller_mate40pro.sh"
    ]
    main_execute_traffic_script(ip, user, password, script_path, script_name)
