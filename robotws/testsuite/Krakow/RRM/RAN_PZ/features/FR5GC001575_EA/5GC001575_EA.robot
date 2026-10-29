*** Settings ***
Documentation
...   author: Jakub Kupiec
...   contact: jakub.kupiec@nokia.com

Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Library     testsuite/Krakow/RRM/resources/Python/traffic_split_resources.py

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_QC_ASIKR_ABILB4_AEUB

Suite Setup       Perform commissioning on gNB to onAir state
Suite Teardown    Teardown Logs Collectors

*** Variables ***
${capabilities_ue}   REAL_UE
${branch_tag}        None
@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  Radio Diagnostic Files collected
...                  Diagnostic Files collected
...                  Service account root access is enabled
...                  Ethernet port security is disabled
${size_packet}         1400B
${dl_size_packet}      1400B
${ul_size_packet}      1000B
${buffer_client_dl}    8M
${buffer_server_dl}    8M
${buffer_client_ul}    2M
${buffer_server_ul}    2M
${interval}            1
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}

*** Test Cases ***
[1][1.0] 5GC000570-G_A8_Traffic_split_of_the_UL_PDCP_PDUs_I&V
    [Setup]  Test Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=30s    tput=150 Mbits/sec    protocol=udp    deviation=5%
    ...    buffer_server=${buffer_server_ul}    interval=${interval}    parallel_streams=1
    ...    size_packet=${size_packet}    buffer_client=${buffer_client_ul}
    [Teardown]  Test Postconditions

*** Keywords ***
Test Preconditions
    Run Keyword And Ignore Error     Collect logs during test
    Lock 3 out of 4 NR cells

Test Postconditions
    Unlock 3 out of 4 NR cells
    Run Keyword And Ignore Error     Collect logs after test finished
