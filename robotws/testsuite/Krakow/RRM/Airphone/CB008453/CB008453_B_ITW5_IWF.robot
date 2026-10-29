*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com

Resource    resources/CB008453_resources.robot
Resource    ../CB012734/resources/CB012734_resources.robot

Suite Setup    IWF Suite Setup    scfc=${scfc}    wts_cfg=${wts_cfg}   ap_xml=${iphy}    x2=False    del_RADs=@{del_RADs}    set_RADs=@{set_RADs}
Suite Teardown    IWF Suite teardown after execution

*** Variables ***
${wts_cfg}=           ${CURDIR}/config/wts_212_UEs_NSA_IWF.lua
${scfc}=              ${CURDIR}/config/SCF_2_AWEUC_8_cells_NSA_CB008453_B_ITW5_IWF.xml
${iphy}=              ${CURDIR}/config/AP_2_AWEUC_8cells.xml
@{set_RADs}=          @{EMPTY}
@{del_RADs}=          0x590253    0x580953    0x580958    0x580957    0x580959    0x580983    0x590254    0x590255
${tti_trace_path}=    ${OUTPUTDIR}/TTI_Trace/
${bip_logs_path}=     ${OUTPUTDIR}/BIP_Logs/
${logcollector}=      False
@{BIP_columns_SSB_SLOT_SFN}=    dldata_ssblocksendreql1sw    3gpp.sfn    3gpp.slot

*** Test Cases ***
[1][1.0] CB008453-B_ITW5_Several_UEs_scheduling_with_8CC
    [Documentation]
    ...    Tput Expected in EXCEL Classic_gNB_Capacity_Req_FR2 (CB008453_B_ITW5 - 53UEs x 8CC DL x 4CC UL):
    ...    DL - 2486 Mbps for 8CC DL
    ...    UL - 1438 Mbps (Target L1 1100Mbps) for 4CC UL

    [Setup]  Start Collecting GNB and AP syslog

    CB008453 feature enable
    CB008453_resources.Set maxNumScellsDl and maxNumScellsUl to value    dl_scells=7    ul_scells=3

    Configure Airphone test modes supported high throughput scenarios on IWF setup    first_ue_id=107    last_ue_id=159
    Sleep    120s    reason=Wait for env stabilization
    Attach multi ues    first_ue_id=107    last_ue_id=159
    Sleep    15s    reason=Wait for env stabilization
    Start NSA traffic for multiple UEs    ues=107-159    traffic_rate=50Mbps    dir=DL
    Sleep    15s    reason=Wait for env stabilization
    Start NSA traffic for multiple UEs    ues=107-159    traffic_rate=5Mbps    dir=UL
    Sleep    15s    reason=wait for tput stabilization

    Start collecting BIP logs
    Stop collecting BIP logs    dir_path=${bip_logs_path}    delay=2
    Sleep    15s    reason=Wait for env stabilization

    Start TTI trace
    Stop TTI trace    delay=2    target_dir=${tti_trace_path}
    Sleep    15s    reason=Wait for env stabilization

    Verify DL NSA throughput at gNB level
    ...    expected_dl_traffic_mbps=2500
    ...    margin_mbps=65
    ...    first_ue=107
    ...    last_ue=159
    ...    min_active_cc=421
    ...    max_active_cc=425

    Verify UL NSA throughput at gNB level
    ...    expected_ul_traffic_mbps=250
    ...    margin_mbps=25
    ...    first_ue=107
    ...    last_ue=159
    ...    min_active_cc=210
    ...    max_active_cc=213

    Convert TTI trace pcap
    ...    input=${tti_trace_path}/l2stream3/tcpdump/tcpdump.pcap
    ...    output=${tti_trace_path}/output
    ...    conversion_filter=utcTimestampData|csiSrReportData|csiRsSchedData|dlFdSchedData|dlHarqRxDataArray|ulFdSchedData|ulHarqRxData

    Convert BIP logs pcap to csv
    ...    pcap_path=${bip_logs_path}/L1L2_BIP_Logs/tcpdump.pcap
    ...    filter=dldata_ssblocksendreql1sw
    ...    columns=@{BIP_columns_SSB_SLOT_SFN}
    ...    dir_path=${bip_logs_path}/
    ...    csv_log_name=BIP_Logs.csv

    Run keyword and continue on failure    Verify HARQ feedback on single PUCCH    csv_directory=${tti_trace_path}    ack_nack_check=False
    Run keyword and continue on failure    Verify periodic csi is transmitting    csv_directory=${tti_trace_path}
    Run keyword and continue on failure    Verify TRS on slots    slots=3,11,19,27,35,43,51,59
    ...                                                           csv_directory=${tti_trace_path}
    Run keyword and continue on failure    Verify SSB on slots    slots=0,1,2,3,10,11,16,17
    ...                                                           bip_csv_directory=${bip_logs_path}
    ...                                                           tti_csv_directory=${tti_trace_path}
    Run keyword and continue on failure    Verify BLER from Dl ACK NACK results
    ...                                    csv_directory=${tti_trace_path}    margin_percent=1
    Run keyword and continue on failure    Verify BLER from Ul CRC results
    ...                                    csv_directory=${tti_trace_path}    margin_percent=1

    [Teardown]    Run keywords
    ...           Collect Snapshot and Egate and Syslog logs
    ...    AND    Detach multi UEs    first_ue_id=107    last_ue_id=159
    ...    AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
