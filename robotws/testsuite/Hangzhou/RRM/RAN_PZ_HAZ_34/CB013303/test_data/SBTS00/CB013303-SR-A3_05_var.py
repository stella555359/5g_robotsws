from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id
PARAMS_IN_SCF = [
    # precondition for dependent feature
    "NRBTS:actDrbProfileForCellAggrLevel=disabled",
    "NRBTS/NRDU-1:actInterGnbCa=disabled",
    "NRBTS/NRDU-1:actConnectedModeMobilityCA=false",
    "NRBTS/NRDU-1:carrierAggregationSupportList=none",
    "NRBTS/NRCELL:increasePUSCHPrepTimeULCA=false",
    "NRBTS/NRCELL:maxNumScellsDlFr1=",
    "NRBTS/NRCELL:actDl256Qam=false",
    "NRBTS/NRCELL:actUl256Qam=false",
    "NRBTS/NRCELL:actNonVoNRGbrService=true",
    "NRCELL:dllaBlerTarget=10",
    "NRCELL:dllaDeltaCqiStepdown=250",
    "NRCELL:ullaBlerTarget=10",
    "NRCELL:ullaDeltaSinrStepdown=250",

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

    # 5qi6 linked to NRPDSCHBRLA-1 or NRPUSCHBRLA-1
    "NRBTS/NRDRB_5QI-6:fiveqiValueList=6",
    "NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS/NRBTS/NRDRB-6",
    "NRBTS/NRDRB-6:priorityLevel=60",
    "NRBTS/NRDRB-6:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-1",
    "NRBTS/NRDRB-6:nrPuschBRLaDN=MRBTS/NRBTS/NRPUSCHBRLA-1",
    "NRBTS/NRDRB-6:rlcMode=RLC_AM",

    # 5qi7 linked to NRPDSCHBRLA-2 or NRPUSCHBRLA-2
    "NRBTS/NRDRB_5QI-7:fiveqiValueList=7",
    "NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS/NRBTS/NRDRB-7",
    "NRBTS/NRDRB-7:priorityLevel=70",
    "NRBTS/NRDRB-7:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-2",
    "NRBTS/NRDRB-7:nrPuschBRLaDN=MRBTS/NRBTS/NRPUSCHBRLA-2",
    "NRBTS/NRDRB-7:rlcMode=RLC_AM",

    # 5qi3 linked to NRPDSCHBRLA-2 and NRPUSCHBRLA-2
    "NRBTS/NRDRB_5QI-3:fiveqiValueList=3",
    "NRBTS/NRDRB_5QI-3:nrDrbDN=MRBTS/NRBTS/NRDRB-3",
    "NRBTS/NRDRB-3:priorityLevel=30",
    "NRBTS/NRDRB-3:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-2",
    "NRBTS/NRDRB-3:nrPuschBRLaDN=NRPUSCHBRLA-2",

    # 5qi4 linked to NRPDSCHBRLA-1 and NRPUSCHBRLA-1
    "NRBTS/NRDRB_5QI-4:fiveqiValueList=4",
    "NRBTS/NRDRB_5QI-4:nrDrbDN=MRBTS/NRBTS/NRDRB-4",
    "NRBTS/NRDRB-4:priorityLevel=50",
    "NRBTS/NRDRB-4:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-1",
    "NRBTS/NRDRB-4:nrPuschBRLaDN=NRPUSCHBRLA-1",

    # 5qi9 linked to NRPDSCHBRLA-1 and NRPUSCHBRLA-1
    "NRBTS/NRDRB_5QI-9:fiveqiValueList=9",
    "NRBTS/NRDRB_5QI-9:nrDrbDN=MRBTS/NRBTS/NRDRB-9",
    "NRBTS/NRDRB-9:priorityLevel=50",
    "NRBTS/NRDRB-9:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-1",
    "NRBTS/NRDRB-9:nrPuschBRLaDN=NRPUSCHBRLA-1",
]

DELTA_A3_05_1 = [
    "NRBTS/NRPDSCHBRLA-1:dlDrbBlerTarget=10",
    "NRBTS/NRPDSCHBRLA-1:dlDrbDeltaCqiStepdown=250",
    "NRBTS/NRPUSCHBRLA-1:ulDrbBlerTarget=10",
    "NRBTS/NRPUSCHBRLA-1:ulDrbDeltaSinrStepdown=250",
]

DELTA_A3_05_2 = [
    "NRBTS/NRDRB-7:priorityLevel=55",
]

DELTA_recovery = [
    "NRBTS/NRPDSCHBRLA-1:dlDrbBlerTarget=5",
    "NRBTS/NRPDSCHBRLA-1:dlDrbDeltaCqiStepdown=500",
    "NRBTS/NRPUSCHBRLA-1:ulDrbBlerTarget=5",
    "NRBTS/NRPUSCHBRLA-1:ulDrbDeltaSinrStepdown=800",
    "NRBTS/NRDRB-7:priorityLevel=70",
]
