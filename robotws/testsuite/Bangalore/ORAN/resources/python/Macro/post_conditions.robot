*** Settings ***
Documentation
...   Generic Post condition quantifiable keywords for a test case.

Resource    ./alarm.robot

*** Keywords ***
Check Critical Alarms At End Of Test
    [Arguments]    ${alias}=OAM
    [Documentation]  	 This Keyword helps in getting the alarms that are present in the system after the Test and
    ...                  compares it to the Global Variable and raises a WARNING msg if there is any new alarms.
    ...                  Modified Date: 17-12-2019
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    ...                  The Keyword takes the connection alias as argument and sets the initial set of alarms
    ...                  as Global Variable.
    ...                  | ${alias} | The connection alias used for connecting to the gNB |
    ...                  ${INITIAL_CRITICAL_ALARM_LIST} This is the global variable which is used for storing the
    ...                  initial list of alarms.
    ${new_critical_alarm_list}    Get Critical Alarm List From Admin    alias=${alias}
    ${new_alarms}    Get List of New Alarms Raised    ${INITIAL_CRITICAL_ALARM_LIST}    ${new_critical_alarm_list}
    ${warn_status}    Run Keyword And Return Status    Should Not Be Empty    ${new_alarms}
    Run Keyword If    ${warn_status}    Log    New Critical Alarms Raised : ${new_alarms}    level=WARN

Get Core Files List After Test
    [Arguments]    ${gnb_id}=0
    [Documentation]  	 This Keyword helps in getting the core files present in the system after the Test and
    ...                  compares it to the Global Variable and raises a WARNING msg if there is any new files.
    ...                  Modified Date: 24-01-2020
    ...                  Original by: gopalakrishnan.n@nokia.com
    ...                  Last Modified by: grzegorz.kaczor@nokia.com
    ...                  The Keyword takes the connection alias as argument and compares the core files present in the
   ...                   system to the Global Variable ${INITIAL_CORE_FILES_LIST}.
    ...                  | ${gnb_id} | Id of the gNB from the tl, counting from 0 to collect core files from |
    ...                  ${INITIAL_CORE_FILES_LIST} This is the global variable which is used for storing the
    ...                  initial list of core files present in the system.
    ${core_files_list}    Get Core Files List From gNB    gnb_id=${gnb_id}
    ${new_core_files}    Get Difference Between Lists   ${INITIAL_CORE_FILES_LIST}     ${core_files_list}
    ${warn_status}    Run Keyword And Return Status    Should Not Be Empty    ${New_core_files}
    Run Keyword If    ${warn_status}    Log    New Core files are generated : ${New_core_files}    level=WARN
