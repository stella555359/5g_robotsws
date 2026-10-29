*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_L_10471_1ASIB_1ABIO_3AEHC  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/CM_CABLE_SPEED_CHANGE.robot
Resource    ../../CIT/test_resources/CM_Cell_Addition_LTE.robot
Resource    ../../CIT/test_resources/CM_Cell_Removal_LTE.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Configuration_reset.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_with_BTS_reset.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_delta_commissioning_with_reset.robot
Resource    ../../CIT/test_resources/CM__Recommissioning_delta_commissioning_without_reset.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__BBMOD_recovery_insufficient_resources_processes.robot
Resource    ../../FM/test_resources/FM__BBMOD_recovery_insufficient_resources_threads.robot
Resource    ../../FM/test_resources/FM__SMOD_recovery_insufficient_resources_threads.robot


Suite Setup      Run keywords
...              Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general
...              AND  Map BuildShareTimi01 and move counters folder in test_line_specific

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1471

*** Test Cases ***

[1]Automated__FM__BBMOD_recovery_insufficient_resources_processes
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO    
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${COMMAND}    :(){ :|:& };:
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${SNAPSHOT_FILE_NAME}    processes_snapshot_${BBMOD_TYPE}.zip
    ...    AND    Set Test Variable    ${SNAPSHOT_RETRY_COUNT}    20
    ...    AND    Set Test Variable    ${SNAPSHOT_LOG}    FAULT_SIGNATURE
    ...    AND    Set Test Variable    ${ARCHIVE_TO_CHECK}    2011_startup.zip
    ...    AND    Set Test Variable    ${LOG_TO_CHECK}    startup_HWAPI.log.xz
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    FM__BBMOD_recovery_insufficient_resources_processes
    ...    AND    FM__BBMOD_recovery_insufficient_resources_processes.TC Setup
    TC__FM__BBMOD_recovery_insufficient_resources_processes
    [Teardown]    Run Keywords    FM__BBMOD_recovery_insufficient_resources_processes.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__FM__BBMOD_recovery_insufficient_resources_threads
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO    
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${SNAPSHOT_FILE_NAME}    threads_snapshot_${BBMOD_TYPE}.zip
    ...    AND    Set Test Variable    ${SNAPSHOT_RETRY_COUNT}    20
	...    AND    Set Test Variable    ${THREADS_PY_LOCATION}    ${CURDIR}/python_scripts
    ...    AND    Set Test Variable    ${THREADS_PY_NAME}    crash_threads.py
    ...    AND    Set Test Variable    ${SNAPSHOT_LOG}    THREAD_OVERLOAD_PERSISTENT_RESET_INFO
    ...    AND    Set Test Variable    ${ARCHIVE_TO_CHECK}    2011_startup.zip
    ...    AND    Set Test Variable    ${LOG_TO_CHECK}    startup_HWAPI.log.xz
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    FM__BBMOD_recovery_insufficient_resources_threads
    ...    AND    FM__BBMOD_recovery_insufficient_resources_threads.TC Setup
    TC__FM__BBMOD_recovery_insufficient_resources_threads
    [Teardown]    Run Keywords    FM__BBMOD_recovery_insufficient_resources_threads.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset


[1]Automated__FM__SMOD_recovery_insufficient_resources_threads
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SMOD_TYPE}    ASIB    
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${COLLECT_SNAPSHOT_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${SNAPSHOT_FILE_NAME}    threads_snapshot_${SMOD_TYPE}.zip
    ...    AND    Set Test Variable    ${SNAPSHOT_RETRY_COUNT}    20
	...    AND    Set Test Variable    ${THREADS_PY_LOCATION}    ${CURDIR}/python_scripts
    ...    AND    Set Test Variable    ${THREADS_PY_NAME}    crash_threads.py
    ...    AND    Set Test Variable    ${SNAPSHOT_LOG}    THREAD_OVERLOAD_PERSISTENT_RESET_INFO
    ...    AND    Set Test Variable    ${ARCHIVE_TO_CHECK}    2011_startup.zip
    ...    AND    Set Test Variable    ${LOG_TO_CHECK}    startup_HWAPI.log.xz
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    Modify Resource Search Order    FM__SMOD_recovery_insufficient_resources_threads
    ...    AND    FM__SMOD_recovery_insufficient_resources_threads.TC Setup
    TC__FM__SMOD_recovery_insufficient_resources_threads
    [Teardown]    Run Keywords    FM__SMOD_recovery_insufficient_resources_threads.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset



*** Keywords ***
Map BuildShareTimi01 and move counters folder in test_line_specific
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...                                    noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    ${cp_command}  Catenate  cp /media/BuildShareTimi01/SBTS/Trunk/counters_for_CIT_Trunk/10210/*
    ...                      /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS10210/counters/
    Run  ${cp_command}

