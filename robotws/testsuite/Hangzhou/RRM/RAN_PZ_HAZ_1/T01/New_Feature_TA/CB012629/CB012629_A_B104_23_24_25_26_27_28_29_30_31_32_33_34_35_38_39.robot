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

[TC23]CB012629-SR-A-B104_23_Successful_gNB-DU_SBA_trace_activation_via_F1AP_Trace_Start
    [Tags]    QC_25194       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace
    ...       recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       User scenario B104 #1;OM_GEN_SFS_TRACEMGMNT.4872     USCB012629-A#IWK1-ALT1
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
    ...       step1. UE1 is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Trace Start command works on Core Simulator.
    ...       step4. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       F1AP: TraceStart contains TraceActivate IE same as configured in core simulator.
    ...       L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE
    ...       TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
    Start Subscriber Trace   ue_id=1    tce_ip=${sba_host}  trace_depth=maximum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Start Subscriber Trace   ue_id=2   tce_ip=${sba_host}   trace_depth=med_without_vse
    ...   trace_ref_id=2  trace_rec_session_ref_id=2    trace_plmn=262:03
    [Teardown]     TC23 Teardown

[TC24]CB012629-SR-A-B104_24_Failed_activation_of_the_Subscriber_Trace_for_gNB-DU_due_to_deactivated_NRBTS-actPCMDReport
    [Tags]    QC_25195       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that gNB-DU could not start SBA TRS due to detactivated actPCMDReport.
    ...       OM_GEN_SFS_TRACEMGMNT.4848
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport is set to false.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...    3. Test Case Steps:
    ...       step1. UE1 is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE and start data traffic.
    ...       step3. In core simulator, start SBA Trace via Trace Start command for UE1.
    ...       step4. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       F1AP: UE CONTEXT SETUP REQUEST does contain TraceActivate IE
    ...       SBA TRS is not started.
    ...       SBA PCMD records are not visible for gNB-DU.
    ...       MBA PCMD records are not visible for gNB-DU.
    Activate or Deactivate Trace Report   actPCMDReport=false   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Start Subscriber Trace   ue_id=1    tce_ip=${sba_host}  trace_depth=maximum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Start Subscriber Trace   ue_id=2   tce_ip=${sba_host}   trace_depth=med_without_vse
    ...   trace_ref_id=2  trace_rec_session_ref_id=2    trace_plmn=262:03
    [Teardown]     TC24 Teardown

