*** Settings ***
Documentation     Copyright 2017 Nokia Solution and Networks. All rights reserved
...               Author: Qiaoli-Ann.xu (NSB - CN/Hangzhou)
Resource          TAF_Common_BTS.robot
Library           emssim.py
Library           utils.py
Library           ta_emss


*** Variables ***
${json_port}=           4001
${emssim_user}=         flexi1
${bts_id}=              1
${UTE_IP}               10.0.1.1
${TA_LOG_DIRECTORY}    /home/ute/logs
${num}    0
${CERT_FILE_CA}               ${CURDIR}/certs/ca.pem
${CERT_FILE_EE}               ${CURDIR}/certs/user.pem
${CERT_FILE_PRIVATE}          ${CURDIR}/certs/privkey.pem

*** Keywords ***
Setup with Emssim
    [Arguments]    ${user}=${emssim_user}    ${port}=${json_port}    ${id}=${bts_id}    ${IP}=${UTE_IP}    ${boolean}=False
    Setup Emss    user=${user}    port=${port}    bts_id=${id}    host=${IP}    tls=${boolean}

Setup with Emssim Tls
    [Arguments]    ${user}=${emssim_user}    ${port}=${json_port}    ${id}=${bts_id}    ${IP}=${UTE_IP}    ${boolean}=True
    ta_emss.emss_proxy_ssl_cert    cert=${CERT_FILE_EE}    key=${CERT_FILE_PRIVATE}    cacert=${CERT_FILE_EE}
    Setup Emss    user=${user}    port=${port}    bts_id=${id}    host=${IP}    tls=${boolean}

Teardown with Emssim
    Stop Emss    bts_id=${bts_id}

Clear Events
    Emss Proxy Clear Events    bts_id=${bts_id}

Set Events Format
    [Arguments]    ${format}=full
    Emss Proxy Format Events    events_format=${format}    bts_id=${bts_id}

Get Events
    ${Events}    Emss Proxy Get Events    bts_id=${bts_id}
    [Return]    ${Events}

Check Emss Receive Soap Message Value
    [Arguments]    ${Events}    ${parameter}=ne3scommon:contentType    ${value}=oats
    ${timestampbegin}    Get Current Date
    ${timestampbegin}    Convert Date    ${timestampbegin}    epoch
    ${File}    Set Variable    ${TA_LOG_DIRECTORY}${/}SOAP_Log_${timestampbegin}.xml
    Append To File    ${File}    ${Events}
    ${getvalue}    Get Soap Message Value    ${File}    ${parameter}
	  Should Be Equal As Strings    ${getvalue}    ${value}
    [Return]    ${Events}

Emss Request Upload And Receive Message
    Set Events Format
    Request Upload    allconfigurationplanfile    bts_id=1
    ${Events}    Wait Until Keyword Succeeds    10s    1s    Emss Receive Message From BTS    ne3scommon:contentType    ocos
    [Return]    ${Events}

Emss Receive Message From BTS
    [Arguments]    ${parameter}=ne3scommon:contentType    ${value}=oats
    ${Events}    Get Events
    FOR    ${i}    IN    @{Events}
        ${result}=    Run Keyword And Return Status    Check Emss Receive Soap Message Value    ${i}    ${parameter}    ${value}
        ${num}=    Evaluate    ${num}+1
        Run Keyword If    '${result}'=='True'    Exit For Loop
    END
    Should Be True    ${result}
    [Return]    ${num}    ${Events[${num}]}

Emss Receive All Message From BTS
    [Arguments]    ${parameter}=ne3scommon:contentType    ${value}=oats
    ${Events}    Get Events
    ${list}    create list
    FOR    ${i}    IN    @{Events}
        ${result}=    Run Keyword And Return Status    Check Emss Receive Soap Message Value    ${i}    ${parameter}    ${value}
        ${num}=    Evaluate    ${num}+1
        Run Keyword If    '${result}'=='True'    Append To List    ${list}    ${Events[${num}]}
    END
    [Return]    ${list}

Emssim Perform Commission
    [Arguments]    ${config}={'MOC': 'NRBTS', 'ID': '1', 'inactivityTimerSA': '10'}    ${btsid}=1
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2022.3.2 | SRAN | Wu Xi | first create |
    ...
    ...    This KW is to provision delta plan
    ...
    ...    Example: the distName "MRBTS-1/LNBTS-1/LNCEL-1/DRX-0 is: 'MOC': 'DRX', 'ID': '1-0'
    Configure    ${config}    bts_id=${btsid}

Emssim Perform Commission With Plan
    [Arguments]    ${config}={'MOC': 'NRBTS', 'ID': '1', 'inactivityTimerSA': '10'}    ${btsid}=1
    [Documentation]    | Time | Release | Author | Modification |
    ...    | 2022.3.2 | SRAN | Wu Xi | first create |
    ...
    ...    This KW is to provision delta plan
    ...
    ...    Example: Configures enb using yaml file
    Configure    ${config}    bts_id=${btsid}
