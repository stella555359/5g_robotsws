*** Settings ***
Documentation     author: Yang Liqin
...               contact: liqin.yang@nokia-sbell.com
...               squad group: MMW_SG_05
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.collectors.snapshot     WITH NAME     snapshot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Library           taf.ul.parser.pcap        WITH NAME    pcap
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/wireshark_for_5gClassicalBTS.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Library      testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.5GC000496_C.Resources.process_data_in_file.HtmlParser     WITH NAME    html
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    ./coam.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/csvanalyzer.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/DCAP.robot
Library            random

*** Variables ***
${PATH_Storage}    /home/ute/CB008196_A
${MRBTS_ID}                          ${tl.gnbs[0].instance_id}
${cell_2}    411
${cell_1}    311
${physical_1}    238
${physical_2}    229
${plan_PA_value}    60
${link_to_Artifact_file}    https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.5.3/
##PA
${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}    #int
${5GRU2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}    #int
@{PA_value}    ${20}    ${10}    ${0}    #int list
@{att_connection_port}      ${5GRU1_ANT1}    ${5GRU2_ANT1}     #int list
${HBTE_max_value}           ${120}
${vendor}    topyoung
${att_ipaddr}    ${tl.attenuator[0].ip_addr}
${att_api_port}    ${tl.attenuator[0].port}
${ue_type}    huawei
${ul_port}    ${tl.appserver.iperf_details.port}
@{message_traced_rrc_list}    UL-CCCH-Message    UL-DCCH-Message    DL-DCCH-Message    DL-CCCH-Message
@{message_traced_target_rrc_list}    UL-DCCH-Message    DL-DCCH-Message
@{message_traced_ngap_list}    NGAP-PDU
@{message_not_traced_list}    X2AP-PDU
@{measurement_report_list}  nr-rrc.measResultServingCell  nr-rrc.physCellId  nr-rrc.measQuantityResults.rsrp  nr-rrc.measQuantityResults.rsrq
...  nr-rrc.measQuantityResults.sinr  nr-rrc.servCellId
@{Neighcell_report_list}  nr-rrc.physCellId  nr-rrc.measQuantityResults.rsrp  nr-rrc.measQuantityResults.rsrq  nr-rrc.measQuantityResults.sinr
...  nr-rrc.ssb_Index    nr-rrc.measResultNeighCells
@{beam_report_list}    nr-rrc.resultsSSB_Cell_element  nr-rrc.measQuantityResults.rsrp  nr-rrc.measQuantityResults.rsrq
...  nr-rrc.measQuantityResults.sinr  nr-rrc.ssb_Index
@{measurement_pcmd_list}  nsetapx.carrierFreq  nsetapx.triggerType  nsetapx.purpose  nsetapx.measResultServingMos  nsetapx.servCellId
...  nsetapx.pci  nsetapx.rsrp  nsetapx.rsrq  nsetapx.sinr
@{Neighcell_pcmd_list}  nsetapx.pci  nsetapx.rsrp  nsetapx.rsrq  nsetapx.sinr
...  nsetapx.measResultSsbIndexes    nsetapx.measResultNeighCellsNR    nsetapx.ssbIndex
@{beam_pcmd_list}  nsetapx.MeasResultSsbIndex_element  nsetapx.ssbIndex  nsetapx.rsrp  nsetapx.rsrq  nsetapx.sinr
${delta_activate}               ${CURDIR}/delta_8196_activation.json
${delta_3ms_shift}               ${CURDIR}/delta_3ms_shift_activation.json
${delta_deactivate}               ${CURDIR}/delta_8196_deactivation.json
${delta_delete}               ${CURDIR}/delta_8196_delete.json
${delta_combined}               ${CURDIR}/delta_8196_combined.json
${delta_combined_23R2}     ${CURDIR}/delta_8196_combined_23R2.json

${delta_specificResources}               ${CURDIR}/delta_8196_specificResources.json
${delta_specificResources_23R2}               ${CURDIR}/delta_8196_specificResources_23R2.json

${delta_cell_trace}               ${CURDIR}/delta_8196_cell_trace.json
${delta_cell_trace_23R2}               ${CURDIR}/delta_8196_cell_trace_23R2.json

${delta_pcmd}               ${CURDIR}/delta_8196_pcmd.json
${delta_pcmd_23R2}               ${CURDIR}/delta_8196_pcmd_23R2.json

${ENB_PATH}   MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
${lnrel_dist}    ${ENB_PATH}/LNCEL-1
${lnrel_para}    administrativeState
&{reportamountD}    r2=2    r4=4    r8=8    r16=16    r32=32    r64=64    infinity=7
&{reportintervalD}    ms120=1    ms240=2    ms480=3    ms640=4    ms1024=5    ms2048=6    ms5120=6    ms10240=8    ms20480=9    ms40960=10
...    min1=11    min6=12    min12=13    min30=14
${beam_num}    5
${workspace_dir}    /home/ute
@{gnb_custom_profile}    cp_5g   condor5gSyslog
${dcap_server_ip}  10.101.60.55
${Connect_DCAP}  True
*** Keywords ***
Test Case Setup
    [Arguments]     ${case_name}
    ${TS_CASE_LOG_PATH}    catenate     SEPARATOR=/    ${PATH_Storage}    ${case_name}
    Set Test Variable    ${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/${case_name}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    sleep    10s     sleep for alarm stable
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    Set test variable    ${exist_fault}
    Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}    file_path=${TS_CASE_LOG_PATH}
    ${date}=     robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d
    ...                                    time_zone=UTC
    ...                                    increment=8 hours
    Set test variable    ${date}
    Run keyword If    '${Connect_DCAP}'=='True'  Connect to DCAP and Change flag
    Run keyword and ignore error    Stop DCAP log when case setup

Test Case Teardown
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${0}
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${1}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}    file_path=${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword If Test Passed  Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run keyword and ignore error    Stop DCAP log when case teardown



Suite Case Setup
    Run Keyword And Ignore Error    coam.teardown
    Download plugin file To UTE
    android_ue.Kill ADB application
    log to console    Common Suite Setup
    CI_interface.Common Suite Setup
    Run Keyword And Ignore Error    scf.Activate or Deactivate feature    delta_file=${delta_deactivate}
    scf.Activate or Deactivate feature    delta_file=${delta_activate}
    Run Keyword And Ignore Error    scf.Activate or Deactivate feature    delta_file=${delta_3ms_shift}
    power_ue.Prepare UE      ue_index=${0}    ue_type=${ue_type}
    power_ue.Prepare UE      ue_index=${1}    ue_type=${ue_type}
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${0}
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${1}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}

Start DCAP log and change flag
    Start DCAP log via script

Suite Case Teardown
    log to console    Common Suite Setup
    CI_interface.Common Suite Setup

Connect to DCAP and Change flag
    [Arguments]     ${reset_flag}=False
    ${status}    Run Keyword And Return Status    Create Bts On DCAP via script
    log to console  set Connect_DCAP to ${reset_flag}
    Run Keyword If  ${status}  set suite variable  ${Connect_DCAP}      ${reset_flag}



Collect logs after test
    ${syslog_dir}  Stop DCAP log and get log path
    run  command=cd ${syslog_dir}/${date};ls -R ${syslog_dir}/${date}/ | grep .5gm > ${TS_CASE_LOG_PATH}/emil_log_name.txt
    run  command=cd ${syslog_dir}/${date};ls -R ${syslog_dir}/${date}/ | grep .LOG > ${TS_CASE_LOG_PATH}/syslog_name.txt
    [Return]    ${syslog_dir}

