"""
:copyright: Nokia Networks
:authors:
    Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
    Maciej Majewski, maciej.majewski@nokia.com
    Michal Obszarny, michal.obszarny@nokia.com
    Patryk Wojcik, patryk.wojcik@nokia.com
:maintainers:
    Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
"""
import glob
import subprocess
import time
import logging

from robot.libraries.OperatingSystem import OperatingSystem
from robot.api import logger
from ta_egate_cmd_parser import ta_egate_cmd_parser
from ute_wtssim import ute_wtssim
from ta_messaging.message_flows import get_flow
from taf.transport.ssh import ssh

from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.csv_verifiers import csv_verifiers
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.ue_handling import ue_handling
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.traffic_handling import traffic_handling

from testsuite.Krakow.RRM.Airphone.CB012734.config.iwf_preconfigs import ConfigureIWF
from testsuite.Krakow.RRM.Airphone.CB012734.config.iwf_launch import CheckConfigureIWF

csv_tti_trace = csv_verifiers()
ue_handling = ue_handling()
traffic_handling = traffic_handling()
wts = ute_wtssim()
preconfig_iwf = ConfigureIWF()
lauch_iwf = CheckConfigureIWF()


def setup_egate_instances():
    wts.setup_egate(egate_port=20000)


def verify_TbSize(csv_directory):
    """
    Verify TbSize values in tti traces
    :param csv_directory: (str) file path directory, where tti traces are collected
    :return: average TbSize value
    """
    collected_values = {"slot": [], "dlFdSchedData.tbSize": []}
    for csv_file in glob.glob(csv_directory + 'output_dl.*'):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = csv_tti_trace.get_multiple_columns_values('slot', 'dlFdSchedData.tbSize',
                                                                          input_list=collected_tti, as_dict=True)
        collected_values["slot"].extend(collected_file_values["slot"])
        collected_values["dlFdSchedData.tbSize"].extend(collected_file_values["dlFdSchedData.tbSize"])

    tbsize_length = 0
    tbsize_sum = 0
    for row in range(len(collected_values['slot'])):
        if int(collected_values['slot'][row]) % 5 == 3:
            if collected_values['dlFdSchedData.tbSize'][row] != "":
                tbsize_length += 1
                tbsize_sum += int(float((collected_values['dlFdSchedData.tbSize'][row])))
    return tbsize_sum / tbsize_length


def calculate_average_type_of_ues(ue_type, csv_directory):
    """
    Verify that average values of dlSliceData and dlDrbWeight events in tti traces are in expected range
    :param ue_type: (str) skipped or schedule type of UEs
    :param csv_directory: (str) file path directory, where tti traces are collected
    :return: average value of type of UEs
    """
    collected_values = []
    collected_file_values = []
    for csv_file in glob.glob(csv_directory + 'output_dl.*'):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)

        collected_values_1 = csv_tti_trace.get_column_values(input_list=collected_tti,
                                                             column_name="dlLoadControlData.fdSchedInfo[0]." + ue_type)
        collected_values_2 = csv_tti_trace.get_column_values(input_list=collected_tti,
                                                             column_name="dlLoadControlData.fdSchedInfo[1]." + ue_type)
        for value in range(len(collected_values_1)):
            if collected_values_1[value] != "" and collected_values_2[value] != "":
                collected_file_values.append(float(collected_values_1[value]) + float(collected_values_2[value]))
        collected_values += collected_file_values

    ttitrace_length = 0
    ues_value_sum = 0
    for ues_value in collected_values:
        if ues_value != "":
            ttitrace_length += 1
            ues_value_sum += float(ues_value)
    return ues_value_sum / ttitrace_length


def calculate_slot_processing_time(csv_directory):
    """
    Verify slot processing time values in tti traces
    :param csv_directory: (str) file path directory, where tti traces are collected
    :return: average slot processing time value
    """
    collected_values = []
    for csv_file in glob.glob(csv_directory + 'output_dl.*'):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)

        collected_file_values = csv_tti_trace.get_column_values(
            input_list=collected_tti,
            column_name="dlLoadControlData.measurementInfo.slotProcessingTimeAvg")
        collected_values += collected_file_values

    ttitrace_length = 0
    slot_processing_time_sum = 0
    for slot_processing_time in collected_values:
        if slot_processing_time != "":
            ttitrace_length += 1
            slot_processing_time_sum += float(slot_processing_time)
    print(slot_processing_time_sum / ttitrace_length)
    return slot_processing_time_sum / ttitrace_length


