*** Settings ***
Documentation     Combined CB006877 cases

Resource     CB006877_Resource.robot

Suite Setup         Suite setup from scratch


*** Variables ***
${wts_cfg_file_TC37}     basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${epc_log_path}    /tmp/

${sa_ue_id_cell3}      51
${en_ue_id_cell3}      55
${sa_ue_id_cell4}      71
${en_ue_id_cell4}      75
${sa_trf_id}    1
${sa_qfi_id}    1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}      1
${QFI_ID}      1
${TC37_cell_subgroup_id}    2

${nbrOfBlankedPRBsLowEdgeUL}    21

${TC37_delta_file_name}   TC37_CB006877_CNI_94156_Enable.json
${TC37_delta_file_name1}   TC37_CB006877_UL_PRB_Blanking.json

#TC14 Variables
${wts_cfg_file_TC14}     ${CURDIR}/config/basic_setup_TC14.cfg
${first_sa_ue}      ${1}
${last_sa_ue}     ${4}
${first_nsa_ue}      ${11}
${last_nsa_ue}      ${15}
${nrcell}   1
${TC14_cell_subgroup_id}   0
${IPHY_FILE_TC14}                    ${CURDIR}/config/iphy_AHLOA_2C_TC14.xml
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
${TC14_delta_file_name}   TC06_CB006877_disable.json
${INITIAL_CONTEXT_SETUP_FAILURE} =    ngap.InitialContextSetupFailure_element && ngap.radioNetwork == 22
${gbr_load} =  (itf_l2_ps_cell_celldlgbrloadind) || (itf_l2_ps_cell_cellulgbrloadind)
${no_of_cells}   2

#TC32 Variables
${wts_cfg_file_TC32}     ${CURDIR}/config/basic_setup_ca.cfg
${UE_ID}         1
${sa_ue_id1}     1
${TC32_cell_subgroup_id}    1

${SCFC_TC32}=                        ${CURDIR}/config/SCF_CA.xml
${AP_XML_TC32}=                      ${CURDIR}/config/iphy_f_t_2cell.xml
${TC32_delta_file_name}   TC32_CB006877_enable.json



*** Test Cases ***
USCB006877-A#11_TC37_CNI-94156_interworking_when_CB006877_is_enabled_20MHZ
    [Documentation]   :copyright: Nokia
    ...             :authors: Manasa
    ...             :contact: manasa.shankarappa@nokia.com
    ...             INTRODUCTION:     This user scenario describes the gNB behaviour when UE setups the RRC connection
    ...                               using dedicated config in initialDownlinkBWP with CB006877 enabled. This user scenario
    ...                               also tests if the DL and UL resource utilization and peak throughput are stable for
    ...                               dedicated BWP.
    ...                               This user scenario validates the correct working of CB006877 when UL PRB blanking is
    ...                               enabled.This user scenario describes if 21PRB are blanked at the low edge in UL FDD
    ...                               10 MHz cell, the UL traffic can be scheduled within non-blanked area. Once UE attach
    ...                               in 5G cell, the SRS / PTRS / PUCCH / PRACH / PUSCH resource should be assigned
    ...                               within non-blanked area.
    ...                               Thic TC combines UL PRB Balnking and CNI_94156
    ...             TEST SET NAME:    CB006877
    ...             TESTING SPLIT:    Refer CB006877 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB006877 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_24139
    [Setup]       Run Keywords   Start WTS Using WTS_Runner      ${wts_cfg_file_TC37}
    ...           AND     sleep    60s
    ...           AND     Start Log   btslog
    ${TEST_NAME}    Set Variable   A_TC37
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    cprt
    Perform SCF Delta Commissioning with ${TC37_delta_file_name}
    sleep   2s
    ${path1}    Stop Log    cprt   test_scenario=feature_activation
