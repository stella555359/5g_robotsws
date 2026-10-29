*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    CLOUD_R4P    RAN_4G    CLOUD_R4LAPO_CUS
...               team-CN3ET    release-SBTS19A    owner-fei.he    owner-xu.wang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_CATM_Volte}
...    @{PARAMS_FOR_NormalUE}
...    @{PARAMS_FOR_CATM_emerg}
...    @{PARAMS_FOR_neighbor}
...    @{PARAMS_FOR_Cell}
...    @{PARAMS_FOR_threshold}
...    @{FIX_VALIDATION_ERROR}
@{PARAMS_FOR_CATM}
...    LNCEL/LNCEL_FDD-0:actCatM=true
...    LNCEL/CATMCEL-0:numCELevelCatM=2
...    LNCEL/CATMCEL-0:threshold2CatM=42
...    LNCEL/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNBTS/CATMPR-1:raPreGrCSizeCatM=2
...    LNBTS/CATMPR-1:catMCELevel1:raPreGrCSizeCatM=2
...    LNBTS/CATMBPR-1:catMCELevel2:raPreGrCSizeCatM=2
...    LNBTS/CATMBPR-1:catMCELevel3:raPreGrCSizeCatM=2
...    LNBTS/CATMPR-2:raPreGrCSizeCatM=2
...    LNBTS/CATMPR-2:catMCELevel1:raPreGrCSizeCatM=2
...    LNBTS/CATMBPR-2:catMCELevel2:raPreGrCSizeCatM=2
...    LNBTS/CATMBPR-2:catMCELevel3:raPreGrCSizeCatM=1
...    LNBTS/CATMBPR-2:defaultPagCeModeBCatM=n16
...    LNBTS/CATMBPR-1:defaultPagCeModeBCatM=n16
...    LNCEL:dlsDciCch=DCI format 1A
...    LNBTS/CATMPR-1:cpInactivityTimerCatM=60
...    LNBTS/CATMPR-1:srbInactivityTimerCatM=60
...    LNBTS/CATMPR-1:inactivityTimerCatM=170
#...    LNBTS/CATMPR-1:raPreGrCSizeCatM=5
...    LNCEL-1/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-2/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-3/LNCEL_FDD-0:catMBProfId=2
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-2/LNCEL_FDD-0:catMProfId=1
...    LNCEL-3/LNCEL_FDD-0:catMProfId=2
@{PARAMS_FOR_NormalUE}
...    LNCEL:inactivityTimer=170
...    LNCEL:inactivityTimerQci5Sign=100
...    LNCEL:qci1ProtectionTimer=180
...    LNBTS:qciTab5:schedulType=SIGNALLING
...    LNBTS:qciTab5:lcgid=0
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNBTS:actRrcConnNoActivity=true
...    LNBTS:actBbPooling=true
...    LNBTS:bbPoolMinResource=1
...    LNBTS:bbPoolEvalPeriod=20
...    LNCEL/BBPOOLALLOC:bbPoolTargetId=1
...    LNCEL/BBPOOLALLOC:bbPoolAllocMode=manual
...    LNCEL/BBPOOLALLOC:bbPoolLogicalGroupId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS/CATMPR-1:raPreGrCSizeCatM=5
@{PARAMS_FOR_CATM_Volte}
...    LNCEL/CATMCEL-0:actConvVoiceCatM=true
...    LNBTS/CATMPR-1:qciForVoLTECatM=255
...    LNBTS/CATMPR-1:catMVoLTETab:dlMaxHarqTxQci1CatM=4
...    LNBTS/CATMPR-1:catMVoLTETab:maxGbrDlQci1CatM=80
...    LNBTS/CATMPR-1:catMVoLTETab:maxGbrUlQci1CatM=80
...    LNBTS/CATMPR-1:catMVoLTETab:tDiscardPdcpQci1CatM=infinity
...    LNBTS/CATMPR-1:catMVoLTETab:tDiscardPdcpQci5CatM=300ms
...    LNBTS/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=180
@{PARAMS_FOR_CATM_emerg}
...    LNBTS:imsEmerPlmnConfig:emerSessArpPrioLev=1
...    LNCEL-1/CATMCEL-0:actIMSEmerSessCatM=true
...    LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
@{PARAMS_FOR_neighbor}
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1500
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=4000
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=1450
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1500
...    LNCEL-2/LNHOIF-2:eutraCarrierInfo=4000
...    LNCEL-2/LNHOIF-3:eutraCarrierInfo=1450
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-3/LNHOIF-2:eutraCarrierInfo=1600
...    LNCEL-3/LNHOIF-3:eutraCarrierInfo=1550
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:ecgiLcrId=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-3:handoverAllowed=allowed
...    LNCEL-1/LNREL-3:ecgiLcrId=3
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:handoverAllowed=allowed
...    LNCEL-2/LNREL-2:ecgiLcrId=1
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-3:handoverAllowed=allowed
...    LNCEL-2/LNREL-3:ecgiLcrId=3
...    LNCEL-2/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-2:handoverAllowed=allowed
...    LNCEL-3/LNREL-2:ecgiLcrId=1
...    LNCEL-3/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-3:handoverAllowed=allowed
...    LNCEL-3/LNREL-3:ecgiLcrId=2
...    LNCEL-3/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-388:handoverAllowed=allowed
...    LNCEL-1/LNREL-388:ecgiLcrId=9
...    LNCEL-1/LNREL-388:ecgiAdjEnbId=74566
...    LNBTS/LNADJ-255:rlfBasedRCRsupported=true
...    LNCEL-1/LNREL-388:removeAllowed=false
@{PARAMS_FOR_Cell}
...    LNBTS:actRLFbasedRCR=true
...    LNBTS:actIfHo=enabled
...    LNBTS:rlfBasedRCRdefault=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-3/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-3/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-1/SIB-0:siWindowLen=40ms
...    LNCEL-2/SIB-0:siWindowLen=40ms
...    LNCEL-3/SIB-0:siWindowLen=40ms
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...    LNCEL-1:t301Guard=1000
...    LNCEL-2:t301Guard=1000
...    LNCEL-3:t301Guard=1000
...    LNCEL-1/SIB-0:threshServingLowQR9=0
...    LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNCEL-2/SIB-0:threshServingLowQR9=0
...    LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNCEL-3/SIB-0:threshServingLowQR9=0
...    LNCEL-3/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    delete:LNBTS/PSGRP-1
@{PARAMS_FOR_threshold}
...    LNCEL-1:threshold1=75
...    LNCEL-1:threshold2InterFreq=40
...    LNCEL-1:threshold2a=67
...    LNCEL-1:threshold2aQci1=67
...    LNCEL-1:hysThreshold2InterFreq=0
...    LNCEL-1:cellResourceGroupPrId=1
...    LNCEL-1:inactivityTimerPubSafety=600
...    LNCEL-1:iFServiceBasedHoRetryTimer=60
...    LNCEL-1:threshold2GERANQci1=25
...    LNCEL-1:threshold2InterFreqQci1=35
...    LNCEL-1:threshold2InterFreqHpue=40
...    LNCEL-1:a2TimeToTriggerActWcdmaMeas=0ms
...    LNCEL-1:a2TimeToTriggerActInterFreqMeas=100ms
...    LNCEL-1:iniMcsUl=4
...    LNCEL-2:threshold1=75
...    LNCEL-2:threshold2InterFreq=40
...    LNCEL-2:threshold2a=67
...    LNCEL-2:threshold2aQci1=67
...    LNCEL-2:hysThreshold2InterFreq=0
...    LNCEL-2:cellResourceGroupPrId=1
...    LNCEL-2:inactivityTimerPubSafety=600
...    LNCEL-2:iFServiceBasedHoRetryTimer=60
...    LNCEL-2:threshold2GERANQci1=25
...    LNCEL-2:threshold2InterFreqQci1=35
...    LNCEL-2:threshold2InterFreqHpue=40
...    LNCEL-2:a2TimeToTriggerActWcdmaMeas=0ms
...    LNCEL-2:a2TimeToTriggerActInterFreqMeas=100ms
...    LNCEL-3:threshold1=75
...    LNCEL-3:threshold2InterFreq=40
...    LNCEL-3:threshold2a=67
...    LNCEL-3:threshold2aQci1=67
...    LNCEL-3:hysThreshold2InterFreq=0
...    LNCEL-3:cellResourceGroupPrId=1
...    LNCEL-3:inactivityTimerPubSafety=600
...    LNCEL-3:iFServiceBasedHoRetryTimer=60
...    LNCEL-3:threshold2GERANQci1=25
...    LNCEL-3:threshold2InterFreqQci1=35
...    LNCEL-3:threshold2InterFreqHpue=40
...    LNCEL-3:a2TimeToTriggerActWcdmaMeas=0ms
...    LNCEL-3:a2TimeToTriggerActInterFreqMeas=100ms
...    LNCEL-1/CATMCEL-0:prachRsrpThrCatM=-100
...    LNCEL-1/CATMCEL-0:prachRsrpThr1CatM=-110
...    LNCEL-1/CATMCEL-0:prachRsrpThr2CatM=-120
...    LNCEL-2/CATMCEL-0:prachRsrpThrCatM=-100
...    LNCEL-2/CATMCEL-0:prachRsrpThr1CatM=-110
...    LNCEL-2/CATMCEL-0:prachRsrpThr2CatM=-120
...    LNCEL-3/CATMCEL-0:prachRsrpThrCatM=-100
...    LNCEL-3/CATMCEL-0:prachRsrpThr1CatM=-110
...    LNCEL-3/CATMCEL-0:prachRsrpThr2CatM=-120
@{PARAMS_for_0806}
...    LNCEL-3/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-3/LNCEL_FDD-0:catMProfId=1
...    PMRNL-1:mtCatmAccessibility=15min
...    PMRNL-1:mtCatmRetainability=15min
...    PMRNL-1:mtCatmUsage=15min

