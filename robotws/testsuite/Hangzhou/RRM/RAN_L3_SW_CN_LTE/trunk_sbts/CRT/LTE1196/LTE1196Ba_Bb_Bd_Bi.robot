*** Setting ***
Documentation     \##################################################################################################################################
...                   #####################################
...
...               * Test Case * Instance LTE CN emu macro LTE CN emu unit eNB SCFC start file (wo .xml) eNB SCFC delta file (wo .xml)
...               Instance_01 Establishment of RIM Association, successful Cases, download delta plan file with additional new LNADJW object (RIM cap
...               able) 1 WaitAndSendRimInitialMultipleReportforUTRAN_Ba_Inst1_eNB45090 mme SCFC_missing_LNADJWs add_LNADJWs
...               Instance_02 Establishment of RIM Association, successful Cases, download delta plan file with LNADJW object removed from RIM blackl
...               ist 2 WaitAndSendRimInitialMultipleReportforUTRAN_Ba_Inst5_eNB45090 mme SCFC_LNADJWs_blacklisted remove_LNADJWs_from_blacklist
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4A_CUS
...               owner-kang.xiang    release-RL25    team-SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
${anrUtraTRSCFS}    5000ms    #default value in SCF
${anrUtraInactivityTimer}    5    #inactivity timer in vendor
${anrUtraTRSC}    2500ms    #default value in vendor
${anrUtraTRCGI}    8200ms    #default value in vendor

