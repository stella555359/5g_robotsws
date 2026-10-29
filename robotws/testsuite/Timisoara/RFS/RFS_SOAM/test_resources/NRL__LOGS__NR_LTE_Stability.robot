*** Settings ***
Documentation    TC__NRL__LOGS__NR_LTE_Stability
Variables    tc_variables/nrl__logs__nr_lte_stability_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${STABILITY_PERIOD}  60  # Stability period (wait period) in minutes
${CHECKS_INTERVAL}   10  # Interval in minutes to repeat checks during stability period
${TECH}            None  # NR / LTE / None. Default value is None which means, no SW version check will be done.
${Target SW name}  None  # Name of SW / None. If no SW name is given, the latest package from the folder will be taken
${Target SW dir}   None  # Folder where SW is located / None. Default values are /home/ute/TARGET_SW_MASTER / /home/ute/TARGET_SW_SLAVE
                         # (depending on SM argument) Select STABILITY_PERIOD = 0 and CHECKS_INTERVAL = 0 for just one run of the checks
                         # with no waiting time.

*** Keywords ***
TC__NRL__LOGS__NR_LTE_Stability
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21427
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case which implements a wait period during which, a periodic check of NR and LTE is done
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21427 -
    ...  [5G][MT] New TC NRL: NRL__LOGS__NR_LTE_Stability, to check SW from BTS against user given SW version
    ...  - 06.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21775 - [5G][Legacy][RFSplit] Test NRL Common Part (hran_ta)
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21427_NRL__LOGS__NR_LTE_Stability.png

    Set Tags    CA-STATE    OWNER-alexandra.danciu@nokia.com    AUTHOR-lia.caraiman@nokia.com    PHASE-QT    SW-SBTS21B

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
        Run Keyword If  '${TECH}'!='None'
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
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Check SW version
    [Documentation]
    ...  Check if SW version on Master or Slave is the desired one.
    ...  This TC can be used in conjunction with stop_on_fail flag, to stop a test campaign if the SW is the wrong one
    ...
    [Timeout]  5 min
    Log  Step ${index}: Check SW version  console=True
    ${Target SW dir}=  Set Variable If  '${TECH}'=='NR' and '${Target SW dir}'=='None'  /home/ute/btsauto/TARGET_SW_MASTER  ${Target SW dir}
    ${Target SW dir}=  Set Variable If  '${TECH}'=='LTE' and '${Target SW dir}'=='None'  /home/ute/btsauto/TARGET_SW_SLAVE  ${Target SW dir}
    Run Keyword If  '${TECH}'!='NR' and '${TECH}'!='LTE'
    ...  Run Keywords  Log  Wrong value for 'TECH' argument  level=WARN
    ...  AND  Return From Keyword
    rfs_frame_rfs_common.Get SW Versions On All Sites SOAM
    ${Target SW tmp}=  Run Keyword If  '${Target SW name}'=='None'  Get SW file for SWDL  ${Target SW dir}  ${Target SW name}
    ...  ELSE  Set Variable  ${Target SW name}
    Log  Checking presence of ${TECH} SW: ${Target SW tmp}  console=True
    ${arg_NR}=  Set Variable  ${Master active SW}
    ${arg_LTE}=  Set Variable  ${Slave active SW}
    ${target is active}=  Run Keyword And Return Status  Should Match Regexp  ${Target SW tmp}  (?i).*${arg_${TECH}}(?!T[12]).*
    Run Keyword If  ${target is active}
    ...  Log  ${TECH} SW: ${Target SW tmp} is active on BTS  console=True
    ...  ELSE  Run Keywords  Log  ${TECH} SW: ${Target SW tmp} is not active on BTS  level=ERROR
    ...  AND  Fail

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
