*** Settings ***
Documentation
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: SG_04
...   Feature 5GC000920 in 5G19A program

Resource    ./5GC000920_Variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/SISO_Pre.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource     ../../5GC002139/Resources/5GC002139_Keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/common/connection_with_hostname.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
#Library    ../../../../../resources/python_libs/TestCaseRequirement.py    WITH NAME    TestCaseRequirement
Library    ArchiveLibrary
#Library    taf.analyzer.pcap    WITH NAME    cap
Variables    ../TestData/5GC000920_scf_modify.py
Variables    ../TestData/swconfig_modify.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/defult_testline_scf.py
Library     taf.analyzer.pcap     WITH NAME    pcap

*** Variables ***
${command_template_with_Y}       tshark -r {pcap_file} -Y "x2ap.X2AP_PDU == 0" -T pdml


*** Keywords ***
Tear down connections
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${log_path_alarm}=${TS_CASE_LOG_PATH}
    Run keyword and ignore error    csn.Disconnect    connection=${ASIK_SLAVE_ALIAS}
    Run keyword and ignore error    Tear down all SISO connections

Update and verify administrativeState parameters on ENB
    [Documentation]   Author: zheng.4.liu@nokia-sbell.com
    ...               Description: update administrativeState parameters on ENB, and verify the value after updated.
    [Arguments]    ${update_value}=${update_value}    ${parameters_to_update_via_api}=${MODIFY_ADMINISTRATIVESTATE_PARAMETER_TO_LOCKED_VIA_API_140}
    Connect to eNB via ssl    connection=enblte
    ${update_status}    COAM Update several parameters via rest api    connection=enblte
    ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
    Should be true    '${update_status}'=='PASS'
    @{MOs}    enblte.get_managed_objects    class_name=LNADJGNB_A    connection=enblte
    &{administrativeState}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}  pattern=administrativeState    connection=enblte
    Should be equal as strings    ${administrativeState['administrativeState']}    ${update_value}    msg=administrativeState is not ${update_value}
    [Teardown]    Enblte close down    connection=enblte

Start DL traffic with Power UE
    [Documentation]   Author: yixiang.x.wang@nokia-sbell.com
    ...               Description: start the DL traffic via iperf with power UE
    ...               UE_TYPE can be huawei,qct_dx50, define by branch
    [Arguments]    ${dl_time}=${DL_TIME}    ${ue_type}=${UE_TYPE}    ${dl_throughput}=${DL_THROUGHPUT}    ${retry_time}=5
    Prepare for power UE    ue_type=${ue_type}
    FOR    ${i}    IN RANGE    ${retry_time}
       ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}    hwcheck_index=${0}
       ${status}    run keyword and return status    power_ue.Verify attach    ue_type=${ue_type}
       ...    4G_check=False    5Grach_ed=${5Grach_ed}
       exit for loop if    ${status}==${True}
    END
    run keyword if    ${status}==${False}    Fail    5G attach failed.
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}   duration=${dl_time}
    ...    iperf_port=${DL_PORT}    ue_index=${0}    cap_index=${0}    buffer_size=1024B    dt_name=dt_dl
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=10M   duration=${dl_time}
    ...    iperf_port=${UL_PORT}    ue_index=${0}    cap_index=${0}    buffer_size=1024B    dt_name=dt_ul

Prepare for power UE
    [Documentation]   Author: yixiang.x.wang@nokia-sbell.com
    ...     Prepare UE for L3 call test.
    ...     param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    [Arguments]    ${ue_type}=${UE_TYPE}
    power_ue.Prepare UE    ue_type=${ue_type}

