*** Settings ***
Documentation
...               author: Xiaofeng Nie
...               contact: xiaofeng.nie@nokia-sbell.com
...               CB008927-Q
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    Common MutliBTS Suite Teardown For RRM
Test Setup        Common MultiBTS Test Setup For RRM
Test Teardown     Common MultiBTS Test Teardown For RRM
Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1    VRF_HAZ_T06
...    CLOUD_5G_CLASSICAL_ANDROIDX2_CA_ASIB_ABIO2_AEHC_AHLOA_AHFIB
Test Timeout      60 minutes


*** Variables ***
${SERIALS}      R3CW2008FDL
${COUNTER_TIME}    120s
${DL_IPERF_SERVER}    10.68.254.195
${IPERF_OPTION}    -b 200M -t 1800 -u -i 1 -l 1024 -p 5504


*** Test Cases ***
TC01_USCB008927-Q#B1_single UE in LTE-NR FDD DSS cell SA mode 10MHz with bbpooling disabled
    [Documentation]
    ...    author: xiaofeng.nie@nokia-sbell.com
    ...    06.13.2022 initail create
    [Tags]    10_5_UTE5GTL5396    SCF_10_5_UTE5GTL5396_10M    SWCONFIG_10_5_UTE5GTL5396    CB008927_1
    ${rule1}    Catenate
    ...    Distname: MRBTS-5396/NRBTS-5396/NRCELL-49;
    ...    Counter: M55308C00092;
    ...    Counter rule: max(M55308C00092)>50;
    ${rule2}    Catenate
    ...    Distname: MRBTS-5396/NRBTS-5396/NRCELL-49;
    ...    Counter: M55308C00093;
    ...    Counter rule: max(M55308C00093)>2000000;
    ${rule3}    Catenate
    ...    Distname: MRBTS-5396/NRBTS-5396/NRCELL-49;
    ...    Counter: M55365C00011;
    ...    Counter rule: max(M55365C00011)>20000;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Commercial UE Attach
    Sleep    ${COUNTER_TIME}
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb
    Log To Console    ${value1}
    [Teardown]    Case Postcondition

TC02_USCB008927-Q#B1_single UE in LTE-NR FDD DSS cell SA mode 20MHz with bbpooling enabled
    [Documentation]
    ...    author: xiaofeng.nie@nokia-sbell.com
    ...    06.13.2022 initail create
    [Tags]    10_5_UTE5GTL5396    SCF_10_5_UTE5GTL5396_20M    SWCONFIG_10_5_UTE5GTL5396    CB008927_2
    ${rule1}    Catenate
    ...    Distname: MRBTS-5396/NRBTS-5396/NRCELL-49;
    ...    Counter: M55308C00092;
    ...    Counter rule: max(M55308C00092)>100;
    ${rule2}    Catenate
    ...    Distname: MRBTS-5396/NRBTS-5396/NRCELL-49;
    ...    Counter: M55308C00093;
    ...    Counter rule: max(M55308C00093)>5000000;
    ${rule3}    Catenate
    ...    Distname: MRBTS-5396/NRBTS-5396/NRCELL-49;
    ...    Counter: M55365C00011;
    ...    Counter rule: max(M55365C00011)>50000;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Commercial UE Attach
    Sleep    ${COUNTER_TIME}
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb
    Log To Console    ${value1}
    [Teardown]    Case Postcondition


*** Keywords ***
Commercial UE Attach
    [Documentation]
    ...    Attach UE
    Run Keyword And Ignore Error    Start Multi Bts Log
    Commercial UE Operation    attach    serialno=${SERIALS}
    Commercial UE Operation    start traffic    serialno=${SERIALS}    IperfOptions=${IPERF_OPTION}    direction=dl
    ...  remote_hostname=${DL_IPERF_SERVER}    remote_username=ute    remote_password=ute

Commercial UE Detach
    [Documentation]
    ...    Detach UE
    Commercial UE Operation    stop traffic    serialno=${SERIALS}    IperfOptions=${IPERF_OPTION}    direction=dl
    ...  remote_hostname=${DL_IPERF_SERVER}    remote_username=ute    remote_password=ute
    Commercial UE Operation    detach    serialno=${SERIALS}

Case Postcondition
    [Documentation]
    ...    Teardown
    Run Keyword And Ignore Error    Commercial UE Detach
    Run Keyword And Ignore Error    Stop All BTSLog And Download To Local