def verify_forbiden_sliv(csv_directory):
    """
    Verify SLIV values in tti traces
    :param csv_directory: (str) file path directory, where tti traces are collected
    :return:
    """
    collected_values = []
    for csv_file in glob.glob(csv_directory + 'output_dl.*'):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)

        collected_file_values = csv_tti_trace.get_column_values(input_list=collected_tti,
                                                                column_name="dlFdSchedData.SLIV")
        collected_values += collected_file_values

    for sliv_value in collected_values:
        if sliv_value != "":
            sliv_value = int(float(sliv_value))
        assert sliv_value != (30 or 43 or 54 or 56 or 67 or 86 or 99), "Forbidden SLIV: {}".format(sliv_value)


def verify_number_of_reported_beams_in_csi(csv_directory, expected_number_of_reported_beams):
    """
    Verify in tti traces number of beams reported in CSI (carried in UCI)
    :param csv_directory: (str) file path directory, where tti traces are collected
    :expected_number_of_reported_beams: (1.0 | 2.0) number of reported beams expected in CSI reports
    """
    column_values_number_of_reported_beams = []
    filename = 'output_dl.*'
    column_name_number_of_reported_beams = 'dlBeamData.uciNumOfReportedBeams'
    for csv_file in glob.glob(csv_directory + filename):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = csv_tti_trace.get_multiple_columns_values(column_name_number_of_reported_beams,
                                                                          input_list=collected_tti, as_dict=True)
        column_values_number_of_reported_beams += collected_file_values[column_name_number_of_reported_beams]
    all_numbers_of_reported_beams = set(column_values_number_of_reported_beams)
    all_numbers_of_reported_beams.remove('')
    all_numbers_of_reported_beams = list(map(float, all_numbers_of_reported_beams))
    expected_number_of_reported_beams = list(map(float, expected_number_of_reported_beams))
    logging.info(f'uciNumOfReportedBeams={all_numbers_of_reported_beams}'
                 f'\nexpected_number_of_reported_beams={expected_number_of_reported_beams}')

    assert all_numbers_of_reported_beams == expected_number_of_reported_beams, \
        f'All uciNumOfReportedBeams values={all_numbers_of_reported_beams} is different to expected ' \
        f'{expected_number_of_reported_beams}'


def verify_max_value_of_uci_payload(csv_directory, expected_uci_max_payload_size_bits):
    """
    Verify in tti traces the maximum number of UCI bits used in CSI reports
    :param csv_directory: (str) file path directory, where tti traces are collected
    :expected_uci_max_payload_size_bits: expected max number of uci payload bits in CSI reports
    """
    column_values_number_of_uci_bits = []
    filename = 'output_ul.*'
    column_name_number_of_uci_bits = 'ulPucchReceiveReqData.numOfUciBits'
    for csv_file in glob.glob(csv_directory + filename):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = csv_tti_trace.get_multiple_columns_values(column_name_number_of_uci_bits,
                                                                          input_list=collected_tti, as_dict=True)
        column_values_number_of_uci_bits += collected_file_values[column_name_number_of_uci_bits]
    number_of_uci_bits = set(column_values_number_of_uci_bits)
    number_of_uci_bits.remove('')
    number_of_uci_bits = list(map(float, number_of_uci_bits))
    max_number_of_uci_bits = max(number_of_uci_bits)
    expected_uci_max_payload_size_bits = float(expected_uci_max_payload_size_bits)
    logging.info(f'numOfUciBits={max_number_of_uci_bits}'
                 f'\nexpected_number_of_reported_beams={expected_uci_max_payload_size_bits}')

    assert max_number_of_uci_bits == expected_uci_max_payload_size_bits, \
        f'Max numOfUciBits value={max_number_of_uci_bits} is different to expected {expected_uci_max_payload_size_bits}'


