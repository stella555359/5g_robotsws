"""
:copyright: Nokia Networks
:authors:
    Krzysztof Korczak <krzysztof.korczak@nokia.com>
    Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
:maintainers:
    Lukasz Klimowicz <lukasz.klimowicz@nokia.com>
"""
from robot.api import logger
from ta5g_egate.interface import ta5g_egate
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB006733.CB006733_AP.resources.csv_verifiers import csv_verifiers
cv = csv_verifiers()


def generate_script_for_all_a4_meas_ids(ue_id, file_path='/tmp/all_meas.txt', phycell_id=51, nrsrq_nr=95, nrsrp_nr=90):
    """
    Function generates ad-hoc script for sending A4 measurements for all meas_ids
    :param ue_id: UE ID
    :param file_path: script save location
    :param phycell_id: Physical ID of cell that A4 measurement reports
    :param nrsrq_nr: Value of nrsrq_nr
    :param nrsrp_nr: Value of nrsrp_nr
    :return file_path: generated script path that can be executed in EPCSIM console with 'script file=${file_path}'
    """
    with open(file_path, 'w') as script:
        for i in range(1, 65):
            script.write(f'ue_measurement_send_nr event=A4 phycell_id={phycell_id} nrsrq_nr={nrsrq_nr}'
                         f' nrsrp_nr={nrsrp_nr} id={ue_id} meas_id={i}\n')

    return file_path


def verify_vonr_transmission(tti_csv_path):
    """
    Verifies that uninterrupted VoNR transmission occurred
    @param tti_csv: path to csv file
    """
    csv_list_dl = cv.create_list_of_lists_from_csv(csv_path=tti_csv_path + 'output_dl.csv')
    verify_that_transmission_is_uninterrupted(csv_list_dl)
    csv_list_ul = cv.create_list_of_lists_from_csv(csv_path=tti_csv_path + 'output_ul.csv')
    verify_that_vonr_event_occurred(csv_list_ul)


def verify_that_vonr_event_occurred(csv_list):
    """
    Verifies that ENTRYDEPRIOVOIP occurs in csListEvent
    @param csv_list: list of ul tti traces
    """
    events = cv.get_column_values(input_list=csv_list, column_name='ulPreSchedData.csListEvent', unique_values=True)
    logger.info('Events:', events)
    assert 'ENTRYDEPRIOVOIP' in events, 'No VoNR transmission!'


def verify_that_transmission_is_uninterrupted(csv_list):
    """
    Function that verifies if transmission is uninterrupted via tti traces
    :param csv_list: tti traces as csv_list
    """
    HARQ_list = cv.get_column_values(input_list=csv_list, column_name='dlFdSchedData.ackNack')
    Total = len(HARQ_list) - HARQ_list.count("")
    ACKs = HARQ_list.count('ACK')
    NACKs = HARQ_list.count('NACK')
    DTXs = HARQ_list.count('DTX')
    logger.info(f"ACK: {ACKs}/{Total} ({ACKs/Total * 100:.2f}%)")
    logger.info(f"DTX: {DTXs}/{Total} ({DTXs/Total * 100:.2f}%)")
    logger.info(f"NACK: {NACKs}/{Total} ({NACKs/Total * 100:.2f}%)")
    assert DTXs/Total < 0.01, f'Share of DTX feedback is above 1% ({DTXs/Total * 100:.2f}%)'
    assert NACKs/Total < 0.01, f'Share of NACK feedback is above 1% ({NACKs/Total * 100:.2f}%)'


def verify_in_tti_traces_that_addition_of_scell_occurred_after_dlcacqiwindow(tti_path, dlcacqiwindow=50, vonr=False,
                                                                             dir='dl'):
    """
    Function verifies if SCell addition occured after time defined by dlcacqiwindow parameter.
    :param tti_path: Path to tti traces file
    :param dlcacqiwindow: value of dlcacqiwindow parameter
    :param vonr: set to True if VoNR transmission exists or 5QI-1 is configured for PDU session
    :param dir:  direction of monitored channel
    """
    csv_list = cv.create_list_of_lists_from_csv(csv_path=tti_path + 'output_dl.csv')
    conditions = 'evaluationDlBufferStatusForSCellConfiguration.timeWithGood'
    conditions += 'Cqi' if dir == 'dl' else 'Sinr'
    conditions += 'VoNr' if vonr else ''
    traces_dict = cv.get_multiple_columns_values('timeStamp', conditions, 'dlFdSchedData.macCe.hasSCellActDeact',
                                                 input_list=csv_list, as_dict=True)
    scell_activation_first_possible_time = get_time_stamp_of_time_with_long_enough_good_radio_conditions(traces_dict,
                                                                                                         conditions,
                                                                                                         dlcacqiwindow)
    scell_activation_actual_time = get_time_stamp_of_scell_activation(traces_dict)
    logger.info(f"Timestamp with timewithgoodcqi longer than dlcacqiwindow: {scell_activation_first_possible_time}")
    logger.info(f"Timestamp with scell activation: {scell_activation_actual_time}")

    assert scell_activation_first_possible_time < scell_activation_actual_time, \
        f'SCell activation occurred at {scell_activation_actual_time}, while first possible time is at ' \
        f'{scell_activation_first_possible_time}'


def get_time_stamp_of_time_with_long_enough_good_radio_conditions(traces_dict, good_conditions, dlcacqiwindow):
    """
    :param traces_dict: dict of tti traces that contain timeStamp and conditions columns
    :param good_conditions: name of column that needs to be checked in given conditions (i.e. Sinr of CQI and or 5qi1)
    :param dlcacqiwindow: value of dlcacqiwindow paremeter
    :return:
    """
    for time, time_with_good_radio in zip(traces_dict['timeStamp'], traces_dict[good_conditions]):
        try:
            if float(time_with_good_radio) > dlcacqiwindow:
                return time
        except ValueError:
            pass


def get_time_stamp_of_scell_activation(traces_dict):
    """
    Function that extracts the first time of SCell activation from tti traces
    :param traces_dict: dict of tti traces that contain timeStamp and dlFdSchedData.macCe.hasSCellActDeact columns
    :return: time stamp of frist Scell Activation
    """
    for time, scell_activation in zip(traces_dict['timeStamp'], traces_dict['dlFdSchedData.macCe.hasSCellActDeact']):
        try:
            if float(scell_activation) == 1:
                return time
        except ValueError:
            pass


def verify_vonr_transmission_is_uninterrupted(ue_id, pdu_id, qfi=2):
    """
    Function that verifies if VoNR transmission is uninterrupted, by checkin Lost packest with qfi_stats command
    :param ue_id: ID of UE with VoNR transmission
    :param pdu_id: ID of PDU session with 5QI configured and VoNR transmission
    :param qfi: qos flow ID of 5QI-1 bearer
    """
    vonr_dl_stats_cmd = f'qfi_stats ue={ue_id} pdu={pdu_id} qfi=2 dir=dl format=long'
    vonr_ul_stats_cmd = f'qfi_stats ue={ue_id} pdu={pdu_id} qfi=2 dir=ul format=long'
    egate = ta5g_egate()
    regexp = 'Total packets received .*[^0]\n.*\n.*\nTotal packets lost.*0'
    egate._ute_wtssim_instance.execute_egate_command(cmd=vonr_dl_stats_cmd, pass_regexp=regexp)
    egate._ute_wtssim_instance.execute_egate_command(cmd=vonr_ul_stats_cmd, pass_regexp=regexp)
