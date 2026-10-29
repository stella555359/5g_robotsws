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

[TC40]CB012629-SR-A-B201_40_Successful_PCMD_SBA_trace_deactivation_in_gNB-DU
    [Tags]    QC_25211       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller do not start gNB-DU SBA trace recording session
    ...       and do not report tracing data towards TCE when UE call was terminated before connection to TCE was fully established.
    ...       User scenario B201 #1;5G_RAN_USR_COM_22976
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
    ...       tlsEnabled set to true,ECDSA certificate shall be used
    ...       applyDefNrTceForAllSessions set to false
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  NSETAP-X: TraceMessage.Stop Recording Session is sent to TCE
    ...       b.  All trace recording session for an UE are stopped (MBA & SBA)
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACEDU  param_dict=${NRSTRACECUUP_param_dict_6}
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
    ...   trace_ref_id=16777215  trace_rec_session_ref_id=65535   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Trigger ICS With Trace Start   ue_id=2  tce_ip=${sba_host}  trace_depth=min_without_vse
    ...   trace_ref_id=2  trace_rec_session_ref_id=2   trace_plmn=262:03
    Attach single UE   ue_index=1
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=1
    Stop single UE  ue_index=0
    Stop single UE  ue_index=1
    [Teardown]     TC40 Teardown

[TC46]CB012629-SR-A-B201_46_Successful_TRS_Stop_Cell_Block
    [Tags]    QC_25215       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller successfully cleares intenal resources during
    ...       resource deregistration
    ...       User scenario B201 #4
    ...       5G_RAN_USR_COM_22979
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
    ...       NRBTS.NRCTRLTS.NRMTRACECU configured with following parameters:
    ...       TceId is set
    ...       actPCMDReporting is set to true
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Block cell, which is UE attached to.
    ...       step4: Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  Cell is blocked.
    ...       b.  gNB-DU trace sessions are unaffected
    ...       c.  Stop Recording Session(s) were indicated to TCE
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRMTRACECU
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_2}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host}  trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1  trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    BTS Operation  operation=cell_block  product_type=gnb  bts_index=0  distname_id=NRCELL-1  need_verify=yes
    BTS Operation  operation=cell_block  product_type=gnb  bts_index=0  distname_id=NRCELL-2  need_verify=yes
    [Teardown]    TC46 Teardown

[TC50]CB012629-SR-A-B201_50_Successful_TRS_Stop_Cell_Delete
    [Tags]    QC_25216       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller successfully cleares intenal resources during
    ...       resource deregistration
    ...       User scenario B201 #4
    ...       5G_RAN_USR_COM_22979
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
    ...       NRBTS.NRCTRLTS.NRMTRACECU configured with following parameters:
    ...       TceId is set
    ...       actPCMDReporting is set to true
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Delete cell, which is UE attached to.
    ...       step4: Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  Cell is deleted.
    ...       b.  gNB-DU trace sessions are unaffected
    ...       c.  Stop Recording Session(s) were indicated to TCE
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRMTRACECU
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_2}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host}  trace_depth=minimum
    ...   trace_ref_id=50  trace_rec_session_ref_id=50  trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
#   Delete cell  manually
    sleep  180s
    wait until keyword succeeds    10 min    30 sec    BTS Operation  verify   verify_status=CELL_ONAIR   timeout=360s
    [Teardown]     TC50 Teardown

Case Postcondtion
    Disconnet UEs
    Case Postcondition for ST

*** Keywords ***
TC40 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    Trigger ICS With Trace Stop  ue_id=1
    Trigger ICS With Trace Stop  ue_id=2
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba  traceId=ffffff  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check no tracerecords   tracerecords=${ducp_duup_tracerecords}   host=sba  traceId=000002  capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_min_without_vse}   capture_file_path=${local_file_path}
    Check common tracerecords by host   tracerecords=${stop_sesstion}   capture_file_path=${local_file_path}  host=mba
    Check common tracerecords by host   tracerecords=${stop_sesstion}   capture_file_path=${local_file_path}  host=sba
    Check emil logs for mba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRSTRACEDU

TC46 Teardown
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba  traceId=ffffff  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check common tracerecords by host   tracerecords=${stop_sesstion}   capture_file_path=${local_file_path}  host=mba
    Check common tracerecords by host   tracerecords=${stop_sesstion}   capture_file_path=${local_file_path}  host=sba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    BTS Operation  operation=cell_unblock  product_type=gnb  bts_index=0  distname_id=NRCELL-1  need_verify=yes
    BTS Operation  operation=cell_unblock  product_type=gnb  bts_index=0  distname_id=NRCELL-2  need_verify=yes
    Delete NRMTRACECU
    Delete NRSTRACEDU

TC50 Teardown
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Delete NRMTRACECU
    Delete NRSTRACEDU