from ta_pcmd import ta_pcmd, pcmd_verifier
from ute_common_abstract_core.message import Message
from verifier_msg_for_pcmd import verifier_msg_for_pcmd, save_pcmd_selected_value
from robot.libraries.BuiltIn import BuiltIn


def dummy_import(na, name):
    inst = ta_pcmd()
    inst._is_asndecoding_enabled = lambda: True
    return inst


BuiltIn.get_library_instance = dummy_import


class test_get_verify_msg_for_pcmd(object):
    example_msg = {
        'F1AP-PDU': {
            'initiatingMessage': {
                'criticality': 'ignore',
                'procedureCode': 13,
                'value': {
                    'ULRRCMessageTransfer': {
                        'protocolIEs': [{'criticality': 'reject',
                                         'id': 40,
                                         'value': {
                                             'GNB-CU-UE-F1AP-ID': 0}},
                                        {'criticality': 'reject',
                                         'id': 41,
                                         'value': {
                                             'GNB-DU-UE-F1AP-ID': 1}},
                                        {'criticality': 'reject',
                                         'id': 64,
                                         'value': {'SRBID': 1}},
                                        {'criticality': 'reject',
                                         'id': 50,
                                         'value': {
                                             'RRCContainer':
                                                 '0x0000100005DF80105C40034044E46100000000081855013C0B80A4240000000000'
                                         }}]}}}}}

    message1 = Message(example_msg, {})
    message1.type = 'ULRRCMessageTransfer'
    pcmd_verifier_instance = verifier_msg_for_pcmd()
    save_pcmd_selected_value(message1)
    assert pcmd_verifier_instance.message_values == {
        'ULRRCMessageTransfer': {'GNB-CU-UE-F1AP-ID': [0], 'GNB-DU-UE-F1AP-ID': [1]}}
    pcmd_verifier_instance.set_variable_from_message_for_record_yaml('./test_yaml.yaml')
    assert pcmd_verifier.YAML_VARS_PER_YAML == {
        './test_yaml.yaml': {'${gnb_cu_f1ap_id}': {'default': '0'}, '${gnb_du_f1ap_id}': {'default': '1'}}}
