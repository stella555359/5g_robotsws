*** Settings ***
Force Tags      CLOUD_5G_O_H_AP_LOO    CRT    5G_RAN     SBTS00

Documentation    :copyright: Nokia
...              :authors:
...              :contact:
...              This user scenario describes successful configuration of Long PUCCH and verifies expansion of the
...              PUSCH region over the PRB of PUCCH in the pCSI area which are still not allocated to any UE.
...              The intention is to validate the successful reception of the UL control information (UCI) carried
...              via long PUCCH Format 1, PUCCH Format 3 and PUSCH in FDD deployment for SA (NSA is added in alternate
...              scenarios),while it is noticeable that PRB in the pCSI area not allocated to any UE are then utilized
...              by PUSCH as consequence of CB006877 activation. The PRB in the pCSI area not allocated to any UE may
...              change from  slot to slot and this difference shall be noticeable in the PUSCH as well slot per slot.
...              *REQUIREMENTS COVERAGE:
...              *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_16150

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB006877_Resource.robot
Resource         ../resources/robot/configuration_id.robot
Resource          ../resources/ECEcommon/common_setup_teardown.robot
Resource          ../resources/ECEcommon/common_log_analyzer.robot
Resource          ../resources/ECEcommon/common_lib_variable.robot
Resource         ./CB008954_resource.robot


Suite Setup         Run Keyword and Ignore Error      Suite setup from scratch

*** Variables ***
${wts_cfg_file_TC06}     ${CURDIR}/config/basic_setup_TC06.cfg
${wts_cfg_file_TC17}     ${CURDIR}/config/basic_fs_sa_call_fdd_cmwv_3CC_InterBand_15M.cfg
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
${epc_log_path}    /tmp/
${IPHY_TC06}                    ${CURDIR}/config/iphy_AHEGG_TC6.xml
${IPHY_TC17}                    ${CURDIR}/config/iphy_3CC-Inter-FF_LOO.xml
${scf_TC06}   SCF_TC06_SANSA_35Mhz_ASOH.xml
${scf_TC17}     SCF_CB008131_FFF_3CC_15M_InterBand_DRX_ASOH.xml
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
${no_of_cells}   1
${3CC_INTER_BAND_FFF_SCELLS}    ('1', '51', '2'), ('2', '52', '66')
${3CC}                              3
#####
${wts_cfg_file_42}     ${CURDIR}/config/basic_setup_CB006877_IWK_CNI78446_FDD.cfg
${IPHY_FILE_42}                    ${CURDIR}/config/iphy_CB006877_IWK_CNI78446_FDD_ASOH.xml
${scf_TC42}   SCF_CB006877_IWK_CNI78446_FDD_ASOH.xml
${sa_ue_id_cell1}      1
${en_ue_id_cell1}      2
${sa_ue_id_cell2}      3
${en_ue_id_cell2}      4
${sa_trf_id}    1
${sa_qfi_id}    1
${TEST_NAME}        TC42
${nbrOfBlankedPRBsLowEdgeUL}    21
${delta_file_name_disable}      TC_42_CB006877_CNI_78446_Disable.json
${sa_ue_id_cell1_1}      1
${en_ue_id_cell1_1}      3
${delta_file_name_TC42}   TC_42_CB006877_CNI_78446_Enable.json
${SCFC}=                   ${CURDIR}/config/SBTS25R1/SCF_High_edge_prb_blanking_CA_case_ASOH.xml
${AP_XML}=                 ${CURDIR}/config/iphy_CA_2Cell_latest_ASOH.xml
${wts_cfg_file_2}      ${CURDIR}/config/basic_setup_FDD_highedge_prb_blanking.cfg
${r&d_parameter}     0x1002A=1

