*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Common Suite Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
#Test Teardown     Common Test Teardown For RRM

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CNI121501_Common_Keyword.robot

*** Variables ***
&{analysis_dict}    filter_conditions=f1ap.procedureCode == id-RRCDeliveryReport
*** Test Cases ***

CNI_121501_TC04_Verify_incoming_A2_MR_during_PDU_Session_Resource_Setup_with_VONR
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report for RRC Release with Redirection
    ...       during PDU Session Resource Setup – subsequent PDU Session
    Case Precondition   tag=CLOUD_5G_I_LO_AP_LO_VONR
#    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_LO_AP_LO_VONR
    Activate Feature    feature=a2_redirect.json
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic   ue_id=1
    Hold RRC Reconfiguration Complete   ue_id=1
    ${meas_id_a2_redirect}  Get Measurement id   ue_id=1  event_type=A2  carrierfreq=633216  threshold=38
    PDU Setup With 5QI5 and 5QI1     ue_id=1   pdu_id=2  gw_id=2
    Trigger Measurement Report  ue_id=1  event_type=A2  meas_id=${meas_id_a2_redirect}
    [Teardown]   TC04 Teardown  ue_id=1

*** Keywords ***
TC04 Teardown
   [Arguments]   ${ue_id}=1
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   Counter Verification    counter_rule=counter_rule_tc04.txt
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}





