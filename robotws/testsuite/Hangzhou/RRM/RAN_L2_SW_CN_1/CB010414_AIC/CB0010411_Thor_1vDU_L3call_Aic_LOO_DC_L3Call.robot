*** Settings ***
Documentation    ...
#Resource          ../CUDU_L2_AIC/common_aic_setup_teardown.robot
#Suite Setup       Run Keywords    Common Suite Setup
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown    debug
#
#*** Variables ***
#${CONFIG_FILE_PATH}    ${CURDIR}/config
#${VCU_SCFC_FILE}       SCFC_cu_1vDU_P_AP_LOO_DC.xml
#${VDU_SCFC_FILE}       SCFC_du_1vDU_P_AP_LOO_DC.xml
#${GNB_INDEX}           0
#${IPHY_FILE}           ${CURDIR}/config/iphy_1vDU_P_AP_LOO_DC.xml
#${LOCAL_WTS_DIR}       ${CURDIR}/config
#${WTS_CFG}             basic_setup.cfg
#${ENB_ID}              1
#${GNB_ID}              2
#${SA_UE_ID}            1
#${NSA_UE_ID}           11
#${PROFILE_ID}          1
#${CELL_ID}             1
#${BEARER_ID}           2
#@{UE_LIST_PerCell}     1    21    31    41    51    61
#*** Test Cases ***
#CB010411 Per Cell UE L3 Call
#    [Setup]    Run Keywords    Create Test Directory
#    ...    AND    Start WTS And Check OnAir
#    ...    AND    VDU Get Current Plan File    ${TEST_LOG_DIRECTORY}    VDU_SCF_after_onair.xml
#    ...    AND    VCU Get Current Plan File    ${TEST_LOG_DIRECTORY}    VCU_SCF_after_onair.xml
#    Attach UE Per Cell And Check Tput
#    Release Ue    ${UE_LIST_PerCell}
#
#*** Keywords ***
#
#Attach UE Per Cell And Check Tput
#    sleep    3s
#    Execute Egate Command    cmd=set_pdu_param ue=1,21,31,41,51,61 pdu=1 trf_type=internal
#    FOR    ${ueid}    IN    @{UE_LIST_PerCell}
#        SA 5G Attach    ${ueid}
#        SA 5G PDU Session Setup    ue_id=${ueid}    pdu_id=1
#        Execute Egate Command    cmd=trf_data_start ue=${ueid} pdu=1 dir=dl mbps=175 trf_id=1
#        Execute Egate Command    cmd=trf_data_start ue=${ueid} pdu=1 dir=dl mbps=175 trf_id=2
#        Execute Egate Command    cmd=trf_data_start ue=${ueid} pdu=1 dir=ul mbps=175 trf_id=1
#        Execute Egate Command    cmd=trf_data_start ue=${ueid} pdu=1 dir=ul mbps=175 trf_id=2
#        sleep    5s
#        Execute Egate Command    cmd=ue_stats_nr id=${ueid} type=pdsch,pusch scell=primary,secondary
#    END
#    Verify Per UE Throughput
#Verify Per UE Throughput
#    sleep    5S    sleep for Tput stable
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    0    100
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    1    10
#    Check CA UE Pcell Scell Cell TPut On Target    1    ul    0    50
#    Check CA UE Pcell Scell Cell TPut On Target    1    ul    1    20
#    Check CA UE Pcell Scell Cell TPut On Target    21    dl    0    100
#    Check CA UE Pcell Scell Cell TPut On Target    31    dl    0    100
#    Check CA UE Pcell Scell Cell TPut On Target    41    dl    0    100
#    Check CA UE Pcell Scell Cell TPut On Target    51    dl    0    100
#    Check CA UE Pcell Scell Cell TPut On Target    61    dl    0    100
#    Check CA UE Pcell Scell Cell TPut On Target    21    ul    0    100
#    Check CA UE Pcell Scell Cell TPut On Target    31    ul    0    20
#    Check CA UE Pcell Scell Cell TPut On Target    41    ul    0    50
#    Check CA UE Pcell Scell Cell TPut On Target    51    ul    0    50
#    Check CA UE Pcell Scell Cell TPut On Target    61    ul    0    50
#
#Release UE
#    [Arguments]    @{UE_LIST_PerCell}
#    FOR    ${ueid}    IN    @{UE_LIST_PerCell}
#        Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
#    END
#
#Get CA Cell Average Throughput
#    [Arguments]    ${ue_id}    ${dir}    ${scell_index}
#    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
#    ...    The unit of return throughput is Mbps.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${ue_id} | Yes | ue_id |
#    ...    | ${dir} | Yes | dl/ul |
#    ...    | ${scell_index} | Yes | 1/2/3...|
#    ...
#    ...    | Examples: |
#    ...    | ${pcell_tput} | Get CA Cell Average Throughput | 1 | dl  | 0 |
#    ...    | ${scell1_tput} | Get CA Cell Average Throughput | 1 | dl | 1 |
#    ...    | ${scell2_tput} | Get CA Cell Average Throughput | 1 | ul | 2 |
#    ...
#    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
#    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=${type} scell\=${scell_index}
#    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
#    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
#    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
#    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
#    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
#    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
#    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
#    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
#    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
#    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
#    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
#    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
#    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
#    ...                                     ${cell_tp}
#    [Return]    ${cell_tput_Mbps}
#
#Check CA UE Pcell Scell Cell TPut On Target
#    [Arguments]    ${ue_id}    ${dir}    ${scell_index}    ${target_tp}
#    ${tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    ${scell_index}
#    Should Be True    ${tput}>=${target_tp}
#    ...    msg=UE${ue_id} scell${scell_index} tput is '${tput}'' not on target'${target_tp}'Mb
#    Log To Console    \nUE${ue_id} scell${scell_index} ${dir} tput ${tput}Mb is on target: ${target_tp}Mb
