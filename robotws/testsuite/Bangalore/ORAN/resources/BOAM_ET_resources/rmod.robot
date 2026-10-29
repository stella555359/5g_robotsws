*** Settings ***
Documentation    Author: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Maintainer: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Description: These keywords handles actions performed on radio modules
...              FT in charge: name + mailing list
...              Confluence link:
...              References: (documentation link(e.g. doors or sphinx))
...              QualityCenter: (test set url to QC)
...              Sample execution:

Library             SSHLibrary
Library             Telnet


*** Variables ***
${RADIO_ENB_TRANSPORT_IP_ADDRESS}=    192.168.255.129
${RADIO_ENB_SSH_LOGIN}=               toor4nsn
${RADIO_ENB_SSH_PASSWORD}=            oZPS0POrRieRtu
${RADIO_ENB_SSH_ALIAS}=               radio_enb_ssh
${RADIO_ENB_SSH_PROMPT}=              :~ >
${RADIO_TELNET_PORT}=                 2323
${RADIO_TELNET_PROMPT}=               $
${RADIO_TELNET_PROMPT_GAIA}=          rtose@gaia>
${RADIO_TELNET_ALU_USERNAME}=         asb
${RADIO_TELNET_ALU_PASSWORD}=         asb#1234
${RADIO_LOGS_DIRECTORY}=              /tmp/RMOD/

*** Keywords ***
RMOD Send Fault To RMOD
    [Arguments]    ${radio_ip_address}
    ...            ${fault_nr}
    ...            ${source_number}
    ...            ${activation_cancelation}
    Telnet.Open Connection    host=${radio_ip_address}  port=${RADIO_TELNET_PORT}  prompt=${RADIO_TELNET_PROMPT}
    Telnet.Execute Command    sendFault ${fault_nr} ${source_number} 0 ${activation_cancelation} 0 0
    Sleep              5s
    Telnet.Close All Connections

RMOD Send Fault To RMOD On AirScale
    [Arguments]    ${radio_ip_address}
    ...            ${fault_nr}
    ...            ${source_number}
    ...            ${activation_cancelation}
    SSHLibrary.Open Connection    host=${RADIO_ENB_TRANSPORT_IP_ADDRESS}
    ...                           port=22
    ...                           timeout=60
    ...                           alias=ssh_enb
    ...                           prompt=${RADIO_ENB_SSH_PROMPT}
    SSHLibrary.Login    username=${RADIO_ENB_SSH_LOGIN}
    ...                 password=${RADIO_ENB_SSH_PASSWORD}
    ...                 delay=1s
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    Run Keyword If    ${BTS_Side}==1    SSHLibrary.Write    lxc-attach 0x1018
    ...               ELSE              SSHLibrary.Write    lxc-attach 0x2018
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    telnet ${radio_ip_address} ${RADIO_TELNET_PORT}
    SSHLibrary.Read Until    ${RADIO_TELNET_PROMPT}
    SSHLibrary.Write    sendFault ${fault_nr} ${source_number} 0 ${activation_cancelation} 0 0
    SYSTEM Close SSH Connection To Enb

RMOD Send Fault To RMOD On FSMF
    [Arguments]    ${radio_ip_address}
    ...            ${command}
    SYSTEM Telnet Open Connection
    ...    host=${radio_ip_address}
    ...    port=${RADIO_TELNET_PORT}
    ...    prompt=${RADIO_TELNET_PROMPT}
    ...    alias=rmod
    Telnet.Switch Connection    index_or_alias=rmod
    Telnet.Read Until Prompt
    Telnet.Write    ${command}
    SSHLibrary.Read Until    ${RADIO_TELNET_PROMPT}
    SYSTEM Telnet Close Connection

RMOD Raise Fault On RMOD
    [Arguments]    ${radio_ip_address}
    ...            ${fault_nr}
    ...            ${source_number}
    ...            ${activation_cancelation}=0
    RMOD Send Fault To RMOD    radio_ip_address=${radio_ip_address}
    ...                        fault_nr=${fault_nr}
    ...                        source_number=${source_number}
    ...                        activation_cancelation=${activation_cancelation}

RMOD Clear Fault On RMOD
    [Arguments]    ${radio_ip_address}
    ...            ${fault_nr}
    ...            ${source_number}
    ...            ${activation_cancelation}=1
    RMOD Send Fault To RMOD    radio_ip_address=${radio_ip_address}
    ...                   fault_nr=${fault_nr}
    ...                   source_number=${source_number}
    ...                   activation_cancelation=${activation_cancelation}

RMOD Raise Fault On All RMODs
    [Arguments]    ${radios_ip_addresses_list}
    ...            ${fault_nr}
    ...            ${source_number}
    :FOR    ${out_index}    IN    ${radios_ip_addresses_list}
    \    RMOD Raise Fault On RMOD    radio_ip_address=${out_index}
         ...                         fault_nr=${fault_nr}
         ...                         source_number=${source_number}

RMOD Clear Fault On All RMODs
    [Arguments]    ${radios_ip_addresses_list}
    ...            ${fault_nr}
    ...            ${source_number}
    :FOR    ${out_index}    IN    ${radios_ip_addresses_list}
    \    RMOD Clear Fault On RMOD    radio_ip_address=${out_index}
         ...                         fault_nr=${fault_nr}
         ...                         source_number=${source_number}

