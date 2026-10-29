*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     CRT    5G_RAN     SBTS00

Documentation   :copyright: Nokia
...             :authors: Mundanad Vishnu
...             :contact: mundanad.vishnu@nokia.com
...             INTRODUCTION:     This user scenario validates the correct working of the Inter-band FDD - TDD
...                               FR1 UL and DL CA feature for single UE with 2 aggregated carriers when CB006877 is enabled.
...                               PCell is TDD carrier and single SCell is FDD FR1 carrier. It is assumed that FDD cell
...                               and TDD FR1 cell have overlaid coverage with FDD cell having bigger coverage compared to
...                               TDD FR1 cell.
...                               This user scenario validates the basic algorithm of the adaptive retransmission scheme
...                               for UL transmissions when CB006877 is enabled. When CB006877 is active, it is not mandatory
...                               but it allows scheduler to adapt re-TX when PUSCH BW is variable due to different PUCCH
...                               overhead distribution in each slot.
...                               Thic TC combines DL CA, UL CA and Adaptive_retransmission scenarios.
...             TEST SET NAME:    CB006877
...             TESTING SPLIT:    Refer CB006877 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB006877 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_23581, 5G_RAN_USR_RRM_23582, 5G_RAN_USR_RRM_23373



Resource     CB006877_Resource.robot
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Prepare TL with config files
...                 AND     Start Default Logging Gnb ASIL_ABIO
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep    20s

Suite Teardown    Run Keywords
...               Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...               AND     Stop Default Logging Gnb ASIL_ABIO


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_ca.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${epc_log_path}    /tmp/
${UE_ID}         1
${sa_ue_id1}     1
${sa_trf_id}    1
${sa_qfi_id}    1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}      1
${QFI_ID}      1
${cell_subgroup_id}    1

${nbrOfBlankedPRBsLowEdgeUL}    21
${SCFC}=                        ${CURDIR}/config/SCF_CA.xml
${AP_XML}=                      ${CURDIR}/config/iphy_f_t_2cell.xml
${delta_file_name}   TC32_CB006877_enable.json

*** Test Cases ***
USCB006877-A#9_TC32_FR1_UL_and_DL_CA_interworking_with_CB006877_single_UE
    [Tags]      QC_xxxxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}

    #Attach single UE, start data and get Pcell and Scell tputs in DL and UL
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    UE Register should be Success   ${sa_ue_id1}
    sleep     5s
    Trigger High DL Traffic SA     ${sa_ue_id1}     250
    sleep    20s
    Trigger UL Traffic SA      ${sa_ue_id1}      50     qfi_id=${QFI_ID}
    sleep    20s
    ${scell_dl_tp_1}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    ${scell_ul_tp_1}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=1
    Validate DL Traffic For SA for high data     ${sa_ue_id1}     220    1     1
    UE Deregister should be Successful    ${sa_ue_id1}
    #Enable feature on FDD cell
    Start Log    cprt
    Perform SCF Delta Commissioning with ${delta_file_name}
    sleep   2s
    ${path1}    Stop Log    cprt   test_scenario=feature_activation
    ${longPucchStartPuschPrb}    ${longPucchStartDynPuschPrb}=     Verify Dynamic PUSCH in CellSetup
    ...  ${path1}[cprt]/NODECPRT_GNB.pcap   sctp
    #Attach single UE, start data and get Pcell and Scell tputs in DL and UL
    UE Register should be Success   ${sa_ue_id1}
    sleep     5s
    Trigger High DL Traffic SA     ${sa_ue_id1}     250
    sleep    20s
    Trigger UL Traffic SA      ${sa_ue_id1}      50     qfi_id=${QFI_ID}
    sleep    20s
    ${scell_dl_tp_2}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    ${scell_ul_tp_2}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=1
    Validate DL Traffic For SA for high data     ${sa_ue_id1}     220    1     1
    Start Log    biptaf
    sleep   2s
    ${bip_path}   Stop Log    biptaf  test_scenario=data_traffic
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${bip_path}[biptaf]/BIP_L1L2.pcap
    ...  ${longPucchStartDynPuschPrb}    ${longPucchStartPuschPrb}    ${cell_subgroup_id}
    Run Keyword and Continue on Failure    Should be True    ${scell_ul_tp_2}>${scell_ul_tp_1}
    UE Deregister should be Successful    ${sa_ue_id1}
    sleep    5s

    #Adaptive retransmission scenario
    UE Register should be Success   ${sa_ue_id1}
    sleep     5s
    Trigger High DL Traffic SA     ${sa_ue_id1}     250
    sleep    20s
    Trigger UL Traffic SA      ${sa_ue_id1}      50     qfi_id=${QFI_ID}
    sleep    20s
    ${scell_ul_tp_nobler}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=1
     #Check PM counters for PUSCH with MC27>0 MCS30=0 before retransmission
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter
    Verify Any Counters In File
    ...  M55302C14027  >0  PUSCH_CP_SUCC_ANY_256TBL_MCS27
    ...  M55302C14030  0  PUSCH_CP_SUCC_ANY_256TBL_MCS30
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...  file_path=${pm_counter_file}
    Introduce BLER
    sleep    10s
    ${scell_ul_tp_bler}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=1
    Run Keyword and Continue on Failure    Should be True    ${scell_ul_tp_nobler}>${scell_ul_tp_bler}
    sleep    10s
    #Check PM counters for PUSCH with MCS30 after retransmission
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter
    Verify Any Counters In File
    ...  M55302C14030  >0  PUSCH_CP_SUCC_ANY_256TBL_MCS30
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...  file_path=${pm_counter_file}
    #remove BLER
    wtsrunner.ue_testmode_set_nr    id=1    scell=1       testmode=ul_sinr   action=deactivate   profile_id=1
    UE Deregister should be Successful    ${sa_ue_id1}
