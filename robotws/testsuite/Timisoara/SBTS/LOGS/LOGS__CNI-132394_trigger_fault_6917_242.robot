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
${FSP_ID_test}
${FSP_ID_ABIL_L}    fsp3s0icom
${FSP_ID_ABIA_L}    fsp-1a
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu
${trigger_6917}    lfs-update-os-alarms -s HW_STORAGE:BOOT_FLASH_RECOVERED
${trigger_242}     lfs-update-os-alarms -s HW_ETHERNET:MONITORING_FAILURE
${STARTUP_TIMEOUT}        20


*** Keywords ***
TC__LOGS__CNI-132394_trigger_fault_6917_242
    [Documentation]
    ...  [CASE LINK]:
    ...  ******************
    ...  Author: Maria Toma
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2025-14-07 - TC created. version 1.0
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to trigger fault 6917 and 242 and then to recover the Test Line
    ...  Faults 6917 and fault 242 can be triggered on specific HW due to CNI-132394, for 242 only on ASIL+ABIA(K2A and D).
    ...  For 6917 please check: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1929152812
    ...  For 242 please check: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1986780083
    ...  CLOUD_SRAN_NLWG_10835_2ASIL_2ABIA_2ABIL_1ABIO_1ABIN_FXED_AHGB_AHBCC_3AHIB_AHIB_AEHC_AZHN
    ...  *******************

    Step 0: Preconditions
    Step 1: Perform Site Reset
    Step 2: Trigger fault 6917
    Step 3: Check presence of fault 6917
    Step 4: Trigger fault 242
    Step 5: Check presence of fault 242
    Step 6: Perform Site Reset for recovery

Step 0: Preconditions
    [Documentation]
    ...   in this step we are verifying if BTS is up and running

    Log    \nStep 0: Preconditions    console=${True}
    ${btsid}   bts_states.Get BTS ID
    Set Test Variable    ${BTS_ID}    ${btsid}
    Configure NOTE to unhide suppressed faults    S0G4

Step 1: Perform Site Reset
    [Documentation]
    ...   in this step site reset is performed
    Reset Site And Wait For OnAir


Step 2: Trigger fault 6917
    [Documentation]
    ...   In this step there is a connection on SMOD and fault is triggered
    Log    \nStep 1: Connect to BTS via ssh and trigger fault 6917   console=${True}

    Trigger fault    ${FSP_ID_ABIL_L}    ${trigger_6917}


Step 3: Check presence of fault 6917
    [Documentation]  This KW is checking if FID-6917 was raised (max time for waiting is 30 sec)

    Log    Step 3: Check if FID-6917 was raised    console=${True}
    Set Test Variable    ${FID-6917_was_raised}    ${False}
    Wait Until Keyword Succeeds    30s    1s    coam.Assert Alarm Active    faultId=6917
    Set Test Variable    ${FID-6917_was_raised}    ${True}
    Sleep  60s

Step 4: Trigger fault 242
    [Documentation]  In this step oject Note is configured and there is a connection on SMOD and fault is triggered
    Log    Step 4: Cofigure oject NOTE and trigger fault 242    console=${True}
    Configure NOTE to unhide suppressed faults    R4X8
    Trigger fault    ${FSP_ID_ABIA_L}    ${trigger_242}

Step 5: Check presence of fault 242
    [Documentation]  This KW is checking if FID-242 was raised

    Log    Step 5: Check if FID-242 was raised    console=${True}
    Set Test Variable    ${FID-242_was_raised}    ${False}
    Wait Until Keyword Succeeds    30s    1s    coam.Assert Alarm Active    faultId=242
    Set Test Variable    ${FID-242_was_raised}    ${True}
    Sleep  100s

Step 6: Perform Site Reset for recovery
    [Documentation]
    ...   in this step site reset is performed in order to recover the TL
    Log    Step 6: Perform site reset to recover TL    console=${True}
    Reset Site And Wait For OnAir

Trigger fault
    [Documentation]
    ...    This step provides to perform BBMOD reset, with FSP_ID given as argument
    [Arguments]    ${FSP_ID}    ${command_trigger_fault}

    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Write    > /user/${BTS_login}/.ssh/known_hosts
    SSHLibrary.Write    cat /user/${BTS_login}/.ssh/known_hosts
    Sleep    3s
    SSHLibrary.Read
    SSHLibrary.Write    ssh ${BTS_login}@${FSP_ID}
    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Are you sure you want to continue connecting" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    yes    AND    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Password:" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    ${BTS_password}    AND    Sleep    5s
    Sleep    5s
    SSHLibrary.Write    ${command_trigger_fault}
    Sleep    10s
    SSHLibrary.Read
    SSHLibrary.Close Connection

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
