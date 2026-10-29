*** Settings ***
Documentation     author: Hao Xiaoxia
...                 contact: xiaoxia.hao@nokia-sbell.com
...                 squad group: SG_06
...                 feature : CB014044
Library     DateTime
Library     OperatingSystem
Library     Process
Library     BuiltIn
Library     taf.analyzer.pcap    WITH NAME    cap
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.pdu  WITH NAME   pdu
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Tool/gnb_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
@{All_Cell_Id_List}    1    2    3    21    22    23    101    102    103    111    112    113
${MR_NR_BTS_NAME}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
@{SWCONFIG_CB014044_C_1}    0x58057a=3    0x580581=448    0x5808ff=2
${git_link}    https://gitlabe1.ext.net.nokia.com/xiahao/regression_tools/-/raw/main

*** Keywords ***
CB014044 Common Suite Setup
    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error    Clone Gnblogs Tool
    Run Keyword And Ignore Error    Downlaod BSR And Gnb Lic File
    ${stream_version}    Get Active SW Version Based On Stream Version
    Set Suite Variable    ${STREAM_VERSION}    ${stream_version}
    ${SCF_Path}    ${result}    Split String From Right    ${CURDIR}    testsuite     1
    ${ute_env}    Run Keyword And Return Status    Run Keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${tmp_testline}   Run Keyword If    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    Set Variable     ${testline_name}
    ${stream}    ${build}     Run Keyword If    ${ute_env}    CI_commssion._Get Stream From Variable    ${ENB_BUILD}
    ...    ELSE   CI_commssion._Get Stream From Variable    ${AF_PATH}
    Set Suite Variable    ${tmp_testline}
    ${tl_prefix}    Set Variable    ${tmp_testline.split('_')[-1][-4:]}
    Set Suite Variable    ${tl_prefix}
    Set Suite Variable    ${TL_NAME}    ${tl_prefix}
    Set Suite Variable    ${stream}
    Set Suite Variable    ${SCF_PATH}
    ${Golden_SCF_Path}    Set Variable    ${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}.xml
    ${BSR_File_Path}    Set Variable    /home/ute/SG6_tools/Tools/BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    Set Suite Variable    ${Golden_SCF_Path}
    Set Suite Variable    ${BSR_File_Path}
    Load BSR File
    Run Keyword And Ignore Error    Clean Iptables Before Testrun
    Run Keyword And Ignore Error    Add IP Address On TL VM Eth3
    Setup Egate Port On Suite Setup
    Suite Log Path Create

CB014044 Common Test Setup
    [Arguments]    ${swconfig_flag}=${None}    ${scf_file_name}=SCF_${stream}    ${cfg_sim_file}=basic.lua    ${cellDep_Type}=SA
    robot_common_operations.Common Case Setup    allowed_faults_ids=4459,4741,10,4779,7107,7305,4753,4589,4592
    AlarmWatchdog.add_allow_alarms    fault_id=4459
    AlarmWatchdog.add_allow_alarms    fault_id=4741
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4779
    AlarmWatchdog.add_allow_alarms    fault_id=7107
    AlarmWatchdog.add_allow_alarms    fault_id=7305
    AlarmWatchdog.add_allow_alarms    fault_id=4753
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=4592
    Run Keyword If    '${swconfig_flag}'!='${None}'     Backup and Modify swconfig file
    ...                                                 swconfig_modify=@{SWCONFIG_${swconfig_flag}}
    ...                ELSE                             Uplaod Default Swconfig File
    ${Golden_SCF_Path}    Set Variable    ${SCF_PATH}commissionings/HGZ/${tmp_testline}/${scf_file_name}.xml
    Perform Commission And Rest    scf_file_path=${Golden_SCF_Path}    cfg_sim_file=${cfg_sim_file}    cellDep_Type=${cellDep_Type}
    Create Case Log Path

Perform Commission And Rest
    [Documentation]   xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_path}    ${gnb_index}=0    ${timeout_for_commission}=900
    ...            ${wait_gnb_up_timeout}=20 min    ${is_pdl_checking_needed}=${True}
    ...           ${cfg_sim_file}=basic.lua    ${cellDep_Type}=SA
    Connect to gnb coam via ssl    connection=GNB_OAM${gnb_index}   gnb_index=${gnb_index}
    COAM Commission with scf file    scf_file_path=${scf_file_path}
    ...                              connection=GNB_OAM${gnb_index}
    ...                              timeout=${timeout_for_commission}
    ...                              is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Edaemon And Egate Process    cfg_sim_file=${cfg_sim_file}
    Run WTS Configuration File    cfg_sim_file=${cfg_sim_file}
    Wait Gnb Ready And Cell On Air FOr AP    gnb_id=${gnb_index}    timeout=${wait_gnb_up_timeout}    connection=GNB_OAM${gnb_index}
    ...                                      cellDep_Type=${cellDep_Type}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM${gnb_index}


Wait Gnb Ready And Cell On Air FOr AP
    [Timeout]    60 min
    [Documentation]    Description: Wait GNB cell on air , and each single cell status in cell on air status
    [Arguments]    ${gnb_id}=0    ${timeout}=30 min    ${connection}=GNB_OAM    ${cellDep_Type}=SA
    Wait Until Keyword Succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                                   gnb_index=${gnb_id}
    Wait Until Keyword Succeeds    ${timeout}    20 sec    COAM Check GNB ABIL status    connection=${connection}
    Wait Until Keyword Succeeds    ${timeout}    20 sec    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    Verify all cells should be onair    connection=${connection}
    Run Keyword If    '${cellDep_Type}'=='NSA'    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    2sec
    Run Keyword If    '${cellDep_Type}'=='NSA'
    ...               Wait until keyword succeeds    ${timeout}    20 sec    COAM Check X2 link status from GNB    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Clean Iptables Before Testrun
    ${RC}    Run And Return Rc    sudo iptables -F

Load BSR File
    [Arguments]    ${bsr_file_path}=${BSR_File_Path}
     COAM.setup admin
     ${ret}     COAM.Update Software      ${bsr_file_path}
     COAM.teardown admin

CB014044 Common Suite Teardown
    robot_common_operations.Common Suite Teardown

CB014044 Common Test Teardown
    [Arguments]    ${is_recover_swconfig}=${False}    ${ASIK_MASTER_ALIAS}=ASIK Master
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4459
    AlarmWatchdog.remove_allow_alarms    fault_id=4741
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    Connect to gnb coam via ssl    connection=GNB_OAM0  gnb_index=0
    run keyword and ignore error    COAM Save snapshot via rest api    connection=GNB_OAM0    timeout=30min
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM0
    run keyword if    ${is_recover_swconfig}    run keywords
    ...               run keyword and ignore error    COAM Teardown gnb connections    AND
    ...               run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    AND
    ...               Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}    AND
    ...               swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=${ASIK_MASTER_ALIAS}    AND
    ...               Run Keyword And Ignore Error    CI_interface.Common Case Teardown

Run Edaemon And Egate Process
    [Arguments]    ${cfg_sim_file}=basic.lua
    ${RC}    Run And Return Rc    sudo pkill -9 edaemon
    ${RC}    Run And Return Rc    sudo pkill -9 egate
    ${RC}    Run And Return Rc    scp ${SCF_PATH}commissionings/HGZ/${tmp_testline}/Tool/${cfg_sim_file} /opt/iphy/latest
    ${RC}    ${output_execute_edaemon}    Run And Return Rc And Output    cd /opt/iphy/latest;sudo ./edaemon --port 22222
    ${RC}    ${output_execute_egate}    Run And Return Rc And Output    cd /opt/iphy/latest;./egate --port 20000

Uplaod Default Swconfig File
    [Documentation]    Auther:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${ASIK_MASTER_ALIAS}=ASIK Master
    Cloud DU connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    swconf.Upload swConfig file to asik and crasign    localFilePath=${SCF_PATH}commissionings/HGZ/${tmp_testline}/swconfig.txt
    ...                                                asik_alias=ASIK Master
    csn.disconnect    connection=${ASIK_MASTER_ALIAS}

Run WTS configuration File
    [Arguments]    ${cfg_sim_file}=basic.lua
    Execute Egate Command    cmd=cfg_sim file=${cfg_sim_file}

Setup Egate Port On Suite Setup
    [Arguments]    ${egate_port}=20000
    ute_wtssim.setup_egate    egate_port=${egate_port}

Do SA UE Attach On AP
    [Arguments]    ${traffic_infor}    ${pdu}=1    #${egate_port}=20000
    ${ues}   Get Length   ${traffic_infor}
    Log To Console    \n***start do UE attach***
#    ute_wtssim.setup_egate    egate_port=${egate_port}
    FOR    ${ue}    IN RANGE    ${ues}
        Execute Egate Command    cmd=ue_register id=${traffic_infor[${ue}]}[ue_indx]
        Sleep    2sec
        Execute Egate Command    cmd=set_pdu_param ue=${traffic_infor[${ue}]}[ue_indx] pdu=${pdu} default_qos_flow=1 trf_type=internal
        Sleep    2sec
        Execute Egate Command    cmd=ue_pdu_session_setup pdu=${pdu} ue=${traffic_infor[${ue}]}[ue_indx] nwslice=1
        Sleep    2sec
    END

Stop Traffic And UE Deattach For SA On AP
    [Arguments]    ${traffic_infor}    ${pdu}=1
    ${ues}   Get Length   ${traffic_infor}
    FOR    ${ue}    IN RANGE    ${ues}
        Execute Egate Command    cmd=trf_data_stop ue=${traffic_infor[${ue}]}[ue_indx] pdu=${pdu} qfi=1
        Sleep    2sec
        Execute Egate Command    cmd=ue_pdu_session_release ue=${traffic_infor[${ue}]}[ue_indx] pdu=${pdu}
        Sleep    2sec
        Execute Egate Command    cmd=ue_deregister id=${traffic_infor[${ue}]}[ue_indx] ue_deregister_type=switch_off by=ue
    END

Stop Traffic And UE Deattach On Rounds For SA On AP
    [Arguments]    ${start_ue_id}=1    ${end_ue_id}=70    ${pdu}=1
    Execute Egate Command    cmd=trf_data_stop ue=${start_ue_id}-${end_ue_id} pdu=${pdu} qfi=1
    Sleep    2sec
    Execute Egate Command    cmd=ue_pdu_session_release ue=${start_ue_id}-${end_ue_id} pdu=${pdu}
    Sleep    2sec
    Execute Egate Command    cmd=ue_deregister id=${start_ue_id}-${end_ue_id} ue_deregister_type=switch_off by=ue

