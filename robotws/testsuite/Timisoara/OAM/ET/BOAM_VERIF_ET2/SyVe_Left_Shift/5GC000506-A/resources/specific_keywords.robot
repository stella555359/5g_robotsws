*** Settings ***
Documentation
...    Author: anna.sobolewska@nokia.com
...    Maintainer: sylwia.swiatkiewicz@nokia.com
...    Description: Specific Keywords used in 5GC000506_A
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Library    Collections
Library    OperatingSystem
Library    XML  lxml=True
Library    String
Library     BuiltIn
Library     ute_syslog
Library    taf.sbts.oam.coam.admin
Library    taf.sbts.oam.coam.admin.admin   WITH NAME   admin_cli
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tshark  WITH NAME   tshark
Library       ../resources/server.py

Resource    ../../CommonKeywords/custom_commissionings.robot
Resource   ../../CommonKeywords/nrbts_states_verification/getters.robot
Resource   ../../resources/system.robot
Resource   ./tshark.robot

*** Variables ***
${cert_path}    /home/ute/robotws5g/testsuite/OAM/Wroclaw/COAM/5GC0056_A/resources/rsyslog.pem
#${Object_dist_name}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/TRBLCADM_CONF_M-1/TRBLCADM_R-1
${path}    /home/ute/tshark
${filename}    tshark.pcap

*** Keywords ***
clear syslogs on server
    Run  sudo rm -rf /var/log/btslog-udp.json

Assure TRBLCADM-1 Object exists
    [Documentation]  This object is required
    Run keyword and ignore error    Create TRBLCADM-1 Object

Create TRBLCADM-1 Object
    [Documentation]
    ...    to create TRBLCADM-1 object with required parameters

    [Arguments]
    ${dict1}=    create dictionary    parameterName=actCoreDumpFileCollection
    ...                                         operation=update
    ...                                         value=true
    ${dict2}=    create dictionary    parameterName=actInternalTrace
    ...                                         operation=update
    ...                                         value=true
    ${dict3}=    create dictionary    parameterName=actRemoteSyslogTransmission
    ...                                         operation=update
    ...                                         value=false
    ${dict4}=    create dictionary    parameterName=snapshotUploadDelayForFault6450
    ...                                         operation=update
    ...                                         value=0
    @{parameter_list}=    create list    ${dict1}    ${dict2}    ${dict3}    ${dict4}
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                         parameter=@{parameter_list}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}


Assert that Mplane is configured
    [Documentation]
    ...    check if Mplane is configured for IPv4 and IPv6
    [Arguments]
    ...    ${Object_dist_name}=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/MPLANENW_CONF_M-1
    ...    ${Parameter_name_ipv4}=mPlaneIpv4AddressDN
    ...    ${Parameter_name_ipv6}=mPlaneIpv6AddressDN
    ${mPlaneDNipv4}=
    ...         admin_cli.get_parameters
    ...         dist_name=${Object_dist_name}
    ...         pattern=${Parameter_name_ipv4}
    log         ${mPlaneDNipv4}

    Should Not Be Empty    ${mPlaneDNipv4}
    ${mPlaneDNipv6}=
    ...         admin_cli.get_parameters
    ...         dist_name=${Object_dist_name}
    ...         pattern=${Parameter_name_ipv6}
    log        ${mPlaneDNipv6}
    Should Not Be Empty    ${mPlaneDNipv6}

