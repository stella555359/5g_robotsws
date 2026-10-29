import re
import time
from datetime import datetime, timedelta

from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from ute_tshark.interface import ute_tshark

ute_tshark = ute_tshark()
api = admin()
_ssh = ssh()

first_meas_add_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket(?s:.{20,600})message\sc1\s:\s'
               r'rrcReconfiguration\s:(?s:.{20,200})measObjectToAddModList(?s:.{20,5000})reportConfigToAddModList'
               r'(?s:.{20,24000})measIdToAddModList(?s:.{20,3400})measGapConfig(?s:.{20,400})nonCriticalExtension')

meas_add_after_a2_trigger_during_retry_timer_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket(?s:.{20,600})message\sc1\s:\s'
               r'rrcReconfiguration\s:(?s:.{20,200})measObjectToAddModList(?s:.{20,5000})reportConfigToAddModList'
               r'(?s:.{20,15000})measIdToAddModList(?s:.{20,2000})measGapConfig(?s:.{20,400})nonCriticalExtension'
               r'(?s:.{20,300})drx-Config\srelease')

meas_add_remove_after_a2_trigger_during_supervision_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket(?s:.{20,600})message\sc1\s:\s'
               r'rrcReconfiguration\s:(?s:.{20,200})measObjectToAddModList(?s:.{20,1200})reportConfigToRemoveList'
               r'(?s:.{20,200})reportConfigToAddModList(?s:.{20,3000})measIdToRemoveList(?s:.{20,400})'
               r'measIdToAddModList(?s:.{20,1800})s-MeasureConfig ssb-RSRP(?s:.{20,600})}(?s:.{1,10})\d{4}')

meas_obj_adds_pattern = re.compile(r'measObjectId\s\d{1,2},(?s:.{20,100})ssbFrequency\s\d{3,7},')

report_config_ids_added_pattern = re.compile(r'reportConfigId\s\d{1,2}(?s:.{20,300})a4-Threshold\srsrp\s:\s\d{1,3}')

meas_ids_added_pattern = re.compile(r'measId \d{1,3}')

following_meas_add_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket(?s:.{20,600})message\sc1\s:\s'
               r'rrcReconfiguration\s:(?s:.{20,9000})measIdToAddModList\s+{(\s+{\s+measId\s\d{1,2},\s+measObjectId'
               r'\s\d{1,2},\s+reportConfigId\s\d{1,2}\s+},?)+\s+},(?s:.{20,100})measGapConfig(?s:.{20,50})gapUE'
               r'\ssetup(?s:.{20,300})nonCriticalExtension(?s:.{20,300})drx-Config release')

meas_add_after_a1_steering_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket(?s:.{20,600})message\sc1\s:\s'
               r'rrcReconfiguration\s:(?s:.{20,600})reportConfigToAddModList(?s:.{4000,8000})measIdToAddModList'
               r'(?s:.{1000,2000})measGapConfig(?s:.{100,600})drx-Config\srelease')

meas_remove_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket(?s:.{20,600})message\sc1\s:\s'
               r'rrcReconfiguration\s:(?s:.{20,200})(measIdToRemoveList\s+\{\s+(?:\d+,?\s+)+)},(?s:.{20,100})'
               r'measGapConfig(?s:.{20,200})nonCriticalExtension')

measIdToRemoveList_pattern = re.compile(r'(measIdToRemoveList\s+\{\s+(?:\d+,?\s+)+)},')

measIdToAddList_pattern = re.compile(r'measIdToAddModList\s+{(\s+{\s+measId\s\d{1,2},\s+measObjectId\s\d{1,2},'
                                     r'\s+reportConfigId\s\d{1,2}\s+},?)+\s+},')

drx_setup_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{20,600})message\sc1\s:\srrcReconfiguration\s:(?s:.{20,400})'
               r'drx-Config setup(?s:.{20,200})drx-InactivityTimer\sms20,(?s:.{20,400})skipUplinkTxDynamic')

meas_report_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket(?s:.{20,600})message\sc1\s:\s'
               r'measurementReport\s:(?s:.{20,200})measId\s\d{0,2},(?s:.{20,250})physCellId\s190')

a2_meas_report_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket(?s:.{20,600})message\s'
               r'c1\s:\smeasurementReport\s:\s(?s:.{200,500})physCellId\s190(?s:.{800,1200})measResultServingCell'
               r'(?s:.{20,100})physCellId\s\d{1,3},(?s:.{40,120})cellResults(?s:.{60,150})rsrp\s\d{1,3},(?s:.{10,40})'
               r'rsrq\s\d{1,3},(?s:.{10,40})sinr\s\d{1,3}(?s:.{10,40})}')

meas_report_serving_cell_pattern = re.compile(r'measResultServingCell(?s:.{20,100})physCellId\s\d{3}')

scellrelease_rrcreconfig_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{5,20})NR5G\sRRC\sOTA\sPacket(?s:.{20,600})message\sc1\s:\s'
               r'rrcReconfiguration\s:(?s:.{20,200})measConfig\s(?s:.{20,1200})nonCriticalExtension\s(?s:.{1000,3500})'
               r'sCellToReleaseList(?s:.{10,60})\d{1,2}')

ca_3cc_configuration_message_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{20,600})message\sc1\s:\srrcReconfiguration\s:(?s:.{20,300})'
               r'measObjectToAddModList(?s:.{1000,3000})reportConfigToAddModList(?s:.{1000,3000})measIdToRemoveList'
               r'(?s:.{50,300})measIdToAddModList(?s:.{1000,2000})spCellConfig(?s:.{6000,10000})sCellToAddModList'
               r'(?s:.{20,200})sCellIndex\s\d(?s:.{12000,21000})sCellIndex\s\d(?s:.{12000,21000})otherConfig')

ca_2cc_configuration_message_pattern = \
    re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{20,600})message\sc1\s:\srrcReconfiguration\s:(?s:.{20,300})'
               r'measObjectToAddModList(?s:.{1000,4500})spCellConfig(?s:.{3000,5000})sCellToAddModList(?s:.{20,200})'
               r'sCellIndex(?s:.{12000,21000})otherConfig')

timestamp_pattern = re.compile(r'\d{1,2}:\d{1,2}:\d{1,2}.\d{1,3}(?s:.{1,100})\DL_DCCH')
time_format = '%H:%M:%S.%f'


def get_time():
    return datetime.now()


def wait_certain_time_after_attach(attach_time, time_passed_wanted):
    while (datetime.now() - attach_time).total_seconds() < \
            int(time_passed_wanted):
        time.sleep(1)
    return


def _read_ue_log(qxdm_path: str) -> str:
    with open(qxdm_path, 'r', errors='ignore') as f:
        text = f.read()
    return text


