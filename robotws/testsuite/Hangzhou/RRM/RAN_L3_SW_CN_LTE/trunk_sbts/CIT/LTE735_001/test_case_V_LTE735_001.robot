*** Setting ***
Documentation     \##################################################################################################################################
...                   #####################################
...
...               * Test Case * Instance Instance_ulm delta preparation Re-establishment script setup cell cell HO
...               Instance_01 RRC Connection Re-establishment during Ue capability enquiry with cause other failure, wrong short MAC-Id, Re-establish
...               ment silently ignored 1 3 not_applic prepared Lte_Re-establishment_UeCapabilityEnquiry_othFail_with_wrong_MAC-I.txt not_ap cell12 -
...               100 not_ap
...               Instance_02 RRC Connection Re-establishment during Attach with cause other failure, Re-establishment rejected 2 4 not_applic prepar
...               ed Lte_Re-establishment_RRCConnectionRecon_attach.txt not_ap cell12 -100 not_ap
...               Instance_03 spontaneous re-establishment to intra-eNB neighbor cell, wrong short MAC-Id, re-establishment silently ignored 3 5 CQI_
...               sensit spontaneous Lte_Re-establishment_spontaneous_HoFail_with_wrong_MAC-I.txt QCI1+5 cell12 -70 not_ap
...               Instance_04 RRC Connection Re-establishment during emergency bearer setup, cause reconfiguration failure, re-establishment rejected
...               4 8 not_applic prepared Lte_Re-establishment_RRCConnectionRecon_bearer_setup_recFail_0.txt QCI1+5em cell12 -100 not_ap
...               Instance_05 RRC Connection Re-establishment during intra-cell HO, cause other failure, re-establishment successful 5 9 not_applic p
...               repared Lte_Re-establishment_RRCConnectionRecon_with_mob_othFail_0.txt QCI1+5em cell12 -100 applicable

Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4A_CUS
...               owner-kang.xiang    release-RL25    team-SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
${ue_eutra_capabilities_for_LTE735}    819FF030030804081705C177E0C1880000
@{Delete_Neighbour_Relation}
...  delete:LNADJ.*
...  delete:LNREL.*
...  delete:LNHO.*
@{deltaSCFC_setup}
...  LNBTS-1:actRLFbasedRCR=true
...  LNBTS-1:actFlexQCIARPPMProfiles=true
...  LNCEL-1/SIB-0:t301=400ms
...  LNCEL-1/SIB-0:t310=200ms
...  LNBTS-1/LNBTS_FDD-0:actIMSEmerSessR9=true
...  LNBTS-1/LNBTS_FDD-0:actHighPrioServices=true
...  LNCEL-1:tPageCorrInt=3000
...  LNCEL-2:tPageCorrInt=3000
...  LNCEL-3:tPageCorrInt=3000
...  LNBTS-1:moProfileSelect=spid
...  delete:LNCEL-1:moPrMappingList
...  delete:LNCEL-2:moPrMappingList
...  LNCEL-1:actNbrForNonGbrBearers=true
...  LNCEL-1:ulsFdPrbAssignAlg=MixedFD
...  LNCEL-1:maxPrbsPerNbrUe=90
...  LNCEL-1:maxNbrTrafficLimit=90
...  LNCEL-1:nbrCongHandling=false
...  LNCEL-1:threshold2GERAN=65
...  LNCEL-1:threshold2Wcdma=65
...  LNCEL-2:actNbrForNonGbrBearers=true
...  LNCEL-2:ulsFdPrbAssignAlg=MixedFD
...  LNCEL-2:maxPrbsPerNbrUe=90
...  LNCEL-2:maxNbrTrafficLimit=90
...  LNCEL-2:nbrCongHandling=false
...  LNCEL-2:threshold2GERAN=65
...  LNCEL-2:threshold2Wcdma=65
...  LNCEL-1:dlsPdschNbrCongDetAct=false
...  LNCEL-1:ulsPuschNbrCongDetAct=false
...  LNCEL-1:pdcchCongDetActDl=false
...  LNCEL-1:pdcchCongDetActUl=false
...  LNCEL-2:dlsPdschNbrCongDetAct=false
...  LNCEL-2:ulsPuschNbrCongDetAct=false
...  LNCEL-2:pdcchCongDetActDl=false
...  LNCEL-2:pdcchCongDetActUl=false
...  LNBTS-1/MODPR-0:autoAdapt=false
...  LNBTS-1/MODPR-0:autoAdaptIMLB=false
...  LNBTS-1/MODPR-0:idleLBPercentageOfUes=0
...  LNBTS-1/MODPR-0:idleLBPercCaUe=0
...  LNBTS-1/MODPR-0:targetSelMethod=SIB_based
...  LNBTS-1/MODPR-0:freqLayListLte=300,3000,2100
...  LNBTS-1/MODPR-0:freqLayListSrvccWcdma=9842
...  LNBTS-1/MODPR-0:freqLayListPsHoWcdma=9842
...  LNBTS-1/MODPR-0:refFreqListNaccGeran:bandIndicator=dcs1800|referenceARFCN=10
...  LNBTS-1/MODPR-0:refFreqListSrvccGsm:bandIndicator=dcs1800|referenceARFCN=10
...  LNCEL-1/SIB-0:t311=3000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
...  LNBTS-1:tS1RelPrepU=1000
...  LNBTS-1:tS1RelPrepG=1000
...  LNCEL-2/SIB-0:t301=2000ms
...  LNCEL-2/SIB-0:t311=3000ms
...  LNCEL-2:t304InterRAT=500ms
...  LNCEL-2:t304InterRATGsm=500ms
...  LNBTS-1/LNADJW-0:uTargetScFdd=110
...  LNBTS-1/LNADJW-0:uTargetCid=1
...  LNBTS-1/LNADJW-0:uTargetFreq=10592
...  LNBTS-1/LNADJW-0:uTargetLac=1
...  LNBTS-1/LNADJW-0:uTargetRncId=1
...  LNBTS-1/LNADJW-0:uTargetRac=1
...  LNBTS-1/LNADJW-0:srvccHoInd=PSandCS
...  LNBTS-1/LNADJW-0:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-0:primaryPlmnId:mnc=3
...  LNBTS-1/LNADJW-0:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-1:uTargetScFdd=220
...  LNBTS-1/LNADJW-1:uTargetCid=2
...  LNBTS-1/LNADJW-1:uTargetFreq=9692
...  LNBTS-1/LNADJW-1:uTargetLac=1
...  LNBTS-1/LNADJW-1:uTargetRncId=1
...  LNBTS-1/LNADJW-1:uTargetRac=1
...  LNBTS-1/LNADJW-1:srvccHoInd=PSandCS
...  LNBTS-1/LNADJW-1:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-1:primaryPlmnId:mnc=3
...  LNBTS-1/LNADJW-1:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-2:uTargetScFdd=230
...  LNBTS-1/LNADJW-2:uTargetCid=3
...  LNBTS-1/LNADJW-2:uTargetFreq=9842
...  LNBTS-1/LNADJW-2:uTargetLac=2
...  LNBTS-1/LNADJW-2:uTargetRncId=2
...  LNBTS-1/LNADJW-2:uTargetRac=2
...  LNBTS-1/LNADJW-2:srvccHoInd=PSandCS
...  LNBTS-1/LNADJW-2:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-2:primaryPlmnId:mnc=3
...  LNBTS-1/LNADJW-2:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-3:uTargetScFdd=340
...  LNBTS-1/LNADJW-3:uTargetCid=4
...  LNBTS-1/LNADJW-3:uTargetFreq=1192
...  LNBTS-1/LNADJW-3:uTargetLac=3
...  LNBTS-1/LNADJW-3:uTargetRncId=3
...  LNBTS-1/LNADJW-3:uTargetRac=3
...  LNBTS-1/LNADJW-3:srvccHoInd=CSonly
...  LNBTS-1/LNADJW-3:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-3:primaryPlmnId:mnc=3
...  LNBTS-1/LNADJW-3:primaryPlmnId:mncLength=2
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-0:utranLbAllowed=false
...  LNCEL-1/LNRELW-0:nrControl=automatic
...  LNCEL-1/LNRELW-0:psHoAllowed=allowed
...  LNCEL-1/LNRELW-0:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-0:removeAllowed=true
...  LNCEL-1/LNRELW-0:srvccAllowed=allowed
...  LNCEL-1/LNRELW-0:uTargetCid=1
...  LNCEL-1/LNRELW-0:uTargetRncId=1
...  LNCEL-1/LNRELW-0:plmnId:mcc=262
...  LNCEL-1/LNRELW-0:plmnId:mnc=3
...  LNCEL-1/LNRELW-0:plmnId:mncLength=2
...  LNCEL-1/LNRELW-1:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-1:utranLbAllowed=false
...  LNCEL-1/LNRELW-1:nrControl=automatic
...  LNCEL-1/LNRELW-1:psHoAllowed=allowed
...  LNCEL-1/LNRELW-1:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-1:removeAllowed=true
...  LNCEL-1/LNRELW-1:srvccAllowed=allowed
...  LNCEL-1/LNRELW-1:uTargetCid=2
...  LNCEL-1/LNRELW-1:uTargetRncId=1
...  LNCEL-1/LNRELW-1:plmnId:mcc=262
...  LNCEL-1/LNRELW-1:plmnId:mnc=3
...  LNCEL-1/LNRELW-1:plmnId:mncLength=2
...  LNCEL-1/LNRELW-2:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-2:utranLbAllowed=false
...  LNCEL-1/LNRELW-2:nrControl=automatic
...  LNCEL-1/LNRELW-2:psHoAllowed=allowed
...  LNCEL-1/LNRELW-2:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-2:removeAllowed=true
...  LNCEL-1/LNRELW-2:srvccAllowed=allowed
...  LNCEL-1/LNRELW-2:uTargetCid=3
...  LNCEL-1/LNRELW-2:uTargetRncId=2
...  LNCEL-1/LNRELW-2:plmnId:mcc=262
...  LNCEL-1/LNRELW-2:plmnId:mnc=3
...  LNCEL-1/LNRELW-2:plmnId:mncLength=2
...  LNCEL-1/LNRELW-3:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-3:utranLbAllowed=false
...  LNCEL-1/LNRELW-3:nrControl=automatic
...  LNCEL-1/LNRELW-3:psHoAllowed=allowed
...  LNCEL-1/LNRELW-3:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-3:removeAllowed=true
...  LNCEL-1/LNRELW-3:srvccAllowed=allowed
...  LNCEL-1/LNRELW-3:uTargetCid=4
...  LNCEL-1/LNRELW-3:uTargetRncId=3
...  LNCEL-1/LNRELW-3:plmnId:mcc=262
...  LNCEL-1/LNRELW-3:plmnId:mnc=3
...  LNCEL-1/LNRELW-3:plmnId:mncLength=2
...  LNCEL-2/LNRELW-2:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-2:utranLbAllowed=false
...  LNCEL-2/LNRELW-2:nrControl=automatic
...  LNCEL-2/LNRELW-2:psHoAllowed=allowed
...  LNCEL-2/LNRELW-2:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-2:removeAllowed=true
...  LNCEL-2/LNRELW-2:srvccAllowed=allowed
...  LNCEL-2/LNRELW-2:uTargetCid=3
...  LNCEL-2/LNRELW-2:uTargetRncId=2
...  LNCEL-2/LNRELW-2:plmnId:mcc=262
...  LNCEL-2/LNRELW-2:plmnId:mnc=3
...  LNCEL-2/LNRELW-2:plmnId:mncLength=2
...  LNBTS-1/LNADJG-0:arfcnValueGeran=10
...  LNBTS-1/LNADJG-0:bandIndicatorGeran=dcs1800
...  LNBTS-1/LNADJG-0:basestationColourCode=1
...  LNBTS-1/LNADJG-0:gTargetCi=1
...  LNBTS-1/LNADJG-0:dtm=false
...  LNBTS-1/LNADJG-0:gTargetLac=1
...  LNBTS-1/LNADJG-0:networkColourCode=1
...  LNBTS-1/LNADJG-0:networkControlOrder=NC0
...  LNBTS-1/LNADJG-0:systemInfoType=none
...  LNBTS-1/LNADJG-0:mcc=262
...  LNBTS-1/LNADJG-0:mnc=3
...  LNBTS-1/LNADJG-0:mncLength=2
...  delete:LNBTS-1/LNADJG-0:gTargetRac
...  LNCEL-1/LNRELG-0:ci=1
...  LNCEL-1/LNRELG-0:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-0:lac=1
...  LNCEL-1/LNRELG-0:nrControl=automatic
...  LNCEL-1/LNRELG-0:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELG-0:srvccAllowed=allowed
...  LNCEL-1/LNRELG-0:plmnId:mcc=262
...  LNCEL-1/LNRELG-0:plmnId:mnc=3
...  LNCEL-1/LNRELG-0:plmnId:mncLength=2
...  LNCEL-2/LNRELG-0:ci=1
...  LNCEL-2/LNRELG-0:eNACCAllowed=allowed
...  LNCEL-2/LNRELG-0:lac=1
...  LNCEL-2/LNRELG-0:nrControl=automatic
...  LNCEL-2/LNRELG-0:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELG-0:srvccAllowed=allowed
...  LNCEL-2/LNRELG-0:plmnId:mcc=262
...  LNCEL-2/LNRELG-0:plmnId:mnc=3
...  LNCEL-2/LNRELG-0:plmnId:mncLength=2
...  LNCEL-1/LNHOIF-1:eutraCarrierInfo=2100
...  LNCEL-1/LNHOIF-1:measQuantInterFreq=rsrp
...  LNCEL-1/LNHOIF-2:eutraCarrierInfo=300
...  LNCEL-1/LNHOIF-2:measQuantInterFreq=both
...  LNCEL-1/LNHOIF-2:a3OffsetRsrqInterFreq=10
...  LNCEL-1/LNHOIF-3:eutraCarrierInfo=3000
...  LNCEL-1/LNHOIF-3:measQuantInterFreq=rsrp
...  LNCEL-1/LNHOW-0:reportIntervalUtra=2048ms
...  LNCEL-1/LNHOW-0:maxNumCsfbTargets=16
...  LNCEL-1/LNHOW-0:hysB1ThresholdCSFBUtra=0
...  LNCEL-1/LNHOW-0:hysB2ThresholdUtra=0
...  LNCEL-1/LNHOW-0:b2Threshold1Utra=57
...  LNCEL-1/LNHOW-0:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-1/LNHOW-0:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-1/LNHOW-0:utraCarrierFreq=10592
...  LNCEL-1/LNHOW-0:offsetFreqUtra=0
...  LNCEL-1/LNHOW-0:b2Threshold2UtraRscp=60
...  LNCEL-1/LNHOW-1:reportIntervalUtra=2048ms
...  LNCEL-1/LNHOW-1:maxNumCsfbTargets=16
...  LNCEL-1/LNHOW-1:hysB1ThresholdCSFBUtra=0
...  LNCEL-1/LNHOW-1:hysB2ThresholdUtra=0
...  LNCEL-1/LNHOW-1:b2Threshold1Utra=57
...  LNCEL-1/LNHOW-1:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-1/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-1/LNHOW-1:utraCarrierFreq=9692
...  LNCEL-1/LNHOW-1:offsetFreqUtra=0
...  LNCEL-1/LNHOW-1:b2Threshold2UtraRscp=60
...  LNCEL-1/LNHOW-2:reportIntervalUtra=2048ms
...  LNCEL-1/LNHOW-2:maxNumCsfbTargets=16
...  LNCEL-1/LNHOW-2:hysB1ThresholdCSFBUtra=0
...  LNCEL-1/LNHOW-2:hysB2ThresholdUtra=0
...  LNCEL-1/LNHOW-2:b2Threshold1Utra=57
...  LNCEL-1/LNHOW-2:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-1/LNHOW-2:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-1/LNHOW-2:utraCarrierFreq=9842
...  LNCEL-1/LNHOW-2:offsetFreqUtra=0
...  LNCEL-1/LNHOW-2:b2Threshold2UtraRscp=60
...  LNCEL-1/LNHOW-3:reportIntervalUtra=2048ms
...  LNCEL-1/LNHOW-3:maxNumCsfbTargets=16
...  LNCEL-1/LNHOW-3:hysB1ThresholdCSFBUtra=0
...  LNCEL-1/LNHOW-3:hysB2ThresholdUtra=0
...  LNCEL-1/LNHOW-3:b2Threshold1Utra=57
...  LNCEL-1/LNHOW-3:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-1/LNHOW-3:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-1/LNHOW-3:utraCarrierFreq=1192
...  LNCEL-1/LNHOW-3:offsetFreqUtra=0
...  LNCEL-1/LNHOW-3:b2Threshold2UtraRscp=60
...  LNCEL-1/LNHOG-0:bandIndicatorGERAN=dcs1800
...  LNCEL-1/LNHOG-0:reportIntervalGERAN=480ms
...  LNCEL-1/LNHOG-0:nccperm=0
...  LNCEL-1/LNHOG-0:hysB2ThresholdGERAN=4
...  LNCEL-1/LNHOG-0:b2Threshold2RssiGERAN=15
...  LNCEL-1/LNHOG-0:b2TimeToTriggerGERANMeas=512ms
...  LNCEL-1/LNHOG-0:b2Threshold1GERAN=41
...  LNCEL-1/LNHOG-0:arfcnValueListGERAN=10
...  LNCEL-2/LNHOW-2:reportIntervalUtra=2048ms
...  LNCEL-2/LNHOW-2:maxNumCsfbTargets=16
...  LNCEL-2/LNHOW-2:hysB1ThresholdCSFBUtra=0
...  LNCEL-2/LNHOW-2:hysB2ThresholdUtra=0
...  LNCEL-2/LNHOW-2:b2Threshold1Utra=57
...  LNCEL-2/LNHOW-2:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-2/LNHOW-2:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-2/LNHOW-2:utraCarrierFreq=9842
...  LNCEL-2/LNHOW-2:offsetFreqUtra=0
...  LNCEL-2/LNHOW-2:b2Threshold2UtraRscp=60
...  LNCEL-2/LNHOG-0:bandIndicatorGERAN=dcs1800
...  LNCEL-2/LNHOG-0:reportIntervalGERAN=480ms
...  LNCEL-2/LNHOG-0:nccperm=0
...  LNCEL-2/LNHOG-0:hysB2ThresholdGERAN=4
...  LNCEL-2/LNHOG-0:b2Threshold2RssiGERAN=15
...  LNCEL-2/LNHOG-0:b2TimeToTriggerGERANMeas=512ms
...  LNCEL-2/LNHOG-0:b2Threshold1GERAN=41
...  LNCEL-2/LNHOG-0:arfcnValueListGERAN=10
@{deltaSCFC_other}
...  LNBTS-1:actERabModify=true
...  LNBTS-1:actHOtoWcdma=true
...  LNBTS-1:actLTES1Ho=true
...  LNBTS-1:actMultBearers=true
...  LNBTS-1:actEnhAcAndGbrServices=true
...  LNBTS-1:actMultGbrBearers=true
...  LNBTS-1:actNonGbrServiceDiff=true
...  LNBTS-1:actS1OlHandling=true
...  LNBTS-1:act8EpsBearers=true
...  LNBTS-1:actOperatorQCIGBR=true
...  LNBTS-1:actOperatorQCI=true
...  LNBTS-1:actS1Flex=enabled
...  LNBTS-1:actCiphering=true
...  LNBTS-1:actIfHo=enabled
...  LNBTS-1:prioTopoHO=all equal
...  LNBTS-1:actRedirect=disabled
...  LNBTS-1:geranDtmCap=true
...  LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...  LNBTS-1:actQCIPLMNIDProfiles=false
...  LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=380
...  LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=380
...  LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=380
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB4
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB6
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB7
...  LNCEL-2/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB4
...  LNCEL-2/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...  LNCEL-2/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB6
...  LNCEL-2/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB7
...  LNCEL-2/IAFIM-1:intrFrBCList:startIntraPci=120
...  LNCEL-2/IRFIM-1:dlCarFrqEut=2100
...  LNCEL-2/GFIM-1:tResGer=1
...  LNCEL-2/UFFIM-1:tResUtra=7
...  LNCEL-2:a2TimeToTriggerActWcdmaMeas=0ms
@{RIM}
...  RIM-0:nRimRirU=1
...  RIM-0:nRimRirG=3
...  RIM-0:tRimPollG=150
...  RIM-0:tRimPollU=14400
...  RIM-0:tRimKaG=150
...  RIM-0:tRimKaU=14400
...  RIM-0:tRimRirG=5
...  RIM-0:tRimRirU=15
...  RIM-0:goodRadioCondForCsfbThres=-100
@{add_REDRT}
...  LNCEL-1/REDRT-0:redirFreqUtra=10592
...  LNCEL-1/REDRT-0:redirRat=utraFDD
...  LNCEL-1/REDRT-0:csFallBPrio=1
...  LNCEL-1/REDRT-0:emerCallPrio=3
...  LNCEL-1/REDRT-0:redirectPrio=4
...  LNCEL-1/REDRT-0:addUtranSIToRedirMsg=both
...  LNCEL-1/REDRT-1:redirFreqUtra=10572
...  LNCEL-1/REDRT-1:redirRat=utraFDD
...  LNCEL-1/REDRT-1:csFallBPrio=2
...  LNCEL-1/REDRT-1:emerCallPrio=2
...  LNCEL-1/REDRT-1:redirectPrio=3
...  LNCEL-1/REDRT-1:addUtranSIToRedirMsg=both
...  LNCEL-1/REDRT-2:redirGeranBandIndicator=gsm1800
...  LNCEL-1/REDRT-2:redirRat=geran
...  LNCEL-1/REDRT-2:addGsmSIToRedirMsg=both
...  LNCEL-1/REDRT-2:addUtranSIToRedirMsg=both
...  LNCEL-1/REDRT-2:csFallBPrio=3
...  LNCEL-1/REDRT-2:emerCallPrio=1
...  LNCEL-1/REDRT-2:redirectPrio=2
...  LNCEL-1/REDRT-2:redirGeranArfcnStructL:redirGeranArfcnPrio=2|redirGeranArfcnValue=688
...  LNCEL-1/REDRT-2:redirGeranArfcnStructL:redirGeranArfcnPrio=1|redirGeranArfcnValue=680
...  LNCEL-1/REDRT-3:redirFreqEutra=2100
...  LNCEL-1/REDRT-3:redirRat=eutra
...  LNCEL-1/REDRT-3:addGsmSIToRedirMsg=both
...  LNCEL-1/REDRT-3:addUtranSIToRedirMsg=both
...  LNCEL-1/REDRT-3:redirectPrio=1
...  LNCEL-1/REDRT-3:csFallBPrio=${empty}
...  LNCEL-1/REDRT-3:emerCallPrio=${empty}
...  LNCEL-1/REDRT-4:redirRat=cdma20001xRTT
...  LNCEL-1/REDRT-4:redirectPrio=5
...  LNCEL-1/REDRT-4:redirBandCdma=bc1
...  LNCEL-1/REDRT-4:redirFreqCdma=222
...  LNCEL-1/REDRT-5:redirRat=cdma2000HRPD
...  LNCEL-1/REDRT-5:redirectPrio=6
...  LNCEL-1/REDRT-5:redirBandCdma=bc1
...  LNCEL-1/REDRT-5:redirFreqCdma=333
...  LNCEL-1/REDRT-5:csFallBPrio=5
...  LNCEL-1/REDRT-5:emerCallPrio=5
@{PARAMS_FOR_PMQAP}
...  MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
...  LNBTS-1/PMRNL-1:mtERABPMQAPProfile=15min
...  LNBTS-1:actRtPerfMonitoring=false
...  LNBTS-1/PMRNL-1/PMQAP-1:cfgQCIRange=1
...  LNBTS-1/PMRNL-1/PMQAP-1:cfgPRI=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-1:cfgARPRange=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-1:cfgUECategory=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-1:pLMNID=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-5:cfgQCIRange=5
...  LNBTS-1/PMRNL-1/PMQAP-5:cfgPRI=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-5:cfgARPRange=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-5:cfgUECategory=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-5:pLMNID=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-6:cfgQCIRange=6
...  LNBTS-1/PMRNL-1/PMQAP-6:cfgPRI=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-6:cfgARPRange=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-6:cfgUECategory=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-6:pLMNID=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-7:cfgQCIRange=7
...  LNBTS-1/PMRNL-1/PMQAP-7:cfgPRI=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-7:cfgARPRange=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-7:cfgUECategory=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-7:pLMNID=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-8:cfgQCIRange=8
...  LNBTS-1/PMRNL-1/PMQAP-8:cfgPRI=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-8:cfgARPRange=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-8:cfgUECategory=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-8:pLMNID=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-9:cfgQCIRange=9
...  LNBTS-1/PMRNL-1/PMQAP-9:cfgPRI=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-9:cfgARPRange=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-9:cfgUECategory=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-9:pLMNID=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-11:cfgQCIRange=1
...  LNBTS-1/PMRNL-1/PMQAP-11:cfgPRI=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-11:cfgARPRange=1
...  LNBTS-1/PMRNL-1/PMQAP-11:cfgUECategory=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-11:pLMNID=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-15:cfgQCIRange=5
...  LNBTS-1/PMRNL-1/PMQAP-15:cfgPRI=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-15:cfgARPRange=1
...  LNBTS-1/PMRNL-1/PMQAP-15:cfgUECategory=${empty}
...  LNBTS-1/PMRNL-1/PMQAP-15:pLMNID=${empty}
@{deltaSCFC_instance_03}
...  LNBTS-1:nCqiDtx=1
...  LNBTS-1:nCqiRec=8
...  LNCEL-1:cqiAperEnable=false
@{deltaSCFC_instance_03_recover}
...  LNBTS-1:nCqiDtx=100
...  LNBTS-1:nCqiRec=2
...  LNCEL-1:cqiAperEnable=true
@{Eliminate_relation_error}
...  delete:LNCEL:defaultLnRelGnbCellId
...  LNCEL:t301Guard=390
@{PARAMS_IN_SCF}
...  @{deltaSCFC_setup}
...  @{deltaSCFC_other}
...  @{add_REDRT}
...  @{PARAMS_FOR_PMQAP}
...  @{RIM}
...  @{Delete_Neighbour_Relation}
...  @{Eliminate_relation_error}
#${TTITRACE_FLAG}    ${False}

