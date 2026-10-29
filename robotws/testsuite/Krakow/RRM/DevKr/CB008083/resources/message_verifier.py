from ta_messaging.message_flows import get_flow
from ta_messaging.user_message_subscriber import get_messages_from_subscriber as _get_messages_from_subscriber
from ta_messaging.user_message_subscriber import get_alias_of_owner_from_unparsed_message\
    as _get_alias_of_owner_from_unparsed_message
from robot.libraries.BuiltIn import BuiltIn
from ute_common_abstract_core.message import NotFoundKey
import pprint


def verify_mandatory_fields_in_message(flow_alias, message_alias):
    possible_ngap_messages = {'NGSetupRequest', 'NGSetupResponse'}
    ng_setup_request_mandatory_fileds = {'GlobalRANNodeID', 'SupportedTAList', 'PagingDRX'}
    ng_setup_response_mandatory_fileds = {'AMFName', 'ServedGUAMIList', 'RelativeAMFCapacity', 'PLMNSupportList'}
    field_list = []

    message = get_flow(flow_alias).get_message(message_alias)
    print('message: ', message)

    if message_alias not in possible_ngap_messages:
        raise ValueError('Error: message_alias must be one of {}'.format(possible_ngap_messages))

    try:
        if message_alias == 'NGSetupRequest':
            for field in ng_setup_request_mandatory_fileds:
                field_list.append(message.get_all_values_by_key(field))

        if message_alias == 'NGSetupResponse':
            for field in ng_setup_response_mandatory_fileds:
                field_list.append(message.get_all_values_by_key(field))

    except NotFoundKey:
        raise NotFoundKey('Mandatory field {} is not present in {} message'.format(field_list, message_alias))


def check_that_message_owner_is_matching_expected_owner(message_type, expected_owner, list_of_results=None):
    messages = _get_messages_from_subscriber(message_type)
    assert len(messages) == 1, 'Expected 1 messages, got: {}'.format(len(messages))
    owner_alias = _get_alias_of_owner_from_unparsed_message(messages[0])
    if list_of_results is not None:
        list_of_results.append(owner_alias)
    assert str(owner_alias) == str(expected_owner), 'Expected owner: {}, got: {}'.format(expected_owner, owner_alias)
