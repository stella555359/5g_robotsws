# @Time    : 2023/8/29 10:28
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : General_SiSo_Cell_block_and_unblock.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature Common SISO

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
General_SiSo_Cell_block_and_unblock_2.1
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/29 10:30

    # Precondition
    Selenium Login And Disable Screen Lock
    ${cell_id_list}    Get All Cell Id
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=shutdownNogNBCellTmr    value=0

    # Step 1: block all nr cells, 1 cell = 1 min
    FOR    ${idx}    IN    @{cell_id_list}
        selenium_sbts.block_cell    cell_idx=${idx}
        ${cellgrp_id}    Get Cell Group From Cell    cell_id=${idx}
        Wait Until Keyword Succeeds    3 min    10 sec    Cell Should Be Blocked
        ...    cell_idx=${idx}    cell_group_idx=${cellgrp_id}
        Wait Until Keyword Succeeds    30s    3s    Verify BTS Alarm Exist
        ...    fault_id=49    fault_name=Cell blocked
    END

    # Step 1.1: check 7300&7319 if NSA
    Run Keyword If    '${gNb_CuType}'=='NSA'
    ...    Run Keywords    Wait Until Keyword Succeeds    2min    30s    Verify BTS Alarm Exist
    ...    fault_id=7319    fault_name=No X2 link available for a specific LTEENB    AND
    ...    Wait Until Keyword Succeeds    2min    30s    Verify BTS Alarm Exist
    ...    fault_id=7300    fault_name=No X2 link available

    # Step 2: unblock cell and start l3 call one by one
    FOR    ${idx}    IN    @{cell_id_list}
        selenium_sbts.unblock_cell    cell_idx=${idx}
        Wait Until Keyword Succeeds    5x    3s    UE Attach And Check Throughput With Detach
        ...    global_cell_id=${idx}
        ...    ul_tp=10M    ul_tp_threshold=1
        ...    dl_tp=10M   dl_tp_threshold=1
        selenium_sbts.block_cell    cell_idx=${idx}
    END

    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock

    # Step 3: unblock all cells
    FOR    ${idx}    IN    @{cell_id_list}
        selenium_sbts.unblock_cell    cell_idx=${idx}
    END
    Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Not Exist
    ...    fault_id=49    fault_name=Cell blocked
    Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Not Exist
    ...    fault_id=7319    fault_name=No X2 link available for a specific LTEENB
        Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Not Exist
    ...    fault_id=7300    fault_name=No X2 link available

    [Teardown]    Selenium Logout And Close Browser

Manual_SiSo_SM_LTE Cell_block_unblock
    [Documentation]    v1.0 init by yinhua.zhang@nokia-sbell.com
    ...    ${target_ru} is index of target RU
    [Arguments]    ${target_cell}    ${target_ru}    ${connection}=GNB_OAM
    # Precondition
    &{expected_cell_status_blocked}    Create Dictionary    administrativeState=unlocked
    ...    blockingState=Blocked    operationalState=disabled
    &{expected_cell_status_unblocked}    Create Dictionary    administrativeState=unlocked
    ...    blockingState=Unblocked
    ...    operationalState=enabled
    Selenium Login And Disable Screen Lock

    # Step 1: block a LTE cell
    selenium_sbts.block_cell    cell_idx=${target_cell}    technology=lte
    # check block result
    # obtain the tested LTE cell information
    Wait Until Keyword Succeeds    30s    3s    Verify Single Lte Cell Status As Expected
    ...    target_cell=${target_cell}    expected_cell_status=${expected_cell_status_blocked}
    ...    connection=${connection}
    Wait Until Keyword Succeeds    60s    3s    Verify BTS Alarm Exist
    ...    fault_id=49    fault_name=Cell blocked

    # Step 2: unblock a LTE cell
    selenium_sbts.unblock_cell    cell_idx=${target_cell}    technology=lte
    # check unblock result
    Wait Until Keyword Succeeds    30s    3s    Verify Single Lte Cell Status As Expected
    ...    target_cell=${target_cell}    expected_cell_status=${expected_cell_status_unblocked}
    ...    connection=${connection}
    Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Not Exist
    ...    fault_id=49    fault_name=Cell blocked

    # Step 3: block all LTE cells that are in same antenna line, namely belongs to same Rmod
    ${cell_id_list}    Get All Cell Id    ru_index=${target_ru}    cell_type=lte
    FOR    ${idx}    IN    @{cell_id_list}
        selenium_sbts.block_cell    cell_idx=${idx}    technology=lte
        Wait Until Keyword Succeeds    30s    3s    Verify Single Lte Cell Status As Expected
        ...    target_cell=${idx}    expected_cell_status=${expected_cell_status_blocked}
        ...    connection=${connection}
        Wait Until Keyword Succeeds    60s    3s    Verify Specified Object Alarm Exist
        ...    fault_id=49    fault_name=Cell blocked    object_name=LNCEL-${idx}
    END
    # Step 4: unblock all LTE cells that are in same antenna line, namely belongs to same Rmod
    FOR    ${idx}    IN    @{cell_id_list}
        selenium_sbts.unblock_cell    cell_idx=${idx}    technology=lte
    END
    Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Not Exist
    ...    fault_id=49    fault_name=Cell blocked
    Wait Until Keyword Succeeds    10min    15s    Verify BTS All Cells Status Is Normal State

