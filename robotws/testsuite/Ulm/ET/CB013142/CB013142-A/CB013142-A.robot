*** Settings ***

Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 04'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: This is a Robot Test Suite for sub-feature CB013142-A
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
...                             sCellIndex 1
...                             physCellId 53
...                             downlinkConfigCommon
...                             uplinkConfigCommon
...                             sCellIndex 2
...                             physCellId 54

@{PCELL_SWITCH_MSG_SEQ}         spCellConfig
...                             spCellConfigCommon
...                             physCellId 53
...                             frequencyInfoDL
...                             absoluteFrequencySSB ${CARRIER_FREQ_4}
...                             frequencyInfoUL

*** Test Cases ***
CB013142_A_ET_TC01_B1_SA_A2_meas_Config_on_PCell_for_PCell_change_using_meas_profile_based_on_UE_PC_during_SCell_addition
    [Documentation]
    ...   Main scenario: This test intends to verify configuration of A2 measurement on PCell for ‘PCell change’ using the selected measurement
    ...   profile based on effective UE power class (determined based on CB013392) during SCell addition procedure for an SA UE. A2 based
    ...   ‘PCell change’ is an inter-frequency handover with the current SCell as the target cell and applied when the SCell has bigger coverage
    ...   than the PCell and triggered when the PCell radio conditions degrade. 2 UEs are used for this test automation.
    ...   UE-2 supports pc2 for band combination n41&n71&66 and it selects measurement profile (NRMEASPR_MA_SA-4 points to NRMEASPR_IAF-20) because
    ...   it has pc2 as a selection criteria and effective power class i.e. effPcMeasProf calculated in C-Plane is pc2.
    ...   UE-3 does not define any power class supported for band combination n41&n71&66 and it selects measurement profile (NRMEASPR_MA_SA-9 points
    ...   to NRMEASPR_IAF-19) because it has pc3 as a selection criteria and effective power class i.e. effPcMeasProf calculated in C-Plane is pc3.
    [Tags]    A_B1
    [Setup]   Setup for CB013142-A-B1
    Set Test Variable    &{UE_IDs_to_index_mapping}
    ...    2=1
    ...    3=2
    Register and Establish PDU Session    ue_id=2
    Register and Establish PDU Session    ue_id=3    ue_nr_capabilities=${UE_CAPAB_5CC_PC2_NOT_SUPPORT}
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_1}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=20  ul_data=10
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE   carrier_freq=${CARRIER_FREQ_1}
    Verify whether UEs are configured with A2 Measurement event for the PCell Change   carrier_freq=${CARRIER_FREQ_1}
    Stop Data transfer and Deregister All UEs
    Collect and Verify PM Counters   test_instance=A_B1


CB013142_A_ET_TC02_B3_SA_Secondary_measurement_quantity_evaluation_on_PCell_using_meas_profile_based_on_UE_PC_during_A2_MR_reception_for_PCell_change
    [Documentation]
    ...   Main scenario: This test intends to verify that when A2 measurement for PCell change (NRBTS/NRCELL/a2MeasPCellSwitchEnabled) is
    ...   configured as ‘rsrpCombined’, upon receiving the A2 measurement report for PCell change gNB evaluates the secondary measurement
    ...   quantity included in the A2 measurement report using A2 measurement configuration from the measurement profile, which is selected
    ...   based on effective UE power class criterion. gNB ignores the measurement report, if the A2 event criteria is not fulfilled for
    ...   the RSRQ quantity.
    ...   UE-2 supports pc2 for band combination n41&n71&66 and it selects measurement profile (NRMEASPR_MA_SA-4 points to NRMEASPR_IAF-20) because
    ...   it has pc2 as a selection criteria and effective power class i.e. effPcMeasProf calculated in C-Plane is pc2.
    ...   UE-3 does not define any power class supported for band combination n41&n71&66 and it selects measurement profile (NRMEASPR_MA_SA-9 points
    ...   to NRMEASPR_IAF-19) because it has pc3 as a selection criteria and effective power class i.e. effPcMeasProf calculated in C-Plane is pc3.
    [Tags]    A_B3
    [Setup]   Setup for CB013142-A-B3
    Set Test Variable    &{UE_IDs_to_index_mapping}
    ...    2=1
    ...    3=2
    Register and Establish PDU Session    ue_id=2
    Register and Establish PDU Session    ue_id=3    ue_nr_capabilities=${UE_CAPAB_5CC_PC2_NOT_SUPPORT}
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_1}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=20  ul_data=10
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE   carrier_freq=${CARRIER_FREQ_1}
    Verify whether UEs are configured with A2 Measurement event for the PCell Change   carrier_freq=${CARRIER_FREQ_1}
    Send A2 MR and Verify PCELL switch did not happen   carrier_freq=${CARRIER_FREQ_1}
    Send A2 MR and Verify PCELL switch happened   carrier_freq=${CARRIER_FREQ_1}
    Stop Data transfer and Deregister All UEs
    Collect and Verify PM Counters   test_instance=A_B1