*** Settings ***
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO    team-DevHZ5_SG4
...               owner-chendong.he    release-L18A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{delete_useless_MO}
...    @{disable_ConvVoice}
...    @{CA}
...    @{parameter_A_g_003}
...    @{Anntenna_Change}
...    LNBTS-1:actAmbrModCaTrigger=false
...    delete:MRBTS-1/LNBTS-1/LNCEL-1/MBSFNCEL-0
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=false
...    LNBTS-1:actFlexCaMgmt=false
...    @{Cell1_CA_Config}
...    @{Cell2_CA_Config}
...    @{Cell3_CA_Config}
...    @{Cell4_CA_Config}
...    @{Cell5_CA_Config}
...    @{Cell6_CA_Config}
...    @{Cell7_CA_Config}
...    @{CAGENB}
...    LNBTS-1:multScellReleaseTimer=0
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=0
...    LNBTS-1:actFlexScellSelect=true
@{Cell1_CA_Config}
...    LNCEL-1:actCaArchEnhImp=off
...    LNCEL-1:actFlowCtrlEnh=false
...    LNCEL-1:actScellConfigForHiDemand=false
...    LNCEL-1:caPoolId=1
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=72
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-1:maxNumScells=3
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=2
...    LNCEL-1/CAREL-2:lcrId=2
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:scellPrio=1
...    LNCEL-1/CAREL-4:lcrId=4
...    LNCEL-1/CAREL-4:lnBtsId=1
...    LNCEL-1/CAREL-4:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-4:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-4:scellPrio=1
...    delete:LNCEL-1/CAREL-4:beamformingInScellAllowed
...    delete:LNCEL-1/CAREL-2:beamformingInScellAllowed
...    LNCEL-1:eTputInitMcs=20
...    LNCEL-1:eTputFilterConfig=51

@{Cell2_CA_Config}
...    LNCEL-2:actCaArchEnhImp=off
...    LNCEL-2:actFlowCtrlEnh=false
...    LNCEL-2:actScellConfigForHiDemand=false
...    LNCEL-2:caPoolId=1
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=72
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-2:maxNumScells=3
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=2
...    LNCEL-2:redBwRbUlConfig:redBwMaxRbUl=25
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=500
...    LNCEL-2/CAREL-3:lcrId=3
...    LNCEL-2/CAREL-3:lnBtsId=1
...    LNCEL-2/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-2/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-2/CAREL-3:scellPrio=1
...    LNCEL-2/CAREL-4:lcrId=4
...    LNCEL-2/CAREL-4:lnBtsId=1
...    LNCEL-2/CAREL-4:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-2/CAREL-4:pcellSwapAllowed=allowed
...    LNCEL-2/CAREL-4:scellPrio=1
...    delete:LNCEL-2/CAREL-4:beamformingInScellAllowed
...    delete:LNCEL-2/CAREL-3:beamformingInScellAllowed
...    LNCEL-2:scellFastSchedulingSelect=normal
...    LNCEL-2:dlCaMinPcellCqi=0
...    LNCEL-2:ulCaMinPcellSinr=0
...    LNCEL-2:eTputInitMcs=20
...    LNCEL-2:eTputFilterConfig=51

@{Cell3_CA_Config}
...    LNCEL-3:actCaArchEnhImp=off
...    LNCEL-3:actFlowCtrlEnh=false
...    LNCEL-3:actScellConfigForHiDemand=false
...    LNCEL-3:caPoolId=1
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=72
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-3:maxNumScells=3
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=1
...    LNCEL-3:redBwRbUlConfig:redBwMaxRbUl=25
...    LNCEL-3:eTputInitMcs=20
...    LNCEL-3:eTputFilterConfig=51

@{Cell4_CA_Config}
...    LNCEL-4:actCaArchEnhImp=off
...    LNCEL-4:actFlowCtrlEnh=false
...    LNCEL-4:actScellConfigForHiDemand=false
...    LNCEL-4:caPoolId=1
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-4:actDrx=true
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:cqiPerNp=40ms
...    LNCEL-4:maxNumScells=3
...    LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=1
...    LNCEL-4:eTputInitMcs=20
...    LNCEL-4:eTputFilterConfig=51

