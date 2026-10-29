*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CNI121501_Common_Keyword.robot

*** Variables ***
&{analysis_dict}    filter_conditions=f1ap.procedureCode == id-RRCDeliveryReport
*** Test Cases ***
CNI_121501_TC26_Verify_incoming_A2_MR_during_inter_gNB_NG_HO_after_handover_notify
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report inter_gNB mode
    Case Precondition   tag=CLOUD_5G_I_LOLO_AP_LOO_8574   operation=env_setup_sa
    Start DCAP logs multi BTS
    sleep  40s
#    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_LOLO_AP_LOO_8574
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    ${tcpdump_log_name_T}   Start Tcpdump Log on Target gNB
    UE Register And PDU Session Setup   ue_id=1   cell_id=1
    ${meas_id_a2_ho}  Get Measurement id   ue_id=1  event_type=A2   carrierfreq=518910   threshold=37
    Trigger Measurement Report   ue_id=1   meas_id=${meas_id_a2_ho}    event_type=A2   srsrp_nr=7
    ${meas_id_a3_ho}  Get Measurement id without threshold  ue_id=1  event_type=A3   carrierfreq=518910
    Trigger Measurement Report with neighbor cell id  ue_id=1  meas_id=${meas_id_a3_ho}
    ...   phycell_id=21  event_type=A3  nrsrp_nr=100   pass_regexp=${None}  pass_regexp=Received HandoverNotify
#    sleep   10s
#    ${meas_id_a2_re}  Get Measurement id   ue_id=1  event_type=A2   carrierfreq=518910   threshold=32
#    Hold AMF UE CTX Release Command  time_to_wait=2000
    Trigger Measurement Report   ue_id=1   meas_id=8    event_type=A2
    [Teardown]   TC26 Teardown  ue_id=1   tcpdump_log_name_T=${tcpdump_log_name_T}

*** Keywords ***
TC26 Teardown
   [Arguments]   ${ue_id}=1   ${tcpdump_log_name_T}=${None}
   sleep  10s
   Stop DCAP logs multi BTS
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   ${local_file_path_gNB2}   Stop Tcpdump Log on Target gNB      tcpdump_log_name_T=${tcpdump_log_name_T}
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}