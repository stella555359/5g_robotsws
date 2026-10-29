*** Settings ***
Documentation
...   author: Dawid Chuchnowski, dawid.chuchnowski@nokia.com
...   maintainer: Dawid Chuchnowski, dawid.chuchnowski@nokia.com

Library    DateTime
Library    taf.sbts.oam.coam.admin              WITH NAME       admin
Library    taf.rfrl.bts.commissioning             WITH NAME    commission
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library    taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME      gnbru
Library   taf.rfrl.utilities.test_config.DefaultFileLocation        WITH NAME    dfl
Library    CNI121082_keywords.py

*** Variables ***
${skip_commissioning}=     ${NONE}
@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  Service account root access is enabled
...                  Ethernet port security is disabled

*** Keywords ***
Suite Setup
    [Documentation]    Performs commissioning on gNB
    Log Action To Console    Suite Setup started
    Run Keyword If    '${skip_commissioning}'!='true'    Perform Commissioning on BTS
    Log Action To Console    Suite Setup finished   new_line_after=True

Perform Commissioning on BTS
    [Documentation]    Perform full commissioning on gNB and waits for all cells to reach onAir state
    ...                :param scfc_file:     name of SCF
    Sleep    2min    reason=Wait for RMODs to be powered on
    ${commissioning_files_directory}=    dfl.Get Commissioning Dir
    Log Action To Console    Common Suite Setup With OnAir Test Line Preparation
    Common Suite Setup With OnAir Test Line Preparation     increase_timeout_for_update_sw=1800
    Log Action To Console    Wait until Setup is onAir
    Wait Until Keyword Succeeds    12min    15s    gnbcell.Verify All Cells Are Onair   du_id=0

Check RU has been powered off for energy saving
    [Documentation]    Verifies that RMOD reaches poweroff availabiity status
    Log Action To Console    Check RU has been powered off for energy saving
    gnbru.Verify Radio Unit Statuses     operational_state=disabled  availability_status=poweroff
    ...    power_state=POWEROFFBYES    usage_state=idle

Check that all RUs are online
    [Documentation]    Verifies that all Radio Units reached online state
    Log Action To Console    Check that all RUs are online
    gnbru.Verify Radio Unit Statuses     operational_state=enabled  availability_status=Online
    ...    power_state=AWAKE    usage_state=Active

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs message to console
    ...                :param msg:     message logged
    ...                :datatime:    determines if include timestamp in log
    ...                :new_line_before:    determines if include new line before log
    ...                :new_line_after:    determines if include new line after log

    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    --> [${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    --> ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Verify that no alarms regarding wrong FPFH and FSEE configuration are raised
    [Documentation]    Verifies that faults 4538, 1517 and 1429 are inactive
    Log Action To Console   Verify that no alarms regarding wrong FPFH and FSEE configuration are raised
    ${active_alarms}=    Get active alarms
    Log     ${active_alarms}
    Assert alarm inactive    faultId=4538
    Assert alarm inactive    faultId=1517
    Assert alarm inactive    faultId=1429

Verify that external alarm is raised
    [Documentation]    Verifies that fault 1429 is active
    Log Action To Console   Verify that external alarm is raised
    ${active_alarms}=    Get active alarms
    Log     ${active_alarms}
    Assert alarm active    faultId=1429

Trigger alarm via EAC controller
    [Arguments]    ${rpi_address}    ${command}    ${username}=pi    ${password}=pi
    [Documentation]    Logs into EAC controller emulator (RaspberryPi) and executes command to trigger alarm
    ...                :rpi_addrss:    IP address of RPi
    ...                :command:    command to be executed
    ...                :username:    username used to login on RPi
    ...                :password:    password used to login on RPi
    Log Action To Console   Trigger alarm via EAC controller
    Execute command on rpi
    ...     username=${username}
    ...     password=${password}
    ...     address=${rpi_address}
    ...     command=${command}
    Sleep    10s

Switch off alarm from EAC controller
    [Arguments]    ${rpi_address}    ${command}    ${username}=pi    ${password}=pi
    [Documentation]    Logs into EAC controller emulator (RaspberryPi) and executes command to switch off alarm
    ...                :rpi_addrss:    IP address of RPi
    ...                :command:     command to be executed
    ...                :username:    username used to login on RPi
    ...                :password:    password used to login on RPi
    Log Action To Console   Switch off alarm from EAC controller
    Execute command on rpi
    ...     username=${username}
    ...     password=${password}
    ...     address=${rpi_address}
    ...     command=${command}

Wait for radio module to reach POWEROFFBYES power state
    Log Action To Console    Wait for radio module to reach POWEROFFBYES power state
    Sleep    8min    reason=Wait for radio module to reach POWEROFFBYES power state

Block NRCELL-1
    admin.Block cell
    ...         timeout=60
	...         dist_name=MRBTS-75050/NRBTS-75050/NRCELL-1

Unblock NRCELL-1
    admin.Unblock cell
    ...         timeout=60
    ...         dist_name=MRBTS-75050/NRBTS-75050/NRCELL-1
