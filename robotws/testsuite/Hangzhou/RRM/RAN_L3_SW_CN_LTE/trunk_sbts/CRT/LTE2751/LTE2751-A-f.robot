*** Settings ***
Suite Setup       Common Suite Setup And Setup 2CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_2MAPO_2CUS    team-SG4
...               owner-chendong.he    release-L18A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{disable_ConvVoice}
...    @{CA_enb1}
...    LNBTS-1:actCompChecks=false
...    LNBTS-1:actFlexScellSelect=true
...    LNBTS-1:actInterEnbDLCAggr=true
...    LNBTS-1:actInterEnbULCAggr=false
...    LNBTS-1:actLTES1Ho=true
...    LNBTS-1:actNonGbrServiceDiff=true
...    LNBTS-1:anrOmExtEnable=false
...    LNBTS-1:dlCaPreferred=DLandUL
...    LNBTS-1:caClusterId=1
...    LNBTS-1:caClusterMemberId=1
...    @{PARAMS_FOR_LNADJ_enb1}
...    @{Bandwidth_Change_A_f_003_enb1}
...    @{CAREL_FOR_A_f_003}
...    LNCEL-1:cqiPerSbCycK=1
...    LNCEL-2:cqiPerSbCycK=1
...    LNCEL-3:cqiPerSbCycK=1
...    LNCEL-4:cqiPerSbCycK=1
...    LNCEL-5:cqiPerSbCycK=1
...    @{CAREL_FOR_A_f_002}
@{PARAMS_IN_SCF_ENB2}
...    LNBTS_TDD-0:actConvVoice=false
...    @{CA_enb2}
...    LNBTS-2:actCompChecks=false
...    LNBTS-2:actFlexScellSelect=true
...    LNBTS-2:actInterEnbDLCAggr=true
...    LNBTS-2:actInterEnbULCAggr=false
...    LNBTS-2:actLTES1Ho=true
...    LNBTS-2:actNonGbrServiceDiff=true
...    LNBTS-2:anrOmExtEnable=false
...    LNBTS-2:dlCaPreferred=DLandUL
...    LNBTS-2:caClusterId=1
...    LNBTS-2:caClusterMemberId=2
...    @{PARAMS_FOR_LNADJ_enb2}
...    @{Bandwidth_Change_A_f_003_enb2}
...    LNBTS-2:mcc=262
...    LNBTS-2:mnc=3
...    LNCEL-1:tac=33
...    LNCEL-2:tac=33
...    LNCEL-3:tac=33
...    LNCEL-4:tac=33
...    LNCEL-1:eTputInitMcs=20
...    LNCEL-1:eTputFilterConfig=51
...    LNCEL-2:eTputInitMcs=20
...    LNCEL-2:eTputFilterConfig=51
...    LNCEL-3:eTputInitMcs=20
...    LNCEL-3:eTputFilterConfig=51
...    LNCEL-4:eTputInitMcs=20
...    LNCEL-4:eTputFilterConfig=51
...    LNBTS-2:actAmbrModCaTrigger=false
@{CA_enb1}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actFlexScellSelect=true
...    LNBTS-1:actAdvScellMeas=false
...    LNBTS-1:multScellReleaseTimer=0
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=0
...    LNBTS-1:actFlexCaMgmt=false
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBased
...    LNBTS-1:actAmbrModCaTrigger=false
...    @{CAGENB_enb1}
...    @{Cell1_CA_Config}
...    @{Cell2_CA_Config}
...    @{Cell3_CA_Config}
...    @{Cell4_CA_Config}
...    @{Cell5_CA_Config}
...    @{Cell6_CA_Config}
...    @{Cell7_CA_Config}
...    @{Cell8_CA_Config}
@{CA_enb2}
...    LNBTS-2:actDLCAggr=true
...    LNBTS-2:actFlexScellSelect=true
...    LNBTS-2:actAdvScellMeas=false
...    LNBTS-2:multScellReleaseTimer=0
...    LNBTS-2/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNBTS-2:actFlexCaMgmt=false
...    LNBTS-2:sCellActivationMethod=nonGBRBufferBased
...    @{CAGENB_enb2}
...    LNCEL-1:maxNumScells=4
...    LNCEL-1:actCaArchEnhImp=off
...    LNCEL-1:actFlowCtrlEnh=false
...    LNCEL-1:actScellConfigForHiDemand=false
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:nPucchF3Prbs=0
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=36
...    LNCEL-1:caPoolId=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:riPerOffset=-1
...    LNCEL-2:maxNumScells=4
...    LNCEL-2:actCaArchEnhImp=off
...    LNCEL-2:actFlowCtrlEnh=false
...    LNCEL-2:actScellConfigForHiDemand=false
...    LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0:nPucchF3Prbs=0
...    LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=36
...    LNCEL-2:caPoolId=1
...    LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...    LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...    LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0:riPerOffset=-1
...    LNCEL-3:maxNumScells=4
...    LNCEL-3:actCaArchEnhImp=off
...    LNCEL-3:actFlowCtrlEnh=false
...    LNCEL-3:actScellConfigForHiDemand=false
...    LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0:nPucchF3Prbs=0
...    LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=36
...    LNCEL-3:caPoolId=1
...    LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...    LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...    LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0:riPerOffset=-1
...    LNCEL-4:maxNumScells=4
...    LNCEL-4:actCaArchEnhImp=off
...    LNCEL-4:actFlowCtrlEnh=false
...    LNCEL-4:actScellConfigForHiDemand=false
...    LNCEL-4/LNCEL_TDD-0/MPUCCH_TDD-0:nPucchF3Prbs=0
...    LNCEL-4/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=36
...    LNCEL-4:caPoolId=1
...    LNCEL-4/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...    LNCEL-4/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...    LNCEL-4/LNCEL_TDD-0/MPUCCH_TDD-0:riPerOffset=-1
@{Cell1_CA_Config}
...    LNCEL-1:maxNumScells=4
...    LNCEL-1:actCaArchEnhImp=off
...    LNCEL-1:actFlowCtrlEnh=false
...    LNCEL-1:actScellConfigForHiDemand=false
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=0
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-1:caPoolId=1
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-1:eTputInitMcs=20
...    LNCEL-1:eTputFilterConfig=51

