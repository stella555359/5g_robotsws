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

CNI_121501_TC05_Verify_incoming_A2_MR_during_PDU_Session_Resource_modify_VONR
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report for RRC Release with Redirection
    ...       during PDU Session Resource Setup – subsequent PDU Session
    Case Precondition   tag=CLOUD_5G_I_LO_AP_LO_EC
#    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_LO_AP_LO_VONR
    Activate Feature    feature=a2_redirect.json
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Register  ue_id=1
    sleep  5s
    PDU Setup to add DRB   ue_id=1   pdu_id=1   gw_id=1  nwslice=2   pass_regexp=QoS Routing Table
    Hold RRC Reconfiguration Complete   ue_id=1
    ${meas_id}  Get Measurement id   ue_id=1  event_type=A2  carrierfreq=636576  threshold=38
    PDU Modify to add DRB  ue_id=1  pdu_id=1  qosflows=2   pass_regexp=${None}
    Trigger Measurement Report  ue_id=1  event_type=A2  meas_id=${meas_id}
    [Teardown]   TC05 Teardown  ue_id=1

CNI_121501_TC06_Verify_incoming_A2_MR_during_PDU_Session_Resource_Setup_with_emergency_call
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report for RRC Release with Redirection
    ...       during PDU Session Resource Setup – subsequent PDU Session
    ...     M55125C05505 NNGCC_PDU_SES_STP_REQ_EC_RECD
    ...     M55125C05506  NGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55125C05509  NGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510   NGCC_PDUSESMODRSP_SUC_EC_SENT
    Case Precondition   tag=CLOUD_5G_I_LO_AP_LO_EC
#    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_LO_AP_LO
    Activate Feature    feature=a2_redirect.json
    Start DCAP logs   log_type=emil
    sleep  40s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    Set Qosflow Priority and Reset Smf Param   priority=15
    UE Register  ue_id=1
    sleep  5s
    PDU Setup to add DRB   ue_id=1   pdu_id=1   gw_id=1  nwslice=2   pass_regexp=QoS Routing Table
    ${meas_id}  Get Measurement id   ue_id=1  event_type=A2  carrierfreq=636576  threshold=38
    Set qosflow priority and Reset smf param    priority=1
    PDU Setup to add DRB   ue_id=1   pdu_id=2   gw_id=2  nwslice=2  request_type=initial-emergency-request
    ...   pass_regexp=Pdu Session Resource Setup Response
    Hold RRC Reconfiguration Complete   ue_id=1
    PDU Modify to add DRB  ue_id=1  pdu_id=2  qosflows=2   pass_regexp=${None}
    Trigger Measurement Report  ue_id=1  event_type=A2  meas_id=${meas_id}
    [Teardown]   TC06 Teardown  ue_id=1


*** Keywords ***
TC05 Teardown
   [Arguments]   ${ue_id}=1
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   Counter Verification    counter_rule=counter_rule_tc05.txt
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}

TC06 Teardown
   [Arguments]   ${ue_id}=1
   Stop DCAP logs    log_type=emil
   sleep  10s
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   Counter Verification    counter_rule=counter_rule_tc06.txt
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}





