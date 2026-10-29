*** Settings ***
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Library    ../lib/CB011116.py
Variables   ../TestData/1116_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_logs_Capture.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot

Documentation
...    author: jiangjing lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
@{physCellId_list}    ${581}    ${582}
@{cell_ids}    ${301}    ${302}
@{cell1_id}    ${301}
@{cell2_id}    ${302}
@{cell3_id}    ${303}
${tshark_path}      /usr/bin/tshark
${command_template}    {tshark_path} -r {pcap_file} -Y  \"dldata_pdschsendreql1sw && !(3gpp.rnti == 65535)\"  -T pdml
${command_template_2}    {tshark_path} -r {pcap_file} -Y  \"UlData_srsReceiveReqSubcell_t.srsRtBfEnable == True && uldata_srsreceivereq"  -T pdml

*** Keywords ***
CB011116_SR_AA_Verify_L3call and beam fallback_With_1CC_8DL
    [Arguments]    ${tput}    ${cell_id}    ${ue_type}=huawei_sigspark    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0    ${du_index}=0    ${duration_call}=${9999}
    ...    ${duration_collect}=${300}    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${gnb_tool_path}=/home/ute    ${spark_log_dir}=/home/ute
    old log clear
    #**************************************check cp log*********************************************************
    log to console    load scf of 1CC_8DL
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _1CC_8DL.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}
    CP Log Capture    duration=${120}
    Wait until keyword succeeds    1min    1s    Check CP Log Started Capture
    log to console    check cell onair
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    Get CP Log Name    tool_log_name=tool.log
    CP Log Unzip    cp_log_name=${cp_log_name}
    ${all_packets}    cap.load_pcap_file    pcap_file=${cp_log_unzip_full_path}
    log to console    check message ulcell_setupreq
    ${req_packets}    cap.filter_packets_by_expression    filter_expression=ulcell_setupreq
    log to console    check pSRSBwvAct is true
    ${values}    cap.get_field_value_by_xpath    xpath=.//UlCell_SetupReq_t.pSRSBwvAct
    log to console    ${values}
    should be true    "${values[-1]}"=="True" or ${values[-1]}==1
    log to console    check bwvsubbandsize is 8PRBs
    ${values}    cap.get_field_value_by_xpath    xpath=.//UlCell_pSRSBwvConfig_t.bwvSubbandSize
    log to console    ${values}
    should be equal    ${values[-1]}    8
    log to console    check message itf_l2_ps_cell_cellsetupreq
    ${req_packets}    cap.filter_packets_by_expression    filter_expression=itf_l2_ps_cell_cellsetupreq
    log to console    check structure dlSubbandBmConfig exists
    ${values}    cap.get_field_value_by_xpath    xpath=.//itf_l2_ps_cell_BfSetup.dlSubbandBmConfig.Length
    ${length} =    Get Length    ${values}
    should not be equal    ${length}    ${0}
    log to console    copy ${cp_log_name} to ${TS_CASE_LOG_PATH}
    Run keyword and ignore error    OperatingSystem.Run    command=mv ${cp_log_unzip_full_path} ${TS_CASE_LOG_PATH}
    # ***************************************check tti and spark log during traffic************************************
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    spark.start_log    ue_alias=UE_0
    sleep    5s
    log to console    ue attach
    spark ue attach    ue_alias=${ue_alias}
    spark.stop_log    ue_alias=UE_0    logname=${spark_log_dir}/sparklog/ue1_attach.xml    filter=test
    log to console    start spark ue log
    spark.start_log    ue_alias=${ue_alias}
    sleep    5s
    log to console    start tti log
    TTI Log Capture    duration=${40}
    Wait until keyword succeeds    1min    1s    Check tti Log Started Capture
    log to console    ue do dl 1500Mbps tput
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${tput[${cell_id}]['dl_tp']}
    ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    log to console    dl traffic started...
    sleep    2s
    Get TTI Log Name
    TTI Log Unzip    tti_log_name=${tti_log_name}
    log to console    stop spark ue log
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${spark_log_name}    set variable    ${spark_log_dir}/sparklog/sigspark_UE${ue_index}_${time_stamp}.xml
    Run keyword and ignore error    spark.stop_log    ue_alias=${ue_alias}    logname=${spark_log_dir}/sparklog/${spark_log_name}    filter=test
    format_spark_xml_log    file_path=${spark_log_name}
    spark.read_log    logname=${spark_log_name}
    log to console    check RRC RRCReconfiguration msg in spark ue log
    ${res}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.b-SRS    type=all
    Should be equal    ${res[-1]}    0
    log to console    copy ${spark_log_name} to ${TS_CASE_LOG_PATH}
    Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_name} ${TS_CASE_LOG_PATH}
    log to console    check tti log
    ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${tti_log_unzip_full_path}[0]    type=dlFdSchedData    parameter=beamType
    log to console    ${lines}
    Should be equal    ${lines[-1]}    SUBBAND
    ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${tti_log_unzip_full_path}[0]    type=srsSwitchMeasData
    ...    parameter=srsState    rnti=${rnti}
    log to console    ${lines}
    Should be equal    ${lines[-1]}    WBSRS
    log to console    copy ${gnb_tool_path}/gnb_logs/${tti_log_name} to ${TS_CASE_LOG_PATH}
    Run keyword and ignore error    OperatingSystem.Run    command=mv ${gnb_tool_path}/gnb_logs/${tti_log_name} ${TS_CASE_LOG_PATH}
    log to console    ue do ul 240Mbps tput
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${tput[${cell_id}]['ul_tp']}
    ...    duration=${duration_call}    dt_name=DT_ul    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    log to console    ul traffic started...
    log to console    collect tput for ue
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration_collect}    check_source=spark    ue_index=${ue_index}
    log to console    check tput for ue
    power_ue.Check Tput    direction=DL    target_throughput=${tput[${cell_id}]['dl_exp']}    ue_type=${ue_type}    log=${tput_log}
    ...    cells=${cell_id}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    power_ue.Check Tput    direction=UL    target_throughput=${tput[${cell_id}]['ul_exp']}   ue_type=${ue_type}    log=${tput_log}
    ...    cells=${cell_id}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    #***************************************check tti and spark log during stop traffic*******************************************
    log to console    start spark ue log
    spark.start_log    ue_alias=${ue_alias}
    sleep    5s
    log to console    start tti log
    TTI Log Capture    duration=${40}
    Wait until keyword succeeds    1min    1s    Check tti Log Started Capture
    sleep    5s
    log to console    stop dl traffic
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl    apn_address=${apn_address}
    ...    ue_mode=${ue_mode}    ue_index=${ue_index}
    log to console     ue0 do dl 1Mbps tput
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    log to console    stop ul traffic
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul    apn_address=${apn_address}
    ...    ue_mode=${ue_mode}    ue_index=${ue_index}
    Get TTI Log Name
    TTI Log Unzip    tti_log_name=${tti_log_name}
    log to console    stop spark ue log
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${spark_log_name}    set variable    ${spark_log_dir}/sparklog/sigspark_UE${ue_index}_${time_stamp}.xml
    Run keyword and ignore error    spark.stop_log    ue_alias=${ue_alias}    logname=${spark_log_dir}/sparklog/${spark_log_name}    filter=test
    format_spark_xml_log    file_path=${spark_log_name}
    spark.read_log    logname=${spark_log_name}
    log to console    check RRC RRCReconfiguration msg in spark ue log
    ${res}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.b-SRS    type=all
    run keyword and ignore error    Should be equal    ${res[-1]}    2
    log to console    copy ${spark_log_name} to ${TS_CASE_LOG_PATH}
    Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_name} ${TS_CASE_LOG_PATH}
    log to console    check tti log
    ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${tti_log_unzip_full_path}[0]    type=dlFdSchedData    parameter=beamType
    log to console    ${lines}
    Should not be equal    ${lines[-1]}    SUBBAND
    ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${tti_log_unzip_full_path}[0]    type=srsSwitchMeasData    parameter=srsState
    ...    rnti=${rnti}
    log to console    ${lines}
    Should be equal    ${lines[-1]}    SBSRS
    run keyword and ignore error    should contain    ${lines}    WBTOSBSRS
    log to console    copy ${gnb_tool_path}/gnb_logs/${tti_log_name} to ${TS_CASE_LOG_PATH}
    Run keyword and ignore error    OperatingSystem.Run    command=mv ${gnb_tool_path}/gnb_logs/${tti_log_name} ${TS_CASE_LOG_PATH}
    [Teardown]    Run keywords    Run keyword and ignore error    spark ue stop traffic and detach    ue_index=${0}    AND
    ...    Run keyword and ignore error    OperatingSystem.Run    command=mv ${cp_log_unzip_full_path} ${TS_CASE_LOG_PATH}    AND
    ...    Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_name} ${TS_CASE_LOG_PATH}    AND
    ...    Run keyword and ignore error    OperatingSystem.Run    command=mv ${gnb_tool_path}/gnb_logs/${tti_log_name} ${TS_CASE_LOG_PATH}

CB011116_3_Verify_Cell_Setup_And_L3call_With_2CC
    [Arguments]    ${tput}    ${cell_id}    ${config}    ${ue_type}=huawei_sigspark
    ...    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0    ${du_index}=0
    ...    ${duration_call}=${9999}    ${duration_collect}=${300}    ${target_avg_percent}=0.85    ${min_percent}=0.8
    ...    ${spark_log_dir}=/home/ute
    old log clear
    log to console    load scf of ${config}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _${config}.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}
    log to console    check cell onair
    Wait until keyword succeeds    10min    10s    verify all cells should be onair
    # ***************************************check tti and spark log during traffic***********************************
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    Change qRxLevMin by Coam    cell_id_call=${301}    cell_id_not_call=${302}
    sleep    5s
    log to console    prepare ue1
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    spark.start_log    ue_alias=UE_0
    sleep    5s
    log to console    make ue1 attach to cell 581
    spark ue attach    ue_alias=UE_0
    spark.stop_log    ue_alias=UE_0    logname=${spark_log_dir}/sparklog/ue1_attach.xml    filter=test
    format_spark_xml_log    file_path=${spark_log_dir}/sparklog/ue1_attach.xml
    Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_dir}/sparklog/ue1_attach.xml ${TS_CASE_LOG_PATH}
    log to console    ue1 do dl 1Mbps tput
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
    ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${0}
    sleep    5s
    Change qRxLevMin by Coam    cell_id_call=${302}    cell_id_not_call=${301}
    sleep    5s
    log to console    prepare ue2
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    spark.start_log    ue_alias=UE_2
    sleep    5s
    log to console    make ue2 attach to cell 582
    spark ue attach    ue_alias=UE_2
    spark.stop_log    ue_alias=UE_2    logname=${spark_log_dir}/sparklog/ue2_attach.xml    filter=test
    format_spark_xml_log    file_path=${spark_log_dir}/sparklog/ue2_attach.xml
