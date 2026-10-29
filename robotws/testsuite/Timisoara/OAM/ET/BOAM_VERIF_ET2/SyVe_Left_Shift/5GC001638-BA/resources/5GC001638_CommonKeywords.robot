*** Settings ***
Documentation
...         05.03.2025 -- RF5.0 & :FOR
Resource    ../../resources/CommonKeywords/admin/component_states_verification/OnAirCheckers/CheckOnAir.robot
Resource    ../../CommonKeywords/ConnectivityKeywords.robot
#Resource    ../../resources/CommonKeywords/admin/BasicKeywords.robot

Library     Collections
Library     String
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    trs_ssh
Library     taf.sbts.oam.coam.admin   WITH NAME   cli

#Resource    ../../resources/admin.robot
#Resource    ../../resources/system.robot
Resource    ../../resources/CommonKeywords/admin/component_states_verification/resources/single_state_checkers/administrativeState.robot
Resource    ../../resources/CommonKeywords/admin/component_states_verification/resources/single_state_checkers/availabilityStatus.robot
Resource    ../../resources/CommonKeywords/admin/component_states_verification/resources/single_state_checkers/operationalState.robot
Resource    ../../resources/CommonKeywords/admin/component_states_verification/resources/single_state_checkers/proceduralStatus.robot
#Resource    ../../resources/CommonKeywords/QualcommKeywords.robot
Resource    ../../CommonKeywords/RadioUnitKeywords.robot
Variables   variables.py


*** Variables ***

#${TX_fault_flag}=              . ccsShell.sh rad -w 0x40023 1
#${asik_addr}                     192.168.255.1
#${asik_username}                 toor4nsn
#${asik_password}                 oZPS0POrRieRtu
${file_to_rename}=             /mnt/factory/configs/unit/calibration_dlpath1.bin
${temp_filename}=              /mnt/factory/configs/unit/temp_filename

*** Keywords ***
Connect To ADMIN Via CLI
    [Documentation]
    ...  Establish connection with WebEM via CLI
    cli.connect to

Disconnect From ADMIN Via CLI
    [Documentation]
    ...  Break connection with WebEM via CLI
    cli.teardown

Check All Components while OnAir
    Check SMOD while OnAir      1
    Check BBMOD while OnAir     1
#    Check GNSS while OnAir
    Check RU while OnAir        1
    Check Cell while OnAir      1

Check All Components while OnAir without cell status
    Check SMOD while OnAir      1
    Check BBMOD while OnAir     1
#    Check GNSS while OnAir
    Check RU while OnAir        1

Check All Components while OnAir 2CC
    Check SMOD while OnAir      1
    Check BBMOD while OnAir     1
    Check GNSS while OnAir
    Check RU while OnAir        1
    Check Cell while OnAir      1
    Check Cell while OnAir      2


Check All Components while OnAir 2CC each BBMOD
    Check SMOD while OnAir      1
    Check BBMOD while OnAir     1
    Check BBMOD while OnAir     2
    Check GNSS while OnAir
    Check RU while OnAir        1
    Check RU while OnAir        2
    Check Cell while OnAir      1
    Check Cell while OnAir      2
    Check Cell while OnAir      3
    Check Cell while OnAir      4


Check All Components while OnAir 4CC
    Check SMOD while OnAir      1
    Check BBMOD while OnAir     1
    Check GNSS while OnAir
    Check RU while OnAir        1
    Check Cell while OnAir      1
    Check Cell while OnAir      2
    Check Cell while OnAir      3
    Check Cell while OnAir      4

Check components status while recovery action
   [Arguments]     ${recovery_component}
   Check Cell while RU reset    1
   Check RU while RU reset      1
   Check RU while OnAir        1
   Check BBMOD while OnAir     1
   Check Cell while OnAir      1
   run keyword if    '${recovery_component}'=='BBMOD'    Check BBMOD while BBMOD reset       1
   ...     ELSE       run keywords        Check SMOD while OnAir      1    AND
   ...                                    Check BBMOD while OnAir     1

Check components status while recovery action after 1901
   #[Arguments]     ${recovery_component}
   Check Cell while RU reset    1
   Check RU while RU reset      1
#   Check RU while OnAir        1
   Check BBMOD while OnAir     1
#   Check Cell while OnAir      1
#   run keyword if    '${recovery_component}'=='BBMOD'    Check BBMOD while BBMOD reset       1
#   ...     ELSE       run keywords        Check SMOD while OnAir      1    AND
#   ...                                    Check BBMOD while OnAir     1

Fault Should Be Present
    [Documentation]
    ...  ___
    [Arguments]    ${fault_id}
#    Log To Console    KW - Fault Should Be Present fault_id=${fault_id}
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
#    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Contain    ${list}    ${fault_id}

Fault Should Not Be Present
    [Documentation]
    ...  ___
    [Arguments]    ${fault_id}
#    Log To Console    KW - Fault Should Not Be Present fault_id=${fault_id}
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
#    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Not Contain    ${list}    ${fault_id}

Trigger fault 4019
    Connect Ssh To Asix
    Connect to ABIL Xeon via Asik
    ${OUTPUT}=      trs_ssh.Execute     killall /opt/hwr/HWRTimeSExe    connection=abil
    [Teardown]  Disconnect Ssh From Asix

Trigger fault 4019 2nd XEON 1st BBMOD
    Connect Ssh To Asix
    Connect to 2nd XEON 1st ABIL via Asik
    ${OUTPUT}=      trs_ssh.Execute     killall /opt/hwr/HWRTimeSExe    connection=abil
    [Teardown]  Disconnect Ssh From Asix


Trigger fault 4019 second BBMOD
    Connect Ssh To Asix
    Connect to second ABIL Xeon via Asik
    ${OUTPUT}=      trs_ssh.Execute     killall /opt/hwr/HWRTimeSExe    connection=abil
    [Teardown]  Disconnect Ssh From Asix

Fault 4019 cycle
   log to console   starting Fault 4019 cycle
   Trigger Fault 4019
   Wait For Fault with Alarm to appear      4019    7101
   wait until keyword succeeds  120    1    BBMOD state checkers
   Wait for BBMOD autonomous reset as a recovery action
   Wait For OnAir without cell status
   Check BBMOD while OnAir      1
   Wait For Fault with Alarm to disappear      4019    7101
   log to console   Fault 4019 cycle done

Fault 4019 cycle 19B
   log to console   starting Fault 4019 cycle
   Trigger fault 4019 2nd XEON 1st BBMOD
   Wait For Fault with Alarm to appear      4019    7101
   wait until keyword succeeds  120    1    BBMOD state checkers
   Wait for BBMOD autonomous reset as a recovery action
   Wait For OnAir without cell status
   Check BBMOD while OnAir      1
   Wait For Fault with Alarm to disappear      4019    7101
   log to console   Fault 4019 cycle done

BBMOD state checkers
   Check RU while RU reset    1
   Check BBMOD while BBMOD reset   1


Fault 1912 cycle
   log to console   starting Fault 1912 cycle
   Fault 1912 Trigger
   Wait For Fault with Alarm to appear      1912    7101
   Check SMOD while OnAir      1
   Check BBMOD while OnAir     1
   Wait For OnAir without cell status
   Wait For Fault with Alarm to disappear      1912    7101
   log to console   Fault 4019 cycle done


Fault 4383 cycle
   log to console   starting Fault 4383 cycle
   Stop container to trigger fault 4383
   log to console   waiting for fault and alarm
   wait until keyword succeeds  60     0.001    Fault Should Be Present   4383
   wait until keyword succeeds  30      0.01    Alarm Should Be Present   7101

   log to console   fault and alarm present, recovery...

   Wait for gNB autonomous reset as a recovery action
#   Wait For OnAir without cell status
   Wait Until Keyword Succeeds
    ...    900
    ...    15
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
   Wait For Fault with Alarm to disappear    4383   7101
   log to console  Fault 4383 cycle done


Kill pmagent to trigger fault 4383
    ${process_pid}=   SYSTEM Execute Command On gNB
    ...    command=ps aux | grep -i "pmagent" | egrep -v "grep|bash" | awk '{print $2}'
    @{list_process_pid}=  split to lines  ${process_pid}
    SYSTEM Execute Command On gNB
    ...    command=kill -11 @{list_process_pid}[0]

Stop container to trigger fault 4383
    SYSTEM Execute Command On gNB
    ...    command=systemctl stop hwr-container@TRACECM00.service



Fault 4383 load counter
    [Arguments]  ${count}=3
    FOR    ${INDEX}  IN RANGE    0   ${count}
       log to console  activating and deactivating Fault with Alarm for the ${INDEX} time
       Fault 4383 cycle
    END

Fault 4383 counter overload

    Stop container to trigger fault 4383
    wait until keyword succeeds  60      0.1    Wait For Fault with Alarm to appear    4383   7116


Fault 4019 load counter
    [Arguments]  ${count}=3
    FOR    ${INDEX}  IN RANGE    0   ${count}
       log to console  activating and deactivating Fault with Alarm for the ${INDEX} time
       Fault 4019 cycle
    END

