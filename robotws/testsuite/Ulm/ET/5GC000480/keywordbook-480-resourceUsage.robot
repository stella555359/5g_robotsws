*** Settings ***
Documentation    This is a Robot File, for feature 5GC000480 and 5GC001836, resource Usage
#-------------------------------------------------------------------------------------------------------------

Library    taf.ul.hanging_resources   WITH NAME   resources


*** Keywords ***


get resources taken before_test
    [Documentation]    [PRIVATE]    get resources taken before test, measurement period
    ...       :Autor: Sylvia Schneider
    Log To Console    \nget used resources and save in var "resources_usage_before_test"
    ${resources_usage_before_test}    resources.Get Resources Usage   node_id=0   node_type=gnb
    set test variable    ${resources_usage_before_test}


get resources taken after_test
    [Documentation]    [PRIVATE]    get resources taken after test, measurement period
    ...       :Autor: Sylvia Schneider
    Log To Console    \nget used resources and save in var "resources_usage_after_test"
    ${resources_usage_after_test}    resources.Get Resources Usage   node_id=0   node_type=gnb
    set test variable    ${resources_usage_after_test}


no check of resource nbOfFreeCRNTI
    [Documentation]    [PRIVATE]    exclude nbOfFreeCRNTI from the resource comparison
    ...       :Autor: Sylvia Schneider
    resources.Configure Default excluding Resource Paths   add=//nbOfFreeCRNTI


no check of resource postTimerWheel
    [Documentation]    [PRIVATE]    exclude postTimerWheel from the resource comparison
    ...       :Autor: Sylvia Schneider
    resources.Configure Default excluding Resource Paths   add=//postTimerWheel


verify resource usage
    [Documentation]    [PRIVATE]    compare resources before test and after test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify used resources
    Run Keyword And Continue On Failure      resources.Resources Should Be Equal
    ...    ${resources_usage_before_test}
    ...    ${resources_usage_after_test}
