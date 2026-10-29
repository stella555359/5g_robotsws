*** Settings ***
Documentation    Suite description
...    Author:      konrad.koziol@nokia.com
...    Maintainer:    konrad.koziol@nokia.com


Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Site_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_uncontrolled_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/REC/SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/STARTUP_Radio_Multiple_Power_Reset.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***

@{additional_common_fault_list}=
...                             faultId=4681, severity=Warning    # Sanity chceck error
...                             faultId=1815, severity=Minor      # Not able to synchronize baseband bus
...                             faultId=1815, severity=Major      # Not able to synchronize baseband bus
...                             faultId=7509, severity=Major      #DSS
...                             faultId=7513                      #DSS
...                             faultId=7511                      #DSS
...                             faultId=6134                      #DSS

${SKIP_TRUCK_ROLL}=    ${TRUE}
${CHECK_SWCONFIG}=     ${FALSE}

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}
#${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=    Failed
${HARDWARE_DETECTION_TIME}=  1400
${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO114/ue_config.yaml

*** Test Cases ***

[SBTS00_True][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    N=10    CN=REF_10_16_UTESRANSISO114_DEFAULT
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}      K9251016658    K9251016654    K9251016655
    ...  DH242832518    DH242832510    RW240800036        # custom radio list for testing
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${TRUE}     # user can turn off dyinggasp verification in case of any
    Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition

[SBTS00_False][4.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    N=10    CN=REF_10_16_UTESRANSISO114_DEFAULT
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}        L9134900909    12W332Z10065    DH231942106
    ...  6Q204500337    6Q205001536    6Q204500331             # custom radio list for testing: AHPMDD
    ...  6Q192809744    6Q192809743    RW235000497             # custom radio list for testing: AHSA
    ...  16W323D90402   LBALLU-YD1539025H6    19YD20078788     # custom radio list for testing: UHFD, UHNA, UHLC
    ...  AND  Set Test Variable  ${DYINGGASP_USER_SWITCH}         ${FALSE}     # user can turn off dyinggasp verification in case of any
    Execute Test In Loop  TC__STARTUP_Radio_Multiple_Power_Reset
    [Teardown]  Configuration Postcondition

[TL114][4.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset
    [Setup]  Configuration Precondition          N=20       CN=REF_10_16_UTESRANSISO114_DEFAULT
    Execute Test In Loop  Automated_SiSo_BTS_Startup_Multiple_Site_Reset
    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_uncontrolled_reset
    [Tags]  SiSo STARTUP Site Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition                           CN=REF_10_16_UTESRANSISO114_DEFAULT
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}    K9251016655       #AHEGHA
    SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_uncontrolled_reset
    [Teardown]  Configuration Postcondition

[1][1.0] General_SiSo_Auto_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset
    [Tags]  SiSo STARTUP Site Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition                           CN=REF_10_16_UTESRANSISO114_DEFAULT
    ...  AND  Set Test Variable  @{CUSTOM_RADIO_UNIT_LIST}    K9251016655       #AHEGHA
    SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset
    [Teardown]  Configuration Postcondition

[TL114][1.0] Automated_SiSo_CALL_LTE_Data_Transfer
    [Setup]    Run Keywords
    ...  Configuration Precondition                         CN=REF_10_16_UTESRANSISO114_DEFAULT
    ...  AND    Set Test Variable  @{SELECTED_CELLS}   373830      #FRPA_LTE
    Execute Test In Loop  SiSo Basic L3 Call
    [Teardown]  Configuration Postcondition