*** Settings ***
Documentation
...    author:  keyun.ma@nokia-sbell.com
...    contact: keyun.ma@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_Aic    RAN_5G    CRT    team-VRF3T7    owner-kema    release-25R3
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    master_vDU    vDUCNF00
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T

@{PARAMS_IN_SCF_CU}    @{meas_Config_cell1}    @{NRREL}    @{A3_event}    @{SRB3}    @{BBPooling}    @{PLMN}
...    @{RANsharing}    @{nsaDrbParam}    @{CB008195_CU}    @{CB008195}    @{TAC}    @{other_resource_reserve}
...    @{limit_maxNumOfRrcSA}    @{limit_maxNumOfUsersPerNRCell}    @{cellDepType}
...    @{limit_maxNumOfNonGBRBearers_CU}    @{gnbCutyp_NSA_only}
...    NRBTS:actNgcFlexSaMode=false
...    NRCELL:actRrcReconfProcessingDelay=false
...    NRCELL-2:maxNumOfNonGBRBearersSA=8
...    NRBTS/NRCELLGRP-1:maxNumOfRrcCGRPSA=9
...    NRBTS/NRCELLGRP-2:maxNumOfRrcCGRPSA=9
...    NRDRB_QCI-5:qciValueList=8
...    NRDRB_QCI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRDRB_QCI-5:nrDrbQciId=5
...    NRDRB_QCI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    NRBTS:f1SetupTimeToWait=60s
...    NRBTS:actFullRrcConfNsaPscellChange=enforced
...    delete:NRCELL:a1MeashoEnabledSA
...    delete:NRCELL:a2MeashoEnabledSA
@{PARAMS_IN_SCF_DU1}     @{SSB}    @{CB008847}    @{BBPooling}    @{PLMN}    @{RANsharing}
...    @{cellDepType}    @{CB008195_DU1}    @{CB008195}    @{NRRESOURCEGROUP_PROFILE}    @{TAC}
...    @{limit_maxNumOfRrcSA}    @{limit_maxNumOfUsersPerNRCell}    @{limit_maxNumOfNonGBRBearers_DU1}
...    @{RANsharing_DU}    @{gnbCutyp_NSA_only}    @{other_resource_reserve}
...    MRBTS/NRBTS/NRDU-1:maxNumOfRrcConUEsPerDU=20
...    NRBTS:actScheUePooling=true
...    NRCELL:msg1FrequencyStart=18
...    delete:NRCELL:configuredEpsTac
...    NRBTS:actMultiDrbNSA=true
...    NRCELL:actShortBsrLimitAdaptation=true
...    NRCELL-1:maxNumOfNonGBRBearersSA=8
...    NRBTS/NRCELLGRP-1:maxNumOfRrcCGRPSA=9
...    NRCELL-1/NRREL-1:nrRelId=1
...    NRDRB_QCI-5:qciValueList=8
...    NRDRB_QCI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRDRB_QCI-5:nrDrbQciId=5
...    NRDRB_QCI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    NRCELL:actRrcReconfProcessingDelay=false
...    NRBTS:actFullRrcConfNsaPscellChange=enforced
...    NRCELL:maxNumPdschAllocationPerSlot=16
...    delete:NRCELL:pagingTargetRate
@{PARAMS_IN_SCF_DU2}    @{SSB}    @{CB008847}    @{BBPooling}    @{PLMN}    @{RANsharing}
...    @{cellDepType}   @{CB008195_DU2}    @{CB008195}    @{NRRESOURCEGROUP_PROFILE}    @{TAC}
...    @{limit_maxNumOfRrcSA}    @{limit_maxNumOfUsersPerNRCell}    @{limit_maxNumOfNonGBRBearers_DU2}
...    @{RANsharing_DU}    @{gnbCutyp_NSA_only}    @{other_resource_reserve}
...    MRBTS/NRBTS/NRDU-2:maxNumOfRrcConUEsPerDU=20
...    NRBTS:actScheUePooling=true
...    NRCELL:msg1FrequencyStart=18
...    delete:NRCELL:configuredEpsTac
...    NRBTS:actMultiDrbNSA=true
...    NRCELL:actShortBsrLimitAdaptation=true
...    NRCELL-2:maxNumOfNonGBRBearersSA=8
...    NRBTS/NRCELLGRP-2:maxNumOfRrcCGRPSA=9
...    NRBTS:actSlowPrbPooling=false
...    NRCELL-2/NRREL-1:nrRelId=1
...    NRDRB_QCI-5:qciValueList=8
...    NRDRB_QCI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRDRB_QCI-5:nrDrbQciId=5
...    NRDRB_QCI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    NRCELL:actRrcReconfProcessingDelay=false
...    NRBTS:actFullRrcConfNsaPscellChange=enforced
...    NRCELL:maxNumPdschAllocationPerSlot=16
...    delete:NRCELL:pagingTargetRate
@{limit_maxNumOfNonGBRBearers_DU1}
...    NRCELL:maxNumOfCaUsersNRCell=10
...    NRBTS/NRCELLGRP-1:maxNumOfUsers=10
...    NRBTS-1/NRCELLGRP-1:maxNumOfNonGBRBearers=20
...    NRBTS-1/NRCELLGRP-1:maxNumOfUsers=20
@{limit_maxNumOfNonGBRBearers_DU2}
...    NRCELL:maxNumOfCaUsersNRCell=10
...    NRBTS/NRCELLGRP-2:maxNumOfUsers=10
...    NRBTS-1/NRCELLGRP-2:maxNumOfNonGBRBearers=20
...    NRBTS-1/NRCELLGRP-2:maxNumOfUsers=20
@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{A3_event}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1