Download plugin file To UTE
    [Documentation]   Remove existing MCshark, download the SW-version specific MCshark, and retun the path of it
    [Arguments]    ${wirshark_plugin_dir}=/usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan
    Log To Console   Download plugin file To UTE
    ${MCShark}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/nsetapx-*buster.so
    ${MCShark_local}    Fetch From Right    ${MCShark}    /
    ${mcshark_exist}  Run keyword and return status    html.get_download_link_by_ext    url=${link_to_Artifact_file}   ext=so
    ${mcshark_name}   Run keyword If  ${mcshark_exist}    html.get_download_link_by_ext    url=${link_to_Artifact_file}   ext=so
    ${status1}    Run Keyword And Return Status    Should Not Be Equal    ${mcshark_name}[1]    ${MCShark_local}
    ${mcshark_download_link}=    Set Variable If  ${mcshark_exist}   ${link_to_Artifact_file}/${mcshark_name}[1]    ${None}
    Run Keyword If    ${mcshark_exist} and ${status1}   Run keywords    Run    sudo rm -f ${MCShark}
    ...    AND    run    command=sudo wget -P ${wirshark_plugin_dir} ${mcshark_download_link}

Adjust Attenuation Value
    [Arguments]    ${ports}    ${value}
    att.set_attenuation     port=${ports}    value=${value}
    ${value_port1}    att.read_attenuation    port=${ports}
    should be equal    ${value_port1}    ${value}

UE Attach and Start traffic
    [Arguments]     ${4G_check_needed}=False    ${throughput}=10M    ${duration}=1200    ${attach_mode}=5G_SA
    ...    ${physCellId}=${physical_1}    ${protocol}=udp    ${ue_index}=${0}    ${iperf_port}=default
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=10M     duration=${duration}
    ...    ue_index=${ue_index}    iperf_port=${iperf_port}
    Wait until keyword succeeds    2X  30s  Verify attach by adb    physCellId=${physCellId}    attach_mode=${attach_mode}
    ...    ue_index=${ue_index}

UE Dettach and Stop traffic
    [Arguments]    ${protocol}=udp    ${ue_index}=${0}    ${iperf_port}=default
    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}    iperf_port=${iperf_port}


Check the DL throughput
    [Arguments]    ${dl_expected_throughput}    ${cell_id}    ${ue_index}=${0}
    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dl_expected_throughput}
    ...    cellid=${cell_id}    ue_index=${ue_index}    sample=${10}

Start Tcpdump
    ${eth_port}   Set Variable If
    ...   '${SMOD_NAME}'=='ASIK'   fp0
    ...   '${SMOD_NAME}'=='ASIB'   br1
    ...   '${SMOD_NAME}'=='ASIL'   br0
    ...   '${SMOD_NAME}'=='ASOE'   br0
    Start to collect wireshark log for ASIB    options=-i ${eth_port} dst port ${dcap_server_port} or host ${AMF_IP}    name=trace



Check wireshark log for one cell
    [Arguments]    ${target_dir}    ${name}=trace    ${cell_idx}=1    ${trace_num}=4    ${ho}=${False}
    ${file_log_path}    catenate    ${target_dir}/${name}/${name}.pcap
    Set Suite Variable    ${file_log_path}
    Log to console    Get crnti for one cell
    Get crnti for one cell    file=${file_log_path}    idx=${cell_idx}
    Log to console    Check PCMD trace in wireshark log
    ${pcmd_result}    Run Keyword And Return Status    Check PCMD trace in wireshark log for one cell    file_log_path=${file_log_path}
    ...    idx=${cell_idx}
    Log to console    Check Cell trace in wireshark log
    ${cell_result}    Run Keyword And Return Status    Check Cell trace in wireshark log    file_log_path=${file_log_path}  idx=${cell_idx}
    ...    ho=${ho}
    [Return]    ${pcmd_result}    ${cell_result}

Get crnti for one cell
    [Arguments]    ${file}    ${idx}=1
    @{csv_title_list}    Create List    frame.time_epoch    nsetapx.nodeType  nsetapx.plmn_Identity    nsetapx.cellIdentity    nsetapx.traceId
    ...    nsetapx.TraceMessage    nsetapx.trigger    nsetapx.crnti
    ${idx_tmp}    Set Variable If    ${idx}==1    2    1
    Set Suite Variable    ${filterc_${idx}}    &&nsetapx.cellIdentity!=${nrcellid_${idx_tmp}_col}
    ${filter0}    Set Variable    &&nsetapx.CuVendorExtensionRecordDataType != 16
    ${filter1}    Set Variable    nsetapx.nodeType==0&&nsetapx.cellIdentity==${nrcellid_${idx}_col}&&nsetapx.TraceMessage!=5${filterc_${idx}}

    ${new_list}    ${output_csv1}  Get all crnti    file_log_path=${file}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=${idx}crnti
    Set Suite Variable   ${${idx}_crnti_list}    ${new_list}


Get value list in csv
    [Arguments]    ${list}    ${length}
    ${new_list}    create list
    FOR    ${idx}    IN RANGE    0    ${length}
        ${res}  String.Split String    ${list}[${idx}]    ,
        ${new_list}    Combine Lists    ${new_list}    ${res}
    END
    ${new_list}   Remove Duplicates    ${new_list}
    Remove Values From List    ${new_list}   ${empty}
    [Return]    ${new_list}

