#*** Settings ***
#Documentation      Author: jia-rebecca.liu@nokia-sbell.com
#...                squad group: SG_03
#...                feature : CB008247
#
#
#Suite Setup         Run keywords
#...    robot_common_operations.Common Suite Setup    AND
#...    Run Keyword And Ignore Error       Common Suite Setup for COAM 8247
#
#Suite Teardown      Run keywords
#...    robot_common_operations.Common Suite Teardown    AND
#...    Run Keyword And Ignore Error       Common Suite Teardown for COAM
#
#
#
#
#Resource         ../Resources/CB008247_case_steps_SG3.robot
#
#
#
#
#*** Variables ***
#${golden_scf_Trunk}      MRBTS-10175_TL365_golden_scf.xml
#${golden_scf_23R3}       MRBTS-10175_TL365_golden_scf_23R3.xml
##${golden_scf_23R2}       MRBTS-10175_TL365_golden_scf_23R2.xml
#${golden_scf_23R1}       MRBTS-10175_TL365_golden_scf_23R1.xml
#${golden_scf_SBTS00}       MRBTS-10175_TL365_golden_scf_SBTS00.xml
#${8247_wireshark_01}     8247_wireshark_01
#${8247_wireshark_02}     8247_wireshark_02
#${8247_wireshark_03}     8247_wireshark_03
#${8247_wireshark_04}     8247_wireshark_04
#${ue_num}       1
#${nrcellid}     1
#@{Expect_dl_enable}           400    100
#${multi_ues_tput}        200M
#${get_tti_name}     ls -l | grep *.dl__all.csv |awk '{print $9}'
#
#
#*** Test Cases ***
#[1]CB008247-5G-B#B1_002_Check_UE_attach_to_5Gcell_success_when_2200_and_8247_enable_with_NSA_mode
#    [Documentation]    Purpose of this case is to validate TAS supported UE can attach to 5G cell successfully
#    ...                when 2200 and 8247 feature all enabled.
#    ...    add 8247-D-01 checkpoint:verify that L3 call with CB008247 works fine with CDRX. test with multi UEs
#    ...    UE specific used, DRX enable, NSA
#    [Tags]     CRT_22R3    CRT_TRUNK    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Set suite variable for 8247_B1_002
#    step1 prepare the envrionment
#    step2 prepare UE and MCS
#    step3 test procedures
#    step4 add mumimo test step
#    step5 case check point
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Case TearDown
#
#
#*** Keywords ***
#step1 prepare the envrionment
#    [Arguments]
#    Run Keyword If    '${release_info}' == 'SBTS23R3_ENB_0000'    Set Test Variable    ${golden_scf_Trunk}    ${golden_scf_23R3}
#    Run Keyword If    '${release_info}' == 'SBTS23R4_ENB_0000'    Set Test Variable    ${golden_scf_Trunk}    ${golden_scf_23R4}
#    Run Keyword If    '${release_info}' == 'SBTS24R1_ENB_0000'    Set Test Variable    ${golden_scf_Trunk}    ${golden_scf_24R1}
#    Run Keyword If    '${release_info}' == 'SBTS24R2_ENB_9999'    Set Test Variable    ${golden_scf_Trunk}    ${golden_scf_SBTS00}
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True     Is_Swconfig=True
#    ...                            golden_scf_name=${golden_scf_Trunk}      swconfig_file=${swconfig_paths}
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    ...                            ParamterToModify=${PARAMS_TO_MODIFY_B1002}
#    ...                            ListParamterToModify=${LIST_TO_MODIFY_B1002}
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#
#
#step2 prepare UE and MCS
#    [Arguments]
#    NRCellid Set suit varaible    cellid=${1}
#    MCS SETUP AND SET ATT
#    Prepare MultiUE with client
#
#
#step3 test procedures
#    Log to console    ue put on (5,15)
#    ${cpif_log_01}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_01}
#    ${8247_bip_01}=    Start Traffic And Capture Biplog with new way     dlexpect_tp=${Expect_dl_enable[0]}    aa_sys_addr=${${aa_sys_addr}}
#    ...                                                                 dl_throughput=${${dl_tput_multiue}}
#    stop traffic and detach UE without stop log
#    sleep    30s
#    Log to console    ue put on (-10,-20)
#    Change UE position with MCS    horizontal_angle_1=${-10}    horizontal_angle_2=${-20}
#    ${cpif_log_02}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_02}
#    ${8247_bip_02}=    Start Traffic And Capture Biplog with new way     dlexpect_tp=${Expect_dl_enable[0]}    aa_sys_addr=${${aa_sys_addr}}
#    ...                                                                 dl_throughput=${${dl_tput_multiue}}
#    stop traffic and detach UE without stop log
#    sleep    30s
#    Log to console    ue put on (15,25)
#    Change UE position with MCS    horizontal_angle_1=${15}    horizontal_angle_2=${25}
#    ${cpif_log_03}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_02}
#    ${8247_bip_03}=    Start Traffic And Capture Biplog with new way    dlexpect_tp=${Expect_dl_enable[0]}    aa_sys_addr=${${aa_sys_addr}}
#    ...                                                                 dl_throughput=${${dl_tput_multiue}}
#    stop traffic and detach UE without stop log
#    sleep    30s
#    Log to console    ue put on (-20,-30), 8ues attach and do dl traffic, 8247-D-01 check point
#    Change UE position with MCS    horizontal_angle_1=${-20}    horizontal_angle_2=${-30}
#    Change multi UE position with MCS    horizontal_1=${-20}    horizontal_2=${-30}
#    ${cpif_log_04}=    attach multiUEs and capture wiresharklog    wiresharklog=${8247_wireshark_02}
#    ${8247_bip_04}=    Start multiUEs Traffic And Capture Biplog    dl_tput_multiue=${multi_ues_tput}
#    Check multiUEs traffic with pioneer client    tput_target=${Expect_dl_enable[1]}
#    BuiltIn.Set Test Variable    ${8247_bip_01}
#    BuiltIn.Set Test Variable    ${8247_bip_02}
#    BuiltIn.Set Test Variable    ${8247_bip_03}
#    BuiltIn.Set Test Variable    ${8247_bip_04}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    BuiltIn.Set Test Variable    ${cpif_log_02}
#    BuiltIn.Set Test Variable    ${cpif_log_03}
#    BuiltIn.Set Test Variable    ${cpif_log_04}
#    [Teardown]    Run Keywords    Stop multiues traffic with appserver
#    ...    AND    Detach MultiUE and stoplog    ue=${uegroup}
#    ...    AND    mcs_common.Teardown MCS    mcs_type=${mcs_type}
#
#step4 add mumimo test step
#    MCS SETUP AND SET ATT
#    Prepare MultiUE with client
#    modify the parameters for case     parameters=${ONLINE_MODIFY_B1002}
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#    ${mcs_type}=    mcs_common.Get MCS Type
#    set suite variable      ${mcs_type}
#    HAOJIN MCS SETUP AND SET ATT for Two UEs with different ATT     mcs_type=${mcs_type}
#    ...    att_value_UE0_1=${20}    att_value_UE0_2=${20}    att_value_UE1_1=${20}    att_value_UE1_2=${20}
#    ...    P1_out=${13}    P2_out=${14}    P3_out=${15}    P4_out=${16}
#    ...    vertical_1=${101}    horizontal_1=${45}     vertical_2=${101}    horizontal_2=${40}
#    ...    P5_out=${9}     P6_out=${10}    P7_out=${11}    P8_out=${12}
#    ...    vertical_3=${96}     horizontal_3=${-35}    vertical_4=${96}     horizontal_4=${-25}
#    ${cpif_log_04}=    attach multiUEs and capture wiresharklog    wiresharklog=${8247_wireshark_04}
#    Get CSIRS_nrofPorts from CPIF    file_path=${cpif_log_04}
#    ${8247_bip_04}=    Start multiUEs Traffic And Capture Biplog    dl_tput_multiue=${multi_ues_tput}    UE_define=2
#    Capture tti trace from Gnb logs    output_match=finished    BBMOD=1
#    Get tti trace from gnb logs tool    tti_logs_rename=gnb_logs_TTI00
#    Analysis tti file    tti_logs_rename=gnb_logs_TTI00
#    [Teardown]    Run Keywords    Stop multiues traffic with appserver
#    ...    AND    Detach MultiUE and stoplog    ue=${uegroup}
#    ...    AND    mcs_common.Teardown MCS    mcs_type=${mcs_type}
#
#Analysis B001 ng log
#    ${all_packets}=    cap.load_pcap_file    pcap_file=${cpif_log_04}    tshark_path=${tshark_path}
#    ...    command_template=${None}
#    ${filter_expression}=    Catenate    nr-rrc.rrcReconfiguration_element &&
#    ...                                  nr-rrc.csi_MeasConfig == 1
#    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
#    should contain X times    ${nrofPorts}    3    32
#
#step5 case check point
#    [Arguments]
#    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs    cell_idx=${1}
#    Set Test Variable    ${cprtPatternIdDict}
#    DFTBeam Should Be Used In BIP with mcshark    file_path=${8247_bip_01}
#    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_01}
#    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_01}      srs_ResourceSet=2
#    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_01}    cell_idx=${1}
#    Check CSIRS UE specific Used    file_path=${cpif_log_01}
#    Check PUSCH and CSIRS used DFT beam with mcshark    file_path=${8247_bip_01}
#    Check PUSCH and CSIRS used DFT beam with mcshark    file_path=${8247_bip_02}
#    Check PUSCH and CSIRS used DFT beam with mcshark    file_path=${8247_bip_03}
#    Check PUSCH and CSIRS used DFT beam with mcshark    file_path=${8247_bip_04}
#
#Analysis tti file
#    [Arguments]    ${tti_logs_rename}=${tti_logs_rename}    ${epc_log_path}=${epc_log_path}
#    log to console    analysis tti file from Case_Logs file...
#    csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
#    csn.send command    command=cd ${epc_log_path}/${tti_logs_rename}/L2_trace/tti_packed/&&${get_tti_name}
#    ...                 connection=ute
#    ${tti_dl_file}=    csn.Read Output    connection=ute
#    @{tti_file_name}    String.split string    string=${tti_dl_file}    separator=\n
#    ${paired_count}    read_mumimo_rank2_paired    ${epc_log_path}${tti_logs_rename}/L2_trace/tti_packed/@{tti_file_name}[0]
#    should be true      ${paired_count} > 2
#
#MCS SETUP AND SET ATT
#    [Arguments]
#    ${mcs_type}=    mcs_common.Get MCS Type
#    set suite variable      ${mcs_type}
#    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for UE0   mcs_type=${mcs_type}
#    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${5}
#    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${15}    att_value=${20}
#    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${20}    att_value2=${20}    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
#
#
#Change UE position with MCS
#    [Arguments]    ${horizontal_angle_1}    ${horizontal_angle_2}
#    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS change UE Position    mcs_type=${mcs_type}
#    ...    begin_output_port_1=${13}    end_output_port_2=${14}    vertical_angle_1=${96}    horizontal_angle_1=${horizontal_angle_1}
#    ...    begin_output_port_3=${15}    end_output_port_4=${16}    vertical_angle_2=${96}    horizontal_angle_2=${horizontal_angle_2}
#    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS change UE Phases     mcs_type=${mcs_type}
#    ...    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${horizontal_angle_1}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${horizontal_angle_2}
#
#
#
#Change multi UE position with MCS
#    [Arguments]    ${horizontal_1}    ${horizontal_2}
#    Run keyword if    '${mcs_type}'=='haojin'     HAOJIN change multi UEs position    horizontal_1=${horizontal_1}    horizontal_2=${horizontal_2}
#    Run keyword if    '${mcs_type}'=='hbte'    HBTE change multi UEs position    horizontal_1=${horizontal_1}    horizontal_2=${horizontal_2}
#
#HAOJIN change multi UEs position
#    [Arguments]    ${horizontal_1}    ${horizontal_2}
#    HAOJIN MCS change UE Position    mcs_type=${mcs_type}
#    ...    begin_output_port_1=${9}     end_output_port_2=${10}    vertical_angle_1=${96}    horizontal_angle_1=${horizontal_1}
#    ...    begin_output_port_3=${11}    end_output_port_4=${12}    vertical_angle_2=${96}    horizontal_angle_2=${horizontal_2}
#    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${20}
#    ...    begin_output_port=${9}    end_output_port=${12}
#
#HBTE change multi UEs position
#    [Arguments]    ${horizontal_1}    ${horizontal_2}
#    HBTE MCS change UE Phases     mcs_type=${mcs_type}
#    ...    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${horizontal_1}
#    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${horizontal_2}
#    mcs_common.Set Odd And Even ATT For Output Port     mcs_type=${mcs_type}    att_value=${25}
#    ...    begin_output_port=${1}    end_output_port=${4}
#
#Case TearDown
#    Run Keyword And Ignore Error     Run keyword if    '${mcs_type}'=='haojin'
#    ...      HAOJIN MCS SET Four Output ATT    mcs_type=${mcs_type}    P1_out=${9}    P2_out=${10}
#    ...                                                                P3_out=${11}    P4_out=${12}    att_value_1=${90}    att_value_2=${90}
#    Run Keyword And Ignore Error     Run keyword if    '${mcs_type}'=='HBTE'
#    ...      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${90}    att_value2=${90}    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${15}
#    Run Keyword And Ignore Error     Common Case TestLine Setup     Lock_ENB_Need=True     enb_dist_name=${enb_dist_LNCEL1}
#    ...                                                             enb_parameter=${enb_cell_admin}
#    ...                                                             enb_value=unlocked
##    Run Keyword And Ignore Error     stop traffic and detach UE
#
#
#
