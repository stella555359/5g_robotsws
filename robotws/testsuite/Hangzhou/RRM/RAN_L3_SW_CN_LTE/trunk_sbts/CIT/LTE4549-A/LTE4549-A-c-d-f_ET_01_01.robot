*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    owner-pei.han    team-CN3ET    release-SBTS19B
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNCEL:cqiAperEnable=false
...    @{remove_relation_err}
...    @{CA}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{LTE4549}
...    @{activatedMimoTM}
...    @{Tput_parameter}
...    @{RTPM_Param}
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=14
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=14
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2870
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3070
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20870
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21070
...    @{Handover}
@{PARAMS_IN_SWCONFIG}
...    0x00130060 = 1
#ENDC setup
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=20
...    LNCEL:maxNumScells=3
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=16
...    LNCEL:caPoolId=1
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-3:lcrId=4
...    LNCEL-1/CAREL-3:lnBtsId=1
...    LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNBTS-1:actFlexScellSelect=true
...    LNCEL-4/CAREL-1:lcrId=1
...    LNCEL-4/CAREL-1:lnBtsId=1
...    LNCEL-4/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-4/CAREL-2:lcrId=2
...    LNCEL-4/CAREL-2:lnBtsId=1
...    LNCEL-4/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-4/CAREL-3:lcrId=3
...    LNCEL-4/CAREL-3:lnBtsId=1
...    LNCEL-4/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-2:lcrId=2
...    LNCEL-3/CAREL-2:lnBtsId=1
...    LNCEL-3/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3/CAREL-3:lcrId=4
...    LNCEL-3/CAREL-3:lnBtsId=1
...    LNCEL-3/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNBTS:sCellDeactivationTimereNB=rf128
...    LNBTS-1:actAdvStepwiseScellAdd=off
...    LNCEL-2/CAREL-1:lcrId=3
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-2/CAREL-1:pcellSwapAllowed=forbidden
...    LNCEL-2/CAREL-1:scellPrio=1
...    LNCEL-2/CAREL-2:lcrId=4
...    LNCEL-2/CAREL-2:lnBtsId=1
...    LNCEL-2/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-2/CAREL-2:pcellSwapAllowed=forbidden
...    LNCEL-2/CAREL-2:scellPrio=1
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=14
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=14
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2870
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3070
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20870
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21070
...    LNBTS-1:actFlexCaMgmt=false
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:actCaArchEnhImp=off
...    LNCEL/LNCEL_FDD-0:actMixedMimoTMs=true
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
...    LNBTS:tLteNrDualConnectPrep=5000
...    LNCEL:defaultLnRelGnbCellId=1
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=629984
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
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference
${ue_nr_capabilities}
...    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000213601073E420F0008240310008A05851A0219434088107418604C04416C9014020018073
...    E420F0008240E0E02203C80F00002600001371378120480000002400000812000008014018060180601B005004020080230050060200802008
...    C0140080802300500002300500201806C01400006C04E54DE50DE5456E11BA40101000004186004000050618010000220821040000C8208410
...    0004208210134AA66944C572A2BB515D88
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
...    LNCEL:dlTargetBler=100
@{activatedMimoTM}
...    LNCEL/LNCEL_FDD-0:activatedMimoTM=TM9
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:csiRsSubfrConf=19
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=4
@{LTE4530}
...    LNBTS:actSnChangeSnInit=true
@{RTPM_Param}
...    LNBTS:actRtPerfMonitoring=All_PM_Counters
...    PMCADM-1:rTPmCollEntity:rTPmCollEntityHost=10.0.1.1
...    PMCADM-1:rTPmCollEntity:rTPmCollEntityPortNum=49525
...    PMCADM-1:rTPmCollEntity:rTPmCollInterval=60s
@{Handover}
...    LNBTS-1:actHoWoSnChg=intraEnbHoEnabled
...    LNBTS-1:actIfHo=enabled
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=3070
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-1:threshold2InterFreq=65
...    LNCEL-1:threshold1=90
${Wait_For_Throughtput_stable}    30s
@{Online_Param_01}
...    LNCEL/LNCEL_FDD-0:activatedMimoTM=TM9
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:csiRsSubfrConf=19
...    LNCEL/LNCEL_FDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=4
...    LNCEL:actModulationSchemeDl=256QAM
...    LNBTS-1:actAdvStepwiseScellAdd=off
${ue_eutra_nr_capabilities_01}
...    SEPARATOR=
...    C10040760B0200E2680000000040806C08010102060E2680000100D8100206040C1C4D00000401040002010100200460001008000402000100
...    808010023000080400020100008040400801
${ue_eutra_capabilities_01}
...    SEPARATOR=
...    ue_eutra_capabilities=DD98002A0106030737FFF839BFFFBFE7FF5F44240110C853A1504194E9525C7E7BF8000000000812F05012FC0000
...    000B3700300304218018210C00C00C00841082080304208200C1082080304218210A006006084304218210C1086004B5F55183040308001001
...    C200041420800E100020230400B08001050820A30410B0800101182023040370737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFE
...    0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFF
...    FE0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFEC0580001FB103016000011C3B00000D90F1F88FC000039B00010104000140501010101010004
...    010040100401004010040100401000000005014041405010501404140501010198200F995A601907F37A80018036C9000020000104B8E02800
...    010080309826BC0B7FC81003BFE40841077FC81102082168D00000811000
${SCELL_ADD_AT}    LNCEL-1:LTE_Cell_Resource:M8011C67
${SCELL_ADD_SU_ENDC}    LNCEL-1:LTE_X2_gNB_per_LNCEL:M8080C58
${SCELL_ADD_SU}    LNCEL-1:LTE_Cell_Resource:M8011C68
${SCELL_ADD_AT_ENDC}    LNCEL-1:LTE_X2_gNB_per_LNCEL:M8080C57
${V_1}
...    SEPARATOR=
...    DDB805021813F050B99FFF85CCFFFC2E67FFDFF3FFAEA21000886429D104194E9524C7F0173380000000BC220277C0000000B9B00300300304
...    218210C1086084304218018018210C00C00C1086006006104218410861042184108610421841086084304218210C1086184210C30842184108
...    610421841086104218410861042184108610421841086084304218210C1086084304218210C1086084304218210C1086084304218210C10860
...    84304218210C1086084304218210C1086084304218210C1086084304218210C00C00C2084304218210C108608430030030025A1F55184A6818
...    C000820610002081FE000820FF80020A304105FC20E300020838C000828C1041C600041420820A3041C2000410318001240C60004507080010
...    508208184000920610002283FE00082FE1040FF0004903FC001142FF000417F0828C12427F082FE10718001242FF000417F0828C11427F082F
...    E10718001142FF000417F0828C10427F082FE10718001041FF00041460920BF841C60004907FC00105182282FE10718001143C600041460828
...    41050820868C1051820E100020A10410B18001051820E100020858C000828C1050820848C1051820E100020858C00092841050820848C12708
...    001050820858C0008A841050820848C11708001050820858C00082841050820848C10708001050820838C02092841241C600049C2000490718
...    001250824828C127080412414609384000920E300824A104507180012708001141C6000494208A0A3049C2000450718041250820838C000938
...    4000820E300024A1041051824E100020838C0008B84000920E300022A1049051822E100824828C11708001241C600045C20004507180011508
...    22828C11708001141C600045C2000410718001150820828C11708001041C600041C2000490718001050824828C107080412414608384000920
...    E300020E100022838C0008284114146083840008A0E300020E100020818C020920610082485FE00082FE105FC2083FE00092FE10417F093FE0
...    00820FF80022BF84105FC22FF8002081FE0009A07F8082481FE0108B361733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67F
...    FE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E6
...    7FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2
...    E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFF
...    C2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCF
...    FFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF6CEC0000CE6823F87878BA2E00021E1E1E1E1C21E1E1E1E1E1E1C21E1E1E1
...    C00010F170079A000002020A02028080802008000002000000A0280808080808480A020480A020480A020480A020480A020480A02028080A02
...    028080A02060018004004004004004004004004004002008020080200802008020080200802008020080200802008020080200802008020080
...    20080200000120280A020A02808280A020A02808280A02020202020203340CD000000000000000000000000000040000000004000040004004
...    00040040040004004000000000003E6579A0401485FE694BBC500F800420019A48000100028825C500C4D40103411E08082080082080000080
...    0050901000100008800000
${V_2}
...    SEPARATOR=
...    DDB805021813F050B99FFF85CCFFFC2E67FFDFF3FFAEA21000886429D104194E9524C7F0173380000000BC220277C0000000B9B00300300304
...    218210C1086084304218018018210C00C00C1086006006104218410861042184108610421841086084304218210C1086184210C30842184108
...    610421841086104218410861042184108610421841086084304218210C1086084304218210C1086084304218210C1086084304218210C10860
...    84304218210C1086084304218210C1086084304218210C1086084304218210C00C00C2084304218210C108608430030030025A1F55184A6818
...    C000820610002081FE000820FF80020A304105FC20E300020838C000828C1041C600041420820A3041C2000410318001240C60004507080010
...    508208184000920610002283FE00082FE1040FF0004903FC001142FF000417F0828C12427F082FE10718001242FF000417F0828C11427F082F
...    E10718001142FF000417F0828C10427F082FE10718001041FF00041460920BF841C60004907FC00105182282FE10718001143C600041460828
...    41050820868C1051820E100020A10410B18001051820E100020858C000828C1050820848C1051820E100020858C00092841050820848C12708
...    001050820858C0008A841050820848C11708001050820858C00082841050820848C10708001050820838C02092841241C600049C2000490718
...    001250824828C127080412414609384000920E300824A104507180012708001141C6000494208A0A3049C2000450718041250820838C000938
...    4000820E300024A1041051824E100020838C0008B84000920E300022A1049051822E100824828C11708001241C600045C20004507180011508
...    22828C11708001141C600045C2000410718001150820828C11708001041C600041C2000490718001050824828C107080412414608384000920
...    E300020E100022838C0008284114146083840008A0E300020E100020818C020920610082485FE00082FE105FC2083FE00092FE10417F093FE0
...    00820FF80022BF84105FC22FF8002081FE0009A07F8082481FE0108B361733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67F
...    FE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E6
...    7FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2
...    E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFF
...    C2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCF
...    FFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF6CEC0000CE6823F87878BA2E00021E1E1E1E1C21E1E1E1E1E1E1C21E1E1E1
...    C00010F170079A000002020A02028080802008000002000000A0280808080808480A020480A020480A020480A020480A020480A02028080A02
...    028080A02060018004004004004004004004004004002008020080200802008020080200802008020080200802008020080200802008020080
...    20080200000120280A020A02808280A020A02808280A02020202020203340CD000000000000000000000000000040000000004000040004004
...    00040040040004004000000000003E6579A0401485FE694BBC500F800420019A48000100028825C500C4D40103411E08082080082080000080
...    0051901000100008800000
@{remove_relation_err}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=10 MHz
${attach_cp}
...    transmissionMode-r10 eq 'tm9-v1020' and
...    codebookSubsetRestriction-r10 eq '0b1111000000000000111111111111111111111111111111111111111111111111' and
...    gp0 eq 15 and
...    b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 56) and
...    maxLayersMIMO-r10 eq 'twoLayers'
${addscell_4}
...    sCellToAddModList-r10 contains (physCellId-r10 eq 4) and
...    transmissionMode-r10 eq 'tm9-v1020' and
...    codebookSubsetRestriction-r10 eq '0b1111000000000000111111111111111111111111111111111111111111111111' and
...    maxLayersMIMO-r10 eq 'fourLayers'
${addscell_2}
...    sCellToAddModList-r10 contains (physCellId-r10 eq 2) and
...    transmissionMode-r10 eq 'tm9-v1020' and
...    codebookSubsetRestriction-r10 eq '0b1111000000000000111111111111111111111111111111111111111111111111' and
...    maxLayersMIMO-r10 eq 'fourLayers' and
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 1,sCellIndex-r10 eq 2)
${releasescell1}
...    sCellToReleaseList-r10 contains (2) and
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 1)
${releasescell2}
...    sCellToReleaseList-r10 contains (1) and
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 2)
${addscell_3}
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 2,sCellIndex-r10 eq 1) and
...    physCellId-r10 eq 3 and
...    maxLayersMIMO-r10 eq 'fourLayers' and
...    transmissionMode-r10 eq 'tm9-v1020' and
...    codebookSubsetRestriction-r10 eq '0b1111000000000000111111111111111111111111111111111111111111111111'

