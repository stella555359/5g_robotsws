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

[TC63]CB012629-SR-A_63_Online_Activation_of_SBA_with_PCMD_content_for_gNB-DU
    [Tags]    QC_25240       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace recording
    ...       session to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message
    ...       OM_GEN_SFS_TRACEMGMNT.4843
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport for activating PCMD functionalityis set to false.
    ...       The feature flag NRBTS-actSubscriberTraceReport for activating Subscriber trace functionalityis set to false.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA in ICS for DU with default TCE.
    ...              The feature flag NRBTS-actPCMDReport is set to true.
    ...              The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...              Try all the error configuration for PDL rules.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Detach UE. Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA are same) is reported to TCE for VDU
    ...       b.  In tcpdump, there is  NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=false   actSubscriberTraceReport=false
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
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
    Trigger ICS With Trace Start   ue_id=1    tce_ip=${sba_host}  trace_depth=medium
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Trigger ICS With Trace Start   ue_id=2  tce_ip=${sba_host}  trace_depth=med_without_vse
    ...   trace_ref_id=2  trace_rec_session_ref_id=2   trace_plmn=262:03
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
  [Teardown]     TC63 Teardown

[TC66]CB012629-SR-A_66_Activation_of_SBA_with_PCMD_content_for_gNB-DU_TCE_NRSTRACEDU_Conflicts_TLS
    [Tags]    QC_25242       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that default TCE's configuration will be used when TCE and NRSTRACEDU has configuration conflicts.
    ...       OM_GEN_SFS_TRACEMGMNT.4843
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport for activating PCMD functionality is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport for activating Subscriber trace functionality is set to true
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA in ICS for DU with default TCE.
    ...              Online add below MOCs:
    ...              NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...              actPCMDReporting is set to true
    ...              defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...              nrTcePortNumber is set
    ...              tlsEnabled set to true
    ...              applyDefNrTceForAllSessions set to false
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Detach UE. Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA are same) is reported to TCE
    ...       b.  In tcpdump, there is  NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRMTRACECU    param_dict=${NRMTRACECU_param_dict_1}
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_12}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_12}
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
    Trigger ICS With Trace Start   ue_id=1    tce_ip=${sba_host}  trace_depth=medium
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
#   modify steps:
    [Teardown]     TC66 Teardown

[TC69]CB012629-SR-A_69_Activation_of_SBA_with_PCMD_content_for_gNB-DU-InterfacesToTraces_No_F1_E1
    [Tags]    QC_25246       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. TThis user scenario validates that BTS Trace Controller configures and starts SBA based PCMD for
    ...       gNB-DU/cuup even when the interfaces to trace does not contain F1/E1 and not 0.
    ...       5G_RAN_USR_COM_22981
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport for activating PCMD functionality is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport for activating Subscriber trace functionality is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...       NRBTS/NRCTRLTS/NRSTRACECU/actPCMDReporting set to TRUE
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/actPCMDReporting set to TRUE.
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/defaultNrTceIdentifier set to existing TCE.tceIdentifier.
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA in ICS for with InterfacesToTraces as NGAP or
    ...       other interface, without F1/F1.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Detach UE. Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.   L2 and L3 PCMD content in scope of gNB-DU/CUUP trace recording session for SBA is reported to TCE
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECU    param_dict=${NRSTRACECU_param_dict_2}
    Add NRSTRACECUUP    param_dict=${NRSTRACECUUP_param_dict_4}
#    Add NRSTRACEDU    param_dict=${NRSTRACEDU_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
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
    Trigger ICS With Trace Start   ue_id=1    tce_ip=${sba_host}  trace_depth=medium  ifaces_to_trace=Uu,NG-C,Xn-C
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
     Trigger ICS With Trace Start   ue_id=2    tce_ip=${sba_host}  trace_depth=med_without_vse  ifaces_to_trace=Uu,NG-C,Xn-C
    ...   trace_ref_id=2  trace_rec_session_ref_id=2   trace_plmn=262:03
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
    [Teardown]    TC69 Teardown

