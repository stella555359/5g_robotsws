*** Settings ***
Documentation
...   Author: Qin Zhixia
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: The purpose of this test is to Check CB008411

Suite Setup       Common Suite Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
#Test Teardown     Common Test Teardown For RRM

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

[TC52]CB012629-SR-A-B203_52_Successful_PCMD_SBA_trace_deactivation_in_gNB-DU_via_NRBTS.actPCMDReport_flag
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that deactivates gNB-DU SBA trace recording session after online modification of a NRBTS flag.
    ...       User scenario B203 #1
    ...       OM_GEN_SFS_TRACEMGMNT.4849
    ...    2. Preconditions :
    ...       gNB is up and running in FDD/TDD mode
    ...       Trace Session shall be able to trace SA UEs
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       TCE is DCAP, Trace Expert, 3rd party tool
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       The feature flag:
    ...       NRBTS.actPCMDReport is set to true
    ...       NRBTS.actSubscriberTraceReport is set to true
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range e.g. 1000 ms
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Set NRBTS.actPCMDReport to false.
    ...       step4: Detach UE. Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  gNB-DU SBA trace recording session for requested UE is stopped after step 3
    ...       b.  Records are not reported to TCE for affected UE.
    ...       c.  Comapring to MBA, SBA PCMD do not have UE detach related PCMD records.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_9}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
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
    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host}  trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    [Teardown]    TC52 Teardown

[TC53]CB012629-SR-A-B203_53_Successful_PCMD_SBA_trace_deactivation_in_gNB-DU_via_NRBTS.actSubscriberTrace_flag
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that deactivates gNB-DU SBA trace recording session after online modification of a NRBTS flag.
    ...       User scenario B203 #1
    ...       OM_GEN_SFS_TRACEMGMNT.4849
    ...    2. Preconditions :
    ...       gNB is up and running in FDD/TDD mode
    ...       Trace Session shall be able to trace SA UEs
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       TCE is DCAP, Trace Expert, 3rd party tool
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       The feature flag:
    ...       NRBTS.actPCMDReport is set to true
    ...       NRBTS.actSubscriberTraceReport is set to true
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range e.g. 1000 ms
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Set NRBTS.actSubscriberTrace to false.
    ...       step4: Detach UE. Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  gNB-DU SBA trace recording session for requested UE is stopped after step 3
    ...       b.  Records are not reported to TCE for affected UE.
    ...       c.  Comapring to MBA, SBA PCMD do not have UE detach related PCMD records.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_9}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
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
    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host}  trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    [Teardown]    TC53 Teardown

[TC54]CB012629-SR-A-B203_54_Successful_PCMD_SBA_trace_deactivation_in_gNB-DU_Delete_NRSTRACEDU_MOC
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that deactivates gNB-DU SBA trace recording session after online modification of a NRBTS flag.
    ...       User scenario B302 #1.2: NRSTRACEDU MOC is deleted
    ...    2. Preconditions :
    ...       gNB is up and running in FDD/TDD mode
    ...       Trace Session shall be able to trace SA UEs
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       TCE is DCAP, Trace Expert, 3rd party tool
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       The feature flag:
    ...       NRBTS.actPCMDReport is set to true
    ...       NRBTS.actSubscriberTraceReport is set to true
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to true
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range e.g. 1000 ms
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Delete NRSTRACEDU MOC via online commissioning.
    ...       step4: Detach UE. Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  gNB-DU SBA trace recording session for requested UE is stopped after step 3
    ...       b.  Records are not reported to TCE for affected UE.
    ...       c.  Comapring to MBA, SBA PCMD do not have UE detach related PCMD records.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_8}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
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
    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host_tls}  trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    [Teardown]    TC54 Teardown

[TC55]CB012629-SR-A-B203_55_Successful_PCMD_SBA_trace_deactivation_in_gNB-DU_Delete_NRSTRACEDU_MOC_TLS
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that deactivates gNB-DU SBA trace recording session after online modification of a NRBTS flag.
    ...       User scenario B302 #1.2: NRSTRACEDU MOC is deleted
    ...       OM_GEN_SFS_TRACEMGMNT.4869
    ...    2. Preconditions :
    ...       gNB is up and running in FDD/TDD mode
    ...       Trace Session shall be able to trace SA UEs
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       TCE is DCAP, Trace Expert, 3rd party tool
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to true
    ...       The feature flag:
    ...       NRBTS.actPCMDReport is set to true
    ...       NRBTS.actSubscriberTraceReport is set to true
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to true
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range e.g. 1000 ms
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3. Delete NRSTRACEDU MOC via online commissioning.
    ...       step4. NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU MOC is deleted and configured again with:
    ...       nrTcePortNumber configured,
    ...       tlsEnabled set to false,
    ...       certTypeForTLSAuth set to RSA or ECDSA for activating CB008254 "RSA & Elliptic curve certificate support for TLS",
    ...       applyDefNrTceForAllSessions set to false,
    ...       actPCMDReporting set to true.
    ...       step5.Detach UE. Check tcpdump log and Emil log.
    ...       step6.Attach UE and start data traffic.
    ...    4. Expert Result:
    ...       step5:
    ...       a.  gNB-DU SBA trace recording session for requested UE is stopped after step 3
    ...       b.  Records are not reported to TCE for affected UE.
    ...       c.  Comapring to MBA, SBA PCMD do not have UE detach related PCMD records.
    ...       step6:
    ...       a.  gNB-DU SBA trace recording session for requested UE is started.
    ...       b.  Records are reported to new TCE for new UE.
    ...       c.  Comapring to MBA, SBA have same PCMD records.