${ue_eutra_capabilities_for_LTE1196}    C59FF030030804081705C177E0D9880800020000
${ue_eutra_capabilities_for_LTE1196_ANR}    C59FF030030804081705C177F0DBC8080080500000
${ue_utra_capabilities_LTE1196}    813FF40200189040B82E0BBF868C4000
${ue_geran_cs_capabilities_LTE1196}    33035758A6601404EF6513B8878D2920
${ue_geran_ps_capabilities_LTE1196}    813FF40200189040B82E0BBF868C4000
@{Delete_Neighbour_Relation}
...  delete:LNADJ.*
...  delete:LNREL.*
...  delete:LNHO.*
...  delete:RIM-0:blacklistUtranCellsForRim
...  delete:MODPR.*
...  delete:MOPR.*
...  delete:moPrMappingList
@{deltaSCFC_setup}
...  LNBTS-1:actCSFBRedir=Enabled
...  LNBTS-1:actRIMforUTRAN=false
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  LNBTS-1:actRedirect=enabled
...  LNCEL-1:threshold2GERAN=62
...  LNCEL-1:threshold2Wcdma=62
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
...  LNBTS-1/LNADJW-0:uTargetScFdd=110
...  LNBTS-1/LNADJW-0:uTargetCid=0
...  LNBTS-1/LNADJW-0:uTargetFreq=10592
...  LNBTS-1/LNADJW-0:uTargetLac=1
...  LNBTS-1/LNADJW-0:uTargetRncId=1
...  LNBTS-1/LNADJW-0:uTargetRac=1
...  LNBTS-1/LNADJW-0:srvccHoInd=PSandCS
...  LNBTS-1/LNADJW-0:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-0:primaryPlmnId:mnc=3
...  LNBTS-1/LNADJW-0:primaryPlmnId:mncLength=2
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
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-0:utranLbAllowed=false
...  LNCEL-1/LNRELW-0:nrControl=automatic
...  LNCEL-1/LNRELW-0:psHoAllowed=allowed
...  LNCEL-1/LNRELW-0:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-0:removeAllowed=true
...  LNCEL-1/LNRELW-0:srvccAllowed=allowed
...  LNCEL-1/LNRELW-0:uTargetCid=0
...  LNCEL-1/LNRELW-0:uTargetRncId=1
...  LNCEL-1/LNRELW-0:plmnId:mcc=262
...  LNCEL-1/LNRELW-0:plmnId:mnc=3
...  LNCEL-1/LNRELW-0:plmnId:mncLength=2
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
...  RIM-0:tRimPollU=5
...  RIM-0:tRimKaG=150
...  RIM-0:tRimKaU=15
...  RIM-0:tRimRirG=5
...  RIM-0:tRimRirU=15
...  RIM-0:goodRadioCondForCsfbThres=-100
@{add_REDRT}
...  LNCEL-1/REDRT-1:redirFreqUtra=10592
...  LNCEL-1/REDRT-1:redirRat=utraFDD
...  LNCEL-1/REDRT-1:csFallBPrio=1
...  LNCEL-1/REDRT-1:emerCallPrio=1
...  LNCEL-1/REDRT-1:redirectPrio=1
...  LNCEL-1/REDRT-1:addUtranSIToRedirMsg=both
@{Ba_deltaSCFC_instance_01_activeflag}
...  LNBTS-1:actRIMforUTRAN=true
...  delete:LNADJW.*
...  delete:LNRELW.*
@{Ba_deltaSCFC_instance_02_add_LANDJW_with_blacklist}
...  LNBTS-1:actRIMforUTRAN=true
...  RIM-0:blacklistUtranCellsForRim:rncId=1|utranCarrierFreq=10592
...  RIM-0:blacklistUtranCellsForRim:mcc=262|utranCarrierFreq=10592
...  RIM-0:blacklistUtranCellsForRim:mnc=3|utranCarrierFreq=10592
...  RIM-0:blacklistUtranCellsForRim:mncLength=2|utranCarrierFreq=10592
...  RIM-0:blacklistUtranCellsForRim:rncId=2|utranCarrierFreq=9842
...  RIM-0:blacklistUtranCellsForRim:mcc=262|utranCarrierFreq=9842
...  RIM-0:blacklistUtranCellsForRim:mnc=3|utranCarrierFreq=9842
...  RIM-0:blacklistUtranCellsForRim:mncLength=2|utranCarrierFreq=9842
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
@{Ba_deltaSCFC_second_instance_01_add_LNADJW}
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
@{Ba_deltaSCFC_second_instance_02_del_blacklist}
...  delete:RIM-0:blacklistUtranCellsForRim
@{Bb_pre_deltaSCFC_instance_01_add_LNADJW0}
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
@{Bb_deltaSCFC_instance_01_activeflag}
...  LNBTS-1:actRIMforUTRAN=true
@{Bb_deltaSCFC_instance_02_add_LNADJW0}
...  LNBTS-1:actRIMforUTRAN=true
...  RIM-0:blacklistUtranCellsForRim:mcc=262|utranCarrierFreq=10592
...  RIM-0:blacklistUtranCellsForRim:mnc=4|utranCarrierFreq=10592
...  RIM-0:blacklistUtranCellsForRim:mncLength=2|utranCarrierFreq=10592
...  RIM-0:blacklistUtranCellsForRim:rncId=1|utranCarrierFreq=10592
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
@{Bb_deltaSCFC_second_instance_01_del_LNADJW0}
...  delete:LNADJW-0
@{Bb_deltaSCFC_second_instance_02_change_plmn}
...  LNBTS-1/LNADJW-0:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-0:primaryPlmnId:mnc=4
...  LNBTS-1/LNADJW-0:primaryPlmnId:mncLength=2
...  delete:LNADJW-0:secondaryPlmnIdL
@{Bb_deltaSCFC_instance_03_add_LNADJW_with_blacklist}
...  LNBTS-1:actRIMforUTRAN=true
...  RIM-0:blacklistUtranCellsForRim:mcc=262|utranCarrierFreq=10592
...  RIM-0:blacklistUtranCellsForRim:mnc=3|utranCarrierFreq=10592
...  RIM-0:blacklistUtranCellsForRim:mncLength=2|utranCarrierFreq=10592
...  RIM-0:blacklistUtranCellsForRim:rncId=2|utranCarrierFreq=10592
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
@{Bb_deltaSCFC_second_instance_03_change_blacklist}
...  RIM-0:blacklistUtranCellsForRim:rncId=1
...  delete:LNADJW-0:secondaryPlmnIdL
@{Bb_deltaSCFC_instance_04_add_LNADJW0}
...  LNBTS-1:actRIMforUTRAN=true
...  RIM-0:blacklistUtranCellsForRim:mcc=262|utranCarrierFreq=10599
...  RIM-0:blacklistUtranCellsForRim:mnc=3|utranCarrierFreq=10599
...  RIM-0:blacklistUtranCellsForRim:mncLength=2|utranCarrierFreq=10599
...  RIM-0:blacklistUtranCellsForRim:rncId=1|utranCarrierFreq=10599
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
@{Bb_deltaSCFC_second_instance_04_change_blacklist}
...  RIM-0:blacklistUtranCellsForRim:utranCarrierFreq=10592
...  delete:LNADJW-0:secondaryPlmnIdL
@{Bd_deltaSCFC_instance_01_deactiveflag}
...  LNBTS-1:actRIMforUTRAN=false
...  LNBTS-1/LNADJW-0:uTargetScFdd=110
...  LNBTS-1/LNADJW-0:uTargetCid=1
...  LNBTS-1/LNADJW-0:uTargetFreq=10592
...  LNBTS-1/LNADJW-0:uTargetLac=1
...  LNBTS-1/LNADJW-0:uTargetRncId=1
...  LNBTS-1/LNADJW-0:uTargetRac=1
...  LNBTS-1/LNADJW-0:srvccHoInd=PSandCS
...  LNBTS-1/LNADJW-0:primaryPlmnId:mcc=111
...  LNBTS-1/LNADJW-0:primaryPlmnId:mnc=11
...  LNBTS-1/LNADJW-0:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-0:secondaryPlmnIdL:mcc=262
...  LNBTS-1/LNADJW-0:secondaryPlmnIdL:mnc=3
...  LNBTS-1/LNADJW-0:secondaryPlmnIdL:mncLength=2
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
@{Bd_deltaSCFC_second_instance_01_activeflag}
...  LNBTS-1:actRIMforUTRAN=true
@{fault6322}
...  fault_id=6322
...  fault_name=RIM interface timeout
@{Bi_deltaSCFC_instance_01_activeflag_with_utranANR}
...  LNBTS-1:actRIMforUTRAN=true
...  LNBTS-1:actUeBasedAnrUtran=true
...  ANRPRW-1:lnRelWLimitForAnr=3
...  ANRPRW-1:utraCarrierFreq=10592
...  delete:LNADJ.*
...  delete:LNREL.*
...  delete:RIM-0:blacklistUtranCellsForRim
@{decommission_scf_LTE1196}
...  LNBTS-1:actRIMforUTRAN=false
...  delete:LNADJ.*
...  delete:LNREL.*
...  delete:RIM-0:blacklistUtranCellsForRim
@{PARAMS_IN_SCF}
...  @{deltaSCFC_setup}
...  @{deltaSCFC_other}
...  @{add_REDRT}
...  @{RIM}
...  @{Eliminate_Relation_Error}
@{Eliminate_Relation_Error}    delete:LNCEL:defaultLnRelGnbCellId

