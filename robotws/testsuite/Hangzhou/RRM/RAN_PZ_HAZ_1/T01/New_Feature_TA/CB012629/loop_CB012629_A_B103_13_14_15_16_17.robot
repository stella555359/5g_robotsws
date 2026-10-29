*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: This user scenario describes



Suite Setup       Common Suite Setup For RRM
Test Setup        Common Test Setup For RRM


Test Timeout    90 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource           CommonKeyword/CB012629_Common_KeyWord.robot
Resource           CommonKeyword/CB012629_ET_KeyWord.robot

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
Case Precondition
    Case Precondition For CB008225
#    Airphone Operation  edaemon_egate_setup  gnb  tag=CB008225
[TC13]CB012629_SR_A_B103_13_Successful_PCMD_SBA_trace_activation_Records_buffering_Inactivate_UE_CB008225_B_B1
    [Tags]    QC_25184       QCD_MN_RAN      QCP_RAN_VRF
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
    wait until keyword succeeds   5min  10s    Verify All Cells Onair
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Btslog Collect
    FOR    ${trace_depth}    ${ue_id}    IN ZIP    ${traceDepth_list}    ${ue_id_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_CAaware}
        UE Register And PDU Session Setup   ue_id=${ue_id}  pass_regexp=QoS Routing Table
        Start data traffic in egate   ue_id=${ue_id}
    END
    Start Collect Wireshark For GNB
    FOR  ${ue_id}  IN  @{ue_id_list}
        Stop data traffic in egate   ue_id=${ue_id}    pass_regexp=${inactive_check}
        Trigger RRC Resume wo Action
         ...    ue_id=${ue_id}  gnb_id=2  cell_id=1  msg=resume_request_1  cause=mt_Access    pass_regexp=${resume_check}
        UE Modify new PDU  ue_id=${ue_id}  qosflows_to_add=2
        Start data traffic in egate   ue_id=${ue_id}  qfi=2   pass_regexp=${resume_check_send_data}
    END
    [Teardown]    TC013 Teardown

[TC14]CB012629_SR_A_B103_14_Successful_PCMD_SBA_trace_activation_Records_buffering_Inactivate_UE_CB008225-B_B2
    [Tags]    QC_25185       QCD_MN_RAN      QCP_RAN_VRF
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
    ...       USCB006597-A#B1
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA for DU with Default TCE.
    ...       step2. Attach UE and wait till UE enter inactivate state.
    ...       step3. Start some data traffic and make UE exit inactivate state.
    ...       step4. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. F1AP: UE CONTEXT SETUP REQUEST contains TraceActivate IE same as configured in core simulator.
    ...       b. L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA are same) is reported to TCE for VDU
    ...       c. In tcpdump, there is  NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Btslog Collect
    FOR    ${trace_depth}    ${ue_id}    IN ZIP    ${traceDepth_list}    ${ue_id_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_CAaware}
        UE Register And PDU Session Setup   ue_id=${ue_id}  pass_regexp=QoS Routing Table
        Start data traffic in egate   ue_id=${ue_id}
    END
    Start Collect Wireshark For GNB
    FOR  ${ue_id}  IN  @{ue_id_list}
        Send UAI to gNB   ue_id=${ue_id}    state=inactive     pass_regexp=${inactive_check}
        Trigger RRC Resume wo Action
         ...    ue_id=${ue_id}  gnb_id=2  cell_id=1  msg=resume_request_1  cause=mt_Access    pass_regexp=${resume_check}
    END
    [Teardown]    TC014 Teardown

[TC15]CB012629_SR_A_B103_15_Successful_PCMD_SBA_trace_activation_Records_buffering_Inactivate_UE_RNA_Update
    [Tags]    QC_25186       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       User scenario B102 #3;5G_RAN_USR_COM_23520
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
    ...       Refer CB008225-A#B1 or CB008225-A#B2
    ...       NRBTS.rrcInactPreferredStateEnabled = ‘true’
    ...       USCB006597-A#B1
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA for DU with Default TCE.
    ...       step2. Attach UE and wait till UE enter inactivate state.
    ...       step3. Wait some time, till succesful RNA update.
    ...       step4. Wait some time, till UE enter inactivate state again.
    ...    4. Expert Result:
    ...       a. In tcpdump: - gNB-CU-CP and gNB-DU sends the applicable MBA PCMD and Cell Trace records to TCE.
    ...       b. Trace records are sent only in MBA trace session from gNB-DU and no SBA trace session is started during RNA update
    ...       c. In tcpdump, When UE context is removed, gNB-DU indicates end of MBA trace recording session to BTS TC.
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACECU-1.json
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Start Btslog Collect
    FOR    ${trace_depth}    ${ue_id}    IN ZIP    ${traceDepth_list}    ${ue_id_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_CAaware}
        UE Register And PDU Session Setup   ue_id=${ue_id}  pass_regexp=QoS Routing Table
        Start data traffic in egate   ue_id=${ue_id}
    END
    Start Collect Wireshark For GNB
    FOR  ${ue_id}  IN  @{ue_id_list}
        Stop data traffic in egate   ue_id=${ue_id}    pass_regexp=${inactive_check}
        Trigger RRC Resume wo Action  ue_id=${ue_id}    cell_id=1  msg=resume_request_1  cause=rna_Update    pass_regexp=${inactive_check}
    END
    [Teardown]    TC015 Teardown

