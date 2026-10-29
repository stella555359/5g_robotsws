*** Settings ***
Documentation
...    Robust inter-gNB test suite for TL929 (two gNB setup)
...    Three independent loop cases: SCF apply / gNB restart / RAT reset
Resource    ./Resources/CB014095_Common_Keywords.robot
Variables   ./Resources/TL929_Configuration.py


*** Variables ***
# Default iteration count - overridden inside each test case
${ROBUST_ITERATIONS}    15
${SCF_APPLY_WAIT}       10s
${GNB_RESTART_WAIT}     30s
${RAT_RESTART_WAIT}     20s
${DEFAULT_TIMEOUT}      600min
${SCF_Path_gnb0}        ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T929/SCF_SBTS00.xml
${SCF_Path_gnb1}        ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T929/SCF_SBTS00_gnb2.xml
# gNB connection and identification (from testline configuration)
${connection}           COAM
${connection_gnb1}      COAM1
${gnb1_ip}              ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${gnb0_instance_id}     ${tl.gnbs[0].instance_id}
${gnb1_instance_id}     ${tl.gnbs[1].instance_id}


*** Test Cases ***
CB014095_ROBUST_TL929_SCF_Apply_Loop
    [Tags]    TL929    robust    scf_apply
    [Setup]    Test Case setup
    [Timeout]    ${DEFAULT_TIMEOUT}
    Set Test Variable    ${ROBUST_ITERATIONS}    15    # Edit this number to change loop count
    Step0: Establish COAM connections
    Robust: Loop SCF Apply
    [Teardown]    Robust TL929 Test Case teardown

CB014095_ROBUST_TL929_GNB_Restart_Loop
    [Tags]    TL929    robust    gnb_restart
    [Setup]    Test Case setup
    [Timeout]    ${DEFAULT_TIMEOUT}
    Set Test Variable    ${ROBUST_ITERATIONS}    15    # Edit this number to change loop count
    Step0: Establish COAM connections
    Robust: Loop GNB Restart
    [Teardown]    Robust TL929 Test Case teardown

CB014095_ROBUST_TL929_RAT_Reset_Loop
    [Tags]    TL929    robust    rat_reset
    [Setup]    Test Case setup
    [Timeout]    ${DEFAULT_TIMEOUT}
    Set Test Variable    ${ROBUST_ITERATIONS}    15    # Edit this number to change loop count
    Step0: Establish COAM connections
    Robust: Loop RAT Reset
    [Teardown]    Robust TL929 Test Case teardown


*** Keywords ***
Test Case setup
    [Documentation]    Keep robust loop setup minimal to avoid AlarmWatchdog/admin reconnect ims2 artifacts.
    No Operation

Step0: Establish COAM connections
    [Documentation]    Connect COAM to both gNBs on TL929 (anchor=COAM, secondary=COAM1)
    Wait Until Keyword Succeeds    3min    30s    Connect to gnb coam via ssl    connection=${connection}
    Wait Until Keyword Succeeds    3min    30s    Connect to gnb coam via ssl    bts_host=${gnb1_ip}    connection=${connection_gnb1}

Robust TL929 Test Case teardown
    Test Case teardown

Test Case teardown
    [Documentation]    Only close COAM aliases used by this suite and skip common teardown to avoid extra ims2 dumps.
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_gnb1}

Robust: Loop SCF Apply
    [Documentation]    Loop SCF full recommissioning on both gNBs;
    @{result_list}    Create List
    ${end}=    Evaluate    int(${ROBUST_ITERATIONS}) + 1
    FOR    ${i}    IN RANGE    1    ${end}
        Log To Console    SCF apply iteration ${i}/${ROBUST_ITERATIONS}
        Run Keyword And Ignore Error    coam.perform_commissioning    scf_file=${SCF_Path_gnb0}
        ...    connection=${connection}    timeout=300
        Run Keyword And Ignore Error    coam.perform_commissioning    scf_file=${SCF_Path_gnb1}
        ...    connection=${connection_gnb1}    timeout=300
        Sleep    ${SCF_APPLY_WAIT}
        # Check both gNBs onair + alarm
        ${status_gnb0}=    Check Cells Onair And No Unexpected Alarm    Check_timer=15min    connection=${connection}
        ${status_gnb1}=    Check Cells Onair And No Unexpected Alarm    Check_timer=15min    connection=${connection_gnb1}
        ${status}=    Set Variable If
        ...    '${status_gnb0}'=='pass' and '${status_gnb1}'=='pass'    pass    fail
        Run Keyword And Continue On Failure    Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Run Keywords
        ...    Run Keyword And Ignore Error    Collect snapshot logs    TESTLINEID=gNB0_${gnb0_instance_id}    connection=${connection}    AND
        ...    Run Keyword And Ignore Error    Collect snapshot logs    TESTLINEID=gNB1_${gnb1_instance_id}    connection=${connection_gnb1}
        Append To List    ${result_list}    ${status}
        ${fail_num}=    Collections.Count Values In List    ${result_list}    fail
        Exit For Loop If    ${fail_num} >= 3
    END

