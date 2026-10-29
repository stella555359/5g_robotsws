# *** Settings ***
# Resource    ./../Resources/CB008542_keywords.robot
# 
# Documentation    Suite description
# ...    author: Liu Zheng
# ...    contact: zheng.4.liu@nokia-sbell.com
# ...    squad group: MMW_SG1
# ...    Feature CB008542-BB
# 
# Force Tags    5G_RRM
# ...    PY36
# Suite Setup    8542 PSCell change Suite preparation
# Suite Teardown  run keyword and ignore error    CA Suite teardown
# 
# 
# *** Test Cases ***
# [1]CB008542-BB_TC016_PSCell A2 based PSCell change for NSA call_with_CA_present
#     [Tags]    CRT_TRUNK
#     [Documentation]    author: zheng.4.liu@nokia-sbell.com
#     ...  Precondition in suite setup which set the corresponding NIDDs for A2 based and A1 based PSCell change
#     ...    Related parameters for A2 based PSCell change, for T+F switch to F+T
#     ...      MRBTS/NRBTS/actInterFreqIntraGnbMobilityNSA is set to true
#     ...      MRBTS/NRBTS/NRCELL(TDD)/NRREL/sCellAdditionMethod is set to covBasedA1
#     ...      NRBTS/NRCELL/cellDepType of FR1-TDD cell (F1) is set to 10 (SA+NSA)
# 	...      NRBTS/NRCELL/cellDepType of FDD cell (F2) is set to 10 (SA+NSA)
# 	...      MRBTS/NRBTS/actMeasBasedSCellAddition is set to true
# 	...      MRBTS/NRBTS/actMeasBasedSCellAdditionNSA is set to true, activate secondary cell addition for carrier aggregat
# ...ion based on UE measurement.
#     ...      NRBTS/NRCELL(TDD)/NRHOIF/a2BasedPCellSwitchEnabled for the frequency corresponding to FDD Cell (F2)
#     ...      NRBTS/NRCELL(TDD)/a2MeasPCellSwitchEnabled for FR1-TDD PSCell
#     ...      NRBTS/NRCELL(TDD)/a2MeasPCellSwitchSsbRsrp and/or NRBTS/NRCELL/a2MeasPCellSwitchSsbRsrq (for FR1-TDD PSCell)
#     ...    Related parameters for A1 based PSCell change, for F+T switch to T+F
#     ...      MRBTS-10359/NRBTS-10359/NRDU-1/actConnectedModeMobilityCA is set true if this is false,
#     ...        then A1 PSCell change will not be configured in the RRC Reconfiguration message in which there is also scell addition event.
#     ...      MRBTS/NRBTS/NRCELL(FDD)/NRREL/sCellAdditionMethod is set to covBasedA1
#     ...      NRBTS/NRBTS/NRCELL(FDD)/NRHOIF/a1BasedPCellSwitchEnabled is set to true
#     ...      NRBTS/NRBTS/NRCELL(TDD)/a1MeasPCellSwitchEnabled is set to rsrp
#     ...      NRBTS/NRBTS/NRCELL(TDD)/a1MeasPCellSwitchSsbRsrp is configured.
#     ...  Step1: attach to TDD cell and TDD(pcell) signal is good enough to do A1 scell addition, and in the same RRC reconfiguration message,
#     ...         there is A2 pcell change configured.
#     ...  Step2: start start UL(100M) and DL(1800M) traffic, throughput on TDD(pcell) and FDD(scell) can peak.
#     ...  Step3: adjust TDD(pcell) signal to bad(PA from 0 to 30), trigger a2 measurement report
#     ...  Step4: check pcell change from T+F CA to F+T CA
#     ...  Step5: check F+T CA UL DL traffic, due to scell signal is bad, throughput can't peak.
#     ...  Step6: djust TDD(scell) signal to good(PA from 30 to 0), trigger a1 pcell change measurement report
#     ...  Step7: check pcell change from F+T CA to T+F CA
#     ...  Step8: check T+F CA UL DL traffic, throughput can peak
#     ...  Note:
#     ...    For A2 based PSCell change:
#     ...    When PSCell A2 event is triggered, UE will report RSRP and RSRQ for both PSCell and SCell.
#     ...    If FDD cell is better than TDD cell (check the RSRP or/and RSRQ value of FDD cell with
#     ...    measurement specific offset plus the RSRP or/and RSRQ of TDD cell) and also better than configured threshold,
#     ...    gNB shall do PSCell change by initiating intra-DU inter-frequency handover to the SCell as target cell. Else 
# ...A2 measurement is discarded.
#     [Setup]    Common case setup    NSA_SA=NSA
#     #For A2 based PSCell change
#     8542 Pcell id and scell id and expected throughput redefined in order to match with different pcell     ca_group_type=T+F
#     Connect to gnb coam via ssl
#     Run keyword and continue on failure    CA_L3_call_tput
#     ...    data_transfer_direction=both     dl_tput=${DL_TPUT}    ul_tput=${UL_TPUT}
#     ...    duration=3000s
#     ...    cell_id=${PCELL_ID},${SCELL_ID}     exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL}    exp_ul=${PCELL_EXP_UL},-1
#     ...    tput_duration=${DURATION_OF_TPUT_CHECK}    sleep_time=${WAIT_TIME_FOR_TPUT_STABLE}
#     ...    scell_addition_method=covBasedA1    check_scell_activation=${False}
#     ...    tcpdump_log_name=basic_l3_call_CA    ue_index=${0}   4G_check=True    min_percent=0.8
#     ...    NSA_SA=NSA
#     ...    ENB_Cellid=${ENB_Cellid_${MRBTS_ID}}   is_need_to_stop_traffic=${False}    customized_log_name=traffic_after_attach
# 
# 
#     #attach_f1ap_logpath is test variable defined in CA/Resources/CA_keywords.robot set test variable
#     run keyword and continue on failure    Verify A2 configured on pcell when pcell switch enabled for NSA
#     ...    log_path_pcap=${attach_f1ap_logpath}
# 
#     #pcell change from 2329 CA to 1390 CA
#     ${starting_log_timestamp_A2}    Prepare for counter log    reporting_interval=5
#     log to console    adjust PA to trigger A2 based PSCell change
#     Adjust PA and verify Pcell change successful    pcell_change_type=A2
# 
#     8542 Pcell id and scell id and expected throughput redefined in order to match with different pcell    ca_group_type=F+T
# 
#     ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=1min
#     ...     filter=L2Lo
#     run keyword and continue on failure    Check tput via power UE    cell_id=${PCELL_ID},${SCELL_ID}
#     ...    exp_ul=${PCELL_EXP_UL},-1    exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL_WITH_BLER}    log=${tput_log}
#     log to console    start to check the A2 based PSCell change counter
#     run keyword and continue on failure    Check A2 based PSCell change PM counter M55145C04021 M55145C04022 M55145C04023 M55145C04024
#     ...    starting_log_timestamp=${starting_log_timestamp_A2['log_generator_timestamp']}
# 
#     # For A1 based PSCell change
#     ${starting_log_timestamp_A1}    Prepare for counter log   reporting_interval=5
#     log to console    adjust PA to trigger A1 based PSCell change
#     Adjust PA and verify Pcell change successful    pcell_change_type=A1
#     8542 Pcell id and scell id and expected throughput redefined in order to match with different pcell   ca_group_type=T+F
# 
#     ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=1min
#     ...     filter=L2Lo
#     run keyword and continue on failure    Check tput via power UE    cell_id=${PCELL_ID},${SCELL_ID}
#     ...    exp_ul=${PCELL_EXP_UL},-1    exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL}    log=${tput_log}
#     ...    customized_log_name=traffic_after_A1_handover
# 
#     log to console    start to check the A1 based PSCell change counter
#     run keyword and continue on failure
#     ...    Check A1 based PSCell change PM counter M55145C02005 M55145C02007 M55145C02008 M55145C02009 M55145C02010 M55145C02011 M55145C02012
#     ...    starting_log_timestamp=${starting_log_timestamp_A1['log_generator_timestamp']}
# 
#     [Teardown]     run keyword and ignore error      run keywords
#     ...    Common case teardown    detach_ue=${True}
#     ...    AND    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_F_T}
# 
# 
# *** Keywords ***
# 8542 PSCell change Suite preparation
#     [Arguments]    ${enb_default_scf_file}=${ENB_SCF_DEFAULT_FILE_PATH}
#     Import NIDD variables for 8542
#     import variables      ${CURDIR}/../TestData/NIDD_modify_pcell_switch_8542.py
#     set suite variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_BEFORE_PCELL_SWITCH}
#     set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_PSCELL_SWITCH}
#     set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_PCELL_SWITCH_COMMISSION}
#     CA Suite preparation    prepare_ue=${True}    NSA_SA=NSA    enb_default_scf_file=${enb_default_scf_file}
# 
# 8542 Pcell id and scell id and expected throughput redefined in order to match with different pcell
#     [Documentation]    Author: zheng.4.liu@nokia-sbell.com
#     ...    Support Pcell change between 8015 and 8542, Just support 1 FDD 1 TDD environment.
#     ...    Happened when A1 based or A2 based PSCell triggered.
#     [Arguments]    ${ca_group_type}=F+T
#     run keyword if    '${ca_group_type}'=='T+F'   Run Keywords
#     ...       set test variable   ${PCELL_ID}    ${TDD_CELLS[0]['nrCellId']}
#     ...       AND    set test variable   ${PCELL_RU_INDEX}    ${TDD_CELLS[0]['ru_index_in_testline_file']}
#     ...       AND    set test variable   ${SCELL_ID}    ${FDD_CELLS[0]['nrCellId']}
#     ...       AND    set test variable   ${SCELL_RU_INDEX}    ${FDD_CELLS[0]['ru_index_in_testline_file']}
#     ...       AND    set test variable   ${PCELL_EXP_DL}    880
#     ...       AND    set test variable   ${PCELL_EXP_UL}    39
#     ...       AND    set test variable   ${SCELL_EXP_DL}    210
#     ...       AND    set test variable   ${SCELL_EXP_DL_WITH_BLER}    100
#     ...       AND    set test variable   ${CA_GROUP_TYPE}    T+F
#     ...       ELSE    Run Keywords
#     ...       set test variable   ${PCELL_ID}    ${FDD_CELLS[0]['nrCellId']}
#     ...       AND    set test variable   ${PCELL_RU_INDEX}    ${FDD_CELLS[0]['ru_index_in_testline_file']}
#     ...       AND    set test variable   ${SCELL_ID}    ${TDD_CELLS[0]['nrCellId']}
#     ...       AND    set test variable   ${SCELL_RU_INDEX}    ${TDD_CELLS[0]['ru_index_in_testline_file']}
#     ...       AND    set test variable   ${PCELL_EXP_DL}    214
#     ...       AND    set test variable   ${PCELL_EXP_UL}    70
#     ...       AND    set test variable   ${SCELL_EXP_DL}    880
#     ...       AND    set test variable   ${SCELL_EXP_DL_WITH_BLER}    100
#     ...       AND    set test variable   ${CA_GROUP_TYPE}    F+T
# 
# 
# Adjust PA and verify Pcell change successful
#     [Documentation]    author: zheng.4.liu@nokia-sbell.com
#     ...   when test 8542 A1 and A2 PSCell change, both need to adjust the TDD cell signal.
#     ...   New scell added after Pcell switch
#     ...   Pcell ID should be changed to Scell ID and old Scell released
#     [Arguments]    ${NSA_SA}=${NSA_SA}    ${enb_default_scf_file}=${None}     ${tcpdump_log_name}=pcell_switch_triggered
#     ...   ${pcell_change_type}=A1
#     Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}_${pcell_change_type}    options=-i any sctp
# 
#     Set Test Variable    ${TDD_Cell_id}    ${TDD_CELLS[0]['nrCellId']}
#     Set Test Variable    ${TDD_RU_index}    ${TDD_CELLS[0]['ru_index_in_testline_file']}
#     run keyword if    '${pcell_change_type}'=='A1'    Adjust attenuator multi ports to same value
#     ...       ru_index=${TDD_RU_index}    pa_value=${PA_A1_BASED_PCELL_SWTICH}
#     ...    ELSE    Adjust attenuator multi ports to same value       ru_index=${TDD_RU_index}    pa_value=${PA_A2_BASED_PCELL_SWTICH}
# 
#     sleep    15s
#     ${PSCell_change_log}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}_${pcell_change_type}
# 
#     run keyword if   '${pcell_change_type}'=='A1'    run keyword and continue on failure
#     ...    Verify A1 report for scell to trigger pcell switch in x2 log
#     ...    log_path_pcap=${PSCell_change_log}       a1_rsrp_thres=${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}
#     ...    ELSE    run keyword and continue on failure     Verify A2 report for pcell to trigger pcell swith in x2 log
#     ...    log_path_pcap=${PSCell_change_log}       a2_rsrp_thres=${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}
# 
#     run keyword and continue on failure     Verify Pcell ID Changed after pcell switch through RRC reconfiguration NSA
#     ...         log_path_pcap=${PSCell_change_log}
# 
#     run keyword and continue on failure     Verify new scell add after pcell switch through RRC Info NSA
#     ...         log_path_pcap=${PSCell_change_log}
# 
# Verify new scell add after pcell switch through RRC Info NSA
#     [Documentation]    author: Dandan Fang
#     ...      check new scell added, pci updated.
#     [Arguments]     ${log_path_pcap}=${CPIF_LOG}        ${expected_target_scell}=${PCELL_ID}
#     #new scell addition
#     ${expected_scellPCI}   set variable    ${NR_CELL_ID_MAPPING[${expected_target_scell}]['physicalCellId']}
#     ${filter}    set variable
#     ...     (x2ap.procedureCode == 30) && (nr-rrc.sCellToAddModList) && ( nr-rrc.physCellId == ${expected_scellPCI} )
#     ${pkt_new_scell_addition}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=${filter}
#     ${new_scell_pci}    pcap.get_field_value_by_xpath
#     ...    pdml_list=${pkt_new_scell_addition}        attribute_name=show
#     ...    xpath=.//nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId
# 
#     run keyword and continue on failure   should be true    ${expected_scellPCI} == ${new_scell_pci[0]}
# 
# Verify Pcell ID Changed after pcell switch through RRC reconfiguration NSA
#     [Documentation]    author: Dandan Fang
#     ...     expected_target_cell should be as Scell ID when Pcell switch supported
#     ...     when pcell switch happened, old scell will be released
#     [Arguments]     ${log_path_pcap}       ${expected_target_pcell}=${SCELL_ID}
#     #spcell changed, old scell released
#     ${filter}    set variable
#     ...    (x2ap.procedureCode == 30) && (nr-rrc.spCellConfigCommon_element)
#     ${pkt_pcell_change}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=${filter}
# 
#     ${expectedCellPCI}   set variable    ${NR_CELL_ID_MAPPING[${expected_target_pcell}]['physicalCellId']}
# 
#     ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.spCellConfig_element//nr-rrc.reconfigurationWithSync_element
#     ...    /nr-rrc.spCellConfigCommon_element/nr-rrc.physCellId
#     ${target_cell_pci}    pcap.get_field_value_by_xpath
#     ...    pdml_list=${pkt_pcell_change}      xpath=${xpath}       attribute_name=show
# 
#     ${release_scell_index}    pcap.get_field_value_by_xpath
#     ...    xpath=.//nr-rrc.sCellToReleaseList//nr-rrc.SCellIndex     attribute_name=show
#     run keyword and continue on failure   should be true    ${expectedCellPCI} == ${target_cell_pci[0]}
#     run keyword and continue on failure   should be true    ${release_scell_index[0]} == ${9}
# 
# Verify A1 report for scell to trigger pcell switch in x2 log
#     [Documentation]    author: Dandan Fang
#     ...    check A1 report on Scell
#     [Arguments]    ${log_path_pcap}    ${cellId}=${SCELL_ID}          ${a1_rsrp_thres}=${65}
#     ${physicalCellId}   set variable    ${NR_CELL_ID_MAPPING[${cellId}]['physicalCellId']}
#     ${filter}    set variable
#     ...    (x2ap.procedureCode == 35) && (nr-rrc.measResultServingMOList) && (nr-rrc.physCellId == ${physicalCellId})
#     ${pkt_measReport}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=${filter}
# 
# #    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
# #    ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.rsrp
# 
#     ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
#     ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp
#     ${a1_rsrp}  pcap.get_field_value_by_xpath    xpath=${xpath}      attribute_name=show
# 
#     run keyword and continue on failure    should be true    ${a1_rsrp[0]} >= ${a1_rsrp_thres}
# 
# Verify A2 configured on pcell when pcell switch enabled for NSA
#     [Documentation]    author: zheng.4.liu@nokia-sbell.com
#     ...          it is used for A1 based or A2 based on Pcell to trigger pcell changed feature for NSA
#     [Arguments]     ${log_path_pcap}       ${cellId}=${PCELL_ID}
#     ${filter}    set variable
#     ...    (x2ap.procedureCode == 30) && (nr-rrc.sCellToAddModList)&& (nr-rrc.measIdToAddModList)
#     ${pkt_measReport}    Load pcap file with filter    log_path_pcap=${log_path_pcap}     filter=${filter}
# 
#     ${a2meas_type}  pcap.get_field_value_by_xpath
#     ...      xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold
#     ...      attribute_name=showname
#     run keyword and continue on failure    should be equal as strings    rsrp    ${a2meas_type[0].split()[1]}
# 
# Verify A2 report for pcell to trigger pcell swith in x2 log
#     [Documentation]    author: Liu Zheng
#     [Arguments]    ${log_path_pcap}    ${cellId}=${PCELL_ID}          ${a2_rsrp_thres}=${60}
#     ${physicalCellId}   set variable    ${NR_CELL_ID_MAPPING[${cellId}]['physicalCellId']}
#     ${filter}    set variable
#     ...     (x2ap.procedureCode == 35) && (nr-rrc.measResultServingMOList) && (nr-rrc.physCellId == ${physicalCellId})
#     ${pkt_measReport}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=${filter}
# 
# #    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
# #    ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.rsrp
#     ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
#     ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp
# 
#     ${a2_rsrp}  pcap.get_field_value_by_xpath    xpath=${xpath}      attribute_name=show
#     run keyword and continue on failure    should be true    ${a2_rsrp[0]} <= ${a2_rsrp_thres}
# 
# Check A2 based PSCell change PM counter M55145C04021 M55145C04022 M55145C04023 M55145C04024
#     [Documentation]
#     ...   M55145C04021    A2 Intra-gNB Intra-DU HO prep fail for NSA via MeNB or SRB3 per PLMN-ID due to AC    F_A2_IADU_HO_PR_AC_NSA_PLMN \n
# 	...   M55145C04022    A2 Intra-gNB Intra-DU HO prep fail for NSA via MeNB or SRB3 per PLMN-ID due to other    F_A2_IADU_HO_PR_OTH_NSA_PLMN \n
# 	...   M55145C04023    A2 Intra-gNB Intra-DU HO exec att for NSA via MeNB or SRB3 per PLMN-ID    ATT_A2_IADU_HO_EX_NSA_PLMN \n
#     ...   M55145C04024    A2 Intra-gNB Intra-DU HO exec succ for NSA via MeNB or SRB3 per PLMN-ID    SUC_A2_IADU_HO_EX_NSA_PLMN \n
#     ...   counters need be updated on source cell.
#     [Arguments]       ${starting_log_timestamp}
#     ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
# #   ######need be updated due to the ${SCELL_ID} easily to be misunderstand###########
#     ${cell_check_list}    create list     ${SCELL_ID}
#     ${list_measurement_ids}    create list    M55145C04021    M55145C04022    M55145C04023    M55145C04024
#     ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
#     ...      list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}
#     ${M55145C04021}    set variable    ${dict_measurements_value['${scell_id}']['M55145C04021']}
#     ${M55145C04022}    set variable    ${dict_measurements_value['${scell_id}']['M55145C04022']}
#     ${M55145C04023}    set variable    ${dict_measurements_value['${scell_id}']['M55145C04023']}
#     ${M55145C04024}    set variable    ${dict_measurements_value['${scell_id}']['M55145C04024']}
#     run keyword and continue on failure     should be equal as strings      ${M55145C04021}       0
#     run keyword and continue on failure     should be equal as strings      ${M55145C04022}       0
#     run keyword and continue on failure     should be equal as strings      ${M55145C04023}       1
#     run keyword and continue on failure     should be equal as strings      ${M55145C04024}       1
# 
# 
# Check A1 based PSCell change PM counter M55145C02005 M55145C02007 M55145C02008 M55145C02009 M55145C02010 M55145C02011 M55145C02012
#     [Documentation]
#     ...  M55145C02005 ATT_A1_IF_INTRA_DU_HO_NSA_MNB:A1 based inter frequency intra DU PSCell change attempts for NSA 3x via MeNB \n
# 	...  M55145C02007 FAI_A1_IF_INTRA_DU_HO_TDC_EXP  A1 based inter frequency intra DU PSCell change for NSA 3x failures due to TDCoverall expiry \n
# 	...  M55145C02008 FAI_A1_IF_INTRADU_HOPRE_ENBREF  A1 based inter frequency intra DU PSCell change failures due to MeNB refusal \n
#     ...  M55145C02009 FAI_A1_IF_INTRADU_HOPR_RES_NSA  A1 based inter frequency intra DU PSCell change for NSA 3x failure
# ...s due to resource failure \n
#     ...  M55145C02010 FAI_A1_IF_INTRA_DU_HO_T304_NSA  A1 based inter frequency intra DU PSCell change for NSA 3x failures due to T304 expiry \n
#     ...  M55145C02011 FAI_A1_IF_INTRADU_HOPRE_E1_NSA  A1 based inter frequency intra DU PSCell change for NSA 3x failures due to E1 failure \n
#     ...  M55145C02012 FAI_A1_IF_INTRADU_HOPRE_F1_NSA  A1 based inter frequency intra DU PSCell change for NSA 3x failures due to F1 failure \n
#     ...  counters need be updated on source cell.
#     [Arguments]       ${starting_log_timestamp}
#     ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
# #   ######need be updated due to the ${SCELL_ID} easily to be misunderstand###########
#     ${cell_check_list}    create list     ${SCELL_ID}
#     ${list_measurement_ids}    create list    M55145C02005  M55145C02007  M55145C02008  M55145C02009  M55145C02010  M55145C02011  M55145C02012
#     ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
#     ...      list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}
#     ${M55145C02005}    set variable    ${dict_measurements_value['${scell_id}']['M55145C02005']}
#     ${M55145C02007}    set variable    ${dict_measurements_value['${scell_id}']['M55145C02007']}
#     ${M55145C02008}    set variable    ${dict_measurements_value['${scell_id}']['M55145C02008']}
#     ${M55145C02009}    set variable    ${dict_measurements_value['${scell_id}']['M55145C02009']}
#     ${M55145C02010}    set variable    ${dict_measurements_value['${scell_id}']['M55145C02010']}
#     ${M55145C02011}    set variable    ${dict_measurements_value['${scell_id}']['M55145C02011']}
#     ${M55145C02012}    set variable    ${dict_measurements_value['${scell_id}']['M55145C02012']}
#     run keyword and continue on failure     should be equal as strings      ${M55145C02005}       1
#     run keyword and continue on failure     should be equal as strings      ${M55145C02007}       0
#     run keyword and continue on failure     should be equal as strings      ${M55145C02008}       0
#     run keyword and continue on failure     should be equal as strings      ${M55145C02009}       0
#     run keyword and continue on failure     should be equal as strings      ${M55145C02010}       0
#     run keyword and continue on failure     should be equal as strings      ${M55145C02011}       0
#     run keyword and continue on failure     should be equal as strings      ${M55145C02012}       0
# 
# Adjust attenuator multi ports to same value
#     [Documentation]    Author: Liu Zheng
#     ...    currently only suport 2 ports and 4 ports
#     [Arguments]    ${attenuator_index}=${0}        ${attenuator_device}=ATTEN_0
#     ...    ${gnb_index}=${0}    ${ru_index}=${SCELL_RU_INDEX}
#     ...    ${pa_value}=${SCELL_INIT_PA_VALUE_${MRBTS_ID}}
#     ...    ${pa_port_num}=${4}
#     Connect to Attenuator    attenuator_index=${0}    alias=${attenuator_device}
#     ${atten_ports}    gnb_classical_hangzhou.Get Attenuation Channels For RU    gnb_id=${gnb_index}
#     ...    RU_id=${ru_index}
#     ${pa_values_2}    create list    ${pa_value}    ${pa_value}
#     ${pa_values_4}    create list    ${pa_value}    ${pa_value}    ${pa_value}    ${pa_value}
#     ${pa_values}    set variable if    ${pa_port_num}==${4}    ${pa_values_4}    ${pa_values_2}
#     set_ports_attenuation    ports=${atten_ports}    values=${pa_values}    confirm=${False}
#     ...    attenuator_device=${attenuator_device}
#     read_ports_attenuation     ports=${atten_ports}    attenuator_device=${attenuator_device}
# 
