*** Settings ***
Documentation    UE common keyword for normal L3 call.
...              Please do not modify the file without notification to author
...              author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com

Library    robot.libraries.DateTime
Library    taf.ul.power_ue    WITH NAME    ul_power_ue
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.CI_Operations.CI_analyzation.RobotCaseInfo    WITH NAME    RobotCaseInfo
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.power_ue_adaption    WITH NAME    power_ue_adaption

*** Variables ***

*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    Log    Prepare UE

################################## STEP2: UE ATTACH ##################################
UE Attach
    [Arguments]    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    Log    UE Attach

################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    &{kwargs}
    [Documentation]    Verify attach result when plugin self verify not sufficient
    Log    Verify attach

################################## STEP3: START DATA TRANSFER ##################################
Start traffic
    [Arguments]    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    Log    Start traffic

################################## STEP4X COLLECT THROUGHPUT ##################################
Collect Tput
    [Arguments]    ${duration}=10m    ${ignore_time}=1min    ${upload_duration}=${True}
    ...            ${alias}=log_0    &{kwargs}
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...                As the moment traffic just started, throughput will be unstable (Acceptable and should be ignored)
    ...                Add Ignore time before and after throughput capturing.

    ...                :param duration: duration of log capturing. E.G 10min / 1hour
    ...                :param ignore_time: how long will be ignored before and after capturing. E.G 10min / 1hour
    ${duration}    DateTime.Convert Time    ${duration}
    ${omit}    DateTime.Convert Time    ${ignore_time}
    ${end}    DateTime.Add Time to Time    ${duration}    ${omit}
    ${log_details}    ul_power_ue.collect syslog for throughput
    ...    omit=${omit}    end=${end}    alias=${alias}
    ${log_path}    set variable    ${log_details["log_path"][0]}
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
    ...  :param  target_avg_percent: allowed average percentage. E.G 0.95 or 95%
    power_ue_adaption.check_unidirectional_throughput_from_syslog
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

################################## STEP4X CHECK BI DIRECTION THROUGHPUT ##################################
Check Bi Tput
    [Arguments]    ${log}=none    ${cells}=${1}    ${ultarget_throughput}=5    ${dltarget_throughput}=5
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${actImgGeneration}=${True}    ${upload_tp}=${True}
    ...            ${ue_index}=${0}    ${alias}=log_0    &{kwargs}
    [Documentation]    Validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...                Add both average throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...                :param log: log path of aasyslog throughput file.
    ...                            Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...                :param cells: list of target cells. E.G for 8CC CA traffic, all 8 cell IDs should be in the list.
    ...                :param ultarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param dltarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param target_avg_percent: allowed average percentage. E.G 0.95 or 95%
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
    [Arguments]    &{kwargs}
    [Documentation]    stop data transfer for L3 call test.
    Log    Stop traffic

################################## STEP6: UE DETACH ##################################
UE Detach
    [Arguments]    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    Log    UE Detach
