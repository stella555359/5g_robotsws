bearer_setup_req = """
    BearerContextSetupRequest {
        findBy { has(e1ap.BearerContextSetupRequest_element) }}
"""
bearer_setup_resp = """
    BearerContextSetupResponse {
        findBy { has(e1ap.BearerContextSetupResponse_element) }}
"""
bearer_mod_req = """
    BearerContextModificationRequest {
        findBy { has(e1ap.BearerContextModificationRequest_element) }}
"""
bearer_mod_req_stop = """
    BearerContextModificationRequest {
        findBy { has(e1ap.BearerContextModificationRequest_element) }
        verifyBy { has(e1ap.cell_Group_ID:=0)
                   has(e1ap.dL_TX_Stop:=0)
                   has(e1ap.cell_Group_ID:=1)
                   has(e1ap.dL_TX_Stop:=0) }}
"""
bearer_mod_req_release = """
    BearerContextModificationRequest with session release with cause: radioNetwork: normal-release {
        findBy { has(e1ap.BearerContextModificationRequest_element) }
        verifyBy { has(e1ap.PDU_Session_Resource_To_Remove_Item_element)
                   has(e1ap.radioNetwork:=20) }}
"""
bearer_mod_resp = """
    BearerContextModificationResponse {
        findBy { has(e1ap.BearerContextModificationResponse_element) }}
"""
bearer_context_inactivity_notification_active = """
    BearerContextInactivityNotification with uE-Activity: active {
        findBy { has(e1ap.BearerContextInactivityNotification_element) }
        verifyBy { has(e1ap.uE_Activity:=0) }}
"""
bearer_context_inactivity_notification_not_active = """
    BearerContextInactivityNotification with uE-Activity: not-active {
        findBy { has(e1ap.BearerContextInactivityNotification_element) }
        verifyBy { has(e1ap.uE_Activity:=1) }}
"""
bearer_rel_command_radio_network_normal_release = """
    BearerContextReleaseCommand has radioNetwork == normal-release {
        findBy { has(e1ap.BearerContextReleaseCommand_element) }
        verifyBy { has(e1ap.radioNetwork:=20) }}
"""
bearer_rel_command_radio_network_unspecified = """
    BearerContextReleaseCommand has radioNetwork == unspecified {
        findBy { has(e1ap.BearerContextReleaseCommand_element) }
        verifyBy { has(e1ap.radioNetwork:=0) }}
"""
bearer_rel_complete = """
    BearerContextReleaseComplete {
        findBy { has(e1ap.BearerContextReleaseComplete_element) }}
"""
reset_partial_transport_unspecified = """
    Reset has Cause transport: unspecified  {
        findBy { has(e1ap.Reset_element) }
        verifyBy { has(e1ap.partOfE1_Interface)
                   has(e1ap.transport:=0) }}
"""
reset_partial_misc_om_intervention = """
    Reset has Cause misc: om-intervention {
        findBy { has(e1ap.Reset_element) }
        verifyBy { has(e1ap.partOfE1_Interface)
                   has(e1ap.misc:=3) }}
"""
reset_ack = """
    ResetAcknowledge {
        findBy { has(e1ap.ResetAcknowledge_element) }
        verifyBy { has(e1ap.UE_associatedLogicalE1_ConnectionListResAck) }}
"""
