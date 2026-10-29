*** Settings ***
Documentation    This is a testsuite with which we test changes to agents with sum of sleeps in test cases > 1h

*** Test Cases ***
Dummy First
    Sleep    1800
    Pass Execution   This is a testsuite with which we test changes to agents

Dummy Second
    Sleep    90
    Pass Execution   This is a testsuite with which we test changes to agents

Dummy Third
    Sleep    900
    Pass Execution   This is a testsuite with which we test changes to agents

Dummy Fourth
    Sleep    1000
    Pass Execution   This is a testsuite with which we test changes to agents

Dummy Fifth
    Sleep    200
    Pass Execution   This is a testsuite with which we test changes to agents

Dummy Sixth
    Sleep    400
    Pass Execution   This is a testsuite with which we test changes to agents

Dummy Seventh
    Sleep    30
    Pass Execution   This is a testsuite with which we test changes to agents

