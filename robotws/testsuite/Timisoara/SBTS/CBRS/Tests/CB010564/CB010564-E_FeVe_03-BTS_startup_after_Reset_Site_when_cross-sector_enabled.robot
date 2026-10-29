*** Settings ***
Documentation
...    = Author =
...    karol.sadowski@nokia.com
...    = Maintainer =
...    karol.sadowski@nokia.com
...    = Reviewer =
...    aleksandra.chudzik@nokia.com
...    piotr.lukaszewicz@nokia.com
...    Review link:


*** Keywords ***
CB010564-E_FeVe_03-BTS_startup_after_Reset_Site_when_cross-sector_enabled
    [Documentation]    Requirement: OAM_REQ_CBRS_92, OAM_REQ_CBRS_570
    ...                Purpose: This test case verifies system behaviour during site reset with additional RD flag
    ...                actCbrsRecover set to true for one scenario and false for second one. It is expected to perform
    ...                new registration procedure if actCbrsRecover=false.
    ...
    ...                Test Steps:
    ...                Step 0: Prepare BTS cross-sector and SAS configuration
    ...                Step 1: Start SAS simulator and enable CBRS on BTS
    ...                Step 2: Disable actCbrsRecover RD flag in swconfig
    ...                Step 3: Perform site reset
    ...                Step 4: Check if new registration occurred
    ...                Step 5: Enable actCbrsRecover RD flag in swconfig
    ...                Step 6: Perform site reset
    ...                Step 7: Check if NO new registration occurred - grant extended in hb procedure


    ${bts_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarm}   Create Dictionary    fault_id=6826    fault_name=SAS Registration Failure    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarm}
    ${num_of_cells}   Get Number of Cells    enb_id=${bts_id}

    @{actCbrsRecover_enable}   Create List    0x450019=1
    @{actCbrsRecover_disable}   Create List    0x450019=0

    Log To Console    ${\n}Step 0: Setting preconditions...
    Remove Swconfig Flag    0x450019
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Enable CBRS Feature On eNB    actCbrsEnhMeas=false

    Log To Console    Starting SAS...
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_03/SAS_Sim.conf
    Wait Until Keyword Succeeds    6x    10s    Required CBSD Status Should Be Reached
    ...    expected_status=Registered    enb_id=${bts_id}

    Log To Console    Waiting for cells to be OnAir...
    Wait For All Cells To Be OnAir    wait_time=10min
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Log To Console    ${\n}Step 1: Reset Site while actCbrsRecover flag is not defined in swconfig - default value is actCbrsRecover enabled
    ${log_reset1_start}   Get Time
    taf.sbts.oam.coam.admin.Reset Site    connection=${alias}    wait_for_reconnection=True
    Wait For All Cells To Be OnAir    wait_time=10min
    ${log_reset1_end}   Get Time

    Log To Console    ${\n}Step 2: Add and apply r&d flag: ${actCbrsRecover_enable}
    Add Swconfig Flags     flag_list=${actCbrsRecover_enable}
    Wait For All Cells To Be OnAir    wait_time=10min

    Log To Console    ${\n}Step 3: Reset Site while actCbrsRecover is enabled
    ${log_reset2_start}   Get Time
    taf.sbts.oam.coam.admin.Reset Site    connection=${alias}    wait_for_reconnection=True
    Wait For All Cells To Be OnAir    wait_time=10min
    ${log_reset2_end}   Get Time

    Log To Console    ${\n}Step 4: Add and apply r&d flag: ${actCbrsRecover_disable}
    Add Swconfig Flags     flag_list=${actCbrsRecover_disable}
    Wait For All Cells To Be OnAir    wait_time=10min

    Log To Console    ${\n}Step 5: Reset Site while actCbrsRecover is disabled
    ${log_reset3_start}   Get Time
    taf.sbts.oam.coam.admin.Reset Site    connection=${alias}    wait_for_reconnection=True
    Wait For All Cells To Be OnAir    wait_time=10min
    ${log_reset3_end}   Get Time

    Log To Console    ${\n}Step 6: Logs evaluation...
    Wait Until Keyword Succeeds    6x    10s    Check If TS Version Is As Expected    ${bts_id}    ${alias}    2.0

    ${parsed_log_reset1}   Parse Sas Log File    log_file_name=${sas_logs_dir}    date_start=${log_reset1_start}    date_stop=${log_reset1_end}
    ${parsed_log_reset2}   Parse Sas Log File    log_file_name=${sas_logs_dir}    date_start=${log_reset2_start}    date_stop=${log_reset2_end}
    ${parsed_log_reset3}   Parse Sas Log File    log_file_name=${sas_logs_dir}    date_start=${log_reset3_start}    date_stop=${log_reset3_end}

    ${registrationResponse_reset1}   Extract Values From Sas Log
    ...    log_name=${parsed_log_reset1}     parameter=responseCode    data_type=registrationResponse
    ${registrationResponse_reset2}   Extract Values From Sas Log
    ...    log_name=${parsed_log_reset2}     parameter=responseCode    data_type=registrationResponse
    ${registrationResponse_reset3}   Extract Values From Sas Log
    ...    log_name=${parsed_log_reset3}     parameter=responseCode    data_type=registrationResponse

    Should Be True    '${registrationResponse_reset1}'=='[]'    msg=It is expected to recover cbrs service after reset without re-registration!
    Should Be True    '${registrationResponse_reset2}'=='[]'    msg=It is expected to recover cbrs service after reset without re-registration!

    @{expected_response}   Create List    ${105}    ${105}    ${105}    ${0}    ${0}    ${0}
    Should Be Equal    ${registrationResponse_reset3}    ${expected_response}
    ...    msg=It is expected to perform re-registration after reset, which 1st suppose to fail!

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Remove Swconfig Flag    0x450019     AND
    ...                           Disable CBRS Feature On eNB    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${bts_id}
