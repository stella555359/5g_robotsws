*** Settings ***
Documentation
...  AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/36575
...
...  *****************
...  Basic information
...  *****************
...
...  Step 1: Check Uptime For Specific Radio Unit
...  Checking the uptime for the specified radio unit.
...
...  Step 2: L3 Call
...  Performing L3 call.
...
...  Step 3: Activate CPRI RU reset resiliency
...  Activating the CPRI RU reset resiliency.
...
...  Step 4: Verify value of cntrldResetMplaneBreakTime
...  Verifying the value of cntrldResetMplaneBreakTime.
...
...  Step 5: Verify value of uncntrldResetMplaneBreakTime
...  Verifying the value of uncntrldResetMplaneBreakTime.
...
...  Step 6: Trigger L1Soc Crash And Verify Result
...  Triggering L1Soc crash and verifying the result.
...
...  Step 7: Verify RU State After Reset Recovery
...  Verifying the RU state after reset recovery.
...
...  Step 8: L3 Call
...  Performing L3 call.
...
...  Step 9: Deactivate CPRI RU reset resiliency
...  Deactivating the CPRI RU reset resiliency.
...
...  ******************
...  History of changes
...  ******************
...  - 10.01.2025 - Initial creation

Resource    ./../../Resources/Setup/setup_and_teardown.robot
Resource    ./SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_controlled_reset.robot
Resource    ./SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_uncontrolled_reset.robot


*** Variables ***
${prompt}=    ':~#|>|$|@'
${L1soc_unit_crash_command}=    pkill    -6    HWRIcom
${L1soc_unit_crash_command_singlecore}=    pkill    -6    HWRIcom


*** Keywords ***
SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset
    [Documentation]
    ...  Description:
    ...  Executes the resiliency test for CPRI RU to BTS-DU with uncontrolled reset.
    ...  Author: piotr.korczynski@nokia.com
    ...  Maintainer: piotr.korczynski@nokia.com
    Common Test Setup    tools_to_setup=syslog_ADMIN
    Logging With Timestamp
    ...    message=SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_uncontrolled_reset will be executed
    ...    style=ONGOING
    ${ru_uptime}=    Create Dictionary    &{EMPTY}
    Set Test Variable    ${RU_UPTIME}
    FOR    ${radio_unit}    IN    @{CUSTOM_RADIO_UNIT_LIST}
        ${bts_id}=    Precondition For RU Uncontrolled Resiliency Reset Test    ${radio_unit}
        Step 1 Check Uptime For Specific Radio Unit    ${bts_id}    ${radio_unit}
        Step 2 L3 Call
        Step 3 Activate CPRI RU reset resiliency    ${bts_id}
        Step 4 Verify value of cntrldResetMplaneBreakTime    ${bts_id}
        Step 5 Verify value of uncntrldResetMplaneBreakTime    ${bts_id}

        Step 6 Trigger L1Soc Crash And Verify Result    ${bts_id}    ${radio_unit}
        Step 7 Verify RU State After Reset Recovery
        Step 8 L3 Call
        Step 9 Deactivate CPRI RU reset resiliency
    END
    [Teardown]    Common Test Teardown

Step 6 Trigger L1Soc Crash And Verify Result
    [Arguments]    ${bts_id}    ${radio_unit}    ${timeout}=240
    [Documentation]
    ...  Description:
    ...  Triggers L1Soc crash and verifies the result.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | yes  | BTS identifier                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | radio_unit             | yes  | Radio unit identifier                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                | no   | Timeout for the reset operation                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: piotr.korczynski@nokia.com
    ...  Maintainer: piotr.korczynski@nokia.com
    Logging With Timestamp
    ...    message=Step 6 Trigger L1Soc Crash And Verify Result
    ...    style=STEP
    ...    frame=${TRUE}
    ${scf_cablink_primary}=    Get From Dictionary    ${CFG.RF_INFO['${radio_unit}']}    scf_cablink_primary
    ${bts_info}=    admin.Get Bts Info    connection=${bts_id}
    admin.Add Allowed Alarm    faultId=6450    connection=${bts_id}
    ${basebandModules}=    Get From Dictionary    ${bts_info}    basebandModules
    ${systemModules}=    Get From Dictionary    ${bts_info}    systemModules
    ${cables}=    Get From Dictionary    ${bts_info}    cables
    FOR    ${system_module}    IN    @{systemModules}
