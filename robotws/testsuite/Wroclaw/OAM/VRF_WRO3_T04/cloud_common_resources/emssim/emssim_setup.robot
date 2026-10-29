*** Settings ***
Documentation   Keywords including emssim configurations on VM.
...             Author:     Jagoda Kubacka
...             Contact:    jagoda.kubacka@nokia.com

Library       taf.sbts.oam.coam.admin      WITH NAME   coam_admin
Resource      ./emssim_variables.robot
Resource      ./emssim_connection.robot
Resource      ../../../cloud_common_resources/certificates/certificates.robot
Resource      ../../../cloud_common_resources/connections/connections.robot
Library       SSHLibrary
Library       OperatingSystem


*** Keywords ***
Setup environment for EMSSIM
    [Documentation]    Description:    Setup the environment for EMSSIM. This KW update emssim and then copy
    ...                                proper certificates (RSA/ECDSA) to give a possibility to make secure connection
    ...                                with BTS. Then apache is restarted (must be done because of new certs and strings).
    ...                                After this, the EMSSIM user is added.
    ...                Important:      Before executing this keyword remember to initialize necessary certificate.
    ...                                You can find them in emssim_variables.robot
    ...                Input:          cert_type - RSA/ECDSA (default value is RSA)
    ...                                enable_tls - connecting with or without TLS (default is with TLS)
    ...                                hw_type =  vCU/vDU
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${cert_type}=RSA    ${enable_tls}=1    ${hw_type}=${NONE}
    RUN                /opt/emssim/util/upgrade_emssim.pl -t
    Log                Version of EMSSIM updated    console=true
    ${MRBTS}=          Set Variable If    '${hw_type}'=='vCU'    ${MRBTS_CU}      ${MRBTS}
    ${kill}=           RUN                 sudo killall -u flexi${MRBTS}
    ${del}=            RUN                 sudo userdel -r flexi${MRBTS}
    RUN    sudo pkill -f "emssim"
    ${temp_conn}=      Connect to ADMIN    hw_type=${hw_type}
    Run Keyword If  ${enable_tls} == 1
    ...    Run keywords
    ...    Log         Setup environment for EMSSIM started           console=true
    ...    AND         Certificates Copy         cert_type=${cert_type}
    ...    AND         Strings Replacing
    ...    AND         Apache Restart
    Add EMSSIM User on VM    hw_type=${hw_type}
    Log                Environment for EMSSIM prepared successfully    console=true
    [Teardown]    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${temp_conn}    hw_type=${hw_type}

Add EMSSIM User on VM
    [Documentation]    Description:    Responsible for adding EMSSIM user on VM. Without user the connection
    ...                                with EMSSIM is not possible.
    ...                Input:          hw_type =  vCU/vDU
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${hw_type}=${NONE}
    ${LMP_IP}=         Set Variable If    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${MRBTS}=          Set Variable If    '${hw_type}'=='vCU'    ${MRBTS_CU}      ${MRBTS}
    Log                Creating user flexi${MRBTS} on EMSSIM VM...    console=true
    Run                sudo /opt/emssim/util/add_user.pl -u flexi${MRBTS} -ip ${LMP_IP}
    Log                Creating user flexi${MRBTS} done               console=true

Apache Restart
    [Documentation]    Description:    Responsible for restarting Apache after copying new certificates.
    ...                Input:          None
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    Log                Restart apache2               console=true
    RUN                sudo systemctl restart apache2
    Log                Restart apache2 successful    console=true


Certificates Copy
    [Documentation]    Description:    Responsible for replacing the strings responsible for new certificates.
    ...                Input:          cert_type - RSA/ECDSA (default is RSA)
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${cert_type}=RSA
    ${cert_path}       Get From Dictionary    ${CERTS_PATH}   ${cert_type}
    Log                Copying certificates                console=true
    Run                sudo cp ${cert_path}/*.pem ${emssim_ssl_path}
    Run                sudo cp ${cert_path}/*.pem ${emssim_apache_key}
    Run                sudo cp ${cert_path}/*.pem ${emssim_apache_crt}
    Log                Certificates copied successfully    console=true

Strings Replacing
    [Documentation]    Description:    Responsible for replacing the strings responsible for new certificates.
    ...                Input:          None
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    Log    Replacing strings in files       console=true
    Run    sed -i 's/CipherString = DEFAULT@SECLEVEL=[0-9]/CipherString = DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf
    Run    sed -i '34i\ SSLCertificateChainFile /etc/apache2/ssl.crt/cacert.pem' /home/ute/default-ssl.conf
    Log    Strings replaced successfully    console=true
