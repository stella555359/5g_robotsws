*** Settings ***
Documentation
...   Test suite for regression testing of feature CB009249
...   author: Marek Szlapa
...   contact: marek.szlapa@nokia.com

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords      Common Preconditions With Watching Alarms    AND     Require Ue for L3 Call
Test Teardown     Common Postconditions With Watching Alarms


*** Variables ***
${ENABLE_RACH_OBSERVER}                 ${False}    # don't set to True, the functionality doesn't work
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}    # to debug tput problems set to True
${CUSTOM_ALLOWED_ALARMS}                [{'fault_id': 4656,'fault_name': 'Transceiver compliance validation failure'}]

${tput_dl}                4284 Mbits/sec
${tput_ul}                559 Mbits/sec
${protocol}               tcp
${duration}               300s
${deviation}              10%
${parallel_streams_dl}    8
${parallel_streams_ul}    4
${linux_congestion_dl}    bbr




*** Test Cases ***
Bi-Directional_Throughput_TCP_1-DRB_OTA_AWKUC_8CC_4CC_contiguous
    Verify L3 Call Data Transfer DL&UL    duration=${duration}
    ...                                   tput_dl=${tput_dl}
    ...                                   tput_ul=${tput_ul}
    ...                                   protocol=${protocol}
    ...                                   deviation=${deviation}
    ...                                   parallel_streams_dl=${parallel_streams_dl}
    ...                                   parallel_streams_ul=${parallel_streams_ul}
    ...                                   linux_congestion_dl=${linux_congestion_dl}
