import json
import time

from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.utilities.test_config import get_repository_path
from taf.rfrl.utilities.tl_config import get_radio
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console


def load_gnb_delta(delta, bts_id, timeout=300):
    bts_id = int(bts_id)
    gnb_comm = GnbCommissioning()
    gnb_comm.perform_bts_delta_commissioning(delta=delta, bts_id=bts_id, timeout=timeout)


def load_bts_delta_from_file(delta_json_file, bts_id=0, delta_purpose=None, timeout=300):
    delta_json_path = '{}{}'.format(get_repository_path(), delta_json_file)
    delta_file = open(delta_json_path)
    delta_json = delta_file.read()
    delta_json = json.loads(delta_json)
    load_gnb_delta(delta=delta_json, bts_id=bts_id, timeout=timeout)
    if delta_purpose:
        log_info_to_console(delta_purpose, log_hierarchy=2)


def adjust_dist_name(dist_name, bts_id=0, du_id=0):
    bts = GenericBts()
    return bts.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id)


def get_bts_rats(bts_id=0):
    bts = GnbDuOperations()
    bts_info = bts.get_bts_info(bts_id)
    bts_rats = [k for k, v in bts_info['cells'].items() if v]
    log_info_to_console(f'BTS RATs: {bts_rats}')
    return bts_rats


def check_if_cells_are_disabled_after_rat_reset(rat_type='NR', bts_id=0):
    rat_type = rat_type.lower()
    if rat_type == 'gsm':
        gnb_du = GnbDuOperations()
        gsm_rat_state = gnb_du.get_bts_info(bts_id=bts_id)['ratState']['gsm']
        if gsm_rat_state != 'ALL_FAILED':
            raise Exception(f'GSM rat state: {gsm_rat_state} is different than expected ALL_FAILED')
    else:
        gnb_cell = GnbCellOperations()
        gnb_cell.wait_for_all_cells_statuses(bts_id=bts_id, cell_type=rat_type, availability_status='offline',
                                             operational_state='disabled', usage_state='idle')


def rat_reset(bts_id=0, rat_type='NR', reset_type='Soft', timeout=900):
    gnb_du = GnbDuOperations()
    gnb_cell = GnbCellOperations()
    rat_type = rat_type.upper()
    log_info_to_console(f'Restarting {rat_type} RAT')
    rat_cell_ids = gnb_cell.get_all_global_cell_ids(bts_id=bts_id, cell_type=rat_type.lower())
    log_info_to_console(f'{rat_type} cells ids: {rat_cell_ids}')
    gnb_du.rat_reset(rat_type=rat_type, bts_id=bts_id, timeout=timeout, reset_type=reset_type)
    log_info_to_console(f'{rat_type} RAT was restarted')
    other_bts_rats = get_bts_rats(bts_id=bts_id)
    other_bts_rats.remove(rat_type.lower())
    if other_bts_rats:
        for other_rat in other_bts_rats:
            gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, cell_type=other_rat.lower())
            log_info_to_console(f'All {other_rat.upper()} cells are not affected')
    check_if_cells_are_disabled_after_rat_reset(rat_type=rat_type, bts_id=bts_id)
    log_info_to_console(f'Waiting max {timeout}s for {rat_type} cells to be OnAir')
    gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, cell_type=rat_type.lower(), timeout=timeout)
    log_info_to_console(f'All {rat_type} cells are OnAir')


def block_rat(bts_id=0, rat='NR'):
    gnb_du = GnbDuOperations()
    gnb_alarm = GnbAlarmVerification()
    gnb_cell = GnbCellOperations()
    rat = rat.upper()
    gnb_du.block_rat(bts_id=bts_id, rat=rat, timeout=180)
    log_info_to_console(f'{rat} RAT is blocked')
    gnb_alarm.wait_for_alarm_activation(fault_id='4614', awaiting_time=60, bts_id=bts_id)
    log_info_to_console(f'Alarm `RAT is blocked` is active')
    gnb_cell.verify_all_cells_statuses(
        bts_id=bts_id,
        cell_type=rat.lower(),
        availability_status='offline',
        operational_state='disabled',
        blocking_state='blocked',
        usage_state='idle'
    )
    log_info_to_console(f'All {rat} cells are blocked')


def unblock_rat(bts_id=0, rat='NR'):
    gnb_du = GnbDuOperations()
    gnb_alarm = GnbAlarmVerification()
    gnb_cell = GnbCellOperations()
    rat = rat.upper()
    gnb_du.unblock_rat(bts_id=bts_id, rat=rat, timeout=180)
    log_info_to_console(f'{rat} RAT is unblocked')
    log_info_to_console(f'Waiting for {rat} cells to be OnAir')
    gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id)
    log_info_to_console(f'All {rat} cells are OnAir')
    gnb_alarm.verify_alarm_is_not_active(fault_name='RAT blocked', fault_id='4614', bts_id=bts_id)
    log_info_to_console(f'Alarm `RAT is blocked` is not active')


