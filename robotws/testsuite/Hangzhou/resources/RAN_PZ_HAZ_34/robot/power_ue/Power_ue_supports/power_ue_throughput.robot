*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com
Resource    ../../aasyslog.robot
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.sigspark.SigSpark    WITH NAME    spark
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.sigspark_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE
Library    ../../../python/throughput/aasyslog_tput.py    WITH NAME    aastp
Library    ../../../python/throughput/sigspark_tput.py    WITH NAME    sgptp

*** Keywords ***
################################## Throughput Capture keyword ##################################
__Standard Capturing Aasyslog Throughput
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...                As the moment traffic just started, throughput will be unstable (Acceptable and should be ignored)
    ...                Add Ignore time before and after throughput capturing.
    ...                Author: Civen Chen
    ...                Contact: civen.chen@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    ...                :type two paramater can choose[mcu,rt],the syslog with CCS_MCU contain L2LO and CCS_RT contain L2HI.
    ...                :param duration: duration of log capturing. E.G 10min / 1hour
    ...                :param ignore_time: how long will be ignored before and after capturing. E.G 10min / 1hour
    ...                :param filter: the save log can add filter to aviod too large
    ...                :param start_timeout: captrue timeout in backgroud.'s'for seconds,
    ...                                                                   'm' for minutes,
    ...                                                                   'h'for hours
    ...                                                                   'd'for days
    ...                :aa_sys_mode: AaSysMode means the AaSysLog Output Mode,ex:2 means udp
    ...                :aa_sys_addr: AaSysLog Udp output Address change to Hex, if the first is 0 need add parameter like
    ...                              ex:0x0A39A747 should use 0xA39A747
    ...                :aa_sys_udp_port: AaSysLog Udp Port used for log output
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU   ${duration}=10min    ${ignore_time}=1min
    ...            ${Teardown_after_finished}=${True}
    ...            ${log_ip}=127.0.0.1    ${start_timeout}=15m    ${gnb_path}=/tmp/    ${log_name}=aasyslog_tput.txt
    ...            ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xC738    ${filter}=${EMPTY}
    ...            ${upload_duration}=${True}

    sleep    ${ignore_time}
    ${gnb_index_flag}    evaluate    isinstance(${gnb_index}, list)
    ${log_path}    run keyword if    ${gnb_index_flag}
    ...    aasyslog.Capture multiple aasyslog    duration=${duration}
    ...                                          Teardown_after_finished=${Teardown_after_finished}
    ...                                          du_index=${du_index}    gnb_index_list=${gnb_index}
    ...                                          log_ip=${log_ip}
    ...                                          gnb_path=${gnb_path}    log_name=${log_name}
    ...                                          aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}
    ...                                          aa_sys_udp_port=${aa_sys_udp_port}    filter=${filter}
    ...    ELSE    aasyslog.Capturing Aasyslog with duration    duration=${duration}
    ...                                                         Teardown_after_finished=${Teardown_after_finished}
    ...                                                         du_index=${du_index}    gnb_index=${gnb_index}
    ...                                                         log_ip=${log_ip}
    ...                                                         gnb_path=${gnb_path}    log_name=${log_name}
    ...                                                         aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}
    ...                                                         aa_sys_udp_port=${aa_sys_udp_port}    filter=${filter}
    sleep    ${ignore_time}
    run keyword if    '${upload_duration}'=='${True}'    run keyword and ignore error
    ...               RobotCaseInfo.add_throughput_duration     duration=${duration}
    ...                                                         ignore_time=${ignore_time}
    [Return]    ${log_path}

