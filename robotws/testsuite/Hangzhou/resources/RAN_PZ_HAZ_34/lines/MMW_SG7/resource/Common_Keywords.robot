*** Settings ***
Documentation    This is for common setup and teardown keywords

Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/Common_Resources.robot


*** Variables ***
${UE_PC_IP}                 ${tl.ues[0].ssh_connection_details.addr}
${UE_PC_USERNAME}           ${tl.ues[0].ssh_connection_details.username}
${UE_PC_PASSWD}             ${tl.ues[0].ssh_connection_details.password}

*** Keywords ***
Setup BTS env and set keyword prority
  [Arguments]    ${scf}=SCF_SBTS00.xml    ${swconfig}=swconfig.txt
  Set Library Search Order     admin
  Common Suite Setup And Setup BTS env   scf=${scf}    swconfig=${swconfig}

Setup 2BTS env and set keyword prority
  [Arguments]    ${scf1}=SCFC_1.xml   ${scf2}=SCFC_2.xml   ${swconfig1}=swconfig.txt   ${swconfig2}=swconfig_2.txt
  Set Library Search Order     admin
  Common Suite Setup And Setup 2BTS env   scf1=${scf1}    scf2=${scf2}    swconfig1=${swconfig1}
  ...    swconfig2=${swconfig2}


Check CA ULDL Throughput
    [Arguments]    ${PSCell_List}    ${CC_num}    ${dl_tput}    ${ul_tput}    ${duration}=30    ${tput_ratio}=0.95
    Builtin.Log    ${PSCell_List}
    ${ul_expect}    Set Variable    ${${ul_tput}*${tput_ratio}}
    ${dl_expect}    Set Variable    ${${dl_tput}*${tput_ratio}}
    ${tput_log}    Run keyword and continue on failure    power_ue.Collect Tput
	...    ue_type=${ue_type}    duration=${duration}    check_source=aasyslog
    ${PSCell_Tput}    Run keyword and continue on failure    power_ue.Check Bi Tput
    ...    ue_type=${ue_type}    log=${tput_log}    cells=${PSCell_List}
	...    ultarget_throughput=${0}    dltarget_throughput=${0}    check_source=aasyslog
    ${all_dl_tput}    Set Variable    0
    ${all_ul_tput}    Set Variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${all_ul_tput}    Evaluate    ${all_ul_tput}+${PSCell_Tput[0][${id}]['average']}
        ${all_dl_tput}    Evaluate    ${all_dl_tput}+${PSCell_Tput[1][${id}]['average']}
    END
    Should Be True    ${all_ul_tput} > ${ul_expect}
    Should Be True    ${all_dl_tput} > ${dl_expect}


SA Attach UE And Verify
    [Arguments]    ${cell_id}    ${ue_index}=${0}
    Set Test Variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}
    Start UE Attach With Power UE    ue_index=${ue_index}    4G_check=false
    power_ue.Verify Attach    ue_type=${ue_type}    ue_index=${ue_index}    cell_id=${cell_id}


Restart UE Proxy
    [Documentation]  Author: Flora Du
    ...    Description: Kill UE proxy and start again
    ...    python -m taf.ue.proxy.run_ue_proxy
    [Arguments]  ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    connection_alias_store.Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ...    cpc_ip=${UE_PC_IP}
    ...    cpc_username=${UE_PC_USERNAME}
    ...    cpc_password=${UE_PC_PASSWD}

    log to console    kill ue proxy on UE CTRL PC if exist
    ${is_windows_proxy_exits}    ssh_common_commands.is_process_exist    process_name=python.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    ${cmd_kill_proxy_process}    Set variable    taskkill /f /im python.exe
    Run keyword if    ${is_windows_proxy_exits}==${True}
    ...    csn.Execute   command=${cmd_kill_proxy_process}    connection=${cpc_alias}
    ...    ELSE   Log to console    No need to kill ue proxy on UE CTRL PC as process is not started
    ${is_proxy_process_exits_after_kill}    ssh_common_commands.is_process_exist    process_name=python.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    Should not be true    ${is_proxy_process_exits_after_kill}

    log to console    get python install path
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

    log to console    start new ue proxy process on cygwin
    ${cygwin_run_proxy}   Set variable     ${python_path} -m taf.ue.proxy.run_ue_proxy
    csn.send_command   command=${cygwin_run_proxy}    connection=${cpc_alias}
    ${is_new_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${cygwin_process_name}    connection=${cpc_alias}
    Should be true    ${is_new_cygwin_process_exits}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=${cpc_alias}


Start UE Proxy if not exist
    [Documentation]  Author: Flora Du
    ...    Description: Start UE Proxy if not exist
    ...    python -m taf.ue.proxy.run_ue_proxy
    [Arguments]  ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    connection_alias_store.Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ...    cpc_ip=${UE_PC_IP}
    ...    cpc_username=${UE_PC_USERNAME}
    ...    cpc_password=${UE_PC_PASSWD}


    log to console    check ue proxy on UE CTRL PC if exist
    ${is_windows_proxy_exits}    ssh_common_commands.is_process_exist    process_name=python.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}

    log to console    get python install path
    ${python_path_raw}    csn.Execute   command=which python    connection=${cpc_alias}
    ${python_path}    Strip String     ${python_path_raw}

    log to console    check ue proxy on cygwin is exist
    ${cygwin_process_name}   Set variable    ${python_path}
    ${is_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${cygwin_process_name}    connection=${cpc_alias}

    log to console    start new ue proxy process on cygwin
    run keyword if    ${is_windows_proxy_exits}==${False} and ${is_cygwin_process_exits}==${False}
    ...    Start new UE proxy on cygwin    python_path=${python_path}    cpc_alias=${cpc_alias}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=${cpc_alias}

Start new UE proxy on cygwin
    [Documentation]  Author: Flora Du
    ...    Description: Start new UE proxy on cygwin
    ...    python -m taf.ue.proxy.run_ue_proxy
    [Arguments]  ${python_path}    ${cpc_alias}
    ${cygwin_run_proxy}   Set variable     ${python_path} -m taf.ue.proxy.run_ue_proxy
    csn.send_command   command=${cygwin_run_proxy}    connection=${cpc_alias}
    ${is_new_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${python_path}    connection=${cpc_alias}
    Should be true    ${is_new_cygwin_process_exits}

Connect to UE Control PC
    [Arguments]    ${cpc_ip}=${UE_PC_IP}
    ...    ${cpc_usrname}=${UE_PC_USERNAME}
    ...    ${cpc_passwd}=${UE_PC_PASSWD}
    ${ret}    Wait Until Keyword Succeeds    5min    20s
    ...   csn.Connect to   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=cpc_0
    should be true     ${ret}

Ask scout to analyze scf
  [Arguments]    ${remove_postfix}=${True}
  # ask scout to analyze scf
  ${hostname1}    Execute Cmd On Pc    cat /etc/hostname | sed 's/-/_/g'
  ${hostname2}    Evaluate    re.sub("_1$", "", re.sub("_2$", "", "${host_name1}"))    re
  ${hostname}    set variable if    ${remove_postfix}    ${hostname2}    ${hostname1}
  scout.setup_scout    scout_testline_name=${hostname}
  scout.request_scf

Common Test Teardown with scout
  [Arguments]    ${remove_postfix}=${True}
  ${status}    run keyword and return status    Ask scout to analyze scf    remove_postfix=${False}
  run keyword if  not ${status}    run keyword and ignore error    Ask scout to analyze scf    remove_postfix=${True}
  Common Test Teardown And Stop Capture Logs
