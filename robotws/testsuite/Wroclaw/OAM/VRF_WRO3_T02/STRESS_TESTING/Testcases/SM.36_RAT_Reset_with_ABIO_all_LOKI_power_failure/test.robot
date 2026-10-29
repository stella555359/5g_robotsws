*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/scf.robot
Library     ../../../resources_mem/python_lib/bbmod_faulting.py

Documentation
...  TEST NAME:     SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure
...  AUTHORS:       tomasz.marchewka@nokia.com,
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this scenario is to test the behavior of the BTS during a persistent failure of a all LOKI unit while performing operations.
...  If there were cells setup on failed LOKI(s), these cells are set as disabled.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  04.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-593 - Test creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
@{RESET_TYPES}    Soft    Hard

*** Keywords ***
SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure

    SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test_Step:0 Test Preparation
    SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test_Step:1 Trigger ABIO Crash
    SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test_Step:2 Reset RATs
    SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test_Step:3 Trigger ABIO Recovery Action
    SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test_Step:4 Final Checkpoint

SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test_Step:0 Test Preparation
    Log To Console  \n========================================
    Log To Console  Step: 0 Test Preparation
    Log To Console  ========================================
    Check If NLWG Cells Are OnAir
    SCF Backup
    ${BBMOD_count}  Count Expected BBMODs  ABIO
    Run Keyword If  ${BBMOD_count}==${0}  Fail  msg=At least one ABIO is expected in configuration.
    ${actRatResetEnhancement_backup_value}    Get SCF Backup Value    p_name=actRatResetEnhancement
    Set Test Variable    ${FEATCADM_DN}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Run Keyword If  '${actRatResetEnhancement_backup_value}'=='false'   Run Keywords
    ...    Log To Console    Feature status for actRatResetEnhancement is incorrect, activating feature...
    ...    AND    admin.perform parameter recommissioning  ${FEATCADM_DN}  actRatResetEnhancement  update  true  ${SKIP_PARAMETER_RELATION_ERRORS}
    Set Test Variable  ${actRatResetEnhancement_backup_value}

SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test_Step:1 Trigger ABIO Crash
    Log To Console  \n========================================
    Log To Console  Step: 1 Trigger ABIO Crash
    Log To Console  ========================================
    Allow Fault In Watchdog  faultID=252     #fault_name: Baseband Module Hardware Failure
    Allow Fault In Watchdog  faultID=4019    #fault_name: Master unit has lost connection to the slave unit
    Log To Console    Generating ABIO crash on LOKI A.
    Generate Fault ABION LokiAB  ABIO  ${SLOT_IN_AMIA}  LokiA
    Log To Console    Generating ABIO crash on LOKI B.
    Generate Fault ABION LokiAB  ABIO  ${SLOT_IN_AMIA}  LokiB
    Wait Until Keyword Succeeds  20x  10s  Check BBMOD State  dn=${BBMOD_DN}  expected_operationalState=DISABLED  expected_availabilityStatus=FAILED
    Wait For Active Fault    faultID=252     #fault_name: Baseband Module Hardware Failure
#    Wait For Active Fault    faultID=4019    #fault_name: Master unit has lost connection to the slave unit

SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test_Step:2 Reset RATs
    Log To Console  \n========================================
    Log To Console  Step: 2 Reset RATs
    Log To Console  ========================================
    Allow Fault In Watchdog    faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog    faultID=7107  #Cell problem due to associated X2/NG/E1 link unavailability
    Allow Fault In Watchdog    faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog    faultID=7312  #NgGnbInitFullReset on /SERVEDAMF-1
    Allow Fault In Watchdog    faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    FOR  ${rat}  IN  @{rats}
        Continue For Loop If  '${rat}'=='gsm' or '${rat}'=='wcdma'
        ${reset_type}  Evaluate  random.choice(@{RESET_TYPES})  random
        Log To Console  ${reset_type} resetting ${rat.upper()}
        admin.rat reset  rat_type=${rat.upper()}  graceful_cell_shutdown=false  reset_type=${reset_type}  timeout=700
    END
    Wait For Inactive Fault     faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Wait For Inactive Fault     faultID=7107  #Cell problem due to associated X2/NG/E1 link unavailability
    Wait For Inactive Fault     faultID=7300  #fault_name: No X2 link available
    Wait For Inactive Fault     faultID=7312  #NgGnbInitFullReset on /SERVEDAMF-1
    Wait For Inactive Fault     faultID=7319  #fault_name: No X2 link available for a specific LTEENB

SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test_Step:3 Trigger ABIO Recovery Action
    Log To Console  \n========================================
    Log To Console  Step: 3 Trigger ABIO Recovery Action
    Log To Console  ========================================
    Log To Console  Recovering ABIO
    Recovery Action ABION  ${SLOT_IN_AMIA}
    Run Keywords  Allow Fault In Watchdog  faultID=245   #fault_name: Baseband card autonomous reset as recovery action
    ...    AND    Allow Fault In Watchdog  faultID=4341  #fault_name: SoC autonomous reset as recovery action
    ...    AND    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    admin.reset site  timeout=700

SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test_Step:4 Final Checkpoint
    Log To Console  \n========================================
    Log To Console  Step: 4 Final Checkpoint
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
    Run Keyword If  '${actRatResetEnhancement_backup_value}'=='false'   Run Keywords
    ...    Log To Console    Back to previous parameter settings...
    ...    AND    admin.perform parameter recommissioning  ${FEATCADM_DN}  actRatResetEnhancement  update  false  ${SKIP_PARAMETER_RELATION_ERRORS}

SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test Case Teardown
    [Documentation]  Test teardown which unblock RATs.
    Run Keyword    common.Common Test Teardown
    Run Keyword If Test Failed    SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test Specific Teardown

SM.36_RAT_Reset_with_ABIO_all_LOKI_power_failure.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
    admin.setup admin  admin_api_log_dir=${RESULTS}/specific_teardown/admin_api/  alias=${ute_admin_alias}
    Run Keyword If  '${actRatResetEnhancement_backup_value}'=='false'   Run Keywords
    ...    Log To Console    Back to previous parameter settings...
    ...    AND    admin.perform parameter recommissioning  ${FEATCADM_DN}  actRatResetEnhancement  update  false  ${SKIP_PARAMETER_RELATION_ERRORS}
    ${bbmod_recovered}  Run Keyword And Return Status
    ...    Check BBMOD State  dn=${BBMOD_DN}  expected_operationalState=ENABLED  expected_availabilityStatus=NONE
    Run Keyword If  not ${bbmod_recovered}  Run Keywords  Recovery Action ABION  ${SLOT_IN_AMIA}
    ...    AND    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ...    AND    admin.reset site  timeout=700
    ...    AND    Check SMODs State  ${SMOD_expected_states}
    ...    AND    Check BBMODs State  ${BBMOD_expected_states}
    ...    AND    Check RMODs State  ${RMOD_expected_states}
    ...    AND    Check If ALDs Are Connected And Achieved Expected State
    ...    AND    common.Check BTS State  ${BTS_expected_states}
    ...    AND    Check If NLWG Cells Are OnAir
    ...    AND    Disallow Fault In Watchdog  faultID=6327    #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Disallow Fault In Watchdog  faultID=7300    #fault_name: No X2 link available
    ...    AND    Disallow Fault In Watchdog  faultID=7319    #fault_name: No X2 link available for a specific LTEENB
    admin.teardown admin  alias=${ute_admin_alias}
