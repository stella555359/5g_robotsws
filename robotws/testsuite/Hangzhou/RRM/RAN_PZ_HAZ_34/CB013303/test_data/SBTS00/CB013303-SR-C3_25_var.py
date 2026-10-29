PARAMS_IN_SCF = [
    # reestablish
    "NRBTS:rrcReestabTypeSA=sameGNB",
    # CB013303
    "NRCELL:actDrbBlerTargetForBR=true",
    "NRBTS/NRPDSCHBRLA-1:dlDrbBlerTarget=5",
    "NRBTS/NRPDSCHBRLA-1:dlDrbDeltaCqiStepdown=500",
    "NRBTS/NRPDSCHBRLA-2:dlDrbBlerTarget=8",
    "NRBTS/NRPDSCHBRLA-2:dlDrbDeltaCqiStepdown=300",
    "NRBTS/NRPUSCHBRLA-1:ulDrbBlerTarget=5",
    "NRBTS/NRPUSCHBRLA-1:ulDrbDeltaSinrStepdown=800",
    "NRBTS/NRPUSCHBRLA-2:ulDrbBlerTarget=8",
    "NRBTS/NRPUSCHBRLA-2:ulDrbDeltaSinrStepdown=500",
    # 5qi3 linked to NRPDSCHBRLA-1 and NRPUSCHBRLA-1
    "NRCELL:actNonVoNRGbrService=true",
    "NRBTS/NRDRB_5QI-3:fiveqiValueList=3",
    "NRBTS/NRDRB_5QI-3:nrDrbDN=MRBTS/NRBTS/NRDRB-3",
    "NRBTS/NRDRB-3:priorityLevel=30",
    "NRBTS/NRDRB-3:nrPdschBRLaDN=NRPDSCHBRLA-1",
    "NRBTS/NRDRB-3:nrPuschBRLaDN=NRPUSCHBRLA-1",
    # 5qi6 linked to NRPDSCHBRL-2 and NRPUSCHBRLA-2
    "NRBTS/NRDRB_5QI-6:fiveqiValueList=6",
    "NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS/NRBTS/NRDRB-6",
    "NRBTS/NRDRB-6:priorityLevel=60",
    "NRBTS/NRDRB-6:nrPdschBRLaDN=NRPDSCHBRLA-2",
    "NRBTS/NRDRB-6:nrPuschBRLaDN=NRPUSCHBRLA-2",
    "NRBTS/NRDRB-6:rlcMode=RLC_AM",
    # 5qi7 not linked to NRPDSCHBRLA or NRPUSCHBRLA
    "NRBTS/NRDRB_5QI-7:fiveqiValueList=7",
    "NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS/NRBTS/NRDRB-7",
    "NRBTS/NRDRB-7:priorityLevel=70",
    "NRBTS/NRDRB-7:nrPdschBRLaDN=",
    "NRBTS/NRDRB-7:nrPuschBRLaDN=",
    "NRBTS/NRDRB-7:rlcMode=RLC_AM",
    # other LA params
    "NRCELL:dllaBlerTarget=10",
    "NRCELL:ullaBlerTarget=10",
    "NRCELL:dllaDeltaCqiStepdown=250",
    "NRCELL:ullaDeltaSinrStepdown=250",
    "NRCELL:ullaDeltaSinrMax=150",
    "NRCELL:ullaDeltaSinrMin=-300",
    "NRCELL:dllaDeltaCqiMax=150",
    "NRCELL:dllaDeltaCqiMin=-150",
    # other features
    "NRCELL:actDl256Qam=false",
    "NRCELL:actUl256Qam=true",
    "NRCELL:actUlDftSOfdm=false",
    "NRCELL:actEnhancedPDSCHSchSplSlot=false",
    "NRCELL:actAdaptiveReTxResMcs=false",
    "NRCELL:actDlLaDynBlerTarget=false",
    "NRCELL:actMcsPrbReductionFdmUl=false",
    # make sure no other UEs' interference
    "NRCELL-21:qRxLevMin=-45"
]
