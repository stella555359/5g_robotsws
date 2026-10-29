*** Settings ***
Library    OperatingSystem
Library    taf.ul.verify_snapshot  WITH NAME  snapshot
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/bts_states.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${STARTUP_TIMEOUT}        20
${SNAPSHOT_TIMEOUT}       1200

*** Keywords ***
TC__LOGS__CB008390_Snapshot_startup_Log_ERROR_prints
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-25486
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case created to verify mechanism of creating and moving postmortem files after reset.
    ...  According to feature CB008390, mechanism of collecting postmortem (startup, ERROR Log prints) files in Snapshot was changed.
    ...  After each reset, update, upgrade, rollback new post mortem file pm_1 file will be created.
    ...  Rest of the files will move to next number (pm_1 -> pm_2, pm_2 -> pm_3, pm_3 -> pm_4).
    ...  This rule is working up until file pm_4 will be created.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.06.2023 - TAT-25486 Initial Creation - Damian Kotula
    ...
    ...  *******************
    ...  Test case flowchart
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/raw/master/testsuite/SBTS/
    ...  LOGS__CB008390_Snapshot_startup_Log_ERROR_prints.png
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...   GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R3    FEATURE-CB008390

    Step 0: Preconditions
    Step 1: Collect Snapshot, Perform 2 Resets, Collect Snapshot
    Step 2: Unpack Snapshots And Compare Startup Log Error Prints


Step 0: Preconditions
    [Documentation]
    ...  In this step BTS ID from current BTS is set to variable.

    Log  \nStep 0: Preconditions  console=${True}
    ${bts_id}=  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

Step 1: Collect Snapshot, Perform 2 Resets, Collect Snapshot
    [Documentation]
    ...  In this step snapshot is collected, site reset is done twice and second snapshot is collected.

    Log  \nStep 1: Collect Snapshot, Perform 2 Resets, Collect Snapshot  console=${True}
    ${path_to_first_snapshot}  Collect Snapshot
    log  \nTwo site resets will be performed now  console=${True}
    Repeat Keyword  2 times  Reset Site And Wait For OnAir
    ${path_to_second_snapshot}  Collect Snapshot
    Set Test Variable  ${path_to_first_snapshot}
    Set Test Variable  ${path_to_second_snapshot}

Step 2: Unpack Snapshots And Compare Startup Log Error Prints
    [Documentation]
    ...  In this step postmortem files from both snapshots are unpacked. Mechanism of creating and moving postmortem files after reset is checked.
    ...  Content of PM_1 file from first snapshot, after two resets, should be in PM_3 file in second snapshot.
    ...  Content of PM_2 file from first snapshot, after two resets, should be in PM_4 file in second snapshot.

    Log  \nStep 2: Unpack Snapshots And Compare Startup Log Error Prints  console=${True}

    unpacking.Unpack Archive Content To Directory  ${path_to_first_snapshot}  ${BTS Files}/First_Snapshot_Unpacked
    unpacking.Unpack Archive Content To Directory  ${path_to_second_snapshot}  ${BTS Files}/Second_Snapshot_Unpacked
    Compare Files From MSM
    ${is_it_dualcore}=  Run Keyword And Return Status  Variable Should Exist  ${SMOD2}
    Run Keyword If  ${is_it_dualcore}  Compare Files From ESM

Collect Snapshot
    [Documentation]
    ...  This keyword is used to collect snapshot
    @{time}=  Get Time  year month day hour min
    ${snapshot_status}=  Run Keyword And Return Status
    ...  coam.Collect Snapshot  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  ${snapshot_status}
    ...  Log  Collecting snapshot succeeded  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Collecting snapshot has failed  ${True}
    ${path_to_snapshot}=  Set Variable  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip
    [Return]  ${path_to_snapshot}

Reset Site And Wait For OnAir
    [Documentation]
    ...  This keyword performs site reset and waits until bts is back OnAir
    coam.Reset Site
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  1m  Check All Modules And All Cells Working States
    log  \nReset complete  console=${True}

