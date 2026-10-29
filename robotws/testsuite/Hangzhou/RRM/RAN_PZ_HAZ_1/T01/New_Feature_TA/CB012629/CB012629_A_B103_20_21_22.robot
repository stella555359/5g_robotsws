*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: This user scenario describes



Suite Setup       Common Suite Setup For RRM
Test Setup        Common Test Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Test Timeout    120 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CommonKeyword/CB012629_Common_KeyWord.robot
Resource          CommonKeyword/CB012629_ET_KeyWord.robot

*** Variables ***
${MRBTS_ID}   1
${NRBTS_ID}   1
*** Test Cases ***
Case Precondition
     Case Precondition For CommonET

[TC20]CB012629-SR-A-B103_20_PCMD_SBA_trace_activation_Records_buffering_EC
    [Tags]    QC_25191       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace recording
    ...       session to default TCE using non-TLS TCP connection after reception of TC_NrAppStartCallInd message.
    ...       OM_GEN_SFS_TRACEMGMNT.4871 USCB012629-A#EC2-ALT2;
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
    ...       step1. UE is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Detach UE and check tcpdump log and Emil log.
    ...       step4. Repeat step 1 to 3 with MinimumWithoutVendorSpecificExtension, MediumWithoutVendorSpecificExtension
    ...       MaximumWithoutVendorSpecificExtension
    ...    4. Expert Result:
    ...       F1AP: UE CONTEXT SETUP REQUEST does not contain TraceActivate IE
    ...       SBA TRS is not started.
    ...       SBA PCMD records are not visible for gNB-DU.
    ...       MBA PCMD records is not impacted.
    Start Btslog Collect
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=1    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=1
    Trigger ICS With Trace Start    ue_id=2  trace_ref_id=16777213  trace_rec_session_ref_id=65534  trace_depth=min_without_vse
    UE Register And PDU Session Setup    ue_id=2    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=2
    Trigger ICS With Trace Start    ue_id=3  trace_ref_id=16777214  trace_rec_session_ref_id=65534  trace_depth=med_without_vse
    UE Register And PDU Session Setup    ue_id=3    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=3
    Trigger ICS With Trace Start    ue_id=4  trace_ref_id=16777215  trace_rec_session_ref_id=65534  trace_depth=max_without_vse
    UE Register And PDU Session Setup    ue_id=4    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=4
    [Teardown]    TC020 Teardown

[TC21]CB012629-SR-A-B103_21_Failed_activation_of_the_Subscriber_Trace_for_gNB-DU_due_to_deactivated_NRBTS-actPCMDReport
    [Tags]    QC_25192       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that gNB-DU could not start SBA TRS due to detactivated actPCMDReport.
    ...       OM_GEN_SFS_TRACEMGMNT.4848
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport is set to false.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...    3. Test Case Steps:
    ...       step1. UE1 is  configured in Core Simulator to support SBA.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Detach UE and check tcpdump log and Emil log.
    ...       step4. Repeat step 1 to 3 with MinimumWithoutVendorSpecificExtension, MediumWithoutVendorSpecificExtension
    ...       MaximumWithoutVendorSpecificExtension
    ...    4. Expert Result:
    ...       F1AP: UE CONTEXT SETUP REQUEST does not contain TraceActivate IE
    ...       SBA TRS is not started.
    ...       SBA PCMD records are not visible for gNB-DU.
    ...       MBA PCMD records is not impacted.
    Start Btslog Collect
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Activate or Deactivate Trace Report   actPCMDReport=false   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=1  trace_ref_id=1  trace_rec_session_ref_id=65532  trace_depth=medium
    UE Register And PDU Session Setup    ue_id=1    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=1
    Trigger ICS With Trace Start    ue_id=2  trace_ref_id=16777213  trace_rec_session_ref_id=65533  trace_depth=min_without_vse
    UE Register And PDU Session Setup    ue_id=2    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=2
    Trigger ICS With Trace Start    ue_id=3  trace_ref_id=16777214  trace_rec_session_ref_id=65534  trace_depth=med_without_vse
    UE Register And PDU Session Setup    ue_id=3    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=3
    Trigger ICS With Trace Start    ue_id=4  trace_ref_id=16777215  trace_rec_session_ref_id=65535  trace_depth=max_without_vse
    UE Register And PDU Session Setup    ue_id=4    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=4
    [Teardown]    TC021 Teardown

