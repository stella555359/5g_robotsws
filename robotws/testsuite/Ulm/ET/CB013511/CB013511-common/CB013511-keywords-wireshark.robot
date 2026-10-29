*** Settings ***
Documentation   This is a keyword file for CB013511 part wireshark
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library     OperatingSystem

Resource        ../../../resources/Common/tcpdump.robot


*** Variables ***

${WIRESHARK_RUNNING}     false


*** Keywords ***


Start Wireshark Trace
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Author: Sylvia Schneider
    tcpdump.Start TCPDump On TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Sleep     1s
    Set Suite Variable      ${WIRESHARK_RUNNING}    true


Stop Wireshark Trace
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Author: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    Sleep     2s
    ${tcpdump_file}    tcpdump.Stop TCPDump On TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Sleep     2s
    OperatingSystem.Move File    ${tcpdump_file}    ${wireshark_store}
    Set Suite Variable      ${WIRESHARK_RUNNING}    false


Stop Wireshark Trace For Setup
    [Documentation]    [PRIVATE]    stop wireshark trace for setup
    ...       :Author: Sylvia Schneider
    Stop Wireshark Trace            wireshark_store=${resultDir}/wireshark_startTL.pcap
