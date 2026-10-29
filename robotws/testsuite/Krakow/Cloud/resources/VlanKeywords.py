from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.util.moler_test import MolerTest, MolerException
from moler.device import DeviceFactory
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning as GnbScf
from taf.gnb.oam.coam.admin import admin
from testsuite.Krakow.resources.routing_table.moler_keywords import MolerKeywords
import re

tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
traffic_interface = "fp0"
lmp_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
ue_pc_username = tl.ues[0].ssh_connection_details.username
ue_pc_password = tl.ues[0].ssh_connection_details.password
ue_pc_address = tl.ues[0].ssh_connection_details.addr
ue_serial_number = tl.ues[0].serial_number
vlan_ip_adresses = tl.switches[0]
vlan_regex = r".*ethertype\s802.1Q.*vlan\s{}"
pcp_marking_regex = r".*ethertype\s802.1Q.*vlan\s\d+.\sp\s{},\sethertype\sIPv4,\s.*"


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def check_vlan_tagging(vlan_id):
    """
    Ping on defined vlan address and check if 802.1Q tagging is present in tcpdump.

    :param vlan_id: vlan ID number
    :return: None
    """
    vlan_tracker = DeviceFactory.get_cloned_device("GNB0", "GNB0_vlan{}_tracker".format(vlan_id), initial_state="FCT")
    vlan_pinger = DeviceFactory.get_cloned_device("GNB0", "GNB0_vlan{}_pinger".format(vlan_id),
                                                  initial_state="PROXY_PC")
    vlan_ping_cmd = vlan_pinger.get_cmd(cmd_name="ping", cmd_params={"destination": vlan_ip_adresses[vlan_id]})
    catch_vlan_id_cmd = vlan_tracker.get_cmd(cmd_name="tcpdump",
                                             cmd_params={"options": "-nei {}".format(traffic_interface),
                                                         "break_exec_regex": vlan_regex.format(vlan_id)})
    vlan_ping_cmd.start(timeout=150)
    try:
        tcpdump_ret = catch_vlan_id_cmd(timeout=100)
        MolerTest.info("Vlan ID {} FOUND".format(vlan_id), dump=tcpdump_ret)
    except MolerException:
        MolerTest.error("Vlan ID {} NOT FOUND in tcpdump data on {}".format(vlan_id, traffic_interface),
                        raise_exception=True)
    finally:
        vlan_ping_cmd.break_cmd()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def check_vlan_pcp_marking(vlan_id, pcp_value):
    """
    Ping on defined vlan address from UE, control that the traffic arrived in the right VLAN and traffic is tagged with
    the PCP value corresponding to the PDCP value generated in the initial traffic.

    :param vlan_id: vlan ID number
    :param pcp_value: pcp marking value
    :return: None
    """
    pcp_tracker = DeviceFactory.get_cloned_device("GNB0", "GNB0_pcp_tracker", initial_state="FCT")
    vlan_tracker = DeviceFactory.get_cloned_device("GNB0", "GNB0_{}_vlan_tracker".format(vlan_id), initial_state="FCT")
    vlan_pinger = DeviceFactory.get_cloned_device("GNB0", "GNB0_vlan{}_pinger".format(vlan_id),
                                                  initial_state="PROXY_PC")
    ssh_to_ue_pc = vlan_pinger.get_cmd(cmd_name="ssh", cmd_params={"login": ue_pc_username,
                                                                   "password": ue_pc_password,
                                                                   "host": ue_pc_address,
                                                                   "expected_prompt": ".*"})
    vlan_ping_cmd = vlan_pinger.get_cmd(cmd_name="bash",
                                        cmd_params={"bash": " adb -s {} shell 'ping -Q 0x28 {}'".format(
                                            ue_serial_number, vlan_ip_adresses[vlan_id]), "prompt": ".*"})
    catch_pcp_on_ue_traffic_cmd = pcp_tracker.get_cmd(
        cmd_name="tcpdump",
        cmd_params={"options": "-nei {}".format(traffic_interface),
                    "break_exec_regex": pcp_marking_regex.format(pcp_value)})
    catch_vlan_id_cmd = vlan_tracker.get_cmd(cmd_name="tcpdump",
                                             cmd_params={"options": "-nei {}".format(traffic_interface),
                                                         "break_exec_regex": vlan_regex.format(vlan_id)})
    ssh_to_ue_pc()
    vlan_ping_cmd.start(timeout=150)
    try:
        tcpdump_ret_vlan = catch_vlan_id_cmd(timeout=100)
        MolerTest.info("Traffic from ue with {} vlan ID FOUND".format(vlan_id), dump=tcpdump_ret_vlan)
        tcpdump_ret_pcp = catch_pcp_on_ue_traffic_cmd(timeout=100)
        MolerTest.info("Traffic from ue with {} PCP value mark FOUND".format(pcp_value), dump=tcpdump_ret_pcp)
    except MolerException:
        MolerTest.error(
            "Expected values: vlan {}, {} pcp mark are NOT present in tcpdump".format(vlan_id, pcp_value),
            raise_exception=True)
    finally:
        vlan_ping_cmd.break_cmd()
        vlan_pinger.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": ".*"})()


def create_vlan(vlan_id):
    """
    Create defined vlan with proper interface assigned.

    :param vlan_id: vlan ID number
    :return: None
    """
    du = GnbScf()
    bts_id = du.get_global_bts_id()
    ipif_id = str(int(max(_get_ipif_id_list())) + 1)
    du.perform_object_recommissioning(
        dist_name="MRBTS-{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-{}".format(bts_id, vlan_id),
        parameter=_get_vlan_object(vlan_id), operation="create",
        skip_parameter_relation_errors=True,
        should_activate=True)
    du.perform_object_recommissioning(
        dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-{}".format(bts_id, ipif_id),
        parameter=_get_ipif_object(bts_id, ipif_id, vlan_id), operation="create",
        skip_parameter_relation_errors=True,
        should_activate=True)
    du.perform_object_recommissioning(
        dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-{}/IPADDRESSV4-1".format(bts_id, ipif_id),
        parameter=_get_ip_object(vlan_id), operation="create",
        skip_parameter_relation_errors=True,
        should_activate=True)


def delete_vlan(vlan_id):
    """
    Delete defined vlan with proper interface assigned.

    :param vlan_id: vlan ID number
    :return: None
    """
    du = GnbScf()
    bts_id = du.get_global_bts_id()
    ipif_id = _get_vlan_ipif_id(bts_id, vlan_id)
    du.perform_object_recommissioning(
        dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-{}/IPADDRESSV4-1".format(bts_id, ipif_id),
        parameter=[], operation="delete", skip_parameter_relation_errors=True, should_activate=True)
    du.perform_object_recommissioning(
        dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-{}".format(bts_id, ipif_id),
        parameter=[], operation="delete", skip_parameter_relation_errors=True, should_activate=True)
    du.perform_object_recommissioning(
        dist_name="MRBTS-{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-{}".format(bts_id, vlan_id),
        parameter=[], operation="delete", skip_parameter_relation_errors=True, should_activate=True)


def change_icmp_pcp_mapping(pcp_value):
    """
    Modify 'vlanPrioForDscp00' parameter value.

    :param pcp_value: planned value of vlanPrioForDscp00 parameter
    :return: None
    """
    du = GnbScf()
    bts_id = du.get_global_bts_id()
    du.perform_object_recommissioning(
        dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/QOS-1/DSCP2PCPMAP-1".format(bts_id),
        parameter=[{"parameterName": "vlanPrioForDscp00", "operation": "update", "value": pcp_value}],
        operation="update", skip_parameter_relation_errors=True, should_activate=True)


def _get_vlan_object(vlan_id):
    return [{"parameterName": "vlanIfId", "operation": "update", "value": vlan_id},
            {"parameterName": "vlanId", "operation": "update", "value": vlan_id}]