@{Cell2_CA_Config}
...    LNCEL-2:maxNumScells=4
...    LNCEL-2:actCaArchEnhImp=off
...    LNCEL-2:actFlowCtrlEnh=false
...    LNCEL-2:actScellConfigForHiDemand=false
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=0
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-2:caPoolId=1
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-2:eTputInitMcs=20
...    LNCEL-2:eTputFilterConfig=51

@{Cell3_CA_Config}
...    LNCEL-3:maxNumScells=4
...    LNCEL-3:actCaArchEnhImp=off
...    LNCEL-3:actFlowCtrlEnh=false
...    LNCEL-3:actScellConfigForHiDemand=false
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=0
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-3:caPoolId=1
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-3:eTputInitMcs=20
...    LNCEL-3:eTputFilterConfig=51

@{Cell4_CA_Config}
...    LNCEL-4:maxNumScells=4
...    LNCEL-4:actCaArchEnhImp=off
...    LNCEL-4:actFlowCtrlEnh=false
...    LNCEL-4:actScellConfigForHiDemand=false
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=0
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-4:caPoolId=1
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-4:eTputInitMcs=20
...    LNCEL-4:eTputFilterConfig=51


@{Cell5_CA_Config}
...    LNCEL-5:maxNumScells=4
...    LNCEL-5:actCaArchEnhImp=off
...    LNCEL-5:actFlowCtrlEnh=false
...    LNCEL-5:actScellConfigForHiDemand=false
...    LNCEL-5/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=0
...    LNCEL-5/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-5:caPoolId=1
...    LNCEL-5/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-5/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-5/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-5:eTputInitMcs=20
...    LNCEL-5:eTputFilterConfig=51

