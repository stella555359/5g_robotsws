PARAMS_IN_SCF = [
    # CB013303
    "NRCELL:actDrbBlerTargetForBR=true",
    "NRBTS/NRPDSCHBRLA-1:dlDrbBlerTarget=8",
    "NRBTS/NRPDSCHBRLA-1:dlDrbDeltaCqiStepdown=250",
    "NRBTS/NRPDSCHBRLA-2:dlDrbBlerTarget=5",
    "NRBTS/NRPDSCHBRLA-2:dlDrbDeltaCqiStepdown=160",
    # 5qi6 linked to NRPDSCHBRLA-1
    "NRBTS/NRDRB_5QI-6:fiveqiValueList=6",
    "NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS/NRBTS/NRDRB-6",
    "NRBTS/NRDRB-6:priorityLevel=60",
    "NRBTS/NRDRB-6:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-1",
    "NRBTS/NRDRB-6:nrPuschBRLaDN= ",
    # 5qi8 linked to NRPDSCHBRLA-2
    "NRBTS/NRDRB_5QI-8:fiveqiValueList=8",
    "NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS/NRBTS/NRDRB-8",
    "NRBTS/NRDRB-8:priorityLevel=55",
    "NRBTS/NRDRB-8:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-2",
    "NRBTS/NRDRB-8:nrPuschBRLaDN= ",
    # # 5qi7 not linked
    "NRBTS/NRDRB_5QI-7:fiveqiValueList=7",
    "NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS/NRBTS/NRDRB-7",
    "NRBTS/NRDRB-9:priorityLevel=70",
    "NRBTS/NRDRB-9:nrPdschBRLaDN= ",
    "NRBTS/NRDRB-9:nrPuschBRLaDN= ",
    # other LA params
    "NRCELL:dllaBlerTarget=10",
    "NRCELL:dllaDeltaCqiStepdown=250",
    "NRCELL:ullaDeltaSinrMax=150",
    "NRCELL:ullaDeltaSinrMin=-300",
    "NRCELL:dllaDeltaCqiMax=150",
    "NRCELL:dllaDeltaCqiMin=-150",
    # other features disabled
    "NRBTS/NRDU-1:carrierAggregationSupportList=none",
    "NRCELL:actUlMuMimo=false",
    "NRCELL:actAdaptiveReTxResMcs=false",
    # other features enabled
    "NRCELL:actDl256Qam=true",
    "NRCELL:actUl256Qam=true",
    "NRCELL:actDlLaDynBlerTarget=true",
    "NRCELL:dynamicBlerTableType=MAD algorithm",
    # make sure no other UEs' interference
    "NRCELL-21:qRxLevMin=-45"
]