[TC25]CB012629-SR-A-B104_25_Successful_gNB-DU_SBA_trace_activation_via_Trace_Start_Configuration_Validation_Failure
    [Tags]    QC_25196       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       5G_RAN_USR_COM_22977
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
    ...       step1. UE1/UE2 is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and UE2 and start data traffic.
    ...       step3. In core simulator, start SBA Trace via Trace Start command for UE1.
    ...       step4. In core simulator, start SBA Trace via Trace Start command for UE2,
    ...       with same TRID( RAN Trace ID (Trace Reference + Trace Recording Session Reference Number) as UE1.
    ...    4. Expert Result:
    ...       L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE for UE1.
    ...       TRS session is not started for UE2, due to validation failure.
    ...       TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Start Subscriber Trace   ue_id=1    tce_ip=${sba_host}  trace_depth=maximum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Start Subscriber Trace   ue_id=2   tce_ip=${sba_host}   trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1    trace_plmn=262:03
    [Teardown]     TC25 Teardown

[TC26]CB012629-SR-A-B104_26_Successful_gNB-DU_SBA_trace_activation_via_Trace_Start_Configuration_Validation_Failure2
    [Tags]    QC_25197       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       5G_RAN_USR_COM_22977
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
    ...       step1. UE1 is not configured in Core Simulator to support SBA.
    ...       step2. In core simulator, start SBA Trace via Trace Start command for UE1.
    ...       step3. In core simulator, start SBA Trace via Trace Start command for UE1
    ...       with same TRID( RAN Trace ID (Trace Reference + Trace Recording Session Reference Number) as step 2.
    ...    4. Expert Result:
    ...       1. F1AP: TraceStart contains TraceActivate IE same as configured in core simulator for UE1 in step 2 and step 3.
    ...       2. L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE for UE1.
    ...       3. session is not started for step3, as there is acivated TRS session already via step 2.
    ...       4. TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Start Subscriber Trace   ue_id=1    tce_ip=${sba_host}  trace_depth=maximum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Start Subscriber Trace   ue_id=1  tce_ip=${sba_host}   trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1    trace_plmn=262:03
    [Teardown]     TC26 Teardown

[TC27]CB012629-SR-A-B104_27_Successful_gNB-DU_SBA_trace_activation_via_Trace_Start_Configuration_Validation_Failure_Recovery
    [Tags]    QC_25198       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       5G_RAN_USR_COM_22977
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
    ...       step1. UE1 is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3. In core simulator, start SBA Trace via Trace Start command for UE1
    ...       step4. In core simulator, start SBA Trace via Trace Start command for UE1
    ...       with same TRID( RAN Trace ID (Trace Reference + Trace Recording Session Reference Number) as step 3.
    ...       step5: In core simulator, Clear SBA Trace configuration via Trace Stop command for UE1. And start Trace again.
    ...       step6: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. F1AP: TraceStart contains TraceActivate IE same as configured in core simulator for UE1 in step 3 and step 4.
    ...       2. L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE for UE1.
    ...       3. TRS session is  started for step5, as there is acivated TRS session already via step 3.
    ...       4. TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Start Subscriber Trace   ue_id=1    tce_ip=${sba_host}  trace_depth=maximum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Start Subscriber Trace   ue_id=1  tce_ip=${sba_host}   trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1    trace_plmn=262:03
    Stop Subscriber Trace  ue_id=1  trace_plmn=262:03  trace_rec_session_ref_id=1  trace_ref_id=1
    Trigger ICS With Trace Stop  ue_id=1
    Start Subscriber Trace   ue_id=1    tce_ip=${sba_host}  trace_depth=medium
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    [Teardown]     TC27 Teardown

[TC28]CB012629-SR-A-B104_28_Successful_gNB-DU_SBA_trace_activation_via_ICS_Configuration_Validation_Failure
    [Tags]    QC_25199       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       5G_RAN_USR_COM_22977
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
    ...       step1. UE1 is configured in Core Simulator to support SBA.
    ...       UE2 is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and UE2 and start data traffic.
    ...       step3. In core simulator, start SBA Trace via Trace Start command for UE2,
    ...       with same TRID( RAN Trace ID (Trace Reference + Trace Recording Session Reference Number) as UE1.
    ...       step4: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. F1AP: TraceStart contains TraceActivate IE same as configured in core simulator for UE1 in step 4.
    ...       2. L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE for UE1.
    ...       3. TRS session is not started for step3, as there is acivated TRS session already via step 3.
    ...       4. TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Trigger ICS With Trace Start   ue_id=1    tce_ip=${sba_host}  trace_depth=maximum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
    Start Subscriber Trace   ue_id=2  tce_ip=${sba_host}   trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1    trace_plmn=262:03
    [Teardown]     TC28 Teardown

[TC29]CB012629-SR-A-B104_29_Successful_gNB-DU_SBA_trace_activation_ICS_Trace_Start_Configuration_Validation_Failure2
    [Tags]    QC_25200       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       5G_RAN_USR_COM_22977
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
    ...       step1. UE1 is configured in Core Simulator to support SBA..
    ...       step2. Attach UE1 and start data traffic.
    ...       step3.In core simulator, start SBA Trace via Trace Start command for UE1,
    ...       with same TRID( RAN Trace ID (Trace Reference + Trace Recording Session Reference Number) as ICS setup.
    ...       step4: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. F1AP: TraceStart contains TraceActivate IE same as configured in core simulator for UE1 in step 4.
    ...       2. L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE for UE1.
    ...       3. TRS session is not started for step3, as there is acivated TRS session already via step 3.
    ...       4. TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Trigger ICS With Trace Start   ue_id=1    tce_ip=${sba_host}  trace_depth=maximum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
    Start Subscriber Trace   ue_id=1  tce_ip=${sba_host}   trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1    trace_plmn=262:03
    [Teardown]     TC29 Teardown

[TC30]CB012629-SR-A-B104_30_TCP_connection_interruption_and_recovery_towards_default_TCE
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that  PCMD content in scope of gNB-DU SBA trace recording session is reported to default TCE.
    ...       User scenario B104 #1.2;CB_FIM_4758
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
    ...       applyDefNrTceForAllSessions set to true
    ...       maxBufferingTime configured 50 ms
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3. Interrupt TCP connection to default TCE.
    ...       step4: Recover TCP connection to default TCE.
    ...       step5: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. The fault ID "8000: EFaultId TraceConnectionFailAl" is raised;
    ...          Additional alarm information for Fault 8000 contains distinguished name of NRSTRACEDU-1 MOC.
    ...       b. PCMD content in scope of DU SBA trace recording session was reported to default TCE without TLS
    ...       c. Connection was recovered and fault was cleared
    ...       d. DU SBA Trace Recording Session is active
    ...       e. TCC sends NSETAP-X: TraceMessage.isAlive notifications to default TCE periodically
    ...       f. F1AP: UE CONTEXT SETUP REQUEST contains TraceActivate IE same as configured in core simulator.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Trigger ICS With Trace Start   ue_id=1    tce_ip=${sba_host}  trace_depth=medium
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Trigger ICS With Trace Start   ue_id=2  tce_ip=${sba_host}  trace_depth=med_without_vse
    ...   trace_ref_id=2  trace_rec_session_ref_id=2   trace_plmn=262:03
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
  [Teardown]     TC30 Teardown

[TC31]CB012629-SR-A-B104_31_TCP_connection_failure_recovery_towards_non_default_TCE
    [Tags]    QC_25202       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that  PCMD content in scope of gNB-DU SBA trace recording session is reported to default TCE.
    ...       OM_GEN_SFS_TRACEMGMNT.4873
    ...       B104 #1.2: TCP connection interruption and recovery towards default TCE
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
    ...       step1. UE is  configured in Core Simulator to support SBA to non-default TCE, which has TCE connection error with gNB-DU.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3. Use TraceStart command from Core Simulator to valid TCE.
    ...       step4: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. PCMD content in scope of DU SBA trace recording session was reported to default TCE without TLS
    ...       b. PDU SBA Trace Recording Session is active
    ...       c. TCC sends NSETAP-X: TraceMessage.isAlive notifications to default TCE periodically
    ...       d. F1AP: UE CONTEXT SETUP REQUEST contains TraceActivate IE same as configured in core simulator.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Trigger ICS With Trace Start   ue_id=1    tce_ip=10.101.2.23  trace_depth=maximum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Stop Subscriber Trace  ue_id=1  trace_plmn=262:03  trace_rec_session_ref_id=1  trace_ref_id=1
    Trigger ICS With Trace Stop  ue_id=1
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Start Subscriber Trace   ue_id=1   tce_ip=${sba_host}   trace_depth=medium
    ...   trace_ref_id=31  trace_rec_session_ref_id=31    trace_plmn=262:03
    [Teardown]     TC31 Teardown

[TC32]CB012629-SR-A-B104_32_TCP_connection_failure_recovery_towards_non_default_TCE_TLS
    [Tags]    QC_25203       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that  PCMD content in scope of gNB-DU SBA trace recording session is reported to default TCE.
    ...       OM_GEN_SFS_TRACEMGMNT.4867
    ...        B104 #1.2: TCP connection interruption and recovery towards default TCE
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
    ...       step1. UE is configured in Core Simulator to support SBA to non-default TCE, which has TCE connection error with gNB-DU.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3. Use TraceStart command from Core Simulator to valid TCE.
    ...       step4: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. PCMD content in scope of DU SBA trace recording session was reported to default TCE without TLS
    ...       b. PDU SBA Trace Recording Session is active
    ...       c. TCC sends NSETAP-X: TraceMessage.isAlive notifications to default TCE periodically
    ...       d. F1AP: UE CONTEXT SETUP REQUEST contains TraceActivate IE same as configured in core simulator.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_3}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_3}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Trigger ICS With Trace Start   ue_id=1    tce_ip=10.101.2.23  trace_depth=maximum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Stop Subscriber Trace  ue_id=1  trace_plmn=262:03  trace_rec_session_ref_id=1  trace_ref_id=1
    Trigger ICS With Trace Stop  ue_id=1
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba_tls}    ${dcap_alias_tls}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_tls}    host=${sba_host_tls}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba_tls}
    Set Test Variable  ${dcap_alias_tls}
    Start Subscriber Trace   ue_id=1   tce_ip=${sba_host_tls}   trace_depth=medium
    ...   trace_ref_id=32  trace_rec_session_ref_id=32    trace_plmn=262:03
    [Teardown]     TC32 Teardown

[TC34]CB012629-SR-A-B104_34_Successful_gNB-DU_SBA_trace_activation_applyDefNrTceForAllSessions_True_TLS
    [Tags]    QC_25205       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that  PCMD content in scope of gNB-DU SBA trace recording session is reported to non-default TCE.
    ...       OM_GEN_SFS_TRACEMGMNT.4859;OM_GEN_SFS_TRACEMGMNT.4860
    ...       User scenario B104 #2: Activation of the Subscriber Trace with PCMD content related to C012629-A with default TCE applied
    ...       for all trace recording sessions via
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       TCE is configured under MNL.TCEADM.TCE MOC, e.g.:
    ...        nrTcePortNumber is set
    ...        tlsEnabled set to false
    ...       The feature flag NRBTS-actPCMDReport is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to true
    ...       applyDefNrTceForAllSessions set to true
    ...       maxBufferingTime configured 50 ms
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA with non-default TCE IP.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  PCMD content in scope of gNB-DU SBA trace recording session is reported to default TCE in scope of
    ...       every gNB-DU SBA trace recording session
    ...       b. NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU parameters (nrTcePortNumber, tlsEnabled) are not used.
    ...       Instead MNL.TCEADM.TCE MOC parameters are taken into consideration while opening the connection to a default TCE.
    ...       c. TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    ...       d. F1AP: UE CONTEXT SETUP REQUEST contains TraceActivate IE same as configured in core simulator.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_5}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_5}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Trigger ICS With Trace Start   ue_id=1    tce_ip=${sba_host_tls}  trace_depth=maximum
    ...   trace_ref_id=34  trace_rec_session_ref_id=34   trace_plmn=262:03
    Attach single UE   ue_index=0
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    [Teardown]     TC34 Teardown

