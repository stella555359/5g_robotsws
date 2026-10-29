*** Settings ***
Documentation    The keyword for siso operation
...              Author: Chen Jun
...              Contact: jun.8.chen@nokia-sbell.com


*** Keywords ***
Block Cell And Check Status
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=30   ${connection}=GNB_CELL_Block
    Log To Console  \n***Block cells and check status***
    Perform Cell Block    cell_idx=${cell_idx}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    gnb_index=0    connection=${connection}
    Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be Blocked    cell_idx=${cell_idx}
    ...                                                                     cell_group_idx=${cell_group_idx}
    ...                                                                     timeout=${timeout}
    ...                                                                     connection=${connection}
    Wait For Expect Fault Present    faultId=49    timeout=30    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Unblock Cell And Check Status
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=30   ${connection}=GNB_CELL_Unblock
    Log To Console  \n***Unblock cells and check status***
    Perform Cell Unblock    cell_idx=${cell_idx}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    gnb_index=0    connection=${connection}
    Wait Until Keyword Succeeds   3 min  10 sec   Cell Should Be UnBlocked    cell_idx=${cell_idx}
    ...                                                                       cell_group_idx=${cell_group_idx}
    ...                                                                       timeout=${timeout}
    ...                                                                       connection=${connection}
    Wait For Expect Fault To Disappear    faultId=49    timeout=30    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
