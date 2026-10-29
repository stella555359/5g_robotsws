*** Settings ***
Documentation    CA Feature CB007922 Automation cases common steps
...              Auther: Stella.lin@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/For_feature/Keywords_for_9915_10249.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Variables    TestCaseVariables.py


*** Keywords ***
CB007922_B_10_SA_Intra_frequency_Inter_gNB_mobility_support_for_UE_which_has_TDD_FR1_CA_configured
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${positive_scell_addition_method}=blind
    ${pa_base_interval}    Set Variable    25
    Activate PRB Blank For 9915_B10    update_powersaving_bwpDN_index_powersaving=${False}
    ${nr_phy_cell_ids}    Set Variable    333,411
    ${attach_ca_cell_info_dict}    Procedures.CA Basic Attach L3 Call Test    mode=SA
    ...                                                                       scell_addition_method=${positive_scell_addition_method}
    ...                                                                       gnb_index=${RUNNING_GNB_ID}
    ...                                                                       coam_connection=GNB_OAM
    ...                                                                       tput_collect_duration=150
    ...                                                                       target_DL_avg_percent=0.7
    ...                                                                       target_UL_avg_percent=0.6
    ...                                                                       min_DL_percent=0
    ...                                                                       min_UL_percent=0
    ...                                                                       min_scell_percent=0
    ...                                                                       dl_data_transfer=3000M
    ...                                                                       ul_data_transfer=150M
    ...                                                                       is_vonr_ip_exist=${True}
    ...                                                                       is_vonr_call_needed=${True}
    ...                                                                       auto_required_dl_tput_layers=${True}
    ...                                                                       is_capture_bip_during_traffic=${True}
    ...                                                                       nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                                       extra_expect_pecll_tp_percent=0.9
    ...                                                                       extra_expect_secll_tp_percent=0.7
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    ${handover_ca_cell_info_dict}    Procedures.CA Basic Handover Test    attach_ca_call_info_dict=${attach_ca_cell_info_dict}
    ...                                                                   handover_gnb_type=Inter
    ...                                                                   frequency_type=Intra
    ...                                                                   handover_round=0
    ...                                                                   tput_collect_duration=150
    ...                                                                   target_DL_avg_percent=0.5
    ...                                                                   target_UL_avg_percent=0.6
    ...                                                                   min_DL_percent=0
    ...                                                                   min_UL_percent=0
    ...                                                                   min_scell_percent=0
    ...                                                                   pa_interval=${pa_base_interval}
    ...                                                                   auto_required_dl_tput_layers=${True}
    ...                                                                   check_ul_pcell_tput_type=layer1
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Message_Flow_Check.Intra Frequency Handover Process
    ...                                    source_ho_cpif_log_path=${handover_ca_cell_info_dict['handover_cpif_log']}
    ...                                    target_ho_cpif_log_path=${handover_ca_cell_info_dict['inter_handover_target_cpif_log']}
#    ...                                    addition_cpif_log_path=${attach_ca_cell_info_dict['attach_cpif_log']}
    ...                                    mode=SA
    ${bip_log_for_9915}    Set Variable    ${attach_ca_cell_info_dict['bip_log_path']}
    IF    '${STREAM_VERSION}'=='master' or '${STREAM_VERSION}'=='26R1' or '${STREAM_VERSION}'=='26R2'
        Checkpoint For 9915_Trunk_B10    bip_log=${bip_log_for_9915[-1]}
        ...                              pcell_startprb=3    scell_startprb=9
        ...                              pcell_numofprb=267    scell_numofprb=115
    ELSE
        Checkpoint For 9915_Trunk_B10    bip_log=${bip_log_for_9915[-1]}
    END

