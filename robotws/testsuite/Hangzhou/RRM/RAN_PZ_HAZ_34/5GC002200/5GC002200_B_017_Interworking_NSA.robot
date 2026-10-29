# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    author: liujia
# ...    contact:jia-rebecca.liu@nokia-sbell.com
# ...    squad group: SG_03
# ...    feature : 5GC002200
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
# Resource       Resources/5GC002200_coam_common_keywords.robot
# 
# 
# *** Variables ***
# @{DL_expect_22R2}               520    520    1000    600
# @{DL_expect_Trunk}              100    100    100    10
# @{DL_expect_22R3}               600    100    600    100
# ${2200_B_wireshark}             2200_B_wireshark_017
# ${2200_B_017_A2}                2200_B_wireshark_017_MG
# ${2200_B_017_back}              2200_B_wireshark_017_back
# ${Send_Tput_DL}                 1600M
# ${ASKEY_DL_PORT}                ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# ${ASKEY_UL_PORT}                ${ue_param['data_transfer']['iperf_options']['qci'][6]}
# @{att_value_22R2}               25     50     40
# @{att_value_Trunk}              0      40     5
# @{att_value_22R3}               40     70     50
# ${filter_pdschsendreq}          dldata_pdschsendreq
# ${CMD_pdschsendreq}             {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"${filter_pdschsendreq}\" -T pdml
# ${F1AP_COMMAND}                 {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
# ${ue_num}                       1
# ${rank4}                        4
# 
# 
# ##22R2 test on TL362##
# ##TRUNK test on TL365##
# ##22R3 test on TL374##
# 
# *** Test Cases ***
# [1]5GC002200_B_017_Interworking_with_Measurement_gap_when_feature_enable_with_4_resources_SA
#     [Documentation]
#     ...    this test case is to verify interworking with measurement gap when 2200 feature enabled with
#     ...    4 resources NSA mode. Add DRX checkpoint
#     [Tags]      classical    CRT_22R2    CRT_TRUNK     CRT_22R3    CRT_22R4
#     [Timeout]    2 hour
#     [Setup]    robot_common_operations.Common Case Setup
#     Case variable set for 2200_B_017
#     Common Case TestLine Setup     ModifySCF_Beforecommission=True    Is_Swconfig=True     gnb_type='NSA'    is_x2_check_from_gnb_needed=${True}
#     ...                            golden_scf_name=${${golden_scf_name}}     swconfig_file=${swconfig}
#     ...                            ParameterToDelete=${${ParameterToDelete}}
#     ...                            ParamterToModify=${${ParamterToModify}}
#     ...                            ListParamterToModify=${${ListParamterToModify}}
#     ...                            ListToAdd=${${ListToAdd}}
#     run keyword if    '${MRBTS_ID}' == '10318'
#     ...                Connect and Modify the parameter on enblte    dist_name=${ENB_cell1_dist}
#     ...                                                              parameter=${defaultgnbcell}     value=1
#     Set nrcellid suit varaible    cellid=${${cellid}}
#     UE precondition with uetype
#     MCS SETUP AND SET ATT    att_value=${@{${att_value}}[0]}
#     ${cpif_log_01}=     attach UE with uetype and capture wiresharklog    wiresharklog=${2200_B_wireshark}    ue_num=${ue_num}
#     ...                                                                   attach_mode=${NSA_attach_mode}    ue_mode=${NSA_UE_MODE}
#     ...                                                                   nettpye=${NSA_nettype}     apn_address=${NSA_apn_addr}    4G_check=True
#     set test variable    ${cpif_log_01}
#     Start UE traffic and check tput    apn_address=${NSA_apn_addr}     ue_mode=${NSA_UE_MODE}
#     ...                                dlexpect_tp=${@{${dlexpect_tp}}[0]}    ue_num=${ue_num}
#     Run Keyword If    '${MRBTS_ID}' == '10175'    CsiReportBundling Check Piont
#     Trigeer Mgap test several times NSA
#     UE stop traffic and detach with uetype
#     MCS Teardown with mcs_type    mcs_type=${mcs_type}
#     B_017 wireshark Analysis part
#     run keyword if    '${MRBTS_ID}' == '10318'
#     ...                Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL2}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Run Keyword And Ignore Error     Tests Recover
# 
# 
# *** Keywords ***
# MeasurementGAP test around
#     Log to console    RANK4
#     SET MCS ATT only    att_value=${@{${att_value}}[0]}
#     ${2200_B017_BIP_rank4}=    Check tput and capture Biplog    dlexpect_tp=${@{${dlexpect_tp}}[0]}
#     set test variable    ${2200_B017_BIP_rank4}
#     Log to console    trigger a2 event
#     Start Capture CP-IF logs from Container     tcpdump_collector_name=${2200_B_017_A2}
#     sleep    1s
#     SET MCS ATT only    att_value=${@{${att_value}}[1]}        #trigger A2
#     sleep    2s
#     Check Dl traffic with nrcellid for uetype     dlexpect_tp=${@{${dlexpect_tp}}[3]}
#     ${2200_B_017_2}    Stop CP-IF log Collection     tcpdump_collector_name=${2200_B_017_A2}
#     sleep    2s
#     Log to console    restore RANK4
#     Start Capture CP-IF logs from Container    tcpdump_collector_name=${2200_B_017_back}
#     sleep    1s
#     SET MCS ATT only    att_value=${@{${att_value}}[0]}      #back to rank4
#     sleep    3s
#     ${2200_B_017_3}    Stop CP-IF log Collection    tcpdump_collector_name=${2200_B_017_back}
#     Check Dl traffic with nrcellid for uetype     dlexpect_tp=${@{${dlexpect_tp}}[2]}
#     ${2200_B017_BIP_rank4_back}=    Capture biplog and download
#     set test variable    ${2200_B017_BIP_rank4_back}
#     set test variable    ${2200_B_017_2}
#     set test variable    ${2200_B_017_3}
#     Log to console      check bip
#     SET MCS ATT only    att_value=${@{${att_value}}[2]}
#     B_017 BIP Analysis part
# 
# Trigeer Mgap test several times NSA
#     ${magtimes}    set variable    ${1}
#     FOR    ${mgaptimes}    IN RANGE    ${1}    ${4}
#       MeasurementGAP test around
#       ${mgaptimes}=    BuiltIn.Evaluate    ${mgaptimes}+1
#     END
# 
# SET MCS ATT only
#     [Arguments]    ${att_value}
#     Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SET Four Output ATT    mcs_type=${mcs_type}
#     ...     att_value_1=${att_value}    att_value_2=${att_value}
#     ...     P1_out=${13}    P2_out=${14}    P3_out=${15}    P4_out=${16}
#     Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUN SET Four Output Ports With Different Values    mcs_type=${mcs_type}
#     ...     att_value1=${att_value}     att_value2=${att_value}
#     ...     first_beam_begin_output_port=${1}      first_beam_end_output_port=${2}
#     ...     second_beam_begin_output_port=${3}     second_beam_end_output_port=${4}
#     Run keyword if    '${mcs_type}'=='hbte'         HBTE SET Four Output Ports With Different Values    mcs_type=${mcs_type}
#     ...     att_value1=${att_value}     att_value2=${att_value}
#     ...     first_beam_begin_output_port=${5}      first_beam_end_output_port=${6}
#     ...     second_beam_begin_output_port=${7}     second_beam_end_output_port=${8}
# 
# MCS SETUP AND SET ATT
#     [Arguments]    ${att_value}
#     ${mcs_type}=    mcs_common.Get MCS Type
#     set suite variable      ${mcs_type}
#     Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE   mcs_type=${mcs_type}
#     ...    att_value_1=${att_value}    att_value_2=${att_value}
#     ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${20}
#     ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${27}
#     Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#     ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${-6}
#     ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${15}
#     ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${28}
#     Run keyword if    '${mcs_type}'=='hbte'    HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#     ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${96}
#     ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${-5}
#     ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${-15}
# 
# B_017 BIP Analysis part
#     Get Maxnumber Of Layer for MCshark    bip_log=${2200_B017_BIP_rank4}    rank=4
#     Get Maxnumber Of Layer for MCshark    bip_log=${2200_B017_BIP_rank4_back}    rank=4
# 
# 
# 
# B_017 wireshark Analysis part
#     [Arguments]    ${pcap_file_1}=${cpif_log_01}    ${pcap_file_2}=${2200_B_017_2}    ${pcap_file_3}=${2200_B_017_3}
#     ${nrofPorts}=    Get CSIRS_nrofPorts from CPIF    file_path=${pcap_file_1}
#     should contain x times    ${nrofPorts}    p8    4
#     ${cdm_Type}=     Get CSIRS_cdm_Type from CPIF     file_path=${pcap_file_1}
#     should contain    ${cdm_Type}    2
#     ${density}=      Get CSIRS_density from CPIF      file_path=${pcap_file_1}
#     should contain    ${density}    1
#     ${n1-n2}=        Get CSIRS_n1_n2 from CPIF        file_path=${pcap_file_1}
#     should contain    ${n1-n2}    1
#     ${SinglePanel_ri}=     Get ri_Restriction from CPIF    file_path=${pcap_file_1}
#     should contain    ${SinglePanel_ri}    0f
#     ${drx_config}=         Get DRX_Config from CPIF     file_path=${pcap_file_1}
#     should contain    ${drx_config}    1
#     ${measgapoffset}=      Get MeasGap_offset from CPIF    file_path=${pcap_file_2}
#     should contain    ${measgapoffset}    19
#     ${measgaprelease}=     Get MeasGap_Release from CPIF    file_path=${pcap_file_3}
#     should contain    ${measgaprelease}    0
# 
# CsiReportBundling Check Piont
#     ${CsiReport_SSB_slots}=    Get SSB_Reportslot from CPIF    file_path=${cpif_log_01}
#     ${CsiReport_CQI_slots}=    Get CQI_Reportslot from CPIF    file_path=${cpif_log_01}
#     Should Be True    '${CsiReport_SSB_slots}' == '${CsiReport_CQI_slots}'
#     ${CsiReport_SSB_pucchResource}=    Get CsiReport_Pucch_resource from CPIF    file_path=${cpif_log_01}
#     ${CsiReport_CQI_pucchResource}=    Get CsiReport_Pucch_resource from CPIF    file_path=${cpif_log_01}    report_index=2
#     Should Be True    '${CsiReport_SSB_pucchResource}' == '${CsiReport_CQI_pucchResource}'
#     ${SSB_uplinkBandwidthPartId}=    Get CsiReport_uplinkBandwidthPartId from CPIF    file_path=${cpif_log_01}
#     ${CQI_uplinkBandwidthPartId}=    Get CsiReport_uplinkBandwidthPartId from CPIF    file_path=${cpif_log_01}    report_index=2
#     Should Be True    '${SSB_uplinkBandwidthPartId}' == '${CQI_uplinkBandwidthPartId}'
# 
# Tests Recover
#     run keyword if    '${MRBTS_ID}' == '10318'     Run Keyword And Ignore Error
#     ...                Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL1}
#     Run Keyword And Ignore Error     Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB_AMF}
#     Run Keyword And Ignore Error    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
#     Run Keyword And Ignore Error    csn.send command    command=killall tcpdump     connection=gnb
#     Run Keyword And Ignore Error    Connect to TestPc    alias=ute
#     Run Keyword And Ignore Error    csn.send command
#     ...                   command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ute
#     Run Keyword And Ignore Error    UE stop traffic and detach with uetype
#     Run Keyword And Ignore Error    MCS Teardown with mcs_type    mcs_type=${mcs_type}
#     Run Keyword And Ignore Error    clear cli process
#     Run Keyword And Ignore Error    disconect all connections
