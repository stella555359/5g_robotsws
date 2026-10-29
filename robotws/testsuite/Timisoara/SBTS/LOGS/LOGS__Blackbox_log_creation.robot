*** Settings ***
Documentation  Test Blackbox_log_creation
Resource    ../resources/unpacking.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pdu.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource   ../resources/ping_utils.robot
Library    OperatingSystem
Library    DateTime
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot

*** Variables ***
${SNAPSHOT_EXTRACTED}  ${FALSE}
${RESET_TYPE}
${RESET_DATE}
${BLACKBOX_INFO}
${MATCHES}
${check_blackbox_date}
${STARTUP_TIMEOUT}  10  # Timeout value in minutes after startup for all modules to reach working state.


*** Keywords ***
TC__LOGS__BlackBox
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-9199
    ...  ******************
    ...  Author: Lukasz Targonski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2018-02-20 - TC created. version 1.0
    ...  - 2018-04-06 - https://jira3.int.net.nokia.com/browse/TAT-9683 Bug fixed, unexpected error
    ...  - 2018-12-20 - https://jira3.int.net.nokia.com/browse/TAT-13739
    ...  - 2021-12-03 - https://jira3.ext.net.nokia.com/browse/TAT-22173 - Changes done due to CNI-61110
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 18.04.2023 - TAT-25131 - Mgration from hran_snapshot_analysis to taf.ul.verify_snapshot UL
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This Test Case checks if blackbox log file is correctly created
    ...  *******************
    ...  Test case flowchart: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Blackbox_log_creation.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com     PHASE-CRT    SW-SBTS17

    Should not be equal as strings  ${RESET_TYPE}  ${EMPTY}  msg=reset_type not provided. Set reset_type variable before run TC
    Step 0: Preconditions
    Step 1: Perform reset
    Step 2: Collect Snapshot
    Step 3: Find BlackBox
    Step 4: Wait for Fault clear

Step 0: Preconditions
    [Documentation]
    ...  In this step needed test variables are declared

    Log  \nPreconditions  console=${True}

    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

Step 1: Perform reset
    run keyword if  '${RESET_TYPE}'=='site_reset'  run keywords
    ...  set test variable  ${BLACKBOX_INFO}  User (Execute reset.)
    ...  AND  Site Reset
    run keyword if  '${RESET_TYPE}'=='power_reset'  run keywords
    ...  set test variable  ${BLACKBOX_INFO}  PowerOn reset
    ...  AND  Power Reset
    run keyword if  '${RESET_TYPE}'=='block_site'  run keywords
    ...  set test variable  ${BLACKBOX_INFO}  User (Execute reset.)
    ...  AND  Block site

Step 2: Collect Snapshot
    log  Step2: Trigger Snapshot  console=yes
    ${timestamp}  Get time
    ${timestamp}  replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    set test variable  ${timestamp}
    ${log_status}    run Keyword And Ignore Error  coam.Collect snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  timeout=1800
    run Keyword If  '${log_status[0]}'=='FAIL'
    ...    Fail  Collecting snapshot failed
    ...    ELSE
    ...    log  Full snapshot coverage collection is successfully collected  console=yes
    set Global Variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}.zip

Step 3: Find BlackBox
    log  Step3: Analyze Blackbox  console=yes
    ${snapshot_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot}
    set test variable  ${custom}  ${EMPTY}
    FOR  ${key}  IN  @{snapshot_dict.keys()}

        run keyword if  '${BTS_ID}'=='10823'    Set Test Variable    ${custom}    123D_
        ${MATCHES}  get regexp matches  ${snapshot_dict["${key}"][0]}  \\S+${custom}blackbox.xz

        run keyword if  ${MATCHES}  run keywords
        ...  log  Blackbox file: ${MATCHES[0]} found  console=yes
        ...  AND  set test variable  ${MATCHES}
        ...  AND  Extract log file
        ...  AND  Analyze log file
    END
    log  ${MATCHES}  console=yes
    run keyword unless  ${MATCHES}  fail  blackbox file not found

Step 4: Wait for Fault clear
    Wait Until Keyword Succeeds    10min    30s    coam.Assert alarm inactive    faultId=6202, severity=Critical

