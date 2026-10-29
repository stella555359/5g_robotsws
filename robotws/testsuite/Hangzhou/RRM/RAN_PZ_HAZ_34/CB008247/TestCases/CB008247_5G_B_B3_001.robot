*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB008247
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
#*** Variables ***
#${8247_wireshark_01}          8247_wireshark_01
#${8247_wireshark_02}          8247_wireshark_02
#${ue_num}                     1
#@{Expect_dl_Trunk}            770     200     600     100
#@{Expect_dl_22R3}             1100    200     500     100
#@{Expect_dl_22R4}             1300    500    1000     200
#@{att_value_Trunk}            25       50
#@{att_value_22R3}             30      80
#@{att_value_22R4}             25      65
#@{output_port_Trunk}          13      16
#@{output_port_22R3}            1       4
#@{output_port_22R4}            1       4
#${dl_throughput}              1150M
#
#
#
#
#*** Test Cases ***
#[1]CB008247-5G-B#B3_001_Check_used_beam_adaptation_when_SRS_out_of_data_and_recovery_when_2200_enabled_CSIRS=4
#    [Documentation]    Purpose of this case is to validate TAS supported UE can attach to 5G cell successfully
#    ...                when 2200 and 8247 feature all enabled.
#    [Tags]     CRT_22R3    CRT_TRUNK    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Set suite variable for 8247_B3_001
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
#    ...    Set Suite Variable    ${golden_scf_24R1}     ${golden_scf_23R3_365}
#    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS24R3_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_24R1}     ${golden_scf_24R3_365}
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True     Is_Swconfig=True    Lock_ENB_Need=True
#    ...                            golden_scf_name=${${golden_scf}}      swconfig_file=${swconfig_paths}
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    ...                            ParamterToModify=${${ParamterToModify}}
#    ...                            ListParamterToModify=${${ListParamterToModify}}
#    ...                            enb_dist_name=${${enb_dist_name}}
#    ...                            enb_parameter=${enb_cell_admin}
#    ...                            enb_value=locked
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#    sleep    180s
#
#
#
#step2 prepare UE and MCS
#    [Arguments]
#    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs    cell_idx=${${cellid}}
#    Set Test Variable    ${cprtPatternIdDict}
#    NRCellid Set suit varaible    cellid=${${cellid}}
#    MCS SETUP AND SET ATT
#    Prepare MultiUE with client
#
#
#
#step3 test procedures
#    ${cpif_log_01}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_01}
#    ${8247_bip_01}=    Start Traffic And Capture Biplog with new way     dlexpect_tp=${${${dlexpect_tp}}[0]}    aa_sys_addr=${${aa_sys_addr}}
#    ...                                                                  dl_throughput=${${dl_tput_multiue}}
#    ...                                                                  target_file_name=BIP_B3001_01
#    sleep    5s
#    Repeat increase decrease the PA for 5 times    att_value_bad=${${${att_value}}[1]}    att_value_good=${${${att_value}}[0]}
#    BuiltIn.Set Test Variable    ${8247_bip_01}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    [Teardown]    stop traffic and MCS teardown with new way    mcs_type=${mcs_type}
#
#step4 case check point
#    [Arguments]
#    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_01}
#    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_01}    srs_ResourceSet=2
#    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_01}    cell_idx=${${cellid}}
#    Check PUSCH used DFT beam with mcshark    file_path=${8247_bip_01}
#    Check CSIRS used PMI beam when CELL specific used with mcshark    file_path=${8247_bip_01}
#    Check CSIRS CELL specific Used    file_path=${cpif_log_01}
#
#
#Repeat increase decrease the PA for 5 times
#    [Arguments]    ${att_value_bad}    ${att_value_good}    ${capturing_time_seconds}=5    ${script_path}=${bipscript_path}
#    FOR    ${in_de}    IN RANGE    ${1}
#       mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_bad}
#       ...    begin_output_port=${${${begin_output_port}}[0]}    end_output_port=${${${end_output_port}}[1]}
#       sleep    15s
#       Check Dl traffic with nrcellid in Diff with new way    cellid=${nrcellid}     dlexpect_tp=${${${dlexpect_tp}}[1]}
#       ...                                                    aa_sys_addr=${${aa_sys_addr}}
#       ${8247_bip_02}=    Capture biplog and download    target_file_name=BIP_B3001_02
#       BuiltIn.Set Test Variable    ${8247_bip_02}
#       mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_good}
#       ...    begin_output_port=${${${begin_output_port}}[0]}    end_output_port=${${${end_output_port}}[1]}
#       sleep    15s
#       Check Dl traffic with nrcellid in Diff with new way    cellid=${nrcellid}     dlexpect_tp=${${${dlexpect_tp}}[0]}
#       ...                                                    aa_sys_addr=${${aa_sys_addr}}
#       ${8247_bip_03}=    Capture biplog and download    target_file_name=BIP_B3001_03
#       DFTBeam Should Be Used In BIP with mcshark    file_path=${8247_bip_03}
#       PMIBeam Should Be Used with mcshark     file_path=${8247_bip_02}
#    END
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
#    ...    vertical_distance=${2.0}   horizontal_distance=${0.5}
#    ...    att_value1=${30}    att_value2=${30}    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
#    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${25}    att_value2=${25}    vertical_angle=${-6}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
#
#
#Case TearDown
#    Run Keyword And Ignore Error     Common Case TestLine Setup     Lock_ENB_Need=True     enb_dist_name=${enb_dist_LNCEL1}
#    ...                                                             enb_parameter=${enb_cell_admin}
#    ...                                                             enb_value=unlocked
#    Run Keyword And Ignore Error    Run keyword if    '${MRBTS_ID}' == '10318'    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                                                                                                     Modify_Para_Online=${UNLOCK_GNB1_CELL1}
#    Run Keyword And Ignore Error    Run keyword if    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS24R2_ENB_0000'
#    ...                                                                           Common Case TestLine Setup    ModifySCF_Beforecommission=True
#    ...                                                                                                         golden_scf_name=${golden_scf_24R2_CA}
#    Run Keyword And Ignore Error     stop traffic and detach UE
