from taf.rfrl.utilities.logger.custom_logger import log_info_to_console, log_warn_to_console
import os
from taf.sbts.oam.coam.admin import admin
import re
import time
from datetime import datetime
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.pm_counters import wait_for_next_pm_interval_and_get_counters
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader

api = admin()

REPORTCONFIGTOREMOVELIST_PATTERN = re.compile(r'reportConfigToRemoveList\s+\{\s+(?:\d+,?\s+)+},')

REPORTCONFIGTOADDMODLIST_PATTERN = re.compile(r'reportConfigToAddModList\s+{\s+(?:\s+{\s+reportConfigId\s\d{1,2},\s+'
                                              r'reportConfig\sreportConfigNR\s:\s+{\s+reportType\seventTriggered\s:\s+'
                                              r'{\s+eventId\seventA\d\s:\s+(?s:.{1000,1200})},?)*\s+},')

REPORTCONFIGTOADD_PATTERN = re.compile(r'{\s+reportConfigId\s\d{1,2},\s+reportConfig\sreportConfigNR\s:\s+{\s+report'
                                       r'Type\seventTriggered\s:\s+{\s+eventId\seventA\d\s:\s+(?s:.{1000,1100})},?')
MEASIDTOREMOVELIST_PATTERN = re.compile(r'measIdToRemoveList\s+\{\s+(?:\d+,?\s+)+},\s+')

MEASIDTOADDMODLIST_PATTERN = re.compile(r'measIdToAddModList \s+{(?:\s+{\s+measId\s\d{1,2},\s+measObjectId\s\d{1,2},'
                                        r'\s+reportConfigId\s\d{1,2}\s+},?)*\s+}')

MEASIDTOADD_PATTERN = re.compile(r'\s+{\s+measId\s\d{1,2},\s+measObjectId\s\d{1,2},\s+reportConfigId\s\d{1,2}\s+},?')

TIMEEXPIRYMSG_PATTERN = re.compile(r'measConfig\s+{\s+reportConfigToRemoveList\s+\{\s+(?:\d+,?\s+)+},\s+'
                                   r'reportConfigToAddModList\s+{\s+(?:\s+{\s+reportConfigId\s\d{1,2},\s+'
                                   r'reportConfig\sreportConfigNR\s:\s+{\s+reportType\seventTriggered\s:\s+'
                                   r'{\s+eventId\seventA\d\s:\s+(?s:.{1000,1200})},?)*\s+},\s+measIdToRemoveList\s+'
                                   r'\{\s+(?:\d+,?\s+)+},\s+measIdToAddModList\s+{(?:\s+{\s+measId\s\d{1,2},\s+'
                                   r'measObjectId\s\d{1,2},\s+reportConfigId\s\d{1,2}\s+},?)*\s+}\s+}\s+}\s+}\s+}')

FIRSTMEASADD_MSG_PATTERN = re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket'
                                      r'(?s:.{20,500})message\sc1\s:\srrcReconfiguration\s:(?s:.{1000,1400})'
                                      r'measObjectToAddModList(?s:.{1000,1400})reportConfigToAddModList\s+{\s+'
                                      r'(?:\s+{\s+reportConfigId\s\d{1,2},\s+reportConfig\sreportConfigNR\s:\s+'
                                      r'{\s+reportType\seventTriggered\s:\s+{\s+eventId\seventA\d\s:\s+'
                                      r'(?s:.{1000,1200})},?)*\s+},(?s:.{1000,1200})measIdToAddModList\s+{(?:\s'
                                      r'+{\s+measId\s\d{1,2},\s+measObjectId\s\d{1,2},\s+reportConfigId\s'
                                      r'\d{1,2}\s+},?)*\s+},')

