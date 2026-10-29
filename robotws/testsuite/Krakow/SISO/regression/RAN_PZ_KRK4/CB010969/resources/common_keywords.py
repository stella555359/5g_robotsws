import shutil
import time
import re
from os.path import isfile, join
from unittest import TestCase
import logging

from taf.rfrl.bts.devices.du.alarm_verification import GenericAlarmVerification
from taf.rfrl.bts.devices.du.cell_operations import GenericCellOperations
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations, GnbDuOperations
from taf.rfrl.bts.devices.du.commissioning import GenericCommissioning
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.ru.ru_operations import GenericRuOperations
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.connections import device_aliases
from taf.rfrl.utilities import tl_config
from taf.rfrl.utilities.test_config import DefaultFileLocation
from taf.internal.sbts.admin.exceptions.exception import AdminApiProcedureTimeoutException
import taf.ue.interface as taf_ue
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.ue.iperf.tput_runner import DataTransfer
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK4.CB010969.resources.variables import (cell_to_attenuator_output, TRUNK,
                                                                                       max_tput_for_cells, browser)
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_ASIR_Selenium import \
    DevNJ_ASIR_Selenium
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_sbts_selenium import \
    click_reset_site_and_cancel, setup_sbts_selenium_and_login, teardown_sbts_selenium, sbts_selenium_modify_parameters
from taf.selenium.sbts.interface import sbts
from taf.selenium.sbts.pages.modals import ResetModal
from taf.hw.rf_attenuator import rf_attenuator
from moler.device import DeviceFactory
from moler.exceptions import CommandFailure
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from taf.rfrl.utilities.robot.general import is_dry_run
from selenium.common.exceptions import TimeoutException


def get_scf_path(prefix_tag, asir=False):
    dfl = DefaultFileLocation()
    commission_dir = dfl.get_commissioning_dir()
    if asir:
        scf_name = prefix_tag + '_GNB0_ASIR_SCF.xml'
    else:
        scf_name = dfl.get_default_scf_name(bts_type='GNB', bts_id=0, prefix_tag=prefix_tag)
    scf_path = join(commission_dir, scf_name)
    return scf_path


def reset_asir_configuration(cancel=False, save_logs=False):
    mplane_address = tl_config.get_oam_ip_address(bts_id=0, du_id=0, bts_type='GNB')
    asir_address = 'https://' + mplane_address + ':3601'
    asir_hub = GnbAsirHubOperations()
    cell_operations = GenericCellOperations()
    asir_selenium = DevNJ_ASIR_Selenium(virtual_enable=True, debug=True)
    asir_selenium.asir_webem_login(url=asir_address, browser_version="Firefox")
    asir_selenium.reset_configuration(cancel=cancel, save_logs=save_logs)
    asir_selenium.logout()
    if cancel:
        cell_operations.verify_cell_statuses(availability_status='online', operational_state='enabled')
    else:
        BuiltIn().sleep(90)
        cell_operations.wait_for_all_cells_statuses(availability_status='failed', operational_state='disabled',
                                                    expected_cell_amount=2, timeout=120)
        if asir_hub.get_all_hub_ids():
            raise Exception('There are some HUBs in ASiR after ASiR configuration reset')
        asir_hub.verify_number_of_rfc(expected_rfc_number=0)


def perform_asir_commissioning_and_wait_for_onair(scf_path="B5", expected_cell_amount=2):
    if scf_path == "B5":
        scf_path = get_scf_path("CB010969-ED-B5", asir=True)
    asir_hub = GnbAsirHubOperations()
    cell_operations = GenericCellOperations()
    asir_hub.perform_asir_commissioning(scf_path=scf_path, migrate_nidd=False, timeout=240)
    logger.info("asir commissioning performed, waiting for onair...", also_console=True)
    BuiltIn().sleep(120)
    asir_hub.wait_for_asir_to_be_onair()
    cell_operations.wait_for_all_cells_statuses(availability_status='online', operational_state='enabled',
                                                expected_cell_amount=expected_cell_amount, timeout=300)


def get_release():
    if is_dry_run():
        return {}

    mplane_address = tl_config.get_oam_ip_address(bts_id=0, du_id=0, bts_type='GNB')
    cadmin = admin()
    cadmin.setup_admin(bts_host=mplane_address)
    logger.info("Starting get_release", also_console=True)
    try:
        sw_build_branch = cadmin.get_sw_version()
    finally:
        cadmin.teardown_admin()
    sw_build_branch = sw_build_branch.split('_')[0]
    sw_build_branch = 'SBTS00' if sw_build_branch == TRUNK else sw_build_branch
    logger.info(f"sw_build_branch: {sw_build_branch}", also_console=True)
    return sw_build_branch


