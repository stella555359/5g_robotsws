*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO    CRT    5G_RAN     SBTS00

Documentation    :copyright: Nokia
...              :authors: Lavanya TV
...              :contact: lavanya.t_v@nokia.com
...              This user scenario validates the successful aperiodic CSI handling for a CA configured UE with
...              continuous DL data transmission when CB006877 enabled. UE is configured with P(S)Cell and
...              up to 2 SCells in FDD.
...              This user scenario validates that periodic CSI RS are scheduled by gNB and received by the UE (on
...              P(S)Cell and active SCells) as well as aperiodic CSI reports for channel state feedback are scheduled
...              and received by gNB for CA configured UE.The PRB in the pCSI area not allocated to any UE may change
...              from slot to slot and this difference shall be noticeable in the PUSCH as well slot per slot
...              *REQUIREMENTS COVERAGE:
...              *REQUIREMENTS IN SCOPE:5G_RAN_USR_RRM_23372;CB_FIM_43175

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB006877_Resource.robot
Resource          ../resources/ECEcommon/common_setup_teardown.robot
Resource          ../resources/ECEcommon/common_log_analyzer.robot
Resource          ../resources/ECEcommon/common_lib_variable.robot


Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND    Send Swconfig File To GNB        ${CURDIR}/config/swconfig.txt
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=SCF_CB008131_FFF_3CC_15M_InterBand_DRX.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces   ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

#Suite Teardown      Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_fs_sa_call_fdd_cmwv_3CC_InterBand_15M.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${first_sa_ue}      ${1}
${last_sa_ue}     ${5}
${first_nsa_ue}      ${11}
${last_nsa_ue}      ${15}
${nrcell}   1
${cell_subgroup_id}   0
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC06
${epc_log_path}    /tmp/
${IPHY_FILE}                    ${CURDIR}/config/iphy_3CC-Inter-FF_LOO.xml
${num_of_prbs_using_lower_pcsi}   0
${num_of_prbs_using_upper_pcsi}   0
${num_of_prbs_lower_pcsi}   0
${count_of_prbs_using_lower_pcsi}   0
${total_uldata_pusch}    0
${dynamic_pusch_prb}    0
@{pathlist}    startPrb
${filter}   ${EMPTY}
${startPacket}   1
${endPacket}   1000
${delta_file_name}   TC06_CB006877_disable.json
#${SCF_FFF_3CC_15M_InterBand_DRX}     SCF_CB008131_FFF_3CC_15M_InterBand_DRX.xml
${3CC_INTER_BAND_FFF_SCELLS}    ('1', '51', '2'), ('2', '52', '66')
${3CC}                              3
${no_of_cells}   3

*** Test Cases ***
USCB006877-A#4_TC17_Aperiodic_CSI_handling_for_UE_configured_with_3CC_DL_CA_in_FDD_with_CB006877_enabled
    [Documentation]
    ...              This user scenario validates the successful aperiodic CSI handling for a CA configured UE with
    ...              continuous DL data transmission when CB006877 enabled. UE is configured with P(S)Cell and
    ...              up to 2 SCells in FDD.
    ...              This user scenario validates that periodic CSI RS are scheduled by gNB and received by the UE (on
    ...              P(S)Cell and active SCells) as well as aperiodic CSI reports for channel state feedback are scheduled
    ...              and received by gNB for CA configured UE.The PRB in the pCSI area not allocated to any UE may change
    ...              from slot to slot and this difference shall be noticeable in the PUSCH as well slot per slot

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    ${StartPuschPrb}    ${StartDynPuschPrb}   Verify UL PUSCH PRBs In CellSetupReq      ${cprt_log}
    L3 Call With SA     1
    sleep  5s
    Start Log    biptaf
    Start Log    ttitrace
    sleep  2s
    Stop Log    ttitrace
    Stop Log    biptaf
    Run Keyword And Continue on Failure     Decode TTI Trace
    ${SA_BIP_PATH}    Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/biptaf
    Save Egate Console Log
    Get And Check Scell Infos    ${3CC_INTER_BAND_FFF_SCELLS}
    Verify Scells Are Activation    ${3CC}
    Check BetaOffsets From Local Egate Log    SA
    Log To Console    start check bip log
    Copy Preference For MCShark    ${CURDIR}/resource/preferences_c_15M
    Run Keyword And Continue on Failure     Check_Betaoffset_MCShark_For_CA    A004     ${SA_BIP_PATH}
    Run Keyword And Continue on Failure     Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    A004     ${SA_BIP_PATH}
    Check l1_common_dtx_t.value in PuschReceiveRespPs    A004
    Check csiPart1CrcCheck in PuschReceiveRespPs    A004
    Check csiPart2CrcCheck in PuschReceiveRespPs    A004
    Check dtxCsiPart1 in PuschReceiveRespPs    A004
    Check dtxCsiPart2 in PuschReceiveRespPs    A004
    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131    A004     ${SA_BIP_PATH}
    Check CRCNOK Rate in PuschReceiveRespHarqU    A004
    Log To Console    start check ttitrace log
    ${SA_TTI_PATH}    Set Variable    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace
    Check ACSI Periodicity On PCell    A004    ${SA_TTI_PATH}
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${SA_BIP_PATH}/BIP_L1L2.pcap
    ...                                     ${StartDynPuschPrb}   ${StartPuschPrb}   ${cell_subgroup_id}


