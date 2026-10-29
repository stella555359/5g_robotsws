** Settings ***
Documentation   This is a keyword file for 5GC000480-D-J, part wireshark verification
...             Team: 'MN 5G&SC SW Eng ULM L2PS 60 SG'
...             Email: 'I_ECE_RD_ULM_SQD_60_GMS@internal.nsn.com'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${filter_sgNBChange}                          x2ap.procedureCode == 34
${filter_UEContextRelease}                    x2ap.procedureCode == 5
${filter_SgNBAdditionRequest}                 x2ap.procedureCode == 27
${filter_SgNBReconfigurationComplete}         x2ap.procedureCode == 28

${xpath_successful_outcome}           .//field[@name="x2ap.successfulOutcome_element"]
${xpath_radioNetwork}                 .//field[@name="x2ap.radioNetwork"]



*** Keywords ***
Verify wireshark RACaddHO
    [Documentation]    [PRIVATE]    verify wireshark trace for TC RACaddHO
    ...       :Autor: Sylvia Schneider
    Set test variable    ${part}    part1
    Log To Console    \nVerify wireshark file ${resultDir}/${part}/wireshark.pcap
    check SgNBAdditionRequest message present
    check SgNBAdditionRequestAcknowledge message present
    Set test variable    ${part}    part2
    Log To Console    \nVerify wireshark file ${resultDir}/${part}/wireshark.pcap
    check SgNBAdditionRequest message present              part=${part}
    check SgNBAdditionRequestReject message present        part=${part}
    Set test variable    ${part}    part3
    Log To Console    \nVerify wireshark file ${resultDir}/${part}/wireshark.pcap
    check SgNBChangeRequired message              source_ip=${wts_GNB3_X2_ADDR}        part=${part}
    check successful SgNBChangeConfirm message    destination_ip=${wts_GNB3_X2_ADDR}   part=${part}
    check one UEContextRelease message present    destination_ip=${wts_GNB3_X2_ADDR}   part=${part}


Verify wireshark RacFailure
    [Documentation]    [PRIVATE]    verify wireshark trace for TC RacFailure
    ...       :Autor: Sylvia Schneider
    Set test variable    ${part}    part1
    Log To Console    \nVerify wireshark file ${resultDir}/${part}/wireshark.pcap
    check SgNBChangeRequired message              source_ip=${wts_GNB3_X2_ADDR}
    check successful SgNBChangeConfirm message    destination_ip=${wts_GNB3_X2_ADDR}
    check one UEContextRelease message present    destination_ip=${wts_GNB3_X2_ADDR}
    Set test variable    ${part}    part2
    Log To Console    \nVerify wireshark file ${resultDir}/${part}/wireshark.pcap
    check SgNBChangeRequired message              source_ip=${wts_GNB3_X2_ADDR}        part=${part}
    check SgNBChangeRefuse message                destination_ip=${wts_GNB3_X2_ADDR}   part=${part}


Verify wireshark successful PSCell
    [Documentation]    [PRIVATE]    verify wireshark trace for TC successful PSCell
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify wireshark file ${resultDir}/part1/wireshark.pcap
    check SgNBChangeRequired message              source_ip=${wts_GNB_X2_ADDR}
    check successful SgNBChangeConfirm message    destination_ip=${wts_GNB_X2_ADDR}
    check one UEContextRelease message present    destination_ip=${wts_GNB_X2_ADDR}
    check SgNBChangeRequired message              source_ip=${wts_GNB3_X2_ADDR}
    check successful SgNBChangeConfirm message    destination_ip=${wts_GNB3_X2_ADDR}
    check one UEContextRelease message present    destination_ip=${wts_GNB3_X2_ADDR}


Verify wireshark successful release
    [Documentation]    [PRIVATE]    verify wireshark trace for TC successful release
    ...       :Autor: Sylvia Schneider
    Set test variable    ${part}    part1
    Log To Console    \nVerify wireshark file ${resultDir}/${part}/wireshark.pcap
    check SgNBChangeRequired message              source_ip=${wts_GNB_X2_ADDR}        part=${part}
    check successful SgNBChangeConfirm message    destination_ip=${wts_GNB_X2_ADDR}   part=${part}
    check one UEContextRelease message present    destination_ip=${wts_GNB_X2_ADDR}
    Set test variable    ${part}    part2
    Log To Console    \nVerify wireshark file ${resultDir}/${part}/wireshark.pcap
    check SgNBAdditionRequest message present              part=${part}
    check SgNBAdditionRequestAcknowledge message present   part=${part}