def site_reset(cancel=False):
    if cancel:
        click_reset_site_and_cancel(virtual_enable=True, browser=browser)
        logger.info("'Reset site' and 'cancel' clicked", also_console=True)
        BuiltIn().sleep(5)
    else:
        sbts = setup_sbts_selenium_and_login(virtual_enable=True, browser=browser)
        try:
            sbts.reset_site(with_graceful=True)
        finally:
            if sbts.start_up_view_window_exists():
                sbts.close_start_up_view_window()
            if sbts is not None:
                try:
                    teardown_sbts_selenium(sbts)
                except TimeoutException:
                    if sbts.start_up_view_window_exists():
                        sbts.close_start_up_view_window()
                    teardown_sbts_selenium(sbts)
                sbts.disable_virtual_display()
        check_if_bts_resets_and_wait_for_onair()


def prepare_ue():
    ue = taf_ue.ue()
    ue.require_ue(ue_alias='UE', capabilities="QUECTEL_UE")
    return ue


def l3_call_dl(ue, cells='all', deviation='20%'):
    try:
        ue.detach_ue(ue_alias='UE')
    except Exception as e:
        logger.info(e, also_console=True)
    if cells == 'all':
        cells = GenericCellOperations().get_all_cells_id()
    for cell in cells:
        set_attenuation(cell)
        BuiltIn().sleep(10)
        try_nr = 0
        last_exc = None
        while try_nr < 5:
            try:
                ue.attach_ue(ue_alias='UE')
                break
            except Exception as exc:
                last_exc = exc
                logger.info(f"Attach attempt failed with: {exc}", also_console=True)
            try_nr += 1
        if try_nr >= 5:
            raise Exception(f"Attach failed {try_nr} times! Exception from last attempt:\n{last_exc}")
        BuiltIn().sleep(10)
        logger.info("Starting data transfer", also_console=True)
        ue.start_data_transfer(dt_name="DT_DL", ue_alias="UE", direction="dl", protocol="udp", duration="20s",
                               throughput=str(max_tput_for_cells[cell]['DL'] + 10) + " Mbits/sec")
        ue.await_data_transfer_finish(dt_name="DT_DL")
        ue.verify_average_throughput_with_deviation(dt_name="DT_DL",
                                                    tput=str(max_tput_for_cells[cell]['DL']) + "Mbits/sec",
                                                    deviation=deviation)
        ue.detach_ue(ue_alias='UE')


def set_attenuation(cell):
    att = rf_attenuator()
    tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
    att.setup_attenuator(attenuator=tl.attenuator)
    all_ports = tl.attenuator.attenuation_port_numbers
    for port in all_ports:
        att.set_attenuation(port=port, value="63db")
    for port in cell_to_attenuator_output[cell]:
        att.set_attenuation(port=port,
                            value="20db")


def commission_bts(scf="B5", version=TRUNK):
    if scf == "B5":
        scf_path = get_scf_path("CB010969-ED-B5")
    else:
        scf_path = scf
    du_op = GenericDuOperations(bts_type='GNB')
    time.sleep(10)
    logger.info("Setting up admin in commission_bts()", also_console=True)
    mplane_address = tl_config.get_oam_ip_address(bts_id=0, du_id=0, bts_type='GNB')
    cadmin = admin()
    cadmin.setup_admin(bts_host=mplane_address)
    try:
        bts_status = cadmin.get_bts_statuses()
    finally:
        cadmin.teardown_admin()
    logger.info(f"bts_status: {bts_status}", also_console=True)
    if bts_status['proceduralState'] != "NotCommissioned":
        raise Exception(f'BTS after configuration reset should be "NotCommissioned" not '
                        f'{bts_status["proceduralState"]}')
    sbts_selenium = setup_sbts_selenium_and_login(url="https://" + mplane_address, virtual_enable=True,
                                                  log_level="debug", version=version, browser=browser)
    try:
        sbts_selenium.load_commissioning_file_and_check_load_status(file_path=scf_path)
        logger.info('Loading SCF file done', also_console=True)
        sbts_selenium.validate_plan()
        relation_errors = sbts_selenium.get_relation_errors()
        definition_errors_status = sbts_selenium.get_definition_status()
        logger.info(f"Relation errors: {relation_errors}", also_console=True)
        logger.info(f"Definition errors status: {definition_errors_status}", also_console=True)
        if version == 'SBTS25R1':
            hw_errors = sbts_selenium.get_hardware_errors()
            logger.info(f"HW errors: {hw_errors}", also_console=True)
            if hw_errors or ('NIDD validation succeeded' not in definition_errors_status):
                raise Exception('There are validation errors in SCF')
        else:
            if 'No data available' not in definition_errors_status:
                raise Exception('There are definition errors in SCF')
        if relation_errors:
            raise Exception('There are relation errors in SCF')
        sbts_selenium.activate_plan()
    finally:
        if sbts_selenium.start_up_view_window_exists():
            sbts_selenium.close_start_up_view_window()
        if sbts_selenium is not None:
            teardown_sbts_selenium(sbts_selenium)
            sbts_selenium.disable_virtual_display()

    logger.info("Waiting for admin connection after commissioning BTS", also_console=True)
    du_op.wait_unitl_connection_via_admin_is_possible(timeout=300)
    wait_for_mplane(du_op)
    GenericCellOperations().wait_for_all_cells_statuses(availability_status='offline', operational_state='disabled',
                                                        expected_cell_amount=8, timeout=500)


