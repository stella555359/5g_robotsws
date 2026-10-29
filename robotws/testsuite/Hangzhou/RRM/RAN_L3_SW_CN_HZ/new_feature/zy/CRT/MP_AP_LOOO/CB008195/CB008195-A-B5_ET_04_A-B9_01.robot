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
Resource    testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/resources/DevHZ5_resource.robot

*** Variables ***
${CONFIG_WA}    ${False}
${UTE_WIRESHARK_FLAG}    ${True}
${UTE_CPU_MEM_FLAG}    ${True}
${CaSup}    ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

${rdMaxActiveIncomingCaRelFlexSCellSelect}    0x89006C
${rdMaxActiveOutgoingCaRelFlexSCellSelect}    0x89006D

@{PARAMS_IN_SWCONFIG}    ${rdMaxActiveIncomingCaRelFlexSCellSelect}=3    ${rdMaxActiveOutgoingCaRelFlexSCellSelect}=6
@{PARAMS_IN_VENDOR}
...    maxNumPucchF1SRPerSlotL1Pool=1

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_other}
...    @{PARAMS_FOR_NRCELL1}
...    @{NativeBand_BWP}
...    NRCELL:maxNumOfSCellAlloc=1
...    @{8195_enabled}
...    @{8525_enabled}
...    @{lock_unused_cells_and_disable_NRCELL-3_NRCELL-13}
...    @{FIX_RELATION_ERROR}

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
...    NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
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
#...    NRBTS/BWP_PROFILE-5:bwpType=dedicated
#...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n133
#...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb0
#...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
#...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=static
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=9
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=9
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=9
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=9
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=9
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|duration=9
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9|duration=9
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|duration=9
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|duration=9
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|duration=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=10|duration=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|duration=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=3
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=3
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=3
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=3
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=3
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|duration=3
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=11|duration=3
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|duration=3
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
#...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
#...    NRBTS/BWP_PROFILE-5/PDSCH-1:pdschRat0RbgConfig=config1
#...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
#...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n133
#...    NRBTS/BWP_PROFILE-77:locationAndBandwidthDl:cRbStartDl=crb0
#...    NRBTS/BWP_PROFILE-77:locationAndBandwidthDl:cRbSizeDl=allRb
#...    NRCELL-6:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
#...    NRCELL-6:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-77
#...    NRCELL-6:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
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

@{FIX_RELATION_ERROR}
...    NRBTS:actSaUeBasedAnrNr=false
...    NRBTS/NRANR-1:actAutoNrNbRemoval=false
...    NRCELL:actDynUlDataSplitMode=false
...    NRCELL:dlHpReservedRbgs=${EMPTY}
...    NRCELL-6:pdcchAutoConfig:fineTuneMode=disabled
...    NRBTS:actInterMeNBMobility=false
...    NRBTS:actIntraMeNBMobility=false
...    NRBTS:actMobilityRetryToSecondBestCell=false
...    NRBTS:actMultiDrbNSA=false

@{FAULTS_EXCLUDED_CHECKING}
...    61649    4655    61524    4654    61652    4122    1898    4405

${expected_scaling_factor_tdd}    SEPARATOR=
...    [Scaling factor] = 0.068; [Multicell group type]: L1POOL_SR;[Resource type]: UeContxt;
${expected_scaling_factor_fdd}    SEPARATOR=
...    [Scaling factor] = 0.341; [Multicell group type]: L1POOL_SR;[Resource type]: UeContxt;
${expected_nrcell-1}     NRCELL-1:rgRacMinQuotaLimitationInfo=${expected_scaling_factor_tdd}
${expected_nrcell-2}    NRCELL-2:rgRacMinQuotaLimitationInfo=${expected_scaling_factor_tdd}
${expected_nrcell-11}    NRCELL-11:rgRacMinQuotaLimitationInfo=${expected_scaling_factor_fdd}
${expected_nrcell-12}    NRCELL-12:rgRacMinQuotaLimitationInfo=${expected_scaling_factor_fdd}


${new_expected_scaling_factor_tdd}    SEPARATOR=
...    [Scaling factor] = 0.129; [Multicell group type]: L1POOL_SR;[Resource type]: UeContxt;
${new_expected_scaling_factor_fdd}    SEPARATOR=
...    [Scaling factor] = 0.645; [Multicell group type]: L1POOL_SR;[Resource type]: UeContxt;
${new_expected_nrcell-2}    NRCELL-2:rgRacMinQuotaLimitationInfo=${new_expected_scaling_factor_tdd}
${new_expected_nrcell-12}    NRCELL-12:rgRacMinQuotaLimitationInfo=${new_expected_scaling_factor_fdd}

