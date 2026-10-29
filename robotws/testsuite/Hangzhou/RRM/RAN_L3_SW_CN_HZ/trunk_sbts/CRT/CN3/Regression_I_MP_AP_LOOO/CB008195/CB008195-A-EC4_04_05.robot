*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LOOO    team-VRF_HAZ3_8
...    owner-xiujuan.sun    release-SBTS24R3
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${CaSup}    ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

${rdMaxActiveIncomingCaRelFlexSCellSelect}    0x89006C
${rdMaxActiveOutgoingCaRelFlexSCellSelect}    0x89006D

@{PARAMS_IN_SWCONFIG}    ${rdMaxActiveIncomingCaRelFlexSCellSelect}=3    ${rdMaxActiveOutgoingCaRelFlexSCellSelect}=6
@{PARAMS_IN_VENDOR}
...    maxNumPucchF1SRPerSlotL1Pool=1
...    maxNumOfDRBL2Pool=10
...    maxNumOfUserL2Pool=10
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_other}
...    @{PARAMS_FOR_NRCELL1}
...    @{NativeBand_BWP}
...    NRCELL:maxNumOfSCellAlloc=1
...    @{8195_enabled}
...    @{8525_enabled}
...    @{lock_unused_cells_and_disable_NRCELL-3_NRCELL-13}
...    NRCELL-1:actVoNR=true
...    @{CB008232}
...    @{CB008806}
...    NRCELL:numOfRadioResReservForTempUse=1
...    @{caseAEC4_05}
@{CB008232}
...    NRBTS:applyPriorityAccess=HPA
...    NRBTS/NRPRIOACC_PROFILE-1:nrPlmnIdx=1
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=8
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=6
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax=4
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin=1
...    NRCELL-13:numOfRadioResReservForPa=1
...    NRBTS/NRDU-1:numOfDrbsReservForPa=0
...    NRCELL-13:tPageCorrInt=3000
...    NRCELL-13:raPrioritizationForAI=MPS
...    NRCELL-13:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-13:powerRampingStep=dB2
...    NRCELL-13:pagingPrioLevelPaMax=1
...    NRCELL-13:pagingPrioLevelPaMin=1
...    NRCELL-13:actVoNR=true
...    NRCELL-13:arpPrioEmergencyCall=1
...    NRCELL-13:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-13:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-13:numOfRadioResReservForEmergency=1
...    NRCELL-3:arpPrioEmergencyCall=1
...    NRCELL-3:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-3:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-3:numOfRadioResReservForEmergency=1
...    NRCELL-3:numOfRadioResReservForPa=1
...    NRCELL-3:tPageCorrInt=3000
...    NRCELL-3:raPrioritizationForAI=MPS
...    NRCELL-3:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-3:powerRampingStep=dB2
...    NRCELL-3:pagingPrioLevelPaMax=1
...    NRCELL-3:pagingPrioLevelPaMin=1
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=1
...    NRCELL-3:actVoNR=true

@{lock_unused_cells_and_disable_NRCELL-3_NRCELL-13}
...    NRCELL-13:sliceAwareAdmissionCtrlEnabled=false
...    NRCELL-13:nrResourceGroupProfileRacDN=${EMPTY}
...    NRCELL-14:administrativeState=Locked
...    NRCELL-15:administrativeState=Locked
...    NRCELL-16:administrativeState=Locked
...    NRCELL-17:administrativeState=Locked
...    NRCELL-18:administrativeState=Locked
...    NRCELL-19:administrativeState=Locked
...    NRCELL-20:administrativeState=Locked
...    NRCELL-21:administrativeState=Locked
...    NRCELL-22:administrativeState=Locked
...    NRCELL-3:sliceAwareAdmissionCtrlEnabled=false
...    NRCELL-3:nrResourceGroupProfileRacDN=${EMPTY}
...    NRCELL-4:administrativeState=Locked
...    NRCELL-5:administrativeState=Locked
...    NRCELL-6:administrativeState=Locked

${drbRrcInactInactivityTimerSA_timeout}    20
@{8525_enabled}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=${drbRrcInactInactivityTimerSA_timeout}
...    NRBTS:maxUeRrcInactTime=2
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=false
...    NRBTS:tRanPagingGuard=4