A4MEASADD_MSG_PATTERN = re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket(?s:.{20,500})'
                                   r'message\sc1\s:\srrcReconfiguration\s:(?s:.{100,250})measObjectToAddModList'
                                   r'(?s:.{1500,1900})reportConfigToAddModList\s+{\s+(?:\s+{\s+reportConfigId\s'
                                   r'\d{1,2},\s+reportConfig\sreportConfigNR\s:\s+{\s+reportType\seventTriggered'
                                   r'\s:\s+{\s+eventId\seventA\d\s:\s+(?s:.{1000,1200})},?)*\s+},\s+'
                                   r'measIdToAddModList\s+{(?:\s+{\s+measId\s\d{1,2},\s+measObjectId\s\d{1,2},\s+'
                                   r'reportConfigId\s\d{1,2}\s+},?)*\s+},')

PROFILEMEASSWITCH_MSG_PATTERN = re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket'
                                           r'(?s:.{20,500})message\sc1\s:\srrcReconfiguration\s:(?s:.{200,1900})'
                                           r'measConfig\s+{\s+reportConfigToRemoveList\s+\{\s+(?:\d+,?\s+)+},\s+'
                                           r'reportConfigToAddModList\s+{\s+(?:\s+{\s+reportConfigId\s\d{1,2},\s+'
                                           r'reportConfig\sreportConfigNR\s:\s+{\s+reportType\seventTriggered\s:\s+{'
                                           r'\s+eventId\seventA\d\s:\s+(?s:.{1000,1200})},?)*\s+},\s+measIdToRemoveList'
                                           r'\s+\{\s+(?:\d+,?\s+)+},\s+\s+measIdToAddModList \s+{(?:\s+{\s+measId\s'
                                           r'\d{1,2},\s+measObjectId\s\d{1,2},\s+reportConfigId\s\d{1,2}\s+},?)*\s+}')

RETRYTIMER_MSG_PATTERN = re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket(?s:.{20,500})'
                                    r'message\sc1\s:\srrcReconfiguration\s:\s+{(?s:.{100,200})measConfig\s+{\s+'
                                    r'measIdToRemoveList\s+\{\s+(?:\d+,?\s+)+},(?s:.{100,200})gapUE\srelease\s:\sNULL')

NEXT_SUPERVISIONTIMER_MSG_PATTERN = re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket'
                                               r'(?s:.{20,500})message\sc1\s:\srrcReconfiguration\s:\s+{'
                                               r'(?s:.{100,200})measConfig\s+{\s+reportConfigToRemoveList\s+'
                                               r'\{\s+(?:\d+,?\s+)+},\s+reportConfigToAddModList\s+{\s+(?:\s+{\s+'
                                               r'reportConfigId\s\d{1,2},\s+reportConfig\sreportConfigNR\s:\s+{\s+'
                                               r'reportType\seventTriggered\s:\s+{\s+eventId\seventA\d\s:\s+'
                                               r'(?s:.{1000,1200})},?)*\s+},\s+measIdToAddModList \s+'
                                               r'{(?:\s+{\s+measId\s\d{1,2},\s+measObjectId\s\d{1,2},\s+'
                                               r'reportConfigId\s\d{1,2}\s+},?)*\s+},(?s:.{100,200})gapUE\ssetup')

EVENT_TRIGGERED_RECONFIG_PATTERN = re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket'
                                              r'(?s:.{20,500})message\sc1\s:\srrcReconfiguration\s:(?s:.{100,250})'
                                              r'measObjectTo\w{6}List(?s:.{50,1400})reportConfigToRemoveList\s+\{\s+'
                                              r'(?:\d+,?\s+)+},\s+reportConfigToAddModList\s+{\s+(?:\s+{\s+'
                                              r'reportConfigId\s\d{1,2},\s+reportConfig reportConfig\w{2,8}\s:\s+{'
                                              r'\s+reportType\seventTriggered\s:\s+{\s+eventId\sevent\w\d\s:\s+{'
                                              r'(?s:.{600,1300})},?)*\s+measIdToRemoveList\s+\{\s+(?:\d+,?\s+)+},\s+'
                                              r'\s+measIdToAddModList\s+{(?:\s+{\s+measId\s\d{1,2},\s+measObjectId\s'
                                              r'\d{1,2},\s+reportConfigId\s\d{1,2}\s+},?)*\s+},\s+measGapConfig')

