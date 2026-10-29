*** Setting ***
Documentation     \##################################################################################################################################
...                   #####################################
...
...               * Test Case * Instance setup1 setup2 report failure
...               Instance_01 Successful non emergency SRVCC to WCDMA (CSonly) 1 cbr1_11_15 cbr1_11_15 f4b3pci4 not_applicable
...               Instance_02 Unsuccessful non emergency SRVCC to WCDMA (PSandCS) 2 cbr1_11_15 cbr1_11_15 f3b2pci3 not_applicable
...               Instance_03 Successful emergency SRVCC to WCDMA (CSonly) 3 cbre1_11_15 cbre1_11_15 f4b3pci4 not_applicable
...               Instance_04 Unsuccessful emergency SRVCC to WCDMA (PSandCS) 4 cbre1_11_15 cbre1_11_15 f3b2pci3 not_applicable
...               Instance_05 Successful non emergency PS-HO to WCDMA 5 cbr1_11_78 cbr1_11_78 f4b3pci4 not_applicable
...               Instance_06 Unsuccessful non emergency PS-HO to WCDMA 6 cbr1_11_78 cbr1_11_78 f3b2pci3 not_applicable
...               Instance_07 Successful non emergency PS-HO to WCDMA with QCI1 7 cbr1_11_15 cbr1_11_15 f4b3pci4 not_applicable
...               Instance_08 Unsuccessful non emergency PS-HO to WCDMA with QCI1 8 cbr1_11_15 cbr1_11_15 f3b2pci3 not_applicable
...               Instance_09 Unsuccessful PS-HO to WCDMA preparation, timer expiry 9 cbr1_11_78 cbr1_11_15 f4b3pci4 SGSN_stop

Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4A_CUS
...               owner-kang.xiang    release-RL25    team-SG4
Resource          testsuite/Hangzhou/RRM/RAN_L3_SW_CN_LTE/resources/DevHZ5_resource.robot

