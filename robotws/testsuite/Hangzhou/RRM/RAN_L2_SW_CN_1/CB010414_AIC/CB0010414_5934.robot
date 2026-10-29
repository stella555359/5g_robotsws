*** Settings ***
Documentation    ...
#Resource          ../CUDU_L2_AIC/common_aic_setup_teardown.robot
## Force Tags        CONFIGS_7_5_UTE5GAIC015/test_config.yaml
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown    debug
#
#*** Variables ***
#${CONFIG_FILE_PATH}    ${CURDIR}/config
#${VCU_SCFC_FILE}       SCFC_1_cu.xml
#${VDU_SCFC_FILE}       SCFC_1_du.xml
#${GNB_INDEX}           0
#${IPHY_FILE}           ${CURDIR}/config/iphy.xml
#${LOCAL_WTS_DIR}       ${CURDIR}/config
#${WTS_CFG}             wts.cfg
#${ENB_ID}              1
#${GNB_ID}              2
#${SA_UE_ID}            1
#${NSA_UE_ID}           11
#${PROFILE_ID}          1
#${CELL_ID}             1
#${BEARER_ID}           2
#
#*** Test Cases ***
#CB005934_ET_A_B3a_02_Single_FDD_4CCUE_Call_BasedA1_Scell_addition
#    [Setup]    Run Keywords    Create Test Directory
#    ...    AND    Update Aic GNB    IPHY_FILE=${IPHY_FILE}
#    ...           VCU_SCFC_PATH=${CONFIG_FILE_PATH}/${VCU_SCFC_FILE}
#    ...           VDU_SCFC_PATH=${CONFIG_FILE_PATH}/${VDU_SCFC_FILE}
#    ...    AND    Start WTS And Check OnAir
#    ...    AND    VDU Get Current Plan File    ${TEST_LOG_DIRECTORY}    VDU_SCF_after_onair.xml
#    ...    AND    VCU Get Current Plan File    ${TEST_LOG_DIRECTORY}    VCU_SCF_after_onair.xml
#    Set parameters before case
#	Attach F_and_T CA
#    Release Ue
#
#*** Keywords ***
#Set parameters before case
#    Execute Egate Command    cmd=trace_sim amf\=1 on
#    Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#    Execute Egate Command    cmd=ue_change_location id\=1 enb\=2 cell\=3
#    ...    pass_regexp=(NG Link to gNB=2 is now Active)?(UE1 cannot change location to ENB2.3 - already there)?
#
#Attach F_and_T CA
#    sleep    2min
#    # SA Set Traffic Type To Internal    ue_id=1    pdu_id=1
#    SA 5G Attach    ue_id=1
#    SA 5G PDU Session Setup    ue_id=1    pdu_id=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=102 phycell_id=52
#    ...    pass_regexp=rrc(Connection)?ReconfigurationComplete
#    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=1
#    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=2
#    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=3
#    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=4
#    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=5
#    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=6
#    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=7
#    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=8
#    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=175 trf_id=1
#    sleep    5min
#    Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch,pusch scell=primary,secondary
#    Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch,pusch scell=0,1,2,3
#    Verify Throughput
#
#Verify Throughput
#    [Arguments]    ${Tput_dl}=300    ${Tput_ul}=120    ${sleep_time}=60s
#    sleep    ${sleep_time}    sleep for Tput stable
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    0    ${Tput_dl}
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    1    ${Tput_dl}
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    2    ${Tput_dl}
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    3    ${Tput_dl}
#    Check CA UE Pcell Scell Cell TPut On Target    1    ul    0    ${Tput_ul}
#
#Release UE
#    [Arguments]    ${ue_id}=1
#    Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
#
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
