import re
from moler.device import DeviceFactory
from moler.exceptions import WrongUsage
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.ul.moler.converter.moler_converter import MolerConverter
from taf.ul.moler.converter.interface import add_device_to_already_loaded_configuration
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.connections.device_aliases import ssh_bts_du, ssh_bts_du_ru, ssh_cu_unit

tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)


def verify_sfp_data_from_bts(expected_items_sfp):
    gnbbbu = GnbDuOperations()
    sfp_data = gnbbbu._get_sfp_data_from_bts()
    for items in sfp_data["connected"]:
        for exp_item in expected_items_sfp:
            data = str(items)
            if exp_item in data:
                logger.log_info_to_console(f"Item '{exp_item}' found in sfp data")
            else:
                raise Exception(f"Item '{exp_item}' not found in sfp data")


def verify_output(output, command):
    if "done ok" in output['RESULT'][1]:
        logger.log_info_to_console(f"Output from command {command} ok", log_hierarchy=2)
    else:
        raise Exception(f"Something wrong in output from command {command}. \nOutput: {output['RESULT'][1]}")


def read_temperature_data_from_ru():
    load_ru_device()
    device = get_device(initial_state="RU")
    create_sfp_info_agent()
    read_info_commands(device)
    command = "\"/SI action sfp_override_memory 1 PAGE PAGE_1 96 DATA 80\""
    command_num_3 = device.get_cmd(cmd_name="echo",
                                   cmd_params={
                                       "text": command + " | frmonShellClient 127.0.0.1 2000",
                                       'text_in_quotation': False})
    output = command_num_3()
    verify_output(output, command)
    command = "\"/SI action sfp_override_memory 2 PAGE PAGE_1 96 DATA 10\""
    command_num_4 = device.get_cmd(cmd_name="echo",
                                   cmd_params={
                                       "text": command + " | frmonShellClient 127.0.0.1 2000",
                                       'text_in_quotation': False})
    output = command_num_4()
    verify_output(output, command)
    read_info_commands(device)
    command = "\"/SI action cancel_sfp_override_memory 1\""
    command_num_5 = device.get_cmd(cmd_name="echo",
                                   cmd_params={
                                       "text": command + " | frmonShellClient 127.0.0.1 2000",
                                       'text_in_quotation': False})
    output = command_num_5()
    verify_output(output, command)
    command = "\"/SI action cancel_sfp_override_memory 2\""
    command_num_6 = device.get_cmd(cmd_name="echo",
                                   cmd_params={
                                       "text": command + " | frmonShellClient 127.0.0.1 2000",
                                       'text_in_quotation': False})
    output = command_num_6()
    verify_output(output, command)
    read_info_commands(device)
    terminate_sfp_info_agent()


def read_info_commands(device):
    command = "\"/SI action read_info 1\""
    command_num_1 = device.get_cmd(cmd_name="echo",
                                   cmd_params={
                                       "text": command + " | frmonShellClient 127.0.0.1 2000",
                                       'text_in_quotation': False})
    output = command_num_1()
    verify_output(output, command)
    command = "\"/SI action read_info 2\""
    command_num_2 = device.get_cmd(cmd_name="echo",
                                   cmd_params={
                                       "text": command + " | frmonShellClient 127.0.0.1 2000",
                                       'text_in_quotation': False})
    output = command_num_2()
    verify_output(output, command)


