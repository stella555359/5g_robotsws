"""
:author/contact: jaroslaw.lezon@nokia.com, damian.silkowski@nokia.com
"""

from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations

du_operations = GnbDuOperations()
ru_operations = GnbRuOperations()
commissioning = GnbCommissioning()
alarm_verification = GnbAlarmVerification()


def get_distname_for_param_t12(bts_id=0, du_id=0):
    return f'MRBTS-{ru_operations.get_global_bts_id(bts_id=bts_id, du_id=du_id)}/EQM-1/APEQM-1/ASIRMOD-'


def check_alarm_is_active(fault_to_verify):
    alarm_verification.verify_alarm_is_active(fault_name=fault_to_verify['fault_name'],
                                              fault_id=fault_to_verify['fault_id'],
                                              alarm_id=fault_to_verify['alarm_id'],
                                              severity=fault_to_verify['severity'])


def check_alarm_is_not_active(fault_to_verify):
    alarm_verification.verify_alarms_are_not_active(alarms_to_be_verified=fault_to_verify)


def set_param_t12_min_max(ru_id, t12Min_value, t12Max_value):
    t12_distname = get_distname_for_param_t12()
    commissioning.perform_configuration_parameter_recommissioning(dist_name=f'{t12_distname}{ru_id}',
                                                                  parameter='t12Min',
                                                                  operation='update',
                                                                  value=t12Min_value,
                                                                  should_activate=True,
                                                                  skip_parameter_relation_errors=True,
                                                                  timeout=180)
    commissioning.perform_configuration_parameter_recommissioning(dist_name=f'{t12_distname}{ru_id}',
                                                                  parameter='t12Max',
                                                                  operation='update',
                                                                  value=t12Max_value,
                                                                  should_activate=True,
                                                                  skip_parameter_relation_errors=True,
                                                                  timeout=180)


def reset_radio(ru_id):
    ru_operations.reset_radio_unit(radio_unit_id=ru_id, radio_type='asirmod')
    ru_operations.wait_for_radio_unit_to_be_online(ru_id=ru_id, radio_type='asirmod')


def lock_and_unlock_ru(ru_id):
    ru_operations.lock_radio_unit(radio_unit_id=ru_id, radio_type='asirmod')
    ru_operations.unlock_radio_unit(radio_unit_id=ru_id, radio_type='asirmod')


def vefify_all_cells_onair(bts_id=0, du_id=0):
    gnb_cell = GnbCellOperations()
    gnb_cell.verify_all_cells_are_onair(bts_id=bts_id, du_id=du_id)