Robust: Loop GNB Restart
    [Documentation]    Loop site reset on both gNBs;
    @{result_list}    Create List
    ${end}=    Evaluate    int(${ROBUST_ITERATIONS}) + 1
    FOR    ${i}    IN RANGE    1    ${end}
        Log To Console    GNB restart iteration ${i}/${ROBUST_ITERATIONS}
        Run Keyword And Ignore Error    COAM Reset Site    connection=${connection}
        Sleep    ${GNB_RESTART_WAIT}
        Run Keyword And Ignore Error    COAM Reset Site    connection=${connection_gnb1}
        Sleep    ${GNB_RESTART_WAIT}
        # Check both gNBs onair + alarm
        ${status_gnb0}=    Check Cells Onair And No Unexpected Alarm    Check_timer=7min    connection=${connection}
        ${status_gnb1}=    Check Cells Onair And No Unexpected Alarm    Check_timer=7min    connection=${connection_gnb1}
        ${status}=    Set Variable If
        ...    '${status_gnb0}'=='pass' and '${status_gnb1}'=='pass'    pass    fail
        Run Keyword And Continue On Failure    Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Run Keywords
        ...    Run Keyword And Ignore Error    Collect snapshot logs    TESTLINEID=gNB0_${gnb0_instance_id}    connection=${connection}    AND
        ...    Run Keyword And Ignore Error    Collect snapshot logs    TESTLINEID=gNB1_${gnb1_instance_id}    connection=${connection_gnb1}
        Append To List    ${result_list}    ${status}
        ${fail_num}=    Collections.Count Values In List    ${result_list}    fail
        Exit For Loop If    ${fail_num} >= 3
    END

Robust: Loop RAT Reset
    [Documentation]    Loop NR RAT reset on both gNBs via COAM;
    @{result_list}    Create List
    ${end}=    Evaluate    int(${ROBUST_ITERATIONS}) + 1
    FOR    ${i}    IN RANGE    1    ${end}
        Log To Console    RAT reset iteration ${i}/${ROBUST_ITERATIONS}
        Run Keyword And Ignore Error    coam.rat_reset    rat_type=NR    timeout=${240}    connection=${connection}
        Run Keyword And Ignore Error    coam.rat_reset    rat_type=NR    timeout=${240}    connection=${connection_gnb1}
        Sleep    ${RAT_RESTART_WAIT}
        # Check both gNBs onair + alarm
        ${status_gnb0}=    Check Cells Onair And No Unexpected Alarm    Check_timer=7min    connection=${connection}
        ${status_gnb1}=    Check Cells Onair And No Unexpected Alarm    Check_timer=7min    connection=${connection_gnb1}
        ${status}=    Set Variable If
        ...    '${status_gnb0}'=='pass' and '${status_gnb1}'=='pass'    pass    fail
        Run Keyword And Continue On Failure    Should Be Equal    ${status}    pass
        Run Keyword If    '${status}'=='fail'    Run Keywords
        ...    Run Keyword And Ignore Error    Collect snapshot logs    TESTLINEID=gNB0_${gnb0_instance_id}    connection=${connection}    AND
        ...    Run Keyword And Ignore Error    Collect snapshot logs    TESTLINEID=gNB1_${gnb1_instance_id}    connection=${connection_gnb1}
        Append To List    ${result_list}    ${status}
        ${fail_num}=    Collections.Count Values In List    ${result_list}    fail
        Exit For Loop If    ${fail_num} >= 3
    END
