*** Settings ***
Resource          ../resources/DevHZ5_resource.robot

*** Variables ***

*** Test Cases ***
restart gnb and airphone
    log to console    ${EMPTY}
    Restart Gnb And Airphone
    Log To Console    wait GNB and AP SSH connnected
    Sleep    2min
    Wait For All Hosts    ${FTM_IP}    ${FCT_IP}    timeout=300

*** Keywords ***