Check 8196 in wireshark log
    [Arguments]    ${file}    ${rrc_trace_num}=2    ${trace_num}=2    ${idx}=1   ${cell_trace_only}=${False}
    Log to console    Check RRC Reconfiguration includes MeasId, ReportConfig for periodic measurements
    @{csv_title_list}    Create List    frame.time_epoch    nsetapx.nodeType  nsetapx.cellIdentity    nr-rrc.reportInterval
    ...    nr-rrc.reportAmount    nr-rrc.measReportQuantity.rsrp    nr-rrc.measReportQuantity.rsrq    nr-rrc.measReportQuantity.sinr
    ...    nr-rrc.includeBeamMeasurements    nr-rrc.measId    nsetapx.crnti    nr-rrc.physCellId    nr-rrc.newUE_Identity
    ${filter}  Set Variable    nr-rrc.measReportQuantity.rsrp==1&&nsetapx.cellIdentity==${nrcellid_${idx}_col}
    ${filter1}    Set Variable
    ...  ${filter}&&nr-rrc.reportInterval==${interval}&&nr-rrc.reportAmount==${amount}

    ${crnti_list}    ${output_csv1}  Get all crnti    file_log_path=${file}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=rrc${idx}
    ${crnti_length}    Get Length    ${crnti_list}


    Should Be True    ${crnti_length}>=${rrc_trace_num}
    Set Suite Variable    ${crnti_report}    ${crnti_list}
    Check value for every criti in csv    output_csv=${output_csv1}
    ...    item=nr-rrc.measReportQuantity.rsrq    item_value=1    crnti_length=${crnti_length}
    Check value for every criti in csv    output_csv=${output_csv1}
    ...    item=nr-rrc.measReportQuantity.sinr    item_value=1    crnti_length=${crnti_length}
    Check value for every criti in csv    output_csv=${output_csv1}
    ...    item=nr-rrc.includeBeamMeasurements    item_value=1    crnti_length=${crnti_length}
    Check value for every criti in csv    output_csv=${output_csv1}
    ...    item=_ws.col.Info    item_value=RRC Reconfiguration    crnti_length=${crnti_length}


    Log to console    Check message RRC MeasurementReport message(s) containing Periodic Measurements (for Cell Trace).
    @{csv_title_list}    Create List    frame.time_epoch    frame.number    frame.protocols    nsetapx.nodeType  nsetapx.cellIdentity
    ...    nr-rrc.measQuantityResults.rsrp    nr-rrc.measQuantityResults.rsrq    nr-rrc.measQuantityResults.sinr    nr-rrc.servCellId
    ...    nr-rrc.ssb_Index    nsetapx.crnti    nr-rrc.resultsSSB_Indexes    nr-rrc.physCellId
    ${cell_filter}    Set Variable    nsetapx.cellIdentity==${nrcellid_${idx}_col}
    ${filter1}    Set Variable IF  ${cell_trace_only} and ${idx}==1
    ...  nsetapx.asn1_MsgId && nr-rrc.c1==0 && nr-rrc.measQuantityResults.rsrq!=1&&${cell_filter}
    ...  nsetapx.asn1_MsgId && nr-rrc.c1==0 && nr-rrc.measQuantityResults.rsrq!=1&&${cell_filter}&&nr-rrc.measId != 1
    ${new_list}    ${output_csv1}  Get all crnti    file_log_path=${file}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=report${idx}
    Set Suite Variable    ${crnti_report}    ${new_list}
    ${crnti_length}    Get Length    ${new_list}
    Set Suite Variable    ${${idx}_MR_crnti_length}    ${crnti_length}
    Check value for every criti in csv    output_csv=${output_csv1}
    ...    item=nr-rrc.servCellId    item_value=0    crnti_length=${crnti_length}
    Run Keyword And Continue On Failure    Check value for every criti in csv    output_csv=${output_csv1}
    ...    item=nr-rrc.physCellId    item_value=${physical_${idx}}    crnti_length=${crnti_length}


    @{csv_title_list1}    Create List    nsetapx.crnti
    ${filter_release}    Set Variable
    ...  nsetapx.asn1_MsgId&&${cell_filter}&&(ngap.radioNetwork == 21||ngap.radioNetwork == 20)
    ${release_crnti}    ${csv}  Get all crnti    file_log_path=${file_log_path}    csv_title_list=${csv_title_list1}
    ...    filter=${filter_release}    suffix=release
    ${crnti_length1}    Get Length    ${release_crnti}


    Run Keyword And Continue On Failure    Should Be True    ${crnti_length}>=1

    ${trace_tmp}  Run Keyword If   ${crnti_length}!=${trace_num}  Evaluate  ${crnti_length1}+${trace_num}
    ...  ELSE  Evaluate  ${trace_num}
    Run Keyword If   ${crnti_length1}!=0  Should Be True  ${crnti_length}<=${crnti_length1} or ${crnti_length}==${trace_tmp}


    #${frame_list}    get_the_special_item_value    ${output_csv1}    frame.time_epoch
    #${cell_trace_length}    Get Length    ${frame_list}
    #Set Suite Variable    ${cell_trace_length_${idx}}    ${cell_trace_length}
    Set Suite Variable  ${value_port_modify}  0
    FOR    ${id}    IN RANGE    0    ${crnti_length}
        ${filter_crnti}    Set Variable
        ...  ${filter1}&&nsetapx.crnti==${crnti_report}[${id}]
        ${crnti_csv}    Convert wireshark Log To CSV    wireshark_file=${file}  csv_title_list=${csv_title_list}
        ...    filter=${filter_crnti}    suffix=${crnti_report}[${id}]celltrace
        ${time_list}    get_the_special_item_value    ${crnti_csv}    frame.time_epoch
        Run Keyword And Continue On Failure  Check Periodic Measurement time interval  time_list=${time_list}    time_interval=${report_Interval}

        ${num_list}    get_the_special_item_value    ${crnti_csv}    frame.number
        ${frame_number}=	    random.choice      	${num_list}
        ${filters}    Set Variable    frame.number==${frame_number}
        ${output_pdml}    Convert wireshark Log To pdml    wireshark_file=${file}    filter=${filters}    suffix=${crnti_report}[${id}]reportc
        Check item in one file    file=${output_pdml}    codition_list=${measurement_report_list}
        Check item in one file    file=${output_pdml}    codition_list=${beam_report_list}
        ${beam_list}    Get Special Item Value List With Precondition    file_path=${crnti_csv}
        ...    item=nr-rrc.resultsSSB_Indexes    precondition={"frame.number":"${frame_number}"}
        ${status}  Run Keyword And Return Status    Check item in one file    file=${output_pdml}    codition_list=${Neighcell_report_list}
        ${res}  Run Keyword If    ${status}  String.Split String    ${beam_list}[0]    ,
        ${beam_tmp}    Run keyword If    ${status}    Evaluate    ${res}[0]+${res}[1]
		...    ELSE    Evaluate    ${beam_list}[0]
        Check num of item in one file    file=${output_pdml}    item=nr-rrc.ssb_Index    num=${beam_tmp}
        Log to console    Check all beam measurement report in cell trace for ${crnti_report}[${id}] serving cell
        Run Keyword And Continue On Failure  Check all beam measurement report in PCMD or cell trace  csv_file=${crnti_csv}
        ...  flag=${status}    item=nr-rrc.resultsSSB_Indexes


		${physcellid_list}    Get Special Item Value List With Precondition    file_path=${crnti_csv}
        ...    item=nr-rrc.physCellId    precondition={"frame.number":"${frame_number}"}
		${res}  Run Keyword If    ${status}  String.Split String    ${physcellid_list}[0]    ,
		...    ELSE    set variable    ${physcellid_list}
		List Should Contain Value    ${res}    ${physical_${idx}}
		${cell_id}    Set Variable If    ${idx}==1    2    1
		Run Keyword If    ${status}    List Should Contain Value    ${res}    ${physical_${cell_id}}
    END
    Set Suite Variable  ${cell_trace_length_${idx}}  ${value_port_modify}


