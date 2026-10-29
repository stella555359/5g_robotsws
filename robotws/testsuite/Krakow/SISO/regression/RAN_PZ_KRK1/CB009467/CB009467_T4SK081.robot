*** Settings ***
Documentation
...   Test suite for regression testing of feature CB009467
...   author: Michal Haszko, Tomasz Krol
...   contact: michal.haszko@nokia.com, tomasz.krol@nokia.com


Library         ./resources/ru_keywords.py
Library         ./resources/GnbCellCustomKeywords.py
Library         Collections
Library         taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations                   WITH NAME    gnb_ru
Library         taf.rfrl.bts.devices.du.cell_operations.GenericCellOperations           WITH NAME    gnbgenericcells
Library         taf/rfrl/procedures/resources/python/connections.py                     WITH NAME    connections
Library         taf/rfrl/procedures/resources/python/status_check/status_check.py       WITH NAME    status_check
Library         taf/rfrl/procedures/resources/python/timer/timer.py                     WITH NAME    timer

Resource        taf/rfrl/ue/robot/REAL_UE.robot
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/procedures/SISO/General_SiSo_Auto_Radio_Module_Reset_From_GUI.robot

Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags        CA_VRF_KRK    RF50

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               prefix_tag=8CC_NSA
...               list_of_additional_allowed_alarms=@{ADDITIONAL_ALLOWED_ALARMS}

Suite Teardown    Common Suite Teardown

Test Setup        Custom Test Precondition with Require UE
Test Teardown     Common Postconditions With Watching Alarms and Restore Configuration If Test Failed

*** Variables ***
${ENABLE_RACH_OBSERVER}         ${False}
${SHOULD_BE_REPORTED}=          True
@{CRITICAL_FAULTS}=             0010  0016  1806  1868  4341  4352  4383
${RF_RESET_ITERATIONS}=         3
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_ST
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
@{CUSTOM_ALARMS}=               ${None}
@{ADDITIONAL_ALLOWED_ALARMS}	Create List
...                                 Wifi Enabled Alarm


# TPUT VARIABLES
${tput_duration}                60s
${tput_dl}                      4000 Mbits/sec
${tput_ul}                      500 Mbits/sec
${tput_protocol}                TCP
${tput_parallel_streams_dl}     8
${tput_parallel_streams_ul}     2
${congestion_mode}              reno
${tput_size_packet_ul}          1320B


*** Test Cases ***

[1][1.0] CB009467_C_006_1C_FR2_with_24R1_N_CB009467_1c_configuration_RF_Reset
    ${RMOD_IDS}       Get All Ru Ids
    ${connection}=    connections.get_default_admin_connection_alias
    ${ITERATIONS}     Evaluate    ${RF_RESET_ITERATIONS}+1
    FOR   ${iteration}    IN RANGE    1    ${ITERATIONS}
        Robot Log Iteration     RF_Reset with L3 call verification, Iteration: ${iteration}/${RF_RESET_ITERATIONS}
        FOR    ${rmod_id}    IN    @{RMOD_IDS}
            ${ALIAS}=       run keyword if    ${rmod_id}==2   set variable    UE_2
            ...     ELSE    set variable    UE_1
            ${ul_tput}=     run keyword if    ${rmod_id}==2   set variable    ${tput_ul}
            ...     ELSE    set variable    250 Mbits/sec
            ${dl_tput_parallel_streams}=     run keyword if    ${rmod_id}==2   set variable    ${tput_parallel_streams_dl}
            ...     ELSE    set variable    4
            ${ul_tput_parallel_streams}=     run keyword if    ${rmod_id}==2   set variable    ${tput_parallel_streams_ul}
            ...     ELSE    set variable    1
            ${LOCK_CELLS}=    get cells not related with ru    ${rmod_id}
            change defaultLnRelGnbCellId    ${rmod_id}
            gnbalarm.Allow Alarm    No connection to unit
            Reset RMOD    ${rmod_id}    ${connection}   GNB
            wait_until_keyword_succeeds                 3 min
            ...                                         3 sec
            ...                                         gnb_ru.verify radio unit statuses
            ...                                         ru_id=${rmod_id}
            ...                                         operational_state=disabled
            FOR    ${cell_id}    IN    @{LOCK_CELLS}
                gnbcell.Verify Cell Is Onair            cell_id=${cell_id}
            END
            gnbru.Wait For All Radio Units To Be Online
            gnbcell.Wait For All Cells To Be Onair      timeout=450
            sleep   60
            Verify L3 Call Data Transfer DL&UL
            ...                                 duration=${tput_duration}
            ...                                 alias=${ALIAS}
            ...                                 tput_dl=${tput_dl}
            ...                                 tput_ul=${ul_tput}
            ...                                 protocol=${tput_protocol}
            ...                                 linux_congestion_dl=${congestion_mode}
            ...                                 parallel_streams_dl=${dl_tput_parallel_streams}
            ...                                 parallel_streams_ul=${ul_tput_parallel_streams}
            ...                                 size_packet_ul=${tput_size_packet_ul}
            gnbalarm.Disallow Alarm    No connection to unit
        END
    END

