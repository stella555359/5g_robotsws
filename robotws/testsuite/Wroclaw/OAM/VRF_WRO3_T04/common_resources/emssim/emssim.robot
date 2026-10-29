*** Settings ***
Documentation   Keywords for EMSSIM simulator
Resource      ../admin/admin.robot
Resource      ./emssim_variables.robot

Library      OperatingSystem
Library     ./emssim_operation.py

*** Keywords ***
Connect and Activate EMSSIM
    [Arguments]  ${enable_tls}=1    ${cert_type}=RSA
    ${cert}    Set Variable If    '${cert_type}'=='RSA'    ${cert_RSA}    ${cert_ECDSA}
    ${key}    Set Variable If    '${cert_type}'=='RSA'     ${key_RSA}     ${key_ECDSA}
    ${cacert}    Set Variable If    '${cert_type}'=='RSA'     ${cacert_RSA}     ${cacert_ECDSA}
    Log                                 Connecting with EMSSIM    console=true
    ${emssim_connection}                emssim_operation.Integrate EMSSIM with BTS
    ...                                 bts_id=${BTS_ID}
    ...                                 host=${VM_IP}
    ...                                 user=flexi${BTS_ID}
    ...                                 cert_type=${cert_type}
    ...                                 cert=${cert}
    ...                                 key=${key}
    ...                                 cacert=${cacert}
    ...                                 tls=${enable_tls}
    Run keyword if  ${enable_tls} == 1
    ...      Wait Until NMS in Secured Status    manager_id=EMSsim
    Log                                 EMSSIM connection established.
    ...                                 console=${TRUE}
    [Return]                            ${emssim_connection}

Disconnect From EMSSIM
    [Arguments]                         ${connection}
    Close Connection With EMSSIM        bts_id=${BTS_ID}
    ...                                 connection=${connection}

Update SW with EMMSIM
    [Arguments]  ${target}
    Log  Starting SW update by emssim...  console=true
    RUN  sudo mkdir /home/emssim/LOADS
    ${out}=  RUN  sudo cp /home/ute/Downloads/${target} /home/emssim/LOADS/${target}
    Update SW Using Emssim  ${target}  ${BTS_ID}
    Log         SW updated  console=true

Edit Parameter with EMSSIM
     [Documentation]    Description:     Edit parameter on BTS via EMSSIM
     ...                Input:           emssim_connection = the EMSSIM connection
     ...                                 object = for example: MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
     ...                                 parameter = caSubjectName
     ...                                 value = CN=CB005999_test
     ...                Author:          julia.wijas@nokia.com
     [Arguments]                         ${emssim_connection}
     ...                                 ${object}
     ...                                 ${parameter}
     ...                                 ${value}
     Wait until keyword succeeds         1x  1min    execute_command_on_emssim
     ...                                 command=edit ${object} ${parameter} ${value}
     ...                                 connection=${emssim_connection}

EMSSIM Configure CMP with EE Subject Name And EE Subject AltName
     [Documentation]    Description:    Configuring CMP object with eeSubjectName and eeSubjectAltname
     ...                Input:          emssim_connection = the EMSSIM connection
     ...                                parameter = the parameter to set
     ...                                server_type = RSA/ECDSA
     ...                                cmp_object = for example: MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
     ...                                ca_subject_names = subject name for CA certificate
     ...                                ee_subject_nemes = subject name for EE certificate
     ...                                ca_server_path = the path to server, for example: pkix
     ...                                ca_server_IP = the IP of server, for example: 10.42.54.13
     ...                                ca_default_port = the port of server, for eample: 8080
     ...                Author:         julia.wijas@nokia.com
    [Arguments]                         ${parameter}
    ...                                 ${server_type}=RSA
    ...                                 ${cmp_object}=${CMP_OBJECT}
    ...                                 ${ca_subject_names}=${CA_SUBJECT_NAMES}
    ...                                 ${ee_subject_nemes}=${EE_SUBJECT_NAMES}
    ...                                 ${ca_server_path}=${CA_SERVER_PATH}
    ...                                 ${ca_server_IP}=${CA_SERVER_IP}
    ...                                 ${ca_default_port}=${CA_DEFAULT_PORT}
    ${server_object_name}               Get From Dictionary   ${cmp_object}   ${server_type}
    ${ca_subject_name}                  Get From Dictionary   ${ca_subject_names}   ${server_type}
    ${ee_subject_name}                  Get From Dictionary   ${ee_subject_nemes}   ${server_type}
    ta_emss.create_new_plan
    ta_emss.plan_record_of_structural_attribute_creation_with_values        "${server_object_name}-1-1"
    ...                                                                     eeSubjectAltNames
    ...                                                                     ${parameter}
    ta_emss.edit_planned_object_attributes                                  "${server_object_name}-1-1"
    ...                                                                     eeSubjectName=${ee_subject_name}
    ta_emss.edit_planned_object_attributes                                  "${server_object_name}-1-1"
    ...                                                                     caSubjectName=${ca_subject_name}
    ta_emss.edit_planned_object_attributes                                  "${server_object_name}-1-1"
    ...                                                                     serverPath=${ca_server_path}
    ta_emss.edit_planned_object_attributes                                  "${server_object_name}-1-1"
    ...                                                                     serverPort=${ca_default_port}
    ta_emss.edit_planned_object_attributes                                  "${server_object_name}-1-1"
    ...                                                                     serverHost=${ca_server_IP}
    ta_emss.apply_planned_changes

EMSSIM Change EE SubjectAltName
    [Documentation]    Description:     Configuring CMP object with eeSubjectAltName
     ...                                value = the value for eeSubjectAltNames parameter
     ...                                server_type = RSA/ECDSA
     ...                                structural_attributes = for example: MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
     ...                Author:         julia.wijas@nokia.com
    [Arguments]                         ${value}
    ...                                 ${server_type}=RSA
    ...                                 ${structural_attributes}=${STRUCTURAL_ATTRIBUTES}
    ${structural_attribute}             Get From Dictionary   ${structural_attributes}   ${server_type}
    ta_emss.create_new_plan
    ta_emss.plan_records_deletion_from_structural_attribute_with_values     ${structural_attribute}
    ...                                                                     eeSubjectAltNames
    ta_emss.apply_planned_changes
    ta_emss.create_new_plan
    ta_emss.plan_record_of_structural_attribute_creation_with_values        ${structural_attribute}
    ...                                                                     eeSubjectAltNames
    ...                                                                     ${value}
    ta_emss.apply_planned_changes