Check 8196 for PCMD in wireshark log
    [Arguments]    ${file}    ${trace_num}=2    ${idx}=1
    Log to console    Check message RRC MeasurementReport message(s) containing Periodic Measurements (for PCMD).
    @{csv_title_list}    Create List    frame.time_epoch    frame.number    frame.protocols    nsetapx.nodeType  nsetapx.cellIdentity
    ...  nsetapx.servCellId  nsetapx.pci  nsetapx.rsrp  nsetapx.rsrq  nsetapx.sinr  nsetapx.crnti  nsetapx.measResultSsbIndexes
    ...  nsetapx.ssbIndex
    ${cell_filter}    Set Variable    nsetapx.cellIdentity==${nrcellid_${idx}_col}
    ${filter1}    Set Variable
    ...  nsetapx.CuVendorExtensionRecordDataType&&nsetapx.rsrp&&!ngap&&${cell_filter}&&!nr-rrc${filterc_${idx}}

    ${new_list}    ${output_csv1}  Get all crnti    file_log_path=${file}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=preport${idx}
    ${crnti_length}    Get Length    ${new_list}
    Should Be True    ${crnti_length}>=${trace_num}
    Set Suite Variable    ${crnti_report}    ${new_list}
    Set Suite Variable    ${${idx}_PMR_crnti_length}    ${crnti_length}
    Check value for every criti in csv    output_csv=${output_csv1}
    ...    item=nsetapx.servCellId    item_value=0    crnti_length=${crnti_length}
    Run Keyword And Continue On Failure    Check value for every criti in csv    output_csv=${output_csv1}
    ...    item=nsetapx.pci    item_value=${physical_${idx}}    crnti_length=${crnti_length}

    ${filter2}    Set Variable
    ...  nsetapx.CuVendorExtensionRecordDataType&&nsetapx.rsrp&&${cell_filter}
    ${output_csv2}    Convert wireshark Log To CSV    wireshark_file=${file}  csv_title_list=${csv_title_list}
    ...    filter=${filter2}    suffix=pcmdreport${idx}
    #${frame_list}    get_the_special_item_value    ${output_csv2}    frame.time_epoch
    #${pcmd_length}    Get Length    ${frame_list}
    #Set Suite Variable    ${pcmd_length_${idx}}
    Set Suite Variable  ${value_port_modify}  0
    FOR    ${id}    IN RANGE    0    ${crnti_length}
        ${filter_crnti}    Set Variable
        ...  ${filter2}&&nsetapx.crnti==${crnti_report}[${id}]
        ${crnti_csv}    Convert wireshark Log To CSV    wireshark_file=${file}  csv_title_list=${csv_title_list}
        ...    filter=${filter_crnti}    suffix=${crnti_report}[${id}]pcmd
        ${time_list}    get_the_special_item_value    ${crnti_csv}    frame.time_epoch
        Run Keyword And Continue On Failure  Check Periodic Measurement time interval  time_list=${time_list}    time_interval=${report_Interval}
        ${num_list}    get_the_special_item_value    ${crnti_csv}    frame.number

        ${frame_number}=	    random.choice      	${num_list}
        ${filter1}    Set Variable    frame.number==${frame_number}
        ${output_pdml}    Convert wireshark Log To pdml    wireshark_file=${file}    filter=${filter1}    suffix=${crnti_report}[${id}]reportp
        Check item in one file    file=${output_pdml}    codition_list=${measurement_pcmd_list}
        Check item in one file    file=${output_pdml}    codition_list=${beam_pcmd_list}
        ${status}  Run Keyword And Return Status    Check item in one file    file=${output_pdml}    codition_list=${Neighcell_pcmd_list}
        ${beam_list}    Get Special Item Value List With Precondition    file_path=${crnti_csv}
        ...    item=nsetapx.measResultSsbIndexes    precondition={"frame.number":"${frame_number}"}
        ${res}  Run Keyword If    ${status}  String.Split String    ${beam_list}[0]    ,
        ${beam_tmp}    Run Keyword If    ${status}    Evaluate    ${res}[0]+${res}[1]
        ...    ELSE    Evaluate    ${beam_list}[0]
        Check num of item in one file    file=${output_pdml}    item=nsetapx.ssbIndex    num=${beam_tmp}
        Log to console    Check all beam measurement report in PCMD for ${crnti_report}[${id}] serving cell
        Run Keyword And Continue On Failure  Check all beam measurement report in PCMD or cell trace  csv_file=${crnti_csv}
        ...  flag=${status}    item=nsetapx.measResultSsbIndexes
		${physcellid_list}    Get Special Item Value List With Precondition    file_path=${crnti_csv}
        ...    item=nsetapx.pci    precondition={"frame.number":"${frame_number}"}
		${res}  Run Keyword If    ${status}  String.Split String    ${physcellid_list}[0]    ,
		...    ELSE    set variable    ${physcellid_list}
		List Should Contain Value    ${res}    ${physical_${idx}}
		${cell_id}    Set Variable If    ${idx}==1    2    1
		Run Keyword If    ${status}    List Should Contain Value    ${res}    ${physical_${cell_id}}
    END
    Set Suite Variable    ${pcmd_length_${idx}}  ${value_port_modify}

Check num of measurement report in PCMD and Cell trace
    [Arguments]    ${idx}=1
    Log to console    Check num of measurement report in PCMD and Cell trace
    Should Be Equal As Integers    ${cell_trace_length_${idx}}    ${pcmd_length_${idx}}

Check all beam measurement report in PCMD or cell trace
    [Arguments]    ${csv_file}    ${flag}    ${item}    ${local}=0
    ${value_list}    get_the_special_item_value    ${csv_file}    ${item}
    ${length}    Get Length    ${value_list}
    FOR    ${id}    IN RANGE    0    ${length}
        ${res}  Run Keyword If    ${flag}  String.Split String    ${value_list}[${id}]    ,
        ${beam_tmp}    Set Variable If    ${flag}    ${res}[${local}]    ${value_list}[${id}]
        Exit For Loop If    ${beam_tmp}>=${beam_num}
    END

Check item in one file
    [Arguments]    ${file}    ${codition_list}
    FOR    ${item}    IN    @{codition_list}
        ${filter_res}   Run    cat ${file} | grep ${item}
        Should Not Be Empty    ${filter_res}
    END

Check num of item in one file
    [Arguments]    ${file}    ${item}    ${num}
    ${nums}   Run    cat ${file} | grep ${item} |wc -l
    Should be True    '${nums.split("\r\n")[0]}'=='${num}'


Check value for every criti in csv
    [Arguments]    ${output_csv}    ${item}    ${item_value}    ${crnti_length}
    FOR    ${idx}    IN RANGE    0    ${crnti_length}
        ${value_tmp}    Get Special Item Value List With Precondition    file_path=${output_csv}
        ...    item=${item}    precondition={"nsetapx.crnti":"${crnti_report}[${idx}]"}
        ${status}  Run Keyword And Return Status  Should Be Empty  ${value_tmp}
        ${value_list}  Run Keyword If  ${status}  Get Special Item Value List With Precondition    file_path=${output_csv}
        ...    item=${item}    precondition={"nsetapx.crnti":"${crnti_report}[${idx}],${crnti_report}[${idx}]"}
        ...    ELSE    Set Variable    ${value_tmp}
        ${res}  String.Split String    ${value_list[0]}    ,
        List Should Contain Value    ${res}    ${item_value}
    END



Check Internal count cellActivePeriodicUETraced in syslog
    [Arguments]    ${condition}    ${trace_num}    ${file_name}    ${idx}=2
    ${point}  Set Variable If    ${condition}==1
    ...  grep -rn "nrCellIdentity ${nrcellid_${idx}} allocated.*current list size 1" *| grep Ue|wc -l
    ...  grep -rn "nrCellIdentity ${nrcellid_${idx}} deallocated.*current list size 0" *| grep Ue|wc -l
	${nums}  Run  command=cd ${file_name}/${date};${point}
	Should be True    '${nums.split("\r\n")[0]}'=='${trace_num}'



Check PCMD trace in wireshark log for one cell
    [Arguments]    ${file_log_path}    ${idx}=1    ${nrCellIdentity}=${hex_nrcellid_${idx}}
    Log to console     check in PCMD record
    @{csv_title_list}    Create List    frame.time_epoch    nsetapx.nodeType  nsetapx.plmn_Identity    nsetapx.cellIdentity    nsetapx.traceId
    ...    nsetapx.traceRecordingSessionRef    nsetapx.trigger
    ...    nsetapx.crnti    nsetapx.seconds
    ${filter0}    Set Variable    &&nsetapx.CuVendorExtensionRecordDataType!=16
    ${filter1}  Set Variable  nsetapx.CuVendorExtensionRecordDataType&&nsetapx.cellIdentity==${nrcellid_${idx}_col}${filterc_${idx}}${filter0}


    ${crnti_list_tmp}    ${output_csv1}  Get all crnti    file_log_path=${file_log_path}  csv_title_list=${csv_title_list}
    ...    filter=${filter1}    suffix=pcmd
    Check value in csv    output_csv=${output_csv1}
    ...    item=nsetapx.plmn_Identity    item_value=${PLMN_IDENTITY}
    Check value in csv    output_csv=${output_csv1}
    ...    item=nsetapx.cellIdentity    item_value=${nrCellIdentity}
    Check value in csv    output_csv=${output_csv1}
    ...    item=nsetapx.traceId    item_value=${traceId}
    Check value in csv    output_csv=${output_csv1}
    ...    item=nsetapx.nodeType    item_value=0

    Lists Should Be Equal    ${crnti_list_tmp}    ${${idx}_crnti_list}



