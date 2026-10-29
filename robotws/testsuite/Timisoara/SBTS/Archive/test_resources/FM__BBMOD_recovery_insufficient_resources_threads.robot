*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot
Library     ../../common_resources/python_resources/snapshot_check.py


*** Variables ***
${BBMOD_TYPE}                                                         # Mandatory, specify the BBMOD type where the processes will run
${RECOVERY_TIMEOUT}          900
${COLLECT_SNAPSHOT_TIMEOUT}  1200
${SNAPSHOT_FILE_NAME}        threads_snapshot_${BBMOD_TYPE}.zip       # Snapshot name.
${SNAPSHOT_RETRY_COUNT}      20                                       # Times to retry to collect snapshot.
${THREADS_PY_LOCATION}       ${CURDIR}/python_scripts                 # Python file location.
${THREADS_PY_NAME}           crash_threads.py                         # Python file to be executed.
${SNAPSHOT_LOG}              THREAD_OVERLOAD_PERSISTENT_RESET_INFO    # What to look for in snapshot.
${ARCHIVE_TO_CHECK}          1011_startup.zip                         # ZIP name is BTS10718_1011_startup.zip, only '1011_startup.zip' must pe given.
${LOG_TO_CHECK}              startup_HWAPI.log.xz                     # Log file where test should look.


*** Keywords ***
TC__FM__BBMOD_recovery_insufficient_resources_threads
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25209
    ...  Test will randomly choose one BBMOD wich is the same type as the one provided.
    ...  Python file that triggers multiples threads will pe uploaded to /tmp folder and started. For ABIA boards it will start 100 times in a loop.
    ...  for all other boards, single python script will be run.
    ...  After recovery, snapshot will be collected and will check if FAULT_SIGNATURE is seen.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25209 - Initial TAT creation
    ...  - 03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  *******************

    Set Tags    CA-FM    OWNER-lucian.ciurel@nokia.com      AUTHOR-bogdan.boldurean@nokia.com
    ...         MAINTAINER-bogdan.boldurean@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    CNI-97248

    Step 0: Get BBMOD
    Step 1: Put file to BBMOD
    Step 2: Start processes on BBMOD
    Step 3: Wait BBMOD Recovery after threads crash
    Step 4: Check BBMOD Fault Signature
    Step 5: Waiting for complete SBTS recovery after threads crash

Step 0: Get BBMOD
    Log variables
    Log  Step 0: Get BBMOD  console=true
    Should Not Be Empty  ${BBMOD_TYPE}  msg=BBMOD Type not provided. Test will not continue.
    Log  Start collecting snapshot to clear logs. Timeout is 20 minutes.  console=true
    Wait until keyword succeeds  5x  1m  Collect Snapshot  ${UDPLogs}/snapshot_before_test.zip
    ...                                                    timeout=20m
    Log  Snapshot collected.  console=true
    ${fbb_info}  Get FBB Info
    ${bbmods}  Create list
    FOR  ${bbmod}  IN  @{fbb_info}
        Run keyword if  '${BBMOD_TYPE}' in '${bbmod}[productName]'
        ...  Append to list  ${bbmods}  ${bbmod}
    END
    ${the_choseon_one}  Evaluate  random.choice(${bbmods})  random
    ${vertical}  Get module vertical position  ${the_choseon_one}[id][internal]
    ${horizontal}  Get BBMOD horizontal position  ${the_choseon_one}[id][internal]
    ${position_maping}  Create Dictionary  '1'=LeftSide  '2'=RightSide
    ${smod_list}  get_fsm_info
    FOR  ${smod}  IN  @{smod_list}
        Exit for loop if  '${smod}[positionInSubrack]'=='${position_maping}['${horizontal}']'
    END
    ${SMOD_TYPE}  Set variable  ${smod}[productName]
    Set test Variable  ${SMOD_TYPE}
    Set test Variable  ${BBMOD_VERTICAL_POSITION}  ${vertical}
    ${SMOD_ROLE}  Set variable  ${smod}[activeRole]
    Open connection to primary core
    Run keyword if  '${SMOD_ROLE}'=='Secondary'  Open connection to secondary core
    ${ssh_alias}  Set Variable If  '${SMOD_ROLE}'=='Secondary'  secondary_ssh  primary_ssh
    Set test Variable  ${SSH_ALIAS}

