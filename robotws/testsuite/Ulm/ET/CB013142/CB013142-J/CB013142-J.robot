*** Settings ***

Documentation
...    Author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 04'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: This is a Robot Test Suite for sub-feature CB013142-J
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
...                             sCellIndex 6
...                             physCellId 50
...                             downlinkConfigCommon



@{A1_BASED_PCELL_SWITCH_MSG_SEQ}                spCellConfig
...                                             spCellConfigCommon
...                                             physCellId 50
...                                             frequencyInfoDL
...                                             absoluteFrequencySSB ${CARRIER_FREQ_1}
...                                             frequencyInfoUL

@{A2_BASED_SCELL_RELEASE_MSG_SEQ}               spCellConfig
...                                             spCellConfigDedicated
...                                             sCellToReleaseList

*** Test Cases ***

CB013142_J_ET_TC01_B3_NSA_Secondary_meas_quantity_eval_on_SCell_using_Meas_Profile_during_A2_MR_reception_for_SCell_Rel
    [Documentation]
    ...   Main scenario: This user scenario intends to verify that when A2 measurement for ‘SCell release’ (NRBTS/NRCELL/ a2MeasSCellRelEnabled)
    ...   is configured as ‘rsrpCombined’, upon receiving the A2 measurement report for ‘SCell release’ gNB evaluates the secondary measurement
    ...   quantity included in the A2 measurement report using A2 measurement configuration from the measurement profile. gNB ignores the
    ...   measurement report, if the A2 event criteria is not fulfilled for the RSRQ quantity.


    [Tags]    J_B3
    [Setup]   Setup for CB013142-J-B3
    Set Test Variable    &{UE_IDs_to_index_mapping}
    ...    14=1
    ...    21=2
    Attach Multiple UEs To LTE And Trigger LTE-NR Dual Connectivity    target_cells=4
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_4}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=150  ul_data=150  id=2
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE
    ...    carrier_freq=${CARRIER_FREQ_4}    meas_id=1    pass_regexp=rrcConnectionReconfigurationComplete
    Verify Whether UEs Are Configured With A2 Measurement Event For The SCell Release    carrier_freq=${CARRIER_FREQ_1}
    Display Multiple UEs Traffic Stats
    Send A2 MR And Verify SCELL Release Did Not Happened
    Send A2 MR and Verify SCELL Release Happened
    Display Multiple UEs Traffic Stats
    Stop Data transfer And Detach NSA UEs From 5G And 4G
    Collect and Verify PM Counters   test_instance=D_B2