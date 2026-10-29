from robot.libraries.BuiltIn import BuiltIn
from ta_messaging.message_flows import get_flow
from ta_pdml_parser import parse_rrc5g_container


class CB006733(object):
    def __init__(self):
        super(CB006733, self).__init__()

    def parse_measConfig_and_check_contents(self, measConfig_hex, expected_structure):
        BuiltIn().log('{}- equals to {} '.format('measConfig HEX IE', str(measConfig_hex)))
        measConfig_IE = parse_rrc5g_container('MeasConfig', measConfig_hex)
        BuiltIn().log('{}- equals to {} '.format('MeasConfig', measConfig_IE))
        self._parse_container(measConfig_IE, expected_structure)

    def _parse_container(self, measConfig_IE, expected_structure):
        char_to_replace = {" ": "", "\r": "", "\n": "", "\'": ""}
        parsed_string = str(measConfig_IE)
        for key, value in char_to_replace.items():
            parsed_string = parsed_string.replace(key, value)
            expected_structure = expected_structure.replace(key, value)
        BuiltIn().log('{}- equals to {} '.format('parsed_string', parsed_string))
        BuiltIn().log('{}- equals to {} '.format('ue_context_modification_string_filter', expected_structure))
        assert expected_structure in parsed_string

    def verify_if_measConfig_contains(self, flow_alias, message_alias, expected_structure):
        msg_f1ap = get_flow(flow_alias).get_message(message_alias)
        measConfig_hex = msg_f1ap.get_value_by_unique_key('measConfig')
        self.parse_measConfig_and_check_contents(measConfig_hex, expected_structure)

    def verify_if_information_element_contains(self, ie_element, flow_alias, message_alias, expected_structure):
        msg_cap = get_flow(flow_alias).get_message(message_alias)
        information_element_hex = msg_cap.get_value_by_unique_key(ie_element)
        BuiltIn().log('{}- equals to {} '.format(ie_element + ' HEX IE', str(information_element_hex)))
        assert expected_structure in str(information_element_hex)

    def verify_if_measConfig_contains_when_key_not_unique_inside_container(self, flow_alias, message_alias,
                                                                           expected_structure, occurrence_position):
        msg_f1ap = get_flow(flow_alias).get_message(message_alias)
        measConfig_hex = msg_f1ap.get_all_values_by_key('measConfig')[int(occurrence_position)]
        self.parse_measConfig_and_check_contents(measConfig_hex, expected_structure)
