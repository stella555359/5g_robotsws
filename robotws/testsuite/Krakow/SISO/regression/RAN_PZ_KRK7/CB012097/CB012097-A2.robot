*** Settings ***
Documentation
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)
...   maintainers:
...    - Jakub Kowalczyk
...   contact:
...    - Jakub Kowalczyk
...   CB012097 Early notification of radio fan failures for additional radios - contains two main parts,
...    both related to improvement in radio fan failures.
...   1. CB012097 extends fuctionalities introduced by CB009275 Early notification of radio fan failures,
...    to new radio families and platforms and add it to Cloud.
...   2. CB012097 extends fuctionalities introduced by CNI-62837 Support for optional FAN on RUs,
...    to new radio families and platforms and add it to Cloud.
...    Item A6/A5. Faults 1932, 1933, 1934 will be supported 5.1 radios
...    CB012097-SR-A2-RF5.1
...    CB012097-SR-B3-RF5.1

Library      Collections
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      resources/common.py
Library      SSHLibrary
Variables    resources/variables_a2.py
Resource     resources/kw_a2.robot
Resource     resources/kw_common.robot

Suite Setup       Custom Suite Setup A2
Suite Teardown    Common Suite Teardown

*** Variables ***

${5G_SOURCE_SW}        ${None}
${5G_TARGET_SW}        ${None}

@{CUSTOM_ALLOWED_ALARMS}=       61648    7115    4420    4123    4125    8150    4459    8000    6327
@{CRITICAL_FAULTS}              10  1806  16  4341  4383  4352  1868  69
${REMOTE_VM_IP}=                ${tl.test_pcs[0].default_ssh_connection_details.addr}
${REMOTE_MPLANE}=               ${tl.gnbs[0].oam_ip.v4.split('/')[0]}
@{ADDITIONAL_ALARMS_DURING_PREP}    WiFi Configuration Issue    Setup of X2 connectivity to gNB failed


@{CUSTOM_ALARMS}=       ${CUSTOM_ALLOWED_ALARMS}
${BTS_HOST_IP}          192.168.255.129


${SMOD_ADDR}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${SMOD_USER}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${SMOD_PASS}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${SMOD_SSH}=     ${tl.gnbs[0].cu.oam_ssh_connection_details}
${RMOD_LIST}=    ${tl.gnbs[0].dus[0].airscale.core_units[0].rus}
${MRBTS_ID}=     ${tl.gnbs[0].global_bts_id}

&{FAULT}=        1932=No module fan detected    1933=Cooling fan broken    1934=Cooling fan has reduced from the set speed
...              10=No connection to unit    4589=Unit power reset    4681=Diagnostic Check Error
&{RMOD_RUNTIME}=   AREA=${None}
&{FAN_RUNTIME}=    AREA=${None}

# Expected faulty objects needed to present fault verification:
@{FAULTY_1932_RMODS}=    @{EMPTY}
@{FAULTY_1932_FANS}=     @{EMPTY}
@{FAULTY_1933_RMODS}=    @{EMPTY}
@{FAULTY_1933_FANS}=     @{EMPTY}
@{FAULTY_1934_RMODS}=    @{EMPTY}
@{FAULTY_1934_FANS}=     @{EMPTY}

${tc13_iterations}=  3
                    #
${AREA_sn}=             ${None}    # Enter manually to bypass value from __init__
*** Test Cases ***
CB012097_02_Feature_Enable_with_Fault_1932_activated
    [Tags]    02    CRT    A2
    [Setup]    Run Keywords
    ...    Set RMOD Variables for Test Case    rmod_type=AREA    rmod_id=0    rmod_list=${RMOD_LIST}    AND
    ...    Prepare SSH connection to Container, AREA    AND
    ...    Prepare RMOD AREA environment
    ...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Transmission path failure
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}


    # -------------------------- Part with FAF disabled

    Log To Console    \n******** Step 00.
    Change FAF actRadioFanFailureEarlyNotif to false
    Set TCS parameter Nrpm_fail to value=${5} on AREA, skip reboot.

    Log To Console    \n******** Step 01. Fault 1932:
    kw_common.Allow Alarms    1932
    Trigger Fault 1932 on AREA from all 2 fans.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1932    awaiting_time=${120}
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

    # -------------------------- Part with FAF enabled
    Log To Console    \n******** Step 02.
    Change FAF actRadioFanFailureEarlyNotif to true

    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1932    awaiting_time=${120}
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected



    [Teardown]    Run Keywords
    ...    TC 02 Teardown    AND
    ...    SSHRMOD_A.Close Connection    AND
    ...    Run Keyword If Test Failed    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown
    ...    AND    Test Teardown with Watching Alarms


CB012097_04_Feature_Enable_with_Fault_1934_activated
    [Tags]    04    CRT    A2
    [Setup]    Run Keywords
    ...    Set RMOD Variables for Test Case    rmod_type=AREA    rmod_id=0    rmod_list=${RMOD_LIST}    AND
    ...    Prepare SSH connection to Container, AREA    AND
    ...    Prepare RMOD AREA environment
    ...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Transmission path failure
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}


    # -------------------------- Part with FAF disabled

    Log To Console    \n******** Step 00, prepare TCS, FAF actRadioFanFailureEarlyNotif false.
    kw_common.Allow Alarms    1934    # Filter out temporary 1934 after TCS change
    Set TCS to prepare 1934 triggering by change parameters ${tcs_prepare_1934_AREA} on AREA.
    BuiltIn.Sleep    10
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${40}
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${120}
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    BuiltIn.Sleep    10
    kw_common.Disallow Alarms    1934
    Change FAF actRadioFanFailureEarlyNotif to false

    Log To Console    \n******** Step 01. Fault 1934 on RMOD:
    kw_common.Allow Alarms    1934
    Trigger Fault 1934 on AREA from all 2 fans.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${300}
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Builtin.Sleep    60
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

    # -------------------------- Part with FAF enabled
    Log To Console    \n******** Step 02. FAF actRadioFanFailureEarlyNotif true. Fault 1934 moves to FANs
    Change FAF actRadioFanFailureEarlyNotif to true

    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
    Builtin.Sleep    30
    Remove fid: 1934 on all fans for rmod: AREA from Faulty Objects due to PR 05184468.
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected


    [Teardown]    Run Keywords
    ...    TC 04 Teardown    AND
    ...    SSHRMOD_A.Close Connection    AND
    ...    Run Keyword If Test Failed    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown
    ...    AND    Test Teardown with Watching Alarms


CB012097_08_Feature_Enable_with_Fault_1933_not_raised_due_radio_temperature_not_reach_threshold
    [Tags]    08    CRT    A2
    [Setup]    Run Keywords
    ...    Set RMOD Variables for Test Case    rmod_type=AREA    rmod_id=0    rmod_list=${RMOD_LIST}    AND
    ...    Prepare SSH connection to Container, AREA    AND
    ...    Prepare RMOD AREA environment
    ...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Transmission path failure
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}


    # -------------------------- Part with FAF disabled

    Log To Console    \n******** Step 00 - actRadioFanFailureEarlyNotif false. Temperature threshold HIGH.
    kw_common.Allow Alarms    1934    # Filter out temporary 1934 after TCS change
    Set TCS to prepare 1933 triggering by change parameters ${tcs_prepare_1933_AREA} on AREA.
    BuiltIn.Sleep    10
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${40}
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${120}
    Builtin.Sleep    10
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    kw_common.Disallow Alarms    1934
    Change FAF actRadioFanFailureEarlyNotif to false

    Log To Console    \n******** Step 01. Fault 1933:
    Trigger Fault 1933 on AREA from all 2 fans, temperature not exceeded threshold.
    Remove fid: 1933 on fans: [] for rmod: AREA from Faulty Objects.
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Builtin.Sleep    60
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

    # # -------------------------- Part with FAF enabled
    Log To Console    \n******** Step 02. Part with FAF enabled. FAN Fault 1933 triggered:
    Clear Fault 1933 on AREA from all 2 fans.    # PR 05184468
    kw_common.Allow Alarms    1933
    Change FAF actRadioFanFailureEarlyNotif to true
    Trigger Fault 1933 on AREA from all 2 fans.    # PR 05184468
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933    awaiting_time=${120}
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Builtin.Sleep    30
    IF    'SBTS25R3' not in $ENB_BUILD
        Remove fid: 1933 on all fans for rmod: AREA from Faulty Objects due to PR 05184468.
    END
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected


    [Teardown]    Run Keywords
    ...    TC 08 Teardown    AND
    ...    SSHRMOD_A.Close Connection    AND
    ...    Run Keyword If Test Failed    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown
    ...    AND    Test Teardown with Watching Alarms


*** Keywords ***

TC 02 Teardown
    Log To Console    TC 02 Teardown...
    Clear Fault 1932 on AREA from all 2 fans.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1932
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1932
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 04 Teardown
    Log To Console    TC 04 Teardown...
    Set TCS to clear 1934 triggering by change parameters ${tcs_clear_AREA} on AREA.
    Remove fid: 1934 on fans: [1,2] for rmod: AREA from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1934
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 08 Teardown
    Log To Console    TC 08 Teardown...
    Set TCS to clear 1933 triggering by change parameters ${tcs_clear_AREA} on AREA.
    Remove fid: 1933 on fans: [1,2] for rmod: AREA from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1933
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

