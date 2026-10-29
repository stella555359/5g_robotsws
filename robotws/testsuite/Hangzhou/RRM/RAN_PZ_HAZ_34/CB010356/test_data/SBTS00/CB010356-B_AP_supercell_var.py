PARAMS_IN_SCF = [
    # Beamforming disabled
    "NRCELL:actBeamforming=false",

    # 10356 / 10332 enabled
    # "NRCELL:actHPPosMethodOptList=disabled",
    "NRCELL-3:actHPPosMethodOptList=UL-TDOA",

    # nGRanAccessPointPosition mapping to subcell
    "NRCELL:nGRanAccessPointPosition:confidence=100|altitude=0",
    "NRCELL:nGRanAccessPointPosition:degreesOfLatitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:degreesOfLongitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:directionOfAltitude=Height|altitude=0",
    "NRCELL:nGRanAccessPointPosition:latitudeSign=North|altitude=0",
    "NRCELL:nGRanAccessPointPosition:orientationOfMajorAxis=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintyAltitude=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMajor=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMinor=0|altitude=0",
    "NRCELL:nGRanAccessPointPosition:confidence=100|altitude=1",
    "NRCELL:nGRanAccessPointPosition:degreesOfLatitude=2|altitude=1",
    "NRCELL:nGRanAccessPointPosition:degreesOfLongitude=3|altitude=1",
    "NRCELL:nGRanAccessPointPosition:directionOfAltitude=Depth|altitude=1",
    "NRCELL:nGRanAccessPointPosition:latitudeSign=South|altitude=1",
    "NRCELL:nGRanAccessPointPosition:orientationOfMajorAxis=4|altitude=1",
    "NRCELL:nGRanAccessPointPosition:uncertaintyAltitude=5|altitude=1",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMajor=6|altitude=1",
    "NRCELL:nGRanAccessPointPosition:uncertaintySemiMinor=7|altitude=1",

    # SRS setting
    "NRCELL:srsForPositioning:comb=comb2",
    "NRCELL:srsForPositioning:cSRS=0",
    "NRCELL:srsForPositioning:numberOfCS=4 cycle shifts",
    "NRCELL:srsForPositioning:srsUePeriodicity=slots40",

    # NRPoSINFO
    # "NRCELL-3/NRPOSINFO-1",

    # NTAoffset to calculate SFN Initialisation Time
    "NRCELL:timingAdvanceOffset=n25600",

    # Emergency Call
    "NRCELL:actEmergencyCall=true",
    "NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=true",
    "NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true",
    "NRCELL:actVoNR=true",
    "NRBTS/NRDRB_5QI-1:fiveqiValueList=5",
    "NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10",
    "NRBTS/NRDRB_5QI-6:fiveqiValueList=1",
    "NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15",
    "NRBTS/NRDRB-10:resType=nonGBR_Signaling",
    "NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4",
    "NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible",
    "NRBTS/NRDRB-15:discardTimer=40ms",
    "NRBTS/NRDRB-15:discardTimerUl=infinity",
    "NRBTS/NRDRB-15:dlFlowControlAlgo=none",
    "NRBTS/NRDRB-15:maxDataRateGbrDl=1000",
    "NRBTS/NRDRB-15:maxDataRateGbrUl=1000",
    "NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20",
    "NRBTS/NRDRB-15:maxTransferDelayGbr=20",
    "NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3",
    "NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3",
    "NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1",
    "NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled",
    "NRBTS/NRDRB-15:resType=GBR",
    "NRBTS/NRDRB-15:rlcMode=RLC_UM",
    "NRBTS/NRDRB-15:schedulWeight=1",
    "NRBTS/NRDRB-15:nrDrbRlcAmDN=",
    "NRBTS/NRDRB-15:nsaDrbParam=",
    "NRBTS/NRDRB_MAC-3:lcgid=4",
    "NRBTS/NRDRB_MAC-4:lcgid=0",
    "NRBTS/NRDRB_MAC-4:schedulBSD=100ms",
    "NRBTS/NRDRB_MAC-4:schedulPrio=5",
    "NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1",
    "NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50",

    # NRPMRNL
    "NRBTS/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled",
    "NRBTS/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled",
    "NRBTS/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled",
    "NRBTS/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled",
    "NRBTS/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled",
    "NRBTS/NRPMRNL-1:miNrNgcFlexInterface=disabled",
    "NRBTS/NRPMRNL-1:miNrRRCC=5min",
    "NRBTS/NRPMRNL-1:miNrPaging=5min",
    "NRBTS/NRPMRNL-1:miNrF1CD=5min",

    # interFreqHO
    "NRBTS:actInterFreqHoSA=true",
    "NRBTS:timerXnDataFwdGuard=250",

    # Overload
    "NRBTS:gnbOvlProtMode=classical",
    "NRBTS:cuOvlHa:ovlSaRrcRej=enabled",
    "NRBTS:duOvlHa:ovlSaRrcRej=true",

    # UAI
    "NRBTS:rrcInactPreferredStateEnabled=false",
    "NRBTS:actRrcReleasePreference=false",
    "NRBTS:timerReleasePreferenceProhibit=s3",
    "NRBTS:outOfConnectedPreference=idle",

    # CB008225_RRC_Inactive
    "NRBTS:actRrcInactState=intra-gNB",
    "NRBTS:drbRrcInactInactivityTimerSA=7200",
    "NRBTS:drbInactivityTimerSA=7200",
    "NRBTS:srbInactivityTimerSA=600",
    "NRBTS:maxUeRrcInactTime=1",
    "NRBTS:rrcInactIMMSteeringEnabled=false",
    "NRBTS:rrcInactLocationReportEnabled=false",
    "NRBTS:t380=60min",
    "NRBTS:actPaging=true",
    "NRBTS:tRanPagingGuard=4",
    "NRBTS:ranPagingCycle=v32",
    "NRBTS:activityNotificationLevelSA=ue",
    "NRBTS:act3gppBL23R1=true",
    "NRCELL/NRPLMNSET_SA-1:ranAC=0",

    # HPA
    "NRBTS:applyPriorityAccess=HPA",
    "NRBTS/NRPRIOACC_PROFILE-1:nrPlmnIdx=1",
    "NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=8",
    "NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=6",
    "NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax=4",
    "NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin=1",
    "NRCELL-3:actPriorityAccess=true",
    "NRCELL-3:raPrioritizationForAI=MPS+MCS",
    "NRCELL-3:powerRampingStepHighPriorityCbra=dB4",
    "NRCELL-3:powerRampingStep=dB2",
    "NRCELL-3:pagingPrioLevelPaMax=1",
    "NRCELL-3:pagingPrioLevelPaMin=1",
    "NRCELL-3:tPageCorrInt=3000",

    # RRE
    "NRBTS:rrcReestabTypeSA=sameGNB",

    # intraFreq HO
    "NRBTS:actConflictConfiguration=true",
    "NRBTS:actIntraFreqHoSA=true",
    "NRBTS:timerXnDataFwdGuard=250",
    "NRPMRNL-1:miNrRelReportCu=5min",
    "NRCELL-3:a3MeasEnabled=rsrp",
    "NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320",
    "NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320",
    "NRCELL-3:filterCoeffSsbRsrp=fc4",
    "NRCELL-3:absThreshSsbRsrpConsolidation=80",
    "NRCELL-3:sMeasConfigSsbRsrp=20",
    "NRBTS:actIncXn=true",
    "NRBTS:cipherPrefL:nea0=9|nea3_128=0",
    "NRCELL-3/NRREL-1:lcrId=1",
    "NRCELL-3/NRREL-1:gNbId=1",
    "NRCELL-3/NRREL-1:gNbIdLength=22",
    "NRCELL-3/NRREL-1:handoverAllowedSA=allowed",
    "NRCELL-3/NRREL-1:gnbPlmn:mnc=489",
    "NRCELL-3/NRREL-1:gnbPlmn:mcc=311",
    "NRCELL-3/NRREL-1:gnbPlmn:mncLength=3",
    "NRCELL-3/NRREL-1:removeNotAllowed=false",

]

Trigger_UE_RRC_Inactive = [
    "NRBTS:drbRrcInactInactivityTimerSA=3",
    "NRBTS:drbInactivityTimerSA=60",
    "NRBTS:srbInactivityTimerSA=3",
    "NRBTS:rrcInactIMMSteeringEnabled=true",
    "NRBTS:tRanPagingGuard=5",
    "NRBTS:actIdleMMSteering=true",
    "NRCELL:idleMMSteeringAlgo=non CA aware",
    "NRCELL:idleMMSteeringPercentageOfUes=10",
    "NRCELL:idleMMSteeringWRREnabled=false",
    "NRCELL:idleMMSteeringWRREnabledSec=Disabled",
]

Recover_UE_RRC_Inactive = [
    "NRBTS:drbRrcInactInactivityTimerSA=7200",
    "NRBTS:drbInactivityTimerSA=7200",
    "NRBTS:srbInactivityTimerSA=600",
    "NRBTS:rrcInactIMMSteeringEnabled=false",
    "NRBTS:tRanPagingGuard=4",
    "NRBTS:actIdleMMSteering=false",
    "NRCELL:idleMMSteeringAlgo=",
    "NRCELL:idleMMSteeringPercentageOfUes=",
    "NRCELL:idleMMSteeringWRREnabled=",
    "NRCELL:idleMMSteeringWRREnabledSec=",
]

delay_positioning_information_response = "0x59025d=5"
set_positioning_information_update = "0x59025d=1"
rdPreventOverloadActivationBeforeUeTresholdIsReached = "0x89008e=0"

PARAMS_IN_SWCONFIG = [
    # set_positioning_information_update,
    delay_positioning_information_response,
    rdPreventOverloadActivationBeforeUeTresholdIsReached,
    # 10356/10332 workaround
    "0x59029B = 1",
    "0x890092 = 1",
]

if __name__ == "__main__":
    print("hello")
