from robot.api import logger
import time
from datetime import datetime, timedelta
import re
from taf.ue.tm500.rtc.exceptions import RtcOperationFailed

PASS_STATUS = re.compile('.*PASS')
NO_FILEPATH = re.compile(
    '.*C: SCHEDULE_ITEM 0x03 Failure. File path does not exists.')
PROGRESS = re.compile(r'.*"\s*\d\s*(\d*)')


def get_campaign_name_from_path(path):
    parser = re.compile(r'.*\\(.*).xml')
    a = parser.match(path)
    if a:
        return a.group(1)
    else:
        logger.console('No match foudn from campaign path')


def tput_parser(ret_tput):
    if ret_tput:
        pattern = re.compile('DL PDCP')
        lines = ret_tput.splitlines()
        for i, line in enumerate(lines):
            if re.search(pattern, line):
                logger.console('*' * len(lines[i + 1]))
                logger.console('{}'.format(lines[i]))
                logger.console('{}'.format(lines[i + 1]))
                break
        pattern = re.compile('UL PDCP')
        lines = ret_tput.splitlines()
        for i, line in enumerate(lines):
            if re.search(pattern, line):
                logger.console('{}'.format(lines[i]))
                logger.console('{}'.format(lines[i + 1]))
                break
    else:
        logger.console('*' * 70)
        logger.console('No TPUT data available.')
        logger.console('*' * 70)


def user_amount_parser(ret_user):
    LINE_FOUND = False
    UE = 0
    UE_IDLE = 0
    NSA = False
    SA = False
    if ret_user:
        lines = ret_user.splitlines()
        sa_pattern = re.compile(r'.*CELL_OVERVIEW_NR:')
        nsa_pattern = re.compile(r'.*CELL_OVERVIEW:')
        stop_line = re.compile(r'.*RRC_SIGNALLING_RATE')
        line_match = re.compile(r'.*\[CONNECTED UEs\]')

        lines = ret_user.splitlines()

        for line in lines:
            if re.search(nsa_pattern, line):
                NSA = True
            if re.search(sa_pattern, line):
                SA = True
            if re.search(stop_line, line):
                LINE_FOUND = False
                NSA = False
                SA = False
            if re.search(line_match, line) and (NSA or SA):
                LINE_FOUND = True
                continue
            if LINE_FOUND:
                line = " ".join(line.split())
                if line:
                    if SA:
                        connected, inactive, idle = line.split(" ")[3:6]
                    elif NSA:
                        connected, idle = line.split(" ")[3:5]
                    UE = UE + int(connected)
                    UE_IDLE = UE_IDLE + int(idle)
        logger.console('*' * 70)
        logger.console('Connected UEs {}'.format(UE))
        logger.console('Idle UEs {}'.format(UE_IDLE))
        logger.console('*' * 70)


def check_run_status_and_statistics(tma_obj, test_duration):
    if test_duration:
        test_duration = int(test_duration)
    start_time = datetime.now()
    test_timer_start = time.time()
    mci_command_list = ['forw mte  GetStats [ALL] [COMBINED] [COMBINED]',
                        'FORW MTE GETRRCSTATS [] [] [] [1] [1] [ALL] [1] [1]']
    result = {'success': 'FAIL', 'error': 'error from run', 'stop': 'False'}
    i = 0
    logger.console('Run status printing')
    while True:
        try:
            response = tma_obj.provide_running_state_of_campaign_run()
        except RtcOperationFailed as e:
            print('Error in get statistic {}'.format(e))
        logger.console('{} {}'.format(datetime.now(), response))
        pass_match = PASS_STATUS.match(response)
        ready_for_statistics = PROGRESS.match(response)
        if 'No Campaign in progress' in response:
            if i == 2:
                result['error'] = response
                return result
            i += 1
        if 'AUTOMATION_RUN PROGRESS_TC' in response:
            if ready_for_statistics:
                if int(ready_for_statistics.group(1)) == 100:
                    logger.console(
                        'Error situation in TMA. Waiting for recovery...')
                elif int(ready_for_statistics.group(1)) > 80:
                    for cmd in mci_command_list:
                        try:
                            response = tma_obj.execute_mci_command(cmd)
                        except RtcOperationFailed as e:
                            print('Error in execute mci command {}'.format(e))
                        if 'forw mte  GetStats' in cmd:
                            tput_parser(response)
                        else:
                            user_amount_parser(response)
        if 'AUTOMATION_RUN Complete' in response:
            if pass_match:
                print(pass_match.group(0))
                result['success'] = 'PASS'
                result['complete'] = 'OK'
                return result
            else:
                result['success'] = 'FAIL'
                result['error'] = response
                result['complete'] = 'OK'
                return result
        time_elapsed = datetime.now() - start_time
        logger.console(
            'Test time has elapsed (hh:mm:ss.ms) {}'.format(time_elapsed))
        if test_duration:
            seconds = int(time.time() - test_timer_start)
            if seconds >= test_duration * 60:
                result['success'] = 'PASS'
                result['stop'] = 'True'
                return result
        time.sleep(30)