Collect snapshot and extract specific file
    [Documentation]   Author: zheng.4.liu@nokia-sbell.com
    ...               Description: Collect snapshot, extract it. check the snapshot_file_list.txt,
    ...               get the specific zip file which the specific file in.
    ...               for example the log need to be checked is in runtime_BTSOM.LOG.XZ, it exist in the specific file BTS45_1011_runtime.zip,
    ...               then check the snapshot_file_list.txt, BTS45_1011_runtime.zip exist in BTS45_1011_part_7.zip, the specific directory is
    ...               BTS45_1011_part_7. extract BTS45_1011_part_7.zip, extract BTS45_1011_runtime.zip
    ...               return the path after extract specific file.
    [Arguments]    ${snapshot_log_folder}=${TS_CASE_LOG_PATH}    ${connection}=${GNB_COAM_ALIAS}
    ...    ${specific_file}=BTS${tl.gnbs[0].instance_id}_1011_runtime.zip
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_log_folder}    snapshot_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   timeout=600   connection=${connection}
    ${snapshot_unzip_folder}    Join Path    ${snapshot_log_folder}    snapshot_${timestamp}
    Extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_folder}
    OperatingSystem.File should exist    ${snapshot_unzip_folder}/snapshot_file_list.txt
    Run    grep -e 'zip:' -e '${specific_file}' ${snapshot_unzip_folder}/snapshot_file_list.txt > ${snapshot_unzip_folder}/tmp_test1.txt
    Run    cat ${snapshot_unzip_folder}/tmp_test1.txt
    Run    grep -B1 '${specific_file}' ${snapshot_unzip_folder}/tmp_test1.txt > ${snapshot_unzip_folder}/tmp_test2.txt
    Run    cat ${snapshot_unzip_folder}/tmp_test2.txt
    ${rc}    ${specific_file_in}    Run and return rc and output
    ...    grep -v '${specific_file}' ${snapshot_unzip_folder}/tmp_test2.txt
    ${specific_file_in}    Fetch from left    ${specific_file_in}    :
    ${specific_dir}    Fetch from left    ${specific_file_in}    .zip
    Extract zip file    ${snapshot_unzip_folder}/${specific_file_in}    ${snapshot_unzip_folder}/${specific_dir}
    OperatingSystem.File should exist    ${snapshot_unzip_folder}/${specific_dir}/${specific_file}
    ${specific_file_name}    Fetch from left    ${specific_file}    .zip
    Extract zip file    ${snapshot_unzip_folder}/${specific_dir}/${specific_file}
    ...    ${snapshot_unzip_folder}/${specific_dir}/${specific_file_name}
    [Return]    ${snapshot_unzip_folder}/${specific_dir}/${specific_file_name}

Check specific log in snapshot file
    [Documentation]     Author: zheng.4.liu@nokia-sbell.com
    ...                 For example:
    ...                 Check Incorrect Radio HW log in runtime BTSOM File in Snapshot, the key string "IncorrectRadioHardware" is in
    ...                 BTS45_1011_runtime/runtime_BTSOM.log, the specific_file is BTS45_1011_runtime.zip
    ...                 Check EDlSubcellType in CPRT startup log in snapshot file,  the key string "EDlSubcellType = SUBCELLTYPE_C4" is in
    ...                 BTS45_E005_startup/startup_cp_rt.log
    ...                 ${extract_path} is the dir path that the specific zip file unzip to.
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}  ${connection}=${GNB_COAM_ALIAS}
    ...    ${specific_zip_file}=BTS${tl.gnbs[0].instance_id}_1011_runtime.zip    ${specific_xz_file}=runtime_BTSOM.log.xz
    ...    ${key_string}=IncorrectRadioHardware
    ${extract_path}=    Collect snapshot and extract specific file    snapshot_log_folder=${TS_CASE_LOG_PATH}
    ...    connection=${GNB_COAM_ALIAS}    specific_file=${specific_zip_file}
    OperatingSystem.File should exist    ${extract_path}/${specific_xz_file}
    Run     unxz ${extract_path}/${specific_xz_file}
    ${unxz_file}    Fetch from left    ${specific_xz_file}    .xz
    ${output}   OperatingSystem.grep file    ${extract_path}/${unxz_file}
    ...    ${key_string}    encoding_errors=replace
    Should not be empty    ${output}

Verify specific tcpdump messages frame number should exist
    [Documentation]    Author:zheng.4.liu@nokia-sbell.com
    ...                This keyword is used to verify the c-plane msgs meet the expectations of RLF procedure.
    ...                ${file_path} should include dir name and file name and file extension(if any), eg: /home/ute/CPRT_trace.pcap
    [Arguments]        ${file_path}    ${display_filter}=${display_filter}    ${lua_script}=${LUA_SCRIPT_PATH}   
    #${all_packets}=    cap.load_pcap_file    pcap_file=${file_path}    tshark_path=${TSHARK_PATH}
    #...    luashark_path=${LUA_SCRIPT_PATH}
    #pcap.load_pcap_file    pcap_file=${file_path}     command_template=${command_template_with_Y}    alias=pcap1
    #${filtered_packets}   pcap.Filter Packets By Expression    filter_expression=${display_filter}    pcap_parser=pcap1
    pcap.setup    infile=${file_path}    display_filter=${display_filter}   tshark_path=${TSHARK_PATH}   alias=pcap1
    ${filtered_packets}   pcap.get_packets    filter=${display_filter}   pcap_parser=pcap1
    ${packet_length}    get length    ${filtered_packets}
    should be true    ${packet_length}>0
    
    

