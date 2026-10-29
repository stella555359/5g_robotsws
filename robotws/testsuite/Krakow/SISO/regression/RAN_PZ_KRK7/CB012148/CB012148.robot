*** Settings ***
Documentation
...   Test suite for testing feature CB012148
...   author: Wioleta Święs, Ewelina Kiełbasa
...   contact: wioleta.swies@nokia.com, ewelina.kielbasa@nokia.com

Resource    ./resources/keywords.robot


Suite Setup    Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                 should_5G_neighbour_be_changed=${False}
...                                                                 increase_time_for_checking_bbmod=600
...                                                                 increase_timeout_for_update_sw=1800
...                                                                 increase_time_for_checking_radios=2100
...                                                                 increase_time_for_checking_cells=700
...                                                                 swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt

Suite Teardown    Common Suite Teardown

Test Setup       Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms


*** Variables ***
${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_PACKET_SIZE}               1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_DEVIATION}                 5%
${UE_TYPE}                           quectel
${DATA_TRANSFER_DEFAULT_DURATION}    300s
${PARALLEL_STREAM_DL}                4
${PARALLEL_STREAM_UL}                2
${SCF_USED}                          1

*** Test Cases ***
CB012148_Manual_SiSo_CALL_L3_data_call_4T4R
    [Tags]    tc1
    Set Test Variable    ${expected_tput_NR_DL}    740Mbits/sec

    Set Test Variable    ${expected_tput_NR_UL}    75Mbits/sec

    Check data transfer via Quectel     throughput_DL=${expected_tput_NR_DL}
    ...                                 throughput_UL=${expected_tput_NR_UL}
    ...                                 parallel_streams_DL=${PARALLEL_STREAM_DL}
    ...                                 parallel_streams_UL=${PARALLEL_STREAM_UL}

CB012148_Manual_SiSo_SM_BTS_Block_Site_4T4R
    [Tags]    tc2
    [Setup]    Run Keywords
    ...        Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    RAT blocked    AND
    ...        Common Preconditions With Watching Alarms

    Set Test Variable    ${expected_tput_NR_DL}               740Mbits/sec
    Set Test Variable    ${expected_tput_NR_UL}               75Mbits/sec
    Set Test Variable    ${DEFAULT_DEVIATION}                 40%
    Set Test Variable    ${DATA_TRANSFER_DEFAULT_DURATION}    120s

    gnbbbu.Block RAT       NR
    Sleep    30sec
    gnbbbu.Unblock RAT     NR
    gnbcell.Wait For All Cells To Be Onair    timeout=120
    Check L3 Call On Cells
    ...                       throughput_DL=${expected_tput_NR_DL}
    ...                       throughput_UL=${expected_tput_NR_UL}
    ...                       parallel_streams_DL=${PARALLEL_STREAM_DL}
    ...                       parallel_streams_UL=${PARALLEL_STREAM_UL}

#CB012148_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Tags]    tc3
#    [Setup]    Run Keywords
#    ...        Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Fault signature for crash or failure    AND
#    ...        Common Preconditions With Watching Alarms
#
#    Set Test Variable    ${expected_tput_NR_DL}    390Mbits/sec
#    Set Test Variable    ${expected_tput_NR_UL}    75Mbits/sec
#    Set TesT Variable    ${logs_path}    ${LOG_PATH}/${TEST_NAME}
#
#    Load and Activate SCF and Wait for OnAir    SCF_GNB=2T2R_main_gnb.xml
#    ...                                         SCF_ASIR=2T2R_asir.xml
#
#    General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
#
#    Check data transfer via Quectel     throughput_DL=${expected_tput_NR_DL}
#    ...                                 throughput_UL=${expected_tput_NR_UL}
#    ...                                 parallel_streams_DL=${PARALLEL_STREAM_DL}
#    ...                                 parallel_streams_UL=${PARALLEL_STREAM_UL}


CB012148_Manual_SiSo_SM_cell_lock_unlock_(administrative_state_change)_from_GUI
    [Tags]    tc4
    Set Test Variable    ${expected_tput_NR_DL}    390Mbits/sec
    Set Test Variable    ${expected_tput_NR_UL}    75Mbits/sec
    Set Test Variable    ${DEFAULT_DEVIATION}      40%
    Set Test Variable    ${DATA_TRANSFER_DEFAULT_DURATION}    120s

    Run Keyword If    $SCF_USED == '2'
    ...    Log to console    No need to upload new SCF, already there.
    ...  ELSE
    ...     Load and Activate SCF and Wait for OnAir    SCF_GNB=2T2R_main_gnb.xml
            ...                                         SCF_ASIR=2T2R_asir.xml

    @{all_cell_ids}    gnbcell.Get All Global Cell Ids
    FOR    ${cell}     IN     @{all_cell_ids}
        Verify Cell Statuses    cell_id=${cell}
        ...                     operational_state=Enabled
        ...                     procedural_status=configured
        ...                     administrative_state=Unlocked

        Lock gNB Cell    cell_id=${cell}
        Wait Until Keyword Succeeds    10min    20s    Verify gNB Cell is Locked    cell_id=${cell}
        Unlock gNB Cell    cell_id=${cell}
        Wait Until Keyword Succeeds    10min    20s    Verify gNB Cell is Unlocked    cell_id=${cell}

       sg7keywords.Toggle Cells Barred State  rat=nr  expected_cell_id=${cell}  to_be_barred=${False}
       Check data transfer via Quectel     throughput_DL=${expected_tput_NR_DL}
       ...                                 throughput_UL=${expected_tput_NR_UL}
       ...                                 parallel_streams_DL=${PARALLEL_STREAM_DL}
       ...                                 parallel_streams_UL=${PARALLEL_STREAM_UL}
    END

    [Teardown]    Run Keywords    sg7keywords.Toggle Cells Barred State    rat=nr    to_be_barred=${False}
    ...                    AND    Common Postconditions With Watching Alarms

CB012148_reset_pRRH_via_ASiR_WebEM
    [Tags]    tc5
    [Setup]    Run Keywords
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Failure detected on assigned antennas    AND
    ...    Common Preconditions With Watching Alarms

    Run Keyword If    $SCF_USED == '2'
    ...    Log to console    No need to upload new SCF, already there.
    ...  ELSE
    ...     Load and Activate SCF and Wait for OnAir    SCF_GNB=2T2R_main_gnb.xml
            ...                                         SCF_ASIR=2T2R_asir.xml

    @{antenna_ids}=    gnb_asir.Get All Antenna Ids
    FOR    ${id}    IN    @{antenna_ids}
        gnb_asir.Reset Antenna    ant_id=${id}
    END
    gnbcell.Wait For All Cells To Be Onair    timeout=120
