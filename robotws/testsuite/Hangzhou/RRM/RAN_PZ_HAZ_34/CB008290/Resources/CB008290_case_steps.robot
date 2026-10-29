*** Settings ***
Documentation    CB008290 CA scell swap Automation cases common steps
...              Auther: li.su@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Variables    TestCaseVariables.py



*** Keywords ***
#---8290 Cases Steps---#
CB008290_A_14_A6_Measurement_Report_Handling_for_SCell_swap_of_T_T
    [Documentation]    Auther: li.su@nokia-sbell.com
    Procedures.Update CB008311 Related Parameter
    ${attach_ca_cell_info_dict}    Procedures.CA Basic Attach L3 Call Test    mode=SA
    ...                                                                       gnb_index=${RUNNING_GNB_ID}
    ...                                                                       coam_connection=GNB_OAM
    ...                                                                       tput_collect_duration=150
    ...                                                                       expect_addition_scell_indexs=${EXP_SCELL_ADDITION_INDEXS}
    ...                                                                       target_DL_avg_percent=0.7
    ...                                                                       target_UL_avg_percent=0.03
    ...                                                                       dl_data_transfer=2300M
    ...                                                                       ul_data_transfer=5M
    ...                                                                       min_DL_percent=0
    ...                                                                       min_UL_percent=0
    ...                                                                       min_scell_percent=0
    ...                                                                       is_vonr_ip_exist=${True}
    ...                                                                       auto_required_dl_tput_layers=${True}
    ...                                                                       is_scell_addition_needed=${False}
    ...                                                                       whether_8311_feature_enable=${True}
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    ${ca_scell_swap_wireshark}    ${after_swap_scell_index_list}    ${tput_dict}
    ...                 Procedures.CA A6 Specific Scell Swap Test    attach_ca_call_info_dict=${attach_ca_cell_info_dict}
    ...                                                              A6_swap_value=20
    ...                                                              swap_scell_index_number=${0}
    ...                                                              tput_collect_duration=90
    ...                                                              gnb_index=${RUNNING_GNB_ID}
    ...                                                              target_DL_avg_percent=0.7
    ...                                                              target_UL_avg_percent=0.03
    ...                                                              min_DL_percent=0
    ...                                                              min_UL_percent=0
    ...                                                              min_scell_percent=0
    ...                                                              auto_required_dl_tput_layers=${True}
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    ${addition_cpif_log_path}    Set Variable    ${attach_ca_cell_info_dict['cpif_scell_addition_log']}
    Message_Flow_Check.CA A6 Scell Swap Process    swap_cpif_log_path=${ca_scell_swap_wireshark}
    ...                                            addition_cpif_log_path=${addition_cpif_log_path}
    ...                                            source_scell_index=${EXP_SOURCE_SWAP_SCELL_INDEX[0]}
    ...                                            target_scell_index=${EXP_TARGET_SWAP_SCELL_INDEX[0]}
    ...                                            A6_MR_config_need_update=${True}
    Verify The Check Point For CNI97378    cpif_log_path=${ca_scell_swap_wireshark}


#---7949 Setup And TearDown---#
8290_Common_Case_Teardown
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

8290_Common_Suite_Setup
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    robot_common_operations.Common Suite Setup
    @{ue_num}    Set Variable    ${tl.ues}
    ${ue_length}    Get Length    ${ue_num}
    Set Suite Variable    ${ue_length}
    Common_setup_and_teardown.Suite Common SetUp    is_commission=${False}
    Initial PA Value Setting For All Attenuators

8290_Common_Case_Setup
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=0
    ...            ${specific_testcase_id}=${None}
    ...            ${specific_scf_file_path}=${None}
    ...            ${specific_scf_file_path_for_target_gnb}=${None}
    ...            ${handover_gnb_type}=${None}
    ...            ${is_all_pa_port_need_to_set}=${False}
    ...            ${specific_ru_pa_port_on}=${None}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