def verify_bler_from_dl_ack_nack_results(csv_directory, margin_percent):
    """
    Verify in tti traces DL bler
    :param csv_directory: (str) file path directory, where tti traces are collected
    :param margin_percent: percentage of NACK/DTX allowed
    """
    column_values_dl_harq_feedback = []
    filename = 'output_dl.*'
    column_name_dl_harq_feedback = 'dlHarqRxDataArray.ackNack'
    for csv_file in glob.glob(csv_directory + filename):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = csv_tti_trace.get_multiple_columns_values(column_name_dl_harq_feedback,
                                                                          input_list=collected_tti, as_dict=True)
        column_values_dl_harq_feedback += collected_file_values[column_name_dl_harq_feedback]
    number_of_acks = column_values_dl_harq_feedback.count('ACK')
    number_of_nacks = column_values_dl_harq_feedback.count('NACK')
    number_of_dtxs = column_values_dl_harq_feedback.count('DTX')
    logging.info(f'ACK number={number_of_acks} \nNACK number={number_of_nacks}\nDTX number={number_of_dtxs}')
    logger.console(f'\n... ACK number={number_of_acks}\n... NACK number={number_of_nacks}'
                   f'\n... DTX number={number_of_dtxs}')
    calculated_bler_ratio = ((number_of_nacks + number_of_dtxs) / (number_of_acks + number_of_nacks + number_of_dtxs))
    calculated_bler_percent = calculated_bler_ratio * 100
    margin_percent = float(margin_percent)
    logging.info(f'calculated_bler_percent={calculated_bler_percent} \nmargin_percent={margin_percent}')
    logger.console(f'*** DL Bler: {calculated_bler_percent}')

    assert calculated_bler_percent <= margin_percent, \
        f'ACKs/NACKs bler={calculated_bler_percent}% is higher than expected {margin_percent}%.'


def verify_bler_from_ul_crc_results(csv_directory, margin_percent):
    """
    Verify in tti traces UL bler
    :param csv_directory: (str) file path directory, where tti traces are collected
    :param margin_percent: percentage of NACK/DTX allowed
    """
    column_values_ul_harq_feedback = []
    filename = 'output_ul.*'
    column_name_ul_harq_feedback = 'ulHarqRxData.crcResult'
    for csv_file in glob.glob(csv_directory + filename):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = csv_tti_trace.get_multiple_columns_values(column_name_ul_harq_feedback,
                                                                          input_list=collected_tti, as_dict=True)
        column_values_ul_harq_feedback += collected_file_values[column_name_ul_harq_feedback]
    crc_ok = column_values_ul_harq_feedback.count('OK')
    crc_nok = column_values_ul_harq_feedback.count('NOK')
    logging.info(f'crc_ok={crc_ok} \ncrc_nok={crc_nok}')
    logger.console(f'... crc_ok={crc_ok} \n... crc_nok={crc_nok}')
    calculated_bler_percent = (crc_nok / (crc_ok + crc_nok)) * 100
    margin_percent = float(margin_percent)
    logging.info(f'calculated_bler_percent={calculated_bler_percent} \nmargin_percent={margin_percent}')
    logger.console(f'*** UL Bler: {calculated_bler_percent}')

    assert calculated_bler_percent <= margin_percent, \
        f'CRC OK/NOK bler={calculated_bler_percent}% is higher than expected {margin_percent}%.'


