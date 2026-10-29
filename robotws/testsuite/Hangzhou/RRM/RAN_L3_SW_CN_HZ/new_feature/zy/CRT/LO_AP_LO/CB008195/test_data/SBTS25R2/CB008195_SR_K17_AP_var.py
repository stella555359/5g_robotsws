from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

PARAMS_IN_SCF = [
       # CB008195
       "NRBTS-1:rgMinQuotaReservationLevel=cell_and_multicell_level",
       "MRBTS-1/NRBTS-1/NRPMRNL-1:miNrCellUtilPerNrg=5min",
       "MRBTS-1/NRBTS-1:actSliceAwareAdmissionCtrl=true",
       "NRBTS-1/NRCELL-6:sliceAwareAdmissionCtrlEnabled=true",
       "NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=true",
       "NRBTS-1/NRCELL-3:sliceAwareAdmissionCtrlEnabled=true",
       "NRBTS-1/NRCELL-6:actGBRAdmissionControl=GBRService",
       "NRBTS-1/NRCELL-2:actGBRAdmissionControl=GBRService",
       "NRBTS-1/NRCELL-3:actGBRAdmissionControl=GBRService",
       "NRBTS-1/NRCELL-8:actNonVoNRGbrService=true",
       "NRBTS-1/NRCELL-6:actNonVoNRGbrService=true",
       "NRBTS-1/NRCELL-2:actNonVoNRGbrService=true",
       "NRBTS-1/NRCELL-3:actNonVoNRGbrService=true",
       "NRBTS-1/NRCELL-6:maxGBRTrafficLimit=40",
       "NRBTS-1/NRCELL-2:maxGBRTrafficLimit=40",
       "NRBTS-1/NRCELL-3:maxGBRTrafficLimit=40",
       "NRBTS-1/NRCELL-6:actGbrRacTdEnhResourcePriority=false",
       "NRBTS-1/NRCELL-2:actGbrRacTdEnhResourcePriority=false",
       "NRBTS-1/NRCELL-3:actGbrRacTdEnhResourcePriority=false",
       "NRBTS-1/NRCELL-6:addGbrTrafficHo=20",
       "NRBTS-1/NRCELL-2:addGbrTrafficHo=20",
       "NRBTS-1/NRCELL-3:addGbrTrafficHo=20",
       "NRBTS-1/NRCELL-3:actPriorityAccess=false",
       "NRBTS-1/NRCELL-2:actPriorityAccess=false",
       "NRBTS-1/NRCELL-3:actEmergencyCall=false",
       "NRBTS-1/NRCELL-2:actEmergencyCall=false",
       "NRCELL:numOfRadioResReservForTempUse=0",
       "NRCELL:numOfRadioResReservForEmergency=0",
       "NRCELL:numOfRadioResReservForPa=0",
       "NRCELL-6:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
       "NRCELL-2:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
       "NRCELL-3:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=NRPLMN-1|resourceDN=NRPLMN-1",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=26",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=0",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=NRPLMN-2|resourceDN=NRPLMN-2",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=74",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=24",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=2",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-1:nrResourceGroupProfileId=1",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=NRPLMN-1|resourceDN=NRPLMN-1",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=76",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=75",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=NRPLMN-2|resourceDN=NRPLMN-2",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=24",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=14",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=2",
       "NRBTS-1/NRRESOURCEGROUP_PROFILE-2:nrResourceGroupProfileId=2",
       # GBR Service DRB
       "NRBTS/NRDRB-16:actDddsReduction=true",
       "NRBTS/NRDRB-16:actDlTxResumeOnPdcpStatRep=false",
       "NRBTS/NRDRB-16:actLostPduFastRetx=false",
       "NRBTS/NRDRB-16:actOptDataFlowRateEst=false",
       "NRBTS/NRDRB-16:allowedPdcchPowerBoostALDueCce=none",
       "NRBTS/NRDRB-16:allowedPdcchPowerBoostALDueCfg=None",
       "NRBTS/NRDRB-16:caPduReSendingDelayMargin=2",
       "NRBTS/NRDRB-16:dscp=46",
       "NRBTS/NRDRB-16:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-2",
       "NRBTS/NRDRB-16:discardTimer=100ms",
       "NRBTS/NRDRB-16:dlFlowControlAlgo=none",
       "NRBTS/NRDRB-16:l2OHFactorDl=16",
       "NRBTS/NRDRB-16:l2OHFactorUl=35",
       "NRBTS/NRDRB-16:cellAggrLevel=Not FR1 CA eligible",
       "NRBTS/NRDRB-16:maxDataRateGbrDl=30000",
       "NRBTS/NRDRB-16:maxDataRateGbrUl=30000",
       "NRBTS/NRDRB-16:maxForwardTimeLimitX2=50",
       "NRBTS/NRDRB-16:minForwardTputX2=100",
       "NRBTS/NRDRB-16:schedulWeight=30",
       "NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5",
       "NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1",
       "NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1",
       "NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled",
       "NRBTS/NRDRB-16:resType=GBR",
       "NRBTS/NRDRB-16:rlcMode=RLC_UM",
       "NRBTS/NRDRB-16:nrDrbRlcAmDN=",
       "NRBTS/NRDRB-16:nrPdschHRLaDN=",
       "NRBTS/NRDRB-16:maxRlcQueueingDelayGbr=20",
       "NRBTS/NRDRB-16:maxTransferDelayGbr=20",
       "NRBTS/NRDRB_MAC-5:lcgid=5",
       "NRBTS/NRDRB_MAC-5:delayTarget=50",
       "NRBTS/NRDRB_MAC-5:schedulPrio=5",
       "NRBTS/NRDRB_5QI-7:dataForwarding=IRATDataFwd",
       "NRBTS/NRDRB_5QI-7:fiveqiValueList=4",
       "NRBTS/NRDRB_5QI-7:nrDrbDN=NRDRB-16",
       "NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40",
       "NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40",
       "NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN",
       # CG Type2
       "NRBTS-1/NRCELL-2:actUlCgType2=true",
       "NRBTS/NRDRB-11:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1",
       "NRBTS-1/NRCELL-2:ulConfiguredGrantType2:maxGBRAndCgType2TrafficLimit=40",
       "NRBTS-1/NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumPrbs=12",
       "NRBTS-1/NRCELL-2:ulConfiguredGrantType2:ulCgMaxNumUeUl=3",
       "NRBTS-1/NRCELL-2:ulConfiguredGrantType2:ulCgPrbStartOffset=0",
       "NRBTS-1/NRULCG_PROFILE-1:grantedPacketSize=100",
       "NRBTS-1/NRULCG_PROFILE-1:maxNumPrbs=12",
       "NRBTS-1/NRULCG_PROFILE-1:nrUlCgProfileId=1",
       "NRBTS-1/NRULCG_PROFILE-1:periodicity=ms2",
       # add NRREL
       "NRCELL-8/NRREL-2:gNbId=1",
       "NRCELL-8/NRREL-2:gNbIdLength=24",
       "NRCELL-8/NRREL-2:lcrId=2",
       "NRCELL-8/NRREL-2:removeNotAllowed=true",
       "NRCELL-8/NRREL-2:sCellAdditionMethod=covBasedA1",
       "NRCELL-8/NRREL-2:sCellOperationalMode=dlOnly",
       "NRCELL-8/NRREL-2:gnbPlmn:mcc=310",
       "NRCELL-8/NRREL-2:gnbPlmn:mnc=260",
       "NRCELL-8/NRREL-2:gnbPlmn:mncLength=3",
]

