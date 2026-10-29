*** Settings ***
Documentation
...              tingting.zhong@nokia-sbell.com

Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
*** Variables ***

*** Keywords ***
Check All Components Status
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    ...    component_type=site/bbmod/rmod/cell/no
    [Arguments]    ${operation_component}=cell   ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    ...    ${smod_checktime}=5min    ${bbmod_checktime}=5min    ${rmod_checktime}=10min    ${x2link_checktime}=5min    ${cell_checktime}=15min
    ...    ${interval}=10s    ${is_asod_asoe_asof}=${False}
    ${component_list}    create list    site    smod    bbmod    rmod    cell    no
    ${component_index}    get index from list    ${component_list}    ${operation_component}
    ${smod_checktime}    set variable if    ${component_index}<=${1}   ${smod_checktime}    ${interval}
    ${bbmod_checktime}    set variable if    ${component_index}<=${2}   ${bbmod_checktime}    ${interval}
    ${rmod_checktime}    set variable if    ${component_index}<=${3}     ${rmod_checktime}    ${interval}
    ${cell_checktime}    set variable if    ${component_index}<=${4}     ${cell_checktime}    ${interval}
    ${x2link_checktime}    set variable if    ${component_index}<=${4}     ${x2link_checktime}    ${interval}
    Wait until keyword succeeds    ${smod_checktime}    ${interval}     COAM Check GNB ASIK status     connection=${connection}
    Run keyword if    ${is_asod_asoe_asof}==${False}
    ...    Wait until keyword succeeds    ${bbmod_checktime}    ${interval}     COAM Check GNB ABIL status     connection=${connection}
    Wait until keyword succeeds    ${rmod_checktime}    ${interval}     COAM Check GNB RU status     connection=${connection}
    Run keyword if    '${gnb_type}'!='SA'
    ...    Wait until keyword succeeds    ${x2link_checktime}    ${interval}     COAM Check X2 link status from GNB    connection=${connection}
    Wait until keyword succeeds    ${cell_checktime}    ${interval}     verify all cells should be onair    connection=${connection}

Get Alarm Fault Id List
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    ...    alarm_type=active/history
    [Arguments]    ${alarm_type}=active   ${connection}=GNB_OAM    ${load_history}=${False}
    ${fault_list}    create list
    ${alarms_list}    run keyword if    '${alarm_type}'=='active'    coam.get_active_alarms    connection=${connection}
    ...    ELSE    coam.get_historic_alarms    load_history=${load_history}    connection=${connection}    timeout=100
    FOR    ${alarm}    IN    @{alarms_list}
        append to list    ${fault_list}    ${alarm['faultId']}
    END
    [Return]    ${fault_list}

Check GNB Ping Enable
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${gnb_index}=0    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    ${times}=5
    ${output}=   Run    sudo ping -c ${times} -W 10 ${bts_host}
    Should Contain    ${output}    ${times} packets transmitted, ${times} received, 0% packet loss

Check GNB Ping Disable
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${gnb_index}=0    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    ${times}=5
    ${output}=   Run    sudo ping -c ${times} -W 10 ${bts_host}
    Should Contain    ${output}    ${times} packets transmitted, 0 received, 100% packet loss

Check cell should be disabled
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}   ${connection}=GNB_OAM
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_id}    connection=${connection}
    Cell Should Be Disabled   cell_idx=${cell_id}   cell_group_idx=${cellgrp_id}    connection=${connection}

Check status after bts operation
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${operation_component}    ${before_active_fault_list}   ${before_history_fault_list}
    ...    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}    ${is_asod_asoe_asof}=${False}
    Check All Components Status    operation_component=${operation_component}    gnb_type=${gnb_type}    is_asod_asoe_asof=${is_asod_asoe_asof}
    ${after_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${after_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    FOR    ${alarm}    IN    @{after_active_fault_list}
        run keyword and continue on failure    list should contain value    ${before_active_fault_list}    ${alarm}
    END
    FOR    ${alarm}    IN    @{after_history_fault_list}
        run keyword and continue on failure    list should contain value    ${before_history_fault_list}    ${alarm}
    END

Check status after rat reset
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${gnb_type}=${gNb_CuType}    ${connection}=GNB_OAM
    ...    ${is_asod_asoe_asof}=${False}
    ${ext_active_allowd_list}    create list    ${8150}
    ${ext_history_allowd_list}    create list    ${7300}    ${7319}    ${8150}    ${7509}    ${4293}    ${4592}    ${7313}
    ${new_activre_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_activre_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=bbmod
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}
    ...    is_asod_asoe_asof=${is_asod_asoe_asof}

Check status after rmod reset
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${gnb_type}=${gNb_CuType}    ${connection}=GNB_OAM
    ${ext_active_allowd_list}    create list    ${8150}
    ${ext_history_allowd_list}    create list    ${7300}    ${7319}    ${8150}    ${7509}    ${4293}    ${4592}
    ${new_activre_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_activre_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=rmod
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}

Check status after rmod power reset
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    ${ext_active_allowd_list}    create list    ${8150}
    ${ext_history_allowd_list}    create list    ${7300}    ${7319}    ${10}    ${8150}    ${7509}    ${4293}
    ${new_activre_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_activre_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=rmod
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}

Check status after bbmod reset
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    ${ext_active_allowd_list}    create list    ${8150}
    ${ext_history_allowd_list}    create list    ${7300}    ${7319}    ${10}    ${8150}    ${7509}    ${4293}
    ${new_activre_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_activre_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=bbmod
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}

Check status after site reset
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    ${ext_active_allowd_list}    create list    ${4592}    ${8150}
    ${ext_history_allowd_list}    create list    ${7300}    ${7319}    ${4592}    ${8150}    ${7313}    ${61631}    ${7509}    ${4293}
    ${new_activre_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_activre_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=site
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}

Check status after cell lock unlcok
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    ${ext_active_allowd_list}    create list    ${8150}
    ${ext_history_allowd_list}    create list    ${7300}    ${7319}    ${8150}    ${7509}    ${4293}
    ${new_activre_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_activre_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=cell
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}

Check status after rmod lock unlock
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${gnb_type}=${gNb_CuType}    ${connection}=GNB_OAM
    ${ext_active_allowd_list}    create list    ${8150}
    ${ext_history_allowd_list}    create list    ${7300}    ${7319}    ${8150}    ${7509}    ${4293}
    ${new_activre_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_activre_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=rmod
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}

Check status after bts lock unlock
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${gnb_type}=${gNb_CuType}    ${connection}=GNB_OAM
    ${ext_active_allowd_list}    create list    ${8150}
    ${ext_history_allowd_list}    create list    ${7300}    ${7319}    ${8150}    ${7509}    ${4293}
    ${new_activre_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_activre_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=cell
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}

Check status after bts block unblock
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${gnb_type}=${gNb_CuType}    ${connection}=GNB_OAM
    ${ext_active_allowd_list}    create list    ${4592}    ${8150}
    ${ext_history_allowd_list}    create list    ${7300}    ${7319}    ${8150}    ${7313}    ${61631}    ${7509}    ${4293}
    ${new_activre_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_activre_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=site
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}

Check status of the cell onair fail
    [Documentation]    Owner_rong.2.wu@nokia-sbell.com
    ${status}    Run Keyword And Return Status    Verify all cells should be onair
    Should Not Be True    ${status}