Verify wireshark multiple handovers
    [Documentation]    [PRIVATE]    verify wireshark trace for TC multiple handovers
    ...       :Autor: Sylvia Schneider
    Set test variable    ${part}    part1
    Log To Console    \nVerify wireshark file ${resultDir}/${part}/wireshark.pcap
    check number of SgNBChangeRequired messages             source_ip=${wts_GNB_X2_ADDR}         number_of_expected_messages=${5}
    check number of successful SgNBChangeConfirm messages   destination_ip=${wts_GNB_X2_ADDR}    number_of_expected_messages=${5}
    check number of SgNBChangeRequired messages             source_ip=${wts_GNB3_X2_ADDR}        number_of_expected_messages=${5}
    check number of successful SgNBChangeConfirm messages   destination_ip=${wts_GNB3_X2_ADDR}   number_of_expected_messages=${5}

Verify wireshark RacBearerFailure
    [Documentation]    [PRIVATE]    verify wireshark trace for TC RacBearerFailure
    ...       :Autor: Sylvia Schneider
    Set test variable    ${part}    part1
    Log To Console    \nVerify wireshark file ${resultDir}/${part}/wireshark.pcap
    check SgNBChangeRequired message              source_ip=${wts_GNB3_X2_ADDR}
    check successful SgNBChangeConfirm message    destination_ip=${wts_GNB3_X2_ADDR}
    check one UEContextRelease message present    destination_ip=${wts_GNB3_X2_ADDR}
    Set test variable    ${part}    part2
    Log To Console    \nVerify wireshark file ${resultDir}/${part}/wireshark.pcap
    check SgNBChangeRequired message              source_ip=${wts_GNB3_X2_ADDR}        part=${part}
    check SgNBChangeRefuse message                destination_ip=${wts_GNB3_X2_ADDR}   part=${part}


check SgNBAdditionRequest message present
    [Documentation]    [PRIVATE]    verify wireshark trace that SgNBAdditionRequest message is present
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${part}=part1
    Log To Console    Verify SgNBAdditionRequest message
    Log To Console    with filter ${filter_SgNBAdditionRequest}
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/${part}/sgNBAddReq.pdml
    ...   packet_filter=${filter_SgNBAdditionRequest}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/${part}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/${part}/sgNBAddReq.pdml
    Log To Console    1 SgNBAdditionRequest message present
    ${number_of_SgNBAdditionRequest_messages}  Get Element count  ${pdml_xml}
    ...  .//field[@showname="SgNBAdditionRequest"]
    Run Keyword And Continue On Failure   Should Be Equal    ${number_of_SgNBAdditionRequest_messages}    ${1}
    ...     Wrong number of SgNBAdditionRequest messages
    [Teardown]    teardown tshark

check SgNBAdditionRequestAcknowledge message present
    [Documentation]    [PRIVATE]    verify wireshark trace that SgNBAdditionRequestAcknowledge message is present
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${part}=part1
    Log To Console    Verify SgNBAdditionRequestAcknowledge message
    Log To Console    with filter ${filter_SgNBAdditionRequest}
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/${part}/sgNBAddReq.pdml
    ...   packet_filter=${filter_SgNBAdditionRequest}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/${part}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/${part}/sgNBAddReq.pdml
    Log To Console    1 SgNBAdditionRequestAcknowledge message present
    ${number_of_SgNBAdditionRequestAck_messages}  Get Element count  ${pdml_xml}
    ...  .//field[@showname="SgNBAdditionRequestAcknowledge"]
    Run Keyword And Continue On Failure   Should Be Equal    ${number_of_SgNBAdditionRequestAck_messages}    ${1}
    ...     Wrong number of SgNBAdditionRequestAcknowledge messages
    [Teardown]    teardown tshark

check SgNBAdditionRequestReject message present
    [Documentation]    [PRIVATE]    verify wireshark trace that SgNBAdditionRequestReject message is present
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${part}=part1
    Log To Console    Verify SgNBAdditionRequestReject message
    Log To Console    with filter ${filter_SgNBAdditionRequest}
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/${part}/sgNBAddReq.pdml
    ...   packet_filter=${filter_SgNBAdditionRequest}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/${part}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/${part}/sgNBAddReq.pdml
    Log To Console    SgNBAdditionRequestReject message present with cause no-radio-resources-available-in-target-cell
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    *no-radio-resources-available-in-target-cell*
    ...    xpath=${xpath_radioNetwork}
    [Teardown]    teardown tshark

check SgNBChangeRefuse message
    [Documentation]   [PRIVATE]   verify wireshark trace that SgNBChangeRefuse message, cause no-radio-resources-available-in-target-cell is present
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${destination_ip}  ${part}=part1
    Log To Console    Verify SgNBChangeRefuse message
    Log To Console    with filter ${filter_sgNBChange}&&ip.dst==${destination_ip}
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/${part}/sgNBChange.pdml
    ...   packet_filter=${filter_sgNBChange}&&ip.dst==${destination_ip}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/${part}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/${part}/sgNBChange.pdml
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    *no-radio-resources-available-in-target-cell*
    ...    xpath=${xpath_radioNetwork}
    [Teardown]    teardown tshark


