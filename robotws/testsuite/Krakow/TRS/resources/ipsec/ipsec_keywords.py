from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest, MolerException
from taf.gnb.oam.coam.admin import admin
from moler.device import DeviceFactory
import re

tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
secgw_ip = tl.test_pcs[0].default_ssh_connection_details.addr
secgw_ipsec_interface = tl.test_pcs[0].connections[0]
lmp_ip = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
secgw_prompt = "ute@.*"


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def check_if_ipsec_is_up(bts_id=0):
    """
    Check with cmd 'ipsec status' IPsec protocol associations is up.

    :param bts_id: ID of BTS
    :return: None
    """
    device_name = "GNB{}".format(bts_id)
    bts = DeviceFactory.get_device(device_name)
    bts.goto_state("FCT")
    cmd_ipsec = bts.get_cmd(cmd_name="ipsec", cmd_params={"options": "status"})
    result = cmd_ipsec()
    try:
        connections = list(result["Security Associations"].keys())
        if connections:
            for connection in connections:
                if list(result["Security Associations"][connection]["IKEgroup"].keys())[0] == "ESTABLISHED":
                    MolerTest.info("Security Associations is up")
                else:
                    MolerTest.error("Security Associations is down", raise_exception=True)
        else:
            MolerTest.error("No IPsec associations", raise_exception=True)
    except KeyError:
        MolerTest.error("IPsec is disabled", raise_exception=True)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def block_link_between_du_and_secgw(bts_id=0):
    """
    Block traffic between DU and secGW with 'iptables' cmd.

    :param bts_id: ID of BTS
    :return: None
    """
    device_name = "GNB{}".format(bts_id)
    bts = DeviceFactory.get_device(device_name, initial_state="PROXY_PC")
    ssh_cmd = bts.get_cmd(cmd_name="ssh", cmd_params={"login": "ute", "password": "", "set_timeout": None,
                                                      "host": secgw_ip,
                                                      "expected_prompt": secgw_prompt})
    ssh_cmd()
    cmd_iptables = bts.get_cmd(cmd_name="iptables",
                               cmd_params={"options": "-I OUTPUT 1 -o {} -j DROP".format(secgw_ipsec_interface)})
    cmd_sudo = bts.get_cmd(cmd_name="sudo",
                           cmd_params={"password": "", "cmd_object": cmd_iptables, "prompt": secgw_prompt})
    cmd_exit = bts.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": secgw_prompt})
    try:
        cmd_sudo()
        cmd_exit()
    except MolerException:
        MolerTest.error("Cannot block connection to secGW", raise_exception=True)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def unblock_link_between_du_and_secgw(bts_id=0):
    """
    Unblock traffic between DU and secGW with 'iptables' cmd.

    :param bts_id: ID of BTS
    :return: None
    """
    device_name = "GNB{}".format(bts_id)
    bts = DeviceFactory.get_device(device_name, initial_state="PROXY_PC")
    ssh_cmd = bts.get_cmd(cmd_name="ssh", cmd_params={"login": "ute", "password": "", "set_timeout": None,
                                                      "host": secgw_ip,
                                                      "expected_prompt": secgw_prompt})
    ssh_cmd()
    cmd_iptables = bts.get_cmd(cmd_name="iptables",
                               cmd_params={"options": "-I OUTPUT 1 -o {} -j ACCEPT".format(secgw_ipsec_interface)})
    cmd_sudo = bts.get_cmd(cmd_name="sudo",
                           cmd_params={"password": "", "cmd_object": cmd_iptables, "prompt": secgw_prompt})
    cmd_exit = bts.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": secgw_prompt})

    try:
        cmd_sudo()
        cmd_exit()
    except MolerException:
        MolerTest.error("Cannot block connection to secGW", raise_exception=True)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def verify_dscp_value_in_ip_header_isakmp(expected_value, bts_id=0):
    """
    Verify if proper hex value of tos is present at IP headers with usage of tcpdump cmd.

    :param expected_value: expected decimal value of DCSP
    :param bts_id: ID of BTS
    :return: None
    """
    dscp_hex_dict = {
        "26": "0x68",
        "44": "0xb0",
        "46": "0xb8",
        "48": "0xc0"
    }
    device_name = "GNB{}".format(bts_id)
    bts = DeviceFactory.get_device(device_name, initial_state="PROXY_PC")
    ssh_cmd = bts.get_cmd(cmd_name="ssh", cmd_params={"login": "ute", "password": "", "set_timeout": None,
                                                      "host": secgw_ip,
                                                      "expected_prompt": secgw_prompt})
    ssh_cmd()
    tcpdump_cmd = bts.get_cmd(cmd_name="tcpdump",
                              cmd_params={"options": "-i {} -vvv".format(secgw_ipsec_interface),
                                          "break_exec_regex": r"IP\s\(tos\s{},\sttl.*proto\sUDP".format(
                                              dscp_hex_dict[expected_value]), "prompt": secgw_prompt})
    cmd_sudo_tcpdump = bts.get_cmd(cmd_name="sudo",
                                   cmd_params={"password": "", "cmd_object": tcpdump_cmd, "prompt": secgw_prompt})
    cmd_exit = bts.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": secgw_prompt})
    try:
        cmd_sudo_tcpdump()
        cmd_exit()
    except MolerException:
        MolerTest.error("Cannot find correct DSCP value in IP headers", raise_exception=True)