[1][1.0] CB009467_F_002_4A_FR2_with_24R1_N_CB009467_4a_configuration_Cell_lock_unlock_on_Extension_module_and_main_radio
    @{EXTENSION_CELLS_IDS}       Get All Cell IDs Linked to All Extension RMODs
    @{MAIN_CELLS_IDS}            Get All Cell IDs Linked to All Main RMODs
    ${CELL_GRP_IDS}              get all cell grp ids

    FOR    ${cell_grp_id}    IN     @{CELL_GRP_IDS}
        ${ID}=          run keyword if    ${cell_grp_id}==0  set variable    1
        ...     ELSE    set variable    4
        change defaultLnRelGnbCellId    ${ID}
        ${LOCK_CELLS}=  get cells not related with cell grp    ${cell_grp_id}
        ${dl_tput}=     run keyword if    ${cell_grp_id}==0  set variable    3500 Mbits/sec
        ...     ELSE    set variable    500 Mbits/sec
        ${ul_tput}=     run keyword if    ${cell_grp_id}==0   set variable    250 Mbits/sec
        ...     ELSE    set variable    125 Mbits/sec
        ${dl_tput_parallel_streams}=     run keyword if    ${cell_grp_id}==0   set variable    8
        ...     ELSE    set variable    1
        ${ul_tput_parallel_streams}=     run keyword if    ${cell_grp_id}==0   set variable    2
        ...     ELSE    set variable    1
        FOR    ${cell_id}    IN    @{LOCK_CELLS}
            gnbcell.Lock Cell                   cell_id=${cell_id}    administrative_state=${True}
            Sleep                               5
            gnbcell.Verify Cell is Locked       cell_id=${cell_id}
        END
        sleep    30
        Verify L3 Call Data Transfer DL&UL
        ...                                 duration=${tput_duration}
        ...                                 alias=UE_1
        ...                                 tput_dl=${dl_tput}
        ...                                 tput_ul=${ul_tput}
        ...                                 protocol=${tput_protocol}
        ...                                 linux_congestion_dl=${congestion_mode}
        ...                                 parallel_streams_dl=${dl_tput_parallel_streams}
        ...                                 parallel_streams_ul=${ul_tput_parallel_streams}
        ...                                 size_packet_ul=${tput_size_packet_ul}
        FOR    ${cell_id}    IN    @{LOCK_CELLS}
            gnbcell.UnLock Cell                 cell_id=${cell_id}    administrative_state=${True}
            gnbcell.Verify Cell is UnLocked     cell_id=${cell_id}
        END
    END

    FOR    ${iteration}    IN RANGE    1    4
        Lock_Unlock_Cells_and_Verify_Tput    cell_type=EXT      CELLS_IDS=${EXTENSION_CELLS_IDS}
        Lock_Unlock_Cells_and_Verify_Tput    cell_type=MAIN     CELLS_IDS=${MAIN_CELLS_IDS}
    END


