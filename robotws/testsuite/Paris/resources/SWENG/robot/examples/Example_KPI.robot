*** Settings ***
Documentation
...          Just an exemple about how to use the KPI tool

Resource                            ../Tools.robot
Resource                            ../Connect.robot
Resource                            ../KPIs.robot
Resource                            ../Setup.robot
Resource                            ../Counters.robot
Library                             ../../python/StringTool.py
Library                             ../../python/OsTool.py

Suite Setup                         Suite Setup

*** Variables ***
${CONSTRAINTS_PATH}                 ${CURDIR}/config/KPI/constraints
${CONSTRAINTS_FILE}                 ${CONSTRAINTS_PATH}/SetupEndur.csv
${PM_FILE}                          ${CONSTRAINTS_PATH}/PM.BTS-1.20220618.113000.ANY.xml
*** Test Cases ***
Test ZOI
    Dated log                       START
    ${zoi}                          ZOI Start
    FOR    ${i}     IN RANGE        5
        ${sec}                      ZOI Remaining Sec                       zoi=${zoi}
        Dated log                   Remaining TIME=${sec}
        Sleep                       5
    END
    ZOI Wait End                    zoi=${zoi}
    Dated log                       END


Test ZOI Repeat until
    Dated log                       START
    ${zoi}                          ZOI Start
    ...                                 guardDelay=0
    ...                                 gp=60
    ...                                 pmAvailDelay=10
    ${sec}                          ZOI Remaining Sec                       zoi=${zoi}
    Dated log                       Remaining TIME=${sec}
    ZOI Repeat Until End            ${zoi}
    ...                             DummyKW 1 Arg                        MyParam1
    ${zoi}                          ZOI Start
    ...                                 guardDelay=0
    ...                                 gp=60
    ...                                 pmAvailDelay=10
    ${sec}                          ZOI Remaining Sec                       zoi=${zoi}
    Dated log                       Remaining TIME=${sec}
    ZOI Repeat Until End            ${zoi}
    ...                             DummyKW 3 Args                       MyParam1   MyParam2    MyParam3


Test KPI
    Dated log New Line              Starting collecting PM
    ${pm_path}                      Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    Dated Log                       PM_PATH=[${pm_path}]
    KPI Evaluate                    pmFile=${pm_path}
    ...                             constraintsFile=${CONSTRAINTS_FILE}

Test KPI Real PM File
    Dated log                       START
    KPI Evaluate                    pmFile=${PM_FILE}
    ...                             constraintsFile=${CONSTRAINTS_FILE}
    ...                             failOnError=${True}

*** Keywords ***
DummyKW 1 Arg
    [Arguments]                     ${param}
    ${rand}                         Evaluate    random.randint(20, 90)    random
    Dated Log                       PARAM=${param}:Dummy loop during ${rand} seconds
    sleep                           ${rand}

DummyKW 3 Args
    [Arguments]                     ${param1}       ${param2}       ${param3}
    ${rand}                         Evaluate    random.randint(20, 90)    random
    Dated Log                       PARAMS=${param1},${param2},${param3}:Dummy loop during ${rand} seconds
    sleep                           ${rand}
