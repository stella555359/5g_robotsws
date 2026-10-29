# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    author: liujia
# ...    contact:jia-rebecca.liu@nokia-sbell.com
# ...    squad group: SG_03
# ...    feature : 5GC002200
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
# Resource       Resources/5GC002200_coam_common_keywords.robot
# 
# 
# *** Variables ***
# @{DL_expect_22R2}          1200    700    200
# @{DL_expect_Trunk}          750    350    150
# @{DL_expect_22R3}          1000    350    150
# ${2200_B_wireshark}           74278_A02_wireshark
# ${ASKEY_DL_PORT}              ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# ${ASKEY_UL_PORT}              ${ue_param['data_transfer']['iperf_options']['qci'][6]}
# @{att_value_22R2}            25    40    55    60
# @{att_value_Trunk}            0    30    55    10
# @{att_value_22R3}            40    60    70    10
# ${get_tti_name}         ls -l | grep *.dl__all.csv |awk '{print $9}'
# ${dl_data_hold}             50M
# ${dl_Multi_data_hold}            1000Mbits/sec
# ${filter_name}         csiSrReportData.csiReport.cri
# 
# 
# ##22R2 test on TL362##
# ##TRUNK test on TL365##
# ##22R3 test on TL374##
# 
# *** Test Cases ***
# [1]CNI74278_A_02_SA_max_DLUL_Tput_with_4CSI-RS_4x1_#2#2_3_3_BW_80M_1116
#     [Documentation]
#     ...    The purpose of this test case is to verify cell on air after NIDD NRCELL.csirsResourceSetConfig4CRI set to 4x1_#2#2_3_3;
#     ...    DL and UL can get peak tput with the right beamweight.
#     ...    2022-1-12,due to 2200 cases optimize, tmpParam9 will change to 20:2x2_#2#2_5_5;
#     ...    beamset will be (2+4)x(4+64)+ 1x(4+16) = 428;
#     ...    "2x2 is already using all vertical freedom with 32TRX RU(2TRX rows).
#     ...     That is the reason why in 2x2-2-2_5_5 configurations we have basically only the left and right CRI.
#     ...    Only 64TRX RU can have intended 2x2-2-2_5_5 configuration with two vertical rows"
#     ...    CNI72687 Counter Num=miNrCellUtilization(min)/csiReportPeriodicity(ms)  e.g.   5min/160ms = 1875
#     ...    2022-3-9, add 72687 4csirs cri counters checkpoints.
#     [Tags]      classical    CRT_22R2    CRT_TRUNK     CRT_22R3    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]    robot_common_operations.Common Case Setup
#     Case variable set for 74278_A_02
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
#     ${cpif_log_01}=     attach UE with uetype and capture wiresharklog    wiresharklog=${2200_B_wireshark}    ue_num=1
#     BuiltIn.Set Test Variable    ${cpif_log_01}
#     Analysis 2200 enable    pcap_file=${cpif_log_01}
#     Check beamweight for CNI74278    beamweight_name=${${beamweight_name}}    connection=gnb    beamset_num=428
#     Check beamweight size for CNI65655    beamweight_name=${${beamweight_name}}    connection=gnb    bpf_name=${${bpf_name}}
#     ...                                   ungzip_bpf_name=${${ungzip_bpf_name}}    bpf_name_xml=${${bpf_name_xml}}
#     Start UE traffic and check tput    dlexpect_tp=${@{${dlexpect_tp}}[0]}
#     run keyword if      '${MRBTS_ID}' == '10318'      Check UE in the right CRI location on second bbmod
#     run keyword if      '${MRBTS_ID}' == '10175'      Check UE in the right CRI location on first bbmod
#     run keyword if      '${MRBTS_ID}' == '11006'      Check UE in the right CRI location on fifth bbmod
#     UE stop traffic and detach with uetype
#     MCS Teardown with mcs_type    mcs_type=${mcs_type}
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
# Change UE location for CRI
#     [Arguments]     ${vertical}    ${horizontal_1}    ${horizontal_2}    ${mcs_type}=${mcs_type}
#     Run keyword if    '${mcs_type}'=='haojin'
#     ...                HAOJIN MCS change UE Phases    mcs_type=${mcs_type}
#     ...    begin_output_port_1=${13}    end_output_port_2=${14}    vertical_angle_1=${vertical}     horizontal_angle_1=${horizontal_1}
#     ...    begin_output_port_3=${15}    end_output_port_4=${16}    vertical_angle_2=${vertical}     horizontal_angle_2=${horizontal_2}
#     Run keyword if    '${mcs_type}'=='topyoung'
#     ...                TOPYOUNG MCS change UE Phases    mcs_type=${mcs_type}
#     ...         first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${horizontal_1}
#     ...         second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${horizontal_2}
#     ...         vertical_angle=${vertical}
#     Run keyword if    '${mcs_type}'=='hbte'    HBTE MCS change UE Phases    mcs_type=${mcs_type}    vertical_angle=${vertical}
#     ...    first_beam_begin_output_port=${5}      first_beam_end_output_port=${6}
#     ...    first_beam_horizontal_angle=${horizontal_1}
#     ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
#     ...    second_beam_horizontal_angle=${horizontal_2}
# 
# 
# 
# Check UE in the right CRI location on first bbmod
#     Change UE location for CRI    vertical=${92}    horizontal_1=${-25}    horizontal_2=${-35}
#     sleep    10s
#     Capture tti trace from Gnb logs    BBMOD=${${BBMOD_ID}}    output_match=finished
#     Get tti trace from gnb logs tool    tti_logs_rename=gnb_logs_TTI00
#     Analysis tti file for CRI    tti_logs_rename=gnb_logs_TTI00    CRI=0    BBMOD_TTI=fsp-1a-L2RT20_ttiTrace
#     log to console       start sleep 1min to generate cri0 counter...
#     sleep    1min
#     Change UE location for CRI    vertical=${92}    horizontal_1=${25}      horizontal_2=${35}
#     sleep    10s
#     Capture tti trace from Gnb logs    BBMOD=${${BBMOD_ID}}    output_match=finished
#     Get tti trace from gnb logs tool    tti_logs_rename=gnb_logs_TTI01
#     Analysis tti file for CRI    tti_logs_rename=gnb_logs_TTI01    CRI=1    BBMOD_TTI=fsp-1a-L2RT20_ttiTrace
#     log to console       start sleep 1min to check cri1 counter
#     sleep    1min
#     Change UE location for CRI    vertical=${105}    horizontal_1=${-25}    horizontal_2=${-35}
#     sleep    10s
#     Capture tti trace from Gnb logs    BBMOD=${${BBMOD_ID}}    output_match=finished
#     Get tti trace from gnb logs tool    tti_logs_rename=gnb_logs_TTI02
#     Analysis tti file for CRI    tti_logs_rename=gnb_logs_TTI02    CRI=2    BBMOD_TTI=fsp-1a-L2RT20_ttiTrace
#     log to console       start sleep 1min to check cri2 counter
#     sleep    1min
#     Change UE location for CRI    vertical=${105}    horizontal_1=${25}    horizontal_2=${35}
#     sleep    10s
#     Capture tti trace from Gnb logs    BBMOD=${${BBMOD_ID}}    output_match=finished
#     Get tti trace from gnb logs tool    tti_logs_rename=gnb_logs_TTI03
#     Analysis tti file for CRI    tti_logs_rename=gnb_logs_TTI03     CRI=3    BBMOD_TTI=fsp-1a-L2RT20_ttiTrace
#     log to console       start sleep 1min to check cri3 counter
#     sleep    1min
#     Connect to gnb coam via ssl
#     ${cri0_counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${cri_counter_id[3]}    connection=GNB_OAM
#     ...    dic_path=${counter_dic_path[0]}
#     ${cri1_counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${cri_counter_id[4]}    connection=GNB_OAM
#     ...    dic_path=${counter_dic_path[0]}
#     ${cri2_counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${cri_counter_id[5]}    connection=GNB_OAM
#     ...    dic_path=${counter_dic_path[0]}
#     ${cri3_counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${cri_counter_id[6]}    connection=GNB_OAM
#     ...    dic_path=${counter_dic_path[0]}
#     ${value}    Evaluate    ${cri0_counter_value[0]}+${cri1_counter_value[0]}+${cri2_counter_value[0]}+${cri3_counter_value[0]}
#     Should be true    1874<=${${value}}<=1876
#     log to console       check cri counter successfully!
# 
# Check UE in the right CRI location on fifth bbmod
#     Change UE location for CRI    vertical=${94}    horizontal_1=${15}    horizontal_2=${25}
#     sleep    10s
#     Capture tti trace from Gnb logs    BBMOD=5    output_match=finished
#     Get tti trace from gnb logs tool    tti_logs_rename=gnb_logs_TTI00
#     Analysis tti file for CRI    tti_logs_rename=gnb_logs_TTI00    CRI=1    BBMOD_TTI=fsp-2-5a-L2RT20_ttiTrace
#     log to console       start sleep 1min to generate cri1 counter...
#     sleep    1min
#     Change UE location for CRI    vertical=${94}    horizontal_1=${-25}      horizontal_2=${-35}
#     sleep    10s
#     Capture tti trace from Gnb logs    BBMOD=5    output_match=finished
#     Get tti trace from gnb logs tool    tti_logs_rename=gnb_logs_TTI01
#     Analysis tti file for CRI    tti_logs_rename=gnb_logs_TTI01    CRI=2    BBMOD_TTI=fsp-2-5a-L2RT20_ttiTrace
#     log to console       start sleep 1min to check cri2 counter
#     sleep    4min
#     Connect to gnb coam via ssl
#     ${cri0_counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${cri_counter_id[3]}    connection=GNB_OAM
#     ...    dic_path=${counter_dic_path[0]}
#     ${cri1_counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${cri_counter_id[4]}    connection=GNB_OAM
#     ...    dic_path=${counter_dic_path[0]}
#     ${cri2_counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${cri_counter_id[5]}    connection=GNB_OAM
#     ...    dic_path=${counter_dic_path[0]}
#     ${cri3_counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${cri_counter_id[6]}    connection=GNB_OAM
#     ...    dic_path=${counter_dic_path[0]}
#     ${value}    Evaluate    ${cri0_counter_value[0]}+${cri1_counter_value[0]}+${cri2_counter_value[0]}+${cri3_counter_value[0]}
#     Should be true    3749<=${${value}}<=3751
#     log to console       check cri counter successfully!
# 
# 
# Check UE in the right CRI location on second bbmod
#     Change UE location for CRI    vertical=${-6}    horizontal_1=${-20}    horizontal_2=${-30}
#     sleep    30s
#     Run Keyword If    '${release_info}' == 'SBTS23R2_ENB_9999'
#     ...    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_1    nr_phy_cell_ids=51
#     ...    ELSE    Capture tti trace from Gnb logs    BBMOD=2        output_match=finished
#     Run Keyword If    '${release_info}' == 'SBTS22R4_ENB_0000'
#     ...    Get tti trace from gnb logs tool    tti_logs_rename=gnb_logs_TTI00
#     Run Keyword If    '${release_info}' == 'SBTS23R2_ENB_9999'
#     ...     Analysis tti file for CRI for Admin    names=l2stream3_ttitrace_1    CRI=${0}
#     ...    ELSE    Analysis tti file for CRI    tti_logs_rename=gnb_logs_TTI00    CRI=0    BBMOD_TTI=fsp-2a-L2RT30_ttiTrace
#     Change UE location for CRI    vertical=${-6}    horizontal_1=${15}    horizontal_2=${25}
#     sleep    30s
#     Run Keyword If    '${release_info}' == 'SBTS23R2_ENB_9999'
#     ...    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_2    nr_phy_cell_ids=51
#     ...    ELSE    Capture tti trace from Gnb logs    BBMOD=2        output_match=finished
#     Run Keyword If    '${release_info}' == 'SBTS22R4_ENB_0000'
#     ...    Get tti trace from gnb logs tool    tti_logs_rename=gnb_logs_TTI01
#     Run Keyword If    '${release_info}' == 'SBTS23R2_ENB_9999'
#     ...     Analysis tti file for CRI for Admin    names=l2stream3_ttitrace_2    CRI=${1}
#     ...    ELSE    Analysis tti file for CRI    tti_logs_rename=gnb_logs_TTI01    CRI=1    BBMOD_TTI=fsp-2a-L2RT30_ttiTrace
# 
# 
# 
# Analysis tti file for CRI
#     [Arguments]    ${tti_logs_rename}=${tti_logs_rename}    ${epc_log_path}=${epc_log_path}    ${CRI}=${CRI}
#     ...            ${BBMOD_TTI}=${BBMOD_TTI}
#     log to console    analysis tti file from Case_Logs file...
#     csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
#     csn.send command    command=cd ${epc_log_path}/${tti_logs_rename}/tti_packed/${BBMOD_TTI}/&&${get_tti_name}
#     ...                 connection=ute
#     ${tti_dl_file}=    csn.Read Output    connection=ute
#     @{tti_file_name}    String.split string    string=${tti_dl_file}    separator=\n
#     ${CRI_RATE}    read_cri_rate    ${epc_log_path}${tti_logs_rename}/tti_packed/${BBMOD_TTI}/@{tti_file_name}[0]    ${CRI}
#     should be true      ${CRI_RATE} > 0.5
# 
# Analysis tti file for CRI for Admin
#     [Arguments]    ${names}    ${CRI}=${CRI}    ${epc_log_path}=${epc_log_path}
#     log to console    analysis tti file from Case_Logs file...
#     ${CRI_RATE}    count_required_value    csv_file=${epc_log_path}/${names}_dl.csv     filter_name=${filter_name}    count_value=${CRI}
#     should be true      ${CRI_RATE} > 0.5
# 
# Analysis 2200 enable
#     [Arguments]    ${pcap_file}=${cpif_log_01}
#     ${nrofPorts}=    Get CSIRS_nrofPorts from CPIF    file_path=${pcap_file}
#     should contain x times    ${nrofPorts}    p8    4
#     ${cdm_Type}=     Get CSIRS_cdm_Type from CPIF     file_path=${pcap_file}
#     should contain    ${cdm_Type}    2
#     ${density}=      Get CSIRS_density from CPIF      file_path=${pcap_file}
#     should contain    ${density}     1
#     ${n1-n2}=        Get CSIRS_n1_n2 from CPIF        file_path=${pcap_file}
#     should contain    ${n1-n2}       1
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
