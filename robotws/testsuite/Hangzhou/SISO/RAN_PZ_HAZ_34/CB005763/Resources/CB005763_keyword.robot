*** Settings ***

Documentation
...    author: Ye Tianyi
...    contact: tianyi.ye@nokia-sbell.com
...    Group: Vrf3_SG8

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Library    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/common.py

*** Keywords ***
CB005763-CA_RF_chain_Dying_Gasp_alarm_check_when_first_RU_power_off_AZNA
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    ${SCF_CB005763_Chaining}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB005763_Chaining_
    COAM Commission with scf file    scf_file_path=${SCF_CB005763_Chaining}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Wait Until Keyword Succeeds    10 min    10 sec    Verify all lte cells should be onair
    ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[8].pdu_port.pdu.__class__.__name__}
    ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[8].pdu_port.pdu.addr}
    ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[8].pdu_port.port_no}
    log to console    for 1st hop RU, model is ${model}, pb ip is ${address}, pb port is ${port}
    pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_8
    pdu.power off    port=${port}    pdu_device=pdu_ru_8
    ${release}    Get program version based on gNB active version
    ${Supplementary_info}    Run Keyword If    "${release}"=="master"    Set Variable    RU connection was lost in runtime. RU power loss.    ELSE
    ...    Set Variable    RU connection was lost in runtime;RU power loss
    Wait Until Keyword Succeeds    5 min    10 sec    Check RU Specific Alarm in Alarm List    type=Active
    ...    faultId=10    ru_sn=EA224651578		Supplementary=${Supplementary_info}
    pdu.power on    port=${port}    pdu_device=pdu_ru_8
    Wait Until Keyword Succeeds    10 min    10 sec    Verify all lte cells should be onair
    ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[9].pdu_port.pdu.__class__.__name__}
    ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[9].pdu_port.pdu.addr}
    ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[9].pdu_port.port_no}
    log to console    for 2nd hop RU, model is ${model}, pb ip is ${address}, pb port is ${port}
    pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_9
    pdu.power off    port=${port}    pdu_device=pdu_ru_9
    ${release}    Get program version based on gNB active version
    ${Supplementary_info}    Run Keyword If    "${release}"=="master"    Set Variable    RU connection was lost in runtime. RU power loss.    ELSE
    ...    Set Variable    RU connection was lost in runtime;RU power loss
    Wait Until Keyword Succeeds    5 min    10 sec    Check RU Specific Alarm in Alarm List    type=Active
    ...    faultId=10    ru_sn=RW200800275		Supplementary=${Supplementary_info}
    pdu.power on    port=${port}    pdu_device=pdu_ru_9
    Wait Until Keyword Succeeds    10 min    10 sec    Verify all lte cells should be onair
    ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[10].pdu_port.pdu.__class__.__name__}
    ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[10].pdu_port.pdu.addr}
    ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[10].pdu_port.port_no}
    log to console    for 3rd hop RU, model is ${model}, pb ip is ${address}, pb port is ${port}
    pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_10
    pdu.power off    port=${port}    pdu_device=pdu_ru_10
    ${release}    Get program version based on gNB active version
    ${Supplementary_info}    Run Keyword If    "${release}"=="master"    Set Variable    RU connection was lost in runtime. RU power loss.    ELSE
    ...    Set Variable    RU connection was lost in runtime;RU power loss
    Wait Until Keyword Succeeds    5 min    10 sec    Check RU Specific Alarm in Alarm List    type=Active
    ...    faultId=10    ru_sn=EA224651582		Supplementary=${Supplementary_info}
    pdu.power on    port=${port}    pdu_device=pdu_ru_10
    Wait Until Keyword Succeeds    10 min    10 sec    Verify all lte cells should be onair
    [Teardown]    Run Keywords    run keyword and ignore error    Perform RU Power On    ru_index=${9}    AND
    ...    run keyword and ignore error    Perform RU Power On    ru_index=${10}    AND
    ...    run keyword and ignore error    Perform RU Power On    ru_index=${11}

CB005763-BI_Dying_Gasp_alarm_check_AZQF
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Wait Until Keyword Succeeds    15 min    10 sec    Verify all cells should be onair
    ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[0].pdu_port.pdu.__class__.__name__}
    ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[0].pdu_port.pdu.addr}
    ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[0].pdu_port.port_no}
    log to console    model is ${model}, pb ip is ${address}, pb port is ${port}
    pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_1
    pdu.power off    port=${port}    pdu_device=pdu_ru_1
    ${release}    Get program version based on gNB active version
    ${Supplementary_info}    Run Keyword If    "${release}"=="master"    Set Variable    RU connection was lost in runtime. RU power loss.    ELSE
    ...    Set Variable    RU connection was lost in runtime;RU power loss
    Wait Until Keyword Succeeds    5 min    10 sec    Check Specific Alarm in Alarm List    type=Active
    ...    faultId=10		Supplementary=${Supplementary_info}
    pdu.power on    port=${port}    pdu_device=pdu_ru_1
    Wait Until Keyword Succeeds    5 min    10 sec    Verify all cells should be onair
    [Teardown]    run keyword and ignore error    Perform RU Power On    ru_index=${1}

