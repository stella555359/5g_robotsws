*** Settings ***

Documentation    Description:  Cloud Library with commonly used keywords

Library    BuiltIn
Library    OperatingSystem
Library    Process
Library    String
Library    Collections
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu

Resource    aic_common_resources_new.robot
Resource    ./common_variables.robot

*** Keywords ***

Suite Precondition
    [Documentation]  Description:           List of precondition actions common for all testing suites${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                x ${\n}
    ...              Maintainer:            x ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com${\n}

    #Create Suite Logs Directory
    Setup Host Variables
#    Switch Power Outlet Of BTS Radio Units  #TODO: czy konieczne?

Suite Postcondition
    [Documentation]  Description:           List of postcondition actions common for all testing suites${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                x ${\n}
    ...              Maintainer:            x ${\n}
    ...              Last Modification:     xx-xx-xxxx made by xx@nokia.com${\n}

    vDU Collect Snapshot  logs_dir_path=${SUITE_LOGS_DIR_PATH}/general_logs
    vCU Collect Snapshot  logs_dir_path=${SUITE_LOGS_DIR_PATH}/general_logs
    #Collecting logs from all pods is not needed:
    #vDU Get Container Logs On All Pods  logs_dir_path=${SUITE_LOGS_DIR_PATH}/general_logs
    #vCU Get Container Logs On All Pods  logs_dir_path=${SUITE_LOGS_DIR_PATH}/general_logs

Test Precondition
    [Documentation]  Description:           List of precondition actions common for all test cases${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                x ${\n}
    ...              Maintainer:            x ${\n}
    ...              Last Modification:     xx-xx-xxxx made by xx@nokia.com${\n}

    Start Logging
Test Postcondition
    [Documentation]  Description:           List of postcondition actions common for all test cases${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                x ${\n}
    ...              Maintainer:            x ${\n}
    ...              Last Modification:     xx-xx-xxxx made by xx@nokia.com${\n}

Create Suite Logs Directory
    [Documentation]  Description:           Prepares directory for all suite logs${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                x ${\n}
    ...              Maintainer:            x ${\n}
    ...              Last Modification:     xx-xx-xxxx made by xx@nokia.com${\n}

    ${current_date}=    Get Current Date    exclude_millis=yes
    ${current_date}=    Replace String    ${current_date}    ${SPACE}    _
    ${current_date}=    Replace String    ${current_date}    :    -
    ${current_suite_name}=    Replace String    ${SUITENAME}    ${SPACE}    _
    ${SUITE_LOGS_DIR_PATH}=    Set Suite Variable    ${OUTPUT_DIR}/${current_suite_name}_${current_date}/

    [Return]    ${SUITE_LOGS_DIR_PATH}

Create Test Logs Directory
    [Documentation]  Description:           Get test logs directory from given logs directory path${\n}
    ...              Return:                Logs directory to specified test: i.e. /home/ute/MN/UTE/robotws/date_+_suite_name/test_name${\n}
    ...              Output:                { ${string} }${\n}
    ...              Author:                x@nokia.com${\n}
    ...              Maintainer:            x${\n}
    ...              Last Modification:     xx-xx-xxxx made by xx@nokia.com${\n}
    [Arguments]      ${suite_logs_path}       # path to suite logs

    ${test_name}=    Replace String    ${TESTNAME}    ${SPACE}    _
    ${test_logs_dir}=    Normalize Path    ${suite_logs_path}${TESTNAME}/
    Set Test Variable    ${TEST_LOGS_DIR_PATH}    ${test_logs_dir}

    [Return]    ${TEST_LOGS_DIR_PATH}

Setup Host Variables
    [Documentation]  Description:           Keyword sets test suite global variables ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}

    ${host_parameters}=  Get Host Parameters From Init File
    Set Suite Variable  ${UTE_SSH_IP}  ${host_parameters['ip_addr']}
    Set Suite Variable  ${UTE_SSH_USER_NAME}  ${host_parameters['username']}
    Set Suite Variable  ${UTE_SSH_PASSWORD}  ${host_parameters['password']}

Get Host Parameters From Init File
    [Documentation]  Description:           Get host parameters from TL configuration init file ${\n}
    ...              Return:                Dictionary with host parameters ${\n}
    ...              Output:                { 'ip_addr': ${ip_addr} , 'username': ${username} , 'password': ${password} } ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}

    ${ip_addr}=  Set Variable  ${tl.test_pc.default_ssh_connection_details.addr}
    ${username}=  Set Variable  ${tl.test_pc.default_ssh_connection_details.username}
    ${password}=  Set Variable  ${tl.test_pc.default_ssh_connection_details.password}
    ${host_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}
    [Return]  ${host_parameters}

Disconnect Interactive Connection
    [Documentation]  Description:           Keyword disconnects ssh connection ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${alias}=default

    Should Not Be Empty  ${alias}
    issh.disconnect  alias=${alias}

Calculate Average KPI Values And Compare With Target
    [Documentation]
    ...    This keyword calculates the average of a list of KPI values and compares it with a target value.
    ...    It ensures that the calculated average does not exceed the specified target.
    ...    Arguments:
    ...        - ${kpi_results}: A list of KPI values to calculate the average from.
    ...        - ${kpi_target}: The target value to compare the average against.
    ...    Returns:
    ...        - ${average}: The calculated average of the KPI values.
    ...    Raises:
    ...        - AssertionError: If the calculated average exceeds the target value.
    [Arguments]    ${kpi_results}    ${kpi_target}
    ${average}=    Evaluate    sum(${kpi_results}) / len(${kpi_results})
    Run Keyword And Continue On Failure    Should be True    ${average} <= ${kpi_target}
    ...                                    msg=Average KPI value ${average} exceeds target ${kpi_target}
    ${rounded_average}=    Evaluate    round(${average}, 2)
    [Return]    ${rounded_average}

Round KPI result
    [Documentation]  Description:     Round given KPI value up with 0.1 precision
    ...               Input:          number as a Int/Float/String
    ...               Output:         Float
    ...               Author:         karol.sadowski@nokia.com
    [Arguments]       ${kpi_result}
    ${kpi_result_number}=    Convert To Number    ${kpi_result}
    ${rounded_kpi_result}=    Evaluate    max(round(${kpi_result_number}, 1), 0.1)
    [Return]     ${rounded_kpi_result}

Check Average KPI Value With Previous Release Result
     [Documentation]  Description:    Check if average KPI results mets target from req. 11091878
    ...               Input:          current_kpi_result - Average KPI test result [seconds]
    ...                               previous_release_kpi_result  - Same KPI result, from previous release execution [seconds]
    ...               Output:         none
    ...               Author:         karol.sadowski@nokia.com
    [Arguments]       ${current_kpi_result}     ${previous_release_kpi_result}
    ${current_kpi}=    Convert To Number    ${current_kpi_result}    2
    ${previous_kpi}=    Convert To Number    ${previous_release_kpi_result}    2
    IF    ${previous_kpi}>60
        ${max_value}=    Evaluate    ${previous_kpi} * 1.15
    ELSE IF    ${previous_kpi}<=60 and ${previous_kpi}>=10
        ${max_value}=    Evaluate    ${previous_kpi} * 1.20
    ELSE
        ${max_value}=    Evaluate    ${previous_kpi} * 1.40
    END
    Should Be True    ${current_kpi}<${max_value}    msg=Current result: ${current_kpi} does not match given target: ${max_value}!

Verify KPI Benchmark
    [Arguments]    ${current}    ${benchmark}    ${KPI_name}
    Should Be True    ${current} <= ${benchmark}
    ...    msg=The average result from the previous release is better than the current average for ${KPI_name}. Potential KPI degradation detected.

Get MRBTS and NRBTS IDs
    [Documentation]
    ...  Retrieves MRBTS_ID and NRBTS_ID from the SCF file (for either vCU or vDU).
    ...  The argument ${hw_type} specifies which CNF (vCU/vDU) to query.
    [Arguments]    ${hw_type}

    ${filename}=    Set Variable    scf.xml
    ${download_keyword}=   Set Variable If    '${hw_type}'=='vCU'
    ...    vcu_admin.Get_Current_Plan_File
    ...    vdu_admin.get_current_plan_file

    Run Keyword If    '${hw_type}'=='vDU'
    ...    ${download_keyword}    local_dir_path=${Test_Results_Dir}    filename=${filename}    vdu_connection=${vdu_connection}
    ...    ELSE
    ...    ${download_keyword}    path=${Test_Results_Dir}/${filename}    connection=${vcu_connection}

    ${scf_content}=   OperatingSystem.Get File   ${Test_Results_Dir}/${filename}
    ${result}=     Get Regexp Matches    ${scf_content}   .*NRDU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRDU-(\\d+)"\\s+.*   1  2  3
    ${mrbts_id}=  Set Variable If    ${result}    ${result[0][0]}
    ${nrbts_id}=  Set Variable If    ${result}    ${result[0][1]}

    [Return]    ${mrbts_id}    ${nrbts_id}

Get vCU Uptime
    [Documentation]  Description:           Keyword gets vCU uptime (reading startTime of oamext pod) ${\n}
    ...              Return:                Uptime in seconds ${\n}
    ...              Output:                None ${\n}
    ...              Author:                iuliia.taupeka@nokia.com ${\n}
    ...              Maintainer:            iuliia.taupeka@nokia.com ${\n}
    ...              Last Modification:     22-08-2025 made by iuliia.taupeka@nokia.com ${\n}
    ${cmd}=    Set Variable
    ...    echo $(($(date -u +%s)-$(date -d "$(kubectl get pod po-oamext-0 -n ${CRAN_VCU} -o jsonpath='{.status.startTime}')" +%s)))
    ${connection_alias}=    common_vcu.Connect To vCU K8s Master Node With Tenant    0    3600
    Set Test Variable    ${connection_alias}
    ${uptime_output}=   issh.Execute    command=${cmd}   alias=${connection_alias}
    ${uptime_output}    Strip Prompt    ${uptime_output}
    ${uptime}=    Process Variable    ${uptime_output}
    Log To Console    vCU uptime is ${uptime} seconds
    common_keywords.Disconnect Interactive Connection    alias=${connection_alias}
    [Return]    ${uptime}

Get vDU Uptime
    [Documentation]  Description:           Keyword gets vDU uptime (reading startTime of oamext pod) ${\n}
    ...              Return:                Uptime in seconds ${\n}
    ...              Output:                None ${\n}
    ...              Author:                iuliia.taupeka@nokia.com ${\n}
    ...              Maintainer:            iuliia.taupeka@nokia.com ${\n}
    ...              Last Modification:     22-08-2025 made by iuliia.taupeka@nokia.com ${\n}
    ${cmd}=    Set Variable
    ...    echo $(($(date -u +%s)-$(date -d "$(kubectl get pod po-oamext-0 -n ${CRAN_VDU} -o jsonpath='{.status.startTime}')" +%s)))
    ${connection_alias}=    common_vdu.Connect To vDU K8s Master Node With Tenant    0    3600
    Set Test Variable    ${connection_alias}
    ${uptime_output}=   issh.Execute    command=${cmd}   alias=${connection_alias}
    ${uptime_output}    Strip Prompt    ${uptime_output}
    ${uptime}=    Process Variable    ${uptime_output}
    Log To Console    vDU uptime is ${uptime} seconds
    common_keywords.Disconnect Interactive Connection    alias=${connection_alias}
    [Return]    ${uptime}

Get KPI Target Based On Snapshot Size
    [Documentation]    Description:    This keyword returns BTS KPI target based on snapshot size.
    [Arguments]    ${snapshot_size}
    IF    ${snapshot_size} <= 500
        RETURN    ${KPI_UP_TO_500MB_target}
    ELSE IF    ${snapshot_size} <= 1000
        RETURN    ${KPI_UP_TO_1GB_target}
    ELSE IF    ${snapshot_size} <= 2000
        RETURN    ${KPI_UP_TO_2GB_target}
    END

Calculate Average BTS and E2E Values
    [Arguments]    ${KPI_BTS_results}    ${KPI_E2E_results}    ${SNAPSHOT_SIZES_LIST}
    [Documentation]    Description:    This keyword calculates and checks average BTS KPI, E2E KPI and Snapshot size
    ...                                from all iterations.
    ${average_BTS}=    Evaluate    round ((sum(${KPI_BTS_results}) / len(${KPI_BTS_results})) , 1)
    Set Test Variable    ${average_BTS}
    Log    === Average BTS ${average_BTS} ===    console=${True}

    ${average_E2E}=    Evaluate    round ((sum(${KPI_E2E_results}) / len(${KPI_E2E_results})) , 1)
    Set Test Variable   ${average_E2E}
    Log      === Average E2E ${average_E2E} ===    console=${True}

    ${average_file_size}=    Evaluate    round ((sum(${SNAPSHOT_SIZES_LIST}) / len(${SNAPSHOT_SIZES_LIST})) , 1)
    Set Test Variable   ${average_file_size}
    Log    === Average Snapshot size: ${average_file_size}MB ===    console=${True}
