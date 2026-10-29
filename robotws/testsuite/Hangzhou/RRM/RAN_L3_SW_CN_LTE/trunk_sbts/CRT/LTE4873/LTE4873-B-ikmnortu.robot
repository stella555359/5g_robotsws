*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT    team-SG5
...               CLOUD_R4LAPO_CUS    release-xL19A    owner-menghuan.fang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:caSchedFairFact=0
...    LNBTS-1:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS-1:qciTab6:nrPdcpProfIdx=1001
...    LNBTS-1:tLteNrDualConnectPrep=10000
...    LNBTS-1:mcc=262
...    LNBTS-1:mnc=3
...    LNBTS-1:mncLength=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:lnBtsId=100000
...    LNBTS-1/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-1:pdcpProf1001:pdcpProfileId=1001
...    LNBTS-1:pdcpProf1001:snSizeDl=18bit
...    LNBTS-1:pdcpProf1001:snSizeUl=18bit
...    LNBTS-1:pdcpProf1001:statusRepReq=0
...    LNBTS-1:pdcpProf1001:tDiscard=300ms
...    LNCEL:harqMaxTrVoLteDl=4
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL:tac=33
...    LNBTS-1:actEvtSecRatRep=true
...    LNBTS-1:tX2SgNBRelData=10000
...    @{NRDCDPR}
...    @{NRDCPR}
...    @{relation_error_fixed}
...    @{x2link}
...    @{PAPAMS_FOR_TRACE}
@{relation_error_fixed}
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:tS1eRABModInd=2000
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1:nrRestrictionOverride=disabled
...    LNBTS-1:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
@{x2link}
...    LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=49951
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNBTS-1/LNADJGNB-2:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=66601
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
@{NRDCDPR}
...    LNBTS-1/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-1/NRDCDPR-0:tPeriodicPhr=100sf
...    LNBTS-1/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS-1/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS-1/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=531040
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    @{NRDCDLocalCellID}
@{NRDCPR}
...    LNBTS-1/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=${NRARFCN531000}
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=8
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrq=8
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=2
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    @{NRDCLocalCellID}
@{WCDMA_param}
...    LNBTS-1:actHOtoWcdma=true
...    LNBTS-1:actHoFromUtran=true
...    LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...    LNBTS-1:actLTES1Ho=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1/LNADJW-1:uTargetCid=2
...    LNBTS-1/LNADJW-1:uTargetFreq=10663
...    LNBTS-1/LNADJW-1:uTargetLac=124
...    LNBTS-1/LNADJW-1:uTargetRac=111
...    LNBTS-1/LNADJW-1:uTargetRncId=12
...    LNBTS-1/LNADJW-1:uTargetScFdd=22
...    LNBTS-1/LNADJW-1:srvccHoInd=PSandCS
...    LNCEL-1:threshold2Wcdma=64
...    LNCEL-1:threshold2a=64
...    LNCEL-1:threshold2InterFreq=55
...    LNCEL-1/LNHOW-1:b2Threshold1Utra=54
...    LNCEL-1/LNHOW-1:b2Threshold1UtraQci1=54
...    LNCEL-1/LNHOW-1:b2Threshold2UtraRscp=10
...    LNCEL-1/LNHOW-1:utraCarrierFreq=10663
...    LNCEL-1/LNRELW-1:psHoAllowed=allowed
...    LNCEL-1/LNRELW-1:uTargetCid=2
...    LNCEL-1/LNRELW-1:uTargetRncId=12
...    LNCEL-1/LNRELW-1:srvccAllowed=allowed
@{NRDCDLocalCellID}
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
@{NRDCLocalCellID}
...    LNBTS-1/NRMEASPR-0:cellList=1
@{PARAM_B-i_01_01}
...    LNCEL-2:defaultLnRelGnbCellId=1
...    LNBTS-1:tX2SgNBRelData=10000
...    LNBTS-1:actSecRatRep=true
@{PARAM_B-k_01-01}
...    LNBTS-1:tX2SgNBRelData=2000
...    LNBTS-1:actSecRatRep=true
...    @{WCDMA_param}
@{PARAM_B-k_01-01_recovery}
...    LNBTS-1:actHOtoWcdma=false
...    LNBTS-1:actHoFromUtran=false
...    LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=false
@{PARAM_B-m_01_01}
...    LNCEL:inactivityTimer=60
...    LNBTS-1:tX2SgNBRelData=5000
...    LNBTS-1:actSecRatRep=true
...    LNBTS-1:act8EpsBearers=true
...    LNBTS-1:actExtMeasCtrl=false
...    LNBTS-1:actFlexQCIARPPMProfiles=true
...    LNBTS-1:actNwReqUeCapa=true
...    LNBTS-1:actSnChangeSnInit=true
...    LNBTS-1:enableBwCombCheck=false
...    LNBTS-1:reqFreqBands:bandNumber=1
...    LNBTS-1:reqFreqBands:bandPrio=1
...    LNCEL:actCaArchEnhImp=off
#...    LNCEL:actFlowCtrlEnh=false
...    LNCEL:actScellConfigForHiDemand=false
@{PARAM_B-m_01_01_recovery}
...    LNCEL:inactivityTimer=1000
...    LNBTS-1:actSecRatRep=false
...    LNBTS-1:act8EpsBearers=false
...    LNBTS-1:actFlexQCIARPPMProfiles=false
...    LNBTS-1:actNwReqUeCapa=false
...    LNBTS-1:actSnChangeSnInit=false
...    LNBTS-1:enableBwCombCheck=true
...    delete:LNBTS-1:reqFreqBands
...    delete:LNCEL:actCaArchEnhImp
...    delete:LNCEL:actFlowCtrlEnh
...    delete:LNCEL:actScellConfigForHiDemand
@{PARAM_B-n_01_01}
...    LNBTS-1:tX2SgNBRelData=10000
...    LNBTS-1:actSecRatRep=false
@{PARAM_B-o_08_01}
...    LNCEL-1:inactivityTimer=15
...    LNBTS-1:tX2SgNBRelData=10000
...    LNBTS-1:actSecRatRep=false
@{PARAM_B-o_08_01_recovery}
...    LNCEL:inactivityTimer=1000
@{PARAM_B-r_01_01}
...    LNBTS-1:actEvtSecRatRep=false
...    LNBTS-1:actSecRatRep=true
...    delete:LNBTS-1:tX2SgNBRelData
...    LNBTS-1:actCellTrace=true
...    LNBTS-1:actCellTraceWithIMSI=true
@{PAPAMS_FOR_TRACE}
...    LNBTS-1/CTRLTS-1/MTRACE-1:jobType=TraceOnly
...    LNBTS-1/CTRLTS-1/MTRACE-1:tceIpAddress=10.0.1.1
...    LNBTS-1/CTRLTS-1/MTRACE-1:tceCellTracePortNum=49150
...    LNBTS-1/CTRLTS-1/MTRACE-1:traceRrcSetting=All
...    LNBTS-1/CTRLTS-1/MTRACE-1:traceS1Setting=All
...    LNBTS-1/CTRLTS-1/MTRACE-1:traceX2Setting=All
@{PARAM_B-r_01_01_recovery}
...    LNBTS-1:actCellTrace=false
...    LNBTS-1:actCellTraceWithIMSI=false
@{PARAM_B-u_02_01}
...    LNBTS-1:qciTab7:lteNrDualConnectSupport=EN-DC
...    LNBTS-1:qciTab7:nrPdcpProfIdx=1001
...    LNBTS-1:qciTab9:lteNrDualConnectSupport=EN-DC
...    LNBTS-1:qciTab9:nrPdcpProfIdx=1001
...    LNBTS-1:actSecRatRep=false
...    LNBTS-1:tX2SgNBRelData=10000
...    LNBTS-1:actMultiSCGSplit=true
...    LNBTS-1:actEvtSecRatRep=true
@{PARAM_B-u_02_01_recovery}
...    LNBTS-1:qciTab7:lteNrDualConnectSupport=disabled
...    LNBTS-1:qciTab9:lteNrDualConnectSupport=disabled
...    LNBTS-1:actMultiSCGSplit=false
@{PARAM_B-t_01_01}
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-1:actSecRatRep=false
...    LNBTS-1:tX2SgNBRelData=10000
...    LNCEL-1:inactivityTimer=60
...    LNBTS-1:actERabModify=true
...    LNBTS-1:actEnhAcAndGbrServices=true
...    LNBTS-1:actMultGbrBearers=true
...    LNBTS-1:actNonGbrServiceDiff=true
...    LNBTS-1:act8EpsBearers=true
...    LNBTS-1:actOperatorQCIGBR=false
...    LNBTS-1:actOperatorQCI=false
...    LNBTS-1:maxNumPreEmptions=2
...    LNBTS-1:timDelACContPreempt=100
...    LNBTS-1:actContextPreemption=true
...    LNBTS-1:estCauseArpMapConfig:arpPriority=1|estCause=emergency
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=emergency
...    LNBTS-1:estCauseArpMapConfig:arpPriority=2|estCause=highPriorityAccess
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=highPriorityAccess
...    LNBTS-1:estCauseArpMapConfig:arpPriority=10|estCause=mt-Access
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=mt-Access
...    LNBTS-1:estCauseArpMapConfig:arpPriority=11|estCause=mo-Signalling
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=mo-Signalling
...    LNBTS-1:estCauseArpMapConfig:arpPriority=12|estCause=mo-Data
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=mo-Data
...    LNBTS-1:estCauseArpMapConfig:arpPriority=13|estCause=delayTolerantAccess-v1020
...    LNBTS-1:estCauseArpMapConfig:preemptionCap=true|estCause=delayTolerantAccess-v1020
...    LNCEL-1/SIB-0:t300=2000ms
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=1
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=0
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=1
...    LNCEL-1:actNbrForNonGbrBearers=false
...    LNCEL-1/LNCEL_FDD-0:srsActivation=true
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:addAUeRrHo=0
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:addAUeTcHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumDrbRadioReasHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumDrbTimeCriticalHo=0
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=3
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=0
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrc=0
...    LNCEL-1:actUlLnkAdp=fUlLa
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:deltaPucchShift=1
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:n1PucchAn=10
@{PARAM_B-t_01_01_recovery}
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1:inactivityTimer=1000
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004
${ue_eutra_capabilities}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080
${ue_eutra_capabilities_B_k}
...    SEPARATOR=
...    DE1809E0008206102860E2048A163069022489942A58B983268D9D3CB5F803A7400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000007F
...    FFFFFFC77C0110C8531D0952D8D73E02060A0E12161A1E22262A2E32363A3C149A00000069C0E1B200000000BDD0000000404A9517D0E80800
...    0010400021000043000088000114000230000470000900001240002500004B000098000134000280000510000A400014C0002A0000550000AC
...    00015C0002C0000590000B400016C0002E80005E0000DA0001FC0074E800000007400000003A00000001D00000000E800000007400000003A0
...    0000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A0000
...    0001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074000000028200000C
...    79D000000000000000000000000000000000000000000000000000000000001015C46FF21298061CFFFFFFFFFFFFFFFA15000300452E000040
...    00020961400019E000000C00000040
${ue_eutra_capabilities_B_u}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C6800033C000001800000090800004
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004
@{PARAMS_IN_SWCONFIG}
...    ${MeasTimingConf} = 1
#temporary workaround for LTE4193-B for supporting MeasTimingConf in X2SetupReponse for gNB
${wait_x2_setup}    60s
${wait_report}    12s
${wait_idle}    16s
${wait_detach}    2s
${MeasTimingConf}    0x00130060
*** Test Cases ***
LTE4873-B-i_01_01_Secondary RAT Data Report during X2 HO with EN-DC established
    [Documentation]    This case verifies MeNB sends S1AP about SecondaryRATDataUsageReport towards MME with Secondary RAT Usage Report
    ...    List IE after X2 handover
    [Tags]
    Online parameter change     ${PARAM_B-i_01_01}
    Set UE parameters before ENDC setup    ue_id=1    gnb2_id=3    gnb3_id=4
    Set on sim-gnb sim send secondary rat data report    time=0    status=on    gnb_id=3
    ICS trigger ENDC    ue_id=1
    Trigger X2 handover    ue_id=1    tgt_enb_id=5    tgt_cell_id=51
    release all ues

