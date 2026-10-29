import re

from moler.exceptions import CommandFailure
from taf.hw.rf_attenuator import rf_attenuator
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from taf.rfrl.ue.connections.device_aliases import ue_pc
from taf.rfrl.utilities.robot.general import get_builtin_instance
from taf.ue.android.exceptions import UeSerialNumberUnavailableException
from testsuite.Krakow.RRM.RAN_PZ.resources.small_cells.HpPdu import HpPdu
from taf.sbts.oam.coam.admin import admin
import time

attenuation_sets = {
    "CB008908_A_05": [110, 20, 110, 110, 30, 110, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110],
    "CB008908_A_02": [30, 20, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110],
    "CB008908_B_15": [110, 110, 110, 30, 110, 30, 110, 110, 30, 110, 30, 110, 110, 110, 110, 110],
    "CB008908_B_11": [110, 110, 110, 110, 110, 110, 110, 110, 30, 110, 30, 110, 110, 110, 110, 110],
    "CB008908_B_16": [110, 110, 110, 110, 30, 110, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110],
    "CB007813_A_01": [30, 110, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110],
    "CB007813_A_04": [30, 20, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110],
    "CB007813_A_18": [20, 110, 20, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110],
    "CB007813_A_18_HO_step_1": [40, 110, 40, 110, 110, 110, 110, 110, 110, 110, 110, 110, 100, 110, 100, 110],
    "CB007813_A_18_HO_step_2": [40, 110, 40, 110, 110, 110, 110, 110, 110, 110, 110, 110, 20, 110, 20, 110],
    "CB007813_A_18_HO_step_3": [40, 110, 40, 110, 110, 110, 110, 110, 110, 110, 110, 110, 40, 110, 40, 110],
    "CB007813_A_18_HO_step_4": [20, 110, 20, 110, 110, 110, 110, 110, 110, 110, 110, 110, 40, 110, 40, 110],
    "CB007813_B_23": [30, 110, 30, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110],
    "CB007813_C_34_1": [50, 110, 50, 110, 110, 110, 110, 0, 110, 0, 110, 110, 110, 110, 110, 110],
    "CB007813_C_34_2": [30, 110, 30, 110, 110, 110, 110, 0, 110, 0, 110, 110, 110, 110, 110, 110]}

apn_config = {"5gkrk": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                        "key_events_combination": [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 66, 61, 61, 61, 66]},
              "5gsakrk": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                          "key_events_combination": [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 66, 61, 61, 61, 61,
                                                     61, 61, 66]}}

network_type_config = {
    "NR/LTE": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
               "key_events_combination": [20, 20, 20, 20, 20, 66, 61, 61, 61, 20, 20, 20, 20, 20, 20, 20, 20, 20,
                                          20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
                                          20, 19, 19, 19, 19, 19, 19, 19, 19, 19, 66]},
    "NR": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
           "key_events_combination": [20, 20, 20, 20, 20, 66, 61, 61, 61, 20, 20, 20, 20, 20, 20, 20, 20, 20,
                                      20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
                                      20, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 66]},
    "LTE": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
            "key_events_combination": [20, 20, 20, 20, 20, 66, 61, 61, 61, 20, 20, 20, 20, 20, 20, 20, 20, 20,
                                       20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
                                       19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19,
                                       19, 19, 19, 66]}}

tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)