def get_ipsec_interface_ip():
    """
    Get value of remoteTunnelEndpoint parameter from Webem.

    :return: value of remoteTunnelEndpoint parameter
    """
    du_instance = GnbCommissioning()
    admin_connection = admin().connect_to(lmp_ip)
    bts_configuration = admin_connection.get_scf(export_type="configurationAndRuntimeObjects")
    admin_connection.disconnect()
    ret = str(bts_configuration).partition('distName="{}"'.format(
        "MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-1".format(du_instance.get_global_bts_id())))[2].partition(
        '</managedObject>')[0]
    re_parameter_and_value = r'\s+<p\s\w+=.(?P<KEY>\w+).>(?P<VALUE>.*)</p>'
    ret_dict = dict()
    for line in ret.splitlines():
        determinate_parameter = re.search(re_parameter_and_value, line)
        if determinate_parameter:
            ret_dict[determinate_parameter.group('KEY')] = determinate_parameter.group('VALUE')
    return ret_dict["remoteTunnelEndpoint"]


def change_dscp_parameter(value):
    """
    Change DSCP parameter on DU webem.

    :param value: decimal value of DSCP parameter.
    :return: None
    """

    du_instance = GnbCommissioning()
    du_instance.perform_configuration_parameter_recommissioning(
        dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1".format(du_instance.get_global_bts_id()),
        parameter="ikeDscp", operation="update", value=value, skip_parameter_relation_errors=True)


def check_if_dpd_alarm_is_active():
    """
    Check if 'Dead Peer Detected' alarm is active on DU Webem

    :return: None
    """
    gnb_alarm_instance = GnbAlarmVerification()
    gnb_alarm_instance.verify_alarm_is_active(fault_name="Dead Peer Detected")


