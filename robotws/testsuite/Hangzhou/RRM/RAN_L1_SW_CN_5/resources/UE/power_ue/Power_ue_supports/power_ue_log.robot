*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com
Library    String
Library    OperatingSystem
Library    DateTime
Library    Collections
#Resource    ${CURDIR}/../../../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Keywords ***
################################## LOG KEYWROD ##################################
power_ue.Logging into log file
    [Arguments]    ${log_file}    ${log_folder}    ${massage}
    OperatingSystem.remove file    ${log_file}
    Create directory    ${log_folder}
    append to file    ${log_file}    ${massage}

power_ue.Logging peak information
    [Arguments]    ${dl_tput}    ${ul_tput}    ${theory_dl_peak}    ${theory_ul_peak}
    ...            ${acceptable_tput_percentage}    ${cell_id}    ${scf_dir_path}=${OUTPUT DIR}
    ${real_dl_tput}    ${real_ul_tput}    ${real_dl_percent}    ${real_ul_percent}    ${acceptable_tput_percentage}
    ...    power_ue.Caculate real peak throughput    dl_tput=${dl_tput}
    ...                                              ul_tput=${ul_tput}
    ...                                              theory_dl_peak=${theory_dl_peak}
    ...                                              theory_ul_peak=${theory_ul_peak}
    ...                                              acceptable_tput_percentage=${acceptable_tput_percentage}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}
    ...            Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Cloud DU connect to gnb coam via ssl
    ...    ELSE    Wait Until Keyword Succeeds    5min    30s    coam_gnb_classical.Connect to gnb coam via ssl
    ${scf_path}    COAM Download scf from cluster    scf_dir_path=${scf_dir_path}    connection=GNB_OAM
    scfas.setup    scf_path=${scf_path}
    ${frame_structure}    scfas.get_frame_structure_from_scf    cell_id=${cell_id}
    ${bandwidth}    scfas.get_band_from_scf    cell_id=${cell_id}
    ${console_log_info}    catenate    Frame Structure: ${frame_structure}
    ...         \nRealtime throughput in DL&UL: ${real_dl_tput}Mbits/sec ${real_ul_tput}Mbits/sec
    ...         \nTheory peak throughput in DL&UL: ${theory_dl_peak}Mbits/sec ${theory_ul_peak}Mbits/sec
    ...         \nPercentage of peak traffic in DL&UL: ${real_dl_percent}% ${real_ul_percent}%
    BuiltIn.log to console    ${console_log_info}
    &{peak_data}    create dictionary    real_dl_tput=${real_dl_tput}    theory_dl_peak=${theory_dl_peak}    real_dl_percent=${real_dl_percent}%
    ...                                  real_ul_tput=${real_ul_tput}    theory_ul_peak=${theory_ul_peak}    real_ul_percent=${real_ul_percent}%
    ...                                  acceptable_tput_percentage=${acceptable_tput_percentage}%
    RobotCaseInfo.add_traffic_report_data    cell_id=${cell_id}    traffic_data=${peak_data}
    ...                                      frame_structure=${frame_structure}    bandwidth=${bandwidth}
    [Teardown]    abts_admin.teardown    connection=GNB_OAM

power_ue.Caculate real peak throughput
    [Arguments]    ${dl_tput}    ${ul_tput}    ${theory_dl_peak}    ${theory_ul_peak}
    ...            ${acceptable_tput_percentage}
    ${real_dl_tput}    set variable if    '${dl_tput}'=='${None}'    0    ${dl_tput}
    ${real_ul_tput}    set variable if    '${ul_tput}'=='${None}'    0    ${ul_tput}
    ${real_dl_tput}    convert to number    ${real_dl_tput}
    ${real_ul_tput}    convert to number    ${real_ul_tput}
    ${theory_dl_peak}    convert to number    ${theory_dl_peak}
    ${theory_ul_peak}    convert to number    ${theory_ul_peak}
    ${acceptable_tput_percentage}    convert to number    ${acceptable_tput_percentage}
    ${real_dl_percent}    evaluate    ${real_dl_tput} / ${theory_dl_peak} * 100
    ${real_ul_percent}    evaluate    ${real_ul_tput} / ${theory_ul_peak} * 100
    ${real_dl_percent}    convert to integer    ${real_dl_percent}
    ${real_ul_percent}    convert to integer    ${real_ul_percent}
    ${acceptable_tput_percentage}    evaluate    ${acceptable_tput_percentage} * 100
    [Return]    ${real_dl_tput}    ${real_ul_tput}    ${real_dl_percent}    ${real_ul_percent}    ${acceptable_tput_percentage}

power_ue.Logging keyword usage
    ${tc_name}=    Replace String    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${usage_folder}    Join path    ${OUTPUT DIR}    tmp_CI    ${tc_name}
    ${usage_file}    Join path    ${usage_folder}    power_ue_usage.log
    ${usage_1}    set variable if    ${prepare_use} and ${attach_use} and ${start_traffic_use}    ${True}    ${False}
    ${usage_2}    set variable if    ${check_tput_use} and ${stop_traffic_use} and ${detach_use}    ${True}    ${False}
    ${power_ue_usage}    set variable if    ${usage_1} and ${usage_2}    ${True}    ${False}
    ${usage_information}    catenate    Power UE summary: ${power_ue_usage}
    ...                                 \n keyword squence: prepare | attach | start traffic | check tput | stop traffic | detach
    ...                                 \n Each keyword usage: [${prepare_use} ${attach_use} ${start_traffic_use}
    ...                                                         ${check_tput_use} ${stop_traffic_use} ${detach_use}]
    power_ue.Logging into log file    log_file=${usage_file}    log_folder=${usage_folder}    massage=${usage_information}
