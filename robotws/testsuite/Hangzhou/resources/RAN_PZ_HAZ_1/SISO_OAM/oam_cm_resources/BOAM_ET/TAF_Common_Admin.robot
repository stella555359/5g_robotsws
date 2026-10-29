*** Settings ***
Documentation
...     Author: xi.wu@nokia-sbell.com
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
#Library    taf.sbts.oam.coam.admin.interface
Library    OperatingSystem

*** Variables ***
${ADMIN_BTS_HOST}=            192.168.255.129
${ADMIN_BTS_PORT}=            443
${ADMIN_USERNAME}=            Nemuadmin
${ADMIN_PASSWORD}=            nemuuser
${ADMIN_USE_SSL}=             True
${ADMIN_UPDATE_INTERVAL}=     5000
${ADMIN_API_LOG_DIR}=         ${OUTPUT_DIR}
${ADMIN_TIMEOUT}=             30
${ADMIN_ALIAS}=               default
${CERT_FILE_CA}               ${CURDIR}/certs/ca.pem
${CERT_FILE_EE}               ${CURDIR}/certs/user.pem
${CERT_FILE_PRIVATE}          ${CURDIR}/certs/privkey.pem
${CERT_FILE_P12}              ${CURDIR}/certs/cert.p12
${MO_CERTH_CMP}               MRBTS-1/MNL-1/CERTH-1/CMP-1
${CMP_SERVER_INFO_IP}         10.106.210.183
${CMP_SERVER_INFO_PORT}       8081
${CMP_SERVER_INFO_SERVERPATH}     pkix
${CMP_SERVER_INFO_CASUBNAME}  C=CN, O=Nokia, CN=FlatOAM_EIT_Testing
${CMP_SERVER_INFO_EESUBNAME}  CN=BTS100

*** Keywords ***
ADMIN Setup Admin
    [Arguments]    ${bts_host}=${ADMIN_BTS_HOST}
    ...            ${bts_port}=${ADMIN_BTS_PORT}
    ...            ${username}=${ADMIN_USERNAME}
    ...            ${password}=${ADMIN_PASSWORD}
    ...            ${use_ssl}=${ADMIN_USE_SSL}
    ...            ${update_interval}=${ADMIN_UPDATE_INTERVAL}
    ...            ${admin_api_log_dir}=${ADMIN_API_LOG_DIR}
    ...            ${timeout}=${ADMIN_TIMEOUT}
    ...            ${alias}=${ADMIN_ALIAS}
    #Log To Console    \nSetup Admin\n
    coam.Setup Admin
    ...    bts_host=${bts_host}
    ...    bts_port=${bts_port}
    ...    username=${username}
    ...    password=${password}
    ...    use_ssl=${use_ssl}
    ...    update_interval=${update_interval}
    ...    admin_api_log_dir=${admin_api_log_dir}
    ...    timeout=${timeout}
    ...    alias=${alias}

ADMIN Teardown Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    #Log To Console    \Teardown Admin\n
    coam.Teardown Admin    alias=${alias}

ADMIN Collect Snapshot
    [Arguments]    ${snapshot_name}=${OUTPUTDIR}/${TESTNAME}/Snapshot.zip
    ...            ${coverage}=Full
    ...            ${force}=${TRUE}
    ...            ${timeout}=360
    ...            ${alias}=${ADMIN_ALIAS}
    ${result}=   coam.Collect Snapshot    target_file_name=${snapshot_name}
    ...                           coverage=${coverage}
    ...                           force=${force}
    ...                           timeout=${timeout}
    ...                           alias=${alias}
    [Return]   ${result}


ADMIN Perform Commissioning
    [Arguments]    ${scf_file}
    ...            ${skip_parameter_relation_errors}=${False}
    ...            ${should_activate}=${True}
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    Log To Console    \Send Full Plan To BTS\n
    coam.Perform Commissioning
    ...                                scf_file=${scf_file}
    ...                                skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                should_activate=${should_activate}
    ...                                timeout=${timeout}
    ...                                connection=${alias}



ADMIN Perform Parameter Recommissioning
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${operation}
    ...            ${skip_parameter_relation_errors}=${TRUE}
    ...            ${should_activate}=${TRUE}
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    #Log To Console    \Perform Parameter Recommissioning\n
    coam.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    connection=${connection}


ADMIN Perform Parameter Update
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    #Log To Console    \Perform Parameter Update\n
    ADMIN Perform Parameter Recommissioning    dist_name=${dist_name}
    ...                                        parameter=${parameter}
    ...                                        operation=update
    ...                                        value=${value}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}


