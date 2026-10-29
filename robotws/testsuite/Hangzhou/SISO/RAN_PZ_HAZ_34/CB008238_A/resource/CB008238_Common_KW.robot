*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
Resource    ttitrace_StreamingMode.robot
Library    taf.rfrl.common_resources.python.SWConfig      WITH NAME   swconf
Library      ../lib/CB008238_TTI_Trace_Analysis.py


*** Variables ***
${ue_index}    0
${ui_version}    S30UI3.1.1
${log_capture_time}    10s
${ue_type}    huawei
${connection}    GNB_OAM

*** Keywords ***
Start L3Call and DL small packet
    [Arguments]    ${throughput}=10K    ${ue_index}=0   ${buffer_size}=1400B   ${duration}=1200   ${cell_index}=1
    ...   ${timeout}=900
    Log to console    Start L3Call and DL small packet: ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    #power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}   timeout=${timeout}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${throughput}
    ...    protocol=udp    duration=${duration}    ue_index=${ue_index}    buffer_size=${buffer_size}
    ${cell_list}   Create List   ${1}
    ${ue_index_list}   Create List   ${${ue_index}}
    ${ue_and_cell}   Create Dictionary   ${${ue_index}}   ${${cell_index}}
    ue.UE Verify Peak Throughput   ue_index_list=${ue_index_list}   ue_and_cell=${ue_and_cell}
    ...   dl_exp=${5}   ul_exp=${0}   interval=10s   duration=${30}
    ...   actual_rate=0.1   du_index=0   gnb_ssl_connection=${connection}
    ...   is_need_to_capture_log=${False}   cell_and_peak_info=None
    ...   target_avg_percent=${0.001}   min_percent=${0.0}
#    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M
#    ...    protocol=udp    duration=600    ue_index=${ue_index}
Stop L3Call and DL Traffic
    [Arguments]    ${ue_index}=0
    Log to console    Stop L3Call and DL Traffic ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

Get highestClassPriority and numOfPrb from tti log
    Log to console    Get highestClassPriority and numOfPrb from tti log
    Convert TTI trace from pcap to excelCsv         ${tti_trace}  output_file_path=${TS_CASE_LOG_PATH}/sample_ttitrace
    ...   options=-d dl
    set test variable    ${local_csv_file_path}   ${TS_CASE_LOG_PATH}/sample_ttitrace.dl.csv
    ${avg_numOfPrb}    CB008238_get_dl_average_numOfPrb    ${local_csv_file_path}
    ${highestClassPriority17}    CB008238_check_if_highestClassPriority17_in_dlPreSchedData    ${local_csv_file_path}
    set test variable    ${avg_numOfPrb}
    set test variable    ${highestClassPriority17}

Check highestClassPriority and numOfPrb when CB008238 on for NSA
    Log to console    Check highestClassPriority and numOfPrb when CB008238 on for NSA
    Get highestClassPriority and numOfPrb from tti log
    should be true     ${avg_numOfPrb} < 64
    # should be true    ${highestClassPriority17}

Check highestClassPriority and numOfPrb when CB008238 off for NSA
    Log to console    Check highestClassPriority and numOfPrb when CB008238 off for NSA
    Get highestClassPriority and numOfPrb from tti log
    should be true     ${avg_numOfPrb} < 64
    # should be true    ${highestClassPriority17} == False

Check highestClassPriority and numOfPrb when CB008238 on for SA
    Log to console    Check highestClassPriority and numOfPrb when CB008238 on for SA
    Get highestClassPriority and numOfPrb from tti log
    should be true     ${avg_numOfPrb} >= 64
    # should be true    ${highestClassPriority17}

Check highestClassPriority and numOfPrb when CB008238 off for SA
    Log to console    Check highestClassPriority and numOfPrb when CB008238 off for SA
    Get highestClassPriority and numOfPrb from tti log
    should be true     ${avg_numOfPrb} < 64
    # should be true    ${highestClassPriority17} == False

