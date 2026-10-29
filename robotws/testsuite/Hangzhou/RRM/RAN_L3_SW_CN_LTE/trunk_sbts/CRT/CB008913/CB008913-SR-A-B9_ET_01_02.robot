*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS
...                 release-SBTS24R1    team-CN3ET    owner-lishuo.geng
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}    LNBTS:reportTimerEndcA5=5000ms
@{PARAMS_IN_SCF}
...    @{LTE4088}
...    @{LTE4193}
...    @{NRDCPR}
...    @{CA}
...    @{LTE4549}
...    @{NRDCDPR}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{Disable_CRL31168}
...    @{ENDC_HO}
...    @{CB008218}
...    @{CB008913}
...    @{X2_MOCs}

#LTE5150 counter:
${ENDC_CAP_HO_PREP_cell1}    LNCEL-1:M8080C53
${ENDC_CAP_HO_EXE_ATT_cell1}    LNCEL-1:M8080C54
${ENDC_CAP_HO_EXE_SUCC_cell1}    LNCEL-1:M8080C55
${ENDC_CAP_HO_PREP_cell3}    LNCEL-3:M8080C53
${ENDC_CAP_HO_EXE_ATT_cell3}    LNCEL-3:M8080C54
${ENDC_CAP_HO_EXE_SUCC_cell3}    LNCEL-3:M8080C55

#CB007163 counter:
${ENDC_CAP_HO_EXE_PREF_ATT_cell1}    LNCEL-1:M8080C156
${ENDC_CAP_HO_EXE_PREF_SUCC_cell1}    LNCEL-1:M8080C155
${ENDC_CAP_HO_EXE_PREF_ATT_cell3}    LNCEL-3:M8080C156
${ENDC_CAP_HO_EXE_PREF_SUCC_cell3}    LNCEL-3:M8080C155

#CB008913 counter:
${B1_NR_ENDC_HO_PREP_cell1}    LNCEL-1:M8080C168
${B1_NR_ENDC_HO_EXE_ATT_cell1}    LNCEL-1:M8080C169
${B1_NR_ENDC_HO_EXE_SUC_cell1}    LNCEL-1:M8080C170
${B1_NR_ENDC_HO_PREP_cell3}    LNCEL-3:M8080C168
${B1_NR_ENDC_HO_EXE_ATT_cell3}    LNCEL-3:M8080C169
${B1_NR_ENDC_HO_EXE_SUC_cell3}    LNCEL-3:M8080C170

@{CB006607_ENDC_HO_counter_check_for_cell_1}
...      ${ENDC_CAP_HO_PREP_cell1}=1
...      ${ENDC_CAP_HO_EXE_ATT_cell1}=1
...      ${ENDC_CAP_HO_EXE_SUCC_cell1}=1

...      ${ENDC_CAP_HO_EXE_PREF_ATT_cell1}=0
...      ${ENDC_CAP_HO_EXE_PREF_SUCC_cell1}=0

...      ${B1_NR_ENDC_HO_PREP_cell1}=0
...      ${B1_NR_ENDC_HO_EXE_ATT_cell1}=0
...      ${B1_NR_ENDC_HO_EXE_SUC_cell1}=0

@{CB007163_prefer_ENDC_HO_counter_check_for_cell_3}
...      ${ENDC_CAP_HO_PREP_cell3}=1
...      ${ENDC_CAP_HO_EXE_ATT_cell3}=1
...      ${ENDC_CAP_HO_EXE_SUCC_cell3}=1

...      ${ENDC_CAP_HO_EXE_PREF_ATT_cell3}=1
...      ${ENDC_CAP_HO_EXE_PREF_SUCC_cell3}=1

...      ${B1_NR_ENDC_HO_PREP_cell3}=0
...      ${B1_NR_ENDC_HO_EXE_ATT_cell3}=0
...      ${B1_NR_ENDC_HO_EXE_SUC_cell3}=0

@{CB008913_ENDC_HO_counter_check_for_cell_1}
...      ${ENDC_CAP_HO_PREP_cell1}=0
...      ${ENDC_CAP_HO_EXE_ATT_cell1}=0
...      ${ENDC_CAP_HO_EXE_SUCC_cell1}=0