ADMIN Perform Object Recommissioning
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${operation}
    ...            ${skip_parameter_relation_errors}=${TRUE}
    ...            ${should_activate}=${TRUE}
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    #Log To Console    \Perform Object Recommissioning\n
    coam.Perform Object Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    connection=${connection}


ADMIN Collect SCF
    [Arguments]    ${target_file_name}=${OUTPUTDIR}/${TESTNAME}/scf.xml
    ...            ${export_type}=configuration
    ...            ${timeout}=30
    ...            ${connection}=${ADMIN_ALIAS}
    coam.Collect SCF
    ...    target_file_name=${target_file_name}
    ...    export_type=${export_type}
    ...    timeout=${timeout}
    ...    connection=${connection}


ADMIN Get All SCF
    [Arguments]    ${export_type}=configuration
    ...            ${timeout}=30
    ...            ${connection}=${ADMIN_ALIAS}
    ${scf_content}    coam.Get SCF
    ...    export_type=${export_type}
    ...    timeout=${timeout}
    ...    connection=${connection}
	[Return]    ${scf_content}


ADMIN Get SCF
    [Arguments]    ${Alias}=default    ${timeout}=900
	Sleep    1s    to avaoid SCF with same name
    ${time}    Get Timestamp
    ${SCFFile}    Set Variable    ${TA_LOG_DIRECTORY}${/}scf_${time}.xml
    ${SCFContent}    coam.Get SCF    timeout=${timeout}    alias=${Alias}
    Append To File    ${SCFFile}    ${SCFContent}
    [Return]    ${SCFFile}

ADMIN Get Parameters For Class
    [Arguments]    ${infomodel_class_name}
    ...            ${parameter_name}=.*
    ...            ${timeout}=10
    ...            ${connection}=${ADMIN_ALIAS}
	${object_info}    coam.get_objects_by_class_name    ${infomodel_class_name}    ${timeout}    ${connection}
    ${out_parameters}=    coam.get_parameters
    ...    dist_name=${object_info[0]['distName']}
    ...    pattern=${parameter_name}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]    ${out_parameters}


ADMIN Install Certs
    [Arguments]   ${cert_file}=${CERT_FILE_P12}   ${cert_format}=p12
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2022.03.02 | 5G22R3 | Jet Li | first create |
    ...
    ...    This KW is used to install user certificates to gnb, which will be used for Netconf session establishment.
    ...    Precondition, ADMIN is Setup
    ${cmd1}    Set Variable    -inkey ${CERT_FILE_PRIVATE} -certfile ${CERT_FILE_CA} -out ${cert_file}
    ${cmd}    Set Variable    openssl pkcs12 -export -password pass:onap -in ${CERT_FILE_EE} ${cmd1}
    ${result}=    Run Process    ${cmd}    shell=True    timeout=20
    Run Keyword If   "${cert_format}"=="p12"
    ...    coam.install_certificate   cert_file=${cert_file}   cert_type=BtsTrustChain
    ...    cert_format=P12   password=onap
    ...    ELSE IF   "${cert_format}"=="pem"   coam.install_certificate   cert_file=${cert_file}
    ...    cert_type=AdditionalCa    cert_format=PEM
    ...    ELSE   log   '${cert_file}' is not certificate

Modify DiagSnapDestination To LSS With DIR
    [Arguments]    ${LSS_DIR}    ${lssPortNo}=22    ${operation}=update
	${dict_lssConfig_values}    Create Dictionary    directory    ${LSS_DIR}    lssIPaddress    ${LSS_HOST}    lssPortNo    ${lssPortNo}
	@{lssConfig_param_list}    Create List    ${dict_lssConfig_values}
	${dict_lssConfig}    Create Dictionary    parameterName    lssConfig
    ...    operation    update    value    ${lssConfig_param_list}
	${dict_diagSnapDestination}    Create Dictionary    parameterName    diagSnapDestination
    ...    operation    update    value    lss
	@{lss_list}    Create List    ${dict_diagSnapDestination}    ${dict_lssConfig}
    Log    ${lss_list}
	${scf_content}    ADMIN Get SCF
	ADMIN Perform Object Recommissioning    ${MO_TRBLCADM}     ${lss_list}    ${operation}

