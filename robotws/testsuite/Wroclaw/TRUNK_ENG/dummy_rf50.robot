*** Settings ***
Documentation    This is a testsuite with which we test changes to agents

Force Tags   RF50

*** Test Cases ***
Dummy
    Evaluate         sys.path      modules=sys
    Evaluate         os.environ    modules=os
    Pass Execution   This is a testsuite with which we test changes to agents

[1]Test Name With Brackets
    Log To Console    Test Name With Brackets

Example RF50 syntax
    IF    1 > 0
        Log To Console    This only works on RF50 tests
    END
