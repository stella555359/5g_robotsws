"""
Keywords for Feature CB008969: logs validation and waiting until the next measurement interval.

:author: Jaroslaw Lezon, Arkadiusz Kowalczyk
:contact: jaroslaw.lezon@nokia.com

"""
import logging
import time

from datetime import datetime, timedelta
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations

cell_operations = GnbCellOperations()


def _get_possible_interval_starts(interval, minute):
    """
    Wait until desired minute of an hour
    :param interval: defined measurement window. type: int
    :param minute: desired minute.
    """
    possible_mins = []
    possible_min = minute + interval
    cond = True
    while cond:
        if possible_min > 59:
            possible_min = (possible_min - 60)
        if possible_min != minute:
            possible_mins.append(possible_min)
            possible_min = possible_min + interval
            continue
        else:
            possible_mins.append(possible_min)
            logging.info("Possible minutes: {}".format(possible_mins))
            cond = False
    return possible_mins


def _sleep_until_desired_time(possible_mins, desired_second):
    """
    Wait until desired minute of an hour
    :param possible_mins possible minutes of starting the measurement window.
    :param desired_second second of starting the measurement window.
    """
    while True:
        current_time = datetime.utcnow()
        current_min = current_time.minute
        current_sec = current_time.second
        if current_min not in possible_mins:
            time.sleep(1)
            continue
        else:
            if current_sec != desired_second:
                time.sleep(1)
                continue
            else:
                return False


def strip_date(date):
    """
    Get datetime object from date format: YYYYmmDDHHMMSS.fff+ZZZZ
    :param date: provided date. type: string
    """
    year = int(date.split('.', 1)[0][0:4])
    month = int(date.split('.', 1)[0][4:6])
    day = int(date.split('.', 1)[0][6:8])
    hour = int(date.split('.', 1)[0][8:10])
    minutes = int(date.split('.', 1)[0][-4:-2])
    seconds = int(date.split('.', 1)[0][-2:])
    date = datetime(year=year, month=month, day=day, hour=hour, minute=minutes, second=seconds)
    return date


def validate_link_break_number(breaks_number, interval, journal_results, link_id, soap_results,
                               order=True, previous_journal_results=None, validate=True):
    """
    Check if collected logs provides expected number of link breaks.
    :param breaks_number: number of performed short link breaks.
    :param interval: defined measurement window. type: int
    :param journal_results: provided prints from journal log. e.g.:
    Mar 22 09:43:36 asp-1c ip_mgmtd[922]: 80/INF ip_mgmt: port 27, rx_crcerr 0, rsfec_corr_cw 3882,
    rsfec_uncorr_cw 103368, carrier_lost 37, short_term_carrier_lost 0, rx_frames 2648435, bitmask 0, is_alarm_active 1
    :param link_id: ID of broken link. type: int
    :param soap_results: provided prints from SOAP log. type: dict
    :param order: indicates if Soap and logs are printed in correct order (link 1 first). type: bool
    :param previous_journal_results: provided previous number of carrier breaks from journal log.
    :param validate: indicates if Soap and journal logs needs to be validated. type: bool
    :return: journal_breaks: current number of carrier breaks for both links from journal log for further usage.
    """
    if previous_journal_results is None:
        previous_journal_results = [0, 0]
    journal_breaks = []
    timers = []
    logging.info("Expected link breaks: {}".format(breaks_number))
    for result in journal_results:
        if "grep" in result:
            logging.debug("Skipping line contains grep command - {}".format(result))
            continue
        logging.info("Journal results: {}".format(result))
        results_list = list(result.split(" "))
        logging.info("Results list: {}".format(results_list))
        if len(results_list) > 2:
            timers.append(results_list[2].strip(","))
            journal_breaks.append(results_list[16].strip(","))
    journal_breaks = journal_breaks[-2:]
    logging.info("Journal breaks number: {}".format(journal_breaks))
    logging.info("Breaks timestamps: {}".format(timers))
    if link_id == 1:
        journal_breaks_number = journal_breaks[0]
        previous_journal_result = previous_journal_results[0]
        logging.info("Breaks in Journal: {}".format(journal_breaks_number))
        if order:
            soap_break_number = (list(soap_results.values())[0])[0] * interval
            logging.info("Breaks in SOAP: {}".format(soap_break_number))
        else:
            soap_break_number = (list(soap_results.values())[0])[2] * interval
            logging.info("Breaks in SOAP: {}".format(soap_break_number))
    else:
        journal_breaks_number = journal_breaks[1]
        previous_journal_result = previous_journal_results[1]
        logging.info("Breaks in Journal: {}".format(journal_breaks_number))
        if order:
            soap_break_number = (list(soap_results.values())[0])[2]
            soap_break_number = soap_break_number * interval
            logging.info("Breaks in SOAP: {}".format(soap_break_number))
        else:
            soap_break_number = (list(soap_results.values())[0])[0]
            soap_break_number = soap_break_number * interval
            logging.info("Breaks in SOAP: {}".format(soap_break_number))
    if validate:
        actual_breaks_number = int(journal_breaks_number) - int(previous_journal_result)
        logging.info("Breaks in Journal after subtraction: {}".format(actual_breaks_number))
        if (breaks_number != soap_break_number) or (breaks_number != actual_breaks_number):
            raise ValueError("Actual breaks number: {} differs from SOAP: {} and journal: {} values!".
                             format(breaks_number, soap_break_number, actual_breaks_number))
    return journal_breaks


def wait_until_the_start_of_measurement_window(interval, defined_time=None, dl_timestamp=None, ul_timestamp=None):
    """
    Wait for next measurement period for link breaks observer start.
    :param interval: defined measurement window. type: int
    :param defined_time: predefined second at which measurement window starts. type: int
    :param dl_timestamp: time at which DL measurement window started.
    :param ul_timestamp: time at which UL measurement window started.

    """
    if (dl_timestamp and ul_timestamp) is not None:
        dl_timestamp = strip_date(dl_timestamp)
        ul_timestamp = strip_date(ul_timestamp)
        difference = 60 - (max(dl_timestamp, ul_timestamp) - min(dl_timestamp, ul_timestamp)).seconds
        logging.info("Difference in seconds between UL and DL measurement window start time: {}".format(difference))
        interval_start_minutes = max(dl_timestamp.minute, ul_timestamp.minute)
        if dl_timestamp.minute == ul_timestamp.minute:
            interval_start_seconds = max(dl_timestamp.second, ul_timestamp.second)
        elif dl_timestamp.minute > ul_timestamp.minute:
            interval_start_seconds = dl_timestamp.second
        else:
            interval_start_seconds = ul_timestamp.second
        logging.info("Defined time: {} minute {} second".format(interval_start_minutes, interval_start_seconds))
        defined_time = [interval_start_minutes, interval_start_seconds, difference]
    possible_start_minutes = _get_possible_interval_starts(interval, defined_time[0])
    _sleep_until_desired_time(possible_start_minutes, defined_time[1])
    return defined_time


def wait_until_the_next_minute():
    sleep_time = 60 - datetime.utcnow().second
    time.sleep(sleep_time + 1)


def get_availability_status_of_cell(bts_id=0, du_id=0, cell_id=1):
    """
    Get availabilityStatus of cell
    ...   Author: Jaroslaw Lezon
    ...   Contact: jaroslaw.lezon@nokia.com
    ...   Date: 15.06.2023
    :param bts_id: ID of gNB/eNB, default 0
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :param cell_id: ID of cell, default 1
    :return: String
    """

    key = "availabilityStatus"
    dist_name = cell_operations._get_runtime_cell_dist_name(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
    cell_specific_info = cell_operations.admin.get_cell_specific_info(cell_id=dist_name,
                                                                      connection=cell_operations.rest_alias.format(
                                                                          bts_id, du_id))

    if key not in cell_specific_info["status"]:
        availability_status = "enabled"
    else:
        availability_status = cell_specific_info["status"]["availabilityStatus"]

    return availability_status
