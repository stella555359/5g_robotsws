*** Settings ***
Documentation  The KW for CB012442 feature that introduces usage of vendor certificate for Classical BTS
Resource       ../../../../cloud_common_resources/certificates/certificates.robot
Resource       ../../../../cloud_common_resources/connections/connections.robot
Resource       taf/rfrl/cbts/utilities/init_variables.robot
Library        taf.rfrl.cbts.utilities.generic_utils   WITH NAME    generic_utils


*** Variables ***
${DEFAULT_PORT}=         443
${SHORT_VALIDITY_CERT}=  C=PL, O=Common, CN=validity

*** Keywords ***
CB012442-B_FeVe_05_usage_of_Nokia_BTS_vendor_SW_certificate_for_WebEm_on_vCU
    Log    Step 1: Clearing certificates before test starts    console=true
    Configure CMP                   ca_subject_name=wrong    server_type=RSA    hw_type=vCU
    Configure CMP                   ca_subject_name=wrong    server_type=ECDSA    hw_type=vCU
    Run Keyword and Ignore Error    Delete All Certificates    hw_type=vCU
    Run Keyword and Ignore Error    Restore Default Certificates on BTS    hw_type=vCU
    Log    Step 2: Check if default vendor certificate is used during webem connection    console=true
    ${chain_1}=             Get Info About Used Certificates While Connecting With Server    server=${LMP_VCU_IP}
    Log    Step 3: Check if the proper HW certificate was occured on BTS    console=true
    Should Not Be Equal     ${chain_1['certificate_1']['subject']['O']}    ${chain_1['certificate_1']['issuer']['O']}    msg=Cert seems self-signed!
    Should Not Be Equal     ${chain_1['certificate_1']['subject']['CN']}    ${chain_1['certificate_1']['issuer']['CN']}  msg=Cert seems self-signed!
    Should Be Equal         ${chain_1['certificate_1']['validity']}    18 years    msg=Cert validity is not 18 years
    Should Be Equal         ${chain_1['certificate_1']['key_length']}    2048    msg=Key length is not 2048
    Should Be Equal         ${chain_1['certificate_1']['rsa_encryption']}    RSA-SHA256    msg=Encryption is not SHA256

    Log    Step 4: Install RSA operator certificate 'about to expire'    console=true
    Update CMP Server Settings    hw_type=vCU
    Configure CMP                 ca_subject_name=${SHORT_VALIDITY_CERT}    ee_subject_name=CN=MRBTS-${MRBTS_CU}, O=Common
    ...                           hw_type=vCU    server_type=RSA
    Log    Step 5: Initializing the RSA certificates    console=true
    Initialize Certificate        key_pool_type=RSA    hw_type=vCU
    Sleep                         30s    reason=Wait until successful certificate initialization
    Log    Step 6: Check if RSA operator certificate is used during webem connection    console=true
    ${chain_2}=         Get Info About Used Certificates While Connecting With Server   server=${LMP_VCU_IP}
    Should Be Equal     ${chain_2['certificate_1']['issuer']['O']}    Common    msg=Seems like operator cert is not used in webem connection!
    Should Be Equal     ${chain_2['certificate_1']['issuer']['CN']}    validity    msg=Seems like operator cert is not used in webem connection!
    Log    Step 7: Reconfigure CMP object with wrong path & CN to disable certificate auto renewal    console=true
    Configure CMP       ca_subject_name=CN=wrong_cert    server_path=wrong_path    hw_type=vCU
    Sleep               10min
    Configure CMP       ca_subject_name=wrong_cert   ee_subject_name=CN=MRBTS-${MRBTS_CU}, O=Common
    ...                 hw_type=vCU    server_type=RSA

    Log    Step 8: Check if default vendor certificate is used again during webem connection    console=true
    ${chain_3}=         Get Info About Used Certificates While Connecting With Server    server=${LMP_VCU_IP}
    Should Be Equal     ${chain_3}    ${chain_1}    msg=Default vendor certificate is not used!

    Log    Step 9: Configure CMP object for ECDSA certificate    console=true
    Update CMP Server Settings    key_pool_type=ECDSA    hw_type=vCU
    Configure CMP                 ca_subject_name=${SHORT_VALIDITY_CERT}     ee_subject_name=CN=MRBTS-${MRBTS_CU}, O=Common
    ...                           hw_type=vCU    server_type=ECDSA
    Log    Step 10: Wait for certificate initialization    console=true
    Initialize Certificate        key_pool_type=ECDSA    hw_type=vCU
    Log    Step 11: Reconfigure CMP object with wrong path & CN to disable certificate auto renewal    console=true
    Configure CMP                 ca_subject_name=CN=wrong_cert    server_path=wrong_path    server_type=ECDSA
    ...                           ee_subject_name=CN=MRBTS-${MRBTS_CU}, O=Common    hw_type=vCU
    Sleep                         10min
    Log    Step 12: Check if default vendor certificate is used again during webem connection    console=true
    ${chain_4}=                   Get Info About Used Certificates While Connecting With Server    server=${LMP_VCU_IP}
    Should Be Equal               ${chain_4}    ${chain_1}    msg=Default vendor certificate is not used!
    [Teardown]                    Restore Default Certificates on BTS    hw_type=vCU

