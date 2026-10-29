*** Settings ***
Documentation
...     description:    Keywords for test cases for the CB008154 feature.

Resource    ../../../../common_resources/admin/admin.robot
Resource    8154_split1_resources.robot
Resource    variables.robot
Resource    ../../../../common_resources/netact/netact_operations.robot
Resource    ../../../../common_resources/binary_files/binary_files.robot

*** Keywords ***
CB008154_old_rootCA_retention_WebEM
    [Documentation]    The aim of the test is to configure autoCertDelete parameter via WebEM
    ...                in order to retain the old root CA.
    Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    false
    Configure CMP And Initialize Certificates   ca_subject_name=${cmp_default}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154_default
    Should Be True    ${status}
    Configure CMP And Initialize Certificates   ca_subject_name=${cmp_1}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154_default
    Should Be True    ${status}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154
    Should Be True    ${status}
    Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    true
    Configure CMP And Initialize Certificates   ca_subject_name=${cmp_2}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154_2
    Should Be True    ${status}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154
    Should Not Be True    ${status}
    Clear Certificates
    Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    false
    Generate Binary File From HEX String    hex_string_file=${FIRST_CERT_FILE_P12_HEX}
    ...                                     binary_file_name=${FIRST_CERT_P12}
    Install Certificate On BTS              cert_file=${FIRST_CERT_P12}
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${CERT_P12_PASSWORD}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=8154_First
    Should Be True    ${status}
    Generate Binary File From HEX String    hex_string_file=${SECOND_CERT_FILE_P12_HEX}
    ...                                     binary_file_name=${SECOND_CERT_P12}
    Install Certificate On BTS              cert_file=${SECOND_CERT_P12}
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${CERT_P12_PASSWORD}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=8154_First
    Should Be True    ${status}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=8154_Second
    Should Be True    ${status}
    Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    true
    Generate Binary File From HEX String    hex_string_file=${THIRD_CERT_FILE_P12_HEX}
    ...                                     binary_file_name=${THIRD_CERT_P12}
    Install Certificate On BTS              cert_file=${THIRD_CERT_P12}
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=systest2
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=8154_Third
    Should Be True    ${status}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=8154_First
    Should Be True    ${status}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=8154_Second
    Should Not Be True    ${status}
    [Teardown]  Run Keywords   Clear Certificates    AND
    ...         Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    false

CB008154_old_rootCA_removal_WebEM
    [Documentation]  The aim of the test is to configure autoCertDelete via WebEM to discard the old root CA.
    Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    false
    Configure CMP And Initialize Certificates   ca_subject_name=${cmp_default}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154_default
    Should Be True    ${status}
    Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    true
    Configure CMP And Initialize Certificates   ca_subject_name=${cmp_1}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154
    Should Be True    ${status}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154_default
    Should Not Be True    ${status}
    Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    true
    Clear Certificates
    Generate Binary File From HEX String    hex_string_file=${FIRST_CERT_FILE_P12_HEX}
    ...                                     binary_file_name=${FIRST_CERT_P12}
    Install Certificate On BTS              cert_file=${FIRST_CERT_P12}
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${CERT_P12_PASSWORD}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=8154_First
    Should Be True    ${status}
    Generate Binary File From HEX String    hex_string_file=${SECOND_CERT_FILE_P12_HEX}
    ...                                     binary_file_name=${SECOND_CERT_P12}
    Install Certificate On BTS              cert_file=${SECOND_CERT_P12}
    ...                                     cert_type=BtsTrustChain
    ...                                     cert_format=P12
    ...                                     p12password=${CERT_P12_PASSWORD}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=8154_First
    Should Not Be True    ${status}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=8154_Second
    Should Be True    ${status}
    [Teardown]  Run Keywords   Clear Certificates    AND
    ...         Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    false

CB008154_old_rootCA_retention_Netact
    [Documentation]    The aim of the test is to configure autoCertDelete parameter via Netact
    ...                in order to retain the old root CA.
    Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    false
    Configure CMP    ca_subject_name=${cmp_default}
    ${conn}=    Connect to NetAct
    Initialize Certificates From NetAct    connection=${conn}    server_type=RSA    timeout=400
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154_default
    Should Be True    ${status}
    Configure CMP   ca_subject_name=${cmp_1}
    Initialize Certificates From NetAct    connection=${conn}    server_type=RSA    timeout=400
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154_default
    Should Be True    ${status}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154
    Should Be True    ${status}
    Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    true
    Configure CMP   ca_subject_name=${cmp_2}
    Initialize Certificates From NetAct    connection=${conn}    server_type=RSA    timeout=400
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154_2
    Should Be True    ${status}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154
    Should Not Be True    ${status}
    [Teardown]  Run Keywords    Clear Certificates    AND
    ...         Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    false
    ...         AND     Disconnect from NetAct    ${conn}

CB008154_old_rootCA_removal_Netact
    [Documentation]  The aim of the test is to configure autoCertDelete via Netact to discard the old root CA.
    Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    false
    Configure CMP   ca_subject_name=${cmp_default}
    ${conn}=    Connect to NetAct
    Initialize Certificates From NetAct     connection=${conn}    server_type=RSA    timeout=400
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154_default
    Should Be True    ${status}
    Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    true
    Configure CMP   ca_subject_name=${cmp_1}
    Initialize Certificates From NetAct    connection=${conn}    server_type=RSA    timeout=400
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154
    Should Be True    ${status}
    ${status}=    Checking If The Correct Certificates Are Installed    certificate_CN=Nokia_8154_default
    Should Not Be True    ${status}
    [Teardown]  Run Keywords    Clear Certificates    AND
    ...         Change Parameter on BTS    MRBTS-${bts_id}/MNL-1/CERTH-1    autoCertDelete    false
    ...         AND     Disconnect from NetAct    ${conn}
