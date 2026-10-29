*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Case setup
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS24R1    team-CN3ET    owner-carol.an
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS:actCellTrace=true
...    LNBTS:actMDTCellTrace=true
...    LNBTS:actInterFreqMDTCellTrace=true
...    @{CB010266}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{HO_para}
...    @{LTE4281_and_LTE5438}
...    @{NRDCDPR_for_band78_and_band258}
...    @{immedMDTControl}
...    @{periodicUeMeas}
...    @{eutranTraceid}
...    @{MTRACE}
...    @{CTRLTS}
...    @{LTRACE}
...    @{LTE4804}
...    @{Enable_Dynamic_EN-DC}
...    @{LTE5510}
...    @{interANDintraMDT}

@{PARAMS_IN_EMIL}
...    0x753A
...    0x37B7
...    0x3809
...    0x37B8
...    0x37B9
...    0x380A
...    0x37C8

@{LTE5510}
...    LNBTS:actStepAddBearENDC=true
...    LNBTS:actMultiSCGSplit=true

@{CB010266}
...    LNCEL:actEndcIntraFreqMdt=true

@{CB010266_disable}
...    LNCEL:actEndcIntraFreqMdt=false
@{LTE4281_and_LTE5438}
...    LNBTS:actHoWoSnChg=intraEnbAndX2HoEnabled

@{CTRLTS}
...    LNBTS-1/CTRLTS-1:extTraceReporting:extCellTraceRep=true
...    LNBTS-1/CTRLTS-1:extTraceReporting:extUeTraceRep=true
...    LNBTS-1/CTRLTS-1:traceRepMode:cellTraceRepMode=Online
...    LNBTS-1/CTRLTS-1:traceRepMode:ueTraceRepMode=Online
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedPortNum=49150
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEId=3
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEIP=0.0.0.1
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEmcc=262
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEmnc=3
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEmncLen=2
...    LNBTS-1/CTRLTS-1:vendorSpecTracing:taTracing=false
...    LNBTS-1/CTRLTS-1:maxUeTraceSessions=60
...    LNBTS-1/CTRLTS-1:netActIpAddr=1.1.1.1
...    LNBTS-1/CTRLTS-1:omsTracePortNum=49392
...    LNBTS-1/CTRLTS-1:subscriberMDTObtainLocation=false
...    LNBTS-1/CTRLTS-1:tceTracePortNum=49150
@{LTRACE}
...    LTRACE-1:enableLoggedMdtTRSStartStopInd=false
...    LTRACE-1:loggedCellConf:lcrId=1
...    LTRACE-1:loggedCellConf:mode=configureAndRetrieveDataFromUEs
...    LTRACE-1:loggedMDTConf:anonymizationMDTdata=No identity
...    LTRACE-1:loggedMDTConf:forceUEconsent=false
...    LTRACE-1:loggedMDTConf:loggedTCEId=2
...    LTRACE-1:loggedMDTConf:loggingDuration=120
...    LTRACE-1:loggedMDTConf:loggingInterval=20480
...    LTRACE-1:loggedMDTConf:selectOnlyStandaloneGNSSUes=true
...    LTRACE-1:plmnPerTAlist:mdtperTAmcc=3
...    LTRACE-1:plmnPerTAlist:mdtperTAmnc=99
...    LTRACE-1:plmnPerTAlist:mdtPerTAmncLen=3
...    LTRACE-1:traceReference:traceId=3
...    LTRACE-1:traceReference:traceReferenceMcc=262
...    LTRACE-1:traceReference:traceReferenceMnc=3
...    LTRACE-1:traceReference:traceReferenceMncLen=2

@{immedMDTControl}
...    MTRACE-1:immedMDTControl:immedMDTAnonymization=IMEI-TAC
...    MTRACE-1:immedMDTControl:immedMDTForceUEConsent=false
...    MTRACE-1:immedMDTControl:immedMDTObtainLocation=false
...    MTRACE-1:immedMDTControl:immedMDTPosMethod=None
...    MTRACE-1:immedMDTControl:immedMDTSelectOnlyGNSSUes=false
...    MTRACE-1:immedMDTControl:cellMaxActiveMDTUEsTraced=20
...    MTRACE-1:immedMDTControl:iFMDTPercentage=50
...    MTRACE-1:immedMDTControl:maxMDTFreqLayers=10
...    MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=1500
...    MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=1600
...    MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=1400

@{periodicUeMeas}
...    MTRACE-1:periodicUeMeas:reportAmount=8
...    MTRACE-1:periodicUeMeas:reportInterval=5120ms

