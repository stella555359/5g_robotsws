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
       "NRBTS-1:actBufferBasedSCellAddition=disabled",
]

NRCELL_3_NRREL = [
    "NRCELL-3/NRREL-2:gNbId=1",
    "NRCELL-3/NRREL-2:gNbIdLength=24",
    "NRCELL-3/NRREL-2:lcrId=2",
    "NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1",
    "NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly",
    "NRCELL-3/NRREL-2:gnbPlmn:mnc=260",
    "NRCELL-3/NRREL-2:gnbPlmn:mcc=310",
    "NRCELL-3/NRREL-2:gnbPlmn:mncLength=3",

    "NRCELL-3/NRREL-7:gNbId=1",
    "NRCELL-3/NRREL-7:gNbIdLength=24",
    "NRCELL-3/NRREL-7:lcrId=7",
    "NRCELL-3/NRREL-7:sCellAdditionMethod=covBasedA1",
    "NRCELL-3/NRREL-7:sCellOperationalMode=dlOnly",
    "NRCELL-3/NRREL-7:gnbPlmn:mnc=260",
    "NRCELL-3/NRREL-7:gnbPlmn:mcc=310",
    "NRCELL-3/NRREL-7:gnbPlmn:mncLength=3",

    "NRCELL-3/NRREL-10:gNbId=1",
    "NRCELL-3/NRREL-10:gNbIdLength=24",
    "NRCELL-3/NRREL-10:lcrId=10",
    "NRCELL-3/NRREL-10:sCellAdditionMethod=covBasedA1",
    "NRCELL-3/NRREL-10:sCellOperationalMode=dlOnly",
    "NRCELL-3/NRREL-10:gnbPlmn:mnc=260",
    "NRCELL-3/NRREL-10:gnbPlmn:mcc=310",
    "NRCELL-3/NRREL-10:gnbPlmn:mncLength=3",
    "delete:NRCELL-3/NRREL-1",
    "NRCELL:sCellDeactivationTimerGNB=ms1280",
]

NRCELL_10_NRREL = [
    "NRCELL-10/NRREL-2:gNbId=1",
    "NRCELL-10/NRREL-2:gNbIdLength=24",
    "NRCELL-10/NRREL-2:lcrId=2",
    "NRCELL-10/NRREL-2:sCellAdditionMethod=covBasedA1",
    "NRCELL-10/NRREL-2:sCellOperationalMode=dlOnly",
    "NRCELL-10/NRREL-2:gnbPlmn:mnc=260",
    "NRCELL-10/NRREL-2:gnbPlmn:mcc=310",
    "NRCELL-10/NRREL-2:gnbPlmn:mncLength=3",

    "NRCELL-10/NRREL-7:gNbId=1",
    "NRCELL-10/NRREL-7:gNbIdLength=24",
    "NRCELL-10/NRREL-7:lcrId=7",
    "NRCELL-10/NRREL-7:sCellAdditionMethod=covBasedA1",
    "NRCELL-10/NRREL-7:sCellOperationalMode=dlOnly",
    "NRCELL-10/NRREL-7:gnbPlmn:mnc=260",
    "NRCELL-10/NRREL-7:gnbPlmn:mcc=310",
    "NRCELL-10/NRREL-7:gnbPlmn:mncLength=3",

    "NRCELL-10/NRREL-3:gNbId=1",
    "NRCELL-10/NRREL-3:gNbIdLength=24",
    "NRCELL-10/NRREL-3:lcrId=3",
    "NRCELL-10/NRREL-3:sCellAdditionMethod=covBasedA1",
    "NRCELL-10/NRREL-3:sCellOperationalMode=dlOnly",
    "NRCELL-10/NRREL-3:gnbPlmn:mnc=260",
    "NRCELL-10/NRREL-3:gnbPlmn:mcc=310",
    "NRCELL-10/NRREL-3:gnbPlmn:mncLength=3",
]

A2_scellrelease = [
       "NRCELL:a2MeasSCellRelEnabled=rsrp",
       "NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0",
       "NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34",
       "NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms",
]

