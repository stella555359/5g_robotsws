*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB008247
#
#
#Suite Setup       Run Keywords
#...            robot_common_operations.Common Suite Setup    AND
#...            Run Keyword And Ignore Error     Common Suite Setup for COAM 8247
#
#Suite Teardown          Run Keywords
#...            robot_common_operations.Common Suite Teardown    AND
#...            Run Keyword And Ignore Error     Common Suite Teardown for COAM
#
#Resource         ../Resources/CB008247_case_steps_SG3.robot
#
#
#
#
#*** Variables ***
#${8247_wireshark_01}          8247_wireshark_01
#${8247_wireshark_02}          8247_wireshark_02
#@{Expect_dl_Trunk}            770     200
#@{Expect_dl_22R3}             1100     20
#@{Expect_dl_22R4}             1300     20
#${ue_num_1}                   1
#${dl_throughput}              1150M
#${allow_fault_list}           7115    7312
#
#*** Test Cases ***
#[1]CB008247-5G-B#B4_003_power_control_verification_for_specific_CSIRS_frequency _multiplexing
#    [Documentation]
#    ...    B4_003:Purpose of this case is to validate power control of cell specific CSIRS frequency multiplexing
#    ...    with actCsirsMultiplexing enable.
#    ...    B4_001: Purpose of this case is to validate 4 cell specific CSIRS frequency multiplexing correct, can check it with 8247
#    ...    disable or use rdNumberOfUeCsirsSymbol=0 to trigger cell specific CSIRS allocation if 8247 enabled.
#    [Tags]     CRT_22R3    CRT_TRUNK    CIT_TRUNK    CRT_22R4    CIT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Set suite variable for 8247_B4_003
#    step1 prepare the envrionment
#    step2 prepare UE and MCS
#    step3 test procedures
#    step4 case check point
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Case TearDown
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
#    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS24R3_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_24R1}     ${golden_scf_24R3_365}
#    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS23R3_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_24R1}     ${golden_scf_23R3}
#    Log to console    step1-1 modify scf and commission
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True     Is_Swconfig=True
#    ...                            golden_scf_name=${${golden_scf}}      swconfig_file=${swconfig_paths}
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    ...                            ParamterToModify=${${ParamterToModify}}
#    ...                            ListParamterToModify=${${ListParamterToModify}}
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#    Log to console    step1-2 enble DLRSRBM online
#    Common Case TestLine Setup     ModifySCF_Aftercommission=True
#    ...                            Modify_Para_Online=${${PARA_modify}}
#    ...                            Lock_ENB_Need=True
#    ...                            enb_dist_name=${${enb_dist_name}}
#    ...                            enb_parameter=${enb_cell_admin}
#    ...                            enb_value=locked
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#    sleep    180s
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#
#step2 prepare UE and MCS
#    [Arguments]
#    Log to console    step2 prepare MCS
#    ${cprtPatternIdDict}    Run Keyword If    '${MRBTS_ID}' == '10318'    Get patternIdDict From CPRT Logs for special tl    cell_idx=${${cellid}}
#    ...    ELSE     Get BeampatternIdDict From CPRT Logs    cell_idx=${${cellid}}
#    Set Test Variable    ${cprtPatternIdDict}
#    NRCellid Set suit varaible    cellid=${${cellid}}
#    MCS SETUP AND SET ATT
#    Prepare MultiUE with client
#
#
#step3 test procedures
#    Log to console    step3 test procedures
#    Log to console    step3-1 attach ue and capture cpiflog for 1st time
#    ${cpif_log_01}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_01}
#    Log to console    step3-2 detach ue0
#    Detach UE without traffic with new way
#    Log to console    step3-3 modify ssPbchBlockPower from 10 to 15 online
#    modify the parameters for case     parameters=${${online_modify}}
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#    sleep    180s
#    Log to console    step3-4 attach ue and capture cpiflog for 2nd time
#    ${cpif_log_02}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_02}
#    Log to console    step3-5 start ue traffic and capture biplog
#    ${8247_bip_01}=    Start Traffic And Capture Biplog with new way     dlexpect_tp=${${${dlexpect_tp}}[0]}    aa_sys_addr=${${aa_sys_addr}}
#    ...                                                                  dl_throughput=${${dl_tput_multiue}}
#    Log to console    step3-6 stop ue traffic and mcs teardown
#    BuiltIn.Set Test Variable    ${8247_bip_01}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    BuiltIn.Set Test Variable    ${cpif_log_02}
#    [Teardown]    stop traffic and MCS teardown with new way         mcs_type=${mcs_type}
#
#
#step4 case check point
#    Log to console    step4 start check point
#    DFTBeam Should Be Used In BIP with mcshark    file_path=${8247_bip_01}
#    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_01}
#    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_02}    srs_ResourceSet=2
#    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_02}    cell_idx=${${cellid}}
#    Check PUSCH used DFT beam with mcshark    file_path=${8247_bip_01}
#    Check CSIRS CELL specific Used    file_path=${cpif_log_02}
#    Check CSI-RS nrofRBs changed after modify the sspbchpower
#    Check CELL Specific CSI-RS FDMed
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
#    ...    vertical_distance=${2.0}   horizontal_distance=${0.5}
#    ...    att_value1=${30}    att_value2=${30}    vertical_angle=${96}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
#    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${25}    att_value2=${25}    vertical_angle=${-6}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}
#
#Check CSI-RS nrofRBs changed after modify the sspbchpower
#    ${nrofRBs0}    Get CSI-RS nrofRBs from RRC Message    file_path=${cpif_log_01}    nrofPorts=3    csirs_filter=nr-rrc.rrcReconfiguration_element
#    ${nrofRBs1}    Get CSI-RS nrofRBs from RRC Message    file_path=${cpif_log_02}    nrofPorts=3    csirs_filter=nr-rrc.rrcReconfiguration_element
#    ${nrofRBs_before}      convert to number     ${nrofRBs0[0]}
#    ${nrofRBs_after}       convert to number     ${nrofRBs1[0]}
#    should be true     ${nrofRBs_before} > ${nrofRBs_after}
#
#Check CELL Specific CSI-RS FDMed
#    ${CSIRS_FDomain_1}    Get CELL Spcific CSI-RS frequencyDomainAllocation    file_path=${cpif_log_02}    num=1
#    ${CSIRS_FDomain_2}    Get CELL Spcific CSI-RS frequencyDomainAllocation    file_path=${cpif_log_02}    num=2
#    ${CSIRS_FDomain_3}    Get CELL Spcific CSI-RS frequencyDomainAllocation    file_path=${cpif_log_02}    num=3
#    ${CSIRS_FDomain_4}    Get CELL Spcific CSI-RS frequencyDomainAllocation    file_path=${cpif_log_02}    num=4
#    ${CSIRS_TDomain_1}    Get CELL Specific CSI-RS TimeDomainAllocation    file_path=${cpif_log_02}    num=1
#    ${CSIRS_TDomain_2}    Get CELL Specific CSI-RS TimeDomainAllocation    file_path=${cpif_log_02}    num=2
#    ${CSIRS_TDomain_3}    Get CELL Specific CSI-RS TimeDomainAllocation    file_path=${cpif_log_02}    num=3
#    ${CSIRS_TDomain_4}    Get CELL Specific CSI-RS TimeDomainAllocation    file_path=${cpif_log_02}    num=4
#    Should Be True    '${CSIRS_FDomain_1[0]}' == '${CSIRS_FDomain_2[0]}'
#    Should Be True    '${CSIRS_FDomain_3[0]}' == '${CSIRS_FDomain_4[0]}'
#    Should Be True    '${CSIRS_TDomain_1[0]}' == '${CSIRS_TDomain_3[0]}'
#    Should Be True    '${CSIRS_TDomain_2[0]}' == '${CSIRS_TDomain_4[0]}'
#
#
#
#
#Case TearDown
#    Run Keyword And Ignore Error     Common Case TestLine Setup     Lock_ENB_Need=True     enb_dist_name=${${enb_dist_name}}
#    ...                                                             enb_parameter=${enb_cell_admin}
#    ...                                                             enb_value=unlocked
#    Run Keyword And Ignore Error    Run keyword if    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS24R2_ENB_0000'
#    ...                                                                           Common Case TestLine Setup    ModifySCF_Beforecommission=True
#    ...                                                                                                         golden_scf_name=${golden_scf_24R2_CA}
#    Run Keyword And Ignore Error     stop traffic and detach UE with new way
