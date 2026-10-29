*** Settings ***
Documentation
...   Author: Zhan Yangjun
...   Contact: yangjun.zhan@nokia-sbell.com
...   Description: This is the module test case

Resource    ../../T01/Resources/pet_allm.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot


Suite Setup        Common Suite Setup For AIC
Suite Teardown     Common Suite Teardown For AIC


Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    STATE_SKIP_AGENT
...               CA_RAN_PZ_HAZ_1    RAN_VRF_HAZ1    TA_LEVEL_22

Test Timeout      60 minutes

*** Variables ***
&{dcap_info}    host=10.69.9.51    port=443    username=dcapuser    password=Nokia1234!
#  case part data:

#  PA part
&{PA_info}              PA_device=pa    PA_model=jxb     PA_host=10.97.65.30    PA_port=23    PA_totalinport=16
...                     PA_totaloutport=8
...                     PA_points_cell1=A1B1,A3B2
...                     PA_points_cell2=A5B3,A7B4
...                     PA_points_cell3=A2B1,A4B2
...                     PA_points_cell4=A6B3,A8B4
...                     PA_points_cell_all=A1B1,A3B2,A5B3,A7B4,A2B1,A4B2,A6B3,A8B4
...                     PA_signal_open=0    PA_signal_close=120
...                     PA_signal_20db=10    PA_signal_40db=20    PA_signal_60db=40

#  Counter part
${wait_time}    300
${counter_rule_folder}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test/Counter_Operation_Rule

${scf_path_file_test1}    ${CURDIR}/TC33_34.xml
${scf_path_file_test2}    ${CURDIR}/TC37_38.xml
${gnb_index}    0
#QC part
${TC33_passed}    ${False}

${INSTALL_BUILD}    NO

*** Test Cases ***
# Normal cases
TC06_CB012121
    [Tags]    CRT   QC_68409
    [Documentation]
    ...    Author: yangjun.zhan@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.08.2024, yangjun.zhan@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vcu
    ...                                      delta_file_path=${CURDIR}/Delta_TC06_VCU.json
    Log To Console    VDU delta plan update result: ${out}
    Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Change PA settings    ${PA_info.PA_points_cell_all}    ${PA_info.PA_signal_close}
    Change PA settings    ${PA_info.PA_points_cell1}    ${PA_info.PA_signal_20db}
    TC06_Counter_Operation_List_Counter_Rule_Start
    ${UE1}    ${ip1}=    Prepare and attach Xiaomi13
    Pet UE Make Voice Call    ue=${ue1}    number=+6688
    sleep    15s
    Change PA settings    ${PA_info.PA_points_cell1}    ${PA_info.PA_signal_60db}
    sleep    2s
    Change PA settings    ${PA_info.PA_points_cell2}    ${PA_info.PA_signal_40db}
    sleep    2s
    Change PA settings    ${PA_info.PA_points_cell3}    ${PA_info.PA_signal_20db}
    sleep    10s
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nWireshark log of VDU: ${local_file_path}
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu   bts_index=${0}    cudu_index=${0}
    Log To Console    \nWireshark log of VCU: ${local_file_path}
    sleep    30s
    TC06_Counter_Operation_List_Counter_Rule_Check
    Log To Console    \nSyslog of VDU: ${local_file_path}
    Log To Console    \nSyslog of VCU: ${local_file_path}
    Log To Console    \nSnapshot of VDU: ${local_file_path}
    Log To Console    \nSnapshot of VCU: ${local_file_path}
    ${local_file_path}    Log Collection    start    syslog    product_type=vdu    bts_index=${0}    cudu_index=${0}
    ${local_file_path}    Log Collection    start    syslog    product_type=vcu    bts_index=${0}    cudu_index=${0}
    ${local_file_path}    Log Collection    start    snapshot    product_type=vdu    bts_index=${0}    cudu_index=${0}
    ${local_file_path}    Log Collection    start    snapshot    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Pet UE Cancel Voice Call    ue=${ue1}
    #Pet Ue Deattach     ue=${UE1}    points=432,1600;923,1643
    Pet Ue Deattach     ue=${UE1}    points=713,1586;925,1640
    Change PA settings    ${PA_info.PA_points_cell_all}    ${PA_info.PA_signal_close}
    [Teardown]    Common Test Teardown For AIC

TC13_CB012121
    [Tags]    CRT   QC_68410
    [Documentation]
    ...    Author: yangjun.zhan@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.08.2024, yangjun.zhan@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vcu
    ...                                      delta_file_path=${CURDIR}/Delta_TC13_VCU.json
    Log To Console    VDU delta plan update result: ${out}
    Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Change PA settings    ${PA_info.PA_points_cell_all}    ${PA_info.PA_signal_close}
    Change PA settings    ${PA_info.PA_points_cell1}    ${PA_info.PA_signal_20db}
    TC13_Counter_Operation_List_Counter_Rule_Start
    ${UE1}    ${ip1}=    Prepare and attach Xiaomi13
    Pet UE Make Voice Call    ue=${ue1}    number=+6688
    sleep    15s
    Change PA settings    ${PA_info.PA_points_cell1}    ${PA_info.PA_signal_60db}
    sleep    2s
    Change PA settings    ${PA_info.PA_points_cell2}    ${PA_info.PA_signal_40db}
    sleep    2s
    Change PA settings    ${PA_info.PA_points_cell3}    ${PA_info.PA_signal_20db}
    sleep    10s
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nWireshark log of VDU: ${local_file_path}
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu   bts_index=${0}    cudu_index=${0}
    Log To Console    \nWireshark log of VCU: ${local_file_path}
    sleep    30s
    TC13_Counter_Operation_List_Counter_Rule_Check
    Log To Console    \nSyslog of VDU: ${local_file_path}
    Log To Console    \nSyslog of VCU: ${local_file_path}
    Log To Console    \nSnapshot of VDU: ${local_file_path}
    Log To Console    \nSnapshot of VCU: ${local_file_path}
    ${local_file_path}    Log Collection    start    syslog    product_type=vdu    bts_index=${0}    cudu_index=${0}
    ${local_file_path}    Log Collection    start    syslog    product_type=vcu    bts_index=${0}    cudu_index=${0}
    ${local_file_path}    Log Collection    start    snapshot    product_type=vdu    bts_index=${0}    cudu_index=${0}
    ${local_file_path}    Log Collection    start    snapshot    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Pet UE Cancel Voice Call    ue=${ue1}
    Pet Ue Deattach     ue=${UE1}    points=713,1586;925,1640
    Change PA settings    ${PA_info.PA_points_cell_all}    ${PA_info.PA_signal_close}
    [Teardown]    Common Test Teardown For AIC

