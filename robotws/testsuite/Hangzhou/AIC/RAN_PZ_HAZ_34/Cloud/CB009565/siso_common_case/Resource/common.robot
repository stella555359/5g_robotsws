*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com
Library     BuiltIn
Library     String
Library     Process
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh   WITH NAME   csn
Library     taf.analyzer.pcap   WITH NAME   wireshark
Library     taf.selenium.sbts   WITH NAME   selenium_sbts
Library     taf.ul.oam_kpi_calculations   WITH NAME   oam_kpi
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library     taf.collectors.btslog   WITH NAME   btslog
Library     taf.collectors.core   WITH NAME   core
Library     taf.gnb.oam.coam.cu   WITH NAME   coam_cu
Library     taf.gnb.oam.coam.vdu   WITH NAME   coam_vdu

Resource    taf_coam_cu.robot
Resource    taf_coam_vdu.robot
Resource    log_collection.robot
Resource    check_point.robot
Resource    RU.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Variables   variables.py
Resource    common_vdu.robot
Resource    9301_Common.robot


*** Variables ***
${rulog_exist}    ${False}

*** Keywords ***
Recovery at Case Setup
    COAM VDU Login
    ${status_onair}    run keyword and return status     COAM VDU Check All Cell Status
    ${status_fault}    run keyword and return status     COAM VDU Check Active Alarms
    run keyword if  ${status_onair}==${False} or ${status_fault}==${False}   run keywords
    ...   Run Keyword And Ignore Error   COAM VDU Reset
    ...   AND   Wait Until Keyword Succeeds   15m   1m   COAM VDU Check All Cell Status
    [Teardown]    Run Keyword And Ignore Error   COAM VDU Logout


VDU Siso Common Save Logs
    ${log_status}   Get Variable Value   ${TEST_STATUS}   ${KEYWORD_STATUS}
#    Run Keyword If    "${log_status}" == "FAIL"        run keyword and ignore error    Capature Sreenshot COAM
    Run Keyword If    "${log_status}" == "FAIL"        run keyword and ignore error    COAM VDU Log Collection
    Run Keyword If    "${log_status}" == "FAIL"        run keyword and ignore error    Remote Stop and Save Syslog Collection
    run keyword if   ${egen_exist} and "${log_status}" == "FAIL"
    ...    Run Keyword and ignore error     VDU Stop Egen Log and Save to VM
    Run Keyword If    "${log_status}" != "FAIL"        run keyword and ignore error    Remote Stop and Delete Syslog Collection
    Run Keyword If    "${log_status}" != "FAIL"        run keyword and ignore error
    ...   run keyword if  ${rulog_exist}    VDU RU Log Operation Teardown if keyword passed
    Run Keyword If    "${log_status}" == "FAIL"        run keyword and ignore error
    ...   run keyword if  ${rulog_exist}    VDU RU Log Operation Teardown If Keyword Failed



VDU Siso Common Each Time Teardown
    Run Keyword And Ignore Error    COAM VDU Login
    ${status_active_fault}     run keyword and return status     Wait Until Keyword Succeeds    5min    30s
    ...    COAM VDU Check Active Alarms
    ${status_history_fault}     run keyword and return status     Wait Until Keyword Succeeds    5min    30s
    ...    COAM VDU Check History Alarms
    ${status_syslog}   run keyword and return status    VDU Siso Common Check Syslog Error
    ${status_rulog}    run keyword and return status
    ...    run keyword if  ${rulog_exist}    VDU Siso Common Check ALL RU Syslog Error
    ${status_list}   Create List   ${status_active_fault}   ${status_history_fault}
    ...    ${status_syslog}   ${status_rulog}
    ${status_check}     run keyword and return status    List Should Not Contain Value   ${status_list}   ${False}
    ${operation_status}   Get Variable Value   ${KEYWORD STATUS}   ${TEST STATUS}
    ${loginfo}      Catenate    [FAIL]syslog error check status:${status_syslog};
    ...    Opration status:${operation_status};
    ...   Active Fault status:${status_active_fault};
    ...   History Fault status:${status_history_fault};
    ...   rulog status:${status_rulog}!
    run keyword if     ${operation_status.count('PASS')}>0 and ${status_check}    run keywords
    ...     Remote Stop and Delete Syslog Collection
    ...     AND   run keyword if  ${rulog_exist}    VDU RU Log Operation Teardown if keyword passed
    ...     ELSE     FAIL     msg=${loginfo}
    [Teardown]   Run Keyword And Ignore Error   COAM VDU Logout