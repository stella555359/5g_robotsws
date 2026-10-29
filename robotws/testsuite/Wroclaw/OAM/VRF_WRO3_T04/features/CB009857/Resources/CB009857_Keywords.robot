*** Settings ***
Documentation
...  author:     Patryk Tatarek
...  contact:    patryk.tatarek@nokia.com

Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library     Collections
Library     String

*** Variables ***
${CMP_POLLING_SUBJECT_NAME}=      C=PL,O=NSN,CN=CMPPOLLING
${ECDSA_POLLING_SUBJECT_NAME}=    CN=CB005999_polling
${crl_update_alarm}=              CRL Update failure or certificate revoked

${primary_param_value}=           ${insta_ip_1}:389/CN=CB007672,OU=People,DC=nodomain?certificateRevocationList;binary
${secondary_param_value}=         ${insta_ip_2}:389/CN=CB007672,OU=People,DC=nodomain?certificateRevocationList;binary
${crldp_wrong_format}=    ${insta_ip_1}:389@@@^^^/CN=CB007672,OU=People,DC=nodomain?certificateRevocationList;binary
${crldp_weak_hash}=       ${insta_ip_1}:389/CN=CB007672weak,OU=People,DC=nodomain?certificateRevocationList;binary
${ldap_crldp}=            ldap://${insta_ip_1}:389/CN=CB007672,OU=People,DC=nodomain?certificateRevocationList;binary
${http_crldp}=            http://${insta_ip_2}:8080/crl-as-der/currentcrl-3516138.crl?id=3516138
${http_crldp_fake}=       http://8.8.8.8:8080/crl-as-der/currentcrl-3516138.crl?id=3516138
${ftp_crldp}=             ftp://${insta_ip_2}:8080/crl-as-der/currentcrl-3516138.crl?id=3516138
${ftp_crldp_google}=      ftp://8.8.8.8:8080/crl-as-der/currentcrl-3516138.crl?id=3516138
${insta_ip_1}=            10.42.54.11
${insta_ip_2}=            10.42.54.13

${cert_fail_sha_2k}=      Certificate validation - key length is not supported
${cert_fail_sha1}=        Certificate validation - Unsupported/weak signature algorithm

*** Keywords ***
Search for certificate in revocation list on vDU
    [Arguments]        ${cert}
    ${temp_conn}=      Connect to ADMIN    hw_type=vDU
    ${crl_info}=       vdu_admin.get_vdu_crl_information    vdu_connection=${temp_conn}
    ${cert_string}=    Convert to String    ${cert}
    ${crl_string}=     Convert to String    ${crl_info}
    Should Contain     ${crl_string}    ${cert_string}
    [Teardown]         Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

Search for certificate in revocation list on vCU
    [Arguments]        ${cert}
    ${temp_conn}=      Connect to ADMIN    hw_type=vCU
    ${crl_info}=       vcu_admin.get_current_crl    connection=${temp_conn}
    ${cert_string}=    Convert to String    ${cert}
    ${crl_string}=     Convert to String    ${crl_info}
    Should Contain     ${crl_string}    ${cert_string}
    [Teardown]         Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

CRL should be empty on vDU
    ${temp_conn}=      Connect to ADMIN    hw_type=vDU
    ${crl_info}=       vdu_admin.get_vdu_crl_information    vdu_connection=${temp_conn}
    Should be True    "${crl_info}"=="{'crlinfo_list': []}"
    [Teardown]         Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

CRL should be empty on vCU
    ${temp_conn}=      Connect to ADMIN    hw_type=vCU
    ${crl_info}=       vcu_admin.get_current_crl    connection=${temp_conn}
    ${crl_string}=     Convert to String    ${crl_info}
    ${empty_list}=     Convert to String    'list': []
    Should Contain     ${crl_string}    ${empty_list}
    [Teardown]         Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

Check if cert is not present in revocation list on vDU
    [Arguments]           ${cert}
    ${temp_conn}=         Connect to ADMIN    hw_type=vDU
    ${crl_info}=          vdu_admin.get_vdu_crl_information    vdu_connection=${temp_conn}
    ${cert_string}=       Convert to String    ${cert}
    ${crl_string}=        Convert to String    ${crl_info}
    Should not Contain    ${crl_string}    ${cert_string}
    [Teardown]            Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

Check if cert is not present in revocation list on vCU
    [Arguments]           ${cert}
    ${temp_conn}=         Connect to ADMIN    hw_type=vCU
    ${crl_info}=          vcu_admin.get_current_crl    connection=${temp_conn}
    ${cert_string}=       Convert to String    ${cert}
    ${crl_string}=        Convert to String    ${crl_info}
    Should not Contain    ${crl_string}    ${cert_string}
    [Teardown]            Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

Delete incorrect CRLDPCONFIG objects on vDU
    FOR    ${nr}    IN RANGE    2    20
        Log    Deleting CRLDPCONFIG-${nr} object    console=True
        Delete Object on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${nr}    hw_type=vDU
    END

Delete incorrect CRLDPCONFIG objects on vCU
    FOR    ${nr}    IN RANGE    2    20
        Log    Deleting CRLDPCONFIG-${nr} object    console=True
        Delete Object on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${nr}    hw_type=vCU
    END

Teardown incorrect CRLDPCONFIG on vDU
    Delete Mutliple CRLDP Objects    start=2    stop=21    hw_type=vDU
    Log    All additional CRLDP objects were deleted    console=True

Teardown incorrect CRLDPCONFIG on vCU
    Delete Mutliple CRLDP Objects    start=2    stop=21    hw_type=vCU
    Log    All additional CRLDP objects were deleted    console=True

Prepare for 20 objects test on vDU
    Perform Reset and Wait for Expected State    state=onAir   hw_type=vDU
    Restore Default Certificates on BTS          hw_type=vDU

Prepare for 20 objects test on vCU
    Perform Reset and Wait for Expected State    hw_type=vCU
    Restore Default Certificates on BTS          hw_type=vCU

Remove all eeSubjectAltNames structures from vCU
    ${temp_conn}=        Connect to ADMIN    hw_type=vCU
    ${delta_plan}=       vcu_admin.generate_delta_plan    plan_name=DELTA_PLAN    connection=${temp_conn}
    ${delta_plan_id}=    Set Variable    ${delta_plan['plan_id']}
    Wait Until Keyword Succeeds    3min    2s    _Check If vCU Delta Plan Was Created
    ...                                          id=${delta_plan['action_id']}    conn=${temp_conn}

    ${uuid}=             _Get vCU Specifical MO UUID    plan_id=${delta_plan_id}
    ...                  mo_dn=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMP-1    conn=${temp_conn}

    &{change_dict}=          Create Dictionary    operation_type=remove
    ...                                           parameter_path=/eeSubjectAltNames
    ...                                           value=${Empty}
    @{param_change_list}=    Create List    ${change_dict}
    ${result}=               vcu_admin.update_parameters_of_delta_plan
    ...                      plan_id=${delta_plan_id}    mo_uuid=${uuid}
    ...                      parameter_change_list=${param_change_list}    connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    2s    _Check If vCU Delta Plan Was Updated    plan_id=${delta_plan_id}
    ...                                          action_id=${result['action_id']}       conn=${temp_conn}

    ${valid_result}=    vcu_admin.validate_delta_plan    plan_id=${delta_plan_id}    connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    2s    _Check If vCU Validation Ends With Success     plan_id=${delta_plan_id}
    ...                                          action_id=${valid_result['action_id']}    conn=${temp_conn}

    ${active_result}=   vcu_admin.activate_delta_plan    plan_id=${delta_plan_id}    connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    2s    _Check If vCU Activation Ends With Success
    ...                                          plan_id=${delta_plan_id}    conn=${temp_conn}
    [Teardown]    Run Keywords    Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU
    ...    AND    Run Keyword and Ignore Error    Delete Delta Plan    delta_plan_id=${delta_plan_id}    hw_type=vCU

Remove all eeSubjectAltNames structures from vDU
    ${temp_conn}=        Connect to ADMIN    hw_type=vDU
    ${delta_plan}=       vdu_admin.generate_delta_plan    plan_name=DELTA_PLAN    vdu_connection=${temp_conn}
    ${delta_plan_id}=    Set Variable    ${delta_plan['plan_id']}
    Wait Until Keyword Succeeds    3min    2s    _Check If vDU Delta Plan Was Created
    ...                                          id=${delta_plan['action_id']}    conn=${temp_conn}

    ${param_change_dict}=    Create Dictionary    eeSubjectAltNames    ${Empty}
    ${result}=               vdu_admin.update_vdu_parameter_of_delta_plan
    ...                      plan_id=${delta_plan_id}    mo_dn=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ...                      updated_paras_dict=${param_change_dict}    operation=remove    vdu_connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    2s    _Check If vDU Delta Plan Was Updated    plan_id=${delta_plan_id}
    ...                                          action_id=${result['action_id']}       conn=${temp_conn}

    ${valid_result}=    vdu_admin.validate_delta_plan    delta_plan_id=${delta_plan_id}     vdu_connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    2s    _Check If vDU Validation Ends With Success     plan_id=${delta_plan_id}
    ...                                          action_id=${valid_result['action_id']}    conn=${temp_conn}

    ${active_result}=   vdu_admin.activate_delta_plan    delta_plan_id=${delta_plan_id}    vdu_connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    2s    _Check If vDU Activation Ends With Success
    ...                                          plan_id=${delta_plan_id}    conn=${temp_conn}
    [Teardown]    Run Keywords    Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU
    ...    AND    Run Keyword and Ignore Error    Delete Delta Plan    delta_plan_id=${delta_plan_id}    hw_type=vDU

Try to Install Certificate and Look For Given Fail on vCU
    [Documentation]    Description:    Try to install certificate from file, expect failure with given reason
    ...                Input:          cert_path = path to cert file
    ...                                cert_type = CA/EE
    ...                                fail_reason = reason for installation failure, for example:
    ...                                              Certificate validation - key length is not supported
    ...                                              Certificate validation - Unsupported/weak signature algorithm
    [Arguments]        ${cert_path}    ${cert_type}    ${fail_reason}
    ${temp_conn}=      Connect to ADMIN    hw_type=vCU
    ${output}=         vcu_admin.install_operators_certificate    certificate_file_path=${cert_path}
    ...                certificate_type=${cert_type}    connection=${temp_conn}
    Should Be True     "${output["status"]}"=="Failed"
    Should Be True     "${output["reason"]}"=="${fail_reason}"
    [Teardown]         Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

Try to Install Certificate and Look For Given Fail on vDU
    [Documentation]    Description:    Try to install certificate from file, expect failure with given reason
    ...                Input:          cert_path = path to cert file
    ...                                cert_type = CA/EE
    ...                                fail_reason = reason for installation failure, for example:
    ...                                              Certificate validation - key length is not supported
    ...                                              Certificate validation - Unsupported/weak signature algorithm
    ...                                cert_encoding = encoding of the cert file, by default .pem
    [Arguments]        ${cert_path}    ${cert_type}    ${fail_reason}    ${cert_encoding}=pem
    ${temp_conn}=      Connect to ADMIN    hw_type=vDU
    ${oper_id}=        vdu_admin.install_vdu_certificates    cert_file_path=${cert_path}
    ...                cert_type=${cert_type}    cert_file_encoding=${cert_encoding}    vdu_connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    2s    Check if Certificate has been rejected on vDU
    ...                                          oper_id=${oper_id}    fail=${fail_reason}    conn=${temp_conn}
    [Teardown]         Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

Check if Certificate has been rejected on vDU
    [Arguments]       ${oper_id}    ${fail}    ${conn}
    ${output}=        vdu_admin.get_trs_api_operation_status    operation_id=${oper_id}    vdu_connection=${conn}
    Should Be True    "${output["status"]}"=="Failed"
    Should Be True    "${output["reason"]}"=="${fail}"

Check if Certificate is present on vCU
    [Arguments]             ${cert}
    ${cert_list}=           Check Certificates     hw_type=vCU
    ${cert_string}=         Convert to String      ${cert}
    ${cert_list_string}=    Convert to String      ${cert_list}
    Should Contain          ${cert_list_string}    ${cert_string}

Check if Certificate is present on vDU
    [Arguments]             ${cert}
    ${cert_list}=           Check Certificates     hw_type=vDU
    ${cert_string}=         Convert to String      ${cert}
    ${cert_list_string}=    Convert to String      ${cert_list}
    Should Contain          ${cert_list_string}    ${cert_string}