[TC22]CB012629-SR-A-B103_22_Failed_activation_of_SBA_for_gNB-DU_due_to_late_activation_of_NRBTS-actPCMDReport
    [Tags]    QC_25193       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that gNB-DU could not start SBA TRS due to detactivated actPCMDReport.
    ...       OM_GEN_SFS_TRACEMGMNT.4870
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport is set to false.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...    3. Test Case Steps:
    ...       step1. UE1 is  configured in Core Simulator to support SBA.
    ...       step2. Attach UE and start data traffic.
    ...       step3. The feature flag NRBTS-actPCMDReport for activating PCMD functionality is changed from false to true.
    ...       step4. Repeat step 1 to 3 with MinimumWithoutVendorSpecificExtension, MediumWithoutVendorSpecificExtension
    ...       MaximumWithoutVendorSpecificExtension
    ...    4. Expert Result:
    ...       F1AP: UE CONTEXT SETUP REQUEST does contain TraceActivate IE
    ...       SBA TRS is not started.
    ...       SBA PCMD records are not visible for gNB-DU.
    ...       MBA PCMD records are not visible for gNB-DU.
    Start Btslog Collect
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Activate or Deactivate Trace Report   actPCMDReport=false   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=5  trace_ref_id=1  trace_rec_session_ref_id=65532  trace_depth=medium
    UE Register And PDU Session Setup    ue_id=5    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=5
    [Teardown]    TC022 Teardown

[TC23]CB012629-SR-A-B104_23_Successful_gNB-DU_SBA_trace_activation_via_F1AP_Trace_Start
    [Tags]    QC_25194       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA trace
    ...       recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       User scenario B104 #1;OM_GEN_SFS_TRACEMGMNT.4872     USCB012629-A#IWK1-ALT1
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
    ...       maxBufferingTime configured 50 ms
    ...    3. Test Case Steps:
    ...       step1. UE1 is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE and start data traffic.
    ...       step3. Trace Start command works on Core Simulator.
    ...       step4. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       F1AP: TraceStart contains TraceActivate IE same as configured in core simulator.
    ...       L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE
    ...       TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACECU-1.json
     Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Btslog Collect
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=6    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=6
    Start Subscriber Trace   ue_id=6   trace_ref_id=6  trace_rec_session_ref_id=6  trace_depth=minimum
    ${meas_id}   Get Measurement Id   ue_id=6   carrier_freq=633216
    ${cmd}    Catenate    ue_measurement_send_nr id=6 meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Airphone Execute Egate Command      cmd=${cmd}
    [Teardown]    TC023 Teardown

[TC24]CB012629-SR-A-B104_24_Failed_activation_of_the_Subscriber_Trace_for_gNB-DU_due_to_deactivated_NRBTS-actPCMDReport
    [Tags]    QC_25195       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that gNB-DU could not start SBA TRS due to detactivated actPCMDReport.
    ...       OM_GEN_SFS_TRACEMGMNT.4848
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport is set to false.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...    3. Test Case Steps:
    ...       step1. UE1 is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE and start data traffic.
    ...       step3. In core simulator, start SBA Trace via Trace Start command for UE1.
    ...       step4. Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       F1AP: UE CONTEXT SETUP REQUEST does contain TraceActivate IE
    ...       SBA TRS is not started.
    ...       SBA PCMD records are not visible for gNB-DU.
    ...       MBA PCMD records are not visible for gNB-DU.
    Start Btslog Collect
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Activate or Deactivate Trace Report   actPCMDReport=false   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACECU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=7    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=7
    Start Subscriber Trace   ue_id=7   trace_ref_id=7  trace_rec_session_ref_id=7  trace_depth=minimum
    ${meas_id}   Get Measurement Id   ue_id=7   carrier_freq=633216
    ${cmd}    Catenate    ue_measurement_send_nr id=7 meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Airphone Execute Egate Command      cmd=${cmd}
    [Teardown]    TC024 Teardown