*** Test Cases ***
USCB006877-A#1_TC06_Long_PUCCH_for_FDD_Cells_Multiple_SANSA_UE_on_35MHz
    [Documentation]
    ...              This user scenario describes successful configuration of Long PUCCH and verifies expansion of the
    ...              PUSCH region over the PRB of PUCCH in the pCSI area which are still not allocated to any UE.
    ...              The intention is to validate the successful reception of the UL control information (UCI) carried
    ...              via long PUCCH Format 1, PUCCH Format 3 and PUSCH in FDD deployment for SA (NSA is added in alternate
    ...              scenarios),while it is noticeable that PRB in the pCSI area not allocated to any UE are then utilized
    ...              by PUSCH as consequence of CB006877 activation. The PRB in the pCSI area not allocated to any UE may
    ...              change from  slot to slot and this difference shall be noticeable in the PUSCH as well slot per slot.
    [Setup]      Testcase Setup   ${IPHY_TC06}   ${scf_TC06}   ${wts_cfg_file_TC06}   ${no_of_cells}
    ${TEST_NAME}    Set Variable   A_1_TC06
    set suite variable     ${TEST_NAME}
    ${LOG_PATH1}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH1}
    ${StartPuschPrb}    ${StartDynPuschPrb}   Verify UL PUSCH PRBs In CellSetupReq ASOH    ${LOG_PATH}
    X2AP Link Should be UP
    Register multiple NSA UE to cell   ${nrcell}   ${first_nsa_ue}    ${last_nsa_ue}
    Start and validate UL and DL traffic NSA UE    ${first_nsa_ue}  ${last_nsa_ue}   dl_rate=50   ul_rate=100
    ${6877_on_cell_NSA}    Check cell level UL tput NSA   ${first_nsa_ue}    ${first_nsa_ue}
    sleep  5s
    Start Log    biptaf
    sleep  2s
    Stop Log    biptaf
    Multiple NSA UE Detach   ${first_nsa_ue}    ${last_nsa_ue}
    ${NSA_BIP_PATH}    Set Variable    ${LOG_PATH1}/gNB/biptaf
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${NSA_BIP_PATH}/BIP_L1L2.pcap
    ...                                     ${StartDynPuschPrb}   ${StartPuschPrb}    ${cell_subgroup_id}
    Attach multiple SA UE with traffic  ${first_sa_ue}    ${last_sa_ue}
    ${6877_on_cell_SA}    Check cell level UL tput SA   ${first_sa_ue}    ${last_sa_ue}
    sleep  5s
    Start Log    biptaf
    sleep  2s
    Stop Log    biptaf
    MultiUE Deregister should be Successful   ${first_sa_ue}    ${last_sa_ue}
    ${SA_BIP_PATH}    Set Variable    ${LOG_PATH1}/gNB/biptaf
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${SA_BIP_PATH}/BIP_L1L2.pcap
    ...                                     ${StartDynPuschPrb}   ${StartPuschPrb}   ${cell_subgroup_id}
    #Tput check with feature off
    Perform SCF Delta Commissioning with ${delta_file_name}
    sleep   5sd
    X2AP Link Should be UP
    sleep   5s
    Register multiple NSA UE to cell   ${nrcell}   ${first_nsa_ue}    ${last_nsa_ue}
    Start and validate UL and DL traffic NSA UE    ${first_nsa_ue}  ${last_nsa_ue}   dl_rate=100   ul_rate=100
    ${6877_off_cell_NSA}    Check cell level UL tput NSA   ${first_nsa_ue}    ${first_nsa_ue}
    Multiple NSA UE Detach   ${first_nsa_ue}    ${last_nsa_ue}
    Run Keyword and Continue on Failure    Should be True    ${6877_on_cell_NSA}>${6877_off_cell_NSA}
    Attach multiple SA UE with traffic  ${first_sa_ue}    ${last_sa_ue}
    ${6877_off_cell_SA}    Check cell level UL tput SA   ${first_sa_ue}    ${last_sa_ue}
    MultiUE Deregister should be Successful   ${first_sa_ue}    ${last_sa_ue}
    Run Keyword and Continue on Failure    Should be True    ${6877_on_cell_SA}>${6877_off_cell_SA}
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown

USCB006877-A#4_TC17_Aperiodic_CSI_handling_for_UE_configured_with_3CC_DL_CA_in_FDD_with_CB006877_enabled
    [Documentation]
    ...              This user scenario validates the successful aperiodic CSI handling for a CA configured UE with
    ...              continuous DL data transmission when CB006877 enabled. UE is configured with P(S)Cell and
    ...              up to 2 SCells in FDD.
    ...              This user scenario validates that periodic CSI RS are scheduled by gNB and received by the UE (on
    ...              P(S)Cell and active SCells) as well as aperiodic CSI reports for channel state feedback are scheduled
    ...              and received by gNB for CA configured UE.The PRB in the pCSI area not allocated to any UE may change
    ...              from slot to slot and this difference shall be noticeable in the PUSCH as well slot per slot
    [Setup]      Testcase Setup   ${IPHY_TC17}   ${scf_TC17}   ${wts_cfg_file_TC17}   ${3CC}
    ${LOG_PATH1}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH1}
    ${StartPuschPrb}    ${StartDynPuschPrb}   Verify UL PUSCH PRBs In CellSetupReq ASOH     ${LOG_PATH}
    L3 Call With SA     1
    sleep  5s
    Start Log    biptaf
    Start Log    ttitrace
    sleep  2s
    Stop Log    ttitrace
    Stop Log    biptaf
    Run Keyword And Continue on Failure     Decode TTI Trace
    ${SA_BIP_PATH}    Set Variable    ${LOG_PATH1}/gNB/biptaf
    Save Egate Console Log
    Get And Check Scell Infos    ${3CC_INTER_BAND_FFF_SCELLS}
    Verify Scells Are Activation    ${3CC}
    Get And Check Cells TP    dl    3
    ${cell1_UL_stats}=    Check cell level UL tput SA    ${1}    ${1}
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
    ${SA_TTI_PATH}    Set Variable    ${LOG_PATH1}/gNB/ttitrace
    Check ACSI Periodicity On PCell    A004    ${SA_TTI_PATH}
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${SA_BIP_PATH}/BIP_L1L2.pcap
    ...                                     ${StartDynPuschPrb}   ${StartPuschPrb}   ${cell_subgroup_id}
    [Teardown]    Run Keywords      Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown


USCB006877-B#2_TC42_New_connection_procedure_CNI-78446_interworking_when_CB006877_is_enabled
    [Setup]      Testcase Setup TC42   ${IPHY_FILE_42}   ${LOG_PATH}   ${r&d_parameter}   ${scf_TC42}     ${wts_cfg_file_42}
    ${TEST_NAME}    Set Variable   B_2_TC42
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
#    ${LOG_PATH1}  Set Variable     ${LOG_PATH}/${TEST_NAME}
#    set test variable      ${LOG_PATH1}
#    Start Log    cprt
    Log to Console               ============collecting CPRT===================
    CPRT Monitoring Start ASOH
    Perform SCF Delta Commissioning with ${delta_file_name_TC42}
    sleep   2s
    CPRT Monitoring Stop Collect ASOH    ${LOG_PATH}
    MoveFile    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_delta_TC42_1.pcap
    MoveFile    ${LOG_PATH}/External_NODECPRT_GNB.pcap    ${LOG_PATH}/External_NODECPRT_GNB_delta_TC42_1.pcap
#    ${path1}    set suite variable    ${LOG_PATH}
#    ${path1}    Stop Log    cprt   test_scenario=feature_activation
#   Arguments for below commands ${cell_id}='1' | ${bwp_id}='0'
    ${longPucchStartPuschPrb_1_0}    ${longPucchStartDynPuschPrb_1_0}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank ASOH
    ...  ${LOG_PATH}/SYSCOM_NODECPRT_GNB_delta_TC42_1.pcap    1    0
    ${longPucchStartPuschPrb_1_1}    ${longPucchStartDynPuschPrb_1_1}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank ASOH
    ...  ${LOG_PATH}/SYSCOM_NODECPRT_GNB_delta_TC42_1.pcap    1    1
    ${longPucchStartPuschPrb_1_2}    ${longPucchStartDynPuschPrb_1_2}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank ASOH
    ...  ${LOG_PATH}/SYSCOM_NODECPRT_GNB_delta_TC42_1.pcap    1    2
    Link SCOUT SCF to Configuration ID for Reporting
    MultiUE Register should be Successful    ${sa_ue_id_cell1}   ${en_ue_id_cell1}
    MultiUE Register should be Successful    ${sa_ue_id_cell2}   ${en_ue_id_cell2}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell1}    ${en_ue_id_cell1}    mbps    100      1   1
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell1}    ${en_ue_id_cell1}    mbps    100      1   2
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell1}    ${en_ue_id_cell1}    mbps    100      1   3
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell1}    ${en_ue_id_cell1}    mbps    100      1   1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell1}    ${en_ue_id_cell1}    mbps    150      1   2
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell1}    ${en_ue_id_cell1}    mbps    150      1   3
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell2}    ${en_ue_id_cell2}    mbps    100      1   1
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell2}    ${en_ue_id_cell2}    mbps    100      1   2
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell2}    ${en_ue_id_cell2}    mbps    100      1   3
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell2}    ${en_ue_id_cell2}    mbps    100      1   1
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell2}    ${en_ue_id_cell2}    mbps    150      1   2
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell2}    ${en_ue_id_cell2}    mbps    150      1   3
    sleep    20s
    Start Log    biptaf
    sleep   2s
    ${bip_path}   Stop Log    biptaf  test_scenario=data_traffic
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${bip_path}[biptaf]/BIP_L1L2.pcap
    ...  ${longPucchStartDynPuschPrb_1_0}    ${longPucchStartPuschPrb_1_0}    ${0}
    ${cell1_UL_stats}=    cell tput using ue_stats       ${sa_ue_id_cell1}    ${en_ue_id_cell1}
    ${cell2_UL_stats}=    cell tput using ue_stats       ${sa_ue_id_cell2}    ${en_ue_id_cell2}
    Run Keyword and Continue on Failure    Should be True    ${cell1_UL_stats}>${cell2_UL_stats}
    MultiUE Deregister should be Successful   ${sa_ue_id_cell1}   ${en_ue_id_cell1}
    MultiUE Deregister should be Successful   ${sa_ue_id_cell2}   ${en_ue_id_cell2}