@{SRB3}
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=3
...    NRBTS-1:cipherPrefL:nea2_128=4
...    NRBTS-1:cipherPrefL:nea3_128=2
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=3
...    NRBTS-1:integrityProtPrefL:nia2_128=4
...    NRBTS-1:integrityProtPrefL:nia3_128=2

@{SSB}
...    NRCELL:cbraPreamblesPerSsb=n60
...    NRCELL:rsrpThresholdSSB=11

${ue_id}    11

${carrierfreq}    636576
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=12    maxNumOfDRBL2Pool=14    maxNumPucchF1SRPerSlotL1Pool=
...    maxNumPucchF3PCSIPerSlotL1Pool=30

@{meas_Config_cell1}
...    NRBTS:nsaInactivityTimer=600
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS-1/NRCELL:a3MeasEnabled=rsrp
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRBTS-1/NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
@{NRHOIF_CU}
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=NSA
...    NRCELL-1/NRHOIF-1:chBw=100MHz
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=19
...    NRCELL:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=19

...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=NSA
...    NRCELL-2/NRHOIF-1:chBw=100MHz
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms1024
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
@{NRHOIF_DU}
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=646656
@{BBPooling}
...    NRBTS:actConnRrcPooling=true


@{CB008847}
...    NRBTS:actBbPoolTddFr1=true
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:actBbPoolTddFr1AlgEnh=true
...    NRBTS:actBbPoolTddFr1Enh=true
...    NRBTS:actSACallProcessingDU=false
@{PLMN}
...    MRBTS-1/NRBTS-1/NRPLMN-1:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-1:mnc=489
...    MRBTS-1/NRBTS-1/NRPLMN-1:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=262
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=3
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-3:mcc=460
...    MRBTS-1/NRBTS-1/NRPLMN-3:mnc=2
...    MRBTS-1/NRBTS-1/NRPLMN-3:mncLength=3


@{RANsharing}
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

@{RANsharing_DU}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
@{gnbCutyp_NSA_only}
...    NRBTS:gNbCuType=NSA
...    delete:MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1

@{nsaDrbParam}
...    NRBTS:actMultiDrbNSA=true
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlPreferredPath=F1-U
...    NRBTS-1/NRDRB-10:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-10:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-10:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-10:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-10:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-10:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-10:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-10:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-10:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-10:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlPreferredPath=F1-U
...    NRBTS-1/NRDRB-11:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-11:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-11:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-11:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-11:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-11:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-11:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-11:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-11:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-11:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlPreferredPath=F1-U
...    NRBTS-1/NRDRB-12:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-12:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-12:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-12:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-12:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-12:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-12:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-12:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-12:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-12:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlPreferredPath=F1-U
...    NRBTS-1/NRDRB-13:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-13:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-13:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-13:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-13:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-13:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-13:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-13:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-13:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-13:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlPreferredPath=F1-U
...    NRBTS-1/NRDRB-14:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-14:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS-1/NRDRB-14:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-14:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-14:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-14:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-14:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-14:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-14:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-14:nsaDrbParam:ulDataSplitThreshold=infinity

@{cellDepType}
...    NRCELL:cellDepType=NSA
...    delete:NRCELL:ranAC
...    delete:NRCELL:trackingAreaDN



@{CB008195_DU1}
...    MRBTS/NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
...    NRBTS/NRPMRNL-1:miNrCellUtilPerPLMN=disabled
...    NRCELL-1:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-0
@{CB008195_DU2}
...    MRBTS/NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
...    NRBTS/NRPMRNL-1:miNrCellUtilPerPLMN=disabled
...    NRCELL-2:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
@{CB008195_CU}
...    NRCELL:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=true
@{CB008195}
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRBTS:actSpidBasedSlicingNSA=false
...    NRBTS:actSliceAwareScheduler=false
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRBTS/NRCELL:actPriorityAccess=false
...    NRBTS/NRCELL:actEmergencyCall=false
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=5min


