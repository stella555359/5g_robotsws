*** Settings ***
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Library    taf.transport.ssh  WITH NAME  ssh
Resource   ../resources/pm_logs_frame.robot
Resource   ../resources/pm_logs_general.robot
Resource    ../resources/ssh_utils.robot
Resource   ../resources/verdicts.robot
Resource   taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}    900

*** Keywords ***
TC__LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25493
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Refactored from the test /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM/CB008626
    ...  The purpose of this Test Case is to check .
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25493 - Initial creation
    ...  - 20.12.2023 - TAT-25493 Test refactor
    ...  - 19.04.2024 - Final TC version
    ...

    Set Tags    CA-LOGS    AUTHOR-rafal.sytyk@nokia.com    MAINTAINER-iuliia.taupeka@nokia.com
    ...        GROUP_IN_CHARGE-WRO_6_Vrf    SW-SBTS23R4    FEATURE-CB008626


    Step 1: Collect Snapshot With FullWithoutRFLogs Coverage
    Step 2: Validate Snapshot

Step 1: Collect Snapshot With FullWithoutRFLogs Coverage
    [Documentation]
    ...    In this step Snapshot (local) is collected with FullWithoutRFLogs Coverage
    Log    \nStep 1: Collect Snapshot With FullWithoutRFLogs Coverage    console=${True}
    @{time}=    Get Time    year month day hour min
    ${snapshot_path}    Set Variable    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${snapshot_path}  coverage=FullWithoutRFLogs  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}
    Run Keyword If    ${snapshot_status}    Run Keywords
    ...    Log    Collecting snapshot via admin succeeded  console=${True}
    ...    AND    Set Test Variable    ${snapshot_path}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}
    Log    Checking if there are no unexpected alarms raised during Snapshot collection.  console=${True}
    pm_logs_general.Check Unexpected Active And Historical Alarms

Step 2: Validate Snapshot
    [Documentation]
    ...    In this step is validated that collected Snapshot doesn't contain any RMOD logs.
    Log    \nStep 2: Validate Snapshot    console=${True}
    ${found_file_dict}   snapshot.Get Data From Snapshot  ${snapshot_path}
    ${found_RMOD_log_file}    Get Match Count    ${found_file_dict.keys()}    regexp=BTS_.*RMOD.*
    Log     Number of found RMOD files: ${found_RMOD_log_file}    console=${True}
    Run Keyword If    ${found_RMOD_log_file}!=0
    ...   verdicts.Set Test Failed  Test is failed. RMOD log files found in Snapshot.  ${TRUE}
    ...   ELSE   Log   Snapshot doesn't contain any RMOD Log Files   console=${True}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
