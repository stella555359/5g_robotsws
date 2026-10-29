*** Settings ***
Documentation
...   Keywords file for CB011086
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)

Library     keywords.py
Resource    ../../CB012194/resources/keywords.robot
#Resource    taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Library     taf/rfrl/procedures/resources/python/snapshot/Snapshot.py    WITH NAME    snapshot
Library     ta_uexgate
Library     Collections

*** Variables ***
${OMIT_CUS_LTE_L3CALL}=     ${False}

*** Keywords ***
Try set 5G_SOURCE_SW
    TRY
        ${build}=    csv4all_utilities.Get Source SW
    EXCEPT    FatalError: No Build selected
        Log    Unable to set 5G_SOURCE_SW based on CM_TAGS, setting from 5G_TARGET_SW    level=WARN
        ${build}=    Set Variable  ${5G_TARGET_SW}
    END
    RETURN    ${build}

Custom Set Suite UUF Variables
    Run Keyword And Ignore Error
    ...    Log    CM_EXECUTION_ID: %{CM_EXECUTION_ID}\nCM_ARTIFACTS: %{CM_ARTIFACTS}\nCM_TAGS: %{CM_TAGS}
    ${5G_TARGET_SW}=    Run Keyword If  '${5G_TARGET_SW}'=='${None}'
    ...                     csv4all_utilities.Get Target SW
    ...                 ELSE
    ...                     Set Variable  ${5G_TARGET_SW}
    Set Suite Variable    $5G_TARGET_SW
    ${5G_SOURCE_SW}=    Run Keyword If  '${5G_SOURCE_SW}'=='${None}'
    ...                     Try set 5G_SOURCE_SW
    ...                 ELSE
    ...                     Set Variable  ${5G_SOURCE_SW}
    Set Suite Variable    $5G_SOURCE_SW

    ${QC_ID_UPGRADE}=    Set Variable
    ...    ${qc_id_mapping['${5G_TARGET_SW}'.split('_', 1)[0]]['qc_upgrade'] if 'SBTS' in '${5G_TARGET_SW}' else None}
    Set Suite Variable    $QC_ID_UPGRADE
    ${QC_ID_RESET}=    Set Variable
    ...    ${qc_id_mapping['${5G_TARGET_SW}'.split('_', 1)[0]]['qc_site_reset'] if 'SBTS' in '${5G_TARGET_SW}' else None}
    Set Suite Variable    $QC_ID_RESET
    ${QC_ID_RESET29}=    Set Variable
    ...    ${qc_id_mapping['${5G_TARGET_SW}'.split('_', 1)[0]].get('qc_site_reset29') if 'SBTS' in '${5G_TARGET_SW}' else None}
    Set Suite Variable    $QC_ID_RESET29

    &{NODE1}    Create Dictionary    testline_object=${tl.gnbs[0]}
    ...                              source_sw=${5G_SOURCE_SW}
    ...                              target_sw=${5G_TARGET_SW}
    ...                              custom_allowed_alarms=${CUSTOM_ALARMS}
    Set Suite Variable    $NODE1

    @{NODES}    Create List    ${NODE1}
    Set Suite Variable    $NODES

    Log    5G_SOURCE_SW: ${5G_SOURCE_SW}\n5G_TARGET_SW: ${5G_TARGET_SW}
    Log    QC_ID_UPGRADE: ${QC_ID_UPGRADE}\nQC_ID_RESET: ${QC_ID_RESET}\nQC_ID_RESET29: ${QC_ID_RESET29}
    Log    NODES: ${NODES}


Cleanup After Test 01
    Log To Console    Cleanup after t01
    ${delta}=  prepare_parameters_delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
    ...  parameter=enDcSyncStatus  value=synchronous
    ${delta}=  prepare_parameters_delta    delta=${delta}    distname=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    ...  parameter=actExtN77Support  value=false
    ${delta}=  prepare_parameters_delta    delta=${delta}    distname=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...  parameter=holdOverModeUsed  value=false
    ${delta}=  prepare_parameters_delta    delta=${delta}    distname=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-10
    ...  parameter=inactivityTimer  value=300
    Wait Until Keyword Succeeds    2 min    50 sec    Perform Delta Commissioning On gNB    delta=${delta}    timeout=${600}


Custom UUF Test Setup
    Log To Console    Test Setup...
    common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}

Custom UUF Test Teardown
    Log To Console    Test Teardown...
    Wait For Site To Be Onair  timeout=300
    Run Keyword If Test Passed    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

L3 Call 07
    [Arguments]    ${arg1}=${None}    ${arg2}=${None}    #dummy args necessary for UU4ALL KWs
    Log To Console    L3 Call 07 with args: ${arg1} ${arg2}
    Run Keyword If    not ${OMIT_L3CALL}    L3 Call CUS LTE with NR    cus_lte_cells=2,7,11    nr_cells=2    cell_select_by=${None}

