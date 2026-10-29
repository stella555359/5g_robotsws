*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Keywords ***
General_SiSo_RF_Fault_Signature_FID_4590
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to trigger fault 4590 under some pipe broken scenario for RU
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 24.12.2024 - - Created, https://jiradc.ext.net.nokia.com/browse/LEOPARD-2323
    ...    *******************
    ...    Owner_shifu.lan@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}    ${made_type}=rf7
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    ${keyword_name}    set variable    Connect to Radio and Operate and Check ${made_type}
    run keyword    ${keyword_name}    ru_index=${ru_index}
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4590
    COAM Wait gnb And Cells ready    timeout=15min    gnb_type=${gNb_CuType}

Connect to Radio and Operate and Check rf7
    [Arguments]  ${ru_index}    ${asik_alias}=ASIK Master
    connect to common unit master    alias=${asik_alias}
    ${ru_alias}    set variable    RU_${ru_index}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=${ru_alias}    asik_alias=${asik_alias}
    Execute Command On RF7 Thor Chip    ru_index=${ru_index}    ru_alias=${ru_alias}
    Wait Until Keyword Succeeds    5min    5s    RU Should Be Power Off    ru_index=${ru_index}
    ${fault_signature}    Create Dictionary    rfm_gpp=lastFailedServiceClassId=portsdispatcher,lastFailedServiceInstanceId=16
    ...    info=resetCause=SlaveRecoveryReset(14),resetSignal=SOFT_RESET_SW_RESET_N_REQ(41)
    Wait until keyword succeeds    5min    30s    Expect Fault Should Present    faultId=10    configObjectName=RMOD-${ru_index}
    Wait until keyword succeeds    5min    5s    Expect Fault Should Present    faultId=4590
    ...    fault_signature_rfmgpp=${fault_signature['rfm_gpp']}    fault_signature_info=${fault_signature['info']}
    Wait until keyword succeeds    5min    30s    Expect Fault Should Absent    faultId=10
    Wait until keyword succeeds    5min    5s    Expect Fault Should Absent    faultId=4590
    [Teardown]    csn.disconnect    connection=${asik_alias}

Execute Command On RF7 Thor Chip
    [Arguments]  ${ru_index}    ${ru_alias}    ${thor_ip}=192.168.101.17
    ...    ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ${query_pid_cmd}    Set Variable    ssh ${ru_username}@${thor_ip} ps -ef |grep 'portsdispatcher::16' |grep -v grep |awk '{print $2}'
    ${output}    csn.Execute    command=${query_pid_cmd}    connection=${ru_alias}
    ${match}    ${pid}    Should Match Regexp    ${output}    \\r\\n(\\d+)\\r\\n
    Sleep    1 sec
    ${kill_pid_cmd}    Set Variable    ssh ${ru_username}@${thor_ip} sudo kill -9 ${pid}
    csn.Execute    command=${kill_pid_cmd}    connection=${ru_alias}
