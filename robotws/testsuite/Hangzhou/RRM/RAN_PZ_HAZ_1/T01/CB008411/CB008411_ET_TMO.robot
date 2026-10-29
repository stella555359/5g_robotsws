

*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: This user scenario describes



Suite Setup       Common Suite Setup For RRM
Test Setup        Common Test Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Test Timeout    120 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../T01/Resources/RRM2_RRM_Resource.robot
Resource          CB008411_KeyWord.robot

*** Variables ***
${MRBTS_ID}   1
${NRBTS_ID}   1
${UE_Capa_Support_CAaware}    SEPARATOR=
...    E1A00000074E5A031E000384A0003C1260C80008785800C40340260300C07010A8D851AC10143404B2CA261E003D6C10101070EF1C39061C00103278FAB80027
...    800E0009E00151B133582028680965944C3C007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28987800F5B0404041C3BC
...    70E418700040C9E3EAE0009E00380027800546C4ED6080A1A025965130F001EB608080838778E1C830E0008193C7D5400001400000A8D805AC10143400000060
...    07800F5B00000000000000000000000000000D55554D5555404F0F1340038500000002C040BC3C02000E0D8000010B0102006026C00219000078081448014080
...    0FFFFFFF86C0038003C1C1401C0C026007000683E008000000000000000200F2A6B0300020800004B2CA82000020000000E95555030068007000B00008404008
...    010100200420200801008020043562600020406080A0C0E10162022242632424A4C4E50940A510000210
*** Test Cases ***
CB008411_A_TC001_Activation_Deactivation_of_Subscriber_Trace_with_PCMD_content_INITIAL_CONTEXT_SETUP_REQUEST_CU_CP
    [Tags]    QC_32404       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
    CB008411_Precondtion
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=1  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=minimum   trace_plmn=310:260
    UE Register And PDU Session Setup    ue_id=1  plmn_id=310:260  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=1
    [Teardown]    TC01 Teardown

CB008411_A_TC002_Activation_Deactivation_of_Subscriber_Trace_with_PCMD_content_NGAP_TRACE_START
    [Tags]    QC_32403       QCD_MN_RAN     QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
#    CB008411_Precondtion
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=1  plmn_id=310:260  cell_id=1   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=1
    UE Register And PDU Session Setup    ue_id=2  plmn_id=310:260 cell_id=1  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=2
    UE Register And PDU Session Setup    ue_id=3  plmn_id=310:260 cell_id=1   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=3
    Start Subscriber Trace   ue_id=1  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum  trace_plmn=310:260
    Start Subscriber Trace   ue_id=2   trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium  trace_plmn=310:260
    Start Subscriber Trace   ue_id=3   trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum  trace_plmn=310:260
    ${meas_id_a2_ho}   Get Measurement id   ue_id=3  event_type=A2   carrierfreq=520110   threshold=54
    Trigger Measurement Report   ue_id=3   meas_id=${meas_id_a2_ho}    event_type=A2   srsrp_nr=30
    [Teardown]    TC02 Teardown

CB008411_B_TC002_Activation_of_the_Subscriber_Trace_with_PCMD_UE_Attach
    [Tags]    QC_32410       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
#    CB008411_Precondtion
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=1  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum  trace_plmn=310:260
    UE Register And PDU Session Setup    ue_id=1  plmn_id=310:260  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=1
    Trigger ICS With Trace Start    ue_id=2  trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium  trace_plmn=310:260
    UE Register And PDU Session Setup    ue_id=2  plmn_id=310:260  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=2
    Trigger ICS With Trace Start    ue_id=3  trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum  trace_plmn=310:260
    UE Register And PDU Session Setup    ue_id=3  plmn_id=310:260  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=3
   [Teardown]    TC03 Teardown

CB008411_B_TC002_Activation_of_the_Subscriber_Trace_with_non_PCMD_UE_Attach
    [Tags]    QC_xxxx       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
