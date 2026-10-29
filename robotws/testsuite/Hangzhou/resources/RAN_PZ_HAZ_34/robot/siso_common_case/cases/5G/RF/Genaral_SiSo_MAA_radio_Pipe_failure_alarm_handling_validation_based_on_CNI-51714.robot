*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot

*** Keywords ***
Genaral_SiSo_MAA_radio_Pipe_failure_alarm_handling_validation_based_on_CNI-51714
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to trigger alarm1911 under some pipe broken scenario for Made 1 RU
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 27.07.2023 - - Created https://jiradc.ext.net.nokia.com/browse/LEOPARD-1357
    ...    - 19.12.2023 - - Add made_type, made1/made2, https://jiradc.ext.net.nokia.com/browse/LEOPARD-1358
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${ru_index}=1    ${made_type}=made1
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history
    ${keyword_name}    set variable    Connect to Radio and Operate and Check ${made_type}
    run keyword        ${keyword_name}                ru_index=${ru_index}
    ...                                               before_active_fault_list=${before_active_fault_list}
    ...                                               before_history_fault_list=${before_history_fault_list}

Connect to Radio and Operate and Check made1
    [Arguments]  ${ru_index}    ${before_active_fault_list}    ${before_history_fault_list}
    connect to common unit master    alias=ASIK Master
    Connect to made and Run Command    ru_index=${ru_index}    ip=192.168.101.2    alias=made1    proxy=RU_${ru_index}
    Wait until keyword succeeds    5 min    10 sec
    ...    Expect Fault Should Present    faultId=1911    severity=Major    configObjectName=RMOD-${ru_index}
    ${cell_list}    get all cell id    ru_index=${ru_index}
    Cell status Should Be Degraded    cell_list=${cell_list}
    ${start_server_time}  ${start_uptime}    Connect to RU and Get Uptime    ru_index=${ru_index}
    Connect to made and Run Command    ru_index=${ru_index}    ip=192.168.101.4    alias=made3    proxy=RU_${ru_index}
    Connect to made and Run Command    ru_index=${ru_index}    ip=192.168.101.5    alias=made4    proxy=RU_${ru_index}
    Wait until keyword succeeds    5 min    5 sec    RU Should Be Offline    ru_index=${ru_index}
    Check status after radio Pipe failure rmod auto reset    before_active_fault_list=${before_active_fault_list}
    ...    before_history_fault_list=${before_history_fault_list}
    ${end_server_time}    ${end_uptime}    Connect to RU and Get Uptime    ru_index=${ru_index}
    RU Should Be Reset    start_server_time=${start_server_time}    end_server_time=${end_server_time}
    ...    uptime=${end_uptime}
    [Teardown]    csn.disconnect    connection=ASIK Master

Connect to Radio and Operate and Check made2
    [Arguments]  ${ru_index}    ${before_active_fault_list}    ${before_history_fault_list}
    connect to common unit master    alias=ASIK Master
    Connect to made and Run Command    ru_index=${ru_index}    ip=192.168.101.2    alias=made1    proxy=RU_${ru_index}
    sleep    5
    Check All Components Status    operation_component=no
    Connect to made and Run Command    ru_index=${ru_index}    ip=192.168.101.9    alias=made8    proxy=RU_${ru_index}
    Wait until keyword succeeds    5 min    10 sec
    ...    Expect Fault Should Present    faultId=1911    severity=Major    configObjectName=RMOD-${ru_index}
    ...    supplementary=8 RX faulty pipe(s)
    ${cell_list}    get all cell id    ru_index=${ru_index}
    Cell status Should Be Degraded    cell_list=${cell_list}
    ${start_server_time}  ${start_uptime}    Connect to RU and Get Uptime    ru_index=${ru_index}
    Connect to made and Run Command    ru_index=${ru_index}    ip=192.168.101.4    alias=made3    proxy=RU_${ru_index}
    Connect to made and Run Command    ru_index=${ru_index}    ip=192.168.101.5    alias=made4    proxy=RU_${ru_index}
    Connect to made and Run Command    ru_index=${ru_index}    ip=192.168.101.6    alias=made5    proxy=RU_${ru_index}
    Wait until keyword succeeds    5 min    5 sec    RU Should Be Offline    ru_index=${ru_index}
    Check status after radio Pipe failure rmod auto reset    before_active_fault_list=${before_active_fault_list}
    ...    before_history_fault_list=${before_history_fault_list}
    ${end_server_time}    ${end_uptime}    Connect to RU and Get Uptime    ru_index=${ru_index}
    RU Should Be Reset    start_server_time=${start_server_time}    end_server_time=${end_server_time}
    ...    uptime=${end_uptime}
    [Teardown]    csn.disconnect    connection=ASIK Master

Connect to made and Run Command
    [Arguments]  ${ru_index}    ${ip}=192.168.101.2    ${cmd}=sudo devmem 0xFC98025C 32 0x0    ${alias}=made1    ${proxy}=RU_1
    ...          ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...          ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    csn.Connect to   hostname=${ip}   username=${ru_username}   password=${ru_password}   proxy=${proxy}   alias=${alias}
    ${result}   csn.execute   command=${cmd}    connection=${alias}
    [Teardown]    run keywords    run keyword and ignore error    csn.disconnect    connection=${alias}    AND
    ...                           run keyword and ignore error    csn.disconnect    connection=RU_${ru_index}
    [Return]  ${result}

Connect to RU and Get Uptime
    [Arguments]  ${ru_index}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    ${server_time}  ${uptime}    Get RU Uptime Result    ru_alias=RU_${ru_index}
    [Teardown]    run keyword and ignore error  csn.disconnect    connection=RU_${ru_index}
    [Return]  ${server_time}  ${uptime}

Check status after radio Pipe failure rmod auto reset
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${gnb_type}=${gNb_CuType}    ${connection}=GNB_OAM
    ${ext_active_allowd_list}    create list    ${8150}
    ${ext_history_allowd_list}    create list    ${7300}    ${7319}    ${8150}    ${4592}    ${1911}    ${1920}
    ...    ${61649}    ${7313}    ${1907}    ${4420}
    ${new_active_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_active_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=rmod
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}
