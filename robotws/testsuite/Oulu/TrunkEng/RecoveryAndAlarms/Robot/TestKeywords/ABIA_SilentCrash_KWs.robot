*** Settings ***
Documentation
...  Author:   Mirka Kyllönen
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingBBMOD
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/Resources/unit_state_check_kws.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/Resources/ssh_commands_kws.robot
*** Variables ***
${RESET_TYPE}        Warm

*** Keywords ***
ABIA Silent Crash Primary SOC
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}  ${WAIT_AFTER_SITE_RESET}

    ${STEP}=                                     Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Run Keyword And Continue On Failure          Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                              ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure          Common Preconditions

    Repeat Keyword         3 times               Run Keyword And Continue On Failure
    ...                                          ABIA Silent Crash Primary SOC Steps Loop  ${WAIT_FOR_CELLS_UP}
    ...                                          ${WAIT_FOR_ALARM}  ${STEP}

    ${BBMOD_LIST}=    Get All Bbmods
    @{FAULTY_CELLS}=  Create List
    ${first_index}=   Set Variable  ${BBMOD_LIST}[0]
    FOR    ${bbmod}    IN    @{BBMOD_LIST}
          ${BBMOD_OBJ}=                          Get Bbmod Object From User Given Values    ${bbmod}
          ${CELLS_OF_BBMOD}=                     Get Cells Of Bbmod  ${BBMOD_OBJ.name}
          ${radios_of_bbmod}=                    Get RMODs Connected to BBMOD  ${BBMOD_OBJ.name}
          ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
          Print Step Text                        ${STEP}  Adding ${CELLS_OF_BBMOD} to faulty cells list ${FAULTY_CELLS}
          ${UPDATED_FAULTY_CELLS}=                       Add List To List  ${FAULTY_CELLS}  ${CELLS_OF_BBMOD}
#         Send Silent Crash 3 times to the same ABIA
          ${is_first_bbmod}=                     Run Keyword And Return Status  Should Be Equal  ${bbmod}  ${first_index}
          Repeat Keyword         3 times         Run Keyword And Continue On Failure
          ...                                    Silent Crash Steps  ${STEP}  ${bbmod}  ${BBMOD_OBJ}
          ...                                                ${WAIT_FOR_ALARM}  ${WAIT_FOR_CELLS_UP}  K2A  ${UPDATED_FAULTY_CELLS}
          ...                                                ${is_first_bbmod}

          ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
          Print Step Text                        ${STEP}  Silent crash for ${bbmod}  K2A
          Run Keyword and Continue On Failure    Generate DSP Crash To ABIA           ${BBMOD_OBJ}  K2A
#          Run Keyword And Continue On Failure    Add 10 Fault As Expected To Radios  ${radios_of_bbmod}
          Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
          Run Keyword And Continue On Failure    Wait For Cells Faulty    300    ${UPDATED_FAULTY_CELLS}
          Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
#          Run Keyword And Continue On Failure    Get Snapshot And Delete It
          Run Keyword And Continue On Failure    Remove Expected Alarms
    END

    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}  Add 10 Fault to all radios
    ${RMODS_LIST}=                             Get All Radios
    Run Keyword And Continue On Failure        Add 10 Fault As Expected To Radios  ${RMODS_LIST}
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}  Add DSP platform fatal error alarm to all BBMODs
    Run Keyword And Continue On Failure        Add Expected Alarms To All BBMODs  ${BBMOD_LIST}
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}  Check all BBMOD states
    ${BBMOD_STATES}=                           Run Keyword And Continue On Failure  Create BBMOD Wanted States Dict
    ...                                                                             ${BBMOD_LIST}
    Run Keyword And Continue On Failure        Check Bbmod States    expected_states=${BBMOD_STATES}
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}  Check if BTS Status is integrated to ran
    &{integrated_to_ran}=                      Create Dictionary  proceduralState=IntegratedToRan
    Run Keyword And Continue On Failure        Check Bts State  ${integrated_to_ran}

  # Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}  Site reset cleaner
    Run Keyword And Continue On Failure        Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_AFTER_SITE_RESET}
    ...                                                              ${STEP}

    Run Keyword And Continue On Failure        Stop Background Syslog Print Search
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}.4  Check Postconditions
    Run Keyword And Continue On Failure        Common Postconditions


