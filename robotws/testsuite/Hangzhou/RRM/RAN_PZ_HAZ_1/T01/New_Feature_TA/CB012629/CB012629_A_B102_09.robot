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
${UE_Capa_Support_CAaware}    SEPARATOR=
...    E1A00000074E5A031E000384A0003C1260C80008785800C40340260300C07010A8D851AC10143404B2CA261E003D6C10101070EF1C39061C00103278FAB80027
...    800E0009E00151B133582028680965944C3C007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28987800F5B0404041C3BC
...    70E418700040C9E3EAE0009E00380027800546C4ED6080A1A025965130F001EB608080838778E1C830E0008193C7D5400001400000A8D805AC10143400000060
...    07800F5B00000000000000000000000000000D55554D5555404F0F1340038500000002C040BC3C02000E0D8000010B0102006026C00219000078081448014080
...    0FFFFFFF86C0038003C1C1401C0C026007000683E008000000000000000200F2A6B0300020800004B2CA82000020000000E95555030068007000B00008404008
...    010100200420200801008020043562600020406080A0C0E10162022242632424A4C4E50940A510000210
${MRBTS_ID}   1
${NRBTS_ID}   1
*** Test Cases ***
[TC09]CB012629-SR-A-B102_9_Successful_PCMD_SBA_trace_activation_No_Records_buffering_Inactive_UE
    [Tags]    QC_16475       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       User scenario B102 #3;5G_RAN_USR_COM_22975;5G_RAN_USR_COM_23407;5G_RAN_USR_COM_23408
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...       Refer CB008225-A#B1 or CB008225-A#B2
    ...       NRBTS.rrcInactPreferredStateEnabled = ‘true’
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA for DU with Default TCE.
    ...       step2. Attach UE and wait till UE enter inactivate state.
    ...       step3. Start some data traffic and make UE exit inactivate state.
    ...       step4. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. F1AP: UE CONTEXT SETUP REQUEST contains TraceActivate IE same as configured in core simulator.
    ...       b. L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA are same) is reported to TCE for VDU
    ...       3. In tcpdump, there is  NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    [Setup]    Case Precondition For CB008225
    wait until keyword succeeds   5min  10s    Verify All Cells Onair
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACECU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Get Required Logs   start  syslog   gnb
    FOR    ${trace_depth}    ${ue_id}    IN ZIP    ${traceDepth_list}    ${ue_id_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_CAaware}
        UE Register And PDU Session Setup   ue_id=${ue_id}  pass_regexp=QoS Routing Table
        Start data traffic in egate   ue_id=${ue_id}
    END
    Get Required Logs   start  wireshark   gnb
    FOR  ${ue_id}  IN  @{ue_id_list}
        Stop data traffic in egate   ue_id=${ue_id}    pass_regexp=${inactive_check}
        Trigger RRC Resume wo Action
         ...    ue_id=${ue_id}  gnb_id=2  cell_id=1  msg=resume_request_1  cause=mo_Data    pass_regexp=rrcResumeComplete
    END
    [Teardown]    TC09 Teardown

*** Keywords ***
TC09 Teardown
    sleep  60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Multi UE Detach   num=7
    Multi UE ICS With Trace Stop   num=7
    Delete NRMTRACEDU
    Delete NRSTRACECU
    Delete NRSTRACECUUP
    Delete NRSTRACEDU
    Get Required Logs   stop_and_download   syslog   gnb
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords_after_resume}  host=mba  traceId=000001
    ...   capture_file_path=${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cucp_tracerecords_after_resume}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cucp_tracerecords_after_resume}   ${local_file_path}
    Check multi tracerecords by traceId  ${trace_id_list_1}   ${cuup_throughput_tracerecords}   ${local_file_path}
    Check no tracerecords by traceId   ${trace_id_list_2}  ${cuup_throughput_tracerecords}   ${local_file_path}