[TC25]CB012629-SR-A-B104_25_Successful_gNB-DU_SBA_trace_activation_via_Trace_Start_Configuration_Validation_Failure
    [Tags]    QC_25196       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       5G_RAN_USR_COM_22977
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
    ...       maxBufferingTime configured 50 ms
    ...    3. Test Case Steps:
    ...       step1. UE1/UE2 is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and UE2 and start data traffic.
    ...       step3. In core simulator, start SBA Trace via Trace Start command for UE1.
    ...       step4. In core simulator, start SBA Trace via Trace Start command for UE2,
    ...       with same TRID( RAN Trace ID (Trace Reference + Trace Recording Session Reference Number) as UE1.
    ...    4. Expert Result:
    ...       L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE for UE1.
    ...       TRS session is not started for UE2, due to validation failure.
    ...       TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Start Btslog Collect
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACECU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=8    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=8
    UE Register And PDU Session Setup    ue_id=9    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=9
    sleep  10s
    Start Subscriber Trace   ue_id=8   trace_ref_id=8  trace_rec_session_ref_id=8  trace_depth=minimum
    sleep  10s
    Start Subscriber Trace   ue_id=9   trace_ref_id=8  trace_rec_session_ref_id=8  trace_depth=maximum
    ${meas_id}   Get Measurement Id   ue_id=8   carrier_freq=633216
    ${cmd}    Catenate    ue_measurement_send_nr id=8 meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Airphone Execute Egate Command      cmd=${cmd}
    sleep  10s
    ${meas_id}   Get Measurement Id   ue_id=9   carrier_freq=633216
    ${cmd}    Catenate    ue_measurement_send_nr id=9 meas_id=${meas_id} event=A2 srsrp_nr=16 srsrq_nr=16 srs_result=0:16:16:0
    Airphone Execute Egate Command      cmd=${cmd}
    [Teardown]    TC025 Teardown

[TC26]CB012629-SR-A-B104_26_Successful_gNB-DU_SBA_trace_activation_via_Trace_Start_Configuration_Validation_Failure2
    [Tags]    QC_25197       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       5G_RAN_USR_COM_22977
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
    ...       maxBufferingTime configured 50 ms
    ...    3. Test Case Steps:
    ...       step1. UE1 is not configured in Core Simulator to support SBA.
    ...       step2. In core simulator, start SBA Trace via Trace Start command for UE1.
    ...       step3. In core simulator, start SBA Trace via Trace Start command for UE1
    ...       with same TRID( RAN Trace ID (Trace Reference + Trace Recording Session Reference Number) as step 2.
    ...    4. Expert Result:
    ...       1. F1AP: TraceStart contains TraceActivate IE same as configured in core simulator for UE1 in step 2 and step 3.
    ...       2. L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE for UE1.
    ...       3. session is not started for step3, as there is acivated TRS session already via step 2.
    ...       4. TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Start Btslog Collect
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACECU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=10    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=10
    sleep  10s
    Start Subscriber Trace   ue_id=10   trace_ref_id=10  trace_rec_session_ref_id=10  trace_depth=minimum
    sleep  10s
    Start Subscriber Trace   ue_id=10   trace_ref_id=10  trace_rec_session_ref_id=10  trace_depth=maximum
    ${meas_id}   Get Measurement Id   ue_id=10   carrier_freq=633216
    ${cmd}    Catenate    ue_measurement_send_nr id=10 meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Airphone Execute Egate Command      cmd=${cmd}
    [Teardown]    TC026 Teardown

[TC27]CB012629-SR-A-B104_27_Successful_gNB-DU_SBA_trace_activation_via_Trace_Start_Configuration_Validation_Failure_Recovery
    [Tags]    QC_25198       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       5G_RAN_USR_COM_22977
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
    ...       maxBufferingTime configured 50 ms
    ...    3. Test Case Steps:
    ...       step1. UE1 is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and start data traffic.
    ...       step3. In core simulator, start SBA Trace via Trace Start command for UE1
    ...       step4. In core simulator, start SBA Trace via Trace Start command for UE1
    ...       with same TRID( RAN Trace ID (Trace Reference + Trace Recording Session Reference Number) as step 3.
    ...       step5: In core simulator, Clear SBA Trace configuration via Trace Stop command for UE1. And start Trace again.
    ...       step6: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. F1AP: TraceStart contains TraceActivate IE same as configured in core simulator for UE1 in step 3 and step 4.
    ...       2. L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE for UE1.
    ...       3. TRS session is  started for step5, as there is acivated TRS session already via step 3.
    ...       4. TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Start Btslog Collect
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACECU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=11    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=11
    sleep  10s
    Start Subscriber Trace   ue_id=11   trace_ref_id=11  trace_rec_session_ref_id=11  trace_depth=minimum
    sleep  10s
    Start Subscriber Trace   ue_id=11   trace_ref_id=11  trace_rec_session_ref_id=11  trace_depth=maximum
    ${meas_id}   Get Measurement Id   ue_id=11   carrier_freq=633216
    ${cmd}    Catenate    ue_measurement_send_nr id=11 meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Airphone Execute Egate Command      cmd=${cmd}
    Stop Subscriber Trace   ue_id=11   trace_ref_id=11  trace_rec_session_ref_id=11
    Trigger ICS With Trace Stop   ue_id=11
    Start Subscriber Trace   ue_id=11   trace_ref_id=11  trace_rec_session_ref_id=11  trace_depth=medium
    ${meas_id}   Get Measurement Id   ue_id=11   event_type=A3   carrier_freq=633408
    ${cmd}    Catenate   ue_measurement_send_nr id=11 meas_id=${meas_id} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    Airphone Execute Egate Command      cmd=${cmd}
    [Teardown]    TC027 Teardown

[TC28]CB012629-SR-A-B104_28_Successful_gNB-DU_SBA_trace_activation_via_ICS_Configuration_Validation_Failure
    [Tags]    QC_25199       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       5G_RAN_USR_COM_22977
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
    ...       maxBufferingTime configured 50 ms
    ...    3. Test Case Steps:
    ...       step1. UE1 is configured in Core Simulator to support SBA.
    ...       UE2 is not configured in Core Simulator to support SBA.
    ...       step2. Attach UE1 and UE2 and start data traffic.
    ...       step3. In core simulator, start SBA Trace via Trace Start command for UE2,
    ...       with same TRID( RAN Trace ID (Trace Reference + Trace Recording Session Reference Number) as UE1.
    ...       step4: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. F1AP: TraceStart contains TraceActivate IE same as configured in core simulator for UE1 in step 4.
    ...       2. L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE for UE1.
    ...       3. TRS session is not started for step3, as there is acivated TRS session already via step 3.
    ...       4. TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Start Btslog Collect
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACECU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=12  trace_ref_id=12  trace_rec_session_ref_id=12  trace_depth=medium
    UE Register And PDU Session Setup    ue_id=12   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=12
    UE Register And PDU Session Setup    ue_id=13   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=13
    Start Subscriber Trace   ue_id=13   trace_ref_id=12  trace_rec_session_ref_id=12  trace_depth=maximum
    ${meas_id}   Get Measurement Id   ue_id=12   carrier_freq=633216
    ${cmd}    Catenate    ue_measurement_send_nr id=12 meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Airphone Execute Egate Command      cmd=${cmd}
    sleep  10s
    ${meas_id}   Get Measurement Id   ue_id=13   carrier_freq=633216
    ${cmd}    Catenate    ue_measurement_send_nr id=13 meas_id=${meas_id} event=A2 srsrp_nr=16 srsrq_nr=16 srs_result=0:11:11:0
    Airphone Execute Egate Command      cmd=${cmd}
    [Teardown]    TC028 Teardown

[TC29]CB012629-SR-A-B104_30_TCP_connection_interruption_and_recovery_towards_default_TCE
    [Tags]    QC_25200       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new gNB-DU SBA
    ...       trace recording session to TCE after reception of TC_NrAppAllocateTrsInd message..
    ...       5G_RAN_USR_COM_22977
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
    ...       maxBufferingTime configured 50 ms
    ...    3. Test Case Steps:
    ...       step1. UE1 is configured in Core Simulator to support SBA..
    ...       step2. Attach UE1 and start data traffic.
    ...       step3.In core simulator, start SBA Trace via Trace Start command for UE1,
    ...       with same TRID( RAN Trace ID (Trace Reference + Trace Recording Session Reference Number) as ICS setup.
    ...       step4: Detach UE and check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       1. F1AP: TraceStart contains TraceActivate IE same as configured in core simulator for UE1 in step 4.
    ...       2. L2 and L3 PCMD content in scope of gNB-DU SBA trace recording session is reported to TCE for UE1.
    ...       3. TRS session is not started for step3, as there is acivated TRS session already via step 3.
    ...       4. TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    Start Btslog Collect
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACECU-1.json
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=14  trace_ref_id=14  trace_rec_session_ref_id=14  trace_depth=medium
    UE Register And PDU Session Setup    ue_id=14   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=14
    Start Subscriber Trace   ue_id=14   trace_ref_id=14  trace_rec_session_ref_id=14  trace_depth=maximum
    ${meas_id}   Get Measurement Id   ue_id=14   carrier_freq=633216
    ${cmd}    Catenate    ue_measurement_send_nr id=14 meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Airphone Execute Egate Command      cmd=${cmd}
    [Teardown]    TC029 Teardown

#[TC07]CB012629_SR_A_B102_7_Successful_PCMD_SBA_trace_activation_No_Records_buffering_XNAP_HO
#    [Tags]    CRT1    CB012629_22
#    [Documentation]
#    ...   Description: This user scenario validates that Activation of the Subscriber Trace with PCMD content related to
#    ...   CB012629-A with default TCE defined, without TLS for XNAP HO
#    [Setup]    Case Precondition For 5QI1
#    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
#    Setup Xn Link To gNB
#    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
#    Add or Delete A New MOC   moc_jason=NRMTRACEDU-1.json
#    Start Collect Wireshark For GNB
#    UE Register And PDU Session Setup   ue_id=23    cell_id=1      pass_regexp=${Setup_5QI5_Success}
#    UE Modify new PDU    ue_id=23
#    Start traffic to 5QI5 and 5QI1   ue_id=23
#    Check traffic for 5QI5 and 5QI1   ue_id=23
#    Trigger Inter-gNB Inter-Freq HO   ue_id=23    pass_regexp=${HO_CELL2_SIMCELL1}
#    Trigger HO Back from SiM to Real   ue_id=23    pass_regexp=${HO_SIMCELL1_CELL2}
#    Stop Wireshark log For GNB
#    [Teardown]    TC07 Teardown
*** Keywords ***
TC020 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    Multi UE Detach   num=5
    Multi UE ICS With Trace Stop   num=5
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Stop Btslog Collect
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}  host=mba  traceId=00:00:01  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_min_without_vse}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_med_without_vse}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_max_without_vse}  capture_file_path=${local_file_path}
#    Check no tracerecords     tracerecords=${duup_tracerecords}  host=sba  traceId=FFFFFD  capture_file_path=${local_file_path}

TC021 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    Multi UE Detach   num=5
    Multi UE ICS With Trace Stop   num=5
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Stop Btslog Collect
    Check common tracerecords   tracerecords=${f1ap_trace_activate_medium}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_min_without_vse}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_med_without_vse}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_max_without_vse}  capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${duup_tracerecords}  host=sba   traceId=000001   capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${duup_tracerecords}  host=mba   traceId=00:00:01  capture_file_path=${local_file_path}

