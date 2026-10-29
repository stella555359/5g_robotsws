*** Settings ***


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/wireshark_for_5gClassicalBTS.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Library             taf.hw.rf_attenuator    WITH NAME    PA_
Library     DateTime
Library     String
Library     ./csvanalyzer.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/DCAP.robot



*** Variables ***
${ue_type}    huawei
${PA1_INFO}                 ${tl.attenuators[0]}
${cell_2}    411
${cell_1}    311
${physical_1}    238
${physical_2}    229
${RU1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}    #int
${RU2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}    #int
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${dcap_ip}     10.101.60.55
${dcap_port}    443

${SMOD_NAME}   ASIK
${delta_file_a11_delete}         ${CURDIR}/Configuration/scf_DU1997_delta_22R4_a11_delete.json
${delta_file_a11_add}         ${CURDIR}/Configuration/scf_DU1997_delta_22R4_a11_add.json
${delta_file_a11_add_23R2}         ${CURDIR}/Configuration/scf_DU1997_delta_22R4_a11_add_23R2.json
${delta_file_a10}         ${CURDIR}/Configuration/scf_DU1997_delta_22R4_a10_add.json
${delta_file_a10_23R2}         ${CURDIR}/Configuration/scf_DU1997_delta_22R4_a10_add_23R2.json

${scf}     ${CURDIR}/Configuration/scf_DU1997_22R4_base.xml
${workdir}    ${CURDIR}
@{att_connection_port}      ${RU1}    ${RU2}

*** Keywords ***
CB008196_A_010


    #SCF commission     SCF=${scf}
    run keyword and ignore error    SCF delta recommission       delta_file=${delta_file_a11_delete}
    #SCF delta recommission       delta_file=${delta_file_a10}
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    SCF delta recommission       delta_file=${delta_file_a10}
    ...    ELSE       SCF delta recommission       delta_file=${delta_file_a10_23R2}


    Adjust Attenuation Port Value    port=${RU1}    value=${0}
    Adjust Attenuation Port Value    port=${RU2}    value=${120}

    Run keyword and ignore error    Stop DCAP log when case setup
    @{traces}    create list   condor5gSyslog
    wait until keyword succeeds    3x    5min       DCAP.Start_Collect_Trace   traces=${traces}

    Start Tcpdump a1011
    log to console    attach UE and start traffic
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    verify attach cellid     physCellId=${physical_1}    ue_index=${0}    attach_mode=5G_SA
    Start traffic a1011


    log to console    start 1st handover
    Adjust Attenuation Port Value    port=${RU1}    value=${20}
    sleep    2
    Adjust Attenuation Port Value    port=${RU2}    value=${0}
    sleep   8
    #verify attach cellid     physCellId=${physical_2}    ue_index=${0}    attach_mode=5G_SA


    ${pcap_file1}    Stop tcpdump a1011
    #run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result
    run keyword and continue on failure       Stop_Collect_Trace_and_Get_Result_test
    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=syslog

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    Set Test Variable    ${allocatedSum_exp}    ${2}
    ...    ELSE    Set Test Variable    ${allocatedSum_exp}    ${3}

    run keyword and continue on failure    verify DCAP syslog     allocatedSum_exp=${allocatedSum_exp}     deallocatedSum_exp=${1}
    run keyword and continue on failure    Check the PCMD and cell trace when actCellTraceReport and actPCMDReport to True a1011
    ...  bip_file=${pcap_file1}    csv_file1=${OUTPUT DIR}/trace/nrrrc.csv
    ...  csv_file2=${OUTPUT DIR}/trace/PCMD.csv     csv_file3=${OUTPUT DIR}/trace/celltrace.csv
    ...  filter=(nr-rrc.reportType ==0&&nr-rrc.includeBeamMeasurements ==1&&nr-rrc.reportAmount==7&&nr-rrc.reportInterval==8&&nr-rrc.rsType == 0)

    UE Stop traffic and Dettach     ue_index=${0}


    log to console     reset bts
    Gnb Reset Site

    sleep   30

    log to console    attach UE and start traffic

    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    verify attach cellid     physCellId=${physical_2}    ue_index=${0}    attach_mode=5G_SA
    Start traffic a1011

    Start Tcpdump a1011
    wait until keyword succeeds    3x    5min       DCAP.Start_Collect_Trace   traces=${traces}
    sleep   10
    verify attach cellid     physCellId=${physical_2}    ue_index=${0}    attach_mode=5G_SA

    log to console    start 2nd handover
    Adjust Attenuation Port Value    port=${RU2}    value=${25}
    sleep   3
    Adjust Attenuation Port Value    port=${RU1}    value=${0}
    sleep    10
    verify attach cellid     physCellId=${physical_1}    ue_index=${0}    attach_mode=5G_SA

    power_ue.UE Detach    ue_type=${ue_type}
    sleep    20

    ${pcap_file2}    Stop tcpdump a1011
    #run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result
    run keyword and continue on failure       Stop_Collect_Trace_and_Get_Result_test
    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=syslog

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...  Run keywords  Set Test Variable  ${deallocatedSum_exp}  ${1}  AND  Set Test Variable  ${allocatedSum_exp}  ${2}
    ...  ELSE  Run keywords  Set Test Variable  ${deallocatedSum_exp}  ${2}  AND  Set Test Variable  ${allocatedSum_exp}  ${1}


    verify DCAP syslog     allocatedSum_exp=${allocatedSum_exp}     deallocatedSum_exp=${deallocatedSum_exp}
    Check the PCMD and cell trace when actCellTraceReport and actPCMDReport to True a1011
    ...  bip_file=${pcap_file2}    csv_file1=${OUTPUT DIR}/trace/nrrrc.csv
    ...  csv_file2=${OUTPUT DIR}/trace/PCMD.csv     csv_file3=${OUTPUT DIR}/trace/celltrace.csv
    ...  filter=(nr-rrc.reportType==0&&nr-rrc.includeBeamMeasurements==1&&nr-rrc.reportAmount==7&&nr-rrc.reportInterval==8&&nr-rrc.rsType==0)




