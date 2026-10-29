*** Settings ***
Force Tags      CRT    RAN_5G    RAN_5G_TDD    SBTS00    STATE_CONFIGURED
...             CLOUD_5G_I_MP_AP_LO      SANSA_FS_ECPRI_CMWV_TDD    RF50

Documentation
...            author:     Bartosz Szlezak, bartosz.szlezak@nokia.com
...            maintainer: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource    ./CB008411_common.robot
Resource    ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_ue_mobility
Library     ta5g_enb
Library     ta5g_setups_and_teardowns
Library     ta5g_delta
Library     ../../../../resources/airphone/scripts/dcap_version_checker.py
Library     ../../../../resources/airphone/scripts/SwconfigFlagsChecker.py
Library     ../../../../resources/airphone/scout_reporting/ScoutMonitor.py

Suite Setup       Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...      AND      Create Suite Scope Variables
...      AND      Start Vm Ethernet Interfaces
...      AND      Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...      AND      Find Scfc and Send Delta Commissioning
...               scfc_filename=Delta_PCMD_NRSTRACECU_tracing_without_cell_trace.json
...      AND      Check Version Of Dcap And Install If Needed
...      AND      SwconfigFlagsChecker.Modify Flags In Swconfig    ${RND_FLAGS}
...      AND      Reach Onair    lua_cfg=${WTS_FILE}    check_edaemon_port=True
...      AND      Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...      AND      Roll Delta Back
...               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...               delta_scf_filename=${CURDIR}/config/default/Delta_PCMD_NRSTRACECU_tracing_without_cell_trace.json
...      AND      Stop Default Processes And Gather Logs And Compress Logs

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
Test Teardown     Run Keywords    Restart Scout Monitoring On Test Line If Needed
...      AND      Add Scout External Execution ID To Reporting Portal
...      AND      Test Case Teardown    check_radio_res=yes    oam_logs=yes

*** Variables ***
${WTS_FILE}           ${CURDIR}/config/wts_MP.cfg
@{DCAP_GNB}           condor5gSyslog
@{DCAP_BTS}           ipCapture
&{DCAP_OPTIONS}       gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}     dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
@{tshark_options}     -o    ntrstr.defragment:TRUE    -o    ntrstr.port:49148
@{RND_FLAGS}          0x1003F=1   # AaSysLogInputLevel
...                   0x10040=1   # AaSysLogOutputLevel
...                   0x10041=1   # ERadCcs_AaSysLogOutputMode
...                   0x590072=1  # CP-RT DEBUG level logs
...                   0x66001b=1  # CP-NRT DEBUG level logs
...                   0x890003=0  # CP-UE TRACE level logs
...                   0x890004=1  # CP-CELL DEBUG level logs

${SBA_TRACE_START_1}    ngap.TraceStart_element && nsetapx.TraceMessage==4 && nsetapx.traceActivationType==1 && nsetapx.traceId==00:00:01
${SBA_TRACE_START_2}    ngap.TraceStart_element && nsetapx.TraceMessage==4 && nsetapx.traceActivationType==1 && nsetapx.traceId==00:00:02
${SBA_TRACE_START_3}    ngap.TraceStart_element && nsetapx.TraceMessage==4 && nsetapx.traceActivationType==1 && nsetapx.traceId==00:00:03

${SBA_TRACE_STOP_1}    ngap.DeactivateTrace_element && nsetapx.TraceMessage==5 && nsetapx.traceActivationType==1 && nsetapx.traceId==00:00:01
${SBA_TRACE_STOP_2}    ngap.DeactivateTrace_element && nsetapx.TraceMessage==5 && nsetapx.traceActivationType==1 && nsetapx.traceId==00:00:02
${SBA_TRACE_STOP_3}    ngap.DeactivateTrace_element && nsetapx.TraceMessage==5 && nsetapx.traceActivationType==1 && nsetapx.traceId==00:00:03

@{SBA_START_FILTERS_LIST}     ${SBA_TRACE_START_1}    ${SBA_TRACE_START_2}    ${SBA_TRACE_START_3}
@{SBA_STOP_FILTERS_LIST}     ${SBA_TRACE_STOP_1}    ${SBA_TRACE_STOP_2}    ${SBA_TRACE_STOP_3}

