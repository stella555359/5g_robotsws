import re
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import log_finder
from testsuite.Wroclaw.RRM.resources.tti_verification.csv_verification import process_needed_messages


assert_msg = '\n'.join(["{message}", "Expected: {expected}", "But was: {current}"])
MAX_SFN = 1024
MAX_SLOT = 10
default_scf_params = {'csirsTrackingPeriod': '80ms', 'actProactUlScheduling': 'true'}
route_ip_counter = 41
message_type_pattern = 'structure'


def single_ue_scheduled_per_slot(pcap_file, rntis):
    check_if_single_ue_in_frame(pcap_file, 'dldata_pdschsendreq', 'PdschSendReq')
    check_if_single_ue_in_frame(pcap_file, 'uldata_puschreceivereq', 'PuschReceiveReq')
    single_frame_of_given_type_per_slot(pcap_file, rntis, 'dldata_pdschsendreq', 'PdschSendReq')
    single_frame_of_given_type_per_slot(pcap_file, rntis, 'uldata_puschreceivereq', 'PuschReceiveReq')


def check_if_single_ue_in_frame(pcap_file, frame_type, message_name_pattern):
    relevant_frames = log_finder(pcap_file, frame_type, message_name_pattern, message_type_pattern)
    for frame in relevant_frames:
        rnti_paths = frame.find('rnti*')
        assert len(rnti_paths) == 1, 'More than one UE scheduled on this slot.'


def single_frame_of_given_type_per_slot(pcap_file, rntis, frame_type, message_name_pattern):
    relevant_frames = log_finder(pcap_file, frame_type, message_name_pattern, message_type_pattern)
    for idx in range(len(relevant_frames) - 1):
        previous_frame = relevant_frames[idx]
        prev_rnti = previous_frame.find('rnti*').first()['val']
        prev_sfn = previous_frame.find('sfn*').first()['val']
        prev_slot = previous_frame.find('slot*').first()['val']

        next_frame = relevant_frames[idx + 1]
        next_rnti = next_frame.find('rnti*').first()['val']
        next_sfn = next_frame.find('sfn*').first()['val']
        next_slot = next_frame.find('slot*').first()['val']

        both_rntis_are_not_ghosts = prev_rnti in rntis and next_rnti in rntis
        if both_rntis_are_not_ghosts:
            assert prev_sfn != next_sfn and prev_slot != next_slot, \
                'Two messages of type {frame_type} found in one slot'.format(frame_type=frame_type)


def all_ues_are_scheduled(ue_rntis, pcap_file):
    try:
        check_if_all_rntis_present_in_frame_type('dldata_pdschsendreq', 'PdschSendReq', ue_rntis, pcap_file)
        check_if_all_rntis_present_in_frame_type('uldata_puschreceivereq', 'PuschReceiveReq', ue_rntis, pcap_file)
    except AssertionError:
        blog('Not all UEs are scheduled correctly.')


def check_if_all_rntis_present_in_frame_type(frame_type, message_name_pattern, ue_rntis, pcap_file):
    rntis_from_pcap = []
    all_pusch_rec_req = log_finder(pcap_file, frame_type, message_name_pattern, message_type_pattern)
    for frame in all_pusch_rec_req:
        rnti = frame.find('rnti*').first()['val']
        rnti = re.search(r'\((.*)\)', rnti).group(1)
        rntis_from_pcap.append(rnti)

    unique_rntis = set(rntis_from_pcap)
    ues_diff = set(ue_rntis) - unique_rntis
    assert not ues_diff, \
        'FOUND {ues_found} UEs INSTEAD OF {exp_ues}'.format(ues_found=unique_rntis, exp_ues=set(ue_rntis))


def check_proactive_scheduling_uldl(tti_traces_folder, rntis):
    relevant_msgs = ['ulPreSchedData']
    pre_sched_data_traces = process_needed_messages(tti_traces_folder, relevant_msgs)
    pre_sched_data_traces = [msg for msg in pre_sched_data_traces if msg['csListEvent'] == 'ENTRYPROACTIVEPUSCH']
    assert pre_sched_data_traces, assert_msg.format(
        message='ERROR: csListEvent parsing failed.',
        current='ENTRYPROACTIVEPUSCH message in csListEvent missing or TTI trace is empty',
        expected='csListEvent contains ENTRYPROACTIVEPUSCH message')
    check_proactive_grant_slot_is_increasing_by_5(pre_sched_data_traces, rntis)


