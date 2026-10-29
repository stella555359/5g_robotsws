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
CNI_121501_TC04_Verify_incoming_A2_MR_during_PDU_Session_Resource_Setup_VONR_with_mutli_UEs
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report for RRC Release with Redirection
    ...       during PDU Session Resource Setup – subsequent PDU Session
    Case Precondition   tag=CLOUD_5G_I_LO_AP_LO_VONR
#    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_LO_AP_LO
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    Counter Operation    operation=start_collect_counter
    ...                  product_type=gnb
    ...                  bts_index=0
    ...                  counter_rule=${case_path}/config/counter_rule_tc04.txt
    FOR    ${ue_id}    IN RANGE    1    11
        UE Register And PDU Session Setup   ue_id=${ue_id}  gw=${ue_id}
        Start data traffic in egate by kbps   ue_id=${ue_id}  direction=dl    qfi=1
        Start data traffic in egate by kbps   ue_id=${ue_id}  direction=ul    qfi=1
    END
    FOR    ${ue_id}    IN RANGE    1    6
        Hold RRC Reconfiguration Complete   ue_id=${ue_id}
        ${meas_id_a2_redirect}    Get Measurement id   ue_id=${ue_id}  event_type=A2  carrierfreq=633216  threshold=38
        PDU Setup With 5QI5 and 5QI1     ue_id=${ue_id}   pdu_id=2  gw_id=2
        Trigger Measurement Report  ue_id=${ue_id}  event_type=A2  meas_id=${meas_id_a2_redirect}
        sleep  2s
    END
    FOR    ${ue_id}    IN RANGE    6    11
        PDU Setup With 5QI5 and 5QI1     ue_id=${ue_id}   pdu_id=2  gw_id=${ue_id}
        Start data traffic in egate by kbps   ue_id=${ue_id}  direction=dl    qfi=1
        Start data traffic in egate by kbps   ue_id=${ue_id}  direction=ul    qfi=1
        sleep  2s
    END
    [Teardown]   TC01_M Teardown  ue_id=1-10

CNI_121501_TC04_Verify_incoming_A2_MR_during_PDU_Session_Resource_modify_add_VONR_with_mutli_UEs
    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. The test case is to verify the gNB behaviour for A2 Measurement Report for RRC Release with Redirection
    ...       during PDU Session Resource Setup – subsequent PDU Session
    Case Precondition   tag=CLOUD_5G_I_LO_AP_LO_VONR
#    Airphone Operation  edaemon_egate_setup  gnb  tag=CLOUD_5G_I_LO_AP_LO
    Start DCAP logs   log_type=emil
    sleep  60s
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=-i any
    Counter Operation    operation=start_collect_counter
    ...                  product_type=gnb
    ...                  bts_index=0
    ...                  counter_rule=${case_path}/config/counter_rule_tc04.txt
    FOR    ${ue_id}    IN RANGE    1    21
        UE Register And PDU Session Setup   ue_id=${ue_id}  gw=${ue_id}
        Start data traffic in egate by kbps   ue_id=${ue_id}  direction=dl    qfi=1
        Start data traffic in egate by kbps   ue_id=${ue_id}  direction=ul    qfi=1
    END
    FOR    ${ue_id}    IN RANGE    1    11
        Hold RRC Reconfiguration Complete   ue_id=${ue_id}
        ${meas_id_a2_redirect}    Get Measurement id   ue_id=${ue_id}  event_type=A2  carrierfreq=633216  threshold=38
        PDU Modify to add DRB  ue_id=${ue_id}  qosflows=2  pass_regexp=${None}
        Trigger Measurement Report  ue_id=${ue_id}  event_type=A2  meas_id=${meas_id_a2_redirect}
        sleep  2s
    END
    FOR    ${ue_id}    IN RANGE    11    21
        PDU Modify to add DRB  ue_id=${ue_id}  qosflows=2
        sleep  2s
        Start data traffic in egate by kbps   ue_id=${ue_id}   direction=dl   qfi=2
        Start data traffic in egate by kbps   ue_id=${ue_id}   direction=ul   qfi=2
    END
    [Teardown]   TC01_M Teardown  ue_id=1-20

*** Keywords ***
TC01_M Teardown
   [Arguments]   ${ue_id}=1
   sleep  20s
   Stop DCAP logs    log_type=emil
   ${local_file_path}   Log Collection    stop_and_download   wireshark   gnb
   Log Collection    stop_and_download   syslog   gnb
   Trigger UE Detach   ue_id=${ue_id}
   ${result}    Counter Operation    operation=collect_counter_and_check_rule
   Log To Console    \nCounter Rule Collect and Check Result is: ${result}
   ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict}
   sleep  600s
   Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}