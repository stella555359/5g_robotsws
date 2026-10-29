*** Settings ***
Documentation     author: Yuan Hongyan
...               Group: HGZ_SG1
...               contact: hongyan.1.yuan@nokia-sbell.com

Resource          ../../../5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library      requests
Library      json
Library      cell_edge_data_post-process.py
Library      cell_edge_data_post-process.LaVerification   WITH NAME   la
#Library          ../../../5GC000496_C/Resources/process_data_in_file.py
Library      process_data_in_file.ExcelReader     WITH NAME    excelreader
Library      taf.hw.rf_attenuator    WITH NAME    PA_
Library      hanging_resource.py
Library      taf.sw.scout    WITH NAME   scout
Library      DateTime


*** Variables ***
${scout_testline_name}      7_5_UTE5G402T011_gNB
${api_key}                  a4c9c584dbf641dc9bb7b0178fc5aeb3
#${template_id}              761
#${kpi_report_name}          cell_edge_KPI _TEMPLATE
${gnb_logs_save_path}        /home/ute/gnb_logs/TA
#${SHERPA_LOG_PATH}          /home/ute/sherpa_log/
${PA1_INFO}                  ${tl.attenuator}
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
${IMSI1}                     ${tl.ues[0].imsi}
${IMSI2}                     ${tl.ues[1].imsi}

${AMF_IP}                   ${tl.core.mme_ip}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}

${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}             https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${dist_name}                ${MRBTS_ID}/${NRBTS_ID}

${CONTROL_PC_IP}            ${tl.ues[0].ssh_connection_details.addr}
${CONTROL_PC_USERNAME}      ${tl.ues[0].ssh_connection_details.username}
${CONTROL_PC_PASSWORD}      ${tl.ues[0].ssh_connection_details.password}
${PA_INFO}                  ${tl.attenuators}

@{param_with_mean_value_default}    @{EMPTY}
@{param_with_mean_value_dl}    NR PDSCH iBLER[%]
@{param_with_mean_value_ul}    NR PUSCH iBLER[%]
##################define these variable for convenient############################
${UE_alias}                 UE_0
${ALIAS_5GC}                5gc
${ALIAS_AMF}                AMF
${ALIAS_ASIK}               asik
${ALIAS_ASIK_SLAVE}         asik_slave
${ALIAS1}                   ALIAS_OTA
${ALIAS_UTE}                ALIAS_UTE
########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####

TC.Stationary_Test
    KW.Set_PA_Values    cell_index=${TLCommonConfig['PAConfs']['stationary_test']['pa_cell_index']}
    ...    pa_value=${TLCommonConfig['PAConfs']['stationary_test']['pa_default']}
    KW.One_UE_L3Call_With_Traffic    dl_throughput=${CASE_INPUT_CellEdge['Stationary_Test']['dl_throughput']}
    ...    dltarget_throughput=${CASE_INPUT_CellEdge['Stationary_Test']['dltarget_throughput']}
    ...    ul_throughput=${CASE_INPUT_CellEdge['Stationary_Test']['ul_throughput']}
    ...    ultarget_throughput=${CASE_INPUT_CellEdge['Stationary_Test']['ultarget_throughput']}
    ...    cell_index=${CASE_INPUT_CellEdge['Stationary_Test']['traffic_cell_index']}
#    ...    check_tput=${False}
    ${status}  ${raw_data}   KW.Get_Param_Values_From_Spark   param_names=${CASE_INPUT_CellEdge['Stationary_Test']['pram_names_for_peak']}
    Set To Dictionary    ${raw_data}     NR PDCP Thr. DL [Mbps]=${dl_thput}       NR PDCP Thr. UL [Mbps]=${ul_thput}
    KW.Generate_Final_Data_for_Report_Server   ${raw_data}   pre-process=${False}
    UE.One_UE_Stop_traffic_and_Detach

TC.Link_Adaption_Test
    KW.Set_PA_Values   cell_index=${TLCommonConfig['PAConfs']['stationary_test']['pa_cell_index']}
    ...    pa_value=${TLCommonConfig['PAConfs']['link_adaption_test']['pa_default']}
    KW.One_UE_L3Call_With_Traffic    direction=dl    dl_throughput=${CASE_INPUT_CellEdge['LA_Test']['dl_throughput']}
    ...    dltarget_throughput=${CASE_INPUT_CellEdge['LA_Test']['dltarget_throughput']}    ultarget_throughput=0
    ...    check_tput=${False}
    ...    cell_index=${CASE_INPUT_CellEdge['Stationary_Test']['traffic_cell_index']}
    ${raw_data_dl}   KW.Verify_Link_Adaption_In_Round_Trips   param_names=${CASE_INPUT_CellEdge['LA_Test']['pram_names_for_dl']}
    ...    pa_default=${TLCommonConfig['PAConfs']['link_adaption_test']['pa_default']}
    ...    step=${CASE_INPUT_CellEdge['LA_Test']['step']}
    ...    end=${CASE_INPUT_CellEdge['LA_Test']['PA_max']}
    ...    loop_time=${CASE_INPUT_CellEdge['LA_Test']['loop_time']}
    ...    param_with_mean_value=${param_with_mean_value_dl}
    run keyword and ignore error    UE.One_UE_Stop_traffic_and_Detach
    KW.One_UE_L3Call_With_Traffic    direction=ul    ul_throughput=${CASE_INPUT_CellEdge['LA_Test']['ul_throughput']}
    ...    ultarget_throughput=${CASE_INPUT_CellEdge['LA_Test']['ultarget_throughput']}    dltarget_throughput=0
    ...    check_tput=${False}
    ...    cell_index=${CASE_INPUT_CellEdge['Stationary_Test']['traffic_cell_index']}
    ${raw_data_ul}   KW.Verify_Link_Adaption_In_Round_Trips   param_names=${CASE_INPUT_CellEdge['LA_Test']['pram_names_for_ul']}
    ...    pa_default=${TLCommonConfig['PAConfs']['link_adaption_test']['pa_default']}
    ...    step=${CASE_INPUT_CellEdge['LA_Test']['step']}
    ...    end=${CASE_INPUT_CellEdge['LA_Test']['PA_max']}
    ...    loop_time=${CASE_INPUT_CellEdge['LA_Test']['loop_time']}
    ...    param_with_mean_value=${param_with_mean_value_ul}
    KW.Generate_Final_Data_for_Report_Server   ${raw_data_dl}    ${raw_data_ul}   pre-process=${True}
    KW.Verify_Checkpoints    dl_param_names=${CASE_INPUT_CellEdge['LA_Test']['pram_names_for_dl']}
    ...    dl_peak_thput=${CASE_INPUT_CellEdge['LA_Test']['dltarget_throughput']}   dl_max_mcs=${26}
    ...    dl_max_rank=${CASE_INPUT_CellEdge['LA_Test']['dl_max_rank']}
    ...    ul_param_names=${CASE_INPUT_CellEdge['LA_Test']['pram_names_for_ul']}
    ...    ul_peak_thput=${CASE_INPUT_CellEdge['LA_Test']['ultarget_throughput']}   ul_max_mcs=${27}
    ...    ul_max_rank=${CASE_INPUT_CellEdge['LA_Test']['ul_max_rank']}
    UE.One_UE_Stop_traffic_and_Detach

TC.KPI_Test
    KW.Attach_UE_Multiple_Times_and_Get_Timeframe
    ${snapshot_file}   KW.Collect_Snapshot
    KW.Extract_API_Data_from_Snapshot  snapshot_file=${snapshot_file}
    ${file_path}   ${keys}  KW.Get_KPI_Source_File_and_Key_Column
    ...    file_to_check=${CASE_INPUT_CellEdge['KPI_Test']['file_to_check']}
    ...    sheet_to_check=${CASE_INPUT_CellEdge['KPI_Test']['sheet_to_check']}
    ...    key_column_name=${CASE_INPUT_CellEdge['KPI_Test']['key_column_name']}
    ${KPIs_data}   KW_Get_DATA_of_KPIs   KPIs=${CASE_INPUT_CellEdge['KPI_Test']['KPIs']}   target_file_path=${file_path}
    ...    sheet_to_check=${CASE_INPUT_CellEdge['KPI_Test']['sheet_to_check']}     key_raw_data=${keys}
    KW.Generate_Final_Data_for_Report_Server    ${KPIs_data}    pre-process=${False}

TC.Attach_Success_Rate_at_Cell_Edge
    ${attach_rate_data}   ${result}    KW.Repeat_Test_at_different_attenuation
    ...    test_times=${CASE_INPUT_CellEdge['Attach_Rate']['test_times']}
    ...    attach_times=${CASE_INPUT_CellEdge['Attach_Rate']['attach_times']}
    ...    pa_start_value=${TLCommonConfig['PAConfs']['attach_rate']['pa_default']}
    ...    cell_index=${TLCommonConfig['PAConfs']['attach_rate']['pa_cell_index']}
    run keyword and continue on failure    Should be true
    ...    "${result[0]['successrate']}"=="100.0%" and "${result[-1]['successrate']}"!="100.0%"
    KW.Generate_Final_Data_for_Report_Server    ${attach_rate_data}    pre-process=${False}
    run keyword and ignore error   KW.Check_Attach_Related_Counters

