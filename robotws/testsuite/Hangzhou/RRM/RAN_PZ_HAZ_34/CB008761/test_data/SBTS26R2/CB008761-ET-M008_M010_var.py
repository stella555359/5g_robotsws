from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

PARAMS_CB008761 = [
       "NRCELL:iniNumSCellsToActivate=1",
       "NRDU-1:actMLScellAct=true",
       "NRDU-1:mlScellActParamSet1:mlDataCollectionPeriod=500ms",
       "MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:actMLMode=true",
       "MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:actMLTraining=true",
       "MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:mlTrainingParams:mlTrainingStartTime=2",
]

CAlist = "ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fr1Tdd_Sa_WithUl," \
         "ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl"

NRCELL_11_NRREL = [
    "NRCELL-11/NRREL-1:gNbId=1",
    "NRCELL-11/NRREL-1:gNbIdLength=22",
    "NRCELL-11/NRREL-1:lcrId=1",
    "NRCELL-11/NRREL-1:sCellAdditionMethod=blind",
    "NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly",
    "NRCELL-11/NRREL-1:gnbPlmn:mnc=489",
    "NRCELL-11/NRREL-1:gnbPlmn:mcc=311",
    "NRCELL-11/NRREL-1:gnbPlmn:mncLength=3",

    "NRCELL-11/NRREL-2:gNbId=1",
    "NRCELL-11/NRREL-2:gNbIdLength=22",
    "NRCELL-11/NRREL-2:lcrId=2",
    "NRCELL-11/NRREL-2:sCellAdditionMethod=blind",
    "NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly",
    "NRCELL-11/NRREL-2:gnbPlmn:mnc=489",
    "NRCELL-11/NRREL-2:gnbPlmn:mcc=311",
    "NRCELL-11/NRREL-2:gnbPlmn:mncLength=3",

    "NRCELL-11/NRREL-3:gNbId=1",
    "NRCELL-11/NRREL-3:gNbIdLength=22",
    "NRCELL-11/NRREL-3:lcrId=3",
    "NRCELL-11/NRREL-3:sCellAdditionMethod=blind",
    "NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly",
    "NRCELL-11/NRREL-3:gnbPlmn:mnc=489",
    "NRCELL-11/NRREL-3:gnbPlmn:mcc=311",
    "NRCELL-11/NRREL-3:gnbPlmn:mncLength=3",

    "NRCELL-11/NRREL-13:gNbId=1",
    "NRCELL-11/NRREL-13:gNbIdLength=22",
    "NRCELL-11/NRREL-13:lcrId=13",
    "NRCELL-11/NRREL-13:sCellAdditionMethod=blind",
    "NRCELL-11/NRREL-13:sCellOperationalMode=dlOnly",
    "NRCELL-11/NRREL-13:gnbPlmn:mnc=489",
    "NRCELL-11/NRREL-13:gnbPlmn:mcc=311",
    "NRCELL-11/NRREL-13:gnbPlmn:mncLength=3",

    "NRCELL-11/NRREL-14:gNbId=1",
    "NRCELL-11/NRREL-14:gNbIdLength=22",
    "NRCELL-11/NRREL-14:lcrId=14",
    "NRCELL-11/NRREL-14:sCellAdditionMethod=blind",
    "NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly",
    "NRCELL-11/NRREL-14:gnbPlmn:mnc=489",
    "NRCELL-11/NRREL-14:gnbPlmn:mcc=311",
    "NRCELL-11/NRREL-14:gnbPlmn:mncLength=3",
]

A2_scellrelease = [
       "NRCELL:a2MeasSCellRelEnabled=rsrp",
       "NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0",
       "NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34",
       "NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms",
]

CAlist = "ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Fr1Tdd_Sa_WithUl," \
         "ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl"

PARAMS_IN_SCF = PARAMS_CB008761 + NRCELL_11_NRREL + A2_scellrelease + \
                [f"NRBTS/NRDU-1:carrierAggregationSupportList={CAlist}",
                 "NRCELL-2:chBw=60MHz",
                 "NRCELL-3:chBw=60MHz",
                 "NRCELL:timingAdvanceOffset=n25600",
                 "MNL-1:timeZone=(GMT+0) UTC",
                 "NRCELL-12/NRCELL_FDD-1:nrarfcnDl=124900",
                 "NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134100",
                 "NRCELL-12:gscnOrSsPbchArfcn=1562"]

PARAMS_blind = [
       "NRCELL-2/NRREL-1:sCellAdditionMethod=blind",
       "NRCELL-2/NRREL-3:sCellAdditionMethod=blind",
       "NRCELL-2/NRREL-11:sCellAdditionMethod=blind",
       "NRCELL-2/NRREL-13:sCellAdditionMethod=blind",
       "NRCELL-2/NRREL-14:sCellAdditionMethod=blind",
       "NRCELL:sCellDeactivationTimerGNB=infinity",
]

PARAMS_actMLScellAct_enable = [
       "NRDU-1:actMLScellAct=true",
]
PARAMS_actMLScellAct_disable = [
       "NRDU-1:actMLScellAct=false",
]

