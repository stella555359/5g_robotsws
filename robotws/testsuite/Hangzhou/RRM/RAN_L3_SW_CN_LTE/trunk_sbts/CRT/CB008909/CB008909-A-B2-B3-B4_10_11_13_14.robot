*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT    team-DevHZ5_SG4
...               CLOUD_R4LAPO_CUS    release-SBTS23R3    owner-rebecca.zhong
Resource          ../../../resources/DevHZ5_resource.robot
*** Variables ***
@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerIFSBA4=5000ms
${UTE_WIRESHARK_FLAG}    ${True}
${NRARFCN630000}    630048
${NRARFCN657700}    656736
@{PARAMS_IN_SCF}
...    @{Feature_flag}
...    @{NRDCDPR}
...    @{LTE4088}
...    @{LTE4193}
...    @{relation_error_fixed}
...    @{HANDOVER_TO_5GSA}
...    @{neighbor_relationship_WCDMA}
...    @{neighbor_relationship_with_gnb}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
...    LNBTS:actMultBearers=true
...    LNBTS:actMultGbrBearers=true
...    LNBTS:actIfHo=enabled
...    LNBTS-1:actHOtoNR=false
...    LNBTS-1:actHOtoWcdma=false
...    @{LNADJ}
@{relation_error_fixed}
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:tS1eRABModInd=2000
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1:nrRestrictionOverride=disabled
...    LNBTS-1:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
@{Feature_flag}
...    LNCEL:actServBasedHoQciX=true
...    LNBTS:reportTimerSBHoQciXA5=5000ms
...    LNBTS:qciTab2:servBasedHoAllowed=forbidden
...    LNBTS:qciTab3:servBasedHoAllowed=forbidden
...    LNBTS:qciTab4:servBasedHoAllowed=allowed
...    LNBTS:qciTab5:servBasedHoAllowed=forbidden
...    LNBTS:qciTab6:servBasedHoAllowed=forbidden
...    LNBTS:qciTab7:servBasedHoAllowed=forbidden
...    LNBTS:qciTab8:servBasedHoAllowed=forbidden
...    LNBTS:qciTab9:servBasedHoAllowed=forbidden
...    LNBTS:qciTab65:servBasedHoAllowed=forbidden
...    LNBTS:qciTab66:servBasedHoAllowed=forbidden
...    LNBTS:qciTab69:servBasedHoAllowed=forbidden
...    LNBTS:qciTab70:servBasedHoAllowed=forbidden
...    LNBTS:qciTabOperator:servBasedHoAllowed=forbidden
...    LNCEL-1/LNHOIF-1:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-1:thresholdRsrqSBHoQciXFilter=-120
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNBTS:actSelMobPrf=true
...    LNBTS:moProfileSelect=spid
...    LNBTS/MOPR-1:freqLayListServBasedHoQciX=1600
...    LNCEL-1:moPrMappingList:moPrId=1|spid=1
...    LNCEL-2:moPrMappingList:moPrId=1|spid=1
...    LNCEL-3:moPrMappingList:moPrId=1|spid=1
...    LNBTS/MODPR-0:autoAdapt=false
...    delete:MODPR:freqLayListServBasedHoQciX
@{LNADJ}
...    LNBTS/LNADJ-255:adjEnbId=2
...    LNBTS/LNADJ-255:cPlaneIpAddr=10.0.1.4
...    LNBTS/LNADJ-255:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-255:plmnId:mnc=3
...    LNBTS/LNADJ-255:plmnId:mcc=262
...    LNBTS/LNADJ-255:plmnId:mncLength=2
@{NRDCDPR}
...    LNBTS-1/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-1/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS-1/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=56
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${NRARFCN657700}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1
@{LTE4088}
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:tLteNrDualConnectPrep=5000
...    LNBTS-1:qciTab8:nrPdcpProfIdx=1001
...    LNBTS-1:qciTab8:lteNrDualConnectSupport=EN-DC
...    LNBTS-1:pdcpProf1001:pdcpProfileId=1001
...    LNBTS-1:pdcpProf1001:snSizeDl=18bit
...    LNBTS-1:pdcpProf1001:snSizeUl=18bit
...    LNBTS-1:pdcpProf1001:statusRepReq=0
...    LNBTS-1:pdcpProf1001:tDiscard=300ms
@{LTE4193}
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-2:defaultLnRelGnbCellId=1
@{neighbor_relationship_with_gnb}
...    LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=33301
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNBTS-1/LNADJGNB-2:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=49951
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=33301
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{HANDOVER_TO_5GSA}
...    LNBTS-1:tS1RelOvDeltN=5000
...    LNBTS-1:tS1RelPrepN=5000
...    LNCEL:actFlowCtrlEnh=true
...    LNBTS-1:actRedirect=disabled
...    LNBTS-1:actCsfbPsHoToUtra=false
...    LNBTS-1:act1xCsfb=false
...    LNBTS-1:actDualRx1xCsfb=false
...    LNBTS-1/LNCEL:threshold2NR=25
...    LNBTS-1/LNCEL:t304InterRATN=500ms
...    LNBTS-1/LNCEL:a2TimeToTriggerActNRMeas=320ms
...    LNBTS-1/LNCEL:hysThreshold2NR=0
...    LNBTS-1/LNCEL:measQuantityNr=RSRP
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-1/MOPR-1:freqLayListPsHoNR=${NRARFCN630000}
...    LNBTS-1/MOPR-1:freqLayListPsHoNRVoLte=${NRARFCN630000}
...    LNBTS/LNADJN-1/LNADJNL-1:cellIdentity=133161
...    LNBTS/LNADJN-1/LNADJNL-1:trackingAreaCodeNR=33
...    LNBTS/LNADJN-1/LNADJNL-1:gnbIdLength=22
...    LNBTS/LNADJN-1/LNADJNL-1:gNBplmnId:mcc=262
...    LNBTS/LNADJN-1/LNADJNL-1:gNBplmnId:mnc=3
...    LNBTS/LNADJN-1/LNADJNL-1:gNBplmnId:mncLength=2
...    LNBTS/LNADJN-1/LNADJNL-1:plmnIdList:mcc=262
...    LNBTS/LNADJN-1/LNADJNL-1:plmnIdList:mnc=3
...    LNBTS/LNADJN-1/LNADJNL-1:plmnIdList:mncLength=2
...    LNBTS/LNADJN-1:arfcnValueNR=${NRARFCN630000}
...    LNBTS/LNADJN-1:physCellIdNr=2
...    LNBTS/LNADJN-1:multiFrequencyBandList=77
...    LNBTS/LNCEL/LNHON-1:b2NrCellReportQuantity=RSRP
...    LNBTS/LNCEL/LNHON-1:carrierFreqNr=${NRARFCN630000}
...    LNBTS/LNCEL/LNHON-1:freqBandIndicatorListNr=77
...    LNBTS/LNCEL/LNHON-1:ssbPeriodicity=sf10-r15
...    LNBTS/LNCEL/LNHON-1:ssbSubcarrierSpacing=30kHz
...    LNBTS/LNCEL/LNHON-1:ssbDuration=sf1
...    LNBTS/LNCEL/LNHON-1:b2Threshold1RsrpNr=40
...    LNBTS/LNCEL/LNHON-1:b2Threshold2RsrpNr=56
...    LNBTS-1/LNCEL/LNRELN-1:cellIdentity=133161
...    LNBTS-1/LNCEL/LNRELN-1:psHoAllowed=allowed
...    LNBTS-1/LNCEL/LNRELN-1:plmnId:mcc=262
...    LNBTS-1/LNCEL/LNRELN-1:plmnId:mnc=3
...    LNBTS-1/LNCEL/LNRELN-1:plmnId:mncLength=2
@{neighbor_relationship_WCDMA}
...    LNBTS/LNADJW-1:uTargetRncId=1
...    LNBTS/LNADJW-1:uTargetCid=1
...    LNBTS/LNADJW-1:uTargetFreq=1200
...    LNCEL:threshold2Wcdma=25
...    LNCEL/LNHOW-1:utraCarrierFreq=1200
...    LNBTS-1/LNADJW-1:uTargetFreq=1200
...    LNBTS-1/MOPR-1:freqLayListSrvccWcdma=1200
...    LNBTS-1/MOPR-1:freqLayListPsHoWcdma=1200
...    LNCEL/LNRELW-1:uTargetRncId=1
...    LNCEL/LNRELW-1:uTargetCid=1
...    LNCEL/LNRELW-1:psHoAllowed=allowed
...    LNCEL:a2TimeToTriggerActWcdmaMeas=0ms
@{Parameter_10_02}
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    LNBTS:qciTab7:servBasedHoAllowed=allowed
@{Parameter_recovery_10_02}
...    LNBTS:qciTab7:servBasedHoAllowed=forbidden
@{Parameter_11_02}
...    LNBTS/MOPR-1:freqLayListLte=1600
...    LNBTS:qciTab8:servBasedHoAllowed=allowed
@{Parameter_11_02_HOtoWcdma}
...    LNBTS-1:actHOtoWcdma=true
...    LNBTS/MOPR-1:freqLayListPsHoWcdma=1200
@{Parameter_11_02_HOtoSA}
...    LNBTS-1:actHOtoNR=true
...    LNBTS-1/MOPR-1:freqLayListPsHoNR=${NRARFCN630000}
...    LNBTS-1/MOPR-1:freqLayListPsHoNRVoLte=${NRARFCN630000}
@{Parameter_recovery_11_02}
...    LNBTS-1:actHOtoNR=false
...    LNBTS-1:actHOtoWcdma=false
...    delete:LNBTS-1/MOPR-1:freqLayListPsHoNR
...    delete:LNBTS-1/MOPR-1:freqLayListPsHoNRVoLte
...    delete:LNBTS/MOPR-1:freqLayListLte
...    delete:LNBTS/MOPR-1:freqLayListPsHoWcdma
...    LNBTS:qciTab8:servBasedHoAllowed=forbidden
@{Parameter_13_02}
...    LNBTS-1:actDynTrigLteNrDualConnectivity=false
...    LNBTS:qciTab8:servBasedHoAllowed=allowed
...    LNBTS:qciTab9:servBasedHoAllowed=allowed
...    LNBTS-1:qciTab6:nrPdcpProfIdx=1001
...    LNBTS-1:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS-1:qciTab8:nrPdcpProfIdx=1001
...    LNBTS-1:qciTab8:lteNrDualConnectSupport=EN-DC
@{Parameter_13_02_LTE4193_enable}
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
@{Parameter_recovery_13_02}
...    LNBTS:qciTab8:servBasedHoAllowed=forbidden
...    LNBTS:qciTab9:servBasedHoAllowed=forbidden
@{LTE1127}
...    LNBTS/LNBTS_FDD-0:actInterFreqServiceBasedHo=true
...    LNBTS/MODPR-0:freqLayListServiceBasedHo=38000
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=38000
...    LNCEL-1/LNHOIF-2:thresholdRsrpIFSBFilter=-100
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw100
...    LNCEL:iFServiceBasedHoRetryTimer=60
...    LNCEL:sbHoMode=all
@{LTE2503}
...    LNCEL:sbHoMode=ec
@{Enable_for_Case14}
...    @{LTE1127}
...    LNBTS/MODPR-0:freqLayListServBasedHoQciX=1600
...    LNBTS:actRedirect=disabled
...    LNCEL-1/LNHOIF-2:thresholdRsrpSBHoQciXFilter=-98
@{Disable_LTE1127}
...    LNBTS/LNBTS_FDD-0:actInterFreqServiceBasedHo=false
...    LNCEL:sbHoMode=all
@{Disable_for_Case14}
...    @{Disable_LTE1127}
...    delete:MODPR:freqLayListServBasedHoQciX
...    LNBTS:actRedirect=enabled
${ue_eutra_capabilities}
...    SEPARATOR=
...    DD9FF44083000894204F82E0B8004FBF06FCCF650801102008295000028331D9FE0DD89A5E190117BF06EC4D5858210C2084308210C108608
...    410025A0FAA8C28141C208020A30410B08200828C1051820858410041420828C1041C208020A104103082008207280020B205C1705C1705C1
...    705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705
...    DF8A0000336421E1E1E2E11FC5C878787878787878787878710F0F0F0E00008BF060000102020880CD0007CE3C0004080C10181C2C4C6C707
...    507EFF896B4D03217F9A00EA000600DB24000080000412E780C000048080C2609A143C037FC00000A00000061000880004
${ue_MRDC_capabilities}
...    SEPARATOR=
...    C10060B71B02004040C1803A020000000FD00000000081B8981002060E2680000103F400000000206E360400818103071340000101FA000000
...    0010370B0200E2680000303F400000000206E26040081838040000100FD0000000008100800803004809B00080418000402000100800040202
...    0040088000201000080404008011800040200010080004020200400840002010100200440001008000402020040080
${ue_nr_capabilities}
...    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C28D010CA1A044083A0C30260220B6480A01000C039
...    F2107800412070701101E407800040400009B89BC09024000000120000040900000400A00C0300C0300D802802010040118028030100401004
...    600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C00800011041082000064104208
...    000210410809A55334A262B9515DA8AEC4
${ue_eutra_capab_HO_to_WCDMA_SA}
...    SEPARATOR=
...    DD9FF430830008081705C177F0FFDBBCA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C1082080304
...    218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B082008284105182083841004142082061040
...    105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B
...    82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E0002040
...    6080C0E162636383A83F7FC4B5A68190BFCD08750003006D9200004000020973C0600002404061304D0A1E01BFE0000050000003080044000A
...    103FC011304D
${wait_onair_stable}    240s
*** Test Cases ***
CB008909-SR-A-B3_ET_10_02_No QCIx-SBHO A5 Measurement Setup when UE in EN-DC mode
    [Documentation]    This case verifies No QCIx-SBHO A5 Measurement Setup when UE in EN-DC mode
    ...    step1: Attach UE-1 to Cell-1 with QCIx bearer QCI-6
    ...    step2: E-RAB setup with NR-PDCP QCI-8 Ande dynamic ENDC B1 event configured
    ...    step3: UE-1 report dynamic ENDC B1 with NR cell and setup ENDC
    ...    step4: UE-1 E-RAB setup with QCIx-SBHO bearer QCI-4,No QCIx SBHO eA5 configured due to ENDC active
    ...    step5: UE-1 E-RAB release request with NR-PDCP QCI-8,No QCIx SBHO eA5  configured
    ...    step6: ERAB setup request with QCIx-SBHO bearer QCI-7,QCIx SBHO eA5 measurements configure.
    [Tags]
    Online parameter change     ${Parameter_10_02}
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}    ue_id=1
    ...    cell_id=1
    Add one NR_PDCP bearer    ue_id=1    qci=8    reportConfigId=4
    Setup ENDC with Dynamic B1 report    ue_id=1    pci=1
    Add one GBR QCIx bearer without QCIx_SBHO eA5    ue_id=1    qci=4
    Release NR_PDCP bearer without QCIx_SBHO eA5    ue_id=1    qci=8
    Add one NON_GBR QCIx bearer with QCIx_SBHO eA5    ue_id=1    qci=7    earfcn=1600
    [Teardown]     Restore Env and Capture Logs    ${Parameter_recovery_10_02}