TIMESTAMP_PATTERN = re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{1,100})\DL_DCCH')

TIME_FORMAT = '%H:%M:%S.%f'


def check_if_there_is_time_to_run_tc() -> None:
    """
    Waits for next 5min counter period if there isn't enough time to perform the TC scenario
    """
    log_info_to_console(msg='waiting until time is right')
    while True:
        time_now = datetime.now()
        if time_now.minute % 5 <= 3:
            log_info_to_console(msg='The time is right!!!')
            return
        else:
            time.sleep(5)


def _read_ue_log(qxdm_path: str) -> str:
    with open(qxdm_path, 'r', errors='ignore') as f:
        text = f.read()
    return text


def analyze_b_b2_a2_ue_logs(qxdm_path: str) -> None:
    """
    Checking the rrcReconfig msg sent upon ProtectTimer's expiry. It should remove 5 reportConfigId's and configure
    4 new ones with new threshold values for events A2, A3 and A5 based on the values configured in NRMEASPR_IAF that's
    linked to the tested cell. It also should reconfigure 4 new measId's.

    :param qxdm_path: path ue log txt file
    """
    text = _read_ue_log(qxdm_path)
    timer_expiry_reconfig = TIMEEXPIRYMSG_PATTERN.findall(text)[0]
    report_config_to_remove_list = REPORTCONFIGTOREMOVELIST_PATTERN.findall(timer_expiry_reconfig)[0]
    report_config_ids_to_remove = re.compile(r'\d{1,2}').findall(report_config_to_remove_list)
    assert len(report_config_ids_to_remove) == 5, f'Expected 5 reportConfig Id\'s to be removed. ' \
                                                  f'(Id\'s found: {report_config_ids_to_remove}.)'
    report_config_to_add_list = REPORTCONFIGTOADDMODLIST_PATTERN.findall(timer_expiry_reconfig)[0]
    report_config_ids_to_add = REPORTCONFIGTOADD_PATTERN.findall(report_config_to_add_list)
    assert len(report_config_ids_to_add) == 4, f'Expected 4 new reportConfig Id\'s to be added. ' \
                                               f'(Id\'s found: {report_config_ids_to_add}).'
    for report_config_id in report_config_ids_to_add:
        if 'eventA2' in report_config_id:
            assert 'a2-Threshold rsrp : 34' in report_config_id, 'Wrong rsrp threshold value reported for eventA2.'
        elif 'eventA3' in report_config_id:
            assert ('a3-Offset rsrp : 8' in report_config_id) and ('hysteresis 8' in report_config_id), \
                   'Wrong a3 Offset rsrp or hysteresis reported for eventA3..'
        elif 'eventA1' in report_config_id:
            assert 'a1-Threshold rsrp : 101' in report_config_id, 'Wrong rsrp threshold value reported for eventA1.'
        else:
            assert ('a5-Threshold1 rsrp : 45' in report_config_id) and \
                   ('a5-Threshold2 rsrp : 57' in report_config_id), 'Wrong rsrp threshold values reported for eventA5.'
    meas_id_to_remove_list = MEASIDTOREMOVELIST_PATTERN.findall(timer_expiry_reconfig)[0]
    meas_ids_to_remove = re.compile(r'\d{1,2}').findall(meas_id_to_remove_list)
    assert len(meas_ids_to_remove) == 5, f'Expected 5 measId\'s to be removed. Id\'s found: {meas_ids_to_remove}.'
    meas_id_to_add_list = MEASIDTOADDMODLIST_PATTERN.findall(timer_expiry_reconfig)[0]
    meas_ids_to_add = MEASIDTOADD_PATTERN.findall(meas_id_to_add_list)
    assert len(meas_ids_to_add) == 5, f'Expected 5 new meas Id\'s to be added. Id\'s found: {meas_ids_to_add}.'


def _check_counters(counters, paths, check_if_value_higher_than_1=False):
    counter_values = {}
    for path in paths:
        counter_values[path.split('NRBTS-50825')[-1]] = str(counters[path][0]).split(' ')[-1].replace(')', '')
    for counter in counter_values.keys():
        log_info_to_console(msg=f'{counter} counter value: {counter_values[counter]}\n')
        assert int(counter_values[counter]) > 0, f'Counter {counter} value not as expected.'
        if check_if_value_higher_than_1:
            if int(counter_values[counter]) > 1:
                log_warn_to_console(msg=f'Counter {counter} value is above 1.')


def verify_b_b2_a2_counters() -> None:
    """
    Checks if counters M55190C00001 and M55187C00001 have been both incremented by 1 during B_B2_A2 TC
    """
    admin_alias = api.setup_admin(alias='admin_alias')
    counters = wait_for_next_pm_interval_and_get_counters(counter_ids=['M55190C00001', 'M55187C00001'],
                                                          admin_connection=admin_alias)
    api.teardown_admin(alias=admin_alias)
    paths = ['BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMASA-1/MASA/M55190C00001',
             'BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMIAF-1/MIAF/M55187C00001']
    _check_counters(counters, paths, True)


def analyze_b_b2_a2_syslogs(syslog_dir: str) -> None:
    """
    :param syslog_dir: syslog files directory path

    Checks for prints stating that protectTimer was configured, activated at attach and expired after 15 sec
    """
    needed_prints = ['startMeasurementProfProtectTimerService',
                     'measProfProtectTimer Timer is started',
                     'measProfProtectTimer Timer expired for UE']
    lines = []
    for filename in sorted(os.listdir(syslog_dir)):
        filepath = os.path.join(syslog_dir, filename)
        log_info_to_console(msg=f'checking file: {filepath}')
        for line in file_reader(filepath):
            if any(log in line for log in needed_prints):
                lines.append(line)
    log_info_to_console(msg='\nSyslog prints found: ')
    for line in lines:
        log_info_to_console(msg=line)
    for needed_print in needed_prints:
        assert needed_print in str(lines), f'no \'{needed_print}\' print found'
    assert len(lines) == 3, 'Expected to find 3 prints in syslogs, such was not the case.'
    timestamps = [re.compile(r'\s\d{2}:\d{2}:\d{2}.\d{3}').findall(log)[0].replace(' ', '') for log in lines]
    protect_timer = ((datetime.strptime(timestamps[2], TIME_FORMAT) - datetime.strptime(timestamps[0], TIME_FORMAT))
                     .total_seconds())
    assert 14.9 <= protect_timer <= 15.1, f'ProtectTimer lasted {protect_timer}seconds. (expected 15).'