*** Test Case ***
LTE735_001_Instance_04_RRC_Connection_Re-establishment_during_emergency_bearer_setup_cause_reconfiguration_failure_re-establishment_rejected
    [Tags]
    Start Rtpm Counter
    UE Attach With Default Bearer QCI_6  uecapability_for_LTE735=${ue_eutra_capabilities_for_LTE735}  UE_ID_FOR_LTE735=4
    Prepare Reestablish    UE_ID_FOR_LTE735=4    trigger_precontion=eps-BearerIdentity    reestablish_cause=reconfigurationFailure
    Steup Dedicated Bearer QCI_5_Emergancy    UE_ID_FOR_LTE735=4    #waiting_string_for_Bearer_setup=UEContextReleaseComplete
    Execute Uex Command     ue_detach id=4
    Check Rtpm Counters    pm_reference_file=${CURDIR}${/}Instance4${/}reference_PM.txt

*** Keyword ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Execute Egate Command    trace_sim on mme=1 protocol=s1

Modify Yaml
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'emergency.nsn.com'
    ...    emergency: 'on'
    Update Yaml    UEs/bearer_sets/bearer_set_1/1    qci: 6
    Update Yaml    UEs/bearer_sets/bearer_set_1/7    qci: 8
    Update Yaml    UEs/bearer_sets/bearer_set_1/12    qci: 5  default: on  pdn: 3  trf_type: external  priority: 1  preemption: off
    Update Yaml    UEs/bearer_sets/bearer_set_1/13    qci: 1  gbr_ul: 31  gbr_dl: 31  mbr_ul:31  mbr_dl: 31  pdn: 3
    ...    priority: 1  preemption: off

