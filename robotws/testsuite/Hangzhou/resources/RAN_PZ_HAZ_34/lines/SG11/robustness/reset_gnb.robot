*** Settings ***
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG11/Resources/SG11_Common_setup_teardown.robot
Suite Setup       SG11 Common Suite Setup
Suite Teardown    SG11 Common Suite Teardown
Test Setup        SG11 Common Case Setup
Test Teardown     SG11 Common Case Teardown

*** Variables ***
${cell_type}             NR
${reset_times}           50


*** Test Cases ***
Robustness_Reset_Site
    Wait Until Keyword Succeeds    10min    30s    Verify All Cells Should Be Onair
    FOR   ${i}  IN RANGE  ${reset_times}
        Get Logs and Reboot Site    ${i}
    END

    
*** Keywords ***
Get Logs and Reboot Site
    [Arguments]    ${i}
    ${log_dir}    Set Variable    ${TEST_LOG_DIRECTORY}//Site_Reset_${i}_log
    Start GNB Syslog    ${log_dir}
    Perform BTS Site Reset   ${log_dir}
    Wait Until Keyword Succeeds    10min    30s    Verify All Cells Should Be Onair
    [Teardown]    Run keywords    Stop And Collect GNB Syslog    ${log_dir}
    ...           AND     Save Coam SnapShot    ${log_dir}
    ...           AND     Display All Active Alarms



    






