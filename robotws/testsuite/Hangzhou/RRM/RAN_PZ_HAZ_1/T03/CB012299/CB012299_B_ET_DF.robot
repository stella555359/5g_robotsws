*** Settings ***
Documentation
...   author: Dong Feng
...   contact: tony.1.dong@nokia-sbell.com
...   Description: This is regression case for CB012299-B new feature automation and CRT regression.
...   Test ENV: CLOUD_5G_I_MP_AP_LO

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM

Test Timeout       120 minutes

*** Variables ***
# Reduce global paramter as possilbe and automatically got from gNB or __init__.py

&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
&{fault_61616}           faultId=${61616}
&{fault_7529}            faultId=${7529}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61616}    &{fault_7529}


*** Test Cases ***
CB012299_B_8_UE call setup scenario in limited bandwidth mode
    [Documentation]
    ...    author: Dong Feng
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    This case aims to test UE re-establishment in limited bandwidth mode.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_DF
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sa
    Counter Check 20MHz DL TP
    Counter Check 20MHz UL TP
    ATTACH UE    UE_ID=1
    Start traffic on UE    UE_ID=1     TRAFFIC_RATE=150
    Sleep    10 min    reason=wait for counter ready
    Counter Check CB012299 End
    Counter Check CB012299 End

CB012299_B_7_Triggering of transition from limited bandwidth to nominal bandwidth mode
    [Documentation]
    ...    author: Dong Feng
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    This case aims to test UE re-establishment in limited bandwidth mode.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_DF
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sa
    Counter Check 20MHz DL TP
    Counter Check 20MHz UL TP
    ATTACH UE    UE_ID=1
    Start traffic on UE    UE_ID=1     TRAFFIC_RATE=150
    Sleep    10 min    reason=wait for counter ready
    Counter Check CB012299 End
    Counter Check CB012299 End
    change semiDynamicBwSize from limitedBandwidth to nominalBandwidth
    Counter Check 40MHz DL TP
    Counter Check 40MHz UL TP
    ATTACH UE    UE_ID=2
    Start traffic on UE    UE_ID=2     TRAFFIC_RATE=150
    Sleep    10s
    DEATTACH UE    UE_ID=1
    Sleep    10 min    reason=wait for counter ready
    Counter Check CB012299 End
    Counter Check CB012299 End

CB012299_B_4_Triggering of transition from nominal bandwidth to limited bandwidth mode with massive reconfiguration
    [Documentation]
    ...    author: Dong Feng
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    This case aims to test UE re-establishment in limited bandwidth mode.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_DF
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sa
    change semiDynamicBwSize from limitedBandwidth to nominalBandwidth
    Sleep    10s
    ATTACH UE    UE_ID=1
    Start traffic on UE    UE_ID=1     TRAFFIC_RATE=30
    Sleep    10s
    ATTACH UE    UE_ID=2
    Start traffic on UE    UE_ID=2     TRAFFIC_RATE=30
    Sleep    10s
    Counter Check CB012299_BC
    change semiDynamicBwSize from nominalBandwidth to limitedBandwidth
    Sleep    10 min    reason=wait for counter ready
    Counter Check CB012299 End
    DEATTACH UE    UE_ID=1
    DEATTACH UE    UE_ID=2
    Sleep    10s

    Counter Check 20MHz DL TP
    Counter Check 20MHz UL TP
    ATTACH UE    UE_ID=3
    Start traffic on UE    UE_ID=3     TRAFFIC_RATE=150
    Sleep    10 min    reason=wait for counter ready
    Counter Check CB012299 End
    Counter Check CB012299 End

CB012299-C_01_Verify counter update when transition from nominal bandwidth to limited bandwidth
    [Documentation]
    ...    author: Yin Ran
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    This case aims to Verify counter update when transition between nominal bandwidth and limited bandwidth.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_DF
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sa
    Counter Check CB012299_C_Limited_to_Nominal_BWP
    change semiDynamicBwSize from limitedBandwidth to nominalBandwidth
    Sleep    10s
    ATTACH UE    UE_ID=1
    Start traffic on UE    UE_ID=1     TRAFFIC_RATE=10
    Sleep    10s
    ATTACH UE    UE_ID=2
    Start traffic on UE    UE_ID=2     TRAFFIC_RATE=10
    Sleep    5 min    reason=wait for counter ready
    Counter Check CB012299 End
    Sleep    10s
    Counter Check CB012299_C_Nominal_to_Limited_BWP
    change semiDynamicBwSize from nominalBandwidth to limitedBandwidth
    Sleep    10s
    ATTACH UE    UE_ID=3
    Start traffic on UE    UE_ID=3     TRAFFIC_RATE=10
    Sleep    5 min    reason=wait for counter ready
    DEATTACH UE    UE_ID=1
    DEATTACH UE    UE_ID=2
    DEATTACH UE    UE_ID=3
    Sleep    10s
    Counter Check CB012299 End

