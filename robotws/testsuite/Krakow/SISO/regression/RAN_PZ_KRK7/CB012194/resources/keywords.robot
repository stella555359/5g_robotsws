*** Settings ***
Documentation
...   Keywords file for CB012194
...   author:
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)

Library      keywords.py
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    sg7keywords
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/helpers.py
Library      ute_ue
Library      Collections
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK7/keywords.robot
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
Test Teardown
    Log To Console    Test Teardown...
    Wait For Site To Be Onair  timeout=300
    gnbcell.Wait For All Cells To Be OnAir    timeout=300


L3 Call on Cell
    [Arguments]    ${network_mode}
    ...            ${band_num}
    ...            ${desired_pci}
    ...            ${throughput_DL}
    ...            ${throughput_UL}
    ...            ${parallel_streams_DL}=1
    ...            ${parallel_streams_UL}=1
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...            ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...            ${packet}=${DEFAULT_PACKET_SIZE}
    ...            ${protocol}=${DEFAULT_PROTOCOL}
    ...            ${deviation}=${DEFAULT_DEVIATION}
    ...            ${linux_congestion}=reno
    ...            ${max_segment_size}=${DEFAULT_PACKET_SIZE}
    ...            ${log_throughput}=${False}
    ...            ${rat_change}=${True}
    Run Keyword If    $log_throughput == True  Log To Console  ${network_mode}_  no_newline=True
    Run Keyword If    $rat_change    Prepare Network Mode And Band    ue_alias=${ue_alias}    network_mode=${network_mode}    band_num=${band_num}
    Check connectivity and data transfer with Quectel on desired PCI    desired_pci=${desired_pci}
    ...       throughput_DL=${throughput_DL}  throughput_UL=${throughput_UL}
    ...       parallel_streams_DL=${parallel_streams_DL}  parallel_streams_UL=${parallel_streams_UL}
    ...       ue_alias=${ue_alias}
    ...       duration=${duration}  packet=${packet}  protocol=${protocol}  deviation=${deviation}
    ...       linux_congestion=${linux_congestion}  max_segment_size=${max_segment_size}
    ...       log_throughput=${log_throughput}


L3 Call on NR Cells
    [Arguments]
    ...    @{cells}
    ...    ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...    ${capabilities}=${UE_CAPABILITIES}
    ...    ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}    ${deviation}=${NR_DEVIATION}
    ...    ${band}=${DEFAULT_BAND}    ${cell_select_by}=barring
    ...    ${tput_map}=&{TPUT_NR_CELL_MAPPING}
    ...    ${arfcn}=${None}    ${scs}=${15}
    [Documentation]    L3 Call on NR Cells.
    ...    KW requires 'L3 Call on Cell' keyword
    ...    :param cells:  list of cells to make L3 call. Throughputs must be provided by &{TPUT_NR_CELL_MAPPING}, dictionary of 2 element lists,
    ...        where key is cell ID and list is DL and UL expected througput, e.g.:
    ...        @{tput1}=    100Mbits/sec    100Mbits/sec
    ...        @{tput2}=    200Mbits/sec    150Mbits/sec
    ...        &{TPUT_NR_CELL_MAPPING}=    1=@{tput1}    2=@{tput2}
    ...    :param duration: duration of L3 call, default is provided by ${DATA_TRANSFER_DEFAULT_DURATION}
    ...    :param deviation: accepted deviation, default is provided by ${NR_DEVIATION}
    ...    :param band: which band select in UE to L3 call, default is provided by ${DEFAULT_BAND}
    ...    :param cell_select_by: 'barring' (default - recommended), 'blocking' or 'arfcn'. Method used to force UE attach to particular cell.
    ...        If 'blocking' used the &{TPUT_NR_CELL_MAPPING} must contain all cell IDs needed to block.
    ...        If 'arfcn' used the cell-arfcn ${arfcn} mapping must be set (dictionary).
    ...           E.g. &{ARFCN_NR_MAPPING}=    2=362670    3=363150    6=362910
    ...           L3 Call on NR Cells    2  3  6    cell_select_by=arfcn    arfcn=&{ARFCN_NR_MAPPING}
    Log To Console    L3 Call on NR Cells: ${cells} ..  no_newline=True
    @{cells_to_block}=    Get Dictionary Keys    ${tput_map}
    @{cells_to_unblock}=    Get Dictionary Keys    ${tput_map}
    Remove Values From List    ${cells_to_block}    ${cells}[0]
    Run Keyword If  '${cell_select_by}' == 'blocking'    sg7keywords.Block cells    ${cells_to_block}    ignore_error=${True}
    Run Keyword And Ignore Error    ute_ue.Require UE    ${ue_alias}    capabilities=${capabilities}
    Adjust Apn             ${ue_alias}    pdp_type=IP     apn_name=5gsakrk
    Wait Until Keyword Succeeds    3x    3 min    ute_ue.reboot_ue    ${ue_alias}    timeout=${170}
    Sleep    2
    Prepare Network Mode And Band    ue_alias=${ue_alias}    network_mode=NR5G    band_num=${band}
    Run Keyword And Ignore Error    ute_ue.Detach UE    ${ue_alias}
    FOR  ${cell}  IN  @{cells}
        Log To Console    . NR cell:${cell}
        ${cell_pci}=      sg7keywords.get_cell_pci_by_id    id=${cell}    rat=nr
        @{cell_tput}=     Set Variable  ${tput_map}[${cell}]
        Run Keyword If  '${cell_select_by}' == 'blocking'    sg7keywords.Unblock cells    [${cell}]    ignore_error=${True}
        Run Keyword If  '${cell_select_by}' == 'arfcn'
        ...    ute_ue.set_earfcn_lock    ${ue_alias}    network_mode=nr5g    earfcn=${arfcn}[${cell}]    scs=${scs}
        Run Keyword If  '${cell_select_by}' == 'barring'
        ...    sg7keywords.Toggle Cells Barred State  rat=nr  expected_cell_id=${cell}  to_be_barred=${False}
        L3 Call on Cell    ue_alias=${ue_alias}    network_mode=NR5G    band_num=${band}    desired_pci=${cell_pci}
        ...    throughput_UL=${cell_tput}[1]    throughput_DL=${cell_tput}[0]
        ...    duration=${duration}    deviation=${deviation}    protocol=tcp    parallel_streams_DL=20    parallel_streams_UL=2
        ...    log_throughput=${True}    rat_change=${False}
        Run Keyword If  '${cell_select_by}' == 'blocking'    sg7keywords.Block cells    [${cell}]

    END
    [Teardown]    Run Keywords
    ...  Run Keyword If  '${cell_select_by}' == 'barring'    sg7keywords.Toggle Cells Barred State  rat=nr  to_be_barred=${False}    AND
    ...  Run Keyword If  '${cell_select_by}' == 'arfcn'    ute_ue.reset_earfcn_lock    ${ue_alias}    network_mode=nr5g    AND
    ...  Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${ue_alias}    AND
    ...  Run Keyword If  '${cell_select_by}' == 'blocking'    sg7keywords.Unblock cells    ${cells_to_unblock}    ignore_error=${True}


