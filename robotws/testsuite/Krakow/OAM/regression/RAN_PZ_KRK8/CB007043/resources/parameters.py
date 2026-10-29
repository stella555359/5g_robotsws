missing_parameters = [{"distName": "MRBTS-78113/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1", "operation": "update",
                       "parameters": [
                           {"parameterName": "nrCntRachStpSlCellDetHChFrq", "value": "900", "operation": "update"},
                           {"parameterName": "nrCntRachStpSlCellDetMsg3Thr", "value": "10", "operation": "update"},
                           {"parameterName": "nrCntRachStpSlCellDetThr", "value": "10000", "operation": "update"},
                           {"parameterName": "nrCntRachStpSlCellRecPh1Tmr", "value": "1810", "operation": "update"},
                           {"parameterName": "nrCntRachStpSlCellRecPhAct", "value": "Phase 1", "operation": "update"}]}]

preconditions_params = [
    "autRrcAtmpBasedSlCellDetHCheckFreq",
    "autRrcAtmpBasedSlCellDetRrcAtmpThr",
    "autRrcAtmpBasedSlCellDetRrcReqThr",
    "autRrcAtmpBasedSlCellRecPh1Timer",
    "autRrcAtmpBasedSlCellRecPh2Timer",
    "autRrcAtmpBasedSlCellRecPh3Timer",
    "autRrcBasedSlCellDetHCheckFreq",
    "autRrcBasedSlCellDetRrcSuccRateThr",
    "autRrcBasedSlCellDetRrcVolThr",
    "autRrcBasedSlCellRecPh1Timer",
    "autRrcBasedSlCellRecPh2Timer",
    "autRrcBasedSlCellRecPh3Timer",
    "autAntRecPwrBasedSlCellDetHCheckFreq",
    "autAntRecPwrBasedSlCellDetHighPwrThr",
    "autAntRecPwrBasedSlCellDetLowPwrThr",
    "autAntRecPwrBasedSlCellRecPh1Timer",
    "autAntRecPwrBasedSlCellRecPh2Timer",
    "autAntRecPwrBasedSlCellRecPh3Timer",
    "autAntTxPwrBasedSlCellDetHCheckFreq",
    "autAntTxPwrBasedSlCellDetThr",
    "autAntTxPwrBasedSlCellRecPh1Timer",
    "autAntTxPwrBasedSlCellRecPh2Timer",
    "autAntTxPwrBasedSlCellRecPh3Timer",
    "autPrachBasedSlCellDetHCheckFreq",
    "autPrachBasedSlCellRecPh1Timer",
    "autPrachBasedSlCellRecPh2Timer",
    "autPrachBasedSlCellRecPh3Timer",
    "autPrachBasedSlCellThr",
    "autRachBasedSlCellDetHCheckFreq",
    "autRachBasedSlCellRachAtmpThr",
    "autRachBasedSlCellRachMsg3Thr",
    "autRachBasedSlCellRecPh1Timer",
    "autRachBasedSlCellRecPh2Timer",
    "autRachBasedSlCellRecPh3Timer",
    "autS1CommBasedSlCellDetHCheckFreq",
    "autS1CommBasedSlCellDetRrcConnSetThr",
    "autS1CommBasedSlCellDetUeCtxSetAttThr",
    "autS1CommBasedSlCellDetUeS1SignConnEstAttThr",
    "autS1CommBasedSlCellRecPh1Timer",
    "autS1CommBasedSlCellRecPh2Timer",
    "autS1CommBasedSlCellRecPh3Timer"
]

preconditions_add_params = [
    "autRrcAtmpBasedSlCellRecPhase1Act",
    "autRrcAtmpBasedSlCellRecPhase2Act",
    "autRrcAtmpBasedSlCellRecPhase3Act",
    "autRrcBasedSlCellRecPhase1Act",
    "autRrcBasedSlCellRecPhase2Act",
    "autRrcBasedSlCellRecPhase3Act",
    "autAntRecPwrBasedSlCellRecPhase1Act",
    "autAntRecPwrBasedSlCellRecPhase2Act",
    "autAntRecPwrBasedSlCellRecPhase3Act",
    "autAntTxPwrBasedSlCellRecPhase1Act",
    "autAntTxPwrBasedSlCellRecPhase2Act",
    "autAntTxPwrBasedSlCellRecPhase3Act",
    "autRachBasedSlCellRecPhase1Act",
    "autRachBasedSlCellRecPhase2Act",
    "autRachBasedSlCellRecPhase3Act",
    "autS1CommBasedSlCellRecPhase1Act",
    "autS1CommBasedSlCellRecPhase2Act",
    "autS1CommBasedSlCellRecPhase3Act",
    "autPrachBasedSlCellRecPhase1Act",
    "autPrachBasedSlCellRecPhase2Act",
    "autPrachBasedSlCellRecPhase3Act",
]

postconditions_add_params = [
    "autRrcAtmpBasedSlCellRecPhaseAct",
    "autRrcBasedSlCellRecPhaseAct",
    "autAntRecPwrBasedSlCellRecPhaseAct",
    "autAntTxPwrBasedSlCellRecPhaseAct",
    "autPrachBasedSlCellRecPhaseAct",
    "autRachBasedSlCellRecPhaseAct",
    "autS1CommBasedSlCellRecPhaseAct"
]

false_parameters = [
    "actAutRrcAtmpBasedSlCellDetRec",
    "actAutRrcBasedSlCellDetRec",
    "actAutAntRecPwrBasedSlCellDetRec",
    "actAutAntTxPwrBasedSlCellDetRec",
    "actAutPrachBasedSlCellDetRec",
    "actAutRachBasedSlCellDetRec",
    "actAutS1CommBasedSlCellDetRec"
]

mandatory_parameters = [
    "maxNumSlCellRecActForBbuPerDay",
    "maxNumSlCellRecActForRfmPerDay",
    "maxNumSlCellRecActForBtsPerDay",
    "maxNumSlCellRecActForCellPerDay"
]

preconditions_parameters = preconditions_params + preconditions_add_params
postconditions_parameters = preconditions_params + postconditions_add_params
