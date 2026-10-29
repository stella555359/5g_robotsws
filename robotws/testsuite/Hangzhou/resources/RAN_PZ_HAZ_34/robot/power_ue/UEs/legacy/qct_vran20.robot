*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author: Andy Cheng, Civen Chen
...              Contact: huimin.1.cheng@nokia-sbell.com, civen.chen@nokia-sbell.com
...              Already verified equipment: DX50 DX55

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot

*** Variables ***

*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_index}=${0}    ${capatibility_index}=${0}    ${reset_sol}=none    ${detach_request}=${true}    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    ...  :param  capatibility_index: The list index from ue.capabilities[], will use the index capability for reserve
    ...  :param reset_sol has four choose (none, pc_reset, pb_reset, ue_reboot):
    ...    none with default choose mean with no action when ue connect is missing.
    ...    pc_reset mean if ue connection nok, will try to reset the control pc to recover.
    ...    pb_reset mean if ue connection nok, will try to reset the ue with ue PB power off and on.
    ...    ue_reboot mean force to let ue with adb reboot before attach.
    ...  :param detach_request is the choose with ue with detach status contain in prepare progress.
    Prepare for Android UE    ue_index=${ue_index}    cap_index=${capatibility_index}    reset_sol=${reset_sol}
    ...                       detach_request=${detach_request}

################################## STEP2: UE ATTACH ##################################
UE Attach
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${vdu_index}=0
    ...    ${log_type}=Aasyslog    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  With Aasyslog catch normally please confirm the RD parameter 0x1003F=1;0x10040=1 have been setted in swconfig
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  gnb_index: The list index from tl.gnbs[], it will use the index gnb for attach check
    ...  :param  hwcheck_index: The list index with mapping as 0->ASIK 1->ABIL1 2->ABIL2 3ABIL3, it will use the
    ...          mapping HW to check the ue attach status
    ...  add turn mobile data on to make sure the mobile data is turned on.
    Log    click Airplane mode switch to disable its function so that make UE attach
    ${handle}    vDU Begin K8s Log    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    Set test variable    ${handle}
	sleep  5s
    ${attach_status}    run keyword and return status  Ue attach with index    ue_index=${ue_index}
    run keyword and continue on failure    turn mobile data on    alias=UE_${ue_index}
    run keyword if     '${attach_status}'=='False'    run keywords    Ue reattach with index    ue_index=${ue_index}    AND
    ...    run keyword and continue on failure    turn mobile data on    alias=UE_${ue_index}
    sleep  5s
    #${container_prefix}    vDU Get Container Name Prefix
    #${local_l2rt_file}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    #...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    #Run keyword if    '${attach_mode}' == '5G_NSA'    Check UE Attach NSA    local_l2rt_file=${local_l2rt_file}
    #...    ELSE    Check UE Attach SA    local_l2rt_file=${local_l2rt_file}

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
    [Arguments]    ${direction}    ${throughput}    ${duration}    ${iperf_port}    ${ue_index}=${0}
    ...            ${cap_index}=${0}    ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp    ${process_num}=${5}
    ...            ${seg_size}=${1180}    ${window}=2M    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer, like 10M
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  iperf_port: port number used for traffic start via iperf.
    ...  :param  process_num: the number of process which are used for tcp data transfer, the more the better.
    ...  :param  window: tcp window size. eg, default value is 2M
    ${ue_addr} =    Get the UE Ip address    ue_index=${ue_index}
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    wait until keyword succeeds    3x    10s    Start DL traffic via iperf on Appserver
    ...                                                                                    ue_addr=${ue_addr}
    ...                                                                                    dl_time=${duration}
    ...                                                                                    dl_port=${port}
    ...                                                                                    dl_throughput=${throughput}
    ...                                                                                    dl_length=${buffer_size}
    ...                                                                                    appserver=${appserver}
    ...                                                                                    protocol=${protocol}
    ...                                                                                    ue_index=${ue_index}
    ...                                                                                    process_num=${process_num}
    ...                                                                                    seg_size=${seg_size}
    ...                                                                                    window=${window}
    ...    ELSE IF    '${direction}' == 'ul'    wait until keyword succeeds    3x    10s    Start UL traffic via iperf from andriod UE
    ...                                                                                       ue_index=${ue_index}
    ...                                                                                       ul_time=${duration}
    ...                                                                                       ul_port=${port}
    ...                                                                                       ul_throughput=${throughput}
    ...                                                                                       ul_length=${buffer_size}
    ...                                                                                       appserver=${appserver}
    ...                                                                                       protocol=${protocol}
    ...                                                                                       process_num=${process_num}
    ...                                                                                       window=${window}
