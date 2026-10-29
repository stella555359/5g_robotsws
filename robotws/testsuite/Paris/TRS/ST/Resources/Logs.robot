*** Settings ***
Documentation
...                 Keywords Purpose:
...                 keywords relative to logs
...
...                 AUTHOR:
...                 David Jollivet    david.jollivet@nokia.com

Library             OperatingSystem
Library             DateTime
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.btslog    WITH NAME    btslog


*** Keywords ***
Setup BTSLOG
    # Prepare BTSLOG on a VM
    # Alias is returned for next usages of the BTSLOG
    [Arguments]    ${TEST_VM_IP}    ${TEST_VM_username}    ${TEST_VM_password}    ${ALIAS}
    ${executor_test_vm}=    Create Dictionary
    ...    host=${TEST_VM_IP}
    ...    user=${TEST_VM_username}
    ...    password=${TEST_VM_password}
    btslog.create_btslog_collector
    ...    name=${ALIAS}
    ...    btslog_path=/opt/btslog/btslog
    ...    btslog_launcher_path=/opt/btslog/btslog_launcher
    ...    executor=${executor_test_vm}
    ...    log_dir=/tmp/btslog2
    ${collector}=    btslog.Get Alias Value    ${ALIAS}
    btslog.Set Suite Alias    ${ALIAS}

Start BTSLOG
    [Arguments]    ${ALIAS}
    core.setup_collectors    names=${ALIAS}
    core.start_collectors    names=${ALIAS}

Stop BTSLOG
    [Arguments]    ${ALIAS}    ${path}

    # Name of the file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d-%H%M
    ${filename}=    Set Variable    syslog_files_${ALIAS}_${timestamp}.tgz

    core.stop_collectors    names=${ALIAS}
    core.collect_collectors    names=${ALIAS}    target_dir=${path}
    core.teardown_collectors    names=${ALIAS}
    Move File    ${path}/${ALIAS}/syslog_files.tgz    ${path}/${filename}