Check value in csv
    [Arguments]    ${output_csv}    ${item}    ${item_value}
    ${special_item_value_list}    get_the_special_item_value    ${output_csv}    ${item}
    ${special_item_value_length}    BuiltIn.Get Length    ${special_item_value_list}
    ${result}    Run keyword and return status    Should Not Be Equal As Integers     ${special_item_value_length}    1
    ${special_item_list}    Run Keyword If    ${result}    Get value list in csv
    ...    list=${special_item_value_list}    length=${special_item_value_length}
    ...    ELSE    Set Variable    ${special_item_value_list}
    ${status1}  Run keyword and return status  List Should Contain Value    ${special_item_list}    ${item_value}
    ${status2}  Run keyword and return status  Should Contain  ${special_item_list}[0]    ${item_value}
    Should Be True  ${status1} or ${status2}

Convert wireshark Log To pdml
    [Arguments]    ${wireshark_file}    ${filter}    ${suffix}=${none}
    ${pdml_file}    Replace String    ${wireshark_file}    .pcap    ${suffix}.pdml
    Convert wireshark To pdml By NSETAPX    wireshark_file=${wireshark_file}
    ...    output_file=${pdml_file}    filter=${filter}
    [Return]    ${pdml_file}

Convert wireshark To pdml By NSETAPX
    [Arguments]    ${wireshark_file}    ${output_file}    ${filter}
    ${cmd}    Catenate    tshark -r ${wireshark_file} -Y '${filter}' -T pdml -o ntrstr.port:49148 -o ntrstr.defragment:TRUE
    ...    > ${output_file}
    OperatingSystem.Run    ${cmd}

Convert wireshark Log To CSV
    [Arguments]    ${wireshark_file}    ${csv_title_list}    ${filter}    ${suffix}=${none}
    ${csv_file}    Replace String    ${wireshark_file}    .pcap    ${suffix}.csv
    CB008196_A_keyword.Convert wireshark To CSV By NSETAPX    bip_file=${wireshark_file}
    ...    output_file=${csv_file}    filter=${filter}    csv_title_list=${csv_title_list}
    [Return]    ${csv_file}

Check all recorded crnti
    [Arguments]    ${file_log_path}    ${csv_title_list}    ${filter}    ${suffix}    ${idx}=1
    ${new_list}    ${output_csv1}  Get all crnti    file_log_path=${file_log_path}  csv_title_list=${csv_title_list}
    ...    filter=${filter}    suffix=${suffix}
    Lists Should Be Equal    ${new_list}    ${${idx}_crnti_list}
    [Return]    ${new_list}


Get all crnti
    [Arguments]    ${file_log_path}    ${csv_title_list}    ${filter}    ${suffix}
    ${output_csv1}    Convert wireshark Log To CSV    wireshark_file=${file_log_path}  csv_title_list=${csv_title_list}
    ...    filter=${filter}    suffix=${suffix}
    ${crnti_list_tmp}    get_the_special_item_value    ${output_csv1}    nsetapx.crnti
    ${crnti_length}    BuiltIn.Get Length    ${crnti_list_tmp}
    ${new_list}    Get value list in csv    list=${crnti_list_tmp}    length=${crnti_length}
    [Return]    ${new_list}  ${output_csv1}

Check Cell trace in wireshark log
    [Arguments]    ${file_log_path}    ${idx}=1    ${ho}=${False}
    Log to console    Check rrc message in pdml
    ${rrc_filter}    Set Variable  nsetapx.nodeType==0&&nsetapx.asn1_MsgId&&nr-rrc&&nsetapx.cellIdentity==${nrcellid_${idx}_col}
    ${output_pdml}    Convert wireshark Log To pdml    wireshark_file=${file_log_path}    filter=${rrc_filter}    suffix=nrrrc${idx}
    FOR    ${message_not_traced}    IN    @{message_not_traced_list}
        ${filter_res}   Run    cat ${output_pdml} | grep ${message_not_traced}
        Should Be Empty    ${filter_res}
    END
    ${rrc_message_list}    Set Variable If  ${idx}==1  ${message_traced_target_rrc_list}    ${message_traced_rrc_list}
    FOR    ${message_traced_rrc}    IN    ${rrc_message_list}
        ${filter_res}   Run    cat ${output_pdml} | grep ${message_traced_rrc}
        Should Not Be Empty    ${filter_res}
    END


    @{csv_title_list}    Create List    frame.time_epoch    nsetapx.nodeType  nsetapx.plmn_Identity    nsetapx.cellIdentity    nsetapx.traceId
    ...    nsetapx.traceRecordingSessionRef    nsetapx.trigger
    ...    nsetapx.crnti    nsetapx.seconds
    Run Keyword And Continue On Failure    Check all recorded crnti    file_log_path=${file_log_path}    csv_title_list=${csv_title_list}
    ...    filter=${rrc_filter}    suffix=rrc    idx=${idx}

    Log to console    Check ngap message in pdml
    ${ngap_filter}    Set Variable    nsetapx.nodeType==0&&nsetapx.asn1_MsgId&&ngap&&nsetapx.cellIdentity==${nrcellid_${idx}_col}
    ${output_pdml}    Convert wireshark Log To pdml    wireshark_file=${file_log_path}    filter=${ngap_filter}    suffix=ngap
    FOR    ${message_traced_ngap}    IN    @{message_traced_ngap_list}
        ${filter_res}   Run    cat ${output_pdml} | grep ${message_traced_ngap}
        Should Not Be Empty    ${filter_res}
    END
    ${ngap_filter1}    Set Variable    ngap&&ip.dst!=${dcap_server_ip}
    ${ngap_pdml1}    Convert wireshark Log To pdml    wireshark_file=${file_log_path}    filter=${ngap_filter1}    suffix=ngap1
    ${ngap_num1}    Run    cat ${output_pdml} | grep ngap.NGAP_PDU | wc -l
	Log to console    ngap message in this cell
    ${ngap_num1}    Set Variable    ${ngap_num1.split("\r\n")[0]}
    ${ngap_num2}    Run    cat ${ngap_pdml1} | grep ngap.NGAP_PDU | wc -l
	Log to console    all ngap messages
    ${ngap_num2}    Set Variable    ${ngap_num2.split("\r\n")[0]}
    Run Keyword And Continue On Failure    Check all recorded crnti    file_log_path=${file_log_path}    csv_title_list=${csv_title_list}
    ...    filter=${ngap_filter}    suffix=ngapc    idx=${idx}

	${num3}    Run keyword If    ${ho}    Get ngap num for handover case
	...    ELSE    Set Variable    ${ngap_num1}
    Run Keyword And Continue On Failure    Should Be True    '${ngap_num2}'>='${num3}'


Get ngap num for handover case
    ${ngap_filter_tmp}    Set Variable    nsetapx.nodeType==0&&nsetapx.asn1_MsgId
	${output_pdml}    Convert wireshark Log To pdml    wireshark_file=${file_log_path}    filter=${ngap_filter_tmp}    suffix=ngapt
	${ngap_num3}    Run    cat ${output_pdml} | grep ngap.NGAP_PDU | wc -l
    ${ngap_num3}    Set Variable    ${ngap_num3.split("\r\n")[0]}
	[Return]    ${ngap_num3}