CB008909-SR-A-B3_ET_11_02_No QCIx-SBHO A5 Measurement when coverage-based HO Ongoing
    [Documentation]    This case verifies No QCIx-SBHO A5 Measurement when coverage-based HO Ongoing
    ...    step1: Attach UE-2 to Cell-1 with QCIx bearer QCI-8 Attach successfully and QCIx SBHO eA5 measurements configure
    ...    step2: UE-2 report inter-F HO A2 ,event A1 and Inter-F HO A3 configure, deactivate QCIx SBHO eA5
    ...    step3: Attach UE-3 to Cell-1 with QCI-5,Attach successfully but no QCIx SBHO eA5 measurements configure
    ...    step4: UE-3 report inter-F HO A2,event A1 and Inter-F HO A3 configure
    ...    step5: UE-3 E-RAB setup request with QCIx bearer QCI-4,No QCIx SBHO eA5 measurements configure
    ...    step6: Enable LTE56 PSHO to WCDMA
    ...    step7: Attach UE-4 to Cell-1 with QCIx bearer QCI-8 Attach successfully and QCIx SBHO eA5 measurements configure
    ...    step8: UE-4 report inter-RAT to WCDMA A2,event A1 and Inter-RAT HO B2 configure, deactivate QCIx SBHO eA5
    ...    step9: Attach UE-5 to Cell-1 with QCI-5,Attach successfully but no QCIx SBHO eA5 measurements configure
    ...    step10: UE-5 report inter-RAT to WCDMA A2,event A1 and Inter-RAT HO B2 configure
    ...    step11: UE-5 E-RAB setup request with QCIx bearer QCI-4,No QCIx SBHO eA5 measurements configure
    ...    step12: Enable CB007742 PSHO to NR
    ...    step13: Attach UE-6 to Cell-1 with QCIx bearer QCI-8 Attach successfully and QCIx SBHO eA5 measurements configure
    ...    step14: UE-6 report inter-RAT to NR A2,event A1 and Inter-RAT HO B2 with NR configure, deactivate QCIx SBHO eA5
    ...    step15: Attach UE-7 to Cell-1 with QCI-5,Attach successfully but no QCIx SBHO eA5 measurements configure
    ...    step16: UE-7 report inter-RAT to WCDMA A2,event A1 and Inter-RAT HO B2 with NR configure
    ...    step17: UE-7 E-RAB setup request with QCIx bearer QCI-4,No QCIx SBHO eA5 measurements configure
    [Tags]
    Online parameter change     ${Parameter_11_02}
    UE attach with eA5 and trigger IFHO to deactive eA5    ue_id=2
    UE attach setup bearer with eA5 and trigger IFHO to deactive eA5    ue_id=3
    Online parameter change    ${Parameter_11_02_HOtoWcdma}
    UE attach with eA5 and trigger inter-RAT WCDMA HO to deactive eA5    ue_id=4
    UE attach setup bearer with eA5 and trigger inter-RAT WCDMA HO to deactive eA5    ue_id=5
    Online parameter change    ${Parameter_11_02_HOtoSA}
    UE attach with eA5 and trigger inter-RAT NR HO to deactive eA5    ue_id=6
    UE attach setup bearer with eA5 and trigger NR WCDMA HO to deactive eA5    ue_id=7
    [Teardown]     Restore Env and Capture Logs    ${Parameter_recovery_11_02}