...      ${ENDC_CAP_HO_EXE_PREF_ATT_cell1}=0
...      ${ENDC_CAP_HO_EXE_PREF_SUCC_cell1}=0

...      ${B1_NR_ENDC_HO_PREP_cell1}=1
...      ${B1_NR_ENDC_HO_EXE_ATT_cell1}=1
...      ${B1_NR_ENDC_HO_EXE_SUC_cell1}=1

@{CB008913_ENDC_HO_counter_check_for_cell_3}
...      ${ENDC_CAP_HO_PREP_cell3}=0
...      ${ENDC_CAP_HO_EXE_ATT_cell3}=0
...      ${ENDC_CAP_HO_EXE_SUCC_cell3}=0

...      ${ENDC_CAP_HO_EXE_PREF_ATT_cell3}=0
...      ${ENDC_CAP_HO_EXE_PREF_SUCC_cell3}=0

...      ${B1_NR_ENDC_HO_PREP_cell3}=1
...      ${B1_NR_ENDC_HO_EXE_ATT_cell3}=1
...      ${B1_NR_ENDC_HO_EXE_SUC_cell3}=1


@{CB008913_ENDC_HO_counter_check} 
...    @{CB008913_ENDC_HO_counter_check_for_cell_3}
...    @{CB008913_ENDC_HO_counter_check_for_cell_1}

@{CB006607_and_CB007163_ENDC_HO_counters_check}
...    @{CB006607_ENDC_HO_counter_check_for_cell_1}
...    @{CB007163_prefer_ENDC_HO_counter_check_for_cell_3} 

${flte1}    1400    #band3
${flte2}    1600    #band3
${flte3}    2870    #band7
${flte4}    3100    #band7

${fnr1}    188512    #nr band 8
${fnr2}    650048    #nr band 77
${fnr3}    2079200    #nr band 257

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400    #band3
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600    #band3
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2870    #band7
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20870
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3100    #band7
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21100
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:tS1eRABModInd=2000
...    LNCEL:eTputFilterConfig=51
...    LNCEL:eTputInitMcs=20
...    LNCEL:actFlowCtrlEnh=true
...    delete:LNBTS/CTRLTS-1
...    delete:LNBTS/CTRLTS-1/LTRACE-1
...    delete:LNBTS/CTRLTS-1/MTRACE-1
...    delete:LNCEL-1/MBSFNCEL-0

@{X2_MOCs}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.41    #gNB_id=7
...    LNCEL-3/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-1:nrCellId=115969    # SSBfrequency=188512 for GNB-7 cell-1
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

@{CB008913}
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO
...    LNCEL-3:actNrCovEndcHo=ENDC NR-coverage HO
...    LNBTS:blockNrEndcHoAtHoFromTrg=no blocking
...    LNBTS:numB1CyclesWoEndc=1
...    LNBTS/MODPR-0:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS:actEndcHo=enabled    #LTE5150
...    LNBTS:actUeCapEndcHo=true    #CB006607
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${flte1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte4}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${flte1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte3}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte4}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking    #no blocking
...    LNBTS-1:blockNrEndcHoAtHoFromTrg=no blocking    #EN-DC NR-coverage HO

@{delta_for_case_B9_02}
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO
...    LNCEL-3:actNrCovEndcHo=ENDC NR-coverage HO
...    LNCEL-1:actEndcHoPrefLay=false    #CB007163
...    LNCEL-3:actEndcHoPrefLay=true    #CB007163
...    LNCEL:iFEndcHoRetryTimer=20
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte1}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=257
...    delete:LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2
...    LNBTS/CAGENB-0/CAIMLBP-1:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:band=77
...    delete:LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1


@{delta_for_case_B9_01}
...    @{enabled_LTE4193}
...    @{PCMD_Setup}
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO
...    LNCEL-3:actNrCovEndcHo=ENDC NR-coverage HO
...    LNCEL-3:actEndcHoPrefLay=false    #CB007163
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=257

...    LNBTS/CAGENB-0/CAIMLBP-1:pcellConfig:earfcnDL=${flte1}
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1:nrcellConfigL:band=257


