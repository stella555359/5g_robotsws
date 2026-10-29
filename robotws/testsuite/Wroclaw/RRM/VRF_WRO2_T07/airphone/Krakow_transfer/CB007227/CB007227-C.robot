*** Settings ***
Documentation
...            title:        CB007227-C PCMD measurements for U-Plane - DU
...
...            author:       Nelsandro Sampaio, nelsandro.sampaio@nokia.com
...                          Jakub Rutyna, jakub.rutyna@nokia.com
...            maintainer:   Jakub Rutyna, jakub.rutyna@nokia.com

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    CB007227_common.robot

Suite Setup       Testline Setup    config=${SUITE_CONFIG}    reach_on_air=yes
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
Test Teardown     Run Keywords
...               Add Scout External Execution ID To Reporting Portal
...    AND        Test Case Teardown    check_radio_res=yes    oam_logs=yes
...    AND        Update Sim ENB EN-DC Parameters    id=1    reset=yes

*** Variables ***
# Config Files
${CONFIG_PCMD}        ${CURDIR}/configs/Delta_PCMD_NRMTRACECUUP_tracing.json
@{DELTAS}             ${CONFIG_PCMD}
&{SUITE_CONFIG}       delta=${DELTAS}
# Logging Options
@{DCAP_GNB}             condor5gSyslog
@{DCAP_BTS}             ipCapture
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       dcap=${DCAP_OPTIONS}
@{tshark_options}       -o    ntrstr.defragment:TRUE    -o    ntrstr.port:49148

*** Test Cases ***
# Test transferred from Krakow, will be rewritten
[1]CB007227-5G-C_6_B01_PCMD_measurements_for_U-Plane_gNB-DU
    [Documentation]   This user scenario describes U-Plane PCMD measurement data collection from gNB-DU
    ...               Records that shall be verified and compared with PM Counters:
    ...               *  DuDlRadioBearerRlcMeasTraceRecord
    Start NSA L3 Call    ue_id=11
    Start NSA L3 Call    ue_id=12
    sleep    20s    reason=Wait until at least 5 reports (4096 ms each) are sent to TCE
    Stop NSA L3 Call    ue_id=11
    Stop NSA L3 Call    ue_id=12
    sleep    20s    reason=Wait to make sure that all records have been received properly
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/

    ${records}    Get PCMD Records from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    save_to_file=${TEST_log_dir}/PCMD/PCMD_records.json
    ${records_with_end_marker_true}    Get PCMD Records from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.dlRbRlcMeasRecord && nsetapx.endMarker == 1
    ...    save_to_file=${TEST_log_dir}/PCMD/PCMD_records_with_EndMarker_1.json

    @{sum_of_tx_bytes}    Get Message Field Values from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    field_name=nsetapx.sumOfRlcPduTxBytes
    ...    filter=nsetapx.dlRbRlcMeasRecord && nsetapx.endMarker == 1
    ...    options=${tshark_options}
    @{sum_of_delays}    Get Message Field Values from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    field_name=nsetapx.sumOfDelays
    ...    filter=nsetapx.dlRbRlcMeasRecord && nsetapx.endMarker == 1
    ...    options=${tshark_options}
    @{num_of_rlc_sdus}    Get Message Field Values from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    field_name=nsetapx.numOfRlcSdus
    ...    filter=nsetapx.dlRbRlcMeasRecord && nsetapx.endMarker == 1
    ...    options=${tshark_options}

    ${End_Marker_False}    Create Dictionary
    ...      record_name=dlRbRlcMeasRecord
    ...      drb_Id=4
    ...      endMarker=0
    ...      sumOfRlcPduTxBytes=\\d{1,}
    ...      avgIpLatency.*sumOfDelays=\\d{1,}
    ...      avgIpLatency.*numOfRlcSdus=\\d{1,}
    ${End_Marker_True_UE1}    Create Dictionary
    ...      record_name=dlRbRlcMeasRecord
    ...      drb_Id=4
    ...      endMarker=1
    ...      sumOfRlcPduTxBytes=${sum_of_tx_bytes}[0]
    ...      avgIpLatency.*sumOfDelays=${sum_of_delays}[0]
    ...      avgIpLatency.*numOfRlcSdus=${num_of_rlc_sdus}[0]
    ${End_Marker_True_UE2}    Create Dictionary
    ...      record_name=dlRbRlcMeasRecord
    ...      drb_Id=4
    ...      endMarker=1
    ...      sumOfRlcPduTxBytes=${sum_of_tx_bytes}[1]
    ...      avgIpLatency.*sumOfDelays=${sum_of_delays}[1]
    ...      avgIpLatency.*numOfRlcSdus=${num_of_rlc_sdus}[1]
    ${PCMD_Seq_0}    Create List    ${End_Marker_False}
    Verify PCMD Records Sequence in Collection    ${records}    ${PCMD_Seq_0}
    ${PCMD_Seq_1}    Create List    ${End_Marker_True_UE1}    ${End_Marker_True_UE2}
    Verify PCMD Records Sequence in Collection    ${records_with_end_marker_true}    ${PCMD_Seq_1}