${NRRRD_RRC_SETUP_FAIL}    M55127C00010
${NRRCD_RRC_STPREQ_MO_SIGNALLING}    M55127C00001

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

@{FM_COUNTER_OF_SLICE_AB5_04}
...    ${NRRRD_RRC_SETUP_FAIL}=3
...    ${NRRCD_RRC_STPREQ_MO_SIGNALLING}=20
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-1/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>3
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

@{FM_COUNTER_OF_SLICE_AB9_01}
...    ${NRRRD_RRC_SETUP_FAIL}=2
...    ${NRRCD_RRC_STPREQ_MO_SIGNALLING}=77
...    NRCELL-11/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-11/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>3
...    NRCELL-11/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-11/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-11/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}>=300
...    NRCELL-11/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-11/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>3
...    NRCELL-11/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=11
...    NRCELL-11/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=19
...    NRCELL-11/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=11
...    NRCELL-11/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=19
...    NRCELL-11/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=12
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=20
...    NRCELL-11/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=11
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=19
...    NRCELL-11/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=12
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=20
...    NRCELL-11/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=11
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=19
...    NRCELL-11/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-3:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-3:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

*** Test Cases ***
CB008195-A-B5_ET_04_01_SA UE context admission dynamic cell limits check interwork with maxNumPucchF1SRPerSlotL1Pool
    [Documentation]
    ...    1. TThe test scenario is intended to verify SA UE context admission dynamic cell limits check interwork with maxNumPucchF1SRPerSlotL1Pool.
    ...    2. Configuretion:
    ...        Three Active FDD Cells in L1pool, NRCELL-11 and NRCELL-12 are 8195 enabled, NRCELL-13 is 8195 disabled.
    ...        Three active TDD in L1pool, NRCELL-1 and NRCELL-1 are 8195 enabled, NRCELL-3 is 8195 disabled.
    ...        For NRCLL-1:availableAreaCapacityL1Pool=32, minquota=[3,3,7], max_quota=[55,220,275],
    ...            scalingFactorTDD=0.068 maxNumOfUsersPerNRCell = 275, guaranteedResourceRatioPerCell=5
    ...            srPeriodicity=slot80 maxNumPucchF1SRPerSlotL1Pool=1 UplinkShareTDD=0.2
    ...        max number of UEs belongs to NRCELL-1 and NRCELL-2:
    ...            nodrb: 32-sum(3+3+7)-1=18 18/2=9 UE
    ...            slice1: 32-sum(3+3+7)-1-sum(3+7)=8, min(8,55)=8 8/2=4 UE
    ...            slice2: 32-sum(3+3+7)-1-sum(3+7)=8, min(8,220)=8 8/2=4 UE
    ...            slice3: 32-sum(3+3+7)-1-sum(3+3)=12, min(12,275)=12 12/2=6UE
    ...              ...
    ...        For NRCELL-11: availableAreaCapacityL1Pool=160, minquota=[18,18,37], max_quota=[55,220,275],
    ...           scalingFactorFDD=0.341 maxNumOfUsersPerNRCell = 275, guaranteedResourceRatioPerCell=5
    ...           srPeriodicity=slot80 maxNumPucchF1SRPerSlotL1Pool=1 UplinkShareTDD=1
    ...    3. Test Case Steps:
    ...        3.1. Register 10 UEs to NRCELL-1, only the 10th UE RAC failed. maxNumberOfUE supported by L2POOL for NRCELL-1:
    ...            32-sum(3+3+7)=19 19/2=9UE
    ...        3.2. Register 7UEs to NRCELL-2, only the 7th UE RAC failed. maxNumberOfUE supported by L2POOL for NRCELL-2:
    ...             32-9*2-1=13 13/2=6UE
    ...        c. Create PDU session to all UEs belongs to NRCELL-1.
    ...            slice1: create pdu for 4 UEs in step3.1, the 5th will be failed: 32-sum(3+3+7)-1-sum(3+7)=8, min(8,55)=8 4UE
    ...            slice2: create pdu for 4 UEs in step3.1, the 5th will be failed. 32-sum(3+3+7)-1-8-7=3, min(3,55)=7, 1 UE
    ...            slice3: create pdu for 8 UEs in step3.1, the 8th will be failed. 32-sum(3+3+7)-1-8-max(3,1*2)=7, min(7,55)=7, 3 UE
    [Tags]    c1    crt-true
    Lock_X2Link_to_let_gnb_Performed_as_SA
    Clear Counter Files
    reach the maxNum of ueContext of with nodrb on NRCELL-1 and NRCELL-2 one by one
    reach the maxnum of ueContext of with slice1 and slice3 on NRCELL-1 one by one
    Check Counters    ${FM_COUNTER_OF_SLICE_AB5_04}
    Deregister all Ues From gNB

CB008195-A-B9_ET_01_01_Slice-Aware Admission Control without active users then initial SA RRC connection admission
    [Documentation]
    ...    1. TThe test scenario is intended to verify SA UE context admission dynamic cell limits check interwork with maxNumPucchF1SRPerSlotL1Pool.
    ...    2. Configuration
    ...        Three Active FDD Cells in L1pool, NRCELL-11 and NRCELL-12 are 8195 enabled, NRCELL-13 is 8195 disabled.
    ...        Three active TDD in L1pool, NRCELL-1 and NRCELL-1 are 8195 enabled, NRCELL-3 is 8195 disabled.
    ...        For NRCELL-1: availableAreaCapacityL1Pool=32, minquota=[3,3,7], max_quota=[55,220,275], cellGuaranteeResources=1
    ...            scalingFactorTDD=0.068, scalingFactorFDD=0.341 maxNumOfUsersPerNRCell = 275, guaranteedResourceRatioPerCell=5
    ...            srPeriodicity=slot80 maxNumPucchF1SRPerSlotL1Pool=1 UplinkShareTDD=0.2
    ...        For NRCELL-11: availableAreaCapacityL1Pool=160, minquota=[18,18,37], max_quota=[55,220,275], cellGuaranteeResources=9
    ...           scalingFactorTDD=0.068, scalingFactorFDD=0.341 maxNumOfUsersPerNRCell = 275, guaranteedResourceRatioPerCell=5
    ...           srPeriodicity=slot80 maxNumPucchF1SRPerSlotL1Pool=1 UplinkShareTDD=1
    ...    3. Test Case Steps:
    ...        3.1. Register 40 UEs to NRCELL-11, only the 40th UE RAC failed. maxNumberOfUE supported by L2POOL for NRCELL-11:
    ...            160-(18+18+37)-9=78 78/2=39UE,36 UEs use dedicated resources and 3 UEs use commonpool resource, and no common resource left.
    ...        3.2. Register 37 UEs to NRCELL-12, only the 37th UE RAC failed. maxNumberOfUE supported by L2POOL for NRCELL-12:
    ...             160-9-39*2=73 73/2=36UE, 36 UEs use dedicated resources.
    ...        c. Create PDU session to all UEs belongs to NRCELL-11. the max number of uecontext of slice1 to slice3 are
    ...            slice1: create pdu for 12 UEs in step3.1, the 12th will be failed: 160-sum(18+18+37)-9-sum(18+37)=23, 11 UE
    ...                    9 UEs use dedicate resource for RG1, 2 UEs use common resource for RG1, and 1 common resource is left.
    ...            #slice2: create pdu for 4 UEs in step3.1, the 5th will be failed. 160-sum(18+18+37)-9-11*2-37=19, 9UE
    ...            #        9 UEs use dedicate resource for RG2, no UE can use common resource for RG1 because of 1 common resource is not enough.
    ...            slice3: create pdu for 20 UEs in step3.1, the 20th will be failed. 160-sum(18+18+37)-9-11*2-18=38, 19UE
    ...                    18 UEs use dedicate resource for RG3, 1 dedicate resource and 1 common resource is usd for the 19th UE.

    [Tags]    c2    cit-true
    Checking the scalingFactor will be changed by Cell lock and Unlock
    Clear Counter Files
    reach the maxNum of ueContext of with nodrb on NRCELL-11 and NRCELL-22 one by one
    reach the maxnum of ueContext of with slice1 and slice3 on NRCELL-11 one by one
    Check Counters    ${FM_COUNTER_OF_SLICE_AB9_01}
#    Deregister all Ues From gNB

*** Keywords ***
Lock_X2Link_to_let_gnb_Performed_as_SA
    Execute Egate Command    link_lock link=x2 at=enb:1 to=gnb:2    locked

Deregister all Ues From gNB
    ${active_ue_list}    get_active_ue
    FOR    ${ue_id}    IN    @{active_ue_list}
        UE Deregister From gNB    ${ue_id}
	END

Checking the scalingFactor will be changed by Cell lock and Unlock
    Checking the scalingFactor before NRCELL-1 and NRCELL-11 locked
    Lock Cell1
    Lock Cell11
    Checking the scalingFactor after NRCELL-1 and NRCELL-11 locked
    Unlock Cell1
    Unlock Cell11
    Checking the scalingFactor before NRCELL-1 and NRCELL-11 locked

Checking the scalingFactor before NRCELL-1 and NRCELL-11 locked
    Object Should Exist    ${expected_nrcell-1}    timeout=10
    Object Should Exist    ${expected_nrcell-2}    timeout=10
    Object Should Exist    ${expected_nrcell-11}    timeout=10
    Object Should Exist    ${expected_nrcell-12}    timeout=10

