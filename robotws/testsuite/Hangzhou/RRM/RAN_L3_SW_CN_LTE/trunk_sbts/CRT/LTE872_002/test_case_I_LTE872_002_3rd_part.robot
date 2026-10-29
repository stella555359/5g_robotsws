*** Setting ***
Documentation     \##################################################################################################################################
...                   #####################################
...
...               ${QC_TEST_CASE_NAME}= C-Pln_LTE872 Elimination of unsuitable target cells during receiving of a B2 measurement report
...               ${QC_TEST_CASE_VERSION}= 2.0
...               ${TESTCASE_ID}= V.LTE872.002
...               * Test Case * Instance Instance_ulm list Ue capabilities SRVCC FGI bit settings setup1 setup2 EUTRA


Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4A_CUS
...               owner-kang.xiang    release-RL25    team-SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
${01_SRVCC_FGI_COM_1_FDD_n_TDD_n_B1_B2_B3_Ue_Cap}    859FF030030804081705C177F0D9CA08010022
${01_SRVCC_FGI_COM_0_FDD_n_TDD_n_B1_B2_B3_Ue_Cap}    859FF030030804081705C177F0D9C808010022
${01_SRVCC_PSHO_FGI_COM_0_FDD_n_B1_B2_B3_Ue_Cap}    859FF030030804081705C177E0D9C808010022
${ue_utra_capabilities_LTE872}    813FF40200189040B82E0BBF868C4000
@{Delete_Neighbour_Relation}
...  delete:LNADJ.*
...  delete:LNREL.*
...  delete:LNHO.*
...  delete:LNCEL:defaultLnRelGnbCellId
@{deltaSCFC_setup}
...  LNBTS-1:tS1RelPrepU=5000
...  LNBTS-1:actFlexQCIARPPMProfiles=true
...  LNBTS-1/LNBTS_FDD-0:actIMSEmerSessR9=true
...  LNBTS-1/GTPU-1:gtpuPathSupint=20
...  LNBTS-1/GTPU-1:gtpuN3Reqs=1
...  LNBTS-1/MODPR-0:autoAdapt=false
...  LNBTS-1/MODPR-0:autoAdaptIMLB=false
...  LNBTS-1/MODPR-0:idleLBPercentageOfUes=0
...  LNBTS-1/MODPR-0:idleLBPercCaUe=0
...  LNBTS-1/MODPR-0:targetSelMethod=SIB_based
...  LNBTS-1/MODPR-0:freqLayListSrvccWcdma=9692
...  LNBTS-1/MODPR-0:freqLayListPsHoWcdma=9692
...  LNCEL-2/LNHOW-1:reportIntervalUtra=2048ms
...  LNCEL-2/LNHOW-1:maxNumCsfbTargets=16
...  LNCEL-2/LNHOW-1:hysB1ThresholdCSFBUtra=0
...  LNCEL-2/LNHOW-1:hysB2ThresholdUtra=0
...  LNCEL-2/LNHOW-1:b2Threshold1Utra=57
...  LNCEL-2/LNHOW-1:b2TimeToTriggerUtraMeas=480ms
...  LNCEL-2/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=80ms
...  LNCEL-2/LNHOW-1:utraCarrierFreq=9692
...  LNCEL-2/LNHOW-1:offsetFreqUtra=0
...  LNCEL-2/LNHOW-1:b2Threshold2UtraRscp=60
...  LNCEL-2:furtherPlmnIdL:mcc=555
...  LNCEL-2:furtherPlmnIdL:mnc=10
...  LNCEL-2:furtherPlmnIdL:mncLength=2
...  LNCEL-2:furtherPlmnIdL:autoRemovalAllowed=false
...  LNCEL-2:furtherPlmnIdL:cellReserve=Not Reserved
...  LNCEL-2/SIB-0:t301=2000ms
...  LNCEL-2/SIB-0:t311=30000ms
...  LNCEL-2:t304InterRAT=500ms
...  LNCEL-2:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
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
@{deltaSCFC_instance_All}
...  LNBTS-1:actIfHo=disabled
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
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
...  LNBTS-1/LNADJW-12:uTargetScFdd=221
...  LNBTS-1/LNADJW-12:uTargetCid=12
...  LNBTS-1/LNADJW-12:uTargetFreq=9692
...  LNBTS-1/LNADJW-12:uTargetLac=1
...  LNBTS-1/LNADJW-12:uTargetRncId=1
...  LNBTS-1/LNADJW-12:uTargetRac=1
...  LNBTS-1/LNADJW-12:srvccHoInd=PSandCS
...  LNBTS-1/LNADJW-12:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-12:primaryPlmnId:mnc=3
...  LNBTS-1/LNADJW-12:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-13:uTargetScFdd=222
...  LNBTS-1/LNADJW-13:uTargetCid=13
...  LNBTS-1/LNADJW-13:uTargetFreq=9692
...  LNBTS-1/LNADJW-13:uTargetLac=1
...  LNBTS-1/LNADJW-13:uTargetRncId=1
...  LNBTS-1/LNADJW-13:uTargetRac=1
...  LNBTS-1/LNADJW-13:srvccHoInd=PSandCS
...  LNBTS-1/LNADJW-13:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-13:primaryPlmnId:mnc=3
...  LNBTS-1/LNADJW-13:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-14:uTargetScFdd=223
...  LNBTS-1/LNADJW-14:uTargetCid=14
...  LNBTS-1/LNADJW-14:uTargetFreq=9692
...  LNBTS-1/LNADJW-14:uTargetLac=1
...  LNBTS-1/LNADJW-14:uTargetRncId=1
...  LNBTS-1/LNADJW-14:uTargetRac=1
...  LNBTS-1/LNADJW-14:srvccHoInd=PSandCS
...  LNBTS-1/LNADJW-14:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-14:primaryPlmnId:mnc=3
...  LNBTS-1/LNADJW-14:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-15:uTargetScFdd=224
...  LNBTS-1/LNADJW-15:uTargetCid=15
...  LNBTS-1/LNADJW-15:uTargetFreq=9692
...  LNBTS-1/LNADJW-15:uTargetLac=1
...  LNBTS-1/LNADJW-15:uTargetRncId=1
...  LNBTS-1/LNADJW-15:uTargetRac=1
...  LNBTS-1/LNADJW-15:srvccHoInd=PSandCS
...  LNBTS-1/LNADJW-15:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-15:primaryPlmnId:mnc=3
...  LNBTS-1/LNADJW-15:primaryPlmnId:mncLength=2
...  LNCEL-2/LNRELW-1:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-1:utranLbAllowed=false
...  LNCEL-2/LNRELW-1:nrControl=automatic
...  LNCEL-2/LNRELW-1:psHoAllowed=allowed
...  LNCEL-2/LNRELW-1:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-1:removeAllowed=true
...  LNCEL-2/LNRELW-1:srvccAllowed=allowed
...  LNCEL-2/LNRELW-1:uTargetCid=2
...  LNCEL-2/LNRELW-1:uTargetRncId=1
...  LNCEL-2/LNRELW-1:plmnId:mcc=262
...  LNCEL-2/LNRELW-1:plmnId:mnc=3
...  LNCEL-2/LNRELW-1:plmnId:mncLength=2
...  LNCEL-2/LNRELW-12:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-12:utranLbAllowed=false
...  LNCEL-2/LNRELW-12:nrControl=automatic
...  LNCEL-2/LNRELW-12:psHoAllowed=allowed
...  LNCEL-2/LNRELW-12:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-12:removeAllowed=false
...  LNCEL-2/LNRELW-12:srvccAllowed=allowed
...  LNCEL-2/LNRELW-12:uTargetCid=12
...  LNCEL-2/LNRELW-12:uTargetRncId=1
...  LNCEL-2/LNRELW-12:plmnId:mcc=262
...  LNCEL-2/LNRELW-12:plmnId:mnc=3
...  LNCEL-2/LNRELW-12:plmnId:mncLength=2
...  LNCEL-2/LNRELW-13:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-13:utranLbAllowed=false
...  LNCEL-2/LNRELW-13:nrControl=automatic
...  LNCEL-2/LNRELW-13:psHoAllowed=allowed
...  LNCEL-2/LNRELW-13:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-13:removeAllowed=true
...  LNCEL-2/LNRELW-13:srvccAllowed=allowed
...  LNCEL-2/LNRELW-13:uTargetCid=13
...  LNCEL-2/LNRELW-13:uTargetRncId=1
...  LNCEL-2/LNRELW-13:plmnId:mcc=262
...  LNCEL-2/LNRELW-13:plmnId:mnc=3
...  LNCEL-2/LNRELW-13:plmnId:mncLength=2
...  LNCEL-2/LNRELW-14:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-14:utranLbAllowed=false
...  LNCEL-2/LNRELW-14:nrControl=automatic
...  LNCEL-2/LNRELW-14:psHoAllowed=allowed
...  LNCEL-2/LNRELW-14:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-14:removeAllowed=true
...  LNCEL-2/LNRELW-14:srvccAllowed=allowed
...  LNCEL-2/LNRELW-14:uTargetCid=14
...  LNCEL-2/LNRELW-14:uTargetRncId=1
...  LNCEL-2/LNRELW-14:plmnId:mcc=262
...  LNCEL-2/LNRELW-14:plmnId:mnc=3
...  LNCEL-2/LNRELW-14:plmnId:mncLength=2
...  LNCEL-2/LNRELW-15:csfbPsHoAllowed=forbidden
...  LNCEL-2/LNRELW-15:utranLbAllowed=false
...  LNCEL-2/LNRELW-15:nrControl=automatic
...  LNCEL-2/LNRELW-15:psHoAllowed=allowed
...  LNCEL-2/LNRELW-15:redirWithSysInfoAllowed=allowed
...  LNCEL-2/LNRELW-15:removeAllowed=true
...  LNCEL-2/LNRELW-15:srvccAllowed=allowed
...  LNCEL-2/LNRELW-15:uTargetCid=15
...  LNCEL-2/LNRELW-15:uTargetRncId=1
...  LNCEL-2/LNRELW-15:plmnId:mcc=262
...  LNCEL-2/LNRELW-15:plmnId:mnc=3
...  LNCEL-2/LNRELW-15:plmnId:mncLength=2
@{eliminate_relation_error_for_instance06_07}
...  delete:LNCEL:a2TimeToTriggerActInterFreqMeas
...  LNCEL-2:a2TimeToTriggerActWcdmaMeas=320ms
@{deltaSCFC_instance_06_07}
...  @{deltaSCFC_instance_All}
...  @{eliminate_relation_error_for_instance06_07}
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=None
@{delta_file_second_Instance_06_07}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  delete:LNCEL-2/LNRELW-1
...  delete:LNBTS-1/LNADJW-12
...  LNBTS-1/LNADJW-14:uTargetLac=2
...  LNBTS-1/LNADJW-14:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-14:primaryPlmnId:mnc=4
...  LNBTS-1/LNADJW-14:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mcc=555
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mnc=10
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mncLength=2
...  LNBTS-1/LNADJW-15:uTargetLac=3
...  LNBTS-1/LNADJW-15:primaryPlmnId:mcc=777
...  LNBTS-1/LNADJW-15:primaryPlmnId:mnc=10
...  LNBTS-1/LNADJW-15:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mcc=555
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mnc=10
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mncLength=2
...  LNCEL-2/LNRELW-13:psHoAllowed=forbidden
...  LNCEL-2/LNRELW-13:srvccAllowed=allowed
...  LNCEL-2/LNRELW-14:psHoAllowed=allowed
...  LNCEL-2/LNRELW-14:srvccAllowed=forbidden
...  LNCEL-2/LNRELW-14:plmnId:mcc=262
...  LNCEL-2/LNRELW-14:plmnId:mnc=4
...  LNCEL-2/LNRELW-14:plmnId:mncLength=2
...  LNBTS-1/LNADJW-14:uTargetRncId=3
...  LNCEL-2/LNRELW-14:uTargetRncId=3
...  LNCEL-2/LNRELW-15:psHoAllowed=allowed
...  LNCEL-2/LNRELW-15:srvccAllowed=forbidden
...  LNBTS-1/LNADJW-15:uTargetRncId=2
...  LNCEL-2/LNRELW-15:uTargetRncId=2
...  LNCEL-2/LNRELW-15:plmnId:mcc=777
...  LNCEL-2/LNRELW-15:plmnId:mnc=10
...  LNCEL-2/LNRELW-15:plmnId:mncLength=2
@{deltaSCFC_instance_11_13_15_16_18}
...  @{deltaSCFC_instance_All}
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=NonVoiceOnly
@{delta_file_second_Instance_11}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  delete:LNCEL-2/LNRELW-1
...  delete:LNBTS-1/LNADJW-12
...  LNBTS-1/LNADJW-14:uTargetLac=2
...  LNBTS-1/LNADJW-14:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-14:primaryPlmnId:mnc=4
...  LNBTS-1/LNADJW-14:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mcc=555
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mnc=10
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mncLength=2
...  LNBTS-1/LNADJW-15:uTargetLac=3
...  LNBTS-1/LNADJW-15:primaryPlmnId:mcc=777
...  LNBTS-1/LNADJW-15:primaryPlmnId:mnc=10
...  LNBTS-1/LNADJW-15:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mcc=555
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mnc=10
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mncLength=2
...  LNCEL-2/LNRELW-13:psHoAllowed=allowed
...  LNCEL-2/LNRELW-13:srvccAllowed=forbidden
...  LNCEL-2/LNRELW-14:psHoAllowed=forbidden
...  LNCEL-2/LNRELW-14:srvccAllowed=allowed
...  LNCEL-2/LNRELW-14:plmnId:mcc=262
...  LNCEL-2/LNRELW-14:plmnId:mnc=4
...  LNCEL-2/LNRELW-14:plmnId:mncLength=2
...  LNBTS-1/LNADJW-14:uTargetRncId=3
...  LNCEL-2/LNRELW-14:uTargetRncId=3
...  LNCEL-2/LNRELW-15:psHoAllowed=forbidden
...  LNCEL-2/LNRELW-15:srvccAllowed=allowed
...  LNBTS-1/LNADJW-15:uTargetRncId=2
...  LNCEL-2/LNRELW-15:uTargetRncId=2
...  LNCEL-2/LNRELW-15:plmnId:mcc=777
...  LNCEL-2/LNRELW-15:plmnId:mnc=10
...  LNCEL-2/LNRELW-15:plmnId:mncLength=2
@{delta_file_second_Instance_13_14}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=false
...  delete:LNCEL-2/LNRELW-1
...  delete:LNBTS-1/LNADJW-12
...  LNBTS-1/LNADJW-14:uTargetLac=2
...  LNBTS-1/LNADJW-14:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-14:primaryPlmnId:mnc=4
...  LNBTS-1/LNADJW-14:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mcc=555
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mnc=10
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mncLength=2
...  LNBTS-1/LNADJW-15:uTargetLac=3
...  LNBTS-1/LNADJW-15:primaryPlmnId:mcc=777
...  LNBTS-1/LNADJW-15:primaryPlmnId:mnc=10
...  LNBTS-1/LNADJW-15:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mcc=555
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mnc=10
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mncLength=2
...  LNCEL-2/LNRELW-13:psHoAllowed=forbidden
...  LNCEL-2/LNRELW-13:srvccAllowed=allowed
...  LNCEL-2/LNRELW-14:psHoAllowed=allowed
...  LNCEL-2/LNRELW-14:srvccAllowed=forbidden
...  LNCEL-2/LNRELW-14:plmnId:mcc=262
...  LNCEL-2/LNRELW-14:plmnId:mnc=4
...  LNCEL-2/LNRELW-14:plmnId:mncLength=2
...  LNBTS-1/LNADJW-14:uTargetRncId=3
...  LNCEL-2/LNRELW-14:uTargetRncId=3
...  LNCEL-2/LNRELW-15:psHoAllowed=allowed
...  LNCEL-2/LNRELW-15:srvccAllowed=forbidden
...  LNBTS-1/LNADJW-15:uTargetRncId=2
...  LNCEL-2/LNRELW-15:uTargetRncId=2
...  LNCEL-2/LNRELW-15:plmnId:mcc=777
...  LNCEL-2/LNRELW-15:plmnId:mnc=10
...  LNCEL-2/LNRELW-15:plmnId:mncLength=2
@{deltaSCFC_instance_14}
...  @{deltaSCFC_instance_All}
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=All
@{delta_file_second_Instance_15}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  delete:LNCEL-2/LNRELW-1
...  delete:LNBTS-1/LNADJW-12
...  LNBTS-1/LNADJW-14:uTargetLac=5
...  LNBTS-1/LNADJW-14:primaryPlmnId:mcc=888
...  LNBTS-1/LNADJW-14:primaryPlmnId:mnc=10
...  LNBTS-1/LNADJW-14:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mcc=777
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mnc=10
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mncLength=2
...  LNBTS-1/LNADJW-15:uTargetLac=3
...  LNBTS-1/LNADJW-15:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-15:primaryPlmnId:mnc=4
...  LNBTS-1/LNADJW-15:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mcc=555
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mnc=10
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mncLength=2
...  LNCEL-2/LNRELW-13:psHoAllowed=forbidden
...  LNCEL-2/LNRELW-13:srvccAllowed=allowed
...  LNCEL-2/LNRELW-14:psHoAllowed=allowed
...  LNCEL-2/LNRELW-14:srvccAllowed=allowed
...  LNCEL-2/LNRELW-14:plmnId:mcc=888
...  LNCEL-2/LNRELW-14:plmnId:mnc=10
...  LNCEL-2/LNRELW-14:plmnId:mncLength=2
...  LNBTS-1/LNADJW-14:uTargetRncId=3
...  LNCEL-2/LNRELW-14:uTargetRncId=3
...  LNCEL-2/LNRELW-15:psHoAllowed=allowed
...  LNCEL-2/LNRELW-15:srvccAllowed=forbidden
...  LNBTS-1/LNADJW-15:uTargetRncId=2
...  LNCEL-2/LNRELW-15:uTargetRncId=2
...  LNCEL-2/LNRELW-15:plmnId:mcc=262
...  LNCEL-2/LNRELW-15:plmnId:mnc=4
...  LNCEL-2/LNRELW-15:plmnId:mncLength=2
@{delta_file_second_Instance_16}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=false
...  delete:LNCEL-2/LNRELW-1
...  delete:LNBTS-1/LNADJW-12
@{deltaSCFC_instance_17}
...  @{deltaSCFC_instance_All}
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=None
@{delta_file_second_Instance_17}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  delete:LNCEL-2/LNRELW-1
...  delete:LNBTS-1/LNADJW-12
@{delta_file_second_Instance_18}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  delete:LNCEL-2/LNRELW-1
...  delete:LNBTS-1/LNADJW-12
...  LNBTS-1/LNADJW-14:uTargetLac=5
...  LNBTS-1/LNADJW-14:primaryPlmnId:mcc=888
...  LNBTS-1/LNADJW-14:primaryPlmnId:mnc=10
...  LNBTS-1/LNADJW-14:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mcc=777
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mnc=10
...  LNBTS-1/LNADJW-14:secondaryPlmnIdL:mncLength=2
...  LNBTS-1/LNADJW-15:uTargetLac=2
...  LNBTS-1/LNADJW-15:primaryPlmnId:mcc=262
...  LNBTS-1/LNADJW-15:primaryPlmnId:mnc=4
...  LNBTS-1/LNADJW-15:primaryPlmnId:mncLength=2
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mcc=555
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mnc=10
...  LNBTS-1/LNADJW-15:secondaryPlmnIdL:mncLength=2
...  LNCEL-2/LNRELW-13:psHoAllowed=forbidden
...  LNCEL-2/LNRELW-13:srvccAllowed=allowed
...  LNCEL-2/LNRELW-14:psHoAllowed=allowed
...  LNCEL-2/LNRELW-14:srvccAllowed=allowed
...  LNCEL-2/LNRELW-14:plmnId:mcc=888
...  LNCEL-2/LNRELW-14:plmnId:mnc=10
...  LNCEL-2/LNRELW-14:plmnId:mncLength=2
...  LNBTS-1/LNADJW-14:uTargetRncId=3
...  LNCEL-2/LNRELW-14:uTargetRncId=3
...  LNCEL-2/LNRELW-15:psHoAllowed=allowed
...  LNCEL-2/LNRELW-15:srvccAllowed=forbidden
...  LNBTS-1/LNADJW-15:uTargetRncId=2
...  LNCEL-2/LNRELW-15:uTargetRncId=2
...  LNCEL-2/LNRELW-15:plmnId:mcc=262
...  LNCEL-2/LNRELW-15:plmnId:mnc=4
...  LNCEL-2/LNRELW-15:plmnId:mncLength=2
@{delta_file_revert_Instance_All}
...  LNBTS-1/LNBTS_FDD-0:actSrvccToWcdma=true
...  delete:LNCEL-2/LNRELW.*
...  delete:LNBTS-1/LNADJW.*
@{PARAMS_IN_SCF}
...  @{deltaSCFC_setup}
...  @{deltaSCFC_other}
...  @{add_REDRT}
...  @{PARAMS_FOR_PMQAP}
...  @{RIM}
...  @{Delete_Neighbour_Relation}
${TTITRACE_FLAG}    ${False}

