*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-DevHZ5_SG1    owner-qi.zheng,ying.shang    release-SBTS22R1
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{others}
...    @{LTE4088}
...    @{LTE4193}
...    @{LTE5411}
...    @{CB007334}
...    @{inactive_timer}
...    @{LTE5226}
...    @{LTE5003}
...    @{LTE4549}
...    @{CA}
...    @{LNADJGNB}
${ue_nr_capabilities}
...    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C28D010CA1A044083A0C30260220B6480A01000C0
...    39F2107800412070701101E407800040400009B89BC09024000000120000040900000400A00C0300C0300D80280201004011802803010040
...    1004600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C00800011041082000064
...    104208000210410809A55334A262B9515DA8AEC4
${ue_eutra_nr_capabilities}
...    SEPARATOR=
...    C10060B71B02004040C1803A020000000FD00000000081B8981002060E2680000103F400000000206E360400818103071340000101FA0000
...    000010370B0200E8080000303F400000000206E26040081838040000100FD0000000008100800803004809B0008041800040200010080004
...    02020040088000201000080404008011800040200010080004020200400840002010100200440001008000402020040080
@{LTE4088}
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS-1:tLteNrDualConnectPrep=10000
...    LNBTS-1:pdcpProf1001:pdcpProfileId=1001
...    LNBTS-1:pdcpProf1001:snSizeDl=18bit
...    LNBTS-1:pdcpProf1001:snSizeUl=18bit
...    LNBTS-1:pdcpProf1001:statusRepReq=0
...    LNBTS-1:pdcpProf1001:tDiscard=300ms
...    LNBTS-1:nrRestrictionOverride=disabled
@{LTE4193}
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNBTS-1/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS-1/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS-1/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS-1/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS-1/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=120kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-1/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS-1/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS-1/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS-1/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
@{others}
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:caSchedFairFact=0
...    LNBTS-1:mcc=262
...    LNBTS-1:mnc=3
...    LNBTS-1:mncLength=2
...    LNBTS-1/CAGENB-0:caClusterEnbList:lnBtsId=100000
...    LNBTS-1/CAGENB-0:caClusterEnbList:numSrioLinks=0
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1:harqMaxTrVoLteDl=4
...    LNCEL-2:harqMaxTrVoLteDl=4
...    LNCEL-3:harqMaxTrVoLteDl=4
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-2/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-3/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-1:tac=33
...    LNCEL-2:tac=33
...    LNCEL-3:tac=33
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    delete:LNCEL-1/MBSFNCEL-0
...    LNBTS-1:actAmbrModCaTrigger=false
@{LTE5411}
...    LNBTS-1:actLteNrFastNbrRelAdd=true
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelAddHyst=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelAddThresh=5
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
@{CB007334}
...    LNBTS-1:actUeBasedAnrNr=true
...    LNBTS-1/ANR-0:actAutoNrNeighRemoval=true
...    LNBTS-1/ANR-0:anrNrParamList:anrDefRelDcAllowed=true|paramPlmnId=0
...    LNBTS-1/ANR-0:anrNrParamList:carrierFreqNrCell=${NRARFCN2036667}|paramPlmnId=0
...    LNBTS-1/ANR-0:anrNrParamList:gNBIdLength=22|paramPlmnId=0
...    LNBTS-1/ANR-0:anrNrParamList:frqNrCarSelect=All|paramPlmnId=0
...    LNBTS-1/ANR-0:anrNrParamList:paramMeasConfId=1|paramPlmnId=0
...    LNBTS-1/ANR-0:anrNrMeasConfList:thresholdNrRsrp=6|paramMeasConfId=1
...    LNBTS-1/ANR-0:anrNrMeasConfList:thresholdNrRsrq=-80|paramMeasConfId=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:nrPciNbrRelRemThresh=50000
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS-1/ANR-0:anrNrNbrRelRemGuardTime=3
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mcc=262|paramPlmnId=1
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mnc=3|paramPlmnId=1
...    LNBTS-1/ANR-0:anrNrParamPlmnList:mncLength=2|paramPlmnId=1
@{LNADJGNB}
...    LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
@{LNRELGNBCELL}
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{inactive_timer}
...    LNCEL-1:inactivityTimer=6000
...    LNCEL-1:inactivityTimerPubSafety=6000
...    LNBTS-1/ANR-0:anrNrInactivityTimer=5
...    LNBTS-1/ANR-0:anrNrCoverageConfirmTimer=2500
...    LNBTS-1/ANR-0:anrIfTRSC=8000
...    LNBTS-1/ANR-0:anrRttTRSCFS=8000ms
${ue_eutra_capabilities}
...    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C10820803
...    04218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B08200828410518208384100414208206
...    1040105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0
...    B82E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71
...    E00020406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C2609A143C037FC00000A000000610
...    008800142001800808
...    #no UTRA FGI bit22
@{LTE5226}
...    LNBTS-1/NRMEASDPR-0:mrWaitTimer=2000
@{LTE5003}
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNCEL:actFlowCtrlEnh=true
@{LTE4549}
...    LNBTS-1:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS-1:enableBwCombCheck=true
...    LNBTS-1/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS-1/NRDCDPR-0:allowedBcSelectMethod=no preference
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=7
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=7
...    LNCEL:caPoolId=1
...    LNCEL:maxNumScells=1
...    LNBTS-1:actFlexScellSelect=true
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1800
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19800
...    LNCEL:actFlowCtrlEnh=true
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.31
...    delete:LNBTS-1/LNADJ-255
...    LNCEL-1/CAREL-1:scellPrio=3
...    LNBTS-1:actFlexCaMgmt=true
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    delete:LNCEL-2/CAREL-1:beamformingInScellAllowed
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=10
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=10
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL-2/CAREL-1:lcrId=1
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-2/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-2/CAREL-1:scellPrio=3
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-3/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-1:scellPrio=3
@{clean-up}
...    delete:LNCEL-1/LNRELGNBCELL-255
...    delete:LNCEL-1/LNRELGNBCELL-254
...    delete:LNCEL-1/LNRELGNBCELL-253
...    delete:LNCEL-1/LNRELGNBCELL-1
...    delete:LNCEL-1/LNRELGNBCELL-2
...    delete:LNCEL-1/LNRELGNBCELL-3
...    delete:LNBTS-1/LNADJGNB-127
...    delete:LNBTS-1/LNADJGNB-126
...    delete:LNBTS-1/LNADJGNB-125
...    delete:LNBTS-1/LNADJGNB-3
...    LNBTS-1:actUeBasedAnrNr=false
...    LNBTS-1/ANR-0:actAutoNrNeighRemoval=false
...    LNBTS-1:actLteNrFastNbrRelAdd=false
@{X2shouldup}
...    LNBTS-1/LNADJGNB-1:x2ToGnbLinkStatus=available
@{PARAMS_IN_EMIL}
...    0x400e
...    0x7509
${nci-115970}     000000000000000000100000010100000010
${B1NR_REPORT_UNKN_PCI}    LNCEL-1:M8080C142
${NR_REPORT_CGI_ATT}    LNCEL-1:M8080C143
${NR_REPORT_CGI_SUCC}    LNCEL-1:M8080C144
${NR_REPORT_CGI_INCOMPL}    LNCEL-1:M8080C145
@{pm_counters_UNKN0_ATT0_SUCC0_INCOMPL0}
...    ${B1NR_REPORT_UNKN_PCI}=0
...    ${NR_REPORT_CGI_ATT}=0
...    ${NR_REPORT_CGI_SUCC}=0
...    ${NR_REPORT_CGI_INCOMPL}=0
@{pm_counters_UNKN5_ATT0_SUCC0_INCOMPL0}
...    ${B1NR_REPORT_UNKN_PCI}=5
...    ${NR_REPORT_CGI_ATT}=0
...    ${NR_REPORT_CGI_SUCC}=0
...    ${NR_REPORT_CGI_INCOMPL}=0
@{pm_counters_UNKN0_ATT1_SUCC1_INCOMPL0}
...    ${B1NR_REPORT_UNKN_PCI}=0
...    ${NR_REPORT_CGI_ATT}=1
...    ${NR_REPORT_CGI_SUCC}=1
...    ${NR_REPORT_CGI_INCOMPL}=0
@{pm_counters_UNKN0_ATT1_SUCC0_INCOMPL1}
...    ${B1NR_REPORT_UNKN_PCI}=0
...    ${NR_REPORT_CGI_ATT}=1
...    ${NR_REPORT_CGI_SUCC}=0
...    ${NR_REPORT_CGI_INCOMPL}=1

