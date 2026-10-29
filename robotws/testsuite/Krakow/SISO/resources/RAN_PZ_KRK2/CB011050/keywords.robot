*** Settings ***
Documentation
...   File contains Robot variables and keywords to assist in performing common tasks
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Library     resources.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
L3 call teardown
    ${status}    Run keyword and return status    gnbcell.Unblock all cells
    Run keyword if    ${status}==${False}    Reset gNB
    Wait until keyword succeeds    360 sec    10 sec   gnbcell.Verify All Cells are OnAir
    gnb_alarm.Disallow alarm    Cell blocked

Block all cells before L3 call
    gnb_alarm.Allow alarm    Cell blocked
    gnbcell.Block all cells
    Wait until keyword succeeds    60 sec    10 sec    gnbcell.Verify all cells are blocked

Unblock cell before L3 call
    [Arguments]    ${cell_id}
    gnbcell.Unblock cell    cell_id=${cell_id}
    gnbcell.Wait for cell to be onAir    cell_id=${cell_id}
    gnbcell.Verify cell is unblocked    cell_id=${cell_id}

Block cell after L3 call
    [Arguments]    ${cell_id}
    gnbcell.Block cell    cell_id=${cell_id}
    Wait until keyword succeeds    60 sec    10 sec    gnbcell.Verify cell is blocked    cell_id=${cell_id}

Analyse L3 call status
    [Arguments]    ${l3_call_status}    ${cell_id}
    Run keyword if    '${l3_call_status[0]}'=='FAIL'    Run keywords
    ...    Log to console    Tput on cell ${cell_id} failed: ${l3_call_status[1]}
    ...    AND
    ...    Set test variable    ${L3_CALL_STATUS}    ${False}

Perform L3 call on selected cell
    [Arguments]    ${cell_id}    ${tput_dl}    ${tput_ul}    ${deviation}
    ...            ${parallel_streams_dl}=4    ${parallel_streams_ul}=2    ${attach_timeout}=${20}
    Unblock cell before L3 call    ${cell_id}
    Log to console    Run tput on cell ${cell_id}
    ${status}    Run keyword and ignore error
    ...    Verify L3 call data transfer DL&UL
    ...    duration=60s
    ...    tput_dl=${tput_dl}
    ...    tput_ul=${tput_ul}
    ...    protocol=tcp
    ...    deviation=${deviation}
    ...    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet=1400B
    ...    alias=${UE}
    ...    attach_timeout=${attach_timeout}
    Block cell after L3 call    ${cell_id}
    Analyse L3 call status
    ...    l3_call_status=${status}
    ...    cell_id=${cell_id}

Perform SISO reset all pRRHs
    gnb_alarm.Allow alarm    Failure detected on assigned antennas
    SISO reset all pRRHs
    [Teardown]    gnb_alarm.Disallow alarm    Failure detected on assigned antennas

Perform SISO block unblock all pRRHs
    gnb_alarm.Allow alarm    Failure detected on assigned antennas
    SISO block unblock all pRRHs
    [Teardown]    gnb_alarm.Disallow alarm    Failure detected on assigned antennas

Perform RU module reset from GUI
    Reset all gNB radio units from GUI
    Sleep    60s    Wait for RU reset
    gnbru.Wait for all radio units to be online
    Wait until keyword succeeds     360 sec     10 sec   gnbcell.Verify all cells are onAir
    Verify gNB is onAir

SISO reset all pRRHs
    [Arguments]    ${prrh_to_reset}=${None}
    Action with pRRHs    action=Reset    prrh_id=${prrh_to_reset}
    Wait until keyword succeeds    600 sec    15 sec    gnbcell.Verify all cells are onAir

SISO block unblock all pRRHs
    Action with pRRHs    action=Block
    Sleep    5s    Wait for blocks
    Action with pRRHs    action=Unblock
    Wait until keyword succeeds    600 sec    15 sec    gnbcell.Verify all cells are onAir

SISO Lock unlock all ASiR hubs
    Action with ASiR hub    action=Lock
    Sleep    5s    Wait for locks
    Action with ASiR hub    action=Unlock
    Wait until keyword succeeds    600 sec    15 sec    gnbcell.Verify all cells are onAir

SISO reset all ASiR hubs
    Action with ASiR hub    action=Reset
    Wait until keyword succeeds    600 sec    15 sec    gnbcell.Verify all cells are onAir

Perform RU lock unlock
    gnbru.Lock all radio unit
    gnbru.Verify all radio units statuses
    ...    administrative_state=Locked
    ...    operational_state=Enabled
    gnbcell.Verify all cells statuses
    ...    availability_status=dependency
    ...    operational_state=disabled
    gnbru.Unlock all radio unit
    gnbru.Wait for all radio units to be online
    Wait until keyword succeeds    360 sec    10 sec    gnbcell.Verify all cells are onAir
    Verify gNB is onAir

Permorm NR RAT reset
    gnbbbu.RAT reset    rat_type=NR
    gnbcell.Verify all cells statuses    operational_state=disabled
    Wait until keyword succeeds    360 sec    10 sec    gnbcell.Verify all cells are onAir
    Verify gNB is onAir

