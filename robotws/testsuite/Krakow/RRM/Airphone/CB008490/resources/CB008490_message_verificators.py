"""
:copyright: Nokia Networks
:author: Michal Szymakowski <michal.szymakowski@nokia.com>
:maintainer: Michal Szymakowski <michal.szymakowski@nokia.com>
"""

import logging
import pprint
from ta_messaging.message_flows import get_flow

logger = logging.getLogger('messaging.flows.logic')


def compare_field_between_two_messages(msg1, msg1_flow, msg2, msg2_flow, field):
    supported_messages = ['SNodeReleaseRequest',
                          'SNodeReleaseRequestAcknowledge',
                          'SNodeAdditionRequestAcknowledge',
                          'BearerContextModificationRequest',
                          'BearerContextModificationResponse',
                          'UEContextRelease',
                          'UECapabilityInformation',
                          'UERadioCapabilityInfoIndication']

    supported_fields_to_compare = ['id-M-NG-RANnodeUEXnAPID',
                                   'id-S-NG-RANnodeUEXnAPID',
                                   'dRB-ID',
                                   'pduSessionID',
                                   'ue-CapabilityRAT-Container']

    if msg1 not in supported_messages or msg2 not in supported_messages:
        logger.error(f"Comparing not supported messages. Choose from {supported_messages}")
        raise Exception("Not recognized messages to compare. Choose between:{}".format(supported_messages))

    if field not in supported_fields_to_compare:
        logger.info(f'field check not supported')
        raise Exception("Not recognized fields to compare. Choose between:{}".format(supported_fields_to_compare))

    if (msg1 == 'SNodeReleaseRequest' and msg2 == 'SNodeAdditionRequestAcknowledge') \
            or (msg1 == 'SNodeAdditionRequestAcknowledge' and msg2 == 'SNodeReleaseRequest'):
        logger.info(f"Comparing SNodeReleaseRequest with SNodeAdditionRequestAcknowledge")

        if field == 'id-M-NG-RANnodeUEXnAPID':
            id_M_NG_RANnodeUEXnAPID_first = get_idMNGRANnodeUEXnAPID_from_message(msg1_flow, msg1)
            id_M_NG_RANnodeUEXnAPID_second = get_idMNGRANnodeUEXnAPID_from_message(msg2_flow, msg2)
            assert id_M_NG_RANnodeUEXnAPID_first == id_M_NG_RANnodeUEXnAPID_second, \
                'Wrong {} field between {} and {} messages'.format(field, msg1, msg2)

        if field == 'id-S-NG-RANnodeUEXnAPID':
            id_S_NG_RANnodeUEXnAPID_first = get_idSNGRANnodeUEXnAPID_from_message(msg1_flow, msg1)
            id_S_NG_RANnodeUEXnAPID_second = get_idSNGRANnodeUEXnAPID_from_message(msg2_flow, msg2)
            assert id_S_NG_RANnodeUEXnAPID_first == id_S_NG_RANnodeUEXnAPID_second, \
                'Wrong {} field between {} and {} messages'.format(field, msg1, msg2)

        if field == 'pduSessionID':
            pduSessionId_first = get_pduSessionId_from_message(msg1_flow, msg1)
            pduSessionId_second = get_pduSessionId_from_message(msg2_flow, msg2)
            assert pduSessionId_first == pduSessionId_second, \
                'Wrong {} field between {} and {} messages'.format(field, msg1, msg2)

    if (msg1 == 'SNodeReleaseRequest' and msg2 == 'UEContextRelease'):
        logger.info(f"Comparing SNodeReleaseRequest with UEContextRelease")

        if field == 'id-M-NG-RANnodeUEXnAPID':
            id_M_NG_RANnodeUEXnAPID_first = get_idMNGRANnodeUEXnAPID_from_message(msg1_flow, msg1)
            id_M_NG_RANnodeUEXnAPID_second = get_idMNGRANnodeUEXnAPID_from_ue_context_release_message(msg2_flow, msg2)
            assert id_M_NG_RANnodeUEXnAPID_first == id_M_NG_RANnodeUEXnAPID_second, \
                'Wrong {} field between {} and {} messages'.format(field, msg1, msg2)

        if field == 'id-S-NG-RANnodeUEXnAPID':
            id_S_NG_RANnodeUEXnAPID_first = get_idSNGRANnodeUEXnAPID_from_message(msg1_flow, msg1)
            id_S_NG_RANnodeUEXnAPID_second = get_idSNGRANnodeUEXnAPID_from_ue_context_release_message(msg2_flow, msg2)
            assert id_S_NG_RANnodeUEXnAPID_first == id_S_NG_RANnodeUEXnAPID_second, \
                'Wrong {} field between {} and {} messages'.format(field, msg1, msg2)

    if msg1 == 'BearerContextModificationRequest' and msg2 == 'SNodeReleaseRequest':
        logger.info(f"Comparing SNodeReleaseRequest with BearerContextModificationRequest")
        if field == 'pduSessionID':
            pduSessionId_first = get_pduSessionId_from_e1ap_bearer_modification_message(msg1_flow, msg1)
            pduSessionId_second = get_pduSessionId_from_message(msg2_flow, msg2)
            assert pduSessionId_first == pduSessionId_second, \
                'Wrong {} field between {} and {} messages'.format(field, msg1, msg2)

    if (msg1 == 'BearerContextModificationRequest' and msg2 == 'BearerContextModificationResponse') \
            or (msg2 == 'BearerContextModificationRequest' and msg1 == 'BearerContextModificationResponse'):
        logger.info(f"Comparing BearerContextModificationRequest with BearerContextModificationResponse")

        if field == 'pduSessionID':
            pduSessionId_first = get_pduSessionId_from_e1ap_bearer_modification_message(msg1_flow, msg1)
            pduSessionId_second = get_pduSessionId_from_e1ap_bearer_modification_message(msg2_flow, msg2)
            assert pduSessionId_first == pduSessionId_second, \
                'Wrong {} field between {} and {} messages'.format(field, msg1, msg2)

        if field == 'dRB-ID':
            drbId_first = get_dRBID_from_message(msg1_flow, msg1)
            drbId_second = get_dRBID_from_message(msg2_flow, msg2)
            assert drbId_first == drbId_second, \
                'Wrong {} field between {} and {} messages'.format(field, msg1, msg2)

    if msg1 == 'UECapabilityInformation' and msg2 == 'UERadioCapabilityInfoIndication':
        logger.info(f"Comparing UECapabilityInformation with UERadioCapabilityInfoIndication")
        if field == 'ue-CapabilityRAT-Container':
            UECapabilityInformation = get_ue_capability_from_message(msg1_flow, msg1)
            UERadioCapabilityInfoIndication = get_ue_capability_from_message(msg2_flow, msg2)
            assert UECapabilityInformation == UERadioCapabilityInfoIndication, \
                'Wrong {} field between {} and {} messages'.format(field, msg1, msg2)


