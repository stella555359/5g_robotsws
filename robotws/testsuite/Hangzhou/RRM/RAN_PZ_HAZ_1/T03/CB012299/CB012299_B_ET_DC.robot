*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
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
CB012299_B_14_UE re-establishment scenario in limited bandwidth mode
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    This case aims to test UE re-establishment in limited bandwidth mode.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_Reestab
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sa
    ATTACH UE    UE_ID=1
    Start traffic on UE    UE_ID=1     TRAFFIC_RATE=20
    Trigger intra-gNB reestablishment    UE_ID=1

CB012299_B_18_Re-triggering of transition to limited bandwidth mode with bulk reconfiguration during transition to nominal bandwidth
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    This case aims to test re-triggering of transition to limited bandwidth mode during transition to nominal bandwidth.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_Retrigger_Case18
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sa
    ATTACH UE    UE_ID=1
    Start traffic on UE    UE_ID=1     TRAFFIC_RATE=20
    # UE2 will be always in limited bandwidth.
    ATTACH UE    UE_ID=2
    Start traffic on UE    UE_ID=2     TRAFFIC_RATE=20
    Log To Console      ${\n}============= Trigger Transition to nominal bandwidth =============${\n}
    Modify BW size to nominal BW
    # UE3 should be attached to nominal bandwith
    ATTACH UE    UE_ID=3
    Start traffic on UE    UE_ID=3     TRAFFIC_RATE=20
    Detach UE    UE_ID=1
    # UE5-UE11 should be attached to nominal bandwith
    ATTACH UE    UE_ID=5
    Start traffic on UE    UE_ID=5     TRAFFIC_RATE=5
    ATTACH UE    UE_ID=6
    Start traffic on UE    UE_ID=6     TRAFFIC_RATE=5
    ATTACH UE    UE_ID=7
    Start traffic on UE    UE_ID=7     TRAFFIC_RATE=5
    ATTACH UE    UE_ID=8
    Start traffic on UE    UE_ID=8     TRAFFIC_RATE=5
    ATTACH UE    UE_ID=9
    Start traffic on UE    UE_ID=9     TRAFFIC_RATE=5
    ATTACH UE    UE_ID=10
    Start traffic on UE    UE_ID=10     TRAFFIC_RATE=5
    Log To Console      ${\n}============= Re-trigger Transition to limited bandwidth =============${\n}
    Modify BW size to limited BW
    # UE4 should be attached to limited bandwith
    ATTACH UE    UE_ID=4
    Start traffic on UE    UE_ID=4     TRAFFIC_RATE=20
    Detach UE    UE_ID=3
    Log To Console      ${\n}============= Wait for RRC Reconfiguration Timer expiration =============${\n}
    sleep    3 min
    # UE11 should be attached to limited bandwith
    ATTACH UE    UE_ID=11
    Start traffic on UE    UE_ID=11     TRAFFIC_RATE=5
    Detach UE    UE_ID=6
    # UE6 should be attached to limited bandwith
    ATTACH UE    UE_ID=6
    Start traffic on UE    UE_ID=6     TRAFFIC_RATE=5
    Detach UE    UE_ID=6

CB012299_B_21_Re-triggering of transition to nominal bandwidth mode during ongoing transition to limited bandwidth
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    This case aims to test re-triggering of transition to nominal bandwidth mode during ongoing transition to limited bandwidth.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_Retrigger_Case21
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sa
    ATTACH UE    UE_ID=1
    Start traffic on UE    UE_ID=1     TRAFFIC_RATE=20
    ATTACH UE    UE_ID=2
    Start traffic on UE    UE_ID=2     TRAFFIC_RATE=20
    Modify BW size to limited BW
    ATTACH UE    UE_ID=3
    Start traffic on UE    UE_ID=3     TRAFFIC_RATE=20
    Detach UE    UE_ID=1
    Detach UE    UE_ID=2
    Modify BW size to nominal BW
    Start limited BW UL throughput counter collection
    sleep    5 min
    Stop UL throughput counter collection and check counters
    Detach UE    UE_ID=3
    ATTACH UE    UE_ID=4
    Start traffic on UE    UE_ID=4     TRAFFIC_RATE=40
    Start nominal BW UL throughput counter collection
    sleep    5 min
    Stop UL throughput counter collection and check counters
    Detach UE    UE_ID=4

*** Keywords ***
ATTACH UE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Attach UE ${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=${UE_ID}
    ...    pass_regexp=now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=${UE_ID} pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=${UE_ID} nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s

Start traffic on UE
    [Arguments]    ${UE_ID}    ${TRAFFIC_RATE}
    Log To Console      ${\n}============= Start traffic on UE ${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi\=1 dir\=dl mbps\=${TRAFFIC_RATE}
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi\=1 dir\=ul mbps\=${TRAFFIC_RATE}
    ...    pass_regexp=${None}
    sleep    2s

Trigger intra-gNB reestablishment
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger intra-gNB Re-establishment =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_rrc_reestablish id\=${UE_ID} gnb\=2 cell\=1 cause\=reconfigurationFailure
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed
    sleep    3s
    Log To Console      ${\n}============= Re-establishment is completed. =============${\n}

Modify BW size to limited BW
    Log To Console      ${\n}============= Online modify bandwidth size to limited BW =============${\n}
    [Documentation]    Modify BW size of both cells to limited BW size 20MHz
    @{para_list}    Create List    semiDynamicBwSize
    @{value_list}    Create List    limitedBandwidth
    @{mo_list}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-2
    ${out}    Parameter Operation    operation=parameter_update    product_type=gnb    para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Modify BW size to nominal BW
    Log To Console      ${\n}============= Online modify bandwidth size to nominal BW =============${\n}
    [Documentation]    Modify BW size of both cells to nominal BW size 40MHz
    @{para_list}    Create List    semiDynamicBwSize
    @{value_list}    Create List    nominalBandwidth
    @{mo_list}    Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-2
    ${out}    Parameter Operation    operation=parameter_update    product_type=gnb    para_list=${para_list}
    ...      value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Detach UE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Detach UE ${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_deregister id\=${UE_ID} ue_deregister_type\=switch_off
    ...    pass_regexp=${None}
    sleep    2s

Start nominal BW UL throughput counter collection
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16009;
    ...    Counter rule: max(M55319C16009)>930000;
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Start limited BW UL throughput counter collection
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16009;
    ...    Counter rule: max(M55319C16009)<675000;
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Stop UL throughput counter collection and check counters
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}