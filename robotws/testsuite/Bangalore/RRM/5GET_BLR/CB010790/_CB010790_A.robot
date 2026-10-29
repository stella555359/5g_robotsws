*** Settings ***
Documentation
...            CB010790      DU overload handling
...
...            author:    Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:    Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Resource    ./CB010790_common.robot

Suite Setup       Run Keywords
...               Add Second ENB Cell to WTS Config    wts_delta=${DELTA_WTS_ENB}    wts_out=${WTS_CFG}
...    AND        Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Add Extra NSA Bearer    wts_delta=${DELTA_WTS_DRB}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Add Extra UE Caps    wts_delta=${DELTA_WTS_CAPS}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Testline Setup    reach_on_air=yes    wts=${WTS_CFG}    config=${SUITE_CONFIG}
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}
Test Teardown     Test Case Teardown

*** Variables ***
@{IP_ADDR_SIM_GNB}     eth3:10.0.1.3/24    eth3:10.0.1.4/24
${DELTA_CNT}           ${CURDIR}/configs/delta_pm_counters_5min.json
${DELTA_HO}            ${CURDIR}/configs/delta_HO_SA_NSA.json
${DELTA_A4}            ${CURDIR}/configs/delta_A4meas.json
${DELTA_BEAM}          ${CURDIR}/configs/delta_beam_rrc.json
@{DELTAS}              ${DELTA_CNT}    ${DELTA_HO}    ${DELTA_A4}    ${DELTA_BEAM}
&{SUITE_CONFIG}        delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}    wait_for_state=Configured
${DELTA_WTS_A3_Xn}     ${CURDIR}/configs/wts_sim_gnb_A3_XnHO.cfg
${DELTA_WTS_ENB}       ${CURDIR}/configs/wts_sim_enb_cell_2.cfg
${DELTA_WTS_DRB}       ${CURDIR}/configs/wts_nsa_bearer.cfg
${DELTA_WTS_CAPS}      ${CURDIR}/configs/wts_ue_caps.cfg
${WTS_CFG}             ${OUTPUT DIR}/Logs/wts_modified.cfg

@{DCAP_GNB}             condor5gSyslog    cp_5g
@{DCAP_BTS}             scf
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       tcpdump_gnb=yes    dcap=${DCAP_OPTIONS}

${DELTA_ovlBeamSwitchRej}        ${CURDIR}/configs/delta_ovlBeamSwitchRej_enabled.json
${DELTA_ovlNsaA4TimerDiscard}    ${CURDIR}/configs/delta_ovlNsaA4TimerDiscard_enabled.json
${DELTA_ovlNsaAddRej}            ${CURDIR}/configs/delta_ovlNsaAddRej_enabled.json
${DELTA_ovlNsaErabRej}           ${CURDIR}/configs/delta_ovlNsaErabRej_enabled.json
${DELTA_ovlNsaLteHoRej}          ${CURDIR}/configs/delta_ovlNsaLteHoRej_enabled.json
${DELTA_ovlNsaMeasDiscard}       ${CURDIR}/configs/delta_ovlNsaMeasDiscard_enabled.json
${DELTA_ovlSaA4TimerDiscard}     ${CURDIR}/configs/delta_ovlSaA4TimerDiscard_enabled.json
${DELTA_ovlSaHoRej}              ${CURDIR}/configs/delta_ovlSaHoRej_enabled.json
${DELTA_ovlSaMeasDiscard}        ${CURDIR}/configs/delta_ovlSaMeasDiscard_enabled.json
${DELTA_ovlSaPduRej}             ${CURDIR}/configs/delta_ovlSaPduRej_enabled.json
${DELTA_cu_ovlSaRrcRej}          ${CURDIR}/configs/delta_cu_ovlSaRrcRej_enabled.json
${DELTA_du_ovlSaRrcRej}          ${CURDIR}/configs/delta_du_ovlSaRrcRej_enabled.json
${DELTA_ovl_disabled}            ${CURDIR}/configs/delta_ovl_disabled.json

