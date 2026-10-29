*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.
...   env preapre by /home/ute/MN/UTE/robotws/testsuite/Krakow/RRM/DevKr/CB008490/CB008490-EB-B301.robot


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CNI121501_Common_Keyword.robot

*** Variables ***
&{analysis_dict}    filter_conditions=f1ap.procedureCode == id-RRCDeliveryReport
${MRBTS_ID}   1
${NRBTS_ID}   2
*** Test Cases ***
Prepare_env
     Case Precondition   operation=env_setup_sa   tag=CLOUD_5G_I_LO_AP_LO_NRDC
     Activate Feature    feature=mea_switch.json

CNI121501_TC07_Verify_incoming_A2_MR_during_PDU_Session_Resource_release_with_NRDC
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report for RRC Release with Redirection
    ...       during PDU Session Resource Setup – subsequent PDU Session
    ...      M55124C01501  NRRCC_RRC_RELEASE_REDIR_NR
    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_[LO][LO]_AP_[LOO]
#    Case Precondition   tag=CLOUD_5G_I_LO_AP_LO_NRDC
#    Activate Feature    feature=a2_redirect_new.json
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
#    Set ICS none to gNB
    UE Register   ue_id=1
#    Set Internal Traffic Type To UE
#    Set Scg UL Dist Percent
#    Set ICS to gNB
    Initial PDU Session Setup
    Subsequent PDU Session Setup  ue_id=1   pdu_id=4   gw_id=4
    Send Data Traffic   inactive_timer=1
    ${meas_id_a4}  Run Keyword And Ignore Error  Get Measurement id   ue_id=1  event_type=A4  carrierfreq=2071387  threshold=44
#    Hold RRC Reconfiguration Complete   ue_id=1
    ${meas_id_a2}  Get Measurement id   ue_id=1  event_type=A2  carrierfreq=633312  threshold=32
    Trigger Measurement Report with neighbor cell id  ue_id=1  event_type=A4  meas_id=2  phycell_id=52  nrsrp_nr=85
    ...   pass_regexp=PDUSessionResourceModifyIndication
    sleep  10s
    Hold snode release Complete
    Subsequent PDU Session Release  ue_id=1   pdu_id=1
    Trigger Measurement Report  ue_id=1  event_type=A2  meas_id=${meas_id_a2}   pass_regexp=${None}
    [Teardown]   TC07 Teardown  ue_id=1

CNI_121501_TC08_Verify_incoming_A2_MR_during_PDU_Session_Resource_modify_with_NRDC
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report for RRC Release with Redirection
    ...       during PDU Session Resource Setup – subsequent PDU Session
    ...      M55124C01501  NRRCC_RRC_RELEASE_REDIR_NR
    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_[LO][LO]_AP_[LOO]
#    Case Precondition   tag=CLOUD_5G_I_LO_AP_LO
#    Activate Feature    feature=a2_redirect_new.json
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Register   ue_id=1
    Initial PDU Session Setup
    Subsequent PDU Session Setup  ue_id=1   pdu_id=4   gw_id=4
    Send Data Traffic   inactive_timer=1
    ${meas_id_a4}  Get Measurement id   ue_id=1  event_type=A4  carrierfreq=2071387  threshold=44
#    Hold RRC Reconfiguration Complete   ue_id=1
    ${meas_id_a2}  Get Measurement id   ue_id=1  event_type=A2  carrierfreq=633312  threshold=32
    Trigger Measurement Report with neighbor cell id  ue_id=1  event_type=A4  meas_id=${meas_id_a4}  phycell_id=52  nrsrp_nr=85
    ...   pass_regexp=PDUSessionResourceModifyIndication
    sleep  10s
    Hold snode release Complete
    PDU Modify to add DRB  ue_id=1  qosflows=4
    Trigger Measurement Report  ue_id=1  event_type=A2  meas_id=${meas_id_a2}   pass_regexp=${None}
    [Teardown]   TC08 Teardown  ue_id=1

*** Keywords ***
TC07 Teardown
   [Arguments]   ${ue_id}=1
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}
#   Counter Verification
#   Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}

TC08 Teardown
   [Arguments]   ${ue_id}=1
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}
#   Counter Verification
#   Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}

