*** Settings ***
Documentation
...  author:   Patryk Tatarek
...  contact:  patryk.tatarek@nokia.com

Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/netact/netact_operations.robot
Resource    ../../../common_resources/certificates/certificates.robot

Library     SSHLibrary

*** Variables ***
${logs_dest}=    ${OUTPUT_DIR}/ATL_logs.xml
${csr_file}=     ${EXECDIR}/csr_key.txt
${domain_type}=      CBRS

*** Keywords ***
Turn On autoCBRSCertDelete
    [Arguments]                ${conn}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1
    ...                        param_name=autoCBRSCertDelete
    ...                        param_value=true
    ...                        connection=${conn}
    Wait until BTS reach Configured or OnAir state

Turn Off autoCBRSCertDelete
    [Arguments]                ${conn}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1
    ...                        param_name=autoCBRSCertDelete
    ...                        param_value=false
    ...                        connection=${conn}
    Wait until BTS reach Configured or OnAir state

Turn On autoCertDelete
    [Arguments]                ${conn}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1
    ...                        param_name=autoCertDelete
    ...                        param_value=true
    ...                        connection=${conn}
    Wait until BTS reach Configured or OnAir state

Turn Off autoCertDelete
    [Arguments]                ${conn}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1
    ...                        param_name=autoCertDelete
    ...                        param_value=false
    ...                        connection=${conn}
    Wait until BTS reach Configured or OnAir state

Manual Temporary Log Event Storage
    ${connection}=                Connect to NetAct
    Get RUEM logs from NetAct     ${connection}    MRBTS-${BTS_ID}    ${logs_dest}
    File Should Not Be Empty      ${logs_dest}
    [Teardown]                    Disconnect from NetAct    ${connection}

