*** Settings ***
Documentation    Author: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com
...              Maintainer: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com
Library             ta_emss
Library             Collections
Library             OperatingSystem

*** Variables ***
${EMSSIM_CONNECTION_TIMEOUT}=      300
${EMSSIM_BTS_CONNECTION_TIMEOUT}=  300
${EMSSIM_WAIT_CONNECTED}=          ${True}
${EMSSIM_WAIT_DISCOVERED}=         ${True}
${EMSSIM_ENB_ID}=                  1
${EMSSIM_HOST}=                    10.0.1.1
${EMSSIM_PORT}=                    4001
${EMSSIM_COMMAND_PARAMS}=          ${None}
${EMSSIM_COMMAND_TIMEOUT}=         ${None}
${EMSSIM_COMMAND_FULL_DATA}=       False
${EMSSIM_COMMAND_CAN_FAIL}=        False
${EMSSIM_LOG_DIR}=                 /home/flexi1/emssim_log.log
${EMSSIM_LOG_LEVEL}=               5
${EMSSIM_OUTPUT_LOG_DIR}=          ${EMPTY}

*** Keywords ***
EMSSIM All Cells Should Be Enabled
    [Arguments]    ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.All Cells Should Be Enabled    enb_id=${enb_id}

EMSSIM Check If Attribute Exists
    [Arguments]    ${object_name}
    ...            ${attribute}
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Check If Attribute Exists    object_name=${object_name}
    ...                                  attribute=${attribute}
    ...                                  enb_id=${enb_id}

EMSSIM Check If Object Exists
    [Arguments]    ${object_name}
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Check If Object Exists    object_name=${object_name}
    ...                               enb_id=${enb_id}

EMSSIM Check if message exists in log
    [Arguments]    ${message}
    ...            ${log_dir}=${EMSSIM_LOG_DIR}
    Log  Checking EMSSIM console for ${message}    console=yes
    ${log_file_content}=  Run  cat ${log_dir}
    Should Contain  ${log_file_content}  ${message}

EMSSIM Clear Alarm History
    [Arguments]    ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Clear Alarm History    enb_id=${enb_id}

EMSSIM Check If There Are Number Of Occurrences Of Fault With Alarm In EMSS
    [Documentation]
    ...    Author: Monika Kurzyp
    [Arguments]     ${fault_id}
    ...             ${alarm_number}
    ...             ${number_of_occurrences}

    @{alarms}=   ta_emss.Get Alarm History
    ${count}=   Set Variable      0
    FOR  ${item}   IN    @{alarms}
        ${fault}=   Get From Dictionary   ${item}   FAULT ID
        ${ID}=   run keyword if   ${fault}==${fault_id}   Get From Dictionary   ${item}   ID
        ${object}=  run keyword if   ${fault}==${fault_id}   Get From Dictionary   ${item}   OBJECT
        ${count} =  run Keyword If    ${ID}==${alarm_number}    Set Variable  ${count}+1     ELSE     Set Variable    ${count}
        ${number_of_alarms}=   Evaluate    ${count}
    END
	Should Be Equal    ${number_of_alarms}   ${${number_of_occurrences}}

EMSSIM Enb Should Be OnAir
    [Arguments]    ${enb_id}=${EMSSIM_ENB_ID}
    ta_emss.Enb Should Be Onair    enb_id=${enb_id}

EMSSIM Get Enb Active Alarms
    [Arguments]    ${criteria}=ID
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    ${alarm_list}=  ta_emss.Get Enb Active Alarms As String Of Ids    criteria=${criteria}
    ...                                                               enb_id=${enb_id}
    [Return]    ${alarm_list}

EMSSIM Get Enb Active Faults
    [Arguments]    ${retry_limit}=3
    ...            ${retry_sleep}=30
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    @{alarm_list}=    ta_emss.Get Enb Active Alarms    retry_limit=${retry_limit}
    ...                                                retry_sleep=${retry_sleep}
    ...                                                enb_id=${enb_id}
    [Return]    @{alarm_list}

EMSSIM Get Faults History
    [Arguments]    ${enb_id}=${EMSSIM_ENB_ID}
    @{alarm_list}=    ta_emss.Get Alarm History    enb_id=${enb_id}
    [Return]    @{alarm_list}