def check_if_dpd_alarm_is_inactive():
    """
    Check if 'Dead Peer Detected' alarm is inactive on DU Webem

    :return: None
    """
    gnb_alarm_instance = GnbAlarmVerification()
    gnb_alarm_instance.verify_alarm_is_not_active(fault_name="Dead Peer Detected")


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def verify_if_traffic_with_fragmentation_is_encrypted(bts_id=0):
    """
    Verify if traffic with fragmentation is encrypted.

    :param bts_id: ID of BTS
    :return: None
    """
    device_name = "GNB{}".format(bts_id)
    du_device_name = "{}_ping_secGW".format(bts_id)
    bts = DeviceFactory.get_device(device_name, initial_state="PROXY_PC")
    du = DeviceFactory.get_cloned_device(new_name=du_device_name, source_device=bts, initial_state="FCT")
    ping_secgw = du.get_cmd(cmd_name="ping",
                            cmd_params={"options": "-s 1500", "destination": get_ipsec_interface_ip()})
    ping_secgw.start()
    ssh_cmd = bts.get_cmd(cmd_name="ssh", cmd_params={"login": "ute", "password": "", "set_timeout": None,
                                                      "host": secgw_ip,
                                                      "expected_prompt": secgw_prompt})
    ssh_cmd()
    tcpdump_cmd = bts.get_cmd(cmd_name="tcpdump",
                              cmd_params={"options": "-i {} -vvv".format(secgw_ipsec_interface),
                                          "break_exec_regex": r"IP\s\(tos\s.*proto\sESP"})
    cmd_sudo_tcpdump = bts.get_cmd(cmd_name="sudo",
                                   cmd_params={"password": "", "cmd_object": tcpdump_cmd, "prompt": secgw_prompt})
    try:
        cmd_sudo_tcpdump()
        ping_secgw.break_cmd()
    except MolerException:
        MolerTest.error("Cannot find encrypted traffic with ESP headers", raise_exception=True)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def verify_if_dscp_value_is_same_in_encrypted_and_non_encrypted_ip_header(bts_id=0):
    """
    Verify if hex value of tos is same in encrypted and non encrypted IP header.

    :param bts_id: ID of BTS
    :return: None
    """
    device_name = "GNB{}".format(bts_id)
    device_name_sctp = "{}_sctp_finder".format(bts_id)
    du_device_name = "{}_ping_secGW".format(bts_id)
    bts_esp_finder = DeviceFactory.get_device(device_name, initial_state="PROXY_PC")
    bts_sctp_finder = DeviceFactory.get_cloned_device(new_name=device_name_sctp, source_device=bts_esp_finder,
                                                      initial_state="PROXY_PC")
    du = DeviceFactory.get_cloned_device(new_name=du_device_name, source_device=bts_esp_finder, initial_state="FCT")
    ping_secgw = du.get_cmd(cmd_name="ping",
                            cmd_params={"options": "-s 1500", "destination": get_ipsec_interface_ip()})

    esp_finder_ssh_cmd = bts_esp_finder.get_cmd(cmd_name="ssh",
                                                cmd_params={"login": "ute", "password": "", "set_timeout": None,
                                                            "host": secgw_ip,
                                                            "expected_prompt": secgw_prompt})
    sctp_finder_ssh_cmd = bts_sctp_finder.get_cmd(cmd_name="ssh",
                                                  cmd_params={"login": "ute", "password": "ute", "set_timeout": None,
                                                              "host": secgw_ip,
                                                              "expected_prompt": secgw_prompt})
    tcpdump_cmd_esp = bts_esp_finder.get_cmd(cmd_name="tcpdump",
                                             cmd_params={"options": "-i {} -vvv".format(secgw_ipsec_interface),
                                                         "break_exec_regex": r"^.*IP\s\(tos\s0xba.*proto\sESP"})
    tcpdump_cmd_sctp = bts_sctp_finder.get_cmd(cmd_name="tcpdump",
                                               cmd_params={"options": "-i {} -vvv".format(secgw_ipsec_interface),
                                                           "break_exec_regex": r"^.*IP\s\(tos\s0xba.*proto\sSCTP"})
    cmd_sudo_esp = bts_esp_finder.get_cmd(cmd_name="sudo", cmd_params={"password": "", "cmd_object": tcpdump_cmd_esp,
                                                                       "prompt": secgw_prompt})
    cmd_sudo_sctp = bts_sctp_finder.get_cmd(cmd_name="sudo", cmd_params={"password": "", "prompt": secgw_prompt,
                                                                         "cmd_object": tcpdump_cmd_sctp})
    try:
        ping_secgw.start()
        esp_finder_ssh_cmd()
        sctp_finder_ssh_cmd()
        cmd_sudo_esp.start()
        cmd_sudo_sctp.start()
        cmd_sudo_esp.await_done()
        cmd_sudo_sctp.await_done()
    except MolerException:
        MolerTest.error("Cannot find proper tos values in IP headers", raise_exception=True)
    ping_secgw.break_cmd()
