*** Settings ***
Documentation    This is a testsuite with which we test changes to agents

Library  ./kill_agent_robot.py

*** Test Cases ***
Dummy
    Evaluate         sys.path      modules=sys
    Evaluate         os.environ    modules=os
    Pass Execution   This is a testsuite with which we test changes to agents


Failing test
    Fail


Print processes
    print_all_processes


Send SIGTERM signal during testrun
    send_sigterm_to_agent_robot
    Log To Console    Signal sent
    Sleep   120s
    Log To Console    End of test


Print it again
    print_all_processes
