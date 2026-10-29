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
       "NRCELL-4/NRREL-6:cellIndividualSsbRsrpOffset=0dB",
       "NRCELL-4/NRREL-6:cellIndividualSsbRsrpOffset=0dB",
       "NRCELL-4/NRREL-6:cellIndividualSsbRsrqOffset=0dB",
       "NRCELL-4/NRREL-6:gNbId=37562",
       "NRCELL-4/NRREL-6:gNbIdLength=22",
       "NRCELL-4/NRREL-6:handoverAllowedSA=allowed",
       "NRCELL-4/NRREL-6:handoverAllowedSARedCap=forbidden",
       "NRCELL-4/NRREL-6:lcrId=6",
       "NRCELL-4/NRREL-6:nrDcAllowed=false",
       "NRCELL-4/NRREL-6:removeNotAllowed=false",
       "NRCELL-4/NRREL-6:sCellAdditionMethod=blind",
       "NRCELL-4/NRREL-6:sCellOperationalMode=dlOnly",
       "NRCELL-4/NRREL-6:gnbPlmn:mcc=262",
       "NRCELL-4/NRREL-6:gnbPlmn:mnc=3",
       "NRCELL-4/NRREL-6:gnbPlmn:mncLength=2",
       "NRCELL-4/NRREL-5:sCellAdditionMethod=blind",
       "NRCELL-4/NRREL-11:sCellAdditionMethod=blind",
       "NRCELL-4/NRREL-12:sCellAdditionMethod=blind",
       "NRCELL-4/NRREL-13:sCellAdditionMethod=blind",
       "NRCELL-4/NRREL-14:sCellAdditionMethod=blind",
]
PARAMS_IN_SCF = PARAMS_CB008761 + \
                ["MNL-1:timeZone=(GMT+0) UTC"]

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
  f"NRCELL-6:{SCELL_ACT_INFERENCE_REQ_AIML}>=0",
  f"NRCELL-6:{SCELL_ACT_INFERENCE_RES_AIML}>=0",
  f"NRCELL-6:{NUM_OF_NON_AIML_SCELL_ACT}>0",
  f"NRCELL-6:{NUM_OF_AIML_SCELL_ACT}>=0"
]
PM_Counters_Check_after_trained = [
  f"NRCELL-6:{NUM_OF_NON_AIML_SCELL_ACT}>=0",
  f"NRCELL-6:{NUM_OF_AIML_SCELL_ACT}>=1",
  f"NRCELL-6:{SCELL_ACT_INFERENCE_REQ_AIML}>0",
  f"NRCELL-6:{SCELL_ACT_INFERENCE_RES_AIML}>0"
]
