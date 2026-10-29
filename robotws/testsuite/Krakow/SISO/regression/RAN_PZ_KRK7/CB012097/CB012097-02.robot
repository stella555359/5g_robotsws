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
...    Item A6/A5. Faults 1932, 1933, 1934 will be supported on ASiR Hub2.0 and 1932, 1933 on ASiR Hub1.0
...    CB012097-SR-A5-sHub1.0
...    CB012097-SR-A6-sHub2.0

Library      Collections
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      SSHLibrary
Library      resources/common.py
Variables    resources/variables02.py
Resource     resources/kw02.robot
Resource     resources/kw_common.robot
Resource     taf/rfrl/procedures/resources/robot/Reset.robot

Suite Setup       Custom Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***

${5G_SOURCE_SW}        ${None}
${5G_TARGET_SW}        ${None}

@{CUSTOM_ALLOWED_ALARMS}=       61648    7115    4420    4123    4125    8150    4459    8000   6327
@{CRITICAL_FAULTS}              10  1806  16  4341  4383  4352  1868  69
${REMOTE_VM_IP}=                ${tl.test_pcs[0].default_ssh_connection_details.addr}
${REMOTE_MPLANE}=               ${tl.gnbs[0].oam_ip.v4.split('/')[0]}
${HOSTNAME}=                    7_7_TSPY016
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
${RMOD_LIST}=    ${tl.gnbs[0].dus[0].airscale.core_units[0].rus}
${MRBTS_ID}=     ${tl.gnbs[0].global_bts_id}

&{FAULT}=        1932=No module fan detected    1933=Cooling fan broken    1934=Cooling fan has reduced from the set speed
...              10=No connection to unit    4589=Unit power reset    4681=Diagnostic Check Error
&{RMOD_RUNTIME}=   APHA=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/ASIRMOD_R-1
            ...    APHG=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/ASIRMOD_R-2
&{FAN_RUNTIME}=    APHA=MRBTS-1/EQM_R-1/APEQM_R-1/ASIRMOD_R-1/FAN_R-
            ...    APHG=MRBTS-1/EQM_R-1/APEQM_R-1/ASIRMOD_R-2/FAN_R-

# Expected faulty objects needed to present fault verification:
@{FAULTY_1932_RMODS}=    @{EMPTY}
@{FAULTY_1932_FANS}=     @{EMPTY}
@{FAULTY_1933_RMODS}=    @{EMPTY}
@{FAULTY_1933_FANS}=     @{EMPTY}
@{FAULTY_1934_RMODS}=    @{EMPTY}
@{FAULTY_1934_FANS}=     @{EMPTY}

${tc16_robustness_iterations}=  3
                    #
*** Test Cases ***
CB012097_05_Feature_Disable_with_Fault_1932_activated
    [Tags]    05    CRT    A5
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container    AND
    ...    Prepare RMOD APHA environment
    ...    AND    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Setup of X2 connectivity to gNB failed
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}

    Set TCS temperature threshold to 25 degrees on APHA, skip reboot.

    # -------------------------- Part with FAF enabled
    Log To Console    \n******** Step 01. Fault 1932:
    kw_common.Allow Alarms    1932
    Trigger Fault 1932 on APHA from fan(s) [1-4].
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1932
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    # -------------------------- Part with FAF disabled
    Log To Console    \n******** Step 02.
    Change FAF actRadioFanFailureEarlyNotif to false

    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

    [Teardown]    Run Keywords
    ...    TC 05 Teardown    AND
    ...    SSHRMOD.Close Connection    AND
    ...    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms


CB012097_06_Feature_Disable_with_Fault_1933_activated
    [Tags]    06    CRT    A5
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container    AND
    ...    Prepare RMOD APHA environment
    ...    AND    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Setup of X2 connectivity to gNB failed
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}

    Log To Console    \n******** Step 01. Fault 1933:
    Set TCS temperature threshold to 25 degrees on APHA, skip reboot.
    kw_common.Allow Alarms    1933
    Trigger Fault 1933 on APHA from fan(s) [1-4].
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    # -------------------------- Part with FAF disabled
    Log To Console    \n******** Step 02.
    Change FAF actRadioFanFailureEarlyNotif to false

    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

    [Teardown]    Run Keywords
    ...    TC 06 Teardown    AND
    ...    SSHRMOD.Close Connection    AND
    ...    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms


CB012097_09_Feature_Enable_with_Fault_1934_not_raised_due_radio_temperature_not_reach_threshold
    [Tags]    09    CRT    A6
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container    AND
    ...    Prepare RMOD APHG environment
    ...    AND    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Setup of X2 connectivity to gNB failed
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}

    # -------------------------- Part with FAF disabled
    Log To Console    \n******** Step 00 Part with FAF disabled. Temperature threshold HIGH.
    Change FAF actRadioFanFailureEarlyNotif to false
    Set TCS temperature threshold to 80 degrees on APHG, skip reboot.

    # --------------------------
    Log To Console    \n******** Step 01. RMOD Fault 1934 not triggered due to low temperature:
    Trigger Fault 1934 on APHG from all 4 fans.
    Remove fid: 1934 on fans: [] for rmod: APHG from Faulty Objects.
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Builtin.Sleep    60
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

    # -------------------------- Part with FAF enabled
    Log To Console    \n******** Step 02. Part with FAF enabled. FAN Fault 1934 triggered:
    kw_common.Allow Alarms    1934
    Change FAF actRadioFanFailureEarlyNotif to true
    # Add fid: 1934 on fans: [1-4] for rmod: APHG to Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1934
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    [Teardown]    Run Keywords
    ...    TC 09 Teardown    AND
    ...    SSHRMOD.Close Connection    AND
    ...    Run Keyword If Test Failed    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms


CB012097_11_Feature_Disable_with_Fault_1934_not_raised_due_radio_temperature_not_reach_threshold
    [Tags]    11    CRT    A6
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container    AND
    ...    Prepare RMOD APHG environment    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Setup of X2 connectivity to gNB failed
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}

    # -------------------------- Part with FAF enabled
    Log To Console    \n******** Step 00 Part with FAF enabled. Temperature threshold HIGH.
    Set TCS temperature threshold to 90 degrees on APHG, skip reboot.

    # --------------------------
    Log To Console    \n******** Step 01. FAN Fault 1934 triggered:
    kw_common.Allow Alarms    1934
    Trigger Fault 1934 on APHG from all 4 fans.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1934
    Builtin.Sleep    30
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    # -------------------------- Part with FAF disabled
    Log To Console    \n******** Step 02. Part with FAF enabled RMOD Fault 1934 not triggered due to low temperature.:
    Change FAF actRadioFanFailureEarlyNotif to false
    Remove fid: 1934 on fans: [] for rmod: APHG from Faulty Objects.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1934
    Builtin.Sleep    30
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

    [Teardown]    Run Keywords
    ...    TC 11 Teardown    AND
    ...    SSHRMOD.Close Connection    AND
    ...    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms


CB012097_15_Exploratory
    [Tags]    15    CRT    A5
    [Documentation]    Diagnostic check error for alarm 1933 after Site Reset
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container    AND
    ...    Prepare RMOD APHA environment
    ...    AND    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Setup of X2 connectivity to gNB failed
        ...    ${FAULT}[1932]    ${FAULT}[1933]    ${FAULT}[1934]    ${FAULT}[10]    ${FAULT}[4589]
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}

    Log To Console    \n******** Step 01. Fault 1933:
    Set TCS temperature threshold to 25 degrees on APHA, skip reboot.
    kw_common.Allow Alarms    1933
    Trigger Fault 1933 on APHA from fan(s) [1-4].
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    # -------------------------- Diagnostic Check
    Log To Console    \n******** Step 02 Reset Site and Diagnostic Check.
    kw_common.Allow Alarms    4681
    SSHRMOD.Close Connection
    Perform Site Reset And Wait On OnAir
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    4681
    SSHRMOD.Open Host Connection    ${SMOD_ADDR}    ${SMOD_USER}    ${SMOD_PASS}
    SSHRMOD.Attach To Container
    ${report}=    Get Diagnostic Check
    Verify Diagnostic Check    ${report}    Radio Module FAN    Check point failure    APHA
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    Log To Console    \n******** Step 03. Clear Fault 1933:
    Clear Fault 1933 on APHA from fan(s) [1-4].
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1933
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

    Log To Console    \n******** Step 04 Diagnostic Check.
    ${report}=    Get Diagnostic Check
    Verify Diagnostic Check    ${report}    Radio Module FAN    Check point failure    APHA    negative_check=True
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    4681
    Builtin.Sleep    10
    kw_common.Disallow Alarms    4681

    [Teardown]    Run Keywords
    ...    TC 15 Teardown    AND
    ...    SSHRMOD.Close Connection    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms


CB012097_16_Robustness
    [Tags]    16  robustness  CRT    A6
    [Setup]    Run Keywords
    ...    Prepare SSH connection to Container    AND
    ...    Prepare RMOD APHG environment    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Setup of X2 connectivity to gNB failed
    ...    AND
    ...    common_setups_and_teardowns.Common Preconditions With Watching Alarms    collect_syslog=${False}  collect_ru_console_log=${False}

    Set TCS temperature threshold to 25 degrees on APHG, skip reboot.

    FOR    ${iter}    IN RANGE    1    ${tc16_robustness_iterations}+1
        Log    \n---***** Iteration ${iter} of ${tc16_robustness_iterations} Start... *****---    console=True

        # -------------------------- Part with FAF enabled
        Log To Console    \n******** Step 01. Fault 1932:
        kw_common.Allow Alarms    1932
        Trigger Fault 1932 on APHG from fan(s) [1,3].
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1932
        Builtin.Sleep    10
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

        # --------------------------
        Log To Console    \n******** Step 02. Fault 1934:
        kw_common.Allow Alarms    1934
        Clear Fault 1932 on APHG from fan(s) [1,3], skip reboot.
        Trigger Fault 1934 on APHG from all 4 fans.
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1934
        Builtin.Sleep    10
        kw_common.Disallow Alarms    1932
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

        # --------------------------
        Log To Console    \n******** Step 03. Fault 1934 and 1933:
        kw_common.Allow Alarms    1933
        Trigger Fault 1933 on APHG from fan(s) [2,4].
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933
        Remove fid: 1934 on fans: [2,4] for rmod: APHG from Faulty Objects.
        Builtin.Sleep    15
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

        # -------------------------- Part with FAF disabled
        Log To Console    \n******** Step 04.
        Change FAF actRadioFanFailureEarlyNotif to false

        # --------------------------
        Log To Console    \n******** Step 05. Only RMOD Fault 1933 despite 1934 trigger:
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933
        Remove fid: 1934 on fans: [] for rmod: APHG from Faulty Objects.
        Builtin.Sleep    10
        kw_common.Disallow Alarms    1934
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

        # --------------------------
        Log To Console    \n******** Step 06. RMOD Fault 1934 again after 1933 clear:
        kw_common.Allow Alarms    1934
        Clear Fault 1933 on APHG from fan(s) [2,4].
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
        Add fid: 1934 on fans: [1-4] for rmod: APHG to Faulty Objects.
        Builtin.Sleep    10
        kw_common.Disallow Alarms    1933
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

        # --------------------------
        Log To Console    \n******** Step 07. Clear 1934. Trigger RMOD Fault 1932:
        kw_common.Allow Alarms    1932
        Set TCS temperature threshold to 75 degrees on APHG, skip reboot.
        Clear Fault 1934 on APHG from all 4 fans, skip reboot.
        Trigger Fault 1932 on APHG from fan(s) [1,3].
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1932
        Builtin.Sleep    10
        kw_common.Disallow Alarms    1934
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

        # --------------------------
        Log To Console    \n******** Step 08. Clear 1932. No Faults:
        Set TCS temperature threshold to 25 degrees on APHG, skip reboot.
        Clear Fault 1932 on APHG from fan(s) [1,3].
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1932
        Builtin.Sleep    10
        kw_common.Disallow Alarms    1932    1933    1934
        Fault_verifier.log_alarms

        # --------------------------
        Log To Console    \n******** Step 09. Trigger 1932, 1933 and 1934 on RMOD:
        kw_common.Allow Alarms    1932    1934
        Trigger Fault 1932 on APHG from fan(s) [1], skip reboot.
        Trigger Fault 1934 on APHG from all 4 fans.
        Remove fid: 1934 on fans: [1] for rmod: APHG from Faulty Objects.
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1932
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1934
        Builtin.Sleep    10
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
        kw_common.Allow Alarms    1933
        Trigger Fault 1933 on APHG from fan(s) [2,3].
        Remove fid: 1934 on fans: [2,3] for rmod: APHG from Faulty Objects.
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1933
        Remove fid: 1934 on fans: [] for rmod: APHG from Faulty Objects.
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
        Builtin.Sleep    15
        kw_common.Disallow Alarms    1934
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected

        # -------------------------- Part with FAF enabled
        Log To Console    \n******** Step 10.
        kw_common.Allow Alarms    1934
        Change FAF actRadioFanFailureEarlyNotif to true

        # --------------------------
        Log To Console    \n******** Step 11. Change 1932, 1933 object to FAN, Fault 1934 appear:
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_activation    1934
        Builtin.Sleep    15
        Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

        # --------------------------
        Log To Console    \n******** Step 12. Clear All 1932, 1933 and 1934 Faults:
        Clear Fault 1933 on APHG from fan(s) [2,3].
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
        Clear Fault 1932 on APHG from fan(s) [1], skip reboot.
        Clear Fault 1934 on APHG from all 4 fans.
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1932
        Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
        Builtin.Sleep    10
        kw_common.Disallow Alarms    1932    1933    1934
        Fault_verifier.log_alarms

        Log    \n---***** Iteration ${iter} of ${tc16_robustness_iterations} PASSED *****---   console=True
    END

    [Teardown]    Run Keywords
    ...    TC 16 Robustness Teardown    AND
    ...    SSHRMOD.Close Connection    AND
    ...    Change FAF actRadioFanFailureEarlyNotif to true    AND
    ...    Test Teardown    AND
    ...    Test Teardown with Watching Alarms

*** Keywords ***

TC 05 Teardown
    Log To Console    TC 05 Teardown...
    Log To Console    Clearing faults...
    Clear Fault 1932 on APHA from fan(s) [1-4].
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1932
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1932
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 06 Teardown
    Log To Console    TC 06 Teardown...
    Log To Console    Clearing faults...
    Clear Fault 1933 on APHA from fan(s) [1-4].
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1933
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 09 Teardown
    Log To Console    TC 09 Teardown...
    Log To Console    Clearing faults...
    Clear Fault 1934 on APHG from all 4 fans.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
    Builtin.Sleep    10
    kw_common.Disallow Alarms    1934
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 11 Teardown
    Log To Console    TC 11 Teardown...
    Log To Console    Clearing faults...
    Clear Fault 1934 on APHG from all 4 fans.
    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934
    Builtin.Sleep    10
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 15 Teardown
    Log To Console    TC 15 Teardown...
    Run Keyword If Test Failed    Run Keywords
    ...    Log To Console    Clearing faults...    AND
    ...    Clear Fault 1933 on APHA from fan(s) [1-4].    AND
    ...    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933    AND
    ...    Builtin.Sleep    10    AND
    ...    Get Diagnostic Check   AND
    ...    kw_common.Disallow Alarms    1933    4681
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected

TC 16 Robustness Teardown
    Log To Console    TC 16 Teardown...
    Run Keyword If Test Failed    Run Keywords
    ...    Clear Fault 1933 on APHG from fan(s) [1-4].    AND
    ...    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1933    AND
    ...    Clear Fault 1934 on APHG from all 4 fans, skip reboot.    AND
    ...    Clear Fault 1932 on APHG from fan(s) [1-4].    AND
    ...    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1934    AND
    ...    Run Keyword And Warn On Failure    Fault_verifier.wait_for_alarm_deactivation    1932    AND
    ...    Builtin.Sleep    10    AND
    ...    kw_common.Disallow Alarms    1932    1933    1934
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related RMOD Faults are Triggered as Expected
    Wait Until Keyword Succeeds  1 min  10s    Verify All Fan Related FAN Faults are Triggered as Expected