def check_proactive_grant_slot_is_increasing_by_5(pre_sched_data_traces, rntis):
    previous_slot_by_rnti = {r: None for r in rntis}
    total_grants = 0
    wrong_grants = 0

    for pre_sched_data in pre_sched_data_traces:
        current_rnti = pre_sched_data['rnti']
        current_slot = pre_sched_data['slot']
        if current_rnti in rntis:
            total_grants += 1
            if not previous_slot_by_rnti[current_rnti]:
                previous_slot_by_rnti[current_rnti] = int(current_slot)
            else:
                if not str(current_slot) == str((previous_slot_by_rnti[current_rnti] + 5) % MAX_SLOT):
                    wrong_grants += 1
                previous_slot_by_rnti[current_rnti] = int(current_slot)

    blog('wrong_grants: {}, total_grants: {}'.format(wrong_grants, total_grants))
    error_in_percent = wrong_grants * 100 / total_grants
    blog('error: {}%.'.format(error_in_percent))
    assert error_in_percent <= 10, \
        assert_msg.format(
            message='Increase in slot for proactive scheduling should be 5 every time',
            expected='at most 10% error',
            current='{}% error'.format(error_in_percent))


def check_csi_rs_periodicity(pcap_file, periodicity_as_sfn=16):
    csi_send_req_frames = log_finder(pcap_file, 'dldata_csirssendreq', 'CsirsSendReq', message_type_pattern)
    previous_sfn = None
    for frame in csi_send_req_frames:
        start_symbol = frame.find('startSymbol*').first()['val']
        csi_resources_length = frame.find('csiRsResources-Length*').first()['val']
        if start_symbol == '0x0d' and csi_resources_length == 1:
            if not previous_sfn:
                previous_sfn = int(frame.find('sfn*').first()['val'], 16)
            else:
                current_sfn = int(frame.find('sfn*').first()['val'], 16)
                assert current_sfn == (previous_sfn + periodicity_as_sfn) % MAX_SFN, \
                    assert_msg.format(
                        message='Invalid period of CSI-RS.', expected='Period should be 16 sfn.', current='')
                previous_sfn = current_sfn


def check_csi_sr_report_periodicity(tti_file, rntis, periodicity_as_sfn=16):
    needed_messages = ['csiSrReportData']
    messages_info = process_needed_messages(tti_file, needed_messages)
    previous_sfn = None
    total_csi_sr = 0
    wrong_csi_sr = 0
    csi_msgs = []

    for message in messages_info:
        if message['rnti'] in rntis:
            total_csi_sr += 1
            if previous_sfn is None:
                previous_sfn = int(message['sfn'])
            else:
                current_sfn = int(message['sfn'])
                if not current_sfn == (previous_sfn + periodicity_as_sfn) % MAX_SFN:
                    wrong_csi_sr += 1
                else:
                    csi_msgs.append(message)
                previous_sfn = current_sfn

    error_in_percent = wrong_csi_sr * 100 / total_csi_sr
    blog('error: {}%.'.format(error_in_percent))
    assert error_in_percent <= 5, assert_msg.format(
        message='Invalid period of CSI Sr report.', expected='Period should be 160ms (16 sfn).', current='')
    return csi_msgs


def check_csi_pucch_configuration(pcap_file, csi_msgs):
    receive_resp_ps = find_matching_pucch_receive_resp_ps(pcap_file, csi_msgs)
    receive_req = find_matching_pucch_receive_req(pcap_file, csi_msgs)

    for resp, req in zip(receive_resp_ps, receive_req):
        num_of_uci_bits = req.find('numOfBitsOfUciInformation*').first()['val'].split('(')[0]
        assert int(num_of_uci_bits, 16) >= 8, \
            assert_msg.format(message='Wrong number of UCI bits.',
                              expected='Higher or equal than 0x08',
                              current=num_of_uci_bits)
        pucch_format = req.find('pucchFormat*').first()['val'].split('(')[0].strip()
        assert pucch_format in ['2', '3'], \
            assert_msg.format(message='Wrong pucch format.', expected='2 or 3', current=pucch_format)
        num_of_symbols = req.find('numOfSymbols*').first()['val'].split('(')[0]
        assert num_of_symbols in ['0x01', '0x0e'], \
            assert_msg.format(message='Wrong number of symbols.', expected='0x01 or 0x0e', current=num_of_symbols)
        pucch_format = resp.find('pucchFormat*').first()['val'].split('(')[0].strip()
        assert pucch_format in ['2', '3'], \
            assert_msg.format(message='Wrong pucch format.', expected='2 or 3', current=pucch_format)
        req_start_prb = req.find('startPrb*').filter('pucchResources-Payload').first()['val'].split('(')[0]
        resp_start_prb = resp.find('startPrb*').first()['val'].split('(')[0]
        assert resp_start_prb == req_start_prb, \
            assert_msg.format(
                message='StartPrb in receiveReq and receiveRespPs are not matching.', expected='', current='')


