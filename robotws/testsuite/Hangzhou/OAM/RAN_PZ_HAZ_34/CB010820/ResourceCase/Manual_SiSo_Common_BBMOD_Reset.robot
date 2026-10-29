*** Settings ***
Resource    ../Resource/Common.robot


*** Variables ***


*** Keywords ***
Test_Case_Manual_SiSo_Common_BBMOD_Reset
    Case Setup: Manual_SiSo_Common_BBMOD_Reset
    Manual_SiSo_Common_BBMOD_Reset
    [Teardown]   Case Teardown: Manual_SiSo_Common_BBMOD_Reset


Manual_SiSo_Common_BBMOD_Reset
    Log To Console   Manual_SiSo_Common_BBMOD_Reset

    ${bbmod_info_list}   coam.get_managed_objects   class_name=BBMOD_R   timeout=${60}   connection=COAM
    FOR   ${bbmod_info}   IN   @{bbmod_info_list}
        ${dist_name}   Set Variable   ${bbmod_info['distName']}
        COAM Reset BBMOD   dist_name=${dist_name}
    END

    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair

    CB010820 L3 Call Common Keyword


Case Setup: Manual_SiSo_Common_BBMOD_Reset
    Set Suite Variable   ${DEFINE_TEST_NAME}   Manual_SiSo_Common_BBMOD_Reset
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair


Case Teardown: Manual_SiSo_Common_BBMOD_Reset
    CB010820 Common Case Teardown

    Wait Until Keyword Succeeds   10m   1m   COAM Login
    ${onair}   Run Keyword And Return Status   COAM ADMIN Check Cell Onair
    Run Keyword If   not ${onair}   COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair
    [Teardown]   Run Keyword And Ignore Error   COAM Logout