@{8195_enabled}
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRCELL:cellDepType=SA
...    NRCELL:nrResourceGroupProfileRacDN=MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1
...    NRCELL:ranAC=0
...    NRCELL:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL:configuredEpsTac=${EMPTY}
...    NRCELL-1/NRREL-11:isRplCellForPSCell=false
...    NRCELL-1/NRREL-12:isRplCellForPSCell=false
...    NRCELL-1/NRREL-15:isRplCellForPSCell=false
...    NRCELL-1/NRREL-19:isRplCellForPSCell=false
...    NRCELL-1/NRREL-20:isRplCellForPSCell=false
...    NRCELL-1/NRREL-5:isRplCellForPSCell=false
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:applyCellRacForPrivilegedUE=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=10
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=10
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=10
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:maxQuota=50
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:minQuota=20
...    NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=4
...    NRBTS/SNSSAI-2:sd=13714342
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-2:ngUplane=${EMPTY}
...    NRBTS/SNSSAI-3:sd=13714343
...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-3:ngUplane=${EMPTY}
...    NRBTS/SNSSAI-4:sd=13714344
...    NRBTS/SNSSAI-4:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-4:ngUplane=${EMPTY}
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDNLast=MRBTS-1/NRBTS-1/SNSSAI-4
...    NRCELL-1:actPerCsiReportBundlingTddFr1=true
...    NRCELL-2:actPerCsiReportBundlingTddFr1=true
...    NRCELL-3:actPerCsiReportBundlingTddFr1=true

@{PARAMS_FOR_NRCELL1}
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-5:gNbId=1
...    NRCELL-1/NRREL-5:gNbIdLength=22
...    NRCELL-1/NRREL-5:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-5:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-5:lcrId=5
...    NRCELL-1/NRREL-5:nrDcAllowed=false
...    NRCELL-1/NRREL-5:removeNotAllowed=false
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-5:isRplCellForPSCell=true
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:nrDcAllowed=false
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:isRplCellForPSCell=true
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:nrDcAllowed=false
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:isRplCellForPSCell=true
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-15:gNbId=1
...    NRCELL-1/NRREL-15:gNbIdLength=22
...    NRCELL-1/NRREL-15:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-15:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-15:lcrId=15
...    NRCELL-1/NRREL-15:nrDcAllowed=false
...    NRCELL-1/NRREL-15:removeNotAllowed=false
...    NRCELL-1/NRREL-15:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-15:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-15:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-15:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-15:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-15:isRplCellForPSCell=true
...    NRCELL-1/NRREL-19:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-19:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-19:gNbId=1
...    NRCELL-1/NRREL-19:gNbIdLength=22
...    NRCELL-1/NRREL-19:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-19:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-19:lcrId=19
...    NRCELL-1/NRREL-19:nrDcAllowed=false
...    NRCELL-1/NRREL-19:removeNotAllowed=false
...    NRCELL-1/NRREL-19:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-19:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-19:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-19:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-19:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-19:isRplCellForPSCell=true
...    NRCELL-1/NRREL-20:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-20:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-20:gNbId=1
...    NRCELL-1/NRREL-20:gNbIdLength=22
...    NRCELL-1/NRREL-20:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-20:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-20:lcrId=20
...    NRCELL-1/NRREL-20:nrDcAllowed=false
...    NRCELL-1/NRREL-20:removeNotAllowed=false
...    NRCELL-1/NRREL-20:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-20:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-20:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-20:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-20:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-20:isRplCellForPSCell=true
...    NRCELL-1/NRREL-5:sCellPrio=1
...    NRCELL-1/NRREL-15:sCellPrio=3
...    NRCELL-1/NRREL-11:sCellPrio=2
...    NRCELL-1/NRREL-12:sCellPrio=12
...    NRCELL-1/NRREL-19:sCellPrio=19
...    NRCELL-1/NRREL-20:sCellPrio=20
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{PARAMS_FOR_other}
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:srbInactivityTimerSA=600
...    NRCELL:filterCoeffSsbRsrq=fc4
...    NRBTS/NRSCTP-1:sctpProfile:sctpRtoInit=30000
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1
...    NRCELL:actDlRbgRandomization=disabled
...    NRCELL:timingAdvanceOffset=n25600
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

