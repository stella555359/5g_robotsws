import pprint
import ta_pdml_parser
from ta_messaging.message_flows import get_flow
from ute_common_abstract_core.message import NotFoundKey


def get_hex_from_message(flow_alias, message_alias, container, direction='sourceToTarget'):
    possible_directions = {'sourceToTarget', 'targetToSource'}
    message = get_flow(flow_alias).get_message(message_alias)
    print('message:\n{}'.format(pprint.pformat(message)))
    try:
        hex_container = message.get_all_values_by_key(container)
    except NotFoundKey:
        raise NotFoundKey('HEX container not found')

    if direction not in possible_directions:
        raise ValueError('parse_ngap_hex_container: direction must be one of {}'.format(possible_directions))

    if direction != 'sourceToTarget':
        hex_container = hex_container[0].get_value_by_unique_key('rRCContainer')

    print('Returned HEX string:\n{}'.format(pprint.pformat(hex_container)))

    return hex_container


def parse_ngap_hex_container(flow_alias, message_alias, container, direction='sourceToTarget'):
    if direction == 'sourceToTarget':
        transparent_container = 'SourceNGRANNode-ToTargetNGRANNode-TransparentContainer'
        hex_container = get_hex_from_message(flow_alias, message_alias, container, direction)
        parsed_ngap_hex_container = ta_pdml_parser.interface.parse_ngap_container(transparent_container,
                                                                                  str(hex_container[0]))
    else:
        transparent_container = 'HandoverCommand'
        hex_container = get_hex_from_message(flow_alias, message_alias, container, direction)
        parsed_ngap_hex_container = ta_pdml_parser.interface.parse_rrc5g_container(transparent_container, hex_container)

    print('parsed hex container:\n{}'.format(pprint.pformat(parsed_ngap_hex_container)))

    return parsed_ngap_hex_container


def verify_dlforwarding_field_inside_hex_container(flow_alias, message_alias, container, value, occurences=1):
    dl_forwarding = 'dLForwarding'
    parsed_ngap_container = parse_ngap_hex_container(flow_alias, message_alias, container)
    dl_forwarding_field_list = parsed_ngap_container.get_all_values_by_key(dl_forwarding)

    assert dl_forwarding_field_list[0] == value and \
           dl_forwarding_field_list.count(dl_forwarding_field_list[0]) == occurences, \
           'Wrong value or number of dLForwarding in {}'.format(container)


def verify_number_of_elements_in_drbstoqosflowsmappinglist_field_inside_hex_container(flow_alias, message_alias,
                                                                                      container, elements):
    drbs_to_qos_flows_mapping_list = 'dRBsToQosFlowsMappingList'
    parsed_ngap_container = parse_ngap_hex_container(flow_alias, message_alias, container)
    drbs_to_qos_flows_mapping_field_list = parsed_ngap_container.get_all_values_by_key(drbs_to_qos_flows_mapping_list)

    assert len(drbs_to_qos_flows_mapping_field_list[0]) == int(elements), \
        'Wrong number of dRBsToQosFlowsMappingList in {}'.format(container)


def verify_number_of_elements_in_mappedqosflowstoadd_field_inside_hex_container(flow_alias, message_alias,
                                                                                container, elements):
    mapped_qos_flows = 'mappedQoS-FlowsToAdd'
    parsed_nrrrc_container = parse_ngap_hex_container(flow_alias, message_alias, container, direction='targetToSource')
    mapped_qos_flows_to_add = parsed_nrrrc_container.get_all_values_by_key(mapped_qos_flows)

    assert len(mapped_qos_flows_to_add) == int(elements), \
        'Wrong number of mappedQoSFlowsToAdd in {}'.format(container)
