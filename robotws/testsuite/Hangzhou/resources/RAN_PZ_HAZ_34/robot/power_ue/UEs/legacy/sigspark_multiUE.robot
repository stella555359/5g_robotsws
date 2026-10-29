*** Settings ***
Documentation    common keyword for sigspark multi UE.
...              Author: Zhang Wenjin
...              Contact: wenjin.zhang@nokia-sbell.com

Resource    ../../Power_ue_supports/power_ue_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot


*** Variables ***

*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_alias}   ${multiue_traffic_config}    &{kwargs}
    [Documentation]     Prepare UE for L3 call test.
    ...  :param   ue_alias: <str> store ue by ue_alias
    ${output}   run keyword and continue on failure    sparkMultiUE.require_ue
    ...         ue_alias=${ue_alias}    multiue_traffic_config=${multiue_traffic_config}
    [Return]   ${output}

################################## STEP2: UE ATTACH ##################################
UE Attach
    [Arguments]    ${ue_alias}   &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  power_reset: <str> used to choose whether use power on or not in huawei spark,
    ...                       if it set to true, ue attach will use power on
    ${output}     sparkMultiUE.attach_ue    ue_alias=${ue_alias}
    [Return]     ${output}

################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    &{kwargs}
    [Documentation]    Verify attach result when plugin self verify not suffient
    Log    Already verified inside UE Attach.

################################## STEP3: START DATA TRANSFER ##################################
Start traffic
    [Arguments]    ${direction}    ${ue_alias}    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  iperf_port:  The port value of traffic, eg: 50001
    ...  :param  multidrb_QoS_dest: <optional> default None,
    ...                             multidrb_QoS_dest is a optional input,
    ...                             Setup UL traffic dest ip address for multidrb testing,
    ...                             Normal UL traffic ignore this param.
    ...  :param  connection_type: net connection type, "app" or "current", "app" default.
    ${output}    sparkMultiUE.start_data_transfer    ue_alias=${ue_alias}    direction=${direction}
    [Return]    ${output}

################################## STEP4: CHECK THROUGHPUT ##################################
Check throughput
    [Arguments]    ${ue_alias}    ${direction}    ${throughput}    &{kwargs}
    [Documentation]    Check throughput from started traffic on UE side.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ${output}    sparkMultiUE.check_throughput_on_ue    ue_alias=${ue_alias}
    ${tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output[0]} / 1024 / 1024
    ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output[1]} / 1024 / 1024
    should be true    ${tput} > ${throughput}
    [Return]    ${tput}

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
    [Arguments]    ${ue_alias}    ${duration}=10min    &{kwargs}
    [Documentation]    Check throughput from started traffic on UE side.
    ...  :param  ue_alias: <str> store ue by ue_alias

    ${log}    power_ue_throughput.__Standard Capturing Sigspark Throughput    ue_alias=${ue_alias}    duration=${duration}
    [Return]    ${log}

################################## STEP4X Standard Check single direction throughput ##################################
Check Tput
    [Arguments]    ${direction}    ${log}    ${cells}    ${target_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    &{kwargs}
    [Documentation]    validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...                Add both avraget throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...                :param direction: direction of the target traffic to be checked. E.G: UL/DL
    ...                :param log: log path of aasyslog throughput file.
    ...                            Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...                :param cells: ue_alias in sigspark.
    ...                :param target_throughput: theory target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                                           Check_result > target_throughput * target_avg_percent

    ${throughput_result}    power_ue_throughput.__Standard Check Sigspark Throughput
    ...                     ue_alias=${cells}    tput_output=${log}    direction=${direction}
    ...                     target_throughput=${target_throughput}
    ...                     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Return]    ${throughput_result}

################################## STEP4X CHECK BI DIRECTION THROUGHPUT ##################################
Check Bi Tput
    [Arguments]    ${log}    ${cells}    ${ultarget_throughput}    ${dltarget_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    &{kwargs}
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

    ${throughput_result}   run keyword and continue on failure    sparkMultiUE.check_throughput_on_ue    ue_alias=UE_0
    [Return]    ${throughput_result}

################################## STEP5: STOP DATA TRANSFER ##################################
Stop traffic
    [Arguments]    ${direction}    ${ue_alias}    &{kwargs}
    [Documentation]    Stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  dt_name: <str> store traffic by ue_alias
    ...  :param  iperf_port:  The port value of traffic, only used in stop DL traffic eg: 50001
#    ${default_port}    set variable    ${tl.ues[${ue_index}].iperf_details.port}
#    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    ${output}    sparkMultiUE.stop_data_transfer    ue_alias=${ue_alias}    direction=${direction}
    [Return]   ${output}

################################## STEP6: UE DETACH ##################################
UE Detach
    [Arguments]    ${ue_alias}    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ${output}    sparkMultiUE.detach_ue    ue_alias=${ue_alias}
    [Return]    ${output}