@{PARAMS_FOR_CA}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CaSup}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:maxNumScellsUl=2
...    NRCELL:actK1Opt=intra-gNB

@{NativeBand_BWP}
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=38
...    NRCELL-6:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-6:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-1:actEnhMultipleDedicatedBWPs=true
...    NRCELL-6:actEnhMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-5:bwpType=dedicated
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=10|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=11|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRCELL-6:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-6:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-77
...    NRCELL-6:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-2:gscnOrSsPbchArfcn=6276
...    NRCELL-3:gscnOrSsPbchArfcn=6372
...    NRCELL-4:gscnOrSsPbchArfcn=6276
...    NRCELL-5:gscnOrSsPbchArfcn=8054
...    NRCELL-6:gscnOrSsPbchArfcn=8009
...    NRCELL-2:nrarfcn=510306
...    NRCELL-4:nrarfcn=510306
...    NRCELL-2:msg1FrequencyStart=20
...    NRCELL-3:msg1FrequencyStart=20
...    NRCELL-4:msg1FrequencyStart=20
...    NRCELL-5:msg1FrequencyStart=20
...    NRCELL-6:msg1FrequencyStart=20

...    NRBTS/BWP_PROFILE-17:bwpType=initial
...    NRBTS/BWP_PROFILE-17:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-17:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-17:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-17:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-17/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=3
...    NRBTS/BWP_PROFILE-18:bwpType=dedicated
...    NRBTS/BWP_PROFILE-18:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-18:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-18:locationAndBandwidthUl:cRbSizeUl=n106
...    NRBTS/BWP_PROFILE-18:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-18/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-19:bwpType=dedicated
...    NRBTS/BWP_PROFILE-19:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-19:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-19:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-19:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-19/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-17
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-18
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-19
...    NRCELL-1:chBw=40MHz
...    NRCELL-1:nrarfcn=519000
...    NRCELL-1:gscnOrSsPbchArfcn=6462
...    NRCELL-1:type0CoresetConfigurationIndex=10
...    NRCELL-1:msg1FrequencyStart=20

...    NRCELL-13/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-15/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-15/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-13:actEnhMultipleDedicatedBWPs=true
...    NRCELL-15:actEnhMultipleDedicatedBWPs=true
...    NRCELL-15:msg1FrequencyStart=20
...    NRCELL-13:msg1FrequencyStart=20
...    NRCELL-13:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-16
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-27
...    NRCELL-13:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-88
...    NRCELL-15:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-16
...    NRCELL-15:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-27
...    NRCELL-15:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-88
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthDl:cRbSizeDl=n52
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-16/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-27:bwpType=dedicated
...    NRBTS/BWP_PROFILE-27:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-27:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-27:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-27/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-88:bwpType=dedicated
...    NRBTS/BWP_PROFILE-88:locationAndBandwidthDl:cRbSizeDl=n52
...    NRBTS/BWP_PROFILE-88:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-88:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-88/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDSCH-1:pdschRat0RbgConfig=config1

...    NRCELL-17:actEnhMultipleDedicatedBWPs=true
...    NRCELL-17:msg1FrequencyStart=20
...    NRCELL-17:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4|cellBwpId=0
...    NRCELL-17:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-47|cellBwpId=1
...    NRCELL-17:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-48|cellBwpId=2
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbSizeDl=n52
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-47:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-47:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-48:bwpType=dedicated
...    NRBTS/BWP_PROFILE-48:locationAndBandwidthDl:cRbSizeDl=n52
...    NRBTS/BWP_PROFILE-48:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-48:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-48/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=10|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=11|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDSCH-1:pdschRat0RbgConfig=config1

@{FAULTS_EXCLUDED_CHECKING}
...    61649    4655    61524    4654    61652    4122    1898    4405

