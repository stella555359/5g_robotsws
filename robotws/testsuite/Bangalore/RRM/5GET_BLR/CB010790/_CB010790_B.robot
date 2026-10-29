*** Settings ***
Documentation
...            CB010790      DU overload handling
...
...            author: Mateusz Michalik,   mateusz.michalik@nokia.com
...            maintainer: Mateusz Michalik,   mateusz.michalik@nokia.com

Resource    ./CB010790_common.robot

Suite Setup       Run Keywords
...               Add Second ENB Cell to WTS Config    wts_delta=${DELTA_WTS_ENB}    wts_out=${WTS_CFG}
...    AND        Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Add Extra NSA Bearer    wts_delta=${DELTA_WTS_DRB}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Add Extra UE Caps    wts_delta=${DELTA_WTS_CAPS}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Testline Setup    reach_on_air=yes    wts=${WTS_CFG}    config=${SUITE_CONFIG}
Suite Teardown    Testline Teardown

Test Teardown     Run Keywords        Stop GNB tcpdump Collection
    ...    AND    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

*** Variables ***
@{IP_ADDR_SIM_GNB}     eth3:10.0.1.3/24    eth3:10.0.1.4/24
${DELTA_CNT}           ${CURDIR}/configs/delta_pm_counters_5min.json
${DELTA_CNT_15min}     ${CURDIR}/configs/delta_pm_counters_15min.json
${DELTA_HO}            ${CURDIR}/configs/delta_HO_SA_NSA.json
${DELTA_A4}            ${CURDIR}/configs/delta_A4meas.json
${DELTA_BEAM}          ${CURDIR}/configs/delta_beam_rrc.json
@{DELTAS}              ${DELTA_CNT}    ${DELTA_HO}    ${DELTA_A4}    ${DELTA_BEAM}
&{SUITE_CONFIG}        delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
${DELTA_WTS_A3_Xn}     ${CURDIR}/configs/wts_sim_gnb_A3_XnHO.cfg
${DELTA_WTS_ENB}       ${CURDIR}/configs/wts_sim_enb_cell_2.cfg
${DELTA_WTS_DRB}       ${CURDIR}/configs/wts_nsa_bearer.cfg
${DELTA_WTS_CAPS}      ${CURDIR}/configs/wts_ue_caps.cfg
${WTS_CFG}             ${OUTPUT DIR}/Logs/wts_modified.cfg

@{DCAP_GNB}             condor5gSyslog    cp_5g
@{DCAP_BTS}             scf
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       tcpdump_gnb=yes    dcap=${DCAP_OPTIONS}

${DELTA_du_ovlSaRrcRej}                  ${CURDIR}/configs/delta_du_ovlSaRrcRej_enabled.json
${DELTA_ovlNsaAddRej}                    ${CURDIR}/configs/delta_ovlNsaAddRej_enabled.json
${DELTA_ovl_disabled}                    ${CURDIR}/configs/delta_ovl_disabled.json
${DELTA_ovlNsaLteHoRej}                  ${CURDIR}/configs/delta_ovlNsaLteHoRej_enabled.json
${DELTA_ovlNsaMeasDiscard}               ${CURDIR}/configs/delta_ovlNsaMeasDiscard_enabled.json
${DELTA_ovlSaHoRej}                      ${CURDIR}/configs/delta_ovlSaHoRej_enabled.json
${DELTA_ovlSaMeasDiscard}                ${CURDIR}/configs/delta_ovlSaMeasDiscard_enabled.json
${DELTA_ovlNsaErabRej}                   ${CURDIR}/configs/delta_ovlNsaErabRej_enabled.json
${DELTA_ovlSaA4TimerDiscard}             ${CURDIR}/configs/delta_ovlSaA4TimerDiscard_enabled.json
${DELTA_ovlBeamSwitchRej}                ${CURDIR}/configs/delta_ovlBeamSwitchRej_enabled.json
${DELTA_emergency_call}                  ${CURDIR}/configs/delta_emergency.json
${DELTA_emergency_call_disabled}         ${CURDIR}/configs/delta_emergency_disabled.json
${DELTA_ovl_enabled}                     ${CURDIR}/configs/delta_ovl_enabled.json

