*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot

*** Variables ***
${TECHNICAL_LOGS_OK}   ${True}

*** Keywords ***
Failsafe Pre Checks
    [Documentation]    Check preconditions before failsafe tests
    [Arguments]        ${SYSLOG_LIST}
    IF  '${OMKPI_CASE}' == '${False}'
#        Run Keyword And Continue On Failure     Check If Netboot Is Active And Deactivate It
        Run Keyword And Continue On Failure     Start Syslog Print Search To Background  ${SYSLOG_LIST}
    END
    Print Step Text                      1  Check Preconditions   automatic=${True}
    Print Text To Eventlog                  Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure     Check If Fault 61675 Should Be Allowed
    Run Keyword And Continue On Failure     Common Preconditions
    Run Keyword And Continue On Failure     Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure     Check If Fault 4589 Should Be Allowed
    Run Keyword And Continue On Failure     Stop Rt Alarm Listener
    Sleep                                   10s
    Run Keyword And Continue On Failure     Make SSH Log
    Run Keyword And Continue On Failure     Open BTS SSH Connection
    Print Step Text                      2  Check partition and make sure FD SW is installed   automatic=${True}
    Run Keyword And Continue On Failure     Check FD SW
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Failsafe Rescue Console usage
    [Documentation]    Connect to Rescue Console, Check partition and SW and Check alarms from Rescue Console
    [Arguments]  ${WAIT_RC_CONNECTION}   ${ALLOWED_RC_ALARM}
    Run Keyword And Continue On Failure     Close BTS SSH Connection
    Wait Time And Reason                    ${WAIT_RC_CONNECTION}     before connecting to RescueConsole
    Run Keyword And Continue On Failure     Connect To RC
    Print Step Text                      1  Check partition and SW   automatic=${True}
    Run Keyword And Continue On Failure     Check Partition And SW
    Print Step Text                      2  Check alarms from Rescue Console   automatic=${True}
    Run Keyword And Continue On Failure     Check Alarms From Rescue Console    allowed_alarms=${ALLOWED_RC_ALARM}
    Run Keyword And Continue On Failure     Collect RC Technical Logs
#    FCA_TATSCRIPTS-182330 Remove Technical log collection from Service button test
#        Print Step Text                      3  Collect RC technical logs   automatic=${True}
#        Run Keyword And Continue On Failure     Collect RC Technical Logs
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Failsafe Activate Previous SW
    [Documentation]    Activate previous SW and teardown Rescue Console connection
#    [Arguments]        ${STEP}
    Print Step Text                      1  Activate previous SW   automatic=${True}
    Run Keyword And Continue On Failure     Activate Previous SW
    Run Keyword And Continue On Failure     Teardown Rc Connection
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Failsafe Post Checks
    [Documentation]   Wait for BTS to reply to ping, reset admin connections, check postconditions after failsafe tests and
    ...               activate netboot
    [Arguments]       ${WAIT}
    Print Step Text                      1  Wait for BTS connection, then wait ${WAIT} before postconditions check  automatic=${True}
#    Run Keyword And Continue On Failure           Wait For BTS Connection
    Run Keyword And Continue On Failure     Ping Ip Until Disconnection Or Reconnection
    ...                                     ip_to_ping=192.168.255.129  disconnection=True    time_to_wait=300
    Run Keyword And Continue On Failure     Ping Ip Until Disconnection Or Reconnection
    ...                                     ip_to_ping=192.168.255.129  time_to_wait=300
    Run Keyword And Continue On Failure     Check If Admin Connection Available    360
    Start Rt Alarm Listener
    # Reset admin connections after SWDL
    Print Text To Eventlog    Reset admin connections after returning to normal partition
    Run Keyword and Continue On Failure     Reset Admin Connection
    Run Keyword and Continue On Failure     Reset Admin Connection    admin=default
    Wait Time And Reason                    ${WAIT}    before checking post-conditions
    Print Step Text                      2  Check Postconditions   automatic=${True}
    Run Keyword And Continue On Failure     Check If Log Collection Status Exists
    Run Keyword And Continue On Failure     Close SSH Log
    Run Keyword And Continue On Failure     Stop Background Syslog Print Search
    Run Keyword And Continue On Failure     Common Postconditions
#    IF  '${OMKPI_CASE}' == '${False}'
#        Run Keyword And Continue On Failure           Check If Netboot Is Deactive And Activate It
#    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Upload Swconfig And Reset site
    [Documentation]    Upload swconfig.txt to bts and reset site
