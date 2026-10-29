*** Settings ***
Documentation
Resource         ./../common_setup_teardown.robot
*** Variables ***
${UE_ID}               1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
*** Test Cases ***
Super Simple Case
    Suite Setup Update GNB    log=${False}
    Suite Setup Copy WTS Config Files From QT
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start WTS And Check OnAir
    Attach NSA UE and Get Throughput    UE_ID=11    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=50    ul_tp_threshold=5
    Attach SA UE and Get Throughput    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=50    ul_tp_threshold=5

*** Keywords ***

