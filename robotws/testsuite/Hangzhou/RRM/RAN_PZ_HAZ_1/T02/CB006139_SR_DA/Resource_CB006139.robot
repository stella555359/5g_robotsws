*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../../T02/Common_Case/common_resource_new.robot
Library     taf.sw.scout    WITH NAME    scout

*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}

*** Keywords ***
mue_attach_and_activate_pdu
    [Arguments]  ${ue_id_start}  ${ue_id_end}
    FOR  ${ue_id}  IN RANGE  ${ue_id_start}  ${ue_id_end}  1
        attach_ue_and_activate_pdu  ue_id=${ue_id}
    END
mue_detach_with_power_off
    [Arguments]  ${ue_id_start}  ${ue_id_end}
    FOR  ${ue_id}  IN RANGE  ${ue_id_start}  ${ue_id_end}  1
        detach_ue_with_power_off  ue_id=${ue_id}
    END

mue_start_dl_data_service
    [Arguments]  ${ue_id_start}  ${ue_id_end}  ${ue_interval}  ${dl_rate}=${30}
    FOR  ${ue_id}  IN RANGE  ${ue_id_start}  ${ue_id_end}  ${ue_interval}
        start_ue_dl_data_traffic  ue_id=${ue_id}  dl_rate=${dl_rate}
        # 如果data+vonr，mcs/rank会受vonr参数设置影响，导致mcs降低，data tput也会下降
    END

mue_start_ul_data_service
    [Arguments]  ${ue_id_start}  ${ue_id_end}  ${ue_interval}  ${ul_rate}=${10}
    FOR  ${ue_id}  IN RANGE  ${ue_id_start}  ${ue_id_end}  ${ue_interval}
        start_ue_ul_data_traffic  ue_id=${ue_id}  ul_rate=${ul_rate}
    END

mue_stop_data_service
    [Arguments]  ${ue_id_start}  ${ue_id_end}
    FOR  ${ue_id}  IN RANGE  ${ue_id_start}  ${ue_id_end}
        stop_ue_dl_data_traffic  ue_id=${ue_id}
        stop_ue_ul_data_traffic  ue_id=${ue_id}
    END

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
    # ...    pass_regexp=UE${ue_id}: detached
    # ...    timeout=2
    log to console  \nUE-${ue_id} Detached!

start_ue_dl_data_traffic
    [Arguments]  ${ue_id}=1  ${trf_id}=1  ${dl_rate}=150
    Log to Console  \nUE-${ue_id} Start trf_id=${trf_id} DL Data Service: dl_rate=${dl_rate}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${trf_id} dir=dl mbps=${dl_rate} seconds=3600
    ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}


start_ue_ul_data_traffic
    [Arguments]  ${ue_id}=1  ${trf_id}=1  ${ul_rate}=10
    Log to Console  \nUE-${ue_id} Start trf_id=${trf_id} UL Data Service: ul_rate=${ul_rate}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${trf_id} dir=ul mbps=${ul_rate} seconds=3600
    ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}

stop_ue_dl_data_traffic
    [Arguments]  ${ue_id}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop trf_id=${trf_id} DL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 trf_id=${trf_id} dir=dl
    # ...    pass_regexp= Stopped.*Internal traffic on Ue:${ue_id}

stop_ue_ul_data_traffic
    [Arguments]  ${ue_id}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop trf_id=${trf_id} UL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    # ...    pass_regexp= Stopping.*Internal traffic on Ue:${ue_id}

start_ue_big_data_traffic
    [Arguments]  ${ue_id}=1  ${dl_rate}=450  ${ul_rate}=10
    ${dl_num}  evaluate  ${dl_rate}//150+1
    FOR  ${i}  IN RANGE  1  ${dl_num}  1
        log to console  \nue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=dl mbps=150 seconds=360
        ute_wtssim.Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=dl mbps=150 seconds=360
        ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END
    ${ul_num}  evaluate  ${ul_rate}//10+1
    FOR  ${i}  IN RANGE  1  ${ul_num}  1
        log to console  \nue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=ul mbps=10 seconds=360
        ute_wtssim.Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=ul mbps=10 seconds=360
        ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END

