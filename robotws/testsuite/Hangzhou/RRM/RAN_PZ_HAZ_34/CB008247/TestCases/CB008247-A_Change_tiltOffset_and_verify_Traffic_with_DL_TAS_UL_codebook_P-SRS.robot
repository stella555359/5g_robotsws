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
#Resource         ../Resources/CB008247_case_steps_SG3.robot
#
#
#
#*** Variables ***
#${8247_wireshark_01}        8247_wireshark_01
#${8247_wireshark_02}        8247_wireshark_02
#@{Expect_dl_Trunk}          300     750
#@{Expect_dl_22R3}           580     1100
#@{Expect_dl_22R4}           580     1250
#${dl_throughput}            1150M
#
#
#
#*** Test Cases ***
#[1]CB008247-A_Change_tiltOffset_and_verify_Traffic_with_DL_TAS_UL_codebook_P-SRS
#    [Documentation]    The purpose of this test case is to verify traffic with different tiltOffset
#    [Tags]     CRT_22R3    CRT_TRUNK    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Set suite variable for 8247_A_Change
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
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True     Is_Swconfig=True    Lock_ENB_Need=True
#    ...                            golden_scf_name=${${golden_scf}}      swconfig_file=${swconfig_paths}
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    ...                            ParamterToModify=${${ParamterToModify}}
#    ...                            ParameterToDelete=${${ParameterToDelete}}
#    ...                            ListToAdd=${${ListToAdd}}
#    ...                            ListParamterToModify=${${ListParamterToModify}}
#    ...                            enb_dist_name=${${enb_dist_name}}
#    ...                            enb_parameter=${enb_cell_admin}
#    ...                            enb_value=locked
#    Run Keyword If    '${MRBTS_ID}' == '11006'    sleep    150s
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
#    ${cpif_log_01}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_01}
#    ${8247_bip_01}=    Start Traffic And Capture Biplog with new way        dlexpect_tp=${@{${dlexpect_tp}}[0]}    aa_sys_addr=${${aa_sys_addr}}
#    ...                                                                    dl_throughput=${${dl_tput_multiue}}
#    stop traffic and detach UE without stop log
#    Log to console    modify tiltoffset from 0 to -3, actpci change to true, p0srs from -96 to -86
#    modify the parameters for case     parameters=${${online_modify}}
#    sleep     3min
#    ${cpif_log_02}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_02}
#    ${8247_bip_02}=    Start Traffic And Capture Biplog with new way       dlexpect_tp=${@{${dlexpect_tp}}[0]}    aa_sys_addr=${${aa_sys_addr}}
#    ...                                                                    dl_throughput=${${dl_tput_multiue}}
#    Log to console    change UE position from -5,-5 to -5,-15
#    change UE position with MCS
#    sleep    10s
#    Check Dl traffic with nrcellid in Diff with new way     dlexpect_tp=${@{${dlexpect_tp}}[1]}    aa_sys_addr=${${aa_sys_addr}}
#    ${8247_bip_03}=     Capture biplog and download
#    BuiltIn.Set Test Variable    ${8247_bip_01}
#    BuiltIn.Set Test Variable    ${8247_bip_02}
#    BuiltIn.Set Test Variable    ${8247_bip_03}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    BuiltIn.Set Test Variable    ${cpif_log_02}
#    [Teardown]    stop traffic and MCS teardown with new way    mcs_type=${mcs_type}
#
#step4 case check point
#    [Arguments]
#    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs    cell_idx=${${cellid}}
#    Set Test Variable    ${cprtPatternIdDict}
#    DFTBeam Should Be Used In BIP with mcshark    file_path=${8247_bip_01}
#    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_01}
#    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_01}    srs_ResourceSet=2
#    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_01}    cell_idx=${${cellid}}
#    Check p0NominalSrs has changed    file_path_old=${cpif_log_01}    file_path_new=${cpif_log_02}
#    Check p0 Is Same in SCF And RRC Message    file_path=${cpif_log_02}    cell_idx=${${cellid}}
#    Check PUSCH and CSIRS used DFT beam with mcshark    file_path=${8247_bip_01}
#
#MCS SETUP AND SET ATT
#    [Arguments]
#    ${mcs_type}=    mcs_common.Get MCS Type
#    set suite variable      ${mcs_type}
#    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE    mcs_type=${mcs_type}
#    ...    att_value_1=${25}     att_value_2=${25}
#    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${-5}
#    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${-5}
#    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${45}    att_value2=${45}    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${-5}
#    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${-5}
#    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${25}    att_value2=${25}    vertical_angle=${-6}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-5}
#
#Change UE position with MCS
#    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS change UE Phases    mcs_type=${mcs_type}
#    ...    begin_output_port_1=${13}    end_output_port_2=${14}    vertical_angle_1=${96}    horizontal_angle_1=${-5}
#    ...    begin_output_port_3=${15}    end_output_port_4=${16}    vertical_angle_2=${96}    horizontal_angle_2=${-15}
#    Run keyword if    '${mcs_type}'=='hbte'    HBTE MCS change UE Phases    mcs_type=${mcs_type}    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${-5}
#    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${-15}
#    Run keyword if    '${mcs_type}'=='topyoung'     TOPYOUNG MCS change UE Phases    mcs_type=${mcs_type}    vertical_angle=${-6}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}
#
#
#Check bestbeam patternid used
#    [Arguments]    ${SRSBeam_tilt_0}=1325    ${SRSBeam_tilt_3}=1075
#    ${bipPatternIdList1}    Get PDSCH_patternId From BIP Log with mcshark    file_path=${8247_bip_01}
#    ${bipPatternIdList2}    Get PDSCH_patternId From BIP Log with mcshark    file_path=${8247_bip_02}
#    ${bipPatternIdList3}    Get PDSCH_patternId From BIP Log with mcshark    file_path=${8247_bip_03}
#    Should Be True    '${bipPatternIdList1[0]}' == '${SRSBeam_tilt_0}'
#    Should Be True    '${bipPatternIdList2[0]}' == '${SRSBeam_tilt_3}'
#
#
#
#Case TearDown
#    Run Keyword And Ignore Error     Common Case TestLine Setup     Lock_ENB_Need=True    enb_dist_name=${${enb_dist_name}}
#    ...                                                             enb_parameter=${enb_cell_admin}
#    ...                                                             enb_value=unlocked
#    Run Keyword And Ignore Error    Run keyword if    '${MRBTS_ID}' == '10318'    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                                                                                                     Modify_Para_Online=${UNLOCK_GNB1_CELL1}
##    Run Keyword And Ignore Error    stop traffic and detach UE
