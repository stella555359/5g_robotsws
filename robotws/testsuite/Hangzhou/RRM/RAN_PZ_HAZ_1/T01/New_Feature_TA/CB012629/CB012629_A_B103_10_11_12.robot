*** Settings ***
Documentation
...   Author: Qin Zhixia
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: The purpose of this test is to Check CB012629

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK


Test Timeout    180 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CommonKeyword/CB012629_Common_KeyWord.robot



*** Test Cases ***
[1][1.0] WTS Precondition
         Case Precondition for ST   product_type=gnb

[TC10]CB012629-SR-A-B103_10_Successful_PCMD_record_buffering_for_gNB_DU_SBA
    [Tags]    QC_16476       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller buffers initial L2 vendor records and later
    ...       reports them in scope of gNB-DU SBA trace recording session.
    ...       5G_RAN_USR_COM_22975  OM_GEN_SFS_TRACEMGMNT.4852:USCB012629-A#IWK1:
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to true, RSA certificate shall be used
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime 50ms
    ...       NRBTS-actIpThp is set to true
    ...       NRBTS-thpTimeCalc  is set to true
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA for DU with Default TCE, with interfacestotrace set to 0
    ...       step2. Attach UE and start data traffic.
    ...       step3. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. F1AP: UE CONTEXT SETUP REQUEST contains TraceActivate IE same as configured in core simulator.
    ...       b. L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA) is reported to TCE
    ...          SBA TRS contains same records comparing to MBA TRS, due to buffering function is supported .
    ...       c. In tcpdump, there is  NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    ...       d. Verify feaure Interactions of CB012629 with CB008187: RANUEID is included in StartRecording message,
    ...          Sartrecording message,Report message
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP    param_dict=${NRSTRACECUUP_param_dict_3}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_3}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba_tls}    ${dcap_alias_tls}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_tls}    host=${sba_host_tls}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba_tls}
    Set Test Variable  ${dcap_alias_tls}
#    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host_tls}  trace_depth=minimum  ifaces_to_trace=0
#    ...   trace_ref_id=16777215  trace_rec_session_ref_id=65535   trace_plmn=262:03
    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host_tls}  trace_depth=minimum
    ...   trace_ref_id=16777215  trace_rec_session_ref_id=65535   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Trigger ICS With Trace Start   ue_id=2  tce_ip=${sba_host_tls}  trace_depth=min_without_vse
    ...   trace_ref_id=2  trace_rec_session_ref_id=2   trace_plmn=262:03
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
    [Teardown]     TC10 Teardown

[TC11]CB012629-SR-A-B103_11_Application_of_maxBufferingTime_buffering_and_bundling_for_trace_sessions_MBA_SBA
    [Tags]    QC_16483       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller buffers initial L2 vendor records in scope of
    ...       gNB-DU SBA trace recording session
    ...       OM_GEN_SFS_TRACEMGMNT.4851    USCB012629-A#B7;  CB_FIM_47380;CB_FIM_46494
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to true, RSA certificate shall be used
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime 50ms
    ...       NRBTS-actIpThp is set to true
    ...       NRBTS-thpTimeCalc  is set to true
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA for DU with Default TCE.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. F1AP: UE CONTEXT SETUP REQUEST contains TraceActivate IE same as configured in core simulator.
    ...       2. L2 and L3 PCMD content in scope of gNB-DU SBA and MBA trace recording sessions is reported to TCE
    ...       periodically and not less often than buffering time value configured in NIDD,for a particular trace
    ...       recording session (for NRSTRACEDU each 50ms, for NRMTRACEDU each 2000ms interval)
    ...       3.  TCM reports tracing data in a bundled way, i.e. the syscom messages as well as tracing data on a
    ...       level of trace recording sessions and records inside those sessions are combined into singular message
    ...       and reported to TCE as per [BTS_TC_7617].
 #    same with TC10, just check bundled way
    sleep  10s

[TC12]CB012629-SR-A-B103_12_Change_of_maxBufferingTime_due_to_SBA_trace_session_deactivation_via_NRSTRACEDU_MOC_deletion
    [Tags]    QC_25183       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller reports tracing data in bundled way no less often
    ...       than defined value of maxBufferingTime.
    ...       User scenario B103 #2.1;     OM_GEN_SFS_TRACEMGMNT.4869
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to true, RSA certificate shall be used
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime 50ms
    ...       NRBTS-actIpThp is set to true
    ...       NRBTS-thpTimeCalc  is set to true
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA for DU with Default TCE.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Delete NRSTRACEDU MOC via online commissioning.
    ...       step3. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. SBA DU trace recording session for users are stopped
    ...       2. NSETAP-X: TraceMessage.Stop Recording Session is sent to TCE for SBA DU trace recording session
    ...       3. UEs are still registered in TCM and tracing is active for MBA trace sessions
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_3}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_3}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba_tls}    ${dcap_alias_tls}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_tls}    host=${sba_host_tls}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba_tls}
    Set Test Variable  ${dcap_alias_tls}
#    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host_tls}  trace_depth=minimum  ifaces_to_trace=0
#    ...   trace_ref_id=16777215  trace_rec_session_ref_id=65535   trace_plmn=262:03
    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host_tls}  trace_depth=minimum
    ...   trace_ref_id=16777215  trace_rec_session_ref_id=65535   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Trigger ICS With Trace Start   ue_id=2  tce_ip=${sba_host_tls}  trace_depth=min_without_vse
    ...   trace_ref_id=2  trace_rec_session_ref_id=2   trace_plmn=262:03
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
    [Teardown]     TC12 Teardown

Case Postcondtion
    Disconnet UEs
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Case Postcondition for ST

*** Keywords ***
TC10 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   start  wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    sleep  60s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Stop single UE  ue_index=1
    Trigger ICS With Trace Stop  ue_id=2
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba  traceId=ffffff
    Check common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_min_without_vse}   capture_file_path=${local_file_path}
    Check emil logs for sba tls
    Check emil logs for mba

TC12 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   start  wireshark   gnb
    sleep   30s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Stop single UE  ue_index=1
    Trigger ICS With Trace Stop  ue_id=2
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba  traceId=ffffff
    Check common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_min_without_vse}   capture_file_path=${local_file_path}
    Check no tracerecords  tracerecords=${cuup_throughput_tracerecords}   capture_file_path=${local_file_path_1}   host=sba   traceId=ffffff
    Check emil logs for sba tls
    Check emil logs for mba
#   manually check no emil after delete