[TC16]CB012629_SR_A_B103_16_PCMD_records_from_gNB-DU_during_RRC_Inactive_to_Fallback_to_RRC_Setup_CB008225_D_E5
    [Tags]    QC_25187       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace recording session
    ...       to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       User scenario B102 #3;5G_RAN_USR_COM_23521
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
    ...       Refer CB008225-A#B1 or CB008225-A#B2
    ...       NRBTS.rrcInactPreferredStateEnabled = ‘true’
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA for DU with Default TCE.
    ...       step2. Attach UE and wait till UE enter inactivate state with: CB008225-D#B5 – and fallback to RRCSetup
    ...       step3. Wait some time, till succesful RRC Setup.
    ...       step4. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. RRCResumeRequest1 from UE, gNB-DU selects UE in MBA trace sessions and indicates start of trace recording sessions to TCE.
    ...       b. gNB-DU sends gNB-DU RRCSetup record [5G_TC_129] to TCE with RRC resume trigger resumeCause / timestamps of RRC signalling.
    ...       c. In tcpdump, MBA and SBA has same records.
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRMTRACECU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Start Btslog Collect
    FOR    ${trace_depth}    ${ue_id}    IN ZIP    ${traceDepth_list}    ${ue_id_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_CAaware}
        UE Register And PDU Session Setup   ue_id=${ue_id}  pass_regexp=QoS Routing Table
        Start data traffic in egate   ue_id=${ue_id}
    END
    Update ranAC   ranAC=1   cell_id=1
    Start Collect Wireshark For GNB
    FOR  ${ue_id}  IN  @{ue_id_list}
        Stop data traffic in egate   ue_id=${ue_id}    pass_regexp=${inactive_check}
        Trigger RRC Resume    ue_id==${ue_id}    cell_id=1   cause=rna_Update   msg=resume_request_1
         ...                 action=invalid_short_mac_i    pass_regexp=none
        Start data traffic in egate   ue_id=${ue_id}   pass_regexp=none
    END
    [Teardown]    TC016 Teardown

[TC17]CB012629_SR_A_B103_17_PCMD_records_from_gNB-DU_during_RRC_Inactive_to_Fallback_to_RRC_Setup_CB008225_D_B5
    [Tags]    QC_25188      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace recording session
    ...       to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       User scenario B102 #3;5G_RAN_USR_COM_23521
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
    ...       Refer CB008225-A#B1 or CB008225-A#B2
    ...       NRBTS.rrcInactPreferredStateEnabled = ‘true’
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA for DU with Default TCE.
    ...       step2. Attach UE and wait till UE enter inactivate state with: CB008225-D#B7 – and fallback to RRCSetup .
    ...       step3. Wait some time, till succesful RRC Setup.
    ...       step4. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a. RRCResumeRequest1 from UE, gNB-DU selects UE in MBA trace sessions and indicates start of trace recording sessions to TCE.
    ...       b. gNB-DU sends gNB-DU RRCSetup record [5G_TC_129] to TCE with RRC resume trigger resumeCause / timestamps of RRC signalling.
    ...       b. SBA Trace session in gNB-DU is started as part of legacy procedure in Step 7 of user Scenario CB008225-D#E5 while fallback
    ...          to RRCSetup
    ...       c. In tcpdump, MBA and SBA has same records.
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Add or Delete A New MOC   moc_jason=delete_ranac.json
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRMTRACECU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Start Btslog Collect
    FOR    ${trace_depth}    ${ue_id}    IN ZIP    ${traceDepth_list}    ${ue_id_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_CAaware}
        UE Register And PDU Session Setup   ue_id=${ue_id}  pass_regexp=QoS Routing Table
        Start data traffic in egate   ue_id=${ue_id}
    END
    Start Collect Wireshark For GNB
    FOR  ${ue_id}  IN  @{ue_id_list}
        Stop data traffic in egate   ue_id=${ue_id}    pass_regexp=${inactive_check}
        Trigger RRC Resume wo Action  ue_id==${ue_id}  gnb_id=2  cell_id=2  cause=rna_Update  msg=resume_request
    END
    [Teardown]    TC017 Teardown