#    CB008411_Precondtion
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=1  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=min_without_vse  trace_plmn=310:260
    UE Register And PDU Session Setup    ue_id=1  plmn_id=310:260  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=1
    Trigger ICS With Trace Start    ue_id=2  trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=med_without_vse  trace_plmn=310:260
    UE Register And PDU Session Setup    ue_id=2  plmn_id=310:260  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=2
    Trigger ICS With Trace Start    ue_id=3  trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=max_without_vse  trace_plmn=310:260
    UE Register And PDU Session Setup    ue_id=3  plmn_id=310:260  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=3
   [Teardown]    TC04 Teardown

CB008411_B_TC003_Activation_of_the_Subscriber_Trace_with_PCMD_content_Trace_Start
    [Tags]    QC_32411       QCD_MN_RAN     QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
#    CB008411_Precondtion
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=1  plmn_id=310:260   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=1
    UE Register And PDU Session Setup    ue_id=2  plmn_id=310:260  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=2
    UE Register And PDU Session Setup    ue_id=3  plmn_id=310:260  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=3
    Start Subscriber Trace   ue_id=1  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum  trace_plmn=310:260
    Start Subscriber Trace   ue_id=2   trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium  trace_plmn=310:260
    Start Subscriber Trace   ue_id=3   trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum  trace_plmn=310:260
    [Teardown]    TC05 Teardown

CB008411_A_TC010_Activation_of_Subscriber_Trace_with_PCMD_content_CA
    [Tags]    QC_32402       QCD_MN_RAN     QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
#    CB008411_Precondtion
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=1  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=minimum  trace_plmn=310:260
    UE Register And PDU Session Setup    ue_id=1  plmn_id=310:260  cell_id=8  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=1  trf_id=1  direction=dl
    Start data traffic in egate   ue_id=1  trf_id=2  direction=dl
    Start data traffic in egate   ue_id=1  trf_id=3  direction=dl
    ${meas_id_a1_scell_addition}  Get Measurement id   ue_id=1  event_type=A1   carrierfreq=396970    threshold=40
    Trigger Measurement Report   ue_id=1  meas_id=${meas_id_a1_scell_addition}    event_type=A1   srsrp_nr=100
    Check traffic status
    [Teardown]    TC06 Teardown

CB012629_SR_A_B103_14_Successful_PCMD_SBA_trace_activation_Records_buffering_Inactivate_UE_CB008225_B_B2
    [Tags]    QC_132238       QCD_MN_RAN      QCP_RAN_VRF
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
    CB008411_Precondtion
    Activate CB008225
    wait until keyword succeeds    5 min    10 sec    Airphone Verify bts status
    sleep  120s
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Trigger ICS With Trace Start    ue_id=1  trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium  trace_plmn=310:260
    Update UE capa    ue_id=1     SA_Capa_perUE_Full=${UE_Capa_Support_CAaware}
    UE Register And PDU Session Setup    ue_id=1  plmn_id=310:260  cell_id=1  pass_regexp=${releasePreference_check}
    Start data traffic in egate   ue_id=1
    Send UAI to gNB   ue_id=1    state=inactive     pass_regexp=${inactive_check}
    Start Collect Wireshark For GNB
    Trigger RRC Resume wo Action
    ...    ue_id=1  gnb_id=2  cell_id=1  msg=resume_request_1  cause=mt_Access    pass_regexp=${resume_check}
    [Teardown]    TC014 Teardown

*** Keywords ***
TC01 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    UE Deregister From gNB    ue_id=1
    Trigger ICS With Trace Stop   ue_id=1
    Log Collection    operation=stop_and_download   log_type=syslog   product_type=gnb   bts_index=${0}
    Check multi tracerecords   tracerecords=${cucp_tracerecords}  host=sba  traceId=00:00:01  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_minimum}  capture_file_path=${local_file_path}
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

TC02 Teardown
     sleep  30s
     ${local_file_path}   Stop Wireshark log For GNB
     Log Collection    operation=stop_and_download   log_type=syslog   product_type=gnb   bts_index=${0}
     Multi UE Detach   start=1  num=4
     Multi UE ICS With Trace Stop  start=1  num=4
     Check common tracerecords   tracerecords=${f1ap_trace_activate_maximum}  capture_file_path=${local_file_path}
     Check common tracerecords   tracerecords=${f1ap_trace_activate_medium}  capture_file_path=${local_file_path}
     Check common tracerecords   tracerecords=${f1ap_trace_activate_minimum}  capture_file_path=${local_file_path}
