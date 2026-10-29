*** Settings ***
Documentation	Suite description
...    Responsible tester: konrad.koziol@nokia.com
Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/tc_scenarios.robot


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
@{additional_common_fault_list}=
...  faultId=4589
...  faultId=7509, severity=Major      #DSS
...  faultId=7513, severity=Major      #DSS
...  faultId=7511                      #DSS
...  faultId=6134, severity=Minor      #DSS


&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=     Failed
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=     True
${SKIP_TRUCK_ROLL}=     ${True}

*** Test Cases ***
[1][1.0] Automated_SiSo_TEST_Stability_Without_Reset
    [Timeout]    20h
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO114_DEFAULT
    ...  AND  Set Test Variable  ${Total_Time}     900
    ...  AND  Set Test Variable  ${Interval}     180
    Automated_SiSo_TEST_Stability_Without_Reset
    [Teardown]  Configuration Postcondition
