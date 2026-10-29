*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    release-xL19A    DEVHZ5_FT2    owner-xiuli.song    owner-eric.jiang
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
...    @{PARAMS_FOR_LTE5138}
@{PARAMS_FOR_CATM}
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-2/LNCEL_FDD-0:actCatM=true
...    LNCEL-3/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/CATMCEL-0:numCELevelCatM=2
...    LNCEL-2/CATMCEL-0:numCELevelCatM=2
...    LNCEL-3/CATMCEL-0:numCELevelCatM=2
...    LNCEL-1/CATMCEL-0:threshold2CatM=42
...    LNCEL-1/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-1/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL-1/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNCEL-2/CATMCEL-0:threshold2CatM=42
...    LNCEL-2/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-2/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL-2/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNCEL-3/CATMCEL-0:threshold2CatM=42
...    LNCEL-3/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-3/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL-3/CATMCEL-0:actRLFbasedRCRCatM=true
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
...    LNCEL-1:dlsDciCch=DCI format 1A
...    LNCEL-2:dlsDciCch=DCI format 1A
...    LNCEL-3:dlsDciCch=DCI format 1A
...    LNBTS/CATMPR-1:cpInactivityTimerCatM=60
...    LNBTS/CATMPR-1:srbInactivityTimerCatM=60
...    LNBTS/CATMPR-1:inactivityTimerCatM=170
...    LNBTS/CATMPR-1:raPreGrCSizeCatM=5
@{PARAMS_FOR_NormalUE}
...    LNCEL-1:inactivityTimer=170
...    LNCEL-1:inactivityTimerQci5Sign=100
...    LNCEL-1:qci1ProtectionTimer=180
...    LNCEL-2:inactivityTimer=170
...    LNCEL-2:inactivityTimerQci5Sign=100
...    LNCEL-2:qci1ProtectionTimer=180
...    LNCEL-3:inactivityTimer=170
...    LNCEL-3:inactivityTimerQci5Sign=100
...    LNCEL-3:qci1ProtectionTimer=180
...    LNBTS:qciTab5:schedulType=SIGNALLING
...    LNBTS:qciTab5:lcgid=0
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNBTS:actRrcConnNoActivity=true
...    LNBTS:actBbPooling=true
...    LNBTS:bbPoolMinResource=1
...    LNBTS:bbPoolEvalPeriod=20
...    LNCEL-1/BBPOOLALLOC:bbPoolTargetId=1
...    LNCEL-1/BBPOOLALLOC:bbPoolAllocMode=manual
...    LNCEL-1/BBPOOLALLOC:bbPoolLogicalGroupId=1
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...    LNBTS:actEnhAcAndGbrServices=true
...    LNCEL-2/BBPOOLALLOC:bbPoolTargetId=1
...    LNCEL-2/BBPOOLALLOC:bbPoolAllocMode=manual
...    LNCEL-2/BBPOOLALLOC:bbPoolLogicalGroupId=1
...    LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...    LNBTS/CATMPR-1:raPreGrCSizeCatM=5
...    LNCEL-3/BBPOOLALLOC:bbPoolTargetId=1
...    LNCEL-3/BBPOOLALLOC:bbPoolAllocMode=manual
...    LNCEL-3/BBPOOLALLOC:bbPoolLogicalGroupId=1
...    LNCEL-3/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
@{PARAMS_FOR_CATM_Volte}
...    LNCEL-1/CATMCEL-0:actConvVoiceCatM=true
...    LNCEL-2/CATMCEL-0:actConvVoiceCatM=true
...    LNCEL-3/CATMCEL-0:actConvVoiceCatM=true
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
...    LNCEL-1:t301Guard=100
...    LNCEL-2:t301Guard=100
...    LNCEL-3:t301Guard=100
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
@{PARAMS_FOR_LTE5138}
...    LNBTS/CATMPR-1:catMVoLTETab:mpucchMaxNumRepQci1CatM=r2
...    LNBTS/CATMPR-1:pucchF1NumRepModeACatM=r4
...    LNBTS/CATMPR-1:catMCELevel1:pucchF1NumRepModeACatM=r4
...    LNBTS/CATMBPR-1:catMCELevel2:pucchF1NumRepModeBCatM=r8
...    LNBTS/CATMBPR-1:catMCELevel3:pucchF1NumRepModeBCatM=r8
...    LNBTS/CATMPR-2:catMVoLTETab:mpucchMaxNumRepQci1CatM=r1
...    LNBTS/CATMPR-2:pucchF1NumRepModeACatM=r2
...    LNBTS/CATMPR-2:catMCELevel1:pucchF1NumRepModeACatM=r4
...    LNBTS/CATMBPR-2:catMCELevel2:pucchF1NumRepModeBCatM=r4
...    LNBTS/CATMBPR-2:catMCELevel3:pucchF1NumRepModeBCatM=r4
...    LNCEL-1/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-2/LNCEL_FDD-0:catMBProfId=2
...    LNCEL-3/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-2/LNCEL_FDD-0:catMProfId=2
...    LNCEL-3/LNCEL_FDD-0:catMProfId=1
${UE_EUTRA_CAPABILITIES_CATM}    D628030300082100C1F83F07E0FFFC3062FF282008800886400C08216A7008047480003184000AEC04390A6A03AA14908000000100
${UE_EUTRA_CAPABILITIES}    CA1FF43A33E6CB0007FFFFFFFC008006217FFFFFFF80