LTE4873-B-k_01-01 Secondary RAT Data Report to MME during Successful PS-HO to WCDMA with EN_DC established
    [Documentation]    This case verifies Secondary RAT Data Report to MME during Successful PS-HO to WCDMA with EN_DC established
    [Tags]
    Online parameter change     ${PARAM_B-k_01-01}
    Set UE parameters before ENDC setup and for WCDMA capability    ue_id=2    gnb2_id=3    gnb3_id=4
    Set on sim-gnb sim send secondary rat data report    time=0    status=on    gnb_id=3
    ICS trigger ENDC with utran capability    ue_id=2    ue_eutra_capabilities=${ue_eutra_capabilities_B_k}
    Trigger UE PS HO to UTRAN    ue_id=2
    [Teardown]     Restore Env and Capture Logs    ${PARAM_B-k_01-01_recovery}

LTE4873-B-m_01_01 eNB send DVR via E-RAB modification indication to MME during Inter-SgNB Mobility for EN-DC
    [Documentation]    This case verifies Secondary RAT data Report during Inter-SgNB Mobility for EN-DC
    [Tags]
    Online parameter change     ${PARAM_B-m_01_01}
    Set UE parameters before ENDC setup    ue_id=3    gnb2_id=3    gnb3_id=4
    Set on sim-gnb sim send secondary rat data report    time=5000    status=on    gnb_id=3
    Inter Sgnb Mobility    ue_id=3    target_sgnb=4    sgnb_cell_id=41
    [Teardown]     Restore Env and Capture Logs    ${PARAM_B-m_01_01_recovery}