TC.KPI_Test_For_without_traffic_OTA_ENV
    #[Arguments]  ${start_time}=2023-04-13 03:35:00
    ${collect_log_start_time}    get current time
    Set Test Variable    ${loop_times}    ${CASE_INPUT_CellEdge['OTA_KPI_Test']['without_traffic_loop_times']}
    KW.Attach_commercial_UE_Multiple_Times_and_Get_Timeframe  script_name=multi_ue_attach_detach_without_traffic_threading.py
    ${snapshot_file}   KW.Collect_Snapshot
    Set test Variable   ${snapshot_file}      ${snapshot_file}
    Run Keyword And Ignore Error    save log to server  snapshot_file=${snapshot_file}  gnb_logs_save_path=${gnb_logs_save_path}
    Run Keyword If   ${CASE_INPUT_CellEdge['OTA_KPI_Test']['save_snapshot_to_UTE']} == True
    ...    KW.save_snapshot_to_UTE    snapshot_transit_path=${snapshot_file}
#    KW.Extract_API_Data_from_Snapshot  snapshot_file=${snapshot_file}
#    ${file_path}   ${keys}  KW.Get_KPI_Source_File_and_Key_Column
#    ...    file_to_check=${CASE_INPUT_CellEdge['KPI_Test']['file_to_check']}
#    ...    sheet_to_check=${CASE_INPUT_CellEdge['KPI_Test']['sheet_to_check']}
#    ...    key_column_name=${CASE_INPUT_CellEdge['KPI_Test']['key_column_name']}
#    ${KPIs_data}   KW_Get_DATA_of_KPIs   KPIs=${CASE_INPUT_CellEdge['KPI_Test']['KPIs']}   target_file_path=${file_path}
#    ...    sheet_to_check=${CASE_INPUT_CellEdge['KPI_Test']['sheet_to_check']}     key_raw_data=${keys}
#    KW.Generate_Final_Data_for_Report_Server    ${KPIs_data}    pre-process=${False}
    [Teardown]  run keyword and ignore error     Generate kpi report in Scout   report_name_1=CellEdge_without_traffic_
       ...   collect_log_start_time=${collect_log_start_time}

TC.KPI_Test_with_short_time_ul_traffic_For_OTA_ENV
    ${collect_log_start_time}    get current time
    Set Test Variable    ${loop_times}    ${CASE_INPUT_CellEdge['OTA_KPI_Test']['with_short_time_ul_traffic_loop_times']}
    KW.Attach_commercial_UE_Multiple_Times_and_Get_Timeframe  script_name=multi_ue_attach_detach_with_short_time_ul_traffic_threading.py
    ${snapshot_file}   KW.Collect_Snapshot
    Set test Variable   ${snapshot_file}      ${snapshot_file}
    Run Keyword And Ignore Error    save log to server  snapshot_file=${snapshot_file}  gnb_logs_save_path=${gnb_logs_save_path}
    Run Keyword If   ${CASE_INPUT_CellEdge['OTA_KPI_Test']['save_snapshot_to_UTE']} == True
    ...    KW.save_snapshot_to_UTE    snapshot_transit_path=${snapshot_file}
    [Teardown]  run keyword and ignore error     Generate kpi report in Scout     report_name_1=CellEdge_with_short_time_ul_traffic_
     ...  collect_log_start_time=${collect_log_start_time}

TC.KPI_Test_with_long_time_ul_traffic_For_OTA_ENV
    ${collect_log_start_time}    get current time
    Set Test Variable    ${loop_times}    ${CASE_INPUT_CellEdge['OTA_KPI_Test']['with_long_time_ul_traffic_loop_times']}
    KW.Attach_commercial_UE_Multiple_Times_and_Get_Timeframe  script_name=multi_ue_attach_detach_with_long_time_ul_traffic_threading.py
    ${snapshot_file}   KW.Collect_Snapshot
    Set test Variable   ${snapshot_file}      ${snapshot_file}
    Run Keyword And Ignore Error    save log to server  snapshot_file=${snapshot_file}  gnb_logs_save_path=${gnb_logs_save_path}
    Run Keyword If   ${CASE_INPUT_CellEdge['OTA_KPI_Test']['save_snapshot_to_UTE']} == True
    ...    KW.save_snapshot_to_UTE    snapshot_transit_path=${snapshot_file}
    [Teardown]  run keyword and ignore error     Generate kpi report in Scout     report_name_1=CellEdge_with_long_time_ul_traffic_
     ...  collect_log_start_time=${collect_log_start_time}

####Case Level Keywords####
Get Specific Format Time
    ${current_time}=  Get Time  result_format=%Y-%m-%d %H:%M:%S.%f
    [Return]   ${current_time}

Setup Suite
    TestSuite.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    ${gnb_version}       KW.Get_gNB_Active_SW_Version
    set suite variable    ${gnb_version}
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    Conn.ResetCache
    set suite variable  ${CFGFILE_PATH}   /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/7_5_UTE5G402T011/
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
    #run keyword if   ${SCF_Delta_Implementation}    KW.Generate_TL_SCF


KW.Generate_TL_SCF
    ${StreamInfo}        Basic.GetStreamInfo    StreamInfoName=STREAM_INFOs
    Import Variables        ${CURDIR}/CaseSCFDelta.py   # needs be here, as gNB.GenerateTestLineSCFs checks its existance.
    Import Variables        ${CFGFILE_PATH}TLSCFDelta_${StreamInfo['StreamPrefix']}.py
    set suite variable    ${DeltaPath}                ${CURDIR}/CaseSCFDelta.py
    ${outputfile}    gNB.GenerateTestLineSCFs
    set suite variable    ${Original_CFGFILE}    ${outputfile}


Teardown Suite
    TestSuite.Stop

Setup case
    TestCase.Start
    log to console     Case Start
    run keyword if    ${SCF_Delta_Implementation}    KW.ModifyAndCommissionAndCheckOnair
    ...    original_cfgfile=${Original_CFGFILE}    modified_cfgfile=${LOG_PATH}/${TEST NAME}.xml
    ...    parameters_to_modify=PARAMS_TO_MODIFY_CellEdge   parameters_to_delete=PARAMS_TO_CellEdge
    ...    mo_to_add=ADD_MOS_CellEdge    list_parameter_to_modify=LIST_PARAMS_TO_MODIFY_CellEdge
    ...    list_to_add=LIST_TO_ADD_CellEdge
    ...    ELSE    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
    run keyword and ignore error    BtsLog.StartBTSlogCollection

Teardown case
     [Arguments]   ${URL}   ${graph}=${False}   ${data}=${all_data_to_pass}   ${graph_type}=LA
     KW.Put_Stats_To_Report_Server    data=${data}  URL=${URL}   graph=${graph}   graph_type=${graph_type}
     run keyword and ignore error    AMTU.Disconnect
     run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
#    log     ${TEST STATUS}
#    Run Keyword If  '${TEST STATUS}' == 'FAIL'    gNB.CollectSnapshot
#    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${UE_TYPE}     direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul
    ${status}  ${5Grach_ed}  run keyword and ignore error   power_ue.UE Detach  ue_type=${UE_TYPE}
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Conn.ResetCache
#    TestCase.Stop

KW.OTA block cell
    Run Keyword And Ignore Error    COAM_WebEM.Login
    Set Test Variable    ${block_cell_index}   ${CASE_INPUT_CellEdge['OTA_KPI_Test']['block_cell_index']}
    ${length}    get length    ${block_cell_index}
    FOR    ${i}    IN RANGE    ${length}
        COAM_WEBEM.BlockUnBlcokCell     cell_idx=${block_cell_index[${i}]}   action=block
        sleep  3s
    END
    Run Keyword And Ignore Error    COAM_WebEM.Logout
KW.save_snapshot_to_UTE
    [Arguments]      ${snapshot_transit_path}  ${Snapshot_history}=/home/ute/Snapshot_history/
    Run Keyword And Ignore Error    run    command=cp ${snapshot_transit_path}* ${Snapshot_history}
    sleep  15s

Setup case for OTA
    TestCase.Start
    set suite variable     ${5GRU2_PA_Ports}        ${CASE_INPUT_CellEdge['OTA_KPI_Test']['5GRU2_PA_Ports']}
    set suite variable     ${PA_Value}              ${CASE_INPUT_CellEdge['OTA_KPI_Test']['PA_Value']}
    set suite variable     ${template_id}           ${CASE_INPUT_CellEdge['OTA_KPI_Test']['template_id']}
    set suite variable     ${PC_IP}                 ${CASE_INPUT_CellEdge['OTA_KPI_Test']['PC_IP_LIST']}
    set suite variable     ${PC_USERNAME}           ${CASE_INPUT_CellEdge['OTA_KPI_Test']['PC_USERNAME_LIST']}
    set suite variable     ${PC_PASSWORD}           ${CASE_INPUT_CellEdge['OTA_KPI_Test']['PC_PASSWORD_LIST']}
    set suite variable     ${DEBUG_LOG}             ${CASE_INPUT_CellEdge['OTA_KPI_Test']['ENABLE_DEBUG_LOG']}
    set suite variable     ${UE_REBOOT}             ${CASE_INPUT_CellEdge['OTA_KPI_Test']['ENABLE_UE_REBOOT']}
    Run Keyword And Ignore Error   Adjust PA To Default Value for L3CALL
    run    command=cp ${CFGFILE_PATH}/TL011_golden.xml ${LOG_PATH}/TL011_golden.xml
    gNB.CommissionWithRetry   scf_file=${LOG_PATH}/TL011_golden.xml    model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
     ...    RUmodel=${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}
    wait until keyword succeeds     15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    Run Keyword If   ${CASE_INPUT_CellEdge['OTA_KPI_Test']['block_cell']} == True
    ...    KW.OTA block cell
    log to console     Case Start