L3 Call on LTE Cells
    [Arguments]
    ...    @{cells}
    ...    ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...    ${capabilities}=${UE_CAPABILITIES}
    ...    ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}    ${deviation}=${LTE_DEVIATION}
    ...    ${band}=${DEFAULT_BAND}    ${cell_select_by}=barring
    ...    ${tput_map}=&{TPUT_LTE_CELL_MAPPING}
    ...    ${arfcn}=${None}
    [Documentation]    L3 Call on LTE Cells.
    ...    KW requires 'L3 Call on Cell' keyword
    ...    :param cells:  list of cells to make L3 call. Throughputs must be provided by &{TPUT_LTE_CELL_MAPPING}, dictionary of 2 element lists,
    ...        where key is cell ID and list is DL and UL expected througput, e.g.:
    ...        @{tput1}=    100Mbits/sec    100Mbits/sec
    ...        @{tput2}=    200Mbits/sec    150Mbits/sec
    ...        &{TPUT_LTE_CELL_MAPPING}=    1=@{tput1}    2=@{tput2}
    ...    :param duration: duration of L3 call, default is provided by ${DATA_TRANSFER_DEFAULT_DURATION}
    ...    :param deviation: accepted deviation, default is provided by ${LTE_DEVIATION}
    ...    :param band: which band select in UE to L3 call, default is provided by ${DEFAULT_BAND}
    ...    :param cell_select_by: 'barring' (default - recommended), 'blocking' or 'arfcn'. Method used to force UE attach to particular cell.
    ...        If 'blocking' used the &{TPUT_LTE_CELL_MAPPING} must contain all cell IDs needed to block.
    ...        If 'arfcn' used the cell-arfcn ${arfcn} mapping must be set (dictionary).
    ...           E.g. &{ARFCN_LTE_MAPPING}=    11=1650  12=1550  13=1450  14=1750  19=1850  20=1925
    ...           L3 Call on LTE Cells    11  12  19    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}
    Log To Console    L3 Call on LTE Cells: ${cells} ..  no_newline=True
    @{cells_to_block}=    Get Dictionary Keys    ${tput_map}
    @{cells_to_unblock}=    Get Dictionary Keys    ${tput_map}
    Remove Values From List    ${cells_to_block}    ${cells}[0]
    Run Keyword If  '${cell_select_by}' == 'blocking'    sg7keywords.Block cells    ${cells_to_block}    ignore_error=${True}
    Run Keyword And Ignore Error    ute_ue.Require UE    ${ue_alias}    capabilities=${capabilities}
    Adjust Apn             ${ue_alias}    pdp_type=IP     apn_name=5gkrk
    Wait Until Keyword Succeeds    3x    3 min    ute_ue.reboot_ue    ${ue_alias}    timeout=${170}
    Sleep    2
    Prepare Network Mode And Band    ue_alias=${ue_alias}    network_mode=LTE    band_num=${band}
    Run Keyword And Ignore Error    ute_ue.Detach UE    ${ue_alias}
    FOR  ${cell}  IN  @{cells}
        Log To Console    LTE cell:${cell}
        ${cell_pci}=      sg7keywords.get_cell_pci_by_id    id=${cell}    rat=lte
        @{cell_tput}=     Set Variable  ${tput_map}[${cell}]
        Run Keyword If  '${cell_select_by}' == 'blocking'    sg7keywords.Unblock cells    [${cell}]    ignore_error=${True}
        Run Keyword If  '${cell_select_by}' == 'arfcn'
        ...    ute_ue.set_earfcn_lock    ${ue_alias}    network_mode=lte    earfcn=${arfcn}[${cell}]
        Run Keyword If  '${cell_select_by}' == 'barring'
        ...    sg7keywords.Toggle Cells Barred State  rat=lte  expected_cell_id=${cell}  to_be_barred=${False}
        L3 Call on Cell    ue_alias=${ue_alias}    network_mode=LTE    band_num=${band}    desired_pci=${cell_pci}
        ...    throughput_UL=${cell_tput}[1]    throughput_DL=${cell_tput}[0]
        ...    duration=${duration}    deviation=${deviation}    protocol=tcp    parallel_streams_DL=2    parallel_streams_UL=2
        ...    log_throughput=${True}    rat_change=${False}
        Run Keyword If  '${cell_select_by}' == 'blocking'    sg7keywords.Block cells    [${cell}]

    END
    [Teardown]    Run Keywords
    ...  Run Keyword If    '${cell_select_by}' == 'barring'    sg7keywords.Toggle Cells Barred State    rat=lte    to_be_barred=${False}    AND
    ...  Run Keyword If  '${cell_select_by}' == 'arfcn'    ute_ue.reset_earfcn_lock    ${ue_alias}    network_mode=lte    AND
    ...  Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${ue_alias}    AND
    ...  Run Keyword If    '${cell_select_by}' == 'blocking'    sg7keywords.Unblock cells    ${cells_to_unblock}    ignore_error=${True}


