*** Settings ***
Resource    ../tcpdump.robot
Resource    ../testline.robot
Library    OperatingSystem
Library    Collections


*** Test Cases ***
Test Start Stop Tcpdump on TestPc
    [TAGS]              TCPDUMP
    ${collector_name}=  Start Tcpdump on TestPc  interface=any
    ...                                          option=sctp or icmp
    ...                                          collector=dump_testpc
    Sleep   10
    ${tcpdump_file}=  Stop Tcpdump on TestPc  interface=any  collector=${collector_name}
    File Should Exist           ${tcpdump_file}
    File Should not be empty    ${tcpdump_file}



Test Start Stop Tcpdump on gNB Common Unit Master Node
    [TAGS]              TCPDUMP
    ${gnb_collector}=  Start Tcpdump on gNB Common Unit  interface=any
    Sleep   10
    ${pcap_file}=   Stop Tcpdump on gNB Common Unit   collector=${gnb_collector}
    File Should Exist           ${pcap_file}
    File Should not be empty    ${pcap_file}


Test Start Stop Tcpdump on gNB Common Unit Slave Node
    [TAGS]              TCPDUMP
    ${cu_type}=   Get Common Unit Type
    Run Keyword If  $cu_type!='ASIK'    Run Keywords
    ...     Run Keyword And Expect Error     *   Start Tcpdump on gNB Common Unit  interface=any  node=slave
    ...     AND
    ...     Pass Execution      Test failed as expected on '${cu_type}'
    ${gnb_collector}=   Start Tcpdump on gNB Common Unit  interface=any  node=slave
    Sleep   10
    ${pcap_file}=   Stop Tcpdump on gNB Common Unit   collector=${gnb_collector}
    File Should Exist           ${pcap_file}
    File Should not be empty    ${pcap_file}


Test Start Stop Tcpdump on AP Common Unit
    [TAGS]              TCPDUMP
    ${ap_collector}=  Start Tcpdump on AP Common Unit  interface=any
    Sleep   10
    ${pcap_file}=   Stop Tcpdump on AP Common Unit   collector=${ap_collector}
    File Should Exist           ${pcap_file}
    File Should not be empty    ${pcap_file}