def verify_cell_mapping_info():
    nr_cells_mapping = get_nr_cells_mapping()
    verify_nr_cells_mapping(nr_cells_mapping)
    lte_cells_mapping = get_lte_cells_mapping()
    verify_lte_cells_mapping(lte_cells_mapping)


def get_nr_cells_mapping():
    bts_alias = device_aliases.ssh_bts_du.format('GNB', 0, 0)
    bts = DeviceFactory.get_device(bts_alias)
    bts.goto_state(state="FCT", rerun=15)
    scp_nrcells = bts.get_cmd(
        cmd_name="cat",
        cmd_params={
            "path": "/ram/NrCellMappingInfo.txt"
        }
    )
    nr_cells_mapping = scp_nrcells()
    logger.info(f"NR cells mapping: {nr_cells_mapping}", also_console=True)
    return nr_cells_mapping['LINES']


def verify_nr_cells_mapping(nr_cells_mapping):
    cells_lines = []
    for it in range(len(nr_cells_mapping)):
        if 'NRCELL' in nr_cells_mapping[it]:
            cells_lines = nr_cells_mapping[it + 2:]
            break
    if not cells_lines:
        raise Exception('NR cells mapping is empty!')
    TestCase().assertRegex(cells_lines[0], r'0 *0 *1231765504 *120 *0x151. *0x151. *')
    TestCase().assertRegex(cells_lines[2], r'1 *1 *1231765505 *21 *0x151. *0x151. *')
    TestCase().assertRegex(cells_lines[4], r'2 *2 *1231765506 *22 *0x151. *0x151. *')
    TestCase().assertRegex(cells_lines[6], r'3 *3 *1231765507 *23 *0x151. *0x151. *')


def get_lte_cells_mapping():
    bts_alias = device_aliases.ssh_bts_du.format('GNB', 0, 0)
    bts = DeviceFactory.get_device(bts_alias)
    bts.goto_state(state="AASHELL")
    scp_ltecells = bts.get_cmd(
        cmd_name="get_cell_mapping",
        cmd_params={
            "options": "@RROMexe #0x101B"
        }
    )
    lte_cells = scp_ltecells()
    logger.info(f"LTE cells mapping: {lte_cells}", also_console=True)
    return lte_cells