@{ENDC_HO}
...    LNBTS:actEndcHo=enabled    #LTE5150
...    LNBTS:actUeCapEndcHo=true    #CB006607
...    LNCEL:actEndcHoPrefLay=false    #CB007163
...    LNCEL:iFEndcHoRetryTimer=10
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=noRetries
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:band=257
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${flte2}
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=${flte3}
...    LNCEL-1/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-3:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=${flte4}
...    LNCEL-1/LNHOIF-3:thresholdRsrqEndcFilt=-120
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=${flte1}
...    LNCEL-2/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=${flte1}
...    LNCEL-3/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-3/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    @{add_moPrMapList}



@{add_moPrMapList}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1/MODPR-0:autoAdapt=false
...    LNBTS-1:moProfileSelect=spid
...    LNCEL-1:moPrMappingList:spid=2|moPrId=1
...    LNCEL-1:moPrMappingList:spidLast=100|moPrId=1
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=1
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=1
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=1


@{NRDCPR}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRMEASPR-0:cellList=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:quantityConfigId=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:quantityConfigId=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=${fnr1}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:nrCarPrio=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz

...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:carrierFreqNrCell=${fnr2}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:nrCarPrio=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbSubcarrierSpacing=30kHz

...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:carrierFreqNrCell=${fnr3}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=257
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:nrCarPrio=3
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbSubcarrierSpacing=30kHz

@{NRDCDPR}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=3
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:quantityConfigId=1
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${fnr1}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=8
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrCarPrio=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${fnr2}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=2
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:carrierFreqNrCell=${fnr3}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=257
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:nrCarPrio=3
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrq=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbSubcarrierSpacing=30kHz

@{CA}
...    LNBTS:actDLCAggr=true
...    LNBTS:actAdvScellMeas=true
...    LNBTS:enableBwCombCheck=true
...    LNBTS:actFlexScellSelect=true
...    LNCEL:actScellConfigForHiDemand=true
...    LNBTS/LNBTS_FDD-0:numTxWithHighNonGbr=10
...    LNBTS:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL:maxNumScells=3
...    LNCEL-2:maxNumScells=3
...    LNCEL-3:maxNumScells=3
...    LNCEL:actCaArchEnhImp=off
...    LNCEL-2:actCaArchEnhImp=off
...    LNCEL-3:actCaArchEnhImp=off
...    LNCEL:caPoolId=1
...    LNCEL:dlScellConfigLevel=10
...    LNCEL/CAPR-1:earfcnDL=1600
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNBTS/CADPR-0:maxNumMimoLayerFdd=16
...    LNBTS:actFlexCaMgmt=true
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL-2:scellFastSchedulingSelect=normal
...    LNCEL-3:scellFastSchedulingSelect=normal
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL-2:dlCaMinPcellCqiQci1=0
...    LNCEL-2:dlCaMinPcellCqi=0
...    LNCEL-3:dlCaMinPcellCqiQci1=0
...    LNCEL-3:dlCaMinPcellCqi=0

@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNBTS:qciTab6:nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS:pdcpProf1001:pdcpProfileId=1001
...    LNBTS:pdcpProf1001:snSizeDl=18bit
...    LNBTS:pdcpProf1001:snSizeUl=18bit
...    LNBTS:pdcpProf1001:statusRepReq=0
...    LNBTS:pdcpProf1001:tDiscard=300ms

@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference

@{Disable_CRL31168}
...    LNBTS/NRMEASDPR-0:mrWaitTimer=${EMPTY}    #ms
...    LNBTS/NRMEASPR-0:mrWaitTimer=${EMPTY}    #ms

@{CB008218}
...    LNCEL-1:actPeriodicB1NRMeas=enhanced
...    LNCEL-3:actPeriodicB1NRMeas=enhanced
...    LNBTS/NRMEASDPR-0:supervisionTimerB1NR=10    #s
...    LNBTS/NRMEASPR-0:supervisionTimerB1NR=10    #s
...    LNBTS/NRMEASDPR-0:retryTimerB1NR=30    #s
...    LNBTS/NRMEASPR-0:retryTimerB1NR=30    #s

@{enabled_LTE4193}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased

${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A00000001D00000000E800000007400000003A00000001
...    D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000
...    001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00
...    000001D00000001BFBFFEDA00E00886429CC20070D9000000005EE800000020254A8389D0100000E10000084000B0800004200210000
...    43000088000114000230000470000900001240002500004B000098000134000280000510000A400014C0002A0000550000AC00015C00
...    02C0000590000B400016C0002E80005E0000DA0001FC0074E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074000000
...    0282000001E740000000000000000000000000000000000000000000000000000000000040471084A681873FFFFFFFFFFFFFFE8082A0
...    006008A5C000080000412C68062600E8004EF0000006000000240000860030080601D00000

${ue_nr_capabilities}    00000000010100400004C0000038000400040160401C06000000
${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}    0108080260C01C07000E260000000098100701C003A000000000010000402020040080801002
${ue_eutra_nr_capabilities_b7+n8_b7+n77}    0108040260C01C07000E2600000000040001008080100202004008


${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '179500:188500', 
...    suggested_band: 8}

${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '650000:650000', 
...    suggested_band: 77}

${gnb7_cell3}    SEPARATOR=
...    {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x503', nr_arfcn: '2079166:2079166', 
...    suggested_band: 257}

${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18,
    ...    measId eq 19
    ...    )
    ...    and measObjectToAddModList contains (
    ...    carrierFreq-r15 eq ${fnr1},
    ...    carrierFreq-r15 eq 650048,
    ...    carrierFreq-r15 eq 2079200
    ...    )
    ...    and reportConfigToAddModList contains (
    ...    eventB1-NR-r15 contains (
    ...    reportOnLeave-r15 eq "TRUE"
    ...    ))

${ENDC_A5_for_Flte3}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 2870)
    ...    and reportConfigToAddModList contains (
    ...    a5-Threshold1 contains (
    ...    threshold-RSRP eq 97) 
    ...    and a5-Threshold2 contains (
    ...    threshold-RSRP eq 0))
    ...    and measIdToAddModList contains (
    ...    measId eq 3)
    ...    and measIdToRemoveList contains (17, 18, 19)



${B1_deactive_for_all}    measIdToRemoveList contains (17, 18, 19)

${ENDC_A5_for_Flte3_only}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 2870)
    ...    and reportConfigToAddModList contains (
    ...    a5-Threshold1 contains (
    ...    threshold-RSRP eq 97) 
    ...    and a5-Threshold2 contains (
    ...    threshold-RSRP eq 0))
    ...    and measIdToAddModList contains (
    ...    measId eq 3)

${ENDC_A5_for_Flte1_only}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 1400)
    ...    and reportConfigToAddModList contains (
    ...    a5-Threshold1 contains (
    ...    threshold-RSRP eq 97) 
    ...    and a5-Threshold2 contains (
    ...    threshold-RSRP eq 0))
    ...    and measIdToAddModList contains (
    ...    measId eq 3)

${HO_successful_to_lte3}    SEPARATOR=
    ...    mobilityControlInfo contains ( 
    ...    targetPhysCellId eq 3
    ...    and carrierFreq contains ( 
    ...    dl-CarrierFreq eq ${flte3}))

${HO_successful_to_lte1}    SEPARATOR=
    ...    mobilityControlInfo contains ( 
    ...    targetPhysCellId eq 1
    ...    and carrierFreq contains ( 
    ...    dl-CarrierFreq eq ${flte1}))
	
@{PCMD_Setup}
...    LNBTS:actPCMDReport=true
...    LNBTS/CTRLTS-1:extTraceReporting:extCellTraceRep=true
...    LNBTS/CTRLTS-1/MTRACE-1:actPCMDReporting=true
...    LNBTS/CTRLTS-1/MTRACE-1:jobType=TraceOnly
...    LNBTS/CTRLTS-1/MTRACE-1:tceIpAddress=10.0.1.1
...    LNBTS/CTRLTS-1/MTRACE-1:tceCellTracePortNum=49150
...    LNBTS/CTRLTS-1/MTRACE-1:lcrId=1
...    LNBTS/CTRLTS-1/MTRACE-1:traceRrcSetting=None
...    LNBTS/CTRLTS-1/MTRACE-1:traceS1Setting=None
...    LNBTS/CTRLTS-1/MTRACE-1:traceX2Setting=None
...    LNBTS/CTRLTS-1/MTRACE-1:actUeThroughputMR=false
...    LNBTS/CTRLTS-1/MTRACE-1:cellVendorSpecTracing:cellTaTracing=false

