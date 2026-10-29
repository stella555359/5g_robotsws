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

[TC72]CB012629-SR-B-B102_72_SBA_TRSs_activation_InterfacesToTraces_IE_0_ICS_TraceActivation_IE_propagation
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that TraceActivation IE propogation by gNB-CU-CP (triggered by NGAP:Intial Context Setup Request)
    ...       and SBA TRS activation for PCMD in gNB-CU-CP/gNB-CU-UP/gNB-DU.
    ...       5G_RAN_USR_COM_22981
    ...    2. Preconditions :
    ...       gNB is up and running with cell supporting SA
    ...       TCE is configured in MNL/TCEADM/TCE
    ...       NRBTS/actSubscriberTraceReport set to TRUE
    ...       NRBTS/actPCMDReport set to TRUE
    ...       NRBTS/NRCTRLTS/NRSTRACECU/actPCMDReporting set to TRUE
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/actPCMDReporting set to TRUE.
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/defaultNrTceIdentifier set to existing TCE.tceIdentifier.
    ...       NRBTS/NRDU/NRCTRLTSDU/NRSTRACEDU/actPCMDReporting set to TRUE
    ...       NRBTS/NRDU/NRCTRLTSDU/NRSTRACEDU/defaultNrTceIdentifier set to existing TCE.tceIdentifier
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA in ICS  with  Interfaces To Traces IE = 0
    ...       step2. Attach UE and start data traffic.
    ...       step3. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. UE: L2 and L3 PCMD content in scope of gNB-CUCP/CUUP trace recording session (both MBA and SBA are same) is reported to TCE.
    ...       In tcpdump,  The GNB-DU TRS related message is visible with TRACEACTIVATION IE:
    ...       F1AP: UE CONTEXT SETUP REQUEST - for setup UE context
    ...       GNB-DU PCMD TRS is not started as it will be implemented in CB012629-A.
    ...       In tcpdump,  The CUUP TRS is triggered by following messages:
    ...       E1AP: BEARER CONTEXT SETUP REQUEST - for setup UE context
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRMTRACECU
    Add NRSTRACECU
    Add NRMTRACECUUP
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_4}
#    Add NRSTRACEDU   param_dict=${NRSTRACEDU_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host}  trace_depth=${trace_depth}  ifaces_to_trace=none
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    [Teardown]    TC72 Teardown

[TC75]CB012629-SR-B-B102_75_SBA_TRSs_activation_gNB-CU-CP_InterfacesToTraces_IE_0_TraceStart_TraceActivation_IE_propagation
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that TraceActivation IE propogation by gNB-CU-CP (triggered by NGAP:Intial Context Setup Request)
    ...       and SBA TRS activation for PCMD in gNB-CU-CP/gNB-CU-UP/gNB-DU.
    ...       5G_RAN_USR_COM_22981
    ...    2. Preconditions :
    ...       gNB is up and running with cell supporting SA
    ...       TCE is configured in MNL/TCEADM/TCE
    ...       NRBTS/actSubscriberTraceReport set to TRUE
    ...       NRBTS/actPCMDReport set to TRUE
    ...       NRBTS/NRCTRLTS/NRSTRACECU/actPCMDReporting set to TRUE
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/actPCMDReporting set to TRUE.
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/defaultNrTceIdentifier set to existing TCE.tceIdentifier.
    ...       NRBTS/NRDU/NRCTRLTSDU/NRSTRACEDU/actPCMDReporting set to TRUE
    ...       NRBTS/NRDU/NRCTRLTSDU/NRSTRACEDU/defaultNrTceIdentifier set to existing TCE.tceIdentifier
    ...    3. Test Case Steps:
    ...       step1. UE is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Trigger SBA based PCMD via TraceStart command with InterfacesToTraces set to 0 from Core Simulator.
    ...       step4. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. UE: L2 and L3 PCMD content in scope of gNB-CUCP/CUUP trace recording session (both MBA and SBA are same) is reported to TCE.
    ...       b. In tcpdump,  The CUUP TRS is triggered by following messages:
    ...          E1AP: TRACE START - for setup UE context
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRMTRACECU
    Add NRSTRACECU
    Add NRMTRACECUUP
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_4}
#    Add NRSTRACEDU   param_dict=${NRSTRACEDU_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
        Start Subscriber Trace   ue_id=${ue_id}   tce_ip=${sba_host}   trace_depth=${trace_depth}   ifaces_to_trace=none
         ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
    END
    Start attenuator  value1=${30}  value9=${30}  value2=${50}  value10=${50}   value3=${50}  value11=${50}
    ...   value4=${50}  value12=${50}
    [Teardown]    TC75 Teardown