CB012442-B_FeVe_05_usage_of_Nokia_BTS_vendor_SW_certificate_for_WebEm_on_vDU
    Log    Step 1: Clearing certificates before test starts    console=true
    Configure CMP                   ca_subject_name=wrong    server_type=RSA    hw_type=vDU
    Configure CMP                   ca_subject_name=wrong    server_type=ECDSA    hw_type=vDU
    Delete All Certificates    hw_type=vDU
    Restore Default Certificates on BTS    hw_type=vDU
    Sleep    3min    reason=Wait until certificates are deleted and vendor certs are used
    Log    Step 2: Check if default vendor certificate is used during webem connection    console=true
    ${chain_1}=             Get Info About Used Certificates While Connecting With Server    server=${LMP_VDU_IP}
    Log    Step 3: Check if the proper HW certificate was occured on BTS    console=true
    Should Not Be Equal     ${chain_1['certificate_1']['subject']['O']}    ${chain_1['certificate_1']['issuer']['O']}    msg=Cert seems self-signed!
    Should Not Be Equal     ${chain_1['certificate_1']['subject']['CN']}    ${chain_1['certificate_1']['issuer']['CN']}  msg=Cert seems self-signed!
    Should Be Equal         ${chain_1['certificate_1']['validity']}    18 years    msg=Cert validity is not 18 years
    Should Be Equal         ${chain_1['certificate_1']['key_length']}    2048    msg=Key length is not 2048
    Should Be Equal         ${chain_1['certificate_1']['rsa_encryption']}    RSA-SHA256    msg=Encryption is not SHA256

    Log    Step 4: Install RSA operator certificate 'about to expire'    console=true
    Update CMP Server Settings    hw_type=vDU
    Configure CMP                 ca_subject_name=${SHORT_VALIDITY_CERT}    ee_subject_name=CN=MRBTS-${MRBTS}, O=Common
    ...                           hw_type=vDU    server_type=RSA
    Log    Step 5: Initializing the RSA certificates    console=true
    Initialize Certificate        key_pool_type=RSA    hw_type=vDU
    Sleep                         30s    reason=Wait until successful certificate initialization
    Log    Step 6: Check if RSA operator certificate is used during webem connection    console=true
    ${chain_2}=         Get Info About Used Certificates While Connecting With Server   server=${LMP_VDU_IP}
    Should Be Equal     ${chain_2['certificate_1']['issuer']['O']}    Common    msg=Seems like operator cert is not used in webem connection!
    Should Be Equal     ${chain_2['certificate_1']['issuer']['CN']}    validity    msg=Seems like operator cert is not used in webem connection!
    Log    Step 7: Reconfigure CMP object with wrong path & CN to disable certificate auto renewal    console=true
    Configure CMP       ca_subject_name=CN=wrong_cert    server_path=wrong_path    hw_type=vDU
    Sleep               10min
    Configure CMP       ca_subject_name=wrong_cert   ee_subject_name=CN=MRBTS-${MRBTS}, O=Common
    ...                 hw_type=vDU    server_type=RSA

    Log    Step 8: Check if default vendor certificate is used again during webem connection    console=true
    ${chain_3}=         Get Info About Used Certificates While Connecting With Server    server=${LMP_VDU_IP}
    Should Be Equal     ${chain_3}    ${chain_1}    msg=Default vendor certificate is not used!

    Log    Step 9: Configure CMP object for ECDSA certificate    console=true
    Update CMP Server Settings    key_pool_type=ECDSA    hw_type=vDU
    Configure CMP                 ca_subject_name=${SHORT_VALIDITY_CERT}     ee_subject_name=CN=MRBTS-${MRBTS}, O=Common
    ...                           hw_type=vDU    server_type=ECDSA
    Log    Step 10: Wait for certificate initialization    console=true
    Initialize Certificate        key_pool_type=ECDSA    hw_type=vDU
    Log    Step 11: Reconfigure CMP object with wrong path & CN to disable certificate auto renewal    console=true
    Configure CMP                 ca_subject_name=CN=wrong_cert    server_path=wrong_path    server_type=ECDSA
    ...                           ee_subject_name=CN=MRBTS-${MRBTS}, O=Common    hw_type=vDU
    Sleep                         10min
    Log    Step 12: Check if default vendor certificate is used again during webem connection    console=true
    ${chain_4}=                   Get Info About Used Certificates While Connecting With Server    server=${LMP_VDU_IP}
    Should Be Equal               ${chain_4}    ${chain_1}    msg=Default vendor certificate is not used!
    [Teardown]                    Restore Default Certificates on BTS    hw_type=vDU