*** Variable ***
${ue_eutra_capabilities_for_LTE872}    859FF030030804081705C177FCD9EA0881002208E640
${ue_utra_capabilities_LTE872}    813FF40200189040B82E0BBF868C4000
${ue_geran_cs_capabilities_LTE872}    33035758A6601404EF6513B8878D2920
${ue_geran_ps_capabilities_LTE872}    813FF40200189040B82E0BBF868C4000
@{Delete_Neighbour_Relation}
...  delete:LNADJ.*
...  delete:LNREL.*
...  delete:LNHO.*
@{deltaSCFC_setup}
...  LNBTS-1:acteNACCtoGSM=true
...  LNBTS-1:actFlexQCIARPPMProfiles=true
...  LNBTS-1/LNBTS_FDD-0:actIMSEmerSessR9=true
...  LNBTS-1:moProfileSelect=spid
...  LNCEL-1:moPrMappingList:moPrId=1|spid=1
...  LNCEL-1:moPrMappingList:moPrId=2|spid=2
...  LNCEL-1:moPrMappingList:spidLast=${EMPTY}|spid=1
...  LNCEL-1:moPrMappingList:spidLast=${EMPTY}|spid=2
...  LNCEL-1:threshold2GERAN=62
...  LNCEL-1:threshold2Wcdma=62
...  LNBTS-1/MODPR-0:autoAdapt=false
...  LNBTS-1/MODPR-0:autoAdaptIMLB=false
...  LNBTS-1/MODPR-0:idleLBPercentageOfUes=0
...  LNBTS-1/MODPR-0:idleLBPercCaUe=0
...  LNBTS-1/MODPR-0:targetSelMethod=SIB_based
...  LNBTS-1/MODPR-0:freqLayListLte=300,3000,2100
...  LNBTS-1/MODPR-0:freqLayListSrvccWcdma=9842,1192
...  LNBTS-1/MODPR-0:freqLayListPsHoWcdma=9842,1192
...  LNBTS-1/MODPR-0:refFreqListNaccGeran:bandIndicator=dcs1800|referenceARFCN=10
...  LNBTS-1/MODPR-0:refFreqListNaccGeran:bandIndicator=dcs1800|referenceARFCN=20
...  LNBTS-1/MODPR-0:refFreqListSrvccGsm:bandIndicator=dcs1800|referenceARFCN=10
...  LNBTS-1/MODPR-0:refFreqListSrvccGsm:bandIndicator=dcs1800|referenceARFCN=30
...  LNBTS-1/MODPR-0:refFreqListSrvccGsm:bandIndicator=dcs1800|referenceARFCN=680
...  LNBTS-1/MOPR-1:idleLBPercentageOfUes=0
...  LNBTS-1/MOPR-1:idleLBPercCaUe=0
...  LNBTS-1/MOPR-1:targetSelMethod=SIB_based
...  LNBTS-1/MOPR-1:freqLayListLte=300,3000
...  LNBTS-1/MOPR-1:freqLayListPsHoWcdma=10592,9692,9842
...  LNBTS-1/MOPR-2:idleLBPercentageOfUes=0
...  LNBTS-1/MOPR-2:idleLBPercCaUe=0
...  LNBTS-1/MOPR-2:targetSelMethod=SIB_based
...  LNBTS-1/MOPR-2:freqLayListLte=2100
...  LNBTS-1/MOPR-2:freqLayListSrvccWcdma=9842,1192
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
...  LNBTS-1/LNADJG-1:arfcnValueGeran=20
...  LNBTS-1/LNADJG-1:bandIndicatorGeran=dcs1800
...  LNBTS-1/LNADJG-1:basestationColourCode=1
...  LNBTS-1/LNADJG-1:gTargetCi=2
...  LNBTS-1/LNADJG-1:dtm=false
...  LNBTS-1/LNADJG-1:gTargetLac=1
...  LNBTS-1/LNADJG-1:networkColourCode=1
...  LNBTS-1/LNADJG-1:networkControlOrder=NC0
...  LNBTS-1/LNADJG-1:systemInfoType=none
...  LNBTS-1/LNADJG-1:mcc=262
...  LNBTS-1/LNADJG-1:mnc=3
...  LNBTS-1/LNADJG-1:mncLength=2
...  delete:LNBTS-1/LNADJG-1:gTargetRac
...  LNBTS-1/LNADJG-2:arfcnValueGeran=30
...  LNBTS-1/LNADJG-2:bandIndicatorGeran=dcs1800
...  LNBTS-1/LNADJG-2:basestationColourCode=1
...  LNBTS-1/LNADJG-2:gTargetCi=4
...  LNBTS-1/LNADJG-2:dtm=false
...  LNBTS-1/LNADJG-2:gTargetLac=1
...  LNBTS-1/LNADJG-2:networkColourCode=1
...  LNBTS-1/LNADJG-2:networkControlOrder=NC0
...  LNBTS-1/LNADJG-2:systemInfoType=none
...  LNBTS-1/LNADJG-2:mcc=262
...  LNBTS-1/LNADJG-2:mnc=3
...  LNBTS-1/LNADJG-2:mncLength=2
...  delete:LNBTS-1/LNADJG-2:gTargetRac
...  LNBTS-1/LNADJG-3:arfcnValueGeran=680
...  LNBTS-1/LNADJG-3:bandIndicatorGeran=dcs1800
...  LNBTS-1/LNADJG-3:basestationColourCode=1
...  LNBTS-1/LNADJG-3:gTargetCi=3
...  LNBTS-1/LNADJG-3:dtm=false
...  LNBTS-1/LNADJG-3:gTargetLac=1
...  LNBTS-1/LNADJG-3:networkColourCode=1
...  LNBTS-1/LNADJG-3:networkControlOrder=NC0
...  LNBTS-1/LNADJG-3:systemInfoType=none
...  LNBTS-1/LNADJG-3:mcc=262
...  LNBTS-1/LNADJG-3:mnc=3
...  LNBTS-1/LNADJG-3:mncLength=2
...  delete:LNBTS-1/LNADJG-3:gTargetRac
...  LNCEL-1/LNRELG-0:ci=1
...  LNCEL-1/LNRELG-0:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-0:lac=1
...  LNCEL-1/LNRELG-0:nrControl=automatic
...  LNCEL-1/LNRELG-0:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELG-0:srvccAllowed=allowed
...  LNCEL-1/LNRELG-0:plmnId:mcc=262
...  LNCEL-1/LNRELG-0:plmnId:mnc=3
...  LNCEL-1/LNRELG-0:plmnId:mncLength=2
...  LNCEL-1/LNRELG-1:ci=2
...  LNCEL-1/LNRELG-1:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-1:lac=1
...  LNCEL-1/LNRELG-1:nrControl=automatic
...  LNCEL-1/LNRELG-1:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELG-1:srvccAllowed=allowed
...  LNCEL-1/LNRELG-1:plmnId:mcc=262
...  LNCEL-1/LNRELG-1:plmnId:mnc=3
...  LNCEL-1/LNRELG-1:plmnId:mncLength=2
...  LNCEL-1/LNRELG-2:ci=4
...  LNCEL-1/LNRELG-2:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-2:lac=1
...  LNCEL-1/LNRELG-2:nrControl=automatic
...  LNCEL-1/LNRELG-2:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELG-2:srvccAllowed=allowed
...  LNCEL-1/LNRELG-2:plmnId:mcc=262
...  LNCEL-1/LNRELG-2:plmnId:mnc=3
...  LNCEL-1/LNRELG-2:plmnId:mncLength=2
...  LNCEL-1/LNRELG-3:ci=3
...  LNCEL-1/LNRELG-3:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-3:lac=1
...  LNCEL-1/LNRELG-3:nrControl=automatic
...  LNCEL-1/LNRELG-3:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELG-3:srvccAllowed=allowed
...  LNCEL-1/LNRELG-3:plmnId:mcc=262
...  LNCEL-1/LNRELG-3:plmnId:mnc=3
...  LNCEL-1/LNRELG-3:plmnId:mncLength=2
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
...  LNCEL-1/LNHOG-0:arfcnValueListGERAN=10,20,30
...  LNCEL-1/LNHOG-1:bandIndicatorGERAN=dcs1800
...  LNCEL-1/LNHOG-1:reportIntervalGERAN=480ms
...  LNCEL-1/LNHOG-1:nccperm=0
...  LNCEL-1/LNHOG-1:hysB2ThresholdGERAN=4
...  LNCEL-1/LNHOG-1:b2Threshold2RssiGERAN=15
...  LNCEL-1/LNHOG-1:b2TimeToTriggerGERANMeas=512ms
...  LNCEL-1/LNHOG-1:b2Threshold1GERAN=41
...  LNCEL-1/LNHOG-1:arfcnValueListGERAN=680
@{deltaSCFC_other}
...  LNBTS-1:actERabModify=true
...  LNBTS-1:actEnhAcAndGbrServices=true
...  LNBTS-1:actHOtoWcdma=true
...  LNBTS-1:actLTES1Ho=true
...  LNBTS-1:actMultBearers=true
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
...  LNCEL-1:actNbrForNonGbrBearers=false
...  LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=380
...  LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=380
...  LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=380
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB4
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB6
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB7
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
@{deltaSCFC_instance_01}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNCEL-1/SIB-0:t301=2000ms
...  LNCEL-1/SIB-0:t311=30000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
@{deltaSCFC_instance_02}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNCEL-1/SIB-0:t301=2000ms
...  LNCEL-1/SIB-0:t311=3000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
@{deltaSCFC_instance_03}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNCEL-1/SIB-0:t301=2000ms
...  LNCEL-1/SIB-0:t311=30000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
@{deltaSCFC_instance_04}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNCEL-1/SIB-0:t301=2000ms
...  LNCEL-1/SIB-0:t311=3000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
@{deltaSCFC_instance_05}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNCEL-1/SIB-0:t301=2000ms
...  LNCEL-1/SIB-0:t311=30000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
@{deltaSCFC_instance_06}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNCEL-1/SIB-0:t301=2000ms
...  LNCEL-1/SIB-0:t311=3000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
@{deltaSCFC_instance_07}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=false
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=false
...  LNCEL-1/SIB-0:t301=2000ms
...  LNCEL-1/SIB-0:t311=30000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
@{deltaSCFC_instance_08}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=false
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=false
...  LNCEL-1/SIB-0:t301=2000ms
...  LNCEL-1/SIB-0:t311=3000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
@{deltaSCFC_instance_09}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNCEL-1/SIB-0:t301=2000ms
...  LNCEL-1/SIB-0:t311=3000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
@{PARAMS_IN_SCF}
...  @{deltaSCFC_setup}
...  @{deltaSCFC_other}
...  @{add_REDRT}
...  @{PARAMS_FOR_PMQAP}
...  @{RIM}
${TTITRACE_FLAG}    ${False}

