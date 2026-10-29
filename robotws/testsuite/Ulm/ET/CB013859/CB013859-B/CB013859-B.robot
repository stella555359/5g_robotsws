*** Settings ***

Documentation
...    author: VRF ULM T01 01
...    Team: 'MN RAN RD VRF ULM 1'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_1_53028392@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB013859-B
...    Tested on: CLOUD_5G_I_LOO_AP_LOOO   STATE_CONFIGURED
...    TMO variant: VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource   ../CB013859_Keywords.robot

Suite Setup       CB013859_Keywords.Prepare TL For CB013859
Suite Teardown    sqd65_keywords.Sqd65 Common Teardown

Test Setup        CB013859_Keywords.Perform Preconditions Of Test Scenario
Test Teardown     CB013859_Keywords.Perform Postconditions Of Test Case

*** Variables ***

${TEST_MODE}                        auto
${NRCELL-1.arfcnSsbPbch}            520110
${NRCELL-2.arfcnSsbPbch}            502110
${NRCELL-7.arfcnSsbPbch}            396970
${NRCELL-10.arfcnSsbPbch}           125290
${NRCELL-4.arfcnSsbPbch}            502110
${NRCELL-1.lcrId}                   1
${NRCELL-7.lcrId}                   7

@{CA_MSG_SEQ}                       @{EMPTY}

@{CA_MSG_SEQ_4CC_DL_FDD_PCell}      sCellToAddModList
...                                 sCellIndex 1
...                                 physCellId 51
...                                 downlinkConfigCommon
...                                 sCellIndex 2
...                                 physCellId 52
...                                 downlinkConfigCommon
...                                 sCellIndex 3
...                                 physCellId 60
...                                 downlinkConfigCommon

@{CA_MSG_SEQ_4CC_DL_TDD_PCell}      sCellToAddModList
...                                 sCellIndex 1
...                                 physCellId 52
...                                 downlinkConfigCommon
...                                 sCellIndex 2
...                                 physCellId 57
...                                 downlinkConfigCommon
...                                 sCellIndex 3
...                                 physCellId 60
...                                 downlinkConfigCommon

@{CA_MSG_SEQ_4CC_DLUL_TDD_PCell}    sCellToAddModList
...                                 sCellIndex 1
...                                 physCellId 52
...                                 downlinkConfigCommon
...                                 sCellIndex 2
...                                 physCellId 57
...                                 downlinkConfigCommon
...                                 sCellIndex 3
...                                 physCellId 60
...                                 downlinkConfigCommon
...                                 uplinkConfigCommon

@{CA_MSG_SEQ_RELEASE}               sCellToReleaseList

*** Test Cases ***