PARAMS_IN_VENDOR = [
  "bbPoolCapacity:maxNumOfUserL2Pool=30|bbHwVariant=ABIO",
  "bbPoolCapacity:maxNumPucchF1SRPerSlotL1Pool=30|bbHwVariant=ABIO",
  "bbPoolCapacity:maxNumPucchF3PCSIPerSlotL1Pool=30|bbHwVariant=ABIO",
]

DELTA_PARAS_Bypass = [
    "NRBTS/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=2",
    "NRBTS/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=2",
    "NRBTS-1/NRCELL-6:sliceAwareAdmissionCtrlEnabled=true",
    "NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=true",
    "NRBTS-1/NRCELL-3:sliceAwareAdmissionCtrlEnabled=true",
]

DELTA_PARAS_NonBypass = [
    "NRBTS/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=0",
    "NRBTS/NRRESOURCEGROUP_PROFILE-2:bypassRgLimits=0",
    "NRBTS-1/NRCELL-6:sliceAwareAdmissionCtrlEnabled=true",
    "NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=true",
    "NRBTS-1/NRCELL-3:sliceAwareAdmissionCtrlEnabled=true",
]

DELTA_PARAS_Lock_Cell = [
    "NRCELL-2:administrativeState=Locked",
    "NRCELL-6:administrativeState=Locked",
]

