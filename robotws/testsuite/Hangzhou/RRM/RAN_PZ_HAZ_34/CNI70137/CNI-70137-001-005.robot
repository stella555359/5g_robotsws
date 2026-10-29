# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    author: liujia
# ...    contact:jia-rebecca.liu@nokia-sbell.com
# ...    squad group: SG_03
# ...    feature : CNI70137
# 
# 
# 
# Suite Setup         Run keywords
# ...    robot_common_operations.Common Suite Setup    AND
# ...    Run Keyword And Ignore Error       Common Suite Setup for COAM 2200
# 
# Suite Teardown      Run keywords
# ...    robot_common_operations.Common Suite Teardown    AND
# ...    Run Keyword And Ignore Error       Common Suite Teardown for COAM
# 
# 
# 
# 
# 
# Resource       ./../5GC002200/Resources/5GC002200_coam_common_keywords.robot
# 
# 
# *** Variables ***
# @{dlexpect_tp_22R2}           900
# @{dlexpect_tp_Trunk}          700
# @{dlexpect_tp_22R3}           900
# ${2200_B_wireshark_1}            70137_wireshark_005_1
# ${2200_B_wireshark_2}            70137_wireshark_005_2
# ${Send_Tput_DL}             1200M
# ${ASKEY_DL_PORT}            ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# ${ASKEY_UL_PORT}            ${ue_param['data_transfer']['iperf_options']['qci'][6]}
# @{att_value_22R2}          25    55    75    127
# @{att_value_Trunk}           5    55    75    127
# @{att_value_22R3}          20    50    70    127
# ${ue_num}                   1
# 
# ##22R2 test on TL362##
# ##TRUNK test on TL365##
# ##22R3 test on TL374##
# 
# *** Test Cases ***
# [1]CNI-70137_005_CSIRS_reconfiguration_with_maxCsirsNumber=4_long_PUCCH_when_DRX_on_duration_is_small_Qualcomm_UE
#     [Documentation]
#     ...    Purpose of this case is to validate the CSIRS number reconfigured to Qualcomm UE which support simultaneousCSI-ReportsPerC=4 when DRX
#     ...    on duration is long enough to allocate 4CSIRS
#     [Tags]      classical    CRT_TRUNK     CRT_22R2    CRT_22R3    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]    robot_common_operations.Common Case Setup
#     Case variable set for 70137_005
#     Common Case TestLine Setup    ModifySCF_Beforecommission=True    Is_Swconfig=True     Lock_ENB_Need=True
#     ...                           swconfig_file=${swconfig}    golden_scf_name=${${golden_scf_name}}
#     ...                           ParamterToModify=${${ParamterToModify}}
#     ...                           ListParamterToModify=${${ListParamterToModify}}
#     ...                           enb_dist_name=${ENB_cell1_dist}
#     ...                           enb_parameter=${enb_cell_admin}
#     ...                           enb_value=locked
#     Set nrcellid suit varaible    cellid=${${cellid}}
#     UE precondition with uetype
#     MCS SETUP AND SET ATT         att_value=${@{${att_value}}[0]}
#     ${cpif_log_01}=     attach UE with uetype and capture wiresharklog    wiresharklog=${2200_B_wireshark_1}    ue_num=1
#     BuiltIn.Set Test Variable    ${cpif_log_01}
#     Start UE traffic and check tput    ue_num=1    dlexpect_tp=${@{${dlexpect_tp}}[0]}
#     UE stop traffic and detach with uetype
#     Modify the COAM parameter with admin API     parameters=${${DRX_onduration}}
#     sleep    10s
#     ${cpif_log_02}=     attach UE with uetype and capture wiresharklog    wiresharklog=${2200_B_wireshark_2}    ue_num=1
#     BuiltIn.Set Test Variable    ${cpif_log_02}
#     UE stop traffic and detach with uetype
#     MCS Teardown with mcs_type    mcs_type=${mcs_type}
#     Analysis 70137_005 70851
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Run Keyword And Ignore Error     Tests Recover
# 
# *** Keywords ***
# MCS SETUP AND SET ATT
#     [Arguments]    ${att_value}
#     ${mcs_type}=    mcs_common.Get MCS Type
#     set suite variable      ${mcs_type}
#     Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE   mcs_type=${mcs_type}
#     ...    att_value_1=${att_value}    att_value_2=${att_value}
#     ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${-8}
#     ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${8}
#     Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#     ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${-6}
#     ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-3}
#     ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-13}
#     Run keyword if    '${mcs_type}'=='hbte'    HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#     ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${96}
#     ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${-5}
#     ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${-15}
# 
# 
# Analysis 70137_005 70851
#     ${nrofPorts_1}=    Get CSIRS_nrofPorts from CPIF    file_path=${cpif_log_01}
#     should contain x times    ${nrofPorts_1}    p8    4
#     ${cdm_Type_1}=    Get CSIRS_cdm_Type from CPIF    file_path=${cpif_log_01}
#     should contain    ${cdm_Type_1}    2
#     ${density_1}=    Get CSIRS_density from CPIF    file_path=${cpif_log_01}
#     should contain    ${density_1}    1
#     ${n1_n2_1}=    Get CSIRS_n1_n2 from CPIF    file_path=${cpif_log_01}
#     should contain    ${n1_n2_1}    1
#     ${longpucch_1}=    Get LongPucch_format from CPIF    file_path=${cpif_log_01}
#     ${longpucch_1_result}=    Evaluate     '1' in ${longpucch_1} and '3' in ${longpucch_1}
#     should be true    ${longpucch_1_result}
#     ${nrofPorts_2}=    Get CSIRS_nrofPorts from CPIF    file_path=${cpif_log_02}
#     should contain x times    ${nrofPorts_2}    p8    2
#     ${density_2}=    Get CSIRS_density from CPIF    file_path=${cpif_log_02}
#     should contain    ${density_2}    1
#     ${n1_n2_2}=    Get CSIRS_n1_n2 from CPIF    file_path=${cpif_log_02}
#     should contain    ${n1_n2_2}    1
#     ${longpucch_2}=    Get LongPucch_format from CPIF    file_path=${cpif_log_02}
#     ${longpucch_2_result}=    Evaluate     '1' in ${longpucch_2} and '3' in ${longpucch_2}
#     should be true    ${longpucch_2_result}
#     SSB_report should in DRX
#     CQI_report should in DRX
#     CSIRS_slot should in DRX
# 
# 
# SSB_report should in DRX
#     [Arguments]    ${70137_005}=${cpif_log_02}
#     ${drx_startoffset}=    Get DRX_StarOffset from CPIF    file_path=${70137_005}
#     ${drx_slotoffset}=    Get DRX_slotoffset from CPIF    file_path=${70137_005}
#     ${drx_onduration}=    Get DRX_onduration timer from CPIF    file_path=${70137_005}
#     ${bm_report}=     Get SSB_Reportslot from CPIF    file_path=${70137_005}
#     ${cqi_report}=     Get CQI_Reportslot from CPIF    file_path=${70137_005}
#     ${drx_onduration_startslot}    Evaluate    (${drx_startoffset}+${drx_slotoffset})*2
#     ${drx_onduration_endslot}    Evaluate    ${drx_onduration_startslot}+${drx_onduration}*2-1
#     ${DRX_period}=     Get DRX_LongCycle from CPIF    file_path=${70137_005}
#     ${DRX_LongCycle}=    String.Remove String    ${DRX_period}    ms
#     FOR    ${n}    IN RANGE    0    5
#        ${SSB_report}=    Evaluate    ${bm_report}+${DRX_LongCycle}*${n}
#        ${status_1}=    Run Keyword And Return Status    ${drx_onduration_startslot} <= ${SSB_report} <= ${drx_onduration_endslot}
#        Exit For Loop If    '${status_1}' == 'PASS'
#     END
# 
# CQI_report should in DRX
#     [Arguments]    ${70137_005}=${cpif_log_02}
#     ${drx_startoffset}=    Get DRX_StarOffset from CPIF    file_path=${70137_005}
#     ${drx_slotoffset}=    Get DRX_slotoffset from CPIF    file_path=${70137_005}
#     ${drx_onduration}=    Get DRX_onduration timer from CPIF    file_path=${70137_005}
#     ${bm_report}=     Get SSB_Reportslot from CPIF    file_path=${70137_005}
#     ${cqi_report}=     Get CQI_Reportslot from CPIF    file_path=${70137_005}
#     ${drx_onduration_startslot}    Evaluate    (${drx_startoffset}+${drx_slotoffset})*2
#     ${drx_onduration_endslot}    Evaluate    ${drx_onduration_startslot}+${drx_onduration}*2-1
#     ${DRX_period}=     Get DRX_LongCycle from CPIF    file_path=${70137_005}
#     ${DRX_LongCycle}=    String.Remove String    ${DRX_period}    ms
#     FOR    ${n}    IN RANGE    0    5
#        ${SSB_report}=    Evaluate     ${bm_report}+${DRX_LongCycle}*${n}
#        ${status_2}=    Run Keyword And Return Status    ${drx_onduration_startslot} <= ${cqi_report} <= ${drx_onduration_endslot}
#        Exit For Loop If    '${status_2}' == 'PASS'
#     END
# 
# CSIRS_slot should in DRX
#     [Arguments]    ${70137_005}=${cpif_log_02}
#     ${drx_startoffset}=    Get DRX_StarOffset from CPIF    file_path=${70137_005}
#     ${drx_slotoffset}=    Get DRX_slotoffset from CPIF    file_path=${70137_005}
#     ${drx_onduration}=    Get DRX_onduration timer from CPIF    file_path=${70137_005}
#     ${drx_onduration_startslot}    Evaluate    (${drx_startoffset}+${drx_slotoffset})*2
#     ${drx_onduration_endslot}    Evaluate    ${drx_onduration_startslot}+${drx_onduration}*2-1
#     ${csirs_slot}=    Get CSIRS_StartOffset from CPIF    file_path=${70137_005}
#     ${csirs_period_0}=    Get CSIRS_periodicity from CPIF    file_path=${70137_005}
#     ${csirs_period}=    String.Remove String    ${csirs_period_0}    slots
#     FOR    ${n}    IN RANGE    0    5
#        ${csirs_slot}=    Evaluate    ${csirs_slot}+${csirs_period}*${n}
#        ${status_3}=    Run Keyword And Return Status    ${drx_onduration_startslot} <= ${csirs_slot} <= ${drx_onduration_endslot}
#        Exit For Loop If    '${status_3}' == 'PASS'
#     END
# 
# 
# Tests Recover
#     Run Keyword And Ignore Error     Common Case TestLine Setup     Lock_ENB_Need=True     enb_dist_name=${${ENB_cell_dist}}
#     ...                                                             enb_parameter=${enb_cell_admin}
#     ...                                                             enb_value=unlocked
#     run keyword if    '${MRBTS_ID}' == '10318'     Run Keyword And Ignore Error
#     ...                Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL1}
#     Run Keyword And Ignore Error    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
#     Run Keyword And Ignore Error    csn.send command    command=killall tcpdump     connection=gnb
#     Run Keyword And Ignore Error    Connect to TestPc    alias=ute
#     Run Keyword And Ignore Error    csn.send command
#     ...                   command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ute
#     Run Keyword And Ignore Error    UE stop traffic and detach with uetype
#     Run Keyword And Ignore Error    MCS Teardown with mcs_type    mcs_type=${mcs_type}
#     Run Keyword And Ignore Error    clear cli process
#     Run Keyword And Ignore Error    disconect all connections
# 
# 
# 
