*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
#Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown
Test Timeout         50 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Library    ./lib/check_bts_log.py

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008538 in 5G22R4 program

Force Tags    5G_RAN_TDD

*** Variables ***

*** Test Cases ***
[1]CB008538-5G_01_RU_WebEM_Reset_startup_time_Amber
    [Tags]    master_classicalbts_all    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Selenium Login And Disable Screen Lock
    General_SiSo_RF_module_reset_from_GUI
    run keyword and ignore error    run    command=rm /tmp/BTSLOG_AA_11.txt&
    Sleep    1s
    run    command=cat /tmp/btslog2/SYSLOG_*.LOG >> /tmp/BTSLOG_AA_11.txt&
    Sleep    3s
    ${duration}    get_ru_reset_duration    file_log_name=/tmp/BTSLOG_AA_11.txt
    should be true  ${duration} < ${180} and ${duration} > ${0}
    #Start Btslog With Path Check
    [Teardown]    Run keywords     Selenium Logout And Close Browser
    ...    AND   SISO Coam Test Teardown

[1]CB008538-5G_02_RU_Power_Reset_startup_time_Amber
    [Tags]    master_classicalbts_all    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Perform RU Power Off    ru_index=${1}   model=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${1}
    Perform RU Power On    ru_index=${1}    model=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}
    ${timestartTmp}    robot.libraries.DateTime.Get Current Date    UTC
    Log to console    Power on time: ${timestartTmp}
    ${timestart}    robot.libraries.DateTime.Convert Date     ${timestartTmp}    epoch
    Wait Until Keyword Succeeds     10min    1min    RU Should Be Online    ru_index=${1}
    Sleep    30s
    run keyword and ignore error    run    command=rm /tmp/BTSLOG_AA_11.txt&
    Sleep    1s
    run    command=cat /tmp/btslog2/SYSLOG_*.LOG >> /tmp/BTSLOG_AA_11.txt&
    Sleep    3s
    ${timeend}    run    command=cat /tmp/BTSLOG_AA_11.txt | grep "Operational state changed to Enabled for Rmod"|awk '{print $7}'|head -n 3|tail -1
    Log to console    RU online time: ${timeend}
    Should Not Be Empty     ${timeend}
    ${timeend}        robot.libraries.DateTime.convert date
    ...    ${timeend.replace("<", "").replace(">", "").replace("T", " ").replace("Z", "")}       epoch
    ${duration}    Evaluate    ${timeend}-${timestart}
    Log to console    RU power reset duration: ${duration}
    should be true  ${duration} < ${180} and ${duration} > ${0}
    [Teardown]    Run keywords     Selenium Logout And Close Browser
    ...    AND   SISO Coam Test Teardown
*** Keywords ***