TC022 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    UE Deregister From gNB    ue_id=5
    Multi UE ICS With Trace Stop   num=5
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Stop Btslog Collect
    Check common tracerecords   tracerecords=${f1ap_trace_activate_medium}  capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${duup_tracerecords}  host=sba   traceId=000001   capture_file_path=${local_file_path}
    Check no tracerecords     tracerecords=${duup_tracerecords}  host=mba   traceId=00:00:01  capture_file_path=${local_file_path}
    ${start_sesstion}   Check tracerecords   tracerecords=${start_sesstion}   capture_file_path=${local_file_path}  host=mba
    Should Be Empty     ${start_sesstion}

TC023 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    UE Deregister From gNB    ue_id=6
    Trigger ICS With Trace Stop   ue_id=6
    Delete NRSTRACECU
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Stop Btslog Collect
    Check multi tracerecords   tracerecords=${duup_tracerecords}   host=mba   traceId=00:00:01   capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${cucp_mea_tracerecords}    capture_file_path=${local_file_path}
#   Check common tracerecords   tracerecords=${f1ap_trace_activate}   capture_file_path=${local_file_path}

TC024 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    UE Deregister From gNB    ue_id=7
    Trigger ICS With Trace Stop   ue_id=7
    Delete NRSTRACECU
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Stop Btslog Collect
    Check no tracerecords   tracerecords=${duup_tracerecords}   host=mba   traceId=00:00:01   capture_file_path=${local_file_path}
    Check no common tracerecords   tracerecords=${cucp_mea_tracerecords}    capture_file_path=${local_file_path}