def verify_lte_cells_mapping(lte_cells_mapping):
    if lte_cells_mapping[0]['lcr'] != 11 or \
            lte_cells_mapping[1]['lcr'] != 12 or \
            lte_cells_mapping[2]['lcr'] != 15 or \
            lte_cells_mapping[3]['lcr'] != 16:
        raise Exception('LCR field in LTE cells mapping is other than expected!')
    if lte_cells_mapping[0]['pci'] != 11 or \
            lte_cells_mapping[1]['pci'] != 12 or \
            lte_cells_mapping[2]['pci'] != 15 or \
            lte_cells_mapping[3]['pci'] != 16:
        raise Exception('PCI field in LTE cells mapping is other than expected!')
    if lte_cells_mapping[0]['eutraCelId'] != 19246347 or \
            lte_cells_mapping[1]['eutraCelId'] != 19246348 or \
            lte_cells_mapping[2]['eutraCelId'] != 19246351 or \
            lte_cells_mapping[3]['eutraCelId'] != 19246352:
        raise Exception('eutraCelId field in LTE cells mapping is other than expected!')
    for current_cell in lte_cells_mapping:
        if 'Thor' not in current_cell['L1PoolType']:
            raise Exception(f"L1PoolType field {current_cell['L1PoolType']} in LTE cells mapping is other than "
                            f"expected!")
        if 'Marlin' not in current_cell['L2PoolType']:
            raise Exception(f"L2PoolType field {current_cell['L2PoolType']} in LTE cells mapping is other than "
                            f"expected!")
        if '0x101' not in current_cell['UEC_raw']:
            raise Exception(f"UEC_raw field {current_cell['UEC_raw']} in LTE cells mapping is other than expected!")
        if '0x101' not in current_cell['L2CELL_raw']:
            raise Exception(f"L2CELL_raw field {current_cell['L2CELL_raw']} in LTE cells mapping is other than "
                            f"expected!")
        if '0x101' not in current_cell['CELLC_raw']:
            raise Exception(f"CELLC_raw field {current_cell['CELLC_raw']} in LTE cells mapping is other than expected!")
        if '0x105' not in current_cell['DL-PHY_raw']:
            raise Exception(f"DL-PHY_raw field {current_cell['DL-PHY_raw']} in LTE cells mapping is other than "
                            f"expected!")
        if '0x105' not in current_cell['UL-PHY_raw']:
            raise Exception(f"UL-PHY_raw field {current_cell['UL-PHY_raw']} in LTE cells mapping is other than "
                            f"expected!")


def check_if_bts_resets_and_wait_for_onair():
    du_op = GenericDuOperations(bts_type='GNB')
    for i in range(24):
        if du_op.lmp_is_pingable_from_ws() is False:
            break
    assert du_op.lmp_is_pingable_from_ws() is False
    logger.info("Waiting for onAir after site reset", also_console=True)
    BuiltIn().sleep(120)
    du_op.wait_for_site_to_be_onair()


def wait_for_mplane(du_operations=None):
    if du_operations is None:
        du_op = GenericDuOperations(bts_type='GNB')
    else:
        du_op = du_operations
    for i in range(24):
        if du_op.mplane_is_pingable_from_ws():
            logger.info("M-plane is now pingable", also_console=True)
            return
        else:
            logger.info("M-plane still is not pingable, waiting...", also_console=True)
            BuiltIn().sleep(5)
    assert du_op.mplane_is_pingable_from_ws() is True


def verify_correct_parameter_is_set(dist_name=None, filter_param='Time zone', abbr='timeZone',
                                    expected_value='(GMT+1) Europe/Warsaw', version=TRUNK):
    mrbts_id = tl_config.get_global_bts_id(bts_id=0, du_id=0, bts_type='GNB')
    if dist_name is None:
        dist_name = f'MRBTS-{mrbts_id}/MNL-1'
    sbts_selenium = setup_sbts_selenium_and_login(virtual_enable=True, version=version, browser=browser)
    try:
        value = sbts_selenium.get_parameter_value(dist_name=dist_name, filter_param=filter_param, abbr=abbr)
        if value != expected_value:
            raise Exception(
                f'Parameter {abbr} is different than expected! Current: {value}, expected: {expected_value}')
    finally:
        if sbts_selenium is not None:
            teardown_sbts_selenium(sbts_selenium)
            sbts_selenium.disable_virtual_display()


