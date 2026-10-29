*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real AP TL.
...   It verifies proper function of KWs in btslog.robot.


Resource    ../btslog.robot
Resource    ../testline.robot
Resource    ../gnb.robot
Library     OperatingSystem
Library     String


*** Test Cases ***
Test Set Syslog Level and other gNB swconfig Keywords
    [TAGS]              BTSLOG
    ${target_dir}   testline.Get Testcase Log Directory
    ${org_file}     gnb.Store Current SWConfig From GNB     target_dir=${target_dir}
    File Should Exist           ${org_file}
    File Should Not Be Empty    ${org_file}
    Set Syslog Level In GNB SWConfig    log_level=1
    ${modified_file}    gnb.Get SWConfig From GNB     target_dir=${target_dir}
    ${file_differ}      Run And Return RC   cmp ${org_file} ${modified_file}
    IF      not ${file_differ}  Fail      Set Syslog Level in gNB swconfig failed!
    Reload Stored Swconfig To GNB
    ${restored_file}    gnb.Get SWConfig From GNB     target_dir=${target_dir}
    ${file_differ}      Run And Return RC   cmp ${org_file} ${restored_file}
    IF      ${file_differ}  Fail    Reload stored swconfig to gNB failed!


Test Start Stop Btslog
    [TAGS]              BTSLOG
    ${target_dir}=    testline.Get Testcase Log Directory
    Start Btslog
    Sleep   10
    Stop Btslog    target_dir=${target_dir}
    File Should Exist           ${target_dir}/btslog_gnb0/syslog_files.tgz
    File Should Not Be Empty    ${target_dir}/btslog_gnb0/syslog_files.tgz

Test Get Cplane Log Level Value Error Case
    [TAGS]              BTSLOG
    Run Keyword And Expect Error  Log level dummy isn't in supported list*
    ...     Get Cplane Log Level Value  level=dummy


Test Get Cplane Log Level Value
    [TAGS]              BTSLOG
    FOR  ${level}  IN  trace  debug  info  warning  error  vip  TRACE  Debug
        ${level_val}    Get Cplane Log Level Value  level=${level}
        ${is_int}       Evaluate     isinstance(${level_val}, int)
        Should Be True  ${is_int}
    END


Test Create cplane runtime file to gnb
    [TAGS]              BTSLOG
    [Setup]  Setup Environment And Backup Existing CP Runtime GNB And SWConfig
    Create CPlane Runtime File To Gnb   gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}  level=error
    Check CP Runtime Or SWConfig Is Created With Correct Content  level=error
    [Teardown]  Run Keywords    Restore Original CP Runtime  AND  Reload Stored SWConfig To GNB


Test Create cplane runtime file to ap
    [TAGS]              BTSLOG
    [Setup]  Setup Environment And Backup Existing CP Runtime AP
    Create CPlane Runtime File To AP  ue_id=${ue_id}    comu_id=${comu_id}
    Check AP CP Runtime Is Created With Correct Content
    [Teardown]  Restore Original CP Runtime


*** Keywords ***
Setup Environment And Backup Existing CP Runtime GNB And SWConfig
    Set Test Variable  ${gnb_id}  0
    Set Test Variable  ${comu_id}  0
    Set Test Variable  ${du_id}  0
    ${comu_alias}=    connect.Connect To Node Common Unit    node_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    Set Test Variable  ${comu_alias}
    Backup Existing CP Runtime
    Store Current SWConfig From GNB


Setup Environment And Backup Existing CP Runtime AP
    Set Test Variable  ${ue_id}  0
    Set Test Variable  ${comu_id}  0
    ${comu_alias}=    connect.Connect To Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    Set Test Variable  ${comu_alias}
    Backup Existing CP Runtime

Backup Existing CP Runtime
    ssh.Send Command    command= [ -f /ffs/run/cp_runtime.ini ] && mv /ffs/run/cp_runtime.ini /ffs/run/cp_runtime.ini.CI
    ...                 connection=${comu_alias}


Restore Original CP Runtime
    ssh.Send Command    command= [ -f /ffs/run/cp_runtime.ini.CI ] && mv /ffs/run/cp_runtime.ini.CI /ffs/run/cp_runtime.ini
    ...                 connection=${comu_alias}


Check AP CP Runtime Is Created With Correct Content
    ${target_dir}=    testline.Get Testcase Log Directory
    ssh.Download File   remote_path=/ffs/run/cp_runtime.ini
    ...                 local_path=${target_dir}/cp_runtime.ini
    ...                 connection=${comu_alias}
    ...                 timeout=10
    ${output}=  Run  cat ${target_dir}/cp_runtime.ini
    Should Contain   ${output}  [control]
    Should Contain   ${output}  LoggingSeverity=trace


Check CP Runtime Or SWConfig Is Created With Correct Content
    [Arguments]         ${level}
    ${target_dir}       testline.Get Testcase Log Directory
    ${sw_branch}        testline.Get GNB SW Branch


    Run Keyword And Expect Error      FileNotFoundError*  ssh.Download File   remote_path=/ffs/run/cp_runtime.ini
    ...                 local_path=${target_dir}/cp_runtime.ini     connection=${comu_alias}     timeout=10
    Check CP Log Level For Component In Swconfig File  target_dir=${target_dir}  level=${level}
    RETURN      "cp_runtime.ini not found as expected!"


    ssh.Download File   remote_path=/ffs/run/cp_runtime.ini
    ...                 local_path=${target_dir}/cp_runtime.ini
    ...                 connection=${comu_alias}
    ...                 timeout=10
    ${output}=  Run  cat ${target_dir}/cp_runtime.ini
    Should Contain   ${output}  [control]
    Should Contain   ${output}  LoggingSeverity=trace



Check CP Log Level For Component In Swconfig File
    [Arguments]         ${target_dir}  ${level}
    ${level}            Get Cplane Log Level Value  level=${level}
    ${path}             Get SWConfig From GNB       target_dir=${target_dir}
    ${rad_flags}        Get File    ${path}
    FOR     ${flag}     IN          @{P_RAD_CPLOG_FLAG_IDS}
        Should Contain  ${rad_flags}    ${flag}
        ${line}         Get Lines Containing String     ${rad_flags}    ${flag}
        ${rad}  ${val}  Split String From Right 	${line} 	= 	1
        Should Be Equal As Integers     ${level}    ${val}
        ...   Expected log level '${level}' doesn't match found level '${val}' for rad '${rad}'  values=${False}
    END
    [Teardown]  Run         rm -rf /tmp/swconfig