def analyze_a_b10_logs(qxdm_path: str) -> None:
    """
    Checks that all the A1, A2, A3, A5measurements are taken from thresholds defined under NRCELL after attach. Then
    A4 ones from NRCELL/NRHOIF are added (A4 supervisionTimer starts here). Then they're all switched to thresholds
    defined under NRMEASPR_MA_SA-1. After VoNR call start, measurements are switched to NRMEASPR_MA_SA-2 based ones.
    During VoNR call, 10 seconds from supervisionTimer start should pass - retryTimer starts removing the A4
    measurements. Once the call ends, all the existing measurements (A1, A2, A3, A5) are switched back to
    NRMEASPR_MA_SA-1 based ones. Then after another 10 seconds from retryTimer start, supervisionTimer starts again
    taking measurements from NRMEASPR_MA_SA-1.

    :param qxdm_path: path ue log txt file
    :return:
    """
    text = _read_ue_log(qxdm_path)
    first_meas_add_msg = FIRSTMEASADD_MSG_PATTERN.findall(text)[0]
    _confirm_event_thresholds(first_meas_add_msg, ['a2-Threshold rsrp : 67',
                                                   'a2-Threshold rsrp : 38',
                                                   'a3-Offset rsrp : 6',
                                                   'a5-Threshold1 rsrp : 12',
                                                   'a5-Threshold2 rsrp : 12',
                                                   'a1-Threshold rsrp : 99'])
    supervision_timer_1_msg = A4MEASADD_MSG_PATTERN.findall(text)[0]
    supervision_timer_1_start = _return_messages_timestamps(supervision_timer_1_msg)

    _confirm_event_thresholds(supervision_timer_1_msg, ['a4-Threshold rsrp : 35',
                                                        'a4-Threshold rsrp : 50',
                                                        'a4-Threshold rsrp : 34'])
    profile_switch_msgs = PROFILEMEASSWITCH_MSG_PATTERN.findall(text)
    profile_switch_timestamps = _return_messages_timestamps(profile_switch_msgs)
    _confirm_event_thresholds(profile_switch_msgs[0], ['a4-Threshold rsrp : 44',
                                                       'a2-Threshold rsrp : 34',
                                                       'a3-Offset rsrp : 8',
                                                       'a5-Threshold1 rsrp : 45',
                                                       'a5-Threshold2 rsrp : 57',
                                                       'a4-Threshold rsrp : 33',
                                                       'a1-Threshold rsrp : 101'])
    _confirm_event_thresholds(profile_switch_msgs[1], ['a4-Threshold rsrp : 54',
                                                       'a2-Threshold rsrp : 57',
                                                       'a2-Threshold rsrp : 38',
                                                       'a3-Offset rsrp : 9',
                                                       'a5-Threshold1 rsrp : 46',
                                                       'a5-Threshold2 rsrp : 58',
                                                       'a4-Threshold rsrp : 32',
                                                       'a1-Threshold rsrp : 102'])
    _confirm_event_thresholds(profile_switch_msgs[2], ['a2-Threshold rsrp : 34',
                                                       'a3-Offset rsrp : 8',
                                                       'a5-Threshold1 rsrp : 45',
                                                       'a5-Threshold2 rsrp : 57',
                                                       'a1-Threshold rsrp : 101'])
    retry_timer_msgs = RETRYTIMER_MSG_PATTERN.findall(text)
    retry_timer_timestamps = _return_messages_timestamps(retry_timer_msgs)
    second_supervision_timer_msg = NEXT_SUPERVISIONTIMER_MSG_PATTERN.findall(text)[0]
    second_supervision_timer_timestamp = _return_messages_timestamps(second_supervision_timer_msg)
    _confirm_event_thresholds(second_supervision_timer_msg, ['a4-Threshold rsrp : 44',
                                                             'a4-Threshold rsrp : 33'])

    log_info_to_console(msg=f"{supervision_timer_1_start[0]} "
                            f"-> first supervitionTimer started (measurements taken from NRCELL)")
    log_info_to_console(msg=f"{profile_switch_timestamps[0]} -> a4 measurements switched to NRMEASPR_MA_SA-1")
    log_info_to_console(msg=f"{profile_switch_timestamps[1]} "
                            f"-> VoNR call started (measurements switched to NRMEASPR_MA_SA-2)")
    log_info_to_console(msg=f"{retry_timer_timestamps[0]} -> retryTimer started (a4 measurements removed)")
    log_info_to_console(msg=f"{profile_switch_timestamps[2]} "
                            f"-> VoNR call ended (measurements switched to NRMEASPR_MA_SA-1)")
    log_info_to_console(msg=f"{second_supervision_timer_timestamp[0]} -> second supervisionTimer started "
                            f"(measurements taken from NRMEASPR_MA_SA-1)")

    assert round((datetime.strptime(profile_switch_timestamps[0], TIME_FORMAT) -
                  datetime.strptime(supervision_timer_1_start[0], TIME_FORMAT)).total_seconds()) == 0, \
        "a4 measurements should be switched to NRMEASPR_MA_SA-1 ones right after first supervisionTimer start"
    assert round((datetime.strptime(retry_timer_timestamps[0], TIME_FORMAT) -
                  datetime.strptime(supervision_timer_1_start[0], TIME_FORMAT)).total_seconds()) == 10, \
        "retryTimer should start 10 seconds after first supervisionTimer"
    assert round((datetime.strptime(second_supervision_timer_timestamp[0], TIME_FORMAT) -
                  datetime.strptime(retry_timer_timestamps[0], TIME_FORMAT)).total_seconds()) == 10, \
        "second supervisionTimer should start 10 seconds after first retryTimer"


