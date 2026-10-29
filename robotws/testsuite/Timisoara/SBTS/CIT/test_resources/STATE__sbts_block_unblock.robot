*** Settings ***
Documentation
    ...  Verification of operability function for bts block/unblock scenario

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${CUSTOM_BLOCKED_BTS_DISTNAME}  ${EMPTY}  # distname of object to block. if empty, the ID of current BTS will be taken
${CELLS_TIMEOUT_BEFORE_BLOCK}  300  # timeout in seconds for waiting until cells reach expected states before block
${CELLS_TIMEOUT_AFTER_BLOCK}  300  # timeout in seconds for waiting until cells reach expected states after block
${CELLS_TIMEOUT_AFTER_UNBLOCK}  1200  # timeout in seconds for waiting until cells reach expected states after unblock
${BTS_HOST}  192.168.255.129


*** Keywords ***
TC__STATE__SBTS_block_unblock
    [Documentation]
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 01.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-4457 - Test delivered
    ...  - 14.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-6301 - cells states verification unified for all RATs
    ...  - 21.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7335 - invalid parameter is checking
    ...  - 01.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7407 - change preconditions
    ...  - 01.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7507 - unmatching paths to LNCEL_R
    ...  - 08.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7547 - parallel verif of each rat cells states, timeout for waiting pending cells
    ...  - 05.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7840 - Change dist_name when SMOD_R-1 horizontal position 2 – right
    ...  - 05.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7953 - incorrect UsageState for RMOD_R
    ...  - 11.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7732 - change the deprecated keyword
    ...  - 20.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7654 - Added support for hran_logging==2.1.0
    ...  - 25.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-8066 - Run custom teardown only if admin_started properly in setup
    ...  - 09.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-7606 - Migration from ute_infomodel to ADMIN Abstraction Layer
    ...  - 09.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8118 -
    ...  - 12.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9151 - KPI (first cell up after block request) added
    ...  - 15.06.2018 - https://jira3.int.net.nokia.com/browse/TAT-7816 - change the object to block - now it is current BTS ID
    ...  - 29.06.2018 - https://jira3.int.net.nokia.com/browse/TAT-10613 - split implementation for SBTS18 as PR293945 was not delivered to SBTS17
    ...  - 13.07.2018 - https://jira3.int.net.nokia.com/browse/TAT-10862 - STATE__sbts_block_unblock related to hran_ims==1.3.0
    ...  - 06.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18122 - increase default cells timeout after unblock
    ...  - 3.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18397 - Adding new keyword to TC
    ...  - 25.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21353 - Replacing KW block to TAF library
    ...  - 10.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24067 - Preconditions fixed for a configuration with an RF without cells mapped
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/STATE__sbts_block_unblock.svg#

    Set Tags  CA-STATE  OWNER-grzegorz.gulaj@nokia.com  AUTHOR-tomasz.1.filipek@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18_P8  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    TC Preconditions
    Step1: Perform SBTS Block Operation
    Step2: Check SBTS States And Alarms After Block Operation
    Step3: Perform SBTS Unblock Operation
    Step4: Check SBTS States And Alarms After Unblock Operation


TC Preconditions
    Log  TC preconditions: Check alarms and states before SBTS block  console=true
    Set Blocked BTS Distname
    Detect Existing RATs
    Assert Every  BTS  blockingState=${UNBLOCKED}
    Assert Every  SMOD  usageState=${ACTIVE}
    Assert Every  RMOD  usageState=regex"[Aa]ctive|[Bb]usy|[Ii]dle"

    ${critical_alarms}  Create Dictionary  severity=(Major|Critical)
    ${critical_patterns}  Create List  ${critical_alarms}
    Admin Check Active Alarms TAF  critical_patterns=${critical_patterns}


