*** Settings ***

Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 04'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: This is a Robot Test Suite for sub-feature CB013142-C
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
...                             physCellId 53
...                             downlinkConfigCommon


@{PCELL_SWITCH_MSG_SEQ}         spCellConfig
...                             spCellConfigCommon
...                             physCellId 53
...                             frequencyInfoDL
...                             absoluteFrequencySSB ${CARRIER_FREQ_4}
...                             frequencyInfoUL

*** Test Cases ***
CB013142_C_ET_TC02_B2_NSA_Secondary_measurement_quantity_evaluation_on_PSCell_using_meas_profile_during_A2_MR_reception_for_PSCell_change
    [Documentation]
    ...   Main scenario: This test intends to verify that when A2 measurement for PSCell change (NRBTS/NRCELL/a2MeasPCellSwitchEnabled) is configured
    ...   as ‘rsrpCombined’, upon receiving the A2 measurement report for PSCell change gNB evaluates the secondary measurement quantity included in
    ...   the A2 measurement report using A2 measurement configuration from the measurement profile, which is selected based on one or more criteria.
    ...   gNB ignores the measurement report, if the A2 event criteria is not fulfilled for the RSRQ quantity.
    ...   UE-14 selects measurement profile (NRMEASPR_MA_NSA-3 points to NRMEASPR_IAF-43) based on PLMN criteria.
    ...   UE-21 & 22 select measurement profile (NRMEASPR_MA_NSA-10 points to NRMEASPR_IAF-20) based on spid criteria.
    ...   UE-23 & 24 support pc2 for PCELL band n41 and they select measurement profile (NRMEASPR_MA_NSA-12 points to NRMEASPR_IAF-19) because
    ...   it has pc2 as a selection criteria and effective power class i.e. effPcMeasProf calculated in C-Plane is pc2.
    [Tags]    C_B2
    [Setup]   Setup for CB013142-C-B2
    Set Test Variable    &{UE_IDs_to_index_mapping}
    ...    14=2
    ...    21=1
    ...    22=1
    ...    23=2
    ...    24=2
    Attach Multiple UEs To LTE And Trigger LTE-NR Dual Connectivity
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_1}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=150  ul_data=150  id=2
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE
    ...    carrier_freq=${CARRIER_FREQ_1}    meas_id=1    pass_regexp=rrcConnectionReconfigurationComplete
    Verify whether UEs are configured with A2 Measurement event for the PCell Change   carrier_freq=${CARRIER_FREQ_1}
    ...    report_id=2    measid=2
    Display Multiple UEs Traffic Stats
    Send A2 MR and Verify PCELL switch did not happen   carrier_freq=${CARRIER_FREQ_1}    scell_1_meas=scell=6 scell_rsrp=70 scell_rsrq=70
    ...    scell_2_meas=${EMPTY}    meas_id=2
    Send A2 MR and Verify PCELL switch happened   carrier_freq=${CARRIER_FREQ_1}    scell_1_meas=scell=6 scell_rsrp=70 scell_rsrq=70
    ...    scell_2_meas=${EMPTY}    meas_id=2    pass_regexp=rrcConnectionReconfigurationComplete
    Display Multiple UEs Traffic Stats
    Stop Data transfer And Detach NSA UEs From 5G And 4G
    Collect and Verify PM Counters   test_instance=C_B2