*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB008247
#
#
#Suite Setup         Run keyword    SUITE SETUP FOR UTE
#
#Suite Teardown      Run keyword    SUITE TEARDOWN FOR UTE
#
#Resource          ../Resources/CB008247_case_steps_SG3.robot
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
#
#Force Tags    QCA_5G_RRM    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_QC_ASIML_ABIOB1B2_AEQV_AZQO_ENB
#...           PY36


#*** Variables ***
#${8247_T1R4_01}             8247_T1R4_01
#${8247_T1R4_02}             8247_T1R4_02
#${8247_B4003_01}            8247_B4003_01
#${8247_B4003_02}            8247_B4003_02
#${2200_wireshark_01}        2200_wireshark_01
#${10602_wireshark_01}       10602_wireshark_01
#${t1r4_bip_01}              t1r4_bip_01
#${t1r4_bip_02}              t1r4_bip_02
#${B4_003_bip_01}            B4_003_bip_01
#${10602_bip_01}             10602_bip_01
#@{Expect_dl_cloud}          1250    1300    1000    200     1200     1470
#${golden_scf_cloud}         SCF_SBTS00.xml
#${testline_name}            7_5_UTE5G402T362
#${TS_LOG_PATH_BASE}         /home/ute/test_results/
#${target_dir}               /home/ute/test_results/
#${Gnb_cell2_dist}           MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
#@{ALLOWED_FAULT_ID}         4654    61652    61524    4592    7311    7300    4655    61649    4681
#${cloud_phy_cell_ids}        51
#${dl_throughput_cloud}       550M



#*** Test Cases ***
#[1]CB008247-A_PRACH_T1R4_with_TAS_reuse_codebook_or_not_configuration
#    [Documentation]    The purpose of this test case is to verify beam switch with codebook P-SRS both used for DL and UL.
#    [Tags]     master_classicalbts_all     CRT_TRUNK    CIT_TRUNK    SBTS00    CRT_UTE
#    [Setup]    robot_common_operations.Common Case Setup
#    #step1 prepare the envrionmen
#    Generate test case log path
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True      gnb_type='NSA'    is_x2_check_from_gnb_needed=${True}
#    ...                            scf_dir_path=${TS_CASE_LOG_PATH}
#    ...                            scf_path=${Golden_SCF_Path}
#    ...                            golden_scf_name=${golden_scf_cloud}
#    ...                            ParameterToDelete=${PARA_DELETE_T1R4_cloud}
#    ...                            ListToAdd=${ADD_LIST_T1R4_cloud}
#    ...                            ParamterToModify=${PARAMS_TO_MODIFY_TAS_reuse_cloud}
#    ...                            ListParamterToModify=${Modify_List_T1R4_cloud}
#    ...                            Is_Swconfig=True    swconfig_file=${Golden_SCF_Path}/swconfig.txt
#    ...                            swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    ...                            Lock_ENB_Need=True
#    ...                            enb_dist_name=${enb_dist_LNCEL1}
#    ...                            enb_parameter=${enb_cell_admin}
#    ...                            enb_value=unlocked
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${TS_CASE_LOG_PATH}
#    sleep    180s
#    ##step2 prepare UE and MCS
#    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
#    ...    att_value1=${25}    att_value2=${25}    vertical_angle=${-6}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
#    UE prepare with Power UE
#    ##step3 test procedures
#    ${cpif_log_01}=    attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${8247_T1R4_01}    4G_check=True
#    ${8247_bip_01}=    Start Traffic And Capture Biplog for CLOUD UTE     dlexpect_tp=${Expect_dl_cloud}[5]    biplog_name=${t1r4_bip_01}
#    ...                                                                   dl_throughput=${dl_throughput_T1R4}      duration=5m
#    stop traffic and detach UE
#    sleep    5s
#    modify the parameters for case     parameters=${PARAMS_TO_MODIFY_NOTREUSE_cloud}    is_x2_check_from_enb_needed=${True}     gnb_type='NSA'
#    sleep    180s
#    ${cpif_log_02}=    attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${8247_T1R4_02}    4G_check=True
#    ${8247_bip_02}=    Start Traffic And Capture Biplog for CLOUD UTE     dlexpect_tp=${Expect_dl_cloud}[5]    biplog_name=${t1r4_bip_02}
#    ...                                                                   dl_throughput=${dl_throughput_T1R4}      duration=5m
#    sleep    10s
#    stop traffic and MCS teardown     mcs_type=${mcs_type}
#    BuiltIn.Set Test Variable    ${8247_bip_01}
#    BuiltIn.Set Test Variable    ${8247_bip_02}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    BuiltIn.Set Test Variable    ${cpif_log_02}
#    #step4 case check point
#    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs for CLOUD    cell_idx=${2}
#    Set Test Variable    ${cprtPatternIdDict}
#    DFTBeam Should Be Used In BIP with mcshark    file_path=${8247_bip_01}
#    DFTBeam Should Be Used In BIP with mcshark    file_path=${8247_bip_02}
#    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_01}    srs_ResourceSet=2
#    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_02}    srs_ResourceSet=2
#    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_02}    cell_idx=${2}
#    Check SRSresource reuse in RRC Message    file_path=${cpif_log_01}
#    Check SRSresource reuse in RRC Message    file_path=${cpif_log_02}    resource_reues_status=${False}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Case TearDown

