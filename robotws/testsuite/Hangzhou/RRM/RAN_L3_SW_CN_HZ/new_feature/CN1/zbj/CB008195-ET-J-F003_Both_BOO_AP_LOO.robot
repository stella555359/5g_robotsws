*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-VRF3_7    owner-zhubajie
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008195    release-25R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=11    maxNumPucchF1SRPerSlotL1Pool=30    maxNumPucchF3PCSIPerSlotL1Pool=30

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}
...    @{NRREL}
...    @{CA_enable}
...    @{ho}
...    @{RANsharing}
...    @{PLMN}
...    @{CB008195}
...    @{limit_cell_maxNum}
...    @{limit_group_maxNum}
...    @{BBPooling}
...    @{NRRESOURCEGROUP_PROFILE}

@{BBPooling}
...    NRBTS:actConnRrcPooling=true    NRBTS:actScheUePooling=true
...    @{CB008847}

@{CB008847}
...    NRBTS:actBbPoolTddFr1=true
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:actBbPoolTddFr1AlgEnh=true
...    NRBTS:actBbPoolTddFr1Enh=true

@{CB008195}
...    NRBTS-1:actRrcInactState=none
...    MRBTS-1/NRBTS-1:rgMinQuotaReservationLevel=cell_and_multicell_level
...    MRBTS-1/NRBTS-1:drbRrcInactInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:maxUeRrcInactTime=90
...    MRBTS-1/NRBTS-1:gNbCuType=SA+NSA
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrCellUtilPerNrg=5min
...    MRBTS-1/NRBTS-1:actSliceAwareAdmissionCtrl=true
...    MRBTS-1/NRBTS-1:actDrbPreemption=false
...    MRBTS-1/NRBTS-1:actUserPreemption=false
...    MRBTS-1/NRBTS-1:actConnRrcPooling=true
...    MRBTS-1/NRBTS-1:actScheUePooling=true
...    NRBTS-1/NRCELL-1:sliceAwareAdmissionCtrlEnabled=false
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=false
...    NRBTS-1/NRCELL-11:sliceAwareAdmissionCtrlEnabled=false
...    NRBTS-1/NRCELL-1:actPriorityAccess=false
...    NRBTS-1/NRCELL-2:actPriorityAccess=false
...    NRBTS-1/NRCELL-1:actEmergencyCall=false
...    NRBTS-1/NRCELL-2:actEmergencyCall=false
...    NRCELL:numOfRadioResReservForTempUse=0
...    NRCELL:numOfRadioResReservForEmergency=0
...    NRCELL:numOfRadioResReservForPa=0

...    NRBTS-1/NRCELL-11:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1
...    NRBTS-1/NRCELL-2:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1
...    NRBTS-1/NRCELL-1:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-2

...    NRBTS/NRPMRNL-1:miNrCABMCCP=disabled

@{NRRESOURCEGROUP_PROFILE}
#NRRESOURCEGROUP_PROFILE-1 - PLMN1 PLMN2 PLMN3
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=5
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
#...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2
#...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3|nrResourceGroupId=1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=26
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=0
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=74
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=24
#...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:nrResourceList:resourceDN=SNSSAI-3|resourceDN=SNSSAI-3
#...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:maxQuota=74
#...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:minQuota=24
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:nrResourceGroupProfileId=1

#NRRESOURCEGROUP_PROFILE-2 - PLMN1 PLMN2 PLMN3
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=5
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
#...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2
#...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-3|nrResourceGroupId=1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=76
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=75
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=24
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=14
#...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:nrResourceList:resourceDN=SNSSAI-3|resourceDN=SNSSAI-3
#...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:racParams:maxQuota=24
#...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:racParams:minQuota=14
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:nrResourceGroupProfileId=2