CB007922_A_24_NSA_ Single_UE_Peak_Throughput_100M_60M_1116_0ms_beamset_3_1
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Run Keyword If    '${STREAM_VERSION}'=='master'    Wait Until Keyword Succeeds    2 min    5 sec
    ...    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    ${scf_path_nrdim}    Run Keyword If    '${STREAM_VERSION}'=='master'
    ...    coam_gnb_classical.COAM Download scf from cluster    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_OAM
    Run Keyword If    '${STREAM_VERSION}'=='master'    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    ${peak_dl_pcell}    ${peak_ul_pcell}    Run Keyword If    '${STREAM_VERSION}'=='master'
    ...    get_theoretical_throughput    scf_path=${scf_path_nrdim}    cell_id=301    ue_ul_layer=${1}
    ${peak_dl_scell_1}    ${peak_ul_scell_1}    Run Keyword If    '${STREAM_VERSION}'=='master'
    ...    get_theoretical_throughput    scf_path=${scf_path_nrdim}    cell_id=401
    ${info_dict}    Procedures.CA Attach L3 Call Test For Peak With QCOM    mode=NSA
    ...                                                                     gnb_index=${RUNNING_GNB_ID}
    ...                                                                     coam_connection=GNB_OAM
    ...                                                                     dl_data_transfer=2200M
    ...                                                                     ul_data_transfer=130M
    ...                                                                     ultarget_throughput=108
    ...                                                                     dltarget_throughput=1375
    ...                                                                     expect_dl_tput_scell_1=665
    ...                                                                     expect_dl_tput_scell_2=${None}
    ...                                                                     expect_addition_scell_indexs=${EXP_SCELL_ADDITION_INDEXS}
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog

CB007922_A_13_NSA_Inter_frequency_Intra_gNB_mobility_support_for_UE_which_has _TDD_FR1_CA_configured
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ${target_UL_avg_percent}    Set Variable    0.8
    Activate PRB Blank For 9915_A13    update_powersaving_bwpDN_index_powersaving=${False}
    ${nr_phy_cell_ids}    Set Variable    311,411
    ${attach_ca_cell_info_dict}    Procedures.CA Basic Attach L3 Call Test    mode=NSA
    ...                                                                       gnb_index=${RUNNING_GNB_ID}
    ...                                                                       coam_connection=GNB_OAM
    ...                                                                       tput_collect_duration=150
    ...                                                                       target_DL_avg_percent=0.5
    ...                                                                       target_UL_avg_percent=${target_UL_avg_percent}
    ...                                                                       dl_data_transfer=3000M
    ...                                                                       ul_data_transfer=150M
    ...                                                                       min_DL_percent=0
    ...                                                                       min_UL_percent=0
    ...                                                                       min_scell_percent=0
    ...                                                                       ue_index=${1}
    ...                                                                       check_ul_pcell_tput_type=layer1
    ...                                                                       auto_required_dl_tput_layers=${True}
    ...                                                                       expect_addition_scell_indexs=${EXP_SCELL_ADDITION_INDEXS}
    ...                                                                       is_capture_bip_during_traffic=${True}
    ...                                                                       nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                                       extra_expect_pecll_tp_percent=0.95
    ...                                                                       extra_expect_secll_tp_percent=0.7
    ...                                                                       data_transfer_duration=7200
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    ${a2_pa_base_interval}    Set Variable    27
    ${handover_addition_scell_indexs}    Create List    402
    Run Keyword If    '${stream_version}'!='master' or '${stream_version}'!='26R1' or '${stream_version}'!='26R2'
    ...    Initial PA Value Setting For Required RU    pa_off_value=10
    ${handover_ca_cell_info_dict}    Procedures.CA Basic Handover Test    attach_ca_call_info_dict=${attach_ca_cell_info_dict}
    ...                                                                   handover_gnb_type=Intra
    ...                                                                   frequency_type=Inter
    ...                                                                   handover_round=0
    ...                                                                   tput_collect_duration=150
    ...                                                                   target_DL_avg_percent=0.5
    ...                                                                   target_UL_avg_percent=${target_UL_avg_percent}
    ...                                                                   min_DL_percent=0
    ...                                                                   min_UL_percent=0
    ...                                                                   min_scell_percent=0
    ...                                                                   pa_interval=${a2_pa_base_interval}
    ...                                                                   step=2
    ...                                                                   range=8
    ...                                                                   mode=NSA
    ...                                                                   check_ul_pcell_tput_type=layer1
    ...                                                                   step=2
    ...                                                                   range=8
    ...                                                                   auto_required_dl_tput_layers=${True}
    ...                                                                   expect_addition_scell_indexs=${handover_addition_scell_indexs}
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    ${filter_expression}    Set Variable    ${NSA_RRC_RECONFIGURE_FILTER_HANDOVER_A13}
    Run Keyword And Continue On Failure    Message_Flow_Check.Inter Frequency Handover Process
    ...                                    source_ho_cpif_log_path=${handover_ca_cell_info_dict['handover_cpif_log']}
    ...                                    target_ho_cpif_log_path=${handover_ca_cell_info_dict['handover_cpif_log']}
    ...                                    addition_cpif_log_path=${attach_ca_cell_info_dict['attach_cpif_log']}
    ...                                    mode=NSA
    ...                                    rrc_reconfigure_message_filter_expression=${filter_expression}
    ...                                    A1_addition_message_filter_expression=${filter_expression}
    ${bip_log_for_9915}    Set Variable    ${attach_ca_cell_info_dict['bip_log_path']}
    IF    '${STREAM_VERSION}'=='master' or '${STREAM_VERSION}'=='26R1' or '${STREAM_VERSION}'=='26R2'
        Checkpoint For 9915_Trunk_A13    bip_log=${bip_log_for_9915[-1]}
        ...                              pcell_startprb=3    scell_startprb=9
        ...                              pcell_numofprb=267    scell_numofprb=115
    ELSE
        Checkpoint For 9915_Trunk_A13    bip_log=${bip_log_for_9915[-1]}
    END


