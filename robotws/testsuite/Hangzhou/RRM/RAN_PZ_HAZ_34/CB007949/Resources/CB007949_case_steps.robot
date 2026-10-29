*** Settings ***
Documentation    CA Feature CB007949 Automation cases common steps
...              Auther: Stella.lin@nokia-sbell.com

Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Variables    TestCaseVariables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/For_feature/Keywords_for_9915_10249.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}


*** Keywords ***
CB007949_B_B2_01_intra_gNB_Handover_To_Pcell
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ${a2_pa_base_interval}    Set Variable    25
    Activate PRB Blank For 9915_B_B2
    ${extra_expect_pcell_tp_percent}    Set Variable    0.75
    ${extra_expect_secll_tp_percent}    Set Variable    1
    ${nr_phy_cell_ids}    Set Variable    422
    ${attach_ca_cell_info_dict}    Procedures.CA Basic Attach L3 Call Test    mode=SA
    ...                                                                       scell_addition_method=A1
    ...                                                                       gnb_index=${RUNNING_GNB_ID}
    ...                                                                       coam_connection=GNB_OAM
    ...                                                                       tput_collect_duration=150
    ...                                                                       target_DL_avg_percent=0.7
    ...                                                                       target_UL_avg_percent=0.6
    ...                                                                       dl_data_transfer=3000M
    ...                                                                       ul_data_transfer=150M
    ...                                                                       is_vonr_ip_exist=${True}
    ...                                                                       min_DL_percent=0
    ...                                                                       min_UL_percent=0
    ...                                                                       min_scell_percent=0
    ...                                                                       expect_addition_scell_indexs=${EXP_SCELL_ADDITION_INDEXS}
    ...                                                                       auto_required_dl_tput_layers=${True}
    ...                                                                       is_capture_bip_during_traffic=${False}
    ...                                                                       nr_phy_cell_ids=${nr_phy_cell_ids}
    ...    extra_expect_pecll_tp_percent=${extra_expect_pcell_tp_percent}
    ...    extra_expect_secll_tp_percent=${extra_expect_secll_tp_percent}
    ${handover_addition_scell_indexs}    Create List    301    501
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    ${handover_ca_cell_info_dict}    Procedures.CA Basic Handover Test    attach_ca_call_info_dict=${attach_ca_cell_info_dict}
    ...                                                                   handover_gnb_type=Intra
    ...                                                                   frequency_type=Inter
    ...                                                                   handover_round=0
    ...                                                                   tput_collect_duration=150
    ...                                                                   target_DL_avg_percent=0.7
    ...                                                                   target_UL_avg_percent=0.6
    ...                                                                   min_DL_percent=0
    ...                                                                   min_UL_percent=0
    ...                                                                   min_scell_percent=0
    ...                                                                   pa_interval=${a2_pa_base_interval}
    ...                                                                   step=2
    ...                                                                   range=8
    ...                                                                   expect_addition_scell_indexs=${handover_addition_scell_indexs}
    ...                                                                   auto_required_dl_tput_layers=${True}
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Message_Flow_Check.Inter Frequency Handover Process
    ...                                    source_ho_cpif_log_path=${handover_ca_cell_info_dict['handover_cpif_log']}
    ...                                    target_ho_cpif_log_path=${handover_ca_cell_info_dict['handover_cpif_log']}
    ...                                    addition_cpif_log_path=${attach_ca_cell_info_dict['attach_cpif_log']}
    ...                                    mode=SA
    ...                                    A1_Addition_MR_triggered=${False}
    ${prefix_name}    Set Variable    BTS${MRBTS_ID}
    Check_Point_For_10249_Via_Snapshot    ru_index=${2}    check_point_value=NR34    prefix_name=${prefix_name}

