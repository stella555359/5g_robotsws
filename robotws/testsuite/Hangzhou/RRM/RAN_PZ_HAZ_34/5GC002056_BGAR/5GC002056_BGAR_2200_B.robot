*** Settings ***
Force Tags    PY36
Documentation
...    author: liujia
...    contact: jia-rebecca.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC002056_BGAR_2200
#
#
#Suite Setup    Run Keywords
#...    robot_common_operations.Common Suite Setup    AND
#...    Common Suite Setup for COAM 2200    AND
#...    Prepare testline to cell on air for suite cases
#
#Suite Teardown      Run keywords
#...    robot_common_operations.Common Suite Teardown    AND
#...    Run Keyword And Ignore Error       Common Suite Teardown for COAM
#
#
#Resource       ./Resources/5GC002056_BGAR_2200_common_keywords.robot
#Variables      ./Resources/variables.py
#Variables      ./Resources/Stream_parameter.py
#
#
#*** Variables ***
#@{Expect_target_22R2}        1200    500    200
#@{Expect_target_22R3}        860     300    200
#@{Expect_target_Trunk}       750     300    100
#@{tput_22R2}                 1300    1000     200
#@{tput_22R3}                 860     500     200
#@{tput_Trunk}                750     600     600
#${ASKEY_DL_PORT}              ${ue_param['data_transfer']['iperf_options']['qci'][5]}
#${ASKEY_UL_PORT}              ${ue_param['data_transfer']['iperf_options']['qci'][6]}
#${2200_B_nglog}           2200_B_wireshark_enable.pcap
#@{att_value_22R3}         40    70    80
#@{att_value_Trunk}         25    30    30
#@{att_value_22R2}         10    20    55
#${wireshark_C07}          2200_C07_wireshark
#${csv_file_B04}             2200_B04_result.csv
#${csv_file_B06}             2200_B06_result.csv
#${ue_num}    1
#${dltp}     50
#${ultp}     1
#${csv_file_2056_2200_B004}             2056_2200_B004_result_TL365.csv
#${csv_file_2056_2200_B006}             2056_2200_B006_result_TL365.csv
#${Gnb_cell1_dist}                  MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
#${Gnb_cell2_dist}                  MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-2
#${CMlenth_beamset6}                7
#${CMlenth_beamset4}                5
#
#
#
###22R3 test on TL374##
###trunk test on TL365##
###22R2 test on TL362##
#
#*** Test Cases ***
#[1]5GC002056_BGAR_2200_B_004_max_DL_Tput_with_4_resources_and_beamset_6_good_condition_1208_frametype_SA
#    [Documentation]
#    ...    this test case is to verify in good air condition(around -60dbm) ,
#    ...    when 2200 feature is enabled, the average dl tput is better than the one when 2200 disabled
#    ...    n1:n2 will use 2x2, PA port 1and2, 7and8, 13and14, 15and16.
#    [Tags]      classical    CRT_22R2    CRT_TRUNK    CDRT_TRUNK      CRT_22R3    CDRT_22R4    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Case variable set 2056 for 2200_B_004
#    Case Step    att_value=${${${att_value}}[0]}    csv_file=${csv_file_B04}    dlexpect=${${${Expect_target}}[2]}
#    ...          Expect_target=${${${Expect_target}}[0]}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error     Tests Recover for 2056
#
##[1]5GC002056_BGAR_2200_B_006_DL_Tput_with_4_resources_and_beamset_6_bad_condition_1208_frametype_SA
##    [Documentation]
##    ...    this test case is to verify in bad air condition(around -100dbm) ,
##    ...    when 2200 feature is enabled, the average dl tput is better than the one when 2200 disabled
##    [Tags]      classical    CRT_22R2    CRT_TRUNK       CRT_22R3    CRT_22R4
##    [Timeout]    1 hour
##    [Setup]    robot_common_operations.Common Case Setup
##    Case variable set 2056 for 2200_B_006
##    Case Step    att_value=${@{${att_value}}[1]}    csv_file=${csv_file_B04}    dlexpect=${@{${Expect_target}}[2]}
##    ...          Expect_target=${@{${Expect_target}}[1]}
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown    AND
##    ...    Run Keyword And Ignore Error     Tests Recover for 2056
#
#*** Keywords ***
#
#Case Step
#    [Arguments]      ${att_value}    ${csv_file}    ${dlexpect}    ${Expect_target}
#    Prepare MultiUE with client
#    MCS SETUP AND SET ATT    att_value=${att_value}
#    MultiUE one Attach with client    UE_mode=${SA_attach_mode}    nettype=${0}
#    UE start DLData Traffic with Diff TL with new way     dl_tput_multiue=${${dl_tput_multiue}}
#    sleep    10s
#    Performance Test around    ATT=${att_value}    dlexpect=${dlexpect}    csv_path=${epc_log_path}/${csv_file}
#    Caculate average tput    csv_path=${epc_log_path}${csv_file}
#    Set test variable       ${Expect_tp}    ${Expect_target}
#    should be true    ${ave_Tput} > ${Expect_tp}
#    [Teardown]     stop traffic and MCS teardown with new way    mcs_type=${mcs_type}
#
#
#MCS SETUP AND SET ATT
#    [Arguments]    ${att_value}
#    ${mcs_type}=    mcs_common.Get MCS Type
#    set suite variable      ${mcs_type}
#    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE   mcs_type=${mcs_type}
#    ...    att_value_1=${att_value}    att_value_2=${att_value}
#    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${15}
#    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${25}
#    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${-6}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}
#    Run keyword if    '${mcs_type}'=='hbte'    HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${15}
#
#
#Check throughput reduce
#    [Arguments]    ${Expect_Control_Tput}    ${Expect_compare_Tput}
#    ${dlul_tp_l2l0}      Power UE check throughput with nrcellid    cellid=${1}    throughput=${Expect_compare_Tput}    ue_type=${${typeUE}}
#    should be true    ${Expect_Control_Tput} > ${dlul_tp_l2l0}