#    Continue For Loop If    not '${system_module['activeRole']}' == 'Primary'
        ${systemModule_productName}=    Get From Dictionary    ${system_module}    productName
        Exit For Loop
    END
    IF    ('ASOG' or 'ASOF' or 'ASOE') in '${systemModule_productName}'
        ${L1soc_unit_crash_command}=    Set Variable    ${L1soc_unit_crash_command_singlecore}
        ${platform_type}=    Set Variable    singlecore
    ELSE
        ${L1soc_unit_crash_command}=    Set Variable    ${L1soc_unit_crash_command}
        ${platform_type}=    Set Variable    multicore
    END
    FOR    ${cable}    IN    @{cables}
        Continue For Loop If    '${cable['linkMode']['configuration']}' == 'False'
        ${bbmod_id}=    Set Variable    ${False}
        Exit For Loop If    '${platform_type}'=='singlecore'
        FOR    ${cablink}    IN    @{scf_cablink_primary}
            Exit For Loop If    '${cable['id']['configuration']}' == '${cablink}'
        END
        Continue For Loop If    not '${cable['id']['configuration']}' == '${cablink}'
        ${bbmod_first_status}=    Run Keyword And Return Status    Should Match Regexp    ${cable['firstEndPointId']['internal']}    BBMOD|SMOD
        IF    ${bbmod_first_status}
            ${bbmod_cablink}=    Set Variable    ${cable['firstEndPointId']['internal']}
        ELSE
            ${bbmod_cablink}=    Should Match Regexp    ${cable['secondEndPointId']['internal']}    BBMOD|SMOD
        END
        ${bbmod_id}=    split_string_from_right    ${bbmod_cablink}    /    max_split=1
        Exit For Loop If    ${bbmod_id}
    END
    FOR    ${baseBand}    IN    @{basebandModules}
        Continue For Loop If    not '${baseBand['id']['internal']}' == '${bbmod_id[0]}'
        ${baseBandId}=    Get From Dictionary    ${baseBand}    id
        ${baseBandserialNumber}=    Get From Dictionary    ${baseBand}    serialNumber
        Exit For Loop
    END
    FOR    ${systemModule}    IN    @{systemModules}
        ${systemModule_serialNumber}=    Get From Dictionary    ${systemModule}    serialNumber
    END
    IF    '${platform_type}' != 'singlecore'
        ${BBMOD_serial_number}=    Set Variable    ${baseBandserialNumber}
    ELSE
        ${BBMOD_serial_number}=    Set Variable    ${systemModule_serialNumber}
    END
    Logging With Timestamp
    ...    message=Capacity Unit ${BBMOD_serial_number} crash is being made, please wait to recovery.
    SSH Send Command On Specific BBMOD
    ...    bts_id=${bts_id}
    ...    bbmod_serial_number=${BBMOD_serial_number}
    ...    command=${L1soc_unit_crash_command}
    ...    platform_type=${platform_type}
    ...    timeout=${timeout}

    Logging With Timestamp
    ...    message=Capacity Unit ${BBMOD_serial_number} crash executed. Wait for BBMOD crash on WebEM.

    IF    '${platform_type}' != 'singlecore'
        Run Keyword And Continue On Failure    Wait until keyword succeeds    60    5
        ...    STATE Verify States For One
        ...    node_id=${bts_id}
        ...    class=BBMOD
        ...    object=${baseBandId['internal']}
        ...    states=availabilityStatus=regex"(?i)off\\s?line", operationalState=regex"(?i)Disabled"
        ...    onair=${FALSE}
    ELSE
        Run Keyword And Continue On Failure    Wait until keyword succeeds    60    5
        ...    STATE Verify States For One
        ...    node_id=${bts_id}
        ...    class=SMOD
        ...    object=${baseBandId['internal']}
        ...    states=availabilityStatus=regex"(?i)off\\s?line"
        ...    onair=${FALSE}
    END
    admin.Add Allowed Alarm    faultId=6450    connection=${bts_id}
    admin.Add Allowed Alarm    faultId=2087    connection=${bts_id}
    admin.Add Allowed Alarm    faultId=4001    connection=${bts_id}
    Logging With Timestamp
    ...    message=Capacity Unit ${BBMOD_serial_number} crash finished. Wait for OnAir state.
    ${wncel_scf_cell_count_primary}=    Get From Dictionary    ${CFG.RF_INFO['${radio_unit}']['WNCEL']}    scf_cell_count_primary
    IF    ${wncel_scf_cell_count_primary} > 0
        Logging With Timestamp
        ...    message=WCDMA RAT detected, rat reset will be executed.
        Run Keyword And Continue On Failure    admin.Rat Reset
        ...    rat_type=WCDMA
        ...    connection=${bts_id}
        ...    timeout=120
    END
    Run Keyword And Continue On Failure    Wait until keyword succeeds    ${CONFIGURATION_STARTUP_TIMEOUT}    20
    ...    STATE Verify BTS states
    ...    node_id=${bts_id}
    ...    expected_BTS_status=OnAir
    ...    HW_check=${TRUE}
    ...    cells_check=${TRUE}
    ...    scf_check=${FALSE}
    ...    timeout=1200
    Logging With Timestamp
    ...    message=Capacity Unit ${BBMOD_serial_number} crash finished. Wait for 6450 fault.
    FM_Faults.FM Await For Fault
    ...    fault_attr=faultId=6450
    ...    node_id=${bts_id}
    ...    alarm_resource=${FAULT_6450}
    ...    timeout=1200
    Sleep    5    Wait for the system to stabilize after fault occurrence.
    Logging With Timestamp
    ...    message=Capacity Unit ${BBMOD_serial_number} crash finished. Collecting snapshot.
    admin.Collect Snapshot
    ...    target_file_name=${TEST_LOGS_PATH}/BTSFiles/${bts_id}/Crash_Snapshot_${bts_id}.zip
    ...    timeout=1200
    ...    force=${TRUE}
    ...    connection=${bts_id}
    FM_Faults.FM Await For Fault Cleared
    ...    fault_attr=faultId=6450
    ...    node_id=${bts_id}
    ...    timeout=1200