Step1: Perform SBTS Block Operation
    Log  step1: Perform SBTS block  console=true
    ${operation_status}  ${operation_msg}  Run Keyword And Ignore Error
    ...  Block  timeout=300
    Run Keyword If  '${operation_status}' == 'FAIL'
    ...  Run Keywords
    ...  Admin Get Snapshot
    ...  AND
    ...  Set Test Restriction  Block operation failed because of ${operation_msg}. States verification ongoing
    ...  ELSE
    ...  Log  Block operation performed correcty  console=true


Step2: Check SBTS States And Alarms After Block Operation
    Log  step2: Check alarms and states after SBTS block  console=true

    ${gsm_expected_states}  Set Variable
    ...  blockingState=${BLOCKED}, operationalState=${DISABLED}, administrativeState=${UNLOCKED}, usageState=${IDLE}
    ${wcdma_expected_states}  Set Variable  blockingState=${BLOCKED}, operationalState=${DISABLED}, usageState=${IDLE}
    ${lte_expected_states}  Set Variable  blockingState=${BLOCKED}, operationalState=${DISABLED}, administrativeState=${UNLOCKED}
    ${nr_expected_states}  Set Variable  blockingState=${BLOCKED}, operationalState=${DISABLED}, administrativeState=${UNLOCKED}
    Wait For Cells States  ${CELLS_TIMEOUT_AFTER_BLOCK}  ${lte_expected_states}  ${wcdma_expected_states}  ${gsm_expected_states}
    ...  ${nr_expected_states}

    ${bts_expected_states}  Set Variable  blockingState=${BLOCKED}
    ${smod_expected_states}  Set Variable  usageState=${IDLE}, administrativeState=${UNLOCKED}, operationalState=${ENABLED}
    ${rmod_expected_states}  Set Variable  usageState=${IDLE}, administrativeState=${UNLOCKED}, operationalState=${ENABLED}
    Assert Every  BTS  ${bts_expected_states}
    Assert Every  SMOD  ${smod_expected_states}
    Assert Every  RMOD  ${rmod_expected_states}

    ${critical_alarms}  Create Dictionary  severity=(Major|Critical)
    ${critical_patterns}  Create List  ${critical_alarms}
    ${expected_alarm}  Create Dictionary  faultId=^0*${FAULT_50}[fault_id]$
    ${expected_patterns}  Create List  ${expected_alarm}
    Wait Until Keyword Succeeds  5 min  20 sec
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected_patterns}  critical_patterns=${critical_patterns}


Step3: Perform SBTS Unblock Operation
    Log  step3: Perform SBTS unblock operation and verify reset  console=true
    Check That There Are No Resets In Ims2 Before Unblock
    Perform SBTS Unblock Operation
    Wait Until BTS Stabilizes
    Check That Reset Occurred After Unblock


Step4: Check SBTS States And Alarms After Unblock Operation
    Log  step4: Check alarms and states after SBTS unblock  console=true

    ${lte_expected_states}  Set Variable  blockingState=${UNBLOCKED}, operationalState=${ENABLED}, administrativeState=${UNLOCKED}
    ${wcdma_expected_states}  Set Variable  blockingState=${UNBLOCKED}, operationalState=${ENABLED}, usageState=${ACTIVE}
    ${gsm_expected_states}  Set Variable
    ...  blockingState=${UNBLOCKED}, operationalState=${ENABLED}, administrativeState=${UNLOCKED}, usageState=${ACTIVE}
    Wait For Cells States  ${CELLS_TIMEOUT_AFTER_UNBLOCK}  ${CELLS_LTE_EXPECTED_STATES}  ${CELLS_WCDMA_EXPECTED_STATES}  ${CELLS_GSM_EXPECTED_STATES}
    ...  ${CELLS_NR_EXPECTED_STATES}

    Assert Every  BTS  blockingState=${UNBLOCKED}
    Assert Every  SMOD  administrativeState=${UNLOCKED}, operationalState=${ENABLED}
    Assert Every  RMOD  administrativeState=${UNLOCKED}, operationalState=${ENABLED}

    ${critical_alarms}  Create Dictionary  severity=(Major|Critical)
    ${critical_patterns}  Create List  ${critical_alarms}
    Wait Until Keyword Succeeds  5 min  20 sec
    ...  Admin Check Active Alarms TAF  critical_patterns=${critical_patterns}