@{Cell5_CA_Config}
...    LNCEL-5:actCaArchEnhImp=off
...    LNCEL-5:actFlowCtrlEnh=false
...    LNCEL-5:actScellConfigForHiDemand=false
...    LNCEL-5:caPoolId=1
...    LNCEL-5/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-5/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-5/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-5/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-5:actDrx=true
...    LNCEL-5/LNCEL_FDD-0/MPUCCH_FDD-0:cqiPerNp=40ms
...    LNCEL-5:maxNumScells=3
...    LNCEL-5/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=1
...    LNCEL-5:eTputInitMcs=20
...    LNCEL-5:eTputFilterConfig=51

@{Cell6_CA_Config}
...    LNCEL-6:actCaArchEnhImp=off
...    LNCEL-6:actFlowCtrlEnh=true
...    LNCEL-6:actScellConfigForHiDemand=false
...    LNCEL-6:caPoolId=1
...    LNCEL-6/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=36
...    LNCEL-6/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-6/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-6/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-6:maxNumScells=3
...    LNCEL-6/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=2
...    LNCEL-6:eTputInitMcs=20
...    LNCEL-6:eTputFilterConfig=51

@{Cell7_CA_Config}
...    LNCEL-7:actCaArchEnhImp=off
...    LNCEL-7:actFlowCtrlEnh=true
...    LNCEL-7:actScellConfigForHiDemand=false
...    LNCEL-7:caPoolId=1
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=72
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:riEnable=true
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...    LNCEL-7:maxNumScells=3
...    LNCEL-7/LNCEL_FDD-0/MPUCCH_FDD-0:nPucchF3Prbs=2
...    LNCEL-7:scellFastSchedulingSelect=normal
...    LNCEL-7:dlCaMinPcellCqi=0
...    LNCEL-7:ulCaMinPcellSinr=0
...    LNCEL-7:eTputInitMcs=20
...    LNCEL-7:eTputFilterConfig=51

