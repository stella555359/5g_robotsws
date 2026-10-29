*** Settings ***
Documentation
...    author: Kaijia Chen
...    contact: kaijia.chen@nokia-sbell.com
...    squad group: MMW_SG_04


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
#Library     ./Resources/CB009102_common_keywords.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/common_variables.robot


Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

*** Variables ***
@{ru_sn}    DH233082823    1M232008102


*** Test Cases ***
[1]CB005763_D_04_trigger_and _cancell_dying_gasp_alarm_on_eCPRI_with_RF_standalone
    [Setup]    robot_common_operations.Common Case Setup
    ${PDU_IP_list}    ${PDU_PORT_list}    Create RU PDU Info List
    @{allow_alarm}    Create List    10    4589
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_alarm}
    POWER_OFF_RU     topyoung    ${PDU_IP_list}    ${PDU_PORT_list}
    sleep   3min
    ${RU_SN_alarm_Dict}    Get Fault10 Alarm Info
    Check RU Fault10 Info    RU_SN_list=${ru_sn}    RU_SN_alarm_Dict=${RU_SN_alarm_Dict}
    POWER_ON_RU     topyoung    ${PDU_IP_list}    ${PDU_PORT_list}
    Check GNB on air
    [Teardown]    case teardown

[1]CB005763_D_05_trigger_and _cancell_dying_gasp_alarm_on_eCPRI_with_RF_split
    [Setup]    robot_common_operations.Common Case Setup
    ${PDU_IP_list}    ${PDU_PORT_list}    Create RU PDU Info List
    @{allow_alarm}    Create List    10    4589
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_alarm}
    POWER_OFF_RU     topyoung    ${PDU_IP_list}    ${PDU_PORT_list}
    sleep   3min
    ${RU_SN_alarm_Dict}    Get Fault10 Alarm Info
    Check RU Fault10 Info    RU_SN_list=${ru_sn}    RU_SN_alarm_Dict=${RU_SN_alarm_Dict}
    POWER_ON_RU     topyoung    ${PDU_IP_list}    ${PDU_PORT_list}
    Check GNB on air
    [Teardown]    case teardown



*** Keywords ***
case teardown
    robot_common_operations.Common case Teardown
    CI interface.Common Case Teardown

POWER_OFF_RU
    [Arguments]   ${model}    ${PDU_IP_list}    ${PDU_PORT_list}
    ${len}    Get Length    ${PDU_IP_list}
    FOR   ${i}  IN RANGE    ${len}
        Power Off Hardware    model=${model}    PDU_IP=${PDU_IP_list[${i}]}    PDU_PORT=${PDU_PORT_list[${i}]}
    END

POWER_ON_RU
    [Arguments]   ${model}    ${PDU_IP_list}    ${PDU_PORT_list}
    ${len}    Get Length    ${PDU_IP_list}
    FOR   ${i}  IN RANGE    ${len}
        Power On Hardware    model=${model}    PDU_IP=${PDU_IP_list[${i}]}    PDU_PORT=${PDU_PORT_list[${i}]}
    END

Get Fault10 Alarm Info
    [Arguments]    ${connection}=GNB_OAM
    ${RU_SN_alarm_Dict}    Create Dictionary
    Connect to gnb coam via ssl    bts_host=10.71.209.247    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    @{active_alarms}    coam.get_active_alarms    connection=${connection}
    FOR   ${alarm_info}   IN    @{active_alarms}
        ${fault_ID}   Get From Dictionary    ${alarm_info}    additionalFaultID
        ${SN}    ${supplAlarmInfo}    Run Keyword If    '${fault_ID}' == '10'    Get_RU_Alarm_Info    alarm_info=${alarm_info}
        ...    ELSE    Continue For Loop
        Set to Dictionary    ${RU_SN_alarm_Dict}    ${SN}    ${supplAlarmInfo}
    END
    [Return]    ${RU_SN_alarm_Dict}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Get_RU_Alarm_Info
    [Arguments]    ${alarm_info}
    ${SN}    Get From Dictionary    ${alarm_info}    serialNo
    ${supplAlarmInfo}    Get From Dictionary    ${alarm_info}    supplAlarmInfo
    [Return]    ${SN}    ${supplAlarmInfo}

Check RU Fault10 Info
    [Arguments]    ${RU_SN_list}    ${RU_SN_alarm_Dict}
    FOR  ${SN}   IN   @{RU_SN_list}
        ${message}    Get From Dictionary    ${RU_SN_alarm_Dict}    ${SN}
        Run Keyword And Continue On Failure    Should Contain    ${message}    RU power loss
    END

Create RU PDU Info List
    ${ru1_pdu_ip}    Set Variable    ${tl.pdus[1].addr}
    ${ru2_pdu_ip}    Set Variable    ${tl.pdus[1].addr}
    ${ru3_pdu_ip}    Set Variable    ${tl.pdus[2].addr}
    ${PDU_IP_list}    Create List    ${ru1_pdu_ip}    ${ru2_pdu_ip}    ${ru3_pdu_ip}

    ${ru1_pdu_port}    Set Variable    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
    ${ru2_pdu_port}    Set Variable    ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}
    ${ru3_pdu_port}    Set Variable    ${tl.gnbs[0].dus[0].rus[2].pdu_port.port_no}
    ${PDU_PORT_list}    Create List    ${ru1_pdu_port}    ${ru2_pdu_port}    ${ru3_pdu_port}
    [Return]    ${PDU_IP_list}    ${PDU_PORT_list}
