*** Settings ***
Documentation
...     description:    Keywords for test cases for the CB005999-B feature. The feature CB005999 split B is related to the initial enrollment
...                     and update of operator certificates using ECDSA default CMP setup via NetAct.

Resource        ../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource        ../../../common_resources/certificates/certificates.robot
Resource        ./variables.robot

*** Keywords ***
ECDSA Default CMP Setup
    Configure CMP                           ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                                     server_type=ECDSA
    Set CMP Server Settings                 key_pool_type=ECDSA

Certificates Teardown
    Clear Certificates

Verify Polling Timeout In PCAP
    Log                                     ${\n}PCAP analysis:
    ...                                     console=${TRUE}
    PCAP Should Contain Message             tshark_filter=cmp.body == ir
    ...                                     pcap_file=${TEST_OUTPUT_DIR}/${PCAP_NAME}
    PCAP Should Contain Message             tshark_filter=cmp.body == pollReq
    ...                                     pcap_file=${TEST_OUTPUT_DIR}/${PCAP_NAME}
    PCAP Should Contain Message             tshark_filter=cmp.body == pollRep
    ...                                     pcap_file=${TEST_OUTPUT_DIR}/${PCAP_NAME}
    ${polling_start}                        Get First PollReq Message Timestamp
    ${polling_end}                          Get Last PollRep Message Timestamp
    ${polling_duration}                     Evaluate    ${polling_end} - ${polling_start}
    Log                                     Polling timeout parameter value: ${POLLING_TIMEOUT}, Actual polling duration: ${polling_duration}
    ...                                     console=${TRUE}
    Should be Equal as Integers             ${polling_duration}    ${POLLING_TIMEOUT}
    ...                                     msg=Incorrect polling duration (PCAP).

Get First PollReq Message Timestamp
    ${output}      Run    tshark -r ${TEST_OUTPUT_DIR}/${PCAP_NAME} -Y "cmp.body == pollReq" -Tfields -e _ws.col.Time 2>/dev/null | head -n 1
    [Return]       ${output}

Get Last PollRep Message Timestamp
    ${output}      Run    tshark -r ${TEST_OUTPUT_DIR}/${PCAP_NAME} -Y "cmp.body == pollRep" -Tfields -e _ws.col.Time 2>/dev/null | tail -n 1
    [Return]       ${output}


Verify primary CA in use
    ${certs_list}                           Get Operator Certificates List
    ${sw_release}=                          Get Software Release Name
    Verify ECDSA Certificates               certs_list=${certs_list}
    ...                                     sw_release_name=${sw_release}
    PCAP Should Contain Message             ip.addr == ${CA_SERVER_IP} && cmp  pcap_file=${TEST_OUTPUT_DIR}/${PCAP_NAME}
    PCAP Should Be Empty                    ip.addr == 10.44.90.179   pcap_file=${TEST_OUTPUT_DIR}/${PCAP_NAME}


Verify secondary CA in use
    ${certs_list}                           Get Operator Certificates List
    ${sw_release}=                          Get Software Release Name
    Verify ECDSA Certificates               certs_list=${certs_list}
    ...                                     sw_release_name=${sw_release}
    ...                                     subject_name=CN = CB00599_cross

    PCAP Should Contain Message             ip.addr == 10.44.90.179   pcap_file=${TEST_OUTPUT_DIR}/${PCAP2_NAME}
    PCAP Should Contain Message             ip.addr == 10.42.54.13 && cmp    pcap_file=${TEST_OUTPUT_DIR}/${PCAP2_NAME}

Verify Key Length
    [Arguments]                             ${expected_length}
    ${connection}                           Connect to BTS
    ${output}                               Execute
    ...                                     openssl x509 -in /rom/trs_data/active/keystorage/certs/ec_cert.pem -text
    ...                                     connection=${connection}

    Log to console                          ${output}
    Should Contain                          ${output}  Public-Key: (${expected_length} bit)

    [Teardown]                              Disconnect from BTS