[TC80]CB012629-SR-B-B102_80_TraceActivation_IE_propagation_by_gNB-CU-CP_NRSTRACECU-actPCMDReporting_False
    [Tags]    QC_25481       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace recording
    ...       session to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       5G_RAN_USR_COM_22981
    ...    2. Preconditions :
    ...       gNB is up and running with cell supporting SA
    ...       TCE is configured in MNL/TCEADM/TCE
    ...       NRBTS/actSubscriberTraceReport set to TRUE
    ...       NRBTS/actPCMDReport set to TRUE
    ...       NRBTS/NRCTRLTS/NRSTRACECU/actPCMDReporting set to FALSE
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/actPCMDReporting set to TRUE.
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/defaultNrTceIdentifier set to existing TCE.tceIdentifier.
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA with InterfacesToTraces set to 0.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Detach UEs and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. UE: L2 and L3 PCMD content in scope of gNB-CUUP trace recording session (both MBA and SBA are same) is reported to TCE .
    ...       b. In tcpdump,  The CUUP TRS is triggered by following messages:
    ...         - E1AP: BEARER CONTEXT SETUP REQUEST - for setup UE context
    ...       c. SBA Gnb-CUCP PCMD record is not reported to TCE, due to NRBTS/NRCTRLTS/NRSTRACECU/actPCMDReporting set to FALSE.
    ...       d. In tcpdump,  The GNB-DU TRS related message is visible with TRACEACTIVATION IE:
    ...          - F1AP: UE CONTEXT SETUP REQUEST - for setup UE context
    ...       e. GNB-DU PCMD TRS is not started due to NRSTRACEDU/actPCMDReporting set to FALSE.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRMTRACECU
    Add NRSTRACECU  param_dict=${NRSTRACECU_param_dict_3}
    Add NRMTRACECUUP
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_4}
#    Add NRSTRACEDU   param_dict=${NRSTRACEDU_param_dict_15}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_15}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host}  trace_depth=${trace_depth}  ifaces_to_trace=none
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    [Teardown]    TC80 Teardown

[TC81]CB012629-SR-B-B102_81_TraceActivation_IE_propagation_by_gNB-CU-CP_No_NRSTRACECU
    [Tags]    QC_25482       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that TraceActivation IE propogation by gNB-CU-CP (triggered by NGAP:Intial Context Setup Request)
    ...       and SBA TRS activation for PCMD in gNB-CU-CP/gNB-CU-UP/gNB-DU.
    ...       5G_RAN_USR_COM_22981
    ...    2. Preconditions :
    ...       gNB is up and running with cell supporting SA
    ...       TCE is configured in MNL/TCEADM/TCE
    ...       NRBTS/actSubscriberTraceReport set to TRUE
    ...       NRBTS/actPCMDReport set to TRUE
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/actPCMDReporting set to TRUE.
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/defaultNrTceIdentifier set to existing TCE.tceIdentifier.
    ...       NRBTS/NRDU/NRCTRLTSDU/NRSTRACEDU/actPCMDReporting set to TRUE
    ...       NRBTS/NRDU/NRCTRLTSDU/NRSTRACEDU/defaultNrTceIdentifier set to existing TCE.tceIdentifier
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA with InterfacesToTraces set to 0.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Detach UEs and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. UE: L2 and L3 PCMD content in scope of gNB-CUUP trace recording session (both MBA and SBA are same) is reported to TCE .
    ...       b. In tcpdump,  The CUUP TRS is triggered by following messages:
    ...         - E1AP: BEARER CONTEXT SETUP REQUEST - for setup UE context
    ...       c. SBA Gnb-CUCP PCMD record is not reported to TCE, due to NRBTS/NRCTRLTS/NRSTRACECU/actPCMDReporting set to FALSE.
    ...       d. In tcpdump,  The GNB-DU TRS related message is visible with TRACEACTIVATION IE:
    ...          - F1AP: UE CONTEXT SETUP REQUEST - for setup UE context
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRMTRACECU
    Add NRMTRACECUUP
    Add NRSTRACECUUP  param_dict=${NRSTRACECUUP_param_dict_4}