ABIA Silent Crash Primary SOC Steps Loop
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${STEP}

    ${BBMOD_LIST}=    Get All Bbmods
    ${last_index}=    Set Variable  ${BBMOD_LIST}[-1]
    ${first_index}=   Set Variable  ${BBMOD_LIST}[0]
    @{FAULTY_CELLS}=  Create List
#   Silent crash to K2A in loop of all BBMODs one by one in configuration
    FOR    ${bbmod}    IN    @{BBMOD_LIST}
        ${BBMOD_OBJ}=                          Get Bbmod Object From User Given Values    ${bbmod}
        ${CELLS_OF_BBMOD}=                     Get Cells Of Bbmod  ${BBMOD_OBJ.name}
        ${radios_of_bbmod}=                    Get RMODs Connected to BBMOD  ${BBMOD_OBJ.name}
        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Adding ${CELLS_OF_BBMOD} to faulty cells list ${FAULTY_CELLS}
        ${UPDATED_FAULTY_CELLS}=                       Add List To List     ${FAULTY_CELLS}  ${CELLS_OF_BBMOD}
#       Send Silent Crash 3 times to the same ABIA
        ${is_first_bbmod}=                     Run Keyword And Return Status  Should Be Equal  ${bbmod}  ${first_index}
        Repeat Keyword         3 times         Run Keyword And Continue On Failure
        ...                                    Silent Crash Steps  ${STEP}  ${bbmod}  ${BBMOD_OBJ}
        ...                                                ${WAIT_FOR_ALARM}  ${WAIT_FOR_CELLS_UP}  K2A  ${UPDATED_FAULTY_CELLS}
        ...                                                ${is_first_bbmod}

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Silent crash for ${bbmod}  K2A
        Run Keyword and Continue On Failure    Generate DSP Crash To ABIA           ${BBMOD_OBJ}  K2A
        ${is_last_bbmod}=                     Run Keyword And Return Status  Should Be Equal  ${bbmod}  ${last_index}
        Run Keyword If  ${is_last_bbmod}                Run Keywords  Add Expected Alarm
        ...                                             severity=Warning  alarm_id=7101  fault_id=6706
        ...                                             fault_name=BTS site autonomous reset as recovery action
        ...                                             unit_path=${BBMOD_OBJ.unit_path}
        ...                                             hw_path=${BBMOD_OBJ.hw_path}
        ...  AND  Run Keyword And Continue On Failure   Add Expected Alarm To Allowed
        ...  AND  Run Keyword And Continue On Failure   Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
        ...  ELSE                                       Run Keywords  Add Expected Alarm  severity=Critical
        ...                                             alarm_id=7116  fault_id=6706
        ...                                             fault_name=DSP platform fatal error
        ...                                             unit_path=${BBMOD_OBJ.unit_path}
        ...                                             hw_path=${BBMOD_OBJ.hw_path}
#        ...  AND  Run Keyword And Continue On Failure   Add 10 Fault As Expected To Radios  ${radios_of_bbmod}
        ...  AND  Run Keyword And Continue On Failure   Add Expected Alarm To Allowed
        ...  AND  Run Keyword And Continue On Failure   Wait For Cells Faulty    300    ${UPDATED_FAULTY_CELLS}
        Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
#        Run Keyword And Continue On Failure    Get Snapshot And Delete It
        Run Keyword And Continue On Failure    Remove Expected Alarms
    END

ABIA Silent Crash Secondary SOC
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${WAIT_AFTER_SITE_RESET}  ${SOC}

    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Run Keyword And Continue On Failure        Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                            ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure        Common Preconditions

    ${BBMOD_LIST}=    Get All Bbmods
