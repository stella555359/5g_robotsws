*** Settings ***
Documentation    Resource file for TPS switch operation.
Library    ./TpsOperation.py  WITH NAME  TPS

*** Keywords ***
Connect to TPS switch
    [Documentation]   Keyword to connect with TPS switch.
    ...    It is necessary to specify the ip VM to which the switch is connected.
    ...
    ...    Examples:
    ...    | Connect to TPS switch | ${vm_ip_address} |
    [Arguments]    ${vm_ip_address}    ${vm_username}=ute    ${vm_password}=ute
    ...            ${switch_ip}=172.16.0.1    ${switch_username}=admin    ${switch_password}=Admin@1830    ${ssh_switch_username}=cli
    ${connection}    TPS.connect_to_switch      ${vm_ip_address}
    ...                                         switch_ip_address=${switch_ip}
    ...                                         vm_username=${vm_username}
    ...                                         vm_password=${vm_password}
    ...                                         ssh_switch_username=${ssh_switch_username}
    ...                                         switch_username=${switch_username}
    ...                                         switch_password=${switch_password}
    [Return]    ${connection}

Disconnect from TPS switch
    [Documentation]   Keyword to disconnect from TPS switch.
    ...
    ...    Examples:
    ...    | Disconnect from TPS switch | ${connection} |
    [Arguments]    ${connection}
    TPS.disconnect_from_switch    ${connection}

Execute command on TPS switch
    [Documentation]    Keyword to execute command on TPS Switch. Keyword return output.
    ...
    ...    Examples:
    ...    | Execute command on TPS switch | ${command}| ${connection} |
    [Arguments]    ${command}    ${connection}
    ${Output}    TPS.execute_command_on_switch    command=${command}    child=${connection}
    [Return]    ${Output}

Check Is Correct Hostname
    [Arguments]  ${hostname}  ${connection}
    ${output}=  Execute command on TPS switch   command=config general name
    ...                                         connection=${connection}
    Should Contain  ${output}  ${hostname}  msg=New hostname has not appeared in "config general name" command

Check Is Correct Session Timeout
    [Arguments]  ${session_timeout}  ${connection}
    ${output}=  Execute command on TPS switch   command=show admin user admin
    ...                                         connection=${connection}
    ${result}=  TPS.check_is_session_timeout_in_input  console_input=${output}  session_timeout=${session_timeout}
    Should Be True  ${result}  msg=New session timeout has not been set (Invalid session timeout format: ${session_timeout})

Set TPS Hostname
    [Documentation]    Keyword to set hostname of TPS Switch
    ...                Arguments:
    ...                ${hostname}      - Provide hostname
    ...                ${connection}    - Provide TPS connection object
    ...
    ...                 Example:
    ...                 Setup TPS Hostname  ${hostname}  ${connection}
    [Arguments]  ${hostname}  ${connection}
    ${result}=  Execute command on TPS switch   command=config general name ${hostname}
    ...                                         connection=${connection}
    Should Not Contain  ${result}  Error  msg=New hostname has not been set
    Check Is Correct Hostname  hostname=${hostname}
    ...                        connection=${connection}
    Log  New hostname has been set: ${hostname}   console=true

Set TPS Session Timeout
    [Documentation]    Keyword to set session timeout on TPS Switch
    ...                Arguments:
    ...                ${session_timeout}   - Provide time in minutes
    ...                ${connection}        - Provide TPS connection object
    ...
    ...                 Example:
    ...                 Setup TPS Session Timeout  ${session_timeout}  ${connection}
    [Arguments]  ${session_timeout}  ${connection}
    Execute command on TPS switch   command=config admin user edit admin timeout ${session_timeout}
    ...                             connection=${connection}
    Check Is Correct Session Timeout  session_timeout=${session_timeout}
    ...                               connection=${connection}
    Log  New session timeout has been set: ${session_timeout}min  console=true

Check If VPLS Is Configured On
    [Arguments]  ${card}  ${slot}  ${vpls_id}  ${connection}
    ${output}=  Execute command on TPS switch   command=sh card ${card} ${slot} service service-using
    ...                                         connection=${connection}
    ${status}=  TPS.check_vpls_in_input  console_input=${output}  vpls_id=${vpls_id}
    Should Be True  ${status}  msg=VPLS id: ${vpls_id} not found

Check If SAP Is Configured On
    [Arguments]  ${card}  ${slot}  ${vpls_id}  ${sap_port_number}  ${connection}
    Check If VPLS Is Configured On  card=${card}
    ...                             slot=${slot}
    ...                             vpls_id=${vpls_id}
    ...                             connection=${connection}
    ${output}=  Execute command on TPS switch   command=sh card ${card} ${slot} service id ${vpls_id} base
    ...                                         connection=${connection}
    ${status}=  TPS.check_sap_in_input  console_input=${output}  sap_port_number=${sap_port_number}
    Should Be True  ${status}  msg=SAP port number: ${sap_port_number} not found

Get VPLS Status
    [Arguments]  ${card}  ${slot}  ${vpls_id}  ${connection}  ${type}=Opr
    Check If VPLS Is Configured On  card=${card}
    ...                             slot=${slot}
    ...                             vpls_id=${vpls_id}
    ...                             connection=${connection}
    ${output}=  Execute command on TPS switch   command=sh card ${card} ${slot} service service-using
    ...                                         connection=${connection}
    ${status}=  TPS.parse_vpls_status  console_input=${output}  vpls_id=${vpls_id}  type=${type}
    [Return]  ${status}

Get SAP Status
    [Arguments]  ${card}  ${slot}  ${vpls_id}  ${sap_port_number}  ${connection}  ${type}=Opr
    Check If VPLS Is Configured On  card=${card}
    ...                             slot=${slot}
    ...                             vpls_id=${vpls_id}
    ...                             connection=${connection}
    ${output}=  Execute command on TPS switch   command=sh card ${card} ${slot} service id ${vpls_id} base
    ...                                         connection=${connection}
    ${status}=  TPS.parse_sap_status  console_input=${output}  sap_port_number=${sap_port_number}  type=${type}
    [Return]  ${status}

Get FDB MAC Addresses
    [Arguments]  ${card}  ${slot}  ${vpls_id}  ${connection}
    Check If VPLS Is Configured On  card=${card}
    ...                             slot=${slot}
    ...                             vpls_id=${vpls_id}
    ...                             connection=${connection}
    ${output}=  Execute command on TPS switch   command=sh card ${card} ${slot} service id ${vpls_id} fdb detail
    ...                                         connection=${connection}
    ${number_of_mac_adresses}=  TPS.parse_number_of_mac_adresses  console_input=${output}
    [Return]  ${number_of_mac_adresses}

Get Number Of Packets
    [Arguments]  ${card}  ${slot}  ${vpls_id}  ${sap_port_number}  ${connection}  ${counter_type}
    Check If VPLS Is Configured On  card=${card}
    ...                             slot=${slot}
    ...                             vpls_id=${vpls_id}
    ...                             connection=${connection}
    Check If SAP Is Configured On  card=${card}
    ...                            slot=${slot}
    ...                            vpls_id=${vpls_id}
    ...                            sap_port_number=${sap_port_number}
    ...                            connection=${connection}
    ${command}=  Set Variable  sh card ${card} ${slot} service id ${vpls_id} sap ${sap_port_number}:${vpls_id} pmon interval 1day bin 0
    ${output}=  Execute command on TPS switch   command=${command}
    ...                                         connection=${connection}
    Should Not Contain  ${output}  Error  msg=${output}
    ${counter_value}=  TPS.parse_sap_counter  console_input=${output}  counter_type=${counter_type}
    [Return]  ${counter_value}

Get All SAPs from VPLS
    [Arguments]  ${card}  ${slot}  ${vpls_id}  ${sap_type}  ${connection}
    Check If VPLS Is Configured On  card=${card}
    ...                             slot=${slot}
    ...                             vpls_id=${vpls_id}
    ...                             connection=${connection}
    ${output}=  Execute command on TPS switch   command=sh card ${card} ${slot} service id ${vpls_id} base
    ...                                         connection=${connection}
    ${sap_list}=  TPS.get_sap_list  counsole_input=${output}  sap_type=${sap_type}
    [Return]  ${sap_list}

Toggle VPLS
    [Arguments]    ${card}     ${slot}    ${vpls_id}    ${operation}     ${connection}
    Check If VPLS Is Configured On  card=${card}
    ...                             slot=${slot}
    ...                             vpls_id=${vpls_id}
    ...                             connection=${connection}
    Execute Command On TPS Switch
    ...           command=config card ${card} ${slot} service vpls ${vpls_id} ${operation}
    ...           connection=${connection}
    ${result}=    Get VPLS Status    card=${card}
    ...                slot=${slot}
    ...                vpls_id=${vpls_id}
    ...                connection=${connection}
    ${status}=    Set Variable If    '${operation}' == 'no shutdown'    Up    '${operation}' == 'shutdown'    Down
    Log    VPLS ${vpls_id} changed to ${status}    console=True

