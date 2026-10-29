*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for different ciphers with graylog server and DCAP server"
...     [Date]      "02-11-2022"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify both RSA & ECDSA operator certificate-based auth with BTS as Client-server for TLS"
...     [Funtion_Hash_Tags] "RSA & ECDSA operator certificate-based authentication"
...     [Feature_ID]            "CB008254"
...     [Requirement ID]    "OM_GEN_SFS_Netsec_3197,OM_GEN_SFS_NetSec.3190"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "3707"
...     [Config]    "This testcase requires Trace expert configurations from NRBTS/NRCTRLTS/NRMTRACECU  MOC"
...     [scf_file]  "scf to be updated"

*** Keywords ***
Get Pcap Details for TLS1_3 for trex
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_version_trex
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_1_3_cipher_suites_trex
    ...      filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_application_data_trex
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap Details for TLS1_2 for ecdsa in trex
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_version_1_2_trex
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_1_2_cipher_suites_trex
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls12_application_data_trex
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls12_cert_ecdsa
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap Details for TLS1_2 for rsa in trex
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_version_1_2_trex
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_1_2_cipher_suites_trex
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls12_application_data_trex
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls12_cert_rsa
    ...     filter_file_name=${traffic_filter_file_name}


Get Pcap Details for TLS1_3 for dcap
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_version
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_1_3_cipher_suites
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_application_data
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap Details for TLS1_2 for dcap
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_version_1_2
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_1_2_cipher_suites
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls12_application_data
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap Details for TLS1_2 for ECDSA for dcap
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls12_certificate_ecdsa_tls12
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap Details for TLS1_3 for graylog
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_version_graylog
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_1_3_cipher_suites_graylog
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls13_application_data_graylog
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap Details for TLS1_2 for graylog
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_version_1_2_graylog
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_1_2_cipher_suites_graylog
    ...     filter_file_name=${traffic_filter_file_name}
   Analyse Pcap        pcap_filename=${file}        analysis=verify_tls12_application_data_graylog
    ...     filter_file_name=${traffic_filter_file_name}


Set tls parameter
    [Arguments]     ${path}     ${value}
    Perform Recommissioning     type=param  param_path=${path}      value=${value}    operation=update
    Sleep    60

Configure certificate on BTS
    [Arguments]     ${rsa_certificate}     ${ecdsa_certificate}     ${rsa_password}   ${ecdsa_password}
    Certificate Configure     operation=restore_vendor_certificate
    Sleep   300
    Certificate Configure       operation=install_certificate   cert_file=${rsa_certificate}
    ...     cert_type=BtsTrustChain     cert_format=P12     password=${rsa_password}     key_pool_type=RSA
    Sleep   60
    Certificate Configure       operation=install_certificate   cert_file=${ecdsa_certificate}
    ...     cert_type=BtsTrustChain     cert_format=P12     password=${ecdsa_password}      key_pool_type=ECDSA
    Sleep   60

Check server type and Verify TLS paramter and version
    [Arguments]     ${server_type}   ${tls_version}      ${poolType}     ${pcap_name}    ${delta_to_delete}
    ...     ${delta_to_add}
    Log       ${tls_version}
    Log       ${poolType}
    Run Keyword If      '${server_type}'=='graylog'     Graylog_capture     ${pcap_name}
    Run Keyword If      '${server_type}' == 'dcap'  Verify TLS parameter and version    ${pcap_name}
    ...     ${delta_to_delete}  ${delta_to_add}
    Run Keyword If      '${server_type}' == 'trex'      Verify TLS parameter and version    ${pcap_name}
    ...     ${delta_to_delete}  ${delta_to_add}


Verify TLS parameter and version
    [Arguments]     ${pcap_name}    ${delta_to_delete}  ${delta_to_add}
    Traffic Capture Start        capture_device=bts          alias=${pcap_name}
    Perform Recommissioning     type=delta      delta_file=${delta_to_delete}     skip_parameter_relation_errors=${True}
    ...     timeout=300
    Perform Recommissioning     type=delta      delta_file=${delta_to_add}     skip_parameter_relation_errors=${True}
    ...     timeout=300
    Sleep   100
    ${file}=                Traffic Capture Stop    alias=${pcap_name}
    Set Suite Variable              ${file}