@{Cell6_CA_Config}
...    LNCEL-6:maxNumScells=4
...    LNCEL-6:actCaArchEnhImp=off
...    LNCEL-6:actFlowCtrlEnh=true
...    LNCEL-6:actScellConfigForHiDemand=false
...    LNCEL-6/LNCEL_TDD-0/MPUCCH_TDD-0:nPucchF3Prbs=0
...    LNCEL-6/LNCEL_TDD-0/MPUCCH_TDD-0:n1PucchAn=36
...    LNCEL-6:caPoolId=1
...    LNCEL-6/LNCEL_TDD-0/MPUCCH_TDD-0:riEnable=true
...    LNCEL-6/LNCEL_TDD-0/MPUCCH_TDD-0:riPerM=1
...    LNCEL-6/LNCEL_TDD-0/MPUCCH_TDD-0:riPerOffset=-1
...    LNCEL-6:eTputInitMcs=20
...    LNCEL-6:eTputFilterConfig=51

@{Cell7_CA_Config}
...    LNCEL-7:maxNumScells=4
...    LNCEL-7:actCaArchEnhImp=off
...    LNCEL-7:actFlowCtrlEnh=true
...    LNCEL-7:actScellConfigForHiDemand=false
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=0
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-7:caPoolId=1
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-7:eTputInitMcs=20
...    LNCEL-7:eTputFilterConfig=51

@{Cell8_CA_Config}
...    LNCEL-8:maxNumScells=4
...    LNCEL-8:actCaArchEnhImp=off
...    LNCEL-8:actFlowCtrlEnh=true
...    LNCEL-8:actScellConfigForHiDemand=false
...    LNCEL-8/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=0
...    LNCEL-8/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-8:caPoolId=1
...    LNCEL-8/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-8/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-8/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-8:eTputInitMcs=20
...    LNCEL-8:eTputFilterConfig=51

@{disable_ConvVoice}
...    LNBTS_FDD-0:actConvVoice=false
...    delete:LNCEL-1:t310Qci1
...    delete:LNCEL-1:n310Qci1
...    delete:LNCEL-2:t310Qci1
...    delete:LNCEL-2:n310Qci1
...    delete:LNCEL-3:t310Qci1
...    delete:LNCEL-3:n310Qci1
...    delete:LNCEL-4:t310Qci1
...    delete:LNCEL-4:n310Qci1
...    delete:LNCEL-5:t310Qci1
...    delete:LNCEL-5:n310Qci1
@{CAGENB_enb1}
...    LNBTS-1/CAGENB-0:caClusterEnbList:lnBtsId=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-1/CAGENB-0:maxDlCaConfigForUlCa=max_3CC_DL_CA

@{CAGENB_enb2}
...    LNBTS-2/CAGENB-0:caClusterEnbList:lnBtsId=1
...    LNBTS-2/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-2/CAGENB-0:maxDlCaConfigForUlCa=max_3CC_DL_CA