Update the beamforming configuration and start CPRT trace
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${parameters_to_update_via_api}=${MODIFY_BEAMFORMING_PARAMETERS_VIA_API_131}    ${CPRT_log_prefix}=CPRT_131_log
    ${update_status}=    COAM update several parameters via rest api
    ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
    Should be true    '${update_status}'=='PASS'
    ${cprt_log_path_asik}=    Start trace capturing without duration on container    log_prefix=${CPRT_log_prefix}
    ...    log_dir=/ffs/run/config/toor4nsn    connection_alias=${ASIK_SLAVE_ALIAS}
    ...    container_name=0xe005    interface=etha01
    [Return]    ${cprt_log_path_asik}

Stop CPRT trace and verify CPRT dlcell setupReq and itf l2 ps cellSetupReq messages
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${CPRT_log_prefix}=CPRT_140_log    ${CPRT_log_dir_ute}=${TS_CASE_LOG_PATH}    ${cprt_log_path}=${cprt_log_path}
    ...    ${dlMimoMode_type}=Open_loop
    ${connection}    set variable if    ${not_asib_flag}==${True}     ASIK Slave     GNB_OAM
    Stop trace capturing    log_prefix=${CPRT_log_prefix}    connection_alias=${connection}
    ${cprt_trace_on_ute}    Download trace log    log_full_path=${cprt_log_path}    log_dir_ute=${CPRT_log_dir_ute}
    ...    connection_alias=${ASIK_MASTER_ALIAS}
    Run keyword and continue on failure    Verify CPRT dlcell setupReq and itf l2 ps cellSetupReq messages    file_path=${cprt_trace_on_ute}
    ...    dlMimoMode_type=${dlMimoMode_type}

Verify CPRT dlcell setupReq and itf l2 ps cellSetupReq messages
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${file_path}=${cprt_trace_on_ute}    ${lua_script}=${LUA_SCRIPT_PATH}    ${dlMimoMode_type}=Open_loop
    ${setup_dlMimoMode}    set variable if    '${dlMimoMode_type}'=='Open_loop'    0x03    0x01
    ${ps_dlMimoMode}    set variable if    '${dlMimoMode_type}'=='Open_loop'    60    40
    ${dlcell_setupreq_filter}=    Catenate    DlCell_SetupReq.SetupReq.dlMimoMode == ${setup_dlMimoMode}
    ...                                       and DlCell_SetupReq.SetupReq.actBeamforming == 0x00
    ...                                       and DlCell_SetupReq.SetupReq.dlSubcellType == 0x01

    ${tf_l2_ps_cell_CellSetupReq_filter}=    Catenate    itf_l2_ps_cell_CellSetupReq.dlSubcellList_item_7.dlSubcellId == 0x00
    ...                                                  and itf_l2_ps_cell_CellSetupReq.dlSubcellList_item_7.dlSubcellType == 0x02
    ...                                                  and itf_l2_ps_cell_CellSetupReq.CellSetupReq.cellTechnology == 0x01
    ...                                                  and itf_l2_ps_cell_CellSetupReq.CellSetupReq.dlMimoMode == ${ps_dlMimoMode}
    ...                                                  and itf_l2_ps_cell_CellSetupReq.CellSetupReq.actBeamforming == 0x00
    Verify specific tcpdump messages frame number should exist    file_path=${file_path}    display_filter=${dlcell_setupreq_filter}
    ...    lua_script=${lua_script}
    Verify specific tcpdump messages frame number should exist    file_path=${file_path}    display_filter=${tf_l2_ps_cell_CellSetupReq_filter}
    ...    lua_script=${lua_script}