@{disable_ConvVoice}
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=false
...    delete:LNCEL-1:t310Qci1
...    delete:LNCEL-1:n310Qci1
...    delete:LNCEL-2:t310Qci1
...    delete:LNCEL-2:n310Qci1
...    delete:LNCEL-3:t310Qci1
...    delete:LNCEL-3:n310Qci1
@{CAGENB}
...    delete:LNBTS/CAGENB-0:caClusterEnbList
...    LNBTS/CAGENB-0:fastLoadBalanceConfig:fastLoadBalanceMcsThresh=0
...    LNBTS/CAGENB-0:fastLoadBalanceConfig:prbUsageRatioGapThresh=30
...    LNBTS/CAGENB-0:fastLoadBalanceConfig:prbUsageRatioHighThresh=80
...    LNBTS/CAGENB-0:maxDlCaConfigForUlCa=max_3CC_DL_CA
@{delete_useless_MO}
...    delete:LNCEL-1/CAREL-1
@{Anntenna_Change}
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1/CHANNELGROUP-1/CHANNEL-5
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1/CHANNELGROUP-1/CHANNEL-6
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1/CHANNELGROUP-1/CHANNEL-7
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1/CHANNELGROUP-1/CHANNEL-8
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2/CHANNELGROUP-1/CHANNEL-5
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2/CHANNELGROUP-1/CHANNEL-6
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2/CHANNELGROUP-1/CHANNEL-7
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2/CHANNELGROUP-1/CHANNEL-8
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-5
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-6
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-7
...    delete:MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1/CHANNEL-8
...    LNCEL-1/LNCEL_FDD-0:dlMimoMode=Closed Loop Mimo
...    LNCEL-2/LNCEL_FDD-0:dlMimoMode=Closed Loop Mimo
...    LNCEL-3/LNCEL_FDD-0:dlMimoMode=Closed Loop Mimo
...    delete:LNCEL-1/LNCEL_FDD-0:activatedMimoTM
...    delete:LNCEL-2/LNCEL_FDD-0:activatedMimoTM
...    delete:LNCEL-3/LNCEL_FDD-0:activatedMimoTM
@{parameter_A_g_003}
...    LNCEL-1/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=300
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=18300
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1300
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19300
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1444
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19444
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3600
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21600
...    LNBTS-1:dlCaPreferred=DLandUL
...    LNCEL-1:maxNumScells=3
...    LNCEL-2:maxNumScells=3
...    LNCEL-3:maxNumScells=3
...    LNBTS-1:actPcellSwap=true
...    delete:LNCEL-2/CAREL-3
...    LNCEL-2/CAREL-1:lcrId=1
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-2/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-2/CAREL-1:scellPrio=1
...    delete:LNCEL-2/CAREL-1:beamformingInScellAllowed
...    LNCEL-1:pcellSwapConfig:enableVoLteUePcellSwap=AllUes
...    LNCEL-1:pcellSwapConfig:numCaUeThreshold=20
...    LNCEL-1:pcellSwapConfig:pcellSwapMaxHoRate=5
...    LNCEL-1:pcellSwapConfig:pFreqPrio=1
...    LNCEL-1:pcellSwapConfig:puschLoadHysteresis=10
...    LNCEL-1:pcellSwapConfig:puschLoadIndexThr=100
...    LNCEL-1:pcellSwapConfig:scellChQualThreshold=0
...    LNCEL-1:pcellSwapConfig:scellStateForPcellSwap=activated
...    LNCEL-1:loadSettings:cellCapClass=100
...    LNCEL-1:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-1:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL-1:loadSettings:targetLoadGbrDl=50
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-1:loadSettings:targetLoadPdcch=90
...    LNCEL-1:loadSettings:ulCacIgnore=false
...    LNCEL-1:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-1:loadSettings:ulStaticCac=100
...    LNCEL-2:pcellSwapConfig:enableVoLteUePcellSwap=AllUes
...    LNCEL-2:pcellSwapConfig:numCaUeThreshold=20
...    LNCEL-2:pcellSwapConfig:pcellSwapMaxHoRate=5
...    LNCEL-2:pcellSwapConfig:pFreqPrio=1
...    LNCEL-2:pcellSwapConfig:puschLoadHysteresis=10
...    LNCEL-2:pcellSwapConfig:puschLoadIndexThr=100
...    LNCEL-2:pcellSwapConfig:scellChQualThreshold=0
...    LNCEL-2:pcellSwapConfig:scellStateForPcellSwap=activated
...    LNCEL-2:loadSettings:cellCapClass=100
...    LNCEL-2:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-2:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL-2:loadSettings:targetLoadGbrDl=50
...    LNCEL-2:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-2:loadSettings:targetLoadPdcch=90
...    LNCEL-2:loadSettings:ulCacIgnore=false
...    LNCEL-2:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-2:loadSettings:ulStaticCac=100
...    LNCEL-3:loadSettings:cellCapClass=100
...    LNCEL-3:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-3:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL-3:loadSettings:targetLoadGbrDl=50
...    LNCEL-3:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-3:loadSettings:targetLoadPdcch=90
...    LNCEL-3:loadSettings:ulCacIgnore=false
...    LNCEL-3:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-3:loadSettings:ulStaticCac=100
...    LNCEL-4:loadSettings:cellCapClass=100
...    LNCEL-4:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-4:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL-4:loadSettings:targetLoadGbrDl=50
...    LNCEL-4:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-4:loadSettings:targetLoadPdcch=90
...    LNCEL-4:loadSettings:ulCacIgnore=false
...    LNCEL-4:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-4:loadSettings:ulStaticCac=100
...    LNCEL-5:loadSettings:cellCapClass=100
...    LNCEL-5:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-5:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL-5:loadSettings:targetLoadGbrDl=50
...    LNCEL-5:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-5:loadSettings:targetLoadPdcch=90
...    LNCEL-5:loadSettings:ulCacIgnore=false
...    LNCEL-5:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-5:loadSettings:ulStaticCac=100
...    LNCEL-6:loadSettings:cellCapClass=100
...    LNCEL-6:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-6:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL-6:loadSettings:targetLoadGbrDl=50
...    LNCEL-6:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-6:loadSettings:targetLoadPdcch=90
...    LNCEL-6:loadSettings:ulCacIgnore=false
...    LNCEL-6:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-6:loadSettings:ulStaticCac=100
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=1
...    LNBTS-1:actULCAggr=UL_CA_with_smartSched
...    LNBTS-1/CADPR-0:enableFreqPrioSwap=enabled
...    LNBTS-1:actUlTraffDrivUlCa=false
...    LNCEL-7:loadSettings:cellCapClass=100
...    LNCEL-7:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-7:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL-7:loadSettings:targetLoadGbrDl=50
...    LNCEL-7:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-7:loadSettings:targetLoadPdcch=90
...    LNCEL-7:loadSettings:ulCacIgnore=false
...    LNCEL-7:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-7:loadSettings:ulStaticCac=100
@{parameter_A_g_002}
...    LNCEL-1:pcellSwapConfig:numCaUeThreshold=1
@{parameter_A_g_003_1}
...    LNCEL-1:pcellSwapConfig:pFreqPrio=3
@{parameter_A_g_003_2}
...    LNCEL-1:pcellSwapConfig:pFreqPrio=1
...    LNCEL-2:pcellSwapConfig:pFreqPrio=3
@{PM_Counters_for_a_g_003_1}
...    LNCEL-1:${PCELL_SWAP_SUCC}=1
@{PM_Counters_for_a_g_003_2}
...    LNCEL-2:${PCELL_SWAP_SUCC}=1
${PCELL_SWAP_SUCC}    M8021C42
${UTE_WIRESHARK_FLAG}    ${False}

