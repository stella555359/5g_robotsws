*** Settings ***
Documentation
...    cmd: you need to change 2_16_UTE5GCLASSICAL1462 to your testline name.
...    robot -V /home/ute/Auto5G/config/Wroclaw/2_16_UTE5GCLASSICAL1686 -L trace check_gnb_state.robot
Resource         ./../common_setup_teardown.robot

*** Test Cases ***
Prepare Testline
    Suite Setup Update GNB    log=none
    Run Keyword And Ignore Error    Suite Setup Copy WTS Config Files From QT
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Add Multi UE SA    2-4
    Add Multi UE NSA    12-13

