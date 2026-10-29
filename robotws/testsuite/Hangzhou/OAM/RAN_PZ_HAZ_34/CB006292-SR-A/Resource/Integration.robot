*** Settings ***
Resource   Common.robot

*** Variables ***
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
Generate Integrate XML File
    ${tls_status}   Set Variable If   ${TLS_FLAG}   TLS   NoTLS
    ${integrate_file}   Set Variable   ${OUTPUT_DIR}/NE-${BTS_ID}-Integration-${tls_status}.xml

    OperatingSystem.Create File   ${integrate_file}   ${integrate_content}
    ${xml}   XML.Parse XML   ${integrate_file}
    XML.Set Element Attribute   ${xml}   name   NE-${BTS_ID}-Integration-${tls_status}   xpath=cmData
    XML.Set Element Attribute   ${xml}   distName   MRBTS-${BTS_ID}/MRBTSINT-AUTO   xpath=cmData/managedObject
    XML.Set Element Text   ${xml}   ${WEBUI_ADDR}   xpath=cmData/managedObject/p[@name="host"]
    Run Keyword If   ${TLS_FLAG}   Set TLS CA Content   xml=${xml}
    ...   ELSE   Run Keywords
    ...   XML.Remove Element   ${xml}   xpath=cmData/managedObject/p[@name="tlsCA"]   AND
    ...   XML.Remove Element   ${xml}   xpath=cmData/managedObject/p[@name="tlsHostNameCheck"]

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
