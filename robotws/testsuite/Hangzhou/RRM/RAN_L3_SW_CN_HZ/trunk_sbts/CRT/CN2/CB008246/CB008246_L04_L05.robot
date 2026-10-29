*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-qianqian.guo
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    CB008246    release-SBTS23R4
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL-1:actNonVoNRGbrService=true
...    NRCELL-1:actUl256Qam=false
...    NRCELL-1:actDl256Qam=false
...    NRCELL-1:actUlMuMimo=false
...    NRCELL-1:actDlMuMimo=false
...    @{5qi3_related_modification}
...    @{5qi80_related_modification}
...    @{8246_related}
...    @{PRBBlanking_disable}

@{PRBBlanking_disable}
...    NRCELL-1/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-1/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-1:actPRBBlanking=false
...    NRCELL-1:actSpecificBwpSize=false
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:gscnOrSsPbchArfcn=1
...    NRCELL-1:lteNrDssMode=none
...    NRCELL-1:type0CoresetConfigurationIndex=0
...    NRBTS-1:actFdmScheduling=true
...    NRCELL-1:msg1FrequencyStart=17
...    NRCELL-1:nbrOfBlankedPRBsLowEdgeDL=0
...    NRCELL-1:nbrOfBlankedPRBsLowEdgeUL=0
...    NRCELL-1:nbrOfBlankedPRBsHighEdgeDL=0
...    NRCELL-1:nbrOfBlankedPRBsHighEdgeUL=0
...    NRCELL-1:actIncreasedFdmUsersPerSlot=true
...    NRCELL-1:maxNumPdschAllocationPerSlot=6
...    NRCELL-1:maxNumPuschAllocationPerSlot=5

@{PRBBlanking_enable}
...    NRCELL-1:actPRBBlanking=true

@{8246_related}
...    @{bwp_profile}
...    @{PDSCHHRLA_PUSCHHRLA}
...    @{8246_cell_configuration}

@{bwp_profile}
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-14/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4

@{PDSCHHRLA_PUSCHHRLA}
#5QI-5
...    NRBTS/NRDRB-10:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
#5QI-80
...    NRBTS/NRDRB-17:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDRB-17:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1

...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=105
...    NRBTS/NRPUSCHHRLA-1:ullaBlerTargetHR=1
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh64qam=7000
...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=200
...    NRBTS/NRPUSCHHRLA-2:ullaBlerTargetHR=6
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh=10000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh64qam=7000
#5QI-8
...    NRBTS/NRDRB-13:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
#5QI-3
...    NRBTS/NRDRB-19:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-19:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2

...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=10
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=30
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=101
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=10
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=30
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=2
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=180

@{8246_cell_configuration}
...    NRCELL-1:actCceSplit=false
...    NRCELL-1:actLAForHiReliab=true
...    NRCELL-1:scalingStepdownHREnabled=true
...    NRCELL-1:actDlMuMimo=false
...    NRCELL-1:actUlMuMimo=false
...    NRCELL-1:actAdaptiveReTxResMcs=false
...    MRBTS-1/NRBTS-1/NRDU-1:carrierAggregationSupportList=none

...    NRCELL-1:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrMaxHR=150
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrMinHR=-300
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrStepdownHR=20
...    NRCELL-1:puschHrLaConfig:ullaIniMcsHR=0
...    NRCELL-1:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=25
...    NRCELL-1:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=25
...    NRCELL-1:puschHrLaConfig:ullaMcsMax64qamRANK1HR=25
...    NRCELL-1:puschHrLaConfig:ullaMcsMax64qamRANK2HR=25
...    NRCELL-1:puschHrLaConfig:ullaSinrOffsetHR=20

...    NRCELL-1:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMaxHR=150
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL-1:pdschHrLaConfig:dllaIniDeltaCqiHR=-50
...    NRCELL-1:pdschHrLaConfig:dllaIniMcsHR=3
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=25
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=20
...    NRCELL-1:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=20

