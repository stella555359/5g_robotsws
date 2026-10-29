*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RMOD_SN}    	   #Serial number of radio module  to be locked, default are all radio modules
${RESTORE_TIMEOUT}  10m     #Timeout for waiting until cells are onAir/notOnAir in Robot Framework format (600s, 10m)


*** Keywords ***
TC__WebEM__RF_Module_lock_unlock
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-20362
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Verification of radio module lock/unlock function in SBTS
    ...  LTE_OPR_REQ_18290, LTE_OPR_REQ_26392, LTE_OPR_REQ_21073
    ...  verify rmod states: administrativeState, usageState
    ...         cell states: availabilityStatus, operationalState
    ...  unlocked  -> Rmod states: administrativeState=unlocked. Cell states:  operationalState=enabled
    ...  locked  -> Rmod states: administrativeState=locked, usageState=idle. Cell states: availabilityStatus=Dependency, operationalState=Disabled
    ...
    ...  Steps:
    ...     TC Preconditions
    ...     Step 1: Radio lock operation is trigerred via ADMIN API
    ...     Step 2: Verify Rmods and Cells status after lock
    ...     Step 3: Check active alarms
    ...     Step 4: Radio unlock operation is trigerred via ADMIN API
    ...     Step 5: Verify Rmods and Cells status after unlock
    ...     Step 6: Check active alarms
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.10.2020 - https://jira3.int.net.nokia.com/browse/TAT-20362 - New TC
    ...  - 20.11.2020 - https://jira3.int.net.nokia.com/browse/TAT-20520 - rmod cell list correction
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 28.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22868 - Adapt TC to use CONF_REF in old SW and configDN in new SW
    ...  - 09.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23504 - New verification for cells
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24106 - Adapt TC to delete the specific resource
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Remove fault 4592
    ...  *******************

    Set Tags    CA-WebEM    PHASE-CIT    GROUP_IN_CHARGE-WRO_8_Vrf    SW-SBTS21
    ...    OWNER-grzegorz.gulaj@nokia.com    AUTHOR-grzegorz.gulaj@nokia.com    MAINTAINER-andreea.burtic@nokia.com
    ...    FEATURE-RP001498_RP000923    FEATURE-RP001621_RP000923    FEATURE-RP001486_RP000923
    ...    FEATURE-RP001307_RP000923    FEATURE-RP0001145_RP000923

    TC Preconditions
    Step 1: Radio lock operation is trigerred via ADMIN API
    Step 2: Verify Rmods and Cells status after lock
    Step 3: Check active alarms
    Step 4: Radio unlock operation is trigerred via ADMIN API
    Step 5: Verify Rmods and Cells status after unlock
    Step 6: Check active alarms


TC Preconditions
    Log  Preconditions.  console=true
    ${Obj_info}=  Query infomodel  get object //MRBTS_R-*
    ${Obj_stateInfo}=  Run Keyword And Return Status  Variable Should Exist  ${Obj_info['stateInfo']}
    ${STATE_INFO_OBJ_R}  Run Keyword If  ${Obj_stateInfo}
    ...  Set variable  stateInfo.
    ...  ELSE
    ...  Set variable  ${EMPTY}
    Set test variable  ${STATE_INFO_OBJ_R}
    ${status}  Run keyword and return status  Assert Every  RMOD  administrativeState=${Unlocked_}
    Run Keyword Unless  ${status}  Fail  At least one RMOD is incorrect!
    Setup for Alarm Checking
    _Preparing variables

Step 1: Radio lock operation is trigerred via ADMIN API
    Log  Step 1: Radio lock operation is trigerred via ADMIN API.  console=true
    Locking rmods

Step 2: Verify Rmods and Cells status after lock
    Log  Step 2: Verify Rmods and Cells status after lock.  console=true
    Log  \tChecking affected rmods.  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10  Check affected rmods
    Log  \tChecking unaffected rmods.  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10  Check unaffected rmods
    Log  \tChecking affected cells.  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10  Check if affected cells are in Dependency state
    Log  \tChecking unaffected cells.  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10  Check if unaffected cells are OnAir

Step 4: Radio unlock operation is trigerred via ADMIN API
    Log  Step 4: Radio unblock operation is trigerred via ADMIN API.  console=true
    Unlocking rmods

Step 5: Verify Rmods and Cells status after unlock
    Log  Step 5: RMOD and cells states are verified.  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10  Check all rmods
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10  Check if affected cells are OnAir
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10  Check if unaffected cells are OnAir

Step ${step_no}: Check active alarms
    Log  Step ${step_no}: Check active alarms.  console=true
    Final Alarm Checking

Check if affected cells are OnAir
    FOR  ${cell}  IN  @{CELLS_LIST}
        query infomodel  ${cell} is [${STATE_INFO_OBJ_R}blockingState=${Unblocked_}, ${STATE_INFO_OBJ_R}operationalState=${Enabled_}]  timeout=60
    END

Check if affected cells are in Dependency state
    FOR  ${cell}  IN  @{FAILED_CELLS_LIST}
        query infomodel  ${cell} is [${STATE_INFO_OBJ_R}availabilityStatus=${Dependency_}, ${STATE_INFO_OBJ_R}operationalState=${Disabled_}]
        ...  timeout=60
    END

Check if unaffected cells are onair
    ${on_air_cells}=  Copy List  ${CELLS_LIST}  deepcopy=True
    Remove Values From List   ${on_air_cells}  @{FAILED_CELLS_LIST}
    FOR  ${cell}  IN  @{on_air_cells}
        query infomodel  ${cell} is [${STATE_INFO_OBJ_R}blockingState=${Unblocked_}, ${STATE_INFO_OBJ_R}operationalState=${Enabled_}]  timeout=60
    END