Modify source handover cell
    [Arguments]    ${cell_value}=none    ${bts_value}=false
    scf.Activate Parameter Value    dist_name=${INSID}/NRCELL-${cell_1}    p_name=a3MeasEnabled    new_value=${cell_value}
    scf.Activate Parameter Value    dist_name=${INSID}/NRCELL-${cell_1}    p_name=a5MeasEnabled    new_value=${cell_value}
    scf.Activate Parameter Value    dist_name=${INSID}    p_name=actIntraFreqIntraGnbMobilityNSA    new_value=${bts_value}

Check Periodic Measurement time interval
    [Arguments]    ${time_list}    ${time_interval}    ${guardtime}=400
    ${time_length}    Get Length    ${time_list}
    ${basetime1}    Run Keyword If    '${unit}'=='ms'    Evaluate    (${time_interval} + ${guardtime})
    ...    ELSE    Evaluate    (${time_interval}*60*1000 + ${guardtime})
    ${basetime2}    Run Keyword If    '${unit}'=='ms'   Evaluate     (${time_interval} - ${guardtime})
    ...    ELSE    Evaluate    (${time_interval}*60*1000 - ${guardtime})
    FOR    ${id}    IN RANGE    0    ${time_length}-1
        ${tmp}    Evaluate    ${id}+1
        ${DiffTime}=        Evaluate         (${time_list}[${tmp}]-${time_list}[${id}])*1000
        Should be True      ${DiffTime} >= ${basetime2}
        Should be True      ${DiffTime} <= ${basetime1}
        ${value_port_modify}  Run Keyword If  ${DiffTime} < ${basetime2}  Evaluate  ${value_port_modify}
        ...  ELSE  Evaluate  ${value_port_modify}+1
    END

Check wireshark log for no trace
    [Arguments]    ${target_dir}    ${filters}    ${name}=trace    ${size}=5
    ${file_log_path}    catenate    ${target_dir}/${name}/${name}.pcap
    Set Suite Variable    ${file_log_path}
    ${output_pdml}    Convert wireshark Log To pdml    wireshark_file=${file_log_path}    filter=${filters}    suffix=distrace
    ${file_info}    run  command=cat ${output_pdml}|wc -l
    ${file_size}    Set Variable    ${file_info.replace('\n','').strip()}
    Run Keyword And Continue On Failure    Should be True  ${size}==${file_size}

Get measurement report for Intra gNB inter cell Handover
    [Arguments]    ${file}=${file_log_path}
    ${filters}  Set Variable  nr-rrc.measId == 1&&nsetapx.asn1_MsgId && nr-rrc.c1==0 && nr-rrc.measQuantityResults.rsrq!=1
    @{csv_title_list}    Create List    frame.time_epoch    nsetapx.nodeType  nsetapx.plmn_Identity    nsetapx.cellIdentity    nsetapx.traceId
    ...    nsetapx.crnti
    ${new_list}    ${output_csv1}  Get all crnti    file_log_path=${file}  csv_title_list=${csv_title_list}
    ...    filter=${filters}    suffix=hocell
    ${crnti_length}    Get Length    ${new_list}
    ${filters_rrc}  Set Variable  nsetapx.asn1_MsgId&&nr-rrc.newUE_Identity
    @{csv_title_list_rrc}    Create List    frame.time_epoch    nsetapx.nodeType  nsetapx.plmn_Identity    nsetapx.cellIdentity    nsetapx.traceId
    ...    nsetapx.crnti

    ${new_list}    ${output_csv1}  Get all crnti    file_log_path=${file}  csv_title_list=${csv_title_list_rrc}
    ...    filter=${filters_rrc}    suffix=horrc
    ${trace_num}    Get Length    ${new_list}
    Should Be True    ${crnti_length}>=1

Get pcmd report for Intra gNB inter cell Handover
    [Arguments]    ${trace_num}    ${file}=${file_log_path}
    ${filters}  Set Variable  nsetapx.trigger == 1&&nsetapx.CuVendorExtensionRecordDataType == 17
    @{csv_title_list}    Create List    frame.time_epoch    nsetapx.nodeType  nsetapx.plmn_Identity    nsetapx.cellIdentity    nsetapx.traceId
    ...    nsetapx.TraceMessage    nsetapx.trigger    nsetapx.crnti

    ${new_list}    ${output_csv1}  Get all crnti    file_log_path=${file}  csv_title_list=${csv_title_list}
    ...    filter=${filters}    suffix=hopcmd

    ${crnti_length}    Get Length    ${new_list}
    Should Be True    ${crnti_length}>=1





Change radio conditions by mini step
    [Arguments]  ${ports}  ${target_value}  ${port1}  ${target_value1}  ${times}=10    ${physCellId}=${physical_1}    ${ue_index}=${0}
    ...  ${step}=2
    Log To Console    Change radio conditions by mini step
    ${PA_original_value}=      att.read_attenuation    port=${ports}
	${PA_original_value1}=      att.read_attenuation    port=${port1}
    FOR      ${i}      IN RANGE      ${times}
	    ${value_tmp}    att.read_attenuation    port=${ports}
          ${value_port1}      Run keyword if      ${value_tmp}<${target_value}    Evaluate
          ...      ${step}+${step}*${i}+${PA_original_value}
		  Run keyword if      ${value_port1}<=${target_value}    att.set_attenuation     port=${ports}    value=${value_port1}
		  ${value_port2}    Run keyword if      ${value_port1}<=${target_value}    att.read_attenuation    port=${ports}
		  sleep    2s

		  ${value_tmp1}    att.read_attenuation    port=${port1}
          ${value1_port1}      Run keyword if      ${value_tmp1}>${target_value1}    Evaluate
          ...      ${PA_original_value1}-${step}-${step}*${i}
		  Run keyword if      ${value1_port1}>=${target_value1}    att.set_attenuation     port=${port1}    value=${value1_port1}
		  ${value1_port2}    Run keyword if      ${value1_port1}>=${target_value1}    att.read_attenuation    port=${port1}
		  sleep    2s
		  ${status}  Run keyword If  ${physCellId}!=${None}  Run keyword and return status  Verify SA UE handover by adb  target_physCellId=${physCellId}
		  ...  ue_index=${ue_index}  source_physCellId=${physical_2}
		  ...  ELSE  set variable    ${False}
          Run keyword if      ${value_port1}>=${target_value} or ${value1_port1}<=${target_value1} or ${status}    Exit For Loop
    END

Change radio conditions by mini step for Intra gNB inter cell Handover
    Adjust Attenuation Value    ${5GRU2_ANT1}    value=${0}
    Adjust Attenuation Value    ${5GRU1_ANT1}    value=${20}
	log to console    Get ALL Suite Variables
    coam.Get ALL Suite Variables
    Start DCAP log and change flag
    Log To Console    Start Tcpdump
    Start Tcpdump

	UE Attach and Start traffic    ue_index=${0}    physCellId=${physical_2}

	Change radio conditions by mini step  ports=${5GRU2_ANT1}  target_value=${20}  port1=${5GRU1_ANT1}  target_value1=${0}
    ...  physCellId=${physical_1}    ue_index=${0}

    Change radio conditions by mini step  ports=${5GRU1_ANT1}  target_value=${20}  port1=${5GRU2_ANT1}  target_value1=${0}
    ...  physCellId=${None}    ue_index=${0}

    UE Attach and Start traffic    ue_index=${1}    physCellId=${physical_2}    iperf_port=45336
	power_ue.Start traffic  ue_type=${ue_type}  direction=dl  throughput=10M  duration=1200  ue_index=${0}


	Change radio conditions by mini step  ports=${5GRU2_ANT1}  target_value=${20}  port1=${5GRU1_ANT1}  target_value1=${0}
    ...  physCellId=${physical_1}    ue_index=${1}

    Run Keyword And Continue On Failure    UE Dettach and Stop traffic    ue_index=${0}
    Run Keyword And Continue On Failure    UE Dettach and Stop traffic    ue_index=${1}  iperf_port=45336
    Sleep    20
    Log To Console    Stop collecting wireshark log
    Run Keyword And Continue On Failure    wireshark_for_5gClassicalBTS.Stop collecting wireshark log    target_dir=${TS_CASE_LOG_PATH}    name=trace


