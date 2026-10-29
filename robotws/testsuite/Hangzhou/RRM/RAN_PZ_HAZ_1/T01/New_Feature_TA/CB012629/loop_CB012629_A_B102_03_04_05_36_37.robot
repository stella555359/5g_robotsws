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
Resource           CommonKeyword/CB012629_Common_KeyWord.robot




*** Test Cases ***
[1][1.0] WTS Precondition
         Case Precondition for ST   product_type=gnb

[TC03]CB012629_SR_A_B102_3_Successful_PCMD_SBA_trace_activation_No_Records_buffering_TLS_Default_TCE
    [Tags]    QC_16474       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that Successful PCMD SBA trace activation in gNB-DU with TC_NrAppStartCallInd
    ...       with dropping of buffered L2 vendor records in scope of gNB-DU SBA trace recording TLS session with default TCE.
    ...       5G_TC_178,5G_TC_180,5G_TC_2247
    ...    2. Preconditions :
    ...       sba_host_tls is TCE-2
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
    ...       2. L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA) is reported
    ...          to TCE, but SBA TRS contains less records comparing to MBA TRS, due to buffering function is not
    ...          supported yet. (initial PCMD records might not be present for a call)
    ...       3. In tcpdump, there is  NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACEDU   param_dict=${NRSTRACEDU_param_dict_3}
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
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host_tls}  trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    [Teardown]     TC03 Teardown

[TC05]CB012629-SR-A-B102_5_Successful_PCMD_SBA_trace_activation_No_Records_buffering_NonTLS_Non_Default_TCE
    [Tags]    QC_16479       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace recording
    ...       session to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       5G_RAN_USR_COM_22975
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
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA for DU with none Default TCE.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. F1AP: UE CONTEXT SETUP REQUEST contains TraceActivate IE same as configured in core simulator.
    ...       2. L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA) is reported
    ...          to TCE, but SBA TRS contains less records comparing to MBA TRS, due to buffering function is not
    ...          supported yet. (initial PCMD records might not be present for a call)
    ...       3. In tcpdump, there is  NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACEDU   param_dict=${NRSTRACEDU_param_dict_2}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host}  trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
  [Teardown]     TC05 Teardown

[TC04]CB012629-SR-A-B102_4_Successful_PCMD_SBA_trace_activation_No_Records_buffering_TLS_Non_Default_TCE
    [Tags]    QC_16478       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that Successful PCMD SBA trace activation in gNB-DU with TC_NrAppStartCallInd
    ...       with dropping of buffered L2 vendor records in scope of gNB-DU SBA trace recording TLS session with
    ...       non default TCE.
    ...       5G_RAN_USR_COM_22975
    ...    2. Preconditions :
    ...       sba_host_tls is TCE-2
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
    ...       step1. UE is configured in Core Simulator to support SBA for DU with non-Default TCE..
    ...       step2. Attach UE and start data traffic.
    ...       step3. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. F1AP: UE CONTEXT SETUP REQUEST contains TraceActivate IE same as configured in core simulator.
    ...       2. L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA) is reported
    ...          to TCE, but SBA TRS contains less records comparing to MBA TRS, due to buffering function is not
    ...          supported yet. (initial PCMD records might not be present for a call)
    ...       3. In tcpdump, there is  NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACEDU   param_dict=${NRSTRACEDU_param_dict_10}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba_tls}    ${dcap_alias_tls}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba_tls}
    Set Test Variable  ${dcap_alias_tls}
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host_tls}  trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    [Teardown]     TC04 Teardown

[TC36]CB012629-SR-A-B102_36_Activation_of_SBA_with_PCMD_content_for_gNB-DU_TCE_IP_0
    [Tags]    QC_25207       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace recording
    ...       session to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       User scenario B102 #3;OM_GEN_SFS_TRACEMGMNT.4858;
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
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured 50 ms
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA in ICS for DU with 0.0.0.0.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA are same) is reported
    ...           to DEFAULT TCE for VDU
    ...       b.  TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACEDU   param_dict=${NRSTRACEDU_param_dict_11}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=0.0.0.0  trace_depth=${trace_depth}  ifaces_to_trace=0
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    [Teardown]     TC05 Teardown

[TC37]CB012629-SR-A-B102_37_Activation_of_SBA_with_PCMD_content_for_gNB-DU_TCE_IP_0_TLS
    [Tags]    QC_25208       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace recording
    ...       session to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       User scenario B102 #3;OM_GEN_SFS_TRACEMGMNT.4858;OM_GEN_SFS_TRACEMGMNT.4860
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
    ...       tlsEnabled set to true
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured 50 ms
    ...    3. Test Case Steps:
    ...       step1. UE is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Use TraceStart command from Core Simulator to 0.0.0.0.
    ...    4. Expert Result:
    ...       a.  L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA are same) is reported
    ...           to DEFAULT TCE for VDU
    ...       b.  TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACEDU   param_dict=${NRSTRACEDU_param_dict_3}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Attach single UE   ue_index=0
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba_tls}    ${dcap_alias_tls}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_tls}    host=${sba_host_tls}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba_tls}
    Set Test Variable  ${dcap_alias_tls}
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Attach single UE   ue_index=${ue_index}
        Start Subscriber Trace   ue_id=${ue_id}   tce_ip=0.0.0.0   trace_depth=${trace_depth}
         ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}    trace_plmn=262:03
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    [Teardown]     TC37 Teardown

Case Postcondtion
    Disconnet UEs
    Case Postcondition for ST
*** Keywords ***

TC03 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba
    ...   traceId=ffffff
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Run Keyword And Ignore Error  Download Dcap log to local sba tls
    Run Keyword And Ignore Error  Download Dcap log to local mba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRSTRACEDU

TC04 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba
    ...   traceId=ffffff
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Run Keyword And Ignore Error  Download Dcap log to local sba tls
    Run Keyword And Ignore Error  Download Dcap log to local mba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRSTRACEDU

TC05 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba
    ...   traceId=ffffff
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cuup_tracerecords}   ${local_file_path}
    Run Keyword And Ignore Error  Download Dcap log to local sba
    Run Keyword And Ignore Error  Download Dcap log to local mba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRSTRACEDU

TC37 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba
    ...   traceId=ffffff
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Run Keyword And Ignore Error  Download Dcap log to local sba
    Run Keyword And Ignore Error  Download Dcap log to local mba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRSTRACEDU