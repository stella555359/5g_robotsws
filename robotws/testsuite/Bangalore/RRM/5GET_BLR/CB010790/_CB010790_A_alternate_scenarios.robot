*** Settings ***
Documentation
...            CB010790      DU overload handling
...
...            author: Paulina Karpf Matoga,   paulina.karpf_matoga@nokia.com
...            maintainer: Paulina Karpf Matoga,   paulina.karpf_matoga@nokia.com

Resource       ./CB010790_common.robot

Suite Setup       Run Keywords
    ...           Testline Setup    config=${SUITE_CONFIG}    reboot_after_config=yes
    ...    AND    Wait for All Cells to be Configured    timeout=600
    ...    AND    Start WTS and Reach Onair    skip_confirmation=yes

Suite Teardown    Testline Teardown

*** Variables ***
${DELTA_CNT}             ${CURDIR}/configs/delta_pm_counters_5min.json
${DELTA_ovlNsaAddRej}    ${CURDIR}/configs/delta_ovlNsaAddRej_enabled.json
@{DELTAS}                ${DELTA_CNT}    ${DELTA_ovlNsaAddRej}
&{SUITE_CONFIG}          delta=${DELTAS}

@{DCAP_GNB}              condor5gSyslog    cp_5g
@{DCAP_BTS}              ipCapture
&{DCAP_OPTIONS}          gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}        tcpdump_gnb=yes    dcap=${DCAP_OPTIONS}

${MO_CELL3}              PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3

*** Test Cases ***
[1]CB010790-A_35_On-line_feature_activation_and_deactivation_alternate_scenario
    [Setup]       Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes

    Start NSA L3 Call    ue_id=101    target_gnb_cell=3
    Stop NSA L3 Call    ue_id=101
    Enable gNB Overload Protection Feature
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=3    pass_regexp=SgNBAdditionRequestReject
    NSA UE Detach    ue_id=101
    Disable gNB Overload Protection Feature
    Start NSA L3 Call    ue_id=101    target_gnb_cell=3
    Stop NSA L3 Call    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBAdditionRequestReject_element && x2ap.misc==control-processing-overload   count=1
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes    check_radio_res=yes
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Disable gNB Overload Protection Feature

[1]CB010790-A_36_gNB-CU_ovl_detection_and_clearing_ovl_state_alternate_scenario
    [Setup]       Run Keywords
    ...           Enable gNB Overload Protection Feature
    ...    AND    Wait for Next PM Counters Interval
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
    Start NSA L3 Call    ue_id=101    target_gnb_cell=3
    Stop NSA L3 Call    ue_id=101
    Enter Overload State on gNB-DU
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=3    pass_regexp=SgNBAdditionRequestReject
    NSA UE Detach    ue_id=101
    Exit Overload State on gNB-DU
    Start NSA L3 Call    ue_id=101    target_gnb_cell=3
    Stop NSA L3 Call    ue_id=101
    Verify Entry and Exit of DU Overload State in PCAP    ${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBAdditionRequestReject_element && x2ap.misc==control-processing-overload   count=1
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55112C05501  1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...  local_moid=${MO_CELL3}
    ...  file_path=${pm_filepath}
    [Teardown]    Test Case Teardown    oam_logs=yes    check_radio_res=yes

[1]CB010790-A_37_Clearing_gNB-DU_overload_state_while_gNB-CU_still_experiences_overload_conditions_alternate_scenario
    [Setup]       Run Keywords
    ...           Enter Overload State on gNB-DU
    ...    AND    Enter Overload State on gNB-CU
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Wait for Next PM Counters Interval
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
    Exit Overload State on gNB-DU
    NSA UE Attach    ue_id=101
    NSA LTE-NR Dual Connectivity    ue_id=101    target_gnb=2    target_cell=3    pass_regexp=SgNBAdditionRequestReject
    NSA UE Detach    ue_id=101
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.GNBDUStatusIndication_element && f1ap.GNBDUOverloadInformation == not-overloaded    count=1
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBAdditionRequestReject_element && x2ap.misc==control-processing-overload   count=1
    ${pm_filepath}    Get Next XML PM Counters File
    Verify Last Counters In File
    ...  M55112C05501  1  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...  local_moid=${MO_CELL3}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes    check_radio_res=yes
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU
