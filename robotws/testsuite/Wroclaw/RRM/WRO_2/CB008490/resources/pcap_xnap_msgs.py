snode_add_req_allowed_bc = """
    SNodeAdditionRequest {
            findBy { has(xnap.SNodeAdditionRequest_element) }
            verifyBy { has (nr-rrc.allowedBC_ListMRDC) }}
"""
snode_add_req_ack = """
    SNodeAdditionRequestAcknowledge {
        findBy { has(xnap.SNodeAdditionRequestAcknowledge_element) }
        verifyBy { has (nr-rrc.bandCombinationIndex)
                   has (nr-rrc.requestedFeatureSets) }}
"""
snode_add_req_ack_8cc = """
    SNodeAdditionRequestAcknowledge {
        findBy { has(xnap.SNodeAdditionRequestAcknowledge_element) }
        verifyBy { has (nr-rrc.sCellIndex:=2)
                   has (nr-rrc.sCellIndex:=3)
                   has (nr-rrc.sCellIndex:=4)
                   has (nr-rrc.sCellIndex:=5)
                   has (nr-rrc.sCellIndex:=6)
                   has (nr-rrc.sCellIndex:=7)
                   has (nr-rrc.bandCombinationIndex)
                   has (nr-rrc.requestedFeatureSets) }}
"""
xnu_addr_ind = """
    XnUAddressIndication {
        findBy { has(xnap.XnUAddressIndication_element) }}
"""
sn_status_transfer = """
    SNStatusTransfer {
        findBy { has(xnap.SNStatusTransfer_element) }}
"""
snode_reconf_complete = """
    SNodeReconfigurationComplete {
        findBy { has(xnap.SNodeReconfigurationComplete_element) }}
"""
snode_release_req = """
    SNodeReleaseRequest {
        findBy { has(xnap.SNodeReleaseRequest_element) }}
"""
snode_rel_req_radio_network_normal_release = """
    SNodeReleaseRequest with Cause radioNetwork: normal-release {
        findBy { has(xnap.SNodeReleaseRequest_element) }
        verifyBy { has(xnap.radioNetwork:=65) }}
"""
snode_rel_req_radio_network_radio_connection_with_ue_lost = """
    SNodeReleaseRequest with Cause radioNetwork: radio-connection-with-UE-lost {
        findBy { has(xnap.SNodeReleaseRequest_element) }
        verifyBy { has(xnap.radioNetwork:=36) }}
"""
snode_rel_req_ack = """
    SNodeReleaseRequestAcknowledge {
        findBy { has(xnap.SNodeReleaseRequestAcknowledge_element) }}
"""
ue_ctx_rel = """
    UEContextRelease {
        findBy { has(xnap.UEContextRelease_element) }}
"""
reset_req_partial_misc_om_intervention = """
    ResetRequest with Cause misc: o-and-M-intervention {
        findBy { has(xnap.ResetRequest_element) }
        verifyBy { has(xnap.partialReset_element)
                   has (xnap.misc:=2) }}
"""
reset_resp_partial_misc_om_intervention = """
    ResetRequest with Cause misc: o-and-M-intervention {
        findBy { has(xnap.ResetResponse_element) }
        verifyBy { has(xnap.partialReset_element) }}
"""
activity_notification_inactive = """
    ActivityNotification with UserPlaneTrafficActivityReport: inactive {
        findBy { has(xnap.ActivityNotification_element) }
        verifyBy { has(xnap.UserPlaneTrafficActivityReport:=0) }}
"""
activity_notification_reactivated = """
    ActivityNotification with UserPlaneTrafficActivityReport: re-activated {
        findBy { has(xnap.ActivityNotification_element) }
        verifyBy { has(xnap.UserPlaneTrafficActivityReport:=1) }}
"""
snode_modification_req = """
    SNodeModificationRequired {
        findBy { has(xnap.SNodeModificationRequired_element) }}
"""
