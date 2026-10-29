*** Setting ***
Documentation     \##################################################################################################################################
...                   #####################################    #    # ${QC_TEST_CASE_NAME}=    C-Pln_LTE498-A-a-Establishment of RIM Association-succ
...               essf    # CA_DevUL    FT_LTE562    FT_LTE22    FT_LTE1043    FT_CN4777    FT_LTE1740    FT_LTE1925    FT_LTE1196    FT_LTE3303    #
...               ${01_SRVCC_WCDMA_eNACC_B1_B2_B3_gsm900_Ue_Cap}    #0 859FF0200308040B82E0BBFE6CF504408011047320,1 813FF40200189040B82E0BBF868C4    
...               # Verification of Test Case I.LTE498Aa.001a Establishm    #* Test Case *    Instance    LTE CN emu macro    LTE CN emu unit    eNB 
...               SCFC start f    # Verification of Test Case I.LTE498Ag.003 Reception of RAN Information Report -    #* Test Case *    Instance    L
...               TE CN emu macro    #Instance_01    Reception of RAN Information    ################################################################
...               ################################    #######################################################################
...               ul Cases
...               000,2 33035758A6601404EF6513B8878D2920,3 813FF40200189040B82E0BBF868C4000
...               ent of RIM Association - successful Cases.
...               ile (wo .xml) eNB SCFC delta file (wo .xml)
...               successful Case, different System Info Content. Within this test case it is tested that the controlling LTE eNB successfully receiv
...               es a RAN-INFORMATION/Initial Multiple Report PDU sent by the serving GERAN BSC
...               LTE CN emu unit eNB SCFC start file (wo .xml) eNB SCFC delta file (wo .xml)
...               Report, successful Case, different System Info Content 1 WaitAndSendMscLte498Ag_case3_eNB45090 mme SCFC_LTE498_deactiva
...               ted activateLTE498_deltaSCFC
...               Instance_01 Establishment of RIM Association, successful Cases, LTE498 feature flag activation 1 WaitAndSendRimInitialMultipleRepor
...               t mme add_LNADJGs activateLTE498_deltaSCFC
...               Instance_02 Establishment of RIM Association, successful Cases, download delta plan file with additional new LNADJG object (RIM cap
...               able) 2 WaitAndSendRimInitialMultipleReport mme SCFC_missing_LNADJGs add_LNADJGs
...               Instance_03 Establishment of RIM Association, successful Cases, download delta plan file with changed LNADJG object Id 3 WaitAndSen
...               dMscLte498Aa_case1Inst4_eNB45090 mme SCFC_default change_LNADJG-Id
...               Instance_04 Establishment of RIM Association, successful Cases, download delta plan file with LNADJG object removed from RIM blackl
...               ist 4 WaitAndSendRimInitialMultipleReport mme SCFC_LNADJGs_blacklisted remove_LNADJGs_from_blacklist
...               Instance_05 Establishment of RIM Association, successful Cases, download delta plan file with gTragetRac added to LNADJG objects 5
...               WaitAndSendRimInitialMultipleReport mme SCFC_LNADJGs_no_gTargetRac add_gTargetRac_to_LNADJGs

Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4A_CUS
...               owner-kang.xiang    release-RL25    team-SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
${ue_eutra_capabilities_for_LTE498}    813A05C302146990C1F83F07E0FFF7FFBE0020403260
${ue_utra_capabilities_LTE498}    813FF40200189040B82E0BBF868C4000
${ue_geran_cs_capabilities_LTE498}    33035758A6601404EF6513B8878D2920
${ue_geran_ps_capabilities_LTE498}    813FF40200189040B82E0BBF868C4000
@{Delete_Neighbour_Relation}
...  delete:LNADJ.*
...  delete:LNREL.*
...  delete:LNHO.*
...  delete:MODPR.*
...  delete:MOPR.*
...  delete:moPrMappingList
@{deltaSCFC_setup}
...  LNBTS-1:actCSFBRedir=Enabled
...  LNBTS-1:actGsmRedirWithSI=true
...  LNBTS-1:acteNACCtoGSM=true
...  LNCEL-1:threshold2GERAN=62
...  LNCEL-1:threshold2Wcdma=62
...  LNCEL-1/LNHOIF-1:eutraCarrierInfo=2100
...  LNCEL-1/LNHOIF-1:measQuantInterFreq=rsrp
...  LNCEL-1/LNHOIF-2:eutraCarrierInfo=300
...  LNCEL-1/LNHOIF-2:measQuantInterFreq=both
...  LNCEL-1/LNHOIF-2:a3OffsetRsrqInterFreq=10
...  LNCEL-1/LNHOIF-3:eutraCarrierInfo=3000
...  LNCEL-1/LNHOIF-3:measQuantInterFreq=rsrp
...  LNCEL-1/LNHOG-0:bandIndicatorGERAN=dcs1800
...  LNCEL-1/LNHOG-0:reportIntervalGERAN=480ms
...  LNCEL-1/LNHOG-0:nccperm=255
...  LNCEL-1/LNHOG-0:hysB2ThresholdGERAN=4
...  LNCEL-1/LNHOG-0:b2Threshold2RssiGERAN=15
...  LNCEL-1/LNHOG-0:b2TimeToTriggerGERANMeas=512ms
...  LNCEL-1/LNHOG-0:b2Threshold1GERAN=41
...  LNCEL-1/LNHOG-0:arfcnValueListGERAN=512
...  LNCEL-1/LNHOG-1:bandIndicatorGERAN=dcs1800
...  LNCEL-1/LNHOG-1:reportIntervalGERAN=480ms
...  LNCEL-1/LNHOG-1:nccperm=255
...  LNCEL-1/LNHOG-1:hysB2ThresholdGERAN=4
...  LNCEL-1/LNHOG-1:b2Threshold2RssiGERAN=15
...  LNCEL-1/LNHOG-1:b2TimeToTriggerGERANMeas=512ms
...  LNCEL-1/LNHOG-1:b2Threshold1GERAN=41
...  LNCEL-1/LNHOG-1:arfcnValueListGERAN=513
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
...  LNCEL-1/REDRT-2:redirGeranArfcnStructL:redirGeranArfcnPrio=1|redirGeranArfcnValue=513
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
@{deltaSCFC_instance_01_add_LNADJG}
...  LNBTS-1/LNADJG-1:arfcnValueGeran=512
...  LNBTS-1/LNADJG-1:bandIndicatorGeran=dcs1800
...  LNBTS-1/LNADJG-1:basestationColourCode=1
...  LNBTS-1/LNADJG-1:gTargetCi=100
...  LNBTS-1/LNADJG-1:dtm=false
...  LNBTS-1/LNADJG-1:gTargetLac=100
...  LNBTS-1/LNADJG-1:networkColourCode=1
...  LNBTS-1/LNADJG-1:networkControlOrder=NC0
...  LNBTS-1/LNADJG-1:systemInfoType=none
...  LNBTS-1/LNADJG-1:mcc=262
...  LNBTS-1/LNADJG-1:mnc=3
...  LNBTS-1/LNADJG-1:mncLength=2
...  LNBTS-1/LNADJG-1:gTargetRac=1
...  LNBTS-1/LNADJG-2:arfcnValueGeran=513
...  LNBTS-1/LNADJG-2:bandIndicatorGeran=dcs1800
...  LNBTS-1/LNADJG-2:basestationColourCode=1
...  LNBTS-1/LNADJG-2:gTargetCi=200
...  LNBTS-1/LNADJG-2:dtm=false
...  LNBTS-1/LNADJG-2:gTargetLac=200
...  LNBTS-1/LNADJG-2:networkColourCode=1
...  LNBTS-1/LNADJG-2:networkControlOrder=NC0
...  LNBTS-1/LNADJG-2:systemInfoType=none
...  LNBTS-1/LNADJG-2:mcc=262
...  LNBTS-1/LNADJG-2:mnc=3
...  LNBTS-1/LNADJG-2:mncLength=2
...  LNBTS-1/LNADJG-2:gTargetRac=2
...  LNCEL-1/LNRELG-1:ci=100
...  LNCEL-1/LNRELG-1:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-1:lac=100
...  LNCEL-1/LNRELG-1:nrControl=automatic
...  LNCEL-1/LNRELG-1:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELG-1:srvccAllowed=allowed
...  LNCEL-1/LNRELG-1:plmnId:mcc=262
...  LNCEL-1/LNRELG-1:plmnId:mnc=3
...  LNCEL-1/LNRELG-1:plmnId:mncLength=2
...  LNCEL-1/LNRELG-2:ci=200
...  LNCEL-1/LNRELG-2:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-2:lac=200
...  LNCEL-1/LNRELG-2:nrControl=automatic
...  LNCEL-1/LNRELG-2:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELG-2:srvccAllowed=allowed
...  LNCEL-1/LNRELG-2:plmnId:mcc=262
...  LNCEL-1/LNRELG-2:plmnId:mnc=3
...  LNCEL-1/LNRELG-2:plmnId:mncLength=2
@{deltaSCFC_second_instance_01_activeflag}
...  LNBTS-1:actRIMforGSM=true
@{deltaSCFC_instance_02_activeflag_add_LNRELG}
...  LNBTS-1:actRIMforGSM=true
...  LNCEL-1/LNRELG-1:ci=100
...  LNCEL-1/LNRELG-1:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-1:lac=100
...  LNCEL-1/LNRELG-1:nrControl=automatic
...  LNCEL-1/LNRELG-1:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELG-1:srvccAllowed=allowed
...  LNCEL-1/LNRELG-1:plmnId:mcc=262
...  LNCEL-1/LNRELG-1:plmnId:mnc=3
...  LNCEL-1/LNRELG-1:plmnId:mncLength=2
...  LNCEL-1/LNRELG-2:ci=200
...  LNCEL-1/LNRELG-2:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-2:lac=200
...  LNCEL-1/LNRELG-2:nrControl=automatic
...  LNCEL-1/LNRELG-2:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELG-2:srvccAllowed=allowed
...  LNCEL-1/LNRELG-2:plmnId:mcc=262
...  LNCEL-1/LNRELG-2:plmnId:mnc=3
...  LNCEL-1/LNRELG-2:plmnId:mncLength=2
@{deltaSCFC_second_instance_02_add_LNADJG}
...  LNBTS-1/LNADJG-1:arfcnValueGeran=512
...  LNBTS-1/LNADJG-1:bandIndicatorGeran=dcs1800
...  LNBTS-1/LNADJG-1:basestationColourCode=1
...  LNBTS-1/LNADJG-1:gTargetCi=100
...  LNBTS-1/LNADJG-1:dtm=false
...  LNBTS-1/LNADJG-1:gTargetLac=100
...  LNBTS-1/LNADJG-1:networkColourCode=1
...  LNBTS-1/LNADJG-1:networkControlOrder=NC0
...  LNBTS-1/LNADJG-1:systemInfoType=none
...  LNBTS-1/LNADJG-1:mcc=262
...  LNBTS-1/LNADJG-1:mnc=3
...  LNBTS-1/LNADJG-1:mncLength=2
...  LNBTS-1/LNADJG-1:gTargetRac=1
...  LNBTS-1/LNADJG-2:arfcnValueGeran=513
...  LNBTS-1/LNADJG-2:bandIndicatorGeran=dcs1800
...  LNBTS-1/LNADJG-2:basestationColourCode=1
...  LNBTS-1/LNADJG-2:gTargetCi=200
...  LNBTS-1/LNADJG-2:dtm=false
...  LNBTS-1/LNADJG-2:gTargetLac=200
...  LNBTS-1/LNADJG-2:networkColourCode=1
...  LNBTS-1/LNADJG-2:networkControlOrder=NC0
...  LNBTS-1/LNADJG-2:systemInfoType=none
...  LNBTS-1/LNADJG-2:mcc=262
...  LNBTS-1/LNADJG-2:mnc=3
...  LNBTS-1/LNADJG-2:mncLength=2
...  LNBTS-1/LNADJG-2:gTargetRac=2
@{deltaSCFC_instance_03_activeflag}
...  LNBTS-1:actRIMforGSM=true
...  @{deltaSCFC_instance_01_add_LNADJG}
@{deltaSCFC_second_instance_03_change_LNADJGID}
...  LNBTS-1/LNADJG-3:arfcnValueGeran=513
...  LNBTS-1/LNADJG-3:bandIndicatorGeran=dcs1800
...  LNBTS-1/LNADJG-3:basestationColourCode=1
...  LNBTS-1/LNADJG-3:gTargetCi=200
...  LNBTS-1/LNADJG-3:dtm=false
...  LNBTS-1/LNADJG-3:gTargetLac=200
...  LNBTS-1/LNADJG-3:networkColourCode=1
...  LNBTS-1/LNADJG-3:networkControlOrder=NC0
...  LNBTS-1/LNADJG-3:systemInfoType=none
...  LNBTS-1/LNADJG-3:mcc=262
...  LNBTS-1/LNADJG-3:mnc=3
...  LNBTS-1/LNADJG-3:mncLength=2
...  LNBTS-1/LNADJG-3:gTargetRac=2
...  delete:LNADJG-2
@{deltaSCFC_instance_04_add_LNADJG_with_balcklist}
...  LNBTS-1:actRIMforGSM=true
...  RIM-0:blacklistedGsmPlmnsForRim:mcc=262
...  RIM-0:blacklistedGsmPlmnsForRim:mnc=3
...  RIM-0:blacklistedGsmPlmnsForRim:mncLength=2
...  @{deltaSCFC_instance_01_add_LNADJG}
@{deltaSCFC_second_instance_04_del_blacklist}
...  delete:RIM-0:blacklistedGsmPlmnsForRim
@{deltaSCFC_instance_05_add_LNADJG_without_RAC}
...  LNBTS-1:actRIMforGSM=true
...  LNBTS-1/LNADJG-1:arfcnValueGeran=512
...  LNBTS-1/LNADJG-1:bandIndicatorGeran=dcs1800
...  LNBTS-1/LNADJG-1:basestationColourCode=1
...  LNBTS-1/LNADJG-1:gTargetCi=100
...  LNBTS-1/LNADJG-1:dtm=false
...  LNBTS-1/LNADJG-1:gTargetLac=100
...  LNBTS-1/LNADJG-1:networkColourCode=1
...  LNBTS-1/LNADJG-1:networkControlOrder=NC0
...  LNBTS-1/LNADJG-1:systemInfoType=none
...  LNBTS-1/LNADJG-1:mcc=262
...  LNBTS-1/LNADJG-1:mnc=3
...  LNBTS-1/LNADJG-1:mncLength=2
...  LNBTS-1/LNADJG-2:arfcnValueGeran=513
...  LNBTS-1/LNADJG-2:bandIndicatorGeran=dcs1800
...  LNBTS-1/LNADJG-2:basestationColourCode=1
...  LNBTS-1/LNADJG-2:gTargetCi=200
...  LNBTS-1/LNADJG-2:dtm=false
...  LNBTS-1/LNADJG-2:gTargetLac=200
...  LNBTS-1/LNADJG-2:networkColourCode=1
...  LNBTS-1/LNADJG-2:networkControlOrder=NC0
...  LNBTS-1/LNADJG-2:systemInfoType=none
...  LNBTS-1/LNADJG-2:mcc=262
...  LNBTS-1/LNADJG-2:mnc=3
...  LNBTS-1/LNADJG-2:mncLength=2
...  LNCEL-1/LNRELG-1:ci=100
...  LNCEL-1/LNRELG-1:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-1:lac=100
...  LNCEL-1/LNRELG-1:nrControl=automatic
...  LNCEL-1/LNRELG-1:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELG-1:srvccAllowed=allowed
...  LNCEL-1/LNRELG-1:plmnId:mcc=262
...  LNCEL-1/LNRELG-1:plmnId:mnc=3
...  LNCEL-1/LNRELG-1:plmnId:mncLength=2
...  LNCEL-1/LNRELG-2:ci=200
...  LNCEL-1/LNRELG-2:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-2:lac=200
...  LNCEL-1/LNRELG-2:nrControl=automatic
...  LNCEL-1/LNRELG-2:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELG-2:srvccAllowed=allowed
...  LNCEL-1/LNRELG-2:plmnId:mcc=262
...  LNCEL-1/LNRELG-2:plmnId:mnc=3
...  LNCEL-1/LNRELG-2:plmnId:mncLength=2
...  delete:LNBTS-1/LNADJG-1:gTargetRac
...  delete:LNBTS-1/LNADJG-2:gTargetRac
@{deltaSCFC_second_instance_05_add_RAC}
...  LNBTS-1/LNADJG-1:gTargetRac=1
...  LNBTS-1/LNADJG-2:gTargetRac=2
@{Ag_deltaSCFC_instance_01_add_LNADJG}
...  @{deltaSCFC_instance_01_add_LNADJG}
@{Ag_deltaSCFC_second_instance_01_activeflag}
...  @{deltaSCFC_second_instance_01_activeflag}
@{decommission_scf_LTE498}
...  LNBTS-1:actRIMforGSM=false
...  delete:LNADJ.*
...  delete:LNREL.*
@{PARAMS_IN_SCF}
...  @{deltaSCFC_setup}
...  @{deltaSCFC_other}
...  @{add_REDRT}
...  @{RIM}
...  @{Eliminate_Relation_Error}
@{Eliminate_Relation_Error}    delete:LNCEL:defaultLnRelGnbCellId    delete:LNCEL-1/REDRT-4:csFallBPrio    delete:LNCEL-1/REDRT-5:csFallBPrio
${TTITRACE_FLAG}    ${False}
${V_1}
...  SEPARATOR=
...  0026407d000001007a0076007470548e0262f23000210062f2300000001054890062f230006401006458d64b81014c84000000004f81144ec8
...  62f2300064010064061b0102030405060708090a0b0c0d0e0f1011121314000102030405060708090a0b0c0d0e0f1011121314190102030405
...  060708090a0b0c0d0e0f1011121314
${V_2}
...  SEPARATOR=
...  0026407d000001007a0076007470548e0262f23000210062f2300000001054890062f23000c80200c858d64b81014c84000000004f81144ec8
...  62f23000c80200c8061b0102030405060708090a0b0c0d0e0f1011121314000102030405060708090a0b0c0d0e0f1011121314190102030405
...  060708090a0b0c0d0e0f1011121314
${V_3}
...  SEPARATOR=
...  0026407d000001007a0076007470548e0262f23000210062f2300000001054890062f230006401006458d64b81014c84000000014f81064ec8
...  62f2300064010064061b0101010101010101010101010101010101010101000303030303030303030303030303030303030303190202020202
...  020202020202020202020202020202
${V_4}
...  SEPARATOR=
...  0026407d000001007a0076007470548e0262f23000210062f2300000001054890062f23000c80200c858d64b81014c84000000014f81064ec8
...  62f23000c80200c8061b0101010101010101010101010101010101010101000303030303030303030303030303030303030303190202020202
...  020202020202020202020202020202
${V_5}
...  SEPARATOR=
...  0026407d000001007a0076007470548e0262f23000210062f2300000001054890062f230006401006458d64b81014c84000000024f81064ec8
...  62f2300064010064061b0404040404040404040404040404040404040404000505050505050505050505050505050505050505190606060606
...  060606060606060606060606060606
${V_6}
...  SEPARATOR=
...  0026407d000001007a0076007470548e0262f23000210062f2300000001054890062f23000c80200c858d64b81014c84000000024f81064ec8
...  62f23000c80200c8061b0404040404040404040404040404040404040404000505050505050505050505050505050505050505190606060606
...  060606060606060606060606060606

