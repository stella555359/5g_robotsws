*** Settings ***
Documentation
    ...  Verify admin cell block/unblock scenario for LTE

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${CELL_ID}  ${EMPTY}  # LNCEL id parameter. ex. /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-18246/LNCEL_R-10774 . Leave empty to test all LNCELs.
${LOG_TX_POWER}  True  # If set True, test log to console all radio modules Tx powers


*** Keywords ***
TC__STATE__LTE_cell_block_unblock_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7082
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 25.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7082 - Initial Creation
    ...  - 21.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7661 - Ignore GSM cells if not deployed
    ...  - 09.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7962 - Incorrect availabilityStatus for LNCEL
    ...  - 31.07.2018 - https://jira3.int.net.nokia.com/browse/TAT-11053 - Added support for TL without WCDMA
    ...  - 16.08.2018 - https://jira3.int.net.nokia.com/browse/TAT-10851 - Test doesn't fail when IoT cells are present
    ...  - 11.12.2018 - https://jira3.int.net.nokia.com/browse/TAT-12827 - Added expected alarm for each blocked cell
    ...  - 02.03.2020 - https://jira3.int.net.nokia.com/browse/TAT-19049 - Parameter LOG_TX_POWER added
    ...  - 09.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19861 - Adding TL recovery action
    ...  - 25.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21353 - Replacing KW block to TAF library
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7082.png#

    Set Tags  CA-STATE  OWNER-rafal.wisniewski@nokia.com  AUTHOR-tomasz.1.filipek@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Test Case Preconditions
    Step1: Lte Cell Block
    Step2: Lte Cell Unblock


Test Case Preconditions
    Log  Test Case Preconditions  console=true
    Assert Every  LNCEL  ${CELLS_LTE_EXPECTED_STATES}
    Query Infomodel  every //CELL_M-* is [stateInfo.proceduralState=${ON_AIR_DONE}]
    ${all}  Set Variable If  '${CELL_ID}'=='${EMPTY}'  ${True}  ${False}
    ${lncels}  Get Ids For All  LNCEL
    Run Keyword If  ${all}==${FALSE}
    ...  List Should Contain Value  ${lncels}  ${CELL_ID}  Invalid CELL_ID input parameter or cell is not LTE.
    Set Test Variable  ${TEST_ALL_LTE}  ${all}
    Set Test Variable  ${STATES_ON_BLOCK}  administrativeState=${UNLOCKED}, blockingState=${BLOCKED}, operationalState=${DISABLED}


Step1: Lte Cell Block
    Log  Step1: Lte Cell Block  console=true
    ${ignored_alarms}  Create Dictionary  severity=Minor
    ${ignored_alarms}  Create List  ${ignored_alarms}
    ${expected_alarms}  Create List
    Set Test Variable  ${EXPECTED_ALARMS}
    Run Keyword If  ${TEST_ALL_LTE}
    ...  Lte Cell Block All
    ...  ELSE
    ...  Lte Cell Block Specific
    Run Keyword If  ${LOG_TX_POWER}
    ...  Log All Tx Power
    Wait Until Keyword Succeeds  1 min  10s
    ...  Admin Check Active Alarms TAF  ignored_patterns=${ignored_alarms}  expected_patterns=${EXPECTED_ALARMS}


Lte Cell Block Specific
    ${cell_blocked}  Run Keyword And Return Status
    ...  coam.Block Cell  dist_name=${CELL_ID}
    ${expected_alarm}  Create Dictionary  faultId=^${FAULT_49}[fault_id]$
    Run Keyword If  ${cell_blocked}
    ...  Append To List  ${EXPECTED_ALARMS}  ${expected_alarm}
    ...  ELSE
    ...  Set Test Failed  ${CELL_ID} block failed
    Run Keyword And Continue On Failure
    ...  Assert  LNCEL  ${CELL_ID}  ${STATES_ON_BLOCK}  timeout=20


Lte Cell Block All
    ${lte_cells_ids}  Admin Get IDs For All LTE Cells
    ${iot_cells_ids}  Admin Get IDs For Standalone IoT Cells
    ${cell_ids}  Evaluate  ${lte_cells_ids} + ${iot_cells_ids}
    FOR  ${cell_id}  IN  @{cell_ids}
        ${cell_blocked}  Run Keyword And Return Status
        ...  coam.Block Cell  dist_name=${cell_id}
        ${expected_alarm}  Create Dictionary  faultId=^${FAULT_49}[fault_id]$
        Run Keyword If  ${cell_blocked}
        ...  Append To List  ${EXPECTED_ALARMS}  ${expected_alarm}
        ...  ELSE
        ...  Set Test Failed  ${cell_id} block failed
    END
    Run Keyword And Continue On Failure
    ...  Assert Every  LNCEL  ${STATES_ON_BLOCK}  timeout=20


Step2: Lte Cell Unblock
    Log To Console  Step2: Lte Cell Unblock
    Run Keyword If  ${TEST_ALL_LTE}
    ...  Lte Cell Unblock All
    ...  ELSE
    ...  coam.Unblock Cell  dist_name=${CELL_ID}
    ${ignored_alarms}  Create Dictionary  severity=Minor
    ${ignored_alarms}  Create List  ${ignored_alarms}
    Admin Check Active Alarms TAF  ignored_patterns=${ignored_alarms}
    Run Keyword If  ${LOG_TX_POWER}
    ...  Log All Tx Power
    Run Keyword And Continue On Failure
    ...  Assert All Cells Are In Expected State
    Run Keyword And Continue On Failure
    ...  Query Infomodel  every //CELL_M-* is [stateInfo.proceduralState=${ON_AIR_DONE}]


Lte Cell Unblock All
    ${lte_cells_ids}  Admin Get IDs For All LTE Cells
    ${iot_cells_ids}  Admin Get IDs For Standalone IoT Cells
    ${cell_ids}  Evaluate  ${lte_cells_ids} + ${iot_cells_ids}
    FOR  ${id}  IN  @{cell_ids}
        coam.Unblock Cell  dist_name=${id}
    END


TC Setup
    Common Test Setup  tc_name=STATE__LTE_cell_block_unblock_from_ADMIN


TC Teardown
    Common Test Teardown
    Recover Test Line By Power Reset
