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
Variables    resources/variables01.py
Resource     resources/kw01.robot
Resource     resources/kw_common.robot

Suite Setup       Custom Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***

${5G_SOURCE_SW}        ${None}
${5G_TARGET_SW}        ${None}

@{CUSTOM_ALLOWED_ALARMS}=       61648    7115    4420    4123    4125    8150    4459    8000    6327
@{CRITICAL_FAULTS}              10  1806  16  4341  4383  4352  1868  69
${REMOTE_VM_IP}=                ${tl.test_pcs[0].default_ssh_connection_details.addr}
${REMOTE_MPLANE}=               ${tl.gnbs[0].oam_ip.v4.split('/')[0]}
${HOSTNAME}=                    7_7_TSPY010
${TARGET_DIR}                   /home/ute/UUF_SW
${USE_REMOTE_NODE}=             ${False}
@{ADDITIONAL_ALARMS_DURING_PREP}    Setup of X2 connectivity to gNB failed


# UUF variables
${UPDATE_TEST_ITERATION}            1         # To run test with different value add arg: -v UPDATE_TEST_ITERATION:5
${SITE_RESET_TEST_ITERATION}        1         # To run test with different value add arg: -v SITE_RESET_TEST_ITERATION:30
${OMIT_L3CALL}=                     ${False}  # To run test without L3 call add arg: -v OMIT_L3CALL:True

${SHOULD_BE_REPORTED}=  ${False}
@{CUSTOMERS_LIST}=      Generic
${UPDATE_TEST_FAILED}   ${False}
${QC_DOMAIN}=           MN_RAN
${QC_PROJECT}=          RAN_VRF
@{CUSTOM_ALARMS}=       ${CUSTOM_ALLOWED_ALARMS}
${BTS_HOST_IP}          192.168.255.129
${RP_CA}                            VRF_SiSo
${RP_ORGANIZATION}                  VRF_KRK_T07
${RP_LOCATION}                      VRF_KRK

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${5G_SOURCE_SW}
...                                 target_sw=${5G_TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}                            ${NODE1}

${SMOD_ADDR}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${SMOD_USER}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${SMOD_PASS}=    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${SMOD_SSH}=     ${tl.gnbs[0].cu.oam_ssh_connection_details}

${MRBTS_ID}=     ${tl.gnbs[0].global_bts_id}

&{FAULT}=        1932=No module fan detected    1933=Cooling fan broken    1934=Cooling fan has reduced from the set speed
...              10=No connection to unit    4589=Unit power reset    4681=Diagnostic Check Error
&{RMOD_RUNTIME}=   AHEGA=MRBTS-${MRBTS_ID}/EQM_R-4/APEQM_R-1/RMOD_R-1
            ...    AHFIG=MRBTS-${MRBTS_ID}/EQM_R-4/APEQM_R-1/RMOD_R-2
&{FAN_RUNTIME}=    AHEGA=MRBTS-4/EQM_R-4/APEQM_R-1/RMOD_R-1/FAN_R-
            ...    AHFIG=MRBTS-4/EQM_R-4/APEQM_R-1/RMOD_R-2/FAN_R-

# Expected faulty objects needed to present fault verification:
@{FAULTY_1932_RMODS}=    @{EMPTY}
@{FAULTY_1932_FANS}=     @{EMPTY}
@{FAULTY_1933_RMODS}=    @{EMPTY}
@{FAULTY_1933_FANS}=     @{EMPTY}
@{FAULTY_1934_RMODS}=    @{EMPTY}
@{FAULTY_1934_FANS}=     @{EMPTY}

${tc13_iterations}=  3
                    #
*** Test Cases ***
CB012097_02_Feature_Enable_with_Fault_1932_activated
    [Tags]    02    CRT    A2
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container, AHFIG    AND
    ...    Prepare RMOD AHFIG environment    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Phase error exceeds 5 us limit    ToP reference missing
    ...        Setup of X2 connectivity to gNB failed
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}


    # -------------------------- Part with FAF disabled

    Log To Console    \n******** Step 00.
    Change FAF actRadioFanFailureEarlyNotif to false
    Set TCS parameter Nrpm_fail to value=${5} on AHFIG, skip reboot.

    Log To Console    \n******** Step 01. Fault 1932:
    kw_common.Allow Alarms    1932
    Trigger Fault 1932 on AHFIG from all 2 fans.
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
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms


CB012097_03_Feature_Enable_with_Fault_1933_activated
    [Tags]    03    CRT    B3
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container, AHEGA    AND
    ...    Prepare RMOD AHEGA environment    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Phase error exceeds 5 us limit    ToP reference missing
    ...        Setup of X2 connectivity to gNB failed
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}


    # -------------------------- Part with FAF disabled

    Log To Console    \n******** Step 00.
    kw_common.Allow Alarms    1934    # Filter out temporary 1934 after TCS change
    Set TCS to prepare 1933 triggering by change parameters ${tcs_prepare_1933_AHEGA} on AHEGA.
    BuiltIn.Sleep    10
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${40}
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${120}
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    BuiltIn.Sleep    10
    kw_common.Disallow Alarms    1934
    Change FAF actRadioFanFailureEarlyNotif to false

    Log To Console    \n******** Step 01. Fault 1933:
    kw_common.Allow Alarms    1933   1934
    Trigger Fault 1933 on AHEGA from fan.
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
    Builtin.Sleep    60
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected



    [Teardown]    Run Keywords
    ...    TC 03 Teardown    AND
    ...    SSHRMOD_B.Close Connection    AND
    ...    Run Keyword If Test Failed    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms


CB012097_04_Feature_Enable_with_Fault_1934_activated
    [Tags]    04    CRT    A2
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container, AHFIG    AND
    ...    Prepare RMOD AHFIG environment    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Phase error exceeds 5 us limit    ToP reference missing
    ...        Setup of X2 connectivity to gNB failed
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}


    # -------------------------- Part with FAF disabled

    Log To Console    \n******** Step 00, prepare TCS, FAF actRadioFanFailureEarlyNotif false.
    kw_common.Allow Alarms    1934    # Filter out temporary 1934 after TCS change
    Set TCS to prepare 1934 triggering by change parameters ${tcs_prepare_1934_AHFIG} on AHFIG.
    BuiltIn.Sleep    10
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${40}
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${120}
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    BuiltIn.Sleep    10
    kw_common.Disallow Alarms    1934
    Change FAF actRadioFanFailureEarlyNotif to false

    Log To Console    \n******** Step 01. Fault 1934 on RMOD:
    kw_common.Allow Alarms    1934
    Trigger Fault 1934 on AHFIG from all 2 fans.
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
    Remove fid: 1934 on all fans for rmod: AHFIG from Faulty Objects due to PR 05184468.
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected


    [Teardown]    Run Keywords
    ...    TC 04 Teardown    AND
    ...    SSHRMOD_A.Close Connection    AND
    ...    Run Keyword If Test Failed    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms


CB012097_08_Feature_Enable_with_Fault_1933_not_raised_due_radio_temperature_not_reach_threshold
    [Tags]    08    CRT    A2
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container, AHFIG    AND
    ...    Prepare RMOD AHFIG environment    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Phase error exceeds 5 us limit    ToP reference missing
    ...        Setup of X2 connectivity to gNB failed
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}


    # -------------------------- Part with FAF disabled

    Log To Console    \n******** Step 00 - actRadioFanFailureEarlyNotif false. Temperature threshold HIGH.
    kw_common.Allow Alarms    1934    # Filter out temporary 1934 after TCS change
    Set TCS to prepare 1933 triggering by change parameters ${tcs_prepare_1933_AHFIG} on AHFIG.
    BuiltIn.Sleep    10
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${40}
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${120}
    Builtin.Sleep    10
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    kw_common.Disallow Alarms    1934
    Change FAF actRadioFanFailureEarlyNotif to false

    Log To Console    \n******** Step 01. Fault 1933:
    Trigger Fault 1933 on AHFIG from all 2 fans, temperature not exceeded threshold.
    Remove fid: 1933 on fans: [] for rmod: AHFIG from Faulty Objects.
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Builtin.Sleep    60
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

    # # -------------------------- Part with FAF enabled
    Log To Console    \n******** Step 02. Part with FAF enabled. FAN Fault 1933 triggered:
    Clear Fault 1933 on AHFIG from all 2 fans.    # PR 05184468
    kw_common.Allow Alarms    1933
    Change FAF actRadioFanFailureEarlyNotif to true
    Trigger Fault 1933 on AHFIG from all 2 fans.    # PR 05184468
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933    awaiting_time=${120}
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Builtin.Sleep    30
    IF    'SBTS25R3' not in $ENB_BUILD
        Remove fid: 1933 on all fans for rmod: AHFIG from Faulty Objects due to PR 05184468.
    END
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected


    [Teardown]    Run Keywords
    ...    TC 08 Teardown    AND
    ...    SSHRMOD_A.Close Connection    AND
    ...    Run Keyword If Test Failed    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms


CB012097_13_Disable_Enable_feature_repeatedly_when_fault_1933_1934_active
    [Tags]    13    CRT    B3
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container, AHEGA    AND
    ...    Prepare RMOD AHEGA environment    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Phase error exceeds 5 us limit    ToP reference missing
    ...        Setup of X2 connectivity to gNB failed
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}


    # -------------------------- Part with FAF disabled

    Log To Console    \n******** Step 00, prep,  disable FAF.
    kw_common.Allow Alarms    1934    # Filter out temporary 1934 after TCS change
    Set TCS to prepare 1933 triggering by change parameters ${tcs_prepare_1933_AHEGA} on AHEGA.
    BuiltIn.Sleep    10
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${40}
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${120}
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    BuiltIn.Sleep    10
    kw_common.Disallow Alarms    1934
    Change FAF actRadioFanFailureEarlyNotif to false

    Log To Console    \n******** Step 01. Fault 1933:
    kw_common.Allow Alarms    1933    1934
    Trigger Fault 1933 on AHEGA from fan.
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
        Quick Trigger Fault 1934 on AHEGA.
        Remove fid: 1933 on fans: [1] for rmod: AHEGA from Faulty Objects.
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
        Builtin.Sleep    30
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

        Log To Console    \n******** Step 04, Back to 1933.
        kw_common.Allow Alarms    1933
        Quick Trigger Fault 1933 on AHEGA.
        Remove fid: 1934 on fans: [1] for rmod: AHEGA from Faulty Objects.
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933    awaiting_time=${120}
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${10}
        Builtin.Sleep    10
        kw_common.Disallow Alarms    1934
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
        gnbcell.Wait For All Cells To Be OnAir    timeout=300
        Builtin.Sleep    30
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected


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
    ...    Prepare SSH connection to Container, AHEGA    AND
    ...    Prepare RMOD AHEGA environment    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Phase error exceeds 5 us limit    ToP reference missing
    ...        Setup of X2 connectivity to gNB failed
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}


    Log To Console    \n******** Step 00, prep.
    kw_common.Allow Alarms    1934    # Filter out temporary 1934 after TCS change
    Set TCS to prepare 1933 triggering by change parameters ${tcs_prepare_1933_AHEGA} on AHEGA.
    BuiltIn.Sleep    10
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${40}
    Run Keyword And Ignore Error    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${120}
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    BuiltIn.Sleep    10

    Log To Console    \n******** Step 01. Fault 1933:
    kw_common.Allow Alarms    1933
    Trigger Fault 1933 on AHEGA from fan.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933    awaiting_time=${120}
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1934
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Builtin.Sleep    30
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    # -------------------------- Diagnostic Check
    Log To Console    \n******** Step 02 Diagnostic Check.
    kw_common.Allow Alarms    4681
    ${report}=    Get Diagnostic Check
    Verify Diagnostic Check    ${report}    Radio Module FAN    Check point failure    AHEGA
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    4681
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected


    Log To Console    \n******** Step 03. Fault 1934:
    kw_common.Allow Alarms    1934
    Quick Trigger Fault 1934 on AHEGA.
    Remove fid: 1933 on fans: [1] for rmod: AHEGA from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1934    awaiting_time=${120}
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933    awaiting_time=${10}
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1933
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Builtin.Sleep    30
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    # -------------------------- Diagnostic Check
    Log To Console    \n******** Step 04 Diagnostic Check.
    ${report}=    Get Diagnostic Check
    Verify Diagnostic Check    ${report}    Radio Module FAN    Check point failure    AHEGA
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    4681
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected


    Log To Console    \n******** Step 05. Clear Fault 1934:
    Clear Fault 1934 on AHEGA from fan.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934    awaiting_time=${60}
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    # -------------------------- Diagnostic Check
    Log To Console    \n******** Step 06 Diagnostic Check.
    ${report}=    Get Diagnostic Check
    Verify Diagnostic Check    ${report}    Radio Module FAN    Check point failure    AHEGA    negative_check=True
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    4681
    Builtin.Sleep    10
    kw_common.Disallow Alarms    4681


    [Teardown]    Run Keywords
    ...    TC 15 Teardown    AND
    ...    SSHRMOD_B.Close Connection    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms

*** Keywords ***

TC 02 Teardown
    Log To Console    TC 02 Teardown...
    Clear Fault 1932 on AHFIG from all 2 fans.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1932
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1932
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 03 Teardown
    Log To Console    TC 03 Teardown...
    Set TCS to clear 1933 triggering by change parameters ${tcs_clear_AHEGA} on AHEGA.
    Remove fid: 1933 on fans: [1] for rmod: AHEGA from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1933   # 1934
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 04 Teardown
    Log To Console    TC 04 Teardown...
    Set TCS to clear 1934 triggering by change parameters ${tcs_clear_AHFIG} on AHFIG.
    Remove fid: 1934 on fans: [1,2] for rmod: AHFIG from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1934
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 08 Teardown
    Log To Console    TC 08 Teardown...
    Set TCS to clear 1933 triggering by change parameters ${tcs_clear_AHFIG} on AHFIG.
    Remove fid: 1933 on fans: [1,2] for rmod: AHFIG from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1933
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 13 Teardown
    Log To Console    TC 13 Teardown...
    Set TCS to clear 1933 and 1934 triggering by change parameters ${tcs_clear_AHEGA} on AHEGA.
    Remove fid: 1933 on fans: [1] for rmod: AHEGA from Faulty Objects.
    Remove fid: 1934 on fans: [1] for rmod: AHEGA from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 15 Teardown
    Log To Console    TC 15 Teardown...
    Set TCS to clear 1933 and 1934 triggering by change parameters ${tcs_clear_AHEGA} on AHEGA.
    Remove fid: 1933 on fans: [1] for rmod: AHEGA from Faulty Objects.
    Remove fid: 1934 on fans: [1] for rmod: AHEGA from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
    Get Diagnostic Check

