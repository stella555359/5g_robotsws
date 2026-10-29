*** Settings ***
Documentation
...  Author:   Essi Passoja
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library      taf.fdsw.rc  WITH NAME  RC
Resource     testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library      testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FDSW  WITH NAME  FDSW
Library      testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.RescueConsole

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${wait}                     3 min
${path_to_sw_build}=        testsuite/Oulu/TrunkEng/RecoveryAndAlarms/sw_build.zip
&{SMODS_AND_PORTS}          ASIA1=9
&{EXPECTED_ALARM}   fault_id=${4082}  fault_text=SW fallback due to max number of recovery resets   alarm_number=${7651}
${ALLOWED_ALARMS_FILE}      testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt

*** Test Cases ***
Long Press
    [Documentation]   Make long service button press, collect logs from Rescue Console and go back to previous SW.
    Run Keyword In Loop And Return Pass Rate
     ...    name=Long Press
     ...    test_case=1
     ...    loops=1
     ...    keywords=Long Press
     ...    expected_pass_rate=1

Short Press
    [Documentation]   Make short service button press, collect logs from Rescue Console and go back to previous SW.
    Run Keyword In Loop And Return Pass Rate
     ...    name=Short Press
     ...    test_case=2
     ...    loops=1
     ...    keywords=Short Press
     ...    expected_pass_rate=1

Short Press And New SW
    [Documentation]   Make short service button press, collect logs from Rescue Console, upload and activate new SW and
    ...    perform commissioning with scf file.
    Run Keyword In Loop And Return Pass Rate
     ...    name=Short Press And New SW
     ...    test_case=3
     ...    loops=1
     ...    keywords=Short Press And New SW
     ...    expected_pass_rate=1

Sw Fallback
    [Documentation]   Corrupt software from fs1 and fs2 and reboot, check that correct alarm 4082 'SW fallback due to
    ...    max number of recovery resets' is reported, collect logs from Rescue Console, upload and activate new SW and
    ...    perform commissioning with scf file.
    Run Keyword In Loop And Return Pass Rate
        ...    name=Sw Fallback
        ...    test_case=4
        ...    loops=1
		...    keywords=Sw Fallback
        ...    expected_pass_rate=1

*** Keywords ***
# [Tags]    QC_ID
Long Press
    Print Step Text                          1  Check Preconditions
    Common Preconditions
    Stop Rt Alarm Listener
    Make SSH Log
    Open BTS SSH Connection
    Print Step Text                          2  Check partition and make sure FD SW is installed
    Run Keyword And Continue On Failure         Check FD SW
    Print Step Text                          3  Press service button and try connecting to Rescue Console
    Run Keyword And Continue On Failure         Press Service Button  ASIA  Long
    Run Keyword And Continue On Failure         Close BTS SSH Connection
    Sleep                                       ${wait}
    Run Keyword And Continue On Failure         Connect To RC
    Print Step Text                          4  Check partition and SW
    Run Keyword And Continue On Failure         Check Partition And SW
    Print Step Text                          5  Check alarms from RC
    Run Keyword And Continue On Failure         Check Alarms From Rescue Console
    Print Step Text                          6  Collect RC technical logs
    Run Keyword And Continue On Failure         Get Logs From Rescue Console
    Print Step Text                          7  Activate previous SW
    Run Keyword And Continue On Failure         Activate Previous SW
    Run Keyword And Continue On Failure         RC.Teardown  connection=rc_connection
    Print Step Text                          8  Wait for BTS connection, then wait ${wait} before postconditions check
    Run Keyword And Continue On Failure         Wait For BTS Connection
    Start Rt Alarm Listener
    Sleep                                       ${wait}
    Print Step Text                          9  Check Postconditions
    Run Keyword And Continue On Failure         Close SSH Log
    Common Postconditions

Short Press
    Print Step Text                          1  Check Preconditions
    Common Preconditions
    Stop Rt Alarm Listener
    Make SSH Log
    Open BTS SSH Connection
    Print Step Text                          2  Check partition and make sure FD SW is installed
    Run Keyword And Continue On Failure         Check FD SW
    Print Step Text                          3  Press service button and try connecting to Rescue Console
    Run Keyword And Continue On Failure         Press Service Button  ASIA  Short
    Run Keyword And Continue On Failure         Close BTS SSH Connection
    Sleep                                       ${wait}
    Run Keyword And Continue On Failure         Connect To RC
    Print Step Text                          4  Check partition and SW
    Run Keyword And Continue On Failure         Check Partition And SW
    Print Step Text                          5  Check alarms from RC
    Run Keyword And Continue On Failure         Check Alarms From Rescue Console
    Print Step Text                          6  Collect RC technical logs
    Run Keyword And Continue On Failure         Get Logs From Rescue Console
    Print Step Text                          7  Activate previous SW
    Run Keyword And Continue On Failure         Activate Previous SW
    Run Keyword And Continue On Failure         RC.Teardown  connection=rc_connection
    Print Step Text                          8  Wait for BTS connection, then wait ${wait} before postconditions check
    Run Keyword And Continue On Failure         Wait For BTS Connection
    Start Rt Alarm Listener
    Sleep                                       ${wait}
    Print Step Text                          9  Check Postconditions
    Run Keyword And Continue On Failure        Close SSH Log
    Common Postconditions

