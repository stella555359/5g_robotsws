*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     CRT    5G_RAN     SBTS00

Documentation   :copyright: Nokia
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



Resource     CB006877_Resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep    60s
...                 AND     Start Log   btslog

Suite Teardown    Run Keywords
...               MultiUE Deregister should be Successful   ${sa_ue_id_cell3}   ${en_ue_id_cell3}
...               AND   MultiUE Deregister should be Successful   ${sa_ue_id_cell4}   ${en_ue_id_cell4}
...               AND   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...               AND   Stop Log   btslog   snapshot    sosreport


*** Variables ***
${wts_cfg_file}     basic_setup.cfg
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
${cell_subgroup_id}    2

${nbrOfBlankedPRBsLowEdgeUL}    21

${delta_file_name}   TC37_CB006877_CNI_94156_Enable.json
${delta_file_name1}   TC37_CB006877_UL_PRB_Blanking.json

*** Test Cases ***
[1]USCB006877-A#11_TC37_CNI-94156_interworking_when_CB006877_is_enabled_20MHZ
    [Tags]      QC_xxxxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    cprt
    Perform SCF Delta Commissioning with ${delta_file_name}
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
    ...  ${longPucchStartDynPuschPrb}    ${longPucchStartPuschPrb}    ${cell_subgroup_id}
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
    Perform SCF Delta Commissioning with ${delta_file_name1}
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
    ...  ${longPucchStartDynPuschPrb_with_prb_blank}    ${longPucchStartPuschPrb_with_prb_blank}    ${cell_subgroup_id}
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq_prb_blank   ${bip_path}[biptaf]/BIP_L1L2.pcap
    ...  ${nbrOfBlankedPRBsLowEdgeUL}    ${cell_subgroup_id}
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
    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting

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


