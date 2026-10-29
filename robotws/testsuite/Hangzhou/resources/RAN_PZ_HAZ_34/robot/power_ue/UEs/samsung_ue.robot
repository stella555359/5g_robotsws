*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              author: Zhong Tingting
...              Contact: tingting.zhong@nokia-sbell.com
...              Verified equipment: nokia_fastmile support taf.ue.fastmile
...              testline_configuration refer to 7_5_UTE5G402T319

Library    robot.libraries.DateTime
Library    taf.ue    WITH NAME    ute_ue
Library    taf.ul.power_ue    WITH NAME    ul_power_ue
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.CI_Operations.CI_analyzation.RobotCaseInfo    WITH NAME    RobotCaseInfo
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.power_ue_adaption    WITH NAME    power_ue_adaption
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot


*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_index}=${0}    ${cap_index}=${0}    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for reserve
    ${unused_arguments_list}    Create List    cap_index=${cap_index}
    Log    message=\nArgument ${unused_arguments_list} is not used and will be removed in the future.
    Builtin.Log    Prepare UE
    ${status}    run keyword and return status    append to list    ${tl.ues[${ue_index}].capabilities}    samsung
    ul_power_ue.Prepare UE    ue_alias=UE_${ue_index}    ue_index=${ue_index}
    [Teardown]  run keyword if    ${status}    remove from list    ${tl.ues[${ue_index}].capabilities}    -1

################################## STEP2: UE ATTACH ##################################
UE Attach
    [Arguments]    ${ue_index}=${0}    ${log_type}=Aasyslog    ${gnb_index}=${0}    ${du_index}=0
    ...    ${pci}=${0}    ${power_reset}=${False}    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for attach
    ...  :param  log_type: <String> Attach log type, Aasyslog/Iperf
    ${unused_arguments_list}    Create List    pci=${pci}   power_reset=${power_reset}
    Log    message=\nArgument ${unused_arguments_list} is not used and will be removed in the future.
    ul_power_ue.UE Detach    ue=UE_${ue_index}
    run keyword if    '${log_type.lower()}'=='aasyslog'    run keywords
    ...    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    AND
    ...    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    AND
    ...    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
    ul_power_ue.UE Attach    ue=UE_${ue_index}

################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    Verify attach result when plugin self verify not suffient
    ul_power_ue.Verify Ue Attach    ue=UE_${ue_index}

################################## STEP2.2: Create additional PDN ##################################
Start traffic
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${protocol}=udp    ${ue_index}=${0}    ${iperf_port}=default
    ...    ${packet}=1400B    ${process_num}=1   ${apn}=${None}   &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic. E.G 120
    ...  :param  throughput: Throughput(M) of new data transfer, Unit in Mbps
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${throughput}    convert to string    ${throughput}
    ${process_num}    convert to string    ${process_num}
    ${throughput}    Get Regexp Matches    ${throughput}    (\\d+\\.?\\d*)    1
    ${throughput}    set variable    ${throughput[0]}
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0]}
    ...                                                           ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[1]}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    # Kill iperf process before start traffic, as if port is in use, start traffic will fail in ue proxy solution
    Run keyword and ignore error    traffic_via_iperf.Kill iperf process on app server    port=${port}    is_ue_proxy=${True}
#    Run keyword and ignore error    traffic_via_iperf.Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${port}
    ${iperf_options}    create dictionary    packet=${packet}    parallel_streams=${process_num}
    ul_power_ue.Start traffic    direction=${direction}    dt_name=${dt_name}    protocol=${protocol}    throughput=${throughput}
    ...    duration=${duration}    ue=UE_${ue_index}    iperf_port=${port}    iperf_options=${iperf_options}    apn=${apn}

################################## STEP4X COLLECT THROUGHPUT ##################################
Collect Tput
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${duration}=10m    ${ignore_time}=1min    ${type}=MCU
    ...            ${filter}=${EMPTY}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${log_dir}=${OUTPUT_DIR}
    ...            ${Teardown_after_finished}=${True}    ${check_source}=Aasyslog    ${upload_duration}=${True}
    ...            ${alias}=log_0
    ...            &{kwargs}
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...                As the moment traffic just started, throughput will be unstable (Acceptable and should be ignored)
    ...                Add Ignore time before and after throughput capturing.

    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    ...                :type two paramater can choose[mcu,rt],the syslog with CCS_MCU contain L2LO and CCS_RT contain L2HI.
    ...                :param duration: duration of log capturing. E.G 10min / 1hour
    ...                :param ignore_time: how long will be ignored before and after capturing. E.G 10min / 1hour
    ...                :param  check_source: check log type, Aasyslog/Iperf
    ${unused_arguments_list}    Create List    gnb_index=${gnb_index}   du_index=${du_index}   type=${type}   filter=${filter}
    ...    ue_alias=${ue_alias}   log_dir=${log_dir}   Teardown_after_finished=${Teardown_after_finished}
    Log    message=\nArgument ${unused_arguments_list} is not used and will be removed in the future.
    ${duration}    DateTime.Convert Time    ${duration}
    ${omit}    DateTime.Convert Time    ${ignore_time}
    ${end}    DateTime.Add Time to Time    ${duration}    ${omit}
    ${log_details}    run keyword if    '${check_source.lower()}'=='aasyslog'    ul_power_ue.collect syslog for throughput
    ...    omit=${omit}    end=${end}    alias=${alias}
    ...    ELSE    sleep    ${end}
    ${log_path}    set variable if    '${check_source.lower()}'=='aasyslog'    ${log_details["log_path"][0]}    ${None}
    set test variable    ${omit}
    set test variable    ${end}
    run keyword if    '${upload_duration}'=='${True}'    run keyword and ignore error
    ...               RobotCaseInfo.add_throughput_duration     duration=${duration}
    ...                                                         ignore_time=${ignore_time}
    [Return]  ${log_path}