&{CONFIG_ovlBeamSwitchRej}        delta=${DELTA_ovlBeamSwitchRej}
&{CONFIG_ovlNsaA4TimerDiscard}    delta=${DELTA_ovlNsaA4TimerDiscard}
&{CONFIG_ovlNsaAddRej}            delta=${DELTA_ovlNsaAddRej}
&{CONFIG_ovlNsaErabRej}           delta=${DELTA_ovlNsaErabRej}
&{CONFIG_ovlNsaLteHoRej}          delta=${DELTA_ovlNsaLteHoRej}
&{CONFIG_ovlNsaMeasDiscard}       delta=${DELTA_ovlNsaMeasDiscard}
&{CONFIG_ovlSaA4TimerDiscard}     delta=${DELTA_ovlSaA4TimerDiscard}
&{CONFIG_ovlSaHoRej}              delta=${DELTA_ovlSaHoRej}
&{CONFIG_ovlSaMeasDiscard}        delta=${DELTA_ovlSaMeasDiscard}
&{CONFIG_ovlSaPduRej}             delta=${DELTA_ovlSaPduRej}
&{CONFIG_cu_ovlSaRrcRej}          delta=${DELTA_cu_ovlSaRrcRej}
&{CONFIG_du_ovlSaRrcRej}          delta=${DELTA_du_ovlSaRrcRej}
&{CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}    delta=${DELTAS_du_ovlSaRrcRej_ovlNsaAddRej}
@{DELTAS_du_ovlSaRrcRej_ovlNsaAddRej}    ${DELTA_du_ovlSaRrcRej}    ${DELTA_ovlNsaAddRej}

${MO_CELL1}                 PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${MO_NRBTS}                 PLMN-PLMN/MRBTS-1/NRBTS-1
&{CNT_ovlSaRrcRej}          id=M55124C04501    name=SA_RRC_ESTAB_NEME_FAIL_OVLCP      mo_id=${MO_CELL1}    value=1
&{CNT_ovlSaPduRej}          id=M55125C06001    name=SA_PDU_SES_NEME_STP_FAIL_OVLCP    mo_id=${MO_CELL1}    value=1
&{CNT_ovlSaMeasDiscard}     id=M55124C04503    name=NRRCC_SA_MEAS_DISCARD_OVLCP       mo_id=${MO_CELL1}    value=1
&{CNT_ovlSaHoRej}           id=M55143C00501    name=XN_SA_HO_PREP_FAIL_OVLCP          mo_id=${MO_CELL1}    value=1
&{CNT_ovlNsaMeasDiscard}    id=M55124C04502    name=NRRCC_MEAS_NSA_DISCARD_OVLCP      mo_id=${MO_CELL1}    value=1
&{CNT_ovlNsaLteHoRej}       id=M55128C01501    name=X2_HO_FAIL_OVLCP                  mo_id=${MO_CELL1}    value=1
&{CNT_ovlNsaErabRej}        id=M55112C05502    name=NX2CC_BEARER_FAIL_OVLCP           mo_id=${MO_CELL1}    value=1
&{CNT_ovlBeamSwitchRej}     id=M55113C02501    name=SA_UE_CTXT_MOD_FAIL_OVLCP         mo_id=${MO_CELL1}    value=1

*** Test Cases ***
[1]CB010790-A_1_On-line_feature_activation_and_deactivation
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}
    Start SA L3 Call    ue_id=1
    Start NSA L3 Call    ue_id=101
    Stop SA L3 Call    ue_id=1
    Stop NSA L3 Call    ue_id=101
    Enable gNB Overload Protection Feature
    SA UE Register    ue_id=1    pass_regexp=RRC Reject was received
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1    pass_regexp=SgNBAdditionRequestReject
    NSA UE Detach    ue_id=101
    Disable gNB Overload Protection Feature
    Start SA L3 Call    ue_id=1
    Start NSA L3 Call    ue_id=101
    Stop SA L3 Call    ue_id=1
    Stop NSA L3 Call    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBAdditionRequestReject_element   count=1
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

