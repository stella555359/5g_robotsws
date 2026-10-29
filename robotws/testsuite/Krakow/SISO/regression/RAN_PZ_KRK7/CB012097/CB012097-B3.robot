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
...    CB012097-SR-B3-RF5.1

Library      Collections
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      resources/common.py
Library      SSHLibrary
Variables    resources/variables_b3.py
Resource     resources/kw_b3.robot
Resource     resources/kw_common.robot

Suite Setup       TL 7_7_T09SK145 Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***

${5G_SOURCE_SW}        ${None}
${5G_TARGET_SW}        ${None}

@{CUSTOM_ALLOWED_ALARMS}=       61648    7115    4420    4123    4125    8150    4459    8000
@{CRITICAL_FAULTS}              10  1806  16  4341  4383  4352  1868  69
${REMOTE_VM_IP}=                ${tl.test_pcs[0].default_ssh_connection_details.addr}
${REMOTE_MPLANE}=               ${tl.gnbs[0].oam_ip.v4.split('/')[0]}
@{ADDITIONAL_ALARMS_DURING_PREP}    @{EMPTY}


# UUF variables

@{CUSTOM_ALARMS}=       ${CUSTOM_ALLOWED_ALARMS}


${SMOD_ADDR}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${SMOD_USER}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${SMOD_PASS}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${SMOD_SSH}=     ${tl.gnbs[0].cu.oam_ssh_connection_details}

${MRBTS_ID}=     ${tl.gnbs[0].global_bts_id}

&{FAULT}=        1932=No module fan detected    1933=Cooling fan broken    1934=Cooling fan has reduced from the set speed
...              10=No connection to unit    4589=Unit power reset    4681=Diagnostic Check Error
&{RMOD_RUNTIME}=   AHEGA=MRBTS-${MRBTS_ID}/EQM_R-4/APEQM_R-1/RMOD_R-1
            ...    AHFIG=MRBTS-${MRBTS_ID}/EQM_R-4/APEQM_R-1/RMOD_R-2
            ...    AHLOA=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1
&{FAN_RUNTIME}=    AHEGA=MRBTS-4/EQM_R-4/APEQM_R-1/RMOD_R-1/FAN_R-
            ...    AHFIG=MRBTS-4/EQM_R-4/APEQM_R-1/RMOD_R-2/FAN_R-
            ...    AHLOA=MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1/FAN_R-

# Expected faulty objects needed to present fault verification:
@{FAULTY_1932_RMODS}=    @{EMPTY}
@{FAULTY_1932_FANS}=     @{EMPTY}
@{FAULTY_1933_RMODS}=    @{EMPTY}
@{FAULTY_1933_FANS}=     @{EMPTY}
@{FAULTY_1934_RMODS}=    @{EMPTY}
@{FAULTY_1934_FANS}=     @{EMPTY}

${tc13_iterations}=  3
                    #

${AHEGA_sn}=             K9182603831
${AHLOA_sn}=             BL1930G11JG

*** Test Cases ***
CB012097_03_Feature_Enable_with_Fault_1933_activated
    [Tags]    03    CRT    B3
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container, AHLOA    AND
    ...    Prepare RMOD AHLOA with sn:${AHLOA_sn} environment    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    #Phase error exceeds 5 us limit    ToP reference missing
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}
    ...    AND    Run Keyword And Ignore Error    SSHRMOD_B.Close Connection
    ...    AND    Prepare SSH connection to Container, AHLOA


    # -------------------------- Part with FAF disabled

    Log To Console    \n******** Step 00.
    kw_common.Allow Alarms    1934    # Filter out temporary 1934 after TCS change
    Set TCS to prepare 1933 triggering by change parameters ${tcs_prepare_1933_AHLOA} on AHLOA with sn:${AHLOA_sn}.
    BuiltIn.Sleep    10
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${40}
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${120}
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    BuiltIn.Sleep    10
    kw_common.Disallow Alarms    1934
    Change FAF actRadioFanFailureEarlyNotif to false

    Log To Console    \n******** Step 01. Fault 1933:
    kw_common.Allow Alarms    1933   1934
    Trigger Fault 1933 on AHLOA with sn:${AHLOA_sn} from fan.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933    awaiting_time=${120}
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1934
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Builtin.Sleep    60
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

    # # -------------------------- Part with FAF enabled
    Log To Console    \n******** Step 02.
    Change FAF actRadioFanFailureEarlyNotif to true
    Builtin.Sleep    10

    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    gnbcell.Wait For All Cells To Be OnAir    timeout=300



    [Teardown]    Run Keywords
    ...    TC 03 Teardown    AND
    ...    SSHRMOD_B.Close Connection    AND
    ...    Run Keyword If Test Failed    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms


CB012097_13_Disable_Enable_feature_repeatedly_when_fault_1933_1934_active
    [Tags]    13    CRT    B3
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container, AHLOA    AND
    ...    Prepare RMOD AHLOA with sn:${AHLOA_sn} environment    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Phase error exceeds 5 us limit    ToP reference missing
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}
    ...    AND    Run Keyword And Ignore Error    SSHRMOD_B.Close Connection
    ...    AND    Prepare SSH connection to Container, AHLOA


    # -------------------------- Part with FAF disabled

    Log To Console    \n******** Step 00, prep,  disable FAF.
    kw_common.Allow Alarms    1934    # Filter out temporary 1934 after TCS change
    Set TCS to prepare 1933 triggering by change parameters ${tcs_prepare_1933_AHLOA} on AHLOA with sn:${AHLOA_sn}.
    BuiltIn.Sleep    10
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${40}
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${120}
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    BuiltIn.Sleep    10
    kw_common.Disallow Alarms    1934
    Change FAF actRadioFanFailureEarlyNotif to false

    Log To Console    \n******** Step 01. Fault 1933:
    kw_common.Allow Alarms    1933    1934
    Trigger Fault 1933 on AHLOA with sn:${AHLOA_sn} from fan.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933    awaiting_time=${120}
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1934
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Builtin.Sleep    30
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

    FOR    ${iter}    IN RANGE    1    ${tc13_iterations}+1
        Log    \n---***** Iteration ${iter} of ${tc13_iterations} Start... *****---    console=True

        Log To Console    \n******** Step 02. Fault 1934:
        kw_common.Allow Alarms    1934
        Quick Trigger Fault 1934 on AHLOA with sn:${AHLOA_sn}.
        Remove fid: 1933 on fans: [1] for rmod: AHLOA from Faulty Objects.
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${120}
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933    awaiting_time=${10}
        Builtin.Sleep    10
        kw_common.Disallow Alarms    1933
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
        gnbcell.Wait For All Cells To Be OnAir    timeout=300
        Builtin.Sleep    30
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

        # # -------------------------- Part with FAF enabled
        Log To Console    \n******** Step 03, FAF enable.
        Change FAF actRadioFanFailureEarlyNotif to true
        Builtin.Sleep    10
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
        gnbcell.Wait For All Cells To Be OnAir    timeout=300

        Log To Console    \n******** Step 04, Back to 1933.
        kw_common.Allow Alarms    1933
        Quick Trigger Fault 1933 on AHLOA with sn:${AHLOA_sn}.
        Remove fid: 1934 on fans: [1] for rmod: AHLOA from Faulty Objects.
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933    awaiting_time=${120}
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${10}
        Builtin.Sleep    10
        kw_common.Disallow Alarms    1934
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
        gnbcell.Wait For All Cells To Be OnAir    timeout=300


        # -------------------------- Part with FAF disabled
        Log To Console    \n******** Step 05,  disable FAF.
        Change FAF actRadioFanFailureEarlyNotif to false

        Builtin.Sleep    10
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
        gnbcell.Wait For All Cells To Be OnAir    timeout=300
        Builtin.Sleep    30
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    END


    [Teardown]    Run Keywords
    ...    TC 13 Teardown    AND
    ...    SSHRMOD_B.Close Connection    AND
    ...    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms


CB012097_15_Exploratory
    [Tags]    15    CRT    B3
    [Documentation]    Diagnostic check error for alarm 1933 and 1934
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container, AHLOA    AND
    ...    Prepare RMOD AHLOA with sn:${AHLOA_sn} environment    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Phase error exceeds 5 us limit    ToP reference missing
    ...    AND    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}
    ...    AND    Run Keyword And Ignore Error    SSHRMOD_B.Close Connection
    ...    AND    Prepare SSH connection to Container, AHLOA


    Log To Console    \n******** Step 00, prep.
    kw_common.Allow Alarms    1934    # Filter out temporary 1934 after TCS change
    Set TCS to prepare 1933 triggering by change parameters ${tcs_prepare_1933_AHLOA} on AHLOA with sn:${AHLOA_sn}.
    BuiltIn.Sleep    10
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${40}
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${120}
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    BuiltIn.Sleep    10

    Log To Console    \n******** Step 01. Fault 1933:
    kw_common.Allow Alarms    1933
    Trigger Fault 1933 on AHLOA with sn:${AHLOA_sn} from fan.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933    awaiting_time=${120}
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1934
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
    gnbcell.Wait For All Cells To Be OnAir    timeout=300

    # -------------------------- Diagnostic Check
    Log To Console    \n******** Step 02 Diagnostic Check.
    kw_common.Allow Alarms    4681
    ${report}=    Get Diagnostic Check
    Verify Diagnostic Check    ${report}    Radio Module FAN    Check point failure    AHLOA
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    4681
    Remove fid: 1933 on all fans for rmod: AHLOA from Faulty Objects due to PR 05184468.
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected


    Log To Console    \n******** Step 03. Fault 1934:
    kw_common.Allow Alarms    1934
    Quick Trigger Fault 1934 on AHLOA with sn:${AHLOA_sn}.
    Remove fid: 1933 on fans: [1] for rmod: AHLOA from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${120}
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933    awaiting_time=${10}
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1933
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
    gnbcell.Wait For All Cells To Be OnAir    timeout=300

    # -------------------------- Diagnostic Check
    Log To Console    \n******** Step 04 Diagnostic Check.
    ${report}=    Get Diagnostic Check
    Verify Diagnostic Check    ${report}    Radio Module FAN    Check point failure    AHLOA
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    4681
    Remove fid: 1934 on all fans for rmod: AHLOA from Faulty Objects due to PR 05184468.
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected


    Log To Console    \n******** Step 05. Clear Fault 1934:
    Clear Fault 1934 on AHLOA with sn:${AHLOA_sn} from fan.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${60}
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    # -------------------------- Diagnostic Check
    Log To Console    \n******** Step 06 Diagnostic Check.
    ${report}=    Wait Until Keyword Succeeds  5 min  10s    Get Diagnostic Check and Wait for Alarm Deactivation
    Verify Diagnostic Check    ${report}    Radio Module FAN    Check point failure    AHLOA    negative_check=True
    Builtin.Sleep    10
    kw_common.Disallow Alarms    4681


    [Teardown]    Run Keywords
    ...    TC 15 Teardown    AND
    ...    SSHRMOD_B.Close Connection    AND
    ...    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown
    ...    AND    Test Teardown with Watching Alarms


*** Keywords ***
TL 7_7_T09SK145 Suite Setup
    IF    $CUSTOM_ADDITIONAL_ALARMS_DURING_PREP
        @{list_argument}=    Evaluate    [el.strip() for el in $CUSTOM_ADDITIONAL_ALARMS_DURING_PREP.split(',')]
        Log    list_argument=${list_argument}  console=True
        @{ADDITIONAL_ALARMS_DURING_PREP}=    Create List    @{ADDITIONAL_ALARMS_DURING_PREP}    @{list_argument}
        Log    ADDITIONAL_ALARMS_DURING_PREP=${ADDITIONAL_ALARMS_DURING_PREP}  console=True
    END
    Run Keyword And Ignore Error    tl_prep.prepare_testline    should_LTE_neighbour_be_changed=${False}
    ...                                                         should_5G_neighbour_be_changed=${False}
    ...                                                         wait_for_on_air=${False}
    ...                                                         swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${True}
    ...                                                  should_5G_neighbour_be_changed=${False}
    ...                                                  increase_time_for_checking_bbmod=600
    ...                                                  increase_timeout_for_update_sw=1800
    ...                                                  increase_time_for_checking_radios=2100
    ...                                                  increase_time_for_checking_cells=700
    ...                                                  swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                                  list_of_additional_allowed_alarms=${ADDITIONAL_ALARMS_DURING_PREP}



TC 03 Teardown
    Log To Console    TC 03 Teardown...
    Set TCS to clear 1933 triggering by change parameters ${tcs_clear_AHLOA} on AHLOA with sn:${AHLOA_sn}.
    Remove fid: 1933 on fans: [1] for rmod: AHLOA from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1933   # 1934
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 13 Teardown
    Log To Console    TC 13 Teardown...
    Set TCS to clear 1933 and 1934 triggering by change parameters ${tcs_clear_AHLOA} on AHLOA with sn:${AHLOA_sn}.
    Remove fid: 1933 on fans: [1] for rmod: AHLOA from Faulty Objects.
    Remove fid: 1934 on fans: [1] for rmod: AHLOA from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 15 Teardown
    Log To Console    TC 15 Teardown...
    Set TCS to clear 1933 and 1934 triggering by change parameters ${tcs_clear_AHLOA} on AHLOA with sn:${AHLOA_sn}.
    Remove fid: 1933 on fans: [1] for rmod: AHLOA from Faulty Objects.
    Remove fid: 1934 on fans: [1] for rmod: AHLOA from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
    Get Diagnostic Check