def find_matching_pucch_receive_resp_ps(pcap_file, csi_msgs):
    return find_matching_pucch_receive_X(pcap_file, csi_msgs, 'uldata_pucchreceiverespps', 'PucchReceiveRespPs')


def find_matching_pucch_receive_req(pcap_file, csi_msgs):
    return find_matching_pucch_receive_X(pcap_file, csi_msgs, 'uldata_pucchreceivereq', 'PucchReceiveReq')


def find_matching_pucch_receive_X(pcap_file, csi_msgs, frame_type, message_name_pattern):
    pucch_receive_resp_ps_frames = log_finder(pcap_file, frame_type, message_name_pattern, message_type_pattern)
    matched_pucch = []
    for csi in csi_msgs:
        is_match_found = 0

        for frame in pucch_receive_resp_ps_frames:
            rnti, sfn, slot = get_rnti_sfn_slot_from_frame(frame)
            if int(csi['rnti']) == rnti and int(csi['sfn']) == sfn and int(csi['slot']) == slot:
                matched_pucch.append(frame)
                is_match_found += 1
                break
    return matched_pucch


def get_rnti_sfn_slot_from_frame(frame):
    rnti = int(frame.find('rnti*').first()['val'].split('(')[0], 16)
    sfn = int(frame.find('sfn*').first()['val'].split('(')[0], 16)
    slot = int(frame.find('slot*').first()['val'].split('(')[0], 16)
    return rnti, sfn, slot


def check_rach_msg1_is_sent_on_single_occasion(pcap_file, num_of_ues=2):
    ra_msg1_frames = log_finder(pcap_file, 'uldata_prachreceiveind', 'PrachReceiveInd', message_type_pattern)
    for msg1 in ra_msg1_frames:
        num_of_preambles = msg1.find('detectedPrachPreambles-Length*').first()['val'].split('(')[0]
        all_peak_metrics = get_prach_peak_metrics_from_frame(msg1)
        valid_peak_metrics = get_number_of_valid_peak_metrics(all_peak_metrics)

        if int(num_of_preambles, 16) >= num_of_ues and valid_peak_metrics == 2:
            global msg1_sfn
            msg1_sfn = msg1.find('sfn*').first()['val']
            return
    assert False, assert_msg.format(
        message='RACH procedure invalid.',
        current='No RACH occasion, which contains all UEs.',
        expected='There must be a RACH occasion, for which all UEs are handled together.')


def get_prach_peak_metrics_from_frame(frame_tree):
    return [float(peak_metric['val'].split('(')[0]) for peak_metric in frame_tree.find('peakMetric*')]


def get_number_of_valid_peak_metrics(all_peak_metrics):
    valid_peak_metrics = 0
    for peak_metric in all_peak_metrics:
        if peak_metric >= float(1e+5):
            valid_peak_metrics += 1
    return valid_peak_metrics


def check_rach_msg2_sent_according_to_msg1_peak_metric(tti_file, rntis, num_of_ues=2):
    needed_messages = ['dlPreSchedData']
    messages_info = process_needed_messages(tti_file, needed_messages)
    ENTRY_ADD_UE = 'ENTRYPENDINGRACH2'

    ra_msg2_lst = []
    relevant_rnti_and_peak_metrics = []
    for msg in messages_info:
        if msg['csListEvent'] == ENTRY_ADD_UE and (msg['rnti'] in rntis):
            ra_msg2_lst.append(msg)
            relevant_rnti_and_peak_metrics.append([msg['rnti'], float(msg['prachPeakMetric'])])
    assert len(ra_msg2_lst) == num_of_ues, assert_msg.format(
        message='Not all UEs have received Msg2.',
        expected='{ues} ENTRYADDUE events'.format(ues=num_of_ues),
        current='{found_ues} ENTRYADDUE events'.format(found_ues=len(ra_msg2_lst)))

    PEAK_METRIC_IDX = 1
    relevant_rnti_and_peak_metrics = sorted(relevant_rnti_and_peak_metrics, key=lambda x: x[PEAK_METRIC_IDX])
    assert check_msg2_receive_order(relevant_rnti_and_peak_metrics, tti_file), assert_msg.format(
        message='RACH Msg2 should be sent according to preamble peak metric from Msg1.',
        expected='Higher peak metric sent first',
        current='Lower peak metric sent first')

    assert check_rach_msg2_is_only_in_resp_window(ra_msg2_lst, msg1_sfn), \
        blog('All RACH Msg2 should be sent during the response window period.')


