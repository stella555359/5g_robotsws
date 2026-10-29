*** Settings ***
Documentation    KW to downloads, extracts, and merges syslog files from vCU and vDU.

Library           file_operation.py

*** Variables ***
${SYSLOG_PORT}               50108
${SYSLOG_API_ENDPOINT}       /api/trc/v1/log_data
${SUITE_LOGS_DIR_PATH}       /tmp/suite_logs
${SSH_K8S_PASSWORD}          your_password_here

*** Keywords ***
Download vCU Syslog
    [Documentation]    Downloads and merges syslog for vCU.
    ${path}=    Download Syslog
    ...    vCU    ${CRAN_VCU}    ${SSH_VCU_IP}
    ...    common_vcu.Connect To vCU K8s Master Node With Tenant
    ...    syslog_vcu
    [Return]    ${path}

Download vDU Syslog
    [Documentation]    Downloads and merges syslog for vDU.
    ${path}=    Download Syslog
    ...    vDU    ${CRAN_VDU}    ${SSH_VDU_IP}
    ...    common_vdu.Connect To vDU K8s Master Node With Tenant
    ...    syslog_vdu
    [Return]    ${path}

Download Syslog
    [Arguments]    ${TYPE}    ${CRAN_NS}    ${SSH_IP}    ${ALIAS_KEYWORD}    ${LOG_FILE_NAME}
    Run    mkdir -p ${SUITE_LOGS_DIR_PATH}/${TYPE}
    ${alias}=    Run Keyword    ${ALIAS_KEYWORD}

    ${cmd}=    Set Variable    kubectl get po -n ${CRAN_NS} -l app.kubernetes.io/name=logservice -o=jsonpath='{..podIP}'
    ${output}=    issh.Execute    command=${cmd}    alias=${alias}
    ${ip_address}=    Get Regexp Matches    ${output}    \\d+\\.\\d+\\.\\d+\\.\\d+

    IF    '${TYPE}' == 'vCU'
        ${logservice_cmd}=    Set variable    kubectl get pod -n ${CRAN_VCU} | grep "logservice" | awk '{print $1}'
        ${logservice}=    issh.Execute    command=${logservice_cmd}    alias=${alias}
        ${logservice}=    Get Regexp Matches    ${logservice}    [a-z0-9-]+logservice-[a-z0-9]+-[a-z0-9]+
        ${curl_cmd_vcu}=    Catenate    SEPARATOR=
            ...    kubectl exec -n ${CRAN_NS} -c ctr-logprocessor ${logservice[0]}${SPACE}
            ...    -- curl -X GET "http://${ip_address[0]}:${SYSLOG_PORT}${SYSLOG_API_ENDPOINT}" -H "Accept-Encoding: gzip"${SPACE}
            ...    > /var/home/core/${LOG_FILE_NAME}.zip
        ${curl_cmd}=    Set Variable    ${curl_cmd_vcu}

    ELSE IF    '${TYPE}' == 'vDU'
        ${pod_line}=    issh.Execute    oc get pods -n ${CRAN_VDU} -o wide | grep logservice
        ${columns}=     Split String    ${pod_line}
        ${node}    Set Variable    ${None}

        FOR    ${col}    IN    @{columns}
            ${col_clean}=    Evaluate    '''${col}'''.strip()
            ${found_master}=    Run Keyword And Return Status    Should Contain    ${col_clean}    master
            ${found_worker}=    Run Keyword And Return Status    Should Contain    ${col_clean}    worker
            ${node}=    Run Keyword If    ${found_master} or ${found_worker}    Set Variable    ${col_clean}
            Exit For Loop If    '${node}' != '${None}'
        END

        IF    '${node}' != 'master0'
            ${nodes_out}=   issh.Execute    oc get nodes -o wide
            ${lines}=       Split To Lines   ${nodes_out}
            ${target_line}=    Set Variable    None
            FOR    ${line}    IN    @{lines}
                Run Keyword If    '${node}' in '${line}'    Set Test Variable    ${target_line}    ${line}
                Run Keyword If    '${node}' in '${line}'    Exit For Loop
            END
            ${ip_address_for_worker}=    Get Regexp Matches    ${target_line}    \\d+\\.\\d+\\.\\d+\\.\\d+
            ${ip}=            Set Variable           ${ip_address_for_worker[0]}
            ${curl_cmd_vdu}=    Set Variable
         ...  curl -X GET 'http://${ip_address[0]}:${SYSLOG_PORT}${SYSLOG_API_ENDPOINT}' -H 'accept: application/octet-stream' -o ${LOG_FILE_NAME}.zip
            ${ssh_cmd}=         Set Variable    ssh core@${ip} "${curl_cmd_vdu}"
            issh.Execute        ${ssh_cmd}
            ${curl_cmd}=        Set Variable    rsync -av --remove-source-files core@${ip}:/var/home/core/${LOG_FILE_NAME}.zip /var/home/core/
        ELSE
            ${curl_cmd_vdu}=    Set Variable
         ...  curl -X GET "http://${ip_address[0]}:${SYSLOG_PORT}${SYSLOG_API_ENDPOINT}" -H "accept: application/octet-stream" -o ${LOG_FILE_NAME}.zip
            ${curl_cmd}=        Set Variable    ${curl_cmd_vdu}
        END
    END

    issh.Execute    command=${curl_cmd}    alias=${alias}

    ${rsync_cmd}=    Catenate    SEPARATOR=
    ...    sshpass -p '${SSH_K8S_PASSWORD}' rsync -avz --remove-source-files${SPACE}
    ...    core@${SSH_IP}:/var/home/core/${LOG_FILE_NAME}.zip${SPACE}
    ...    ${SUITE_LOGS_DIR_PATH}/${TYPE}

    ${rsync_cmd_check}=    Run    ${rsync_cmd}

    ${contains_something_nasty}=    Run Keyword And Return Status    Should Match Regexp    ${rsync_cmd_check}    .*DOING.*NASTY.*

    IF    ${contains_something_nasty}
        ${pattern}=    Set Variable    ssh-keygen -f ".*?known_hosts" -R ".*?"
        ${fix_cmd}=    Get Regexp Matches    ${rsync_cmd_check}    ssh-keygen -f ".*?known_hosts" -R ".*?"
        Log To Console    Executing fix: ${fix_cmd[0]}
        ${fix_cmd}    Set Variable    ${fix_cmd[0]}
        ${fix_out}=    Run    ${fix_cmd}
        Log To Console    ${fix_out}
        ${rsync_cmd_check}=    Run    ${rsync_cmd}
    END

    Run Keyword And Ignore Error    Disconnect Interactive Connection
    Unpack File To Destination    ${SUITE_LOGS_DIR_PATH}/${TYPE}/${LOG_FILE_NAME}.zip    ${SUITE_LOGS_DIR_PATH}/${TYPE}/extracted

    Unpack Syslog Zips If Needed    ${TYPE}

    ${file_list}=    OperatingSystem.List Files In Directory    ${SUITE_LOGS_DIR_PATH}/${TYPE}
    Collections.Sort List    ${file_list}
    Collections.Reverse List    ${file_list}
    Run    rm -rf ${SUITE_LOGS_DIR_PATH}/${TYPE}/extracted

    ${result}=    Merge Text Files
    ...  ${SUITE_LOGS_DIR_PATH}/${TYPE}
    ...  ${SUITE_LOGS_DIR_PATH}/${TYPE}/full_${TYPE}_syslog
    ...  "ISO-8859-1"
    [Return]    ${SUITE_LOGS_DIR_PATH}/${TYPE}/full_${TYPE}_syslog

Unpack Syslog Zips If Needed
    [Arguments]    ${TYPE}
    ${files}=    OperatingSystem.List Files In Directory    ${SUITE_LOGS_DIR_PATH}/${TYPE}/extracted    *.zip
    FOR    ${file}    IN    @{files}
        ${is_latest}=    Run Keyword And Ignore Error    Should Contain    ${file}    latest
        ${status1}=    Get From List    ${is_latest}    0
        ${is_err}=    Run Keyword And Ignore Error    Should Contain    ${file}    err_
        ${status2}=    Get From List    ${is_err}    0
        Run Keyword If    '${status1}' == 'FAIL' and '${status2}' == 'FAIL'
        ...    Unpack File To Destination    ${SUITE_LOGS_DIR_PATH}/${TYPE}/extracted/${file}    ${SUITE_LOGS_DIR_PATH}/${TYPE}
        Run Keyword If    '${status1}' == 'PASS' and '${status2}' == 'FAIL'
        ...    Unpack File To Destination    ${SUITE_LOGS_DIR_PATH}/${TYPE}/extracted/${file}    ${SUITE_LOGS_DIR_PATH}/${TYPE}
    END
