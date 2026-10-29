*** Settings ***
Force Tags    PY36
Documentation
...    author: liujia
...    contact: jia-rebecca.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC002056_BGAR_2200


Suite Setup    Run Keywords
...    robot_common_operations.Common Suite Setup    AND
...    Common Suite Setup for COAM 2200
...    AND    Prepare testline to cell on air for suite cases

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Run Keyword And Ignore Error     Common Suite Teardown for COAM

Resource       ./Resources/5GC002056_BGAR_2200_common_keywords.robot
Variables      ./Resources/variables.py
Variables      ./Resources/Stream_parameter.py


*** Variables ***
${golden_scf_24R2_CA}         MRBTS-11006_TL374_golden_SCF_24R2_CA.xml
${golden_scf_25R1_CA}         MRBTS-11006_TL374_golden_SCF_25R1_CA.xml
@{Expect_target_22R2}        1200    500    200
@{Expect_target_22R3}        860     330    200
@{Expect_target_Trunk}       750     300    100
@{tput_22R2}                 1300    1000     200
@{tput_22R3}                 860     500     100
@{tput_Trunk}                750     600     100
${ASKEY_DL_PORT}              ${ue_param['data_transfer']['iperf_options']['qci'][5]}
${ASKEY_UL_PORT}              ${ue_param['data_transfer']['iperf_options']['qci'][6]}
${2200_B_nglog}           2200_B_wireshark_enable.pcap
@{att_value_24R2}         35    70    80
@{att_value_Trunk}         25    30    30
@{att_value_22R2}         25    20    55
${wireshark_C07}          2200_C07_wireshark
${csv_file_B04}             2200_B04_result.csv
${csv_file_B06}             2200_B06_result.csv
${ue_num}    1
${dltp}     50
${ultp}     1
${csv_file_2056_2200_B004}             2056_2200_B004_result_TL365.csv
${csv_file_2056_2200_B006}             2056_2200_B006_result_TL365.csv
${Gnb_cell1_dist}                  MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
${Gnb_cell2_dist}                  MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-2
${CMlenth_beamset6}                7
${CMlenth_beamset4}                5
@{ALLOWED_FAULT}    4655    4654    61652    61524    61649    1920    1907    7300    4592
${swconfig_paths}    /opt/workspace/SCF/swconfig.txt


##22R3 test on TL374##
##trunk test on TL365##
##22R2 test on TL362##

*** Test Cases ***
[1]5GC002056_BGAR_2200_C_007_PM_counter_impact_after_2200_activated
    [Documentation]
    ...    this test case is to verify interworking online modify eirp with 2200 enable.
    [Tags]      classical    CRT_22R2    CRT_TRUNK     CRT_22R3    CIT_TRUNK    CRT_22R4
    [Setup]
    robot_common_operations.Common Case Setup
    Case variable set 2056 for 2200_C_007
    Case Step for C_007
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error     Tests Recover for 2056

*** Keywords ***
Case Step for C_007
    Common Case TestLine Setup    ModifySCF_Aftercommission=True    alarm_check=True
    ...                           Modify_Para_Online=${${Modify_Para_Online}}
    sleep    180s
    Prepare MultiUE with client
    MCS SETUP AND SET ATT    att_value=${${${att_value}}[0]}
    ${cpif_log_01}=     attach UE and capture wiresharklog with new way    wiresharklog=${wireshark_C07}
    BuiltIn.Set Test Variable    ${cpif_log_01}
    Analysis 2200-C07 log    file_path=${cpif_log_01}
    UE start DLData Traffic with Diff TL with new way    dl_tput_multiue=${${dl_tput_multiue}}
    Wait Until Keyword Succeeds   1m   10s    check tput with diff tl new way    throughput=${${${throughput}}[0]}
    sleep    60s
    Wait Until Keyword Succeeds   6m   10s    Check throughput reduce    Expect_Control_Tput=${${${throughput}}[1]}
    ...                                                                  Expect_compare_Tput=${${${throughput}}[2]}
    stop traffic and detach UE with new way
    Modify EIRP Segments Configuration Online    dist_id=${${Gnb_cell_dist}}
    sleep    180s
    UE attach with Diff TL with new way
    UE start DLData Traffic with Diff TL with new way    dl_tput_multiue=${${dl_tput_multiue}}
    Wait Until Keyword Succeeds   1m   10s   check tput with diff tl new way   throughput=${${${throughput}}[0]}
    sleep    50s
    Wait Until Keyword Succeeds   6m   10s    Check throughput reduce    Expect_Control_Tput=${${${throughput}}[1]}
    ...                                                                  Expect_compare_Tput=${${${throughput}}[2]}
    Run Keyword If     '${release_info}' == 'SBTS24R1_ENB_0000'
    ...      Set Suite Variable     ${counter_dic_path_CELL1_24R2}      ${counter_dic_path_CELL1}
    Check the PM counter shuould not be 0    counter_id=${counter_id_C07_1}    dic_path=${counter_dic_path_CELL1_24R2}
    ...                                      counter_lenth=${${CMlenth}}
    Check the PM counter shuould be 0    counter_id=${counter_id_C07_0}    dic_path=${counter_dic_path_CELL1_24R2}    out_of_beamid=6
    [Teardown]     Run Keywords
    ...     stop traffic and MCS teardown with new way    mcs_type=${mcs_type}     AND
    ...     Run Keyword And Ignore Error    Run keyword if    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS24R2_ENB_0000'
    ...                                                        Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...                                                                                      golden_scf_name=${golden_scf_24R2_CA}   AND
    ...     Run Keyword And Ignore Error    Run keyword if    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS25R1_ENB_0000'
    ...                                                        Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...                                                                                      golden_scf_name=${golden_scf_25R1_CA}