#    ${longPucchStartPuschPrb}    ${longPucchStartDynPuschPrb}=     Verify Dynamic PUSCH in CellSetup
    ${longPucchStartPuschPrb}    ${longPucchStartDynPuschPrb}=     Verify UL PUSCH PRBs In CellSetupReq
    ...  ${path1}
    MultiUE Register should be Successful    ${sa_ue_id_cell3}   ${en_ue_id_cell3}
    MultiUE Register should be Successful    ${sa_ue_id_cell4}   ${en_ue_id_cell4}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell3}    ${en_ue_id_cell3}    mbps    100
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell3}    ${en_ue_id_cell3}    mbps    100
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    mbps    100
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    mbps    100
    sleep    20s
    Start Log    biptaf
    sleep   2s
    ${bip_path}   Stop Log    biptaf  test_scenario=data_traffic
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${bip_path}[biptaf]/BIP_L1L2.pcap
    ...  ${longPucchStartDynPuschPrb}    ${longPucchStartPuschPrb}    ${TC37_cell_subgroup_id}
    Run Keyword And Continue on Failure     Wait Until Keyword Succeeds    10x    1s
    ...  Validate DL Traffic For MultiUE for SA    ${sa_ue_id_cell3}    ${en_ue_id_cell3}    39
    Run Keyword And Continue on Failure     Wait Until Keyword Succeeds    10x    1s
    ...  Validate UL Traffic For MultiUE for SA    ${sa_ue_id_cell3}    ${en_ue_id_cell3}    45
    Run Keyword And Continue on Failure     Wait Until Keyword Succeeds    10x    1s
    ...  Validate DL Traffic For MultiUE for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    39
    Run Keyword And Continue on Failure     Wait Until Keyword Succeeds    10x    1s
    ...  Validate UL Traffic For MultiUE for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    42
    ${cell3_UL_stats}=    Check cell level UL tput SA    ${sa_ue_id_cell3}    ${en_ue_id_cell3}
    ${cell4_UL_stats}=    Check cell level UL tput SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}
    Run Keyword and Continue on Failure    Should be True    ${cell3_UL_stats}>${cell4_UL_stats}
    MultiUE Deregister should be Successful   ${sa_ue_id_cell3}   ${en_ue_id_cell3}
    MultiUE Deregister should be Successful   ${sa_ue_id_cell4}   ${en_ue_id_cell4}
##UL PRB blanking TC starts here
    Start Log    cprt
    Perform SCF Delta Commissioning with ${TC37_delta_file_name1}
    sleep   2s
    ${path2}    Stop Log    cprt   test_scenario=feature_activation_prb_blank
