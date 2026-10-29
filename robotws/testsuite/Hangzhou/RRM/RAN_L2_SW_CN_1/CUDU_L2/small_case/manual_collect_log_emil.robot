*** Settings ***
Resource    ./../common_setup_teardown.robot
*** Variables ***
${STOP_CASE_FILE}    /home/ute/delete_me_to_stop_case.txt
*** Test Cases ***
Small Case For Catch Emil
    [Tags]    case1
    #Verify BTS Is OnAir
    Start Emil Log
    #Wait Until User Manually Delete Stop Case File
    sleep    10s
    Stop And Collect Emil Log
*** Keywords ***

