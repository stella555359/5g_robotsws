*** Settings ***
Documentation   This is a keyword file for CB008127-G, part wireshark
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------
*** Variables ***
${srb3}   (f1ap.procedureCode == 13)

*** Keywords ***


verify wireshark t4
    [Documentation]    [PRIVATE]    verify wireshark for ULRRCTransfer srb3
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \nverify wireshark for ULRRCTransfer srb3

    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/srb3.xml
    ...   packet_filter=${srb3}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/wireshark_t4.pcap
    teardown tshark

    ${pdml_xml}    parse xml    ${resultDir}/srb3.xml
    ${srb}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@showname="SRBID: 3"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${srb}    ${4}
