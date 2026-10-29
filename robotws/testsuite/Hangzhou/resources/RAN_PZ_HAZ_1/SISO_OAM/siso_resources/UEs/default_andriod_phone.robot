*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              author: Zhou Qiang
...              Contact: qiang.1.zhou@nokia-sbell.com
...              Verified equipment: default ue

Resource   ../../../../resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
#Resource     ../ue.robot


*** Variables ***
${iperf_server_ip}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
${iperf_server_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
${iperf_server_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}
*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_index}=${0}    ${reset_sol}=${True}    &{kwargs}
    [Documentation]    This kw is used to Prepare UE for inseego
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ${ue0_type} | translate_power_ue_type_from_testline | ue_index=${0} |
    ...    | set test variable | ${ue0_type} |
    ...    | inseego.Prepare UE | ${ue0_type} | ue_index=${0}  |
    ...
    Log    ${reset_sol}
    Reserve ue with index    ue_index=${ue_index}
    Run Keyword If    '${reboot_ue}'=='${True}'  UE soft reboot    ue_index=${ue_index}

################################## STEP2: UE ATTACH ##################################
UE Attach
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${du_index}=${0}
    ...    ${log_type}=Aasyslog    &{kwargs}


    Log    ${gnb_index}
    Log    ${hwcheck_index}
    Log    ${du_index}
    Log    ${log_type}
    Run Keyword And Ignore Error    Ue detach with index    ue_index=${ue_index}
    Wait Until Keyword Succeeds    8 min    10 sec    Ue attach with index    ue_index=${ue_index}


################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    ${5Grach_ed}    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=${0}
    ...            ${4G_check}=True    ${5Gstatus}=PASS    &{kwargs}

    Log    ${5Grach_ed}
    Log    ${gnb_index}
    Log    ${du_index}
    Log    ${4G_check}
    Log    ${5Gstatus}
    ${ue_ip}    ute_ue.Get Ue Info     UE_${ue_index}    IP
    ${cell_id}    ute_ue.Get Ue Info     UE_${ue_index}    CELL_ID
    #Should Contain    ${UE_IP}    172.    msg=attach failed
    Set Suite Variable    ${ue_ip}

################################## STEP3: START DATA TRANSFER ##################################
Start traffic
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1400B    ${iperf_type}=via_command
    ...            ${protocol}=udp    ${data_amount}=1M    ${process_num}=${5}
    ...            ${seg_size}=1180    ${window}=2M    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  iperf_type: Traffic use iperf command or iperf app type. E.G via_app/via_command
    Log    ${interval}
    Log    ${iperf_type}
    Log    ${process_num}
    Log    ${seg_size}
    Log    ${window}
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22

    ${ue_ip}    ute_ue.Get Ue Info     UE_${ue_index}    IP

#    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
#    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
#    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}

    Run Keyword If    '${direction}' == 'dl'    siso_data.Start UDP Iperf Client    ${iperf_pc_info}
    ...                                                                                     ${ue_ip}
    ...                                                                                     ${iperf_port}
    ...                                                                                     band_width=${throughput}
    ...                                                                                     duration=${duration}
    ...                                                                                     ttl=64
    ...                                                                                     alias=dl_client
    ...    ELSE IF    '${direction}' == 'ul'    Start UL traffic and check the TP on Commercial    time=${duration}
    ...                                                                                            traffic=${throughput}
    ...                                                                                            ue_index=${ue_index}
    ...                                                                                            iperf_port=${iperf_port}
    ...                                                                                            iperf_type=via_command
    ...                                                                                             protocol=${protocol}
    ...                                                                                             data_amount=${data_amount}
    ...                                                                                             buffer_size=${buffer_size}

################################## STEP4: CHECK THROUGHPUT ##################################
Check throughput
    [Arguments]    ${direction}    ${throughput}    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}
    ...    ${sample}=${10}    ${start_offset}=${3}    ${sleep_time}=${5}    ${cellid}=${EMPTY}    ${log_type}=Aasyslog    &{kwargs}
    [Documentation]    Check throughput from started traffic.
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
    Log    ${ue_index}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2Lo   log_name=data_${direction}.txt
    run keyword if    '${direction}' == 'dl'    Caculate DL throughput on gnb L2Lo with re    dl_expect=${throughput}
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
    Log    ${total_time}
    Log    ${interval}
    Log    ${duration_time_for_once}
    Log    ${acceptable_tput_percentage}
    Log    ${nr_cell_index}
    Log    ${du_index}
    Log    ${gnb_ssl_connection}
    Log    ${is_need_to_capture_log}
    log to console      Step4: Check throughput
    ${handle}    vDU Begin K8s Log    ${current_gnb_index}    ${currernt_vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
    sleep    80s
    ${log}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Set Suite Variable    ${log}

    ${all_tp}    Run keyword and continue on failure    Check Bi Tput     log=${log}     cells=${cells}
    ...    ultarget_throughput=${theory_ul_peak}    dltarget_throughput=${theory_dl_peak}
    ...    target_avg_percent=0.95
    Set Test Variable    ${all_tp}
    ${real_dl_tput}    Set Variable    ${all_tp[1][0]['average']}
    ${real_ul_tput}    Set Variable    ${all_tp[1][0]['average']}
    Run keyword and continue on failure    should be true    ${real_dl_tput}>=${exp_dl}
    Run keyword and continue on failure    should be true    ${real_ul_tput}>=${exp_ul}

    [Return]    ${real_dl_tput}    ${real_ul_tput}

################################## STEP4X COLLECT THROUGHPUT ##################################
Collect Tput
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${duration}=10min    ${ignore_time}=1min    ${type}=MCU
    ...            ${filter}=${EMPTY}    ${Teardown_after_finished}=${True}    &{kwargs}
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
    [Return]    ${log_path}

################################## STEP4X Standard Check single direction throughput ##################################
Check Tput
    [Arguments]    ${direction}    ${log}    ${cells}    ${target_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${cell_indiv_tput}=${None}    ${actImgGeneration}=${True}
    ...            &{kwargs}
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
    ...    actImgGeneration=${actImgGeneration}
    [Return]    ${throughput_result}

################################## STEP4X CHECK BI DIRECTION THROUGHPUT ##################################
Check Bi Tput
    [Arguments]    ${log}    ${cells}    ${ultarget_throughput}    ${dltarget_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${actImgGeneration}=${True}    &{kwargs}
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
    ...    actImgGeneration=${actImgGeneration}
    [Return]    ${throughput_result}

################################## STEP5: STOP DATA TRANSFER ##################################
Stop traffic
    [Arguments]    ${direction}    ${ue_index}    ${iperf_port}=default    ${iperf_type}=via_app    ${protocol}=udp    &{kwargs}
    [Documentation]    Stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  iperf_type: Traffic use iperf command or iperf app type. E.G via_app/via_command
    ${iperf_pc_info}=    Create List    ${iperf_server_ip}    ${iperf_server_username}
    ...                                 ${iperf_server_password}    22

#    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
#    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
#    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}

    Run Keyword If    '${direction}' == 'dl'    siso_data.Stop Iperf Client    ${iperf_pc_info}    ${iperf_port}
    ...    alias=dl_client
    ...    ELSE IF    '${direction}' == 'ul'    Stop UL traffic and check the TP on EPC    ue_index=${ue_index}
    ...    UL_port=${iperf_port}    iperf_type=${iperf_type}    protocol=${protocol}

################################## STEP6: UE DETACH ##################################
UE Detach
    [Arguments]    ${ue_index}    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for detach
    Ue detach with index    ue_index=${ue_index}