${gnb7_cell1}    SEPARATOR=
    ...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes,
    ...    nr_scs: 120kHz, bs_channel_bandwidth: 50MHz}

${gnb8_cell2}    SEPARATOR=
    ...    {id: 82, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes,
    ...    nr_scs: 120kHz, bs_channel_bandwidth: 50MHz}
${gnb8_cell3}    SEPARATOR=
    ...    {id: 83, technology: nr , tac: 33, pci: '1:0', nrci: '0x0000503', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes,
    ...    nr_scs: 120kHz, bs_channel_bandwidth: 50MHz}
${gnb8_cell4}    SEPARATOR=
    ...    {id: 84, technology: nr , tac: 33, pci: '1:1', nrci: '0x0000504', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes,
    ...    nr_scs: 120kHz, bs_channel_bandwidth: 50MHz}
${gnb8_cell5}    SEPARATOR=
    ...    {id: 85, technology: nr , tac: 33, pci: '1:2', nrci: '0x0000505', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes,
    ...    nr_scs: 120kHz, bs_channel_bandwidth: 50MHz}
${gnb8_cell6}    SEPARATOR=
    ...    {id: 86, technology: nr , tac: 33, pci: '2:0', nrci: '0x0000506', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes,
    ...    nr_scs: 120kHz, bs_channel_bandwidth: 50MHz}
${gnb8_cell7}    SEPARATOR=
    ...    {id: 87, technology: nr , tac: 33, pci: '2:1', nrci: '0x0000507', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes,
    ...    nr_scs: 120kHz, bs_channel_bandwidth: 50MHz}
${gnb8_cell8}    SEPARATOR=
    ...    {id: 88, technology: nr , tac: 33, pci: '2:2', nrci: '0x0000508', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', tdd_cell: yes,
    ...    nr_scs: 120kHz, bs_channel_bandwidth: 50MHz}

*** Test Cases ***
CB007334-SR-A-m_ET_01_01_PM counter with mult pair and add MOC after verified and reportCGI with or without vaild value
    [Documentation]
    ...    phase1, checks report B1 pci1~5 not reach nrPciNbrRelAddThresh(value: 5)+1, B1NR_REPORT_UNKN_PCI=0
    ...    phase2, checks report B1 pci1~5 reach nrPciNbrRelAddThresh+1, B1NR_REPORT_UNKN_PCI=5, even new LNRELGNBCELL-255 115969
    ...    created by LTE5411, B1NR_REPORT_UNKN_PCI not duplicate calculated.
    ...    phase3, checks report pci2 one time makes pci1, pci3~5 pci counter value below nrPciNbrRelAddThresh+1, then report
    ...    pci1~5 one time to make pci1,3~5 counter value reach nrPciNbrRelAddThresh+1, B1NR_REPORT_UNKN_PCI no increase.
    ...    phase4, checks reestablish UE and new MOC LNRELGNBCELL 115970 created 115969 deleted,B1NR_REPORT_UNKN_PCI no increase,
    ...    NR_REPORT_CGI_ATT and NR_REPORT_CGI_SUCC is 1.
    ...    phase5, checks new MOC LNRELGNBCELL 115969 created, B1NR_REPORT_UNKN_PCI no increase(due to its pair is verified in
    ...    phase4)
    ...    phase6 checks report pci2 with default CGI report nosib-r15, NR_REPORT_CGI_ATT and NR_REPORT_CGI_INCOMPL is 1
    [Tags]
    block unblock cell1
    clean up moc and tobeverified list
    attch_ue1_report_B1_pci1topci5_UNKN0_ATT0_SUCC0_INCOMPL0
    report_B1_pci1topci5_5times_counter_UNKN5_ATT0_SUCC0_INCOMPL0
    report_B1_pci2_1time_then_pci1topci5_UNKN0_ATT0_SUCC0_INCOMPL0
    reestablish_ue1_report_B1_pci1_UNKN0_ATT1_SUCC1_INCOMPL0
    create_MOC_LNRELGNBCELL115969_UNKN0_ATT0_SUCC0_INCOMPL0
    attch_ue2_report_B1_pci2_nosib_for_reportCGI_UNKN0_ATT1_SUCC0_INCOMPL1

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Set UE parameters about ENDC
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=3    id_type=cus

block unblock cell1
    block cell1
    unblock cell1
    cells should be onair

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...      - id: 7
    ...        gnb_id: '0x00007'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.11
    ...        x2: 10.0.1.11
    ...        cells:
    ...          - ${gnb7_cell1}
    Add Yaml    BASE_STATIONS
    ...      - id: 8
    ...        gnb_id: '0x00008'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.12
    ...        x2: 10.0.1.12
    ...        cells:
    ...          - ${gnb8_cell2}
    ...          - ${gnb8_cell3}
    ...          - ${gnb8_cell4}
    ...          - ${gnb8_cell5}
    ...          - ${gnb8_cell6}
    ...          - ${gnb8_cell7}
    ...          - ${gnb8_cell8}
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      x2: 10.0.1.31
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '1:1', earfcn: '1400:19400', bw: 20, eci: '0x0000201', status: enabled}

Set UE parameters about ENDC
    Execute Uex Command    ue_param id=1-20 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1-20 nr_supported_bands=258,260
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=4:1

UE attach to cell1
    [Arguments]    ${ue_id}=1
    ${RRC_INFO}    catenate    measObjectToAddModList contains (measObjectNR-r15 contains (carrierFreq-r15 eq 2036672))
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${RRC_INFO})
    ...    alias=UE_Attach    overall_timeout=20
    ${command}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    Execute Uex Command    ${command}
    Flow Occurred As Expected    alias=UE_Attach

clean up moc and tobeverified list
    Delta Commission Parameters    ${clean-up}
    Delta Commission Parameters    ${CB007334}
    Delta Commission Parameters    LNBTS-1:actLteNrFastNbrRelAdd=true
    Object Should Exist    ${X2shouldup}

report NR B1 PCI1 to PCI5
    [Arguments]    ${ue_id}=1
    ${result}    catenate    measResults contains (measId eq 17) and
    ...    measResultNeighCellListNR-r15 contains ((pci-r15 eq 1), (pci-r15 eq 2), (pci-r15 eq 3), (pci-r15 eq 4), (pci-r15 eq 5))
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport(${result})
    ...    alias=UE_send_B1_5pcis    overall_timeout=20
    ${cmd}    catenate    ue_measurement_send id=${ue_id} event=B1_NR
    ...    phycell_id=1 narfcn=2036672 nrsrp=113
    ...    phycell_id=2 narfcn=2036672 nrsrp=114
    ...    phycell_id=3 narfcn=2036672 nrsrp=115
    ...    phycell_id=4 narfcn=2036672 nrsrp=116
    ...    phycell_id=5 narfcn=2036672 nrsrp=117
    Execute Uex Command    ${cmd}
    Flow Occurred As Expected    alias=UE_send_B1_5pcis

report NR B1 PCI1 to PCI5 5 times
    [Arguments]    ${ue_id}=1    ${expect_output}=rsrpResult-r15 120    ${measid}=17    ${pci}=1    ${num}=2    ${temp}=1
    FOR    ${temp}    IN RANGE    1    6
        report NR B1 PCI1 to PCI5    ue_id=${ue_id}
    END

send B1-NR to cell
    [Arguments]    ${ue_id}=1    ${pci}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport(measResults contains (measId eq 17))
    ...    alias=UE_send_B1_1pci    overall_timeout=20
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport(measResultNeighCellListNR-r15 contains (pci-r15 eq 3))
    ...    alias=B1_contain_1pci    overall_timeout=20
    Execute Uex Command    ue_param id=${ue_id} reset
    ${cmd}    catenate    ue_measurement_send id=${ue_id} event=B1_NR narfcn=2036672 srsrp=79 phycell_id=${pci} nrsrp=120 amount=1
    ...    cgi_plmn_group cgi=262:03|0x1C502 rac=125 tac=33
    ...    cgi_plmn_group cgi=253:560,253:561,253:562|0x78D1B1AB rac=221 tac=491532
    Execute Uex Command    ${cmd}
    Flow Occurred As Expected    alias=UE_send_B1_1pci
    Flow Not Occurred For Message    alias=B1_contain_1pci

