from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

PARAMS_IN_SCF = [
       "NRDU-1:actMLScellAct=true",
       "NRDU-1:mlScellActParamSet1:mlDataCollectionPeriod=100ms",
       "MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:actMLMode=true",
       "MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:actMLTraining=true",
       "MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:mlTrainingParams:mlTrainingStartTime=2",
       "NRCELL-2:chBw=60MHz",
       "NRCELL-3:chBw=60MHz",
       "NRCELL:timingAdvanceOffset=n25600",
       "MNL-1:timeZone=(GMT+0) UTC"
]
GNB_SCELL_5_ADMI_REQ_SA = "M55138C03504"
GNB_SCELL_5_ADMI_SUCC_SA = "M55138C03507"

PM_Counters_Check_L007 = [
  f"NRCELL-2:{GNB_SCELL_5_ADMI_REQ_SA}=2",
  f"NRCELL-2:{GNB_SCELL_5_ADMI_SUCC_SA}=2"
]
