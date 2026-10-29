*** Settings ***
Documentation    This is a Robot File, for resource Usage
#-------------------------------------------------------------------------------------------------------------

Library    taf.ul.hanging_resources   WITH NAME   resources


*** Variables ***
@{DEFAULT_EXCLUDE_RESOURCE}    //nbOfFreeCRNTI

*** Keywords ***


Get Resources Taken Before Test
    [Documentation]    [PRIVATE]    get resources taken before test, measurement period
    ...       :Author: Sylvia Schneider
    Log To Console    \nget used resources and save in var "resources_usage_before_test"
    ${resources_usage_before_test}    resources.Get Resources Usage   node_id=0   node_type=gnb
    Set Test Variable    ${resources_usage_before_test}


Get Resources Taken After Test
    [Documentation]    [PRIVATE]    get resources taken after test, measurement period
    ...       :Author: Sylvia Schneider
    Log To Console    \nget used resources and save in var "resources_usage_after_test"
    ${resources_usage_after_test}    resources.Get Resources Usage   node_id=0   node_type=gnb
    Set Test Variable    ${resources_usage_after_test}


No Check Of Resource NbOfFreeCRNTI
    [Documentation]    [PRIVATE]    exclude nbOfFreeCRNTI from the resource comparison
    ...       :Author: Sylvia Schneider
    resources.Configure Default Excluding Resource Paths   add=//nbOfFreeCRNTI


Verify Resource Usage
    [Documentation]    [PRIVATE]    compare resources before test and after test
    ...       :Author: Sylvia Schneider
    Log To Console    \nverify used resources
    Run Keyword And Continue On Failure      resources.Resources Should Be Equal
    ...    ${resources_usage_before_test}
    ...    ${resources_usage_after_test}

Add Exclude Resources
    [Documentation]    [PRIVATE]    exclude list of resources
    ...       :Author: Noli Valdez III
    [Arguments]    ${exclude_list}=@{DEFAULT_EXCLUDE_RESOURCE}
    FOR    ${resource}    IN    @{exclude_list}
        resources.Configure Default Excluding Resource Paths   add=${resource}
    END