LTE4873-B-n_01-01 VDR will send to MME during reestablishment rejected after SgNB addtion successful
    [Documentation]    This case verifies that Secondary RAT Data Usage Report will send to MME carried on S1AP:UE Context Release Request
    ...    during reestablishment reject after SgNB addtion successful
    [Tags]
    Online parameter change     ${PARAM_B-n_01_01}
    Set UE parameters before ENDC setup    ue_id=4    gnb2_id=3    gnb3_id=4
    Set on sim-gnb sim send secondary rat data report    time=0    status=on    gnb_id=3
    ICS trigger ENDC    ue_id=4
    Trigger RRC Reestablishment Reject After RRC Reconfiguration Complete    ue_id=4

LTE4873-B-o_08_01_US10_case2_sgnbrelease after S1AP-ERAB MODIFICATION INDICATION send out
    [Documentation]    LTE4873-B-o_08_01 DVR send to MME via S1AP-E-RAB MODIFICATION INDICATION when MME initiated UE Context Release
    ...    procedure after S1AP-ERAB MODIFICATION INDICATION send out
    [Tags]
    Online parameter change     ${PARAM_B-o_08_01}
    Set UE parameters before ENDC setup    ue_id=5    gnb2_id=3    gnb3_id=4
    Set on sim-gnb sim send secondary rat data report    time=0    status=on    gnb_id=3
    recover noraml ENDC environemet    gnb_id=3
    ICS trigger ENDC    ue_id=5
    Starting data traffic on SCG split bearer    ue_id=5
    Trigger SCG split to MSG bearer with RLF    ue_id=5
    [Teardown]     Restore Env and Capture Logs    ${PARAM_B-o_08_01_recovery}