@{periodicUeMeas}
...    MTRACE-1:periodicUeMeas:reportAmount=8
...    MTRACE-1:periodicUeMeas:reportInterval=5120ms
@{eutranTraceid}
...    MTRACE-1:eutranTraceId:eutranTraceIdMcc=262
...    MTRACE-1:eutranTraceId:eutranTraceIdMnc=3
...    MTRACE-1:eutranTraceId:eutranTraceIdMncLen=2
...    MTRACE-1:eutranTraceId:traceId=1
...    MTRACE-1:eutranTraceId:trcRecSessionRef=1

@{MTRACE}
...    MTRACE-1:lcrId=1
...    MTRACE-1:jobType=ImmediateMDTAndTrace
...    MTRACE-1:cellMaxActiveUEsTraced=20
...    MTRACE-1:tceIpAddress=${TCE_IP}
...    MTRACE-1:tceCellTracePortNum=${TCE_PORT}
...    MTRACE-1:traceRrcSetting=All
...    MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=1400
...    MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=1425
...    MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=1500
...    MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=1600

@{HO_para}
...    LNBTS:actIfHo=enabled
...    LNBTS/MODPR-0:freqLayListLte=1400,1500,1600
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=1500
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw100
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-2/LNHOIF-2:eutraCarrierInfo=1600
...    LNCEL-2/LNHOIF-2:measurementBandwidth=mbw100
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-2:ecgiLcrId=51
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-4:ecgiAdjEnbId=3
...    LNCEL-1/LNREL-4:ecgiLcrId=31
...    LNCEL-1/LNREL-4:removeAllowed=false
...    LNCEL-1/LNREL-4:handoverAllowed=allowed
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-3:ecgiLcrId=3
...    LNCEL-1/LNREL-3:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-3:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-3:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-3:removeAllowed=false
...    LNCEL-1/LNREL-3:handoverAllowed=allowed
...    LNCEL-2/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-1:ecgiLcrId=1
...    LNCEL-2/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNREL-1:removeAllowed=false
...    LNCEL-2/LNREL-1:handoverAllowed=allowed
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=2
...    LNCEL-2/LNREL-2:ecgiLcrId=51
...    LNCEL-2/LNREL-2:removeAllowed=false
...    LNCEL-2/LNREL-2:handoverAllowed=allowed
...    LNCEL-2/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-3:ecgiLcrId=3
...    LNCEL-2/LNREL-3:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-3:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-3:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNREL-3:removeAllowed=false
...    LNCEL-2/LNREL-3:handoverAllowed=allowed

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19400

@{x2link}
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.41
...    LNCEL/LNRELGNBCELL-0:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-0:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-0:nrCellId=115969
...    LNCEL/LNRELGNBCELL-0:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-0:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-0:nrCgiPlmnId:mncLength=2
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115970
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

@{NRDCDPR_for_band78_and_band258}
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN2036667}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrCarPrio=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=120kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=629984    #${GSCN22325}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=3
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1

@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:nrRestrictionOverride=disabled
...    LNCEL:defaultLnRelGnbCellId=0
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS:tLteNrDualConnectPrep=5000
...    LNBTS:actTransmittedBelowGap=true
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab9:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true

@{LTE4804}
...    LNBTS:actRCREnDc=RCR-servingCell

