*** Settings ***
Documentation
...    contact: Mikolaj Kasian
Library     OperatingSystem
Library     String
Library     DateTime
Library     ute_ue
Library     taf.config.scf
Library     ta5g_pm_counters
Library     taf.collectors.syscomdump
Library     ute_fsmaccess
Resource    ../../resources/ca_INTER_RAT.robot
Library     resources/message_verifier.py
Library     resources/counters_fetching.py
Library     resources/crm_syslog_analyzer.py

*** Variables ***
${NR_DSS_CELL}     # ID of NR DSS cell
${LTE_DSS_CELL}    # ID of main tested LTE DSS cell belonging to power group

${LTE_UE_ALIAS}    # Alias of the LTE UE
${NR_UE1_ALIAS}    # Alias of the NR UE 1
${NR_UE2_ALIAS}    # Alias of the NR UE 2
${NR_UE3_ALIAS}    # Alias of the NR UE 3
${NR_UE4_ALIAS}    # Alias of the NR UE 4

*** Keywords ***
TC__CB009237_CB009238_Multi_UE_NR_DL_data_transfer__high_PDCCH_load_with_low_LTE_load
    Set Tags    CA-INTER_RAT    AUTHOR-mikolaj.kasian@nokia.com    OWNER-dawid.kurowski@nokia.com
    ...    MAINTAINER-mikolaj.kasian@nokia.com    PHASE-CRT    SW-SBTS25R2    GROUP_IN_CHARGE-VRF_2_WRO_2

    Step 1: Attach Ues
    Step 2: Generate Multiple Nr Ues Dl And Ul Load On The Nr Side
    Step 3: Generate Dl And Ul Load On Lte Side
    Step 4: Wait For Traffic Stabilize
    Step 5: Wait For Next Two Counters Periods
    Step 6: Collect Snapshots When Feature Is Off
    Step 7: Stop Data Transfer
    Step 8: Detach UEs
    Step 9: Get Initial Counters Values

    Step 10: Activate Feature

    Step 11: Attach Ues
    Step 12: Generate Multiple Nr Ues Dl And Ul Load On The Nr Side
    Step 13: Wait For Traffic Stabilize
    Step 14: Start eNB Syscomdump Collection
    Step 15: Wait For Logs Capture
    Step 16: Stop Syscomdump Collection
    Step 17: Check Nr Pdcch Load
    Step 18: Check NR DL Sharing Is Greater Than 80 Percents And Lte Load 0 Percents
    Step 19: Generate Dl And Ul Load On Lte Side
    Step 20: Wait For Traffic Stabilize
    Step 21: Start eNB Syscomdump Collection
    Step 22: Wait For Logs Capture
    Step 23: Stop Syscomdump Collection
    Step 24: Check Nr Pdcch Load
    Step 25: Check NR DL Sharing Is Greater Than 80 Percents And Lte Load About 30 Percents

    Step 26: Wait For Next Two Counters Periods
    Step 27: Collect Snapshots When Feature Is On
    Step 29: Stop Data Transfer
    Step 30: Detach UEs
    Step 31: Check Counters


Prepare Ues
    Log    === Prepare Ues ===    console=True
    Require UE    LTE_UE    ${LTE_UE_ALIAS}
    Require UE    NR_UE1    ${NR_UE1_ALIAS}
    Require UE    NR_UE2    ${NR_UE2_ALIAS}
    Require UE    NR_UE3    ${NR_UE3_ALIAS}
    Require UE    NR_UE4    ${NR_UE4_ALIAS}


Step ${index}: Attach Ues
    Log    === Step ${index}: Attach Ues ===    console=True
    Prepare UE For Data Transfer    LTE_UE    ${LTE_DSS_CELL}

    ${global_nr_cell_id} =    Get NR Global Cell ID From NR Cell ID    ${NR_DSS_CELL}
    Prepare UE For Data Transfer    NR_UE1    ${global_nr_cell_id}    connection=gNB
    Prepare UE For Data Transfer    NR_UE2    ${global_nr_cell_id}    connection=gNB
    Prepare UE For Data Transfer    NR_UE3    ${global_nr_cell_id}    connection=gNB
    Prepare UE For Data Transfer    NR_UE4    ${global_nr_cell_id}    connection=gNB


Step ${index}: Generate Multiple Nr Ues Dl And Ul Load On The Nr Side
    Log    === Step ${index}: Generate Multiple Nr Ues Dl And Ul Load On The Nr Side ===    console=True

    Start Data Transfer    NR_DT1    NR_UE1    dl    throughput=4 Mbits/sec    packet_size=1400    buffer=32M    protocol=tcp
    Log    \nNR UE 1 DL Data Transfer started    console=True

    Start Data Transfer    NR_DT2    NR_UE2    dl    throughput=4 Mbits/sec    packet_size=1400    buffer=32M    protocol=tcp
    Log    \nNR UE 2 DL Data Transfer started    console=True

    Start Data Transfer    NR_DT3    NR_UE3    dl    throughput=4 Mbits/sec    packet_size=1400    buffer=32M    protocol=tcp
    Log    \nNR UE 3 DL Data Transfer started    console=True

    Start Data Transfer    NR_DT4    NR_UE4    dl    throughput=4 Mbits/sec    packet_size=1400    buffer=32M    protocol=tcp
    Log    \nNR UE 4 DL Data Transfer started    console=True


    Start Data Transfer    NR_DT1_UL    NR_UE1    ul    throughput=1 Mbits/sec    packet_size=1400    buffer=32M    protocol=tcp
    Log    \nNR UE 1 UL Data Transfer started    console=True

    Start Data Transfer    NR_DT2_UL    NR_UE2    ul    throughput=1 Mbits/sec    packet_size=1400    buffer=32M    protocol=tcp
    Log    \nNR UE 2 UL Data Transfer started    console=True

    Start Data Transfer    NR_DT3_UL    NR_UE3    ul    throughput=1 Mbits/sec    packet_size=1400    buffer=32M    protocol=tcp
    Log    \nNR UE 3 UL Data Transfer started    console=True

    Start Data Transfer    NR_DT4_UL    NR_UE4    ul    throughput=1 Mbits/sec    packet_size=1400    buffer=32M    protocol=tcp
    Log    \nNR UE 4 UL Data Transfer started    console=True


Step ${index}: Generate Dl And Ul Load On Lte Side
    Log    === Step ${index}: Generate Dl And Ul Load On Lte Side ===    console=True

    Start Data Transfer    LTE_DT    LTE_UE    dl    throughput=1 Mbits/sec    packet_size=1400    buffer=32M    protocol=tcp
    Log    \nLTE DL data transfer started    console=True

    Start Data Transfer    LTE_DT_UL    LTE_UE    ul    throughput=1 Mbits/sec    packet_size=1400    buffer=32M    protocol=tcp
    Log    \nLTE UL data transfer started    console=True


Step ${index}: Wait For Traffic Stabilize
    Log    === Step ${index}: Wait For Traffic Stabilize ===    console=True
    Sleep    90s


Step ${index}: Stop Data Transfer
    Log    === Step ${index}: Stop Data Transfer ===    console=True

    Run Keyword And Ignore Error  Stop Data Transfers For All Ues
    Log    \nLTE and 5G data transfer stopped    console=True


Step ${index}: Detach UEs
    Log    === Step ${index}: Detach UEs===    console=True
    Run Keyword And Continue On Failure    Detach UE    LTE_UE
    Run Keyword And Continue On Failure    Detach UE    NR_UE1
    Run Keyword And Continue On Failure    Detach UE    NR_UE2
    Run Keyword And Continue On Failure    Detach UE    NR_UE3
    Run Keyword And Continue On Failure    Detach UE    NR_UE4


Step ${index}: Start eNB Syscomdump Collection
    Log    === Step ${index}: Start eNB Syscomdump Collection ===    console=True
    Start Collecting Syscomdump    host=${ENB_OAM_IP}


Step ${index}: Wait For Logs Capture
    Log    === Step ${index}: Wait For Logs Capture ===    console=True
    ${savepoint} =    syslog.Capture Savepoint    alias=default
    Set Test Variable    ${SAVEPOINT}    ${savepoint}
    Log    :: SAVEPOINT ${index}: ${SAVEPOINT}    console=True
    Set Test Variable    ${TIME_OF_LOGS_COLLECTION}    60
    Sleep    ${TIME_OF_LOGS_COLLECTION}s


Step ${index}: Stop Syscomdump Collection
    Log    === Step ${index}: Stop Syscomdump Collection ===    console=True
    ${syscomdump_file}=    Stop Collecting Syscomdump
    Set Test Variable    ${SYSCOMDUMP_FILE_PATH}    ${syscomdump_file}


Step ${index}: Check NR PDCCH Load
    Log    === Step ${index}: Check Nr Pdcch Load ===    console=True

    ${xp_gnb_cell_id_filter}=    Set Variable    xp_common_EndpointIdentifier_t.gNBCellId == ${NR_DSS_CELL}
    ${xp_enb_cell_id_filter}=    Set Variable    xp_common_CrmId.eNBCellId == ${LTE_DSS_CELL}
    ${dss_cells_id_filter}=    Set Variable    ${xp_gnb_cell_id_filter} && ${xp_enb_cell_id_filter}
    ${pdcch_load_message_filter}=    Set Variable    ${dss_cells_id_filter} && xp_dss_EnDssDlQosLoadMeasurement.measuredPdcchLoad_item
    ${period_of_message_appears}=    Set Variable    0.01
    ${expected_number_of_messages}=    Evaluate    ${TIME_OF_LOGS_COLLECTION} / ${period_of_message_appears}


    Run Keyword And Continue On Failure
    ...    Verify Amount Of Messages In File    ${pdcch_load_message_filter}    >=    ${expected_number_of_messages}    ${SYSCOMDUMP_FILE_PATH}
    Run Keyword And Continue On Failure
    ...    Verify Percentage Of Messages With Expected Value
    ...    ${pdcch_load_message_filter}    ${pdcch_load_message_filter} == 100    >=    99     ${SYSCOMDUMP_FILE_PATH}


Step ${index}: Check NR DL Sharing Is Greater Than 80 Percents And Lte Load About 30 Percents
    Log    === Step ${index}: Check NR DL Sharing Is Greater Than 80 Percents And Lte Load About 30 Percents ===    console=True
    Check NR DL Sharing Ratio And Lte Load    nr_ratio=80    expected_lte_load=30


Step ${index}: Check NR DL Sharing Is Greater Than 80 Percents And Lte Load 0 Percents
    Log    === Step ${index}: Check NR DL Sharing Is Greater Than 80 Percents And Lte Load About 30 Percents ===    console=True
    Check NR DL Sharing Ratio And Lte Load    nr_ratio=80    expected_lte_load=0


Check NR DL Sharing Ratio And Lte Load
    [Arguments]    ${nr_ratio}    ${expected_lte_load}
    Log    === Check NR DL Sharing Ratio ===    console=True
    ${log_name}=    Generate Filename From Timestamp    ${SAVEPOINT}
    ${log_path}=    Set Variable    ${LOG_PATH}/udp_logs/${log_name}
    syslog.Collect From Savepoint    savepoint=${SAVEPOINT}    destination_file=${log_path}    alias=default
    Analyse Crm Logs    enb_id=${LNBTS_ID}    enb_pci=${LTE_DSS_CELL}    gnb_id=${NRBTS_ID}    gnb_pci=${NR_DSS_CELL}
    ...    expected_nr_sharing_ratio=${nr_ratio}    expected_lte_load=${expected_lte_load}    btslog=${log_path}