#[1]CB008247-5G-B#B4_003_power_control_verification_for_specific_CSIRS_frequency _multiplexing
#    [Documentation]
#    ...    B4_003:Purpose of this case is to validate power control of cell specific CSIRS frequency multiplexing
#    ...    with actCsirsMultiplexing enable.
#    ...    B4_001: Purpose of this case is to validate 4 cell specific CSIRS frequency multiplexing correct, can check it with 8247
#    ...    disable or use rdNumberOfUeCsirsSymbol=0 to trigger cell specific CSIRS allocation if 8247 enabled.
#    [Tags]     CRT_22R3    CRT_TRUNK    CIT_TRUNK    CRT_22R4    CIT_22R4
#    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,4681
#    Set suite variable for 8247_B4_003
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    ##step1 prepare the envrionment
#    Generate test case log path
#    Log to console    step1-1 modify scf and commission
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True
#    ...                            scf_dir_path=${SUITE_LOG_PATH}
#    ...                            scf_path=${Golden_SCF_Path}
#    ...                            golden_scf_name=SCF_${stream}.xml
#    ...                            ParamterToModify=${PARAMS_TO_MODIFY_B4003_cloud}
#    ...                            ListParamterToModify=${Modify_List_T1R4_cloud}
#    ...                            Is_Swconfig=True    swconfig_file=${Golden_SCF_Path}/swconfig.txt
#    ...                            swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${TS_CASE_LOG_PATH}
#    Log to console    step1-2 enble DLRSRBM online
#    Common Case TestLine Setup     ModifySCF_Aftercommission=True
#    ...                            Modify_Para_Online=${PARAMS_TO_MODIFY_DLSRSBM_cloud}
##    ...                            Lock_ENB_Need=True
##    ...                            enb_dist_name=${enb_dist_LNCEL1}
##    ...                            enb_parameter=${enb_cell_admin}
##    ...                            enb_value=barred
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${TS_CASE_LOG_PATH}
#    sleep    180s
#    ##step2 prepare UE and MCS
#    Log to console    step2 prepare MCS
#    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs for CLOUD     cell_idx=${2}
#    Set Test Variable    ${cprtPatternIdDict}
#    ##MCS SETUP AND SET ATT
#    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}    frequency=2600_1_ALL    end_input_port=${32}
#    ...    att_value1=${0}    att_value2=${0}    vertical_angle=${-6}    vertical_distance=${2.1}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
#    UE prepare with Power UE
#    ##step3 test procedures
#    Log to console    step3-1 attach ue and capture cpiflog for 1st time
#    ${cpif_log_01}=    attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${8247_B4003_01}
#    Log to console    step3-2 detach ue0
#    Detach UE without traffic
#    Log to console    step3-3 modify ssPbchBlockPower from 10 to 15 online
#    modify the parameters for case     parameters=${PARAMS_TO_MODIFY_CSIRS_PBCH_POWER_cloud}
#    sleep    180s
#    Log to console    step3-4 attach ue and capture cpiflog for 2nd time
#    ${cpif_log_02}=    attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${8247_B4003_02}
#    Log to console    step3-5 start ue traffic and capture biplog
#    ${8247_bip_01}=    Start Traffic And Capture Biplog for CLOUD UTE     dlexpect_tp=${Expect_dl_cloud}[1]    biplog_name=${B4_003_bip_01}
#    ...                                                                   dl_throughput=${dl_throughput_cloud}
#    Log to console    step3-6 stop ue traffic and mcs teardown
#    stop traffic and MCS teardown        mcs_type=${mcs_type}
#    BuiltIn.Set Test Variable    ${8247_bip_01}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    BuiltIn.Set Test Variable    ${cpif_log_02}
#    ##step4 case check point
#    Log to console    step4 start check point
#    DFTBeam Should Be Used In BIP with mcshark    file_path=${8247_bip_01}    filter=dldata_pdschsendreql1sw
#    ...                                                                        pdsch_xpath=DlData_PdschGrantL1sw
#    Check TAS SRS Is Used in RRC Message Cloud UTE    file_path=${cpif_log_01}
#    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_02}    srs_ResourceSet=2
#    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_02}    cell_idx=${2}
#    Check PUSCH used DFT beam with mcshark    file_path=${8247_bip_01}    filter=uldata_puschreceivereq
#    ...                                       pusch_xpath=.//UlData_eCpriConfigStruct_t.patternId_item
#    Check CSIRS CELL specific Used    file_path=${cpif_log_02}
#    Check CSI-RS nrofRBs changed after modify the sspbchpower
#    Check CELL Specific CSI-RS FDMed
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Case TearDown
#
#[1]5GC002056_BGAR_2200_C_007_PM_counter_impact_after_2200_activated
#    [Documentation]
#    ...    this test case is to verify interworking online modify eirp with 2200 enable.
#    [Tags]      classical    CRT_22R2    CRT_TRUNK     CRT_22R3    CIT_TRUNK    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,4681
#    Generate test case log path
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Common Case TestLine Setup    ModifySCF_Beforecommission=True
#    ...                           scf_dir_path=${SUITE_LOG_PATH}
#    ...                           scf_path=${Golden_SCF_Path}
#    ...                           golden_scf_name=SCF_${stream}.xml
#    ...                           ParameterToDelete=${PARA_TO_DELETE_C007_cloud}
#    ...                           ListToAdd=${LIST_TO_ADD_C007_cloud}
#    ...                           ParamterToModify=${PARA_TO_MODIFY_C007_cloud}
#    ...                           ListParamterToModify=${LIST_TO_MODIFY_C007_cloud}
#    ...                           Is_Swconfig=True
#    ...                           swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
#    ...                           swconfig_file=${Golden_SCF_Path}/swconfig.txt
#    ...                           swconfig_modify=${swconfig_C007_FLAG}
##    ...                           Lock_ENB_Need=True
##    ...                           enb_dist_name=${enb_dist_LNCEL1}
##    ...                           enb_parameter=${enb_cell_admin}
##    ...                           enb_value=barred
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${TS_CASE_LOG_PATH}
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                           Modify_Para_Online=${PARA_Modify_online_C007}
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${TS_CASE_LOG_PATH}
#    sleep    180s
#    UE prepare with Power UE
#    TOPYOUNG MCS SETUP Phases AND SET ATT   mcs_type=${mcs_type}    frequency=2600_1_ALL    end_input_port=${32}
#    ...    att_value1=${0}    att_value2=${0}    vertical_angle=${-6}    vertical_distance=${2.1}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}
#    ${cpif_log_01}=     attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${2200_wireshark_01}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    Analysis 2200_C007 log    file_path=${cpif_log_01}
#    Start UE traffic and check stream for CLOUD UTE    dlexpect_tp=${Expect_dl_cloud}[1]
#    ...                                                throughput=${dl_throughput_cloud}
#    sleep    60s
#    Wait Until Keyword Succeeds    6m    10s    Check throughput reduce    Expect_Control_Tput=${Expect_dl_cloud}[2]
#    ...                                                                    Expect_compare_Tput=${Expect_dl_cloud}[3]
#    stop traffic and detach UE
#    Modify EIRP Segments Configuration Online    dist_id=${Gnb_cell2_dist}
#    sleep    180s
#    UE attach for QCOM and verify with retry
#    Start UE traffic and check stream for CLOUD UTE    dlexpect_tp=${Expect_dl_cloud}[1]
#    ...                                                throughput=${dl_throughput_cloud}
#    sleep    50s
#    Wait Until Keyword Succeeds    6m    10s    Check throughput reduce    Expect_Control_Tput=${Expect_dl_cloud}[2]
#    ...                                                                    Expect_compare_Tput=${Expect_dl_cloud}[3]
#    Check the PM counter shuould not be 0    counter_id=${counter_id_C007_1}    dic_path=${counter_dic_path_C007_cloud}    counter_lenth=7
#    Check the PM counter shuould be 0    counter_id=${counter_id_C007_0}    dic_path=${counter_dic_path_C007_cloud}    out_of_beamid=6
#    stop traffic and MCS teardown        mcs_type=${mcs_type}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error     Case TearDown
#
#
#[1]CB010602A_01_B2_Single_UE_Beam_power_balance_rank4_8x4_UE_specific_CSIRS
#    [Documentation]
#    ...    Beam power balanced was extened to 8x4/4x4 and rank=3/4.L2PS will dynamic adjust pdsch power between two beams.
#    ...    New counter was updated for Number of Beam Power Offset used for rank3 and rank4
#    [Tags]     CRT_23R1    CRT_TRUNK    CIT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,4681
#    ##step1 prepare the envrionment
#    Generate test case log path
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Log to console    \n*** modify scf and commission ***
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True
#    ...                            scf_dir_path=${SUITE_LOG_PATH}
#    ...                            scf_path=${Golden_SCF_Path}
#    ...                            golden_scf_name=SCF_${stream}.xml
#    ...                            ParamterToModify=${PARAMS_TO_MODIFY_A01_cloud}
#    ...                            ListParamterToModify=${LIST_TO_MODIFY_A01_cloud}
#    ...                            Is_Swconfig=True
#    ...                            swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
#    ...                            swconfig_file=${Golden_SCF_Path}/swconfig.txt
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${TS_CASE_LOG_PATH}
#    sleep    180s
#    ${dl_expect_throughput}    ${ul_expect_throughput}    nrdim.Get Theoretical Throughput
#    ...     scf_path=${Golden_SCF_Path}/${golden_scf_cloud}    cell_id=${2}
#    ##step2 prepare UE and MCS
#    Log to console    \n*** prepare MCS ***
#    ${cprtPatternIdDict}      Get BeampatternIdDict From CPRT Logs for CLOUD     cell_idx=${nrcellid_cell2}
#    Set Test Variable    ${cprtPatternIdDict}
#    NRCellid Set suit varaible    cellid=${nrcellid_cell2}
#    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}    frequency=2600_1_ALL    end_input_port=${32}
#    ...    att_value1=${5}    att_value2=${0}    vertical_angle=${-6}    vertical_distance=${2.1}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}
#    UE prepare with Power UE
#    ##step3 test procedures
#    Log to console    \n*** attach ue and capture cpiflog ***
#    ${cpif_log_01}=    attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${10602_wireshark_01}
#    Log to console    \n*** start traffic and capture biplog ***
#    ${10602_bip_01}=    Start Traffic And Capture Biplog for CLOUD UTE     dlexpect_tp=${dl_expect_throughput}    biplog_name=${10602_bip_01}
#    ...                                                                    dl_throughput=${dl_throughput_cloud}      duration=5m
#    Log to console    \n*** stop ue traffic and mcs teardown ***
#    stop traffic and MCS teardown        mcs_type=${mcs_type}
#    BuiltIn.Set Test Variable    ${10602_bip_01}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    ##step4 case check point
#    Log to console    \n*** check point ***
#    Check PM counter for 10602    counter_id=${counter_id_10602_Trunk}    counter_dic_path=${counter_dic_path_10602_cloud}
#    DFTBeam Should Be Used In BIP with mcshark    file_path=${10602_bip_01}    filter=dldata_pdschsendreql1sw
#    ...                                                                        pdsch_xpath=DlData_PdschGrantL1sw
#    Check PUSCH used DFT beam with mcshark    file_path=${10602_bip_01}    filter=uldata_puschreceivereq
#    ...                                       pusch_xpath=.//UlData_eCpriConfigStruct_t.patternId_item
#    Check CSIRS UE specific Used Cloud UTE    file_path=${cpif_log_01}
#    Check bestbeampoweroffset    file_path=${10602_bip_01}    csirsresoure_filter=DlData_CsiRsResourceL1sw_t.csiRsConfig
#    ...                          csirs_filter=dldata_csirssendreql1sw
#    ...                          csirs_xpath=DlData_CsiRsResourceL1sw_t.csiBestBeamPowerOffset
#    ...                          bestbeam_xpath=DlData_PdschGrantL1sw.bestBeamPowerOffset
#    ...                          bestbeam_filter=dldata_pdschsendreql1sw
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Case TearDown
#
#
#
#*** Keywords ***
####[1]CB008247-5G-B#B4_003_power_control_verification_for_specific_CSIRS_frequency _multiplexing###
#Check CSI-RS nrofRBs changed after modify the sspbchpower
#    ${nrofRBs0}    Get CSI-RS nrofRBs from RRC Message    file_path=${cpif_log_01}    nrofPorts=3    csirs_filter=nr-rrc.rrcReconfiguration_element
#    ${nrofRBs1}    Get CSI-RS nrofRBs from RRC Message    file_path=${cpif_log_02}    nrofPorts=3    csirs_filter=nr-rrc.rrcReconfiguration_element
#    should be true    '${nrofRBs0[0]}' > '${nrofRBs1[0]}'
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
####[1]5GC002056_BGAR_2200_C_007_PM_counter_impact_after_2200_activated###
#Analysis 2200_C007 log
#    [Arguments]    ${file_path}
#    ${nrofPorts}=    Get CSIRS_nrofPorts from CPIF    file_path=${file_path}
#    should contain    ${nrofPorts}    p8     # enable actTddCsiImRm impact csirs num
##    should contain x times    ${nrofPorts}    p8    4
#    ${cdm_Type}=     Get CSIRS_cdm_Type from CPIF     file_path=${file_path}
#    should contain    ${cdm_Type}    2
#    ${n1-n2}=        Get CSIRS_n1_n2 from CPIF        file_path=${file_path}
#    should contain    ${n1-n2}       1
#
#Modify EIRP Segments Configuration Online
#   [Arguments]     ${dist_id}
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=${WEBUI_COAM}
#    ...                    username=${WEBUI_NAME}
#    ...                    password=${WEBUI_PWD}
#    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
#    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
#    selenium_coam.disable_message_box
#    Wait Until Keyword Succeeds    5min   5s
#    ...    selenium_coam.set_parameter_value    dist_name=${dist_id}
#    ...    filter_param=Number of cell segment edges in azimuth
#    ...    new_value=2
#    Wait Until Keyword Succeeds    5min   5s
#    ...    selenium_coam.set_parameter_value    dist_name=${dist_id}
#    ...    filter_param=Cell segment edge azimuth 1
#    ...    new_value=20
#    Run Keyword And Ignore Error    selenium_coam.delete_parameter    dist_name=${dist_id}
#    ...    filter_param=Cell segment edge azimuth 2
#    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=${dist_id}
#    ...    filter_param=List of EIRP control power reduction factor per cell segment
#    ...    node_index=0
#    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=${dist_id}
#    ...    filter_param=List of EIRP control power reduction factor per cell segment
#    ...    node_index=1
#    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=${dist_id}
#    ...    filter_param=List of EIRP control power reduction factor per cell segment
#    ...    node_index=2
#    Wait Until Keyword Succeeds    5min   5s
#    ...    selenium_coam.set_parameter_value    dist_name=${dist_id}
#    ...    filter_param=Cell segment edge elevation 0
#    ...    new_value=33
#    Wait Until Keyword Succeeds    5min   5s
#    ...    selenium_coam.set_parameter_value    dist_name=${dist_id}
#    ...    filter_param=Cell segment edge elevation 1
#    ...    new_value=30
#    sleep    3s
#    selenium_coam.validate_plan
#    sleep    3s
#    selenium_coam.activate_plan    activate_plan_despite_errors=True
#    sleep    5s
#    [Teardown]    selenium_coam.logout
#
#
#
#Check throughput reduce
#    [Arguments]    ${Expect_Control_Tput}    ${Expect_compare_Tput}
#    ${dlul_tp_l2l0}      Power UE check throughput with nrcellid    cellid=${nrcellid}    dlexpect=${Expect_compare_Tput}    ue_type=${ue_type_0}
#    should be true    ${Expect_Control_Tput} > ${dlul_tp_l2l0}
#
#Check the PM counter shuould not be 0
#    [Arguments]    ${counter_id}    ${dic_path}    ${counter_lenth}
#    Connect to gnb coam via ssl
#    FOR    ${index}    IN RANGE    ${counter_lenth}
#        ${counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
#         ...    dic_path=${dic_path[0]}    timeout=600
#        Should be true    ${counter_value[0]} > ${0}
#    END
#    [Teardown]    COAM Teardown gnb connections
#
#Check the PM counter shuould be 0
#    [Arguments]    ${counter_id}    ${dic_path}    ${out_of_beamid}
#    Connect to gnb coam via ssl
#    FOR    ${index}    IN RANGE    ${out_of_beamid}    64
#        ${index_tmp}=    set variable if    ${index}<10    ${0}${index}    ${index}
#        ${counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${counter_id[0]}${index_tmp}    connection=GNB_OAM
#         ...    dic_path=${dic_path[0]}    timeout=600
#        Should be equal    ${counter_value[0]}    ${0}
#    END
#    [Teardown]    COAM Teardown gnb connections
#
#Record the counter action timer
#    @{utc0} =    Get Time    hour min sec    UTC
#    ${utc0_min} =    convert to integer  ${utc0}[1]
#    ${utc_min} =    Evaluate    ${utc0_min}%5
#    Run Keyword If    ${utc_min}>3    Record time again
#    ${utc_left} =    Evaluate    5-${utc_min}+1
#    set test variable    ${utc_left}
#
#Record time again
#    sleep    1min
#    @{utc0} =    Get Time    hour min sec    UTC
#    ${utc0_min} =    convert to integer  ${utc0}[1]
#    ${utc_min} =    Evaluate    ${utc0_min}%5
#    Set Suite Variable    ${utc_min}
#
#
#
#
#
#Case TearDown
##    Run Keyword And Ignore Error     Common Case TestLine Setup     Lock_ENB_Need=True    enb_dist_name=${enb_dist_LNCEL1}
##    ...                                                             enb_parameter=${enb_cell_admin}
##    ...                                                             enb_value=notBarred
#    Run Keyword And Ignore Error     Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                                                            Modify_Para_Online=${UNLOCK_GNB1_CELLs}
#    Run Keyword And Ignore Error     Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                                                            Modify_Para_Online=${Unlock_gnb1_AMF1}
#    Run Keyword And Ignore Error     stop traffic and detach UE
#    Run Keyword And Ignore Error     mcs_common.Teardown MCS    mcs_type=${mcs_type}
#    Run Keyword And Ignore Error     Common Case Teardown for COAM    log_path=${TS_CASE_LOG_PATH}
