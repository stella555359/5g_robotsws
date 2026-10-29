*** Settings ***
Resource          ../../../../resources/Krakow_Resources_from_Nanjing/robot/Common.robot
Resource          ../../../../resources/Krakow_Resources_from_Nanjing/robot/OAM5G_keywords.robot
Resource          taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables         taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
Test Setup
    Log to console    \n--Test Setup started--\n
    Run keyword And Restart gNB On Error    Common preconditions
    Upload commisioning with pcmd enabled
    Log to console    \n--Test Setup done--\n
    create test log directory
    Log to console    \n--Starting test ${TEST_NAME}--\n

Test Teardown
    Log to console    \n--Finished test ${TEST_NAME}--\n
    Log to console    \n--Test Teardown started--\n
    Run keyword And Restart gNB On Error    Common postconditions
    Log to console    \n--Test Teardown done--\n

Suite Setup
    Log to console    \n--Suite Setup started--\n
    Run keyword And Restart gNB On Error    Perform Full Commissioning and Wait for onAir    prefix_tag=${None}    asir_hub=${True}
    Wait For Site To Be Onair
    Common Suite Setup
    Log to console    \n--Suite Setup done--\n

Suite Teardown
    Log to console    \n--Suite Teardown started--\n
    Run keyword And Restart gNB On Error    Common Suite Teardown
    Log to console    \n--Suite Teardown done--\n

Run Keyword And Restart gNB On Error
    [Arguments]    ${keyword}    @{args}    &{kwargs}
    FOR  ${i}  IN RANGE  3
        ${keyword_status}=    Run keyword and return status    ${keyword}    @{args}    &{kwargs}
        Return From Keyword If    '${keyword_status}' == '${True}'
        Log to console    \n--${keyword} failed, restarting gNB--\n
        Reset gNB
        Wait For Site To Be Onair
    END
    Fail    Keyword did not succeed in the given number of attempts