Get Lte Cell Info By Cell Id
    [Documentation]    v1.0 initial draft by yinhua.zhang@nokia-sbell.com
    ...    ${cell_id} is Global cell ID
    [Arguments]    ${cell_id}    ${connection}=GNB_OAM
    ${cells_info}   coam.get_cells_info    cell_type=lte    connection=${connection}
    FOR    ${each_cell}    IN    @{cells_info}
        Return From Keyword If    ${cell_id}==${each_cell["globalCellId"]}    ${each_cell}
    END
    Return From Keyword    ${-1}

Verify Single Lte Cell Status As Expected
    [Documentation]    v1.0 init by yinhua.zhang@nokia-sbell.com
    [Arguments]     ${target_cell}    ${expected_cell_status}    ${connection}=GNB_OAM
    ${blocked_cell_info}    Get Lte Cell Info By Cell Id    ${target_cell}    ${connection}=GNB_OAM
    Should Not Be Equal    ${blocked_cell_info}    ${-1}
    Verify BTS Target Cell Status    ${blocked_cell_info['status']}    ${expected_cell_status}

Verify Specified Object Alarm Exist
    [Documentation]    v1.0 init by yinhua.zhang@nokia-sbell.com
    [Arguments]    ${fault_id}    ${fault_name}    ${object_name}    ${connection}=GNB_OAM
    ...    ${fault_info}=None
    @{alarm_list}    coam.get_active_alarms    connection=${connection}
    FOR    ${each_alarm}    IN    @{alarm_list}
        ${alarmObject}    Set Variable    ${each_alarm["configObjectName"]}
        Run keyword if    ${fault_id}==${each_alarm["faultId"]} and '${object_name}' in '${alarmObject}'
        ...    Verify Alarm Details    alarm_info=${each_alarm}    faultId=${fault_id}
        ...    faultName=${fault_name}    supplAlarmInfo=${fault_info}
    END

Verify Alarm Details
    [Documentation]    v1.0 init by yinhua.zhang@nokia-sbell.com
    [Arguments]    ${alarm_info}    ${faultId}    ${faultName}
    ...    ${supplAlarmInfo}=None
    Should Contain    '${alarm_info}'    'faultId': ${faultId}
    Should Contain    '${alarm_info}'    'faultName': '${faultName}'
    Run Keyword If    '${supplAlarmInfo}'!='None'    Should Contain    '${alarm_info}'
    ...    'supplAlarmInfo': '${supplAlarmInfo}'