Get Info About Used Certificates While Connecting With Server
    [Documentation]  Description:           Return list of used certificaes used during tls connection with server                    ${\n}
    ...              Return:                List of dictionaries with certificates and their parameters                               ${\n}
    ...              Output:                {cert1:{subject:{, issuer, pem}, cert2:{}, cert3:{}, ciphering: SHAxx}                    ${\n}
    ...              Author:                karol.sadowski@nokia.com                                                                  ${\n}
    ...              Maintainer:            CBRS Team                                                                                 ${\n}
    [Arguments]      ${server}=192.168.255.1    # destination ip to server
    ...              ${port}=443                # connection port to server

    ${output}=    Run    timeout 60s openssl s_client -connect ${server}:${port} -showcerts
    Log    ${output}

    ${cert1_subject}=    Get Regexp Matches    ${output}    \\s0\\ss:(.*)    1
    ${cert2_subject}=    Get Regexp Matches    ${output}    \\s1\\ss:(.*)    1
    ${cert3_subject}=    Get Regexp Matches    ${output}    \\s2\\ss:(.*)    1

    ${cert1_issuer}=    Get Regexp Matches    ${output}    \\s0\\ss:.*\\n\\s*i:(.*)    1
    ${cert2_issuer}=    Get Regexp Matches    ${output}    \\s1\\ss:.*\\n\\s*i:(.*)    1
    ${cert3_issuer}=    Get Regexp Matches    ${output}    \\s2\\ss:.*\\n\\s*i:(.*)    1

    ${cert1_pem}=    Get Regexp Matches    ${output}    \\s0\\ss:[\\s\\S]*?(-----BEGIN CERTIFICATE-----[\\s\\S]*?-----END CERTIFICATE-----)    1
    ${cert2_pem}=    Get Regexp Matches    ${output}    \\s1\\ss:[\\s\\S]*?(-----BEGIN CERTIFICATE-----[\\s\\S]*?-----END CERTIFICATE-----)    1
    ${cert3_pem}=    Get Regexp Matches    ${output}    \\s2\\ss:[\\s\\S]*?(-----BEGIN CERTIFICATE-----[\\s\\S]*?-----END CERTIFICATE-----)    1

    ${cert1_validity}=    Get Regexp Matches    ${output}    \\s0\\ss:[\\s\\S]*?NotBefore:.*\\s(.*)\\sGMT;\\sNotAfter:.*\\s(.*)\\sGMT    1    2
    ${cert2_validity}=    Get Regexp Matches    ${output}    \\s1\\ss:[\\s\\S]*?NotBefore:.*\\s(.*)\\sGMT;\\sNotAfter:.*\\s(.*)\\sGMT    1    2
    ${cert3_validity}=    Get Regexp Matches    ${output}    \\s2\\ss:[\\s\\S]*?NotBefore:.*\\s(.*)\\sGMT;\\sNotAfter:.*\\s(.*)\\sGMT    1    2

    ${cert1_cipher}=    Get Regexp Matches    ${output}    \\s0\\ss:[\\s\\S]*?\\s(\\d{4})\\s\\(bit\\).*(RSA-SHA\\d*)    1    2
    ${cert2_cipher}=    Get Regexp Matches    ${output}    \\s1\\ss:[\\s\\S]*?\\s(\\d{4})\\s\\(bit\\).*(RSA-SHA\\d*)    1    2
    ${cert3_cipher}=    Get Regexp Matches    ${output}    \\s2\\ss:[\\s\\S]*?\\s(\\d{4})\\s\\(bit\\).*(RSA-SHA\\d*)    1    2

    &{data}=    Create Dictionary

    ${certificate_count}    Set Variable If    "${cert3_subject}" != "[]"    ${4}    ${3}

    FOR    ${i}   IN RANGE    ${1}    ${certificate_count}
        ${subject_organization}=    Get Regexp Matches     ${cert${i}_subject[0]}     O\\s*=\\s*([^,]+)    1
        ${subject_name}=    Get Regexp Matches     ${cert${i}_subject[0]}     CN\\s*=\\s*([^,]+)    1
        ${issuer_organization}=    Get Regexp Matches     ${cert${i}_issuer[0]}     O\\s*=\\s*([^,]+)    1
        ${issuer_name}=    Get Regexp Matches     ${cert${i}_issuer[0]}     CN\\s*=\\s*([^,]+)    1
        ${cert_validity}=    Evaluate    str(${cert${i}_validity[0]}[1] - ${cert${i}_validity[0]}[0]) + " years"

        &{subject}=    Create Dictionary    O=${subject_organization[0]}    CN=${subject_name[0]}
        &{issuer}=    Create Dictionary    O=${issuer_organization[0]}    CN=${issuer_name[0]}

        &{cert}=    Create Dictionary
        ...    subject=&{subject}
        ...    issuer=&{issuer}
        ...    validity=${cert_validity}
        ...    key_length=${cert${i}_cipher[0]}[0]
        ...    rsa_encryption=${cert${i}_cipher[0]}[1]
        ...    pem=${cert${i}_pem}

        Set To Dictionary    ${data}   certificate_${i}=&{cert}
    END

    Log    ${data}
    [Return]    ${data}
