import re

from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from taf.rfrl.bts.connections import device_aliases
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from variables import *

admin_connection = admin()
tl = BuiltIn().get_variable_value('${tl}')
if tl.gnbs[0].dus[0].airscale.common_units:
    lmp_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
else:
    lmp_address = tl.gnbs[0].dus[0].airscale.core_units[0].lmp_connection.addr
gnb_id = tl.gnbs[0].dus[0].global_bts_id
du_operations = GnbDuOperations()
trigger_dist_names = ["MRBTS-{}/TNLSVC-1/TNL-2/TRIGGER-1/TRIGGER_R-1".format(gnb_id),
                      "MRBTS-{}/TNLSVC-1/TNL-2/TRIGGER-2/TRIGGER_R-1".format(gnb_id)]


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def block_incoming_bfd_packets(bbmod_ip, bts_id=0, du_id=0, ru_id=0):
    """
    Block incoming BFD packets on RMOD.

    :param bbmod_ip: BBMOD IP address
    :param bts_id: BTS ID
    :param du_id: DU ID
    :param ru_id: RU ID
    :return: None
    """
    nft_insert_rule_cmd = "nft insert rule ip filter INPUT ip saddr {} drop".format(bbmod_ip)
    run_nft_cmd(nft_insert_rule_cmd, bts_id, du_id, ru_id)


def block_outgoing_bfd_packets(bbmod_ip, bts_id=0, du_id=0, ru_id=0):
    """
    Block outgoing BFD packets on RMOD.

    :param bbmod_ip: BBMOD IP address
    :param bts_id: BTS ID
    :param du_id: DU ID
    :param ru_id: RU ID
    :return: None
    """
    nft_insert_rule_cmd = "nft insert rule ip filter OUTPUT ip daddr {} drop".format(bbmod_ip)
    run_nft_cmd(nft_insert_rule_cmd, bts_id, du_id, ru_id)


def unblock_incoming_bfd_packets(bbmod_ip, bts_id=0, du_id=0, ru_id=0):
    """
    Unblock incoming BFD packets on RMOD.

    :param bbmod_ip: BBMOD IP address
    :param bts_id: BTS ID
    :param du_id: DU ID
    :param ru_id: RU ID
    :return: None
    """
    nft_handle_cmd = "nft -n -a list chain filter INPUT | grep {}".format(bbmod_ip)
    nft_output = run_nft_cmd(nft_handle_cmd, bts_id, du_id, ru_id)['LINES'][0]
    handle_pattern = r"ip saddr .* handle (?P<HANDLE>\d+)"
    handle = re.search(handle_pattern, nft_output).group('HANDLE')
    nft_delete_rule_cmd = "nft delete rule filter INPUT handle {}".format(handle)
    run_nft_cmd(nft_delete_rule_cmd, bts_id, du_id, ru_id)


def unblock_outgoing_bfd_packets(bbmod_ip, bts_id=0, du_id=0, ru_id=0):
    """
    Unlock outgoing BFD packets on RMOD.

    :param bbmod_ip: BBMOD IP address
    :param bts_id: BTS ID
    :param du_id: DU ID
    :param ru_id: RU ID
    :return: None
    """
    nft_handle_cmd = "nft -n -a list chain filter OUTPUT| grep {}".format(bbmod_ip)
    nft_output = run_nft_cmd(nft_handle_cmd, bts_id, du_id, ru_id)['LINES'][0]
    handle_pattern = r"ip daddr .* handle (?P<HANDLE>\d+)"
    handle = re.search(handle_pattern, nft_output).group('HANDLE')
    nft_delete_rule_cmd = "nft delete rule filter OUTPUT handle {}".format(handle)
    run_nft_cmd(nft_delete_rule_cmd, bts_id, du_id, ru_id)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def run_nft_cmd(cmd, bts_id=0, du_id=0, ru_id=0):
    """
    Run NFT CMD on RMOD.

    :param cmd: nft cmd
    :param bts_id: BTS ID
    :param du_id: DU ID
    :param ru_id: RU ID
    :return: None
    """
    ru = DeviceFactory.get_device(device_aliases.ssh_bts_du_ru.format('GNB', bts_id, du_id, ru_id), initial_state="RU")
    ru.get_cmd(cmd_name="sudo", cmd_params={"sudo_params": "su"})()
    nft_cmd = ru.get_cmd(cmd_name="cat", cmd_params={"path": cmd})
    nft_cmd.command_string = nft_cmd.command_string[4:]
    nft = nft_cmd()
    ru.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": r"(root|serviceuser|rfsw)@.*Node\d+:.*#"})
    return nft


