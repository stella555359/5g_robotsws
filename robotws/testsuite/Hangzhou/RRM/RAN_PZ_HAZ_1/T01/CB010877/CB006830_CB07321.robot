*** Settings ***
Documentation
...   Author: Wang Yuhan
...   Contact: yuhan.wang@nokia-sbell.com
...   Description: This is the module test case

Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot


Suite Setup        Common Suite Setup For AIC
Suite Teardown     Common Suite Teardown For AIC


Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    STATE_SKIP_AGENT
...               CA_RAN_PZ_HAZ_1    RAN_VRF_HAZ1    TA_LEVEL_22

Test Timeout      60 minutes

*** Variables ***
&{dcap_info}    host=10.69.9.51    port=443    username=dcapuser    password=Nokia1234!

*** Test Cases ***
# Normal cases
CB006830_T01
    [Tags]    CRT   QC_32461     QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: yuhan.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.08.2024, yuhan.wang@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC

    Log To Console    VDU Reset successfully
    Log To Console    wait cell onair
    sleep  240s
    Check both vDU and vCU cells should be onair
#    Sleep    100s
#    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  800s   30s
#    ...                            vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    [Teardown]    Common Test Teardown For AIC

CB006830_T02
    [Tags]    CRT   QC_32460    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: yuhan.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.08.2024, yuhan.wang@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC

    Log To Console    Cell Group Reset successfully
    Log To Console    wait cell onair
    sleep  120s
    Check both vDU and vCU cells should be onair
#    Sleep    100s
#    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  800s   30s
#    ...                            vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    [Teardown]     Common Test Teardown For AIC

CB007321_T01
    [Tags]    CRT   QC_32420    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: yuhan.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.08.2024, yuhan.wang@nokia-sbell.com, draft

    log to console    Activate or Deactivate Trace Report
#    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
#    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    sleep  30s
    log to console    Start Collect Wireshark For GNB
#    Start Collect Wireshark For GNB
#    UE Register And PDU Session Setup    ue_id=81    pass_regexp=QoS Routing Table
#    Start data traffic in egate   ue_id=81
#    UE Register And PDU Session Setup    ue_id=82   pass_regexp=QoS Routing Table
#    Start data traffic in egate   ue_id=82
#    UE Register And PDU Session Setup    ue_id=83   pass_regexp=QoS Routing Table
#    Start data traffic in egate   ue_id=83
    sleep  30s
#    ${local_file_path}   Stop Wireshark log For GNB
    log to console    Stop Wireshark log For GNB
#    Check no tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=00:00:03  capture_file_path=${local_file_path}
#    Start Collect Wireshark For GNB
#    Start Subscriber Trace   ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum
#    Start Subscriber Trace   ue_id=82   trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium
#    Start Subscriber Trace   ue_id=83   trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum
    [Teardown]     Common Test Teardown For AIC


CB007321_T02
    [Tags]    CRT   QC_32419    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: yuhan.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.08.2024, yuhan.wang@nokia-sbell.com, draft

    log to console    Activate or Deactivate Trace Report
#    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
#    Log Collection    operation=start   log_type=syslog   product_type=gnb   bts_index=${0}
    sleep  30s
    log to console    Start Collect Wireshark For GNB
#    Start Collect Wireshark For GNB
#    UE Register And PDU Session Setup    ue_id=81    pass_regexp=QoS Routing Table
#    Start data traffic in egate   ue_id=81
#    UE Register And PDU Session Setup    ue_id=82   pass_regexp=QoS Routing Table
#    Start data traffic in egate   ue_id=82
#    UE Register And PDU Session Setup    ue_id=83   pass_regexp=QoS Routing Table
#    Start data traffic in egate   ue_id=83
    sleep  30s
#    ${local_file_path}   Stop Wireshark log For GNB
    log to console    Stop Wireshark log For GNB
#    Check no tracerecords   tracerecords=${cuup_tracerecords}  host=sba  traceId=00:00:03  capture_file_path=${local_file_path}
#    Start Collect Wireshark For GNB
#    Start Subscriber Trace   ue_id=81  trace_ref_id=1  trace_rec_session_ref_id=1  trace_depth=maximum
#    Start Subscriber Trace   ue_id=82   trace_ref_id=2  trace_rec_session_ref_id=2  trace_depth=medium
#    Start Subscriber Trace   ue_id=83   trace_ref_id=3  trace_rec_session_ref_id=3  trace_depth=minimum
    [Teardown]    Common Test Teardown For AIC

*** Keywords ***
Commission Full SCF For vDU
    [Arguments]    ${scf_path}
    vDU Update Full SCF By Rest    scf_path=${scf_path}
    ...                               vdu_index=${0}

Commission Full SCF For vCU
    [Arguments]    ${scf_path}   ${plan_name}=TA_plan_file
    vCU Full Commssion By Rest  path_of_commission_file=${scf_path}  plan_name=${plan_name}


Prepare and attach Xiaomi13
    ${UE1}=    Pet Ue Setup    ue_type=android     host=10.97.65.29    serialno=d2cf9fe3    os=windows    username=csv5-tester
    ...    password=Nokia123!
    Pet Ue Deattach     ue=${UE1}    points=432,1600;923,1643
    sleep    5
    Pet Ue Attach     ue=${UE1}    points=432,1600;923,1643
    sleep    10
    ${ip1}=     Pet Ue Get Ueip    ue=${UE1}
    Log     ${ip1}
    [Return]    ${UE1}    ${ip1}

Change PA settings
    [Arguments]    ${Select_Port}    ${Signal_setting}
    log    OK
    Pet Change PA Signal    devicetype=${PA_info.PA_device}    model=${PA_info.PA_model}    host=${PA_info.PA_host}
    ...                     port=${PA_info.PA_port}    totalinport=${PA_info.PA_totalinport}
    ...                     totaloutport=${PA_info.PA_totaloutport}    points=${Select_Port}    signal=${Signal_setting}

Check both vDU and vCU cells should be onair
    Log To Console    \n*** check on air state in cu ***
    wait until keyword succeeds    1200    20
    ...        Check All Cells On Air In vCU
    Log To Console    \n*** check on air state in du ***
    wait until keyword succeeds    1200    20
    ...        vDU Check All Cells Status Should Be Onair

Reset vDU
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]   Reset VDU By REST
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...   | Input Parameters | Man. | Description |
    ...   | need_check_on_air | no | if need to check cell on air |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Reset vDU With Check Cell On Air | need_check_on_air=${False} |
    ...
    log to console  Reset VDU By REST...
    vDU Login By Rest  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${out}    vdu.reset_vdu
    ${error_msg}    set variable  ${out["error_message"]}
    should contain    ${error_msg}    No error
    ${out}    Wait Until Keyword Succeeds  60   10   _Check Reset VDU Status Should Be Expected    operation_id=${out["id"]}
    ...                                                                                expected_status=ongoing

CU Check Maximum Plan Number And Delete One If Reach Maximum Number
    Login To vCU By Rest
    ${all_plans}   cu.get_staged_plans_list
    Should Be True  ${all_plans.__len__()}<=3
    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    Run Keyword If  ${all_plans.__len__()}==3   cu.plan_delete   plan_id=${all_plans[0]["plan_id"]}
    Run Keyword And Ignore Error  Logout To vCU By Rest

Empty Setup
    Log To Console  Ok