CB013859_B_SE_TC05_IWK_1_interworking_A1_based_PCell_change
    [Documentation]
    ...   This user scenario describes the successful A1 based PCell change for the CA UE with PDU sessions with single slice.
    ...   After inter-frequency handover to the configured SCell as the target cell, SCells can be added to UE. UE is configured with SCells
    ...   supporting the special slice.
    ...   UE-1: Intially attached to the FDD Cell-7 as PCell and PDU session(s) setup with single S-NSSAI equal to (sst1, sd1) is
    ...   requested together with initial context setup procedure. 4CC CA is configured with A1 MR: Cell-1, Cell-2 and Cell-10 added as SCells.
    ...   Then A1 MR based PCell change is triggered and UE gets attached to one of the SCells: FR1 TDD Cell-1. 4CC CA is configured with
    ...   A1 MR: Cell-2, Cell-7 and Cell-10 added as SCells.
    [Tags]    B_IWK1
    [Setup]   CB013859_Keywords.Setup For CB013859-B_IWK1
    pmcounters.Wait Until The Next Measurement Period Starts
    wts_ue.UE Register   ue_id=1
    CB013859_Keywords.Establish PDU Session   ue_id=1   pdu_id=1   nwslice=1
    CB013859_Keywords.Verify A1 Measurement Event Configured And Confirm That UE Is Configured With CA After Sending A1 MR
    ...    ue_id=1
    ...    carrier_freq=${NRCELL-7.arfcnSsbPbch}
    ...    srsrp_nr=70
    ...    ca_msg_verify=@{CA_MSG_SEQ_4CC_DL_FDD_PCell}
    ...    CA_cell_configuration=4CC DL CA with Cell-1, Cell-2 and Cell-10 as SCells
    ...    PCell_info=_PCell_Cell-${NRCELL-7.lcrId}
    CB013859_Keywords.Start SA Data Traffic In Egate On Multiple Traffic IDs
    ...    ue_id=1   trf_id_range_min=1   trf_id_range_max=6   direction=dl   mbps=175   pdu=1
    Sleep   10s  reason=wait for AP to start DL data for all trf_ids
    CB013859_Keywords.Verify A1 Measurement Event Configured On TDD-SCell For The PCell Change   ue_id=1   carrier_freq=${NRCELL-1.arfcnSsbPbch}
    CB013859_Keywords.Send A1 MR And Verify PCell Switch And SCells Release Happened
    ...    ue_id=1   carrier_freq=${NRCELL-1.arfcnSsbPbch}   scell=1   scell_rsrp=70
    CB013859_Keywords.Verify A1 Measurement Event Configured And Confirm That UE Is Configured With CA After Sending A1 MR
    ...    ue_id=1
    ...    carrier_freq=${NRCELL-1.arfcnSsbPbch}
    ...    srsrp_nr=70
    ...    ca_msg_verify=@{CA_MSG_SEQ_4CC_DL_TDD_PCell}
    ...    CA_cell_configuration=4CC DL CA with Cell-2, Cell-7 and Cell-10 as SCells
    ...    PCell_info=_PCell_Cell-${NRCELL-1.lcrId}
    CB013859_Keywords.Collect And Verify PM Counters For SA   test_instance=B_IWK1   pcell=${None}
    CB013859_Keywords.Stop SA Data Traffic In Egate On Multiple Traffic IDs
    ...    ue_id=1   trf_id_range_min=1   trf_id_range_max=6   direction=dl   pdu=1
    [Teardown]   CB013859_Keywords.Teardown For CB013859-B_IWK1

CB013859_B_SE_TC10_IWK_7_interworking_A4_based_Scell_addition
    [Documentation]
    ...   This user scenario describes the successful carrier aggregation configuration for the UE with PDU sessions with single slice.
    ...   A4 based SCell addition and buffer-based SCell addition are activated.
    ...   UE-1: PDU session(s) setup with single S-NSSAI equal to (sst1, sd1) is requested together with initial context setup procedure.
    ...   gNB configures A4 measurement for SCell addition, and a4 Supervision Timer is started for the UE. UE-1 moves to the coverage of Cell-2,
    ...   Cell-7 and Cell-10, one after the other, with RSRP and RSRQ above threshold and triggers A4 Measurement Report for SCell Addition, while
    ...   A4 supervision timer is still running. After sufficient data rate is triggered for gNB-DU to trigger DL Buffer Overflow notification,
    ...   SCell addition of the three SCells are triggered, respectively.
    [Tags]    B_IWK7
    CB013859_Commissioning.Apply Configs For B_IWK7    test_instance=B_IWK7
    pmcounters.Wait Until The Next Measurement Period Starts
    wts_ue.UE Register   ue_id=1
    CB013859_Keywords.Establish PDU Session For B_IWK7   ue_id=1   pdu_id=1   nwslice=1
    CB013859_Keywords.Verify A4 Measurement Event Configured And Send A4 MR For All Candidate SCells
    CB013859_Keywords.Start SA Data Traffic In Egate On Multiple Traffic IDs
    ...    ue_id=1   trf_id_range_min=1   trf_id_range_max=8   direction=dl   mbps=175   pdu=1
    Sleep   10s  reason=wait for AP to start DL data for all trf_ids
    Set Suite Variable    @{CA_MSG_SEQ}   @{CA_MSG_SEQ_4CC_DL_TDD_PCell}
    wts_ue.Send Egate Command And Verify Output    set_log flush
    CB013859_Keywords.Verify SCELL Addition For UE In RRC Reconfiguration
    ...    Rrc_file_path=${EGATE_CONSOLE_LOG}
    ...    CA_cell_configuration=4CC DL CA with Cell-2, Cell-7 and Cell-10 as SCells
    CB013859_Keywords.Collect And Verify PM Counters For SA   test_instance=B_IWK7
    CB013859_Keywords.Stop SA Data Traffic In Egate On Multiple Traffic IDs
    ...    ue_id=1   trf_id_range_min=1   trf_id_range_max=8   direction=dl   pdu=1
    wts_ue.UE Deregister  ue_id=1

