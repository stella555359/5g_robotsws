*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010203
...   author: Marcin Bereznicki
...   contact: marcin.bereznicki@nokia.com

Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup     Common Suite Setup With OnAir Test Line Preparation
...             prefix_tag=CB010203_C_49
...             increase_timeout_for_update_sw=${1800}
Suite Teardown  Common Suite Teardown

Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${ENABLE_RACH_OBSERVER}                 ${False}
${capabilities}                         REAL_UE_1

*** Test Cases ***
[1][2.0] CB010203-SR-C_49_Concurrent_NR_80M_LTE_20M_onAir_Call
    Require Ue for L3 Call                  capabilities=${capabilities}
    Change Network Mode           UE        nr5g    ue_type=quectel
    ue.Reboot Ue                  UE        timeout=100
    Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
    ...                                     duration=120s
    ...                                     tput_dl=1231 Mbits/sec
    ...                                     tput_ul=80 Mbits/sec
    ...                                     deviation=20%
    ...                                     protocol=tcp
    Change Network Mode           UE        lte     ue_type=quectel
    ue.Reboot Ue                  UE        timeout=100
    Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
    ...                                     duration=120s
    ...                                     tput_dl=260 Mbits/sec
    ...                                     tput_ul=16 Mbits/sec
    ...                                     deviation=20%
    ...                                     protocol=tcp
    Change Network Mode           UE        auto    ue_type=quectel
