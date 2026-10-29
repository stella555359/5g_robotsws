*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-CN3ET    owner-lishuo.geng    owner-xu.wang    release-SBTS20C
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{LTE5140}
...    @{LTE5661}
...    @{intra_HO_para}
@{PARAMS_FOR_CATM}
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-2/LNCEL_FDD-0:catMProfId=1
...    LNCEL-3/LNCEL_FDD-0:catMProfId=1
...    LNCEL-1/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-2/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-3/LNCEL_FDD-0:catMBProfId=1
...    LNBTS-1/CATMPR-1:pagAreaScopeCheckCatM=true
...    LNCEL-1/CATMCEL-0:startingCovLevelPagingOptCatM=Coverage Level 0
...    LNCEL-2/CATMCEL-0:startingCovLevelPagingOptCatM=Coverage Level 0
...    LNCEL-3/CATMCEL-0:startingCovLevelPagingOptCatM=Coverage Level 0
...    LNCEL-1/CATMCEL-0:prachRsrpThrCatM=-100
...    LNCEL-2/CATMCEL-0:prachRsrpThrCatM=-100
...    LNCEL-3/CATMCEL-0:prachRsrpThrCatM=-100
...    LNBTS-1/CATMPR-1:mpdcchMaxNumRepPagCatM=n64
...    LNCEL-1:addSpectrEmi=1
...    LNCEL-2:addSpectrEmi=1
...    LNCEL-3:addSpectrEmi=1
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-2/LNCEL_FDD-0:actCatM=true
...    LNCEL-3/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/CATMCEL-0:numCELevelCatM=2
...    LNCEL-2/CATMCEL-0:numCELevelCatM=2
...    LNCEL-3/CATMCEL-0:numCELevelCatM=2
...    LNCEL-1/CATMCEL-0:actDlPciBasedNarBandCatM=true
...    LNCEL-2/CATMCEL-0:actDlPciBasedNarBandCatM=true
...    LNCEL-3/CATMCEL-0:actDlPciBasedNarBandCatM=true
...    delete:LNBTS-1/PSGRP-1
...    delete:LNCEL-1/CATMCEL-0:threshServingLowQR9CatM
...    delete:LNCEL-2/CATMCEL-0:threshServingLowQR9CatM
...    delete:LNCEL-3/CATMCEL-0:threshServingLowQR9CatM
...    LNCEL-1/SIB-0:threshServingLowQR9=0
...    LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNCEL-2/SIB-0:threshServingLowQR9=0
...    LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNCEL-3/SIB-0:threshServingLowQR9=0
...    LNCEL-3/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNBTS-1/CATMPR-1:inactivityTimerCatM=60
...    delete:LNCEL-1/CATMCEL-0:acbPlmnNumStepsCatM
...    delete:LNCEL-2/CATMCEL-0:acbPlmnNumStepsCatM
...    delete:LNCEL-3/CATMCEL-0:acbPlmnNumStepsCatM
@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-1:tac=33
...    LNCEL-2:tac=33
...    LNCEL-3:tac=33
...    LNCEL-1:dlsDciCch=DCI format 1A
...    LNCEL-2:dlsDciCch=DCI format 1A
...    LNCEL-3:dlsDciCch=DCI format 1A
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/SIB-0:siWindowLen=20ms
...    LNCEL-2/SIB-0:siWindowLen=20ms
...    LNCEL-3/SIB-0:siWindowLen=20ms
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-3/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-1/LNCEL_FDD-0:blankedPucch=0
...    LNCEL-2/LNCEL_FDD-0:blankedPucch=0
...    LNCEL-3/LNCEL_FDD-0:blankedPucch=0
...    LNCEL-1/LNCEL_FDD-0:selectOuterPuschRegion=None
...    LNCEL-2/LNCEL_FDD-0:selectOuterPuschRegion=None
...    LNCEL-3/LNCEL_FDD-0:selectOuterPuschRegion=None
...    LNCEL-1/LNCEL_FDD-0:actPuschMask=false
...    LNCEL-2/LNCEL_FDD-0:actPuschMask=false
...    LNCEL-3/LNCEL_FDD-0:actPuschMask=false
...    LNCEL-1/LNCEL_FDD-0:actUlMultiCluster=false
...    LNCEL-2/LNCEL_FDD-0:actUlMultiCluster=false
...    LNCEL-3/LNCEL_FDD-0:actUlMultiCluster=false
...    LNBTS-1:actULCAggr=false
...    LNCEL-1/LNCEL_FDD-0:actRedFreqOffset=false
...    LNCEL-2/LNCEL_FDD-0:actRedFreqOffset=false
...    LNCEL-3/LNCEL_FDD-0:actRedFreqOffset=false
...    LNCEL-1/LNCEL_FDD-0:actSuperCell=false
...    LNCEL-2/LNCEL_FDD-0:actSuperCell=false
...    LNCEL-3/LNCEL_FDD-0:actSuperCell=false
...    LNCEL-1/LNCEL_FDD-0:actLiquidCell=false
...    LNCEL-2/LNCEL_FDD-0:actLiquidCell=false
...    LNCEL-3/LNCEL_FDD-0:actLiquidCell=false
...    LNCEL-1/LNCEL_FDD-0:actCombSuperCell=false
...    LNCEL-2/LNCEL_FDD-0:actCombSuperCell=false
...    LNCEL-3/LNCEL_FDD-0:actCombSuperCell=false
...    LNBTS-1/LNBTS_FDD-0:actProSeComm=false
...    LNCEL-1:nbIoTMode=disabled
...    LNCEL-2:nbIoTMode=disabled
...    LNCEL-3:nbIoTMode=disabled
...    LNCEL-1/LNCEL_FDD-0:actUlPwrRestrScn=none
...    LNCEL-2/LNCEL_FDD-0:actUlPwrRestrScn=none
...    LNCEL-3/LNCEL_FDD-0:actUlPwrRestrScn=none
...    LNCEL-1:phyCellId=1
...    LNCEL-2:phyCellId=2
...    LNCEL-3:phyCellId=3
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19450
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1450
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1400
@{intra_HO_para}
...    LNBTS-1/MODPR-0:autoAdapt=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1:actRLFbasedRCR=true
...    LNBTS-1:rlfBasedRCRdefault=true
...    LNBTS-1/LNADJ-1:rlfBasedRCRsupported=true
...    LNBTS-1:actRLFbasedRCREnhancedIntra=true
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1450
...    LNCEL-2/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-1:ecgiLcrId=1
...    LNCEL-2/LNREL-1:handoverAllowed=allowed
...    LNCEL-2/LNREL-1:removeAllowed=false
...    LNCEL-2/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=3
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-1/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNCEL-1/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-1/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL-2/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNCEL-2/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-2/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL-3/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNCEL-3/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-3/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL-1:t301Guard=100
...    LNCEL-2:t301Guard=100
...    LNCEL-3:t301Guard=100
@{LTE5140}
...    LNCEL-1/CATMCEL-0:numNarBandModeACatM=2
...    LNCEL-1/CATMCEL-0:loadWeightCL1CatM=10
...    LNCEL-1/CATMCEL-0:loadMetricScalePrimNBCL1CatM=10
...    LNCEL-1/CATMCEL-0:loadMetricScaleAddiNBCatM=10
...    LNCEL-1/CATMCEL-0:loadMetricOffsetAddiNBCatM=0
...    LNCEL-2/CATMCEL-0:numNarBandModeACatM=2
...    LNCEL-3/CATMCEL-0:numNarBandModeACatM=2
...    LNCEL-2/CATMCEL-0:loadWeightCL1CatM=10
...    LNCEL-2/CATMCEL-0:loadMetricScalePrimNBCL1CatM=10
...    LNCEL-2/CATMCEL-0:loadMetricScaleAddiNBCatM=10
...    LNCEL-2/CATMCEL-0:loadMetricOffsetAddiNBCatM=0
...    LNCEL-3/CATMCEL-0:loadWeightCL1CatM=10
...    LNCEL-3/CATMCEL-0:loadMetricScalePrimNBCL1CatM=10
...    LNCEL-3/CATMCEL-0:loadMetricScaleAddiNBCatM=10
...    LNCEL-3/CATMCEL-0:loadMetricOffsetAddiNBCatM=0
@{LTE5661}
...    LNCEL-1/CATMCEL-0:actLoadbasedNBSelectionCatM=true
...    LNCEL-1/CATMCEL-0:loadBasedNBSelThresCatM=20
...    LNBTS-1/CATMPR-1:dlTargetBlerModeACatM=10
...    LNBTS-1/CATMPR-1:ulTargetBlerModeACatM=10
...    LNCEL-2/CATMCEL-0:actLoadbasedNBSelectionCatM=true
...    LNCEL-2/CATMCEL-0:loadBasedNBSelThresCatM=20
...    LNCEL-3/CATMCEL-0:actLoadbasedNBSelectionCatM=true
...    LNCEL-3/CATMCEL-0:loadBasedNBSelThresCatM=20
@{LTE5661_for_case1}
...    LNCEL-1/CATMCEL-0:actLoadbasedNBSelectionCatM=true
...    LNCEL-1/CATMCEL-0:loadBasedNBSelThresCatM=40
${LTE5661_disable}    LNCEL-1/CATMCEL-0:actLoadbasedNBSelectionCatM=false
@{secondary_narrowband_parameters_for_cell_1}
...  LNCEL-1/CATMCEL-0:addiPdschNarBandNumCatM=2
...  LNCEL-1/CATMCEL-0:addiMpdcchNarBandNumCatM=2
...  LNCEL-1/CATMCEL-0:addiPuschNarBandNumCatM=5
@{primary_narrowband_parameters_for_cell_1}
...  LNCEL-1/CATMCEL-0:pdschNarBandNumCatM=0
...  LNCEL-1/CATMCEL-0:mpdcchNarBandNumCatM=0
...  LNCEL-1/CATMCEL-0:siNarBandNumCatM=0
...  LNCEL-1/CATMCEL-0:puschNarBandNumCatM=6
...  LNCEL-1/CATMCEL-0:pagPdschNarBandNumCatM=1
${UE_EUTRA_CAPABILITIES_CATM}
...    d62803060008210308990C1BF86FE1BF86FE1BF86FE1BFFF860C5FE50401100110C80181042D4E01008E9000063080015D8087214D40D5550A48400000008000
# CATM FGI3,7,20 set as 1,enable ROHC
${factor_DL_main_NB_overhead}    0XF008A
@{PARAMS_IN_SWCONFIG}
...    ${factor_DL_main_NB_overhead} = 10
${PM_COUNTER_INTERVAL}    1min
${MAX_RRC_CONN_UE_2NB_LTEM}    M8104C48
${MAX_RRC_CONN_UE_LTEM}    M8104C47
@{Rtpm_counters_case1}
...    last LNCEL-1:Cat_M_Usage:${MAX_RRC_CONN_UE_LTEM}=8
...    last LNCEL-1:Cat_M_Usage:${MAX_RRC_CONN_UE_2NB_LTEM}=4