def detach_selected_ues_and_get_cells_traffic(csv_directory, ues_id_and_crnti):
    """
    Select UEs, which used the same slot and detach
    :param csv_directory: (str) file path directory, where tti traces are collected
    :param ues_id_and_crnti: (dict) dict with ues_id and it crnti
    :return: cells traffic_after detach specific ues
    """
    collected_values = {"slot": [], "rnti": [], "csiSrReportData.isReportSaved": []}
    for csv_file in glob.glob(csv_directory + 'output_dl.*'):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = csv_tti_trace.filter_csv_by_column_value(csv_list=collected_tti,
                                                                         column_name='csiSrReportData.isReportSaved',
                                                                         condition='==', value="1.0")
        collected_file_values = csv_tti_trace.get_multiple_columns_values('slot', 'rnti',
                                                                          'csiSrReportData.isReportSaved',
                                                                          input_list=collected_file_values,
                                                                          as_dict=True)
        collected_values["slot"].extend(collected_file_values["slot"])
        collected_values["rnti"].extend(collected_file_values["rnti"])
        collected_values["csiSrReportData.isReportSaved"].extend(collected_file_values["csiSrReportData.isReportSaved"])

    ues_id_rnti_slot = {}
    for row in range(len(collected_values['rnti'])):
        for ue_id, crnti in ues_id_and_crnti.items():
            if ue_id in ues_id_rnti_slot:
                del (ues_id_and_crnti[ue_id])
                break
            elif crnti == int(collected_values['rnti'][row]):
                ues_id_rnti_slot[int(ue_id)] = [crnti, int(collected_values['slot'][row]) % 80]
        if ues_id_and_crnti == {}:
            break
    ues_id_rnti_slot = dict(sorted(ues_id_rnti_slot.items()))
    used_slot = []
    ues_to_keep = []
    sum_of_traffic = 0
    for ue_id in ues_id_rnti_slot.keys():
        if ues_id_rnti_slot[ue_id][1] in used_slot:
            ue_handling.ue_detach(ue_id=ue_id)
        else:
            ues_to_keep.append(ue_id)
            used_slot.append(ues_id_rnti_slot[ue_id][1])
    time.sleep(10)
    for ue_id in ues_to_keep:
        sum_of_traffic += traffic_handling.get_summarize_data_rate_for_multiple_NSA_UEs(dir="DL", first_ue=ue_id,
                                                                                        last_ue=ue_id,
                                                                                        data_rate_type="Average",
                                                                                        bearer_type="scg", bearer=2)
    return sum_of_traffic


def get_from_message(flow_alias, message_alias, field):
    """
    Gets specific field value from message of specific flow
    :param flow_alias: flow aliases from earlier defined flow
    :param message_alias: message aliases from earlier defined flow
    :param field: filed which lokking in message
    :return: filed from message
    """
    msg = get_flow(flow_alias).get_message(message_alias)
    field_values = msg.get_all_values_by_key(field)
    if len(field_values) > 1:
        if field != 'eventId':
            return field_values[0]
        field_value_list = list()
        for field_value in field_values:
            field_value_list.append(field_value.keys()[0])
        return field_value_list
    else:
        return field_values[0]


def reboot_ap():
    ap_ssh_instance = ssh()
    ap_ssh_instance.connect_to(hostname="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu")
    output = ap_ssh_instance.execute("system-module-reboot; sleep 2; echo")
    rc = ap_ssh_instance.get_exit_status()
    ap_ssh_instance.disconnect()
    return rc, output