def block_bts(bts_id=0):
    gnb_du = GnbDuOperations()
    gnb_cell = GnbCellOperations()
    gnb_ru = GnbRuOperations()
    gnb_alarm = GnbAlarmVerification()
    gnb_du.block_bts(bts_id=bts_id, timeout=180)
    log_info_to_console(f'BTS{bts_id} is blocked')
    log_info_to_console(f'Waiting for all cells to be `disabled`')
    gnb_cell.wait_for_all_cells_statuses(
        bts_id=bts_id, availability_status='offline',
        operational_state='disabled',
        administrative_state='unlocked',
        blocking_state='blocked',
        usage_state='idle'
    )
    log_info_to_console(f'All cells are `disabled`')
    gnb_ru.verify_all_radio_units_statuses(
        bts_id=bts_id,
        availability_status='online',
        operational_state='enabled',
        administrative_state='unlocked',
        procedural_status='configured',
        usage_state='idle'
    )
    log_info_to_console(f'All RUs are `enabled` and `idle`')
    gnb_alarm.wait_for_alarm_activation(fault_id='50', awaiting_time=60, bts_id=bts_id)
    log_info_to_console(f'Alarm `BTS is blocked` is active')


def unblock_bts(bts_id=0):
    gnb_du = GnbDuOperations()
    gnb_cell = GnbCellOperations()
    gnb_ru = GnbRuOperations()
    gnb_alarm = GnbAlarmVerification()
    log_info_to_console(f'Unblocking BTS{bts_id}')
    gnb_du.unblock_bts(bts_id=bts_id, timeout=300)
    log_info_to_console('BTS{} is unblocked, waiting to be OnAir'.format(bts_id))
    gnb_du.wait_for_site_to_be_onair(bts_id=bts_id)
    log_info_to_console('BTS{} is OnAir'.format(bts_id))
    log_info_to_console(f'Waiting for all cells to be OnAir')
    gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, timeout=900)
    log_info_to_console('All cells are OnAir')
    gnb_ru.verify_all_radio_units_statuses(
        bts_id=bts_id,
        availability_status='online',
        operational_state='enabled',
        administrative_state='unlocked',
        procedural_status='configured',
        usage_state='active'
    )
    log_info_to_console(f'All RUs are enabled and active')
    gnb_alarm.verify_alarm_is_not_active(fault_name='BTS blocked', fault_id='50', bts_id=bts_id)
    log_info_to_console(f'Alarm `BTS is blocked` is not active')


def rf_power_reset(bts_id=0, init_radio_unit_id=0, radio_type='rmod', affected_cells_states=None):
    gnb_ru = GnbRuOperations()
    gnb_alarm = GnbAlarmVerification()
    gnb_cell = GnbCellOperations()
    gnb_alarm.check_if_sw_incompatible_alarm_occurred()
    ru_config = gnb_ru.get_radio_unit_configuration_based_on_tl_config_id(bts_id=bts_id, ru_id=init_radio_unit_id)
    ru_id = ru_config["configuration_id"]
    gnb_ru.power_reset_radio_unit(bts_id=bts_id, radio_unit_id=init_radio_unit_id)
    log_info_to_console(f'RMOD-{ru_id} is power restarted')
    gnb_alarm.wait_for_alarm_activation(fault_id='10', awaiting_time=60, bts_id=bts_id)
    gnb_alarm.verify_alarm_occurrences(fault_name='No connection to unit', occurrences=1, bts_id=bts_id)
    log_info_to_console(f'Alarm `No connection to unit` is active')
    gnb_ru.verify_radio_unit_statuses(
        bts_id=bts_id,
        ru_id=ru_id,
        radio_type=radio_type,
        availability_status='notinstalled',
        operational_state='disabled',
        administrative_state='unlocked',
        procedural_status='not initialized',
        usage_state='idle'
    )
    log_info_to_console(f'RMOD-{ru_id} is disabled')
    if affected_cells_states:
        for cell_id in affected_cells_states:
            gnb_cell.verify_cell_statuses(
                bts_id=bts_id,
                cell_id=cell_id,
                availability_status=affected_cells_states[cell_id].get('availability_status', None),
                operational_state=affected_cells_states[cell_id].get('operational_state', None),
                administrative_state=affected_cells_states[cell_id].get('administrative_state', None),
                blocking_state=affected_cells_states[cell_id].get('blocking_state', None),
                usage_state=affected_cells_states[cell_id].get('usage_state', None)
            )
        log_info_to_console(f'All affected cells are disabled')
    log_info_to_console(f'Waiting for affected cells to be OnAir')
    time.sleep(60)
    gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, timeout=600, interval=40)
    log_info_to_console(f'All affected cells are OnAir')
    gnb_ru.verify_radio_unit_statuses(
        bts_id=bts_id,
        ru_id=ru_id,
        radio_type=radio_type,
        availability_status='online',
        operational_state='enabled',
        administrative_state='unlocked',
        procedural_status='configured',
        usage_state='active'
    )
    log_info_to_console(f'RMOD-{ru_id} is enabled')
    gnb_alarm.verify_alarm_is_not_active(fault_name='No connection to unit', fault_id='10', bts_id=bts_id)
    log_info_to_console(f'Alarm `No connection to unit` is not active')