[TC35]CB012629-SR-A-B104_35_Successful_gNB-DU_SBA_trace_activation_non-default_TCE_TLS
    [Tags]    QC_25206       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace recording
    ...       session to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       User scenario B104 #3; OM_GEN_SFS_TRACEMGMNT.4860
    ...       User scenario B104 #3: Activation of the Subscriber Trace with PCMD content related to CB012629-A to
    ...       non-default TCE with TLS via TC_NrAppAllocateTrsInd
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       TCE is configured under MNL.TCEADM.TCE MOC, e.g.:
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
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
    ...       step1. UE is configured in Core Simulator to support SBA with non-default TCE IP.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  PCMD content in scope of gNB-DU SBA trace recording session is reported to non-default TCE
    ...       b.  TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    ...       c.  F1AP: UE CONTEXT SETUP REQUEST contains TraceActivate IE same as configured in core simulator.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_12}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_12}
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
    Trigger ICS With Trace Start   ue_id=1    tce_ip=${sba_host_tls}  trace_depth=maximum
    ...   trace_ref_id=35  trace_rec_session_ref_id=35   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    [Teardown]     TC35 Teardown

[TC38]CB012629-SR-A-B104_38_Configuration_mismatch_between_TLS_configuration_of_separate_NRSTRACE_MOCs
    [Tags]    QC_25209       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller behaves accordingly to NIDD configuration in case it was misconfigured.
    ...       UUser scenario B104 #4
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       TCE3 is configured as:
    ...       TCE.tceId=3
    ...       TCE.tlsEnabled=false
    ...       TCE2 is configured as:
    ...       TCE.tceId=2
    ...       TCE.tlsEnabled=true
    ...       The feature flag NRBTS-actPCMDReport is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRCTRLTS.NRSTRACECU
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured TCE2
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to true, RSA certificate shall be used
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range, e.g. 50 ms
    ...       NRBTS.NRCUUP.NRCTRLTSCUUP.NRSTRACECUUP
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured TCE3
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false, RSA certificate shall be used
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range, e.g. 150 ms
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured TCE3
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false, RSA certificate shall be used
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range, e.g. 1500 ms
    ...    3. Test Case Steps:
    ...       step1. UE is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Trigger SBA TRS start via Trace Start command from Core Simulator to TCE-3.
    ...    4. Expert Result:
    ...       a.  SBA trace recording session was opened only on appropriately configure nodes: gNB-CU-UP and gNB-DU
    ...       b.  gNB-CU-CP SBA trace recording session was not started
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECU  param_dict=${NRSTRACECU_param_dict_1}
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_6}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_6}
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    ${log_collection_end_time_sba_tls}    ${dcap_alias_tls}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_tls}    host=${sba_host_tls}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Set Test Variable  ${log_collection_end_time_sba_tls}
    Set Test Variable  ${dcap_alias_tls}
    Start Subscriber Trace   ue_id=1   tce_ip=${sba_host}   trace_depth=maximum
    ...   trace_ref_id=38  trace_rec_session_ref_id=38    trace_plmn=262:03
    Start attenuator  value1=${30}  value9=${30}
    [Teardown]     TC38 Teardown

