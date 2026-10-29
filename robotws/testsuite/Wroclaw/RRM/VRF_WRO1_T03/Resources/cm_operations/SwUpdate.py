from taf.sbts.oam.coam.admin import admin
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.devices.ru.ru_operations import GenericRuOperations
from testsuite.Wroclaw.RRM.VRF_WRO1_T03.Resources.tti.TtiDecoder import convert_sw_name_to_trunk
from robot.libraries.BuiltIn import BuiltIn


def check_if_fid23_is_active_and_update_sw():
    admin_cli = admin().connect_to()
    alarms = admin_cli.get_active_alarms()
    for fault_id in alarms:
        if fault_id.get("faultId") == 23:
            BuiltIn().log_to_console(f'FID23 found')
            sw_version = convert_sw_name_to_trunk(admin_cli.get_sw_version())
            BuiltIn().log_to_console(f'GNB sw version: {sw_version}')
            BuiltIn().log_to_console(f'Start gnb sw download')
            sw_path = download_package(sw_version=sw_version, target_dir='/home/ute/Desktop/')
            BuiltIn().log_to_console(f'Start radio sw update')
            update_software(sw_path)
    admin().teardown_admin()
    GenericRuOperations().wait_for_radio_unit_to_be_online()


def download_package(sw_version, target_dir):
    pkg_path = GnbSwUpdate().download_sw_package(sw_version=sw_version, target_dir=target_dir, by_nominal=True)
    BuiltIn().log_to_console(f'Path to the download sw package: {pkg_path}')
    return pkg_path


def update_software(sw_package, timeout=600):
    GnbSwUpdate().update_software(sw_package_dir=sw_package, timeout=timeout)