*** Test Cases ***
LTE4549-A-c-d-f_ET_01_01_TM9 two layers signal cell to TM9 four layers 3CC CA ENDC mode
    [Documentation]    case_name:LTE4549-A-b-c-d-f_ET_01_01_TM9 two layers signal cell to TM9 four layers 3CC CA ENDC mode then SgNB initiated
    ...    modification lead to one scell release and another one scell add also scells layers down to two
    [Tags]
    OnlineParamChange    ${Online_Param_01}
    Set ue parameters before attach
    UE attach
    Trigger Dynamic ENDC    X:Y=2:1
    Start traffic
    Get Throughput Ave and Verify    Target=222
    SgNB modification required    X:Y=3:1
    Get Throughput Ave and Verify    Target=222

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Execute Cmd On Pc    sudo ifconfig eth4:1 add 10.0.2.11
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7
    execute egate command    trace_sim uec=1 protocol=rrc on
    execute egate command    trace_sim on mme=1 protocol=s1
    execute egate command    debug_log level=6
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create Enb Alias    GNB_8    enb_id=8    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '630000:630000',tdd_cell: yes}
        Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}
    ${GNB8_CELL1}    catenate    - {id: 81, technology: nr, tac: 33, pci: '1:0', nrci: '0x0000502', nr_arfcn: '636666:636666',tdd_cell: yes}
        Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...      gnb_id: '0x00008'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.12
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB8_CELL1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 6, pdn: 1}
    Update Yaml    UEs/UE_sets/1     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/1    capability: ${V_1}
    Update Yaml    UEs/UE_sets/2    capability: ${V_2}
    add yaml    EPC
    ...    UEC:
    ...    - id: 1
    ...    peer_uplane: '10.0.2.11:2152'

