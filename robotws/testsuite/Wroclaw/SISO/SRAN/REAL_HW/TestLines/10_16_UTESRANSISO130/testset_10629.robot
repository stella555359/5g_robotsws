*** Settings ***
Documentation
...   author: Tomasz Pawlaczyk                                     # set your Name
...   contact: tomasz.pawlaczyk@nokia.com                                # set your email

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot

Resource     ../../robotlte_legacy/hran_ta/SiSo_PM_PIMC_Counters.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_NR_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_LTE_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/REC_L1SoC_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/CM/CM_Runtime_Change_Of_enableInternalIQRouting.robot
#Resource    ../../hran_ta/testsuite/SBTS/test_resources/BS-SM/BS-SM__GSM_RAT_reset_from_ADMIN.robot
#Resource    ../../Resources/SiSo_L3_Call.robot
#Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Data_Transfer.robot
#Resource    ${PATH}/test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Voice_Call.robot
#Resource    ${PATH}/test_resources/5G_RRM/Automated_SiSo_CALL_NR_Data_Transfer.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
@{additional_common_fault_list}=
#...  faultId=2403
...  faultId=1898
#...  faultId=4003
#...  faultId=7107
...  faultId=61675
#...  faultId=6450

@{tc_additional_1303_fault_list1}=
...  faultId=7107
...  faultId=61675
@{tc_additional_1303_fault_list2}=
...  faultId=6450
...  faultId=61675


&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

${CELLS_YAML_PATH}=    /home/ute/testline_configuration/10_16_UTESRANSISO130/130cells.yaml
${COMMISSIONING_PATH}
...  /home/ute/testline_init_results/execution/configs/topology_configs/node_1/CONF_DTAG_10629.xml
#${TESTLINE_NAME}      10_16_UTESRANSISO100
#${PATH}    testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS   #DO NOT CHANGE

${FORCE_RESET_CONFIGURATION}=    False
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=    Failed
${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}=    ${False}
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=    True
${CHECK_SWCONFIG}  False
${SKIP_TRUCK_ROLL}=      True   #  ${False}       # to disable Truck And Roll feature set this flag to False
${ENABLE_TRUCK_ROLL_FLAG}    ${False}

*** Test Cases ***

[1][1.0] General_SiSo_Auto_Runtime_Change_Of_enableInternalIQRouting     # SBTS00
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO130_DTAG_10629    N=10
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    Execute Test In Loop  TC__CM_Runtime_Change_Of_enableInternalIQRouting
    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_L1SoC_Reset     # SBTS00
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO130_DTAG_10629
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1303=@{tc_additional_1303_fault_list2}
    Execute Test In Loop  TC__REC_L1SoC_Reset
    [Teardown]  Run Keywords
    ...  Configuration Postcondition
    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1303=@{EMPTY}