Stop CPRT trace and verify beamforming type in CPRT itf l2 ps cellSetupReq messages
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${CPRT_log_prefix}=CPRT_131_log    ${CPRT_log_dir_ute}=${TS_CASE_LOG_PATH}    ${cprt_log_path}=${cprt_log_path}
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    Connect to Common Unit Slave      alias=${ASIK_SLAVE_ALIAS}
    ${connection}    set variable if    ${asib_flag}==${False}     ASIK Slave     ASIK Master
    Stop trace capturing    log_prefix=${CPRT_log_prefix}    connection_alias=${connection}
    ${cprt_trace_on_ute}    Download trace log    log_full_path=${cprt_log_path}    log_dir_ute=${CPRT_log_dir_ute}
    ...    connection_alias=${ASIK_MASTER_ALIAS}
    Verify specific tcpdump messages frame number should exist    file_path=${cprt_trace_on_ute}
    ...    display_filter=itf_l2_ps_cell_CellSetupReq_t.actBeamforming == false    lua_script=${LUA_SCRIPT_PATH}

Collect BIP messages and verify dldata_csirssendreq message
    [Documentation]    Author: Wang Yixiang
    [Timeout]    15 min
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts with retry
    sleep    10 sec
    ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC

    ${dldata_CsiRsSendReq_filter}=    Catenate    DlData_CsiRsSendReq.csiRsResources_item_11.csiRsConfig == 0x04
    ...                                           and DlData_CsiRsSendReq.csiRsResources_item_11.antennaStream == 0x0f
    ${dldata_CsiRsSendReq_filter_19B}=    Catenate     DlData_CsiRsResource_t.csiRsConfig == 0x04
    ...                                           and DlData_CsiRsResource_t.antennaStream == 0x0f
    ${dldata_CsiRsSendReq_filter}     set variable if    '${program}'=='19A'    ${dldata_CsiRsSendReq_filter}
    ...                      ${dldata_CsiRsSendReq_filter_19B}
    Verify specific tcpdump messages frame number should exist    file_path=${list_log_path_local[0]}
    ...    display_filter=${dldata_CsiRsSendReq_filter}    lua_script=${LUA_SCRIPT_PATH}

Case env recovery for call case
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${name}=btslog    ${is_btslog_required}=${True}
    Run keyword if     '${ue_type}' == 'huawei'    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl   dt_name=dt_dl
    ...    iperf_port=${tl.ues[0].iperf_details.port}
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul   dt_name=dt_ul
    ...    iperf_port=${tl.appserver.iperf_details.port}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    COAM Verify if alarm exists    log_path_alarm=${TS_CASE_LOG_PATH}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot via webUI
    run keyword if    ${is_btslog_required}    stop btslog and collect logs    status=${TEST STATUS}}    name=${name}
    ${connection}    set variable if    ${not_asib_flag}==${True}     ASIK Slave     ASIK Master
    Run keyword and ignore error    Stop trace capturing    log_prefix=CPRT_140    connection_alias=${connection}
    #Run keyword and ignore error    csn.execute         command=rm ${cprt_log_path_asik}    connection=${ASIK_MASTER_ALIAS}
    Run keyword and ignore error    5GC000920_Keywords.Tear down connections

Lock and unlock administrativeState parameters on ENB start CPRT trace and wait until cell on air
    [Documentation]    Description: only lock unlock administrativeState parameter on ENB on 5G19A_FSMK_0006_008352_000738,
    ...                not trigger cell setup process, no bellow messages.
    ...                DlCell_SetupReq.SetupReq.dlMimoMode
    ...                DlCell_SetupReq.SetupReq.actBeamforming
    ...                DlCell_SetupReq.SetupReq.dlSubcellType
    ...                itf_l2_ps_cell_CellSetupReq.dlSubcellList_item_7.dlSubcellId ,
    ...                itf_l2_ps_cell_CellSetupReq.dlSubcellList_item_7.dlSubcellType,
    ...                itf_l2_ps_cell_CellSetupReq.CellSetupReq.cellTechnology,
    ...                itf_l2_ps_cell_CellSetupReq.CellSetupReq.dlMimoMode,
    ...                itf_l2_ps_cell_CellSetupReq.CellSetupReq.actBeamforming
    ...                manual tester advice add lock unlock GNB cell.
    [Arguments]    ${CPRT_log_prefix}=CPRT_140
    ${local_node_id}    set variable if    ${not_asib_flag}==${True}     0x1021     0x1011
    ${connection}    set variable if    ${not_asib_flag}==${True}     ASIK Slave     ASIK Master
    Connect to Common Unit Master
    ${cprt_log_path_asik}=    Start CPRT trace capturing    CPRT_log_prefix=${CPRT_log_prefix}
    ...    connection_alias=${connection}    local_node_id=${local_node_id}    retry_time=20
    coam.lock_cell    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1    connection=GNB_OAM
    Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Locked    cell_idx=${1}
    Update and verify administrativeState parameters on ENB    update_value=locked
    ...    parameters_to_update_via_api=${MODIFY_ADMINISTRATIVESTATE_PARAMETER_TO_LOCKED_VIA_API_140}
    coam.unlock_cell    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-1    connection=GNB_OAM
    Update and verify administrativeState parameters on ENB    update_value=unlocked
    ...    parameters_to_update_via_api=${MODIFY_ADMINISTRATIVESTATE_PARAMETER_TO_UNLOCKED_VIA_API_140}
    Wait until keyword succeeds    10 min    5 sec    COAM Check GNB cell on air    connection=${GNB_COAM_ALIAS}
    Verify all cells should be onair
    [Return]    ${cprt_log_path_asik}
    [Teardown]    Update and verify administrativeState parameters on ENB    update_value=unlocked
    ...    parameters_to_update_via_api=${MODIFY_ADMINISTRATIVESTATE_PARAMETER_TO_UNLOCKED_VIA_API_140}