CB008196_A_011
    run keyword and ignore error    SCF delta recommission       delta_file=${delta_file_a11_delete}
    sleep    5
    #SCF delta recommission       delta_file=${delta_file_a11_add}
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R1'
    ...    SCF delta recommission       delta_file=${delta_file_a11_add}
    ...    ELSE       SCF delta recommission       delta_file=${delta_file_a11_add_23R2}

    Adjust Attenuation Port Value    port=${RU1}    value=${0}
    Adjust Attenuation Port Value    port=${RU2}    value=${120}
    log to console    Connect and Modify the parameter on enblte
    Connect and Modify the parameter on enblte    dist_name=${lnrel_dist}    parameter=${lnrel_para}     value=locked

    Run keyword and ignore error    Stop DCAP log when case setup
    @{traces}    create list   condor5gSyslog
    wait until keyword succeeds    3x    5min       DCAP.Start_Collect_Trace   traces=${traces}
    Start Tcpdump a1011

    log to console    attach UE and start traffic
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    verify attach cellid     physCellId=${physical_1}    ue_index=${0}    attach_mode=5G_SA
    Start traffic a1011
    sleep   10

    log to console    start 1st handover
    Adjust Attenuation Port Value    port=${RU1}    value=${20}
    Adjust Attenuation Port Value    port=${RU2}    value=${0}
    sleep    10
    verify attach cellid     physCellId=${physical_2}    ue_index=${0}    attach_mode=5G_SA

    #log to console     gnblog check verify ue should in userinactivity, here manual check by huawei mate 30failed, so TA ignore this checkpoint
    power_ue.Stop traffic    ue_type=${ue_type}     direction=ul
    power_ue.Stop traffic    ue_type=${ue_type}     direction=dl
    sleep   30

    Start traffic a1011
    sleep   10

    Adjust Attenuation Port Value    port=${RU1}    value=${120}
    Adjust Attenuation Port Value    port=${RU2}    value=${120}

    sleep    10
    ${pcap_file1}     Stop tcpdump a1011
    #run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result
    run keyword and continue on failure       Stop_Collect_Trace_and_Get_Result_test
    run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=syslog

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R2' or '${release_sbts}'=='SBTS23R3'
    ...    Set Test Variable    ${allocatedSum_exp}    ${3}
    ...    ELSE    Set Test Variable    ${allocatedSum_exp}    ${2}


    #run keyword and continue on failure    verify DCAP syslog  allocatedSum_exp=${allocatedSum_exp}   deallocatedSum_exp=${1}
    run keyword and continue on failure    Check the PCMD and cell trace when actCellTraceReport and actPCMDReport to True a1011
    ...  bip_file=${pcap_file1}    csv_file1=${OUTPUT DIR}/trace/nrrrc.csv
    ...  csv_file2=${OUTPUT DIR}/trace/PCMD.csv     csv_file3=${OUTPUT DIR}/trace/celltrace.csv
    [Teardown]  case_teardown a11