*** Keywords ***

Check ACSI Periodicity On PCell
    [Arguments]    ${case_id}    ${csv_file_path}
    OperatingSystem.Copy File    ${csv_file_path}/output_ul.csv     ${OUTPUT_DIR}/output_ul.csv
    A2A_Check_CSV_Table    ${CURDIR}/resource/TC${case_id}/ttitrace_1_acsi.ini    ${OUTPUT_DIR}/output_ul.csv

Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131
    [Arguments]    ${tc_id}     ${bip_path}
    ${filter}=    Set Variable    uldata_puschreceiverespharqu
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_UePuschReceiveRespHarqU_t.crc
    ...    UlData_UePuschReceiveRespHarqU_t.dtx
    Convert BIP To CSV By MCShark   ${bip_path}/BIP_L1L2.pcap
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    ${filter}    ${csv_title_list}

Check CRCNOK Rate in PuschReceiveRespHarqU
    [Arguments]    ${tc_id}
    Log To Console    CRCNOK Rate in PuschReceiveRespHarqU.
    ${total_number}    Get Total UlDataPuschReceiveRespHarqU Message Number 1817    ${tc_id}
    ${failed_number}    Get Total Failed UlDataPuschReceiveRespHarqU Message Number 1817    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    CRCNOK Rate in PuschReceiveRespHarqU is ${rate}
    Should Be True    ${rate}<0.1

Get Total UlDataPuschReceiveRespHarqU Message Number 1817
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    UlData_UePuschReceiveRespHarqU_t.crc    ["0", "1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed UlDataPuschReceiveRespHarqU Message Number 1817
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    UlData_UePuschReceiveRespHarqU_t.crc    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Save Egate Console Log
    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}
#    wtsrunner.sim_log_set       flush
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${log_path}

L3 Call With SA
    [Arguments]    ${ue_id}=1
#    [Arguments]    ${ul_zeropadding}    ${ucionly}    ${scell_add_method}
#    ...    ${A2_Flag}    ${cell_nums}    ${tc_id}    ${measurement_gap}=0    ${MBPS}=175
    UE Register should be Success    ${ue_id}
          Trigger DL Traffic SA   ${ue_id}   175
          sleep   1s
          Trigger UL Traffic SA   ${ue_id}     175   1
#          Trigger UL Traffic SA   ${ue_id}=${ue_id}     ${ul_rate}=175   ${trf_id}=2
          sleep   1s
    Scell Addition Triggered By A1 Event
    Measurement Gap Triggered By A2 Event
#    wtsrunner.ue_cqi_param    id=1 on=nr    nr_cqi=15    nr_cqi_mode=oneway    nr_cqi_min=4    nr_cqi_max=15    nr_cqi_step=-1    nr_cqi_period=32
    Get And Check Cells TP    dl    3
    ${cell1_UL_stats}=    Check cell level UL tput SA    ${ue_id}    ${ue_id}
#    Release Scell And Capture BIP Log    ${tc_id}    ${cell_nums}    ${measurement_gap}


Check BetaOffsets From Local Egate Log
    [Arguments]    ${sa_flag}    ${log_path}=/opt/iphy/latest
    Log To Console    \nStart check betaOffset info from egate log.\n
    ${betaoffset}    Set Variable    betaOffset
    ${check_rst}    Run    cat ${log_path}/egate_console.log|grep "${betaoffset}"|wc -l
    Run Keyword If    '${sa_flag}'=='SA'
    ...    Should Be True    ${check_rst}>=37
    Run Keyword If    '${sa_flag}'=='NSA'
    ...    Should Be True    ${check_rst}==29

Scell Addition Triggered By A1 Event
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${srsrp_nr}=100
        wtsrunner.ue_measurement_send_nr  id=${ue_id}       meas_id=${meas_id}      event=A1    srsrp_nr=${srsrp_nr}
        ${output}    Read WTS Output Until Pattern Matches    activated successfully    40
    #...    pass_regexp=activated successfully    timeout=60
