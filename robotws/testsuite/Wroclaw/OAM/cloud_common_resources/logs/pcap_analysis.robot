*** Settings ***
Documentation    Keywords regarding PCAP files analyzing.
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Library          OperatingSystem

*** Keywords ***
Convert pcap to XML
    [Arguments]  ${filename}  ${filters}  ${xml_name}
    Run    tshark -r ${filename} -Y "${filters}" -T pdml > ${xml_name}

PCAP Should Contain Message
    [Documentation]        Checks if PCAP file contains packets matching given `tshark_filter`.
    [Arguments]            ${tshark_filter}    ${pcap_file}

    ${output}              Run     tshark -r ${pcap_file} -Y '${tshark_filter}' 2>/dev/null | wc -l
    Should not be equal    ${output}    0
    ...                    msg=Packets matching filter "${tshark_filter}" not found in PCAP.
    Log                    Packets matching filter "${tshark_filter}" found in PCAP.
    ...                    console=${TRUE}

PCAP Should Be Empty
    [Documentation]        Checks if PCAP file contains no packets matching given `tshark_filter`.
    [Arguments]            ${tshark_filter}    ${pcap_file}

    ${output}              Run     tshark -r ${pcap_file} -Y "${tshark_filter}" 2>/dev/null | wc -l
    Should be equal        ${output}    0
    ...                    msg=Packets matching filter "${tshark_filter}" found in PCAP.
    Log                    Packets matching filter "${tshark_filter}" not found in PCAP.
    ...                    console=${TRUE}

PCAP Should Contain Address
    [Documentation]        Checks if PCAP file contains packets from given address.
    [Arguments]            ${address}    ${pcap_file}

    ${output}=             Run          tshark -r ${pcap_file} -Y 'ip.addr == ${address}'
    Should Not Be Empty    ${output}
    Should Contain         ${output}    ${address}

Check Used Certificate
    [Documentation]    Description:    Checking the used certificate in connection
    ...                Input:          file_path: path to PCAP file
    ...                                ca_subject_name: CA of the used certificate
    ...                Output:         pass/fail
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${file_path}    ${ca_subject_name}    ${bts_ip}   ${VM_address}
    ${used_rsa}    Run Keyword and Return Status    Should Contain    ${ca_subject_name}    7672
    ${algorithm_id}    Set Variable If    '${used_rsa}'=='True'    1.2.840.113549.1.1.11    1.2.840.10045.4.3.3
    ${supported_groups_filters}=    Catenate      tls and ip.src == ${bts_ip} and ip.dst == ${VM_address} and
    ...                                      tls.handshake.type == 11 and tls.handshake.certificates and
    ...                                      x509af.algorithm.id==${algorithm_id}
    ${support_groups}=    Run    tshark -r ${file_path} -Y "${supported_groups_filters}" -V | grep -A 20 "id-at-commonName="
    ${support_groups}=    Split String    ${support_groups}    --
    Should Contain    ${support_groups}[0]    id-at-commonName=${ca_subject_name}
    Should Contain    ${support_groups}[1]    id-at-commonName=${ca_subject_name}