*** Test Cases ***
LTE2751-A-g_003_PCell_Swap_PFreqPrio_StepWise_3cc
    [Documentation]    3CC UEa attach ,Pcell swap due to PfreqPrio change,but UL&DL CA doesn't support to pcell swap
    [Tags]
    Two 3CC UEs Attach And Trigger CA
    Pcell Swap For Dl Only Ue
    Pcell Swap Back For Dl Only Ue

LTE2751-A-g_002_PCell_Swap_Num_Of_CA_UEs_StepWise_3cc
    [Documentation]    pcell swap due to number of CA UEs up to maximum.
    [Tags]
    Change Bandwidth And numCaUeThreshold
    3CC Ue3 Attach To Cell1 And Trigger CA
    3CC Ue4 Attach To Cell1 And Trigger PCell Swap

*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup
    Setup Cus Env    tl_type=7CELLs_FDD_B1_2B3_B8_B2_25_B12_17
    Execute Egate Command    trace_sim uec=1 protocol=rrc on
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Create Alias

Create Alias
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create UE Alias    UE_5    ue_id=5    id_type=cus
    Create UE Alias    UE_6    ue_id=6    id_type=cus

Configure UE CA Bands
    [Arguments]    ${ueid}    ${ca_supported_bands}
    Execute Uex Command    ue_param id=${ueid} ca_supported_bands=${ca_supported_bands}    #configure UE CA capability

Parameters Configuration
    [Arguments]    ${delta_params}
    Delta Commission Parameters    ${delta_params}
    Cells Should Be OnAir

Start Dl Traffic And Wait 4CC
    [Arguments]    ${ueid}    ${direction}    ${mbps}
    Execute Uex Command    trf_data_start ue=${ueid} dir=${direction} protocol=udp Mbps=${mbps} stats=true

Two 3CC UEs Attach And Trigger CA
    Configure UE CA Bands    ueid=5    ca_supported_bands=3:a:a+1::a|3:a:a+8::a|1:a:a+3::a|1:a:a+8::a|3:a:a+1::a+8::a|1:a:a+3::a+8::a
    Configure UE CA Bands    ueid=6    ca_supported_bands=1:a:a+3:a:a|1:a:a+8::a|3:a:a+8::a|3:a:a+1:a:a+8::a|1:a:a+3:a:a+8::a
    Dl Only 3CC Ue Attach To Cell1
    Ul Dl 3CC Ue Attach To Cell1
    Start Dl Traffic And Wait 3CC    ueid=5    direction=dl    mbps=50
    Start Dl Traffic And Wait 3CC    ueid=6    direction=dl    mbps=50

Dl Only 3CC Ue Attach To Cell1
    Execute Uex Command    ue_attach id=5 cell=1 selected_plmn=262:03

Ul Dl 3CC Ue Attach To Cell1
    Execute Uex Command    ue_attach id=6 cell=1 selected_plmn=262:03