*** Test Case ***
LTE872_001_Instance_05_Successful_non_emergency_PS-HO_to_WCDMA
    [Tags]
    Start RTPM And Delta Commission    delta_file=${deltaSCFC_instance_05}
    UE Attach With Default Bearer QCI_6 And Dedicated QCI_7_8  UE_ID_LTE872=1  uecapability_for_LTE872=${ue_eutra_capabilities_for_LTE872}
    Trriger SRVCC With B2 Report UTRAN  ue_id_for_B2=1
    Execute Uex Command     ue_detach id=1
    UE Attach With Default Bearer QCI_6 And Dedicated QCI_7_8  UE_ID_LTE872=1  uecapability_for_LTE872=${ue_eutra_capabilities_for_LTE872}
    Trriger SRVCC With B2 Report GERAN  ue_id_for_B2=1  #wait_string_for_srvcc=CCO to GERAN completed  phycell_id_for_LTE872=9  arfcn_for_LTE872=10
    Execute Uex Command     ue_detach id=1
    Check Rtpm Counters    pm_reference_file=${CURDIR}${/}Instance5${/}reference_PM.txt

*** Keyword ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Execute Egate Command    trace_sim on mme=1 protocol=s1

Modify Yaml
    Add Yaml      EPC/RNC
    ...    - id: 1
    ...    host_enb: 4
    ...    rnc_id: 1
    ...    lac: 1
    ...    plmn: '262:03'
    Add Yaml      EPC/RNC
    ...    - id: 2
    ...    host_enb: 5
    ...    rnc_id: 1
    ...    lac: 1
    ...    plmn: '262:03'
    Add Yaml      EPC/RNC
    ...    - id: 3
    ...    host_enb: 6
    ...    rnc_id: 2
    ...    lac: 2
    ...    plmn: '262:03'
    Add Yaml      EPC/RNC
    ...    - id: 4
    ...    host_enb: 7
    ...    rnc_id: 3
    ...    lac: 3
    ...    plmn: '262:03'
    Add Yaml      EPC/RNC
    ...    - id: 5
    ...    host_enb: 3
    ...    rnc_id: 4
    ...    lac: 1
    ...    plmn: '262:03'
    Update Yaml    EPC/MME_POOL_AREA/1    tac_list: 33,1,2,3
    ${rnc1_enb4_CELL1}    catenate    - {id: 41, technology: utran, rnc: 1, uarfcn: '10592:9642',
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 1, rac: 1, pci: '36:2'}
    ${rnc1_enb4_CELL1_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '4:1', earfcn: '1400:19400', eci: '0x0000401'}
    ${rnc1_enb5_CELL2}    catenate    - {id: 52, technology: utran, rnc: 1, uarfcn: '9692:9292',
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 2, rac: 1, pci: '73:1'}
    ${rnc1_enb5_CELL2_LTE}    catenate    - {id: 1, technology: 'lte', tac: 33, pci: '5:2', earfcn: '1400:19400', eci: '0x0000502'}
    ${rnc2_enb6_CELL3}    catenate    - {id: 63, technology: utran, rnc: 1, uarfcn: '9842:9442',
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 3, rac: 2, pci: '76:2'}
    ${rnc2_enb6_CELL3_LTE}    catenate    - {id: 1, technology: 'lte', tac: 33, pci: '6:0', earfcn: '1400:19400', eci: '0x0000603'}
    ${rnc3_enb7_CELL4}    catenate    - {id: 74, technology: utran, rnc: 3, uarfcn: '1192:967',
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 4, rac: 3, pci: '113:1'}
    ${rnc3_enb7_CELL4_LTE}    catenate    - {id: 1, technology: 'lte', tac: 33, pci: '7:1', earfcn: '1400:19400', eci: '0x0000704'}
    ${rnc4_enb3_CELL1}    catenate    - {id: 35, technology: utran, rnc: 4, uarfcn: '10:680',
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 5, rac: 1, pci: '3:0'}
    ${rnc4_enb3_CELL1_LTE}    catenate    - {id: 1, technology: 'lte', tac: 33, pci: '0:0', earfcn: '1400:19400', eci: '0x0000301'}
    Add Yaml    BASE_STATIONS
    ...    - id: 4
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.31'
    ...    enb_id: '0x00004'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc1_enb4_CELL1}
    ...      ${rnc1_enb4_CELL1_LTE}
    Add Yaml    BASE_STATIONS
    ...    - id: 5
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.32'
    ...    enb_id: '0x00005'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc1_enb5_CELL2}
    ...      ${rnc1_enb5_CELL2_LTE}
    Add Yaml    BASE_STATIONS
    ...    - id: 6
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.33'
    ...    enb_id: '0x00006'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc2_enb6_CELL3}
    ...      ${rnc2_enb6_CELL3_LTE}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.34'
    ...    enb_id: '0x00007'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc3_enb7_CELL4}
    ...      ${rnc3_enb7_CELL4_LTE}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.35'
    ...    enb_id: '0x00003'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc4_enb3_CELL1}
    ...      ${rnc4_enb3_CELL1_LTE}
    Update Yaml    UEs/bearer_sets/bearer_set_1/1     qci: 6
    Update Yaml    UEs/bearer_sets/bearer_set_1/7     qci: 8
    Add Yaml      EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'emergency.nsn.com'
    ...    emergency: 'on'