def reboot_gnb():
    gnb_ssh_instance = ssh()
    gnb_ssh_instance.connect_to(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    output = gnb_ssh_instance.execute("system-module-reboot; sleep 2; echo")
    rc = gnb_ssh_instance.get_exit_status()
    gnb_ssh_instance.disconnect()
    return rc, output


def verify_percentage_of_skipped_ues(csv_directory, expected_limit=0, direction='dl', dl_ca_enabled=False):
    """
    Verify that average values of dlSliceData and dlDrbWeight events in tti traces are in expected range
    :param csv_directory: (str) file path to collected tti traces in csv format
    :param expected_limit: expected max percentage of skipped ues
    :param direction: dl|ul
    :param dl_ca_enabled: (bool) True when dl carrier aggregation is enabled
    :return:
    """
    sum_of_skipped_ues = 0
    sum_of_scheduled_ues = 0
    if direction == 'dl':
        if dl_ca_enabled:
            column_skippedues = ['dlLoadControlData.fdSchedInfo[0].skippedUes',
                                 'dlLoadControlData.fdSchedInfo[1].skippedUes']
            column_scheduledues = ['dlLoadControlData.fdSchedInfo[0].scheduledUes',
                                   'dlLoadControlData.fdSchedInfo[1].scheduledUes']
        else:
            column_skippedues = ['dlLoadControlData.fdSchedInfo[0].skippedUes']
            column_scheduledues = ['dlLoadControlData.fdSchedInfo[0].scheduledUes']
        filename = 'output_dl.*'
    else:
        column_skippedues = ['ulLoadControlData.fdSchedInfo.skippedUes']
        column_scheduledues = ['ulLoadControlData.fdSchedInfo.scheduledUes']
        filename = 'output_ul.*'

    for csv_file in glob.glob(csv_directory + filename):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_values = csv_tti_trace.get_multiple_columns_values(*column_skippedues, *column_scheduledues,
                                                                     input_list=collected_tti, as_dict=True)
        if dl_ca_enabled:
            collected_values['dlLoadControlData.fdSchedInfo[0].skippedUes'].extend(
                collected_values['dlLoadControlData.fdSchedInfo[1].skippedUes'])
            collected_values['dlLoadControlData.fdSchedInfo[1].skippedUes'].clear()
            collected_values['dlLoadControlData.fdSchedInfo[0].scheduledUes'].extend(
                collected_values['dlLoadControlData.fdSchedInfo[1].scheduledUes'])
            collected_values['dlLoadControlData.fdSchedInfo[1].scheduledUes'].clear()

        for row in range(len(collected_values[column_skippedues[0]])):
            if collected_values[column_skippedues[0]][row] != "":
                sum_of_skipped_ues += int(int(float(collected_values[column_skippedues[0]][row])))
                sum_of_scheduled_ues += int(int(float(collected_values[column_scheduledues[0]][row])))

    skipped_to_scheduled_ues_ratio = round(sum_of_skipped_ues / (sum_of_skipped_ues + sum_of_scheduled_ues), 3)
    logging.info(f'sum_of_skipped_ues={sum_of_skipped_ues} sum_of_scheduled_ues={sum_of_scheduled_ues}')
    logging.info(f'percentage={skipped_to_scheduled_ues_ratio}')
    logger.console(f'*** Skipped to scheduled UEs ratio: {skipped_to_scheduled_ues_ratio}')

    assert sum_of_skipped_ues / (sum_of_skipped_ues + sum_of_scheduled_ues) <= expected_limit, \
        f'sum_of_skipped_UEs={sum_of_skipped_ues}\nsum_of_scheduled_ues={sum_of_scheduled_ues} ' \
        f'\npercentage={skipped_to_scheduled_ues_ratio} is bigger' \
        f' than {expected_limit}'


def attach_ue_to_specific_beam(ue_id=107, beam_id=0, target_cell=1):
    """
    attach ue to specific beam
    :param target_cell: cell used in command enb_ue_dc_start
    :param ue_id: id of UE
    :param beam_id: id of beam on which UE should be attached
    :return:
    """
    wts.execute_egate_command(cmd=f'ue_attach id={ue_id} profile=1')
    time.sleep(1)
    wts.execute_egate_command(cmd=f'beam_control_testmode_nr profile_id={ue_id} beamType=Analog '
                                  f'ueBeamIndexInitial={beam_id} ssbeam_bestbeam={beam_id} '
                                  f'ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
    time.sleep(2)

    wts.execute_egate_command(cmd=f'ue_testmode_set_nr id={ue_id} testmode=beam_control action=activate '
                                  f'profile_id={ue_id} beamaction=attach scell=8-20')
    time.sleep(2)

    wts.execute_egate_command(cmd=f'enb_ue_dc_start ue={ue_id} target_gnb=2 target_cells={target_cell} '
                                  f'bearer=2 type=split_scg')
    time.sleep(2)

    wts.execute_egate_command(cmd=f'ue_testmode_set_nr id={ue_id} testmode=csi_override action=activate '
                                  f'profile_id=1 scell=8-20')
    time.sleep(2)


def add_bearer_for_ue(ue_id=107, bearer_id=1):
    """
    attach ue on specific bearer
    :param ue_id: id of UE
    :param bearer_id: id of bearer which should be added
    :return:
    """
    bearer_addition_command = f'bearer_add ue={ue_id} id={bearer_id} filter=1 precedence=1'
    wts.execute_egate_command(cmd=bearer_addition_command)
    time.sleep(2)

    modify_command = f'enb_ue_dc_modify ue={ue_id} bearer_to_add={bearer_id} by=enb ' \
                     f'cause=RN_CauseRadioNetwork_unspecified type=split_scg'

    wts.execute_egate_command(cmd=modify_command)
    time.sleep(2)


def run_traffic(ue_id, trf_dir, mbps, bearer_id):
    """
    run traffic for given UE
    :param ue_id: id of UE
    :param bearer_id: id of bearer on which traffic will be running
    :param trf_dir: direction of traffic
    :param mbps: mbps for traffic
    :return:
    """
    traffic_command = f'trf_data_start ue={ue_id} id={bearer_id} dir={trf_dir} trf_id=1 mbps={mbps} size=1350'
    wts.execute_egate_command(cmd=traffic_command)


def set_specific_mcs_for_given_ue(ue_id, target_mcs, profile):
    """
    set specific mcs for specific ue
    :param ue_id: id of UE
    :param target_mcs: target mcs for UE
    :param target_cell: cell used in command enb_ue_dc_start
    :param bearer_id: id of bearer on should be added
    :param trf_dir: direction of traffic
    :param mbps: mbps for traffic
    :return:
    """
    if profile == 1:
        wts.execute_egate_command(cmd=f'adv_bler_testmode_nr profile_id={profile} '
                                      f'target_bler_profile_id={profile} '
                                      f'target_bler=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 '
                                      f'target_mcs={target_mcs} p_target_bler_profile_id={profile}')
    elif profile == 2:
        wts.execute_egate_command(cmd=f'adv_bler_testmode_nr profile_id={profile} '
                                      f'target_bler_profile_id={profile} '
                                      f'target_bler=0,0,0,0,5,5,5,5,5,5,5,0,0,0,0 '
                                      f'target_mcs={target_mcs} p_target_bler_profile_id={profile}')
    elif profile == 3:
        wts.execute_egate_command(cmd=f'adv_bler_testmode_nr profile_id={profile} '
                                      f'target_bler_profile_id={profile} '
                                      f'target_bler=0,0,0,10,10,10,10,10,10,10,10,0,0,0,0 '
                                      f'target_mcs={target_mcs} p_target_bler_profile_id={profile}')

    wts.execute_egate_command(cmd=f'ue_testmode_nr_set id={ue_id} testmode=adv_bler '
                                  f'action=activate profile_id={profile}')
    time.sleep(1)


def set_specific_mcs_for_multi_ues(first_ue=107, last_ue=159, target_mcs=27, profile=1):
    """
    set specific mcs for multi ues
    :param target_mcs: target mcs for UE
    :param first_ue: id of first UE on given beam
    :param last_ue: id of last UE on given beam
    :param profile: profile
    :return:
    """
    if profile == 1:
        wts.execute_egate_command(cmd=f'adv_bler_testmode_nr profile_id={profile} '
                                      f'target_bler_profile_id={profile} '
                                      f'target_bler=70,60,50,40,30,20,0,0,0,0,0,0,0,0,0 '
                                      f'target_mcs={target_mcs} p_target_bler_profile_id={profile}')
    elif profile == 2:
        wts.execute_egate_command(cmd=f'adv_bler_testmode_nr profile_id={profile} '
                                      f'target_bler_profile_id={profile} '
                                      f'target_bler=80,70,60,50,40,20,10,5,5,5,0,0,0,0,0 '
                                      f'target_mcs={target_mcs} p_target_bler_profile_id={profile}')
    elif profile == 3:
        wts.execute_egate_command(cmd=f'adv_bler_testmode_nr profile_id={profile} '
                                      f'target_bler_profile_id={profile} '
                                      f'target_bler=80,70,60,50,40,30,20,10,10,5,0,0,0,0,0 '
                                      f'target_mcs={target_mcs} p_target_bler_profile_id={profile}')

    wts.execute_egate_command(
        cmd=f'ue_testmode_nr_set id={first_ue}-{last_ue} scell=0-31 testmode=adv_bler '
            f'action=activate profile_id={profile}')
    time.sleep(1)


def attach_multi_ues_to_specific_beam_and_bearer_with_traffic(first_ue=107, last_ue=159, beam_id=0, bearer_id=2,
                                                              mbps=80, trf_dir='dl'):
    """
    attach ue to specific beam on specific bearer and run traffic
    :param first_ue: id of first UE on given beam
    :param last_ue: id of last UE on given beam
    :param beam_id: id of beam on which UE should be attached
    :param bearer_id: id of bearer on should be added
    :param trf_dir: direction of traffic
    :param mbps: mbps for traffic
    :return:
    """
    for ue_id in range(first_ue, last_ue + 1):
        attach_ue_to_specific_beam(ue_id, beam_id)
        add_bearer_for_ue(ue_id, bearer_id)
        run_traffic(ue_id, trf_dir, mbps, bearer_id)
        time.sleep(2)


def attach_multi_ues_to_specific_beam_with_traffic(first_ue=107, last_ue=159, bearer_id=2, beam_id=0, mbps=80,
                                                   trf_dir='dl', target_cell=1):
    """
    attach ue to specific beam and run traffic
    :param first_ue: id of first UE on given beam
    :param last_ue: id of last UE on given beam
    :param bearer_id: id of bearer on should be added
    :param beam_id: id of beam on which UE should be attached
    :param mbps: mbps for traffic
    :param trf_dir: direction of traffic
    :param target_cell: cell used in command enb_ue_dc_start
    :return:
    """
    for ue_id in range(first_ue, last_ue + 1):
        attach_ue_to_specific_beam(ue_id, beam_id, target_cell)
        run_traffic(ue_id, trf_dir, mbps, bearer_id)


def attach_multi_ues_to_different_beams_with_traffic(first_ue=107, last_ue=138, bearer_id=2, mbps=80, trf_dir='dl',
                                                     target_cell=1):
    """
    attach ues to different beam on given PCell and traffic
    :param first_ue: id of first UE on given beam
    :param last_ue: id of last UE on given beam
    :param bearer_id: id of bearer on should be added
    :param mbps: mbps for traffic
    :param target_cell: cell used in command enb_ue_dc_start
    :param trf_dir: direction of traffic
    :return:
    """

    for ue_id in range(first_ue, last_ue + 1):
        beam_id = ue_id - 107
        attach_ue_to_specific_beam(ue_id, beam_id, target_cell)
        run_traffic(ue_id, trf_dir, mbps, bearer_id)


def attach_multi_ues_and_run_traffic(first_ue=107, last_ue=138, bearer_id=2, mbps=100, trf_dir='dl', target_cell=1):
    """
    attach ues to and run traffic
    :param first_ue: id of first UE
    :param last_ue: id of last UE
    :param bearer_id: id of bearer
    :param mbps: mbps for traffic
    :param target_cell: cell used in command enb_ue_dc_start
    :param trf_dir: direction of traffic
    :return:
    """

    for ue_id in range(first_ue, last_ue + 1):
        attach_command = f'ue_attach id={ue_id} profile=1'
        wts.execute_egate_command(cmd=attach_command)
        time.sleep(1)
        ue_dc = f'enb_ue_dc_start ue={ue_id} target_gnb=2 target_cells={target_cell} bearer={bearer_id} type=split_scg'
        wts.execute_egate_command(cmd=ue_dc)
        time.sleep(1)
        run_traffic(ue_id, trf_dir, mbps, bearer_id)
        time.sleep(1)


def register_multi_ues_and_run_traffic(first_ue=1, last_ue=53, pdu=1, qfi=1, mbps=100, cell_id=1, nwslice=1, gw=1,
                                       trf_dir='dl',
                                       protocol='udp', size=1350, packets=None):
    """
    attach ues to and run traffic
    :param first_ue: id of first UE
    :param last_ue: id of last UE
    :param ue: (mandatory)
    :param pdu: pdu id (optional, default equal to ue_id)
    :param trf_dir: dl, DL, ul, UL (mandatory)
    :param mbps: requested traffic rate mbps/kbps/bps (mandatory)
    :param protocol: (optional, default udp)
    :param size: packet size range (optional)
    :param packets: maximum packets to generate (optional)
    :return:
    """

    for ue_id in range(first_ue, last_ue + 1):
        set_pdu = f'set_pdu_param ue={ue_id} pdu={pdu} trf_type=internal'
        register = f'ue_register id={ue_id}'
        change_location = f'ue_change_location id={ue_id} cell={cell_id} enb=2'
        register_regexp = f'UE{ue_id}: UE performed Registration type INITIAL_REGISTRATION'
        wts.execute_egate_command(cmd=set_pdu)
        time.sleep(1)
        wts.execute_egate_command(cmd=change_location)
        time.sleep(1)
        wts.execute_egate_command(cmd=register, pass_regexp=register_regexp)
        time.sleep(1)
        ue_pdu = f'ue_pdu_session_setup pdu={pdu} ue={ue_id} nwslice={nwslice} gw={gw}'
        pdu_regexp = f'UE{ue_id}: Established PDU session'
        wts.execute_egate_command(cmd=ue_pdu, pass_regexp=pdu_regexp)
        time.sleep(1)

        for trf_id in range(1, mbps // 175 + 2):
            command = f'trf_data_start ' \
                      f'ue={ue_id} ' \
                      f'pdu={pdu} ' \
                      f'qfi={qfi} ' \
                      f'dir={trf_dir.lower()} ' \
                      f'mbps={min(mbps, 175)} ' \
                      f'trf_id={trf_id} ' \
                      f'protocol={protocol} ' \
                      f'size={size} '
            mbps -= mbps % 175
            if packets:
                command += f'packets={packets}'
            wts.execute_egate_command(cmd=command)


def get_number_of_active_ccs(dir, scells, first_ue=107, last_ue=159):
    """
    Get number of active CCs for given UEs
    -  :param dir: dl|ul
    -  :param scells: scells which should be measured
    -  :param first_ue: ue id of first UE
    -  :param first_ue: ue id of last UE
    :return:
    """
    counter = 0
    traffic_type = {'dl': 'pdsch', 'ul': 'pusch'}
    ta_egate = ta_egate_cmd_parser()
    cmd = ta_egate.get_command('ue_stats_nr')
    for ue in range(first_ue, last_ue + 1):
        try:
            ue_stats_nr = cmd(id=ue, scell=scells, type=traffic_type[dir.lower()]).execute_and_parse()
            for idx in range(int(scells.split('-')[0]), int(scells.split('-')[1]) + 1):
                if int(float(ue_stats_nr[f'CellIndex-{idx}']['Average']['value'])) > 0:
                    counter += 1
        except Exception as error:
            logging.info('NR UEStats are supported only for Active UE')
    return counter


def create_ues_id_string(first_ue, last_ue):
    ues_id_string = str(first_ue)
    for ue in range(int(first_ue) + 1, int(last_ue) + 1):
        ues_id_string += ",{}".format(str(ue))
    return ues_id_string


def compare(number1, relation, number2, compared_types='AssertionError'):
    if relation == "<":
        assert float(number1) < float(number2), f'{compared_types}: {number1} is not "{relation}" than {number2}'
    if relation == ">":
        assert float(number1) > float(number2), f'{compared_types}: {number1} is not "{relation}" than {number2}'
    if relation == ">=":
        assert float(number1) >= float(number2), f'{compared_types}: {number1} is not "{relation}" than {number2}'
    if relation == "<=":
        assert float(number1) <= float(number2), f'{compared_types}: {number1} is not "{relation}" than {number2}'
    if relation == "=":
        assert float(number1) == float(number2), f'{compared_types}: {number1} is not "{relation}" than {number2}'


def prepare_iwf_configuration():
    try:
        subprocess.run([
            'cp', '/home/ute/MN/UTE/robotws/testsuite/Krakow/RRM/Airphone/CB012734/config/iwf_preconfigs.py',
            '/opt/wts/latest/'],
            check=True)
        subprocess.run([
            'cp', '/home/ute/MN/UTE/robotws/testsuite/Krakow/RRM/Airphone/CB012734/config/iwf_launch.py',
            '/opt/wts/latest/'],
            check=True)
    except Exception as error:
        raise Exception("Copy error occurred:", error)

    try:
        preconfig_iwf.config_iwf()
    except subprocess.CalledProcessError as cpe:
        if cpe.returncode == 75:
            logging.info("env3s interface already created")
        else:
            raise
    except Exception as error:
        raise Exception("Preconfigs error occurred:", error)

    try:
        lauch_iwf.iwf_launch_start()
    except Exception as error:
        raise Exception("Launch error occurred:", error)


def iwf_preconfigs_teardown():
    preconfig_iwf.teardown_iwf()