def get_device(initial_state, gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=True):
    if initial_state is None:
        device = DeviceFactory.get_device(
            name=ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".
                                      format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")))
    else:
        device = DeviceFactory.get_device(
            name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                      "{}_{}".format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")),
            initial_state="RU")
    return device


def get_ru_object(gnb_id=0, du_id=0, ru_id=0):
    return tl.gnbs[gnb_id].dus[du_id].airscale.common_units[0].capacity_units[0].rus[ru_id]


@load_moler_configuration_from_tl()
def get_ru_ip(gnb_id=0, du_id=0, ru_id=0):
    ru_ipaddr = None
    radio_unit = get_ru_object(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id)
    ru_name = radio_unit.radio_type
    ru_serial = radio_unit.serial_number
    pattern_ru_addr = re.compile(r'(\d+\.\d+\.\d+\.\d+);{};{}'.format(ru_serial, ru_name))
    device = DeviceFactory.get_device(name=ssh_bts_du.format("GNB", gnb_id, du_id))
    device.goto_state("FCT")
    rus_info = device.get_cmd(cmd_name='cat',
                              cmd_params={"path": "/rom/config/FRIps.txt"})()['LINES']
    for ru_info in rus_info:
        match_ipaddr = re.search(pattern_ru_addr, ru_info)
        if match_ipaddr:
            ru_ipaddr = match_ipaddr.group(1)
            logger.log_info_to_console("Found ip address of '{}' RU with serial "
                                       "number '{}': '{}'".format(ru_name, ru_serial, ru_ipaddr), log_hierarchy=2)
            return ru_ipaddr
        if not ru_ipaddr:
            logger.log_info_to_console("Not found ip address of '{}' RU with serial number '{}' in "
                                       "'/rom/config/FRIps.txt'".format(ru_name, ru_serial), log_hierarchy=2)


def load_ru_device(factory_device=True, gnb_id=0, du_id=0, ru_id=0):
    if factory_device:
        rfsw_credentials = get_builtin_value("rfsw_credentials")
    else:
        rfsw_credentials = None
    ru_address = get_ru_ip(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id)
    ru_object = get_ru_object(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id)
    mc = MolerConverter()
    all_devices = mc.moler_devices.get_moler_device_config()['DEVICES']
    mc.moler_devices. \
        add_ru_configuration(device_name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                                              "{}_{}".format(ru_id,
                                                                             "FACTORY" if factory_device else
                                                                             "DEFAULT")),
                             host=ru_address,
                             login=rfsw_credentials['username'] if factory_device else
                             ru_object.default_ssh_connection_details.username,
                             password=rfsw_credentials['password'] if factory_device else
                             ru_object.default_ssh_connection_details.password,
                             proxy_pc_host=tl.test_pc.default_ssh_connection_details.addr,
                             proxy_pc_login=tl.test_pc.default_ssh_connection_details.username,
                             proxy_pc_password=tl.test_pc.default_ssh_connection_details.password,
                             bts_host=tl.gnbs[gnb_id].cu.oam_ssh_connection_details.addr,
                             bts_login=tl.gnbs[gnb_id].cu.oam_ssh_connection_details.username,
                             bts_password=tl.gnbs[gnb_id].cu.oam_ssh_connection_details.password)
    try:
        add_device_to_already_loaded_configuration(config=all_devices)
    except WrongUsage:
        device = DeviceFactory.get_device(
            name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                      "{}_{}".format(ru_id, "FACTORY" if factory_device else "DEFAULT")))
        device.ru_ip_address = ru_address


