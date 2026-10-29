*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Library   BuiltIn
Library   XML   True
Library   String
Library   DateTime
Library   Collections
Library   OperatingSystem

Library   taf.nms.nom   WITH NAME   nom


*** Variables ***
# ${API_USERNAME}   neonetics
# ${API_PASSWORD}   Nokia_150
# ${APIGW_URI}   https://apigw.srncnms07.srnblr.nsn-rdnet.net
# ${USER_MGMT_URI}   https://user-mgmt.srncnms07.srnblr.nsn-rdnet.net


*** Keywords ***
NOM Login
    [Arguments]   ${client_id}=Client_${MRBTS_ID}   ${username}=${API_USERNAME}   ${password}=${API_PASSWORD}
    ...   ${apigw_uri}=${APIGW_URI}   ${user_mgmt_uri}=${USER_MGMT_URI}
    ...   ${nom_version}=nom_v1   ${port}=443   ${secure}=${True}

    ${nom_rf_secret}   nom.register_the_client
    ...   client_id=${client_id}
    ...   username=${username}
    ...   password=${password}
    ...   apigw_uri=${apigw_uri}

    nom.connect_to
    ...   user_mgmt_uri=${user_mgmt_uri}
    ...   apigw_uri=${apigw_uri}
    ...   client_id=${client_id}
    ...   client_secret=${nom_rf_secret}
    ...   port=${port}
    ...   username=${username}
    ...   password=${password}
    ...   nom_version=${nom_version}
    ...   secure=${secure}

NOM Logout
    [Arguments]   ${client_id}=Client_${MRBTS_ID}   ${username}=${API_USERNAME}   ${password}=${API_PASSWORD}   ${apigw_uri}=${APIGW_URI}
    nom.delete_the_client
    ...   client_id=${client_id}
    ...   username=${username}
    ...   password=${password}
    ...   apigw_uri=${apigw_uri}

NOM Get Active Alarms
    ${alarms}   nom.get_active_alarms
    [Return]   ${alarms}

NOM Integrate NE
    [Arguments]   ${plan_name}   ${reintegrate}=${True}
    ${operation_list}   nom.integrate_ne
    ...   plan_name=${plan_name}
    ...   reintegrate=${reintegrate}
    ...   timeout=${600}

NOM Interrupt Operation
    [Arguments]   ${operation_id}
    ${operation_ids}   nom.interrupt_operation   operation_id=${operation_id}
    [Return]   ${operation_ids}

NOM Wait For Operation Status
    [Arguments]   ${operation_id}   ${timeout}=${3600}   ${retry_interval}=${60}
    nom.wait_for_operation_status
    ...   operation_id=${operation_id}
    ...   timeout=${timeout}
    ...   retry_interval=${retry_interval}

NOM Check Operation Status
    [Arguments]   ${operation_id}   ${status}=finished
    # @{status_enum_list}   Create List   queuing   ongoing   finished   failed   interrupted
    # Run Keyword If   ${status} not in ${status_enum_list}
    # ...   Fail   Please Enter Correct Status: ['queuing', 'ongoing', 'finished', 'failed', 'interrupted']

    @{operation_id_list}   Create List   ${operation_id}
    ${operation_list}   nom.get_operation_status   operation_ids=${operation_id_list}
    @{status_list}   Create List
    FOR   ${operation}   IN   @{operation_list}
        Append To List   ${status_list}   ${operation['status']}
    END
    List Should Contain Value   ${status_list}   ${status}

NOM Import Plan
    [Documentation]
    ...   Example:
    ...   plan_type: INTEGRATION, DEINTEGRATION, GENERAL
    [Arguments]   ${path_to_plan}   ${name}  ${description}=None   ${plan_type}=GENERAL   ${overwrite}=${True}
    nom.import_plan
    ...   path_to_plan=${path_to_plan}
    ...   name=${name}
    ...   description=${description}
    ...   plan_type=${plan_type}
    ...   overwrite=${overwrite}

NOM Import Software
    [Documentation]   NOM Import Software
    ...   Author: yin.4.chen@nokia-sbell.com
    ...   Example:
    ...   file_directory=${OUTPUT_DIR}
    ...   file_name=SBTS00_ENB_9999_211103_000002_release_BTSSM_downloadable_A54.zip
    ...   sw_version=SBTS00_ENB_9999_211103_000002
    [Arguments]   ${file_directory}   ${file_name}   ${sw_version}   ${ne_type}=MRBTS
    nom.import_sw_package
    ...   file_path=${file_directory}/${file_name}
    ...   file_name=${file_name}
    ...   ne_sw_version=${sw_version}
    ...   ne_type=${ne_type}

