*** Settings ***
Documentation
...   author: Rafal Kawa
...   contact: rafal.kawa@nokia.com
...   description: CRT test suite of features CB008127-CD and CB008127-G

Library     taf.rfrl.bts.devices.du.cell_operations.EnbCellOperations    WITH NAME      enbcell
Library     ../resources/EnbOperations.py    WITH NAME    enb
Library     ../resources/GnbPower.py   WITH NAME    gnb_power
Library     ./resources/GnbOperations.py    WITH NAME    gnb
Library     ./resources/CustomObservers.py    WITH NAME    observer
Library     ./resources/CustomKeywords.py    WITH NAME    keywords
Library     ./resources/PcapAnalyzer.py    WITH NAME    pcap_analyzer
Library     ./resources/MeasCountersChecker.py    WITH NAME    meas_counters
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ./resources/common_scenarios.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup     Run Keywords
...             enb.power_on_enb
...             AND  gnb_power.power_on_gnb  bts_id=${1}
...             AND  Perform Full Commissioning On Classical Enb
...             AND  enbcell.wait_for_all_cells_to_be_onair    timeout=${600}
...             AND  enb.set_nr_dc_carrier_frequency  frequency=2071387
...             AND  Perform Full Commissioning on Classical gNB  bts_id=${1}  # Slave gNB commissioning
...             AND  gnb_cells.wait_for_all_cells_to_be_onair  bts_id=${1}  timeout=${600}
...             AND  gnbbbu.upload_swconfig  sw_config_path=${CURDIR}/resources/swconfig.txt
...             AND  Common Suite Setup With Commissioning  # Master gNB commissioning
...             AND  gnb_cells.wait_for_all_cells_to_be_onair  bts_id=${0}  timeout=${600}
...             AND  meas_counters.enable_measurement_profile_counters_nsa  bts_id=${0}
Suite Teardown  Common Suite Teardown
Test Setup      Run Keywords
...             Common Preconditions With Watching Alarms
...             AND  gnb_cells.verify_all_cells_are_onair  bts_id=${0}
...             AND  gnb_cells.verify_all_cells_are_onair  bts_id=${1}
...             AND  keywords.reboot_mediatek_ue
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
${SOURCE_CELL_ID}=            1
${TARGET_CELL_ID}=            9
${SOURCE_CELL_NRHOIF_ID}=     1
${SPID_UE}=                   256
${SPID_MIN}=                  240
${PRIMARY_MEASPR_MA_ID}=      11
${SECONDARY_MEASPR_MA_ID}=    31
${DEFAULT_NRPLMN}=            NRPLMN-1

*** Test Cases ***
USCB008127-CD#B5_Activate_Inter-Freq_A3_A5_A1_meas_using_selected_meas_profile_upon_receipt_of_A2_Meas_Report_for_NSA
    Activate_Inter-Freq_A3_A5_A1_meas_using_selected_meas_profile_upon_receipt_of_A2_Meas_Report_for_NSA
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}  source_cell_id=${SOURCE_CELL_ID}
    ...  nrhoif_id=${SOURCE_CELL_NRHOIF_ID}  target_cell_id=${TARGET_CELL_ID}