CB010790-A_2_gNB-DU_overload_detection
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Start SA L3 Call    ue_id=1
    Stop NSA L3 Call    ue_id=101
    Stop SA L3 Call    ue_id=1
    Enter Overload State on gNB-DU
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1    pass_regexp=SgNBAdditionRequestReject
    NSA UE Detach    ue_id=101
    SA UE Register    ue_id=1    pass_regexp=RRC Reject was received
    Exit Overload State on gNB-DU
    Start NSA L3 Call    ue_id=102
    Start SA L3 Call    ue_id=2
    Stop NSA L3 Call    ue_id=102
    Stop SA L3 Call    ue_id=2
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBAdditionRequestReject_element   count=1
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55112C05501  1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...  M55124C00023  1  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_3_Clearing_gNB-DU_overload_state_while_gNB-CU_still_experiences_overload_conditions
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}
    Wait for Next PM Counters Interval
    Exit Overload State on gNB-DU
    SA UE Register    ue_id=1    pass_regexp=RRC Reject was received
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1    pass_regexp=SgNBAdditionRequestReject
    NSA UE Detach    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBAdditionRequestReject_element && x2ap.misc==control-processing-overload   count=1
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55112C05501  1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...  M55124C00023  1  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

[1]CB010790-A_5_On-line_feature_activation_and_deactivation_handle_RRC_connection_request_for_SA
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_cu_ovlSaRrcRej}
    Wait for Next PM Counters Interval
    SA UE Register    ue_id=1
    SA UE Deregister    ue_id=1
    Enable gNB Overload Protection Feature
    SA UE Register    ue_id=1    pass_regexp=RRC Reject was received
    Disable gNB Overload Protection Feature
    SA UE Register    ue_id=1
    SA UE Deregister    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55124C04501  1  SA_RRC_ESTAB_NEME_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_6_On-line_feature_activation_and_deactivation_handle_PDU_session_resource_setup
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaPduRej}
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    Stop SA L3 Call    ue_id=1
    Enable gNB Overload Protection Feature
    Start SA L3 Call    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    ...    pass_regexp=PDU Session Resource Setup.*unsuccessful due to misc control processing overload
    Stop SA L3 Call    ue_id=1
    Disable gNB Overload Protection Feature
    Start SA L3 Call    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    Stop SA L3 Call    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55125C06001  1  SA_PDU_SES_NEME_STP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_7_On-line_feature_activation_and_deactivation_handle_RRC_Measurement_report
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaMeasDiscard}
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=2    cell_id=1
    Enable gNB Overload Protection Feature
    Start SA L3 Call    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=measResultNeighCells measResultListNR
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=1    node_id=2    cell_id=1
    Stop SA L3 Call    ue_id=1
    Disable gNB Overload Protection Feature
    Start SA L3 Call    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    Stop SA L3 Call    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55124C04503  1  NRRCC_SA_MEAS_DISCARD_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_8_On-line_feature_activation_and_deactivation_handle_incoming_HO
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaHoRej}
    Wait for Next PM Counters Interval
    Prepare UE History Information    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Enable gNB Overload Protection Feature
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    ...    should_contain=@{Empty}    pass_regexp=Unsuccessful outcome for XnAP::HandoverPreparation
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Disable gNB Overload Protection Feature
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    Stop SA L3 Call    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55143C00501  1  XN_SA_HO_PREP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_9_On-line_feature_activation_and_deactivation_handle_A4_timer_expiry_for_SA
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaA4TimerDiscard}
    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_TDD_FDD_A4
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier 0.*rrcReconfigurationComplete
    ...    should_contain=eventId eventA4
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=52    event=A4
    SA UE Deregister    ue_id=1
    Change UE Location    ue_id=1    node_id=2    cell_id=1
    Enable gNB Overload Protection Feature
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    Sleep    3s    Wait for potential unexpected A4 configuration
    Verify UE Has No Configuration For A4 Measurement    ue_id=1
    SA UE Deregister    ue_id=1
    Disable gNB Overload Protection Feature
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier 0.*rrcReconfigurationComplete
    ...    should_contain=eventId eventA4
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=52    event=A4
    SA UE Deregister    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ...    AND    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_TDD
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_10_On-line_feature_activation_and_deactivation_handle_A4_timer_expiry_for_NSA
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaA4TimerDiscard}
    Update UE Parameters    ue_id=101
    ...    ue_nr_capabilities=$NSA_UE_NR_CAPABILITIES_TDD_FDD_A4
    ...    ue_eutra_nr_capabilities=$NSA_UE_EUTRA_NR_CAPABILITIES_TDD_FDD_A4
    Execute Egate Command Ext
    ...    cmd=ue_enb_param id=101 measurement_gap=gp5:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1
    ...    pass_regexp=SgNBModificationConfirm.*MeNBtoSgNBContainer : '00'H
    ...    should_contain=eventId eventA4
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=52    event=A4
    NSA UE Detach    ue_id=101
    Enable gNB Overload Protection Feature
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1
    Sleep    3s    Wait for potential unexpected A4 configuration
    Verify UE Has No Configuration For A4 Measurement    ue_id=101
    NSA UE Detach    ue_id=101
    Disable gNB Overload Protection Feature
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1
    ...    pass_regexp=SgNBModificationConfirm.*MeNBtoSgNBContainer : '00'H
    ...    should_contain=eventId eventA4
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=52    event=A4
    NSA UE Detach    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Update UE Parameters    ue_id=101
    ...    ue_nr_capabilities=$NSA_UE_CAPABILITIES_TDD    ue_eutra_nr_capabilities=$NR_EUTRA_CAPABILITIES_TDD
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_11_On-line_feature_activation_and_deactivation_handle_measurements_for_NSA
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaMeasDiscard}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    Stop NSA L3 Call    ue_id=101
    Enable gNB Overload Protection Feature
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=value NRUeReport
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=1    node_id=2    cell_id=1
    Stop NSA L3 Call    ue_id=101
    Disable gNB Overload Protection Feature
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    Stop NSA L3 Call    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55124C04502  1  NRRCC_NSA_MEAS_DISCARD_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_12_On-line_feature_activation_and_deactivation_handle_NSA_inter_MeNB_mobility
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaLteHoRej}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    Stop NSA L3 Call    ue_id=101
    Change UE Location    ue_id=101    node_id=1    cell_id=1
    Enable gNB Overload Protection Feature
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Change UE Location    ue_id=101    node_id=1    cell_id=1
    Disable gNB Overload Protection Feature
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    Stop NSA L3 Call    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55128C01501  1  X2_HO_FAIL_OVLCP
    ...  local_moid=${MO_NRBTS}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=101    node_id=1    cell_id=1
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_13_On-line_feature_activation_and_deactivation_handle_SgNB_Modification_Request_from_MeNB_for_E-RAB_additions
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaErabRej}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    Stop NSA L3 Call    ue_id=101
    Enable gNB Overload Protection Feature
    Start NSA L3 Call    ue_id=101
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Disable gNB Overload Protection Feature
    Start NSA L3 Call    ue_id=101
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    Stop NSA L3 Call    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55112C05502  1  NX2CC_BEARER_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_14_On-line_feature_activation_and_deactivation_handle_beam_switch
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlBeamSwitchRej}
    Wait for Next PM Counters Interval
    Set and Attach Beamcontrol Test Mode    ue_id=1
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier 3.*rrcReconfigurationComplete
    Perform Beam Change with RRC    ue_id=1    profile_id=2    should_contain=detectionResource ssb-Index : 1
    Perform Beam Change with RRC    ue_id=1    profile_id=1    should_contain=detectionResource ssb-Index : 0
    SA UE Deregister    ue_id=1
    Enable gNB Overload Protection Feature
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    Perform Beam Change with RRC    ue_id=1    profile_id=2    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    Perform Beam Change with RRC    ue_id=1    profile_id=1    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    SA UE Deregister    ue_id=1
    Disable gNB Overload Protection Feature
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier 3.*rrcReconfigurationComplete
    Perform Beam Change with RRC    ue_id=1    profile_id=2    should_contain=detectionResource ssb-Index : 1
    Perform Beam Change with RRC    ue_id=1    profile_id=1    should_contain=detectionResource ssb-Index : 0
    SA UE Deregister    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55113C02501  1  SA_UE_CTXT_MOD_FAIL_OVLCP
    ...  M55305C03009  3  BEAM_CHANGE_0_1
    ...  M55305C03002  3  BEAM_CHANGE_1_0
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

