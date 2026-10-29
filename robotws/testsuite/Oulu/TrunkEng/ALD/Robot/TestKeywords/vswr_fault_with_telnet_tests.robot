*** Settings ***

Documentation
...  Author:   Terhi Talvitie
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource   testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library    testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.CommonAldInterface
Library    testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingRmod


*** Keywords ***
VSWR Minor Alarm With Telnet
    [Documentation]  This keyword is used to cause VSWR minor alarm with telnet to given radio module and antenna line.
    ...              Fault is canceled with telnet command after alarm is raised.
    [Arguments]  ${ANTL}  ${RMOD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    Print Step Text                   1  Check Preconditions
    Run Keyword and Continue On Failure  Common Preconditions
    ${antl_obj}=                         Get Antenna Line Object  ${ANTL}
    ${rmod_obj}=                         Get RMOD Object From User Given Values  ${RMOD}
    Print Text To Eventlog               Antenna Line ${ANTL} connected to cells ${ANTL_OBJ.connected_cells}
    ${tx_resource}=                      Get Tx Resource To Be Used  ${rmod_obj}  ${ANTL_OBJ.connected_cells}  ${ANTL}
    ${affected_cells}=                   Get Cells Connected To Selected Tx  ${tx_resource}  ${rmod_obj}  ${ANTL}
    Print Step Text                   2  Set VSWR Minor Alarm (fault id: 1838) for ${tx_resource} of ${rmod_obj.name}
    Run Keyword And Continue On Failure  Add Expected Alarm  alarm_id=7654  fault_id=1838
    ...                                  fault_name=VSWR lower threshold exceeded  unit_path=${ANTL_OBJ.unit_path}
    Run Keyword And Continue On Failure  Cause Fault With Telnet  ${rmod_obj}  1838  resource=${tx_resource}
    ...                                  alarm_severity=Minor  deactivate_fault=${False}
#    Run Keyword And Continue On Failure  Wait Time And Reason   ${WAIT_FOR_ALARMS}   wait_reason=for filtering time
    Print Step Text                   3  Check expected alarms and cell states
    Run Keyword and Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARMS}
    Run Keyword and Continue On Failure  Check Expected States  ${affected_cells}  ${rmod_obj}  state=cell_enabled_degraded
    # Run Keyword And Continue On Failure  Get Radio Powers  ${rmod_obj}  tx  # DEBUG LINE
    # Run Keyword If  '${ALARM}' == '1837'   Check TX power of affected cell
    Print Step Text                   4  Cancel VSWR Minor Alarm (fault id: 1838) for ${tx_resource} of ${rmod_obj.name}
    Run Keyword And Continue On Failure  Cause Fault With Telnet  ${rmod_obj}  1838  resource=${tx_resource}
    ...                                  alarm_severity=Minor  deactivate_fault=${True}
    Print Step Text                   5  Check that alarm has been cancelled
    ${alarm_to_add_allowed}=             ALARMS.Get Expected Alarms
    Wait Time And Reason                 ${WAIT_AFTER_CANCEL_ALARM}  before checking that alarms have been cancelled
    Run Keyword And Continue On Failure  Reset Alarms
    Run Keyword and Continue On Failure  Check Active Alarms
    Print Step Text                   6  Check alarm history and postconditions
    # Need to add VSWR alarm to the list so it does not fail the alarm history check
    Run Keyword And Continue On Failure  ALARMS.Add Allowed Alarms  ${alarm_to_add_allowed}
    Run Keyword and Continue On Failure  Common Postconditions

