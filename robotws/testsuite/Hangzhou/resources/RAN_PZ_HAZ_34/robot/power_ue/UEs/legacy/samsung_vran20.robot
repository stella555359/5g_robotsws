*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author: Ming Shi, Civen Chen
...              Contact: ming.shi@nokia-sbell.com, civen.chen@nokia-sbell.com
...              Already verified equipment: Samsung S10

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot

*** Variables ***

*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_index}=${0}    ${is_need_to_kill_vysor}=${True}    ${ui_version}=default    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    ...  :param  is_need_to_kill_vysor: flag to decide whether or not to kill vysor process
    Run keyword if    ${is_need_to_kill_vysor}    Kill vysor process    ue_index=${ue_index}
    Get product brand    ue_index=${ue_index}
    Get all pointer variable    ui_version=${ui_version}


################################## STEP2: UE ATTACH ##################################

UE Attach
    [Arguments]    ${ue_index}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${vdu_index}=0
    ...    ${log_type}=Aasyslog    ${attach_mode}=5G_NSA    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  gnb_index: The list index from tl.gnbs[], it will use the index gnb for attach check
    ...  :param  hwcheck_index: The list index with mapping as 0->ASIK 1->ABIL1 2->ABIL2 3ABIL3, it will use the
    ...          mapping HW to check the ue attach status
    Log    click Airplane mode switch to disable its function so that make UE attach
    ${handle}    vDU Begin K8s Log    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    Set test variable    ${handle}
	sleep  5s
	Preparation and execution for Commercial UE Attach    ue_index=${ue_index}
    sleep  5s
	${container_prefix}    vDU Get Container Name Prefix
    ${local_l2rt_file}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Run keyword if    '${attach_mode}' == '5G_NSA'    samsung_vran20.Check UE Attach NSA    local_l2rt_file=${local_l2rt_file}
    ...    ELSE    samsung_vran20.Check UE Attach SA    local_l2rt_file=${local_l2rt_file}

Check UE Attach NSA
    [Arguments]    ${local_l2rt_file}
    [Documentation]    check  UE Attach for NSA call test..
    ...  :param  local_l2rt_file: the attach log

    ${number_1}=  OperatingSystem.Run  cat ${local_l2rt_file} | grep 'UE attached' | wc -l
    run keyword and continue on failure   should be true   ${number_1}==1
    ${out}=  OperatingSystem.Run  cat ${local_l2rt_file} | grep 'UE attached'
    ${result}  Get Regexp Matches    ${out}    rnti=(\\d+)   1
    ${rnti_number}  Set Variable If  ${result}   ${result[0]}
    log to console   rnti_number is ${rnti_number}

    ${number_2}=  OperatingSystem.Run  cat ${local_l2rt_file} | grep 'UserDelete::execute: rnti=${rnti_number}' | wc -l
    run keyword and continue on failure   should be true   ${number_2}==0

Check UE Attach SA
    [Arguments]    ${local_l2rt_file}
    [Documentation]    check  UE Attach for SA call test.
    ...  :param  local_l2rt_file: the attach log
    ${number_1}=  OperatingSystem.Run  cat ${local_l2rt_file} | grep 'flow control starts' | wc -l
    run keyword and continue on failure   should be true   ${number_1}>=1
    ${out}=  OperatingSystem.Run  cat ${local_l2rt_file} | grep 'flow control starts'
    ${result}  Get Regexp Matches    ${out}    crnti (\\d+)   1
    ${rnti_number}  Set Variable If  ${result}   ${result[0]}
    log to console   rnti_number is ${rnti_number}

    ${number_2}=  OperatingSystem.Run  cat ${local_l2rt_file} | grep 'UserDelete::execute: crnti ${rnti_number}' | wc -l
    run keyword and continue on failure   should be true   ${number_2}==0
################################## STEP2.1: VERIFY ATTACH ##################################

################################## STEP3: START DATA TRANSFER ##################################
Start traffic
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1400B    ${iperf_type}=via_app
    ...            ${protocol}=udp    ${data_amount}=1M    ${process_num}=${5}
    ...            ${seg_size}=1180    ${window}=2M    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  iperf_type: Traffic use iperf command or iperf app type. E.G via_app/via_command
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Start DL traffic and check the TP on EPC    ue_index=${ue_index}
    ...                                                                                     time=${duration}
    ...                                                                                     interval=${interval}
    ...                                                                                     traffic=${throughput}
    ...                                                                                     buffer_size=${buffer_size}
    ...                                                                                     iperf_port=${port}
    ...                                                                                     protocol=${protocol}
    ...                                                                                     process_num=${process_num}
    ...                                                                                     seg_size=${seg_size}
    ...                                                                                     window=${window}
    ...    ELSE IF    '${direction}' == 'ul'    Start UL traffic and check the TP on Commercial    time=${duration}
    ...                                                                                            traffic=${throughput}
    ...                                                                                            ue_index=${ue_index}
    ...                                                                                            iperf_port=${port}
    ...                                                                                            iperf_type=${iperf_type}
    ...                                                                                            protocol=${protocol}
    ...                                                                                            process_num=${process_num}
    ...                                                                                            data_amount=${data_amount}
    ...                                                                                            buffer_size=${buffer_size}

################################## STEP4: CHECK THROUGHPUT ##################################

################################## STEP4.1: CHECK PEAK THROUGHPUT ##################################