#    ${longPucchStartPuschPrb_with_prb_blank}    ${longPucchStartDynPuschPrb_with_prb_blank}=    Verify UL PUSCH PRBs In CellSetupReq
#    ...  ${path2}
    ${longPucchStartPuschPrb_with_prb_blank}    ${longPucchStartDynPuschPrb_with_prb_blank}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank
    ...  ${path2}[cprt]/NODECPRT_GNB.pcap    3    1
    MultiUE Register should be Successful    ${sa_ue_id_cell3}    ${en_ue_id_cell3}
    MultiUE Register should be Successful    ${sa_ue_id_cell4}    ${en_ue_id_cell4}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell3}    ${en_ue_id_cell3}    mbps    100
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell3}    ${en_ue_id_cell3}    mbps    100
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    mbps    100
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    mbps    100
    sleep    10s
    Start Log    biptaf
    sleep   2s
    ${bip_path}   Stop Log    biptaf  test_scenario=data_traffic
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${bip_path}[biptaf]/BIP_L1L2.pcap
    ...  ${longPucchStartDynPuschPrb_with_prb_blank}    ${longPucchStartPuschPrb_with_prb_blank}    ${TC37_cell_subgroup_id}
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq_prb_blank   ${bip_path}[biptaf]/BIP_L1L2.pcap
    ...  ${nbrOfBlankedPRBsLowEdgeUL}    ${TC37_cell_subgroup_id}
    Run Keyword And Continue on Failure     Wait Until Keyword Succeeds    10x    1s
    ...     Validate DL Traffic For MultiUE for SA    ${sa_ue_id_cell3}    ${en_ue_id_cell3}    39
    Run Keyword And Continue on Failure     Wait Until Keyword Succeeds    10x    1s
    ...     Validate UL Traffic For MultiUE for SA    ${sa_ue_id_cell3}    ${en_ue_id_cell3}    35
    Run Keyword And Continue on Failure     Wait Until Keyword Succeeds    10x    1s
    ...     Validate DL Traffic For MultiUE for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    39
    Run Keyword And Continue on Failure     Wait Until Keyword Succeeds    10x    1s
    ...     Validate UL Traffic For MultiUE for SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}    35
    ${cell3_UL_stats}=    Check cell level UL tput SA    ${sa_ue_id_cell3}    ${en_ue_id_cell3}
    ${cell4_UL_stats}=    Check cell level UL tput SA    ${sa_ue_id_cell4}    ${en_ue_id_cell4}
    Run Keyword and Continue on Failure    Should be True    ${cell3_UL_stats}>${cell4_UL_stats}
    Run Keyword And Continue on Failure    Link SCOUT SCF to Configuration ID for Reporting
    [Teardown]    Run Keywords
    ...           MultiUE Deregister should be Successful   ${sa_ue_id_cell3}   ${en_ue_id_cell3}
    ...           AND   MultiUE Deregister should be Successful   ${sa_ue_id_cell4}   ${en_ue_id_cell4}
    ...           AND   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...           AND   Stop Log   btslog   snapshot    sosreport

USCB006877-A#2_TC14_CB008379_GBR_Load_reporting_for_GBR_Radio_Admission_Control_with_CB006877_enabled
    [Documentation]    :copyright: Nokia
    ...              :authors: Mohan
    ...              :contact: mohanavel.p@nokia.com
    ...              To accept a GBR 5QI [2/3/4/71/72/76] or operator defined 5QI [128..254] bearer addition
    ...              request there must be sufficient available GBR resources in the cell. L2RT will periodically
    ...              report the GBR load to C-Plane. C-Plane will use this data to determine if there is sufficient
    ...              GBR resources available to admit another 5QI [2/3/4/71/72/76] or [128..254] bearer with a given
    ...              GBR value. This user scenario describes the case in which there is not sufficient GBR resources
    ...              to admit another 5QI [2/3/4/71/72/76] or [128..254] bearer.
    ...              *REQUIREMENTS COVERAGE:
    ...              *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_23360

    [Setup]         Run keywords
    ...             Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE_TC14}
    ...    AND     Find Scfc And Fix And Send Full Commissioning      scfc_filename=SCF_TC14_SANSA_20Mhz.xml
    ...    AND     Load CFG Config And Verify cell setup in Capture CPRT Traces   ${wts_cfg_file_TC14}   ${no_of_cells}
    ...    AND     Check gNB Bulid
    ${TEST_NAME}    Set Variable   A_TC14
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    ${StartPuschPrb}    ${StartDynPuschPrb}   Verify UL PUSCH PRBs In CellSetupReq      ${cprt_log}
    log to console   Wait for next PM to starts
    Wait until the next Measurement Period starts
    Attach multiple SA UE with ICS nGBR,5QI1 & 2 and verify gbrload  ${first_sa_ue}    ${last_sa_ue}
    log to console   Wait for next PM to stop
    Wait until the current Measurement Period stops
    ${6877_on_GBR_RAC}=    Get Latest Unpacked Raw Pm Counters File   output_dirpath=${OUTPUT DIR}/6877_on_GBR_RAC
    Verify Any Counters In File
    ...  M55138C01001  8  SA_GBR_DRB_REQ
    ...  M55138C01002  6  SA_GBR_DRB_SUCC
    ...  M55138C01003  2  SA_GBR_REJ_LACK_DRB
    ...  M55138C01004  0  SA_GBR_DRB_REL
    ...  M55308C10002  >10000000  PRB_USED_PUSCH
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${nrcell}
    ...  file_path=${6877_on_GBR_RAC}
    MultiUE Deregister should be Successful   ${first_sa_ue}    ${last_sa_ue}
    #GBR load check with feature off
    Perform SCF Delta Commissioning with ${TC14_delta_file_name}
    sleep   5s
    log to console   Wait for next PM to starts
    Wait until the next Measurement Period starts
    Attach multiple SA UE with ICS nGBR,5QI1 & 2 and verify gbrload  ${first_sa_ue}    ${last_sa_ue}
    log to console   Wait for next PM to stop
    Wait until the current Measurement Period stops
    ${6877_off_GBR_RAC}=    Get Latest Unpacked Raw Pm Counters File   output_dirpath=${OUTPUT DIR}/6877_off_GBR_RAC
    Verify Any Counters In File
    ...  M55138C01001  8  SA_GBR_DRB_REQ
    ...  M55138C01002  6  SA_GBR_DRB_SUCC
    ...  M55138C01003  2  SA_GBR_REJ_LACK_DRB
    ...  M55138C01004  0  SA_GBR_DRB_REL
    ...  M55308C10002  >10000000  PRB_USED_PUSCH
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${nrcell}
    ...  file_path=${6877_off_GBR_RAC}
    MultiUE Deregister should be Successful   ${first_sa_ue}    ${last_sa_ue}
    [Teardown]     Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...            AND     Stop Log   snapshot
    ...            AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

