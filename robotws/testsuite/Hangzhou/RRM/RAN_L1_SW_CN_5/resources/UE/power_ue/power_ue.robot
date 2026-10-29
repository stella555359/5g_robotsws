*** Settings ***
Documentation     UE common keyword for normal L3 call, support to control Multi UE also.
...               Please do not modify the file without notification to author
...               Author: Civen Chen
...               Contact: civen.chen@nokia-sbell.com
Resource          ./UEs/qct_dx50.robot
Resource          ./Power_ue_supports/power_ue_log.robot
Resource          ./Power_ue_supports/power_ue_throughput.robot

*** Variables ***
${prepare_use}    ${False}
${attach_use}     ${False}
${start_traffic_use}    ${False}
${check_tput_use}    ${False}
${stop_traffic_use}    ${False}
${detach_use}     ${False}

*** Keywords ***
power_ue.Prepare UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${capatibility_index}=${0}    ${reset_sol}=none
    ...    ${detach_request}=${true}
    ...    ${ui_version}=default
    [Documentation]    Prepare UE for L3 call test.
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / huawei_sigspark
    ...    :param ue_index: The list index from tl.ues[], it will use the index UE for reserve
    ...    :param ue_alias: <str> store ue by ue_alias
    ...    :param capatibility_index: The list index from ue.capabilities[], will use the index capability for reserve
    ...    :param reset_sol for qctdx50 ue has three choose (none, pc_reset, pb_reset):
    ...    none with default choose mean with no action when ue connect is missing.
    ...    pc_reset mean if ue connection nok, will try to reset the control pc to recover.
    ...    pb_reset mean if ue connection nok, will try to reset the ue with ue PB power off and on.
    ...    :param detach_request for qctdx50 ue has the choose for ue with detach status contain in prepare progress.
    ################################## STEP1: Prepare UE for L3 call ##################################
    ${output}    run keyword    ${ue_type}.Prepare Ue    ue_index=${ue_index}    capatibility_index=${capatibility_index}
    ...    ue_alias=${ue_alias}    reset_sol=${reset_sol}
    ...    detach_request=${detach_request}    ui_version=${ui_version}
    ################################## STEP2: UE ATTACH ##################################
    [Return]    ${output}

power_ue.UE Attach
    [Arguments]    ${ue_type}    ${attach_mode}=5G_SA    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=0    ${hwcheck_index}=${1}
    ...    ${ue_alias}=UE_${ue_index}    ${abil_index}=${1}    ${log_type}=Aasyslog    ${interval}=${1}    ${power_reset}=False    ${retry}=${2}
    [Documentation]    Attach UE for L3 call test.
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / huawei_sigspark
    ...    :param ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...    :param ue_alias: <str> store ue by ue_alias
    ...    :param power_reset: <str> used to choose whether use power on or not in huawei spark,
    ...    if it set to true, ue attach will use power on
    ...    :param retry: retry times for ue attach.
    ${output}    run keyword    ${ue_type}.UE Attach    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...    hwcheck_index=${hwcheck_index}    ue_alias=${ue_alias}
    ...    abil_index=${abil_index}    du_index=${du_index}    log_type=${log_type}    attach_mode=${attach_mode}
    ...    interval=${interval}    power_reset=${power_reset}
    ...    retry=${retry}
    ################################## STEP2.1: VERIFY ATTACH ##################################
    [Return]    ${output}

power_ue.Verify attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${abil_index}=${1}    ${4G_check}=True
    ...    ${5Grach_ed}=${0}    ${5Gstatus}=PASS
    [Documentation]    Verify attach result when plugin self verify not suffient
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / huawei_sigspark
    ...    :param ue_index: The list index from tl.ues[], it will use the index UE for verify attach
    ${output}    run keyword    ${ue_type}.Verify attach    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...    4G_check=${4G_check}    5Grach_ed=${5Grach_ed}
    ...    5Gstatus=${5Gstatus}    abil_index=${abil_index}    du_index=${du_index}
    ################################## STEP2.2: Create additional PDN ##################################
    [Return]    ${output}

