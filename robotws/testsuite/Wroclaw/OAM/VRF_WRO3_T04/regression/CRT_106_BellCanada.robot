*** Settings ***
Documentation    Suite for trunk for TL106

Resource        ../features/CB009482/TestCases/CB009482.robot

Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/variables/variables.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***
${NetAct_name}=     srnclab1015

*** Test Cases ***
[1]CB009482-E-SR_ARP_counters_harmonization_on_SRAN_M51328C17_M51328C0_ASIB
    CB009482-SR-E_Rate_limit_for_ARP_packets-ipRmDropPcktsRtLimARP    TL106_ASIB    enp1s0f1.454

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown

Test Setup NMS
    Common Gathering Logs for Test Setup
    Integrate BTS to MantaRay without TLS    NMS_HOST=${SRNCLAB1015}    LAB_NAME=${NetAct_name}

Test Teardown NMS
    Deintegrate BTS from MantaRay    LAB_NAME=${NetAct_name}
    Wait until BTS reach Configured or OnAir state
    Common Gathering Logs for Test Teardown