#     ${trace_records}   Check tracerecords   tracerecords=${cucp_mea_tracerecords}  host=mba  traceId=000003  capture_file_path=${local_file_path}
#     Should Not Be Empty     ${trace_records}
     ${trace_records}   Check tracerecords   tracerecords=${cucp_mea_tracerecords}  host=sba  traceId=00:00:03  capture_file_path=${local_file_path}
     Should Not Be Empty     ${trace_records}
     ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

TC03 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    Log Collection    operation=stop_and_download   log_type=syslog   product_type=gnb   bts_index=${0}
    Multi UE Detach   start=1  num=4
    Multi UE ICS With Trace Stop  start=1  num=4
    Check common tracerecords   tracerecords=${f1ap_trace_activate_maximum}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_medium}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_minimum}  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=00:00:01  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=00:00:02  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=00:00:03  capture_file_path=${local_file_path}
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

TC04 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    Log Collection    operation=stop_and_download   log_type=syslog   product_type=gnb   bts_index=${0}
    Multi UE Detach   start=1  num=4
    Multi UE ICS With Trace Stop  start=1  num=4
    Check common tracerecords   tracerecords=${f1ap_trace_activate_min_without_vse}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_med_without_vse}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_max_without_vse}  capture_file_path=${local_file_path}
    Check no tracerecords    tracerecords=${cuup_tracerecords}  host=sba  traceId=000001  capture_file_path=${local_file_path}
    Check no tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=000002  capture_file_path=${local_file_path}
    Check no tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=000003  capture_file_path=${local_file_path}
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

TC05 Teardown
    sleep  30s
    Multi UE Detach   start=1  num=4
    Multi UE ICS With Trace Stop  start=1  num=4
    ${local_file_path}   Stop Wireshark log For GNB
    Log Collection    operation=stop_and_download   log_type=syslog   product_type=gnb   bts_index=${0}
    Check multi tracerecords   tracerecords=${cuup_throughput_tracerecords}  host=sba  traceId=00:00:01  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_throughput_tracerecords}  host=sba  traceId=00:00:02  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_throughput_tracerecords}  host=sba  traceId=00:00:03  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${duup_tracerecords}  host=sba  traceId=00:00:01  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${duup_tracerecords}  host=sba  traceId=00:00:02  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${duup_tracerecords}  host=sba  traceId=00:00:03  capture_file_path=${local_file_path}
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

TC06 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    Log Collection    operation=stop_and_download   log_type=syslog   product_type=gnb   bts_index=${0}
    UE Deregister From gNB    ue_id=1
    Trigger ICS With Trace Stop   ue_id=1
    Check common tracerecords   tracerecords=${f1ap_trace_activate_minimum}  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cucp_ca_tracerecords}  host=sba  traceId=00:00:01  capture_file_path=${local_file_path}
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

TC014 Teardown
    sleep  20s
    ${local_file_path}   Stop Wireshark log For GNB
    Log Collection    operation=stop_and_download   log_type=syslog   product_type=gnb   bts_index=${0}
    UE Deregister From gNB      ue_id=1
    Trigger ICS With Trace Stop   ue_id=1
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords_after_resume}  host=mba  traceId=ffffff  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords_after_resume}  host=sba  traceId=00:00:02  capture_file_path=${local_file_path}
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

CB008411_Precondtion
    Run Keyword And Ignore Error   Scout_cli start
    Prepare_env

Prepare_env
    Case Precondition  operation=env_setup_sansa   tag=${NONE}  customer=TMO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
#    Airphone Operation  edaemon_egate_setup  gnb  tag=${NONE}  customer=TMO
    Parameter Operation    operation=delta_plan_update   product_type=gnb  delta_file_path=${case_path}/config/CB0012629.json