*** Settings ***
Suite Setup    Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...    owner-jun.3.ye    owner-yin.zhang    release-SBTS20A    team-DEVHZ5_SG6
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{LTE4549}
...    @{LTE5515}
...    @{Tput_parameter}
...    @{modulation}
...    @{pcellswap}
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=7
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=7
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2870
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3070
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20870
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21070
...    LNCEL-3/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL-3:redBwRbUlConfig:redBwMaxRbUl=25
...    @{activatedMimoTM}
...    @{PARAMS_FIX_RELATION_ERROR}
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL-1/CAREL-1:lcrId=3
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=16
...    LNCEL:caPoolId=1
...    LNCEL:maxNumScells=1
...    LNBTS-1:actFlexScellSelect=true
...    LNCEL:actFlowCtrlEnh=false
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.31
...    delete:LNBTS-1/LNADJ-255
...    LNCEL-1/CAREL-1:scellPrio=3
...    LNBTS:sCellDeactivationTimereNB=rf128
...    LNBTS-1:actAdvStepwiseScellAdd=buffer-based
...    LNCEL:actScellConfigForHiDemand=false
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=10
...    LNCEL-1:actCaArchEnhImp=on_peak_data_rate_basic
...    LNCEL-2:actCaArchEnhImp=on_peak_data_rate_basic
...    LNCEL-3:actCaArchEnhImp=on_peak_data_rate_basic
...    LNCEL-4:actCaArchEnhImp=on_peak_data_rate_basic
...    LNBTS-1:actFlexCaMgmt=true
@{x2link}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNCEL:defaultLnRelGnbCellId=1
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference
@{modulation}
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNCEL:actDl256QamChQualEst=false
...    LNCEL:dl256QamDeactChQualThr=13
...    LNCEL:dl256QamReactChQualThr=22
...    LNCEL:iniDl256QamChQualEst=1s
...    LNCEL:perDl256QamChQualEst=60s
...    LNCEL:actDlPwBackoff=true
...    LNCEL:dlPwBackoffStructure:dlPwBackoffApp=ALL
...    LNCEL:dlPwBackoffStructure:dlPwBackoffThreshold=50
...    LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue1=0
...    LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue2=1
...    LNCEL:dlPwBackoffStructure:usageOfMaxDlPwBackoffValue2=QAM256r1r2r3r4
...    LNBTS:pdcpProf2:snSize=15bit
...    LNBTS:rlcProf7:tReord=15ms
${ue_eutra_capabilities_01}
...    SEPARATOR=
...    DD980010830205C1705DF837626800A0DDC25F83762697864045EFC1BB1356CA0060050420821041006084300300304018200C108600600442
...    080108010420800840082100018210410820803042082104100608410420821041006084104208200C10820841040182104108208030420820
...    0C108208030420821041006006004B43EAA30A020708210828C1000C208420818C10841640B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0
...    B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0BBF14000066CBF40000000FD00000
...    003F400000008787878B847F1721E1E1E1E1E1E1E1E1E1E1C43C3C3C3800022FD880000220208008082000000A02028080800000280A021800
...    60010010010010010010008020080200802008020080200802008020080200802008020080200802008020000134080003E79E00020406080C
...    0E162636383A83F7FC4A0080000FA00000000056980642FF37A8401830200400000FA000000000006D920400400016000000001404000600B0
...    104B8E03000010080309826850F00DFF000003A00000061000
${ue_nr_capabilities}    CE00000001C8F5C0302800001939980000CC00100002600001349880000018060010000001
${ue_eutra_nr_capabilities_01}
...    SEPARATOR=
...    C100609613020040C1C4D00000007F00000000040D82C080389A0000040FE00000000081B05830071340000101FC0000000010362300004040
...    810103071340000181FC0000000010201001006809A00002006200008040002010100200480001008000402000100800040202004008400020
...    101002004200010080801002
@{pcellswap}
...    LNBTS:actPcellSwap=true
...    LNBTS:actIfHo=enabled
...    LNCEL-1:pcellSwapConfig:numCaUeThreshold=5
...    LNCEL-1:pcellSwapConfig:puschLoadIndexThr=0.01
...    LNCEL-2:pcellSwapConfig:numCaUeThreshold=10
...    LNCEL-2:pcellSwapConfig:puschLoadIndexThr=10
...    LNCEL-3:pcellSwapConfig:numCaUeThreshold=10
...    LNCEL-3:pcellSwapConfig:puschLoadIndexThr=10
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL:loadSettings:targetLoadGbrDl=50
...    LNCEL:loadSettings:targetLoadNonGbrDl=75
...    LNCEL:loadSettings:targetLoadPdcch=90
...    LNCEL:loadSettings:ulCacIgnore=false
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulStaticCac=100
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-3/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-1:scellPrio=3
...    LNCEL-3:scellFastSchedulingSelect=normal
...    LNCEL-3:dlCaMinPcellCqi=0
...    LNCEL-3:dlCaMinPcellCqiQci1=0
...    LNCEL-3:ulCaMinPcellSinr=0
...    LNCEL-3:ulCaMinPcellSinrQci1=0
@{LTE5515}
...    LNBTS:actEnhFlexCaWithEnDc=true
...    LNBTS:enableBwComSetChkEnDc=true
@{Tput_parameter}
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNCEL:actDl256QamChQualEst=false
...    LNCEL:dl256QamDeactChQualThr=13
...    LNCEL:dl256QamReactChQualThr=22
...    LNCEL:iniDl256QamChQualEst=1s
...    LNCEL:perDl256QamChQualEst=60s
...    LNCEL:actDlPwBackoff=true
...    LNCEL:dlPwBackoffStructure:dlPwBackoffApp=ALL
...    LNCEL:dlPwBackoffStructure:dlPwBackoffThreshold=50
...    LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue1=0
...    LNCEL:dlPwBackoffStructure:maxDlPwBackoffValue2=1
...    LNCEL:dlPwBackoffStructure:usageOfMaxDlPwBackoffValue2=QAM256r1r2r3r4
...    LNBTS:pdcpProf2:snSize=15bit
...    LNBTS:rlcProf7:tReord=15ms
@{Online_Param_a_01}
...    LNBTS:actEnhFlexCaWithEnDc=true
...    LNBTS:enableBwComSetChkEnDc=true
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL-1/CAREL-1:lcrId=3
...    LNCEL:maxNumScells=1
...    delete:LNCEL-1/CAREL-2
...    delete:LNCEL-1/CAREL-3
...    delete:LNCEL-3/CAREL-1
@{Online_Param_b_04}
...    LNBTS:actEnhFlexCaWithEnDc=true
...    LNBTS:enableBwComSetChkEnDc=true
...    LNCEL-1/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-3:lcrId=4
...    LNCEL-1/CAREL-3:lnBtsId=1
...    LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL:maxNumScells=3
@{Online_Param_e_01}
...    LNBTS:actEnhFlexCaWithEnDc=true
...    LNBTS:enableBwComSetChkEnDc=true
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=20 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=20 MHz
...    LNCEL:maxNumScells=1
...    delete:LNCEL-1/CAREL-2
...    delete:LNCEL-1/CAREL-3
...    delete:LNCEL-3/CAREL-1
...    LNCEL-1/CAREL-1:lcrId=3
@{activatedMimoTM}
...    LNCEL/LNCEL_FDD-0:activatedMimoTM=TM9
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:csiRsSubfrConf=19
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=4
${ue_eutra_capabilities_b_04}
...    SEPARATOR=
...    DD980010830205C1705DF837626800A0DDC25F83762697864045EFC1BB1356CA0060050420821041006084300300304018200C108600600442
...    080108010420800840082100018210410820803042082104100608410420821041006084104208200C10820841040182104108208030420820
...    0C108208030420821041006006004B43EAA30A070308210820E10421050820858410841420838C108410F0821082841051820A304107082008
...    28C1042C208020A3041460820E10401051820858410041460828C105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82EFC5000019B2FD00000003F40000000FD000000021E1
...    E1E2E11FC5C878787878787878787878710F0F0F0E00008BF62000008808200202080000028080A0202000000A028086001800400400400400
...    400400200802008020080200802008020080200802008020080200802008020080200800004D020000F9E78000810182030385898D8E0EA0FD
...    FF1280200003E80000000015A60190BFCDEA10060C0801000003E800000000001B6481001000058000000005010001802C0412E380C0000402
...    00C2609A143C037FC00000E8000001840000
${ue_eutra_nr_capabilities_b_04}
...    SEPARATOR=
...    C100611613020040C1C4D00000007F00000000040D82C080389A0000040FE00000000081B05830071340000101FC0000000010362300004040
...    810103071340000181FC0000000010361302004041C4D00000800081B0D8100202040C1C4D00000A07F00000000040D88C0801010206040C1C
...    4D00000C00081B0D8100206040C1C4D00000E0008100800803404D000010071000040200010080801002100008040400801080004020200400
...    900002010000804000201000080404008011000040200010080801002300008040002010000804040080120000402000100800040200010080
...    8010023000080400020100008040400801
${ue_eutra_capabilities_e_01}
...    SEPARATOR=
...    DD98003001040C081705C177E0DD89A0028377097E0DD89A5E190117BF06EC4D5B280180141082084104018210C00C00C10060803042180180
...    110820042004108200210020840006084104208200C1082084104018210410820841040182104108208030420821041006084104208200C108
...    2080304208200C1082084104018018012D0FAA8C28081C208420A3040030821082063042105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E
...    0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82EFC5000019B2FD00000003F40
...    000000FD000000021E1E1E2E11FC5C878787878787878787878710F0F0F0E00008BF62000008808200202080000028080A0202000000A02808
...    6001800400400400400400400200802008020080200802008020080200802008020080200802008020080200800004D020000F9E7800081018
...    2030385898D8E0EA0FDFF1280200003E80000000015A60190BFCDEA10060C0801000003E800000000001B64810010000580000000050100018
...    02C0412E380C000040200C2609A143C037FC00000E800000184000
${ue_eutra_nr_capabilities_e_01}
...    SEPARATOR=
...    C100609613020040C1C4D00000007F00000000040D82C080389A0000040FE00000000081B1180003020060800C180389A0000080FE00000000
...    081B0D8100202040C1C4D00000607F000000000408040000080200609A01880002010000804040080108000402020040090000201000080400
...    020100008040400801180004020001008000402020040080
@{PARAMS_FIX_RELATION_ERROR}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:enableNonCompBcsChkEnDc=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:tS1eRABModInd=2000
...    LNCEL:eTputFilterConfig=51
...    LNCEL:eTputInitMcs=20
...    delete:LNCEL/MBSFNCEL-.*

