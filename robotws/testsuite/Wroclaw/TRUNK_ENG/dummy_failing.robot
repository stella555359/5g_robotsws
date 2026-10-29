*** Settings ***
Documentation    This is a testsuite with which we test changes to agents

*** Test Cases ***
Dummy
    Evaluate         sys.path      modules=sys
    Evaluate         os.environ    modules=os
    Pass Execution   This is a testsuite with which we test changes to agents


Failing test
    Fail