#   Silent crash to Secondary SOC in loop of all BBMODs one by one in configuration
    FOR    ${bbmod}    IN    @{BBMOD_LIST}
        ${BBMOD_OBJ}=                          Get Bbmod Object From User Given Values    ${bbmod}
    #    ${bbmod_unit_path}=                    Get Values From Object    ${BBMOD_OBJ}    unit_path
    #    ${bbmod_hw_path}=                      Get Values From Object    ${BBMOD_OBJ}    hw_path
    #    ${bbmod_name}=                         Get Values From Object    ${BBMOD_OBJ}    name
    #    ${CELLS_OF_BBMOD}=                     Get Cells Of Bbmod  ${bbmod_name}
    #    ${CELLS_OF_SOC}=                       Get Cells Of Soc    ${bbmod_name}    ${SOC}
    #    ${radios_of_bbmod}=                    Get RMODs Connected to BBMOD  ${bbmod_name}

        Run Keyword And Continue On Failure     ALARMS.Add Allowed Alarm  severity=Minor  alarm_id=7115  fault_id=6706
                             ...                fault_name=DSP platform fatal error
                             ...                unit_path=${BBMOD_OBJ.unit_path}
                             ...                hw_path=${BBMOD_OBJ.hw_path}
        Run Keyword And Continue On Failure     ALARMS.Add Allowed Alarm  severity=Warning  alarm_id=7101  fault_id=6706
                             ...                fault_name=Baseband card autonomous reset as recovery action
                             ...                unit_path=${BBMOD_OBJ.unit_path}
                             ...                hw_path=${BBMOD_OBJ.hw_path}
        Run Keyword And Continue On Failure     ALARMS.Add Allowed Alarm  severity=Critical  alarm_id=7116  fault_id=6706
                             ...                fault_name=DSP platform fatal error
                             ...                unit_path=${BBMOD_OBJ.unit_path}
                             ...                hw_path=${BBMOD_OBJ.hw_path}
        Run Keyword And Continue On Failure     ALARMS.Add Allowed Alarm  severity=Minor  alarm_id=7115  fault_id=4714
                             ...                fault_name=FSP Reset Needed
                             ...                unit_path=${BBMOD_OBJ.unit_path}
                             ...                hw_path=${BBMOD_OBJ.hw_path}
        Run Keyword And Continue On Failure     ALARMS.Add Allowed Alarm  severity=Minor  alarm_id=7115  fault_id=6706
                             ...                fault_name=DSP platform fatal error
                             ...                unit_path=${BBMOD_OBJ.unit_path}
                             ...                hw_path=${BBMOD_OBJ.hw_path}
        Run Keyword And Continue On Failure    Add Expected Alarm To Allowed

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Silent crash for ${bbmod}  ${SOC}
        Run Keyword and Continue On Failure    Generate DSP Crash To ABIA           ${BBMOD_OBJ}  ${SOC}

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Wait for cells up
        Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}

        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Execute BBMOD power reset
        Run Keyword And Continue On Failure    ADMIN.Reset Unit  dist_name=${BBMOD_OBJ.scf_dist_name}
        ...                                    reset_type=${RESET_TYPE}  timeout=300  detailed_output=True
        ${STEP}=                               Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                        ${STEP}  Wait For All Cells Up
        Run Keyword And Continue On Failure    Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
        Run Keyword And Continue On Failure    Get Snapshot And Delete It
        Run Keyword And Continue On Failure    Remove Expected Alarms
    END

#   Executing site reset cleaner is done after successful test run so it is able to loop this test multiple times
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}  Site reset cleaner
    Run Keyword And Continue On Failure        Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_AFTER_SITE_RESET}
    ...                                                              ${STEP}
    Run Keyword And Continue On Failure        Stop Background Syslog Print Search
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}.4  Check Postconditions
    Run Keyword And Continue On Failure        Common Postconditions

Silent Crash Steps
    [Arguments]  ${STEP}  ${bbmod}  ${BBMOD_OBJ}  ${WAIT_FOR_ALARM}  ${WAIT_FOR_CELLS_UP}  ${SOC}
    ...          ${FAULTY_CELLS}  ${is_first_bbmod}

    Run Keyword And Continue On Failure        Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=6706
    ...                                        fault_name=Baseband card autonomous reset as recovery action
    ...                                        unit_path=${BBMOD_OBJ.unit_path}
    ...                                        hw_path=${BBMOD_OBJ.hw_path}
    Run Keyword And Continue On Failure        Add Expected Alarm To Allowed
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}  Silent crash for ${bbmod}  ${SOC}
    Run Keyword and Continue On Failure        Generate DSP Crash To ABIA  ${BBMOD_OBJ}  ${SOC}
