from moler.device import DeviceFactory
from moler.exceptions import CommandFailure
from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn
from taf.hw.rf_attenuator import rf_attenuator as attenuator
from taf.internal.sbts.admin.exceptions import AdminApiConnectionClosedException, AdminApiProcedureFailureException
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.devices.exceptions import SwUpgradeException
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.ue.rpc.mtk.interface import mtk
import testsuite.Krakow.RRM.RAN_PZ.resources.small_cells.tl_configuration_keywords as tl_configuration_keywords
from testsuite.Krakow.RRM.RAN_PZ.resources.small_cells.tl_configuration_keywords import set_ue_apn
from taf.rfrl.ue.connections.device_aliases import ue_pc
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.ue.custom_ues import AndroidUe
import time

admin_connection = admin()
att = attenuator()
tl = BuiltIn().get_variable_value('${tl}')
ue_sn = "lepin"

swipe_up_coordinates = [1030, 1080, 1030, 380]
attach_at_commands = ["AT+EFUN=1"]
detach_at_commands = ["AT+EFUN=0"]
sa_at_commands = ["AT+EFUN=0", "AT+ERAT=15", "AT+E5GOPT=3", "AT+CEMODE=0", "AT+EFUN=1"]
nsa_at_commands = ["AT+EFUN=0", "AT+ERAT=19", "AT+E5GOPT=5", "AT+CEMODE=0", "AT+EFUN=1"]
tl_configuration_keywords.apn_config = {"5gkrk": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                                                  "key_events_combination": [20, 20, 20, 20, 20, 20, 66, 20, 20, 20,
                                                                             20, 20, 20, 20, 20, 20, 66, 61, 61, 66]},
                                        "5gsakrk": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                                                    "key_events_combination": [20, 20, 20, 20, 20, 20, 66, 20, 20, 20,
                                                                               20, 20, 20, 20, 20, 20, 66, 20, 61, 61,
                                                                               66]}}
hostname = tl.ues[0].ssh_connection_details.addr
username = tl.ues[0].ssh_connection_details.username
password = tl.ues[0].ssh_connection_details.password
port = tl.ues[0].server_port
server_dir = tl.ues[0].server_dir
python_path = tl.ues[0].python_path
edb_file_path = tl.ues[0].edb_file_path
enb_address = tl.enbs[0].oam_ip.v4
enb_id = tl.enbs[0].global_bts_id


@MolerTest.raise_background_exceptions()
def set_cell_attenuation(attenuation_ports, values_in_db):
    """
    Set cell attenuation.

    :param list attenuation_ports: list of attenuator ports
    :param list values_in_db: attenuation values in db
    :return: None
    """
    att1 = att.setup_attenuator(attenuator=tl.attenuator[0], alias='att')
    for attenuation_port, value_in_db in zip(attenuation_ports, values_in_db):
        att.set_attenuation(port=attenuation_port, value=value_in_db, attenuator_device=att1)
        attenuation = att.read_attenuation(port=attenuation_port, attenuator_device=att1)
        if attenuation != value_in_db:
            MolerTest.error("Attenuation not changed")


def get_all_global_cell_ids(radio_id=None):
    """
    Returns global ids of all cells from a bts with given id

    :param radio_id: radio unit ID, if None - cells from all rus are returned
    :return:        cell ids as ints in tuple
    """
    admin_connection.connect_to(bts_host=enb_address)
    cells_info = admin_connection.get_cells_info(cell_type="lte")
    admin_connection.teardown()
    cell_ids = []
    for cell_number in cells_info:
        if radio_id is None or \
                'RMOD_R-{}'.format(radio_id) in cell_number['carrierList'][1]['antennaLineId']['internal']:
            cell_ids.append(int(cell_number["globalCellId"]))
    cell_ids.sort(key=int)
    return tuple(cell_ids)


def block_all_lte_cells():
    """
    Block all lte cells.

    :return: None
    """
    cell_ids = get_all_global_cell_ids()
    admin_connection.connect_to(bts_host=enb_address)
    try:
        for cell_id in cell_ids:
            admin_connection.block_cell("MRBTS-{0}/LNBTS-{0}/LNCEL-{1}".format(enb_id, cell_id), timeout=60)
    finally:
        admin_connection.teardown()


