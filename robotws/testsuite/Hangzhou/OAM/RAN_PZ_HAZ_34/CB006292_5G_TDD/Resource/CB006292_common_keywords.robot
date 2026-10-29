*** Settings ***
Library     BuiltIn
Library     OperatingSystem
Library     XML   True
#Library     taf.nms.nom         WITH NAME   nom
Library      taf.transport.ssh   WITH NAME   csn
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/siso_resource.robot
#Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
#Resource     taf/rfrl/common_resources/robot/connection_alias_store.robot

#Resource    Certifacate.robot
#Resource    Integration.robot

Resource    ../../common/taf_coam.robot
Resource    ../../common/taf_nom.robot

Variables   ALL_Variables.py
Variables   ../../libraries/global_vars.py

*** Variables ***
${SET_NOM_NAME}   NOM08
${REINTEGRATE_FLAG}   ${False}
${TLS_FLAG}    ${False}
# ${CERT_FLAG}   ${True}
${vault_ip}   10.93.130.149
${vault_username}   root
${vault_password}   Salasana1!
${cert_password}   123456


${integrate_content}   SEPARATOR=
...   <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
...       <cmData type="plan" scope="all" name="NE-xxx-Integration-TLS">
...           <header><log dateTime="2021-10-28T05:52:40Z" action="export"></log></header>
...           <managedObject distName="MRBTS-xxx/MRBTSINT-AUTO" class="com.nokia.nms.integration:MRBTSINT" operation="create" version="1.0">
...               <p name="sbiNetConnectedTo">sbi-default-ipv4</p>
...               <p name="tlsHostNameCheck">false</p>
...               <p name="username">wsuser</p>
...               <p name="password">A0zY~rP#8Mx@</p>
...               <p name="host">xx.xx.xx.xx</p>
...               <p name="tlsCA"></p>
...           </managedObject>
...       </cmData>
...   </raml>


${deintegrate_content}   SEPARATOR=
...    <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
...        <cmData type="plan" scope="all" name="NE-xxx-Deintegration">
...            <managedObject distName="MRBTS-xx/MRBTSINT-AUTO" class="com.nokia.nms.integration:MRBTSINT" operation="delete" version="1.0" />
...        </cmData>
...    </raml>




*** Keywords ***
Common Teardown
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   NOM Logout

Get ALL Suite Variables
    Set Suite Variable   ${APIGW_URI}   ${ALL_NOM_Variables['${NOM_NAME}']['apigw_uri']}
    Set Suite Variable   ${USER_MGMT_URI}   ${ALL_NOM_Variables['${NOM_NAME}']['user_mgmt_uri']}
    Set Suite Variable   ${API_USERNAME}   ${ALL_NOM_Variables['${NOM_NAME}']['api_username']}
    Set Suite Variable   ${API_PASSWORD}   ${ALL_NOM_Variables['${NOM_NAME}']['api_password']}

ReIntegrate GNB To NOM
    Run Keyword If   ${TLS_FLAG}   Run Keywords
    ...   Generate Certificate In Vault Machine   AND
    ...   Install Certificates In WEBEM
    Generate Integrate XML File
    NOM Import Plan   path_to_plan=${INTEGRATE_FILE}   name=${INTEGRATE_PLAN_NAME}   plan_type=INTEGRATION
    NOM Integrate NE   plan_name=${INTEGRATE_PLAN_NAME}

Generate Integrate XML File
    ${tls_status}   Set Variable If   ${TLS_FLAG}   TLS   NoTLS
    ${integrate_file}   Set Variable   ${OUTPUT_PATH}/NE-${BTS_ID}-Integration-${tls_status}.xml

    OperatingSystem.Create File   ${integrate_file}   ${integrate_content}
    ${xml}   XML.Parse XML   ${integrate_file}
    XML.Set Element Attribute   ${xml}   name   NE-${BTS_ID}-Integration-${tls_status}   xpath=cmData
    XML.Set Element Attribute   ${xml}   distName   MRBTS-${BTS_ID}/MRBTSINT-AUTO   xpath=cmData/managedObject
    XML.Set Element Text   ${xml}   ${WEBUI_ADDR}   xpath=cmData/managedObject/p[@name="host"]
    Run Keyword If   ${TLS_FLAG}   Set TLS CA Content   xml=${xml}
    ...   ELSE   XML.Remove Element   ${xml}   xpath=cmData/managedObject/p[@name="tlsCA"]

    XML.Save Xml   ${xml}   ${integrate_file}
    Set Suite Variable   ${INTEGRATE_PLAN_NAME}   NE-${BTS_ID}-Integration-${tls_status}
    Set Suite Variable   ${INTEGRATE_FILE}

Set TLS CA Content
    [Arguments]   ${xml}
    ${tlsCA}   Get File   ${CERT_CHAIN_ISSUING_CA_FILE}
    XML.Set Element Text   ${xml}   ${tlsCA}   xpath=cmData/managedObject/p[@name="tlsCA"]

