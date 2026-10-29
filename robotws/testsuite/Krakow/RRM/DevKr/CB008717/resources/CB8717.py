from robot.libraries.BuiltIn import BuiltIn
from ta_messaging.message_flows import get_flow
from ta_pdml_parser import parse_rrc5g_container
from ta_pdml_parser import parse_f1ap_container
from ta_pdml_parser.message import NotFoundKey
from ta_pdml_parser import parse_ngap_container
import pprint


class CB8717(object):
    def __init__(self):
        super(CB8717, self).__init__()

    def verify_if_UERadioCapability_from_two_messages_is_the_same(self, message_source, flow_source,
                                                                  message_to_verify, flow_to_verify):
        msg_content_nr_rrc = get_flow(flow_source).get_message(message_source)
        msg_content_ngap = get_flow(flow_to_verify).get_message(message_to_verify)
        ue_cap_nr_rrc = msg_content_nr_rrc.get_value_by_unique_key('ue-CapabilityRAT-Container')
        ue_cap_ngap = msg_content_ngap.get_value_by_unique_key('ue-CapabilityRAT-Container')
        assert ue_cap_nr_rrc == ue_cap_ngap, \
            'UECap from NR_RRC: {} does not match with UECap forwarded to AMF: {}'.format(ue_cap_nr_rrc, ue_cap_ngap)

    def verify_if_measConfig_contains(self, flow_alias, message_alias, field, value):
        msg_f1ap = get_flow(flow_alias).get_message(message_alias)
        measConfig_hex = msg_f1ap.get_all_values_by_key('measConfig')
        measConfig_hex = measConfig_hex[0]
        BuiltIn().log('{}- equals to {} '.format('measConfig HEX IE', str(measConfig_hex)))
        measConfig_IE = parse_rrc5g_container('MeasConfig', measConfig_hex)
        BuiltIn().log('{}- equals to {} '.format('MeasConfig', measConfig_IE))

        if value == 'is present':
            measConfig_IE.get_all_values_by_key(field)
        elif value == 'is not present':
            try:
                measConfig_IE.get_value_by_unique_key(field)
            except NotFoundKey as e:
                BuiltIn().log(e)
                assert True
            else:
                assert False
        else:
            msg_content = str(measConfig_IE.get_value_by_unique_key(field))
            BuiltIn().log('{}- equals to {} '.format(field, msg_content))
            assert msg_content == str(value)

    def verify_length_of_IE_in_measConfig(self, flow_alias, message_alias, field, length):
        msg_f1ap = get_flow(flow_alias).get_message(message_alias)
        measConfig_hex = msg_f1ap.get_all_values_by_key('measConfig')
        measConfig_hex = measConfig_hex[0]
        BuiltIn().log('{}- equals to {} '.format('measConfig HEX IE', str(measConfig_hex)))
        measConfig_IE = parse_rrc5g_container('MeasConfig', measConfig_hex)
        BuiltIn().log('{}- equals to {} '.format('MeasConfig', measConfig_IE))

        msg_content = measConfig_IE.get_value_by_unique_key(field)
        BuiltIn().log('{}- equals to {} '.format(field, msg_content))
        assert len(msg_content) == int(length)

    def verify_indexToRfsp_presence_in_handoverRequest(self, flow_alias, message_alias, container, value):
        index_to_rfsp = 'indexToRFSP'
        source_to_target_container = 'SourceNGRANNode-ToTargetNGRANNode-TransparentContainer'
        message = get_flow(flow_alias).get_message(message_alias)
        try:
            hex_container = message.get_all_values_by_key(container)
        except NotFoundKey:
            raise NotFoundKey('HEX container not found')
        pprint.pprint(hex_container)
        parsed_ngap_hex_container = parse_ngap_container(source_to_target_container, str(hex_container[0]))
        pprint.pprint(parsed_ngap_hex_container)
        index_to_rfsp_field_list = parsed_ngap_hex_container.get_all_values_by_key(index_to_rfsp)
        pprint.pprint(index_to_rfsp_field_list)
        pprint.pprint(index_to_rfsp_field_list[0])
        pprint.pprint(value)

        assert str((index_to_rfsp_field_list)[0]) == str(value), 'Wrong value indexToRFSP: {}'.format(value)
