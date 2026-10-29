*** Settings ***
Documentation  The resources for CB012442 feature that introduces usage of vendor certificate for Cloud BTS

*** Keywords ***
Get Info About Used Certificates While Connecting With Server
    [Documentation]  Description:           Return list of used certificaes used during tls connection with server                    ${\n}
    ...              Return:                List of dictionaries with certificates and their parameters                               ${\n}
    ...              Output:                {cert1:{subject:{, issuer, pem}, cert2:{}, cert3:{}, ciphering: SHAxx}                    ${\n}
    ...              Author:                karol.sadowski@nokia.com                                                                  ${\n}
    ...              Maintainer:            CBRS Team                                                                                 ${\n}
    [Arguments]      ${server}=192.168.255.129    # destination ip to server
    ...              ${port}=443                # connection port to server

    ${output}=    Run    timeout 10 openssl s_client -connect ${server}:${port} -showcerts
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