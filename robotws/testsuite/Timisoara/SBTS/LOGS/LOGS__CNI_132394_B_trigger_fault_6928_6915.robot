*** Settings ***
Documentation  Test Suite for TL10835_ARO
Library    OperatingSystem
Library    SSHLibrary
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pdu.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/suppress.robot


*** Variables ***
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu
${STARTUP_TIMEOUT}        20


*** Keywords ***
TC__LOGS__CNI_132394_B_trigger_fault_6928_6915
    [Documentation]
    ...  [CASE LINK]:
    ...  ******************
    ...  Author: Maria Toma
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2025-31-10 - TC created. version 1.0
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to trigger fault 6928 and 6915 and then to recover the Test Line
    ...  Faults 6928 and fault 6915 can be triggered on specific HW due to CNI-132394, for 242 only on ASIL+ABIA(K2A and D).
    ...  For 6928 please check: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1929153166
    ...  For 6915 please check: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1929152164
    ...  *******************

    Step 0: Preconditions
    Step 1: Trigger fault 6928
    Step 2: Check presence of fault 6928
    Step 3: Perform site reset
    Step 4: Trigger fault 6915
    Step 5: Check presence of fault 6915
    Step 6: Perform site reset to recover



Step 0: Preconditions
    [Documentation]
    ...   in this step we are verifying if BTS is up and running

    Log    \nStep 0: Preconditions    console=${True}
    ${btsid}   bts_states.Get BTS ID
    Set Test Variable    ${BTS_ID}    ${btsid}
    Configure NOTE to unhide suppressed faults    S0G4

Step 1: Trigger fault 6928
    [Documentation]
    ...   In this step there is a connection on SMOD and fault is triggered
    Log    \nStep 1: Connect to BTS via ssh and trigger fault 6917   console=${True}

    SSH Connection
    ${output_1}   ssh.Execute   command=lfs-update-os-alarms -s TPM:HW_DEGRADED:Degraded


Step 2: Check presence of fault 6928
    [Documentation]  This KW is checking if FID-6928 was raised (max time for waiting is 30 sec)

    Log    Step 3: Check if FID-6928 was raised    console=${True}
    Set Test Variable    ${FID-6928_was_raised}    ${False}
    Wait Until Keyword Succeeds    30s    1s    coam.Assert Alarm Active    faultId=6928
    Set Test Variable    ${FID-6928_was_raised}    ${True}
    Sleep  60s

Step 3: Perform site reset
    [Documentation]
    ...   in this step site reset is performed in order to recover the TL
    Reset Site And Wait For OnAir

Step 4: Trigger fault 6915
    [Documentation]
    ...   In this step there is a connection on SMOD and fault is triggered
    Log    \nStep 1: Connect to BTS via ssh and trigger fault 6915   console=${True}

    SSH Connection
    ${output_2}   ssh.Execute   command=lfs-update-os-alarms -s HW_STORAGE:BOOT_FLASH_CORRUPTED

Step 5: Check presence of fault 6915
    [Documentation]  This KW is checking if FID-6915 was raised (max time for waiting is 30 sec)

    Log    Step 3: Check if FID-6915 was raised    console=${True}
    Set Test Variable    ${FID-6915_was_raised}    ${False}
    Wait Until Keyword Succeeds    30s    1s    coam.Assert Alarm Active    faultId=6915
    Set Test Variable    ${FID-6915_was_raised}    ${True}
    Sleep  60s

Step 6: Perform site reset to recover
    [Documentation]
    ...   in this step site reset is performed in order to recover the TL
    Reset Site And Wait For OnAir


Reset Site And Wait For OnAir
    [Documentation]
    ...  This keyword performs site reset and waits until bts is back OnAir
    coam.Reset Site
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  1m  Check All Modules And All Cells Working States
    log  \nReset complete  console=${True}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