Step ${index}: Wait For Next Two Counters Periods
    Log    === Step ${index}: Wait For Next Two Counters Periods to have one full period with stable traffic without interruptions ===    console=True
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval


Step ${index}: Get Initial Counters Values
    Log    === Step ${index}: Get Initial Counters Values ===    console=True
    Get Counters Files
    ${LTE_COUNTERS}=    Create List    M8029C216
    ${lte_initial_counters_values} =    Get Last Counters From File    ${LTE_COUNTERS}
    ...    file_path=${LTE_PM_COUNTER_FILE}
    ...    local_moid=PLMN-PLMN/MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_DSS_CELL}/MCC-001/MNC-01
    Set Test Variable    ${LTE_INITIAL_COUNTERS_VALUES}    ${lte_initial_counters_values}

    ${NR_COUNTERS}=    Create List
    ...    M55332C00001
    ...    M55332C01001
    ...    M55332C02001
    ...    M55332C02002
    ${nr_initial_counters_values} =    Get Last Counters From File    ${NR_COUNTERS}
    ...    file_path=${NR_PM_COUNTER_FILE}
    ...    local_moid=PLMN-PLMN/MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_DSS_CELL}
    Set Test Variable    ${NR_INITIAL_COUNTERS_VALUES}    ${nr_initial_counters_values}


Step ${index}: Check Counters
    Log    === Step ${index}: Check Counters ===    console=True
    Get Counters Files
    Run Keyword And Continue On Failure    Check LTE Counters
    Run Keyword And Continue On Failure    Check 5G Counters


Get Counters Files
    Log    === Get Counters ===    console=True

    Get LTE Counters File
    Get 5G Counters File


Get LTE Counters File
    Log    === Get LTE Counters File ===    console=True
    ${mplane_ip} =    Evaluate    $tl.enbs[0].oam_ip.v4
    Wait Until Keyword Succeeds    5x    10s    Collect PM Counters
    ...    target_dir_path=${LOG_PATH}/pm_counters    xml_files_left=4    host=${mplane_ip}    time_interval=15min    intervals=15
    ${pm_counter_file}=    Find File By Mask    folder_path=${LOG_PATH}/pm_counters    file_mask=PM.BTS-${LNBTS_ID}*.xml
    Set Test Variable    ${LTE_PM_COUNTER_FILE}    ${pm_counter_file}


Get 5G Counters File
    Log    === Get 5G Counters File ===    console=True
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File    output_dirpath=${LOG_PATH}/pm_counters
    Set Test Variable    ${NR_PM_COUNTER_FILE}    ${pm_counter_file}


Check LTE Counters
    Log    === Check LTE Counters ===    console=True
    ${INITIAL_M8029C216}=    Set Variable    @{LTE_INITIAL_COUNTERS_VALUES}

    Verify Last Counters In File
    ...    M8029C216    >${INITIAL_M8029C216}    PUSCH_NR_PRB_UTIL_RATIO
    ...    local_moid=PLMN-PLMN/MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${LTE_DSS_CELL}/MCC-001/MNC-01
    ...    file_path=${LTE_PM_COUNTER_FILE}


Check 5G Counters
    Log    === Check 5G Counters ===    console=True

    ${INITIAL_M55332C00001}    ${INITIAL_M55332C01001}
    ...    ${INITIAL_M55332C02001}    ${INITIAL_M55332C02002}=    Set Variable    @{NR_INITIAL_COUNTERS_VALUES}

    Verify Last Counters In File
    ...    M55332C00001    >${INITIAL_M55332C00001}    EN_DSS_DL_NR_SLOTS
    ...    M55332C01001    >${INITIAL_M55332C01001}    EN_DSS_UL_PRBS_NR
    ...    M55332C02001    \=\=${INITIAL_M55332C02001}    EN_DSS_NBR_AVLBL_DL_SLOTS
    ...    M55332C02002    \=\=${INITIAL_M55332C02002}    EN_DSS_NBR_AVLBL_UL_PRBS

    ...    local_moid=PLMN-PLMN/MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_DSS_CELL}
    ...    file_path=${NR_PM_COUNTER_FILE}


