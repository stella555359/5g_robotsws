*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Library     ../../../resources_mem/python_lib/bbmod_faulting.py

Documentation
...  TEST NAME:     SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure
...  AUTHORS:       tomasz.marchewka@nokia.com,
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this scenario is to test the behavior of the BTS during a persistent failure of LOKI unit while performing operations.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  28.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-597 - Test creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${LTE_BLOCKED_EXPECTED_CELL_STATE}    operationalState=regex"(?i)Disabled", blockingState=regex"(?i)Blocked"
${NR_BLOCKED_EXPECTED_CELL_STATE}     operationalState=regex"(?i)Disabled", blockingState=regex"(?i)Blocked"

*** Keywords ***
SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure

    SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:0 Test Preparation
    SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:1 Block RATs
    SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:2 Trigger ABIN Crash
    SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:3 Unblock RATs
    SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:4 Trigger ABIN Recovery Action
    SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:5 Final Checkpoint

SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:0 Test Preparation
    Log To Console  \n========================================
    Log To Console  Step: 0 Test Preparation
    Log To Console  ========================================
    Check If NLWG Cells Are OnAir
    SCF Backup
    ${BBMOD_count}  Count Expected BBMODs  ABIN
    Run Keyword If  ${BBMOD_count}==${0}  Fail  msg=At least one ABIN is expected in configuration.

SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:1 Block RATs
    Log To Console  \n========================================
    Log To Console  Step: 1 Block RATs
    Log To Console  ========================================
    FOR  ${rat}  IN  @{rats}
        Continue For Loop If  '${rat}'=='gsm' or '${rat}'=='wcdma'
        Allow Fault In Watchdog  faultID=4614    #fault_name: RAT blocked
        Log To Console  Blocking ${rat.upper()}
        admin.block_rat    ${rat.upper()}    timeout=180
        Run Keyword If  '${rat}'=='lte'  Run Keywords
        ...         Wait Until Keyword Succeeds  4x  20s  admin.assert every  LNCEL  ${LTE_BLOCKED_EXPECTED_CELL_STATE}
        ...    AND  Log To Console  All LNCELs have states: operationalState=Disabled, blockingState=Blocked
        ...    ELSE IF  '${rat}'=='nr'   Run Keywords
        ...         Wait Until Keyword Succeeds  4x  20s  admin.assert every  NRCEL  ${NR_BLOCKED_EXPECTED_CELL_STATE}
        ...    AND  Log To Console  All NRCELs have states: operationalState=Disabled, blockingState=Blocked
        Wait For Active Fault    faultID=4614    #fault_name: RAT blocked
        Sleep    10s
        ${active_FIDs}  admin.Get Active Alarms
        ${alarm_for_technology}  Evaluate
        ...  [fid['technology'] for fid in ${active_FIDs} if str('4614') == str(fid['faultId']) and str(fid['technology']) == str('${rat.upper()}')]
        Should Be Equal As Strings  ${rat.upper()}  ${alarm_for_technology[0]}
    END

SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:2 Trigger ABIN Crash
    Log To Console  \n========================================
    Log To Console  Step: 2 Trigger ABIN Crash
    Log To Console  ========================================
    Allow Fault In Watchdog  faultID=252     #fault_name: Baseband Module Hardware Failure
    Allow Fault In Watchdog  faultID=4019    #fault_name: Master unit has lost connection to the slave unit
    Log To Console    Generating ABIN crash on LOKI A.
    Generate Fault ABION LokiAB  ABIN  ${SLOT_IN_AMIA}  LokiA
    Wait Until Keyword Succeeds  20x  10s  Check BBMOD State  dn=${BBMOD_DN}  expected_operationalState=DISABLED  expected_availabilityStatus=FAILED
    Wait For Active Fault    faultID=252     #fault_name: Baseband Module Hardware Failure

SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:3 Unblock RATs
    Log To Console  \n========================================
    Log To Console  Step: 3 Unblock RATs
    Log To Console  ========================================
    FOR  ${rat}  IN  @{rats}
        Continue For Loop If  '${rat}'=='gsm' or '${rat}'=='wcdma'
        Log To Console  Unblocking ${rat.upper()}
        admin.unblock_rat    ${rat.upper()}    timeout=180
        Sleep    10s
    END
    Wait For Inactive Fault     faultID=4614    #fault_name: RAT blocked
    Disallow Fault In Watchdog  faultID=4614    #fault_name: RAT blocked

SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:4 Trigger ABIN Recovery Action
    Log To Console  \n========================================
    Log To Console  Step: 4 Trigger ABIN Recovery Action
    Log To Console  ========================================
    Log To Console  Recovering ABIN
    Recovery Action ABION  ${SLOT_IN_AMIA}
    Run Keywords  Allow Fault In Watchdog  faultID=245   #fault_name: Baseband card autonomous reset as recovery action
    ...    AND    Allow Fault In Watchdog  faultID=4341  #fault_name: SoC autonomous reset as recovery action
    ...    AND    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ...    AND    Allow Fault In Watchdog  faultID=6150  #fault_name: GTP-U Path Failure
    admin.reset site  timeout=700

SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test_Step:5 Final Checkpoint
    Log To Console  \n========================================
    Log To Console  Step: 5 Final Checkpoint
    Log To Console  ========================================
    Check SMODs State  ${SMOD_expected_states}
    Check BBMODs State  ${BBMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Run Keyword If  'nr' in $rats  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
    Run Keywords  Disallow Fault In Watchdog  faultID=245     #fault_name: Baseband card autonomous reset as recovery action
    ...    AND    Disallow Fault In Watchdog  faultID=252     #fault_name: Baseband Module Hardware Failure
    ...    AND    Disallow Fault In Watchdog  faultID=4019    #fault_name: Master unit has lost connection to the slave unit
    ...    AND    Disallow Fault In Watchdog  faultID=4341    #fault_name: SoC autonomous reset as recovery action
    ...    AND    Disallow Fault In Watchdog  faultID=6327    #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Disallow Fault In Watchdog  faultID=7300    #fault_name: No X2 link available
    ...    AND    Disallow Fault In Watchdog  faultID=7319    #fault_name: No X2 link available for a specific LTEENB
    ...    AND    Disallow Fault In Watchdog  faultID=6150    #fault_name: GTP-U Path Failure

SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test Case Teardown
    [Documentation]  Test teardown which unblock RATs.
    Run Keyword    common.Common Test Teardown
    Run Keyword If Test Failed    SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test Specific Teardown

SM.35_RAT_Block_Unblock_with_ABIN_LOKI_power_failure.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
    admin.setup admin  admin_api_log_dir=${RESULTS}/specific_teardown/admin_api/  alias=${ute_admin_alias}
    FOR  ${rat}  IN  @{rats}
        Continue For Loop If  '${rat}'=='gsm' or '${rat}'=='wcdma'
        Run Keyword And Ignore Error  admin.unblock_rat  ${rat.upper()}  timeout=180
    END
    ${bbmod_recovered}  Run Keyword And Return Status
    ...    Check BBMOD State  dn=${BBMOD_DN}  expected_operationalState=ENABLED  expected_availabilityStatus=NONE
    Run Keyword If  not ${bbmod_recovered}  Run Keywords  Recovery Action ABION  ${SLOT_IN_AMIA}
    ...  AND  admin.reset site  timeout=700
    ...  AND  Check SMODs State  ${SMOD_expected_states}
    ...  AND  Check BBMODs State  ${BBMOD_expected_states}
    ...  AND  Check RMODs State  ${RMOD_expected_states}
    ...  AND  Check If ALDs Are Connected And Achieved Expected State
    ...  AND  common.Check BTS State  ${BTS_expected_states}
    ...  AND  Check If NLWG Cells Are OnAir
    admin.teardown admin  alias=${ute_admin_alias}