*** Test Cases ***
# Test transferred from Krakow, will be rewritten
[1]CB008411-SR-A_B201_17_PCMD_records_sent_from_cu-cp_in_sba_enabled_by_ngap_trace_start_and_disabled_by_ngap_deactivate_trace
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1    param=rrcReestabTypeSA    value=sameGNB
    Attach 3 UEs And Start 80mbps DL And 20mbps UL Traffic For Each UE
    Verify For 3 UEs That 80mbps DL And 20mbps UL Traffic Is Running And Stable For 60s Period
    Start Subscriber Trace
    ...    ue_id=1    trace_session_id=1    trace_depth=minimum
    Start Subscriber Trace
    ...    ue_id=2    trace_session_id=2    trace_depth=medium
    Start Subscriber Trace
    ...    ue_id=3    trace_session_id=3    trace_depth=maximum
    Sleep    10s    reason=Wait for trace activation
    Trigger UE Reestablishment To The Same DU     ue_id=1      cell_id=1
    Trigger UE Reestablishment To The Same DU     ue_id=2      cell_id=2
    Trigger UE Reestablishment To The Same DU     ue_id=3      cell_id=1
    Sleep    30s    reason=Wait for PCMD records
    Stop Subscriber Trace For 3 UEs
    Sleep    10s    reason=Wait for trace deactivation
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Stop Traffic And Deregister 3 UEs
    Verify That Subscriber Trace Session Was Started
    ...    num_ues=3    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    options=@{tshark_options}
    Verify That Subscriber Trace Session Was Stopped
    ...    num_ues=3    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    options=@{tshark_options}
    ${records}       Get PCMD Records from PCAP      pcap_filepath=${dcap_files}[ipCapture][0]
    ...    save_to_file=${TEST_log_dir}/PCMD/PCMD_records.json
    ${records_MBA}    Filter PCMD Records Based On Trace Field Name
        ...    pcap_filepath=${dcap_files}[ipCapture][0]
        ...    options=@{tshark_options}
        ...    save_to_file=/home/ute/robotws/Logs/UE_MBA_records.json
        ...    nsetapx.traceId=00:00:00
    ${records_SBA_UE_1}    Filter PCMD Records Based On Trace Field Name
        ...    pcap_filepath=${dcap_files}[ipCapture][0]
        ...    options=@{tshark_options}
        ...    save_to_file=${TEST_log_dir}/PCMD/UE_1_SBA_records.json
        ...    nsetapx.traceId=00:00:01
    ${records_SBA_UE_2}    Filter PCMD Records Based On Trace Field Name
        ...    pcap_filepath=${dcap_files}[ipCapture][0]
        ...    options=@{tshark_options}
        ...    save_to_file=${TEST_log_dir}/PCMD/UE_2_SBA_records.json
        ...    nsetapx.traceId=00:00:02
    ${records_SBA_UE_3}    Filter PCMD Records Based On Trace Field Name
        ...    pcap_filepath=${dcap_files}[ipCapture][0]
        ...    options=@{tshark_options}
        ...    save_to_file=${TEST_log_dir}/PCMD/UE_3_SBA_records.json
        ...    nsetapx.traceId=00:00:03

    Verify Records for UE    ue_id=1    records=${records_SBA_UE_1}
    Verify Records for UE    ue_id=2    records=${records_SBA_UE_2}
    Verify Records for UE    ue_id=3    records=${records_SBA_UE_3}

*** Keywords ***
Verify That Subscriber Trace Session Was Started
    [Arguments]    ${num_ues}    ${pcap_filepath}    ${options}
    Log to console    Verifying if Subscriber Trace Session was started for ${num_ues} UEs
    FOR    ${ue}    IN RANGE    ${num_ues}
        Verify Message Count in PCAP
        ...    pcap_filepath=${pcap_filepath}
        ...    filter=${SBA_START_FILTERS_LIST}[${ue}]
        ...    count=>=1    options=${options}
        ${ueCtxSetupCmplRcvTime}    Get Message Timestamp From Pcap
        ...    filter=f1ap.UEContextSetupResponse_element    which_message=${ue}
        ${sbaTraceStartRcvTime}    Get Message Timestamp From Pcap
        ...    filter=${SBA_START_FILTERS_LIST}[${ue}]    pcap_filepath=${pcap_filepath}    which_message=0
        ${diff}     Evaluate    ${sbaTraceStartRcvTime} - ${ueCtxSetupCmplRcvTime}
        Should Be True    ${diff} > 60    msg=SBA trace was activated before triggering ngap.TraceStart
    END