def _find_rrcreconfig_messages(qxdm_path: str, ) -> tuple[list, list, list, list, list, list]:
    text = _read_ue_log(qxdm_path)

    meas_add_msgs = _find_messages_using_pattern(text, first_meas_add_pattern)
    if len(meas_add_msgs) > 1:
        log_info_to_console(msg='duplicate first measId msg fount, removing the first one.')
        meas_add_msgs = meas_add_msgs[-1:]
    meas_add_msgs.extend(_find_messages_using_pattern(text, following_meas_add_pattern))
    drx_setup_msgs = _find_messages_using_pattern(text, drx_setup_pattern)
    meas_remove_msgs = _find_messages_using_pattern(text, meas_remove_pattern)

    add_msgs_timestamps = _return_messages_timestamps(meas_add_msgs)
    remove_msgs_timestamps = _return_messages_timestamps(meas_remove_msgs)
    drx_setup_timestamps = _return_messages_timestamps(drx_setup_msgs)

    log_info_to_console(msg=('\nmeasid add msgs timestamps: ', add_msgs_timestamps))
    log_info_to_console(msg=('measid remove msgs timestamps: ', remove_msgs_timestamps))
    log_info_to_console(msg=('drx setup timestamps: ', drx_setup_timestamps))

    return meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps


def _find_message_for_iwk7_tc(qxdm_path: str, pattern: re.Pattern) -> tuple[list, list]:
    text = _read_ue_log(qxdm_path)
    message = _find_messages_using_pattern(text, pattern)
    message_timestamp = _return_messages_timestamps(message)
    return message, message_timestamp


def _assert_proper_messages_order(add_msgs_timestamps: list, remove_msgs_timestamps: list, drx_setup_timestamps: list,
                                  number_of_cycles_to_check: int, supervision_timer=5, retry_timer=5) -> None:
    log_info_to_console(msg=f'meas add timestamps to be checked: {add_msgs_timestamps}')
    log_info_to_console(msg=f'meas remove timestamp to be checked: {remove_msgs_timestamps}')
    assert len(add_msgs_timestamps) >= number_of_cycles_to_check, \
        f'amount of measId add msgs lesser than expected ({len(add_msgs_timestamps)})'
    assert len(remove_msgs_timestamps) >= number_of_cycles_to_check, \
        f'amount of measId remove msgs lesser than expected ({len(remove_msgs_timestamps)})'
    assert len(drx_setup_timestamps) >= number_of_cycles_to_check, \
        f'amount of drx setup msgs lesser than expected ({len(drx_setup_timestamps)})'
    for index in range(number_of_cycles_to_check):
        diff_add_remove = round((datetime.strptime(remove_msgs_timestamps[index], time_format) -
                                 datetime.strptime(add_msgs_timestamps[index], time_format)).total_seconds())
        assert abs(diff_add_remove - supervision_timer) <= 1, \
            f'Time between measIdAdd and measIdRemove messages not as expected ' \
            f'(index: {index}, time: {diff_add_remove}s)'
        diff_remove_drx = round((datetime.strptime(drx_setup_timestamps[index], time_format) -
                                 datetime.strptime(remove_msgs_timestamps[index], time_format)).total_seconds())
        if index == 0:
            assert diff_remove_drx <= 3, f'drx setup message didn\'t come right after measId removal msg ' \
                                           f'(index: {index}, time difference: {diff_remove_drx}s)'
        else:
            assert diff_remove_drx == 0, f'drx setup message didn\'t come right after measId removal msg ' \
                                         f'(index: {index}, time difference: {diff_remove_drx}s)'
        if index > 0:
            diff_remove_next_add = round((datetime.strptime(add_msgs_timestamps[index], time_format) -
                                          datetime.strptime(remove_msgs_timestamps[index - 1], time_format))
                                         .total_seconds())
            assert abs(diff_remove_next_add - retry_timer) <= 1, \
                f'Time between new measIdAdd and previous measIdRemove messages not as expected ' \
                f'(index: {index}, time: {diff_remove_next_add}s)'


def analyze_ab1_testcase_phase_1(qxdm_path: str) -> None:
    """
    Checking that the messages are sent in the right order -> rrcReconfiguration adding measId's, seting up measGaps,
    then DRX release mesasage, then rrcReconfiguration removing measId's, deconfiguring measGaps and setting up DRX.
    Checking that first rrcReconfiguration contains proper NRHOIF info.Checking that the right amount of CA-related and
    mobility-related measId's are added and that they're being properly added and removed in consecutive
    rrcReconfiguration messages.

    :param qxdm_path: qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    _assert_proper_messages_order(add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps, 2)
    _check_ssbfrequencies_from_first_rrcreconfig_message(meas_add_msgs[0])
    _check_proper_amount_of_reported_ca_and_mobility_measids(meas_add_msgs[0])
    _check_proper_measids_adds_and_removes(meas_add_msgs, meas_remove_msgs, 2)


def analyze_ab1_testcase_phase_2(qxdm_path: str) -> None:
    """
    Checking that rrcReconfiguration messages are reissued after UE is back from inactive state. Checking that the first
    one contains proper NRHOIF info. Checking that the right amount of CA-related and mobility-related measId's are
    added and that they're being properly added and removed in consecutive rrcReconfiguration messages.
    :param qxdm_path: qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    assert len(remove_msgs_timestamps) == 5, \
        f'amount of measId remove msgs lesser than expected ({len(add_msgs_timestamps)})'
    assert len(add_msgs_timestamps) == 5, \
        f'amount of measId add msgs lesser than expected ({len(remove_msgs_timestamps)})'
    assert len(drx_setup_timestamps) == 5, \
        f'amount of drx setup msgs lesser than expected ({len(drx_setup_timestamps)})'
    _assert_proper_messages_order(add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps, 5)
    _check_ssbfrequencies_from_first_rrcreconfig_message(meas_add_msgs[0])
    _check_proper_amount_of_reported_ca_and_mobility_measids(meas_add_msgs[0])
    _check_proper_measids_adds_and_removes(meas_add_msgs, meas_remove_msgs, 5)


