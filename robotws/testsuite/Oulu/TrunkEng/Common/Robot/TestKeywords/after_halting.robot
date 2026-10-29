*** Settings ***
Documentation
...   Author:   Jere Jacklin

# More scenarios can be added here whenever new functionality is needed

*** Keywords ***
Wait And Collect Snapshot After Halting
    [Arguments]    ${wait_time}
    Print Step Text                   1    Starting Wait And Collect Snapshot After Halting
    Wait Time And Reason                   ${wait_time}  Wait ${wait_time} seconds before collecting snapshot
    Print Step Text                   2    Get snapshot and ims
    Run Keyword And Continue On Failure    Get Snapshot And Ims Log

Collect Pcap Logs After Halting
    [Arguments]    ${smod_tcpdump}  ${smod_file}  ${smod_address}  ${wait_time}  ${also_bbmod}
    ...            ${bbmod_tcpdump}  ${bbmod_address}  ${bbmod_file}  ${only_bbmod}

    Print Step Text                   1    Collecting Pcap logs from BBMOD
    Run Keyword And Continue On Failure    Collect Pcap Logs  smod_tcpdump_command=${smod_tcpdump}
    ...                                                       file_on_smod=${smod_file}  smod_address=${smod_address}
    ...                                                       wait_time=${wait_time}  also_bbmod=${also_bbmod}
    ...                                                       bbmod_tcpdump_command=${bbmod_tcpdump}
    ...                                                       bbmod_address=${bbmod_address}
    ...                                                       file_on_bbmod=${bbmod_file}, only_bbmod=${only_bbmod}
    Print Step Text                   2    Get snapshot and ims
    Run Keyword And Continue On Failure    Get Snapshot And Ims Log