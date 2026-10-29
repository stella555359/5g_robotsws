*** Settings ***
Documentation
...     description:    Test cases for the CB005999-B feature. Test cases checks the initial enrollment
...                     and update of operator certificates using ECDSA default CMP setup via NetAct.

Resource        ../../../common_resources/certificates/certificates.robot
Resource        ../../../common_resources/netact/netact_operations.robot
Resource        ../../../common_resources/ip_traffic/ip_traffic.robot
Resource        ../resources/variables.robot
Resource        ../resources/keywords.robot

Library         ../resources/utils.py

*** Keywords ***
CB005999_EC_Operator_certificate_initial_enrollment
    ECDSA Default CMP Setup

    Run Keyword And Ignore Error            Initialize Certificates From NetAct
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=ECDSA
    Sleep                                   30
    ...                                     reason=Wait until certificates initialization completed
    ${certs_list}                           Get Operator Certificates List
    ${sw_release}=                          Get Software Release Name
    Verify ECDSA Certificates               certs_list=${certs_list}
    ...                                     sw_release_name=${sw_release}

    [Teardown]                              Certificates Teardown


CB005999_EC_Operator_certificate_update
    ECDSA Default CMP Setup

    Initialize Certificates                 key_pool_type=ECDSA

    ${certs_before}                         Get Operator Certificates List

    Run Keyword And Ignore Error            Update CMP Key With NetAct
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=ECDSA

    Sleep                                   30
    ...                                     reason=Wait until CMP updated

    ${certs_after}                          Get Operator Certificates List

    Verify CMP Key Update                   certs_before=${certs_before}
    ...                                     certs_after=${certs_after}

    [Teardown]                              Certificates Teardown

CB005999_Operator_Trust_Anchor_update_with_CMP_initialization
    ECDSA Default CMP Setup
    Change Parameter on BTS                 dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1
    ...                                     param_name=autoCertDelete
    ...                                     param_value=${TRUE}

    Run Keyword And Ignore Error            Initialize Certificates From NetAct
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=ECDSA

    ${certs_before}                         Get Operator Certificates List

    Change Parameter on BTS                 dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                     param_name=caSubjectName
    ...                                     param_value=CN\\=CB00599_cross

    Run Keyword And Ignore Error            Initialize Certificates From NetAct
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=ECDSA

    Sleep                                   30
    ...                                     reason=Wait until certificates initialization completed

    ${certs_after}                          Get Operator Certificates List

    Verify Trust Anchor Update              certs_before=${certs_before}
    ...                                     certs_after=${certs_after}

    [Teardown]                              Certificates Teardown

CB005999_Max_polling_timeout
    Change Parameter on BTS                 dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                     param_name=cmpPollingTimeout
    ...                                     param_value=${POLLING_TIMEOUT}
    Configure CMP                           ca_subject_name=${ECDSA_POLLING_SUBJECT_NAME}
    ...                                     server_type=ECDSA

    Sleep                                   300
    ...                                     reason=Wait until certificates initialization completed

    Start TCPDump

    Sleep                                   15
    ...                                     reason=Wait until tcpdump starts properly

    Run Keyword And Ignore Error            Initialize Certificates From NetAct
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=ECDSA
    ...                                     timeout=120
    ...                                     retry=1

    Sleep                                   60
    ...                                     reason=Wait until polling is completed

    Stop TCPDump And Download PCAP          tcpdump_filename=${PCAP_NAME}

    Verify Polling Timeout in PCAP

    [Teardown]                              Run Keywords
    ...                                     TCPDump Teardown        AND
    ...                                     Certificates Teardown

CB005999_Elliptic_curve_primary_and_secondary_RA_CA_support
    ECDSA Default CMP Setup
    Configure Secondary CMP                 subject_name=CN=qwerty
    ...                                     server_host=10.44.90.179
    ...                                     server_type=ECDSA

    Start TCPDump

    Run Keyword And Ignore Error            Initialize Certificates From NetAct
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=ECDSA
    ...                                     timeout=120

    Sleep                                   30
    ...                                     reason=Wait until certificates initialization completed

    Stop TCPDump And Download PCAP          tcpdump_filename=${PCAP_NAME}

    Verify primary CA in use

    Configure CMP                           ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                                     server_type=ECDSA
    ...                                     ca_server_host=10.44.90.179
    ...                                     ca_server_port=8089

    Configure Secondary CMP                 subject_name=${CROSS_SUBJECT_NAME}
    ...                                     server_type=ECDSA

    Start TCPDump

    Run Keyword And Ignore Error            Initialize Certificates From NetAct
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=ECDSA
    ...                                     timeout=120

    Sleep                                   30
    ...                                     reason=Wait until certificates initialization completed

    Stop TCPDump And Download PCAP          tcpdump_filename=${PCAP2_NAME}
    Verify secondary CA in use

    [Teardown]                              Run Keywords
    ...                                     TCPDump Teardown                       AND
    ...                                     Clear Secondary CMP Configuration
    ...                                     server_type=ECDSA                      AND
    ...                                     Certificates Teardown

CB005999_Elliptic_curve_CMP_init_update_failure_handling
    Configure CMP                           ca_subject_name=${DUMMY_SUBJECT_NAME}

    Run Keyword And Expect Error            *OperationFailed*
    ...                                     Initialize Certificates From NetAct
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=RSA

    Configure CMP                           ca_subject_name=${DUMMY_SUBJECT_NAME}
    ...                                     server_type=ECDSA

    Run Keyword And Expect Error            *OperationFailed*
    ...                                     Initialize Certificates From NetAct
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=ECDSA

CB005999_Elliptic_curve_key_length_configuration
    Configure CMP                           ca_subject_name=${CROSS_SUBJECT_NAME}
    ...                                     server_type=ECDSA
    Set CMP Server Settings                 key_pool_type=ECDSA

    Change Parameter on BTS                 dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                     param_name=keyLength
    ...                                     param_value=256

    Run Keyword And Ignore Error            Initialize Certificates From NetAct
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=ECDSA

    Verify Key Length                       expected_length=256

    Change Parameter on BTS                 dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                     param_name=keyLength
    ...                                     param_value=384

    Run Keyword And Ignore Error            Initialize Certificates From NetAct
    ...                                     connection=${NETACT_CONNECTION}
    ...                                     server_type=ECDSA

    Sleep                                   60s
    ...                                     reason=Wait until certificate file reloads

    Verify Key Length                       expected_length=384

    [Teardown]                              Certificates Teardown