def create_sfp_info_agent(gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=True, initial_state=None):
    load_ru_device()
    if initial_state is None:
        device = DeviceFactory.get_device(
            name=ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".
                                      format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")))
    else:
        device = DeviceFactory.get_device(
            name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                      "{}_{}".format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")),
            initial_state="RU")
    command = "\"/ action create SfpInfo /SI\""
    hostname = device.get_cmd(cmd_name="hostname")
    h = hostname()
    logger.log_info_to_console(f"Running command  {h}: {command}", log_hierarchy=2)
    create_sfp_info = device.get_cmd(cmd_name="echo",
                                     cmd_params={
                                         "text": command + " | frmonShellClient 127.0.0.1 2000",
                                         'text_in_quotation': False})
    output = create_sfp_info()
    logger.log_info_to_console(f"Output from creating SFP Info Agent on: {output['RESULT'][1]}", log_hierarchy=3)
    if "ret / action create SfpInfo /SI ==> done ok" not in output['RESULT']:
        logger.log_info_to_console("Cannot Create SfpInfo")


def terminate_sfp_info_agent(gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=True):
    load_ru_device()
    device = DeviceFactory.get_device(
        name=ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".
                                  format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")), initial_state="RU")
    command = "\"/SI action terminate\""
    hostname = device.get_cmd(cmd_name="hostname")
    h = hostname()
    logger.log_info_to_console(f"Running command  {h}: {command}", log_hierarchy=2)
    terminate_sfp_info = device.get_cmd(cmd_name="echo", cmd_params={
        "text": command + " | frmonShellClient 127.0.0.1 2000", 'text_in_quotation': False})
    output = terminate_sfp_info()
    logger.log_info_to_console(f"Output from terminating SFP Info Agent: {output['RESULT'][1]}", log_hierarchy=3)


def sfp_override_gpio(gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=True, port_id_on_ru=1, action="TX_FAULT",
                      fault="true"):
    load_ru_device()
    device = DeviceFactory.get_device(
        name=ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".
                                  format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")), initial_state="RU")
    command = f"\"/SI action sfp_override_gpio {port_id_on_ru} {action} {fault} \""
    hostname = device.get_cmd(cmd_name="hostname")
    h = hostname()
    logger.log_info_to_console(f"Running command  {h}: {command}", log_hierarchy=2)
    sfp_override = device.get_cmd(cmd_name="echo", cmd_params={"text": command + " | frmonShellClient 127.0.0.1 2000",
                                                               'text_in_quotation': False})
    output = sfp_override()
    logger.log_info_to_console(f"Output from SFP override gpio: {output['RESULT'][1]}", log_hierarchy=3)


def sfp_override_memory(gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=True, port_id_on_ru=1, action="PAGE PAGE_1",
                        fault="0x70 DATA 0x01"):
    load_ru_device()
    device = DeviceFactory.get_device(
        name=ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".
                                  format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")), initial_state="RU")
    command = f"\"/SI action sfp_override_memory {port_id_on_ru} {action} {fault} \""
    hostname = device.get_cmd(cmd_name="hostname")
    h = hostname()
    logger.log_info_to_console(f"Running command  {h}: {command}", log_hierarchy=2)
    sfp_override = device.get_cmd(cmd_name="echo", cmd_params={
        "text": command + " | frmonShellClient 127.0.0.1 2000", 'text_in_quotation': False})
    output = sfp_override()
    logger.log_info_to_console(f"Output from SFP override memory: {output['RESULT'][1]}", log_hierarchy=3)


def cancel_override_memory(gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=True, port_num_id=1):
    load_ru_device()
    device = DeviceFactory.get_device(
        name=ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".
                                  format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")), initial_state="RU")
    command = f"\"/SI action cancel_sfp_override_memory {port_num_id}\""
    hostname = device.get_cmd(cmd_name="hostname")
    h = hostname()
    logger.log_info_to_console(f"Running command  {h}: {command}", log_hierarchy=2)
    terminate_sfp_info = device.get_cmd(cmd_name="echo",
                                        cmd_params={
                                            "text": command + " | frmonShellClient 127.0.0.1 2000",
                                            'text_in_quotation': False})
    output = terminate_sfp_info()
    logger.log_info_to_console(f"Output from terminating SFP Info Agent: {output['RESULT'][1]}", log_hierarchy=3)


def perform_recommisioning_on_bts(monitoring_params, param_value):
    logger.log_info_to_console(f"Performing gNB recommisioning: param: "
                               f"{monitoring_params[0]['parameters'][0]['parameterName']}, to value: {param_value}",
                               log_hierarchy=2)
    monitoring_params[0]["parameters"][0]["value"] = param_value
    logger.log_info_to_console(monitoring_params)
    gnb_commisioning = GnbCommissioning()
    gnb_commisioning.perform_bts_delta_commissioning(delta=monitoring_params)


def verify_if_alarm_is_visible_on_ru(expected_alarms, gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=True):
    load_ru_device()
    device = DeviceFactory.get_device(
        name=ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".
                                  format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")))
    for alarm in expected_alarms:
        alarm_name = alarm["alarm_name"]
        alarm_id = alarm["alarm_id"]
        alarm_state = alarm["alarm_state"]
        command = f"/ram/fault_history_log_temp.txt| grep -aE '<[-.0-9:TZ]{{27}}>'| tail -{len(expected_alarms)+3}"\
                  f"| grep -ia \"{alarm_name}\" | grep -a \"{alarm_id}\" | grep -a \"{alarm_state}\""
        alarms_on_ru = device.get_cmd(cmd_name="cat", cmd_params={"path": command})
        output = alarms_on_ru()
        if len(output["LINES"]) > 0:
            logger.log_info_to_console(f"Alarm {alarm_name}({alarm_id}) with state {alarm_state} is visible "
                                       f"on RU.", log_hierarchy=3)
        else:
            logger.log_info_to_console(f"Alarm {alarm_name}({alarm_id}) with state {alarm_state} is not visible on "
                                       f"RU what is not expected.", log_hierarchy=3)
            raise Exception(f"Alarm {alarm_name}({alarm_id}) with state {alarm_state} is not visible on RU.")


class CannotFindMessagesInSyslog(Exception):
    pass


def verify_if_alarm_is_visible_in_log(log_file_path, alarm_ids):
    line_with_alarms = []
    for alarm_id in alarm_ids:
        regexp = "Create detector for {" + alarm_id + "/1} fault source"
        with open(log_file_path, "r") as log_file:
            for line in log_file.readlines():
                if regexp in line:
                    logger.log_info_to_console(f"Find message in syslog: {line}", log_hierarchy=3)
                    line_with_alarms.append(line)
    if len(line_with_alarms) == len(alarm_ids):
        return True
    else:
        raise CannotFindMessagesInSyslog(f"Cannot find expected alarms in syslog {alarm_ids}")


def verify_if_alarm_is_not_visible_in_log(log_file_path, alarm_ids):
    line_with_alarms = []
    for alarm_id in alarm_ids:
        regexp = "Create detector for {" + alarm_id + "/1} fault source"
        with open(log_file_path, "r") as log_file:
            for line in log_file.readlines():
                if regexp in line:
                    line_with_alarms.append(line)
    if len(line_with_alarms) == 0:
        return True
    else:
        raise CannotFindMessagesInSyslog(f"Expected alarms in syslog {alarm_ids} are visible what is not expected")


def is_link_swap_needed():
    gnb_commisioning = GnbCommissioning()
    second_link_config = gnb_commisioning.get_parameters_by_dist_name(
        "MRBTS-{}/EQM_R-1/HWTOP_R-1/CABLINK_R-1002", ["linkModeConfiguration", "secondEndpointPortId"])
    logger.log_info_to_console(second_link_config)
    return second_link_config["parameters"]["linkModeConfiguration"]