CB008909-SR-A-B4_ET_13_02_Deactivate QCIx-SBHO A5 Measurement when EN-DC setup
    [Documentation]    This case verifies Deactivate QCIx-SBHO A5 Measurement when EN-DC setup
    ...    step1: Enable LTE4088, disable LTE4193
    ...    step2: Attach UE-8 to Cell-1 with NR-PDCP and QCIx bearer QCI-8,Attach successfully, QCIx SBHO eA5 measurements configure first,
    ...    then deactivate QCIx SBHO eA5 measurements after blind EN-DC setup
    ...    step3: Attach UE-9 to Cell-1 with QCIx bearer QCI-9,Attach successfully, QCIx SBHO eA5 measurements configure first
    ...    step4: ue-9 E-RAB setup with NR-PDCP bearer QCI-6,EN-DC setup successfully, and deactivate QCIx SBHO eA5 measurements
    ...    step5: Enable LTE4193
    ...    step6: Attach UE-10 to Cell-1 with NR-PDCP and QCIx bearer QCI-8,Attach successfully, QCIx SBHO eA5 measurements configure
    ...    step7: UE-10 report dynamic ENDC B1 with NR cell EN-DC setup successfully and deactivate QCIx SBHO eA5 measurements
    ...    step8: Attach UE-11 to Cell-1 with NR-PDCP bearer QCI-6,Attach successfully, B1 for EN-DC measurements configure
    ...    step9: UE-11 E-RAB setup request with QCIx bearer QCI-4,QCIx SBHO eA5 measurements configure
    ...    step10: UE-11 report dynamic ENDC B1 with NR cell EN-DC setup successfully and deactivate QCIx SBHO eA5 measurements
    [Tags]
    Online parameter change     ${Parameter_13_02}
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5 and the deactive due to blind ENDC    ${ue_eutra_capabilities}    ${ue_MRDC_capabilities}
    ...    ${ue_nr_capabilities}    ue_id=8    cell_id=1    reportConfigId=4
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5    ${ue_eutra_capabilities}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}    ue_id=9
    ...    cell_id=1    reportConfigId=4
    Add one NR_PDCP bearer QCIx_SBHO eA5 deactive    ue_id=9    qci=6
    Online parameter change     ${Parameter_13_02_LTE4193_enable}
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5    ${ue_eutra_capabilities}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}    ue_id=10
    ...    cell_id=1    reportConfigId=4
    Setup ENDC with Dynamic B1 report    ue_id=10    pci=1
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capabilities}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}    ue_id=11
    ...    cell_id=1
    Add one GBR QCIx bearer with QCIx_SBHO eA5    ue_id=11    qci=4
    Setup ENDC with Dynamic B1 report    ue_id=11    pci=1
    [Teardown]     Restore Env and Capture Logs    ${Parameter_recovery_13_02}

