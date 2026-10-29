*** Settings ***
Documentation  Test for CB008064
Library     ../resources/extractor.py
Library     SSHLibrary
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     taf.transport.ssh  WITH NAME  ssh
Library     DateTime
Library     OperatingSystem
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
#Resource    ../resources/bts_states.robot
#Resource    ../resources/verdicts.robot
#Resource    ../resources/unpacking.robot
#Resource    ../resources/diagnostic_check.robot
#Resource    ../resources/suppress.robot
#Resource    ../resources/ecc_errors.robot

*** Variables ***
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu
${json_tce}    testsuite/Timisoara/SBTS/test_line_specific/SBTS_10822_Jaguar/commissioning/add_2xTCE.json
${TCE_restore}    testsuite/Timisoara/SBTS/test_line_specific/SBTS_10822_Jaguar/commissioning/restore_TCE.json
${ALARM_ID_TO_CHECK}    7115

*** Keywords ***
TC__LOGS__CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed
    [Documentation]
    ...  ******************
    ...  Author: Cristinel Sava
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2024-03-13 - TC created, version 1.0
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  In this case, BTS SMOD ASIL checks Alarms 7115 when TCE connect is failed
    ...  *******************

    Set Tags    CA-LOGS    OWNER-cristinel.sava@nokia.com    AUTHOR-cristinel.sava@nokia.com
    ...    MAINTAINER-cristinel.sava@nokia.com    GROUP_IN_CHARGE-TSR1_7_Vrf
    ...    PHASE-CRT    SW-SBTS25R2    FEATURE-CB008064

      Step 0: Preconditions
      Step 1: Check Alarm 7115 and clear it


Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    Step 0: Preconditions    console=${True}

    Check Unexpected Alarms  skip_fault=61524,61649,4654,4655,61652
    Log to console   Start DCAP server
    Run  utf_lab-controller start
    Log to console   Perform Delta Recommissioning add TCE param
    Wait Until Keyword Succeeds  2m  30s    coam.Perform Delta Recommissioning   delta_file=${json_tce}
    ...    skip_parameter_relation_errors=${True}    timeout=120
    Log to console   Stop DCAP server
    Run  utf_lab-controller stop

Step 1: Check Alarm 7115 and clear it
    Check Alarm 7115 and clear it

TC Setup
    Common Test Setup


Check Alarm 7115 and clear it
    [Documentation]    Verify that alarm 7115 appears and optionally start clearing process.

    # take alarm status
    ${fault_status}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    30    10
    ...    coam.Assert Alarm Active    parameters=alarmId=7115, faultId=8000    timeout=30

    # if alarm not rise, FAIL
    IF    not ${fault_status}
        Fail    Alarm 7115 did NOT appear within timeout
    END

    # take active alarm list
    ${active_alarms}=    coam.Get Active Alarms    timeout=60
    ${count_7115}=       Set Variable    0

    # Count nr of alarmId 7115
    FOR    ${fault}    IN    @{active_alarms}
        ${alarm_id}=    Get From Dictionary    ${fault}    alarmId
        IF    ${alarm_id} == 7115
            ${count_7115}=    Evaluate    ${count_7115} + 1
        END
    END

    # Log la consola
    Log To Console    Total alarms with alarmId 7115: ${count_7115}

    #  Fail if exist count different of 2
    IF    ${count_7115} != 2
        Fail    Nr of active alarms with alarmId 7115 found is ${count_7115} != 2
    END

    [Return]    ${count_7115}


    Log   start dcap to clear 7115   console=${True}
    Wait Until Keyword Succeeds   60   10
    ...   Run   utf_lab-controller start

    Log   \nCheck If Alarm 7115 is cleared.   console=${True}


Custom TC Teardown
    [Documentation]
    ...    Send proper value TCE_restore
    ...    Check if Alam 7115 is canceled from WebEm
    Log to console   Custom TC Teardown
    Wait Until Keyword Succeeds  2m  30s    coam.Perform Delta Recommissioning   delta_file=${TCE_restore}
    ...    skip_parameter_relation_errors=${True}    timeout=120
    Run  utf_lab-controller stop
    sleep    20s

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Custom TC Teardown
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
