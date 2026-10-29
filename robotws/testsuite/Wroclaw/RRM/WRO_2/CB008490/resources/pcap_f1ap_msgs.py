ue_ctx_setup_req = """
    UEContextSetupRequest  {
        findBy { has(f1ap.UEContextSetupRequest_element) }}
"""
ue_ctx_setup_req_8cc = """
    UEContextSetupRequest  {
        findBy { has(f1ap.UEContextSetupRequest_element) }
        verifyBy { has(f1ap.SCell_ToBeSetup_List:=7)
                   has(nr-rrc.allowedBC_ListMRDC:=1) }}
"""
ue_ctx_setup_resp = """
    UEContextSetupResponse {
        findBy { has(f1ap.UEContextSetupResponse_element) }}
"""
ue_ctx_setup_resp_8cc = """
    SN UEContextSetupResponse {
        findBy { has(f1ap.UEContextSetupResponse_element) }
        verifyBy { has(f1ap.SelectedBandCombinationIndex)
                   has(f1ap.SelectedFeatureSetEntryIndex)
                   has(nr-rrc.sCellToAddModList:=7) }}
"""
ue_ctx_mod_req = """
    UEContextModificationRequest  {
        findBy { has(f1ap.UEContextModificationRequest_element) }}
"""
ue_ctx_mod_req_allowedbc_listmrdc = """
    UEContextModificationRequest  {
        findBy { has(f1ap.UEContextModificationRequest_element) }
        verifyBy { has(nr-rrc.allowedBC_ListMRDC) }}
"""
ue_ctx_mod_req_scg_release = """
    UEContextModificationRequest with SCGIndicator: released  {
        findBy { has(f1ap.UEContextModificationRequest_element) }
        verifyBy { has(f1ap.SCGIndicator:=0) }}
"""
ue_ctx_mod_req_rrc_reconfig_complete_ind = """
    UEContextModificationRequest  {
        findBy { has(f1ap.UEContextModificationRequest_element) }
        verifyBy { has(f1ap.RRCReconfigurationCompleteIndicator:=0) }}
"""
ue_ctx_mod_req_du_config_query = """
    UEContextModificationRequest with DUConfigurationQuery: true  {
        findBy { has(f1ap.UEContextModificationRequest_element) }
        verifyBy { has(f1ap.GNB_DUConfigurationQuery:=0) }}
"""
ue_ctx_mod_resp = """
    UEContextModificationResponse {
        findBy { has(f1ap.UEContextModificationResponse_element) }}
"""
ue_ctx_mod_resp_bc_idx_fs_idx = """
    UEContextModificationResponse {
        findBy { has(f1ap.UEContextModificationResponse_element) }
        verifyBy { has(f1ap.SelectedBandCombinationIndex)
                   has (f1ap.SelectedFeatureSetEntryIndex) }}
"""
ue_ctx_mod_resp_dutocurrcinfo = """
    UEContextModificationResponse {
        findBy { has(f1ap.DUtoCURRCInformation_element) }}
"""
ue_ctx_mod_req_stop = """
    UEContextModificationRequest with TransmissionActionIndicator = stop {
        findBy { has(f1ap.UEContextModificationRequest_element) }
        verifyBy { has(f1ap.TransmissionActionIndicator:=0) }}
"""
ue_ctx_rel_command_radio_network_normal_release = """
    UEContextReleaseCommand has radioNetwork == normal-release  {
        findBy { has(f1ap.UEContextReleaseCommand_element) }
        verifyBy { has(f1ap.radioNetwork:=10) }}
"""
ue_ctx_rel_command_radio_network_unspecified = """
    UEContextReleaseCommand has radioNetwork == unspecified  {
        findBy { has(f1ap.UEContextReleaseCommand_element) }
        verifyBy { has(f1ap.radioNetwork:=0) }}
"""
ue_ctx_rel_complete = """
    UEContextReleaseComplete {
        findBy { has(f1ap.UEContextReleaseComplete_element) }}
"""
reset_partial_transport_unspecified = """
    Reset has Cause transport: unspecified   {
        findBy { has(f1ap.Reset_element) }
        verifyBy { has(f1ap.partOfF1_Interface)
                   has(f1ap.transport:=0) }}
"""
reset_partial_misc_om_intervention = """
    Reset has Cause misc: om-intervention {
        findBy { has(f1ap.Reset_element) }
        verifyBy { has(f1ap.partOfF1_Interface)
                   has(f1ap.misc:=3) }}
"""
reset_ack = """
    ResetAcknowledge {
        findBy { has(f1ap.ResetAcknowledge_element) }
        verifyBy { has(f1ap.UE_associatedLogicalF1_ConnectionListResAck) }}
"""
