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

CB013142_F_ET_TC03_B5_SA_Secondary_meas_quantity_eval_using_Meas_Profile_during_A1_MR_reception_for_SCell_add
    [Documentation]
    ...   Main scenario: This user scenario intends to verify that when A1 measurement for SCell addition (NRBTS/NRCELL/ a1MeasSCellAddEnabled)
    ...   is configured as ‘rsrpCombined’, upon receiving the A1 measurement report for ‘SCell addition’, gNB evaluates the secondary
    ...   measurement quantity included in the A1 measurement report using A1 measurement configuration from the measurement profile.
    ...   gNB ignores the measurement report, if the A1 event criteria is not fulfilled for the RSRQ quantity.


    [Tags]    F_B5
    [Setup]   Setup For CB013142-F-B5
    Set Test Variable    &{UE_IDs_to_index_mapping}
    ...    5=1
    Register And Establish PDU Session    ue_id=5    rfsp=35
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_5}
    Verify Whether UEs Are Configured With A4 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_3}
    Initiate Both Uplink And Downlink Data Traffic On UEs   dl_data=150  ul_data=150
    Display Multiple UEs Traffic Stats
    Run Keyword And Ignore Error    Send A1 MR For Scell Addition And Verify Whether A1 And A4 Measurements Are Still Configured At The UE
    ...    carrier_freq_1=${CARRIER_FREQ_5}    carrier_freq_2=${CARRIER_FREQ_3}    srsrp_nr=85    srsrq_nr=80
    Run Keyword And Ignore Error    Send A1 MR For Scell Addition And Verify Whether A1 And A4 Measurements Are Still Configured At The UE
    ...    carrier_freq_1=${CARRIER_FREQ_5}    carrier_freq_2=${CARRIER_FREQ_3}    srsrp_nr=86    srsrq_nr=80
    ${meas_id_a1}    Get NR Measurement IDs   event_type=A1  ue_id=5  carrier_freq=${CARRIER_FREQ_5}
    ${meas_id_a4}    Get NR Measurement IDs   event_type=A4  ue_id=5  carrier_freq=${CARRIER_FREQ_3}
    Send A1 MR For Scell Addition And Verify Whether GNB Configures CA And Deconfigures A1 Measurement At The UE
    ...    carrier_freq=${CARRIER_FREQ_5}    meas_id=${meas_id_a1}[0]    srsrp_nr=86    srsrq_nr=81
    Verify Whether GNB Deconfigures A4 Measurement At The UE   carrier_freq=${CARRIER_FREQ_3}
    Display Multiple UEs Traffic Stats
    Stop Data Transfer And Deregister All UEs
    Collect And Verify PM Counters   test_instance=F_B5
