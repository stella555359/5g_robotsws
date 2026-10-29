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
   Case Precondition  operation=env_setup_sa   tag=CLOUD_5G_I_BOO_AP_LOO

CNI12501_TC15_Verify_incoming_A2_MR_during_Scell_addition_Intra_gNB
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_Pcell_Change_queue_when_A6_scell_swap_ongoing
#    [Setup]    Case Precondition   tag=CLOUD_5G_I_BOO_AP_LOO
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic   ue_id=81  cell_id=11
    ${meas_id_a1}  Get Measurement id   ue_id=81  event_type=A1   carrierfreq=424090    threshold=70
    ${meas_id_a2}  Get Measurement id   ue_id=81  event_type=A2   carrierfreq=424090   threshold=38
    Hold RRC Reconfiguration Complete    ue_id=81  delay_time=1000
    Trigger Measurement Report   ue_id=81   meas_id=${meas_id_a1}    event_type=A1   srsrp_nr=100
    Trigger Measurement Report   ue_id=81   meas_id=${meas_id_a2}    event_type=A2
    [Teardown]   TC15 Teardown  ue_id=81

CNI12501_TC16_Verify_incoming_A2_MR_during_Scell_change
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_scell_change_queue_when_A6_scell_swap_ongoing
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic  ue_id=81  cell_id=11
    ${meas_id_a1_scell_addition}  Get Measurement id   ue_id=81  event_type=A1   carrierfreq=424090    threshold=70
    ${meas_id_a2_redirect}  Get Measurement id   ue_id=81  event_type=A2   carrierfreq=424090   threshold=38
    Trigger Measurement Report   ue_id=81   meas_id=${meas_id_a1_scell_addition}    event_type=A1   srsrp_nr=81
    ${meas_id_a1_scell_change}  Get Measurement id   ue_id=81  event_type=A1   carrierfreq=424090    threshold=90
    Hold RRC Reconfiguration Complete    ue_id=81  delay_time=1000
    Trigger Measurement Report   ue_id=81   meas_id=${meas_id_a1_scell_change}    event_type=A1   srsrp_nr=100
    Trigger Measurement Report   ue_id=81   meas_id=${meas_id_a2_redirect}    event_type=A2
    [Teardown]   TC16 Teardown  ue_id=81

CNI12501_TC17_Verify_incoming_A2_MR_during_Scell_swap_A6
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_scell_change_queue_when_A6_scell_swap_ongoing
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic  ue_id=83  cell_id=11
    ${meas_id_a1_scell_addition}  Get Measurement id   ue_id=83  event_type=A1   carrierfreq=424090    threshold=70
    ${meas_id_a2_redirect}  Get Measurement id   ue_id=83  event_type=A2   carrierfreq=424090   threshold=38
    Trigger Measurement Report   ue_id=83   meas_id=${meas_id_a1_scell_addition}    event_type=A1   srsrp_nr=100
    ${meas_id_a1_scell_swap}  Get Measurement id without threshold   ue_id=83  event_type=A6   carrierfreq=518910
    Hold RRC Reconfiguration Complete    ue_id=83  delay_time=1000
#   cell1 swap to cell2
    Trigger Measurement Report for scell swap  ue_id=83   meas_id=${meas_id_a1_scell_swap}    event_type=A6   nrsrp_nr=63
    Trigger Measurement Report   ue_id=83   meas_id=${meas_id_a2_redirect}    event_type=A2
    [Teardown]   TC17 Teardown  ue_id=83

CNI12501_TC18_Verify_incoming_A2_MR_during_Scell_release_Intra_gNB
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_scell_change_queue_when_A6_scell_swap_ongoing
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic  ue_id=85  cell_id=11
    ${meas_id_a1_scell_addition}  Get Measurement id   ue_id=85  event_type=A1   carrierfreq=424090    threshold=70
    ${meas_id_a2_redirect}  Get Measurement id   ue_id=85  event_type=A2   carrierfreq=424090   threshold=38
    Trigger Measurement Report   ue_id=85   meas_id=${meas_id_a1_scell_addition}    event_type=A1   srsrp_nr=100
    ${meas_id_a2_scell_release}  Get Measurement id without threshold  ue_id=85  event_type=A2   carrierfreq=127450
    Hold RRC Reconfiguration Complete    ue_id=85  delay_time=1000
    Trigger Measurement Report for scell release  ue_id=85  meas_id=${meas_id_a2_scell_release}  scell_id=2  event_type=A2
    Trigger Measurement Report   ue_id=85   meas_id=${meas_id_a2_redirect}    event_type=A2
    [Teardown]   TC18 Teardown  ue_id=85