def lock_sfp_lane(lane):
    """
    Lock SFP Lane

    :param lane: SFP Lane dist name
    :return: None
    """
    admin_connection.connect_to(bts_host=lmp_address)
    try:
        admin_connection.lock(dist_name=lane, timeout=60)
    finally:
        admin_connection.teardown()


def lock_multiple_sfp_lanes(lanes_list):
    """
    Lock multiple SFP Lanes

    :param lanes_list: SFP Lanes dist names
    :type lanes_list: list
    :return: None
    """
    for lane in lanes_list:
        lock_sfp_lane(lane)


def unlock_sfp_lane(lane):
    """
    Unlock SFP Lane

    :param lane: SFP Lane dist name
    :return: None
    """
    admin_connection.connect_to(bts_host=lmp_address)
    try:
        admin_connection.unlock(dist_name=lane, timeout=60)
    finally:
        admin_connection.teardown()


def unlock_multiple_sfp_lanes(lanes_list):
    """
    Unlock multiple SFP Lanes

    :param lanes_list: SFP Lanes dist names
    :type lanes_list: list
    :return: None
    """
    for lane in lanes_list:
        unlock_sfp_lane(lane)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def get_bfd_parameters_via_gui(dist_name, parameters):
    """
    Get BFD parameters via GUI.

    :param dist_name: Dist name
    :param parameters: list of parameters
    :type parameters: list
    :return: dict with parameters and values
    """
    parameters_dict = dict()
    for parameter in parameters:
        parameters_dict[parameter['param_abbr']] = du_operations.get_gnb_parameter_value_via_gui(
            dist_name=dist_name, param_name=parameter['param_name'], param_abbr=parameter['param_abbr'])
    return parameters_dict


def _get_parameters(dist_name):
    admin_connection.connect_to(bts_host=lmp_address)
    try:
        bts_configuration = admin_connection.get_scf(export_type="configurationAndRuntimeObjects")
    finally:
        admin_connection.teardown()
    return str(bts_configuration).partition('distName="{}"'.format(dist_name))[2].partition('</managedObject>')[0]


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def get_bfd_parameters(dist_name, parameters):
    """
    Get BFD parameters.

    :param dist_name: Dist name
    :param parameters: list of parameters
    :type parameters: list
    :return: dict with parameters and values
    """
    parameters_dict = dict()
    dist_name_params = _get_parameters(dist_name)
    MolerTest.info("BFD parameters:", dump=dist_name_params)
    for parameter in parameters:
        parameters_dict[parameter['param_abbr']] = \
            dist_name_params.partition('<p name="{}">'.format(parameter['param_abbr']))[2].partition('</p>')[0]
    return parameters_dict


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def verify_trigger_state():
    """
    Verify TRIGGER.state == TRUE.

    :return: None
    """
    expected_state = 'TRUE'
    for trigger_dist_name in trigger_dist_names:
        dist_name_params = _get_parameters(trigger_dist_name)
        trigger_state = dist_name_params.partition('<p name="state">')[2].partition('</p>')[0]
        if trigger_state != expected_state:
            MolerTest.error("{}.state != {}, but == {}".format(trigger_dist_name, expected_state, trigger_state))