CB008909-SR-A-B2-B3-B4_ET_14_02_No QCIx-SBHO A5 Measurement due to QCI1-SBHO A4 Measurement
    [Documentation]    This case verifies:
    ...    CB008909 Interacts with LTE1127;
    ...    LTE1127: Service based mobility trigger;
    ...    Service based HO is prioritized over CB008909, i.e. with both features enabled:
    ...    the CB008909 eA5 is not started for UE with QCI1 bearer (initiated or established)
    ...    upon QCIx SBHO triggering events (ICS or E-RAB Setup or E-RAB Release).
    ...    the ongoing CB008909 eA5 is deactivated upon QCI1 setup;
    ...    When last QCI1 bearer is released, if UE has QCIx bearer(s), eNB try to activate CB008909 eA5.
    [Tags]
    Online parameter change     ${Enable_for_Case14}
    UE Attach with QCI1 SBHO A4 without QCIx SBHO eA5    ue_id=12
    UE Attach with QCI1 SBHO A4    ue_id=14
    Add QCIx bearer without QCIx_SBHO eA5    ue_id=14
    Release QCI1 bearer to trigger QCIx SBHO eA5    ue_id=14
    UE Attach with QCIx SBHO eA5    ue_id=16
    Add QCI1 bearer to deactivate QCIx SBHO eA5    ue_id=16
    Online parameter change    ${LTE2503}
    UE Attach with QCIx SBHO eA5    ue_id=18
    [Teardown]     Restore Env and Capture Logs    ${Disable_for_Case14}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Restore Env and Capture Logs
    [Arguments]    ${PARAM}
    Online parameter change    ${PARAM}
    Common Test Teardown And Stop Capture Logs