Checking the scalingFactor after NRCELL-1 and NRCELL-11 locked
    Object Should Exist    ${new_expected_nrcell-2}     timeout=10
    Object Should Exist    ${new_expected_nrcell-12}    timeout=10

reach the maxNum of ueContext of with nodrb on NRCELL-1 and NRCELL-2 one by one
    [Documentation]
    ...    steps: 1. Create 10 UEs on NRCELL-1, verify only the 10th UE RAC failed.
    ...           2. Create 6 UEs on NRCELL-2, verify only the 6th UE RAC failed.
    SA UEs Register to NRCELL    ueid_start=1    ueid_end=10    cell_id=1
    Register One UE to NRCELL failed    ue_id=10    cell_id=1
    SA UEs Register to NRCELL    ueid_start=11    ueid_end=17    cell_id=2
    Register One UE to NRCELL failed    ue_id=17    cell_id=1

reach the maxNum of ueContext of with nodrb on NRCELL-11 and NRCELL-22 one by one
    [Documentation]
    ...    steps: 1. Create 44 UEs on NRCELL-11, verify only the 44th UE RAC failed.
    ...           2. Create 33 UEs on NRCELL-12, verify only the 33th UE RAC failed.
    SA UEs Register to NRCELL    ueid_start=1    ueid_end=31    cell_id=11
    SA UEs Register to NRCELL    ueid_start=101    ueid_end=110    cell_id=11
    Register One UE to NRCELL failed    ue_id=110    cell_id=11
    SA UEs Register to NRCELL    ueid_start=111    ueid_end=147    cell_id=12
    Register One UE to NRCELL failed    ue_id=147    cell_id=12

reach the maxnum of ueContext of with slice1 and slice3 on NRCELL-1 one by one
    Create Default PDU sessions for UEs    ueid_start=1    ueid_end=5    nwslice=1
    Create Default PDU sessions for UEs failed    ueid_start=5    ueid_end=6    nwslice=1
    recovery ue to RRC created status    ue_id=5    cell_id=1
    Create Default PDU sessions for UEs    ueid_start=5    ueid_end=8    nwslice=3
    Register One UE to NRCELL failed    ue_id=20    cell_id=1

reach the maxnum of ueContext of with slice1 and slice3 on NRCELL-11 one by one
    Create Default PDU sessions for UEs    ueid_start=1    ueid_end=12    nwslice=1
    Create Default PDU sessions for UEs failed    ueid_start=12    ueid_end=13    nwslice=1
    Create Default PDU sessions for UEs    ueid_start=13    ueid_end=31    nwslice=3
    Create Default PDU sessions for UEs    ueid_start=101    ueid_end=102    nwslice=3
    Create Default PDU sessions for UEs failed    ueid_start=103    ueid_end=104    nwslice=3

recovery ue to RRC created status
    [Arguments]    ${ue_id}    ${cell_id}
    UE Deregister From gNB    ${ue_id}
    Register For Normal Call Successfully    ${ue_id}    ${cell_id}

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

Create Default PDU sessions for UEs
    [Arguments]    ${ueid_start}=1    ${ueid_end}=1    ${nwslice}=1
    FOR    ${ue_id}    IN RANGE    ${ueid_start}    ${ueid_end}
        sa ue register and pdu setup    ue_id=${ue_id}    nwslice=${nwslice}
	END

Create Default PDU sessions for UEs failed
    [Arguments]    ${ueid_start}=1    ${ueid_end}=1    ${nwslice}=1
    FOR    ${ue_id}    IN RANGE    ${ueid_start}    ${ueid_end}
        Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=${nwslice} gw=${ue_id}    resources not available    timeout=5s
	END

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=${nwslice} gw=${ue_id}    QoS Routing Table

SA UEs Register to NRCELL
    [Arguments]    ${ueid_start}=1    ${ueid_end}=1    ${cell_id}=1
    FOR    ${ue_id}    IN RANGE    ${ueid_start}    ${ueid_end}
        Register One UE to NRCELL    ue_id=${ue_id}    cell_id=${cell_id}
	END

Register One UE to NRCELL
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=NG RM Registered

Register One UE to NRCELL failed
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2    ${pass_regexp}=rrcReject
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=${pass_regexp}    timeout=5s
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
    Add more number of gateway    gatewayid_start=101    gatewayid_end=150

Add more number of gateway
    [Arguments]    ${gatewayid_start}    ${gatewayid_end}
    FOR    ${gatewayID}    IN RANGE    ${gatewayid_start}    ${gatewayid_end}
        Update Cfg     set_pdu_gateway id=${gatewayID} ue_nat_ip=72.23.${gatewayID}.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
	END


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

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10
