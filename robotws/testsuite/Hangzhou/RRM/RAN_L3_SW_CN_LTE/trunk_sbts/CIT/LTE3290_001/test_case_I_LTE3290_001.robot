*** Setting ***
Documentation     \##################################################################################################################################
...                   #####################################    #    # ${QC_TEST_CASE_NAME}=    C-Pln_LTE3290 SRVCC Trigger Enhancement    # CA_DevUL 
...                  F    #${01_SRVCC_WCDMA_eNACC_B1_B2_B3_gsm900_Ue_Cap}    #0 859FF0200308    #Verification of Test Case I.LTE3290.001. The purpose
...                of this case is to verify correct delay of SRVCC to WCDMA/GS    #All    #    #Instance_01    #Ins    #Instance_03    SRVCC delay O
...               N, QCI1 bearer setup during attach, SRVCC WCDMA/GSM execution delayed, SRVCC to WCDMA    3    -72    #Instance_04    SRVCC delay OF
...               F, QCI1 bearer setup after attach, SRVCC WCDMA execution not delayed, SRVCC to WCDMA    4    #Instance_05    SRVCC delay ON, QCI1 b
...               earer setup after attach, SRVCC delay timer not re-started after intra-cell    #Instance_06    SRVCC delay ON, QCI1 bearer setup af
...               ter attach, SRVCC delay timer not re-    #Instance_07    SRVCC delay ON, QCI1 bearer setup after attach    #Instance_08    SRVCC de
...               lay ON, QCI1    #Instance_09    SRVCC delay ON, QCI1 bearer setup afte    #Instance_10    SRVCC delay ON, QCI1 bearer setup after a
...               ttach, PS-HO to    #Instance_11    SRVCC delay ON, QCI1 bearer setup after at    #Instance_12    SRVCC delay ON, QCI1 bearer se    
...               #Instance_13    SRVCC delay ON, QCI1    #    B2 WCDMA/GSM measurement rep    #Instance_14    SRVCC delay ON, QCI1 bearer setup afte
...               r attach and rel    #    delay timer running, B2 WCDMA/GSM measurement report discarded,    #######################################
...               #################################################    ##############################################################################
...               ##
...
...               T_LTE56 FT_LTE3290 FT_LTE442 FT_LTE873 FT_LTE3290
...               040B82E0BBFE6CF504408011047320,1 813FF40200189040B82E0BBF868C4000,2 33035758A6601404EF6513B8878D2920,3 813FF40200189040B82E0BBF868C
...               4000
...               relevant side conditions like feature flag settings, delay timer settings, call history, etc. are considered.
...               SRVCC delay ON, QCI1 bearer setup after attach, SRVCC WCDMA/GSM execution delayed, SRVCC to WCDMA 1 -78 n/a 3 sec
...               QCI1+5 3 sec n/a n/a n/a WCDMA GERAN QCI1 WCDMA/GERAN not applicable 11 sec WCDMA true
...               tance_02 SRVCC delay ON, QCI1 bearer setup during attach, SRVCC WCDMA/GSM execution delayed, SRVCC to GSM 2 -78 QCI1+5
...               3 sec n/a 3 sec n/a n/a n/a WCDMA GERAN QCI1 WCDMA/GERAN not applicable 11 sec GERAN true
...
...               QCI1+5 6 sec n/a 3 sec n/a n/a n/a WCDMA GERAN n/a WCDMA/GERAN not applicable 8 sec WCDMA
...               true
...               -78 n/a 0 sec QCI1+5 0 sec n/a n/a n/a WCDMA n/a n/a not_appl not applicable 10 sec n
...               ot_ap true
...               HO, SRVCC to WCDMA 5 -78 n/a 3 sec QCI1+5 3 sec n/a n/a n/a WCDMA GERAN n/a WCDMA/GERAN i
...               ntra-cell HO 1 sec WCDMA true
...               started after re-establishment, SRVCC to WCDMA 6 -78 n/a 3 sec QCI1+5 3 sec n/a n/a n/a WCDMA GERA
...               N n/a WCDMA/GERAN re-establish 1 sec WCDMA true
...               , SRVCC delay timer not re-started after inter-cell HO, SRVCC to WCDMA 7 -78 n/a 3 sec QCI1+5 3 sec n/a n/a
...               n/a WCDMA GERAN n/a WCDMA/GERAN inter-cell HO 4 sec WCDMA true
...               bearer setup after attach, PS-HO to WCDMA not delayed 8 -78 n/a 0 sec QCI1+5 0 sec n/a n/a n/a GERAN
...               WCDMA n/a not_appl not applicable 10 sec not_ap true
...               r attach, eNACC to GSM not delayed 9 -78 n/a 0 sec QCI1+5 0 sec n/a n/a n/a WCDMA GERAN n/a
...               not_appl not applicable 10 sec not_ap true
...               WCDMA not delayed, GSM B2 discarded due to ong. HO 10 -78 n/a 0 sec QCI1+5 0 sec n/a n/a n/a WCDMA
...               n/a n/a not_appl not applicable 10 sec not_ap true
...               tach and released again, PS-HO to WCDMA execution not delayed 11 -78 n/a 3 sec QCI1+5 3 sec n/a QCI1 n/a
...               WCDMA n/a n/a not_appl not applicable 10 sec not_ap true
...               tup after attach and released again, eNACC to GSM execution not delayed 12 -78 n/a 3 sec QCI1+5 3 sec n/a Q
...               CI1 n/a GERAN n/a n/a not_appl not applicable 10 sec not_ap true
...               bearer setup after attach, PS-HO/eNACC and SRVCC to WCDMA/GSM forbidden, delay timer running,
...               ort discarded, M8009C0 increased 13 -72 n/a 10 sec n/a 3 sec QCI1+5 n/a eNB_A WCDMA GERAN n/a
...               not_appl not applicable 10 sec not_ap false
...               eased again, PS-HO/eNACC and SRVCC to WCDMA/GSM forbidden,
...               M8009C0 increased 14 -72 n/a 10 sec QCI1+5 3 sec n/a QCI1 n/a WCDMA n/a n/a not_appl not
...               applicable 10 sec not_ap false

Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4A_CUS
...               owner-kang.xiang    release-RL25    team-SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
${ue_eutra_capabilities_for_LTE3290}    859FF030030804081705C177FCD9EA0881002208E640
${ue_utra_capabilities_LTE3290}    813FF40200189040B82E0BBF868C4000
${ue_geran_cs_capabilities_LTE3290}    33035758A6601404EF6513B8878D2920
${ue_geran_ps_capabilities_LTE3290}    813FF40200189040B82E0BBF868C4000
@{Delete_Neighbour_Relation}
...  delete:LNADJ.*
...  delete:LNREL.*
...  delete:LNHO.*
@{deltaSCFC_setup}
...  LNBTS-1:acteNACCtoGSM=true
...  LNBTS-1:actEnhAcAndGbrServices=true
...  LNBTS-1:actMultGbrBearers=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
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
...  LNCEL-1/SIB-0:t301=2000ms
...  LNCEL-1/SIB-0:t311=30000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
...  LNBTS-1:tS1RelPrepU=1000
...  LNBTS-1:tS1RelPrepG=1000
...  LNCEL-2/SIB-0:t301=2000ms
...  LNCEL-2/SIB-0:t311=30000ms
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
@{deltaSCFC_instance_01_02_03_05_06_07_11_12_14}
...  LNBTS-1:srvccDelayTimer=40
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
...  LNBTS-1:tS1RelPrepU=5000
@{deltaSCFC_instance_04}
...  LNBTS-1:srvccDelayTimer=0
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
@{deltaSCFC_instance_08}
...  LNBTS-1:srvccDelayTimer=40
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=false
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
@{deltaSCFC_instance_09}
...  LNBTS-1:srvccDelayTimer=40
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=false
@{deltaSCFC_instance_10}
...  LNBTS-1:srvccDelayTimer=40
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=false
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=false
@{deltaSCFC_instance_13}
...  LNBTS-1:srvccDelayTimer=40
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=true
...  LNCEL-1/LNRELW-2:psHoAllowed=forbidden
...  LNCEL-1/LNRELG-0:eNACCAllowed=forbidden
@{deltaSCFC_instance_13_second}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=false
...  LNBTS-1/LNBTS_FDD-0:actSrvccToGsm=false
@{deltaSCFC_instance_14_second}
...  LNCEL-1/LNRELW-2:psHoAllowed=forbidden
...  LNCEL-1/LNRELG-0:eNACCAllowed=forbidden
@{deltaSCFC_instance_13_14_recover}
...  LNCEL-1/LNRELW-2:psHoAllowed=allowed
...  LNCEL-1/LNRELG-0:eNACCAllowed=allowed
@{Eliminate_relation_error}
...  delete:LNCEL:defaultLnRelGnbCellId
@{PARAMS_IN_SCF}
...  @{deltaSCFC_setup}
...  @{deltaSCFC_other}
...  @{add_REDRT}
...  @{PARAMS_FOR_PMQAP}
...  @{RIM}
...  @{Delete_Neighbour_Relation}
...  @{Eliminate_relation_error}
${TTITRACE_FLAG}    ${False}