@{FIX_VALIDATION_ERROR}
...    EQM-1/APEQM-1/CABINET-1/BBMOD-1:bbPoolSizeLte=extended
...    LNCEL/BBPOOLALLOC-0:bbPoolAllocMode=automatic
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:pucchArRateEvalWinLength=0
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=10 MHz

${UE_EUTRA_CAPABILITIES_CATM}    D628030300082100C1F83F07E0FFFC3062FF282008800886400C08216A7008047480003184000AEC04390A6A03AA14908000000100
# CATM FGI3,7,20 set as 1,enable ROHC
@{pm_counters_0806}
...    LNCEL-1:${ERAB_STP_RLF_ATT_IN_LTEM}=3
...    LNCEL-2:${ERAB_STP_RLF_ATT_IN_LTEM}=1
...    LNCEL-3:${ERAB_STP_RLF_ATT_IN_LTEM}=0
...    LNCEL-1:${ERAB_STP_RLF_SUCC_IN_LTEM}=3
...    LNCEL-2:${ERAB_STP_RLF_SUCC_IN_LTEM}=1
...    LNCEL-3:${ERAB_STP_RLF_SUCC_IN_LTEM}=0
...    LNCEL-1:${ERAB_STP_RLF_ATT_IN_VOLTEM}=1
...    LNCEL-2:${ERAB_STP_RLF_ATT_IN_VOLTEM}=0
...    LNCEL-3:${ERAB_STP_RLF_ATT_IN_VOLTEM}=0
...    LNCEL-1:${ERAB_STP_RLF_SUCC_IN_VOLTEM}=1
...    LNCEL-2:${ERAB_STP_RLF_SUCC_IN_VOLTEM}=0
...    LNCEL-3:${ERAB_STP_RLF_SUCC_IN_VOLTEM}=0
...    LNCEL-1:${ERAB_STP_HO_ATT_IN_LTEM}=1
...    LNCEL-2:${ERAB_STP_HO_ATT_IN_LTEM}=0
...    LNCEL-3:${ERAB_STP_HO_ATT_IN_LTEM}=3
...    LNCEL-1:${ERAB_STP_HO_SUCC_IN_LTEM}=1
...    LNCEL-2:${ERAB_STP_HO_SUCC_IN_LTEM}=0
...    LNCEL-3:${ERAB_STP_HO_SUCC_IN_LTEM}=3
...    LNCEL-1:${ERAB_STP_HO_ATT_IN_VOLTEM}=0
...    LNCEL-2:${ERAB_STP_HO_ATT_IN_VOLTEM}=0
...    LNCEL-3:${ERAB_STP_HO_ATT_IN_VOLTEM}=1
...    LNCEL-1:${ERAB_STP_HO_SUCC_IN_VOLTEM}=0
...    LNCEL-2:${ERAB_STP_HO_SUCC_IN_VOLTEM}=0
...    LNCEL-3:${ERAB_STP_HO_SUCC_IN_VOLTEM}=1
...    LNCEL-1:${ACTIVE_UE_CELL_SUM_VOLTEM}>50
...    LNCEL-1:${ACTIVE_UE_CELL_SUM_VOLTEM}<100
...    LNCEL-2:${ACTIVE_UE_CELL_SUM_VOLTEM}=0
...    LNCEL-3:${ACTIVE_UE_CELL_SUM_VOLTEM}>15
...    LNCEL-3:${ACTIVE_UE_CELL_SUM_VOLTEM}<60
...    LNCEL-1:${ACTIVE_UE_CELL_MAX_VOLTEM}=2
...    LNCEL-2:${ACTIVE_UE_CELL_MAX_VOLTEM}=0
...    LNCEL-3:${ACTIVE_UE_CELL_MAX_VOLTEM}=1
...    LNCEL-1:${UE_SESSION_TIME_ESTAB_LTEM}>60000
...    LNCEL-1:${UE_SESSION_TIME_ESTAB_LTEM}<100000
...    LNCEL-2:${UE_SESSION_TIME_ESTAB_LTEM}>20000
...    LNCEL-2:${UE_SESSION_TIME_ESTAB_LTEM}<60000
...    LNCEL-3:${UE_SESSION_TIME_ESTAB_LTEM}>20000
...    LNCEL-3:${UE_SESSION_TIME_ESTAB_LTEM}<60000
...    LNCEL-1:${DENOM_UE_SESSION_NUM_LTEM}=2
...    LNCEL-2:${DENOM_UE_SESSION_NUM_LTEM}=1
...    LNCEL-3:${DENOM_UE_SESSION_NUM_LTEM}=1
${ERAB_STP_RLF_ATT_IN_LTEM}    M8100C60
${ERAB_STP_RLF_SUCC_IN_LTEM}    M8100C61
${ERAB_STP_RLF_ATT_IN_VOLTEM}    M8100C62
${ERAB_STP_RLF_SUCC_IN_VOLTEM}    M8100C63
${ERAB_STP_HO_ATT_IN_LTEM}    M8100C64
${ERAB_STP_HO_SUCC_IN_LTEM}    M8100C65
${ERAB_STP_HO_ATT_IN_VOLTEM}    M8100C66
${ERAB_STP_HO_SUCC_IN_VOLTEM}    M8100C67
${ACTIVE_UE_CELL_SUM_VOLTEM}    M8101C36
${ACTIVE_UE_CELL_MAX_VOLTEM}    M8101C37
${UE_SESSION_TIME_ESTAB_LTEM}    M8101C38
${DENOM_UE_SESSION_NUM_LTEM}    M8101C39