NOM Download Software
    [Documentation]
        ...   Author: yin.4.chen@nokia-sbell.com
    ...   Example:
    ...   @{gnb_list}   Create List   MRBTS-1234   MRBTS-5678
    ...   ${sw_version}   Set Variable   SBTS00_ENB_9999_211103_000002
    [Arguments]   ${gnb_list}   ${sw_version}
    ${status}   nom.provision_sw
    ...   integrated_ids=${gnb_list}
    ...   ne_sw_version=${sw_version}
    ...   download=${True}
    ...   activate=${False}
    ...   timeout=${7200}
    [Return]   ${status}

NOM Download Software And Return Operation ID
    [Documentation]
        ...   Author: yin.4.chen@nokia-sbell.com
    ...   Example:
    ...   @{gnb_list}   Create List   MRBTS-1234   MRBTS-5678
    ...   ${sw_version}   Set Variable   SBTS00_ENB_9999_211103_000002
    [Arguments]   ${gnb_list}   ${sw_version}
    ${operation_id}   nom.provision_sw
    ...   integrated_ids=${gnb_list}
    ...   ne_sw_version=${sw_version}
    ...   download=${True}
    ...   activate=${False}
    ...   timeout=${7200}
    ...   run_async=${True}
    Dictionary Should Contain Key   ${operation_id}   operation_id
    [Return]   ${operation_id['operation_id']}

NOM Activate Software
    [Documentation]
        ...   Author: yin.4.chen@nokia-sbell.com
    ...   Example:
    ...   @{gnb_list}   Create List   MRBTS-1234   MRBTS-5678
    ...   ${sw_version}   Set Variable   SBTS00_ENB_9999_211103_000002
    [Arguments]   ${gnb_list}   ${sw_version}
    ${status}   nom.provision_sw
    ...   integrated_ids=${gnb_list}
    ...   ne_sw_version=${sw_version}
    ...   download=${False}
    ...   activate=${True}
    ...   timeout=${7200}
    [Return]   ${status}

NOM Provision Software
    [Documentation]
        ...   Author: yin.4.chen@nokia-sbell.com
    ...   Example:
    ...   @{gnb_list}   Create List   MRBTS-1234   MRBTS-5678
    ...   ${sw_version}   Set Variable   SBTS00_ENB_9999_211103_000002
    [Arguments]   ${gnb_list}   ${sw_version}
    ${status}   nom.provision_sw
    ...   integrated_ids=${gnb_list}
    ...   ne_sw_version=${sw_version}
    ...   download=${True}
    ...   activate=${True}
    ...   timeout=${7200}
    [Return]   ${status}

NOM Rollback Software
    [Documentation]
        ...   Author: yin.4.chen@nokia-sbell.com
    ...   Example:
    ...   @{gnb_list}   Create List   MRBTS-1234   MRBTS-5678
    [Arguments]   ${gnb_list}
    ${status}   nom.rollback_sw
    ...   integrated_ids=${gnb_list}
    ...   timeout=${600}
    [Return]   ${status}

NOM Get Software List
    [Arguments]   ${ne_type}=MRBTS
    @{sw_package_list}   nom.get_sw_package_list   ne_type=${ne_type}
    @{software_list}   Create List
    FOR   ${software}   IN   @{sw_package_list}
        ${software_version}   Set Variable   ${software['ne_sw_version']}
        Append To List   ${software_list}   ${software_version}
    END
    [Return]   ${software_list}

NOM Check Software Exist
    [Arguments]   ${software_version}
    @{software_list}   NOM Get Software List
    List Should Contain Value   ${software_list}   ${software_version}

NOM Delete Software
    [Arguments]   ${sw_version}
    ${status}   nom.delete_sw_package
    ...   ne_sw_version=${sw_version}
    ...   timeout=${600}
    [Return]   ${status}

NOM Upload Alarms
    [Documentation]
        ...   Author: yin.4.chen@nokia-sbell.com
    ...   Example:
    ...   @{gnb_list}   Create List   MRBTS-1234   MRBTS-5678
    [Arguments]   ${gnb_list}
    ${status}   nom.upload_alarms
    ...   integrated_ids=${gnb_list}
    ...   timeout=${600}
    [Return]   ${status}


# -----------------------------------------------------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------------------------------------------
# Call NOM API From Remote Server(EDGE)
NOM API Connect To Remote Server
    [Arguments]   ${hostname}=${EDGE_IP}   ${username}=${EDGE_USER}   ${key_path}=${EDGE_KEY}   ${connection}=EDGE
    csn.Connect To
    ...   hostname=${hostname}
    ...   username=${username}
    ...   key_path=${key_path}
    ...   alias=${connection}