*** Test Case ***
LTE3290_001_Instance_01_SRVCC_delay_ON_QCI1_bearer_setup_after_attach_SRVCC_WCDMA_GSM_execution_delayed_SRVCC_to_WCDMA
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Start RTPM And Delta Commission    delta_file=${deltaSCFC_instance_01_02_03_05_06_07_11_12_14}
    UE Attach With Default Bearer QCI_6  uecapability_for_LTE3290=${ue_eutra_capabilities_for_LTE3290}  UE_ID_FOR_LTE3290=1
    Report A2    ue_id_for_A2=1    delay1=3s
    Steup Dedicated Bearer QCI_1_5    UE_ID_FOR_LTE3290=1    delay2=3s
    Report Ordinal B2_WCDMA_GERAN    ue_id_for_B2=1    delay3_interval=2s    delay3=3s
    Setup Second QCI_1    UE_ID_FOR_LTE3290=1
    #Simulated LTE->UTRAN HO with SRVCC HO Indication(PS AND CS) (or eCSFB) (eNB 1->RNC 2 (host eNB 6) PLMN=262:03 LAC=2) performed
    Report Ordinal B2_WCDMA_GERAN_WCDMA    ue_id_for_B2=1    delay4_interval=2s    delay4=11s
    Execute Uex Command     ue_detach id=1
    Check Rtpm Counters    pm_reference_file=${CURDIR}${/}Instance1${/}reference_PM.txt

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
    Update Yaml    UEs/bearer_sets/bearer_set_1/1     qci: 6
    Update Yaml    UEs/bearer_sets/bearer_set_1/7     qci: 8
    Update Yaml    UEs/bearer_sets/bearer_set_1/11    qci: 1  preprovisioned: on  filter: 1  precedence: 1
    ...  gbr_ul: 31  gbr_dl: 31  mbr_ul:31  mbr_dl: 31  pdn: 2
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
    ${rnc1_enb4_CELL1}    catenate    - {id: 41, technology: utran, rnc: 1, uarfcn: '10592:9642',  type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 1, rac: 1, pci: '36:2'}
    ${rnc1_enb4_CELL1_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '4:1', earfcn: '1400:19400', eci: '0x0000401'}
    ${rnc1_enb5_CELL2}    catenate    - {id: 52, technology: utran, rnc: 1, uarfcn: '9692:9292',  type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 2, rac: 1, pci: '73:1'}
    ${rnc1_enb5_CELL2_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '5:2', earfcn: '1400:19400', eci: '0x0000502'}
    ${rnc2_enb6_CELL3}    catenate    - {id: 63, technology: utran, rnc: 2, uarfcn: '9842:9442',  type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 3, rac: 2, pci: '76:2'}
    ${rnc2_enb6_CELL3_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '6:0', earfcn: '1400:19400', eci: '0x0000603'}
    ${rnc3_enb7_CELL4}    catenate    - {id: 74, technology: utran, rnc: 3, uarfcn: '1192:967',  type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 4, rac: 3, pci: '113:1'}
    ${rnc3_enb7_CELL4_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '7:1', earfcn: '1400:19400', eci: '0x0000704'}
    ${rnc4_enb3_CELL1}    catenate    - {id: 35, technology: utran, rnc: 4, uarfcn: '10:680', type: FDD,
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

Start RTPM And Delta Commission
    [Arguments]    ${delta_file}
    Start Rtpm Counter
    Delta Commission Parameters And Wait Cells Onair    ${delta_file}

UE Attach With Default Bearer QCI_6
    [Arguments]    ${uecapability_for_LTE3290}    ${UE_ID_FOR_LTE3290}=${UE1}    ${spid}=1
    Execute Egate Command    ue_mme_param id=${UE_ID_FOR_LTE3290} spid=${spid}
    Execute Egate Command    ue_mme_param id=1 srvcc_operation_possible=yes
    Execute Egate Command    ue_param id=${UE_ID_FOR_LTE3290} srvcc=on
    ${attach_cmd}    catenate    ue_attach id=${UE_ID_FOR_LTE3290} cell=1 ue_eutra_capabilities=${uecapability_for_LTE3290}
    ...    ue_utra_capabilities=${ue_utra_capabilities_LTE3290} ue_geran_cs_capabilities=${ue_geran_cs_capabilities_LTE3290}
    ...    ue_geran_ps_capabilities=${ue_geran_ps_capabilities_LTE3290} attach_type=combined srvcc=true
    Execute Uex Command    ${attach_cmd}

Delay
    [Arguments]    ${delay}
    sleep    ${delay}

Report A2
    [Arguments]    ${ue_id_for_A2}    ${delay1}
    Expect Message Flow
    ...    UE_${ue_id_for_A2}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=A2_Flow   overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id_for_A2} srsrp=64 srsrq=20 event=A2
    Flow Occurred As Expected    alias=A2_Flow
    Delay    ${delay1}

