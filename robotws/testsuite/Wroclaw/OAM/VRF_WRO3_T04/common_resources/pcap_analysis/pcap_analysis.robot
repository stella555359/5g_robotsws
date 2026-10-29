*** Settings ***
Documentation    Keywords regarding PCAP files analyzing.

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
    ${supported_groups_filters}=    Catenate      tls and ip.src == ${bts_ip} and ip.dst == ${VM_address} and
    ...                                      tls.handshake.type == 11 and tls.handshake.certificates
    ${support_groups}=    Run    tshark -r ${file_path} -Y "${supported_groups_filters}" -V | grep -A 20 "id-at-commonName="
    ${support_groups}=    Split String    ${support_groups}    --
    Should Contain    ${support_groups}[0]    id-at-commonName=${ca_subject_name}
    Should Contain    ${support_groups}[1]    id-at-commonName=${ca_subject_name}

Check Alert Message From PCAP
    [Arguments]    ${PATH_TO_XML}    ${alert}
    ${xml}=    Parse XML    ${PATH_TO_XML}
    ${alerts_messages}=    Get Elements    ${xml}    .//field[@name='tls.alert_message.desc']
    FOR    ${alert_message}    IN    @{alerts_messages}
        ${description}=    Get Element Attribute    ${alert_message}    showname
        Should Contain     ${description}    ${alert}
    END
