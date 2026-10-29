*** Settings ***
Documentation    Test Verdicts

*** Keywords ***
Set Test Failed
    [Documentation]
    ...  Mark the test as failed, but do not go to teardown if fail_fast is not True.
    ...  example of simple use:
    ...  Run Keyword If  'a'==`a`
    ...  Set Test Failed    failed reason    ${True}
    ...  default ${fail_fast}=False
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${failed_message}    ${fail_fast}=False

    Run Keyword if  ${fail_fast}  Fail  ${failed_message}
    ...  ELSE    Run Keyword And Continue On Failure  Fail  ${failed_message}


Set Test Restriction
    [Documentation]
    ...  Add restriction to passed test.
    ...  example of simple use:
    ...  Set Test Restriction  restriction message
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${restriction_message}

    Log    ${restriction_message}    WARN


Set Test Norun
    [Documentation]
    ...  Mark test as not run and skip to teardown.
    ...  example of simple use:
    ...  Run Keyword If  'a'==`a`
    ...  Set Test Norun  norun message
    ...  default ${fail_fast}=True
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${norun_message}    ${fail_fast}=True

    Run Keyword if  ${fail_fast}    Fail    ${norun_message}
    ...  ELSE  Run Keywords    Set Test Restriction    ${norun_message}
    ...  AND    Comment  ${norun_message}