Find File By Mask
    [Arguments]    ${folder_path}    ${file_mask}
    ${files}=    OperatingSystem.List_Files_In_Directory    ${folder_path}    ${file_mask}
    ${file_count}=    Get Length    ${files}

    IF    ${file_count} == 0
        RETURN    ${NONE}
    ELSE IF    ${file_count} == 1
        RETURN    ${folder_path}/${files}[0]
    ELSE
        Log    Warning: Multiple files found matching the mask. Returning the first one.
        RETURN    ${files}[0]
    END


TC Setup
    Log    === TC Setup ===    console=True
    IWK Test Setup    local_enb_connection=False    states_check=False
    Set Test Variables

    Configure Modules
    Set Attenuation    GNB_CELL_8_1    0%
    Set Attenuation    GNB_CELL_8_2    0%
    Sleep    10s    reason=Wait to ensure cell is unmuted
    Prepare Ues


TC Teardown
    Log    \n=== TC Teardown ===    console=True
    Step 1: Stop Data Transfer
    Step 2: Detach UEs
    Deconfigure Modules
    IWK Test Teardown    local_enb_connection=False


Set Test Variables
    Log    \n=== Set Test Variables ===    console=True
    ${nrbts_id} =    Get BTS ID From ADMIN    alias=gNB
    Set Test Variable    ${NRBTS_ID}    ${nrbts_id}

    ${lnbts_id} =    Get BTS ID From ADMIN
    Set Test Variable    ${LNBTS_ID}    ${lnbts_id}


Configure Modules
    Log    \n=== Configure Modules ===    console=True
    Perform Delta Recommissioning    ${CURDIR}/config/delta_feature.json    alias=gNB
    Change Minimum Required RX Level In eNB Cell    2    -140


Deconfigure Modules
    Log    \n=== Deconfigure Modules ===    console=True
    Perform Delta Recommissioning    ${CURDIR}/config/delta_feature_revert.json    alias=gNB
    Change Minimum Required RX Level In eNB Cell    2    -90


Change Minimum Required RX Level In eNB Cell
    [Arguments]    ${CELL_ID}    ${parameter_value}
    Perform Parameter Recommissioning    MRBTS-${LNBTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${CELL_ID}/SIB-0
    ...    qrxlevmin    update    ${parameter_value}


Step ${index}: Activate Feature
    Log    === Step ${index}: Activate Feature ===    console=True
    Perform Parameter Recommissioning    MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_DSS_CELL}/NRDSSLTE-1
    ...    actLteNrDssPdcchLoadResAlloc    update    true    connection=gNB
    Sleep    60s    reason=Wait for sure feature is active


Step ${index}: Collect Snapshots When Feature Is ${feature_state}
    Log    === Step ${index}: Collect Snapshots When Feature Is ${feature_state} ===    console=True
    ${PATH_TO_DEBUG_SNAPSHOTS}=    Set Variable    ${LOG_PATH}/debug_snapshots_feature_${feature_state}
    Create Directory  ${PATH_TO_DEBUG_SNAPSHOTS}
    Collect Snapshot  ${PATH_TO_DEBUG_SNAPSHOTS}/enb_snapshot_feature_${feature_state}.zip    timeout=600
    Collect Snapshot  ${PATH_TO_DEBUG_SNAPSHOTS}/gnb_snapshot_feature_${feature_state}.zip  alias=gNB    timeout=600
    Log To Console  Snapshots collected.
