*** Settings ***
Documentation
    ...  LTE cell lock/unlock from ADMIN TC.
    ...  If ${CELL_ID} parameter is not set, all cells will be checked.
    ...
    ...  Step 0: TC Preconditions
    ...  Check cells states:
    ...  administrativeState=Unlocked #WCDMA cells excluded
    ...  availabilityStatus=Online
    ...  blockingState=Unblocked
    ...  operationalState=Enabled
    ...  proceduralState=OnAirDone
    ...  Fail if cells states don't match.
    ...
    ...  Step 1: LTE CELL lock
    ...  Lock specified LTE cells
    ...  Check WCDMA, GSMA and not affected LTE cells states match as Step 0:
    ...  Check affected LTE cells states:
    ...  administrativeState=Locked
    ...  availabilityStatus=Offline
    ...  blockingState=Unblocked
    ...  operationalState=Disabled
    ...  proceduralState=Validated
    ...
    ...  Log TX power and set restriciton if any alarm is visible.
    ...  Fail if cells states don't match.
    ...
    ...  Step 2: LTE CELL Unlock
    ...  Lock specified LTE cells
    ...  Check WCDMA, GSMA and not affected LTE cells states match as Step 0:
    ...  Check affected LTE cells states:
    ...  administrativeState=Unlocked
    ...  availabilityStatus=Online
    ...  blockingState=Unblocked
    ...  operationalState=Enabled
    ...  proceduralState=OnAirDone
    ...  Log TX power and set restriciton if any alarm is visible.
    ...  Fail if cells states don't match.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${CELL_ID}  ${None}  # Example: 23651


*** Keywords ***
TC__STATE__LTE_cell_lock_unlock_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7083
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 07.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-7083 - Initial creation
    ...  - 20.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-8081 - Change SCF-*
    ...  - 20.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9842 - Increase timeout to 1h
    ...  - 24.07.2018 - https://jira3.int.net.nokia.com/browse/TAT-10728 - Recover locked cells in case of FAIL
    ...  - 03.12.2018 - https://jira3.int.net.nokia.com/browse/TAT-13416 - Skip IoT inband cells during test execution
    ...  - 22.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14847 - Added iotProceduralState check
    ...  - 31.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16253 - TC handover, changed GROUP_IN_CHARGE
    ...  - 23.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17567 - Added LTE inband IoT cell support
    ...  - 16.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17567 - TC refactoring
    ...  - 03.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23875 - Fix for IoT cell lock-unlock
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7083.png#
    ...
    [Timeout]  60 minutes

    Set Tags  CA-STATE  OWNER-rafal.wisniewski@nokia.com  AUTHOR-teodor.szurek@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Step 0: TC Preconditions
    Step 1: LTE Cells Lock
    Step 2: LTE Cells Unlock


Step 0: TC Preconditions
    Log  \nStep 0: Preconditions  console=true
    ${cells_dn}  Run Keyword If  ${CELL_ID}
    ...  Get Cell Dist_name
    ...  ELSE
    ...  Get Cells Dist_name
    Set Test Variable  ${CELLS_DN}
    ${status}  Run Keyword And Return Status
    ...  Assert All Cells Are In Expected State
    Run Keyword If  not ${status}
    ...  Fail  Incorrect cells or units states, test fail! Collecting snapshot


Get Cell Dist_name
    ${cell_object}  Query Infomodel  get object //SCF-*//LNCEL_A-${CELL_ID}
    ${cell_dn}  Remove String Using Regexp  ${cell_object.dist_name}  .*/SCF-\\d/
    ${cell_dn_list}  Create List  ${cell_dn}

    [Return]  ${cell_dn_list}


Get Cells Dist_name
    ${cells_dn_list}  Create List
    ${bts_id}  Admin Get BTS ID
    ${lte_cells_ids}  Admin Get IDs For All LTE Cells
    ${iot_cells_ids}  Admin Get IDs For Standalone IoT Cells
    ${cells_ids}  Evaluate  ${lte_cells_ids} + ${iot_cells_ids}
    FOR  ${cell}  IN  @{cells_ids}
        ${cell_dn}  Remove String Using Regexp  ${cell}  .*VIEW-\\d/
        ${cell_dn}  Replace String Using Regexp  ${cell_dn}  _R  _A
        ${cell_dn}  Replace String Using Regexp  ${cell_dn}  MRBTS_A-\\d  MRBTS_A-${bts_id}
        Append To List  ${cells_dn_list}  ${cell_dn}
    END

    [Return]  ${cells_dn_list}


Step 1: LTE Cells Lock
    Log  \nStep 1: LTE Cells Lock  console=true
    FOR  ${cell}  IN  @{CELLS_DN}
        ${cell}  Remove String Using Regexp  ${cell}  _A
        Perform Parameter Recommissioning  ${cell}  administrativeState  update  locked  skip_parameter_relation_errors=${True}  timeout=1200
    END
    Sleep  60
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    ${status}  Run Keyword And Return Status
    ...  Verify Cells States  after_block=${True}  states_lte=${STATES_ON_LOCK_LG}  lte_procedural_state=Validated  iot_procedural_state=Initializing
    Run Keyword If  not ${status}
    ...  Fail  Incorrect cells or units states, test fail! Collecting snapshot
    Admin Check Active Alarms TAF


Step 2: LTE Cells Unlock
    Log  \nStep 2: LTE Cells Unlock  console=true
    FOR  ${cell}  IN  @{CELLS_DN}
        ${cell}  Remove String Using Regexp  ${cell}  _A
        Perform Parameter Recommissioning  ${cell}  administrativeState  update  unlocked  skip_parameter_relation_errors=${True}
    END
    Sleep  60
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    ${status}  Run Keyword And Return Status
    ...  Verify Cells States
    Run Keyword If  not ${status}
    ...  Fail  Incorrect cells or units states, test fail! Collecting snapshot
    Admin Check Active Alarms TAF


