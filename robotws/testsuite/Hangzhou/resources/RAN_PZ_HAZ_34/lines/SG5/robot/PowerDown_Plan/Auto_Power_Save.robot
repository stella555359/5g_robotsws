*** Settings ***
Suite Setup          PB Suite Setup
Suite Teardown       PB Suite Teardown
Test Setup           PB Test Setup
Test Teardown        PB Test Teardown
Test Timeout         30 min

Library    String
Library    Process
Library    BuiltIn
Library    DateTime
Library    Collections
Library    OperatingSystem
Library    lib/csvtodict.py
Library    robot.libraries.DateTime
Library    taf.pdu    WITH NAME    pdu

Documentation
...    HW Auto Power Off/On to save cost according to AutoPowerOff.csv

Force Tags    5G_RAN_TDD

*** Variables ***
${TS_LOG_PATH_BASE}      %{HOME}/PowerPlan_SG5/CronTask
${csv_file_path}         %{HOME}/PowerPlan_SG5/AutoPowerOff_weekend.csv
${is_powerOFF}           ${True}
${is_powerON}            ${False}

*** Test Cases ***
Auto_Power_Down_Plan
    Run Keyword If   ${is_powerOFF}    Auto_Power_OFF_Plan
    ...    ELSE IF   ${is_powerON}     Auto_Power_ON_Plan
    ...    ELSE       log to console   \nDo Nothing!

*** Keywords ***
Auto_Power_OFF_Plan
    ${data}    get_pb_info_from_csv    path=${csv_file_path}
    ${length}    Get Length    ${data}
    Should Be True    ${length}>=1   msg=no info get from csv file
    ${result_list}    create list
    FOR   ${id}   IN RANGE   ${length}
        append to list    ${result_list}    ${id}
    END
    FOR   ${index}   IN RANGE   ${length}
        ${msg_console}   Set Variable   ${data}[${index}][TL_NAME]-${data}[${index}][HW_Component]-${data}[${index}][HW_index]
        log to console  \nStart to power off ${msg_console}
        ${mode}    Set Variable If    '${data}[${index}][PB_MODE]'=='HBTE'   HBTE
        ...    '${data}[${index}][PB_MODE]'=='TopYoung'   TopYoung
        ...    '${data}[${index}][PB_MODE]'=='FACOM'   FACOM
        ...     Undefined
        ${result}    Run Keyword And Return Status    Perform Power Off    pdu_model=${mode}
        ...      pdu_ip=${data}[${index}][PB_IP]
        ...      pdu_port=${data}[${index}][PB_PORT]
        ${data_with_result}    copy dictionary    ${data}[${index}]
        ${result}    Set Variable If   '${result}'=='True'   Pass   Fail
        ${result}    Set Variable    Pass
        Set To Dictionary   ${data_with_result}   Result=${result}
        log    ${data_with_result}
        set list value   ${result_list}   index=${index}   value=&{data_with_result}
        sleep   5s
    END
    update_pb_info_to_csv    source_path=${csv_file_path}
    ...                      target_path=${SAVE LOG DIRECTORY}/AutoPowerOff_result.csv
    ...                      tl_list=${result_list}
    log to console    \nPower OFF results stored in ${SAVE LOG DIRECTORY}/AutoPowerOff_result.csv


Auto_Power_ON_Plan
    ${data}    get_pb_info_from_csv    path=${csv_file_path}
    ${length}    Get Length    ${data}
    Should Be True    ${length}>=1   msg=no info get from csv file
    ${result_list}    create list
    FOR   ${id}   IN RANGE   ${length}
        append to list    ${result_list}    ${id}
    END
    FOR   ${index}   IN RANGE   ${length}
        ${msg_console}   Set Variable   ${data}[${index}][TL_NAME]-${data}[${index}][HW_Component]-${data}[${index}][HW_index]
        log to console  \nStart to power on ${msg_console}
        ${mode}    Set Variable If    '${data}[${index}][PB_MODE]'=='HBTE'   HBTE
        ...    '${data}[${index}][PB_MODE]'=='TopYoung'   TopYoung
        ...    '${data}[${index}][PB_MODE]'=='FACOM'   FACOM
        ...     Undefined
        ${result}    Run Keyword And Return Status    Perform Power On    pdu_model=${mode}
        ...      pdu_ip=${data}[${index}][PB_IP]
        ...      pdu_port=${data}[${index}][PB_PORT]

        ${data_with_result}    copy dictionary    ${data}[${index}]
        ${result}    Set Variable If   '${result}'=='True'   Pass   Fail
        ${result}    Set Variable    Pass
        Set To Dictionary   ${data_with_result}   Result=${result}
        log    ${data_with_result}
        set list value   ${result_list}   index=${index}   value=&{data_with_result}
        sleep   2s
    END
    update_pb_info_to_csv    source_path=${csv_file_path}
    ...                      target_path=${SAVE LOG DIRECTORY}/AutoPowerOn_result.csv
    ...                      tl_list=${result_list}
    log to console    \nPower ON results stored in ${SAVE LOG DIRECTORY}/AutoPowerOn_result.csv

PB Suite Setup
    log to console    \n*** Suite Setup ***
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}

PB Test Setup
    log to console    \n*** Test Setup***
    ${tc_name}=    Replace String    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${case_log_path}    Join path    ${SUITE_LOG_PATH}    TC_${tc_name}
    Set test variable    ${TS_CASE_LOG_PATH}    ${case_log_path}
    Create directory    ${TS_CASE_LOG_PATH}
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    log to console  case log path:${TS_CASE_LOG_PATH}

PB Suite Teardown
    log to console    \n*** Suite Teardown ***
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

PB Test Teardown
    log to console    \n*** Test Teardown ***

Perform Power Off
    [Arguments]   ${pdu_model}   ${pdu_ip}   ${pdu_port}   ${alias}=pdu
    pdu.setup_pdu    model=${pdu_model}   host=${pdu_ip}    alias=${alias}
    pdu.power_off    port=${pdu_port}    pdu_device=${alias}

Perform Power On
    [Arguments]   ${pdu_model}   ${pdu_ip}   ${pdu_port}   ${alias}=pdu
    pdu.setup_pdu    model=${pdu_model}   host=${pdu_ip}    alias=${alias}
    pdu.power_on     port=${pdu_port}    pdu_device=${alias}