Perform CMP certificate activation

    [Documentation]
    ...    to perform CMP server certificates activation

    [Arguments]
    ${dict1}=    create dictionary    parameterName=caSubjectName
    ...                                         operation=update
    ...                                         value=C=PL, O=COAM, CN=5GC000506
    ${dict2}=    create dictionary    parameterName=eeSubjectName
    ...                                         operation=update
    ...                                         value=${Empty}
    ${dict3}=    create dictionary    parameterName=serverHost
    ...                                         operation=update
    ...                                         value=10.42.54.13
    ${dict4}=    create dictionary    parameterName=serverPath
    ...                                         operation=update
    ...                                         value=pkix/
    ${dict5}=    create dictionary    parameterName=serverPort
    ...                                         operation=update
    ...                                         value=8080
    @{parameter_list}=    create list    ${dict1}    ${dict2}    ${dict3}    ${dict4}    ${dict5}


    ${certif_presence_cmp}=    is_certificate_with_issuer_exists
    ...     issued_by=C=PL,O=COAM,CN=5GC000506
    ...     issued_to=O=Nokia Solutions and Networks,CN=L1183111786.nokiasolutionsandnetworks.com
    Return From Keyword If   '${certif_presence_cmp}'=='True'     ${None}

    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                         parameter=@{parameter_list}
    ...                                         operation=update
    ...                                         skip_parameter_relation_errors=True
    admin_cli.cmp_initialize_certificate   connection=${ADMIN_ALIAS}
    Restart admin connection



Restart admin connection
    ADMIN Teardown Admin
    ADMIN Setup Admin


Install additional certificates
    ${certif_presence_ca}=    is_certificate_with_issuer_exists
    ...     issued_by=C=PL,O=COAM,CN=5GC000506
    ...     issued_to=OU=Nokia,O=Nokia,ST=PL,C=PL
    Return From Keyword If   '${certif_presence_ca}'=='True'     ${None}
    Install additional CA cert
    Restart admin connection


Install additional CA cert
    admin_cli.install_certificate
    ...     cert_file=testsuite/OAM/Wroclaw/cOAM/5GC000506-A/resources/bts_cert_506.pem
    ...     cert_type=AdditionalCa
    ...     cert_format=PEM

Perform additional parameters activation for remote transmission
    ${IPv6_config_dict}=
    ...                admin_cli.get_parameters
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/TNLSVC_CONF_M-1/TNL_CONF_M-1/IPNO_CONF_M-1/IPRTV6_CONF_M-1
    ...                pattern=staticIpv6Routes

    ${list_param_to_change}=    Create Dictionary   destIpv6Addr=::
    ...                                             destinationIpv6PrefixLength=0
    ...                                             gatewayIpv6Addr=2a00:8a00:6000:607c::5501
    ...                                             preSrcIpv6Addr=::
    ...                                             preference=1

    @{list}=    create list    ${list_param_to_change}
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1
    ...                                            parameter=staticIpv6Routes
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=True

Get Current NP Path Left
    ${currentNP}        ADMIN Get Parameter
    ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1
    ...    parameter=currentNp
    ...    timeout=300
    ${NP_path}  Set variable  &{currentNP}[currentNp]
    [Return]  ${NP_path}


Get Current NP Path Right
    ${currentNP}        ADMIN Get Parameter
    ...    dist_name=/MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1
    ...    parameter=currentNp
    ...    timeout=300
    ${NP_path}  Set variable  &{currentNP}[currentNp]
    [Return]  ${NP_path}


Get Current NP Path
    ${NP_Path}=  Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...            Get Current NP Path Left
    ...   ELSE IF     '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...            Get Current NP Path Right
    [Return]  ${NP_Path}


Perform remoteSyslogIPaddress parameter activation
    [Arguments]    ${DSCPvalue}
    ...            ${format}
    ...            ${IP_remoteServer}
    ...            ${portNumber}
    ...            ${time}
    ...            ${protocol}
    ...            ${Object_WebEm_dist_name}
    ${NP_path}=  Get Current NP Path
    ${remoteSyslogConfig_dict}=
    ...                admin_cli.get_parameters
    ...                dist_name=${NP_path}/SCF-1/MRBTS_A-1/MNL_A-1/MNLENT_A-1/TRBLCADM_A-1
    ...                pattern=remoteSyslog


    ${list_param_to_change}=    Create Dictionary    remoteSyslogServerIPaddress    1.0.0.0
    Set To Dictionary    ${list_param_to_change}    remoteSyslogDSCP=${DSCPvalue}
    ...                                             remoteSyslogFormat=${format}
    ...                                             remoteSyslogServerIPaddress=${IPremoteServer}
    ...                                             remoteSyslogServerPortNo=${portNumber}
    ...                                             remoteSyslogTransmitDuration=${time}
    ...                                             remoteSyslogTransportProtocol=${protocol}
    @{list}=    create list    ${list_param_to_change}
    admin_cli.perform_parameter_recommissioning    dist_name=${Object_WebEm_dist_name}
    ...                                            parameter=remoteSyslogConfig
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=True

