*** Settings ***

Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 04'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: This is a Robot Test Suite for sub-feature CB013142-B
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
...                             physCellId 50
...                             downlinkConfigCommon
...                             uplinkConfigCommon
...                             sCellIndex 2
...                             physCellId 51


@{A1_BASED_PCELL_SWITCH_MSG_SEQ}                spCellConfig
...                                             spCellConfigCommon
...                                             physCellId 50
...                                             frequencyInfoDL
...                                             absoluteFrequencySSB 518910
...                                             frequencyInfoUL



*** Test Cases ***
CB013142_B_ET_TC01_B1_SA_A1_meas_Config_on_SCell_for_PCell_change_using_meas_profile_based_on_UE_PC_during_SCell_addition
    [Documentation]
    ...   Main scenario: This user scenario intends to verify configuration of A1 measurement on SCell(s) for ‘PCell change’ using the selected
    ...   measurement profile based on effective UE power class criterion during SCell addition procedure for an SA UE. A1 based ‘PCell change’
    ...   is an inter-frequency handover with the current SCell as the target cell and applied when the SCell has smaller coverage than the PCell
    ...   and triggered when the SCell radio conditions are good enough.1 UE is used for this test automation.

    [Tags]    B_B1
    [Setup]   Setup for CB013142-B-B1
    Set Test Variable    &{UE_IDs_to_index_mapping}
    ...    3=2
    Register and Establish PDU Session    ue_id=3
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_4}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=20  ul_data=10
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE   carrier_freq=${CARRIER_FREQ_4}
    Verify whether UEs are configured with A1 Measurement event for the PCell Change
    Stop Data transfer and Deregister All UEs
    Collect and Verify PM Counters   test_instance=B_B1

CB013142_B_ET_TC02_B2_SA_Secondary_measurement_quantity_evaluation_on_SCell_using_meas_profile_based_on_UE_PC_during_A1_MR_reception_for_PCell_change
    [Documentation]
    ...   Main scenario: This user scenario intends to verify that when A1 measurement for PCell change (NRBTS/NRCELL/a1MeasPCellSwitchEnabled) is
    ...   configured as ‘rsrpCombined’, upon receiving the A1 measurement report for PCell change gNB evaluates the secondary measurement quantity
    ...   included in the A1 measurement report using A1 measurement configuration from the measurement profile which is selected based on effective
    ...   UE power class criterion. gNB ignores the measurement report, if the A1 event criteria is not fulfilled for the RSRQ quantity.

    [Tags]    B_B2
    [Setup]   Setup for CB013142-B-B2
    Set Test Variable    &{UE_IDs_to_index_mapping}
    ...    3=2
    Register and Establish PDU Session    ue_id=3
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_4}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=20  ul_data=10
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE   carrier_freq=${CARRIER_FREQ_4}
    Verify whether UEs are configured with A1 Measurement event for the PCell Change
    Send A1 MR and Verify PCELL switch did not happen
    Send A1 MR and Verify PCELL switch happened
    Stop Data transfer and Deregister All UEs
    Collect and Verify PM Counters   test_instance=B_B1