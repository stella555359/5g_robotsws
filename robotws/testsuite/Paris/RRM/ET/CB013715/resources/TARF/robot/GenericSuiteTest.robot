*** Settings ***
Documentation
...             == Purpose ==
...             Library to ease write of generic tests and provide more understandable display
...
...             *Note:*
...
...             When using "Step" Keyword, it will never fail since it is invoke with "Run keyword and ignore error"
...             but status is stored and in case of error, it will be highlighted at Display Diagnosis step.
...             So, when parsing and reading log.html, look first at Display Disgnosis KW, then look into specified
...             keyword in error.
...

Library           DateTime

Variables         ../../../../../../resources/SWENG/python/Colors.py

*** Keywords ***
# ==================================================================================================
# Generic tools to manage a sequence of steps
# ==================================================================================================

Init Suite Test Sequence
    [Documentation]                 Initialize all global variables required to execute a generic test
    ${line}                         Evaluate  "${BG_CYAN}${BLACK}%s${NORMAL}" % ('=' * 80)
    ${msg}                          Evaluate  "${BG_CYAN}${BLACK}SUITE TEST : %-68s${NORMAL}" % ('${SUITE NAME}')
    Log to Console                  \n${line}
    Log to Console                  ${msg}
    Log to Console                  ${line}
    Set Suite Variable              ${StepNb}                   0
    @{ListStep}                     Create List
    Set Suite Variable              @{ListStep}

Init Sequence
    [Documentation]                 Initialize all global variables required to execute a generic test
    ${line}                         Evaluate  "${BG_CYAN}${BLACK}%s${NORMAL}" % ('=' * 80)
    ${msg}                          Evaluate  "${BG_CYAN}${BLACK}TEST CASE : %-68s${NORMAL}" % ('${TEST_NAME}')
    Log to Console                  \n${line}
    Log to Console                  ${msg}
    Log to Console                  ${line}
    Set Suite Variable              ${StepNb}                   0
    @{ListStep}                     Create List
    Set Suite Variable              @{ListStep}


Init Test Sequence
    [Documentation]                 Initialize all global variables required to execute a generic test
    [Arguments]                     ${param}
    Set Suite variable              ${param}


Next Step
    [Documentation]                 INTERNAL USAGE
    ...                             Compute next step index and print step nb and step name
    [Arguments]                     ${StepName}
    ${StepNb}                       evaluate                                ${StepNb}+1
    Set Suite Variable              ${StepNb}
    ${timestamp_msg}=               DateTime.Get Current Date    result_format=%H:%M:%S
    Set Suite Variable              ${timestamp_msg}
    ${msg}                          Evaluate
    ...                             "${BG_BLUE}${WHITE} [%s] STEP %-2s : %-70s${NORMAL}" % ('${timestamp_msg}','${StepNb}','${StepName}')
    Log to Console                  ${msg}

Current Step
    [Documentation]                 INTERNAL USAGE
    ...                             Compute next step index and print step nb and step name
    [Arguments]                     ${StepName}
    ${StepNb}                       evaluate                                ${StepNb}+1
    Set Suite Variable              ${StepNb}
    ${timestamp_msg}=               DateTime.Get Current Date    result_format=%H:%M:%S
    Set Suite Variable              ${timestamp_msg}
    ${msg}                          Evaluate
    ...                             "${BG_BLUE}${WHITE} [%s] STEP %-2s : %-70s${NORMAL}" % ('${timestamp_msg}','${StepNb}','${StepName}')
    Log to Console                  ${msg}

Step
    [Documentation]                 Check dependency of a step, then execute it.
    ...                             and store its results (status, error msg) in ListStep.
    ...                             Default timeout is 1 hour, but maybe override to a custom value.
    ...                             It now accept variable arguments number, but there are 2 cases.
    ...                             Either you use the old way:
    ...                                 Step     My Keyword    depends=WTS Setup    argument=${param}
    ...                             Or with variable number of args (not compatible with the use of "argument"):
    ...                                 Step     My Keyword    depends=WTS Setup    arg1    arg2=value2    arg3=value3
    [Arguments]                     ${StepName}
    ...                             @{varargs}
    ...                             &{kwargs}
    GenericSuiteTest.Current Step    ${StepName}
    ${status}   ${msg}              run keyword and ignore error          ${StepName}     @{varargs}    &{kwargs}
    [Teardown]                      GenericSuiteTest.Add Step             ${StepName}     ${status}       ${msg}