*** Test Cases ***
LTE5072-A-a_ET_08_06_CatM UE RCR to target Cell in target eNB and X2 HO
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT    owner-Chenghong.li
    clear counter files
    Delta Commission Parameters    ${PARAMS_for_0806}
    Cat-M UE9-12 attach to eNB2 cell1 OK and UE9 UE12 setup QCI1 and QCI5 bearers successful
    UE9 RCR to eNB1 Cell1 successful
    UE10 Re-establishment to eNB1 cell2 OK during HO to eNB1 cell2 failed with cause HO failure
    UE11 Handover to eNB1 cell1 OK
    Setup QCI5 and QCI1 bearers for UE11 OK
    UE12 Handover to eNB1 cell3 OK
    Detach all UEs and Check Counters_0806

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace_sim on mme=1 enb=1 uec=1 protocol=x2,s1,rrc on
    Execute Egate Command    enb_param id=2 on_rlf_indication=rlf_triggered_ho_ignore_next_rlf_indications
    Execute Egate Command    enb_param id=2 sib1_br_period=1000 sib2_br_period=1000
    Create UE Alias    alias=UE_9    ue_id=9    id_type=cus
    Create UE Alias    alias=UE_10    ue_id=10    id_type=cus
    Create UE Alias    alias=UE_11    ue_id=11    id_type=cus
    Create UE Alias    alias=UE_12    ue_id=12    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}

    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, pdn: 1, preprovisioned: on, filter: 1, precedence: 1, priority: 1}
    ...      - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...      - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...      - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...      - {qci: 5, pdn: 1, preprovisioned: on, filter: 2, precedence: 2}
    ...      - {qci: 6, pdn: 1}
    ...      - {qci: 7, pdn: 1}
    ...      - {qci: 9, pdn: 1}
    ...      - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...      - {qci: 6, pdn: 2}
    ...      - {qci: 7, pdn: 2}
    ...      - {qci: 9, pdn: 2}
    Update Yaml    UEs/UE_sets/9    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/12    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/10    bearer: bearer_set_1
    Update Yaml    UEs/UE_sets/11    bearer: bearer_set_1

Cat-M UE9-12 attach to eNB2 cell1 OK and UE9 UE12 setup QCI1 and QCI5 bearers successful
    Execute Egate Command    enb_cell_param enb=2 scheduling_info_sib1_br=1
    Execute Egate Command    ue_enb_param id=9-12 ue_config_release_r9=rel13
    Execute Egate Command    ue_enb_param id=9-12 overwrite_ue_config_release_r9=yes
    ${QCI_8_1_5}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains ( qCI eq 8, qCI eq 1, qCI eq 5 )
    ...    and
    ...    length(E-RABToBeSetupListCtxtSUReq) eq 3
    ${QCI_8}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains ( qCI eq 8 )
    ...    and
    ...    length(E-RABToBeSetupListCtxtSUReq) eq 1
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${QCI_8_1_5})
    ...    alias=UE9    overall_timeout=20
    Execute Uex Command    ue_attach id=9 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} cell=21
    Flow Occurred As Expected    alias=UE9
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${QCI_8})
    ...    alias=UE10    overall_timeout=20
    Execute Uex Command    ue_attach id=10 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} cell=21
    Flow Occurred As Expected    alias=UE10
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${QCI_8})
    ...    alias=UE11    overall_timeout=20
    Execute Uex Command    ue_attach id=11 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} cell=21
    Flow Occurred As Expected    alias=UE11
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${QCI_8_1_5})
    ...    alias=UE12    overall_timeout=20
    Execute Uex Command    ue_attach id=12 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} cell=21
    Flow Occurred As Expected    alias=UE12
    execute uex command    trf_data_start ue=9-12 dir=dl protocol=udp kbps=10 trf_id=1