stop_ue_big_data_traffic
    [Arguments]  ${ue_id}=1
    Log to Console  \nUE-${ue_id} Stop Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl
    # ...    pass_regexp= Stopped .*Internal traffic on Ue:${ue_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    # ...    pass_regexp=Stopped .*Internal traffic on Ue:${ue_id}

verify_ue_dl_scell_status
    [Arguments]    ${ue_id}=1    ${num_of_scells}=3
    ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
    ${scell_status}=  ute_wtssim.Execute Egate Command And Wait For Data
        ...           cmd=ue_stats_nr id=${ue_id} scell=0-${num_of_scells}
        # ...           pass_regexp=(CellIndex-[0-${num_of_scells}].*)
        ...           pass_regexp=(CellIndex-[0-${num_of_scells}][\\s][\\s][0-9].*\\n){${num_of_cells}}
    log to console  \n${scell_status}

verify_ue_ul_scell_status
    [Arguments]    ${ue_id}=1    ${num_of_scells}=3
    ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
    ${scell_status}=  ute_wtssim.Execute Egate Command And Wait For Data
        ...           cmd=ue_stats_nr id=${ue_id} scell=0-${num_of_scells} type=pusch
        # ...           pass_regexp=(CellIndex-[0-${num_of_scells}][\\s][\\s][0-9].*\\n){${num_of_cells}}
    log to console  \n${scell_status}

trigger_scell_rlq_release
    [Arguments]    ${ue_id}=1  ${scell_id}=0
    ute_wtssim.Execute Egate Command
    ...  cmd=bler_testmode_nr profile_id=2 dl_bler=800,200,100
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=bler action=activate profile_id=2 scell=${scell_id}
    ...  pass_regexp=SCellIndex [1-9] deactivated successfully
    ...  timeout=20

detrigger_scell_rlq_release
    ute_wtssim.Execute Egate Command
    ...  cmd=bler_testmode_nr profile_id=2 delete=yes

Setup_for_CB006139
    [Arguments]    ${config_tag}=${None}

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
    # ${current_time}=  Get Current Date  result_format=%H:%M:%S
    # Run Keyword And Ignore Error  stop_log_collection  log_type=emil+syslog+snapshot
    HAZ TC02 Get SCF Internal Id By Scout  no_ute=False

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
    log to console  \nNeed Wait for ${wait_time_to_next_5min} secnods to next 5min period
    sleep  ${wait_time_to_next_5min}

start_log_collection
    [Arguments]  ${cell_id}  ${log_type}=emil+syslog++snapshot
    ####################### Log Collection ##################################
    # # syslog
    # Log to Console    \n syslog collection started...
    # Log Collection    start    syslog    product_type=gnb    bts_index=${0}

    # # emil log
    # Log to Console    \n emil collection started...
    # ${dcap_argument}   Create Dictionary   nrCells=NRCELL_R-${cell_id}
    # ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    # Log Collection    start    emil    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}   timeout=180
    # sleep  60  reason=Waiting For EMil capture start

    # # tti
    # ${dcap_argument}   Create Dictionary   nrCells=NRCELL_R-${cell_id}
    # ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    # Log Collection    start    tti    product_type=gnb    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    # sleep  30  reason=Waiting For TTI capture start

    # # bip
    # ${dcap_argument}   Create Dictionary   nrCells=NRCELL_R-${cell_id}
    # ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    # Log Collection    start    bip    product_type=gnb    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    # sleep  30  reason=Waiting For BIP capture start

    # emil+syslog+bip+snapshot
    ${dcap_argument}  Create Dictionary   nrCells=NRCELL_R-${cell_id}
    ${dict_argument}  Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start  ${log_type}  product_type=gnb  bts_index=${0}  cudu_index=${0}  dict_argument=${dict_argument}
    sleep  60s