#    Add NRSTRACEDU   param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host}  trace_depth=${trace_depth}  ifaces_to_trace=none
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    [Teardown]    TC81 Teardown

[TC82]CB012629-SR-B-B102_82_Deactivate_Trace_propagation_by_gNB-CU-CP_ICS_Interfaces_to_trace_0
    [Tags]    QC_25483       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace recording
    ...       session to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       USCB012629-B#B02 Deactivate Trace
    ...    2. Preconditions :
    ...       gNB is up and running with cell supporting SA
    ...       TCE is configured in MNL/TCEADM/TCE
    ...       NRBTS/actSubscriberTraceReport set to TRUE
    ...       NRBTS/actPCMDReport set to TRUE
    ...       NRBTS/NRCTRLTS/NRSTRACECU/actPCMDReporting set to TRUE
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/actPCMDReporting set to TRUE.
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/defaultNrTceIdentifier set to existing TCE.tceIdentifier.
    ...       NRBTS/NRDU/NRCTRLTSDU/NRSTRACEDU/actPCMDReporting set to TRUE
    ...       NRBTS/NRDU/NRCTRLTSDU/NRSTRACEDU/defaultNrTceIdentifier set to existing TCE.tceIdentifier
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA with InterfacesToTraces set to 0.
    ...       step2. Attach UE and start data traffic.
    ...       step3. In Core Simulator, use TraceStop command to stop SBA.
    ...       step4. Detach UEs and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. UE: L2 and L3 PCMD content in scope of gNB-CUUP/gNB-CUCP trace recording session (both MBA and SBA are same)
    ...          is reported to TCE after step 3 .
    ...       b. In tcpdump,  The CUUP TRS is triggered by following messages:
    ...         - E1AP: Trace Stop - for setup UE context
    ...       d. In tcpdump,  The GNB-DU TRS related message is visible with TRACEACTIVATION IE:
    ...          - F1AP: Trace Stop - for setup UE context
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRMTRACECU
    Add NRSTRACECU
    Add NRMTRACECUUP
    Add NRSTRACECUUP    param_dict=${NRSTRACECUUP_param_dict_4}
#    Add NRSTRACEDU    param_dict=${NRSTRACEDU_param_dict_4}
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list}  ${traceDepth_list}  ${ue_index_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host}  trace_depth=${trace_depth}  ifaces_to_trace=none
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    [Teardown]    TC82 Teardown

