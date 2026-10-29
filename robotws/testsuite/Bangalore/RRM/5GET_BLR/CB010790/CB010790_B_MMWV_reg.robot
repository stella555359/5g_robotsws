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
    ...           Testline Setup    config=${SUITE_CONFIG}    reboot_after_config=yes
    ...    AND    Wait for All Cells to be Configured    timeout=600
    ...    AND    Start WTS and Reach Onair    skip_confirmation=yes
Suite Teardown    Testline Teardown

*** Variables ***
${DELTA_CNT}                ${CURDIR}/configs/delta_pm_counters_5min.json
${DELTA_du_ovlSaRrcRej}     ${CURDIR}/configs/delta_du_ovlSaRrcRej_enabled.json
${DELTA_ovl_disabled}       ${CURDIR}/configs/delta_ovl_disabled.json
&{SUITE_CONFIG}             delta=${DELTA_CNT}
&{CONFIG_du_ovlSaRrcRej}    delta=${DELTA_du_ovlSaRrcRej}

@{DCAP_GNB}                 condor5gSyslog    cp_5g
@{DCAP_BTS}                 scf
&{DCAP_OPTIONS}             gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}           tcpdump_gnb=yes    dcap=${DCAP_OPTIONS}

${MO_CELL1}                 PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
@{RRC_Reject_waitTime}      RRC Reject was received    waitTime.14|waitTime.15|waitTime.16

*** Test Cases ***
[1]CB010790-B_2_On-line_feature_activation_and_deactivation_alternate_scenario
    [Setup]    Run Keywords    Enter Overload State on gNB-CU
    ...    AND    Disable gNB Overload Protection Feature
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_du_ovlSaRrcRej}    radio_res=yes
    Wait for Next PM Counters Interval
    SA UE Register    ue_id=1
    SA UE Deregister    ue_id=1
    ${start_time}    Get Start Time For PCAP Verification
    Enable gNB Overload Protection Feature
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    fail_regexp=REGISTRATION COMPLETE from UE    should_contain=@{RRC_Reject_waitTime}
    Verify NetworkAccessRateReduction Indicating Overload State In PCAP    ${start_time}
    ${start_time}    Get Start Time For PCAP Verification
    Disable gNB Overload Protection Feature
    SA UE Register    ue_id=1
    SA UE Deregister    ue_id=1
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    Enter Overload State on gNB-DU
    Enable gNB Overload Protection Feature
    ${start_time}    Get Start Time For PCAP Verification
    Exit Overload State on gNB-CU
    SA UE Register    ue_id=1    pass_regexp=UE1: detached    fail_regexp=REGISTRATION COMPLETE from UE    should_contain=@{RRC_Reject_waitTime}
    Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP    ${start_time}
    ${pm_filepath}    Get Next XML PM Counters File
    Stop GNB tcpdump Collection
    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Verify Last Counters In File
    ...  M55124C00023  2  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    [Teardown]    Run Keywords
    ...           Test Case Teardown    oam_logs=yes    check_radio_res=yes
    ...    AND    Upload Delta    delta=${DELTA_ovl_disabled}
    ...    AND    Exit Overload State on gNB-DU
    ...    AND    Exit Overload State on gNB-CU
