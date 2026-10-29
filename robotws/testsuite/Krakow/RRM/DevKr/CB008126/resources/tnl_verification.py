import pprint
from ta_messaging.message_flows import get_flow


def get_ul_tnl_ip_teid(flow_alias, message_alias, pdu_id):
    msg = get_flow(flow_alias).get_message(message_alias)
    pdu_list_ie, tnl_ie = None, None
    if message_alias == 'InitialContextSetupRequest':
        pdu_list_ie = 'PDUSessionResourceSetupListCxtReq'
        tnl_ie = 'UPTransportLayerInformation'
    elif message_alias == 'PDUSessionResourceSetupRequest':
        pdu_list_ie = 'PDUSessionResourceSetupListSUReq'
        tnl_ie = 'UPTransportLayerInformation'
    elif message_alias == 'PDUSessionResourceModifyRequest':
        pdu_list_ie = 'PDUSessionResourceModifyListModReq'
        tnl_ie = 'uL-NGU-UP-TNLInformation'
    assert pdu_list_ie, f'UL NG-U UP TNL is not expected to be checked in message: {message_alias}'
    pdu_list = msg.get_value_by_unique_key(pdu_list_ie)
    tnl_address = search_field_in_item_with_specific_pdu(tnl_ie, pdu_list, pdu_id)

    return tnl_address['gTPTunnel']


def verify_ul_tnl_address_modification_is_forwarded_to_cu_up(flow_alias_ngap, flow_alias_e1ap, pdu_id):
    tnl_mod_req_ngap = get_from_pdu_mod_ngap_req(flow_alias_ngap, 'uL-NGU-UP-TNLInformation', pdu_id)
    tnl_mod_req_e1ap = get_from_pdu_mod_e1ap_req(flow_alias_e1ap, 'nG-UL-UP-TNL-Information', pdu_id)
    assert tnl_mod_req_ngap == tnl_mod_req_e1ap, \
        f'uL-NGU-UP-TNLInformation from NGAP:PDUSessionResourceModifyRequest:\n' \
        f'{pprint.pformat(tnl_mod_req_ngap)}\n' \
        f'uL-NGU-UP-TNLInformation from E1AP:BearerContextModificationRequest:\n' \
        f'{pprint.pformat(tnl_mod_req_e1ap)}\n'


def verify_tnl_address_in_pdu_mod_response_is_the_same_as_in_request(flow_alias_ngap, pdu_id):
    ul_tnl_mod_req = get_from_pdu_mod_ngap_req(flow_alias_ngap, 'uL-NGU-UP-TNLInformation', pdu_id)
    ul_tnl_mod_resp = get_from_pdu_mod_ngap_resp(flow_alias_ngap, 'uL-NGU-UP-TNLInformation', pdu_id)
    dl_tnl_mod_req = get_from_pdu_mod_ngap_req(flow_alias_ngap, 'dL-NGU-UP-TNLInformation', pdu_id)
    dl_tnl_mod_resp = get_from_pdu_mod_ngap_resp(flow_alias_ngap, 'dL-NGU-UP-TNLInformation', pdu_id)

    assert ul_tnl_mod_req == ul_tnl_mod_resp
    assert dl_tnl_mod_req == dl_tnl_mod_resp


def get_from_pdu_mod_ngap_req(flow_alias, field, pdu_id):
    msg = get_flow(flow_alias).get_message('PDUSessionResourceModifyRequest')
    pdu_list = msg.get_value_by_unique_key('PDUSessionResourceModifyListModReq')
    value = search_field_in_item_with_specific_pdu(field, pdu_list, pdu_id)
    return value


def get_from_pdu_mod_ngap_resp(flow_alias, field, pdu_id):
    msg = get_flow(flow_alias).get_message('PDUSessionResourceModifyResponse')
    pdu_list = msg.get_value_by_unique_key('PDUSessionResourceModifyListModRes')
    value = search_field_in_item_with_specific_pdu(field, pdu_list, pdu_id)
    return value


def get_from_pdu_mod_e1ap_req(flow_alias, field, pdu_id):
    msg = get_flow(flow_alias).get_message('BearerContextModificationRequest')
    pdu_list = msg.get_value_by_unique_key('PDU-Session-Resource-To-Modify-List')
    value = search_field_in_item_with_specific_pdu(field, pdu_list, pdu_id)
    return value


def search_field_in_item_with_specific_pdu(field, pdu_list, pdu_id):
    value = None
    for pdu in pdu_list:
        if str(pdu.get('pDUSessionID')) == pdu_id or str(pdu.get('pDU-Session-ID')) == pdu_id:
            try:
                value = pdu.get_value_by_unique_key(field)
            except Exception as e:
                print(f'IE {field} is not present for PDU session = {pdu_id}')
                raise e
    assert value is not None, f'PDU session = {pdu_id} is not present'
    return value