@{DELTAS_du_ovlSaRrcRej_ovlNsaAddRej}    ${DELTA_du_ovlSaRrcRej}    ${DELTA_ovlNsaAddRej}

&{CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}    delta=${DELTAS_du_ovlSaRrcRej_ovlNsaAddRej}
&{CONFIG_du_ovlSaRrcRej}                 delta=${DELTA_du_ovlSaRrcRej}
&{CONFIG_ovlNsaAddRej}                   delta=${DELTA_ovlNsaAddRej}
&{CONFIG_ovlNsaLteHoRej}                 delta=${DELTA_ovlNsaLteHoRej}
&{CONFIG_ovlNsaMeasDiscard}              delta=${DELTA_ovlNsaMeasDiscard}
&{CONFIG_ovlSaHoRej}                     delta=${DELTA_ovlSaHoRej}
&{CONFIG_ovlSaMeasDiscard}               delta=${DELTA_ovlSaMeasDiscard}
&{CONFIG_ovlNsaErabRej}                  delta=${DELTA_ovlNsaErabRej}
&{CONFIG_ovlSaA4TimerDiscard}            delta=${DELTA_ovlSaA4TimerDiscard}
&{CONFIG_ovlBeamSwitchRej}               delta=${DELTA_ovlBeamSwitchRej}
&{CONFIG_ovl_enabled}                    delta=${DELTA_ovl_enabled}

@{RRC_Reject_waitTime}    RRC Reject was received    waitTime.14|waitTime.15|waitTime.16

*** Test Cases ***
CB010790-B_1_On-line_feature_activation_and_deactivation
    [Setup]    Run Keywords    Enter Overload State on gNB-CU
    ...    AND    Disable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}
    SA UE Register    ue_id=1
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101
    SA UE Deregister    ue_id=1
    NSA UE Detach    ue_id=101
    ${start_time}    Get Start Time For PCAP Verification
    Enable gNB Overload Protection Feature
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    fail_regexp=REGISTRATION COMPLETE from UE    should_contain=RRC Reject was received
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    pass_regexp=SgNBAdditionRequestReject
    NSA UE Detach    ue_id=101
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Disable gNB Overload Protection Feature
    SA UE Register    ue_id=1
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101
    SA UE Deregister    ue_id=1
    NSA UE Detach    ue_id=101
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}

CB010790-B_3_gNB-CU_ovl_detection_and_clearing_ovl_state
    [Setup]    Run Keywords    Exit Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}
    Wait for Next PM Counters Interval
    SA UE Register    ue_id=1
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101
    SA UE Deregister    ue_id=1
    NSA UE Detach    ue_id=101
    ${start_time}    Get Start Time For PCAP Verification
    Enter Overload State on gNB-CU
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    fail_regexp=REGISTRATION COMPLETE from UE    should_contain=RRC Reject was received
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    pass_regexp=SgNBAdditionRequestReject
    NSA UE Detach    ue_id=101
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Exit Overload State on gNB-CU
    SA UE Register    ue_id=1
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101
    SA UE Deregister    ue_id=1
    NSA UE Detach    ue_id=101
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55124C00023  1  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  M55112C05501  1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

CB010790-B_5_Clearing_gNB-CU_overload_state_while_gNB-DU_still_experiences_overload_conditions
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}
    Wait for Next PM Counters Interval
    ${start_time}    Get Start Time For PCAP Verification
    Exit Overload State on gNB-CU
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    fail_regexp=REGISTRATION COMPLETE from UE    should_contain=RRC Reject was received
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    pass_regexp=SgNBAdditionRequestReject
    NSA UE Detach    ue_id=101
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55124C00023  1  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  M55112C05501  1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

