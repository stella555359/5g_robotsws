*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT_NOT    team-CN1ET    owner-zhuo.lena
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]    CB008225    release-SBTS23R4
...    STATE_CONFIGURED
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CB008225_ET_I001}
...    @{CB008140_GNB1}
@{PARAMS_IN_SCF_GNB2}
...    @{CB008140_GNB2}

${NOKIA_XNAP_PLUGIN_FLAG}    ${True}

@{CB008225_ET_I001}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{HPA_related}
...    @{AC_related}
...    @{8225_related}

@{UAI}
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:timerReleasePreferenceProhibit=s3
...    NRBTS:outOfConnectedPreference=inactive

@{HPA_related}
...    NRCELL-1:actPriorityAccess=true
...    NRCELL-1:actEmergencyCall=true
...    NRBTS:applyPriorityAccess=HPA
...    NRBTS/NRPRIOACC_PROFILE-1:nrPlmnIdx=1
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=8
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=6
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax=4
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin=1
...    NRCELL-1:raPrioritizationForAI=MPS+MCS
...    NRCELL-1:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-1:powerRampingStep=dB2
...    NRCELL-1:pagingPrioLevelPaMax=1
...    NRCELL-1:pagingPrioLevelPaMin=1
...    NRCELL-1:tPageCorrInt=3000
...    @{EC_related}

@{AC_related}
...    NRCELL-1:maxNumOfRrcSA=1
...    NRCELL-1:maxNumOfUsersPerNRCell=1
...    NRCELL-1:maxNumOfUsersPerCell=1
...    NRCELL-1:maxNumOfCaUsersNRCell=1
...    NRCELL-1:maxNumOfNrDcSnUsers=1
...    NRCELL-1:maxNumOfSCellAlloc=1
...    NRCELL-1:numOfRadioResReservForPa=3
...    NRCELL-1:numOfRadioResReservForEmergency=1
...    NRCELL-1:numOfRadioResReservForTempUse=10
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=1

@{EC_related}
...    NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-1:actVoNR=true
...    @{5QI1}

@{5QI1}
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:discardTimer=40ms
...    NRBTS/NRDRB-15:discardTimerUl=infinity
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
#...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-15:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-4:schedulPrio=5
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50

@{8225_related}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:drbInactivityTimerSA=7200
...    NRBTS:srbInactivityTimerSA=600
...    NRBTS:maxUeRrcInactTime=1
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:t380=60min
...    NRBTS:actPaging=true
...    NRBTS:tRanPagingGuard=4
...    NRBTS:ranPagingCycle=v32
...    NRCELL:ranAC=0
...    NRBTS:activityNotificationLevelSA=ue
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRRCC=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrPaging=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrF1CD=5min
...    NRBTS:act3gppBL23R1=true
...    @{UAI}

@{AC_I001}
...    NRCELL-1:maxNumOfRrcSA=2
...    NRCELL-1:maxNumOfUsersPerNRCell=2
...    NRCELL-1:maxNumOfUsersPerCell=2
...    NRCELL-1:maxNumOfCaUsersNRCell=2
...    NRCELL-1:maxNumOfNrDcSnUsers=2
...    NRCELL-1:maxNumOfSCellAlloc=2
...    NRCELL-1:maxNumOfNonGBRBearersSA=10
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=120
...    NRCELL-2:numOfRadioResReservForTempUse=10

@{preemption_related}
...    NRBTS:actDrbPreemption=true
...    NRBTS:actUserPreemption=true
...    NRCELL:preferNsaPreemption=false
...    NRCELL:allowEmergencyReservForTempUse=false
...    NRCELL-2:emergencyCallRestrictions=${EMPTY}
...    NRBTS:maxNumOfPreemptions=20

@{CB008225_delta_I001}
...    @{AC_I001}
...    @{preemption_related}
...    NRCELL-1:actPriorityAccess=false

@{CB008225_recovery_I001}
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    @{AC_related}
...    NRCELL-1:actPriorityAccess=true

${UE_Capa_Support_UAI_VONR}    SEPARATOR=
...    E1A00000074E5A031E000384A0003C1260C80008785800C40340260300C0700CA8D851AC10143404B2CA261E003D6C10101070EF1C39061C00103278FAB
...    80027800E0009E00151B133582028680965944C3C007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28987800F5B0
...    404041C3BC70E418700040C9E3EAE0009E00380027800546C4ED6080A1A025965130F001EB608080838778E1C830E0008193C7D54000014000000420E26
...    8000000010134640000E010113D86C003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAA868007000B00000004008011A
...    B130001020304050607080B101112131921252627284A44A9440000840

