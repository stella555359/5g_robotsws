*** Settings ***
Resource    ../btslog.robot
Resource    ../testline.robot
Resource    ../gnb.robot
Library     OperatingSystem
Library     String


*** Test Cases ***
Test Set Syslog Level and other gNB swconfig Keywords
    [TAGS]              BTSLOG
    ${target_dir}   testline.Get Testcase Log Directory
    ${org_file}     gnb.Store Current swconfig from gNB     target_dir=${target_dir}
    File should Exist           ${org_file}
    File Should Not Be Empty    ${org_file}
    Set Syslog Level in gNB swconfig    log_level=1
    ${modified_file}    gnb.Get swconfig from gNB     target_dir=${target_dir}
    ${file_differ}      Run And Return RC   cmp ${org_file} ${modified_file}
    Run Keyword Unless  ${file_differ}  Fail    Set Syslog Level in gNB swconfig failed!
    Reload stored swconfig to gNB
    ${restored_file}    gnb.Get swconfig from gNB     target_dir=${target_dir}
    ${file_differ}      Run And Return RC   cmp ${org_file} ${restored_file}
    Run Keyword If      ${file_differ}  Fail    Reload stored swconfig to gNB failed!


Test Start Stop Btslog
    [TAGS]              BTSLOG
    ${target_dir}=    testline.Get Testcase Log Directory
    Start Btslog
    Sleep   10
    Stop Btslog    target_dir=${target_dir}
    File Should Exist           ${target_dir}/btslog_gnb0/syslog_files.tgz
    File Should not be empty    ${target_dir}/btslog_gnb0/syslog_files.tgz

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
    [Setup]  Setup environment and backup existing cp_runtime gnb and swconfig
    Create cplane runtime file to gnb   gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}  level=error
    Check cp_runtime or swconfig is created with correct content  level=error
    [Teardown]  Run Keywords    Restore original cp_runtime  AND  Reload stored swconfig to gNB


Test Create cplane runtime file to ap
    [TAGS]              BTSLOG
    [Setup]  Setup environment and backup existing cp_runtime ap
    Create cplane runtime file to ap  ue_id=${ue_id}    comu_id=${comu_id}
    Check AP cp_runtime is created with correct content
    [Teardown]  Restore original cp_runtime


*** Keywords ***
Setup environment and backup existing cp_runtime gnb and swconfig
    Set Test Variable  ${gnb_id}  0
    Set Test Variable  ${comu_id}  0
    Set Test Variable  ${du_id}  0
    ${comu_alias}=    connect.Connect to Node Common Unit    node_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    Set Test Variable  ${comu_alias}
    backup existing cp_runtime
    Store Current swconfig from gNB


Setup environment and backup existing cp_runtime ap
    Set Test Variable  ${ue_id}  0
    Set Test Variable  ${comu_id}  0
    ${comu_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    Set Test Variable  ${comu_alias}
    backup existing cp_runtime

backup existing cp_runtime
    ssh.send_command    command= [ -f /ffs/run/cp_runtime.ini ] && mv /ffs/run/cp_runtime.ini /ffs/run/cp_runtime.ini.CI
    ...                 connection=${comu_alias}


Restore original cp_runtime
    ssh.send_command    command= [ -f /ffs/run/cp_runtime.ini.CI ] && mv /ffs/run/cp_runtime.ini.CI /ffs/run/cp_runtime.ini
    ...                 connection=${comu_alias}


Check AP cp_runtime is created with correct content
    ${target_dir}=    testline.Get Testcase Log Directory
    ssh.download_file   remote_path=/ffs/run/cp_runtime.ini
    ...                 local_path=${target_dir}/cp_runtime.ini
    ...                 connection=${comu_alias}
    ...                 timeout=10
    ${output}=  Run  cat ${target_dir}/cp_runtime.ini
    Should Contain   ${output}  [control]
    Should Contain   ${output}  LoggingSeverity=trace


Check cp_runtime or swconfig is created with correct content
    [Arguments]         ${level}
    ${target_dir}       testline.Get Testcase Log Directory
    ${sw_branch}        testline.Get gNB SW Branch
    Run Keyword If      $sw_branch not in ['SBTS22R2','SBTS22R3']   Run Keywords
    ...                 Run Keyword And Expect Error
    ...                 FileNotFoundError*  ssh.download_file   remote_path=/ffs/run/cp_runtime.ini
    ...                 local_path=${target_dir}/cp_runtime.ini
    ...                 connection=${comu_alias}
    ...                 timeout=10
    ...  AND            Check CP log Level for Component in Swconfig File  target_dir=${target_dir}  level=error
    ...  AND            Return From Keyword     "cp_runtime.ini not found as expected!"
    ssh.download_file   remote_path=/ffs/run/cp_runtime.ini
    ...                 local_path=${target_dir}/cp_runtime.ini
    ...                 connection=${comu_alias}
    ...                 timeout=10
    ${output}=  Run  cat ${target_dir}/cp_runtime.ini
    Should Contain   ${output}  [control]
    Should Contain   ${output}  LoggingSeverity=trace



Check CP log Level for Component in Swconfig File
    [Arguments]         ${target_dir}  ${level}
    ${level}            Get Cplane Log Level Value  level=${level}
    ${path}             Get swconfig from gNB       target_dir=${target_dir}
    ${rad_flags}        Get File    ${path}
    FOR     ${flag}     IN          @{P_RAD_CPLOG_FLAG_IDS}
        Should Contain  ${rad_flags}    ${flag}
        ${line}         Get Lines Containing String     ${rad_flags}    ${flag}
        ${rad}  ${val}  Split String From Right 	${line} 	= 	1
        Should Be Equal As Integers     ${level}    ${val}
        ...   Expected log level '${level}' doesn't match found level '${val}'  values=${False}
    END
    [Teardown]  Run         rm -rf /tmp/swconfig