Set ue parameters before attach
    [Arguments]    ${ue_id}=1
    execute egate command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    execute uex command     ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=78
    execute uex command    ue_cqi_param id=${ue_id} scell=0-3 rank=4 cell=both
    execute egate command    gnb_endc_param id=8 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE attach
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${attach_cp})
    ...    alias=attch_flow    overall_timeout=30
    ${V_3}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_01}
    ...    ${ue_eutra_capabilities_01} enb=1 cell=1
    execute uex command    ${V_3}
    flow occurred as expected    alias=attch_flow

Start traffic
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${addscell_4})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${addscell_2})
    ...    alias=addscell_flow    overall_timeout=60
    execute uex command    trf_data_start ue=1 dir=dl Mbps=150 ue=${ue_id} trf_id=1 protocol=udp
    execute uex command    trf_data_start ue=1 dir=dl Mbps=150 ue=${ue_id} trf_id=2 protocol=udp
#    execute uex command    trf_data_start ue=1 dir=dl Mbps=150 ue=${ue_id} trf_id=3 protocol=udp
#    execute uex command    trf_data_start ue=1 dir=dl Mbps=150 ue=${ue_id} trf_id=4 protocol=udp
    Sleep    ${Wait_For_Throughtput_stable}
    flow occurred as expected    alias=addscell_flow

