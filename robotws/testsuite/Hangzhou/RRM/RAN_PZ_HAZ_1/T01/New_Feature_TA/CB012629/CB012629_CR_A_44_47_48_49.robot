*** Settings ***
Documentation
...   Author: Qin Zhixia
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: The purpose of this test is to Check CB012629

Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup        Common Test Setup For AIC
Test Teardown     Common Test Teardown For AIC

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK


Test Timeout    180 minutes

Resource          ../../../Resources/Cloud/AIC_Common_Resource.robot
Resource          CommonKeyword/CB012629_AIC_KeyWord.robot



*** Test Cases ***
[1][1.0] WTS Precondition
         Case Precondition for ST   product_type=vcu

[TC44]CB012629-CR-A_44_Successful_TRS_Stop_Cell_Delete_AIC
    [Tags]    QC_25254       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller successfully cleares intenal resources during
    ...       resource deregistration
    ...       User scenario B201 #4: Successful trace sessions and trace recording sessions stopping in case of
    ...       resource deregistartion.
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
    ...       step2. Attach UE and start data traffic.
    ...       step3: Delete cell, which is UE attached to.
    ...       step4: Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. gNB-DU trace sessions are unaffected
    ...       b. Stop Recording Session(s) were indicated to TCE
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true  product_type=vcu
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true  product_type=vdu
    Add NRMTRACECU
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_4}
    Add NRSTRACEDU   param_dict=${NRSTRACEDU_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  wireshark_oam   vcu
    Get Required Logs   start  wireshark_oam   vdu
    Trigger ICS With Trace Start   ue_id=11  tce_ip=${sba_host}  trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1  trace_plmn=262:03
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
#   cell deletion
    [Teardown]    TC44 Teardown

[TC47]CB012629-CR-A_47_Successful_TRS_Stop_VCU_Reset_AIC
    [Tags]    QC_25255       QCD_MN_RAN      QCP_RAN_VRF
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
    ...       step3: Reset VCU.
    ...       step4: Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  After receiving F1AP: RESET ACKNOWLEDGE message, gNB-DU indicates end of trace recording sessions for all impacted Ues
    ...       b.  In tcpdump log, there is message about stopRecordingSession for established SBA TRS.
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true  product_type=vcu
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true  product_type=vdu
    Add NRMTRACECU
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  wireshark_oam   vcu
    Get Required Logs   start  wireshark_oam   vdu
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Trigger ICS With Trace Start   ue_id=11  tce_ip=${sba_host}  trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1  trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    BTS Operation  operation=vcu_reset  product_type=vcu  bts_index=0
    [Teardown]    TC47 Teardown

[TC48]CB012629_CR_A_48_Successful_TRS_Stop_Cell_Block_AIC
    [Tags]    QC_25256       QCD_MN_RAN      QCP_RAN_VRF
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
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true  product_type=vcu
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true  product_type=vdu
    Add NRMTRACECU
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_4}
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json  product_type=vcu
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  wireshark_oam   vcu
    Get Required Logs   start  wireshark_oam   vdu
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Trigger ICS With Trace Start   ue_id=11  tce_ip=${sba_host}  trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1  trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    BTS Operation  operation=cell_block  product_type=vdu  bts_index=0  distname_id=NRCELL-2  need_verify=yes
    [Teardown]    TC48 Teardown

[TC49]CB012629-CR-A_49_Successful_TRS_Stop_VDU_Reset_AIC
    [Tags]    QC_25257       QCD_MN_RAN      QCP_RAN_VRF
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
    ...       step3: Reset VDU.
    ...       step4: Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  After receiving F1AP: RESET ACKNOWLEDGE message, gNB-DU releases all related resource of the concerned
    ...           UEs in gNB-DU and indicates end of trace recording sessions for all impacted Ues
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true  product_type=vcu
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true  product_type=vdu
    Add NRMTRACECU
    Add NRSTRACECUUP   param_dict=${NRSTRACECUUP_param_dict_4}
    Prepare UE For commercial or Spark   ue_index=0
    Get Required Logs   start  wireshark_oam   vcu
    Get Required Logs   start  wireshark_oam   vdu
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    Trigger ICS With Trace Start   ue_id=11  tce_ip=${sba_host}  trace_depth=minimum
    ...   trace_ref_id=1  trace_rec_session_ref_id=1  trace_plmn=262:03
    Attach single UE   ue_index=0
    Run Keyword And Ignore Error    Start single UE traffic   ue_index=0
    BTS Operation  operation=bts_reset  product_type=vdu  bts_index=0
    [Teardown]    TC49 Teardown

*** Keywords ***
TC44 Teardown
   sleep  60s
    ${local_file_path_vdu}    Get Required Logs   stop_and_download   wireshark_oam   vdu
    wait until keyword succeeds    10 min    30 sec    BTS Operation  operation=verify   product_type=vdu
    ...    verify_status=CELL_ONAIR   timeout=360s
    Delete NRMTRACECU
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Run Keyword And Ignore Error  Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=11
    Get Required Logs   start  syslog   vdu
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path_vdu}
    Check emil logs for sba
    Check emil logs for mba
    Check emil logs for sba    tracerecords=${emil_session_alive_tracerecords}
#manully check stop session and trace session in emil logs

TC47 Teardown
    sleep  60s
    ${local_file_path_vdu}    Get Required Logs   stop_and_download   wireshark_oam   vdu
    wait until keyword succeeds    10 min    30 sec    BTS Operation  operation=verify   product_type=vdu
    ...    verify_status=CELL_ONAIR   timeout=360s
    Delete NRMTRACECU
    Delete NRSTRACECUUP
    Run Keyword And Ignore Error  Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=11
    Get Required Logs   start  syslog   vdu
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path_vdu}
    Check emil logs for sba
    Check emil logs for mba

TC48 Teardown
    sleep  30s
    ${local_file_path_vcu}    Get Required Logs   stop_and_download   wireshark_oam   vcu
    ${local_file_path_vdu}    Get Required Logs   stop_and_download   wireshark_oam   vdu
    Delete NRMTRACECU
    Delete NRSTRACECUUP
    Run Keyword And Ignore Error  Stop single UE  ue_index=0
    BTS Operation  operation=cell_unblock  product_type=vdu  bts_index=0  distname_id=NRCELL-2  need_verify=yes
    Trigger ICS With Trace Stop  ue_id=11
    Get Required Logs   start  syslog   vdu
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path_vdu}
    Check common tracerecords  tracerecords=${f1ap_trace_activate_minimum}   capture_file_path=${local_file_path_vcu}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}   host=sba   traceId=ffffff  capture_file_path=${local_file_path_vcu}
    Check emil logs for sba
    Check emil logs for mba

TC49 Teardown
    ${local_file_path_vdu}    Get Required Logs   stop_and_download   wireshark_oam   vdu
    wait until keyword succeeds    10 min    30 sec    BTS Operation  operation=verify   product_type=vdu
    ...    verify_status=CELL_ONAIR   timeout=360s
    Delete NRMTRACECU
    Delete NRSTRACECUUP
    Run Keyword And Ignore Error  Stop single UE  ue_index=0
    Trigger ICS With Trace Stop  ue_id=11
    Get Required Logs   start  syslog   vdu
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   host=mba   traceId=ffffff  capture_file_path=${local_file_path_vdu}
    Check emil logs for sba
    Check emil logs for mba

