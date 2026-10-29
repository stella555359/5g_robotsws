*** Settings ***
Documentation
...   Resources for regression testing of features CB008501 and CB007213 CRT
...   author:   Marek Szlapa
...   contact:  marek.szlapa@nokia.com

Library    taf.rfrl.utilities.logger.custom_logger                          WITH NAME    custom_logger
Library    testsuite.Krakow.resources.openssl.Openssl                       WITH NAME    openssl
Library    testsuite.Krakow.resources.du_webem.du_webem_keywords.DuWebem    WITH NAME    du_webem


*** Variables ***
${SR_B_Params_dist_name}    MRBTS-76163/MNL-1/MNLENT-1/MPLANENW-1
${TLS_version}              tls1_2
${ASIR_webem_port}          3601
${ASIR_Ne3s_port}           6443
${M_plane_IP}               ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${LMP_IP}                   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${Cert_p12_filename}        NetAct_L0_CA.p12


*** Keywords ***
Change BTS parameter value
    [Arguments]    ${parameter_name}    ${parameter_value}
    custom_logger.Log info to console    Changing ${parameter_name} value to ${parameter_value}
    Perform parameter recommissioning    ${SR_B_Params_dist_name}  ${parameter_name}  update  ${parameter_value}

Scan available ciphers using NMAP
    [Arguments]    ${forbidden_cipher}=${None}    ${required_cipher}=${None}
    NMAP Cipher Scan    port=${ASIR_webem_port}    ip=${M_plane_IP}
    ...                 forbidden_cipher=${forbidden_cipher}    required_cipher=${required_cipher}
    NMAP Cipher Scan    port=${ASIR_Ne3s_port}     ip=${M_plane_IP}
    ...                 forbidden_cipher=${forbidden_cipher}    required_cipher=${required_cipher}

Scan available TLS versions using NMAP
    [Arguments]    ${forbidden_tls}=${None}    ${required_tls}=${None}
    NMAP TLS version scan    port=${ASIR_webem_port}    ip=${M_plane_IP}
    ...                      forbidden_tls=${forbidden_tls}    required_tls=${required_tls}
    NMAP TLS version scan    port=${ASIR_Ne3s_port}     ip=${M_plane_IP}
    ...                      forbidden_tls=${forbidden_tls}    required_tls=${required_tls}

Create OpenSSL test connections
    [Arguments]    ${moler_devices}    ${cipher}=
    ${additional_parameters}     Concatenate additional parameters    ${TLS_version}    ${cipher}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[0]}    ${additional_parameters}
    Create OpenSSL Connection    ${LMP_IP}        ${ASIR_webem_port}    ${moler_devices[1]}    ${additional_parameters}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_Ne3s_port}     ${moler_devices[2]}    ${additional_parameters}

Concatenate additional parameters
    [Arguments]    ${TLS_version}    ${cipher}
    ${additional_parameters}    Run Keyword If    '${cipher}' != ''
    ...                         Catenate        ${TLS_version}    -cipher ${cipher}
    ...                         ELSE
    ...                         Set Variable    ${TLS_version}
    [Return]    ${additional_parameters}

Create OpenSSL connections with disabled RSA KEx algorithms
    [Arguments]    ${moler_devices}    ${cipher}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[0]}    ${TLS_version}
    Create OpenSSL Connection    ${M_plane_IP}    ${Asir_Ne3s_port}     ${moler_devices[1]}    ${TLS_version}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[2]}
    ...                          ${TLS_version} -cipher ${cipher}

Create OpenSSL connections with disabled TLSv1_1 Downgrade
    [Arguments]    ${moler_devices}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[0]}    ${TLS_version}
    Create OpenSSL Connection    ${LMP_IP}        ${ASIR_webem_port}    ${moler_devices[1]}    ${TLS_version}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_Ne3s_port}     ${moler_devices[2]}    ${TLS_version}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[3]}    tls1_1

Create OpenSSL connections with disabled CBC Cipher
    [Arguments]    ${moler_devices}    ${cipher}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[0]}    ${TLS_version}
    Create OpenSSL Connection    ${LMP_IP}        ${ASIR_webem_port}    ${moler_devices[1]}    ${TLS_version}
    Create OpenSSL Connection    ${M_plane_IP}    ${Asir_Ne3s_port}     ${moler_devices[2]}    ${TLS_version}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[3]}
    ...                          ${TLS_version} -cipher ${cipher}

Create OpenSSL connections with enabled RSA KEx algorithms
    [Arguments]    ${moler_devices}    ${cipher1}    ${cipher2}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[0]}
    ...                          ${TLS_version} -cipher ${cipher1}
    Create OpenSSL Connection    ${M_plane_IP}    ${Asir_Ne3s_port}     ${moler_devices[1]}
    ...                          ${TLS_version} -cipher ${cipher1}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[2]}
    ...                          ${TLS_version} -cipher ${cipher2}
    Create OpenSSL Connection    ${M_plane_IP}    ${Asir_Ne3s_port}     ${moler_devices[3]}
    ...                          ${TLS_version} -cipher ${cipher2}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[4]}
    ...                          ${TLS_version} -cipher AES256-SHA

Create OpenSSL connections with enabled TLSv1_1 Downgrade
    [Arguments]    ${moler_devices}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[0]}    ${TLS_version}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_Ne3s_port}     ${moler_devices[1]}    ${TLS_version}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[2]}    tls1_1

Create OpenSSL connections with enabled CBC Cipher
    [Arguments]    ${moler_devices}    ${cipher1}    ${cipher2}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[0]}
    ...                          ${TLS_version} -cipher ${cipher1}
    Create OpenSSL Connection    ${M_plane_IP}    ${Asir_Ne3s_port}     ${moler_devices[1]}
    ...                          ${TLS_version} -cipher ${cipher1}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[2]}
    ...                          ${TLS_version} -cipher ${cipher2}
    Create OpenSSL Connection    ${M_plane_IP}    ${Asir_Ne3s_port}     ${moler_devices[3]}
    ...                          ${TLS_version} -cipher ${cipher2}
    Create OpenSSL Connection    ${M_plane_IP}    ${ASIR_webem_port}    ${moler_devices[4]}
    ...                          ${TLS_version} -cipher AES256-SHA

Verify Openssl Outputs with disabled RSA KEx algorithms
    [Arguments]    ${open_ssl_result}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[0]}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[1]}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[2]}    0000

Verify Openssl Outputs with disabled TLSv1_1 Downgrade
    [Arguments]    ${open_ssl_result}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[0]}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[1]}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[2]}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[3]}    0000

Verify Openssl Outputs with disabled CBC Cipher
    [Arguments]    ${open_ssl_result}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[0]}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[1]}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[2]}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[3]}    0000

Verify Openssl Outputs with enabled RSA KEx algorithms
    [Arguments]    ${open_ssl_result}    ${cipher1}    ${cipher2}
    Verify Openssl Output    ${open_ssl_result[0]}    ${cipher1}
    Verify Openssl Output    ${open_ssl_result[1]}    ${cipher1}
    Verify Openssl Output    ${open_ssl_result[2]}    ${cipher2}
    Verify Openssl Output    ${open_ssl_result[3]}    ${cipher2}
    Verify Openssl Output    ${open_ssl_result[4]}    0000

Verify Openssl Outputs with enabled TLSv1_1 Downgrade
    [Arguments]    ${open_ssl_result}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[0]}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[1]}    ${cipher}
    Verify Openssl Output    ${open_ssl_result[2]}    0000

Verify Openssl Outputs with enabled CBC Cipher
    [Arguments]    ${open_ssl_result}    ${cipher1}    ${cipher2}
    Verify Openssl Output    ${open_ssl_result[0]}    ${cipher1}
    Verify Openssl Output    ${open_ssl_result[1]}    ${cipher1}
    Verify Openssl Output    ${open_ssl_result[2]}    ${cipher2}
    Verify Openssl Output    ${open_ssl_result[3]}    ${cipher2}
    Verify Openssl Output    ${open_ssl_result[4]}    0000

Install NetAct Certificate on BTS
    openssl.Create certificate file     ${CURDIR}/NetAct_L0_CA_nodes.pem    ${LOG_PATH}/${Cert_p12_filename}
    du_webem.Install bts certificate    path=${LOG_PATH}/${Cert_p12_filename}    certificate_password=emssim