CB010790-B_7_gNB-CU_Overload_Emergency_call
    [Setup]    Run Keywords    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Upload Delta    delta=${DELTA_emergency_call}
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    fail_regexp=REGISTRATION COMPLETE from UE    should_contain=RRC Reject was received
    Prepare UE To Emergency Call    ue_id=1
    SA UE Register    ue_id=1    should_contain=establishmentCause emergency
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1    request_type=initial-emergency-request
    [Teardown]    Run Keywords        Stop GNB tcpdump Collection
    ...    AND    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Upload Delta    delta=${DELTA_emergency_call_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

CB010790-B_9_On-line_feature_activation_and_deactivation_handle_beam_switch
    [Setup]    Run Keywords    Enter Overload State on gNB-CU
    ...    AND    Disable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlBeamSwitchRej}
    Wait for Next PM Counters Interval
    Set and Attach Beamcontrol Test Mode    ue_id=1
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier 3.*rrcReconfigurationComplete
    Perform Beam Change with RRC    ue_id=1    profile_id=2    should_contain=detectionResource ssb-Index : 1
    Perform Beam Change with RRC    ue_id=1    profile_id=1    should_contain=detectionResource ssb-Index : 0
    SA UE Deregister    ue_id=1
    ${start_time}    Get Start Time For PCAP Verification
    Enable gNB Overload Protection Feature
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    Perform Beam Change with RRC    ue_id=1    profile_id=2    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    Perform Beam Change with RRC    ue_id=1    profile_id=1    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    SA UE Deregister    ue_id=1
    Verify gNB Sends F1AP UEContextModificationRefuse With Misc Cause Control Processing Overload    ${start_time}
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Disable gNB Overload Protection Feature
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier 3.*rrcReconfigurationComplete
    Perform Beam Change with RRC    ue_id=1    profile_id=2    should_contain=detectionResource ssb-Index : 1
    Perform Beam Change with RRC    ue_id=1    profile_id=1    should_contain=detectionResource ssb-Index : 0
    SA UE Deregister    ue_id=1
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55113C02501  1  SA_UE_CTXT_MOD_FAIL_OVLCP
    ...  M55305C03009  3  BEAM_CHANGE_0_1
    ...  M55305C03002  3  BEAM_CHANGE_1_0
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

CB010790-B_10_On-line_feature_activation_and_deactivation_handle_NSA_inter_MeNB_mobility
    [Setup]    Run Keywords    Enter Overload State on gNB-CU
    ...    AND    Disable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaLteHoRej}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    Stop NSA L3 Call    ue_id=101
    Change UE Location    ue_id=101    node_id=1    cell_id=1
    ${start_time}    Get Start Time For PCAP Verification
    Enable gNB Overload Protection Feature
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Change UE Location    ue_id=101    node_id=1    cell_id=1
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Disable gNB Overload Protection Feature
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    Stop NSA L3 Call    ue_id=101
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55128C01501  1  X2_HO_FAIL_OVLCP
    ...  local_moid=${LTEMO}
    ...  file_path=${pm_filepath}

CB010790-B_11_On-line_feature_activation_and_deactivation_handle_measurements_for_NSA
    [Setup]    Run Keywords    Enter Overload State on gNB-CU
    ...    AND    Disable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaMeasDiscard}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    Stop NSA L3 Call    ue_id=101
    ${start_time}    Get Start Time For PCAP Verification
    Enable gNB Overload Protection Feature
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=value NRUeReport
    Sleep    5s    Wait for potential unexpected HO to complete
    Stop NSA L3 Call    ue_id=101
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Disable gNB Overload Protection Feature
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    Stop NSA L3 Call    ue_id=101
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55124C04502  1  NRRCC_NSA_MEAS_DISCARD_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

CB010790-B_12_On-line_feature_activation_and_deactivation_handle_incoming_HO
    [Setup]    Run Keywords    Enter Overload State on gNB-CU
    ...    AND    Disable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaHoRej}
    Wait for Next PM Counters Interval
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Prepare UE History Information    ue_id=1
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    Stop SA L3 Call    ue_id=1
    ${start_time}    Get Start Time For PCAP Verification
    Enable gNB Overload Protection Feature
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Prepare UE History Information    ue_id=1
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    ...    should_contain=@{Empty}    pass_regexp=Unsuccessful outcome for XnAP::HandoverPreparation
    Stop SA L3 Call    ue_id=1
    Verify gNB Sends XNAP HandoverPreparationFailure With Misc Cause Control Processing Overload    ${start_time}
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Disable gNB Overload Protection Feature
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Prepare UE History Information    ue_id=1
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    Stop SA L3 Call    ue_id=1
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55143C00501  1  XN_SA_HO_PREP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