UE Attach With Default Bearer QCI_6
    [Arguments]  ${uecapability_for_LTE735}  ${UE_ID_FOR_LTE735}=${UE1}  ${spid}=1
    Execute Egate Command    ue_mme_param id=${UE_ID_FOR_LTE735} spid=${spid}
    Execute Egate Command    ue_mme_param id=1 srvcc_operation_possible=yes
    Execute Egate Command    ue_param id=${UE_ID_FOR_LTE735} srvcc=on
    ${V_2}    catenate    ue_attach id=${UE_ID_FOR_LTE735} ue_eutra_capabilities=${uecapability_for_LTE735}
    ...    attach_type=combined srvcc=true cell=1 enb=1
    Execute Uex Command    ${V_2}

Prepare Reestablish
    [Arguments]    ${UE_ID_FOR_LTE735}=${UE1}    ${trigger_precontion}=meas_config    ${reestablish_cause}=handoverFailure
    Execute Uex Command
    ...  ue_rrc_reconf_param id=${UE_ID_FOR_LTE735} if_contains=${trigger_precontion} action=reestablish cause=${reestablish_cause} cell=1 nth=1

Steup Dedicated Bearer QCI_5_Emergancy
    [Arguments]  ${UE_ID_FOR_LTE735}=${UE1}
    Expect Message Flow
    ...    UE_${UE_ID_FOR_LTE735}:RRC_RRCConnectionReestablishmentRequest ( reestablishmentCause eq "reconfigurationFailure")
    ...    UE_${UE_ID_FOR_LTE735}:RRC_RRCConnectionReestablishmentReject
    ...    MME_1:S1AP_UEContextReleaseRequest
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=RcR_reject_flow    overall_timeout=60
    Execute Uex Command And Expect Error    ue_pdn_connect id=${UE_ID_FOR_LTE735} apn=emergency.nsn.com request_type=emergency    timeout
    Flow Occurred As Expected    alias=RcR_reject_flow