*** Test Case ***
LTE498Aa_001_Instance_01_Establishment_of_RIM_successful_Cases_LTE498_feature_flag_activation
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${deltaSCFC_instance_01_add_LNADJG}
    Check RIM Status available in LNADJG    rimStatus=disabled
    Delta Commission With RIM Sending    delta_file=${deltaSCFC_second_instance_01_activeflag}
    Check RIM Status available in LNADJG
    UE Attach And Trigger SRVCC    UE_ID_FOR_LTE498=1
    [Teardown]    Recover Env And Test Teardown    UE_ID_FOR_LTE498=1    decommission_scf=${decommission_scf_LTE498}

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
    ...    lac: 200
    ...    plmn: '262:03'
    Add Yaml      EPC/RNC
    ...    - id: 5
    ...    host_enb: 3
    ...    rnc_id: 4
    ...    lac: 100
    ...    plmn: '262:03'
    Update Yaml    EPC/MME_POOL_AREA/1    tac_list: 33,1,2,3
    ${rnc1_enb4_CELL1}    catenate    - {id: 41, technology: utran, rnc: 1, uarfcn: '10592:9642',  type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 1, rac: 1, pci: '36:2'}
    ${rnc1_enb4_CELL1_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '4:1', earfcn: '1400:19400', eci: '0x0000401'}
    ${rnc1_enb5_CELL2}    catenate    - {id: 52, technology: utran, rnc: 1, uarfcn: '9692:9292', type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 2, rac: 1, pci: '73:1'}
    ${rnc1_enb5_CELL2_LTE}    catenate    - {id: 1, technology: 'lte', tac: 33, pci: '5:2', earfcn: '1400:19400', eci: '0x0000502'}
    ${rnc2_enb6_CELL3}    catenate    - {id: 63, technology: utran, rnc: 2, uarfcn: '9842:9442', type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 3, rac: 2, pci: '76:2'}
    ${rnc2_enb6_CELL3_LTE}    catenate    - {id: 1, technology: 'lte', tac: 33, pci: '6:0', earfcn: '1400:19400', eci: '0x0000603'}
    ${rnc3_enb7_CELL4}    catenate    - {id: 74, technology: utran, rnc: 3, uarfcn: '10:513', type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 200, rac: 2, pci: '3:0'}
    ${rnc3_enb7_CELL4_LTE}    catenate    - {id: 1, technology: 'lte', tac: 33, pci: '7:1', earfcn: '1400:19400', eci: '0x0000704'}
    ${rnc4_enb3_CELL1}    catenate    - {id: 35, technology: utran, rnc: 4, uarfcn: '10:512', type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 100, rac: 1, pci: '3:1'}
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