${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C108208030
...    4218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420820610
...    40105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E000
...    20406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C2609A143C037FC00000A00000061000880014207F80226A02
# above support both 7334 NRANR and 7742 HO to 5GSA

${ue_nr_capabilities}    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C28D010CA1A044083A0C30260220B6480A01000C039
...    F2107800412070701101E407800040400009B89BC09024000000120000040900000400A00C0300C0300D802802010040118028030100401004
...    600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C00800011041082000064104208
...    000210410809A55334A262B9515DA8AEC4
${ue_eutra_nr_capabilities}    SEPARATOR=
...    C10060B71B02004040C1803A020000000FD00000000081B8981002020E2680000103F400000000206E360400818103071340000101FA0000000010370B0200E8080000
...    303F400000000206E26040081838040000100FD0000000008100800803004809B0008041800040200010080004020200400880002010000804040080118000
...    40200010080004020200400840002010100200440001008000402020040080

${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell3}    SEPARATOR=
...    {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x503', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell4}    SEPARATOR=
...    {id: 74, technology: nr , tac: 33, pci: '1:1', nrci: '0x504', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}', 
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

${gnb7_cell5}    SEPARATOR=
...    {id: 75, technology: nr , tac: 33, pci: '1:2', nrci: '0x01F', nr_arfcn: '${NRARFCN2036667}:${NRARFCN2036667}',
...    meas_timing_carrier_freq: ${NRARFCN2036667}, ssb_subcarrier_spacing: kHz120, ssb_mtc_periodicity_and_offset: 'sf5:0', 
...    ssb_mtc_duration: 'sf1', ss_rssi_meas_slots: 1000000000, ss_rssi_end_symbol: 2}

@{periodicUeMeas}
...    MTRACE-1:periodicUeMeas:reportAmount=16
...    MTRACE-1:periodicUeMeas:reportInterval=5120ms

@{Enable_blind_EN-DC}
...    LNBTS:actDynTrigLteNrDualConnectivity=false

@{Enable_Dynamic_EN-DC}
...    LNBTS:actDynTrigLteNrDualConnectivity=true

@{enableCB0010266_disableLTE4088}
...    LNBTS/LNCEL:actEndcIntraFreqMdt=true
...    LNBTS:actLteNrDualConnectivity=false
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNBTS:actMultiSCGSplit=false
...    LNBTS:actHoWoSnChg=disabled
...    LNBTS:actRCREnDc=disabled
...    LNBTS:actStepAddBearENDC=false

@{MaxActiveMDTUEs1_enableLTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    @{newMTRACE_2_c6_cellMaxActiveMDTUEsTraced1}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:actMultiSCGSplit=true
...    LNBTS:actHoWoSnChg=intraEnbAndX2HoEnabled
...    LNBTS:actRCREnDc=RCR-servingCell
...    LNBTS:actStepAddBearENDC=true

@{MaxActiveMDTUEs2_enableBlindENDC}
...    @{Enable_blind_EN-DC}
...    @{newMTRACE_2_c6_cellMaxActiveMDTUEsTraced2}

@{interANDintraMDT}
...    MTRACE-1:immedMDTControl:iFMDTPercentage=50
...    MTRACE-1:immedMDTControl:maxMDTFreqLayers=10

@{restore_CASE6}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:actMultiSCGSplit=true
...    LNBTS:actHoWoSnChg=intraEnbAndX2HoEnabled
...    LNBTS:actRCREnDc=RCR-servingCell
...    LNBTS:actStepAddBearENDC=true

@{restore_MTRACE1}
...    delete:MTRACE-2
...    delete:MTRACE-3
...    MTRACE-1:lcrId=1
...    MTRACE-1:jobType=ImmediateMDTAndTrace
...    MTRACE-1:cellMaxActiveUEsTraced=20
...    MTRACE-1:tceIpAddress=${TCE_IP}
...    MTRACE-1:tceCellTracePortNum=${TCE_PORT}
...    MTRACE-1:traceRrcSetting=All
...    MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=1400
...    MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=1425
...    MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=1500
...    MTRACE-1:iFMDTList:measBW=mbw100|iFFreqEARFCN=1600
...    MTRACE-1:periodicUeMeas:reportAmount=8
...    MTRACE-1:periodicUeMeas:reportInterval=5120ms
...    MTRACE-1:eutranTraceId:eutranTraceIdMcc=262
...    MTRACE-1:eutranTraceId:eutranTraceIdMnc=3
...    MTRACE-1:eutranTraceId:eutranTraceIdMncLen=2
...    MTRACE-1:eutranTraceId:traceId=1
...    MTRACE-1:eutranTraceId:trcRecSessionRef=1
...    MTRACE-1:immedMDTControl:immedMDTAnonymization=IMEI-TAC
...    MTRACE-1:immedMDTControl:immedMDTForceUEConsent=false
...    MTRACE-1:immedMDTControl:immedMDTObtainLocation=false
...    MTRACE-1:immedMDTControl:immedMDTPosMethod=None
...    MTRACE-1:immedMDTControl:immedMDTSelectOnlyGNSSUes=false
...    MTRACE-1:immedMDTControl:cellMaxActiveMDTUEsTraced=20
...    MTRACE-1:immedMDTControl:iFMDTPercentage=50
...    MTRACE-1:immedMDTControl:maxMDTFreqLayers=10

@{newMTRACE_2_c6_cellMaxActiveMDTUEsTraced1}
...    delete:MTRACE-1
...    MTRACE-2:lcrId=1
...    MTRACE-2:jobType=ImmediateMDTAndTrace
...    MTRACE-2:cellMaxActiveUEsTraced=20
...    MTRACE-2:tceIpAddress=${TCE_IP}
...    MTRACE-2:tceCellTracePortNum=${TCE_PORT}
...    MTRACE-2:traceRrcSetting=All
...    MTRACE-2:iFMDTList:measBW=mbw100|iFFreqEARFCN=1400
...    MTRACE-2:iFMDTList:measBW=mbw100|iFFreqEARFCN=1425
...    MTRACE-2:iFMDTList:measBW=mbw100|iFFreqEARFCN=1500
...    MTRACE-2:iFMDTList:measBW=mbw100|iFFreqEARFCN=1600
...    MTRACE-2:periodicUeMeas:reportAmount=8
...    MTRACE-2:periodicUeMeas:reportInterval=5120ms
...    MTRACE-2:eutranTraceId:eutranTraceIdMcc=262
...    MTRACE-2:eutranTraceId:eutranTraceIdMnc=3
...    MTRACE-2:eutranTraceId:eutranTraceIdMncLen=2
...    MTRACE-2:eutranTraceId:traceId=1
...    MTRACE-2:eutranTraceId:trcRecSessionRef=1
...    MTRACE-2:immedMDTControl:immedMDTAnonymization=IMEI-TAC
...    MTRACE-2:immedMDTControl:immedMDTForceUEConsent=false
...    MTRACE-2:immedMDTControl:immedMDTObtainLocation=false
...    MTRACE-2:immedMDTControl:immedMDTPosMethod=None
...    MTRACE-2:immedMDTControl:immedMDTSelectOnlyGNSSUes=false
...    MTRACE-2:immedMDTControl:cellMaxActiveMDTUEsTraced=1
...    MTRACE-2:immedMDTControl:iFMDTPercentage=50
...    MTRACE-2:immedMDTControl:maxMDTFreqLayers=10

@{newMTRACE_2_c6_cellMaxActiveMDTUEsTraced2}
...    delete:MTRACE-2
...    MTRACE-3:lcrId=1
...    MTRACE-3:jobType=ImmediateMDTAndTrace
...    MTRACE-3:cellMaxActiveUEsTraced=20
...    MTRACE-3:tceIpAddress=${TCE_IP}
...    MTRACE-3:tceCellTracePortNum=${TCE_PORT}
...    MTRACE-3:traceRrcSetting=All
...    MTRACE-3:iFMDTList:measBW=mbw100|iFFreqEARFCN=1400
...    MTRACE-3:iFMDTList:measBW=mbw100|iFFreqEARFCN=1425
...    MTRACE-3:iFMDTList:measBW=mbw100|iFFreqEARFCN=1500
...    MTRACE-3:iFMDTList:measBW=mbw100|iFFreqEARFCN=1600
...    MTRACE-3:periodicUeMeas:reportAmount=8
...    MTRACE-3:periodicUeMeas:reportInterval=5120ms
...    MTRACE-3:eutranTraceId:eutranTraceIdMcc=262
...    MTRACE-3:eutranTraceId:eutranTraceIdMnc=3
...    MTRACE-3:eutranTraceId:eutranTraceIdMncLen=2
...    MTRACE-3:eutranTraceId:traceId=1
...    MTRACE-3:eutranTraceId:trcRecSessionRef=1
...    MTRACE-3:immedMDTControl:immedMDTAnonymization=IMEI-TAC
...    MTRACE-3:immedMDTControl:immedMDTForceUEConsent=false
...    MTRACE-3:immedMDTControl:immedMDTObtainLocation=false
...    MTRACE-3:immedMDTControl:immedMDTPosMethod=None
...    MTRACE-3:immedMDTControl:immedMDTSelectOnlyGNSSUes=false
...    MTRACE-3:immedMDTControl:cellMaxActiveMDTUEsTraced=2
...    MTRACE-3:immedMDTControl:iFMDTPercentage=50
...    MTRACE-3:immedMDTControl:maxMDTFreqLayers=10

${tceport}    49150

@{disable_LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=false

@{MDTJobtype_ImmediateMDTAndTrace}
...    MTRACE-1:jobType=ImmediateMDTAndTrace
...    MTRACE-1:traceRrcSetting=All

@{delta_case1_1}
...    @{MDTJobtype_ImmediateMDTAndTrace}
...    @{disable_LTE4193}
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001

@{restore_CASE1}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001

*** Test Cases ***
CB010266-SR-A_B1_ET_01_Keep on-going intra-freq MDT measurement running on UE when performing blindly EN-DC setup
    [Documentation]
    ...    CB010266-SR-A_B1_ET_01_Keep on-going intra-freq MDT measurement running on UE when performing blindly EN-DC setup triggered
    ...    by E-RAB setup of EN-DC eligible bearer
    [Tags]    owner-ying.shang
    Delta Commission Parameters And Wait Cells Onair    ${delta_case1_1}
    start TCE and Wait Session Establish
    Attach UEs to Cell-1 when actMDTCellTrace is active    ue_start=11    ue_end=21
    Add Bearer Trigger ENDC Setup when actMDTCellTrace is active    ue_start=11    ue_end=21
    UE Delete ENDC Eligible Bearer    ue_start=12    ue_end=13
    Release all UEs
    [Teardown]    case1_teardown

CB010266-SR-A_B2_ET_06_verification online change actEndcIntraFreqMdt false to true with LTE4088 true to false
    [Tags]    owner-carol.an
    start TCE and Wait Session Establish
    UE attach to cell1    ue_id=3
    multi UEs attach dynamic ENDC    start_ue=1    end_ue=2
    CB010266 disable ENDC remove all MDT
    Enable CB0010266 disable LTE4088 no ENDC
    cellMaxActiveMDTUEsTraced1 enable LTE4088 2nd UE without MDT
    cellMaxActiveMDTUEsTraced2 enable BlindENDC 3th UE blind ENDC without MDT
    Release All UEs
    [Teardown]    case6_teardown

*** Keywords ***
Case setup
    Common Test Setup And Start To Capture Logs
    Enable Management MDT Based Allowed

Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias for multi UEs
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Set UE parameters for ENDC capability

Create UE Alias for multi UEs
    FOR    ${ue_id}    IN RANGE    3    51
       Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Egate Command    sim_trace uec=1 protocol=rrc on
    Execute Uex Command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=2 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1 nr_supported_bands=78,258
    Execute Uex Command    ue_param id=2 nr_supported_bands=78,258
    Execute Egate Command    ue_enb_param id=1,2,3,7,8,11,12,13,14,15,16,17,18,19,20,21,22,23 spid=34
    Config gnb7
    Config UE11 to UE16 support NRANR

Config UE11 to UE16 support NRANR
    FOR    ${ue_id}    IN RANGE    3    51
       Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
       Execute Uex Command    ue_param id=${ue_id} nr_supported_bands=78,258
    END

Config gnb7
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=4:1

Perform Steps After Onair
    @{lnadj}    Create List    LNADJ:cPlaneIpAddr=10.0.1.33    LNADJ:x2LinkStatus=available
    Object Should Exist    ${lnadj}

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...     - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    ...     - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...     - {qci: 6, pdn: 2}
    ...     - {qci: 7, pdn: 2}
    ...     - {qci: 9, pdn: 2}
    FOR    ${ue_set_id}     IN RANGE    11    25
        Update Yaml    UEs/UE_sets/${ue_set_id}    bearer: 'bearer_set_2'    release: '15'    nea: 'null'    nia: 'null'
    END

    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31}
    Update Yaml    UEs/UE_sets/37     bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/38     bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/39     bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/30     bearer: bearer_set_3

    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...       type: simulated
    ...       plmn: '262:03'
    ...       s1: 10.0.1.33
    ...       x2: 10.0.1.33
    ...       cells:
    ...       - {id: 21, technology: lte, tac: 33, pci: '9:0', earfcn: '1400:19400', bw: 20}
    ...       - {id: 22, technology: lte, tac: 33, pci: '9:1', earfcn: '5920:23920', bw: 20}
    ...       - {id: 23, technology: lte, tac: 33, pci: '9:2', earfcn: '8770:26770', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...       type: simulated
    ...       enb_id_macro: 0x0000A
    ...       plmn: '262:03'
    ...       s1: 10.0.1.34
    ...       x2: 10.0.1.34
    ...       cells:
    ...        - {id: 31, technology: lte, tac: 33, pci: '2:1', eci: '0x0000A1F', earfcn: '1400:19400', bw: 20}

    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...       gnb_id: '0x00007'
    ...       type: simulated
    ...       plmn: '262:03'
    ...       s1u: 10.0.1.41
    ...       x2: 10.0.1.41
    ...       x2_peers: 1
    ...       cells:
    ...       - ${gnb7_cell1}
    ...       - ${gnb7_cell2}
    ...       - ${gnb7_cell3}
    ...       - ${gnb7_cell4}
    ...       - ${gnb7_cell5}

start TCE and Wait Session Establish
    Start TCE    ${tceport}
    Sleep    120    #wait PCMD trace session to establish

Enable Management MDT Based Allowed
    [Arguments]    ${ue_id}=1
    FOR    ${ue_id}    IN RANGE    1    51
        Execute Egate Command    ue_mme_param mb_mdt_allowed=on id=${ue_id}
    END

UE start traffic
    [Arguments]    ${ue_id}=1    ${qci}=8
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl_and_ul protocol=udp Mbps_dl=150 Mbps_ul=20 qci=${qci}
    Sleep    5s    #wait for eNB load to be High
    Execute Uex Command    ue_stats id=${ue_id} type=dl_mac unit=Mbps

multi UEs attach dynamic ENDC
    [Arguments]    ${start_ue}=1    ${end_ue}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ${stop_ue}=    Evaluate    ${end_ue}+${1}
    FOR    ${i}    IN RANGE    ${start_ue}    ${stop_ue}
       attach UE and report B1 to trigger ENDC    ue_id=${i}    ue_eutra_capabilities=${ue_eutra_capabilities}
    END

multi UEs attach dynamic ENDC remove intraFreqMDT
    [Arguments]    ${start_ue}=1    ${end_ue}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ${stop_ue}=    Evaluate    ${end_ue}+${1}
    FOR    ${i}    IN RANGE    ${start_ue}    ${stop_ue}
       attach UE and report B1 to trigger ENDC remove intraFreqMDT    ue_id=${i}    ue_eutra_capabilities=${ue_eutra_capabilities}
    END

Trigger UE to send B1-NR not Setup ENDC
    [Arguments]    ${ue_id}=1    ${pci}=1
    Expect Message Will Not Occur    ENB_1:X2AP_SgNBAdditionRequest
    ...    alias=Not_ENDC    overall_timeout=20
    Trigger UE to send B1-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}
    Flow Not Occurred For Message    alias=Not_ENDC

attach UE and report B1 to trigger ENDC
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    Expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (14,15))
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=ENDC_setup_with_gNB7    overall_timeout=20
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measConfig contains (measIdToRemoveList contains (9)))
    ...    alias=Not_Del_intraFreqMDT    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Trigger UE to send B1-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    Flow Occurred As Expected    alias=ENDC_setup_with_gNB7
    Flow Not Occurred For Message    alias=Not_Del_intraFreqMDT

ENDC setup without MDT
    [Arguments]    ${ue_id}=1    ${pci}=1
    ${noIntra_interFreqMDT}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((measIdToRemoveList contains (9,14,15)) and
    ...    (measIdToAddModList contains (measId eq 9))) as noMDT
    Expect Message Will Not Occur
    ...    ${noIntra_interFreqMDT}
    ...    alias=without_intra_interFreqMDT    overall_timeout=20
    Trigger UE to send B1-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}
    Flow Not Occurred For Message    alias=without_intra_interFreqMDT

