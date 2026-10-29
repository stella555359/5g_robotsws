*** Settings ***
Documentation         Suite description
...    Author:        bartosz.busz@nokia.com
...    Maintainer:    bartosz.busz@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot
Resource    ../../Resources/SiSo_L3_call.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_Cell_Block_Unblock.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SM/SiSo_SM_LTE_Rat_Reset.robot


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False

@{additional_common_fault_list}=
...    faultId=7300     #severity=Major, No X2 link available
...    faultId=6327     #severity=Major, Setup of X2 connectivity to gNB failed
...    faultId=7319     #severity=Major, No X2 link available for a specific LTEENB
...    faultId=1815     #severity=Major, link break
...    faultId=4773     #Radio unit reset triggered by peer BTS
...    faultId=4589     #Unit power reset
@{additional_1333_fault_list}=
...    faultId=7107		#X2 link break due to ENB reset
...    faultId=7308     #Transport layer connection failure in X2 interface
&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=
...  common=@{additional_common_fault_list}
...  1333=@{additional_1333_fault_list}

#${CELLS_YAML_PATH}              /home/ute/testline_configuration/10_16_UTESRANSISO001/ue_config.yaml
${SKIP_TRUCK_ROLL}=    ${TRUE}
${CHECK_SWCONFIG}=     ${FALSE}

*** Test Cases ***

[TMO_LTE_NR][3.0] Automated_SiSo_RU_Startup_Multiple_Power_Reset
    [Setup]  Configuration Precondition         CN=REF_10_16_UTESRANSISO001_DEFAULT     N=10
    Execute Test In Loop  Execute RU Power Hot Remove Insert On Every Node
    [Teardown]  Configuration Postcondition

[TMO_LTE_NR][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
    [Setup]  Configuration Precondition          CN=REF_10_16_UTESRANSISO001_DEFAULT    N=10
    Execute Test In Loop  Power Reset On Node
    [Teardown]  Configuration Postcondition

[TMO_LTE_NR][4.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset
    [Setup]  Configuration Precondition         CN=REF_10_16_UTESRANSISO001_DEFAULT     N=10
    Execute Test In Loop  Execute Site Reset On Every Node
    [Teardown]  Configuration Postcondition

[TMO_LTE_NR][2.0] Automated_SiSo_SM_LTE_RAT_reset
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO001_DEFAULT  N=10
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}     180
    ...  AND  Set Test Variable  ${TESTED_BTS_ID}       1334
    ...  AND  Set Test Variable  ${LTE_RAT_RESET_TIMEOUT}     240
    ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}     350
    ...  AND  Set Test Variable  ${SIMPLE_ONAIR}     True
    Execute Test In Loop  TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]  Configuration Postcondition
