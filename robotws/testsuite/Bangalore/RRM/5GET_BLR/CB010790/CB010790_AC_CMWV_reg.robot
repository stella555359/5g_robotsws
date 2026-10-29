*** Settings ***
Documentation
...            CB010790      DU overload handling
...
...            author:        Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com,
...                           Marcin Duplaga, marcin.duplaga@nokia.com,
...                           Jakub Rutyna, jakub.rutyna@nokia.com,
...                           Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com
...            maintainer:    Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...                           Marcin Duplaga, marcin.duplaga@nokia.com,
...                           Jakub Rutyna, jakub.rutyna@nokia.com,
...                           Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com

Resource    ./CB010790_common.robot

Suite Setup       Run Keywords
...               Add Second ENB Cell to WTS Config    wts_delta=${DELTA_WTS_ENB}    wts_out=${WTS_CFG}
...    AND        Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Testline Setup    reach_on_air=yes    wts=${WTS_CFG}    config=${SUITE_CONFIG}    reboot_after_config=yes
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}
Test Teardown     Test Case Teardown

*** Variables ***
@{IP_ADDR_SIM_GNB}     eth3:10.0.1.3/24    eth3:10.0.1.4/24
${DELTA_CNT}           ${CURDIR}/configs/delta_pm_counters_5min.json
${DELTA_HO}            ${CURDIR}/configs/delta_HO_SA_NSA.json
${DELTA_INACT}         ${CURDIR}/configs/delta_actRrcInactState_MD.json
@{DELTAS}              ${DELTA_CNT}    ${DELTA_HO}    ${DELTA_INACT}
&{SUITE_CONFIG}        delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
${DELTA_WTS_A3_Xn}     ${CURDIR}/configs/wts_sim_gnb_A3_XnHO.cfg
${DELTA_WTS_ENB}       ${CURDIR}/configs/wts_sim_enb_cell_2.cfg
${WTS_CFG}             ${OUTPUT DIR}/Logs/wts_modified.cfg

@{DCAP_GNB}             condor5gSyslog    cp_5g
@{DCAP_BTS}             scf
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       tcpdump_gnb=yes    dcap=${DCAP_OPTIONS}

${DELTA_ovlNsaAddRej}                    ${CURDIR}/configs/delta_ovlNsaAddRej_enabled.json
${DELTA_ovlNsaLteHoRej}                  ${CURDIR}/configs/delta_ovlNsaLteHoRej_enabled.json
${DELTA_du_ovlSaRrcRej}                  ${CURDIR}/configs/delta_du_ovlSaRrcRej_enabled.json
${DELTA_ovl_disabled}                    ${CURDIR}/configs/delta_ovl_disabled.json
@{DELTAS_du_ovlSaRrcRej_ovlNsaAddRej}    ${DELTA_du_ovlSaRrcRej}    ${DELTA_ovlNsaAddRej}

&{CONFIG_ovlNsaLteHoRej}                 delta=${DELTA_ovlNsaLteHoRej}
&{CONFIG_du_ovlSaRrcRej}                 delta=${DELTA_du_ovlSaRrcRej}
&{CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}    delta=${DELTAS_du_ovlSaRrcRej_ovlNsaAddRej}

${MO_CELL1}                 PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${MO_NRBTS}                 PLMN-PLMN/MRBTS-1/NRBTS-1

*** Test Cases ***
[1]CB010790-A_1_On-line_feature_activation_and_deactivation
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej_ovlNsaAddRej}    radio_res=yes
    Start SA L3 Call    ue_id=1
    Start NSA L3 Call    ue_id=101
    Stop SA L3 Call    ue_id=1
    Stop NSA L3 Call    ue_id=101
    Enable gNB Overload Protection Feature
    @{should_contain}    Create List    RRC Reject was received    waitTime.14|waitTime.15|waitTime.16
    SA UE Register    ue_id=1    pass_regexp=UE.: detached    should_contain=${should_contain}    fail_regexp=${None}
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
    ...           Test Case Teardown    oam_logs=yes    check_radio_res=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU

[1]CB010790-A_22_gNB-DU_ovl_detection_and_clearing_ovl_state_handle_NSA_inter_MeNB_mobility
    [Setup]    Run Keywords
    ...           Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlNsaLteHoRej}    radio_res=yes
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
    Change UE Location    ue_id=101    node_id=1    cell_id=1
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55128C01501  1  X2_HO_FAIL_OVLCP
    ...  local_moid=${MO_NRBTS}
    ...  file_path=${pm_filepath}
    Enter Overload State on gNB-CU
    Enter Overload State on gNB-DU
    Wait for Next PM Counters Interval
    ${start_time}    Get Start Time For PCAP Verification
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
    Verify Entry and Exit of DU Overload State in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}    start_time=${start_time}
    ${filter}    Catenate
    ...    frame.time_epoch > ${start_time} &&
    ...    x2ap.SgNBModificationRequestReject_element && x2ap.misc == control-processing-overload
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=${filter}   count=2
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55128C01501  2  X2_HO_FAIL_OVLCP
    ...  local_moid=${MO_NRBTS}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes    check_radio_res=yes
    ...    AND    Change UE Location    ue_id=101    node_id=1    cell_id=1
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

[1]CB010790-C_3_Handling_of_RRC_resume_during_overload_state_detected_by_gNB-CU
    [Setup]    Run Keywords
    ...           Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_DU_ovlSaRrcRej}

    Wait for Next PM Counters Interval
    ${cmd_ics_param}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command Ext     cmd=${cmd_ics_param}
    SA UE Register    ue_id=1
    Trigger RRC Inactive State
    @{should_contain}    Create List    UE performed resume procedure
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling
    ...    pass_regexp=UE.: Is INACTIVE    should_contain=${should_contain}
    ${ovl_entry_start_time}    Get Start Time For PCAP Verification
    Enter Overload State on gNB-CU
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${ovl_entry_start_time}
    @{should_contain}    Create List    waitTime.14|waitTime.15|waitTime.16
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling
    ...    pass_regexp=RRC Reject was received    should_contain=${should_contain}
    ${ovl_exit_start_time}    Get Start Time For PCAP Verification
    ${pm_filepath}    Get Next XML PM Counters File
    Exit Overload State on gNB-CU
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${ovl_exit_start_time}
    Verify Last Counters In File
    ...  M55166C00019  1  SA_RRC_RESUME1_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-CU