Start SA L3 Call on AP
    [Arguments]    ${traffic_infor}    ${pdu}=1    ${traffic_duration}=30000
    ${ues}   Get Length   ${traffic_infor}
    FOR    ${ue}    IN RANGE    ${ues}
        Log To Console    \n***start to ${traffic_infor[${ue}]}[ue_indx] dl traffic ${traffic_infor[${ue}]}[dl_data_transfer]M***
        ${ue_id}    set variable     ${traffic_infor[${ue}]}[ue_indx]
        ${dl_trf_id}    set variable     ${traffic_infor[${ue}]}[dl_trf_id]
        ${mbps}    set variable    ${traffic_infor[${ue}]}[dl_data_transfer]
        Start SA DL Tput on WTS    ue_id=${ue_id}
        ...                     dl_trf_id=${dl_trf_id}
        ...                     dl_data_transfer=${mbps}
        ...                     pdu=${pdu}
        ...                     traffic_duration=${traffic_duration}
    END
    FOR    ${ue}    IN RANGE    ${ues}
    Log To Console    \n***start to ${traffic_infor[${ue}]}[ue_indx] ul traffic ${traffic_infor[${ue}]}[ul_data_transfer]M***
        ${ue_id}    set variable     ${traffic_infor[${ue}]}[ue_indx]
        ${Ul_trf_id}    set variable     ${traffic_infor[${ue}]}[ul_trf_id]
        ${mbps}    set variable    ${traffic_infor[${ue}]}[ul_data_transfer]
        Start SA Ul Tput on WTS    ue_id=${ue_id}
        ...                     Ul_trf_id=${Ul_trf_id}
        ...                     Ul_data_transfer=${mbps}
        ...                     pdu=${pdu}
        ...                     traffic_duration=${traffic_duration}
    END

Start SA DL Tput on WTS
    [Arguments]    ${ue_id}    ${dl_trf_id}    ${dl_data_transfer}    ${pdu}=1    ${traffic_duration}=30000
    FOR    ${trf_id}    IN RANGE    1    ${dl_trf_id}+1
         Execute Egate Command
         ...      cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl trf_id=${trf_id} mbps=${dl_data_transfer} seconds=${traffic_duration}
         Sleep    2sec
    END


Start SA UL Tput on WTS
    [Arguments]    ${ue_id}    ${Ul_trf_id}    ${Ul_data_transfer}    ${pdu}=1    ${traffic_duration}=30000
    FOR    ${trf_id}    IN RANGE    1    ${Ul_trf_id}+1
         Execute Egate Command
         ...      cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul trf_id=${trf_id} mbps=${Ul_data_transfer} seconds=${traffic_duration}
         Sleep    2sec
    END

Start SA L3 Call And Check Tput
    [Arguments]    ${traffic_infor}
    ...            ${expect_ul_tput}
    ...            ${expect_dl_tput}
    ...            ${cellid}=1
    ...            ${pdu}=1
    ...            ${target_avg_percent}=0.95
    ...            ${min_percent}=0.8
    ...            ${duration}=120
    ...            ${traffic_duration}=30000
    ...            ${is_detach}=${True}
    Do SA UE Attach On AP    traffic_infor=${traffic_infor}    pdu=${pdu}
    Start SA L3 Call on AP    traffic_infor=${traffic_infor}    pdu=${pdu}    traffic_duration=${traffic_duration}
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=${duration}
    ...                                                                expect_ul_tput=${expect_ul_tput}
    ...                                                                expect_dl_tput=${expect_dl_tput}
    ...                                                                cellid=${cellid}
    ...                                                                target_avg_percent=${target_avg_percent}
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=${min_percent}
    [Teardown]    Run Keyword If    ${is_detach}     Run Keyword And Ignore Error
    ...    Stop Traffic And UE Deattach For SA On AP    traffic_infor=${traffic_infor}    pdu=${pdu}

Do NSA UE Attach On AP
    [Arguments]    ${traffic_infor}    ${cellid}=1
    ${ues}   Get Length   ${traffic_infor}
    Log To Console    \n***start do UE attach**
    FOR    ${ue}    IN RANGE    ${ues}
        Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
        Sleep    2sec
        Execute Egate Command    cmd=ue_attach id=${traffic_infor[${ue}]}[ue_indx]
        Sleep    2sec
        Execute Egate Command    cmd=enb_ue_dc_start ue=${traffic_infor[${ue}]}[ue_indx] target_gnb=2 target_cells=${cellid} bearer=2 type=split_scg
        Sleep    2sec
    END

Start NSA L3 Call on AP
    [Arguments]    ${traffic_infor}    ${traffic_duration}=30000
    ${ues}   Get Length   ${traffic_infor}
    FOR    ${ue}    IN RANGE    ${ues}
        Log To Console    \n***start to ${traffic_infor[${ue}]}[ue_indx] dl traffic ${traffic_infor[${ue}]}[dl_data_transfer]M***
        ${ue_id}    set variable     ${traffic_infor[${ue}]}[ue_indx]
        ${mbps}    set variable    ${traffic_infor[${ue}]}[dl_data_transfer]
        Start NSA DL Tput on WTS    ue_id=${ue_id}
        ...                         dl_data_transfer=${mbps}}
        ...                         traffic_duration=${traffic_duration}
    END
    FOR    ${ue}    IN RANGE    ${ues}
    Log To Console    \n***start to ${traffic_infor[${ue}]}[ue_indx] ul traffic ${traffic_infor[${ue}]}[ul_data_transfer]M***
        ${ue_id}    set variable     ${traffic_infor[${ue}]}[ue_indx]
        ${mbps}    set variable    ${traffic_infor[${ue}]}[ul_data_transfer]
        Start NSA Ul Tput on WTS    ue_id=${ue_id}
        ...                         Ul_data_transfer=${mbps}
        ...                         traffic_duration=${traffic_duration}
    END