@{5qi80_related_modification}
...    NRBTS/NRDRB-17:actDddsReduction=false
...    NRBTS/NRDRB-17:actLostPduFastRetx=false
...    NRBTS/NRDRB-17:discardTimer=infinity
...    NRBTS/NRDRB-17:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-17:dscp=0
...    NRBTS/NRDRB-17:endMarkerTimer=2000
...    NRBTS/NRDRB-17:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-17:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-17:maxTransferDelayGbr=20
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-17:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-17:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-17:numSduDiscard=1
...    NRBTS/NRDRB-17:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-17:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-17:resType=nonGBR
...    NRBTS/NRDRB-17:rlcMode=RLC_UM
...    NRBTS/NRDRB-17:schedulWeight=1
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-17:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-17:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-17:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-17:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-17:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-17:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-17:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-17:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-17:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-17:nsaDrbParam:ulDataSplitThreshold=infinity
...    delete:NRBTS/NRDRB-17:nrPdschHRLaDN
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=80
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

@{5qi3_related_modification}
...    NRBTS/NRDRB-19:actDddsReduction=false
...    NRBTS/NRDRB-19:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-19:actLostPduFastRetx=false
...    NRBTS/NRDRB-19:discardTimer=100ms
...    NRBTS/NRDRB-19:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-19:dlFlowControlAlgo=none
...    NRBTS/NRDRB-19:dscp=46
...    NRBTS/NRDRB-19:durationThresDiscardDl=40
...    NRBTS/NRDRB-19:durationThresDiscardUl=20
...    NRBTS/NRDRB-19:endMarkerTimer=2000
...    NRBTS/NRDRB-19:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-19:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-19:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-19:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-19:maxTransferDelayGbr=20
...    NRBTS/NRDRB-19:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-19:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB-19:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-19:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-19:numSduDiscard=1
...    NRBTS/NRDRB-19:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-19:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-19:resType=GBR
...    NRBTS/NRDRB-19:rlcMode=RLC_UM
...    NRBTS/NRDRB-19:schedulWeight=1
...    NRBTS/NRDRB-19:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-19:volThresDiscardDl=8000
...    NRBTS/NRDRB-19:volThresDiscardUl=800
...    NRBTS/NRDRB-19:l2OHFactorDl=16
...    NRBTS/NRDRB-19:l2OHFactorUl=35
...    NRBTS/NRDRB-19:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-19:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-19:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-19:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-19:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-19:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-19:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-19:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-19:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-19:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-19:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-19:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB_5QI-9:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-19
...    NRBTS/NRDRB_MAC-6:delayTarget=50
...    NRBTS/NRDRB_MAC-6:lcgid=5
...    NRBTS/NRDRB_MAC-6:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-6:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-6:schedulPrio=5
...    NRBTS/NRDRB_PDCP-4:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-4:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-4:tReorderingDl=ms8
...    NRBTS/NRDRB_PDCP-4:tReorderingUl=ms8
...    NRBTS/NRDRB_PDCP-4:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_AM-4:dlMaxRetxThreshold=t16
...    NRBTS/NRDRB_RLC_AM-4:dlPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:dlPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:dlTPollRetr=ms100
...    NRBTS/NRDRB_RLC_AM-4:dlTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassemblyIBCA=30
...    NRBTS/NRDRB_RLC_AM-4:duFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-4:ulMaxRetxThreshold=t32
...    NRBTS/NRDRB_RLC_AM-4:ulPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:ulPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:ulTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-4:ulTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassemblyIBCA=${EMPTY}
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

