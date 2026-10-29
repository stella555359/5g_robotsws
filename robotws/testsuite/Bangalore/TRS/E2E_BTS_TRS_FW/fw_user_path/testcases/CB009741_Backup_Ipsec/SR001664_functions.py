import os
import time


def stop_strongswan_process():
    os.system("sudo ipsec stop")


def start_strongswan_process():
    os.system("sudo ipsec start")


def copy_ipsec_config_file(ipsecfile):
    file1 = "/home/ute/MN/UTE/robotlte/testsuite/WMP/DevEspoo/SR001664/ipsec.conf"
    file2 = "/home/ute/MN/UTE/robotlte/testsuite/WMP/DevEspoo/MISC/SR001664/ipsec2.conf"
    filetocopy = ""
    filetoreplace = "/etc/ipsec.conf"
    if (ipsecfile == "2"):
        filetocopy = file2
    else:
        filetocopy = file1
    copycommand = "sudo cp " + filetocopy + " " + filetoreplace
    os.system(copycommand)


def own_add_vlan(vlan_id):
    command_part1 = "sudo ip link add link eth3.2733 name eth3.2733.{}".format(vlan_id)
    command_part2 = " type vlan id {}".format(vlan_id)
    os.system(command_part1+command_part2)


def add_primary_ip_to_vlan(vlan_id):
    os.system("sudo ip addr add 10.0.1.7/32 brd 10.0.1.215 dev eth3.{}".format(vlan_id))
    os.system("sudo ip addr add 10.0.3.7/32 dev eth3.{}".format(vlan_id))


def add_ps_ip_to_vlan(vlan_id):
    os.system("sudo ip addr add 10.0.1.11/32 brd 10.0.1.215 dev eth3.{}".format(vlan_id))
    os.system("sudo ip addr add 10.0.3.11/32 dev eth3.{}".format(vlan_id))


def own_set_ip_link_up(vlan_id):
    os.system("sudo ip link set dev eth3.{} up".format(vlan_id))


def add_secondary_ip_to_vlan(vlan_id):
    os.system("sudo ip addr add 10.0.1.9/32 brd 10.0.1.215 dev eth3.{}".format(vlan_id))
    os.system("sudo ip addr add 10.0.3.9/32 dev eth3.{}".format(vlan_id))


def remove_secondary_ip_from_vlan(vlan_id):
    os.system("sudo ip addr del 10.0.1.9/32 dev eth3.{}".format(vlan_id))
    os.system("sudo ip addr del 10.0.3.9/32 dev eth3.{}".format(vlan_id))


def remove_primary_ip_from_vlan(vlan_id):
    os.system("sudo ip addr del 10.0.1.7/32 brd 10.0.1.215 dev eth3.{}".format(vlan_id))
    os.system("sudo ip addr del 10.0.3.7/32 dev eth3.{}".format(vlan_id))


def remove_ps_ip_from_vlan(vlan_id):
    os.system("sudo ip addr del 10.0.1.11/32 brd 10.0.1.215 dev eth3.{}".format(vlan_id))
    os.system("sudo ip addr del 10.0.3.11/32 dev eth3.{}".format(vlan_id))


def verify_throughput_via_strongswan(connection=2, expectedtput=500000, measuretime=5):
    bits1 = 8*int(get_ipsec_bytes_in(connection))
    time.sleep(int(measuretime))
    bits2 = 8*int(get_ipsec_bytes_in(connection))
    ipsecthroughput = (bits2-bits1)/int(measuretime)
    if int(ipsecthroughput) < int(expectedtput):
        return 0
    else:
        return 1


def get_ipsec_bytes_in(connection):
    _cmd = "sudo ipsec statusall conn{} > strongswantempfile.txt".format(connection)
    os.system(_cmd)
    f = open("strongswantempfile.txt", "r")
    _filecontent = f.readlines()
    for _line in _filecontent:
        if "bytes_i" in _line and "bytes_o" in _line:
            _fetchline = _line.split()
    f.close()
    os.system("rm strongswantempfile.txt")
    return _fetchline[2]