check one UEContextRelease message present
    [Documentation]    [PRIVATE]    verify wireshark trace that 1 UEContextRelease message is present
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${destination_ip}  ${part}=part1
    Log To Console    Verify UEContextRelease message
    Log To Console    with filter ${filter_UEContextRelease}&&ip.dst==${destination_ip}
    Log To Console    contains item ${xpath_successful_outcome} with showname="successfulOutcome"
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/${part}/sgNBChange.pdml
    ...   packet_filter=${filter_UEContextRelease}&&ip.dst==${destination_ip}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/${part}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/${part}/sgNBChange.pdml
    ${number_of_UEContextRelease_messages}  Get Element count  ${pdml_xml}
    ...  .//field[@showname="UEContextRelease"]
    Run Keyword And Continue On Failure   Should Be Equal    ${number_of_UEContextRelease_messages}    ${1}
    ...     Wrong number of UEContextRelease messages
    [Teardown]    teardown tshark

check number of SgNBChangeRequired messages
    [Documentation]    [PRIVATE]    verify wireshark trace that a specified number of SgNBChangeRequired messages is present
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${source_ip}  ${number_of_expected_messages}=1      ${part}=part1
    Log To Console    Verify that ${number_of_expected_messages} SgNBChangeConfirm messages
    Log To Console    with filter ${filter_sgNBChange}&&ip.src==${source_ip}
    Log To Console    containing action-desirable-for-radio-reasons are present
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/${part}/sgNBChange.pdml
    ...   packet_filter=${filter_sgNBChange}&&ip.src==${source_ip}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/${part}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/${part}/sgNBChange.pdml
    ${number_of_SgNBChangeRequired}  Get Element count  ${pdml_xml}
    ...    .//field[@showname="radioNetwork: action-desirable-for-radio-reasons (31)"]
    Run Keyword And Continue On Failure
    ...     Should Be Equal    ${number_of_SgNBChangeRequired}    ${number_of_expected_messages}
    ...     Wrong number of SgNBChangeRequired messages with action-desirable-for-radio-reasons
    [Teardown]    teardown tshark

check number of successful SgNBChangeConfirm messages
    [Documentation]    [PRIVATE]    verify wireshark trace that a specified number of successful SgNBChangeConfirm messages is present
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${destination_ip}  ${number_of_expected_messages}=1      ${part}=part1
    Log To Console    Verify that ${number_of_expected_messages} SgNBChangeRequired messages
    Log To Console    with filter ${filter_sgNBChange}&&ip.dst==${destination_ip}
    Log To Console    contains item ${xpath_successful_outcome} with showname="successfulOutcome"
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/${part}/sgNBChange.pdml
    ...   packet_filter=${filter_sgNBChange}&&ip.dst==${destination_ip}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/${part}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/${part}/sgNBChange.pdml
    ${number_of_SgNBChangeConfirm}  Get Element count  ${pdml_xml}
    ...    .//field[@showname="successfulOutcome"]
    Run Keyword And Continue On Failure
    ...     Should Be Equal    ${number_of_SgNBChangeConfirm}    ${number_of_expected_messages}
    ...     Wrong number of SgNBChangeConfirm messages with showname="successfulOutcome"
    [Teardown]    teardown tshark


check SgNBChangeRequired message
    [Documentation]    [PRIVATE]   verify wireshark trace that SgNBChangeRequired message, cause action-desirable-for-radio-reasons is present
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${source_ip}  ${part}=part1
    Log To Console    Verify SgNBChangeConfirm message
    Log To Console    with filter ${filter_sgNBChange}&&ip.src==${source_ip}
    Log To Console    contains item ${xpath_radioNetwork} with showname action-desirable-for-radio-reasons
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/${part}/sgNBChange.pdml
    ...   packet_filter=${filter_sgNBChange}&&ip.src==${source_ip}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/${part}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/${part}/sgNBChange.pdml
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    *action-desirable-for-radio-reasons*
    ...    xpath=${xpath_radioNetwork}
    [Teardown]    teardown tshark


check successful SgNBChangeConfirm message
    [Documentation]    [PRIVATE]   verify wireshark trace that successful SgNBChangeConfirm message is present
    ...       :Autor: Sylvia Schneider
     [Arguments]    ${destination_ip}  ${part}=part1
    Log To Console    Verify SgNBChangeRequired message
    Log To Console    with filter ${filter_sgNBChange}&&ip.dst==${destination_ip}
    Log To Console    contains item ${xpath_successful_outcome} with showname="successfulOutcome"
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/${part}/sgNBChange.pdml
    ...   packet_filter=${filter_sgNBChange}&&ip.dst==${destination_ip}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/${part}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/${part}/sgNBChange.pdml
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    successfulOutcome
    ...    xpath=${xpath_successful_outcome}
    [Teardown]    teardown tshark