*** Test Case ***
LTE872_002_Instance_07_psHO_emergency_without_QCI1_HRL_missing_all_LNADJW_PLMNs_accepted
    [Documentation]  comment info are for debug in the future, so keep them.
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Start RTPM And Delta Commission    delta_file=${deltaSCFC_instance_06_07}
    Clear Handover Restriction
    UE Attach With Default Bearer QCI_6    uecapability_for_LTE872=${01_SRVCC_FGI_COM_1_FDD_n_TDD_n_B1_B2_B3_Ue_Cap}
    Steup Dedicated Bearer QCI_9_Emergancy
    Trigger B2 Reconfiguration And Delta Commission    delta_file=${delta_file_second_Instance_06_07}
    # add Equi_plmn will cause HO failure in cus, actually it's not need from case pov, so comment it
    # Add Equiv_plmn For HO Request
    Triger SRVCC With B2 Report UTRAN  ue_id_for_B2=1
    #wait_string_for_srvcc=Simulated LTE->UTRAN HO \ \\(or eCSFB\\) \\(eNB 1->RNC 3 \\(host eNB 7\\) PLMN=262\\:04 LAC=2\\) performed
    Execute Uex Command     ue_detach id=1
    Check Rtpm Counters    pm_reference_file=${CURDIR}${/}Instance7${/}reference_PM.txt


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
    Add Yaml    EPC/MME_POOL_AREA
    ...    - id: 2
    ...    plmn: '777:10'
    ...    mmegi: 2
    ...    tac_list: 33,1,2,3
    Add Yaml    EPC/MME_POOL_AREA
    ...    - id: 3
    ...    plmn: '262:04'
    ...    mmegi: 3
    ...    tac_list: 33,1,2,3
    Add Yaml      EPC/RNC
    ...    - id: 1
    ...    host_enb: 5
    ...    rnc_id: 1
    ...    lac: 1
    ...    plmn: '262:03'
    Add Yaml      EPC/RNC
    ...    - id: 2
    ...    host_enb: 6
    ...    rnc_id: 2
    ...    lac: 3
    ...    plmn: '777:10'
    Add Yaml      EPC/RNC
    ...    - id: 3
    ...    host_enb: 7
    ...    rnc_id: 3
    ...    lac: 2
    ...    plmn: '262:04'
    Update Yaml    EPC/MME_POOL_AREA/1    tac_list: 33
    # origin case include 3 MME pool
    Update Yaml    EPC/MME/1    pool: ['1:1', '2:1', '3:1']
    ${rnc1_enb5_CELL2}    catenate    - {id: 52, technology: utran, rnc: 1, uarfcn: '9692:9292', type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 2, rac: 1, pci: '73:1'}
    ${rnc1_enb5_CELL6}    catenate    - {id: 56, technology: utran, rnc: 1, uarfcn: '9692:9292', type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 12, rac: 1, pci: '73:2'}
    ${rnc1_enb5_CELL7}    catenate    - {id: 57, technology: utran, rnc: 1, uarfcn: '9692:9292', type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 13, rac: 1, pci: '74:0'}
    ${rnc1_enb5_LTE}    catenate    - {id: 1, technology: 'lte', tac: 33, pci: '5:2', earfcn: '1400:19400', eci: '0x0000502'}
    ${rnc3_enb7_CELL8}    catenate    - {id: 78, technology: utran, rnc: 3, uarfcn: '9692:9292', type: FDD,
    ...    shared_plmn_utran: '262:04', cell_identity_utran: 14, rac: 1, pci: '74:1'}
    ${rnc3_enb7_CELL8_LTE}    catenate    - {id: 1, technology: 'lte', tac: 33, pci: '7:1', earfcn: '1400:19400', eci: '0x0000702'}
    ${rnc2_enb6_CELL9}    catenate    - {id: 69, technology: utran, rnc: 2, uarfcn: '9692:9292', type: FDD,
    ...    shared_plmn_utran: '777:10', cell_identity_utran: 15, rac: 1, pci: '74:2'}
    ${rnc2_enb6_CELL9_LTE}    catenate    - {id: 1, technology: 'lte', tac: 33, pci: '6:0', earfcn: '1400:19400', eci: '0x0000602'}

    Add Yaml    BASE_STATIONS
    ...    - id: 5
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.32'
    ...    enb_id: '0x00005'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc1_enb5_CELL2}
    ...      ${rnc1_enb5_CELL6}
    ...      ${rnc1_enb5_CELL7}
    ...      ${rnc1_enb5_LTE}
    Add Yaml    BASE_STATIONS
    ...    - id: 6
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.33'
    ...    enb_id: '0x00006'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc2_enb6_CELL9}
    ...      ${rnc2_enb6_CELL9_LTE}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.34'
    ...    enb_id: '0x00007'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc3_enb7_CELL8}
    ...      ${rnc3_enb7_CELL8_LTE}
    Update Yaml    UEs/bearer_sets/bearer_set_1/1     qci: 6
    Update Yaml    UEs/bearer_sets/bearer_set_1/7     qci: 8
    Update Yaml    UEs/bearer_sets/bearer_set_1/9  qci: 9  gbr_ul:31  gbr_dl:31  mbr_ul:31  mbr_dl:31  pdn:1  priority:1
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
    ${attach_cmd}    catenate    ue_attach id=${UE_ID_FOR_LTE872} cell=2 ue_eutra_capabilities=${uecapability_for_LTE872}
    ...    ue_utra_capabilities=${ue_utra_capabilities_LTE872} attach_type=combined srvcc=true
    Execute Uex Command    ${attach_cmd}