USCB006877-A#9_TC32_FR1_UL_and_DL_CA_interworking_with_CB006877_single_UE
    [Documentation]   :copyright: Nokia
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

    [Setup]    Run Keywords  Prepare TL with all config files New    ${SCFC_TC32}    ${AP_XML_TC32}
    ...                 AND     Start Log   btslog
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC32}
    ...                 AND     sleep    20s
    ${TEST_NAME}    Set Variable   A_TC32
    set suite variable     ${TEST_NAME}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
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
    Perform SCF Delta Commissioning with ${TC32_delta_file_name}
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
    ...  ${longPucchStartDynPuschPrb}    ${longPucchStartPuschPrb}    ${TC32_cell_subgroup_id}
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
    [Teardown]   Run Keywords    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...           AND   Stop Log   btslog   snapshot    sosreport

** Keywords **
Verify prbs in uldata_puschreceivereq_prb_blank
    [Arguments]     ${pcapFile}   ${nbrOfBlankedPRBsLowEdgeUL}    ${cell_subgroup_id}
    ${pdmlFile}=         Get filtered PDML file from pcap    ${pcapFile}     (uldata_puschreceivereq) && (3gpp.subcellid == ${cell_subgroup_id})
    @{list_of_values}    Get Packet Match List     ${pdmlFile}   uldata_puschreceivereq    ${pathlist}
    ...                  ${filter}   ${startPacket}   ${endPacket}
    ${total_uldata_pusch}   get length   ${list_of_values}
    FOR      ${prb_packet}     IN      @{list_of_values}
        Get Value In Match Packet PRB Blank     ${prb_packet}     startPrb    ${nbrOfBlankedPRBsLowEdgeUL}
    END

Get Value In Match Packet PRB Blank
    [Arguments]      ${packetMatch}   ${field}   ${blanked_prbs}   ${kind}=show
    @{listPath}                     Get Dictionary Keys                 ${packetMatch.fields}
    FOR    ${path}         IN      @{listPath}
            ${fieldName}            Get Field Name From Path            ${path}
            ${startprb}=   Run Keyword if     '${fieldName}'=='${field}'   Set Variable   ${packetMatch.fields['${path}'].${kind}}
            ${startprb}=    convert to integer      ${startprb}
            Should be True   ${startprb} > ${blanked_prbs}
    END