@{Bandwidth_Change_A_f_003_enb1}
...    LNCEL-1/LNCEL_FDD-0:dlChBw= 10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw= 10 MHz
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=500
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=18500
...    LNCEL-2/LNCEL_FDD-0:dlChBw= 20 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw= 20 MHz
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-4/LNCEL_FDD-0:dlChBw= 3 MHz
...    LNCEL-4/LNCEL_FDD-0:ulChBw= 3 MHz
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3600
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21600
...    LNCEL-4:redBwRbUlConfig:redBwMaxRbUl=15
...    LNCEL-4/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-4/LNCEL_FDD-0:maxNumActUE=85
...    LNCEL-4/LNCEL_FDD-0:maxNumQci1Drb=60
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:cqiPerNp=40ms
...    LNCEL-4/LNCEL_FDD-0:maxNumUeDl=7
...    LNCEL-4/LNCEL_FDD-0:maxNumUeUl=7
...    LNCEL-4:actDrx=true
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:deltaPucchShift=1
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=24
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:nCqiRb=1
@{Bandwidth_Change_A_f_003_enb2}
...    LNCEL-1/LNCEL_TDD-0:chBw= 15 MHz
...    LNCEL-1/LNCEL_TDD-0:earfcn=38800
${UTE_WIRESHARK_FLAG}    ${False}
@{PARAMS_FOR_LNADJ_enb1}
...    LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNADJ-1:cPlaneIpAddr=10.0.1.4
...    LNADJ-1:adjEnbId=2
...    LNADJ-1:plmnId:mcc=262
...    LNADJ-1:plmnId:mnc=3
...    LNADJ-1:plmnId:mncLength=2
...    LNADJ-1:rlfBasedRCRsupported=true
@{PARAMS_FOR_LNADJ_enb2}
...    LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNADJ-1:cPlaneIpAddr=10.0.1.2
...    LNADJ-1:adjEnbId=1
...    LNADJ-1:plmnId:mcc=262
...    LNADJ-1:plmnId:mnc=3
...    LNADJ-1:plmnId:mncLength=2
...    LNADJ-1:rlfBasedRCRsupported=true
@{CAREL_FOR_A_f_002}
...    LNCEL-2/CAREL-1:lcrId=1
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-2/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-2/CAREL-1:scellPrio=1
...    delete:LNCEL-2/CAREL-1:beamformingInScellAllowed
...    LNCEL-2/CAREL-2:lcrId=4
...    LNCEL-2/CAREL-2:lnBtsId=1
...    LNCEL-2/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-2/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-2/CAREL-2:scellPrio=1
...    delete:LNCEL-2/CAREL-2:beamformingInScellAllowed
...    LNCEL-2/CAREL-3:lcrId=51
...    LNCEL-2/CAREL-3:lnBtsId=2
...    LNCEL-2/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-2/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-2/CAREL-3:scellPrio=1
...    delete:LNCEL-2/CAREL-3:beamformingInScellAllowed
...    LNBTS-1/LNCEL-2:scellFastSchedulingSelect=normal
...    LNBTS-1/LNCEL-2:dlCaMinPcellCqi=0
...    LNBTS-1/LNCEL-2:ulCaMinPcellSinr=0
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=72
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=1
@{CAREL_FOR_A_f_003}
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-1:scellPrio=1
...    delete:LNCEL-1/CAREL-1:beamformingInScellAllowed
...    LNCEL-1/CAREL-2:lcrId=4
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:scellPrio=1
...    delete:LNCEL-1/CAREL-2:beamformingInScellAllowed
...    LNCEL-1/CAREL-3:lcrId=51
...    LNCEL-1/CAREL-3:lnBtsId=2
...    LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-3:scellPrio=1
...    delete:LNCEL-1/CAREL-3:beamformingInScellAllowed
...    LNBTS-1/LNCEL-1:scellFastSchedulingSelect=normal
...    LNBTS-1/LNCEL-1:dlCaMinPcellCqi=0
...    LNBTS-1/LNCEL-1:ulCaMinPcellSinr=0
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=72
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=1
@{PARAMS_FOR_A_f_002_enb1}
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1:multScellReleaseTimer=0
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=1
@{PARAMS_FOR_A_f_002_enb2}
...    LNCEL-1/LNCEL_TDD-0:chBw= 20 MHz
...    LNCEL-1/LNCEL_TDD-0:earfcn=39500
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1400
...    LNBTS-2/MODPR-0:autoAdapt=true
...    LNCEL-1:enableCovHo=true

*** Test Cases ***
LTE2751-A-f_003_FDD_TDD_CA_One_Step_Scell_addition_4CC
    [Documentation]    enb1:
    ...    LNCEL-1 band1 10M 500/18500
    ...    LNCEL-2 band 3 20M 1400/19400
    ...    LNCEL-4 band 8 3M 3600/21600
    ...
    ...    enb2:
    ...    LNCEL-1 band 40 15M 38800
    ...
    ...    attach and one step scell addtion for 4CC TDD+FDD
    ...
    ...    Pcell band 1, Scell band 3, band 8 , band 40
    ...    1A+3A+8A+40A 10M+20M+3M+15M
    [Tags]
    Configure 4CC TDD FDD UE Bands
    4CC FDD TDD Ue Attach To Cell1

