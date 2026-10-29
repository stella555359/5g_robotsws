from datetime import datetime
from string import punctuation
from xml.dom import minidom
import os.path
import paramiko
import re
import socket
import subprocess
import sys

log_server_ip = '10.43.254.141'
log_server_user = 'ute'
log_server_pass = 'Secur!ty@123'
log_server_path = '/home/ute_logs'
log_to_upload = ['log.html', 'output.xml', 'report.html', 'BTSSM_CLI_Tool_Logs']


###############################################################################

###############################################################################
def start():
    create_script_debug_log()
    global tl_name
    tl_name = socket.gethostname()
    global tc_name
    tc_name = get_tc_name()
    tc_name = replace_punctuation(tc_name)

    global log_dir_path
    log_dir_path = get_log_dir_path()
    upload_logs(log_dir_path)
    log_server_url = 'http://' + log_server_ip + re.match(log_server_path + r'(.*)', log_dir_path, re.I).group(1)
    print('log_server_url = ' + log_server_url)

    if len(sys.argv[1:]) > 0:
        run_command(sys.argv[1] + ' --log_link ' + log_server_url)


def create_script_debug_log():
    script_log = open('script_log.txt', 'w')
    script_log.close()


def get_time():
    return datetime.now().strftime('%Y-%m-%d %H:%M:%S   ')


def get_log_dir_path():
    ssh_client = open_ssh_to_log_server()
    stdout = ssh_client.exec_command('python /home/ute_logs/log_upload_server.py ' + tl_name + ' ' + tc_name)[1]
    for line in stdout:
        matchObj = re.match(r'Path:(.*)', line, re.I)
        if matchObj:
            write_debug_log("LOG PATH CREATED" + matchObj.group(1), "SUCCESS")
            return matchObj.group(1)
            ssh_client.close()
    write_debug_log("Log path creation failure", "ERROR")
    ssh_client.close()
    exit()


def open_ssh_to_log_server():
    try:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(log_server_ip, username=log_server_user, password=log_server_pass)
        return ssh_client
    except Exception as e:
        write_debug_log("Unable to open SSH to log server", "ERROR")
        exit()


def get_tc_name():
    if os.path.isfile("output.xml"):
        try:
            xml_file = minidom.parse('output.xml')
        except Exception as e:
            write_debug_log("Error parsing output.xml file", "ERROR")
            exit()
        for xml_elem_test in xml_file.getElementsByTagName('test'):
            return xml_elem_test.attributes['name'].value
        write_debug_log("Unable to find testcase name from output.xml file", "ERROR")
    else:
        write_debug_log("Cannot find output.xml in current directory", "ERROR")
    exit()


def replace_punctuation(in_str):
    out_str = ""
    for char in in_str:
        if char not in punctuation and char != ' ':
            out_str = out_str + char
        else:
            out_str = out_str + '_'
    return out_str


def run_command(command):
    p = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
    for line in iter(p.stdout.readline, b''):
        print(line)


def upload_logs(remote_path):
    try:
        ssh_client = open_ssh_to_log_server()
        ftp_client = ssh_client.open_sftp()

        for log_file_name in log_to_upload:
            if not os.path.exists(log_file_name):
                continue
            if os.path.isfile(log_file_name):
                ftp_client.put(log_file_name, remote_path + '/' + log_file_name)
            else:
                upload_dir(ftp_client, remote_path, log_file_name)
        ftp_client.close()
        ssh_client.close()
    except Exception as e:
        print("Error:", e.message)


def upload_dir(ftp_client, remote_path, dir_name):
    ftp_client.mkdir(remote_path + '/' + dir_name)
    files = os.listdir(dir_name)
    for file_name in files:
        if os.path.isfile(dir_name + '/' + file_name):
            ftp_client.put(dir_name + '/' + file_name, remote_path + '/' + dir_name + '/' + file_name)
        else:
            upload_dir(ftp_client, remote_path, dir_name + '/' + file_name)


def write_debug_log(msg, msg_type):
    script_log = open('script_log.txt', 'a')
    script_log.write(get_time() + msg_type + '   ' + msg + '\n')
    script_log.close()


start()
