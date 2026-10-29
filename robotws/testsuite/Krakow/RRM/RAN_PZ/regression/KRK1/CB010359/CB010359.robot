*** Settings ***
Documentation
...
...             Suite for CB10359

Library     ./resources/resources.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
#Resource   taf/rfrl/utilities/utf_lab/utf_lab.robot    # to do
Resource    resources/resources.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***
${alias}                    UE
${capabilities}=            REAL_UE

${throughput}=              1.3 Gbits/sec
${dt_name}=                 dt1
${deviation}                30%
${direction}=               dl
${protocol}=                udp
${packet_size}=             1400
${tput}=                    1.3 Gbits/sec
${buffer_server}=           4M
${buffer_client}=           4M
${expected_tput_for_tl}=    1.1 Gbits/sec

*** Test Cases ***
USCB010359-A#01_PA_warming_up_in_first_activated_DL_slots_after_Rx-to-Tx_switching_point
    [Setup]    Run Keywords         Common Preconditions
    ...                             AND
    ...                             Prepare UE      ${alias}
    ...                                             capabilities=${capabilities}
    Deactivate feature CB010359
    Wait for site to be OnAir
    Wait for cell to be OnAir           cell_id=2
    ...                                 timeout=180
    Attach ue and run throughput        ${alias}
    ...                                 dt_name=${dt_name}
    ...                                 direction=${direction}
    ...                                 throughput=${throughput}
    ...                                 duration=60s
    ...                                 protocol=${protocol}
    ...                                 packet_size=${packet_size}
    ...                                 tput=${tput}
    ...                                 deviation=${deviation}
    ...                                 buffer_client=${buffer_client}
    ...                                 buffer_server=${buffer_server}
    Extract Dcap Logs
    ...                                 dcap_zip_dir=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    ...                                 output_dir=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    ...                                 merged_pcap_name=deactivated
    Activate feature CB010359
    Wait for site to be OnAir
    Wait for cell to be OnAir           cell_id=2
    ...                                 timeout=180
    Attach ue and run throughput        ${alias}
    ...                                 dt_name=${dt_name}
    ...                                 direction=${direction}
    ...                                 throughput=${throughput}
    ...                                 duration=180s
    ...                                 protocol=${protocol}
    ...                                 packet_size=${packet_size}
    ...                                 tput=${tput}
    ...                                 deviation=${deviation}
    ...                                 buffer_client=${buffer_client}
    ...                                 buffer_server=${buffer_server}
    Extract Dcap Logs
    ...                                 dcap_zip_dir=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    ...                                 output_dir=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    ...                                 merged_pcap_name=activated
    [Teardown]      Run Keywords
    ...             Activate feature CB010359
    ...             AND
    ...             Wait for site to be OnAir
    ...             AND
    ...             Wait for cell to be OnAir   cell_id=2    timeout=180
    ...             AND
    ...             Common Postconditions With Restore Configuration If Test Failed
