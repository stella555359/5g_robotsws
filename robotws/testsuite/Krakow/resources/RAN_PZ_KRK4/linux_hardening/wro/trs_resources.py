from os import system
from re import search
from ipaddress import ip_address, ip_interface
from taf.gnb.oam.megazone_client import megazone_client
from taf.transport.ssh import ssh
import testsuite.Krakow.resources.RAN_PZ_KRK4.linux_hardening.wro.robot_variable_in_python as rv
from robot.api.logger import console
ssh = ssh()
mc = megazone_client()


def get_oam_ipv6_address():
    return rv.get_robot_variable("${tl.gnbs[0].cu.oam_ssh_connection_details.addr}")


def get_du_f1_c_ipv6_addr():
    return rv.get_robot_variable("${tl.gnbs[0].dus[0].f1_c_ip_addr.v6}")


def get_du_f1_m_ipv6_addr():
    return rv.get_robot_variable("${tl.gnbs[0].dus[0].f1_m_ip_addr.v6}")


def get_du_f1_u_ipv6_addr():
    return rv.get_robot_variable("${tl.gnbs[0].dus[0].f1_u_ip_addr.v6}")


def get_cu_f1m_ipv6_addr():
    return rv.get_robot_variable("${tl.gnbs[0].cu.f1m.v6}")


def get_cu_f1c_ipv6_addr():
    return rv.get_robot_variable("${tl.gnbs[0].cu.f1c.v6}")


def get_cu_f1u_ipv6_addr():
    return rv.get_robot_variable("${tl.gnbs[0].cu.f1u.v6}")


def get_cu_x2c_ipv6_addr():
    console(rv.get_robot_variable("${tl.gnbs[0].cu.x2c.v6}"))
    return rv.get_robot_variable("${tl.gnbs[0].cu.x2c.v6}")


def get_cu_x2u_ipv6_addr():
    console(rv.get_robot_variable("${tl.gnbs[0].cu.x2u.v6}"))
    return rv.get_robot_variable("${tl.gnbs[0].cu.x2u.v6}")


def get_cu_s1u_ipv6_addr():
    console(rv.get_robot_variable("${tl.gnbs[0].cu.s1u.v6}"))
    return rv.get_robot_variable("${tl.gnbs[0].cu.s1u.v6}")


def get_tnl_4_ipv6_3_address():
    """
    Get ipv6 address for parameter TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-3
    in SCF file.
    :return: ipv6 address
    :rtype: str
    """
    return str(ip_address(unicode(get_du_f1_m_ipv6_addr())))


def get_tnl_4_ipv6_1_address():
    """
    Get ipv6 address for parameter TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1
    in SCF file.
    :return: ipv6 address
    :rtype: str
    """
    return str(ip_address(unicode(get_du_f1_m_ipv6_addr())) + 1)


def get_tnl_4_ipv6_2_address():
    """
    Get ipv6 address for parameter TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-2
    in SCF file.
    :return: ipv6 address
    :rtype: str
        """
    return str(ip_address(unicode(get_du_f1_m_ipv6_addr())) + 2)


def get_servedamf_ipv6_address():
    """
    Get ipv6 address NRBTS-1/SERVEDAMF-1 in SCF file.
    :return: ipv6 address
    :rtype: str
    """
    return str(ip_address(unicode(get_oam_ipv6_address())) + 2)


def get_oam_network_address():
    return str(ip_interface(unicode(get_oam_ipv6_address() + "/120")).network.network_address)


def get_oam_network_gateway_address():
    return str(ip_interface(unicode(get_oam_ipv6_address() + "/120")).network.network_address + 1)


def get_du_network_address():
    return str(ip_interface(unicode(get_du_f1_m_ipv6_addr() + "/120")).network.network_address)


def get_du_network_gateway_address():
    return str(ip_interface(unicode(get_du_f1_m_ipv6_addr() + "/120")).network.network_address + 1)


def get_cu_fronthaul_network_address():
    return str(ip_interface(unicode(get_cu_f1m_ipv6_addr() + "/120")).network.network_address)


def get_cu_fronthaul_network_gateway_address():
    return str(ip_interface(unicode(get_cu_f1m_ipv6_addr() + "/120")).network.network_address + 1)


def get_cu_x2c_network_gateway_address():
    return str(ip_interface(unicode(get_cu_x2c_ipv6_addr() + "/120")).network.network_address + 1)


def set_enb1_x2_addr_in_lteemu_config_file(config_filename_path, connection):
    """
    Set ipv6 address for ENB1_X2 interface in LTEemu config file.
    :param connection: connection to VM where LTEemu will be configured.
    :param config_filename_path: path to LTEemu config file.
    """
    enb1_x2_addr = str(ip_address(unicode(get_oam_ipv6_address())) + 2)
    command = 'sudo sed -i \'s/set ENB1_X2_ADDR=".*"/set ENB1_X2_ADDR="{}"/g\' {}'.format(enb1_x2_addr,
                                                                                          config_filename_path)
    ssh.execute(command, connection)