CNI_71694_A_01_T_T_CA_aware_PSCell_selection_for_FR1_cells_during_EN_DC_setup
    Modify PA Value For ENB
    Update Param b1ThresholdNrRsrp Value In ENDCDMEASCONF    enb_index=${0}    b1ThresholdNrRsrp_value=-114
    Procedures.UE Prepare    ue_index=${1}    ue_type=${ue_type}
    ${attach_info}    Procedures.UE Attach    wireshark_log_prefix=ca_attach
    ...                                       ue_mode=NSA
    ...                                       ue_type=${ue_type}
    ...                                       coam_connection=GNB_OAM
    ...                                       ue_index=${1}
    ...                                       gnb_index=${RUNNING_GNB_ID}
    ...                                       enb_wireshark_log_prefix=enb_wireshark_log
    ...                                       enb_index=${0}
    ...                                       sleep_interval=45 sec
    ...                                       4G_check=${False}
    ${candidate_cell_pci_list}    Get Candidate Cell PCI List Reported By Enb    cpif_log_path=${attach_info['cpif_log_path']}
    Generate Pcell And Scell Mapping Info    pcell_index=${attach_info['attach_cell_index']}    source_gnb_id=${RUNNING_GNB_ID}
    Check Scell Addition Success    cpif_log_path=${attach_info['cpif_log_path']}
    ...                             mode=NSA
    ...                             addition_method=A1

Reboot UE And Verify Device
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot   connection=cpc_${ue_index}
    Sleep    10s
    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}
    ...                                                                   serial_number=${tl.ues[${ue_index}].serial_number}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}

#---7922 Setup And TearDown---#
7922_Common_Case_Teardown
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Initial PA Value Setting For All Attenuators
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${0}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${1}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog
    Run Keyword And Ignore Error    Do UE Detach    ue_index=${1}
    Run Keyword And Ignore Error    Turn On Airplane Mode    ue_index=${0}
    Run Keyword And Ignore Error    Turn On Airplane Mode    ue_index=${1}
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed

7922_Common_Suite_Setup
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    robot_common_operations.Common Suite Setup
    @{ue_num}    Set Variable    ${tl.ues}
    ${ue_length}    Get Length    ${ue_num}
    Set Suite Variable    ${ue_length}
    Common_setup_and_teardown.Suite Common SetUp    is_commission=${False}
    Initial PA Value Setting For All Attenuators

7922_Common_Case_Setup
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=0
    ...            ${specific_testcase_id}=${None}
    ...            ${specific_scf_file_path}=${None}
    ...            ${specific_scf_file_path_for_target_gnb}=${None}
    ...            ${handover_gnb_type}=${None}
    ...            ${is_all_pa_port_need_to_set}=${False}
    ...            ${specific_ru_pa_port_on}=${None}
    ...            ${mode}=SA
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
#    ${specific_ru_pa_port_on}    Run Keyword If    '${specific_ru_pa_port_on}'!='${None}'    convert to list    ${specific_ru_pa_port_on}
    CACaseSetup.Common Initialization    ue_index=${ue_index}
    ...                                  extract_case_info_from_data_file=${True}
    ...                                  handover_gnb_type=${handover_gnb_type}
    ...                                  is_all_pa_port_need_to_set=${is_all_pa_port_need_to_set}
    ...                                  specific_ru_pa_port_on=${specific_ru_pa_port_on}
    ...                                  specific_scf_file_path=${specific_scf_file_path}
    ...                                  specific_scf_file_path_for_target_gnb=${specific_scf_file_path_for_target_gnb}
    ...                                  specific_testcase_id=${specific_testcase_id}
    ...                                  TESTCASE_INFO_MAPPING_TABLE=${TESTCASE_INFO_MAPPING_TABLE_7922}
    Log to console    start to change lte cell to not Barred status for NSA Multi-rat
    ${is_multi_rat}    Check LTE Whether In Gnb    gnb_id=${RUNNING_GNB_ID}    gnb_connection=GNB_OAM${RUNNING_GNB_ID}
    ${case_params}    Set Variable    ${TESTCASE_INFO_MAPPING_TABLE_7922['${TESTCASE_ID}']['${TL_NAME}']}
    ${lte_cell_index}    Run Keyword If    ${is_multi_rat}    Set Variable    ${case_params.get('lte_cell_index')}
    ${lte_bts_id}    Run Keyword If    ${is_multi_rat}    Set Variable    ${case_params.get('lte_bts_id')}
    ${lte_cell_barred_param}    Catenate  {'dist_name': 'LNBTS-${lte_bts_id}/LNCEL-${lte_cell_index}/SIB-0',
    ...    'parameter': 'cellBarred','value': 'notBarred'}
    ${lte_cell_barred_param}    evaluate  [${lte_cell_barred_param}]
    Connect to gnb coam via ssl    connection=GNB_OAM${RUNNING_GNB_ID}
    Run Keyword If    '${mode}'=='NSA' and ${is_multi_rat}
    ...    COAM Update several parameters via rest api    parameters_to_update_via_api=${lte_cell_barred_param}
    ...    connection=GNB_OAM${RUNNING_GNB_ID}    timeout=180
    Run Keyword If   '${mode}'=='NSA' and '${TESTCASE_ID}'!='CNI_71694'     Update Priority Of NR Frequency Band In ENDCDMEASCONF
    ...    enb_index=${0}    b1_value=-100   cell_index=${case_params.get('pcell_index')}
    ${expect_scell_indexs}    Set Variable    ${case_params.get('scell_index')}
    Set Test Variable    ${EXP_SCELL_ADDITION_INDEXS}    ${expect_scell_indexs}
    [Teardown]    Teardown Multi gNb Connections

7922_Common_Case_Setup_A13
    7922_Common_Case_Setup    ue_index=1    mode=NSA    specific_ru_pa_port_on=${0}

7922_Common_Case_Setup_A24
    7922_Common_Case_Setup    ue_index=2    mode=NSA

2314_Common_Case_Setup
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=0
    ...            ${specific_testcase_id}=${None}
    ...            ${specific_scf_file_path}=${None}
    ...            ${specific_scf_file_path_for_target_gnb}=${None}
    ...            ${handover_gnb_type}=${None}
    ...            ${is_all_pa_port_need_to_set}=${False}
    ...            ${specific_ru_pa_port_on}=${None}
    ...            ${mode}=SA
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${specific_ru_pa_port_on}    Run Keyword If    '${specific_ru_pa_port_on}'!='${None}'    convert to list    ${specific_ru_pa_port_on}
    ${extract_case_info_from_data_file}    Set Variable If    '${stream_version}'=='23R1' or '${stream_version}'=='22R4'    ${False}    ${True}
    CACaseSetup.Common Initialization    ue_index=${ue_index}
    ...                                  extract_case_info_from_data_file=${True}
    ...                                  handover_gnb_type=${handover_gnb_type}
    ...                                  is_all_pa_port_need_to_set=${is_all_pa_port_need_to_set}
    ...                                  specific_ru_pa_port_on=${specific_ru_pa_port_on}
    ...                                  specific_scf_file_path=${specific_scf_file_path}
    ...                                  specific_scf_file_path_for_target_gnb=${specific_scf_file_path_for_target_gnb}
    ...                                  specific_testcase_id=${specific_testcase_id}
    ...                                  TESTCASE_INFO_MAPPING_TABLE=${TESTCASE_INFO_MAPPING_TABLE_7922}
    ...                                  extract_case_info_from_data_file=${extract_case_info_from_data_file}
    ...                                  specific_update_params_dict=${K02_23R1}
    Log to console    start to change lte cell to not Barred status for NSA Multi-rat
    ${is_multi_rat}    Check LTE Whether In Gnb    gnb_id=${RUNNING_GNB_ID}    gnb_connection=GNB_OAM${RUNNING_GNB_ID}
    ${lte_cell_index}    Run Keyword If    ${is_multi_rat}    Set Variable
    ...                 ${TESTCASE_INFO_MAPPING_TABLE_7922['${TESTCASE_ID}']['${TL_NAME}']['lte_cell_index']}
    ${lte_bts_id}    Run Keyword If    ${is_multi_rat}    Set Variable
    ...                 ${TESTCASE_INFO_MAPPING_TABLE_7922['${TESTCASE_ID}']['${TL_NAME}']['lte_bts_id']}
    ${lte_cell_barred_param}    Catenate  {'dist_name': 'LNBTS-${lte_bts_id}/LNCEL-${lte_cell_index}/SIB-0',
    ...    'parameter': 'cellBarred','value': 'notBarred'}
    ${lte_cell_barred_param}    evaluate  [${lte_cell_barred_param}]
    Connect to gnb coam via ssl    connection=GNB_OAM${RUNNING_GNB_ID}
    Run Keyword If    '${mode}'=='NSA' and ${is_multi_rat}
    ...    COAM Update several parameters via rest api    parameters_to_update_via_api=${lte_cell_barred_param}
    ...    connection=GNB_OAM${RUNNING_GNB_ID}    timeout=180
    Run Keyword If   '${mode}'=='NSA' and '${TESTCASE_ID}'!='CNI_71694'     Update Priority Of NR Frequency Band In ENDCDMEASCONF
    ...    enb_index=${0}    cell_index=${TESTCASE_INFO_MAPPING_TABLE_7922['${TESTCASE_ID}']['${TL_NAME}']['pcell_index']}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    [Teardown]    Teardown Multi gNb Connections


#---For EDA:02836560--- action: https://jiradc.ext.net.nokia.com/browse/MNRCA-60226 #
Verify Freq Band Indicator Message
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${log_path}    ${filter}=lte-rrc.RAT_Type == 0    ${alias}=parser
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    ${Band_list}    Get Field Value From Pdml    filter_expression=lte-rrc.FreqBandIndicator_r11
    ...                                          xpath=.//lte-rrc.FreqBandIndicator_r11
    ...                                          attribute_name=showname
    @{Band_list_valuses}    Create List
    FOR    ${item}    IN    @{Band_list}
        ${vlaue}    Set Variable    ${item.split(': ')[-1]}
        ${vlaue}    Convert To String    ${vlaue}
        Append To List    ${Band_list_valuses}    ${vlaue}
    END
    Sort List    ${Band_list_valuses}
    ${values}    Create List    28    41    66
    Lists Should Be Equal    ${Band_list_valuses}    ${values}
