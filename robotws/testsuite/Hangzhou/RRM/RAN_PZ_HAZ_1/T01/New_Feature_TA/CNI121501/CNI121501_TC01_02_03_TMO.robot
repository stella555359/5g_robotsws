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
Prepare_env
    Case Precondition  operation=env_setup_sansa   tag=${NONE}  customer=TMO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    Update Measurement Report time
    Activate or Deactivate Emil

CNI121501_TC01_Verify_incoming_A2_MR_during_PDU_Session_Resource_Setup_with_noGBR
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report for RRC Release with Redirection
    ...       during PDU Session Resource Setup – subsequent PDU Session
#    Airphone Operation  edaemon_egate_setup  gnb  tag=TMO
    Start DCAP logs   log_type=emil
    sleep  30s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic   ue_id=1
    Hold RRC Reconfiguration Complete   ue_id=1
    ${meas_id}  Get Measurement id   ue_id=1  event_type=A2  carrierfreq=520110  threshold=44
    Subsequent PDU Session Setup  ue_id=1   pdu_id=4   gw_id=4
    Trigger Measurement Report  ue_id=1  event_type=A2  meas_id=${meas_id}
    [Teardown]   TC01 Teardown  ue_id=1

121501_TC02_Verify_incoming_A2_MR_during_PDU_Session_Resource_release
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report for RRC Release with Redirection
    ...       during PDU Session Resource release – subsequent PDU Session
#    Airphone Operation  edaemon_egate_setup  gnb  tag=TMO
    Start DCAP logs   log_type=emil
    sleep  30s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic   ue_id=1
    ${meas_id}  Get Measurement id   ue_id=1  event_type=A2  carrierfreq=520110  threshold=44
    Subsequent PDU Session Setup  ue_id=1   pdu_id=4   gw_id=4
    sleep  2s
    Hold RRC Reconfiguration Complete   ue_id=1
    Subsequent PDU Session Release   ue_id=1   pdu_id=4
    Trigger Measurement Report  ue_id=1  event_type=A2  meas_id=${meas_id}
    [Teardown]   TC02 Teardown  ue_id=1

CNI121501_TC03_Verify_incoming_A2_MR_during_PDU_Session_Resource_modify_non_GBR
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report for RRC Release with Redirection
    ...       during PDU Session Resource modify – subsequent PDU Session
#    Airphone Operation  edaemon_egate_setup  gnb  tag=TMO
    Start DCAP logs   log_type=emil
    sleep  30s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic   ue_id=1
    ${meas_id}  Get Measurement id   ue_id=1  event_type=A2  carrierfreq=520110  threshold=44
    Hold RRC Reconfiguration Complete   ue_id=1
    PDU Modify to add DRB  ue_id=1  qosflows=3
    PDU Modify to add DRB  ue_id=1  qosflows=2
    Trigger Measurement Report  ue_id=1  event_type=A2  meas_id=${meas_id}
    [Teardown]   TC03 Teardown  ue_id=1

*** Keywords ***
TC01 Teardown
   [Arguments]   ${ue_id}=1
   Stop DCAP logs    log_type=emil
   sleep  10s
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}
   Counter Verification
   Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}

TC02 Teardown
  [Arguments]    ${ue_id}=1
   Stop DCAP logs    log_type=emil
   sleep  10s
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}
   Counter Verification
   Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}

TC03 Teardown
   [Arguments]    ${ue_id}=1
   Stop DCAP logs    log_type=emil
   sleep  10s
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}
   Counter Verification
   Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}