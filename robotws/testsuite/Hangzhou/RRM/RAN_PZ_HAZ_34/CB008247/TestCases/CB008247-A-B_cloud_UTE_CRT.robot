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
#Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002200/Resources/tput_output.py
#
#Force Tags    QCA_5G_RRM    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_QC_ASIML_ABIOB1B2_AEQV_AZQO_ENB
#...           PY36


#*** Variables ***
#${74278_wireshark_01}          74278_wireshark_01
#${70137_wireshark_01}          70137_wireshark_01
#${70137_wireshark_02}          70137_wireshark_02
#${change_wireshark_01}         8247_change_01
#${change_wireshark_02}         8247_change_02
#${beamswitch_wireshark_01}     8247_beamswitch_01
#${8247_W06_wireshark_01}       8247_W06_wireshark_01
#${B3001_wireshark_01}          8247_B3001_wireshark_01
#${change_bip_01}               change_bip_01
#${change_bip_02}               change_bip_02
#${change_bip_03}               change_bip_03
#${beamswitch_bip_01}           beamswitch_bip_01
#${beamswitch_bip_02}           beamswitch_bip_02
#${8247_W06_bip_01}             8247_W06_bip_01
#${B3001_bip_01}                8247_B3001_bip_01
#${B3001_bip_02}                8247_B3001_bip_02
#${B3001_bip_03}                8247_B3001_bip_03
#@{Expect_dl_cloud}             1250    1300    1000    200    580    500
#${golden_scf_cloud}            SCF_SBTS00.xml
#${testline_name}               7_5_UTE5G402T362
#${TS_LOG_PATH_BASE}            /home/ute/test_results/
#${target_dir}                  /home/ute/test_results/
#${Gnb_cell2_dist}              MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
#@{att_value_cloud}             10    20    55
#${csv_file_B04}                2200_B04_result.csv
#${ALLOWED_FAULT_ID}            4655    4654    61652    61524    4592    7311
#${cloud_phy_cell_ids}          51
#${csv_file_good}               8247-W06_good_result.csv
#${csv_file_midial}             8247-W06_midial_result.csv
#${csv_file_poor}               8247-W06_poor_result.csv
#${good_target}                 1350
#${midial_target}               800
#${poor_target}                 400
#${Expect_dl_enable}            100
#${dl_throughput_cloud}         500M
#
#
#*** Test Cases ***
##[1]5GC002056_BGAR_2200_B_004_max_DL_Tput_with_4_resources_and_beamset_6_good_condition_1208_frametype_SA
##    [Documentation]
##    ...    this test case is to verify in good air condition(around -60dbm) ,
##    ...    when 2200 feature is enabled, the average dl tput is better than the one when 2200 disabled
##    ...    n1:n2 will use 2x2, PA port 1and2, 7and8, 13and14, 15and16.
##    [Tags]     master_classicalbts_all     CRT_TRUNK     SBTS00    CRT_UTE    CDRT_TRUNK
##    [Timeout]    1 hour
##    [Setup]    robot_common_operations.Common Case Setup
##    Generate test case log path
##    Common Case TestLine Setup    ModifySCF_Beforecommission=True
##    ...                           scf_dir_path=${SUITE_LOG_PATH}
##    ...                           scf_path=${Golden_SCF_Path}
##    ...                           golden_scf_name=${golden_scf_cloud}
##    ...                           ParameterToDelete=${PARA_TO_DELETE_C007}
##    ...                           ListToAdd=${LIST_TO_ADD_C007}
##    ...                           ParamterToModify=${PARA_TO_MODIFY_C007}
##    ...                           ListParamterToModify=${LIST_TO_MODIFY_C007}
##    ...                           Is_Swconfig=True
##    ...                           swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
##    ...                           swconfig_file=${Golden_SCF_Path}/swconfig.txt
##    ...                           swconfig_modify=${swconfig_C007_FLAG}
##    ...                           Lock_ENB_Need=True
##    ...                           enb_dist_name=${enb_dist_LNCEL1}
##    ...                           enb_parameter=${enb_cell_admin}
##    ...                           enb_value=locked
##    UE prepare with Power UE
##    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
##    ...    att_value1=${att_value_cloud}[0]    att_value2=${att_value_cloud}[0]    vertical_angle=${-6}
##    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
##    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}
##    UE attach for QCOM and verify with retry    ue_type=${ue_type_0}
##    Start UE traffic and check tput for CLOUD UTE    dlexpect_tp=${Expect_dl_cloud}[3]
##    sleep    10s
##    Performance Test around
##    Caculate average tput    csv_path=${TS_CASE_LOG_PATH}${csv_file_B04}
##    stop traffic and MCS teardown     mcs_type=${mcs_type}
##    Set test variable       ${Expect_tp}    ${Expect_dl_cloud}[0]
##    should be true    ${ave_Tput} > ${Expect_tp}
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown    AND
##    ...    Run Keyword And Ignore Error     Case TearDown
#
##[1]CNI74278_A_02_SA_max_DLUL_Tput_with_4CSI-RS_4x1_#2#2_3_3_BW_80M_1116
##    [Documentation]
##    ...    The purpose of this test case is to verify cell on air after NIDD NRCELL.csirsResourceSetConfig4CRI set to 4x1_#2#2_3_3;
##    ...    DL and UL can get peak tput with the right beamweight.
##    ...    2022-1-12,due to 2200 cases optimize, tmpParam9 will change to 20:2x2_#2#2_5_5;
##    ...    beamset will be (2+4)x(4+64)+ 1x(4+16) = 428;
##    ...    "2x2 is already using all vertical freedom with 32TRX RU(2TRX rows).
##    ...     That is the reason why in 2x2-2-2_5_5 configurations we have basically only the left and right CRI.
##    ...    Only 64TRX RU can have intended 2x2-2-2_5_5 configuration with two vertical rows"
##    ...    CNI72687 Counter Num=miNrCellUtilization(min)/csiReportPeriodicity(ms)  e.g.   5min/160ms = 1875
##    ...    2022-3-9, add 72687 4csirs cri counters checkpoints.
##    [Tags]      master_classicalbts_all     CRT_TRUNK    CRT_UTE
##    [Timeout]    1 hour
##    [Setup]    robot_common_operations.Common Case Setup
##    Generate test case log path
##    Common Case TestLine Setup    ModifySCF_Beforecommission=True
##    ...                           scf_dir_path=${SUITE_LOG_PATH}
##    ...                           scf_path=${Golden_SCF_Path}
##    ...                           golden_scf_name=${golden_scf_cloud}
##    ...                           ParamterToModify=${PARA_TO_MODIFY_74278}
##    ...                           ListParamterToModify=${LIST_TO_MODIFY_74278}
##    ...                           Is_Swconfig=True
##    ...                           swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
##    ...                           swconfig_file=${Golden_SCF_Path}/swconfig.txt
##    ...                           Lock_ENB_Need=True
##    ...                           enb_dist_name=${enb_dist_LNCEL1}
##    ...                           enb_parameter=${enb_cell_admin}
##    ...                           enb_value=locked
##    UE prepare with Power UE
##    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
##    ...    att_value1=${25}    att_value2=${25}    vertical_angle=${-6}
##    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-3}
##    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-13}
##    ${cpif_log_01}=    attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${74278_wireshark_01}
##    BuiltIn.Set Test Variable    ${cpif_log_01}
##    Analysis 2200 enable    pcap_file=${cpif_log_01}
##    Check beamweight for CNI74278    beamweight_name=${beamweight_name_cloud}    connection=gnb    beamset_num=860
##    Check beamweight size for CNI65655    beamweight_name=${beamweight_name_cloud}    connection=gnb    bpf_name=${bpf_name_cloud}
##    ...                                   ungzip_bpf_name=${ungzip_bpf_name_cloud}    bpf_name_xml=${bpf_name_xml_cloud}
##    Start UE traffic and check tput for CLOUD UTE    dlexpect_tp=${Expect_dl_cloud}[0]
###    Check UE in the right CRI location on second bbmod
##    stop traffic and MCS teardown        mcs_type=${mcs_type}
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown    AND
##    ...    Run Keyword And Ignore Error    Case TearDown
#
##[1]CNI-70137_005_CSIRS_reconfiguration_with_maxCsirsNumber=4_long_PUCCH_when_DRX_on_duration_is_small_Qualcomm_UE
##    [Documentation]
##    ...    Purpose of this case is to validate the CSIRS number reconfigured to Qualcomm UE which support simultaneousCSI-ReportsPerC=4 when DRX
##    ...    on duration is long enough to allocate 4CSIRS
##    [Tags]      master_classicalbts_all     CRT_TRUNK    CRT_UTE
##    [Timeout]    1 hour
##    [Setup]    robot_common_operations.Common Case Setup
##    Generate test case log path
##    Common Case TestLine Setup    ModifySCF_Beforecommission=True
##    ...                           scf_dir_path=${SUITE_LOG_PATH}
##    ...                           scf_path=${Golden_SCF_Path}
##    ...                           golden_scf_name=${golden_scf_cloud}
##    ...                           ParamterToModify=${PARA_TO_MODIFY_70137}
##    ...                           ListParamterToModify=${LIST_TO_MODIFY_70137}
##    ...                           Is_Swconfig=True
##    ...                           swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
##    ...                           swconfig_file=${Golden_SCF_Path}/swconfig.txt
##    ...                           Lock_ENB_Need=True
##    ...                           enb_dist_name=${enb_dist_LNCEL1}
##    ...                           enb_parameter=${enb_cell_admin}
##    ...                           enb_value=locked
##    UE prepare with Power UE
##    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
##    ...    att_value1=${25}    att_value2=${25}    vertical_angle=${-6}
##    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-3}
##    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-13}
##    ${cpif_log_01}=     attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${70137_wireshark_01}
##    BuiltIn.Set Test Variable    ${cpif_log_01}
##    Check beamweight size for CNI65655    beamweight_name=${beamweight_name_cloud}    connection=gnb    bpf_name=${bpf_name_cloud}
##    ...                                   ungzip_bpf_name=${ungzip_bpf_name_cloud}    bpf_name_xml=${bpf_name_xml_cloud}
##    Start UE traffic and check tput for CLOUD UTE    dlexpect_tp=${Expect_dl_cloud}[0]
##    Power UE stop dl traffic and detach     ue_type=${ue_type_0}    ue_index=${0}
##    Common Case TestLine Setup     ModifySCF_Aftercommission=True
##    ...                            Modify_Para_Online=${DRX_onduration_CLOUD}
##    sleep    10s
##    ${cpif_log_02}=     attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${70137_wireshark_02}
##    BuiltIn.Set Test Variable    ${cpif_log_02}
##    stop traffic and MCS teardown        mcs_type=${mcs_type}
##    Analysis 70137_005 70851
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown    AND
##    ...    Run Keyword And Ignore Error     Case TearDown
#
#[1]CB008247-5G-B#B3_001_Check_used_beam_adaptation_when_SRS_out_of_data_and_recovery_when_2200_enabled_CSIRS=4
#    [Documentation]    Purpose of this case is to validate TAS supported UE can attach to 5G cell successfully
#    ...                when 2200 and 8247 feature all enabled.
#    [Tags]      master_classicalbts_all     CRT_TRUNK    CRT_UTE
#    [Setup]    robot_common_operations.Common Case Setup
#    Generate test case log path
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True
#    ...                            scf_dir_path=${SUITE_LOG_PATH}
#    ...                            scf_path=${Golden_SCF_Path}
#    ...                            golden_scf_name=SCF_${stream}.xml
#    ...                            ParamterToModify=${PARAMS_TO_MODIFY_B3001_cloud}
#    ...                            ListParamterToModify=${List_TO_MODIFY_B3001_cloud}
#    ...                            Is_Swconfig=True
#    ...                            swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    ...                            swconfig_file=${Golden_SCF_Path}/swconfig.txt
##    ...                            Lock_ENB_Need=True
##    ...                            enb_dist_name=${enb_dist_LNCEL1}
##    ...                            enb_parameter=${enb_cell_admin}
##    ...                            enb_value=barred
#    ##ADD EDA_02897242 PDL validation
##    ${PDL_validation_status}    run keyword and return status
##    ...     Common Case TestLine Setup     ModifySCF_Aftercommission=True    gnb_type='NSA'    is_x2_check_from_gnb_needed=${True}
##    ...                                    Modify_Para_Online=${ONLINE_MODIFY_B3001_CLOUD_3}
##    ...                                    skip_parameter_relation_errors=False
##    Should be true    '${PDL_validation_status}' == 'False'
##    ${PDL_validation_status}    run keyword and return status
##    ...     Common Case TestLine Setup     ModifySCF_Aftercommission=True    gnb_type='NSA'    is_x2_check_from_gnb_needed=${True}
##    ...                                    Modify_Para_Online=${ONLINE_MODIFY_B3001_CLOUD_2}
##    ...                                    skip_parameter_relation_errors=False
##    Should be true    '${PDL_validation_status}' == 'False'
##    ${PDL_validation_status}    run keyword and return status
##    ...     Common Case TestLine Setup     ModifySCF_Aftercommission=True    gnb_type='NSA'    is_x2_check_from_gnb_needed=${True}
##    ...                                    Modify_Para_Online=${ONLINE_MODIFY_B3001_CLOUD_1}
##    ...                                    skip_parameter_relation_errors=False
##    Should be true    '${PDL_validation_status}' == 'False'
#    UE prepare with Power UE
#    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}    frequency=2600_1_ALL    end_input_port=${32}
#    ...    att_value1=${0}    att_value2=${0}    vertical_angle=${-6}    vertical_distance=${2.1}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${10}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${20}
#    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs for CLOUD    cell_idx=${2}
#    Set Test Variable    ${cprtPatternIdDict}
#    ${cpif_log_01}=    attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${B3001_wireshark_01}
#    ${biplog_01}=    Start Traffic And Capture Biplog for CLOUD UTE     dlexpect_tp=${Expect_dl_cloud}[2]    biplog_name=${B3001_bip_01}
#    ...                                                                 dl_throughput=${dl_throughput_cloud}
#    sleep    5s
#    Repeat increase decrease the PA for 5 times    att_value_bad=${50}    att_value_good=${0}
#    stop traffic and MCS teardown     mcs_type=${mcs_type}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    BuiltIn.Set Test Variable    ${biplog_01}
#    Check TAS SRS Is Used in RRC Message Cloud UTE    file_path=${cpif_log_01}
#    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_01}    srs_ResourceSet=2
#    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_01}    cell_idx=${2}
#    Check PUSCH used DFT beam with mcshark    file_path=${biplog_01}
#    Check CSIRS used PMI beam when CELL specific used with mcshark for cloud ute    file_path=${biplog_01}
#    ...       filter=dldata_csirssendreql1sw     csirs_expression=DlData_CsiRsResourceL1sw_t
#    Check CSIRS CELL specific Used    file_path=${cpif_log_01}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Case TearDown
#
##[1]CB008247-A_Change_tiltOffset_and_verify_Traffic_with_DL_TAS_UL_codebook_P-SRS
##    [Documentation]    The purpose of this test case is to verify traffic with different tiltOffset
##    [Tags]     master_classicalbts_all     CRT_TRUNK     SBTS00    CRT_UTE
##    [Setup]    robot_common_operations.Common Case Setup
##    Generate test case log path
##    Common Case TestLine Setup     ModifySCF_Beforecommission=True
##    ...                            scf_dir_path=${SUITE_LOG_PATH}
##    ...                            scf_path=${Golden_SCF_Path}
##    ...                            golden_scf_name=${golden_scf_cloud}
##    ...                            ParamterToModify=${CHANGE_MODIFY_PARA_cloud}
##    ...                            ParameterToDelete=${CHANGE_PARA_DELETE_cloud}
##    ...                            ListToAdd=${CHANGE_ADD_LIST_cloud}
##    ...                            ListParamterToModify=${CHANGE_MODIFY_LIST_cloud}
##    ...                            Is_Swconfig=True
##    ...                            swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
##    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
##    ...                            swconfig_file=${Golden_SCF_Path}/swconfig.txt
##    ...                            Lock_ENB_Need=True
##    ...                            enb_dist_name=${enb_dist_LNCEL1}
##    ...                            enb_parameter=${enb_cell_admin}
##    ...                            enb_value=locked
##    UE prepare with Power UE
##    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
##    ...    att_value1=${25}    att_value2=${25}    vertical_angle=${-6}
##    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
##    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-5}
##    ${cpif_log_01}=    attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${change_wireshark_01}
##    ${biplog_01}=    Start Traffic And Capture Biplog for CLOUD UTE     dlexpect_tp=${Expect_dl_cloud}[4]    biplog_name=${change_bip_01}
##    stop traffic and detach UE
##    Log to console    modify tiltoffset from 0 to -3, actpci change to true, p0srs from -96 to -86
##    modify the parameters for case     parameters=${PARAMS_TO_MODIFY_TILTOFFSET_P0_PCI_cloud}
##    sleep     3min
##    ${cpif_log_02}=    attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${change_wireshark_02}
##    ${biplog_02}=    Start Traffic And Capture Biplog for CLOUD UTE       dlexpect_tp=${Expect_dl_cloud}[4]    biplog_name=${change_bip_02}
##    Log to console    change UE position from -5,-5 to -5,-15
##    TOPYOUNG MCS change UE Phases    mcs_type=${mcs_type}    vertical_angle=${-6}
##    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
##    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}
##    sleep    10s
##    Check Dl traffic with nrcellid in Diff     dlexpect_tp=${Expect_dl_cloud}[0]
##    ${biplog_03}=     Capture biplog and download with WEBUI    target_dir=${TS_CASE_LOG_PATH}/    biplog_name=${change_bip_03}
##    stop traffic and MCS teardown        mcs_type=${mcs_type}
##    BuiltIn.Set Test Variable    ${biplog_01}
##    BuiltIn.Set Test Variable    ${biplog_02}
##    BuiltIn.Set Test Variable    ${biplog_03}
##    BuiltIn.Set Test Variable    ${cpif_log_01}
##    BuiltIn.Set Test Variable    ${cpif_log_02}
##    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs for CLOUD     cell_idx=${2}
##    Set Test Variable    ${cprtPatternIdDict}
##    DFTBeam Should Be Used In BIP with mcshark    file_path=${biplog_01}
##    Check TAS SRS Is Used in RRC Message Cloud UTE    file_path=${cpif_log_01}
##    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_01}    srs_ResourceSet=2
##    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_01}    cell_idx=${2}
##    Check p0NominalSrs has changed    file_path_old=${cpif_log_01}    file_path_new=${cpif_log_02}
##    Check p0 Is Same in SCF And RRC Message    file_path=${cpif_log_02}    cell_idx=${2}
##    Check PUSCH and CSIRS used DFT beam with mcshark    file_path=${biplog_01}
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown    AND
##    ...    Run Keyword And Ignore Error     Case TearDown
#
##[1]CB008247-A_Beam_Switch_DFT_beams_got_from_codebook-P-SRS_with_UE_capable_of_TAS_but_rdPriorSrsForDlBm_codebook
##    [Documentation]    The purpose of this test case is to verify beam switch with codebook P-SRS both used for DL and UL.
##    [Tags]     master_classicalbts_all     CRT_TRUNK     SBTS00    CRT_UTE
##    [Setup]    robot_common_operations.Common Case Setup
##    Generate test case log path
##    Common Case TestLine Setup     ModifySCF_Beforecommission=True
##    ...                            scf_dir_path=${SUITE_LOG_PATH}
##    ...                            scf_path=${Golden_SCF_Path}
##    ...                            golden_scf_name=${golden_scf_cloud}
##    ...                            ParamterToModify=${BEAMSWITCH_MODIFY_PARA_cloud}
##    ...                            ParameterToDelete=${BEAMSWITCH_PARA_DELETE_cloud}
##    ...                            ListToAdd=${BEAMSWITCH_ADD_LIST_cloud}
##    ...                            ListParamterToModify=${BEAMSWITCH_Modify_List_cloud}
##    ...                            Is_Swconfig=True
##    ...                            swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
##    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
##    ...                            swconfig_file=${Golden_SCF_Path}/swconfig.txt
##    ...                            Lock_ENB_Need=True
##    ...                            enb_dist_name=${enb_dist_LNCEL1}
##    ...                            enb_parameter=${enb_cell_admin}
##    ...                            enb_value=locked
##    UE prepare with Power UE
##    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
##    ...    att_value1=${25}    att_value2=${25}    vertical_angle=${-6}
##    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
##    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
##    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs for CLOUD     cell_idx=${2}
##    Set Test Variable    ${cprtPatternIdDict}
##    ${cpif_log_01}=    attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${beamswitch_wireshark_01}
##    ${biplog_01}=    Start Traffic And Capture Biplog for CLOUD UTE     dlexpect_tp=${Expect_dl_cloud}[3]    biplog_name=${beamswitch_bip_01}
##    sleep    5s
##    Log to console    change UE position from 5,15 to -5,-15
##    TOPYOUNG MCS change UE Phases    mcs_type=${mcs_type}    vertical_angle=${-6}
##    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
##    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}
##    sleep    15s
##    Check Dl traffic with nrcellid in Diff     dlexpect_tp=${Expect_dl_cloud}[3]
##    ${biplog_02}=     Capture biplog and download with WEBUI    target_dir=${TS_CASE_LOG_PATH}/    biplog_name=${beamswitch_bip_02}
##    sleep    10s
##    stop traffic and MCS teardown        mcs_type=${mcs_type}
##    BuiltIn.Set Test Variable    ${biplog_01}
##    BuiltIn.Set Test Variable    ${biplog_02}
##    BuiltIn.Set Test Variable    ${cpif_log_01}
##    DFTBeam Should Be Used In BIP with mcshark    file_path=${biplog_01}
##    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_01}
##    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_01}    cell_idx=${2}
##    Check bestbeam patternid used
##    Check PUSCH and CSIRS used DFT beam with mcshark    file_path=${biplog_01}
##    Check PUSCH and CSIRS used DFT beam with mcshark    file_path=${biplog_02}
##    [Teardown]    Run Keywords
##    ...    robot_common_operations.Common Case Teardown    AND
##    ...    Case TearDown
#
#[1]8247_W_06_Single_UE_Stationary_Performance_8x4_Good_Medium_Worse_15_Points_On_VS_OFF_AWGN_TAS_SRS
#    [Documentation]     This user scenario validates the Single UE average 5G DL Throughput Performance for 8247 on vs 2200 on
#    ...    TL362 -55--60, 25,55,70
#    [Tags]     master_classicalbts_all     CRT_TRUNK     SBTS00    CRT_UTE
#    [Setup]    robot_common_operations.Common Case Setup
#    Generate test case log path
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Common Case TestLine Setup     ModifySCF_Beforecommission=True
#    ...                            scf_dir_path=${SUITE_LOG_PATH}
#    ...                            scf_path=${Golden_SCF_Path}
#    ...                            golden_scf_name=SCF_${stream}.xml
#    ...                            ParamterToModify=${PARAMS_TO_MODIFY_W06_cloud}
#    ...                            Is_Swconfig=True
#    ...                            swconfig_target_path=${TS_CASE_LOG_PATH}/swconfig.txt
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    ...                            swconfig_file=${Golden_SCF_Path}/swconfig.txt
##    ...                            Lock_ENB_Need=True
##    ...                            enb_dist_name=${enb_dist_LNCEL1}
##    ...                            enb_parameter=${enb_cell_admin}
##    ...                            enb_value=barred
#    UE prepare with Power UE
#    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}    frequency=2600_1_ALL    end_input_port=${32}
#    ...    att_value1=${0}    att_value2=${0}    vertical_angle=${-6}    vertical_distance=${2.1}
#    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-15}
#    ${cpif_log_01}=    attach UE and capture wiresharklog for CLOUD UTE    wiresharklog=${8247_W06_wireshark_01}
#    ${biplog_01}=    Start Traffic And Capture Biplog for CLOUD UTE     dlexpect_tp=${Expect_dl_cloud}[4]    biplog_name=${8247_W06_bip_01}
#    ...                                                                 dl_throughput=${dl_throughput_cloud}
#    Start Performance from Good to Worse
#    stop traffic and MCS teardown        mcs_type=${mcs_type}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    BuiltIn.Set Test Variable    ${biplog_01}
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Case TearDown
#
#*** Keywords ***
###[1]5GC002056_BGAR_2200_B_004##
#Performance Test around
#    [Arguments]    ${ATT}=${att_value_cloud}[0]    ${dlexpect}=${Expect_dl_cloud}[3]    ${csv_path}=${TS_CASE_LOG_PATH}/${csv_file_B04}
#    ...    ${begin_θ_h}=-60    ${end_θ_h}=55
#    TOPYOUNG TEST with one ATT    att=${ATT}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}
#    ...    dlexpect=${dlexpect}    B1_port=${1}    B2_port=${2}    B3_port=${3}    B4_port=${4}    csv_path=${csv_path}
#
#TOPYOUNG TEST with one ATT
#    [Arguments]     ${att}    ${begin_θ_h}    ${end_θ_h}    ${dlexpect}
#    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path}
#    ${list}=    create list
#    set test variable    ${i}    ${1}
#    set test variable    ${list}
#    tput_output.create_new_file_csv    csv_file_path=${csv_path}
#    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
#    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
#    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
#    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
#    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
#    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
#    Set TOPYOUNG θ poll for horizontal and Check tput    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    dlexpect=${dlexpect}
#    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path}
#
#Set TOPYOUNG θ poll for horizontal and Check tput
#    [Arguments]          ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
#    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}    ${mcs_type}=${mcs_type}
#    ...    ${B1_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}    ${B4_port}=${None}
#    ...    ${csv_path}=${csv_path}    ${dlexpect}=${Expect_dl_enable}    ${vertical_angle}=${-6}
#    ...    ${begin_input_port}=${1}    ${end_input_port}=${16}    ${horizontal_distance}=${0.5}     ${vertical_distance}=${3.2}
#    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
#        mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
#        ...    begin_output_port=${B1_port}    end_output_port=${B2_port}
#        ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
#        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
#        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal}    mcs_alias=${mcs_alias}
#        ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+10
#        mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
#        ...    begin_output_port=${B3_port}    end_output_port=${B4_port}
#        ...    begin_input_port=${begin_input_port}     end_input_port=${end_input_port}
#        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
#        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal_x}    mcs_alias=${mcs_alias}
#        sleep    10s
#        ${tput}    Power UE check throughput with nrcellid     cellid=${nrcellid}     dlexpect=${dlexpect}    ue_type=${ue_type_0}
#        Append To List    ${list}    ${tput}
#        tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=${vertical_angle}    value2=${θ_horizontal}    value3=${tput}
#        log    ${list}
#        ${i}=    BuiltIn.Evaluate    ${i}+1
#    END
#
#Caculate average tput
#    [Arguments]    ${csv_path}
#    ${count}    BuiltIn.Get Length    ${list}
#    ${sum}     set variable    ${0}
#    FOR    ${j}    IN RANGE    ${count}
#      ${sum}=    BuiltIn.Evaluate    ${sum}+${list[${j}]}
#    END
#    ${ave}    BuiltIn.Evaluate    round(${sum}/${count},2)
#    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=ave_tput    value2=is    value3=${ave}
#    Log    average_tput is ${ave}
#    Set test variable    ${ave_tput}    ${ave}
#    [Return]    ${ave}
### -- [1]CNI74278_A_02_SA_max_DLUL_Tput_with_4CSI-RS_4x1_#2#2_3_3_BW_80M_1116##
#Analysis 2200 enable
#    [Arguments]    ${pcap_file}=${cpif_log_01}
#    ${nrofPorts}=    Get CSIRS_nrofPorts from CPIF    file_path=${pcap_file}
#    should contain x times    ${nrofPorts}    p8    4
#    ${cdm_Type}=     Get CSIRS_cdm_Type from CPIF     file_path=${pcap_file}
#    should contain    ${cdm_Type}    2
#    ${density}=      Get CSIRS_density from CPIF      file_path=${pcap_file}
#    should contain    ${density}     1
#    ${n1-n2}=        Get CSIRS_n1_n2 from CPIF        file_path=${pcap_file}
#    should contain    ${n1-n2}       1
#
#Check UE in the right CRI location on second bbmod
#    TOPYOUNG MCS change UE Phases    mcs_type=${mcs_type}
#    ...         first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-20}
#    ...         second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${-30}
#    ...         vertical_angle=${-6}
#    sleep    30s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_1    nr_phy_cell_ids=51    target_dir=${TS_CASE_LOG_PATH}
#    Analysis tti file for CRI for Admin    names=l2stream3_ttitrace_1    CRI=${0}
#    TOPYOUNG MCS change UE Phases    mcs_type=${mcs_type}
#    ...         first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${15}
#    ...         second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${25}
#    ...         vertical_angle=${-6}
#    sleep    30s
#    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_2    nr_phy_cell_ids=51
#    Analysis tti file for CRI for Admin    names=l2stream3_ttitrace_2    CRI=${1}
#
#Analysis tti file for CRI for Admin
#    [Arguments]    ${names}    ${CRI}=${CRI}
#    log to console    analysis tti file from Case_Logs file...
#    ${CRI_RATE}    count_required_value    csv_file=${TS_CASE_LOG_PATH}/${names}_dl.csv     filter_name=${filter_name}    count_value=${CRI}
#    should be true      ${CRI_RATE} > 0.5
#
###[1]CNI-70137_005##
#
#Analysis 70137_005 70851
#    ${nrofPorts_1}=    Get CSIRS_nrofPorts from CPIF    file_path=${cpif_log_01}
#    should contain x times    ${nrofPorts_1}    p8    4
#    ${cdm_Type_1}=    Get CSIRS_cdm_Type from CPIF    file_path=${cpif_log_01}
#    should contain    ${cdm_Type_1}    2
#    ${density_1}=    Get CSIRS_density from CPIF    file_path=${cpif_log_01}
#    should contain    ${density_1}    1
#    ${n1_n2_1}=    Get CSIRS_n1_n2 from CPIF    file_path=${cpif_log_01}
#    should contain    ${n1_n2_1}    1
#    ${longpucch_1}=    Get LongPucch_format from CPIF    file_path=${cpif_log_01}
#    ${longpucch_1_result}=    Evaluate     '1' in ${longpucch_1} and '3' in ${longpucch_1}
#    should be true    ${longpucch_1_result}
#    ${nrofPorts_2}=    Get CSIRS_nrofPorts from CPIF    file_path=${cpif_log_02}
#    should contain x times    ${nrofPorts_2}    p8    2
#    ${density_2}=    Get CSIRS_density from CPIF    file_path=${cpif_log_02}
#    should contain    ${density_2}    1
#    ${n1_n2_2}=    Get CSIRS_n1_n2 from CPIF    file_path=${cpif_log_02}
#    should contain    ${n1_n2_2}    1
#    ${longpucch_2}=    Get LongPucch_format from CPIF    file_path=${cpif_log_02}
#    ${longpucch_2_result}=    Evaluate     '1' in ${longpucch_2} and '3' in ${longpucch_2}
#    should be true    ${longpucch_2_result}
#    SSB_report should in DRX
#    CQI_report should in DRX
#    CSIRS_slot should in DRX
#
#
#SSB_report should in DRX
#    [Arguments]    ${70137_005}=${cpif_log_02}
#    ${drx_startoffset}=    Get DRX_StarOffset from CPIF    file_path=${70137_005}
#    ${drx_slotoffset}=    Get DRX_slotoffset from CPIF    file_path=${70137_005}
#    ${drx_onduration}=    Get DRX_onduration timer from CPIF    file_path=${70137_005}
#    ${bm_report}=     Get SSB_Reportslot from CPIF    file_path=${70137_005}
#    ${cqi_report}=     Get CQI_Reportslot from CPIF    file_path=${70137_005}
#    ${drx_onduration_startslot}    Evaluate    (${drx_startoffset}+${drx_slotoffset})*2
#    ${drx_onduration_endslot}    Evaluate    ${drx_onduration_startslot}+${drx_onduration}*2-1
#    ${DRX_period}=     Get DRX_LongCycle from CPIF    file_path=${70137_005}
#    ${DRX_LongCycle}=    String.Remove String    ${DRX_period}    ms
#    FOR    ${n}    IN RANGE    0    5
#       ${SSB_report}=    Evaluate    ${bm_report}+${DRX_LongCycle}*${n}
#       ${status_1}=    Run Keyword And Return Status    ${drx_onduration_startslot} <= ${SSB_report} <= ${drx_onduration_endslot}
#       Exit For Loop If    '${status_1}' == 'PASS'
#    END
#
#CQI_report should in DRX
#    [Arguments]    ${70137_005}=${cpif_log_02}
#    ${drx_startoffset}=    Get DRX_StarOffset from CPIF    file_path=${70137_005}
#    ${drx_slotoffset}=    Get DRX_slotoffset from CPIF    file_path=${70137_005}
#    ${drx_onduration}=    Get DRX_onduration timer from CPIF    file_path=${70137_005}
#    ${bm_report}=     Get SSB_Reportslot from CPIF    file_path=${70137_005}
#    ${cqi_report}=     Get CQI_Reportslot from CPIF    file_path=${70137_005}
#    ${drx_onduration_startslot}    Evaluate    (${drx_startoffset}+${drx_slotoffset})*2
#    ${drx_onduration_endslot}    Evaluate    ${drx_onduration_startslot}+${drx_onduration}*2-1
#    ${DRX_period}=     Get DRX_LongCycle from CPIF    file_path=${70137_005}
#    ${DRX_LongCycle}=    String.Remove String    ${DRX_period}    ms
#    FOR    ${n}    IN RANGE    0    5
#       ${SSB_report}=    Evaluate     ${bm_report}+${DRX_LongCycle}*${n}
#       ${status_2}=    Run Keyword And Return Status    ${drx_onduration_startslot} <= ${cqi_report} <= ${drx_onduration_endslot}
#       Exit For Loop If    '${status_2}' == 'PASS'
#    END
#
#CSIRS_slot should in DRX
#    [Arguments]    ${70137_005}=${cpif_log_02}
#    ${drx_startoffset}=    Get DRX_StarOffset from CPIF    file_path=${70137_005}
#    ${drx_slotoffset}=    Get DRX_slotoffset from CPIF    file_path=${70137_005}
#    ${drx_onduration}=    Get DRX_onduration timer from CPIF    file_path=${70137_005}
#    ${drx_onduration_startslot}    Evaluate    (${drx_startoffset}+${drx_slotoffset})*2
#    ${drx_onduration_endslot}    Evaluate    ${drx_onduration_startslot}+${drx_onduration}*2-1
#    ${csirs_slot}=    Get CSIRS_StartOffset from CPIF    file_path=${70137_005}
#    ${csirs_period_0}=    Get CSIRS_periodicity from CPIF    file_path=${70137_005}
#    ${csirs_period}=    String.Remove String    ${csirs_period_0}    slots
#    FOR    ${n}    IN RANGE    0    5
#       ${csirs_slot}=    Evaluate    ${csirs_slot}+${csirs_period}*${n}
#       ${status_3}=    Run Keyword And Return Status    ${drx_onduration_startslot} <= ${csirs_slot} <= ${drx_onduration_endslot}
#       Exit For Loop If    '${status_3}' == 'PASS'
#    END
#
#####[1]CB008247-5G-B#B3_001######
#Repeat increase decrease the PA for 5 times
#    [Arguments]    ${att_value_bad}    ${att_value_good}
#    FOR    ${in_de}    IN RANGE    ${1}
#       mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_bad}
#       ...    begin_output_port=${1}    end_output_port=${4}
#       sleep    15s
#       Check Dl traffic with nrcellid in Diff    cellid=${nrcellid}     dlexpect_tp=${Expect_dl_cloud}[5]
#       ${biplog_02}=     Capture biplog and download with WEBUI    target_dir=${TS_CASE_LOG_PATH}/    biplog_name=${B3001_bip_02}
#       BuiltIn.Set Test Variable    ${biplog_02}
#       mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_good}
#       ...    begin_output_port=${1}    end_output_port=${4}
#       sleep    15s
#       Check Dl traffic with nrcellid in Diff    cellid=${nrcellid}     dlexpect_tp=${Expect_dl_cloud}[1]
#       ${biplog_03}=     Capture biplog and download with WEBUI    target_dir=${TS_CASE_LOG_PATH}/    biplog_name=${B3001_bip_03}
#       DFTBeam Should Be Used In BIP with mcshark    file_path=${biplog_03}    filter=dldata_pdschsendreql1sw
#       ...                                                                     pdsch_xpath=DlData_PdschGrantL1sw
#       PMIBeam Should Be Used with mcshark     file_path=${biplog_02}    filter=dldata_pdschsendreql1sw
#       ...                                                                     pdsch_xpath=DlData_PdschGrantL1sw
#    END
#
#####[1]CB008247-A_Beam_Switch_DFT######
#Check bestbeam patternid used
#    [Arguments]
#    ${bipPatternIdList1}    Get PDSCH_patternId From BIP Log with mcshark    file_path=${biplog_01}
#    ${bipPatternIdList2}    Get PDSCH_patternId From BIP Log with mcshark    file_path=${biplog_02}
#    Should Not Be Equal    ${bipPatternIdList1}    ${bipPatternIdList2}
#    ...    msg="DFT beam is not changed from scenario1 to scenario2!"
#####[1]8247_W_06######
#Start Performance from Good to Worse
#    [Arguments]     ${csv_file_good}=${csv_file_good}    ${csv_file_midial}=${csv_file_midial}    ${csv_file_poor}=${csv_file_poor}
#    Log to console    start performance test
#    TOPYOUNG TEST with different ATTs    att_goodpoint=${0}    att_medialpoint=${15}
#    ...    att_poorpoint=${35}    begin_θ_h=${-60}    end_θ_h=${55}    B1_port=${1}    B2_port=${2}    B3_port=${3}    B4_port=${4}
#    ...    csv_path_good=${TS_CASE_LOG_PATH}/${csv_file_good}    csv_path_midial=${TS_CASE_LOG_PATH}/${csv_file_midial}
#    ...    csv_path_poor=${TS_CASE_LOG_PATH}/${csv_file_poor}
#    ...    good_target=${good_target}    midial_target=${midial_target}    poor_target=${poor_target}
#
#TOPYOUNG TEST with different ATTs
#    [Arguments]     ${att_goodpoint}    ${att_medialpoint}    ${att_poorpoint}    ${begin_θ_h}    ${end_θ_h}
#    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path_good}    ${csv_path_midial}    ${csv_path_poor}
#    ...    ${good_target}    ${midial_target}    ${poor_target}
#    Log to console     start good point
#    TopYoung TEST with one ATT avg tput    att=${att_goodpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    avg_tput_target=${good_target}
#    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path_good}
#    Log to console     start medial point
#    TopYoung TEST with one ATT avg tput    att=${att_medialpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    csv_path=${csv_path_midial}
#    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    avg_tput_target=${midial_target}
#    Log to console     start poor point
#    TopYoung TEST with one ATT avg tput    att=${att_poorpoint}    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    avg_tput_target=${poor_target}
#    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path_poor}
#
#TopYoung TEST with one ATT avg tput
#    [Arguments]     ${att}    ${begin_θ_h}    ${end_θ_h}    ${avg_tput_target}
#    ...    ${B1_port}    ${B2_port}    ${B3_port}    ${B4_port}    ${csv_path}
#    ${list}=    create list
#    set test variable    ${i}    ${1}
#    set test variable    ${list}
#    tput_output.create_new_file_csv    csv_file_path=${csv_path}
#    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
#    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
#    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
#    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att}
#    ...    begin_output_port=${B1_port}    end_output_port=${B4_port}
#    tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=att    value2=is    value3=${att}
#    Set TOPYOUNG θ poll for horizontal and Check tput old    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}
#    ...    B1_port=${B1_port}    B2_port=${B2_port}    B3_port=${B3_port}    B4_port=${B4_port}    csv_path=${csv_path}
#    ${avg_tput}=    Caculate average tput    csv_path=${csv_path}
#    ${avg_tput}=    Evaluate    int(${avg_tput})
#    ${avg_tput_target}=    Evaluate    int(${avg_tput_target})
#    Should Be True    ${avg_tput} > ${avg_tput_target}
#
#Set TOPYOUNG θ poll for horizontal and Check tput old
#    [Arguments]             ${mcs_index}=${0}    ${mcs_alias}=MCS_${mcs_index}
#    ...    ${begin_θ_h}=${None}    ${end_θ_h}=${None}
#    ...    ${B1_port}=${None}    ${B2_port}=${None}    ${B3_port}=${None}    ${B4_port}=${None}
#    ...    ${csv_path}=${csv_path}    ${dlexpect}=${Expect_dl_enable}    ${vertical_angle}=${-6}
#    ...    ${horizontal_distance}=${0.5}     ${vertical_distance}=${2.1}
#    ...    ${begin_input_port}=${1}    ${end_input_port}=${32}
#    FOR    ${θ_horizontal}    IN RANGE    ${${begin_θ_h}}    ${${end_θ_h}}    5
#        topyoung.Set Phases According To Angles For Input And Output Groups    mcs_index=${mcs_index}    mcs_alias=${mcs_alias}
#        ...    begin_output_port=${B1_port}    end_output_port=${B2_port}
#        ...    begin_input_port=${begin_input_port}     end_input_port=${end_input_port}
#        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
#        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal}
#        ${θ_horizontal_x}    BuiltIn.Evaluate    ${θ_horizontal}+10
#        topyoung.Set Phases According To Angles For Input And Output Groups    mcs_index=${mcs_index}    mcs_alias=${mcs_alias}
#        ...    begin_output_port=${B3_port}    end_output_port=${B4_port}
#        ...    begin_input_port=${begin_input_port}     end_input_port=${end_input_port}
#        ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
#        ...    vertical_angle=${vertical_angle}    horizontal_angle=${θ_horizontal_x}
#        sleep    5s
#        ${tput}    Power UE check throughput with nrcellid     cellid=${nrcellid}     dlexpect=${dlexpect}    ue_type=${ue_type_0}
#        Append To List    ${list}    ${tput}
#        tput_output.write_tput_into_csv    csv_file_path=${csv_path}    value1=${vertical_angle}    value2=${θ_horizontal}    value3=${tput}
#        log    ${list}
#        ${i}=    BuiltIn.Evaluate    ${i}+1
#    END
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
#    Run Keyword And Ignore Error     stop traffic and MCS teardown        mcs_type=${mcs_type}
#    Run Keyword And Ignore Error     Common Case Teardown for COAM    log_path=${TS_CASE_LOG_PATH}