USCB008127-CD#B4_Successful_Configuration_of_A2_measurement_using_measurement_profile_upon_receiving_A1_meas_report
    ${STEP_1_PCAP}  Set Variable   B4_STEP_1_TRIGGER_A2_MESUREMENT_REPORT.pcap
    ${IAF_MEAS_PROFILE_ID}=  gnb.get_iaf_meas_profile_id_from_mapping_profile
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    gnb.enable_measurement_configuration_for_ho  event_name=eventA3  config=none  nrcell_id=${SOURCE_CELL_ID}
    ...  nrhoif_id=${SOURCE_CELL_NRHOIF_ID}
    gnb.update_meas_profile_param_from_structure    param_name=a2ThresholdhoSsbRsrp    param_value=55
    ...    structure_name=a2MeashoSsbRsrp    profile_type=IAF    profile_id=${IAF_MEAS_PROFILE_ID}
    gnb.update_meas_profile_param_from_structure    param_name=a1ThresholdhoSsbRsrp    param_value=57
    ...    structure_name=a1MeashoSsbRsrp    profile_type=IAF    profile_id=${IAF_MEAS_PROFILE_ID}
    keywords.attach_ue_with_source_cell_ru_rotation  pcap_name=${STEP_1_PCAP}  initial_angle=${-20}
    ...  rotation_angle=${30}  detach_ue=${False}
    observer.start_selected_iaf_profile_observer  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ...  meas_profile_id=${IAF_MEAS_PROFILE_ID}  source_cell_id=${SOURCE_CELL_ID}
    ${STEP_2_PCAP}  Set Variable   B4_STEP_2_TRIGGER_A1_MESUREMENT_REPORT.pcap
    meas_counters.wait_for_next_counter_period
    keywords.rotate_source_cell_ru  pcap_name=${STEP_2_PCAP}  rotation_angle=${-20}  wait_after_rotation=20
    pcap_analyzer.check_if_received_measurement_report  event_name=eventA1  pcap_assigned_meas_id=${STEP_1_PCAP}
    ...  pcap_meas_report=${STEP_2_PCAP}
    observer.verify_selected_iaf_measurement_profile
    meas_counters.verify_intra_freq_measurement_profile_counters  cell_id=${SOURCE_CELL_ID}
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}  iaf_meas_profile_id=${IAF_MEAS_PROFILE_ID}
    ...  iaf_meas_cfg_attempts=1  meas_profile_mappings_selections=1
    @{EXPECTED_RESPONSE_TO_A1_MR}=    Create List  eventA2
    pcap_analyzer.check_events_in_mod_req_ack  events_name=${EXPECTED_RESPONSE_TO_A1_MR}  pcap_name=${STEP_2_PCAP}
    keywords.check_if_measurement_profile_settings_used_for_event  event_name=eventA2  profile_id=${IAF_MEAS_PROFILE_ID}
    ...  nrcell_id=${SOURCE_CELL_ID}  pcap_name=${STEP_2_PCAP}
    pcap_analyzer.check_if_removed_measurement_id  event_name=eventA1  pcap_assigned_meas_id=${STEP_1_PCAP}
    ...  pcap_removed_meas_id=${STEP_2_PCAP}
    pcap_analyzer.check_if_removed_measurement_id  event_name=eventA5  pcap_assigned_meas_id=${STEP_1_PCAP}
    ...  pcap_removed_meas_id=${STEP_2_PCAP}
    [Teardown]  Run Keywords
    ...         gnb.enable_measurement_configuration_for_ho  event_name=eventA3  config=rsrp
    ...         nrcell_id=${SOURCE_CELL_ID}    nrhoif_id=${SOURCE_CELL_NRHOIF_ID}
    ...         AND  gnb.update_meas_profile_param_from_structure    param_name=a1ThresholdhoSsbRsrp    param_value=67
    ...              structure_name=a1MeashoSsbRsrp    profile_type=IAF    profile_id=${IAF_MEAS_PROFILE_ID}
    ...         AND  gnb.update_meas_profile_param_from_structure    param_name=a2ThresholdhoSsbRsrp    param_value=65
    ...              structure_name=a2MeashoSsbRsrp    profile_type=IAF    profile_id=${IAF_MEAS_PROFILE_ID}
    ...         AND  Common Postconditions With Watching Alarms

