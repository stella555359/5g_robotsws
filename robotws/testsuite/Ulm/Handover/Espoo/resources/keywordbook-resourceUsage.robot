*** Settings ***
Documentation    This is a Robot File, for feature resource Usage
#-------------------------------------------------------------------------------------------------------------

Library    taf.ul.hanging_resources   WITH NAME   resources
Library    taf.ul.hanging_resources.listener     ${False}


*** Keywords ***


Get Resources Taken Before Test
    [Documentation]    [PRIVATE]    get resources taken before test, measurement period
    BuiltIn.Log To Console    \nget used resources and save in var "resources_usage_before_test"
    ${resources_usage_before_test}    resources.Get Resources Usage   node_id=0   node_type=gnb
    Set Test Variable    ${resources_usage_before_test}


Get Resources Taken After Test
    [Documentation]    [PRIVATE]    get resources taken after test, measurement period
    BuiltIn.Log To Console    \nget used resources and save in var "resources_usage_after_test"
    ${resources_usage_after_test}    resources.Get Resources Usage   node_id=0   node_type=gnb
    Set Test Variable    ${resources_usage_after_test}


No Check Of Resource NbOfFreeCRNTI
    [Documentation]    [PRIVATE]    exclude nbOfFreeCRNTI from the resource comparison

    resources.Configure Default Excluding Resource Paths   add=//nbOfFreeCRNTI


No Check Of Resource PostTimerWheel
    [Documentation]    [PRIVATE]    exclude postTimerWheel from the resource comparison
    resources.Configure Default Excluding Resource Paths   add=//postTimerWheel


Verify Resource Usage
    [Documentation]    [PRIVATE]    compare resources before test and after test
    resources.Configure Default Excluding Resource Paths   add=//cooling
    BuiltIn.Log To Console    \nverify used resources
    Run Keyword And Continue On Failure      resources.Resources Should Be Equal
    ...    ${resources_usage_before_test}
    ...    ${resources_usage_after_test}
