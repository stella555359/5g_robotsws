import logging
import sys
import paramiko
from robot.libraries.BuiltIn import BuiltIn
from on_air_tl_preparation.testline_preparation_resources import power_on_all_pdu_ports


def run_keyword_with_fatal_exception_handling(keyword_name, *args):
    try:
        return BuiltIn().run_keyword(keyword_name, *args)
    except Exception as e:
        return f"Fatal exception caught {str(e)}"


def power_on_all_hw_in_testline():
    power_on_all_pdu_ports()


def run_tput(ip_addr):
    ip_addr = str(ip_addr[0]).strip()
    if ip_addr.startswith('10.84.171'):
        command = f'iperf -c {ip_addr} -u -i1 -t500 -l1400 -b1G -P2 -p6789'
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect('10.84.168.121', username='5g', password='5g')
        stdin, stdout, stderr = client.exec_command(command)
        stdout.channel.set_combine_stderr(True)
        output = stdout.readlines()
        logging.info(output)
        client.close()
    else:
        logging.info("UE bricked. No calls possible.")
        sys.exit(1)


def get_ip_address_from_ue(ue_addr, ue_user, ue_password):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(
        ue_addr,
        username=ue_user,
        password=ue_password,
        allow_agent=False,
        look_for_keys=False,
        disabled_algorithms={
            'pubkeys': [],
            'keys': [],
            'kex': [],
            'ciphers': [],
            'macs': [],
            'signatures': [],
        }
    )
    stdin, stdout, stderr = client.exec_command("ip addr | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1")
    stdout.channel.set_combine_stderr(True)
    output = stdout.readlines()
    client.close()
    assign_addr = [addr.strip() for addr in output if addr.strip().startswith('10.84.171.')]
    logging.info(assign_addr)
    return assign_addr
