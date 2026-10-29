*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: This user scenario describes



Suite Setup       Common Suite Setup For RRM
Test Setup        Common Test Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM

Test Timeout    120 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          CB008411_KeyWord.robot

*** Variables ***
${MRBTS_ID}   1
${NRBTS_ID}   1
${analysis_dict_sba}
...   filter_conditions=nsetapx.traceActivationType == sba && nsetapx.CuVendorExtensionRecordDataType == ueMeasRecord && nsetapx.traceId == 000003
${analysis_dict_mba}
...  filter_conditions=nsetapx.traceActivationType == mba && nsetapx.CuVendorExtensionRecordDataType == ueMeasRecord
*** Test Cases ***
Prepare env
    Case Precondition  operation=env_setup_sa   tag=CLOUD_5G_I_BOO_AP_LOO
#    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_BOO_AP_LOO
[1]CB008411_A_TC001_Activation_Deactivation_of_Subscriber_Trace_with_PCMD_content_INITIAL_CONTEXT_SETUP_REQUEST_CU_CP
    [Tags]    QC_32422       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=minimum
    UE Register And PDU Session Setup    ue_id=81    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=81
    [Teardown]    TC01 Teardown

[1]CB008411_A_TC002_Activation_Deactivation_of_Subscriber_Trace_with_PCMD_content_NGAP_TRACE_START
    [Tags]    QC_xxxx       QCD_MN_RAN     QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=81  cell_id=11   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=81
    UE Register And PDU Session Setup    ue_id=82  cell_id=11  pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=82
    UE Register And PDU Session Setup    ue_id=83  cell_id=11   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=83
    Start Subscriber Trace   ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum
    Start Subscriber Trace   ue_id=82   trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium
    Start Subscriber Trace   ue_id=83   trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum
    ${meas_id_a2_ho}   Get Measurement id   ue_id=83  event_type=A2   carrierfreq=424090   threshold=5
    Trigger Measurement Report   ue_id=83   meas_id=${meas_id_a2_ho}    event_type=A2   srsrp_nr=30
    [Teardown]    TC02 Teardown

[25R1]CB008411_B_TC002_Activation_of_the_Subscriber_Trace_with_PCMD_UE_Attach_01
    [Tags]    QC_82800       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum
    UE Register And PDU Session Setup    ue_id=81    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=81
    Trigger ICS With Trace Start    ue_id=82  trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium
    UE Register And PDU Session Setup    ue_id=82   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=82
    Trigger ICS With Trace Start    ue_id=83  trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum
    UE Register And PDU Session Setup    ue_id=83   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=83
   [Teardown]    TC03 Teardown

CB008411_B_TC002_Activation_of_the_Subscriber_Trace_with_non_PCMD_UE_Attach
    [Tags]    QC_xxxx       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=min_without_vse
    UE Register And PDU Session Setup    ue_id=81    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=81
    Trigger ICS With Trace Start    ue_id=82  trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=med_without_vse
    UE Register And PDU Session Setup    ue_id=82   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=82
    Trigger ICS With Trace Start    ue_id=83  trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=max_without_vse
    UE Register And PDU Session Setup    ue_id=83   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=83
   [Teardown]    TC04 Teardown

[25R1]CB008411_B_TC003_Activation_of_the_Subscriber_Trace_with_PCMD_content_Trace_Start
    [Tags]    QC_82801       QCD_MN_RAN     QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=81    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=81
    UE Register And PDU Session Setup    ue_id=82   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=82
    UE Register And PDU Session Setup    ue_id=83   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=83
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    Check no tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=00:00:03  capture_file_path=${local_file_path}
    Start Collect Wireshark For GNB
    Start Subscriber Trace   ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum
    Start Subscriber Trace   ue_id=82   trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium
    Start Subscriber Trace   ue_id=83   trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum
    [Teardown]    TC05 Teardown

[1]CB008411_A_TC010_Activation_of_Subscriber_Trace_with_PCMD_content_CA
    [Tags]    QC_32423       QCD_MN_RAN     QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=minimum
    UE Register And PDU Session Setup    ue_id=81   cell_id=11  pass_regexp=QoS Routing Table
    ${meas_id_a1_scell_addition}  Get Measurement id   ue_id=81  event_type=A1   carrierfreq=424090    threshold=70
    Trigger Measurement Report   ue_id=81  meas_id=${meas_id_a1_scell_addition}    event_type=A1   srsrp_nr=100
    [Teardown]    TC06 Teardown

[25R1]CB008411_B_TC002_Activation_of_the_Subscriber_Trace_with_PCMD_UE_Attach_02
    [Tags]    QC_82799       QCD_MN_RAN     QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
    Case Precondition  operation=env_setup_sa   tag=CLOUD_5G_I_BOO_AP_LOO
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum
    UE Register And PDU Session Setup    ue_id=81    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=81
    Trigger ICS With Trace Start    ue_id=82  trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium
    UE Register And PDU Session Setup    ue_id=82   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=82
    Trigger ICS With Trace Start    ue_id=83  trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum
    UE Register And PDU Session Setup    ue_id=83   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=83
   [Teardown]    TC03 Teardown

CB008411_B_TC003_Activation_of_the_Subscriber_Trace_with_PCMD_content_Trace_Start
    [Tags]    QC_xxxx      QCD_MN_RAN     QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    UE Register And PDU Session Setup    ue_id=81    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=81
    UE Register And PDU Session Setup    ue_id=82   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=82
    UE Register And PDU Session Setup    ue_id=83   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=83
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    Check no tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=00:00:03  capture_file_path=${local_file_path}
    Start Collect Wireshark For GNB
    Start Subscriber Trace   ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum
    Start Subscriber Trace   ue_id=82   trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium
    Start Subscriber Trace   ue_id=83   trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum
    [Teardown]    TC05 Teardown

