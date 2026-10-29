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
...    MRBTS-1/MNL-1/MNLENT-1/SYNC-1/CLOCK-1:outputConfiguration1Pps=EnabledWithoutBtsInputReference
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
...    @{Bandwidth_Change_A_c_004_enb1}
...    @{CAREL_FOR_A_c_004}

@{PARAMS_IN_SCF_ENB2}
...    MRBTS-2/MNL-1/MNLENT-1/SYNC-1/CLOCK-1:outputConfiguration1Pps=EnabledWithoutBtsInputReference
...    @{disable_ConvVoice}
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
...    @{Bandwidth_Change_A_c_004_enb2}
...    delete:LNCEL-1/CAREL-1

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
...    LNBTS-2/LNBTS_FDD-0:numTxWithHighNonGbr=0
...    LNBTS-2:actFlexCaMgmt=false
...    LNBTS-2:sCellActivationMethod=nonGBRBufferBased
...    LNBTS-2:actAmbrModCaTrigger=false
...    @{CAGENB_enb2}
...    @{Cell1_CA_Config}
...    @{Cell2_CA_Config}
...    @{Cell3_CA_Config}
...    @{Cell4_CA_Config}
...    @{Cell5_CA_Config}
...    @{Cell6_CA_Config}
...    @{Cell7_CA_Config}
...    @{Cell8_CA_Config}

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
...    LNCEL-6/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=0
...    LNCEL-6/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-6:caPoolId=1
...    LNCEL-6/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-6/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-6/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-6:eTputInitMcs=20
...    LNCEL-6:eTputFilterConfig=51

@{Cell7_CA_Config}
...    LNCEL-7:maxNumScells=4
...    LNCEL-7:actCaArchEnhImp=off
...    LNCEL-7:actFlowCtrlEnh=true
...    LNCEL-7:actScellConfigForHiDemand=false
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=0
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-7:caPoolId=2
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
...    LNCEL-8:caPoolId=2
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

@{Bandwidth_Change_A_c_004_enb1}
...    LNCEL-1/LNCEL_FDD-0:dlChBw= 10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw= 10 MHz
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=300
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=18300
...    LNCEL-2/LNCEL_FDD-0:dlChBw= 20 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw= 20 MHz
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNCEL_FDD-0:dlChBw= 10 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw= 10 MHz
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1644
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19644
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

@{Bandwidth_Change_A_c_004_enb2}
...    LNCEL-1/LNCEL_FDD-0:dlChBw= 10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw= 10 MHz
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=300
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=18300
...    LNCEL-2/LNCEL_FDD-0:dlChBw= 20 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw= 20 MHz
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNCEL_FDD-0:dlChBw= 10 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw= 10 MHz
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1644
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19644
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

@{CAREL_FOR_A_c_004}
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-1:scellPrio=5
...    delete:LNCEL-1/CAREL-1:beamformingInScellAllowed
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:scellPrio=5
...    delete:LNCEL-1/CAREL-2:beamformingInScellAllowed
...    LNCEL-1/CAREL-3:lcrId=4
...    LNCEL-1/CAREL-3:lnBtsId=1
...    LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-3:scellPrio=5
...    delete:LNCEL-1/CAREL-3:beamformingInScellAllowed
...    LNCEL-1/CAREL-4:lcrId=52
...    LNCEL-1/CAREL-4:lnBtsId=2
...    LNCEL-1/CAREL-4:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-4:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-4:scellPrio=1
...    delete:LNCEL-1/CAREL-4:beamformingInScellAllowed
...    LNCEL-1/CAREL-5:lcrId=53
...    LNCEL-1/CAREL-5:lnBtsId=2
...    LNCEL-1/CAREL-5:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-5:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-5:scellPrio=1
...    delete:LNCEL-1/CAREL-5:beamformingInScellAllowed
...    LNCEL-1/CAREL-6:lcrId=54
...    LNCEL-1/CAREL-6:lnBtsId=2
...    LNCEL-1/CAREL-6:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-6:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-6:scellPrio=1
...    delete:LNCEL-1/CAREL-6:beamformingInScellAllowed
...    LNBTS-1/LNCEL-1:scellFastSchedulingSelect=normal
...    LNBTS-1/LNCEL-1:dlCaMinPcellCqi=0
...    LNBTS-1/LNCEL-1:ulCaMinPcellSinr=0
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=72
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=1

