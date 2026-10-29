*** Settings ***
Documentation     Auther: xiaodong.d.chen@nokia-sbell.com
...               Description: 679_common_keyword
Library           BuiltIn
Library           OperatingSystem
Library           Collections
Library           String
Library           TTI_trace_log_analysis.py
Library           TTI_trace_log_analysis.Event_trace_alaysis_679    WITH NAME    event_trace_analysis
Library           taf.rfrl.common_resources.python.SWConfig    WITH NAME    679swconfig
Library           taf.analyzer.pcap        WITH NAME    pcap
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          ../../5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/alarm_checking.robot
Resource          testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB005740/Resources/CB005740_common_keywords.robot
Library          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/spark_license.py


*** Variables ***
${tshark_path}    /usr/bin/tshark
${expression_cmas}    \"uldata_puschreceivereq\"
${command_template}    {tshark_path} -r {input_file} -X lua_script:{luashark_path} -Y ${expression_cmas} -T pdml > {output_file}
${rnti_2}    .//uldata_puschreceivereq[2]/UlData_PuschReceiveReq.grants_item_15.rnti
${rnti_4}    .//uldata_puschreceivereq[4]/UlData_PuschReceiveReq.grants_item_15.rnti
${rnti_5}    .//uldata_puschreceivereq[5]/UlData_PuschReceiveReq.grants_item_15.rnti

${numofPRB_1}    .//uldata_puschreceivereq[1]/UlData_PuschReceiveReq.grants_item_15.numOfPrb
${numofPRB_2}    .//uldata_puschreceivereq[2]/UlData_PuschReceiveReq.grants_item_15.numOfPrb
${numofPRB_3}    .//uldata_puschreceivereq[3]/UlData_PuschReceiveReq.grants_item_15.numOfPrb
${numofPRB_4}    .//uldata_puschreceivereq[4]/UlData_PuschReceiveReq.grants_item_15.numOfPrb

${pdsch_numofPrb}    DlData_PdschSendReq.grants_item_15.numOfPrb
${pdsch_slot}    DlData_PdschSendReq.PdschSendReq.slot
${pdsch_rnti}    DlData_PdschSendReq.PdschSendReq.rnti
${pdsch_sfn}     DlData_PdschSendReq.PdschSendReq.sfn

*** Keywords ***
Recover test ENV
    [Arguments]    ${apn_address}    ${ue_mode}=NSA    ${n}=10
    COAM Teardown gnb connections
    run keyword and ignore error    All UEs Stop traffic    ue_mode=${ue_mode}    apn_address=${apn_address}    j=${n}
    robot_common_operations.Common Case Teardown
    run keyword and ignore error     CI_interface.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot

679 Suite Setup
    [Arguments]    ${swconfig_modify}=${None}
    CI_interface.Common Suite Setup
    Backup and upload the new one based on default swconfig    swconfig_modify=${swconfig_modify}
    robot_common_operations.Common Suite Setup
    power_off_for_spark    host=${tl.ues[0].ssh_connection_details.addr}    ue_index=-1
    sleep    5s
    power_on_for_spark     host=${tl.ues[0].ssh_connection_details.addr}    ue_index=-1
    sleep    60s

679 Suite TearDown
    Recover eNB swconfig file

Backup and upload the new one based on default swconfig
    [Arguments]    ${swconfig_modify}    ${ASIK_MASTER_ALIAS}=ASIK Master
    ...            ${tmp_swconfig_path}=/home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T218/swconfig.txt
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    Run keyword if    ${swconfig_modify}!=${None}
    ...    Run keywords    Log to console    Swconfig file modification is needed.    AND
    ...    679swconfig.modify_swConfig_file   parametersList=${swconfig_modify}    filePath=${tmp_swconfig_path}
    679swconfig.upload_swConfig_file_to_asik_and_crasign    localFilePath=${tmp_swconfig_path}    asik_alias=${ASIK_MASTER_ALIAS}
    csn.disconnect    connection=${ASIK_MASTER_ALIAS}

Recover eNB swconfig file
    Connect to Common Unit Master
    679swconfig.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master
    csn.disconnect    connection=ASIK Master

Case Setup ready
    COAM Create log directory
    robot_common_operations.Common Case Setup