VSWR Major Alarm With Telnet
    [Documentation]  This keyword is used to cause VSWR major alarm with telnet to given radio module and antenna line.
    ...              Fault is canceled with radio lock and unlock after alarm is raised.
    [Arguments]  ${ANTL}  ${RMOD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    Print Step Text                   1  Check Preconditions
    Run Keyword and Continue On Failure  Common Preconditions
    ${antl_obj}=                         Get Antenna Line Object  ${ANTL}
    ${rmod_obj}=                         Get RMOD Object From User Given Values  ${RMOD}
    Print Text To Eventlog               Antenna Line ${ANTL} connected to cells ${ANTL_OBJ.connected_cells}
    ${tx_resource}=                      Get Tx Resource To Be Used  ${rmod_obj}  ${ANTL_OBJ.connected_cells}  ${ANTL}
    ${affected_cells}=                   Get Cells Connected To Selected Tx  ${tx_resource}  ${rmod_obj}  ${ANTL}
    Print Step Text                   2  Set VSWR Major Alarm (fault id: 1837) for ${tx_resource} of ${rmod_obj.name}
    Run Keyword And Continue On Failure  Add Expected Alarm  alarm_id=7654  fault_id=1837
    ...                                  fault_name=VSWR upper threshold exceeded  unit_path=${ANTL_OBJ.unit_path}
    Run Keyword And Continue On Failure  Cause Fault With Telnet  ${rmod_obj}  1837  resource=${tx_resource}
    ...                                  alarm_severity=Major  deactivate_fault=${False}
#    Run Keyword And Continue On Failure  Wait Time And Reason   ${WAIT_FOR_ALARMS}   wait_reason=for filtering time
    Print Step Text                   3  Check expected alarms and cell states
    Run Keyword and Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARMS}
    ${two_tx}=                           Check If Cells Have At Least Two Tx    ${affected_cells}
    Run Keyword If                       '${two_tx}' == 'True'  Run Keyword And Continue On Failure
    ...                                  Check That All Antennas Have TX Power Except  ${rmod_obj}  ${antl_obj}  telnet=${True}
    Run Keyword And Continue On Failure  Wait Cells Based On Affected Cells  ${affected_cells}
    Run Keyword And Continue On Failure  Check Expected States  ${affected_cells}   ${rmod_obj}  state=cell_disabled
    # Run Keyword And Continue On Failure  Get Radio Powers  ${rmod_obj}  tx  # DEBUG LINE
    # Run Keyword If  '${ALARM}' == '1837'   Check TX power of affected cell
    Print Step Text                   4  Cancel VSWR Major Alarm (fault id: 1837) from ${rmod_obj.name} by radio lock and unlock
    Print Text To Eventlog               Request radio lock to ${rmod_obj.dist_name} (${rmod_obj.name})
    Run Keyword And Continue On Failure  Lock Radio  ${RMOD}
    Run Keyword And Continue On Failure  Wait Time And Reason   15   wait_reason=before unlock
    Print Text To Eventlog               Request radio unlock to ${rmod_obj.dist_name} (${rmod_obj.name})
    Run Keyword And Continue On Failure  Unlock Radio  ${RMOD}
    Run Keyword and Continue On Failure  Wait For All Cells Up  time_limit=300
    Print Step Text                   5  Check that alarm has been cancelled
    ${alarm_to_add_allowed}=             ALARMS.Get Expected Alarms
    Wait Time And Reason                 ${WAIT_AFTER_CANCEL_ALARM}  before checking that alarms have been cancelled
    Run Keyword And Continue On Failure  Reset Alarms
    Run Keyword and Continue On Failure  Check Active Alarms
    Print Step Text                   6  Check alarm history and postconditions
    # Need to add VSWR alarm to the list so it does not fail the alarm history check
    Run Keyword And Continue On Failure  ALARMS.Add Allowed Alarms  ${alarm_to_add_allowed}
    Run Keyword and Continue On Failure  Common Postconditions