DELTA_PARAS_UnLock_Cell = [
    "NRCELL-2:administrativeState=Unlocked",
]


AVG_NUM_UE_NOM_NRG = "M55910C00005"
DNOM_SAMPLES_NRG = "M55910C00006"
AVE_NUM_NGBR_NOM_NRG = "M55910C00007"
AVE_NUM_GBR_NOM_NRG = "M55910C00008"
PEAK_NUM_UE_NRG = "M55910C00010"
PEAK_NUM_NGBR_NRG = "M55910C00011"
PEAK_NUM_GBR_NRG = "M55910C00012"
NUM_ADM_REQ_NGBR_NRG = "M55910C00017"
NUM_ADM_SUC_NGBR_NRG = "M55910C00018"
NUM_ADM_REQ_GBR_NRG = "M55910C00021"
NUM_ADM_SUC_GBR_NRG = "M55910C00022"
NUM_ADM_REQ_UE_NRG = "M55910C00023"
NUM_ADM_SUC_UE_NRG = "M55910C00024"
RAC_REJ_DUE_DRB_MAX_QUOTA_NRG = "M55910C00015"
SA_DU_GBR_REJ_LACK_DRB = "M55139C00503"
SA_DU_GBR_LACK_RAD_RES = "M55139C00504"
SA_HO_DU_GBR_LACK_DRB = "M55139C00507"
SA_HO_DU_GBR_LACK_RAD_RES = "M55139C00508"

PM_Counters_Check_K17_1 = [
  f"NRCELL-2/NRRESOURCEGROUP-1:{AVE_NUM_GBR_NOM_NRG}>0",
  f"NRCELL-2/NRRESOURCEGROUP-1:{PEAK_NUM_GBR_NRG}=1",
  f"NRCELL-2/NRRESOURCEGROUP-1:{RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=3",
  f"NRCELL-2/NRRESOURCEGROUP-1:{NUM_ADM_REQ_GBR_NRG}=3",
  f"NRCELL-2/NRRESOURCEGROUP-1:{NUM_ADM_SUC_GBR_NRG}=1",
  f"NRCELL-2:{SA_DU_GBR_REJ_LACK_DRB}=0",
  f"NRCELL-2:{SA_DU_GBR_LACK_RAD_RES}=1",
  f"NRCELL-2:{SA_HO_DU_GBR_LACK_DRB}=0",
  f"NRCELL-2:{SA_HO_DU_GBR_LACK_RAD_RES}=1",
]

PM_Counters_Check_K17_2 = [
  f"NRCELL-2/NRRESOURCEGROUP-1:{AVE_NUM_GBR_NOM_NRG}=0",
  f"NRCELL-2/NRRESOURCEGROUP-1:{PEAK_NUM_GBR_NRG}=0",
  f"NRCELL-2/NRRESOURCEGROUP-1:{RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0",
  f"NRCELL-2/NRRESOURCEGROUP-1:{NUM_ADM_REQ_GBR_NRG}=0",
  f"NRCELL-2/NRRESOURCEGROUP-1:{NUM_ADM_SUC_GBR_NRG}=0",
  f"NRCELL-2:{SA_DU_GBR_REJ_LACK_DRB}=0",
  f"NRCELL-2:{SA_DU_GBR_LACK_RAD_RES}=0",
]
