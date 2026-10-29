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


Test Timeout    360 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource           CommonKeyword/CB012629_Common_KeyWord.robot



*** Test Cases ***
[1][1.0] WTS Precondition
         Case Precondition for ST   product_type=gnb

[TC43]CB012629-CR-A_43_Successful_deregistration_of_UEs_in_case_of_5G-CP-RT_instance_failure_AIC
    [Tags]    QC_25253       QCD_MN_RAN      QCP_RAN_VRF
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
    ...       tlsEnabled set to true,
    ...       certTypeForTLSAuth set to RSA or ECDSA for activating CB008254 "RSA & Elliptic curve certificate support for TLS",
    ...       applyDefNrTceForAllSessions set to false
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
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host_tls}  trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    Delete NRSTRACECUUP
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_3}
    FOR   ${ue_index}   IN  @{ue_index_list}
        Stop single UE  ue_index=${ue_index}
    END
    FOR   ${ue_id}    ${ue_index}    IN ZIP     ${ue_id_list}  ${ue_index_list}
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    [Teardown]     TC43 Teardown

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
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_9}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_9}
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
    Activate or Deactivate Trace Report   actPCMDReport=false   actSubscriberTraceReport=true
    [Teardown]     TC52 Teardown

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
    Add NRSTRACECUUP    param_dict=${NRSTRACECUUP_param_dict_9}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_9}
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
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=false
    [Teardown]     TC53 Teardown

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
    ...       tlsEnabled set to false
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
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_8}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_8}
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
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    [Teardown]     TC54 Teardown

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
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host_tls}  trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    Delete NRSTRACECUUP
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_9}
    FOR   ${ue_index}   IN  @{ue_index_list}
        Stop single UE  ue_index=${ue_index}
    END
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host}  trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
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
    ...       tlsEnabled set to true
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range, e.g. 1000 ms
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
    ...       a.  gNB-DU SBA trace recording session for requested UE is not started.
    ...       b.  No Records are reported to new TCE for new UE.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_8}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_8}
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
    Delete NRSTRACECUUP
    Add NRSTRACECUUP   param_dict=${NRSTRACEDU_param_dict_15}
    FOR   ${ue_index}   IN  @{ue_index_list}
        Stop single UE  ue_index=${ue_index}
    END
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host}  trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    [Teardown]     TC56 Teardown

Case Postcondtion
    Disconnet UEs
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Case Postcondition for ST

*** Keywords ***
TC43 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   start  wireshark   gnb
    sleep   30s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba  traceId=ffffff  capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check multi tracerecords   tracerecords=${duup_tracerecords}    host=mba  traceId=ffffff  capture_file_path=${local_file_path_1}
#   manuully check after add the MOC new UE strace info

TC52 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   start  wireshark   gnb
    sleep   30s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}     host=mba  traceId=ffffff  capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords   tracerecords=${duup_tracerecords}   host=mba  traceId=ffffff  capture_file_path=${local_file_path_1}
    Check no tracerecords by traceId   ${trace_id_list}  ${cuup_throughput_tracerecords}   ${local_file_path_1}
#   manully check there is no detach info for both MBA and SBA

TC53 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   start  wireshark   gnb
    sleep   30s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}     host=mba  traceId=ffffff  capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cuup_tracerecords}   ${local_file_path}
    Check multi tracerecords   tracerecords=${duup_tracerecords}   host=mba  traceId=ffffff  capture_file_path=${local_file_path_1}
    Check no tracerecords by traceId   ${trace_id_list}  ${cuup_throughput_tracerecords}   ${local_file_path_1}
#   manully check there is no detach info for both MBA and SBA

TC54 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   start  wireshark   gnb
    sleep   30s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}     host=mba  traceId=ffffff  capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check multi tracerecords   tracerecords=${duup_tracerecords}   host=mba  traceId=ffffff  capture_file_path=${local_file_path_1}
#   manully check there is no detach info for both MBA and SBA

TC55 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   start  wireshark   gnb
    sleep   30s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba  traceId=ffffff  capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check multi tracerecords   tracerecords=${duup_tracerecords}    host=mba  traceId=ffffff  capture_file_path=${local_file_path_1}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cuup_throughput_tracerecords}   ${local_file_path_1}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cuup_throughput_tracerecords}   ${local_file_path_1}

TC56 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   start  wireshark   gnb
    sleep   30s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba  traceId=ffffff  capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check multi tracerecords   tracerecords=${duup_tracerecords}    host=mba  traceId=ffffff  capture_file_path=${local_file_path_1}
    Check no tracerecords by traceId   ${trace_id_list}  ${cuup_throughput_tracerecords}   ${local_file_path_1}