*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     CRT    5G_RAN     SBTS00
Documentation   :copyright: Nokia
...             :authors: Nagesh K V
...             :contact: nagesh.k_v@nokia.com
...             INTRODUCTION:     This user scenario describes the gNB behaviour when UE setups the RRC connection
...                               using dedicated config in initialDownlinkBWP with CB006877 enabled. This user scenario
...                               also tests if the DL and UL resource utilization and peak throughput are stable for
...                               dedicated BWP.
...                               This user scenario validates the correct working of CB006877 when UL PRB blanking is
...                               enabled, in MultiBWP .
...                               Thic TC combines CB006877 IWK with CNI-78446 and UL PRB Blanking with CB008954,
...             TEST SET NAME:    CB006877
...             TESTING SPLIT:    Refer CB006877 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB006877 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_24139

Resource     CB006877_Resource.robot
Resource         ./CB008954_resource.robot
Resource       ../resources/ECEcommon/common_deal_config_file.robot
Resource       ../resources/ECEcommon/common_file_operation.robot
Resource         ../resources/robot/configuration_id.robot
Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
#...                 AND    Send Swconfig File To GNB        ${CURDIR}/config/swconfig.txt
...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${r&d_parameter}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=SCF_CB006877_IWK_CNI78446_FDD.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces   ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

#Suite Teardown    Run Keywords
#...               MultiUE Deregister should be Successful   ${sa_ue_id_cell1}   ${en_ue_id_cell1}
#...               AND   MultiUE Deregister should be Successful   ${sa_ue_id_cell2}   ${en_ue_id_cell2}
#...               AND   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...               AND   Stop Log   btslog   snapshot    sosreport


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_CB006877_IWK_CNI78446_FDD.cfg
${IPHY_FILE}                    ${CURDIR}/config/iphy_CB006877_IWK_CNI78446_FDD.xml
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${epc_log_path}    /tmp/
${sa_ue_id_cell1}      1
${en_ue_id_cell1}      2
${sa_ue_id_cell2}      3
${en_ue_id_cell2}      4
${sa_trf_id}    1
${sa_qfi_id}    1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}      1
${QFI_ID}      1
${cell_subgroup_id}    2
${TEST_NAME}        TC42
${nbrOfBlankedPRBsLowEdgeUL}    21
${delta_file_name_disable}      TC_42_CB006877_CNI_78446_Disable.json
${sa_ue_id_cell1_1}      1
${en_ue_id_cell1_1}      3
${delta_file_name}   TC_42_CB006877_CNI_78446_Enable.json
${SCFC}=                   ${CURDIR}/config/SBTS24R3/High_edge_prb_blanking_CA_case.xml
${AP_XML}=                 ${CURDIR}/config/iphy_CA_2Cell_latest.xml
${wts_cfg_file_2}      ${CURDIR}/config/basic_setup_FDD_highedge_prb_blanking.cfg
${r&d_parameter}     0x1002A=1
${no_of_cells}   2

*** Test Cases ***
[1][1.0] USCB006877-B#2_TC42_New_connection_procedure_CNI-78446_interworking_when_CB006877_is_enabled
    [Tags]      QC_xxxxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    cprt
    Perform SCF Delta Commissioning with ${delta_file_name}
    sleep   2s
    ${path1}    Stop Log    cprt   test_scenario=feature_activation
#   Arguments for below commands ${cell_id}='1' | ${bwp_id}='0'
    ${longPucchStartPuschPrb_1_0}    ${longPucchStartDynPuschPrb_1_0}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank
    ...  ${path1}[cprt]/NODECPRT_GNB.pcap    1    0
    ${longPucchStartPuschPrb_1_1}    ${longPucchStartDynPuschPrb_1_1}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank
    ...  ${path1}[cprt]/NODECPRT_GNB.pcap    1    1
    ${longPucchStartPuschPrb_1_2}    ${longPucchStartDynPuschPrb_1_2}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank
    ...  ${path1}[cprt]/NODECPRT_GNB.pcap    1    2
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
#    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${bip_path}[biptaf]/BIP_L1L2.pcap
#    ...  ${longPucchStartDynPuschPrb_1_1}    ${longPucchStartPuschPrb_1_1}    ${0}
#    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${bip_path}[biptaf]/BIP_L1L2.pcap
#    ...  ${longPucchStartDynPuschPrb_1_2}    ${longPucchStartPuschPrb_1_2}    ${0}

    ${cell1_UL_stats}=    cell tput using ue_stats       ${sa_ue_id_cell1}    ${en_ue_id_cell1}
    ${cell2_UL_stats}=    cell tput using ue_stats       ${sa_ue_id_cell2}    ${en_ue_id_cell2}
    Run Keyword and Continue on Failure    Should be True    ${cell1_UL_stats}>${cell2_UL_stats}
    MultiUE Deregister should be Successful   ${sa_ue_id_cell1}   ${en_ue_id_cell1}
    MultiUE Deregister should be Successful   ${sa_ue_id_cell2}   ${en_ue_id_cell2}
####UL PRB blanking with multiBWP TC starts here
    Testprepare second scenario

    [Documentation]  This Test scenario validates high edge PRB blanking with 3BWP's i.e 20Mhz,30Mhz and 40Mhz
    Start Log    cprt
    Perform SCF Delta Commissioning with ${delta_file_name}
    sleep   2s
    ${path1}    Stop Log    cprt   test_scenario=feature_activation_MultiBWP

#   Arguments for the commands below ${cell_id}='1' | ${bwp_id}='0'
    ${longPucchStartPuschPrb_1_0}    ${longPucchStartDynPuschPrb_1_0}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank
    ...  ${path1}[cprt]/NODECPRT_GNB.pcap    1    0
    ${longPucchStartPuschPrb_1_1}    ${longPucchStartDynPuschPrb_1_1}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank
    ...  ${path1}[cprt]/NODECPRT_GNB.pcap    1    1
    ${longPucchStartPuschPrb_1_2}    ${longPucchStartDynPuschPrb_1_2}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank
    ...  ${path1}[cprt]/NODECPRT_GNB.pcap    1    2
    ${longPucchStartPuschPrb_1_2}    ${longPucchStartDynPuschPrb_1_2}=    Verify Ul PUSCH PRBs In CellSetup for PRB Blank
    ...  ${path1}[cprt]/NODECPRT_GNB.pcap    1    3

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
** Keywords **
Testprepare second scenario
    Run keywords    Prepare TL with all config files
#    ...             AND    Suite setup from scratch
    ...             AND    Start WTS Using WTS_Runner   ${wts_cfg_file_2}

Verify prbs in uldata_puschreceivereq_prb_blank
    [Arguments]     ${pcapFile}   ${nbrOfBlankedPRBsLowEdgeUL}
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}     uldata_puschreceivereq
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


Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

cell tput using ue_stats
    [Arguments]      ${start_ue}   ${end_ue}
    ${cell_dl_tp}   set variable  0
    ${cell_ul_tp}   set variable  0
    FOR    ${i}    IN RANGE    ${start_ue}    ${end_ue}+1
            ${cell_ul_tput}=    Get CA Cell Average Throughput    ue_id=${i}    dir=ul    cell_type=scell    scell_index=0
            ${cell_ul_tp}     Evaluate    ${cell_ul_tp} + int(${cell_ul_tput})
    END
    [Return]   ${cell_ul_tp}