# Below kw for debug in the future, so keep in case.
#Modify Lua
#    FOR    ${ue_id_number}    IN RANGE    1    6
#        Set Bearer In Lua    bearer_id=1    ue=${ue_id_number}    default=on    qci=6    ip=1.7.11.1
#        ...    trf_type=internal
#        Set Bearer In Lua    bearer_id=7    ue=${ue_id_number}    qci=8
#        Set Bearer In Lua    bearer_id=10    ue=${ue_id_number}    default=on    qci=1    gbr_ul=31
#        ...    gbr_dl=31    gbr_ul=31    gbr_dl=31    mbr_ul=31    mbr_dl=31
#        ...    pdn=2
#        Set Bearer In Lua    bearer_id=2    ue=${ue_id_number}    qci=1    gbr_ul=31    gbr_dl=31
#        ...    mbr_ul=31    mbr_dl=31
#        Set Bearer In Lua    bearer_id=6    ue=${ue_id_number}    qci=5    gbr_ul=31    gbr_dl=31
#        ...    mbr_ul=31    mbr_dl=31
#    END
#    Set Pgw In Lua    pgw_id=3    pgw_type=simulated    ip=127.0.0.1:10000    apn=ulm_pgw3.net    devtype=tun    devname=tunPGW3
#    ...    addr=3.7.255.254/16    emergency=on
#    Set Bearer In Lua    bearer_id=14    ue=4    qci=5    ip=3.7.11.1    trf_type=internal    default=on
#    ...    pdn=3    priority=1    preemption=off
#    Set Bearer In Lua    bearer_id=15    ue=4    qci=1    gbr_ul=31    gbr_dl=31    mbr_ul=31
#    ...    mbr_dl=31    pdn=3    priority=1    preemption=off
#    Set Bearer In Lua    bearer_id=14    ue=5    qci=5    ip=3.7.11.1    trf_type=internal    default=on
#    ...    pdn=3    priority=1    preemption=off
#    Set Bearer In Lua    bearer_id=15    ue=5    qci=1    gbr_ul=31    gbr_dl=31    mbr_ul=31
#    ...    mbr_dl=31    pdn=3    priority=1    preemption=off

