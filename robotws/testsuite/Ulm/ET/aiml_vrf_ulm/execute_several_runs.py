"""
This modules executes several test runs for collecting syslogs for AIML training
"""
import socket
import robot
from robot.api import ExecutionResult
import argparse
import os
from datetime import datetime
import shutil
import zipfile
import paramiko
try:
    from StringIO import StringIO
except ImportError:
    from io import StringIO


def is_robot_testcase_passed(output_xml):
    """This function checks the output_xml, if all tests are passed or not and
    returns the corresponding boolean.

    :param str output_xml: The output xml from robotframework to parse
    :returns: True if all tests are passed, False if not
    """
    result = ExecutionResult(output_xml)
    return all(test.status == "PASS" for test in result.suite.tests)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--tl_config", help="The testline configuration", required=True)
    parser.add_argument("-r", "--runs", help="Execution count", type=int, default=10)
    parser.add_argument("-a", "--actions", help="Number of ue actions (approx)", type=int, default=10)
    parser.add_argument("-s", "--suite", help="The test suite to execute")

    args = parser.parse_args()
    action_count = args.actions
    tl_config = args.tl_config

    print("Executing several robot runs to collect the syslog")
    print("--------------------------------------------------")
    print(f"  tl_config : {tl_config}")
    print(f"       runs : {args.runs}")
    print(f"    actions : {action_count}")
    print("--------------------------------------------------")

    output_path = "/home/ute/rotta/5G_2/aimlulm/Syslogs/"
    if not os.path.exists(output_path):
        print("No rotta mounted! Using tmp path! Don't forget to copy!")
        output_path = "/tmp/results/"
        os.makedirs(output_path, exist_ok=True)
    else:
        pass

    for count in range(args.runs):
        print(f"Executing {count}. run ...")

        target_dir_name = "logs_" + datetime.now().strftime("%d%m%Y_%H%M%S")
        target_dir = os.path.join(output_path, target_dir_name)
        os.makedirs(target_dir, exist_ok=True)

        stdout = StringIO()
        stderr = StringIO()
        robot.run("testsuite/Ulm/ET/aiml_vrf_ulm/perform_handovers.robot",
                  stdout=stdout,
                  stderr=stderr,
                  variablefile=tl_config,
                  loglevel="DEBUG",
                  debugfile="/tmp/robot_debug.log",
                  variable=[f"ai_result_dir:{target_dir}", f"number_of_operations:{action_count}"])

        with open(os.path.join(target_dir, "stdout.txt"), "w") as stdout_file:
            stdout_file.write(stdout.getvalue())

        with open(os.path.join(target_dir, "stderr.txt"), "w") as stderr_file:
            stderr_file.write(stderr.getvalue())

        if is_robot_testcase_passed("output.xml"):
            shutil.copy2("output.xml", target_dir)
            write_meta_info(os.path.join(target_dir, "info.txt"))
            print(f"... test succesfull - copied result files to {target_dir}")
        else:
            print("Test execution failed! - remove result files and abort the loop.")
            shutil.rmtree(target_dir)
            exit(1)

    # upload data to the host "7-15-UTE5Gtest11.ulm.nsn-rdnet.net" with user ute and password UTE.debian12 in case the
    target_host = "7-15-UTE5Gtest11.ulm.nsn-rdnet.net"
    target_user = "ute"
    target_password = "UTE.debian12"
    target_folder = "/mnt/etfiles/users/nuecker/aiml/training_data/"
    if is_host_available(target_host, target_user, target_password):
        print(f"Host {target_host} is reachable. Compressing and uploading data...")
        compress_and_upload_folder(output_path, target_host, target_user, target_password, target_folder)
        print("Upload completed.")
    else:
        print(f"Host {target_host} is not reachable. Skipping upload.")

    print("All done")


def write_meta_info(filename):
    """This functions writes additional information to the given text file.
    The file is overwritten, if it already exists.

    :param str filename: The file to add the aditionam meta information to
    """
    with open(filename, "w") as fp:
        hostname = socket.gethostname()
        fp.write("host: " + str(hostname))


def compress_and_upload_folder(folder, target_host, target_user, target_password, target_folder):
    """
    Compress a folder to a zip file (with timestamp) and upload it to a remote host via SCP (paramiko SFTP).

    :param str folder: Local folder to compress
    :param str target_host: Hostname or IP to upload to
    :param str target_user: Username for SCP
    :param str target_password: Password for SCP
    :param str target_folder: Remote folder to upload the zip file to
    """
    # Create zip filename with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    base_folder = os.path.basename(folder)
    if base_folder:
        zip_filename = f"{base_folder}_{timestamp}.zip"
    else:
        zip_filename = f"results_exec_ute_{timestamp}.zip"

    zip_filepath = os.path.join("/tmp", zip_filename)

    # Compress the folder
    with zipfile.ZipFile(zip_filepath, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(folder):
            for file in files:
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, start=folder)
                zipf.write(abs_path, arcname=rel_path)

    # Upload via paramiko SFTP
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(target_host, username=target_user, password=target_password)
    sftp = ssh.open_sftp()
    try:
        # Ensure target_folder exists on remote
        try:
            sftp.chdir(target_folder)
        except IOError:
            sftp.mkdir(target_folder)
            sftp.chdir(target_folder)
        remote_path = os.path.join(target_folder, zip_filename)
        sftp.put(zip_filepath, remote_path)
    finally:
        sftp.close()
        ssh.close()
        os.remove(zip_filepath)


def is_host_available(host, user, password):
    """
    Checks if the host is reachable via SSH.

    :param str host: Hostname or IP to check
    :param str user: SSH username
    :param str password: SSH password
    :return: True if reachable, False otherwise
    """
    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, username=user, password=password, timeout=5)
        ssh.close()
        return True
    except Exception:
        return False


if __name__ == "__main__":
    main()