USCB008127-CD#B6_Activate_InterFreq_A4_meas_for_mobility_to_higher_prio_NR_freq_using_meas_profile_upon_a4RetryTimer_NSA
    ${PCAP}  Set Variable   B6_TRIGGER_A4_MEASUREMENTS.pcap
    ${IEF_MEAS_PROFILE_ID}=  gnb.get_ief_meas_profile_id_from_mapping_profile  target_cell_id=${TARGET_CELL_ID}
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ${IAF_MEAS_PROFILE_ID}=  gnb.get_iaf_meas_profile_id_from_mapping_profile
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    gnb.activate_mobility_to_higher_priority_freq  value=NSA
    gnb.define_a4_threshold_for_ssb_rsrq  threshold=112  profile_id=${IEF_MEAS_PROFILE_ID}
    gnb.update_meas_profile_param_from_structure    param_name=a2ThresholdhoSsbRsrp    param_value=55
    ...    structure_name=a2MeashoSsbRsrp    profile_type=IAF    profile_id=${IAF_MEAS_PROFILE_ID}
    observer.start_selected_iaf_profile_observer  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ...  meas_profile_id=${IAF_MEAS_PROFILE_ID}  source_cell_id=${SOURCE_CELL_ID}
    observer.start_selected_ief_profile_observer  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ...  meas_profile_id=${IEF_MEAS_PROFILE_ID}  source_cell_id=${SOURCE_CELL_ID}  target_cell_id=${TARGET_CELL_ID}
    ${DURATION_MEAS_A4}=  gnb.count_duration_of_all_meas_a4_intervals  nrcell_id=${SOURCE_CELL_ID}
    meas_counters.wait_for_next_counter_period
    observer.start_sgnb_addition_success_observer
    keywords.attach_ue_with_source_cell_ru_rotation  pcap_name=${PCAP}  wait_after_attach=${DURATION_MEAS_A4}
    ...  initial_angle=${-20}  rotation_angle=${None}
    observer.verify_selected_iaf_measurement_profile
    observer.verify_selected_ief_measurement_profile
    ${successful_sgnb_additions}=  observer.count_successful_sgnb_addition_results
    meas_counters.verify_inter_and_intra_freq_measurement_profile_counters  cell_id=${SOURCE_CELL_ID}
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}  ief_meas_profile_id=${IEF_MEAS_PROFILE_ID}
    ...  iaf_meas_profile_id=${IAF_MEAS_PROFILE_ID}  ief_meas_cfg_attempts=5  iaf_meas_cfg_attempts=5
    ...  meas_profile_mappings_selections=10  successful_sgnb_additions=${successful_sgnb_additions}
    keywords.check_a4_measurements  nrcell_id=${SOURCE_CELL_ID}  pcap_name=${PCAP}
    [Teardown]  Run Keywords
    ...         gnb.activate_mobility_to_higher_priority_freq  value=none
    ...         AND  gnb.define_a4_threshold_for_ssb_rsrq  threshold=51  profile_id=${IEF_MEAS_PROFILE_ID}
    ...         AND  gnb.update_meas_profile_param_from_structure    param_name=a2ThresholdhoSsbRsrp    param_value=65
    ...              structure_name=a2MeashoSsbRsrp    profile_type=IAF    profile_id=${IAF_MEAS_PROFILE_ID}
    ...         AND  Common Postconditions With Watching Alarms