def analyze_a_b9_testcase(qxdm_path: str) -> None:
    """
    Checking that ue logs contain a rrcReconfig message that configured 3CC CA (it should have 2 scellindex added)

    Checking that rrcReconfig after first measurementReport removed cell 193 from CA - reportConfigId and measId
    related to a2 measurements from that cell are rmoved and there's one Id in scellToReleaseList. The following
    rrcReconfig messages containe 4 measId adds and removes (mobility-related ones).

    Checking that rrcReconfig after second measurementReport contains a removal of one measObjectId, reportconfigId,
    measId and sCellToRelease has one value. From this moment ownward rrcReconfigs should have 9 measIds added
    and removed, and they stop after 50sec after CA deconfiguration.
    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    ca_configuring_message = _find_3cc_ca_configuring_message(qxdm_path)
    a2_meas_reports, a2_meas_reports_timestamps = _find_a2_measreports(qxdm_path)
    scellrelease_rrcreconfigs, scellrelease_rrcreconfigs_timestamps = _find_scellrelease_rrcreconfigs(qxdm_path)
    log_info_to_console(msg=f'scellreleasetimestamps: {scellrelease_rrcreconfigs_timestamps}')
    _confirm_2_scellindexes_in_ca_message(ca_configuring_message[0])
    _verify_scellrelease_messages(scellrelease_rrcreconfigs)
    _check_rrc_reconfigs_between_a2_measurements(meas_add_msgs, meas_remove_msgs, add_msgs_timestamps,
                                                 remove_msgs_timestamps, a2_meas_reports_timestamps)
    _check_rrcreconfigs_after_ca_deconfiguration(meas_add_msgs, meas_remove_msgs, add_msgs_timestamps,
                                                 remove_msgs_timestamps, a2_meas_reports_timestamps)


def analyze_a_b3_testcase_step_01(qxdm_path: str) -> None:
    """
    Checking that after last pair of measurementReports there's a rrcReconfiguration message configuring 3CC CA -
    should contain 2 scellIndexes and 5 measIds removal (CA-related ones). Next rrcReconfig should have 4 measIds
    removed (mobility-related ones) and measGap relesase. Next one should have one measObjectToRemove (nrhoif 12
    because it hasn't got its mobility measurements enabled), 5 reportconfigid's removed and new measId configuration
    (4 id's).

    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    ca_configuring_message = _find_3cc_ca_configuring_message(qxdm_path)
    meas_reports_timestamps = _find_meas_report_timestamps(qxdm_path)
    log_info_to_console(msg=f'measreport timestamps: {meas_reports_timestamps}')
    _confirm_2_scellindexes_in_ca_message(ca_configuring_message[0])
    measids_removed = _find_measid_removes_in_messages(ca_configuring_message)
    log_info_to_console(msg=f'measids removed: {measids_removed}')
    assert len(measids_removed[0]) == 5, 'Unexpected amount of measIds removed in CA configuration message'
    _check_first_add_and_remove_messages_after_ca_configuration(meas_add_msgs, add_msgs_timestamps,
                                                                meas_remove_msgs, remove_msgs_timestamps,
                                                                meas_reports_timestamps[-1])


def analyze_a_b3_testcase_step_02(qxdm_path: str) -> None:
    """
    Checking that after measurementReport from cell 193 one scellIndex is removed in next rrcReconfiguration and
    measId + repoconfigId related to a2 measurements from that cell are removed.
    Checking that there are no a4-related rrcReconfigurations between the two a2-related measurementReports
    Checking that after measurementReport from cell 193 one scellIndex is removed in next rrcReconfiguration and
    measObjectId, reportconfigId and measId (one of each) are removed in it. a4-related rrcreconfigs with supervision
    timer and retrytimer cycles begin anew after CA deconfiguration.

    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    a2_meas_reports, a2_meas_reports_timestamps = _find_a2_measreports(qxdm_path)
    scellrelease_rrcreconfigs, scellrelease_rrcreconfigs_timestamps = _find_scellrelease_rrcreconfigs(qxdm_path)

    _verify_scellrelease_messages(scellrelease_rrcreconfigs)
    _verify_no_rrcreconfigs_between_a2_measreports(add_msgs_timestamps, remove_msgs_timestamps,
                                                   a2_meas_reports_timestamps)
    _check_rrcreconfigs_after_ca_deconfiguration(meas_add_msgs, meas_remove_msgs, add_msgs_timestamps,
                                                 remove_msgs_timestamps, a2_meas_reports_timestamps)


def analyze_a_b2_testcase_step_01(qxdm_path: str) -> None:
    """
    Checking that CA configuring message has one measBojectId added, 1 reportConfigId added, 10 measIds removed,
    1 measId added and 1 scellIndex id.
    Checking that a4 rrcReconfigs before CA configuration (last measurementReport) had 20 measId's added/removed
    and 10 after.

    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    ca_configuring_message = _find_2cc_ca_configuring_message(qxdm_path)
    meas_reports_timestamps = _find_meas_report_timestamps(qxdm_path)
    log_info_to_console(msg=f'measReport timestamps: {meas_reports_timestamps}')
    _verify_2cc_ca_configuring_message(ca_configuring_message)
    _verify_measids_amount_before_and_after_ca_configuration(meas_add_msgs, meas_remove_msgs, add_msgs_timestamps,
                                                             remove_msgs_timestamps, meas_reports_timestamps)


def analyze_a_b2_testcase_step_02(qxdm_path: str) -> None:
    """
    Checking that CA deconfiguration message (after measurementReport) has one scellIndex in sCellRelease.
    Checking that after CA deconfiguration a4 rrcReconfiguration messages have 20 measId's added/removed and there
    will be 5 measId-adding messages and 5 measId-removing ones.

    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    meas_reports_timestamps = _find_meas_report_timestamps(qxdm_path)
    log_info_to_console(msg=f'measReport timestamps: {meas_reports_timestamps}')
    _assert_no_rrcreconfigs_before_measreport(add_msgs_timestamps, meas_reports_timestamps[0], 'add')
    _assert_amount_of_measids_expected(meas_add_msgs, 'add', 5, 20)
    _assert_no_rrcreconfigs_before_measreport(remove_msgs_timestamps, meas_reports_timestamps[0], 'remov')
    _assert_amount_of_measids_expected(meas_remove_msgs, 'remov', 5, 20)


def _assert_no_rrcreconfigs_before_measreport(msg_timestamps: list, meas_report_timestamp: str, operation: str) -> None:
    for timestamp in msg_timestamps:
        assert datetime.strptime(timestamp, time_format) > datetime.strptime(meas_report_timestamp, time_format), \
            f'Found an unexpected measId {operation}ing message before measurementReport'


def _assert_amount_of_measids_expected(messages: list, operation: str, msg_amount: int, measid_amount: int) -> None:
    assert len(messages) == msg_amount, f'Unexpected amount of measId {operation}ed found.'
    pattern = measIdToAddList_pattern if operation == 'add' else measIdToRemoveList_pattern
    measids_pattern = re.compile(r'measId\s\d{1,2}') if operation == 'add' else re.compile(r'\d{1,2}')
    for message in messages:
        meas_list = _find_messages_using_pattern(message, pattern)
        meas_ids = list(measids_pattern.finditer(meas_list[0]))
        assert len(meas_ids) == measid_amount, f'Unexpected amount of measIds {operation}ed in rrcReconfig message'


def analyze_a_ec2_testcase(qxdm_path: str) -> None:
    """
    Checking that CA configuring message has one measBojectId added, 1 reportConfigId added, 10 measIds removed,
    1 measId added and 1 scellIndex id.
    Checking that there were 20 measId's being removed before CA configuration, 10 after and 20 again after CA
    deconfiguration and there were 5 adding and 5 removing messages after CA deconfiguration, then a 60 sec silence
    and then the adding/removing rrcReconfigurations started again.

    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    ca_configuring_message = _find_2cc_ca_configuring_message(qxdm_path)
    meas_reports_timestamps = _find_meas_report_timestamps(qxdm_path)
    log_info_to_console(msg=f'measReport timestamps: {meas_reports_timestamps}')
    _verify_2cc_ca_configuring_message(ca_configuring_message)
    _verify_a_ec2_rrcreconfigs(meas_add_msgs, add_msgs_timestamps, meas_reports_timestamps, 'add')
    _verify_a_ec2_rrcreconfigs(meas_remove_msgs, remove_msgs_timestamps, meas_reports_timestamps, 'remov')


def _verify_a_ec2_rrcreconfigs(messages: list, timestamps: list, meas_reports_timestamps: list, operation: str) -> None:
    pattern = measIdToAddList_pattern if operation == 'add' else measIdToRemoveList_pattern
    measids_pattern = re.compile(r'measId\s\d{1,2}') if operation == 'add' else re.compile(r'\d{1,2}')
    for index in range(len(messages)):
        meas_list = _find_messages_using_pattern(messages[index], pattern)
        meas_ids = list(measids_pattern.finditer(meas_list[0]))
        if (datetime.strptime(timestamps[index], time_format) <
                datetime.strptime(meas_reports_timestamps[-2], time_format)):
            assert len(meas_ids) == 20, \
                f'Unexpected amount of measIds {operation}ed in rrcReconfig message before CA configuration'
        elif (datetime.strptime(meas_reports_timestamps[-2], time_format) <
              datetime.strptime(timestamps[index], time_format) <
              datetime.strptime(meas_reports_timestamps[-1], time_format)):
            assert len(meas_ids) == 10, \
                f'Unexpected amount of measIds {operation}ed in rrcReconfig message after CA configuration'
        elif (datetime.strptime(meas_reports_timestamps[-1], time_format) <
              datetime.strptime(timestamps[index], time_format)):
            assert len(meas_ids) == 20, \
                f'Unexpected amount of measIds {operation}ed in rrcReconfig message after CA deconfiguration'

    meas_timestamps_after_ca_deconfig = []
    meas_timestamps_after_block_timer = []
    delta = 60 if operation == 'add' else 70
    for index in range(len(timestamps)):
        if (datetime.strptime(meas_reports_timestamps[-1], time_format) <
                datetime.strptime(timestamps[index], time_format) <
                (datetime.strptime(meas_reports_timestamps[-1], time_format) + timedelta(seconds=delta))):
            meas_timestamps_after_ca_deconfig.append(timestamps[index])
        elif (datetime.strptime(meas_reports_timestamps[-1], time_format) <
              datetime.strptime(timestamps[index], time_format)):
            meas_timestamps_after_block_timer.append(timestamps[index])
    log_info_to_console(msg=f'measReport timestamps after ca deconfiguration: {meas_timestamps_after_ca_deconfig}')
    log_info_to_console(msg=f'measReport timestamps after block timer expiry: {meas_timestamps_after_block_timer}')
    assert len(meas_timestamps_after_ca_deconfig) == 5, \
        f'Unexpected amount of measId {operation}ing rrcReconfigs after CA deconfiguration and before block timer.'
    assert len(meas_timestamps_after_block_timer) > 0, 'rrcReconfigs not reissued after block timer expiry.'


def _verify_no_rrcreconfigs_between_a2_measreports(add_msgs_timestamps: list, remove_msgs_timestamps: list,
                                                   a2_meas_reports_timestamps: list) -> None:
    _assert_messages_outside_certain_time_period(add_msgs_timestamps, a2_meas_reports_timestamps[0],
                                                 a2_meas_reports_timestamps[1])
    _assert_messages_outside_certain_time_period(remove_msgs_timestamps, a2_meas_reports_timestamps[0],
                                                 a2_meas_reports_timestamps[1])


def _check_first_add_and_remove_messages_after_ca_configuration(meas_add_msgs: list, add_msgs_timestamps: list,
                                                                meas_remove_msgs: list, remove_msgs_timestamps: list,
                                                                last_meas_report_timestamp: str) -> None:
    id_pattern = re.compile(r'\d{1,3}')
    for index in range(len(add_msgs_timestamps)):
        if (datetime.strptime(last_meas_report_timestamp, time_format) <
                datetime.strptime(add_msgs_timestamps[index], time_format)):
            log_info_to_console(msg=f'Checking adds index {str(index)}')
            reportconfigstoremove_found = \
                _find_messages_using_pattern(meas_add_msgs[index],
                                             re.compile(r'(reportConfigToRemoveList\s+\{\s+(?:\d+,?\s+)+)},'))
            reportconfigidstoremove = _find_messages_using_pattern(reportconfigstoremove_found[0], id_pattern)
            log_info_to_console(msg=f'Reporting ids removed: {reportconfigidstoremove}')
            assert len(reportconfigidstoremove) == 5, \
                'Unexpected amount of reporconfigIds removed in supervistion timer message after CA configuration'
            measids_found = _find_messages_using_pattern(meas_add_msgs[index], meas_ids_added_pattern)
            log_info_to_console(msg=f'measIds found: {measids_found}')
            assert len(measids_found) == 4, \
                'Unexpected amount of measIds added in supervistion timer message after CA configuration'
            break
    for index in range(len(remove_msgs_timestamps)):
        if (datetime.strptime(last_meas_report_timestamp, time_format) <
                datetime.strptime(remove_msgs_timestamps[index], time_format)):
            log_info_to_console(msg=f'Checking removes index {str(index)}')
            measidstoremove_found = \
                _find_messages_using_pattern(meas_remove_msgs[index],
                                             re.compile(r'(measIdToRemoveList\s+\{\s+(?:\d+,?\s+)+)},'))
            measidstoremove = _find_messages_using_pattern(measidstoremove_found[0], id_pattern)
            log_info_to_console(msg=f'measIds removed: {measidstoremove}')
            assert len(measidstoremove) == 4, \
                'Unexpected amount of measIds removed in retry timer message after CA configuration'
            break


def _find_3cc_ca_configuring_message(qxdm_path: str) -> list:
    text = _read_ue_log(qxdm_path)
    message = _find_messages_using_pattern(text, ca_3cc_configuration_message_pattern)
    assert len(message) == 1, f'Found {len(message)} 3CC CA configuring messages unexpectedly (expected 1).'
    return message


def _find_2cc_ca_configuring_message(qxdm_path: str) -> list:
    text = _read_ue_log(qxdm_path)
    message = _find_messages_using_pattern(text, ca_2cc_configuration_message_pattern)
    assert len(message) == 1, 'Found more than one 2CC CA configuring messages unexpectedly.'
    return message


def _verify_2cc_ca_configuring_message(ca_configuring_message: list) -> None:
    indexes = _find_messages_using_pattern(ca_configuring_message[0], re.compile(r'sCellIndex\s\d'))
    assert len(indexes) == 1, f'Unexpected amount of sCellIndexes found in CA configuring message ({len(indexes)})'
    measobjectaddlist = \
        _find_messages_using_pattern(ca_configuring_message[0],
                                     re.compile(r'measObjectToAddModList(?s:.{300,2000})reportConfigToAddModList'))
    measid_adds = list(meas_obj_adds_pattern.finditer(measobjectaddlist[0]))
    assert len(measid_adds) == 1, 'Unexpected amount of measIds added in 2CC CA configuring message'
    reportconfigaddlist = \
        _find_messages_using_pattern(ca_configuring_message[0],
                                     re.compile(r'reportConfigToAddModList(?s:.{1000,3000})measIdToRemoveList'))
    reportconfigidsadded = list(re.compile(r'reportConfigId\s\d{1,2}').finditer(reportconfigaddlist[0]))
    assert len(reportconfigidsadded) == 1, 'Unexpected amount of reportConfigIds added in 2CC CA configuring message'
    measid_removes = _find_measid_removes_in_messages(ca_configuring_message)
    assert len(measid_removes[0]) == 10, 'Unexpected amount of measIds removed in 2CC CA configuring message'


def _verify_measids_amount_before_and_after_ca_configuration(meas_add_msgs: list,  meas_remove_msgs: list,
                                                             add_msgs_timestamps: list,
                                                             remove_msgs_timestamps: list,
                                                             meas_reports_timestamps: list,
                                                             measids_before_ca=20,
                                                             measids_after_ca=10) -> None:
    _verify_measids_amount(meas_add_msgs, add_msgs_timestamps, meas_reports_timestamps[-1],
                           measids_before_ca, measids_after_ca, 'add')
    _verify_measids_amount(meas_remove_msgs, remove_msgs_timestamps, meas_reports_timestamps[-1],
                           measids_before_ca, measids_after_ca, 'remov')


def _verify_measids_amount(messages: list, timestamps: list, ca_timestamp: str,
                           measids_before_ca: int, measids_after_ca: int, operation: str) -> None:
    list_pattern = measIdToAddList_pattern if operation == 'add' else measIdToRemoveList_pattern
    pattern = re.compile(r'measId\s\d{1,2}') if operation == 'add' else re.compile(r'\d{1,2}')
    for index in range(len(messages)):
        meas_list = _find_messages_using_pattern(messages[index], list_pattern)
        meas_ids = list(pattern.finditer(meas_list[0]))
        if (datetime.strptime(timestamps[index], time_format) <
                datetime.strptime(ca_timestamp, time_format)):
            assert len(meas_ids) == measids_before_ca, \
                f'Unexpected amount of measIds {operation}ed in rrcReconfig message before CA configuration ' \
                f'({len(meas_ids)}, expected {measids_before_ca}).'
        else:
            assert len(meas_ids) == measids_after_ca, \
                f'Unexpected amount of measIds {operation}ed in rrcReconfig message before CA configuration ' \
                f'({len(meas_ids)}, expected {measids_after_ca}).'


def _confirm_2_scellindexes_in_ca_message(message: str) -> None:
    indexes = _find_messages_using_pattern(message, re.compile(r'sCellIndex\s\d'))
    assert len(indexes) == 2, f'Unexpected amount of sCellIndexes found in CA configuring message ({len(indexes)})'


def _find_a2_measreports(qxdm_path: str) -> tuple[list, list]:
    text = _read_ue_log(qxdm_path)
    meas_reports = _find_messages_using_pattern(text, a2_meas_report_pattern)
    assert len(meas_reports) == 2, \
        f'Unexpected amount of a2 triggering measurement reports found ({len(meas_reports)}).'
    return meas_reports, _return_messages_timestamps(meas_reports)


def _find_scellrelease_rrcreconfigs(qxdm_path: str) -> tuple[list, list]:
    text = _read_ue_log(qxdm_path)
    scellrelease_reconfigs = _find_messages_using_pattern(text, scellrelease_rrcreconfig_pattern)
    assert len(scellrelease_reconfigs) == 2, \
        f'Unexpected amount of sCellRelease rrcReconfigs found ({len(scellrelease_reconfigs)}).'
    return scellrelease_reconfigs, _return_messages_timestamps(scellrelease_reconfigs)


def _verify_scellrelease_messages(scellrelease_rrcreconfigs: list) -> None:
    meas_configs = []
    measobjectstoremove = []
    reportconfigstoremove = []
    measidtorremove = []
    id_pattern = re.compile(r'\d{1,3}')
    for message in scellrelease_rrcreconfigs:
        meas_configs.extend(_find_messages_using_pattern(message,
                                                         re.compile(r'measConfig(?s:.{100,1200})nonCriticalExtension')))
    for message in meas_configs:
        measobjectstoremove_found = \
            _find_messages_using_pattern(message, re.compile(r'measObjectToRemoveList(?s:.{10,100})},'))
        reportconfigstoremove_found = \
            _find_messages_using_pattern(message, re.compile(r'(reportConfigToRemoveList\s+\{\s+(?:\d+,?\s+)+)},'))
        measidtorremove_found = \
            _find_messages_using_pattern(message, re.compile(r'measIdToRemoveList(?s:.{10,100})},'))
        if measobjectstoremove_found:
            measobjectstoremove.append(_find_messages_using_pattern(measobjectstoremove_found[0], id_pattern))
        else:
            measobjectstoremove.append([])
        if reportconfigstoremove_found:
            reportconfigstoremove.append(_find_messages_using_pattern(reportconfigstoremove_found[0], id_pattern))
        else:
            reportconfigstoremove.append([])
        if measidtorremove_found:
            measidtorremove.append(_find_messages_using_pattern(measidtorremove_found[0], id_pattern))
        else:
            measidtorremove.append([])
    log_info_to_console(msg=f'measobjectsToRemove: {measobjectstoremove} '
                            f'\nreportconfigsToRemove: {reportconfigstoremove} '
                            f'\nmeasIdtoRemove: {measidtorremove}')
    assert len(measobjectstoremove[0]) == 0 and len(reportconfigstoremove[0]) == 1 and len(measidtorremove[0]) == 1, \
        'measConfig contents of the first scellRemoval message not verified.'
    assert len(measobjectstoremove[1]) == 1 and len(reportconfigstoremove[1]) == 1 and len(measidtorremove[1]) == 1, \
        'measConfig contents of the second scellRemoval message not verified.'


def _check_rrc_reconfigs_between_a2_measurements(meas_add_msgs: list, meas_remove_msgs: list,
                                                 add_msgs_timestamps: list, remove_msgs_timestamps: list,
                                                 a2_meas_reports_timestamps: list) -> None:
    add_indexes, remove_indexes = _return_indexes_to_check(a2_meas_reports_timestamps, add_msgs_timestamps,
                                                           remove_msgs_timestamps)
    add_msgs_to_check = [meas_add_msgs[ind] for ind in add_indexes]
    remove_msgs_to_check = [meas_remove_msgs[ind] for ind in remove_indexes]
    measids_added = _find_measid_adds_in_messages(add_msgs_to_check)
    measids_removed = _find_measid_removes_in_messages(remove_msgs_to_check)
    for measids in measids_added:
        assert len(measids) == 4, \
            'Unexpected amount of measIds added in rrcReconfig message between a2 measurementReports'
    for measids in measids_removed:
        assert len(measids) == 4, \
            'Unexpected amount of measIds removed in rrcReconfig message between a2 measurementReports'


def _check_rrcreconfigs_after_ca_deconfiguration(meas_add_msgs: list, meas_remove_msgs: list,
                                                 add_msgs_timestamps: list, remove_msgs_timestamps: list,
                                                 a2_meas_reports_timestamps: list) -> None:
    add_indexes, remove_indexes = [], []
    for index in range(len(add_msgs_timestamps)):
        if (datetime.strptime(a2_meas_reports_timestamps[1], time_format) <
                datetime.strptime(add_msgs_timestamps[index], time_format)):
            add_indexes.append(index)
    for index in range(len(remove_msgs_timestamps)):
        if (datetime.strptime(a2_meas_reports_timestamps[1], time_format) <
                datetime.strptime(remove_msgs_timestamps[index], time_format)):
            remove_indexes.append(index)
    log_info_to_console(msg=f'adds indexes to check: {add_indexes}\nremoves indexes to check: {remove_indexes}')
    add_msgs_to_check = [meas_add_msgs[ind] for ind in add_indexes]
    remove_msgs_to_check = [meas_remove_msgs[ind] for ind in remove_indexes]
    measids_added = _find_measid_adds_in_messages(add_msgs_to_check)
    measids_removed = _find_measid_removes_in_messages(remove_msgs_to_check)
    log_info_to_console(msg=f'measIds added: {measids_added}\nmeasIds removed: {measids_removed}')
    for measids in measids_added:
        assert len(measids) == 9, \
            'Unexpected amount of measIds added in rrcReconfig message after CA deconfiguration'
    for measids in measids_removed[1:]:
        assert len(measids) == 9, \
            'Unexpected amount of measIds removed in rrcReconfig message after CA deconfiguration'
    for msg_timestamp in add_msgs_timestamps:
        assert (datetime.strptime(a2_meas_reports_timestamps[1], time_format) + timedelta(seconds=60)) > \
               datetime.strptime(msg_timestamp, time_format), \
               'Found a measId adding rrcReconfig over 50 seconds after CA deconfiguration'
    for msg_timestamp in remove_msgs_timestamps:
        assert (datetime.strptime(a2_meas_reports_timestamps[1], time_format) + timedelta(seconds=60)) > \
               datetime.strptime(msg_timestamp, time_format), \
               'Found a measId removing rrcReconfig over 50 seconds after CA deconfiguration'


def _return_indexes_to_check(a2_meas_reports_timestamps: list, add_msgs_timestamps: list,
                             remove_msgs_timestamps: list) -> tuple[list, list]:
    add_indexes = []
    remove_indexes = []
    for index in range(len(add_msgs_timestamps)):
        if (datetime.strptime(a2_meas_reports_timestamps[0], time_format) <
                datetime.strptime(add_msgs_timestamps[index], time_format) <
                datetime.strptime(a2_meas_reports_timestamps[1], time_format)):
            add_indexes.append(index)
    for index in range(len(remove_msgs_timestamps)):
        if (datetime.strptime(a2_meas_reports_timestamps[0], time_format) <
                datetime.strptime(remove_msgs_timestamps[index], time_format) <
                datetime.strptime(a2_meas_reports_timestamps[1], time_format)):
            remove_indexes.append(index)
    return add_indexes, remove_indexes


def _find_meas_reports(qxdm_path: str) -> list:
    text = _read_ue_log(qxdm_path)
    return _find_messages_using_pattern(text, meas_report_pattern)


def _find_meas_report_timestamps(qxdm_path: str) -> list:
    return _return_messages_timestamps(_find_meas_reports(qxdm_path))


def _assert_proper_amount_of_measids_before_and_after_a1_steering_trigger(meas_add_msgs: list,
                                                                          add_msgs_timestamps: list,
                                                                          meas_report_timestamp: str) -> None:
    reported_measid_adds = _find_measid_adds_in_messages(meas_add_msgs)
    for index in range(len(meas_add_msgs)):
        meas_report_timediff = (datetime.strptime(add_msgs_timestamps[index], time_format) -
                                datetime.strptime(meas_report_timestamp, time_format))/timedelta(milliseconds=1)
        log_info_to_console(msg=('timediff: ', meas_report_timediff, '\nmeas ids: ', reported_measid_adds[index]))
        assert len(reported_measid_adds[index]) == 5 if meas_report_timediff < 0 \
            else len(reported_measid_adds[index]) == 10


def _find_measid_add_msg_after_a1_steering(qxdm_path: str) -> list:
    text = _read_ue_log(qxdm_path)
    return _find_messages_using_pattern(text, meas_add_after_a1_steering_pattern)


def _prepare_iwk1_tc_messages(qxdm_path: str) -> tuple[list, list, list, list, list, list, list]:
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    meas_report_timestamps = _find_meas_report_timestamps(qxdm_path)
    log_info_to_console(msg=f'meas_reports_timestamps: {meas_report_timestamps}')
    return meas_add_msgs, meas_remove_msgs, drx_setup_msgs, add_msgs_timestamps, remove_msgs_timestamps, \
        drx_setup_timestamps, meas_report_timestamps


def analyze_iwk1_testcase_step_1(qxdm_path: str) -> None:
    """
    Checking that after the measurementReport a4 rrcReconfigs are happenning each 10sec with measGap and drx
    configurations and 10 measId's added/removed in each reconfiguration.

    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, add_msgs_timestamps, remove_msgs_timestamps, \
        drx_setup_timestamps, meas_report_timestamps = _prepare_iwk1_tc_messages(qxdm_path)
    log_info_to_console(msg=('new meas id add msgs timestamps:', add_msgs_timestamps))
    _assert_proper_amount_of_measids_before_and_after_a1_steering_trigger(meas_add_msgs,
                                                                          add_msgs_timestamps,
                                                                          meas_report_timestamps[0])
    _assert_proper_messages_order(add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps,
                                  number_of_cycles_to_check=3, supervision_timer=10, retry_timer=20)


def analyze_iwk1_testcase_step_2(qxdm_path: str) -> None:
    """
    Checking that before measurementReport there were 5 measId's added/removed in rrcReconfigurations and 10 after it.

    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, add_msgs_timestamps, remove_msgs_timestamps, \
        drx_setup_timestamps, meas_report_timestamps = _prepare_iwk1_tc_messages(qxdm_path)
    _assert_proper_messages_order(add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps,
                                  number_of_cycles_to_check=3, supervision_timer=10, retry_timer=20)
    _assert_proper_amount_of_measids_before_and_after_a1_steering_trigger(meas_add_msgs,
                                                                          add_msgs_timestamps,
                                                                          meas_report_timestamps[0])


def analyze_iwk7_testcase_step_1(qxdm_path: str) -> None:
    """
    Checking that measurementReport was sent during retryTimer, rrcReconfiguration triggered immediately after
    measurementReport should contain DRX release and measGap setup.

    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    meas_report_timestamps = _find_meas_report_timestamps(qxdm_path)
    log_info_to_console(msg=('measReports timestamps: ', meas_report_timestamps))
    assert len(meas_report_timestamps) == 1, 'Unexpected amount of measurement report messages found.'
    remove_msg_meas_rep_diff = (datetime.strptime(meas_report_timestamps[0], time_format) -
                                datetime.strptime(remove_msgs_timestamps[0], time_format)).total_seconds()
    assert 0 < remove_msg_meas_rep_diff < 10, 'Measurement Report wasn\'t triggered during retry timer.'
    a2_meas_add_message, a2_meas_add_timestamp = \
        _find_message_for_iwk7_tc(qxdm_path, meas_add_after_a2_trigger_during_retry_timer_pattern)
    meas_add_2_meas_rep_diff = (datetime.strptime(meas_report_timestamps[0], time_format) -
                                datetime.strptime(a2_meas_add_timestamp[0], time_format)).total_seconds()
    assert len(a2_meas_add_message) == 1, 'Haven\'t found the a2-triggered meas add message.'
    assert -1 < meas_add_2_meas_rep_diff < 0, 'Measurement Report didn\'t trigger a2 rrcReconfig.'


def analyze_iwk7_testcase_step_2(qxdm_path: str) -> None:
    """
    Checking that supervisionTimer starting rrcReconfig is sent after first measurementReport -> its rrcReconfiguration
    message should contain measGap setup, drx release and 10 measId's added.
    After the second measurementReport message rrcReconfiguration message should remove 11 measId's
    (10 default ones + a1-related one) and add 11 measId's (10 default ones + a2-related one) - the message shouldn't
    also contain any info about measGap and DRX configuration.

    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    meas_report_timestamps = _find_meas_report_timestamps(qxdm_path)
    log_info_to_console(msg=('measReports timestamps: ', meas_report_timestamps))
    assert len(meas_report_timestamps) == 2, 'Unexpected amount of measurement report messages found.'
    diff_add_msg_meas_report = (datetime.strptime(meas_report_timestamps[0], time_format) -
                                datetime.strptime(add_msgs_timestamps[1], time_format)).total_seconds()
    assert -10 < diff_add_msg_meas_report < 0, 'First measurement Report didn\'t trigger a1 rrcReconfig.'
    meas_ids = _find_measid_adds_in_messages(meas_add_msgs)
    log_info_to_console(msg=f'Meas ids: {meas_ids[1]}')
    assert len(meas_ids[1]) == 10, 'Haven\'t verified 10 added measId\'s after a1 trigger.'
    a2_triggered_meas_add_remove_msg, a2_triggered_meas_add_remove_timestamp = \
        _find_message_for_iwk7_tc(qxdm_path, meas_add_remove_after_a2_trigger_during_supervision_pattern)
    diff_add_remove_msg_a2_meas_report = \
        (datetime.strptime(meas_report_timestamps[1], time_format) -
         datetime.strptime(a2_triggered_meas_add_remove_timestamp[0], time_format)).total_seconds()
    assert -1 < diff_add_remove_msg_a2_meas_report < 0, 'A2 during supervision didn\'t trigger rrcReconfig immediately.'
    meas_ids_added = _find_measid_adds_in_messages(list(a2_triggered_meas_add_remove_msg))
    meas_ids_removed = _find_measid_removes_in_messages(list(a2_triggered_meas_add_remove_msg))
    assert len(meas_ids_added[0]) == 11, \
        'Unexpected amount of measId\'s added after a2 triggered during supervision'
    assert len(meas_ids_removed[0]) == 11, \
        'Unexpected amount of measId\'s removed after a2 triggered during supervision'
    assert 'measGap' not in a2_triggered_meas_add_remove_msg, \
        'Found Unexpected measGap reconfiguration after a2 triggered during supervision'
    assert 'drx-Config' not in a2_triggered_meas_add_remove_msg, \
        'Found Unexpected drx reconfiguration after a2 triggered during supervision'


def analyze_iwk7_testcase_step_3(pcap_path: str) -> None:
    """
    Checking successful handover to cell 193.

    :param pcap_path: path to tcpdump pcap file
    """
    handover_filter = '(nokiaf1ap.procedureCode == 7) && (nr-rrc.physCellId == 193)'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    msg_count = ute_tshark.get_packets_count(packet_filter=handover_filter,
                                             pcap_file_path=pcap_path,
                                             alias=pcap_alias)
    handover_messages = ute_tshark.read_pcap(packet_filter=handover_filter, pcap_file_path=pcap_path, alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    assert msg_count == 3, 'Unexpected amount of handover messages found.'
    pattern = re.compile(r'successfulOutcome(?s:.{5,20})procedureCode:\sid-UEContextModification\s.7.')
    ue_context_mod = _find_messages_using_pattern(handover_messages, pattern)
    assert len(ue_context_mod) == 2, 'Unexpected amount of UeContextModification messages found'


def analyze_iwk3_testcase_phase_1(qxdm_path: str) -> None:
    """
    Checking that there were 5 supervisionTimer starting measId adding rrcReconfig messages total
    (that CA configuration doesn't reset the counter). Checking that 3CC CA was configured (2 scellIndexes in
    rrcReconfig after last measReport) and that there were 8 measId's being added and removed before CA and 4 after.

    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    meas_report_timestamps = _find_meas_report_timestamps(qxdm_path)
    log_info_to_console(msg=f'measReport timestamps: {meas_report_timestamps}')
    assert len(add_msgs_timestamps) == 5, f'Unexpected amount of measId adding rrcReconfig messages found ' \
                                          f'({len(add_msgs_timestamps)}).'
    ca_msg_timestamp = _return_messages_timestamps(_find_3cc_ca_configuring_message(qxdm_path))
    log_info_to_console(msg=f'CA start time: {ca_msg_timestamp}')
    _verify_measids_amount_before_and_after_ca_configuration(meas_add_msgs, meas_remove_msgs, add_msgs_timestamps,
                                                             remove_msgs_timestamps, meas_report_timestamps,
                                                             measids_before_ca=8, measids_after_ca=4)


def analyze_iwk3_testcase_phase_2(qxdm_path: str) -> None:
    """
    Checking that 3CC CA was configured (find rrcReconfig with 2 sCellIndexes). Assert that measurementRepors preceding
    the CA configuring rrcReconfig were triggered by measIds 4  (a1 scell addition) and 24 (a4 scell addition).
    Checking that there are none a4 rrcReconfig messages between the CA configuring message and
    a1 steering-triggered measReport (measId 5). After that measReport there should be a whole cycle of rrcReconfig
    messages (5 measId removing messages and 4 measId adding (first add was at attach)).

    :param qxdm_path: path to ue logs txt file
    """
    meas_add_msgs, meas_remove_msgs, drx_setup_msgs, \
        add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps = _find_rrcreconfig_messages(qxdm_path)
    meas_reports = _find_meas_reports(qxdm_path)
    meas_report_timestamps = _find_meas_report_timestamps(qxdm_path)
    log_info_to_console(msg=f'measReports timestamps: {meas_report_timestamps}')
    ca_msg_timestamp = _return_messages_timestamps(_find_3cc_ca_configuring_message(qxdm_path))
    log_info_to_console(msg=f'CA start time: {ca_msg_timestamp}')
    _assert_proper_measreport_measids_before_3cc_ca_configuration(meas_reports,
                                                                  meas_report_timestamps,
                                                                  ca_msg_timestamp[0])
    _assert_full_a4_cycle_after_a1_steering_trigger(ca_msg_timestamp[0], meas_reports, meas_report_timestamps,
                                                    add_msgs_timestamps, remove_msgs_timestamps, drx_setup_timestamps)


def _assert_proper_measreport_measids_before_3cc_ca_configuration(meas_reports: list,
                                                                  meas_report_timestamps: list,
                                                                  ca_msg_timestamp: str) -> None:
    for index in range(len(meas_report_timestamps)):
        if 0 < (datetime.strptime(ca_msg_timestamp, time_format) -
                datetime.strptime(meas_report_timestamps[index], time_format)).total_seconds() < 6:
            assert 'measId 4' or 'measId 24' in meas_reports[index], \
                f'wrong measId found in measReport with timestamp {meas_report_timestamps[index]}'


def _assert_full_a4_cycle_after_a1_steering_trigger(ca_msg_timestamp: str, meas_reports: list,
                                                    meas_report_timestamps: list, add_msgs_timestamps: list,
                                                    remove_msgs_timestamps: list, drx_setup_timestamps: list) -> None:
    add_msgs_to_check, remove_msgs_to_check, drx_msgs_to_check = [], [], []
    a1_steering_meas_report_timestamp = None
    for index in range(len(meas_report_timestamps)):
        if 'measId 5' in meas_reports[index]:
            a1_steering_meas_report_timestamp = meas_report_timestamps[index]
            break
        assert index != len(meas_report_timestamps), 'Haven\'t found a1 steering-triggered measReport message.'
    _assert_messages_outside_certain_time_period(add_msgs_timestamps, ca_msg_timestamp,
                                                 a1_steering_meas_report_timestamp)
    _assert_messages_outside_certain_time_period(remove_msgs_timestamps, ca_msg_timestamp,
                                                 a1_steering_meas_report_timestamp)
    for msg in add_msgs_timestamps:
        if (datetime.strptime(msg, time_format) - datetime.strptime(a1_steering_meas_report_timestamp, time_format))\
                .total_seconds() > 0:
            add_msgs_to_check.append(msg)
    for msg in remove_msgs_timestamps:
        if (datetime.strptime(msg, time_format) - datetime.strptime(a1_steering_meas_report_timestamp, time_format))\
                .total_seconds() > 0:
            remove_msgs_to_check.append(msg)
    for msg in drx_setup_timestamps:
        if (datetime.strptime(msg, time_format) - datetime.strptime(a1_steering_meas_report_timestamp, time_format))\
                .total_seconds() > 0:
            drx_msgs_to_check.append(msg)
    _assert_proper_messages_order(add_msgs_to_check, remove_msgs_to_check, drx_msgs_to_check, 5, 10, 2)


def _assert_messages_outside_certain_time_period(messages: list,
                                                 period_start_timestamp: str,
                                                 period_end_timestamp: str):
    for msg in messages:
        assert (datetime.strptime(period_start_timestamp, time_format) -
                datetime.strptime(msg, time_format)).total_seconds() > 0 or \
                (datetime.strptime(period_end_timestamp, time_format) -
                 datetime.strptime(msg, time_format)).total_seconds() < 0, \
                f'Unexpected rrcReconfig message has been found at {msg} , placing it within the ' \
                f'{period_start_timestamp} - {period_end_timestamp} period.'


def _check_ssbfrequencies_from_first_rrcreconfig_message(message: str) -> None:
    expected = ['430090,', '523470,', '521550,', '522990,', '390970,']
    frequencies = [(match.group()).split(' ')[-1] for match in list(meas_obj_adds_pattern.finditer(message))]
    log_info_to_console(msg=('ssbFrequencies reported: ', frequencies))
    assert frequencies == ['430090,', '523470,', '521550,', '522990,', '390970,'], \
        f'Reported ssbFrequencies ({frequencies}) not as expected ({expected})'


def _check_proper_amount_of_reported_ca_and_mobility_measids(message: str) -> None:
    thresholds = [match.group().split(' ')[-1] for match in list(report_config_ids_added_pattern.finditer(message))]
    log_info_to_console(msg=f'reportconfigIds added: {thresholds}')
    assert len(thresholds) == 10, f'Unexpected amoount ({len(thresholds)}) of reportConfigIds reported.'
    ca_measids, mobility_measids = [], []
    for threshold in thresholds:
        if 55 <= int(threshold) <= 69:
            ca_measids.append(threshold)
        if 30 <= int(threshold) <= 40:
            mobility_measids.append(threshold)
    assert len(ca_measids) == 5, f'Unexpected amoount ({len(ca_measids)}) of CA related reportConfigIds reported.'
    assert len(mobility_measids) == 5, f'Unexpected amoount ({len(mobility_measids)}) of mobility related ' \
                                       f'reportConfigIds reported.'


def _check_proper_measids_adds_and_removes(meas_add_msgs: list, mease_remove_msgs: list, number_of_cycles: int) -> None:
    reported_measid_adds = _find_measid_adds_in_messages(meas_add_msgs)
    reported_measid_removes = _find_measid_removes_in_messages(mease_remove_msgs)
    log_info_to_console(msg=('reported measId additions: ', reported_measid_adds))
    log_info_to_console(msg=('reported measId removals: ', reported_measid_removes))
    for index in range(number_of_cycles):
        assert reported_measid_removes[index] == reported_measid_adds[index], \
            f'different measIds are being removed than then ones that have been reported (cycle number {str(index+1)})'


def _find_measid_adds_in_messages(messages: list) -> list:
    return [[match.group().split(' ')[-1] for match in list(meas_ids_added_pattern.finditer(message))]
            for message in messages]


def _find_measid_removes_in_messages(messages: list) -> list:
    return [[match.group().replace(',', '') for match in
             list(re.compile(r'\d{1,2}').finditer(re.findall(measIdToRemoveList_pattern, message)[0]))]
            for message in messages]


def _find_messages_using_pattern(text: str, pattern: re.Pattern) -> list:
    return [match.group() for match in list(pattern.finditer(text))]


def _return_messages_timestamps(messages: list) -> list:
    return [timestamp.split(' ')[0] for timestamp in list(timestamp_pattern.findall(str(messages)))]