*** Test Cases ***
LTE5138-C-c_01-01_CatM UE HO to target cell with different PUCCH rep_mpucchMaxNumRepQci1CatM Greater than pucchF1NumRepModeACatM
    [Tags]
    Cat-M CE level0 UE1 attached to cell1 and setup QCI1 bearer with cause mo-Signalling to check pucch-NumRepetitionCE
    Cat-M CE level1 UE2 attached to cell1 and setup QCI1 bearer with cause emergency to check pucch-NumRepetitionCE
    Cat-M UE1-2 HO to cell2 with 1 PUCCH repetitions for VoLTE call to check eNB should use target cell's PUCCH repetitions
    Release QCI1 bearer of CAT-M UE1-2 to check pucch-NumRepetitionCE
    #All UEs detach

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=10
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=2    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'emergency.nsn.com'
    ...    emergency: 'on'
    Add Yaml    UEs/bearer_sets/bearer_set_2
    ...    - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...    - {qci: 1, preprovisioned: on, default: off, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, priority: 1, filter: 3, precedence: 3, pdn: 1}
    ...    - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...    - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...    - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...    - {qci: 5, preprovisioned: on, default: off, filter: 5, precedence: 5, pdn: 1}
    ...    - {qci: 6, pdn: 1}
    ...    - {qci: 7, pdn: 1}
    ...    - {qci: 9, pdn: 1}
    ...    - {qci: 5, default: on, priority: 1, trf_type: external, pdn: 3}
    ...    - {qci: 1, preprovisioned: on, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, priority: 1, filter: 1, precedence: 1, pdn: 3}
    Add Yaml    UEs/bearer_sets/bearer_set_3
    ...    - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...    - {qci: 1, preprovisioned: on, default: off, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, priority: 1, filter: 3, precedence: 3, pdn: 1}
    ...    - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...    - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...    - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...    - {qci: 5, preprovisioned: on, default: off, filter: 5, precedence: 5, pdn: 1}
    ...    - {qci: 6, pdn: 1}
    ...    - {qci: 7, pdn: 1}
    ...    - {qci: 9, pdn: 1}
    ...    - {qci: 5, default: on, priority: 1, trf_type: external, pdn: 3}
    ...    - {qci: 1, preprovisioned: on, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, priority: 1, filter: 1, precedence: 1, pdn: 3}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_3

Cat-M CE level0 UE1 attached to cell1 and setup QCI1 bearer with cause mo-Signalling to check pucch-NumRepetitionCE
    ${message_1}=    catenate
    ...    S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 8, e-RAB-ID eq 6 and qCI eq 1, e-RAB-ID eq 7 and qCI eq 5))
    ${message_2}=    catenate
    ...    RRC_RRCConnectionSetup (pucch-ConfigDedicated-r13 contains (pucch-NumRepetitionCE-r13 contains (
    ...    setup contains (modeA contains (pucch-NumRepetitionCE-format1-r13 eq "r4" and
    ...    pucch-NumRepetitionCE-format2-r13 eq "r1")))))
    ${message_3}=    catenate
    ...    RRC_RRCConnectionReconfiguration (pucch-ConfigDedicated-r13 contains (pucch-NumRepetitionCE-r13 contains (
    ...    setup contains (modeA contains (pucch-NumRepetitionCE-format1-r13 eq "r2" and
    ...    pucch-NumRepetitionCE-format2-r13 eq "r1")))))
    Expect Message Flow
    ...    UE_GROUP_1:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "mo-Signalling"))
    ...    MME_1:${message_1}
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    UE_GROUP_1:${message_2}
    ...    UE_GROUP_1:${message_3}
    ...    alias=UE1_Attach_Flow    overall_timeout=20
    Execute Egate Command    ue_change_location id=1 enb=1 cell=1
    Execute Uex Command    ue_attach id=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} enb=1 cell=1    # CE Level 0 UE1 attach
    Sleep    5
    Flow Occurred As Expected    alias=UE1_Attach_Flow
    Execute Uex Command    trf_data_start ue=1 qci=1 kbps=32 dir=dl protocol=udp