Short Press And New SW
    Print Step Text                          1  Check Preconditions
    Common Preconditions
    Stop Rt Alarm Listener
    Make SSH Log
    Open BTS SSH Connection
    Get Active Partition
    Print Step Text                          2  Check partition and make sure FD SW is installed
    Run Keyword And Continue On Failure         Check FD SW
    Print Step Text                          3  Press service button and try connecting to Rescue Console
    Run Keyword And Continue On Failure         Press Service Button  ASIA  Short
    Run Keyword And Continue On Failure         Close BTS SSH Connection
    Sleep                                       ${wait}
    Run Keyword And Continue On Failure         Connect To RC
    Print Step Text                          4  Check partition and SW
    Run Keyword And Continue On Failure         Check Partition And SW
    Print Step Text                          5  Check alarms from RC
    Run Keyword And Continue On Failure         Check Alarms From Rescue Console
    Print Step Text                          6  Collect RC technical logs
    Run Keyword And Continue On Failure         Get Logs From Rescue Console
    Print Step Text                          7  Upload and activate new SW
    Run Keyword And Continue On Failure         Print TargetBD Of SW Zip  ${path_to_sw_build}
    Run Keyword And Continue On Failure         Upload And Activate New SW  ${path_to_sw_build}
    Sleep                                       1 min
    Run Keyword And Continue On Failure         RC.Teardown  connection=rc_connection
    Print Step Text                          8  Wait for BTS connection
    Run Keyword And Continue On Failure         Wait For BTS Connection  ip_to_ping=192.168.255.129
    Run Keyword And Continue On Failure         Check If Admin Connection Available    900
    Print Step Text                          9  Perform commissioning
    Run Keyword And Continue On Failure         Perform Commissioning With Scf File  create_own_connection=${False}
    Print Step Text                         10  Wait for BTS connection, then wait ${wait} before postconditions check
    Run Keyword And Continue On Failure         Wait For BTS Connection
    Start Rt Alarm Listener
    Sleep                                       ${wait}
    Print Step Text                         11  Check Postconditions
    Run Keyword And Continue On Failure         Close SSH Log
    Common Postconditions

Sw Fallback
    Print Step Text                          1  Check Preconditions
    Common Preconditions
    Setup Power Breaker Controller          smod  enics  172.31.4.239  ${SMODS_AND_PORTS}
    Stop Rt Alarm Listener
    Make SSH Log
    Open BTS SSH Connection
    Get Active Partition
    Print Step Text                          2  Check partition and make sure FD SW is installed
    Run Keyword And Continue On Failure         Check FD SW
    Print Step Text                          3  Corrupt software from active and passive partition
    Run Keyword And Continue On Failure         Corrupt sw
    Run Keyword And Continue On Failure         Close BTS SSH Connection
    Print Step Text                          4  Reboot unit
    Run Keyword And Continue On Failure      Turn Power Off From Chosen Units    ASIA1
    Sleep                                    5s
    Run Keyword And Continue On Failure      Turn Power On To Chosen Units       ASIA1
    Print Step Text       5  Calculate that software attempts to start 3 times from active and 3 times from passive side
    Run Keyword And Continue On Failure      Calculate Software Attempts To Start
    Ping Ip Until Disconnection Or Reconnection   ip_to_ping=192.168.255.129   time_to_wait=900
    Wait Time And Reason   sleep_time=300   wait_reason=before trying to take Rescue Console connection
    Run Keyword And Continue On Failure      Connect To RC
    Print Step Text                          6  Check partition and SW
    Run Keyword And Continue On Failure         Check Partition And SW
    Print Step Text                          7  Check alarms from RC
    Run Keyword And Continue On Failure         Check Alarms From Rescue Console   expected_alarms=${EXPECTED_ALARM}
    Print Step Text                          8  Collect RC technical logs
    Run Keyword And Continue On Failure         Get Logs From Rescue Console
    Print Step Text                          9  Upload and activate new SW
    Run Keyword And Continue On Failure         Print TargetBD Of SW Zip  ${path_to_sw_build}
    Run Keyword And Continue On Failure         Upload And Activate New SW  ${path_to_sw_build}
    Sleep                                       1 min
    Run Keyword And Continue On Failure         RC.Teardown  connection=rc_connection
    Print Step Text                         10  Wait for BTS connection
    Run Keyword And Continue On Failure         Wait For BTS Connection  ip_to_ping=192.168.255.129
    Run Keyword And Continue On Failure         Check If Admin Connection Available    360
    Print Step Text                         11  Perform commissioning
    Run Keyword And Continue On Failure         Perform Commissioning With Scf File  create_own_connection=${False}
    Print Step Text                         12  Wait for BTS connection, then wait ${wait} before postconditions check
    Run Keyword And Continue On Failure         Wait For BTS Connection
    Start Rt Alarm Listener
    Sleep                                       ${wait}
    Print Step Text                         12  Check Postconditions
    Run Keyword And Continue On Failure         Close SSH Log
    Common Postconditions
