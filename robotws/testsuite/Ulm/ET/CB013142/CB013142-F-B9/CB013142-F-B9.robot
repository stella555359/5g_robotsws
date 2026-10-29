*** Settings ***

Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 04'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: This is a Robot Test Suite for sub-feature CB013142-F
...    Tested on: CLOUD_5G_I_MP_AP_LOOO   STATE_CONFIGURED
...    Private variant: VARIANT_PRIVATE_SANSA_CMWV_TDD_FDD_CA_5CCDL_2CCUL

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Resource                        ../CB013142_Keywords.robot
Resource                        ../CB013142_Commissioning.robot
Resource                        ../CB013142_PM.robot

Suite Setup                     Prepare TL For CB013142
Suite Teardown                  Sqd65 Common Teardown

Test Setup                      Perform Preconditions Of Test Scenario
Test Teardown                   Perform Postconditions Of Test Case

*** Variables ***
@{CA_MSG_SEQ}                   sCellToAddModList
...                             sCellIndex 1
...                             physCellId 50
...                             downlinkConfigCommon
...                             sCellIndex 2
...                             physCellId 53
...                             downlinkConfigCommon



@{A1_BASED_PCELL_SWITCH_MSG_SEQ}                spCellConfig
...                                             spCellConfigCommon
...                                             physCellId 50
...                                             frequencyInfoDL
...                                             absoluteFrequencySSB ${CARRIER_FREQ_1}
...                                             frequencyInfoUL



*** Test Cases ***

CB013142_F_ET_TC07_B9_SA_Threshold_criteria_based_SCell_add_based_on_mobility_meas_results_during_HO_using_Meas_Profile
    [Documentation]
    ...   Main scenario: This user scenario intends to verify checking of A1 criteria for SCell addition using the selected measurement profile
    ...   when the SCell addition is triggered by HO completion as NRBTS.actHoOptimizationCa is activated and the UE reported target cell
    ...   measurement result (RSRP/RSRQ as per NRCELL/a1MeasSCellAddEnabled) fulfils the threshold criteria of the A1 event for SCell addition.
    ...   The mapping criteria can be S-NSSAI (slice)


    [Tags]    F_B9
    [Setup]   Setup For CB013142-F-B9
    Set Test Variable    &{UE_IDs_to_index_mapping}
    ...    6=1
    CB013142_Keywords.Register And Establish PDU Session    ue_id=6    rfsp=35
    CB013142_Keywords.Initiate Both Uplink And Downlink Data Traffic On UEs   dl_data=150  ul_data=150
    CB013142_Keywords.Display Multiple UEs Traffic Stats
    ${meas_id_a2}    Get NR Measurement IDs   event_type=A2  ue_id=6  carrier_freq=${CARRIER_FREQ_6}
    wts_ue.Send Egate Command and verify output    cmd=ue_measurement_send_nr id=6 meas_id=${meas_id_a2}[0] event=A2 rs_type=ssb srsrp_nr=5
    ${meas_id_a3}    Get NR Measurement IDs   event_type=A3  ue_id=6  carrier_freq=${CARRIER_FREQ_5}
    wts_ue.Send Egate Command and verify output
    ...    cmd=ue_measurement_send_nr id=6 meas_id=${meas_id_a3}[0] event=A3 srsrp_nr=5 phycell_id=54 nrsrp_nr=95
    Sleep   3s  Reason=Waiting for RRC to finish
    sqd65_keywords.Verify Measurement ID Is Absent        event_type=A3  ue_id=6  carrier_freq=${CARRIER_FREQ_6}
    sqd65_keywords.Verify Measurement ID Is Absent        event_type=A1  ue_id=6  carrier_freq=${CARRIER_FREQ_5}
    sqd65_keywords.Verify Measurement ID Is Configured    event_type=A3  ue_id=6  carrier_freq=${CARRIER_FREQ_5}
    sqd65_keywords.Verify Measurement ID Is Configured    event_type=A2  ue_id=6  carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Display Multiple UEs Traffic Stats
    CB013142_Keywords.Stop Data Transfer And Deregister All UEs
    CB013142_Keywords.Collect And Verify PM Counters   test_instance=F_B9