${AVG_NUM_UE_NOM_NRG}    M55910C00005
${DNOM_SAMPLES_NRG}    M55910C00006
${AVE_NUM_NGBR_NOM_NRG}    M55910C00007
${PEAK_NUM_UE_NRG}    M55910C00010
${PEAK_NUM_NGBR_NRG}    M55910C00011
${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}    M55910C00015
${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}    M55910C00016
${NUM_ADM_REQ_NGBR_NRG}    M55910C00017
${NUM_ADM_SUC_NGBR_NRG}    M55910C00018
${NUM_ADM_REQ_UE_NRG}    M55910C00023
${NUM_ADM_SUC_UE_NRG}    M55910C00024

@{FM_COUNTER_OF_SLICE_AEC4_01}
...    ${NRRRD_RRC_SETUP_FAIL}=1
...    ${NRRCD_RRC_STPREQ_MO_SIGNALLING}=10
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>2
...    NRCELL-1/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>3
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}=300
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}=300
...    NRCELL-1/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}=300
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>2
...    NRCELL-1/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>3
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}=300
...    NRCELL-2/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}=300
...    NRCELL-2/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}=300
...    NRCELL-2/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=3
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

@{FM_COUNTER_OF_SLICE_AEC4_04_2}
...    ${NRRRD_RRC_SETUP_FAIL}=0
...    ${NRRCD_RRC_STPREQ_MO_SIGNALLING}=1
...    NRCELL-11/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>3
...    NRCELL-11/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}=300
...    NRCELL-11/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}=300
...    NRCELL-11/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}=300
...    NRCELL-11/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>2
...    NRCELL-11/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>3
...    NRCELL-11/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=1
...    NRCELL-11/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=3
...    NRCELL-11/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-11/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=4
...    NRCELL-11/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=3
...    NRCELL-11/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=3
...    NRCELL-11/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-11/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=1
...    NRCELL-11/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-11/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

@{FM_COUNTER_OF_SLICE_AEC4_05}
...    ${NRRRD_RRC_SETUP_FAIL}=0
...    ${NRRCD_RRC_STPREQ_MO_SIGNALLING}=2
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}=300
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}=300
...    NRCELL-1/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}=300
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>2
...    NRCELL-1/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=2
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}=300
...    NRCELL-2/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}=300
...    NRCELL-2/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}=300
...    NRCELL-2/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>2
...    NRCELL-2/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>2
...    NRCELL-2/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=6
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=3
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=4
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=3
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=2
...    NRCELL-2/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0


${NRRCD_RRC_STPREQ_MO_SIGNALLING}    M55127C00001
${NRRRD_RRC_SETUP_FAIL}    M55127C00010



@{CB008806}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS-1:suppCnPartialAdNgHo=false
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000
...    NRBTS:timerXnDataFwdGuard=2000
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:absThreshSsbRsrpConsolidation=0
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:ifhoSsbSmtcOffset=1
...    NRCELL/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL/NRHOIF-1:cellDepType=SA
...    NRCELL/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-1:ssbFrequency=513150
...    NRCELL/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-1:gNbId=35
...    NRCELL/NRREL-1:gNbIdLength=22
...    NRCELL/NRREL-1:lcrId=1
...    NRCELL/NRREL-1:removeNotAllowed=false
...    NRCELL/NRREL-1:nrDcAllowed=false
...    NRCELL/NRREL-1:gnbPlmn:mcc=311
...    NRCELL/NRREL-1:gnbPlmn:mnc=489
...    NRCELL/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL/NRREL-1:handoverAllowedSA=XnHoNotAllowed
...    @{NRADJGNB}
...    @{NRADJNRCELL}

@{NRADJGNB}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=35
...    NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3

@{NRADJNRCELL}
...    NRBTS/NRADJNRCELL-1:cellDepType=SA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-1:gNbId=35
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=513234
...    NRBTS/NRADJNRCELL-1:physCellId=381
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=513150

@{caseAEC4_05}
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:cellDepType=SA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:ssbFrequency=502110
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-1/NRREL-5:lcrId=2
...    NRCELL-2/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-2:cellDepType=SA
...    NRCELL-2/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-2:ssbFrequency=516990
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:sCellPrio=1
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3

*** Test Cases ***