Read trace_expert ip
        ${trex_ip}=     Get Parameter   param_path=${trace_ip_moc}
        Set Suite Variable          ${trex_ip}

Read mplane IP
    ${mplane_ipv4}=     Get Parameter   param_path=${mplane_ipv4_moc}
    Set Suite Variable          ${mplane_ipv4}

Ping to Mplane
    ${status}=  Run Keyword     Run     command=ping -c 10 ${mplane_ipv4}
    Should contain Any      ${status}   0% packet loss

Read trace_expert ip for 4g
        ${trex_ip}=     Get Parameter   param_path=${trace_ip_moc_4g}
        Set Suite Variable          ${trex_ip}

Graylog_capture
    [Arguments]     ${pcap_name}
    Traffic Capture Start        capture_device=bts          alias=${pcap_name}
    Set tls parameter       ${remotesyslog_path}        ${remote_syslog_value_disable}
    Set tls parameter       ${remotesyslog_path}        ${remote_syslog_value}
    Sleep   300
    ${file}=                Traffic Capture Stop    alias=${pcap_name}
    Set Suite Variable              ${file}

Read graylog IP
    ${graylog_ip}=      Get Parameter   param_path=${graylog_ip_moc}
    Set Suite Variable      ${graylog_ip}

Copy certificate to EMSSIM
    [Arguments]     ${certificate_type}
    Run Keyword If  '${certificate_type}'=='ecdsa'      Run     command=sudo systemctl restart apache2
    Run Keyword If  '${certificate_type}'=='ecdsa'
    ...     Run     command=sudo mv /opt/emssim/serverprivkey.pem /opt/emssim/proxy/ssl/serverprivkey_bkup1.pem
    Run Keyword If  '${certificate_type}'=='ecdsa'
    ...     Run     command=sudo mv /opt/emssim/proxy/ssl/servercert.pem /opt/emssim/proxy/ssl/servercert_bkup1.pem
    Run Keyword If  '${certificate_type}'=='ecdsa'
    ...     Run     command=sudo mv /opt/emssim/proxy/ssl/cacert.pem /opt/emssim/proxy/ssl/cacert_bkup1.pem
    Run Keyword If  '${certificate_type}'=='ecdsa'
    ...     Run     command=sudo cp /home/ute/fw_user_path/testcases/CB008254/serverprivkey.pem /opt/emssim/proxy/ssl/.
    Run Keyword If  '${certificate_type}'=='ecdsa'
    ...     Run     command=sudo cp /home/ute/fw_user_path/testcases/CB008254/servercert.pem /opt/emssim/proxy/ssl/.
    Run Keyword If  '${certificate_type}'=='ecdsa'
    ...     Run     command=sudo cp /home/ute/fw_user_path/testcases/CB008254/cacert.pem /opt/emssim/proxy/ssl/.
    Run Keyword If  '${certificate_type}'=='rsa'    Run     command=sudo systemctl restart apache2
    Run Keyword If  '${certificate_type}'=='rsa'
    ...     Run     command=cp /home/ute/fw_user_path/testcases/CB008254/serverprivkey_rsa.pem /tmp/serverprivkey.pem
     Run Keyword If  '${certificate_type}'=='rsa'
     ...    Run    command=sudo mv /opt/emssim/proxy/ssl/serverprivkey.pem /opt/emssim/proxy/ssl/serverprivkey_bkup.pem
    Run Keyword If  '${certificate_type}'=='rsa'
    ...     Run     command=sudo cp /tmp/serverprivkey.pem /opt/emssim/proxy/ssl/.
    Run Keyword If  '${certificate_type}'=='rsa'
    ...     Run     command=sudo cp /home/ute/fw_user_path/testcases/CB008254/servercert_rsa.pem /tmp/servercert.pem
    Run Keyword If  '${certificate_type}'=='rsa'
    ...     Run     command=sudo mv /opt/emssim/proxy/ssl/servercert.pem /opt/emssim/proxy/ssl/servercert_bkup.pem
    Run Keyword If  '${certificate_type}'=='rsa'
    ...     Run     command=sudo cp /tmp/servercert.pem /opt/emssim/proxy/ssl/.
    Run Keyword If  '${certificate_type}'=='rsa'
    ...     Run     command=sudo cp /home/ute/fw_user_path/testcases/CB008254/cacert_rsa.pem /tmp/cacert.pem
    Run Keyword If  '${certificate_type}'=='rsa'
    ...     Run     command=sudo mv /opt/emssim/proxy/ssl/cacert.pem /opt/emssim/proxy/ssl/cacert_bkup.pem
    Run Keyword If  '${certificate_type}'=='rsa'    Run     command=sudo cp /tmp/cacert.pem /opt/emssim/proxy/ssl/.

