*** Settings ***

Documentation
...    author: VRF ULM T01 01
...    Team: 'MN RAN RD VRF ULM 1'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_1_53028392@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB013859-A
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

@{CA_MSG_SEQ}                       @{EMPTY}

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

*** Test Cases ***

CB013859_A_SE_TC03_B4_UE_connection_setup_multiple_slices_all_supp_by_scells
    [Documentation]
    ...   This user scenarios describe the successful carrier aggregation configuration for the UE with PDU sessions with multiple slices, where
    ...   all slices are supported by SCells. UE is configured with SCells supporting the special slice.
    ...   UE-1: PDU sessions setup with multiple S-NSSAI equal to (sst1, sd1) and (sst2, sd2) requested together with initial context setup
    ...   procedure.
    [Tags]    A_B4
    CB013859_Commissioning.Apply Configs For A_B3    test_instance=A_B4
    pmcounters.Wait Until The Next Measurement Period Starts
    wts_ue.UE Register   ue_id=1
    CB013859_Keywords.Establish PDU Session   ue_id=1   pdu_id=1   nwslice=1
    CB013859_Keywords.Establish PDU Session   ue_id=1   pdu_id=2   nwslice=2   pass_regexp=Pdu Session.*successfully
    CB013859_Keywords.Verify A1 Measurement Event Configured And Confirm That UE Is Configured With CA After Sending A1 MR
    ...    ue_id=1
    ...    carrier_freq=${NRCELL-1.arfcnSsbPbch}
    ...    srsrp_nr=70
    ...    ca_msg_verify=@{CA_MSG_SEQ_4CC_DLUL_TDD_PCell}
    ...    CA_cell_configuration=4CC DL CA with Cell-2, Cell-7 and Cell-10 as SCells and 2CC UL CA with Cell-10 as SCell
    ...    PCell_info=_PCell_Cell-${NRCELL-1.lcrId}
    CB013859_Keywords.Start DL UL Data Traffic On 2 PDU Sessions   ue_id=1
    CB013859_Keywords.Collect And Verify PM Counters For SA   test_instance=A_B4
    CB013859_Keywords.Stop DL UL Data Traffic On 2 PDU Sessions And Deregister UE   ue_id=1

CB013859_A_SE_TC04_B6_UE_conn_setup_PDU_single_slice_new_PDU_unsupp_slice_some_scells
    [Documentation]
    ...   This user scenario describes the successful configuration for the new PDU session of CA UE, where the slice of new PDU session is not
    ...   supported by some SCells.
    ...   UE-1: PDU session(s) setup with single S-NSSAI equal to (sst1, sd1) is requested together with initial context setup procedure.
    ...   Then two more PDU sessions are setup (subsequent), with single S-NSSAI equal to (sst3, sd3) and (sst5, sd5), respectively.
    [Tags]    A_B6
    CB013859_Commissioning.Apply Configs For A_B6    test_instance=A_B6
    pmcounters.Wait Until The Next Measurement Period Starts
    wts_ue.UE Register   ue_id=1
    CB013859_Keywords.Establish PDU Session   ue_id=1   pdu_id=1   nwslice=1
    CB013859_Keywords.Verify A1 Measurement Event Configured And Confirm That UE Is Configured With CA After Sending A1 MR
    ...    ue_id=1
    ...    carrier_freq=${NRCELL-1.arfcnSsbPbch}
    ...    srsrp_nr=70
    ...    ca_msg_verify=@{CA_MSG_SEQ_4CC_DLUL_TDD_PCell}
    ...    CA_cell_configuration=4CC DL CA with Cell-2, Cell-7 and Cell-10 as SCells and 2CC UL CA with Cell-10 as SCell
    ...    PCell_info=_PCell_Cell-${NRCELL-1.lcrId}
    CB013859_Keywords.Start DL UL Data Traffic On Single PDU Session   ue_id=1   pdu=1
    CB013859_Keywords.Establish PDU Session   ue_id=1   pdu_id=2   nwslice=3   pass_regexp=Pdu Session.*successfully
    CB013859_Keywords.Start DL UL Data Traffic On Single PDU Session   ue_id=1   pdu=2
    wts_ue.UE PDU Session Release   ue_id=1   pdu=1
    CB013859_Keywords.Establish PDU Session   ue_id=1   pdu_id=3   nwslice=5   pass_regexp=Pdu Session.*successfully
    CB013859_Keywords.Start DL UL Data Traffic On Single PDU Session   ue_id=1   pdu=3
    CB013859_Keywords.Collect And Verify PM Counters For SA   test_instance=A_B6
    CB013859_Keywords.Stop DL UL Data Traffic On 3 PDU Sessions And Deregister UE   ue_id=1
