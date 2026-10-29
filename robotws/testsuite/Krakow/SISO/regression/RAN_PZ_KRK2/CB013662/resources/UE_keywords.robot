*** Settings ***
Documentation
...    Author: Slawomir Szopinski, slawomir.szopinski@nokia.com

Resource    taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${CAPABILITIES}                                         REAL_UE
${REBOOT_UE}                                            ${True}
${REBOOT_UE_TIMEOUT}                                    100
${COLLECT_LOGS_DURING_DATA_TRANSFER}                    ${False}

${DURATION_15MHz_Cell_TCP}                              120s
${THROUGHPUT_15MHz_Cell_TCP_DL}                         175 MBits/sec
${PARAREL_STREAMS_15MHz_Cell_TCP_DL}                    1
${INTERVAL_15MHz_Cell_TCP_DL}                           1
${LINUX_CONGESTION_15MHz_Cell_TCP_DL}                   reno

${THROUGHPUT_15MHz_Cell_TCP_UL}                         12 MBits/sec
${PARAREL_STREAMS_15MHz_Cell_TCP_UL}                    1
${INTERVAL_15MHz_Cell_TCP_UL}                           1
${LINUX_CONGESTION_15MHz_Cell_TCP_UL}                   reno

${DURATION_15MHz_PCell_30MHz_SCell_TCP}                 120s
${THROUGHPUT_15MHz_PCell_30MHz_SCell_TCP_DL}            560 MBits/sec
${PARAREL_STREAMS_15MHz_PCell_30MHz_SCell_TCP_DL}       1
${INTERVAL_15MHz_PCell_30MHz_SCell_TCP_DL}              1
${LINUX_CONGESTION_15MHz_PCell_30MHz_SCell_TCP_DL}      reno

${THROUGHPUT_15MHz_PCell_30MHz_SCell_TCP_UL}            11 MBits/sec
${PARAREL_STREAMS_15MHz_PCell_30MHz_SCell_TCP_UL}       1
${INTERVAL_15MHz_PCell_30MHz_SCell_TCP_UL}              1
${LINUX_CONGESTION_15MHz_PCell_30MHz_SCell_TCP_UL}      reno

${DURATION_49.5MHz_PCell_15MHz_SCell_TCP}               120s
${THROUGHPUT_49.5MHz_PCell_15MHz_SCell_TCP_DL}          835 MBits/sec
${PARAREL_STREAMS_49.5MHz_PCell_15MHz_SCell_TCP_DL}     4
${INTERVAL_49.5MHz_PCell_15MHz_SCell_TCP_DL}            1
${LINUX_CONGESTION_49.5MHz_PCell_15MHz_SCell_TCP_DL}    reno

${THROUGHPUT_49.5MHz_PCell_15MHz_SCell_TCP_UL}          48 MBits/sec
${PARAREL_STREAMS_49.5MHz_PCell_15MHz_SCell_TCP_UL}     1
${INTERVAL_49.5MHz_PCell_15MHzSCell_TCP_UL}             1
${LINUX_CONGESTION_49.5MHz_PCell_15MHz_SCell_TCP_UL}    reno

${DURATION_49.5MHz_Cell_TCP}                            120s
${THROUGHPUT_49.5MHz_Cell_TCP_DL}                       670 MBits/sec
${PARAREL_STREAMS_49.5MHz_Cell_TCP_DL}                  1
${INTERVAL_49.5MHz_Cell_TCP_DL}                         1
${LINUX_CONGESTION_49.5MHz_Cell_TCP_DL}                 reno

${THROUGHPUT_49.5MHz_Cell_TCP_UL}                       48 MBits/sec
${PARAREL_STREAMS_49.5MHz_Cell_TCP_UL}                  1
${INTERVAL_49.5MHz_Cell_TCP_UL}                         1
${LINUX_CONGESTION_49.5MHz_Cell_TCP_UL}                 reno

*** Keywords ***
Prepare Ue
    Prepare Ue for L3 Call
    ...    capabilities=${CAPABILITIES}
    ...    reboot_ue=${REBOOT_UE}
    ...    timeout_reboot_ue=${REBOOT_UE_TIMEOUT}
    ...    alias=${CAPABILITIES}