@{NRRESOURCEGROUP_PROFILE}
#NRRESOURCEGROUP_PROFILE-0 - PLMN1 and PLMN2 and PLMN3
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:maxQuota=19
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:minQuota=14
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:racParams:maxQuota=80
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2:racParams:minQuota=15

#NRRESOURCEGROUP_PROFILE-1 - PLMN1 and PLMN2 and PLMN3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=70
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=15
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=85
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=20

##NRRESOURCEGROUP_PROFILE-2 - PLMN1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=80
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=20

#NRRESOURCEGROUP_PROFILE-3 - PLMN1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:bypassRgLimits=4
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:racParams:maxQuota=80
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:racParams:minQuota=30

@{TAC}
...    NRBTS/TRACKINGAREA-1:fiveGsTac=200
...    delete:TRACKINGAREA-1:snssaiList
...    delete:NRBTS/SNSSAI-1
@{other_resource_reserve}
...    NRCELL:actPriorityAccess=false
...    NRCELL:actEmergencyCall=false
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
#...    NRCELL:numOfRadioResReservForTempUse=30
...    NRCELL:numOfRadioResReservForTempUse=0
...    NRCELL:numOfRadioResReservForEmergency=0
...    NRCELL:numOfRadioResReservForPa=0

@{limit_maxNumOfRrcSA}
...    NRCELL:maxNumOfRrcSA=4



@{limit_maxNumOfUsersPerNRCell}
...    NRCELL:maxNumOfUsersPerNRCell=16
...    NRCELL:maxNumOfUsersPerCell=16

@{limit_maxNumOfNonGBRBearers_CU}
...    NRCELL:maxNumOfSCellAlloc=10
...    NRCELL:maxNumOfCaUsersNRCell=10
##supported UE Power Saving's releasePreference-r16
${ue_nr_capabilities}    SEPARATOR=
...    E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700CA8D851AC101434
...    04B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36266B04050D01
...    2CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89BAC10143404B
...    2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB
...    28986801EB608080838778E1C830E0008193C7D54000014000000420E26800000001013454000
...    3804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A5
...    5542C007000B00000004008011AB130001020304050607080B101112131921252627284A052880001080

${PLMN_1}    311:489
${PLMN_2}    262:003
${PLMN_3}    460:002

@{PM_Counters_Check_DU_I02}
...    NRCELL-1/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>0
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}>=2
...    NRCELL-1/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}>=3
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=9
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=5
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=3
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=4
...    NRCELL-1/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0


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
@{PM_Counters_Check_CU}
...    NRCELL-1:NX2CC:${HO_PREP_SUC_FCNF_TRG_NSA_IEDU}=0
...    NRCELL-2:NX2CC:${HO_PREP_SUC_FCNF_TRG_NSA_IEDU}=1
...    NRCELL-1:NX2CC:${RRC_RECNFCMP_FCNF_TRG_NSA_IEDU}=0
...    NRCELL-2:NX2CC:${RRC_RECNFCMP_FCNF_TRG_NSA_IEDU}=1
...    NRCELL-1:NINFC:${INT_FR_PSCEL_CHA_ATT_SRB3}=1
...    NRCELL-2:NINFC:${INT_FR_PSCEL_CHA_ATT_SRB3}=0
...    NRCELL-1:NINFC:${TRA_FR_PSCEL_CH_ATTEMPT}=0
...    NRCELL-2:NINFC:${TRA_FR_PSCEL_CH_ATTEMPT}=0
${HO_PREP_SUC_FCNF_TRG_NSA_IEDU}    M55112C00039
${RRC_RECNFCMP_FCNF_TRG_NSA_IEDU}    M55112C00040
${INT_FR_PSCEL_CHA_ATT_SRB3}    M55120C00501
${TRA_FR_PSCEL_CH_ATTEMPT}    M55120C00001
*** Test Cases ***
CB013452-I_02_Verify Unsuccessful PSCell addition Since NSA non-GBR DRB RAC cell limits check Failure
    [Documentation]
    ...    1. Verify Cloud NSA TDD cmWave Intra-freq inter-DU handover with A3-RSRP-SRB3-CFRA is unsuccessful
    [Tags]
    Clear Counter Files Cu Aic    ${False}
    Clear Counter Files Du Aic    ${False}
    NSA UE attach    ue_id=12    selected_plmn=${PLMN_1}    tcell=1    bid=2
    NSA UE attach    ue_id=11    selected_plmn=${PLMN_1}    tcell=1    bid=2,3
    Add one more non-GBR DRB and expect failed
    Execute Egate Command    ue_detach id=11
    NSA UE attach    ue_id=11    selected_plmn=${PLMN_1}    tcell=1    bid=2,3
    UE tigger Intra-gnb inter-DU HO from CELL1 to CELL2
    Add one more non-GBR DRB and expect succeed
    UE tigger Intra-gnb inter-DU HO from CELL2 to CELL1
    Check Counters Du Aic    ${PM_Counters_Check_DU_I02}
    Check Counters Cu Aic    ${PM_Counters_Check_CU}

*** Keywords ***
Modify Cfg Aic
    Set PDU Session in WTS
    Set AMF config
    Set UE config
    Set Bearer

Set Bearer
    Update Cfg Aic    set_bearer id=3 ue=11 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    Update Cfg Aic    set_bearer id=4 ue=11 qci=7 pdn=1
    Update Cfg Aic    set_bearer id=3 ue=12 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    Update Cfg Aic    set_bearer id=3 ue=13 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    Update Cfg Aic    enb_param id=1 drb_id_begin=3 endc_capable_qci=all

Set AMF config
    Update Cfg Aic    set_amf_region id=1 tac_list=100,200,300 plmn=311:489
    Update Cfg Aic    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg Aic    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2 name=SimModeAMF1
    ${amf}    catenate    amf_ng_setup_param id=1 relative_capacity=10 include_backup_amf_name=on
    ...    ue_retention=on retention_time=indefinite
    Update Cfg Aic    ${amf}
    ${nwslice}    catenate     set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on qos_flows=7,6,5,4,3,2,1
    ...    qos_rules=1,2 ue=all
    Update Cfg Aic    ${nwslice}
    Update Cfg Aic    set_nwslice id=2 snssai=0x01:0xd143a6 amf=1 qos_flows=7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg Aic    set_nwslice id=3 snssai=0x01:0xd143a7 amf=1 qos_flows=7,6,5,4,3,2,1 qos_rules=1,2 ue=all

Set PDU Session in WTS
    Update Cfg Aic    set_qosflow id=1 5qi=1 priority=1 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg Aic    set_qosflow id=2 5qi=2 priority=2 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg Aic    set_qosflow id=3 5qi=3 priority=3 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg Aic    set_qosflow id=4 5qi=4 priority=4 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg Aic    set_qosflow id=5 5qi=5 default=on priority=5 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg Aic    set_qosflow id=6 5qi=6 priority=6 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg Aic    set_qosflow id=7 5qi=7 priority=7 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg Aic    qosrule_set id=1 proto=tcp qos_flow=1
    Update Cfg Aic    qosrule_set id=2 proto=udp qos_flow=2

Set UE config
    ${set_ue11}    catenate    set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=${PLMN_3}:21645400
    ${set_ue12}    catenate    set_ue simulated id=12 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=${PLMN_3}:21645401
    ${set_ue13}    catenate    set_ue simulated id=13 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=${PLMN_2}:21645402
    ${set_ue14}    catenate    set_ue simulated id=14 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=${PLMN_2}:21645403
    ${set_ue15}    catenate    set_ue simulated id=15 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=${PLMN_2}:21645404
    Update Cfg Aic    ${set_ue11}
    Update Cfg Aic    ${set_ue12}
    Update Cfg Aic    ${set_ue13}
    Update Cfg Aic    ${set_ue14}
    Update Cfg Aic    ${set_ue15}

NSA UE attach
    [Arguments]  ${ue_id}=11    ${selected_plmn}=311:489    ${tcell}=1    ${bid}=2
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${tcell} bearer=${bid} type=split_scg
    ...    UE${ue_id}: Proxy \\(eNB 2 cell ${tcell}\\) reported successful RA
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5 trf_id=1    UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5 trf_id=2    UDP DL


Add one more non-GBR DRB and expect failed
    [Arguments]  ${ue_id}=11
    Execute Egate Command    bearer_add ue=${ue_id} id=4 filter=0 precedence=0    PGW-initiated Bearer Creation
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=4 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
	...    SgNBModificationRequestReject    timeout=300
Add one more non-GBR DRB and expect succeed
    [Arguments]  ${ue_id}=11
    Execute Egate Command    bearer_add ue=${ue_id} id=4 filter=0 precedence=0    PGW-initiated Bearer Creation
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=4 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg

UE tigger Intra-gnb inter-DU HO from CELL1 to CELL2
    ${A3_meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30
    ...    nrsrq_nr=30 rs_type=ssb index=0 nrs_result=35:35:35
    Execute Egate Command    ${cmd}    SgNB Modification Confirm
    Verify Throughput


UE tigger Intra-gnb inter-DU HO from CELL2 to CELL1
    ${A3_meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30
    ...    nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:20:59
    Execute Egate Command    ${cmd}    Bearer-type change from SCG-split to MCG is successful
    Verify Throughput

Verify Throughput
    [Arguments]    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.5
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>=0