${TTITRACE_FLAG}    ${False}
@{start_thread_list}
@{stop_thread_list}
${V_1}
...  SEPARATOR=
...  0026408157000001007A00814F00814C70548E0262F23000210062F2300000001054890162F230000101001058011E4B81054C84000000004F
...  81044E010F0062F23080100010205185200C1412C110C1115091231123022BC8D841804791111420002442004304062BF469B5C90052001000
...  A113E5168141A44800811FFFFFE97700010688E03A000F03FFFC1210F0290C0A8018000C8CF7B17EE103F000003F5A88E70320203890163C08
...  0A0088643280020445A2C880078860163B32004308936B4807010688E03A000F03FFFC1210F0290C0A8018000C8CF7B17EE103F000003F5A88
...  E70320203890163C080A0088643280020445A2C880078860163B32004308936B48070114075B1E0080142500A31CCC044500E31CCC04650163
...  1CCC048501A31CCC04A503231CCC04C503A31CCC04E503E31CCC000F8494FF14018C7330014048C73300140D8C733000800D0025F081000001
...  7025F081002D
${V_2}
...  SEPARATOR=
...  0026408157000001007A00814F00814C70548E0262F23000210062F2300000001054890162F230000101000158011E4B81054C84000000004F
...  81044E010F0062F23080010001205185200C1412C110C1115091231123022BC8D841804791111420002442004304062BF469B5C90052001000
...  A113E5168141A44800811FFFFFE97700010688E03A000F03FFFC1210F0290C0A8018000C8CF7B17EE103F000003F5A88E70320203890163C08
...  0A0088643280020445A2C880078860163B32004308936B4807010688E03A000F03FFFC1210F0290C0A8018000C8CF7B17EE103F000003F5A88
...  E70320203890163C080A0088643280020445A2C880078860163B32004308936B48070114075B1E0080142500A31CCC044500E31CCC04650163
...  1CCC048501A31CCC04A503231CCC04C503A31CCC04E503E31CCC000F8494FF14018C7330014048C73300140D8C733000800D0025F081000001
...  7025F081002D
${V_3}
...  SEPARATOR=
...  0026408157000001007A00814F00814C70548E0262F23000210062F2300000001054890162F230000101000158011E4B81054C84000000004F
...  81044E010F0062F23080010001205185200C1412C110C1115091231123022BC8D841804791111420002442004304062BF469B5C90052001000
...  A113E5168141A44800811FFFFFE97700010688E03A000F03FFFC1210F0290C0A8018000C8CF7B17EE103F000003F5A88E70320203890163C08
...  0A0088643280020445A2C880078860163B32004308936B4807010688E03A000F03FFFC1210F0290C0A8018000C8CF7B17EE103F000003F5A88
...  E70320203890163C080A0088643280020445A2C880078860163B32004308936B48070114075B1E0080142500A31CCC044500E31CCC04650163
...  1CCC048501A31CCC04A503231CCC04C503A31CCC04E503E31CCC000F8494FF14018C7330014048C73300140D8C733000800D0025F081000001
...  7025F081002D
${V_4}
...  SEPARATOR=
...  0026408157000001007A00814F00814C70548E0262F23000210062F2300000001054890162F230000202000258011E4B81054C84000000004F
...  81044E010F0062F23080020003205185200C1412C110C1115091231123022BC8D841804791111420002442004304062BF469B5C90052001000
...  A113E5168141A44800811FFFFFE97700010688E03A000F03FFFC1210F0290C0A8018000C8CF7B17EE103F000003F5A88E70320203890163C08
...  0A0088643280020445A2C880078860163B32004308936B4807010688E03A000F03FFFC1210F0290C0A8018000C8CF7B17EE103F000003F5A88
...  E70320203890163C080A0088643280020445A2C880078860163B32004308936B48070114075B1E0080142500A31CCC044500E31CCC04650163
...  1CCC048501A31CCC04A503231CCC04C503A31CCC04E503E31CCC000F8494FF14018C7330014048C73300140D8C733000800D0025F081000001
...  7025F081002D