LTE2751-A-f_002_FDD_TDD_CA_Step_Wise_HO_Scell_addition_3CC
    [Documentation]    enb1:
    ...    LNCEL-2 band 3 20M 1400/19400
    ...    LNCEL-4 band 8 3M 3600/21600
    ...
    ...    enb2:
    ...    LNCEL-1 band 40 20M 39500
    ...
    ...    UE attach to enb2 cell1
    ...    send DL traffic
    ...    handover to enb1 LNCEL-2 and trigger stepwise 3CC 3A+8A+40A \ 20M+20M+3M
    [Tags]
    Change Step Wise And Bandwidth
    4CC Ue Attach To Enb2 Cell1
    Start Dl Traffic
    Inter ENB Handover

*** Keywords ***
Common Suite Setup And Setup 2CUS Env
    Common Suite Setup
    Setup 2CUS Env    tl_type=8CELLs_FDD_B1_2B3_B7_B8_B20_B27_B28    tl_type_enb2=4CELLs_TDD_2Band40_2band42
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus

Parameters Configuration
    [Arguments]    ${delta_params}
    Delta Commission Parameters    ${delta_params}
    Cells Should Be OnAir

Configure 4CC TDD FDD UE Bands
    Configure UE CA Bands    ueid=1    ca_supported_bands=1:a:a+3::a+8::a+40::a    supported_bands=1,3,8,38,40

Configure UE CA Bands
    [Arguments]    ${ueid}    ${ca_supported_bands}    ${supported_bands}
    Execute Uex Command    ue_param id=${ueid} ca_supported_bands=${ca_supported_bands} supported_bands=${supported_bands}

4CC FDD TDD Ue Attach To Cell1
    ${DL_4CC_Scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    physCellId-r10 eq 2,
    ...    physCellId-r10 eq 4,
    ...    physCellId-r10 eq 51)
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${DL_4CC_Scell_addition})
    ...    alias=scell_addition_flow1    overall_timeout=5
    Execute Uex Command    ue_attach id=1 cell=1 selected_plmn=262:03
    Flow Occurred As Expected    alias=scell_addition_flow1

Parameters Configuration On Enb2
    [Arguments]    ${delta_params}
    Delta Commission Parameters Enb2    ${delta_params}
    Cells Should Be OnAir eNB2

Change Step Wise And Bandwidth
    Parameters Configuration    ${PARAMS_FOR_A_f_002_enb1}
    Parameters Configuration On Enb2    ${PARAMS_FOR_A_f_002_enb2}

4CC Ue Attach To Enb2 Cell1
    Execute Uex Command    ue_param id=1 ca_supported_bands=3:a:a+8::a|3:a:a+40::a|3:a:a+8::a+40::a supported_bands=1,3,8,38,40
    Execute Uex Command    ue_attach id=1 cell=51 selected_plmn=262:03 enb=2

Start Dl Traffic
    Execute Uex Command    trf_data_start ue=1 dir=dl protocol=udp Mbps=100
    sleep    5s    #wait traffic stable

Inter ENB Handover
    ${DL_3CC_Scell_addition_1}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains (physCellId-r10 eq 4)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Execute Uex Command    ue_measurement_send id=1 srsrp=15 srsrq=15 event=A2    #trigger A2 activation
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${DL_3CC_Scell_addition_1})
    ...    alias=scell_addition_flow2    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=1 srsrp=15 srsrq=15 event=A5 nrsrp=97 nrsrq=34 phycell_id=2    #trigger A5 interEnb HO
    Flow Occurred As Expected    alias=scell_addition_flow2



