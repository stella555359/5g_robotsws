*** Settings ***
Documentation     author: ming.shi
...                 contact: ming.shi@nokia.com
...                 squad group: SG_03
...                 feature : VDT case

Library    OperatingSystem
Library    Collections
Library    DateTime
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/ping_pang_common_keywords.robot

#Suite Teardown    Clean Up Old Files

*** Variables ***
${TASK_NAME}    VDT_test
${BASE_PATH}    /opt/workspace/CRT/Master/Case_Logs/
${DAYS_THRESHOLD}    20

*** Test Cases ***
[1][1.0]virtual_drive_throughput_performance_test_dl
    [Documentation]
    ...    case1: 01:10 start to run
    ...    01:15 capture tti trace pci=31,32
    ...    02:20 capture snapshot
    [Tags]    VDT_DL
    [Timeout]    5 hours
    Check Time and collect tti logs    case=dl    check_time=01:15
    [Teardown]    Check Time and collect snapshot    case=dl    check_time=02:20

[1][1.0]virtual_drive_throughput_performance_test_ul
    [Documentation]
    ...    case2：04：10 start to run
    ...    04:15 capture tti trace  pci=31,32
    ...    05:20 capture snapshot
    [Tags]    VDT_UL
    [Timeout]    5 hours
    Check Time and collect tti logs    case=ul    check_time=04:15
    [Teardown]    Check Time and collect snapshot    case=ul    check_time=05:20

*** Keywords ***
Set release build and time variable
    ${release_info}=    Get completed release
    ${time}=    Get Time    year month day hour min sec
    ${time_string}=    Evaluate    "_".join(${time})
    ${build_time}=    Catenate    ${release_info}_${time_string}
    [Return]    ${build_time}

Capture Ttitrace via Admin CLI
    [Arguments]
    ...            ${names}=l2stream3_ttitrace
    ...            ${SW_BRANCH}=NULL
    ...            ${nr_phy_cell_ids}=NULL
    ...            ${gNB_index}=${0}
    ...            ${target_dir}=${epc_log_path}
    ${build_time}=    Set release build and time variable
    Start Ttitrace With Admin Mode
    ...    names=${names}_${build_time}    SW_BRANCH=${SW_BRANCH}    nr_phy_cell_ids=${nr_phy_cell_ids}    gNB_index=${gNB_index}
    Sleep    20s
    [Teardown]    Stop Ttitrace With Admin Mode    names=${names}_${build_time}      target_dir=${target_dir}

Check Time and collect tti logs
    [Arguments]    ${case}=dl    ${check_time}=02:10
    Prepare PM counter to caculate time    period=start
    WHILE    ${True}
        ${current_time} =    Get Current Date    result_format=%H:%M
        IF    '${current_time}' == '${check_time}'
            Log    current_time: ${current_time}
            Capture Ttitrace via Admin CLI    names=l2stream3_ttitrace_${case}_31    nr_phy_cell_ids=${31}
            Capture Ttitrace via Admin CLI    names=l2stream3_ttitrace_${case}_32    nr_phy_cell_ids=${32}
            BREAK
        END
        Sleep    300s
    END

Check Time and collect snapshot
    [Arguments]    ${case}=dl    ${check_time}=02:10
    Prepare PM counter to caculate time    period=start
    WHILE    ${True}
        ${current_time} =    Get Current Date    result_format=%H:%M
        IF    '${current_time}' == '${check_time}'
            Log    current_time: ${current_time}
            collect snapshot    case=${case}
            BREAK
        END
        Sleep    300s
    END

collect snapshot
    [Arguments]     ${case}=dl    ${gnb_index}=${0}    ${connection}=GNB_OAM    ${timeout}=${360}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${build_time}=    Set release build and time variable
    ${snapshot_file_path}    Set variable    ${epc_log_path}/snapshot_rest_api_${case}_${build_time}.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${connection}    timeout=${timeout}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

#Clean Up Old Files
#    ${current_time}=    Get Current Date
#    ${threshold_time}=    Evaluate    datetime.datetime.strptime('${current_time}', '%Y-%m-%d %H:%M:%S') - datetime.timedelta(days=${DAYS_THRESHOLD})
#    ${files}=    Get File List    ${BASE_PATH}
#    FOR    ${file}    IN    @{files}
#        ${file_path}=    Catenate    SEPARATOR=/    ${BASE_PATH}    ${file}
#        ${file_mtime}=    Get File Modification Time    ${file_path}
#        ${file_mtime_str}=    Convert To String    ${file_mtime}
#        ${file_mtime_obj}=    Evaluate    datetime.datetime.strptime('${file_mtime_str}', '%Y-%m-%d %H:%M:%S')
#        IF    ${file_mtime_obj} < ${threshold_time}
#            Remove File    ${file_path}
#        END
#    END
#
#Get File List
#    [Arguments]    ${path}
#    ${files}=    Get File List    ${path}
#    [Return]    ${files}
#
#Get File Modification Time
#    [Arguments]    ${file_path}
#    ${mtime}=    Get File Modification Time    ${file_path}
#    [Return]    ${mtime}









Run VDT Case
    [Arguments]    ${connection}=VDT_PC
    csn.Connect To
    ...    hostname=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=${connection}
    ${info}   csn.Execute    command=schtasks /Run /TN "${TASK_NAME}"
    [Teardown]   csn.Disconnect   connection=${connection}

Check Task Completion
    [Arguments]    ${connection}=VDT_PC
    csn.Connect To
    ...    hostname=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=${connection}
    ${output}=    csn.Execute    command=

    ${status}=    Get Task Status From Output    ${output}schtasks /Query /TN "${TASK_NAME}" /FO CSV
    Log    Task status output: ${output}

    IF    '${status}' != 'Running'
        get gnb snapshot
    ELSE
        Fail    Task is still running
    END

Get Task Status From Output
    [Arguments]    ${output}
    ${lines}=    Split String    ${output}    \n
    ${last_line}=    Set Variable    ${lines[-1]}
    ${fields}=    Split String    ${last_line}    ,
    ${status_field}=    Set Variable    ${fields[3]}
    [Return]    ${status_field}
