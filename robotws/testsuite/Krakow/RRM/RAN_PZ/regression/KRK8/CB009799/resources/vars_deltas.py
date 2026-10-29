import datetime

autAntRecPwrBasedSlCellDetHCheckFreq = 120
autAntRecPwrBasedSlCellRecPh1Timer = 130
autAntRecPwrBasedSlCellRecPh2Timer = 130
autAntRecPwrBasedSlCellRecPh3Timer = 300
time_to_wait_regarding_to_timer = autAntRecPwrBasedSlCellRecPh1Timer + 30

delta_force_reset_true = [
    {"distName": "MRBTS-{}/MNL-1/MNLENT-1/FMCADM-1", "operation": "update",
     "parameters": [
         {
             "parameterName": "actForceAutoReset",
             "value": "true",
             "operation": "update"
         },
         {
             "parameterName": "actForceUnitAutoReset",
             "value": "true",
             "operation": "update"
         }
     ]
     }
]
delta_force_reset_false = [
    {"distName": "MRBTS-{}/MNL-1/MNLENT-1/FMCADM-1", "operation": "update",
     "parameters": [
         {
             "parameterName": "actForceAutoReset",
             "value": "false",
             "operation": "update"
         },
         {
             "parameterName": "actForceUnitAutoReset",
             "value": "false",
             "operation": "update"
         }
     ]
     }
]
delta_disable_7043 = [
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actAutAntRecPwrAntBasedSlCellDetRec",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actAutAntRecPwrBasedSlCellDetRec",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actAutAntRecPwrDiff2AntBasedSlCellDetRec",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actNrAutRxPwrSlCellDetRec",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actNrAutRxPwrAntSlCellDetRec",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actNrAutRxPwrDiff2AntSlCellDetRec",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actNrAutTxPwrSlCellDetRec",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actAutAntTxPwrBasedSlCellDetRec",
                "value": "false",
                "operation": "update"
            }
        ]
    }
]

delta_test_011_phase1 = [
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1", "operation": "update",
        "parameters": [
            {
                "parameterName": "actNrAutTxPwrSlCellDetRec", "value": "true", "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1", "operation": "update",
        "parameters": [
            {
                "parameterName": "nrTxPwrSlCellDetHChFrq", "value": "120", "operation": "update"
            },
            {
                "parameterName": "nrTxPwrSlCellDetThr", "value": "500", "operation": "update"
            },
            {
                "parameterName": "nrTxPwrSlCellRecPh1Tmr", "value": "130", "operation": "update"
            },
            {
                "parameterName": "nrTxPwrSlCellRecPh2Tmr", "value": "130", "operation": "update"
            },
            {
                "parameterName": "nrTxPwrSlCellRecPh3Tmr", "value": "130", "operation": "update"
            },
            {
                "parameterName": "nrTxPwrSlCellRecPhAct", "value": "Phase 1", "operation": "update"
            }
        ]
    }
]

delta_test_011_phase2 = [
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1", "operation": "update",
        "parameters": [
            {
                "parameterName": "actNrAutTxPwrSlCellDetRec", "value": "true", "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1", "operation": "update",
        "parameters": [
            {
                "parameterName": "nrTxPwrSlCellRecPhAct", "value": "Phase 2", "operation": "update"
            }
        ]
    }
]

delta_test_011_phase3 = [
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1", "operation": "update",
        "parameters": [
            {
                "parameterName": "actNrAutTxPwrSlCellDetRec", "value": "true", "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1", "operation": "update",
        "parameters": [
            {
                "parameterName": "nrTxPwrSlCellRecPhAct", "value": "Phase 3", "operation": "update"
            }
        ]
    }
]

delta_test_010_phase1 = [
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actNrAutRxPwrSlCellDetRec",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actNrAutRxPwrAntSlCellDetRec",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actNrAutRxPwrDiff2AntSlCellDetRec",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumSlCellRecActForBbuPerDay",
                "value": "48",
                "operation": "update"
            },
            {
                "parameterName": "maxNumSlCellRecActForBtsPerDay",
                "value": "48",
                "operation": "update"
            },
            {
                "parameterName": "nrRxPwrSlCellDetHChFrq",
                "value": "120",
                "operation": "update"
            },
            {
                "parameterName": "nrRxPwrSlCellRecPh1Tmr",
                "value": "130",
                "operation": "update"
            },
            {
                "parameterName": "nrRxPwrSlCellRecPh2Tmr",
                "value": "130",
                "operation": "update"
            },
            {
                "parameterName": "nrRxPwrSlCellRecPh3Tmr",
                "value": "130",
                "operation": "update"
            },
            {
                "parameterName": "nrRxPwrSlCellDetHighPwrThr",
                "value": "1800",
                "operation": "update"
            },
            {
                "parameterName": "nrRxPwrSlCellDetHighPwrThrAnt",
                "value": "1800",
                "operation": "update"
            },
            {
                "parameterName": "nrRxPwrSlCellDetLowPwrThr",
                "value": "1790",
                "operation": "update"
            },
            {
                "parameterName": "nrRxPwrSlCellDetLowPwrThrAnt",
                "value": "1790",
                "operation": "update"},
            {
                "parameterName": "nrRxPwrSlCellRecPhAct",
                "value": "",
                "operation": "update"
            },
            {
                "parameterName": "nrRxPwrSlCellRecPhAct", "value": "Phase 1", "operation": "update"
            }
        ]
    }
]

