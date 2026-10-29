*** Settings ***
Resource    ../resources/unpacking.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     OperatingSystem
Library     DateTime
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot

*** Variables ***
${STARTUP_TIMEOUT}  10  # Timeout value in minutes after startup for all modules to reach working state.
${CLOCK_SYNCHRONIZATION_TIMEOUT}  3  # Timeout in minutes for clock to synchronize and propagate current time to all modules.
${BOARD_REGEXP}=    SEPARATOR=
    ...  (1011|2011|120D|130D|140D|220D|230D|240D|123D|124D|125D|126D|132D|133D|134D|135D|136D|142D|143D|144D|145D|146D|223D|224D|225D|226D|232D
    ...  |233D|234D|235D|236D|242D|243D|244D|245D|246D)

*** Keywords ***
TC__LOGS__Clock_Time_Managment
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7531
    ...  ******************
    ...  Author: Lukasz Targonski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2017-08-14 - TC created. version 1.0
    ...  - 2018-06-12 - TAT-10204 https://jira3.int.net.nokia.com/browse/TAT-10204
    ...  - 2018-08-17 - TAT-11142 https://jira3.int.net.nokia.com/browse/TAT-11142
    ...  - 2018-12-13 - TAT-13617 https://jira3.int.net.nokia.com/browse/TAT-13617
    ...  - 2018-12-20 - https://jira3.int.net.nokia.com/browse/TAT-13739
    ...  - 2019-04-08 - https://jira3.int.net.nokia.com/browse/TAT-15566
    ...  - 2021-12-04 - https://jira3.ext.net.nokia.com/browse/TAT-22173 - Changes done due to CNI-61110
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 20.04.2023 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This Test Case checks if time is correct in runtime logs
    ...  *******************
    ...  Test case flowchart: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Clock_Time_Managment.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com   GROUP_IN_CHARGE-WRO_6_Vrf  PHASE-CRT    SW-SBTS17

    Step 1: Site reset
    Step 2: Collect Snapshot
    Step 3: Analyze Snapshot


Step 1: Site reset
    log  Step1: Perform BTS site reset  console=yes

    Set Test Variable  ${SNAPSHOT_EXTRACTED}  ${FALSE}
    Set Test Variable  ${VERDICT}  ${TRUE}

    coam.Reset Site  600
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All SMODs And RMODs States
    Log  All modules reached working state  console=yes
    bts_states.Check Active Alarms
    log  Wait ${CLOCK_SYNCHRONIZATION_TIMEOUT} min for clock to synchronize.  console=yes
    sleep  ${CLOCK_SYNCHRONIZATION_TIMEOUT}m

Step 2: Collect Snapshot
    log  Step2: Snapshot is being triggered  console=yes
    ${timestamp}  Get time
    ${timestamp}  replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    set test variable  ${timestamp}
    ${log_status}    run Keyword And Ignore Error  coam.Collect Snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  timeout=1800
    Run Keyword If  '${log_status[0]}'=='FAIL'
    ...    Fail  Collecting snapshot failed
    ...    ELSE
    ...    log  Full snapshot coverage collection is successfully collected  console=yes
    set Global Variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}.zip

Step 3: Analyze Snapshot
    [Documentation]
    ...  In this step Snapshot file is being analyzed. Startup logs from RF modules and FSPa are being extracted (using extract log file)
    ...  and analyzed (using Analyze log file keyword)

    log  Step3: Runtime logs from SM/BB Extensions/RF Modules are being analyzed  console=yes
    ${snapshot_dict}    snapshot.get data from snapshot    ${path_to_snapshot}
    set test variable  @{incorrect_logs}  ${EMPTY}
    FOR  ${key}  IN  @{snapshot_dict.keys()}
      ${matches_temp}  get regexp matches  ${key}  ^((?!FSP).)*runtime.zip
      ${matches}  get regexp matches  ${snapshot_dict["${key}"][0]}  ^((?!FSP).)*runtime.zip
      Run Keyword If  ${matches_temp}  run keywords
      ...  set test variable  ${matches}
      ...  AND  log  log file: ${matches[0]} is being extracted  console=yes
      ...  AND  Extract log file
      ...  AND  log  file: ${matches[0]} is being analyzed  console=yes
      ...  AND  Analyze log file
    END
    sleep  1s
    FOR  ${i}  IN  @{incorrect_logs}
      Run Keyword If  '${i}'!='${EMPTY}'  log  runtime logs in: ${i} with incorrect time  level=ERROR  console=yes
    END
    run keyword unless  ${VERDICT}  Fail  Time in log(s) not correct