send B1-NR to cell and config CGI with noSib1
    [Arguments]    ${ue_id}=1    ${pci}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport(measResults contains (measId eq 17))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (purpose eq "reportCGI"))
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport(measResultNeighCellListNR-r15 contains (cgi-Info-r15 contains (noSIB1-r15 is present)))
    ...    alias=UE_send_B1_withnosib1    overall_timeout=20
    ${cmd}    catenate    ue_measurement_send id=${ue_id} event=B1_NR narfcn=2036672 srsrp=97 srsrq=34 phycell_id=${pci}
    ...    nrsrp=127 nrsrq=127 nsinr=127 nr_cgi_nosib1=0:0
    Execute Uex Command    ${cmd}
    Flow Occurred As Expected    alias=UE_send_B1_withnosib1

UE trigger reestablish To eNB1 Cell1
    [Arguments]    ${ue_id}=1
    ${expect}    catenate    measIdToRemoveList contains (1,2,3,31,32) and measIdToAddModList contains (measId eq 17)
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${expect})
    ...    alias=UE_reestablish    overall_timeout=20
    Execute Uex Command    ue_rrc_reestablish id=1 enb=1 cell=1 cause=otherFailure
    Flow Occurred As Expected    alias=UE_reestablish

attch_ue1_report_B1_pci1topci5_UNKN0_ATT0_SUCC0_INCOMPL0
    UE attach to cell1    ue_id=1    #no nr anr timer configured
    Start Rtpm Counter    tag=phase1
    report NR B1 PCI1 to PCI5
    Check Rtpm Counters    ${pm_counters_UNKN0_ATT0_SUCC0_INCOMPL0}    tag=phase1

report_B1_pci1topci5_5times_counter_UNKN5_ATT0_SUCC0_INCOMPL0
    Start Rtpm Counter    tag=phase2
    report NR B1 PCI1 to PCI5 5 times
    sleep    1s    115969 created by LTE5411
    Object Should Exist    LNCEL-1/LNRELGNBCELL-255:nrCellId=115969
    object should not exist    LNCEL-1/LNRELGNBCELL-254:nrCellId=115970
    Check Rtpm Counters    ${pm_counters_UNKN5_ATT0_SUCC0_INCOMPL0}    tag=phase2

report_B1_pci2_1time_then_pci1topci5_UNKN0_ATT0_SUCC0_INCOMPL0
    Start Rtpm Counter    tag=phase3
    send B1-NR to cell    ue_id=1    pci=2
    report NR B1 PCI1 to PCI5
    Check Rtpm Counters    ${pm_counters_UNKN0_ATT0_SUCC0_INCOMPL0}    tag=phase3

reestablish_ue1_report_B1_pci1_UNKN0_ATT1_SUCC1_INCOMPL0
    Start Rtpm Counter    tag=phase4
    UE trigger reestablish To eNB1 Cell1    ue_id=1
    send B1-NR to cell   ue_id=1    pci=1
    sleep    5s    wait anrNrInactivityTimer timeout
    Object Should Exist    LNCEL-1/LNRELGNBCELL-254:nrCellId=115970
    Object Should Not Exist    LNCEL-1/LNRELGNBCELL-255:nrCellId=115969
    Check Rtpm Counters    ${pm_counters_UNKN0_ATT1_SUCC1_INCOMPL0}    tag=phase4

create_MOC_LNRELGNBCELL115969_UNKN0_ATT0_SUCC0_INCOMPL0
    Start Rtpm Counter    tag=phase5
    Delta Commission Parameters    ${LNRELGNBCELL}
    Check Rtpm Counters    ${pm_counters_UNKN0_ATT0_SUCC0_INCOMPL0}    tag=phase5

attch_ue2_report_B1_pci2_nosib_for_reportCGI_UNKN0_ATT1_SUCC0_INCOMPL1
    Start Rtpm Counter    tag=phase6
    UE attach to cell1    ue_id=2
    send B1-NR to cell and config CGI with noSib1   ue_id=2    pci=2
    sleep    5s    wait anrNrInactivityTimer timeout
    Check Rtpm Counters    ${pm_counters_UNKN0_ATT1_SUCC0_INCOMPL1}    tag=phase6
