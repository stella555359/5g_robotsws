*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   nom_oam_integration.robot



*** Variables ***



*** Keywords ***
_Generate NOM Integrate xml File With TLS
    [Arguments]   ${Plan_name}   ${mrbts_id}    ${oam_ip}  ${ne_id}   ${CACert}
    ${xml1}   set variable   <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
    ${xml2}   set variable   <cmData type="plan" scope="all" name="${Plan_name}">
    ${xml3}   set variable   <managedObject class="com.nokia.nms.integration:NE3SINT" distName="${mrbts_id}/NE3SINT-PREDEFINED"
    ${xml4}   set variable   ${SPACE}operation="create" version="1.0"><p name="host">${oam_ip}</p><p name="port">8443</p>
    ${xml5}   set variable   <p name="neType">MRBTS</p><p name="neId">${ne_id}</p><p name="username">wsuser</p><p name="password">A0zY~rP#8Mx@</p>
    ${xml6}   set variable   <p name="sbiNetConnectedTo">sbi-default-ipv4</p><p name="timezone">Europe/Helsinki</p>
    ${xml7}   set variable   <p name="tlsHostNameCheck">False</p><p name="tlsCA"><![CDATA[${CACert}]]></p></managedObject></cmData></raml>
    ${xmlfile}   set variable   ${xml1}${xml2}${xml3}${xml4}${xml5}${xml6}${xml7}
    [Return]   ${xmlfile}


_Generate NOM Integrate xml File Without TLS
    [Arguments]   ${Plan_name}   ${mrbts_id}    ${oam_ip}  ${ne_id}
    ${xml1}   set variable   <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
    ${xml2}   set variable   <cmData type="plan" scope="all" name="${Plan_name}">
    ${xml3}   set variable   <managedObject class="com.nokia.nms.integration:NE3SINT" distName="${mrbts_id}/NE3SINT-PREDEFINED"
    ${xml4}   set variable   ${SPACE}operation="create" version="1.0"><p name="host">${oam_ip}</p><p name="port">8080</p>
    ${xml5}   set variable   <p name="neType">MRBTS</p><p name="neId">${ne_id}</p><p name="username">wsuser</p><p name="password">A0zY~rP#8Mx@</p>
    ${xml6}   set variable   <p name="sbiNetConnectedTo">sbi-default-ipv4</p><p name="timezone">Europe/Helsinki</p>
    ${xml7}   set variable   </managedObject></cmData></raml>
    ${xmlfile}   set variable   ${xml1}${xml2}${xml3}${xml4}${xml5}${xml6}${xml7}
    [Return]   ${xmlfile}


_Get CNMS TimeStamp
    [Teardown]  run keyword and ignore error  Disconnect Interactive Connection   ${connection}
    ${connection}   SSH To NOM
    ${timestamp}    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"   alias=${connection}
    ${timestamp}    Strip String     ${timestamp}
    ${timestamp}    Split String     ${timestamp}
    log to console    ${timestamp}
    [Return]    ${timestamp}


Deintegrate VDU which integration with plan
    log to console   Deintegrate VDU which integration with plan
    ${deintegrate_file_local_path}    Generate Deintegrate Config File which integrate via plan   MRBTS  ${NE_ID}
    ${path_of_config_file}     ${deintegrate_config_file_name}
    ...   Upload Integration Config File To NOM which integrte with plan    MRBTS  ${NE_ID}     ${deintegrate_file_local_path}
    Deintegrate NE From NOM which integrte with plan     MRBTS  ${NE_ID}   ${path_of_config_file}     ${deintegrate_config_file_name}
