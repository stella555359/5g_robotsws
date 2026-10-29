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
#Resource         ../Resources/CB008247_case_steps_SG3.robot
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
#${nrcellid}              1
#${Expect_dl_enable}           350
#${dl_tput_multiue}         500M
#${UE_define}    NULL
#${dl_tput_multiue_365}          500M
#${dl_tput_multiue_374}          700M
#
#
#
#
#*** Test Cases ***
#[1]CB008247-A_Power_Control_verification_with_CSI-RS_FDM
#    [Documentation]    The purpose of this test case is to verify UE specific CSI-RS power control with actCsirsMultiplexing enable
#    ...    and verify UE specific CSI-RS FDM with 1086/8247 on.
#    [Tags]     CRT_22R3    CRT_TRUNK    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Set suite variable for 8247_A_POWER
#    NRCellid Set suit varaible    cellid=${1}
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
#    Log to console    step1-1modify scf and commission
#    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS24R1_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_23R4}     ${golden_scf_24R1_374}
#    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS23R3_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_23R4}     ${golden_scf_23R3_374}
#    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS24R2_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_23R4}     ${golden_scf_24R2_374}
#    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS23R4_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_24R1}     ${golden_scf_23R4_365}
#    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS23R3_ENB_0000'
#    ...    Set Suite Variable    ${golden_scf_24R1}     ${golden_scf_23R3
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True     Is_Swconfig=True     Lock_ENB_Need=True
#    ...                            golden_scf_name=${${golden_scf}}      swconfig_file=${swconfig_paths}
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    ...                            ParamterToModify=${PARAMS_TO_MODIFY_ULSRSBM}
#    ...                            ListParamterToModify=${Modify_List_T1R4_22R3}
#    ...                            ParameterToDelete=${CHANGE_PARA_DELETE}
#    ...                            ListToAdd=${CHANGE_ADD_LIST}
#    ...                            enb_dist_name=${enb_dist_LNCEL1}
#    ...                            enb_parameter=${enb_cell_admin}
#    ...                            enb_value=locked
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#    Log to console    step1-2modify parameters online
#    modify the parameters for case     parameters=${PARAMS_TO_MODIFY_DLSRSBM}
#    sleep    150s
#
#
#
#step2 prepare UE and MCS
#    [Arguments]
#    Log to console    step2 prepare MCS
#    ${mcs_type}=    mcs_common.Get MCS Type
#    set suite variable      ${mcs_type}
#    Prepare MultiUE with client
#    Run keyword if    '${mcs_type}'=='haojin'
#    ...    HAOJIN MCS SETUP AND SET ATT for MultiUE    mcs_type=${mcs_type}    att_value_UE0=${25}    att_value_UE1=${25}
#    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${15}
#    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${25}
#    ...    P5_out=${9}     P6_out=${10}    vertical_3=${96}    horizontal_3=${-10}
#    ...    P7_out=${11}    P8_out=${12}    vertical_4=${96}    horizontal_4=${-20}
#    Run keyword if    '${mcs_type}'=='hbte'
#    ...      HBTE MCS SETUP AND SET ATT for MultiUE     mcs_type=${mcs_type}    att_value_UE0=${25}    att_value_UE1=${25}
#    ...      horizontal_angle_1=${15}     horizontal_angle_2=${25}
#    ...      horizontal_angle_3=${-10}    horizontal_angle_4=${-20}
#
#step3 test procedures
#    Log to console    step3 test procedures
#    Log to console    step3-1attach ue and capture cpiflog for 1st time
#    ${cpif_log_01}=    attach UE and capture wiresharklog with new way    wiresharklog=${8247_wireshark_01}
#    Log to console    step3-2 detach ue0
#    Detach UE without traffic with new way
#    Log to console    step3-3 modify sspbch from 10 to 15, enable DRX
#    modify the parameters for case     parameters=${PARAMS_TO_MODIFY_POWER_CONTROL}
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#    sleep    1min
#    Log to console    step3-4 attach 2ues and capture cpiflog for 2nd time
#    ${cpif_log_02}=    attach multiUEs and capture wiresharklog    wiresharklog=${8247_wireshark_02}
#    Log to console    step3-5 start 2ues traffic and capture biplog
#    sleep    30s
#    ${8247_bip_01}=    Start multiUEs Traffic And Capture Biplog        dl_tput_multiue=${${dl_tput_multiue}}      UE_define=2
#    Check multiUEs traffic with pioneer client    tput_target=${Expect_dl_enable}      UE_define=2
#    Log to console    step3-6 stop 2ues traffic and mcs teardown
#    BuiltIn.Set Test Variable    ${8247_bip_01}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    BuiltIn.Set Test Variable    ${cpif_log_02}
#    [Teardown]    Run Keywords    Stop multiues traffic with appserver
#    ...    AND    Detach MultiUE and stoplog    ue=${uegroup}
#    ...    AND    mcs_common.Teardown MCS    mcs_type=${mcs_type}
#
#
#step4 case check point
#    [Arguments]
#    Log to console    step4 start check point
#    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs    cell_idx=${1}
#    Set Test Variable    ${cprtPatternIdDict}
#    DFTBeam Should Be Used In BIP with mcshark    file_path=${8247_bip_01}
#    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_02}
#    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_02}    srs_ResourceSet=2
#    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_02}    cell_idx=${1}
#    Check PUSCH and CSIRS used DFT beam with mcshark    file_path=${8247_bip_01}
#    Check CSI-RS nrofRBs changed after modify the sspbchpower
#    Check CSI-RS FDMed
#
#
#
#Check CSI-RS nrofRBs changed after modify the sspbchpower
#    ${nrofRBs0}    Get CSI-RS nrofRBs from RRC Message    file_path=${cpif_log_01}
#    ${nrofRBs1}    Get CSI-RS nrofRBs from RRC Message    file_path=${cpif_log_02}
#    ${nrofRBs_before}      convert to number     ${nrofRBs0[0]}
#    ${nrofRBs_after}       convert to number     ${nrofRBs1[0]}
#    should be true    ${nrofRBs_before} > ${nrofRBs_after}
#
#Check CSI-RS FDMed
#    ${CSIRS_FDomain}    Get CSI-RS frequencyDomainAllocation    file_path=${cpif_log_02}
#    ${CSIRS_TDomain}    Get CSI-RS TimeDomainAllocation    file_path=${cpif_log_02}
#    Should Not Be True    '${CSIRS_FDomain[0]}' == '${CSIRS_FDomain[1]}'
#    ${TDomain_length}    Get Length    ${CSIRS_TDomain}
#    ${FDomain_length}    Get Length    ${CSIRS_FDomain}
#    Should Be True    '${TDomain_length}' == '${1}'
#
#
#Case TearDown
#    Run Keyword And Ignore Error     HAOJIN MCS SET Four Output ATT    mcs_type=${mcs_type}    P1_out=${9}    P2_out=${10}
#    ...                                                                P3_out=${11}    P4_out=${12}    att_value_1=${90}    att_value_2=${90}
#    Run Keyword And Ignore Error     Common Case TestLine Setup     Lock_ENB_Need=True     enb_dist_name=${enb_dist_LNCEL1}
#    ...                                                             enb_parameter=${enb_cell_admin}
#    ...                                                             enb_value=unlocked
##    Run Keyword And Ignore Error     stop traffic and MCS teardown        mcs_type=${mcs_type}     ue_num=2