Trigger B2 Reconfiguration And Delta Commission
    [Arguments]    ${delta_file}    ${UE_ID_FOR_LTE872}=${UE1}
    #trigger eventB2: ue_measurement_send meas_id=6 id=${UE_ID_FOR_LTE872} srsrp=62 srsrq=20    eventB2
    ${eventB2}    catenate
    ...    measConfig contains ( measObjectToAddModList contains (
    ...    measObject contains (carrierFreq eq 9692 and cellsToAddModList contains (
    ...    cellsToAddModListUTRA-FDD contains (
    ...    physCellId eq 220, physCellId eq 221, physCellId eq 222, physCellId eq 223, physCellId eq 224 ) ) ) )
    ...    )
    Expect Message Flow
    ...    UE_${UE_ID_FOR_LTE872}:RRC_RRCConnectionReconfiguration ( ${eventB2} )
    ...    alias=eventB2_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${UE_ID_FOR_LTE872} event=A2 srsrp=62 srsrq=20
    Flow Occurred As Expected    alias=eventB2_flow
    Delta Commission Parameters And Wait Cells Onair    ${delta_file}

Steup Dedicated Bearer QCI_9_Emergancy
    [Arguments]    ${UE_ID_FOR_LTE872}=${UE1}
    #Add Dedicate Bearer    qci=9    ue_id=${UE_ID_FOR_LTE872}    filter_id=4    precedence_id=4
    Execute Uex Command    bearer_add ue=${UE_ID_FOR_LTE872} qci=9

