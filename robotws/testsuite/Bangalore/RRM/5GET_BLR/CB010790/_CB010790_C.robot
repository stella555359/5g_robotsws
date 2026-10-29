*** Settings ***
Documentation
...            CB010790 -C    RRC Resume Handling
...
...            author:        Jakub Rutyna, jakub.rutyna@nokia.com,
...                           Marcin Duplaga, marcin.duplaga@nokia.com
...            maintainer:    Jakub Rutyna, jakub.rutyna@nokia.com,
...                           Marcin Duplaga, marcin.duplaga@nokia.com

Resource    ./CB010790_common.robot

Suite Setup       Testline Setup    reach_on_air=yes    config=${SUITE_CONFIG}
Suite Teardown    Testline Teardown

Test Teardown     Test Case Teardown    check_radio_res=yes    oam_logs=yes

*** Variables ***
@{DCAP_GNB}                  condor5gSyslog    cp_5g
@{DCAP_BTS}                  ipCapture
&{DCAP_OPTIONS}              gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}            dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
${DELTA_CONFIG_C}            ${CURDIR}/configs/delta_actRrcInactState_MD.json
${DELTA_DU_ovlSaRrcRej}      ${CURDIR}/configs/delta_du_ovlSaRrcRej_enabled.json
${DELTA_CU_ovlSaRrcRej}      ${CURDIR}/configs/delta_cu_ovlSaRrcRej_enabled.json
${DELTA_ovl_disabled}        ${CURDIR}/configs/delta_ovl_disabled.json
${DELTA_PM_COUNTERS_5MIN}    ${CURDIR}/configs/delta_pm_counters_5min.json
${DELTA_EMERGENCY}           ${CURDIR}/configs/delta_emergency.json
${DELTA_PRIORITY_ACCESS}     ${CURDIR}/configs/delta_priority_access.json
@{DELTAS}                    ${DELTA_CONFIG_C}    ${DELTA_PM_COUNTERS_5MIN}    ${DELTA_EMERGENCY}     ${DELTA_PRIORITY_ACCESS}
&{SUITE_CONFIG}              delta=${DELTAS}

&{CONFIG_DU_ovlSaRrcRej}       delta=${DELTA_DU_ovlSaRrcRej}
&{CONFIG_CU_ovlSaRrcRej}       delta=${DELTA_CU_ovlSaRrcRej}

${MO_CELL1}                    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

*** Test Cases ***
[1]CB010790-C_1_Handling_of_RRC_resume_during_overload_state_detected_by_gNB-DU
    [Setup]    Run Keywords    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_DU_ovlSaRrcRej}

    ${cmd_ics_param}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command Ext     cmd=${cmd_ics_param}
    SA UE Register    ue_id=1
    Trigger RRC Inactive State
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling
    Sleep    10s    reason=Wait for UE to be in inactive state again
    Enter Overload State on gNB-DU
    Verify Message Count in PCAP        ${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.GNBDUStatusIndication_element && f1ap.GNBDUOverloadInformation == overloaded    count=>1
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling    pass_regexp=RRC Reject was received
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55166C00019  1  SA_RRC_RESUME1_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

    [Teardown]    Run Keywords
    ...           Exit Overload State on gNB-DU
    ...    AND    Verify Message Count in PCAP    ${TEST_tcpdump_gnb_path}
    ...           filter=f1ap.GNBDUStatusIndication_element && f1ap.GNBDUOverloadInformation == not-overloaded    count=1
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}

