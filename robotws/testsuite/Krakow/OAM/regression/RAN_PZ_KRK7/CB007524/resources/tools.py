from taf.rfrl.bts.devices.du.cell_operations import GenericCellOperations
from robot.api import logger
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from datetime import datetime
import re


def get_current_time():
    now = datetime.now()
    current_time = now.strftime("%Y-%m-%d %H:%M:%S")
    logger.info('Start time {}'.format(current_time))
    return current_time


def wait_for_all_cells_to_be_onair(cells_list):
    generic_cell = GenericCellOperations()
    for cell in cells_list:
        logger.console(f"Checking cell {cell} onair status...")
        generic_cell.wait_for_cell_to_be_onair(cell_id=int(cell),
                                               timeout=300,
                                               interval=10)


def preparing_data(output):
    parameters = ['time', 'fault_id']
    inactive_alarms = output.split('Inactive faults')[-1]
    str_output = inactive_alarms.split('=')[-1]
    regexp = r'(?P<time>\d{4}\-\w{3,4}-\d{2}\s\d{2}:\d{2}:\d{2})\s+\((?P<fault_id>\d{4})\)'
    alarm_list = re.findall(regexp, str_output)
    dict_date = [dict(zip(parameters, alarm)) for alarm in alarm_list]
    return dict_date


def modify_format_of_asir_time(asir_time):
    return asir_time.replace('T', ' ', 1).replace('UTC', '')


def verify_alarm_appear_in_alarm_history_on_asir(allowed_fault_ids, start_time):
    all_alarm = GnbAsirHubOperations().get_historical_asir_webem_alarms()
    alarm_list_after_time = [alarm for alarm in all_alarm
                             if modify_format_of_asir_time(alarm['time_started']) > start_time]
    logger.debug(f'All alarm {alarm_list_after_time}')
    if alarm_list_after_time:
        fault_id_list = list(dict.fromkeys([alarm['fault_id'] for alarm in alarm_list_after_time]))
        logger.debug(f'Alarm in alarm history on asir {fault_id_list}')
        logger.debug(f'Allowed Alarm {allowed_fault_ids}')
        not_expected_alarm = [fault for fault in sorted(fault_id_list) if str(fault) not in sorted(allowed_fault_ids)]
        if not_expected_alarm:
            raise Exception('Fault {} not appear in history list {} after time{}'.format(not_expected_alarm,
                                                                                         alarm_list_after_time,
                                                                                         start_time))
        return
    else:
        logger.info('There is no alarm in history alarms after time {}'.format(start_time))


def block_specific_cells(cell_list):
    for cell in cell_list:
        GenericCellOperations().block_cell(cell_id=cell)
        GenericCellOperations().verify_cell_is_blocked(cell_id=cell)


def unblock_specific_cells(cell_list):
    for cell in cell_list:
        GenericCellOperations().unblock_cell(cell_id=cell)
