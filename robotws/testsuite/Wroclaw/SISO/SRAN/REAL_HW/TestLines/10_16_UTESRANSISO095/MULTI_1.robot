*** Settings ***
Documentation  Maintainers: marta.bak@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=
...                             faultId=1300, severity=Minor

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}   common=@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}

*** Test Cases ***
[MULTI2][4.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset
    [Setup]  Configuration Precondition  CN=REF_10_16_UTESRANSISO095_DEFAULT    N=15
    Execute Test In Loop  Execute Site Reset On Every Node
    [Teardown]  Configuration Postcondition

[MULTI2][3.0] Automated_SiSo_BTS_Startup_Multiple_Power_Reset
    [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO095_DEFAULT    N=15
    Execute Test In Loop  Power Reset On Node
    [Teardown]  Configuration Postcondition
