*** Settings ***
Documentation     Author: changyan.li@nokia-sbell.com
...
...               General_SiSo_Online_Sector_Addition_Deletion.
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot
Resource          taf/rfrl/cbts/robot/vdu/vdu_fm.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/utils.py
Library           taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library           taf.rfrl.cbts.utilities.generic_utils    WITH NAME    generic_utils

*** Keywords ***
General_SiSo_BTS_startup_with_delayed_RF_link_setup
    [Arguments]    ${ru_index}=${1}    ${vdu_index}=0    ${gnb_index}=0    
    ...    ${ru_model}=${tl.gnbs[0].dus[0].fhgws[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    ...    ${ru_pdu_ip}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}-1].pdu_port.pdu.addr}
    ...    ${ru_pdu_port}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}-1].pdu_port.port_no}
    ...    ${test_name}=default
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to verification vDU reset and l3call success.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...    1. power off ru and check alarm fault10 is repoorted
    ...    2. power on ru and check alarm fault10 is cancelled
    ...    3. check all cells are onair
    ...    4. Check L3 call is ok
    ...    - [EXPECTED RESULTS] vDU and all cells status are normal; l3call success.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | No | The RU index. Default is 1. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | ru_model | No | The model of the PDU. Default is the model of the PDU for the given RU from testline configuration. |
    ...    | ru_pdu_ip | No | The IP of the PDU for the given RU. Default is the IP of the PDU for the given RU from testline configuratio. |
    ...    | ru_pdu_port | No | The port of the PDU for the given RU. Default is the port of the PDU for the given RU from testline configuratio.
    ...      RU PB type eg: HBTE, topypung
    ...    | test_name | No | The test name used for customed peak rate. Default value is default. |
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    * Owner: changyan.li@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T13
    ...    *******************

    log to console    step1: power off ru and check alarm fault10 is reported
    Cloud Perform RU Power Off    model=${ru_model}    ru_pdu_ip=${ru_pdu_ip}    ru_pdu_port=${ru_pdu_port}
    sleep    60s
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    wait until keyword succeeds    10min    30s    Cloud vDU Alarm Should Exist In Active Alarms    fault_id=10
    ...    fault_name=No connection to unit    alias=${conn_alias}

    log to console    step2: power on ru and check alarm fault10 is cancelled
    Cloud Perform RU Power On    model=${ru_model}    ru_pdu_ip=${ru_pdu_ip}    ru_pdu_port=${ru_pdu_port}
    sleep    60s
    wait until keyword succeeds    10min    30s    Cloud vDU Alarm Should Not Exist In Active Alarms    fault_id=10
    ...    fault_name=No connection to unit    alias=${conn_alias}
#    wait until keyword succeeds    10min    30s    vdu_fm.Checking No unexpected Active Alarms Raised    user_unexpected_alarms=@{EMPTY}

    log to console    step3:all cells are onair, UE attach successful and check tput
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs
    log to console    check cell status should be on air for cu
    wait until keyword succeeds    5min    30s    All Cells Should Be Onair For One Specific vCU

    log to console    step4:check L3 call is ok
    ${cell_index_list}    vDU Get Cell List From Webem
    Cloud UE L3 Call And Throughput    cell_list=${cell_index_list}    test_name=${test_name}

Cloud vDU Alarm Should Exist In Active Alarms
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${fault_id}=${None}    ${fault_name}=${None}    ${alias}=default
    [Documentation]    Check specified alarm exists in active alarm list by alarm id or fault name or fault id or alarm name.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | fault_id | Yes | Fault id |
    ...    | fault_name | No | Fault name |
    ...    | gnb_index | No | gnb index to indicate which gnb will be used, 0 in default |
    ...    | alias | Yes | vdu login_rest return alias |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Cloud vDU Alarm Should Exist In Active Alarms | fault_id=10 | fault_name=BB bus reception error (summing device1) |
    ${alarm_info}=    run keyword and continue on failure    Cloud vDU Get Active Alarm Info    ${gnb_index}    alias=${alias}
    Log To Console    fault_id=${fault_id}
    Log To Console    fault_name=${fault_name}
    ${result}=    check_alarm_fault_exist    ${alarm_info}    fault_id=${fault_id}    fault_name=${fault_name}
    should be true    "${result}"=="True"    Expected active alarm is not found!

Cloud vDU Alarm Should Not Exist In Active Alarms
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${fault_id}=${None}    ${fault_name}=${None}    ${alias}=default
    [Documentation]    Check specified alarm doesn't exist in active alarm list by alarm id or fault name or fault id or alarm name.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | fault_id | Yes | Fault id |
    ...    | fault_name | No | Fault name |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | alias | Yes | vdu login_rest return alias |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Cloud vDU Alarm Should Not Exist In Active Alarms | alarm_id=7107 | alarm_name=ETHERNET LINK FAILURE |
    ...    | Cloud vDU Alarm Should Not Exist In Active Alarms | fault_name=BB bus reception error (summing device1) |
    ${alarm_info}=    Cloud vDU Get Active Alarm Info    ${gnb_index}    alias=${alias}
    ${result}=    check_alarm_fault_exist    ${alarm_info}    ${fault_id}    ${fault_name}
    should be true    "${result}"=="False"    Active alarm should not be found!

Cloud vDU Get Active Alarm Info
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${alias}=default    ${waiting_time}=10s
    [Documentation]    Gets active alarms including faults from BTS and alarms from RCP.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | gnb_index | No | gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    Active alarm list
    ...    Example
    ...    | Cloud vDU Get Active Alarm Info | |
    ${out}    vdu.vdu_get_active_alarms    timeout=${waiting_time}    paging=${False}    vdu_connection=${alias}
    ${num_of_alarms}    Set Variable    ${out["total"]}
    ${active_alarm_info}    Set Variable    ${out["alarms"]}
    ${active_alarm_total}=    get length    ${active_alarm_info}
    run keyword and continue on failure    should be equal as integers    ${active_alarm_total}    ${num_of_alarms}
    ...    There should be ${active_alarm_total} active alarms, but actually got ${num_of_alarms}
    [Return]    ${active_alarm_info}