Perform RU power reset of selected units
    [Arguments]    @{ru_list}
    Allow alarm    Unit power reset
    Allow alarm    No connection to unit
    FOR    ${ru_id}    IN    @{ru_list}
        Power reset gNB radio unit    radio_unit_id=${ru_id}
    END
    Sleep    60s    Wait for power reset to be finished
    gnbru.Wait for all radio units to be online
    Wait until keyword succeeds    360 sec    10 sec    gnbcell.Verify all cells are onAir
    Verify gNB is onAir
    Disallow alarm    No connection to unit

Perform BTS site block
    Allow alarm    BTS blocked
    gnbbbu.Block BTS    timeout=120
    Sleep    15s    Wait for gNB to be blocked
    gnbbbu.Verify BTS states    blocking_state=blocked
    gnbbbu.Unblock BTS    timeout=360
    Sleep    60s    Wait for gNB reset
    Wait until keyword succeeds    360 sec    10 sec    gnbcell.Verify all cells are onAir
    Verify gNB is onAir

Perform RAT block unblock for 5G LTE GSM
    [Arguments]    ${rats_cell_ids}
    Allow alarm    RAT blocked
    gnbbbu.Block rat    rat=NR
    Verify cells for blocked RAT    @{rats_cell_ids["NR"]}
    Verify cells for unblocked RAT    @{rats_cell_ids["LTE"]}
    Verify cells for unblocked RAT    @{rats_cell_ids["GSM"]}
    gnbbbu.Verify RAT is blocked    rat=NR
    gnbbbu.Unblock RAT    rat=NR
    Wait until keyword succeeds    60 sec    10 sec    gnbcell.Verify all cells are onAir
    gnbbbu.Block RAT    rat=LTE
    Verify cells for blocked RAT    @{rats_cell_ids["LTE"]}
    Verify cells for unblocked RAT    @{rats_cell_ids["NR"]}
    Verify cells for unblocked RAT    @{rats_cell_ids["GSM"]}
    gnbbbu.Verify RAT is blocked    rat=LTE
    gnbbbu.Unblock RAT    rat=LTE
    Wait until keyword succeeds    60 sec    10 sec    gnbcell.Verify all cells are onAir
    gnbbbu.Block rat    rat=GSM    timeout=120
    Verify cells for blocked RAT    @{rats_cell_ids["GSM"]}
    Verify cells for unblocked RAT    @{rats_cell_ids["NR"]}
    Verify cells for unblocked RAT    @{rats_cell_ids["LTE"]}
    gnbbbu.Verify RAT is blocked    rat=GSM
    gnbbbu.Unblock RAT    rat=GSM
    Wait until keyword succeeds    60 sec    10 sec    gnbcell.Verify all cells are onAir
    Verify gNB is onAir

Verify cells for blocked RAT
    [Arguments]    @{rat_cell_ids}
    FOR    ${cell_id}    IN    @{rat_cell_ids}
        gnbcell.Verify cell is blocked    cell_id=${cell_id}
    END

Verify cells for unblocked RAT
    [Arguments]    @{rat_cell_ids}
    FOR    ${cell_id}    IN    @{rat_cell_ids}
        gnbcell.Verify cell is onAir    cell_id=${cell_id}
    END

Perform all cells block unblock
    gnb_alarm.Allow alarm    Cell blocked
    gnbcell.Block all cells
    Sleep    60s    Wait for cells to be blocked
    gnbcell.Verify all cells are blocked
    gnbcell.Unblock all cells
    Sleep    15s    Wait for cells to be unblocked
    gnb_alarm.Disallow alarm    Cell blocked
    gnbcell.Verify all cells are unblocked
    Wait until keyword succeeds    360 sec    10 sec    gnbcell.Verify all cells are onAir
    Verify gNB is onAir

Perform RAT reset for 5G LTE
    [Arguments]    ${rats_cell_ids}
    gnbbbu.rat_reset    rat_type=NR
    Verify cells disabled after RAT reset    @{rats_cell_ids["NR"]}
    Verify cells enabled for online RAT    @{rats_cell_ids["LTE"]}
    Wait until keyword succeeds    360 sec    10 sec    gnbcell.Verify all cells are onAir
    Verify gNB is onAir
    Allow alarm    Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    gnbbbu.rat_reset    rat_type=LTE
    Verify cells disabled after RAT reset    @{rats_cell_ids["LTE"]}
    Verify cells enabled for online RAT    @{rats_cell_ids["NR"]}
    Wait until keyword succeeds    360 sec    10 sec    gnbcell.Verify all cells are onAir
    Verify gNB is onAir
    Disallow alarm    Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability

Verify cell operational state
    [Arguments]    ${cell_id}    ${state}
    Verify cell statuses    cell_id=${cell_id}    operational_state=${state}

Verify cells disabled after RAT reset
    [Arguments]    @{rat_cell_ids}
    FOR    ${cell_id}    IN    @{rat_cell_ids}
        Verify cell operational state    cell_id=${cell_id}    state=disabled
    END

Verify cells enabled for online RAT
    [Arguments]    @{rat_cell_ids}
    FOR    ${cell_id}    IN    @{rat_cell_ids}
        Verify cell operational state    cell_id=${cell_id}    state=enabled
    END