################################## STEP4: CHECK THROUGHPUT ##################################
Check throughput
    [Arguments]    ${direction}    ${throughput}    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}
    ...    ${sample}=${10}    ${start_offset}=${3}    ${sleep_time}=${5}    ${cellid}=${EMPTY}    ${log_type}=Aasyslog    &{kwargs}
    [Documentation]    Check throughput from started traffic.
    ...  With Aasyslog catch normally please confirm the RD parameter 0x1003F=1;0x10040=1 have been setted in swconfig
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  index, throughput (M): Throughput of new data transfer , like 10 which means 10M
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for check throughput.
    ...  :param  du_index: this du index can distinguish left or right of AMIA, 0 meas left, 1 means right
    ...  :param  hw_slot: abil index, In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...  :param  sample: how many sample cut in l2lo for average caculate.
    ...  :param  start_offset: start from which line to caculate the throughput.
    ...  :param  sleep_time: with gnb l2lo log print is normal with 1 second/1 time, this default value is fine,
    ...           but if the log print is 5/10 second/1 time . this value need change to large one.
    ...  :param  cellid: with just 1 cell, use the default empty value, if has mutli cell, need add the cellid for each cell check.
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2Lo   log_name=data_${direction}.txt
    ${output}    run keyword if    '${direction}' == 'dl'    Caculate DL throughput on gnb L2Lo with re    dl_expect=${throughput}
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
    [Return]    ${output}
    [Teardown]    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}

################################## STEP4.1: CHECK PEAK THROUGHPUT ##################################
Check peak throughput
    [Arguments]    ${theory_dl_peak}    ${theory_ul_peak}
    ...            ${total_time}=60    ${interval}=10s    ${duration_time_for_once}=200s
    ...            ${acceptable_tput_percentage}=0.95    ${nr_cell_index}=1    ${du_index}=0
    ...            ${gnb_ssl_connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
    [Documentation]    Check throughput from started traffic.
    ...  :param  theory_ul_peak: The theory peak value of UL traffic. Unit is Mbits/sec. E.G 11.8
    ...  :param  theory_dl_peak: The theory peak value of DL traffic. Unit is Mbits/sec  E.G 262.0
    ...  :param  total_time: is the duration time in which the throughput need to be checked. The time unit is second.
    ...  :param  interval: refers to the sleep time between tput checking, can be mins, hours, or secs
    ...  :param  duration_time_for_once: is the duration time for calculating average tput in one capturing
    ...  :param  acceptable_tput_percentage: The acceptable tput percentage of throughput.
    ...                                      Will check if Throughput > theory * acceptable_tput_percentage.
    ...  :param  is_need_to_capture_log: will capture event trace log if set to ${True}
    ${real_dl_tput}    ${real_ul_tput}    Verify tput from GNB within duration and record data to csv
    ...                                   total_time=${total_time}
    ...                                   exp_dl_tput=${theory_dl_peak}
    ...                                   exp_ul_tput=${theory_ul_peak}
    ...                                   interval=${interval}
    ...                                   duration_time_for_once=${duration_time_for_once}
    ...                                   nr_cell_index=${nr_cell_index}
    ...                                   tput_percentage=${acceptable_tput_percentage}
    ...                                   is_need_to_capture_log=${is_need_to_capture_log}
    ...                                   du_index=${du_index}
    ...                                   gnb_ssl_connection=${gnb_ssl_connection}
    [Return]    ${real_dl_tput}    ${real_ul_tput}

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
    [Arguments]    ${direction}    ${iperf_port}    ${ue_index}=${0}    ${appserver}=APPserver    &{kwargs}
    [Documentation]    Stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Close the iperf process on APPserver    port=${port}    appserver=${appserver}
    ...    ELSE IF    '${direction}' == 'ul'    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${port}


################################## STEP6: UE DETACH ##################################
UE Detach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for detach
    Ue detach with index    ue_index=${ue_index}