Verify TLS parameter and version for nms case
    [Arguments]     ${pcap_name}
    Traffic Capture Start        capture_device=bts          alias=${pcap_name}
    Set tls parameter   ${oamtls}       ${oamTls_off}
    Set tls parameter   ${oamtls}       ${oamTls_forced}
    ta_emss.setup_emss    config_device=emssim1   ne3s_activate=True     tls=True   bts_id=3
    ...     wait_discovered=False   wait_connected=False
    Run Ems Command     config_device=emssim1   command=ne3s_activate -tls
    Sleep   120
    ${status}=            Query Admin Infomodel     query=get param ${oamTls_status}
    Should be equal     ${status}        secured
    Teardown Ems    config_device=emssim1
    ${file}=                Traffic Capture Stop    alias=${pcap_name}
    Set Suite Variable              ${file}

Get Pcap Details for TLS1_3 for emssim
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_version_1_3_emmsim
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls13_application_data_emssim
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls13_emssim_destport
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap Details for TLS1_2 for emssim
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_version_1_2_emssim
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_1_2_cipher_suites_emssim
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls12_application_data_emssim
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap Details for TLS1_2 with rsa for emssim
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_version_1_2_emssim
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls_1_2_cipher_suites_emssim_rsa
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_tls12_application_data_emssim
    ...     filter_file_name=${traffic_filter_file_name}

Read DCAP IP
        ${dcap_server}=     Get Parameter   param_path=${dcap_ip_moc}
        Set Suite Variable          ${dcap_server}

Expected alarms
    ${pre_reset_alarms}=    Verify Alarm    alarm_type=active
    ${pre_reset_length}=    Get Length  ${pre_reset_alarms}
    ${pre_alarm_faultids}=  Create List
    ${pre_alarm_faultids}=  Create fault id List    ${pre_reset_alarms}
    Set Suite Variable      ${pre_alarm_faultids}

Alarms after reset
    [Arguments]    ${pre_alarm_faultids}
    ${post_reset_alarms}=   Verify Alarm    alarm_type=active
    ${post_reset_length}=   Get Length  ${post_reset_alarms}
    ${post_alarm_faultids}=  Create List
    ${post_alarm_faultids}=  Create fault id List   ${post_reset_alarms}
    Lists Should Be Equal    ${pre_alarm_faultids}   ${post_alarm_faultids}     ignore_order=${True}

Create fault id List
    [Arguments]     ${list}
    ${length}=  Get Length  ${list}
    ${list1}=   Create List
    FOR     ${i}    IN RANGE    ${length}
        Append To List  ${list1}    ${list[${i}]['faultId']}
    END
    RETURN    ${list1}

Fault list after reset
    [Arguments]     ${pre_alarm_faultids}   ${post_alarm_faultids}
    ${list}=    Create List
    FOR     ${i}    IN      ${post_alarm_faultids}
        Run Keyword If  ${i} in ${pre_alarm_faultids}   Continue For Loop
        Append To List  ${list} ${i}
    END
    RETURN    ${list}