LTE4873-B-r_01_01 Support tracing S1AP and X2AP for Secondary RAT Data Usage Report Messages for periodic triggered
    [Documentation]    This case verifies S1AP/X2AP: Secondary RAT Data Usage Report will be traced On NetAct/TraceViewer for event triggered
    [Tags]
    Online parameter change     ${PARAM_B-r_01_01}
    Set UE parameters before ENDC setup    ue_id=6    gnb2_id=3    gnb3_id=4
    Set on sim-gnb sim send secondary rat data report    time=5000    status=on    gnb_id=3
    ICS trigger ENDC    ue_id=6
    Wait for receiving message Secondary RAT Data Volume Report from SgNB
    [Teardown]     Restore Env and Capture Logs    ${PARAM_B-r_01_01_recovery}

LTE4873-B-u_02_01 Multiple SCG split bearers DVRs are forwarding to MME during X2 handover procedure
    [Documentation]    This case verifies Multiple SCG split bearers' DVRs with all of SCG split bearers' date usage are forwarding to MME
    ...    during X2 handover procedure
    [Tags]
    Online parameter change     ${PARAM_B-u_02_01}
    Set UE parameters before ENDC setup    ue_id=7    gnb2_id=3    gnb3_id=4
    Set on sim-gnb sim send secondary rat data report    time=0    status=on    gnb_id=3
    ICS with 4 bearers trigger ENDC    ue_id=7
    Trigger X2 handover with multi bearers        ue_id=7    tgt_enb_id=5    tgt_cell_id=51
    [Teardown]     Restore Env and Capture Logs    ${PARAM_B-u_02_01_recovery}

LTE4873-B-t_01_01_Ue context preemption for UEs and Secondary RAT Data Usage Report with EN-DC established
    [Documentation]    Trigger UE2 preempts UE1 with ENDC , and chek DVR
    [Tags]
    Online parameter change     ${PARAM_B-t_01_01}
    Set UE parameters before ENDC setup    ue_id=8    gnb2_id=3    gnb3_id=4
    Set on sim-gnb sim send secondary rat data report    time=0    status=on    gnb_id=3
    ICS trigger ENDC with establish cause mo_Data    ue_id=8
    Attach UE to preempt    pre_ue_id=8    ue_id=9    bearer_id=1
    [Teardown]     Restore Env and Capture Logs    ${PARAM_B-t_01_01_recovery}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_ABIO    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Perform Steps After Onair
    sleep    ${wait_x2_setup}
    @{LNADJGNB}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.11    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${LNADJGNB}

Modify Yaml
    Add Yaml      EPC/RNC
    ...    - id: 12
    ...    host_enb: 2
    ...    rnc_id: 12
    ...    lac: 124
    ...    plmn: '262:03'
    Update Yaml    EPC/MME_POOL_AREA/1    tac_list: 33,124
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 6, preprovisioned: on, filter: 1, precedence: 1, remote_port: 7070, proto: 17, priority: 13, vulnerability: on, pdn: 1}
    ...     - {qci: 7, preprovisioned: on, filter: 2, precedence: 2, remote_port: 7070, proto: 17, priority: 14, vulnerability: on, pdn: 1}
    ...     - {qci: 9, preprovisioned: on, filter: 3, precedence: 3, remote_port: 7070, proto: 17, priority: 14, vulnerability: on, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/4    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/5    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/6    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/7    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/8    bearer: bearer_set_2
    ${GNB2_CELL1}    catenate    - {id: 31, technology: nr, tac: 33, pci: '0:1', nrci: '0x000031F', nr_arfcn: '507000:531000'}
    ${GNB3_CELL1}    catenate    - {id: 41, technology: nr, tac: 33, pci: '0:2', nrci: '0x0000429', nr_arfcn: '507000:531000'}
    ${rnc_CELL1}    catenate    - {id: 21, technology: utran, rnc: 12, tac: 33, uarfcn: '10663:9713', pci: '7:1', type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 1, rac: 111, earfcn: '1400:19400', eci: '0x0000215', pci_utran: 22}
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.31'
    ...    enb_id: '0x00002'
    ...    cells:
    ...       ${rnc_CELL1}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...    gnb_id: '0x00003'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2_peers: none
    ...    cells:
    ...       ${GNB2_CELL1}
    Add Yaml    BASE_STATIONS
    ...    - id: 4
    ...    gnb_id: '0x00004'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.12
    ...    x2_peers: none
    ...    cells:
    ...       ${GNB3_CELL1}
    Add Yaml    BASE_STATIONS
    ...    - id: 5
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.32
    ...    x2: 10.0.1.32
    ...    cells:
    ...       - {id: 51, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}
    ...       - {id: 52, technology: lte, tac: 33, pci: '3:1', earfcn: '1400:19400', bw: 20}
    ...       - {id: 53, technology: lte, tac: 33, pci: '3:2', earfcn: '1400:19400', bw: 20}

Online parameter change
    [Arguments]    ${PARAM}
    Delta Commission Parameters    ${PARAM}
    Cells Should Be OnAir

Restore Env and Capture Logs
    [Arguments]    ${PARAM}
    Online parameter change    ${PARAM}
    Common Test Teardown And Stop Capture Logs

Set UE parameters before ENDC setup
    [Arguments]    ${ue_id}=1    ${gnb2_id}=3    ${gnb3_id}=4
    Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=${ue_id} type=nr release=15 nr_supported_bands=7
    Execute Egate Command    ue_enb_param id=${ue_id} ue_config_release_r9=rel15
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
	Execute Egate Command    enb_timer T_DC_Overall=5000ms
    execute egate command
    ...    gnb_endc_param id=${gnb2_id} include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0
    execute egate command
    ...    gnb_endc_param id=${gnb3_id} include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0

Set UE parameters before ENDC setup and for WCDMA capability
    [Arguments]    ${ue_id}=1    ${gnb2_id}=3    ${gnb3_id}=4
    Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=${ue_id} type=nr release=15 nr_supported_bands=7
    Execute Egate Command    ue_enb_param id=${ue_id} ue_config_release_r9=rel15
	Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms
    execute egate command
    ...    gnb_endc_param id=${gnb2_id} include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0
    execute egate command
    ...    gnb_endc_param id=${gnb3_id} include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0
    Execute Uex Command    ue_param eutra_interrat_utra_fdd=VII id=${ue_id}

Set on sim-gnb sim send secondary rat data report
    [Arguments]    ${time}=0    ${status}=on    ${gnb_id}=3
    Execute Egate Command    gnb_endc_param send_secondary_rat_data_volume_report=${status}:${time} id=${gnb_id}

ICS trigger ENDC
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}    ${cell_id}=1
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=attach_ENDC_flow    overall_timeout=20
    ${cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${cmd}
    Flow Occurred As Expected    alias=attach_ENDC_flow

ICS trigger ENDC with utran capability
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}    ${cell_id}=1
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=attach_ENDC_flow    overall_timeout=20
    ${cmd}    catenate    ue_attach id=${ue_id} ue_utra_capabilities=123456 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${cmd}
    Flow Occurred As Expected    alias=attach_ENDC_flow

