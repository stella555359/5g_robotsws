*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF_TDD_9855_TDLTE_1V4}    iphy_file=${3T2F_IPHY}
#...               swconfig_param=${SWCONFIG_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F}
#...               AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_3T3F}
#Suite Teardown    Common Suite Teardown    debug
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT
#...               SBTS00    CN1_SQ6    CB009855
#Resource         ./Resources/CB009855_resource.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#### Suite level ###
#${SWCONFIG_PARAM}               0x590004=4;0x5900a8=1;0x58076e=0x320
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF_TDD_9855_TDLTE_1V4}    Full_SCF_CB009855_A_tdlte_4v1_4v1.xml
#${WTS_CFG_3T3F}                 basic_3T_3F_tdlte_1v4.cfg
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${3T2F_IPHY}                    ${CURDIR}/Resources/wts/iphy_tdlte_1v4.xml
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
##### A008 ############
#${DELTA_SCF_A008}               Delta_scf_A008.json
#${5CC_DL_TRF_008}              1500
#${5CC_UL_TRF_008}              50
#${VONR_UEID}    4
#${5QI5_QFI}       4
#${5QI5_5QI}       5
#${VONR_QFI}       5
#${VONR_5QI}       1
#@{VONR_UEID_LIST}               ${VONR_UEID}
#@{VONR_UEID_UL_TPUT_LIST_008}     1    0
#@{VONR_UEID_DL_TPUT_LIST_008}     300    0    0    0    0
#${VONR_DL_TRF}    500
#${VONR_UL_TRF}    50
#${VONR_UL_TPUT}    10
#${VONR_DL_TPUT}    10
#@{5CC_EXP_UL_TPUT_LIST_008}     10    5
#@{5CC_EXP_DL_TPUT_LIST_008}     100    20    300    300    20
#@{5CC_UE_LIST_008}              2    3    4
#@{5CC_TRF_UE_LIST_008}          2    3
#@{5CC_SCELL_PCI_1}             51    52    53    54
#@{5CC_SCELL_PCI_2}             51    52    53    54
#@{5CC_SCELL_PCI_3}             51    52    53    54
#@{SCELL_PHYSICALID_LIST_A08}       ${5CC_SCELL_PCI_1}    ${5CC_SCELL_PCI_2}    ${5CC_SCELL_PCI_3}
#${CC_NUM}                       5
#### B1602 #########
#${DELTA_SCF_1602}              Delta_scf_B1602.json
#@{5CC_UE_LIST_1602}             2
#@{SCELL_PHYSICALID_LIST_1602}    ${5CC_SCELL_PCI_1}
#${5CC_DL_TRF_1602}              2000
#${5CC_UL_TRF_1602}              100
#${2CC_DL_TRF_1602}              2000
#${2CC_UL_TRF_1602}              100
#@{5CC_EXP_DL_TPUT_LIST_1602}    800    30    400    400    30
#@{5CC_EXP_UL_TPUT_LIST_1602}    20    10
#${2CC_SCELL_INFO}               ('2', '52', '41')
#
#
#*** Test Cases ***
#CB009855-ET-A008_Verify_3T2F_DL_CA_With_Harqbit_Greaterthan_18__BF_Enabled_MultiUE_VONR
#    [Tags]    Owner_naliu
#    [Setup]    Run Keywords    Clear Egate
#    ...    AND    Test Setup Update GNB    scf_file=${DELTA_SCF_A008}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_3T3F}
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell Blind Addition    ${5CC_UE_LIST_008}    ${SCELL_PHYSICALID_LIST_A08}    ${CC_NUM}
#    Add VONR Bearer And start DL and UL Traffic     ${VONR_UEID}    ${VONR_DL_TRF}    ${VONR_UL_TRF}
#    SA Multi UE Start DL And UL Traffic    ${5CC_TRF_UE_LIST_008}    ${5CC_DL_TRF_008}    ${5CC_UL_TRF_008}
#    Wait Until Keyword Succeeds    5min    30sec    Check Multi UE Multi Bearer Tput
#    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}
#
#CB009855-ET-B1602_Verify_3T2F_5CC_UE_IWK_UL_Slot_Muting
#    [Tags]    Owner_naliu
#    [Setup]    Run Keywords    Clear Egate
#    ...    AND    Test Setup Update GNB    scf_file=${DELTA_SCF_1602}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_3T3F}
#    ...    AND    Common Test Setup
#    UE Attach and 5CC DLUL Tput Check
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-6    actInfTddFrameMuting    true
#    Sleep    60s    reason=waiting for Cell6 onair
#    UE Attach and TDD 2CC Tput Check
#    Capture Ttitrace And Check
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#Add VONR Bearer And start DL and UL Traffic
#    [Arguments]    ${UE_ID}    ${dl_trf}    ${ul_trf}
#    Trigger 5QI Setup    ${UE_ID}    ${5QI5_QFI}    ${5QI5_5QI}
#    Trigger 5QI Setup    ${UE_ID}    ${VONR_QFI}    ${VONR_5QI}
#    Start DL Traffic for Dedicated Bearer    ${UE_ID}    ${dl_trf}    3
#    Start UL Traffic for Dedicated Bearer    ${UE_ID}    ${ul_trf}    3
#
#
#Start DL Traffic for Dedicated Bearer
#    [Arguments]    ${ue_id}    ${mbps}    ${qfi_id}    ${pdu_id}=1    ${trf_id}=1
#    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
#    ${dl_times}    Evaluate    int(${mbps}/${175})
#    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
#        ${tmp_trf_id}    Evaluate    ${trf_id}+${t_time}-1
#        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi_id} dir=dl mbps\=175 trf_id\=${tmp_trf_id}
#        Log To Console    \nUE${ue_id}_qfi_${qfi_id} Start DL 175M Traffic for trf_id=${tmp_trf_id}
#    END
#    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
#    ${last_trf_id}    Evaluate    ${trf_id}+${dl_times}
#    Run Keyword If    '${last_mbps}'!='0'    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi_id} dir=dl mbps\=${last_mbps} trf_id\=${last_trf_id}
#    Run Keyword If    '${last_mbps}'!='0'    Log To Console    \nUE${ue_id}_qfi_${qfi_id} Start DL ${last_mbps}M Traffic for trf_id=${last_trf_id}
#Start UL Traffic for Dedicated Bearer
#    [Arguments]    ${ue_id}    ${mbps}    ${qfi_id}    ${pdu_id}=1    ${trf_id}=1
#    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
#    ${ul_times}    Evaluate    int(${mbps}/${175})
#    FOR    ${t_time}    IN RANGE    1    ${ul_times}+1
#        ${tmp_trf_id}    Evaluate    ${trf_id}+${t_time}-1
#        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi_id} dir=ul mbps\=175 trf_id\=${tmp_trf_id}
#        Log To Console    \nUE${ue_id}_qfi_${qfi_id} Start UL 175M Traffic for trf_id=${tmp_trf_id}
#    END
#    ${last_mbps}    Evaluate    ${mbps}-${175}*${ul_times}
#    ${last_trf_id}    Evaluate    ${trf_id}+${ul_times}
#    Run Keyword If    '${last_mbps}'!='0'    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi_id} dir=ul mbps\=${last_mbps} trf_id\=${last_trf_id}
#    Run Keyword If    '${last_mbps}'!='0'    Log To Console    \nUE${ue_id}_qfi_${qfi_id} Start UL ${last_mbps}M Traffic for trf_id=${last_trf_id}
#
#Check Multi UE Multi Bearer Tput
#    Sleep    5s    reason=waiting for Tput stable
#    Run Keyword And Continue On Failure    Check Multi UE ULCA Cell L1 Tput    ${5CC_TRF_UE_LIST_008}    ${5CC_EXP_UL_TPUT_LIST_008}    ${CC_NUM}
#    Run Keyword And Continue On Failure    Check Multi UE DLCA Cell L1 Tput    ${5CC_TRF_UE_LIST_008}    ${5CC_EXP_DL_TPUT_LIST_008}    ${CC_NUM}
#    Run Keyword And Continue On Failure    Check Multi UE DLCA Cell L1 Tput    ${VONR_UEID_LIST}    ${VONR_UEID_DL_TPUT_LIST_008}    ${CC_NUM}
#    Run Keyword And Continue On Failure    Check Multi UE ULCA Cell L1 Tput    ${VONR_UEID_LIST}    ${VONR_UEID_UL_TPUT_LIST_008}    ${CC_NUM}
#    Run Keyword And Continue On Failure    Check DLUL CA VONR No Tput    ${VONR_UEID}    ${CC_NUM}
#Check DLUL CA VONR No Tput
#    [Arguments]    ${ue_id}    ${CC_NUM}
#    ${scell_ul_tput}    Get ULCA SCell L1 Average Throughput    ${ue_id}    ${CC_NUM}
#    ${scell_dl_tput}    Get DLCA SCell L1 Average Throughput    ${ue_id}    ${CC_NUM}
#    Should be True    "${scell_dl_tput}"=="0"
#    Should be True    "${scell_ul_tput}"=="0"
#Get DLCA SCell L1 Average Throughput
#    [Arguments]    ${ue_id}    ${dl_cc_num}
#    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
#    ...    The unit of return throughput is Mbps.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${ue_id} | Yes | ue_id |
#    ...    | ${dl_cc_num} | Yes | 2/3/4...|
#    ...
#    ...    | Examples: |
#    ...    | ${ul_scell_tput} | Get ULCA SCell L1 Average Throughput | 1 | 4 |
#    ...
#    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=pdsch scell\=1-${dl_cc_num}
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
#UE Attach and 5CC DLUL Tput Check
#    SA Multi UE Attach With Scell Blind Addition    ${5CC_UE_LIST_1602}    ${SCELL_PHYSICALID_LIST_1602}    ${CC_NUM}
#    Override All UE RI For TDD Pcell 4Layer    ${5CC_UE_LIST_1602}
#    SA Multi UE Start DL And UL Traffic    ${5CC_UE_LIST_1602}    ${5CC_DL_TRF_1602}    ${5CC_UL_TRF_1602}
#    Sleep    5s    reason=stable Tput
#    Wait Until Keyword Succeeds    5min    20sec    Check Multi UE DLCA And 2CCULCA L1 Cell tput     ${5CC_UE_LIST_1602}
#    ...    ${5CC_EXP_UL_TPUT_LIST_1602}    ${5CC_EXP_DL_TPUT_LIST_1602}   ${CC_NUM}
#UE Attach and TDD 2CC Tput Check
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    SA 5G CA Attach    2    1
#    Override All UE RI For TDD Pcell 4Layer    ${5CC_UE_LIST_1602}
#    SA Multi UE Start DL And UL Traffic    ${5CC_UE_LIST_1602}    ${2CC_DL_TRF_1602}    ${2CC_UL_TRF_1602}
#    sleep    5s
#    Run Keyword And Continue On Failure      Check T_T 2CC Config
#    Run Keyword And Continue On Failure      Check CA UE Pcell Scell Cell TPut On Target     2    dl    pdsch    0    500
#    Run Keyword And Continue On Failure      Check CA UE Pcell Scell Cell TPut On Target     2    dl    pdsch    2    500
#Capture Ttitrace And Check
#    Capture Convert Format Ttitrace With Streaming Mode    3s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2/
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_B${/}CB009855_1602_Tti_NackRatio.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming2
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_B${/}CB009855_1602_Tti_ULMut.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming2
#
#Check T_T 2CC Config
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/egate/
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009855_B${/}CB009855_1602.ini
#    ...    p    save_log_directory=${TEST_LOG_DIRECTORY}/
