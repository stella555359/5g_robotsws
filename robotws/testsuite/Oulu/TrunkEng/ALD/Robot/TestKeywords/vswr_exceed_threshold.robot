*** Settings ***

Documentation
...  Author:   Essi Passoja
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource   testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library    testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.CommonAldInterface


*** Keywords ***
Exceed VSWR Threshold
    [Arguments]  ${ANTL}  ${RMOD}  ${ALARM}  ${THRESHOLD}  ${WAIT_FOR_ALARMS}  ${WAIT_AFTER_CANCEL_ALARM}
    Print Step Text                   1  Check Preconditions
    Run Keyword and Continue On Failure  Common Preconditions
    ${antl_obj}=                         Get Antenna Line Object  ${ANTL}
    ${rmod_obj}=                         Get RMOD Object From User Given Values  ${RMOD}
    Print Text To Eventlog               Antenna Line ${ANTL} connected to cells ${ANTL_OBJ.connected_cells}
    Print Text To Eventlog               Get initial VSWR value from Admin
    ${initial_vswr_value}=               VSWR Value From Admin  ${ALARM}  ${antl_obj}
    Run Keyword and Continue On Failure  Check That All Antennas Have TX Power  ${rmod_obj}
    Print Step Text                   2  Set VSWR value to trigger alarm
    Run Keyword If  '${ALARM}' == '1837'   Add Expected Alarm  alarm_id=7654  fault_id=${ALARM}
    ...                                    fault_name=VSWR upper threshold exceeded  unit_path=${ANTL_OBJ.unit_path}
    Run Keyword If  '${ALARM}' == '1838'   Add Expected Alarm  alarm_id=7654  fault_id=${ALARM}
    ...                                    fault_name=VSWR lower threshold exceeded  unit_path=${ANTL_OBJ.unit_path}
    Set VSWR Value To Trigger Alarm      ${ALARM}  ${antl_obj}  ${THRESHOLD}
    Run Keyword and Continue On Failure  SCF.Get SCF  extra_name=after_commissioning
    Run Keyword and Continue On Failure  Compare VSWR Values  ${ALARM}  ${antl_obj}  ${THRESHOLD}
    Print Step Text                   3  Check expected alarms and cell states
    Run Keyword and Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARMS}
    Run Keyword and Continue On Failure  Wait For All Cells Up  time_limit=120  degraded_cells=${antl_obj.connected_cells}
    Run Keyword If  '${ALARM}' == '1837'   Run Keyword And Continue On Failure
    ...                                    Check That All Antennas Have TX Power Except  ${rmod_obj}  ${antl_obj}
    Print Step Text                   4  Make radio reset and check that new alarm is reported
    Print Text To Eventlog               Requesting warm reset to ${rmod_obj.dist_name} (${rmod_obj.name})
    Run Keyword And Continue On Failure  ADMIN.Reset Unit  dist_name=${rmod_obj.dist_name}
    ...                                  reset_type=Warm  timeout=600  detailed_output=True
    Run Keyword and Continue On Failure  Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARMS}  get_active_alarms=${True}
    Run Keyword and Continue On Failure  Wait For All Cells Up  time_limit=120  degraded_cells=${antl_obj.connected_cells}
    Run Keyword If  '${ALARM}' == '1837'   Run Keyword And Continue On Failure
    ...                                    Check That All Antennas Have TX Power Except  ${rmod_obj}  ${antl_obj}
    Print Step Text                   5  Set VSWR value to initial to cancel alarm
    Run Keyword And Continue On Failure  Set VSWR Value To Clear Alarm  ${antl_obj}  31
    Run Keyword If  '${ALARM}' == '1837'   Run Keywords
    ...       Print Text To Eventlog  Requesting warm reset to ${rmod_obj.dist_name} (${rmod_obj.name})
    ...  AND  Run Keyword And Continue On Failure  ADMIN.Reset Unit  dist_name=${rmod_obj.dist_name}
    ...       reset_type=Warm  timeout=600  detailed_output=True
    Run Keyword and Continue On Failure  SCF.Get SCF  extra_name=after_second_commissioning
    Run Keyword and Continue On Failure  Compare VSWR Values  ${ALARM}  ${antl_obj}  31
    Print Step Text                   6  Check that alarm has been cancelled
    Wait Time And Reason                 ${WAIT_AFTER_CANCEL_ALARM}  Wait before checking that alarms have been cancelled
    Run Keyword And Continue On Failure  Reset Alarms
    Run Keyword and Continue On Failure  Check Active Alarms
    Print Step Text                   7  Check alarm history and postconditions
    # Need to add VSWR alarm to the list so it does not fail the alarm history check
    Run Keyword If  '${ALARM}' == '1837'   Add Expected Alarm  alarm_id=7654  fault_id=${ALARM}
    ...                                    fault_name=VSWR upper threshold exceeded  unit_path=${antl_obj.unit_path}
    Run Keyword If  '${ALARM}' == '1838'   Add Expected Alarm  alarm_id=7654  fault_id=${ALARM}
    ...                                    fault_name=VSWR lower threshold exceeded  unit_path=${antl_obj.unit_path}
    Run Keyword and Continue On Failure  Common Postconditions
    Run Keyword and Continue On Failure  Check That All Antennas Have TX Power  ${rmod_obj}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
