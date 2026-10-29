#*** Settings ***
#Documentation      Author: jia-rebecca.liu@nokia-sbell.com
#...                squad group: SG_03
#...                feature : CB008247
#
#
#Suite Setup       Run Keywords
#...            robot_common_operations.Common Suite Setup    AND
#...            Run Keyword And Ignore Error     Common Suite Setup for COAM 8247
#
#Suite Teardown    Run Keywords
#...            robot_common_operations.Common Suite Teardown    AND
#...            Run Keyword And Ignore Error     Common Suite Teardown for COAM
#
#
#Resource         ../Resources/CB008247_case_steps_SG3.robot
#
#
#
#*** Variables ***
#${8247_wireshark_01}     8247_wireshark_01
#${8247_wireshark_02}     8247_wireshark_02
#${ue_num}                1
#${Expect_dl_Trunk}          770
#${Expect_dl_22R3}           1100
#${Expect_dl_22R4}           1300
#${dl_throughput}            1150M
#
#
#
#*** Test Cases ***
#[1]CB008247-A_PRACH_T1R4_with_TAS_reuse_codebook_or_not_configuration
#    [Documentation]    The purpose of this test case is to verify beam switch with codebook P-SRS both used for DL and UL.
#    ...    TL365-ue T1R2-slots40-not reuse, slots20-reuse.
#    ...    TL374-Ue T1R4-slots80-not reuse, slots40-reuse.
#    ...    reuse first, then not reuse.
#    [Tags]     CRT_22R3    CRT_TRUNK    CIT_TRUNK    CRT_22R4    CIT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Set suite variable for 8247_A_PRACH
#    step1 prepare the envrionment
#    step2 prepare UE and MCS
#    step3 test procedures
#    step4 case check point
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Case TearDown
#
#
#*** Keywords ***
#step1 prepare the envrionment
#    [Arguments]
#    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS24R1_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_23R4}     ${golden_scf_24R1_374}
#    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS23R3_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_23R4}     ${golden_scf_23R3_374}
#    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS24R2_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_23R4}     ${golden_scf_24R2_374}
#    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS23R4_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_24R1}     ${golden_scf_23R4_365}
#    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS23R3_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_24R1}     ${golden_scf_23R3}
#
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True     Is_Swconfig=True    gnb_type='NSA'    is_x2_check_from_gnb_needed=${True}
#    ...                            golden_scf_name=${${golden_scf}}      swconfig_file=${swconfig_paths}
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    ...                            ParameterToDelete=${${ParameterToDelete}}
#    ...                            ListToAdd=${${ListToAdd}}
#    ...                            ParamterToModify=${${ParamterToModify}}
#    ...                            ListParamterToModify=${${ListParamterToModify}}
#    ...                            Lock_ENB_Need=True
#    ...                            enb_dist_name=${enb_dist_LNCEL1}
#    ...                            enb_parameter=${enb_cell_admin}
#    ...                            enb_value=unlocked
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#    sleep    180s
#
#
#
#step2 prepare UE and MCS
#    [Arguments]
#    NRCellid Set suit varaible    cellid=${${cellid}}
#    MCS SETUP AND SET ATT
#    Prepare MultiUE with client
#
#
#step3 test procedures
#    ${cpif_log_01}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_01}    UE_mode=${NSA_attach_mode}
#    ${8247_bip_01}=    Start Traffic And Capture Biplog with new way    dlexpect_tp=${${dlexpect_tp}}    aa_sys_addr=${${aa_sys_addr}}
#    ...                                                                 dl_throughput=${${dl_tput_multiue}}
#    stop traffic and detach UE with new way
#    sleep    5s
#    modify the parameters for case     parameters=${${online_modify}}    is_x2_check_from_enb_needed=${True}     gnb_type='NSA'
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#    sleep    180s
#    ${cpif_log_02}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_02}    UE_mode=${NSA_attach_mode}
#    ${8247_bip_02}=    Start Traffic And Capture Biplog with new way      dlexpect_tp=${${dlexpect_tp}}    aa_sys_addr=${${aa_sys_addr}}
#    ...                                                                  dl_throughput=${${dl_tput_multiue}}
#    sleep    10s
#    BuiltIn.Set Test Variable    ${8247_bip_01}
#    BuiltIn.Set Test Variable    ${8247_bip_02}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    BuiltIn.Set Test Variable    ${cpif_log_02}
#    [Teardown]     stop traffic and MCS teardown with new way     mcs_type=${mcs_type}
#
#
#step4 case check point
#    [Arguments]
#    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs    cell_idx=${${cellid}}
#    Set Test Variable    ${cprtPatternIdDict}
#    DFTBeam Should Be Used In BIP with mcshark    file_path=${8247_bip_01}
#    DFTBeam Should Be Used In BIP with mcshark    file_path=${8247_bip_02}
#    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_01}    srs_ResourceSet=2
#    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_02}    srs_ResourceSet=2
#    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_02}    cell_idx=${${cellid}}
#    Check SRSresource reuse in RRC Message    file_path=${cpif_log_01}
#    Check SRSresource reuse in RRC Message    file_path=${cpif_log_02}    resource_reues_status=${False}
#
#
#MCS SETUP AND SET ATT
#    ${mcs_type}=    mcs_common.Get MCS Type
#    set suite variable      ${mcs_type}
#    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE    mcs_type=${mcs_type}
#    ...    att_value_1=${25}     att_value_2=${25}
#    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${5}
#    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${15}
#    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${15}    att_value2=${15}    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
#    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${25}    att_value2=${25}    vertical_angle=${-6}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
#
#
#Case TearDown
#    Run Keyword And Ignore Error     Modify Parameters for Cases     Modify_Para_Online=${UNLOCK_SERVEDAMF}
#    Run Keyword And Ignore Error      stop traffic and detach UE with new way
#
#
