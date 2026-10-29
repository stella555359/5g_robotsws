*** Settings ***
Documentation
...     description:    Test cases for the CB005999-A feature.

Resource        ../resources/CB005999.robot
Resource        ../../../common_resources/netact/netact_operations.robot
Resource        ../../../common_resources/certificates/certificates.robot

*** Keywords ***
CB005999_Manual_deployment_of_Sensitive_EC_CMP_client_parameters_from_WebEM_and_NMS
    FOR    ${server_type}    IN    @{server_types}
        Log  ${server_type}  console=true
        Wait until keyword succeeds         5x    1min    Configure CMP Server With NetAct    ${NETACT_CONNECTION}
        ...                                 ${CERT_PRESHARED_KEY}
        ...                                 ${CA_REFERENCE_NUMBER}
        ...                                 ${server_type}
        ...                                 MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
        ...                                 400
        Check if file contains valid data  ${server_type}
    END

CB005999_Re-configuration_of_CMP_parameters
    Download SCF                          filename=${SCF_NAME}
    ...                                   local_path=${OUTPUT DIR}

    ${param_changes}                      Create Dictionary
    ...                                   caSubjectName=${ECDSA_SUBJECT_NAME}
    ...                                   serverHost=${CA_SERVER_IP}
    ...                                   serverPath=${CA_SERVER_PATH}
    ...                                   serverPort=${CA_DEFAULT_PORT}
    ...                                   caCertificateUpdateTime=90

    Set Parameter Using Netact            dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                   param_changes=${param_changes}
    ...                                   path_to_scf=${OUTPUT DIR}/${SCF_NAME}
    ...                                   na_instance=${NETACT_CONNECTION}

    Log                                   CMP parameters configured with ${ECDSA_SUBJECT_NAME} from NetAct.
    ...                                   console=${TRUE}
    [Teardown]    Run Keyword and Ignore Error  Clear Certificates