CB008195-A-EC4_ET_04_01_Counters for SA non-GBR DRB admission dynamic cell limits check
    [Tags]    AEC4_04    CRT
    [Documentation]    1. The test scenario is intended to verify Counters for SA non-GBR DRB admission dynamic cell limit check.
    ...    2 Configuration
    ...    3. Test Case Steps:
    ...       maxNumOfDRBL2Pool=10,maxNumOfUserL2Pool=10
    ...       the scalingFactor of TDD is : [Scaling factor] = 0.021; [Multicell group type]: L2POOL;[Resource type]: DRB;
    ...                                     [Scaling factor] = 0.034; [Multicell group type]: L2POOL;[Resource type]: ueContext;
    ...       the scalingFactor of FDD is : [Scaling factor] = 0.021; [Multicell group type]: L2POOL;[Resource type]: DRB;
    ...                                     [Scaling factor] = 0.034; [Multicell group type]: L2POOL;[Resource type]: ueContext;
    ...       L2POO DRB: min_quto=[1,1,2] ,max_quota=[56,224,280] for each TDD and FDD with 8195 on. NRCELL:numOfRadioResReservForTempUse=1
    ...       L2POO Uecontext: min_quto=[0,0,1] ,max_quota=[27,110,137] for each TDD and FDD with 8195 on. NRCELL:numOfRadioResReservForTempUse=1
    ...       cellGuaranteeResources of all NRCELL both DRB and Ue context are 0.
    ...       Steps: for drb, the common resource number is 10-(1+1+2)-(1+2+1)=2
    ...           1. register 10 UEs to NRCELL-1, the 10th UE will be refused. 10-(0+0+1)=9
    ...           2. create 4 DRB on slice1 for SA1, only the 4th will be failed .
    ...              10-(1+1+2)-(1+2)=3. 1 dedicated and 2 common resource used.
    ...           3. create 2 DRB on slice2 for SA2, only the 2nd will be failed .
    ...               only dedicated resources can be used, because of no common resource left.
    ...           4. create 3 DRB on slice3 for SA3, only the 3th will be failed .
    ...               only dedicated resources can be used, because of no common resource left.
    ...           5. create 1 DRB on slice4 for SA4 will be failed.
    ...                because of both dedicate and common resource left.
    ...           6. let SA1 RRE to NRCELL-2: will be failed becasue of no free NR user num in pool and SA1 will be released.
    ...           7. release SA9 or else the following step will be failed: the tempuser cannot be used again
    ...                when reserveMinquota and avaialbepool resource are both empty.
    ...           8. let SA2 RRE to NRCELL-1 will be successfuly
    ...           9. check counters.
    ...           10. clear all counter file and start for next senario:
    ...           11. create SA4 to NRCELL-11 and create 4 pdu on with slice2 , the 4th pdu shall be failed.
    ...              1 dedicated and up to 2 common resource can be used for slice2.
    ...           12. create 3 pdu with slice3 for SA4, and 1 pdu for slice4. the 3th pdu with slice3 and slice4 will be failed.
    ...              no common resource left, so only dedicated(2)
    ...           13. check counters.
    Lock_X2Link_to_let_gnb_Performed_as_SA
    Check counter When UE has one kind of Slice
    Release Ues    ue_type=all
    Check counter When UE has multi kind of slice