Teardown case for OTA
    [Arguments]   #${URL}   ${graph}=${False}   ${data}=${all_data_to_pass}   ${graph_type}=LA
    #KW.Put_Stats_To_Report_Server    data=${data}  URL=${URL}   graph=${graph}   graph_type=${graph_type}
    Run Keyword And Ignore Error    run    command=sudo ps -ef|grep multi_ue_attach_detach | grep -v grep | awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Conn.ResetCache

Adjust PA To Default Value for L3CALL
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${PA_Value}   attenuator=${PA1_INFO}
    ...    logging_message=Setting PA values for FDD CELL2 default value.

KW.PA_Adjust Attenuation Ports To Same Value
    [Arguments]    ${ports}    ${value}    ${attenuator}   ${logging_message}=Adjusting PA values
    log to console    ${logging_message}
    PA_.setup_attenuator    attenuator=${attenuator}
    ${length}    Get Length    ${ports}
    FOR    ${i}    IN RANGE    ${length}
        PA_.set_attenuation     port=${ports[${i}]}    value=${value}
        PA_.read_attenuation    port=${ports[${i}]}
    END

KW.Attach_commercial_UE_Multiple_Times_and_Get_Timeframe
    [Arguments]   ${attach_mode}=5G_SA    ${script_name}=multi_ue_attach_detach_threading.py
    #${gnb_logs_save_path}   Start collect EMIL log at UTE
    ${start}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${START_TIME}   set variable    ${start.strftime("%H")}:${start.strftime("%M")}
    #Set Test Variable    ${test_duration}  ${CASE_INPUT_CellEdge['OTA_KPI_Test']['test_duration']}
    #KW.Multi PC click flight mode
    #sleep    ${test_duration}
    KW.Mult_UE_trun off and on flight mode1  script_name=${script_name}
    #Multi_UE_ATTACH for loop
    ${end}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${END_TIME}   set variable    ${end.hour}:${end.minute}
    set test variable    ${START_TIME}
    set test variable    ${END_TIME}
    #Run Keyword And Ignore Error    Stop collect EMIL log at UTE
#    KW.WEBEM_LockUnlcokCell   cell_idx=${2}    action=lock    checkstatus=false
#    execute_hanging_resource_file     ute_ip=${UTE_IP}   ute_name=${UTE_USERNAME}   ute_pwd=${UTE_PASSWORD}     gnb_ip=${WEBUI_IP}
#   [Teardown]    KW.WEBEM_LockUnlcokCell  cell_idx=${2}    action=unlock    checkstatus=false

KW.WEBEM_LockUnlcokCell
    [Arguments]   ${cell_idx}=1    ${action}=lock    ${timeout}=60    ${checkstatus}=true
    Run Keyword And Ignore Error    COAM_WebEM.Login
    Wait Until Keyword Succeeds    3x    10s
    ...   COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=${action}    checkstatus=${checkstatus}
    Run Keyword And Ignore Error    COAM_WebEM.Logout

Multi_UE_ATTACH for loop
    [Arguments]    ${ue_index}=${0}     ${times}=${3}   ${connection}=connection
    Set Test Variable    ${times}  ${CASE_INPUT_CellEdge['OTA_KPI_Test']['loop_times']}
    FOR  ${i}    IN RANGE   1   ${times}+1
        log to console   Start the ${i}/${times} round(s) of testing
        KW.Multi PC click flight mode
    END

KW.Multi PC click flight mode
    ${PC_nums}    Get Length    ${tl.ues}
    FOR  ${i}    IN RANGE     ${PC_nums}
        KW.Mult_UE_trun off and on flight mode1   ue_index=${i}
        sleep   5s
    END
KW.Mult_UE_trun off and on flight mode1
    [Arguments]    ${script_name}=multi_ue_attach_detach_threading.py    ${ue_index}=${0}      ${connection}=connection    ${action}=attach
    ...   ${SCF_path}=/home/ute/TAF/cfgfile/
#    ...    ${pc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}   ${pc_username}=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    ${pc_password}=${tl.ues[${ue_index}].ssh_connection_details.password}   ${loop_times}=2400
#    @{PC_IP_ALL}    Create List
#    ${UE_nums}    Get Length    ${tl.ues}
#    : FOR    ${i}    IN RANGE   ${UE_nums}
#        ${pc_ip}   set variable    ${tl.ues[${i}].ssh_connection_details.addr}
#        Append To List    ${PC_IP_ALL}    ${pc_ip}
#        log to console   ${PC_IP_ALL}
#    END
    log to console    start to trun off and on flight mode for loop
    Run Keyword And Ignore Error    run
    ...  command=python ${SCF_path}${script_name} '${PC_IP}' '${PC_USERNAME}' '${PC_PASSWORD}' ${loop_times} ${DEBUG_LOG} ${UE_REBOOT}
    #...   command=python ${SCF_path}${script_name} '${PC_IP_ALL}' 'nokia5G,mn5gran' 'noki@123,nokia123@' ${loop_times} true false

KW.Mult_UE_trun off and on flight mode
    [Arguments]    ${ue_index}=${0}      ${connection}=connection    ${action}=attach
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${ALIAS1}
    ssh.send_command   command=adb devices  connection=${ALIAS1}      timeout=10
    BuiltIn.Sleep   10s
    ${output}=    csn.Read output    connection=${ALIAS1}
    Should not be empty    ${output}
    log to console   ${output}
    # use command adb devices to get serial_number
    @{First_split}=    Split String   ${output}     separator=\r\n\r\n
    ${Second_split}=    Split String   ${First_split}[0]     separator=\r\n
    ${fromlist}   Get Slice From List  ${Second_split}   1
    ${UE_nums}    Get Length    ${fromlist}
    FOR    ${i}    IN RANGE    0    ${UE_nums}
        ${first_split1}=  Split String   ${fromlist}[${i}]     separator=\t
        ${serial_number}  set variable     ${first_split1}[0]
        Continue For Loop If    '${first_split1}[1]' != 'device'
        KW.Get UE brand and UI version    connection=${ALIAS1}   serial_number=${serial_number}
        Run Keyword If   '${first_split1}[1]' == 'device'   trun off and on flight mode  serial_number=${serial_number}  connection=${ALIAS1}
        sleep  1s
    END
    [Teardown]    csn.disconnect      connection=${ALIAS1}


KW.Get UE brand and UI version
    [Arguments]    ${ui_version}=default    ${connection}=connection   ${serial_number}=0
    ssh.send_command   command=adb -s ${serial_number} shell getprop ro.product.brand   connection=${ALIAS1}      timeout=10
    ${output}=    csn.Read output    connection=${ALIAS1}
    ${brand}=    Strip String    ${output}
    #Should not be empty    ${brand}    msg=Fail to get brand info from ue ${serial_number}, please check your ue status
    Set test Variable   ${brand}      ${brand}
    ssh.send_command   command=adb -s ${serial_number} shell getprop ro.product.name   connection=${ALIAS1}      timeout=10
    ${output}=    csn.Read output    connection=${ALIAS1}
    ${product_name}=    Strip String    ${output}
    #Should not be empty    ${product_name}    msg=Fail to get product name info from ue ${serial_number}, please check your ue status
    ${ui_version}   Run Keyword If   '${brand}'=='samsung'   KW.get samsung UI version   product_name=${product_name}
    ...   ELSE                         Set Variable    default
    Get all pointer variable1     ui_version=${ui_version}


KW.get samsung UI version
    [Arguments]   ${product_name}=default
    ${ui_version}   Run Keyword If    '${product_name}'=='x1qsqw'     Set Variable   S20UI2.1    #SAMSUNG S20
    ...   ELSE IF                     '${product_name}'=='z3qsqw'     Set Variable   S20UI2.5    #SAMSUNG S20 Ultra 5G
    ...   ELSE IF                     '${product_name}'=='y2qsqw'     Set Variable   S20UI2.5    #SAMSUNG S20+
    ...   ELSE IF                     '${product_name}'=='o1qsqw'     Set Variable   S21UI4.0    #SAMSUNG S21
    ...   ELSE IF                     '${product_name}'=='t2qsqw'     Set Variable   S21UI4.1    #SAMSUNG S21+
    ...   ELSE IF                     '${product_name}'=='g0qsqw'     Set Variable   S22UI4.1    #SAMSUNG S22
    ...   ELSE                         Set Variable    default
    [Return]   ${ui_version}