power_ue.Create additional PDN
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    [Documentation]    Create additional PDN, needed from MTK APOLO.
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / huawei_sigspark
    ...    :param ue_index: The list index from tl.ues[], it will use the index UE for verify attach
    ${output}    run keyword    ${ue_type}.Create additional PDN    ue_index=${ue_index}
    ################################## STEP3: START DATA TRANSFER ##################################
    [Return]    ${output}

power_ue.Start traffic
    [Arguments]    ${ue_type}    ${direction}    ${throughput}    ${apn_address}=wap1nokiacom    ${duration}=10    ${protocol}=udp
    ...    ${ue_index}=${0}    ${ue_mode}=SA    ${cap_index}=${0}    ${dt_index}=${0}    ${iperf_port}=default    ${interval}=1
    ...    ${buffer_size}=1400B    ${dt_name}=DT_1    ${ue_alias}=UE_${ue_index}    ${multidrb_QoS_dest}=${None}
    ...    ${appserver}=APPserver    ${iperf_type}=via_app
    ...    ${data_amount}=1M    ${connection_type}=app    ${process_num}=${5}    ${seg_size}=1180    ${window}=2M
    [Documentation]    Start data transfer for L3 call test.
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / huawei_sigspark
    ...    :param direction: The traffic direction, ul or dl.
    ...    :param duration: Duration of traffic
    ...    :param throughput: Throughput of new data transfer
    ...    :param protocal: Traffic protocal type. E.G udp/tcp
    ...    :param ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...    :param dt_index: The new data transfer index alias.
    ...    :param iperf_port: port number used for traffic start via iperf.
    ...    :param dt_name: alias name for created data transfer.
    ...    :param ue_alias: <str> store ue by ue_alias
    ...    :param multidrb_QoS_dest: <optional> default None,
    ...    multidrb_QoS_dest is a optional input,
    ...    Setup UL traffic dest ip address for multidrb testing,
    ...    Normal UL traffic ignore this param.
    ...    :param cap_index: The list index from ue.capabilities[], will use the index capability for reserve.
    ...    :param iperf_type: Traffic use iperf command or iperf app type.
    ...    :param connection_type: net connection type, "app" or "current", "app" default.
    ...    :param process_num: the number of process which are used for tcp data transfer, the more the better.
    ...    :param seg_size: set TCP maximum segment size (MTU - 40 bytes)
    ...    :param window: set TCP window size. eg, default value is 2M
    ${direction}=    Convert To Lowercase    ${direction}
    ${output}    run keyword    ${ue_type}.Start traffic    direction=${direction}    ue_index=${ue_index}    dt_index=${dt_index}
    ...    duration=${duration}
    ...    throughput=${throughput}    protocol=${protocol}    iperf_port=${iperf_port}    interval=${interval}
    ...    buffer_size=${buffer_size}    dt_name=${dt_name}
    ...    ue_alias=${ue_alias}    multidrb_QoS_dest=${multidrb_QoS_dest}    cap_index=${cap_index}    appserver=${appserver}
    ...    iperf_type=${iperf_type}    data_amount=${data_amount}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}    connection_type=${connection_type}    process_num=${process_num}
    ...    seg_size=${seg_size}    window=${window}
    ################################## STEP4: CHECK THROUGHPUT ##################################
    [Return]    ${output}