#    Print Text To Eventlog  Wait for autonomous reset to occur and that mapped cells of tested BBMOD/${SOC} are disabled
#    Run Keyword And Continue On Failure        Wait For Cells Faulty    time_limit=${WAIT_FOR_CELLS_UP}    cells_to_be_faulty=${FAULTY_CELLS}
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}  Check expected alarms and reset them
    Run Keyword And Continue On Failure        Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
    Run Keyword And Continue On Failure        Check If Fault Active And Wait For It To Clear  fault_id=6706
    ...                                        wait_max_clear=300  unit_path=${BBMOD_OBJ.unit_path}
    Run Keyword And Continue On Failure        Reset Alarms
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}  Check cells
    Print Text To Eventlog                     is_first_bbmod is ${is_first_bbmod}
    Run Keyword If  ${is_first_bbmod}          Run Keyword And Continue On Failure  Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
    ...  ELSE                                  Run Keyword And Continue On Failure  Wait For Cells Faulty   time_limit=${WAIT_FOR_CELLS_UP}
    ...                                        cells_to_be_faulty=${FAULTY_CELLS}

Add Expected Alarms To All BBMODs
    [Arguments]    ${BBMOD_LIST}

    FOR  ${bbmod}  IN  @{BBMOD_LIST}
        ${BBMOD_OBJ}=                          Get Bbmod Object From User Given Values    ${bbmod}
        Run Keyword And Continue On Failure     ALARMS.Add Allowed Alarm  severity=Critical  alarm_id=7116  fault_id=6706
                             ...                fault_name=DSP platform fatal error
                             ...                unit_path=${BBMOD_OBJ.unit_path}
                             ...                hw_path=${BBMOD_OBJ.hw_path}
        Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
    END

Create BBMOD Wanted States Dict
    [Arguments]    ${BBMOD_LIST}
    &{state_dict_disabled}=  Create Dictionary  availabilityStatus=failed  operationalState=disabled
    &{BBMOD_STATES}=    Create Dictionary
    FOR    ${bbmod}    IN    @{BBMOD_LIST}
        ${BBMOD_OBJ}=  Get Bbmod Object From User Given Values    ${bbmod}
        Set To Dictionary  ${BBMOD_STATES}  ${BBMOD_OBJ.name}=${state_dict_disabled}
    END
    [Return]    ${BBMOD_STATES}

Simple SilentCrash Primary SoC
    [Arguments]   ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${SYSLOG_LIST}  ${WAIT_AFTER_SITE_RESET}

    ${STEP}=                                     Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Run Keyword And Continue On Failure          Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                              ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure          Common Preconditions

    ${BBMOD_LIST}=    Get All Bbmods
    FOR    ${bbmod}    IN    @{BBMOD_LIST}
        ${BBMOD_OBJ}=                              Get Bbmod Object From User Given Values    ${bbmod}
        ${CELLS_OF_BBMOD}=                         Get Cells Of Bbmod  ${BBMOD_OBJ.name}
        ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                            ${STEP}  Add Expected alarm
        Run Keyword And Continue On Failure        Add Expected Alarm  severity=Warning  alarm_id=7101  fault_id=6706
        ...                                        fault_name=Baseband card autonomous reset as recovery action
        ...                                        unit_path=${BBMOD_OBJ.unit_path}
        ...                                        hw_path=${BBMOD_OBJ.hw_path}
        Run Keyword And Continue On Failure        Add Expected Alarm To Allowed
        ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                            ${STEP}  Silent crash for ${bbmod}  K2A
        Run Keyword and Continue On Failure        Generate DSP Crash To ABIA  ${BBMOD_OBJ}  K2A
        Print Text To Eventlog  Wait for autonomous reset to occur and that mapped cells of tested BBMOD/K2A are disabled
        Run Keyword And Continue On Failure        Wait For Cells Faulty    time_limit=${WAIT_FOR_CELLS_UP}
        ...                                        cells_to_be_faulty=${CELLS_OF_BBMOD}
        ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
        Print Step Text                            ${STEP}  Check Expected Alarms
        Run Keyword And Continue On Failure        Check Expected Alarms  wait_active_timeout=${WAIT_FOR_ALARM}
        Print Step Text                            ${STEP}  Wait for cells up
        Run Keyword And Continue On Failure        Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
        Run Keyword And Continue On Failure        Remove Expected Alarms
    END

    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}  Site reset cleaner
    Run Keyword And Continue On Failure        Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_AFTER_SITE_RESET}
    ...                                                              ${STEP}

    Run Keyword And Continue On Failure        Stop Background Syslog Print Search
    ${STEP}=                                   Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                            ${STEP}.4  Check Postconditions
    Run Keyword And Continue On Failure        Common Postconditions