*** Test Cases ***
LTE5515-A-a_ET_01_01_Feature deactivation with enableBwComSetChkEnDc set to false
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Online_Param_a_01}
    UE Attach And Start Traffic To Trigger 2CC CA    ue=1
    Trigger ENDC And CA Changed From 2CC to 1CC    ue=1
    Check Current Throughput    ue_id=1    target=144
    Delta Commission Parameters    LNBTS:enableBwComSetChkEnDc=false
    UE Attach And Start Traffic To Trigger 2CC CA    ue=2
    Trigger ENDC And CA Still 2CC    ue=2
    Check Current Throughput    ue_id=2    target=76
    Check Current Throughput    ue_id=1    target=75

LTE5515-A-b_ET_04_01_Bandwidth combination set checking succeed with 4CC CA during inter-band EN-DC setup
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Online_Param_b_04}
    UE Attach With 4cc Capability    ue=3
    Start traffic To Trigger 4CC CA    ue=3
    Check Current Throughput    ue_id=3    target=144
    Trigger ENDC And CA Still 4CC    ue=3
    Check Current Throughput    ue_id=3    target=144

LTE5515-A-e_ET_01_01_Scell added successful after inter-band EN-DC setup
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Online_Param_e_01}
    UE Attach With 2cc Capability    ue=4
    Trigger ENDC    ue=4
    Start traffic To Trigger 2CC CA    ue=4

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=4    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Set ue parameters before attach

