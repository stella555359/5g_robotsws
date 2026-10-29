*** Settings ***
Documentation
...   Test cases run on AP testlines

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010414/CB010414_CB005934.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB005935/CB005935.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010414/CB010414_CB008152.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB006733/CB006733.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB012669/CB012669.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB011081/CB011081.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB012219/CB012219_Scell_swap.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB013438/CB013438_TC_06.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB006449/CB006449.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/aic_commissioning.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Resource        ./regression_keywords.robot
Library        ./python_functions.py
Library     OperatingSystem
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/DcapLogs.py

Suite Setup     Run Keywords
...    Initialise Attenuator    AND
...    Set Global Variable    ${CURRENT_SCF}    SCF_DEFAULT


Test Setup      Run Keywords
...    Set TESTNAME without spaces
...    Start Syslog On Vdu
...    Start Syslog On Vcu
...    Change Vdu Vcu Configuration If Needed


Test Teardown   Run Keywords
...    Clear cache
...    Stop Syslog On Vdu And Collect Snapshot
...    Stop Syslog On Vcu And Collect Snapshot

Test Timeout    30h


*** Test Cases ***
CB010414_CB005934_SCell_swap_4FDD_limit_on_SCell_swap_targets+VONR
    [Tags]    SCF_DEFAULT    25R1    25R2
    CB010414_CB005934_SCell_swap_4FDD_limit_on_SCell_swap_targets+VONR

TC04_CB005935_AA_B4_Single_UE_call_buffer_based_SCell_activation_deactivation
    [Tags]    SCF_DEFAULT    25R1    25R2
    TC04_CB005935_AA_B4_Single_UE_call_buffer_based_SCell_activation_deactivation

CB012669-Feature_activation_with_DL_2CC_CA
    [Tags]    SCF_DEFAULT    25R1    25R2
    CB012669-Feature_activation_with_DL_2CC_CA

CB010414_CB008152_35MHz_4cc_DL_CA_1F+3T
    [Tags]    SCF_8152    25R1    25R2
    CB010414_CB008152_35MHz_4cc_DL_CA_1F+3T

CB006733_B_B1_TC11 A4 measurements for FR1 CA SCell Addition are not configured after intra-gNB HO
    [Tags]    SCF_6733    25R1    25R2
    CB006733_B_B1_TC11 A4 measurements for FR1 CA SCell Addition are not configured after intra-gNB HO

CB006733_B_B17_TC26 Activation of A1 for SCell Change upon A2 SCell Release of A4-based SCell
    [Tags]    SCF_6733    25R1    25R2
    CB006733_B_B17_TC26 Activation of A1 for SCell Change upon A2 SCell Release of A4-based SCell

CB006733_A_B4_TC04 Deactivation of A4 measurements for SCell Addition after A4 supervision timer expiry
    [Tags]    SCF_6733    25R1    25R2
    CB006733_A_B4_TC04 Deactivation of A4 measurements for SCell Addition after A4 supervision timer expiry

CB012219_Scell_swap
    [Tags]    SCF_12219    25R2
    CB012219_Scell_swap

[1]TC3_CB011081_C_IWK4_FDD+TDD_FR1_DL_6CC_CA_and_F+F_UL_2CC_CA test automation
    [Tags]    SCF_6CC    25R2
    [1]TC3_CB011081_C_IWK4_FDD+TDD_FR1_DL_6CC_CA_and_F+F_UL_2CC_CA test automation

TC06_CB013438-A-A1-A3_Online_modification_of_scheduling_weight_with_extended_range_with_RAT1_and_parameter_Reinit_Prohibit_Timer_on_cloud
    [Tags]    SCF_13438
    TC06_CB013438-A-A1-A3_Online_modification_of_scheduling_weight_with_extended_range_with_RAT1_and_parameter_Reinit_Prohibit_Timer_on_cloud

TC03_AA_B3_AB_B2 Successful_intra_band_FR1_TDD_TDD_UL_CA_configuration_via_blind_SCell_addition_with_A2_MR_based_SCell_release_with_delta_A2
    [Tags]    SCF_6449
    TC03_AA_B3_AB_B2 Successful_intra_band_FR1_TDD_TDD_UL_CA_configuration_via_blind_SCell_addition_with_A2_MR_based_SCell_release_with_delta_A2

TC09_CA_IWK7_IWK_8_event_A1_A4_&_bufferBased_CB008311_NR_FR1_SCell_addition_for_SA
    [Tags]    SCF_6449
    TC09_CA_IWK7_IWK_8_event_A1_A4_&_bufferBased_CB008311_NR_FR1_SCell_addition_for_SA