RMOD Open FSM SSH Tunnel
    [Arguments]    ${local_ip_address}=${RADIO_ENB_TRANSPORT_IP_ADDRESS}    ${alias}=${RADIO_ENB_SSH_ALIAS}    ${enb_prompt}=${RADIO_ENB_SSH_PROMPT}
    SSHLibrary.Open Connection    ${local_ip_address}    alias=${alias}    prompt=${enb_prompt}
    SSHLibrary.Login              ${RADIO_ENB_SSH_LOGIN}    ${RADIO_ENB_SSH_PASSWORD}

RMOD NOKIA Telnet Via FSM SSH Tunnel
    [Arguments]    ${radio_ip_address}    ${radio_telnet_port}=${RADIO_TELNET_PORT}    ${alias}=${RADIO_ENB_SSH_ALIAS}
    SSHLibrary.Switch Connection           ${alias}
    SSHLibrary.Write                       telnet ${radio_ip_address}:${radio_telnet_port}
    ${out_telnet_login}=     SSHLibrary.Read Until Regexp    (\\${RADIO_TELNET_PROMPT}|${RADIO_TELNET_PROMPT_GAIA})$
    ${out_telnet_prompt}=    Should Match Regexp    ${out_telnet_login}    \\$${RADIO_TELNET_PROMPT}|${RADIO_TELNET_PROMPT_GAIA}$
    SSHLibrary.Set Client Configuration    prompt=${out_telnet_prompt}

RMOD ALU Telnet Via FSM SSH Tunnel
    [Arguments]    ${radio_ip_address}     ${alias}=${RADIO_ENB_SSH_ALIAS}
    SSHLibrary.Switch Connection           ${alias}
    SSHLibrary.Write                       telnet ${radio_ip_address}
    SSHLibrary.Read Until                  ZYNQ-RRH login:
    SSHLibrary.Write                       ${RADIO_TELNET_ALU_USERNAME}
    SSHLibrary.Read Until                  Password:
    SSHLibrary.Write                       ${RADIO_TELNET_ALU_PASSWORD}

RMOD NOKIA Create And Get Logs File
    [Arguments]    ${radio_ip_address}    ${logs_dir_path}=${RADIO_LOGS_DIRECTORY}
    RMOD Open FSM SSH Tunnel
    RMOD NOKIA Telnet Via FSM SSH Tunnel    ${radio_ip_address}
    SSHLibrary.Write    log -c full -z /ram/${radio_ip_address}_rflogs.zip
    Wait Until Keyword Succeeds    120    10    SSHLibrary.Read Until    AaSysComUserDeregister succeed!
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    exit
    SSHLibrary.Write    echo "exit done"
    SSHLibrary.Execute Command    ftpget ${radio_ip_address} /ram/${radio_ip_address}_rflogs.zip ${radio_ip_address}_rflogs.zip
    SSHLibrary.Get File           /ram/${radio_ip_address}_rflogs.zip  ${logs_dir_path}
    [Teardown]    SSHLibrary.Close Connection

RMOD ALU Create And Get Logs File
    [Arguments]    ${radio_ip_address}     ${logs_dir_path}=${RADIO_LOGS_DIRECTORY}
    RMOD Open FSM SSH Tunnel
    SSHLibrary.Write    lxc-attach -n 0x2018
    RMOD ALU Telnet Via FSM SSH Tunnel    ${radio_ip_address}
    SSHLibrary.Read Until    RFH1-1>
    SSHLibrary.Write    cat /tmp/tmpLog_
    Wait Until Keyword Succeeds    180    60x    SSHLibrary.Read Until    RFH1-1>    loglevel=TRACE
    SSHLibrary.Write    exit
    SSHLibrary.Write    echo "exit done"
    #TO DO: Get Logs from ALU RMOD through ABIA module
    [Teardown]    SSHLibrary.Close Connection

RADIO Send Fault Via Telnet On NOKIA Rmod
    [Arguments]    ${radio_ip_address}    ${telnet_port}=${RADIO_TELNET_PORT}   ${fault_id}=1163
    RMOD Open FSM SSH Tunnel
    RMOD NOKIA Telnet Via FSM SSH Tunnel    ${radio_ip_address}    ${telnet_port}
    ${out}=    SSHLibrary.Write    sendFault ${fault_id} 0 0 0 0 0
    Sleep    2s
    ${out}=    SSHLibrary.Read Until Prompt
    ${out}=    SSHLibrary.Write    exit
    ${out}=    SSHLibrary.Write    echo "exit done"
    [Teardown]    SSHLibrary.Close Connection

RADIO Clear Fault Via Telnet On NOKIA Rmod
    [Arguments]    ${radio_ip_address}    ${telnet_port}=${RADIO_TELNET_PORT}   ${fault_id}=1163
    RMOD Open FSM SSH Tunnel
    RMOD NOKIA Telnet Via FSM SSH Tunnel    ${radio_ip_address}    ${telnet_port}
    : FOR    ${out_index}    IN RANGE    3
    \    ${out}=    SSHLibrary.Write    sendFault ${fault_id} 0 0 1 0 0
    \    Sleep    2s
    ${out}=    SSHLibrary.Read Until Prompt
    ${out}=    SSHLibrary.Write    exit
    ${out}=    SSHLibrary.Write    echo "exit done"
    [Teardown]    SSHLibrary.Close Connection
