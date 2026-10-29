from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id
PARAMS_IN_SCF = [
    # precondition for dependent feature
    "NRBTS:sCellActivationMethod=bufferBased",
    "NRBTS/NRDU-1:actInterGnbCa=DLOnly",
    "NRBTS/NRDU-1:actConnectedModeMobilityCA=true",
    "NRBTS/NRDU-1:actInterNumerologyCa=true",
    "NRBTS/NRDU-1:dlToUlContributionRatio=100",
    "NRBTS/NRDU-1:flexibleCAMode=NumberCellAmount",
    "NRBTS/NRDU-1:fr1UlCaPreferred=ulCaPreferred",
    "NRBTS/NRDU-1:carrierAggregationSupportList="
    "ca_Fdd_Fr1Tdd_Sa,"
    "ca_Fdd_Fr1Tdd_Sa_WithUl,"
    "ca_Fdd_Any_Sa,ca_Fdd_Fdd,"
    "ca_Fr1Tdd_Fdd_Sa_WithUl,"
    "ca_Fr1Tdd_Fdd_Sa,"
    "ca_Fr1Tdd_Any_Sa,"
    "ca_Fr1Tdd_Sa,"
    "ca_Fdd_Fdd_Sa_WithUl",
    "NRBTS/NRCELL:increasePUSCHPrepTimeULCA=false",
    "NRBTS/NRCELL:maxNumScellsDlFr1=3",
    "NRCELL-1/NRREL-1:gNbId=37398",
    "NRCELL-1/NRREL-1:lcrId=10",
    "NRCELL-1/NRREL-1:sCellAdditionMethod=blind",
    "NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl",
    "NRCELL-1/NRREL-3:gNbId=37398",
    "NRCELL-1/NRREL-3:lcrId=12",
    "NRCELL-1/NRREL-3:sCellAdditionMethod=blind",
    "NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly",
    "NRCELL-1/NRREL-2:sCellAdditionMethod=",
    "NRCELL-1/NRREL-2:sCellOperationalMode=",
    "NRCELL-1/NRREL-4:sCellAdditionMethod=",
    "NRCELL-1/NRREL-4:sCellOperationalMode=",
    "NRCELL-10/NRREL-1:sCellAdditionMethod=",
    "NRCELL-10/NRREL-1:sCellOperationalMode=",
    "NRCELL-10/NRREL-2:sCellAdditionMethod=",
    "NRCELL-10/NRREL-2:sCellOperationalMode=",
    "NRCELL-10/NRREL-3:sCellAdditionMethod=",
    "NRCELL-10/NRREL-3:sCellOperationalMode=",
    "NRCELL-10/NRREL-4:sCellAdditionMethod=",
    "NRCELL-10/NRREL-4:sCellOperationalMode=",
    "NRCELL-12/NRREL-1:sCellAdditionMethod=",
    "NRCELL-12/NRREL-1:sCellOperationalMode=",
    "NRCELL-12/NRREL-2:sCellAdditionMethod=",
    "NRCELL-12/NRREL-2:sCellOperationalMode=",
    "NRCELL-12/NRREL-3:sCellAdditionMethod=",
    "NRCELL-12/NRREL-3:sCellOperationalMode=",
    "NRCELL-12/NRREL-4:sCellAdditionMethod=",
    "NRCELL-12/NRREL-4:sCellOperationalMode=",
    "NRCELL:actAdaptiveReTxResMcs=false",
    "NRCELL:actAdaptiveReTxResMcsEnh=false",
    "NRCELL:actDlLaDynBlerTarget=false",
    "NRCELL:actMcsPrbReductionFdmUl=false",
    "NRCELL:actDl256Qam=true",
    "NRCELL:actUl256Qam=true",
    "NRCELL:actUlDftSOfdm=false",
    "NRCELL:actUlSlotAgg=Disabled",
    "NRCELL:actNonVoNRGbrService=true",
    "NRCELL:actGBRAdmissionControl=GBRService",
    "NRCELL:dllaBlerTarget=10",
    "NRCELL:dllaDeltaCqiStepdown=250",
    "NRCELL:ullaDeltaSinrMax=150",
    "NRCELL:ullaDeltaSinrMin=-300",
    "NRCELL:dllaDeltaCqiMax=150",
    "NRCELL:dllaDeltaCqiMin=-150",
    "NRCELL:actEnhancedPDSCHSchSplSlot=false",
    "NRCELL:actPdcchSharingWithPdsch=false",
    "NRCELL:actUlTransPreEnhRankSwitchIwk=false",
    "NRCELL:actUlTransPreEnhSinrMetric=false",
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
    # 5qi6 linked to NRPDSCHBRLA or NRPUSCHBRLA
    "NRBTS/NRDRB_5QI-6:fiveqiValueList=6",
    "NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS/NRBTS/NRDRB-6",
    "NRBTS/NRDRB-6:priorityLevel=60",
    "NRBTS/NRDRB-6:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-1",
    "NRBTS/NRDRB-6:nrPuschBRLaDN=MRBTS/NRBTS/NRPUSCHBRLA-1",
    "NRBTS/NRDRB-6:rlcMode=RLC_AM",
    # 5qi8 linked to NRPDSCHBRLA-2 and NRPUSCHBRLA-2
    "NRBTS/NRDRB_5QI-8:fiveqiValueList=8",
    "NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS/NRBTS/NRDRB-8",
    "NRBTS/NRDRB-8:priorityLevel=30",
    "NRBTS/NRDRB-8:nrPdschBRLaDN=MRBTS/NRBTS/NRPDSCHBRLA-2",
    "NRBTS/NRDRB-8:nrPuschBRLaDN=NRPUSCHBRLA-2"
]