Add NEW bearer
    [Arguments]    ${ue_id}=1    ${qci}=1
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measConfig contains (measIdToRemoveList contains (9)))
    ...    alias=Not_Del_intraFreqMDT    overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci}
    Flow Not Occurred For Message    alias=Not_Del_intraFreqMDT

UE reestablish and check log
    [Arguments]    ${start_ue}=1    ${end_ue}=1
    Expect message flow
    ...    UE_${start_ue}:RRC_RRCConnectionReconfiguration as UE_reestabRRC
    ...    alias=UE_addINterIntra    overall_timeout=20
    UE reestablish    start_ue=${start_ue}    end_ue=${end_ue}
    Flow Occurred As Expected    alias=UE_addINterIntra
    verify that message has fields
        ...    measIdToAddModList..measId eq 9
        ...    measIdToAddModList..measObjectId eq 1
        ...    measIdToAddModList..reportConfigId eq 5
        ...    measIdToAddModList..measId eq 4
        ...    measIdToAddModList..measObjectId eq 1
        ...    measIdToAddModList..reportConfigId eq 3
        ...    measIdToAddModList..measId eq 14
        ...    measIdToAddModList..measObjectId eq 2
        ...    measIdToAddModList..reportConfigId eq 5
        ...    measIdToAddModList..measId eq 15
        ...    measIdToAddModList..measObjectId eq 3
        ...    measIdToAddModList..reportConfigId eq 5
        ...    measIdToAddModList..measId eq 16
        ...    measIdToAddModList..measObjectId eq 4
        ...    measIdToAddModList..reportConfigId eq 5
        ...    message_alias=UE_reestabRRC
        ...    flow_alias=UE_addINterIntra

