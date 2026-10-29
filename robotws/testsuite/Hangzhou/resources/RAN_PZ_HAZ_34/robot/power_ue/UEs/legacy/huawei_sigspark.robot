*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author: Zhang Haijun, Civen Chen
...              Contact: haijun.zhang@nokia-sbell.com, civen.chen@nokia-sbell.com
...              Already verified equipment: Huawei Meta20x

Resource    ../../Power_ue_supports/power_ue_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot


*** Variables ***

*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_alias}  ${power_reset}  ${detach_request}  ${ue_index}=${0}    ${reset_sol}=${None}
    ...            ${get_spark_license}=${true}    ${ue_num_input}=${None}    ${required_spark_license_time}=2
    ...            ${force_check_ue}=${False}    ${eq_index}=${None}    &{kwargs}
    [Documentation]     Prepare UE for L3 call test.
    ...  :param   ue_alias: <str> store ue by ue_alias
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    ...  :param required_spark_license_time: extend spark license if remaining time less than it. unit: hours.
    ...  :param force_check_ue: True/False. will verify ue imsi when connect to UE. Default is not to verify.
    ...           if verify ue failed, will continue to use UE 1 to continue the testing. This flag is used to keep the
    ...           original behavior, if you want to make sure UE is correctly used, please set it to True
    ...   :param eq_index: UE index start from 1. if None, will search one by one based on ue_num on spark.
    ...                     if not none, then will verify IMSI, if passed, will set ueindex to eq_index. If you would
    ...                     like to improve the efficiency for require_ue, you can directly specify this eq_index
    spark.require_ue    ue_alias=${ue_alias}    index=${ue_index}    reset_sol=${reset_sol}
    ...                 power_reset=${power_reset}     detach_request=${detach_request}
    ...                 get_spark_license=${get_spark_license}
    ...                 ue_num_input=${ue_num_input}
    ...                 required_spark_license_time=${required_spark_license_time}
    ...                 force_check_ue=${force_check_ue}    eq_index=${eq_index}

################################## STEP2: UE ATTACH ##################################
UE Attach
    [Arguments]    ${ue_alias}   ${attach_mode}   ${power_reset}   &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  power_reset: <str> used to choose whether use power on or not in huawei spark,
    ...                       if it set to true, ue attach will use power on
    ${attach_res}     spark.attach_ue    ue_alias=${ue_alias}   attach_mode=${attach_mode}
    ...                                  power_reset=${power_reset}
    [Return]     ${attach_res}

################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    &{kwargs}
    [Documentation]    Verify attach result when plugin self verify not suffient
    Log    Already verified inside UE Attach.

################################## STEP3: START DATA TRANSFER ##################################
Start traffic
    [Arguments]    ${direction}    ${duration}   ${throughput}  ${ue_index}   ${apn_address}  ${ue_mode}
    ...            ${ue_alias}    ${dt_name}    ${iperf_port}   ${process_num}=1    ${protocol}=UDP    ${multidrb_QoS_dest}=${None}
    ...            ${connection_type}=app    ${buffer_size}=1024B    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  iperf_port:  The port value of traffic, eg: 50001
    ...  :param  process_num: effective for dl traffic
    ...  :param  multidrb_QoS_dest: <optional> default None,
    ...                             multidrb_QoS_dest is a optional input,
    ...                             Setup UL traffic dest ip address for multidrb testing,
    ...                             Normal UL traffic ignore this param.
    ...  :param  connection_type: net connection type, "app" or "current", "app" default.
    ${protocol}=    Convert To Uppercase    ${protocol}
    ${default_port}    set variable    ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    spark.start_data_transfer    ue_alias=${ue_alias}    direction=${direction}    dt_name=${dt_name}
    ...                          duration=${duration}    throughput=${throughput}  iperf_port=${port}
    ...                          process_num=${process_num}, protocol=${protocol}    multidrb_QoS_dest=${multidrb_QoS_dest}
    ...                          connectiontype=${connection_type}     apn_address=${apn_address}
    ...                          ue_mode=${ue_mode}    buffer_size=${buffer_size}