*** Test Cases ***
CB008913-SR-A-B9_ET_01_01_New ENDC-HO counters instead of former will be increased
    [Tags]    TC01
    [Documentation]
    ...    precondition:
    ...    CB008913 enabled on lte cell-1 and cell-3, lte1 for UE1 is non anchor layer, lte3 for UE2 is ENDC anchor layer
    ...    LNBTS:numB1CyclesWoEndc=1
    ...    freqLayEndcHoList.freqLayer={flte1, flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.IMLBNR.nrcellConfigL.band={77,257}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL="flte3"
    ...    CAGENB.CAIMLBP.IMLBNR.nrcellConfigL.band={8,257}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL="flte1"
    ...    UE-1 MRDC capability: {B7+N8,B7+N77}
    ...    UE-2 MRDC capability:{B3+N8,B3+N257,B7+N8,B7+N77}
    ...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased (LTE4193)
    ...    Case steps:
    ...    Step1: UE-1 ICS to Cell-1
    ...    check: B1 activated with Fnr1, Fnr2, Fnr3
    ...    step2: UE-1 report B1-NR measure at Fnr2
    ...    check: ENDC A5 activated
    ...    step3: UE-1 report A5 and ENDC HO is triggered to Flte cell-3
    ...    check: ENDC HO counter of CB008913 update
    ...    Step4: UE-2 ICS to cell-3
    ...    check: B1 activated with Fnr1, Fnr2, Fnr3
    ...    Step5: UE-2 report B1 at NR frequency Fnr3
    ...    check: ENDC A5 activated
    ...    step6: UE-2 report A5 and ENDC HO is triggered to Flte cell-1
    ...    check: ENDC HO counter of CB008913 update
    ...    step7: check PCMD: Measurement Report Triggers value 31(NrCoverageBasedEndcHo)
    ...    Mobility Trigger Reason: value 4(Mobility is triggered due to load balancing)
    [Setup]    Case Setup with Delta Commission and Clear Counters    ${delta_for_case_B9_01}
    Start TCE and Wait
    UE attach to cell and check B1 activation    ue_id=1    cell_id=1    mrdc_capa=${ue_eutra_nr_capabilities_b7+n8_b7+n77}    
    UE report B1 and Check A5 Active After B1 Supervision Timer timeout    ue_id=1    narfcn=${fnr2}    pci=2   
    Report valid ENDC_HO A5 for special EARFCN and check HO successful    ue_id=1    earfcn=${flte3}
    ...    pci=3    HO_successful=${HO_successful_to_lte3}
    UE attach to cell and check B1 activation    ue_id=2    cell_id=3
    UE report B1 and Check A5 Active After B1 Supervision Timer timeout    ue_id=2    narfcn=${fnr3}    pci=3  
    Report valid ENDC_HO A5 for special EARFCN and check HO successful    ue_id=2    earfcn=${flte1}
    ...    pci=1    HO_successful=${HO_successful_to_lte1}
    Check Counters    ${CB008913_ENDC_HO_counter_check}    
    Check WireShark Log    ${CURDIR}/A2A_B9_01/a2a_PCMD.ini    wait_string=StopRecordingSession::2
    [Teardown]    Local Test Teardown For Each Postcondition

CB008913-SR-A-B9_ET_02_01_Only legacy ENDC-HO counters will be increased
    [Tags]    TC02
    [Documentation]
    ...    precondition:
    ...    CB008913 enabled on lte cell-1 and cell-3
    ...    LNBTS:numB1CyclesWoEndc=1
    ...    freqLayEndcHoList.freqLayer={flte1, flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.IMLBNR.nrcellConfigL.band={77}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL="flte3"
    ...    CAGENB.CAIMLBP.IMLBNR.nrcellConfigL.band={8,257}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL="flte1"
    ...    UE-11 MRDC capability: {B7+N8,B7+N77}
    ...    UE-1 MRDC capability:{B3+N8,B3+N257,B7+N8,B7+N77}
    ...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased (LTE4193)
    ...    Case steps:
    ...    Step1: UE-11 ICS to Cell-1 without ENDC bearer established
    ...    check: A5 activated and no B1 activated since no ENDC bearer, while UE-11 is CB006607 UE
    ...    step2: add ENDC bearer for UE-11, report B1 for fnr2
    ...    check: ENDC A5 activated since UE-11 change to CB008913 UE
    ...    step3: delete ENDC bearer
    ...    check: UE-11 change to CB006607 UE and ENDC A5 activated
    ...    Step4: UE-11 report A5 of Flte3, and perform HO to cell-3
    ...    check: ENDC HO counter of CB006607 update, no counter of CB008913 update
    ...    Step5: UE-1 ICS to cell-3 with ENDC bearer established
    ...    check: B1 and A5 activated while UE-1 is CB007163 UE
    ...    Step6: UE-1 report B1 at NR frequency Fnr1
    ...    check: no A5 activated since UE-1 is CB007163 UE
    ...    step7: ENDC A5 activated with retry timer
    ...    step8: UE-1 report A5 of Flte1, and perform HO to cell-1
    ...    check: ENDC HO counter of CB007163 update, no counter of CB008913 update
    [Setup]    Case Setup with Delta Commission and Clear Counters    ${delta_for_case_B9_02}
    UE attach to cell and check no B1 activation and ENDC A5 activation after MRDC retrieved    ue_id=11    cell_id=1
    ...    mrdc_capa=${ue_eutra_nr_capabilities_b7+n8_b7+n77}
    Add ENDC Bearer And Report B1 For Fnr2 And Check A5 Activated For CB008913 UE
    Delete ENDC Bearer And Check ENDC A5 Activated
    Report valid ENDC_HO A5 for special EARFCN and check HO successful    ue_id=11    earfcn=${flte3}
    ...    pci=3    HO_successful=${HO_successful_to_lte3}
    UE attach to cell and check B1 activation and ENDC A5 activation after MRDC retrieved    ue_id=1    cell_id=3
    ...    mrdc_capa=${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}    A5_activate=${ENDC_A5_for_Flte1_only}
    Report valid B1 report for special NRFCN    ue_id=1    narfcn=${fnr1}    pci=1
    Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation    ue_id=1    endc_A5_activate=${ENDC_A5_for_Flte1_only}
    wait EndcHoRetry timer expired and expected ENDC A5 activated    ue_id=1
    Report valid ENDC_HO A5 for special EARFCN and check HO successful    ue_id=1    earfcn=${flte1}
    ...    pci=1    HO_successful=${HO_successful_to_lte1}
    Check Counters    ${CB006607_and_CB007163_ENDC_HO_counters_check}	

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
    Create MME alias    MME_1    mme_id=1    id_type=wts
    Set UE parameters for ENDC capability
    Config gnb


Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Egate Command    ue_mme_param id=1-10 spid=2
    Execute Uex Command    ue_param id=1-20 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=77,8,257

Config gnb
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=2:1


Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    FOR    ${ue_id}     IN RANGE    1    11
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END
    Add Yaml    BASE_STATIONS
    ...      - id: 7
    ...        gnb_id: '0x00007'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.41
    ...        x2_peers: 1
    ...        cells:
    ...          - ${gnb7_cell1}
    ...          - ${gnb7_cell2}
    ...          - ${gnb7_cell3}

UE attach to cell
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${mrdc_capa}=${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}
    ${V_1}    catenate
    ...      ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${mrdc_capa} 
    ...      ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    ${ret1}=    Execute Uex Command    ${V_1}

Case Setup with Delta Commission and Clear Counters
    [Arguments]    ${delta_params}
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${delta_params}
    Clear Counter Files


Report valid B1 report for special NRFCN
    [Arguments]    ${ue_id}=1    ${narfcn}=531040    ${pci}=2
    Execute Uex Command    ue_measurement_send id=${ue_id} narfcn=${narfcn} srsrp=79 phycell_id=${pci} nrsrp=58 event=B1_NR

UE attach to cell and check B1 activation
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${mrdc_capa}=${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime})
    ...    alias=B1_activation    overall_timeout=20
    UE attach to cell    ue_id=${ue_id}    cell_id=${cell_id}    mrdc_capa=${mrdc_capa}
    Flow Occurred As Expected    alias=B1_activation


Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation
    [Arguments]    ${ue_id}=1    ${endc_A5_activate}=${ENDC_A5_for_Flte3}    ${B1_deactive}=${B1_deactive_for_all}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_deactive})
    ...    alias=B1_deactive    overall_timeout=20
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${endc_A5_activate})
    ...    alias=NO_ENDC_A5    overall_timeout=20
    Flow Occurred As Expected    alias=B1_deactive
    Flow Not Occurred For message    alias=NO_ENDC_A5