CB008195-A-EC4_ET_05_01_Counters for Admission for incoming HO static cell limits check
    [Tags]    AEC4_05    pass
    [Documentation]    1. The test scenario is intended to verify Counters for Admission for incoming HO static cell limits check.
    ...    2 Configuration
    ...    3. Test Case Steps:
    ...       1. NRCELL-1: create 2 DRB on slice1 for SA1, only 1 common resource is left for drbperl2pool.
    ...       2. SA1 interfrq handover to NRCELL-2 slice1 will be successfully.
    ...       3. SA1 interfrq handover to NRCELL-1 slice1 will be successfully.
    ...       4. NRCELL-1: create 3 DRB on slice1 for SA1, no common resource is left for drbperl2pool.
    ...       5. SA1 interfrq handover to NRCELL-1 slice1 will be failed becuase of no common resource left. SA1 still be kept in NRCELL-1 slice1.
    ...       6. SA2 interfrq handover to NRCELL-2 slice1 will be failed becuase of no common resource left. SA2 still be kept in NRCELL-2 slice1.
    ...       7. Delete 1 drb for SA2
    ...       8. SA1 interfrq handover to NRCELL-2 slice1 will be successfully.
    ...       9. SA2 interfrq handover to NRCELL-1 slice2 will be successfully.
    Clear Counter Files
    Register For Number Of Normal Calls with Default PDU    cell_id=1    ue_id_start=1    ue_id_end_before=2    nwslice=1
    Add_pdu_for_sa    ue_id=1    qos_flow=3

    SA1 inter-freqency to NRCELL-2 from NRCELL-1 should be successfully
    SA1 inter-freqency to NRCELL-1 from NRCELL-2 should be successfully

    Register For Number Of Normal Calls with Default PDU    cell_id=1    ue_id_start=2    ue_id_end_before=3    nwslice=2
    Add_pdu_for_sa    ue_id=2    qos_flow=3
    SA1 inter-freqency to NRCELL-2 from NRCELL-1 should be failed
    SA2 inter-freqency to NRCELL-2 from NRCELL-1 should be failed

    delete_qos_for_sa    ue_id=2    qosflows_to_del=3

    Trigger A3 Measurement Report    ue_id=1    carrierfreq=502110     phycelId=51
    ...    pass_check=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

    Trigger A3 Measurement Report    ue_id=2    carrierfreq=502110     phycelId=51
    ...    pass_check=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Check Counters    ${FM_COUNTER_OF_SLICE_AEC4_05}

*** Keywords ***
Check counter When UE has one kind of Slice
    Clear Counter Files
    reach the maxnum of UEs on NRCELL-1
    Create 3 DRBs of slice1 for SA1 on NRCELL-1 to exhausted common resource
    create 1 DRB of slice2 for SA2
    Create 2 DRB of slice3 for SA3
    Create Default PDU sessions for UEs failed    ueid_start=5    ueid_end=6    nwslice=4
    SA reestablish to NRCELL should be failed    ue_id=1    cell_id=2
    Deregister UEs    ueid_start=9    ueid_end=10
    SA reestablish to NRCELL    ue_id=2    cell_id=1
    Check Counters    ${FM_COUNTER_OF_SLICE_AEC4_01}

Deregister UEs
    [Arguments]    ${ueid_start}=1    ${ueid_end}=1
    Execute Egate Command    ue_deregister id=${ueid_start}-${ueid_end} ue_deregister_type=switch_off    detached


SA reestablish to NRCELL
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id}    pass_regexp=rrcReconfigurationComplete

SA reestablish to NRCELL should be failed
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id}    pass_regexp=Received UE Context Release Complete

reach the maxnum of UEs on NRCELL-1
    SA UEs Register to NRCELL    ueid_start=1    ueid_end=10    cell_id=1
    Register One UE to NRCELL failed    ue_id=10    cell_id=1

create 1 DRB of slice2 for SA2
    Create Default PDU sessions for UEs    ueid_start=2    ueid_end=3    nwslice=2
    Add_pdu_for_sa_failed    ue_id=2    qos_flow=3

Create 2 DRB of slice3 for SA3
    Create Default PDU sessions for UEs    ueid_start=3    ueid_end=4    nwslice=3
    Add_pdu_for_sa    ue_id=3    qos_flow=3
    Add_pdu_for_sa_failed    ue_id=3    qos_flow=4

Create 3 DRBs of slice1 for SA1 on NRCELL-1 to exhausted common resource
    Create Default PDU sessions for UEs    ueid_start=1    ueid_end=2    nwslice=1
    Add_pdu_for_sa    ue_id=1    qos_flow=3
    Add_pdu_for_sa    ue_id=1    qos_flow=4
    Add_pdu_for_sa_failed    ue_id=1    qos_flow=5

