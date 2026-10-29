*** Settings ***
Documentation
...  author:   Patryk Tatarek
...  contact:  patryk.tatarek@nokia.com

Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/netact/netact_operations.robot
Resource    ../../../common_resources/certificates/certificates.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/commissioning/commissioning.robot

Library     ../../../common_resources/admin/admin_utils.py
Library     set_ntp.py   WITH NAME  ntp

*** Variables ***
${logs_dest}=          ${OUTPUT_DIR}/ATL_logs.xml
${ca_subject_name}=    CN=CB007672

*** Keywords ***
NTP Time Fluctuation DST Change
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1
    ...                            param_name=timeZone
    ...                            param_value=(GMT+3) Europe/Moscow
    Wait until keyword succeeds    10min  20s    Wait until BTS reach Configured or OnAir state
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1
    ...                            param_name=timeZone
    ...                            param_value=(GMT+1) Europe/Warsaw
    Wait until keyword succeeds    10min  20s    Wait until BTS reach Configured or OnAir state
    Sleep    600                   reason=Wait more time to be sure that logs have been generated
    ${connection}=                 Connect to NetAct
    Get RUEM logs from NetAct      ${connection}    MRBTS-${BTS_ID}    ${logs_dest}
    Sleep    300                   reason=Wait more time to be sure that logs have been generated
    Get RUEM logs from NetAct      ${connection}    MRBTS-${BTS_ID}    ${logs_dest}
    ${dst_log}=                    Grep File    ${logs_dest}    DST Status: Not Applied
    Should Contain                 ${dst_log}     DST Status: Not Applied
    [Teardown]                     Disconnect from NetAct    ${connection}

Time Fluctuation Offset 1000ms
    ${connection}=       Connect to ADMIN
    ${new_scf_path}=     set variable    ${EXECDIR}/new_scf.xml
    ${base_scf_path}=    Download SCF
    ntp.prepare_NTP_configuration             ${base_scf_path}   ${new_scf_path}
    Load SCF and update RU SW if necessary    ${new_scf_path}
    Wait until keyword succeeds    10min  20s    Wait until BTS reach Configured or OnAir state
    Sleep    900                   reason=Wait more time to be sure that logs have been generated
    ${conn}=                       Connect to NetAct
    Get RUEM logs from NetAct      ${conn}    MRBTS-${BTS_ID}    ${logs_dest}
    ${offset_above_log}=           Grep File    ${logs_dest}    offset above 1000ms
    ${offset_below_log}=           Grep File    ${logs_dest}    offset below 1000ms
    Should Contain                 ${offset_above_log}      offset above 1000ms
    Should Contain                 ${offset_below_log}      offset below 1000ms
    [Teardown]    Run Keywords     Disconnect from ADMIN     ${connection}
    ...           AND              Disconnect from NetAct    ${conn}
    ...           AND              Load SCF and update RU SW if necessary    ${base_scf_path}
    ...           AND              Wait until keyword succeeds    10min  20s
    ...                            Wait until BTS reach Configured or OnAir state

X.509 Enrollment And Renewal Logs
    ${connection}=    Connect to ADMIN
    Configure CMP     ca_subject_name=${ca_subject_name}    connection=${connection}
    Initialize Certificates
    FOR    ${i}    IN RANGE    1000
         ${PING}=    Run    ping -c 2 192.168.255.129
         ${Exit}=    Run Keyword And Return Status    Should Contain    ${PING}    100% packet loss
         Exit For Loop If    ${Exit}==True
    END
    Wait until keyword succeeds    30 min  60sec  Check if BTS status is Configured or OnAir
    Sleep    900                   reason=Wait more time to be sure that logs have been generated
    ${conn}=                       Connect to NetAct
    Get RUEM logs from NetAct      ${conn}    MRBTS-${BTS_ID}    ${logs_dest}
    ${renewal_log}=                Grep File    ${logs_dest}    Automatic certificate enrolment is successful
    Should Contain                 ${renewal_log}    Automatic certificate enrolment is successful
    [Teardown]                     Run Keywords      Disconnect from NetAct    ${conn}
    ...    AND                     Run Keyword and Ignore Error    Disconnect from ADMIN    ${connection}

X.509 Enrollment And Renewal Logs for ABIQ
    ${connection}=    Connect to ADMIN
    Configure CMP     ca_subject_name=${ca_subject_name}    connection=${connection}
    Initialize Certificates
    FOR    ${i}    IN RANGE    1000
         ${PING}=    Run    ping -c 2 192.168.255.129
         ${Exit}=    Run Keyword And Return Status    Should Contain    ${PING}    100% packet loss
         Exit For Loop If    ${Exit}==True
    END
    Wait until keyword succeeds    30 min  60sec  Check if BTS status is Configured or OnAir
    Sleep    900                   reason=Wait more time to be sure that logs have been generated
    ${conn}=                       Connect to NetAct
    Get RUEM logs from NetAct      ${conn}    MRBTS-${BTS_ID}    ${logs_dest}
    ${renewal_log}=                Grep File    ${logs_dest}    Automatic certificate enrolment is successful
    Should Contain                 ${renewal_log}    Automatic certificate enrolment is successful
    [Teardown]                     Run Keywords    Disconnect from NetAct    ${conn}
    ...    AND                     Run Keyword and Ignore Error    Disconnect from ADMIN    ${connection}

X 509 Enrollment And Renewal Logs ASIM
    ${connection}=    Connect to ADMIN
    Configure CMP     ca_subject_name=${ca_subject_name}    connection=${connection}
    ${cert_status}=    Run Keyword and Return Status    Initialize Certificates
    FOR    ${i}    IN RANGE    500
         ${PING}=    Run    ping -c 2 192.168.255.129
         ${Exit}=    Run Keyword And Return Status    Should Contain    ${PING}    100% packet loss
         Exit For Loop If    ${Exit}==True
    END
    Wait until keyword succeeds    30 min  60sec  Check if BTS status is Configured or OnAir
    Sleep    900                   reason=Wait more time to be sure that logs have been generated
    ${conn}=                       Connect to NetAct
    Get RUEM logs from NetAct      ${conn}    MRBTS-${BTS_ID}       ${logs_dest}
    Run Keyword If                 ${cert_status}==True    Initialize status True     ${logs_dest}
    ...         ELSE                                       Initialize status False    ${logs_dest}
    [Teardown]                     Run Keywords    Disconnect from NetAct    ${conn}
    ...    AND                     Run Keyword and Ignore Error    Disconnect from ADMIN    ${connection}

Initialize status True
    [Arguments]    ${logs}
    ${renewal_log}=    Grep File    ${logs}    Automatic certificate enrolment is successful
    Should Contain    ${renewal_log}    Automatic certificate enrolment is successful

Initialize status False
    [Arguments]    ${logs}
    ${renewal_log}=    Grep File    ${logs}    Automatic certificate enrolment is failed
    Should Contain    ${renewal_log}    Automatic certificate enrolment is failed