USCB008127-CD#B7_Handling_Inter-Freq_A3_meas_report_using_the_selected_measurement_profile_for_RsrpCombined_mode_for_NSA
    ${PCAP}  Set Variable   B7_MESUREMENT_A3_RSRQ_COMBINED_EVALUATION.pcap
    ${IEF_MEAS_PROFILE_ID}=  gnb.get_ief_meas_profile_id_from_mapping_profile  target_cell_id=${TARGET_CELL_ID}
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ${IAF_MEAS_PROFILE_ID}=  gnb.get_iaf_meas_profile_id_from_mapping_profile
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    gnb.enable_measurement_configuration_for_ho  event_name=eventA3  config=rsrqCombined  nrcell_id=${SOURCE_CELL_ID}
    ...  nrhoif_id=${SOURCE_CELL_NRHOIF_ID}
    gnb.enable_measurement_configuration_for_ho  event_name=eventA5  config=none  nrcell_id=${SOURCE_CELL_ID}
    ...  nrhoif_id=${SOURCE_CELL_NRHOIF_ID}
    gnb.define_a3_offset_ssb_rsrp  offset=-30  profile_id=${IEF_MEAS_PROFILE_ID}
    observer.start_selected_iaf_profile_observer  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ...  meas_profile_id=${IAF_MEAS_PROFILE_ID}  source_cell_id=${SOURCE_CELL_ID}
    observer.start_selected_ief_profile_observer  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ...  meas_profile_id=${IEF_MEAS_PROFILE_ID}  source_cell_id=${SOURCE_CELL_ID}  target_cell_id=${TARGET_CELL_ID}
    observer.start_measurement_a3_rsrq_combined_evaluation_observer
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}  meas_profile_id=${IEF_MEAS_PROFILE_ID}
    ...  source_cell_id=${SOURCE_CELL_ID}  target_cell_id=${TARGET_CELL_ID}
    observer.start_inter_freq_handover_observer  source_cell_id=${SOURCE_CELL_ID}  target_cell_id=${TARGET_CELL_ID}
    meas_counters.wait_for_next_counter_period
    observer.start_sgnb_addition_success_observer
    keywords.attach_ue_with_source_cell_ru_rotation  pcap_name=${PCAP}  initial_angle=${30}  rotation_angle=${None}
    ...  wait_after_attach=5
    pcap_analyzer.check_if_received_measurement_report  event_name=eventA2  pcap_assigned_meas_id=${PCAP}
    ...  pcap_meas_report=${PCAP}  msg_assigned_meas_id=SgNBAdditionRequestAcknowledge
    keywords.check_if_measurement_profile_settings_used_for_event  event_name=eventA3  configuration=rsrq
    ...  profile_id=${IEF_MEAS_PROFILE_ID}  nrhoif_id=${SOURCE_CELL_NRHOIF_ID}  pcap_name=${PCAP}
    pcap_analyzer.check_if_received_measurement_report  event_name=eventA3  pcap_assigned_meas_id=${PCAP}
    ...  pcap_meas_report=${PCAP}
    observer.verify_selected_iaf_measurement_profile
    observer.verify_selected_ief_measurement_profile
    observer.verify_measurement_a3_rsrq_combined_evaluation
    observer.verify_inter_freq_handover_succeeded
    ${successful_sgnb_additions}=  observer.count_successful_sgnb_addition_results
    meas_counters.verify_inter_and_intra_freq_measurement_profile_counters  cell_id=${SOURCE_CELL_ID}
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}  ief_meas_profile_id=${IEF_MEAS_PROFILE_ID}
    ...  iaf_meas_profile_id=${IAF_MEAS_PROFILE_ID}  ief_meas_cfg_attempts=1  iaf_meas_cfg_attempts=1
    ...  meas_profile_mappings_selections=2  successful_sgnb_additions=${successful_sgnb_additions}
    [Teardown]  Run Keywords
    ...         gnb.define_a3_offset_ssb_rsrp  offset=21  profile_id=${IEF_MEAS_PROFILE_ID}
    ...         AND  gnb.enable_measurement_configuration_for_ho  event_name=eventA3  config=rsrp
    ...              nrcell_id=${SOURCE_CELL_ID}  nrhoif_id=${SOURCE_CELL_NRHOIF_ID}
    ...         AND  gnb.enable_measurement_configuration_for_ho  event_name=eventA5  config=rsrp
    ...              nrcell_id=${SOURCE_CELL_ID}  nrhoif_id=${SOURCE_CELL_NRHOIF_ID}
    ...         AND  Common Postconditions With Watching Alarms