CB013859_B_SE_TC11_IWK_9_slice_online_modif_with_none_Scell_candidate_filter_procedure_new_PDU_setup
    [Documentation]
    ...   This user scenario describes the slice online modification with none SCell candidates filter procedure. The new slice information should
    ...   not apply to non SCell candidates filter procedure, e.g. new PDU session setup with CA UE.
    ...   UE-1: Intially attached to the TDD Cell-1 as PCell and PDU sessions setup with multiple S-NSSAI equal to (sst1, sd1) and (sst3, sd3)
    ...   requested together with initial context setup procedure. 4CC CA is configured with A1 MR: Cell-2, Cell-7 and Cell-10 (DL and UL) added
    ...   as SCells. Online modification of Slice-1: NRBTS/SNSSAI-1.applicationType is set to 'disabled'. Another PDU session (PDU-3) is setup
    ...   with slice equal to (sst5, sd5) and 4CC CA call should continue.
    [Tags]    B_IWK9
    ${DELTA_COMMISSIONING}=  Set Variable  _Slice-1_applicationType_enabled
    CB013859_Commissioning.Apply Delta Config For B_IWK9  test_instance=B_IWK9  action=${DELTA_COMMISSIONING}
    pmcounters.Wait Until The Next Measurement Period Starts
    wts_ue.UE Register   ue_id=1
    CB013859_Keywords.Establish PDU Session   ue_id=1   pdu_id=1   nwslice=1
    CB013859_Keywords.Establish PDU Session   ue_id=1   pdu_id=2   nwslice=3   pass_regexp=Pdu Session.*successfully
    CB013859_Keywords.Verify A1 Measurement Event Configured And Confirm That UE Is Configured With CA After Sending A1 MR
    ...    ue_id=1
    ...    carrier_freq=${NRCELL-1.arfcnSsbPbch}
    ...    srsrp_nr=70
    ...    ca_msg_verify=@{CA_MSG_SEQ_4CC_DLUL_TDD_PCell}
    ...    CA_cell_configuration=4CC DL CA with Cell-2, Cell-7 and Cell-10 as SCells and 2CC UL CA with Cell-10 as SCell
    ...    PCell_info=_PCell_Cell-${NRCELL-1.lcrId}
    CB013859_Keywords.Start DL UL Data Traffic On 2 PDU Sessions   ue_id=1
    CB013859_Keywords.Collect And Verify PM Counters For SA  test_instance=B_IWK9  dual_delta_commissioning=${DELTA_COMMISSIONING}
    ${DELTA_COMMISSIONING}=  Set Variable  _Slice-1_applicationType_disabled
    CB013859_Commissioning.Apply Delta Config For B_IWK9  test_instance=B_IWK9  action=${DELTA_COMMISSIONING}
    pmcounters.Wait Until The Next Measurement Period Starts
    CB013859_Keywords.Establish PDU Session   ue_id=1   pdu_id=3   nwslice=5   pass_regexp=Pdu Session.*successfully
    CB013859_Keywords.Start DL UL Data Traffic On Single PDU Session   ue_id=1   pdu=3
    CB013859_Keywords.Collect And Verify PM Counters For SA  test_instance=B_IWK9  dual_delta_commissioning=${DELTA_COMMISSIONING}
    CB013859_Keywords.Stop DL UL Data Traffic On 3 PDU Sessions And Deregister UE   ue_id=1
