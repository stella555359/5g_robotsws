*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot

Documentation
...  TEST NAME:     SM.02_Site_Block_Unblock
...  AUTHORS:       artur.lebek@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform Site Block and Unblock operations, check eNB status after operations are done.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  31.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Legacy test
...  08.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - changed timeout after unblock from 360 to 600 seconds
...  21.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-420 - robotws migration and small hotfixes
...  18.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-517 - Resolve Blocked BTS after failed iteration and small hotfixes
...  16.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-589 - Add FID: 6150 to allowed alarms during startup after Site Block
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
SM.02_Site_Block_Unblock

    SM.02_Site_Block_Unblock.Test_Step:0 Test Preparation
    SM.02_Site_Block_Unblock.Test_Step:1 Perform Site Block
    SM.02_Site_Block_Unblock.Test_Step:2 Perform Site Unblock

SM.02_Site_Block_Unblock.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Resolve Blocked BTS
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check If NLWG Cells Are OnAir
    ${bts_name}  Get BTS Name
    Set Test Variable  ${bts_name}
    ${rats}  Detect RATs
    Set Test Variable  ${rats}
    SCF Backup

SM.02_Site_Block_Unblock.Test_Step:1 Perform Site Block
    Log to console    \n========================================
    Log  Step: 1 Perform Site Block  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=50  #fault_name: BTS blocked
    Log To Console  BTS Block site...
    admin.block  timeout=180
    ${unit_path}  Set Variable  [${bts_name}] MRBTS-${MRBTS_ID}
    ${unit_path}  Evaluate   re.sub('\\[--\\]','','''${unit_path}''')  re
    Wait For Active Fault  faultID=50  unit_path=${unit_path}  timeout=30 sec    #OM_GEN_SFS_FM.3103
    Log To Console  Checking if all cells have reached the expected state: blockingState=Blocked, operationalState=Disabled
    Wait Until Keyword Succeeds  5x  1s  Check Cells Expected States

SM.02_Site_Block_Unblock.Test_Step:2 Perform Site Unblock
    Log to console    \n========================================
    Log  Step: 2 Perform Site Unblock  console=${True}
    Log to console    ========================================
    ${if_nr_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  nr
    Run Keyword If  ${if_nr_exist}  Run Keywords  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                    ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                    ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Allow Fault In Watchdog  faultID=6150  #fault_name: GTP-U Path failure can be visible during startup
    Log To Console  BTS Unblock site...
    admin.Unblock  timeout=600
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Wait Until Keyword Succeeds  10x  1s  Check S1 Link
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=50  #fault_name: BTS blocked
    Run Keyword If  ${if_nr_exist}  Run Keywords  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
                                    ...    AND    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
                                    ...    AND    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
                                    ...    AND    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
                                    ...    AND    Disallow Fault In Watchdog  faultID=6150  #fault_name: GTP-U Path failure
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${0}<${counter_diff}<${2}  Log To Console  Reset Counter Incremented +${counter_diff}
    ...  ELSE  Log  Reset Counter Incremented +${counter_diff}  WARN

SM.02_Site_Block_Unblock.Test Specific Teardown
    [Documentation]  Test teardown which unblock BTS.
    admin.setup admin  admin_api_log_dir=${RESULTS}/specific_teardown/admin_api/  alias=${ute_admin_alias}
    Log To Console With Time  Trying to unblock BTS
    Run Keyword And Ignore Error  admin.Unblock  timeout=600
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    admin.teardown admin  alias=${ute_admin_alias}

SM.02_Site_Block_Unblock.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
    Run Keyword If Test Failed  SM.02_Site_Block_Unblock.Test Specific Teardown

Check Cells Expected States
    ${cells_list}  admin.get cell list
    ${cells}  Combine Lists    ${cells_list['cells']['lte']}
                      ...      ${cells_list['cells']['wcdma']}
                      ...      ${cells_list['cells']['gsm']}
                      ...      ${cells_list['cells']['nr']}
    FOR  ${cell}  IN  @{cells}
        ${cell_states}        Get From Dictionary  ${cell}         status
        ${blocking_state}     Get From Dictionary  ${cell_states}  blockingState
        ${operational_state}  Get From Dictionary  ${cell_states}  operationalState
        Should Be Equal As Strings  ${blocking_state}  Blocked  ignore_case=True
        Should Be Equal As Strings  ${operational_state}  Disabled  ignore_case=True
    END
    Log To Console  States of cells are correct
