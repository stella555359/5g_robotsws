*** Settings ***
Documentation
...    author: Susana Yan
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    RAN_5G    RAN_5G_TDD    master_classicalbts_all    STATE_CONFIGURED
...    FR1    IPV4    team-SG2    PRI-Medium    SBTS00    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    QCD_MN_RAN    QCP_RAN_VRF
...    CIT    Classical    5GC001094    5GC001546    5GC000718    5GC000573    5GC000732    CDRT    owner-cathy.mao
...    release-5G19A    AP_P1
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${sa_ue_id}    1
${nsa_ue_id}    31


#@{PARAMS_IN_SWCONFIG}    0x58057b = 4    0x58057a = 3

${AP_BIP_FLAG}      ${True}
${GNB_BIP_FLAG}     ${True}
${TTITRACE_FLAG}    ${True}
#${EMIL_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}

@{FAULTS_EXCLUDED_CHECKING}    4681

${carrierfreq}    636576

@{PARAMS_IN_SCF}
...    @{CIT005_Params_both_cellDepType}
...    @{CIT016_Params}
...    @{CIT017_Params}
...    @{CIT021_Params}
...    NRCELL-1:pciExcludeList:range=n4|physCellId=0
...    NRCELL-1:pciExcludeList:physCellId=0|physCellId=0
...    NRCELL-1:pciExcludeList:pciRangeValidity=NSA|physCellId=0
...    NRCELL-1:pciExcludeList:range=n4|physCellId=55
...    NRCELL-1:pciExcludeList:physCellId=55|physCellId=55
...    NRCELL-1:pciExcludeList:pciRangeValidity=SA|physCellId=55

@{CIT005_Params_both_cellDepType}
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac=4580

@{CIT016_Params}
...    @{params_to_enable_nsa_ho}
...    @{enable_a3_meas}
...    @{Cell1_CBRA_Cell2_CFRA_non_srb3}
...    @{cell1_locked}

@{cell1_locked}
...    NRCELL-1:administrativeState=Locked

@{enable_a3_meas}
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:rsrpThresholdSSB=11
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:sMeasConfigSsbRsrp=1


@{Cell1_CBRA_Cell2_CFRA_non_srb3}
...    NRCELL-1:cbraPreamblesPerSsb=n64
...    NRCELL-2:cbraPreamblesPerSsb=n60
...    NRBTS:srb3SupportEnabled=false
...    NRCELL:a3MeasEnabled=rsrp

@{params_to_enable_nsa_ho}

...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true


@{delta_enable_srb3}
...    NRBTS:srb3SupportEnabled=true


##CIT017
@{CIT017_Params}    @{feature_flag}    @{a3_rsrp}    @{intra_freq_inter_gnb}    @{intra_freq_intra_gnb}    @{DRX}
@{feature_flag}
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true


@{a3_rsrp}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:rsrpThresholdSSB=11
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1
@{DRX}
...    NRCELL:actCDrx=true

@{intra_freq_intra_gnb}
...    NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-2:gNbId=1
...    NRBTS-1/NRCELL-1/NRREL-2:gNbIdLength=22
...    NRBTS-1/NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-1/NRREL-2:lcrId=2
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-2/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-2/NRREL-1:lcrId=1
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-2/NRREL-2:gNbId=35
...    NRBTS-1/NRCELL-2/NRREL-2:gNbIdLength=22
...    NRBTS-1/NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-2/NRREL-2:lcrId=1
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
@{intra_freq_inter_gnb}
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:removeNotAllowed=true
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

##CIT021
@{CIT021_Params}    @{A5_PARAMS}    @{HO_PARAMS}    @{5GC000732_Base}
@{A5_PARAMS}
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0


@{HO_PARAMS}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS:timerXnDataFwdGuard=250
...    NRCELL:a5MeasEnabled=rsrp

@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:tWaitingRlRecover=4000ms



${SA_Capa_perUE_Full}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFEC0001F78017FFE00002C7
...    807E290401BFFEF0BFFEBC00E54D00158800000000023003CAA08

