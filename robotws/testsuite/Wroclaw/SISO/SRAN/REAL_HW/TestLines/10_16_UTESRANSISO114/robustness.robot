*** Settings ***
Documentation    Suite description
...    Author:      konrad.koziol@nokia.com
...    Maintainer:    konrad.koziol@nokia.com


Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_NR_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_LTE_Rat_Reset.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/STARTUP/SiSo_STARTUP_Baseband_Module_Reset.robot

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
...                             faultId=7107, severity=Major      #X2 link failure after LTE RAT reset
...                             faultId=7107, severity=Critical   #X2 link failure after LTE RAT reset

${SKIP_TRUCK_ROLL}=    ${TRUE}
${CHECK_SWCONFIG}=     ${FALSE}

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}
#${FORCE_RESET_CONFIGURATION}=    True
#${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=    Failed
#${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}=    ${False}
#${CUSTOM_SWITCH_PERFORM_HW_SETUP}=    True
${HARDWARE_DETECTION_TIME}=  1400
${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO114/ue_config.yaml

*** Test Cases ***

[1][1.0] Automated_SiSo_BTS_Startup_Multiple_Baseband_Module_Reset
    [Setup]  Run Keywords
    ...  Configuration Precondition              N=5       CN=REF_10_16_UTESRANSISO114_DEFAULT
    ...  AND  Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}     600
    ...  AND  Set Test Variable  ${FAULT_10_TIMEOUT}     180
    ...  AND  Set Test Variable  ${FR_AVAILABILITY_TIMEOUT}     420
    ...  AND  Set Test Variable  ${RU_STARTUP_TIMEOUT}     280
    Execute Test In Loop  Automated_SiSo_BTS_Startup_Multiple_Baseband_Module_Reset
    [Teardown]  Configuration Postcondition

[1][1.0] Automated_SiSo_SM_NR_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition      N=1      CN=REF_10_16_UTESRANSISO114_DEFAULT
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     240
    ...  AND  Set Test Variable  @{RAT_IMPACT_LIST}    373830    373800    373813
#    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     800
    ...  AND  Set Test Variable  ${NR_RAT_RESET_TIMEOUT}     240
#    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     True
    Execute Test In Loop  TC__STATE__NR_RAT_reset_from_ADMIN
    [Teardown]  Configuration Postcondition

[1][2.0] Automated_SiSo_SM_LTE_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition      N=1      CN=REF_10_16_UTESRANSISO114_DEFAULT
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     240
#    ...  AND  Set Test Variable  @{RAT_IMPACT_LIST}    23924141    23924341    23924142    23924342    23920732    23927641    23927642    23927643
#    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     800
    ...  AND  Set Test Variable  ${LTE_RAT_RESET_TIMEOUT}     240
    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     True
    Execute Test In Loop  TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]  Configuration Postcondition