Generate Deintegrate XML File
    ${tls_status}   Set Variable If   ${TLS_FLAG}   TLS   NoTLS
    ${deintegrate_file}   Set Variable   ${OUTPUT_DIR}/NE-${BTS_ID}-Deintegration-${tls_status}.xml
    OperatingSystem.Create File   ${deintegrate_file}   ${deintegrate_content}
    ${xml}   XML.Parse XML   ${deintegrate_file}
    XML.Set Element Attribute   ${xml}   name   NE-${BTS_ID}-Deintegration-${tls_status}   xpath=cmData
    XML.Set Element Attribute   ${xml}   distName   MRBTS-${BTS_ID}/MRBTSINT-AUTO   xpath=cmData/managedObject
    XML.Save Xml   ${xml}   ${deintegrate_file}
    Set Suite Variable   ${DEINTEGRATE_PLAN_NAME}   NE-${BTS_ID}-Deintegration-${tls_status}
    Set Suite Variable   ${DEINTEGRATE_FILE}

Generate Certificate In Vault Machine
    csn.Connect To   hostname=${vault_ip}   username=${vault_username}   password=${vault_password}   alias=VaultMachine
    csn.Execute
    ...   command=cd /root/SYVE_VAULT; vault write pki/issue/ne-syve common_name="${MO_NAME}" ip_sans="${WEBUI_ADDR}" > ne_${BTS_ID}_raw_cert_chain
    ...   connection=VaultMachine
    csn.Send Command   command=cd /root/SYVE_VAULT; ./convert_to_p12.sh ne_${BTS_ID}_raw_cert_chain   connection=VaultMachine
    Sleep   3s
    csn.Write Input   data=${cert_password}\n   connection=VaultMachine
    Sleep   3s
    csn.Write Input   data=${cert_password}\n   connection=VaultMachine
    Sleep   3s
    csn.Download File
    ...   remote_path=/root/SYVE_VAULT/ne_${BTS_ID}_raw_cert_chain_issuing_ca.txt
    ...   local_path=${OUTPUT_DIR}/ne_${BTS_ID}_raw_cert_chain_issuing_ca.txt
    ...   connection=VaultMachine
    csn.Download File
    ...   remote_path=/root/SYVE_VAULT/ne_${BTS_ID}_raw_cert_chain.p12
    ...   local_path=${OUTPUT_DIR}/ne_${BTS_ID}_raw_cert_chain.p12
    ...   connection=VaultMachine
    Set Suite Variable   ${CERT_CHAIN_FILE}   ${OUTPUT_DIR}/ne_${BTS_ID}_raw_cert_chain.p12
    Set Suite Variable   ${CERT_CHAIN_ISSUING_CA_FILE}   ${OUTPUT_DIR}/ne_${BTS_ID}_raw_cert_chain_issuing_ca.txt
    Set Suite Variable   ${AdditionalCA_FILE}   ${CURDIR}/../Certificate/${NOM_NAME}.pem
    OperatingSystem.File Should Not Be Empty   path=${CERT_CHAIN_FILE}
    OperatingSystem.File Should Not Be Empty   path=${CERT_CHAIN_ISSUING_CA_FILE}
    OperatingSystem.File Should Not Be Empty   path=${AdditionalCA_FILE}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=VaultMachine

Install Certificates In WEBEM
    COAM Install Certificate   cert_file=${CERT_CHAIN_FILE}
    Run Keyword And Ignore Error   COAM Logout
    Sleep   10s
    Wait Until Keyword Succeeds   30s   10s   COAM Login
    COAM Install Certificate   cert_file=${AdditionalCA_FILE}
    Run Keyword And Ignore Error   COAM Logout
    Sleep   10s
    Wait Until Keyword Succeeds   30s   10s   COAM Login

Log ALL Suite Variables
    Log To Console   NOM_NAME: ${NOM_NAME}
    Log To Console   APIGW_URI: ${APIGW_URI}
    Log To Console   USER_MGMT_URI: ${USER_MGMT_URI}
    Log To Console   API_USERNAME: ${API_USERNAME}
    Log To Console   API_PASSWORD: ${API_PASSWORD}
    Log To Console   BTS_ID: ${BTS_ID}
    Log To Console   MO_NAME: ${MO_NAME}
    Log To Console   DN: ${DN}

Get Unique ID
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}   ${precise}=HIGH
    [Documentation]   Get Unique ID
    ...    | Input Parameters | Man. | Description |
    ...    | prefix       | no | prefix, default is ${EMTPY} |
    ...    | suffix       | no | suffix, default is ${EMTPY} |
    ...    | precise      | no | precise, HIGH or LOW, default is HIGH |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...  | ${tmp_id} | Get Unique ID |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=LOW |
    ${precise}  Set Variable  ${precise.upper()}
    ${rtn}  Run Keyword If  "${precise}"=="HIGH"  _Get Unique ID High Precise  prefix=${prefix}   suffix=${suffix}
    ...   ELSE   _Get Unique ID LOW Precise   prefix=${prefix}   suffix=${suffix}
    [Return]    ${rtn}

_Get Unique ID High Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(uuid.uuid4())    modules=uuid
    ${unique_id}    String.Replace String    ${unique_id}    -    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}

_Get Unique ID LOW Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(time.time())    modules=time
    ${unique_id}    String.Replace String    ${unique_id}    .    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}