Cat-M CE level1 UE2 attached to cell1 and setup QCI1 bearer with cause emergency to check pucch-NumRepetitionCE
    ${message_1}=    catenate
    ...    S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 8, e-RAB-ID eq 6 and qCI eq 1, e-RAB-ID eq 7 and qCI eq 5))
    ${message_2}=    catenate
    ...    RRC_RRCConnectionSetup (pucch-ConfigDedicated-r13 contains (pucch-NumRepetitionCE-r13 contains (
    ...    setup contains (modeA contains (pucch-NumRepetitionCE-format1-r13 eq "r4" and
    ...    pucch-NumRepetitionCE-format2-r13 eq "r1")))))
    ${message_3}=    catenate
    ...    RRC_RRCConnectionReconfiguration (pucch-ConfigDedicated-r13 contains (pucch-NumRepetitionCE-r13 contains (
    ...    setup contains (modeA contains (pucch-NumRepetitionCE-format1-r13 eq "r2" and
    ...    pucch-NumRepetitionCE-format2-r13 eq "r1")))))
    Expect Message Flow
    ...    UE_GROUP_2:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "emergency"))
    ...    MME_1:${message_1}
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    UE_GROUP_2:${message_2}
    ...    UE_GROUP_2:${message_3}
    ...    alias=UE2_Attach_Flow    overall_timeout=20
    Execute Egate Command    ue_change_location id=2 enb=1 cell=1
    Execute Uex Command    ue_ul_power_control id=2 pathloss=115
    Execute Uex Command    ue_attach id=2 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} establishment_cause=emergency enb=1 cell=1
    Sleep    5
    Flow Occurred As Expected    alias=UE2_Attach_Flow
    Execute Uex Command     trf_data_start ue=2 qci=1 kbps=32 dir=dl protocol=udp

Cat-M UE1-2 HO to cell2 with 1 PUCCH repetitions for VoLTE call to check eNB should use target cell's PUCCH repetitions
    ${message_1}=    catenate
    ...    RRC_RRCConnectionReconfiguration (pucch-ConfigDedicated-r13 contains (pucch-NumRepetitionCE-r13 contains (
    ...    setup contains (modeA contains (pucch-NumRepetitionCE-format1-r13 eq "r1" and
    ...    pucch-NumRepetitionCE-format2-r13 eq "r1")))))
    Expect Message Flow
    ...    UE_GROUP_1:${message_1}
    ...    alias=UE1_HO_Flow    overall_timeout=20
    Expect Message Flow
    ...    UE_GROUP_2:${message_1}
    ...    alias=UE2_HO_Flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=1 event=A2 srsrp=15 srsrq=15
	Sleep    1
    Execute Uex Command    ue_measurement_send id=1 event=A3 nrsrp=97 srsrp=15 nrsrq=34 srsrq=15 phycell_id=2
    Flow Occurred As Expected    alias=UE1_HO_Flow
    Sleep    2
    Execute Uex Command    ue_measurement_send id=2 event=A2 srsrp=15 srsrq=15
	Sleep    2
    Execute Uex Command    ue_measurement_send id=2 event=A3 nrsrp=97 srsrp=15 nrsrq=34 srsrq=15 phycell_id=2
    Flow Occurred As Expected    alias=UE2_HO_Flow

Release QCI1 bearer of CAT-M UE1-2 to check pucch-NumRepetitionCE
    ${message_1}=    catenate
    ...    S1AP_E-RABReleaseCommand (E-RABList contains (e-RAB-ID eq 6))
    ${message_2}=    catenate
    ...    RRC_RRCConnectionReconfiguration (pucch-ConfigDedicated-r13 contains (pucch-NumRepetitionCE-r13 contains (
    ...    setup contains (modeA contains (pucch-NumRepetitionCE-format1-r13 eq "r4" and
    ...    pucch-NumRepetitionCE-format2-r13 eq "r1")))))
    Expect Message Flow
    ...    MME_1:${message_1}
    ...    UE_GROUP_1:${message_2}
    ...    alias=UE1_ReleaseQCI1_Flow    overall_timeout=20
    Expect Message Flow
    ...    MME_1:${message_1}
    ...    UE_GROUP_2:${message_2}
    ...    alias=UE2_ReleaseQCI1_Flow    overall_timeout=20
    Execute Uex Command    bearer_del ue=1 qci=1
    Flow Occurred As Expected    alias=UE1_ReleaseQCI1_Flow
    Sleep    5
    Execute Uex Command    bearer_del ue=2 qci=1
    Flow Occurred As Expected    alias=UE2_ReleaseQCI1_Flow

All UEs detach
    Execute Uex Command    ue_detach id=1
    Sleep    1
    Execute Uex Command    ue_detach id=2
