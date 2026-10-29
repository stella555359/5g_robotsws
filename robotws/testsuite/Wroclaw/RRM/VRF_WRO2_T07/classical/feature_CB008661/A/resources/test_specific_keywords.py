from datetime import datetime
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections import connect_to_uepc, _ssh
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher

scf_params_a1 = {'actCDrx': 'false', 'actCDrxVoNR': 'false',
                 'actProactUlScheduling': 'false', 'actAdaptiveSr': 'false'}
scf_params_a2 = {'actCDrx': 'true', 'actCDrxVoNR': 'true',
                 'actProactUlScheduling': 'true', 'actAdaptiveSr': 'false'}
scf_params_a3 = {'actCDrx': 'false', 'actCDrxVoNR': 'false', 'actProactUlScheduling': 'false', 'actAdaptiveSr': 'true'}
scf_params_a4 = {'actCDrx': 'true', 'actCDrxVoNR': 'true', 'actProactUlScheduling': 'true', 'actAdaptiveSr': 'true'}
scf_params_a5 = {'actCDrx': 'true', 'actCDrxVoNR': 'true'}
scf_params_a6 = {'actCDrx': 'true', 'actCDrxVoNR': 'true'}
scf_params_a7 = {'actCDrx': 'true', 'actCDrxVoNR': 'true'}
scf_params_a11 = {'actCDrx': 'true', 'actCDrxVoNR': 'true'}

TIME_FORMAT = '%H:%M:%S.%f'


def perform_ping_test_on_ue(ue_serial_number, count, packet_size, ip, latency_threshold):
    blog('Start ping test on UE...')
    output = send_ping_from_ue_to_core_network(ue_serial_number, count, packet_size, ip)
    delays = get_ping_delays_from_output(output)
    delays = delays[1:]

    if delays:
        avg_delay = sum(delays) / len(delays)
        blog('Avg. ping delay for packet_size={}: {} ms'.format(packet_size, avg_delay))
    else:
        raise Exception('No ping entries were found. Ping probably did not run properly.')

    assert avg_delay <= float(latency_threshold), 'Ping delay is too large.'
    blog('Ping test finished successfully.')


def send_ping_from_ue_to_core_network(ue_serial_number, count, packet_size, ip):
    conn = connect_to_uepc()
    cmd = construct_ping_cmd(ue_serial_number, count, packet_size, ip)
    blog('Sending command to UE: {}'.format(cmd))
    output = _ssh.execute(command=cmd, connection=conn)
    return output


def construct_ping_cmd(ue_serial_number, count, packet_size, ip):
    base_cmd = 'adb -s {} shell "ping{} -c {} -s {} {}"'
    if is_ipv6(ip):
        return base_cmd.format(ue_serial_number, '6', count, packet_size, ip)
    return base_cmd.format(ue_serial_number, '', count, packet_size, ip)


def is_ipv6(ip):
    return len(ip.split(':')) == 8


def get_ping_delays_from_output(output):
    lines = [line for line in output.split('\r\r\n') if 'bytes from' in line]
    return [get_ping_delay_from_line(line) for line in lines]


def get_ping_delay_from_line(line):
    time_field = line.split(' ')[-2]
    time_ms = time_field.split('=')[-1]
    return float(time_ms)


def analyze_latency_of_vonr_call(vonr_start_logs, vonr_stop_logs):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=vonr_start_logs,
                             tshark_filter='f1ap || ngap',
                             lua=None)

        rrc_setup_req = PcapMessageMatcher('InitialULRRCMessageTransfer', message_type_pattern='empty')
        initial_context_setup_resp = PcapMessageMatcher('InitialContextSetupResponse', message_type_pattern='empty')
        all_rrc_setup_req = finder.find_all(rrc_setup_req)
        all_initial_context_setup_resp = finder.find_all(initial_context_setup_resp)

    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=vonr_stop_logs,
                             tshark_filter='f1ap || ngap',
                             lua=None)
        pdu_session_mod_req = PcapMessageMatcher('PDUSessionResourceModifyRequest', message_type_pattern='empty')
        pdu_session_mod_resp = PcapMessageMatcher('PDUSessionResourceModifyResponse', message_type_pattern='empty')
        all_pdu_session_mod_req = finder.find_all(pdu_session_mod_req)
        all_pdu_session_mod_resp = finder.find_all(pdu_session_mod_resp)

    assert lists_are_non_empty(all_rrc_setup_req, all_initial_context_setup_resp), \
        'Not all necessary messages for VoNR START could be found in SCTP logs.'

    assert lists_are_non_empty(all_pdu_session_mod_req, all_pdu_session_mod_resp), \
        'Not all necessary messages for VoNR STOP could be found in SCTP logs.'

    vonr_start_latency = get_delay_between_msgs(all_rrc_setup_req[0], all_initial_context_setup_resp[0])
    blog('VoNR START latency: {} ms'.format(vonr_start_latency))

    vonr_stop_latency = get_delay_between_msgs(all_pdu_session_mod_req[0], all_pdu_session_mod_resp[0])
    blog('VoNR STOP latency: {} ms'.format(vonr_stop_latency))


