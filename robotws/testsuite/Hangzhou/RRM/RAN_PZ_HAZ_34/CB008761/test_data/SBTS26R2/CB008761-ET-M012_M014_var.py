from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

PARAMS_CB008761 = [
       "NRCELL:iniNumSCellsToActivate=1",
       "NRDU-1:actMLScellAct=true",
       "NRDU-1:mlScellActParamSet1:mlDataCollectionPeriod=100ms",
       "MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:actMLMode=true",
       "MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:actMLTraining=true",
       "MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:mlTrainingParams:mlTrainingStartTime=2",
]

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

PARAMS_IN_SCF = PARAMS_CB008761 + NRCELL_11_NRREL + A2_scellrelease + \
                ["NRCELL-2:chBw=60MHz",
                 "NRCELL-3:chBw=60MHz",
                 "NRCELL:timingAdvanceOffset=n25600",
                 "MNL-1:timeZone=(GMT+0) UTC"]

PARAMS_covBasedA1 = [
       "NRCELL-2/NRREL-11:sCellOperationalMode=dlAndUl",
       "NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1",
       "NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1",
       "NRCELL-2/NRREL-11:sCellAdditionMethod=covBasedA1",
       "NRCELL-2/NRREL-13:sCellAdditionMethod=covBasedA1",
       "NRCELL-2/NRREL-14:sCellAdditionMethod=covBasedA1",
       "NRCELL:sCellDeactivationTimerGNB=ms1280",
]

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
GNB_SCELL_5_ADMI_REQ_SA = "M55138C03504"
GNB_SCELL_5_ADMI_SUCC_SA = "M55138C03507"
NUM_OF_NON_AIML_SCELL_ACT = "M55316C00031"
NUM_OF_AIML_SCELL_ACT = "M55316C00030"
SCELL_ACT_TRAIN_MOD_SUCC_AIML = "M55911C00004"
SCELL_ACT_MODEL_ACCUR_AIML = "M55911C00005"
SCELL_ACT_MODEL_NOT_ACCUR_AIML = "M55911C00006"
SCELL_ACT_INFERENCE_REQ_AIML = "M55913C00001"
SCELL_ACT_INFERENCE_RES_AIML = "M55913C00002"

PM_Counters_Check_L007 = [
  f"NRCELL-2:{GNB_SCELL_5_ADMI_REQ_SA}=2",
  f"NRCELL-2:{GNB_SCELL_5_ADMI_SUCC_SA}=2"
]
PM_Counters_Check_N1 = [
  f"NRCELL-2:{GNB_SCELL_5_ADMI_REQ_SA}=2",
  f"NRCELL-2:{GNB_SCELL_5_ADMI_SUCC_SA}=2",
  f"NRDU-1:{SCELL_ACT_MODEL_ACCUR_AIML}>=0",
  f"NRDU-1:{SCELL_ACT_MODEL_NOT_ACCUR_AIML}>=0",
  f"NRDU-1:{SCELL_ACT_TRAIN_MOD_SUCC_AIML}=1",
  f"NRCELL-11:{SCELL_ACT_INFERENCE_REQ_AIML}=0",
  f"NRCELL-11:{SCELL_ACT_INFERENCE_RES_AIML}=0",
  f"NRCELL-2:{NUM_OF_NON_AIML_SCELL_ACT}>0",
  f"NRCELL-2:{NUM_OF_AIML_SCELL_ACT}>=0"
]
PM_Counters_Check_one_6CC = [
  f"NRCELL-2:{GNB_SCELL_5_ADMI_REQ_SA}=1",
  f"NRCELL-2:{GNB_SCELL_5_ADMI_SUCC_SA}=1",
  f"NRCELL-2:{NUM_OF_NON_AIML_SCELL_ACT}=1",
  f"NRCELL-2:{NUM_OF_AIML_SCELL_ACT}=4",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_REQ_AIML}>0",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_RES_AIML}>0"
]
PM_Counters_Check_TF_TFF_TTTF = [
  f"NRCELL-2:{NUM_OF_NON_AIML_SCELL_ACT}=3",
  f"NRCELL-2:{NUM_OF_AIML_SCELL_ACT}=3",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_REQ_AIML}>0",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_RES_AIML}>0"
]
PM_Counters_Check_TTFF_TTTFF_TTFFF = [
  f"NRCELL-2:{NUM_OF_NON_AIML_SCELL_ACT}=3",
  f"NRCELL-2:{NUM_OF_AIML_SCELL_ACT}=8",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_REQ_AIML}>0",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_RES_AIML}>0",
  f"NRDU-1:{SCELL_ACT_MODEL_ACCUR_AIML}>=0",
  f"NRDU-1:{SCELL_ACT_MODEL_NOT_ACCUR_AIML}>=0"
]
PM_Counters_Check_FDD = [
  f"NRCELL-11:{NUM_OF_NON_AIML_SCELL_ACT}=0",
  f"NRCELL-11:{NUM_OF_AIML_SCELL_ACT}=0",
  f"NRCELL-11:{SCELL_ACT_INFERENCE_REQ_AIML}=0",
  f"NRCELL-11:{SCELL_ACT_INFERENCE_RES_AIML}=0"
]
PM_Counters_Check_UL_scell = [
  f"NRCELL-11:{NUM_OF_NON_AIML_SCELL_ACT}=0",
  f"NRCELL-11:{NUM_OF_AIML_SCELL_ACT}=0",
  f"NRCELL-11:{SCELL_ACT_INFERENCE_REQ_AIML}=0",
  f"NRCELL-11:{SCELL_ACT_INFERENCE_RES_AIML}=0"
]
PM_Counters_Check_3T3F_covbase = [
  f"NRCELL-2:{NUM_OF_NON_AIML_SCELL_ACT}>=1",
  f"NRCELL-2:{NUM_OF_AIML_SCELL_ACT}>=4",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_REQ_AIML}>0",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_RES_AIML}>0"
]
PM_Counters_Check_3T3F_covbase_flagdisable = [
  f"NRCELL-2:{NUM_OF_NON_AIML_SCELL_ACT}=0",
  f"NRCELL-2:{NUM_OF_AIML_SCELL_ACT}=0",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_REQ_AIML}=0",
  f"NRCELL-2:{SCELL_ACT_INFERENCE_RES_AIML}=0"
]