[24R3]CB008411_B_TC002_Activation_of_the_Subscriber_Trace_with_PCMD_UE_Attach_03
    [Tags]    QC_xxxx       QCD_MN_RAN      QCP_RAN_ST
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
    Case Precondition  operation=env_setup_sa   tag=CLOUD_5G_I_BOO_AP_LOO_24R3
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    Start Collect Wireshark For GNB
    Trigger ICS With Trace Start    ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum
    UE Register And PDU Session Setup    ue_id=81    pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=81
    Trigger ICS With Trace Start    ue_id=82  trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium
    UE Register And PDU Session Setup    ue_id=82   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=82
    Trigger ICS With Trace Start    ue_id=83  trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum
    UE Register And PDU Session Setup    ue_id=83   pass_regexp=QoS Routing Table
    Start data traffic in egate   ue_id=83
   [Teardown]    TC03 Teardown

[TMO]]CB008411_B_TC003_Activation_of_the_Subscriber_Trace_with_PCMD_content_Trace_Start_TMO
    [Tags]    QC_32421       QCD_MN_RAN     QCP_RAN_VRF
    [Documentation]
    ...    Author: zhixia.qin@nokia-sbell.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    2.5.2024,zhixia.qin@nokia-sbell.com, draft
    log to console    Activate or Deactivate Trace Report
#    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
#    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    sleep  30s
    log to console    Start Collect Wireshark For GNB
#    Start Collect Wireshark For GNB
#    UE Register And PDU Session Setup    ue_id=81    pass_regexp=QoS Routing Table
#    Start data traffic in egate   ue_id=81
#    UE Register And PDU Session Setup    ue_id=82   pass_regexp=QoS Routing Table
#    Start data traffic in egate   ue_id=82
#    UE Register And PDU Session Setup    ue_id=83   pass_regexp=QoS Routing Table
#    Start data traffic in egate   ue_id=83
    sleep  30s
#    ${local_file_path}   Stop Wireshark log For GNB
    log to console    Stop Wireshark log For GNB
#    Check no tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=00:00:03  capture_file_path=${local_file_path}
#    Start Collect Wireshark For GNB
#    Start Subscriber Trace   ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum
#    Start Subscriber Trace   ue_id=82   trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium
#    Start Subscriber Trace   ue_id=83   trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum
    [Teardown]    TC08 Teardown


*** Keywords ***
TC01 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    UE Deregister From gNB    ue_id=81
    Trigger ICS With Trace Stop   ue_id=81
    Log Collection    operation=stop_and_download   log_type=syslog   product_type=gnb   bts_index=${0}
    Check multi tracerecords   tracerecords=${cucp_tracerecords}  host=sba  traceId=00:00:01  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_minimum}  capture_file_path=${local_file_path}
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

TC02 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
     Multi UE Detach   start=81  num=84
     Multi UE ICS With Trace Stop  start=81  num=84
     Check common tracerecords   tracerecords=${f1ap_trace_activate_maximum}  capture_file_path=${local_file_path}
     Check common tracerecords   tracerecords=${f1ap_trace_activate_medium}  capture_file_path=${local_file_path}
     Check common tracerecords   tracerecords=${f1ap_trace_activate_minimum}  capture_file_path=${local_file_path}
#     ${trace_records}   Check tracerecords   tracerecords=${cucp_mea_tracerecords}  host=mba  traceId=000003  capture_file_path=${local_file_path}
#     Should Not Be Empty     ${trace_records}
     ${trace_records}   Check tracerecords   tracerecords=${cucp_mea_tracerecords}  host=sba  traceId=000003  capture_file_path=${local_file_path}
     Should Not Be Empty     ${trace_records}
     ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False


TC03 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    Multi UE Detach   start=81  num=84
    Multi UE ICS With Trace Stop  start=81  num=84
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
    Multi UE Detach   start=81  num=84
    Multi UE ICS With Trace Stop  start=81  num=84
    Check common tracerecords   tracerecords=${f1ap_trace_activate_min_without_vse}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_med_without_vse}  capture_file_path=${local_file_path}
    Check common tracerecords   tracerecords=${f1ap_trace_activate_max_without_vse}  capture_file_path=${local_file_path}
    Check no tracerecords    tracerecords=${cuup_tracerecords}  host=sba  traceId=00:00:01  capture_file_path=${local_file_path}
    Check no tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=00:00:02  capture_file_path=${local_file_path}
    Check no tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=00:00:03  capture_file_path=${local_file_path}
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

TC05 Teardown
    sleep  30s
    Multi UE Detach   start=81  num=84
    Multi UE ICS With Trace Stop  start=81  num=84
    ${local_file_path}   Stop Wireshark log For GNB
    Check multi tracerecords   tracerecords=${cuup_throughput_tracerecords}  host=sba  traceId=00:00:01  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_throughput_tracerecords}  host=sba  traceId=00:00:02  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cuup_throughput_tracerecords}  host=sba  traceId=00:00:03  capture_file_path=${local_file_path}
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

TC06 Teardown
    sleep  30s
    ${local_file_path}   Stop Wireshark log For GNB
    UE Deregister From gNB    ue_id=81
    Trigger ICS With Trace Stop   ue_id=81
    Check common tracerecords   tracerecords=${f1ap_trace_activate_minimum}  capture_file_path=${local_file_path}
    Check multi tracerecords   tracerecords=${cucp_ca_tracerecords}  host=sba  traceId=00:00:01  capture_file_path=${local_file_path}
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

TC08 Teardown
    sleep  30s
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False