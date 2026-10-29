from robot.libraries.BuiltIn import BuiltIn
import pytest
from ta_messaging.message_flows import get_flow
from ta_pdml_parser.interface import parse_rrc5g_container
import re

log = BuiltIn().log


class UnparsedContainers(object):

    def _get_hex_from_message(self, flow_alias, message_alias, key):
        msg = get_flow(flow_alias).get_message(message_alias)
        hex_value = msg.get_value_by_unique_key(key)
        re.sub('0x', '', hex_value)
        log('{}- equals to {} '.format('HEX IE:', str(hex_value)))
        return hex_value

    def verify_if_rrc5g_container_contains(self, flow_alias, message_alias, field, value,
                                           unparsed_container_key, IE_name):
        hex_value = self._get_hex_from_message(flow_alias, message_alias, unparsed_container_key)
        IE = parse_rrc5g_container(IE_name, hex_value)
        log('parsed IE: {} '.format(IE))
        if value == 'is present':
            IE.get_value_by_unique_key(field)
        else:
            msg_content = str(IE.get_value_by_unique_key(field))
            log('{}- equals to {} '.format(field, msg_content))
            assert msg_content == value

    def verify_if_rrc5g_container_contains_non_unique_value(self, flow_alias, message_alias, field, value,
                                                            unparsed_container_key, IE_name, index_of_value):
        index_of_value = int(index_of_value)
        value = int(value)
        hex_value = self._get_hex_from_message(flow_alias, message_alias, unparsed_container_key)
        IE = parse_rrc5g_container(IE_name, hex_value)
        log('parsed IE: {} '.format(IE))
        list_of_values = IE.get_all_values_by_key(field)
        log('List of values- {} '.format(list_of_values))
        if index_of_value is None:
            assert value in list_of_values
        else:
            assert value == list_of_values[index_of_value]

    def verify_if_rrc5g_container_doesnt_contain_field(self, flow_alias, message_alias, field,
                                                       unparsed_container_key, IE_name):
        hex_value = self._get_hex_from_message(flow_alias, message_alias, unparsed_container_key)
        IE = parse_rrc5g_container(IE_name, hex_value)
        log('parsed IE: {} '.format(IE))
        with pytest.raises(Exception):
            IE.get_all_values_by_key(field)

    def verify_multiple_values_of_field_in_rrc5g_container(self, flow_alias, message_alias, field,
                                                           list_to_compare, unparsed_container_key, IE_name):
        list_to_compare = list(map(int, list_to_compare))
        hex = self._get_hex_from_message(flow_alias, message_alias, key=unparsed_container_key)
        IE = parse_rrc5g_container(IE_name, hex)
        log('Parsed IE equals to {} '.format(IE))
        list_of_values = IE.get_all_values_by_key(field)
        log('List of values- {} '.format(list_of_values))
        assert list_of_values == list_to_compare

    def verify_that_field_is_present_x_times_in_rrc5g_container(self, flow_alias, message_alias, field,
                                                                expected_occurrences, unparsed_container_key, IE_name):
        hex = self._get_hex_from_message(flow_alias, message_alias, key=unparsed_container_key)
        IE = parse_rrc5g_container(IE_name, hex)
        log('Parsed IE equals to {} '.format(IE))
        list_of_values = IE.get_all_values_by_key(field)
        log('Occurences of {} = {} '.format(field, len(list_of_values)))
        assert len(list_of_values) == int(expected_occurrences)

    def verify_that_field_is_not_present_x_times_in_rrc5g_field(self, flow_alias, message_alias, field,
                                                                expected_occurrences, unparsed_container_key, IE_name):
        hex = self._get_hex_from_message(flow_alias, message_alias, key=unparsed_container_key)
        IE = parse_rrc5g_container(IE_name, hex)
        log('Parsed IE Not present to {} '.format(IE))
        list_of_values = IE.get_all_values_by_key(field)
        log('Occurences of {} = {} '.format(field, len(list_of_values)))
        assert len(list_of_values) != int(expected_occurrences)