Start NSA DL Tput on WTS
    [Arguments]    ${ue_id}    ${dl_data_transfer}    ${traffic_duration}=30000
    FOR    ${trf_id}    IN RANGE    1    ${dl_trf_id}+1
         Execute Egate Command
         ...      cmd=trf_data_start ue=${ue_id} id=2 dir=dl mbps=${dl_data_transfer} trf_id=${trf_id} seconds=${traffic_duration}
         Sleep    2sec
    END

Start NSA UL Tput on WTS
    [Arguments]    ${ue_id}    ${Ul_data_transfer}    ${traffic_duration}=30000
    FOR    ${trf_id}    IN RANGE    1    ${Ul_trf_id}+1
         Execute Egate Command
         ...      cmd=trf_data_start ue=${ue_id} id=2 dir=Ul mbps=${Ul_data_transfer} trf_id=${trf_id} seconds=${traffic_duration}
         Sleep    2sec
    END

Start NSA L3 Call And Check Tput
    [Arguments]    ${traffic_infor}
    ...            ${expect_ul_tput}
    ...            ${expect_dl_tput}
    ...            ${cellid}=1
    ...            ${target_avg_percent}=0.95
    ...            ${min_percent}=0.8
    ...            ${duration}=120
    ...            ${traffic_duration}=30000
    ...            ${is_detach}=${True}
    Do NSA UE Attach On AP    traffic_infor=${traffic_infor}
    Start NSA L3 Call on AP    traffic_infor=${traffic_infor}    traffic_duration=${traffic_duration}
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=${duration}
    ...                                                                expect_ul_tput=${expect_ul_tput}
    ...                                                                expect_dl_tput=${expect_dl_tput}
    ...                                                                cellid=${cellid}
    ...                                                                target_avg_percent=${target_avg_percent}
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=${min_percent}
    [Teardown]    Run Keyword If    ${is_detach}     Run Keyword And Ignore Error
    ...    Stop Traffic And UE Deattach For NSA On AP    traffic_infor=${traffic_infor}

Stop Traffic And UE Deattach For NSA On AP
    [Arguments]    ${traffic_infor}
    ${ues}   Get Length   ${traffic_infor}
    FOR    ${ue}    IN RANGE    ${ues}
        Execute Egate Command    cmd=trf_data_stop ue=${traffic_infor[${ue}]}[ue_indx]
        Sleep    2sec
        Execute Egate Command    cmd=ue_detach id=${traffic_infor[${ue}]}[ue_indx]
    END

Get And Check NKListBuildAlgoBase Information from Syslog
    [Arguments]    ${capture_time}=1min    ${gnb_index}=0
    Log To Console    Start to Check NKListBuildAlgoBase Information From Syslog
    Set Test Variable    @{btslog_dirs}
    Recover Collect Syslog For Gnb    host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    Start Btslog With Path Check
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Sleep    ${capture_time}
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Check NKListBuildAlgoBase Information from Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}

