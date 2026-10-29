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
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/STARTUP_Radio_Multiple_Power_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_controlled_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_controlled_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_uncontrolled_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/PM/PM_Energy_Optimized_mode_for_Pandion_RRH.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
@{additional_common_fault_list}=
#...  faultId=1898
#...  faultId=4003
#...  faultId=7107
#...  faultId=1815
...  faultId=61675

@{tc_additional_common_fault_list}=
...  faultId=6450
@{tc_additional_1369_fault_list1}=
...  faultId=7107
...  faultId=61675
@{tc_additional_1369_fault_list2}=
...  faultId=6450
...  faultId=61675
@{tc_additional_1369_fault_list3}=
...  faultId=1815
...  faultId=61675

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

${CELLS_YAML_PATH}=    /home/ute/testline_configuration/10_16_UTESRANSISO100/100cells.yaml
#${UTE_UE_CONFIG}=                   /home/ute/testline_configuration/10_16_UTESRANSISO100/ute_ue_config.yml
${FORCE_RESET_CONFIGURATION}=    False
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=    Failed
${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}=    ${False}
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=    True
${CHECK_SWCONFIG}  False
${SKIP_TRUCK_ROLL}=          ${False}       # to disable Truck And Roll feature set this flag to False
${ENABLE_TRUCK_ROLL_FLAG}    ${False}

*** Test Cases ***

[G20][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset       #OK     SBTS00 & 25R1
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_DEFAULT    N=40
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    Execute Test In Loop  Power Reset On Node
    [Teardown]  Configuration Postcondition

[G21TRUE][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_DEFAULT   N=5
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}       LR244709861   LR244901374    K9243201394    K9243202409
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${TRUE}     # user can turn off dyinggasp verification in case of any
    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1369=@{tc_additional_1369_fault_list3}
     Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
     [Teardown]  Run Keywords
     ...  Configuration Postcondition
     ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1369=@{EMPTY}

[G20][4.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset        ##OKOK
   [Setup]  Run Keywords
   ...  Configuration Precondition        CN=REF_10_16_UTESRANSISO100_DEFAULT    N=40
   ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}  350
   Execute Test In Loop  Execute Site Reset On Every Node
   [Teardown]  Configuration Postcondition

[G20][1.0] Automated__SiSo__BTS_Block_Unblock_without_call                       # SBTS00 & 25R1
    [Setup]  Run Keywords
    ...  Configuration Precondition      CN=REF_10_16_UTESRANSISO100_DEFAULT   N=30
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
    Execute Test In Loop  Execute Block BTS On Every Node
    [Teardown]  Configuration Postcondition

[G20][1.0] Automated_SiSo_PM_Energy_Optimized_mode_for_Pandion_RRH
    [Setup]    Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_DEFAULT
    ...  AND  Set Test Variable  ${CELLS_YAML_PATH}
    ...  AND  Set Test Variable  @{SELECTED_CELLS}    350473
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    ...  AND  Set Test Variable  ${RMOD_SN}  LR244709861
    ...  AND  Set Test Variable  ${CHECK_POWER_EE}  False
    Execute Test In Loop  TC__PM_Energy_Optimized_mode_for_Pandion_RRH
    [Teardown]  Configuration Postcondition

                            ###  C A L L ####

[G20][1.0] Automated_SiSo_CALL_LTE_Data_Transfer                    #OK     #OK    Trunk  $ 25R1
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_DEFAULT
    ...  AND  Set Test Variable  @{SELECTED_CELLS}   350473
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop    SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition
#
[G20][1.0] Automated_SiSo_CALL_NR_Data_Transfer                 #   Trunk  $ 25R1
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_G21
    ...  AND  Set Test Variable  @{SELECTED_CELLS}   22429700
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
    Execute Test In Loop    SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition

[G20][3.0] Automated_SiSo_CALL_GSM_Data_Transfer          #OK    Trunk  $ 25R1
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_DEFAULT
    ...  AND  Set Test Variable  @{SELECTED_CELLS}   2301
    ...  AND  Set Test Variable  ${LOGS_DIR}   ${cfg.test_logs_path}
#    ...  AND  Set Test Variable  ${VOICE}    ${FALSE}
    Execute Test In Loop    SiSo Basic L3 Call

[1][1.0] General_SiSo_Auto_Runtime_Change_Of_enableInternalIQRouting     # SBTS00
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_DEFAULT    N=20
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    Execute Test In Loop  TC__CM_Runtime_Change_Of_enableInternalIQRouting
    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_L1SoC_Reset     # SBTS00
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_DEFAULT
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1369=@{tc_additional_1369_fault_list2}
    Execute Test In Loop  TC__REC_L1SoC_Reset
    [Teardown]  Run Keywords
    ...  Configuration Postcondition
    ...  AND  Set To Dictionary  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}  1369=@{EMPTY}

[1][1.0] General_SiSo_Auto_CPRI_RU_resiliency_to_BTS-DU_L1Soc_controlled_reset               # OK
    [Tags]  SiSo STARTUP Site Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_DEFAULT
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  EA203761974
    SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_controlled_reset
    [Teardown]  Configuration Postcondition

#[1][1.0] General_SiSo_Auto_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset
#    [Tags]  SiSo STARTUP Site Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO100_DEFAULT
#    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}  EA203761974
#    SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset
#    [Teardown]  Configuration Postcondition
