*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/netact.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.33_CNI_Grace_Cell_Down_Reset
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to verify if site reset with grace cell shutdown option works as it should work.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  04.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-376 - TC creation
...  ******************
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.33_CNI_Grace_Cell_Down_Reset

    PS.33_CNI_Grace_Cell_Down_Reset.Test_Step:0 Test Preparation
    PS.33_CNI_Grace_Cell_Down_Reset.Test_Step:1 Perform Grace Reset
    PS.33_CNI_Grace_Cell_Down_Reset.Test_Step:2 Final Recovery and Checkpoint

PS.33_CNI_Grace_Cell_Down_Reset.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Test Variable  ${pre_action_reset_number}
    Remove SWRESETREQ Object If Exists
#    Set Feature Under Given Object  shutdownWindow  60  NRBTS
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  120

PS.33_CNI_Grace_Cell_Down_Reset.Test_Step:1 Perform Grace Reset
    Log to console    \n========================================
    Log  Step: 1 Perform Grace Reset  console=${True}
    Log to console    ========================================
    Create And Activate SWRESETREQ  SWRESETREQ-1
    Log to console  Check If Gracefull working
    Log to console  SWRESETREQ For CB006830  SWRESETREQ-1 ACTIVATED
    Check For Specofic Time  NR  ENABLED  60
    Log to console  === Waiting for grace cell shutdown for NR ===
    Wait Until Keyword Succeeds  10sec  10sec  Check If Cells Are Disabled  NR  DISABLED
    Log to console  === NR cells are disabled ===
    Log to console  === Waiting for grace cell shutdown for LTE ===
    Check For Specofic Time  LTE  ENABLED  15
    Wait Until Keyword Succeeds  120sec  1sec  Check If Cells Are Disabled  LTE  DISABLED
    Log to console  === NR cells are disabled ===

PS.33_CNI_Grace_Cell_Down_Reset.Test_Step:2 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step: 3 Final Recovery and Checkpoint  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check If ALDs Are Connected And Achieved Expected State
	common.Check BTS State  ${BTS_expected_states}
	Check If NLWG Cells Are OnAir
	Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
	Check If Unexpected Alarms Are Raised  ${skip_fault}
	${post_action_reset_number}=  Get Reset Counter From Blackbox
    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
    IF  ${counter_diff}==${0}
        Log  Reset Counter not incremented
    ELSE IF  ${counter_diff}>${1}
        Fail  msg=Reset Counter incremented (more than 1 unexpected reset)
    ELSE IF  ${counter_diff}==${1}
        Log to console  Reset Counter incremented +1
    END

PS.33_CNI_Grace_Cell_Down_Reset.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Remove SWRESETREQ Object If Exists
#    Set Feature Under Given Object  shutdownWindow  180  NRBTS
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.33_CNI_Grace_Cell_Down_Reset.Test Case Teardown
    common.Common Test Teardown
    Run Keyword If Test Failed  PS.33_CNI_Grace_Cell_Down_Reset.Test Specific Teardown

Check If Cells Are Disabled
    [Arguments]  ${technology}  ${state_value}  ${alias}=default
    ${cells_list}=  admin.get cell list  alias=${alias}
    ${lte_cells}  Set Variable   ${cells_list['cells']['lte']}
    ${nr_cells}  Set Variable   ${cells_list['cells']['nr']}
    IF  '${technology}'=='LTE'
        State For List Of Cells  ${lte_cells}  ${state_value}
    ELSE IF  '${technology}'=='NR'
        State For List Of Cells  ${nr_cells}  ${state_value}
    END

State For List Of Cells
    [Arguments]  ${listOfCells}  ${state_value}
        FOR  ${cell}  IN   @{listOfCells}
            ${cell_states}  Get From Dictionary  ${cell}  status
            ${operational_state}  Get From Dictionary  ${cell_states}  operationalState
            ${operational_state}  Evaluate  "${operational_state}".upper()
            Should Be True  '${operational_state}'=='${state_value}'
        END


