*** Settings ***

Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 04'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: This is a Robot Test Suite for sub-feature CB013142-D
...    Tested on: CLOUD_5G_I_MP_AP_LOOO   STATE_CONFIGURED
...    Private variant: VARIANT_PRIVATE_SANSA_CMWV_TDD_FDD_CA_5CCDL_2CCUL

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Resource                        ../CB013142_Keywords.robot
Resource                        ../CB013142_Commissioning.robot
Resource                        ../CB013142_PM.robot

Suite Setup                     Prepare TL for CB013142
Suite Teardown                  Sqd65 Common Teardown

Test Setup                      Perform Preconditions of Test Scenario
Test Teardown                   Perform Postconditions of Test Case

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



*** Test Cases ***

CB013142_D_ET_TC02_B2_NSA_Secondary_measurement_quantity_evaluation_on_SCell_using_meas_profile_during_A1_MR_reception_for_PSCell_change
    [Documentation]
    ...   Main scenario: This test intends to verify that when A1 measurement for PSCell change (NRBTS/NRCELL/a1MeasPCellSwitchEnabled) is configured
    ...   as ‘rsrpCombined’, upon receiving the A1 measurement report for PSCell change gNB evaluates the secondary measurement quantity included in
    ...   the A1 measurement report using A1 measurement configuration from the measurement profile, which is selected based on one or more
    ...   criteria.gNB ignores the measurement report, if the A1 event criteria is not fulfilled for the RSRQ quantity.


    [Tags]    D_B2
    [Setup]   Setup for CB013142-D-B2
    Set Test Variable    &{UE_IDs_to_index_mapping}
    ...    21=2
    ...    23=1
    Attach Multiple UEs To LTE And Trigger LTE-NR Dual Connectivity    target_cells=4
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_4}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=150  ul_data=150  id=2
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE
    ...    carrier_freq=${CARRIER_FREQ_4}    meas_id=1    pass_regexp=rrcConnectionReconfigurationComplete
    Verify whether UEs are configured with A1 Measurement event for the PCell Change for NSA UEs    carrier_freq=${CARRIER_FREQ_1}
    Display Multiple UEs Traffic Stats
    Send A1 MR and Verify PCELL switch did not happen for NSA UEs
    Send A1 MR and Verify PCELL switch happened for NSA UEs    pass_regexp=rrcConnectionReconfigurationComplete
    Display Multiple UEs Traffic Stats
    Stop Data transfer And Detach NSA UEs From 5G And 4G
    Collect and Verify PM Counters   test_instance=D_B2