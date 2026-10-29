# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: liujia
# # #...    contact:jia-rebecca.liu@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : 5GC002200
# # #
# # #
# # #Suite Setup         Run keywords
# # #...    robot_common_operations.Common Suite Setup    AND
# # #...    Run Keyword And Ignore Error       Common Suite Setup for COAM 2200
# # #
# # #Suite Teardown      Run keywords
# # #...    robot_common_operations.Common Suite Teardown    AND
# # #...    Run Keyword And Ignore Error       Common Suite Teardown for COAM
# # #
# # #
# # #Resource       Resources/5GC002200_coam_common_keywords.robot
# # #
# # #*** Variables ***
# # #@{DL_expect_22R2}          1200     90
# # #@{DL_expect_Trunk}          740    100
# # #@{DL_expect_22R3}          1100    200
# # #${2200_B_wireshark}        2200_B_wireshark
# # #${ASKEY_DL_PORT}           ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# # #${ASKEY_UL_PORT}           ${ue_param['data_transfer']['iperf_options']['qci'][6]}
# # #@{att_value_22R2}          25    65    90    127
# # #@{att_value_Trunk}         0     20    35    50
# # #@{att_value_22R3}          40    60    70    90
# # #${rank2}                   2
# # #${rank4}                   4
# # #${256QAM}                  8
# # #${64QAM}                   6
# # #${dl_TCP}                  1000M
# # #${filter_pdschsendreq}     dldata_pdschsendreq
# # #${CMD_pdschsendreq}        {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"${filter_pdschsendreq}\" -T pdml
# # #${ue_num}                  1
# # #
# # ###22R2 test on TL362##
# # ###TRUNK test on TL365##
# # ###22R3 test on TL374##
# # #
# # #*** Test Cases ***
# # #[1]5GC002200_B_007_max_DLUL_Tput_with_4_resources_and_beamset_6_good_condition_100M_1116_Frametype_SA
# # #    [Documentation]
# # #    ...    this test case is to verify 64TRX(4*8*2) RU can do DL and UL data transfer successfully when
# # #    ...    2200 feature enable with beamset6 and frametype 1116 and 80M bandwidth. also check the rank
# # #    ...    switch from rank4 to rank1(if possible)
# # #    ...    add CNI74278_A_01_SA_max_DLUL_Tput_with_4CSI-RS_4x1_#2#1#1wT_2_2_4_BW_100M_1116 case check points
# # #    ...    n1-n2 shoud be 4x1; UE can get peak with the right beamweight; beamset= (4+1)x(4+16)+2x(4+64)=236;
# # #    ...    n1:n2 will use extend 4x1,
# # #    ...    csirsResourceSetConfig4CRI = 4x1-2-1-1wT_2_2_4;
# # #    ...    add CNI65655 checkpoints, "im" and "re" should be range -16384 ~ 16383 in beamset json file.
# # #    ...    TRUNK add CNI80224 bundling check point
# # #    [Tags]      classical    CRT_22R2    CRT_TRUNK    CRT_22R3    CRT_22R4
# # #    [Timeout]    1 hour
# # #    [Setup]    robot_common_operations.Common Case Setup
# # #    Case variable set for 2200_B_007
# # #    Common Case TestLine Setup    ModifySCF_Beforecommission=True    Is_Swconfig=True     Lock_ENB_Need=True
# # #    ...                           swconfig_file=${swconfig}    golden_scf_name=${${golden_scf_name}}
# # #    ...                           ParamterToModify=${${ParamterToModify}}
# # #    ...                           ListParamterToModify=${${ListParamterToModify}}
# # #    ...                           enb_dist_name=${${ENB_cell_dist}}
# # #    ...                           enb_parameter=${enb_cell_admin}
# # #    ...                           enb_value=locked
# # #    Set nrcellid suit varaible    cellid=${${cellid}}
# # #    UE precondition with uetype
# # #    MCS SETUP AND SET ATT         att_value=${@{${att_value}}[0]}
# # #    ${cpif_log_01}=     attach UE with uetype and capture wiresharklog    wiresharklog=${2200_B_wireshark}    ue_num=${ue_num}
# # #    BuiltIn.Set Test Variable    ${cpif_log_01}
# # #    Analysis 2200 enable
# # #    Check beamweight for CNI74278         beamweight_name=${${beamweight_name}}    connection=gnb    beamset_num=236
# # #    Check beamweight size for CNI65655    beamweight_name=${${beamweight_name}}    connection=gnb    bpf_name=${${bpf_name}}
# # #    ...                                   ungzip_bpf_name=${${ungzip_bpf_name}}    bpf_name_xml=${${bpf_name_xml}}
# # #    ${2200_B007_BIP_rank4}=    Start DL Traffic And Capture Biplog    script_path=${bipscript_path}
# # #    ...                                                               dlexpect_tp=${@{${dlexpect_tp}}[0]}
# # #    SET MCS ATT for RANK2     att_value=${@{${att_value}}[1]}
# # #    sleep     5s
# # #    Check Dl traffic with nrcellid for uetype    cellid=${nrcellid}     dlexpect_tp=${@{${dlexpect_tp}}[1]}    duration=3m
# # #    ${2200_B007_BIP_rank2}=    Capture biplog and download to UTE    script_path=${bipscript_path}    capturing_time_seconds=5
# # #    sleep     5s
# # #    UE stop traffic and detach with uetype
# # #    MCS Teardown with mcs_type    mcs_type=${mcs_type}
# # #    sleep    2s
# # #    analysis BIP with MCshark    BIP_log=${2200_B007_BIP_rank4}     rank=${rank4}     QAM=${256QAM}
# # #    Get Maxnumber Of Layer for MCshark    bip_log=${2200_B007_BIP_rank2}    rank=${rank2}
# # #    Run Keyword If    '${MRBTS_ID}' == '10175'    CsiReportBundling Check Piont
# # #    run keyword if    '${MRBTS_ID}' == '10318'
# # #    ...                 Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL2}
# # #    [Teardown]    Run Keywords
# # #    ...    robot_common_operations.Common Case Teardown    AND
# # #    ...    Run Keyword And Ignore Error     Tests Recover
# # #
# # #*** Keywords ***
# # #MCS SETUP AND SET ATT
# # #    [Arguments]    ${att_value}
# # #    ${mcs_type}=    mcs_common.Get MCS Type
# # #    set suite variable      ${mcs_type}
# # #    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE   mcs_type=${mcs_type}
# # #    ...    att_value_1=${att_value}    att_value_2=${att_value}
# # #    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${15}
# # #    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${25}
# # #    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
# # #    ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${-6}
# # #    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-6}
# # #    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${6}
# # #    Run keyword if    '${mcs_type}'=='hbte'    HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
# # #    ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${96}
# # #    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${5}
# # #    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${15}
# # #
# # #
# # #SET MCS ATT for RANK2
# # #    [Arguments]    ${att_value}
# # #    Run keyword if    '${mcs_type}'=='haojin'       HAOJIN MCS SET Four Output ATT    mcs_type=${mcs_type}
# # #    ...    att_value_1=${att_value}    att_value_2=90    P1_out=${13}    P2_out=${14}    P3_out=${15}    P4_out=${16}
# # #    Run keyword if    '${mcs_type}'=='topyoung'     TOPYOUN SET Four Output Ports With Different Values    mcs_type=${mcs_type}
# # #    ...    att_value1=${att_value}    att_value2=90    first_beam_begin_output_port=${1}      first_beam_end_output_port=${2}
# # #    ...    second_beam_begin_output_port=${3}     second_beam_end_output_port=${4}
# # #    Run keyword if    '${mcs_type}'=='hbte'         HBTE SET Four Output Ports With Different Values    mcs_type=${mcs_type}
# # #    ...    att_value1=${att_value}    att_value2=90    first_beam_begin_output_port=${5}      first_beam_end_output_port=${6}
# # #    ...    second_beam_begin_output_port=${7}     second_beam_end_output_port=${8}
# # #
# # #
# # #Analysis 2200 enable
# # #    ${nrofPorts}=    Get CSIRS_nrofPorts from CPIF    file_path=${cpif_log_01}
# # #    should contain x times    ${nrofPorts}    p8    4
# # #    ${cdm_Type}=     Get CSIRS_cdm_Type from CPIF     file_path=${cpif_log_01}
# # #    should contain    ${cdm_Type}    2
# # #    ${density}=      Get CSIRS_density from CPIF      file_path=${cpif_log_01}
# # #    should contain    ${density}     1
# # #    ${n1-n2}=        Get CSIRS_n1_n2 from CPIF        file_path=${cpif_log_01}
# # #    should contain    ${n1-n2}       2
# # #
# # #CsiReportBundling Check Piont
# # #    ${CsiReport_SSB_slots}=    Get SSB_Reportslot from CPIF    file_path=${cpif_log_01}
# # #    ${CsiReport_CQI_slots}=    Get CQI_Reportslot from CPIF    file_path=${cpif_log_01}
# # #    Should Be True    '${CsiReport_SSB_slots}' == '${CsiReport_CQI_slots}'
# # #    ${CsiReport_SSB_pucchResource}=    Get CsiReport_Pucch_resource from CPIF    file_path=${cpif_log_01}
# # #    ${CsiReport_CQI_pucchResource}=    Get CsiReport_Pucch_resource from CPIF    file_path=${cpif_log_01}    report_index=2
# # #    Should Be True    '${CsiReport_SSB_pucchResource}' == '${CsiReport_CQI_pucchResource}'
# # #    ${SSB_uplinkBandwidthPartId}=    Get CsiReport_uplinkBandwidthPartId from CPIF    file_path=${cpif_log_01}
# # #    ${CQI_uplinkBandwidthPartId}=    Get CsiReport_uplinkBandwidthPartId from CPIF    file_path=${cpif_log_01}    report_index=2
# # #    Should Be True    '${SSB_uplinkBandwidthPartId}' == '${CQI_uplinkBandwidthPartId}'
# # #
# # #
# # #
# # #Analysis BIP
# # #    [Arguments]     ${BIP_log}     ${rank}     ${QAM}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${BIP_log}    tshark_path=${tshark_path}
# # #    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_pdschsendreq}
# # #    ${filter_expression}=    Catenate    dldata_pdschsendreq
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${numOfLayers}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//DlData_PdschGrant.numOfLayers
# # #    should contain    ${numOfLayers}    ${rank}
# # #    ${modulationOrder}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//DlData_PdschSendReq.grants_item_0.modulationOrder
# # #    should contain    ${modulationOrder}    ${QAM}
# # #
# # #analysis BIP with MCshark
# # #    [Arguments]     ${BIP_log}     ${rank}    ${QAM}
# # #    Get Maxnumber Of Layer for MCshark    bip_log=${BIP_log}    rank=${rank}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${BIP_log}
# # #    ${filter_expression}=    Catenate    dldata_pdschsendreq
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${modulationOrder}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//DlData_PdschGrant.modulationOrder
# # #    should contain    ${modulationOrder}    ${QAM}
# # #
# # #Analysis BIP for rank2
# # #    [Arguments]     ${BIP_log}     ${rank}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${BIP_log}    tshark_path=${tshark_path}
# # #    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${CMD_pdschsendreq}
# # #    ${filter_expression}=    Catenate    dldata_pdschsendreq
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${numOfLayers}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//DlData_PdschSendReq.grants_item_0.numOfLayers
# # #    should contain    ${numOfLayers}    ${rank}
# # #
# # #Tests Recover
# # #    Run Keyword And Ignore Error     Common Case TestLine Setup     Lock_ENB_Need=True     enb_dist_name=${${ENB_cell_dist}}
# # #    ...                                                             enb_parameter=${enb_cell_admin}
# # #    ...                                                             enb_value=unlocked
# # #    Run Keyword And Ignore Error    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    as
# ...ik_password=${asik_password}
# # #    Run Keyword And Ignore Error    csn.send command    command=killall tcpdump     connection=gnb
# # #    Run Keyword And Ignore Error    Connect to TestPc    alias=ute
# # #    Run Keyword And Ignore Error    csn.send command
# # #    ...                   command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ute
# # #    Run Keyword And Ignore Error    UE stop traffic and detach with uetype
# # #    Run Keyword And Ignore Error    MCS Teardown with mcs_type    mcs_type=${mcs_type}
# # #    Run Keyword And Ignore Error    clear cli process
# # #    Run Keyword And Ignore Error    disconect all connections
# # #
# # #