PARAMS_a4based = [
       "NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1",
       "NRBTS:actMeasBasedSCellAdditionSa=A4-based,A1-based",
       "NRCELL:dlSCellConfigLevel=1",
       "NRCELL:dlSCellConfigLevelNum=1",
       "NRCELL-2:maxNumScellsDlFr1=5",
       "NRCELL-2:measGapSelectionSA=favourUeThroughput",
       "NRCELL-2:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000",
       "NRCELL-2:a4PeriodicMeasControlSA:a4MeasMaxNumber=8",
       "NRCELL-2:a4PeriodicMeasControlSA:a4RetryTimer=5",
       "NRCELL-2/NRHOIF-1:a4MeasSCellAddEnabled=rsrpCombined",
       "NRCELL-2/NRHOIF-1:deriveSsbIndexFromCell=true",
       "NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41",
       "NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz",
       "NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1",
       "NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10",
       "NRCELL-2/NRHOIF-1:ssbFrequency=504990",
       "NRCELL-2/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0",
       "NRCELL-2/NRHOIF-1:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0",
       "NRCELL-2/NRHOIF-1:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0",
       "NRCELL-2/NRHOIF-1:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0",
       "NRCELL-2/NRHOIF-1:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0",
       "NRCELL-2/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0",
       "NRCELL-2/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0",

       "NRCELL-2/NRHOIF-3:a4MeasSCellAddEnabled=rsrpCombined",
       "NRCELL-2/NRHOIF-3:deriveSsbIndexFromCell=true",
       "NRCELL-2/NRHOIF-3:freqBandIndicatorNR=78",
       "NRCELL-2/NRHOIF-3:ifhoSsbScs=30 KHz",
       "NRCELL-2/NRHOIF-3:ifhoSsbSmtcDuration=sf1",
       "NRCELL-2/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10",
       "NRCELL-2/NRHOIF-3:ssbFrequency=637920",
       "NRCELL-2/NRHOIF-3:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0",
       "NRCELL-2/NRHOIF-3:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0",
       "NRCELL-2/NRHOIF-3:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0",
       "NRCELL-2/NRHOIF-3:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0",
       "NRCELL-2/NRHOIF-3:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0",
       "NRCELL-2/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0",
       "NRCELL-2/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0",

       "NRCELL-2/NRHOIF-11:a4MeasSCellAddEnabled=rsrpCombined",
       "NRCELL-2/NRHOIF-11:deriveSsbIndexFromCell=true",
       "NRCELL-2/NRHOIF-11:freqBandIndicatorNR=71",
       "NRCELL-2/NRHOIF-11:ifhoSsbSmtcDuration=sf1",
       "NRCELL-2/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf10",
       "NRCELL-2/NRHOIF-11:ssbFrequency=127450",
       "NRCELL-2/NRHOIF-11:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0",
       "NRCELL-2/NRHOIF-11:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0",
       "NRCELL-2/NRHOIF-11:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0",
       "NRCELL-2/NRHOIF-11:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0",
       "NRCELL-2/NRHOIF-11:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0",
       "NRCELL-2/NRHOIF-11:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0",
       "NRCELL-2/NRHOIF-11:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0",

       "NRCELL-2/NRHOIF-13:a4MeasSCellAddEnabled=rsrpCombined",
       "NRCELL-2/NRHOIF-13:deriveSsbIndexFromCell=true",
       "NRCELL-2/NRHOIF-13:freqBandIndicatorNR=66",
       "NRCELL-2/NRHOIF-13:ifhoSsbSmtcDuration=sf1",
       "NRCELL-2/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf10",
       "NRCELL-2/NRHOIF-13:ssbFrequency=424090",
       "NRCELL-2/NRHOIF-13:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0",
       "NRCELL-2/NRHOIF-13:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0",
       "NRCELL-2/NRHOIF-13:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0",
       "NRCELL-2/NRHOIF-13:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0",
       "NRCELL-2/NRHOIF-13:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0",
       "NRCELL-2/NRHOIF-13:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0",
       "NRCELL-2/NRHOIF-13:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0",

       "NRCELL-2/NRHOIF-14:a4MeasSCellAddEnabled=rsrpCombined",
       "NRCELL-2/NRHOIF-14:deriveSsbIndexFromCell=true",
       "NRCELL-2/NRHOIF-14:freqBandIndicatorNR=66",
       "NRCELL-2/NRHOIF-14:ifhoSsbSmtcDuration=sf1",
       "NRCELL-2/NRHOIF-14:ifhoSsbSmtcPeriodicity=sf10",
       "NRCELL-2/NRHOIF-14:ssbFrequency=427970",
       "NRCELL-2/NRHOIF-14:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0",
       "NRCELL-2/NRHOIF-14:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0",
       "NRCELL-2/NRHOIF-14:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0",
       "NRCELL-2/NRHOIF-14:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0",
       "NRCELL-2/NRHOIF-14:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0",
       "NRCELL-2/NRHOIF-14:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0",
       "NRCELL-2/NRHOIF-14:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0",

       "NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA4",
       "NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA4",
       "NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA4",
       "NRCELL-2/NRREL-14:sCellAdditionMethod=covBasedA4",
       "NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA4",
       "NRCELL-2/NRREL-11:sCellOperationalMode=dlAndUl",
       "NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly",
       "NRCELL-2/NRREL-3:sCellOperationalMode=dlOnly",
       "NRCELL-2/NRREL-13:sCellOperationalMode=dlAndUl",
       "NRCELL-2/NRREL-14:sCellOperationalMode=dlAndUl",
       "delete:NRCELL-2/NRREL-12",
]