Perform Steps After Onair
    @{lnadjgnb7}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.11    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${lnadjgnb7}

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '630000:630000',
    ...    meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz15,
    ...    ssb_mtc_periodicity_and_offset: 'sf5:1', ssb_mtc_duration: 'sf1'}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...    gnb_id: '0x00007'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2u: 10.0.1.12
    ...    x2_peers: none
    ...    cells:
    ...       ${GNB7_CELL1}

Set ue parameters before attach
    Execute Uex Command    ue_param id=1-4 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=78
    Execute Uex Command    ue_cqi_param id=1-4 scell=0-3 rank=4 ri_i1=18
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms T_DC_Overall=5000ms

Start traffic To Trigger CA
    [Arguments]    ${ue}    ${ca_conf}
    Expect Message Flow
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${ca_conf})
    ...    alias=ca_flow    overall_timeout=20
    Execute Uex Command    trf_data_start ue=${ue} Mbps=150 dir=dl protocol=udp
    Flow Occurred As Expected    alias=ca_flow

UE Attach And Start Traffic To Trigger 2CC CA
    [Arguments]    ${ue}
    ${attach_cmd}    catenate
    ...    ue_attach id=${ue} cell=1 ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_01}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_01}
    Execute Uex Command    ${attach_cmd}
    Start traffic To Trigger 2CC CA    ${ue}

