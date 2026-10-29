*** Settings ***
Documentation      author: Cheng Jiajing
...                contact: jiajing.1.cheng@nokia-sbell.com

Suite Setup       KW.TestSuilt.Start_CB013843
Suite Teardown    KW.TestSuilt.Stop_CB013843
Test Timeout         100 min


Resource           ../CB013843/Resources/CB013843_Resources.robot

*** Test Cases ***
CB013843_T07_Unlock_Lane_for_Target_SFP_Object_under_BBMOD_where_RF_is_connected
    [Documentation]     This case is to test CB013843. Lock BBMOD SFP LANE and check if fault 1815 is triggered
    [Tags]
    [Setup]    TestCase.Start_CB013843
    [Teardown]  Teardown Case_CB013843
    CB013843_T07_Unlock_Lane_for_Target_SFP_Object_under_BBMOD_where_RF_is_connected