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

[TC77]CB012629-SR-B-B103_77_SBA_TRSs_activation_gNB-CU-CP_InterfacesToTraces_IE_0_Validation_Failure2_TraceActivation_IE_propagation
    [Tags]    QC_25233       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace recording
    ...       session to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       5G_RAN_USR_COM_22981
    ...       ALT3: gNB-CU-CP shall propagate TraceActivation IE to gNB-CU-UP, gNB-DU even if Trace reference
    ...       validation is failed. In this scenario, gNB-CU-CP shall not activate trace recording session for the UE
    ...       but gNB-CU-UP and gNB-DU starts the trace recording session.
    ...    2. Preconditions :
    ...       gNB is up and running with cell supporting SA
    ...       TCE is configured in MNL/TCEADM/TCE
    ...       NRBTS/actSubscriberTraceReport set to TRUE
    ...       NRBTS/actPCMDReport set to TRUE
    ...       NRBTS/NRCTRLTS/NRSTRACECU/actPCMDReporting set to TRUE
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA with InterfacesToTraces set to 0.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Online add below MOCs.
    ...              NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/actPCMDReporting set to TRUE.
    ...              NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/defaultNrTceIdentifier set to existing TCE.tceIdentifier.
    ...       step4. In Core Simulator, use TraceStart command to trigger SBA with InterfacesToTraces set to 0 and same TRS as step 1.
    ...       step5. Detach UEs and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. UE: L2 and L3 PCMD content in scope of gNB-CUUP trace recording session (both MBA and SBA are same) is
    ...          reported to TCE after step 4
    ...          L2 and L3 PCMD content in scope of gNB-CUCP trace recording session (both MBA and SBA are same) is
    ...          reported to TCE after step 1, not interrupted by step 4.
    ...       b. In tcpdump,  The CUUP TRS is triggered by following messages:
   ...           - E1AP: Trace Start - for setup UE context
   ...        c. In tcpdump,  The GNB-DU TRS related message is visible with TRACEACTIVATION IE:
   ...          - F1AP: Trace Start - for setup UE context
   ...        d. GNB-DU PCMD TRS is not started as it will be implemented in CB012629-A.
#    [Setup]    Case Precondition for ST   product_type=gnb
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRMTRACECU
    Add NRSTRACECU
    Add NRSTRACEDU   param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Trigger ICS With Trace Start   ue_id=1    tce_ip=${sba_host}  trace_depth=medium  ifaces_to_trace=none
    ...   trace_ref_id=1  trace_rec_session_ref_id=1   trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_4}
    Start Subscriber Trace   ue_id=1   tce_ip=${sba_host}   trace_depth=maximum   ifaces_to_trace=none
    ...   trace_ref_id=1  trace_rec_session_ref_id=1    trace_plmn=262:03
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    sleep  10s
    Start attenuator  value1=${30}  value9=${30}
    [Teardown]    TC77 Teardown

Case Postcondtion
    Disconnet UEs

*** Keywords ***
TC77 Teardown
    sleep  60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=1
    Start attenuator  value1=${0}  value9=${0}
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_medium}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${e1ap_trace_activate_maximum}   capture_file_path=${local_file_path}
    Check common tracerecords    tracerecords=${cucp_mea_tracerecords}   capture_file_path=${local_file_path}
    Check multi tracerecords by DCAP IP    tracerecords=${cucp_tracerecords}  dcap_ip=${sba_host}   traceId=000001
    ...    capture_file_path=${local_file_path}
    Check multi tracerecords by DCAP IP    tracerecords=${cuup_throughput_tracerecords}  dcap_ip=${sba_host}   traceId=000001
    ...    capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${ducp_duup_tracerecords}  host=sba   traceId=000001   capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_cucp_tracerecords}
    Check emil logs for sba   tracerecords=${emil_cuup_throughput_tracerecords}
    Check emil logs for mba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRMTRACECU
    Delete NRSTRACECU
    Delete NRSTRACECUUP
    Delete NRSTRACEDU