CB007949_B_B3_01_A1_Scell_Addition_A2_Scell_Release_TDD_FDD_different_a1ThresholdSCellAddSsb
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    Do ADB Reboot
    ${attach_ca_cell_info_dict}    Procedures.CA Basic Attach L3 Call Test    mode=SA
    ...                                                                       gnb_index=${RUNNING_GNB_ID}
    ...                                                                       coam_connection=GNB_OAM
    ...                                                                       scell_addition_method=A1
    ...                                                                       tput_collect_duration=150
    ...                                                                       target_DL_avg_percent=0.7
    ...                                                                       target_UL_avg_percent=0.03
    ...                                                                       dl_data_transfer=3000M
    ...                                                                       ul_data_transfer=5M
    ...                                                                       is_vonr_ip_exist=${True}
    ...                                                                       expect_addition_scell_indexs=${EXP_SCELL_ADDITION_INDEXS}
    ...                                                                       is_vonr_call_needed=${True}
    ...                                                                       auto_required_dl_tput_layers=${True}
    ...                                                                       min_DL_percent=0
    ...                                                                       min_UL_percent=0
    ...                                                                       min_scell_percent=0
    ${scell_one_index}    Create List    502
    ${scell_one_A2_release_value}    Set Variable    58
    Modify PA Value For Required RU With Interval    ru_index=${attach_ca_cell_info_dict['pcell_ru_index']}
    ...                                              gnb_id=${RUNNING_GNB_ID}
    ...                                              interval=20
    ${scell_one_release_wireshark}    Procedures.Trigger A2 Release    scell_index=${scell_one_index[0]}
    ...                                                                gnb_id=${RUNNING_GNB_ID}
    ...                                                                A2_release_value=${scell_one_A2_release_value}
    Procedures.Check Tput    check_pcell_tput=${False}    addition_scell_index_list=${scell_one_index}    check_scell_tput_type=no_data
    ${scell_two_index}    Create List    402
    ${scell_two_A2_release_value}    Set Variable    68
    ${scell_two_release_wireshark}    Procedures.Trigger A2 Release    scell_index=${scell_two_index[0]}
    ...                                                                gnb_id=${RUNNING_GNB_ID}
    ...                                                                A2_release_value=${scell_two_A2_release_value}
    Procedures.Check Tput    gnb_index=${RUNNING_GNB_ID}    check_pcell_tput=${False}
    ...                      addition_scell_index_list=${scell_two_index}    check_scell_tput_type=no_data
    Initial PA Value Setting For Required RU    modify_ru_id=${attach_ca_cell_info_dict['scell_ru_index_list']}
    ...                                         gnb_id=${RUNNING_GNB_ID}
    Initial PA Value Setting For Required RU    modify_ru_id=${attach_ca_cell_info_dict['pcell_ru_index']}
    ...                                         gnb_id=${RUNNING_GNB_ID}
#    Procedures.Check Tput    gnb_index=${RUNNING_GNB_ID}    addition_scell_index_list=${EXP_SCELL_ADDITION_INDEXS}
#    ...                      auto_required_dl_tput_layers=${True}
#    ...                      target_DL_avg_percent=0.8    target_UL_avg_percent=0.03    min_DL_percent=0    min_UL_percent=0
#    ...                      min_scell_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Message_Flow_Check.A2 Release Process    release_cpif_log_path=${scell_one_release_wireshark}
    ...                                      addition_cpif_log_path=${attach_ca_cell_info_dict['attach_cpif_log']}
    ...                                      scell_index=${scell_one_index[0]}
    Message_Flow_Check.A2 Release Process    release_cpif_log_path=${scell_two_release_wireshark}
    ...                                      addition_cpif_log_path=${attach_ca_cell_info_dict['attach_cpif_log']}
    ...                                      scell_index=${scell_two_index[0]}


CB007949_B_B4_01_Scell_Change_From_T_3F_To_3T
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    Procedures.Update CB008311 Related Parameter
    Activate PRB Blank For 9915_B_B4    update_powersaving_bwpDN_index_powersaving=${False}
    ${attach_ca_cell_info_dict}    Procedures.CA Basic Attach L3 Call Test    mode=SA
    ...                                                                       gnb_index=${RUNNING_GNB_ID}
    ...                                                                       coam_connection=GNB_OAM
    ...                                                                       tput_collect_duration=150
    ...                                                                       target_DL_avg_percent=0.7
    ...                                                                       target_UL_avg_percent=0.2
    ...                                                                       dl_data_transfer=3000M
    ...                                                                       ul_data_transfer=5M
    ...                                                                       is_vonr_ip_exist=${True}
    ...                                                                       is_scell_addition_needed=${False}
    ...                                                                       is_vonr_call_needed=${False}
    ...                                                                       check_scell_tput=${False}
    ...                                                                       check_pcell_tput_type=not_peak
    ...                                                                       check_ul_pcell_tput_type=not_peak
    ...                                                                       min_DL_percent=0
    ...                                                                       min_UL_percent=0
    ...                                                                       min_scell_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    ${pre_scell_addition_index_list}    Create List    21
    ${changed_scell_addition_index_list}    Create List    402    502
    ${scell_change_wireshark_dict}    Procedures.Scell Change Test    attach_cpif_log=${attach_ca_cell_info_dict['attach_cpif_log']}
    ...                                                               pre_scell_addition_pa_value=30
    ...                                                               changed_scell_addition_pa_value=20
    ...                                                               pre_scell_addition_index_list=${pre_scell_addition_index_list}
    ...                                                               changed_scell_addition_index_list=${changed_scell_addition_index_list}
    ...                                                               gnb_id=${RUNNING_GNB_ID}
    ...                                                               nr_phy_cell_ids=422
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Check_Point_For_10249_Via_Snapshot    ru_index=${2}    check_point_value=NR49_5    prefix_name=BTS${MRBTS_ID}