Find And Unpack File
    [Documentation]
    ...  This keyword is used to find specified file in snapshot and unpack it until runtime_SYSTEM.log
    ...  Works only for Runtime and PostMortem files.
    ...  Filename to unpack, snapshot path and output path are needed as argument.
    ...  Size of PM file and content of unpacked runtime_SYSTEM.log are returned from keyword.
    [Arguments]  ${filename}  ${snapshot_path}  ${unpacked_snapshot_path}
    ${Snapshot_dict}=  snapshot.Get Data From Snapshot  ${snapshot_path}
    ${file_entry_from_snapshot_dictionary}=  Set Variable  ${Snapshot_dict}[${filename}]
    ${file_container_and_file_name}=  Get From List  ${file_entry_from_snapshot_dictionary}  0
    ${File_container}=  Fetch From Left  ${file_container_and_file_name}  /

    unpacking.Unpack Archive Content To Directory  ${unpacked_snapshot_path}/${File_container}
    ...  ${unpacked_snapshot_path}/${File_container}_unpacked
    unpacking.Unpack Archive Content To Directory  ${unpacked_snapshot_path}/${File_container}_unpacked/${filename}
    ...  ${unpacked_snapshot_path}/${filename}_unzipped
    unpacking.Unpack Archive Content To Directory  ${unpacked_snapshot_path}/${filename}_unzipped/runtime_SYSTEM.log.xz
    ...  ${unpacked_snapshot_path}/${filename}_unpacked
    ${runtime_SYSTEM_file_path}=  Set Variable  ${unpacked_snapshot_path}/${filename}_unpacked/runtime_SYSTEM.log
    ${runtime_SYSTEM_file}=  OperatingSystem.Get File  ${runtime_SYSTEM_file_path}
    ${PM_filesize}=  OperatingSystem.Get File Size  ${unpacked_snapshot_path}/${File_container}_unpacked/${filename}
    [Return]  ${runtime_SYSTEM_file}  ${PM_filesize}

Compare Files From MSM
    [Documentation]
    ...  This keyword is used to check if 1011_pm_1 file content moved to 1011_pm_3 file and
    ...  1011_pm_2 file content moved to 1011_pm_4 file after two resets.

    ${1011_pm_1_runtime}  ${1011_pm_1_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_1_syslog.zip  ${path_to_first_snapshot}  ${BTS Files}/First_Snapshot_Unpacked
    ${1011_pm_2_runtime}  ${1011_pm_2_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_2_syslog.zip  ${path_to_first_snapshot}  ${BTS Files}/First_Snapshot_Unpacked
    ${1011_pm_3_runtime}  ${1011_pm_3_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_3_syslog.zip  ${path_to_second_snapshot}  ${BTS Files}/Second_Snapshot_Unpacked
    ${1011_pm_4_runtime}  ${1011_pm_4_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_1011_pm_4_syslog.zip  ${path_to_second_snapshot}  ${BTS Files}/Second_Snapshot_Unpacked

    Should Be Equal  ${1011_pm_1_runtime}  ${1011_pm_3_runtime}
    Should Be Equal  ${1011_pm_2_runtime}  ${1011_pm_4_runtime}
    Should Be Equal As Integers  ${1011_pm_1_filesize}  ${1011_pm_3_filesize}
    Should Be Equal As Integers  ${1011_pm_2_filesize}  ${1011_pm_4_filesize}

Compare Files From ESM
    [Documentation]
    ...  This keyword is used to check if 2011_pm_1 file content moved to 2011_pm_3 file and
    ...  2011_pm_2 file content moved to 2011_pm_4 file after two resets.

    ${2011_pm_1_runtime}  ${2011_pm_1_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_2011_pm_1_syslog.zip  ${path_to_first_snapshot}  ${BTS Files}/First_Snapshot_Unpacked
    ${2011_pm_2_runtime}  ${2011_pm_2_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_2011_pm_2_syslog.zip  ${path_to_first_snapshot}  ${BTS Files}/First_Snapshot_Unpacked
    ${2011_pm_3_runtime}  ${2011_pm_3_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_2011_pm_3_syslog.zip  ${path_to_second_snapshot}  ${BTS Files}/Second_Snapshot_Unpacked
    ${2011_pm_4_runtime}  ${2011_pm_4_filesize}  Find And Unpack File
    ...  BTS${BTS_ID}_2011_pm_4_syslog.zip  ${path_to_second_snapshot}  ${BTS Files}/Second_Snapshot_Unpacked

    Should Be Equal  ${2011_pm_1_runtime}  ${2011_pm_3_runtime}
    Should Be Equal  ${2011_pm_2_runtime}  ${2011_pm_4_runtime}
    Should Be Equal As Integers  ${2011_pm_1_filesize}  ${2011_pm_3_filesize}
    Should Be Equal As Integers  ${2011_pm_2_filesize}  ${2011_pm_4_filesize}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...  interface.Common step trigger
    ...  AND  Setup Scout And Send Configuration
    ...  AND  Common Test Teardown