def get_idMNGRANnodeUEXnAPID_from_message(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    id_M_NG_RANnodeUEXnAPID_list = msg.get_all_values_by_key('NG-RANnodeUEXnAPID')
    id_M_NG_RANnodeUEXnAPID = id_M_NG_RANnodeUEXnAPID_list[0]
    return id_M_NG_RANnodeUEXnAPID


def get_idMNGRANnodeUEXnAPID_from_ue_context_release_message(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    id_M_NG_RANnodeUEXnAPID_list = msg.get_all_values_by_key('NG-RANnodeUEXnAPID')
    id_M_NG_RANnodeUEXnAPID = id_M_NG_RANnodeUEXnAPID_list[1]
    return id_M_NG_RANnodeUEXnAPID


def get_idSNGRANnodeUEXnAPID_from_message(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    id_S_NG_RANnodeUEXnAPID_list = msg.get_all_values_by_key('NG-RANnodeUEXnAPID')
    id_S_NG_RANnodeUEXnAPID = id_S_NG_RANnodeUEXnAPID_list[1]
    return id_S_NG_RANnodeUEXnAPID


def get_idSNGRANnodeUEXnAPID_from_ue_context_release_message(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    id_S_NG_RANnodeUEXnAPID_list = msg.get_all_values_by_key('NG-RANnodeUEXnAPID')
    id_S_NG_RANnodeUEXnAPID = id_S_NG_RANnodeUEXnAPID_list[0]
    return id_S_NG_RANnodeUEXnAPID


def get_dRBID_from_message(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    drb_id = msg.get_value_by_unique_key('dRB-ID')
    return drb_id


def get_pduSessionId_from_message(flow_alias, message_alias):
    supported_messages_to_compare = ['SNodeReleaseRequest',
                                     'SNodeReleaseRequestAcknowledge',
                                     'SNodeAdditionRequestAcknowledge']

    if message_alias not in supported_messages_to_compare:
        logger.error(f"Cannot get pduSessionId from this kind of message. Choose from {supported_messages_to_compare}")
        raise Exception

    if message_alias == 'SNodeReleaseRequest':
        msg = get_flow(flow_alias).get_message(message_alias)
        pduSessionId = msg.get_value_by_unique_key('PDUSession-List-withCause')[0]['pduSessionId']
    if message_alias == 'SNodeReleaseRequestAcknowledge':
        msg = get_flow(flow_alias).get_message(message_alias)
        pduSessionId = msg.get_value_by_unique_key('pduSessionsToBeReleasedList-SNterminated')[0]['pduSessionId']
    if message_alias == 'SNodeAdditionRequestAcknowledge':
        msg = get_flow(flow_alias).get_message(message_alias)
        pduSessionId = msg.get_value_by_unique_key('PDUSessionAdmittedAddedAddReqAck')[0]['pduSessionId']
    return pduSessionId


def get_pduSessionId_from_e1ap_bearer_modification_message(flow_alias, message_alias):
    supported_messages_to_compare = ['BearerContextModificationRequest',
                                     'BearerContextModificationResponse']

    if message_alias not in supported_messages_to_compare:
        logger.error(f"Cannot get pduSessionId from this kind of message. Choose from {supported_messages_to_compare}")
        raise Exception

    msg = get_flow(flow_alias).get_message(message_alias)
    pprint.pprint(msg)
    if message_alias == 'BearerContextModificationRequest':
        pduSessionId = msg.get_value_by_unique_key('PDU-Session-Resource-To-Modify-List')[0]['pDU-Session-ID']
    else:
        pduSessionId = msg.get_value_by_unique_key('PDU-Session-Resource-Modified-List')[0]['pDU-Session-ID']
    return pduSessionId


def get_ue_capability_from_message(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    ue_capabilities = msg.get_value_by_unique_key('ue-CapabilityRAT-Container')
    return ue_capabilities
