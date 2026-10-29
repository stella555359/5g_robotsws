*** Settings ***

Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 4'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB013859-D
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

@{CA_MSG_SEQ_2CC_DL_TDD_PCell}      sCellToAddModList
...                                 sCellIndex 1
...                                 physCellId 57
...                                 downlinkConfigCommon

*** Test Cases ***

CB013859_D_SE_TC01_IWK1_Interworking_with_CB013052_PDU_session_for_non-configured_slice
    [Documentation]
    ...   This user scenario describes the successful carrier aggregation configuration for the UE with PDU sessions
    ...   with the slice which is not supported by PCell.
    ...   UE is configured with SCells if SCell supports the default slice and the default slice is ‘singleSliceUE’.
    [Tags]    D_IWK1
    CB013859_Commissioning.Apply Configs For D_IWK1    test_instance=D_IWK1
    pmcounters.Wait Until The Next Measurement Period Starts
    wts_ue.UE Register   ue_id=1
    CB013859_Keywords.Establish PDU Session   ue_id=1   pdu_id=1   nwslice=4
    CB013859_Keywords.Verify A1 Measurement Event Configured And Confirm That UE Is Configured With CA After Sending A1 MR
    ...    ue_id=1
    ...    carrier_freq=${NRCELL-1.arfcnSsbPbch}
    ...    srsrp_nr=70
    ...    ca_msg_verify=@{CA_MSG_SEQ_2CC_DL_TDD_PCell}
    ...    CA_cell_configuration=2CC DL CA with Cell-10 as SCell and 2CC UL CA with Cell-10 as SCell
    ...    PCell_info=_PCell_Cell-${NRCELL-1.lcrId}
    CB013859_Keywords.Start DL UL Data Traffic On Single PDU Session   ue_id=1   pdu=1
    CB013859_Keywords.Collect And Verify PM Counters For SA   test_instance=D_IWK1
    CB013859_Keywords.Stop SA Data Traffic In Egate On Multiple Traffic IDs
    ...    ue_id=1   trf_id_range_min=1   trf_id_range_max=3   direction=dl   pdu=1
    CB013859_Keywords.Stop SA Data Traffic In Egate On Multiple Traffic IDs
    ...    ue_id=1   trf_id_range_min=4   trf_id_range_max=6   direction=ul   pdu=1
    wts_ue.UE Deregister  ue_id=1