Modify DiagSnapDestination To LSS Without DIR
    [Arguments]    ${lssPortNo}=22    ${operation}=update
	${dict_lssConfig_values}    Create Dictionary    lssIPaddress    ${LSS_HOST}    lssPortNo    ${lssPortNo}
	@{lssConfig_param_list}    Create List    ${dict_lssConfig_values}
	${dict_lssConfig}    Create Dictionary    parameterName    lssConfig
    ...    operation    update    value    ${lssConfig_param_list}
	${dict_diagSnapDestination}    Create Dictionary    parameterName    diagSnapDestination
    ...    operation    update    value    lss
	@{lss_list}    Create List    ${dict_diagSnapDestination}    ${dict_lssConfig}
    Log    ${lss_list}
	${scf_content}    ADMIN Get SCF
	ADMIN Perform Object Recommissioning    ${MO_TRBLCADM}     ${lss_list}    ${operation}

Modify DiagSnapDestination To Netact
	Create Delta    delta1
    Append Parameter Update To Delta    ${MO_TRBLCADM}    diagSnapDestination    netact    delta_id=delta1
	Append Parameter Delete To Delta    ${MO_TRBLCADM}    lssConfig    delta_id=delta1
	${delta1_data}    Get Delta    delta1
	Log    ${delta1_data}
	${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta1_data}  skip_parameter_relation_errors=True
    Log    ${feedback}

ADMIN Perform Site Reset
    [Arguments]    ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    ...            ${wait_for_reconnection}=True
    ...            ${detailed_output}=False
    coam.reset_site
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    wait_for_reconnection=${wait_for_reconnection}
    ...    detailed_output=${detailed_output}

ADMIN Perform Parameter Delete
    [Arguments]    ${dist_name}    ${parameter}
#	${scf1content}    ADMIN Get SCF
    Create Delta    delta1
    Append Parameter Delete To Delta    ${dist_name}    ${parameter}     delta_id=delta1
    ${delta1_data}    Get Delta    delta1
	Log    ${delta1_data}
	${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta1_data}   skip_parameter_relation_errors=True
    Log    ${feedback}
	${scf_content}    ADMIN Get SCF

ADMIN Perform Parameter Add Fault
    [Arguments]    ${fault_value}     ${fault_trig_value}    ${dist_name}     ${operation}=update
	${para_values}    Create Dictionary    faultNumber    ${fault_value}    triggerType    ${fault_trig_value}
	@{para_value_list}    Create List    ${para_values}
	${parameter_value}    Create Dictionary    parameterName    faultSnapshotTriggers
    ...    operation    ${operation}    value    ${para_value_list}
	@{parameter_list}    Create List    ${parameter_value}
    Log    ${parameter_list}
	ADMIN Perform Object Recommissioning    ${dist_name}     ${parameter_list}    ${operation}
	${scf_content}    ADMIN Get SCF

Run Admin Cli
    [Arguments]
    ...    ${Shell}
    ...    ${Data}= '{"requestId":1,"parameters":{"name":"runSanityCheck"}}'
	...    ${OutputJson}= ${OUTPUTDIR}/${TESTNAME}/result.json      #Redirects JSON responses to a specified file
	...    ${OutputFile}= ${OUTPUTDIR}/${TESTNAME}/OutputFile.txt   #Payload file extracted from the response message
    ...    ${User}= Nemuadmin
	...    ${Pass}= nemuuser
    ...    ${Host}= 192.168.255.129
	...    ${Port}= 443
	${argu_p1}    Set Variable    --format=human --bts-host ${Host} --bts-username ${User} --bts-password ${Pass} --bts-port ${Port}
	${argu_p2}    Set Variable    --data ${Data} --output-json ${OutputJson} --output-file ${OutputFile}
    ${argu_p3}    Set Variable    > printout.txt 2>\&1
    Run    ${Shell} ${argu_p1} ${argu_p2} ${argu_p3}
    ${outputExist}   Run Keyword And Return Status    OperatingSystem.File Should Exist    ${OutputJson}
    ${feedback}=    Run Keyword If    '${outputExist}' == 'True'    Run    cat ${OutputJson}
    ...    ELSE    Run    cat printout.txt
	Log    ${feedback}
	[Return]    ${feedback}