Perform Steps After Onair
    sleep    ${wait_onair_stable}
    @{LNADJGNB}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.11    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${LNADJGNB}
    @{lnadj_1}    Create List    LNADJ:cPlaneIpAddr=10.0.1.4    LNADJ:x2LinkStatus=available
    Object Should Exist    ${lnadj_1}

Online parameter change
    [Arguments]    ${PARAM}
    Delta Commission Parameters    ${PARAM}
    Cells Should Be OnAir

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 9, default: on, pdn: 1}
    ...     - {qci: 6, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_4:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_5:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preprovisioned: on, filter: 1, precedence: 4, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 1, precedence: 2, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_6:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 2, precedence: 2}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_7:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preprovisioned: on, filter: 1, precedence: 4, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_8:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_8
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/5    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/7    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/9    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/11    bearer: bearer_set_4
    Update Yaml    UEs/UE_sets/12    bearer: bearer_set_5
    Update Yaml    UEs/UE_sets/14    bearer: bearer_set_6
    Update Yaml    UEs/UE_sets/16    bearer: bearer_set_7
    Update Yaml    UEs/UE_sets/18    bearer: bearer_set_5
    ${GNB2_CELL1}  catenate  - {id: 21, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000215', nr_arfcn: '630000:630000',
    ...    tdd_cell: yes, suggested_band: 78, gscn: 7812}
    ${GNB3_CELL1}  catenate  - {id: 31, technology: nr , tac: 33, pci: '0:2', nrci: '0x000031F', nr_arfcn: '657700:657700',
    ...    tdd_cell: yes, suggested_band: 77, gscn: 8090}