def _get_ipif_object(bts_id, ipif_id, vlan_id):
    return [{"parameterName": "interfaceDN", "operation": "update",
             "value": "MRBTS-{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-{}".format(bts_id, vlan_id)},
            {"parameterName": "ipIfId", "operation": "update", "value": ipif_id},
            {"parameterName": "ipMtu", "operation": "update", "value": "9200"}]


def _get_ip_object(vlan_id):
    return [{"parameterName": "localIpAddr", "operation": "update", "value": vlan_ip_adresses[vlan_id]},
            {"parameterName": "localIpPrefixLength", "operation": "update", "value": "23"},
            {"parameterName": "ipAddressAllocationMethod", "operation": "update", "value": "MANUAL"}]


def _get_ipif_id_list():
    admin_connection = admin().connect_to(lmp_address)
    bts_configuration = admin_connection.get_scf(export_type="configurationAndRuntimeObjects")
    admin_connection.disconnect()
    ipif_list = re.findall(r"MRBTS-\d+\/TNLSVC-\d+\/TNL-\d+\/IPNO-\d+\/IPIF-(?P<VALUE>\d+)\/IPADDRESSV4-1",
                           bts_configuration)
    return list(dict.fromkeys(ipif_list))


def _get_vlan_ipif_id(bts_id, vlan_id):
    admin_connection = admin().connect_to(lmp_address)
    bts_configuration = admin_connection.get_scf(export_type="configurationAndRuntimeObjects")
    admin_connection.disconnect()
    ipif_per_vlan = {}
    for ipif_id in _get_ipif_id_list():
        ret = str(bts_configuration).partition('distName="{}"'.format(
            "MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-{}".format(bts_id, ipif_id)))[2].partition('</managedObject>')[0]
        re_parameter_and_value = r"\s+<p\s\w+=.(?P<KEY>\w+).>(?P<VALUE>.*)</p>"
        ret_dict = dict()
        for line in ret.splitlines():
            determinate_parameter = re.search(re_parameter_and_value, line)
            if determinate_parameter:
                ret_dict[determinate_parameter.group('KEY')] = determinate_parameter.group('VALUE')
        ipif_per_vlan.update({str(ret_dict["interfaceDN"].split("-")[-1]): ipif_id})
    return ipif_per_vlan[vlan_id]


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def generate_nping_packets(source, destination, ether_type, count, bts_id=0):
    """
    Generate network packets by using Nping tool.

    :param source: str, source IP address
    :param destination: str, destination Ip address
    :param ether_type: str, Ethertype field of ethernet frame e.g. 0x0800
    :param count: str, number of nping rounds
    :param bts_id: int, BTS identifier, default is 0
    :return: None
    """
    source_address = get_vm_address(source)
    destination_address = MolerKeywords().get_du_interface_address(interface_name=destination, vlan_tag_fp0=True)
    device_name = "GNB{}".format(bts_id)
    vm = DeviceFactory.get_device(device_name, initial_state="PROXY_PC")
    cmd_nping = vm.get_cmd(cmd_name="run_script",
                           cmd_params={"script_command": "nping -c {} -S {} --ether-type {} {}".format(
                               count, source_address, ether_type, destination_address)})
    cmd_sudo_nping = vm.get_cmd(cmd_name="sudo", cmd_params={"password": "", "cmd_object": cmd_nping})
    cmd_sudo_nping.start(timeout=300)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def get_vm_address(interface_name, bts_id=0):
    """
    Get IP address of VM interface.

    :param interface_name: str, name of VM interface e.g. "eth3"
    :param bts_id: int, BTS identifier, default is 0
    :return: str, IP address
    """
    device_name = "GNB{}".format(bts_id)
    vm = DeviceFactory.get_device(device_name, initial_state="PROXY_PC")
    ip_cmd = vm.get_cmd(cmd_name="ip_addr", cmd_params={"options": "show {}".format(interface_name)})
    addr = ip_cmd()[interface_name]["IPV4"][0]["IP"]
    return addr
