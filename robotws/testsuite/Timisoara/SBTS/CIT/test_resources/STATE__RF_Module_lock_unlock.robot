*** Settings ***
Documentation
    ...  Verification of radio module lock/unlock function in SBTS
    ...  LTE_OPR_REQ_18290, LTE_OPR_REQ_26392, LTE_OPR_REQ_21073
    ...  verify rmod states: administrativeState, usageState
    ...   cell states: availabilityStatus, operationalState
    ...  unlocked   -> Rmod states: administrativeState=unlocked. Cell states:  operationalState=enabled
    ...  locked     -> Rmod states: administrativeState=locked, usageState=idle.states: availabilityStatus=Dependency, operationalState=Disabled
    ...  Steps:
    ...   TC Preconditions
    ...   Step 1: Radio lock operation is trigerred via ADMIN API
    ...   Step 2: Verify Rmods and Cells status after lock
    ...   Step 3: Check active alarms
    ...   Step 4: Radio unlock operation is trigerred via ADMIN API
    ...   Step 5: Verify Rmods and Cells status after unlock
    ...   Step 6: Check active alarms

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # Serial number of radio module  to be locked, default are all radio modules
${RESTORE_TIMEOUT}  10m  # Timeout for waiting until cells are onAir/notOnAir in Robot Framework format (600s, 10m)
${LOG_TX_POWER}  False  # If set True, test log to console al radio modules Tx powers


*** Keywords ***
TC__RF_Module_lock_unlock
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-20362
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.10.2020 - https://jira3.int.net.nokia.com/browse/TAT-20362 - New TC
    ...  - 20.11.2020 - https://jira3.int.net.nokia.com/browse/TAT-20520 - rmod cell list correction
    ...  - 19.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22220 - [CNI-61110] Tests refactoring
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  *******************

    Set Tags  CA-STATE  PHASE-CIT  GROUP_IN_CHARGE-WRO_8_Vrf  SW-SBTS21  OWNER-grzegorz.gulaj@nokia.com  AUTHOR-grzegorz.gulaj@nokia.com
    ...  MAINTAINER-przemyslaw.kempa@nokia.com  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923  FEATURE-RP001486_RP000923
    ...  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    TC Preconditions
    Step 1: Radio Lock Operation Is Trigerred Via ADMIN API
    Step 2: Verify Rmods And Cells Status After Lock
    Step 3: Check Active Alarms
    Step 4: Radio Unlock Operation Is Trigerred Via ADMIN API
    Step 5: Verify Rmods And Cells Status After Unlock
    Step 6: Check Active Alarms


TC Preconditions
    Log  Preconditions.  console=true
    Assert Every  RMOD  ${STATES_ONAIR_RMOD}
    ${is_lte}  Run Keyword And Return Status
    ...  Query Infomodel  //LNCEL_R-*
    Run Keyword If  ${is_lte}
    ...  Assert Every  LNCEL  ${STATES_ONAIR_LG}
    ${is_wcdma}  Run Keyword And Return Status
    ...  Query Infomodel  //WNCEL_R-*
    Run Keyword If  ${is_wcdma}
    ...  Assert Every  WNCEL  ${STATES_ONAIR_WCDMA}
    ${is_gsm}  Run Keyword And Return Status
    ...  Query Infomodel  //GNCEL_R-*
    Run Keyword If  ${is_gsm}
    ...  Assert Every  GNCEL  ${STATES_ONAIR_LG}
    Setup Alarm Checking
    _Preparing Variables
    Run Keyword If  ${LOG_TX_POWER}
    ...  Log All Tx Power


Step 1: Radio Lock Operation Is Trigerred Via ADMIN API
    Log  Step 1: Radio lock operation is trigerred via ADMIN API.  console=true
    Lock Rmods


Step 2: Verify Rmods And Cells Status After Lock
    Log  Step 2: Verify Rmods and Cells status after lock.  console=true
    Log  \tChecking affected rmods.  console=true
    Check Affected Rmods
    Log  \tChecking unaffected rmods.  console=true
    Check Unaffected Rmods
    Log  \tChecking affected cells.  console=true
    Run Keyword If  ${TESTING_ALL_RM}==${False}
    ...  Check If Affected Cells Are Degraded
    Check If Affected Cells Are In Dependency State
    Log  \tChecking unaffected cells.  console=true
    Check If Unaffected Cells Are OnAir
    Run Keyword If  ${LOG_TX_POWER}
    ...  Log All Tx Power


Step 4: Radio Unlock Operation Is Trigerred Via ADMIN API
    Log  Step 4: Radio unblock operation is trigerred via ADMIN API.  console=true
    Unlock Rmods