Modify EIRP Segments Configuration Online
    [Arguments]     ${dist_id}    ${version}=None
    Run Keyword If    '${release_info}' == 'SBTS24R1_ENB_0000'    Set Suite Variable    ${sw_version}    SBTS24R1
    Run Keyword If    '${release_info}' == 'SBTS24R2_ENB_0000'    Set Suite Variable    ${sw_version}    SBTS24R2
    Run Keyword If    '${release_info}' == 'SBTS24R3_ENB_0000'    Set Suite Variable    ${sw_version}    SBTS24R3
    Run Keyword If    '${release_info}' == 'SBTS25R1_ENB_9999'    Set Suite Variable    ${sw_version}    SBTS25R1
    Run Keyword If    '${release_info}' == 'SBTS25R2_ENB_9999'    Set Suite Variable    ${sw_version}    SBTS25R1
    Run Keyword If    '${release_info}' == 'SBTS25R1_ENB_0000'    Set Suite Variable    ${sw_version}    SBTS25R1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ...                    version=${sw_version}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box
    selenium_coam.set_parameter_value    dist_name=${dist_id}
    ...    filter_param=Number of cell segment edges in azimuth
    ...    new_value=2
    selenium_coam.set_parameter_value    dist_name=${dist_id}
    ...    filter_param=Cell segment edge azimuth 1
    ...    new_value=20
    Run Keyword And Ignore Error    selenium_coam.delete_parameter    dist_name=${dist_id}
    ...    filter_param=Cell segment edge azimuth 2
    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=${dist_id}
    ...    filter_param=List of EIRP control power reduction factor per cell segment
    ...    node_index=0
    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=${dist_id}
    ...    filter_param=List of EIRP control power reduction factor per cell segment
    ...    node_index=1
    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=${dist_id}
    ...    filter_param=List of EIRP control power reduction factor per cell segment
    ...    node_index=2
    selenium_coam.set_parameter_value    dist_name=${dist_id}
    ...    filter_param=Cell segment edge elevation 0
    ...    new_value=33
    selenium_coam.set_parameter_value    dist_name=${dist_id}
    ...    filter_param=Cell segment edge elevation 1
    ...    new_value=30
    sleep    3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    3s
    selenium_coam.logout
    sleep    5s


Case Step
    [Arguments]      ${att_value}    ${csv_file}    ${dlexpect}    ${Expect_target}
    UE precondition with uetype
    MCS SETUP AND SET ATT    att_value=${att_value}
    UE attach with Diff uetype    ue_num=1
    UE start DLData Traffic with Diff uetype    ue_num=1    dlexpect=${dlexpect}
    sleep    10s
    Performance Test around    ATT=${att_value}    dlexpect=${dlexpect}    csv_path=${epc_log_path}/${csv_file}
    Caculate average tput    csv_path=${epc_log_path}${csv_file}
    UE stop traffic and detach with uetype
    Set test variable       ${Expect_tp}    ${Expect_target}
    should be true    ${ave_Tput} > ${Expect_tp}
    MCS Teardown with mcs_type    mcs_type=${mcs_type}

MCS SETUP AND SET ATT
    [Arguments]    ${att_value}
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE   mcs_type=${mcs_type}
    ...    att_value_1=${att_value}    att_value_2=${att_value}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${15}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${25}
    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${-6}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}
    Run keyword if    '${mcs_type}'=='hbte'    HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    vertical_distance=${2.0}   horizontal_distance=${0.5}
    ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${96}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}


Check throughput reduce
    [Arguments]    ${Expect_Control_Tput}    ${Expect_compare_Tput}
    ${dlul_tp_l2l0}      Check one UE traffic with pioneer client    tput_target=${Expect_compare_Tput}
    should be true    ${Expect_Control_Tput} > ${dlul_tp_l2l0}