# Upload swconfig.txt to bts and reset site, swconfig is lost in cases where sw is updated
    Run Keyword And Continue On Failure     Upload File To Bts
    Run Keyword And Continue On Failure     Reset Site    detailed_output=True
    Run Keyword And Continue On Failure     Wait For All Cells Up   time_limit=360
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Failsafe New SW And Commissioning
    [Documentation]    Upload and activate new SW, wait for BTS connection, perform commissioning and check postconditions
    [Arguments]        ${WAIT}  ${PATH_TO_BUILD}
# update SW
    Run Keyword And Continue On Failure     Update Software To BTS On FDSW  ${PATH_TO_BUILD}
# commissioning
    Print Step Text                      1  Perform commissioning   automatic=${True}
    Run Keyword And Continue On Failure     Perform Commissioning With Scf File  create_own_connection=${False}
    Print Step Text                      2  Wait for BTS connection, then wait ${WAIT} before postconditions check  automatic=${True}
    Wait Time And Reason                    sleep_time=300   wait_reason=after commissioning before checking if bts pings
    Run Keyword And Continue On Failure     Ping Ip Until Disconnection Or Reconnection
    ...                                     ip_to_ping=192.168.255.129  time_to_wait=300
    Run Keyword And Continue On Failure     Start Rt Alarm Listener
    Wait Time And Reason                    sleep_time=${WAIT}   wait_reason=before checking post-conditions
    Print Step Text                      3  Check Postconditions   automatic=${True}
    Run Keyword And Continue On Failure     Close SSH Log
    Run Keyword And Continue On Failure     Stop Background Syslog Print Search
    Run Keyword And Continue On Failure     Common Postconditions
    Run Keyword And Continue On Failure     Upload Swconfig And Reset site
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Long Press
    [Documentation]    Test long press of service button and that Rescue Console is activated. Rollback to previous SW
    ...                is made from Rescue Console.
    [Arguments]  ${WAIT}  ${SYSLOG_LIST}  ${WAIT_RC_CONNECTION}  ${ALLOWED_RC_ALARM}  ${UNIT}
    Run Keyword And Continue On Failure     Failsafe Pre Checks    ${SYSLOG_LIST}
    Print Step Text                      3  Press service button and try connecting to Rescue Console   automatic=${True}
    Run Keyword And Continue On Failure     Press Service Button  ${UNIT}  Long
    Check That Ping Is Lost After Service Button Press  ${UNIT}  Long
    Run Keyword And Continue On Failure     Failsafe Rescue Console usage  ${WAIT_RC_CONNECTION}  ${ALLOWED_RC_ALARM}
    Run Keyword And Continue On Failure     Failsafe Activate Previous SW
    Run Keyword And Continue On Failure     Failsafe Post Checks    ${WAIT}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Short Press
    [Documentation]    Test short press of service button and that Rescue Console is activated. Rollback to previous SW
    ...                is made from Rescue Console.
    [Arguments]  ${WAIT}    ${SYSLOG_LIST}  ${WAIT_RC_CONNECTION}    ${ALLOWED_RC_ALARM}    ${UNIT}
    Run Keyword And Continue On Failure     Failsafe Pre Checks    ${SYSLOG_LIST}
    Print Step Text                      3  Press service button and try connecting to Rescue Console   automatic=${True}
    Run Keyword And Continue On Failure     Press Service Button  ${UNIT}  Short
    Check That Ping Is Lost After Service Button Press  ${UNIT}  Short
    Run Keyword And Continue On Failure     Failsafe Rescue Console usage  ${WAIT_RC_CONNECTION}   ${ALLOWED_RC_ALARM}
    Run Keyword And Continue On Failure     Failsafe Activate Previous SW
    Run Keyword And Continue On Failure     Failsafe Post Checks    ${WAIT}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Short Press And New SW
    [Documentation]    Test short press of service button and that new software is updated from Rescue Console. Commissioning is made
    [Arguments]  ${WAIT}  ${SYSLOG_LIST}  ${WAIT_RC_CONNECTION}  ${ALLOWED_RC_ALARM}  ${UNIT}
    Run Keyword And Continue On Failure     Failsafe Pre Checks    ${SYSLOG_LIST}
    # collect sw build to test pc
    ${BRANCH_OF_ACTIVE_BUILD}=              Get Branch Of Active Build
    ${PATH_TO_BUILD}=                       Get Build That Is Currently Active On Bts  ${BRANCH_OF_ACTIVE_BUILD}
    Print Step Text                      3  Press service button and try connecting to Rescue Console   automatic=${True}
    Run Keyword And Continue On Failure     Press Service Button  ${UNIT}  Short
    Run Keyword And Continue On Failure     Failsafe Rescue Console usage  ${WAIT_RC_CONNECTION}   ${ALLOWED_RC_ALARM}
    Run Keyword And Continue On Failure     Failsafe New SW And Commissioning  ${WAIT}  ${PATH_TO_BUILD}
