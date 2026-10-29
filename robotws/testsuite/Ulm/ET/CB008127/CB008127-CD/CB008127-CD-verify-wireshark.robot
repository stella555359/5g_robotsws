*** Settings ***
Documentation   This is a keyword file for CG008127-CD, part wireshark
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***
${filter_sgnb_modify}   (x2ap.procedureCode == 29)&&(ip.src == 10.0.1.2)

*** Keywords ***


verify wireshark t2
    [Documentation]    [PRIVATE]    verify wireshark for MeNB_initiated_SgNB_Modification_using_meas_profile test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for MeNB_initiated_SgNB_Modification_using_meas_profile
    Log to console    \nverify 1 sgNB modificaton acknowledge message present

    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/sgNBmodAck.xml
    ...   packet_filter=${filter_sgnb_modify}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/wireshark_t2.pcap
    teardown tshark

    ${xpath1}   set variable   field[@name="x2ap.successfulOutcome_element"]/field[@name="x2ap.value_element"]
    ${xpath2}   set variable   field[@name="x2ap.SgNBModificationRequestAcknowledge_element"]
    ${pdml_xml}    parse xml    ${resultDir}/sgNBmodAck.xml
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    SgNBModificationRequestAcknowledge
    ...    xpath=.//${xpath1}/${xpath2}

