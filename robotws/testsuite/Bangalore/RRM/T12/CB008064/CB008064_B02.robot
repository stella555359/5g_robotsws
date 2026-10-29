*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature  : The aim of the feature is to validate TRACE ID in NSETAPX messages.
...                             We have created 5 CUCP Mocs(NRMTRACECU) with jobtype as ImmediateMDTAndTrace and one SBA Moc(NRSTRACECU)
...                             2 of CUCP mocs are conifgured with PCMD as enable and Celltrace as disabled
...                             2 of CUCP mocs are conifgured with Celltrace as enable and PCMD as disabled
...                             1 of CUCP mocs is configured both PCMD and celltrace as enabled.

Resource        resources/Keywords/CB008064_Keyword.robot

Suite Setup       Updated Suite Setup
Suite Teardown    suite teardown for 8064


*** Variables ***
${UE_ID}            1
${pcapfile}         CB008064_B02.pcap
${TOPOLOGY}         CLOUD_5G_I_LO_AP_LO


*** Test Cases ***
[1][1.0] CB008064_B02_2_Verify_CU_CP_initiated_multiple_MBA_traces_like_Celltrace_PCMD_and_SBA_trace_with_jobType_is_ImmediateMDTAndTrace
    [Documentation]         Verify the NRMTRACECU initiated multiple MBA trace sessions(Cell trace, PCMD) and
    ...                     Subscriber trace record from gNBCU-CP with jobType=TraceOnly
    [Tags]    QC_28291   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console          Starting the test......
    [Setup]                 Prepare for test Case - CB008064_B02
    Start Tcp Pcap on wts        log_filename=${pcapfile}        log_dirpath=${Log_Path}
    UE Register and verify for SA
    Trigger SBA trace recording with PDU setup from AMF     trace_ref_id=6      trace_rec_session_ref_id=6      tce_ip=10.0.1.7
    PDU Session setup
    Traffic should be successful for SA         traffic_dl_rate=1       traffic_ul_rate=1
    Disable NRBTS level celltrace and PCMD NIDD parameters
    Verify TraceIds in SBA CU moc           ${pcapfile}
    Verify TraceIds in MBA CU moc with Celltrace Only           ${TCE1_IP_PORT}
    ...                    1            ${pcap_file}            tcp_pcap
    Verify TraceIds in MBA CU moc with PCMD Only                ${TCE2_IP_PORT}
    ...                    2            ${pcap_file}            tcp_pcap
    Verify TraceIds in MBA CU moc with Celltrace Only           ${TCE3_IP_PORT}
    ...                    3            ${pcap_file}            tcp_pcap
    Verify TraceIds in MBA CU moc with PCMD Only                ${TCE4_IP_PORT}
    ...                    4            ${pcap_file}            tcp_pcap
    Verify TraceIds in MBA CU moc with PCMD and Celltrace       ${TCE5_IP_PORT}
    ...                    5            ${pcap_file}            tcp_pcap
    UE Deregister should be Successful for SA
    Stop Tcp Pcap on wts
    [Teardown]      Run Keyword And Ignore Error     Tear Down for test Case - CB008064_B02