###UL PRB blanking with multiBWP TC starts here
    Testprepare second scenario

    [Documentation]  This Test scenario validates high edge PRB blanking with 3BWP's i.e 20Mhz,30Mhz and 40Mhz

    CPRT Monitoring Start ASOH
    Perform SCF Delta Commissioning with ${delta_file_name}
    sleep   2s
    CPRT Monitoring Stop Collect ASOH    ${LOG_PATH}
    MoveFile    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_delta_TC42_2.pcap
    MoveFile    ${LOG_PATH}/External_NODECPRT_GNB.pcap    ${LOG_PATH}/External_NODECPRT_GNB_delta_TC42_2.pcap
#   Arguments for the commands below ${cell_id}='1' | ${bwp_id}='0'
    ${longPucchStartPuschPrb_1_0}    ${longPucchStartDynPuschPrb_1_0}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank ASOH
    ...  ${LOG_PATH}/SYSCOM_NODECPRT_GNB_delta_TC42_2.pcap    1    0
    ${longPucchStartPuschPrb_1_1}    ${longPucchStartDynPuschPrb_1_1}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank ASOH
    ...  ${LOG_PATH}/SYSCOM_NODECPRT_GNB_delta_TC42_2.pcap    1    1
    ${longPucchStartPuschPrb_1_2}    ${longPucchStartDynPuschPrb_1_2}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank ASOH
    ...  ${LOG_PATH}/SYSCOM_NODECPRT_GNB_delta_TC42_2.pcap    1    2
    ${longPucchStartPuschPrb_1_2}    ${longPucchStartDynPuschPrb_1_2}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank ASOH
    ...  ${LOG_PATH}/SYSCOM_NODECPRT_GNB_delta_TC42_2.pcap    1    3

    ${large_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${1}
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=100   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=100   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=100   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=100   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=100   pdu_id=1   trf_id=3   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=100   pdu_id=1   trf_id=3   qfi_id=1
    sleep   5s
    ${second_bwp_rnti}    MultiUE Register should be Successful     ${2}    ${2}
    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=100   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=100   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=100   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=100   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=100   pdu_id=1   trf_id=3   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=100   pdu_id=1   trf_id=3   qfi_id=1
    sleep   5s

    ${small_bwp_rnti}    MultiUE Register should be Successful     ${3}    ${3}
    MultiUE Trigger UL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     ul_rate=100   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     dl_rate=100   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     ul_rate=100   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     dl_rate=100   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     ul_rate=100   pdu_id=1   trf_id=3   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     dl_rate=100   pdu_id=1   trf_id=3   qfi_id=1
    sleep    5s
    Start Log         ttitrace
    sleep    3s
    ${scen3}     Stop Log     ttitrace         test_scenario=Mix1

    Decode TTI Trace   Mix1
    ${small_bwp_id}    Set variable    ${1}
    ${second_bwp_id}   Set Variable    ${3}
    ${large_bwp_id}   Set Variable    ${2}
    ${small_bwp_size}    Set Variable    ${106}
    ${second_bwp_size}    Set Variable    ${160}
    ${large_bwp_num_prb}    Set Variable    ${208}
    ${Mix1}    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}
    ...    ${second_bwp_id}    ${large_bwp_id}     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}
    ...     large_bwp_ues=${large_bwp_rnti}     small_bwp_ues=${small_bwp_rnti}     second_bwp_ues=${second_bwp_rnti}
    should contain    ${Mix1}     pass

    ${cell1_UL_stats_6877_ON}=    cell tput using ue_stats       ${sa_ue_id_cell1_1}    ${en_ue_id_cell1_1}
    MultiUE Deregister should be Successful   ${sa_ue_id_cell1_1}   ${en_ue_id_cell1_1}

    Perform SCF Delta Commissioning with ${delta_file_name_disable}

    ${large_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${1}
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=170   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=170   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=170   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=170   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=170   pdu_id=1   trf_id=3   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=170   pdu_id=1   trf_id=3   qfi_id=1
    sleep   5s
    ${second_bwp_rnti}    MultiUE Register should be Successful     ${2}    ${2}
    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=170   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=170   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=170   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=170   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=170   pdu_id=1   trf_id=3   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=170   pdu_id=1   trf_id=3   qfi_id=1
    sleep   5s

    ${small_bwp_rnti}    MultiUE Register should be Successful     ${3}    ${3}
    MultiUE Trigger UL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     ul_rate=170   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     dl_rate=170   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     ul_rate=170   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     dl_rate=170   pdu_id=1   trf_id=2   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     ul_rate=170   pdu_id=1   trf_id=3   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     dl_rate=170   pdu_id=1   trf_id=3   qfi_id=1
    sleep    5s
    ${cell1_UL_stats_6877_OFF}=    cell tput using ue_stats       ${sa_ue_id_cell1_1}    ${en_ue_id_cell1_1}
    Run Keyword and Continue on Failure    Should be True    ${cell1_UL_stats_6877_ON}>${cell1_UL_stats_6877_OFF}
    MultiUE Deregister should be Successful   ${sa_ue_id_cell1_1}   ${en_ue_id_cell1_1}
    [Teardown]    Run Keywords      Link SCOUT SCF to Configuration ID for Reporting
    ...           AND   common Teardown


*** Keywords ****

Testcase Setup
    [Arguments]    ${IPHY_xml}   ${scfc_file}   ${wts_file}   ${num_of_cells}
    Modify IPHY File And Send to Airphone Custom    ${IPHY_xml}
    Find Scfc And Fix And Send Full Commissioning  scfc_filename=${scfc_file}
    Load CFG Config And Verify cell setup in Capture CPRT Traces ASOH      ${wts_file}   ${num_of_cells}
    Check gNB Bulid

common Teardown
     Stop Log   snapshot
     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Testcase Setup TC42
    [Arguments]    ${IPHY_FILE}   ${LOG_PATH}   ${r&d_parameter}   ${scfc_file}     ${wts_cfg_file}
    Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
    Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter}
    Find Scfc And Fix And Send Full Commissioning  scfc_filename=${scfc_file}
    Load CFG Config And Verify cell setup in Capture CPRT Traces ASOH TC42      ${wts_cfg_file}
    Check gNB Bulid

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Testprepare second scenario
    Run keywords    Prepare TL with all config files
#    ...             AND    Suite setup from scratch
    ...             AND    Start WTS Using WTS_Runner   ${wts_cfg_file_2}

Check ACSI Periodicity On PCell
    [Arguments]    ${case_id}    ${csv_file_path}
    OperatingSystem.Copy File    ${csv_file_path}/output_ul.csv     ${OUTPUT_DIR}/output_ul.csv
    A2A_Check_CSV_Table    ${CURDIR}/resource/TC${case_id}/ttitrace_1_acsi.ini    ${OUTPUT_DIR}/output_ul.csv

Convert BIP To CSV By MCShark For PuschReceiveRespHarqU8131
    [Arguments]    ${tc_id}     ${bip_path}
    ${filter}=    Set Variable    uldata_puschreceiverespharqul1sw
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_UePuschReceiveRespHarqUL1sw_t.crc
    ...    UlData_UePuschReceiveRespHarqUL1sw_t.dtx
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
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    UlData_UePuschReceiveRespHarqUL1sw_t.crc    ["0", "1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed UlDataPuschReceiveRespHarqU Message Number 1817
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    UlData_UePuschReceiveRespHarqUL1sw_t.crc    ["1"]    include    no
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