Fault 4019 load counter 19B
    [Arguments]  ${count}=3
    FOR    ${INDEX}  IN RANGE    0   ${count}
       log to console  activating and deactivating Fault with Alarm for the ${INDEX} time
       Fault 4019 cycle 19B
    END

Fault 4019 counter overload
   Trigger Fault 4019
   Wait For Fault with Alarm to appear      4019    7116

Fault 4019 counter overload 19B
   Trigger fault 4019 2nd XEON 1st BBMOD
   Wait For Fault with Alarm to appear      4019    7115


Fault 1912 counter overload
   Fault 1912 Trigger
   Wait For Fault with Alarm to appear      1912    7116

Fault 1912 load counter
    [Arguments]  ${count}=3
    FOR    ${INDEX}  IN RANGE    0   ${count}
       log to console  activating and deactivating Fault with Alarm for the ${INDEX} time
       Fault 1912 cycle
    END


Fault 1912 Trigger
    Connect Ssh To Asix
    ${RU_IP}=     Get RU IP from ASIK
    Connect to RU via Asik   ${RU_IP}
    ssh.execute    ${TX_fault_flag}    connection=ru
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix

#Connect Ssh To Asix
#    [Documentation]
#    ...  Establish connection with ASIx via SSH
#    trs_ssh.Connect To
#    ...    hostname=${asik_addr}
#    ...    username=${asik_username}
#    ...    password=${asik_password}
#    ...    alias=asik
#
#Disconnect Ssh From Asix
#    [Documentation]
#    ...  Break connection with ASIx via SSH
#    trs_ssh.Disconnect      connection=asik

Check Cell while RU reset
    [Arguments]  ${component_index}
    ${states}   Get Cell Statuses       ${component_index}
    Check availability & operational & administrative & procedural while Reset Cell  ${states}

Check RU while RU reset
    [Arguments]  ${component_index}
    ${states}   Get RU Statuses         ${component_index}
    Check availability & operational & administrative & procedural while Reset RU  ${states}

Check availability & operational & administrative & procedural while Reset Cell
    [Arguments]  ${states}
    Check availabilityStatus failed             ${states}
    Check operationalState disabled             ${states}
    Check administrativeState unlocked          ${states}
    Check proceduralStatus notinitialized       ${states}

Check availability & operational & administrative & procedural while Reset RU
    [Arguments]  ${states}
    Check availabilityStatus notinstalled       ${states}
    Check operationalState disabled             ${states}
    Check administrativeState unlocked          ${states}
    Check proceduralStatus notinitialized       ${states}

Check availability & operational & administrative & procedural while Reset BBMOD
    [Arguments]  ${states}
    Check availabilityStatus offline            ${states}
    Check operationalState disabled             ${states}
    Check administrativeState unlocked          ${states}
    ${actual_value}=    get from dictionary    ${states}    proceduralStatus
    should contain any  ${actual_value}    initializing    not initialized

Check availability & operational & administrative & procedural while Reset SMOD
    [Arguments]  ${states}
    Check availabilityStatus failed             ${states}
    Check operationalState disabled             ${states}
    Check administrativeState unlocked          ${states}
    Check proceduralStatus configured           ${states}

Check availability & operational & administrative & procedural while SMOD with OnAir on first BBMOD
    [Arguments]  ${states}
    Check availabilityStatus degraded       ${states}
    Check operationalState enabled          ${states}
    Check administrativeState unlocked      ${states}
    Check proceduralStatus configured       ${states}

Check availability & operational & administrative & procedural while SMOD with OnAir on second BBMOD
    [Arguments]  ${states}
    Check availabilityStatus degraded       ${states}
    Check operationalState enabled          ${states}
    Check administrativeState unlocked      ${states}
    Check proceduralStatus configured       ${states}