def verify_plan_activation_when_wrong_param_set(version=TRUNK):
    mrbts_id = tl_config.get_global_bts_id(bts_id=0, du_id=0, bts_type='GNB')
    sbts_selenium = setup_sbts_selenium_and_login(virtual_enable=True, version=version, browser=browser)
    dist_name = f'MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/NRCELL-0'
    filter_param = 'Consecutive radio link outage threshold'
    abbr = 'consecRlOThreshold'
    try:
        base_value = sbts_selenium.get_parameter_value(dist_name=dist_name, filter_param=filter_param, abbr=abbr)
        sbts_selenium.set_parameter_value(dist_name=dist_name, filter_param=filter_param, new_value=110, abbr=abbr)
        if version == TRUNK or version == "SBTS00" or version == "SBTS25R2" or version == "SBTS25R3":
            sbts_selenium.validate_plan()
            definition_errors = sbts_selenium.get_definition_errors()
            logger.info(f"def err: {definition_errors}", also_console=True)
            if 'Given value is too big.' not in definition_errors[0]['Error description']:
                raise Exception(
                    'There is no validation error with "Given value is too big." description when setting out of range '
                    'value in SCF!')
        else:
            validation_error = sbts_selenium.get_error_info_after_set_parameter()
            if 'Given value is too big.' not in validation_error:
                raise Exception(
                    'There is no validation error with "Given value is too big." description when setting out of range '
                    'value in SCF!')
        activation_done = sbts_selenium.activate_plan()
        if activation_done:
            raise Exception('Plan activation is possible when out of range parameter is set!')
        sbts_selenium.undo_changes()
        coam = sbts_selenium.store.get()
        coam.bts_status.site_view.navigate_to()
        value = sbts_selenium.get_parameter_value(dist_name=dist_name, filter_param=filter_param, abbr=abbr)
        if value != base_value:
            raise Exception(
                f'consecRlOThreshold parameter value after udo changes {value} is other than value before '
                f'modification {base_value}!')
    except Exception as e:
        if sbts_selenium is not None:
            logs_dir = BuiltIn().get_variable_value("${OUTPUTDIR}") + '/selenium'
            shutil.copytree(sbts_selenium.screenshot_dir, logs_dir, dirs_exist_ok=True)
        raise e
    finally:
        if sbts_selenium is not None:
            teardown_sbts_selenium(sbts_selenium)
            sbts_selenium.disable_virtual_display()


def wait_for_lmp():
    gb = GenericBts()
    start_time = time.time()
    while time.time() < start_time + 1500:
        if gb.lmp_is_pingable_from_ws():
            break
        else:
            time.sleep(30)
    logger.info("LMP is now pingable from WS", also_console=True)
    BuiltIn().sleep(900)


def update_ru_sw_if_needed():
    sw_incompatible = GenericAlarmVerification(bts_type='GNB', log='',
                                               ru=None).check_if_sw_incompatible_alarm_occurred()
    if sw_incompatible:
        logger.info("Updating RU software due to 'SW incompatible' fault", also_console=True)
        mplane_address = tl_config.get_oam_ip_address(bts_id=0, du_id=0, bts_type='GNB')
        mrbts_id = tl_config.get_global_bts_id(bts_id=0, du_id=0, bts_type='GNB')
        cadmin = admin()
        cadmin.setup_admin(bts_host=mplane_address)
        try:
            current_build = cadmin.get_sw_version()
            current_build = current_build.replace(TRUNK, 'SBTS00')
            sw_package = f"/home/ute/.ute-ca/cache/bts/{current_build}/{current_build}_release_BTSSM_downloadable_A54" \
                         f".zip"
            if not isfile(sw_package):
                sw_package = GnbSwUpdate().download_sw_package(sw_version=current_build,
                                                               target_dir='/home/ute/Downloads')
            try:
                cadmin.update_software(sw_package=sw_package, override_ru_software=True,
                                       independent_sw_update_type="RuSwOnly")
            except AdminApiProcedureTimeoutException:  # WA for PR832661 on SBTS25R2
                GnbDuOperations().smods_power_reset(cu_ids=[0])
            time.sleep(120)
            GenericRuOperations().wait_for_all_radio_units_to_be_online(timeout=720)
            GenericCellOperations().wait_for_cell_statuses(availability_status=re.compile(r'failed|online|-'),
                                                           timeout=520)
            cell_status = cadmin.get_cell_specific_info(cell_id=f'MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/NRCELL-1')['status']
            if cell_status['availabilityStatus'] == 'failed':
                GenericAlarmVerification(bts_type='GNB', log='', ru=None).wait_for_alarm_activation(fault_id=4478,
                                                                                                    awaiting_time=120)
        finally:
            cadmin.teardown_admin()


def load_asir_scf_if_not_present():
    mplane_address = tl_config.get_oam_ip_address(bts_id=0, du_id=0, bts_type='GNB')
    cadmin = admin()
    cadmin.setup_admin(bts_host=mplane_address)
    try:
        alarms = cadmin.get_active_alarms()
    finally:
        cadmin.teardown_admin()
    for alarm in alarms:
        if 'Antennas assignment not available' in alarm['alarmDetail']:
            asir_scf = get_scf_path("CB010969-ED-B5", asir=True)
            expected_cell_amount = 8
            perform_asir_commissioning_and_wait_for_onair(scf_path=asir_scf, expected_cell_amount=expected_cell_amount)
            break