CB007949_D_Extend_02_TDD_3CC_CA_Interworking_with_VoNR
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    Run Keyword If    '${STREAM_VERSION}'=='master'    Wait Until Keyword Succeeds    2 min    5 sec
    ...    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    ${scf_path_nrdim}    Run Keyword If    '${STREAM_VERSION}'=='master'
    ...    coam_gnb_classical.COAM Download scf from cluster    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_OAM
    Run Keyword If    '${STREAM_VERSION}'=='master'    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    ${peak_dl_pcell}    ${peak_ul_pcell}    Run Keyword If    '${STREAM_VERSION}'=='master'
    ...    get_theoretical_throughput    scf_path=${scf_path_nrdim}    cell_id=301
    ${peak_dl_scell_1}    ${peak_ul_scell_1}    Run Keyword If    '${STREAM_VERSION}'=='master'
    ...    get_theoretical_throughput    scf_path=${scf_path_nrdim}    cell_id=401
    ${peak_dl_scell_2}    ${peak_ul_scell_2}    Run Keyword If    '${STREAM_VERSION}'=='master'
    ...    get_theoretical_throughput    scf_path=${scf_path_nrdim}    cell_id=501

    ${attach_ca_cell_info_dict}    Run Keyword If    '${STREAM_VERSION}'=='master'
    ...            Procedures.CA Attach L3 Call Test For Peak With QCOM    mode=SA
    ...                                                                    gnb_index=${RUNNING_GNB_ID}
    ...                                                                    coam_connection=GNB_OAM
    ...                                                                    dl_data_transfer=2500M
    ...                                                                    ul_data_transfer=230M
    ...                                                                    ultarget_throughput=215
    ...                                                                    dltarget_throughput=1375
    ...                                                                    expect_dl_tput_scell_1=665
    ...                                                                    expect_dl_tput_scell_2=250
    ...                                                                    expect_addition_scell_indexs=${EXP_SCELL_ADDITION_INDEXS}
    ...    ELSE    Procedures.CA Basic Attach L3 Call Test    mode=SA
    ...                                                       gnb_index=${RUNNING_GNB_ID}
    ...                                                       coam_connection=GNB_OAM
    ...                                                       scell_addition_method=A1
    ...                                                       tput_collect_duration=150
    ...                                                       target_DL_avg_percent=0.7
    ...                                                       target_UL_avg_percent=0.6
    ...                                                       dl_data_transfer=3000M
    ...                                                       ul_data_transfer=150M
    ...                                                       is_vonr_ip_exist=${True}
    ...                                                       expect_addition_scell_indexs=${EXP_SCELL_ADDITION_INDEXS}
    ...                                                       is_vonr_call_needed=${False}
    ...                                                       auto_required_dl_tput_layers=${True}
    ...                                                       min_DL_percent=0
    ...                                                       min_UL_percent=0
    ...                                                       min_scell_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog

CB009915-B#IWK20_PRB_blanking_interworking_with_multiple_dedicated_BWPs_inter_gNB_CA
    Create Case Log Path
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933    62003
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation    gnb_index=${0}
    Set Test Variable    ${summary_alarm_info}
    ${summary_alarm_info_scell}    Get Active Alarms And Save Summary Infomation    gnb_index=${1}
    Set Test Variable    ${summary_alarm_info_scell}
    Connect To Multi gNb Coam
    Initial PA Value Setting For All Gnb
    Initial PA Value Setting For Required RU    modify_ru_id=${0}    gnb_id=${0}
    Initial PA Value Setting For Required RU    modify_ru_id=${0}    gnb_id=${1}
    ${pcell_gnb_id}    Set Variable    0
    ${scell_gnb_id}    Set Variable    1
    Run Keyword And Continue On Failure    Perform Commission    scf_file_path=/home/ute/SCF/GNB0_BASIC_GOLDEN_SCF_9915_${STREAM_VERSION}.xml
    ...                   gnb_index=${0}
    ...                   timeout_for_commission=900
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${True}
    Run Keyword And Continue On Failure    Perform Commission    scf_file_path=/home/ute/SCF/GNB1_BASIC_GOLDEN_SCF_9915_${STREAM_VERSION}.xml
    ...                   gnb_index=${1}
    ...                   timeout_for_commission=900
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${True}
    Procedures.UE Prepare    ue_index=${0}    ue_type=mtk
    ${attach_info}    Procedures.UE Attach    wireshark_log_prefix=ca_attach_gnb${pcell_gnb_id}
    ...                                       ue_mode=SA
    ...                                       ue_type=mtk
    ...                                       sleep_interval=45 sec
    ...                                       4G_check=${False}
    ...                                       gnb_index=${pcell_gnb_id}
    ...                                       coam_connection=GNB_OAM${pcell_gnb_id}
    Start L3 Call Data Transfer    ul_data_transfer=150M
    ...                            dl_data_transfer=3000M
    ...                            duration=3600
    ...                            need_get_ue_ip=${True}
    ...                            cpif_log_path=${attach_info['cpif_log_path']}
    ...                            ue_iperf_path=/data/local/tmp/iperf
    ...                            mode=SA
    ...                            ue_index=${0}
    Sleep    60sec
    ${pcell_phy_id}    Set Variable    311
    ${scell_phy_id}    Set Variable    201
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector
    ...    nr_phy_cell_ids=${pcell_phy_id}    gnb_index=${pcell_gnb_id}    target_file_name=pcell_l2l1_bip
    Sleep    6sec
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector
   ...    nr_phy_cell_ids=${scell_phy_id}     gnb_index=${scell_gnb_id}    target_file_name=scell_l2l1_bip
    ${pcell_bip_log_path}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...    target_file_name=pcell_l2l1_bip
    ${scell_bip_log_path}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...    target_file_name=scell_l2l1_bip
    Run Keyword And Continue On Failure    9915 Check A1 Addition Success    cpif_log_path=${attach_info['cpif_log_path']}
    ...    pcell_pci=${pcell_phy_id}    scell_pci=${scell_phy_id}
    Run Keyword And Continue On Failure    Check dl number of layers from bip    file_path=${pcell_bip_log_path[0]}
    ...                                                                          pci=${pcell_phy_id}
    ...                                                                          dldata_pdschsendreq=dldata_pdschsendreql1sw
    ...                                                                          DlData_PdschGrant=DlData_PdschGrantL1sw
    Run Keyword And Continue On Failure    Check dl number of layers from bip    file_path=${scell_bip_log_path[0]}
    ...                                                                          pci=${scell_phy_id}
    ...                                                                          dldata_pdschsendreq=dldata_pdschsendreql1sw
    ...                                                                          DlData_PdschGrant=DlData_PdschGrantL1sw
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    csn.reset_cache
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                         duration=120
    ...                                                         expect_ul_tput=160
    ...                                                         expect_dl_tput=1125
    ...                                                         cellid=43462957
    ...                                                         target_avg_percent=0.65
    ...                                                         ue_type=huawei_sigspark
    ...                                                         check_source=aasyslog
    ...                                                         min_percent=0
    ...                                                         gnb_index=${pcell_gnb_id}
    ...                                                         connection=GNB_OAM${pcell_gnb_id}
    ...                                                         whether_get_nrcellid=${False}
    @{scell_direction_component_list}    Create List    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{scell_direction_component_list}
    ...                                                         duration=120
    ...                                                         expect_ul_tput=204
    ...                                                         expect_dl_tput=525
    ...                                                         cellid=169761
    ...                                                         target_avg_percent=0.80
    ...                                                         ue_type=huawei_sigspark
    ...                                                         check_source=aasyslog
    ...                                                         min_percent=0
    ...                                                         gnb_index=${scell_gnb_id}
    ...                                                         connection=GNB_OAM${scell_gnb_id}
    ...                                                         whether_get_nrcellid=${False}

#---7949 Setup And TearDown---#
7949_Common_Case_Teardown
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Initial PA Value Setting For All Attenuators
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${0}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
    Run Keyword If    ${ue_length}==2 or ${ue_length}==3    Run Keyword And Ignore Error
    ...    Close the iperf process on android ue    ue_index=${1}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog
    Run Keyword If    ${ue_length}==2 or ${ue_length}==3    Run Keyword And Ignore Error    Do UE Detach    ue_index=${1}
    Run Keyword And Ignore Error    Turn On Airplane Mode    ue_index=${0}
    Run Keyword If    ${ue_length}==2 or ${ue_length}==3    Run Keyword And Ignore Error    Turn On Airplane Mode    ue_index=${1}
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}