CNI12501_TC19_Verify_incoming_A2_MR_during_A3_Measurement_inter_frequecny
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_scell_change_queue_when_A6_scell_swap_ongoing
    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_LO_AP_LO
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE location   ue_id=82  cell_id=11
    UE Attach and Send Traffic  ue_id=82  cell_id=11
    ${meas_id_a1_scell_addition}  Get Measurement id   ue_id=82  event_type=A1   carrierfreq=424090    threshold=70
    ${meas_id_a2_redirect}  Get Measurement id   ue_id=82  event_type=A2   carrierfreq=424090   threshold=38
    Trigger Measurement Report   ue_id=82   meas_id=${meas_id_a1_scell_addition}    event_type=A1   srsrp_nr=100
    ...   pass_regexp=SCellIndex 3 activated successfully at airphone
    ${meas_id_a2_ho}  Get Measurement id   ue_id=82  event_type=A2   carrierfreq=424090   threshold=41
    Trigger Measurement Report   ue_id=82   meas_id=${meas_id_a2_ho}    event_type=A2   srsrp_nr=30
    ${meas_id_a3_ho}  Get Measurement id without threshold  ue_id=82  event_type=A3  carrierfreq=427970
    Hold RRC Reconfiguration Complete    ue_id=82  delay_time=1000
    Trigger Measurement Report with neighbor cell id  ue_id=82  meas_id=${meas_id_a3_ho}
    ...   phycell_id=62  event_type=A3  nrsrp_nr=80  pass_regexp=${None}
    Trigger Measurement Report   ue_id=82   meas_id=${meas_id_a2_redirect}    event_type=A2
    [Teardown]   TC19 Teardown  ue_id=82

CNI12501_TC20_Verify_incoming_A2_MR_during_A5_Measurement_inter_frequecny
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_scell_change_queue_when_A6_scell_swap_ongoing
    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_LO_AP_LO
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    Setup Xn Link To gNB   gnb_id=4
    UE Attach and Send Traffic  ue_id=83  cell_id=11
    ${meas_id_a1_scell_addition}  Get Measurement id   ue_id=83  event_type=A1   carrierfreq=424090    threshold=70
    ${meas_id_a2_redirect}  Get Measurement id   ue_id=83  event_type=A2   carrierfreq=424090   threshold=38
    Trigger Measurement Report   ue_id=83   meas_id=${meas_id_a1_scell_addition}    event_type=A1   srsrp_nr=100
    ${meas_id_a2_ho}  Get Measurement id  ue_id=83  event_type=A2   carrierfreq=424090   threshold=41
    Trigger Measurement Report   ue_id=83   meas_id=${meas_id_a2_ho}    event_type=A2   srsrp_nr=30
    ${meas_id_a5_ho}  Get Measurement id without threshold  ue_id=83  event_type=A5   carrierfreq=427970
    Hold RRC Reconfiguration Complete    ue_id=83  delay_time=1000
    Trigger Measurement Report with neighbor cell id   ue_id=83   meas_id=${meas_id_a5_ho}   event_type=A5
    Trigger Measurement Report   ue_id=83   meas_id=${meas_id_a2_redirect}   event_type=A2
    [Teardown]   TC20 Teardown  ue_id=83

CNI121501_TC24_Verify_incoming_A2_MR_during_DRX_Setup_release
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario Verify_incoming_A1_MR_for_scell_change_queue_when_A6_scell_swap_ongoing
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    UE Attach and Send Traffic  ue_id=84  cell_id=11
    ${meas_id_a2_redirect}  Get Measurement id   ue_id=84  event_type=A2   carrierfreq=424090   threshold=38
    ${meas_id_a1_scell_addition}  Get Measurement id   ue_id=84  event_type=A1   carrierfreq=424090    threshold=70
    Trigger Measurement Report   ue_id=84   meas_id=${meas_id_a1_scell_addition}    event_type=A1   srsrp_nr=100
    ${meas_id_a2_ho}  Get Measurement id   ue_id=84  event_type=A2   carrierfreq=424090   threshold=41
#    Hold RRC Reconfiguration Complete    ue_id=84  delay_time=1000  contains=drx_release
    Trigger Measurement Report   ue_id=84   meas_id=${meas_id_a2_ho}    event_type=A2   srsrp_nr=30
#    Trigger Measurement Report   ue_id=84   meas_id=${meas_id_a2_redirect}    event_type=A2
    ${meas_id_a3_ho}  Get Measurement id without threshold  ue_id=84  event_type=A3  carrierfreq=427970
    Trigger Measurement Report with neighbor cell id  ue_id=84  meas_id=${meas_id_a3_ho}
    ...   phycell_id=62  event_type=A3  nrsrp_nr=80
    [Teardown]   TC24 Teardown  ue_id=84

*** Keywords ***
TC15 Teardown
   [Arguments]   ${ue_id}
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}

TC16 Teardown
   [Arguments]   ${ue_id}
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}

TC17 Teardown
   [Arguments]   ${ue_id}
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}

TC18 Teardown
   [Arguments]   ${ue_id}
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}

TC19 Teardown
   [Arguments]   ${ue_id}
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}

TC20 Teardown
   [Arguments]   ${ue_id}
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}

TC24 Teardown
   [Arguments]   ${ue_id}
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}