#     add sim gnb345
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    gnb_id: '0x00002'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2_peers: none
    ...    cells:
    ...       ${GNB2_CELL1}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...    gnb_id: '0x00003'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.12
    ...    x2_peers: none
    ...    cells:
    ...       ${GNB3_CELL1}
    Add Yaml    BASE_STATIONS
    ...    - id: 4
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.4
    ...      x2: 10.0.1.4
    ...      cells:
    ...        - {'id': 41, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '13:2', eci: '0x0000429', earfcn: '38000:38000', bw: 20}
    ...        - {'id': 42, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '14:0', eci: '0x000042A', earfcn: '38000:38000', bw: 20}
    ...        - {'id': 43, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '14:1', eci: '0x000042B', earfcn: '38000:38000', bw: 20}

UE Attach to eNB1 Cell1 without QCIx_SBHO eA5
    [Arguments]    ${ue_eutra_capabilities}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}    ${ue_id}=1    ${cell_id}=1
    Set UE parameters before attach    ue_id=${ue_id}
    ${no_a5_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_query})
    ...    alias=attach_no_a5_flow    overall_timeout=2
    ${attach_cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities} ue_nr_capabilities=${ue_nr_capabilities} cell=${cell_id}
    Execute Uex Command    ${attach_cmd}
    Flow Not Occurred For Message    alias=attach_no_a5_flow

UE Attach to eNB1 Cell1 with QCIx_SBHO eA5
    [Arguments]    ${ue_eutra_capabilities}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}    ${ue_id}=1    ${cell_id}=1    ${earfcn}=1600
    ...    ${reportConfigId}=5
    Set UE parameters before attach    ue_id=${ue_id}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    alias=attach_a5_flow    overall_timeout=2
    ${attach_cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities} ue_nr_capabilities=${ue_nr_capabilities} cell=${cell_id}
    Execute Uex Command    ${attach_cmd}
    Flow Occurred As Expected    alias=attach_a5_flow
    verify that message fulfills query
    ...  (
    ...    rrcConnectionReconfiguration  contains (
    ...        measObjectToAddModList  contains (measObjectEUTRA contains (carrierFreq eq ${earfcn})) and
    ...        reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97)))) and
    ...        measIdToAddModList contains ((measId eq 3) and (measObjectId eq 2) and (reportConfigId eq ${reportConfigId}))
    ...        )
    ...  )
    ...  message_alias=a5_active
    ...  flow_alias=attach_a5_flow

UE Attach to eNB1 Cell1 with QCIx_SBHO eA5 and the deactive due to blind ENDC
    [Arguments]    ${ue_eutra_capabilities}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}    ${ue_id}=1    ${cell_id}=1    ${earfcn}=1600
    ...    ${reportConfigId}=4
    Set UE parameters before attach    ue_id=${ue_id}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measConfig contains (measIdToRemoveList is present))
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=attach_a5_flow    overall_timeout=5
    ${attach_cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities} ue_nr_capabilities=${ue_nr_capabilities} cell=${cell_id}
    Execute Uex Command    ${attach_cmd}
    Flow Occurred As Expected    alias=attach_a5_flow
    verify that message fulfills query
    ...  (
    ...    rrcConnectionReconfiguration  contains (
    ...        measObjectToAddModList  contains (measObjectEUTRA contains (carrierFreq eq ${earfcn})) and
    ...        reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97)))) and
    ...        measIdToAddModList contains ((measId eq 3) and (measObjectId eq 2) and (reportConfigId eq ${reportConfigId}))
    ...        )
    ...  )
    ...  message_alias=a5_active
    ...  flow_alias=attach_a5_flow

Add one NR_PDCP bearer
    [Arguments]    ${ue_id}=1    ${qci}=2    ${reportConfigId}=4
    ${B1_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigInterRAT contains
    ...    (eventB1-NR-r15 contains (b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 56))))
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as B1_active
    ...    alias=ENDC_B1_flow    overall_timeout=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=ENDC_B1_flow
    verify that message fulfills query
    ...  (
    ...    rrcConnectionReconfiguration  contains (
    ...        measObjectToAddModList  contains (measObjectNR-r15 contains (carrierFreq-r15 eq ${NRARFCN630000})) and
    ...        ${B1_query} and
    ...        measIdToAddModList contains ((measId eq 17) and (measObjectId eq 2) and (reportConfigId eq ${reportConfigId}))
    ...        )
    ...  )
    ...  message_alias=B1_active
    ...  flow_alias=ENDC_B1_flow

Setup ENDC with Dynamic B1 report
    [Arguments]    ${ue_id}=1    ${pci}=1
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=ENDC_setup_flow   overall_timeout=5
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${pci} nrsrp=79 nrsrq=66 narfcn=630048
    Flow Occurred As Expected    alias=ENDC_setup_flow

