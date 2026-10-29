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
Resource          CB010559_Common_Keyword.robot

*** Variables ***
&{analysis_dict}    filter_conditions=f1ap.procedureCode == id-RRCDeliveryReport
*** Test Cases ***
CB010559_TC01_Inter_gNB_HO
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
     Case Precondition   tag=CLOUD_5G_I_LOLO_AP_LOO_8574   operation=env_setup_sa
#     Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_LOLO_AP_LOO_8574
     Activate Feature    feature=CB008574_gNB1.json    bts_index=${0}
     Activate Feature    feature=CB008574_gNB2.json    bts_index=${1}
     Start DCAP logs multi BTS
     sleep  60s
     Log Collection    start    syslog    product_type=gnb    bts_index=${0}
     Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
     ${tcpdump_log_name_T}   Start Tcpdump Log on Target gNB
     UE Register And PDU Session Setup   ue_id=1   cell_id=1
     PDU Setup With 5QI5 and 5QI1    ue_id=1   pdu_id=2  gw_id=2
     ${meas_id_a2_ho}  Get Measurement id   ue_id=1  event_type=A2   carrierfreq=518910   threshold=37
     Trigger Measurement Report   ue_id=1   meas_id=${meas_id_a2_ho}    event_type=A2   srsrp_nr=7
     ${meas_id_a3_ho}  Get Measurement id without threshold  ue_id=1  event_type=A3   carrierfreq=518910
#     Hold RRC Reconfiguration Complete    ue_id=1  nth=3
     Trigger Measurement Report with neighbor cell id  ue_id=1  meas_id=${meas_id_a3_ho}
     ...   phycell_id=21  event_type=A3  nrsrp_nr=100   pass_regexp=Inter-eNB handover from
#     ${meas_id_a2_re}  Get Measurement id   ue_id=1  event_type=A2   carrierfreq=518910   threshold=32
     ${meas_id_a1_scell}  Get Measurement id   ue_id=1  event_type=A1   carrierfreq=518910   threshold=30
     Trigger Measurement Report   ue_id=1   meas_id=${meas_id_a1_scell}    event_type=A1   srsrp_nr=70
    [Teardown]   TC01 Teardown  ue_id=1   tcpdump_log_name_T=${tcpdump_log_name_T}

*** Keywords ***
TC01 Teardown
   [Arguments]   ${ue_id}=1   ${tcpdump_log_name_T}=${None}
   sleep  10s
   Stop DCAP logs multi BTS
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   ${local_file_path_gNB2}   Stop Tcpdump Log on Target gNB      tcpdump_log_name_T=${tcpdump_log_name_T}
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}
   Common Test Teardown For RRM