Triger SRVCC With B2 Report UTRAN
    [Arguments]  ${ue_id_for_B2}
    ${HO_Required}    catenate
    ...    value contains (HandoverType eq "ltetoutran") and value contains (
    ...    lAI contains ( lAC contains ("0x02") and pLMNidentity contains ("0x62F240"))
    ...    and rAC eq "0x01" and rNC-ID eq 3)
    Expect Message Flow
    ...    MME_1:S1AP_HandoverRequired ( ${HO_Required} )
    ...    MME_1:S1AP_HandoverCommand (value contains (HandoverType eq "ltetoutran"))
    ...    UE_${ue_id_for_B2}:RRC_MobilityFromEUTRACommand (handover contains (targetRAT-Type eq "utra"))
    ...    MME_1:S1AP_UEContextReleaseCommand (value contains (Cause contains (radioNetwork eq "successful-handover")))
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=SRVCC_UTRAN_flow    overall_timeout=60
    ${ue_measurement_send_cmd}  catenate
    ...  ue_measurement_send id=${ue_id_for_B2} event=B2_UTRA srsrp=55 srsrq=20 phycell_id=220 necn0=10 nrscp=61 phycell_id=221 necn0=10 nrscp=61
    ...  phycell_id=222 necn0=10 nrscp=61 phycell_id=223 necn0=10 nrscp=61 phycell_id=224 necn0=10 nrscp=61
    Execute Uex Command  ${ue_measurement_send_cmd}
    Flow Occurred As Expected    alias=SRVCC_UTRAN_flow

