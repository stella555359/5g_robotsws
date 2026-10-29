*** Settings ***
Documentation    Description:      Keywords to perform varius operations and configurations with Syslog.
...              Author:           julia.wijas@nokia.com
...              Modification:     17.07.2025 - julia.wijas@nokia.com

Library     taf.transport.ssh       WITH NAME    ssh
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../cloud_common_resources/parameters/parameters.robot
Library     Collections

*** Variables ***

${SYSLOG_LOGIN}             kali
${SYSLOG_PASS}              kali
${SYSLOG_IP}=               10.42.63.247

*** Keywords ***
Syslog Configuration
    [Documentation]    Keyword will create structure and fill needed parameters
    [Arguments]    ${syslog_DSCP}    ${syslog_format}    ${syslog_server_host}    ${syslog_port}
    ...            ${syslog_transmision_duration}  ${syslog_protocol}    ${hw_type}
    Log    Creating remoteSyslogConfig structure, and addiing parameters    console=true
    ${MRBTS}=    Set Variable If    "${hw_type}"=="vDU"    ${MRBTS}   ${MRBTS_CU}
    ${values_dict}=      create dictionary
    set to dictionary    ${values_dict}     remoteSyslogDSCP                ${syslog_DSCP}
    ...                                     remoteSyslogFormat              ${syslog_format}
    ...                                     remoteSyslogServerHost          ${syslog_server_host}
    ...                                     remoteSyslogServerPortNo        ${syslog_port}
    ...                                     remoteSyslogTransmitDuration    ${syslog_transmision_duration}
    ...                                     remoteSyslogTransportProtocol   ${syslog_protocol}
    ${values_list}       create list        ${values_dict}
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                             param_name=remoteSyslogConfig
    ...                             operation=update
    ...                             hw_type=${hw_type}
    ...                             param_value=${values_list}
    Log    Remote syslog is configured     console=true

Collect PCAP from syslog server
    [Arguments]     ${filename}=tcpdump.pcap
    SSHLibrary.Open Connection          host=${SYSLOG_IP}
    SSHLibrary.Login                    username=${SYSLOG_LOGIN}      password=${SYSLOG_PASS}
    ${command}=        Catenate    sudo -S tcpdump -i any -w /home/kali/pcaps/${filename} &
    SSHLIbrary.Start Command        ${command}
    Sleep    20s
    ${pid}   SSHLibrary. Execute Command       pgrep tcpdump
    [Return]    ${pid}
    [Teardown]        SSHLibrary.Close Connection

Stop and colledt PCAP from syslog server
    [Arguments]    ${pid}    ${filename}=tcpdump.pcap
    SSHLibrary.Open Connection          host=${SYSLOG_IP}
    SSHLibrary.Login                    username=${SYSLOG_LOGIN}      password=${SYSLOG_PASS}
    ${command}=        Catenate  sudo kill -SIGINT ${pid}
    SSHLIbrary.Execute Command        ${command}
    Log  Pcap is collected               console=true
    ${output}     Run keyword and return status                             SSHLibrary.Read Until    expected=password
    IF    ${output}
        SSHLIbrary.Write      ${SYSLOG_PASS}
    END
    ${output}                          SSHLibrary.Read
    Log  Start download pcap from syslog to VM               console=true
    ${out}=    RUN  sshpass -p '${SYSLOG_PASS}' scp ${SYSLOG_LOGIN}@${SYSLOG_IP}:/home/kali/pcaps/${filename} /home/ute/${filename}
    Log  Pcap is downoladed              console=true
    [Teardown]        SSHLibrary.Close Connection
