import importlib
import sys
import socket
import re
import subprocess
import argparse
import taf.pdu.interface


def get_hostname_and_node():
    hostname = socket.gethostname()
    match = re.search(r'-(\d)$', hostname)
    if match:
        node = match.group(1)
        host = re.sub(r'-(\d)$', '', hostname)
        host = host.replace('-', '_')
    else:
        node = 0
        host = hostname.replace('-', '_')
    return host, node


def check_node_id(node):
    if int(node) == 1:
        node_id = 1
    elif int(node) == 2:
        node_id = 0
    else:
        print("I don't see any neighbor")
        exit(1)
    return node_id


def _import(module_name):
    # print("module name: {}".format(module_name))
    try:
        return importlib.import_module(module_name)
    except ImportError as e:
        print("cos: {}".format(e))
        print('Could not import configuration file')
        exit(1)


def import_by_path(path):
    # print('module_path: {}'.format(path))
    sys.path.insert(0, path)
    try:
        return _import(module_name='__init__')
    finally:
        sys.path.remove(path)


tl_config_path = "/home/ute/testline_configuration/"
host, node = get_hostname_and_node()
test_line = import_by_path(tl_config_path + host)

parser = argparse.ArgumentParser(
    description="""
    __init__.py digger is a program to find useful information to make useful things for the smart user like you
    """
)
parser.add_argument("-s", "--ssh-to-neighbor-vm", action="store_true", help="connect with the neighboring vm")
args = parser.parse_args()

if __name__ == '__main__':
    if args.ssh_to_neighbor_vm:
        node_id = check_node_id(node)
        ip_address = test_line.tl.test_pcs[node_id].default_ssh_connection_details.addr
        script = "/home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/qol/ssh_secondary_node.sh"
        subprocess.call(['bash', script, ip_address])

    # for enb in test_line.tl.enbs:
    #     # print(len(enb.rms))
    #     for rms in enb.rms:
    #         print("{}: {} --> pdu_ip: {} port: {}".format(
    #             rms.radio_type,
    #             rms.serial_number,
    #             rms.pdu_port.pdu.addr,
    #             rms.pdu_port.port_no
    #         ))
    #     for unit in enb.system_module.common_units:
    #         print("{}: {} --> pdu_ip: {} port {}".format(
    #             unit.hardware_type,
    #             unit.serial_number,
    #             unit.pdu_port.pdu.addr,
    #             unit.pdu_port.port_no
    #         ))
