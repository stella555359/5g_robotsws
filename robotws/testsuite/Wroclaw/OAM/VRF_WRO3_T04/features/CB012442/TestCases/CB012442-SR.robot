*** Settings ***
Documentation  The KW for CB012442 feature that introduces usage of vendor certificate for Cloud BTS
Resource     ../../../common_resources/swconfig/swconfig.robot
Resource     ../../../common_resources/ip_traffic/ip_traffic.robot
Resource     ../../../common_resources/certificates/certificates.robot
Resource     ../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource     ../../../common_resources/connections/connections.robot
Resource     ../../../common_resources/admin/admin.robot
Resource     ../../../common_resources/commissioning/commissioning.robot
Resource     ../Resources/resources.robot

Library      taf.sbts.oam.coam.admin  WITH NAME    coam_admin
Library      XML

*** Variables ***
${DISABLE_HW_CERT}=      0x12442=1
${SHORT_VALIDITY_CERT}=  C=PL, O=Common, CN=validity
${IPSEC_CERT}=           C=PL, O=Common, CN=IPSEC

*** Keywords ***
CB012442-B_FeVe_04_usage_of_Nokia_BTS_vendor_SW_certificate_for_WebEm_on_SBTS
    Log    Step 1: Connecting to ADMIN and clearing certificates before test starts    console=true
    ${connection}=                   Connect to ADMIN
    Configure CMP           ca_subject_name=CN=wrong     server_type=RSA
    Configure CMP           ca_subject_name=CN=wrong     server_type=ECDSA
    Run Keyword and Ignore Error    Clear Certificates
    Log    Step 2: Adding 12442=1 flag to activate the CB012442 feature    console=true
    Add one flag to swconfig        flag=${DISABLE_HW_CERT}    reboot_after_uploading=True
    Log    Step 3: Check if default vendor certificate is used during webem connection    console=true
    ${chain_1}=                 Get Info About Used Certificates While Connecting With Server    server=${LMP_IP}
    Log    Step 4: Check if the proper HW certificate was occured on BTS    console=true
    #TODO: Check if CN=W6242200001.nokiasolutionsandnetworks.com
    Should Not Be Equal     ${chain_1['certificate_1']['subject']['O']}    ${chain_1['certificate_1']['issuer']['O']}
    ...                     msg=Cert seems self-signed!
    Should Not Be Equal     ${chain_1['certificate_1']['subject']['CN']}    ${chain_1['certificate_1']['issuer']['CN']}
    ...                     msg=Cert seems self-signed!
    Should Be Equal         ${chain_1['certificate_1']['validity']}    18 years    msg=Cert validity is not 18 years
    Should Be Equal         ${chain_1['certificate_1']['key_length']}    2048    msg=Key length is not 2048
    Should Be Equal         ${chain_1['certificate_1']['rsa_encryption']}    RSA-SHA256    msg=Encryption is not SHA256

    Log    Step 5: Install RSA operator certificate 'about to expire'    console=true
    Set CMP Server Settings
    Configure CMP           ca_subject_name=${SHORT_VALIDITY_CERT}    server_type=RSA
    Log    Step 6: Initializing the RSA certificates    console=true
    Initialize Certificates    key_pool_type=RSA    connection=${connection}
    Log    Step 7: Check if RSA operator certificate is used during webem connection    console=true
    ${chain_2}=                Get Info About Used Certificates While Connecting With Server
    Should Be Equal            ${chain_2['certificate_2']['issuer']['O']}    Common
    ...                        msg=Seems like operator cert is not used in webem connection!
    Should Be Equal            ${chain_2['certificate_2']['issuer']['CN']}    validity
    ...                        msg=Seems like operator cert is not used in webem connection!
    Log    Step 8: Reconfigure CMP object with wrong path & CN to disable certificate auto renewal    console=true
    Configure CMP              ca_subject_name=CN=wrong_cert    server_path=wrong_path
    Sleep                      10min    reason=Operator certificate expiration and rollback to default vendor certificate

    Log    Step 9: Check if default vendor certificate is used again during webem connection    console=true
    ${chain_3}=                Get Info About Used Certificates While Connecting With Server
    Should Be Equal            ${chain_3}    ${chain_1}    msg=Default vendor certificate is not used!

    Log    Step 10: Configure CMP object for ECDSA certificate    console=true
    Configure CMP              ca_subject_name=${SHORT_VALIDITY_CERT}   server_type=ECDSA
    Log    Step 11: Wait for certificate initialization    console=true
    Initialize Certificates    key_pool_type=ECDSA    connection=${connection}
    Log    Step 12: Reconfigure CMP object with wrong path & CN to disable certificate auto renewal    console=true
    Configure CMP             ca_subject_name=CN=wrong_cert    server_path=wrong_path    server_type=ECDSA
    Sleep                     10min    reason=Operator certificate expiration and rollback to default vendor certificate

    Log    Step 13: Check if default vendor certificate is used again during webem connection    console=true
    ${chain_4}=               Get Info About Used Certificates While Connecting With Server
    Should Be Equal           ${chain_4}    ${chain_1}    msg=Default vendor certificate is not used!
    [Teardown]                Run Keyword and Ignore Error    Clear Certificates

