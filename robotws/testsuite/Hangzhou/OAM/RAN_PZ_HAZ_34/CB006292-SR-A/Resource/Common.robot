*** Settings ***
Library     BuiltIn
Library     OperatingSystem
Library     XML   True
Library     taf.nms.nom         WITH NAME   nom
Library     taf.transport.ssh   WITH NAME   csn
Library     Utils.py

Resource    Certifacate.robot
Resource    Download.robot
Resource    Integration.robot

Resource    ../../common/taf_coam.robot
Resource    ../../common/taf_nom.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

Variables   ALL_Variables.py
Variables   ../../libraries/global_vars.py
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot

*** Variables ***
${SET_NOM_NAME}   NEO8164
${REINTEGRATE_FLAG}   ${True}
${TLS_FLAG}   ${False}
${CERT_FLAG}   ${False}

*** Keywords ***
Common Setup
    [Arguments]   ${NOM_NAME}=${SET_NOM_NAME}
    Log To Console   ${EMPTY}
    Set Suite Variable   ${BTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MO_NAME}   MRBTS-${BTS_ID}
    Set Suite Variable   ${NRBTS_NAME}   MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    Set Suite Variable   ${DN}   PLMN-PLMN/${MO_NAME}
    Set Suite Variable   ${NOM_NAME}
    Get ALL Suite Variables
    COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM Check All Cells Onair
    ${status}   Run Keyword And Return Status   NOM Login
    run keyword if  not ${status}   Run Keywords
    ...   Run Keyword And Ignore Error   NOM Logout   AND
    ...   NOM Login
    Run Keyword If   ${REINTEGRATE_FLAG}   ReIntegrate GNB To NOM
    Log ALL Suite Variables

Common Teardown
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   NOM Logout

Get ALL Suite Variables
    Set Suite Variable   ${APIGW_URI}   ${ALL_NOM_Variables['${NOM_NAME}']['apigw_uri']}
    Set Suite Variable   ${USER_MGMT_URI}   ${ALL_NOM_Variables['${NOM_NAME}']['user_mgmt_uri']}
    Set Suite Variable   ${API_USERNAME}   ${ALL_NOM_Variables['${NOM_NAME}']['api_username']}
    Set Suite Variable   ${API_PASSWORD}   ${ALL_NOM_Variables['${NOM_NAME}']['api_password']}
    Set Suite Variable   ${EDGE_IP}   ${ALL_NOM_Variables['${NOM_NAME}']['edge_ip']}
    Set Suite Variable   ${EDGE_USER}   ${ALL_NOM_Variables['${NOM_NAME}']['edge_user']}
    Set Suite Variable   ${EDGE_KEY}   ${CURDIR}/../Certificate/${NOM_NAME}_RSA

Log ALL Suite Variables
    Log To Console   NOM_NAME: ${NOM_NAME}
    Log To Console   APIGW_URI: ${APIGW_URI}
    Log To Console   USER_MGMT_URI: ${USER_MGMT_URI}
    Log To Console   API_USERNAME: ${API_USERNAME}
    Log To Console   API_PASSWORD: ${API_PASSWORD}
    Log To Console   BTS_ID: ${BTS_ID}
    Log To Console   MO_NAME: ${MO_NAME}
    Log To Console   DN: ${DN}

ReIntegrate GNB To NOM
    ${oamtls}   Set Variable If   ${TLS_FLAG}   forced   off
    COAM Update Parameter   dist_name=${MO_NAME}/MNL-1/MNLENT-1/MPLANENW-1   parameter=oamTls   value=${oamtls}

    Run Keyword If   ${TLS_FLAG} and ${CERT_FLAG}   Run Keywords
    ...   Generate Certificate In Vault Machine   AND
    ...   Install Certificates In WEBEM
    Generate Integrate XML File
    NOM Import Plan   path_to_plan=${INTEGRATE_FILE}   name=${INTEGRATE_PLAN_NAME}   plan_type=INTEGRATION
    NOM Integrate NE   plan_name=${INTEGRATE_PLAN_NAME}

