*** Settings ***
Documentation
    ...  Automated test for performing WBTS cell lock/unlock via changing OMS AdminCellState parameter (value 0: lock,
    ...  value 1: unlock). After cell lock/unlock cell states are verified  within 60 seconds. All cell states except
    ...  WCelState are fetched from ADMIN. WCelState is fetched from OMS. If proper cell states are not met TC fails.
    ...
    ...  Proper WBTS cell states after cell lock:
    ...  - Availability status: Offline,
    ...  - Blocking state: Unblocked,
    ...  - Operational state: Disabled,
    ...  - Usage state: Idle
    ...  - WCelState: 1 (BL-USER)
    ...
    ...  Proper WBTS cell states after cell unlock:
    ...  - Availability status: Online,
    ...  - Blocking state: Unblocked,
    ...  - Operational state: Enabled,
    ...  - Usage state: Active
    ...  - WCelState: 0 (WORKING)

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${WBTS_NUMBER}  ${EMPTY}  # WBTS number from OMS
${WCELL_NUMBER}  ${EMPTY}  # WBTS cell ID from OMS (if not given, all cells will be tested)
${OMS_IP_ADDRESS}  ${EMPTY}  # Overide global definition OMS_IP address (if not given, global variable from RNC.yaml will be taken)
${OMS_USERNAME}  Nemuadmin  # OMS username default value: Nemuadmin
${OMS_PASSWORD}  nemuuser  # OMS password default value: nemuuser


*** Keywords ***
TC__STATE__WCDMA_cell_lock_unlock_from_RNC
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-6325
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 25.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-6325 - Initial creation
    ...  - 13.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8024 - Change checked states
    ...  - 07.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-12753 - Symlink this TC to SBTS18/CI
    ...  - 20.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19398 - Adding optional TC parameter: OMS_IP_ADDRESS
    ...  - 03.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19632 - OMS library changing from hran_nwi3 to taf.rnc.oms.nwi3
    ...  - 28.10.2020 - https://jira3.int.net.nokia.com/browse/TAT-20396 - Adding optional TC parameters: OMS_USERNAME, OMS_PASSWORD
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-6325_01.png#

    Set Tags  CA-STATE  OWNER-grzegorz.gulaj@nokia.com  AUTHOR-patryk.furman@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Step 1: Prepare WCDMA Cells List And OMS Connection
    Step 2: Get WCDMA Cells Statuses And RMODs TX Power Info
    Step 3: WCELL Lock Via OMS
    Step 4: WCELL States Verification After Cells Lock
    Step 5: WCELL Unlock Via OMS
    Step 6: WCELL States Verification After Cells Unlock


Step 1: Prepare WCDMA Cells List And OMS Connection
    [Timeout]  15 min

    Log  Step 1: Prepare cells list and setup OMS connection  console=True
    Should Not Be Empty  ${WBTS_NUMBER}  Variable WBTS_NUMBER should not be empty
    ${cells}  Run Keyword If  '${WCELL_NUMBER}' != ''
    ...  Create List  ${WCELL_NUMBER}
    ...  ELSE
    ...  Admin Get Wncel Ids
    Log  List of WCELL IDs fetched from ADMIN to be tested: ${cells}  console=True
    ${is_oms_ip_defined_locally}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${OMS_IP_ADDRESS}
    Run Keyword If  ${is_oms_ip_defined_locally}
    ...  Set Test Variable  ${RNC['OMS_IP']}  ${OMS_IP_ADDRESS}
    Setup Nwi3  ${RNC['ID']}  ${RNC['OMS_IP']}  ${OMS_USERNAME}  ${OMS_PASSWORD}
    Set Test Variable  ${WCELL_IDS}  ${cells}


Step 2: Get WCDMA Cells Statuses And RMODs TX Power Info
    [Timeout]  15 min

    Log  Step 2: Get WCDMA cells statuses and RMODs TX power info  console=True
    ${wncel_params}  Get Parameters For All  WNCEL
    ${rmods_serial_numbers}  Infomodel Get All Radio Modules Serial Numbers
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    Set Global Variable  ${RMODS_SERIALS}  ${rmods_serial_numbers}


Step 3: WCELL Lock Via OMS
    [Timeout]  30 min

    Log  Step 3: WCELL lock via OMS  console=True
    Change WCELLs Administrative State From OMS  0  ${WCELL_IDS}