#    IF  '${OMKPI_CASE}' == '${False}'
#        Run Keyword And Continue On Failure     Check If Netboot Is Deactive And Activate It
#    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Sw Fallback
    [Documentation]    Test SW fallback and that it activates Rescue Console. Sw fallback is caused by corrupting sw. Corruption
    ...                is done by removing BTSOM applications. New software is updated from Rescue Console and commissioning is made.
    [Arguments]  ${WAIT}  ${EXPECTED_ALARM}  ${SYSLOG_LIST}  ${WAIT_RC_CONNECTION}  ${ALLOWED_RC_ALARM}
    Setup Power Breaker Controller          smod
    @{ports}=                               Find Ports For Chosen Units  s1
    Print Text To Eventlog                  Check if SMOD in use is ASOG/H and add fault 61675 as allowed
    Run Keyword And Continue On Failure     Check If Fault 61675 Should Be Allowed
    Run Keyword And Continue On Failure     Download packages to bts before test
    Run Keyword And Continue On Failure     Failsafe Pre Checks    ${SYSLOG_LIST}
    # collect sw build to test pc
    ${BRANCH_OF_ACTIVE_BUILD}=              Get Branch Of Active Build
    ${PATH_TO_BUILD}=                       Get Build That Is Currently Active On Bts    ${BRANCH_OF_ACTIVE_BUILD}
    Print Step Text                      3  Corrupt software from active and passive partition   automatic=${True}
    Run Keyword And Continue On Failure     Corrupt sw
    Run Keyword And Continue On Failure     Close BTS SSH Connection
    Print Step Text                      4  Reboot unit   automatic=${True}
    ${product_name}=                        Get Master SMOD ProductName
    Run Keyword And Continue On Failure     Turn Power Off From Chosen Units  ${product_name}
    Sleep                                   5
    Run Keyword And Continue On Failure     Turn Power On To Chosen Units  ${product_name}
    Print Step Text                      5  Calculate that software attempts to start 3 times from active and 3 times from passive side
    ...                                     automatic=${True}
    Run Keyword And Continue On Failure     Calculate Software Attempts To Start
    Run Keyword And Continue On Failure     Ping Ip Until Disconnection Or Reconnection
    ...                                     ip_to_ping=192.168.255.129  time_to_wait=900
    Wait Time And Reason                    sleep_time=360    wait_reason=before trying to take Rescue Console connection
    Run Keyword And Continue On Failure     Close BTS SSH Connection
    Sleep                                   ${WAIT_RC_CONNECTION}
    Run Keyword And Continue On Failure     Connect To RC
    Print Step Text                      6  Check partition and SW   automatic=${True}
    Run Keyword And Continue On Failure     Check Partition And SW
    Print Step Text                      7  Check alarms from RC   automatic=${True}
    Run Keyword And Continue On Failure     Check Alarms From Rescue Console  allowed_alarms=${ALLOWED_RC_ALARM}
    ...                                     expected_alarms=${EXPECTED_ALARM}
#    Print Step Text                      8  Collect RC technical logs   automatic=${True}
    Run Keyword And Continue On Failure     Collect RC Technical Logs
    IF  '${TECHNICAL_LOGS_OK}' == '${False}'
        Run Keyword And Continue On Failure     Stop Rc Log Collecting
        Run Keyword And Continue On Failure     BTS.Wait Time And Reason  sleep_time=15  wait_reason=before updating software
        Print Text To Eventlog                  Problems with log collecting from rescue console. Teardown RC connection and reconnect
        Run Keyword And Continue On Failure     Teardown Rc Connection
        Run Keyword And Continue On Failure     BTS.Wait Time And Reason  sleep_time=5  wait_reason=before reconnecting
        Run Keyword And Continue On Failure     Connect To RC
        Set Suite Variable                      ${KW_SUCCESS}    ${False}
    END
    Run Keyword And Continue On Failure     Failsafe New SW And Commissioning  ${WAIT}  ${PATH_TO_BUILD}
