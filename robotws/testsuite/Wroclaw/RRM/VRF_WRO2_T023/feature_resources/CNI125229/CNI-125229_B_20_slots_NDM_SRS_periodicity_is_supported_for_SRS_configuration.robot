*** Settings ***
Documentation    Keywords for the CNI-125229

Library     taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations    WITH NAME    ru_operation
Library     ta5g_egate
Library     ta5g_cell_operations
Resource    testsuite/Wroclaw/RRM/WRO_2/keywords/messaging.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/keywords/L3_Call.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/testline_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/wts.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/gnb.robot


*** Variables ***
${ARTIFACTORY_LOCATION}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/zapatyla
${BSR_FILENAME}=            BSR_AQQL_6_H6_ALN60_ARP60_P12_COVERAGE_00808_00002.zip
${BSR_FILEPATH}=            ${ARTIFACTORY_LOCATION}/${BSR_FILENAME}
${ARTI_USER}=               zapatyla
${ARTI_PASS}=               cmVmdGtuOjAxOjE3OTQxMzUwMjc6U2R3R3duaUVPWmhRRlJpQnJvTWhZZkF3aG9Y
${BSR_TARGET_FILEPATH}=     ${OUTPUT_DIR}

@{ETH3_IPs}=    61    62    63    64    131    132    133    134    135    136    137    138    139
@{ETH4_IPs}=    3    4    5    6    7    8    9    10    11    12    13

@{CELL_LIST}=    1    2    3    4    5    6    7    8    9    10    11    12

@{UE_IDs}=      1      2      21     22     41     42     61     62     81     82     101    102
...             121    122    141    142    161    162    181    182    201    202    221    222
@{PDU_IDs}=     1    2     3    4    5    6    7    8    9    10    11    12    13    14    15    1    2    3    4    5    6    7    8    9
@{GW_IDs}=      1      2      21     22     41     42     61     62     81     82     101    102
...             121    122    141    142    161    162    181    182    201    202    221    222
@{CELL_IDs}=    1    1     2    2    3    3    4    4    5    5    6    6    7    7    8    8    9    9    10    10    11    11    12    12

${GNB_ID}=    2

*** Keywords ***
TC__CNI-125229_B_20_slots_NDM_SRS_periodicity_is_supported_for_SRS_configuration_for_SB_BF_for_2_UEs_in_12cell
    Attach Multiple Ues To The Different Cells And Start Data Traffic    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}    gw_ids=${GW_IDs}
    ...                                                                  cell_ids=${CELL_IDs}    gnb_id=${GNB_ID}    inactive_timer=10

    [Teardown]    Stop Data Traffic And Release Multiple Ues    ue_ids=${UE_IDs}    pdu_ids=${PDU_IDs}

Attach Multiple Ues To The Different Cells And Start Data Traffic
    [Arguments]    ${ue_ids}    ${pdu_ids}    ${gw_ids}    ${cell_ids}    ${inactive_timer}
    ...            ${gnb_id}=2    ${gnb_ip}=10.0.1.2    ${dl_mbps}=45    ${ul_mbps}=20
    ${ues_number}=    Get Length    ${ue_ids}
    Create Gnb Device With Alias 'gNB${gnb_id}' Identified By ip=${gnb_ip}
    Enable Internal Mirroring For Alias    gNB${gnb_id}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Attach Ue And Establish Pdu Session    ue_id=${ue_ids}[${ue_index}]    cell_id=${cell_ids}[${ue_index}]    enb_id=${gnb_id}
        ...                                    pdu_id=${pdu_ids}[${ue_index}]    gw_id=${gw_ids}[${ue_index}]
        Execute Egate Command    cmd=trf_data_start ue=${ue_ids}[${ue_index}] pdu=${pdu_ids}[${ue_index}] trf_id=1 dir=dl mbps=${dl_mbps}
        Execute Egate Command    cmd=trf_data_start ue=${ue_ids}[${ue_index}] pdu=${pdu_ids}[${ue_index}] trf_id=2 dir=ul mbps=${ul_mbps}
        BuiltIn.Sleep    ${inactive_timer}s    Wait for Traffic to Stabilize
        Execute Egate Command    cmd=ue_stats_nr id=${ue_ids}[${ue_index}]
    END

Configure Eth3 And Eth4 Interfaces
    Configure Interfaces    eth=eth3    ips_range=${ETH3_IPs}
    Configure Interfaces    eth=eth4    ips_range=${ETH4_IPs}

Install Bsr Package For AQQL
    Install Bsr Package    bsr_file_path=${BSR_FILEPATH}
    ...                    target_file_path=${BSR_TARGET_FILEPATH}/${BSR_FILENAME}

Wait For Gnb Environment Stabilization
    ru_operation.Wait For All Radio Units To Be Online    timeout=300
    Wait For All Cells To Be Configured    timeout=60

Configure Wts Environment
    [Arguments]    ${lua_cfg}    ${cell_list}=${CELL_LIST}
    Stop Edaemon And Egate Processes
    Log To Console    Starting WTS...
    Setup Edaemon And Egate    10000
    Wait For Wts Is Ready To Use    lua_cfg=${lua_cfg}    cell_list=${cell_list}
    Setup X2 Connection
