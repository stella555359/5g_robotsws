*** Settings ***
Documentation    Test variables and keyword resource file for Performance_Test

Library     taf.transport.ssh                            WITH NAME   ssh
Library     python/emperf_eorun_to_csv.py

Resource    ../../../resources/Common/connect.robot
Resource    performance_database.robot
Resource    performance_log_collection.robot

*** Variables ***
${EMPERF_0x1730_STARTED}    ${false}
${EMPERF_0x1731_STARTED}    ${false}
${EMPERF_0x1732_STARTED}    ${false}
${EMPERF_0x1733_STARTED}    ${false}
${emperf_remote_path}   /rom/logs
${emperf_assert_fail}   ${empty}

*** Keywords ***
Start All enabled emperfs on background
    [Arguments]    ${label}
    IF    'ENABLE_EMPERF_${label}' in $TP
        IF       "${TP['ENABLE_EMPERF_${label}']}"=="null"   RETURN
    ELSE
        RETURN    ${none}
    END


    ${container_ids}             Split String    ${TP['ENABLE_EMPERF_${label}']}    ,
    FOR   ${container_id}   IN   @{container_ids}
        Start emperf on background    ${container_id}
        Set Test Variable    ${EMPERF_${container_id}_STARTED}    ${true}
    END
    Log to console    ${empty}

Teardown all enabled emperfs
    [Arguments]    ${label}
    IF    'ENABLE_EMPERF_${label}' in $TP
        IF       "${TP['ENABLE_EMPERF_${label}']}"=="null"   RETURN
    ELSE
        RETURN    ${none}
    END

    ${emperf_db_dict}    Create Dictionary
    ${container_ids}             Split String    ${TP['ENABLE_EMPERF_${label}']}    ,
    FOR   ${container_id}   IN   @{container_ids}
        IF    not ${EMPERF_${container_id}_STARTED}   RETURN
        ${emperf_data}    Teardown emperf    ${container_id}    filename=emperf_${label}
        Set Test Variable    ${EMPERF_${container_id}_STARTED}    ${false}
        ${disps_list}    Convert disp dict to list    ${emperf_data}
        Set to Dictionary    ${emperf_db_dict}    ${container_id}=${disps_list}
    END
    IF    ${emperf_db_dict} == &{EMPTY}    RETURN   &{EMPTY}
    Insert Emperf data    ${emperf_db_dict}
    Assert emperf container    ${emperf_db_dict}
    Log to console     ${empty}
    RETURN    ${emperf_db_dict}

Convert disp dict to list
    [Arguments]    ${emperf_data}
    Remove From Dictionary     ${emperf_data}    total_row     error
    ${disp_list}    Create List
    FOR    ${data}    IN     @{emperf_data}
        ${tmp_dict}    Create Dictionary        disp_number=${data}
        ...                                     average=${emperf_data['${data}']['average']}
        ...                                     minimum=${emperf_data['${data}']['minimum']}
        ...                                     maximum=${emperf_data['${data}']['maximum']}
        Append To List      ${disp_list}    ${tmp_dict}
    END
    RETURN    ${disp_list}

Assert emperf container
    [Arguments]    ${emperf_db_dict}
    Log to console    \nEmperf Results:
    ${msg}    Format String    ${SPACE} {: >6}, {: >5}, {: >10}, {: >10}, {: >10}, {: >5}
    ...                        DISP     NAME    AVERAGE    PREVIOUS     DIFFERENCE    % DIFF
    Log to console    ${msg}
    FOR    ${container_id}    IN    @{emperf_db_dict}
        Assert emperf data    ${container_id}    ${emperf_db_dict['${container_id}']}
    END
    ${assert_str}    Catenate    """${emperf_assert_fail}"""!="${empty}"
    ...                          and ("${TP.CFG_EMPERF_TOLERANCE}" !="1"
    ...                          and "${TP.CFG_EMPERF_TOLERANCE}" !="null")
    IF    ${assert_str}
    ...   Run Keyword And Continue On Failure    BuiltIn.Fail    EMPERF Assert Failed:\n${emperf_assert_fail}
    Log to console     ${empty}