Step 5: Verify Rmods And Cells Status After Unlock
    Log  Step 5: RMOD and cells states are verified.  console=true
    Check All Rmods
    Check If Affected Cells Are OnAir
    Check If Unaffected Cells Are OnAir


Step ${step_no}: Check Active Alarms
    Log  Step ${step_no}: Check active alarms.  console=true
    &{ignored_fault_4592}  Create Dictionary  faultId=${FAULT_4592}[fault_id]  faultName=${FAULT_4592}[fault_name]
    ${ignored_alarms}  Create List  ${ignored_fault_4592}
    Final Alarm Checking  ${ignored_alarms}


Check If Affected Cells Are OnAir
    FOR  ${cell}  IN  @{CELLS_LIST}
        ${is_lte}  Run Keyword And Return Status
        ...  Should Contain  ${LNCEL}  ${cell}
        Run Keyword If  ${is_lte}
        ...  Check Object Expected States  LNCEL  ${cell}  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
        ${is_wcdma}  Run Keyword And Return Status
        ...  Should Contain  ${WNCEL}  ${cell}
        Run Keyword If  ${is_wcdma}
        ...  Check Object Expected States  WNCEL  ${cell}  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
        ${is_gsm}  Run Keyword And Return Status
        ...  Should Contain  ${GNCEL}  ${cell}
        Run Keyword If  ${is_gsm}
        ...  Check Object Expected States  GNCEL  ${cell}  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
    END


Check If Affected Cells Are In Dependency State
    FOR  ${cell}  IN  @{FAILED_CELLS_LIST}
        ${is_lte}  Run Keyword And Return Status
        ...  Should Contain  ${LNCEL}  ${cell}
        Run Keyword If  ${is_lte}
        ...  Check Object Expected States  LNCEL  ${cell}  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)Dependency"
        ${is_wcdma}  Run Keyword And Return Status
        ...  Should Contain  ${WNCEL}  ${cell}
        Run Keyword If  ${is_wcdma}
        ...  Check Object Expected States  WNCEL  ${cell}  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)Dependency"
        ${is_gsm}  Run Keyword And Return Status
        ...  Should Contain  ${GNCEL}  ${cell}
        Run Keyword If  ${is_gsm}
        ...  Check Object Expected States  GNCEL  ${cell}  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)Dependency"
    END


Check If Unaffected Cells Are Onair
    ${on_air_cells}  Copy List  ${CELLS_LIST}  deepcopy=True
    Remove Values From List  ${on_air_cells}  @{FAILED_CELLS_LIST}
    Remove Values From List  ${on_air_cells}  @{DEGRADED_CELLS_LIST}
    FOR  ${cell}  IN  @{on_air_cells}
        ${is_lte}  Run Keyword And Return Status
        ...  Should Contain  ${LNCEL}  ${cell}
        Run Keyword If  ${is_lte}
        ...  Check Object Expected States  LNCEL  ${cell}  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
        ${is_wcdma}  Run Keyword And Return Status
        ...  Should Contain  ${WNCEL}  ${cell}
        Run Keyword If  ${is_wcdma}
        ...  Check Object Expected States  WNCEL  ${cell}  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
        ${is_gsm}  Run Keyword And Return Status
        ...  Should Contain  ${GNCEL}  ${cell}
        Run Keyword If  ${is_gsm}
        ...  Check Object Expected States  GNCEL  ${cell}  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
    END


Check Affected Rmods
    FOR  ${rmod}  IN  @{RMOD_LIST}
        Check Object Expected States  RMOD  ${rmod}  administrativeState=regex"(?i)Locked", usageState=regex"(?i)Idle"
        # Query Infomodel  ${rmod} is [stateInfo.administrativeState=Locked, stateInfo.usageState=Idle]
    END


Check Unaffected Rmods
    ${on_air_rmods}  Get Ids For All  RMOD
    Remove Values From List  ${on_air_rmods}  @{RMOD_LIST}
    FOR  ${rmod}  IN  @{on_air_rmods}
        Check Object Expected States  RMOD  ${rmod}  administrativeState=regex"(?i)Unlocked"
    END


Check All Rmods
    ${all_rmods}  Get Ids For All  RMOD
    FOR  ${rmod}  IN  @{all_rmods}
        Check Object Expected States  RMOD  ${rmod}  administrativeState=regex"(?i)Unlocked"
    END