Add bearer for dedicated QCI
    [Arguments]    ${ue_id}    ${QCI}
    Execute Uex Command    bearer_add ue=${ue_id} qci=${QCI}


Delete bearer for dedicated QCI
    [Arguments]    ${ue_id}    ${QCI}
    Execute Uex Command    bearer_del ue=${ue_id} qci=${QCI}


UE attach to cell and check no B1 activation and ENDC A5 activation after MRDC retrieved
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${mrdc_capa}=${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}
    ...    ${A5_activate}=${ENDC_A5_for_Flte3_only}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_UECapabilityEnquiry (ue-CapabilityRequest contains ("nr", "eutra-nr"))
    ...    UE_GROUP_${ue_id}:RRC_UECapabilityInformation
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${A5_activate})
    ...    alias=A5_activation    overall_timeout=20
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime})
    ...    alias=NO_B1    overall_timeout=20
    UE attach to cell    ue_id=${ue_id}    cell_id=${cell_id}    mrdc_capa=${mrdc_capa}
    Flow Occurred As Expected    alias=A5_activation
    Flow Not Occurred For message    alias=NO_B1

UE attach to cell and check B1 activation and ENDC A5 activation after MRDC retrieved
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${mrdc_capa}=${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}
    ...    ${A5_activate}=${ENDC_A5_for_Flte3_only}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime})
    ...    UE_GROUP_${ue_id}:RRC_UECapabilityEnquiry (ue-CapabilityRequest contains ("nr", "eutra-nr"))
    ...    UE_GROUP_${ue_id}:RRC_UECapabilityInformation
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${A5_activate})
    ...    alias=A5_activation    overall_timeout=20
    UE attach to cell    ue_id=${ue_id}    cell_id=${cell_id}    mrdc_capa=${mrdc_capa}
    Flow Occurred As Expected    alias=A5_activation

