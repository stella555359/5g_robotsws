*** Settings ***
Documentation
...   author: Rafal Kawa
...   contact: rafal.kawa@nokia.com
...   description: Common scenarios of CB008127 feature

Library     ./GnbOperations.py    WITH NAME    gnb
Library     ./CustomObservers.py    WITH NAME    observer
Library     ./CustomKeywords.py    WITH NAME    keywords
Library     ./PcapAnalyzer.py    WITH NAME    pcap_analyzer
Library     ./MeasCountersChecker.py    WITH NAME    meas_counters

*** Keywords ***
Activate_Inter-Freq_A3_A5_A1_meas_using_selected_meas_profile_upon_receipt_of_A2_Meas_Report_for_NSA
    [Arguments]  ${mapping_profile_id}  ${source_cell_id}  ${nrhoif_id}  ${target_cell_id}  ${iaf_meas_cfg_attempts}=1
    ...  ${ief_meas_cfg_attempts}=1  ${meas_profile_mappings_selections}=2
    ${PCAP}  Set Variable   CD_B5_TRIGGER_A2_MESUREMENT_REPORT.pcap
    ${IEF_MEAS_PROFILE_ID}=  gnb.get_ief_meas_profile_id_from_mapping_profile  target_cell_id=${target_cell_id}
    ...  mapping_profile_id=${mapping_profile_id}
    ${IAF_MEAS_PROFILE_ID}=  gnb.get_iaf_meas_profile_id_from_mapping_profile
    ...  mapping_profile_id=${mapping_profile_id}
    observer.start_selected_iaf_profile_observer  mapping_profile_id=${mapping_profile_id}
    ...  meas_profile_id=${IAF_MEAS_PROFILE_ID}  source_cell_id=${source_cell_id}
    observer.start_selected_ief_profile_observer  mapping_profile_id=${mapping_profile_id}
    ...  meas_profile_id=${IEF_MEAS_PROFILE_ID}  source_cell_id=${source_cell_id}  target_cell_id=${target_cell_id}
    meas_counters.wait_for_next_counter_period
    observer.start_sgnb_addition_success_observer
    keywords.attach_ue_with_source_cell_ru_rotation  pcap_name=${PCAP}  initial_angle=${-20}  rotation_angle=${30}
    pcap_analyzer.check_if_received_measurement_report  event_name=eventA2  pcap_assigned_meas_id=${PCAP}
    ...  pcap_meas_report=${PCAP}  msg_assigned_meas_id=SgNBAdditionRequestAcknowledge
    observer.verify_selected_iaf_measurement_profile
    observer.verify_selected_ief_measurement_profile
    ${successful_sgnb_additions}=  observer.count_successful_sgnb_addition_results
    meas_counters.verify_inter_and_intra_freq_measurement_profile_counters  cell_id=${source_cell_id}
    ...  iaf_meas_profile_id=${IAF_MEAS_PROFILE_ID}  ief_meas_profile_id=${IEF_MEAS_PROFILE_ID}
    ...  mapping_profile_id=${mapping_profile_id}  meas_profile_mappings_selections=${meas_profile_mappings_selections}
    ...  iaf_meas_cfg_attempts=${iaf_meas_cfg_attempts}  ief_meas_cfg_attempts=${ief_meas_cfg_attempts}
    ...  successful_sgnb_additions=${successful_sgnb_additions}
    @{EXPECTED_RESPONSE_TO_A2_MR}=    Create List  eventA1  eventA3  eventA5
    pcap_analyzer.check_events_in_mod_req_ack  events_name=${EXPECTED_RESPONSE_TO_A2_MR}  pcap_name=${PCAP}
    keywords.check_if_measurement_profile_settings_used_for_event  event_name=eventA1  profile_id=${IAF_MEAS_PROFILE_ID}
    ...  nrcell_id=${source_cell_id}  pcap_name=${PCAP}
    keywords.check_if_measurement_profile_settings_used_for_event  event_name=eventA3  profile_id=${IEF_MEAS_PROFILE_ID}
    ...  nrhoif_id=${nrhoif_id}  pcap_name=${PCAP}
    keywords.check_if_measurement_profile_settings_used_for_event  event_name=eventA5  profile_id=${IEF_MEAS_PROFILE_ID}
    ...  nrhoif_id=${nrhoif_id}  pcap_name=${PCAP}
    pcap_analyzer.check_if_removed_measurement_id  event_name=eventA2  pcap_assigned_meas_id=${PCAP}
    ...  pcap_removed_meas_id=${PCAP}  msg_assigned_meas_id=SgNBAdditionRequestAcknowledge

Failure_case_A1_and_InterFreq_A3_A5_meas_addition
    [Arguments]  ${mapping_profile_id}  ${source_cell_id}  ${iaf_meas_cfg_attempts}=0
    ...  ${meas_profile_mappings_selections}=0
    ${IAF_MEAS_PROFILE_ID}=  gnb.get_iaf_meas_profile_id_from_mapping_profile
    ...  mapping_profile_id=${mapping_profile_id}
    observer.start_selected_iaf_profile_observer  mapping_profile_id=${mapping_profile_id}
    ...  meas_profile_id=${IAF_MEAS_PROFILE_ID}  source_cell_id=${source_cell_id}
    meas_counters.wait_for_next_counter_period
    observer.start_sgnb_addition_success_observer
    keywords.attach_ue_with_source_cell_ru_rotation  initial_angle=${-20}  rotation_angle=${30}
    observer.verify_selected_iaf_measurement_profile
    ${successful_sgnb_additions}=  observer.count_successful_sgnb_addition_results
    meas_counters.verify_intra_freq_measurement_profile_counters  cell_id=${source_cell_id}
    ...  mapping_profile_id=${mapping_profile_id}  iaf_meas_profile_id=${IAF_MEAS_PROFILE_ID}
    ...  iaf_meas_cfg_attempts=${iaf_meas_cfg_attempts}
    ...  meas_profile_mappings_selections=${meas_profile_mappings_selections}
    ...  successful_sgnb_additions=${successful_sgnb_additions}
