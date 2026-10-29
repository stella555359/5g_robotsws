from robot.api import logger
import datetime
import json
from ta5g_enb import ta5g_enb
from ta5g_admin_operations import ta5g_admin_operations
from ta5g_delta.utils import get_delta_scf_path


def get_date_from_du(remote_host=None):
    ta5g_enb_instance = ta5g_enb()
    date_from_du = ta5g_enb_instance.execute_enb_command("date +%Y/%m/%d/%H/%M/%S", remote_host)
    date_from_du = "".join(date_from_du.split())
    now = datetime.datetime.strptime(date_from_du, "%Y/%m/%d/%H/%M/%S")
    return now


def add_time_in_minutes_to_current_date(current_date, time_delta):
    now_plus_delta = current_date + datetime.timedelta(minutes=int(time_delta))
    day_of_week_plus_delta = now_plus_delta.weekday()
    hour_plus_delta = now_plus_delta.hour
    minute_plus_delta = now_plus_delta.minute
    return (now_plus_delta, day_of_week_plus_delta, hour_plus_delta, minute_plus_delta)


def update_scfc_lbpsPeriodList_parameters_with_given_values(
    found_scfc_filepath, day_of_week_plus_delta, hour_plus_delta, minute_plus_delta,
        nrpgrp=1, lbpsPeriodList_idx=0
):
    days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

    with open(found_scfc_filepath, 'r') as file:
        user_data = json.load(file)

        nrpgrp_idx = 0
        parameter_idx = 0

        for distName in user_data:
            if ('distName', 'MRBTS-1/NRBTS-1/NRPGRP-{}'.format(nrpgrp)) in distName.items():
                for parameterName in distName.get('parameters'):
                    if ('parameterName', 'lbpsPeriodList') in parameterName.items():
                        for value in parameterName.get('value'):
                            print(value)
                        break
                    parameter_idx += 1
                break
            nrpgrp_idx += 1

        user_data[nrpgrp_idx]['parameters'][parameter_idx]['value'][lbpsPeriodList_idx]['lbpsDayOfWeek'] = \
            days[day_of_week_plus_delta]
        user_data[nrpgrp_idx]['parameters'][parameter_idx]['value'][lbpsPeriodList_idx]['lbpsStartTimeHour'] = \
            hour_plus_delta
        user_data[nrpgrp_idx]['parameters'][parameter_idx]['value'][lbpsPeriodList_idx]['lbpsStartTimeMinute'] = \
            minute_plus_delta
    with open(found_scfc_filepath, "w") as write_file:
        write_file.write(json.dumps(user_data))


def set_current_date_in_delta_and_return_lbps_start_time(scfc_filename):
    found_scfc_filepath = get_delta_scf_path(scfc_filename)
    now = get_date_from_du()
    (now_plus_1, day_of_week_plus_1, hour_plus_1, minute_plus_1) = add_time_in_minutes_to_current_date(now, 1)
    update_scfc_lbpsPeriodList_parameters_with_given_values(
        found_scfc_filepath, day_of_week_plus_1, hour_plus_1, minute_plus_1)
    return [now_plus_1]


def set_correct_2_lbpsPeriodList_parameters_in_delta_and_return_lbps_start_time(scfc_filename):
    found_scfc_filepath = get_delta_scf_path(scfc_filename)
    now = get_date_from_du()
    (now_plus_1, day_of_week_plus_1, hour_plus_1, minute_plus_1) = add_time_in_minutes_to_current_date(now, 1)
    (now_plus_15, day_of_week_plus_15, hour_plus_15, minute_plus_15) = add_time_in_minutes_to_current_date(now, 15)
    update_scfc_lbpsPeriodList_parameters_with_given_values(
        found_scfc_filepath, day_of_week_plus_1, hour_plus_1, minute_plus_1)
    update_scfc_lbpsPeriodList_parameters_with_given_values(
        found_scfc_filepath, day_of_week_plus_15, hour_plus_15, minute_plus_15, lbpsPeriodList_idx=1)
    return [now_plus_1, now_plus_15]


def set_overlapping_2_lbpsPeriodList_parameters_in_delta_and_return_lbps_start_time(scfc_filename):
    found_scfc_filepath = get_delta_scf_path(scfc_filename)
    now = get_date_from_du()
    (now_plus_1, day_of_week_plus_1, hour_plus_1, minute_plus_1) = add_time_in_minutes_to_current_date(now, 1)
    (now_plus_11, day_of_week_plus_11, hour_plus_11, minute_plus_11) = add_time_in_minutes_to_current_date(now, 11)
    update_scfc_lbpsPeriodList_parameters_with_given_values(
        found_scfc_filepath, day_of_week_plus_1, hour_plus_1, minute_plus_1)
    update_scfc_lbpsPeriodList_parameters_with_given_values(
        found_scfc_filepath, day_of_week_plus_11, hour_plus_11, minute_plus_11, lbpsPeriodList_idx=1)
    return [now_plus_1, now_plus_11]


def set_correct_2_nrpgrp_parameters_in_delta_and_return_lbps_start_time(scfc_filename):
    found_scfc_filepath = get_delta_scf_path(scfc_filename)
    now = get_date_from_du()
    (now_plus_1, day_of_week_plus_1, hour_plus_1, minute_plus_1) = add_time_in_minutes_to_current_date(now, 1)
    update_scfc_lbpsPeriodList_parameters_with_given_values(
        found_scfc_filepath, day_of_week_plus_1, hour_plus_1, minute_plus_1)
    update_scfc_lbpsPeriodList_parameters_with_given_values(
        found_scfc_filepath, day_of_week_plus_1, hour_plus_1, minute_plus_1, nrpgrp=2)
    return [now_plus_1]


def set_current_date_in_delta_lbpsSuspended(scfc_filename):
    found_scfc_filepath = get_delta_scf_path(scfc_filename)
    now = get_date_from_du()
    (now_plus_1, day_of_week_plus_1, hour_plus_1, minute_plus_1) = add_time_in_minutes_to_current_date(now, 1)
    update_scfc_lbpsPeriodList_parameters_with_given_values(
        found_scfc_filepath, day_of_week_plus_1, hour_plus_1, minute_plus_1)
    update_scfc_lbpsPeriodList_parameters_with_given_values(
        found_scfc_filepath, day_of_week_plus_1, hour_plus_1, minute_plus_1)
    return [now_plus_1]


def wait_for_parameter_value_change_and_assert_if_time_of_change_is_correct(
    time_set_in_delta, power_saving_duration, lbpsPeriodList_index, parameter_name, value,
    moc='NRBTS_A', timeout='1100'
):
    power_saving_end_time = time_set_in_delta[int(lbpsPeriodList_index)-1] + \
        datetime.timedelta(minutes=int(power_saving_duration))
    logger.info('\nPower Saving End Time: {}; '.format(power_saving_end_time), also_console=True)
    ta5g_admin_operations().wait_for_parameter_value_change(parameter_name, value, moc, timeout)
    now = get_date_from_du()
    logger.info('\nCurrent time: {}; '.format(now), also_console=True)
    assert now.weekday() == power_saving_end_time.weekday()
    assert now.hour == power_saving_end_time.hour
    assert now.minute == power_saving_end_time.minute