Add Step
    [Documentation]                 INTERNAL USAGE
    ...                             Add in <ListStep> table a new step result
    [Arguments]                     ${StepName}
    ...                             ${status}
    ...                             ${msg}
    ${s}=                           create dictionary                       name=${StepName}
    ...                             status=${status}                        nb=${StepNb}
    ...                             msg=${msg}
    append to list                  ${ListStep}                             ${s}
    ${str}                          GenericSuiteTest.Get Status Str       ${status}
    Log to console                  STEP ${StepName}: ${str}
    run keyword if                  '${status}'=='FAIL'
    ...                             Log to console                          ERROR : ${msg}

Get Status Str
    [Documentation]                 INTERNAL USAGE
    ...                             Compute status string (PASS of FAIL, but in color manner)
    [Arguments]                     ${status}
    ${str}                          Run Keyword if                         '${status}'=='PASS'
    ...                             evaluate                               "${BG_GREEN}${BLACK}PASS${NORMAL}"
    ...                             ELSE
    ...                             evaluate                               "${BG_RED}${BLACK}FAIL${NORMAL}"
    [Return]                        ${str}

Get short Str
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${str}
    ${type}                         Evaluate    type($str).__name__
    ${line}                         set variable if                         '${type}'=='NoneType'
    ...                             ${EMPTY}
    ...                             ${str.replace("\n","")}
    [Return]                        ${line}

Display diagnosis Suite Test
    [Documentation]                 Log in console sump up of all steps for a test (name and status)
    ${msg}                          Evaluate
    ...                             "${BG_BLUE}${YELLOW}DIAGNOSIS : %-68s${NORMAL}" % ('${SUITE NAME}')
    ${KOrange}                      Set variable                           -1
    Log to console                  ${msg}
    FOR     ${step}    IN           @{ListStep}
        ${str_status}               GenericSuiteTest.Get Status Str                          ${step.status}
        ${msg_line}                 GenericSuiteTest.Get Short Str                           ${step.msg}
        ${str}                      evaluate
        ...                         "\tSTEP %-2s : %-50s ${str_status} ${msg_line}" % ('${step.nb}','${step.name}')
        Log to console              ${str}
        ${KOrange}                  set variable if
        ...                         '${step.status}'=='FAIL' and '${KOrange}'=='-1'
        ...                         ${step.nb}                              ${KOrange}
    END
    run keyword if                  '${KOrange}'!='-1'           GenericSuiteTest.Fail Step          ${KOrange}


Display diagnosis
    [Documentation]                 Log in console sump up of all steps for a test (name and status)
    ${msg}                          Evaluate
    ...                             "${BG_BLUE}${YELLOW}DIAGNOSIS : %-68s${NORMAL}" % ('${TEST_NAME}')
    ${KOrange}                      Set variable                           -1
    Log to console                  ${msg}
    FOR     ${step}    IN           @{ListStep}
        ${str_status}               GenericSuiteTest.Get Status Str                          ${step.status}
        ${msg_line}                 GenericSuiteTest.Get Short Str                           ${step.msg}
        ${str}                      evaluate
        ...                         "\tSTEP %-2s : %-50s ${str_status} ${msg_line}" % ('${step.nb}','${step.name}')
        Log to console              ${str}
        ${KOrange}                  set variable if
        ...                         '${step.status}'=='FAIL' and '${KOrange}'=='-1'
        ...                         ${step.nb}                              ${KOrange}
    END
    run keyword if                  '${KOrange}'!='-1'           GenericSuiteTest.Fail Step          ${KOrange}

Fail Step
    [Documentation]                 INTERNAL USAGE
    ...                             Invoke a failure for step with a particular range
    [Arguments]                     ${range}
    ${step}                         set variable                            ${ListStep[${range}-1]}
    Fail                            ERROR:STEP=${step.nb} NAME=[${step.name}] MSG=${step.msg}