${UE_Capa_Support_UAI_VONR_B41}    SEPARATOR=
...    E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700CA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F570
...    004F001C0013C002A36266B04050D012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89BAC10143404B2CA261A007AD820
...    2020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB28986801EB608080838778E1C830E0008193C7D54000014000000420E1400
...    000000100A0540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B00000004008011AB13
...    0001020304050607080B101112131921252627284A44A944000084

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{releasePreference_check}
...     QoS Routing Table
...     releasePreference-r16 supported

@{CB008225_resume_check}
...    resumeCause mt-Access
...    UE2: Received RRC Release
...    rrcResumeComplete

@{PM_Counters_Check_I001}
...    NRCELL-1:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1
...    NRCELL-1:${NRRCC_RRC_RESUME_REQUEST1}=1
...    NRCELL-1:${NRRCC_RRC_RESUME_SUCC}=1
...    NRCELL-1:${SA_UE_CTX_REL_PREEM}=1
...    NRCELL-1:${NG_FLOW_REL_GNB_PREEM}=1

@{CB008140_GNB1}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}

@{CB008140_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=80
...    NRBTS:actIncXn=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:maxNumScellsDlFr1=3
@{PARAMS_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actBcsCheck=enabled_FR1
...    NRBTS:rejectSuppBcs=none
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL:tddFrameStructure:frameStructureType=tdLte
...    NRCELL:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL:tddFrameStructure:lteToNrFrameShift=0ms
...    NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/9
...    NRCELL:prachConfigurationIndex=156
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=40
...    delete:NRBTS/NRADJGNB-2:xnLinkRef
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=3
...    NRBTS/NRADJNRCELL-1:nrarfcn=653400
...    NRBTS/NRADJNRCELL-1:physCellId=52
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=4
...    NRBTS/NRADJNRCELL-2:nrarfcn=648000
...    NRBTS/NRADJNRCELL-2:physCellId=53
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=11
...    NRBTS/NRADJNRCELL-3:nrarfcn=368400
...    NRBTS/NRADJNRCELL-3:physCellId=60
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=12
...    NRBTS/NRADJNRCELL-4:nrarfcn=153400
...    NRBTS/NRADJNRCELL-4:physCellId=61
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=11
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=12
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:weightForSCellSelection=50
...    NRCELL-3:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-3:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-3:tddFrameStructure:lteToNrFrameShift=${EMPTY}
...    NRCELL-3:tddFrameStructure:tdLteUlDlConfig=${EMPTY}
...    NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL-4:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-4:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-4:tddFrameStructure:lteToNrFrameShift=${EMPTY}
...    NRCELL-4:tddFrameStructure:tdLteUlDlConfig=${EMPTY}
...    NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-2/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=40
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:lcrId=1
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
@{PARAMS_FOR_OTHERS}
...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

${NRRCC_RRC_REL_WITH_SUSP_NRNAU}    M55124C00006    #This counter provides the total number of RRC releases with suspendConfig IE sent
#from the gNB-CU.
${NRRCC_RRC_RESUME_REQUEST1}    M55124C00007    #This counter provides the total number of RRCResumeRequests1 received at the gNB-CU.
${NRRCC_RRC_RESUME_SUCC}    M55124C00010    #This counter provides the total number of successful RRC Resume procedures from RRC_INACTIVE
#connection resumes fallbacks to RRC setup.
${SA_UE_CTX_REL_PREEM}    M55125C11501    #This counter describes the number of UE Context Releases for SA users due to preemption.
${NG_FLOW_REL_GNB_PREEM}    M55125C11504    #This counter describes the number of QosFlows that are released due to preemption reasons.

#UE_Capa: CA_n3A-n41A-n77(2A) with BCS0 and simultaneousRxTxInterBandCA
${SA_Capa_Support_4CC_n3_n41_n77_n77_CA_BCS0_simultaneousRxTxInterBandCA}    SEPARATOR=
...    E9A09000575F5A13160003C4A0002C1262E003387A16009B20C39F30C7942C0E0980C0311C04EE3603606B04610D04083A41E006D6C98AB1A1CF88E3D033EC09F1891C790E7D
...    473E618F28581C0E1E0B801FF800E000BE000C80000E0541B00B582308682041E20F0032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000
...    C80000E0551B133582308682041D20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF000640000702A0D837AC1184341020F10780195B26
...    2AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000640000703B8D851FFAC1184341020E907801B5B262AC6873E238F40CFB027C62471E439F51CF
...    9863CA1607038782F557FF553D55FFD5432000038024B0F1300038980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1F008003036061300C260
...    000C2C0AC5C02000C010181B0002058158F8040018060303606134000A160562E01000606C0C26000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D80
...    0242C0AC3C02000C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2600061300C01000382C0AC78020385000184C030980
...    00F0B02B171300030040606C0020160563E2680060080C030181B00088581009006E003404C800500A065001D212851226C73E1C4891226C73E1C4891226C73E1C68912244D8
...    E7C38912244D8E7C38D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C4891226C73E1C6
...    8912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D06C003C00281C1401C0C02500700060240040603E0900200000001000800000020000
...    0C0100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000
...    C0339535953582958195833582B594B7933780B581B58095811583B40D040000259494100001965260400006594901000039652404000125949010000596526040001A594901
...    000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D554
...    1E286802F012A05028140A05028140A05028140A05028140A05028008840400801010020044020040080801002020040088040300501002004040080118080600A0201802808
...    01002020040088040400501010014040580B18080600C02018028080600C02004008804030050100C014040080108080600A02004008404030050100C014202018030080600C
...    10100C018040300508080600A02018028804030050100C018040300508080600C020040088040080101002004040300518080600A02004008080100202004008804008010100
...    C018040300618080100202018028080600C02018028D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

@{Scell_expect}
...    pcid:52, scellIdx:1
...    pcid:53, scellIdx:2
...    pcid:60, scellIdx:3
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone

*** Test Cases ***
CB008225-ET-I001_Successful_transition_of_Suspended_UE_in_RRC_INACTIVE_to_RRC_CONNECTED_resume_of_SRBs_and_DRBs_With_UE_context_preemption
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behavior for UE in RRC_INACTIVE state that is successfully transitioned to
    ...    RRC_CONNECTED state in case of UE context or DRB resource shortage and ARP-based preemption enabled. Successful Resume procedure.
    ...    2. Configuration:
    ...    GNB cell1:
    ...    actUserPreemption/actRrcInactState enabled.
    ...    maxNumOfRrcSA=2.
    ...    3. Test Case Steps:
    ...    a.Set UE1 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...    trigger UE1 attach to Gnb cell1 as normal call with priority=2, PCI&PVI=true, then send UAI to trigger UE1 turn to RRC_inactive state.
    ...    b.UE2 attach to cell1 as normal call with priority=3, PVI=true, UE3 attach to cell1 as normal call with priority=4, PVI=false.
    ...    c.Tigger UE1 RRC resume with cause mt_Access.
    ...    d.check counter
    ...    e.UE11 Register And PDU Session Setup On GNB1 Cell1 ,Trigger CA_n3A-n41A-n77(2A) with BCS0 and simultaneousRxTxInterBandCA
    ...    f.UE11 Start Traffic And Verify Throughput
    ...    4. Expect result:
    ...    a.UE1 attach to cell1 successfully, then turn to RRC_inactive state.
    ...    b.UE2 and UE3 attach successfully.
    ...    c.UE1 turns back to RRC_connected state, UE2 been preempted and released.
    ...    e.UE11 Register And PDU Session Setup Successful, InterGnb Blind Add Gnb2 Cell3, Gnb2 Cell4 and Gnb2 Cell11 as Scell
    ...    f.UE11 Traffic And Throughput is OK
    ...    5. CheckPoints:
    ...    a.Check UE1 RRC release message contains SuspendConfig IE.
    ...    b.Check UE1 turns to RRC_connected with resume procedure.
    ...    c.Check UE2 released due to preempted.
    ...    d.Check counter.
    ...    e.UE11 register successfully and Scell addition successfully.
    ...    f.UE11 Traffic normally.
    [Tags]    owner-lena.zhuo    I001    AP_REG
    OnlineParamChange    ${CB008225_delta_I001}
    Clear Counter Files
    UE turn to inactive    ue_id=1    cell_id=1    priority=2
    multi UE attach
    RRC Resume    ue_id=1    cell_id=1    cause=mt_Access    pass_regexp=${CB008225_resume_check}
    Release Ues    ue_id=3,1
    check counters    pm_counters_expression=${PM_Counters_Check_I001}
    OnlineParamChange    ${CB008225_recovery_I001}

    # Start to CB008140 Scenario
    Wait Until Keyword Succeeds    180s    60s     Wait IgNBCAResourceStatusUpdate Received
    UE11 Register And PDU Session Setup With Blind 3 Scell Addition
    UE11 Run Traffic And Verify Throughput
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    #Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=2
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_N41_gnb2_2T2F

Run UL Traffic
    [Arguments]    ${ue_id}=1    ${Tput_ul}=4000000
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 bps=${Tput_ul} dir=ul
    ...    pass_regexp=Started Uplink Internal traffic

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=8 default=on
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=4
    Update Cfg    set_qosflow id=5 5qi=6
    Update Cfg    set_qosflow id=6 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1
    Update Cfg    ue_param id=11 ue_nr_capabilities=${SA_Capa_Support_4CC_n3_n41_n77_n77_CA_BCS0_simultaneousRxTxInterBandCA}

Run UL Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_ul}=4000000
    Run UL Traffic    ${ue_id}    ${Tput_ul}
    Verify Throughput UL TP    ${ue_id}    ${Tput_ul}

Verify Throughput UL TP
    [Arguments]    ${ue_id}=1    ${Tput_ul}=5    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}>${Tput_ul}/1000*0.9

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair

ICS With Preemption
    [Arguments]    ${ue_id}    ${cell_id}    ${pvi}    ${priority}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=1 priority=${priority} pci=may_trigger_pre_emption pvi=${pvi}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${releasePreference_check}
    Run UL Traffic And Verify Throughput    ue_id=${ue_id}    Tput_ul=60000

UAI
    [Arguments]    ${ue_id}=1    ${state}=inactive
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=${state}    pass_regexp=${INACTIVE_check}

UE turn to inactive
    [Arguments]    ${ue_id}    ${cell_id}    ${priority}
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR_B41}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling
    Execute Egate Command    ${cmd}
    ICS With Preemption    ue_id=${ue_id}    cell_id=${cell_id}    pvi=pre_emptable    priority=${priority}
    UAI    ue_id=${ue_id}    state=inactive
	
RRC Resume
    [Arguments]    ${ue_id}    ${cell_id}    ${cause}    ${pass_regexp}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}    fail_regexp=Initial Context Setup Failure
    Run UL Traffic And Verify Throughput    ue_id=${ue_id}    Tput_ul=60000
	
multi UE attach
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR_B41}
    Update UE capa    ue_id=3    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR_B41}
    ICS With Preemption    ue_id=2    cell_id=1    pvi=pre_emptable    priority=3
    ICS With Preemption    ue_id=3    cell_id=1    pvi=not_pre_emptable    priority=4