${RSCFS_CF}
...    measConfig contains (
...      measObjectToAddModList contains (carrierFreq eq 10592)
...      and
...      reportConfigToAddModList contains (purpose eq 'reportStrongestCellsForSON')
...      and
...      measIdToAddModList contains (measId eq 32)
...    )

${RSC_CF}
...    measConfig contains (
...      measObjectToAddModList contains (carrierFreq eq 10592)
...      and
...      reportConfigToAddModList contains (purpose eq 'reportStrongestCells')
...      and
...      measIdToAddModList contains (measId eq 32)
...    )

${CGI_CF}
...    measConfig contains (
...      measObjectToAddModList contains (carrierFreq eq 10592)
...      and
...      reportConfigToAddModList contains (purpose eq 'reportCGI')
...      and
...      measIdToAddModList contains (measId eq 32)
...    )

*** Test Case ***
LTE1196Bi_Instance_01_LNADJW_LNRELW_created_by_ANR_triggers_RIM_Connection
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Delta Commission Parameters And Wait Cells Onair    delta_params=${Bi_deltaSCFC_instance_01_activeflag_with_utranANR}
    Calculate UtraAnr Timeout
    UE Attach With Default Bearer QCI_6 With RSCFS  uecapability_for_LTE1196=${ue_eutra_capabilities_for_LTE1196_ANR}  UE_ID_FOR_LTE1196=3
    Report RCS And CGI MeasurementReport
    Sleep for LNADJW create and write into OAM
    Start RIM Function in WTS With Single LNADJW    hex_code=${V_1}
    Execute Uex Command     ue_detach id=3
    Check RIM Status available in LNADJW By ANR
    [Teardown]    Recover Env And Test Teardown    decommission_scf=${decommission_scf_LTE1196}

*** Keyword ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Execute Egate Command    trace_sim on mme=1 protocol=s1

Modify Yaml
    Add Yaml      EPC/RNC
    ...    - id: 1
    ...    host_enb: 4
    ...    rnc_id: 1
    ...    lac: 1
    ...    plmn: '262:03'
    ${rnc1_enb4_CELL1}    catenate    - {id: 41, technology: utran, rnc: 1, uarfcn: '10592:9642',  type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 1, rac: 1, pci: '36:2'}
    ${rnc1_enb4_CELL1_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '4:1', earfcn: '1400:19400', eci: '0x0000401'}
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

UE Attach With Default Bearer QCI_6 With RSCFS
    [Arguments]    ${uecapability_for_LTE1196}    ${UE_ID_FOR_LTE1196}=3    ${spid}=1
    ${RSCFS_CMD}    catenate
    ...    ue_rrc_reconf_param id=${UE_ID_FOR_LTE1196} if_contains=purpose with_value=reportStrongestCellsForSON
    ...    action=measurement_send id=${UE_ID_FOR_LTE1196} phycell_id=110 arfcn=10592 type=fdd nrscp=91 necn0=49
    ...    lac=1 rac=1 strongest=utra cgi=262:03|0x0100010 son=true
    Expect Message Flow
    ...    UE_${UE_ID_FOR_LTE1196}:RRC_RRCConnectionReconfiguration(${RSCFS_CF})
    ...    UE_${UE_ID_FOR_LTE1196}:RRC_RRCConnectionReconfiguration(${RSC_CF})
    ...    alias=RSCFS&RSC    overall_timeout=20
    Execute Uex Command    ${RSCFS_CMD}
    Execute Egate Command    ue_mme_param id=${UE_ID_FOR_LTE1196} spid=${spid}
    Execute Egate Command    ue_mme_param id=${UE_ID_FOR_LTE1196} srvcc_operation_possible=yes
    Execute Egate Command    ue_param id=${UE_ID_FOR_LTE1196} srvcc=on
    ${attach_cmd}    catenate    ue_attach id=${UE_ID_FOR_LTE1196} cell=1 ue_eutra_capabilities=${uecapability_for_LTE1196}
    ...  ue_utra_capabilities=${ue_utra_capabilities_LTE1196} attach_type=combined srvcc=true
    Execute Uex Command    ${attach_cmd}
    Flow Occurred As Expected    alias=RSCFS&RSC

Report RCS And CGI MeasurementReport
    [Arguments]    ${ue_id}=3
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${CGI_CF})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=LTE908_cgi    overall_timeout=${utraAnr_timeout}
    ${rsc_report_command}=    Catenate
    ...    ue_measurement_send id=${ue_id} phycell_id=110 arfcn=10592 type=fdd
    ...    nrscp=91 necn0=49 lac=1 rac=1 strongest=utra cgi=262:03|0x0100010 son=true
    Execute Uex Command    ${rsc_report_command}
    Flow Occurred As Expected    alias=LTE908_cgi

Sleep for LNADJW create and write into OAM
    sleep    10s

Start RIM Function in WTS With Single LNADJW
    [Arguments]    ${hex_code}=${V_2}
    [Documentation]    LNADJW-0
    Execute Egate Command    send_hex source=mme:1 target=enb:1 hex=${hex_code}

Check RIM Status available in LNADJW By ANR
    Object Should Exist    LNBTS-1\/LNADJW-511:rimStatus=available

Recover Env And Test Teardown
    [Arguments]    ${UE_ID_FOR_LTE1196}=3    ${decommission_scf}=${empty}
    Execute Egate Command    ue_mme_param id=${UE_ID_FOR_LTE1196} reset
    Execute Egate Command    ue_param id=${UE_ID_FOR_LTE1196} reset
    Delta Commission Parameters And Wait Cells Onair    delta_params=${decommission_scf}
    Common Test Teardown And Stop Capture Logs

Calculate UtraAnr Timeout
    ${anrUtraTRSCFS_timeout}=    Remove String Using Regexp    ${anrUtraTRSCFS}    \\D+
    ${anrUtraTRSC_timeout}=    Remove String Using Regexp    ${anrUtraTRSC}    \\D+
    ${anrUtraTRCGI_timeout}=    Remove String Using Regexp    ${anrUtraTRCGI}    \\D+
    ${utraAnr_timeout}    Set Variable    ${${${anrUtraTRSCFS_timeout}+${anrUtraTRSC_timeout}+${anrUtraTRCGI_timeout}}/1000}
    Set Suite Variable    ${utraAnr_timeout}



#below kw keep for future debug.
#Modify Lua
#    FOR    ${ue_id_number}    IN RANGE    1    11
#        Set Bearer In Lua    bearer_id=1    ue=${ue_id_number}    default=on    qci=6    ip=1.7.11.1
#        ...    trf_type=internal
#        Set Bearer In Lua    bearer_id=7    ue=${ue_id_number}    qci=8
#    END
#    Set Enb In Lua    enb_id=4    enb_type=simulated    plmn=262:03    enb_id_macro=0x00004    s1=10.0.1.31    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Cell In Lua    cell_id=1    enb_id=4    tac=33    pci=4:1    proxy=:2154    eci=0x0000401
#    ...    earfcn=1400:19400
#    Set Utran Rnc In Lua    utran_rnc_id=1    host_enb_id=4    rnc_id=1    plmn=262:03    lac=1
#    Set Utran Cell In Lua    utran_cell_id=1    rnc_id=1    uarfcn=10592:9642    pci=110    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=1    rac=1