Check counter When UE has multi kind of slice
    Clear Counter Files
    Register For Number Of Normal Calls with Default PDU    cell_id=11    ue_id_start=4    ue_id_end_before=5    nwslice=3
    add_Pdu_to_slice_for_sa    ue_id=4    nwslice=2    pdu=5    gateway_id=5
    add_Pdu_to_slice_for_sa    ue_id=4    nwslice=2    pdu=6    gateway_id=6
    add_Pdu_to_slice_for_sa    ue_id=4    nwslice=2    pdu=7    gateway_id=7
    add_Pdu_to_slice_for_sa_failed    ue_id=4    nwslice=2    pdu=8    gateway_id=8
    add_Pdu_to_slice_for_sa    ue_id=4    nwslice=3    pdu=9    gateway_id=9
    add_Pdu_to_slice_for_sa_failed    ue_id=4    nwslice=4    pdu=10    gateway_id=10
    Check Counters    ${FM_COUNTER_OF_SLICE_AEC4_04_2}

Create Default PDU sessions for UEs failed
    [Arguments]    ${ueid_start}=1    ${ueid_end}=1    ${nwslice}=1
    FOR    ${ue_id}    IN RANGE    ${ueid_start}    ${ueid_end}
        Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=${nwslice} gw=${ue_id}    resources not available    timeout=5s
	END

delete_qos_for_sa
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qosflows_to_del}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows_to_del} by=amf
    ...    pass_regexp=Received Pdu Session Resource Modify Response Message

SA1 inter-freqency to NRCELL-2 from NRCELL-1 should be successfully
    UE inter-freqency to NRCELL    ue_id=1    serving_cell_carrierfreq=516990    target_cell_carrierfreq=502110
    ...    tareget_cell_phycelId=51     pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed


SA1 inter-freqency to NRCELL-1 from NRCELL-2 should be successfully
    UE inter-freqency to NRCELL    ue_id=1    serving_cell_carrierfreq=502110    target_cell_carrierfreq=516990
    ...    tareget_cell_phycelId=50     pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed

SA1 inter-freqency to NRCELL-2 from NRCELL-1 should be failed
    UE inter-freqency to NRCELL failed    ue_id=1    serving_cell_carrierfreq=516990    target_cell_carrierfreq=502110
    ...    tareget_cell_phycelId=51     fail_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

SA2 inter-freqency to NRCELL-2 from NRCELL-1 should be failed
    UE inter-freqency to NRCELL failed    ue_id=2    serving_cell_carrierfreq=516990    target_cell_carrierfreq=502110
    ...    tareget_cell_phycelId=51     fail_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed


UE inter-freqency to NRCELL failed
    [Arguments]    ${ue_id}    ${serving_cell_carrierfreq}    ${target_cell_carrierfreq}    ${tareget_cell_phycelId}    ${fail_regexp}
    Trigger A2 measurement report    ue_id=${ue_id}    carrierfreq=${serving_cell_carrierfreq}
    Trigger A3 Measurement Report failed    ue_id=${ue_id}    carrierfreq=${target_cell_carrierfreq}
    ...    phycelId=${tareget_cell_phycelId}     failed_check=${fail_regexp}


UE inter-freqency to NRCELL
    [Arguments]    ${ue_id}    ${serving_cell_carrierfreq}    ${target_cell_carrierfreq}    ${tareget_cell_phycelId}    ${pass_regexp}
    Trigger A2 measurement report    ue_id=${ue_id}    carrierfreq=${serving_cell_carrierfreq}
    Trigger A3 Measurement Report    ue_id=${ue_id}    carrierfreq=${target_cell_carrierfreq}
    ...    phycelId=${tareget_cell_phycelId}     pass_check=${pass_regexp}


Trigger A2 measurement report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=3 srsrq_nr=5
    ...    pass_regexp=${pass_check}

Trigger A3 Measurement Report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycelId}    ${pass_check}    ${nrsrp_nr}=60    ${nrsrq_nr}=60
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycelId} nrsrp_nr=${nrsrp_nr}
    ...    nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${V3}    pass_regexp=${pass_check}    sleep_time=1

Trigger A3 Measurement Report failed
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycelId}    ${failed_check}    ${nrsrp_nr}=60    ${nrsrq_nr}=60
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycelId} nrsrp_nr=${nrsrp_nr}
    ...    nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${V3}    fail_regexp=${failed_check}    sleep_time=1

