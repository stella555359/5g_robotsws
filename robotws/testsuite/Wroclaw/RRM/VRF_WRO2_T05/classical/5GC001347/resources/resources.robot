*** Settings ***
Documentation
...   author: PZ_2_WRO_5

Library     pm_counters.py


*** Keywords ***
Verify DMRS Additional Position
    [Arguments]  ${dir}=${OUTPUT DIR}/tcpdumpL2L1_filtering_on-1347.pcap
    ${msgs}    check dmrs parameters  ${dir}
    should be true    ${msgs}