Verify That Subscriber Trace Session Was Stopped
    [Arguments]    ${num_ues}    ${pcap_filepath}    ${options}
    Log to console    Verifying if Subscriber Trace Session was stopped for ${num_ues} UEs
    FOR    ${ue}    IN RANGE    ${num_ues}
        Verify Message Count in PCAP
        ...    pcap_filepath=${pcap_filepath}
        ...    filter=${SBA_STOP_FILTERS_LIST}[${ue}]
        ...    count=>=1    options=${options}
    END

Verify Records for UE
    [Arguments]    ${ue_id}    ${records}
	Verify UeDuConnectivityRecord    ${ue_id}    ${records}
    Verify UeSetupRecord    ${ue_id}    ${records}

Verify UeDuConnectivityRecord
    [Arguments]   ${ue_id}    ${records}
    @{BearerContextSetupRequest_timestamps}    Get Message Timestamp List From Pcap
    ...    filter=e1ap.BearerContextModificationRequest_element
    @{BearerContextSetupResponse_timestamps}   Get Message Timestamp List From Pcap
    ...    filter=e1ap.BearerContextModificationResponse_element
    @{ues_ran_cu_ue_id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_CU_UE_F1AP_ID
    ...    filter=f1ap.DLRRCMessageTransfer_element && nr-rrc.rrcSetup_element
	@{ues_ran_du_ue_id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_DU_UE_F1AP_ID
    ...    filter=f1ap.GNB_DU_UE_F1AP_ID && f1ap.ULRRCMessageTransfer_element && nr-rrc.c1 == 3
    ${index}     Evaluate    ${ue_id} - 1
    ${index_timestamp}    Evaluate    3 + (${index} * 3)
    ${ueDuConnectivityRecord_reestablishment}    Create Dictionary
    ...    record_name=ueDuConnectivityRecord
    ...    DuUeCtxSetupData.*result=0
    ...    DuUeCtxSetupData.*gnb_du_Ids.*gnb_du_Id=0
    ...    DuUeCtxSetupData.*gnb_du_Ids.*gnb_Id.*plmn_Identity=13:41:98
    ...    DuUeCtxSetupData.*gnb_du_Ids.*gnb_Id.*gnb_Id=0
    ...    DuUeCtxSetupData.*gnb_du_Ids.*gnb_Id.*gnb_Id.*gnb_id=00:00:04
    ...    DuUeCtxSetupData.*gnb_cu_ue_f1ap_Id=${ues_ran_cu_ue_id}[${index}]
    ...    DuUeCtxSetupData.*gnb_du_ue_f1ap_Id=${ues_ran_du_ue_id}[${index}]
    ...    DuUeCtxSetupData.*initialUeRrcMessageTransferRcvTime.*seconds=${BearerContextSetupRequest_timestamps}[${index_timestamp}]
    ...    DuUeCtxSetupData.*initialUeRrcMessageTransferRcvTime.*useconds=\\d{2,}
    ${PCMD_Seq}    Create List
	...    ${ueDuConnectivityRecord_reestablishment}
    Verify PCMD Records Sequence in Collection    ${records}    ${PCMD_Seq}

Verify UeSetupRecord
    [Arguments]    ${ue_id}    ${records}
    ${ueSetupRecord_reestablishment}    Create Dictionary
    ...    record_name=ueSetupRecord
    ...    ueSetupRecord.*result=0
    ...    ueSetupRecord.*ran_ue_ngap_Id=\\d+
    ...    ueSetupRecord.*trigger=1
    ...    ueSetupRecord.*amf_ue_ngap_Id=${ue_id}
    ...    ueSetupRecord.*guami_element.*plmn_Identity=13:41:98
    ...    ueSetupRecord.*guami_element.*amfRegionId=01
    ...    ueSetupRecord.*guami_element.*amfSetId=00:80
    ...    ueSetupRecord.*guami_element.*amfPointer=08
    ${PCMD_Seq}    Create List
	...    ${ueSetupRecord_reestablishment}
    Verify PCMD Records Sequence in Collection    ${records}    ${PCMD_Seq}