Trigger X2 handover
    [Arguments]    ${ue_id}=1    ${tgt_enb_id}=5    ${tgt_cell_id}=51
    ${SNSstatus}         catenate
    ...    E-RABs-SubjectToStatusTransfer-Item contains (
    ...    iE-Extensions contains (
    ...    ((id eq 151) and
    ...    (COUNTvaluePDCP-SNlength18 contains (pDCP-SNlength18 eq 0))),
    ...    ((id eq 152) and
    ...    (COUNTvaluePDCP-SNlength18 contains (pDCP-SNlength18 eq 0))))
    ...    )
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBModificationRequest (value contains (Cause contains (radioNetwork eq "action-desirable-for-radio-reasons")))
    ...    ENB_1:X2AP_HandoverRequest
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReleaseRequest (value contains (Cause contains (radioNetwork eq "mCG-Mobility")))
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    ENB_1:X2AP_SNStatusTransfer (${SNSstatus})
    ...    MME_1:S1AP_SecondaryRATDataUsageReport (value contains (HandoverFlag eq "handoverPreparation"))
    ...    ENB_1:X2AP_UEContextRelease
    ...    alias=x2_ho_flow    overall_timeout=20
    Execute Egate Command    enb_endc_param id=${tgt_enb_id} keep_endc_on_ho=off    #inform target enbsim NOT to setup endc after handover
    Execute Uex Command    ue_ho id=${ue_id} enb=${tgt_enb_id} cell=${tgt_cell_id}
    Flow Occurred As Expected    alias=x2_ho_flow
    Execute Egate Command    enb_endc_param id=${tgt_enb_id} reset


Trigger UE PS HO to UTRAN
    [Arguments]    ${ue_id}=1
    ${release_info}         catenate
    ...    SecondaryRATUsageReportList contains (
    ...    SecondaryRATUsageReport-Item contains (
    ...    (e-RAB-ID eq 5)
    ...    )
    ...    )
    ${S1AP_release_info}         catenate
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (e-RAB-ID eq 5)
    ...    )
    ...    )
   Expect Message Flow
    ...    MME_1:S1AP_HandoverRequired (value contains (HandoverType eq "ltetoutran"))
    ...    MME_1:S1AP_HandoverRequest (value contains (HandoverType eq "ltetoutran"))
    ...    MME_1:S1AP_HandoverRequestAcknowledge
    ...    MME_1:S1AP_HandoverCommand (value contains (HandoverType eq "ltetoutran"))
    ...    ENB_1:X2AP_SgNBReleaseRequest (value contains (Cause contains (radioNetwork eq "mCG-Mobility")))
    ...    UE_GROUP_${ue_id}:RRC_MobilityFromEUTRACommand (handover contains (targetRAT-Type eq "utra"))
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport (${release_info})
    ...    MME_1:S1AP_SecondaryRATDataUsageReport (${S1AP_release_info})
    ...    ENB_1:X2AP_UEContextRelease
    ...    MME_1:S1AP_UEContextReleaseCommand (value contains (Cause contains (radioNetwork eq "successful-handover")))
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=PSHO_UTRAN_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34
    sleep    2s
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_UTRA srsrp=15 srsrq=15 phycell_id=22 necn0=10 nrscp=85 arfcn=10663
    Flow Occurred As Expected    alias=PSHO_UTRAN_flow