#Steup Dedicated Bearer QCI_1_5
#    [Arguments]    ${UE_ID_FOR_LTE735}=${UE1}
#    Iphy Setup Dedicate Bearer    qci=2    ue_id=${UE_ID_FOR_LTE735}    filter_id=2    precedence_id=2
#    Iphy Setup Dedicate Bearer    qci=6    ue_id=${UE_ID_FOR_LTE735}    filter_id=3    precedence_id=3
#    Delay    delay=1s    #delay for bear setup and next for throughput stable
#
#Trigger CQI DTX
#    [Arguments]    ${UE_ID_FOR_LTE735}
#    Iphy Execute Ue Command Without Kargs    trf_data_start ue=${UE_ID_FOR_LTE735} id=2 dir=dl mbps=10
#    Iphy Execute Ue Command Without Kargs    trf_data_start ue=${UE_ID_FOR_LTE735} id=6 dir=dl mbps=10
#    sleep    5s    #sleep for trf_data stable,it's precondition for CQI disable command
#    Iphy Execute Ue Command Without Kargs    ue_cqi_param id=${UE_ID_FOR_LTE735} disable_cqi_reporting=on    rrcConnectionRelease
#
#Throughput_DL_QCI1
#    [Arguments]    ${UE_ID_FOR_LTE735}    ${delay}
#    Iphy Execute Ue Command Without Kargs    trf_data_start ue=${UE_ID_FOR_LTE735} id=2 dir=dl mbps=10
#    sleep    ${delay}    #delay for UE go to connect state and CQI DTX
#
#Steup Dedicated Bearer QCI_1_Emergancy
#    [Arguments]    ${UE_ID_FOR_LTE735}=${UE1}    ${waiting_string_for_Bearer_setup}=PGW-initiated Bearer Creation
#    Iphy Execute Ue Command Without Kargs    bearer_add ue=${UE_ID_FOR_LTE735} id=15 filter=3 precedence=3    ${waiting_string_for_Bearer_setup}
#
#Delay
#    [Arguments]    ${delay}
#    sleep    ${delay}
#
#Trigger Re-establishment
#    [Arguments]    ${ue_id_LTE735}    ${delay}    ${reestablish_cause}=handoverFailure
#    Iphy Execute Ue Command Without Kargs  ue_rrc_reestablish id=${ue_id_LTE735} cell=2 cause=${reestablish_cause}
#    ...  RRC Reestablishment sucessfully completed
#    sleep    ${delay}    #sleep for CQI trigger if Re-establishment reject
#
#Trigger Intra Cell Ho
#    [Arguments]    ${ue_id_LTE735}    ${delay}    ${waiting_string_for_Intra_Cell_Ho}
#    Iphy Execute Ue Command Without Kargs    ue_reauth id=${ue_id_LTE735}    ${waiting_string_for_Intra_Cell_Ho}
#    sleep    ${delay}    #delay for Re-establishment
#
#Start RTPM And Delta Commission
#    [Arguments]    ${delta_file}
#    Start Rtpm Counter
#    Delta Commission Parameters And Wait Cells Onair    ${delta_file}
#
#Recover Env And Test Teardown
#    [Arguments]    ${UE_ID_FOR_LTE735}=${UE1}    ${trigger_precontion}=meas_config
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_mme_param id=${UE_ID_FOR_LTE735} reset
#    Run Keyword and Ignore Error  Iphy Execute Ue Command Without Kargs
#    ...  ue_param id=${UE_ID_FOR_LTE735} if_rrc_reconf_contains=${trigger_precontion} action=None
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_param id=${UE_ID_FOR_LTE735} reset
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE735} id=2
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE735} id=6
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE735} id=15
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    pdn_disconnect ue=${UE_ID_FOR_LTE735} pdn=3
#    Common Test Teardown And Stop Capture Logs
#
#Recover Env And Test Teardown With Delta Commission
#    [Arguments]    ${UE_ID_FOR_LTE735}    ${delta_file}
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_mme_param id=${UE_ID_FOR_LTE735} reset
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_param id=${UE_ID_FOR_LTE735} reset
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_cqi_param id=${UE_ID_FOR_LTE735} reset
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    trf_data_stop ue=${UE_ID_FOR_LTE735}
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE735} id=2
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE735} id=6
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE735} id=15
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    pdn_disconnect ue=${UE_ID_FOR_LTE735} pdn=3
#    Delta Commission Parameters    ${delta_file}
#    Cells Should Be OnAir    wait_sib=5s
#    Common Test Teardown And Stop Capture Logs