7949_D_Case_Teardown
    [Documentation]    Auther: jun.8.chen@nokia-sbell.com
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Initial PA Value Setting For All Attenuators
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${2}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}

7949_Common_Suite_Setup
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    robot_common_operations.Common Suite Setup
    @{ue_num}    Set Variable    ${tl.ues}
    ${ue_length}    Get Length    ${ue_num}
    Set Suite Variable    ${ue_length}
    Common_setup_and_teardown.Suite Common SetUp    is_commission=${False}
    Initial PA Value Setting For All Attenuators

7949_Common_Case_Setup
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=0
    ...            ${specific_testcase_id}=${None}
    ...            ${specific_scf_file_path}=${None}
    ...            ${specific_scf_file_path_for_target_gnb}=${None}
    ...            ${handover_gnb_type}=${None}
    ...            ${is_all_pa_port_need_to_set}=${False}
    ...            ${specific_ru_pa_port_on}=${None}
    ...            ${initial_pcell_pa_value}=${None}
    ...            ${initial_scell_pa_value}=${None}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    CACaseSetup.Common Initialization    ue_index=${ue_index}
    ...                                  extract_case_info_from_data_file=${True}
    ...                                  handover_gnb_type=${handover_gnb_type}
    ...                                  is_all_pa_port_need_to_set=${is_all_pa_port_need_to_set}
    ...                                  specific_ru_pa_port_on=${specific_ru_pa_port_on}
    ...                                  specific_scf_file_path=${specific_scf_file_path}
    ...                                  specific_scf_file_path_for_target_gnb=${specific_scf_file_path_for_target_gnb}
    ...                                  specific_testcase_id=${specific_testcase_id}
    ...                                  extract_index=1:4
    ...                                  initial_pcell_pa_value=${initial_pcell_pa_value}
    ...                                  initial_scell_pa_value=${initial_scell_pa_value}
    ...                                  TESTCASE_INFO_MAPPING_TABLE=${TESTCASE_INFO_MAPPING_TABLE_7949}
    ${expect_scell_indexs}    Set Variable   ${TESTCASE_INFO_MAPPING_TABLE_7949['${TESTCASE_ID}']['${TL_NAME}']['scell_index']}
    Set Test Variable    ${EXP_SCELL_ADDITION_INDEXS}    ${expect_scell_indexs}
    [Teardown]    Teardown Multi gNb Connections

7949_Common_Case_Setup_B_B3_01
    7949_Common_Case_Setup    specific_ru_pa_port_on=${1}

7949_Common_Case_Setup_B_B2_01
    7949_Common_Case_Setup    specific_ru_pa_port_on=${1}

7949_Common_Case_Setup_D
    ${ue_id}    Set Variable if    '${STREAM_VERSION}'=='master'    ${2}    ${0}
    7949_Common_Case_Setup    ue_index=${ue_id}

8941_Common_Case_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}

7949_Common_Case_Setup_B_B4_01
    ${initial_pcell_pa_value}    Set Variable    40
    ${initial_scell_pa_value}    Set Variable    40
    7949_Common_Case_Setup    initial_pcell_pa_value=${initial_pcell_pa_value}    initial_scell_pa_value=${initial_scell_pa_value}

9915_Common_Case_Teardown
    Run Keyword And Continue On Failure    7949_Common_Case_Teardown
    Run Keyword And Continue On Failure    Check Whether New Alarm Happened During Running Case
    ...    alarm_info_before=${summary_alarm_info_scell}    gnb_index=${1}
    Run Keyword And Continue On Failure    Capture Snapshot For Target Gnb
    Run Keyword And Ignore Error    Perform Commission    scf_file_path=/home/ute/SCF/GNB0_BASIC_GOLDEN_SCF_${STREAM_VERSION}.xml
    ...                   gnb_index=${0}
    ...                   timeout_for_commission=450
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${True}
    csn.reset_cache
    Run Keyword And Ignore Error    Perform Commission    scf_file_path=/home/ute/SCF/GNB1_BASIC_GOLDEN_SCF_${STREAM_VERSION}.xml
    ...                   gnb_index=${1}
    ...                   timeout_for_commission=450
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${True}