[1][1.0] CB009467_E_002_3A_FR2_with_24R1_N_CB009467_3a_configuration_RF_Deletion_and_Addition
    Backup BTS Configuration Before Test
    ${RMOD_IDS}     Get All RU IDs
    ${CELL_GRP_IDS}     get all cell grp ids

    FOR    ${cell_grp_id}    IN    @{CELL_GRP_IDS}
        ${rmod_id}=     evaluate    ${cell_grp_id}+1
        #${RMOD_CELLS}=  get cells not related with ru   ru_id=${rmod_id}
        ${RMOD_CELLS}=      get cells not related with cell grp    ${cell_grp_id}
        ${ALIAS}=       run keyword if    ${rmod_id}==3   set variable    UE_2
        ...     ELSE    set variable    UE_1
        ${dl_tput}=     run keyword if    ${rmod_id}==3   set variable    ${tput_dl}
        ...     ELSE    set variable    2000 Mbits/sec
        ${ul_tput}=     run keyword if    ${rmod_id}==3   set variable    ${tput_ul}
        ...     ELSE    set variable    250 Mbits/sec
        ${dl_tput_parallel_streams}=     run keyword if    ${rmod_id}==3   set variable    ${tput_parallel_streams_dl}
        ...     ELSE    set variable    4
        ${ul_tput_parallel_streams}=     run keyword if    ${rmod_id}==3   set variable    ${tput_parallel_streams_ul}
        ...     ELSE    set variable    1
        change defaultLnRelGnbCellId    ${rmod_id}
        FOR    ${cell_id}    IN    @{RMOD_CELLS}
            gnbcell.Lock Cell                   cell_id=${cell_id}    administrative_state=${True}
            Sleep                               5
            gnbcell.Verify Cell is Locked       cell_id=${cell_id}
        END
        Sleep   60
        Verify L3 Call Data Transfer DL&UL
        ...                                 duration=${tput_duration}
        ...                                 alias=${ALIAS}
        ...                                 tput_dl=${dl_tput}
        ...                                 tput_ul=${ul_tput}
        ...                                 protocol=${tput_protocol}
        ...                                 linux_congestion_dl=${congestion_mode}
        ...                                 parallel_streams_dl=${dl_tput_parallel_streams}
        ...                                 parallel_streams_ul=${ul_tput_parallel_streams}
        ...                                 size_packet_ul=${tput_size_packet_ul}
        FOR    ${cell_id}    IN    @{RMOD_CELLS}
            gnbcell.UnLock Cell                 cell_id=${cell_id}    administrative_state=${True}
            gnbcell.Verify Cell is UnLocked     cell_id=${cell_id}
        END
        Delete RMOD from Configuration                  rmod_id=${rmod_id}
        gnbru.Verify All Radio Units are Online         skip_ru_if_not_configured=${True}
        gnbcell.Verify All Cells are Onair
        Add RMOD to Configuration           rmod_id=${rmod_id}
        gnbru.Wait For All Radio Units To Be Online
        gnbcell.Wait For All Cells To Be Onair      timeout=450

        FOR    ${cell_id}    IN    @{RMOD_CELLS}
            gnbcell.Lock Cell                   cell_id=${cell_id}    administrative_state=${True}
            Sleep                               5
            gnbcell.Verify Cell is Locked       cell_id=${cell_id}
        END
        Verify L3 Call Data Transfer DL&UL
        ...                                 duration=${tput_duration}
        ...                                 alias=${ALIAS}
        ...                                 tput_dl=${dl_tput}
        ...                                 tput_ul=${ul_tput}
        ...                                 protocol=${tput_protocol}
        ...                                 linux_congestion_dl=${congestion_mode}
        ...                                 parallel_streams_dl=${dl_tput_parallel_streams}
        ...                                 parallel_streams_ul=${ul_tput_parallel_streams}
        ...                                 size_packet_ul=${tput_size_packet_ul}
        FOR    ${cell_id}    IN    @{RMOD_CELLS}
            gnbcell.UnLock Cell                 cell_id=${cell_id}    administrative_state=${True}
            gnbcell.Verify Cell is UnLocked     cell_id=${cell_id}
        END
    END

#[1][1.0] CB009467_F_008_4E_FR2_with_24R1_N_CB009467_4e_configuration
#    # to samo co 1a prawdopodobnie
#
[1][1.0] CB009467_E_004_3B_FR2_with_24R1_N_CB009467_3b_configuration_Cell_Deletion_and_Addition
    Backup BTS Configuration Before Test
    ${CELL_GRP_IDS}     get all cell grp ids

    FOR    ${cell_grp_id}    IN    @{CELL_GRP_IDS}
        ${LOCK_CELLS}=  get cells not related with cell grp    ${cell_grp_id}
        ${ALIAS}=       run keyword if    ${cell_grp_id}==2   set variable    UE_2
        ...     ELSE    set variable    UE_1
        ${dl_tput}=     run keyword if    ${cell_grp_id}==2  set variable    ${tput_dl}
        ...     ELSE    set variable    2000 Mbits/sec
        ${ul_tput}=     run keyword if    ${cell_grp_id}==2   set variable    ${tput_ul}
        ...     ELSE    set variable    250 Mbits/sec
        ${dl_tput_parallel_streams}=     run keyword if    ${cell_grp_id}==2   set variable    ${tput_parallel_streams_dl}
        ...     ELSE    set variable    4
        ${ul_tput_parallel_streams}=     run keyword if    ${cell_grp_id}==2   set variable    ${tput_parallel_streams_ul}
        ...     ELSE    set variable    1
        ${ID}=          evaluate    ${cell_grp_id}+1
        log to console    ${ID}
        change defaultLnRelGnbCellId    ${ID}
        Delete Cell Grp From Configuration                     ${cell_grp_id}
        gnbcell.Verify All Cells are Onair
        Add Cell Grp To Configuration                          ${cell_grp_id}
        gnbcell.Wait For All Cells To Be Onair                 timeout=450
        FOR    ${cell_id}    IN    @{LOCK_CELLS}
            gnbcell.Lock Cell                   cell_id=${cell_id}    administrative_state=${True}
            Sleep                               5
            gnbcell.Verify Cell is Locked       cell_id=${cell_id}
        END
        sleep    30
        Verify L3 Call Data Transfer DL&UL
        ...                                 duration=${tput_duration}
        ...                                 alias=${ALIAS}
        ...                                 tput_dl=${dl_tput}
        ...                                 tput_ul=${ul_tput}
        ...                                 protocol=${tput_protocol}
        ...                                 linux_congestion_dl=${congestion_mode}
        ...                                 parallel_streams_dl=${dl_tput_parallel_streams}
        ...                                 parallel_streams_ul=${ul_tput_parallel_streams}
        ...                                 size_packet_ul=${tput_size_packet_ul}
        FOR    ${cell_id}    IN    @{LOCK_CELLS}
            gnbcell.UnLock Cell                 cell_id=${cell_id}    administrative_state=${True}
            gnbcell.Verify Cell is UnLocked     cell_id=${cell_id}
        END
    END