wait EndcHoRetry timer expired and expected ENDC A5 activated
    [Arguments]    ${ue_id}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measId eq 3))
    ...    alias=ENDC_A5_activate    overall_timeout=20
    Flow Occurred As Expected    alias=ENDC_A5_activate

Report valid ENDC_HO A5 for special EARFCN and check HO successful
    [Arguments]    ${ue_id}=1    ${earfcn}=${flte3}    ${pci}=3    ${HO_successful}=${HO_successful_to_lte3}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${HO_successful})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=HO_successful    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} earfcn=${earfcn} srsrp=79 phycell_id=${pci} nrsrp=58 nrsrq=26 event=A5
    Flow Occurred As Expected    alias=HO_successful
	
Add ENDC Bearer And Report B1 For Fnr2 And Check A5 Activated For CB008913 UE
    Add bearer for dedicated QCI    ue_id=11    QCI=6
    Report valid B1 report for special NRFCN    ue_id=11    narfcn=${fnr2}    pci=2
    wait EndcHoRetry timer expired and expected ENDC A5 activated    ue_id=11
	
Delete ENDC Bearer And Check ENDC A5 Activated
    Delete bearer for dedicated QCI    ue_id=11    QCI=6
    wait EndcHoRetry timer expired and expected ENDC A5 activated    ue_id=11

UE report B1 and Check A5 Active After B1 Supervision Timer timeout
    [Arguments]    ${ue_id}    ${narfcn}    ${pci}
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${narfcn}    pci=${pci}
    wait EndcHoRetry timer expired and expected ENDC A5 activated    ue_id=${ue_id}
	
Local Test Teardown For Each Postcondition
    Stop TCE    ${tceport}
    Common Test Teardown And Stop Capture Logs
	
Start TCE and Wait
    Start TCE    ${tceport}
    Sleep    120    #wait PCMD trace session to establish