trun off and on flight mode
    [Documentation]    click AIRPLANE switch twice
    ...    :param  swipe: Swipe the phone screen up
    ...    :param  Home_button: UE home button keycode
    ...    :param  airplane: airplane switch pointer variable
    ...    :param  close_task: close all UE's task pointer variable
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${airplane}=${airplane}    ${close_task}=${close_task}
    ...   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=connection
    log to console     ${serial_number} start to click flight mode button
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=${connection}
    sleep   1s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}
       ...   connection=${connection}
    sleep   1s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=${connection}
    sleep   1s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=${connection}
    sleep   1s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=${connection}
    sleep   1s
    ${output}   csn.read_output    connection=${connection}
    #####Tap the airplane mode switch to disable airplane mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=${connection}
    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
    ...   Close Airmode confirm window for lg_v50   old_output=${output}  serial_number=${serial_number}  connection=${connection}
    sleep   1s
    #####Tap the airplane mode switch to enable airplane mode#####
#    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=${connection}
#    sleep   1s
#    run keyword if    '${brand}'=='lge'   Run Keyword and Ignore Error
#    ...   Close Airmode confirm window for lg_v50   old_output=${output}  serial_number=${serial_number}   connection=${connection}
    #####Click the task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   1s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}
    sleep   1s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}
      ...    connection=${connection}
    sleep   1s

Get all pointer variable1
    [Documentation]    Get all pointer variable.
    ...  :param  ui_version: The ui version from UE, for samsung the default is ui version [S10UI1.1], also support S10UI2.1
    [Arguments]      ${ui_version}=default
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='default'
    ...    Get all Samsung pointer variable
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S10UI2.1'
    ...    Get all Samsung pointer variable with S10UI2.1
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S20UI2.1'
    ...    Get all Samsung pointer variable with S20UI2.1
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S20UI2.5'
    ...    Get all Samsung pointer variable with S20UI2.5
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S21UI3.1'
    ...    Get all Samsung pointer variable with S21UI3.1
    run keyword if    '${brand}'=='HUAWEI'
    ...    Get all Huawei pointer variable
    run keyword if    '${brand}'=='HUAWEI' and '${ui_version}'=='M40PUI1.1'
    ...    Get all Huawei pointer variable with M40PUI1.1
    run keyword if    '${brand}'=='Xiaomi' and '${ui_version}'=='default'
    ...    Get all Xiaomi pointer variable
    run keyword if    '${brand}'=='Xiaomi' and '${ui_version}'=='Mi12UI13.0.12'
    ...    Get all Xiaomi pointer variable with Mi12UI13.0.12
    run keyword if    '${brand}'=='HONOR' and '${ui_version}'=='default'
    ...    Get all HONOR pointer variable
    run keyword if    '${brand}'=='HONOR' and '${ui_version}'=='S30UI3.1.1'
    ...    Get all HONOR pointer variable with S30UI3.1.1
    run keyword if    '${brand}'=='lge'
    ...    Get all LG pointer variable1
    run keyword if    '${brand}'=='OnePlus'
    ...    Get all Oneplus pointer variable
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S21UI4.0'
    ...    Get all Samsung pointer variable with S21UI4.0
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S21UI4.1'
    ...    Get all Samsung pointer variable with S21UI4.1
    run keyword if    '${brand}'=='Redmi'
    ...    Get all Redmi pointer variable


Get all Samsung pointer variable with S21UI4.1
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    941 412
    Set Suite Variable    ${close_task}    535 1865
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    900 380
    Set Suite Variable    ${iperf_space}    800 550

Get all LG pointer variable1
    Set Suite Variable    ${home}    KEYCODE_HOME
    Set Suite Variable    ${airplane}    1000 1000
    Set Suite Variable    ${close_task}    700 2450
    Set Suite Variable    ${Home_button}    KEYCODE_HOME
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    1200 360
    Set Suite Variable    ${iperf_space}    800 650

KW.ModifyAndCommissionAndCheckOnair
    [Documentation]    1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    ...                4. Do cell search and ue attach and Check
    [Arguments]       ${original_cfgfile}
    ...               ${modified_cfgfile}
    ...               ${parameters_to_modify}='NULL'
    ...               ${parameters_to_delete}='NULL'
    ...               ${mo_to_add}='NULL'
    ...               ${list_parameter_to_modify}='NULL'
    ...               ${list_to_add}='NULL'
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.GenerateCaseSCF    InputFile=${original_cfgfile}
    ...                    OutputFile=${modified_cfgfile}
    ...                    ResourceFolder=${CURDIR}
    ...                    ParamterToModify=${parameters_to_modify}
    ...                    ParameterToDelete=${parameters_to_delete}
    ...                    MOsToAdd=${mo_to_add}
    ...                    ListParamterToModify=${list_parameter_to_modify}
    ...                    ListToAdd=${list_to_add}
    gNB.CommissionWithRetry    scf_file=${modified_cfgfile}     model=HBTE
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

KW.BtsLog.StartBTSlogCollection
    [Documentation]    collect syslogs from ute VM.
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

KW.Set_PA_Values
    [Documentation]    Set the values of programmable attenuator to the same pre-defined value. The programmable attenuator
    ...     can be inside AMTU as a buit-in module, or a standalone equipment like one from TopYoung or HBTE.
    [Arguments]   ${pa_value}   ${AMTU_used}=${AMTU_USED}   ${cell_index}=1
    ...    ${PAGroup}=${TLCommonConfig['PAGroups']['1']}  ${attenuator}=${PA_INFO[0]}
    Run Keyword If    '${AMTU_used}'=='${True}'   KW.AMTU_Set_PA_Values  pa_value=${pa_value}
    ...    ELSE     PA.AdjustAttenuationValueByGroup   PAGroup=${PAGroup}   value=${pa_value}  attenuator=${attenuator}

KW.AMTU_Set_PA_Values
    [Documentation]   Only appliable to AMTU. Set attenuation values to a same predifined value using its built-in PA module.
    ...    CellIdx 0 means all cell, 1 2 3 4 means cell index
    [Arguments]    ${cell_index}=1   ${pa_value}=0   ${path}=${PA_Controller_PATH}
    AMTU.Connect     host=${CONTROL_PC_IP}     username=${CONTROL_PC_USERNAME}     password=${CONTROL_PC_PASSWORD}
    AMTU.SetToDefault    CellIdx=${cell_index}   path=${path}
    KW.AMTU_Increment_PA_Value   CellIdx=${cell_index}    Value=${pa_value}   offset=false    path=${path}

KW.AMTU_Increment_PA_Value
    [Documentation]     Only appliable to AMTU. Inrement attenuation by the value defined,
    ...    CellIdx: 0 means all cell, 1 2 3 4 means cell index
    ...    offset:  [Restriction/Limitation]PA control CLI tool can only add value to the current value, can't reset to a new value.
    ...    i.e. the pram 'offset' doesn't work, no matter it is true or false, value is inremented by the value defined,
    ...    instead of reseted to the value defined.
    ...    path: The folder where you put the PA contoller in the control PC of AMTU
    [Arguments]   ${CellIdx}=1   ${Value}=3   ${offset}=false   ${path}=${PA_Controller_PATH}
    ${output}    AMTU.SetCellInfo    CellIdx=${CellIdx}   Value=${Value}   offset=${offset}   path=${path}
    log to console    ${output}