Trigger Fault 1901
    ${RU_IP}=     Get RU IP from ASIK
    Connect Ssh To Asix
    Run Keyword If  '${sw_version}' == 'SBTS22R1'      Connect to RU via Asik   ${RU_IP}    root    w@=EIj7P6R0bVy85OjCVa^ho&8
    ...     ELSE    Connect to RU via Asik   ${RU_IP}    serviceuser    Pl(FzaYj5~c5;q
    ssh.execute     sudo mv ${file_to_rename} ${temp_filename}    connection=ru
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix

Cancel Fault 1901
    ${RU_IP}=     Get RU IP from ASIK
    Connect Ssh To Asix
    Run Keyword If  '${sw_version}' == 'SBTS22R1'      Connect to RU via Asik   ${RU_IP}    root    w@=EIj7P6R0bVy85OjCVa^ho&8
    ...     ELSE    Connect to RU via Asik   ${RU_IP}    serviceuser    Pl(FzaYj5~c5;q
    ssh.execute     sudo mv ${temp_filename} ${file_to_rename}   connection=ru
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix
#    ...                         cli.reset_site                       cli.reset_site

Fault 1901 cycle and overload
   log to console   starting Fault 1901 cycle
    run_keyword and ignore error    Disconnect from RU
   run keyword and ignore error   Disconnect Ssh From Asix
   Trigger Fault 1901
   run keyword and ignore error  Ru Reset from Admin CLI without waiting for result  1
   FOR    ${INDEX}  IN RANGE    0   3
       wait until keyword succeeds    180sec    1sec    Check components status while recovery action after 1901
       wait until keyword succeeds    340sec    2sec    Fault Should Be Present   1901
       wait until keyword succeeds    120sec    1sec    Check recovery status    RMOD
       Wait For Fault with Alarm to disappear      1901    7101
       log to console    ${${INDEX}+1} recovery action done
   END
   Wait For Fault with Alarm to appear      1901    7111
   Cancel Fault 1901
   Ru Reset from Admin CLI  1




Check recovery status
   [Arguments]     ${recovery_component}
   ${states}         run keyword if    '${recovery_component}'=='BBMOD'    Get BBMOD Statuses    1
   ...     ELSE       Get RU Statuses   1
   ${procedural}=    get from dictionary    ${states}    proceduralStatus
   should be equal    ${procedural}    initializing
   ${availability}=    get from dictionary    ${states}    availabilityStatus
   should be equal    ${availability}    Offline
   ${operational}=    get from dictionary    ${states}    operationalState
   should be equal    ${operational}    Disabled
   ${administrative}=    get from dictionary    ${states}    administrativeState
   should be equal    ${administrative}    Unlocked


Wait for gNB autonomous reset as a recovery action
    Wait Until Keyword Succeeds  5 min  30 sec  SYSTEM Check If Gnb Is Not Pingable
    Wait Until Keyword Succeeds  5 min  30 sec  SYSTEM Check If Gnb Is Pingable

Wait For OnAir without cell status
    [Documentation]
    ...    to check if cOAM BTS is in OnAir
    [Arguments]    ${timeout}=15 min
    wait until keyword succeeds    ${timeout}
    ...                            300s
    ...                            Check RU while OnAir       30

Wait For OnAir
    [Documentation]
    ...    to check if cOAM BTS is in OnAir
    [Arguments]    ${timeout}=15 min
    wait until keyword succeeds    ${timeout}
    ...                            300s
    ...                            Check Cell while OnAir      1


Wait For OnAir on first BBMOD
    [Documentation]
    ...    to check if cOAM BTS is in OnAir
    [Arguments]    ${timeout}=15 min
    wait until keyword succeeds    ${timeout}
    ...                            30s
    ...                            Check Cell while OnAir       1



Wait For OnAir on second BBMOD
    [Documentation]
    ...    to check if cOAM BTS is in OnAir
    [Arguments]    ${timeout}=15 min
    wait until keyword succeeds    ${timeout}
    ...                            30s
    ...                            Check Cell while OnAir       3


Get Virtual Nodes
    ${virtual_nodes}    trs_ssh.Execute    command=lxc-ls    connection=asik
    [Return]    ${virtual_nodes}

Virtual Node Should Be Available
    [Arguments]
    ...    ${virtual_node}
    #...    ${connection_ssh}=asik
    ${list_VNs}    Get Virtual Nodes
    collections.List Should Contain Value    ${list_VNs}    ${virtual_node}

Get Processes From Virtual Node
    [Arguments]
    ...    ${virtual_node}=0xe002
    #...    ${connection_ssh}=asik
    trs_ssh.Send command    command=lxc-attach -n ${virtual_node} -- ps aux    connection=asik
    ${VN_processes}    trs_ssh.Read Output    connection=asik
    [Return]    ${VN_processes}

Extract PID from process
    [Arguments]
    ...     ${process}
    ${strip1}  fetch from left    ${process}      0.
    ${strip2}  remove string   ${strip1}   root
    ${pid}  strip string    ${strip2}
    set test variable  ${pid}

Process On Virtual Node Should Be Running
    [Arguments]
    #...    ${process_command}
    ...    ${vn_address}=0xe002
    #...    ${connection_ssh}=asik

    ${VN_processes}    Get Processes From Virtual Node    ${vn_address}    connection_ssh=asik
    ${process}      string.Get Lines Matching Pattern   ${VN_processes}      *${proc}*
    Should Not Be Empty    ${process}
    Extract PID from process    ${process}

Wait for BBMOD autonomous reset as a recovery action
    Wait Until Keyword Succeeds  4 min  0 sec  Check if BBMOD is pingable

Wait for second BBMOD autonomous reset as a recovery action
    Wait Until Keyword Succeeds  4 min  0 sec  Check if second BBMOD is pingable

Kill Process On Virtual Node
    [Arguments]
    ...    ${vn_address}=0xe002
    ...    ${connection_ssh}=asik
    ...    ${pid}=${pid}
    trs_ssh.Execute    command=lxc-attach -n ${vn_address} -- kill -9 ${pid}    connection=${connection_ssh}

Check BBMOD while BBMOD reset
    [Arguments]  ${component_index}
    ${states}   Get BBMOD Statuses          ${component_index}
    Check availability & operational & administrative & procedural while Reset BBMOD    ${states}

Check SMOD while BBMOD reset
    [Arguments]  ${component_index}
    ${states}   Get SMOD Statuses       ${component_index}
    Check availability & operational & administrative & procedural while Reset SMOD      ${states}

Check SMOD while first BBMOD reset
    [Arguments]  ${component_index}
    ${states}   Get SMOD Statuses       ${component_index}
    Check availability & operational & administrative & procedural while SMOD with OnAir on second BBMOD    ${states}

Check SMOD while second BBMOD reset
    [Arguments]  ${component_index}
    ${states}   Get SMOD Statuses       ${component_index}
    Check availability & operational & administrative & procedural while SMOD with onAir on first BBMOD     ${states}

Trigger Fault 1907
    Connect to RU via Asik
    trs_ssh.Execute     command=echo "65 37 5 0" > /mnt/factory/configs/unit/hwid.txt     connection=ru
    trs_ssh.Execute     command=rfsw-reboot     connection=ru

Cancel Fault 1907
    log to console      Canceling Fault 1907
    Connect Ssh To Asix
    Connect to RU via Asik
    trs_ssh.Execute     command=echo "65 37 0 0" > /mnt/factory/configs/unit/hwid.txt     connection=ru
    trs_ssh.Execute     command=rfsw-reboot             connection=ru
    log to console      Fault 1907 Canceled

Wait for Fault 1907 activate and deactivate X times
    [Arguments]  ${count}=3
    FOR    ${INDEX}  IN RANGE    0   ${count}
       log to console  activating and deactivating Fault with Alarm for the ${INDEX} time
       Wait For Fault with Alarm to appear   1907      7101
       Wait For Fault with Alarm to disappear   1907      7101
    END

Wait For Fault with Alarm to appear
    [Arguments]  ${FaultID}     ${AlarmID}
    wait until keyword succeeds  340      0.1    Fault Should Be Present   ${FaultID}
    wait until keyword succeeds  20       0.1     Alarm Should Be Present   ${AlarmID}

Wait For Fault with Alarm to disappear
    [Arguments]  ${FaultID}     ${AlarmID}
    wait until keyword succeeds  240      0.1   Fault Should Not Be Present   ${FaultID}
    wait until keyword succeeds  20       0.1     Alarm Should Not Be Present   ${AlarmID}

Alarm Should Be Present
    [Documentation]
    ...  ___
    [Arguments]    ${alarm_id}
#    Log To Console    KW - Alarm Should Be Present alarm_id=${alarm_id}
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
#    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Contain    ${list}    ${alarm_id}

Alarm Should Not Be Present
    [Documentation]
    ...  ___
    [Arguments]    ${alarm_id}
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    ${list}     convert to string  ${alarm_id_list}
    Should Not Contain    ${list}    ${alarm_id}

Reset Site
    log to console      performing Site Reset
    admin_cli.reset_site


Revert 1907 changes
    log to console      reverting changes due to test failure
    wait until keyword succeeds  120    20      Cancel Fault 1907
    wait until keyword succeeds  240    20      Fault Should Not Be Present   1907
    Reset Site
    Wait For OnAir

Revert RF changes in case of fail
    run keyword if test failed      Revert 1907 changes


Trunk or Branch
    ${split_build}=  Split String  ${OUT_ACTIVE_SW}  separator=\_
    ${trunk_flag}=   Get from list  ${split_build}   2
    Set Suite Variable  ${trunk_flag}
    ${sw_version}=   Get from list  ${split_build}   0
    Set Suite Variable  ${sw_version}