power_ue.Check throughput
    [Arguments]    ${ue_type}    ${direction}    ${throughput}    ${deviation}=10    ${ue_index}=${0}    ${dt_index}=${0}
    ...    ${ue_alias}=UE_${ue_index}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}    ${sample}=${10}    ${start_offset}=${3}
    ...    ${sleep_time}=${5}    ${cellid}=${EMPTY}    ${log_type}=Aasyslog
    [Documentation]    Check throughput from started traffic.
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / huawei_sigspark
    ...    :param direction: The traffic direction, ul or dl.
    ...    :param throughput: Throughput of new data transfer
    ...    :param deviation: Aceptable deviation of target throughput
    ...    :param ue_index: The list index from tl.ues[], it will use the index UE for check throughput.
    ...    :param dt_index: The new data transfer index alias.
    ...    :param ue_alias: <str> store ue by ue_alias
    ...    :param du_index: this du index can distinguish left or right of AMIA, 0 meas left, 1 means right
    ...    :param hw_slot: abil index, In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...    :param sample: how many sample cut in l2lo for average caculate.
    ...    :param start_offset: start from which line to caculate the throughput.
    ...    :param sleep_time: with gnb l2lo log print is normal with 1 second/1 time, this default value is fine.
    ...    :param cellid: with just 1 cell, use the default empty value, if has mutli cell, need add the cellid for each cell check.
    ${output}    run keyword    ${ue_type}.Check throughput    direction=${direction.lower()}    ue_index=${ue_index}
    ...    dt_index=${dt_index}    throughput=${throughput}
    ...    deviation=${deviation}    ue_alias=${ue_alias}    gnb_index=${gnb_index}    du_index=${du_index}    hw_slot=${hw_slot}    sample=${sample}
    ...    start_offset=${start_offset}    sleep_time=${sleep_time}    cellid=${cellid}    log_type=${log_type}
    ################################## STEP4.1: CHECK PEAK THROUGHPUT ##################################
    [Return]    ${output}

power_ue.Check peak throughput
    [Arguments]    ${ue_type}    ${theory_dl_peak}    ${theory_ul_peak}    ${total_time}=60    ${interval}=10s    ${duration_time_for_once}=200s
    ...    ${acceptable_tput_percentage}=0.95    ${nr_cell_index}=1    ${du_index}=0    ${gnb_ssl_connection}=GNB_OAM
    ...    ${is_need_to_capture_log}=${False}
    [Documentation]    Check throughput from started traffic.
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / qct_dx50
    ...    :param theory_ul_peak: The theory peak value of UL traffic. Unit is Mbits/sec. E.G 11.8
    ...    :param theory_dl_peak: The theory peak value of DL traffic. Unit is Mbits/sec E.G 262.0
    ...    :param total_time: is the duration time in which the throughput need to be checked. The time unit is second.
    ...    :param interval: refers to the sleep time between tput checking, can be mins, hours, or secs
    ...    :param duration_time_for_once: is the duration time for calculating average tput in one capturing
    ...    :param acceptable_tput_percentage: The acceptable tput percentage of throughput.
    ...    Will check if Throughput > theory * acceptable_tput_percentage.
    ...    :param is_need_to_capture_log: will capture event trace log if set to ${True}
    ${dl_tput}    ${ul_tput}    run keyword    ${ue_type}.Check peak throughput    total_time=${total_time}
    ...    theory_dl_peak=${theory_dl_peak}    theory_ul_peak=${theory_ul_peak}
    ...    interval=${interval}    duration_time_for_once=${duration_time_for_once}    nr_cell_index=${nr_cell_index}
    ...    acceptable_tput_percentage=${acceptable_tput_percentage}    is_need_to_capture_log=${is_need_to_capture_log}    du_index=${du_index}
    ...    gnb_ssl_connection=${gnb_ssl_connection}
    run keyword and ignore error    power_ue.Logging peak information    dl_tput=${dl_tput}    ul_tput=${ul_tput}
    ...    theory_dl_peak=${theory_dl_peak}    theory_ul_peak=${theory_ul_peak}    cell_id=${nr_cell_index}
    ...    acceptable_tput_percentage=${acceptable_tput_percentage}
    ################################## STEP4X COLLECT THROUGHPUT ##################################
    [Return]    ${dl_tput}    ${ul_tput}