*** Keywords ***
ATTACH UE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Attach UE ${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=${UE_ID}
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=${UE_ID} pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=${UE_ID} nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s

DEATTACH UE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Deattach UE ${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_deregister id\=${UE_ID} ue_deregister_type\=switch_off
    ...    pass_regexp=${None}
    sleep    3s

Start traffic on UE
    [Arguments]    ${UE_ID}    ${TRAFFIC_RATE}
    Log To Console      ${\n}============= Start traffic on UE ${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi\=1 dir\=dl trf_id\=1 mbps\=${TRAFFIC_RATE}
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi\=1 dir\=dl trf_id\=2 mbps\=${TRAFFIC_RATE}
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi\=1 dir\=dl trf_id\=3 mbps\=${TRAFFIC_RATE}
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi\=1 dir\=dl trf_id\=4 mbps\=${TRAFFIC_RATE}
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi\=1 dir\=ul mbps\=${TRAFFIC_RATE}
    ...    pass_regexp=${None}
    sleep    2s

Counter Check 20MHz DL TP
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12009;
    ...    Counter rule: max(M55319C12009)>10500000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12009;
    ...    Counter rule:  max(M55319C12009)<10550000;
    ${rule_list}    Create List     ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
#    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Counter Check 20MHz UL TP
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16009;
    ...    Counter rule: max(M55319C16009)>524000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16009;
    ...    Counter rule: max(M55319C16009)<527000;
    ${rule_list}    Create List    ${rule1}   ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
#    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Counter Check CB012299 End
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

change semiDynamicBwSize from limitedBandwidth to nominalBandwidth
    [Documentation]    change semiDynamicBwSize
    @{para_list}   Create List   semiDynamicBwSize
    @{value_list}   Create List   nominalBandwidth
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-1
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

change semiDynamicBwSize from nominalBandwidth to limitedBandwidth
    [Documentation]    change semiDynamicBwSize
    @{para_list}   Create List   semiDynamicBwSize
    @{value_list}   Create List   limitedBandwidth
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-1
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Counter Check 40MHz DL TP
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12009;
    ...    Counter rule: max(M55319C12009)>18000000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12009;
    ...    Counter rule:  max(M55319C12009)<21000000;
    ${rule_list}    Create List     ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
#    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Counter Check 40MHz UL TP
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16009;
    ...    Counter rule: max(M55319C16009)>990000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16009;
    ...    Counter rule: max(M55319C16009)<1002000;
    ${rule_list}    Create List    ${rule1}   ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
#    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Counter Check CB012299_BC
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00001;
    ...    Counter rule: max(M55166C00001)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00003;
    ...    Counter rule: max(M55166C00003)>0;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00025;
    ...    Counter rule: max(M55166C00025)>0;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00026;
    ...    Counter rule: max(M55166C00026)>0;
    ${rule_list}    Create List    ${rule1}   ${rule2}   ${rule3}  ${rule4}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
#    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Counter Check CB012299_C_Limited_to_Nominal_BWP
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00025;
    ...    Counter rule: sum(M55166C00025)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00026;
    ...    Counter rule: sum(M55166C00026)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00002;
    ...    Counter rule: sum(M55166C00002)==2;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00004;
    ...    Counter rule: sum(M55166C00004)==2;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00001;
    ...    Counter rule: sum(M55166C00001)==0;
    ${rule6}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00003;
    ...    Counter rule: sum(M55166C00003)==0;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter Check CB012299_C_Nominal_to_Limited_BWP
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00025;
    ...    Counter rule: sum(M55166C00025)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00026;
    ...    Counter rule: sum(M55166C00026)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00001;
    ...    Counter rule: sum(M55166C00001)==3;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00003;
    ...    Counter rule: sum(M55166C00003)==3;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00002;
    ...    Counter rule: sum(M55166C00002)==0;
    ${rule6}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55166C00004;
    ...    Counter rule: sum(M55166C00004)==0;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}