[TC39]CB012629-SR-A-B104_39_Configuration_mismatch_between_TLS_configuration_of_separate_NRSTRACExx_MOCs_TLS_TCE
    [Tags]    QC_25210       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller behaves accordingly to NIDD configuration in case
    ...      it was misconfigured, with TCE of TLS connection
    ...       UUser scenario B104 #4
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       TCE2 is configured as:
    ...       TCE.tceId=2
    ...       TCE.tlsEnabled=true
    ...       TCE3 is configured as:
    ...       TCE.tceId=3
    ...       TCE.tlsEnabled=false
    ...       The feature flag NRBTS-actPCMDReport is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRCTRLTS.NRSTRACECU
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured TCE2
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to true, RSA certificate shall be used
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range, e.g. 50 ms
    ...       NRBTS.NRCUUP.NRCTRLTSCUUP.NRSTRACECUUP
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured TCE3
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false, RSA certificate shall be used
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range, e.g. 150 ms
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured TCE3
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false, RSA certificate shall be used
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range, e.g. 1500 ms
    ...    3. Test Case Steps:
    ...       step1. UE is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Trigger SBA TRS start via Trace Start command from Core Simulator to TCE-2
    ...    4. Expert Result:
    ...       a.  SBA trace recording session was opened only on appropriately configure nodes: gNB-CU-CP
    ...       b.  gNB-CU-UP and gNB-DU SBA trace recording session was not started
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECU  param_dict=${NRSTRACECU_param_dict_1}
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_6}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_6}
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    ${log_collection_end_time_sba_tls}    ${dcap_alias_tls}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_tls}    host=${sba_host_tls}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Set Test Variable  ${log_collection_end_time_sba_tls}
    Set Test Variable  ${dcap_alias_tls}
    Start Subscriber Trace   ue_id=1   tce_ip=${sba_host_tls}   trace_depth=medium
    ...   trace_ref_id=39  trace_rec_session_ref_id=39    trace_plmn=262:03
    Start attenuator  value1=${30}  value9=${30}
    [Teardown]     TC39 Teardown

[TC33]CB012629-SR-A-B104_33_TCP_connection_failure_recovery_towards_non_default_TCE_TLS_Conflicts_MOCs
    [Tags]    QC_25204       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that  PCMD content in scope of gNB-DU SBA trace recording session is reported to default TCE.
    ...       OM_GEN_SFS_TRACEMGMNT.4867;
    ...       B104 #1.2: TCP connection interruption and recovery towards default TCE
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
    ...       step1. UE is configured in Core Simulator to support SBA to non-default TCE, which has TCE connection error with gNB-DU.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3. Configure NRSTRACEDU/NRSTRACECU/NRSTRACECUUP with conflicts configuration for default TCEs(covering TLS/NON-TLS)
    ...       these TCEs all have TCP connection problem.
    ...       step4: Delete NRSTRACE*.
    ...    4. Expert Result:
    ...       a. The fault ID "8000: EFaultId TraceConnectionFailAl" is raised and cleared as TRS is deleted soon for non-Default TCE.
    ...       b. The fault ID "8000: EFaultId TraceConnectionFailAl" is raised for each TCE with all MOCs as CNI-103630.
    ...       c. All fault ID 8000 are cleared.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add A TCE
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_16}
    Add NRSTRACECU  param_dict=${NRSTRACECU_param_dict_4}
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_16}
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Trigger ICS With Trace Start   ue_id=1    tce_ip=10.101.2.23  trace_depth=maximum
    ...   trace_ref_id=33  trace_rec_session_ref_id=65535   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    [Teardown]     TC33 Teardown

Case Postcondtion
    Disconnet UEs
    Case Precondition for ST   product_type=gnb
*** Keywords ***

TC23 Teardown
    sleep   30s
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path}
    Check multi tracerecords by DCAP IP    tracerecords=${cuup_throughput_tracerecords}  dcap_ip=${sba_host}   traceId=000001
    ...    capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_med_without_vse}   capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${cuup_throughput_tracerecords}  host=sba   traceId=000002   capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba

TC24 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check no tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_med_without_vse}   capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${cuup_throughput_tracerecords}  host=sba   traceId=000001   capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${cuup_throughput_tracerecords}  host=sba   traceId=000002   capture_file_path=${local_file_path}

TC25 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path}
    Check multi tracerecords by DCAP IP    tracerecords=${cuup_throughput_tracerecords}  dcap_ip=${sba_host}   traceId=000001
    ...    capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba
#   need check manully no record for UE2
TC26 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path}
    Check multi tracerecords by DCAP IP    tracerecords=${cuup_throughput_tracerecords}  dcap_ip=${sba_host}   traceId=000001
    ...    capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check no common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${cuup_throughput_tracerecords}  host=sba   traceId=000002   capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba

TC27 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path}
    Check multi tracerecords by DCAP IP    tracerecords=${cuup_throughput_tracerecords}  dcap_ip=${sba_host}   traceId=000001
    ...    capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check no common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_medium}  capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${cuup_throughput_tracerecords}  host=sba   traceId=000002   capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba
#   need check emil after trace start recovery

TC28 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Stop single UE  ue_index=1
    Trigger ICS With Trace Stop  ue_id=2
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}   host=sba   traceId=000001  capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba

TC29 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Stop single UE  ue_index=1
    Trigger ICS With Trace Stop  ue_id=2
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check no common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_throughput_tracerecords}   host=sba   traceId=000001  capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba

TC30 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    TCE server action  ${sudo_password}    dcap_server_ssh_info=${dcap_server_sba}    dcap_action=-I
    ...    tce_host=${sba_host}
    sleep  60s
    TCE server action  ${sudo_password}    dcap_server_ssh_info=${dcap_server_sba}    dcap_action=-D
    ...    tce_host=${sba_host}
    Get Required Logs   start  wireshark   gnb
    sleep  60s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Stop single UE  ue_index=1
    Trigger ICS With Trace Stop  ue_id=2
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba  traceId=ffffff
    Check common tracerecords  tracerecords=${f1ap_trace_activate_medium}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_med_without_vse}   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}   host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${cuup_tracerecords}  host=sba   traceId=000002   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${duup_tracerecords}   capture_file_path=${local_file_path}   host=mba  traceId=ffffff
    Check multi tracerecords   tracerecords=${cuup_throughput_tracerecords}   host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${cuup_throughput_tracerecords}  host=sba   traceId=000002   capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba
    # need manual check emil PCMD reocords still alive after tcp recovery

TC31 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path}
    Check multi tracerecords by DCAP IP    tracerecords=${cuup_throughput_tracerecords}  dcap_ip=${sba_host}   traceId=00001F
    ...    capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_medium}   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_throughput_tracerecords}   host=sba   traceId=00001f  capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba

TC32 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba   traceId=ffffff
    Check common tracerecords  tracerecords=${f1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_medium}   capture_file_path=${local_file_path}
    Check emil logs for sba tls   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba

TC34 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}  host=mba  traceId=ffffff  capture_file_path=${local_file_path}
    Check multi tracerecords by DCAP IP    tracerecords=${cuup_tracerecords}  dcap_ip=${sba_host}   traceId=000022
    ...    capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check emil logs for sba
    Check emil logs for mba

TC35 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba  traceId=ffffff
    Check common tracerecords  tracerecords=${f1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check emil logs for sba tls   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba

TC38 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECU
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Start attenuator  value1=${0}  value9=${0}
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords by DCAP IP    tracerecords=${cuup_throughput_tracerecords}  dcap_ip=${sba_host}   traceId=000026
    ...    capture_file_path=${local_file_path}
    Check no common tracerecords    tracerecords=${cucp_mea_tracerecords}   capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cuup_throughput_tracerecords}

TC39 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECU
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Start attenuator  value1=${0}  value9=${0}
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check no tracerecords     tracerecords=${cuup_throughput_tracerecords}  host=sba   traceId=000027   capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${duup_tracerecords}  host=sba   traceId=000027  capture_file_path=${local_file_path}
    Check common tracerecords    tracerecords=${alive}   capture_file_path=${local_file_path}
    Check emil logs for sba tls   tracerecords=${emil_cucp_mea_tracerecords}

TC33 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Stop single UE
    Get Required Logs   stop_and_download   syslog   gnb
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Delete NRSTRACECU
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Delete A TCE