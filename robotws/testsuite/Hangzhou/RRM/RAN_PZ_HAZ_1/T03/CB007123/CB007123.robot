*** Settings ***
Documentation
...               author: Xiaofeng Nie
...               contact: xiaofeng.nie@nokia-sbell.com
...               CB007123
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    Common MutliBTS Suite Teardown For RRM
Test Setup        Common MultiBTS Test Setup For RRM
Test Teardown     Common MultiBTS Test Teardown For RRM
Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1    VRF_HAZ_T06
...    CLOUD_5G_CLASSICAL_ANDROIDX2_CA_ASIA_ABIAL_AZNC_FXEB
Test Timeout      120 minutes


*** Variables ***
${SERIALS}      RFCWA0G52XE
${COUNTER_TIME}    120s
${DL_IPERF_SERVER}    10.68.254.195
${IPERF_OPTION}    -b 200M -t 1800 -u -i 1 -l 1024 -p 5504


*** Test Cases ***
CB007123_TC01_B1-NR activated by DL buffer overflow indication
    [Documentation]
    ...    author: xiaofeng.nie@nokia-sbell.com
    ...    06.13.2022 initail create
    [Tags]    10_5_UTE5GTL11693    SCF_10_5_UTE5GTL11693    SWCONFIG_10_5_UTE5GTL11693    CB007123_1
    ${rule1}    Catenate
    ...    Distname: MRBTS-11693/LNBTS-11693/LNCEL-11;
    ...    Counter: M8080C171;
    ...    Counter rule: max(M8080C171)>=1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-11693/LNBTS-11693/LNCEL-11;
    ...    Counter: M8001C45;
    ...    Counter rule: max(M8001C45)<=100;
    ${rule3}    Catenate
    ...    Distname: MRBTS-11693/LNBTS-11693/LNCEL-11;
    ...    Counter: M8001C46;
    ...    Counter rule: max(M8001C46)<=100;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Commercial UE Attach
    Commercial UE Start DL Traffic
    Sleep    ${COUNTER_TIME}
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    interval=1
    Log To Console    ${value1}
    Commercial UE Stop DL Traffic
    [Teardown]    Case Postcondition

CB007123_TC04_B1-NR activated by UL buffer overflow indication
    [Documentation]
    ...    author: xiaofeng.nie@nokia-sbell.com
    ...    06.13.2022 initail create
    [Tags]    10_5_UTE5GTL11693    SCF_10_5_UTE5GTL11693    SWCONFIG_10_5_UTE5GTL11693    CB007123_2
    ${rule1}    Catenate
    ...    Distname: MRBTS-11693/LNBTS-11693/LNCEL-11;
    ...    Counter: M8080C172;
    ...    Counter rule: max(M8080C172)>=1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-11693/LNBTS-11693/LNCEL-11;
    ...    Counter: M8001C16;
    ...    Counter rule: max(M8001C16)<=100;
    ${rule3}    Catenate
    ...    Distname: MRBTS-11693/LNBTS-11693/LNCEL-11;
    ...    Counter: M8001C17;
    ...    Counter rule: max(M8001C17)<=100;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Commercial UE Attach
    Commercial UE Start UL Traffic
    Sleep    ${COUNTER_TIME}
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    interval=1
    Log To Console    ${value1}
    Commercial UE Stop UL Traffic
    [Teardown]    Case Postcondition


*** Keywords ***
Commercial UE Attach
    [Documentation]
    ...    Attach UE
    Run Keyword And Ignore Error    Start Multi Bts Log
    Commercial UE Operation    attach    serialno=${SERIALS}

Commercial UE Start DL Traffic
    [Documentation]
    ...    DL UDP data
    Commercial UE Operation    start traffic    serialno=${SERIALS}    IperfOptions=${IPERF_OPTION}    direction=dl
    ...  remote_hostname=${DL_IPERF_SERVER}    remote_username=ute    remote_password=ute

Commercial UE Stop DL Traffic
    [Documentation]
    ...    Stop DL data
    Commercial UE Operation    stop traffic    serialno=${SERIALS}    IperfOptions=${IPERF_OPTION}    direction=dl
    ...  remote_hostname=${DL_IPERF_SERVER}    remote_username=ute    remote_password=ute

Commercial UE Start UL Traffic
    [Documentation]
    ...    Start UL data by Ultra Caller
    Commercial UE Operation    stop_uc_all    serialno=${SERIALS}
    Commercial UE Operation    start uc test or sequence    serialno=${SERIALS}   sequence_name=CB007123_UL

Commercial UE Stop UL Traffic
    [Documentation]
    ...    Stop UL data by Ultra Caller
    Commercial UE Operation    stop_uc_all    serialno=${SERIALS}

Commercial UE Detach
    [Documentation]
    ...    Detach UE
    Commercial UE Operation    detach    serialno=${SERIALS}

Case Postcondition
    [Documentation]
    ...    Teardown
    Run Keyword And Ignore Error    Commercial UE Detach
    Run Keyword And Ignore Error    Stop All BTSLog And Download To Local
