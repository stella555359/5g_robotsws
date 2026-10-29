"""
:copyright: Nokia Networks
:author: Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
:maintainer: Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
"""

from ta_messaging.message_flows import get_flow
from ute_common_abstract_core.message import NotFoundKey
import pprint


def verify_if_amf_id_changed(flow_alias, message_alias):
    UEContextModificationRequest_msg = get_flow(flow_alias).get_message(message_alias)

    try:
        AMFids = UEContextModificationRequest_msg.get_all_values_by_key('AMF-UE-NGAP-ID')

    except NotFoundKey:
        raise NotFoundKey('AMF-UE-NGAP-IDs in UEContextModificationRequest are invalid')

    pprint.pprint('Old AMF Id: {}'.format(AMFids[0]))
    pprint.pprint('New AMF Id: {}'.format(AMFids[1]))

    assert AMFids[0] != AMFids[1], 'AMF IDs values are the same for both AMFs, no AMF update!'
