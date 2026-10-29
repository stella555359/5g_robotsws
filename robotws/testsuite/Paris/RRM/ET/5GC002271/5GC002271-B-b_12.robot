*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE     SBTS00    CRT    RAN_5G_TDD     RAN_5G
...             STATE_CONFIGURED

Documentation
...             author:                 Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...                                     Wojciech Gicala, wojciech.gicala@nokia.com
...             maintainer:             Paulina Matoga, paulina.matoga@nokia.com
...
...             INTRODUCTION:   5GC002271 PUSCH DTX behavior verification for multi-UE scenario
...             TEST SET NAME:  5GC002271-B-b_12_Validate that proactive grants are assigned
...             TESTING SPLIT:  See 5GC002271 testplan
...             CONTACTS:       OU_MN_RAN_L3_SW_2_KRK_3_SG_53004197@internal.nsn.com
...             REFERENCES:     5GC002271 CFAM
...                             5GC002271 Test Plan
...

Resource        resources/5GC002271-keywords-oran.robot

Suite Setup    Run Keywords
...            Testline Setup
...    AND     Add UEs from UE-131 to UE-134 with skipUplinkTxDynamic and DRX capabilities for NSA TDD

Suite Teardown    Testline Teardown

*** Variables ***
&{TTI_TRACE_STREAM}     nr_phy_cell_ids=50   up_sw=L2Ps    trace_type=Component
@{tti_traces}    ${TTI_TRACE_STREAM}
&{logs_B-b_12}    syslog_gnb=yes    syslog_ap=yes    tcpdump_gnb=yes    sherpa=${tti_traces}
${default_wts_cfg}      ${default_configs}/basic.cfg
${default_configs}      /home/ute/.ute-ca/executions/1/configs/topology_configs/node_1/PRIVATE_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
&{TC_CONFIG_Bb12}    delta=${delta_Bb12}
${delta_Bb12}        ${CURDIR}/resources/Delta-B-b_12.json

*** Test Cases ***
[1]5GC002271-B-b_12_Validate that proactive grants are assigned aproximately in interval defined with ulSchedTimeIntervalTxSkip (basic scenario)
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  Test to validate ulSchedTimeIntervalTxSkip default value. PUSCH DTX behavior verification for multi-UE scenario.
    ...
    ...  PRECONDITIONS:
    ...
    ...  actAdaptiveSr= "FALSE"
    ...  pucchModeSelect = longPucch
    ...  actCDrx=TRUE
    ...  actUlTxSkip=TRUE
    ...  UE has the DRX capability
    ...  UE has the capability of skipUplinkTxDynamic
    ...  srPeriodicity = slots160
    ...  ulSchedTimeInterval = "8" (ms)
    ...  ulSchedTimeIntervalTxSkip  = "15" (ms)
    ...  ulProGrantTimer="10"(ms)
    ...  ulProGrantTimerTxSkip = "1200" (ms)
    ...  payloadSizeProactiveTxSkip = "80" (byte)
    ...
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   AEQN
    ...
    ...  REQUIRED LOGS:        IM Log, Snapshot, CPRT pcap, TTI trace, egate console log
    ...
    ...
    ...  CONTACTS:   OU_MN_RAN_L3_SW_2_KRK_3_SG_53004197@internal.nsn.com
    ...  AUTHOR:     bartosz.bednarczyk@nokia.com
    ...
    ...  REFERENCES:   5GC002271 CFAM
    ...

    [Setup]    Test Case Setup    config=${TC_CONFIG_Bb12}    logs=${logs_B-b_12}    reach_on_air=yes    radio_res=yes    log_dir=B-b_12

    Start Sherpa Trace Collection

    NSA UE Attach    ue_id=131    profile=1
    NSA LTE-NR Dual Connectivity    ue_id=131
    NSA UE Attach    ue_id=132    profile=2
    NSA LTE-NR Dual Connectivity    ue_id=132
    NSA UE Attach    ue_id=133    profile=3
    NSA LTE-NR Dual Connectivity    ue_id=133
    NSA UE Attach    ue_id=134    profile=4
    NSA LTE-NR Dual Connectivity    ue_id=134

    Start UL Burst Traffic    ue_id=131    burst=1    size=1000    period=120
    Start UL Burst Traffic    ue_id=132    burst=1    size=1200    period=130
    Start UL Burst Traffic    ue_id=133    burst=1    size=1300    period=140
    Start UL Burst Traffic    ue_id=134    burst=1    size=1400    period=150

    Start DTX testmode    ue_id=131    profile_id=1    time_vs_interval=50:10
    Start DTX testmode    ue_id=132    profile_id=2    time_vs_interval=60:10
    Start DTX testmode    ue_id=133    profile_id=3    time_vs_interval=70:10
    Start DTX testmode    ue_id=134    profile_id=4    time_vs_interval=80:10

    Sleep    5s    reason=TTI Trace collecting

    ${ttitrace_pcap}    Stop and Collect Sherpa Trace    log_dir=${TEST_log_dir}/TTITrace/

    Stop NSA L3 Call    ue_id=131
    Stop NSA L3 Call    ue_id=132
    Stop NSA L3 Call    ue_id=133
    Stop NSA L3 Call    ue_id=134

    ${ttitrace_files}    Decode TTI Traces from PCAP or BIN    input_filepath=${ttitrace_pcap}
    ...                  format=excelCsv    excel_csv_options=-d combineDlAndUl
    ${ttitrace_dict}    Convert TTI trace from csv to dict    ttitrace_csv=${ttitrace_files.ttitrace_dl_and_ul}

    @{separate_rnti_ttitrace_csv_list}    Split original ttitrace csv to separate files by RNTI
    ...                              ttitrace_csv=${ttitrace_files.ttitrace_dl_and_ul}    ttitrace_dict=${ttitrace_dict}

    Verify proactive grants assignment for UEs    ms=15    ttitrace_csv=${ttitrace_files.ttitrace_dl_and_ul}    ttitrace_dict=${ttitrace_dict}

    Verify that retransmission for proactive grant is not started    separate_rnti_ttitrace_csv_list=${separate_rnti_ttitrace_csv_list}
    Verify that there is no skippableDynamic or nonSkippable grant and CSI report in the same slot
    ...    separate_rnti_ttitrace_csv_list=${separate_rnti_ttitrace_csv_list}

    [Teardown]    Test Case Teardown    teardown_wts=yes    oam_logs=yes    check_radio_res=yes