CB010790-A_15_gNB-DU_ovl_detection_and_clearing_ovl_state_handle_RRC_connection_request_for_SA
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_cu_ovlSaRrcRej}
    SA UE Register    ue_id=1
    SA UE Deregister    ue_id=1
    Enter Overload State on gNB-DU
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    should_contain=RRC Reject was received
    Exit Overload State on gNB-DU
    SA UE Register    ue_id=1
    SA UE Deregister    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

CB010790-A_16_gNB-DU_ovl_detection_and_clearing_ovl_state_handle_PDU_session_resource_setup
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaPduRej}
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    Stop SA L3 Call    ue_id=1
    Enter Overload State on gNB-DU
    Start SA L3 Call    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    ...    pass_regexp=PDU Session Resource Setup.*unsuccessful due to misc control processing overload
    Stop SA L3 Call    ue_id=1
    Exit Overload State on gNB-DU
    Start SA L3 Call    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    Stop SA L3 Call    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55125C06001  1  SA_PDU_SES_NEME_STP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

CB010790-A_17_gNB-DU_ovl_detection_and_clearing_ovl_state_handle_RRC_Measurement_report
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaMeasDiscard}
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=2    cell_id=1
    Enter Overload State on gNB-DU
    Start SA L3 Call    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=measResultNeighCells measResultListNR
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=1    node_id=2    cell_id=1
    Stop SA L3 Call    ue_id=1
    Exit Overload State on gNB-DU
    Start SA L3 Call    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    Stop SA L3 Call    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55124C04503  1  NRRCC_SA_MEAS_DISCARD_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

CB010790-A_18_gNB-DU_ovl_detection_and_clearing_ovl_state_handle_incoming_HO
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaHoRej}
    Wait for Next PM Counters Interval
    Prepare UE History Information    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Enter Overload State on gNB-DU
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    ...    should_contain=@{Empty}    pass_regexp=Unsuccessful outcome for XnAP::HandoverPreparation
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Exit Overload State on gNB-DU
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    Stop SA L3 Call    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55143C00501  1  XN_SA_HO_PREP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_19_gNB-DU_ovl_detection_and_clearing_ovl_state_handle_A4_timer_expiry_for_SA
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
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
    Enter Overload State on gNB-DU
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    Sleep    3s    Wait for potential unexpected A4 configuration
    Verify UE Has No Configuration For A4 Measurement    ue_id=1
    SA UE Deregister    ue_id=1
    Exit Overload State on gNB-DU
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier 0.*rrcReconfigurationComplete
    ...    should_contain=eventId eventA4
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=52    event=A4
    SA UE Deregister    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ...    AND    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_TDD
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_20_gNB-DU_ovl_detection_and_clearing_ovl_state_handle_A4_timer_expiry_for_NSA
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaA4TimerDiscard}
    Update UE Parameters    ue_id=101
    ...    ue_nr_capabilities=$NSA_UE_NR_CAPABILITIES_TDD_FDD_A4
    ...    ue_eutra_nr_capabilities=$NSA_UE_EUTRA_NR_CAPABILITIES_TDD_FDD_A4
    Execute Egate Command Ext
    ...    cmd=ue_enb_param id=101 measurement_gap=gp5:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1
    ...    pass_regexp=SgNBModificationConfirm.*MeNBtoSgNBContainer : '00'H
    ...    should_contain=eventId eventA4
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=52    event=A4
    NSA UE Detach    ue_id=101
    Enter Overload State on gNB-DU
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1
    Sleep    3s    Wait for potential unexpected A4 configuration
    Verify UE Has No Configuration For A4 Measurement    ue_id=101
    NSA UE Detach    ue_id=101
    Exit Overload State on gNB-DU
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1
    ...    pass_regexp=SgNBModificationConfirm.*MeNBtoSgNBContainer : '00'H
    ...    should_contain=eventId eventA4
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=52    event=A4
    NSA UE Detach    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Update UE Parameters    ue_id=101
    ...    ue_nr_capabilities=$NSA_UE_CAPABILITIES_TDD    ue_eutra_nr_capabilities=$NR_EUTRA_CAPABILITIES_TDD
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

