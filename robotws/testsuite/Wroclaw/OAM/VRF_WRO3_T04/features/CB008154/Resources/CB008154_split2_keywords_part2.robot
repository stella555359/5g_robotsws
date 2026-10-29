*** Settings ***
Documentation
...    author:    Marta Gal
...    contact:   marta.gal@nokia.com

Resource    ../../../common_resources/certificates/certificates.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/alarms/alarm.robot
Resource    ../../../common_resources/binary_files/binary_files.robot
Resource    ../../../common_resources/netact/netact_operations.robot
Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/connections/connections.robot

Library     SSHLibrary

*** Variable ***
${cert_expired_pem}        ${CURDIR}/Split2/cert_expired.pem
${cert_valid_pem}          ${CURDIR}/Split2/8154.pem
${cert_pem_fingerprint}    12:A6:17:17:8A:F9:E3:57:1C:DB:69:22:16:33:5D:6A:01:57:51:51
${cert_expired_p12_hex}    ${CURDIR}/Split2/8154_expired.txt
${cert_expired_p12}        8154_expired.p12
${cert_p12_hex}            ${CURDIR}/Split2/cert_8154.txt
${cert_p12}                8154.p12
${P12PASSWORD}             YT_xk39b
${logs_dest}=              ${OUTPUT_DIR}/Logs_ATL.xml
${logs_dest2}=             ${OUTPUT_DIR}/Logs2_ATL.xml
${ATL_event_fail}=         <operation>ADD_CERTIFICATE_IND</operation>\n<logStatus>Failure</logStatus>
${ATL_event_pass}=         <operation>ADD_CERTIFICATE_IND</operation>\n<logStatus>Success</logStatus>
${ATL_event_del_fail}=     <operation>DEL_CERTIFICATE_IND</operation>\n<logStatus>Success</logStatus>


*** Keywords ***
CB008154_Manual_install_additional_CA_Certificate_from_WebEM_to_cOAM_BTS
    ${installation_result}=  Run Keyword And Ignore Error   Install Certificate On BTS
    ...                           cert_file=${cert_expired_pem}
    ...                           cert_type=AdditionalCa
    ...                           cert_format=PEM
    Log    ${installation_result}    console=true
    Should Contain     '${installation_result}'   Certificate validation - Certificate expired

    Install Certificate On BTS    cert_file=${cert_valid_pem}
    ...                           cert_type=AdditionalCa
    ...                           cert_format=PEM

    Clear Certificates
    Sleep    600    reason=Wait more time to be sure that logs have been generated
    ${connection}=    Connect to NetAct
    Get RUEM logs from NetAct     ${connection}    MRBTS-$${BTS_ID}    ${logs_dest}
    ${file}=    OperatingSystem.Get File     ${logs_dest}
    Get RUEM logs from NetAct     ${connection}    MRBTS-$${BTS_ID}    ${logs_dest}
    ${file}=    OperatingSystem.Get File     ${logs_dest}
    Should Contain    ${file}      ${ATL_event_fail}
    Should Contain   ${file}    ${ATL_event_pass}
    [Teardown]    Disconnect from NetAct    ${connection}

CB008154_Manual_install_Operator_Certificate_from_WebEM_to_cOAM_BTS
    Generate Binary File From HEX String    hex_string_file=${cert_expired_p12_hex}
    ...                                     binary_file_name=8154_expired.p12

    ${installation_result}=  Run Keyword And Ignore Error   Install Certificate On BTS
    ...                           cert_file=${cert_expired_p12}
    ...                           cert_type=BtsTrustChain
    ...                           cert_format=P12
    ...                           p12password=${P12PASSWORD}
    Log    ${installation_result}    console=true
    Should Contain     '${installation_result}'    Certificate validation - Certificate expired

    Generate Binary File From HEX String    hex_string_file=${cert_p12_hex}
    ...                                     binary_file_name=8154.p12
    Install Certificate On BTS    cert_file=${cert_p12}
    ...                           cert_type=BtsTrustChain
    ...                           cert_format=P12
    ...                           p12password=${P12PASSWORD}
    Clear Certificates
    Sleep    600    reason=Wait more time to be sure that logs have been generated
    ${connection}=    Connect to NetAct
    Get RUEM logs from NetAct     ${connection}    MRBTS-$${BTS_ID}    ${logs_dest2}
    ${file}=    OperatingSystem.Get File   ${logs_dest2}
    Get RUEM logs from NetAct     ${connection}    MRBTS-$${BTS_ID}    ${logs_dest2}
    ${file}=    OperatingSystem.Get File   ${logs_dest2}
    Should Contain   ${file}    ${ATL_event_fail}
    Should Contain   ${file}    ${ATL_event_pass}
    [Teardown]    Disconnect from NetAct    ${connection}


CB008154_Manual_remove_CA_Certificate_from_cOAM_BTS_on_NMS
    Install Certificate On BTS    cert_file=${cert_valid_pem}
    ...                           cert_type=AdditionalCa
    ...                           cert_format=PEM

    ${connection}=    Connect to NetAct
    Delete Certificate With NetAct      connection=${connection}     fingerprint=${cert_pem_fingerprint}
    Sleep    1800    reason=Wait more time to be sure that logs have been generated
    ${connection}=    Connect to NetAct
    Get RUEM logs from NetAct     ${connection}    MRBTS-$${BTS_ID}    ${logs_dest}
    ${file}    OperatingSystem.Get File   ${logs_dest}
    Should Contain   ${file}    ${ATL_event_del_fail}

    [Teardown]    Disconnect from NetAct    ${connection}
