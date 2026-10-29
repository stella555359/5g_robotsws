*** Settings ***
Documentation    This is a testsuite with which we test changes to agents with sum of sleeps in test cases < 1h

*** Test Cases ***
Dummy First
    Sleep    30
    Pass Execution   This is a testsuite with which we test changes to agents

Dummy Second
    Sleep    50
    Pass Execution   This is a testsuite with which we test changes to agents

Dummy Third
    Sleep    60
    Pass Execution   This is a testsuite with which we test changes to agents

Dummy Fourth
    Sleep    120
    Pass Execution   This is a testsuite with which we test changes to agents

Dummy Fifth
    Sleep    90
    Pass Execution   This is a testsuite with which we test changes to agents