power_ue.Collect Tput
    [Arguments]    ${ue_type}    ${gnb_index}=0    ${du_index}=0    ${duration}=10min    ${ignore_time}=1min    ${type}=MCU
    ...    ${filter}=${EMPTY}
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...    As the moment traffic just started, throughput will be unstable (Acceptable and should be ignored)
    ...    Add Ignore time before and after throughput capturing.
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / huawei_sigspark
    ...    :param gnb_index: the gnb index which config in tl.gnbs[].
    ...    :param du_index: the du index mean the left or right board in AMIA
    ...    :param type: two paramater can choose[mcu,rt],the syslog with CCS_MCU contain L2LO and CCS_RT contain L2HI.
    ...    :param duration: duration of log capturing. E.G 10min / 1hour
    ...    :param ignore_time: how long will be ignored before and after capturing. E.G 10min / 1hour
    ...    Should be used between Start traffic and Stop traffic!!!
    ...    E.G Single direction
    ...    Power_ue.Start Traffic
    ...    ${tput_log} power_ue.Collect Tput
    ...    Power_ue.Stop Traffic
    ...    E.G BI-direction
    ...    Power_ue.Start Traffic direction=ul
    ...    Power_ue.Start Traffic direction=dl
    ...    ${tput_log} power_ue.Collect Tput
    ...    Power_ue.Stop Traffic
    ...    Power_ue.Stop Traffic
    ...    The tput_log will contain both direction throughput data.
    ${log_path}    run keyword    ${ue_type}.Collect Tput    gnb_index=${gnb_index}    du_index=${du_index}    type=${type}    duration=${duration}
    ...    ignore_time=${ignore_time}    filter=${filter}
    ################################## STEP4X Standard Check single direction throughput ##################################
    [Return]    ${log_path}

power_ue.Check Tput
    [Arguments]    ${ue_type}    ${direction}    ${log}    ${cells}    ${target_throughput}    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    [Documentation]    validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...    # unit is Mbps    # unit is Mbps    # unit is Mbps    # if you need to use the value.
    ...    Add both avraget throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / huawei_sigspark
    ...    :param direction: direction of the target traffic to be checked. E.G: UL/DL
    ...    :param log: log path of aasyslog throughput file.
    ...    Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...    :param cells: list of target cells. E.G for 8CC CA traffic , all 8 cells IDs should be in list.
    ...    :param target_throughput: theory target throughput. Unit in Mbps.
    ...    Will be used in validation with target_avg_percent and minimum percent.
    ...    :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...    Check_result > target_throughput * target_avg_percent
    ...    :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.
    ...    E.G Single direction
    ...    Power_ue.Start Traffic
    ...    ${tput_log} power_ue.Collect Tput
    ...    Power_ue.Stop Traffic
    ...    ${list_of_cell_ids} Create list 16385
    ...    power_ue.Check Tput direction=DL cells=${list_of_cell_ids} log=${tput_log}
    ...    target_throughput=2048
    ...    E.G Bi-direction with individual check.
    ...    Power_ue.Start Traffic
    ...    Power_ue.Start Traffic
    ...    ${tput_log} power_ue.Collect Tput
    ...    Power_ue.Stop Traffic
    ...    Power_ue.Stop Traffic
    ...    ${ul_cell} Create list 16385
    ...    ${dl_cell} Create list 16388
    ...    power_ue.Check Tput direction=DL cells=${ul_cell} log=${tput_log}
    ...    target_throughput=2048
    ...    power_ue.Check Tput direction=UL cells=${dl_cell} log=${tput_log}
    ...    target_throughput=256
    ...
    ...    ${ul} Power_ue.Check Tput xxxxxxxxxxxxxxxxxx
    ${output}    run keyword    ${ue_type}.Check Tput    direction=${direction}    log=${log}    cells=${cells}
    ...    target_throughput=${target_throughput}
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}    min_percent=${min_percent}
    ################################## STEP4X CHECK BI DIRECTION THROUGHPUT ##################################
    [Return]    ${output}

