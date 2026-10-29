*** Settings ***
Documentation   This is a keyword file for CB008146-E, part verification
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***
${xnap_version}     xnap

${filterInitialContextSetupResponse_attachCompl}             (ngap.NGAP_PDU==1)&&(ngap.procedureCode==14)
${filterHandover}                                            (${xnap_version}.XnAP_PDU==1)&&(${xnap_version}.procedureCode==0)

*** Keywords ***


verify wireshark successful InitialContextSetupResponse
    [Documentation]    [PRIVATE]    verify wireshark contains successful InitialContextSetupResponse
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${number_of_expected_messages}
    Log To Console    verify wireshark - ${number_of_expected_messages} successful InitialContextSetupResponse messages expected
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/X2_InitialContextSetupResponse.xml
    ...   packet_filter=${filterInitialContextSetupResponse_attachCompl}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/X2_InitialContextSetupResponse.xml
    ${number of messages}   Get Element Count    ${pdml_xml}    xpath=.//field[@name="frame.number"]
    Run Keyword And Continue On Failure
    ...     Should Be Equal As Integers   ${number of messages}    ${number_of_expected_messages}
    ...     Wrong number of successful InitialContextSetupResponse messages
    [Teardown]   teardown tshark


verify wireshark successful handover
    [Documentation]    [PRIVATE]    verify wireshark contains successful handover
    ...       :Autor: Sylvia Schneider
    Log To Console    verify wireshark - 2 successful handover messages expected
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/XNAP_SuccessfulHO.xml
    ...   packet_filter=${filterHandover}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/XNAP_SuccessfulHO.xml
    ${number_of_HO_messages}   Get Element Count    ${pdml_xml}    xpath=.//field[@name="frame.number"]
    Run Keyword And Continue On Failure
    ...     Should Be Equal As Integers   2   ${number_of_HO_messages}
    ...     Wrong number of successful handover messages
    [Teardown]   teardown tshark


verify successful xn setup
    [Documentation]    [PRIVATE]    verify that xn setup is successful
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}
    setup tshark    eth1
    Log To Console    \ncheck that successful XNSetupResponse message present
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/XN_setup.xml
    ...   packet_filter=${xnap_version}
    ...   output_type=pdml
    ...   pcap_file_path=${wireshark_store}
    teardown tshark
    ${pdml_xml}    parse xml    ${resultDir}/XN_setup.xml

    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@name="${xnap_version}.successfulOutcome_element"]
    Should Not Be Equal As Integers    ${successful_msg}    ${0}
    ...     NO successful XNSetupResponse message