*** Test Cases ***
LTE5661-A-a_ET_01_01_Feature migration acitive deactive
    [Tags]    CDRT
    Start Rtpm Counter
    online change LTE5661 Disable
    Cat-M CEleveL-0 UE1-2 attach to cell1 success and assigned in the primary and secondary NB Then Start Traffic With LTE5661 Disabled
    Active LTE5661 Feature For Case1
    Cat-M CEleveL-0 UE3-8 attach to cell1 success and assigned in the primary and secondary NB Then Start Traffic
    Check Rtpm Counters    ${Rtpm_counters_case1}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace_sim on mme=1 enb=1 uec=1 protocol=x2,s1,rrc on
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=8    id_type=cus

Cat-M CEleveL-0 UE3-8 attach to cell1 success and assigned in the primary and secondary NB Then Start Traffic
    UE Attach And Start Traffic And Check NB In The Primary On Cell    ue_id=3    cell_id=1
    UE Attach And Start Traffic And Check NB In The Primary On Cell    ue_id=4    cell_id=1
    UE Attach And Start Traffic And Check NB In The Primary On Cell    ue_id=5    cell_id=1
    UE Attach And Start Traffic And Check NB In The Secondary On Cell    ue_id=6    cell_id=1
    UE Attach And Start Traffic And Check NB In The Secondary On Cell    ue_id=7    cell_id=1
    UE Attach And Start Traffic And Check NB In The Secondary On Cell    ue_id=8    cell_id=1