Start x2 trace capturing from enb
    [Arguments]     ${log_prefix}    ${retry_time}=2    ${interface}=br1     ${log_dir}=/tmp
    wait until keyword succeeds    10 min    10 sec    Connect to eNB
    ${trace_timestamp}    Get Current Date    result_format=%H%M%S
    ${log_name}    Set variable    ${log_prefix}_${trace_timestamp}.pcap
    ${log_full_path_enb}    join path    ${log_dir}    ${log_name}
    csn.send command    command=nohup tcpdump -i ${interface} -s 0 -w ${log_full_path_enb}     connection=ENB
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${log_prefix}    connection_alias=ENB
    [Return]      ${log_full_path_enb}

Start syslog capture
    [Documentation]  Author: Wang Yixiang
    ...              btslog capture
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ...    ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    start btslog capture    name=${name}    btslog_path=${btslog_path}
    ...    btslog_launcher_path=${btslog_launcher_path}    log_dir=${log_storage_dir}    host=${host}

Stop syslog capture
    [Documentation]  Author: Wang Yixiang
    ...              stop btslog
    [Arguments]    ${name}=btslog
    core.stop_collectors      names=${name}
    sleep    1 sec
    core.collect_collectors   names=${name}    target_dir=${TS_CASE_LOG_PATH}
	core.teardown_collectors    names=${name}

Create default connection with hostname
    [Documentation]  Author: Wang Yixiang
    ...    create connection with hostname for ASIB cannot get IP
    [Arguments]  ${hw_slot}=${1}
    Connect to Common Unit Master
    #${is_feature_1514_enabled}    stream_manager.feature_1514_opened    connection=ASIK Master
    #${ABIL_ALIAS}    Set variable if     ${is_feature_1514_enabled}    ${ABIL_SLAVE_ALIAS}    ${ABIL_MASTER_ALIAS}
    ${ABIL_ALIAS}    Set variable      ${ABIL_SLAVE_ALIAS}
    Set suite variable    ${ABIL_ALIAS}
    #Run keyword if    ${is_feature_1514_enabled}
    #...    Connect to Capacity Unit Slave case    hw_slot=${hw_slot}    alias=${ABIL_ALIAS}    master_alias=ASIK Master
    #...    ELSE    connection_alias_store.Connect to Capacity Unit Master    alias=${ABIL_ALIAS}    asik_alias=${ASIK}    hw_slot=${hw_slot}
    Connect to Capacity Unit Slave case    hw_slot=${hw_slot}    alias=${ABIL_ALIAS}    master_alias=ASIK Master

Start TTI trace log capturing case
    [Documentation]    Author: Wang Yixiang
    ...    connection
    [Arguments]  ${hw_slot}=${1}    ${connection_for_abil}=${None}
    Run keyword if    '${connection_for_abil}'=='${None}'
    ...    Create default connection with hostname    hw_slot=${hw_slot}
    ${connection_for_abil}    Set variable if    '${connection_for_abil}'=='${None}'    ${ABIL_ALIAS}    ${connection_for_abil}
    tti.prepare_for_tti_trace_log_capturing    connection=${connection_for_abil}
    tti.start_tti_trace    connection=${connection_for_abil}

