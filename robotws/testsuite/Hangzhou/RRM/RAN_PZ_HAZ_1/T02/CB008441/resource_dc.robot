*** Settings ***
Documentation
Resource    ../Resources_pet/pet_allm.robot

*** Variables ***
${wts_cfg}    ${CURDIR}/basic_setup_dc.cfg

${bler_cmd_str1}    bler_testmode_nr profile_id=2 target_mcs=3
${bler_cmd_str2}    target_bler=100,100,100,98,95,90,50,10,5,1,0.5,0.1,0,0,0 mcs_table=qam256
${bler_cmd_str3}    delete=yes
${tcp_congestion_alg}    sudo sysctl -w net.ipv4.tcp_congestion_control=cubic

&{vcu_para_1}
...    distname=MRBTS-1/NRBTS-1    operation_type=replace
...    parameter_path=/actServiceAwarePDCPConfig   value=true
&{vcu_para_2}
...    distname=MRBTS-1/NRBTS-1/NRDRB-11    operation_type=replace
...    parameter_path=/queuingDelayDiscardStart    value=1
&{vcu_para_3}
...    distname=MRBTS-1/NRBTS-1  operation_type=replace
...    parameter_path=/drbInactivityTimerSA    value=3600
&{vcu_para_4}
...    distname=MRBTS-1/NRBTS-1/NRPMRNL-1    operation_type=replace
...    parameter_path=/miNrPDCPCell    value=5min
@{vcu_paras}   &{vcu_para_1}   &{vcu_para_2}  &{vcu_para_3}  &{vcu_para_4}

&{vdu_para_1}
...    distname=MRBTS-1/NRBTS-1    operation_type=replace
...    parameter_path=/actServiceAwarePDCPConfig   value=true
@{vdu_paras}   &{vdu_para_1}

*** Keywords ***
Setup for CB008441 ET
    run    cd /opt
    run    sudo mv /opt/iphy /opt/iphy_old
    run    sudo cp -r /opt/wts /opt/iphy
    run    sudo chown -R ute:ute /opt/iphy
    log to console  \nreset AP Wait for 180s....
    run    sshiphy reboot
    sleep  180

    common_case_setup_for_pet_aic
    setup_for_ap
    log to console  \nReset EGate
    run keyword and ignore error  wts.execute_egate_command  cmd=re
    sleep  10
    setup_for_ap  wts_cfg=${wts_cfg}  init_wts=YES
    wait_until_found_expect_msg_in_egate_console_log  SystemInformationBlockType[123]-NR   expect_times=12  timeout=1200
    ${bler_test_cmd}    Catenate    ${bler_cmd_str1}    ${bler_cmd_str2}
    log to console  \nset bler test mode: ${bler_test_cmd}
    wts.execute_egate_command  cmd=${bler_test_cmd}
    wts.execute_egate_command  cmd=ue_testmode_set_nr id=51 testmode=bler action=activate profile_id=2
    wts.execute_egate_command  cmd=ue_testmode_set_nr id=52 testmode=bler action=activate profile_id=2
    run process  ${tcp_congestion_alg}  shell=true  alias=tcp_congestion_alg
    ${output}=  get process result  tcp_congestion_alg
    log to console  \n${output.stdout}

    ${distnames}  ${parameter_paths}  ${values}=  Convert NIDD Parameters  ${vcu_paras}
    ${out}   Parameter Operation    operation=parameter_update  product_type=vcu
    ...    para_list=@{parameter_paths}    value_list=@{values}    mo_list=@{distnames}
    Log to Console  \n${out}
    ${distnames}  ${parameter_paths}  ${values}=  Convert NIDD Parameters  ${vdu_paras}
    ${out}   Parameter Operation    operation=parameter_update  product_type=vdu
    ...    para_list=@{parameter_paths}    value_list=@{values}    mo_list=@{distnames}
    Log to Console  \n${out}

Teardown for CB008441 ET
    ${bler_test_cmd}    Catenate    ${bler_cmd_str1}    ${bler_cmd_str2}    ${bler_cmd_str3}
    log to console  \ndelete bler test mode: ${bler_test_cmd}
    wts.execute_egate_command  cmd=${bler_test_cmd}
    wts.execute_egate_command  re
    run  sudo pkill egate
    run  sudo pkill edaemon
    run  sudo pkill iperf3
    collect_logs_for_aic
    common_case_teardown_for_pet_aic

Remove Leading Slash
    [Arguments]    ${string}
    ${string}=    Evaluate    '${string}'.lstrip('/')
    [Return]    ${string}

Convert NIDD Parameters
    [Arguments]  ${dicts}
    ${distnames}=    Create List
    ${parameter_paths}=    Create List
    ${values}=    Create List
    FOR    ${dict}    IN    @{dicts}
        ${distname}=    Get From Dictionary    ${dict}    distname
        Append To List    ${distnames}    ${distname}
        ${parameter_path}=    Get From Dictionary    ${dict}    parameter_path
        ${parameter_path}=    Remove Leading Slash    ${parameter_path}
        Append To List    ${parameter_paths}    ${parameter_path}
        ${value}=    Get From Dictionary    ${dict}    value
        Append To List    ${values}    ${value}
    END
    [Return]    ${distnames}    ${parameter_paths}    ${values}

Prepare iperf3
    run  sudo pkill iperf3
    run  iperf3 -s -D -p 7070 -B 10.0.2.1
    run  iperf3 -s -D -p 7071 -B 10.0.2.1

attach_ue_and_activate_pdu
    [Arguments]  ${id}  ${trf_type}  ${max_retry_number}=3
    wts.execute_egate_command  cmd=set_pdu_param ue=${id} pdu=1 trf_type=${trf_type}
    FOR  ${num}  IN RANGE  ${max_retry_number}
        log to console  \nUE${id} Tried to attach ${num} time
        ${status}  run keyword and return status
        ...    wts.execute_egate_command  cmd=ue_register id=${id}  pass_regexp=REGISTRATION COMPLETE
        run keyword if  ${status}==True  Exit For Loop
    END
    run keyword if  ${status}==False
    ...    log to console  UE${id} \nREGISTRATION FAILURE for ${max_retry_number} times
    ...    ELSE  log to console  \nUE${id} Registration Success
    wts.execute_egate_command  cmd=ue_pdu_session_setup ue=${id} pdu=1 nwslice=1 gw=1  pass_regexp=Initial Context Setup Successful

detach_ue_with_power_off
    [Arguments]  ${id}
    wts.execute_egate_command  cmd=ue_deregister id=${id} ue_deregister_type=switch_off
    log to console  UE${id} Detached!

collect_logs_for_aic
    # Collect vCU syslog
    ${local_file_path}    Log Collection    start    syslog    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSyslog of VCU: ${local_file_path}
    # Collect vCU snapshot
    ${local_file_path}    Log Collection    start    snapshot    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nSnapshot of VCU: ${local_file_path}