stop_log_collection
    [Arguments]  ${log_type}=emil+syslog++snapshot
    ####################### Log Collection ####################################
    # ${current_time}=  Get Current Date  result_format=%H:%M:%S
    # ${current_time_in_seconds}=  Convert Time  ${current_time}
    # run  mkdir ~/${current_time_in_seconds}
    # log to console  \nLog folder: ~/${current_time_in_seconds}

    # # syslog
    # ${syslog_path}    Log Collection    stop_and_download    syslog    product_type=gnb    bts_index=${0}
    # Log To Console    \nSyslog log: ${syslog_path}

    # # emil
    # ${emil_path}    Log Collection    stop_and_download    emil    product_type=gnb    bts_index=${0}
    # Log To Console    \nEmil log: ${emil_path}

    # # tti log
    # ${tti_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}
    # Log To Console    \nTTI log: ${tti_path}

    # # bip log
    # ${bip_path}    Log Collection    stop_and_download    bip    product_type=gnb    bts_index=${0}    cudu_index=${0}
    # Log To Console    \nBIP log: ${bip_path}

    # # snapshot
    # ${snapshot_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    # Log To Console    \nSnapshot log: ${snapshot_path}

    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}    cudu_index=${0}
    Log To Console    \nlog of gnb: ${local_file_path}

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
    [Arguments]  ${ue_capability}  ${ue_id}=1

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=${ue_capability} capability_file=${CURDIR}/APCFG/ue_capability.cfg

CB006139_Change_UE_Location
    [Arguments]  ${ue_id}=1  ${enb_id}=2  ${cell_id}=1

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}

CB006139_Change_actBufferBasedSCellAddition
    [Arguments]  ${value}
    @{gnb_para_list}          Create List    actBufferBasedSCellAddition
    @{gnb_mo_list}            Create List    MRBTS-1/NRBTS-1
    @{gnb_value_list}         Create List    ${value}
    CB006139_DA_Configuration  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}

CB006139_Change_maxNumOfSCellAlloc
    [Arguments]  ${cell_id}  ${value}
    @{gnb_para_list}          Create List    maxNumOfSCellAlloc
    @{gnb_mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    @{gnb_value_list}         Create List    ${value}
    CB006139_DA_Configuration  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}

CB006139_Change_actEnhRrcReconfUlPrbRandom
    [Arguments]  ${value}
    @{gnb_para_list}          Create List    actEnhRrcReconfUlPrbRandom  actTransPhaseUlPrbNonRandom
    @{gnb_mo_list}            Create List    MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1
    @{gnb_value_list}         Create List    ${value}[0]  ${value}[1]
    CB006139_DA_Configuration  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}

CB006139_Change_actAperCsi
    [Arguments]  ${value}
    @{gnb_para_list}          Create List
    ...    actAperCsi  actAperCsi  actAperCsi  actAperCsi  actAperCsi  actAperCsi  actAperCsi
    @{gnb_mo_list}            Create List
    ...    MRBTS-1/NRBTS-1/NRCELL-1  MRBTS-1/NRBTS-1/NRCELL-2  MRBTS-1/NRBTS-1/NRCELL-3
    ...    MRBTS-1/NRBTS-1/NRCELL-4  MRBTS-1/NRBTS-1/NRCELL-5  MRBTS-1/NRBTS-1/NRCELL-6
    ...    MRBTS-1/NRBTS-1/NRCELL-7
    @{gnb_value_list}         Create List
    ...    ${value}  ${value}  ${value}  ${value}  ${value}  ${value}  ${value}
    CB006139_DA_Configuration  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}

CB006139_Change_sCellInactivityReleaseTimer
    [Arguments]  ${cell_id}  ${value}
    @{gnb_para_list}          Create List    sCellInactivityReleaseTimer
    @{gnb_mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    @{gnb_value_list}         Create List    ${value}
    CB006139_DA_Configuration  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}

CB006139_Delta_Commission
    [Arguments]  ${file_name}
    ${detal_commission_result}   Parameter Operation  operation=delta_plan_update   product_type=gnb
    ...                          delta_file_path=${CURDIR}/APCFG/${file_name}
    Log To Console    delta plan update result: ${detal_commission_result}
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=SITE_ONAIR

trigger_reestablishment_procedure
    [Arguments]  ${ue_id}  ${gnb_id}=2  ${cell_id}=1  ${cause}=otherFailure
    Log to Console  \nTrigger UE-${ue_id} RRC Restablisment Procedure
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id} cause=${cause}
    ...  pass_regexp=UE${ue_id}: NR RRC Reestablishment sucessfully completed