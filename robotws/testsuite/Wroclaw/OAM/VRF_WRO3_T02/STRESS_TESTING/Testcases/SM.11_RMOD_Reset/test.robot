*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.11_RMOD_Reset
...  AUTHORS:       jakub.hirny@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform Radio Module Reset operations for randomly chosen RM on RAN eNodeB,
...  check eNB status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  26.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Test creation
...  21.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-423 - robotws migration and small hotfixes
...  24.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-521 - Solution for allowing FID4003 when cell deployed on other RMOD.
...  22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-565 - Fix SM.11_RMOD_Reset for RMODs in chain
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.11_RMOD_Reset

    SM.11_RMOD_Reset.Test_Step:0 Test Preparation
    SM.11_RMOD_Reset.Test_Step:1 Select RMOD
    SM.11_RMOD_Reset.Test_Step:2 Perform RMOD Reset
    SM.11_RMOD_Reset.Test_Step:3 KPI Measurement

SM.11_RMOD_Reset.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Run Keyword If  ${ITERATION_INDEX}==1  RMOD Chain Detection    #sets test variables ${RMOD_TO_CHAIN_INDEX_MAPPING} and ${AVAILABLE_CHAINS_INDEX}
    Check If NLWG Cells Are OnAir
    ${rats}  Detect RATs
    Set Test Variable  ${rats}
    SCF Backup
#    Compare current date with PSGRP/NRPGRP  PSGRP
#    Compare current date with PSGRP/NRPGRP  NRPGRP

SM.11_RMOD_Reset.Test_Step:1 Select RMOD
    Log to console    \n========================================
    Log  Step: 1 Select RMOD  console=${True}
    Log to console    ========================================
    ${selected_rmod}  Evaluate  random.choice(${rmods})  random
    Log To Console  Selected RMOD: ${selected_rmod}
    Set Test Variable  ${selected_rmod}

SM.11_RMOD_Reset.Test_Step:2 Perform RMOD Reset
    Log to console    \n========================================
    Log  Step: 2 Perform RMOD Reset  console=${True}
    Log to console    ========================================
    ${is_in_chain}  Set Variable If  '${selected_rmod}' in $RMOD_TO_CHAIN_INDEX_MAPPING  True  False
    ${chain_index}  Run Keyword If  ${is_in_chain}  Get From Dictionary  ${RMOD_TO_CHAIN_INDEX_MAPPING}  ${selected_rmod}
    ${chain_dict}   Run Keyword If  ${is_in_chain}  Get From Dictionary  ${AVAILABLE_CHAINS_INDEX}       ${chain_index}
    ...                       ELSE  Create Dictionary
    ${selected_position_in_chain}  Run Keyword If  ${is_in_chain}  Get From Dictionary  ${chain_dict}  ${selected_rmod}
    ${shared_cell}  Check If Cells Configured On Other RMOD  ${selected_rmod}
    Run Keyword If  ${shared_cell}
    ...  Allow Fault In Watchdog  faultID=4003  #fault_name: Transmission path failure
    Log To Console  Reset RMOD: ${selected_rmod}
    admin.reset unit  ${selected_rmod}  timeout=700
    Log To Console  Checking if selected RMOD has reached the expected state: operationalState=Disabled, the rest of the RMODs should remain Enabled
    Run Keyword If  ${AVAILABLE_CHAINS_INDEX}!={}  Run Keywords
    ...             Log To Console  Exception: if RMOD is in chain with RMOD that is being reset, its expected state can be Enabled,  no_newline=true
    ...        AND  Log To Console  ${SPACE}if its position in chain is before, or Disabled, if positioned after RMOD that is being reset.
    ${bts_info}  admin.get bts info
    FOR  ${rmod}  IN  @{bts_info['radioModules']['rmod']}
        ${position_in_chain}  Run Keyword If  '${rmod['id']['configuration']}' in $chain_dict
        ...                                   Get From Dictionary  ${chain_dict}  ${rmod['id']['configuration']}
        ...                             ELSE  Set Variable  0
        ${rmod_states}  Get From Dictionary  ${rmod}  status
        ${operational_state}  Get From Dictionary  ${rmod_states}  operationalState
        ${operational_state_upper}  Evaluate  "${operational_state}".upper()
        Run Keyword If  '${rmod['id']['configuration']}'=='${selected_rmod}' and '${operational_state_upper}'!='ENABLED'
        ...             Should Be Equal As Strings  ${operational_state}  disabled  ignore_case=True
        ...    ELSE IF  ${is_in_chain} and ${position_in_chain}>${selected_position_in_chain} and '${operational_state_upper}'!='ENABLED'
        ...             Should Be Equal As Strings  ${operational_state}  disabled  ignore_case=True
        ...       ELSE  Should Be Equal As Strings  ${operational_state}  enabled   ignore_case=True
        ${administrative_state}  Get From Dictionary  ${rmod_states}  administrativeState
        Should Be Equal As Strings  ${administrative_state}  Unlocked  ignore_case=True
        Log To Console  State of ${rmod['id']['configuration']} is correct
    END
    Check If NLWG Cells Are OnAir
    ${if_gsm_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  gsm
    Run Keyword If  ${if_gsm_exist}  Wait Until Keyword Succeeds  3min  30s  Check State on GNCELs  availabilityStatus  None
    Run Keyword If  ${shared_cell}  Run Keywords
    ...         Run Keyword And Ignore Error  Wait For Inactive Fault  faultID=4003  timeout=60 sec
    ...  AND    Disallow Fault In Watchdog  faultID=4003  #fault_name: Transmission path failure
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN

SM.11_RMOD_Reset.Test_Step:3 KPI Measurement
    Log to console    \n========================================
    Log  Step: 3 KPI Measurement console=${True}
    Log to console    ========================================
    Run Keyword And Ignore Error  Calculate KPI51a KPI51b  ${ITERATION_INDEX}
#    Reselect Cells For NRPGRP
#    Reselect Cells For PSGRP

SM.11_RMOD_Reset.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