__Standard Check Aasyslog Throughput
    [Arguments]    ${direction}    ${log}    ${cells}    ${target_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${cell_indiv_tput}=${None}   ${actImgGeneration}=${True}
    ...            ${upload_tp}=${True}
    ${tput_result}    ${record}    aastp.get_aasyslog_throughput
    ...                            direction=${direction}    log=${log}    cells=${cells}
    ...                            actCarrierAggregation=${actCarrierAggregation}
    run keyword and ignore error    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    run keyword and continue on failure    aastp.check_aasyslog_throughput
    ...    direction=${direction}    log=${log}    cells=${cells}    min_percent=${min_percent}
    ...    target_throughput=${target_throughput}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    output_dir=${OUTPUT_DIR}/${TEST NAME}/
    ...    customized_log_name=${customized_log_name}    cell_indiv_tput=${cell_indiv_tput}
    ...    actImgGeneration=${actImgGeneration}

    run keyword if    '${upload_tp}'=='${True}'    run keyword and ignore error    RobotCaseInfo.add_aasyslog_tp
    ...                             cells=${cells}    origin_tput=${tput_result}    direction=${direction}
    ...                             target_tp=${target_throughput}    avg_percent=${target_avg_percent}
    ...                             min_percent=${min_percent}    ca=${actCarrierAggregation}
    [Return]    ${tput_result}

__Standard Check Bi Aasyslog Throughput
    [Arguments]    ${log}    ${cells}    ${ultarget_throughput}    ${dltarget_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${actImgGeneration}=${True}    ${upload_tp}=${True}
    ${ul_tput_result}    ${ul_record}    aastp.get_aasyslog_throughput
    ...                                  direction=ul    log=${log}    cells=${cells}
    ...                                  actCarrierAggregation=${actCarrierAggregation}
    ${dl_tput_result}    ${dl_record}    aastp.get_aasyslog_throughput
    ...                                  direction=dl    log=${log}    cells=${cells}
    ...                                  actCarrierAggregation=${actCarrierAggregation}
    run keyword and ignore error    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    run keyword and continue on failure    aastp.check_bi_aasyslog_throughput
    ...    log=${log}    cells=${cells}    ultarget_throughput=${ultarget_throughput}
    ...    dltarget_throughput=${dltarget_throughput}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    output_dir=${OUTPUT_DIR}/${TEST NAME}/
    ...    min_percent=${min_percent}    customized_log_name=${customized_log_name}
    ...    actImgGeneration=${actImgGeneration}

    run keyword if    '${upload_tp}'=='${True}'    run keyword and ignore error    RobotCaseInfo.add_aasyslog_tp
    ...                             cells=${cells}    origin_tput=${ul_tput_result}    direction=ul
    ...                             target_tp=${ultarget_throughput}    avg_percent=${target_avg_percent}
    ...                             min_percent=${min_percent}    ca=${actCarrierAggregation}

    run keyword if    '${upload_tp}'=='${True}'    run keyword and ignore error    RobotCaseInfo.add_aasyslog_tp
    ...                             cells=${cells}    origin_tput=${dl_tput_result}    direction=dl
    ...                             target_tp=${dltarget_throughput}    avg_percent=${target_avg_percent}
    ...                             min_percent=${min_percent}    ca=${actCarrierAggregation}
    [Return]    ${ul_tput_result}    ${dl_tput_result}

__Standard Capturing Sigspark Throughput
    [Arguments]    ${ue_alias}    ${duration}=10min    ${ignore_time}=1min
    sleep    ${duration}
    ${log}    spark.check_throughput_on_ue    ue_alias=${ue_alias}
    run keyword and ignore error    RobotCaseInfo.add_throughput_duration    duration=${duration}
    ...                                                                      ignore_time=${ignore_time}
    [Return]    ${log}

__Standard Capturing Dingli Throughput
    [Arguments]    ${ue_alias}    ${duration}=10min    ${ignore_time}=1min
    sleep    ${duration}
    ${dl_throughput_dict}=      pclient.getparammac    ue=${ue_alias}
    ${ul}    Evaluate    ${dl_throughput_dict}[Param][MACUL]/1
    ${dl}    Evaluate    ${dl_throughput_dict}[Param][MACDL]/1
    ${log}       create list    ${ul}    ${dl}
    run keyword and ignore error    RobotCaseInfo.add_throughput_duration    duration=${duration}
    ...                                                                      ignore_time=${ignore_time}
    [Return]    ${log}

__Standard Check Sigspark Throughput
    [Arguments]    ${ue_alias}    ${tput_output}    ${direction}    ${target_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${upload_tp}=${True}
    ${tput}    sgptp.get_sigspark_throughput    tput=${tput_output}    direction=${direction}
    run keyword and continue on failure    sgptp.check_sigspark_throughput    tput=${tput_output}    direction=${direction}
    ...                                    target_throughput=${target_throughput}    target_avg_percent=${target_avg_percent}
    run keyword if    '${upload_tp}'=='${True}'    run keyword and ignore error    RobotCaseInfo.add_sigspark_tp
    ...               cell=${ue_alias}    tput=${tput}    direction=${direction}
    ...               target_tp=${target_throughput}
    ...               avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Return]    ${tput}

__Standard Check Bi Sigspark Throughput
    [Arguments]    ${ue_alias}    ${tput_output}    ${ultarget_throughput}    ${dltarget_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${upload_tp}=${True}
    ${ul_tput}    ${dl_tput}    sgptp.get_bi_sigspark_throughput    tput=${tput_output}
    run keyword and continue on failure    sgptp.check_bi_sigspark_throughput    tput=${tput_output}
    ...                                    ul_target_throughput=${ultarget_throughput}    dl_target_throughput=${dltarget_throughput}
    ...                                    target_avg_percent=${target_avg_percent}
    run keyword if    '${upload_tp}'=='${True}'    run keyword and ignore error    RobotCaseInfo.add_sigspark_tp
    ...                             cell=${ue_alias}    tput=${ul_tput}    direction=ul
    ...                             target_tp=${ultarget_throughput}
    ...                             avg_percent=${target_avg_percent}    min_percent=${min_percent}
    run keyword if    '${upload_tp}'=='${True}'    run keyword and ignore error    RobotCaseInfo.add_sigspark_tp
    ...                             cell=${ue_alias}    tput=${dl_tput}    direction=dl
    ...                             target_tp=${dltarget_throughput}
    ...                             avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Return]    ${ul_tput}    ${dl_tput}
