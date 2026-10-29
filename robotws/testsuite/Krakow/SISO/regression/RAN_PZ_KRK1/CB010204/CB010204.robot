*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010204
...   author: Marek Szlapa
...   contact: marek.szlapa@nokia.com

Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup     Common Suite Setup With OnAir Test Line Preparation
...             swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...             increase_timeout_for_update_sw=${1800}
...             prefix_tag=C_56
Suite Teardown  Common Suite Teardown

Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${ENABLE_RACH_OBSERVER}                 ${False}
${capabilities}                         REAL_UE_3

*** Test Cases ***
CB010204-SR-C_56_NR_1x6_Supercell_call
    [Setup]    Common Preconditions With Commissioning and Watching Alarms    test_config=C_56
    Require Ue for L3 Call                  capabilities=${capabilities}
    Change Network Mode           UE        nr5g    ue_type=quectel
    Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
    ...                                     duration=120s
    ...                                     tput_dl=545 Mbits/sec
    ...                                     tput_ul=40 Mbits/sec
    ...                                     deviation=30%

CB010204-SR-B_25_NR_2_Cell_20M_20M_Call_9218_A9_different_Pmax
    [Setup]    Common Preconditions With Commissioning and Watching Alarms    test_config=B_25
    Require Ue for L3 Call                  capabilities=${capabilities}
    ue.Set earfcn Lock            UE        network_mode=nr5g    earfcn=516000
    Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
    ...                                     duration=120s
    ...                                     tput_dl=175 Mbits/sec
    ...                                     tput_ul=35 Mbits/sec
    ...                                     deviation=30%
    ue.Set earfcn Lock            UE        network_mode=nr5g    earfcn=522000
    Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
    ...                                     duration=120s
    ...                                     tput_dl=175 Mbits/sec
    ...                                     tput_ul=35 Mbits/sec
    ...                                     deviation=30%
    ue.Set earfcn Lock            UE        network_mode=nr5g    earfcn=0

CB010204-SR-C_44_Concurrent_NR_40M_LTE_10M_onAir_Call_with_10600
    [Setup]    Common Preconditions With Commissioning and Watching Alarms    test_config=C_44
    Require Ue for L3 Call                  capabilities=${capabilities}
    Change Network Mode           UE        nr5g    ue_type=quectel
    Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
    ...                                     duration=120s
    ...                                     tput_dl=575 Mbits/sec
    ...                                     tput_ul=27 Mbits/sec
    ...                                     deviation=30%
    Change Network Mode           UE        lte     ue_type=quectel
    Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
    ...                                     duration=120s
    ...                                     tput_dl=137 Mbits/sec
    ...                                     tput_ul=4 Mbits/sec
    ...                                     deviation=30%
    Change Network Mode           UE        auto    ue_type=quectel

CB010204-SR-C_48_Concurrent_NR_30M_LTE_20M_onAir_Call_SplitMode_2x2T2R
    [Setup]    Common Preconditions With Commissioning and Watching Alarms    test_config=C_48
    Require Ue for L3 Call                  capabilities=${capabilities}
    Change Network Mode           UE        nr5g    ue_type=quectel
    Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
    ...                                     duration=120s
    ...                                     tput_dl=230 Mbits/sec
    ...                                     tput_ul=20 Mbits/sec
    ...                                     deviation=30%
    Change Network Mode           UE        lte     ue_type=quectel
    Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
    ...                                     duration=120s
    ...                                     tput_dl=270 Mbits/sec
    ...                                     tput_ul=8 Mbits/sec
    ...                                     deviation=30%
    Change Network Mode           UE        auto    ue_type=quectel