[TC83]CB012629-SR-B-B102_83_Deactivate_Trace_propagation_by_gNB-CU-CP_ICS_Interfaces_to_trace_F1_E1
    [Tags]    QC_25484       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that Deactivate Trace (triggered by NGAP:DEACTIVATE TRACE) propogation
    ...       by gNB-CU-CP and SBA TRS deactivation in gNB-CU-CP/gNB-CU-UP/gNB-DU.
    ...       USCB012629-B#B02 Deactivate Trace
    ...       Interfaces To Traces IE = F1 and E1 (or) F1 (or) E1
    ...       TraceDepth = MinimumWithoutVendorSpecificExtension/MediumWithoutVendorSpecificExtension/MaximumWithoutVendorSpecificExtension
    ...       gNB-CU-CP stops the trace session for the indicated trace reference contained in the NG-RAN Trace ID IE.
    ...       gNB-CU-UP/gNB-DU shall ignore the DEACTIVATE TRACE message received from gNB-CU-CP as the trace session is not started
    ...       (signalling only trace session is not suported yet in gNB_CU-UP/gNB-DU).
    ...       OM_GEN_SFS_TRACEMGMNT.4876    USCB012629-B#EC1
    ...       OM_GEN_SFS_TRACEMGMNT.4861    USCB012629-B#EC2
    ...    2. Preconditions :
    ...       gNB is up and running with cell supporting SA
    ...       TCE is configured in MNL/TCEADM/TCE
    ...       NRBTS/actSubscriberTraceReport set to TRUE
    ...       NRBTS/actPCMDReport set to TRUE
    ...       NRBTS/NRCTRLTS/NRSTRACECU/actPCMDReporting set to TRUE
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/actPCMDReporting set to TRUE.
    ...       NRBTS/NRCUUP/NRCTRLTSCUUP/NRSTRACECUUP/defaultNrTceIdentifier set to existing TCE.tceIdentifier.
    ...       NRBTS/NRDU/NRCTRLTSDU/NRSTRACEDU/actPCMDReporting set to TRUE
    ...       NRBTS/NRDU/NRCTRLTSDU/NRSTRACEDU/defaultNrTceIdentifier set to existing TCE.tceIdentifier
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA with InterfacesToTraces set to E1 and F1,
    ...       TraceDepth = MinimumWithoutVendorSpecificExtension/MediumWithoutVendorSpecificExtension/MaximumWithoutVendorSpecificExtension.
    ...       step2. Attach UE and start data traffic.
    ...       step3. In Core Simulator, use TraceStop command to stop SBA.
    ...       step4. Detach UEs and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. UE: No L2 and L3 PCMD content in scope of gNB-CUUP/gNB-CUCP trace recording session (both MBA and SBA are same)
    ...          is reported from step 2.
    ...       b. Only CUCP trace message is visible.
    ...       c. CUCP trace message reporting is stopped after step
    ...       d. In tcpdump, there is visible E1AP: DEACTIVATE TRACE message.
    ...       e. In tcpdump, there is visible F1AP: DEACTIVATE TRACE message
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRMTRACECU
    Add NRSTRACECU
    Add NRMTRACECUUP
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_4}
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
    FOR   ${ue_id}    ${trace_depth}    ${ue_index}    IN ZIP     ${ue_id_list_wo}  ${traceDepth_list_wo}  ${ue_index_list_wo}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host}  trace_depth=${trace_depth}  ifaces_to_trace=E1,F1-C
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}   trace_plmn=262:03
        Attach single UE   ue_index=${ue_index}
        Run Keyword And Ignore Error    Start single UE traffic   ue_index=${ue_index}
    END
    [Teardown]    TC83 Teardown

Case Postcondtion
    Disconnet UEs
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Case Postcondition for ST
*** Keywords ***
TC72 Teardown
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cucp_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${ngap_trace_activate_list}  ${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cucp_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cucp_tracerecords}   ${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId  ${trace_id_list}   ${ducp_duup_tracerecords}   ${local_file_path}
    Run Keyword And Ignore Error  Download Dcap log to local sba
    Run Keyword And Ignore Error  Download Dcap log to local mba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRMTRACECU
    Delete NRSTRACECU
    Delete NRMTRACECUUP
    Delete NRSTRACECUUP
#    Delete NRSTRACEDU
    Delete NRSTRACEDU

TC75 Teardown
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Start attenuator  value1=${0}  value9=${0}
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cucp_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${ngap_trace_activate_list}  ${local_file_path}
    Check common tracerecords   tracerecords=${cucp_mea_tracerecords}    capture_file_path=${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cuup_throughput_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cuup_throughput_tracerecords}   ${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_throughput_tracerecords}   host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check no tracerecords by traceId  ${trace_id_list}   ${ducp_duup_tracerecords}   ${local_file_path}
    Run Keyword And Ignore Error  Download Dcap log to local sba
    Run Keyword And Ignore Error  Download Dcap log to local mba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRMTRACECU
    Delete NRSTRACECU
    Delete NRMTRACECUUP
    Delete NRSTRACECUUP
#    Delete NRSTRACEDU
    Delete NRSTRACEDU

TC80 Teardown
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cucp_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list}  ${cucp_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list}  ${ducp_duup_tracerecords}   ${local_file_path}
    Run Keyword And Ignore Error  Download Dcap log to local sba
    Run Keyword And Ignore Error  Download Dcap log to local mba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRMTRACECU
    Delete NRSTRACECU
    Delete NRMTRACECUUP
    Delete NRSTRACECUUP
    Delete NRSTRACEDU

