*** Settings ***
Documentation  Test for CB10239
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     DateTime
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pdu.robot
Resource    ../resources/diagnostic_check_new.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Keywords ***
TC__LOGS__CB010239-C_CP31_active_critical_alarms

    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26129
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case verifies CP31: active critical alarms.
    ...  It should be returned for checkpoint 31 in diagnostic report if at least one of critical alarm is active on BTS.
    ...  Additionally, fault 4681 (EFaultId_SanityCheckErrAl) should be raised.
    ...  Scenario checks also if fault 4681 will be cleared when CP31 returns OK result.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 15.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26129 - Initial creation
    ...  - 15.11.2033 - Changed severity of fid 4681 to Warning due to OM_GEN_SFS_SYSM.9049 change
    ...  - 20.03.2024 - change coam.Run Diagnostic Check timeout in accordance to updated req OM_GEN_SFS_PERF_CAP.10677


    Set Tags    CA-LOGS    OWNER-joanna.wolnicka@nokia.com    AUTHOR-jakub.kokoszka@nokia.com
    ...    MAINTAINER-jakub.kokoszka@nokia.com    PHASE-CRT    SW-SBTS24R1    FEATURE-CB010239-C


    Step 0: Preconditions
    Step 1: Turn off RMOD to generate FID:10
    Step 2: Disable all check points except of CP31
    Step 3: Trigger Diagnostic Check with no service impact
    Step 4: Verify if FID: 4681 has been raised with warning severity.
    Step 5: Verify if Diagnostic Check report contains NOK status for CP31.
    Step 6: Revert the trigger for critical alarm on BTS.
    Step 7: Re-execute Diagnostic Check with no service impact.
    Step 8: Verify if FID: 4681 has been cleared.
    Step 9: Verify if Diagnostic Check report contains OK status for CP31.


Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    Step 0: Preconditions    console=${True}
    ${bts_id}   bts_states.Get BTS ID
    Set Test Variable    ${TRBL_MNLENT_DISTNAME}   MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    Set Test Variable    ${RMOD_OFF}  ${False}
    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${False}
    ${is_it_dualcore}    Run Keyword And Return Status  Variable Should Exist  ${SMOD2}
    Run Keyword If    ${is_it_dualcore}==${False}
    ...    Set Test Variable   ${PRIMARY_SMOD_DISTNAME}   SMOD_R-1
    ...    ELSE  Set Primary SMOD Distname For Dual Core

Step 1: Turn off RMOD to generate FID:10
    [Documentation]
    ...   In this step firs RMOD on list rmod_serial_number_list will turn off to generate FID:10

    Log    \nStep 1: Turn off RMOD to generate FID:10    console=${True}

    ${rmod_param}    coam.Get Parameters For All    RMOD
    @{rmod_serial_number_list}=    Create List

    FOR  ${mod}  IN  @{rmod_param}
        Append To List  ${rmod_serial_number_list}  RMOD_${mod.serialNumber}
    END
    Set Test Variable    ${rmod_serial_number_list}
    pdu.Pdu BTS Interface Off    ${rmod_serial_number_list}[0]
    Log    \n${rmod_serial_number_list}[0]: power turn OFF    console=${True}
    Set Test Variable  ${RMOD_OFF}  ${True}

    ${fault_status}  Run Keyword And Return Status  Wait until keyword succeeds  360  10
    ...  coam.Assert Alarm Active  parameters=alarmId=7116, faultId=10, faultName="No connection to unit", severity=Critical    timeout=120
    Run keyword if  ${fault_status}
    ...  Log  Fault 10 "No connection to unit" - severity=Critical - appeared  console=${True}
    ...  ELSE  Set Test Failed  Fault 10 "No connection to unit - did not not appear    ${True}

Step 2: Disable all check points except of CP31
    [Documentation]
    ...   All diagnostic checkpoints except point 31 are disabled for diagnostic check.

    Log    \nStep 2: disable all check points except of CP31    console=${True}

    diagnostic_check_new.Disable Diagnostic Checkpoints Except    31
    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${True}

Step 3: Trigger Diagnostic Check with no service impact
    [Documentation]
    ...   In this step Diagnostic Check will run with allow_service_impact=False

    Log    \nStep 3: Trigger Diagnostic Check with no service impact    console=${True}

    ${DC1_result}    coam.Run Diagnostic Check    allow_service_impact=${False}    timeout=930

Step 4: Verify if FID: 4681 has been raised with warning severity.
    [Documentation]
    ...   In this step test check if FaultID 4681 severity = WARNING appeared

    Log    \nStep 4: Verify if FID: 4681 has been raised with warning severity.    console=${True}

    diagnostic_check_new.Check Alarm 4681   Active   Warning

Step 5: Verify if Diagnostic Check report contains NOK status for CP31.
    [Documentation]
    ...   In this step test check if Diagnostic Check report contains NOK status for CP31.

    Log    \nStep 5: Verify if Diagnostic Check report contains NOK status for CP31.    console=${True}

    Get DC Report And Check CP Result   31   Check point failure    ${connection}

Step 6: Revert the trigger for critical alarm on BTS.
    [Documentation]
    ...   In this step RMOD will turn on

    Log    \nStep 6: Revert the trigger for critical alarm on BTS.    console=${True}

    pdu.Pdu BTS Interface On    ${rmod_serial_number_list}[0]
    Log  \npower on ${rmod_serial_number_list}[0] was turned ON    console=${True}
    Set Test Variable  ${RMOD_OFF}  ${False}
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States

Step 7: Re-execute Diagnostic Check with no service impact.
    [Documentation]
    ...   In this step diagnostic Check will re-execute with no service impact.

    Log    \nStep 7: Re-execute Diagnostic Check with no service impact.    console=${True}

    ${DC2_result} =    coam.Run Diagnostic Check  allow_service_impact=${False}  timeout=930

Step 8: Verify if FID: 4681 has been cleared.
    [Documentation]
    ...   In this step test check if FID: 4681 has been cleared.

    Log    \nStep 8: Verify if FID: 4681 has been cleared.    console=${True}

    diagnostic_check_new.Check Alarm 4681   Inactive   Warning

Step 9: Verify if Diagnostic Check report contains OK status for CP31.
    [Documentation]
    ...   In this step test check if Diagnostic Check report contains OK status for CP31.

    Log    \nStep 9: Verify if Diagnostic Check report contains OK status for CP31.    console=${True}

    ${second_connection}   coam.Connect To   name=dc_second_connection
    Get DC Report And Check CP Result   31   Check point successful    ${second_connection}
    coam.teardown   connection=${second_connection}


Get DC Report And Check CP Result
    [Documentation]
    ...   This keyword verifies if checkpoint has expected status in latest diagnostic check report.
    [Arguments]   ${checkpoint}   ${expected_status}   ${connection}

    Log   \nVerifying if CP '${checkpoint}' has expected status '${expected_status}' in DC Report.   console=${True}
    ${diagnostic_report}   coam.Get Diagnostic Report   connection=${connection}
    ${found_checkpoint}   diagnostic_check_new.Get Checkpoint Result For SMOD  ${PRIMARY_SMOD_DISTNAME}   ${diagnostic_report}   ${checkpoint}
    diagnostic_check_new.Verify CP Status   ${found_checkpoint}   ${expected_status}


Revert Delta Changes
    [Documentation]
    ...   This keyword prepares and recommissions delta that removes excluded diagnostic checkpoints.

    Log   \nRemoving excluded diagnostic checkpoints from configuration   console=${True}
    ${delta_id}   Set Variable   remove_delta_changes
    coam.Create Delta   ${delta_id}
    coam.Append Parameter Delete To Delta   ${TRBL_MNLENT_DISTNAME}   excludedDiagnosticCheckPoints   ${delta_id}
    coam.Get Delta   ${delta_id}
    coam.Save Delta   ${BTS Files}/remove_delta_changes.json   ${delta_id}
    coam.Perform Delta Recommissioning   ${BTS Files}/remove_delta_changes.json   skip_parameter_relation_errors=${True}

Set Primary SMOD Distname For Dual Core
    ${primary_smod_obj}   Query Infomodel   get object //SMOD_R-* is [activeRole="Primary"]    timeout=60
    ${primary_smod_distname}   Fetch From Right   ${primary_smod_obj.dist_name}   /
    Set Test Variable   ${PRIMARY_SMOD_DISTNAME}   ${primary_smod_distname}

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}

    Run Keyword If  ${RMOD_OFF}  Run Keywords
    ...    pdu.Pdu BTS Interface On    ${rmod_serial_number_list}[0]
    ...    AND    Log  power on ${rmod_serial_number_list}[0] was turned ON  console=${True}
    ...    AND    Set Test Variable  ${RMOD_OFF}  ${False}
    ...    AND    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States

    Run Keyword If  ${REVERT_DELTA_CHANGES}  Run Keywords
    ...    Revert Delta Changes
    ...    AND    Set Test Variable    ${REVERT_DELTA_CHANGES}  ${False}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Custom Test Teardown
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