Set parameter [${param}] from object [${object}] to value [${val}] and expect ${result}
    Log to Console    Changing parameter ${param} from object ${object} to value ${val}
    ${reset_type}=    Set Variable If
    ...    '${result}' == 'bts reset'    ['Site']
    ...    '${result}' == 'lte rat reset'    ['LteRat']
    ...    '${result}' == 'nr rat reset'    ['NrRat']
    ...    '${result}' == 'online modification'    ['None']    unknown_key
    perform_parameter_recommissioning_and_verify_result    dist_name=${object}
    ...    parameter=${param}   operation=update    value=${val}    timeout=600
    ...    result_key=resetCoverage    result_val=${reset_type}
    log to console    Done after ${result}


Lock gNB Cells And Verify Results
    [Arguments]    @{cells}    ${timeout}=30

    FOR    ${cell}    IN    @{cells}
        Log    Locking cell: ${cell}
        sg7keywords.Lock gNB Cell    cell_id=${cell}
        Wait for cell to be locked    timeout=${timeout}    cell_id=${cell}
    END


Cleanup After TC01
    Log To Console    Cleanup after t01
    ${delta}=  prepare_parameters_delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
    ...  parameter=enDcSyncStatus  value=synchronous
    ${delta}=  prepare_parameters_delta    delta=${delta}    distname=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    ...  parameter=actExtN77Support  value=false
    ${delta}=  prepare_parameters_delta    delta=${delta}    distname=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...  parameter=holdOverModeUsed  value=false
    ${delta}=  prepare_parameters_delta    delta=${delta}    distname=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-11
    ...  parameter=inactivityTimer  value=30
    Wait Until Keyword Succeeds    2 min    50 sec    Perform Delta Commissioning On gNB    delta=${delta}


Cleanup After TC11
    Log To Console   Test 11 Teardown...
    ${MRBTS_ID}=    sg7keywords.get_mrbts_id
    Set Test Variable    ${MRBTS_ID}     ${MRBTS_ID}
    Run Keyword If Test Failed    Change multiple parameters
    ...    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2="parameterName": "administrativeState", "value": "Unlocked", "operation": "update"
    ...    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-5="parameterName": "administrativeState", "value": "Unlocked", "operation": "update"
    ...    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-6="parameterName": "administrativeState", "value": "Unlocked", "operation": "update"


L3 Call 09 LTE and NR Cell
    [Arguments]    ${arg1}    #${arg2}    #dummy args necessary for UU4ALL KWs
    Log    arg1: ${arg1}    #; arg2: ${arg2}
    L3 Call on LTE Cells    19    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}
    L3 Call on LTE Cells    17    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}    ue_alias=UE2    capabilities=QUECTEL_UE2
    Wait Until Keyword Succeeds    2x    1 min    L3 Call on NR Cells    6    cell_select_by=arfcn    arfcn=&{ARFCN_NR_MAPPING}
    Wait Until Keyword Succeeds    2x    1 min    L3 Call on NR Cells    5    cell_select_by=none    ue_alias=UE2    capabilities=QUECTEL_UE2