PARAMS_nrrel_12_NRHOIF = [
    "NRCELL-2/NRREL-12:gNbId=1",
    "NRCELL-2/NRREL-12:gNbIdLength=22",
    "NRCELL-2/NRREL-12:lcrId=12",
    "NRCELL-2/NRREL-12:sCellAdditionMethod=covBasedA4",
    "NRCELL-2/NRREL-12:sCellOperationalMode=dlAndUl",
    "NRCELL-2/NRREL-12:gnbPlmn:mnc=489",
    "NRCELL-2/NRREL-12:gnbPlmn:mcc=311",
    "NRCELL-2/NRREL-12:gnbPlmn:mncLength=3",
    "NRCELL-2/NRHOIF-12:a4MeasSCellAddEnabled=rsrpCombined",
    "NRCELL-2/NRHOIF-12:deriveSsbIndexFromCell=true",
    "NRCELL-2/NRHOIF-12:freqBandIndicatorNR=71",
    "NRCELL-2/NRHOIF-12:ifhoSsbSmtcDuration=sf1",
    "NRCELL-2/NRHOIF-12:ifhoSsbSmtcPeriodicity=sf10",
    "NRCELL-2/NRHOIF-12:ssbFrequency=125050",
    "NRCELL-2/NRHOIF-12:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms0",
    "NRCELL-2/NRHOIF-12:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0",
    "NRCELL-2/NRHOIF-12:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0",
    "NRCELL-2/NRHOIF-12:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0",
    "NRCELL-2/NRHOIF-12:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0",
    "NRCELL-2/NRHOIF-12:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0",
    "NRCELL-2/NRHOIF-12:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0",
    "delete:NRCELL-2/NRREL-1:sCellAdditionMethod",
    "delete:NRCELL-2/NRREL-3:sCellAdditionMethod",
    "delete:NRCELL-2/NRREL-1:sCellOperationalMode",
    "delete:NRCELL-2/NRREL-3:sCellOperationalMode",
]

GNB_SCELL_5_ADMI_REQ_SA = "M55138C03504"
GNB_SCELL_5_ADMI_SUCC_SA = "M55138C03507"
NUM_OF_NON_AIML_SCELL_ACT = "M55316C00031"
NUM_OF_AIML_SCELL_ACT = "M55316C00030"
SCELL_ACT_TRAIN_MOD_SUCC_AIML = "M55911C00004"
SCELL_ACT_MODEL_ACCUR_AIML = "M55911C00005"
SCELL_ACT_MODEL_NOT_ACCUR_AIML = "M55911C00006"
SCELL_ACT_INFERENCE_REQ_AIML = "M55913C00001"
SCELL_ACT_INFERENCE_RES_AIML = "M55913C00002"

PM_Counters_Check_N1 = [
  f"NRCELL-2:{GNB_SCELL_5_ADMI_REQ_SA}=2",
  f"NRCELL-2:{GNB_SCELL_5_ADMI_SUCC_SA}=2",
  f"NRDU-1:{SCELL_ACT_MODEL_ACCUR_AIML}>=0",
  f"NRDU-1:{SCELL_ACT_MODEL_NOT_ACCUR_AIML}>=0",
  f"NRDU-1:{SCELL_ACT_TRAIN_MOD_SUCC_AIML}=1",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_REQ_AIML}>=0",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_RES_AIML}>=0",
  f"NRCELL-2:{NUM_OF_NON_AIML_SCELL_ACT}>0",
  f"NRCELL-2:{NUM_OF_AIML_SCELL_ACT}>=0"
]
PM_Counters_Check_UL_scell = [
  f"NRCELL-2:{NUM_OF_NON_AIML_SCELL_ACT}>=0",
  f"NRCELL-2:{NUM_OF_AIML_SCELL_ACT}>=0",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_REQ_AIML}>=0",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_RES_AIML}>=0"
]
PM_Counters_Check_3T3F_covbasea4 = [
  f"NRCELL-2:{NUM_OF_NON_AIML_SCELL_ACT}>=1",
  f"NRCELL-2:{NUM_OF_AIML_SCELL_ACT}>=3",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_REQ_AIML}>0",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_RES_AIML}>0"
]
PM_Counters_Check_TFFFF = [
  f"NRCELL-2:{NUM_OF_NON_AIML_SCELL_ACT}>=1",
  f"NRCELL-2:{NUM_OF_AIML_SCELL_ACT}>=2",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_REQ_AIML}>0",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_RES_AIML}>0"
]