def set_daemon_ip_to_localhost_in_lteemu_config_file(connection, config_filename_path):
    """
    Set daemon IP to "localhost" in LTEemu config file.
    :param connection: connection to VM where LTEemu will be configured.
    :param config_filename_path: path to LTEemu config file.
    """
    command = 'sudo sed -i \'s/set DAEMON_IP=".*"/set DAEMON_IP="localhost"/g\' {}'.format(config_filename_path)
    ssh.execute(command, connection)


def set_enb2_x2_addr_in_lteemu_config_file(connection, config_filename_path):
    """
    Set ipv6 address for ENB2_X2 interface in LTEemu config file.
    :param connection: connection to VM where LTEemu will be configured.
    :param config_filename_path: path to LTEemu config file.
    """
    enb2_x2_addr = str(ip_address(unicode(get_oam_ipv6_address())) + 768)
    command = 'sudo sed -i \'s/set ENB2_X2_ADDR=".*"/set ENB2_X2_ADDR="{}"/g\' {}'.format(enb2_x2_addr,
                                                                                          config_filename_path)
    ssh.execute(command, connection)


def set_gnb_type_external_line_in_lteemu_config_file(connection, config_filename_path):
    """
    Change ":" --> "." in line started with "set_gnb id=2 type=external" in LTEemu config file.
    :param connection: connection to VM where LTEemu will be configured.
    :param config_filename_path: path to LTEemu config file.
    """
    command = "sudo sed -i '/set_gnb id=2 type=external/s/:/./2' {}".format(config_filename_path)
    ssh.execute(command, connection)


def prepare_du_to_connect_with_cu(connection):
    ssh.execute(command="ip address add {}/120 dev fp0".format(get_tnl_4_ipv6_3_address()), connection=connection)
    ssh.execute(command="ip route add {}/120 via {}".format(get_oam_network_address(),
                                                            get_du_network_gateway_address), connection=connection)


def add_route_on_vm(destination, net_mask, gateway):
    ip_version = check_if_ip_version_is_6(destination)
    if ip_version:
        system("sudo ip -6 r a {}/{} via {}".format(destination, net_mask, gateway))
    else:
        system("sudo ip r a {}/{} via {}".format(destination, net_mask, gateway))


def check_if_ip_version_is_6(ip_addr):
    if ":" in ip_addr:
        return True
    else:
        return False


def add_ip_to_interface_on_vm(ip_addr, net_mask, interface):
    system("sudo ip address add {}/{} dev {}".format(ip_addr, net_mask, interface))


def check_rap_online_status(connection):
    rap_availability_status = mc.get_rap_statuses(status_name="availabilityStatus", session=connection, timeout=10)
    rap_operational_state = mc.get_rap_statuses(status_name="operationalState", session=connection, timeout=10)
    rap_administrative_state = mc.get_rap_statuses(status_name="administrativeState", session=connection, timeout=10)

    if str(rap_availability_status[unicode(1)]["availabilityStatus"]) != "online"\
            or str(rap_operational_state[unicode(1)]["operationalState"]) != "enabled"\
            or str(rap_administrative_state[unicode(1)]["administrativeState"]) != "Unlocked":
        raise AssertionError("RAP is not online")


def check_vms_online_status(connection):
    vms_names = ["cpifVM", "cpueVM", "oamVM", "upueVM", "cpclVM", "cpnbVM"]
    vms_procedural_statuses = []
    for vm_name in vms_names:
        vm_procedural_status = mc.get_vm_procedural_status(vm_name=vm_name,
                                                           session=connection,
                                                           timeout=10)
        vms_procedural_statuses.append(vm_procedural_status)
    if any(status != "configured" for status in vms_procedural_statuses):
        raise AssertionError("At least one vm is offline")


def get_scf_parameters_version_from_oam_vm(parameters_name, oam_connection):
    command = "cat /opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G18A/SBTS5G18A_5g_pid11.xml |" \
              " grep -P -o '(?<=version=\"{}).*?(?=\")' | head -1".format(parameters_name)
    ssh.send_command(command=command, connection=oam_connection)
    version = ssh.read_output(connection=oam_connection).split()[0]
    return version


def get_scf_parameters_version_from_scf(path_to_scf, parameters_name):
    with open(path_to_scf) as scf:
        content = scf.read()
        version = str(search("(?<=version=\"{}).*?(?=\")".format(parameters_name), content).group())
    return version


def set_required_ip_addresses_for_lteemu():
    ip_addresses = ["10.35.166.81", "10.35.166.145", "10.35.166.112", "10.35.166.62", "10.35.166.63", "10.35.166.116"]
    for ip in ip_addresses:
        add_ip_to_interface_on_vm(ip, 24, "eth0")