UE Attach With Default Bearer QCI_6
    [Arguments]    ${uecapability_for_LTE872}    ${UE_ID_FOR_LTE872}=${UE1}    ${spid}=1
    Execute Egate Command    ue_mme_param id=${UE_ID_FOR_LTE872} spid=${spid}
    Execute Egate Command    ue_mme_param id=1 srvcc_operation_possible=yes
    Execute Egate Command    ue_param id=${UE_ID_FOR_LTE872} srvcc=on
    ${attach_cmd}    catenate    ue_attach id=${UE_ID_FOR_LTE872} cell=1 ue_eutra_capabilities=${uecapability_for_LTE872}
    ...    ue_utra_capabilities=${ue_utra_capabilities_LTE872} ue_geran_cs_capabilities=${ue_geran_cs_capabilities_LTE872}
    ...    ue_geran_ps_capabilities=${ue_geran_ps_capabilities_LTE872} attach_type=combined srvcc=true
    Execute Uex Command    ${attach_cmd}

UE Attach With Default Bearer QCI_6 And Dedicated QCI_7_8
    [Arguments]  ${uecapability_for_LTE872}  ${UE_ID_LTE872}=${UE1}  ${spid_LTE872}=1
    UE Attach With Default Bearer QCI_6  uecapability_for_LTE872=${uecapability_for_LTE872}  UE_ID_FOR_LTE872=${UE_ID_LTE872}  spid=${spid_LTE872}
    Steup Dedicated Bearer QCI_7_8    UE_ID_FOR_LTE872=${UE_ID_LTE872}