UE reestablish without MDT and check log
    [Arguments]    ${start_ue}=1    ${end_ue}=1
    ${reestabRRC}    catenate
    ...    measConfig contains (measIdToAddModList contains (
    ...    measId eq 9,
    ...    measObjectId eq 1,
    ...    reportConfigId eq 5
    ...    ))
    ...    and (measIdToAddModList contains (
    ...    measId eq 14,
    ...    reportConfigId eq 5
    ...    ))
    Expect Message Will Not Occur
    ...    UE_${start_ue}:RRC_RRCConnectionReconfiguration (${reestabRRC}) as UE_reestabRRC
    ...    alias=UE_addINterIntra    overall_timeout=20
    UE reestablish    start_ue=${start_ue}    end_ue=${end_ue}
    Flow Not Occurred For Message    alias=UE_addINterIntra

B1 to trigger ENDC remove intraFreqMDT
    [Arguments]    ${ue_id}=1    ${pci}=1
    Expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (14,15))
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=ENDC_setup_with_gNB7    overall_timeout=20
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measConfig contains (measIdToRemoveList contains (9)))
    ...    alias=Not_Del_intraFreqMDT    overall_timeout=20
    Trigger UE to send B1-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}
    Flow Occurred As Expected    alias=ENDC_setup_with_gNB7
    Flow Occurred As Expected    alias=Not_Del_intraFreqMDT