Check NKListBuildAlgoBase Information from Syslog
    [Arguments]    ${btslog_path}=${TS_CASE_LOG_PATH}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ${btslog_full_path}    set variable    ${btslog_path}/btslog/syslog_files.tgz
    ${Rc}    ${NKListBuildAlgoBase_infor}=    Run And Return Rc And Output    command=zgrep -a "NKListBuildAlgoBase.hpp" ${btslog_full_path}
    ${NKListBuildAlgoBase_infor_all} =    split string    ${NKListBuildAlgoBase_infor}    \n
    ${NKListBuildAlgoBase_infor_all_len}=      get length     ${NKListBuildAlgoBase_infor_all}
    ${KList_infor}    get regexp matches    ${NKListBuildAlgoBase_infor}   KList{\\s\\d+
    ${KList_infor_len}=      get length     ${KList_infor}
    ${List_rate}    evaluate    ${KList_infor_len}/${NKListBuildAlgoBase_infor_all_len}
    run keyword and continue on failure    Should Be True    ${List_rate}>0.99
    [Teardown]    run keyword and ignore error    ssh.disconnect    connection=ute

Check nkUeType Status Via TTITrace
    [Documentation]   Auther:xiaoxia.hao@nokia-sbell.com
    [Arguments]     ${ttitrace_filt_path}
    ...             ${group_paird_percent_exp}=0.1
    calculate_ul_ulmugroup_status     file_path=${ttitrace_filt_path}
    ...                                   group_paird_percent_exp=${group_paird_percent_exp}

Update 14044 Param Value
    [Arguments]    ${skip_parameter_relation_errors}=False
    Log To Console    \n***start to update 14044 Param to DL_UL***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${update_param_all_cells}    Create List
    FOR    ${cell_index}    IN    @{All_Cell_Id_List}
        ${update_param}    catenate
        ...               {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-${cell_index}','parameter':'actTdPfMetricOpt','value':'DL_UL'},
        ...               {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-${cell_index}','parameter':'actTdHighBufUePrio','value':'DL_UL'},
        ...               {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-${cell_index}','parameter':'actFdAlgoEnh','value':'DL_UL'},
        ...               {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-${cell_index}','parameter':'actUlSchLowBufferOpt','value':'true'},
        ...               {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-${cell_index}','parameter':'actDlSchLowBufferOpt','value':'true'},
        ...               {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-${cell_index}','parameter':'bestNK',
        ...                                                                                              'value':[{'actBestNList':'DL_UL',
        ...                                                                                                       'actBestKList':'DL_UL',
        ...                                                                                                       'dlBestNListRatio':'10',
        ...                                                                                                       'ulBestNListRatio':'10',
        ...                                                                                                       'dlBestKListRatio':'10',
        ...                                                                                                       'ulBestKListRatio':'10'}]},
        ${update_param}     evaluate    [${update_param}]
        ${update_param_all_cells}    combine lists    ${update_param_all_cells}     ${update_param}
    END
    ${update_channelBwMultiplierDl}    catenate
    ...                   {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-101','parameter':'channelBwMultiplierDl','value':'80'},
        ...               {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-102','parameter':'channelBwMultiplierDl','value':'80'},
        ...               {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-103','parameter':'channelBwMultiplierDl','value':'80'},
        ...               {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-111','parameter':'channelBwMultiplierDl','value':'80'},
        ...               {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-112','parameter':'channelBwMultiplierDl','value':'80'},
        ...               {'dist_name':'${MR_NR_BTS_NAME}/NRCELL-113','parameter':'channelBwMultiplierDl','value':'80'},
    ${update_channelBwMultiplierDl}     evaluate    [${update_channelBwMultiplierDl}]
    ${update_param_all_cells}    combine lists    ${update_param_all_cells}     ${update_channelBwMultiplierDl}
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param_all_cells}    gnb_index=0
    ...                                          skip_parameter_relation_errors=${skip_parameter_relation_errors}

Capture TTI with gnb logs For 14044
    [Documentation]  Author: xiaoxia.hao@nokia-sbell.com
    ...              Description: Capturing event trace log,Also will check the tput value by tti trace
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${duration}=5
    ...            ${eth_port_on_ute}=eth0    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming
    Start Ttitrace With Streaming Mode    collector_names=${collector_names}    eth_port_on_ute=${eth_port_on_ute}
    Sleep    ${duration}s    reason=Wait for logs
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${file_path}    Stop Ttitrace    collector_names=${collector_names}    log_dir=${log_dir}/ttitrace_streaming_${timestamp}
    ${tti_file_path_ul}    Decode Ttitrace Logs    file_path=${file_path}    direction=ul
    Sleep    5sec
    ${tti_file_path_dl}    Decode Ttitrace Logs    file_path=${file_path}    direction=dl
    [Return]    ${tti_file_path_ul}    ${tti_file_path_dl}

Add IP Address On TL VM Eth3
    Log To Console    Configure VM interfaces...
    OperatingSystem.Run    sudo sysctl -w net.sctp.sack_timeout=20
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_min=200
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_initial=200
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_max=800
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.139/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
#   add ip address for NSA
    OperatingSystem.Run    sudo ip addr add 10.0.1.112/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.113/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.122/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.123/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.124/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3
    OperatingSystem.Run    sudo ifconfig eth4:gNB3_PR add 10.0.2.90
    OperatingSystem.Run    sudo ifconfig eth4:gNB3_PR2 add 10.0.2.91

Set Permanent Debug Params
    [Arguments]    ${persistency}=persistent
    &{para_dict}=   Create Dictionary    name=rdFeatureFlagBitmapLevel    value=3
    &{para_dict_6}=   Create Dictionary    name=rdFeatureFlagBitmap6    value=6
    @{para_list}    Create List    ${para_dict}    ${para_dict_6}
    ${is_success}    Update vDU RAD Debug params    persistency=${persistency}   domain_name=L2PS
    ...                 vdu_connection=${connect_du}    parameters=${para_list}
    sleep    5s

Set RAD debug parameters By ADMIN
    [Documentation]    This keyword will modify debug flags in the gNB GUI in BTS RAD Debug Parameters page
    ...                Need to Setup_admin before using this keyword and teardown admin after the changes are done.
    ...                Modified Date: 11-Jul-2024
    ...                Last Modified by: merin.varghese@nokia.com
    ...    Usage:
    ...         ADMIN Set RAD debug parameters    Domain=L2PS     Name=rdFeatureFlagBitmapLevel     Value=4    Persistency=NotPersistent
    [Arguments]    ${Name}    ${Value}    ${Domain}=L2PS    ${Persistency}=Persistent   ${timeOut}=30    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${bts_state}=       coam.Set Rad Debug Parameters
    ...    domain=${Domain}
    ...    persistency=${Persistency}
    ...    name=${Name}
    ...    value=${Value}
    ...    timeout=${timeOut}
    ...    connection=${connecTion}

UPdate RD Paramter for CB014044
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    Set RAD debug parameters By ADMIN    Name=rdFeatureFlagBitmap6    Value=448    connection=${connecTion}
    Set RAD debug parameters By ADMIN    Name=rdFeatureFlagBitmapLevel    Value=3    connection=${connecTion}
    Set RAD debug parameters By ADMIN    Name=rdComponentBitMapProfile    Value=2    connection=${connecTion}

Downlaod BSR And Gnb Lic File
    [Arguments]    ${tools_dir}=/home/ute
    ${status}    Run Keyword And Return Status    File Should Exist    ${tools_dir}/SG6_tools/Tools/lic.dat
    return from keyword if    ${status}
    Log To Console    start clone SG6_tools
    Run Process    git clone git@gitlabe2.ext.net.nokia.com:xiahao/sg6_tool.git ${tools_dir}/SG6_tools
    ...    shell=True
    ...    stdout=${tools_dir}/tools_result.txt
    Run Process    sudo scp ${tools_dir}/SG6_tools/Tools/lic.dat /home/ute/gnb_logs/
    ...    shell=True
    Log To Console    SG6_tools finish

Test Procedures For KPI Report Case On AP
    [Arguments]    ${rounds}=1
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
#    ...            ${need_to_check_status}=${True}
    ${dir_exist_status}    Run Keyword And Return Status   Directory Should Exist    /home/ute/KPI_Report/Excel_KPI
    Run Keyword If    not ${dir_exist_status}    Create Directory     /home/ute/KPI_Report/Excel_KPI
    ${btsName}    ${gnb_version}     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    Set Test Variable    ${btsName}
    Set Test Variable    ${gnb_version}
#    ${scf_version}    ${stream_version}    Get scf stream and sw stream    scf_name=${btsName}    sw_version=${gnb_version}
    ${report_start_time}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${report_timestamps}      Create List
    ${empty_list}     Create List
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S    increment=+8hours
    log to console    start to call for KPI from ${call_start_time}
    Sleep    15min
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S    increment=+8hours
    log to console    end to call for KPI from ${call_end_time}
    ${call_timestamp}    Create List    ${call_start_time}    ${call_end_time}
    Append To List    ${report_timestamps}    ${call_timestamp}
#
#    FOR    ${round}    IN RANGE    ${rounds}
#        log to console    start to call round-${round}
#        ${status}     Run Keyword And Return Status    ${case_test_procedure_kw}
#         ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S   increment=+8hours
#         ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S    increment=+8hours
#         ${call_start_time}    Add Time To Date    ${call_start_time}    -276    exclude_millis=true
#         Sleep    15min
#         ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S    increment=+8hours
#         ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S    increment=+8hours
#        ${call_timestamp}    Create List    ${call_start_time}    ${call_end_time}
#        Append To List    ${report_timestamps}    ${call_timestamp}
#    END
    ${test_procedure_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S    increment=+8hours
    ${diff_time}    Subtract Date From Date    ${test_procedure_time}    ${call_end_time}
    ${duration}    Evaluate   2100-${diff_time}
    ${sleep_time}   Set Variable If   ${diff_time}>=1800    300      ${duration}
    log to console    sleep for wait for scout report : ${sleep_time}
    log    test timestamps for ${rounds} rounds is ${report_timestamps}
#    ${report_end_time}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${timestamps_length}    Get Length    ${report_timestamps}
    Run keyword If    '${timestamps_length}'=='${0}'    fail    msg= test all failed.
    log to console    start to wait ${sleep_time}
    Sleep    ${sleep_time}sec
    [Return]    ${report_timestamps}

#Generate And Record KPI Report To Compass And UTE On AP
#    [Arguments]   ${report_timestamps}
#    ...           ${comments}=5605005
#    ...           ${filter_distnames}=bts,NRCELL-276,NRCELL-101
#    ...           ${gnb_index}=${0}
##    ...           ${group_name}=${comments}
#    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
#    ${all_template_excel_report}    Create List
#    ${all_report_id}    Create List
#    ${empty_list}    Create List
#    ${filter_distnames}    Set Variable    ${filter_distnames.split(',')}
#    ${list1_excel_report_path}    ${list1_report_id_list}    Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass For AP
#    ...                           report_timestamps=${report_timestamps}
#    ...                           comments=PZ4_SG06_${comments}_List1_Jay_gNB_TMO_KPI
#    ...                           template_name=Jay_gNB_TMO_KPI
#    ...                           gnb_index=${gnb_index}
#    ${list2_excel_report_path}    ${list2_report_id_list}    Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass For AP
#    ...                           report_timestamps=${report_timestamps}
#    ...                           comments=PZ4_SG06_${comments}_List2_Jay_KPI_2
#    ...                           template_name=Jay_KPI_2
#    ...                           gnb_index=${gnb_index}
#    [Return]    ${list1_excel_report_path}    ${list2_excel_report_path}

#Generate KPI Report And Record To Compass For AP
#    [Arguments]   ${report_timestamps}
#    ...           ${comments}=CB014044 KIP check
#    ...           ${template_name}=KPI_24R1_TMO_SA_SG6
#    ...           ${check_out_entry}=false
#    ...           ${scout_name}=7_5_UTE5G402T083
#    ...           ${gnb_index}=${0}
#    ...           ${connection}=GNB_OAM${gnb_index}
#    log to console    start to generate kpi report on compass for ${scout_name}
#    ${excel_report_path_on_ute}    Create List
#    ${report_id_list}    Create List
#    FOR   ${timestamp}    IN    @{report_timestamps}
#       ${excel_report}    ${report_id}    Run Keyword And Continue On Failure    KPI.Generate kpi report in Scout
#       ...    tl_name=${scout_name}
#       ...    start_time=${timestamp[0]}
#       ...    end_time=${timestamp[1]}
#       ...    comments=${comments}
#       ...    template_name=${template_name}
#       ...    check_out_entry=${check_out_entry}
#       ...    gnb_index=${gnb_index}
#       ...    connection=${connection}
#       Append To List    ${excel_report_path_on_ute}    ${excel_report}
#       Append To List    ${report_id_list}    ${report_id}
#       ${report_name}    Set Variable    ${excel_report.split('/')[-1]}
#       ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
#       Run Keyword And Ignore Error    upload_files_to_remote_server
#       ...    local_path=${excel_report}
#       ...    remote_path=/home/hz4sg6/shared/01_E2E_Rep/${test_case_id}/${test_case_id}_${tl_prefix}/Excel_KPI/${report_name}
#        ...    hostname=${samba_server_ip}
#        ...    username=${samba_server_username}
#        ...    password=${samba_server_password}
#    END
#    log    ${excel_report_path_on_ute}
#    log    ${report_timestamps}
#    ${report_length}    Get Length    ${excel_report_path_on_ute}
#    Run keyword If    '${report_length}'=='${0}'    fail    msg=no available report get from this round test.
#   [Return]    ${excel_report_path_on_ute}    ${report_id_list}

Generate KPI Report And Record To Compass For AP
    [Arguments]    ${timestamp_list}
    ...           ${check_out_entry}=false
    ...           ${gnb_index}=${0}
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${download_report}=${False}
    ...           ${test_comments}=${EMPTY}
    ...           ${restore_path}=/home/ute/Compass_Report
    ...           ${scout_name}=7_5_UTE5G402T083
    ...           ${template_name}=14044_KPI_UL
    log    ${connection}
    log to console    report timestap is:${timestamp_list}
    log to console    start to generate kpi report on compass for ${scout_name}
    ${bts_name}    ${sw_version}    Wait Until Keyword Succeeds    3x    30s
    ...     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    ${release_info}    Set Variable     ${sw_version.split('_')[0].split('BTS')[1]}
    ${bts_name_format}    Replace String    ${bts_name}    _    .
    ${sw_version_format}    Replace String    ${sw_version}    _    .
    log to console    release is ${release_info}
    ${report_timestamp}    Get current date    result_format=%Y%m%dT%H%M%S
    ${formatted_start_timestamp}    Convert Date    ${timestamp_list[0]}    result_format=%Y%m%dT%H%M%S
    ${formatted_end_timestamp}    Convert Date    ${timestamp_list[1]}    result_format=%Y%m%dT%H%M%S
    ${kpi_report_name}   Catenate    SEPARATOR=_   SG06    ${sw_version}   ${formatted_start_timestamp}
    ${report_id_list}    Create List
    ${template_names_list}    Create List    ${template_name}
    ${current_date}    Get Current Date    result_format=%m%d
#    ${package_version}     Set Variable    exec${formatted_start_timestamp}_${test_comments}_${bts_name}_${sw_version}
    ${package_version}     Set Variable
    ...    exec${formatted_start_timestamp}_${sw_version_format}_${tl_prefix}.SCF.${bts_name_format}_${test_comments}_1csv
    FOR    ${template}    IN   @{template_names_list}
        Log To Console     start to get kpi report for ${template}
        ${status}    ${report_id}    Run Keyword And Ignore Error    generate_new_report_on_compass
        ...    report_name=${kpi_report_name}
        ...    tl_id=${scout_name}
        ...    package_version=${package_version}
        ...    start_time=${timestamp_list[0]}
        ...    end_time=${timestamp_list[1]}
        ...    template_name=${template}
       ...    check_out_entry=${check_out_entry}
        Run Keyword If  "${status}"=="PASS"   Append To List    ${report_id_list}    ${report_id}
    END
    log    ${report_id_list}
    Sleep   15sec
    ${combine_report_id}    combine_kpi_reports_on_compass    report_id_list=${report_id_list}
    ${full_path}    create_kpi_report_directories    base_path=${restore_path}
    ...    subdirs=${TEST NAME}/${sw_version}
    ${kpi_report}    Run Keyword If    ${download_report}    Wait Until Keyword Succeeds    5x    30s
    ...    get_kpi_result_from_compass    report_id=${combine_report_id}
    ...    output_report=${full_path}/KpiReport_${test_comments}_${sw_version}_${formatted_start_timestamp}_to_${formatted_end_timestamp}.xlsx
    ...    package_version=${package_version}
    [Return]    ${combine_report_id}    ${kpi_report}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Generate And Record KPI Report To Compass And UTE On AP
    [Arguments]    ${report_timestamps_list}    ${test_comments}=TL083_testing    ${report_parsed_duration}=${None}
    ...    ${restore_path}=/home/ute/Compass_Report    ${test_comments}=${EMPTY}    ${template_name}=14044_KPI_UL
    [Documentation]    Auther:xiaoxia.hao
    ...    ${report_timestamps_list}:[['2026-01-30 03:10:44', '2026-01-30 07:40:44'],['2026-01-30 08:10:44', '2026-01-30 11:40:44']]
    ...    ${test_comments}:test description
    ...    ${report_parsed_duration}:is not ${None},timestamp will parsed as duration ${report_parsed_duration}sec.
    ${new_report_timestamps_list}    Run Keyword If    '${report_parsed_duration}'!='${None}'
    ...    split_intervals    intervals=${report_timestamps_list}
    ${input_report_timestamps_list}    Set Variable If    '${report_parsed_duration}'!='${None}'    ${new_report_timestamps_list}
    ...    ${report_timestamps_list}
    log to console  input timestamp is:${input_report_timestamps_list}
    ${current_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S       increment=+8hours
    ${last_end_time}    Set Variable    ${report_timestamps_list[-1][1]}
    ${diff_time}    Subtract Date From Date    ${current_time}    ${last_end_time}
    ${duration}    Evaluate   1860-${diff_time}
    ${sleep_time}   Set Variable If   ${diff_time}>=1800    10      ${duration}
    log to console   prepare to generate scout report,SLEEP:${sleep_time}sec
    Sleep    ${sleep_time}sec
    log to console   start to generate compass kpi report
    ${combine_report_id_all}    Create List
    FOR    ${time_stamp}    IN    @{input_report_timestamps_list}
        ${status}    ${report_info}    Run Keyword And Ignore Error
        ...    Generate KPI Report And Record To Compass For AP    timestamp_list=${time_stamp}    test_comments=${test_comments}
        ...    restore_path=${restore_path}    template_name=${template_name}
        Run Keyword If    '${status}'=='PASS'    Append To List     ${combine_report_id_all}     ${report_info[0]}
    END
    Log To Console   all report ids��${combine_report_id_all}
    log to console   start to combine and compare kpi report
    ${formatted_report_ids}    Evaluate    ','.join(${combine_report_id_all})
    ${output_file}    Run Keyword And Continue On Failure    Compass.Save Compare KPI Report
    ...    report_ids=${formatted_report_ids}
    ...    restore_path=${restore_path}
    ...    test_comments=${test_comments}
    log to console   compare report is:${output_file}
    log to console   start to append kpi report
    Run Keyword And Ignore Error    Compass.Append Result To Excel    append_kpi_report_path=${output_file}
    ...    restore_path=${restore_path}
    [Return]    ${output_file}

check 7533 alarm report On gNB
    Log To Console    \n***start to check 7533 appear***
    Connect to gnb coam via ssl
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=7533

check 7533 alarm Cancel On gNB
    Log To Console    \n***start to check 7533 cancel***
    Connect to gnb coam via ssl
    Wait until keyword succeeds    10min    20 sec    Expect Fault Should Absent    faultId=7533

Start Tcpdump from gNB
    [Arguments]     ${filename}=tcpdump_ueattach    ${interface}=any    ${alias}=ASIK Master
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${alias}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    csn.send command    command=nohup tcpdump -i ${interface} -w /tmp/${filename}.pcap     connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${filename}    connection_alias=${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Stop Tcpdump from gNB
    [Arguments]     ${filename}=tcpdump_ueattach    ${logpath}=${TS_CASE_LOG_PATH}    ${alias}=ASIK Master
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${logpath}/${filename}_${timestamp}.pcap
    csn.download_file   remote_path=/tmp/${filename}.pcap   local_path=${log_full_path_ute}   connection=${alias}
    csn.execute    command=rm /tmp/${filename}.pcap    connection=${alias}
    [Return]    ${log_full_path_ute}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Check uac_BarringFactor Infor From Tcpdump
    [Arguments]     ${log_full_path_ute}
    Setup Pcap File    file_path=${log_full_path_ute}     filter=f1ap
    ${uac_BarringFactor_infor}    Get Field Value From PCAP    field_name=nr-rrc.uac_BarringFactor
    ...                                              filter_expression=nr-rrc.uac_BarringFactor==0
    ${uac_BarringFactor}    Remove Duplicates    ${uac_BarringFactor_infor}
    ${uac_BarringFactor_length}    Get Length    ${uac_BarringFactor}
    Should Be True    ${uac_BarringFactor_length}>0

prepare Before Do UE Release UE
    [Arguments]    ${counter_period}=5    ${asik_alais}=ASIK Master
    [Documentation]    Author:xiaoxia.hao@nokia.com
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${asik_alais}
    ${period}    Evaluate    ${counter_period}*60
    ${current}     csn.execute    command=date +%s    connection=${asik_alais}
    ${current}    Get Line    ${current}    -1
    ${sleep}    Evaluate    ${period}+${period}-${current}+int(${current}/${period})*${period}
    log to console    Sleep ${sleep} sec
    Sleep    ${sleep}
    sleep    60

Force NSA UE Relase On AP
    [Arguments]    ${traffic_infor}    ${cause_infor}=RN_normal_release
    ${ues}   Get Length   ${traffic_infor}
    Log To Console    \n***force UE release by ${cause_infor}**
    FOR    ${ue}    IN RANGE    ${ues}
        Execute Egate Command    cmd=enb_ue_dc_release ue=${traffic_infor[${ue}]}[ue_indx] bearer=2 by=enb cause=${cause_infor}
        Sleep    2sec
    END

Check Normal NSA E_RAB Releases Initiated Counter
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ${M55112C06002_full_path}    set variable    ${dis_name_dir}/NRCELL-1/NX2CC/NX2CC_RAB_REL_NORM_MENB
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${M55112C06002_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55112C06002
    ...                                                  counter_full_path=${M55112C06002_full_path}
    ${M55112C06002_value}    convert to integer     ${M55112C06002_value}
    run keyword and continue on failure    should be true    ${M55112C06002_value}>0

Run Scripts File On Egate
    [Arguments]    ${scripts_file}=mutiuetraffic_UL_FDD.lua
    ${RC}    Run And Return Rc    scp ${SCF_PATH}commissionings/HGZ/${tmp_testline}/Tool/${scripts_file} /opt/iphy/latest
    Execute Egate Command    cmd=script file=${scripts_file}