Stop_Collect_Trace_and_Get_Result_test
    [Arguments]   ${timeout}=10min
    [Documentation]  Stop tracing, delete to traces to save server space, then remove the bts from the dcapserver.
    ...     return: path of downloaded trace file in zip format, and the content in the zip file.
    Log to console   Stop collecting dcap log.
    rd.stop_trace
    sleep    ${timeout}
    ${trace_file_path}    rd.get_results
    ${trace_result_content}    rd.get_result_file_contents
    ${PATHONLY}   ${SNAPSHOTNAME}   Split String From Right    string=${trace_file_path}   separator=/     max_split=1
    ${PATHONLY}   ${SNAPSHOTNAMEContent}   Split String From Right    string=${trace_result_content}   separator=/     max_split=1
    run    mv ${trace_file_path} ${LOG_PATH}/.
    run    mv ${trace_result_content} ${LOG_PATH}/.
    set test variable   ${trace_file_path}    ${LOG_PATH}/${SNAPSHOTNAME}
    set test variable   ${trace_result_content}    ${LOG_PATH}/${SNAPSHOTNAMEContent}
    rd.delete_trace
    rd.delete_bts
    [Return]  ${trace_file_path}  ${trace_result_content}




case_teardown a11
    log to console    modify qRxLevMin for cell-1
    scf.Activate Parameter Value    dist_name=MRBTS-1997/NRBTS-10291/NRCELL-311    p_name=qRxLevMin    new_value=-65
    log to console    modify qRxLevMin for cell-2
    scf.Activate Parameter Value    dist_name=MRBTS-1997/NRBTS-10291/NRCELL-411    p_name=qRxLevMin    new_value=-65
    log to console    unlock cell-1 on enblte
    Connect and Modify the parameter on enblte    dist_name=${lnrel_dist}    parameter=${lnrel_para}     value=unlocked


