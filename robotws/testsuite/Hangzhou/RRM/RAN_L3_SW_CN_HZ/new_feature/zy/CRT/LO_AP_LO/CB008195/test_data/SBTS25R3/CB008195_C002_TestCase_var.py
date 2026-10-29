from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id
PARAMS_IN_SCF = [
  # PARAMS_CB008915
  "NRBTS:actIntraFreqIntraGnbMobilityNSA=true",
  "NRBTS:gNbCuType=NSA",
  "NRCELL:cellDepType=NSA",
  "NRBTS:actSACallProcessingDU=false",
  "delete:NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1",
  "delete:NRCELL/NRPLMNSET_SA-1",
  "delete:NRBTS/SNSSAI-1:ngUplane",
  "delete:NRBTS/TRACKINGAREA-200:snssaiList",
  "NRBTS-1:actConnRrcPooling=true",
  "NRCELL:msg1FrequencyStart=10",
  "NRCELL-1:maxNumOfUsersPerCell=5",
  "NRCELL-4:maxNumOfUsersPerCell=5",
  "NRCELL:maxNumOfUsersPerNRCell=5",
  "NRCELL:maxNumOfCaUsersNRCell=5",
  "NRCELL:maxNumOfRrcSA=5",
  "NRCELL:maxNumOfNrDcSnUsers=5",
  "NRCELL:maxNumOfSCellAlloc=5",
  "NRBTS:actMultiDrbNSA=true",
  "NRBTS-1:actScheUePooling=true",
  "NRBTS-1:actSliceAwareAdmissionCtrl=true",
  "NRCELL-1:sliceAwareAdmissionCtrlEnabled=true",
  "NRCELL-4:sliceAwareAdmissionCtrlEnabled=true",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1|nrResourceGroupId=1",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2|nrResourceGroupId=2",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=2",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-1",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=60",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=40",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/NRPLMN-2",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=50",
  "NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=30",
  "NRCELL-1:nrResourceGroupProfileRacDN=MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
  "NRCELL-4:nrResourceGroupProfileRacDN=MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-2",
  "NRBTS-1/NRDRB:nsaDrbParam:actPrioritizeX2AfterInactivity=true",
  "NRBTS-1/NRDRB:nsaDrbParam:actX2DuplicateTxNSA3x=false",
  "NRBTS-1/NRDRB:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5",
  "NRBTS-1/NRDRB:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U",
  "NRBTS-1/NRDRB:nsaDrbParam:dlNumOfCongOrGainDdds=2",
  "NRBTS-1/NRDRB:nsaDrbParam:inactivityThresholdForPrioritizeX2=300",
  "NRBTS-1/NRDRB:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100",
  "NRBTS-1/NRDRB:nsaDrbParam:inactPeriodX2PdcpDuplication=300",
  "NRBTS-1/NRDRB:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U",
  "NRBTS-1/NRDRB:nsaDrbParam:nsa3xBearerAllowed=true",
  "NRBTS-1/NRDRB:nsaDrbParam:prioritizeX2Period=500",
  "NRBTS-1/NRDRB:nsaDrbParam:ulDataPath=ulOverNr",
  "NRBTS-1/NRDRB:nsaDrbParam:ulDataSplitThreshold=infinity",
  "NRBTS-1/NRDRB:nsaDrbParam:dlPreferredPath=F1-U"
  # RanSharing
  "NRBTS-1:actRanSharing=true",
  "NRBTS-1:actRanSharingEnh=max_10_PLMNs",
  "NRBTS-1:actInterFreqInterGnbMobilityNSA=true",
  "NRBTS-1:actInterFreqIntraGnbMobilityNSA=true",
  "NRBTS-1:actIntraFreqInterGnbMobilityNSA3x=true",
  "NRBTS-1:actConflictConfiguration=false",
  "delete:NRCELL:trackingAreaDN",
  "delete:NRCELL:configuredEpsTac"
  # MultiPLMN
  "NRPLMN-3:mcc=310",
  "NRPLMN-3:mnc=260",
  "NRPLMN-3:mncLength=3",
  "NRPLMN-1:mcc=262",
  "NRPLMN-1:mnc=03",
  "NRPLMN-1:mncLength=2",
  "NRPLMN-2:mcc=460",
  "NRPLMN-2:mnc=02",
  "NRPLMN-2:mncLength=2"
  # NRPLMNSET_SA_NSA
  "NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-210",
  # "NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3",
  "NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200",
  "NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2"
  "NRCELL-4/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2"
  # SNSSAI
  # "SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3"
  # TRACKINGAREA
  "TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1"
]

AVG_NUM_UE_NOM_NRG = "M55910C00005"
DNOM_SAMPLES_NRG = "M55910C00006"
AVE_NUM_NGBR_NOM_NRG = "M55910C00007"
AVE_NUM_GBR_NOM_NRG = "M55910C00008"
AVE_NUM_NBR_NOM_NRG = "M55910C00009"
PEAK_NUM_UE_NRG = "M55910C00010"
PEAK_NUM_NGBR_NRG = "M55910C00011"
PEAK_NUM_GBR_NRG = "M55910C00012"
PEAK_NUM_NBR_NRG = "M55910C00013"
AVE_UNALLOC_5QI1_RES_NOM_NRG = "M55910C00014"
RAC_REJ_DUE_DRB_MAX_QUOTA_NRG = "M55910C00015"
RAC_REJ_DUE_UE_MAX_QUOTA_NRG = "M55910C00016"
NUM_ADM_REQ_NGBR_NRG = "M55910C00017"
NUM_ADM_SUC_NGBR_NRG = "M55910C00018"
NUM_ADM_REQ_NBR_NRG = "M55910C00019"
NUM_ADM_SUC_NBR_NRG = "M55910C00020"
NUM_ADM_REQ_GBR_NRG = "M55910C00021"
NUM_ADM_SUC_GBR_NRG = "M55910C00022"
NUM_ADM_REQ_UE_NRG = "M55910C00023"
NUM_ADM_SUC_UE_NRG = "M55910C00024"


CELL1_COUNTER = [
    f"last NRCELL-1:{AVG_NUM_UE_NOM_NRG}=0",
    f"last NRCELL-1:{DNOM_SAMPLES_NRG}=0",
    f"last NRCELL-1:{AVE_NUM_NGBR_NOM_NRG}=0",
    f"last NRCELL-1:{AVE_NUM_GBR_NOM_NRG}=0",
    f"last NRCELL-1:{AVE_NUM_NBR_NOM_NRG}=0",
    f"last NRCELL-1:{PEAK_NUM_UE_NRG}=0",
    f"last NRCELL-1:{PEAK_NUM_NGBR_NRG}=0",
    f"last NRCELL-1:{PEAK_NUM_GBR_NRG}=0",
    f"last NRCELL-1:{PEAK_NUM_NBR_NRG}=0",
    f"last NRCELL-1:{AVE_UNALLOC_5QI1_RES_NOM_NRG}=0",
    f"last NRCELL-1:{RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0",
    f"last NRCELL-1:{RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0",
    f"last NRCELL-1:{NUM_ADM_REQ_NGBR_NRG}=0",
    f"last NRCELL-1:{NUM_ADM_SUC_NGBR_NRG}=0",
    f"last NRCELL-1:{NUM_ADM_REQ_NBR_NRG}=0",
    f"last NRCELL-1:{NUM_ADM_SUC_NBR_NRG}=0",
    f"last NRCELL-1:{NUM_ADM_REQ_GBR_NRG}=0",
    f"last NRCELL-1:{NUM_ADM_SUC_GBR_NRG}=0",
    f"last NRCELL-1:{NUM_ADM_REQ_UE_NRG}=0",
    f"last NRCELL-1:{NUM_ADM_SUC_UE_NRG}=0"
]