[1]CB010790-C_2_Handling_of_RRC_resume_during_overload_state_detected_by_gNB-DU_alternate_scenario
    [Setup]    Run Keywords    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_CU_ovlSaRrcRej}

    ${cmd_ics_param}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command Ext     cmd=${cmd_ics_param}
    SA UE Register    ue_id=1
    Trigger RRC Inactive State
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling
    Sleep    10s    reason=Wait for UE to be in inactive state again
    Enter Overload State on gNB-DU
    Verify Message Count in PCAP    ${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.GNBDUStatusIndication_element && f1ap.GNBDUOverloadInformation == overloaded    count=>1
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling    pass_regexp=RRC Reject was received
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55124C00015  1  SA_RRC_RESUME_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

    [Teardown]    Run Keywords
    ...           Exit Overload State on gNB-DU
    ...    AND    Verify Message Count in PCAP    ${TEST_tcpdump_gnb_path}
    ...           filter=f1ap.GNBDUStatusIndication_element && f1ap.GNBDUOverloadInformation == not-overloaded    count=1
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}

[1]CB010790-C_3_Handling_of_RRC_resume_during_overload_state_detected_by_gNB-CU
    [Setup]    Run Keywords    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_DU_ovlSaRrcRej}
    ...    AND    Wait for Next PM Counters Interval

    ${cmd_ics_param}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command Ext     cmd=${cmd_ics_param}
    SA UE Register    ue_id=1
    Trigger RRC Inactive State
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling
    Sleep    10s    reason=Wait for UE to be in inactive state again
    ${ovl_entry_start_time}    Get Start Time For PCAP Verification
    Enter Overload State on gNB-CU
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${ovl_entry_start_time}
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling    pass_regexp=RRC Reject was received
    ${ovl_exit_start_time}    Get Start Time For PCAP Verification
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55166C00019  1  SA_RRC_RESUME1_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

    [Teardown]    Run Keywords
    ...           Exit Overload State on gNB-CU
    ...    AND    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${ovl_exit_start_time}
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}

[1]CB010790-C_4_Handling_of_RRC_resume_during_overload_state_detected_by_gNB-CU_alternate_scenario
    [Setup]    Run Keywords    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_CU_ovlSaRrcRej}

    ${cmd_ics_param}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command Ext     cmd=${cmd_ics_param}
    SA UE Register    ue_id=1
    Trigger RRC Inactive State
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling
    Sleep    10s    reason=Wait for UE to be in inactive state again
    ${ovl_entry_start_time}    Get Start Time For PCAP Verification
    Enter Overload State on gNB-CU
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${ovl_entry_start_time}
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling    pass_regexp=RRC Reject was received
    ${ovl_exit_start_time}    Get Start Time For PCAP Verification
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55124C00015  1  SA_RRC_RESUME_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

    [Teardown]    Run Keywords
    ...           Exit Overload State on gNB-CU
    ...    AND    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${ovl_exit_start_time}
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}

[1]CB010790-C_5_Handling_of_emergency_RRC_resume_during_overload_state_detected_by_gNB-DU
    [Setup]    Run Keywords    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_CU_ovlSaRrcRej}

    ${cmd_ics_param}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command Ext     cmd=${cmd_ics_param}
    SA UE Register    ue_id=1
    Trigger RRC Inactive State
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling
    Sleep    10s    reason=Wait for UE to be in inactive state again
    Trigger RRCResumeRequest1    ue_id=1    cause=emergency    pass_regexp=QoS Routing Table
    Sleep    10s    reason=Wait for UE to be in inactive state again
    Enter Overload State on gNB-DU
    Verify Message Count in PCAP    ${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.GNBDUStatusIndication_element && f1ap.GNBDUOverloadInformation == overloaded    count=>1
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling    pass_regexp=RRC Reject was received
    Sleep    20s    reason=Wait for UE to be in inactive state again after receiving RRC Reject with Wait Time
    Trigger RRCResumeRequest1    ue_id=1    cause=emergency    pass_regexp=QoS Routing Table

    [Teardown]    Run Keywords
    ...           Exit Overload State on gNB-DU
    ...    AND    Verify Message Count in PCAP    ${TEST_tcpdump_gnb_path}
    ...           filter=f1ap.GNBDUStatusIndication_element && f1ap.GNBDUOverloadInformation == not-overloaded    count=1
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}

