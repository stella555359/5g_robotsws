*** Settings ***
Documentation   Keywords for CB012562
...
...  author:   Julia Wijas
...  contact:  julia.wijas@nokia.com

Resource        ../../../common_resources/certificates/certificates.robot
Resource        ../../../common_resources/commissioning/parameters.robot
Resource        ../../../common_resources/admin/admin.robot
Resource        ../../../common_resources/commissioning/commissioning.robot
Library         ../../../common_resources/admin/admin_utils.py
Library         ../../../common_resources/scf/scf_edit.py
Library         ta_emss
Library         ./keywords.py
*** Variables ***
${RSA_CA_SUBJECT_NAME}          CN=CB010265
&{CMP_OBJECT}                   RSA=CMP-1
...                             ECDSA=CMPECDSA-1
&{RSA_PARAMS}                   subjectAltType=DOMAIN    subjectAltName=.qwerty
${ECDSA_CA_SUBJECT_NAME}        CN=CB010265_1
&{ECDSA_PARAMS_1}               subjectAltType=DOMAIN    subjectAltName=.qwerty
&{ECDSA_PARAMS_2}               subjectAltType=DOMAIN    subjectAltName=.mobile-network.com
${PCAP_NAME}                    certs.pcap
&{SUBJECT_NAMES}                RSA=CN = CB010265
...                             ECDSA=CN = CB010265_1
${RSA_CA_SUBJECT_NAME_2}        CN=CB010265_First
&{RSA_PARAMS_2}                 subjectAltType=DOMAIN    subjectAltName=qwerty
${ECDSA_CA_SUBJECT_NAME_2}      CN=CB010265_First_ECDSA
&{ECDSA_PARAMS_3}               subjectAltType=DOMAIN    subjectAltName=qwerty
@{ECDSA_PARAMS_LIST_3}          &{ECDSA_PARAMS_3}
&{ECDSA_PARAMS_4}               subjectAltType=DOMAIN    subjectAltName=mobile-network.com
@{ECDSA_PARAMS_LIST_4}          &{ECDSA_PARAMS_4}
${default_SAN}                  0
&{SUBJECT_ALT_NAME_VALUES_RSA}  subjectAltName=.qwerty
...                             subjectAltType=DOMAIN
@{SUBJECT_ALT_NAME_LIST_RSA}    &{SUBJECT_ALT_NAME_VALUES_RSA}
&{SUBJECT_ALT_NAME_VALUES_ECDSA}      subjectAltName=.mobile-network.com
...                                   subjectAltType=DOMAIN
@{SUBJECT_ALT_NAME_LIST_ECDSA}        &{SUBJECT_ALT_NAME_VALUES_ECDSA}
&{value}                       ID=1-1-1
...                            MOC=CMP
...                            eesubjectname=${RSA_CA_SUBJECT_NAME}
&{CA_SUBJECT_NAMES}            RSA=${RSA_CA_SUBJECT_NAME}
...                            ECDSA=${ECDSA_CA_SUBJECT_NAME}
#&{EE_SUBJECT_NAMES}            RSA=${RSA_EE_SUBJECT_NAME_2}
#...                            ECDSA=${ECDSA_EE_SUBJECT_NAME_2}

*** Keywords ***
Configure CMP with EE Subject Name
    [Documentation]    Description:    This KW configure CMP with casubjectname and eesubjectname
    ...                Author:         julia.wijas@nokia.com
    [Arguments]                         ${ca_subject_name}
    ...                                 ${ee_subject_name}
    ...                                 ${bts_id}=${BTS_ID}
    ...                                 ${server_type}=RSA
    ...                                 ${ca_server_host}=${CA_SERVER_IP}
    ...                                 ${server_path}=${CA_SERVER_PATH}
    ...                                 ${ca_server_port}=${CA_DEFAULT_PORT}
    ...                                 ${connection}=${NONE}
    ${server_object_name}               Get From Dictionary   ${CMP_OBJECT}   ${server_type}
    ${connection}=                      admin_utils.create connection if not exist    ${connection}    alias=temp_conn

    Change Multiple Parameters on BTS   dist_name=MRBTS-${bts_id}/MNL-1/CERTH-1/${server_object_name}
    ...                                 connection=${connection}
    ...                                 caSubjectName=${ca_subject_name}
    ...                                 eeSubjectName=${ee_subject_name}
    ...                                 serverHost=${ca_server_host}
    ...                                 serverPath=${server_path}
    ...                                 serverPort=${ca_server_port}

    [Teardown]                          Run keyword and ignore error
    ...                                 Disconnect from ADMIN    connection=temp_conn

Check Serial Number For EE Certs
    [Documentation]    Description:    This KW checks if a certificate with a given serial number is on the web
    ...                Author:         julia.wijas@nokia.com
    [Arguments]                        ${server_type}=RSA
    ${subject_name}                    Get From Dictionary    ${SUBJECT_NAMES}   ${server_type}
    ${cert_list}=    Get Certificates List
    ${connection}    Connect to ADMIN
    ${bts_info} =    coam_admin.Get Bts Info    connection=${connection}
    ${SERIAL_NR}=    Set Variable    ${bts_info['systemModules'][0]['serialNumber']}
    ${SERIAL_NUMBER}          Set Variable       CN = ${SERIAL_NR}.MRBTS-${BTS_ID}
    FOR  ${list}  IN  @{cert_list}
        Log                        ${list}                                    console=${TRUE}
        ${output}=  Run Keyword if  '${list}[issuer]' == '${subject_name}'
        ...         Return From Keyword If     '${list}[issuedTo]'=='${SERIAL_NUMBER}'
    END
    Should be true     ${output}

Delete CMP Objects
    [Documentation]    Description:    This KW delete CPM paramteters: eeSubjectAltName, caSubjectName and eeSubject Name
    ...                for RSA nad ECDSA
    ...                Author:         julia.wijas@nokia.com
    &{cmp_object_param_dict}=        Create Dictionary    parameterName=eeSubjectAltNames     operation=delete      value=
    &{cmp_object_1_param_dict}=      Create Dictionary    parameterName=caSubjectName         operation=delete      value=
    &{cmp_object_2_param_dict}=      Create Dictionary    parameterName=eeSubjectName         operation=delete      value=
    @{cmp_object_rsa_param_list}=    Create List      ${cmp_object_param_dict}   ${cmp_object_1_param_dict}
    ...                                               ${cmp_object_2_param_dict}
    &{cmp_object_rsa_dict}=          Create Dictionary    distName=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                               operation=update
    ...                                               parameters=@{cmp_object_rsa_param_list}
    @{cmp_object_ecdsa_param_list}=    Create List    ${cmp_object_param_dict}   ${cmp_object_1_param_dict}
    ...                                               ${cmp_object_2_param_dict}
    &{cmp_object_ecdsa_dict}=        Create Dictionary    distName=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                               operation=update
    ...                                               parameters=@{cmp_object_ecdsa_param_list}
    @{cmp_object_delta}=             Create List    ${cmp_object_rsa_dict}    ${cmp_object_ecdsa_dict}
    Recommission Parameters By Delta                  delta=${cmp_object_delta}
    Wait until BTS reach Configured or OnAir state

Create Issuers List
    [Documentation]    Description:    this keyword creates a list of certificate issuers on the web
    ...                Author:         julia.wijas@nokia.com
    ${cert_list}=  Get Certificates List  TA
    @{issuers}=  Create List  ${EMPTY}
    FOR  ${list}  IN  @{cert_list}
        log  ${list}  console=true
        Append To List  ${issuers}  ${list}[issuer]
    END
    [Return]  @{issuers}

Create IssuedTo List
    [Documentation]    Description:    this keyword creates a list of certificate issuedTo on the web
    ...                Author:         julia.wijas@nokia.com
    ${cert_list}=  Get Certificates List
    @{issuers}=  Create List  ${EMPTY}
    FOR  ${list}  IN  @{cert_list}
        log  ${list}  console=true
        Append To List  ${issuers}  ${list}[issuedTo]
    END
    [Return]  @{issuers}

Create eeSubjectAltNames Structure
    [Documentation]    Description:    Adding list eeSubjectAltNames with subjectAltType and subjectAltName parameters to scf and upload it to BTS
    ...                Author:         julia.wijas@nokia.com
    [Arguments]      ${param}=${SUBJECT_ALT_NAME_VALUES_ECDSA}    ${dist_name}=MNL-1/CERTH-1/CMP-1     ${structure_name}=eeSubjectAltNames
    ${base_scf_path}=    Download SCF
    ${new_scf_path}=     add_populated_list_to_scf    ${base_scf_path}    ${dist_name}    ${structure_name}    ${param}
    Log  Uploading scf...  console=true
    Commission SCF    scf_file=${new_scf_path}    skip_parameter_relation_errors=False    timeout=900
    Log  Scf uploaded  console=true
#    ${base_scf_path}=    Download SCF
#    ${new_scf_path}=     add paramameter to scf    ${BTS_ID}     ${param}    ${base_scf_path}
#    Log  Uploading scf...  console=true
#    Run Keyword With ADMIN Connection  coam_admin.perform_commissioning      scf_file=${new_scf_path}
#    ...                                skip_parameter_relation_errors=False  should_activate=True  timeout=900
    Log  Scf uploaded  console=true
    Sleep                   2 min
    ...                     reason=Wait until scf uploaded properly
