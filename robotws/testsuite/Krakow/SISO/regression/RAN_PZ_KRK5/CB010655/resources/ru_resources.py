import re
from moler.device import DeviceFactory
from moler.exceptions import WrongUsage
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.ul.moler.converter.moler_converter import MolerConverter
from taf.ul.moler.converter.interface import add_device_to_already_loaded_configuration
from taf.rfrl.bts.connections.device_aliases import ssh_bts_du, ssh_bts_du_ru, ssh_cu_unit
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.sbts.oam.coam.admin import admin
from resources import ItemsNotFound, save_file_content_to_file, verify_last_write


tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)


def actions_with_ru(action):
    ru = GnbRuOperations()
    if action == "Reset":
        logger.log_info_to_console(f"Resseting All RUs via WebEm")
        ru.reset_all_radio_unit(timeout=300)
    elif action == "Lock":
        logger.log_info_to_console(f"Locking All RUs via WebEm")
        ru.lock_all_radio_unit()
    elif action == "Unlock":
        logger.log_info_to_console(f"Unlocking All RUs via WebEm")
        ru.unlock_all_radio_unit()
    elif action == "Turn Off":
        logger.log_info_to_console(f"Turn Off (Power Off) All RUs")
        ru.radio_unit_power_off()
    elif action == "Turn On":
        logger.log_info_to_console(f"Turn On (Power On) All RUs")
        ru.radio_unit_power_on()
    else:
        logger.log_warn_to_console(f"Action: {action} not supported by this KW. Please contact with KW autor.")


def get_ru_info(key):
    ru = GnbRuOperations()
    return ru.get_all_radio_unit_info()[0][key]


def get_ru_sw_version():
    gnb_du = GnbDuOperations()
    return gnb_du.get_gnb_parameter_value_via_gui(dist_name="MRBTS-76007/EQM_R-1/APEQM_R-1/RMOD_R-1",
                                                  param_name="RU active SW build", param_abbr="activeSwBuild")


def verify_all_items_are_avaliable_in_file_on_ru(path_to_file, expected_items):
    file_content = get_file_content_from_ru(path_to_file)
    save_file_content_to_file(file_content, "_ru_file_content")
    for item in expected_items:
        for line_num, line in enumerate(file_content):
            if re.match(item, line):
                logger.log_info_to_console(f"Item '{item}' found in file {path_to_file}", log_hierarchy=2)
                count = 0
                for last_write in range(line_num, len(file_content)):
                    if count < 5:
                        if "Reset Counter" not in item and "Item type: Voltage" not in item:
                            if "Last write: " in file_content[last_write]:
                                lw_time = file_content[last_write]
                                lw_time = lw_time[lw_time.index(':') + 1:]
                                if verify_last_write(lw_time):
                                    logger.log_info_to_console(
                                        f"Found Last write and is correct, for item '{item}' - {lw_time}",
                                        log_hierarchy=2)
                                    break
                                else:
                                    raise ItemsNotFound(f"Wrong Last write time  for item '{item}' - {lw_time}.")
                            else:
                                count += 1
                        elif "Reset Counter" in item:
                            r_c = file_content[last_write]
                            reset_count = int(r_c[r_c.index(':') + 1:])
                            if reset_count == 0:
                                raise ItemsNotFound(f"Wrong value of: '{item}'")
                            else:
                                logger.log_info_to_console(f"Found correct value of '{item}' - '{str(reset_count)}'",
                                                           log_hierarchy=2)
                            break
                    else:
                        raise ItemsNotFound(f"Cannot find Last write time for item '{item}'")
                break


def trigger_alarm_on_ru(src, dst, replace_val, commands_to_trigger_alarm_on_ru):
    load_ru_device()
    device = get_device(initial_state="RU")
    for command in commands_to_trigger_alarm_on_ru:
        if "echo" in command.keys():
            for echo_command in command["echo"]:
                command_runner = device.get_cmd(cmd_name="echo",
                                                cmd_params={
                                                    "text": echo_command + " | frmonShellClient 127.0.0.1 2000",
                                                    'text_in_quotation': False})
                output = command_runner()
                logger.log_info_to_console(f"Output from echo command: {output['RESULT'][1]}")
        elif "sed" in command.keys():
            if replace_val is True:
                for sed_command in command["sed"]:
                    command_runner_sed = device.get_cmd(cmd_name="sed",
                                                        cmd_params={
                                                            "options": sed_command,
                                                            'input_files': ["/ram/tempest_inst1.json"]})
                    command_runner = device.get_cmd(cmd_name="sudo", cmd_params={"cmd_object": command_runner_sed})
                    output = command_runner()
                    logger.log_info_to_console(f"Output from sed command: {output}")
        elif "cp" in command.keys():
            command_runner_cp = device.get_cmd(cmd_name="cp", cmd_params={"options": "-f", "src": src, 'dst': dst})
            command_runner = device.get_cmd(cmd_name="sudo", cmd_params={"cmd_object": command_runner_cp})
            command_runner()