Get Throughput Ave and Verify
    [Arguments]    ${Target}=0    ${ue_id}=1
    check average throughput    ${ue_id}    ${Target}

Trigger Dynamic ENDC
    [Arguments]    ${ue_id}=1    ${X:Y}=disable
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    alias=sgaddition_flow    overall_timeout=60
    execute egate command    gnb_endc_param id=7 selected_band_combination_nr=${X:Y}
    execute uex command    ue_measurement_send id=${ue_id} meas_id_blacklist=18 event=B1_NR phycell_id=1 nrsrp=60
    Sleep    ${Wait_For_Throughtput_stable}
    flow occurred as expected    alias=sgaddition_flow

SgNB modification required
    [Arguments]    ${ue_id}=1    ${X:Y}=disable
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${releasescell1})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${addscell_3})
    ...    alias=sgmodi_flow    overall_timeout=60
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${releasescell2})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${addscell_3})
    ...    alias=sgmodi_flow2    overall_timeout=60
    execute egate command    gnb_endc_param id=7 selected_band_combination_nr=${X:Y} include_reestablish_pdcp=off
    execute egate command    enb_ue_dc_modify by=gnb ue=${ue_id} cause=RN_handover_desirable_for_radio_reasons
    Sleep    ${Wait_For_Throughtput_stable}
    verify at least one flow occurs as expected      sgmodi_flow    sgmodi_flow2



