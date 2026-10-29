*** Settings ***
Documentation
...     description:    Keywords for test cases for the CB007822 feature. This feature is related to creation of certain keypairs
...                     at factory, ways of storing/importing, creating/removing operator keypairs and firmware upgrade of TPM
...                     along with software rollback in case of any errors.

Resource        ../../../common_resources/admin/admin.robot
Resource        ../../../common_resources/certificates/certificates.robot
Resource        ../../../common_resources/ip_traffic/ip_traffic.robot
Resource        ../../../common_resources/connections/connections.robot
Library     ../../../common_resources/tls/TLSHandshakeTests.py      WITH NAME   handshake

Library         SeleniumLibrary
Library         taf.sbts.oam.coam.admin      WITH NAME   coam_admin

*** Variables ***
${username}                 Nemuadmin
${password}                 nemuuser
${port}                     22
${P12_ECDSA_256}            ${CURDIR}/certificates/certEC256.txt
${P12_ECDSA_384}            ${CURDIR}/certificates/certEC384.txt
${P12_RSA_2048}             ${CURDIR}/certificates/certRSA2048.txt
${P12_RSA_4096}             ${CURDIR}/certificates/certRSA4096.txt

&{PARAMS1}                   remoteSyslogDSCP=0    remoteSyslogFormat=RFC5424   remoteSyslogServerIPaddress=10.42.54.11
...                         remoteSyslogServerPortNo=6514   remoteSyslogTransmitDuration=10080
...                         remoteSyslogTransportProtocol=TLS


*** Keywords ***
Successfully login to WebEM
    ${browser} =    successful_login_via_chrome_asir_webem     https://${LMP_IP}   ${username_web}    ${password_web}
    ${vm_pass}      Run    sudo cat /etc/ute/vncpasswd
    lss_server_user    ${browser}    ${LSS_username}    ${vm_pass}    ${vm_pass}
    lss_server_define    ${browser}    ${VM_IP}    ${port}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                        param_name=diagSnapDestination
    ...                        param_value=lss
    collect_remote_snap    ${browser}

Syslog Setup for TLS1.3
    [Arguments]                ${connection}
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        tls12Enabled
    ...                        true
    ...                        connection=${connection}
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        oamTls
    ...                        forced
    ...                        connection=${connection}
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        actEnableTLSv13
    ...                        true
    ...                        connection=${connection}
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        tls11Enabled
    ...                        false
    ...                        connection=${connection}

Change Local Symptoms Server Configuration
    [Arguments]    ${IP_address}  ${IP_port}  ${connection}
    ${dist_name}=  Set Variable   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ${params_list}=  local_symptoms_server_configuration  ${IP_address}  ${IP_port}
    coam_admin.perform_object_recommissioning        dist_name=${dist_name}
    ...                                              parameter=${params_list}
    ...                                              operation=update
    ...                                              skip_parameter_relation_errors=${FALSE}
    ...                                              should_activate=${True}
    ...                                              connection=${connection}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                        param_name=diagSnapDestination
    ...                        param_value=lss

Check File Permissions
    [Arguments]    ${connection}    ${file_path}    ${expected_permissions}
    ${output}=    ssh.execute    command=ls -la ${file_path}
    ...                          connection=${connection}
    Should Contain    ${output}    ${expected_permissions}

File Should Be Visible
    [Arguments]    ${connection}    ${file_path}
    ${output}=    ssh.execute    command=cat ${file_path}
    ...                          connection=${connection}
    Should Not Contain    ${output}    Permission denied

File Should Not Be Visible
    [Arguments]    ${connection}    ${file_path}
    ${output}=    ssh.execute    command=cat ${file_path}
    ...                          connection=${connection}
    Should Contain    ${output}    Permission denied
