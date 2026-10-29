"""
:copyright: Nokia Networks
:author: Konrad Bem <konrad.bem@nokia.com>
:maintainer: Konrad Bem <konrad.bem@nokia.com>
"""

import logging
from ta_messaging.message_flows import get_flow
from ta_messaging.message_sources.message_sources_tshark_based import configure_iphy_interfaces
from ta_messaging.message_sources.message_sources_tshark_based import restore_default_iphy_interfaces
from ute_common_abstract_core.message import NotFoundKey
from ta_pdml_parser import parse_rrc5g_container
from testsuite.Krakow.RRM.resources.Python.dictionaries import compare_dicts
from robot.api.deco import keyword
from taf.rfrl.utilities.robot.general import get_builtin_value
from datetime import datetime, timezone
import yaml
from math import floor

logger = logging.getLogger('messaging.flows.logic')


def get_last_char(string):
    return string[-1]


def verify_UEContextSetupRequest_DLPDCPSNLength_ULPDCPSNLength(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    ie_extensions = msg.get_value_by_unique_key('DRBs-ToBeSetup-Item')['iE-Extensions']
    logger.info('2: iE-Extensions')
    logger.info(ie_extensions)
    verify_PDCPSNLength(ie_extensions)


def verify_PDCPSNLength(ie_extensions):
    try:
        for ie_extension in ie_extensions:
            if ie_extension['id'] == 161:
                if ie_extension['extensionValue']['PDCPSNLength'] == 'eighteen-bits':
                    logger.info('DLPDCPSNLength (id:161) has correct PDCPSNLength = eighteen-bits')
                else:
                    logger.error('DLPDCPSNLength (id:161) has incorrect PDCPSNLength value: %s',
                                 ie_extension['extensionValue']['PDCPSNLength'])
                    raise Exception
            elif ie_extension['id'] == 192:
                if ie_extension['extensionValue']['PDCPSNLength'] == 'eighteen-bits':
                    logger.info('ULPDCPSNLength (id:192) has correct PDCPSNLength = eighteen-bits')
                else:
                    logger.error('ULPDCPSNLength (id:192) has incorrect PDCPSNLength value: %s',
                                 ie_extension['extensionValue']['PDCPSNLength'])
                    raise Exception
            else:
                logger.error('DLPDCPSNLength (id:161) or ULPDCPSNLength (id:192) not found '
                             'on DRBs-ToBeSetup-Item -> iE-Extensions list')
                raise Exception
    except Exception as e:
        logger.error('verify_UEContextSetupRequest_DLPDCPSNLength_ULPDCPSNLength error: ')
        logger.error(e)
        raise Exception


def get_PDU_session_from_SNodeAdditionRequest(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    pdu = msg.get_value_by_unique_key('PDUSessionToBeAddedAddReq')
    return pdu


def get_PDU_session_from_SNodeAdditionAcknowledge(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    pdu = msg.get_value_by_unique_key('PDUSessionAdmittedAddedAddReqAck')
    return pdu


def get_PDU_session_from_BearerContextSetupRequest(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    pdu = msg.get_value_by_unique_key('PDU-Session-Resource-To-Setup-List')
    return pdu


def get_PDU_session_from_BearerContextSetupResponse(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    pdu = msg.get_value_by_unique_key('PDU-Session-Resource-Setup-List')
    return pdu


def get_drb_list_from_BearerContextSetupRequest(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    drb_list = msg.get_value_by_unique_key('dRB-To-Setup-List-NG-RAN')
    return drb_list


def get_drb_list_from_BearerContextSetupResponse(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    drb_list = msg.get_value_by_unique_key('dRB-Setup-List-NG-RAN')
    return drb_list


def get_drb_list_from_UEContextSetupRequest(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    drb_list = msg.get_value_by_unique_key('DRBs-ToBeSetup-List')
    return drb_list


def get_drb_list_from_SNodeAdditionRequestAcknowledge(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    drb_list = msg.get_value_by_unique_key('dRBsToBeSetup')
    return drb_list


def convert_str_to_int_list(drb_ids):
    drb_list = [int(c.strip()) for c in drb_ids.split(',')]
    return drb_list


def get_drb_ids_from_drb_list(drb_list):
    drb_ids_list = []
    possible_IE_names = ['dRB-ID', 'dRBID', 'drb-ID', 'drbID']

    for IE_name in possible_IE_names:
        for drb in drb_list:
            try:
                drb_ids_list.append(drb.get_value_by_unique_key(IE_name))
            except NotFoundKey:
                break

    return drb_ids_list


def get_drb_to_tunnels_mapping(flow_alias, msg):
    drb_tunnels = {}
    if msg == 'BearerContextSetupResponse':
        drb_list = get_drb_list_from_BearerContextSetupResponse(flow_alias, msg)
        for drb in drb_list:
            if len(drb['uL-UP-Transport-Parameters']) != 2:
                logger.error("uL-UP-Transport-Parameters should have 2 elements")
                logger.error(f"uL-UP-Transport-Parameters: {drb['uL-UP-Transport-Parameters']}")
                raise Exception
            drb_tunnels[drb['dRB-ID']] = drb['uL-UP-Transport-Parameters']

    if msg == 'UEContextSetupRequest':
        drb_list = get_drb_list_from_UEContextSetupRequest(flow_alias, msg)
        for drb in drb_list:
            drb_item = drb['value']['DRBs-ToBeSetup-Item']
            if len(drb_item['uLUPTNLInformation-ToBeSetup-List']) != 1:
                logger.error("uLUPTNLInformation-ToBeSetup-List should have 1 element")
                logger.error(f"uLUPTNLInformation-ToBeSetup-List: {drb_item['uLUPTNLInformation-ToBeSetup-List']}")
                raise Exception
            drb_tunnels[drb_item['dRBID']] = drb_item['uLUPTNLInformation-ToBeSetup-List']

    if msg == 'SNodeAdditionRequestAcknowledge':
        drb_list = get_drb_list_from_SNodeAdditionRequestAcknowledge(flow_alias, msg)
        for drb in drb_list:
            if len(drb['sN-UL-PDCP-UP-TNLInfo']) != 1:
                logger.error("sN-UL-PDCP-UP-TNLInfo should have 1 element")
                logger.error(f"sN-UL-PDCP-UP-TNLInfo: {drb['sN-UL-PDCP-UP-TNLInfo']}")
                raise Exception
            drb_tunnels[drb['drb-ID']] = drb['sN-UL-PDCP-UP-TNLInfo']

    return drb_tunnels


def compare_gTPTunnels_between_messages(msg1, msg1_flow, msg2, msg2_flow):
    supported_messages = ['SNodeAdditionRequestAcknowledge',
                          'BearerContextSetupResponse',
                          'UEContextSetupRequest']

    if msg1 not in supported_messages or msg2 not in supported_messages:
        logger.error(f"Comparing not supported messages. Choose from {supported_messages}")
        raise Exception

    msg1_drb_tunnels = get_drb_to_tunnels_mapping(msg1_flow, msg1)
    msg2_drb_tunnels = get_drb_to_tunnels_mapping(msg2_flow, msg2)

    logger.info(f"Tunnels from {msg1}: {msg1_drb_tunnels}")
    logger.info(f"Tunnels from {msg2}: {msg2_drb_tunnels}")

    if msg1 == 'BearerContextSetupResponse' and msg2 == 'UEContextSetupRequest':
        logger.info(f"Comparing {msg1} and {msg2}")
        for drb_id in msg1_drb_tunnels.keys():
            assert drb_id in msg2_drb_tunnels.keys(), f"DRB with ID {drb_id} not present in {msg2}"

            for tunnel in msg1_drb_tunnels[drb_id]:
                if tunnel['cell-Group-ID'] == 1:
                    gtp_tunnel_1 = tunnel['uP-TNL-Information']['gTPTunnel']
                    gtp_tunnel_2 = msg2_drb_tunnels[drb_id][0]['uLUPTNLInformation']['gTPTunnel']
                    logger.info(f"Comparing:\n{gtp_tunnel_1}\n{gtp_tunnel_2}")
                    assert gtp_tunnel_1['transportLayerAddress'] == gtp_tunnel_2['transportLayerAddress']
                    assert gtp_tunnel_1['gTP-TEID'] == gtp_tunnel_2['gTP-TEID']

    if msg1 == 'BearerContextSetupResponse' and msg2 == 'SNodeAdditionRequestAcknowledge':
        logger.info(f"Comparing {msg1} and {msg2}")
        for drb_id in msg1_drb_tunnels.keys():
            assert drb_id in msg2_drb_tunnels.keys(), f"DRB with ID {drb_id} not present in {msg2}"

            for tunnel in msg1_drb_tunnels[drb_id]:
                if tunnel['cell-Group-ID'] == 0:
                    gtp_tunnel_1 = tunnel['uP-TNL-Information']['gTPTunnel']
                    gtp_tunnel_2 = msg2_drb_tunnels[drb_id][0]['upTNLInfo']['gtpTunnel']
                    logger.info(f"Comparing:\n{gtp_tunnel_1}\n{gtp_tunnel_2}")
                    assert gtp_tunnel_1['transportLayerAddress'] == gtp_tunnel_2['tnl-address']
                    assert gtp_tunnel_1['gTP-TEID'] == gtp_tunnel_2['gtp-teid']

    return True


def verify_dl_dataforwarding(flow, msg, num_of_qos_flows):
    pdu = get_PDU_session_from_SNodeAdditionRequest(flow, msg)
    qosFlowsToBeForwarded = pdu.get_value_by_unique_key('qosFlowsToBeForwarded')
    assert len(qosFlowsToBeForwarded) == int(num_of_qos_flows), "Wrong number of QoS Flows"
    for qos in qosFlowsToBeForwarded:
        assert qos['dl-dataforwarding'] == 'dl-forwarding-proposed'
        logger.info(f"qosFlowIdentifier: {qos['qosFlowIdentifier']} - dl-dataforwarding eq dl-forwarding-proposed")


def verify_sourceDRBtoQoSFlowMapping(flow, msg, num_of_drbs):
    pdu = get_PDU_session_from_SNodeAdditionRequest(flow, msg)
    sourceDRBtoQoSFlowMapping = pdu.get_value_by_unique_key('sourceDRBtoQoSFlowMapping')
    assert len(sourceDRBtoQoSFlowMapping) == int(num_of_drbs), "Wrong number of DRBs"
    for drb in sourceDRBtoQoSFlowMapping:
        assert len(drb['qosFlows-List']) == 1
        logger.info(f"drb-ID: {drb['drb-ID']} - contains single qfi: {drb['qosFlows-List'][0]}")


def verify_drbs_in_BearerContextSetupRequest(flow, msg, num_of_drbs):
    first_drb_id = 4
    drbs = get_drb_list_from_BearerContextSetupRequest(flow, msg)
    assert len(drbs) == int(num_of_drbs), "Wrong number of DRBs"
    for drb in drbs:
        logger.info(drb)

        drb_id = drb.get_value_by_unique_key('dRB-ID')
        default_drb = drb.get_value_by_unique_key('defaultDRB')
        pdcp_reestab = drb.get_value_by_unique_key('pDCP-Reestablishment')
        cgi = drb.get_value_by_unique_key('cell-Group-Information')
        qos = drb.get_value_by_unique_key('qos-flow-Information-To-Be-Setup')
        drb_forwarding = drb.get_value_by_unique_key('dRB-Data-Forwarding-Information-Request')

        if drb_id == first_drb_id:
            assert default_drb == 'true', f"DRB-{drb_id} should be true"
        else:
            assert default_drb == 'false', f"DRB-{drb_id} should be false"

        assert pdcp_reestab == 'true', f"pDCP-Reestablishment should be true for all DRBs"
        assert len(cgi) == 2, "cell-Group-Information should have 2 elements"

        for CG in cgi:
            if CG['cell-Group-ID'] == 0:
                assert CG['uL-Configuration'] == 'only', "uL-Configuration for MCG should be only"
            if CG['cell-Group-ID'] == 1:
                assert CG['uL-Configuration'] == 'no-data', "uL-Configuration for SCG should be no-data"
            assert 'DL-TX-Stop' not in CG, "DL-TX-Stop should not be present"

        assert len(qos) == 1, "qos-flow-Information-To-Be-Setup should have 1 element"
        assert drb_forwarding['data-Forwarding-Request'] == 'dL', "data-Forwarding-Request should be dL"
        assert 'qoS-Flows-Forwarded-On-Fwd-Tunnels' not in drb_forwarding, "not expected IE found"

    logger.info("All checks done")


def verify_dRB_Inactivity_Timer(flow, msg, timer):
    drbs = get_drb_list_from_BearerContextSetupRequest(flow, msg)
    for drb in drbs:
        t = drb.get_value_by_unique_key('dRB-Inactivity-Timer')
        assert t == int(timer), f"expected timer value: {timer}, got: {t}"

    logger.info("All checks done")


def verify_multi_dRB_Inactivity_Timer(flow, msg, drb_ids, timers):
    drb_ids = convert_str_to_int_list(drb_ids)
    timers = convert_str_to_int_list(timers)
    assert len(drb_ids) == len(timers), "List of DRB IDs and timers must have the same length"
    drbs = get_drb_list_from_BearerContextSetupRequest(flow, msg)
    assert len(drbs) == len(drb_ids), "Wrong number of DRBs"
    for drb in drbs:
        drb_id = drb.get_value_by_unique_key('dRB-ID')
        t = drb.get_value_by_unique_key('dRB-Inactivity-Timer')
        expected_timer = timers[drb_ids.index(drb_id)]
        assert t == expected_timer, f"expected timer value: {expected_timer}, got: {t}"

    logger.info("All checks done")


def verify_drbs_in_BearerContextSetupResponse(flow, msg, num_of_drbs):
    drbs = get_drb_list_from_BearerContextSetupResponse(flow, msg)
    assert len(drbs) == int(num_of_drbs), "Wrong number of DRBs"
    for drb in drbs:
        assert 'dRB-data-Forwarding-Information-Response' in drb, "IE not present"
        assert len(drb['uL-UP-Transport-Parameters']) == 2, "Incorrect number of tunnels"

    logger.info("All checks done")


def verify_drbs_in_UEContextSetupRequest(flow, msg, num_of_drbs):
    drbs = get_drb_list_from_UEContextSetupRequest(flow, msg)
    assert len(drbs) == int(num_of_drbs), "Wrong number of DRBs"
    for drb in drbs:
        ul_config = drb.get_value_by_unique_key('uLUEConfiguration')
        assert ul_config == 'no-data', "Wrong IE value"

        ie_extensions = drb.get_value_by_unique_key('DRBs-ToBeSetup-Item')['iE-Extensions']
        assert len(ie_extensions) == 2, "Incorrect number of IEs"
        verify_PDCPSNLength(ie_extensions)

    logger.info("All checks done")


def verify_lcids_in_rlc_BearerToAddModList(flow, msg, lcids):
    msg = get_flow(flow).get_message(msg)
    lcid_list = [int(c.strip()) for c in lcids.split(',')]
    lcids_to_compare = []
    rlc_bearers = msg.get_value_by_unique_key('rlc-BearerToAddModList')
    assert len(rlc_bearers) == len(lcid_list), "Wrong number of bearers or LCIDs"
    for rlc_bearer in rlc_bearers:
        lcid = rlc_bearer.get_value_by_unique_key('logicalChannelIdentity')
        lcids_to_compare.append(lcid)

    assert lcid_list == sorted(lcids_to_compare), f"Expected LCIDs: {lcid_list}, got: {lcids_to_compare}"

    logger.info("All checks done")


def verify_drbs_in_DRBs_Setup_List(flow, msg, num_of_drbs):
    msg = get_flow(flow).get_message(msg)
    drbs = msg.get_value_by_unique_key('DRBs-Setup-List')
    assert len(drbs) == int(num_of_drbs), "Wrong number of DRBs"
    for drb in drbs:
        tunnels = drb.get_value_by_unique_key('dLUPTNLInformation-ToBeSetup-List')
        assert len(tunnels) == 1, "Only one tunnel should be present"
        assert 'dLUPTNLInformation' in tunnels[0], "IE not present"

    logger.info("All checks done")


def verify_drbs_in_dRBsToBeSetup(flow, msg, drb_ids):
    drb_list = convert_str_to_int_list(drb_ids)
    drbs = get_drb_list_from_SNodeAdditionRequestAcknowledge(flow, msg)
    assert len(drbs) == len(drb_list), "Wrong number of DRBs"
    drbs_to_compare = get_drb_ids_from_drb_list(drbs)

    assert drb_list == sorted(drbs_to_compare), f"Expected DRB IDs: {drb_list}, got: {drbs_to_compare}"

    logger.info("All checks done")


def verify_drbs_in_DRB_LIST(flow, msg, drb_ids):
    msg = get_flow(flow).get_message(msg)
    drb_list = convert_str_to_int_list(drb_ids)
    drbs = msg.get_value_by_unique_key('DRB-List')
    assert len(drbs) == len(drb_list), "Wrong number of DRBs"
    assert drb_list == sorted(drbs), f"Expected DRB IDs: {drb_list}, got: {drbs}"

    logger.info("All checks done")


def verify_drbs_in_XnUAddressIndication(flow, msg, drb_ids):
    msg = get_flow(flow).get_message(msg)
    drb_list = convert_str_to_int_list(drb_ids)
    drbs = msg.get_value_by_unique_key('dRBsToBeSetupList')
    assert len(drbs) == len(drb_list), "Wrong number of DRBs"
    drbs_to_compare = get_drb_ids_from_drb_list(drbs)
    assert drb_list == sorted(drbs_to_compare), f"Expected DRB IDs: {drb_list}, got: {drbs_to_compare}"
    for drb in drbs:
        tunnel = drb.get_value_by_unique_key('gtpTunnel')
        assert 'tnl-address' in tunnel and 'gtp-teid' in tunnel, "IE not present in gtpTunnel"

    logger.info("All checks done")


def verify_drbs_in_SNStatusTransfer(flow, msg, drb_ids):
    msg = get_flow(flow).get_message(msg)
    drb_list = convert_str_to_int_list(drb_ids)
    drbs = msg.get_value_by_unique_key('DRBsSubjectToStatusTransfer-List')
    assert len(drbs) == len(drb_list), "Wrong number of DRBs"
    drbs_to_compare = get_drb_ids_from_drb_list(drbs)
    assert drb_list == sorted(drbs_to_compare), f"Expected DRB IDs: {drb_list}, got: {drbs_to_compare}"
    for drb in drbs:
        pdcp_ul = drb.get_value_by_unique_key('pdcpStatusTransfer-UL')
        pdcp_dl = drb.get_value_by_unique_key('pdcpStatusTransfer-DL')
        assert 'pdcp-sn-18bits' in pdcp_ul and 'pdcp-sn-18bits' in pdcp_dl, "IE not present in pdcpStatusTransfer"
        assert 'cOUNTValue' in pdcp_ul['pdcp-sn-18bits'], "cOUNTValue not present in pdcpStatusTransfer-UL"
        assert 'cOUNTValue' in pdcp_dl['pdcp-sn-18bits'], "cOUNTValue not present in pdcpStatusTransfer-DL"

    logger.info("All checks done")


def verify_drbs_in_BearerContextModReq(flow, msg, drb_ids):
    msg = get_flow(flow).get_message(msg)
    drb_list = convert_str_to_int_list(drb_ids)
    drbs = msg.get_value_by_unique_key('dRB-To-Modify-List-NG-RAN')
    assert len(drbs) == len(drb_list), "Wrong number of DRBs"
    drbs_to_compare = get_drb_ids_from_drb_list(drbs)
    assert drb_list == sorted(drbs_to_compare), f"Expected DRB IDs: {drb_list}, got: {drbs_to_compare}"

    logger.info("All checks done")


def verify_drbs_in_BearerContextModResp(flow, msg, drb_ids):
    msg = get_flow(flow).get_message(msg)
    drb_list = convert_str_to_int_list(drb_ids)
    drbs = msg.get_value_by_unique_key('dRB-Modified-List-NG-RAN')
    assert len(drbs) == len(drb_list), "Wrong number of DRBs"
    drbs_to_compare = get_drb_ids_from_drb_list(drbs)
    assert drb_list == sorted(drbs_to_compare), f"Expected DRB IDs: {drb_list}, got: {drbs_to_compare}"

    logger.info("All checks done")


def verify_drbs_in_BearerContextInactivityNotification(flow, msg, drb_ids):
    msg = get_flow(flow).get_message(msg)
    drb_list = convert_str_to_int_list(drb_ids)
    drbs = msg.get_value_by_unique_key('dRB-Activity-List')
    assert len(drbs) == len(drb_list), "Wrong number of DRBs"
    drbs_to_compare = get_drb_ids_from_drb_list(drbs)
    assert drb_list == sorted(drbs_to_compare), f"Expected DRB IDs: {drb_list}, got: {drbs_to_compare}"
    for drb in drbs:
        assert drb['dRB-Activity'] == 'active'

    logger.info("All checks done")


def verify_drb_activity(flow, msg, drb_num, all_drbs):
    msg = get_flow(flow).get_message(msg)
    drbs = msg.get_value_by_unique_key('dRB-Activity-List')
    assert len(drbs) == int(all_drbs), "Wrong number of DRBs"
    logger.info(drbs)
    active_bearers = 0
    not_active_bearers = 0
    for drb in drbs:
        if drb['dRB-Activity'] == 'active':
            active_bearers += 1
        if drb['dRB-Activity'] == 'not-active':
            not_active_bearers += 1
    assert active_bearers + not_active_bearers == int(all_drbs), "Wrong sum of active and not-active bearers"
    assert active_bearers == int(drb_num), "Wrong number of active bearers"

    logger.info("All checks done")


def verify_bearers_in_RRCReconfiguration(flow, msg, num_of_bearers):
    msg = get_flow(flow).get_message(msg)
    SCG = msg.get_value_by_unique_key('secondaryCellGroup')
    rlc_bearers_list = SCG.get_value_by_unique_key('rlc-BearerToAddModList')
    assert len(rlc_bearers_list) == int(num_of_bearers), "Wrong number of bearers in SCG"
    for bearer in rlc_bearers_list:
        assert 'logicalChannelIdentity' in bearer, "IE not present"

    logger.info("All checks done")


def compare_pdcp_SN_Status_Information(flow1, msg1, flow2, msg2):
    bearerCtxModReq = get_flow(flow1).get_message(msg1)
    SNStatusTransfer = get_flow(flow2).get_message(msg2)

    e1_drb_list = bearerCtxModReq.get_value_by_unique_key('dRB-To-Modify-List-NG-RAN')
    xn_drb_list = SNStatusTransfer.get_value_by_unique_key('DRBsSubjectToStatusTransfer-List')

    for e1_drb in e1_drb_list:
        drb1_id = e1_drb['dRB-ID']
        for xn_drb in xn_drb_list:
            drb2_id = xn_drb['drbID']
            if drb1_id == drb2_id:
                drb1_UL_pdcpsn = e1_drb.get_value_by_unique_key('pdcpStatusTransfer-UL')['countValue']['pDCP-SN']
                drb1_DL_pdcpsn = e1_drb.get_value_by_unique_key('pdcpStatusTransfer-DL')['pDCP-SN']
                drb1_UL_hfn = e1_drb.get_value_by_unique_key('pdcpStatusTransfer-UL')['countValue']['hFN']
                drb1_DL_hfn = e1_drb.get_value_by_unique_key('pdcpStatusTransfer-DL')['hFN']

                drb2_UL_count = xn_drb.get_value_by_unique_key('pdcpStatusTransfer-UL')['pdcp-sn-18bits']['cOUNTValue']
                drb2_DL_count = xn_drb.get_value_by_unique_key('pdcpStatusTransfer-DL')['pdcp-sn-18bits']['cOUNTValue']

                drb2_UL_pdcpsn = drb2_UL_count.get_value_by_unique_key('pdcp-SN18')
                drb2_DL_pdcpsn = drb2_DL_count.get_value_by_unique_key('pdcp-SN18')
                drb2_UL_hfn = drb2_UL_count.get_value_by_unique_key('hfn-PDCP-SN18')
                drb2_DL_hfn = drb2_DL_count.get_value_by_unique_key('hfn-PDCP-SN18')

                logger.info(f"Comparing:\n{drb1_UL_pdcpsn}\n{drb2_UL_pdcpsn}")
                assert drb1_UL_pdcpsn == drb2_UL_pdcpsn, "Wrong value of pdcpStatusTransfer-UL pDCP-SN"
                logger.info(f"Comparing:\n{drb1_DL_pdcpsn}\n{drb2_DL_pdcpsn}")
                assert drb1_DL_pdcpsn == drb2_DL_pdcpsn, "Wrong value of pdcpStatusTransfer-DL pDCP-SN"
                logger.info(f"Comparing:\n{drb1_UL_hfn}\n{drb2_UL_hfn}")
                assert drb1_UL_hfn == drb2_UL_hfn, "Wrong value of pdcpStatusTransfer-UL hFN"
                logger.info(f"Comparing:\n{drb1_DL_hfn}\n{drb2_DL_hfn}")
                assert drb1_DL_hfn == drb2_DL_hfn, "Wrong value of pdcpStatusTransfer-DL hFN"

    logger.info("All checks done")


def compare_tunnels_in_BearerContextModReq(flow1, msg1, flow2, msg2, flow3, msg3):
    bearerCtxModReq = get_flow(flow1).get_message(msg1)
    UECtxSetupResp = get_flow(flow2).get_message(msg2)
    XNUAddrInd = get_flow(flow3).get_message(msg3)

    e1_drb_list = bearerCtxModReq.get_value_by_unique_key('dRB-To-Modify-List-NG-RAN')
    f1_drb_list = UECtxSetupResp.get_value_by_unique_key('DRBs-Setup-List')
    xn_drb_list = XNUAddrInd.get_value_by_unique_key('dRBsToBeSetupList')

    for e1_drb in e1_drb_list:
        e1_drb_id = e1_drb['dRB-ID']
        for f1_drb in f1_drb_list:
            f1_drb_id = f1_drb.get_value_by_unique_key('dRBID')
            if e1_drb_id == f1_drb_id:
                for item in e1_drb['dL-UP-Parameters']:
                    if item['cell-Group-ID'] == 1:
                        gtp_tunnel_1 = item.get_value_by_unique_key('gTPTunnel')
                        gtp_tunnel_2 = f1_drb.get_value_by_unique_key('gTPTunnel')
                        logger.info(f"Comparing:\n{gtp_tunnel_1}\n{gtp_tunnel_2}")
                        assert gtp_tunnel_1['transportLayerAddress'] == gtp_tunnel_2['transportLayerAddress']
                        assert gtp_tunnel_1['gTP-TEID'] == gtp_tunnel_2['gTP-TEID']

        for xn_drb in xn_drb_list:
            xn_drb_id = xn_drb.get_value_by_unique_key('dRB-ID')
            if e1_drb_id == xn_drb_id:
                for item in e1_drb['dL-UP-Parameters']:
                    if item['cell-Group-ID'] == 0:
                        gtp_tunnel_1 = item.get_value_by_unique_key('gTPTunnel')
                        gtp_tunnel_2 = xn_drb.get_value_by_unique_key('gtpTunnel')
                        logger.info(f"Comparing:\n{gtp_tunnel_1}\n{gtp_tunnel_2}")
                        assert gtp_tunnel_1['transportLayerAddress'] == gtp_tunnel_2['tnl-address']
                        assert gtp_tunnel_1['gTP-TEID'] == gtp_tunnel_2['gtp-teid']

    logger.info("All checks done")


def parse_mn_to_sn_container(flow, msg):
    msg_content = get_flow(flow).get_message(msg)
    mn_to_sn_container_hex = msg_content.get_value_by_unique_key('STRING')
    container_IE = parse_rrc5g_container('CG-ConfigInfo', mn_to_sn_container_hex)
    return container_IE


def parse_sn_to_mn_container(flow, msg):
    msg_content = get_flow(flow).get_message(msg)
    sn_to_mn_container_hex = msg_content.get_value_by_unique_key('STRING')
    container_IE = parse_rrc5g_container('CG-Config', sn_to_mn_container_hex)
    return container_IE


def compare_secondaryCellGroup_and_CellGroupConfig(flow1, msg1, flow2, msg2):
    cg_config = parse_sn_to_mn_container(flow1, msg1)
    ue_ctx_stp_resp = get_flow(flow2).get_message(msg2)
    secondaryCellGroup = cg_config.get_value_by_unique_key('secondaryCellGroup')['CONTAINING']
    CellGroupConfig = ue_ctx_stp_resp.get_value_by_unique_key('cellGroupConfig')['CellGroupConfig']

    compare_dicts(secondaryCellGroup, CellGroupConfig)


def verify_sdap_config_in_snode_add_request_and_ack(flow, rdDisableSDAPheaderSa):
    snode_request = get_flow(flow).get_message('SNodeAdditionRequest')
    snode_request_ack = get_flow(flow).get_message('SNodeAdditionRequestAcknowledge')
    mn_to_sn_container_hex = snode_request.get_value_by_unique_key('STRING')
    sn_to_mn_container_hex = snode_request_ack.get_value_by_unique_key('STRING')

    container_IE = parse_rrc5g_container('CG-ConfigInfo', mn_to_sn_container_hex)
    container_IE_ack = parse_rrc5g_container('CG-Config', sn_to_mn_container_hex)
    drb_list = container_IE.get_value_by_unique_key('drb-ToAddModList')
    drb_list_ack = container_IE_ack.get_value_by_unique_key('drb-ToAddModList')

    for drb_list_to_check in (drb_list, drb_list_ack):
        for drb in drb_list_to_check:
            logger.info(drb)
            sdap_header_ul = drb.get_value_by_unique_key('sdap-HeaderUL')
            default_drb = drb.get_value_by_unique_key('defaultDRB')
            if drb['drb-Identity'] == 4 and not rdDisableSDAPheaderSa:
                assert default_drb == 'TRUE', "defaultDRB set to FALSE, but should be TRUE"
                assert sdap_header_ul == 'present', "sdap-HeaderUL is set to absent, but should be present"
            else:
                assert default_drb == 'FALSE', "defaultDRB set to TRUE, but should be FALSE"
                assert sdap_header_ul == 'absent', "sdap-HeaderUL is set to present, but should be absent"


def verify_sdap_config_in_bearer_ctx_setup_request(flow, msg, rdDisableSDAPheaderSa):
    drb_list = get_drb_list_from_BearerContextSetupRequest(flow, msg)
    for drb in drb_list:
        logger.info(drb)
        sdap_header_ul = drb.get_value_by_unique_key('sDAP-Header-UL')
        default_drb = drb.get_value_by_unique_key('defaultDRB')
        if drb['dRB-ID'] == 4 and not rdDisableSDAPheaderSa:
            assert default_drb == 'true', "defaultDRB set to false, but should be true"
            assert sdap_header_ul == 'present', "sdap-HeaderUL is set to absent, but should be present"
        else:
            assert default_drb == 'false', "defaultDRB set to true, but should be false"
            assert sdap_header_ul == 'absent', "sdap-HeaderUL is set to present, but should be absent"


def compare_candidateCellInfoListMN(flow1, msg1, flow2, msg2):
    mn_to_sn_parsed = parse_mn_to_sn_container(flow1, msg1)
    ue_ctx_setup_req = get_flow(flow2).get_message(msg2)

    candidateCellInfoListMN_1 = mn_to_sn_parsed.get_value_by_unique_key('candidateCellInfoListMN')
    candidateCellInfoListMN_2 = ue_ctx_setup_req.get_value_by_unique_key('candidateCellInfoListMN')

    compare_dicts(candidateCellInfoListMN_1, candidateCellInfoListMN_2)


def prepare_nxa_query(nxa_list):
    query = ""
    for item in nxa_list:
        query += f"'{item}-128',"

    return query.rstrip(',')


def verify_field_not_in_sn_to_mn_container(field, flow, msg):
    sn_to_mn_container = parse_sn_to_mn_container(flow, msg)
    logger.info(sn_to_mn_container)
    assert field not in sn_to_mn_container


def verify_field_not_in_mn_to_sn_container(field, flow, msg):
    mn_to_sn_container = parse_mn_to_sn_container(flow, msg)
    logger.info(mn_to_sn_container)
    assert field not in mn_to_sn_container


def enable_ue_capture_on_simulated_enb(enable=True):
    """
    Enable expectations in ta_messaging for AirPhone UEs RRC flow
    +------------------+-------+------------+------------+
    |     Example                                        |
    +==================+=======+============+============+
    | Enable UE Capture On Simulated Enb  enable=${True} |
    | Create UEs alias  alias=UE  id_type=wts            |
    | Expect Message Flow                                |
    | ...  UE_1:RRC_RRCConnectionReconfiguration         |
    | ...  alias=your_flow_alias                         |
    | ...  overall_timeout=30                            |
    +------------------+-------+------------+------------+
    :param enable:
    :return:
    """
    if enable:
        configure_iphy_interfaces(['any'])
    else:
        restore_default_iphy_interfaces()


def get_ip_address_of_second_tl():
    tl_cfg = get_builtin_value(param_name="tl")
    vm2_address = None
    try:
        vm2_address = tl_cfg.test_pcs[1].default_ssh_connection_details.addr
    except IndexError:
        logger.warn("Second VM not found")

    return vm2_address


@keyword("Verify that resetRequest was send to the same UE as in SNodeAdditionRequest to SN gNB${sn_gnb_id}")
def verify_that_reset_request_was_send_to_the_same_ue(sn_gnb_id):
    resetReq_alias = f'gNB{sn_gnb_id}_XNAP_ResetRequest_ResetResponse'
    reset_msg = 'ResetRequest'
    snodeAdd_alias = f'gNB{sn_gnb_id}_XNAP_SNodeAdditionRequest_SNodeAdditionRequestAcknowledge'
    snodeAddReq_msg = 'SNodeAdditionRequest'
    snodeAddAck_msg = 'SNodeAdditionRequestAcknowledge'

    ng_ran_node1UEXnAPID = get_flow(resetReq_alias).get_message(reset_msg).get_value_by_unique_key(
        'ng-ran-node1UEXnAPID')
    ng_ran_node2UEXnAPID = get_flow(resetReq_alias).get_message(reset_msg).get_value_by_unique_key(
        'ng-ran-node2UEXnAPID')

    NG_RANnodeUEXnAPID_req = get_flow(snodeAdd_alias).get_message(snodeAddReq_msg).get_value_by_unique_key(
        'NG-RANnodeUEXnAPID')
    NG_RANnodeUEXnAPID_ack = get_flow(snodeAdd_alias).get_message(snodeAddAck_msg).get_value_by_unique_key(
        'SNodeAdditionRequestAcknowledge')['protocolIEs'][1]['value']['NG-RANnodeUEXnAPID']

    assert ng_ran_node1UEXnAPID == NG_RANnodeUEXnAPID_req and ng_ran_node2UEXnAPID == NG_RANnodeUEXnAPID_ack


def get_ps_config(suspended=False):
    current_day = datetime.now().strftime("%A")
    current_hour = datetime.now(timezone.utc).hour
    isSuspended = "suspended" if suspended else "notSuspended"
    config = [{
        "ID": 1,
        "MOC": "NRPGRP",
        "lbpsPeriodList": [{
            "lbpsDayOfWeek": str(current_day[0:3]),
            "lbpsDuration": "1440",
            "lbpsStartTimeHour": str(current_hour),
            "lbpsStartTimeMinute": "0",
            "lbpsSuspended": isSuspended
        }]
    }]

    with open('/home/ute/MN/UTE/robotws/testsuite/Krakow/RRM/DevKr/CB008490/config/yaml/power_saving.yaml', 'w') as f:
        yaml.dump(config, f, default_flow_style=False)


@keyword("Verify that NRCELL-4 alternative band was configured as SCell for UE${ue_id}")
def verify_scell_band(ue_id):
    RRC_flow = f'UE_{ue_id}_NR-RRC_RRCReconfiguration_1_RRCReconfiguration_2_RRCReconfiguration_3'
    scell_freq_band = get_flow(RRC_flow).get_message('RRCReconfiguration_2').get_value_by_unique_key(
        'frequencyBandList')
    assert scell_freq_band == [5]


def calculate_timing_advance(dist):
    """https://confluence.ext.net.nokia.com/display/AirPhoneWTS/ue_ta_nr"""
    c = 300000000
    ta = 2 * int(dist) / c
    ts = 64 / (480000 * 4096)
    tg = 16 * ts / (2 * 3)
    return floor(ta / tg)