#    ${8290_scf}    Set Variable if    '${STREAM_VERSION}'=='master'    /home/ute/SCF/GNB0_BASIC_GOLDEN_SCF_master_8290.xml
#    ...                                                                ${specific_scf_file_path}
    CACaseSetup.Common Initialization    ue_index=${ue_index}
    ...                                  extract_case_info_from_data_file=${True}
    ...                                  handover_gnb_type=${handover_gnb_type}
    ...                                  is_all_pa_port_need_to_set=${is_all_pa_port_need_to_set}
    ...                                  specific_ru_pa_port_on=${specific_ru_pa_port_on}
    ...                                  specific_scf_file_path=${specific_scf_file_path}
    ...                                  specific_scf_file_path_for_target_gnb=${specific_scf_file_path_for_target_gnb}
    ...                                  specific_testcase_id=${specific_testcase_id}
    ...                                  TESTCASE_INFO_MAPPING_TABLE=${TESTCASE_INFO_MAPPING_TABLE_8290}
    ${expect_scell_indexs}    Set Variable   ${TESTCASE_INFO_MAPPING_TABLE_8290['${TESTCASE_ID}']['${TL_NAME}']['scell_index']}
    ${source_swap_scell_index}    Set Variable
    ...    ${TESTCASE_INFO_MAPPING_TABLE_8290['${TESTCASE_ID}']['${TL_NAME}']['swap_scell_index']['source_scell']}
    ${target_swap_scell_index}    Set Variable
    ...    ${TESTCASE_INFO_MAPPING_TABLE_8290['${TESTCASE_ID}']['${TL_NAME}']['swap_scell_index']['target_scell']}
    Set Test Variable    ${EXP_SCELL_ADDITION_INDEXS}    ${expect_scell_indexs}
    Set Test Variable    ${EXP_SOURCE_SWAP_SCELL_INDEX}    ${source_swap_scell_index}
    Set Test Variable    ${EXP_TARGET_SWAP_SCELL_INDEX}    ${target_swap_scell_index}
    [Teardown]    Teardown Multi gNb Connections

Procedures.Online Activate And Deactivate A6 Trigger actSCellSwapFr1
    [Documentation]   Auther:li.su@nokia-sbell.com
    [Arguments]    ${gnb_id}=0
    ...            ${actSCellSwapFr1}=disabled
    Log To Console    \n***start to activate/deactivates SCell swap functionality for NR FR1 CA***
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    ${update_actSCellSwapFr1}    Catenate   {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter':'actSCellSwapFr1',
    ...    'value':'${actSCellSwapFr1}'}
    ${update_actSCellSwapFr1}     Evaluate    [${update_actSCellSwapFr1}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_actSCellSwapFr1}    gnb_index=${gnb_id}

Verify The Check Point For CNI97378
    [Arguments]    ${cpif_log_path}    ${alias}=parser
    ${message_filter_expression}    Set Variable    nr-rrc.eventId==5 && nr-rrc.useAllowedCellList
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter_expression}    alias=${alias}
    ${useallowedcelllist}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.eventA6_element/nr-rrc.useAllowedCellList
    ...                                                       pcap_parser=${alias}
    ...                                                       attribute_name=showname
    ${pci_range}    pcap.get_field_value_by_xpath    xpath=.//nr-rrc.pci_Range_element/nr-rrc.start    pcap_parser=${alias}
    ${vlaue}    Set Variable    ${useallowedcelllist[0].split(': ')[-1]}
    Should Be Equal    ${vlaue}    True    msg=The vlaue of useAllowedCellList is not true.
    ${scell_pci}    Set Variable    ${scell_mapping[${EXP_SCELL_ADDITION_INDEXS}[0]]['all_cell_info']['physicalCellId']}
    ${scell_pci}    Convert To String    ${scell_pci}
    Should Be Equal    ${pci_range}[0]    ${scell_pci}    msg=The PCI is not macthed

Procedures.Online Modify A6 MR Configuration a6OffsetSCellSwapSsbRsrp
    [Documentation]   Auther:li.su@nokia-sbell.com
    [Arguments]    ${scell_index}
    ...            ${gnb_id}=0
    ...            ${a6OffsetSCellSwapSsbRsrp_value}=30
    Log To Console    \n***start to update A6 MR Configuration***
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    ${update_a6OffsetSCellSwapSsbRsrp}    Catenate   {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${scell_index}', 'parameter':'a6MeasSCellSwapSsbRsrp',
    ...    'value':[{'a6OffsetSCellSwapSsbRsrp':'${a6OffsetSCellSwapSsbRsrp_value}'}]}
    ${update_a6OffsetSCellSwapSsbRsrp}     Evaluate    [${update_a6OffsetSCellSwapSsbRsrp}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_a6OffsetSCellSwapSsbRsrp}    gnb_index=${gnb_id}