Wait For Cells States
    [Arguments]  ${timeout}  ${lte_expected_states}  ${wcdma_expected_states}  ${gsm_expected_states}  ${nr_expected_states}

    Run Keyword And Continue On Failure
    ...  Wait Until Keyword Succeeds  ${timeout}  15s
    ...  Run Keywords
    ...  Verify Cells  LTE  ${lte_expected_states}
    ...  AND
    ...  Verify Cells  WCDMA  ${wcdma_expected_states}
    ...  AND
    ...  Verify Cells  GSM  ${gsm_expected_states}
    ...  AND
    ...  Verify Cells  NR  ${nr_expected_states}


Assertion Analyse
    [Arguments]  ${assertion_output}

    Run Keyword If  '${assertion_output[0]}'=='PASS'
    ...  Return From Keyword If  ${assertion_output[1]}!=@{EMPTY}  ${TRUE}

    [Return]  ${FALSE}


Detect Existing RATs
    ${lte_exists}  Query Infomodel  ${DIST_LTE_CELL}  allow_negative_result=${TRUE}
    Set Test Variable  ${LTE_EXISTS}
    ${wcdma_exists}  Query Infomodel  ${DIST_WCDMA_CELL}  allow_negative_result=${TRUE}
    Set Test Variable  ${WCDMA_EXISTS}
    ${gsm_exists}  Query Infomodel  ${DIST_GSM_CELL}  allow_negative_result=${TRUE}
    Set Test Variable  ${GSM_EXISTS}
    Log  Detected cells in configuration: LTE: ${LTE_EXISTS}, WCDMA: ${WCDMA_EXISTS}, GSM: ${GSM_EXISTS}  console=true


Perform SBTS Unblock Operation
    Log  Perform SBTS unblock  console=true
    ${operation_status}  ${operation_msg}  Run Keyword And Ignore Error
    ...  Unblock  timeout=300
    Run Keyword If  '${operation_status}' == 'FAIL'
    ...  Run Keywords
    ...  Set Test Restriction  Unblock operation failed because of ${operation_msg}. States verification ongoing
    ...  AND
    ...  Admin Get Snapshot
    ...  ELSE
    ...  Log  Unblock operation performed correcty  console=true


Wait Until BTS Stabilizes
    Log  Wait max 1200 seconds until BTS stabilizes after unblock  console=true
    Check If Target Is Stable  ip=${BTS_HOST}  min_uptime=300  max_downtime=300  timeout=1200


Check That There Are No Resets In Ims2 Before Unblock
    Save Infomodel Log  filename=${BTS_FILES}/IM/reset_detector/InfoModel_log_before_unblock.ims2
    Initialize Ims2 Validator  ${BTS_FILES}/IM/reset_detector/InfoModel_log_before_unblock.ims2
    Add Expected Ims2 Event  reset
    Run Keyword And Expect Error  *
    ...  Validate Ims2


Check That Reset Occurred After Unblock
    Save Infomodel Log  filename=${BTS_FILES}/IM/reset_detector/InfoModel_log_after_unblock.ims2
    Initialize Ims2 Validator  ${BTS_FILES}/IM/reset_detector/InfoModel_log_after_unblock.ims2
    Add Expected Ims2 Event  reset
    Validate Ims2


Set Blocked BTS Distname
    ${dist_blocked_bts}  Run Keyword If  '${CUSTOM_BLOCKED_BTS_DISTNAME}'==''
    ...  Get ID For Current  BTS
    ...  ELSE
    ...  Set Variable  ${CUSTOM_BLOCKED_BTS_DISTNAME}
    Set Test Variable  ${DIST_BLOCKED_BTS}
    Log  distname to be blocked: ${DIST_BLOCKED_BTS}  console=true


TC Setup
    Common Test Setup  tc_name=STATE__SBTS_block_unblock


TC Teardown
    Common Test Teardown