Steup Dedicated Bearer QCI_7_8
    [Arguments]    ${UE_ID_FOR_LTE872}=${UE1}
    Execute Uex Command    bearer_add ue=${UE_ID_FOR_LTE872} qci=8
    Execute Uex Command    bearer_add ue=${UE_ID_FOR_LTE872} qci=7

Trriger SRVCC With B2 Report UTRAN
    [Arguments]  ${ue_id_for_B2}
    Expect Message Flow
    ...    MME_1:S1AP_HandoverRequired (value contains (HandoverType eq "ltetoutran"))
    ...    MME_1:S1AP_HandoverCommand (value contains (HandoverType eq "ltetoutran"))
    ...    UE_${ue_id_for_B2}:RRC_MobilityFromEUTRACommand (handover contains (targetRAT-Type eq "utra"))
    ...    MME_1:S1AP_UEContextReleaseCommand (value contains (Cause contains (radioNetwork eq "successful-handover")))
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=SRVCC_UTRAN_flow    overall_timeout=60
    Execute Uex Command    ue_measurement_send id=${ue_id_for_B2} event=A2 srsrp=0 srsrq=20
    Sleep    1s
    Execute Uex Command    ue_measurement_send id=${ue_id_for_B2} event=B2_UTRA srsrp=65 srsrq=20 phycell_id=340 necn0=10 nrscp=85 arfcn=1192
    Flow Occurred As Expected    alias=SRVCC_UTRAN_flow