CB010790-B_13_gNB-CU_ovl_detection_and_clearing_ovl_state_handle_RRC_Measurement_report
    [Setup]    Run Keywords    Exit Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaMeasDiscard}
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ${start_time}    Get Start Time For PCAP Verification
    Enter Overload State on gNB-CU
    Start SA L3 Call    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=measResultNeighCells measResultListNR
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=1    node_id=2    cell_id=1
    Stop SA L3 Call    ue_id=1
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Exit Overload State on gNB-CU
    Start SA L3 Call    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    Stop SA L3 Call    ue_id=1
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55124C04503  1  NRRCC_SA_MEAS_DISCARD_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

CB010790-B_15_gNB-CU_ovl_detection_and_clearing_ovl_state_handle_SgNB_Modification_Request_from_MeNB_for_E-RAB_additions
    [Setup]    Run Keywords    Exit Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaErabRej}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    Stop NSA L3 Call    ue_id=101
    ${start_time}    Get Start Time For PCAP Verification
    Enter Overload State on gNB-CU
    Start NSA L3 Call    ue_id=101
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Exit Overload State on gNB-CU
    Start NSA L3 Call    ue_id=101
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    Stop NSA L3 Call    ue_id=101
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55112C05502  1  NX2CC_BEARER_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

CB010790-B_16_gNB-CU_ovl_detection_and_clearing_ovl_state_handle_A4_timer_expiry_for_SA
    [Setup]    Run Keywords    Exit Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaA4TimerDiscard}
    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_TDD_FDD_A4
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier 0.*rrcReconfigurationComplete
    ...    should_contain=eventId eventA4
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=52    event=A4
    SA UE Deregister    ue_id=1
    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ${start_time}    Get Start Time For PCAP Verification
    Enter Overload State on gNB-CU
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    Sleep    3s    Wait for potential unexpected A4 configuration
    Verify UE Has No Configuration For A4 Measurement    ue_id=1
    SA UE Deregister    ue_id=1
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Exit Overload State on gNB-CU
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier 0.*rrcReconfigurationComplete
    ...    should_contain=eventId eventA4
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=52    event=A4
    SA UE Deregister    ue_id=1
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    [Teardown]    Run Keywords        Stop GNB tcpdump Collection
    ...    AND    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ...    AND    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_TDD
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

CB010790-B_17_Multiple_countermeasure_application_and_emergency_call_during_gNB-DU_overload
    [Setup]    Run Keywords    Enter Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Upload Delta    delta=${DELTA_CNT_15min}
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovl_enabled}
    ${start_time}    Get Start Time For PCAP Verification
    Set and Attach Beamcontrol Test Mode    ue_id=1
    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_TDD_FDD_A4
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    Sleep    3s    Wait for potential unexpected A4 configuration
    Verify UE Has No Configuration For A4 Measurement    ue_id=1
    Perform Beam Change with RRC    ue_id=1    profile_id=2    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    Perform Beam Change with RRC    ue_id=1    profile_id=1    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=measResultNeighCells measResultListNR
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=1    node_id=2    cell_id=1
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Prepare UE History Information    ue_id=1
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    ...    should_contain=@{Empty}    pass_regexp=Unsuccessful outcome for XnAP::HandoverPreparation
    Stop SA L3 Call    ue_id=1
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=value NRUeReport
    Sleep    5s    Wait for potential unexpected HO to complete
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Change UE Location    ue_id=101    node_id=1    cell_id=1
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55113C02501  1  SA_UE_CTXT_MOD_FAIL_OVLCP
    ...  M55305C03009  3  BEAM_CHANGE_0_1
    ...  M55305C03002  3  BEAM_CHANGE_1_0
    ...  M55124C04502  1  NRRCC_NSA_MEAS_DISCARD_OVLCP
    ...  M55143C00501  1  XN_SA_HO_PREP_FAIL_OVLCP
    ...  M55124C04503  1  NRRCC_SA_MEAS_DISCARD_OVLCP
    ...  M55112C05502  1  NX2CC_BEARER_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    Verify Last Counters In File
    ...  M55128C01501  1  X2_HO_FAIL_OVLCP
    ...  local_moid=${LTEMO}
    ...  file_path=${pm_filepath}
    Prepare UE To Emergency Call    ue_id=1
    SA UE Register    ue_id=1    should_contain=establishmentCause emergency
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1    request_type=initial-emergency-request
    ...    pass_regexp=rrc-TransactionIdentifier 0.*rrcReconfigurationComplete
    ...    should_contain=eventId eventA4
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=52    event=A4
    SA UE Deregister    ue_id=1
    Change UE Location    ue_id=1    node_id=2    cell_id=1
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    Perform Beam Change with RRC    ue_id=1    profile_id=2    should_contain=detectionResource ssb-Index : 1
    Perform Beam Change with RRC    ue_id=1    profile_id=1    should_contain=detectionResource ssb-Index : 0
    Start Internal SA Downlink Traffic    ue_id=1
    Start Internal SA Uplink Traffic    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    Verify UE Location    ue_id=1    node_id=3    cell_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    Stop SA L3 Call    ue_id=1
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55113C02501  1  SA_UE_CTXT_MOD_FAIL_OVLCP
    ...  M55305C03009  3  BEAM_CHANGE_0_1
    ...  M55305C03002  3  BEAM_CHANGE_1_0
    ...  M55124C04502  1  NRRCC_NSA_MEAS_DISCARD_OVLCP
    ...  M55143C00501  1  XN_SA_HO_PREP_FAIL_OVLCP
    ...  M55124C04503  1  NRRCC_SA_MEAS_DISCARD_OVLCP
    ...  M55112C05502  1  NX2CC_BEARER_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    Verify Last Counters In File
    ...  M55128C01501  1  X2_HO_FAIL_OVLCP
    ...  local_moid=${LTEMO}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords        Stop GNB tcpdump Collection
    ...    AND    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ...    AND    Change UE Location    ue_id=101    node_id=1    cell_id=1
    ...    AND    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_TDD
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

