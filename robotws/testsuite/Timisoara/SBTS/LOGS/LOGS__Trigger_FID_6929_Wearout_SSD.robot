*** Settings ***
Library    SSHLibrary
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/ssh_utils.robot
Resource    ../resources/ping_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***

*** Keywords ***
TC__LOGS__Trigger_FID_6929_Wearout_SSD
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25182
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Step1: Check if change in /run/ssd-status-sda.dat file - SPARE_AVAIL_PERCENT=5.00 triggers FID:6929
    ...  Step2: Check if change in /run/ssd-status-sda.dat file - SMART_STATUS=0 triggers FID:6929
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2023-04-05 - TAT-25182 - BOAM_ET TC transfer
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/LOGS__Trigger_FID_6929_SSD_Wearout.png

    Set Tags    CA-PM    OWNER-mateusz.majkusiak@nokia.com    AUTHOR-mateusz.majkusiak@nokia.com
    ...    MAINTAINER-mateusz.majkusiak@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CIT    SW-SBTS23R3    FEATURE-CNI83747

    Step 1: Trigger FID:6929 By Updating SPARE_AVAIL_PERCENT Parameter
    Step 2: Trigger FID:6929 By Updating SMART_STATUS Parameter

Step 1: Trigger FID:6929 By Updating SPARE_AVAIL_PERCENT Parameter
    [Documentation]
    ...    KW checks content of /run/ssd-status-sda.dat file and update SPARE_AVAIL_PERCENT parameter to 5.00.
    ...    This change should cause FID:6929 raising
    ${content}=    Get SSD status
    ${modified}=    Modify current ssd spare available percent  ${content}
    Trigger SSD Wearout fault    ${modified}

Step 2: Trigger FID:6929 By Updating SMART_STATUS Parameter
    [Documentation]
    ...    KW checks content of /run/ssd-status-sda.dat file and update SMART_STATUS parameter to 0.
    ...    This change should cause FID:6929 raising
    ${content}=    Get SSD status
    ${modified}=    Modify smart status   ${content}
    Trigger SSD Wearout fault    ${modified}

Get SSD status
    [Documentation]
    ...    This KW checks if BTS is in one of the following Procedural States: Configured Commissioned IntegratedToRan OnAir
    ...    and save content of /run/ssd-status-sda.dat used by other KW
    [Arguments]    ${timeout}=360  ${port}=22
    bts_states.Get BTS Procedural State
    ${bts_acceptable_states}    Set Variable    Configured Commissioned IntegratedToRan OnAir
    Should Contain    ${bts_acceptable_states}  ${bts_procedural_state}
    coam.Reset Site    timeout=${timeout}  wait_for_reconnection=${True}  connection=${connection}
    Wait Until Keyword Succeeds  200  30  ping_utils.Check If Target IP Is Reachable  ${msm_ip}
    Sleep    60s
    SSHLibrary.Open Connection    host=${msm_ip}  port=${port}  timeout=60
    SSHLibrary.Login    username=${user_name}  password=${password}  delay=1s
    ${cmd_return}=    SSHLibrary.Execute Command  cat /run/ssd-status-sda.dat

    [Return]     ${cmd_return}

Modify current SSD spare available percent
    [Documentation]
    ...    This KW modify the number of spare blocks in SSD disk to 5.00 percent.
    ...    According to requirement for CNI-83747 should be < 10% to raise FID:6929
    [Arguments]    ${content}
    ${modified}=    Replace String Using Regexp  ${content}  SPARE_AVAIL_PERCENT=[0-9]*.[0-9]*
    ...    SPARE_AVAIL_PERCENT=5.00
    Log    Parameter SPARE_AVAIL_PERCENT from /run/ssd-status-sda.dat file changed  console=${True}

    [Return]    ${modified}

Modify smart status
    [Documentation]
    ...    This KW modify the wearout level indicator SMART to 0.
    ...    According to requirement for CNI-83747 should be 0 to raise FID:6929
    [Arguments]    ${content}
    ${modified}=    Replace String Using Regexp  ${content}  SMART_STATUS=1  SMART_STATUS=0
    Log    Parameter SMART_STATUS from /run/ssd-status-sda.dat file changed  console=${True}

    [Return]    ${modified}

Trigger SSD Wearout fault
    [Documentation]
    ...    This KW takes content of ${modified} variable and triggers the FID:6929 and verifies fault presence from raw alarm history
    [Arguments]    ${modified}
    Run Keywords    SSHLibrary.Write  echo -n "${modified}" > /tmp/fake_ssd.dat
    ...    AND    SSHLibrary.Write  mount -o bind /tmp/fake_ssd.dat /run/ssd-status-sda.dat
    SSHLibrary.Close Connection
    Sleep    60s
    Wait Until Keyword Succeeds    600  5  Check if fault is in active raw alarm  6929  EFaultId_SsdWearoutAl

Check if fault is in active raw alarm
    [Documentation]
    ...    This KW checks if FID:6929 is in active raw alarm history file
    [Arguments]    ${fault_id}    ${EFaultId}
    ${RawAlarms}=     coam.Get Raw Alarm History File
    ${RawAlamrsActive}=    Fetch From Left  ${RawAlarms}  Inactive faults
    Should contain    ${RawAlamrsActive}  (${fault_id})
    Should contain    ${RawAlamrsActive}  ${EFaultId}

Custom Test Teardown
    Log    Custom Test Teardown  console=${True}
    coam.Reset Site    600
    Wait until keyword succeeds    12m  2m  Verify BTS states

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