NOM API Disconnect To Remote Server
    [Arguments]   ${connection}=EDGE
    csn.Disconnect   connection=${connection}

NOM API Registrations
    [Arguments]   ${apigw_uri}=${APIGW_URI}   ${username}=${API_USERNAME}   ${password}=${API_PASSWORD}   ${connection}=EDGE
    ${client_id}    Generate Random String
    Set Suite Variable   ${CLIENT_ID}
    Log To Console   CLIENT_ID: ${CLIENT_ID}

    ${registrations_str}   Catenate   SEPARATOR=
    ...   curl -k -X POST "${apigw_uri}/auth/api/v1/apps/registrations"
    ...   ${SPACE}-H "Content-Type":"application/json"
    ...   ${SPACE}-d '{"clientId":"${CLIENT_ID}"}'
    ...   ${SPACE}-u "${username}:${password}"
    ${output}   csn.Execute   command=${registrations_str}   connection=${connection}
    ${output}   Strip String   ${output}
    ${dict}   Evaluate   json.loads('''${output}''')   json
    Set Suite Variable   ${CLIENT_SECRET}   ${dict['clientSecret']}
    Log To Console   CLIENT_SECRET: ${CLIENT_SECRET}
    [Return]   ${CLIENT_ID}   ${CLIENT_SECRET}

NOM API Delete Registrations
    [Arguments]   ${client_id}=${CLIENT_ID}
    ...   ${apigw_uri}=${APIGW_URI}   ${username}=${API_USERNAME}   ${password}=${API_PASSWORD}
    ...   ${connection}=EDGE
    ${delete_str}   Catenate   SEPARATOR=
    ...   curl -k -X DELETE "${apigw_uri}/auth/api/v1/apps/registrations/${client_id}"
    ...   ${SPACE}-u "${username}:${password}"
    ${logout}   csn.Execute   command=${delete_str}   connection=${connection}
    Should Contain   ${logout}   Deleted Successfully

NOM API Get Access Token
    [Arguments]   ${client_id}=${CLIENT_ID}   ${client_secret}=${CLIENT_SECRET}
    ...   ${user_mgmt_uri}=${USER_MGMT_URI}   ${username}=${API_USERNAME}   ${password}=${API_PASSWORD}
    ...   ${connection}=EDGE

    ${token_str}   Catenate   SEPARATOR=
    ...   curl -k -X POST "${user_mgmt_uri}/auth/realms/NEO/protocol/openid-connect/token"
    ...   ${SPACE}-d "grant_type=password"
    ...   ${SPACE}-d "client_id=${client_id}"
    ...   ${SPACE}-d "client_secret=${client_secret}"
    ...   ${SPACE}-d "username=${username}"
    ...   ${SPACE}-d "password=${password}"
    ${output}   csn.Execute   command=${token_str}   connection=${connection}
    ${dict}   Evaluate   json.loads('''${output}''')   json
    Set Suite Variable   ${ACCESS_TOKEN}   ${dict['access_token']}
    Log To Console   ACCESS_TOKEN: ${ACCESS_TOKEN}
    [Return]   ${ACCESS_TOKEN}

NOM API Software Build Import
    [Arguments]   ${file_name}=${PACKAGE_NAME}   ${sw_version}=${ACTIVE_SW_VERSION}   ${file_path}=${REMOTE_PACKAGE_PATH}
    ...   ${apigw_uri}=${APIGW_URI}   ${access_token}=${ACCESS_TOKEN}
    ...   ${connection}=EDGE
    ${sw_import_str}   Catenate   SEPARATOR=
    ...   curl -vk -X POST ${apigw_uri}/api/operations/v1/execute/sw-pkg-import
    ...   ${SPACE}-H "Content-Type: application/octet-stream"
    ...   ${SPACE}-H "Authorization: Bearer ${access_token}"
    ...   ${SPACE}-H "X-NOM-Filename: ${file_name}"
    ...   ${SPACE}-H "X-NOM-NeType: MRBTS"
    ...   ${SPACE}-H "X-NOM-NeSwVersion: ${sw_version}"
    ...   ${SPACE}-T ${file_path}
    ${logout}   csn.Execute   command=${sw_import_str}   connection=${connection}
    Should Not Contain   ${logout}   504 Gateway Time-out
    Should Not Contain   ${logout}   HTTP error before end of send, stop sending