#   Check common tracerecords   tracerecords=${f1ap_trace_activate}   capture_file_path=${local_file_path}

TC025 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    UE Deregister From gNB    ue_id=8
    Trigger ICS With Trace Stop   ue_id=8
    UE Deregister From gNB    ue_id=9
    Trigger ICS With Trace Stop   ue_id=9
    Delete NRSTRACECU
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Stop Btslog Collect
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}  host=mba  traceId=00:00:01  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_minimum}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_maximum}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${ueMeasRecord_rsrp_11}    capture_file_path=${local_file_path}
    Check no common tracerecords   tracerecords=${ueMeasRecord_rsrp_16}    capture_file_path=${local_file_path}

TC026 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    UE Deregister From gNB    ue_id=10
    Trigger ICS With Trace Stop   ue_id=10
    Delete NRSTRACECU
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Stop Btslog Collect
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}  host=mba  traceId=00:00:01  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_minimum}  capture_file_path=${local_file_path}
    Check no common tracerecords   tracerecords=${f1ap_trace_activate_maximum}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${rrc_message_rsrp_11}    capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${cucp_mea_tracerecords}    capture_file_path=${local_file_path}


TC027 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    UE Deregister From gNB    ue_id=11
    Trigger ICS With Trace Stop   ue_id=11
    Delete NRSTRACECU
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Stop Btslog Collect
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}  host=mba  traceId=00:00:01  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_minimum}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_medium}  capture_file_path=${local_file_path}
    Check no common tracerecords   tracerecords=${f1ap_trace_activate_maximum}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${rrc_message_rsrp_11}    capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${rrc_message_rsrp_85}    capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${ueMeasRecord_rsrp_11}    capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${ueMeasRecord_rsrp_85}    capture_file_path=${local_file_path}


TC028 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    UE Deregister From gNB    ue_id=12
    Trigger ICS With Trace Stop   ue_id=12
    UE Deregister From gNB     ue_id=13
    Trigger ICS With Trace Stop   ue_id=13
    Delete NRSTRACECU
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Stop Btslog Collect
    Check common tracerecords   tracerecords=${rrc_message_rsrp_11}    capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${rrc_message_rsrp_16}    capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${ueMeasRecord_rsrp_11}    capture_file_path=${local_file_path}
    Check no common tracerecords   tracerecords=${ueMeasRecord_rsrp_16}    capture_file_path=${local_file_path}

TC029 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    UE Deregister From gNB    ue_id=14
    Trigger ICS With Trace Stop   ue_id=14
    Delete NRSTRACECU
    Delete NRMTRACEDU
    Delete NRSTRACEDU
    Stop Btslog Collect
    Check common tracerecords   tracerecords=${f1ap_trace_activate_medium}  capture_file_path=${local_file_path}
    Check no common tracerecords   tracerecords=${f1ap_trace_activate_maximum}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${rrc_message_rsrp_11}    capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${ueMeasRecord_rsrp_11}    capture_file_path=${local_file_path}
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}