Check affected rmods
    FOR  ${rmod}  IN  @{RMOD_LIST}
        Query Infomodel  ${rmod} is [${STATE_INFO_OBJ_R}administrativeState=${Locked_}, ${STATE_INFO_OBJ_R}usageState=${Idle_}]
    END

Check unaffected rmods
    ${on_air_rmods}=  Get Ids For All  RMOD
    Remove Values From List   ${on_air_rmods}  @{RMOD_LIST}
    FOR  ${rmod}  IN  @{on_air_rmods}
        Query Infomodel  ${rmod} is [${STATE_INFO_OBJ_R}administrativeState=${Unlocked_}]
    END

Check all rmods
    ${all_rmods}=  Get Ids For All  RMOD
    FOR  ${rmod}  IN  @{all_rmods}
        Query Infomodel  ${rmod} is [${STATE_INFO_OBJ_R}administrativeState=${Unlocked_}]
    END

Locking rmods
    FOR  ${rm}  IN  @{RMOD_LIST}
        Log  \tLock radio ${rm}  console=${True}
        Lock  ${rm}  timeout=300s
    END

Unlocking rmods
    FOR  ${rm}  IN  @{RMOD_LIST}
        Log  \tUnlock radio ${rm}  console=${True}
        Unlock  ${rm}  timeout=300s
    END

_Get all cells
    ${lncel}=   Get ids for all  LNCEL
    ${wncel}=   Get ids for all  WNCEL
    ${gncel}=   Get ids for all  GNCEL
    ${nrcel}=   Get ids for all  NRCEL
    ${CELLS_LIST}=  Evaluate  [cell_dn for cell_dn in ${lncel}+${wncel}+${gncel}+${nrcel} if 'RUNTIME_VIEW' in cell_dn]
    ${iot_cells}  Get IoT cells
    Remove Values From List  ${CELLS_LIST}  @{iot_cells}
    Set test variable  ${CELLS_LIST}

_Preparing variables
    _Get all cells
    Run keyword if  '${RMOD_SN}'==''
    ...  _Preparing for all radio modules testing
    ...  ELSE
    ...  _Preparing for one radio module testing

_Preparing for all radio modules testing
    set test variable  ${TESTING_ALL_RM}  ${True}
    ${all_rm}  Get Ids For All  RMOD
    Set test variable  ${RMOD_LIST}  ${all_rm}
    Set test variable  ${FAILED_CELLS_LIST}  ${CELLS_LIST}
    Log  All radio modules will be tested.  console=${True}

_Preparing for one radio module testing
    Set test variable  ${TESTING_ALL_RM}  ${False}
    ${rm}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rm}
        Continue For Loop If  '${rmod.serialNumber}'!='${RMOD_SN}'
        ${rmod_distname}  Set Variable  ${rmod.id}
    END
    ${rmod_cells_list}=  Get Cell Mapping By Module Id  ${rmod_distname}
    ${iot_cells}  Get IoT cells
    Remove Values From List  ${rmod_cells_list}  @{iot_cells}
    Set test variable  ${FAILED_CELLS_LIST}  ${rmod_cells_list}
    Log  Should be dependency after lock operation:${FAILED_CELLS_LIST}  console=true
    Set test variable  ${CELLS_LIST}  ${rmod_cells_list}
    Log  All cells from RMOD:${CELLS_LIST}  console=true
    Set test variable  @{RMOD_LIST}   ${rmod_distname}
    Log  Radio module ${RMOD_SN} will be tested.  console=${True}

Get IoT cells
    ${lncel}  coam.Get parameters for all  LNCEL
    ${iot_cells}  Evaluate  [cell['nbIoTCell']['distName'] for cell in ${lncel} if cell['nbIoTCell']]
    [Return]  ${iot_cells}

Setup for Alarm Checking
    [Documentation]  Preparing active alarm test variable
    Log  Saving list of active alarms    console=yes
    ${alarms}=  coam.Get Active Alarms
    ${STARTUP_ALARMS}=  _Normalize Alarm List  ${alarms}
    Set Test Variable  ${STARTUP_ALARMS}

Final Alarm Checking
    [Documentation]  Checking unexpected active alarm
    ${alarms}=  coam.Get Active Alarms
    ${historical_alarms}=  Get Historic Alarms
    ${present_alarms}=  _Normalize Alarm List  ${alarms}
    ${historical_alarms}=  _Normalize Alarm List  ${historical_alarms}
    Remove Values From List  ${present_alarms}  @{STARTUP_ALARMS}
    log to console   \tactive alarms:${present_alarms}
    Should Be Empty  ${present_alarms}  Unexpected alarm: ${present_alarms}
    Remove Values From List  ${historical_alarms}  @{STARTUP_ALARMS}
    log to console   \thistorical alarms:${historical_alarms}
    Should Be Empty  ${historical_alarms}  Unexpected alarm: ${historical_alarms}

_Normalize Alarm List
    [Documentation]  Base on list of alarm objects, creates list of dictionary with keys: faultId, faultName
    [Arguments]  ${list_of_alarms}
    ${alarms_without_timestamp}=  Create List
    FOR  ${alarm}  IN  @{list_of_alarms}
        ${normalized_alarm}=   Create Dictionary  faultId=${alarm}[faultId]  faultName=${alarm}[faultName]
        Append To List  ${alarms_without_timestamp}  ${normalized_alarm}
    END
    [Return]  ${alarms_without_timestamp}

Custom Test Teardown
    Run keyword if test failed  run keywords   Log  Test Fail - unlocking rmods  console=${True}  AND  Unlocking rmods
    Common Test Teardown


TC Setup
    Common Test Setup

TC Teardown
    Run keywords  WebEM__RF_Module_lock_unlock.Custom Test Teardown