*** Keywords ***
TC013 Teardown
    sleep  60s
    Log Collection    stop_and_download    bip    product_type=gnb    bts_index=${0}
    ${local_file_path}   Stop Wireshark log For GNB
    Multi UE Detach   num=7
    Multi UE ICS With Trace Stop   num=7
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    ${stop_sesstion}   Check tracerecords   tracerecords=${stop_sesstion}   capture_file_path=${local_file_path}  host=mba
    Should Not Be Empty     ${stop_sesstion}
    Check common tracerecords  tracerecords=${alive}   capture_file_path=${local_file_path}
    ${start_sesstion}   Check tracerecords   tracerecords=${start_sesstion}   capture_file_path=${local_file_path}  host=mba
    Should Not Be Empty     ${start_sesstion}
    Check multi tracerecords   tracerecords=${duup_tracerecords}   capture_file_path=${local_file_path}   host=mba
    Stop Btslog Collect

TC014 Teardown
    sleep  60s
    ${local_file_path}   Stop Wireshark log For GNB
    Multi UE Detach   num=7
    Multi UE ICS With Trace Stop   num=7
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    ${stop_sesstion}   Check tracerecords   tracerecords=${stop_sesstion}   capture_file_path=${local_file_path}  host=mba
    Should Not Be Empty     ${stop_sesstion}
    ${start_sesstion}   Check tracerecords   tracerecords=${start_sesstion}   capture_file_path=${local_file_path}  host=mba
    Should Not Be Empty     ${start_sesstion}
    Check no common tracerecords    tracerecords=${ngap}   capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${duup_tracerecords}   capture_file_path=${local_file_path}   host=mba
    Stop Btslog Collect

TC015 Teardown
    sleep  20s
    ${local_file_path}   Stop Wireshark log For GNB
    Multi UE Detach   num=7
    Multi UE ICS With Trace Stop   num=7
    Delete NRMTRACECU
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    ${start_sesstion}   Check tracerecords   tracerecords=${start_sesstion}   capture_file_path=${local_file_path}  host=mba
    Should Not Be Empty     ${start_sesstion}
    ${stop_sesstion}   Check tracerecords   tracerecords=${stop_sesstion}   capture_file_path=${local_file_path}  host=mba
    Should Not Be Empty     ${stop_sesstion}
    Check multi tracerecords   tracerecords=${duup_tracerecords}   capture_file_path=${local_file_path}   host=mba
##    Check no multi tracerecords   tracerecords=${duup_tracerecords}   capture_file_path=${local_file_path}   host=sba
##    Check common tracerecords  tracerecords=${f1ap_trace_activate}   capture_file_path=${local_file_path}
    Stop Btslog Collect

TC016 Teardown
    sleep  60s
    ${local_file_path}   Stop Wireshark log For GNB
    Multi UE Detach   num=7
    Multi UE ICS With Trace Stop   num=7
    Delete NRMTRACECU
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    ${start_sesstion}   Check tracerecords   tracerecords=${start_sesstion}   capture_file_path=${local_file_path}  host=mba
    Should Not Be Empty     ${start_sesstion}
    Check multi tracerecords   tracerecords=${duup_tracerecords}   capture_file_path=${local_file_path}   host=mba
#    Check multi tracerecords   tracerecords=${duup_tracerecords}   capture_file_path=${local_file_path}   host=sba
#    Check common tracerecords  tracerecords=${f1ap_trace_activate}   capture_file_path=${local_file_path}
    Stop Btslog Collect

TC017 Teardown
    sleep  20s
    ${local_file_path}   Stop Wireshark log For GNB
    Multi UE Detach   num=7
    Multi UE ICS With Trace Stop   num=7
    Delete NRMTRACECU
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Add or Delete A New MOC    moc_jason=ranac.json
    ${rrc_setup_cell2}    Check common tracerecords   tracerecords=${rrc_setup_cell2}   capture_file_path=${local_file_path}
    ${start_sesstion}   Check tracerecords   tracerecords=${start_sesstion}   capture_file_path=${local_file_path}  host=mba
    Should Not Be Empty     ${start_sesstion}
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}   capture_file_path=${local_file_path}   host=mba
#    Check multi tracerecords   tracerecords=${duup_tracerecords}   capture_file_path=${local_file_path}   host=sba
#    Check common tracerecords  tracerecords=${f1ap_trace_activate}   capture_file_path=${local_file_path}
    Stop Btslog Collect