Assert emperf data
    [Arguments]    ${container_id}    ${disps_list}    ${tolerance}=${TP.CFG_EMPERF_TOLERANCE}
    IF    not ${DB_INTERFACE_RETRIEVE_ONLINE}   RETURN
    IF    "${tolerance}"!="null"
    ...    Log to console    Container: ${container_id}, t:${tolerance}, tcid: ${PREV_DB_TESTCASE_ID_EMPERF}
    ${tolerance}    Convert To Number    ${tolerance}    2
    FOR    ${disp}    IN    @{disps_list}
        ${disp_number}           Set Variable                ${disp['disp_number']}
        ${row}             Get Emperf disps from db    container=${container_id}    disp_number=${disp_number}    limit=1
        IF     "${row}"=="${none}"
            Log    Database returned empty for EMPERF: ${container_id}, ${disp_number}
            ...                                       level=WARN    console=${false}
            RETURN    ${none}
        END

        ${prev_average}          Evaluate          float(0) if "${row[0][5]}"=="${none}" else float(${row[0][5]})
        ${disp_name}             Set Variable If   "${row[0][8]}"=="${none}"    ---    ${row[0][8]}
        ${average}               Evaluate          float(0) if "${disp['average']}"=="${none}" else float(${disp['average']})

        ${difference}            Evaluate    round(${average} - ${prev_average}, 2)
        ${average_calc}          Evaluate    round(${average} - (${tolerance} * ${average}), 2)
        ${high_value}            Evaluate    ${average_calc} > ${prev_average}

        ${percent}               Evaluate    f"\{round((${difference}/${average})*100)\} %" if ${average} != 0 else ''

        ${msg}    Format String    ${SPACE} {: >6}, {: >5}, {: >10.2f}, {: >10.2f}, {: >10.2f}, {: >5}
        ...                        ${disp_number}     ${disp_name}    ${average}    ${prev_average}     ${difference}
        ...                        ${percent}

        IF    ${high_value} and "${tolerance}"!="null"
        ...               Set Suite Variable    $emperf_assert_fail    ${emperf_assert_fail}${container_id}: ${msg}\n

        IF    "${tolerance}"!="null"    Log    ${msg}        console=${True}
    END

Teardown emperf
    [Arguments]    ${container_name}    ${filename}=emperf
    ${emperf_file}       Kill Emperf and get logs       ${container_name}    filename=${filename}
    ${emperf_data}       Extract emperf EOrun values    ${emperf_file}
    ...                                                 container_name=${container_name}
    ...                                                 filename=${filename}
    RETURN    ${emperf_data}

Extract emperf EOrun values
    [Arguments]    ${emperf_file}    ${container_name}=${empty}    ${target}=${P_resultTestDir}    ${filename}=emperf
    ${_}    ${csv}        Run Keyword And Warn On Failure
    ...                   Generate EOrun CSV from emperf              ${emperf_file}
    ...                                                               ${target}/${filename}_${container_name}_eorun.csv
    ...                                                               ${container_name}

    Sleep    1s    reason=wait till csv is created
    ${_}    ${data}       Run Keyword And Warn On Failure
    ...                   Get Data EOrun values from emperf csv       ${csv}
    ...                                                               ${target}/${filename}_${container_name}_eorun_average.json
    ...                                                               ${container_name}
    RETURN    ${data}

Generate EOrun CSV from emperf
    [Arguments]    ${filepath}    ${target}    ${container}
    ${csv}        emperf_eorun_to_csv.generate_csv                    ${filepath}     ${target}    container=${container}
    perf_log_collection.Queue Logs To Turandot    ${csv}    compress=false
    RETURN    ${csv}

Get Data EOrun values from emperf csv
    [Arguments]    ${csv}    ${target}    ${container}
    ${data}    emperf_eorun_to_csv.compute_data_from_csv        ${csv}      ${target}    container=${container}
    perf_log_collection.Queue Logs To Turandot    ${target}    compress=false
    RETURN    ${data}

