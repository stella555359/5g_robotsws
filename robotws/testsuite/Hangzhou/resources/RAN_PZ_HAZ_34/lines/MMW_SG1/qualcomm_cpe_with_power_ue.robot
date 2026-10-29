*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Keywords ***
attach UE for qualcomm CPE with retry
    [Documentation]  Author: Liu Zheng
    ...          step1: require UE
    ...          step2: UE attach
    ...          step3: check UE attach result
    ...          step4: if UE attach failed, re-attach with WA
    [Arguments]    ${ue_type}=${UE_TYPE}    ${retry_time}=2    ${ue_index}=${0}    ${prepare_ue_needed}=${True}
    ...    ${is_ue_reboot}=${False}    ${cell_id}=None   ${detach_request}=${True}
    Kill At command process
    Start the UE Proxy if not exist
    run keyword if    ${prepare_ue_needed}==${True}     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword if    ${detach_request}==${True}
    ...       Run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    ${detach_time}    Set variable    ${0}
    ${attach_retry_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
        Run keyword and ignore error    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        ${attach_status}   run keyword and return status    power_ue.Verify attach
        ...    ue_type=${ue_type}    ue_index=${ue_index}    cell_id=${cell_id}
        Exit for loop if    ${attach_status}
        Run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
        ${detach_time}    Evaluate    ${detach_time}+1
        Log to console   UE_${ue_index} attached failed, retry detach time ${detach_time}
        Exit for loop if    '${detach_time}' == '${retry_time}'
        run keyword if   '${attach_status}'=='${False}' or ${is_ue_reboot}
        ...    Run keywords    run keyword and ignore error    qualcomm.UE reboot   ue_index=${ue_index}    AND
        ...    Sleep    360s    Waiting for UE to reboot, and due to UTETAF-6309, need wait more time to do next attach...
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE_${ue_index} attach with ${retry_time} times and still failed
    ${attach_retry_time}    Evaluate    ${i}+1
    [Return]     ${attach_retry_time}

Kill At command process
    [Documentation]  Author: Wang Yixiang
    ...    Description: Kill at command process if APP start on UE CRTL PC
    ...    At command will lead to automation attach failed
    [Arguments]  ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    connection_alias_store.Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ...    cpc_ip=${tl.ues[0].ue_pc_address}
    ...    cpc_username=${tl.ues[0].ue_pc_login}
    ...    cpc_password=${tl.ues[0].ue_pc_password}

    ${is_windows_atCom_exits}    ssh_common_commands.is_process_exist    process_name=ATCom.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    ${cmd_kill_atCom_process}    Set variable    taskkill /f /im ATCom.exe
    Run keyword if    ${is_windows_atCom_exits}==${True}
    ...    csn.Execute   command=${cmd_kill_atCom_process}    connection=${cpc_alias}
    ${is_atCom_process_exits_after_kill}    ssh_common_commands.is_process_exist    process_name=ATCom.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    Should not be true    ${is_atCom_process_exits_after_kill}

    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=${cpc_alias}

Restart the UE Proxy
    [Documentation]  Author: Wang Yixiang
    ...    Description: Kill UE proxy and start again
    ...    python -m taf.ue.proxy.run_ue_proxy
    [Arguments]  ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    connection_alias_store.Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ...    cpc_ip=${tl.ues[0].ue_pc_address}
    ...    cpc_username=${tl.ues[0].ue_pc_login}
    ...    cpc_password=${tl.ues[0].ue_pc_password}

    # kill ue proxy on UE CTRL PC if exist
    ${is_windows_proxy_exits}    ssh_common_commands.is_process_exist    process_name=python.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    ${cmd_kill_proxy_process}    Set variable    taskkill /f /im python.exe
    Run keyword if    ${is_windows_proxy_exits}==${True}
    ...    csn.Execute   command=${cmd_kill_proxy_process}    connection=${cpc_alias}
    ...    ELSE   Log to console    No need to kill ue proxy on UE CTRL PC as process is not started
    ${is_proxy_process_exits_after_kill}    ssh_common_commands.is_process_exist    process_name=python.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    Should not be true    ${is_proxy_process_exits_after_kill}

    # get python install path
    ${python_path_raw}    csn.Execute   command=which python    connection=${cpc_alias}
    ${python_path}    Strip String     ${python_path_raw}

    # kill ue proxy on cygwin is exist
    ${cygwin_process_name}   Set variable    ${python_path}
    ${is_old_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${cygwin_process_name}    connection=${cpc_alias}
    Run keyword if    ${is_old_cygwin_process_exits}==${True}
    ...    csn.Execute   command=ps -ef|grep ${cygwin_process_name}|grep -v grep| awk '{print $2}' |xargs kill -9
    ...    connection=${cpc_alias}
    ${is_old_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${cygwin_process_name}    connection=${cpc_alias}
    Should not be true    ${is_old_cygwin_process_exits}

    # start new ue proxy process on cygwin
    ${cygwin_run_proxy}   Set variable     ${python_path} -m taf.ue.proxy.run_ue_proxy
    csn.send_command   command=${cygwin_run_proxy}    connection=${cpc_alias}
    ${is_new_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${cygwin_process_name}    connection=${cpc_alias}
    Should be true    ${is_new_cygwin_process_exits}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=${cpc_alias}

Start the UE Proxy if not exist
    [Documentation]  Author: Wang Yixiang
    ...    Description: Start UE Proxy if not exist
    ...    python -m taf.ue.proxy.run_ue_proxy
    [Arguments]  ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    connection_alias_store.Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ...    cpc_ip=${tl.ues[0].ue_pc_address}
    ...    cpc_username=${tl.ues[0].ue_pc_login}
    ...    cpc_password=${tl.ues[0].ue_pc_password}

    # check ue proxy on UE CTRL PC if exist
    ${is_windows_proxy_exits}    ssh_common_commands.is_process_exist    process_name=python.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}

    # get python install path
    ${python_path_raw}    csn.Execute   command=which python    connection=${cpc_alias}
    ${python_path}    Strip String     ${python_path_raw}

    # check ue proxy on cygwin is exist
    ${cygwin_process_name}   Set variable    ${python_path}
    ${is_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${cygwin_process_name}    connection=${cpc_alias}

    # start new ue proxy process on cygwin
    run keyword if    ${is_windows_proxy_exits}==${False} and ${is_cygwin_process_exits}==${False}
    ...    Start a new UE proxy on cygwin    python_path=${python_path}    cpc_alias=${cpc_alias}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=${cpc_alias}

Start a new UE proxy on cygwin
    [Documentation]  Author: Wang Yixiang
    ...    Description: Start new UE proxy on cygwin
    ...    python -m taf.ue.proxy.run_ue_proxy
    [Arguments]  ${python_path}    ${cpc_alias}
    ${cygwin_run_proxy}   Set variable     ${python_path} -m taf.ue.proxy.run_ue_proxy
    csn.send_command   command=${cygwin_run_proxy}    connection=${cpc_alias}
    ${is_new_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${python_path}    connection=${cpc_alias}
    Should be true    ${is_new_cygwin_process_exits}