PCMD and cell trace cellActivePeriodicUETraced exceed cellMaxPeriodicUEsTraced
    Log To Console    Preconditon for testing
	Run keyword and ignore error    scf.Activate or Deactivate feature    delta_file=${delta_delete}
	#scf.Activate or Deactivate feature    delta_file=${delta_combined}
	${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    scf.Activate or Deactivate feature    delta_file=${delta_combined}
    ...    ELSE       scf.Activate or Deactivate feature    delta_file=${delta_combined_23R2}

	log to console    Get ALL Suite Variables
    coam.Get ALL Suite Variables
    Adjust Attenuation Value    ${5GRU2_ANT1}    value=${120}
    Adjust Attenuation Value    ${5GRU1_ANT1}    value=${0}
    Log To Console    Start Tcpdump
    Start Tcpdump
    Start DCAP log and change flag
    UE Attach and Start traffic    ue_index=${0}
    UE Attach and Start traffic    ue_index=${1}
    Run Keyword And Continue On Failure    UE Dettach and Stop traffic    ue_index=${0}
    Run Keyword And Continue On Failure    UE Dettach and Stop traffic    ue_index=${1}
    Log To Console    Perform cell lock and unlock
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Perform cell lock via rest api    cell_idx=${311}
    sleep    5s
    Perform cell unlock via rest api    cell_idx=${311}
    Wait Until Keyword Succeeds    600 sec    60 sec    COAM Check GNB cell on air
    run keyword and ignore error    COAM Teardown gnb connections
    Log To Console    check UE after cell unlock
    UE Attach and Start traffic    ue_index=${1}
    UE Attach and Start traffic    ue_index=${0}
    Run Keyword And Continue On Failure    UE Dettach and Stop traffic    ue_index=${1}
    Run Keyword And Continue On Failure    UE Dettach and Stop traffic    ue_index=${0}
    Log To Console    Stop collecting wireshark log
    Run Keyword And Continue On Failure    wireshark_for_5gClassicalBTS.Stop collecting wireshark log    target_dir=${TS_CASE_LOG_PATH}    name=trace
    Log To Console    Stop collecting syslog
    ${syslog_dir}    Collect logs after test
    Log To Console    Check wireshark log
    ${pcmd_result}    ${cell_result}    Check wireshark log for one cell    target_dir=${TS_CASE_LOG_PATH}
    ...    name=trace
    Log to console    Check cell trace measurement in wireshark log
    Run Keyword And Continue On Failure    Check 8196 in wireshark log    file=${file_log_path}
    Run Keyword And Continue On Failure    should be equal    ${pcmd_result}    ${True}
    Run Keyword And Continue On Failure    should be equal    ${cell_result}    ${True}
    Run Keyword And Continue On Failure    Check 8196 for PCMD in wireshark log    file=${file_log_path}
    Run Keyword And Continue On Failure    Check num of measurement report in PCMD and Cell trace
    Log To Console    decrement Internal counter in syslog
#    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=0  trace_num=2
#    ...  idx=1  file_name=${syslog_dir}
    Log To Console    Increment Internal count in syslog



    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R3'
    ...    Set Test Variable    ${trace_num_syslog}    ${4}
    ...    ELSE    Set Test Variable    ${trace_num_syslog}    ${2}

#    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog
#    ...  condition=1  trace_num=${trace_num_syslog}
#    ...  idx=1  file_name=${syslog_dir}


PCMD cellMaxPeriodicUEsTraced is less than cellMaxActiveUEsTraced during intra gnb HO
    Log To Console    Modify Parameter actCellTraceReport and actPCMDReport
    Run keyword and ignore error    scf.Activate or Deactivate feature    delta_file=${delta_delete}

    #scf.Activate or Deactivate feature    delta_file=${delta_pcmd}
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    scf.Activate or Deactivate feature    delta_file=${delta_pcmd}
    ...    ELSE       scf.Activate or Deactivate feature    delta_file=${delta_pcmd_23R2}

    Log To Console    Change radio conditions by mini step for Intra gNB inter cell Handover
    Change radio conditions by mini step for Intra gNB inter cell Handover

    Log To Console    Stop collecting syslog
    ${syslog_dir}    Collect logs after test
    Log To Console    Check wireshark log for cell trace
    ${filters}  Set Variable  nsetapx.asn1_MsgId
    Run Keyword And Continue On Failure    Check wireshark log for no trace    target_dir=${TS_CASE_LOG_PATH}    filters=${filters}
    Log To Console    Get crnti for cell-1
    Get crnti for one cell    file=${file_log_path}    idx=1

    Log To Console    Check wireshark log
    Run Keyword And Continue On Failure    Check PCMD trace in wireshark log for one cell    file_log_path=${file_log_path}
    Run Keyword And Continue On Failure    Check 8196 for PCMD in wireshark log    file=${file_log_path}  trace_num=1
    Log To Console    Get crnti for cell-2
    Get crnti for one cell    file=${file_log_path}    idx=2
    Run Keyword And Continue On Failure    Check PCMD trace in wireshark log for one cell    file_log_path=${file_log_path}
    ...    idx=2

    Run Keyword And Continue On Failure    Check 8196 for PCMD in wireshark log    file=${file_log_path}    idx=2    trace_num=2
    Run Keyword And Continue On Failure    Get pcmd report for Intra gNB inter cell Handover    trace_num=2

#    Log To Console    decrement Internal counter for cell-1 in syslog
#    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=0  trace_num=${1_PMR_crnti_length}
#    ...  idx=1  file_name=${syslog_dir}
    Log To Console    Increment Internal count for cell-1 in syslog
    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=1  trace_num=${1_PMR_crnti_length}
    ...  idx=1  file_name=${syslog_dir}
#    Log To Console    decrement Internal counter for cell-2 in syslog
#    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=0  trace_num=${2_PMR_crnti_length}
#    ...  idx=2  file_name=${syslog_dir}
    Log To Console    Increment Internal count for cell-2 in syslog
#    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=1  trace_num=${2_PMR_crnti_length}
#    ...  idx=2  file_name=${syslog_dir}
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    Set Test Variable    ${trace_num_syslog}    ${2}
    ...    ELSE    Set Test Variable    ${trace_num_syslog}    ${4}

    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog
    ...  condition=1  trace_num=${trace_num_syslog}
    ...  idx=2  file_name=${syslog_dir}

    [Teardown]  Modify source handover cell    cell_value=rsrp    bts_value=true

cell trace cellMaxPeriodicUEsTraced is less than cellMaxActiveUEsTraced during intra gnb HO
    Log To Console    Preconditon for testing

    Log To Console    Modify Parameter actCellTraceReport and actPCMDReport
    Run keyword and ignore error  scf.Activate or Deactivate feature    delta_file=${delta_delete}
    #scf.Activate or Deactivate feature    delta_file=${delta_cell_trace}

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    scf.Activate or Deactivate feature    delta_file=${delta_cell_trace}
    ...    ELSE       scf.Activate or Deactivate feature    delta_file=${delta_cell_trace_23R2}



    Log To Console    Change radio conditions by mini step for Intra gNB inter cell Handover
    Change radio conditions by mini step for Intra gNB inter cell Handover
    Log To Console    Stop collecting syslog
    ${syslog_dir}    Collect logs after test
    Log To Console    Check wireshark log for pcmd
    ${filters}  Set Variable  nsetapx.CuVendorExtensionRecordDataType
    Run Keyword And Continue On Failure    Check wireshark log for no trace    target_dir=${TS_CASE_LOG_PATH}    filters=${filters}
    Log To Console    Get crnti for cell-1
    Run Keyword And Continue On Failure    Get crnti for one cell    file=${file_log_path}
    Log To Console    Check wireshark log
    Run Keyword And Continue On Failure    Check Cell trace in wireshark log    file_log_path=${file_log_path}    ho=${True}
    Run Keyword And Continue On Failure    Check 8196 in wireshark log    file=${file_log_path}    trace_num=1    rrc_trace_num=0
    ...    cell_trace_only=${True}
    Log To Console    Get crnti for cell-2
    Run Keyword And Continue On Failure    Get crnti for one cell    file=${file_log_path}    idx=2
    Run Keyword And Continue On Failure    Check Cell trace in wireshark log    file_log_path=${file_log_path}
    ...    idx=2    ho=${True}
    Run Keyword And Continue On Failure    Check 8196 in wireshark log    file=${file_log_path}    idx=2    trace_num=2
    Run Keyword And Continue On Failure    Get measurement report for Intra gNB inter cell Handover

    Log To Console    decrement Internal counter for cell-1 in syslog
#    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=0  trace_num=${1_MR_crnti_length}
#    ...  idx=1  file_name=${syslog_dir}
    Log To Console    Increment Internal count for cell-1 in syslog
    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=1  trace_num=${1_MR_crnti_length}
    ...  idx=1  file_name=${syslog_dir}
    Log To Console    decrement Internal counter for cell-2 in syslog
#    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=0  trace_num=${2_MR_crnti_length}
#    ...  idx=2  file_name=${syslog_dir}
    Log To Console    Increment Internal count for cell-2 in syslog
#    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=1  trace_num=${2_MR_crnti_length}
#    ...  idx=2  file_name=${syslog_dir}

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    Set Test Variable    ${trace_num_syslog}    ${2}
    ...    ELSE    Set Test Variable    ${trace_num_syslog}    ${4}

    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog
    ...  condition=1  trace_num=${trace_num_syslog}
    ...  idx=2  file_name=${syslog_dir}


    [Teardown]  Modify source handover cell    cell_value=rsrp    bts_value=true

PCMD and cell trace UEs Handover between enabled trace and disabled trace cells
    Log To Console    Modify scf to specificResources
    Run keyword and ignore error  scf.Activate or Deactivate feature    delta_file=${delta_delete}
    #scf.Activate or Deactivate feature    delta_file=${delta_specificResources}
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    scf.Activate or Deactivate feature    delta_file=${delta_specificResources}
    ...    ELSE       scf.Activate or Deactivate feature    delta_file=${delta_specificResources_23R2}



    log to console    Get ALL Suite Variables
    coam.Get ALL Suite Variables
    Log To Console    Preconditon for testing
    Adjust Attenuation Value    ${5GRU2_ANT1}    value=${0}
    Adjust Attenuation Value    ${5GRU1_ANT1}    value=${20}
    Start DCAP log and change flag
    Log To Console    Start Tcpdump
    Start Tcpdump
    UE Attach and Start traffic    ue_index=${0}    physCellId=${physical_2}
    Adjust Attenuation Value    ${5GRU1_ANT1}    value=${0}
    Adjust Attenuation Value    ${5GRU2_ANT1}    value=${20}

    sleep    10s
    Verify attach by adb    physCellId=${physical_1}    attach_mode=5G_SA    ue_index=${0}
    UE Attach and Start traffic    ue_index=${1}    physCellId=${physical_1}
    Adjust Attenuation Value    ${5GRU1_ANT1}    value=${20}
    Adjust Attenuation Value    ${5GRU2_ANT1}    value=${0}
    sleep    10s
    Verify attach by adb    physCellId=${physical_2}    attach_mode=5G_SA    ue_index=${0}
    Verify attach by adb    physCellId=${physical_2}    attach_mode=5G_SA    ue_index=${1}
    Run Keyword And Continue On Failure    UE Dettach and Stop traffic    ue_index=${0}
    Run Keyword And Continue On Failure    UE Dettach and Stop traffic    ue_index=${1}
    ${syslog_dir}    Collect logs after test
    Log To Console    Stop collecting wireshark log
    Run Keyword And Continue On Failure  wireshark_for_5gClassicalBTS.Stop collecting wireshark log  target_dir=${TS_CASE_LOG_PATH}  name=trace

    Log To Console    Check wireshark log for disabled trace cell
    ${filters}  Set Variable  nsetapx.nodeType==0&&nsetapx.cellIdentity==${nrcellid_1_col}&&nsetapx.cellIdentity!=${nrcellid_2_col}
    Run Keyword And Continue On Failure  Check wireshark log for no trace    target_dir=${TS_CASE_LOG_PATH}    filters=${filters}
    Log To Console    Check wireshark log for enabled trace cell

    ${pcmd_result_2}    ${cell_result_2}    Check wireshark log for one cell    target_dir=${TS_CASE_LOG_PATH}
    ...    name=trace    cell_idx=2    trace_num=3    ho=${True}
    Run Keyword And Continue On Failure    should be equal    ${pcmd_result_2}    ${True}
    Run Keyword And Continue On Failure    should be equal    ${cell_result_2}    ${True}
    Run Keyword And Continue On Failure    Check 8196 in wireshark log    file=${file_log_path}    idx=2    rrc_trace_num=1
    Run Keyword And Continue On Failure    Check 8196 for PCMD in wireshark log    file=${file_log_path}    idx=2
    Run Keyword And Continue On Failure    Check num of measurement report in PCMD and Cell trace    idx=2
    Run Keyword And Continue On Failure    Get measurement report for Intra gNB inter cell Handover

    Log To Console    decrement Internal counter for cell-1 in syslog
    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=0  trace_num=0
    ...  idx=1  file_name=${syslog_dir}
    Log To Console    Increment Internal count for cell-1 in syslog
    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=1  trace_num=0
    ...  idx=1  file_name=${syslog_dir}
    Log To Console    decrement Internal counter for cell-2 in syslog
    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=0  trace_num=${2_MR_crnti_length}
    ...  idx=2  file_name=${syslog_dir}
    Log To Console    Increment Internal count for cell-2 in syslog
#    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog  condition=1  trace_num=${2_MR_crnti_length}
#    ...  idx=2  file_name=${syslog_dir}

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    Set Test Variable    ${trace_num_syslog}    ${2}
    ...    ELSE    Set Test Variable    ${trace_num_syslog}    ${3}

    Run Keyword And Continue On Failure  Check Internal count cellActivePeriodicUETraced in syslog
    ...  condition=1  trace_num=${trace_num_syslog}
    ...  idx=2  file_name=${syslog_dir}