Modify actDtxOptimizedScheduler Parameter
    [Arguments]    ${actDtxOptimizedScheduler}=true    ${dtxMaxRetentionDelay}=10    ${dtxPrbThreshold}=80
    ...    ${dtxDelaySinceLastScheduling}=0
    Log to console    Modify actDtxOptimizedScheduler Parameter
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate micro DTX optimized scheduler
    ...    abbr=actDtxOptimizedScheduler
    ${currect_dtxPrbThreshold}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=PRB threshold for micro DTX optimized scheduler
    ...    abbr=dtxPrbThreshold
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Activate micro DTX optimized scheduler  p_name=actDtxOptimizedScheduler  value=${actDtxOptimizedScheduler}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Delay threshold since last scheduling for micro DTX optimized scheduler  p_name=dtxDelaySinceLastScheduling
    ...  value=${dtxDelaySinceLastScheduling}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Maximum retention delay for micro DTX optimized scheduler  p_name=dtxMaxRetentionDelay  value=${dtxMaxRetentionDelay}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=PRB threshold for micro DTX optimized scheduler  p_name=dtxPrbThreshold  value=${dtxPrbThreshold}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${actDtxOptimizedScheduler}' or '${currect_dtxPrbThreshold}'!='${dtxPrbThreshold} (%)'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Delete temp csv tti file on gnb
    [Arguments]    ${hw_slot}=1
    Create default connection    hw_slot=${hw_slot}
    ${connection_for_abil}    	Set Variable    ${ABIL_ALIAS}
    ${output_cmd}    Run Keyword And Ignore Error    csn.execute    command=ls /tmp/*.csv;rm /tmp/*.csv
    ...    connection=${connection_for_abil}    timeout=60s
    Run keyword and ignore error    csn.disconnect    connection=${connection_for_abil}

Modify miNrCellUtilization Parameter
    [Arguments]    ${miNrCellUtilization}=15min
    Log to console    Modify miNrCellUtilization Parameter
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    ...    filter_param=NR Cell Utilization
    ...    abbr=miNrCellUtilization
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    ...    filter_param=NR Cell Utilization  p_name=miNrCellUtilization
    ...    value=${miNrCellUtilization}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${miNrCellUtilization}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Start Ping
    [Arguments]    ${ue_ip}=${UE_IP}    ${count}=10   ${packet_size}=32    ${appserver_alias}=EPCAPP
    ssh.Send Command
    ...    command=ping ${ue_ip} -c ${count} -s ${packet_size}\n
    ...    connection=${appserver_alias}
    ${ping_result}=     ssh.Read Output
                                ...    connection=${appserver_alias}
#    ${ping_result}=     ssh.Read Output Until
#                                ...    match=[cmw_sg5@cmw_sg5 ~]$${SPACE}
#                                ...    timeout=30
#                                ...    connection=${appserver_alias}
    [Return]    ${ping_result}

Check Ping Latency
    [Arguments]    ${output}=${output}    ${latency_target}=${45}
    ${latency_list}    Evaluate    re.findall("time=([\\d]*[\\.][\\d]*)", '''${output}''', re.M)    re
    Log to console    latency list: ${latency_list}
    ${len}    Evaluate    len(${latency_list})
    ${sum}    set variable    ${0}
    FOR    ${i}    IN    @{latency_list}
        ${sum}    Evaluate    ${sum}+float(${i})
    END
    ${avg}    Evaluate    ${sum}/${len}
    Should be true    ${avg}<${latency_target}

Modify pucchModeSelect Parameter
    [Arguments]    ${pucchModeSelect}=longPucch
    Log to console    Modify pucchModeSelect Parameter
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=PUCCH mode selection
    ...    abbr=pucchModeSelect
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Activate UL proactive scheduling  p_name=actProactUlScheduling  value=${pucchModeSelect}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${pucchModeSelect}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Modify actProactUlScheduling Parameter
    [Arguments]    ${actProactUlScheduling}=true    ${ulSchedTimeInterval}=40    ${ulProGrantTimer}=3000
    ...   ${payloadSizeProactiveDrx}=64   ${payloadSizeProactiveNonDrx}=16
    Log to console    Modify actProactUlScheduling Parameter
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate UL proactive scheduling
    ...    abbr=actProactUlScheduling
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Activate UL proactive scheduling  p_name=actProactUlScheduling  value=${actProactUlScheduling}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=UL scheduling time interval  p_name=ulSchedTimeInterval  value=${ulSchedTimeInterval}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=UL proactive grant timer  p_name=ulProGrantTimer  value=${ulProGrantTimer}
        append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Payload size for UL proactive grant for DRX UEs  p_name=payloadSizeProactiveDrx  value=${payloadSizeProactiveDrx}
        append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Payload size for UL proactive grant for non-DRX UEs  p_name=payloadSizeProactiveNonDrx  value=${payloadSizeProactiveNonDrx}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${actProactUlScheduling}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Modify csiReportPeriodicity Parameter
    [Arguments]    ${csiReportPeriodicity}=slots320
    Log to console    Modify csiReportPeriodicity Parameter
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=CSI Reporting Periodicity
    ...    abbr=csiReportPeriodicity
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=CSI Reporting Periodicity  p_name=csiReportPeriodicity  value=${csiReportPeriodicity}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${csiReportPeriodicity}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Modify srPeriodicity Parameter
    [Arguments]    ${srPeriodicity}=slots80
    Log to console    Modify srPeriodicity Parameter
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Scheduling request periodicity
    ...    abbr=srPeriodicity
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Scheduling request periodicity  p_name=srPeriodicity  value=${srPeriodicity}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${srPeriodicity}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Modify actCDrx Parameter
    [Arguments]    ${actCDrx}=true   ${drxInactivityTimer}=80ms   ${drxLongCycle}=160ms
    ...   ${drxOnDurationTimer}=10ms   ${drxRetransTimerDl}=0slot   ${drxRetransTimerUl}=0slot
    Log to console    Modify actCDrx Parameter ${actCDrx}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate connected DRX
    ...    abbr=actCDrx
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id
    FOR  ${cell_index}  IN  @{cell_list}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=Activate connected DRX   p_name=actCDrx
    ...   value=${actCDrx}
        append to list  ${modify_params}  ${item}
        ${para_object}    set variable if  '${stream}'<'SBTS24R3'   NRCELL-${cell_index}    NRDRX-4
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${para_object}
    ...    filter_param=DRX Inactivity Timer   p_name=drxInactivityTimer
    ...   value=${drxInactivityTimer}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${para_object}
    ...    filter_param=DRX Long Cycle   p_name=drxLongCycle
    ...   value=${drxLongCycle}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${para_object}
    ...    filter_param=DRX On Duration Timer   p_name=drxOnDurationTimer
    ...   value=${drxOnDurationTimer}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${para_object}
    ...    filter_param=DRX Retransmission Timer for Downlink   p_name=drxRetransTimerDl
    ...   value=${drxRetransTimerDl}
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${para_object}
    ...    filter_param=DRX Retransmission Timer for Uplink   p_name=drxRetransTimerUl
    ...   value=${drxRetransTimerUl}
        append to list  ${modify_params}  ${item}
    END
    Run Keyword If    '${currect_status}'!='${actCDrx}'
    ...    Modify Parameters On Webem    modify_params=${modify_params}

Update SW Config file on System Module
    [Documentation]    :Author: Jing Liang
    ...     This keyword sets the rnd params in the swconfig.txt
    ...     :param param_list:      list the update content, example input can be: ["0x4600BA=6","0x460002=6"]
    ...     :param del_param_list:  list the delete content, example input can be: ["0x4600BA","0x460002"]
    [Arguments]  ${param_list}=@{EMPTY}  ${del_param_list}=@{EMPTY}
    #${comu_alias}=   Connect to gNB Common Unit  gnb_id=${gnb_id}    du_id=${du_id}     comu_id=${comu_id}
    connection_alias_store.Connect to Common Unit Master    alias=${ASIK}
    swconf.download_swConfig_file_from_asik_to_test_pc    localFilePath=/tmp/swconfig_tmp.txt    asik_alias=${ASIK}
    Run Keyword if    ${del_param_list} != @{EMPTY}    swconf.delete_parameter_of_swConfig_file    parametersList=${del_param_list}
    ...    filePath=/tmp/swconfig_tmp.txt
    Run Keyword if    ${param_list} != @{EMPTY}    swconf.modify_swConfig_file    parametersList=${param_list}
    ...    filePath=/tmp/swconfig_tmp.txt
    swconf.upload_swConfig_file_to_asik_and_crasign    localFilePath=/tmp/swconfig_tmp.txt    asik_alias=${ASIK}

Get AaShell SW Config
    [Documentation]    :Author: Michele | This keyword Prints all non default R&D parameters of RadMaster.
    ...
    ...     :param rad_param    Rad Parameter                   [0x580017]  default=Empty
    ...
    ...    :return:
    ...           IF rad_param is empty:
    ...                      Prints all non default R&D parameters of RadMaster.
    ...           ELSE  The "Current val" of rad_param. e.g.: [u'0x0']
    [Arguments]  ${rad_param}=${EMPTY}
    connection_alias_store.Connect to Common Unit Master    alias=${ASIK}
    ssh.Send Command
    ...    command=telnet 0 15007  connection=${ASIK}
    ssh.Read Output Until
    ...    match=AaShell>${SPACE}
    ...    timeout=3
    ...    connection=${ASIK}
    ssh.Write Input
    ...    data=rad -mu \n
    ...    connection=${ASIK}
    ${nonDefaultRadMaster}=     ssh.Read Output Until
                                ...    match=AaShell>${SPACE}
                                ...    timeout=3
                                ...    connection=${ASIK}
    ssh.Write Input
    ...    data=quit\n
    ...    connection=${ASIK}
    ssh.Read Output Until
    ...    match=Bye ...
    ...    timeout=3
    ...    connection=${ASIK}
    ${radMasterValue}=    Run Keyword If     '${rad_param}'=='${EMPTY}'
    ...    set variable    ${nonDefaultRadMaster}
    ...   ELSE
    ...    Get regexp matches    ${nonDefaultRadMaster}       \\[${rad_param}\\] Default val = .*; Current val = (.*)  1
    [Return]    ${radMasterValue}

Set SW Config on Common Module
    [Documentation]    :Author: Srihari Janardhan  | This keyword sets the rnd params in the common module
    ...
    ...     :param rad_param:   rad param to set
    ...     :param rad_param_value:     value for rad param
    ...
    [Arguments]  ${rad_param}  ${rad_param_value}
    connection_alias_store.Connect to Common Unit Master    alias=${ASIK}
    ssh.Send Command
    ...    command=telnet 0 15007  connection=${ASIK}
    ssh.Read Output Until
    ...    match=AaShell>${SPACE}
    ...    timeout=3
    ...    connection=${ASIK}
    ssh.Write Input
    ...    data=rad -mw ${rad_param} ${rad_param_value}\n
    ...    connection=${ASIK}
    ssh.Write Input
    ...    data=quit\n
    ...    connection=${ASIK}
    ssh.Read Output Until
    ...    match=Bye ...
    ...    timeout=3
    ...    connection=${ASIK}