TC81 Teardown
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cucp_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list}  ${cucp_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list}  ${ducp_duup_tracerecords}   ${local_file_path}
    Run Keyword And Ignore Error  Download Dcap log to local sba
    Run Keyword And Ignore Error  Download Dcap log to local mba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRMTRACECU
    Delete NRMTRACECUUP
    Delete NRSTRACECUUP
#    Delete NRSTRACEDU
    Delete NRSTRACEDU

TC82 Teardown
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    sleep   60s
    FOR  ${ue_id}  IN  @{ue_id_list}
        Stop Subscriber Trace  ue_id=${ue_id}  trace_plmn=262:03  trace_rec_session_ref_id=${ue_id}  trace_ref_id=${ue_id}
    END
    sleep  30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    sleep  10s
    Get Required Logs   start  wireshark   gnb
    Start attenuator  value1=${30}  value9=${30}
    sleep   60s
    ${local_file_path_1}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list}  ${ue_index_list}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Start attenuator  value1=${0}  value9=${0}
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cucp_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list}  ${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cucp_tracerecords}   ${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cucp_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list}  ${ducp_duup_tracerecords}   ${local_file_path}
    ${traceMessage_result}  Check tracerecord by DCAP IP  tracerecords=${cucp_mea_tracerecords}  dcap_ip=${mba_host}  traceId=ffffff
    ...   capture_file_path=${local_file_path_1}
    Should Not Be Empty     ${traceMessage_result}
    FOR    ${index}    IN RANGE    6
         ${traceMessage_result}  Check tracerecord by DCAP IP  tracerecords=${cucp_mea_tracerecords}  dcap_ip=${sba_host}  traceId=00000${index}
         ...   capture_file_path=${local_file_path_1}
         Should Be Empty     ${traceMessage_result}
    END
    Check no tracerecords by traceId   ${trace_id_list}  ${cuup_throughput_tracerecords}   ${local_file_path_1}
    Check no tracerecords by traceId   ${trace_id_list}  ${cuup_throughput_tracerecords}   ${local_file_path_1}
    Run Keyword And Ignore Error  Download Dcap log to local sba
    Run Keyword And Ignore Error  Download Dcap log to local mba
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRMTRACECU
    Delete NRSTRACECU
    Delete NRMTRACECUUP
    Delete NRSTRACECUUP
#    Delete NRSTRACEDU
    Delete NRSTRACEDU

TC83 Teardown
    sleep   60s
    FOR  ${ue_id}  IN  @{ue_id_list_wo}
        Stop Subscriber Trace  ue_id=${ue_id}  trace_plmn=262:03  trace_rec_session_ref_id=${ue_id}  trace_ref_id=${ue_id}
    END
    sleep   30s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    FOR   ${ue_id}  ${ue_index}   IN ZIP   ${ue_id_list_wo}  ${ue_index_list_wo}
        Stop single UE  ue_index=${ue_index}
        Trigger ICS With Trace Stop  ue_id=${ue_id}
    END
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cucp_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}      host=mba  traceId=ffffff    capture_file_path=${local_file_path}
    Check common tracerecords for activate protocal   ${f1ap_trace_activate_list_wo}  ${local_file_path}
    Check common tracerecords for activate protocal   ${e1ap_trace_activate_list_wo}  ${local_file_path}
    Check common tracerecords for activate protocal   ${ngap_trace_activate_list_wo}  ${local_file_path}
    Check no tracerecords by traceId  ${trace_id_list_1}   ${cucp_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId  ${trace_id_list_1}   ${cuup_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId  ${trace_id_list_1}   ${ducp_duup_tracerecords}   ${local_file_path}
    Check emil logs for mba    tracerecords=${emil_ducp_duup_tracerecords}
    Check emil logs for mba    tracerecords=${emil_cucp_tracerecords}
    Check emil logs for mba    tracerecords=${emil_cuup_tracerecords}
    CB012629_Common_KeyWord.Backup scf
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRMTRACECU
    Delete NRSTRACECU
    Delete NRMTRACECUUP
    Delete NRSTRACECUUP
#    Delete NRSTRACEDU
    Delete NRSTRACEDU