Add one GBR QCIx bearer with QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=2    ${earfcn}=1600
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    alias=GBR_a5_flow  overall_timeout=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=32 mbr_dl=320 gbr_ul=32 gbr_dl=320
    Flow Occurred As Expected    alias=GBR_a5_flow
    verify that message has fields
    ...    measObjectToAddModList..measObjectId eq 4
    ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq ${earfcn}
    ...    reportConfigToAddModList..reportConfigEUTRA..triggerType..event..eventId..eventA5..a5-Threshold1..threshold-RSRP eq 97
    ...    measIdToAddModList..measId eq 3
    ...    measIdToAddModList..measObjectId eq 4
    ...    measIdToAddModList..reportConfigId eq 5
    ...    message_alias=a5_active
    ...    flow_alias=GBR_a5_flow

Add one GBR QCIx bearer without QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=2
    ${no_a5_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_query})
    ...    alias=add_GBR_no_a5_flow  overall_timeout=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=32 mbr_dl=320 gbr_ul=32 gbr_dl=320
    Flow Not Occurred For Message    alias=add_GBR_no_a5_flow

report interFreq A3 measurement report
    [Arguments]    ${ue_id}=1    ${pci}=2    ${earfcn}=1600
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_MeasurementReport (measId eq 14)
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq ${pci}))
    ...    alias=intra_enb_ho1_flow  overall_timeout=2
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A3 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=43 nrsrq=16 earfcn=${earfcn}
    Flow Occurred As Expected    alias=intra_enb_ho1_flow

Add one NR_PDCP bearer QCIx_SBHO eA5 deactive
    [Arguments]    ${ue_id}=1    ${qci}=2
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measConfig contains (measIdToRemoveList is present))
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    alias=bearer_a5_deact_flow    overall_timeout=5
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=bearer_a5_deact_flow

Release NR_PDCP bearer without QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=2
    ${no_a5_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_query})
    ...    alias=rel_bearer_no_a5_flow    overall_timeout=2
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci}
    Flow Not Occurred For Message    alias=rel_bearer_no_a5_flow

trigger UE send A2 Measurement report with eA5 deactivation
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (3))
    ...    alias=a5_deactivate_flow  overall_timeout=10
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34
    Flow Occurred As Expected    alias=a5_deactivate_flow

trigger UE send A2 Measurement report without eA5 deactivation
    [Arguments]    ${ue_id}=1
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (3))
    ...    alias=no_a5_deactivate_flow  overall_timeout=10
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34
    Flow Not Occurred For Message    alias=no_a5_deactivate_flow

Add one NON_GBR QCIx bearer with QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=2        ${earfcn}=1600
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    alias=NBR_a5_flow    overall_timeout=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=NBR_a5_flow
    verify that message has fields
    ...    measObjectToAddModList..measObjectId eq 4
    ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq ${earfcn}
    ...    reportConfigToAddModList..reportConfigEUTRA..triggerType..event..eventId..eventA5..a5-Threshold1..threshold-RSRP eq 97
    ...    measIdToAddModList..measId eq 3
    ...    measIdToAddModList..measObjectId eq 4
    ...    measIdToAddModList..reportConfigId eq 5
    ...    message_alias=a5_active
    ...    flow_alias=NBR_a5_flow

UE attach with eA5 and trigger IFHO to deactive eA5
    [Arguments]    ${ue_id}=1
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5    ${ue_eutra_capab_HO_to_WCDMA_SA}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}
    ...    ue_id=${ue_id}    cell_id=1    reportConfigId=4
    trigger UE send A2 Measurement report with eA5 deactivation   ue_id=${ue_id}
    report interFreq A3 measurement report    ue_id=${ue_id}    pci=3

UE attach setup bearer with eA5 and trigger IFHO to deactive eA5
    [Arguments]    ${ue_id}=1
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capab_HO_to_WCDMA_SA}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}
    ...    ue_id=${ue_id}
    trigger UE send A2 Measurement report without eA5 deactivation   ue_id=${ue_id}
    Add one GBR QCIx bearer without QCIx_SBHO eA5    ue_id=${ue_id}    qci=4

UE attach with eA5 and trigger inter-RAT WCDMA HO to deactive eA5
    [Arguments]    ${ue_id}=1
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5    ${ue_eutra_capab_HO_to_WCDMA_SA}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}
    ...    ue_id=${ue_id}    cell_id=1    reportConfigId=4
    trigger UE send A2 Measurement report with eA5 deactivation   ue_id=${ue_id}

UE attach setup bearer with eA5 and trigger inter-RAT WCDMA HO to deactive eA5
    [Arguments]    ${ue_id}=1
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capab_HO_to_WCDMA_SA}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}
    ...    ue_id=${ue_id}
    trigger UE send A2 Measurement report without eA5 deactivation   ue_id=${ue_id}
    Add one GBR QCIx bearer without QCIx_SBHO eA5    ue_id=${ue_id}    qci=4

UE attach with eA5 and trigger inter-RAT NR HO to deactive eA5
    [Arguments]    ${ue_id}=1
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5    ${ue_eutra_capab_HO_to_WCDMA_SA}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}
    ...    ue_id=${ue_id}    cell_id=1    reportConfigId=4
    trigger UE send A2 Measurement report with eA5 deactivation   ue_id=${ue_id}

UE attach setup bearer with eA5 and trigger NR WCDMA HO to deactive eA5
    [Arguments]    ${ue_id}=1
    UE Attach to eNB1 Cell1 without QCIx_SBHO eA5    ${ue_eutra_capab_HO_to_WCDMA_SA}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}
    ...        ue_id=${ue_id}
    trigger UE send A2 Measurement report without eA5 deactivation   ue_id=${ue_id}
    Add one GBR QCIx bearer without QCIx_SBHO eA5    ue_id=${ue_id}    qci=4

UE Attach with QCI1 SBHO A4 without QCIx SBHO eA5
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${No_QCIx_SBHO_eA5}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${No_QCIx_SBHO_eA5})
    ...    alias=no_a5_flow  overall_timeout=10
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (carrierFreq eq 38000)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (reportConfigId eq 4 and a4-Threshold contains (threshold-RSRP eq 0))
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 31 and measObjectId eq 2 and reportConfigId eq 4)
    ${QCI1_SBHO_A4}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToAddModList}) and
    ...    (s-Measure eq 0) and (measGapConfig contains (gapOffset is present))
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${QCI1_SBHO_A4})
    ...    alias=QCI1_SBHO_a4_flow  overall_timeout=10
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Not Occurred For Message    alias=no_a5_flow
    Flow Occurred As Expected    alias=QCI1_SBHO_a4_flow

UE Attach with QCI1 SBHO A4
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (carrierFreq eq 38000)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (reportConfigId eq 4 and a4-Threshold contains (threshold-RSRP eq 0))
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 31 and measObjectId eq 2 and reportConfigId eq 4)
    ${QCI1_SBHO_A4}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToAddModList}) and
    ...    (s-Measure eq 0) and (measGapConfig contains (gapOffset is present))
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${QCI1_SBHO_A4})
    ...    alias=QCI1_SBHO_a4_flow  overall_timeout=2
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=QCI1_SBHO_a4_flow

Add QCIx bearer without QCIx_SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=4
    ${No_QCIx_SBHO_eA5}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${No_QCIx_SBHO_eA5})
    ...    alias=no_a5_flow  overall_timeout=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=32 mbr_dl=320 gbr_ul=32 gbr_dl=320
    Flow Not Occurred For Message    alias=no_a5_flow

Release QCI1 bearer to trigger QCIx SBHO eA5
    [Arguments]    ${ue_id}=1    ${qci}=1
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (measObjectId eq 3 and carrierFreq eq 1600)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97) and
    ...    a5-Threshold2 contains (threshold-RSRP eq 0)))
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 3 and measObjectId eq 3 and reportConfigId eq 5)
    ${measIdToRemoveList}    catenate
    ...    measIdToRemoveList contains (31)
    ${Expect_Message_Flow}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToAddModList}) and (${measIdToRemoveList})
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${Expect_Message_Flow})
    ...    alias=a5_activate_flow  overall_timeout=10
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=a5_activate_flow

UE Attach with QCIx SBHO eA5
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 1600)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97) and
    ...    a5-Threshold2 contains (threshold-RSRP eq 0)))
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 3 and measObjectId eq 2 and reportConfigId eq 4)
    ${Expect_Message_Flow}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToAddModList}) and
    ...    (s-Measure eq 0) and (measGapConfig contains (gapOffset is present))
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${Expect_Message_Flow})
    ...    alias=a5_activate_flow  overall_timeout=2
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=a5_activate_flow

Add QCI1 bearer to deactivate QCIx SBHO eA5
    [Arguments]    ${ue_id}=1
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (measObjectId eq 3 and carrierFreq eq 38000)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (reportConfigId eq 5 and a4-Threshold contains (threshold-RSRP eq 0))
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 31 and measObjectId eq 3 and reportConfigId eq 5)
    ${measIdToRemoveList}    catenate
    ...    measIdToRemoveList contains (3)
    ${QCI1_SBHO_A4}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToAddModList}) and (${measIdToRemoveList})
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${QCI1_SBHO_A4})
    ...    alias=QCI1_SBHO_a4_flow  overall_timeout=10
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred As Expected    alias=QCI1_SBHO_a4_flow

Set UE parameters before attach
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_mme_param id=${ue_id} spid=1
	Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms
    Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=${ue_id} nr_supported_bands=78,77
    Execute Egate Command    gnb_endc_param id=2 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=3 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=2 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=3 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=2 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=3 include_reestablish_pdcp=on