Inter Sgnb Mobility
    [Arguments]    ${ue_id}=1    ${target_sgnb}=4    ${sgnb_cell_id}=41
    ICS trigger ENDC    ${ue_id}
    ${release_info}         catenate
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (secondaryRATType eq "nR")
    ...    ))
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBChangeRequired
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBChangeConfirm
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    MME_1:S1AP_E-RABModificationIndication (${release_info})
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    ENB_1:X2AP_UEContextRelease
    ...    alias=sgnb_change_flow1    overall_timeout=20
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBChangeRequired
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SgNBChangeConfirm
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    MME_1:S1AP_E-RABModificationIndication (${release_info})
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    ENB_1:X2AP_UEContextRelease
    ...    alias=sgnb_change_flow2    overall_timeout=20
    Execute Egate Command    gnb_endc_param id=3 include_candidate_cell_info_list_sn=off
    Execute Egate Command    gnb_endc_param id=4 include_candidate_cell_info_list_sn=off
    Execute Egate Command
    ...    gnb_ue_dc_change ue=${ue_id} gnb=${target_sgnb} target_sgnb_cells=${sgnb_cell_id} cause=off
    ...    pass_regexp=Inter Sgnb Handover is successful
    Verify At Least One Flow Occurs As Expected    sgnb_change_flow1    sgnb_change_flow2

Trigger RRC Reestablishment Reject After RRC Reconfiguration Complete
    [Arguments]    ${ue_id}=1
    ${release_info}         catenate
    ...    Cause contains (
    ...    radioNetwork eq "radio-connection-with-ue-lost"
    ...    ) and
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (secondaryRATType eq "nR")
    ...    ))
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBReleaseRequest (Cause contains (radioNetwork eq "radio-connection-with-UE-lost"))
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    ENB_1:X2AP_UEContextRelease
    ...    MME_1:S1AP_UEContextReleaseRequest (${release_info})
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=RCR_flow    overall_timeout=20
    execute uex command and expect error    ue_rrc_reestablish id=${ue_id} enb=1 cell=1 cause=otherFailure    sErrRachFail
    Flow Occurred As Expected    alias=RCR_flow


recover noraml ENDC environemet
    [Arguments]    ${gnb_id}=3
    Execute Egate Command    link_x2_management_abnormal_cases id=${gnb_id} sgnb_release_rsp=normal_rsp partner=1
    Execute Egate Command    enb_param force_gtpu_error_indication=off id=${gnb_id}

Starting data traffic on SCG split bearer
    [Arguments]    ${ue_id}=1    ${bearer_id}=5
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp bearer=${bearer_id} Mbps=1 trf_id=1


Trigger SCG split to MSG bearer with RLF
    [Arguments]    ${ue_id}=1
    ${release_info}         catenate
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (e-RAB-ID eq 5) and
    ...    (secondaryRATType eq "nR") and
    ...    e-RABUsageReportList contains (id eq 267)
    ...    )
    ...    )
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBReleaseRequired (Cause contains (radioNetwork eq "failure-in-the-radio-interface-procedure"))
    ...    ENB_1:X2AP_SgNBReleaseConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (drb-Identity eq 4))
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    MME_1:S1AP_E-RABModificationIndication (${release_info})
    ...    MME_1:S1AP_UEContextReleaseCommand (Cause contains (nas eq "normal-release"))
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=RLF_sgnb_rel_flow    overall_timeout=20
    sleep    ${wait_idle}
    Execute Egate Command    link_s1_management_abnormal_cases id=1 mme_erab_modification_rsp=ue_ctx_rel
    Execute Egate Command    enb_dc_ue_release by=gnb cause=RN_failure_in_the_radio_interface_procedure ue=${ue_id} bearer=1
    ...    UEContextRelease    timeout=20s
    sleep    ${wait_detach}
    Execute Uex Command    ue_detach id=${ue_id}
    Flow Occurred As Expected    alias=RLF_sgnb_rel_flow
    Execute Egate Command    link_s1_management_abnormal_cases id=1 mme_erab_modification_rsp=normal_rsp

Wait for receiving message Secondary RAT Data Volume Report from SgNB
    Expect Message Flow
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    MME_1:S1AP_SecondaryRATDataUsageReport
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    MME_1:S1AP_SecondaryRATDataUsageReport
    ...    alias=wait_report_flow    overall_timeout=20
    sleep    ${wait_report}
    Flow Occurred As Expected    alias=wait_report_flow

ICS with 4 bearers trigger ENDC
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${multi_bearers}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    ((e-RAB-ID eq 5) and (qCI eq 8)),
    ...    ((e-RAB-ID eq 6) and (qCI eq 6)),
    ...    ((e-RAB-ID eq 7) and (qCI eq 7)),
    ...    ((e-RAB-ID eq 8) and (qCI eq 9))
    ...    )
    ${multi_bearers_addition}    catenate
    ...    E-RABs-ToBeAdded-SgNBAddReqList contains (
    ...    ((e-RAB-ID eq 6) and (qCI eq 6)),
    ...    ((e-RAB-ID eq 7) and (qCI eq 7)),
    ...    ((e-RAB-ID eq 8) and (qCI eq 9))
    ...    )
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${multi_bearers})
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    ENB_1:X2AP_SgNBAdditionRequest (${multi_bearers_addition})
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=attach_4bearers_flow    overall_timeout=20
    ${cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities_B_u} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute Uex Command    ${cmd}
    Flow Occurred As Expected    alias=attach_4bearers_flow

Trigger X2 handover with multi bearers
    [Arguments]    ${ue_id}=1    ${tgt_enb_id}=5    ${tgt_cell_id}=51
    ${multi_bearers}         catenate
    ...    e-RABs-ToBeSetup-List contains (
    ...    ((e-RAB-ID eq 5) and (qCI eq 8)),
    ...    ((e-RAB-ID eq 6) and (qCI eq 6)),
    ...    ((e-RAB-ID eq 7) and (qCI eq 7)),
    ...    ((e-RAB-ID eq 8) and (qCI eq 9))
    ...    )
    ${multi_bearers_release}         catenate
    ...    E-RABs-ToBeReleased-SgNBRelReqList contains (
    ...    (e-RAB-ID eq 6),
    ...    (e-RAB-ID eq 7),
    ...    (e-RAB-ID eq 8)
    ...    )
    ${multi_bearers_report}         catenate
    ...    SecondaryRATDataUsageReportList contains (
    ...    (e-RAB-ID eq 6),
    ...    (e-RAB-ID eq 7),
    ...    (e-RAB-ID eq 8)
    ...    )
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBModificationRequest (value contains (Cause contains (radioNetwork eq "action-desirable-for-radio-reasons")))
    ...    ENB_1:X2AP_SgNBModificationRequestAcknowledge
    ...    ENB_1:X2AP_HandoverRequest (${multi_bearers})
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReleaseRequest (${multi_bearers_release})
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    MME_1:S1AP_SecondaryRATDataUsageReport (${multi_bearers_report})
    ...    ENB_1:X2AP_UEContextRelease
    ...    ENB_1:X2AP_UEContextRelease
    ...    alias=x2_ho_multi_flow    overall_timeout=20
    Execute Egate Command    enb_endc_param id=${tgt_enb_id} keep_endc_on_ho=off    #inform target enbsim NOT to setup endc after handover
    Execute Uex Command    ue_ho id=${ue_id} enb=${tgt_enb_id} cell=${tgt_cell_id}
    Flow Occurred As Expected    alias=x2_ho_multi_flow
    Execute Egate Command    enb_endc_param id=${tgt_enb_id} reset

ICS trigger ENDC with establish cause mo_Data
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}    ${cell_id}=1
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=attach_ENDC_flow    overall_timeout=20
    ${cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id} establishment_cause=mo_Data
    Execute Uex Command    ${cmd}
    Flow Occurred As Expected    alias=attach_ENDC_flow

Attach UE to preempt
    [Arguments]    ${pre_ue_id}=1    ${ue_id}=1    ${bearer_id}=1    ${cell_id}=1
    ${release_info}         catenate
    ...    E-RABList contains (
    ...    E-RABItem contains (
    ...    cause contains (radioNetwork eq "release-due-to-pre-emption")
    ...    )) and
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (secondaryRATType eq "nR")
    ...    ))
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBReleaseRequest (Cause contains (radioNetwork eq "unspecified"))
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    ENB_1:X2AP_SecondaryRATDataUsageReport
    ...    MME_1:S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "release-due-to-pre-emption"))
    ...    MME_1:S1AP_UEContextReleaseCommand
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=preemption_sgnb_rel_flow    overall_timeout=20
    Execute Egate Command    bearer_mod ue=${pre_ue_id} id=${bearer_id} priority=14 preemption=1 vulnerability=1    E-RABModifyResponse
    ...    timeout=20s
    Set UE parameters before ENDC setup    ue_id=${ue_id}
    ${cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id} establishment_cause=mo_Data
    Execute Uex Command    ${cmd}
    Flow Occurred As Expected    alias=preemption_sgnb_rel_flow