L3 Call CUS LTE with NR
    [Arguments]
    ...    ${cus_lte_cells}
    ...    ${nr_cells}=${None}
    ...    ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...    ${lte_deviation}=${LTE_DEVIATION}
    ...    ${nr_deviation}=${NR_DEVIATION}
    ...    ${cell_select_by}=barring

    Log To Console    L3 Call CUS LTE with NR
    Log To Console    lte cells: ${cus_lte_cells} ; nr cells: ${nr_cells}
    Log To Console    duration: ${duration} ; lte_deviation: ${lte_deviation} ; nr_deviation: ${nr_deviation}

    IF    ${OMIT_CUS_LTE_L3CALL}
        Log    OMIT_CUS_LTE_L3CALL = True, omiting CUS L3 call    console=True
    ELSE
        ta_uexgate.Run Uex Command    sib_status
        ta_uexgate.Run Uex Command    wait_for_ovhd    cell=${cus_lte_cells}    timeout=3    logging_interval=10
        Sleep    5
        ta_uexgate.Run Uex Command    ue_attach    id=${cus_lte_cells}    cell=${cus_lte_cells}    #attach 1 UE per cell with the same id
        Sleep    2
        @{lte_cell_list}=    Convert [${cus_lte_cells}] to list
        @{result_list}=    Set Variable    ${EMPTY}
        Log To Console    ----- LTE CUS DL Part -----
        FOR    ${cell}    IN    @{lte_cell_list}
            @{tput_dl}=    Convert Unit to uexgate    ${TPUT_LTE_CELL_MAPPING}[${cell}][0]
            Log To Console    Start traffic on lte cell: ${cell} with ${tput_dl}[0] ${tput_dl}[1] DL
            Run Keyword And Warn On Failure    Wait Until Keyword Succeeds    3x    10 sec
            ...    ta_uexgate.Run Uex Command    trf_data_start    stats=true
            ...    dir=dl    protocol=udp    ${tput_dl}[1]=${tput_dl}[0]    ue=${cell}

        END
        Stabilize LTE CUS tput    timeout=180
            ...    cell_list=${lte_cell_list}    t_type=dl    expected_dict=${TPUT_LTE_CELL_MAPPING}    deviation=${LTE_DEVIATION}
        ta_uexgate.Run Uex Command    trf_data_stats    clear    ue=${cus_lte_cells}    cell=${cus_lte_cells}
    END

    @{nr_cell_list}=    Convert [${nr_cells}] to list
    Run Keyword If    ${nr_cells}
    ...    L3 Call on NR Cells    @{nr_cell_list}    duration=${duration}    deviation=${nr_deviation}    cell_select_by=${cell_select_by}
    ...  ELSE
    ...    Sleep    ${duration}    reason=Time to measure tputs

    IF    ${OMIT_CUS_LTE_L3CALL}
        Log    OMIT_CUS_LTE_L3CALL = True, omiting CUS L3 call verification    console=True
    ELSE
        FOR    ${cell}    IN    @{lte_cell_list}
            Log    ${cell}
            ${result}=    Run Keyword And Warn On Failure
            ...    Verify Throughput In CUS Cell
            ...    cell_id=${cell}    t_type=dl    expected=${TPUT_LTE_CELL_MAPPING}[${cell}][0]    deviation=${LTE_DEVIATION}
            Append to List    ${result_list}    ${result}
            Run Keyword And Warn On Failure     ta_uexgate.Run Uex Command    trf_data_stop    ue=${cell}

        END
        Log To Console    ----- LTE CUS UL Part -----
        FOR    ${cell}    IN    @{lte_cell_list}
            @{tput_ul}=    Convert Unit to uexgate    ${TPUT_LTE_CELL_MAPPING}[${cell}][1]
            Log To Console    Start traffic on lte cell: ${cell} with ${tput_ul}[0] ${tput_ul}[1] UL
            Run Keyword And Warn On Failure    Wait Until Keyword Succeeds    3x    10 sec
            ...    ta_uexgate.Run Uex Command    trf_data_start    stats=true
            ...    dir=ul    protocol=udp    ${tput_ul}[1]=${tput_ul}[0]    ue=${cell}

        END
        Stabilize LTE CUS tput    timeout=180
            ...    cell_list=${lte_cell_list}    t_type=ul    expected_dict=${TPUT_LTE_CELL_MAPPING}    deviation=${LTE_DEVIATION}
        ta_uexgate.Run Uex Command    trf_data_stats    clear    ue=${cus_lte_cells}    cell=${cus_lte_cells}

        Sleep    ${duration}    reason=Time to measure tputs
        FOR    ${cell}    IN    @{lte_cell_list}
            Log    ${cell}
            ${result}=    Run Keyword And Warn On Failure
            ...    Verify Throughput In CUS Cell
            ...    cell_id=${cell}    t_type=ul    expected=${TPUT_LTE_CELL_MAPPING}[${cell}][1]    deviation=${LTE_DEVIATION}
            Append to List    ${result_list}    ${result}
            Run Keyword And Warn On Failure     ta_uexgate.Run Uex Command    trf_data_stop    ue=${cell}

        END

        Log    ${result_list}
        FOR    ${res}    IN    @{result_list}    # TODO: remove Run Keyword And Warn On Failure when stable CUS tput
            Run Keyword And Warn On Failure    Should Be Equal    ${res}[0]    PASS    msg=${res}[1]
        END
    END

    [Teardown]    Run Keywords
    ...    ta_uexgate.Run Uex Command    sib_status    AND
    ...    Run Keyword And Warn On Failure
        ...    ta_uexgate.Run Uex Command    ue_detach   all

