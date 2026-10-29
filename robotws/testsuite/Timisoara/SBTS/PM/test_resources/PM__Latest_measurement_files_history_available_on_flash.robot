*** Settings ***
Documentation
    ...  Purpose of this test case is to check correctness of PM files history available on BTS.
    ...  Step1: Get BTS Uptime And Wait Until 24h If Needed
    ...   - BTS Uptime is Calculated.
    ...   - It is waited till 24h if Uptime is less.
    ...  Step2: Download All PM XML Files From BTS And Verify If Amount Is Correct
    ...   - All available PM files are downloaded from BTS and stored locally.
    ...   - Verify if amount of PM files is correct.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${COLLECT_SCF_FILE_TIMEOUT}  60


*** Keywords ***
TC__PM__Latest_measurement_files_history_available_on_flash
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29103 - Update testcases and resourses for CB011146
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters
    ...  ******************


    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-iuliia.taupeka@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT

    Step1: Get BTS Uptime And Wait Until 24h If Needed
    Step2: Download All PM XML Files From BTS And Verify If Amount Is Correct


Step1: Get BTS Uptime And Wait Until 24h If Needed
    Log  \n----- Step1: Get BTS Uptime And Wait Until 24h On Air If Needed ----- \n  console=true
    ssh.Connect To  hostname=${OAM_BTS_IP}  username=toor4nsn  password=oZPS0POrRieRtu
    ${bts_uptime_sec}  ssh.Execute  awk '{print int($1)}' /proc/uptime
    ssh.Disconnect
    Log  BTS Uptime in seconds is ${bts_uptime_sec}.  console=true
    ${24h_in_sec}  Set Variable  ${86400}
    IF  ${24h_in_sec} > ${bts_uptime_sec}
      Evaluate Waiting Time And Wait Timer  ${bts_uptime_sec}
    ELSE
      Log  Uptime is grater than 24h. Amount of PM files will be checked in next step.\n  console=true
    END


Step2: Download All PM XML Files From BTS And Verify If Amount Is Correct
    Log  \n----- Step2: Download All PM XML Files From BTS And Verify If Amount Is Correct----- \n  console=true
    ${current_reporting_interval}  Get Reporting Interval From BTS
    ${expected_num_of_files}  Calculate Expected Number Of PM Files  ${current_reporting_interval}
    ${path_to_saved_pm_files}  Set Variable  ${BTS_FILES}/All_PM_xml_files/
    Get Pm XML Files From BTS  ${path_to_saved_pm_files}
    ${xml_files_list_from_bts}  OperatingSystem.List Directory  ${path_to_saved_pm_files}
    ${number_of_files}  Get Length  ${xml_files_list_from_bts}
    Log  There is ${number_of_files} files on BTS.\n  console=true
    Check If Amount Of Files Is Equal To Expected  ${number_of_files}  ${expected_num_of_files}  ${xml_files_list_from_bts}


Check If Amount Of Files Is Equal To Expected
    [Documentation]
    ...  This keyword verifies if amount of PM files on BTS is equal to expected.
    ...  If not, test is set to failed.
    ...  Keyword takes 3 variables: number of present files; number of expected files; list of present files.
    [Arguments]  ${number_of_files}  ${expected_num_of_files}  ${files_list}

    ${status}  Run Keyword And Return Status  Should Be Equal  ${number_of_files}  ${expected_num_of_files}
    IF  ${status}
      Log  Number of PM files on BTS is correct (${number_of_files} files).  console=true
    ELSE
      Set Test Failed
      ...  The number of files (${number_of_files}) differs from expected one (${expected_num_of_files}).\nList of available PM files: ${files_list}
    END


Get Reporting Interval From BTS
    [Documentation]
    ...  This keyword gets and returns current reporting interval from BTS (as integer number in minutes).

    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  with_auto_configured_parameters=${TRUE}  timeout=${COLLECT_SCF_FILE_TIMEOUT}
    Setup Pm  scf_path=${BTS_FILES}/scf.xml
    ${reporting_interval}  Get Reporting Interval
    ${reporting_interval}  Evaluate  int(${reporting_interval}/60)
    Log  Current reporting interval = ${reporting_interval} min.  console=true
    ${type_of}  Evaluate  type(${reporting_interval})

    [Teardown]  Teardown Pm
    RETURN  ${reporting_interval}


Evaluate Waiting Time And Wait Timer
    [Documentation]
    ...  This keyword takes BTS uptime as input, calculates how long to wait till BTS will be running for 24h and waits.
    [Arguments]  ${uptime}

    ${waiting_time}  Evaluate  86400 - ${uptime}
    Log  BTS Uptime is less than 24h. Waiting ${waiting_time} s...  console=true
    Sleep  ${waiting_time}s  reason=BTS Uptime is less than 24h. Waiting ${waiting_time} s...


Calculate Expected Number Of PM Files
    [Documentation]
    ...  Keyword takes current reporting interval as input; calculates and returns as output expected number of PM files.
    [Arguments]  ${reporting_interval}

    ${expected_num_of_files}  Evaluate  1440/${reporting_interval}
    Log  Expected number of PM result files on BTS is ${expected_num_of_files}.  console=true

    RETURN  ${expected_num_of_files}


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown