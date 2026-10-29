import subprocess
import paramiko
import time
import os
import re
import datetime as dt


def check_syslog_for_crashes(crash_prints, syslog_file):
    try:
        crashes = subprocess.check_output(
            "zgrep -a '{0}' {1}".format(crash_prints, syslog_file), shell=True
        )
        if crashes:
            raise Exception(
                "Syslog Crash verification failed :\n Crash has been found in {0}: \n{1}".format(
                    syslog_file, crashes
                )
            )
    except subprocess.CalledProcessError as e:
        if e.returncode == 1:
            return True
        elif e.returncode == 2:
            raise RuntimeError("Error occured during executing {0}".format(e.cmd))


def run_test_on_remote_node(host, user, command, ssh_key):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, username=user, key_filename=ssh_key)
    stdin, stdout, stderr = ssh.exec_command(command)
    output = stdout.readlines()
    errors = stderr.readlines()
    print('###============errors=============###')
    for error in errors:
        print(error)
    print('###============output=============###')
    for line in output:
        print(line)
    print('###===============================###')
    output_slice = output[-20:]
    slice_as_string = str(output_slice)
    if "| PASS |" in slice_as_string:
        status = True
    else:
        status = False
    ssh.close()
    return status, output


def set_ssh_tunnel(lmp_ip, uboot_fsp_ip, uboot_port_suffix):
    os.system('killall -9 ssh')
    os_cmd = 'ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "' + str(lmp_ip) + '"'
    os.system(os_cmd)
    os_cmd_known_hosts = 'rm /home/ute/.ssh/known_hosts'
    os.system(os_cmd_known_hosts)
    port = '1001' + str(uboot_port_suffix)

    # set tunnel
    cmd = "sshpass -p 'oZPS0POrRieRtu' ssh -f toor4nsn@{0} -L {1}:[{2}]:22 -N".format(lmp_ip, port, uboot_fsp_ip)
    print(cmd)
    os.system(cmd)

    # check if exist
    check_tunnel = "ps aux | grep ssh"
    print(check_tunnel)
    process = subprocess.Popen(check_tunnel, shell=True, universal_newlines=True, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT)
    out, err = process.communicate()
    print(out)
    # do nothing xD


def run_command_on_card(uboot_port_suffix, command, timeout):
    port = '1001' + str(uboot_port_suffix)
    password = 'oZPS0POrRieRtu'
    card_cmd = "timeout {} sshpass -p 'oZPS0POrRieRtu' ssh toor4nsn@127.0.0.1 -q -p {} timeout {} {}".format(timeout,
                                                                                                             str(port),
                                                                                                             timeout,
                                                                                                             command)
    print(card_cmd)
    process = subprocess.Popen(card_cmd, shell=True, universal_newlines=True, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT)
    out, err = process.communicate()
    print(out)
    return out


def check_module_type(uboot_port_suffix):
    port = '1001' + str(uboot_port_suffix)
    check = r"""timeout 5m sysinfo 2>&1| head -n10 | grep "ID_00_MODULE_ID_\[0\]" | awk -F "'" '{print $2}'"""
    card_cmd = """sshpass -p 'oZPS0POrRieRtu' ssh toor4nsn@127.0.0.1 -p """ + str(port) + " " + check
    print(card_cmd)
    process = subprocess.Popen(card_cmd, shell=True, universal_newlines=True, stdout=subprocess.PIPE)
    out, err = process.communicate()
    print(out.rstrip())
    return out.rstrip()


def get_first_cell_downtime(item):
    items = item.split("\n")
    first_cell = items[0]
    return first_cell


def get_last_cell(item):
    all_cells = item.count("CellDriver")
    items = item.split("\n")
    print(items[all_cells - 1])
    return items[all_cells - 1]


def get_first_cell(item):
    # if cell_m == 1:
    #    return item
    # else:
    #    all_cells = item.count("CellDriver")
    items = item.split("\n")
    print(items[0])
    return items[0]


# def get_first_cell(item, cell_m):
#     if cell_m == 1:
#        return item
#     else:
#        all_cells = item.count("CellDriver")
#        items = item.split("\n")
#        print(items[all_cells - 2 * cell_m])
#        return items[all_cells - 2 * cell_m]


def get_delta_time_in_seconds(start_frame, stop_frame):
    start_frame = start_frame.split('\n')[0]
    start = re.search("<(.*?)>", start_frame).group(1).split("T")[1][:14]
    stop = re.search("<(.*?)>", stop_frame).group(1).split("T")[1][:14]
    start_formated = dt.datetime.strptime(start, '%H:%M:%S.%f')
    stop_formated = dt.datetime.strptime(stop, '%H:%M:%S.%f')
    diff = (stop_formated - start_formated).total_seconds()
    print("Time Difference: ".format(diff))
    if diff > 0:
        return diff
    else:
        return 0