Step 1: Put file to BBMOD
    Log  Step 1: Put file to BBMOD  console=true
    Put File  ${THREADS_PY_LOCATION}/${THREADS_PY_NAME}
    ...       /tmp/${THREADS_PY_NAME}
    SSHLibrary.write  cp /tmp/${THREADS_PY_NAME} /ffs/run/logs/${THREADS_PY_NAME}
    ${output}  SSHLibrary.Read Until Prompt
    Run Keyword if  'ASIA' in '${SMOD_TYPE}'
    ...  Connect to BBMOD using ssh  ${BBMOD_VERTICAL_POSITION}  ${SSH_ALIAS}
    ...  ELSE
    ...  Connect to BBMOD using bsh  ${BBMOD_VERTICAL_POSITION}
    SSHLibrary.write  cp /ffs/run/logs/${THREADS_PY_NAME} /tmp/${THREADS_PY_NAME}
    ${output}  SSHLibrary.Read Until Prompt
    SSHLibrary.write  rm /ffs/run/logs/${THREADS_PY_NAME}
    ${output}  SSHLibrary.Read Until Prompt

Step 2: Start processes on BBMOD
    Log  Step 2: Start processes on BBMOD  console=true
    ${execution_command}  Set variable if  '${BBMOD_TYPE}'=='ABIA'
    ...                                    for i in {0..100}; do python3 /tmp/${THREADS_PY_NAME} & done
    ...                                    python3 /tmp/${THREADS_PY_NAME}
    SSHLibrary.write  ${execution_command}
    ${output}  Run keyword and ignore error  SSHLibrary.Read Until Prompt
    Log  ${output}[1]  console=true
    Log  Crash sent. Wait for BBMOD to be disabled.  console=true
    Assert Any  BBMOD  operationalState=${Disabled_}  timeout=60

Step 3: Wait BBMOD Recovery after threads crash
    Log  Step 3: Wait BBMOD Recovery after threads crash  console=true
    Run keyword and return status  Assert Every  BBMOD  operationalState=${Enabled_}  timeout=${RECOVERY_TIMEOUT}

Step 4: Check BBMOD Fault Signature
    Log  Step 4: Check BBMOD Fault Signature  console=true
    Log  Collecting snapshot to ${UDPLogs}/${SNAPSHOT_FILE_NAME} timeout is ${COLLECT_SNAPSHOT_TIMEOUT}.  console=true
    Wait until keyword succeeds  ${SNAPSHOT_RETRY_COUNT}x  1m  Collect Snapshot  ${UDPLogs}/${SNAPSHOT_FILE_NAME}
    ...                                                                          timeout=${COLLECT_SNAPSHOT_TIMEOUT}
    Log  Snapshot collected.  console=true
    ${bts_id}  Admin Get BTS ID
    extract_snapshot_content  ${UDPLogs}/${SNAPSHOT_FILE_NAME}  BTS${bts_id}_${ARCHIVE_TO_CHECK}
    ${result}  check_snapshot_content  ${UDPLogs}/${LOG_TO_CHECK}  ${SNAPSHOT_LOG}
    Should not be empty  ${result}  ${SNAPSHOT_LOG} log not found in BTS${bts_id}_1011_startup.zip startup_HWAPI.log.xz
    Log  ${result}  console=true

Step 5: Waiting for complete SBTS recovery after threads crash
    Log  Step 5: Waiting for complete SBTS recovery after threads crash.  console=true
    Log  Timeout is ${RECOVERY_TIMEOUT}s.  console=true
    Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    coam.Get Alarm History


TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Perform site reset
    Common Test Teardown


