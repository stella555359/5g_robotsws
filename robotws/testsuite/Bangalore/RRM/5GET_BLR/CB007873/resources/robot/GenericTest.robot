*** Settings ***
Documentation
...             == Purpose ==
...             Library to ease write of generic tests and provide more understandable display
...
...             == Description ==
...             In some features, many tests are similar in their sequence, variations are just in values of some parameters
...             So, it is then highly recommended to write a unique generic keyword aim to perform the test upon values of parameters
...             BUT then, capabilities of test are not available at Kewyword level.
...             For instance, it is not possible to introduce some dependencies between keywords as it is possible for tests.
...             This module aims at reproduce these capabilities inside a single keyword.
...
...             *Concepts:*.
...
...             A generic test is a keyword that will contain a sequence of steps and critical steps.
...             A step corresponds to a particular step in a test (do this... do that...).
...             But we can introduce dependencies, meaning a test will be done ONLY if its dependency is OK.
...             If a step fails, next steps will nevertheless be done. That way, we can control proper termination
...             of some actions. For instance, even if Capture Start is failing, we can ensure to execute Capture Stop
...             to ensure processes are properly stopped.
...             A critical step is a step that will stop the whole sequence, meaning the test will be stopped.
...             At the end of a generi test,you should invoke Display Diagnosis keyword to provide summary of steps
...             that was OK and steps that was KO.
...
...             *Example:*
...
...             | --- Test suite ---\ \ \ \#
...             | Test 1\ \ \ \# First test
...             | \ \ \ \MyGenericTest\ \ \ \param=1
...             | Test 2\ \ \ \# Second test
...             | \ \ \ \MyGenericTest\ \ \ \param=2
...             | ... \ \ \ \
...
...             | --- Keywords ---\ \ \ \#
...             | MyGenericTest\ \ \ \# ...
...             | \ \ \ \[Arguments]\ \ \ \${param}
...             | \ \ \ \InitSequence\ \ \${param}=param
...             | \ \ \ \Step\ \ \ \ \ \ \ \ \ \ \ \PrepareTL
...             | \ \ \ \Critical Step\ \Call Setup      depends=PrepareTL
...             | \ \ \ \Critical Step\ \           Traffic         depends=Call Setup
...             | \ \ \ \...
...             | \ \ \ \[Teardown]\ \ \ \Display Diagnosis
...
...             *Note:*
...
...             When using "Step" Keyword, it will never fail since it is invoke with "Run keyword and ignore error"
...             but status is stored and in case of error, it will be highlighted at Display Diagnosis step.
...             So, when parsing and reading log.html, look first at Display Disgnosis KW, then look into specified
...             keyword in error.
...

Variables         ../python/Colors.py

*** Keywords ***
# ==================================================================================================
# Generic tools to manage a sequence of steps
# ==================================================================================================
Init Sequence
    [Documentation]                 Initialize all global variables required to execute a generic test
    [Arguments]                     ${param}
    Set Suite variable              ${param}
    ${line}                         Evaluate  "${BG_CYAN}${BLACK}%s${NORMAL}" % ('=' * 80)
    ${msg}                          Evaluate  "${BG_CYAN}${BLACK}TEST CASE : %-68s${NORMAL}" % ('${TEST_NAME}')
    Log to Console                  \n${line}
    Log to Console                  ${msg}
    Log to Console                  ${line}
    Set Suite Variable              ${StepNb}                   0
    @{ListStep}                     Create List
    Set Suite Variable              @{ListStep}

Check Dependencies
    [Documentation]                 INTERNAL USAGE
    ...                             Check if a previous step (<depends>) was successfully executed
    [Arguments]                     ${depends}
    ${ret_status}                   Set variable                            PASS
    FOR     ${i}       IN          @{ListStep}
        ${ret_status}               set variable if                         '${i.name}'=='${depends}'
        ...                         ${i.status}                             ${ret_status}
    END
    ${msg}                          Set Variable                            ${EMPTY}
    ${msg}                          set variable if                         '${ret_status}'=='FAIL'
    ...                             SKIP:previous step (${depends}) was FAIL
    ...                             ${msg}
    [Return]                        ${ret_status}       ${msg}