Report A2 Without Delay
    [Arguments]    ${ue_id_for_A2}    ${wait_string_for_InterRAT_A2}=rrcConnectionReconfigurationComplete
    Iphy Execute Ue Command Without Kargs    ue_measurement_send meas_id=7 id=${ue_id_for_A2} srsrp=64 srsrq=20    ${wait_string_for_InterRAT_A2}

Report Ordinal B2_WCDMA_GERAN
    [Arguments]  ${ue_id_for_B2}  ${delay3_interval}=1s  ${delay3}=3s
    ${B2_WCDMA}  catenate
    ...  ue_measurement_send id=${ue_id_for_B2} srsrp=55 srsrq=20 event=B2_UTRA phycell_id=230 necn0=10 nrscp=61 amount=1 meas_id_blacklist=20
    Execute Uex Command  ${B2_WCDMA}
    sleep    ${delay3_interval}
    ${B2_GERAN}  catenate
    ...  ue_measurement_send id=${ue_id_for_B2} srsrp=55 srsrq=20 event=B2_GERAN phycell_id=1:1 arfcn=10 band=dcs1800 nrssi=30
    ...  amount=1 meas_id_blacklist=19
    Execute Uex Command  ${B2_GERAN}
    Delay    ${delay3}

Report Ordinal B2_WCDMA_GERAN_WCDMA
    [Arguments]  ${ue_id_for_B2}  ${delay4_interval}  ${delay4}
    ${B2_WCDMA}  catenate
    ...  ue_measurement_send id=${ue_id_for_B2} srsrp=55 srsrq=20 event=B2_UTRA phycell_id=230 necn0=10 nrscp=61 amount=1 meas_id_blacklist=20
    Execute Uex Command  ${B2_WCDMA}
    sleep    ${delay4_interval}
    ${B2_GERAN}  catenate
    ...  ue_measurement_send id=${ue_id_for_B2} srsrp=55 srsrq=20 event=B2_GERAN phycell_id=1:1 arfcn=10 band=dcs1800 nrssi=30
    ...  amount=1 meas_id_blacklist=19
    Execute Uex Command  ${B2_GERAN}
    Delay    ${delay4}
    Expect Message Flow
    ...    MME_1:S1AP_HandoverRequired (value contains (HandoverType eq "ltetoutran"))
    ...    MME_1:S1AP_HandoverCommand (value contains (HandoverType eq "ltetoutran"))
    ...    UE_${ue_id_for_B2}:RRC_MobilityFromEUTRACommand (handover contains (targetRAT-Type eq "utra"))
    ...    MME_1:S1AP_UEContextReleaseCommand (value contains (Cause contains (radioNetwork eq "successful-handover")))
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=HO_Flow   overall_timeout=20
    Execute Uex Command    ${B2_WCDMA}
    Flow Occurred As Expected    alias=HO_Flow

