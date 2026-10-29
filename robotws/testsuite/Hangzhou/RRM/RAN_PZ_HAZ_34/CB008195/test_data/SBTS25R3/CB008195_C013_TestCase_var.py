from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id
PARAMS_IN_SCF = [
  # PARAMS_CB008915
  "NRCELL-3:administrativeState=Locked",
  "NRCELL-5:administrativeState=Unlocked",
  "NRBTS:actIntraFreqIntraGnbMobilityNSA=true",
  "NRBTS:gNbCuType=NSA",
  "NRCELL:cellDepType=NSA",
  "NRBTS:actSACallProcessingDU=false",
  "NRBTS:nsaInactivityTimer=600",
  "delete:NRSYSINFO_PROFILE-1/NRLIM-1",
  "delete:NRCELL-5/NRPLMNSET_SA-1",
  "delete:NRBTS/SNSSAI-1:ngUplane",
  "delete:NRBTS/TRACKINGAREA-200:snssaiList",
  "delete:NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3",
  "delete:NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3",
  "NRBTS:actConnRrcPooling=true",
  "NRBTS:actScheUePooling=true",
  "NRCELL-5:msg1FrequencyStart=18",
  "NRCELL-5:maxNumOfUsersPerCell=10",
  "NRCELL-5:maxNumOfUsersPerNRCell=10",
  "NRCELL-5:maxNumOfCaUsersNRCell=10",
  "NRCELL-5:maxNumOfRrcSA=10",
  "NRCELL-5:maxNumOfNrDcSnUsers=10",
  "NRCELL-5:maxNumOfSCellAlloc=10",
  "NRCELL-3:msg1FrequencyStart=10",
  "NRCELL-3:maxNumOfUsersPerCell=10",
  "NRCELL-3:maxNumOfUsersPerNRCell=10",
  "NRCELL-3:maxNumOfCaUsersNRCell=10",
  "NRCELL-3:maxNumOfRrcSA=10",
  "NRCELL-3:maxNumOfNrDcSnUsers=10",
  "NRCELL-3:maxNumOfSCellAlloc=10",
  "NRBTS/NRCELLGRP-0:maxNumOfNonGBRBearers=550",
  "NRBTS/NRCELLGRP-0:maxNumOfUsers=550",
  "NRBTS:actMultiDrbNSA=true",
  "NRBTS:actSliceAwareAdmissionCtrl=true",
  "NRCELL-5:sliceAwareAdmissionCtrlEnabled=true",
  "NRCELL-3:sliceAwareAdmissionCtrlEnabled=true",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=NRPLMN-1|nrResourceGroupId=1",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=NRPLMN-2|nrResourceGroupId=2",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrPlmnDN=NRPLMN-1",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=NRPLMN-2",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=80",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=60",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=NRPLMN-1",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=40",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=10",

  "NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=NRPLMN-1|nrResourceGroupId=1",
  "NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=NRPLMN-2|nrResourceGroupId=2",
  "NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrPlmnDN=NRPLMN-1",
  "NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=2",
  "NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=NRPLMN-2",
  "NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=20",
  "NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=0",
  "NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=NRPLMN-1",
  "NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=100",
  "NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=80",

  "NRCELL-3:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1",
  "NRCELL-5:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-2",
  "NRBTS/NRDRB:nsaDrbParam:actPrioritizeX2AfterInactivity=true",
  "NRBTS/NRDRB:nsaDrbParam:actX2DuplicateTxNSA3x=false",
  "NRBTS/NRDRB:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5",
  "NRBTS/NRDRB:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U",
  "NRBTS/NRDRB:nsaDrbParam:dlPreferredPath=F1-U",
  "NRBTS/NRDRB:nsaDrbParam:dlNumOfCongOrGainDdds=2",
  "NRBTS/NRDRB:nsaDrbParam:inactivityThresholdForPrioritizeX2=300",
  "NRBTS/NRDRB:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100",
  "NRBTS/NRDRB:nsaDrbParam:inactPeriodX2PdcpDuplication=300",
  "NRBTS/NRDRB:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U",
  "NRBTS/NRDRB:nsaDrbParam:nsa3xBearerAllowed=true",
  "NRBTS/NRDRB:nsaDrbParam:prioritizeX2Period=500",
  "NRBTS/NRDRB:nsaDrbParam:ulDataPath=ulOverNr",
  "NRBTS/NRDRB:nsaDrbParam:ulDataSplitThreshold=infinity",
  # RanSharing
  "NRBTS:actRanSharing=true",
  "NRBTS:actRanSharingEnh=max_10_PLMNs",
  "NRBTS:actInterFreqInterGnbMobilityNSA=true",
  "NRBTS:actInterFreqIntraGnbMobilityNSA=true",
  "NRBTS:actIntraFreqInterGnbMobilityNSA3x=true",
  "NRBTS:actConflictConfiguration=false",
  "delete:NRCELL-5:trackingAreaDN",
  "delete:NRCELL:configuredEpsTac",
  # MultiPLMN
  "NRPLMN-3:mcc=310",
  "NRPLMN-3:mnc=260",
  "NRPLMN-3:mncLength=3",
  "NRPLMN-1:mcc=262",
  "NRPLMN-1:mnc=03",
  "NRPLMN-1:mncLength=2",
  "NRPLMN-2:mcc=460",
  "NRPLMN-2:mnc=02",
  "NRPLMN-2:mncLength=2",
  # NRPLMNSET_SA_NSA
  "NRCELL-5/NRPLMNSET_NSA-1:nrPlmnDNList=NRPLMN-1,NRPLMN-2",
  # "NRCELL-5/NRPLMNSET_NSA-1:configuredEpsTac=200",
  # TRACKINGAREA
  # "TRACKINGAREA-200/snssaiList:snssaiDN=SNSSAI-1",
  "NRCELL:actPriorityAccess=false",
  "NRCELL:actEmergencyCall=false",
  "NRBTS:actDrbPreemption=false",
  "NRBTS:actUserPreemption=false",
  "NRBTS:actSpidBasedSlicingNSA=false",
  "NRBTS:actSliceAwareScheduler=false",
  "NRPMRNL:miNrCellUtilPerNrg=5min",
  "NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled",
  "NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled",
  "NRPMRNL-1:miNrNgcFlexInterface=disabled",
  "NRPMRNL:miNrX2CC=5min",
  "NRDU:maxNumOfRrcConUEsPerDU=20",
]

PARAMS_IN_SCF_BTS2 = [
  "LNBTS/NRDCDPR-0/ENDCDMEASCONF-5:nrCarPrio=3",
  "LNBTS/NRDCDPR-0/ENDCDMEASCONF-7:nrCarPrio=2",
]

cell3_nrcarprio_better_than_cell5 = [
  "LNBTS/NRDCDPR-0/ENDCDMEASCONF-5:nrCarPrio=3",
  "LNBTS/NRDCDPR-0/ENDCDMEASCONF-7:nrCarPrio=2",
]

cell5_nrcarprio_better_than_cell3 = [
  "LNBTS/NRDCDPR/ENDCDMEASCONF-5:nrCarPrio=2",
  "LNBTS/NRDCDPR/ENDCDMEASCONF-7:nrCarPrio=3",
]

PARAMS_IN_VENDOR = [
  "bbPoolCapacity:maxNumOfUserL2Pool=18|bbHwVariant=ABIO",
  "bbPoolCapacity:maxNumPucchF1SRPerSlotL1Pool=30|bbHwVariant=ABIO",
  "bbPoolCapacity:maxNumPucchF3PCSIPerSlotL1Pool=30|bbHwVariant=ABIO",
]

AVG_NUM_UE_NOM_NRG = "M55910C00005"
DNOM_SAMPLES_NRG = "M55910C00006"
AVE_NUM_NGBR_NOM_NRG = "M55910C00007"
PEAK_NUM_UE_NRG = "M55910C00010"
PEAK_NUM_NGBR_NRG = "M55910C00011"
RAC_REJ_DUE_DRB_MAX_QUOTA_NRG = "M55910C00015"
RAC_REJ_DUE_UE_MAX_QUOTA_NRG = "M55910C00016"
NUM_ADM_REQ_NGBR_NRG = "M55910C00017"
NUM_ADM_SUC_NGBR_NRG = "M55910C00018"
NUM_ADM_REQ_UE_NRG = "M55910C00023"
NUM_ADM_SUC_UE_NRG = "M55910C00024"

CELL_COUNTER = [
  f"NRCELL-5/NRRESOURCEGROUP-1:{AVG_NUM_UE_NOM_NRG}>200",
  f"NRCELL-5/NRRESOURCEGROUP-1:{DNOM_SAMPLES_NRG}>200",
  f"NRCELL-5/NRRESOURCEGROUP-1:{AVE_NUM_NGBR_NOM_NRG}>200",
  f"NRCELL-5/NRRESOURCEGROUP-1:{PEAK_NUM_UE_NRG}>=6",
  f"NRCELL-5/NRRESOURCEGROUP-1:{PEAK_NUM_NGBR_NRG}>=6",
  f"NRCELL-5/NRRESOURCEGROUP-1:{RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0",
  f"NRCELL-5/NRRESOURCEGROUP-1:{RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0",
  f"NRCELL-5/NRRESOURCEGROUP-1:{NUM_ADM_REQ_NGBR_NRG}=2",
  f"NRCELL-5/NRRESOURCEGROUP-1:{NUM_ADM_SUC_NGBR_NRG}=2",
  f"NRCELL-5/NRRESOURCEGROUP-1:{NUM_ADM_REQ_UE_NRG}=2",
  f"NRCELL-5/NRRESOURCEGROUP-1:{NUM_ADM_SUC_UE_NRG}=2",
  f"NRCELL-3/NRRESOURCEGROUP-2:{AVG_NUM_UE_NOM_NRG}>200",
  f"NRCELL-3/NRRESOURCEGROUP-2:{DNOM_SAMPLES_NRG}>200",
  f"NRCELL-3/NRRESOURCEGROUP-2:{AVE_NUM_NGBR_NOM_NRG}>200",
  f"NRCELL-3/NRRESOURCEGROUP-2:{PEAK_NUM_UE_NRG}>=6",
  f"NRCELL-3/NRRESOURCEGROUP-2:{PEAK_NUM_NGBR_NRG}>=6",
  f"NRCELL-3/NRRESOURCEGROUP-2:{RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0",
  f"NRCELL-3/NRRESOURCEGROUP-2:{RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0",
  f"NRCELL-3/NRRESOURCEGROUP-2:{NUM_ADM_REQ_NGBR_NRG}=4",
  f"NRCELL-3/NRRESOURCEGROUP-2:{NUM_ADM_SUC_NGBR_NRG}=3",
  f"NRCELL-3/NRRESOURCEGROUP-2:{NUM_ADM_REQ_UE_NRG}=4",
  f"NRCELL-3/NRRESOURCEGROUP-2:{NUM_ADM_SUC_UE_NRG}=3",
]