[1]CB010790-C_6_Handling_of_emergency_RRC_resume_during_overload_state_detected_by_gNB-CU_alternate_scenario
    [Setup]    Run Keywords    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_DU_ovlSaRrcRej}

    ${cmd_ics_param}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command Ext     cmd=${cmd_ics_param}
    SA UE Register    ue_id=1
    Trigger RRC Inactive State
    Trigger RRCResumeRequest1    ue_id=1    cause=emergency    pass_regexp=QoS Routing Table
    Sleep    10s    reason=Wait for UE to be in inactive state again
    ${ovl_entry_start_time}    Get Start Time For PCAP Verification
    Enter Overload State on gNB-CU
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${ovl_entry_start_time}
    Trigger RRCResumeRequest1    ue_id=1    cause=emergency    pass_regexp=QoS Routing Table
    Sleep    10s    reason=Wait for UE to be in inactive state again
    Trigger RRCResumeRequest1    ue_id=1    cause=mo_Signalling    pass_regexp=RRC Reject was received
    Sleep    10s    reason=Wait for UE to be in inactive state again
    ${ovl_exit_start_time}    Get Start Time For PCAP Verification

    [Teardown]    Run Keywords
    ...           Exit Overload State on gNB-CU
    ...    AND    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${ovl_exit_start_time}
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}

[1]CB010790-C_7_Handling_of_RRC_resume_during_overload_state_detected_by_gNB-DU_with_different_resume_causes
    [Setup]    Run Keywords    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_DU_ovlSaRrcRej}

    Wait for Next PM Counters Interval
    ${cmd_ics_param}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command Ext     cmd=${cmd_ics_param}
    ${start_time}    Get Start Time For PCAP Verification
    Perform Test Procedure For UE-1 With RRC Resume Request 1 Cause mt_Access
    Verify Current Number of F1AP DU Overload Exit Messages    start_time=${start_time}    count=1
    Sleep    10s    reason=Wait before next attach of UE-1
    Perform Test Procedure For UE-1 With RRC Resume Request 1 Cause mo_Data
    Verify Current Number of F1AP DU Overload Exit Messages    start_time=${start_time}    count=2
    Sleep    10s    reason=Wait before next attach of UE-1
    Perform Test Procedure For UE-1 With RRC Resume Request 1 Cause mo_VoiceCall
    Verify Current Number of F1AP DU Overload Exit Messages    start_time=${start_time}    count=3
    Sleep    10s    reason=Wait before next attach of UE-1
    Perform Test Procedure For UE-1 With RRC Resume Request 1 Cause mo_VideoCall
    Verify Current Number of F1AP DU Overload Exit Messages    start_time=${start_time}    count=4
    Sleep    10s    reason=Wait before next attach of UE-1
    Perform Test Procedure For UE-1 With RRC Resume Request 1 Cause mo_SMS
    Verify Current Number of F1AP DU Overload Exit Messages    start_time=${start_time}    count=5
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55166C00019  5  SA_RRC_RESUME1_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

    [Teardown]    Run Keywords    Exit Overload State on gNB-DU
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}

*** Keywords ***
Perform Test Procedure For UE-${ue_id} With RRC Resume Request 1 Cause ${resume_cause}
    SA UE Register    ue_id=${ue_id}
    Trigger RRC Inactive State    ue_id=${ue_id}
    Enter Overload State on gNB-DU
    Trigger RRCResumeRequest1    ue_id=${ue_id}    cause=${resume_cause}
    ...    pass_regexp=RRC Reject was received
    Exit Overload State on gNB-DU
    Sleep    10s    reason=Wait till gNB-DU exits overload state and for UE to be in inactive state again
    Start Internal SA Downlink Traffic    ue_id=${ue_id}
    Sleep    5s    reason=Maintain downlink traffic flow for a while
    Stop SA L3 Call    ue_id=${ue_id}