CB010790-A_21_gNB-DU_ovl_detection_and_clearing_ovl_state_handle_measurements_for_NSA
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaMeasDiscard}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    Stop NSA L3 Call    ue_id=101
    Enter Overload State on gNB-DU
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=value NRUeReport
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=1    node_id=2    cell_id=1
    Stop NSA L3 Call    ue_id=101
    Exit Overload State on gNB-DU
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    Stop NSA L3 Call    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55124C04502  1  NRRCC_NSA_MEAS_DISCARD_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

CB010790-A_22_gNB-DU_ovl_detection_and_clearing_ovl_state_handle_NSA_inter_MeNB_mobility
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaLteHoRej}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    Stop NSA L3 Call    ue_id=101
    Change UE Location    ue_id=101    node_id=1    cell_id=1
    Enter Overload State on gNB-DU
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Change UE Location    ue_id=101    node_id=1    cell_id=1
    Exit Overload State on gNB-DU
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    Stop NSA L3 Call    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55128C01501  1  X2_HO_FAIL_OVLCP
    ...  local_moid=${MO_NRBTS}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=101    node_id=1    cell_id=1
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

CB010790-A_23_gNB-DU_ovl_detection_and_clearing_ovl_state_handle_SgNB_Modification_Request_from_MeNB_for_E-RAB_additions
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaErabRej}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    Stop NSA L3 Call    ue_id=101
    Enter Overload State on gNB-DU
    Start NSA L3 Call    ue_id=101
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Exit Overload State on gNB-DU
    Start NSA L3 Call    ue_id=101
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    Stop NSA L3 Call    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBModificationRequestReject_element && x2ap.misc == control-processing-overload   count=1
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55112C05502  1  NX2CC_BEARER_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

CB010790-A_24_gNB-DU_ovl_detection_and_clearing_ovl_state_handle_beam_switch
    [Setup]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlBeamSwitchRej}
    Wait for Next PM Counters Interval
    Set and Attach Beamcontrol Test Mode    ue_id=1
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier 3.*rrcReconfigurationComplete
    Perform Beam Change with RRC    ue_id=1    profile_id=2    should_contain=detectionResource ssb-Index : 1
    Perform Beam Change with RRC    ue_id=1    profile_id=1    should_contain=detectionResource ssb-Index : 0
    SA UE Deregister    ue_id=1
    Enter Overload State on gNB-DU
      SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    Perform Beam Change with RRC    ue_id=1    profile_id=2    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    Perform Beam Change with RRC    ue_id=1    profile_id=1    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    SA UE Deregister    ue_id=1
    Exit Overload State on gNB-DU
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier 3.*rrcReconfigurationComplete
    Perform Beam Change with RRC    ue_id=1    profile_id=2    should_contain=detectionResource ssb-Index : 1
    Perform Beam Change with RRC    ue_id=1    profile_id=1    should_contain=detectionResource ssb-Index : 0
    SA UE Deregister    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.UEContextModificationRefuse_element && f1ap.misc == control-processing-overload    count=1
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55113C02501  1  SA_UE_CTXT_MOD_FAIL_OVLCP
    ...  M55305C03009  3  BEAM_CHANGE_0_1
    ...  M55305C03002  3  BEAM_CHANGE_1_0
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