CB012442-B_FeVe_07_usage_of_Nokia_BTS_vendor_SW_certificate_for_CMP_on_SBTS
    Log    Step 1: Connect to ADMIN and clear secondary CMP configuration    console=true
    ${connection}=                       Connect to ADMIN
    Clear Secondary CMP Configuration    server_type=RSA    connection=${connection}
    Clear Secondary CMP Configuration    server_type=ECDSA    connection=${connection}
    Log    Step 2: Configuring CMP server on BTS with RSA and ECDSA certificates    console=true
    Configure CMP                        ca_subject_name=CN=my_cert    server_type=RSA
    Configure CMP                        ca_subject_name=CN=my_cert    server_type=ECDSA
    Log    Step 3: Clearing certificates if some old was occured    console=true
    Clear Certificates                   connection=${connection}
    Log    Step 4: Set the wrong reference_number to fail initialization    console=true
    Set CMP Server Settings              reference_number=wrong_reference_number     preshared_key=1234
    Log    Step 5: Adding 12442=1 flag to activate the feature    console=true
    Add one flag to swconfig             flag=${DISABLE_HW_CERT}    reboot_after_uploading=True

    Log    Step 6: Check if default vendor certificate is used during webem connection    console=true
    ${chain_1}=             Get Info About Used Certificates While Connecting With Server    server=${LMP_IP}
    Log    Step 7: Check if the proper HW certificate was occured on BTS    console=true
    #TODO: Check if CN=W6242200001.nokiasolutionsandnetworks.com
    Should Not Be Equal     ${chain_1['certificate_1']['subject']['O']}    ${chain_1['certificate_1']['issuer']['O']}
    ...                     msg=Cert seems self-signed!
    Should Not Be Equal     ${chain_1['certificate_1']['subject']['CN']}    ${chain_1['certificate_1']['issuer']['CN']}
    ...                     msg=Cert seems self-signed!
    Should Be Equal         ${chain_1['certificate_1']['validity']}    18 years    msg=Cert validity is not 18 years
    Should Be Equal         ${chain_1['certificate_1']['key_length']}    2048    msg=Key length is not 2048
    Should Be Equal         ${chain_1['certificate_1']['rsa_encryption']}    RSA-SHA256    msg=Encryption is not SHA256

    Log    Step 8: Starting TCPdump    console=true
    Start Tcpdump              bts_host=${LMP_IP}
    Log    Step 9: Configuring CMP to get the proper RSA and ECDSA certificates
    Configure CMP              ca_subject_name=${IPSEC_CERT}    server_type=RSA
    Configure CMP              ca_subject_name=${IPSEC_CERT}    server_type=ECDSA
    Initialize Certificates    key_pool_type=ECDSA    connection=${connection}
    Sleep                      3s    reason=allow CMP to generate certificates

    Log    Step 10: Stopping TCPdump and get PCAP file    console=true
    ${logs}=               Stop Tcpdump And Download Pcap     tcpdump_filename=certs.pcap    bts_host=${LMP_IP}
    Convert pcap to XML    filename=${TEST_OUTPUT_DIR}/certs.pcap
    ...                    filters=ip.dst_host == 10.42.54.13 && cmp.body == ir && not pkcs1.ECParameters
    ...                    xml_name=${CURDIR}/pcap_CMP_RSA.xml
    Convert pcap to XML    filename=${TEST_OUTPUT_DIR}/certs.pcap
    ...                    filters=ip.dst_host == 10.42.54.13 && cmp.body == ir && pkcs1.ECParameters
    ...                    xml_name=${CURDIR}/pcap_CMP_ECDSA.xml
    Log    Step 11: Parsing XML    console=true
    ${logs_xml_RSA}=       Parse XML    ${CURDIR}/pcap_CMP_RSA.xml
    ${logs_xml_ECDSA}      Parse XML    ${CURDIR}/pcap_CMP_ECDSA.xml
    Log    Step 12: Preparing the filters for getting the elements about certificate    console=true
    ${CN_path}=    Catenate    SEPARATOR=    packet/proto[@name='cmp']/field[@name='cmp.header_element']/field[@name='cmp.sender']
    ...    /field[@name='x509ce.directoryName']/field[@name='x509if.rdnSequence']/field[@name='x509if.RDNSequence_item']
    ...    /field[@name='x509if.RelativeDistinguishedName_item_element']/field[@name='x509sat.DirectoryString']/field[@name='x509sat.uTF8String']
    @{cert_1}=             Get Elements             ${logs_xml_RSA}    ${CN_path}
    ${cert_1_CN}=          Get Element Attribute    ${cert_1}[0]    show
    ${cert_1_O}=           Get Element Attribute    ${cert_1}[1]    show
    @{cert_2}=             Get Elements             ${logs_xml_ECDSA}    ${CN_path}
    ${cert_2_CN}=          Get Element Attribute    ${cert_2}[0]    show
    ${cert_2_O}=           Get Element Attribute    ${cert_2}[1]    show

    Log    Step 13: Checking if in the PCAP are used the certificate that should be initialized and used    console=true
    Should Be Equal        ${cert_1_CN}    ${cert_2_CN}
    Should Be Equal        ${cert_1_O}    ${cert_2_O}
    Should Be Equal        ${chain_1['certificate_1']['subject']['CN']}    ${cert_1_CN}
    Should Be Equal        ${chain_1['certificate_1']['subject']['O']}    ${cert_1_O}
    [Teardown]    Run Keyword and Ignore Error    Clear Certificates