[TC70]CB012629-SR-A_70_Activation_of_SBA_with_PCMD_content_for_gNB-DU_CA
    [Tags]    QC_25247       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that gNB-CU SBA PCMD record could report same as MBA.
    ...       5G_TC_826	    DU CA Configuration Record
    ...       5G_TC_1391	CA Downlink Scheduling Trace Record
    ...       5G_TC_1405	CA Uplink Scheduling Trace Record
    ...       5G_TC_2359	CA Beam Usage Trace Record
    ...       5G_TC_2595	CA Channel State Information Report Trace Record
    ...       5G_TC_2615	CA Beam Report Trace Record
    ...       5G_TC_2623	CA Power Headroom Trace Record
    ...       5G_TC_2384	CA Downlink Radio Bearer RLC Measurement Trace Record
    ...       5G_TC_2394	CA Uplink Radio Bearer RLC Measurement Trace Record
    ...       5G_TC_2662	Direction of Arrival Trace Record
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
    ...       NRBTS/NRCTRLTS/NRSTRACECU/actPCMDReporting set to TRUE
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/actPCMDReporting set to TRUE.
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/defaultNrTceIdentifier set to existing TCE.tceIdentifier.
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA in ICS for with InterfacesToTraces as 0/
    ...       Interfaces containg F1.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. L2 and L3 PCMD content in scope of gNB-DU trace recording session for SBA is reported to TCE
    ...       At least below records should be checked between SBA and MBA and having same content.
    ...       5G_TC_826	    DU CA Configuration Record
    ...       5G_TC_1391	CA Downlink Scheduling Trace Record
    ...       5G_TC_1405	CA Uplink Scheduling Trace Record
    ...       5G_TC_2359	CA Beam Usage Trace Record
    ...       5G_TC_2595	CA Channel State Information Report Trace Record
    ...       5G_TC_2615	CA Beam Report Trace Record
    ...       5G_TC_2623	CA Power Headroom Trace Record
    ...       5G_TC_2384	CA Downlink Radio Bearer RLC Measurement Trace Record
    ...       5G_TC_2394	CA Uplink Radio Bearer RLC Measurement Trace Record
    ...       5G_TC_2662	Direction of Arrival Trace Record
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACECU   param_dict=${NRSTRACECU_param_dict_2}
    Add NRSTRACECUUP    param_dict=${NRSTRACECUUP_param_dict_4}
#    Add NRSTRACEDU    param_dict=${NRSTRACEDU_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
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
    Start attenuator   value5=${0}  value6=${0}  value13=${10}   value14=${10}
    Trigger ICS With Trace Start   ue_id=5    tce_ip=${sba_host}  trace_depth=medium  ifaces_to_trace=0
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=4
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=4
     Trigger ICS With Trace Start   ue_id=6    tce_ip=${sba_host}  trace_depth=med_without_vse  ifaces_to_trace=0
    ...   trace_ref_id=2  trace_rec_session_ref_id=2   trace_plmn=262:03
    Attach single UE   ue_index=5
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=5
    [Teardown]    TC70 Teardown

Case Postcondtion
    Disconnet UEs
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Case Postcondition for ST

*** Keywords ***
TC63 Teardown
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
    Check common tracerecords  tracerecords=${f1ap_trace_activate_medium}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_med_without_vse}   capture_file_path=${local_file_path}
    Check multi tracerecords     tracerecords=${cuup_tracerecords}  host=sba   traceId=000001   capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${cuup_tracerecords}  host=sba   traceId=000002   capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cuup_tracerecords}
    Check emil logs for mba

TC66 Teardown
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRMTRACECU
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_medium}   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}   host=sba   traceId=000001  capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cuup_tracerecords}
    Check emil logs for mba

TC69 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECU
    Delete NRSTRACECUUP
#    Delete NRSTRACEDU
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Stop single UE  ue_index=1
    Trigger ICS With Trace Stop  ue_id=2
    Check common tracerecords  tracerecords=${f1ap_trace_activate_medium}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_med_without_vse}   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}   host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check no tracerecords      tracerecords=${cuup_tracerecords}  host=sba   traceId=000002   capture_file_path=${local_file_path}
#    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check no tracerecords      tracerecords=${ducp_duup_tracerecords}  host=sba   traceId=000002   capture_file_path=${local_file_path}
    Check emil logs for sba    tracerecords=${emil_cuup_tracerecords}
    Check emil logs for mba    tracerecords=${emil_ducp_duup_tracerecords}

TC70 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECU
    Delete NRSTRACECUUP
#    Delete NRSTRACEDU
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=4
    Trigger ICS With Trace Stop  ue_id=5
    Stop single UE  ue_index=5
    Trigger ICS With Trace Stop  ue_id=6
    Check common tracerecords  tracerecords=${f1ap_trace_activate_medium}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_med_without_vse}   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}   host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check no tracerecords      tracerecords=${cuup_tracerecords}  host=sba   traceId=000002   capture_file_path=${local_file_path}
#    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check no tracerecords      tracerecords=${ducp_duup_tracerecords}  host=sba   traceId=000002   capture_file_path=${local_file_path}
#    Check emil logs for sba    tracerecords=${emil_ca_tracerecords}
#    Check emil logs for mba    tracerecords=${emil_ca_tracerecords}
    Check emil logs for sba
    Check emil logs for mba
    Start attenuator   value5=${10}  value6=${10}  value13=${20}   value14=${20}




