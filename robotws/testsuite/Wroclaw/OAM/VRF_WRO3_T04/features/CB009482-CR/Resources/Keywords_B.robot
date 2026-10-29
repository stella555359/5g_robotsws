*** Settings ***
Documentation
...    author:          Julia Wijas
...    contact:         julia.wijas@nokia.com
...    Description:     Keywords for TestCases to feature CB009482

Library     BuiltIn
Library     String
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../cloud_common_resources/logs/logs.robot
Resource    ../../../../cloud_common_resources/certificates/certificates.robot
Resource    ../../../../cloud_common_resources/resets/resets.robot
Library     SSHLibrary


*** Variables ***
${SYSLOG_LOGIN}             trssec
${SYSLOG_PASS}              YT_xk39b
${SYSLOG_IP}=               10.42.63.247

*** Keywords ***
TLS Configuration
    [Documentation]    Keyword configure TLS with proper values
    [Arguments]     ${tls12Enabled}     ${actEnableTLSv13}      ${oamTls}       ${hw_type}
    ${MRBTS}=    Set Variable If    "${hw_type}"=="vDU"    ${MRBTS}   ${MRBTS_CU}
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=tls12Enabled
    ...                             param_value=${tls12Enabled}
    ...                             hw_type=${hw_type}
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=actEnableTLSv13
    ...                             param_value=${actEnableTLSv13}
    ...                             hw_type=${hw_type}
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=oamTls
    ...                             param_value=${oamTls}
    ...                             hw_type=${hw_type}

Get Cert ID
    [Arguments]         ${cert}     ${cert_type}
    ${cert_tyoe}=       Run Keyword If        '${cert_type}'=='TA'      Set Variable     CA
    ...                 ELSE                  Set Variable      NE
    ${cert_string}=     Convert to String      ${cert}
    ${cert_id}=         Get Regexp Matches    ${cert_string}    ${cert_tyoe}CERT_R[0-9][0-9']
    ${cert_id}          Convert to String      ${cert_id}
    ${cert_id}=         Remove String         ${cert_id}    '
    ${cert_id}=         Remove String         ${cert_id}    "
    ${cert_id}=         Remove String         ${cert_id}    [
    ${cert_id}=         Remove String         ${cert_id}    ]
    [Return]            ${cert_id}

Checke Details of Alarm
    [Arguments]      ${fault_id}        ${error}            ${hw_type}
    ${alarm_info}       Get Information of Active Alarms        fault_id=${fault_id}        parameter=additional_info
    ...                 hw_type=${hw_type}
    Should Contain      ${alarm_info}        ${error}

Get Information of Active Alarms
    [Documentation]    Description:    This keyword give extra information of alarm
    ...                Input:          hw_type = vCU/vDU
    ...                                fault_id = ID of fault which info will be given
    ...                                parameter = Info which will be given
    ...                Author:         julia.wijas@nokia.com
    [Arguments]     ${fault_id}         ${parameter}        ${hw_type}
    ${alarm_info}    Create List
    ${active_alarms}    Get Active Alarms From BTS      hw_type=${hw_type}
    FOR     ${alarm}    IN      @{active_alarms}[alarms]
        Run Keyword If      ${alarm}[fault_id]==${fault_id}     Append To List    ${alarm_info}    ${alarm}[${parameter}]
    END
    ${alarm_info}          Convert to String      ${alarm_info}
    ${alarm_info}=         Remove String         ${alarm_info}    [
    ${alarm_info}=         Remove String         ${alarm_info}    ]
    [Return]        ${alarm_info}

Get Apper Time of Historical Alarms
    [Arguments]     ${fault_id}         ${hw_type}
    ${apper_history_time}    Create List
    ${historical_alarms}=    Get Historical Alarms From BTS             hw_type=${hw_type}
    FOR     ${alarm}    IN      @{historical_alarms}[alarms]
        Run Keyword If      ${alarm}[fault_id]==${fault_id}   Append To List  ${apper_history_time}  ${alarm}[appear_time]
    END
    [Return]        ${apper_history_time}

Get Additional Info of Specified Historical Alarm
    [Arguments]     ${time}     ${hw_type}
    ${additional_info}      Create List
    ${historical_alarms}=    Get Historical Alarms From BTS             hw_type=${hw_type}
    FOR     ${alarm}    IN      @{historical_alarms}[alarms]
        Run Keyword If      '${alarm}[appear_time]'==${time}   Append To List   ${additional_info}    ${alarm}[additional_info]
    END
    [Return]        ${additional_info}

Teardown for Syslog and CNUM Actions
    [Arguments]   ${pid}
    Change Parameter on BTS       dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                           param_name=actRemoteSyslogTransmission
    ...                           param_value=false
    ...                           hw_type=vCU
    Change Parameter on BTS       dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                           param_name=actRemoteSyslogTransmission
    ...                           param_value=false
    ...                           hw_type=vDU
    Change Parameter on BTS       dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                           param_name=enableCnumLdapCtrlAlarm
    ...                           param_value=false
    ...                           hw_type=vCU
    Change Parameter on BTS       dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                           param_name=enableCnumLdapCtrlAlarm
    ...                           param_value=false
    ...                           hw_type=vDU
    Run keyword and ignore error    Stop and colledt PCAP from syslog server    ${pid}    test_teardown.pcap
    Run keyword and ignore error    Stop TCPdump and Download Pcap     hw_type=vDU    pod_name=oamext
    Run keyword and ignore error    Stop TCPdump and Download Pcap     hw_type=vCU    pod_name=oamext