Extract log file
    [Documentation]
    ...  Keyword used to extract blackbox.log file from snapshot.
    ...  Only blackbox.log file that needed to be analyzed is extracted using this keyword.


    run keyword unless  ${SNAPSHOT_EXTRACTED}
    ...  unpacking.Unpack Archive Content To Directory  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}
    set test variable  ${SNAPSHOT_EXTRACTED}  ${TRUE}
    ${zip_from_extract}  get regexp matches  ${MATCHES[0]}  [\\w.]+
    ${log_to_extract}  replace string using regexp  ${zip_from_extract[0]}  (.zip)  ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}/${zip_from_extract[0]}  ${BTS_Files}/snapshot_${timestamp}${log_to_extract}
    unpacking.Unpack Archive Content To Directory  ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}  ${BTS_Files}/Blackbox

    ${unzipped_log_name}  replace string using regexp  ${zip_from_extract[1]}  (.xz)  ${EMPTY}
    set test variable  ${path_to_log_file}  ${BTS_Files}/Blackbox/${unzipped_log_name}

Analyze log file
    [Documentation]
    ...  Keyword used to analyze blackbox log. It is checked if date and text info in last line of the blackbox log file is correct.
    ...  If date or test message inside blackbox log is not correct, test case fails.

    ${date_in_logs}  OperatingSystem.get file  ${path_to_log_file}  encoding_errors=ignore
    ${current_year}  Get Time  return year
    ${number_of_entries}  get lines containing string  ${date_in_logs}  ${current_year}-
    ${last_line}  get line  ${number_of_entries}  -1
    set test variable  ${last_line}

    FOR  ${i}  IN RANGE  1  10
        Check Date
        exit for loop if  '${check_blackbox_date[0]}'=='PASS'
    END
    ${check_blackbox_info}  run keyword and ignore error  should contain  ${last_line}  ${BLACKBOX_INFO}
    run keyword unless  '${check_blackbox_info[0]}'=='PASS' and '${check_blackbox_date[0]}'=='PASS'  fail  bbox ${last_line} incorrect  console=yes
    run keyword if  '${check_blackbox_info[0]}'=='PASS' and '${check_blackbox_date[0]}'=='PASS'  pass execution  bbox${last_line} correct  console=yes


Site Reset
    Log  Step1: Perform BTS site reset  console=yes
    ${RESET_DATE}  DateTime.get current date  time_zone=UTC
    set test variable  ${RESET_DATE}
    coam.Reset Site  600
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes
    bts_states.Check Active Alarms

Power Reset
    Log  Step1: Perform BTS power reset  console=yes
    ${interfaces}  bts_states.Get Modules For Interfaces
    FOR  ${module_distname}  IN  @{interfaces}
        ${match}  run keyword and ignore error  should contain  ${module_distname}  SMOD_
        run keyword if  '${match[0]}'=='PASS'  run keywords
        ...  pdu.Pdu BTS Interface Off  ${module_distname}
        ...  AND  log  power on pdu interface ${module_distname} is turned OFF  console=yes
        ...  AND  sleep  1s
        ...  AND  pdu.Pdu BTS Interface On  ${module_distname}
        ...  AND  log  power on pdu interface ${module_distname} is turned ON  console=yes
    END
    ${RESET_DATE}  DateTime.get current date  time_zone=UTC
    set test variable  ${RESET_DATE}
    ping_utils.Wait For Target IP To Be Reachable    ${SMOD1['IP']}    10
    Sleep  180s
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes
    bts_states.Check Active Alarms

Block Site
    Log  Step1: Perform BTS block site  console=yes
    coam.Block  /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1  600
    ${RESET_DATE}  DateTime.get current date  time_zone=UTC
    set test variable  ${RESET_DATE}
    coam.Unblock  /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1  600
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes
    bts_states.Check Active Alarms


Check Date
    ${reset_date_mod}  replace string  ${RESET_DATE}  ${space}  T
    ${reset_date_mod}  get substring  ${reset_date_mod}  0  16
    ${check_blackbox_date}  run keyword and ignore error  should contain  ${last_line}  ${reset_date_mod}
    ${RESET_DATE}  DateTime.add time to date  ${RESET_DATE}  00:01:00.000
    set test variable  ${RESET_DATE}
    set test variable  ${check_blackbox_date}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
