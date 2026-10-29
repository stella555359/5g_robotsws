*** Settings ***
Documentation
...            CB010790      DU overload handling
...
...            author: Mateusz Michalik,   mateusz.michalik@nokia.com
...            maintainer: Mateusz Michalik,   mateusz.michalik@nokia.com

Resource    ./CB010790_common.robot

Suite Setup       Run Keywords
    ...           Testline Setup    config=${SUITE_CONFIG}    reboot_after_config=yes
    ...    AND    Wait for All Cells to be Configured    timeout=600
    ...    AND    Start WTS and Reach Onair    skip_confirmation=yes
Suite Teardown    Testline Teardown

Test Teardown     Run Keywords        Stop GNB tcpdump Collection
    ...    AND    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ...    AND    Test Case Teardown    oam_logs=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU

*** Variables ***
${DELTA_CNT}            ${CURDIR}/configs/delta_pm_counters_5min.json
&{SUITE_CONFIG}         delta=${DELTA_CNT}

@{DCAP_GNB}             condor5gSyslog    cp_5g
@{DCAP_BTS}             scf
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       tcpdump_gnb=yes    dcap=${DCAP_OPTIONS}

${DELTA_du_ovlSaRrcRej}                  ${CURDIR}/configs/delta_du_ovlSaRrcRej_enabled.json
${DELTA_ovl_disabled}                    ${CURDIR}/configs/delta_ovl_disabled.json
${DELTA_ovlSaPduRej}                     ${CURDIR}/configs/delta_ovlSaPduRej_enabled.json

&{CONFIG_du_ovlSaRrcRej}                 delta=${DELTA_du_ovlSaRrcRej}
&{CONFIG_ovlSaPduRej}                    delta=${DELTA_ovlSaPduRej}

*** Test Cases ***
CB010790-B_2_On-line_feature_activation_and_deactivation_alternate_scenario
    [Setup]    Run Keywords    Enter Overload State on gNB-CU
    ...    AND    Disable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej}
    SA UE Register    ue_id=1
    SA UE Deregister    ue_id=1
    ${start_time}    Get Start Time For PCAP Verification
    Enable gNB Overload Protection Feature
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    fail_regexp=REGISTRATION COMPLETE from UE    should_contain=RRC Reject was received
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Disable gNB Overload Protection Feature
    SA UE Register    ue_id=1
    SA UE Deregister    ue_id=1
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}

CB010790-B_4_gNB-CU_ovl_detection_and_clearing_ovl_state_alternate_scenario
    [Setup]    Run Keywords    Exit Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej}
    Wait for Next PM Counters Interval
    SA UE Register    ue_id=1
    SA UE Deregister    ue_id=1
    ${start_time}    Get Start Time For PCAP Verification
    Enter Overload State on gNB-CU
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    fail_regexp=REGISTRATION COMPLETE from UE    should_contain=RRC Reject was received
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Exit Overload State on gNB-CU
    SA UE Register    ue_id=1
    SA UE Deregister    ue_id=1
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55124C00023  1  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

CB010790-B_6_Clearing_gNB-CU_overload_state_while_gNB-DU_still_experiences_overload_conditions_alternate_scenario
    [Setup]    Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej}
    Wait for Next PM Counters Interval
    ${start_time}    Get Start Time For PCAP Verification
    Exit Overload State on gNB-CU
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    fail_regexp=REGISTRATION COMPLETE from UE    should_contain=RRC Reject was received
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55124C00023  1  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}

CB010790-B_14_gNB-CU_ovl_detection_and_clearing_ovl_state_handle_PDU_session_resource_setup
    [Setup]    Run Keywords    Exit Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovlSaPduRej}
    Wait for Next PM Counters Interval
    Start SA L3 Call    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    Stop SA L3 Call    ue_id=1
    ${start_time}    Get Start Time For PCAP Verification
    Enter Overload State on gNB-CU
    Start SA L3 Call    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    ...    pass_regexp=PDU Session Resource Setup.*unsuccessful due to misc control processing overload
    Stop SA L3 Call    ue_id=1
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Exit Overload State on gNB-CU
    Start SA L3 Call    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    Stop SA L3 Call    ue_id=1
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55125C06001  1  SA_PDU_SES_NEME_STP_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