Start traffic To Trigger 2CC CA
    [Arguments]    ${ue}
    ${2cc}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 2870)
    ...    and length(sCellToAddModList-r10) eq 1
    Start traffic To Trigger CA    ${ue}    ${2cc}

Start traffic To Trigger 4CC CA
    [Arguments]    ${ue}
    ${4cc}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq 1600,
    ...    sCellIndex-r10 eq 2 and physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 2870,
    ...    sCellIndex-r10 eq 3 and physCellId-r10 eq 4 and dl-CarrierFreq-r10 eq 3070)
    ...    and length(sCellToAddModList-r10) eq 3
    Start traffic To Trigger CA    ${ue}    ${4cc}

UE Attach With 4cc Capability
    [Arguments]    ${ue}
    ${attach_cmd}    catenate
    ...    ue_attach id=${ue} cell=1 ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_b_04}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_b_04}
    Execute Uex Command    ${attach_cmd}

UE Attach With 2cc Capability
    [Arguments]    ${ue}
    ${attach_cmd}    catenate
    ...    ue_attach id=${ue} cell=1 ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_e_01}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_e_01}
    Execute Uex Command    ${attach_cmd}

Trigger ENDC And CA changed
    [Arguments]    ${ue}    ${selected_bc}    ${ca_conf}
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=${selected_bc}
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${ca_conf})
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfigurationComplete
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=b1_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue} event=B1_NR phycell_id=1 nrsrp=62
    Flow Occurred As Expected    alias=b1_flow

Trigger ENDC And CA Changed From 2CC to 1CC
    [Arguments]    ${ue}
    ${DC_3A_7A_n78A_BSC0}    Set Variable    1:1    # not support band7 5MHz, support 10 15 and 20MHz
    ${2cc_to_1cc}    Catenate    sCellToReleaseList-r10 contains (1) and sCellToAddModList-r10 is not present
    Trigger ENDC And CA changed    ue=${ue}    selected_bc=${DC_3A_7A_n78A_BSC0}    ca_conf=${2cc_to_1cc}

Trigger ENDC And CA Still 2CC
    [Arguments]    ${ue}
    ${DC_3A_7A_n78A_BSC0}    Set Variable    1:1    # not support band7 5MHz, support 10 15 and 20MHz
    ${2cc_to_2cc}    Catenate    sCellIndex-r10 eq 1
    Trigger ENDC And CA changed    ue=${ue}    selected_bc=${DC_3A_7A_n78A_BSC0}    ca_conf=${2cc_to_2cc}

Trigger ENDC And CA Still 4CC
    [Arguments]    ${ue}
    ${DC_3A_3A_7A_7A_n78A_BSC0}    Set Variable    7:1    # suport all bandwidth
    ${4cc_to_4cc}    Catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1, sCellIndex-r10 eq 2, sCellIndex-r10 eq 3)
    ...    and length(sCellToAddModList-r10) eq 3
    Trigger ENDC And CA changed    ue=${ue}    selected_bc=${DC_3A_3A_7A_7A_n78A_BSC0}    ca_conf=${4cc_to_4cc}

Trigger ENDC
    [Arguments]    ${ue}
    ${DC_3A_7A_n78A_BSC0}    Set Variable    1:1
    ${no_ca}    Catenate    sCellIndex-r10 is not present
    Trigger ENDC And CA changed    ue=${ue}    selected_bc=${DC_3A_7A_n78A_BSC0}    ca_conf=${no_ca}
