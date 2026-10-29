*** Settings ***
Documentation
...   Generic Pre_condition quantifiable keywords for a test case.

Resource    ./alarm.robot
Resource    ./Testline/gnb.robot
Library     String
Library     Collections
Library     ./Python/utilities.py

*** Variables ***
${INITIAL_CORE_FILES_LIST}        ${EMPTY}
${INITIAL_CRITICAL_ALARM_LIST}    ${EMPTY}

*** Keywords ***
Get Critical Alarms Before Test
    [Arguments]    ${alias}=OAM
    [Documentation]  	 This Keyword helps in getting the alarms that are not present in the first list of alarms
    ...                  Modified Date: 17-12-2019
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    ...                  The Keyword takes the connection alias as argument and sets the initial set of alarms
    ...                  as Global Variable.
    ...                  | ${alias} | The connection alias used for connecting to the gNB |
    ...                  ${INITIAL_CRITICAL_ALARM_LIST} This is the global variable which is used for storing the
    ...                  initial list of alarms.
    ${INITIAL_CRITICAL_ALARM_LIST}    Get Critical Alarm List From Admin    alias=${alias}
    Set Global Variable    ${INITIAL_CRITICAL_ALARM_LIST}

Get Core Files List Before Test
    [Arguments]    ${gnb_id}=0
    [Documentation]  	 This Keyword helps in getting the core files present in the system before the Test and
    ...                  initializing to a global variable.
    ...                  Modified Date: 24-01-2020
    ...                  Original by: gopalakrishnan.n@nokia.com
    ...                  Last Modified by: grzegorz.kaczor@nokia.com
    ...                  The Keyword takes the connection alias as argument and sets the core files present int the
    ...                  system as Global Variable ${INITIAL_CORE_FILES_LIST}.
    ...                  | ${gnb_id} | Id of the gNB from the tl, counting from 0 to collect core files from |
    ...                  ${INITIAL_CORE_FILES_LIST} This is the global variable which is used for storing the
    ...                  initial list of core files present in the system.
    ${INITIAL_CORE_FILES_LIST}    Get Core Files List From gNB    gnb_id=${gnb_id}
    Set Global Variable    ${INITIAL_CORE_FILES_LIST}
