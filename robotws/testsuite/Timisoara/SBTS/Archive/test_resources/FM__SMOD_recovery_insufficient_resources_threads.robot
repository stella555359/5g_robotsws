*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot
Library     ../../common_resources/python_resources/snapshot_check.py


*** Variables ***
${SMOD_TYPE}                                                          # Mandatory, specify the BBMOD type where the processes will run
${RECOVERY_TIMEOUT}          900
${COLLECT_SNAPSHOT_TIMEOUT}  1200
${SNAPSHOT_FILE_NAME}        threads_snapshot_${SMOD_TYPE}.zip        # Snapshot name.
${SNAPSHOT_RETRY_COUNT}      20                                       # Times to retry to collect snapshot.
${THREADS_PY_LOCATION}       ${CURDIR}/python_scripts                 # Python file location.
${THREADS_PY_NAME}           crash_threads.py                         # Python file to be executed.
${SNAPSHOT_LOG}              THREAD_OVERLOAD_PERSISTENT_RESET_INFO    # What to look for in snapshot.
${ARCHIVE_TO_CHECK}          1011_startup.zip                         # ZIP name is BTS10718_1011_startup.zip, only '1011_startup.zip' must pe given.
${LOG_TO_CHECK}              startup_HWAPI.log.xz                     # Log file where test should look.


*** Keywords ***
TC__FM__SMOD_recovery_insufficient_resources_threads
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25205
    ...  Test will randomly choose one SMOD wich is the same type as the one provided.
    ...  Python file that triggers multiples threads will pe uploaded to /tmp folder and started. For ASIA boards it will start 100 times in a loop.
    ...  for all other boards, single python script will be run.
    ...  After recovery, snapshot will be collected and will check if FAULT_SIGNATURE is seen.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25205 - Initial TAT creation
    ...  *******************

    Set Tags    CA-FM    bogdan.boldurean@nokia.com    AUTHOR-bogdan.boldurean@nokia.com
    ...         MAINTAINER-bogdan.boldurean@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    CNI-97248

    Step 0: Get SMOD
    Step 1: Start threads on SMOD
    Step 2: Wait SMOD Recovery after threads crash
    Step 3: Check SMOD Fault Signature
    Step 4: Waiting for complete SBTS recovery after SMOD threads crash

Step 0: Get SMOD
    Log  Step 0: Get SMOD  console=true
    Should Not Be Empty  ${SMOD_TYPE}  msg=SMOD Type not provided. Test will not continue.
    Log  Start collecting snapshot to clear logs. Timeout is 20 minutes.  console=true
    Wait until keyword succeeds  5x  1m  Collect Snapshot  ${UDPLogs}/snapshot_before_test.zip
    ...                                                    timeout=20m
    Log  Snapshot collected.  console=true
    ${position_maping}  Create Dictionary  '1'=LeftSide  '2'=RightSide
    ${smod_list}  get_fsm_info
    ${available_smod}  Create list
    FOR  ${smod}  IN  @{smod_list}
        Run Keyword If  '${SMOD_TYPE}' in '${smod}[productName]'
        ...  Append to list  ${available_smod}  ${smod}
    END
    Should Not Be Empty  ${available_smod}  msg=SMOD Type not available. Test will not continue.
    ${chosen_smod}  Evaluate  random.choice(${available_smod})  random
    ${status}  Run keyword and return status  Get From Dictionary  ${chosen_smod}  activeRole
    ${SMOD_ROLE}  Set Variable if  ${status}  ${chosen_smod}[activeRole]  SMOD1
    Log  ${SMOD_ROLE} smod will be crashed.  console=true
    Open connection to primary core
    Run keyword if  '${SMOD_ROLE}'=='Secondary'  Open connection to secondary core

Step 1: Start threads on SMOD
    Log  Step 1: Start threads on SMOD  console=true
    Log  Put python file to /tmp/${THREADS_PY_NAME}  console=true
    Put File  ${THREADS_PY_LOCATION}/${THREADS_PY_NAME}
    ...       /tmp/${THREADS_PY_NAME}
    ${execution_command}  Set variable if  '${SMOD_TYPE}'=='ASIA'
    ...                                    for i in {0..10}; do python3 /tmp/${THREADS_PY_NAME} & done
    ...                                    python3 /tmp/${THREADS_PY_NAME}
    SSHLibrary.write  ${execution_command}
    ${output}  Run keyword and ignore error  SSHLibrary.Read Until Prompt
    Log  ${output}[1]  console=true
    Sleep  120  Added to allow SMOD to reset.

Step 2: Wait SMOD Recovery after threads crash
    Log  Step 2: Wait SMOD Recovery after threads crash  console=true
    Assert Every  SMOD  operationalState=${Enabled_}  timeout=${RECOVERY_TIMEOUT}

Step 3: Check SMOD Fault Signature
    Log  Step 3: Check SMOD Fault Signature  console=true
    Log  Collecting snapshot to ${UDPLogs}/${SNAPSHOT_FILE_NAME} timeout is ${COLLECT_SNAPSHOT_TIMEOUT}.  console=true
    Wait until keyword succeeds  ${SNAPSHOT_RETRY_COUNT}x  1m  Collect Snapshot  ${UDPLogs}/${SNAPSHOT_FILE_NAME}
    ...                                                                          timeout=${COLLECT_SNAPSHOT_TIMEOUT}
    Log  Snapshot collected.  console=true
    ${bts_id}  Admin Get BTS ID
    extract_snapshot_content  ${UDPLogs}/${SNAPSHOT_FILE_NAME}  BTS${bts_id}_${ARCHIVE_TO_CHECK}
    ${result}  check_snapshot_content  ${UDPLogs}/${LOG_TO_CHECK}  ${SNAPSHOT_LOG}
    Should not be empty  ${result}  ${SNAPSHOT_LOG} log not found in BTS${bts_id}_1011_startup.zip startup_HWAPI.log.xz
    Log  ${result}  console=true

Step 4: Waiting for complete SBTS recovery after SMOD threads crash
    Log  Step 4: Waiting for complete SBTS recovery after SMOD threads crash.  console=true
    Log  Timeout is ${RECOVERY_TIMEOUT}s.  console=true
    Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    coam.Get Alarm History

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Perform site reset
    Common Test Teardown