def get_bbmod_ip_address(dist_name, bbmod_dn_param_name, bbmod_param_name):
    """
    Get BBMOD IP address.

    :param dist_name: MPLANEFHNW dist name
    :param bbmod_dn_param_name: parameter with BBMOD dist name
    :param bbmod_param_name: parameter with BBMOD IP address
    :return: None
    """
    admin_connection.connect_to(bts_host=lmp_address)
    try:
        bts_configuration = admin_connection.get_scf(export_type="configurationAndRuntimeObjects")
    finally:
        admin_connection.teardown()
    dist_name_params = \
        str(bts_configuration).partition('distName="{}"'.format(dist_name))[2].partition('</managedObject>')[0]
    bbmod_ip_dist_name = \
        dist_name_params.partition('<p name="{}">'.format(bbmod_dn_param_name))[2].partition('</p>')[0]
    bbmod_ip_dist_name_params = str(bts_configuration)\
        .partition('distName="{}"'.format(bbmod_ip_dist_name))[2].partition('</managedObject>')[0]
    bbmod_ip = \
        bbmod_ip_dist_name_params.partition('<p name="{}">'.format(bbmod_param_name))[2].partition('</p>')[0]
    return bbmod_ip


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def restore_bfd_parameters(parameters_dict):
    """
    Prepare delta with saved BFD parameters.

    :param parameters_dict: dict with saved bfd parameters values
    :return: dict with delta
    """
    delta = bfd_delta.copy()
    for parameter in delta[0]['parameters']:
        parameter['value'] = parameters_dict[parameter['parameterName']]
    return delta


def run_tcpdump_and_check_bfd_parameters(tcpdump_cmd, delta):
    tcpdump_cmd.command_string = tcpdump_cmd.command_string[4:]
    tcpdump_output = tcpdump_cmd()
    parameters = [_remove_from_list_of_dicts(d, 'operation') for d in delta[0]['parameters']]
    for parameter in bfd_parameters:
        next(item for item in parameters if item["parameterName"] == parameter['param_abbr'])['new_value'] \
            = _check_parameter_value(parameter, tcpdump_output)
    _compare_parameter_values(parameters)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def verify_parameters_change(delta, bts_id=0, du_id=0):
    """
    Compare parameters from delta with actual values.

    :param delta: commissioned delta
    :param bts_id: BTS ID
    :param du_id: DU ID
    :return: dict with delta
    """
    du = DeviceFactory.get_device(device_aliases.ssh_bts_du.format('GNB', bts_id, du_id), initial_state="FSP")
    du.get_cmd(cmd_name="run_script", cmd_params={'script_command': 'ip netns exec radions bash'})()
    tcpdump_cmd = du.get_cmd(cmd_name="cat", cmd_params={'path': 'timeout 18 tcpdump -ni rfoe0.1 dst 10.1.1.2 -v'})
    run_tcpdump_and_check_bfd_parameters(tcpdump_cmd, delta)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def verify_parameters_change_asof(delta=None, bts_id=0, du_id=0):
    """
    Compare parameters from delta with actual values on ASOF.

    :param delta: commissioned delta
    :param bts_id: BTS ID
    :param du_id: DU ID
    :return: dict with delta
    """
    du = DeviceFactory.get_device(device_aliases.ssh_bts_du.format('GNB', bts_id, du_id), initial_state="FCT")
    du.get_cmd(cmd_name="run_script", cmd_params={'script_command': 'bsh 0:1', "prompt": "asc.*#"})()
    du.get_cmd(cmd_name="run_script", cmd_params={'script_command': 'ip netns exec radions bash', "prompt": "asc.*#"})()
    tcpdump_cmd = du.get_cmd(cmd_name="cat", cmd_params={'path': 'timeout 18 tcpdump -ni rfoe4.1 dst 10.1.1.2 -v',
                                                         "prompt": "asc.*#"})
    run_tcpdump_and_check_bfd_parameters(tcpdump_cmd, delta)
    try:
        du.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": r"asc.*#"})()
    except Exception:
        pass


def _remove_from_list_of_dicts(old_dict, key):
    n = old_dict.copy()
    n.pop(key, None)
    return n


def _check_parameter_value(parameter, tcpdump_output):
    for line in tcpdump_output["LINES"]:
        msg = re.search(parameter['message_regex'], line)
        if msg and parameter['param_abbr'] == 'bfdDscp':
            # get DSCP from ToS
            return int(bin(int(msg.group('VALUE'), 16))[2:].zfill(8)[:-2], 2)
        elif msg:
            return msg.group('VALUE')
    return None


def _compare_parameter_values(parameters):
    error_list = list()
    for parameter in parameters:
        if parameter['value'] != parameter['new_value']:
            error_list.append("Incorrect value of parameter {parameterName}: expected: {value}, actual: {new_value}"
                              .format(**parameter))
    if error_list:
        MolerTest.error("Incorrect values after bfd parameters change:", dump=error_list)
