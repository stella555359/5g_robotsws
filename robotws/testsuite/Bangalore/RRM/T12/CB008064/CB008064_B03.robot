*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature  : The aim of the feature is to validate RAN UE ID in NSETAPX messages.
...                             RAN UE ID provide easier correlation of PCMD/Call trace messages coming from CU (CP only) and
...                             DU within 5G (SA mode) as well as correlation of 5G and LTE records in NSA mode.

Resource        resources/Keywords/CB008064_Keyword.robot

Suite Setup       Updated Suite Setup
Suite Teardown    suite teardown for 8064


*** Variables ***
${TOPOLOGY}         CLOUD_5G_I_MP_AP_LO
${UE_ID}            1
${pcapfile}         CB008064_B03.pcap


*** Test Cases ***
[1][1.0] CB008064_B03_3_Verify_NRMTRACECU_initiated_multiple_MBA_TRS_like_Celltrace_PCMD_and_SBA_trace_record_from_gNBCU_CP_with_jobType_is_MDTonly
    [Documentation]         Verify the NRMTRACECU initiated multiple MBA trace sessions(Cell trace, PCMD) and
    ...                     Subscriber trace record from gNBCU-CP with jobType=TraceOnly
    [Tags]    QC_28289   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console          Starting the test......
    [Setup]                 Prepare for test Case - CB008064_B03
    Start Tcp Pcap on wts        log_filename=${pcapfile}        log_dirpath=${Log_Path}
    UE Register and verify for SA    1
    UE Register and verify for SA    2
    UE Register and verify for SA    3
    UE Register and verify for SA    4
    UE Register and verify for SA    5
    Trigger SBA trace recording with PDU setup from AMF     trace_ref_id=6      trace_rec_session_ref_id=6      tce_ip=10.0.1.7
    PDU Session setup                1
    PDU Session setup                2
    PDU Session setup                3
    PDU Session setup                4
    PDU Session setup                5
    Traffic should be successful for SA         traffic_dl_rate=1       traffic_ul_rate=1
    Disable NRBTS level celltrace and PCMD NIDD parameters
    Verify TraceIds in SBA CU moc       ${pcapfile}
    Verify TraceIds in MBA CU moc with Celltrace Only          ${TCE1_IP_PORT}
    ...                    1         ${pcap_file}       tcp_pcap
    Verify TraceIds in MBA CU moc with PCMD Only               ${TCE2_IP_PORT}
    ...                    2         ${pcap_file}       tcp_pcap
    Verify TraceIds in MBA CU moc with Celltrace Only          ${TCE3_IP_PORT}
    ...                    3         ${pcap_file}       tcp_pcap
    Verify TraceIds in MBA CU moc with PCMD Only               ${TCE4_IP_PORT}
    ...                    4         ${pcap_file}       tcp_pcap
    Verify TraceIds in MBA CU moc with PCMD and Celltrace      ${TCE5_IP_PORT}
    ...                    5         ${pcap_file}       tcp_pcap
    UE Deregister should be Successful for SA           1
    UE Deregister should be Successful for SA           2
    UE Deregister should be Successful for SA           3
    UE Deregister should be Successful for SA           4
    UE Deregister should be Successful for SA           5
    Stop Tcp Pcap on wts
    [Teardown]      Run Keyword And Ignore Error     Tear Down for test Case - CB008064_B03