UE11 Register And PDU Session Setup With Blind 3 Scell Addition
    [Arguments]    ${ue_id}=11    ${gateway}=1    ${enb_id}=2    ${cell_id}=1
    log to console    Start to Test CB008140 Scenario
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=${Scell_expect}    timeout=20s
    Sleep    5s    #wait all Scell info print

UE11 Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=11    ${pdu}=1    ${qfi}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=3 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=4 protocol=tcp mbps=150 dir=dl
    ...    pass_regexp=Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=1 protocol=tcp mbps=50 dir=ul
    ...    pass_regexp=Started Uplink Internal traffic over TCP on Ue
    Verify Throughput    ${ue_id}    ${pdu}    ${qfi}    540    45
    [teardown]    Stop Traffic    ${ue_id}    ${pdu}

Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=1
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=2
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=3
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=dl trf_id=4
    ...    pass_regexp=Stopped Downlink Internal traffic on Ue
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu} dir=ul trf_id=1
    ...    pass_regexp=Stopping Uplink Internal traffic on Ue

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Wait IgNBCAResourceStatusUpdate Received
    Start to Capture Wireshark Log    XNAP_IgNBCAResourceStatusUpdate
    Sleep    60s
    Stop Capture Wireshark Log    XNAP_IgNBCAResourceStatusUpdate
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}wireshark_XNAP_IgNBCAResourceStatusUpdate.pcap
    ...    nokiaxnap.procedureCode == 139 && nokiaxnap.NR_Cell_Identity == 0x000008003 && nokiaxnap.NR_Cell_Identity == 0x00000800c
    Should Be True    ${number}>0
