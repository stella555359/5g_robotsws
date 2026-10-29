*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ../../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../../../T02/Common_Case/common_resource_new.robot
Library     taf.sw.scout    WITH NAME    scout
*** Variables ***
&{dcap_info}    host=192.168.255.126    port=9443    username=${None}    password=${None}

*** Keywords ***
attach_ue_and_activate_pdu
    [Arguments]  ${ue_id}=1  ${pdu_id}=1  ${trf_type}=internal
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=${trf_type}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_register id=${ue_id}
    ...    pass_regexp=REGISTRATION COMPLETE
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=Initial Context Setup Successful
    log to console  \nUE-${ue_id} PDU Setup Successfully!

detach_ue_with_power_off
    [Arguments]  ${ue_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ...    pass_regexp=UE${ue_id}: detached
    log to console  \nUE-${ue_id} Detached!

start_ue_data_traffic
    [Arguments]  ${ue_id}=1  ${dl_rate}=150  ${ul_rate}=10
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=dl mbps=${dl_rate} seconds=360
    ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 dir=ul mbps=${ul_rate} seconds=360
    ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}

stop_ue_data_traffic
    [Arguments]  ${ue_id}=1
    Log to Console  \nUE-${ue_id} Stop Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=${i} dir=dl
    ...    pass_regexp= Stopped.*Internal traffic on Ue:${ue_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    ...    pass_regexp= Stopping.*Internal traffic on Ue:${ue_id}

start_ue_big_data_traffic
    [Arguments]  ${ue_id}=1  ${dl_rate}=150  ${ul_rate}=10
    ${dl_num}  evaluate  ${dl_rate}//150+2
    FOR  ${i}  IN RANGE  1  ${dl_num}  1
        log to console  \nue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=dl mbps=150 seconds=360
        ute_wtssim.Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=dl mbps=150 seconds=360
        ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END
    ${ul_num}  evaluate  ${ul_rate}//30+2
    FOR  ${i}  IN RANGE  1  ${ul_num}  1
        ute_wtssim.Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=ul mbps=30 seconds=360
        ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END

stop_ue_big_data_traffic
    [Arguments]  ${ue_id}=1
    Log to Console  \nUE-${ue_id} Stop Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl
    ...    pass_regexp= Stopped.*Internal traffic on Ue:${ue_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    ...    pass_regexp= Stopping.*Internal traffic on Ue:${ue_id}

verify_ue_scell_status
    [Arguments]    ${ue_id}=1    ${num_of_scells}=3
    ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
    ${scell_status}=  ute_wtssim.Execute Egate Command And Wait For Data
        ...           cmd=ue_stats_nr id=${ue_id} scell=0-${num_of_scells}
        ...           pass_regexp=(CellIndex-[0-${num_of_scells}][\\s][\\s][1-9].*\\n){${num_of_cells}}
    log to console  ${scell_status}

trigger_scell_rlq_release
    [Arguments]    ${ue_id}=1  ${scell_id}=0
    ute_wtssim.Execute Egate Command
    ...  cmd=bler_testmode_nr profile_id=2 dl_bler=800,200,100
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=bler action=activate profile_id=2 scell=${scell_id}

detrigger_scell_rlq_release
    ute_wtssim.Execute Egate Command
    ...  cmd=bler_testmode_nr profile_id=2 dl_bler=800,200,100 delete=yes

Setup_for_CB006139
    # run    sudo mv /opt/iphy /opt/iphy_old
    # run    sudo cp -r /opt/wts /opt/iphy
    # run    sudo chown -R ute:ute /opt/iphy
    # run  sudo chown -R ute:ute /opt/wts

    Airphone Operation    operation=edaemon_egate_teardown
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sansa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${config_tag}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1200s

Teardown_for_CB006139
    # Airphone Operation    operation=edaemon_egate_teardown
    # ...                   product_type=gnb
    # ...                   traffic_info_dic=${None}
    # ...                   tag=${None}
    # ...                   cmd=${None}
    # ...                   pass_regexp=${None}
    # ...                   timeout=100s

    ####################### Log Collection ####################################
    ${current_time}=  Get Current Date  result_format=%H:%M:%S

Setup_eGate_Env
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Wait_for_Next_5min_Period
    log to console  \nWait for Next 5min Period...
    ${current_time}=  Get Current Date  result_format=%H:%M:%S
    log to console  \nCurrent Time: ${current_time}
    ${current_time_in_seconds}=  Convert Time  ${current_time}
    ${wait_time_to_next_5min}=  Evaluate  300 - (${current_time_in_seconds} % 300)
    log to console  \nNeed Wait for ${wait_time_to_next_5min} secnods to Start Testing
    sleep  ${wait_time_to_next_5min}

start_log_collection
    ####################### Log Collection ##################################
    # syslog
    Log to Console    \n syslog collection started...
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}

    # emil log
    Log to Console    \n emil collection started...
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    emil    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}   timeout=180
    sleep  30

    # # tti log, 需要把gnb_logs copy到执行脚本所在目录
    # ${Cell_Index}    set variable    ${1}
    # ${tti_argument}   Create Dictionary   tti_options=-C ${Cell_Index}
    # ${dict_argument}   Create Dictionary   argument=${tti_argument}
    # Log Collection    start    tti    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}

stop_log_collection
    ####################### Log Collection ####################################
    ${current_time}=  Get Current Date  result_format=%H:%M:%S
    # ${current_time_in_seconds}=  Convert Time  ${current_time}
    # run  mkdir ~/${current_time_in_seconds}
    # log to console  \nLog folder: ~/${current_time_in_seconds}

    # syslog
    ${local_file_path}    Log Collection    stop_and_download    syslog    product_type=gnb    bts_index=${0}
    Log To Console    \nSyslog log: ${local_file_path}

    # emil
    ${local_file_path}    Log Collection    stop_and_download    emil    product_type=gnb    bts_index=${0}
    Log To Console    \nEmil log: ${local_file_path}

    # # tti log
    # ${local_file_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}
    # Log To Console    \nTTI log: ${local_file_path}

    # snapshot
    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}


CB006139_DA_Configuration
    [Arguments]  ${para_list}  ${mo_list}  ${value_list}  ${product_type}=gnb

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console    \nGNB Parameter Check Result: ${out}

    ${out}    Parameter Operation
    ...    operation=parameter_update    product_type=${product_type}
    ...    para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console    \nGNB Parameter Check Result: ${out}

    BTS Operation    operation=verify    product_type=${product_type}   distname_id=NRCELL-ALL
    ...              verify_status=CELL_ONAIR    timeout=180s

CB006139_Change_UE_Capability
    [Arguments]  ${ue_capability_hex}  ${ue_id}=1

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=${ue_capability_hex}

CB006139_Change_UE_Location
    [Arguments]  ${ue_id}=1  ${enb_id}=2  ${cell_id}=1

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