################################## STEP4X Standard Check single direction throughput ##################################
Check Tput
    [Arguments]    ${direction}    ${target_throughput}    ${cells}=${1}    ${log}=none
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${check_source}=Aasyslog    ${ue_index}=${0}
    ...            ${cell_indiv_tput}=${None}   ${actImgGeneration}=${True}    ${upload_tp}=${True}
    ...            ${omit_time}=10    ${end_time}=0    ${alias}=log_0    &{kwargs}
    [Documentation]   Check throughput from started traffic.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  target_throughput (M): theory target throughput. Unit in Mbps
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for check throughput.
    ...  :param  target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ${unused_arguments_list}    Create List    log=${log}   cell_indiv_tput=${cell_indiv_tput}
    Log    message=\nArgument ${unused_arguments_list} is not used and will be removed in the future.
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ${omit_status}    run keyword and return status    variable should exist    ${omit}
    ${omit_time}    set variable if    ${omit_status}    ${omit}    ${omit_time}
    run keyword if    '${check_source.lower()}'=='aasyslog'
    ...                                                  power_ue_adaption.check_unidirectional_throughput_from_syslog
    ...                                                  ue_class_name=ul_power_ue
    ...                                                  tp_class_name=RobotCaseInfo
    ...                                                  direction=${direction}
    ...                                                  theoretical_throughput=${target_throughput}
    ...                                                  average_tolerance=${target_avg_percent}
    ...                                                  minimum_tolerance=${min_percent}
    ...                                                  cells=${cells}
    ...                                                  ca=${actCarrierAggregation}
    ...                                                  enable_chart_generation=${actImgGeneration}
    ...                                                  customized_chart_file_name=${customized_log_name}
    ...                                                  alias=${alias}
    ...                                                  upload_tp=${upload_tp}
    ...    ELSE
    ...                                                  power_ue_adaption.check_unidirectional_tput
    ...                                                  ue_class_name=ul_power_ue
    ...                                                  tp_class_name=RobotCaseInfo
    ...                                                  dt_name=${dt_name}
    ...                                                  direction=${direction}
    ...                                                  theoretical_throughput=${target_throughput}
    ...                                                  average_tolerance=${target_avg_percent}
    ...                                                  minimum_tolerance=${min_percent}
    ...                                                  omit=${omit_time}
    ...                                                  end=${end_time}
    ...                                                  cells=${cells}
    ...                                                  upload_tp=${upload_tp}

################################## STEP4X CHECK BI DIRECTION THROUGHPUT ##################################
Check Bi Tput
    [Arguments]    ${log}=none    ${cells}=${1}    ${ultarget_throughput}=5    ${dltarget_throughput}=5
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${actImgGeneration}=${True}    ${upload_tp}=${True}
    ...            ${ue_index}=${0}    ${alias}=log_0    &{kwargs}
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
    ${unused_arguments_list}    Create List    log=${log}   ue_index=${ue_index}
    Log    message=\nArgument ${unused_arguments_list} is not used and will be removed in the future.
    run keyword and continue on failure
    ...                                                  power_ue_adaption.check_unidirectional_throughput_from_syslog
    ...                                                  ue_class_name=ul_power_ue
    ...                                                  tp_class_name=RobotCaseInfo
    ...                                                  direction=dl
    ...                                                  theoretical_throughput=${dltarget_throughput}
    ...                                                  average_tolerance=${target_avg_percent}
    ...                                                  minimum_tolerance=${min_percent}
    ...                                                  cells=${cells}
    ...                                                  ca=${actCarrierAggregation}
    ...                                                  enable_chart_generation=${actImgGeneration}
    ...                                                  customized_chart_file_name=${customized_log_name}
    ...                                                  alias=${alias}
    ...                                                  upload_tp=${upload_tp}
    run keyword and continue on failure
    ...                                                  power_ue_adaption.check_unidirectional_throughput_from_syslog
    ...                                                  ue_class_name=ul_power_ue
    ...                                                  tp_class_name=RobotCaseInfo
    ...                                                  direction=ul
    ...                                                  theoretical_throughput=${ultarget_throughput}
    ...                                                  average_tolerance=${target_avg_percent}
    ...                                                  minimum_tolerance=${min_percent}
    ...                                                  cells=${cells}
    ...                                                  ca=${actCarrierAggregation}
    ...                                                  enable_chart_generation=${actImgGeneration}
    ...                                                  customized_chart_file_name=${customized_log_name}
    ...                                                  alias=${alias}
    ...                                                  upload_tp=${upload_tp}

################################## STEP5: STOP DATA TRANSFER ##################################
Stop traffic
    [Arguments]    ${direction}    ${ue_index}=${0}    &{kwargs}
    [Documentation]    stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ul_power_ue.Stop traffic    dt_name=${dt_name}

################################## STEP6: UE DETACH ##################################
UE Detach
    [Arguments]    ${ue_index}=${0    ${power_reset}=False    ${timeout}=600    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  power_reset: <str> flag for power reset ue or not, if it set to true, ue will be reset
    ...  :param  timeout: <str> timeout for ue power reset
    IF    '${power_reset}'=='True'
        ul_power_ue.UE Reboot    ue=UE_${ue_index}    timeout=${timeout}
        log to console    \nreboot ue_index ue ${ue_index}
    END
    ul_power_ue.UE Detach    ue=UE_${ue_index}