attach UE without B1_NR
    [Arguments]    ${ue_id}=1
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    alias=noB1_RRC    overall_timeout=16
    UE attach to cell1    ue_id=${ue_id}
    Flow Not Occurred For Message    alias=noB1_RRC

attach UE and report B1 to trigger ENDC remove intraFreqMDT
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    Expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (14,15))
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=ENDC_setup_with_gNB7    overall_timeout=20
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measConfig contains (measIdToRemoveList contains (9)))
    ...    alias=Not_Del_intraFreqMDT    overall_timeout=20
    UE attach to cell1    ue_id=${ue_id}    ue_eutra_capabilities=${ue_eutra_capabilities}
    Trigger UE to send B1-NR for freq with PCI1    ue_id=${ue_id}    pci=${pci}    narfcn=${narfcn}
    Flow Occurred As Expected    alias=ENDC_setup_with_gNB7
    Flow Occurred As Expected    alias=Not_Del_intraFreqMDT

UE reestablish
    [Arguments]    ${start_ue}=1    ${end_ue}=1    ${enb_id}=1    ${cell_id}=1
    ${stop_ue}=    Evaluate    ${end_ue}+${1}
    FOR    ${i}    IN RANGE    ${start_ue}    ${stop_ue}
        Set RSC report HO to cell3    ue_id=${i}
        Execute Uex Command    ue_rrc_reestablish id=${i} enb=1 cell=1
    END

UE attach to cell1
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration as UE_RRCReconfig
    ...    alias=UE_Attach    overall_timeout=20
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    ${ret1}=    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=UE_Attach
    verify that message has fields
        ...    measObjectToAddModList..measObjectId eq 1
        ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq 1400
        ...    measObjectToAddModList..measObjectId eq 4
        ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq 1425
        ...    measObjectToAddModList..measObjectId eq 2
        ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq 1500
        ...    measObjectToAddModList..measObjectId eq 3
        ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq 1600
        ...    reportConfigToAddModList..reportConfigId eq 5
        ...    reportConfigToAddModList..reportConfigEUTRA..periodical..purpose eq "reportStrongestCells"
        ...    measIdToAddModList..measId eq 9
        ...    measIdToAddModList..measObjectId eq 1
        ...    measIdToAddModList..reportConfigId eq 5
        ...    measIdToAddModList..measId eq 14
        ...    measIdToAddModList..measObjectId eq 2
        ...    measIdToAddModList..reportConfigId eq 5
        ...    measIdToAddModList..measId eq 15
        ...    measIdToAddModList..measObjectId eq 3
        ...    measIdToAddModList..reportConfigId eq 5
        ...    measIdToAddModList..measId eq 16
        ...    measIdToAddModList..measObjectId eq 4
        ...    measIdToAddModList..reportConfigId eq 5
        ...    message_alias=UE_RRCReconfig
        ...    flow_alias=UE_Attach

Set RSC auto report HO to cell3
    [Arguments]    ${ue_id}=1    ${nrsrp}=56    ${nrsrq}=34    ${pci}=3
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=1400 nrsrp=${nrsrp} nrsrq=${nrsrq} srsrp=0 srsrq=0 nsinr=31 strongest=true     #strongest=eutra
    Run Uex Command    ${cmd}

Set RSC report HO to cell3
    [Arguments]    ${ue_id}=1    ${nrsrp}=56    ${nrsrq}=34    ${pci}=3
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=measId with_value=9 action=measurement_send
    ...    phycell_id=${pci} narfcn=1400 nrsrp=${nrsrp} nrsrq=${nrsrq} srsrp=0 srsrq=0 nsinr=31 strongest=true     #strongest=eutra
    Run Uex Command    ${cmd}

Trigger UE to send B1-NR for freq with PCI1
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=${NRARFCN2036667}
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${pci} nrsrp=58 nrsrq=88 narfcn=${narfcn} amount=1

case6_teardown
    Delta Commission Parameters    ${restore_MTRACE1}
    Delta Commission Parameters    ${restore_CASE6}
    Execute Egate Command    mme_timer reset
    Release All UEs
    Common Test Teardown And Stop Capture Logs

CB010266 disable ENDC remove all MDT
    Delta Commission Parameters    ${CB010266_disable}
    multi UEs attach dynamic ENDC remove intraFreqMDT    start_ue=4    end_ue=4
    Add NEW bearer    ue_id=1    qci=6
    UE start traffic    ue_id=1
    UE start traffic    ue_id=2
    UE reestablish and check log    start_ue=1    end_ue=1
    B1 to trigger ENDC remove intraFreqMDT    ue_id=1    pci=1

Enable CB0010266 disable LTE4088 no ENDC
    Delta Commission Parameters    ${enableCB0010266_disableLTE4088}
    attach UE without B1_NR    ue_id=5
    Trigger UE to send B1-NR not Setup ENDC    ue_id=3    pci=1
    UE start traffic    ue_id=3
    UE start traffic    ue_id=5
    UE reestablish and check log    start_ue=3    end_ue=3
    Add NEW bearer    ue_id=3    qci=6

cellMaxActiveMDTUEsTraced1 enable LTE4088 2nd UE without MDT
    Delta Commission Parameters    ${MaxActiveMDTUEs1_enableLTE4088}
    Set RSC auto report HO to cell3    ue_id=6    nrsrp=90    nrsrq=88
    multi UEs attach dynamic ENDC    start_ue=6    end_ue=6
    Add NEW bearer    ue_id=6    qci=6
    UE reestablish without MDT and check log    start_ue=3    end_ue=3
    ENDC setup without MDT    ue_id=3    pci=1

cellMaxActiveMDTUEsTraced2 enable BlindENDC 3th UE blind ENDC without MDT
    Delta Commission Parameters    ${MaxActiveMDTUEs2_enableBlindENDC}
    Add NEW bearer    ue_id=5    qci=6
    UE reestablish and check log    start_ue=5    end_ue=5
    UE attach to cell1    ue_id=7
    UE reestablish without MDT and check log    start_ue=2    end_ue=2

case1_teardown
    Delta Commission Parameters    ${restore_CASE1}
    Execute Egate Command    mme_timer reset
    Release All UEs
    Common Test Teardown And Stop Capture Logs

Attach UEs to Cell-1 when actMDTCellTrace is active
    [Arguments]    ${ue_start}    ${ue_end}
    FOR    ${ue_id}    IN RANGE    ${ue_start}    ${ue_end}
        Expect message flow
        ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration as UE_RRCReconfig
        ...    alias=UE_Attach    overall_timeout=20
        ${V_1}    catenate
        ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} \
        ...    ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
        Execute Uex Command    ${V_1}
        Flow Occurred As Expected    alias=UE_Attach
        verify that message has fields
        ...    measObjectToAddModList..measObjectId eq 1
        ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq 1400
        ...    measObjectToAddModList..measObjectId eq 2
        ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq 1425
        ...    measObjectToAddModList..measObjectId eq 3
        ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq 1500
        ...    reportConfigToAddModList..reportConfigId eq 5
        ...    reportConfigToAddModList..reportConfigEUTRA..periodical..purpose eq "reportStrongestCells"
        ...    measIdToAddModList..measId eq 9
        ...    measIdToAddModList..measObjectId eq 1
        ...    measIdToAddModList..reportConfigId eq 5
        ...    measIdToAddModList..measId eq 14
        ...    measIdToAddModList..measObjectId eq 2
        ...    measIdToAddModList..reportConfigId eq 5
        ...    measIdToAddModList..measId eq 15
        ...    measIdToAddModList..measObjectId eq 3
        ...    measIdToAddModList..reportConfigId eq 5
        ...    message_alias=UE_RRCReconfig
        ...    flow_alias=UE_Attach
    END

Add Bearer Trigger ENDC Setup when actMDTCellTrace is active
    [Arguments]    ${ue_start}    ${ue_end}
    FOR    ${ue_id}    IN RANGE    ${ue_start}    ${ue_end}
        Expect message flow
        ...    GNB_7:X2AP_SgNBAdditionRequest
        ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
        ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (14,15))
        ...    GNB_7:X2AP_SgNBReconfigurationComplete
        ...    GNB_7:X2AP_SNStatusTransfer
        ...    alias=ENDC_setup_with_gNB7    overall_timeout=20
        Expect Message Will Not Occur
        ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measConfig contains (measIdToRemoveList contains (9)))
        ...    alias=Not_Del_intraFreqMDT    overall_timeout=20
        Execute Uex Command    bearer_add ue=${ue_id} qci=8
        Flow Occurred As Expected    alias=ENDC_setup_with_gNB7
        Flow Not Occurred For Message    alias=Not_Del_intraFreqMDT
    END

UE Delete ENDC Eligible Bearer
    [Arguments]    ${ue_start}    ${ue_end}
    FOR    ${ue_id}    IN RANGE    ${ue_start}    ${ue_end}
        Expect message flow
        ...    MME_1:S1AP_E-RABReleaseCommand (E-RABList contains (e-RAB-ID eq 6))
        ...    ENB_1:X2AP_SgNBReleaseRequest
        ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge (E-RABs-Admitted-ToBeReleased-SgNBRelReqAckList contains (e-RAB-ID eq 6))
        ...    MME_1:S1AP_E-RABReleaseResponse (E-RABReleaseListBearerRelComp contains (e-RAB-ID eq 6))
        ...    alias=Del_Bearer    overall_timeout=20
        Execute Uex Command    bearer_del ue=${ue_id} qci=8
        Flow Occurred As Expected    alias=Del_Bearer
    END