KW.Verify_Link_Adaption_In_Round_Trips
    [Documentation]    list, int, int, int, int, int, list --> list
    ...    retrun a list like below:
    ...    [{'index': 1, 'att': 0, 'pram_name1': 'parm_value1', ...,  'pram_namen': 'parm_valuen'},
    ...    {'index': 2, 'att': 3, 'pram_name1': 'parm_value1', ...,  'pram_namen': 'parm_valuen'},
    ...    ...
    ...    {'index': n, 'att': x, ''pram_name1': 'parm_value1', ...,  'pram_namen': 'parm_valuen'},]
    [Arguments]   ${param_names}   ${pa_default}    ${start}=${0}   ${step}=${3}   ${end}=${54}  ${loop_time}=${2}
    ...   ${param_with_mean_value}=${None}
    ${loop_res}    Create list
    ${ATT_change_time}   set variable    ${0}
    Set test variable    ${ATT_change_time}
    ${x_axis_start_point}    set variable    ${start}
    ${initial_step}    evaluate    0-${step}
    ${first_time}   KW.Verify_Link_Adaption_Via_Change_PA_Gradually   param_names=${param_names}
    ...    start=${pa_default}  step=${initial_step}   end=${x_axis_start_point}  param_with_mean_value=${param_with_mean_value}
    ${loop_res}    combine lists     ${loop_res}   ${first_time}
    FOR   ${i}    IN RANGE    ${loop_time}
        ${odd}     evaluate    ${i} % 2 == 1
        ${step}    run keyword if    ${odd}    evaluate   -1 * ${step}
        ...    ELSE    set variable    ${step}
        Log to console    Start increaing attenuation to the max value ${end} in a step of ${step}.
        ${res_up}   KW.Verify_Link_Adaption_Via_Change_PA_Gradually   param_names=${param_names}   start=${start}  step=${step}  end=${end}
        ...    param_with_mean_value=${param_with_mean_value}
        ${loop_res}     combine lists     ${loop_res}   ${res_up}
        ${step}   evaluate    0-${step}
        Log to console    Start reducing attenuation to 0 in a step of ${step} till.
        ${res_down}   KW.Verify_Link_Adaption_Via_Change_PA_Gradually   param_names=${param_names}  start=${end}  step=${step}  end=${start}
        ...   param_with_mean_value=${param_with_mean_value}
        ${loop_res}    combine lists     ${loop_res}   ${res_down}
    END
    [Return]    ${loop_res}

KW.Verify_Link_Adaption_Via_Change_PA_Gradually
    [Documentation]    list, int, int, int --> list
    ...    retrun a list like below:
    ...    [{'index': 1, 'att': 0, 'pram_name1': 'parm_value1', ...,  'pram_namen': 'parm_valuen'},
    ...    {'index': 2, 'att': 3, 'pram_name1': 'parm_value1', ...,  'pram_namen': 'parm_valuen'},
    ...    ...
    ...    {'index': n, 'att': x, ''pram_name1': 'parm_value1', ...,  'pram_namen': 'parm_valuen'},]
    [Arguments]   ${param_names}   ${start}=${0}    ${step}=${3}    ${end}=${54}    ${interval}=${3}
    ...    ${param_with_mean_value}=${param_with_mean_value_default}
    ${res}    create list
    AMTU.Connect     host=${CONTROL_PC_IP}     username=${CONTROL_PC_USERNAME}     password=${CONTROL_PC_PASSWORD}
    FOR    ${value}    IN RANGE    ${start}    ${end}    ${step}
        ${pa_value}    evaluate     ${value}+${step}
#        KW.AMTU_Increment_PA_Value   CellIdx=1    Value=${step}   offset=false
        KW.Set_PA_Values   pa_value=${pa_value}
        ${ATT_change_time_new}   evaluate    ${ATT_change_time} + 1
        set test variable   ${ATT_change_time}    ${ATT_change_time_new}
        log to console    PA is changed for the ${ATT_change_time} time.
#        ${index}   evaluate    str(${ATT_change_time}).zfill(2)
        ${index}   evaluate    str(${ATT_change_time})
        sleep   ${interval}
        ${status}  ${statistics}  KW.Get_Param_Values_From_Spark   param_names=${param_names}
        ...    param_with_mean_value=${param_with_mean_value}
#        ${res}   evaluate     dict(${res.items()} + ${statistics.items()})
        ${pa_value_str}   evaluate   str(${pa_value})
        &{one_time_res}    Create Dictionary    index=${index}    att=${pa_value_str}    &{statistics}
        append to list      ${res}    ${one_time_res}
    END
    [Return]    ${res}

KW.Get Param Value
    [Arguments]    ${param}   ${ue_index}=${0}   ${ue_alias}=UE_${ue_index}
    [Documentation]    Get Param Value from spark.
    ${output}    spark.get_parm_value_on_ue    ue_alias=${UE_alias}    param=${param}
    [Return]    ${output}

KW.Get_Param_Mean_Value
    [Arguments]    ${param}   ${ue_index}=${0}   ${ue_alias}=UE_${ue_index}   ${interval}=${1}   ${times}=${10}
    [Documentation]    Get Param Value from spark for ${times} times, then return the mean value.
    ${sum}    set variable    ${0}
    FOR   ${item}    IN RANGE    ${times}
        ${output}    spark.get_parm_value_on_ue    ue_alias=${UE_alias}    param=${param}
        ${sum}   evaluate   ${sum} + ${output}[0]
        sleep    ${interval}
    END
    ${mean_value}    evaluate    ${sum} / ${times}
    ${mean}    evaluate    str(round(${mean_value}, 2))
    ${mean_str}    convert to string     ${mean}
    [Return]    ${mean_str}

KW.Replace_Certain_Items_in_Param_Values
    [Arguments]    ${param_names}   ${param_values}    ${name_to_replace}    ${value_to_replace}
    ${new_values}    copy list    ${param_values}
    ${idx}    Get Index From List    ${param_names}    ${name_to_replace}
    set list value    ${new_values}    ${idx}   ${value_to_replace}

    Log to console   The ${idx} value of ${param_values} for ${param_names} was changed to ${value_to_replace}.
    Log to console   Final result is ${new_values}
    [Return]    ${new_values}

KW.Get_Param_Values_From_Spark
    [Documentation]    list, int, int --> boolean, dict
    ...    Get Param Value from spark based on the names in param_names.
    ...    eg. {'NR Rank Avg. DL': u'4.0', 'NR MCS Avg. DL': u'19.4', 'NR PDSCH iBLER[%]': u'0.00',
    ...    'NR SSB RSRP[dBm]': u'-74.16', 'NR PDCP Thr. DL [Mbps]': u'107.683'}
    [Arguments]   ${param_names}   ${retry_times}=${10}    ${ue_index}=${0}
    ...    ${param_with_mean_value}=${param_with_mean_value_default}
    ${status}   set variable    ${True}
    ${res}    create dictionary
    ${valid_param_values}    set variable    @{Empty}

    FOR   ${item}    IN RANGE    ${retry_times}
        ${param_values}    Run Keyword And Continue On Failure   KW.Get Param Value
        ...      ue_index=${ue_index}   param=${param_names}
        continue for loop if    len(${param_values}) == 0
        ${validness}  KW.Check_Validness_Of_Param_Values    values=${param_values}   prams=${param_names}
        ${valid_param_values}   run keyword if   ${validness}    set variable   ${param_values}
        exit for loop if   ${validness}
    END
    ${status}   set variable    ${validness}
    run keyword if  not ${status}   log    Get param value from Spark failed!   level=WARN   console=yes
    return from keyword if    "${validness}"=="${False}"   ${status}   ${res}
#    should not be empty    ${valid_param_values}
    ${param_mean_cnt}    Get length    ${param_with_mean_value}
    ${mean}   run keyword if   ${param_mean_cnt}!=${0}   KW.Get_Param_Mean_Value   param=${param_with_mean_value}
    ...    ELSE    set variable   ${None}
    ${final_values}   run keyword if   ${param_mean_cnt}!=${0}   KW.Replace_Certain_Items_in_Param_Values
    ...    param_names=${param_names}    param_values=${valid_param_values}
    ...    name_to_replace=${param_with_mean_value}[0]    value_to_replace=${mean}
    ...    ELSE    set variable   ${valid_param_values}
    ${res}    evaluate    dict(zip(${param_names}, ${final_values}))
#    ${valid_param_values_new}    ${param_names_new}   KW.devide tput data by ${100} in ${valid_param_values} and ${param_names}
#    ${res}    evaluate    dict(zip(${param_names_new}, ${valid_param_values_new}))
    [Return]   ${status}   ${res}

KW.devide tput data by ${devider} in ${values} and ${names}
    [Documentation]  not used anymore.
    ...    change the values accordingly if the corresponding unit changed.
    ${values_new}   create list
    ${names_new}   create list

    ${index_value}   set variable    ${0}
    FOR   ${item}   IN   @{values}
        ${new_value}   run keyword if    ${index_value}==${dl_tput_idx} or ${index_value}==${ul_tput_idx}
        ...    evaluate     ${item}/${devider}
        ...    ELSE    set variable     ${item}
        append to list    ${values_new}    ${new_value}
        ${index_value}   evaluate    ${index_value}+1
    END

    ${index_name}   set variable    ${0}
    FOR   ${item}   IN   @{names}
#        run keyword if    ${index_name}==${dl_tput_idx}
#        ...    Set List Value    ${names}    ${index_name}     NR PDCP Thr. DL [${devider}Mbps]
#        run keyword if    ${index_name}==${ul_tput_idx}
#        ...    Set List Value    ${names}    ${index_name}     NR PDCP Thr. UL [${devider}Mbps]
        ${new_name}   run keyword if    ${index_name}==${dl_tput_idx} or ${index_name}==${ul_tput_idx}
        ...    set variable      ${item.replace("Mbps]", "${devider}" + "Mbps]")}
        ...    ELSE    set variable     ${item}
        append to list    ${names_new}    ${new_name}
        ${index_name}   evaluate    ${index_name}+1
    END
    [Return]   ${values_new}    ${names_new}

KW.Check_Validness_Of_Param_Values
    [Arguments]   ${values}    ${prams}
    ${res}    set variable    ${False}
    ${index}  set variable    ${-1}
    ${valid_item_count}    set variable    ${0}
    ${target_valid_item_count}    set variable    len(${values})
    ${dl_bler_idx}    Get Index From List     ${prams}   NR PDSCH iBLER[%]
    ${ul_bler_idx}    Get Index From List     ${prams}   NR PUSCH iBLER[%]
    ${dl_tput_idx}    Get Index From List     ${prams}   NR PDCP Thr. DL [Mbps]
    ${ul_tput_idx}    Get Index From List     ${prams}   NR PDCP Thr. UL [Mbps]
    set test variable    ${dl_tput_idx}
    set test variable    ${ul_tput_idx}
    FOR   ${item}   IN   @{values}
         ${index}   evaluate    ${index}+1
         Continue For Loop If   '${item}'=='${None}'
         Continue For Loop If   '${item}'==''
         Continue For Loop If   '${item}'=='${0}' and ${index}!=${dl_bler_idx} and ${index}!=${ul_bler_idx}
         ${valid_item_count}    evaluate    ${valid_item_count}+1
    END
    ${res}    set variable if    ${valid_item_count}==${target_valid_item_count}   ${True}   ${False}
    [Return]   ${res}

KW.Attach_UE_Multiple_Times_and_Get_Timeframe
    [Arguments]   ${attach_mode}=5G_SA     ${times}=${100}
    ${start}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${START_TIME}   set variable    ${start.hour}:${start.minute}
    KW.Attach_UE_Multiple_Times    attach_mode=${attach_mode}    times=${times}
    ${end}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${END_TIME}   set variable    ${end.hour}:${end.minute}
    set test variable    ${START_TIME}
    set test variable    ${END_TIME}

KW.Attach_UE_Multiple_Times
    [Arguments]   ${attach_mode}=5G_SA     ${times}=${100}
    power_ue.Prepare UE    ue_type=${UE_TYPE}    detach_request=${true}    power_reset=true
    FOR  ${i}  IN RANGE   ${times}
        log to console    Attaching UE for for ${i+1} times.
        run keyword and ignore error   power_ue.UE Attach     ue_type=${UE_TYPE}   power_reset=True    attach_mode=${attach_mode}
        sleep   3s
        run keyword and ignore error   power_ue.UE Detach  ue_type=${UE_TYPE}   power_reset=True
        sleep   2s
    END

KW.One_UE_L3Call_With_Traffic
    [Arguments]   ${attach_mode}=5G_SA   ${dl_throughput}=500Mbits/sec   ${ul_throughput}=100Mbits/sec   ${dl_duration}=3600
    ...    ${ul_duration}=3600    ${cell_index}=${0}    ${dltarget_throughput}=400     ${ultarget_throughput}=50
    ...    ${direction}=bi    ${check_tput}=${True}
    power_ue.Prepare UE    ue_type=${UE_TYPE}    detach_request=${true}    power_reset=true
    power_ue.UE Attach     ue_type=${UE_TYPE}   power_reset=True    attach_mode=${attach_mode}
    run keyword if    '${direction}' == 'bi'    run keywords
    ...    Run Keyword And Ignore error   power_ue.Start traffic    ue_type=${UE_TYPE}   direction=dl   throughput=${dl_throughput}
    ...    duration=${dl_duration}
    ...    AND    Run Keyword And Ignore error   power_ue.Start traffic    ue_type=${UE_TYPE}   direction=ul
    ...    throughput=${ul_throughput}  duration=${ul_duration}
    ...    ELSE IF    '${direction}' == 'ul'
    ...    Run Keyword And Ignore error   power_ue.Start traffic    ue_type=${UE_TYPE}   direction=ul
    ...    throughput=${ul_throughput}  duration=${ul_duration}
    ...    ELSE IF    '${direction}' == 'dl'
    ...    Run Keyword And Ignore error   power_ue.Start traffic    ue_type=${UE_TYPE}   direction=dl   throughput=${dl_throughput}
    ...    duration=${dl_duration}
    Run keyword if     '${check_tput}' == '${True}'    KW.Check_Throughput    cell_index=${cell_index}
    ...    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}
    ...    dltarget_throughput=${dltarget_throughput}   ultarget_throughput=${ultarget_throughput}
    sleep    3s


KW.Check_Throughput
    [Arguments]   ${dl_throughput}=500Mbits/sec   ${ul_throughput}=100Mbits/sec
    ...    ${ul_duration}=1800    ${cell_index}=${0}    ${dltarget_throughput}=400     ${ultarget_throughput}=50
    ${tput_log}    power_ue.Collect Tput   ue_type=${UE_TYPE}
    ${target_cell_id}    KW.Get NR Cell Indentities    cell_index=${cell_index}
    ${list_of_cell_ids}    Create list    ${target_cell_id}
    ...     dltarget_throughput=${dltarget_throughput}   ultarget_throughput=${ultarget_throughput}
    ${ul_thput}    ${dl_thput}   Power_ue.Check Bi Tput   ue_type=${UE_TYPE}   cells=${list_of_cell_ids}    log=${tput_log}
    ...     dltarget_throughput=${dltarget_throughput}   ultarget_throughput=${ultarget_throughput}
    ${ul_thput}    evaluate    str(round(${ul_thput}, 2))
    ${dl_thput}    evaluate    str(round(${dl_thput}, 2))
    set test variable    ${ul_thput}
    set test variable    ${dl_thput}

KW.Get NR Cell Indentities
    [Arguments]   ${cell_index}=${0}
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=GNB_OAM
    COAM Teardown gnb connections   connection=GNB_OAM
    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
    ${nrCellIdentity_list}    Create List
    FOR    ${item}    IN     @{cell_id_list}
        ${nrCellIdentity}    Evaluate    int(${cell_mapping[${item}]['nrCellIdentity']})
        Append To List    ${nrCellIdentity_list}    ${nrCellIdentity}
    END
    [Return]    ${nrCellIdentity_list}[${cell_index}]

KW.Get_gNB_Active_SW_Version
    [Arguments]   ${connection}=COAM
    wait until keyword succeeds   10x   1min    COAM_Admin.Login    alias=${connection}
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=10
    ${active_sw_version}   Run Keyword If   "${sw_info['Active SW version']}"!="${None}" and "${sw_info['Active SW version']}"!=""
    ...   COAM_Admin.TransferSWVersion   ${sw_info['Active SW version']}
    log to console       get gNB SW version completed
    COAM_Admin.Logout
    [Return]   ${active_sw_version}

KW.Generate_Final_Data_for_Report_Server
   [Arguments]    @{data}   ${pre-process}=${False}
   ${all_data_to_pass}=    run keyword if   '${pre-process}'=='${True}'    KW.Pre-process_Data    @{data}
   ...    ELSE    Set variable    ${data[0]}
   Set test variable    ${all_data_to_pass}

KW.Pre-process_Data
    [Documentation]   pre-process the data for drawing graphs.
    [Arguments]    ${statistics_dl}   ${statistics_ul}
#    log    ${statistics_dl}
#    log    ${statistics_ul}
    ${statistics_dl_json}    json.dumps    ${statistics_dl}
    ${statistics_ul_json}    json.dumps    ${statistics_ul}

    ${traffic_data_to_pass_shadow}    set to dictionary   ${CASE_INPUT_CellEdge['LA_Test']['data_to_pass']}
    ...    ${CASE_INPUT_CellEdge['LA_Test']['graph_title_dl']}=${statistics_dl}
    ...    ${CASE_INPUT_CellEdge['LA_Test']['graph_title_ul']}=${statistics_ul}
    ...    DL_Ranges=${CASE_INPUT_CellEdge['LA_Test']['dl_pram_value_ranges']}
    ...    UL_Ranges=${CASE_INPUT_CellEdge['LA_Test']['ul_pram_value_ranges']}
    ...    DL_Names=${CASE_INPUT_CellEdge['LA_Test']['pram_names_for_dl']}
    ...    UL_Names=${CASE_INPUT_CellEdge['LA_Test']['pram_names_for_ul']}
    ${all_data_to_pass_shadow}   create dictionary     Testline=${testline_name}
    ...    Version=${gnb_version}    &{traffic_data_to_pass_shadow}
    set test variable    ${all_data_to_pass_shadow}

    ${traffic_data_to_pass}    set to dictionary   ${CASE_INPUT_CellEdge['LA_Test']['data_to_pass']}
    ...    ${CASE_INPUT_CellEdge['LA_Test']['graph_title_dl']}=${statistics_dl_json}
    ...    ${CASE_INPUT_CellEdge['LA_Test']['graph_title_ul']}=${statistics_ul_json}
    ...    DL_Ranges=${CASE_INPUT_CellEdge['LA_Test']['dl_pram_value_ranges']}
    ...    UL_Ranges=${CASE_INPUT_CellEdge['LA_Test']['ul_pram_value_ranges']}
    ...    DL_Names=${CASE_INPUT_CellEdge['LA_Test']['pram_names_for_dl']}
    ...    UL_Names=${CASE_INPUT_CellEdge['LA_Test']['pram_names_for_ul']}

    [Return]   ${traffic_data_to_pass}

KW.Verify_Checkpoints
    [Arguments]  ${dl_param_names}  ${dl_peak_thput}  ${dl_max_mcs}  ${dl_max_rank}
    ...    ${ul_param_names}  ${ul_peak_thput}  ${ul_max_mcs}  ${ul_max_rank}
    text.write_dicts_to_json_file   file_path=${LOG_PATH}   file_name=data.json   data=${all_data_to_pass_shadow}
    la.get_data_from_json_file    filename=${LOG_PATH}/data.json
    ...    dl_param_list=${dl_param_names}   ul_param_list=${ul_param_names}
    ${dl_res}=   la.verify_checkpoints   direction=dl   peak_thput=${dl_peak_thput}   max_mcs=${dl_max_mcs}   max_rank=${dl_max_rank}
    ${ul_res}=   la.verify_checkpoints   direction=ul   peak_thput=${ul_peak_thput}   max_mcs=${ul_max_mcs}   max_rank=${ul_max_rank}
    should be true    ${dl_res} and ${ul_res}


KW.Put_Stats_To_Report_Server
    [Arguments]    ${data}   ${URL}  ${graph}=${False}  ${testline}=${testline_name}   ${graph_type}=LA
#    log to console    API from tool center under development.
    ${time} =	Get Time
    &{final_data}   create dictionary     Testline=${testline}
    ...    Version=${gnb_version}    Result=${TEST STATUS}
    ...    &{data}
    log dictionary    ${final_data}

    requests.post    ${URL}    data=${final_data}

    run keyword if    '${graph}'=='${True}' and '${graph_type}'=='LA'   run keywords
    ...    run keyword and ignore error   text.write_dicts_to_json_file   file_path=${LOG_PATH}
    ...    file_name=data_shadow.json   data=${all_data_to_pass_shadow}
    ...    AND    run keyword and ignore error    run
    ...    command=python /home/ute/YHY/demo_graph/cell_edge/Resource/drawing.py ${LOG_PATH}/data_shadow.json

    run keyword if    '${graph}'=='${True}' and '${graph_type}'=='KPI'   run keywords
    ...    run keyword and ignore error   text.write_dicts_to_json_file   file_path=${LOG_PATH}
    ...    file_name=KPI_data_shadow.json   data=${KPI_data_to_pass_shadow}
    ...    AND    run keyword and ignore error    run
    ...    command=python /home/ute/YHY/demo_graph/cell_edge/Resource/drawing_kpi.py ${LOG_PATH}/KPI_data_shadow.json

KW.Collect_Snapshot
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    [Return]   ${snapshot_file}
save log to server
    [Arguments]    ${snapshot_file}  ${gnb_logs_save_path}
#    Create Directory   ${output_log_path}
#    Empty Directory    ${output_log_path}
    save snapshot log to server  snapshot_file=${snapshot_file}   output_log_path=${LOG_PATH}
    save gnb log to server  gnb_logs_save_path=${gnb_logs_save_path}   output_log_path=${LOG_PATH}
save snapshot log to server
    [Arguments]    ${snapshot_file}   ${output_log_path}
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${output_log_path}
    sleep  5s
save gnb log to server
    [Arguments]    ${gnb_logs_save_path}  ${output_log_path}
    Run Keyword And Ignore Error    run    command=cp ${gnb_logs_save_path}/* ${output_log_path}
    sleep  5s

KW.Extract_API_Data_from_Snapshot
    [Arguments]  ${snapshot_file}   ${LTEPAT_path}=/home/ute/LTEPAT/   ${snapshot_transit_path}=/home/ute/Snapshot_log/
    ...    ${snapshot_output_path}=/home/ute/Snapshot_log_output/    ${template_file}=PmTemplateExample.xml
    Create Directory   ${snapshot_transit_path}
    Create Directory   ${snapshot_output_path}
    Empty Directory    ${snapshot_transit_path}
    Empty Directory    ${snapshot_output_path}
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${snapshot_transit_path}
    sleep  5s
    Run Keyword And Ignore Error    run    command=cd ${LTEPAT_path}; mono LTEPAT.exe ${template_file}
    sleep  30s

KW.Get_KPI_Source_File_and_Key_Column
    [Documentation]
    [Arguments]  ${file_to_check}=PMOutput.xlsx  ${sheet_to_check}=KPIs_All   ${key_column_name}=StartTime
    ...    ${snapshot_output_path}=/home/ute/Snapshot_log_output/
    @{output_file_names}   List Directory    ${snapshot_output_path}
    @{files}  Create list
    FOR  ${file}  IN   @{output_file_names}
        ${name}   Fetch From Right    ${file}    _
        append to list    ${files}    ${name}
    END
    ${target_file_index}   Get Index From List    ${files}   ${file_to_check}
    ${target_file_path}   set variable    ${snapshot_output_path}/${output_file_names[${target_file_index}]}

    ${key_raw_data}   excelreader.get_column_values_by_column_name
    ...    excel_file=${target_file_path}
    ...    sheet_name=${sheet_to_check}  column_name=${key_column_name}
#    set test variable    ${target_file_path}
#    set test variable    ${key_raw_data}
    log    ${key_raw_data}
    [Return]   ${target_file_path}   ${key_raw_data}

KW.Get_Data_of_one_KPI
    [Documentation]
    [Arguments]  ${KPI_name}   ${filter_col_in}   ${values_accepted}   ${filter_col_out}  ${values_unexcepted}
    ...    ${target_file_path}    ${sheet_to_check}    ${key_raw_data}

    ${row_indices_in}    excelreader.get_row_indices_by_values_in_a_column   excel_file=${target_file_path}
    ...    sheet_name=${sheet_to_check}  column_name=${filter_col_in}   cell_values=${values_accepted}
    log   row_indices_in is ${row_indices_in}

    ${row_indices_out}    excelreader.get_row_indices_by_values_in_a_column  excel_file=${target_file_path}
    ...    sheet_name=${sheet_to_check}  column_name=${filter_col_out}   cell_values=${values_unexcepted}
    log   row_indices_out is ${row_indices_out}

    remove values from list    ${row_indices_in}   @{row_indices_out}

    ${KPI_raw_data}   excelreader.get_column_values_by_column_name  excel_file=${target_file_path}
    ...    sheet_name=${sheet_to_check}   column_name=${KPI_name}
    log    ${KPI_raw_data}

    ${final_KPI_data}    Create list
#    ${id}   set variable    ${1}
    FOR  ${index}  IN   @{row_indices_in}
        ${time_str}   convert to string    ${key_raw_data[${index}]}
        ${time}   ${remainder}  split string from right   ${time_str}   :    1
        ${KPI_value}    convert to string    ${KPI_raw_data[${index}]}
        log  ${time}
#        ${KPI_dict}    create dictionary   id=${id}    ${time}=${KPI_value}
        ${KPI_dict}    run keyword if   '${time}'>='${START_TIME}'    create dictionary   ${time}=${KPI_value}
        ...    ELSE    continue for loop
        append to list    ${final_KPI_data}    ${KPI_dict}
#        ${id}    evaluate    ${id}+${1}
    END
    log    ${final_KPI_data}
    [Return]  ${final_KPI_data}

KW_Get_DATA_of_KPIs
    [Documentation]   NR_5151b  NR_5013A  NR_5167b  NR_5143b
    [Arguments]  ${KPIs}    ${target_file_path}   ${sheet_to_check}     ${key_raw_data}
    log   ${KPIs}
    ${KPIs_data}    create dictionary
    ${KPIs_data_shadow}   create dictionary
    FOR   ${KPI}  IN   @{KPIs}
        ${KPI_data}   KW.Get_Data_of_one_KPI  KPI_name=${KPI['name']}  filter_col_in=${KPI['conditions_accepted']['filter_column']}
        ...    values_accepted=${KPI['conditions_accepted']['values']}    filter_col_out=${KPI['conditions_unaccepted']['filter_column']}
        ...    values_unexcepted=${KPI['conditions_unaccepted']['values']}   target_file_path=${target_file_path}
        ...    sheet_to_check=${sheet_to_check}    key_raw_data=${key_raw_data}
        ${KPI_data_json}    json.dumps    ${KPI_data}
        set to dictionary    ${KPIs_data_shadow}    ${KPI['name']}=${KPI_data}   Start_Time=${START_TIME}    End_Time=${END_TIME}
        set to dictionary    ${KPIs_data}    ${KPI['name']}=${KPI_data_json}    Start_Time=${START_TIME}    End_Time=${END_TIME}
    END
    # The following statements are only used for test-used python ploting
    set test variable    ${KPIs_data_shadow}
    ${KPI_data_to_pass_shadow}   create dictionary     Testline=${testline_name}
    ...    Version=${gnb_version}    IDs=${CASE_INPUT_CellEdge['KPI_Test']['KPI_IDs']}  &{KPIs_data_shadow}
    set test variable    ${KPI_data_to_pass_shadow}
#    run keyword and ignore error   text.write_dicts_to_json_file   file_path=${LOG_PATH}
#    ...    file_name=KPI_data_shadow.json   data=${KPI_data_to_pass_shadow}
    [Return]  ${KPIs_data}


KW.Attach_UE_MulTimes_and_Get_Success_Rate
    [Arguments]    ${attach_times}=${10}   ${ue_index}=${0}    ${attach_mode}=5G_SA   ${cell_index}=${0}
    ...    ${dl_throughput}=100Kbits/sec  ${ul_throughput}=100Kbits/sec   ${dl_duration}=300    ${ul_duration}=300
    ...    ${dltarget_throughput}=100     ${ultarget_throughput}=100
    ...    ${direction}=dl    ${check_tput}=${False}
    ${success_cnt}   Set Variable   ${0}
    ${rsrp_sum}   Set Variable   ${0}
    ${rsrp_param}   create list    NR SSB RSRP[dBm]
    ${thput_param}   create list    NR PDCP Thr. DL [Mbps]
#    ${invalid_attach_values}   create dictionary    NR SSB RSRP[dBm]=${0}    NR PDCP Thr. DL [Mbps]=${0}
    ${valid_rsrp_cnt}   Set Variable   ${0}
    FOR    ${i}    IN RANGE    ${attach_times}
        log to console     Attaching UE for the ${i+1} time.
        KW.One_UE_L3Call_With_Traffic   attach_mode=${attach_mode}  cell_index=${cell_index}
        ...    dl_throughput=${dl_throughput}  dl_duration=${dl_duration}   dltarget_throughput=${dltarget_throughput}
        ...    ul_throughput=${ul_throughput}  ul_duration=${ul_duration}   ultarget_throughput=${ultarget_throughput}
        ...    direction=${direction}    check_tput=${check_tput}
        ${status_rsrp}  ${rsrp_param_value}   KW.Get_Param_Values_From_Spark    ${rsrp_param}   ue_index=${ue_index}
        ${status_thput}  ${thput_param_value}   KW.Get_Param_Values_From_Spark    ${thput_param}   ue_index=${ue_index}
        ${valid_flag}   evaluate   ${status_rsrp} and ${status_thput}
        continue for loop if    '${valid_flag}'=='${false}'
#        ${attach_values}   set variable if   ${status}    ${attach_param_values}   ${invalid_attach_values}
#        Run Keyword And Ignore error   power_ue.Stop traffic   ue_type=${UE_TYPE_FOR_SUCCESS_RATE}    direction=dl   ue_index=${ue_index}
        run keyword and ignore error    UE.One_UE_Stop_traffic_and_Detach
        ${success_flag}   Set Variable If   ${thput_param_value["NR PDCP Thr. DL [Mbps]"]} > 0.08  ${1}  ${0}
        ${rsrp_valid_flag}   Set Variable If   ${status_rsrp}  ${1}   ${0}
        ${success_cnt}   Evaluate    ${success_cnt}+${success_flag}
        ${valid_rsrp_cnt}   Evaluate    ${valid_rsrp_cnt}+${rsrp_valid_flag}
        ${rsrp_sum}  run keyword if   ${status_rsrp}    Evaluate    ${rsrp_sum}+${rsrp_param_value["NR SSB RSRP[dBm]"]}
        ...   ELSE    set variable   ${rsrp_sum}
        run keyword if   ${status_rsrp}   log to console     Current rsrp is: ${rsrp_param_value["NR SSB RSRP[dBm]"]}dBm
        ...    ELSE    log to console    No signal, thus no rsrp value got.
        run keyword if   ${status_thput}   log to console     DL throughput is: ${thput_param_value["NR PDCP Thr. DL [Mbps]"]}Mbit/s.
        ...    ELSE    log to console    No signal, thus no throught value got.
    END
    run keyword if   ${valid_rsrp_cnt}==${0}   fail   Spark got no signal, pls check if the attenation is too big.
    ${success_rate}  Evaluate   round(100*${success_cnt}/${attach_times},2)
    ${rsrp_average}    evaluate    round(${rsrp_sum}/${valid_rsrp_cnt},2)
    [Return]     ${success_rate}     ${rsrp_average}

KW.Repeat_Test_at_different_attenuation
    [Arguments]    ${test_times}=${10}   ${pa_start_value}=${50}   ${cell_index}=${10}    ${ue_index}=${0}   ${attach_times}=${10}
    ${pa_value}    set variable    ${pa_start_value}
    ${result}    create list
    FOR    ${i}    IN RANGE    ${test_times}
        log to console    \n**********Starting the ${i+1}-round test!**********
        KW.Set_PA_Values   cell_index=${cell_index}   pa_value=${pa_value}
        ${success_rate}    ${rsrp_average}    KW.Attach_UE_MulTimes_and_Get_Success_Rate   ue_index=${ue_index}   attach_times=${attach_times}
        ${rsrp_str}    evaluate    str(${rsrp_average})
        ${pa_str}    evaluate    str(${pa_value})
        log to console    Result for the ${i+1}-round test:\n PA value is ${pa_str}dB, RSRP is ${rsrp_str}dBm, success rate is ${success_rate}%.
        ${one_time_result}   create dictionary    version=${gnb_version}  testline=${testline_name}   pa=${pa_str}   rsrp=${rsrp_str}
        ...    successrate=${success_rate}%
        Append to list    ${result}    ${one_time_result}
        ${pa_value}      Evaluate     ${pa_value}+${1}
    END
    ${result_json}    json.dumps    ${result}
    &{attach_rate_data}   create dictionary    attach_rate_result=${result_json}
    [Return]     ${attach_rate_data}    ${result}

KW.Check_Attach_Related_Counters
    ${M55306C06001}    KW.GetCounterSumValue    counter_id=M55306C06001    full_path=[CELL1] CELLS/NRCELL-1/NRACH/RA_MSG3_RECEP
    ${M55306C00002}    KW.GetCounterSumValue    counter_id=M55306C00002    full_path=[CELL1] CELLS/NRCELL-1/NRACH/RA_ATT_CONT_A_PRMBL_SSB_01
    ${M55306C00003}    KW.GetCounterSumValue    counter_id=M55306C00003    full_path=[CELL1] CELLS/NRCELL-1/NRACH/RA_ATT_CONT_A_PRMBL_SSB_02
    ${M55125C02501}    KW.GetCounterSumValue    counter_id=M55125C02501    full_path=[CELL1] CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_STP_REQ_RECD
    ${M55125C02502}    KW.GetCounterSumValue    counter_id=M55125C02502    full_path=[CELL1] CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_STP_RESP_SENT
    ${ssb01_02}    Evaluate    ${M55306C00002}+${M55306C00003}
    ${succ_rate}    Evaluate    ${ssb01_02}/${M55306C06001}
    run keyword and ignore error   should be equal    ${M55125C02501}  ${M55125C02502}
    run keyword and ignore error   should be true    ${succ_rate}>=1 and ${succ_rate}<=1.05

KW.GetCounterSumValue
    [Arguments]    ${counter_id}    ${full_path}
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   ${counter_id}    ${full_path}
    log    ${res}
    run keyword and ignore error    COAM_WebEM.Logout
    ${values}    get dictionary values   ${res}
    log    ${values}
    log  The latest one is: ${values[-1]}
    ${length}    get length    ${values}
    ${count_sum}   set variable  ${0}
    ${Idx}   set variable    ${0}
    FOR    ${i}    IN RANGE    ${length}
        ${count_sum}    Evaluate    ${count_sum}+${values[${Idx}]}
        ${Idx}    Evaluate    ${i}+1
    END
    log    ${count_sum}
    [Return]   ${count_sum}



Start collect EMIL log at UTE
    [Arguments]     ${gnb_logs_script_path}=/home/ute/gnb_logs/   ${gnb_index}=${0}
    log to console    --- start gnb_logs collection---
    ssh.Connect to    hostname=${UTE_IP}
    ...               username=${UTE_USERNAME}
    ...               password=${UTE_PASSWORD}
    ...               alias=${ALIAS_UTE}
    ssh.send command    command=cd ${gnb_logs_script_path}TA; sudo rm *    connection=${ALIAS_UTE}
    ssh.send command    command=cd ${gnb_logs_script_path}; sudo ./gnb_logs ${WEBUI_IP} -N ${gnb_logs_save_path} -e
      ...   connection=${ALIAS_UTE}
    sleep  10s
    [Return]   ${gnb_logs_save_path}
    #[Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=${ALIAS_UTE}

Stop collect EMIL log at UTE
    [Arguments]   ${gnb_logs_script_path}=/home/ute/gnb_logs/
    log to console    --- stop gnb_logs collection---
    Run Keyword And Ignore Error    run    command=cd ${gnb_logs_script_path}; sudo touch stop_mon.log
    sleep  60s
    ${gnb_version}       KW.Get_gNB_Active_SW_Version
    Run Keyword And Ignore Error    run    command=cd /home/ute/EMIL_log_hisrtory/; mkdir ${gnb_version}
    Run Keyword And Ignore Error    run    command=sudo mv ${gnb_logs_save_path}/* /home/ute/EMIL_log_hisrtory/${gnb_version}/

Generate kpi report in Scout
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Param: ${scout_testline_name} is "TL73_gNB" or "TL813_gNB", scout_testline_name in scout, type: str
    ...               Param: the style of ${end_time} and ${start_time} like as "2022-03-29 04:10:00"
    ...                      Time delta between start and end must be above 15 minutes"
    ...                      ${end_time} and ${start_time}:  Date and time must be in past
    ...                      Use the pm xml file under the path "/ffs/run/uri/PERFMON_FILES/" of gnb
    ...                      if " -rw-r--r-- 1 root btssw  72682 Mar 31 11:35 PM.BTS-813.20220331.033500.ANY.xml.gz "
    ...                      so ${end_time} or ${start_time} use 20220331.033500 into "2022-03-31 03:35:00"
    ...               Param: ${template_id}---https://scout.nsn-rdnet.net/kpis-templates/382/, 382 is ${template_id}
    ...               Param: ${api_key}---scout for easy access from robot framework to Scout API
    [Arguments]     ${collect_log_start_time}   ${alias}=scout  ${report_name_1}=CellEdge_
    log to console   ${collect_log_start_time}
    ${gnb_version}       KW.Get_gNB_Active_SW_Version
    ${new_timestamp}    get current time
    ${kpi_report_name}   Catenate    SEPARATOR=   ${report_name_1}   ${gnb_version}
    scout.setup_scout    scout_testline_name=${scout_testline_name}    api_key=${api_key}    alias=${alias}
    ${report}    scout.generate kpi report    report_name=${kpi_report_name}
    ...                                       template_id=${template_id}
    ...                                       start_time=${collect_log_start_time}
    ...                                       end_time=${new_timestamp}
    ...                                       alias=${alias}
    [Teardown]    Run Keyword And Ignore Error    scout.teardown_scout_api    alias=${alias}


get current time
    ${current_time}  DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
    ${new_time}  DateTime.Subtract Time From Date  ${current_time}  8.5hours
    ${new_timestamp}=    DateTime.Convert Date    ${new_time}    result_format=%Y-%m-%d %H:%M:%S.%f
    [Return]     ${new_timestamp}