Check If Affected Cells Are Degraded
    FOR  ${cell}  IN  @{DEGRADED_CELLS_LIST}
        ${is_lte}  Run Keyword And Return Status
        ...  Should Contain  ${LNCEL}  ${cell}
        Run Keyword If  ${is_lte}
        ...  Check Object Expected States  LNCEL  ${cell}  availabilityStatus=regex"(?i)Degraded"
        ${is_wcdma}  Run Keyword And Return Status
        ...  Should Contain  ${WNCEL}  ${cell}
        Run Keyword If  ${is_wcdma}
        ...  Check Object Expected States  WNCEL  ${cell}  availabilityStatus=regex"(?i)Degraded"
        ${is_gsm}  Run Keyword And Return Status
        ...  Should Contain  ${GNCEL}  ${cell}
        Run Keyword If  ${is_gsm}
        ...  Check Object Expected States  GNCEL  ${cell}  availabilityStatus=regex"(?i)Degraded"
        # query infomodel  ${cell} is [stateInfo.availabilityStatus=regex"Degraded"]  timeout=${RESTORE_TIMEOUT}
    END


Lock Rmods
    FOR  ${rm}  IN  @{RMOD_LIST}
        Log  \tLock radio ${rm}  console=true
        Lock  ${rm}  timeout=300s
    END


Unlock Rmods
    FOR  ${rm}  IN  @{RMOD_LIST}
        Log  \tUnlock radio ${rm}  console=true
        Unlock  ${rm}  timeout=300s
    END


_Get All Cells
    ${lncel}  Get Ids For All  LNCEL
    ${wncel}  Get Ids For All  WNCEL
    ${gncel}  Get Ids For All  GNCEL
    ${cells_list}  Evaluate  [cell_dn for cell_dn in ${lncel}+${wncel}+${gncel} if 'RUNTIME_VIEW' in cell_dn]
    Set Test Variable  ${CELLS_LIST}
    Set Test Variable  ${LNCEL}  ${lncel}
    Set Test Variable  ${WNCEL}  ${wncel}
    Set Test Variable  ${GNCEL}  ${gncel}


_Preparing Variables
    _Get All Cells
    Run Keyword If  '${RMOD_SN}'==''
    ...  _Preparing For All Radio Modules Testing
    ...  ELSE
    ...  _Preparing For One Radio Module Testing


_Preparing For All Radio Modules Testing
    Set Test Variable  ${TESTING_ALL_RM}  ${True}
    ${all_rm}  Get Ids For All  RMOD
    ${degraded_cells_list}  Create List
    Set Test Variable  ${RMOD_LIST}  ${all_rm}
    Set Test Variable  ${DEGRADED_CELLS_LIST}  ${degraded_cells_list}
    Set Test Variable  ${FAILED_CELLS_LIST}  ${CELLS_LIST}
    Log  All radio modules will be tested.  console=true


_Preparing For One Radio Module Testing
    Set Test Variable  ${TESTING_ALL_RM}  ${False}
    ${rm}  Query Infomodel  get object //EQM_R-*//RMOD_R-* is [serialNumber="${RMOD_SN}"]
    ${rmod_a_distname}  Query Infomodel  get object ${rm.dist_name}/CONF_REF-1
    ${rmod_a}  Fetch From Right  ${rmod_a_distname.distName}  /
    ${rm_cells_list}  Get Cell Mapping By Module Id  ${rm.dist_name}
    ${not_on_rmod}  Get Cells Out Of Rmod  ${rm_cells_list}  ${rmod_a}
    Remove Values From List  ${rm_cells_list}  @{not_on_rmod}
    ${cells_fail_state}  Get List Of Fail Cells If Rmod Will Be Blocked  ${RMOD_SN}
    ${degraded_cells_list}  Copy List  ${rm_cells_list}
    Remove Values From List  ${degraded_cells_list}  @{cells_fail_state}
    Set Test Variable  ${DEGRADED_CELLS_LIST}  ${degraded_cells_list}
    Log To Console  degraded:${DEGRADED_CELLS_LIST}
    Set Test Variable  ${FAILED_CELLS_LIST}  ${cells_fail_state}
    Log To Console  failed:${FAILED_CELLS_LIST}
    Set Test Variable  ${CELLS_LIST}  ${rm_cells_list}
    Log To Console  all:${CELLS_LIST}
    Set Test Variable  @{RMOD_LIST}  ${rm.dist_name}
    Log  Radio module ${RMOD_SN} will be tested.  console=true


Custom Test Teardown
    Run Keyword If Test Failed
    ...  Run Keywords
    ...  Log  Test Fail - unlocking rmods  console=true
    ...  AND
    ...  Unlock Rmods
    Common Test Teardown


TC Setup
    Common Test Setup  tc_name=STATE__RF_Module_lock_unlock


TC Teardown
    Run Keywords
    ...  STATE__RF_Module_lock_unlock.Custom Test Teardown
