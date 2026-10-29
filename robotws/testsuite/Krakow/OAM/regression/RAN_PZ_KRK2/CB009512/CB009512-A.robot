*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB009512
...   author: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com
...   maintainer: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com

Resource   ./resources/keywords.robot

Suite Setup       CB009512 Suite Setup
Suite Teardown    Common suite teardown
Test Setup        CB009512 Test Setup
Test Teardown     Common postconditions

*** Test Cases ***
[1][1.0] CB009512-A_005_TLS1.3_fallback_when_TLSv1.2_and_TLSv1.1_is_enabled
    Check OpenSSL version
    commissioning.perform_bts_delta_commissioning    delta=${tls_1_3}
    ${path_to_wireshark_file}=  Start Tcpdump On gNB  options=-i ${network_interface}
    asir.get_all_software_packages
    Sleep    60    Waiting for package
    Stop Tcpdump On gNB
    Convert pcap to XML    filename=${path_to_wireshark_file}
    ...                    filters=tls && tls.handshake.type == 2
    ...                    xml_name=${CURDIR}/fallback.xml
    ${change_cipher}=  protocol_finding    ${CURDIR}/fallback.xml
    Should Contain    ${change_cipher}[1][showname]    TLSv1.3
    ${pcap_filters}=    Catenate              tls.handshake.extensions.supported_version == 0x0304 &&
    ...                                       tls.handshake.type == 2
    ${frame_number}=    Run      tshark -r ${path_to_wireshark_file} -Y "${pcap_filters}" | awk 'NR==1{print $1}'
    Should not be empty    ${frame_number}
    tls_tests.load_xml_file    xml_filepath=${CURDIR}/fallback.xml
    tls_tests.test_if_application_data_is_present    frame_number=${frame_number}
    commissioning.perform_bts_delta_commissioning    delta=${tls_1_2}
    ${path_to_wireshark_file}=  Start Tcpdump On gNB  options=-i ${network_interface}
    asir.get_all_software_packages
    Sleep    60    Waiting for package
    Stop Tcpdump On gNB
    Convert pcap to XML    filename=${path_to_wireshark_file}
    ...                    filters=tls && tls.handshake.type == 2
    ...                    xml_name=${CURDIR}/fallback1_2.xml
    tls_tests.load_xml_file                   xml_filepath=${CURDIR}/fallback1_2.xml
    tls_tests.test_tls12_handshake_process
    [Teardown]    Run keywords
    ...           commissioning.perform_bts_delta_commissioning    delta=${tls_1_3}
    ...           AND
    ...           Common Postconditions

[1][1.0] CB009512-A_007_Secure_file_transfer_between_ASiR_and_NMS
    Check OpenSSL version
    ${path_to_wireshark_file}    Activate EMSSIM and Collect Tcpdump
    ${pcap_filters}=    Catenate              tls and ip.src == ${mplane_ip} and
    ...                                       tls.change_cipher_spec
    ${pcap_filters1}    Catenate              tls and tls.handshake.type == 1 and ip.src == ${host_ip}
    Convert pcap to XML                       filename=${path_to_wireshark_file}
    ...                                       filters=${pcap_filters}
    ...                                       xml_name=${CURDIR}/cipher.xml
    Convert pcap to XML                       filename=${path_to_wireshark_file}
    ...                                       filters=${pcap_filters1}
    ...                                       xml_name=${CURDIR}/cipher1.xml
    ${change_cipher}=  analyze_change_cipher  ${CURDIR}/cipher.xml
    ${application_data}=    analyze_app_data    ${CURDIR}/cipher.xml
    ${client_hello}=      client_hello    ${CURDIR}/cipher1.xml
    Should Contain   ${change_cipher}[0][showname]      Change Cipher Spec Message
    Should Contain    ${application_data}[0][showname]     Encrypted Application Data
    Should Contain   ${client_hello}[1][showname]    Client Hello
    ${output}=    Run    tshark -r ${path_to_wireshark_file} -Y "udp && ip.addr == ${host_ip}"
    Should Be Empty    ${output}
    Run EMSSIM Command  ne3s_deactivate  alias=asirAC

[1][1.0] CB009512-A_016_Removal_of_TLS1.1_support_from_ASiR-supported_ciphers
    Run Keyword And Expect Error    *missing NIDD definition for parameter*   commissioning.perform_bts_delta_commissioning   delta=${tls_1_1}
    commissioning.perform_bts_delta_commissioning    delta=${tls_1_2}
    ${path_to_wireshark_file}    Activate EMSSIM and Collect Tcpdump
    Convert pcap to XML        ${path_to_wireshark_file}    tls.handshake.type==1 && ip.src==${mplane_ip}    ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=            OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_CBC_SHA256
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_256_CBC_SHA256
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_CBC_SHA256
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_128_CBC_SHA256
    Run EMSSIM Command  ne3s_deactivate  alias=asirAC
    commissioning.perform_bts_delta_commissioning    delta=${tls_1_2_cbc_off}
    ${path_to_wireshark_file}    Activate EMSSIM and Collect Tcpdump
    Convert pcap to XML        ${path_to_wireshark_file}    tls.handshake.type==1 && ip.src==${mplane_ip}    ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=            OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_RSA_WITH_AES_128_GCM_SHA256
    Run EMSSIM Command  ne3s_deactivate  alias=asirAC
    commissioning.perform_bts_delta_commissioning    delta=${tls_1_2_cipher_off}
    ${path_to_wireshark_file}    Activate EMSSIM and Collect Tcpdump
    Convert pcap to XML        ${path_to_wireshark_file}    tls.handshake.type==1 && ip.src==${mplane_ip}    ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=            OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_CBC_SHA256
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_CBC_SHA256
    Run EMSSIM Command  ne3s_deactivate  alias=asirAC
    commissioning.perform_bts_delta_commissioning    delta=${tls_1_2_cbc_off}
    ${path_to_wireshark_file}    Activate EMSSIM and Collect Tcpdump
    Convert pcap to XML        ${path_to_wireshark_file}    tls.handshake.type==1 && ip.src==${mplane_ip}    ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=            OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
    Should Contain             ${inside_pcap}    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    Should Contain             ${inside_pcap}    TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
    Run EMSSIM Command  ne3s_deactivate  alias=asirAC
    commissioning.perform_bts_delta_commissioning    delta=${tls_1_2_cipher_off}