################################## STEP4: CHECK THROUGHPUT ##################################
Check throughput
    [Arguments]    ${ue_alias}    ${direction}    ${throughput}    &{kwargs}
    [Documentation]    Check throughput from started traffic on UE side.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ${output}    spark.check_throughput_on_ue    ue_alias=${ue_alias}
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
    [Arguments]    ${ue_alias}    ${check_source}=spark
    ...            ${gnb_index}=0    ${du_index}=0    ${duration}=10min    ${ignore_time}=1min    ${type}=MCU
    ...            ${filter}=${EMPTY}    ${Teardown_after_finished}=${True}    ${upload_duration}=${True}    &{kwargs}
    [Documentation]    Check throughput from started traffic on UE side.
    ...  :param  ue_alias: <str> store ue by ue_alias, used for sigspark ue throughput

    ...                :param gnb_index: the gnb index which config in tl.gnbs[]. from here used for aasyslog throughput
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

    ${log}    run keyword if
    ...               '${check_source}'=='spark'    power_ue_throughput.__Standard Capturing Sigspark Throughput
    ...                                  ue_alias=${ue_alias}    duration=${duration}
    ...    ELSE IF    '${check_source}'=='aasyslog'    power_ue_throughput.__Standard Capturing Aasyslog Throughput
    ...            gnb_index=${gnb_index}    du_index=${du_index}
    ...            type=${type}    duration=${duration}    ignore_time=${ignore_time}
    ...            filter=${filter}    Teardown_after_finished=${Teardown_after_finished}
    ...            upload_duration=${upload_duration}
    [Return]    ${log}

################################## STEP4X Standard Check single direction throughput ##################################
Check Tput
    [Arguments]    ${direction}    ${log}    ${cells}    ${target_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${check_source}=spark    &{kwargs}
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

    ...                :param direction: direction of the target traffic to be checked. E.G: UL/DL  From here for aasyslog throughput
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
    ${check_source}    Convert To Lowercase    ${check_source}
    ${throughput_result}    run keyword if
    ...    '${check_source}'=='spark'    power_ue_throughput.__Standard Check Sigspark Throughput
    ...    ue_alias=${cells}    tput_output=${log}    direction=${direction}
    ...    target_throughput=${target_throughput}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}

    ...    ELSE IF    '${check_source}'=='aasyslog'    power_ue_throughput.__Standard Check Aasyslog Throughput
    ...    direction=${direction}    log=${log}    cells=${cells}
    ...    target_throughput=${target_throughput}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    min_percent=${min_percent}
    ...    customized_log_name=${customized_log_name}
    [Return]    ${throughput_result}

################################## STEP4X CHECK BI DIRECTION THROUGHPUT ##################################
Check Bi Tput
    [Arguments]    ${log}    ${cells}    ${ultarget_throughput}    ${dltarget_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${check_source}=spark    &{kwargs}
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

    ${throughput_result}    run keyword if
    ...    '${check_source}'=='spark'    power_ue_throughput.__Standard Check Bi Sigspark Throughput
    ...    ue_alias=${cells}    tput_output=${log}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}

    ...    ELSE IF    '${check_source}'=='aasyslog'    power_ue_throughput.__Standard Check Bi Aasyslog Throughput
    ...    log=${log}    cells=${cells}    min_percent=${min_percent}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
    ...    customized_log_name=${customized_log_name}
    [Return]    ${throughput_result}

################################## STEP5: STOP DATA TRANSFER ##################################
Stop traffic
    [Arguments]    ${direction}    ${ue_alias}    ${dt_name}  ${ue_index}
    ...            ${iperf_port}   ${apn_address}   ${ue_mode}   &{kwargs}
    [Documentation]    Stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  dt_name: <str> store traffic by ue_alias
    ...  :param  iperf_port:  The port value of traffic, only used in stop DL traffic eg: 50001
    ${default_port}    set variable    ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    spark.stop_data_transfer    ue_alias=${ue_alias}    dt_name=${dt_name}    direction=${direction}
    ...     iperf_port=${port}     apn_address=${apn_address}   ue_mode=${ue_mode}

################################## STEP6: UE DETACH ##################################
UE Detach
    [Arguments]    ${ue_alias}    ${power_reset}    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  power_reset: <str> used to choose whether use power off or not in huawei spark,
    ...                       if it set to true, ue attach will use power off
    spark.detach_ue    ue_alias=${ue_alias}      power_reset=${power_reset}

################################## STEP7: TEARDOWN UE ##################################
Teardown UE
    [Arguments]    ${ue_alias}   &{kwargs}
    [Documentation]    Teardown UE after test finished. for spark, it should release spark license
    spark.release_spark_license   ue_alias=${ue_alias}

################################## GET Setup Complete EVENT ##################################
Get SA RRC Setup Complete Time
    [Arguments]    ${ue_alias}    ${ue_index}=1
    [Documentation]    Get SA RRC Setup Complete Time
    ...    :param index: ue number
    ...    :return setup complete time
    ${output}    spark.get_SA_RRC_setup_complete_time_on_ue    index=${ue_index}    ue_alias=${ue_alias}
    [Return]    ${output}