#    IF  '${OMKPI_CASE}' == '${False}'
#        Run Keyword And Continue On Failure     Check If Netboot Is Deactive And Activate It
#    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Download packages to bts before test
    [Documentation]    Download packages to PC and to BTS before test so that after this KW passive partition has T1
    ...                 software of software to be tested.
    # collect sw builds to test pc
    ${BRANCH_OF_ACTIVE_BUILD}=              Get Branch Of Active Build
    ${path_to_build}=                       Get Build That Is Currently Active On Bts  ${BRANCH_OF_ACTIVE_BUILD}
    ${t1_build}=                            Get Build That Is Currently Active On Bts  ${BRANCH_OF_ACTIVE_BUILD}  testpackage=T1
    Set Suite Variable  ${PATH_TO_BUILD}    ${path_to_build}
    Set Suite Variable  ${T1_BUILD}         ${t1_build}
    ${build_already_on_passive}=            Check If Build In Passive Side Is Same That Is Planned To Be Downloaded
    ...                                     ${t1_build}   switch_order=${False}   return_boolean=${True}
    IF  '${build_already_on_passive}' == '${False}'
        Run Keyword And Continue On Failure    Download T1 And Rollback   ${T1_BUILD}   ${PATH_TO_BUILD}
    ELSE
        Run Keyword And Continue On Failure    Print Text To Eventlog   T1 build is already on passive side, no need for T1 SWDL
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Download T1 And Rollback
    [Documentation]    Download T1 and rollback to normal build
    [Arguments]        ${T1_BUILD}  ${PATH_TO_BUILD}
    Print Step Text                    0    Before test, download T1 testpackage build to bts and after that rollback to normal build
    Run Keyword and Continue On Failure     SW Update No KPI Calculations and Log Collection If Fail
    ...                                     ${T1_BUILD}  T1 testpackage  0  900   900  ${True}  SWDL_of_T1
    Run Keyword And Continue On Failure     Create New Log Folder  Rollback_from_T1
    Run Keyword and Continue On Failure     Rollback and Log Collection If Fail  ${T1_BUILD}  ${PATH_TO_BUILD}  0  900  Rollback_from_T1
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Collect RC Technical Logs
    [Documentation]    Collect technical logs from Rescue Console if RESCUE_CONSOLE_LOGS suite variable is found. If log collection is
    ...                not finished within 60 minutes timeouts from this keyword.
    [Timeout]          60 minutes
    ${rc_logs_should_be_collected}=   Check If Rescue Console Logs Variable Is Set
    IF  '${rc_logs_should_be_collected}' == '${True}'
        Print Step Text                      1  Collect RC technical logs   automatic=${True}
        Run Keyword And Continue On Failure     Get Logs From Rescue Console
    END
#    ELSE
#        Print Text To Eventlog               Technical logs are not collected from RescueConsole
#    END
#    Run Keyword And Continue On Failure     Get Logs From Rescue Console
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Run Keywords    Set Suite Variable  ${KW_SUCCESS}    ${False}  AND
    ...                                                                          Set Suite Variable  ${TECHNICAL_LOGS_OK}   ${False}

#SW Update Setting Uboot
#    [Documentation]    This method is needed because occasionally collecting log from RescueConsole hangs and timeout keyword is raised
#    ...                and this method is used to update SW so that environment is not broken in UTE.
#    ${TARGET_BD}=               Print TargetBD Of SW Zip  ${PATH_TO_BUILD}
#    Upload And Activate New SW  ${PATH_TO_BUILD}  ${TARGET_BD}
#    Sleep                       600
#    Teardown Rc Connection
#    Check If Admin Connection Available    360
## Reset admin connections after SWDL
#    Print Text To Eventlog      Reset admin connections after returning to normal partition
#    Reset Admin Connection
#    Reset Admin Connection      admin=default
#    Perform Commissioning With Scf File
#    Check If Netboot Is Deactive And Activate It
#

Update Software To BTS On FDSW
    [Documentation]    Update software to BTS when FDSW software is active
    [Arguments]        ${PATH_TO_BUILD}
    Print Step Text                      1  Upload and activate new SW   automatic=${True}
    ${TARGET_BD}=                           Print TargetBD Of SW Zip  ${PATH_TO_BUILD}
    Run Keyword And Continue On Failure     Upload And Activate New SW  ${PATH_TO_BUILD}  ${TARGET_BD}
    Sleep                                   60
    Run Keyword And Continue On Failure     Teardown Rc Connection
#    Print Step Text                      2  Wait for BTS connection   automatic=${True}
    Print Text To Eventlog                  Wait for BTS connection
    Run Keyword And Continue On Failure     Ping Ip Until Disconnection Or Reconnection
    ...                                     ip_to_ping=192.168.255.129  disconnection=True  time_to_wait=300  level_in_error=info
    Run Keyword And Continue On Failure     Ping Ip Until Disconnection Or Reconnection
    ...                                     ip_to_ping=192.168.255.129  time_to_wait=300  level_in_error=info
    Run Keyword And Continue On Failure     Check If Admin Connection Available    360
# Reset admin connections after SWDL
    Print Text To Eventlog                  Reset admin connections after returning to normal partition
    Run Keyword and Continue On Failure     Reset Admin Connection
    Run Keyword and Continue On Failure     Reset Admin Connection    admin=default
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}
