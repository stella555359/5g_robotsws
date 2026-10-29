*** Settings ***

Documentation
...  Author:   Sirpa Passoja / Mirka Kyllönen
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingBBMOD
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/Resources/unit_state_check_kws.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/Resources/ssh_commands_kws.robot

*** Variables ***
${RESET_TYPE}        Warm

*** Keywords ***
ABIA 476 Primary SOC
    [Documentation]  This KW causes 476 fault to K2x of ABIAs and expects autonomous reset or alarm active.
    ...              UNIT can be only ABIA and SOC for K2A
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}  ${WAIT_AFTER_SITE_RESET}
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Run Keyword And Continue On Failure        Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                            ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure        Common Preconditions

    ${BBMOD_LIST}=    Get All Bbmods
#   476 fault to K2A of all BBMODs in configuration
    FOR    ${bbmod}    IN    @{BBMOD_LIST}
        ${BBMOD_OBJ}=                          Get Bbmod Object From User Given Values    ${bbmod}
        ${bbmod_unit_path}=                    Get Values From Object    ${BBMOD_OBJ}    unit_path
        ${bbmod_hw_path}=                      Get Values From Object    ${BBMOD_OBJ}    hw_path
        ${bbmod_name}=                         Get Values From Object    ${BBMOD_OBJ}    name
        ${CELLS_OF_BBMOD}=                     Get Cells Of Bbmod  ${bbmod_name}
        ${CELLS_OF_SOC}=                       Get Cells Of Soc    ${bbmod_name}    K2A

        Run Keyword And Continue On Failure    Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=476
        ...                                    fault_name=Baseband card autonomous reset as recovery action
        ...                                    unit_path=${bbmod_unit_path}
        ...                                    hw_path=${bbmod_hw_path}
        Run Keyword And Continue On Failure    Add Expected Alarm To Allowed

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Send 476 Fault ${bbmod}  K2A
        Run Keyword and Continue On Failure    Send Lom Fault  fsp_unit=${bbmod}  k2_unit=K2A
        Print Text To Eventlog  Wait for autonomous reset to occur and that mapped cells of tested BBMOD/K2A are disabled
        Run Keyword And Continue On Failure    Wait For Cells Faulty    300    ${CELLS_OF_BBMOD}
        Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
        Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Check alarm history
        Run Keyword And Continue On Failure    Check Alarm History

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Execute BBMOD power reset
        Run Keyword And Continue On Failure    ADMIN.Reset Unit  dist_name=${BBMOD_OBJ.scf_dist_name}
        ...                                    reset_type=${RESET_TYPE}  timeout=300  detailed_output=True

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Wait For All Cells Up
        Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Check alarm history
        ${alarm_status}=                       Run Keyword And Return Status    Check Alarm History

        Run Keyword If                         '${alarm_status}' == '${True}'  Get Snapshot And Delete It
        Run Keyword And Continue On Failure    Remove Expected Alarms
    END
# Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
	Print Step Text                            ${STEP}  Site reset cleaner
	Run Keyword And Continue On Failure        Site reset cleaner  ${WAIT_FOR_CELLS_UP}  ${WAIT_AFTER_SITE_RESET}
	...                                                            ${STEP}
    Run Keyword And Continue On Failure        Stop Background Syslog Print Search
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}.4  Check Postconditions
    Run Keyword And Continue On Failure        Common Postconditions

ABIA 476 Secondary SOC
    [Documentation]  This KW causes 476 fault to K2x of ABIAs and expects autonomous reset or alarm active.
    ...              UNIT can be only ABIA and SOC for K2B
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}  ${SOC}  ${WAIT_AFTER_SITE_RESET}

    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Run Keyword And Continue On Failure        Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                            ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure        Common Preconditions

    ${BBMOD_LIST}=    Get All Bbmods
#   476 fault to Secondary SOC (K2B,K2C or K2D) of all BBMODs in configuration
    FOR    ${bbmod}    IN    @{BBMOD_LIST}
        ${BBMOD_OBJ}=                          Get Bbmod Object From User Given Values    ${bbmod}
        ${bbmod_unit_path}=                    Get Values From Object    ${BBMOD_OBJ}    unit_path
        ${bbmod_hw_path}=                      Get Values From Object    ${BBMOD_OBJ}    hw_path
        ${bbmod_name}=                         Get Values From Object    ${BBMOD_OBJ}    name
        ${CELLS_OF_BBMOD}=                     Get Cells Of Bbmod  ${bbmod_name}
        ${CELLS_OF_SOC}=                       Get Cells Of Soc    ${bbmod_name}    ${SOC}

        Run Keyword And Continue On Failure     ALARMS.Add Allowed Alarm  fault_id=4714
                             ...                unit_path=${bbmod_unit_path}
                             ...                hw_path=${bbmod_hw_path}
        Run Keyword And Continue On Failure     ALARMS.Add Expected Alarm  fault_id=476
                             ...                unit_path=${bbmod_unit_path}
                             ...                hw_path=${bbmod_hw_path}
        Run Keyword And Continue On Failure    Add Expected Alarm To Allowed

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Send 476 Fault ${bbmod}  ${SOC}
        Run Keyword and Continue On Failure    Send Lom Fault  fsp_unit=${bbmod}  k2_unit=${SOC}

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Check expected alarms
        Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Wait for cells up
        Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Check alarm history
        Run Keyword And Continue On Failure    Check Alarm History

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Execute BBMOD power reset
        Run Keyword And Continue On Failure    ADMIN.Reset Unit  dist_name=${BBMOD_OBJ.scf_dist_name}
        ...                                    reset_type=${RESET_TYPE}  timeout=300  detailed_output=True

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Wait For All Cells Up
        Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Check alarm history
        ${alarm_status}=                       Run Keyword And Return Status    Check Alarm History

        Run Keyword If                         '${alarm_status}' == '${True}'  Get Snapshot And Delete It
        Run Keyword And Continue On Failure    Remove Expected Alarms
    END
#   Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
	Print Step Text                            ${STEP}  Site reset cleaner
	Run Keyword And Continue On Failure        Site reset cleaner  ${WAIT_FOR_CELLS_UP}  ${WAIT_AFTER_SITE_RESET}
	...                                                            ${STEP}
    Run Keyword And Continue On Failure        Stop Background Syslog Print Search
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}.4  Check Postconditions
    Run Keyword And Continue On Failure        Common Postconditions