*** Keywords ***
Custom Test Precondition with Require UE
    REAL_UE.Prepare Ue for L3 Call      capabilities=REAL_UE_DOWN        alias=UE_1
    REAL_UE.Prepare Ue for L3 Call      capabilities=REAL_UE_UP          alias=UE_2
    Common Preconditions With Watching Alarms

Lock Cells
    [Arguments]     ${CELLS_LIST}

    FOR    ${cell_id}    IN    @{CELLS_LIST}
        gnbcell.Lock Cell                   cell_id=${cell_id}    administrative_state=${True}
        Sleep                               5
        gnbcell.Verify Cell is Locked       cell_id=${cell_id}
    END

Unlock Cells
    [Arguments]     ${CELLS_LIST}

    FOR    ${cell_id}    IN    @{CELLS_LIST}
        gnbcell.UnLock Cell                 cell_id=${cell_id}    administrative_state=${True}
        gnbcell.Verify Cell is UnLocked     cell_id=${cell_id}
    END
Lock_Unlock_Cells_and_Verify_Tput
    [Arguments]    ${cell_type}     ${CELLS_IDS}

    ${cells_to_lock}=           get cells to lock    ${CELLS_IDS}
    ${ID}=          run keyword if    '${cell_type}'=='MAIN'   set variable    1
    ...     ELSE    set variable    4
    change defaultLnRelGnbCellId    ${ID}
    FOR    ${cell_id}    IN    @{CELLS_IDS}
        gnbcell.Lock Cell                   cell_id=${cell_id}    administrative_state=${True}
        Sleep                               5
        gnbcell.Verify Cell is Locked       cell_id=${cell_id}
    END
    ${dl_tput}=     run keyword if    '${cell_type}'=='MAIN'   set variable    3500 Mbits/sec
    ...     ELSE    set variable    500 Mbits/sec
    ${ul_tput}=     run keyword if    '${cell_type}'=='MAIN'   set variable    250 Mbits/sec
    ...     ELSE    set variable    125 Mbits/sec
    ${dl_tput_parallel_streams}=     run keyword if    '${cell_type}'=='MAIN'   set variable    8
    ...     ELSE    set variable    1
    ${ul_tput_parallel_streams}=     run keyword if    '${cell_type}'=='MAIN'   set variable    2
    ...     ELSE    set variable    1

    FOR    ${cell_id}    IN    @{CELLS_IDS}
        gnbcell.UnLock Cell                 cell_id=${cell_id}    administrative_state=${True}
        gnbcell.Verify Cell is UnLocked     cell_id=${cell_id}
    END
    gnbcell.Wait For All Cells To Be Onair      timeout=450
    FOR    ${cell_id}    IN    @{cells_to_lock}
        gnbcell.Lock Cell                   cell_id=${cell_id}    administrative_state=${True}
        Sleep                               5
        gnbcell.Verify Cell is Locked       cell_id=${cell_id}
    END
    sleep    30
    Verify L3 Call Data Transfer DL&UL
    ...                                 duration=${tput_duration}
    ...                                 alias=UE_1
    ...                                 tput_dl=${dl_tput}
    ...                                 tput_ul=${ul_tput}
    ...                                 protocol=${tput_protocol}
    ...                                 linux_congestion_dl=${congestion_mode}
    ...                                 parallel_streams_dl=${dl_tput_parallel_streams}
    ...                                 parallel_streams_ul=${ul_tput_parallel_streams}
    ...                                 size_packet_ul=${tput_size_packet_ul}
    FOR    ${cell_id}    IN    @{cells_to_lock}
        gnbcell.UnLock Cell                 cell_id=${cell_id}    administrative_state=${True}
        gnbcell.Verify Cell is UnLocked     cell_id=${cell_id}
    END
    gnbcell.Wait For All Cells To Be Onair      timeout=450