Check autoCBRSCertDelete privileges on WebEM
    Setup Local user account       account_type=BTSApplication    new_password=Pl(FzaYj5~c5;q
    ${apl}=    Connect to ADMIN    username=BTSApplication    password=Pl(FzaYj5~c5;q
    ${on}=     Run Keyword And Return Status    Turn On autoCBRSCertDelete     ${apl}
    Should Not Be True    ${on}
    ${off}=    Run Keyword And Return Status    Turn Off autoCBRSCertDelete    ${apl}
    Should Not Be True    ${off}
    ${adm}=    Connect to ADMIN
    Turn On autoCBRSCertDelete     ${adm}
    Turn Off autoCBRSCertDelete    ${adm}
    Setup Local user account       account_type=BTSSecurity    new_password=Pl(FzaYj5~c5;q
    ${sec}=    Connect to ADMIN    username=BTSSecurity    password=Pl(FzaYj5~c5;q
    Turn On autoCBRSCertDelete     ${sec}
    Turn Off autoCBRSCertDelete    ${sec}
    [Teardown]    Firewall BTS Teardown

Check autoCertDelete privilegeson on WebEM
    Setup Local user account       account_type=BTSApplication    new_password=Pl(FzaYj5~c5;q
    ${apl}=    Connect to ADMIN    username=BTSApplication    password=Pl(FzaYj5~c5;q
    ${on}=     Run Keyword And Return Status    Turn On autoCertDelete     ${apl}
    Should Not Be True    ${on}
    ${off}=    Run Keyword And Return Status    Turn Off autoCertDelete    ${apl}
    Should Not Be True    ${off}
    ${adm}=    Connect to ADMIN
    Turn On autoCertDelete     ${adm}
    Turn Off autoCertDelete    ${adm}
    Setup Local user account       account_type=BTSSecurity    new_password=Pl(FzaYj5~c5;q
    ${sec}=    Connect to ADMIN    username=BTSSecurity    password=Pl(FzaYj5~c5;q
    Turn On autoCertDelete     ${sec}
    Turn Off autoCertDelete    ${sec}
    [Teardown]    Firewall BTS Teardown

Old CBRS rootCA removal WebEM
    ${conn}=    Connect to ADMIN
    Generate CSR    ${csr_file}    ${domain_type}    ${conn}
    ${csr}=    OperatingSystem.Get File    ${csr_file}
    SSHLibrary.Open Connection    10.42.158.109
    SSHLibrary.Login    ute    ute
    SSHLibrary.Write    cd SSLCA/intermediate1/enduser-certs
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    echo "${csr}" > bts11.csr
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    cd ..
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    openssl ca -batch -config ca.conf -notext -in enduser-certs/bts11.csr -out enduser-certs/bts11.pem
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Get File    /home/ute/SSLCA/intermediate1/enduser-certs/bts11.pem    ${EXECDIR}/
    Sleep    2    reason=Wait until terminal executes the command
    Run    cat ${CURDIR}/rootca_109.pem >> ${EXECDIR}/vendor1.pem
    Run    cat ${CURDIR}/intermediate1_109.pem >> ${EXECDIR}/vendor1.pem
    Run    cat ${EXECDIR}/bts11.pem >> ${EXECDIR}/vendor1.pem
    Install Certificate On BTS    cert_file=${EXECDIR}/vendor1.pem
    ...                           cert_type=CBRSVendorChain
    ...                           cert_format=PEM
    ...                           connection=${conn}
    Turn On autoCBRSCertDelete    ${conn}
    Generate CSR    ${csr_file}    ${domain_type}    ${conn}
    ${csr}=    OperatingSystem.Get File    ${csr_file}
    SSHLibrary.Close Connection
    Sleep    5    reason=Wait until connection closes
    SSHLibrary.Open Connection    10.44.180.108
    SSHLibrary.Login    ute    ute
    SSHLibrary.Write    cd SSLCA/intermediate1/enduser-certs
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    echo "${csr}" > bts11.csr
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    cd ..
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    openssl ca -batch -config ca.conf -notext -in enduser-certs/bts11.csr -out enduser-certs/bts11.pem
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Get File    /home/ute/SSLCA/intermediate1/enduser-certs/bts11.pem    ${EXECDIR}/
    Sleep    2    reason=Wait until terminal executes the command
    Run    cat ${CURDIR}/rootca_108.pem >> ${EXECDIR}/vendor2.pem
    Run    cat ${CURDIR}/intermediate1_108.pem >> ${EXECDIR}/vendor2.pem
    Run    cat ${EXECDIR}/bts11.pem >> ${EXECDIR}/vendor2.pem
    Install Certificate On BTS    cert_file=${EXECDIR}/vendor2.pem
    ...                           cert_type=CBRSVendorChain
    ...                           cert_format=PEM
    ...                           connection=${conn}
    ${certs}=             Get Certificates List    cert_type=CBRSTA   connection=${conn}
    ${certs_string}=      Convert To String    ${certs}
    Should Not Contain    ${certs_string}    CB008154root'
    [Teardown]    Run Keywords    Disconnect from ADMIN    ${conn}
    ...           AND             SSHLibrary.Close Connection
    ...           AND             Run    rm ${EXECDIR}/vendor1.pem
    ...           AND             Run    rm ${EXECDIR}/vendor2.pem
    ...           AND             Run    rm ${EXECDIR}/bts11.pem

Old CBRS rootCA retention WebEM
    ${conn}=    Connect to ADMIN
    Generate CSR    ${csr_file}    ${domain_type}    ${conn}
    ${csr}=    OperatingSystem.Get File    ${csr_file}
    SSHLibrary.Open Connection    10.42.158.109
    SSHLibrary.Login    ute    ute
    SSHLibrary.Write    cd SSLCA/intermediate1/enduser-certs
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    echo "${csr}" > bts11.csr
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    cd ..
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    openssl ca -batch -config ca.conf -notext -in enduser-certs/bts11.csr -out enduser-certs/bts11.pem
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Get File    /home/ute/SSLCA/intermediate1/enduser-certs/bts11.pem    ${EXECDIR}/
    Sleep    2    reason=Wait until terminal executes the command
    Run    cat ${CURDIR}/rootca_109.pem >> ${EXECDIR}/vendor1.pem
    Run    cat ${CURDIR}/intermediate1_109.pem >> ${EXECDIR}/vendor1.pem
    Run    cat ${EXECDIR}/bts11.pem >> ${EXECDIR}/vendor1.pem
    Install Certificate On BTS    cert_file=${EXECDIR}/vendor1.pem
    ...                           cert_type=CBRSVendorChain
    ...                           cert_format=PEM
    ...                           connection=${conn}
    Turn Off autoCBRSCertDelete    ${conn}
    Generate CSR    ${csr_file}    ${domain_type}    ${conn}
    ${csr}=    OperatingSystem.Get File    ${csr_file}
    SSHLibrary.Close Connection
    Sleep    5    reason=Wait until connection closes
    SSHLibrary.Open Connection    10.44.180.108
    SSHLibrary.Login    ute    ute
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    cd SSLCA/intermediate1/enduser-certs
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    echo "${csr}" > bts11.csr
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    cd ..
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Write    openssl ca -batch -config ca.conf -notext -in enduser-certs/bts11.csr -out enduser-certs/bts11.pem
    Sleep    2    reason=Wait until terminal executes the command
    SSHLibrary.Get File    /home/ute/SSLCA/intermediate1/enduser-certs/bts11.pem    ${EXECDIR}/
    Sleep    2    reason=Wait until terminal executes the command
    Run    cat ${CURDIR}/rootca_108.pem >> ${EXECDIR}/vendor2.pem
    Run    cat ${CURDIR}/intermediate1_108.pem >> ${EXECDIR}/vendor2.pem
    Run    cat ${EXECDIR}/bts11.pem >> ${EXECDIR}/vendor2.pem
    Install Certificate On BTS    cert_file=${EXECDIR}/vendor2.pem
    ...                           cert_type=CBRSVendorChain
    ...                           cert_format=PEM
    ...                           connection=${conn}
    ${certs}=           Get Certificates List    cert_type=CBRSTA    connection=${conn}
    ${certs_string}=    Convert To String    ${certs}
    Should Contain      ${certs_string}    CBRSCAlinux'
    [Teardown]    Run Keywords    Disconnect from ADMIN    ${conn}
    ...           AND             SSHLibrary.Close Connection
    ...           AND             Run    rm ${EXECDIR}/vendor1.pem
    ...           AND             Run    rm ${EXECDIR}/vendor2.pem
    ...           AND             Run    rm ${EXECDIR}/bts11.pem