Toggle SAP
    [Arguments]    ${card}    ${slot}    ${vpls_id}    ${sap_port_number}    ${operation}    ${connection}
    Check If VPLS Is Configured On  card=${card}
    ...                             slot=${slot}
    ...                             vpls_id=${vpls_id}
    ...                             connection=${connection}
    Check If SAP Is Configured On  card=${card}
    ...                            slot=${slot}
    ...                            vpls_id=${vpls_id}
    ...                            sap_port_number=${sap_port_number}
    ...                            connection=${connection}
    ${result}=    Execute Command On TPS Switch
    ...           command=config card ${card} ${slot} service vpls ${vpls_id} sap ${sap_port_number}:${vpls_id} ${operation}
    ...           connection=${connection}
    ${result}=    Get SAP Status    card=${card}
    ...                             slot=${slot}
    ...                             vpls_id=${vpls_id}
    ...                             sap_port_number=${sap_port_number}
    ...                             connection=${connection}
    ${status}=    Set Variable If    '${operation}' == 'no shutdown'    Up    '${operation}' == 'shutdown'    Down
    Log    SAP ${sap_port_number}:${vpls_id} changed to ${status}    console=True

Change Status of RU via TPS
    [Documentation]   Keyword to set status of RU to "up" or "down" via TPS. TPS "Description" field must contain
    ...               number of Test Line (TL374, TL066 etc.) and RU type (AEQN, AZQN etc.)
    ...
    ...    Examples:
    ...    | Change Status of RU via TPS | TL374 | AEQN | down | 127.0.0.1 | 127.0.0.1 | admin | password |
    [Arguments]  ${test_line}  ${ru_type}  ${status}  ${vm_ip}  ${tps_ip}  ${tps_username}  ${tps_password}
    ${tps_connection}=  Connect to TPS Switch  vm_ip_address=${vm_ip}
    ...                                        switch_ip=${tps_ip}
    ...                                        switch_username=${tps_username}
    ...                                        switch_password=${tps_password}
    ${command_output}=  Execute Command on TPS Switch   show int t24ps2 *   ${tps_connection}
    ${ru_port}=  TPS.get_ru_port_for_test_line  ${command_output}  ${test_line}  ${ru_type}
    ${turn_on_command}=  Catenate  conf interface t24ps2 ${ru_port} state ${status}
    ${command_output}=  Execute Command on TPS Switch   ${turn_on_command}   ${tps_connection}
    Disconnect from TPS Switch  ${tps_connection}

Enable Specific RU on TPS
    [Documentation]   Keyword to set status of one RU on the testline to up and all others to down.
    ...               TPS "Description" field must contain number of Test Line (TL374, TL066 etc.) and RU type (AEQN, AZQN etc.)
    ...
    ...    Examples:
    ...    | Enable Specific RU on TPS | TL374 | AEQN | 127.0.0.1 | 127.0.0.1 | admin | password |
    [Arguments]  ${test_line}  ${ru_type}  ${vm_ip}  ${tps_ip}  ${tps_username}  ${tps_password}
    ${tps_connection}=  Connect to TPS Switch  vm_ip_address=${vm_ip}
    ...                                        switch_ip=${tps_ip}
    ...                                        switch_username=${tps_username}
    ...                                        switch_password=${tps_password}
    ${command_output}=  Execute Command on TPS Switch   show int t24ps2 *   ${tps_connection}
    ${ru_ports}=   TPS.get_all_ru_ports_for_test_line  ${command_output}  ${test_line}
    ${enable_ru_port}=  TPS.get_ru_port_for_test_line  ${command_output}  ${test_line}  ${ru_type}
    :FOR    ${port}    IN    @{ru_ports}
        ${state}=    set variable if    "${port}" == "${enable_ru_port}"    up    down
        ${command}=  Catenate  conf interface t24ps2 ${port} state ${state}
        log to console   setting the state of a port ${port} on TPS to ${state}
        ${command_output}=  Execute Command on TPS Switch   ${command}   ${tps_connection}
    END
    [Teardown]  Disconnect from TPS Switch    ${tps_connection}