UE9 RCR to eNB1 Cell1 successful
    Expect Message Flow
    ...    UE_9:RRC_RRCConnectionReestablishmentRequest (reestablishmentCause eq "otherFailure")
    ...    UE_9:RRC_RRCConnectionReestablishmentComplete
    ...    alias=UE9_RCR    overall_timeout=20
    Execute Uex Command    ue_rrc_reestablish id=9 cell=1 enb=1 cause=otherFailure
    Flow Occurred As Expected    alias=UE9_RCR

UE10 Re-establishment to eNB1 cell2 OK during HO to eNB1 cell2 failed with cause HO failure
    Expect Message Flow
    ...    UE_10:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 2))
    ...    UE_10:RRC_RRCConnectionReestablishmentRequest (reestablishmentCause eq "handoverFailure")
    ...    UE_10:RRC_RRCConnectionReestablishmentComplete
    ...    alias=UE10_RCR    overall_timeout=20
    Execute Uex Command    ue_rrc_reconf_param id=10 if_contains=mobilityControlInfo action=reestablish cause=handoverFailure cell=2 nth=1
    execute uex command and expect error    ue_ho id=10 enb=1 cell=2    sErrTransactionInProgress
    Flow Occurred As Expected    alias=UE10_RCR

UE11 Handover to eNB1 cell1 OK
    Expect Message Flow
    ...    UE_11:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 1))
    ...    UE_11:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE11_HO    overall_timeout=20
    Execute Uex Command    ue_ho id=11 enb=1 cell=1
    Flow Occurred As Expected    alias=UE11_HO

Setup QCI5 and QCI1 bearers for UE11 OK
    Execute Uex Command    bearer_add ue=11 qci=5
    Execute Uex Command    bearer_add ue=11 qci=1 gbr_ul=25 gbr_dl=25 mbr_ul=25 mbr_dl=25

UE12 Handover to eNB1 cell3 OK
    Expect Message Flow
    ...    UE_12:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 3))
    ...    UE_12:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE12_HO    overall_timeout=20
    Execute Uex Command    ue_ho id=12 enb=1 cell=3
    Flow Occurred As Expected    alias=UE12_HO

Detach all UEs and Check Counters_0806
    sleep    35s    #waiting for counters number increasing
    Release All UEs
    Check Counters    ${pm_counters_0806}