Prepare Admin Cli
    [Arguments]    ${input_version}=${empty}
	${active_version}    coam.Get Sw Version
	${active_version}    Set Variable If     "${input_version}" != "${empty}"    ${input_version}    ${active_version}
	${version_splitted}    Split String    ${active_version}    _
	${is_trunk}    Run Keyword And Return Status    Should Contain    ${active_version}    _9999_
	${branch}    Set Variable If    ${is_trunk}    SBTS00    ${version_splitted[0]}
	${version}    Set Variable    ${branch}_${version_splitted[1]}_${version_splitted[2]}_${version_splitted[3]}_${version_splitted[4]}
	${url}    Set Variable    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/${branch}/${version}_ADMIN_CLI.zip
	Run    rm -rf /home/ute/*_ADMIN_CLI* && wget ${url} -q -P /home/ute/
	Run    mkdir -p /home/ute/${version}_ADMIN_CLI
	Run    unzip /home/ute/${version}_ADMIN_CLI.zip -d /home/ute/${version}_ADMIN_CLI
	${CliShell}    Set Variable    /home/ute/${version}_ADMIN_CLI/admin-cli.sh
	Set Suite Variable    ${CliShell}

ADMIN Check Bts Status
    [Arguments]    ${timeout}=30
    ...            ${connection}=${ADMIN_ALIAS}
    ...            ${wait_for_reconnection}=True
    ...            ${status}=OnAir
    Log To Console    ${wait_for_reconnection}
    ${real_status}    coam.get_bts_statuses
    ...    timeout=${timeout}
    ...    connection=${connection}
	Log To Console    ${real_status['proceduralState']}
	Should Be True    '${real_status['proceduralState']}' == '${status}'

Get Active SW Version
	${active_version}    coam.Get Sw Version
	${version_splitted}    Split String    ${active_version}    _
	${is_trunk}    Run Keyword And Return Status    Should Contain    ${active_version}    _9999_
	${branch}    Set Variable If    ${is_trunk}    SBTS00    ${version_splitted[0]}
	${version}    Set Variable    ${branch}_${version_splitted[1]}_${version_splitted[2]}_${version_splitted[3]}_${version_splitted[4]}
    [Return]    ${version}


ADMIN Configure CMP Server
    [Arguments]    ${CMP_SERVER_IP}=${CMP_SERVER_INFO_IP}
    ...    ${CMP_SERVER_PORT}=${CMP_SERVER_INFO_PORT}
    ...    ${CMP_SERVER_SERVERPATH}=${CMP_SERVER_INFO_SERVERPATH}
    ...    ${CMP_SERVER_CASUBNAME}=${CMP_SERVER_INFO_CASUBNAME}
    ...    ${CMP_SERVER_EESUBNAME}=${CMP_SERVER_INFO_EESUBNAME}
    Create Delta    delta1
    Append Parameter Update To Delta    ${MO_CERTH_CMP}    serverHost    ${CMP_SERVER_IP}    delta_id=delta1
    Append Parameter Update To Delta    ${MO_CERTH_CMP}    serverPath    ${CMP_SERVER_SERVERPATH}    delta_id=delta1
    Append Parameter Update To Delta    ${MO_CERTH_CMP}    serverPort    ${CMP_SERVER_PORT}    delta_id=delta1
    Append Parameter Update To Delta    ${MO_CERTH_CMP}    caSubjectName    ${CMP_SERVER_CASUBNAME}    delta_id=delta1
    Append Parameter Update To Delta    ${MO_CERTH_CMP}    eeSubjectName    ${CMP_SERVER_EESUBNAME}    delta_id=delta1
    ${delta1_data}    Get Delta    delta1
    Log    ${delta1_data}
    ${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta1_data}  skip_parameter_relation_errors=True
    Log    ${feedback}


ADMIN Cmp Initialize Certificate
    [Arguments]    ${key_pool_type}=RSA    ${timeout}=300
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2018.8.31| TL19 | Kingkong.Wang | first create |
    ...    | 2019.4.2| TL19 | Kingkong.Wang | update as UTE KW is deprecated |
    ...    | 2022.11.4| TL19 | qiaoli-ann.xu | update as key_pool_type introduced |
    ...
    ...    This KW is used to cmp initialize certificate from CA server.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | timeout | N | Time to wait for positive procedure result. |
    ...    | alias | N | Name of execution context. |
    ...
    ...    Return value: No
    ...
    ...    Exp:
    ...    | ADMIN Cmp Initialize Certificate | timeout =60 | alias=default |
    ...
    ...    Precondition:
    ...    ADMIN Setup
    ...
    ...    Status: Ready to use
    coam.cmp_initialize_certificate
    ...    key_pool_type=${key_pool_type}
    ...    timeout=${timeout}

ADMIN Restore Vendor Certificate
    [Arguments]    ${timeout}=300
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2018.8.31| TL19 | Kingkong.Wang | first create |
    ...
    ...    This KW is used to restore vendor certificate on BTS.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | timeout | N | Time to wait for positive procedure result. |
    ...    | alias | N | Name of execution context. |
    ...
    ...    Return value: No
    ...
    ...    Exp:
    ...    | ADMIN Restore Vendor Certificate | timeout =60| alias=default |
    ...
    ...    Precondition:
    ...    ADMIN Setup
    ...
    ...    Status: Ready to use
    coam.Restore vendor certificate    ${timeout}