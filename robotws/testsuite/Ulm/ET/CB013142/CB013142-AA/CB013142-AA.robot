*** Settings ***

Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 04'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: This is a Robot Test Suite for sub-feature CB013142-AA
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

@{PCELL_SWITCH_MSG_SEQ}         spCellConfig
...                             spCellConfigCommon
...                             physCellId 53
...                             frequencyInfoDL
...                             absoluteFrequencySSB ${CARRIER_FREQ_4}
...                             frequencyInfoUL


*** Test Cases ***

CB013142_AA_ET_TC01_B1_SA_A2_meas_Config_on_PCell_for_PCell_change_using_criteria_except_UE_PC_based_meas_prof_during_SCell_addition
    [Documentation]   Main Scenario: This test instance verifies the configuration of A2 measurement on PCell for ‘PCell change’ using the selected
    ...   measurement  profile based on one or more criteria (except UE power class) during SCell addition procedure for an SA UE.
    ...   7 UEs are used for this test automation.
    ...   UE-1 selects measurement profile (NRMEASPR_MA_SA-67 points to NRMEASPR_IAF-43) based on PLMN criteria.
    ...   UE-2 and UE-5 select measurement profile (NRMEASPR_MA_SA-4 points to NRMEASPR_IAF-20) based on RFSP criteria.
    ...   UE-3 and UE-6 select measurement profile (NRMEASPR_MA_SA-9 points to NRMEASPR_IAF-19) based on slice criteria.
    ...   UE-4 selects measurement profile (NRMEASPR_MA_SA-78 points to NRMEASPR_IAF-89) based on 5qi criteria.
    ...   UE-7 selects measurement profile (NRMEASPR_MA_SA-99 points to NRMEASPR_IAF-76) based on NRCACLASS criteria.
    [Tags]    AA_B1
    Register and Establish PDU Session for Multiple UEs
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_1}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=20  ul_data=10
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE   carrier_freq=${CARRIER_FREQ_1}
    Verify whether UEs are configured with A2 Measurement event for the PCell Change   carrier_freq=${CARRIER_FREQ_1}
    Stop Data transfer and Deregister All UEs
    Collect and Verify PM Counters   test_instance=AA_B1

CB013142_AA_ET_TC02_B4_SA_Second_meas_quant_eval_on_PCell_using_meas_profile_using_criteria_except_UE_PC_during_A2_MR_reception_for_PCell_change
    [Documentation]
    ...   Main scenario: Secondary measurement quantity evaluation on PCell using measurement profile during A2 MR reception for
    ...   ‘PCell change’ for SA
    ...   7 UEs are used for this test automation.
    ...   UE-1 selects measurement profile (NRMEASPR_MA_SA-67 points to NRMEASPR_IAF-43) based on PLMN criteria.
    ...   UE-2 and UE-5 select measurement profile (NRMEASPR_MA_SA-4 points to NRMEASPR_IAF-20) based on RFSP criteria.
    ...   UE-3 and UE-6 select measurement profile (NRMEASPR_MA_SA-9 points to NRMEASPR_IAF-19) based on slice criteria.
    ...   UE-4 selects measurement profile (NRMEASPR_MA_SA-78 points to NRMEASPR_IAF-89) based on 5qi criteria.
    ...   UE-7 selects measurement profile (NRMEASPR_MA_SA-99 points to NRMEASPR_IAF-76) based on NRCACLASS criteria.
    [Tags]    AA_B4
    [Setup]   Setup for CB013142-AA-B4
    Register and Establish PDU Session for Multiple UEs
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_1}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=20  ul_data=10
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE   carrier_freq=${CARRIER_FREQ_1}
    Verify whether UEs are configured with A2 Measurement event for the PCell Change   carrier_freq=${CARRIER_FREQ_1}
    Send A2 MR and Verify PCELL switch did not happen   carrier_freq=${CARRIER_FREQ_1}    scell_2_meas=${EMPTY}
    Send A2 MR and Verify PCELL switch happened   carrier_freq=${CARRIER_FREQ_1}    scell_2_meas=${EMPTY}
    Stop Data transfer and Deregister All UEs
    Collect and Verify PM Counters   test_instance=AA_B1
