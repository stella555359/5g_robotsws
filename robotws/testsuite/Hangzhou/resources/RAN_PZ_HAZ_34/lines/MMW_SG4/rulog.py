import re
import time
from taf.transport.ssh.connection import SSHConnection
from taf.transport.ssh.exceptions import CommandOutputCollectionError
import logging

rf_username = 'rfsw'
rf_password = '3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc='


def capture_ru_logs(host, username, password, ru_sn=None, timestamp=None):
    sshconnection = SSHConnection()
    sshconnection.configure(hostname=host, username=username, password=password, timeout=300)
    sshconnection.connect()
    tn = sshconnection.invoke_shell()
    tn.send('rm -rf /ffs/run/config/toor4nsn/rulog_*.zip\n')
    match_shell_til(tn, match="root", timeout=2)
    if ru_sn:
        tn.send(f'cat /ffs/run/config/FRIps.txt | grep {ru_sn}\n')
    else:
        tn.send('cat /ffs/run/config/FRIps.txt\n')
    ru_ip_info = match_shell_til(tn, match="root", timeout=2)
    logging.info(f"ru_ip_info:\n{ru_ip_info}")
    ru_ip_list = get_ru_ip(ru_ip_info)
    logging.info(f"ru_ip_list: {ru_ip_list}")

    tn.send('cd /ram\n')
    match_shell_til(tn, match=":/ram", timeout=2)
    tn.send("ls -l | grep FHNET | head -n 1 \n")
    reg_info = match_shell_til(tn, match="node_FHNET00", timeout=2)
    logging.info(f"FHNET:\n{reg_info}")
    reg_id = get_reg_id(reg_info)
    print('reg_id:', reg_id)
    tn.send(f"lxc-attach -n {reg_id} \n")
    attach_fhnet = match_shell_til(tn, match="root@FHNET00", timeout=2)
    print(f"attach_fhnet:\n{attach_fhnet}")

    for ip, sn, ru in ru_ip_list:
        ru_log_name = f'rulog_{sn}_{timestamp}_{ru}.zip'
        print(f'ssh to ru: {ip}, {sn}, {ru}')
        tn.send(f"ssh {rf_username}@{ip} \r\n")
        output = ru_login_shell_output(tn)
        if 'yes/no/[fingerprint]' in output:
            print('send to yes')
            tn.send("yes \n")
            match_shell_til(tn, match="password:", timeout=3)
        tn.send(f"{rf_password}\n")
        login_info = match_shell_til(tn, match=f"/home/{rf_username}", timeout=3)
        print(login_info)
        tn.send(f'log -c full -a -z {ru_log_name} \n')
        match_shell_til(tn, match="succeed", timeout=120)
        tn.send(f'find /ram/ -maxdepth 1 -type f | grep {ru_log_name} \n')
        match_shell_til(tn, match=f"/ram/{ru_log_name}", timeout=3)
        tn.send("exit \r\n")
        match_shell_til(tn, match=":/ram", timeout=3)
        tn.send(f"scp {rf_username}@{ip}:/ram/{ru_log_name} /ffs/run/config/toor4nsn/ \n")
        match_shell_til(tn, match="password:", timeout=3)
        tn.send(f"{rf_password}\n")
        match_shell_til(tn, match="100%", timeout=60)
        time.sleep(3)

    sshconnection.disconnect()


def get_ru_ip(ru_info):
    # regx = re.compile(r';(\\d{2,3}\.\\d{2,3}\.\\d{1,3}\.\\d{1,3});(.+?);(.+?)\\')
    regx = re.compile(r';\d+;(\d{1,3}(?:\.\d{1,3}){3});([^;]+);([^;\r\n]+)')
    result = regx.findall(ru_info)
    print('ru_list:', result)
    return result


def get_reg_id(reg_info):
    # regx = re.compile(r'node_(0x\\d+) -> /ram/node_FHNET00')
    regx = re.compile(r'node_(0x\d+)\s*->\s*/ram/node_FHNET00')
    result = regx.findall(reg_info)
    return result[0]


def match_shell_til(shell, match, timeout=3):
    start = time.time()
    output = ""
    while (time.time() - start) <= timeout:
        output += str(shell.recv(65535))
        if re.search(match, output):
            return output
        time.sleep(0.1)
    else:
        return 'match failed'


def ru_login_shell_output(shell, timeout=3):
    start = time.time()
    output = ""
    while (time.time() - start) <= timeout:
        output += str(shell.recv(65535))
        if 'yes/no/[fingerprint]' in output or 'password:' in output:
            break
        time.sleep(0.1)
    else:
        output = 'match failed'
    return output
