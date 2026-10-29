*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              author: JIAYI TANG
...              Contact: jiayi.tang@nokia-sbell.com
...              Verified equipment: huawei_mate30 support taf.ue.android
...              testline_configuration refer to 7_5_UTE5G402T329

Library    robot.libraries.DateTime
Library    taf.ul.power_ue    WITH NAME    ul_power_ue
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.CI_Operations.CI_analyzation.RobotCaseInfo    WITH NAME    RobotCaseInfo
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.power_ue_adaption    WITH NAME    power_ue_adaption

*** Variables ***


*** Keywords ***
################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_index}=${0}    ${cap_index}=${0}    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for reserve
    Log    Prepare UE
    append to list    ${tl.ues[${ue_index}].capabilities}    huaweiandroid
    ul_power_ue.Prepare UE    ue_alias=UE_${ue_index}    ue_index=${ue_index}
    remove from list    ${tl.ues[${ue_index}].capabilities}    -1

################################## STEP2: UE ATTACH ##################################
UE Attach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for attach
    ...  :param  log_type: <String> Attach log type, Aasyslog/Iperf
    ul_power_ue.UE Detach    ue=UE_${ue_index}
    Sleep    1s
    ul_power_ue.UE Attach    ue=UE_${ue_index}
    Sleep    1s    

################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    Verify attach result when plugin self verify not suffient
    ul_power_ue.verify_ue_attach    ue=UE_${ue_index}

################################## STEP3 Start traffic ##################################
Start traffic
    [Arguments]    ${direction}    ${duration}    ${throughput}    ${protocol}=udp    ${ue_index}=${0}    ${iperf_port}=default
    ...            ${packet}=1400    ${iperf_len}=1400     &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic. E.G 120
    ...  :param  throughput: Throughput(M) of new data transfer, Unit in Mbps
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ${throughput}    convert to string    ${throughput}
    ${throughput}    Get Regexp Matches    ${throughput}    (\\d+\\.?\\d*)    1
    ${throughput}    set variable    ${throughput[0]}
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0]}
    ...                                                           ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[1]}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    ${iperf_options}    create dictionary    packet=${packet}    iperf_len=${iperf_len}
    ul_power_ue.Start traffic    dt_name=${dt_name}    direction=${direction}    duration=${duration}
    ...        throughput=${throughput}    protocol=${protocol}
    ...        iperf_port=${port}    iperf_options=${iperf_options}    ue=UE_${ue_index}

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
    ${duration}    DateTime.Convert Time    ${duration}
    ${omit}    DateTime.Convert Time    ${ignore_time}
    ${end}    DateTime.Add Time to Time    ${duration}    ${omit}
    ${log_details}    run keyword if    '${check_source.lower()}'=='aasyslog'    ul_power_ue.collect syslog for throughput
    ...    omit=${omit}    end=${end}    alias=${alias}
    ...    ELSE    sleep    ${end}
    ${log_path}    set variable if    '${check_source.lower()}'=='aasyslog'    ${log_details["log_path"][0]}    ${None}
    set test variable    ${omit}
    set test variable    ${end}
    [Return]  ${log_path}

################################## STEP4 Check Tput ##################################
Check Tput
    [Arguments]    ${direction}    ${target_throughput}    ${cells}=${1}    ${log}=none
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${check_source}=spark    ${ue_index}=${0}
    ...            ${cell_indiv_tput}=${None}   ${actImgGeneration}=${True}
    ...            ${omit_time}=10    ${end_time}=60    ${alias}=log_0    &{kwargs}
    [Documentation]   Check throughput from started traffic.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  target_throughput (M): theory target throughput. Unit in Mbps
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for check throughput.
    ...  :param  target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ${omit_status}    run keyword and return status    variable should exist    ${omit}
    ${omit_time}    set variable if    ${omit_status}    ${omit}    ${omit_time}
    ${tput_result}    run keyword if    '${check_source.lower()}'=='aasyslog'
    ...                                                  ul_power_ue.check_unidirectional_throughput_from_syslog
    ...                                                  direction=${direction}
    ...                                                  theoretical_throughput=${target_throughput}
    ...                                                  average_tolerance=${target_avg_percent}
    ...                                                  minimum_tolerance=${min_percent}
    ...                                                  nrcellids=${cells}
    ...                                                  ca=${actCarrierAggregation}
    ...                                                  enable_chart_generation=${actImgGeneration}
    ...                                                  customized_chart_file_name=${customized_log_name}
    ...                                                  alias=${alias}
    ...    ELSE
    ...                                                  ul_power_ue.check_unidirectional_throughput          
    ...                                                  dt_name=${dt_name}
    ...                                                  direction=${direction}
    ...                                                  theoretical_throughput=${target_throughput}
    ...                                                  average_tolerance=${target_avg_percent}
    ...                                                  minimum_tolerance=${min_percent}
    ...                                                  omit=${omit_time}
    ...                                                  end=${end_time}
    [Return]  ${tput_result}

################################## STEP5: STOP DATA TRANSFER ##################################
Stop traffic
    [Arguments]     ${direction}    ${ue_index}=${0}    &{kwargs}
    [Documentation]    stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${dt_name}    set variable    DT_${direction}_${ue_index}
    ul_power_ue.Stop traffic    dt_name=${dt_name}

################################## STEP6: UE DETACH ##################################
UE Detach
    [Arguments]    ${ue_index}=${0}   &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for traffic
    ul_power_ue.UE Detach    ue=UE_${ue_index}
