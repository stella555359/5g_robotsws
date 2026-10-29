*** Settings ***
Documentation
...            authors:       Marcin Duplaga, marcin.duplaga@nokia.com,
...                           Justyna Michalik, justyna.michalik@nokia.com
...            maintainer:    Marcin Duplaga, marcin.duplaga@nokia.com

Resource     testsuite/Krakow/resources/former_l3_sw2/main_cls.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Library      SSHLibrary

*** Variables ***
@{faults_list}    1907    1908    1910    1911    1920    2922    2923
${ap_host}        192.168.200.1
${username}       toor4nsn
${password}       oZPS0POrRieRtu
${oamTermCmd}     /opt/UE_APP-OAM/service/OamTerm/oamTerm.py
${DELTA_MW}       ${CURDIR}/maintenanceWindow.json
${DELTA_DEL_MW}   ${CURDIR}/resources/deconfigure_maintenanceWindow.json

*** Keywords ***
Execute AP AaShell Command
    [Arguments]    ${command}
    Log To Console    Executing ${command} on AP
    SSHLibrary.Open Connection     host=${ap_host}
    SSHLibrary.Login               username=${username}    password=${password}
    ${stdout}    SSHLibrary.Execute Command    command=${oamTermCmd} ${command}
    Sleep    5s    reason=Wait for the command to take effect
    [Teardown]    SSHLibrary.Close All Connections

Lock And Unlock Single Cell Multiple Times
    [Arguments]    ${cell_id}=1    ${quantity}=10
    FOR  ${iteration}  IN RANGE  ${quantity}
        Lock Single Cell    id=${cell_id}
        Wait for Single Cell to be in Locked State    id=${cell_id}
        Unlock Single Cell    id=${cell_id}
        Wait for Single Cell to be in not Locked State    id=${cell_id}
    END

Lock And Unlock All Cells Multiple Times
    [Arguments]    ${quantity}=2
    FOR  ${iteration}  IN RANGE  ${quantity}
        cell_operations_cls.Lock All Cells
        Wait for All Cells to be Locked
        cell_operations_cls.Unlock All Cells
        Wait for All Cells to be in not Locked State
    END

Block And Unblock Single Cell Multiple Times
    [Arguments]    ${cell_id}=1    ${quantity}=10
    FOR  ${iteration}  IN RANGE  ${quantity}
        Block Single Cell    id=${cell_id}
        gnbcell.verify_cell_statuses    cell_id=${cell_id}    blocking_state=blocked
        Unblock Single Cell    id=${cell_id}
        gnbcell.verify_cell_statuses    cell_id=${cell_id}    blocking_state=unblocked
    END

Block And Unblock All Cells Multiple Times
    [Arguments]    ${quantity}=3
    FOR  ${iteration}  IN RANGE  ${quantity}
        Block All Cells
        gnbcell.verify_all_cells_statuses    blocking_state=blocked
        Unblock All Cells
        gnbcell.verify_all_cells_statuses    blocking_state=unblocked
    END

Check If Cell Is In Given State
    [Arguments]    ${state}    ${cell_id}
    gnbcell.verify_cell_statuses    cell_id=${cell_id}    availability_status=${state}

Check If All Cells Are In Given State
    [Arguments]    ${state}
    gnbcell.verify_all_cells_statuses    availability_status=${state}

Verify If Expected Alarm Is Active
    [Arguments]    ${expected_alarm}=1907
    ${connection}    coam_admin.setup_admin
    ${active_alarms}    coam_admin.Get Active Alarms
    ${alarms_history}    coam_admin.Get Alarm History
    ${found}    Set Variable    False
    FOR    ${item}    IN    @{active_alarms}
        ${id}    Get From Dictionary    ${item}    faultId
        Run Keyword If    '${id}' == '${expected_alarm}'    Set Test Variable    ${found}    True
    END
    Should Be True    ${found}
    [Teardown]    coam_admin.teardown_admin    connection=${connection}

Verify If Given Alarm Is Not Active
    [Arguments]    ${alarm}=1907
    ${connection}    coam_admin.setup_admin
    ${active_alarms}    coam_admin.Get Active Alarms
    ${alarms_history}    coam_admin.Get Alarm History
    ${not_found}    Set Variable    True
    FOR    ${item}    IN    @{active_alarms}
        ${id}    Get From Dictionary    ${item}    faultId
        Run Keyword If    '${id}' == '${alarm}'    Set Test Variable    ${not_found}    False
    END
    Should Be True    ${not_found}
    [Teardown]    coam_admin.teardown_admin    connection=${connection}

Block And Unblock Cell
    [Arguments]    ${cell_id}    ${cell_block_unblock_time}=5min
    Log to console    Block and unblock cell with ID: ${cell_id}
    gnbcell.block_cell    cell_id=${cell_id}
    Wait Until Keyword Succeeds     ${cell_block_unblock_time} sec     2 sec    gnbcell.verify_cell_is_blocked    cell_id=${cell_id}
    gnbcell.unblock_cell    cell_id=${cell_id}
    Wait Until Keyword Succeeds     ${cell_block_unblock_time} sec     2 sec    gnbcell.verify_cell_is_unblocked    cell_id=${cell_id}
    Log to console    Block and unblock cell with ID: ${cell_id} - operation finished successfully.

Trigger RF Fault With SA L3 Call
    [Arguments]    ${rf_number}    ${fault_id}    ${cell_array}
    Execute AP AaShell Command    trigger_rf_fault ${rf_number} ${fault_id} ${cell_array} CRI
    Start SA L3 Call    ue_id=1
    Start SA L3 Call    ue_id=2
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Verify SA UE Traffic Using Bearer Stats    ue_id=2
    Stop SA L3 Call    ue_id=1
    Stop SA L3 Call    ue_id=2

SA L3 Call
    Start SA L3 Call    ue_id=1
    Start SA L3 Call    ue_id=2
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Verify SA UE Traffic Using Bearer Stats    ue_id=2
    Stop SA L3 Call    ue_id=1
    Stop SA L3 Call    ue_id=2

Find Pattern In EGATE
    [Arguments]    ${file}    ${pattern}    ${grepArgs}=grep -i
    ${command}        Catenate    ${grepArgs} '${pattern}' ${file}
    ${result}         Run    ${command}
    Should Match Regexp    ${result}    (?i)${pattern}

Reset All NR Cells Multiple Times
    [Arguments]    ${quantity}=5
    ${connection}    coam_admin.setup_admin
    Repeat Keyword    ${quantity} times    coam_admin.Reset All Cells    technology=NR    connection=${connection}
    [Teardown]    coam_admin.teardown_admin    connection=${connection}

Update actForceUnitAutoReset Flag
    ${test_id}    Get Regexp Matches  ${TEST_NAME}  _([A-C])_
    Run Keyword If    '${test_id}[0]' == '_B_'    Activate actForceUnitAutoReset Flag
    ...    ELSE    Deactivate actForceUnitAutoReset Flag

Activate actForceUnitAutoReset Flag
    Change NIDD Parameter Online    dist=MRBTS-1/MNL-1/MNLENT-1/FMCADM-1    param=actForceUnitAutoReset    value=true

Deactivate actForceUnitAutoReset Flag
    Change NIDD Parameter Online     dist=MRBTS-1/MNL-1/MNLENT-1/FMCADM-1    param=actForceUnitAutoReset    value=false

Get BTS Time
    ${output}    Execute Command on GNB    command=date
    ${matches}    Get Regexp Matches    ${output}    \\d{2}:\\d{2}
    ${time}    Set Variable    ${matches[0]}
    [Return]    ${time}

Schedule Maintenance Window Start Time
    [Arguments]    ${minutes}=10
    ${bts_time}    Get BTS Time
    ${mw_scheduled_time}  Evaluate  (datetime.datetime.strptime('${bts_time}', '%H:%M') + datetime.timedelta(minutes=${minutes})).strftime('%H:%M')
    [Return]    ${mw_scheduled_time}

Configure Maintenance Window
    [Arguments]    ${scheduled_startTime}=05:00
    ${DELTA_MW_TMP}    Set Variable    ${OUTPUT DIR}/Logs/delta_maintenanceWindow_tmp.json
    ${raw_delta}    OperatingSystem.Get File    ${DELTA_MW}
    ${prepared_delta}    Replace String    ${raw_delta}    \${startTime}    ${scheduled_startTime}
    Create File     ${DELTA_MW_TMP}    ${prepared_delta}
    Upload Delta         delta=${DELTA_MW_TMP}

Deconfigure Maintenance Window
    Upload Delta         delta=${DELTA_DEL_MW}