#Trriger CSFB
#    [Arguments]    ${ue_id_for_csfb}    ${SERVICE_TYPE}    ${priority}=off    ${wait_string_for_check}=CSFB to UTRA FDD
#    [Documentation]    Can't set mme_param to RN_cs_fallback_triggered here due to recover is unavailable for case requirement
#    Iphy Execute Ue Command Without Kargs    ue_csfb id=${ue_id_for_csfb} direction=${SERVICE_TYPE} priority=${priority}    ${wait_string_for_check}
#
#Delta Commission
#    [Arguments]    ${delta_file}
#    Delta Commission Parameters    ${delta_file}
#    Cells Should Be OnAir    wait_sib=5s
#
#Delta Commission With RIM Sending
#    [Arguments]    ${delta_file}    ${wait_RIM_message}=MME-1: S1:ENB_DIRECT_INFORMATION_TRANSFER
#    ${Delta_result}    Delta Commission Parameters    ${delta_file}    background=${True}
#    Iphy Execute Ue Command Without Kargs    set_log flush    ${wait_RIM_message}    timeout=60s    sleep_time=1
#    Start RIM Function in WTS
#    Collect Keyword Result    ${Delta_result}
#
#Delta Commission With RIM Sending With Single LNADJW
#    [Arguments]    ${delta_file}    ${wait_RIM_message}=ENB-4: S1:ENB_DIRECT_INFORMATION_TRANSFER
#    ${Delta_result}    Delta Commission Parameters    ${delta_file}    background=${True}
#    Iphy Execute Ue Command Without Kargs    set_log flush    ${wait_RIM_message}    timeout=60s    sleep_time=1
#    Start RIM Function in WTS With Single LNADJW
#    Collect Keyword Result    ${Delta_result}
#
#Start RIM Function in WTS
#    [Documentation]    LNADJW-0,LNADJW-2
#    Iphy Execute Ue Command Without Kargs    send_hex source=mme:1 target=enb:1 hex=${V_3}
#    Iphy Execute Ue Command Without Kargs    send_hex source=mme:1 target=enb:1 hex=${V_4}
#
#Check RIM Status available in LNADJW
#    [Arguments]    ${rimStatus_LNADJW_0}=available    ${rimStatus_LNADJW_2}=available
#    Check RIM Status available in LNADJW_0    rimStatus_LNADJW_0=${rimStatus_LNADJW_0}
#    Check RIM Status available in LNADJW_2    rimStatus_LNADJW_2=${rimStatus_LNADJW_2}
#
#Check RIM Status available in LNADJW_0
#    [Arguments]    ${rimStatus_LNADJW_0}=available
#    Object Should Exist    LNBTS-1\/LNADJW-0:rimStatus=${rimStatus_LNADJW_0}
#
#Check RIM Status available in LNADJW_2
#    [Arguments]    ${rimStatus_LNADJW_2}=available
#    Object Should Exist    LNBTS-1\/LNADJW-2:rimStatus=${rimStatus_LNADJW_2}
#
#Check No RIM Parameter in LNADJW
#    Object Should Not Exist    LNBTS-1\/LNADJW-0:rimStatus=available
#
#Wait For RIM Restart
#    [Arguments]    ${wait_RIM_message}=ENB-4: S1:ENB_DIRECT_INFORMATION_TRANSFER
#    Iphy Execute Ue Command Without Kargs    set_log flush    ${wait_RIM_message}    timeout=330s    sleep_time=1
#
#Reserve CGI Of WCDMA
#    [Arguments]    ${UE_ID_FOR_LTE1196}=${UE1}
#    Iphy Execute Ue Command Without Kargs    ue_meas_param id=${UE_ID_FOR_LTE1196} use_meas=on
#    Iphy Execute Ue Command Without Kargs    ue_meas_param id=${UE_ID_FOR_LTE1196} rscp=91 ecn0=49 utran_neigh_cell=non_cfgd:110:10592
