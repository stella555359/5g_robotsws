*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot
Library     ../../common_resources/python_resources/snapshot_check.py


*** Variables ***
${BBMOD_TYPE}                                                         # Mandatory, specify the SMOD type where the processes will run
${RECOVERY_TIMEOUT}          900
${COMMAND}                   :(){ :|:& };:                            # Command to start processes, do not change.
${COLLECT_SNAPSHOT_TIMEOUT}  1200
${SNAPSHOT_FILE_NAME}        processes_snapshot_${BBMOD_TYPE}.zip     # Snapshot name.
${SNAPSHOT_RETRY_COUNT}      20                                       # Times to retry to collect snapshot.
${SNAPSHOT_LOG}              FAULT_SIGNATURE                          # What to look for in snapshot.
${ARCHIVE_TO_CHECK}          1011_startup.zip                         # ZIP name is BTS10718_1011_startup.zip, only '1011_startup.zip' must pe given.
${LOG_TO_CHECK}              startup_HWAPI.log.xz                     # Log file where test should look.


*** Keywords ***
TC__FM__BBMOD_recovery_insufficient_resources_processes
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25210
    ...  Test will randomly choose one BBMOD wich is the same type as the one provided.
    ...  Fork bomb command will be executed.
    ...  After recovery, snapshot will be collected and will check if FAULT_SIGNATURE is seen.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25210 - Initial TAT creation
    ...  - 03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  *******************

    Set Tags    CA-FM    OWNER-lucian.ciurel@nokia.com    AUTHOR-bogdan.boldurean@nokia.com
    ...         MAINTAINER-bogdan.boldurean@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    CNI-97248

    Step 0: Get BBMOD
    Step 1: Start processes
    Step 2: Wait BBMOD Recovery after processes crash
    Step 3: Check Snapshot for BBMOD Fault Signature
    Step 4: Waiting for complete SBTS recovery after processes crash

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
    ${status}  Run keyword and return status  Get From Dictionary  ${chosen_smod}  activeRole
    ${SMOD_ROLE}  Set Variable if  ${status}  ${chosen_smod}[activeRole]  SMOD1
    Open connection to primary core
    Run keyword if  '${SMOD_ROLE}'=='Secondary'  Open connection to secondary core
    ${ssh_alias}  Set Variable If  '${SMOD_ROLE}'=='Secondary'  secondary_ssh  primary_ssh
    Run Keyword if  'ASIA' in '${SMOD_TYPE}'
    ...  Connect to BBMOD using ssh  ${vertical}  ${ssh_alias}
    ...  ELSE
    ...  Connect to BBMOD using bsh  ${vertical}

Step 1: Start processes
    Log  Step 1: Start processes  console=true
    SSHLibrary.write  ${COMMAND}
    Run keyword and return status  Assert Any  BBMOD  operationalState=${Disabled_}  timeout=60
    Sleep  30

Step 2: Wait BBMOD Recovery after processes crash
    Log  Step 2: Wait BBMOD Recovery after processes crash  console=true
    Assert Every  BBMOD  operationalState=${Enabled_}  timeout=${RECOVERY_TIMEOUT}
    Log  Collecting snapshot to ${UDPLogs}/${SNAPSHOT_FILE_NAME} timeout is ${COLLECT_SNAPSHOT_TIMEOUT}.  console=true
    Wait until keyword succeeds  ${SNAPSHOT_RETRY_COUNT}x  1m  Collect Snapshot  ${UDPLogs}/${SNAPSHOT_FILE_NAME}
    ...               timeout=${COLLECT_SNAPSHOT_TIMEOUT}
    Log  Snapshot collected.  console=true

Step 3: Check Snapshot for BBMOD Fault Signature
    Log  Step 3: Check Snapshot for BBMOD Fault Signature  console=true
    ${bts_id}  Admin Get BTS ID
    extract_snapshot_content  ${UDPLogs}/${SNAPSHOT_FILE_NAME}  BTS${bts_id}_${ARCHIVE_TO_CHECK}
    ${result}  check_snapshot_content  ${UDPLogs}/${LOG_TO_CHECK}  ${SNAPSHOT_LOG}
    Should not be empty  ${result}  ${SNAPSHOT_LOG} log not found in BTS${bts_id}_1011_startup.zip startup_HWAPI.log.xz
    Log  ${result}  console=true

Step 4: Waiting for complete SBTS recovery after processes crash
    Log  Step 4: Waiting for complete SBTS recovery after processes crash.  console=true
    Log  Timeout is ${RECOVERY_TIMEOUT}s.  console=true
    Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    coam.Get Alarm History


TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Perform site reset
    Common Test Teardown


