from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from moler.device import DeviceFactory
from taf.rfrl.bts.connections import device_aliases
from moler.util.moler_test import MolerTest
from taf.sbts.oam.coam.admin import admin
from ta_moler.device.ru import RadioUnit
from robot.libraries.BuiltIn import BuiltIn


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def get_ru_uptime(bts_id=0, du_id=0, ru_id=0):
    """
    Get RU uptime.

    :param bts_id: BTS ID
    :param du_id: DU ID
    :param ru_id: RU ID
    :return: None
    """
    du = DeviceFactory.get_device(device_aliases.ssh_bts_du_ru.format('GNB', bts_id, du_id, ru_id), initial_state="RU")
    uptime = du.get_cmd(cmd_name="uptime")()
    return uptime["UPTIME_SECONDS"]


@load_moler_configuration_from_tl()
def update_asirmod_address(bts_id=0, du_id=0, ru_id=0):
    DeviceFactory.get_device(device_aliases.ssh_bts_du_ru.format('GNB', bts_id, du_id, ru_id), initial_state="RU")
    tl = get_builtin_value(param_name="tl")
    ru_config = tl.gnbs[bts_id].dus[du_id].rus[ru_id]
    try:
        admin_connection = admin()
        admin_connection.connect_to()
        asir = admin_connection.get_parameters_for_all(class_name="ASIRMOD")
        asir_info = next([x["serialNumber"], x["ipAddress"]]
                         for x in asir if x["serialNumber"] == ru_config.serial_number)
    finally:
        admin_connection.teardown()
    ru_devices = DeviceFactory.get_devices_by_type(RadioUnit)
    ru_device = next(ru_device for ru_device in ru_devices
                     if ru_device.ru_ip_address == ru_config.default_ssh_connection_details.addr)
    ru_device.ru_ip_address = asir_info[1]
    ru_config.default_ssh_connection_details.addr = asir_info[1]
    BuiltIn().set_global_variable("${tl}", tl)
    load_moler_configuration_from_tl()
    DeviceFactory.get_device(device_aliases.ssh_bts_du_ru.format('GNB', bts_id, du_id, ru_id), initial_state="FHNET")


def verify_all_cells_are_onair_on_all_bts():
    gnbcell = GnbCellOperations()
    tl = get_builtin_value(param_name="tl")
    for bts_id in range(len(tl.gnbs)):
        gnbcell.verify_all_cells_are_onair(bts_id=bts_id)
