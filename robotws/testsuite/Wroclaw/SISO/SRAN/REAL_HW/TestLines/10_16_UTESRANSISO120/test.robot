*** Settings ***
Documentation         Suite description
...    Author:        anna.maciejewska@nokia.com
...    Maintainer:    anna.maciejewska@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestCases/SEC/SEC_Nokia_Service_account_management_on_RU.robot



Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     None      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     False     # to disable hardware reconfiguration ( PDU and Optical part ) set value False

@{additional_common_fault_list}=
...    faultId=1403     #severity=Major, No X2 link available
...    faultId=1402     #severity=Major, Setup of X2 connectivity to gNB failed
...    faultId=4546     #severity=Major, No X2 link available for a specific LTEENB
...    faultId=6450
...    faultId=2403

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=
...  common=@{additional_common_fault_list}


#${CELLS_YAML_PATH}              /home/ute/testline_configuration/10_16_UTESRANSISO001/ue_config.yaml
${SKIP_TRUCK_ROLL}=    ${TRUE}
${CHECK_SWCONFIG}=     ${FALSE}
${CONFIGURATION_STARTUP_TIMEOUT}    400
*** Test Cases ***

[1][3.0] Nokia_Service_account_management_on_RU
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO120_LTE  N=1
    ...  AND   Set Test Variable  ${SSH_TIMER}    30
    ...  AND   Set Test Variable  ${OFFSET}    10
    Execute Test In Loop  TC__SEC_Nokia_Service_account_management_on_RU
    [Teardown]  Configuration Postcondition

