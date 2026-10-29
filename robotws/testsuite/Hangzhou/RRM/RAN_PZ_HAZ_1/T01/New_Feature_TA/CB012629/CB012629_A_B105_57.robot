*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: This user scenario describes



Suite Setup       Common Suite Setup For RRM
#Test Setup        Common Test Setup For RRM

Test Timeout    90 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CommonKeyword/CB012629_Common_KeyWord.robot
Resource          CommonKeyword/CB012629_ET_KeyWord.robot

*** Variables ***
${MRBTS_ID}   1
${NRBTS_ID}   1
*** Test Cases ***
[TC57]CB012629-SR-A-B105_57_Successful_PCMD_SBA_trace_activation_Records_buffering_RRC_ReEstablishment
    [Tags]    QC_25223       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that PCMD records are buffered for SBA when there is RRC reestablishment.
    ...       User scenario B102 #3
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
    ...       step1. UE is configured in Core Simulator to support SBA in ICS for DU with default TCE.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Adjust PA to trigger RRC REESTABLISHMENT.
    ...       step4: Detach UE. Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA are same)
    ...           is reported to TCE for VDU
    ...       b.  In tcpdump, there is  NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    [Setup]    Case Precondition For CommonET
    Get Required Logs   start  syslog   gnb
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Activate RRC Reestabishment
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Trigger ICS With Trace Start    ue_id=1  trace_ref_id=16777215  trace_rec_session_ref_id=65535  trace_depth=maximum
    UE Register And PDU Session Setup    ue_id=1    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=1
    Get Required Logs   start  wireshark   gnb
    Trigger RRC Reestablish   ue_id=1
    [Teardown]    TC57 Teardown

*** Keywords ***
TC57 Teardown
    sleep  60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    UE Deregister From gNB    ue_id=1
    Trigger ICS With Trace Stop   ue_id=1
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords_after_reestablish}  host=mba  traceId=000001
    ...   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords_after_reestablish}  host=sba  traceId=ffffff
    ...   capture_file_path=${local_file_path}