Check RIM Status available in LNADJG
    [Arguments]    ${rimStatus}=available    ${LNADJG_ID}=2
    Object Should Exist    LNBTS-1\/LNADJG-1:rimStatus=${rimStatus}
    Object Should Exist    LNBTS-1\/LNADJG-${LNADJG_ID}:rimStatus=${rimStatus}

Delta Commission With RIM Sending
    [Arguments]    ${delta_file}    ${wait_RIM_message}=MME-1: S1:ENB_DIRECT_INFORMATION_TRANSFER
    ${Delta_result}    Delta Commission Parameters    ${delta_file}    background=${True}
    Execute Egate Command    set_log flush    ${wait_RIM_message}    timeout=60s    sleep_time=1
    Start RIM Function in WTS
    Collect Keyword Result    ${Delta_result}

Start RIM Function in WTS
    Execute Egate Command    send_hex source=mme:1 target=enb:1 hex=${V_1}
    Execute Egate Command    send_hex source=mme:1 target=enb:1 hex=${V_2}

UE Attach And Trigger SRVCC
    [Arguments]    ${UE_ID_FOR_LTE498}=1    ${wait_string_for_srvcc}=CCO to GERAN completed
    UE Attach With Default Bearer QCI_6  uecapability_for_LTE498=${ue_eutra_capabilities_for_LTE498}  UE_ID_FOR_LTE498=${UE_ID_FOR_LTE498}
    Trriger SRVCC With B2 Report GERAN  ue_id_for_B2=${UE_ID_FOR_LTE498}
    Execute Uex Command    ue_detach id=${UE_ID_FOR_LTE498}

