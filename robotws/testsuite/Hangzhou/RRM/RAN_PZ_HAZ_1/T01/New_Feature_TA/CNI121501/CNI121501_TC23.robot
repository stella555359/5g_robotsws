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

CNI121501_TC23_Verify_incoming_A2_MR_during_E_CID_Positioning_Reporting
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report inter_gNB mode
    Case Precondition   tag=CLOUD_5G_I_LO_AP_LO
#    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_LO_AP_LO
    Activate CB008281
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic   ue_id=1
    Hold RRC Reconfiguration Complete    ue_id=1  delay_time=3000
    ${meas_id}  Get Measurement id   ue_id=1  event_type=A2  carrierfreq=636576  threshold=38
    Trigger E-CID Measurement Initiation Request    pass_regexp=${None}
    Trigger Measurement Report  ue_id=1  event_type=A2  meas_id=${meas_id}
    [Teardown]   TC23 Teardown  ue_id=1

*** Keywords ***
TC23 Teardown
   [Arguments]   ${ue_id}=1
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}
   Get Egate console Log