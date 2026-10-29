*** Settings ***
Documentation    Selenium related keywords for classical.
...              Please notify 5G_HGZ_Core_Testers when modifying the file
...              Author: HAZ3&4_common

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    DateTime
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.btslog  WITH NAME   btslog


*** Keywords ***
Start Btslog With Path Check
    [Documentation]    Need to set suite variable for stopping btslog in teardown
    FOR   ${btslog_dir}     IN     @{btslog_dirs}
          ${file_exist}=    Run Keyword And Return Status    File Should Exist    ${btslog_dir}/btslog
          run keyword if      '${file_exist}'=='True'       run keywords       Start Btslog Collect
          ...    btslog_dir=${btslog_dir}    AND    Exit For Loop
    END
    Set Suite Variable    ${btslog_dir}
    run keyword if    '${btslog_dir}'=='none'    Log    Can't find btslog.    WARN

Stop Btslog With Path Check
    [Arguments]      ${target_dir}=${TS_CASE_LOG_PATH}
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${target_dir}

Start Btslog Collect
    [Arguments]      ${names}=btslog     ${btslog_dir}=/opt/btslog     ${log_dir}=/tmp/btslog2
    btslog.create_btslog_collector    name=${names}    btslog_path=${btslog_dir}/btslog
    ...                               btslog_launcher_path=${btslog_dir}/btslog_launcher
    ...                               log_dir=${log_dir}    start_timeout=${120}
    core.setup_collectors      names=${names}
    core.start_collectors      names=${names}
    btslog.Set Suite Alias     ${names}

Stop Btslog Collect
    [Timeout]  3 hours
    [Arguments]      ${names}=btslog     ${target_dir}=${TS_CASE_LOG_PATH}
    run keyword and ignore error      core.stop_collectors    names=${names}
    run keyword and ignore error      core.collect_collectors      names=${names}    target_dir=${target_dir}
    core.teardown_collectors      names=${names}
    Log To Console    Collecting BTSLOG [DONE]
