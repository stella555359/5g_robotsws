from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import get_all_frames
from testsuite.Wroclaw.RRM.resources.pcap_verification.message_to_tree import message_to_tree
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword


@logged_keyword
def validate_attach_with_x2s1_logs(pcap_file, num_of_ues=1):
    """Validate attach procedure for NSA configuration"""
    number_of_msgs_to_check = 4
    check_list = [0] * number_of_msgs_to_check

    all_frames = get_all_frames(pcap_file, True, 'x2ap || s1ap')
    for frame in all_frames:
        tree = message_to_tree(frame)
        s1ap_initial_ue_message = find_field_in_frame_if_exists('ENB-UE-S1AP-ID*', 'InitialUEMessage', tree)
        s1ap_context_setup_resp = find_field_in_frame_if_exists('ENB-UE-S1AP-ID*', 'InitialContextSetupResponse', tree)
        x2ap_SgNBAdditionReq = find_field_in_frame_if_exists('UE-X2AP-ID*', 'SgNBAdditionRequest', tree)
        x2ap_SgNBReconfig_complete = find_field_in_frame_if_exists('UE-X2AP-ID*', 'SgNBReconfigurationComplete', tree)

        if s1ap_initial_ue_message:
            check_list[0] += 1
        if s1ap_context_setup_resp:
            check_list[1] += 1
        if x2ap_SgNBAdditionReq:
            check_list[2] += 1
        if x2ap_SgNBReconfig_complete:
            check_list[3] += 1
    assert all(i == num_of_ues for i in check_list), blog(
        'Wrong number of UEs found. Expected: {}. Found: {}'.format(num_of_ues, check_list[3]))


@logged_keyword
def validate_attach_with_ngap_logs(pcap_file, num_of_ues=1):
    """Validate attach procedure for SA configuration"""
    number_of_msgs_to_check = 2
    check_list = [0] * number_of_msgs_to_check

    all_frames = get_all_frames(pcap_file, True, 'ngap')
    for frame in all_frames:
        tree = message_to_tree(frame)
        initial_ue_message = find_field_in_frame_if_exists('RAN-UE-NGAP-ID*', 'InitialUEMessage', tree)
        context_setup_resp = find_field_in_frame_if_exists('RAN-UE-NGAP-ID*', 'InitialContextSetupResponse', tree)

        if initial_ue_message:
            check_list[0] += 1
        if context_setup_resp:
            check_list[1] += 1

    assert all(i == num_of_ues for i in check_list), blog(
        'Wrong number of UEs found. Expected: {}. Found: {}'.format(num_of_ues, check_list[1]))


def find_exactly_x_attached_rntis(sctp_logs, x):
    rntis = get_attached_rntis(sctp_logs)
    assert len(rntis) == int(x), 'Unexpected number of attached RNTIS found in SCTP logs. ' \
                                 'Expected: {}. Found: {}'.format(int(x), len(rntis))
    return rntis


@logged_keyword
def get_attached_rntis(sctp_logs):
    blog('Start RNTI extraction from F1AP logs...')
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=sctp_logs, lua=None, tshark_filter='f1ap')
        msgs = finder.find_all(PcapMessageMatcher('UEContextSetupResponse', message_type_pattern='empty'))
        attached_rntis = [str(ue.find('C-RNTI*').first()['val']) for ue in msgs]

        blog('RNTI extraction finished. Attached RNTI: ' + str(attached_rntis))
        return attached_rntis


def find_field_in_frame_if_exists(parameter, path, tree):
    found_parameter = tree.find(parameter).filter(path)
    if found_parameter:
        return found_parameter.first()['val']
    return None
