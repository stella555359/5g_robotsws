*** Settings ***
Documentation       Set of tools to manage a generic test
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
    [Documentation]                 Check if a previous step (<depends>) was successfully executed
    ...                             ${depends}
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
    [Documentation]                 Compute next step index and print step nb and step name
    [Arguments]                     ${StepName}
    ${StepNb}                       evaluate                                ${StepNb}+1
    Set Suite Variable              ${StepNb}
    ${msg}                          Evaluate
    ...                             "${BG_BLUE}${WHITE}STEP %-2s : %-70s${NORMAL}" % ('${StepNb}','${StepName}')
    Log to Console                  ${msg}

Step
    [Documentation]                 Check dependency of a step, then execute it
    ...                             and store its results (status, error msg) in ListStep
    ...                             Default timeout is 1 hour, but maybe override to a custom value
    [Arguments]                     ${StepName}
    ...                             ${depends}=None
    ...                             ${timeout}=3600
    ...                             ${argument}=${EMPTY}
    Next Step                       ${StepName}
    ${status}   ${msg}              Check Dependencies                      ${StepName}     ${depends}
    ${status}   ${msg}              Run keyword if                          '${status}'=='PASS' and "${argument}"=="${EMPTY}"
    ...                             run keyword and ignore error            ${StepName}
    ...                             ELSE IF     '${status}'=='PASS' and "${argument}"!="${EMPTY}"
    ...                             run keyword and ignore error            ${StepName}      ${argument}
    ...                             ELSE
    ...                             run keyword and ignore error            Fail   ${msg}
    [Timeout]                       ${timeout}
    [Teardown]                      Add Step                                ${StepName}     ${status}       ${msg}

Critical Step
    [Documentation]                 Check dependency of a step, then execute it
    ...                             and store its results (status, error msg) in ListStep
    ...                             Same as Step, but stop the whole sequence in case it fail
    ...                             Default timeout is 1 hour, but maybe override to a custom value
    [Arguments]                     ${StepName}
    ...                             ${depends}=None
    ...                             ${timeout}=3600
    Next Step                       ${StepName}
    ${status}   ${msg}              Check Dependencies                      ${StepName}     ${depends}
    Run keyword if                  '${status}'=='PASS'                     ${StepName}
    ...                             ELSE                                    Fail            ${msg}
    [Timeout]                       ${timeout}
    [Teardown]                      Add Step                                ${StepName}
    ...                             ${KEYWORD_STATUS}                       ${KEYWORD_MESSAGE}


Add Step
    [Documentation]                 Add in <ListStep> table a new step result
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
    [Documentation]                 Compute status string (PASS of FAIL, but in color manner)
    [Arguments]                     ${status}
    ${str}                          Run Keyword if                         '${status}'=='PASS'
    ...                             evaluate                               "${BG_GREEN}${BLACK}PASS${NORMAL}"
    ...                             ELSE
    ...                             evaluate                               "${BG_RED}${BLACK}FAIL${NORMAL}"
    [Return]                        ${str}

Get short Str
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
    [Documentation]                 Invoke a failure for step with a particular range
    [Arguments]                     ${range}
    ${step}                         set variable                            ${ListStep[${range}-1]}
    Fail                            ERROR:STEP=${step.nb} NAME=[${step.name}] MSG=${step.msg}