delta_test_010_phase2 = [
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actNrAutRxPwrSlCellDetRec",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actNrAutRxPwrAntSlCellDetRec",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actNrAutRxPwrDiff2AntSlCellDetRec",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1",
        "operation": "update",
        "parameters": [

            {
                "parameterName": "nrRxPwrSlCellRecPhAct", "value": "Phase 2", "operation": "update"
            }
        ]
    }
]

delta_test_010_phase3 = [
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actNrAutRxPwrSlCellDetRec",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actNrAutRxPwrAntSlCellDetRec",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actNrAutRxPwrDiff2AntSlCellDetRec",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1",
        "operation": "update",
        "parameters": [

            {
                "parameterName": "nrRxPwrSlCellRecPhAct", "value": "Phase 3", "operation": "update"
            }
        ]
    }
]

sleeping_cell_object_creation = [
    {"distName": "MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1", "operation": "create", "parameters": [
        {"parameterName": "autAntRecPwrBasedSlCellDetDiff2AntCellThr", "value": "3200", "operation": "update"},
        {"parameterName": "autAntRecPwrBasedSlCellDetHCheckFreq", "value": "900", "operation": "update"},
        {"parameterName": "autAntRecPwrBasedSlCellDetHighPwrThr", "value": "1800", "operation": "update"},
        {"parameterName": "autAntRecPwrBasedSlCellDetHighPwrThrAnt", "value": "1800", "operation": "update"},
        {"parameterName": "autAntRecPwrBasedSlCellDetLowPwrThr", "value": "400", "operation": "update"},
        {"parameterName": "autAntRecPwrBasedSlCellDetLowPwrThrAnt", "value": "400", "operation": "update"},
        {"parameterName": "autAntRecPwrBasedSlCellRecPh1Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autAntRecPwrBasedSlCellRecPh2Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autAntRecPwrBasedSlCellRecPh3Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autAntRecPwrBasedSlCellRecPhaseAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "autAntTxPwrBasedSlCellDetHCheckFreq", "value": "900", "operation": "update"},
        {"parameterName": "autAntTxPwrBasedSlCellDetThr", "value": "0", "operation": "update"},
        {"parameterName": "autAntTxPwrBasedSlCellRecPh1Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autAntTxPwrBasedSlCellRecPh2Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autAntTxPwrBasedSlCellRecPh3Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autAntTxPwrBasedSlCellRecPhaseAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "autPrachBasedSlCellDetHCheckFreq", "value": "900", "operation": "update"},
        {"parameterName": "autPrachBasedSlCellRecPh1Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autPrachBasedSlCellRecPh2Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autPrachBasedSlCellRecPh3Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autPrachBasedSlCellRecPhaseAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "autPrachBasedSlCellThr", "value": "50", "operation": "update"},
        {"parameterName": "autRachBasedSlCellDetHCheckFreq", "value": "900", "operation": "update"},
        {"parameterName": "autRachBasedSlCellRachAtmpThr", "value": "10000", "operation": "update"},
        {"parameterName": "autRachBasedSlCellRachMsg3Thr", "value": "10", "operation": "update"},
        {"parameterName": "autRachBasedSlCellRecPh1Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autRachBasedSlCellRecPh2Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autRachBasedSlCellRecPh3Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autRachBasedSlCellRecPhaseAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "autRrcAtmpBasedSlCellDetHCheckFreq", "value": "900", "operation": "update"},
        {"parameterName": "autRrcAtmpBasedSlCellDetRrcAtmpThr", "value": "1000", "operation": "update"},
        {"parameterName": "autRrcAtmpBasedSlCellDetRrcReqThr", "value": "0", "operation": "update"},
        {"parameterName": "autRrcAtmpBasedSlCellRecPh1Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autRrcAtmpBasedSlCellRecPh2Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autRrcAtmpBasedSlCellRecPh3Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autRrcAtmpBasedSlCellRecPhaseAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "autRrcBasedSlCellDetHCheckFreq", "value": "900", "operation": "update"},
        {"parameterName": "autRrcBasedSlCellDetRrcSuccRateThr", "value": "50", "operation": "update"},
        {"parameterName": "autRrcBasedSlCellDetRrcVolThr", "value": "100", "operation": "update"},
        {"parameterName": "autRrcBasedSlCellRecPh1Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autRrcBasedSlCellRecPh2Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autRrcBasedSlCellRecPh3Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autRrcBasedSlCellRecPhaseAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "autS1CommBasedSlCellDetHCheckFreq", "value": "900", "operation": "update"},
        {"parameterName": "autS1CommBasedSlCellDetRrcConnSetThr", "value": "100", "operation": "update"},
        {"parameterName": "autS1CommBasedSlCellDetUeCtxSetAttThr", "value": "100", "operation": "update"},
        {"parameterName": "autS1CommBasedSlCellDetUeS1SignConnEstAttThr", "value": "1000", "operation": "update"},
        {"parameterName": "autS1CommBasedSlCellRecPh1Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autS1CommBasedSlCellRecPh2Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autS1CommBasedSlCellRecPh3Timer", "value": "1810", "operation": "update"},
        {"parameterName": "autS1CommBasedSlCellRecPhaseAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "maxNumSlCellRecActForBbuPerDay", "value": "1", "operation": "update"},
        {"parameterName": "maxNumSlCellRecActForBtsPerDay", "value": "1", "operation": "update"},
        {"parameterName": "maxNumSlCellRecActForCellPerDay", "value": "1", "operation": "update"},
        {"parameterName": "maxNumSlCellRecActForRfmPerDay", "value": "1", "operation": "update"},
        {"parameterName": "nrCntRachStpSlCellDetHChFrq", "value": "900", "operation": "update"},
        {"parameterName": "nrCntRachStpSlCellDetMsg3Thr", "value": "10", "operation": "update"},
        {"parameterName": "nrCntRachStpSlCellDetThr", "value": "10000", "operation": "update"},
        {"parameterName": "nrCntRachStpSlCellRecPh1Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrCntRachStpSlCellRecPh2Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrCntRachStpSlCellRecPh3Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrCntRachStpSlCellRecPhAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "nrDegAdmCtrlSlCellDetHChFrq", "value": "900", "operation": "update"},
        {"parameterName": "nrDegAdmCtrlSlCellDetMinPrcThr", "value": "100", "operation": "update"},
        {"parameterName": "nrDegAdmCtrlSlCellDetThr", "value": "70", "operation": "update"},
        {"parameterName": "nrDegAdmCtrlSlCellRecPh1Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrDegAdmCtrlSlCellRecPh3Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrDegAdmCtrlSlCellRecPhAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "nrDegNgComSlCellDetHChFrq", "value": "900", "operation": "update"},
        {"parameterName": "nrDegNgComSlCellDetInUeMsgThr", "value": "1000", "operation": "update"},
        {"parameterName": "nrDegNgComSlCellDetRrcConStThr", "value": "100", "operation": "update"},
        {"parameterName": "nrDegNgComSlCellDetUeCtStRqThr", "value": "100", "operation": "update"},
        {"parameterName": "nrDegNgComSlCellRecPh1Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrDegNgComSlCellRecPh3Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrDegNgComSlCellRecPhAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "nrPrachAccSltSlCellDetHChFrq", "value": "900", "operation": "update"},
        {"parameterName": "nrPrachAccSltSlCellDetThr", "value": "80", "operation": "update"},
        {"parameterName": "nrPrachAccSltSlCellRecPh1Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrPrachAccSltSlCellRecPh2Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrPrachAccSltSlCellRecPh3Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrPrachAccSltSlCellRecPhAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "nrRrcConStAtSlCellDetHChFrq", "value": "900", "operation": "update"},
        {"parameterName": "nrRrcConStAtSlCellDetRrcAtThr", "value": "1000", "operation": "update"},
        {"parameterName": "nrRrcConStAtSlCellDetRrcMinThr", "value": "50", "operation": "update"},
        {"parameterName": "nrRrcConStAtSlCellRecPh1Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrRrcConStAtSlCellRecPh2Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrRrcConStAtSlCellRecPh3Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrRrcConStAtSlCellRecPhAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellCuRecPh1Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellCuRecPh3Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellCuRecPhAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellDetCuHChFrq", "value": "900", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellDetCuRrcMinThr", "value": "100", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellDetCuThr", "value": "70", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellDetDuHChFrq", "value": "900", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellDetDuRrcMinThr", "value": "100", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellDetDuThr", "value": "70", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellDuRecPh1Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellDuRecPh2Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellDuRecPh3Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrRrcSuccRateSlCellDuRecPhAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "nrRxPwrSlCellDetDiff2AntCellThr", "value": "3200", "operation": "update"},
        {"parameterName": "nrRxPwrSlCellDetHChFrq", "value": "900", "operation": "update"},
        {"parameterName": "nrRxPwrSlCellDetHighPwrThr", "value": "1800", "operation": "update"},
        {"parameterName": "nrRxPwrSlCellDetHighPwrThrAnt", "value": "1800", "operation": "update"},
        {"parameterName": "nrRxPwrSlCellDetLowPwrThr", "value": "400", "operation": "update"},
        {"parameterName": "nrRxPwrSlCellDetLowPwrThrAnt", "value": "400", "operation": "update"},
        {"parameterName": "nrRxPwrSlCellRecPh1Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrRxPwrSlCellRecPh2Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrRxPwrSlCellRecPh3Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrRxPwrSlCellRecPhAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "nrSgnbAddCplSlCellDetHChFrq", "value": "900", "operation": "update"},
        {"parameterName": "nrSgnbAddCplSlCellDetMinResThr", "value": "1", "operation": "update"},
        {"parameterName": "nrSgnbAddCplSlCellDetThr", "value": "70", "operation": "update"},
        {"parameterName": "nrSgnbAddCplSlCellRecPh1Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrSgnbAddCplSlCellRecPh2Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrSgnbAddCplSlCellRecPh3Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrSgnbAddCplSlCellRecPhAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "nrTxPwrSlCellDetHChFrq", "value": "900", "operation": "update"},
        {"parameterName": "nrTxPwrSlCellDetThr", "value": "0", "operation": "update"},
        {"parameterName": "nrTxPwrSlCellRecPh1Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrTxPwrSlCellRecPh2Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrTxPwrSlCellRecPh3Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrTxPwrSlCellRecPhAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "nrUeCtxStpRtSlCellDetHChFrq", "value": "900", "operation": "update"},
        {"parameterName": "nrUeCtxStpRtSlCellDetMinReqThr", "value": "1", "operation": "update"},
        {"parameterName": "nrUeCtxStpRtSlCellDetThr", "value": "70", "operation": "update"},
        {"parameterName": "nrUeCtxStpRtSlCellRecPh1Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrUeCtxStpRtSlCellRecPh2Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrUeCtxStpRtSlCellRecPh3Tmr", "value": "1810", "operation": "update"},
        {"parameterName": "nrUeCtxStpRtSlCellRecPhAct", "value": "Phase 1", "operation": "update"},
        {"parameterName": "slCellDetRecMaintWindowSchedTimeEnd", "value": "05:00", "operation": "update"},
        {"parameterName": "slCellDetRecMaintWindowSchedTimeStart", "value": "22:00", "operation": "update"},
        {"parameterName": "slCellDetRecMaintWindowSchedWeekCal", "value": "0", "operation": "update"}]}
]

maintanance_enabled = [
    {"distName": "MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1", "operation": "update", "parameters": [
        {"parameterName": "slCellDetRecMaintWindowSchedMonthCalList", "value": [datetime.datetime.today().day],
         "operation": "update"},
        {"parameterName": "slCellDetRecMaintWindowSchedTimeEnd", "value": "23:00", "operation": "update"},
        {"parameterName": "slCellDetRecMaintWindowSchedTimeStart", "value": "01:00", "operation": "update"},
        {"parameterName": "slCellDetRecMaintWindowSchedWeekCal", "value": "0", "operation": "update"}]}
]

maintanance_disabled = [
    {"distName": "MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1", "operation": "update", "parameters": [
        {"parameterName": "slCellDetRecMaintWindowSchedMonthCalList",
         "value": [(datetime.datetime.now() + datetime.timedelta(1)).day],
         "operation": "update"},
        {"parameterName": "slCellDetRecMaintWindowSchedTimeEnd", "value": "23:00", "operation": "update"},
        {"parameterName": "slCellDetRecMaintWindowSchedTimeStart", "value": "01:00", "operation": "update"},
        {"parameterName": "slCellDetRecMaintWindowSchedWeekCal", "value": "0", "operation": "update"}]}
]