${Capa_LTE}    SEPARATOR=
...    BD1BA063058380713400000018062B000060400C1001830030600E268000010300C160801C4D000006060182C000389A00000C0C030581
...    00713400001018060B0600E26800002030048BC500C2000201008010025700100402008040100802010040200804010080201004020080
...    40100802010040201004020080401008000000402008040000000000040200000000000000004020080401008020100000008040100800
...    00000000080400000000000000008040100802010040200804000000201004020080400000000000000008040000000000000000000010
...    09C00202008040080801010000000404008080000000000040400000000000000004020100401008020100402008040100802010040200
...    80401008020100402008080201002020000000808010100000004040000000000020200000000000101004020040400808000000202004
...    04000000000002020040400000000000202000000000000000020270010080201004020000001008020100000008040000000000040200
...    00000000020100402008040000002010040200000010080000000000080400000000000401008020100402008040100802010040200804
...    01008020100402008040100804010080201000000080401008000000402000000100800000040200000000000201000000000001009C00
...    20200404008080101002020000000808010100202000000000001010000000404008080101002020040400000010100202004040000000
...    00002020000000808010100202004040080800000020200404008080000000000040400000010080201004020080401008020100402008
...    04010080201004020080401008020100402008040100804017001008010100000004040080800000000000000008080000000000000000
...    00002010020200000008080101000000000000000010100000000000000000000040200404000000101002020000000000000000202000
...    000000000000000000804008080000002020040400808000000000004040000001010020200000000000000002020000000809C4008018
...    0100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0
...    080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600
...    400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801080004020
...    2004008400040101002004

#just switch bandcomb 1 with bandcomb 3
${EDA_Capa_LTE}    SEPARATOR=
...    BD1BA063058200713400000018062B000060400C1001830030600E268000010300C160E01C4D000006060182C000389A00000C0C0305810
...    0713400001018060B0600E26800002030048BC500C2000201008010025700100402008040100802010040200804010080201004020080401008020
...    1004020100402008040100800000040200804000000000004020000000000000000402008040100802010000000804010080000000000080400000
...    00000000000804010080201004020080400000020100402008040000000000000000804000000000000000000001009C0020200804008080101000
...    0000404008080000000000040400000000000000004020100401008020100402008040100802010040200804010080201004020080802010020200
...    0000080801010000000404000000000002020000000000010100402004040080800000020200404000000000002020040400000000000202000000
...    0000000000202700100802010040200000010080201000000080400000000000402000000000002010040200804000000201004020000001008000
...    0000000080400000000000401008020100402008040100802010040200804010080201004020080401008040100802010000000804010080000004
...    02000000100800000040200000000000201000000000001009C0020200404008080101002020000000808010100202000000000001010000000404
...    0080801010020200404000000101002020040400000000000202000000080801010020200404008080000002020040400808000000000004040000
...    0010080201004020080401008020100402008040100802010040200804010080201004020080401008040170010080101000000040400808000000
...    0000000000808000000000000000000002010020200000008080101000000000000000010100000000000000000000040200404000000101002020
...    0000000000000002020000000000000000000008040080800000020200404008080000000000040400000010100202000000000000000020200000
...    00809C40080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600
...    400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400
...    C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080108000402020040084000
...    40101002004

@{PM_Counters_Check}
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:${SAMPLES_CELL_AVAIL}>0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2:${SAMPLES_CELL_AVAIL}>0
...    NRCELL-1:${INTRA_DU_HO_ATT_NSA_MNB}=${loop_time}
...    NRCELL-1:${INTRA_FR_PSCEL_CH_TOT_DURAT}>0
...    NRCELL-2:${INTRA_FR_PSCEL_CH_TOT_DURAT}>0
...    NRCELL-2:${INTRA_DU_HO_ATT_NSA_MNB}=${loop_time}
...    ${X2_SGNB_CHG_REQD_SENT}=${2*${loop_time}}
...    ${X2_SGNB_CHG_CONF_RECEIVED}=${2*${loop_time}}
...    ${X2_SGNB_CHG_REF_RECEIVED}=0
...    ${X2_SGNB_RECONF_SN_CH_RCVD}=${2*${loop_time}}
...    ${X2_SGNB_RECONF_ACK_SN_CH_RCVD}=${2*${loop_time}}
...    ${INTRA_DU_HO_ATT_NSA_SRB3}=${2*${loop_time}}
...    ${F1_UE_CTXT_MOD_FAIL_SENT}=0
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=${1+2*${loop_time}}
...    ${REESTAB_ACC_OTHER_FAIL_DU}=${1+2*${loop_time}}
...    ${NF1CD_DL_RRC_MSG_TRANSFER}=93
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=${1+${loop_time}}
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=${1+${loop_time}}
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=${1+${loop_time}}
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}=11
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REL}=11
...    NRCELL-1:${SA_DU_GBR_DRB_REL}=0