Next Step
    [Documentation]                 INTERNAL USAGE
    ...                             Compute next step index and print step nb and step name
    [Arguments]                     ${StepName}
    ${StepNb}                       evaluate                                ${StepNb}+1
    Set Suite Variable              ${StepNb}
    ${msg}                          Evaluate
    ...                             "${BG_BLUE}${WHITE}STEP %-2s : %-70s${NORMAL}" % ('${StepNb}','${StepName}')
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
    ...                             ${depends}=None
    ...                             ${timeout}=3600
    ...                             ${argument}=${EMPTY}
    ...                             &{kwargs}
    Next Step                       ${StepName}
    ${status}   ${msg}              Check Dependencies                      ${StepName}     ${depends}
    ${status}   ${msg}              Run keyword if                          '${status}'=='PASS' and "${argument}"=="${EMPTY}"
    ...                             run keyword and ignore error            ${StepName}     @{varargs}    &{kwargs}
    ...                             ELSE IF                                 '${status}'=='PASS' and "${argument}"!="${EMPTY}"
    ...                             run keyword and ignore error            ${StepName}      ${argument}
    ...                             ELSE
    ...                             run keyword and ignore error            Fail   ${msg}
    [Timeout]                       ${timeout}
    [Teardown]                      Add Step                                ${StepName}     ${status}       ${msg}

Critical Step
    [Documentation]                 Check dependency of a step, then execute it.
    ...                             and store its results (status, error msg) in ListStep.
    ...                             Same as Step, but stop the whole sequence in case it fail.
    ...                             Default timeout is 1 hour, but maybe override to a custom value.
    ...                             Example:
    ...                                 Critical Step     My Keyword    depends=WTS Setup    arg1    arg2=value2    arg3=value3
    [Arguments]                     ${StepName}
    ...                             @{varargs}
    ...                             ${depends}=None
    ...                             ${timeout}=3600
    ...                             &{kwargs}
    Next Step                       ${StepName}
    ${status}   ${msg}              Check Dependencies                      ${StepName}     ${depends}
    Run keyword if                  '${status}'=='PASS'                     ${StepName}     @{varargs}    &{kwargs}
    ...                             ELSE                                    Fail            ${msg}
    [Timeout]                       ${timeout}
    [Teardown]                      Add Step                                ${StepName}
    ...                             ${KEYWORD_STATUS}                       ${KEYWORD_MESSAGE}


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
    ${str}                          Get Status Str                          ${status}
    Log to console                  ${str}
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

Display diagnosis
    [Documentation]                 Log in console sump up of all steps for a test (name and status)
    ${msg}                          Evaluate
    ...                             "${BG_BLUE}${YELLOW}DIAGNOSIS : %-68s${NORMAL}" % ('${TEST_NAME}')
    ${KOrange}                      Set variable                           -1
    Log to console                  ${msg}
    FOR     ${step}    IN           @{ListStep}
        ${str_status}               Get Status Str                          ${step.status}
        ${msg_line}                 Get Short Str                           ${step.msg}
        ${str}                      evaluate
        ...                         "\tSTEP %-2s : %-50s ${str_status} ${msg_line}" % ('${step.nb}','${step.name}')
        Log to console              ${str}
        ${KOrange}                  set variable if
        ...                         '${step.status}'=='FAIL' and '${KOrange}'=='-1'
        ...                         ${step.nb}                              ${KOrange}
    END
    run keyword if                  '${KOrange}'!='-1'                      Fail Step          ${KOrange}

Fail Step
    [Documentation]                 INTERNAL USAGE
    ...                             Invoke a failure for step with a particular range
    [Arguments]                     ${range}
    ${step}                         set variable                            ${ListStep[${range}-1]}
    Fail                            ERROR:STEP=${step.nb} NAME=[${step.name}] MSG=${step.msg}
