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
&{analysis_dict}     filter_conditions=f1ap.procedureCode == id-RRCDeliveryReport
&{analysis_dict_1}   filter_conditions=nr-rrc.sCellToAddModList == 1
*** Test Cases ***

CNI_121501_TC14_Verify_incoming_A2_MR_during_Scell_release_Ext_gNB
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report inter_gNB mode
    [Setup]    Case Precondition   tag=CLOUD_5G_I_LO_AP_LO_AEQU_AEQK
#    Airphone Operation  edaemon_egate_setup  gnb  tag=5G_I_LO_AP_LO_AEQU_AEQK
    Set Sim gNB4 Parameter
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic   ue_id=1  cell_id=2
    Subsequent PDU Session Setup  ue_id=1   pdu_id=2   gw_id=2
    ${meas_id_a1}  Get Measurement id   ue_id=1  event_type=A1   carrierfreq=663360   threshold=75
    ${meas_id_a2}  Get Measurement id   ue_id=1  event_type=A2   carrierfreq=663360   threshold=38
    Hold RRC Reconfiguration Complete   ue_id=1
    Trigger Measurement Report   ue_id=1  meas_id=${meas_id_a1}  event_type=A1  srsrp_nr=90
    Trigger Measurement Report   ue_id=1  meas_id=${meas_id_a2}  event_type=A2
    [Teardown]   TC14 Teardown  ue_id=1

*** Keywords ***
TC14 Teardown
   [Arguments]   ${ue_id}=1
   sleep  20s
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict_1}