################################## STEP4X COLLECT THROUGHPUT ##################################
Collect Tput
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${duration}=10min    ${ignore_time}=1min    ${type}=MCU
    ...            ${filter}=${EMPTY}    ${Teardown_after_finished}=${True}    ${upload_duration}=${True}    &{kwargs}
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...                As the moment traffic just started, throughput will be unstable (Acceptable and should be ignored)
    ...                Add Ignore time before and after throughput capturing.

    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    ...                :type two paramater can choose[mcu,rt],the syslog with CCS_MCU contain L2LO and CCS_RT contain L2HI.
    ...                :param duration: duration of log capturing. E.G 10min / 1hour
    ...                :param ignore_time: how long will be ignored before and after capturing. E.G 10min / 1hour

    ...                Should be used between Start traffic and Stop traffic!!!
    ...                E.G    Single direction
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic

    ...                E.G    BI-direction
    ...                Power_ue.Start Traffic     direction=ul
    ...                Power_ue.Start Traffic     direction=dl
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                Power_ue.Stop Traffic
    ...                The tput_log will contain both direction throughput data.

    ${log_path}    power_ue_throughput.__Standard Capturing Aasyslog Throughput
    ...            gnb_index=${gnb_index}    du_index=${du_index}
    ...            type=${type}    duration=${duration}    ignore_time=${ignore_time}
    ...            filter=${filter}    Teardown_after_finished=${Teardown_after_finished}
    ...            upload_duration=${upload_duration}
    [Return]    ${log_path}

################################## STEP4X Standard Check single direction throughput ##################################
Check Tput
    [Arguments]    ${direction}    ${log}    ${cells}    ${target_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${cell_indiv_tput}=${None}    ${actImgGeneration}=${True}
    ...            ${upload_tp}=${True}    &{kwargs}
    [Documentation]    validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...                Add both avraget throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...                :param direction: direction of the target traffic to be checked. E.G: UL/DL
    ...                :param log: log path of aasyslog throughput file.
    ...                            Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...                :param cells: list of target cells. E.G for 8CC CA traffic , all 8 cells IDs should be in list.
    ...                :param target_throughput: theory target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                                           Check_result > target_throughput * target_avg_percent
    ...                :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.

    ...                E.G    Single direction
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                ${list_of_cell_ids}    Create list  16385
    ...                power_ue.Check Tput    direction=DL    cells=${list_of_cell_ids}    log=${tput_log}
    ...                                                      target_throughput=2048  # unit is Mbps
    ...                E.G    Bi-direction with individual check.
    ...                Power_ue.Start Traffic
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                Power_ue.Stop Traffic
    ...                ${ul_cell}    Create list  16385
    ...                ${dl_cell}    Create list  16388
    ...                Power_ue.power_ue.Check Tput    direction=DL    cells=${ul_cell}    log=${tput_log}
    ...                                                target_throughput=2048  # unit is Mbps
    ...                Power_ue.power_ue.Check Tput    direction=DL    cells=${dl_cell}    log=${tput_log}
    ...                                                target_throughput=256  # unit is Mbps

    ${throughput_result}    power_ue_throughput.__Standard Check Aasyslog Throughput
    ...    direction=${direction}    log=${log}    cells=${cells}
    ...    target_throughput=${target_throughput}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    min_percent=${min_percent}
    ...    customized_log_name=${customized_log_name}    cell_indiv_tput=${cell_indiv_tput}
    ...    actImgGeneration=${actImgGeneration}    upload_tp=${upload_tp}
    [Return]    ${throughput_result}

################################## STEP4X CHECK BI DIRECTION THROUGHPUT ##################################
Check Bi Tput
    [Arguments]    ${log}    ${cells}    ${ultarget_throughput}    ${dltarget_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${actImgGeneration}=${True}    ${upload_tp}=${True}    &{kwargs}
    [Documentation]    validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...                Add both avraget throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...                :param log: log path of aasyslog throughput file.
    ...                            Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...                :param cells: list of target cells. E.G for 8CC CA traffic , all 8 cells IDs should be in list.
    ...                :param ultarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param dltarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                                           Check_result > target_throughput * target_avg_percent
    ...                :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.

    ...                E.G
    ...                Power_ue.Start Traffic
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                Power_ue.Stop Traffic
    ...                ${list_of_cell_ids}    Create list    16385    16388
    ...                Power_ue.Check Bi Tput    cells=${list_of_cell_ids}    log=${tput_log}
    ...                                          ultarget_throughput=2048    dltarget_throughput=256   # unit is Mbps

    ${throughput_result}    power_ue_throughput.__Standard Check Bi Aasyslog Throughput
    ...    log=${log}    cells=${cells}    min_percent=${min_percent}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
    ...    customized_log_name=${customized_log_name}
    ...    actImgGeneration=${actImgGeneration}    upload_tp=${upload_tp}
    [Return]    ${throughput_result}

################################## STEP5: STOP DATA TRANSFER ##################################
Stop traffic
    [Arguments]    ${direction}    ${ue_index}    ${iperf_port}=default    ${iperf_type}=via_app    ${protocol}=udp    &{kwargs}
    [Documentation]    Stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  iperf_type: Traffic use iperf command or iperf app type. E.G via_app/via_command
    #${port}    set variable if   '${iperf_port}' == 'default'    ${tl.ues[${ue_index}].iperf_details.port}    ${iperf_port}
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Stop DL traffic and check the TP on EPC    ue_index=${ue_index}
    ...    DL_port=${port}    protocol=${protocol}
    ...    ELSE IF    '${direction}' == 'ul'    Stop UL traffic and check the TP on EPC    ue_index=${ue_index}
    ...    UL_port=${port}    iperf_type=${iperf_type}    protocol=${protocol}

################################## STEP6: UE DETACH ##################################
UE Detach
    [Arguments]    ${ue_index}    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for detach
    Commercial UE detach    ue_index=${ue_index}