VSWR Minor Major Alarm Telnet
    [Arguments]  ${ANTL}  ${RMOD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    Print Step Text                   1  Check Preconditions
    Run Keyword and Continue On Failure  Common Preconditions
    ${antl_obj}=                         Get Antenna Line Object  ${ANTL}
    ${rmod_obj}=                         Get RMOD Object From User Given Values  ${RMOD}
    Print Text To Eventlog               Antenna Line ${ANTL} connected to cells ${ANTL_OBJ.connected_cells}
    ${tx_resource}=                      Get Tx Resource To Be Used  ${rmod_obj}  ${ANTL_OBJ.connected_cells}  ${ANTL}
    ${affected_cells}=                   Get Cells Connected To Selected Tx  ${tx_resource}  ${rmod_obj}  ${ANTL}
    Print Step Text                   2  Set VSWR Minor Alarm (fault id: 1838) for ${tx_resource} of ${rmod_obj.name}
    Run Keyword And Continue On Failure  ALARMS.Add Expected Alarm  alarm_id=7654  fault_id=1838
    ...                                  fault_name=VSWR lower threshold exceeded  unit_path=${ANTL_OBJ.unit_path}
    Run Keyword And Continue On Failure  Cause Fault With Telnet  ${rmod_obj}  1838  resource=${tx_resource}
    ...                                  alarm_severity=Minor  deactivate_fault=${False}
#    Run Keyword And Continue On Failure  Wait Time And Reason   ${WAIT_FOR_ALARMS}   wait_reason=for filtering time
    Print Step Text                   3  Check expected alarms and cell states
    Run Keyword and Continue On Failure  ALARMS.Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARMS}
    Run Keyword and Continue On Failure  Check Expected States  ${affected_cells}  ${rmod_obj}  state=cell_enabled_degraded
    # Run Keyword and Continue On Failure  Wait For All Cells Up  time_limit=120  degraded_cells=${affected_cells}
    # Run Keyword And Continue On Failure  Get Radio Powers  ${rmod_obj}  tx  # DEBUG LINE
    # Run Keyword If  '${ALARM}' == '1837'   Check TX power of affected cell
    ${alarm_to_add_allowed_minor}=       ALARMS.Get Expected Alarms
#    Run Keyword And Continue On Failure  Remove Expected Alarm   ${alarm_to_add_allowed}
    Print Step Text                   4  Set VSWR Major Alarm (fault id: 1837) for ${tx_resource} of ${rmod_obj.name}
    Run Keyword And Continue On Failure  Cause Fault With Telnet  ${rmod_obj}  1837  resource=${tx_resource}
    ...                                  alarm_severity=Major  deactivate_fault=${False}
#    Run Keyword And Continue On Failure  Wait Time And Reason   ${WAIT_FOR_ALARMS}   wait_reason=for filtering time
    Run Keyword And Continue On Failure  ALARMS.Reset Alarms
    Run Keyword And Continue On Failure  ALARMS.Add Expected Alarm  alarm_id=7654  fault_id=1837
    ...                                  fault_name=VSWR upper threshold exceeded  unit_path=${ANTL_OBJ.unit_path}
    Print Step Text                   5  Check expected alarms and cell states
    Run Keyword and Continue On Failure  ALARMS.Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARMS}  get_active_alarms=${True}
    ${two_tx}=                           Check If Cells Have At Least Two Tx    ${affected_cells}
    Run Keyword If                       '${two_tx}' == 'True'  Run Keyword And Continue On Failure
    ...                                  Check That All Antennas Have TX Power Except  ${rmod_obj}  ${antl_obj}  telnet=${True}
    Run Keyword And Continue On Failure  Wait Cells Based On Affected Cells  ${affected_cells}
    Run Keyword And Continue On Failure  Check Expected States  ${affected_cells}   ${rmod_obj}  state=cell_disabled
    Print Step Text                   6  Cancel VSWR Major Alarm (fault id: 1837) from ${rmod_obj.name} by radio lock and unlock
    Print Text To Eventlog               Request radio lock to ${rmod_obj.dist_name} (${rmod_obj.name})
    Run Keyword And Continue On Failure  Lock Radio  ${RMOD}
    Run Keyword And Continue On Failure  Wait Time And Reason   15   wait_reason=before unlock
    Print Text To Eventlog               Request radio unlock to ${rmod_obj.dist_name} (${rmod_obj.name})
    Run Keyword And Continue On Failure  Unlock Radio  ${RMOD}
    Run Keyword and Continue On Failure  Wait For All Cells Up  time_limit=300
    Print Step Text                   7  Check that alarm has been cancelled
    ${alarm_to_add_allowed_major}=       ALARMS.Get Expected Alarms
    Wait Time And Reason                 ${WAIT_AFTER_CANCEL_ALARM}  before checking that alarms have been cancelled
    Run Keyword And Continue On Failure  Reset Alarms
    Run Keyword and Continue On Failure  Check Active Alarms
    Print Step Text                   8  Check alarm history and postconditions
    # Need to add VSWR alarm to the list so it does not fail the alarm history check
    Run Keyword And Continue On Failure  ALARMS.Add Allowed Alarms  ${alarm_to_add_allowed_minor}
    Run Keyword And Continue On Failure  ALARMS.Add Allowed Alarms  ${alarm_to_add_allowed_major}
    Run Keyword and Continue On Failure  Common Postconditions
