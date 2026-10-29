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
[TC51]CB012629-SR-A-B202_51_SBA_gNB-DU_trace_session_deactivation_via_F1AP_Deactivate_Trace
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller deactivates gNB-DU SBA Trace Recoding Session after
    ...       reception of TC_NrAppReleaseTrsInd message.
    ...       User scenario B202 #1
    ...       5G_RAN_USR_COM_22976;OM_GEN_SFS_TRACEMGMNT.4850
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
    ...       tlsEnabled set to true, RSA certificate shall be used
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range e.g. 1000 ms
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Stop SBA TRS via Trace Stop command from Core Simulator.
    ...       step4: Detach UE. Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  gNB-DU SBA trace recording session for requested UE is stopped after step 3, via F1AP: DEACTIVATE TRACE.
    ...       b.  Records are not reported to TCE for affected UE.
    ...       c.  Comapring to MBA, SBA PCMD do not have UE detach related PCMD records.
    [Setup]    Case Precondition for ST   product_type=gnb
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
    Trigger ICS With Trace Start   ue_id=1  tce_ip=${sba_host_tls}  trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Stop Subscriber Trace  ue_id=1  trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    [Teardown]    TC51 Teardown

Case Postcondtion
    Disconnet UEs
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Case Postcondition for ST

*** Keywords ***
TC51 Teardown
    Stop single UE  ue_index=0
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Trigger ICS With Trace Stop  ue_id=1
    Get Required Logs   stop_and_download   syslog   gnb
    Check common tracerecords    tracerecords=${alive}   capture_file_path=${local_file_path}
    Check emil logs for sba tls
    # need check detach trace records
    Check emil logs for mba