*** Settings ***

Resource    ./keywords.robot

*** Keywords ***
General SiSo Fault 1900 EFaultId FrConfiguringFailed
    [Arguments]    ${mandatory_alarms}    ${pmax_test_value}    ${timeout_reset_RU}=120
    ${pmax_original_value}    Save current pMax Value
    ${dist_name}    Get Cell Dist Name for pMax Change
    Change pMax to unexpected value    dist_name=${dist_name}    pmax_test_value=${pmax_test_value}
    Reset gNB
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify gNB is onAir
    Verify Mandatory Alarms on gNB   mandatory_alarms=${mandatory_alarms}
    [Teardown]    Restore pMax to original value    dist_name=${dist_name}    pmax_original_value=${pmax_original_value}
    ...                                             timeout_reset_RU=${timeout_reset_RU}