GNB is ready
    [Arguments]    ${679_default_scf}=${679_Korea_default_scf}    ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_100MHz}
    Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_SCF}    679_default_scf=${679_default_scf}
    COAM Wait for gnb ready and cell setup    timeout=15 min

Load Case SCF and Commission
    [Arguments]    ${default_scf}
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${default_scf}
    COAM Wait for gnb ready and cell setup    timeout=15 min

Load Case SCF and Commission new
    [Arguments]    ${default_scf}
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${default_scf}
    COAM Wait for gnb ready and cell setup    timeout=18 min    is_x2_check_from_gnb_needed=${False}

GNB is ready and UE attach
    [Arguments]    ${ue_num}    ${679_default_scf}=${679_Korea_default_scf}    ${e500_script_path}=${E500_5892_phase2_Muti_UEs}
    ...    ${BW}=80    ${type}=NSA    ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_Korea_conf_A}
    Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_SCF}    679_default_scf=${679_default_scf}
    COAM Wait for gnb ready and cell setup    timeout=15 min
    Synchron gNB and VIAVI
    Cobham UE attach    ue_num=${ue_num}    e500_script_path=${e500_script_path}    BW=${BW}    type=${type}

Modify SCF File and Commissioning
    [Arguments]    ${PARAMS_TO_MODIFY_SCF}    ${default_scf}
    ${new_scf_file}    COAM Modify scf file    scf_file_path=${default_scf}    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
    Connect to gnb coam via ssl
    Run keyword and ignore error    COAM Commission with scf file    scf_file_path=${new_scf_file}

Check throughput on gNB
    [Arguments]    ${direction}    ${throughput}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}
    ...    ${sample}=${10}    ${start_offset}=${3}    ${sleep_time}=${8}    ${cellid}=${EMPTY}    ${log_type}=Aasyslog    &{kwargs}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2Lo   log_name=data_${direction}.txt
    ${Tput_cell}    run keyword if    '${direction}' == 'dl'    Caculate DL throughput on gnb L2Lo with re
    ...                                                                                       dl_expect=${throughput}
    ...                                                                                       gnb_index=${gnb_index}
    ...                                                                                       du_index=${du_index}
    ...                                                                                       hw_slot=${hw_slot}
    ...                                                                                       sample=${sample}
    ...                                                                                       start_offset=${start_offset}
    ...                                                                                       sleep_time=${sleep_time}
    ...                                                                                       cellid=${cellid}
    ...                                                                                       log_type=${log_type}
    ...    ELSE IF    '${direction}' == 'ul'    Caculate UL throughput on gnb L2Lo with re    ul_expect=${throughput}
    ...                                                                                       gnb_index=${gnb_index}
    ...                                                                                       du_index=${du_index}
    ...                                                                                       hw_slot=${hw_slot}
    ...                                                                                       sample=${sample}
    ...                                                                                       start_offset=${start_offset}
    ...                                                                                       sleep_time=${sleep_time}
    ...                                                                                       cellid=${cellid}
    ...                                                                                       log_type=${log_type}
    [Return]    ${Tput_cell}
    [Teardown]    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}

###UE side spark&Dingli###
Check Tput for one UE
    [Arguments]     ${n}
    [Documentation]    check_tput
    ...                :param  n: The ue_index of Dingli
    log to console      "check traffic UE${n}"
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expected_Throughput_DL}
    ...                                                          ue_index=${n}
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${Expected_Throughput_UL}
    ...                                                          ue_index=${n}

All UEs Stop traffic
    [Arguments]     ${apn_address}    ${ue_mode}=NSA    ${j}=10
    [Documentation]    stop_DLUL_traffic
    FOR    ${i}    IN RANGE    ${j}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${i}    ue_mode=${ue_mode}
        ...                                                      apn_address=${apn_address}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${i}    ue_mode=${ue_mode}
        ...                                                      apn_address=${apn_address}
    END

All UEs Check Tput
    [Arguments]     ${num}=10
    FOR    ${i}    IN RANGE    ${num}
        Check Tput for one UE     n=${i}
    END