Assert that IP address for remote server is set
    [Documentation]
    ...    set parameter remoteSyslogServerIPaddress with remote server's IPv4 or IPv6 address
    [Arguments]    ${IP_remoteServer}
    ...    ${Parameter_name}=remoteSyslog
    ${NP_path}=  Get Current NP Path
    ${remote_IPaddress}=    admin_cli.get_parameters    dist_name=${NP_path}/SCF-1/MRBTS_A-1/MNL_A-1/MNLENT_A-1/TRBLCADM_A-1
    ...                                                 pattern=${Parameter_name}
    ${remote_IPaddress_dict}=    Get From Dictionary    ${remote_IPaddress['remoteSyslogConfig']}
    ...                                                 remoteSyslogServerIPaddress
    should be equal    ${remote_IPaddress_dict}    ${IP_remoteServer}


Enable remote syslog transmission
    [Documentation]
    ...    set parameter Activate remote syslog transmission to true
    ...    validate and activate it
    [Arguments]    ${Object_dist_name}
    ...            ${parameter_name}=actRemoteSyslogTransmission
    ${remoteStatus}=    admin_cli.perform_parameter_recommissioning    dist_name=${Object_dist_name}
    ...                                                                parameter=${parameter_name}
    ...                                                                operation=update
    ...                                                                value=true
    ...                                                                skip_parameter_relation_errors=True

Assert remote syslog status
    [Documentation]
    ...    check remoteSyslogTransmissionStatus
    [Arguments]
    ...    ${expected_status}
    ...    ${Object_dist_name}=MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1
    ${NP_path}=  Get Current NP Path
    ${remote_transmission_status}=  admin_cli.get_parameters    dist_name=MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                                         pattern=actRemoteSyslogTransmission
    ${remote_status_dict}=    Get From Dictionary   ${remote_transmission_status}    actRemoteSyslogTransmission
    ${remote_status}=    Convert To String    ${remote_status_dict}
    should be equal    ${remote_status}    ${expected_status}


Assert that remote syslog status is enabled
    wait until keyword succeeds  20s  5s  Assert remote syslog status  True

Assert that remote syslog status is disabled
    wait until keyword succeeds  60s  10s  Assert remote syslog status  False

Assert that syslog server is receiving logs
    [Documentation]
    ...    in manual tests logs are checked on remote server in Wireshark tool
    ...    start_stop_collect_Tshark_log
    [Arguments]  ${outputPath}   ${captureTimeInSeconds}=120
    capture pcap
    ...     outputPath=${outputPath}
    ...     captureTimeInSeconds=${captureTimeInSeconds}

    ${syslog_file}=          get file size         ${outputPath}
    Should Not Be Equal      ${syslog_file}    ${0}      Server is not receiving logs

Disable remote syslog transmission
    [Documentation]
    ...    set parameter Activate remote syslog transmission to false
    ...    validate and activate it

    ${remoteStatus}=     admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                                                 parameter=actRemoteSyslogTransmission
    ...                                                                 operation=update
    ...                                                                 value=false
    ...                                                                 skip_parameter_relation_errors=True



Resolve errors 5G BTS for Common build
    admin_cli.perform_parameter_recommissioning          dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                            parameter=actApts
    ...                                            value=false
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=true
    ...                                            should_activate=${True}
    ...                                            timeout=900


Get Testline IP From Config
    [return]    ${tl.test_pc.default_ssh_connection_details.addr}


Reset COAM BTS
    admin_cli.reset_site

Reset site and wait for Configured
    Reset COAM BTS
    Wait for Configured

BTS Syslog shall be redirected to remote server
    OperatingSystem.File Should Exist  &{rsyslog_config}[udp_file]
    OperatingSystem.File Should Not Be Empty  &{rsyslog_config}[udp_file]
    Run    sudo rm &{rsyslog_config}[udp_file]