Verify Cells States
    [Arguments]  ${after_block}=${False}  ${states_lte}=${STATES_ONAIR_LG}  ${lte_procedural_state}=OnAirDone  ${iot_procedural_state}=OnAirDone

    Log  \nCheck cells states  console=true
    Assert All Cells Are In Expected State  check_lte=${FALSE}
    Run Keyword If  ${after_block} and ${CELL_ID}
    ...  Verify Specific LTE Cell States After Lock  ${CELL_ID}
    ...  ELSE
    ...  Run Keywords
    ...  Assert Every  LNCEL  ${states_lte}
    ...  AND
    ...  Assert No  LNCEL  ${DEGRADED_CELL_REGEX}
    ...  AND
    ...  Query Infomodel
    ...  every //MCTRL-*/BBTOP_M-1/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=regex"${lte_procedural_state}|${iot_procedural_state}"]


Verify Specific LTE Cell States After Lock
    [Arguments]  ${cell_id}

    ${lncel_objects}  Query Infomodel  get list //LNBTS_M-*/CELL_M-*/LNCEL_M-*
    ${runtime_obj}  Query Infomodel  get object //LNCEL_R-${cell_id}
    ${right}  ${left}  Split String From Right  ${runtime_obj.dist_name}  separator=-  max_split=1
    Set Test Variable  ${RUNTIME_PATTERN}  ${right}
    _Check Specific LTE Cell States  ${cell_id}
    _Check Other LTE Cells States  ${lncel_objects}  ${cell_id}


_Check Specific LTE Cell States
    [Arguments]  ${cell_id}

    ${lncel_object}  Query Infomodel  get object //LNCEL_M-${cell_id}
    ${cell_m_path}  ${lncel}  Split Path  ${lncel_object.dist_name}
    Query Infomodel  check ${cell_m_path} is [stateInfo.proceduralState=Validated]
    ${lncel_list}  Get Ids For All  LNCEL
    ${parameters}  Assert  LNCEL  ${RUNTIME_PATTERN}-${cell_id}  ${STATES_ON_LOCK_LG}
    ${status}  Run Keyword And Return Status
    ...  Should Not Be Equal As Strings  ${parameters}[nbIoTCell]  None
    ${io_t_cell_id}  Run Keyword If  ${status}
    ...  Fetch From Right  ${parameters}[nbIoTCell][distName]  -
    Set Test Variable  ${IOT_CELL_ID}  ${io_t_cell_id}
    ${is_inband_iot}  Is Cell With Inband IoT  ${cell_id}
    Run Keyword If  ${is_inband_iot}
    ...  _Check Inband IoT Cell States By LTE Cell Id  ${cell_id}


_Check Other LTE Cells States
    [Arguments]  ${lncel_objects}  ${cell_id}

    Log To Console  ${cell_id}
    ${cells_m_dn}  Create List
    FOR  ${cell}  IN  @{lncel_objects}
        ${lncel_cell_id}  Remove String Using Regexp  ${cell.dist_name}  .*/LNCEL_M-
        ${contains_cell_id}  Verify If Inband Cell Is In LTE Cell  ${cell_id}  ${lncel_cell_id}
        Continue For Loop If  ${contains_cell_id}
        ${contains_cell_id}  Run Keyword And Return Status
        ...  Should Match Regexp  ${cell["dist_name"]}  LNCEL_M-${cell_id}$|LNCEL_M-${IOT_CELL_ID}
        Continue For Loop If  ${contains_cell_id}
        ${cell_m_dn}  ${lncel}  Split Path  ${cell["dist_name"]}
        ${cid}  Remove String Using Regexp  ${cell["dist_name"]}  .*LNCEL_M-
        Assert  LNCEL  ${RUNTIME_PATTERN}-${cid}  ${STATES_ONAIR_LG}
        Query Infomodel  check ${cell_m_dn} is [stateInfo.proceduralState=${ON_AIR_DONE}]
    END
    Assert No  LNCEL  ${DEGRADED_CELL_REGEX}  timeout=20


_Check Inband IoT Cell States By LTE Cell Id
    [Arguments]  ${host_cell_id}

    ${iot_inband_cell_id}  Get Inband IoT Cell By LTE Cell Id  ${host_cell_id}
    ${iot_cell_object}  Query Infomodel  get object //LNCEL_M-${iot_inband_cell_id}
    ${iot_cell_m_path}  ${lncel}  Split Path  ${iot_cell_object.dist_name}
    ${iot_test}  Query Infomodel  get object ${iot_cell_m_path} is [stateInfo.proceduralState=${INITIALIZING}]
    Query Infomodel  check ${iot_cell_m_path} is [stateInfo.proceduralState=${INITIALIZING}]
    Assert  LNCEL  ${RUNTIME_PATTERN}-${iot_inband_cell_id}  ${STATES_ON_LOCK_LG}


_Recovery Action For Cells
    [Documentation]  Will try to unlock all LTE cells under test

    FOR  ${cell}  IN  @{CELLS_DN}
        ${cell}  Remove String Using Regexp  ${cell}  _A
        Perform Parameter Recommissioning  ${cell}  administrativeState  update  unlocked  skip_parameter_relation_errors=${True}
    END


TC Setup
    Common Test Setup  tc_name=STATE__LTE_cell_lock_unlock_from_ADMIN


TC Teardown
    Run Keyword If Test Failed
    ...  _Recovery Action For Cells
    Common Test Teardown
    Recover Test Line By Power Reset