Step 4: WCELL States Verification After Cells Lock
    [Timeout]  15 min

    Log  Step 4: WCELL states verification after cells lock  console=True
    ${wcell_lock_params}  Set Variable  blockingState=${UNBLOCKED}, operationalState=${DISABLED}, usageState=${IDLE}
    ${wcel_states_verification_list}  Evaluate  ["1" for num in range(len(${WCELL_IDS}))]
    Wait Until Keyword Succeeds  5x  10s
    ...  Check WCELLs States In ADMIN  ${wcell_lock_params}  ${WCELL_IDS}
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    ${wcel_states_list}  Get WCELLs States From OMS  ${WCELL_IDS}
    ${are_cells_locked}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${wcel_states_list}  ${wcel_states_verification_list}
    Run Keyword If  ${are_cells_locked}==${FALSE}
    ...  Run Keywords
    ...  Try To Recover Cells From Lock State  ${WCELL_IDS}
    ...  AND
    ...  Fail  Not all cell states were achieved


Step 5: WCELL Unlock Via OMS
    [Timeout]  30 min

    Log  Step 5: WCELL unlock via OMS  console=True
    Change WCELLs Administrative State From OMS  1  ${WCELL_IDS}


Step 6: WCELL States Verification After Cells Unlock
    [Timeout]  15 min

    Log  Step 6: WCELL states verification after cells unlock  console=True
    ${wcel_states_verification_list}  Evaluate  ["0" for num in range(len(${WCELL_IDS}))]
    Wait Until Keyword Succeeds  5x  10s
    ...  Check WCELLs States In ADMIN  ${CELLS_WCDMA_EXPECTED_STATES}  ${WCELL_IDS}
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    ${wcel_states_list}  Get WCELLs States From OMS  ${WCELL_IDS}
    ${are_cells_unlocked}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${wcel_states_list}  ${wcel_states_verification_list}
    Run Keyword If  ${are_cells_unlocked}==${FALSE}
    ...  Run Keywords
    ...  Try To Recover Cells From Lock State  ${WCELL_IDS}
    ...  AND
    ...  Fail  Not all cell states were achieved


Get WCELLs States From OMS
    [Arguments]  ${wcell_ids}

    ${wcel_states_list}  Create List
    FOR  ${wcell}  IN  @{wcell_ids}
        Log  Trying to get WCELL-${wcell} WCelState from OMS  console=True
        ${wcel_state_value}  Get Wcel Parameter  ${WBTS_NUMBER}  ${wcell}  WCelState
        Log  WCELL-${wcell} WCelState equals ${wcel_state_value}  console=True
        Append To List  ${wcel_states_list}  ${wcel_state_value}
        Sleep  5  Wait for another WCEL check
    END

    [Return]  ${wcel_states_list}


Change WCELLs Administrative State From OMS
    [Arguments]  ${value}  ${wcell_ids}

    FOR  ${wcell}  IN  @{wcell_ids}
        Log  Trying to change AdminCellState=${value} of WCELL-${wcell}  console=True
        ${status}  Run Keyword And Return Status
        ...  Set Wcel Parameters  ${WBTS_NUMBER}  ${wcell}  AdminCellState=${value}
        Run Keyword If  ${status}==${FALSE}
        ...  Run Keywords
        ...  Try To Recover Cells From Lock State  ${wcell_ids}
        ...  AND
        ...  Fail  Error during changing AdminCellState=${value}
        Log  WCELL-${wcell} AdminCellState value changed to ${value}  console=True
    END
    Log  All cells AdminCellState value changed to ${value}. Wait 60 seconds for states checking  console=True
    Sleep  60  Wait for WCELLs states change


Try To Recover Cells From Lock State
    [Arguments]  ${wcell_ids}

    Log  Try to recover cells from lock state  level=WARN  console=True
    FOR  ${wcell}  IN  @{wcell_ids}
        Log  Trying to unlock WCELL-${wcell}  console=True
        ${status}  Run Keyword And Return Status
        ...  Set Wcel Parameters  ${WBTS_NUMBER}  ${wcell}  AdminCellState=1
        Run Keyword If  ${status}==${FALSE}
        ...  Fail  Additional cell unlock has failed. Please unlock cells manually
        Log  WCELL-${wcell} unlock succeeded  console=True
    END
    Log  All cell has been unlocked after failure  console=True


Check WCELLs States In ADMIN
    [Arguments]  ${states}  ${wcells_ids}

    Run Keyword If  len(${wcells_ids}) > 0 and '${WCELL_NUMBER}'==''
    ...  Assert Every  WNCEL  ${states}  timeout=60s
    ...  ELSE
    ...  _Check Single WCELL State In ADMIN  ${states}
    Log  Cells ${wcells_ids} states (${states}) are visible in ADMIN  console=True


_Check Single WCELL State In ADMIN
    [Arguments]  ${states}

    ${wncells_ids}  Get Ids For All  WNCEL
    ${current_wncell_id}  Get Matches  ${wncells_ids}  *-${WCELL_NUMBER}
    ${list_len}  Evaluate  len(${current_wncell_id})
    Should Be Equal As Integers  ${list_len}  ${1}  Number of cells fetched from ADMIN is not equal 1!
    Assert  WNCEL  ${current_wncell_id[0]}  ${states}  60s


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