def change_timeBetweenSaveOnNVM(src, dst, replace_val, commands_to_change_time_on_ru):
    load_ru_device()
    device = get_device(initial_state="RU")
    for command in commands_to_change_time_on_ru:
        if "echo" in command.keys():
            for echo_command in command["echo"]:
                command_runner = device.get_cmd(cmd_name="echo",
                                                cmd_params={
                                                    "text": echo_command + " | frmonShellClient 127.0.0.1 2000",
                                                    'text_in_quotation': False})
                output = command_runner()
                logger.log_info_to_console(f"Output from echo command: {output['RESULT'][1]}")
        elif "sed" in command.keys():
            if replace_val is True:
                for sed_command in command["sed"]:
                    command_runner_sed = device.get_cmd(cmd_name="sed",
                                                        cmd_params={
                                                            "options": sed_command,
                                                            'input_files': [src]})
                    command_runner = device.get_cmd(cmd_name="sudo", cmd_params={"cmd_object": command_runner_sed})
                    output = command_runner()
                    logger.log_info_to_console(f"Output from sed command: {output}")
        elif "cp" in command.keys():
            command_runner_cp = device.get_cmd(cmd_name="cp", cmd_params={"options": "-f", "src": src, 'dst': dst})
            command_runner = device.get_cmd(cmd_name="sudo", cmd_params={"cmd_object": command_runner_cp})
            command_runner()
    reset_ru_sudo = device.get_cmd(cmd_name="sudo", cmd_params={"sudo_params": 'pssreboot hw | bash'})
    reset_ru_sudo()


def get_file_content_from_ru(path_to_file):
    load_ru_device()
    device = get_device(initial_state="RU")
    cat_command_output = device.get_cmd(cmd_name='cat',
                                        cmd_params={"path": path_to_file})()['LINES']
    return cat_command_output


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


def get_ru_object(gnb_id=0, du_id=0, common_unit_id=0, capacity_unit_id=0, ru_id=0):
    return tl.gnbs[gnb_id].dus[du_id].airscale.common_units[common_unit_id].capacity_units[capacity_unit_id].rus[ru_id]


@load_moler_configuration_from_tl()
def get_ru_ip(gnb_id=0, du_id=0, ru_id=0, productName='AWHQX'):
    conn = admin().connect_to()
    result = conn.get_managed_objects(class_name='RMOD_L', timeout=30)
    admin().teardown_admin(connection=conn)
    for product in result:
        if product["parameters"]["productName"] == productName:
            return product["parameters"]["ipAddress"]
    raise Exception(f"Cannot find RU {productName} in your config")
    # ru_ipaddr = None
    # radio_unit = get_ru_object(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id)
    # ru_name = radio_unit.radio_type
    # ru_serial = radio_unit.serial_number
    # pattern_ru_addr = re.compile(r'(\d+\.\d+\.\d+\.\d+);{};{}'.format(ru_serial, ru_name))
    # device = DeviceFactory.get_device(name=ssh_bts_du.format("GNB", gnb_id, du_id))
    # device.goto_state("FCT")
    # rus_info = device.get_cmd(cmd_name='cat',
    #                           cmd_params={"path": "/rom/config/FRIps.txt"})()['LINES']
    # for ru_info in rus_info:
    #     match_ipaddr = re.search(pattern_ru_addr, ru_info)
    #     if match_ipaddr:
    #         ru_ipaddr = match_ipaddr.group(1)
    #         return ru_ipaddr
    #     if not ru_ipaddr:
    #         logger.log_info_to_console("Not found ip address of '{}' RU with serial number '{}' in "
    #                                    "'/rom/config/FRIps.txt'".format(ru_name, ru_serial), log_hierarchy=2)


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