power_ue.Check Bi Tput
    [Arguments]    ${ue_type}    ${log}    ${cells}    ${ultarget_throughput}    ${dltarget_throughput}    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    [Documentation]    validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...    # unit is Mbps    # if you need to use the value.
    ...    Add both avraget throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / huawei_sigspark
    ...    :param log: log path of aasyslog throughput file.
    ...    Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...    :param cells: list of target cells. E.G for 8CC CA traffic , all 8 cells IDs should be in list.
    ...    :param ultarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...    Will be used in validation with target_avg_percent and minimum percent.
    ...    :param dltarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...    Will be used in validation with target_avg_percent and minimum percent.
    ...    :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...    Check_result > target_throughput * target_avg_percent
    ...    :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.
    ...    E.G
    ...    Power_ue.Start Traffic
    ...    Power_ue.Start Traffic
    ...    ${tput_log} power_ue.Collect Tput
    ...    Power_ue.Stop Traffic
    ...    Power_ue.Stop Traffic
    ...    ${list_of_cell_ids} Create list 16385 16388
    ...    Power_ue.Check Bi Tput cells=${list_of_cell_ids} log=${tput_log}
    ...    ultarget_throughput=2048 dltarget_throughput=256
    ...
    ...    ${ul} ${dl} Power_ue.Check Bi Tput xxxxxxxxxxxxxxxxxx
    ${output}    run keyword    ${ue_type}.Check Bi Tput    log=${log}    cells=${cells}
    ...    min_percent=${min_percent}    ultarget_throughput=${ultarget_throughput}
    ...    dltarget_throughput=${dltarget_throughput}    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
    ################################## STEP5: STOP DATA TRANSFER ##################################
    [Return]    ${output}

power_ue.Stop traffic
    [Arguments]    ${ue_type}    ${direction}    ${ue_index}=${0}    ${dt_index}=${0}    ${dt_name}=DT_1    ${ue_alias}=UE_${ue_index}
    ...    ${iperf_port}=default    ${appserver}=APPserver    ${iperf_type}=via_app    ${protocol}=udp
    ...    ${apn_address}=wap1nokiacom    ${ue_mode}=SA
    [Documentation]    Stop data transfer for L3 call test.
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / huawei_sigspark
    ...    :param direction: The traffic direction, ul or dl.
    ...    :param ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...    :param dt_index: The new data transfer index alias.
    ...    :param dt_name: alias name for created data transfer.
    ...    :param ue_alias: <str> store ue by ue_alias
    ...    :param protocal: Traffic protocal type. E.G udp/tcp
    ...    :param iperf_type: Traffic use iperf command or iperf app type.
    ${direction}=    Convert To Lowercase    ${direction}
    ${output}    run keyword    ${ue_type}.Stop traffic    direction=${direction}    ue_index=${ue_index}
    ...    dt_index=${dt_index}    dt_name=${dt_name}
    ...    ue_alias=${ue_alias}    iperf_port=${iperf_port}    appserver=${appserver}    iperf_type=${iperf_type}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    ...    protocol=${protocol}
    ################################## STEP6: UE DETACH ##################################
    [Return]    ${output}

power_ue.UE Detach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${power_reset}=False
    [Documentation]    Detach UE for L3 call test.
    ...    :param ue_type: The type of target UE, given in lowercase. E.G huawei / huawei_sigspark
    ...    :param ue_index: The list index from tl.ues[], it will use the index UE for detach
    ...    :param ue_alias: <str> store ue by ue_alias
    ...    :param power_reset: <str> used to choose whether use power off or not in huawei spark,
    ...    if it set to true, ue detach will use power off
    ${output}    run keyword    ${ue_type}.UE Detach    ue_index=${ue_index}    ue_alias=${ue_alias}    power_reset=${power_reset}
    ################################## STEP7: TEARDOWN UE ##################################
    [Return]    ${output}

power_ue.Teardown UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    Teardown UE after test finished.
    ${output}    run keyword    ${ue_type}.Teardown UE    ue_index=${ue_index}    ue_alias=${ue_alias}
    ################################## STEP8: Get Param Value    ##################################
    [Return]    ${output}

power_ue.Get Param Value
    [Arguments]    ${ue_type}    ${param}=[]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    Get Param Value.
    ${index}    Evaluate    ${ue_index}+1
    ${output}    run keyword    ${ue_type}.Get Param Value    index=${index}    param=${param}    ue_alias=${ue_alias}
    [Return]    ${output}
