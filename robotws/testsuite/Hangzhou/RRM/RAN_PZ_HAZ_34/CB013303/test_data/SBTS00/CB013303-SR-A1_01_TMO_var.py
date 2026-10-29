PARAMS_IN_SCF = [
    # CB013303
    "NRCELL:actDrbBlerTargetForBR=true",
    "NRBTS/NRPDSCHBRLA-1:dlDrbBlerTarget=5",
    "NRBTS/NRPDSCHBRLA-1:dlDrbDeltaCqiStepdown=500",
    "NRBTS/NRPDSCHBRLA-2:dlDrbBlerTarget=8",
    "NRBTS/NRPDSCHBRLA-2:dlDrbDeltaCqiStepdown=300",
    # 5qi6 linked to NRPDSCHBRLA-1
    "NRBTS/NRDRB_5QI-2:fiveqiValueList=6",
    "NRBTS/NRDRB_5QI-2:nrDrbDN=MRBTS/NRBTS/NRDRB-11",
    "NRBTS/NRDRB-11:priorityLevel=60",
    "NRBTS/NRDRB-11:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-1",
    "NRBTS/NRDRB-11:nrPuschBRLaDN= ",
    "delete:NRBTS/NRDRB:nrPdschHRLaDN",
    "delete:NRBTS/NRDRB:nrPuschHRLaDN",
    "NRBTS/NRDRB:nrPdschHRLaDN=NRPDSCHHRLA-1",
    "NRBTS/NRDRB:nrPuschHRLaDN= ",
    # 5qi8 linked to NRPDSCHBRLA-2
    "NRBTS/NRDRB_5QI-4:fiveqiValueList=8",
    "NRBTS/NRDRB_5QI-4:nrDrbDN=MRBTS/NRBTS/NRDRB-13",
    "NRBTS/NRDRB-13:priorityLevel=80",
    "NRBTS/NRDRB-13:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-2",
    "NRBTS/NRDRB-13:nrPuschBRLaDN= ",
    # 5qi9 not linked
    "NRBTS/NRDRB_5QI-5:fiveqiValueList=9",
    "NRBTS/NRDRB_5QI-5:nrDrbDN=MRBTS/NRBTS/NRDRB-14",
    "NRBTS/NRDRB-14:priorityLevel=55",
    "NRBTS/NRDRB-14:nrPdschBRLaDN= ",
    "NRBTS/NRDRB-14:nrPuschBRLaDN= ",
    # other LA params
    "NRCELL:dllaBlerTarget=10",
    "NRCELL:dllaDeltaCqiStepdown=250",
    "NRCELL:ullaDeltaSinrMax=150",
    "NRCELL:ullaDeltaSinrMin=-300",
    "NRCELL:dllaDeltaCqiMax=150",
    "NRCELL:dllaDeltaCqiMin=-150",
    # other features disabled
    # "NRBTS/NRDU-1:carrierAggregationSupportList=none",
    # "NRCELL:actDl256Qam=false",
    # "NRCELL:actAdaptiveReTxResMcs=false",
    "NRCELL:actDlLaDynBlerTarget=false",
    # make sure no other UEs' interference
    "NRCELL-1:qRxLevMin=-45"
]

DELTA_A1_01_1 = [
    "NRBTS/NRDRB-11:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-1",
    "NRBTS/NRPDSCHBRLA-2:dlDrbBlerTarget=8",
    "NRBTS/NRPDSCHBRLA-2:dlDrbDeltaCqiStepdown=300",
]

DELTA_A1_01_2 = [
    "delete:NRBTS/NRDRB-11:nrPdschBRLaDN",
    "NRBTS/NRPDSCHBRLA-2:dlDrbBlerTarget=12",
    "NRBTS/NRPDSCHBRLA-2:dlDrbDeltaCqiStepdown=600",
]