Trriger SRVCC With B2 Report GERAN
    [Arguments]  ${ue_id_for_B2}
    Expect Message Flow
    ...    UE_${ue_id_for_B2}:RRC_MobilityFromEUTRACommand (cellChangeOrder contains (targetRAT-Type contains ("geran")))
    ...    MME_1:S1AP_UEContextReleaseCommand (value contains (Cause contains (radioNetwork eq "successful-handover")))
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=SRVCC_GERAN_flow    overall_timeout=20
    ${release_for_coo_cmd}    catenate
    ...    ue_rrc_mobility_from_eutra_param id=${ue_id_for_B2} if_contains=cellChangeOrder action=ue_s1_ctx_release
    ...    cause_rnl=successful_handover delay=100
    Execute Uex Command    ue_measurement_send id=${ue_id_for_B2} event=A2 srsrp=0 srsrq=20
    Run Uex Command    ${release_for_coo_cmd}
    #ue_measurement_send meas_id=6 id=${ue_id_for_B2} srsrp=62 srsrq=20    ${wait_string_for_B2}
    #ue_srvcc id=1 type=geran phycellid=${phycell_id_for_LTE872} arfcn=${arfcn_for_LTE872}  ${wait_string_for_srvcc}
    Execute Uex Command    ue_measurement_send id=${ue_id_for_B2} event=B2_GERAN srsrp=15 srsrq=20 phycell_id=1:1 nrssi=15 arfcn=10
    Flow Occurred As Expected    alias=SRVCC_GERAN_flow

#UE Attach With Default Bearer QCI_6 And Dedicated QCI_1_5
#    [Arguments]  ${uecapability_for_LTE872}  ${UE_ID_LTE872}=${UE1}  ${spid_LTE872}=1
#    UE Attach With Default Bearer QCI_6  uecapability_for_LTE872=${uecapability_for_LTE872}  UE_ID_FOR_LTE872=${UE_ID_LTE872}  spid=${spid_LTE872}
#    Steup Dedicated Bearer QCI_1_5    UE_ID_FOR_LTE872=${UE_ID_LTE872}
#
#Steup Dedicated Bearer QCI_1_5
#    [Arguments]    ${UE_ID_FOR_LTE872}=${UE1}
##    Iphy Setup Dedicate Bearer    qci=2    ue_id=${UE_ID_FOR_LTE872}    filter_id=2    precedence_id=2
##    Iphy Setup Dedicate Bearer    qci=6    ue_id=${UE_ID_FOR_LTE872}    filter_id=3    precedence_id=3
#    Execute Uex Command    bearer_add ue=${ue_id} qci=1
#    Execute Uex Command    bearer_add ue=${ue_id} qci=5

#UE Attach With Default Bearer QCI_6 And Dedicated QCI_1_5_Emergancy
#    [Arguments]  ${uecapability_for_LTE872}  ${UE_ID_LTE872}=${UE1}  ${ue_start_id_LTE872}=${UE1}  ${ue_stop_id_LTE872}=${UE1}  ${spid_LTE872}=1
#    UE Attach With Default Bearer QCI_6  uecapability_for_LTE872=${uecapability_for_LTE872}  UE_ID_FOR_LTE872=${UE_ID_LTE872}
#    ...  ue_start_id=${ue_start_id_LTE872}  ue_stop_id=${ue_stop_id_LTE872}  spid=${spid_LTE872}
#    Steup Dedicated Bearer QCI_1_5_Emergancy    UE_ID_FOR_LTE872=${UE_ID_LTE872}

#Steup Dedicated Bearer QCI_1_5_Emergancy
#    [Arguments]    ${UE_ID_FOR_LTE872}=${UE1}
#    Iphy Execute Ue Command Without Kargs  pdn_connect_ue ue=${UE_ID_FOR_LTE872} pdn=3
#    ...  PDN connectivity procedure for emergency PDN 3 \\(EBI of default bearer \\= 6\\) performed
#    Iphy Setup Dedicate Bearer    qci=15    ue_id=${UE_ID_FOR_LTE872}    filter_id=3    precedence_id=3

