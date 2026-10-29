*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__LOGS__Stability
Variables    tc_variables/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${STABILITY_PERIOD}  60   # Stability period (wait period) in minutes
${CHECKS_INTERVAL}   10   # Interval in minutes to repeat checks during stability period
                          # (depending on SM argument) Select STABILITY_PERIOD = 0 and CHECKS_INTERVAL = 0 for just one run of the checks
                          # with no waiting time.
${CHECK_SW_VERSION}  True                           # Flag for Checking the active Software; Possible values: True, False; default value: True
${FORCE_CURRENT_SW_CHECK}  False                    # Force current reservation SW build check, in offline running it needs variable ENB_BUILD to
                                                    # be defined in argfile.txt
${Target SW name BTS1}  None                        # Name of SW / None. If no SW name is given, the latest package from the folder will be taken
${Target SW dir BTS1}   /home/ute/TARGET_SW_MASTER  # Folder where SW is located / None. Default values are /home/ute/TARGET_SW_MASTER
${Target SW name BTS2}  None                        # Name of SW / None. If no SW name is given, the latest package from the folder will be taken
${Target SW dir BTS2}   /home/ute/TARGET_SW_SLAVE   # Folder where SW is located / None. Default values are /home/ute/TARGET_SW_SLAVE
${Target SW name BTS3}  None                        # Name of SW / None. If no SW name is given, the latest package from the folder will be taken
${Target SW dir BTS3}   /home/ute/TARGET_SW_SLAVE1  # Folder where SW is located / None. Default values are /home/ute/TARGET_SW_SLAVE1
${Target SW name BTS4}  None                        # Name of SW / None. If no SW name is given, the latest package from the folder will be taken
${Target SW dir BTS4}   /home/ute/TARGET_SW_SLAVE2  # Folder where SW is located / None. Default values are /home/ute/TARGET_SW_SLAVE2

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25743
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case which implements a wait period during which, a periodic check of every BTS is done
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 20.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25743 - [5G] Create new SBTS_SBTS Stability TC
    ...  - 29.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27546 -
    ...  [5G] [Infomodel] Eliminate infomdel usage in test SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25743_SBTS_SBTS_SBTS_SBTS__LOGS__Stability.png

    Set Tags    CA-STATE    OWNER-valentin.marian@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS24R1

    Run Keyword If  ${STABILITY_PERIOD} < ${CHECKS_INTERVAL}  Run Keywords
    ...  Log  User defined STABILITY_PERIOD (${STABILITY_PERIOD} minutes) not greater than CHECKS_INTERVAL (${CHECKS_INTERVAL} minutes)  console=True
    ...  AND  Fail  User defined STABILITY_PERIOD (in minutes) must be greater than CHECKS_INTERVAL (in minutes)
    ${check total duration}=  Evaluate  0
    FOR  ${INDEX}  IN RANGE  1  10000
        ${time begin}=  Get Time
        Log     ==============================================================================  console=True
        Log     Start Check Number: ${INDEX}  console=True
        Log     ==============================================================================  console=True
        Step 1: Check all BTS state
        Step 2: Check all BTS alarms
        Step 3: Check final number and state of Cells and RMs
        Run Keyword If  ${CHECK_SW_VERSION}
        ...  Step 4: Check SW version
        ${time end}=  Get Time
        ${check duration}=  Subtract Date From Date  ${time end}  ${time begin}
        ${check total duration}=  Evaluate  ${check total duration} + ${check duration} #add check duration
        ${check time left}=  Subtract Time From Time  ${STABILITY_PERIOD} minutes  ${check_total_duration}
        Run Keyword If  ${check time left} < 0  Exit For Loop
        ${sleep period}=  Subtract Time From Time  ${CHECKS_INTERVAL} minutes  ${check duration}
        ${sleep period}=  Evaluate  ${sleep period} if ${sleep period} > 0 else 0
        Log  Wait for ${sleep period} seconds  console=True
        Sleep  ${sleep period} seconds
        ${check total duration}=  Evaluate  ${check total duration} + ${sleep period}  #add sleep duration
    END

Step ${index}: Check all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view. Works
    ...  for NR and LTE technologies.
    ...  Also check RMs operationalState
    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks  wait_timer=18 min

Step ${index}: Check SW version
    Log  Step ${index}: Check SW version  console=True
    Get SW versions from all BTS partitions
    FOR  ${alias}  IN  @{alias_list}
        Check SW version on BTS ${alias}
    END

Check SW version on BTS ${alias}
    [Documentation]
    ...  Check if SW version on ${alias} is the desired one.
    ...  This TC can be used in conjunction with stop_on_fail flag, to stop a test campaign if the SW is the wrong one
    ...
    [Timeout]  5 min
    ${BTS}=  Set Variable If
    ...  '${alias}' == 'Master'  BTS1
    ...  '${alias}' == 'Slave'  BTS2
    ...  '${alias}' == 'Slave1'  BTS3
    ...  '${alias}' == 'Slave2'  BTS4
    ${Target SW}=  Run Keyword If  ${FORCE_CURRENT_SW_CHECK}
    ...  Check argfile and return target SW
    ...  ELSE IF  '${Target SW name ${BTS}}' != 'None'
    ...  Set Variable  ${Target SW name ${BTS}}
    ...  ELSE  Get SW file for SWDL  ${Target SW dir ${BTS}}  ${Target SW name ${BTS}}

    Run Keyword If  '${Target SW name ${BTS}}' == 'None' and not ${FORCE_CURRENT_SW_CHECK}
    ...  Rename Software Package  ${Target SW}

    Log  Checking presence of ${BTS} SW: ${Target SW}  console=True
    ${target is active}=  Run Keyword And Return Status  Should Match Regexp  ${Target SW}  (?i).*${${alias} active SW}.*
    Run Keyword If  ${target is active}
    ...  Log  ${BTS} SW: ${Target SW} is active on BTS  console=True
    ...  ELSE  Run Keywords  Log  ${BTS} SW: ${Target SW} is not active on BTS  level=ERROR
    ...  AND  Fail  Target SW is not active on BTS

Get SW versions from all BTS partitions

    Log  Get SW versions from all BTS partitions  console=True
    FOR  ${alias}  IN  @{alias_list}
        Admin Get BTS SW Version  alias=${alias}
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
