*** Settings***

Documentation
...     description:    Variables used in test cases for the CB005999-B feature.

*** Variables ***
${ECDSA_SUBJECT_NAME}           CN=CB005999_test
${CROSS_SUBJECT_NAME}           CN=CB00599_cross_SUB
${DUMMY_SUBJECT_NAME}           CN=dummy
${NETACT_CONNECTION}            Actual connection object dynamically set in test setup
${TEST_OUTPUT_DIR}              Actual variable value dynamically set in test setup
${ECDSA_POLLING_SUBJECT_NAME}   CN=CB005999_polling
${POLLING_TIMEOUT}              60
${PCAP_NAME}                    certs.pcap
${PCAP2_NAME}                   certs2.pcap

${NE3S_INIT_ERROR_MSG}          *OperationFailed: [<class 'taf.gnb.oam.ne3s.ws.components.CERT.v1.
...                             resources.notifications.messages.CMPOperationNotification'>*