###BIP check point###
Check FDM schedlue two UEs in one slot on DL traffic
    [Arguments]    ${filename}=${bip_log_path}    ${crnti_expression}=${pdsch_rnti}
    Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
    ${PdschSendReq_sfn_list}=   cap.Get element value    element_expression=${pdsch_sfn}
    ${PdschSendReq_sfn_list}    Remove_repetition_list    ${PdschSendReq_sfn_list}
    ${length}=    get length     ${PdschSendReq_sfn_list}
    should be true    ${length}>0
    FOR    ${sfn}    IN    @{PdschSendReq_sfn_list}
        Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
        ${pdsch_slotlist}=   cap.Get Element Value    element_expression=${pdsch_slot}    condition_expression=${pdsch_sfn}==0x${sfn[2:]}${sfn[:2]}
        ${result}=    Get rnti based on sfn and slot    filename=${filename}    sfnn=${sfn[2:]}${sfn[:2]}
        ...                                             PdschSendReq_slot_list=@{pdsch_slotlist}    rnti_expression=${crnti_expression}
        Exit for loop if    ${result}>=2
    END

Get rnti based on sfn and slot
    [Arguments]    ${filename}    ${sfnn}    ${PdschSendReq_slot_list}    ${rnti_expression}
    FOR    ${slot}    IN    @{PdschSendReq_slot_list}
        Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
        ${PdschSendReq_rnti_list}=   cap.Get Element Value    element_expression=${rnti_expression}
        ...                                                   condition_expression=${pdsch_slot}==0x${slot} and ${pdsch_sfn}==0x${sfnn}
        ${num_UE}=      get length     ${PdschSendReq_rnti_list}
        Exit for loop if    ${num_UE}>=2
    END
    [Return]    ${num_UE}

Check FDM schedlue two UEs in one slot on UL traffic
    [Arguments]    ${filename}=${bip_log_path}    ${item}=${rnti_2}
    ${packets}    Load BIP Log with Template Command    pcap_file=${filename}    command_template=${command_template}
    ${value}    Get value from Bip Log by xpath    packets=${packets}    field_name=${item}
    ${length}=    get length    ${value}
    Should be true    ${length}>=1

Check ALL PRBs were schedlued in one slot on UL traffic
    [Arguments]    ${filename}=${bip_log_path}    ${allofPrb}=${217}
    ${packets}    Load BIP Log with Template Command    pcap_file=${filename}    command_template=${command_template}
    ${value1}    Get value from Bip Log by xpath    packets=${packets}    field_name=${numofPRB_1}
    ${value2}    Get value from Bip Log by xpath    packets=${packets}    field_name=${numofPRB_2}
    ${value3}    Get value from Bip Log by xpath    packets=${packets}    field_name=${numofPRB_3}
    ${value4}    Get value from Bip Log by xpath    packets=${packets}    field_name=${numofPRB_4}
    Run keyword if     '${value1}[0]' == '0x000000d9'
    ...     Run keyword and continue on failure    Get all PRBs of schedlued    a=${value1}[0]
    ...     ELSE    Get all PRBs of schedlued   a=${value1}[0]    b=${value2}[0]    c=${value3}[0]    d=${value4}[0]
    Should be True    ${sumofPrb} == ${allofPrb}

Get all PRBs of schedlued
    [Arguments]    ${a}    ${b}=${0}    ${c}=${0}    ${d}=${0}
    ${sumofPrb}    Evaluate    ${a}+${b}+${c}+${d}
    set test variable     ${sumofPrb}

Check ALL PRBs were schedlued in one slot on DL traffic
    [Arguments]    ${filename}=${bip_log_path}    ${prb_expression}=${pdsch_numofPrb}    ${allofPrb}=${217}
    Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
    ${PdschSendReq_sfn_list}=   cap.Get element value    element_expression=${pdsch_sfn}
    ${PdschSendReq_sfn_list}    Remove_repetition_list    ${PdschSendReq_sfn_list}
    ${length}=    get length     ${PdschSendReq_sfn_list}
    should be true    ${length}>0
    FOR    ${sfn}    IN    @{PdschSendReq_sfn_list}
        Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
        ${pdsch_slotlist}=   cap.Get Element Value    element_expression=${pdsch_slot}    condition_expression=${pdsch_sfn}==0x${sfn[2:]}${sfn[:2]}
        ${result}=    Get Prbs based on sfn and slot on DL    filename=${filename}    sfnn=${sfn[2:]}${sfn[:2]}
        ...                                                   PdschSendReq_slot_list=@{pdsch_slotlist}    prb_expression=${prb_expression}
        Get schedlued prb for one UE    prb_list=${result}
        Get all PRBs of schedlued   a=0x${prb_1[2:]}${prb_1[:2]}    b=0x${prb_2[2:]}${prb_2[:2]}
        ...                         c=0x${prb_3[2:]}${prb_3[:2]}    d=0x${prb_4[2:]}${prb_4[:2]}
        Exit for loop if    ${sumofPrb} == ${allofPrb}
    END