Start Dl Traffic And Wait 3CC
    [Arguments]    ${ueid}    ${direction}    ${mbps}    ${timeout}=120
    ${DL_3CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and
    ...    sCellIndex-r10 ne 3
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration ( ${DL_3CC_scell_addition} )
    ...    alias=LTE2751_A_g_003_flow1    overall_timeout=${timeout}
    Start Dl Traffic And Wait 4CC    ueid=${ueid}    direction=${direction}    mbps=${mbps}
    Flow Occurred As Expected    alias=LTE2751_A_g_003_flow1

Pcell Swap For Dl Only Ue
    Start Rtpm Counter    tag=pcell_swap
    Execute Uex Command    trf_data_start ue=5 dir=ul protocol=udp Mbps=10 stats=true
    Pcell Swap By Change pFreqPrio
    sleep    60s    #wait Pcell Swap trigger
    Check Ue Location    ueid=5    wait_string=2
    Check Ue Location    ueid=6    wait_string=1
    Check Rtpm Counters    ${PM_Counters_for_a_g_003_1}    tag=pcell_swap

Pcell Swap Back For Dl Only Ue
    Start Rtpm Counter    tag=pcell_swap_back
    Pcell Swap Back By Change pFreqPrio
    sleep    60s    #wait Pcell Swap back trigger
    Check Ue Location    ueid=5    wait_string=1
    Check Ue Location    ueid=6    wait_string=1
    Check Rtpm Counters    ${PM_Counters_for_a_g_003_2}    tag=pcell_swap_back

Pcell Swap By Change pFreqPrio
    Parameters Configuration    ${parameter_A_g_003_1}

Pcell Swap Back By Change pFreqPrio
    Parameters Configuration    ${parameter_A_g_003_2}

Check Ue Location
    [Arguments]    ${ueid}    ${wait_string}
    ${ue_info}    Execute UEx Command    get_ue_info id=${ueid}
    ${cell_id}=      Convert To String     ${ue_info["cell"]}
    should be equal    ${cell_id}    ${wait_string}

Change Bandwidth And numCaUeThreshold
    Parameters Configuration    ${parameter_A_g_002}

3CC Ue3 Attach To Cell1 And Trigger CA
    Configure UE CA Bands    ueid=3    ca_supported_bands=8:a:a+3::a|1:a:a+3::a|1:a:a+8::a|1:a:a+3::a+8::a
    Execute Uex Command    ue_attach id=3 cell=1 selected_plmn=262:03
    ${DL_3CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and
    ...    sCellIndex-r10 ne 3
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_3:RRC_RRCConnectionReconfiguration ( ${DL_3CC_scell_addition} )
    ...    alias=LTE2751_A_g_002_flow1    overall_timeout=120
    Execute Uex Command    trf_data_start ue=3 dir=dl protocol=udp Mbps=30 stats=true
    Flow Occurred As Expected    alias=LTE2751_A_g_002_flow1
    Check Ue Location    ueid=3    wait_string=1
    Execute Uex Command    trf_data_start ue=3 dir=ul protocol=udp Mbps=10 stats=true    #send ul traffic

3CC Ue4 Attach To Cell1 And Trigger PCell Swap
    Start Rtpm Counter    tag=pcell_swap_ca_threshold
    Configure UE CA Bands    ueid=4    ca_supported_bands=3:a:a+8::a|1:a:a+3::a|1:a:a+8::a|1:a:a+3::a+8::a
    Execute Uex Command    ue_attach id=4 cell=1 selected_plmn=262:03
    ${DL_2CC_scell_release}    catenate
    ...    sCellToReleaseList-r10 contains (2,1)
    Expect Message Flow
    ...    UE_4:RRC_RRCConnectionReconfiguration ( ${DL_2CC_scell_release} )
    ...    alias=LTE2751_A_g_002_flow2    overall_timeout=120
    Execute Uex Command    trf_data_start ue=4 dir=dl protocol=udp Mbps=30 stats=true
    Flow Occurred As Expected    alias=LTE2751_A_g_002_flow2
    Check Ue Location    ueid=4    wait_string=2
    sleep    60s    #wait the counter increase
    Check Rtpm Counters    ${PM_Counters_for_a_g_003_1}    tag=pcell_swap_ca_threshold