#    Log To Console    \n${output}

Measurement Gap Triggered By A2 Event
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${srsrp_nr}=20
    wtsrunner.ue_measurement_send_nr    id=${ue_id}     meas_id=${meas_id}      event=A2    srsrp_nr=${srsrp_nr}
#    ...    pass_regexp=rrcReconfigurationComplete     timeout=60
#    Log To Console    \n${output}

Scell Released By A2 Event
    [Arguments]    ${ue_id}=1    ${meas_id}=2    ${scell_id}=1    ${scell_rsrp}=70
    ${output}=    ute_wtssim.execute egate command and wait for data
     wtsrunner.ue_measurement_send_nr    id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=${scell_rsrp}
#    ...    pass_regexp=rrcReconfigurationComplete    timeout=30
    Log To Console    \n${output}

Get And Check Cells TP
    [Arguments]    ${dir}    ${cell_nums}
    ${pcell_tput}    Get CA Cell Average Throughput    1    ${dir}    pcell    0
    Log To Console    Pcell Throughtput of ${dir} is ${pcell_tput}
    Should Be True    ${pcell_tput}>0    Pcell Throughtput of ${dir} is abnormal.
    FOR    ${id}    IN RANGE    1    ${cell_nums}
        ${scell__tput}    Get CA Cell Average Throughput    1    ${dir}    scell    ${id}
        Log To Console    Scell${id} Throughtput of ${dir} is ${scell__tput}.
    END

Get CA Cell Average Throughput
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${cell_type} | Yes | pcell/scell |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_tput} | Get CA Cell Average Throughput | 1 | dl | pcell | 0 |
    ...    | ${scell1_tput} | Get CA Cell Average Throughput | 1 | dl | scell | 1 |
    ...    | ${scell2_tput} | Get CA Cell Average Throughput | 1 | ul | scell | 2 |
    ...
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
     wtsrunner.ue_stats_nr     id=${ue_id} type=${type} scell=${scell_index} format=long
    ${output}    wtsrunner.read_wtsemu_output_until    expected=Number of received DL TBs dropped for error simulation
    ...                     timeout=30
#     ${output}    Read WTS Output Until Pattern Matches    CellIndex-0    40
#    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}

Get And Check Scell Infos
    [Arguments]    ${scells_info}    ${egate_file}=/opt/iphy/latest/egate_console.log
    [Documentation]    This keyword is to get and check Scell Info from egate Log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scells_info} | Yes |expected scell info with the format ('sCellIndex', 'physCellId', 'frequencyBandList') |
    ...    | ${egate_file | No | the egate Log path|
    ...    The keyword return a tuple list, then check whether it include above expected infos defined in ${scells_info}
    ...    Examples:
    ...    | Get And Check Scell Infos | ('1', '51', '2'), ('2', '52', '66')|
    ...
#     wtsrunner.sim_log_set      flush
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${regexp}    Catenate    SEPARATOR=    sCellIndex\\s+(?P<sCellIndex>\\d+),[\\s\\S]*?physCellId\\s(?P<physCellId>\\d+),
    ...    [\\s\\S]*?frequencyBandList\\s+{\\s+(?P<frequencyBandList>\\d+)\\s+},
    ${ret}    String.Get Regexp Matches    ${content}    ${regexp}    sCellIndex    physCellId    frequencyBandList
    ${ret_str}=    Convert To String    ${ret}
    ${ret}=    String.Replace String Using Regexp    ${ret_str}    u    ${EMPTY}
    BuiltIn.Log    ${ret}
    Should Contain    ${ret}    ${scells_info}

Verify Scells Are Activation
    [Arguments]    ${cell_nums}    ${egate_file}=/opt/iphy/latest/egate_console.log
    [Documentation]    This keyword is to check whether scell actived from egate Log.
    Log To Console    verify Scell Info...
#     wtsrunner.sim_log_set      flush
    FOR    ${id}    IN RANGE    1    ${cell_nums}
    ${scell_activation}    Set Variable    SCellIndex ${id} activated successfully.
    # ${check_rst}    Run    cat ${egate_file}|grep -i "${scell_activation}"|wc -l
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}     Get Regexp Matches    ${content}    ${scell_activation}
    ${check_rst}    Get Length    ${match_list}
    Should Be True    ${check_rst}>=1
    END