def unblock_all_lte_cells():
    """
    Block all lte cells.

    :return: None
    """
    cell_ids = get_all_global_cell_ids()
    admin_connection.connect_to(bts_host=enb_address)
    for cell_id in cell_ids:
        admin_connection.unblock_cell("MRBTS-{0}/LNBTS-{0}/LNCEL-{1}".format(enb_id, cell_id), timeout=60)
    admin_connection.teardown()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def unlock_ue_screen(ue_id=0):
    """
    Unlock UE screen.

    :param int ue_id: UE id in __init__.py
    :return: None
    """
    ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    check_screen_lock_cmd = "adb shell dumpsys power | grep mHoldingDisplaySuspendBlocker"
    screen_lock_status_cmd = ue_pc_device.get_cmd(cmd_name="cat", cmd_params={'path': check_screen_lock_cmd})
    screen_lock_status_cmd.command_string = screen_lock_status_cmd.command_string[4:]
    screen_lock_status = screen_lock_status_cmd()['LINES'][0]
    if "false" in screen_lock_status:
        press_lock_button_cmd = "adb shell input keyevent 26"
        swipe_up_command = "adb shell input touchscreen swipe {0} {1} {2} {3}".format(*swipe_up_coordinates)
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': press_lock_button_cmd})()
        MolerTest.sleep(1)
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': swipe_up_command})()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def reboot_mtk_ue(timeout=45, interval=5, ue_id=0):
    """
    Reboot mediatek UE.

    :param int timeout: timeout
    :param int interval: interval
    :param int ue_id: UE id in __init__.py
    :return: None
    """
    ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': "adb reboot"})()
    _time = time.perf_counter() + timeout
    while _time > time.perf_counter():
        adb_devices_cmd = ue_pc_device.get_cmd(cmd_name="adb_devices")
        devices_dict = adb_devices_cmd()
        for ue_device in devices_dict["DEVICES"]:
            if ue_sn == ue_device:
                MolerTest.info("UE reboot successfully completed")
                MolerTest.sleep(15)
                return
        MolerTest.sleep(interval)
    MolerTest.error("UE reboot not completed within {} seconds".format(timeout))


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def disable_30mhz_bandwidth_support_on_mtk_ue(ue_id=0):
    """
    Disable 30MHz bandwidth support on MTK UE.

    :param int ue_id: UE id in __init__.py
    :return: None
    """
    ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': "adb root"})()
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': "adb remount"})()
    ue_pc_device.get_cmd(cmd_name="cd", cmd_params={'path': "/cygdrive/c/Mediatek/m80_disable_30mhz_n66/"})()
    ue_pc_device.get_cmd(cmd_name="run_script",
                         cmd_params={'script_command': "adb push MTK_OTA.mcfota /mnt/vendor/nvcfg/mdota"})(timeout=60)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def enable_30mhz_bandwidth_support_on_mtk_ue(ue_id=0):
    """
    Enable 30MHz bandwidth support on MTK UE.

    :param int ue_id: UE id in __init__.py
    :return: None
    """
    ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': "adb root"})()
    try:
        ue_pc_device.get_cmd(cmd_name="run_script",
                             cmd_params={'script_command': "adb shell rm /mnt/vendor/nvcfg/mdota/MTK_OTA.mcfota"})()
    except CommandFailure as e:
        if "No such file or directory" not in str(e):
            raise
        else:
            MolerTest.info("30MHz bandwidth already enabled")


@MolerTest.raise_background_exceptions()
def run_at_commands(at_commands):
    """
    Run AT commands on MTK UE.

    :param list at_commands: list of AT commands
    :return: None
    """
    mtk_device = mtk()
    mtk_device.configure(hostname=hostname, port=port, username=username, password=password, server_dir=server_dir,
                         python_path=python_path)
    mtk_device.setup()
    mtk_device.create_proxy()
    mtk_device.connect_device(edb_file_path=edb_file_path)
    for command in at_commands:
        mtk_device.send_at_command(command)
        MolerTest.sleep(3)
    mtk_device.teardown()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def verify_mtk_ue_attached():
    airplane_mode_coordinates = {"all_ues": {"x": "500", "y": "800"}}
    ue = AndroidUe(ue_id=0, airplane_mode_coordinates=airplane_mode_coordinates)
    if not ue.get_ue_ip():
        MolerTest.error("UE is not attached", raise_exception=True)


def enable_sa_support():
    """
    Enable SA support on MTK UE.

    :return: None
    """
    run_at_commands(sa_at_commands)


def enable_nsa_support():
    """
    Enable NSA support on MTK UE.

    :return: None
    """
    run_at_commands(nsa_at_commands)


def mtk_attach():
    """
    Attach MTK UE.

    :return: None
    """
    run_at_commands(attach_at_commands)
    verify_mtk_ue_attached()


def mtk_detach():
    """
    Detach MTK UE.

    :return: None
    """
    run_at_commands(detach_at_commands)


def set_mtk_ue_apn(apn_name):
    """
    Set APN on MTK UE.

    :param string apn_name: APN name
    :return: None
    """
    unlock_ue_screen()
    set_ue_apn(apn_name)


def reupload_sw(bts_id=0, du_id=0, target_path="/tmp", update_timeout=600):

    bts_operations = GnbDuOperations()
    bts_sw_update = GnbSwUpdate()
    try:
        bts_sw_version = bts_operations.get_bts_sw_version()
        sw_path = bts_sw_update.download_sw_package(bts_sw_version, target_path)
        bts_sw_update.update_software(sw_package_dir=sw_path, timeout=update_timeout, bts_id=bts_id, du_id=du_id)
    except (AdminApiConnectionClosedException, AdminApiProcedureFailureException):
        raise SwUpgradeException