Run Bidirectional TCP Data Transfer 15MHz
    Run Keyword And Continue On Failure    Verify L3 Call Data Transfer DL&UL
    ...    alias=${CAPABILITIES}
    ...    duration=${DURATION_15MHz_Cell_TCP}
    ...    tput_dl=${THROUGHPUT_15MHz_Cell_TCP_DL}
    ...    tput_ul=${THROUGHPUT_15MHz_Cell_TCP_UL}
    ...    protocol=tcp
    ...    deviation=10%
    ...    parallel_streams_dl=${PARAREL_STREAMS_15MHz_Cell_TCP_DL}
    ...    parallel_streams_ul=${PARAREL_STREAMS_15MHz_Cell_TCP_UL}
    ...    linux_congestion_dl=${LINUX_CONGESTION_15MHz_Cell_TCP_DL}
    ...    linux_congestion_ul=${LINUX_CONGESTION_15MHz_Cell_TCP_UL}

Run Bidirectional TCP Data Transfer 15MHz PCell 30MHz SCell
    Run Keyword And Continue On Failure    Verify L3 Call Data Transfer DL&UL
    ...    alias=${CAPABILITIES}
    ...    duration=${DURATION_15MHz_PCell_30MHz_SCell_TCP}
    ...    tput_dl=${THROUGHPUT_15MHz_PCell_30MHz_SCell_TCP_DL}
    ...    tput_ul=${THROUGHPUT_15MHz_PCell_30MHz_SCell_TCP_UL}
    ...    protocol=tcp
    ...    deviation=10%
    ...    parallel_streams_dl=${PARAREL_STREAMS_15MHz_PCell_30MHz_SCell_TCP_DL}
    ...    parallel_streams_ul=${PARAREL_STREAMS_15MHz_PCell_30MHz_SCell_TCP_UL}
    ...    linux_congestion_dl=${LINUX_CONGESTION_15MHz_PCell_30MHz_SCell_TCP_DL}
    ...    linux_congestion_ul=${LINUX_CONGESTION_15MHz_PCell_30MHz_SCell_TCP_UL}

Run Bidirectional TCP Data Transfer 49.5MHz PCell 15MHz SCell
    Run Keyword And Continue On Failure    Verify L3 Call Data Transfer DL&UL
    ...    alias=${CAPABILITIES}
    ...    duration=${DURATION_49.5MHz_PCell_15MHz_SCell_TCP}
    ...    tput_dl=${THROUGHPUT_49.5MHz_PCell_15MHz_SCell_TCP_DL}
    ...    tput_ul=${THROUGHPUT_49.5MHz_PCell_15MHz_SCell_TCP_UL}
    ...    protocol=tcp
    ...    deviation=10%
    ...    parallel_streams_dl=${PARAREL_STREAMS_49.5MHz_PCell_15MHz_SCell_TCP_DL}
    ...    parallel_streams_ul=${PARAREL_STREAMS_49.5MHz_PCell_15MHz_SCell_TCP_UL}
    ...    linux_congestion_dl=${LINUX_CONGESTION_49.5MHz_PCell_15MHz_SCell_TCP_DL}
    ...    linux_congestion_ul=${LINUX_CONGESTION_49.5MHz_PCell_15MHz_SCell_TCP_UL}

Run Bidirectional TCP Data Transfer 49.5MHz
    Run Keyword And Continue On Failure    Verify L3 Call Data Transfer DL&UL
    ...    alias=${CAPABILITIES}
    ...    duration=${DURATION_49.5MHz_Cell_TCP}
    ...    tput_dl=${THROUGHPUT_49.5MHz_Cell_TCP_DL}
    ...    tput_ul=${THROUGHPUT_49.5MHz_Cell_TCP_UL}
    ...    protocol=tcp
    ...    deviation=10%
    ...    parallel_streams_dl=${PARAREL_STREAMS_49.5MHz_Cell_TCP_DL}
    ...    parallel_streams_ul=${PARAREL_STREAMS_49.5MHz_Cell_TCP_UL}
    ...    linux_congestion_dl=${LINUX_CONGESTION_49.5MHz_Cell_TCP_DL}
    ...    linux_congestion_ul=${LINUX_CONGESTION_49.5MHz_Cell_TCP_UL}