Lock_X2Link_to_let_gnb_Performed_as_SA
    Execute Egate Command    link_lock link=x2 at=enb:1 to=gnb:2    locked

add_Pdu_to_slice_for_sa
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${pdu}=${ue_id}    ${gateway_id}=${ue_id}    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gateway_id}    ${pass_regexp}    timeout=5s

add_Pdu_to_slice_for_sa_failed
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${pdu}=${ue_id}    ${gateway_id}=${ue_id}    ${pass_regexp}=RAN radio resources not available
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gateway_id}    ${pass_regexp}    timeout=5s
SA UEs Register to NRCELL
    [Arguments]    ${ueid_start}=1    ${ueid_end}=1    ${cell_id}=1
    FOR    ${ue_id}    IN RANGE    ${ueid_start}    ${ueid_end}
        Register One UE to NRCELL    ue_id=${ue_id}    cell_id=${cell_id}
	END

Create Default PDU sessions for UEs
    [Arguments]    ${ueid_start}=1    ${ueid_end}=1    ${nwslice}=1
    FOR    ${ue_id}    IN RANGE    ${ueid_start}    ${ueid_end}
        sa ue register and pdu setup    ue_id=${ue_id}    nwslice=${nwslice}
	END

Add_pdu_for_sa_failed
    [Arguments]    ${ue_id}=1    ${qos_flow}=3
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_flow} by=amf    timeout=5s
    ...    fail_regexp=Added QosFlow with
Add_pdu_for_sa
    [Arguments]    ${ue_id}=1    ${qos_flow}=3
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_flow} by=amf    timeout=5s
    ...    pass_regexp=Added QosFlow with

Register One UE to NRCELL
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=NG RM Registered

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=${nwslice} gw=${ue_id}    QoS Routing Table


Register For Number Of Normal Calls with Default PDU
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}    ${nwslice}=1
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
        Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=${nwslice} gw=${ue_id}    QoS Routing Table    timeout=5s
    END

Register One UE to NRCELL failed
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2    ${pass_regexp}=rrcReject
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=${pass_regexp}    timeout=2s

Register For Normal Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB    ${ue_id}

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg


Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}


Modify Cfg
    ${C_1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=519000:519000 gscn=6462 mandatory_for_activation=off
    ${C_2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=510306:510306 gscn=6276 mandatory_for_activation=off
    ${C_3}    catenate
    ...    set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=517800:517800 gscn=6372 mandatory_for_activation=off
    ${C_4}    catenate
    ...    set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=510306:510306 gscn=6276 mandatory_for_activation=off
    ${C_5}    catenate
    ...    set_cell id=5 gnb=2 pci=18:0 tac=200 nrci=0x05 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=656000:656000 gscn=8054 mandatory_for_activation=off
    ${C_6}    catenate
    ...    set_cell id=6 gnb=2 pci=18:1 tac=200 nrci=0x06 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=650000:650000 gscn=8009 mandatory_for_activation=off
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    ${C_3}
    Update Cfg    ${C_4}
    Update Cfg    ${C_5}
    Update Cfg    ${C_6}
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=6
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosflow id=5 5qi=8
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 qos_flows=5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A6 ue=all amf=1
    Update Cfg    set_nwslice id=3 qos_flows=5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A7 ue=all amf=1
    Update Cfg    set_nwslice id=4 qos_flows=5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A8 ue=all amf=1
    Update Cfg    set_nwslice id=5 qos_flows=5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A9 ue=all amf=1
    Add more number of SA UEs    ueid_start=101    ueid_end=150

Add more number of SA UEs
    [Arguments]    ${ueid_start}    ${ueid_end}
    ${suci}    set variable    500
    FOR    ${ue_id}    IN RANGE    ${ueid_start}    ${ueid_end}
        ${suci}    evaluate    ${suci}+1
        ${ue_simulated}    catenate
        ...    set_ue simulated id=${ue_id} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
        ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
        ...    suci=0:311:489:0000:0:0:021645${suci} enb=2 cell=11 mode=nr
        Update Cfg     ${ue_simulated}
        Update Cfg     ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
	END

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/18cells_6T12F

