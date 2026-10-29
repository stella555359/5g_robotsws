*** Settings ***
Documentation
...     description:    Test cases for the CB007822 feature. Test cases check AirScale ASIM TPM activation for applications
...                     (factory procedure scenarios for TPM, TPM operational functions and support for TPM FW upgrade).

Resource        ../../../common_resources/emssim/emssim_setup.robot
Resource        ../../../common_resources/emssim/emssim.robot
Resource        ../../../common_resources/tls/tls.robot
Resource        ../../../common_resources/binary_files/binary_files.robot
Resource        ../resources/CB007822.robot
Library         ../resources/7822.py
Resource     	../../CB008254/TestCases/CB008254.robot
Resource        ../../../common_resources/admin/admin.robot
Resource        ../../../common_resources/certificates/certificates.robot
Resource        ../../../common_resources/netact/netact_operations.robot
Resource        ../../../common_resources/scf/scf_objects.robot
Library         taf.sbts.oam.coam.admin    WITH NAME   coam_admin


*** Variables ***
${RSA_SUBJECT_NAME}         CN = CB007672
${RSA_SUBJECT_NAME_2}       CN = CB007672_blank
${para}                     cert.pem
${para2}                    privkey.crk
${para3}                    root_cert
${LOGIN}                    toor4nsn
${PASSWORD}                 oZPS0POrRieRtu
${ECDSA_SUBJECT_NAME}       CN = CB005999_test
${ECDSA_SUBJECT_NAME2}      CN=CB00599_cross_SUB
${issuer_ECDSA}             CN = CB00599_cross_SUB
${IP_Syslog}                10.42.22.116
${P12_PASSWORD}             YT_xk39b
${rsa_name}                 rsa
${ecdsa_name}               ecdsa
${username_web}             Nemuadmin
${password_web}             nemuuser
${FILE_TPM_PATH}            /ffs/fs1/etc/keys.d/private/tpmboardkeypriv.pem
${SERVICEUSER_USERNAME}=    serviceuser
${SERVICEUSER_PASSWORD}=    Pl(FzaYj5~c5;q


*** Keywords ***
CB007822_BTS_Default_Keypair_Storage_TPM
    ${bts_connection}=    ssh.Connect to       hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                   password=${SSH_PASSWORD}
    ${files}=             ssh.execute          command=ls /etc/keys.d/private
    ...                                        connection=${bts_connection}
    Should Contain        ${files}             tpmboardkeypriv.pem
    ${params}=            ssh.execute          command=ls /etc/keys.d/board
    ...                                        connection=${bts_connection}
    Should Contain        ${params}            privkey.pem
    Log                   ${params}            console=true
    [Teardown]            ssh.Disconnect       ${bts_connection}

CB007822_TPM_Log_Check_on_BTS_Startup
    ${bts_connection}=    ssh.Connect to       hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                   password=${SSH_PASSWORD}
    ${files}=             ssh.execute          command=ls /etc/keys.d/private
    ...                                        connection=${bts_connection}
    Should Contain        ${files}             tpmboardkeypriv.pem
    ssh.Disconnect        ${bts_connection}
    Run Keyword With ADMIN Connection          coam_admin.Reset Site      timeout=900
    Wait Until Keyword Succeeds  20m  30s      Check If BTS Is Pingable
    ${ssh_conn}=          ssh.Connect To       ${LMP_IP}    ${SSH_USERNAME}    ${SSH_PASSWORD}
    ${params}=            ssh.execute          command=zcat /var/log/uboot.msg.gz
    ...                                        connection=${ssh_conn}
    Log                   ${params}            console=true
    Should Contain        ${params}            Initialize TPM
    [Teardown]            ssh.Disconnect       ${ssh_conn}

CB007822_BTS_TPM_reboot
    ${bts_connection}=    ssh.Connect to       hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                   password=${SSH_PASSWORD}
    ${files}=             ssh.execute          command=ls /etc/keys.d/private
    ...                                        connection=${bts_connection}
    Should Contain        ${files}             tpmboardkeypriv.pem
    ssh.Disconnect        ${bts_connection}
    ${admin_conn}=        Connect to ADMIN
    ${certs_list}=        Run Keyword With ADMIN Connection  coam_admin.get_certificate_list  Vendor
    Log                   ${certs_list}        console=true
    ${fingerprints}=      Get Certificates Fingerprints      cert_list=${certs_list}
    coam_admin.Reset Site                      connection=${admin_conn}      timeout=600
    Wait Until Keyword Succeeds  20m  30s      Check If BTS Is Pingable
    ${certs_list1}=       coam_admin.get_certificate_list    Vendor          connection=${admin_conn}
    ${fingerprints1}=     Get Certificates Fingerprints      cert_list=${certs_list1}
    compare_two_fingerprints   ${fingerprints}   ${fingerprints1}
    [Teardown]            Disconnect from ADMIN              connection=${admin_conn}

CB007822_Secure_file_storage
    Connect to Admin      alias=admin_connection
    ${vm_pass}            Run    sudo cat /etc/ute/vncpasswd
    coam_admin.configure_lss_account            lss_username=${LSS_username}
    ...                                         lss_password=${vm_pass}
    ...                                         connection=admin_connection
    Change Local Symptoms Server Configuration         ${VM_IP}
    ...                                                ${port}
    ...                                                connection=admin_connection
    coam_admin.get_remote_snapshot              connection=admin_connection
    ${ssh_conn}=   ssh.Connect to               hostname=${VM_IP}           username=${LSS_username}
    ...                           password=${LSS_password}
    ${params}=     ssh.execute    command=ls -d *Snapshot*
    ...                           connection=${ssh_conn}
    ${bts_sw_version}=  Run Keyword With ADMIN Connection  coam_admin.Get SW Version
    Should Contain      ${params}   ${bts_sw_version}
    [Teardown]    Run Keywords             ssh.Disconnect    ${ssh_conn}
    ...           AND                      Disconnect from ADMIN              connection=admin_connection

CB007822_Signing_IPSec_fronthaul
    Run Keyword With ADMIN Connection  coam_admin.Perform Parameter Recommissioning
    ...                                dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                parameter=actEcpriRuMPlaneSecurity
    ...                                operation=update
    ...                                value=RuProtectEnabled
    Wait until BTS reach Configured or OnAir state
    ${bts_connection}=    ssh.Connect to                   hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                              password=${SSH_PASSWORD}
    ${response}=    ssh.Execute      command=lxc-attach -n 0x1018 -- timeout -s 9 90s tcpdump -i rlan0
    ...                              connection=${bts_connection}
    Should Contain    ${response}   ESP
    ${response2}=    ssh.Execute     command=lxc-attach -n 0x1018 -- timeout -s 9 90s ipsec statusall
    ...                              connection=${bts_connection}
    Should Contain    ${response2}    conn1502
    [Teardown]     ssh.Disconnect     ${bts_connection}

CB007822_Creating_EC_Keypairs_via_CMP_init
    [Documentation]       Changing ECDSA key lenght, checking it in ec_cert.pem
    ${bts_connection}=    ssh.Connect to       hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                   password=${SSH_PASSWORD}
    ${files}=             ssh.execute          command=ls /etc/keys.d/private
    ...                                        connection=${bts_connection}
    Should Contain        ${files}             tpmboardkeypriv.pem
    ssh.Disconnect        ${bts_connection}
    Connect to Admin      alias=connection1
    Set CMP Server Settings                    key_pool_type=ECDSA
    coam_admin.Restore Vendor Certificate      connection=connection1
    Configure CMP         ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                   server_type=ECDSA
    Change Parameter On BTS                    MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                        keyLength
    ...                                        256
    Initialize Certificates                    key_pool_type=ECDSA
    SSHLibrary.Open Connection                 ${LMP_IP}    alias=Main
    SSHLibrary.Login      ${SSH_USERNAME}     ${SSH_PASSWORD}
    SSHLibrary.Write      cd /rom/trs_data/active/keystorage/certs
    Sleep    2
    SSHLibrary.Write      openssl x509 -in ec_cert.pem -text
    Sleep    5
    ${output}=            SSHLibrary.Read
    Should contain        ${output}             256 bit
    Change Parameter On BTS                     MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                         keyLength
    ...                                         384
    Initialize Certificates                     key_pool_type=ECDSA
    SSHLibrary.Write      openssl x509 -in ec_cert.pem -text
    Sleep    5
    ${output}=            SSHLibrary.Read
    Should contain        ${output}             384 bit
    [Teardown]            Run Keywords
    ...                   Clear Certificates
    ...                   AND                   Disconnect From Admin
    ...                   connection1

CB007822_Creating_RSA_Keypairs_via_CMP_init
    [Documentation]     Changing RSA key lenght, checking it in cert.pem
    ${bts_connection}=    ssh.Connect to       hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                   password=${SSH_PASSWORD}
    ${files}=             ssh.execute          command=ls /etc/keys.d/private
    ...                                        connection=${bts_connection}
    Should Contain        ${files}             tpmboardkeypriv.pem
    ssh.Disconnect        ${bts_connection}
    Connect to Admin      alias=connection2
    Set CMP Server Settings                    key_pool_type=RSA
    coam_admin.Restore Vendor Certificate      connection=connection2
    Change Parameter On BTS                    MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                        keyLength
    ...                                        2048
    Initialize Certificates                    key_pool_type=RSA
    SSHLibrary.Open Connection                 ${LMP_IP}    alias=Main
    SSHLibrary.Login      ${SSH_USERNAME}     ${SSH_PASSWORD}
    SSHLibrary.Write      cd /rom/trs_data/active/keystorage/certs
    Sleep    2
    SSHLibrary.Write                            openssl x509 -in cert.pem -text
    Sleep    5
    ${output}=            SSHLibrary.Read
    Should contain        ${output}             2048 bit
    Change Parameter On BTS                     MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                         keyLength
    ...                                         4096
    Initialize Certificates                     key_pool_type=RSA
    SSHLibrary.Write       cd /rom/trs_data/active/keystorage/certs
    Sleep    2
    SSHLibrary.Write       openssl x509 -in cert.pem -text
    Sleep    5
    ${output}=            SSHLibrary.Read
    Should contain        ${output}             4096 bit
    [Teardown]            Run Keywords
    ...                   Clear Certificates
    ...                   AND                   Disconnect From Admin
    ...                   connection2

CB007822_Operator_RSA_Keypairs_Renewal
    [Documentation]     Changing RSA CE object name, checking it in cert.pem
    ${bts_connection}=    ssh.Connect to       hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                   password=${SSH_PASSWORD}
    ${files}=             ssh.execute          command=ls /etc/keys.d/private
    ...                                        connection=${bts_connection}
    Should Contain        ${files}             tpmboardkeypriv.pem
    ssh.Disconnect        ${bts_connection}
    NetAct Setup
    Configure CMP         ca_subject_name=${RSA_SUBJECT_NAME}
    ...                   server_type=RSA
    Initialize Certificates From NetAct
    ...                   connection=${NETACT_CONNECTION}
    ...                   server_type=RSA
    Sleep                 20
    ...                   reason=Wait until certificates initialization completed
    ${connection}=        Connect with SSH      ${LMP_IP}  ${LOGIN}  ${PASSWORD}  conn
    ${out}=               Execute   ls -la /rom/trs_data/active/keystorage/certs  conn
    ${output}=            Execute   openssl x509 -in /rom/trs_data/active/keystorage/certs/cert.pem -text  conn
    Log                   ${out}    console=true
    Log                   ${output} console=true
    Should Contain        ${output}             Issuer: ${RSA_SUBJECT_NAME}
    Change Parameter on BTS         dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1
    ...                             param_name=autoCertDelete
    ...                             param_value=${TRUE}
    Set CMP Server Settings         key_pool_type=RSA
    Configure CMP                   ca_subject_name=${RSA_SUBJECT_NAME_2}
    ...                             server_type=RSA
    Initialize Certificates From NetAct
    ...                             connection=${NETACT_CONNECTION}
    ...                             server_type=RSA
    Sleep                           20
    ...                             reason=Wait until certificates initialization completed
    ${out2}=              Execute   ls -la /rom/trs_data/active/keystorage/certs  conn
    Log                   ${out2}   console=true
    Should Contain        ${out2}               ${para}
    Should Contain        ${out2}               ${para2}
    Should Contain        ${out2}               ${para3}
    ${out4}=              Execute   openssl x509 -in /rom/trs_data/active/keystorage/certs/cert.pem -text   conn
    Should Contain        ${out4}               Issuer: ${RSA_SUBJECT_NAME_2}
    Change Parameter on BTS         dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1
    ...                             param_name=autoCertDelete
    ...                             param_value=${FALSE}
    [Teardown]            Run Keywords
    ...                   Disconnect SSH Session    conn
    ...                   AND       Clear Certificates
    ...                   AND       NetAct Teardown

CB007822_Operator_EC_Keypairs_Renewal
    [Documentation]       Changing ECDSA CE object name, checking it in ec_cert.pem
    ${bts_connection}=    ssh.Connect to       hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                   password=${SSH_PASSWORD}
    ${files}=             ssh.execute          command=ls /etc/keys.d/private
    ...                                        connection=${bts_connection}
    Should Contain        ${files}             tpmboardkeypriv.pem
    ssh.Disconnect        ${bts_connection}
    NetAct Setup
    Set CMP Server Settings           key_pool_type=ECDSA
    Run Keyword and Ignore Error      Change parameter on BTS               MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                                                     certTypeForTlsAuth
    ...                                                                     ECDSA
    Configure CMP                     ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                               server_type=ECDSA
    Initialize Certificates From NetAct
    ...                               connection=${NETACT_CONNECTION}
    ...                               server_type=ECDSA
    Sleep                             20
    ...                               reason=Wait until certificates initialization completed
    ${connection}=       Connect with SSH      ${LMP_IP}  ${LOGIN}  ${PASSWORD}  conn
    ${out}=              Execute      ls -la /rom/trs_data/active/keystorage/certs  conn
    ${output}=           Execute      openssl x509 -in /rom/trs_data/active/keystorage/certs/ec_cert.pem -text  conn
    Log                  ${out}       console=true
    Log                  ${output}    console=true
    Should Contain       ${output}    Issuer: ${ECDSA_SUBJECT_NAME}
    Change Parameter on BTS           dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1
    ...                               param_name=autoCertDelete
    ...                               param_value=${TRUE}
    Clear Certificates
    Configure CMP                     ca_subject_name=${ECDSA_SUBJECT_NAME2}
    ...                               server_type=ECDSA
    Initialize Certificates From NetAct
    ...                               connection=${NETACT_CONNECTION}
    ...                               server_type=ECDSA
    Sleep                             20
    ...                               reason=Wait until certificates initialization completed
    ${out2}=             Execute      ls -la /rom/trs_data/active/keystorage/certs  conn
    Log                  ${out2}      console=true
    Should Contain       ${out2}      ${para}
    Should Contain       ${out2}      ${para2}
    Should Contain       ${out2}      ${para3}
    ${out4}=             Execute      openssl x509 -in /rom/trs_data/active/keystorage/certs/ec_cert.pem -text   conn
    Should Contain       ${out4}      Issuer: ${issuer_ECDSA}
    [Teardown]           Run Keywords
    ...                  Disconnect SSH Session    conn          AND
    ...                  Clear Certificates        AND
    ...                  NetAct Teardown

CB007822_Manual_Operator_RSA_keypair_install
    [Documentation]       Installation of RSA certificates, checking if installed correctly
    ${bts_connection}=    ssh.Connect to       hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                   password=${SSH_PASSWORD}
    ${files}=             ssh.execute          command=ls /etc/keys.d/private
    ...                                        connection=${bts_connection}
    Should Contain        ${files}             tpmboardkeypriv.pem
    ssh.Disconnect        ${bts_connection}
    Connect to Admin      alias=connection3
    coam_admin.Restore Vendor Certificate      connection=connection3
    Generate Binary File From HEX String       hex_string_file=${P12_RSA_2048}
    ...                                        binary_file_name=${CURDIR}/certRSA2048.p12
    Install Certificate On BTS                 cert_file=${CURDIR}/certRSA2048.p12
    ...                                        cert_type=BtsTrustChain
    ...                                        cert_format=P12
    ...                                        p12password=ute
    ...                                        connection=connection3
    ...                                        key_pool_type=RSA
    SSHLibrary.Open Connection                 ${LMP_IP}                 alias=ssh_connection
    SSHLibrary.Login       ${SSH_USERNAME}    ${SSH_PASSWORD}
    SSHLibrary.Write       cd /rom/trs_data/active/keystorage/certs
    Sleep    2
    SSHLibrary.Write       openssl x509 -in cert.pem -text
    Sleep    5
    ${output}=             SSHLibrary.Read
    Should contain         ${output}            2048 bit
    SSHLibrary.Close Connection
    Generate Binary File From HEX String        hex_string_file=${P12_RSA_4096}
    ...                                         binary_file_name=${CURDIR}/certRSA4096.p12
    Install Certificate On BTS                  cert_file=${CURDIR}/certRSA4096.p12
    ...                                         cert_type=BtsTrustChain
    ...                                         cert_format=P12
    ...                                         p12password=ute
    ...                                         connection=connection3
    ...                                         key_pool_type=RSA
    Sleep                  20
    ...                    reason=Wait until certificates initialization completed
    SSHLibrary.Open Connection                  ${LMP_IP}               alias=ssh_connection2
    SSHLibrary.Login       ${SSH_USERNAME}     ${SSH_PASSWORD}
    SSHLibrary.Write       cd /rom/trs_data/active/keystorage/certs
    Sleep    2
    SSHLibrary.Write       openssl x509 -in cert.pem -text
    Sleep    5
    ${output}=             SSHLibrary.Read
    Should contain         ${output}            4096 bit
    SSHLibrary.Close Connection
    [Teardown]             Run Keywords         Clear Certificates          AND
    ...                                         Disconnect from ADMIN       connection3

CB007822_Manual_Operator_EC_keypair_install
    [Documentation]     Installation of RSA certificates, checking if installed correctly
    ${bts_connection}=    ssh.Connect to       hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                   password=${SSH_PASSWORD}
    ${files}=             ssh.execute          command=ls /etc/keys.d/private
    ...                                        connection=${bts_connection}
    Should Contain        ${files}             tpmboardkeypriv.pem
    ssh.Disconnect        ${bts_connection}
    Clear Certificates
    Connect to Admin      alias=connection4
    coam_admin.Restore Vendor Certificate       connection=connection4
    Generate Binary File From HEX String        hex_string_file=${P12_ECDSA_256}
    ...                                         binary_file_name=${CURDIR}/certECDSA.p12
    Install Certificate On BTS                  cert_file=${CURDIR}/certECDSA.p12
    ...                                         cert_type=BtsTrustChain
    ...                                         cert_format=P12
    ...                                         p12password=ute
    ...                                         key_pool_type=ECDSA
    Sleep                  20
    ...                    reason=Wait until certificates initialization completed
    SSHLibrary.Open Connection                  ${LMP_IP}                   alias=ssh_connection
    SSHLibrary.Login        ${SSH_USERNAME}    ${SSH_PASSWORD}
    SSHLibrary.Write        cd /rom/trs_data/active/keystorage/certs
    Sleep    2
    SSHLibrary.Write        openssl x509 -in ec_cert.pem -text
    Sleep    5
    ${output}=              SSHLibrary.Read
    Should contain          ${output}           256 bit
    SSHLibrary.Close Connection
    Clear Certificates
    Generate Binary File From HEX String        hex_string_file=${P12_ECDSA_384}
    ...                                         binary_file_name=${CURDIR}/certEC384.p12
    Install Certificate On BTS                  cert_file=${CURDIR}/certEC384.p12
    ...                                         cert_type=BtsTrustChain
    ...                                         cert_format=P12
    ...                                         p12password=ute
    ...                                         key_pool_type=ECDSA
    SSHLibrary.Open Connection                  ${LMP_IP}                     alias=ssh_connection
    SSHLibrary.Login         ${SSH_USERNAME}   ${SSH_PASSWORD}
    SSHLibrary.Write         cd /rom/trs_data/active/keystorage/certs
    Sleep    2
    SSHLibrary.Write         openssl x509 -in ec_cert.pem -text
    Sleep    5
    ${output}=               SSHLibrary.Read
    Should contain           ${output}          384 bit
    SSHLibrary.Close Connection
    [Teardown]             Run Keywords         Clear Certificates          AND
    ...                                         Disconnect from ADMIN       connection4

CB007822_TLS_authentication_with_RSA
    [Documentation]       Configuration of RSA CMP and TLS 1.3, verification of it with syslog
    ${bts_connection}=    ssh.Connect to       hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                   password=${SSH_PASSWORD}
    ${files}=             ssh.execute          command=ls /etc/keys.d/private
    ...                                        connection=${bts_connection}
    Should Contain        ${files}             tpmboardkeypriv.pem
    ssh.Disconnect        ${bts_connection}
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        actEnableTLSv13
    ...                        true
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        tls12Enabled
    ...                        false
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        oamTls
    ...                        forced
    Set CMP Server Settings                   key_pool_type=RSA
    Run Keyword and Ignore Error              Change parameter on BTS        MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                       certTypeForTlsAuth
    ...                                       RSA
    Configure CMP              ca_subject_name=${RSA_SUBJECT_NAME}
    ...                        server_type=RSA
    Initialize Certificates    key_pool_type=RSA
    Sleep                      20
    ...                        reason=Wait until certificates initialization completed
    Add remoteSyslogConfig Structure To SCF    ${PARAMS1}
    Wait until BTS reach Configured or OnAir state
    Start TCPDump
    Sleep                      15
    ...                        reason=Wait until tcpdump starts properly
    Wait Until Keyword Succeeds               5x  1 min                       Change parameter on BTS
    ...                                                                       MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                                                       actRemoteSyslogTransmission
    ...                                                                       true
    Sleep                      30
    ...                        reason=Wait until packets will be collected in PCAP
    Stop TCPDump And Download PCAP            tcpdump_filename=${rsa_name}.pcap
    Convert pcap to XML                       filename=${TEST_OUTPUT_DIR}/${rsa_name}.pcap
    ...                                       filters=tls.handshake.type == 2
    ...                                       xml_name=${CURDIR}/${rsa_name}.xml
    ${rsa}= 	               analyze_tls13                                  ${CURDIR}/${rsa_name}.xml
    Should Contain             ${rsa}[1][showname]                            TLSv1.3 Record Layer:
    [Teardown]                 Run Keywords
    ...                        TCPDump Teardown                               AND
    ...                        Change parameter on BTS                        MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                                                       actRemoteSyslogTransmission
    ...                                                                       false

CB007822_TLS_authentication_with_EC
    [Documentation]       Configuration of ECDSA CMP and TLS 1.3, verification of it with syslog
    ${bts_connection}=    ssh.Connect to       hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...                   password=${SSH_PASSWORD}
    ${files}=             ssh.execute          command=ls /etc/keys.d/private
    ...                                        connection=${bts_connection}
    Should Contain        ${files}             tpmboardkeypriv.pem
    ssh.Disconnect        ${bts_connection}
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        actEnableTLSv13
    ...                        true
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        tls12Enabled
    ...                        false
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        oamTls
    ...                        forced
    Set CMP Server Settings                   key_pool_type=ECDSA
    Run Keyword and Ignore Error              Change parameter on BTS        MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                       certTypeForTlsAuth
    ...                                       ECDSA
    Configure CMP              ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                        server_type=ECDSA
    Initialize Certificates    key_pool_type=ECDSA
    Sleep                      20
    ...                        reason=Wait until certificates initialization completed
    Add remoteSyslogConfig Structure To SCF   ${PARAMS1}
    Wait until BTS reach Configured or OnAir state
    Start TCPDump
    Sleep                      15
    ...                        reason=Wait until tcpdump starts properly
    Wait Until Keyword Succeeds               5x  1 min                     Change parameter on BTS
    ...                                                                     MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                                                     actRemoteSyslogTransmission
    ...                                                                     true
    Sleep                     30
    ...                       reason=Wait until packets will be collected in PCAP
    Stop TCPDump And Download PCAP           tcpdump_filename=${ecdsa_name}.pcap
    Convert pcap to XML       filename=${TEST_OUTPUT_DIR}/${ecdsa_name}.pcap
    ...                       filters=tls.handshake.type == 2
    ...                       xml_name=${CURDIR}/${ecdsa_name}.xml
    ${ecdsa}= 	              analyze_tls13                                ${CURDIR}/${ecdsa_name}.xml
    Should Contain            ${ecdsa}[1][showname]                        TLSv1.3 Record Layer:
    [Teardown]                Run Keywords
    ...                       TCPDump Teardown                             AND
    ...                       Change parameter on BTS                      MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                                                    actRemoteSyslogTransmission
    ...                                                                    false

CB007822_Robustness_full_TPM_or_unavailable
    Log                      Step 1: Login as toor4nsn    console=True
    ${connection_toor4nsn}=             Connect with SSH         ip_addr=${LMP_IP}
    ...                                                          user=${SSH_USERNAME}
    ...                                                          password=${SSH_PASSWORD}
    ...                                                          alias=connection_toor4nsn
    Log                      Step 2: Login as serviceuser    console=True
    ${connection_serviceuser}=          Connect with SSH         ip_addr=${LMP_IP}
    ...                                                          user=${SERVICEUSER_USERNAME}
    ...                                                          password=${SERVICEUSER_PASSWORD}
    ...                                                          alias=connection_serviceuser
    Log                      Step 3: Check file permission for toor4nsn    console=True
    Check File Permissions    ${connection_toor4nsn}    ${FILE_TPM_PATH}    -rw-r-----
    File Should Be Visible    ${connection_toor4nsn}    ${FILE_TPM_PATH}
    Log                      Step 4: Check file permission for serviceuser    console=True
    File Should Not Be Visible    ${connection_serviceuser}    ${FILE_TPM_PATH}
    Log                      Step 5: File tpmboardkeypriv.pem is not visible for serviceuser: Permission denied
    [Teardown]    Run Keywords    Disconnect SSH Session     ${connection_toor4nsn}
    ...    AND                    Disconnect SSH Session     ${connection_serviceuser}
