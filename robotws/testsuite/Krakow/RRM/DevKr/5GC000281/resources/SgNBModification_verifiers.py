"""
:copyright: Nokia Networks
:author: Michal Szymakowski <michal.szymakowski@nokia.com>
:maintainer: Michal Szymakowski <michal.szymakowski@nokia.com>
"""
from ta_messaging.message_flows import get_flow
from ute_common_abstract_core.message import NotFoundKey


def verify_security_key_change(flow_alias_first, message_alias_first, flow_alias_second, message_alias_second):
    sgnb_modification_request_first = get_flow(flow_alias_first).get_message(message_alias_first)
    sgnb_modification_request_second = get_flow(flow_alias_second).get_message(message_alias_second)

    try:
        unique_key_first = sgnb_modification_request_first.get_all_values_by_key('SgNBSecurityKey')
        unique_key_second = sgnb_modification_request_second.get_all_values_by_key('sgNB-SecurityKey')
    except NotFoundKey:
        raise NotFoundKey('problem with fields in message')

    assert unique_key_first != unique_key_second, 'security key value for UE remains the same'
