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
#Resource         ../Resources/CB008247_case_steps_SG3.robot
#
#
#
#
#*** Variables ***
#${8247_wireshark_01}        8247_wireshark_01
#${Expect_dl_Trunk}          375
#${Expect_dl_22R3}           500
#${Expect_dl_22R4}           600
#
#
#
#*** Test Cases ***
#[1]CB008247-A_Beam_Switch_DFT_beams_got_from_codebook-P-SRS_with_UE_capable_of_TAS_but_rdPriorSrsForDlBm_codebook
#    [Documentation]    The purpose of this test case is to verify beam switch with codebook P-SRS both used for DL and UL.
#    [Tags]     CRT_22R3    CRT_TRUNK    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Set suite variable for 8247_A_Beam
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
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True     Is_Swconfig=True    Lock_ENB_Need=True
#    ...                            golden_scf_name=${${golden_scf}}      swconfig_file=${swconfig_paths}
#    ...                            swconfig_modify=${${swconfig_modify}}
#    ...                            ParamterToModify=${${ParamterToModify}}
#    ...                            ParameterToDelete=${${ParameterToDelete}}
#    ...                            ListToAdd=${${ListToAdd}}
#    ...                            ListParamterToModify=${${ListParamterToModify}}
#    ...                            enb_dist_name=${${enb_dist_name}}
#    ...                            enb_parameter=${enb_cell_admin}
#    ...                            enb_value=locked
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#    sleep    150s
#
#step2 prepare UE and MCS
#    [Arguments]
#    NRCellid Set suit varaible    cellid=${${cellid}}
#    MCS SETUP AND SET ATT
#    Prepare MultiUE with client
#
#
#step3 test procedures
#    ${cpif_log_01}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_01}
#    ${8247_bip_01}=    Start Traffic And Capture Biplog with new way      dlexpect_tp=${${dlexpect_tp}}    aa_sys_addr=${${aa_sys_addr}}
#    ...                                                                   dl_throughput=${${dl_tput_multiue}}
#    sleep    5s
#    Log to console    change UE position from 5,15 to -5,-15
#    change UE position with MCS
#    sleep    15s
#    Check Dl traffic with nrcellid in Diff with new way     dlexpect_tp=${${dlexpect_tp}}    aa_sys_addr=${${aa_sys_addr}}
#    ${8247_bip_02}=    Capture biplog and download
#    sleep    10s
#    BuiltIn.Set Test Variable    ${8247_bip_01}
#    BuiltIn.Set Test Variable    ${8247_bip_02}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    [Teardown]     stop traffic and MCS teardown with new way    mcs_type=${mcs_type}
#
#step4 case check point
#    [Arguments]    ${8247_cpif_log}=${cpif_log_01}
#    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs    cell_idx=${${cellid}}
#    Set Test Variable    ${cprtPatternIdDict}
#    DFTBeam Should Be Used In BIP with mcshark    file_path=${8247_bip_01}
#    Check CodeBook SRS Is Used in RRC Message    file_path=${8247_cpif_log}
#    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${8247_cpif_log}    cell_idx=${${cellid}}
#    Check bestbeam patternid used
#    Check PUSCH and CSIRS used DFT beam with mcshark    file_path=${8247_bip_01}
#    Check PUSCH and CSIRS used DFT beam with mcshark    file_path=${8247_bip_02}
#
#
#MCS SETUP AND SET ATT
#    [Arguments]
#    ${mcs_type}=    mcs_common.Get MCS Type
#    set suite variable      ${mcs_type}
#    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE    mcs_type=${mcs_type}
#    ...    att_value_1=${25}     att_value_2=${25}
#    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${5}
#    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${15}
#    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${10}    att_value2=${10}    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
#    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${25}    att_value2=${25}    vertical_angle=${-6}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
#
#
#Change UE position with MCS
#    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS change UE Phases    mcs_type=${mcs_type}
#    ...    begin_output_port_1=${13}    end_output_port_2=${14}    vertical_angle_1=${96}    horizontal_angle_1=${-5}
#    ...    begin_output_port_3=${15}    end_output_port_4=${16}    vertical_angle_2=${96}    horizontal_angle_2=${-15}
#    Run keyword if    '${mcs_type}'=='hbte'    HBTE MCS change UE Phases    mcs_type=${mcs_type}    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-4}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-14}
#    Run keyword if    '${mcs_type}'=='topyoung'     TOPYOUNG MCS change UE Phases    mcs_type=${mcs_type}    vertical_angle=${-6}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}
#
#
#
#Check bestbeam patternid used
#    [Arguments]
#    ${bipPatternIdList1}    Get PDSCH_patternId From BIP Log with mcshark    file_path=${8247_bip_01}
#    ${bipPatternIdList2}    Get PDSCH_patternId From BIP Log with mcshark    file_path=${8247_bip_02}
#    Should Not Be Equal    ${bipPatternIdList1}    ${bipPatternIdList2}
#    ...    msg="DFT beam is not changed from scenario1 to scenario2!"
#
#
#Case TearDown
#    Run Keyword And Ignore Error     Common Case TestLine Setup     Lock_ENB_Need=True    enb_dist_name=${${enb_dist_name}}
#    ...                                                             enb_parameter=${enb_cell_admin}
#    ...                                                             enb_value=unlocked
#    Run Keyword And Ignore Error    Run keyword if    '${MRBTS_ID}' == '10318'    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                                                                                                     Modify_Para_Online=${UNLOCK_GNB1_CELL1}
##    Run Keyword And Ignore Error    stop traffic and detach UE
