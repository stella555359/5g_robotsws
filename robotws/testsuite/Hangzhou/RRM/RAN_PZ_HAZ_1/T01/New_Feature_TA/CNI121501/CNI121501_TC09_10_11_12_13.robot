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
Prepare env
   Case Precondition  operation=env_setup_sa   tag=CLOUD_5G_I_[LO][LO]_AP_[LOO]

CNI12501_TC09_Verify_incoming_A2_MR_during_PDU_Sesssion_Setup_DRB_reconfiguration_for_inter-gNB_CA
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_Pcell_Change_queue_when_A6_scell_swap_ongoing
#    [Setup]    Case Precondition   tag=CLOUD_5G_I_BOO_AP_LOO
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach To Target Cell  ue_id=1
    ${meas_id_a1}  Get Measurement id   ue_id=1  event_type=A1   carrierfreq=663360    threshold=70
    ${meas_id_a2}  Get Measurement id   ue_id=1  event_type=A2   carrierfreq=663360   threshold=38
    Trigger Measurement Report   ue_id=1   meas_id=${meas_id_a1}    event_type=A1   srsrp_nr=85
    Hold RRC Reconfiguration Complete    ue_id=1  delay_time=1000
    Subsequent PDU Session Setup   ue_id=1   pdu_id=4   gw_id=4
    Trigger Measurement Report   ue_id=1   meas_id=${meas_id_a2}    event_type=A2
    [Teardown]   TC11 Teardown  ue_id=1

CNI12501_TC10_Verify_incoming_A2_MR_during_PDU_Sesssion_Release_DRB_reconfiguration_for_inter-gNB_CA
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_scell_change_queue_when_A6_scell_swap_ongoing
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach To Target Cell  ue_id=2
    ${meas_id_a1}  Get Measurement id   ue_id=2  event_type=A1   carrierfreq=663360    threshold=70
    ${meas_id_a2}  Get Measurement id   ue_id=2  event_type=A2   carrierfreq=663360   threshold=38
    Trigger Measurement Report   ue_id=2   meas_id=${meas_id_a1}    event_type=A1   srsrp_nr=85
    Subsequent PDU Session Setup      ue_id=2   pdu_id=4   gw_id=4
    Hold RRC Reconfiguration Complete    ue_id=2  delay_time=1000
    Subsequent PDU Session Release      ue_id=2  pdu_id=4
    Trigger Measurement Report   ue_id=2   meas_id=${meas_id_a2}    event_type=A2
    [Teardown]   TC11 Teardown  ue_id=2

CNI12501_TC11_Verify_incoming_A2_MR_during_PDU_Sesssion_modify_DRB_reconfiguration_for_inter-gNB_CA
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_scell_change_queue_when_A6_scell_swap_ongoing
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach To Target Cell  ue_id=3
    ${meas_id_a1}  Get Measurement id   ue_id=3  event_type=A1   carrierfreq=663360    threshold=70
    ${meas_id_a2}  Get Measurement id   ue_id=3  event_type=A2   carrierfreq=663360   threshold=38
    Trigger Measurement Report   ue_id=3   meas_id=${meas_id_a1}    event_type=A1   srsrp_nr=85
    Send And Verify Throughput   ue_id=3
    Hold RRC Reconfiguration Complete    ue_id=3  delay_time=1000
    PDU Modify to add DRB    ue_id=3   qosflows=5
    Trigger Measurement Report   ue_id=3  meas_id=${meas_id_a2}    event_type=A2
    [Teardown]   TC11 Teardown  ue_id=3

CNI12501_TC12_Verify_incoming_A2_MR_during_Scell_addition_Inter_gnb
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_scell_change_queue_when_A6_scell_swap_ongoing
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach To Target Cell  ue_id=4
    ${meas_id_a1}  Get Measurement id   ue_id=4  event_type=A1   carrierfreq=663360    threshold=70
    ${meas_id_a2}  Get Measurement id   ue_id=4  event_type=A2   carrierfreq=663360   threshold=38
    Hold RRC Reconfiguration Complete    ue_id=4  delay_time=2000
    Trigger Measurement Report   ue_id=4   meas_id=${meas_id_a1}    event_type=A1   srsrp_nr=85
    Trigger Measurement Report   ue_id=4   meas_id=${meas_id_a2}    event_type=A2
    [Teardown]   TC11 Teardown  ue_id=4

CNI12501_TC13_Verify_incoming_A2_MR_during_Scell_release_inter_gNB
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_scell_change_queue_when_A6_scell_swap_ongoing
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach To Target Cell  ue_id=5
    ${meas_id_a1}  Get Measurement id   ue_id=5  event_type=A1   carrierfreq=663360    threshold=70
    ${meas_id_a2}  Get Measurement id   ue_id=5  event_type=A2   carrierfreq=663360   threshold=38
    Trigger Measurement Report   ue_id=5   meas_id=${meas_id_a1}    event_type=A1   srsrp_nr=85
    Send And Verify Throughput   ue_id=5
    ${meas_id_a2_rel}  Get Measurement id   ue_id=5  event_type=A2   carrierfreq=648096   threshold=33
    Hold RRC Reconfiguration Complete    ue_id=5  delay_time=2000
    Trigger Measurement Report for scell release  ue_id=5  meas_id=${meas_id_a2_rel}  scell_id=1  event_type=A2
    Trigger Measurement Report   ue_id=5   meas_id=${meas_id_a2}    event_type=A2
    [Teardown]   TC11 Teardown  ue_id=5

*** Keywords ***
TC11 Teardown
   [Arguments]   ${ue_id}
   sleep  20s
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}