def check_msg2_receive_order(relevant_rnti_and_peak_metrics, tti_file):
    needed_messages = ['dlTdSchedSubcellData']
    messages_info = process_needed_messages(tti_file, needed_messages)
    already_checked = []
    RNTI_IDX = 0
    next_ue_for_msg2 = relevant_rnti_and_peak_metrics[-1]
    for msg in messages_info:
        values = msg.values()
        if next_ue_for_msg2[RNTI_IDX] in values and '99' in values:
            if not all(rnti not in values for rnti in already_checked):
                return False
            already_checked.append(relevant_rnti_and_peak_metrics.pop()[RNTI_IDX])
            if not relevant_rnti_and_peak_metrics:
                break
            next_ue_for_msg2 = relevant_rnti_and_peak_metrics[-1]

    if relevant_rnti_and_peak_metrics:
        return False
    return True


def check_rach_msg2_is_only_in_resp_window(ra_msg2_lst, msg1_sfn):
    RESP_WINDOW_IN_SFN = 8
    for msg2 in ra_msg2_lst:
        is_in_resp_window = abs(int(msg2['sfn'].split('(')[0]) - int(msg1_sfn.split('(')[0], 16)) <= RESP_WINDOW_IN_SFN
        if not is_in_resp_window:
            return False
    return True


def check_used_mcs_equals_proposed(tti_file, rntis, margin=25):
    check_mcs_according_to_data_in_buffer(tti_file, rntis, margin, compare=lambda x, y: x >= y)


def check_used_mcs_is_less_than_proposed(tti_file, rntis, margin=25):
    check_mcs_according_to_data_in_buffer(tti_file, rntis, margin, compare=lambda x, y: x < y)


def check_mcs_according_to_data_in_buffer(tti_file, rntis, margin, compare=lambda x, y: x == y):
    needed_messages = ['dlFdSchedData']
    messages_info = process_needed_messages(tti_file, needed_messages)
    log_msg = 'Used MCS should equal proposed MCS, when DL buffer is full ' \
              'and be less than proposed otherwise.'
    wrong_mcs = 0
    total_mcs = 0

    for msg in messages_info:
        if msg['rnti'] in rntis:
            total_mcs += 1
            rrm_dl_used_mcs = int(msg['rrmDlUsedMcs'])
            rrm_dl_proposed_mcs = int(msg['rrmDlProposedMcs'])

            if not compare(rrm_dl_used_mcs, rrm_dl_proposed_mcs):
                wrong_mcs += 1
            assert is_supported_mcs(rrm_dl_used_mcs), assert_msg.format(
                message='Used mcs should stay between 0-28', expected='between 0-28', current=str(rrm_dl_used_mcs))

    error_in_percent = wrong_mcs * 100 / total_mcs
    blog('error: {}%.'.format(error_in_percent))
    assert error_in_percent <= margin, assert_msg.format(
        message=log_msg, expected='at most {}% error.'.format(margin), current='{}% error.'.format(error_in_percent))


def is_supported_mcs(rrm_dl_used_mcs):
    supported_mcs_range = range(0, 29)
    return int(rrm_dl_used_mcs) in supported_mcs_range or int(rrm_dl_used_mcs) == 255


def check_prb_allocation_is_the_same_for_all_dl(tti_file, rntis):
    needed_messages = ['dlFdSchedData']
    messages_info = process_needed_messages(tti_file, needed_messages)

    for msg in messages_info:
        if msg['rnti'] in rntis:
            numOfPrb = msg['numOfPrb']
            startPrb = msg['startPrb']
            assert numOfPrb == messages_info[0]['numOfPrb'] and startPrb == messages_info[0]['startPrb'], \
                assert_msg.format(
                    message='Invalid PRB allocation.',
                    expected='All FdSchedData should have equal numOfPrb and startPrb.',
                    current='numOfPrb and startPrb are not equal throughout all dlFdSchedData.')