Start RTPM And Delta Commission
    [Arguments]    ${delta_file}
    Start Rtpm Counter
    Delta Commission Parameters And Wait Cells Onair    ${delta_file}

Clear Handover Restriction
    [Arguments]    ${forbid_rat}=no_rat_restriction
    # actually clear not need in this case, just keep for debug in the future.
    Execute Egate Command    mme_ho_restriction_list clear id=1
    Execute Egate Command    mme_ho_restriction_list clear id=2
    Execute Egate Command    mme_ho_restriction_list clear id=3
    Execute Egate Command
    ...  ue_mme_param id=1 forbid_rat=${forbid_rat} lte_ho_restrictions=off la_ho_restrictions=off ho_restriction_list_id=no

Add Equiv_plmn For HO Request
    [Arguments]    ${UE_ID_FOR_LTE872}=1
    Execute Egate Command    mme_ho_restriction_list equiv_plmn=777:10 equiv_plmn=262:04 id=4
    Execute Egate Command    ue_mme_param id=${UE_ID_FOR_LTE872} ho_restrictions=lte ho_restriction_list_id=4


# below kw keep for debug in the future, so not remove in case.
#Modify Lua
#    FOR    ${ue_id_number}    IN RANGE    1    11
#        Set Bearer In Lua    bearer_id=1    ue=${ue_id_number}    default=on    qci=6    ip=1.7.11.1
#        ...    trf_type=internal
#        Set Bearer In Lua    bearer_id=7    ue=${ue_id_number}    qci=8
#    END
#    set_mme_pool_area_in_lua    1    262:03    33
#    set_mme_pool_area_in_lua    2    777:10    33
#    set_mme_pool_area_in_lua    3    262:04    33
#    set_mme_pool_in_lua    1    simulated    127.0.0.1    10000    10.0.1.1    36412
#    ...    1:1 2:1 3:1
#    Set Bearer In Lua    bearer_id=9    ue=1    qci=9    gbr_ul=31    gbr_dl=31    mbr_ul=31
#    ...    mbr_dl=31    pdn=1    priority=1
#    Set Pgw In Lua    pgw_id=3    pgw_type=simulated    ip=127.0.0.1:10000    apn=ulm_pgw3.net    devtype=tun    devname=tunPGW3
#    ...    addr=3.7.255.254/16    emergency=on
#    Set Bearer In Lua    bearer_id=14    ue=1    qci=5    ip=3.7.11.1    trf_type=internal    default=on
#    ...    pdn=3    priority=1
#    Set Bearer In Lua    bearer_id=15    ue=1    qci=1    gbr_ul=31    gbr_dl=31    mbr_ul=31
#    ...    mbr_dl=31    pdn=3    priority=1
#    Set Enb In Lua    enb_id=5    enb_type=simulated    plmn=262:03    enb_id_macro=0x00005    s1=10.0.1.32    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Enb In Lua    enb_id=6    enb_type=simulated    plmn=777:10    enb_id_macro=0x00006    s1=10.0.1.33    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Enb In Lua    enb_id=7    enb_type=simulated    plmn=262:04    enb_id_macro=0x00007    s1=10.0.1.34    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Cell In Lua    cell_id=1    enb_id=5    tac=33    pci=5:2    proxy=:2155    eci=0x0000502
#    ...    earfcn=1400:19400
#    Set Cell In Lua    cell_id=1    enb_id=6    tac=33    pci=6:0    proxy=:2156    eci=0x0000602
#    ...    earfcn=1400:19400
#    Set Cell In Lua    cell_id=1    enb_id=7    tac=33    pci=7:1    proxy=:2157    eci=0x0000702
#    ...    earfcn=1400:19400
#    Set Utran Rnc In Lua    utran_rnc_id=1    host_enb_id=5    rnc_id=1    plmn=262:03    lac=1
#    Set Utran Rnc In Lua    utran_rnc_id=2    host_enb_id=6    rnc_id=2    plmn=777:10    lac=3
#    Set Utran Rnc In Lua    utran_rnc_id=3    host_enb_id=7    rnc_id=3    plmn=262:04    lac=2
#    Set Utran Cell In Lua    utran_cell_id=2    rnc_id=1    uarfcn=9692:9292    pci=220    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=2    rac=1
#    Set Utran Cell In Lua    utran_cell_id=6    rnc_id=1    uarfcn=9692:9292    pci=221    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=12    rac=1
#    Set Utran Cell In Lua    utran_cell_id=7    rnc_id=1    uarfcn=9692:9292    pci=222    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=13    rac=1
#    Set Utran Cell In Lua    utran_cell_id=8    rnc_id=3    uarfcn=9692:9292    pci=223    type=FDD    shared_plmn_utran=262:04
#    ...    cell_identity_utran=14    rac=1
#    Set Utran Cell In Lua    utran_cell_id=9    rnc_id=2    uarfcn=9692:9292    pci=224    type=FDD    shared_plmn_utran=777:10
#    ...    cell_identity_utran=15    rac=1
#
#UE Attach With Default Bearer QCI_6 And Dedicated QCI_1_5
#    [Arguments]  ${uecapability_for_LTE872}  ${UE_ID_LTE872}=${UE1}  ${ue_start_id_LTE872}=${UE1}  ${ue_stop_id_LTE872}=${UE1}  ${spid_LTE872}=1
#    UE Attach With Default Bearer QCI_6  uecapability_for_LTE872=${uecapability_for_LTE872}  UE_ID_FOR_LTE872=${UE_ID_LTE872}
#    ...  ue_start_id=${ue_start_id_LTE872}  ue_stop_id=${ue_stop_id_LTE872}  spid=${spid_LTE872}
#    Steup Dedicated Bearer QCI_1_5    UE_ID_FOR_LTE872=${UE_ID_LTE872}
#
#Steup Dedicated Bearer QCI_1_5
#    [Arguments]    ${UE_ID_FOR_LTE872}=${UE1}
#    Iphy Setup Dedicate Bearer    qci=2    ue_id=${UE_ID_FOR_LTE872}    filter_id=2    precedence_id=2
#    Iphy Setup Dedicate Bearer    qci=6    ue_id=${UE_ID_FOR_LTE872}    filter_id=3    precedence_id=3
#
#UE Attach With Default Bearer QCI_6 And Dedicated QCI_1_5_Emergancy
#    [Arguments]  ${uecapability_for_LTE872}  ${UE_ID_LTE872}=${UE1}  ${ue_start_id_LTE872}=${UE1}  ${ue_stop_id_LTE872}=${UE1}  ${spid_LTE872}=1
#    UE Attach With Default Bearer QCI_6  uecapability_for_LTE872=${uecapability_for_LTE872}  UE_ID_FOR_LTE872=${UE_ID_LTE872}
#    ...  ue_start_id=${ue_start_id_LTE872}  ue_stop_id=${ue_stop_id_LTE872}  spid=${spid_LTE872}
#    Steup Dedicated Bearer QCI_1_5_Emergancy    UE_ID_FOR_LTE872=${UE_ID_LTE872}
#
#Steup Dedicated Bearer QCI_1_5_Emergancy
#    [Arguments]    ${UE_ID_FOR_LTE872}=${UE1}
#    Iphy Execute Ue Command Without Kargs  pdn_connect_ue ue=${UE_ID_FOR_LTE872} pdn=3
#    ...  PDN connectivity procedure for emergency PDN 3 \\(EBI of default bearer \\= 6\\) performed
#    Iphy Setup Dedicate Bearer    qci=15    ue_id=${UE_ID_FOR_LTE872}    filter_id=3    precedence_id=3
#
#Enable Handover Restriction
#    [Arguments]    ${forbid_rat}=cdma2000andutran    ${ho_restriction_list_id}=1
#    ${V_3}  catenate
#    ...  mme_ho_restriction_list equiv_plmn=555:10 equiv_plmn=262:04 ta_plmn=262:03 tacs=124,4901 ta_plmn=222:22 tacs=21,22 la_plmn=262:03 lacs=11,12
#    ...  la_plmn=555:10 lacs=2,22 restrict_nr_access=on id=1
#    Iphy Execute Ue Command Without Kargs    ${V_3}
#    ${V_4}  catenate
#    ...  mme_ho_restriction_list equiv_plmn=555:10 equiv_plmn=262:04 ta_plmn=262:03 tacs=124,4901 ta_plmn=222:22 tacs=21,22 la_plmn=262:03 lacs=11,2
#    ...  la_plmn=555:10 lacs=23,22 restrict_nr_access=on id=2
#    Iphy Execute Ue Command Without Kargs    ${V_4}
#    ${V_5}  catenate
#    ...  mme_ho_restriction_list equiv_plmn=555:10 equiv_plmn=262:04 ta_plmn=262:03 tacs=124,4901 ta_plmn=222:22 tacs=21,22 la_plmn=262:03 lacs=11,12
#    ...  la_plmn=555:10 lacs=23,22 restrict_nr_access=on id=3
#    Iphy Execute Ue Command Without Kargs    ${V_5}
#    Iphy Execute Ue Command Without Kargs
#    ...  ue_mme_param id=1 forbid_rat=${forbid_rat} lte_ho_restrictions=on la_ho_restrictions=on ho_restriction_list_id=${ho_restriction_list_id}
#
#Recover Env And Test Teardown
#    [Arguments]    ${UE_ID_FOR_LTE872}=${UE1}    ${delta_file}=${delta_file_revert_Instance_All}
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_mme_param id=1 reset
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    mme_ho_restriction_list clear id=1
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    mme_ho_restriction_list clear id=2
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    mme_ho_restriction_list clear id=3
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    mme_ho_restriction_list clear id=4
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_param id=${UE_ID_FOR_LTE872} reset
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE872} id=2
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE872} id=6
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE872} id=9
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    bearer_del ue=${UE_ID_FOR_LTE872} id=15
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    pdn_disconnect ue=${UE_ID_FOR_LTE872} pdn=3
#    Delta Commission Parameters    ${delta_file}
#    Common Test Teardown And Stop Capture Logs