PARAMS_IN_SCF = PARAMS_CB008761 + NRCELL_3_NRREL + NRCELL_10_NRREL + A2_scellrelease + \
                ["NRCELL:timingAdvanceOffset=n25600",
                 "delete:NRBTS-1/NRCTRLTS-1/NRMTRACECU-1",
                 "MNL-1/MNLENT-1/FEATCADM-1:actOPGEnergySaving=false",
                 "NRBTS-1:actNrLBmMimoRTXPowerSaving=false",
                 "MNL-1:timeZone=(GMT+0) UTC"]

PARAMS_covBasedA1 = [
       "NRCELL-3/NRREL-10:sCellOperationalMode=dlAndUl",
       "NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1",
       "NRCELL-3/NRREL-7:sCellAdditionMethod=covBasedA1",
       "NRCELL-3/NRREL-10:sCellAdditionMethod=covBasedA1",
       "NRCELL:sCellDeactivationTimerGNB=ms1280",
]

PARAMS_blind = [
       "NRCELL-3/NRREL-2:sCellAdditionMethod=blind",
       "NRCELL-3/NRREL-7:sCellAdditionMethod=blind",
       "NRCELL-3/NRREL-10:sCellAdditionMethod=blind",
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

PM_Counters_Check_N1 = [
  f"NRDU-1:{SCELL_ACT_MODEL_ACCUR_AIML}>=0",
  f"NRDU-1:{SCELL_ACT_MODEL_NOT_ACCUR_AIML}>=0",
  f"NRDU-1:{SCELL_ACT_TRAIN_MOD_SUCC_AIML}=1",
  f"NRCELL-3:{SCELL_ACT_INFERENCE_REQ_AIML}>=0",
  f"NRCELL-3:{SCELL_ACT_INFERENCE_RES_AIML}>=0",
  f"NRCELL-3:{NUM_OF_NON_AIML_SCELL_ACT}>0",
  f"NRCELL-3:{NUM_OF_AIML_SCELL_ACT}>=0"
]
PM_Counters_Check_after_trained = [
  f"NRCELL-3:{NUM_OF_NON_AIML_SCELL_ACT}>=0",
  f"NRCELL-3:{NUM_OF_AIML_SCELL_ACT}>=1",
  f"NRCELL-3:{SCELL_ACT_INFERENCE_REQ_AIML}>0",
  f"NRCELL-3:{SCELL_ACT_INFERENCE_RES_AIML}>0",
  f"NRCELL-10:{NUM_OF_NON_AIML_SCELL_ACT}=0",
  f"NRCELL-10:{NUM_OF_AIML_SCELL_ACT}=0",
  f"NRCELL-10:{SCELL_ACT_INFERENCE_REQ_AIML}=0",
  f"NRCELL-10:{SCELL_ACT_INFERENCE_RES_AIML}=0"
]
PM_Counters_Check_after_trained_manyUEs = [
  f"NRCELL-3:{NUM_OF_NON_AIML_SCELL_ACT}>=0",
  f"NRCELL-3:{NUM_OF_AIML_SCELL_ACT}>=1",
  f"NRCELL-3:{SCELL_ACT_INFERENCE_REQ_AIML}>0",
  f"NRCELL-3:{SCELL_ACT_INFERENCE_RES_AIML}>0"
]
PM_Counters_Check_2T2F_covbase = [
  f"NRCELL-3:{NUM_OF_NON_AIML_SCELL_ACT}>=0",
  f"NRCELL-3:{NUM_OF_AIML_SCELL_ACT}>=1",
  f"NRCELL-3:{SCELL_ACT_INFERENCE_REQ_AIML}>0",
  f"NRCELL-3:{SCELL_ACT_INFERENCE_RES_AIML}>0"
]
PM_Counters_Check_2T2F_covbase_flagdisable = [
  f"NRCELL-3:{NUM_OF_NON_AIML_SCELL_ACT}=0",
  f"NRCELL-3:{NUM_OF_AIML_SCELL_ACT}=0",
  f"NRCELL-3:{SCELL_ACT_INFERENCE_REQ_AIML}=0",
  f"NRCELL-3:{SCELL_ACT_INFERENCE_RES_AIML}=0"
]
