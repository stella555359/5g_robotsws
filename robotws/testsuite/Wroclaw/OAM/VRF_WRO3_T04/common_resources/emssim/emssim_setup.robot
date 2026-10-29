*** Settings ***
Documentation   Keywords including emssim configurations on VM.
...             Author:     Maciej Jopek
...             Contact:    maciej.jopek@nokia.com

Library       taf.sbts.oam.coam.admin      WITH NAME   coam_admin
Resource      ./emssim_variables.robot
Resource      ../certificates/certificates.robot
Library       SSHLibrary
Library       OperatingSystem

*** Variables ***
&{EMSSIM_CERT_PATH}    too_short=${CURDIR}/certificates_files/too_short
...                    expired=${CURDIR}/certificates_files/expired

*** Keywords ***
Setup environment for EMSSIM
    [Documentation]  Keyword including emssim configurations on VM.
    [Arguments]               ${cert_type}=RSA
    ...                       ${tls_version}=1_3
    ...                       ${enable_tls}=1
    ${update}=                RUN                       /opt/emssim/util/upgrade_emssim.pl -t
    Log                       Emssim updated
    ...                       console=${TRUE}
    ${kill}=                  RUN                       sudo killall -u flexi${BTS_ID}
    ${del}=                   RUN                       sudo userdel -r flexi${BTS_ID}
    RUN    sudo pkill -f "emssim"
    ${temp_conn}=             Connect to ADMIN
    Run keyword if  ${enable_tls} == 1
    ...    Run keywords
    ...    Log                       Setup environment for EMSSIM started
    ...                              console=${TRUE}
    ...    AND  Certificates Copy         cert_type=${cert_type}
    ...    AND  Strings Replacing
    ...    AND  Apache Restart
    ...    AND  Log                        Configuring TLS ${tls_version} on BTS...
    ...                                    console=${TRUE}
    ...    AND  Configure TLS On BTS       tls_version=${tls_version}    temp_conn=${temp_conn}
    ...    AND  Log                        Configuring certificates on BTS...
    ...                                    console=${TRUE}
    ...    AND  Configure CMP              bts_id=${bts_id}
    ...                                    server_type=${cert_type}
    ...                                    ca_subject_name=${CERTS_SUBJECT_NAME['${cert_type}']}
    ...                                    connection=${temp_conn}
    ...    AND  Initialize Certificates    key_pool_type=${cert_type}    connection=${temp_conn}
    ...    ELSE
    ...    Change parameter on BTS        dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                   param_name=oamTls
    ...                                   param_value=off
    ...                                   connection=${temp_conn}
    Add EMSSIM User on VM
    [Teardown]    Run Keyword and Ignore Error    Disconnect from ADMIN    ${temp_conn}

Configure TLS On BTS
    [Arguments]  ${tls_version}    ${temp_conn}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_TLS_1_1}    Configure TLS On BTS With TLS11
    ...                                           ${tls_version}    ${temp_conn}
    ...         ELSE    Configure TLS On BTS Without TLS11    ${tls_version}    ${temp_conn}

Configure TLS On BTS With TLS11
    [Arguments]  ${tls_version}    ${temp_conn}
    &{params}    Get From Dictionary    ${TLS_VERSIONS}     ${tls_version}

    Change Multiple Parameters On BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                 connection=${temp_conn}
    ...                                 oamTls=forced
    ...                                 &{params}

Configure TLS On BTS Without TLS11
    [Arguments]      ${tls_version}    ${temp_conn}
    &{params}        Get From Dictionary    ${TLS_VERSIONS}     ${tls_version}_WITHOUT_1_1

    Change Multiple Parameters On BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                 connection=${temp_conn}
    ...                                 oamTls=forced
    ...                                 &{params}

Get Sw Branch Release
    [Arguments]    ${connection}=${NONE}
    ${connection}=          admin_utils.create connection if not exist    ${connection}    alias=temp_conn
    ${INSTALLED_SW_BRANCH}  coam_admin.Get sw release name    connection=${connection}
    Set Global Variable   ${INSTALLED_SW_BRANCH}

Add EMSSIM User on VM
    [Documentation]  Keyword is responsible for add emssim user on VM
    Log                 Creating user flexi${BTS_ID} on EMSSIM VM...    console=True
    Run                 sudo /opt/emssim/util/add_user.pl -u flexi${BTS_ID} -ip ${MPLANE_IPV4}
    Log                 Creating user flexi${BTS_ID} done    console=True

Apache Restart
    [Documentation]  Keyword is responsible for restarting Apache.
    Log    Restart apache2    console=True
    RUN   sudo systemctl restart apache2

Certificates Copy
    [Documentation]  Keyword is responsible for copying unpleasant certificates on VM.
    [Arguments]      ${cert_type}=RSA
    ${cert_path}     Get From Dictionary    ${CERTS_PATH}   ${cert_type}

    Log    Copying certificates    console=True
    Run    sudo cp ${cert_path}/*.pem ${emssim_ssl_path}
    Run    sudo cp ${cert_path}/*.pem ${emssim_apache_key}
    Run    sudo cp ${cert_path}/*.pem ${emssim_apache_crt}

Strings Replacing
    [Documentation]  Keyword is responsible for replacing necessary string in files on VM.
    Log    Replacing strings in files    console=True
    Run   sed -i 's/CipherString = DEFAULT@SECLEVEL=[0-9]/CipherString = DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf
    Run   sed -i '34i\ SSLCertificateChainFile /etc/apache2/ssl.crt/cacert.pem' /home/ute/default-ssl.conf

Copy certificates to Emssim
    [Arguments]  ${cert_type}
    Log  ${EMSSIM_CERT_PATH}[${cert_type}]  console=true
    RUN  sudo cp ${EMSSIM_CERT_PATH}[${cert_type}]/cacert.pem /opt/emssim/proxy/ssl/cacert.pem
    RUN  sudo cp ${EMSSIM_CERT_PATH}[${cert_type}]/servercert.pem /opt/emssim/proxy/ssl/servercert.pem
    RUN  sudo cp ${EMSSIM_CERT_PATH}[${cert_type}]/serverprivkey.pem /opt/emssim/proxy/ssl/serverprivkey.pem
    RUN  sudo cp ${EMSSIM_CERT_PATH}[${cert_type}]/cacert.pem /etc/apache2/ssl.crt/cacert.pem
    RUN  sudo cp ${EMSSIM_CERT_PATH}[${cert_type}]/servercert.pem /etc/apache2/ssl.crt/servercert.pem
    RUN  sudo cp ${EMSSIM_CERT_PATH}[${cert_type}]/serverprivkey.pem /etc/apache2/ssl.key/serverprivkey.pem
    RUN  sudo systemctl restart apache2
    RUN  sudo systemctl restart fbox
    Sleep                               20
    ...                                 reason=Wait until fbox restarts
