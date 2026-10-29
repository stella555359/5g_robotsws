*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real AP TL.
...   It verifies proper function of KWs in tshark.robot for classical deployments.


Library     OperatingSystem

Resource    ../tshark.robot
Resource    ../testline.robot

*** Test Cases ***
Test Start Stop Tshark on Test PC Eth0
    [TAGS]              TSHARK
    Start Tshark On Test PC     collector=trace_eth3    options=-i eth0
    Sleep                       2s  Wait 2s to collect some packets!
    ${tshark_dump_file}         Stop Tshark On Test PC  collector=trace_eth3
    File Should Exist           ${tshark_dump_file}
    File Should Not Be Empty    ${tshark_dump_file}

Test Start Tshark for Trace Session
    [TAGS]              TSHARK
    ${tce_collector}                Start Tshark For Trace Session
    Sleep                       2s  Wait 2s to collect some packets!
    ${tshark_dump_file}         Stop Tshark On Test PC  collector=${tce_collector}
    File Should Exist           ${tshark_dump_file}
    File Should Not Be Empty    ${tshark_dump_file}