EMSSIM Get LNBTS Object Name
    [Arguments]    ${enb_id}=${EMSSIM_ENB_ID}
    ${lnbts_name}=    Get LNBTS Object Name    enb_id=${enb_id}
    [Return]    ${lnbts_name}

EMSSIM Perform Software Rollback
    EMSSIM Run Emssim Command  command=sw_rollback
    ...                        timeout=720

EMSSIM Perform Software Update With Activation
     [Arguments]    ${software_path}
     ...            ${delay_after}=30
     ...            ${enb_id}=${EMSSIM_ENB_ID}
     ta_emss.Perform Software Update    target=${software_path}
     ...                                delay_after=${delay_after}
     ...                                enb_id=${enb_id}

EMSSIM Perform Software Update Without Activation
     [Arguments]    ${software_path}
     ...            ${command}=sw_update
     ...            ${timeout}=720
     ta_emss.Run Emssim Command  command=${command}
     ...                         params=${software_path} 0
     ...                         timeout=${timeout}

EMSSIM Run Emssim Command
     [Arguments]    ${command}
     ...            ${params}=${EMSSIM_COMMAND_PARAMS}
     ...            ${timeout}=${EMSSIM_COMMAND_TIMEOUT}
     ...            ${get_full_data}=${EMSSIM_COMMAND_FULL_DATA}
     ...            ${can_fail}=${EMSSIM_COMMAND_CAN_FAIL}
     ...            ${enb_id}=${EMSSIM_ENB_ID}
     ta_emss.Run Emssim Command  command=${command}
     ...                         params=${params}
     ...                         timeout=${timeout}
     ...                         get_full_data=${get_full_data}
     ...                         can_fail=${can_fail}
     ...                         enb_id=${enb_id}

EMSSIM Setup Emssim
    [Arguments]    ${timeout}=${EMSSIM_CONNECTION_TIMEOUT}
    ...            ${bts_timeout}=${EMSSIM_BTS_CONNECTION_TIMEOUT}
    ...            ${wait_connected}=${EMSSIM_WAIT_CONNECTED}
    ...            ${wait_discovered}=${EMSSIM_WAIT_DISCOVERED}
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    ...            ${host}=${EMSSIM_HOST}
    ...            ${port}=${EMSSIM_PORT}
    ...            ${log_dir}=${EMSSIM_LOG_DIR}
    ...            ${log_level}=${EMSSIM_LOG_LEVEL}
    ta_emss.Setup EMSS    timeout=${timeout}
    ...                   bts_timeout=${bts_timeout}
    ...                   wait_connected=${wait_connected}
    ...                   wait_discovered=${wait_discovered}
    ...                   enb_id=${enb_id}
    ...                   host=${host}
    ...                   port=${port}
    ta_emss.Logging Stop
    EMSSIM Run Emssim Command  command=slog
    ...                        params=${log_dir} ${log_level}


EMSSIM Software On Active Partition Should Be
    [Arguments]    ${software_version}
    EMSSIM Software Version Should Be  software_version=${software_version}
    ...                                partition=Active

EMSSIM Software On Passive Partition Should Be
    [Arguments]    ${software_version}
    EMSSIM Software Version Should Be  software_version=${software_version}
    ...                                partition=Passive

EMSSIM Software Version Should Be
    [Arguments]    ${software_version}
    ...            ${partition}
    ta_emss.Software Version Should Be    version=${software_version}
    ...                                   type=${partition}
    ...                                   enb_id=${EMSSIM_ENB_ID}

EMSSIM Teardown Emssim
    [Arguments]    ${output_log_dir}=${EMSSIM_OUTPUT_LOG_DIR}
    ...            ${emssim_log_dir}=${EMSSIM_LOG_DIR}
    ...            ${enb_id}=${EMSSIM_ENB_ID}
    EMSSIM Run Emssim Command  command=slog
    ta_emss.Teardown EMSS    enb_id=${enb_id}
    Run Keyword If  '${output_log_dir}'!='${EMPTY}'
    ...  OperatingSystem.Copy File  ${emssim_log_dir}  ${output_log_dir}