#    run keyword if    '${config}'=='2CC_16DL_C'    run keyword    check bSRS and cSRS for 2CC_16DL_C
#    ...    spark_log_name=${spark_log_dir}/sparklog/ue2_attach.xml
    Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_dir}/sparklog/ue2_attach.xml ${TS_CASE_LOG_PATH}
    log to console    start spark log for ue1 and ue2
    spark.start_log    ue_alias=UE_0
    sleep    5s
    FOR    ${id}    IN    @{cell_id}
        ${ue_index}    set variable    ${tput[${id}]['ue_index']}
        ${dl_throughput}    set variable    ${tput[${id}]['dl_tp']}
        log to console    ue_${ue_index} do dl ${dl_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    sleep    10s
    FOR    ${id}    IN    @{cell_id}
        ${ue_index}    set variable    ${tput[${id}]['ue_index']}
        log to console    stop spark ue log for ue_${ue_index}
        ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
        ${spark_log_name}    set variable    ${spark_log_dir}/sparklog/sigspark_${time_stamp}.xml
        Run keyword and ignore error    spark.stop_log    ue_alias=UE_${ue_index}    logname=${spark_log_name}    filter=test
        format_spark_xml_log    file_path=${spark_log_name}
        spark.read_log    logname=${spark_log_name}
        log to console    check RRC RRCReconfiguration msg in spark log for ue_${ue_index}
#        ${Physical_Cell_Id}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=QualcommMessage.Content.Physical_Cell_Id
        ${bSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.b-SRS    type=all
        ${cSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.c-SRS    type=all
        run keyword and ignore error    Should be equal    ${bSRS[-1]}    0
#        ${bSRS_first}    set variable    ${bSRS[0]}
#        ${cSRS_first}    set variable    ${cSRS[0]}
#        run keyword if    '${Physical_Cell_Id}'=='${physCellId_list}[1]' and '${config}'=='2CC_16DL_C'    run keywords
#        ...    should be equal    ${bSRS_first}    1    AND    should be equal    ${cSRS_first}    59
        log to console    copy ${spark_log_name} to ${TS_CASE_LOG_PATH}
        Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_name} ${TS_CASE_LOG_PATH}
    END
    log to console    start tti log
    Capture And Decode TTitrace Log
    log to console    check tti log for ue1 and ue2
    Format and Check tti log    cells=${cell_ids}
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=ttitrace_streaming    target_dir_name=ttitrace_streaming_start_traffic
    Collect Interface Mirroring Bip Collector
    sleep    3s
    Get Bip Log Via Interface Mirroring Collector
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=l1l2bip_log    target_dir_name=l1l2bip_log_start_traffic
    FOR    ${id}    IN    @{cell_id}
        ${ue_index}    set variable    ${tput[${id}]['ue_index']}
        ${ul_throughput}    set variable    ${tput[${id}]['ul_tp']}
        log to console    ue_${ue_index} do ul ${ul_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
        ...    duration=${duration_call}    dt_name=DT_ul    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    log to console    collect tput for ue
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration_collect}    check_source=spark
    log to console    check tput for ue
    FOR    ${id}    IN    @{cell_id}
        run keyword and ignore error    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${id}
        ...    ultarget_throughput=${tput[${id}]['ul_exp']}    dltarget_throughput=${tput[${id}]['dl_exp']}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    END
    FOR    ${id}    IN    @{cell_id}
        ${ue_index}    set variable    ${tput[${id}]['ue_index']}
        log to console    stop dl traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console     ue_${ue_index} do dl 1Mbps tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console    stop ul traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    Capture And Decode TTitrace Log
    log to console    check tti log for ue1 and ue2
    Format and Check tti log    cells=${cell_ids}    option=${4}
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=ttitrace_streaming    target_dir_name=ttitrace_streaming_stop_traffic
    Collect Interface Mirroring Bip Collector
    sleep    3s
    Get Bip Log Via Interface Mirroring Collector
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=l1l2bip_log    target_dir_name=l1l2bip_log_stop_traffic
    [Teardown]    run keywords    Run keyword and ignore error    spark ue stop traffic and detach    ue_index=${0}    AND
    ...    Run keyword and ignore error    spark ue stop traffic and detach    ue_index=${2}

check bSRS and cSRS for 2CC_16DL_C
    [Arguments]    ${spark_log_name}
    format_spark_xml_log    file_path=${spark_log_name}
    spark.read_log    logname=${spark_log_name}
    ${bSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.b-SRS    type=all
    ${cSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.c-SRS    type=all
    ${bSRS_first}    set variable    ${bSRS[0]}
    ${cSRS_first}    set variable    ${cSRS[0]}
    log to console    ${bSRS_first}
    log to console    ${cSRS_first}
#    should be equal    ${bSRS_first}    1
#    should be equal    ${cSRS_first}    59

CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS
    [Arguments]    ${tput}    ${ue_indexes}    ${ue_type}=huawei_sigspark
    ...    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0    ${du_index}=0
    ...    ${duration_call}=${9999}    ${duration_collect}=${300}    ${target_avg_percent}=0.85    ${min_percent}=0.8
    ...    ${spark_log_dir}=/home/ute
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    sleep    5s
    log to console    prepare ue1
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    spark.start_log    ue_alias=UE_0
    sleep    5s
    log to console    make ue1 attach to cell 581
    spark ue attach    ue_alias=UE_0
    spark.stop_log    ue_alias=UE_0    logname=${spark_log_dir}/sparklog/ue1_attach.xml    filter=test
    ##################################################################################################
    log to console    ue1 do dl 1Mbps tput
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
    ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${0}
    sleep    5s
    ##################################################################################################
    log to console    prepare ue2
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    spark.start_log    ue_alias=UE_2
    sleep    5s
    log to console    make ue2 attach to cell 581
    spark ue attach    ue_alias=UE_2
    spark.stop_log    ue_alias=UE_2    logname=${spark_log_dir}/sparklog/ue2_attach.xml    filter=test
#    ${result}    get cSRS and bSRS from scf    cell_id=301
#    format_spark_xml_log    file_path=${spark_log_dir}/sparklog/ue1_attach.xml
#    spark.read_log    logname=${spark_log_dir}/sparklog/ue1_attach.xml
#    log to console    check RRC RRCReconfiguration msg in spark log for ue_0
#    ${bSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.b-SRS    type=all
#    ${cSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.c-SRS    type=all
#    should be true    ${bSRS}==${result[0]} or ${bSRS[0]}==${result[0]}
#    should be true    ${cSRS}==${result[1]} or ${cSRS[0]}==${result[1]}
#    ##################################################################################################
#    format_spark_xml_log    file_path=${spark_log_dir}/sparklog/ue2_attach.xml
#    spark.read_log    logname=${spark_log_dir}/sparklog/ue2_attach.xml
#    log to console    check RRC RRCReconfiguration msg in spark log for ue_2
#    ${bSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.b-SRS    type=all
#    ${cSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.c-SRS    type=all
#    should be true    ${bSRS}==${result[0]} or ${bSRS[0]}==${result[0]}
#    should be true    ${cSRS}==${result[1]} or ${cSRS[0]}==${result[1]}
#    log to console    copy ${spark_log_dir}/sparklog/ue1_attach.xml to ${TS_CASE_LOG_PATH}
#    Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_dir}/sparklog/ue1_attach.xml ${TS_CASE_LOG_PATH}
#    log to console    copy ${spark_log_dir}/sparklog/ue2_attach.xml to ${TS_CASE_LOG_PATH}
#    Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_dir}/sparklog/ue2_attach.xml ${TS_CASE_LOG_PATH}
    ${cSRS_bSRS_list}     Create List
    set test variable    ${cSRS_bSRS_list}
    run keyword and ignore error    check csbs and bsrs during attach    cell_id=${cell1_id}    ue_indexs=${ue_indexes}
    sleep    5s
    log to console    start spark log for ue1 and ue2
    spark.start_log    ue_alias=UE_0
    sleep    5s
    FOR    ${ue_index}    IN    @{ue_indexes}
        ${cell_id}    get_cell_id_by_ue_index    ue_index=${ue_index}    tput=${tput}
        ${dl_throughput}    set variable    ${tput[${cell_id}]['dl_tp']}
        log to console    ue_${ue_index} do dl ${dl_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    sleep    2s
    run keyword and ignore error    check csbs and bsrs during call    cell_id=${cell1_id}    ue_indexs=${ue_indexes}
#    FOR    ${ue_index}    IN    @{ue_indexes}
#        log to console    stop spark ue log for ue_${ue_index}
#        ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
#        ${spark_log_name}    set variable    ${spark_log_dir}/sparklog/sigspark_${time_stamp}.xml
#        Run keyword and ignore error    spark.stop_log    ue_alias=UE_${ue_index}    logname=${spark_log_name}    filter=test
#        format_spark_xml_log    file_path=${spark_log_name}
#        spark.read_log    logname=${spark_log_name}
#        log to console    check RRC RRCReconfiguration msg in spark log for ue_${ue_index}
#        ${bSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.b-SRS    type=all
#        ${cSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.c-SRS    type=all
#        ${cSRS_bSRS}    get cSRS and bSRS from table    cell_id=301
#        should be true    ${cSRS[1]}==${cSRS_bSRS[0]}
#        should be true    ${bSRS[1]}==${cSRS_bSRS[1]}
#        should be true    ${cSRS[2]}==${cSRS_bSRS[0]}
#        should be true    ${bSRS[2]}==${cSRS_bSRS[1]}
#        log to console    copy ${spark_log_name} to ${TS_CASE_LOG_PATH}
#        Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_name} ${TS_CASE_LOG_PATH}
#    END
    log to console    start tti log
    Capture And Decode TTitrace Log
    log to console    check tti log for ue1 and ue2
    Format and Check tti log    cells=${cell1_id}
    ##################################################################################################
    Collect Interface Mirroring Bip Collector
    sleep    3s
    Get Bip Log Via Interface Mirroring Collector
    bip log analyse    bip_log_path=${TS_CASE_LOG_PATH}/l1l2bip_log/l1l2bip_log.pcap
    ##################################################################################################
    FOR    ${ue_index}    IN    @{ue_indexes}
        ${cell_id}    get_cell_id_by_ue_index    ue_index=${ue_index}    tput=${tput}
        ${ul_throughput}    set variable    ${tput[${cell_id}]['ul_tp']}
        log to console    ue_${ue_index} do ul ${ul_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
        ...    duration=${duration_call}    dt_name=DT_ul    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    log to console    collect tput for ue
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration_collect}    check_source=spark
    log to console    check tput for ue
    FOR    ${id}    IN    @{cell1_id}
        run keyword and ignore error    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${id}
        ...    ultarget_throughput=${tput[${id}]['ul_exp']}    dltarget_throughput=${tput[${id}]['dl_exp']}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    END
    ##################################################################################################
    FOR    ${ue_index}    IN    @{ue_indexes}
        log to console    stop dl traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console     ue_${ue_index} do dl 1Mbps tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console    stop ul traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    ##################################################################################################
    Capture And Decode TTitrace Log
    log to console    check tti log for ue1 and ue2
    Format and Check tti log    cells=${cell1_id}    option=${4}
    ##################################################################################################
    Collect Interface Mirroring Bip Collector
    sleep    3s
    Get Bip Log Via Interface Mirroring Collector
    ##################################################################################################
    log to console   collect snapshot log and check
    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    snapshot log analyse    snapshot_log_path=${TS_CASE_LOG_PATH}
#    log to console    collect ru log and check
#    Capture RU logs    target_dir=${TS_CASE_LOG_PATH}
#    run keyword and ignore error    ru log analyse    ru_log_path=${TS_CASE_LOG_PATH}
    [Teardown]    run keywords    Run keyword and ignore error    spark ue stop traffic and detach    ue_index=${0}    AND
    ...    Run keyword and ignore error    spark ue stop traffic and detach    ue_index=${1}

check tti log during start traffic from csv
    [Arguments]    ${cell_ids}    ${file_path}
    FOR    ${cell_id}    IN    @{cell_ids}
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=dlFdSchedData
        ...    parameter=beamType    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    SUBBAND
    #    ${lines}    ${rnti}    get_lines_by_type_and_paramter_new
    #    ...    file_path=${file_path}    type=srsSwitchMeasData
    #    ...    parameter=srsSwitchMeas    rnti=${rnti}    cell_id=${cell_id}
    #    log to console    ${lines}
    #    Should be equal    ${lines[-1]}    WBSRS
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=dlFdSchedData
        ...    parameter=rtBeamFailureReason    rnti=${rnti}    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    NOFAILURE
    END
    [Return]    ${rnti}

check tti log during stop traffic from csv
    [Arguments]    ${cell_ids}    ${file_path}
    FOR    ${cell_id}    IN    @{cell_ids}
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=dlFdSchedData
        ...    parameter=beamType    cell_id=${cell_id}
        log to console    ${lines}
        Should not be equal    ${lines[-1]}    SUBBAND
    #    ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=srsSwitchMeasData
    #    ...    parameter=srsSwitchMeas    rnti=${rnti}    cell_id=${cell_id}
    #    log to console    ${lines}
    #    Should be equal    ${lines[-1]}    SBSRS
    #    run keyword and ignore error    should contain    ${lines}    WBTOSBSRS
    END

check tti log during stop traffic from csv for CA and HO
    [Arguments]    ${cell_ids}    ${file_path}
    FOR    ${cell_id}    IN    @{cell_ids}
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=dlFdSchedData
        ...    parameter=beamType    cell_id=${cell_id}
        log to console    ${lines}
        Should not be equal    ${lines[-1]}    SUBBAND
    END
    [Return]    ${rnti}

check tti log during start traffic from csv new
    [Arguments]    ${cell_ids}    ${file_path}
    FOR    ${cell_id}    IN    @{cell_ids}
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=dlFdSchedData
        ...    parameter=beamType    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    DFTNONTAPERING
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=srsSwitchMeasData
        ...    parameter=srsSwitchMeas    rnti=${rnti}    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    SBSRS
    END

check tti log during stop traffic from csv new
    [Arguments]    ${cell_ids}    ${file_path}
    FOR    ${cell_id}    IN    @{cell_ids}
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=dlFdSchedData
        ...    parameter=beamType    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    DFTNONTAPERING
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=srsSwitchMeasData
        ...    parameter=srsSwitchMeas    rnti=${rnti}    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    WBSRS
        run keyword and ignore error    should contain    ${lines}    WBTOSBSRS
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=dlFdSchedData
        ...    parameter=rtBeamFailureReason    rnti=${rnti}    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    CELLINPOWERSAVING
    END

check tti log from csv for MIMO
    [Arguments]    ${cell_ids}    ${file_path}
    FOR    ${cell_id}    IN    @{cell_ids}
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=dlFdSchedData
        ...    parameter=muStatus    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    MUPAIR
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=dlFdSchedData
        ...    parameter=beamType    rnti=${rnti}    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    DFTTAPERING
#        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=dlFdSchedData
#        ...    parameter=rtBeamFailureReason    rnti=${rnti}    cell_id=${cell_id}
#        log to console    ${lines}
#        Should be equal    ${lines[-1]}    MUPAIR
        ${lines}    ${rnti}    get_lines_by_type_and_paramter_new    file_path=${file_path}    type=dlFdSchedData
        ...    parameter=numOfLayers    rnti=${rnti}    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    RANK4
    END

spark ue attach
    [Arguments]    ${ue_alias}
    spark.power_off    ue_alias=${ue_alias}
    sleep    2s
    spark.power_off    ue_alias=${ue_alias}
    sleep    2s
    spark.power_on    ue_alias=${ue_alias}
    sleep    2s
    spark.power_on    ue_alias=${ue_alias}
    sleep    15s

spark ue stop traffic and detach
    [Arguments]    ${ue_index}    ${ue_alias}=UE_${ue_index}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    spark.detach_ue   ue_alias=${ue_alias}
    sleep    2s
    spark.detach_ue    ue_alias=${ue_alias}
    sleep    2s

spark ue stop traffic
    [Arguments]    ${ue_index}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}

spark ue stop traffic and detach with multi ue
    [Arguments]    ${ue_indexes}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA
    FOR    ${ue_index}    IN    @{ue_indexes}
        Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl
        ...    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul
        ...    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        ${ue_alias}    set variable    UE_${ue_index}
        spark.detach_ue   ue_alias=${ue_alias}
        sleep    2s
        spark.detach_ue    ue_alias=${ue_alias}
        sleep    2s
    END

old log clear
    [Arguments]    ${gnb_tool_path}=/home/ute
    log to console    clear CP log
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/*_CP.zip
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/BTS-*_CP
    log to console    clear TTI log
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/*_TTI.zip
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/BTS-*_TTI
    log to console    clear BIP log
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/*_BIP.zip
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/BTS-*_BIP
    log to console    clear spark log
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/sparklog/*

create dir for spark log
    [Arguments]    ${path}=/home/ute
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${path}/sparklog
    OperatingSystem.Run    command=cd ${path}; mkdir sparklog
    OperatingSystem.Run    command=sudo chmod -R 777 ${path}/sparklog

online change qRxLevMin
    [Arguments]    ${qRxLevMin}    ${cell_id}
    selenium login and disable screen lock
    ${old_value}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	...    filter_param=Minimum required RX level in the cell (dBm)
	@{result}    string.split string    ${old_value}
	${old_value}    set variable    ${result}[0]
	Return From Keyword If   "${qRxLevMin}"=="${old_value}"
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=Minimum required RX level in the cell (dBm)    abbr=qRxLevMin    new_value=${qRxLevMin}
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${300}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    selenium logout and close browser

Change qRxLevMin by Coam
    [Arguments]    ${cell_id_call}    ${cell_id_not_call}    ${qRxLevMin_call}=-65    ${qRxLevMin_not_call}=-22    ${connection}=GNB_OAM
    ${List_call}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_call}
    ...    parameter    qRxLevMin
    ...    value        ${qRxLevMin_call}
    ${List_not_call}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_not_call}
    ...    parameter    qRxLevMin
    ...    value        ${qRxLevMin_not_call}
    ${parameters}    Create List    ${List_call}    ${List_not_call}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    log to console    ${delta_file['updated']}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}

check tti log during start traffic from one zip
    [Arguments]    ${cell_ids}
    FOR    ${cell_id}    IN    @{cell_ids}
        ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${tti_log_unzip_full_path}[0]    type=dlFdSchedData    parameter=beamType
        ...    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    SUBBAND
        ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${tti_log_unzip_full_path}[0]    type=srsSwitchMeasData
        ...    parameter=srsState    rnti=${rnti}    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    WBSRS
    END

check tti log during start traffic from seperate zips
    FOR    ${item}    IN    @{tti_log_unzip_full_path}
        ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${item}    type=dlFdSchedData    parameter=beamType
        log to console    ${lines}
        Should be equal    ${lines[-1]}    SUBBAND
        ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${item}    type=srsSwitchMeasData    parameter=srsState
        ...    rnti=${rnti}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    WBSRS
    END

check tti log during stop traffic from one zip
    [Arguments]    ${cell_ids}
    FOR    ${cell_id}    IN    @{cell_ids}
        ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${tti_log_unzip_full_path}[0]    type=dlFdSchedData    parameter=beamType
        ...    cell_id=${cell_id}
        log to console    ${lines}
        Should not be equal    ${lines[-1]}    SUBBAND
        ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${tti_log_unzip_full_path}[0]    type=srsSwitchMeasData
        ...    parameter=srsState    rnti=${rnti}    cell_id=${cell_id}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    SBSRS
        run keyword and ignore error    should contain    ${lines}    WBTOSBSRS
    END

check tti log during stop traffic from seperate zips
    FOR    ${item}    IN    @{tti_log_unzip_full_path}
        ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${item}    type=dlFdSchedData    parameter=beamType
        log to console    ${lines}
        Should not be equal    ${lines[-1]}    SUBBAND
        ${lines}    ${rnti}    get_lines_by_type_and_paramter    file_path=${item}    type=srsSwitchMeasData    parameter=srsState
        ...    rnti=${rnti}
        log to console    ${lines}
        Should be equal    ${lines[-1]}    SBSRS
        run keyword and ignore error    should contain    ${lines}    WBTOSBSRS
    END

bip log analyse
    [Arguments]    ${bip_log_path}
    ${all_packets}    cap.load_pcap_file    pcap_file=${bip_log_path}    tshark_path=${tshark_path}
    ...    command_template=${command_template}
    ${values}    cap.get_field_value_by_name    pdml_list=${all_packets}    field_name=DlData_PdschGrantL1sw.bwvDumpGranularityInSubbands
    should be true    ${values[-1]}==8 or ${values[-1]}==16
    ${all_packets}    cap.load_pcap_file    pcap_file=${bip_log_path}    tshark_path=${tshark_path}
    ...    command_template=${command_template_2}
    ${values}    cap.get_field_value_by_name    pdml_list=${all_packets}    field_name=UlData_srsRtBfStruct_t.ceDumpGranularityInSubbands
    should be true    ${values[-1]}==16

snapshot log analyse
    [Arguments]    ${snapshot_log_path}=${TS_CASE_LOG_PATH}    ${ru_index}=1
    ${file_name}    OperatingSystem.Run  ls -al ${snapshot_log_path}|grep Snapshot_|awk '{ print $9 }'
    ${snapshot_file_path}    set variable    ${snapshot_log_path}/${file_name}
    ${RU_SN}    Get Serial Number Via Ru Index    ru_index=${ru_index}
    ${output}  OperatingSystem.Run  unzip ${snapshot_file_path} -d /home/ute/snapshot
    ${file_name}    OperatingSystem.Run  ls -al /home/ute/snapshot|grep ${RU_SN}|grep _l1a_up_trace|awk '{ print $9 }'
    ${output}  OperatingSystem.Run  mkdir /home/ute/snapshot/l1a_up_trace
    ${cmd}    set variable    sudo tar -zxvf /home/ute/snapshot/${file_name} -C /home/ute/snapshot/l1a_up_trace
    ${output}  OperatingSystem.Run  ${cmd}
    FOR    ${i}    IN RANGE    ${1}    ${5}
        ${cmd}    set variable    ls -l /home/ute/snapshot/l1a_up_trace/OtherSnapshotFiles |grep historyBufferNrUlSrsRtbfCeWindowingH${i}|wc -l
        ${output}  OperatingSystem.Run  ${cmd}
        ${nums}    Evaluate    int(${output})
        should be true    ${nums} == 1
        ${cmd}    set variable    ls -l /home/ute/snapshot/l1a_up_trace/OtherSnapshotFiles |grep historyBufferNrDlAsipArea${i}|wc -l
        ${output}  OperatingSystem.Run  ${cmd}
        ${nums}    Evaluate    int(${output})
        should be true    ${nums} == 1
    END
    [Teardown]    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/snapshot

ru log analyse
    [Arguments]    ${ru_log_path}=${TS_CASE_LOG_PATH}
    ${file_name}    OperatingSystem.Run  ls -al ${ru_log_path}|grep rfsw_log|awk '{ print $9 }'
    ${ru_file_path}    set variable    ${ru_log_path}/${file_name}
    ${output}  OperatingSystem.Run  unzip ${ru_file_path} -d /home/ute/ru
    ${output}  OperatingSystem.Run    mkdir /home/ute/ru/A011
    ${cmd}    set variable    sudo tar -zxvf /home/ute/ru/2012_trbl_logs.tgz -C /home/ute/ru/A011
    ${output}  OperatingSystem.Run  ${cmd}
    FOR    ${i}    IN RANGE    ${1}    ${5}
        ${cmd}    set variable    ls -l /home/ute/ru/A011/OtherSnapshotFiles |grep historyBufferNrUlSrsRtbfCeWindowingH${i}|wc -l
        ${output}  OperatingSystem.Run  ${cmd}
        ${nums}    Evaluate    int(${output})
        should be true    ${nums} == 1
        ${cmd}    set variable    ls -l /home/ute/ru/A011/OtherSnapshotFiles |grep historyBufferNrDlAsipArea${i}|wc -l
        ${output}  OperatingSystem.Run  ${cmd}
        ${nums}    Evaluate    int(${output})
        should be true    ${nums} == 1
    END
    [Teardown]    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/ru

get cSRS and bSRS from table
    [Arguments]    ${cell_id}
    log to console    get chBw from scf
    selenium login and disable screen lock
    ${chBw}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	...    filter_param=Channel bandwidth
    log to console    get numOfSrsSubbandInput from scf
    ${numOfSrsSubbandInput}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	...    filter_param=Number of SRS sub-bands proposed
    log to console    get cSRS and bSRS by chbw and numOfSrsSubbandInput
    ${cSRS_bSRS}    get_cSRS_bSRS_from_pointed_table    chBw=${chBw}    numOfSrsSubbandInput=${numOfSrsSubbandInput}
    [Return]    ${cSRS_bSRS}
    [Teardown]    selenium logout and close browser

Get Serial Number Via Ru Index
    [Arguments]    ${ru_index}=1
    selenium login and disable screen lock
    ${output_ru}      selenium_coam.get_ru_info    ru_index=${ru_index}
    ${serial_number}    Set Variable    ${output_ru['Serial number']}
    [Return]    ${serial_number}
    [Teardown]    selenium logout and close browser

get cSRS and bSRS from scf
    [Arguments]    ${cell_id}
    log to console    get cSRS from scf
    selenium login and disable screen lock
    ${cSRS}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	...    filter_param=SRS bandwidth configuration
    log to console    get bSRS from scf
    ${bSRS}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	...    filter_param=SRS subband configuration
	[Return]    ${bSRS}    ${cSRS}
	[Teardown]    selenium logout and close browser

#Get RU Type By RU Index Id
#    [Arguments]    ${ru_id}=${1}    ${connection}=GNB_OAM
#    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
#    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
#    ${ru_index_type_mapping}    create dictionary
#    FOR  ${ru}  IN  @{rmod_info}
#        ${ru_id_configuration}  set variable  ${ru.id.configuration}
#        ${ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(\\d+)    1
#        ${ru_type}  set variable  ${ru.productName}
#        Exit For Loop IF    '${ru_index}[0]'=='${ru_id}'
#    END
#    [Return]  ${ru_type}

load swconfig file and sign
    [Arguments]    ${flag_0x5901BD}
    Connect to Common Unit Master    alias=ASIK Master
    csn.download file    remote_path=/ffs/run/swconfig.txt    local_path=/tmp/swconfig.txt   connection=ASIK Master
    add_or_modify_flag_in_swconfig    flag_0x5901BD=${flag_0x5901BD}    swconfig_path=/tmp/swconfig.txt
    csn.Upload File    local_path=/tmp/swconfig.txt    remote_path=/ffs/run/swconfig.txt    connection=ASIK Master
    csn.execute    crasign /ffs/run/swconfig.txt    connection=ASIK Master

scf commission with cell status and unexpected fault check
    [Arguments]    ${scf_ends_with}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    ${scf_ends_with}
    COAM Commission with scf file    scf_file_path=${SCF_upload}    is_pdl_checking_needed=False
    Wait until keyword succeeds    5min    10s    verify all cells should be onair
    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}

CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_MULTI_CC
    [Arguments]    ${tput}    ${cells_all}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0
    ...    ${du_index}=0    ${duration_call}=${9999}    ${duration_collect}=${300}    ${target_avg_percent}=0.85    ${min_percent}=0.8
    ...    ${spark_log_dir}=/home/ute
    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/snapshot
    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/ru
    ${cell_ue_mapping}    get_cell_ue_mapping    tput_define=${tput}
    ${cells}    Get Dictionary Keys    ${cell_ue_mapping}
    ${cell_1}    set variable    ${cells[0]}
    ${cell1_ues}    Get From Dictionary    ${cell_ue_mapping}    ${cell_1}
    ${cell_2}    set variable    ${cells[1]}
    ${cell2_ues}    Get From Dictionary    ${cell_ue_mapping}    ${cell_2}
    ####################################################################################################################
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${cell_1}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${cell_1}    cell_id_not_call=${cell}
    END
    sleep    5s
    FOR    ${ue_index}    IN    @{cell1_ues}
        Start DL 1M traffic    ue_index=${ue_index}
        log to console    prepare ue${ue_index}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        spark.start_log    ue_alias=UE_${ue_index}
        sleep    5s
        log to console    make ue${ue_index} attach to cell ${cell_1}
        spark ue attach    ue_alias=UE_${ue_index}
        spark.stop_log    ue_alias=UE_${ue_index}    logname=${spark_log_dir}/sparklog/ue${ue_index}_attach.xml    filter=test
#        log to console    ue${ue_index} do dl 1Mbps tput
#        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
#        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
#        sleep    5s
    END
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${cell_2}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${cell_2}    cell_id_not_call=${cell}
    END
    sleep    5s
    FOR    ${ue_index}    IN    @{cell2_ues}
        Start DL 1M traffic    ue_index=${ue_index}
        log to console    prepare ue${ue_index}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        spark.start_log    ue_alias=UE_${ue_index}
        sleep    5s
        log to console    make ue${ue_index} attach to cell ${cell_2}
        spark ue attach    ue_alias=UE_${ue_index}
        spark.stop_log    ue_alias=UE_${ue_index}    logname=${spark_log_dir}/sparklog/ue${ue_index}_attach.xml    filter=test
    END
    ####################################################################################################################
    run keyword and ignore error    check csbs and bsrs during attach    cell_id=${cell_1}    ue_indexs=${cell1_ues}
    run keyword and ignore error    check csbs and bsrs during attach    cell_id=${cell_2}    ue_indexs=${cell2_ues}
    ####################################################################################################################
    sleep    5s
    FOR    ${ue_index}    IN    @{cell1_ues}
        ${dl_throughput}    set variable    ${tput[${cell_1}]['dl_tp']}
        log to console    start spark log for ue_${ue_index}
        spark.start_log    ue_alias=UE_${ue_index}
        sleep    5s
        log to console    ue_${ue_index} do dl ${dl_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        sleep    10s
        Run keyword and ignore error    spark.stop_log    ue_alias=UE_${ue_index}    logname=${spark_log_dir}/sparklog/ue${ue_index}_call.xml
        ...    filter=test
    END
    FOR    ${ue_index}    IN    @{cell2_ues}
        ${dl_throughput}    set variable    ${tput[${cell_2}]['dl_tp']}
        log to console    start spark log for ue_${ue_index}
        spark.start_log    ue_alias=UE_${ue_index}
        sleep    5s
        log to console    ue_${ue_index} do dl ${dl_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        sleep    10s
        Run keyword and ignore error    spark.stop_log    ue_alias=UE_${ue_index}    logname=${spark_log_dir}/sparklog/ue${ue_index}_call.xml
        ...    filter=test
    END
    ####################################################################################################################
    sleep    2s
    Run keyword and ignore error    check csbs and bsrs during call    cell_id=${cell_1}    ue_indexs=${cell1_ues}
    Run keyword and ignore error    check csbs and bsrs during call    cell_id=${cell_2}    ue_indexs=${cell2_ues}
    ####################################################################################################################
    log to console    start tti log
    Capture And Decode TTitrace Log
    log to console    format and check tti log
    Format and Check tti log    cells=${cells}
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=ttitrace_streaming    target_dir_name=ttitrace_streaming_start_traffic
    ####################################################################################################################
    Collect Interface Mirroring Bip Collector
    sleep    3s
    Get Bip Log Via Interface Mirroring Collector
    bip log analyse    bip_log_path=${TS_CASE_LOG_PATH}/l1l2bip_log/l1l2bip_log.pcap
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=l1l2bip_log    target_dir_name=l1l2bip_log_start_traffic
    ####################################################################################################################
    FOR    ${ue_index}    IN    @{cell1_ues}
        ${ul_throughput}    set variable    ${tput[${cell_1}]['ul_tp']}
        log to console    ue_${ue_index} do ul ${ul_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
        ...    duration=${duration_call}    dt_name=DT_ul    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    FOR    ${ue_index}    IN    @{cell2_ues}
        ${ul_throughput}    set variable    ${tput[${cell_2}]['ul_tp']}
        log to console    ue_${ue_index} do ul ${ul_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
        ...    duration=${duration_call}    dt_name=DT_ul    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    log to console    collect tput for ue
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration_collect}    check_source=spark
    log to console    check tput for ue
    FOR    ${id}    IN    @{cells}
        run keyword and ignore error    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${id}
        ...    ultarget_throughput=${tput[${id}]['ul_exp']}    dltarget_throughput=${tput[${id}]['dl_exp']}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    END
    ####################################################################################################################
    FOR    ${ue_index}    IN    @{cell1_ues}
        log to console    stop dl traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console     ue_${ue_index} do dl 1Mbps tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console    stop ul traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    FOR    ${ue_index}    IN    @{cell2_ues}
        log to console    stop dl traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console     ue_${ue_index} do dl 1Mbps tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console    stop ul traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    ####################################################################################################################
    Capture And Decode TTitrace Log
    log to console    check tti log for all ues
    Format and Check tti log    cells=${cells}    option=${4}
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=ttitrace_streaming    target_dir_name=ttitrace_streaming_stop_traffic
    ####################################################################################################################
    Collect Interface Mirroring Bip Collector
    sleep    3s
    Get Bip Log Via Interface Mirroring Collector
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=l1l2bip_log    target_dir_name=l1l2bip_log_stop_traffic
    ####################################################################################################################
    log to console   collect snapshot log and check
    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    snapshot log analyse    snapshot_log_path=${TS_CASE_LOG_PATH}
#    log to console    collect ru log and check
#    Capture RU logs    target_dir=${TS_CASE_LOG_PATH}
#    run keyword and ignore error    ru log analyse    ru_log_path=${TS_CASE_LOG_PATH}
    [Teardown]    run keywords    Run keyword and ignore error    spark ue stop traffic and detach with multi ue   ue_indexes=${cell1_ues}    AND
    ...    Run keyword and ignore error    spark ue stop traffic and detach with multi ue    ue_indexes=${cell2_ues}

check csbs and bsrs during attach
    [Arguments]    ${cell_id}    ${ue_indexs}    ${spark_log_dir}=/home/ute
    selenium login and disable screen lock
    FOR    ${ue_index}    IN    @{ue_indexs}
        log to console    get bfSubbandSize
        ${bfSubbandSize}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Beamforming sub-band size
        log to console    check framestruct type is 1070 or not
        ${is_1070}    check framestruct type    cell_id=${cell_id}
        ${cSRS}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=SRS bandwidth configuration
	    ${bSRS}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=SRS subband configuration
	    ${comb}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Comb
        ${result}    get_cSRS_and_bSRS_by_rule    bfSubbandSize=${bfSubbandSize}    is_1070=${is_1070}
        ...    csrs=${cSRS}    bsrs=${bSRS}    comb=${comb}
        format_spark_xml_log    file_path=${spark_log_dir}/sparklog/ue${ue_index}_attach.xml
        spark.read_log    logname=${spark_log_dir}/sparklog/ue${ue_index}_attach.xml
        log to console    check RRC RRCReconfiguration msg in spark log for ue_${ue_index}
        ${bSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.b-SRS    type=all
        ${cSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.c-SRS    type=all
        should be true    ${cSRS[0]}==${result[0]}
        should be true    ${bSRS[0]}==${result[1]}
        log to console    copy ${spark_log_dir}/sparklog/ue${ue_index}_attach.xml to ${TS_CASE_LOG_PATH}
        Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_dir}/sparklog/ue${ue_index}_attach.xml ${TS_CASE_LOG_PATH}
    END
    [Teardown]    selenium logout and close browser

check framestruct type
    [Arguments]    ${cell_id}
    ${frameStructureType}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	...    filter_param=Frame Structure Type
    ${ulDlDataSlotRatio}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	...    filter_param=UL to DL logical data slot ratio
	${status1}    Run Keyword And Return Status   Should Be Equal     ${frameStructureType}  semiStatic
	${status2}    Run Keyword And Return Status   Should Be Equal     ${ulDlDataSlotRatio}  3/7
	${is_1070}    Run keyword if    ${status1}==True and ${status2}==True    set variable    True
	...    ELSE    set variable    False
	[Return]    ${is_1070}

check csbs and bsrs during call old
    [Arguments]    ${cell_id}    ${ue_indexs}    ${spark_log_dir}=/home/ute
    FOR    ${ue_index}    IN    @{ue_indexs}
        log to console    stop spark ue log for ue_${ue_index}
        ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
        ${spark_log_name}    set variable    ${spark_log_dir}/sparklog/sigspark_${time_stamp}.xml
        Run keyword and ignore error    spark.stop_log    ue_alias=UE_${ue_index}    logname=${spark_log_name}    filter=test
        format_spark_xml_log    file_path=${spark_log_name}
        spark.read_log    logname=${spark_log_name}
        log to console    check RRC RRCReconfiguration msg in spark log for ue_${ue_index}
        ${bSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.b-SRS    type=all
        ${cSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.c-SRS    type=all
        ${cSRS_bSRS}    get cSRS and bSRS from table    cell_id=${cell_id}
        should be true    ${cSRS[1]}==${cSRS_bSRS[0]}
        should be true    ${bSRS[1]}==${cSRS_bSRS[1]}
        should be true    ${cSRS[2]}==${cSRS_bSRS[0]}
        should be true    ${bSRS[2]}==${cSRS_bSRS[1]}
        log to console    copy ${spark_log_name} to ${TS_CASE_LOG_PATH}
        Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_name} ${TS_CASE_LOG_PATH}
    END

check csbs and bsrs during call
    [Arguments]    ${cell_id}    ${ue_indexs}    ${spark_log_dir}=/home/ute
    selenium login and disable screen lock
    FOR    ${ue_index}    IN    @{ue_indexs}
        ${chBw}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Channel bandwidth
	    ${bfSubbandSize}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Beamforming sub-band size
	    ${nbrOfBlankedPRBsLowEdgeUL}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Number of blanked PRBs in low edge of uplink side
	    ${nbrOfBlankedPRBsHighEdgeUL}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Number of blanked PRBs in high edge of uplink side
	    ${numOfSrsSubbandInput}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Number of SRS sub-bands proposed
	    ${numOfSrsSubbandOutput}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Number of SRS sub-bands selected by system
        ${result}    get_cSRS_bSRS_and_numOfSrsSubbandOutput_during_call    chBw=${chBw}    bfSubbandSize=${bfSubbandSize}
        ...    nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL}    nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL}
        ...    numOfSrsSubbandInput=${numOfSrsSubbandInput}
        format_spark_xml_log    file_path=${spark_log_dir}/sparklog/ue${ue_index}_call.xml
        spark.read_log    logname=${spark_log_dir}/sparklog/ue${ue_index}_call.xml
        log to console    check RRC RRCReconfiguration msg in spark log for ue_${ue_index}
        ${bSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.b-SRS    type=all
        ${cSRS}    spark.get_expected_val    msg=NR RRCReconfiguration    expression=freqHopping.c-SRS    type=all
        should be true    ${numOfSrsSubbandOutput}==${result[0]}
        should be true    ${cSRS[-1]}==${result[1]}
        should be true    ${bSRS[-1]}==${result[2]}
        log to console    copy ${spark_log_dir}/sparklog/ue${ue_index}_call.xml to ${TS_CASE_LOG_PATH}
        Run keyword and ignore error    OperatingSystem.Run    command=mv ${spark_log_dir}/sparklog/ue${ue_index}_call.xml ${TS_CASE_LOG_PATH}
    END
    [Teardown]    selenium logout and close browser

modify log dir name
    [Arguments]    ${original_dir_name}    ${target_dir_name}    ${path}=${TS_CASE_LOG_PATH}
    OperatingSystem.Run    command=mv ${path}/${original_dir_name} ${path}/${target_dir_name}

Based_SB_BF_Counter_Verify
    [Arguments]    ${tput}    ${cells_all}    ${power_basic}    ${sinr_basic}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1
    ...    ${ue_mode}=NSA    ${gnb_index}=0    ${du_index}=0    ${duration_call}=${9999}
    ${cell_ue_mapping}    get_cell_ue_mapping    tput_define=${tput}
    ${cells}    Get Dictionary Keys    ${cell_ue_mapping}
    ${cell_1}    set variable    ${cells[0]}
    ${cell1_ues}    Get From Dictionary    ${cell_ue_mapping}    ${cell_1}
    ${cell_2}    set variable    ${cells[1]}
    ${cell2_ues}    Get From Dictionary    ${cell_ue_mapping}    ${cell_2}
    ####################################################################################################################
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${cell_1}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${cell_1}    cell_id_not_call=${cell}
    END
    sleep    5s
    FOR    ${ue_index}    IN    @{cell1_ues}
        Start DL 1M traffic    ue_index=${ue_index}
        log to console    prepare ue${ue_index}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        log to console    make ue${ue_index} attach to cell ${cell_1}
        spark ue attach    ue_alias=UE_${ue_index}
#        log to console    ue${ue_index} do dl 1Mbps tput
#        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
#        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
#        sleep    5s
    END
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${cell_2}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${cell_2}    cell_id_not_call=${cell}
    END
    sleep    5s
    FOR    ${ue_index}    IN    @{cell2_ues}
        Start DL 1M traffic    ue_index=${ue_index}
        log to console    prepare ue${ue_index}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        log to console    make ue${ue_index} attach to cell ${cell_2}
        spark ue attach    ue_alias=UE_${ue_index}
    END
    FOR    ${ue_index}    IN    @{cell1_ues}
        ${dl_throughput}    set variable    ${tput[${cell_1}]['dl_tp']}
        log to console    ue_${ue_index} do dl ${dl_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        sleep    5s
    END
    FOR    ${ue_index}    IN    @{cell2_ues}
        ${dl_throughput}    set variable    ${tput[${cell_2}]['dl_tp']}
        log to console    ue_${ue_index} do dl ${dl_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        sleep    5s
    END
    ####################################################################################################################
    log to console    start tti log
    Capture And Decode TTitrace Log
    log to console    check tti log for all ues
    Format and Check tti log    cells=${cells}
    ####################################################################################################################
    log to console    sleep 5mins
    sleep    5mins
    log to console    get counter info
    ${counter_traffic}    coam.get_counters_info  connection=GNB_OAM  timeout=1min
    log to console    stop traffic for each ue
    Run keyword and ignore error    spark ue stop traffic and detach with multi ue   ue_indexes=${cell1_ues}
    Run keyword and ignore error    spark ue stop traffic and detach with multi ue   ue_indexes=${cell2_ues}
    log to console    sleep 10mins
    sleep    10mins
    log to console    get counter info
    ${counter_stop_traffic}    coam.get_counters_info  connection=GNB_OAM  timeout=1min
    log to console    check counter info during traffic
    selenium login and disable screen lock
    FOR    ${cell_id}    IN    @{cells_all}
        ${counter_info_1}    set variable    ${counter_traffic}[BTS][MRBTS-${mrbtsID}][NRBTS-${nrbtsID}][NRCELL-${cell_id}][NRBF2]
        ${M55330C00017_value}    get_counter_value    counter_info=${counter_info_1}    counter_id=M55330C00017
        ${M55330C00018_value}    get_counter_value    counter_info=${counter_info_1}    counter_id=M55330C00018
        ${M55330C00042_value}    get_counter_value    counter_info=${counter_info_1}    counter_id=M55330C00042
        ${M55330C00020_value}    get_counter_value    counter_info=${counter_info_1}    counter_id=M55330C00020
        ${M55330C00021_value}    get_counter_value    counter_info=${counter_info_1}    counter_id=M55330C00021
        log to console    check value of M55330C00018 should be about 2 * value of M55330C00017
        should be true    ${M55330C00017_value}*2*0.93 < ${M55330C00018_value} < ${M55330C00017_value}*2*1.01
        ####################################################################################################################
        log to console    check value of M55330C00042 should be 0
        should be equal    ${M55330C00042_value}    ${0}
        ####################################################################################################################
        log to console    check value of M55330C00020 should be equal to maxcellprb in table3
        ${chBw}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Channel bandwidth
	    ${bfSubbandSize}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Beamforming sub-band size
	    ${nbrOfBlankedPRBsLowEdgeUL}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Number of blanked PRBs in low edge of uplink side
	    ${nbrOfBlankedPRBsHighEdgeUL}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
	    ...    filter_param=Number of blanked PRBs in high edge of uplink side
	    ${available_prb_num}    get_available_prb_num_during_counter_check    chBw=${chBw}    bfSubbandSize=${bfSubbandSize}
	    ...    nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL}    nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL}
	    run keyword and ignore error    should be equal    ${M55330C00020_value}    ${available_prb_num}
        ####################################################################################################################
        log to console    check value of M55330C00021 should be larger than expected value
        ${M55330C00021_exp_value}    Get from Dictionary    ${M55330C00021_2CC_expect}    ${cell_id}
        should be true    ${M55330C00021_exp_value}*0.95 < ${M55330C00021_value} < ${M55330C00021_exp_value}*1.01
        ####################################################################################################################
        ${counter_info_2}    set variable    ${counter_traffic}[BTS][MRBTS-${mrbtsID}][NRBTS-${nrbtsID}][NRCELL-${cell_id}][NBFC]
        log to console    check value of M55196C00010 should be equal to 300 * ue number
        ${M55196C00010_value}    get_counter_value    counter_info=${counter_info_2}    counter_id=M55196C00010
        should be equal        ${M55196C00010_value}    ${600}
        log to console    check value of M55196C00012 shoud be equal to ue number
        ${M55196C00012_value}    get_counter_value    counter_info=${counter_info_2}    counter_id=M55196C00012
        should be equal        ${M55196C00012_value}    ${2}
        ${counter_info_3}    set variable    ${counter_traffic}[BTS][MRBTS-${mrbtsID}][NRBTS-${nrbtsID}][NRCELL-${cell_id}][NSRS]
        log to console    check counter M55371C00140 to M55371C00177 during traffic
        ${counter_not_zero}    get_count_with_not_zero_value    counter_info=${counter_info_3}    counter_prefix=M55371C00
        ...    counter_start=${140}    counter_end=${178}
        ${counter_power_basic}    set variable    ${power_basic[${cell_id}]}
        ${counter_check_result}    check_counter_percentage    counter_basic=${counter_power_basic}    counter_log=${counter_not_zero}
        run keyword and ignore error    should be equal    ${counter_check_result}    ${0}
        log to console    check counter M55371C00178 to M55371C00202 during traffic
        ${counter_sinr_basic}    set variable    ${sinr_basic[${cell_id}]}
        ${counter_not_zero}    get_count_with_not_zero_value    counter_info=${counter_info_3}    counter_prefix=M55371C00
        ...    counter_start=${178}    counter_end=${203}
        ${counter_check_result}    check_counter_percentage    counter_basic=${counter_sinr_basic}    counter_log=${counter_not_zero}
        run keyword and ignore error    should be equal    ${counter_check_result}    ${0}
    END
    log to console    check counter info after traffic
    FOR    ${cell_id}    IN    @{cells_all}
        ${counter_info_1}    set variable    ${counter_stop_traffic}[BTS][MRBTS-${mrbtsID}][NRBTS-${nrbtsID}][NRCELL-${cell_id}][NRBF2]
        ${M55330C00017_value}    get_counter_value    counter_info=${counter_info_1}    counter_id=M55330C00017
        ${M55330C00018_value}    get_counter_value    counter_info=${counter_info_1}    counter_id=M55330C00018
        ${M55330C00042_value}    get_counter_value    counter_info=${counter_info_1}    counter_id=M55330C00042
        ${M55330C00020_value}    get_counter_value    counter_info=${counter_info_1}    counter_id=M55330C00020
        ${M55330C00021_value}    get_counter_value    counter_info=${counter_info_1}    counter_id=M55330C00021
        log to console    check value of M55330C00017 should be equal to 0
        should be equal    ${M55330C00017_value}    ${0}
        log to console    check value of M55330C00018 should be equal to 0
        should be equal    ${M55330C00018_value}    ${0}
        log to console    check value of M55330C00042 should be 0
        should be equal    ${M55330C00042_value}    ${0}
        log to console    check value of M55330C00020 should be equal to 0
	    should be equal    ${M55330C00020_value}    ${0}
        log to console    check value of M55330C00021 should be equal to 0
        should be equal    ${M55330C00021_value}    ${0}
        ${counter_info_2}    set variable    ${counter_stop_traffic}[BTS][MRBTS-${mrbtsID}][NRBTS-${nrbtsID}][NRCELL-${cell_id}][NBFC]
        log to console    check value of M55196C00010 should be equal to 0
        ${M55196C00010_value}    get_counter_value    counter_info=${counter_info_2}    counter_id=M55196C00010
        should be equal        ${M55196C00010_value}    ${0}
        log to console    check value of M55196C00012 shoud be equal to 0
        ${M55196C00012_value}    get_counter_value    counter_info=${counter_info_2}    counter_id=M55196C00012
        should be equal        ${M55196C00012_value}    ${0}
        ${counter_info_3}    set variable    ${counter_stop_traffic}[BTS][MRBTS-${mrbtsID}][NRBTS-${nrbtsID}][NRCELL-${cell_id}][NSRS]
        check counter M55371C00140 to M55371C00202 after stop traffic    counter_info=${counter_info_3}
    END
    # snapshot capture
    [Teardown]    run keywords    Run keyword and ignore error    spark ue stop traffic and detach with multi ue   ue_indexes=${cell1_ues}    AND
    ...    Run keyword and ignore error    spark ue stop traffic and detach with multi ue    ue_indexes=${cell2_ues}

check counter M55371C00140 to M55371C00202 after stop traffic
    [Arguments]    ${counter_info}
    FOR    ${index}    IN RANGE    ${140}    ${203}
        ${index}    convert to string    ${index}
        ${counter_id}    set variable    M55371C00${index}
        ${counter_value}    get_counter_value    counter_info=${counter_info}    counter_id=${counter_id}
        should be equal    ${counter_value}    ${0}
    END

Capture_L1_Antenna_Snapshot_Triggered_By_L2-RT
    [Arguments]    ${tput}    ${cells_all}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0
    ...    ${du_index}=0    ${duration_call}=${9999}    ${cell_call}=${302}    ${ru_index}=1
    mcs_common.Setup MCS    mcs_type=topyoung    server_ip=10.57.230.100    server_port=${28888}    vendor=TOPYOUNG    model=MCS2350A2-64B32-E6
    MCS Recovery
    ${subcell_index}    run keyword if    ${cell_call}==${302}    set variable    ${0}    ELSE
    ...    set variable    ${4}
    ${PCI}    run keyword if    ${cell_call}==${302}    set variable    ${582}    ELSE
    ...    set variable    ${584}
    log to console    step1:add flag 0x5806D9=-10 and 0x5806D8=7 in swconfig.txt
    load swconfig file and sign for snapshot trigger    flag_0x5806D9=-10    flag_0x5806D8=7
    log to console    step2:config IQ data on WEBUI
    selenium login and disable screen lock
    ${dict1}    Create Dictionary    capture_activity_timer    2
    ${ru_type}    Get RU type
    ${radio_configurations}    Create Dictionary    RMOD-${ru_index}/RMOD_R-${ru_index}(${ru_type})    ${dict1}
    ${ul_subcell_index_list}    Create List    [BBMOD_R-1(ABIP)] [PCI: ${PCI}][7-2e]NRCELL-${cell_call}: Subcell ${subcell_index}
    selenium_coam.configure_iq_capture    ul_subcell_index_list=${ul_subcell_index_list}    enable_capture_on=Event
    ...    radio_configurations=${radio_configurations}
    ...    capture_from=BBU and RU    profile=[UL_PROFILE_1][FD][Event/Blind][7-2e]PUSCH/PUCCH/SRS issues debugging
    log to console    step3:make dl traffic on one cell
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${cell_call}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${cell_call}    cell_id_not_call=${cell}
    END
    Start DL 1M traffic    ue_index=${0}
    log to console    prepare ue0
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    log to console    make ue0 attach to cell ${cell_call}
    spark ue attach    ue_alias=UE_0
    ${dl_throughput}    set variable    ${tput[${cell_call}]['dl_tp']}
    log to console    ue0 do dl ${dl_throughput} tput
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
    ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${0}
    log to console    step4:modify mcs to make traffic lower
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_phase    phase=${Phase_B1}[${index}]    input_port=${input_port}    output_port=${1}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_attenuation    attenuation=${Att_B1}[${index}]    input_port=${input_port}    output_port=${1}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE   ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_phase    phase=${Phase_B2}[${index}]    input_port=${input_port}    output_port=${2}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE   ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_attenuation    attenuation=${Att_B2}[${index}]    input_port=${input_port}    output_port=${2}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE   ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_phase    phase=${Phase_B3}[${index}]    input_port=${input_port}    output_port=${3}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE   ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_attenuation    attenuation=${Att_B3}[${index}]    input_port=${input_port}   output_port=${3}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_phase    phase=${Phase_B4}[${index}]    input_port=${input_port}    output_port=${4}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_attenuation    attenuation=${Att_B4}[${index}]    input_port=${input_port}    output_port=${4}    mcs_device=MCS_0
    END
    sleep    60s
    log to console    step5:collect snapshot, and check fcp_triggered_capture file included
    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    find fcp_triggered_capture files in snapshot log
    [Teardown]    run keywords    selenium_coam.disable_iq_capture    AND
    ...    Run keyword and ignore error    selenium logout and close browser    AND
    ...    Run keyword and ignore error    spark ue stop traffic and detach    ue_index=${0}    AND
    ...    delete flag in swconfig file and sign    AND
    ...    MCS Recovery    AND    run keyword and ignore error    mcs_common.Teardown MCS    mcs_type=topyoung

MCS Recovery
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_phase    phase=${Phase_B1_Original}[${index}]    input_port=${input_port}    output_port=${1}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_attenuation    attenuation=${Att_B1_Original}[${index}]    input_port=${input_port}    output_port=${1}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_phase    phase=${Phase_B2_Original}[${index}]    input_port=${input_port}    output_port=${2}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_attenuation    attenuation=${Att_B2_Original}[${index}]    input_port=${input_port}    output_port=${2}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_phase    phase=${Phase_B3_Original}[${index}]    input_port=${input_port}    output_port=${3}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_attenuation    attenuation=${Att_B3_Original}[${index}]    input_port=${input_port}    output_port=${3}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_phase    phase=${Phase_B4_Original}[${index}]    input_port=${input_port}    output_port=${4}    mcs_device=MCS_0
    END
    FOR    ${index}    IN RANGE    ${0}    ${64}
        ${input_port}    Evaluate  ${index}+1
        MCS.set_attenuation    attenuation=${Att_B4_Original}[${index}]    input_port=${input_port}    output_port=${4}    mcs_device=MCS_0
    END

load swconfig file and sign for snapshot trigger
    [Arguments]    ${flag_0x5806D9}    ${flag_0x5806D8}
    Connect to Common Unit Master    alias=ASIK Master
    csn.download file    remote_path=/ffs/run/swconfig.txt    local_path=/tmp/swconfig.txt   connection=ASIK Master
    add_or_modify_flag_in_swconfig_for_snapshot_trigger    flag_0x5806D9=${flag_0x5806D9}    flag_0x5806D8=${flag_0x5806D8}
    ...    swconfig_path=/tmp/swconfig.txt
    csn.Upload File    local_path=/tmp/swconfig.txt    remote_path=/ffs/run/swconfig.txt    connection=ASIK Master
    csn.execute    crasign /ffs/run/swconfig.txt    connection=ASIK Master
    sleep    5s
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    Wait until keyword succeeds    10min    5s    verify all cells should be onair

delete flag in swconfig file and sign
    log to console    delete flag 0x5806D9 and 0x5806D8=7 in swconfig.txt
    Connect to Common Unit Master    alias=ASIK Master
    csn.download file    remote_path=/ffs/run/swconfig.txt    local_path=/tmp/swconfig.txt   connection=ASIK Master
    remove_flag_in_swconfig    swconfig_path=/tmp/swconfig.txt
    csn.Upload File    local_path=/tmp/swconfig.txt    remote_path=/ffs/run/swconfig.txt    connection=ASIK Master
    csn.execute    crasign /ffs/run/swconfig.txt    connection=ASIK Master
    sleep    5s
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    Wait until keyword succeeds    10min    5s    verify all cells should be onair

find fcp_triggered_capture files in snapshot log
    [Arguments]    ${snapshot_log_path}=${TS_CASE_LOG_PATH}    ${ru_index}=1
    ${file_name}    OperatingSystem.Run  ls -al ${snapshot_log_path}|grep Snapshot_|awk '{ print $9 }'
    ${snapshot_file_path}    set variable    ${snapshot_log_path}/${file_name}
    ${RU_SN}    Get Serial Number Via Ru Index    ru_index=${ru_index}
    ${output}  OperatingSystem.Run  unzip ${snapshot_file_path} -d /home/ute/snapshot
    ${result}    OperatingSystem.Run    ls -al /home/ute/snapshot |grep ${RU_SN}|grep _fcp_triggered_capture_thor.tar.gz| wc -l
    ${count}    Convert To Integer      ${result}
    Should Be True      ${count}>0
    [Teardown]    run keyword and ignore error    OperatingSystem.Run    rm -rf /home/ute/snapshot

Interworking_With_Power_Saving_Mode_Mute
    [Arguments]    ${tput}    ${cells_all}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0
    ...    ${du_index}=0    ${duration_call}=${9999}    ${cell_call}=${302}    ${nrpgrp_index}=${0}
    ${cell_call_list}    create list    ${cell_call}
    log to console    Change qRxLevMin except cell ${cell_call}
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${cell_call}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${cell_call}    cell_id_not_call=${cell}
    END
    log to console    modify lbpsCellList, make start time current time + 10 minutes
    ${week}    ${hour}    ${minute}    get_start_time_after_a_period_time    addminute=${10}
    selenium login and disable screen lock
    SG8 common Change lbpsPeriodList On Web     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
    ...    lbpsDayOfWeek=${week}    lbpsStartTimeHour=${hour}    lbpsStartTimeMinute=${minute}
    log to console    check Energy saving state is notenergysaving for cell ${cell_call}
    check_cell_power_saving_status_equal_to_expected    cell_index=${cell_call}    expected_status=notEnergySaving
    log to console    prepare ue0
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    log to console    make ue0 attach to cell ${cell_call}
    spark ue attach    ue_alias=UE_0
    log to console    ue_0 do dl 150Mb tput
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=150MKbits/sec
    ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${0}
    sleep    5s
    log to console    collect tti, check rtBeamFailureReason is NOFAILURE, beamType is SUBBAND, and srsSwitchMeas is WBSRS
    Capture And Decode TTitrace Log
    Format and Check tti log    cells=${cell_call_list}
    log to console    check Energy saving state is reduceenergysaving for cell ${cell_call}
    Wait until keyword succeeds    20min    10s    check_cell_power_saving_status_equal_to_expected    cell_index=${cell_call}
    ...    expected_status=reducedEnergySaving
    sleep    5s
    log to console    collect tti, check rtBeamFailureReason is CELLINPOWERSAVING, beamType is DFTNONTAPERING, and srsSwitchMeas is WBSRS
    Capture And Decode TTitrace Log
    Format and Check tti log    cells=${cell_call_list}    option=${5}
    log to console    stop traffic
    Run keyword and ignore error    spark ue stop traffic    ue_index=${0}
    log to console    ue_0 do dl 150Mb tput
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=150MKbits/sec
    ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${0}
    sleep    5s
    log to console    collect tti, check beamType is DFTNONTAPERING, and srsSwitchMeas is SBSRS
    Capture And Decode TTitrace Log
    Format and Check tti log    cells=${cell_call_list}    option=${2}
    log to console    make peak call for cell ${cell_call}
    ${dl_throughput}    set variable    ${tput[${cell_call}]['dl_tp']}
    log to console    ue_0 do dl ${dl_throughput} tput
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
    ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${0}
    #log to console    sleep 2mins
    #sleep    2mins
    log to console    check Energy saving state is notenergysaving for cell ${cell_call}
    Wait until keyword succeeds    5min    10s    check_cell_power_saving_status_equal_to_expected
    ...    cell_index=${cell_call}    expected_status=notEnergySaving
    sleep    5s
    log to console    collect tti, check rtBeamFailureReason is NOFAILURE, beamType is SUBBAND, and srsSwitchMeas is WBSRS
    Capture And Decode TTitrace Log
    Format and Check tti log    cells=${cell_call_list}
    [Teardown]    Run keyword and ignore error    spark ue stop traffic and detach    ue_index=${0}

check_cell_power_saving_status_equal_to_expected
    [Arguments]      ${cell_index}    ${expected_status}    ${connection}=GNB_OAM
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_index}    connection=${connection}
    ${energysaving_status}    Set Variable    ${cell_info['energySavingState']}
    log    cell_${cell_index}: ${energysaving_status}
    should be equal    ${energysaving_status}    ${expected_status}

SG8 common Change lbpsPeriodList On Web
    [Arguments]    ${dist_name}    ${lbpsDayOfWeek}=Fri    ${lbpsDuration}=1440    ${lbpsStartTimeHour}=0    ${lbpsStartTimeMinute}=0
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=Load-based power saving day of week    abbr=lbpsDayOfWeek    new_value=${lbpsDayOfWeek}
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=Load-based power saving duration    abbr=lbpsDuration    new_value=${lbpsDuration}
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=Load-based power saving start time hour    abbr=lbpsStartTimeHour    new_value=${lbpsStartTimeHour}
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...    filter_param=Load-based power saving start time minute    abbr=lbpsStartTimeMinute    new_value=${lbpsStartTimeMinute}
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${300}

Interworking_With_DL_MU-MIMO_8DL
    [Arguments]    ${tput}    ${cells_all}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0
    ...    ${du_index}=0    ${duration_call}=${9999}    ${duration_collect}=${300}    ${target_avg_percent}=0.85    ${min_percent}=0.8
    selenium login and disable screen lock
    log to console    random select 1 cell and 2 ues to make call
    ${cell_ue_mapping}    get_cell_ue_mapping_for_1cc_2ues    tput_define=${tput}
    ${cells}    Get Dictionary Keys    ${cell_ue_mapping}
    ${cell_call}    set variable    ${cells[0]}
    ${cell_call_ues}    Get From Dictionary    ${cell_ue_mapping}    ${cell_call}
    log to console    modify parameter for selected cell
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_call}
    ...    filter_param=PRB ratio threshold    abbr=prbRatioThreshold    new_value=100
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_call}
    ...    filter_param=Spectral efficiency threshold    abbr=seThreshold    new_value=32
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${300}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${cell_call}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${cell_call}    cell_id_not_call=${cell}
    END
    sleep    2s
    FOR    ${ue_index}    IN    @{cell_call_ues}
        Start DL 1M traffic    ue_index=${ue_index}
        log to console    prepare ue${ue_index}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        log to console    make ue${ue_index} attach to cell ${cell_call}
        spark ue attach    ue_alias=UE_${ue_index}
        ${dl_throughput}    set variable    ${tput[${cell_call}]['dl_tp']}
        log to console    ue_${ue_index} do dl ${dl_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    sleep    10s
    ####################################################################################################################
    log to console    start tti log
    Capture And Decode TTitrace Log
    log to console    check tti log for all ues
    Format and Check tti log    cells=${cells}    option=${6}
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=ttitrace_streaming    target_dir_name=ttitrace_streaming_start_traffic
    ####################################################################################################################
    log to console    collect tput for ue
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration_collect}    check_source=spark
    ...    ue_alias=UE_${cell_call_ues[0]}
    log to console    check tput for ue
    run keyword and ignore error    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${cell_call}
    ...    ultarget_throughput=${tput[${cell_call}]['ul_exp']}    dltarget_throughput=${tput[${cell_call}]['dl_exp']}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    run keywords    Run keyword and ignore error    selenium logout and close browser    AND
    ...    Run keyword and ignore error    spark ue stop traffic and detach with multi ue    ue_indexes=${cell_call_ues}

Interworking_With_EIRP_Control_Functionalities
    [Arguments]    ${tput}    ${cells_all}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0
    ...    ${du_index}=0    ${duration_call}=${9999}
    selenium login and disable screen lock
    log to console    random select 1 cell to make call
    ${cell_List}    Evaluate    random.sample(${cells_all},1)    random
    ${cell_call}    set variable    ${cell_List[0]}
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${cell_call}
    ${nrCellIdentity}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_call}
	...    filter_param=NR Cell Identity
    log to console    enable eirp (set actEirpControl to true) for selected cell, and set actEirpControl to false for other cell
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_call}
    ...    filter_param=Activate EIRP control    abbr=actEirpControl    new_value=true
    FOR    ${cell}    IN    @{other_cells}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell}
        ...    filter_param=Activate EIRP control    abbr=actEirpControl    new_value=true
    END
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${300}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    log to console    get rmod that the selected cell belong to
    ${cells_info}    coam.Get Cells Info    cell_type=nr    timeout=30    connection=GNB_OAM
    ${ru_index}    get_cell_belonged_ru    cells_info=${cells_info}    cell_id=${cell_call}
    log to console    lock RU${ru_index}
    coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    connection=GNB_OAM    timeout=180
    sleep    5s
    wait until keyword succeeds    5min    5sec    RU Should Be Locked    ru_index=${ru_index}
    log to console    unlock RU${ru_index}
    coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    connection=GNB_OAM    timeout=60s
    sleep    5s
    wait until keyword succeeds    10min    5sec    RU Should Be Online    ru_index=${ru_index}
    log to console    4 UE make call under selected cell
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${cell_call}    cell_id_not_call=${cell}
    END
    sleep    5s
    ${ue_index_all}    Create List    0    1  2  3
    ${dl_throughput}    set variable    ${tput[${cell_call}]['dl_tp']}
    FOR    ${ue_index}    IN    @{ue_index_all}
        Start DL 1M traffic    ue_index=${ue_index}
        log to console    prepare ue${ue_index}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
        log to console    make ue${ue_index} attach to cell ${cell_call}
        spark ue attach    ue_alias=UE_${ue_index}
        log to console    ue${ue_index} do dl traffic
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    log to console    sleep 10mins
    sleep    10mins
    log to console    get eirpControlPowerReductionFactorList from scf
    ${detail}    selenium_coam.get_parameter_details    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_call}
	...    filter_param=List of EIRP control power reduction factor per cell segment
    ${value}    set variable    ${detail['Value']}
    log to console    ${value}
    ${eirpControlPowerReductionFactorList}     format_str_to_int_list    str=${value}
    ${counter_length}    Get Length    ${eirpControlPowerReductionFactorList}
    ${counter_list_7xx}    generate_counter_list_by_start_counter    start_counter=M55324C00701    num=${counter_length}
    ${counter_list_3xx}    generate_counter_list_by_start_counter    start_counter=M55324C00301    num=${counter_length}
    Run Keyword And Ignore Error  Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    ${btslog_path}    set variable    ${SAVE LOG DIRECTORY}/btslog
    OperatingSystem.Run    command=tar -zxvf ${btslog_path}/syslog_files.tgz -C ${btslog_path}
    sleep    2s
    ${cmd}    set variable    ls -l ${SAVE LOG DIRECTORY}/btslog|grep -v syslog_files.tgz | awk '{print $9}'
    ${syslog_names}    OperatingSystem.Run    command=${cmd}
    @{syslog_names}   Split String   ${syslog_names}   \n
    log to console    get Pmax_CC_from_logs from bts log (maxTxPowerPerCCmW)
    FOR    ${syslog_name}    IN    @{syslog_names}
        ${cmd}    set variable    cat ${btslog_path}/${syslog_name} |grep ${nrCellIdentity}|grep maxTxPowerPerCCmW
        ${output}  OperatingSystem.Run  ${cmd}
        ${len}    Get length    ${output}
        Continue For Loop If    ${len}==${0}
        ${Pmax_CC_from_logs}    get_maxTxPowerPerCCmW_from_bts_log    loginfo=${output}
        log to console    ${Pmax_CC_from_logs}
        Exit For Loop
    END
    log to console    get maxBeamGain from bts log (maxBeamGain)
    FOR    ${syslog_name}    IN    @{syslog_names}
        ${cmd}    set variable    cat ${btslog_path}/${syslog_name} |grep ',"maxBeamGain":'
        ${output}  OperatingSystem.Run  ${cmd}
        ${len}    Get length    ${output}
        Continue For Loop If    ${len}==${0}
        ${maxBeamGain}    get_maxBeamGain_from_bts_log    loginfo=${output}
        log to console    ${maxBeamGain}
        Exit For Loop
    END
    log to console    get dutyCycle(FTDC) from bts log (dutyCycle)
    FOR    ${syslog_name}    IN    @{syslog_names}
        ${cmd}    set variable    cat ${btslog_path}/${syslog_name} |grep 'dutyCycle:'
        ${output}  OperatingSystem.Run  ${cmd}
        ${len}    Get length    ${output}
        Continue For Loop If    ${len}==${0}
        ${dutyCycle}    get_dutyCycle_from_bts_log    loginfo=${output}
        log to console    ${dutyCycle}
        Exit For Loop
    END
    log to console    Convert linear values for eirpControlPowerReductionFactorList
    ${eirpControlPowerReductionFactorList_linear}    create list
    FOR    ${item}    IN    @{eirpControlPowerReductionFactorList}
        ${result}    Evaluate   pow(10, -2/${item})
        Append To List    ${eirpControlPowerReductionFactorList_linear}    ${result}
    END
    log to console    Convert linear values for Pmax_CC_from_logs
    ${Pmax_CC_from_logs_linear}    set variable    ${Pmax_CC_from_logs}
    log to console    Convert linear values for maxBeamGain
    ${maxBeamGain_linear}    Evaluate   pow(10, ${maxBeamGain}/10/10)
    log to console    Convert linear values for dutyCycle(FTDC)
    ${dutyCycle_linear}    set variable    ${dutyCycle}
    ${actual_ EIRP_target_list}    create list
    FOR    ${item}    IN    @{eirpControlPowerReductionFactorList_linear}
        ${actual_ EIRP_target}    Evaluate    ${item}*${Pmax_CC_from_logs_linear}*${maxBeamGain_linear}*${dutyCycle_linear}
        Append To List    ${actual_ EIRP_target_list}    ${actual_ EIRP_target}
    END
    log to console    get counter value for M55324C00000
    ${counter_info}    coam.get_counters_info    connection=GNB_OAM    timeout=1min
    ${counter_info}    set variable    ${counter_info}[BTS][MRBTS-${mrbtsID}][NRBTS-${nrbtsID}][NRCELL-${cell_call}][NREIRP]
    ${M55324C00000_value}    get_counter_value    counter_info=${counter_info}    counter_id=M55324C00000
    ${counter_list_3xx_value}    Create List
    ${EIRP_control_list}    Create List
    FOR    ${index}    IN RANGE    ${0}    ${counter_length}
        log to console    get counter value for M55324C007xx
        ${counter_7xx_value}    get_counter_value    counter_info=${counter_info}    counter_id=${counter_list_7xx[${index}]}
        log to console    calculate    EIRP_control
        ${EIRP_control}    set variable    ${counter_7xx_value} /${M55324C00000_value}
        Append To List    ${EIRP_control_list}    ${EIRP_control}
        log to console    get counter value for M55324C003xx
        ${counter_3xx_value}    get_counter_value    counter_info=${counter_info}    counter_id=${counter_list_3xx[${index}]}
        Append To List    ${counter_list_3xx_value}    ${counter_3xx_value}
    END
    log to console    ${actual_ EIRP_target_list}
    log to console    ${EIRP_control_list}
    log to console    ${counter_list_3xx_value}
    ${not_all_zero}    check_counter_list    counter_list=${counter_list_3xx_value}
    ${not_all_zero}    Convert to string    ${not_all_zero}
    FOR    ${index}    IN RANGE    ${0}    ${counter_length}
        run keyword if    ${actual_ EIRP_target_list[${index}]} > ${EIRP_control_list[${index}]}    should be equal    '${not_all_zero}'    'True'
    END
    [Teardown]    run keywords    Run keyword and ignore error    selenium logout and close browser    AND
    ...    Run keyword and ignore error    spark ue stop traffic and detach with multi ue    ue_indexes=${ue_index_all}

CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_2CC_2UE
    [Arguments]    ${tput}    ${cells_all}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0
    ...    ${du_index}=0    ${duration_call}=${9999}    ${duration_collect}=${300}    ${target_avg_percent}=0.98    ${min_percent}=0.85
    ...    ${spark_log_dir}=/home/ute
    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/snapshot
    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/ru
    ####################################################################################################################
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    Change qRxLevMin by Coam    cell_id_call=${302}    cell_id_not_call=${304}
    sleep    5s
    Start DL 1M traffic    ue_index=${0}
    log to console    prepare ue1
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    spark.start_log    ue_alias=UE_0
    sleep    5s
    log to console    make ue1 attach to cell 581
    spark ue attach    ue_alias=UE_0
    spark.stop_log    ue_alias=UE_0    logname=${spark_log_dir}/sparklog/ue0_attach.xml    filter=test
    format_spark_xml_log    file_path=${spark_log_dir}/sparklog/ue0_attach.xml
#    log to console    ue1 do dl 1Mbps tput
#    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
#    ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${0}
#    sleep    5s
    Change qRxLevMin by Coam    cell_id_call=${304}    cell_id_not_call=${302}
    sleep    5s
    Start DL 1M traffic    ue_index=${2}
    log to console    prepare ue2
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    spark.start_log    ue_alias=UE_2
    sleep    5s
    log to console    make ue2 attach to cell 582
    spark ue attach    ue_alias=UE_2
    spark.stop_log    ue_alias=UE_2    logname=${spark_log_dir}/sparklog/ue2_attach.xml    filter=test
    format_spark_xml_log    file_path=${spark_log_dir}/sparklog/ue2_attach.xml
    ####################################################################################################################
    ${cell1_ues}    set variable    ${tput[302]['ue_index']}
    ${cell2_ues}    set variable    ${tput[304]['ue_index']}
    run keyword and ignore error    check csbs and bsrs during attach    cell_id=${302}    ue_indexs=${cell1_ues}
    run keyword and ignore error    check csbs and bsrs during attach    cell_id=${304}    ue_indexs=${cell2_ues}
    ####################################################################################################################
    sleep    5s
    FOR    ${ue_index}    IN    @{cell1_ues}
        ${dl_throughput}    set variable    ${tput[302]['dl_tp']}
        log to console    start spark log for ue_${ue_index}
        spark.start_log    ue_alias=UE_${ue_index}
        sleep    5s
        log to console    ue_${ue_index} do dl ${dl_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        sleep    10s
        Run keyword and ignore error    spark.stop_log    ue_alias=UE_${ue_index}    logname=${spark_log_dir}/sparklog/ue${ue_index}_call.xml
        ...    filter=test
    END
    FOR    ${ue_index}    IN    @{cell2_ues}
        ${dl_throughput}    set variable    ${tput[304]['dl_tp']}
        log to console    start spark log for ue_${ue_index}
        spark.start_log    ue_alias=UE_${ue_index}
        sleep    5s
        log to console    ue_${ue_index} do dl ${dl_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        sleep    10s
        Run keyword and ignore error    spark.stop_log    ue_alias=UE_${ue_index}    logname=${spark_log_dir}/sparklog/ue${ue_index}_call.xml
        ...    filter=test
    END
    ####################################################################################################################
    sleep    2s
    Run keyword and ignore error    check csbs and bsrs during call    cell_id=${302}    ue_indexs=${cell1_ues}
    Run keyword and ignore error    check csbs and bsrs during call    cell_id=${304}    ue_indexs=${cell2_ues}
    ####################################################################################################################
    log to console    start tti log
    Capture And Decode TTitrace Log
    log to console    check tti log for all ues
    Format and Check tti log    cells=${cells_all}
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=ttitrace_streaming    target_dir_name=ttitrace_streaming_start_traffic
    ####################################################################################################################
    Collect Interface Mirroring Bip Collector
    sleep    3s
    Get Bip Log Via Interface Mirroring Collector
    bip log analyse    bip_log_path=${TS_CASE_LOG_PATH}/l1l2bip_log/l1l2bip_log.pcap
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=l1l2bip_log    target_dir_name=l1l2bip_log_start_traffic
    ####################################################################################################################
    FOR    ${ue_index}    IN    @{cell1_ues}
        ${ul_throughput}    set variable    ${tput[302]['ul_tp']}
        log to console    ue_${ue_index} do ul ${ul_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
        ...    duration=${duration_call}    dt_name=DT_ul    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    FOR    ${ue_index}    IN    @{cell2_ues}
        ${ul_throughput}    set variable    ${tput[304]['ul_tp']}
        log to console    ue_${ue_index} do ul ${ul_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
        ...    duration=${duration_call}    dt_name=DT_ul    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    log to console    collect tput for ue
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration_collect}    check_source=spark
    log to console    check tput for ue
    FOR    ${id}    IN    @{cells_all}
        run keyword and ignore error    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${id}
        ...    ultarget_throughput=${tput[${id}]['ul_exp']}    dltarget_throughput=${tput[${id}]['dl_exp']}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    END
    ####################################################################################################################
    FOR    ${ue_index}    IN    @{cell1_ues}
        log to console    stop dl traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console     ue_${ue_index} do dl 1Mbps tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console    stop ul traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    FOR    ${ue_index}    IN    @{cell2_ues}
        log to console    stop dl traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console     ue_${ue_index} do dl 1Mbps tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console    stop ul traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    ####################################################################################################################
    Capture And Decode TTitrace Log
    log to console    check tti log for all ues
    Format and Check tti log    cells=${cells_all}    option=${4}
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=ttitrace_streaming    target_dir_name=ttitrace_streaming_stop_traffic
    ####################################################################################################################
    Collect Interface Mirroring Bip Collector
    sleep    3s
    Get Bip Log Via Interface Mirroring Collector
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=l1l2bip_log    target_dir_name=l1l2bip_log_stop_traffic
    ####################################################################################################################
    log to console   collect snapshot log and check
    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    snapshot log analyse    snapshot_log_path=${TS_CASE_LOG_PATH}
#    log to console    collect ru log and check
#    Capture RU logs    target_dir=${TS_CASE_LOG_PATH}
#    run keyword and ignore error    ru log analyse    ru_log_path=${TS_CASE_LOG_PATH}
    [Teardown]    run keywords    Run keyword and ignore error    spark ue stop traffic and detach with multi ue   ue_indexes=${cell1_ues}    AND
    ...    Run keyword and ignore error    spark ue stop traffic and detach with multi ue    ue_indexes=${cell2_ues}

Start DL 1M traffic
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=9999
    ...            ${interval}=1    ${traffic}=1M    ${buffer_size}=1400B
    ...            ${process_num}=${1}    ${ue_ips}=${spark_ue_ips}
    log to console    get ue ip
    ${UE_IP}    set variable    ${ue_ips[${ue_index}]}
    log to console    login appserver
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l ${buffer_size} -T 64&
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} udp dl iperf start....
    sleep    5s

Interworking_With_CA
    [Arguments]    ${tput}    ${cells_all}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0
    ...    ${du_index}=0    ${duration_call}=${9999}    ${duration_collect}=${300}    ${target_avg_percent}=0.85    ${min_percent}=0.8
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${301}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${301}    cell_id_not_call=${cell}
    END
    sleep    2s
    Start DL 1M traffic    ue_index=${0}
    log to console    prepare ue0
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    log to console    make ue0 attach to cell 301
    spark ue attach    ue_alias=UE_${0}
    Change qRxLevMin by Coam    cell_id_call=${302}    cell_id_not_call=${303}
    sleep    2s
    log to console    make dl traffic
    ${dl_tp_301}    set variable    ${tput[${301}]['dl_tp']}
    ${dl_tp_302}    set variable    ${tput[${302}]['dl_tp']}
    ${ul_tp_301}    set variable    ${tput[${301}]['ul_tp']}
    ${ul_tp_302}    set variable    ${tput[${302}]['ul_tp']}
    ${dl_throughput}    get tput for 2cc together    tput1=${dl_tp_301}    tput2=${dl_tp_302}
    ${ul_throughput}    get tput for 2cc together    tput1=${ul_tp_301}    tput2=${ul_tp_302}
    ${dl_exp_301}    set variable    ${tput[${301}]['dl_exp']}
    ${dl_exp_302}    set variable    ${tput[${302}]['dl_exp']}
    ${ul_exp_301}    set variable    ${tput[${301}]['ul_exp']}
    ${ul_exp_302}    set variable    ${tput[${302}]['ul_exp']}
    ${dl_exp}    get tput for 2cc together    tput1=${dl_exp_301}    tput2=${dl_exp_302}
    ${ul_exp}    get tput for 2cc together    tput1=${ul_exp_301}    tput2=${ul_exp_302}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
    ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
    ...    duration=${duration_call}    dt_name=DT_ul    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${0}
    sleep    10s
    log to console    collect tput for ue
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration_collect}    check_source=spark
    log to console    check tput for ue
    run keyword and ignore error    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${301}
        ...    ultarget_throughput=${ul_exp}    dltarget_throughput=${dl_exp}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    start tti log
    Capture And Decode TTitrace Log
    log to console    check tti log
    Format and Check tti log    cells=${cell1_id}
    Format and Check tti log    cells=${cell2_id}    option=${7}
    [Teardown]    Run keyword and ignore error    spark ue stop traffic and detach    ue_index=${0}

Interworking_With_11117_HO
    [Arguments]    ${tput}    ${cells_all}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0
    ...    ${du_index}=0    ${duration_call}=${9999}    ${duration_collect}=${300}    ${target_avg_percent}=0.85    ${min_percent}=0.8
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${301}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${301}    cell_id_not_call=${cell}
    END
    sleep    2s
    Start DL 1M traffic    ue_index=${0}
    log to console    prepare ue0
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    log to console    make ue0 attach to cell 301
    spark ue attach    ue_alias=UE_${0}
    Change qRxLevMin by Coam    cell_id_call=${302}    cell_id_not_call=${303}
    sleep    2s
    log to console    make dl traffic
    ${dl_tp_301}    set variable    ${tput[${301}]['dl_tp']}
    ${dl_tp_302}    set variable    ${tput[${302}]['dl_tp']}
    ${ul_tp_301}    set variable    ${tput[${301}]['ul_tp']}
    ${ul_tp_302}    set variable    ${tput[${302}]['ul_tp']}
    ${dl_throughput}    get tput for 2cc together    tput1=${dl_tp_301}    tput2=${dl_tp_302}
    ${ul_throughput}    get tput for 2cc together    tput1=${ul_tp_301}    tput2=${ul_tp_302}
    ${dl_exp_301}    set variable    ${tput[${301}]['dl_exp']}
    ${dl_exp_302}    set variable    ${tput[${302}]['dl_exp']}
    ${ul_exp_301}    set variable    ${tput[${301}]['ul_exp']}
    ${ul_exp_302}    set variable    ${tput[${302}]['ul_exp']}
    ${dl_exp}    get tput for 2cc together    tput1=${dl_exp_301}    tput2=${dl_exp_302}
    ${ul_exp}    get tput for 2cc together    tput1=${ul_exp_301}    tput2=${ul_exp_302}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
    ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
    ...    duration=${duration_call}    dt_name=DT_ul    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${0}
    sleep    10s
    log to console    collect tput for ue
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration_collect}    check_source=spark
    log to console    check tput for ue
    run keyword and ignore error    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${301}
        ...    ultarget_throughput=${ul_exp}    dltarget_throughput=${dl_exp}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    start tti log
    Capture And Decode TTitrace Log    format_tti_log=True
    log to console    check tti log
    ${rnti_301}    check tti log during start traffic from csv    cell_ids=${cell1_id}
    ...    file_path=${TS_CASE_LOG_PATH}/ttitrace_streaming/l2stream3_ttitrace/format_output_dl.csv
    ${rnti_302}    check tti log during stop traffic from csv for CA and HO    cell_ids=${cell2_id}
    ...    file_path=${TS_CASE_LOG_PATH}/ttitrace_streaming/l2stream3_ttitrace/format_output_dl.csv
    ${List_call}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${303}
    ...    parameter    qRxLevMin
    ...    value        ${-65}
    ${parameters}    Create List    ${List_not_call}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=GNB_OAM
    log to console    ${delta_file['updated']}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=GNB_OAM
    log to console    lock cell 301
    coam.lock    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${301}    connection=GNB_OAM    timeout=180
    sleep    5s
    ${dl_exp_303}    set variable    ${tput[${303}]['dl_exp']}
    ${ul_exp_303}    set variable    ${tput[${303}]['ul_exp']}
    log to console    collect tput for ue
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration_collect}    check_source=spark
    log to console    check tput for ue
    run keyword and ignore error    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${303}
        ...    ultarget_throughput=${ul_exp_303}    dltarget_throughput=${dl_exp_303}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    start tti log
    Capture And Decode TTitrace Log    format_tti_log=True
    log to console    check tti log
    ${rnti_303}    check tti log during start traffic from csv    cell_ids=${cell3_id}
    ...    file_path=${TS_CASE_LOG_PATH}/ttitrace_streaming/l2stream3_ttitrace/format_output_dl.csv
    should be equal    ${rnti_301}     ${rnti_302}
    should be equal    ${rnti_301}     ${rnti_303}
    [Teardown]    run keywords    run keyword and ignore error    coam.unlock    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${301}
    ...    connection=GNB_OAM    timeout=180    AND
    ...    Run keyword and ignore error    spark ue stop traffic and detach    ue_index=${0}

Format and Check tti log
    [Arguments]    ${cells}    ${option}=${1}
    ${tti_log_path}    set variable    ${TS_CASE_LOG_PATH}/ttitrace_streaming/l2stream3_ttitrace/
    ${output}    OperatingSystem.Run    ls -al ${tti_log_path}|grep tcpdump_ttitrace_dl|awk '{print $9}'
    @{files}    Split String    string=${output}    separator=\n
    FOR    ${item}    IN    @{files}
        ${file_name_formatted}    String.Replace string    ${item}    tcpdump_ttitrace    format_output
        TTI_logs_Capture.Format Tti In Stream Mode    ${tti_log_path}/${item}    ${tti_log_path}/${file_name_formatted}
        IF    ${option}==1
            check tti log during start traffic from csv    cell_ids=${cells}    file_path=${tti_log_path}/${file_name_formatted}
        ELSE IF    ${option}==2
            check tti log during start traffic from csv new    cell_ids=${cells}    file_path=${tti_log_path}/${file_name_formatted}
        ELSE IF    ${option}==3
            check tti log during stop traffic from csv for CA and HO    cell_ids=${cells}    file_path=${tti_log_path}/${file_name_formatted}
        ELSE IF    ${option}==4
            check tti log during stop traffic from csv    cell_ids=${cells}    file_path=${tti_log_path}/${file_name_formatted}
        ELSE IF    ${option}==5
            check tti log during stop traffic from csv new    cell_ids=${cells}    file_path=${tti_log_path}/${file_name_formatted}
        ELSE IF    ${option}==6
            check tti log from csv for MIMO    cell_ids=${cells}    file_path=${tti_log_path}/${file_name_formatted}
        ELSE IF    ${option}==7
            check tti log during stop traffic from csv for CA and HO    cell_ids=${cells}    file_path=${tti_log_path}/${file_name_formatted}
        END
    END

CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_1CC_1UE
    [Arguments]    ${tput}    ${cells_all}    ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1    ${ue_mode}=NSA    ${gnb_index}=0
    ...    ${du_index}=0    ${duration_call}=${9999}    ${duration_collect}=${300}    ${target_avg_percent}=0.85    ${min_percent}=0.8
    ...    ${spark_log_dir}=/home/ute
    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/snapshot
    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/ru
    ####################################################################################################################
    log to console    random select 1 cell to make call
    ${cell_List}    Evaluate    random.sample(${cells_all},1)    random
    ${cell_call}    set variable    ${cell_List[0]}
    ${cell_call_list}    create list    ${cell_call}
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${cell_call}
    ${ue_call_list}    create list    ${0}
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${cell_call}    cell_id_not_call=${cell}
    END
    sleep    5s
    Start DL 1M traffic    ue_index=${0}
    log to console    prepare ue1
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    spark.start_log    ue_alias=UE_0
    sleep    5s
    log to console    make ue1 attach to cell ${cell_call}
    spark ue attach    ue_alias=UE_0
    spark.stop_log    ue_alias=UE_0    logname=${spark_log_dir}/sparklog/ue0_attach.xml    filter=test
    format_spark_xml_log    file_path=${spark_log_dir}/sparklog/ue0_attach.xml
    ####################################################################################################################
    run keyword and ignore error    check csbs and bsrs during attach    cell_id=${cell_call}    ue_indexs=${ue_call_list}
    ####################################################################################################################
    sleep    5s
    FOR    ${ue_index}    IN    @{ue_call_list}
        ${dl_throughput}    set variable    ${tput[${cell_call}]['dl_tp']}
        log to console    start spark log for ue_${ue_index}
        spark.start_log    ue_alias=UE_${ue_index}
        sleep    5s
        log to console    ue_${ue_index} do dl ${dl_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        sleep    10s
        Run keyword and ignore error    spark.stop_log    ue_alias=UE_${ue_index}    logname=${spark_log_dir}/sparklog/ue${ue_index}_call.xml
        ...    filter=test
    END
    ####################################################################################################################
    sleep    2s
    Run keyword and ignore error    check csbs and bsrs during call    cell_id=${cell_call}    ue_indexs=${ue_call_list}
    ####################################################################################################################
    log to console    start tti log
    Capture And Decode TTitrace Log
    log to console    check tti log for all ues
    Format and Check tti log    cells=${cell_call_list}
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=ttitrace_streaming    target_dir_name=ttitrace_streaming_start_traffic
    ####################################################################################################################
    Collect Interface Mirroring Bip Collector
    sleep    3s
    Get Bip Log Via Interface Mirroring Collector
    run keyword and ignore error    bip log analyse    bip_log_path=${TS_CASE_LOG_PATH}/l1l2bip_log/l1l2bip_log.pcap
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=l1l2bip_log    target_dir_name=l1l2bip_log_start_traffic
    ####################################################################################################################
    FOR    ${ue_index}    IN    @{ue_call_list}
        ${ul_throughput}    set variable    ${tput[${cell_call}]['ul_tp']}
        log to console    ue_${ue_index} do ul ${ul_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
        ...    duration=${duration_call}    dt_name=DT_ul    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    log to console    collect tput for ue
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration_collect}    check_source=spark
    log to console    check tput for ue
    FOR    ${id}    IN    @{cell_call_list}
        power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${id}
        ...    ultarget_throughput=${tput[${id}]['ul_exp']}    dltarget_throughput=${tput[${id}]['dl_exp']}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    END
    ####################################################################################################################
    FOR    ${ue_index}    IN    @{ue_call_list}
        log to console    stop dl traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console     ue_${ue_index} do dl 1Mbps tput
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1MKbits/sec
        ...    duration=${duration_call}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}    ue_index=${ue_index}
        log to console    stop ul traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    dt_name=DT_ul    apn_address=${apn_address}
        ...    ue_mode=${ue_mode}    ue_index=${ue_index}
    END
    ####################################################################################################################
    Capture And Decode TTitrace Log
    log to console    check tti log for all ues
    Format and Check tti log    cells=${cell_call_list}    option=${4}
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=ttitrace_streaming    target_dir_name=ttitrace_streaming_stop_traffic
    ####################################################################################################################
    Collect Interface Mirroring Bip Collector
    sleep    3s
    Get Bip Log Via Interface Mirroring Collector
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=l1l2bip_log    target_dir_name=l1l2bip_log_stop_traffic
    ####################################################################################################################
    log to console   collect snapshot log and check
    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    [Teardown]    Run keyword and ignore error    spark ue stop traffic and detach with multi ue   ue_indexes=${ue_call_list}

CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_1CC_1UE_Q
    [Arguments]    ${tput}    ${cells_all}    ${ue_index}=${0}    ${gnb_index}=0
    ...    ${du_index}=0    ${duration_call}=${9999}    ${duration_collect}=${300}    ${target_avg_percent}=0.85    ${min_percent}=0.8
    ...    ${protocol}=udp    ${check_source}=Aasyslog    ${process_num_ul}=1    ${buffer_size}=1400B    ${ui_version}=default
    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/snapshot
    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/ru
    ####################################################################################################################
    ${process_num_dl}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    log to console    random select 1 cell to make call
    ${cell_List}    Evaluate    random.sample(${cells_all},1)    random
    ${cell_call}    set variable    ${cell_List[0]}
    ${cell_call_list}    create list    ${cell_call}
    ${other_cells}  Get Other Ids    id_list=${cells_all}    given_id=${cell_call}
    ${ue_call_list}    create list    ${ue_index}
    prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    FOR    ${cell}    IN    @{other_cells}
         Change qRxLevMin by Coam    cell_id_call=${cell_call}    cell_id_not_call=${cell}
    END
    log to console    prepare ue1
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    sleep    5s
    log to console    make ue1 attach to cell ${cell_call}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}    timeout=900
    FOR    ${ue_index}    IN    @{ue_call_list}
        ${dl_throughput}    set variable    ${tput[${cell_call}]['dl_tp']}
        sleep    5s
        log to console    ue_${ue_index} do dl ${dl_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}
        ...    duration=${duration_call}    protocol=${protocol}    process_num=${process_num_dl}
        sleep    10s
    END
    log to console    start tti log
    Capture And Decode TTitrace Log
    log to console    check tti log for all ues
    Format and Check tti log    cells=${cell_call_list}
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=ttitrace_streaming    target_dir_name=ttitrace_streaming_start_traffic
    ####################################################################################################################
#    Collect Interface Mirroring Bip Collector
#    sleep    3s
#    Get Bip Log Via Interface Mirroring Collector
#    run keyword and ignore error    bip log analyse    bip_log_path=${TS_CASE_LOG_PATH}/l1l2bip_log/l1l2bip_log.pcap
#    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=l1l2bip_log    target_dir_name=l1l2bip_log_start_traffic
    ####################################################################################################################
    FOR    ${ue_index}    IN    @{ue_call_list}
        ${ul_throughput}    set variable    ${tput[${cell_call}]['ul_tp']}
        log to console    ue_${ue_index} do ul ${ul_throughput} tput
        power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}
        ...    duration=${duration_call}    protocol=${protocol}    iperf_type=${iperf_type}
        ...    data_amount=2M    process_num=${process_num_ul}    buffer_size=${buffer_size}
    END
    log to console    collect tput for ue
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration_collect}    check_source=${check_source}
    log to console    check tput for ue
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=GNB_OAM
    FOR    ${id}    IN    @{cell_call_list}
        ${cell_Identity}    Convert To String    ${cell_mapping[${id}]['nrCellIdentity']}
        ${cell_Identity}    Create List    ${cell_Identity}
        run keyword and ignore error    power_ue.Check Bi Tput    ue_type=nokia_fastmile    log=${tput_log}    cells=${cell_Identity}
        ...    ultarget_throughput=${tput[${id}]['ul_exp']}    dltarget_throughput=${tput[${id}]['dl_exp']}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    END
    ####################################################################################################################
    FOR    ${ue_index}    IN    @{ue_call_list}
        log to console    stop dl traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    protocol=${protocol}
        log to console     ue_${ue_index} do dl 1Mbps tput
        power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=1MKbits/sec
        ...    duration=${duration_call}    protocol=${protocol}    process_num=${process_num_dl}
        log to console    stop ul traffic for ue_${ue_index}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
        ...    iperf_type=${iperf_type}    protocol=${protocol}
    END
    ####################################################################################################################
    Capture And Decode TTitrace Log
    log to console    check tti log for all ues
    Format and Check tti log    cells=${cell_call_list}    option=${4}
    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=ttitrace_streaming    target_dir_name=ttitrace_streaming_stop_traffic
    ####################################################################################################################
#    Collect Interface Mirroring Bip Collector
#    sleep    3s
#    Get Bip Log Via Interface Mirroring Collector
#    modify log dir name    path=${TS_CASE_LOG_PATH}    original_dir_name=l1l2bip_log    target_dir_name=l1l2bip_log_stop_traffic
    ####################################################################################################################
    log to console   collect snapshot log and check
    Save Coam Snapshot    target_dir=${TS_CASE_LOG_PATH}
    [Teardown]    Run keyword and ignore error    traffic_stop_and_detach_ue   ue_indexes=${ue_call_list}