#    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_3}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba_tls}    ${dcap_alias_tls}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_tls}    host=${sba_host_tls}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba_tls}
    Set Test Variable  ${dcap_alias_tls}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias}
    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host_tls}  trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_3}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json   target_operation=delete
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_4}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
    [Teardown]     TC55 Teardown

[TC56]CB012629-SR-A-B203_56_Successful_PCMD_SBA_trace_deactivation_in_gNB-DU_Delete_Add_NRSTRACEDU_MOC
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that deactivates gNB-DU SBA trace recording session after online modification of a NRBTS flag.
    ...       User scenario B302 #1.2: NRSTRACEDU MOC is deleted
    ...       OM_GEN_SFS_TRACEMGMNT.4875
    ...    2. Preconditions :
    ...       gNB is up and running in FDD/TDD mode
    ...       Trace Session shall be able to trace SA UEs
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       TCE is DCAP, Trace Expert, 3rd party tool
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       The feature flag:
    ...       NRBTS.actPCMDReport is set to true
    ...       NRBTS.actSubscriberTraceReport is set to true
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to false
    ...       nrTcePortNumber is set
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3. Delete NRSTRACEDU MOC via online commissioning.
    ...       step4. NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU MOC is deleted and configured again with:
    ...       nrTcePortNumber configured,
    ...       tlsEnabled set to true,
    ...       certTypeForTLSAuth set to RSA or ECDSA for activating CB008254 "RSA & Elliptic curve certificate support for TLS",
    ...       applyDefNrTceForAllSessions set to false,
    ...       actPCMDReporting set to true.
    ...       step5.Detach UE. Check tcpdump log and Emil log.
    ...       step6.Attach UE and start data traffic.
    ...    4. Expert Result:
    ...       step5:
    ...       a.  gNB-DU SBA trace recording session for requested UE is stopped after step 3
    ...       b.  Records are not reported to TCE for affected UE.
    ...       c.  Comapring to MBA, SBA PCMD do not have UE detach related PCMD records.
    ...       step6:
    ...       a.  gNB-DU SBA trace recording session for requested UE is not started.
    ...       b.  No Records are reported to new TCE for new UE.
#    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_8}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
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
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias}
    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host_tls}  trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_8}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json   target_operation=delete
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_15}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
    [Teardown]    TC56 Teardown

*** Keywords ***
TC52 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Activate or Deactivate Trace Report   actPCMDReport=false   actSubscriberTraceReport=true
    Get Required Logs   start  wireshark   gnb
    sleep   60s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_9}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json   target_operation=delete
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Stop single UE  ue_index=1
    Trigger ICS With Trace Stop  ue_id=2
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba  traceId=ffffff
    Check common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}   host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${cuup_throughput_tracerecords}  host=sba   traceId=000001   capture_file_path=${local_file_path_1}
    Check emil logs for sba
    Check emil logs for mba

TC53 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=false
    Get Required Logs   start  wireshark   gnb
    sleep   60s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_9}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json   target_operation=delete
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba  traceId=ffffff
    Check common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}   host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${cuup_throughput_tracerecords}  host=sba   traceId=000001   capture_file_path=${local_file_path_1}
    Check emil logs for sba
    Check emil logs for mba

TC54 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_8}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json   target_operation=delete
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
    Get Required Logs   start  wireshark   gnb
    sleep   60s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba  traceId=ffffff
    Check common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check emil logs for sba tls
    Check emil logs for mba

TC55 Teardown
    sleep   20s
    Stop single UE  ue_index=0
    sleep   40s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   start  wireshark   gnb
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    sleep  60s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_4}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json   target_operation=delete
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
    Get Required Logs   stop_and_download   syslog   gnb
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba  traceId=ffffff
    Check common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check emil logs for sba tls
    Check emil logs for mba
    sleep   300s
    Check emil logs for sba tls   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba   tracerecords=${emil_duup_tracerecords}
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1

TC56 Teardown
    sleep   20s
    Stop single UE  ue_index=0
    sleep   40s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   start  wireshark   gnb
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    sleep  60s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Modify json file value    param_dict=${NRSTRACECUUP_param_dict_4}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json   target_operation=delete
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba  traceId=ffffff
    Check common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${cuup_throughput_tracerecords}  host=sba   traceId=000001   capture_file_path=${local_file_path_1}
    Check emil logs for sba tls
    Check emil logs for mba