Verify sm and rf states
    ${stateInfo}  Set Variable  stateInfo.administrativeState=Unlocked, stateInfo.blockingState=Unblocked, stateInfo.operationalState=Enabled
    ${sm_state}  query infomodel
    ...  every //BTS_L-*/LNBTS-* is [${stateInfo}]  allow_negative_result=${TRUE}
    ${rf_state}  query infomodel  every ${dist_radio}/RU_L-* is [${stateInfo}]  allow_negative_result=${TRUE}
    ${are_states_as_expected}  evaluate  ${sm_state} and ${rf_state}
    Run Keyword If  ${are_states_as_expected}  log  All states of BTS and RF modules are as expected.  console=${TRUE}
    ...  ELSE  Fail  At least one module has state other than expected.

Extract log file
    [Documentation]
    ...  Keyword used to extract runtime.log (from RF mdule) or runtime_DEFAULT.log (from FSP) file from snapshot.
    ...  Only files that needed to be analyzed are extracted using this keyword.
    ...  FOR loop is used to extract runtime files from RF modules and additional Unpack Archive Content To Directory
    ...  keyword below that FOR loop is used
    ...  to extract runtime files from FSP boards (as they are additionally archived inside .xz files inside snapshot)

    run keyword unless  ${SNAPSHOT_EXTRACTED}
    ...  unpacking.Unpack Archive Content To Directory  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}
    ${zip_from_extract}  get regexp matches  ${matches[0]}  [^\/].[^\/]+
    set test variable  ${SNAPSHOT_EXTRACTED}  ${TRUE}
    ${zip}  set variable  ${EMPTY}
    FOR  ${i}  IN  @{zip_from_extract}
      ${zip}  catenate  SEPARATOR=/  ${zip}  ${i}
      ${extract_log}  replace string using regexp  ${zip}  (.zip)  ${EMPTY}
      ${dir_exists}  run keyword and ignore error  OperatingSystem.directory should not exist  ${BTS_Files}/snapshot_${timestamp}${extract_log}
      Run Keyword If  '${dir_exists[0]}'=='PASS'
      ...  unpacking.Unpack Archive Content To Directory  ${BTS_Files}/snapshot_${timestamp}${zip}  ${BTS_Files}/snapshot_${timestamp}${extract_log}
      ${dir_content}  OperatingSystem.List Files In Directory  ${BTS_Files}/snapshot_${timestamp}${extract_log}
      ${runtime_default_log_exists}  Run Keyword And Ignore Error  Should Contain  ${dir_content}  runtime_DEFAULT.log.xz
      Run Keyword If  '${runtime_default_log_exists[0]}'=='PASS'  Run Keywords
      ...  unpacking.Unpack Archive Content To Directory
      ...  ${BTS_Files}/snapshot_${timestamp}${extract_log}/runtime_DEFAULT.log.xz  ${BTS_Files}/snapshot_${timestamp}${extract_log}/runtime_DEFAULT
      ...  AND  Set Test Variable  ${path_to_log_file}  ${BTS_Files}/snapshot_${timestamp}${extract_log}/runtime_DEFAULT/runtime_DEFAULT.log
      ...  ELSE  Set Test Variable  ${path_to_log_file}  ${BTS_Files}/snapshot_${timestamp}${extract_log}/runtime.log
      ${zip}  Set Variable  ${extract_log}
    END
    ${zip}=  Set Variable  ${EMPTY}
    Set Test Variable  ${extract_log}

Analyze log file
    [Documentation]
    ...  Keyword used to to analyze runtime log. It is checked if date in those logs is the same as the current date.
    ...  It is checked if date_in_logs contains current_date (UTC date).
    ...  If any of the analyzed log file is not in line with the current_date (UTC date) than VERDICT is set to false
    ...  and overall test case VERDICT is Failed

    ${current_date}  DateTime.get current date  time_zone=UTC
    ${current_date}  get regexp matches  ${current_date}  ^\\S{,10}
    ${date_in_logs}  OperatingSystem.get file  ${path_to_log_file}  encoding_errors=ignore
    ${date_in_logs}  run keyword and ignore error  should contain  ${date_in_logs}  ${current_date[0]}
    Run Keyword If  '${date_in_logs[0]}'=='FAIL'  run keywords
    ...  set test variable  ${VERDICT}  ${FALSE}
    ...  AND  append to list  ${incorrect_logs}  ${path_to_log_file}
    ...  ELSE  log  runtime logs in ${path_to_log_file} with correct time  console=yes


TC Setup
    Common Test Setup    modules_check=${FALSE}    cells_check=${FALSE}    scf_check=${FALSE}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown    collect_snapshot=never
