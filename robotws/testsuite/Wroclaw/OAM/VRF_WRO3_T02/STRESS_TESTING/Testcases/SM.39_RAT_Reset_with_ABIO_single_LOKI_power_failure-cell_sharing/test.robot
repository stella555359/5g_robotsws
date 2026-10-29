*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/scf.robot
Library     ../../../resources_mem/python_lib/bbmod_faulting.py

Documentation
...  TEST NAME:     SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing
...  AUTHORS:       tomasz.marchewka@nokia.com, paulina.zachorodna@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this scenario is to test the behavior of the BTS during a persistent failure of a all LOKI unit while performing operations.
...  All cells partially or fully deployed on failed Loki are set as Disabled/Failed. Other cells are not impacted.
...  TC created for dedicated TL: enb101003
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  18.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-608 - Test creation
...  18.03.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-17486 - TC adaptation with TMO config (MRBTS-8288)
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
@{RESET_TYPES}    Soft    Hard

*** Keywords ***
SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing
    SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:0 Test Preparation
    SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:1 Trigger ABIO LOKI B Crash
    SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:2 Reset RATs
    SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:3 Check If LOKI B Crash
    SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:4 Trigger ABIO Recovery Action
    SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:5 Final Checkpoint

SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:0 Test Preparation
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

SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:1 Trigger ABIO LOKI B Crash
    Log To Console  \n========================================
    Log To Console  Step: 1 Trigger ABIO LOKI B Crash
    Log To Console  ========================================
    Allow Fault In Watchdog  faultID=4663    #fault_name: Baseband card crash has been detected
    Allow Fault In Watchdog  faultID=252     #fault_name: Baseband Module Hardware Failure
    Log To Console    Generating ABIO crash on LOKI B.
    Generate Fault ABION LokiAB  ABIO  ${SLOT_IN_AMIA}  LokiB
    Wait Until Keyword Succeeds  8x  10s  Check BBMOD State  dn=${BBMOD_DN}  expected_operationalState=ENABLED  expected_availabilityStatus=DEGRADED
    Wait For Active Fault    faultID=252    #fault_name: Baseband Module Hardware Failure

SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:2 Reset RATs
    Log To Console  \n========================================
    Log To Console  Step: 2 Reset RATs
    Log To Console  ========================================
    Allow Fault In Watchdog    faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog    faultID=7107  #fault_name: Cell problem due to associated X2/NG/E1 link unavailability
    Allow Fault In Watchdog    faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog    faultID=7312  #fault_name: NgGnbInitFullReset on /SERVEDAMF-1
    Allow Fault In Watchdog    faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    FOR  ${rat}  IN  @{rats}
        Continue For Loop If  '${rat}'=='gsm' or '${rat}'=='wcdma'
        ${reset_type}  Evaluate  random.choice(@{RESET_TYPES})  random
        Log To Console  ${reset_type} resetting ${rat.upper()}
        admin.rat reset  rat_type=${rat.upper()}  graceful_cell_shutdown=false  reset_type=${reset_type}  timeout=700
    END
    Wait For Inactive Fault     faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Wait For Inactive Fault     faultID=7107  #fault_name: Cell problem due to associated X2/NG/E1 link unavailability
    Wait For Inactive Fault     faultID=7300  #fault_name: No X2 link available
    Wait For Inactive Fault     faultID=7312  #fault_name: NgGnbInitFullReset on /SERVEDAMF-1
    Wait For Inactive Fault     faultID=7319  #fault_name: No X2 link available for a specific LTEENB

SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:3 Check If LOKI B Crash
    Log To Console  \n========================================
    Log To Console  Step: 3 Check If LOKI B Crash
    Log To Console  ========================================
    Allow Fault In Watchdog  faultID=4663    #fault_name: Baseband card crash has been detected
    Allow Fault In Watchdog  faultID=252     #fault_name: Baseband Module Hardware Failure
    Wait Until Keyword Succeeds  3x  10s  Check BBMOD State  dn=${BBMOD_DN}  expected_operationalState=ENABLED  expected_availabilityStatus=DEGRADED
    Log to console   Check if LNCELL is on Air
    Check LNCEL/NRCELL OnAir Or EnergySaving State  lte

SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:4 Trigger ABIO Recovery Action
    Log To Console  \n========================================
    Log To Console  Step: 4 Trigger ABIO Recovery Action
    Log To Console  ========================================
    Log To Console  Recovering ABIO
    Recovery Action ABION  ${SLOT_IN_AMIA}
    Run Keywords  Allow Fault In Watchdog  faultID=245   #fault_name: Baseband card autonomous reset as recovery action
    ...    AND    Allow Fault In Watchdog  faultID=4341  #fault_name: SoC autonomous reset as recovery action
    ...    AND    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...    AND    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...    AND    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ...    AND    Allow Fault In Watchdog  faultID=6150  #GTP-U Path Failure
    admin.reset site  timeout=700

SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test_Step:5 Final Checkpoint
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
    ...    AND    Disallow Fault In Watchdog  faultID=6150    #GTP-U Path Failure
    Run Keyword If  '${actRatResetEnhancement_backup_value}'=='false'   Run Keywords
    ...    Log To Console    Back to previous parameter settings...
    ...    AND    admin.perform parameter recommissioning  ${FEATCADM_DN}  actRatResetEnhancement  update  false  ${SKIP_PARAMETER_RELATION_ERRORS}

SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test Case Teardown
    [Documentation]  Test teardown which unblock RATs.
    Run Keyword    common.Common Test Teardown
    Run Keyword If Test Failed    SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test Specific Teardown

SM.39_RAT_Reset_with_ABIO_single_LOKI_power_failure-cell_sharing.Test Specific Teardown
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
    ...    AND    Allow Fault In Watchdog  faultID=6150  #GTP-U Path Failure
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
    ...    AND    Disallow Fault In Watchdog  faultID=6150    #GTP-U Path Failure
    admin.teardown admin  alias=${ute_admin_alias}