CB010790-A_25_Clearing_gNB-DU_ovl_state_while_gNB-CU_still_experiences_ovl_conditions_handle_RRC_connection_request_for_SA
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_cu_ovlSaRrcRej}
    Wait for Next PM Counters Interval
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    should_contain=RRC Reject was received
    Exit Overload State on gNB-DU
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    should_contain=RRC Reject was received
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55124C04501  2  SA_RRC_ESTAB_NEME_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

CB010790-A_26_Clearing_gNB-DU_ovl_state_while_gNB-CU_still_experiences_ovl_conditions_handle_PDU_session_resource_setup
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaPduRej}
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    ...    pass_regexp=PDU Session Resource Setup.*unsuccessful due to misc control processing overload
    Stop SA L3 Call    ue_id=1
    Exit Overload State on gNB-DU
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Start SA L3 Call    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    ...    pass_regexp=PDU Session Resource Setup.*unsuccessful due to misc control processing overload
    Stop SA L3 Call    ue_id=1
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55125C06001  2  SA_PDU_SES_NEME_STP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

CB010790-A_27_Clearing_gNB-DU_ovl_state_while_gNB-CU_still_experiences_ovl_conditions_handle_RRC_Measurement_report
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaMeasDiscard}
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=measResultNeighCells measResultListNR
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=1    node_id=2    cell_id=1
    Stop SA L3 Call    ue_id=1
    Exit Overload State on gNB-DU
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Start SA L3 Call    ue_id=1
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=measResultNeighCells measResultListNR
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=1    node_id=2    cell_id=1
    Stop SA L3 Call    ue_id=1
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55124C04503  2  NRRCC_SA_MEAS_DISCARD_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

CB010790-A_28_Clearing_gNB-DU_ovl_state_while_gNB-CU_still_experiences_ovl_conditions_handle_incoming_HO
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaHoRej}
    Wait for Next PM Counters Interval
    Prepare UE History Information    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    ...    should_contain=@{Empty}    pass_regexp=Unsuccessful outcome for XnAP::HandoverPreparation
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Exit Overload State on gNB-DU
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    ...    should_contain=@{Empty}    pass_regexp=Unsuccessful outcome for XnAP::HandoverPreparation
    Stop SA L3 Call    ue_id=1
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55143C00501  2  XN_SA_HO_PREP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=1    node_id=2    cell_id=1
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

CB010790-A_29_Clearing_gNB-DU_ovl_state_while_gNB-CU_still_experiences_ovl_conditions_handle_A4_timer_expiry_for_SA
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaA4TimerDiscard}
    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_TDD_FDD_A4
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    Sleep    3s    Wait for potential unexpected A4 configuration
    Verify UE Has No Configuration For A4 Measurement    ue_id=1
    SA UE Deregister    ue_id=1
    Exit Overload State on gNB-DU
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    Sleep    3s    Wait for potential unexpected A4 configuration
    Verify UE Has No Configuration For A4 Measurement    ue_id=1
    SA UE Deregister    ue_id=1
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_TDD
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

