"""
:copyright: Nokia Networks
:author: Dawid Krawczuk <dawid.krawczuk@nokia.com>, Michal Szymakowski <michal.szymakowski@nokia.com>
:maintainer: Dawid Krawczuk <dawid.krawczuk@nokia.com>, Michal Szymakowski <michal.szymakowski@nokia.com>
"""

from ta_messaging.message_flows import get_flow
from ute_common_abstract_core.message import NotFoundKey
import pprint


def get_amf_guami(flow_alias, message_alias):
    initialContextSetupRequest_msg = get_flow(flow_alias).get_message(message_alias)

    try:
        guamiPlmn = initialContextSetupRequest_msg.get_all_values_by_key('pLMNIdentity')
        guamiAmfRegion = initialContextSetupRequest_msg.get_all_values_by_key('aMFRegionID')
        guamiAmfSet = initialContextSetupRequest_msg.get_all_values_by_key('aMFSetID')
        guamiAmfPointer = initialContextSetupRequest_msg.get_all_values_by_key('aMFPointer')

    except NotFoundKey:
        raise NotFoundKey('GUAMI in InitialContextSetupMessage is invalid')

    guami = {'amfPlmn': guamiPlmn,
             'amfRegion': guamiAmfRegion,
             'amfSet': guamiAmfSet,
             'amfPointer': guamiAmfPointer}

    pprint.pprint('GUAMI: {}'.format(guami))
    return guami


def verify_difference_of_two_amf_guami(flow_alias_amf1, flow_alias_amf2, msg_alias_amf1, msg_alias_amf2):
    guami_amf1 = get_amf_guami(flow_alias=flow_alias_amf1, message_alias=msg_alias_amf1)
    guami_amf2 = get_amf_guami(flow_alias=flow_alias_amf2, message_alias=msg_alias_amf2)

    assert guami_amf1 != guami_amf2, 'GUAMI values are the same for both AMFs'
