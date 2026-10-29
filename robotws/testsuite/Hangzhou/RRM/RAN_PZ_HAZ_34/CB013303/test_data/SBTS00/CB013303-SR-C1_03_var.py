PARAMS_IN_SCF = [
    # CB013303
    "NRCELL-12:actDrbBlerTargetForBR=false",
    "NRCELL-10:actDrbBlerTargetForBR=true",
    "NRCELL-11:actDrbBlerTargetForBR=true",
    "NRBTS/NRPDSCHBRLA-1:dlDrbBlerTarget=5",
    "NRBTS/NRPDSCHBRLA-1:dlDrbDeltaCqiStepdown=500",
    "NRBTS/NRPDSCHBRLA-2:dlDrbBlerTarget=8",
    "NRBTS/NRPDSCHBRLA-2:dlDrbDeltaCqiStepdown=300",
    "NRBTS/NRPUSCHBRLA-1:ulDrbBlerTarget=5",
    "NRBTS/NRPUSCHBRLA-1:ulDrbDeltaSinrStepdown=800",
    "NRBTS/NRPUSCHBRLA-2:ulDrbBlerTarget=8",
    "NRBTS/NRPUSCHBRLA-2:ulDrbDeltaSinrStepdown=500",
    "NRBTS/NRDRB_5QI-3:fiveqiValueList=3",
    "NRBTS/NRDRB_5QI-3:nrDrbDN=MRBTS/NRBTS/NRDRB-3",
    "NRBTS/NRDRB-3:priorityLevel=30",
    "NRBTS/NRDRB-3:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-2",
    "NRBTS/NRDRB-3:nrPuschBRLaDN=MRBTS/NRBTS/NRPUSCHBRLA-2",
    # 5qi6 linked to NRPDSCHBRLA-1 NRPUSCHBRLA-1
    "NRBTS/NRDRB_5QI-6:fiveqiValueList=6",
    "NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS/NRBTS/NRDRB-6",
    "NRBTS/NRDRB-6:priorityLevel=60",
    "NRBTS/NRDRB-6:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-1",
    "NRBTS/NRDRB-6:nrPuschBRLaDN=MRBTS/NRBTS/NRPUSCHBRLA-1",
    # 5qi7 not linked
    "NRBTS/NRDRB_5QI-7:fiveqiValueList=7",
    "NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS/NRBTS/NRDRB-7",
    "NRBTS/NRDRB-7:priorityLevel=70",
    # 5qi8 linked to NRPDSCHBRLA-1 NRPUSCHBRLA-1
    "NRBTS/NRDRB_5QI-8:fiveqiValueList=8",
    "NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS/NRBTS/NRDRB-8",
    "NRBTS/NRDRB-8:priorityLevel=80",
    "NRBTS/NRDRB-8:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-1",
    "NRBTS/NRDRB-8:nrPuschBRLaDN=MRBTS/NRBTS/NRPUSCHBRLA-1",
    # other LA params
    "NRCELL:dllaBlerTarget=10",
    "NRCELL:ullaBlerTarget=10",
    "NRCELL:dllaDeltaCqiStepdown=250",
    "NRCELL:ullaDeltaSinrStepdown=250",
    # other features disabled
    "NRCELL:actAdaptiveReTxResMcs=false",
    "NRCELL:actDlLaDynBlerTarget=false"
]

DELTA_C1_03_1 = [
    "NRCELL-12:actDrbBlerTargetForBR=true",
    "delete:NRBTS/NRDRB-6:nrPdschBRLaDN",
    "delete:NRBTS/NRDRB-6:nrPuschBRLaDN"
]
