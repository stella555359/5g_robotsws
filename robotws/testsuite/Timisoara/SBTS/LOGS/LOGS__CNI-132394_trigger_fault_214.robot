*** Settings ***
Documentation  Test Suite for TL10835_ARO
Library    OperatingSystem
Library    SSHLibrary
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
#Resource    ../resources/pdu.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
#Resource    ../resources/verdicts.robot


*** Variables ***
#${BTS_ip}           192.168.255.129
#${BTS_login}        toor4nsn
#${BTS_password}     oZPS0POrRieRtu
${STARTUP_TIMEOUT}        20
${path}     /opt/hwmt/python/
${path_to_script}    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10820_Audi/commissioning/script.py
${alias}     default

*** Keywords ***
TC__LOGS__CNI-132394_trigger_fault_214
    [Documentation]
    ...  [CASE LINK]:
    ...  ******************
    ...  Author: Maria Toma
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2025-24-07 - TC created. version 1.0
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to trigger fault 214 then to recover the Test Line
    ...  Fault 214 can be triggered on specific HW due to CNI-132394
    ...  Please check: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1986780190
    ...  CLOUD_SRAN_NLWG_10835_2ASIL_2ABIA_2ABIL_1ABIO_1ABIN_FXED_AHGB_AHBCC_3AHIB_AHIB_AEHC_AZHN
    ...  *******************

    Step 0: Preconditions
    Step 1: Copy script on BTS and trigger fault 214
    Step 2: Check WebEm presence
    Step 3: Perform Site Reset

Step 0: Preconditions
    [Documentation]
    ...   in this step we are verifying if BTS is up and running

    Log    \nStep 0: Preconditions      console=${True}
    ${btsid}   bts_states.Get BTS ID
    Set Test Variable    ${BTS_ID}    ${btsid}

Step 1: Copy script on BTS and trigger fault 214
    [Documentation]
    ...   in this step the script to trigger fault 214 is copied on BTS and alarm is triggered
    Log    \nStep 1: Copy script on BTS and trigger fault 214   console=${True}
    Copy script on BTS and trigger fault 214

Step 2: Check WebEm presence
    [Documentation]
    ...   in this step the presence of fault 214 is checked on WebEm
    Log   \nStep 2: Check if FID-214 was raised    console=${True}
    Set Test Variable    ${FID-214_was_raised}    ${False}
    Wait Until Keyword Succeeds    30s    1s    coam.Assert Alarm Active    faultId=214
    Set Test Variable    ${FID-214_was_raised}    ${True}
    Sleep  10s


Step 3: Perform Site Reset
    [Documentation]
    ...   in this step site reset is performed in order to recover the TL
    Log    \nStep 3: Perform site reset to recover TL    console=${True}
    Reset Site And Wait For OnAir

Copy script on BTS and trigger fault 214

    ${output}    Run    sudo sshpass -p oZPS0POrRieRtu scp -p ${path_to_script} toor4nsn@192.168.255.129:${path}
    log to console    Copy script:${output}
    Sleep    5s

    should not contain    ${output}    No such file or directory

    SSH Connection

    ${out}    ssh.Execute  chmod +x ${path}script.py    connection=${alias}
    log to console    Give execution rights to script${out}
    log to console    Run the script to trigger fault 214:
    ${output1}   ssh.Execute    ${path}script.py
    log to console    Outout of running the script:${output1}
    Sleep   60s
    ${find_in_logs}    ssh.Execute    grep "Sending alarm for fault '214'" /tmp/startup_HWAPI.log  connection=${alias}
    log to console    Result of checking startup_HWAPI.log:${find_in_logs}

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