CB010790-A_30_Clearing_gNB-DU_ovl_state_while_gNB-CU_still_experiences_ovl_conditions_handle_A4_timer_expiry_for_NSA
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaA4TimerDiscard}
    Update UE Parameters    ue_id=101
    ...    ue_nr_capabilities=$NSA_UE_NR_CAPABILITIES_TDD_FDD_A4
    ...    ue_eutra_nr_capabilities=$NSA_UE_EUTRA_NR_CAPABILITIES_TDD_FDD_A4
    Execute Egate Command Ext
    ...    cmd=ue_enb_param id=101 measurement_gap=gp5:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1
    Sleep    3s    Wait for potential unexpected A4 configuration
    Verify UE Has No Configuration For A4 Measurement    ue_id=101
    NSA UE Detach    ue_id=101
    Exit Overload State on gNB-DU
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=1
    Sleep    3s    Wait for potential unexpected A4 configuration
    Verify UE Has No Configuration For A4 Measurement    ue_id=101
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Update UE Parameters    ue_id=101
    ...    ue_nr_capabilities=$NSA_UE_CAPABILITIES_TDD    ue_eutra_nr_capabilities=$NR_EUTRA_CAPABILITIES_TDD
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

CB010790-A_31_Clearing_gNB-DU_ovl_state_while_gNB-CU_still_experiences_ovl_conditions_handle_measurements_for_NSA
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaMeasDiscard}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=value NRUeReport
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=101    node_id=2    cell_id=1
    Stop NSA L3 Call    ue_id=101
    Exit Overload State on gNB-DU
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=value NRUeReport
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=101    node_id=2    cell_id=1
    Stop NSA L3 Call    ue_id=101
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55124C04502  2  NRRCC_NSA_MEAS_DISCARD_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

[1]CB010790-A_32_Clearing_gNB-DU_ovl_state_while_gNB-CU_still_experiences_ovl_conditions_handle_NSA_inter_MeNB_mobility
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaLteHoRej}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Change UE Location    ue_id=101    node_id=1    cell_id=1
    Exit Overload State on gNB-DU
    Start NSA L3 Call    ue_id=101
    Perform Intra-LTE NSA Handover To Target Cell    ue_id=101    target_cell=2
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBModificationRequestReject_element && x2ap.misc == control-processing-overload   count=2
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55128C01501  2  X2_HO_FAIL_OVLCP
    ...  local_moid=${MO_NRBTS}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Change UE Location    ue_id=101    node_id=1    cell_id=1
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

[1]CB010790-A_33_Clearing_gNB-DU_ovl_state_while_gNB-CU_still_experiences_ovl_handle_SgNB_Modification_Request_from_MeNB_for_E-RAB_additions
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaErabRej}
    Wait for Next PM Counters Interval
    Start NSA L3 Call    ue_id=101
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Exit Overload State on gNB-DU
    Start NSA L3 Call    ue_id=101
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBModificationRequestReject_element && x2ap.misc == control-processing-overload   count=2
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55112C05502  2  NX2CC_BEARER_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_34_Clearing_gNB-DU_ovl_state_while_gNB-CU_still_experiences_ovl_conditions_handle_beam_switch
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlBeamSwitchRej}
    Wait for Next PM Counters Interval
    Set and Attach Beamcontrol Test Mode    ue_id=1
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    Perform Beam Change with RRC    ue_id=1    profile_id=2    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    Perform Beam Change with RRC    ue_id=1    profile_id=1    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    SA UE Deregister    ue_id=1
    Exit Overload State on gNB-DU
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    Perform Beam Change with RRC    ue_id=1    profile_id=2    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    Perform Beam Change with RRC    ue_id=1    profile_id=1    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    SA UE Deregister    ue_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.UEContextModificationRefuse_element && f1ap.misc == control-processing-overload    count=2
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55113C02501  2  SA_UE_CTXT_MOD_FAIL_OVLCP
    ...  M55305C03009  2  BEAM_CHANGE_0_1
    ...  M55305C03002  2  BEAM_CHANGE_1_0
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
