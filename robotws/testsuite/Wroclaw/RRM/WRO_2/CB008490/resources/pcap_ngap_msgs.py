initial_ue_message_reqistartion_request_nrcellid = """
    InitialUEMessage is RegistrationRequest {
        findBy { has(ngap.InitialUEMessage_element) }
        verifyBy { has(nas_5gs.mm.message_type:=0x41)
                   has(ngap.NRCellIdentity:=%s) }}
"""
initial_ue_message_nrcellid = """
    InitialUEMessage is RegistrationRequest {
        findBy { has(ngap.InitialUEMessage_element) }
        verifyBy { has(ngap.NRCellIdentity:=%s) }}
"""
ics_setup_req_pdu_session = """
    InitialContextSetupRequest has PDU Session {
        findBy { has(ngap.InitialContextSetupRequest_element) }
        verifyBy { has(ngap.PDUSessionResourceSetupListCxtReq) }}
"""
ics_setup_resp_pdu_session = """
    InitialContextSetupResponse has PDU Session {
        findBy { has(ngap.InitialContextSetupResponse_element) }
        verifyBy { has(ngap.PDUSessionResourceSetupListCxtRes) }}
"""
pdu_session_res_mod_ind = """
    PDUSessionResourceModifyIndication {
        findBy { has(ngap.PDUSessionResourceModifyIndication_element) }}
"""
pdu_session_res_mod_confirm = """
    PDUSessionResourceModifyConfirm {
        findBy { has(ngap.PDUSessionResourceModifyConfirm_element) }}
"""
pdu_session_res_rel_command = """
    PDUSessionResourceReleaseCommand with cause: nas: normal-release {
        findBy { has(ngap.PDUSessionResourceReleaseCommand_element) }
        verifyBy { has(ngap.nas:=0)
                   has(ngap.pDUSessionID:=2)}}
"""
pdu_session_res_rel_response = """
    PDUSessionResourceReleaseResponse {
        findBy { has(ngap.PDUSessionResourceReleaseResponse_element) }
        verifyBy { has(ngap.pDUSessionID:=2) }}
"""

ue_ctx_rel_req = """
    UEContextReleaseCommand {
        findBy { has(ngap.UEContextReleaseCommand_element) }}
"""
ue_ctx_rel_req_radio_connection_with_ue_lost = """
    UEContextReleaseCommand with Cause radioNetwork: radio-connection-with-ue-lost{
        findBy { has(ngap.UEContextReleaseCommand_element) }
        verifyBy { has(ngap.radioNetwork:=21) }}
"""
ue_ctx_rel_req_nas_deregister = """
    UEContextReleaseCommand has nas == deregister  {
        findBy { has(ngap.UEContextReleaseCommand_element) }
        verifyBy { has(ngap.nas:=2) }}
"""
ue_ctx_release_complete = """
    UEContextReleaseComplete {
        findBy { has(ngap.UEContextReleaseComplete_element) }}
"""
ng_reset_resp_partial_misc_om_intervention = """
    ResetRequest with Cause radioNetwork: release-due-to-ngran-generated-reason {
        findBy { has(ngap.NGReset_element) }
        verifyBy { has(ngap.partOfNG_Interface)
                   has(ngap.radioNetwork:=3) }}
"""
ng_reset_ack = """
    NGResetAcknowledge {
        findBy { has(ngap.NGResetAcknowledge_element) }
        verifyBy { has(ngap.UE_associatedLogicalNG_connectionList) }}
"""