UE Attach And Start Traffic And Check NB In The Primary On Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionSetup ( mpdcch-Narrowband-r13 eq 1)
    ...    alias=UE_${ue_id}    overall_timeout=20
    Run Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} enb=1 cell=${cell_id}
    Flow Occurred As Expected    alias=UE_${ue_id}
    check cell primary narrowband_parameters    cell_id=${cell_id}
    Run Uex Command    bearer_add ue=${ue_id} qci=7
    Run Uex Command    trf_data_start ue=${ue_id} qci=7 dir=dl protocol=udp kbps=100

UE Attach And Start Traffic And Check NB In The Secondary On Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionSetup ( mpdcch-Narrowband-r13 eq 3)
    ...    alias=UE_${ue_id}    overall_timeout=20
    Run Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} enb=1 cell=${cell_id}
    Flow Occurred As Expected    alias=UE_${ue_id}
    check cell secondary narrowband_parameters    cell_id=${cell_id}
    Run Uex Command    bearer_add ue=${ue_id} qci=7
    Run Uex Command    trf_data_start ue=${ue_id} qci=7 dir=dl protocol=udp kbps=100

Cat-M CEleveL-0 UE1-2 attach to cell1 success and assigned in the primary and secondary NB Then Start Traffic With LTE5661 Disabled
    UE Attach And Start Traffic And Check NB In The Secondary On Cell    ue_id=1    cell_id=1
    UE Attach And Start Traffic And Check NB In The Primary On Cell    ue_id=2    cell_id=1

check cell secondary narrowband_parameters
    [Arguments]    ${cell_id}
    Object should Exist    ${secondary_narrowband_parameters_for_cell_${cell_id}}

check cell primary narrowband_parameters
    [Arguments]    ${cell_id}
    Object should Exist    ${primary_narrowband_parameters_for_cell_${cell_id}}

Active LTE5661 Feature For Case1
    Delta Commission Parameters    ${LTE5661_for_case1}

online change LTE5661 Disable
    Delta Commission Parameters    ${LTE5661_disable}