USCB008127-G#B3_Successful_config_A1_InterFreq_A3A5_meas_during_SgNBaddition_using_meas_profile_based_SPID-UE_PowerClass
    enb.activate_endc_subscriber_profile_id_forwarding
    gnb.activate_subscriber_profile_id
    gnb.define_subscriber_profile_id_in_mapping_profile  spid=${SPID_MIN}  profile_id=${PRIMARY_MEASPR_MA_ID}
    gnb.define_last_subscriber_profile_id_in_mapping_profile  spid_last=${SPID_UE}  profile_id=${PRIMARY_MEASPR_MA_ID}
    Activate_Inter-Freq_A3_A5_A1_meas_using_selected_meas_profile_upon_receipt_of_A2_Meas_Report_for_NSA
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}  source_cell_id=${SOURCE_CELL_ID}
    ...  nrhoif_id=${SOURCE_CELL_NRHOIF_ID}  target_cell_id=${TARGET_CELL_ID}
    [Teardown]   Run Keywords
    ...          gnb.define_last_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...          profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.define_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...               profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.activate_subscriber_profile_id  value=false
    ...          AND  enb.activate_endc_subscriber_profile_id_forwarding  value=false
    ...          AND  Common Postconditions With Watching Alarms

USCB008127-G#B3_Failure_case_A1_and_InterFreq_A3_A5_meas_addition_due_to_SPID_out_of_range_with_UE_Power_class_matching
    enb.activate_endc_subscriber_profile_id_forwarding
    gnb.activate_subscriber_profile_id
    gnb.define_subscriber_profile_id_in_mapping_profile  spid=${SPID_MIN}  profile_id=${PRIMARY_MEASPR_MA_ID}
    ${SPID_MAX}=  Evaluate  (${SPID_UE} - ${1})
    gnb.define_last_subscriber_profile_id_in_mapping_profile  spid_last=${SPID_MAX}  profile_id=${PRIMARY_MEASPR_MA_ID}
    Failure_case_A1_and_InterFreq_A3_A5_meas_addition  mapping_profile_id=${SECONDARY_MEASPR_MA_ID}
    ...  source_cell_id=${SOURCE_CELL_ID}
    [Teardown]   Run Keywords
    ...          gnb.define_last_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...          profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.define_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...               profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.activate_subscriber_profile_id  value=false
    ...          AND  enb.activate_endc_subscriber_profile_id_forwarding  value=false
    ...          AND  Common Postconditions With Watching Alarms

USCB008127-G#B3_Failure_case_A1_and_InterFreq_A3_A5_meas_addition_due_to_SPID_not_present_with_UE_Power_class_matching
    enb.activate_endc_subscriber_profile_id_forwarding  value=false
    gnb.activate_subscriber_profile_id
    gnb.define_subscriber_profile_id_in_mapping_profile  spid=${SPID_MIN}  profile_id=${PRIMARY_MEASPR_MA_ID}
    gnb.define_last_subscriber_profile_id_in_mapping_profile  spid_last=${SPID_UE}  profile_id=${PRIMARY_MEASPR_MA_ID}
    Failure_case_A1_and_InterFreq_A3_A5_meas_addition  mapping_profile_id=${SECONDARY_MEASPR_MA_ID}
    ...  source_cell_id=${SOURCE_CELL_ID}
    [Teardown]   Run Keywords
    ...          gnb.define_last_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...          profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.define_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...               profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.activate_subscriber_profile_id  value=false
    ...          AND  enb.activate_endc_subscriber_profile_id_forwarding  value=false
    ...          AND  Common Postconditions With Watching Alarms

USCB008127-G#B3_Successful_config_A1_and_InterFreq_A3A5_meas_during_SgNB_addition_using_meas_profile_based_only_on_SPID
    ${POWER_CLASS_CAP}=  gnb.get_power_class_capabilities  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    enb.activate_endc_subscriber_profile_id_forwarding
    gnb.activate_subscriber_profile_id
    gnb.define_subscriber_profile_id_in_mapping_profile  spid=${SPID_MIN}  profile_id=${PRIMARY_MEASPR_MA_ID}
    gnb.define_last_subscriber_profile_id_in_mapping_profile  spid_last=${SPID_UE}  profile_id=${PRIMARY_MEASPR_MA_ID}
    gnb.update_power_class_capabilities  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}  operation=delete
    ...  capabilities_structure=@{EMPTY}
    Activate_Inter-Freq_A3_A5_A1_meas_using_selected_meas_profile_upon_receipt_of_A2_Meas_Report_for_NSA
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}  source_cell_id=${SOURCE_CELL_ID}
    ...  nrhoif_id=${SOURCE_CELL_NRHOIF_ID}  target_cell_id=${TARGET_CELL_ID}
    [Teardown]   Run Keywords
    ...          gnb.update_power_class_capabilities  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          capabilities_structure=${POWER_CLASS_CAP}
    ...          AND  gnb.define_last_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...               profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.define_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...               profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.activate_subscriber_profile_id  value=false
    ...          AND  enb.activate_endc_subscriber_profile_id_forwarding  value=false
    ...          AND  Common Postconditions With Watching Alarms

USCB008127-G#B4_Reselection_of_measurement_profile_based_on_multiple_criterions_during_measurements_reconfiguration
    gnb.update_plmn_list_in_mapping_profile  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ...  plmn_structure=${DEFAULT_NRPLMN}
    enb.activate_endc_subscriber_profile_id_forwarding
    gnb.activate_subscriber_profile_id
    gnb.define_subscriber_profile_id_in_mapping_profile  spid=${SPID_MIN}  profile_id=${PRIMARY_MEASPR_MA_ID}
    gnb.define_last_subscriber_profile_id_in_mapping_profile  spid_last=${SPID_UE}  profile_id=${PRIMARY_MEASPR_MA_ID}
    Activate_Inter-Freq_A3_A5_A1_meas_using_selected_meas_profile_upon_receipt_of_A2_Meas_Report_for_NSA
    ...  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}  source_cell_id=${SOURCE_CELL_ID}
    ...  nrhoif_id=${SOURCE_CELL_NRHOIF_ID}  target_cell_id=${TARGET_CELL_ID}
    [Teardown]   Run Keywords
    ...          gnb.update_plmn_list_in_mapping_profile  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          operation=delete  plmn_structure=@{EMPTY}
    ...          AND  gnb.define_last_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...               profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.define_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...               profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.activate_subscriber_profile_id  value=false
    ...          AND  enb.activate_endc_subscriber_profile_id_forwarding  value=false
    ...          AND  Common Postconditions With Watching Alarms

USCB008127-G#B4_Failure_case_measurement_profile_based_on_multiple_criterions_PLNM_does_not_match
    ${FAKE_NRPLMN_ID}  Set Variable   3
    gnb.define_nr_plmn_object  operation=create  nr_plmn_id=${FAKE_NRPLMN_ID}  mcc=999  mnc=99  mnc_length=2
    gnb.update_plmn_list_in_mapping_profile  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ...  plmn_structure=NRPLMN-${FAKE_NRPLMN_ID}
    enb.activate_endc_subscriber_profile_id_forwarding
    gnb.activate_subscriber_profile_id
    gnb.define_subscriber_profile_id_in_mapping_profile  spid=${SPID_MIN}  profile_id=${PRIMARY_MEASPR_MA_ID}
    gnb.define_last_subscriber_profile_id_in_mapping_profile  spid_last=${SPID_UE}  profile_id=${PRIMARY_MEASPR_MA_ID}
    Failure_case_A1_and_InterFreq_A3_A5_meas_addition  mapping_profile_id=${SECONDARY_MEASPR_MA_ID}
    ...  source_cell_id=${SOURCE_CELL_ID}
    [Teardown]   Run Keywords
    ...          gnb.update_plmn_list_in_mapping_profile  mapping_profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          operation=delete  plmn_structure=@{EMPTY}
    ...          AND  gnb.define_nr_plmn_object  operation=delete  nr_plmn_id=${FAKE_NRPLMN_ID}
    ...          AND  gnb.define_last_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...               profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.define_subscriber_profile_id_in_mapping_profile  remove_param=${True}
    ...               profile_id=${PRIMARY_MEASPR_MA_ID}
    ...          AND  gnb.activate_subscriber_profile_id  value=false
    ...          AND  enb.activate_endc_subscriber_profile_id_forwarding  value=false
    ...          AND  Common Postconditions With Watching Alarms