Setup Second QCI_1
    [Arguments]    ${UE_ID_FOR_LTE3290}=${UE1}
    Execute Uex Command    ue_pdn_connect id=${UE_ID_FOR_LTE3290} apn=nokia_2.net

Steup Dedicated Bearer QCI_1_5
    [Arguments]    ${UE_ID_FOR_LTE3290}=${UE1}    ${delay2}=3s
    Execute Uex Command    bearer_add ue=${UE_ID_FOR_LTE3290} qci=1 mbr_ul=25 mbr_dl=25 gbr_ul=25 gbr_dl=25 apn=nokia_1.net
    Execute Uex Command    bearer_add ue=${UE_ID_FOR_LTE3290} qci=5
    Delay    ${delay2}




######### Below KW keep for future debug ###########
#Modify Lua
#    FOR    ${ue_id_number}    IN RANGE    1    15
#        Set Bearer In Lua    bearer_id=1    ue=${ue_id_number}    default=on    qci=6    ip=1.7.11.1
#        ...    trf_type=internal
#        Set Bearer In Lua    bearer_id=7    ue=${ue_id_number}    qci=8
#        Set Bearer In Lua    bearer_id=10    ue=${ue_id_number}    default=on    qci=1    gbr_ul=31
#        ...    gbr_dl=31    gbr_ul=31    gbr_dl=31    mbr_ul=31    mbr_dl=31
#        ...    pdn=2
#    END
#    Set Bearer In Lua    bearer_id=2    ue=2    qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31 preprovisioned=on filter=4 precedence=4
#    Set Bearer In Lua    bearer_id=6    ue=2    qci=5 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31 preprovisioned=on filter=5 precedence=5
#    Set Bearer In Lua    bearer_id=2    ue=3    qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31 preprovisioned=on filter=4 precedence=4
#    Set Bearer In Lua    bearer_id=6    ue=3    qci=5 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31 preprovisioned=on filter=5 precedence=5
#    Set Enb In Lua    enb_id=4    enb_type=simulated    plmn=262:03    enb_id_macro=0x00004    s1=10.0.1.31    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Enb In Lua    enb_id=5    enb_type=simulated    plmn=262:03    enb_id_macro=0x00005    s1=10.0.1.32    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Enb In Lua    enb_id=6    enb_type=simulated    plmn=262:03    enb_id_macro=0x00006    s1=10.0.1.33    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Enb In Lua    enb_id=7    enb_type=simulated    plmn=262:03    enb_id_macro=0x00007    s1=10.0.1.34    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Enb In Lua    enb_id=3    enb_type=simulated    plmn=262:03    enb_id_macro=0x00003    s1=10.0.1.35    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Cell In Lua    cell_id=1    enb_id=4    tac=33    pci=4:1    proxy=:2154    eci=0x0000401
#    ...    earfcn=1400:19400
#    Set Cell In Lua    cell_id=1    enb_id=5    tac=33    pci=5:2    proxy=:2155    eci=0x0000502
#    ...    earfcn=1400:19400
#    Set Cell In Lua    cell_id=1    enb_id=6    tac=33    pci=6:0    proxy=:2156    eci=0x0000603
#    ...    earfcn=1400:19400
#    Set Cell In Lua    cell_id=1    enb_id=7    tac=33    pci=7:1    proxy=:2157    eci=0x0000704
#    ...    earfcn=1400:19400
#    Set Cell In Lua    cell_id=1    enb_id=3    tac=33    pci=0:0    proxy=:2158    eci=0x0000301
#    ...    earfcn=1400:19400
#    Set Utran Rnc In Lua    utran_rnc_id=1    host_enb_id=4    rnc_id=1    plmn=262:03    lac=1
#    Set Utran Rnc In Lua    utran_rnc_id=2    host_enb_id=5    rnc_id=1    plmn=262:03    lac=1
#    Set Utran Rnc In Lua    utran_rnc_id=3    host_enb_id=6    rnc_id=2    plmn=262:03    lac=2
#    Set Utran Rnc In Lua    utran_rnc_id=4    host_enb_id=7    rnc_id=3    plmn=262:03    lac=3
#    Set Utran Rnc In Lua    utran_rnc_id=5    host_enb_id=3    rnc_id=4    plmn=262:03    lac=1
#    Set Utran Cell In Lua    utran_cell_id=1    rnc_id=1    uarfcn=10592:9642    pci=110    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=1    rac=1
#    Set Utran Cell In Lua    utran_cell_id=2    rnc_id=1    uarfcn=9692:9292    pci=220    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=2    rac=1
#    Set Utran Cell In Lua    utran_cell_id=3    rnc_id=2    uarfcn=9842:9442    pci=230    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=3    rac=2
#    Set Utran Cell In Lua    utran_cell_id=4    rnc_id=3    uarfcn=1192:967    pci=340    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=4    rac=3
#    Set Utran Cell In Lua    utran_cell_id=5    rnc_id=4    uarfcn=10:680    pci=9    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=1    rac=1