[1][1.0] CB012721_TC33
    [Tags]    CRT   QC_117732
    [Documentation]
    ...    Author: Zhan Yangjun
    ...    history change: <date>,<who>,<what and how>
    ...    16.10.2024, yangjun.zhan@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC
    [Timeout]    72h
    ${out1}            Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vcu
    ...              scf_path=${scf_path_file_test1}   should_activate=${False}
    Log To Console    VDU full commission result: ${out1}
    ${out2}            Run Keyword And Ignore Error    Parameter Operation    operation=full_commission   product_type=vcu
    ...              scf_path=${scf_path_file_test2}   should_activate=${False}
    Log To Console    VDU full commission result: ${out2}
    Set Suite Variable    ${TC33_passed}    ${True}
    [Teardown]    Common Test Teardown For AIC

[1][1.0] CB012721_TC34
    [Documentation]
    [Tags]    CRT   QC_117733
    [Setup]    Empty Setup
    should be true    ${TC33_passed}
    [Teardown]

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

TC06_Counter_Operation_List_Counter_Rule_Start
    [Tags]    TC06    Counter
    ${rule1}    Catenate
    ...         Distname: MRBTS-37668/NRBTS-37668/NRCELL-7;
    ...         Counter: M55142C00523;
    ...         Counter rule: max(M55142C00523)>0
    ${rule2}    Catenate
    ...         Distname: MRBTS-37668/NRBTS-37668/NRCELL-7;
    ...         Counter: M55142C00524;
    ...         Counter rule: max(M55142C00524)==1
    ${rule3}    Catenate
    ...         Distname: MRBTS-37668/NRBTS-37668/NRCELL-7;
    ...         Counter: M55142C00525;
    ...         Counter rule: max(M55142C00525)>0
    ${rule4}    Catenate
    ...         Distname: MRBTS-37668/NRBTS-37668/NRCELL-7;
    ...         Counter: M55142C00526;
    ...         Counter rule: max(M55142C00526)>=8
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0    counter_rule=${rule_list}

TC06_Counter_Operation_List_Counter_Rule_Check
    FOR    ${i}    IN RANGE    1    ${wait_time}
        Sleep    1s
        ${rest_time}    Evaluate    ${wait_time}-${i}
        Run Keyword If    ${rest_time}%10==0    Log To Console    \nStill need to wait ${rest_time}s
        Run Keyword If    ${rest_time}==0    Log To Console    \nWaiting ends, start to collect counters!
    END
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect Result is: ${result}

TC13_Counter_Operation_List_Counter_Rule_Start
    [Tags]    TC13    Counter
    ${rule1}    Catenate
    ...         Distname: MRBTS-37668/NRBTS-37668/NRCELL-7;
    ...         Counter: M55142C00523;
    ...         Counter rule: max(M55142C00523)==0
    ${rule2}    Catenate
    ...         Distname: MRBTS-37668/NRBTS-37668/NRCELL-7;
    ...         Counter: M55142C00524;
    ...         Counter rule: max(M55142C00524)==1
    ${rule3}    Catenate
    ...         Distname: MRBTS-37668/NRBTS-37668/NRCELL-7;
    ...         Counter: M55142C00525;
    ...         Counter rule: max(M55142C00525)==0
    ${rule4}    Catenate
    ...         Distname: MRBTS-37668/NRBTS-37668/NRCELL-7;
    ...         Counter: M55142C00526;
    ...         Counter rule: max(M55142C00526)>=8
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0    counter_rule=${rule_list}

TC13_Counter_Operation_List_Counter_Rule_Check
    FOR    ${i}    IN RANGE    1    ${wait_time}
        Sleep    1s
        ${rest_time}    Evaluate    ${wait_time}-${i}
        Run Keyword If    ${rest_time}%10==0    Log To Console    \nStill need to wait ${rest_time}s
        Run Keyword If    ${rest_time}==0    Log To Console    \nWaiting ends, start to collect counters!
    END
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect Result is: ${result}

CU Check Maximum Plan Number And Delete One If Reach Maximum Number
    Login To vCU By Rest
    ${all_plans}   cu.get_staged_plans_list
    Should Be True  ${all_plans.__len__()}<=3
    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    Run Keyword If  ${all_plans.__len__()}==3   cu.plan_delete   plan_id=${all_plans[0]["plan_id"]}
    Run Keyword And Ignore Error  Logout To vCU By Rest

Empty Setup
    Log To Console  Ok