def analyze_call_setup_and_release_latency_nsa(sctp_logs):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=sctp_logs,
                             tshark_filter='x2ap || s1ap || f1ap || ngap',
                             lua=None)

        sgnb_addition_req_matcher = PcapMessageMatcher('SgNBAdditionRequest', message_type_pattern='empty')
        sn_status_transfer_matcher = PcapMessageMatcher('SNStatusTransfer', message_type_pattern='empty')
        sgnb_release_req_matcher = PcapMessageMatcher('SgNBReleaseRequest', message_type_pattern='empty')
        ue_context_release_matcher = PcapMessageMatcher('UEContextReleaseComplete', message_type_pattern='empty')

        all_sgnb_addition_req = finder.find_all(sgnb_addition_req_matcher)
        all_sn_status_transfer = finder.find_all(sn_status_transfer_matcher)
        all_sgnb_release_req = finder.find_all(sgnb_release_req_matcher)
        all_ue_context_release = finder.find_all(ue_context_release_matcher)

    assert lists_are_non_empty(all_sgnb_addition_req, all_sn_status_transfer), \
        'Not all necessary messages for NSA L3 call setup could be found in SCTP logs.'

    assert lists_are_non_empty(all_sgnb_release_req, all_ue_context_release), \
        'Not all necessary messages for NSA L3 call release could be found in SCTP logs.'

    attach_latency = get_delay_between_msgs(all_sgnb_addition_req[0], all_sn_status_transfer[0])
    blog('Attach latency: {} ms'.format(attach_latency))

    detach_latency = get_delay_between_msgs(all_sgnb_release_req[0], all_ue_context_release[0])
    blog('Detach latency: {} ms'.format(detach_latency))


def analyze_call_setup_and_release_latency_sa(sctp_logs):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=sctp_logs,
                             tshark_filter='f1ap || ngap',
                             lua=None)

        rrc_setup_req = PcapMessageMatcher('InitialULRRCMessageTransfer', message_type_pattern='empty')
        initial_context_setup_resp = PcapMessageMatcher('InitialContextSetupResponse', message_type_pattern='empty')
        pdu_session_release = PcapMessageMatcher('PDUSessionResourceReleaseCommand', message_type_pattern='empty')
        ue_context_release_complete = PcapMessageMatcher('UEContextReleaseComplete', message_type_pattern='empty')

        all_rrc_setup_req = finder.find_all(rrc_setup_req)
        all_initial_context_setup_resp = finder.find_all(initial_context_setup_resp)
        all_pdu_session_release = finder.find_all(pdu_session_release)
        all_ue_context_release_complete = finder.find_all(ue_context_release_complete)

    assert lists_are_non_empty(all_rrc_setup_req, all_initial_context_setup_resp), \
        'Not all necessary messages for SA L3 call setup could be found in SCTP logs.'

    assert lists_are_non_empty(all_pdu_session_release, all_ue_context_release_complete), \
        'Not all necessary messages for SA L3 call release could be found in SCTP logs.'

    attach_latency = get_delay_between_msgs(all_rrc_setup_req[0], all_initial_context_setup_resp[0])
    blog('Attach latency: {} ms'.format(attach_latency))

    detach_latency = get_delay_between_msgs(all_pdu_session_release[0], all_ue_context_release_complete[0])
    blog('Detach latency: {} ms'.format(detach_latency))


def analyze_ho_with_vonr_interruption_time(sctp_logs):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=sctp_logs,
                             tshark_filter='f1ap || ngap || e1ap',
                             lua=None)

        ul_rrc_message_transfer = PcapMessageMatcher('ULRRCMessageTransfer', message_type_pattern='empty')
        bearer_context_mod_resp = PcapMessageMatcher('BearerContextModificationResponse', message_type_pattern='empty')
        dl_rrc_message_transfer = PcapMessageMatcher('DLRRCMessageTransfer', message_type_pattern='empty')
        ue_context_mod_resp = PcapMessageMatcher('UEContextModificationResponse', message_type_pattern='empty')

        all_ul_rrc_message = finder.find_all(ul_rrc_message_transfer)
        all_bearer_context = finder.find_all(bearer_context_mod_resp)
        all_dl_rrc_message = finder.find_all(dl_rrc_message_transfer)
        all_ue_context_mod_resp = finder.find_all(ue_context_mod_resp)

    assert lists_are_non_empty(all_ul_rrc_message, all_bearer_context, all_dl_rrc_message, all_ue_context_mod_resp), \
        'Not all necessary messages for HO interruption could be found in SCTP logs.'

    ho_latency_time = get_delay_between_msgs(all_ul_rrc_message[0], all_ul_rrc_message[1])
    actual_ho_time = get_delay_between_msgs(all_dl_rrc_message[0], all_ul_rrc_message[1])
    time_from_start_to_last_msg = get_delay_between_msgs(all_ul_rrc_message[0], all_ue_context_mod_resp[-1])
    ho_interruption_time = get_delay_between_msgs(all_ul_rrc_message[0], all_bearer_context[-1])

    blog('Handover procedure latency time: {} ms'.format(ho_latency_time))
    blog('Handover procedure interruption time: {} ms'.format(ho_interruption_time))
    blog('Actual handover time (without accompanying operations): {} ms'.format(actual_ho_time))
    blog('time_from_start_to_last_msg: {} ms'.format(time_from_start_to_last_msg))


def get_delay_between_msgs(msg0, msg1):
    start_str = extract_arrival_time_from_msg(msg0)
    end_str = extract_arrival_time_from_msg(msg1)
    return calculate_time_diff(start_str, end_str)


def extract_arrival_time_from_msg(msg):
    arrival_time = msg.find('Arrival Time', engine='re').first()['val']
    return arrival_time.split(',')[1].strip().split(' ')[1]


def calculate_time_diff(start_str, end_str):
    start_timestamp = datetime.strptime(start_str.rstrip('0'), TIME_FORMAT)
    end_timestamp = datetime.strptime(end_str.rstrip('0'), TIME_FORMAT)
    return (end_timestamp - start_timestamp).total_seconds() * 1000


def lists_are_non_empty(*lists):
    return all(lst for lst in lists)