CB005763-BA_Dying_Gasp_alarm_check_RF_split_AZNA
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    FOR    ${index}    IN RANGE    0    6
        ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.__class__.__name__}
        ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.addr}
        ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.port_no}
        ${ru_index}    evaluate    ${index}+1
        log to console    for ru ${ru_index}, model is ${model}, pb ip is ${address}, pb port is ${port}
        pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_${ru_index}
        pdu.power off    port=${port}    pdu_device=pdu_ru_${ru_index}
    ${release}    Get program version based on gNB active version
    ${Supplementary_info}    Run Keyword If    "${release}"=="master"    Set Variable    RU connection was lost in runtime. RU power loss.    ELSE
    ...    Set Variable    RU connection was lost in runtime;RU power loss
    Wait Until Keyword Succeeds    5 min    10 sec    Check Specific Alarm in Alarm List    type=Active
    ...    faultId=10		Supplementary=${Supplementary_info}
        pdu.power on    port=${port}    pdu_device=pdu_ru_${ru_index}
        Wait Until Keyword Succeeds    5 min    10 sec    Verify all cells should be onair
    END
    [Teardown]    Run Keywords    run keyword and ignore error    Perform RU Power On    ru_index=${1}    AND
    ...    run keyword and ignore error    Perform RU Power On    ru_index=${2}    AND
    ...    run keyword and ignore error    Perform RU Power On    ru_index=${3}    AND
    ...    run keyword and ignore error    Perform RU Power On    ru_index=${4}    AND
    ...    run keyword and ignore error    Perform RU Power On    ru_index=${5}    AND
    ...    run keyword and ignore error    Perform RU Power On    ru_index=${6}

General_SISO_RU_power_off_power_on_loop
    [Arguments]     ${Max_loop}=${100}
    FOR    ${index_new}    IN RANGE    0    ${Max_loop}
        log to console    Loop ${index_new}
        Connect to gnb coam via ssl
        Run Keyword and Continue on Failure    Power_off_and_check_alarm_and_power_on_rus
        Sleep    30
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

Power_off_and_check_alarm_and_power_on_rus
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_numbers}    get length    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    log to console    ru_numbers: ${ru_numbers}
    FOR    ${index}    IN RANGE    0    ${ru_numbers}
        ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.__class__.__name__}
        ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.addr}
        ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.port_no}
        ${ru_index}    evaluate    ${index}+1
        log to console    for ru ${ru_index}, model is ${model}, pb ip is ${address}, pb port is ${port}
        pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_${ru_index}
        pdu.power off    port=${port}    pdu_device=pdu_ru_${ru_index}
        Wait Until Keyword Succeeds    5 min    10 sec    Check Specific Alarm in Alarm List    type=Active
		...    faultId=10    Supplementary=RU connection was lost in runtime;RU power loss
        pdu.power on    port=${port}    pdu_device=pdu_ru_${ru_index}
        Wait Until Keyword Succeeds    5 min    10 sec    Verify all cells should be onair
    END

Check one Alarm in Alarm List
    [Arguments]    ${faultId}    ${stamp_case_start}=${None}    ${type}=Active    ${Supplementary}=${None}
    ...    ${expect}=${True}    ${connection}=GNB_OAM
     ${alarms_list}    Run Keyword If    '${type}'=='Active'
     ...    coam.get_active_alarms    connection=${connection}    timeout=100
     ...    ELSE IF   '${type}'=='History'
     ...    coam.get_historic_alarms    connection=${connection}    timeout=100
     ${status}    check_alarm_in_Active_Or_History_Alarmlist    alarmlist=${alarms_list}
     ...    faultId=${faultId}    supplementary=${Supplementary}    stamp_case_start=${stamp_case_start}
    Should be True    '${status}'=='${expect}'

Check RU Specific Alarm in Alarm List
    [Arguments]    ${faultId}    ${stamp_case_start}=${None}    ${type}=Active    ${Supplementary}=${None}
    ...    ${ru_sn}=${None}    ${expect}=${True}    ${connection}=GNB_OAM
     ${alarms_list}    Run Keyword If    '${type}'=='Active'
     ...    coam.get_active_alarms    connection=${connection}    timeout=100
     ...    ELSE IF   '${type}'=='History'
     ...    coam.get_historic_alarms    connection=${connection}    timeout=100
     ${status}    check_alarm_in_Active_Or_History_Alarmlist_RU_SN    alarmlist=${alarms_list}    faultId=${faultId}
     ...    ru_sn=${ru_sn}    supplementary=${Supplementary}    stamp_case_start=${stamp_case_start}
    Should be True    '${status}'=='${expect}'

Check Specific Alarm in Alarm List
    [Arguments]    ${faultId}    ${stamp_case_start}=${None}    ${type}=Active    ${Supplementary}=${None}
    ...    ${expect}=${True}    ${connection}=GNB_OAM
     ${alarms_list}    Run Keyword If    '${type}'=='Active'
     ...    coam.get_active_alarms    connection=${connection}    timeout=100
     ...    ELSE IF   '${type}'=='History'
     ...    coam.get_historic_alarms    connection=${connection}    timeout=100
     ${status}    check_alarm_in_Active_Or_History_Alarmlist_supplAlarmInfo    alarmlist=${alarms_list}
     ...    faultId=${faultId}    supplementary=${Supplementary}    stamp_case_start=${stamp_case_start}
    Should be True    '${status}'=='${expect}'