UE Attach With Default Bearer QCI_6
    [Arguments]    ${uecapability_for_LTE498}    ${UE_ID_FOR_LTE498}=${UE1}    ${spid}=1
    Execute Egate Command    ue_mme_param id=${UE_ID_FOR_LTE498} spid=${spid}
    Execute Egate Command    ue_mme_param id=${UE_ID_FOR_LTE498} srvcc_operation_possible=yes
    Execute Egate Command    ue_param id=${UE_ID_FOR_LTE498} srvcc=on
    ${attach_cmd}    catenate    ue_attach id=${UE_ID_FOR_LTE498} cell=1 ue_eutra_capabilities=${uecapability_for_LTE498}
    ...    ue_utra_capabilities=${ue_utra_capabilities_LTE498} ue_geran_cs_capabilities=${ue_geran_cs_capabilities_LTE498}
    ...    ue_geran_ps_capabilities=${ue_geran_ps_capabilities_LTE498} attach_type=combined srvcc=true
    Execute Uex Command    ${attach_cmd}

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
    Execute Uex Command    ue_measurement_send id=${ue_id_for_B2} event=B2_GERAN srsrp=15 srsrq=20 phycell_id=1:1 nrssi=15 arfcn=513
    Flow Occurred As Expected    alias=SRVCC_GERAN_flow