def _return_messages_timestamps(messages: list) -> list:
    return [timestamp.split(' ')[0] for timestamp in list(TIMESTAMP_PATTERN.findall(str(messages)))]


def _confirm_event_thresholds(msg, expected_thresholds):
    thresholds = re.compile(r'[ab]\d-\S{6,15}\srsr\w\s:\s\d{1,3}').findall(msg)
    assert thresholds == expected_thresholds, f"Expected thresholds {expected_thresholds}, but got {thresholds}"


def verify_a_b10_counters() -> None:
    """
    Checks if counters M55190C00001, M55187C00001, M55187C00003, M55188C00001 and M55188C39806 have been all
    incremented during A_B10 TC
    """
    admin_alias = api.setup_admin(alias='admin_alias')
    counters = wait_for_next_pm_interval_and_get_counters(counter_ids=['M55190C00001', 'M55187C00001', 'M55187C00003',
                                                                       'M55188C00001', 'M55188C39806'],
                                                          admin_connection=admin_alias)
    api.teardown_admin(alias=admin_alias)
    paths = ['BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMASA-1/MASA/M55190C00001',
             'BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMASA-2/MASA/M55190C00001',
             'BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMIAF-1/MIAF/M55187C00001',
             'BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMIAF-2/MIAF/M55187C00001',
             'BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMIAF-1/MIAF/M55187C00003',
             'BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMIAF-2/MIAF/M55187C00003',
             'BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMIEF-1/MIEF/M55188C00001',
             'BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMIEF-2/MIEF/M55188C00001',
             'BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMIEF-1/MIEF/M55188C39806',
             'BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRMIEF-2/MIEF/M55188C39806'
             ]
    _check_counters(counters, paths)


def analyze_c_b11_logs(qxdm_path: str) -> None:
    """
    Checks that eventA2 is triggered immediately after attach in poor conditions, removing a2 measId and configuring
    A1, A5 and B2 measurements.
    Then after crossing A1 event threshold, it removes those measIds and configures eventA2 measurement again.
    :param qxdm_path: path ue log txt file
    :return:
    """
    log_info_to_console(msg='Starting Analysis of C_B11 Test Case')
    text = _read_ue_log(qxdm_path)
    reconfig_msgs = EVENT_TRIGGERED_RECONFIG_PATTERN.findall(text)
    report_config_ids_to_remove_a2 = (re.compile(r'\d{1,2}').
                                      findall(REPORTCONFIGTOREMOVELIST_PATTERN.findall(reconfig_msgs[0])[0]))
    assert report_config_ids_to_remove_a2 == ['1'], \
        'Expected reportConfigId 1 to be removed upon eventA2 trigger after attach.'
    _confirm_event_thresholds(reconfig_msgs[0], ['a1-Threshold rsrp : 77',
                                                 'a5-Threshold1 rsrq : 15',
                                                 'a5-Threshold2 rsrq : 15',
                                                 'b2-Threshold1 rsrp : 36',
                                                 'b2-Threshold2EUTRA rsrp : 24'])
    meas_ids_to_add = MEASIDTOADDMODLIST_PATTERN.findall(reconfig_msgs[0])[0]
    report_config_ids_added = \
        [rcid.split(' ')[-1] for rcid in re.compile(r'reportConfigId\s\d{1,2}').findall(meas_ids_to_add)]
    report_config_ids_to_remove_a1 = (re.compile(r'\d{1,2}').
                                      findall(REPORTCONFIGTOREMOVELIST_PATTERN.findall(reconfig_msgs[1])[0]))
    assert report_config_ids_added == report_config_ids_to_remove_a1, \
        (f'Expected that the reportConfigId\'s removed in A1-triggered reconfig would have been the ones added in '
         f'A2-triggered reconfig. ID\'s added after A2: {report_config_ids_added}\n '
         f'ID\'s removed after A1: {report_config_ids_to_remove_a1}')
    _confirm_event_thresholds(reconfig_msgs[1], ['a2-Threshold rsrp : 67'])
    log_info_to_console(msg='C_B11 analysis passed!')