Manual_SiSo_SM_Cell_Block_Unblock_1.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/03 17:31
    [Arguments]    ${connection}=GNB_OAM
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    # Step 1: Login to WebEM.
    Selenium Login And Disable Screen Lock

    # Step 2: Perform L3Call (voice call + PS call)  on all available bands and monitor it during next steps.
    SISO Common L3 CALL

    # Step 3: Block cells from single band,OAM KPI#17a block duration is verified
    # Start time: block request,End time: cell goes down
    wait_until_next_5_min    extra_sleep_time=2
    ${cells_info}    coam.get_cells_info    connection=GNB_OAM
    ${band_cells_dict}    ${band_length}    Get Band Cells Dict    cells_info=${cells_info}
    IF   ${band_length}==1
        ${bands}    Get Dictionary Keys    ${band_cells_dict}
        ${cell_ids}    Get From Dictionary    ${band_cells_dict}    ${bands[0]}
        ${cell_count}    Get Length    ${cell_ids}
        FOR    ${cell_id}    IN    @{cell_ids}
            selenium_sbts.block_cell    cell_idx=${cell_id}
            Wait Until Keyword Succeeds    60s    3s    Verify BTS Single Cell Status Is Block State
            ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
            Wait Until Keyword Succeeds    60s    3s    Verify BTS Alarm Exist
            ...    fault_id=49    fault_name=Cell blocked
            ...    alarm_object_id=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        END
        FOR    ${cell_id}    IN    @{cell_ids}
            selenium_sbts.unblock_cell    cell_idx=${cell_id}
            Wait Until Keyword Succeeds    60s    3s    Verify BTS Single Cell Status Is Normal State
            ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        END
        Wait Until Keyword Succeeds    60s    3s    Verify BTS Alarm Not Exist
        ...    fault_id=49    fault_name=Cell blocked
    END
    Selenium Logout And Close Browser
    # Step 4: Monitor L3Call (voice call + PS call)  on the cells where call was performed (for different bands - step 2)
    # and performed basic L3Call (voice call + PS call)  on the rest cells (optional, in case of multiple cells from
    # the same bands).
    SISO Common L3 CALL

    # Step 5: Check PM counters:
    # --M55601C00001 - Cell availability denominator
    # --M55601C00002 - Samples when the cell is available
    # --M55601C01001 - Samples when the cell is "planned unavailable"
    # --M55601C01002 - Cell state changes to ''planned unavailable''
    # --M55601C01003 - Samples when the cell is "unplanned unavailable"
    # --M55601C01004 - Cell state changes to ''unplanned unavailable''
    # Expected values of counters for 5G:
    # M55601C01002- should be equal to number of cell block operations
    # M55601C01003- should be equal to 0
    # M55601C01004- should be equal to 0
    # M55601C01001- should be equal to M55601C00001- M55601C00002
    # M55601C00002- should be equal to M55601C00001- M55601C01001
    # M55601C00001- should be equal to M55601C00002 + M55601C01001 + M55601C01003

    Sleep    90s
    wait_until_next_5_min    extra_sleep_time=60
    ${counters}        Catenate    SEPARATOR=    M55601C00001,M55601C00002,M55601C01001,M55601C01002,M55601C01003,M55601C01004
    ${counters}    coam.get_pm_counters    counter_ids=${counters}    connection=${connection}
    FOR    ${cell_id}    IN    @{cell_ids}
        ${counter_values}    Get Recent Multi Counters Value After Cell Block Unblock
        ...    ${counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-${cell_id}']['NCAV']}
        Should Be True    ${counter_values['M55601C01002']}==1
        Should Be True    ${counter_values['M55601C01003']}==0
        Should Be True    ${counter_values['M55601C01004']}==0
        ${M55601C01001}    Evaluate    ${counter_values['M55601C00001']}-${counter_values['M55601C00002']}
        Should Be True    ${counter_values['M55601C01001']}==${M55601C01001}
    END

    AlarmWatchdog.remove_allow_alarms    fault_id=49
    AlarmWatchdog.remove_allow_alarms    fault_id=7311

Get Band Cells Dict
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/03 17:28
    [Arguments]    ${cells_info}
    &{band_cells_dict}=    Create Dictionary
    FOR    ${cell_info}    IN    @{cells_info}
        ${band}    Set Variable    ${cell_info['band']}
        ${cell_id}    Set Variable    ${cell_info['globalCellId']}
        ${exist_band}    Run Keyword And Return Status    Dictionary Should Contain Key    ${band_cells_dict}    ${band}
        IF    '${exist_band}'=='True'
            Append To List    ${band_cells_dict['${band}']}    ${cell_id}
        ELSE
            @{cell_ids}    Create List    ${cell_id}
            Set To Dictionary    ${band_cells_dict}    ${band}=${cell_ids}
        END
    END
    ${band_length}    Get Length    ${band_cells_dict}
    [Return]    ${band_cells_dict}    ${band_length}