@{RANsharing}
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRBTS:actTrsSepaSARanSharing=true
...    NRBTS:ngCplane:ngTnlId=1
...    NRBTS:ngUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS:xnCplane:xnTnlId=1
...    NRBTS:xnUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL:configuredEpsTac=${EMPTY}
...    NRCELL:ranAC=${EMPTY}
...    NRCELL:trackingAreaDN=${EMPTY}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-1:ranAC=0
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL/NRPLMNSET_SA-2:ranAC=0
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRBTS/SERVEDAMF-1:ngTnlId=1
...    NRBTS/XNLINK-1:xnTnlId=1
...    @{SNSSAI}
...    @{TRACKINGAREA}

@{SNSSAI}
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-1:sd=13714341
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
#...    NRBTS-1/SNSSAI-3:sst=1
#...    NRBTS-1/SNSSAI-3:sd=13714343
#...    NRBTS-1/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
#...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3

@{PLMN}
...    MRBTS-1/NRBTS-1/NRPLMN-1:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-1:mnc=489
...    MRBTS-1/NRBTS-1/NRPLMN-1:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=500
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
#...    MRBTS-1/NRBTS-1/NRPLMN-3:mcc=460
#...    MRBTS-1/NRBTS-1/NRPLMN-3:mnc=2
#...    MRBTS-1/NRBTS-1/NRPLMN-3:mncLength=3

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:sCellPrio=1
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=13
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellPrio=2
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=35
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=1
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:lcrId=2
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:sCellPrio=1
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=200
...    NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=524310
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3

@{CA_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actHoOptimizationCa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:actRanSharing=false
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actBeamforming=false
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:cellDepType=SA+NSA

...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2ThresholdSCellRelSsbRsrp=34|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=60
...    NRCELL-13:weightForSCellSelection=60
...    NRCELL-1:weightForSCellSelection=80
...    NRCELL-2:weightForSCellSelection=80
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=524310
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=6549
...    MRBTS-1/NRBTS-1/NRCELL-1:type0CoresetConfigurationIndex=10
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13:type0CoresetConfigurationIndex=7
...    MRBTS-1/NRBTS-1/NRCELL-13:gscnOrSsPbchArfcn=5300

@{ho}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min

@{limit_cell_maxNum}
...    NRCELL:maxNumOfRrcSA=10
...    NRCELL:maxNumOfUsersPerNRCell=10
...    NRCELL:maxNumOfUsersPerCell=10
...    NRCELL:maxNumOfCaUsersNRCell=10
...    NRCELL:maxNumOfNrDcSnUsers=10
...    NRCELL:maxNumOfSCellAlloc=10

@{limit_group_maxNum}
...    NRBTS/NRCELLGRP-3:maxNumOfUsers=50
...    NRBTS/NRCELLGRP-4:maxNumOfUsers=50
#...    NRBTS-1/NRCELLGRP-3:maxNumOfNonGBRBearers=10
#...    NRBTS-1/NRCELLGRP-4:maxNumOfNonGBRBearers=10
...    MRBTS/NRBTS/NRDU-1:maxNumOfRrcConUEsPerDU=20

@{OnlineParamChange_B016}
...    NRBTS-1:actIntraNrNgHo=sourceAndTarget
...    NRBTS-1:tNgRelocExecDeltN=3000
...    NRBTS-1:tNgRelocPrepN=2000
...    NRBTS-1:tNgRelocOverallN=2000
...    NRBTS-1:tNgRelocCancelN =2000
...    NRCELL-1/NRREL-2:handoverAllowedSA=XnHoNotAllowed

@{Result_F001}
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:1
...    SCellIndex 1 activated successfully

@{Expect_Failed_Result_F001}
...    rrcReconfigurationComplete

${pdu_id}    1
${gw_id}    1

@{Online_Param_1}
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=4
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=4
...    NRBTS-1/NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-11:sliceAwareAdmissionCtrlEnabled=true

@{Online_Param_2}
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=6
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=6
...    NRBTS-1/NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-11:sliceAwareAdmissionCtrlEnabled=true

@{Online_Param_3}
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=5
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=5
...    NRBTS-1/NRCELL-1:sliceAwareAdmissionCtrlEnabled=false
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=false
...    NRBTS-1/NRCELL-11:sliceAwareAdmissionCtrlEnabled=false

@{Online_Param_4}
...    delete:NRBTS-1/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits
...    delete:NRBTS-1/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits

@{PM_Counters_Check_ET_F03}
...    NRCELL-11/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-11/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>0
...    NRCELL-11/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-11/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}>=2
...    NRCELL-11/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}>=2
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=2
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=2
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=2
...    NRCELL-11/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}>=2
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}>=1
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}>=1
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

@{PM_Counters_Check_ET_F03_J}
...    NRCELL-11/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>0
...    NRCELL-11/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-11/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}>=2
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=2
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=2
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-11/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-1/NRRESOURCEGROUP-2:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}>=1
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=1
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    NRCELL-2/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0

#Counter
${AVG_NUM_UE_NOM_NRG}    M55910C00005
${DNOM_SAMPLES_NRG}    M55910C00006
${AVE_NUM_NGBR_NOM_NRG}    M55910C00007
${PEAK_NUM_UE_NRG}    M55910C00010
${PEAK_NUM_NGBR_NRG}    M55910C00011
${NUM_ADM_REQ_NGBR_NRG}    M55910C00017
${NUM_ADM_SUC_NGBR_NRG}    M55910C00018
${NUM_ADM_REQ_UE_NRG}    M55910C00023
${NUM_ADM_SUC_UE_NRG}    M55910C00024
${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}    M55910C00015
${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}    M55910C00016

*** Test Cases ***
CB008195-F-ET_003_Verify succesful intra-gNB SCell Addition if m-cell pooled resource limits check resources are assigned within dedicated pool
    [Documentation]
    ...    The test scenario is intended to verify This user scenario describes gNB behavior with Slice Aware Admission Control enabled
    ...    when SCell(s) addition form the same gNB is requested and all resources required for CA can be allocated.
    ...    Test Case Setings:
    ...    Vendor parameters update: maxNumOfUserL2Pool=11    maxNumPucchF1SRPerSlotL1Pool=30    maxNumPucchF3PCSIPerSlotL1Pool=30
    ...    NRCELL:maxNumOfCaUsersNRCell=10
    ...    NRBTS-1/NRCELL-11:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1
    ...    NRBTS-1/NRCELL-2:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1
    ...    NRBTS-1/NRCELL-1:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-2
    ...    ================================================================================================================
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=26    # 26%*10 = 2.6, max 2 UE,  common pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=0     # 0*10 = 0, max 0 UE,  dedicated pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=74    # 74%*10 = 7.4, max 7 UE,  common pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=24    # 24%*10 = 2.4, max 2 UE,  dedicated pool
    ...    =================================================================================================================
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=76     # 76%*10 = 7.6, max 7 UE,  common pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=75     # 75%*10 = 7.5, max 7 UE,  dedicated pool
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=24     # 24%*10 = 2.4, max 2 UE,  common pool.
    ...    NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=14     # 14%*10 = 1.4, max 1 UE,  dedicated pool.
    ...    ==================================================================================================================s
    [Tags]    QC_****    F003
    Clear Counter files
    UE Attach To Target Cell    ue_id=81    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=83    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=82    nwslice=1    cell_id=2
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=81    srsrp_nr=91    scell_id=1
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=83    srsrp_nr=91    scell_id=1
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_F03_J}
    Release UEs    ue_type=all
    Delta Commission Parameters    ${Online_Param_1}
    Clear Counter files
    UE Attach To Target Cell    ue_id=81    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=83    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=82    nwslice=1    cell_id=2
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=81    srsrp_nr=91    scell_id=1
    Trigger ScellAdd or ScellChange and expect failed    ${Expect_Failed_Result_F001}    ue_id=83    srsrp_nr=91
    Release Ues    ue_id=82
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=83    srsrp_nr=91    scell_id=1
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_F03}
    Release UEs    ue_type=all
    Delta Commission Parameters    ${Online_Param_2}
    Clear Counter files
    UE Attach To Target Cell    ue_id=81    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=83    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=82    nwslice=1    cell_id=2
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=81    srsrp_nr=91    scell_id=1
    Trigger ScellAdd or ScellChange and expect failed    ${Expect_Failed_Result_F001}    ue_id=83    srsrp_nr=91
    Release Ues    ue_id=82
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=83    srsrp_nr=91    scell_id=1
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_F03}
    Release UEs    ue_type=all
    Delta Commission Parameters    ${Online_Param_3}
    Clear Counter files
    UE Attach To Target Cell    ue_id=81    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=83    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=82    nwslice=1    cell_id=2
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=81    srsrp_nr=91    scell_id=1
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=83    srsrp_nr=91    scell_id=1
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_F03_J}
    Release UEs    ue_type=all
    Delta Commission Parameters    ${Online_Param_4}
    Clear Counter files
    UE Attach To Target Cell    ue_id=81    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=83    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=82    nwslice=1    cell_id=2
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=81    srsrp_nr=91    scell_id=1
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=83    srsrp_nr=91    scell_id=1
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_F03_J}
    Release UEs    ue_type=all
    Delta Commission Parameters    ${Online_Param_1}
    Clear Counter files
    UE Attach To Target Cell    ue_id=81    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=83    nwslice=2    cell_id=11
    UE Attach To Target Cell    ue_id=82    nwslice=1    cell_id=2
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=81    srsrp_nr=91    scell_id=1
    Trigger ScellAdd or ScellChange and expect failed    ${Expect_Failed_Result_F001}    ue_id=83    srsrp_nr=91
    Release Ues    ue_id=82
    Trigger ScellAdd or ScellChange    ${Result_F001}    ue_id=83    srsrp_nr=91    scell_id=1
    Check Counters    pm_counters_expression=${PM_Counters_Check_ET_F03}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    ${gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=524310:524310 gscn=6549 mandatory_for_activation=off
   Update Cfg    ${gnb3_cell1}
   Update Cfg    set_amf_region id=1 tac_list=0,200,300 plmn=311:489,311:500
   Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=all amf_region_id=1 plmn_list=311:489,311:500
   Update Cfg    set_nwslice id=2 snssai=0x01:13714342 ue=all amf_region_id=1 plmn_list=311:489,311:500
   Update Cfg    set_nwslice id=3 snssai=0x01:13714343 ue=all amf_region_id=1 plmn_list=311:489,311:500

Set UE Parameters Before Register
    [Arguments]    ${send_xn_setup}=true    ${ho_type}=xn_based
    Execute Egate Command    ue_history_information_list id=1 action=reset
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=81 ue_history_list=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=${send_xn_setup} sa_ho=${ho_type}
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    #build XN setup
    Execute Egate Command    ue_gnb_param id=81 candidate_cells_hex_for_interrat_ho=0B1FFAB95F571630684325A3C7

UE Attach To Target Cell
    [Arguments]    ${cell_id}=1    ${ue_id}=81    ${pcell_dl}=0    ${nwslice}=3
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    Should Contain    ${ret1}    drx-Config setup
    Send Throuput    ue_id=${ue_id}
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=0
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=10    ${ul}=0    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd or ScellChange
    [Arguments]    ${Result}    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=80    ${srsrq_nr}=50    ${ue_id}=81
    ...    ${pcell_dl}=0    ${scell_dl}=0    ${scell_id}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${Result}
    Verify Throuput on Pcell and Scell    pcell_dl=${pcell_dl}    scell_dl=${scell_dl}    scell_id=${scell_id}

Trigger ScellAdd or ScellChange and expect failed
    [Arguments]    ${expected_failed_result}    ${event_type}=A1    ${carrierfreq}=424090    ${srsrp_nr}=80    ${srsrq_nr}=50    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=${expected_failed_result}

trigger A2 Scell Release
    [Arguments]    ${event_type}=A2    ${carrierfreq}=633216    ${srsrp_nr}=7    ${srsrq_nr}=7    ${ue_id}=81    ${scell_id}=2
    ...    ${pcell_dl}=610
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} scell=${scell_id}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}