Trriger SRVCC With B2 Report UTRAN_Unsuccessful
    [Arguments]  ${ue_id_for_B2}  ${wait_string_for_srvcc}=${empty}  ${wait_string_for_InterRAT_A2}=rrcConnectionReconfigurationComplete
    ...  ${rnc_id_LTE872}=3  ${phycell_id_for_LTE872}=340  ${arfcn_for_LTE872}=1192
    ...  ${T_S1HoSrcContextRelease}=6800  ${ue_ctx_release_cause}=RN_tS1relocoverall_expiry  ${s1_ho_req_ack_delay}=0  ${wait_string_for_B2}=eventB2
    Iphy Execute Ue Command Without Kargs    ue_measurement_send meas_id=7 id=${ue_id_for_B2} srsrp=65 srsrq=20    ${wait_string_for_InterRAT_A2}
    Iphy Execute Ue Command Without Kargs    ue_measurement_send meas_id=6 id=${ue_id_for_B2} srsrp=62 srsrq=20    ${wait_string_for_B2}
    Iphy Execute Ue Command Without Kargs    mme_timer T_S1HoSrcContextRelease=${T_S1HoSrcContextRelease}
    Iphy Execute Ue Command Without Kargs    mme_timer T_UeCtxReleaseCommandDelay=0
    Iphy Execute Ue Command Without Kargs    mme_param id=1 ue_ctx_release_cause=${ue_ctx_release_cause}
    Iphy Execute Ue Command Without Kargs    enb_param id=7 s1_ho_req_ack_delay=${s1_ho_req_ack_delay}
    Iphy Execute Ue Command Without Kargs
    ...  ue_ho id=1 rnc=${rnc_id_LTE872} ho_mode=TO_UTRAN phycell=${phycell_id_for_LTE872} arfcn=${arfcn_for_LTE872}  ${wait_string_for_srvcc}
    ##sleep for Cause : radioNetwork : tS1relocoverall-expiry ##
    sleep    8s
    Iphy Execute Ue Command Without Kargs    mme_param id=1 ue_ctx_release_cause=off

Trriger SRVCC With B2 Report GERAN_Unsuccessful
    [Arguments]  ${ue_id_for_B2}  ${wait_string_for_srvcc}=${empty}  ${wait_string_for_InterRAT_A2}=rrcConnectionReconfigurationComplete
    ...  ${phycell_id_for_LTE872}=9  ${arfcn_for_LTE872}=10  ${T_UeCtxReleaseCommandDelay}=6800
    ...    ${ue_ctx_release_cause}=RN_tS1relocoverall_expiry    ${s1_ho_req_ack_delay}=0    ${wait_string_for_B2}=eventB2
    Iphy Execute Ue Command Without Kargs    ue_measurement_send meas_id=7 id=${ue_id_for_B2} srsrp=65 srsrq=20    ${wait_string_for_InterRAT_A2}
    Iphy Execute Ue Command Without Kargs    ue_measurement_send meas_id=6 id=${ue_id_for_B2} srsrp=62 srsrq=20    ${wait_string_for_B2}
    ##T_S1HoSrcContextRelease=6800 can't take effect in GSM,replaced by T_UeCtxReleaseCommandDelay##
    Iphy Execute Ue Command Without Kargs    mme_timer T_S1HoSrcContextRelease=6800
    Iphy Execute Ue Command Without Kargs    mme_timer T_UeCtxReleaseCommandDelay=${T_UeCtxReleaseCommandDelay}
    Iphy Execute Ue Command Without Kargs    mme_param id=1 ue_ctx_release_cause=${ue_ctx_release_cause}
    Iphy Execute Ue Command Without Kargs    enb_param id=3 s1_ho_req_ack_delay=${s1_ho_req_ack_delay}
    Iphy Execute Ue Command Without Kargs  ue_srvcc id=1 type=geran phycellid=${phycell_id_for_LTE872} arfcn=${arfcn_for_LTE872}
    ...  ${wait_string_for_srvcc}
    ##sleep for Cause : radioNetwork : tS1relocoverall-expiry ##
    sleep    8s
    Iphy Execute Ue Command Without Kargs    mme_param id=1 ue_ctx_release_cause=off

Start RTPM And Delta Commission
    [Arguments]    ${delta_file}
    Start Rtpm Counter
    Delta Commission Parameters And Wait Cells Onair    ${delta_file}

Recover Env And Test Teardown
    [Arguments]    ${UE_ID_FOR_LTE872}=${UE1}
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_mme_param id=1 reset
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_param id=${UE_ID_FOR_LTE872} reset
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    mme_param id=1 ue_ctx_release_cause=off
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    mme_timer T_UeCtxReleaseCommandDelay=0
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    mme_timer T_S1HoSrcContextRelease=1000
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE872} id=2
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE872} id=6
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE872} id=8
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE872} id=7
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE872} id=15
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    pdn_disconnect ue=${UE_ID_FOR_LTE872} pdn=3
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    enb_param id=7 s1_ho_req_ack_delay=0
    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    enb_param id=3 s1_ho_req_ack_delay=0
    Common Test Teardown And Stop Capture Logs