${UE_Capa_Not_Support_HR}    SEPARATOR=
...    EDA09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47007B8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B11B582308682041F28340125B262A82873E2
...    38F180000000000000000009FFF000007FFC000005C0000E000BC3C46000E140000000B01020060234028174001300C68912244D8E7C3005
...    0119E82C003C1C1401C0C025007000602400406020000000003E008020000000100000200B036B2A68020800004B29282000032CA4A00A81
...    D552AAA16004800D028000020200400808020043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${UE_Capa_Support_HR_PDSCH_PUSCH}    SEPARATOR=
...    EDA09000575F5A13160003C420005824C5C00670F424026C9B0E7CC31E50B038260300C47007B8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B11B582308682041F28340125B262A82873E238
...    F180000000000000000009FFF000007FFC000005C0000E000BC3C46000E140000000B01020060234028174001300C68912244D8E7C3005011
...    9E82C003C1C1401C0C025007000602400406020000000003E008020000000100000200B036B2A68020800004B29282000032CA4A00A81D552
...    AAA16004800D028000020200400808020043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

*** Test Cases ***
CB008246_L_04_High_reliability_DRB_IWK_with_PRB_blanking
    [Documentation]
    ...    1.Description
    ...    This user scenario validates the high reliability DRBs interworking with PRB blanking in 10MHz FDD cell.
    ...    2.Configuration
    ...      a.SA,FDD,10MHZ.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.disable PRB blanking deature actPRBBlanking = false.
    ...      d.UE support Ul-64QAM-MCS-TableAlt and Dl-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.enable PRB blanking deature actPRBBlanking = true.
    ...      b.UE attach to target cell w default DRB 5QI6, 5qi3 and 5qi80.
    ...      c.delete DRB 5qi80.
    ...      d.delete DRB 5qi3.
    ...      e.UE detach.
    ...    4.Check Points
    ...      4.1 for step b: mcs-Table parameter in PDSCH-Config and PUSCH-Config
    ...      4.2 for step c:drb 5qi80 released and check RRC RECONFIGURATION message, no mcs-Table parameter of PUSCH-Config and PUSCH-Config
    ...      4.3 for step d:drb 5qi3 released andcheck RRC RECONFIGURATION message, no mcs-Table parameter of PUSCH-Config and PUSCH-Config
    [Tags]    QC_321802    owner-qianqian.guo
    OnlineParamChange    ${PRBBlanking_enable}
    Cells Should Be Onair
    UE Attach To Target Cell    ue_id=1    cell_id=1    default_qos=6    pass_regexp=mcs-Table qam64LowSE
    Send And Verify Throuput    ue_id=1    qfi=1    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    Send And Verify Throuput    ue_id=1    qfi=2    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    Send And Verify Throuput    ue_id=1    qfi=3    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    Del DRB 5qi80    ue_id=1    fail_regexp=mcs-Table qam64LowSE
    Verify Throuput    ue_id=1    qfi=1    pdu=1    Tput_dl=5*0.9    Tput_ul=3*0.9    sleep_time=10s
    Verify Throuput    ue_id=1    qfi=2    pdu=1    Tput_dl=5*0.9    Tput_ul=3*0.9    sleep_time=10s
    Del DRB 5qi3    ue_id=1    fail_regexp=mcs-Table qam64LowSE
    Verify Throuput    ue_id=1    qfi=1    pdu=1    Tput_dl=5*0.9    Tput_ul=3*0.9    sleep_time=10s
    UE Deregister From gNB    ue_id=1
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_L_04${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008246_L_05_High_reliability_DRB_IWK_with_PRB_blanking_UE_not_qam64lowse
        [Documentation]
    ...    1.Description
    ...    This user scenario validates the high reliability DRBs interworking with PRB blanking in 10MHz FDD cell.
    ...    2.Configuration
    ...      a.SA,FDD,10MHZ.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.disable PRB blanking deature actPRBBlanking = false.
    ...      d.UE doesn't support Ul-64QAM-MCS-TableAlt and Dl-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...      a.enable PRB blanking deature actPRBBlanking = true.
    ...      b.UE attach to target cell w default DRB 5QI5.
    ...      c.setup 2nd pdu session with drb5qi6 and 5ai80.
    ...      d.delete DRB 5qi80.
    ...      e.UE detach.
    ...    4.Check Points
    ...      4.1 for step b:drb 5qi5 added and no mcs-Table parameter in PDSCH-Config and PUSCH-Config
    ...      4.2 for step c:drb 5qi6 and 5qi80 added and check RRC RECONFIGURATION message, no mcs-Table parameter of PUSCH-Config and PUSCH-Config
    ...      4.3 for step d:drb 5qi80 released andcheck RRC RECONFIGURATION message, no mcs-Table parameter of PUSCH-Config and PUSCH-Config
    [Tags]    QC_321803    owner-qianqian.guo
    OnlineParamChange    ${PRBBlanking_enable}
    Cells Should Be Onair
    UE2 Attach To Target Cell    ue_id=2    cell_id=1    default_qos=5    fail_regexp=mcs-Table qam64LowSE
    Send And Verify Throuput    ue_id=2    qfi=1    pdu=1    send_dl=5    send_ul=3    sleep_time=10s
    Setup 2nd PDU with 5qi80    ue_id=2    default_qos=6    fail_regexp=mcs-Table qam64LowSE
    Send And Verify Throuput    ue_id=2    qfi=1    pdu=2    send_dl=5    send_ul=3    sleep_time=10s
    Send And Verify Throuput    ue_id=2    qfi=2    pdu=2    send_dl=5    send_ul=3    sleep_time=10s
    Del 2nd PDU DRB 5qi80    ue_id=2    fail_regexp=mcs-Table qam64LowSE
    Verify Throuput    ue_id=2    qfi=1    pdu=1    Tput_dl=5*0.9    Tput_ul=3*0.9    sleep_time=10s
    Verify Throuput    ue_id=2    qfi=1    pdu=2    Tput_dl=5*0.9    Tput_ul=3*0.9    sleep_time=10s
    UE Deregister From gNB    ue_id=2
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_L_05${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/2cells_1T1F    ue_count=15

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=2000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=2000 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6 default=on
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=80
    Update Cfg    set_qosflow id=10 5qi=76 gfbr_ul=3000 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    ue_param id=1 ue_nr_capabilities=${UE_Capa_Support_HR_PDSCH_PUSCH}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${UE_Capa_Not_Support_HR}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${default_qos}    ${pass_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3,8
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${pass_regexp}

Del DRB 5qi80
    [Arguments]    ${ue_id}    ${fail_regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=8 by=amf
    ...    fail_regexp=${fail_regexp}
    should contain    ${retvalue}    Removed FiveQi:Qfi mapping fiveQi 80 qfi 3

Del DRB 5qi3
    [Arguments]    ${ue_id}    ${fail_regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=3 by=amf
    ...    fail_regexp=${fail_regexp}
    should contain    ${retvalue}    Removed FiveQi:Qfi mapping fiveQi 3 qfi 2

UE2 Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${default_qos}    ${fail_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=${default_qos} priority=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    fail_regexp=${fail_regexp}

Setup 2nd PDU with 5qi80
    [Arguments]    ${ue_id}    ${default_qos}    ${fail_regexp}
    Execute Egate Command    qosflow_modify default=on qos_flow=${default_qos} priority=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=8
    ${retvalue}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1
    ...    fail_regexp=${fail_regexp}
    should contain    ${retvalue}    Setup QosFlow with QFI:1 5QI:6
    should contain    ${retvalue}    Setup QosFlow with QFI:2 5QI:80

Del 2nd PDU DRB 5qi80
    [Arguments]    ${ue_id}    ${fail_regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_del=8 by=amf
    ...    fail_regexp=${fail_regexp}
    should contain    ${retvalue}    Removed FiveQi:Qfi mapping fiveQi 80 qfi 2

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${pdu}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${qfi}=1    ${pdu}=1    ${send_dl}=30    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${pdu}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}
