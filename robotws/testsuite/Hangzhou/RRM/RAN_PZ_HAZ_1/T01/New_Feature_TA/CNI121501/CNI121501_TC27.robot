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
CNI_121501_TC27_Verify_incoming_A2_MR_during_Inter_RAT_Handover_to_LTE_HO_Failure_with_CGI_measurement_configuration_rollback
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report inter_gNB mode
    Case Precondition   tag=CLOUD_5G_I_LO_AP_LO_VONR_CGI
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic   ue_id=24
    ${meas_id_a2_redirect}  Get Measurement id   ue_id=24  event_type=A2   carrierfreq=633408   threshold=38
    ${meas_id_a2_ho}  Get Measurement id   ue_id=24  event_type=A2   carrierfreq=633408   threshold=34
    Trigger Measurement Report   ue_id=24   meas_id=${meas_id_a2_ho}    event_type=A2   srsrp_nr=7
    ${meas_id_a3_ho}  Get Measurement id without threshold  ue_id=24  event_type=A3   carrierfreq=633408
    Trigger Measurement Report with neighbor cell id  ue_id=24  meas_id=${meas_id_a3_ho}
    ...   phycell_id=381  event_type=A3  nrsrp_nr=100
    sleep  1s
    Hold RRC Reconfiguration Complete    ue_id=24  delay_time=2000  contains=drx_release
    Trigger Measurement Report   ue_id=24   meas_id=${meas_id_a2_redirect}    event_type=A2
    [Teardown]   TC24 Teardown  ue_id=24

*** Keywords ***
TC24 Teardown
   [Arguments]   ${ue_id}=1
   sleep  20s
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}