${SAMPLES_CELL_AVAIL}    M55601C00002
${F1_UE_CTXT_MOD_FAIL_SENT}    M55117C00003
${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004
${SGNB_SA_DU_NGBR_DRB_REL}    M55139C00012
${SA_DU_GBR_DRB_REL}    M55139C00509

${INTRA_DU_HO_ATT_NSA_MNB}    M55120C01001
${INTRA_FR_PSCEL_CH_TOT_DURAT}    M55120C00007
${X2_SGNB_CHG_REQD_SENT}             M55112C02501
${X2_SGNB_CHG_CONF_RECEIVED}         M55112C02502
${X2_SGNB_RECONF_SN_CH_RCVD}         M55112C02505
${X2_SGNB_RECONF_ACK_SN_CH_RCVD}     M55112C02506
${X2_SGNB_CHG_REF_RECEIVED}          M55112C02512
${INTRA_DU_HO_ATT_NSA_SRB3}          M55120C01002
${NF1CD_DL_RRC_MSG_TRANSFER}    M55117C02001
@{endcCapModified}
...    UE EUTRA NR Capaility is modified
...    UE NR Capability is modified

${loop_time}    5


*** Test Cases ***
5GSW-CP-CIT016_Verify_Classical_NSA_TDD_cmWave_intra_frequency_intra_gNB_HO_with_A3_RSRP_CBRA_non_SRB3_is_successful
    [Documentation]
    ...    This case will include feature 5GC001094, feature 5GC000718, feature 5GC001546.
    ...    After adding more 1 cell, to verify Classical NSA TDD cmWave - intra-frequency intra-gNB HO with A3 RSRP CBRA
    ...    non SRB3 is successful
    ...    pre-condition: Prepare scf.xml with parameter "administrativeState" locked in cell1
    ...    check counters: M55120C01001 (INTRA_DU_HO_ATT_NSA_MNB),M55120C00007(INTRA_FR_PSCEL_CH_TOT_DURAT)
    Clear Counter Files
    Setup X2 Link then Drop Ng Link then Unlock Cell1
    X2 Link For Simulated gNB-35
    LOOP Five SA NSA UEs Attach
    Trigger RRC Reestablish    target_cell=1
    Trigger IntraFreA3 HO From Cell1 To Cell2    ue_id=32
    Trigger IntraFreA3 HO From Cell2 To Cell1    ue_id=32
    Delta Commission Parameters    ${delta_enable_srb3}
    Combination NSA HO
    SA intrFreq intraGNB HO From Cell1 to Cell2
    Trigger RRC Reestablish    target_cell=2
    SA intrFreq intraGNB HO From Cell2 to Cell1
    Trigger RRC Reestablish    target_cell=1
    Repeat Above Steps If Need
    Check Counters    ${PM_Counters_Check}
    Check Wireshark Log    ${CURDIR}/a2a_Merge/a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

LOOP Five SA NSA UEs Attach
    FOR    ${index}    IN RANGE    0    5
        ${sa_ue}    Evaluate    ${sa_ue_id}+${index}
        Sa Ue Register And Pdu Setup    ${sa_ue}
        Start SA Traffic    ${sa_ue}
        ${nsa_ue}    Evaluate    ${nsa_ue_id}+${index}
        Nsa Ue Attach    ${nsa_ue}
        Start NSA Traffic    ${nsa_ue}
    END

Repeat Above Steps If Need
    Repeat Keyword    ${${loop_time}-1}    Case Repetive Steps

Case Repetive Steps
    Trigger IntraFreA3 HO From Cell1 To Cell2    ue_id=32
    Trigger IntraFreA3 HO From Cell2 To Cell1    ue_id=32
    Delta Commission Parameters    ${delta_enable_srb3}
    Combination NSA HO
    SA intrFreq intraGNB HO From Cell1 to Cell2
    Trigger RRC Reestablish    target_cell=2
    SA intrFreq intraGNB HO From Cell2 to Cell1
    Trigger RRC Reestablish    target_cell=1


X2 Link For Simulated gNB-35
    Execute Egate Command    enb_x2_link_up enb=1 target=3
    ...    pass_regexp=is UP

Combination NSA HO
    Initial IntraFreA3 Ho To SimGNB    phycell_id=381
    Initial IntraFreA3 InterGNB Ho CFRA    phycell_id=51
    Initial IntraFreA3 IntraGNB Ho    phycell_id=50
    Initial IntraFreA3 IntraGNB Ho CFRA    phycell_id=51
    Initial IntraFreA3 Ho To SimGNB    phycell_id=381
    Initial IntraFreA3 IntraGNB Ho    phycell_id=50

SA intrFreq intraGNB HO From Cell1 to Cell2
    SA UE Handover    target_cell=2    source_cell=1    pci=51
    Verify SA Throughput    ue_id=1

SA intrFreq intraGNB HO From Cell2 to Cell1
    SA UE Handover    target_cell=1    source_cell=2    pci=50
    Verify SA Throughput    ue_id=1

SA UE Handover
    [Arguments]    ${target_cell}    ${source_cell}    ${pci}
    Trigger A5 Event    phycell_id=${pci}    sourcecell_id=${source_cell}    targetcell_id=${target_cell}
    sleep    5s    reason=wait related output to be finished

Trigger A5 Event
    [Arguments]    ${ue_id}=1    ${phycell_id}=51    ${sourcecell_id}=1    ${targetcell_id}=2
    ${a5_measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=636576    event_type=A5
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${a5_measid} event=A5 srsrp_nr=20 srsrq_nr=20 phycell_id=${phycell_id} nrsrp_nr=61 nrsrq_nr=61
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.${sourcecell_id} to EXT_ENB-2.${targetcell_id} performed
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measObjectToAddModList
    Should Contain    ${ret1}    measObject measObjectNR
    Should Contain    ${ret1}    physCellId ${phycell_id}


Trigger RRC Reestablish
    [Arguments]    ${target_cell}    ${ue_id}=1
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${target_cell} cause=otherFailure
    ...    UE1: NR RRC Reestablishment sucessfully completed    timeout=20s
    rrc Should Contain    UE1: NR RRC Reestablishment sucessfully completed
    Verify SA Throughput    ue_id=${ue_id}



Sa Ue Register And Pdu Setup
    [Arguments]    ${id}    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${id} pdu=${pdu} nwslice=${nwslice} gw=${id}    ${cmd_pdu_regexp}

Nsa Ue Attach
    [Arguments]    ${id}    ${target_cells}=1    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    ${cmd_regexp}

Start SA Traffic
    [Arguments]    ${ue_id}    ${dl}=5    ${ul}=5
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${dl} trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=${ul} trf_id=1    pass_regexp=Started Uplink
    Verify SA Throughput    ue_id=${ue_id}

Start NSA Traffic
    [Arguments]    ${ue_id}    ${dl}=5    ${ul}=5
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=${dl} trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=${ul} trf_id=2    UE ${ue_id}: UDP UL
    Verify NSA Throughput    ue_id=${ue_id}

Verify NSA Throughput
    [Arguments]    ${ue_id}    ${Tput_dl}=4.1    ${Tput_ul}=4.1
    Sleep    15s
    ${ul_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    ${dl_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    run keyword and ignore error    Should Be True    ${dl_Throughput}/1000>${Tput_dl}
    run keyword and ignore error    Should Be True    ${ul_Throughput}/1000>${Tput_ul}

Verify SA Throughput
    [Arguments]    ${ue_id}    ${Tput_dl}=4.1    ${Tput_ul}=4.1
    Sleep    15s
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    run keyword and ignore error    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    run keyword and ignore error    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Setup X2 Link then Drop Ng Link then Unlock Cell1
    Setup GNB X2 Link up
    Cell Should Be Locked    1
    Drop Ng Link
    Delta Commission Parameters    NRCELL-1:administrativeState=Unlocked
    Delta Commission Parameters    NRCELL-2:administrativeState=Locked
    Delta Commission Parameters    NRCELL-2:administrativeState=Unlocked
    Cells Should Be Onair


Setup GNB X2 Link up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2

Modify Cfg
    ${V_1}    catenate
    ...    ue_param id=31 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    ${V_2}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${V_1}
    Update Cfg    gnb_set id=3 s1u=10.0.1.126 plmn=311:489 gnb_id=0x23:22 type=simulated daemon=:22222 x2=10.0.1.126:36422
    Update Cfg    ${V_2}
    Update Cfg    gnb_endc_param id=3 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0

#EDA UE capa changed during HO
Modify UE capa
    [Arguments]    ${ue_id}=1
    Execute Egate Command
    ...    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${EDA_Capa_LTE}
    ...    pass_regexp=${endcCapModified}

Trigger IntraFreA3 HO From Cell1 To Cell2
    [Arguments]    ${ue_id}
    Initial IntraFreA3 IntraGNB Ho    phycell_id=51    ue_id=32
    Verify NSA Throughput    ${ue_id}

Initial IntraFreA3 IntraGNB Ho
    [Arguments]    ${phycell_id}    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=reported successful RA
    Verify NSA Throughput    ${ue_id}

Initial IntraFreA3 IntraGNB Ho CFRA
    [Arguments]    ${phycell_id}    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=reported successful RA
    Should Contain    ${ret1}    cfra
    Verify NSA Throughput    ${ue_id}

Initial IntraFreA3 Ho To SimGNB
    [Arguments]    ${phycell_id}    ${ue_id}=31
    Modify UE capa    ue_id=${ue_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=reported successful RA


Initial IntraFreA3 InterGNB Ho CFRA
    [Arguments]    ${phycell_id}    ${ue_id}=31
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V_4}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ret1}=     Execute Egate Command
    ...    ${V_4}
    ...    pass_regexp=Sending SgNB Change Confirm
    Should Contain    ${ret1}    cfra
    Verify NSA Throughput    ${ue_id}

Trigger IntraFreA3 HO From Cell2 To Cell1
    [Arguments]    ${ue_id}
    Initial IntraFreA3 IntraGNB Ho    phycell_id=50    ue_id=32
    Verify NSA Throughput    ${ue_id}

Drop Ng Link
    execute egate command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=shutdown    NG Link Drop
    sleep    5s    #sleep for NG link to be dropped
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive
