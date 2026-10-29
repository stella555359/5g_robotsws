from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import SyslogMessageMatcher as Sm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from datetime import datetime, timedelta

assert_msg = '\n'.join(['{message}', 'Expected: {expected}', 'But was: {current}'])
start_msg = r'*[CellDriver]* has been changed from Unblocked to Blocking*'
stop_msg = r'*[CellDriver]* to OnAirDone*'

SYSLOG_TIMESTAMP_FORMAT = '%d.%m %H:%M:%S.%f'
DATE_CMD_TIME_FORMAT = '%Y-%m-%d %H:%M:%S'


@logged_keyword
def count_all_nr_cells_restart_period(bts_log_file, start_time, end_time):
    timestamp_first_cell_down = get_time_first_cell_down(bts_log_file, start_time=start_time, end_time=end_time)
    timestamp_last_cell_up = get_time_last_cell_up(bts_log_file, start_time=start_time, end_time=end_time)
    return (timestamp_last_cell_up - timestamp_first_cell_down).total_seconds()


@logged_keyword
def get_time_first_cell_down(bts_log_file, start_time, end_time):
    start_time = datetime.strptime(start_time, DATE_CMD_TIME_FORMAT)
    end_time = datetime.strptime(end_time, DATE_CMD_TIME_FORMAT)

    all_starts_list = get_list_of_syslog_prints_with_given_msg(start_msg, bts_log_file)
    for line in all_starts_list:
        log_time = extract_timestamp_from_syslog_line(line)

        if start_time < log_time < end_time:
            blog('CELLS_DOWN_TIMESTAMP: {}'.format(log_time))
            return log_time

    assert False, 'Cannot find appropriate "{}" print in syslog'.format(start_msg)


@logged_keyword
def get_time_last_cell_up(bts_log_file, start_time, end_time):
    start_time = datetime.strptime(start_time, DATE_CMD_TIME_FORMAT)
    end_time = datetime.strptime(end_time, DATE_CMD_TIME_FORMAT)

    all_stops_list = get_list_of_syslog_prints_with_given_msg(stop_msg, bts_log_file)
    for line in all_stops_list:
        log_time = extract_timestamp_from_syslog_line(line)

        if start_time < log_time < end_time:
            blog('CELLS_UP_TIMESTAMP: {}'.format(log_time))
            return log_time

    assert False, 'Cannot find appropriate "{}" print in syslog'.format(stop_msg)


@logged_keyword
def get_list_of_syslog_prints_with_given_msg(regex_of_msg, bts_log_file):
    with LogHelper() as lh:
        finder = lh.add_syslog(bts_log_file)
        list_of_syslog_prints = finder.find_all(Sm(regex_of_msg))
        assert list_of_syslog_prints, assert_msg.format(
            message='Cannot find required prints in syslog',
            expected=regex_of_msg,
            current=list_of_syslog_prints)
    return list_of_syslog_prints


@logged_keyword
def extract_timestamp_from_syslog_line(syslog_line):
    today = datetime.now()
    split_line = syslog_line.split()

    if robot_globals.BTSLOG_LOGGER == 'btslog':
        log_time = datetime.strptime(split_line[1] + ' ' + split_line[2], SYSLOG_TIMESTAMP_FORMAT) + timedelta(hours=1)
    elif robot_globals.BTSLOG_LOGGER == 'lmp_logger':
        log_time = datetime.strptime(split_line[0] + ' ' + split_line[1], SYSLOG_TIMESTAMP_FORMAT) + timedelta(hours=1)
    else:
        raise Exception('Please enter a valid btslog_logger method. Available methods: "btslog", "lmp_logger"')

    return log_time.replace(year=today.year)
