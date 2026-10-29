"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>
"""

import logging
from ta_messaging.message_verifiers import message_verifier
from ta_messaging.message_flows import get_flow
from ute_common_abstract_core.message import NotFoundKey


ue_tnla_brr = None


class UETNLABindingReleaseRequest:
    def __init__(self, amf_id, ran_id):
        self.amf_ue_ngap_id = amf_id
        self.ran_ue_ngap_id = ran_id
        self.msg_hex = ''
        self.logger = logging.getLogger('messaging.flows.logic')

    def print_ids(self):
        ids_str = 'AMF-UE-NGAP-ID: {}, RAN-UE-NGAP-ID: {}'.format(self.amf_ue_ngap_id, self.ran_ue_ngap_id)
        self.logger.debug(ids_str)


# NGAP_InitialContextSetupResponse
@message_verifier
def get_amf_and_ran_ue_ngap_id(msg):
    global ue_tnla_brr
    amf_id = msg.get_value_by_unique_key('AMF-UE-NGAP-ID')
    ran_id = msg.get_value_by_unique_key('RAN-UE-NGAP-ID')
    ue_tnla_brr = UETNLABindingReleaseRequest(amf_id, ran_id)
    ue_tnla_brr.print_ids()
    return True


@message_verifier
def verify_new_amf_ue_ngap_id_is_present(msg):
    double_amf_id = msg.get_all_values_by_key('AMF-UE-NGAP-ID')
    if len(double_amf_id) == 2:
        return True
    else:
        return False