Delete old emperf artifacts
    [Arguments]    ${container_name}    ${entity}=gNB
    Run keyword and ignore error
    ...    Execute Command to capacity unit container    rm ${emperf_remote_path}/emperf_${container_name}.txt
    ...                                                  ${container_name}
    ...                                                  entity=${entity}

Start emperf on background
    [Arguments]    ${container_name}    ${entity}=gNB
    ${cmd}    Catenate    SEPARATOR=${SPACE}
    ...    export LD_LIBRARY_PATH=/opt/lib;
    ...    /opt/CCS_RT/em_perf_monitor -q -p -r --delta > ${emperf_remote_path}/emperf_${container_name}.txt
    Log to console    Start Emperf on ${container_name}
    Execute Command to capacity unit container    ${cmd}
    ...                                           ${container_name}
    ...                                           background_task=${True}
    ...                                           entity=${entity}
    Set Test Variable    ${T_EMPERF_STARTED_${container_name}}    ${True}

Kill Emperf and get logs
    [Arguments]    ${container_name}    ${entity}=gNB    ${target}=${P_resultTestDir}    ${filename}=emperf
    ${extension}    Set Variable        .txt
    IF    not ${T_EMPERF_STARTED_${container_name}}   RETURN
    Log to console    Stop Emperf on ${container_name}
    ${source_path}                      Set Variable    ${emperf_remote_path}/emperf_${container_name}.txt
    ${target_path}                      Set Variable    ${target}/${filename}_${container_name}${extension}

    ${pid}    Execute Command to capacity unit container    pgrep -furoot ^/opt/CCS_RT/em_perf_monitor.*
    ...                                                     ${container_name}
    ...                                                     entity=${entity}
    Execute Command to capacity unit container              kill -SIGINT ${pid.strip().rstrip('\n').rstrip('\r')}
    ...                                                     ${container_name}
    ...                                                     entity=${entity}
    Set Test Variable    ${T_EMPERF_STARTED_${container_name}}    ${False}

    ${alias}         Get Capacity Unit Alias    entity=${entity}
    Log    ${alias} -> Download file ${source_path} -> ${target_path}    console=${P_console}
    TRY
        ssh.Download File    remote_path=${source_path}    local_path=${target_path}    connection=${alias}
    EXCEPT    .*FileNotFoundError.*        type=regexp
        Fail    Emperf: ${source_path} Not found
    END
    perf_log_collection.Queue Logs To Turandot    ${target_path}
    RETURN    ${target_path}

Send command via ssh to
    [Arguments]    ${entity}    ${command}
    ${alias}         Get Capacity Unit Alias    entity=${entity}
    ${ret}           ssh.execute   ${command}    connection=${alias}
    Run Keyword And Warn On Failure    ssh.assert_exit_status    expected_exit_code=0    connection=${alias}
    RETURN         ${ret}

Execute Command to capacity unit container
    [Documentation]    Double quotes not allowed in command!
    [Arguments]    ${command}        ${container_name}    ${entity}=gNB    ${background_task}=${False}    &{kwargs}
    ${alias}         Get Capacity Unit Alias    entity=${entity}    &{kwargs}

    ${lxc_cmd}            Set Variable       lxc-attach -n ${container_name} -- bash -c "${command}"
    ${lxc_cmd_delta}=     Set Variable If    ${background_task}    nohup ${lxc_cmd} 2>&1 &    ${lxc_cmd}
    ${exec_type}=         Set Variable If    ${background_task}    ssh.send_command    ssh.execute

    Log    ${alias} -> ${lxc_cmd_delta}    console=${P_console}
    ${ret}             Run Keyword    ${exec_type}    ${lxc_cmd_delta}    connection=${alias}
    Run Keyword And Warn On Failure    ssh.assert_exit_status    expected_exit_code=0    connection=${alias}
    RETURN         ${ret}

Get Capacity Unit Alias
    [Arguments]    ${entity}=gNB    &{kwargs}
    ${alias}       Run Keyword    Connect to ${entity} Capacity Unit    &{kwargs}
    RETURN    ${alias}