Check the PCMD and cell trace when actCellTraceReport and actPCMDReport to True a1011
    [Arguments]    ${bip_file}      ${csv_file1}    ${csv_file2}   ${csv_file3}
    ...  ${filter}=(nr-rrc.reportType==0&&nr-rrc.includeBeamMeasurements==1&&nr-rrc.reportAmount==6&&nr-rrc.reportInterval==8&&nr-rrc.rsType==0)
    run   rm ${OUTPUT DIR}/trace/*.csv
    Convert tcpdump file to CSV for 8196
    ...  filter=${filter}
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file1}
    sleep    5
    ${file_size}=    CB008196_A_keyword.Get File Size   file_path=${csv_file1}
    should be true  ${file_size} > 1

    Convert tcpdump file to CSV for 8196
    ...  filter=(nsetapx.CuVendorExtensionRecordDataType == 3&&nsetapx.measResultSsbIndexes >= 5)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file2}
    Get and Check tcpdumpfile
    ...    item=nsetapx.CuVendorExtensionRecordDataType
    ...    value=3
    ...    CSV_FILE=${csv_file2}
    Get and Check tcpdumpfile
    ...    item=nsetapx.measResultSsbIndexes
    ...    value=6
    ...    CSV_FILE=${csv_file2}

    Convert tcpdump file to CSV for 8196
    ...  filter=(nr-rrc.criticalExtensions == 0&&nr-rrc.resultsSSB_Indexes == 6)
    ...  bip_files=${bip_file}
    ...  csv_file=${csv_file3}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.criticalExtensions
    ...    value=0
    ...    CSV_FILE=${csv_file3}
    Get and Check tcpdumpfile
    ...    item=nr-rrc.resultsSSB_Indexes
    ...    value=6
    ...    CSV_FILE=${csv_file3}


Convert tcpdump file to CSV for 8196
    [Arguments]    ${filter}     ${bip_files}   ${csv_file}

    @{csv_title_list1}    Create List     nsetapx.CuVendorExtensionRecordDataType   nr-rrc.reportType
    ...     nr-rrc.includeBeamMeasurements    nr-rrc.reportAmount    nr-rrc.reportInterval    nr-rrc.rsType
    ...     nr-rrc.criticalExtensions      nr-rrc.resultsSSB_Indexes    nsetapx.measResultSsbIndexes
    Convert wireshark To CSV By NSETAPX    bip_file=${bip_files}
    ...    output_file=${csv_file}    filter=${filter}    csv_title_list=${csv_title_list1}

case_setup a1011
    log to console     Case Start
    power_ue.Prepare UE      ue_index=${0}    ue_type=${ue_type}
    power_ue.Prepare UE      ue_index=${1}    ue_type=${ue_type}
    Run keyword And Ignore Error    UE Stop traffic and Dettach     ue_index=${0}
    Run keyword And Ignore Error    UE Stop traffic and Dettach     ue_index=${1}

UE Stop traffic and Dettach
    [Arguments]    ${ue_index}=${0}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul  ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl  ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}  ue_index=${ue_index}


Setup_Suite
    #SCF commission     SCF=${scf}

UE teardown
    UE Stop traffic and Dettach     ue_index=${0}
    run keyword and ignore error    rd.stop_trace
    run keyword and ignore error    wireshark_for_5gClassicalBTS.Stop collecting wireshark log    target_dir=/tmp     name=trace



Start traffic a1011
    power_ue.Start traffic    ue_type=huawei    direction=ul    throughput=100M    duration=1000
    power_ue.Start traffic    ue_type=huawei    direction=dl    throughput=100M    duration=1000

Check Throughtput
    [Arguments]        ${duration}=30    ${ul_target}=0.5   ${dl_target}=0.5     ${min_percent}=0.00001
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}     filter=L2Lo
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=DL   log=${tput_log}
    ...    cells=${first_cell_to_check}    target_throughput=${dl_target}
    run keyword and continue on failure     power_ue.Check Tput    ue_type=${ue_type}    direction=UL   log=${tput_log}
    ...    cells=${first_cell_to_check}    target_throughput=${ul_target}   min_percent=${min_percent}


verify attach cellid
    [Arguments]    ${physCellId}    ${ue_index}=${0}    ${sleep_time_before_read_output}=5s
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${attach_mode}=5G_SA
    Connect to control pc via cygwin    ue_index=${ue_index}

    csn.send command
    ...    command=adb -s ${serial_number} shell dumpsys telephony.registry
    ...    connection=cygwin
    ...    timeout=15

    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${result} =    csn.read output    connection=cygwin
    Should contain    ${result}    mDataRegState=0
    Run Keyword If   '${attach_mode}' == '5G_SA'    Should contain  ${result}    accessNetworkTechnology=NR
    Run Keyword If   '${attach_mode}' == '5G_SA'    Should contain  ${result}    mPci = ${physCellId}

    [teardown]    Run keyword and ignore error    csn.disconnect   connection=cygwin


Adjust Attenuation Port Value
    [Arguments]    ${port}    ${value}       ${logging_message}=Adjusting PA values
    PA_.setup_attenuator      ip_addr=${tl.attenuator[0].ip_addr}    port=${tl.attenuator[0].port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${120}    vendor=topyoung
    log to console    PA ports ${port} to ${value}
    PA_.set_attenuation     port=${port}    value=${value}
    ${value_port1}   PA_.read_attenuation    port=${port}
    should be equal    ${value_port1}    ${value}


Gnb Reset Site
    [Arguments]   ${timeout}=300     ${connection}=GNB_OAM
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    coam.reset_site   timeout=${timeout}  connection=${connection}
    wait until keyword succeeds    1800      5    coam_gnb_classical.COAM Check GNB cell on air
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}


SCF delta recommission
    [Arguments]    ${delta_file}     ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    ${ignore_get_release_error}=${True}
    coam_gnb_classical.Connect to gnb coam via ssl     connection=${connection}   gnb_index=${gnb_index}
    ...    bts_host=${bts_host}   username=${username}    password=${password}   ignore_get_release_error=${ignore_get_release_error}
    run keyword and ignore error     csn.disconnect    connection=ASIK Master
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...                                   skip_parameter_relation_errors=${true}
    ...                                   should_activate=${true}
    ...                                   timeout=${600}
    ...                                   connection=GNB_OAM
    wait until keyword succeeds    1200      5    coam_gnb_classical.COAM Check GNB cell on air
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM


SCF commission
    [Arguments]    ${SCF}
    coam_gnb_classical.Connect to gnb coam via ssl
    ${result}    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${SCF}
    ...    is_pdl_checking_needed=${True}    timeout=900
    wait until keyword succeeds    1200      5    coam_gnb_classical.COAM Check GNB cell on air
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM



Start Tcpdump a1011
    ${eth_port}   Set Variable If
    ...   '${SMOD_NAME}'=='ASIK'   fp0
    ...   '${SMOD_NAME}'=='ASIB'   br1
    ...   '${SMOD_NAME}'=='ASIL'   br0
    ...   '${SMOD_NAME}'=='ASOE'   br0
    wireshark_for_5gClassicalBTS.Start to collect wireshark log for ASIB    options=-i ${eth_port}    name=trace

Stop tcpdump a1011
    [Arguments]    ${ute_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${ute_username}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${ute_password}=${tl.test_pc.default_ssh_connection_details.password}
    ...            ${alias}=ute
    ...            ${target_dir}=${OUTPUT DIR}

    wireshark_for_5gClassicalBTS.Stop collecting wireshark log    target_dir=${target_dir}    name=trace
    ${time}    DateTime.Get Current Date    result_format=timestamp
    ${updated_time}     Evaluate      $time.replace(' ','_').strip()
    ${updated_time}    Replace String      string=${updated_time}    search_for=:     replace_with=_
    ${pcap_file}    join path     ${target_dir}   trace/trace_${updated_time}.pcap
    csn.connect to    hostname=${ute_ip}    username=${ute_username}    password=${ute_password}    alias=${alias}
    csn.execute    command=mv ${target_dir}/trace/trace.pcap ${pcap_file}     connection=${alias}
    [return]    ${pcap_file}
    [Teardown]       Run Keyword And Ignore Error     csn.disconnect    connection=${alias}


verify DCAP syslog
    [Arguments]  ${log_files}=${all_log_file_paths}  ${log_path}=${extract_log_path}  ${allocatedSum_exp}=${2}  ${deallocatedSum_exp}=${1}
    ${allocatedSum}    Set Variable      ${0}
    ${deallocatedSum}    Set Variable      ${0}
    FOR    ${item}    IN     @{log_files}
        ${allocatedtmp}     run    command=cat ${log_path}/${item} |grep "allocated"|grep "current list size 1"|wc -l
        ${deallocatedtmp}     run    command=cat ${log_path}/${item} |grep "deallocated"|grep "current list size 0"|wc -l
        ${allocatedSum}                Evaluate             ${allocatedSum}+${allocatedtmp}
        ${deallocatedSum}                Evaluate             ${deallocatedSum}+${deallocatedtmp}
    END
    ${check_result}  Set Variable If  '${allocatedSum}'=='${allocatedSum_exp}' and '${deallocatedSum}'=='${deallocatedSum_exp}'  True  False
    Run Keyword If    ${check_result} == ${False}    FAIL




