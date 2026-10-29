*** Settings ***
Documentation
...    contact:             torsten.dieckmann@nokia.com
...    Description:         Test suite to check Ulm common library tcpdump.robot against AP TL.


Resource    ../tcpdump.robot
Resource    ../testline.robot
Library    OperatingSystem
Library    Collections


*** Test Cases ***
Test Start Stop Tcpdump on TestPc
    [TAGS]              TCPDUMP
    ${collector_name}=  Start Tcpdump On TestPc
    ...                    options=-i any sctp or icmp
    ...                    collector=my_private_collector_name
    Should Be Equal   ${collector_name}   my_private_collector_name   ERROR: Unexpected collector name returned!
    Sleep   10
    ${tcpdump_file}=    Stop Tcpdump On TestPc   collector=${collector_name}
    File Should Exist           ${tcpdump_file}
    File Should Not Be Empty    ${tcpdump_file}



Test Start Stop Tcpdump on gNB Common Unit
    [TAGS]              TCPDUMP
    ${gnb_collector}=  Start Tcpdump On GNB Common Unit  options=-i any
    Should Not Be Empty   ${gnb_collector}   ERROR: Returned collector name is empty!
    Sleep   10
    ${pcap_file}=   Stop Tcpdump On GNB Common Unit   collector=${gnb_collector}
    File Should Exist           ${pcap_file}
    File Should Not Be Empty    ${pcap_file}


Test Start Stop Tcpdump on AP Common Unit
    [TAGS]              TCPDUMP
    ${ap_collector}=  Start Tcpdump On AP Common Unit  options=-i any
    Should Not Be Empty   ${ap_collector}   ERROR: Returned collector name is empty!
    Sleep   10
    ${pcap_file}=   Stop Tcpdump On AP Common Unit   collector=${ap_collector}
    File Should Exist           ${pcap_file}
    File Should Not Be Empty    ${pcap_file}