Get Prbs based on sfn and slot on DL
    [Arguments]    ${filename}    ${sfnn}    ${PdschSendReq_slot_list}    ${prb_expression}
    FOR    ${slot}    IN    @{PdschSendReq_slot_list}
        Read BIP Wireshark Log    cap_file=${filename}    filter=dldata_pdschsendreq
        ${PdschSendReq_prb_list}=   cap.Get Element Value    element_expression=${prb_expression}
        ...                                                  condition_expression=${pdsch_slot}==0x${slot} and ${pdsch_sfn}==0x${sfnn}
        ${num_UE}=      get length     ${PdschSendReq_prb_list}
        Exit for loop if    ${num_UE}>=2
    END
    [Return]    ${PdschSendReq_prb_list}

Get schedlued prb for one UE
    [Arguments]    ${prb_list}
    set test variable     ${prb_1}    ${prb_list}[0]
    set test variable     ${prb_2}    ${prb_list}[1]
    set test variable     ${prb_3}    ${prb_list}[2]
    set test variable     ${prb_4}    ${prb_list}[3]

Capturing TTI logs and verify throughput and get MCS
    [Arguments]    ${direction}    ${Expected_Dl_Tput}=80    ${Expected_Ul_Tput}=10
    Start TTI trace log capturing
    Sleep    5s
    Stop TTI trace log capturing
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
    Check throughput on gNB    direction=dl    throughput=${Expected_Dl_Tput}
    Check throughput on gNB    direction=ul    throughput=${Expected_Ul_Tput}
    Run keyword if    '${direction}'=='dl'
    ...    Run keyword and continue on failure    Get DL MCS based on event trace log    dict_event_trace_log=${dict_csv_file_path}
    ...    ELSE    Run keyword and continue on failure    Get UL MCS based on event trace log    dict_event_trace_log=${dict_csv_file_path}

Get DL MCS based on event trace log
    [Arguments]    ${dict_event_trace_log}    ${direction}=dl    ${program}=None
    @{get_usedMcs}    event_trace_analysis.get_average_used_mcs_for_ues    file_path=${dict_event_trace_log['DL']}    direction=${direction}
    ...    program=${program}
    Set test variable    @{rrmUsedMcs}    @{get_usedMcs}
    @{get_proposedMcs}    event_trace_analysis.get_average_proposed_mcs_for_ues    file_path=${dict_event_trace_log['DL']}    direction=${direction}
    ...    program=${program}
    Set test variable    @{rrmProposedMcs}    @{get_proposedMcs}

Get UL MCS based on event trace log
    [Arguments]    ${dict_event_trace_log}    ${direction}=ul    ${program}=None
    @{get_usedMcs}    event_trace_analysis.get_average_used_mcs_for_ues    file_path=${dict_event_trace_log['UL']}    direction=${direction}
    ...    program=${program}
    Set test variable    @{rrmUsedMcs}    @{get_usedMcs}
    @{get_proposedMcs}    event_trace_analysis.get_average_proposed_mcs_for_ues    file_path=${dict_event_trace_log['UL']}    direction=${direction}
    ...    program=${program}
    Set test variable    @{rrmProposedMcs}    @{get_proposedMcs}

Verify used MCS is ok than Proposed MCS
    [Arguments]    ${numofues}
    FOR    ${i}    IN RANGE    ${numofues}
        Should be True    ${rrmUsedMcs}[${i}] <= ${rrmProposedMcs}[${i}]
    END

Get BTS Counters from webUI
    [Arguments]    ${counter_id}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${counters}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}
    COAM selenium logout
    ${counters}    Get Dictionary Values    ${counters}
    [Return]    ${counters}