Recover Env And Test Teardown
    [Arguments]    ${UE_ID_FOR_LTE498}=${UE1}    ${decommission_scf}=${empty}
    Execute Egate Command    ue_mme_param id=1 reset
    Execute Egate Command    ue_param id=${UE_ID_FOR_LTE498} reset
    Delta Commission Parameters And Wait Cells Onair    ${decommission_scf}
    Common Test Teardown And Stop Capture Logs



#Below KW for future debug.
#Start RIM Function in WTS 2nd With Different Si
#    Iphy Execute Ue Command Without Kargs    send_hex source=mme:1 target=enb:1 hex=${V_3}
#    Iphy Execute Ue Command Without Kargs    send_hex source=mme:1 target=enb:1 hex=${V_4}
#
#Start RIM Function in WTS 3rd With Different Si
#    Iphy Execute Ue Command Without Kargs    send_hex source=mme:1 target=enb:1 hex=${V_5}
#    Iphy Execute Ue Command Without Kargs    send_hex source=mme:1 target=enb:1 hex=${V_6}

#Trriger SRVCC With B2 Report GERAN
#    [Arguments]  ${ue_id_for_B2}  ${wait_string_for_srvcc}=${empty}  ${wait_string_for_InterRAT_A2}=rrcConnectionReconfigurationComplete
#    ...  ${phycell_id_for_LTE498}=9  ${arfcn_for_LTE498}=513  ${wait_string_for_B2}=eventB2
#    Iphy Execute Ue Command Without Kargs    ue_measurement_send meas_id=7 id=${ue_id_for_B2} srsrp=65 srsrq=20    ${wait_string_for_InterRAT_A2}
#    Iphy Execute Ue Command Without Kargs    ue_measurement_send meas_id=6 id=${ue_id_for_B2} srsrp=62 srsrq=20    ${wait_string_for_B2}
#    Iphy Execute Ue Command Without Kargs  ue_srvcc id=${ue_id_for_B2} type=geran phycellid=${phycell_id_for_LTE498} arfcn=${arfcn_for_LTE498}
#    ...  ${wait_string_for_srvcc}

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
#    Set Enb In Lua    enb_id=5    enb_type=simulated    plmn=262:03    enb_id_macro=0x00005    s1=10.0.1.32    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Cell In Lua    cell_id=1    enb_id=5    tac=33    pci=5:2    proxy=:2155    eci=0x0000502
#    ...    earfcn=1400:19400
#    Set Utran Rnc In Lua    utran_rnc_id=2    host_enb_id=5    rnc_id=1    plmn=262:03    lac=1
#    Set Utran Cell In Lua    utran_cell_id=2    rnc_id=1    uarfcn=9692:9292    pci=220    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=2    rac=1
#    Set Enb In Lua    enb_id=6    enb_type=simulated    plmn=262:03    enb_id_macro=0x00006    s1=10.0.1.33    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Cell In Lua    cell_id=1    enb_id=6    tac=33    pci=6:0    proxy=:2156    eci=0x0000603
#    ...    earfcn=1400:19400
#    Set Utran Rnc In Lua    utran_rnc_id=3    host_enb_id=6    rnc_id=2    plmn=262:03    lac=2
#    Set Utran Cell In Lua    utran_cell_id=3    rnc_id=2    uarfcn=9842:9442    pci=230    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=3    rac=2
#    Set Enb In Lua    enb_id=7    enb_type=simulated    plmn=262:03    enb_id_macro=0x00007    s1=10.0.1.34    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Cell In Lua    cell_id=1    enb_id=7    tac=33    pci=7:1    proxy=:2157    eci=0x0000704
#    ...    earfcn=1400:19400
#    Set Utran Rnc In Lua    utran_rnc_id=4    host_enb_id=7    rnc_id=3    plmn=262:03    lac=200
#    Set Utran Cell In Lua    utran_cell_id=4    rnc_id=3    uarfcn=10:513    pci=9    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=200    rac=2
#    Set Enb In Lua    enb_id=3    enb_type=simulated    plmn=262:03    enb_id_macro=0x00003    s1=10.0.1.35    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Cell In Lua    cell_id=1    enb_id=3    tac=33    pci=0:0    proxy=:2158    eci=0x0000301
#    ...    earfcn=1400:19400
#    Set Utran Rnc In Lua    utran_rnc_id=5    host_enb_id=3    rnc_id=4    plmn=262:03    lac=100
#    Set Utran Cell In Lua    utran_cell_id=5    rnc_id=4    uarfcn=10:512    pci=10    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=100    rac=1