def check_pucch_timing(pcap_file):
    pucch_req = log_finder(pcap_file, 'uldata_pucchreceivereq', 'PucchReceiveReq', message_type_pattern)
    pucch_req = get_csi_pucch_frames(pucch_req)
    pucch_resp_ps = log_finder(pcap_file, 'uldata_pucchreceiverespps', 'PucchReceiveRespPs', message_type_pattern)
    pucch_resp_ps = get_csi_pucch_frames(pucch_resp_ps)

    matches_found = 0
    relevant_rntis_sfns_slots = get_csi_pucch_frames_info(pucch_resp_ps)
    for resp_rnti, resp_sfn, resp_slot in relevant_rntis_sfns_slots:
        for req in pucch_req:
            req_rnti, req_sfn, req_slot = get_rnti_sfn_slot_from_frame(req)
            if resp_rnti == req_rnti and resp_sfn == req_sfn and resp_slot == req_slot:
                matches_found += 1

    assert matches_found == len(relevant_rntis_sfns_slots), assert_msg.format(
        message='pucchReceiveRequest and response should be sent in the same sfn and slot',
        expected='All requests have a matching response',
        current='{} requests without matching response'.format(len(relevant_rntis_sfns_slots) - matches_found))


def get_csi_pucch_frames(frames):
    pucch_frames = []
    for frame in frames:
        pucch_format_tree = frame.find('pucchFormat*')

        for pucch_format in pucch_format_tree:
            pucch_format = str(int(pucch_format['val'].split('(')[0].strip(), 16))
            if pucch_format == '2':
                pucch_frames.append(frame)
                break

    return pucch_frames


def get_csi_pucch_frames_info(frames):
    rntis_sfns_slots = []
    for frame in frames:
        rnti_tree = frame.find('rnti*')
        pucch_format_tree = frame.find('pucchFormat*')
        sfn = int(frame.find('sfn*').first()['val'].split('(')[0], 16)
        slot = int(frame.find('slot*').first()['val'].split('(')[0], 16)

        for pucch_format, rnti in zip(pucch_format_tree, rnti_tree):
            pucch_format = int(pucch_format['val'].split('(')[0].strip(), 16)
            if pucch_format == '2':
                rnti = int(rnti['val'].split('(')[0], 16)
                rntis_sfns_slots.append((rnti, sfn, slot))

    return rntis_sfns_slots


def format_spaces(output):
    new_output = []
    for message in output:
        new_message = []
        for line in message:
            new_line = line.replace(' ', '')
            new_message.append(new_line)
        new_output.append(new_message)
    return new_output


def hextobin(hexval):
    """
    Takes a string representation of hex data with
    arbitrary length and converts to string representation
    of binary.  Includes padding 0s
    """
    thelen = len(hexval) * 4
    binval = bin(int(hexval, 16))[2:]
    while len(binval) < thelen:
        binval = '0' + binval
    return binval


def get_frames_containing_string(pattern, frames):
    """ returns frames that contain string """
    out = []
    for frame in frames:
        for line in frame:
            if pattern in str(line):
                out.append(frame)
                break
    return out


def check_first_pucch_receiver_responses_for_each_ue(pcap_file, rntis):
    """
    This function checks if the first pucch receiver response (msg1) at the start of data traffic has the first bit
    of UCI bytes set to '1' for each UE.
    """
    stream_20A_filter = '(UlData_PucchReceiveRespPs.pucchResources_item_15.pucchFormat == 2 \
        || (UlData_PucchReceiveReq.pucchResources_item_15.pucchFormat == 2 \
        && UlData_PucchReceiveReq.pucchResources_item_15.numOfBitsOfUciInformation == 0x08))'

    stream_trunk_filter = '(UlData_PucchReceiveRespPs.pucchResources_item_85.pucchFormat == 2 \
        || (UlData_PucchReceiveReq.pucchResources_item_85.pucchFormat == 2 \
        && UlData_PucchReceiveReq.pucchResources_item_85.numOfBitsOfUciInformation == 0x08))'

    pucchreceiverespps = log_finder(pcap_file, 'uldata_pucchreceiverespps', 'PucchReceiveRespPs', message_type_pattern)
    pucchreceivereq = log_finder(pcap_file, 'uldata_pucchreceivereq', 'PucchReceiveReq', message_type_pattern)
    output = pucchreceiverespps + pucchreceivereq

    output = get_csi_pucch_frames(output)
    for rnti in rntis:
        messages = get_frames_containing_string(str(rnti), output)
        bin_bits = '0'
        for index, message in enumerate(messages):
            if 'PucchReceiveReq' in str(message):
                if 'PucchReceiveRespPs' in str(messages[index + 1]):
                    for element in messages[index + 1]:
                        if 'uciBits_item_0' in element:
                            element_value = element.split(':')[-1]
                            hex_bytes = element_value.split('(')[0]
                            bin_bits = bin(int(hex_bytes, 16))[2:].zfill(8)
                            if str(bin_bits[0]) == '1':
                                blog('Proper first PucchReceiveRespPs for rnti {} has been confirmed.'
                                     .format(str(rnti)))
                                break
            if bin_bits[0] == '1':
                break
            assert not message == messages[-1]