Disable Communication With NOM
    ${oamtls}   Set Variable If   ${TLS_FLAG}   off   forced
    COAM Update Parameter   dist_name=${MO_NAME}/MNL-1/MNLENT-1/MPLANENW-1   parameter=oamTls   value=${oamtls}
    Log To Console   Disable Communication With NOM

Enable Communication With NOM
    ${oamtls}   Set Variable If   ${TLS_FLAG}   forced   off
    COAM Update Parameter   dist_name=${MO_NAME}/MNL-1/MNLENT-1/MPLANENW-1   parameter=oamTls   value=${oamtls}
    Log To Console   Enable Communication With NOM

#NOM API Releated
SW Build Import To NOM In Remote Server
    [Arguments]   ${connection}=EDGE
    ${client_id}    Generate Random String
    Set Suite Variable   ${CLIENT_ID}

    ${registrations_str}   Catenate   SEPARATOR=
    ...   curl -k -X POST "${APIGW_URI}/authz/api/v1/apps/registrations"
    ...   ${SPACE}-H "Content-Type":"application/json"
    ...   ${SPACE}-d '{"clientId":"${CLIENT_ID}"}'
    ...   ${SPACE}-u "${API_USERNAME}:${API_PASSWORD}"
    ${output}   csn.Execute   command=${registrations_str}   connection=${connection}
    ${output}   Strip String   ${output}
    ${dict}   Evaluate   json.loads('''${output}''')   json
    Set Suite Variable   ${CLIENT_SECRET}   ${dict['clientSecret']}
    Log To Console   CLIENT_SECRET: ${CLIENT_SECRET}

    ${token_str}   Catenate   SEPARATOR=
    ...   curl -k -X POST "${USER_MGMT_URI}/auth/realms/NEO/protocol/openid-connect/token"
    ...   ${SPACE}-d "grant_type=password"
    ...   ${SPACE}-d "client_id=${CLIENT_ID}"
    ...   ${SPACE}-d "client_secret=${CLIENT_SECRET}"
    ...   ${SPACE}-d "username=${API_USERNAME}"
    ...   ${SPACE}-d "password=${API_PASSWORD}"
    ${output}   csn.Execute   command=${token_str}   connection=${connection}
    ${dict}   Evaluate   json.loads('''${output}''')   json
    Set Suite Variable   ${ACCESS_TOKEN}   ${dict['access_token']}
    Log To Console   ACCESS_TOKEN: ${ACCESS_TOKEN}

    ${sw_import_str}   Catenate   SEPARATOR=
    ...   curl -vk -X POST ${APIGW_URI}/api/operations/v1/execute/sw-pkg-import
    ...   ${SPACE}-H "Content-Type: application/octet-stream"
    ...   ${SPACE}-H "Authorization: Bearer ${ACCESS_TOKEN}"
    ...   ${SPACE}-H "X-NOM-Filename: ${PACKAGE_NAME}"
    ...   ${SPACE}-H "X-NOM-NeType: MRBTS"
    ...   ${SPACE}-H "X-NOM-NeSwVersion: ${ACTIVE_SW_VERSION}"
    ...   ${SPACE}-T ${REMOTE_PACKAGE_PATH}
    ${logout}   csn.Execute   command=${sw_import_str}   connection=${connection}
    Log To Console   ${logout}
    [Teardown]   Run Keyword And Ignore Error   Delete Client In Remote Server   client_id=${CLIENT_ID}   connection=${connection}

Delete Client In Remote Server
    [Arguments]   ${client_id}=${CLIENT_ID}   ${connection}=EDGE
    ${delete_str}   Catenate   SEPARATOR=
    ...   curl -k -X DELETE "${APIGW_URI}/authz/api/v1/apps/registrations/${CLIENT_ID}"
    ...   ${SPACE}-u "${API_USERNAME}:${API_PASSWORD}"
    ${logout}   csn.Execute   command=${delete_str}   connection=${connection}
    Should Contain   ${logout}   Deleted Successfully
