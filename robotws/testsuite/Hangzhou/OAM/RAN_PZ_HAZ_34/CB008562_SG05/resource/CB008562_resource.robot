*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_csv_log.py
Library    String
Documentation
...    Author:liu yue
...    contact:yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008562 in SBTS23R1 program
*** Variables ***

*** Keywords ***
Antenna Line Online Monitoring
    Selenium Login And Disable Screen Lock
    selenium_coam.select_antenna_lines_for_monitoring
    selenium_coam.start_antenna_line_monitoring
    sleep    10s
    selenium_coam.stop_antenna_line_monitoring
    sleep    3s
    ${monitor_result}    selenium_coam.get_monitored_values    value_type=RSSI
    FOR    ${Rssi_result}   IN    @{monitor_result}
        ${Keys}    Get Dictionary Keys    ${Rssi_result}
        ${key_of_rssi}=    Get key of RSSI    @{Keys}
        ${RSSI_value}=    Get From Dictionary    ${Rssi_result}    ${key_of_rssi}[0]
        ${cell}=    Get From Dictionary    ${Rssi_result}    RX carrier
        Run keyword if    '${cell}'=='NRCELL-1'    should be true    ${RSSI_value}>${-100} 
        ...    ELSE    should be equal as strings    ${RSSI_value}    -
    END
    selenium logout and close browser
    [Teardown]    selenium logout and close browser
Get key of RSSI
    [Arguments]    @{Keys}
    ${key_of_rssi}    Create List
    Set test Variable    ${key_of_rssi}
    FOR    ${key}    IN    @{Keys}
        #${key_of_rssi}=    Check RSSI key    key=${key}
        #${i}=     ${0}
        ${check_key}    Evaluate    re.findall("\\d{2}.\\d{2}.\\d{4}\\s\\d{2}:\\d{2}:\\d{2}","${key}")    re
        ${len}    Get length    ${check_key}
        Run keyword if    ${len}!=${0}   
        ...    Append To List    ${key_of_rssi}    ${check_key}[0]
    END
    [Return]    ${key_of_rssi}