def set_attenuator_configuration(attenuation_config):
    """
    Set attenuation values for all attenuator port according to proper config set.

    :param string attenuation_config: attenuation set key in 'attenuation_sets' dictionary
    :return: None
    """
    attenuator_device = rf_attenuator()
    attenuator_device.setup_attenuator(attenuator=tl.attenuator)
    actual_port_id = 1
    for port_attenuation in attenuation_sets[attenuation_config]:
        attenuator_device.set_attenuation(port=actual_port_id, value=port_attenuation)
        actual_port_id = actual_port_id + 1


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def set_ue_apn(apn_name, ue_id=0):
    """
    Set defined APN name on UE.

    :param string apn_name: APN name key in 'apn_config' dictionary
    :param int ue_id: UE id in __init__.py
    :return: None
    """
    ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    ue = BuiltIn().get_variable_value('${tl.ues[0]}')
    ue_conf = ue['UE_POOLS']['TafUeAndroidPool']['inline_config']['ANDROID_UE']['CONSTRUCTOR_PARAMETERS']
    ue_serial_number = ue_conf['serial_number']
    start_activity_cmd = "adb -s {} shell 'am start -a {}'".format(ue_serial_number,
                                                                   apn_config[apn_name]["starting_activity"])
    stop_activity_cmd = "adb -s {} shell 'am force-stop {}'".format(ue_serial_number, "com.android.settings")
    time.sleep(5)
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': start_activity_cmd})()
    time.sleep(2)
    for key_event in apn_config[apn_name]["key_events_combination"]:
        time.sleep(0.4)
        key_event_cmd = "adb -s {} shell 'input keyevent {}'".format(ue_serial_number, key_event)
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': key_event_cmd})()
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': stop_activity_cmd})()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def set_preferred_network_type(network_type, ue_id=0):
    """
    Set preferred network type on UE.

    :param string network_type: preferred network type key in 'network_type_config' dictionary
    :param int ue_id: UE id in __init__.py
    :return: None
    """
    ue = BuiltIn().get_variable_value('${tl.ues[0]}')
    ue_conf = ue['UE_POOLS']['TafUeAndroidPool']['inline_config']['ANDROID_UE']['CONSTRUCTOR_PARAMETERS']
    ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    ue_serial_number = ue_conf['serial_number']
    start_activity_cmd = "adb -s {} shell 'am start -a {}'" \
        .format(ue_serial_number, network_type_config[network_type]["starting_activity"])
    stop_activity_cmd = "adb -s {} shell 'am force-stop {}'".format(ue_serial_number, "com.android.settings")
    time.sleep(5)
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': start_activity_cmd})()
    time.sleep(2)
    for key_event in network_type_config[network_type]["key_events_combination"]:
        time.sleep(0.5)
        key_event_cmd = "adb -s {} shell 'input keyevent {}'".format(ue_serial_number, key_event)
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': key_event_cmd})()
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': stop_activity_cmd})()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def lock_ue_pc(ue_id=0):
    """
    Lock UE PC for ongoing automated run.

    :param int ue_id: UE id in __init__.py
    :return: None
    """
    ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    create_lock_file_cmd = "touch LOCK_UE_PC.txt"
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': create_lock_file_cmd})()
    MolerTest.info("UE PC locked with actual automated run")


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def unlock_ue_pc(ue_id=0):
    """
    Unlock UE PC for ongoing automated run.

    :param int ue_id: UE id in __init__.py
    :return: None
    """
    ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    create_lock_file_cmd = "rm LOCK_UE_PC.txt"
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': create_lock_file_cmd})()
    MolerTest.info("UE PC unlocked")


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def check_if_ue_pc_locked(ue_id=0):
    """
    Check actual UE PC lock state.

    :param int ue_id: UE id in __init__.py
    :return bool: UE PC lock state
    """
    ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    cmd_output = ue_pc_device.get_cmd(cmd_name="ls", cmd_params={"path": "~/"})()
    files_in_home_directory = list(cmd_output["files"].keys())
    if "LOCK_UE_PC.txt" in files_in_home_directory:
        return True
    else:
        return False


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def wait_for_ue_pc_is_available(timeout=90):
    """
    Wait for UE PC to enter unlock state with defined timeout.

    :param int timeout: maximal waiting time for UE PC
    :return: None
    """
    start_time = int(time.time() / 60)
    while int(time.time() / 60) - start_time < timeout:
        if not check_if_ue_pc_locked():
            MolerTest.info("UE PC available")
            break
        else:
            MolerTest.warning("UE PC is already used with other automated run. Waiting for release ...")
            time.sleep(60)
    else:
        MolerTest.error("Cannot acquire UE PC device after {} min".format(timeout), raise_exception=True)


def ue_mode_reconfiguration(mode):
    """
    Set UE preferred network mode to SA or NSA.

    :param mode: UE network mode (SA or NSA)
    :return: None
    """
    ue = get_builtin_instance("ue")
    ue.require_ue("UE", "REAL_ANDROID_UE")
    try:
        ue.reboot_ue("UE", 60)
    except UeSerialNumberUnavailableException:
        HpPdu().reset_pdu_port()
        time.sleep(45)
    ue.attach_ue("UE")
    if mode == "SA":
        set_ue_apn(apn_name="5gsakrk")
        set_preferred_network_type("NR")
        ue.attach_ue("UE")
    else:
        set_ue_apn(apn_name="5gkrk")
        set_preferred_network_type("LTE")
        time.sleep(5)
        ue.detach_ue("UE")
        set_preferred_network_type("NR/LTE")
        ue.attach_ue("UE")


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def install_mcshark_plugin():
    """
    Download mcshark plugin.

    :return: None
    """
    mcshark_dir = "/usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/"
    mcshark_device = DeviceFactory.get_cloned_device("GNB0_DU0", "mcshark", initial_state="PROXY_PC")
    rm_cmd = mcshark_device.get_cmd(cmd_name="rm", cmd_params={
        "file": "{}mcshark*".format(mcshark_dir)})
    try:
        rm_cmd()
    except CommandFailure:
        pass
    admin_connection = admin()
    admin_connection.connect_to()
    sw_version = admin_connection.get_sw_version()
    admin_connection.teardown()
    if "_9999_" in sw_version:
        sw_version = re.sub("SBTS[0-9A-Z]*", "SBTS00", sw_version)
    wget_cmd = mcshark_device.get_cmd(cmd_name="wget", cmd_params={
        "options": "-r -e robots=off -np -nH -nd -A '*4.0*buster.so'"
        " https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/{}/"
                   " -P {}".format(sw_version, mcshark_dir)})
    sudo_cmd = mcshark_device.get_cmd(cmd_name="sudo", cmd_params={"cmd_object": wget_cmd})
    sudo_cmd()


@MolerTest.raise_background_exceptions()
def verify_x2_link_is_available():
    """Check if X2 connection to all eNBs is available; if not - return eNB ID for unavailable ones."""
    admin_connection = admin()
    admin_connection.connect_to()
    try:
        lteenb_objects = admin_connection.get_managed_objects(class_name="LTEENB_R")
    finally:
        admin_connection.teardown()
    for _ in range(20):
        for lteenb in lteenb_objects:
            if str(lteenb["parameters"]["eNodeBId"]) != "None":
                break
            time.sleep(5)
    if not lteenb_objects:
        raise AssertionError("Waiting for LTEENB_R object to be available")
    for lteenb in lteenb_objects:
        link_status = lteenb["parameters"]["x2LinkStatus"]
        if "unavailable" in link_status:
            raise AssertionError("X2 link unavailable to {}".format(lteenb["parameters"]["eNodeBId"]))
        return True