def lock_bbmod(bts_id=0, bbmod_id=1, affected_rus=None, affected_cells=None):
    gnb_du = GnbDuOperations()
    gnb_cell = GnbCellOperations()
    gnb_ru = GnbRuOperations()
    log_info_to_console(f'Locking BBMOD{bbmod_id}')
    gnb_du.lock_bbmod(bts_id=bts_id, bbmod_id=bbmod_id, timeout=180)
    gnb_du.verify_bbmod_statuses(
        bts_id=bts_id,
        bbmod_id=bbmod_id,
        operational_state='enabled',
        procedural_status='configured',
        availability_status='online',
        administrative_state='locked'
    )
    log_info_to_console(f'BBMOD{bbmod_id} is locked')
    if affected_rus:
        for ru in affected_rus:
            gnb_ru.verify_radio_unit_statuses(
                bts_id=bts_id,
                ru_id=ru['ru_id'],
                radio_type=ru['radio_type'],
                availability_status='online',
                operational_state='enabled',
                administrative_state='unlocked',
                procedural_status='configured'
            )
        log_info_to_console(f'All possibly affected RUs are enabled')

    if affected_cells:
        for cell_id in affected_cells:
            gnb_cell.verify_cell_statuses(
                bts_id=bts_id,
                cell_id=cell_id,
                availability_status='dependency',
                operational_state='disabled',
                administrative_state='unlocked',
                procedural_status='configured'
            )
        log_info_to_console(f'All affected cells are disabled')


def unlock_bbmod(bts_id=0, bbmod_id=1):
    gnb_du = GnbDuOperations()
    gnb_cell = GnbCellOperations()
    gnb_ru = GnbRuOperations()
    log_info_to_console(f'Unlocking BBMOD{bbmod_id}')
    gnb_du.unlock_bbmod(bts_id=bts_id, bbmod_id=bbmod_id, timeout=180)
    gnb_du.wait_until_bbmod_is_online(bts_id=bts_id, bbmod_id=bbmod_id)
    log_info_to_console(f'BBMOD{bbmod_id} is unlocked')
    gnb_ru.wait_for_all_radio_units_to_be_online(bts_id=bts_id)
    log_info_to_console(f'All possibly affected RUs are enabled')
    gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id)
    log_info_to_console(f'All affected cells are OnAir')


def bbmod_reset(bts_id=0, bbmod_id=1, affected_rus=None, affected_cells=None):
    gnb_du = GnbDuOperations()
    gnb_cell = GnbCellOperations()
    gnb_ru = GnbRuOperations()
    log_info_to_console(f'Reseting BBMOD{bbmod_id}')
    gnb_du.reset_bbmod(bts_id=bts_id, bbmod_id=bbmod_id)
    log_info_to_console(f'BBMOD{bbmod_id} is restarted')
    if affected_rus:
        for ru in affected_rus:
            gnb_ru.verify_radio_unit_statuses(
                bts_id=bts_id,
                ru_id=ru['ru_id'],
                radio_type=ru['radio_type'],
                availability_status='notinstalled',
                operational_state='disabled',
                administrative_state='unlocked',
                procedural_status='not initialized'
            )
        log_info_to_console(f'All affected RUs are disabled')
    if affected_cells:
        for cell_id in affected_cells:
            gnb_cell.verify_cell_statuses(
                bts_id=bts_id,
                cell_id=cell_id,
                availability_status='failed',
                operational_state='disabled',
                administrative_state='unlocked',
                procedural_status='not initialized'
            )
        log_info_to_console(f'All affected cells are disabled')
    log_info_to_console(f'Waiting for BBMOD{bbmod_id} to be online')
    gnb_du.wait_until_bbmod_is_online(bts_id=bts_id, bbmod_id=bbmod_id)
    log_info_to_console(f'BBMOD{bbmod_id} is online')
    log_info_to_console(f'Waiting for all affected RUs to be online')
    gnb_ru.wait_for_all_radio_units_to_be_online(bts_id=bts_id)
    log_info_to_console(f'All affected RUs are online')
    log_info_to_console(f'Waiting for affected cells to be OnAir')
    gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, timeout=900)
    log_info_to_console(f'All affected cells are OnAir')


def bts_power_on(bts_id=0):
    gnb_du = GnbDuOperations()
    gnb_du.bts_power_on(bts_id=bts_id)
    log_info_to_console(f'BTS{bts_id} is powered on')


def bts_power_off(bts_id=0):
    gnb_du = GnbDuOperations()
    gnb_du.bts_power_off(bts_id=bts_id)
    log_info_to_console(f'BTS{bts_id} is powered off')
