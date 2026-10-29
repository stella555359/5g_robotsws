from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm


def _find_all_messages(finder, messages_to_find):
    found_msgs = finder.find_all(messages_to_find, forget_matcher_on_hit=True)
    blog('messages_to_find:')
    msgs_to_find = [m.tag for m in messages_to_find]
    blog(msgs_to_find)
    missing_msgs = set(msgs_to_find) - set(found_msgs.keys())
    assert len(found_msgs) == len(messages_to_find), \
        "At least one message is missing! Missing messages: {}".format(','.join(missing_msgs))
    return found_msgs


def _messages_are_not_expected(finder, messages_to_find):
    found_msgs = finder.find_all(messages_to_find, forget_matcher_on_hit=True)
    assert not found_msgs, 'Messages are not expected: {}'.format(found_msgs.keys())


def _common_finder(pcap_file, filter=None):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter=filter,
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    return finder


def ul_transfer(pcap_file):
    finder = _common_finder(pcap_file, 'f1ap')
    expected_messages = [pm('MAC*', name_line_pattern='empty')
                         .containing('ULRRCMessageTransfer')
                         .containing('GNB-CU*')]
    return _find_all_messages(finder, expected_messages)


def mimo_layers(pcap_file, layers):
    finder = _common_finder(pcap_file, 'f1ap')
    expected_messages = [pm('UEContextModificationResponse', name_line_pattern='empty')
                         .containing('maxNumberMIMO-LayersPDSCH*{}*'.format(layers))]
    return _find_all_messages(finder, expected_messages)


def _ngap_finder(pcap_file):
    return _common_finder(pcap_file, filter='ngap')


def _expect_messages_with_occurrence(finder, messages, occurrence):
    for msg in messages:
        found_msgs = finder.find_exactly(int(occurrence), msg)
        blog(found_msgs)


def assert_vonr_call_started_with_qos_1(pcap_file, occurrence, qos='1'):
    qos1_start = [
        pm('PDUSessionResourceModifyRequest*', name_line_pattern='empty', tag='VonrStartReq')
        .containing('QosFlowAddOrModifyRequestList*')
        .containing('qosFlowIdentifier*', qos),

        pm('PDUSessionResourceModifyResponse*', name_line_pattern='empty', tag='VonrStartResp')
        .containing('QosFlowAddOrModifyResponseItem*')
        .containing('qosFlowIdentifier*', qos)
    ]
    qos1_end = [
        pm('PDUSessionResourceModifyRequest*', name_line_pattern='empty', tag='VonrEndReq')
        .containing('QosFlowWithCauseItem*')
        .containing('qosFlowIdentifier*', qos),

        pm('PDUSessionResourceModifyResponse*', name_line_pattern='empty', tag='VonrEndResp')
        .containing('PDUSessionResourceModifyListModRes*')
        .containing('PDUSessionResourceModifyResponseTransfer*')
        .not_containing('qosFlowAddOrModifyResponseList*')
    ]
    finder = _ngap_finder(pcap_file)
    return _expect_messages_with_occurrence(finder, qos1_start + qos1_end, occurrence=occurrence)


def assert_both_pdu_session_established(pcap_file):
    qos5_9 = [
        pm('InitialContextSetupResponse', name_line_pattern='empty')
        .containing('PDUSessionResourceSetupResponseTransfer')
        .containing('qosFlowIdentifier*', '5'),
        pm('PDUSessionResourceSetupResponse', name_line_pattern='empty')
        .containing('qosFlowIdentifier*', '9')
    ]
    finder = _common_finder(pcap_file)
    return _find_all_messages(finder, qos5_9)