[1]CB010790-B_20_Multiple_gNB-CU_ovl_detection_and_clearing_ovl_state
    [Setup]    Run Keywords    Exit Overload State on gNB-CU
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Upload Delta    delta=${DELTA_CNT_15min}
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=&{CONFIG_du_ovlSaRrcRej}
    Wait for Next PM Counters Interval
    FOR    ${i}    IN RANGE    20
        SA UE Register    ue_id=1
        SA UE Deregister    ue_id=1
        ${start_time}    Get Start Time For PCAP Verification
        Enter Overload State on gNB-CU
        SA UE Register    ue_id=1    pass_regexp=UE1: detached    fail_regexp=REGISTRATION COMPLETE from UE
        ...    should_contain=@{RRC_Reject_waitTime}
        Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
        ${start_time}    Get Start Time For PCAP Verification
        Exit Overload State on gNB-CU
        Sleep    1s
        Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
        END
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55124C00023  20  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

[1]CB010790-B_21_Multiple_gNB-DU_ovl_detection_and_clearing_ovl_state
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Upload Delta    delta=${DELTA_CNT_15min}
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=&{CONFIG_ovlNsaAddRej}
    Wait for Next PM Counters Interval
    FOR    ${i}    IN RANGE    20
        Start NSA L3 Call    ue_id=101
        Stop NSA L3 Call    ue_id=101
        Enter Overload State on gNB-DU
        NSA UE Attach    ue_id=101
        NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1    pass_regexp=SgNBAdditionRequestReject
        NSA UE Detach    ue_id=101
        Exit Overload State on gNB-DU
    END
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.GNBDUStatusIndication_element && f1ap.GNBDUOverloadInformation == overloaded    count=>1
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.GNBDUStatusIndication_element && f1ap.GNBDUOverloadInformation == not-overloaded    count=20
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBAdditionRequestReject_element && x2ap.misc==control-processing-overload   count=20
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55112C05501  20  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

CB010790-B_22_DU_CU_overload_emergency_call
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Upload Delta    delta=${DELTA_emergency_call}
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej}
    Wait for Next PM Counters Interval
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    fail_regexp=REGISTRATION COMPLETE from UE    should_contain=RRC Reject was received
    Prepare UE To Emergency Call    ue_id=1
    SA UE Register    ue_id=1    should_contain=establishmentCause emergency
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1    request_type=initial-emergency-request
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55124C00023  1  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords        Stop GNB tcpdump Collection
    ...    AND    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Upload Delta    delta=${DELTA_emergency_call_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU
