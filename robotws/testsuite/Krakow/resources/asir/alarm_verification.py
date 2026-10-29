import logging
from testsuite.Krakow.resources.emssim.emssim_operations import emssim_operations


def verify_if_alarm_visible_in_emssim(alarm_id, alarm_activity):
    alarms = emssim_operations().refresh_and_get_alarms()
    alarm_exists = False
    for alarm_info in alarms:
        if int(alarm_info['ID']) == alarm_id and alarm_info['ACTIVITY'] == alarm_activity:
            logging.info("Alarm: exists: {}".format(alarm_info))
            alarm_exists = True

    if not alarm_exists:
        raise Exception("Alarm ID: {}, ACTIVITY: {} not visible in ALARM HISTORY: {}".format(
            alarm_id, alarm_activity, alarms))


def verify_rfc_dl_input_power_low_alarm_01_is_raised_on_emssim():
    verify_if_alarm_visible_in_emssim(alarm_id=3100016, alarm_activity='SET')


def verify_rfc_dl_input_power_low_alarm_01_is_cleared_on_emssim():
    verify_if_alarm_visible_in_emssim(alarm_id=3100016, alarm_activity='CANCEL')


def verify_rfc_dl_input_power_overload_alarm_01_is_raised_on_emssim():
    verify_if_alarm_visible_in_emssim(alarm_id=3100022, alarm_activity='SET')


def verify_rfc_dl_input_power_overload_alarm_01_is_cleared_on_emssim():
    verify_if_alarm_visible_in_emssim(alarm_id=3100022, alarm_activity='CANCEL')


def verify_rfc_over_temperature_alarm_is_raised_on_emssim():
    verify_if_alarm_visible_in_emssim(alarm_id=3100003, alarm_activity='SET')


def verify_rfc_over_temperature_alarm_is_cleared_on_emssim():
    verify_if_alarm_visible_in_emssim(alarm_id=3100003, alarm_activity='CANCEL')