#Report Ordinal B2_WCDMA_GERAN_GERAN
#    [Arguments]  ${ue_id_for_B2}  ${delay4_interval}  ${delay4}  ${wait_string_for_srvcc_W}=${empty}  ${wait_string_for_srvcc_G_1st}=${empty}
#    ...  ${wait_string_for_srvcc_G_2nd}=${empty}
#  Iphy Execute Ue Command Without Kargs  ue_measurement_send meas_id=19 id=${ue_id_for_B2} allow_mobility srsrp=55 srsrq=20 phycell_id=230 nrscp=61
#    ...  ${wait_string_for_srvcc_W}
#    sleep    ${delay4_interval}
#    Iphy Execute Ue Command Without Kargs
#    ...  ue_measurement_send meas_id=20 id=${ue_id_for_B2} allow_mobility srsrp=55 srsrq=20 phycell_id=9 arfcn=10 band_indicator=dcs1800 nrssi=30
#    ...  ${wait_string_for_srvcc_G_1st}
#    Delay    ${delay4}
#    Iphy Execute Ue Command Without Kargs
#    ...  ue_measurement_send meas_id=20 id=${ue_id_for_B2} allow_mobility srsrp=55 srsrq=20 phycell_id=9 arfcn=10 band_indicator=dcs1800 nrssi=30
#    ...  ${wait_string_for_srvcc_G_2nd}
#
#Report Ordinal B2_WCDMA_GERAN_WCDMA With Intra-cell HO
#    [Arguments]  ${ue_id_for_B2_Intra_Cell_HO}  ${delay4_interval_1}  ${delay4_interval_2}  ${delay4}  ${wait_string_for_srvcc_W_1st}=${empty}
#    ...  ${wait_string_for_srvcc_W_2nd}=${empty}
#    ...    ${wait_string_for_srvcc_G}=${empty}
#    Iphy Execute Ue Command Without Kargs
#    ...  ue_measurement_send meas_id=19 id=${ue_id_for_B2_Intra_Cell_HO} allow_mobility srsrp=55 srsrq=20 phycell_id=230 nrscp=61
#    ...  ${wait_string_for_srvcc_W_1st}
#    sleep    ${delay4_interval_1}
#    ${V_7}  catenate  ue_measurement_send meas_id=20 id=${ue_id_for_B2_Intra_Cell_HO} allow_mobility srsrp=55 srsrq=20 phycell_id=9 arfcn=10
#    ...  band_indicator=dcs1800 nrssi=30
#    Iphy Execute Ue Command Without Kargs    ${V_7}    ${wait_string_for_srvcc_G}
#    sleep    ${delay4_interval_2}
#    Iphy Execute Ue Command Without Kargs    ue_reauth id=${ue_id_for_B2_Intra_Cell_HO}    UEContextModificationResponse
#    Delay    ${delay4}
#    Iphy Execute Ue Command Without Kargs
#    ...  ue_measurement_send meas_id=19 id=${ue_id_for_B2_Intra_Cell_HO} allow_mobility srsrp=55 srsrq=20 phycell_id=230 nrscp=61
#    ...  ${wait_string_for_srvcc_W_2nd}
#
#Report Ordinal B2_WCDMA_GERAN_WCDMA With Re-establishment
#    [Arguments]  ${ue_id_for_B2_Re-establishment}  ${delay4_interval_1}  ${delay4_interval_2}  ${delay4}  ${wait_string_for_srvcc_W_1st}=${empty}
#    ...  ${wait_string_for_srvcc_W_2nd}=${empty}
#    ...    ${wait_string_for_srvcc_G}=${empty}
#    Iphy Execute Ue Command Without Kargs
#    ...  ue_measurement_send meas_id=19 id=${ue_id_for_B2_Re-establishment} allow_mobility srsrp=55 srsrq=20 phycell_id=230 nrscp=61
#    ...  ${wait_string_for_srvcc_W_1st}
#    sleep    ${delay4_interval_1}
#    ${V_8}  catenate  ue_measurement_send meas_id=20 id=${ue_id_for_B2_Re-establishment} allow_mobility srsrp=55 srsrq=20 phycell_id=9 arfcn=10
#    ...  band_indicator=dcs1800 nrssi=30
#    Iphy Execute Ue Command Without Kargs    ${V_8}    ${wait_string_for_srvcc_G}
#    sleep    ${delay4_interval_2}
#    Iphy Execute Ue Command Without Kargs    ue_rrc_reestablish id=${ue_id_for_B2_Re-establishment}    rrcConnectionReestablishmentComplete
#    Delay    ${delay4}
#    Iphy Execute Ue Command Without Kargs
#    ...  ue_measurement_send meas_id=19 id=${ue_id_for_B2_Re-establishment} allow_mobility srsrp=55 srsrq=20 phycell_id=230 nrscp=61
#    ...  ${wait_string_for_srvcc_W_2nd}
#
#Report Ordinal B2_WCDMA_GERAN_WCDMA With Inter-cell HO
#    [Arguments]  ${ue_id_for_B2_Inter-cell_HO}  ${delay4_interval_1}  ${delay4_interval_2}  ${delay4_interval_3}  ${delay4}
#    ...  ${wait_string_for_srvcc_W_1st}=${empty}
#    ...    ${wait_string_for_srvcc_W_2nd}=${empty}    ${wait_string_for_srvcc_G}=${empty}
#    Iphy Execute Ue Command Without Kargs
#    ...  ue_measurement_send meas_id=19 id=${ue_id_for_B2_Inter-cell_HO} allow_mobility srsrp=55 srsrq=20 phycell_id=230 nrscp=61
#    ...  ${wait_string_for_srvcc_W_1st}
#    sleep    ${delay4_interval_1}
#    ${V_9}  catenate  ue_measurement_send meas_id=20 id=${ue_id_for_B2_Inter-cell_HO} allow_mobility srsrp=55 srsrq=20 phycell_id=9 arfcn=10
#    ...  band_indicator=dcs1800 nrssi=30
#    Iphy Execute Ue Command Without Kargs    ${V_9}    ${wait_string_for_srvcc_G}
#    sleep    ${delay4_interval_2}
#    Iphy Execute Ue Command Without Kargs    ue_ho id=${ue_id_for_B2_Inter-cell_HO} ho_mode=INTRA_LTE enb=1 cell=2    mobilityControlInfo
#    sleep    ${delay4_interval_3}
#    Iphy Execute Ue Command Without Kargs  ue_measurement_send meas_id=7 id=${ue_id_for_B2_Inter-cell_HO} srsrp=64 srsrq=20
#    ...  rrcConnectionReconfigurationComplete
#    Delay    ${delay4}
#    Iphy Execute Ue Command Without Kargs
#    ...  ue_measurement_send meas_id=14 id=${ue_id_for_B2_Inter-cell_HO} allow_mobility srsrp=55 srsrq=20 phycell_id=230 nrscp=61
#    ...  ${wait_string_for_srvcc_W_2nd}
#
#Report B2_WCDMA
#    [Arguments]    ${ue_id_for_B2}    ${delay3}=3s    ${wait_string_for_srvcc_W}=${empty}
#  Iphy Execute Ue Command Without Kargs  ue_measurement_send meas_id=19 id=${ue_id_for_B2} allow_mobility srsrp=55 srsrq=20 phycell_id=230 nrscp=61
#    ...  ${wait_string_for_srvcc_W}
#    Delay    ${delay3}
#
#Report B2_GERAN
#    [Arguments]    ${ue_id_for_B2}    ${delay3}=3s    ${wait_string_for_srvcc_G}=${empty}
#    Iphy Execute Ue Command Without Kargs
#    ...  ue_measurement_send meas_id=20 id=${ue_id_for_B2} allow_mobility srsrp=55 srsrq=20 phycell_id=9 arfcn=10 band_indicator=dcs1800 nrssi=30
#    ...  ${wait_string_for_srvcc_G}
#    Delay    ${delay3}
#
#Release Dedicated Bearer QCI_1_5
#    [Arguments]    ${UE_ID_FOR_LTE3290}=${UE1}    ${delay3_Interval}=3s
#    Iphy Execute Ue Command Without Kargs  bearer_del ue=${UE_ID_FOR_LTE3290} id=2
#    ...  Bearer-2 \\(EBI=6\\) deleted in result of PGW-initiated Bearer Deletion procedure
#    Iphy Execute Ue Command Without Kargs  bearer_del ue=${UE_ID_FOR_LTE3290} id=6
#    ...  Bearer-6 \\(EBI=7\\) deleted in result of PGW-initiated Bearer Deletion procedure
#    Delay    ${delay3_Interval}
#
#Second Delta Commission For eNB
#    [Arguments]    ${delta_file}    ${delay3_pre}=1s
#    Delta Commission Parameters    ${delta_file}
#    Cells Should Be OnAir    wait_sib=5s
#    Delay    ${delay3_pre}
#
#Recover Env And Test Teardown
#    [Arguments]    ${UE_ID_FOR_LTE3290}=${UE1}
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_mme_param id=1 reset
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_param id=${UE_ID_FOR_LTE3290} reset
#    #    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    mme_param id=1 attach_cb_integrated=off
#    #    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    mme_param id=1 ue_ctx_release_cause=off
#    #    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    mme_timer T_UeCtxReleaseCommandDelay=0
#    #    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    mme_timer T_S1HoSrcContextRelease=1000
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE3290} id=2
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE3290} id=6
#    #    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE3290} id=15
#    #    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    pdn_disconnect ue=${UE_ID_FOR_LTE3290} pdn=3
#    Common Test Teardown And Stop Capture Logs
#
#Recover Env And Test Teardown With Delta Commission
#    [Arguments]    ${UE_ID_FOR_LTE3290}    ${delta_file}
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_mme_param id=1 reset
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_param id=${UE_ID_FOR_LTE3290} reset
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE3290} id=2
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE3290} id=6
#    Delta Commission Parameters    ${delta_file}
#    Cells Should Be OnAir    wait_sib=5s
#    Common Test Teardown And Stop Capture Logs