#Check_Betaoffset_MCShark_For_CA
#    [Arguments]    ${tc_id}     ${bip_path}
#    Log To Console    \ncheck BetaOffset...
#    Convert BIP To CSV By MCShark For CA    ${tc_id}    ${bip_path}
#    A2A_Check_CSV_Table    ${CURDIR}/resource/TC${tc_id}/ttitrace_1_c.ini    ${CURDIR}/resource/TC${tc_id}/ttitrace_1_c.csv

Check_Betaoffset_MCShark_For_CA
    [Arguments]    ${tc_id}       ${bip_path}
    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00
    @{csv_title_list}=    Create List    3gpp.sfn    dci.dci01.CSIrequest    3gpp.subcellid
    ...    dci.dci01.BetaOffsetInd    UlData_puschReceiveReqGrant_t.numOfUciAckBits
    Convert BIP To CSV By MCShark   ${bip_path}/BIP_L1L2.pcap
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_c.csv    ${filter}    ${csv_title_list}
    A2A_Check_CSV_Table    ${CURDIR}/resource/TC${tc_id}/ttitrace_1_c.ini    ${CURDIR}/resource/TC${tc_id}/ttitrace_1_c.csv

Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq
    [Arguments]    ${tc_id}       ${bip_path}
    Log To Console    \nCheck A-CSI in PdcchSendReq.
#    Convert BIP To CSV By MCShark For CRC And DTX    ${tc_id}
    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00||uldata_puschreceiverespps
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    dci.dci01.CSIrequest    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
    ...    UlData_UePuschReceiveRespPs_t.dtx    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
    ...    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    3gpp.subcellid
    Convert BIP To CSV By MCShark   ${bip_path}/BIP_L1L2.pcap
    ...     ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    ${filter}    ${csv_title_list}
    A2A_Check_CSV_Table    ${CURDIR}/resource/TC${tc_id}/ttitrace_1_a.ini    ${CURDIR}/resource/TC${tc_id}/ttitrace_1_a.csv

Check l1_common_dtx_t.value in PuschReceiveRespPs
    [Arguments]    ${tc_id}
    Log To Console    Check DTX in Ul PuschReceiveRespPs.
    ${total_number}    Get Total l1_common_dtx_t.value Number    ${tc_id}
    ${failed_number}    Get Total Failed l1_common_dtx_t.value Number    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    DTX Rate is ${rate}
    Should Be True    ${rate}<0.1

Get Total l1_common_dtx_t.value Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtx    ["0", "1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed l1_common_dtx_t.value Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtx    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check csiPart1CrcCheck in PuschReceiveRespPs
    [Arguments]    ${tc_id}
    Log To Console    Check csiPart1CrcCheck in Ul PuschReceiveRespPs.
    ${total_number}    Get Total csiPart1CrcCheck Number    ${tc_id}
    ${failed_number}    Get Total Failed csiPart1CrcCheck Number    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    CRCNOK Rate is ${rate}
    Should Be True    ${rate}<0.1

Get Total csiPart1CrcCheck Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    ["0", "1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed csiPart1CrcCheck Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check csiPart2CrcCheck in PuschReceiveRespPs
    [Arguments]    ${tc_id}
    Log To Console    Check csiPart2CrcCheck in Ul PuschReceiveRespPs.
    ${total_number}    Get Total csiPart2CrcCheck Number    ${tc_id}
    ${failed_number}    Get Total Failed csiPart2CrcCheck Number    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    CRCNOK Rate is ${rate}
    Should Be True    ${rate}<0.1

Get Total csiPart2CrcCheck Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck    ["0", "1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed csiPart2CrcCheck Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check dtxCsiPart1 in PuschReceiveRespPs
    [Arguments]    ${tc_id}
    Log To Console    Check dtxCsiPart1 in Ul PuschReceiveRespPs.
    ${total_number}    Get Total dtxCsiPart1 Number    ${tc_id}
    ${failed_number}    Get Total Failed dtxCsiPart1 Number    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    dtxCsiPart1 Rate is ${rate}
    Should Be True    ${rate}<0.1

Get Total dtxCsiPart1 Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    ["0", "1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed dtxCsiPart1 Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check dtxCsiPart2 in PuschReceiveRespPs
    [Arguments]    ${tc_id}
    Log To Console    Check dtxCsiPart2 in Ul PuschReceiveRespPs.
    ${total_number}    Get Total dtxCsiPart2 Number    ${tc_id}
    ${failed_number}    Get Total Failed dtxCsiPart2 Number    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    dtxCsiPart2 Rate is ${rate}
    Should Be True    ${rate}<0.1

Get Total dtxCsiPart2 Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    ["1", "0"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed dtxCsiPart2 Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}
