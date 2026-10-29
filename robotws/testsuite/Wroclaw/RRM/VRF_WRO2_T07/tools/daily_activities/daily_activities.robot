*** Settings ***
Documentation    Performs a set of common operations for exploratory testing purposes
...   maintainer: Bartosz Kozlowski
...   contact: bartosz.1.kozlowski@nokia.com

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/tools/daily_activities/resources/daily_activities_keywords.robot

Suite Setup    Setup Test Variables

Test Setup     Start Syslog
Test Teardown   Run keywords
...             Stop And Verify Syslog                AND
...             Run Keyword if  ${SYSLOG_CLEANUP}     Create file with filtered prints for syslog cleanup   ${ERR_WARN}    AND
...             Check for active alarms   ${ommitted_alarms}            AND
...             Run Keyword If Test Failed            Collect Snapshot


*** Variables ***
${target_sw_version}        SBTS00_ENB_9999_250227_000009    #example: SBTS00_ENB_9999_240403_000001
${remote_vm_ip}             ${None}
@{counters}                 M55305C00001   M55316C00001   M55310C10001  M55300C00001  M55302C00001
...                         M55308C00001   M55306C00001   M55127C00001  M55115C00002  M55139C00001
@{counter_params}           miNrBeamforming     miNrCaDu    miNrLowRlcReport    miNrDlHarq    miNrUlHarq
...                         miNrCellUtilization    miNrRachUsage   miNrRRCD   miNrRacDu    miNrRSADU
@{ommitted_alarms}          No X2 link available for a specific LTEENB    No X2 link available      #alarms to be ommitted
${SYSLOG_CLEANUP}           False      #Change the value True/False to check for ERR/WRN prints in syslog (syslog cleanup)
${ERR_WARN}                "ERR/|WRN/"    #Change to WRN/ to find only Warnings

*** Test Cases ***
DAILY_ACTIVITIES_UPGRADE_SW_BUILD
    [Setup]    Backup SCF    ${OUTPUT DIR}/BeforeUpdateSCF
               Start Syslog
    Download Software And Perform Upgrade
    ...            target_sw_version=${target_sw_version}

DAILY_ACTIVITIES_SW_ROLLBACK
    Rollback Software
    Download Software And Perform Upgrade
    ...            target_sw_version=${target_sw_version}

DAILY_ACTIVITIES_CELL_BLOCK_UNBLOCK
    Perform Cell Block Unblock

DAILY_ACTIVITIES_RU_LOCK_UNLOCK
    Perform RU Lock Unlock

DAILY_ACTIVITIES_RAT_RESETS
    Perform RAT Resets

DAILY_ACTIVITIES_BBMOD_RESETS
    Perform BBMOD Resets

DAILY_ACTIVITIES_SITE_RESET
    Perform Site Reset

DAILY_ACTIVITIES_SITE_BLOCK_AND_RESET
    Perform Site Block and Reset

DAILY_ACTIVITES_RANDOM_ACTIVITES
    Perform Random Activities

DAILY_ACTIVITES_POWER_RESET_VIA_WEBEM
    Perform Power reset

DAILY_ACTIVITIES_COUNTERS_CHECK
    [Setup]    Backup SCF    ${OUTPUT DIR}/BeforeCounterCheckSCF
    Perform Counters Check    ${counters}   ${counter_params}
    [Teardown]      Run Keywords
    ...      Revert SCF   ${OUTPUT DIR}/BeforeCounterCheckSCF/scf.xml    AND
    ...      Run Keyword If Test Failed    Collect Snapshot