*** Test Cases ***
LTE2751-A-c_004_Inter_Site_CA_Step_Wise_Scell_addition_4CC
    [Documentation]    enb1:
    ...    Cell1 Band1 10M 300/18300 PCI1
    ...    Cell2 Band3 20M 1500/19500 PCI2 \ \ Cell3 Band3 10M 1644/19644 PCI3
    ...    Cell5 Band8 3M \ 3600/21600 PCI4
    ...
    ...    enb2:
    ...    Cell1 Band1 10M 300/18300 PCI51
    ...    Cell2 Band3 20M 1500/19500 PCI52 \ \ Cell3 Band3 10M 1644/19644 PCI53
    ...    Cell5 Band8 3M \ 3600/21600 PCI54
    ...
    ...    LNCEL-1
    ...    CAREL-1 lcrid 2, scellPrio 5
    ...    CAREL-2 lcrid 3, scellPrio 5
    ...    CAREL-3 lcrid 4, scellPrio 5
    ...    CAREL-4 lcrid 52, scellPrio 1
    ...    CAREL-5 lcrid 53, scellPrio 1
    ...    CAREL-6 lcrid 54, scellPrio 1
    ...
    ...    send traffic to trigger 1A+3C+8A , 8A belongs to 3Mhz and inter-site
    [Tags]
    4CC Ue Attach To Cell1
    Start Dl Traffic And Wait 2CC
    Start Dl Traffic And Wait 3CC
    Start Dl Traffic And Wait 4CC

*** Keywords ***
Common Suite Setup And Setup 2CUS Env
    Common Suite Setup
    Setup 2CUS Env    tl_type=8CELLs_FDD_B1_2B3_B7_B8_B20_B27_B28    tl_type_enb2=8CELLs_FDD_B1_2B3_B7_B8_B20_B27_B28
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus

Configure UE CA Bands
    [Arguments]    ${ueid}    ${ca_supported_bands}
    Execute Uex Command    ue_param id=${ueid} ca_supported_bands=${ca_supported_bands}    #configure UE CA capability

4CC Ue Attach To Cell1
    Configure UE CA Bands    ueid=1    ca_supported_bands=1:a:a+3::c+8::a|1:a:a+3::c|1:a:a+3:a+8::a|1:a:a+3::a|1:a:a+8::a|3:a:a+8::a
    Execute Uex Command    ue_attach id=1 cell=1 selected_plmn=262:03

Start DL Traffic And Wait CA
    [Arguments]    ${ue_id}=1    ${pass_regexp}=${DL_2CC_scell_addition}    ${alias}=scell_addtion_flow1
    ...    ${overall_timeout}=120    ${through_put}=3    ${sleep_time}=15s
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${pass_regexp} )
    ...    alias=${alias}    overall_timeout=${overall_timeout}
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp Mbps=${through_put}
    sleep    ${sleep_time}    # wait traffic stable
    Execute Uex Command    get_ue_stats id=${ue_id} type=dl_mac unit=Mbps
    Flow Occurred As Expected    alias=${alias}
    Execute Uex Command    trf_data_stop ue=${ue_id} dir=dl

Start Dl Traffic And Wait 2CC
    ${DL_2CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq 1500)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 1
    Start DL Traffic And Wait CA    pass_regexp=${DL_2CC_scell_addition}    alias=scell_addtion_flow1
    ...    through_put=3

Start Dl Traffic And Wait 3CC
    ${DL_3CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 1644) and
    ...    sCellIndex-r10 ne 3
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Start DL Traffic And Wait CA    pass_regexp=${DL_3CC_scell_addition}    alias=scell_addtion_flow2
    ...    through_put=20

Start Dl Traffic And Wait 4CC
    ${DL_4CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2,
    ...    sCellIndex-r10 eq 3 and cellIdentification-r10 contains (physCellId-r10 eq 54 and dl-CarrierFreq-r10 eq 3600)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 3
    Start DL Traffic And Wait CA    pass_regexp=${DL_4CC_scell_addition}    alias=scell_addtion_flow3
    ...    through_put=60
