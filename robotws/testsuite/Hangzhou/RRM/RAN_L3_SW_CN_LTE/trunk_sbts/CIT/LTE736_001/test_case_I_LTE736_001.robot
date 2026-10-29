*** Setting ***
Documentation     \##################################################################################################################################
...                   #####################################    #${QC_TEST_CASE_NAME}=    C-Pln_LTE736_CSFB via PS-HO to WCDMA in case Ue is idle    #
...               ${QC    #${TESTCASE_ID}=    I.LTE736.001    #CA_DevUL    FT_LTE1073    FT_LTE736    FT_LTE2162    #Verificat    #    core emu    B1
...                measurement    type    revert    #* Test Case *    Instance    preparation    Ue capability script    preparation    of Extended S
...               ervice Request    delta    #Instan    #Instance_02    CSFB PSHO not executed due to no WCDMA relations with csfbPsHoAllowed set to 
...               allowed found, normal CSFB redirect t    #Instance_03    CSFB PSHO not executed due to no B1 measurement report received from Ue, n
...               ormal CSFB redirect to M    #Instance_04    CSFB PSHO not executed due to no B1 measurement report received from Ue,    #Instance_0
...               5    CSFB PSHO not executed due to LNADJW m    #Instance_06    CS    #Instance_07    CSFB PSHO executed to WCDMA cell reported in B
...               1 measurement report    7    not_appl    01_FGIbits8_15_11_WCDMA_    #Instance_08    CSFB PSHO executed to WC    #Instance_09    CS
...               FB PSHO not executed    #Ins    #Instance_11    CSFB PSHO not executed due to HO preparation fails, emergency CSFB redirect to MODR
...               ED    11    SGSN_stop    #Instance_12    ########    ##############################################################################
...               #####################################################    #############################
...
...               _TEST_CASE_VERSION}= 1.0
...               ion of Test Case I.LTE736.001 Successful CS fallback procedure via PS-HO of idle Ue'S during different side conditions (establishme
...               nt cause, HRL configuration, Ue capabilities, LTE2162 flag settings etc.).
...
...               ce_01 CSFB PSHO not executed due to FGI Bit15 B1 measurement UE capability set to disabled, normal CSFB redirect to MODRED 1
...               not_appl 01_FGIbits8_15_10_WCDMA_B1_GSM_DCS_Ue_Capabilities.txt not_applicable mo_Extended_Service_Request not_ap
...
...               o MODRED 2 HRL_modify 01_FGIbits8_15_11_WCDMA_B1_GSM_DCS_Ue_Capabilities.txt not_applicable mo_Extended_Service_Requ
...               est not_ap
...               ODRED with highest emergency prio 3 HRL_modify 01_FGIbits8_15_11_WCDMA_B1_GSM_DCS_Ue_Capabilities.txt not_applicable
...               em_Extended_Service_Request not_ap
...               no redirect targets found, CSFB redirect to frequency used in B1 meas. 4 not_appl 01_FGIbits8_15_11_WCDMA_B1_GSM_____Ue_Ca
...               pabilities.txt not_applicable mt_Extended_Service_Request not_ap
...               issing for LNRELW with csfbPsHoAllowed set to allowed, normal CSFB redirect to MODRED with highest em. prio 5 not_appl 01_
...               FGIbits8_15_11_WCDMA_B1_GSM_DCS_Ue_Capabilities.txt not_applicable em_Extended_Service_Request eNB_A
...               FB PSHO not executed due to prevent WCDMA PS-HO set to NonVoiceOnly, normal CSFB redirect to frequency received in B1 meas. report
...               6 not_appl 01_FGIbits8_15_11_WCDMA_B1_GSM_DCS_Ue_Capabilities.txt B1_f1b1pci_1 mt_Extended_Service_Request not_ap
...
...               B1_GSM_DCS_Ue_Capabilities.txt B1_f1b1pci_1 mt_Extended_Service_Request not_ap
...               DMA cell reported in B1 measurement report after HRL filtering (second reported pci) 8 HRL_modify 01_FGIbits8_15_11_WCDMA_
...               B1_GSM_DCS_Ue_Capabilities.txt B1_f1b1pci_1_5 mo_Extended_Service_Request eNB_A
...               due to FGI Bit8 WCDMA PS HO UE capability set to disabled, normal CSFB redirect to frequency received in B1 meas. report 9 HR
...               L_modify 01_FGIbits8_15_01_WCDMA_B1_GSM_DCS_Ue_Capabilities.txt B1_f1b1pci_1 em_Extended_Service_Request not_ap
...               tance_10 CSFB PSHO not executed due to prevent WCDMA PS-HO set to All, normal CSFB redirect to frequency received in B1 meas. re
...               port 10 not_appl 01_FGIbits8_15_11_WCDMA_B1_GSM_DCS_Ue_Capabilities.txt B1_f1b1pci_1 mo_Extended_Service_Request
...               not_ap
...               01_FGIbits8_15_11_WCDMA_B1_GSM_DCS_Ue_Capabilities.txt B1_f1b1pci_1 em_Extended_Service_Request not_ap
...               CSFB PSHO not executed due to HO preparation fails, normal CSFB redirect to frequency received in B1 meas. report 12 SGSN_
...               stop 01_FGIbits8_15_11_WCDMA_B1_GSM_____Ue_Capabilities.txt B1_f1b1pci_1 mo_Extended_Service_Request not_ap


Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CIT    CLOUD_R4A_CUS
...               owner-kang.xiang    release-RL25    team-SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variable ***
${01_FGIbits8_15_10_WCDMA_B1_GSM_DCS_Ue_Capabilities}    819FF030030804081705C177F0DDC80880000480
${01_FGIbits8_15_11_WCDMA_B1_GSM_DCS_Ue_Capabilities}    819FF030030804081705C177F0FDC80880000480
${01_FGIbits8_15_11_WCDMA_B1_GSM_____Ue_Capabilities}    819FF030030804081705C177F0FDC8080000
${01_FGIbits8_15_01_WCDMA_B1_GSM_DCS_Ue_Capabilities}    819FF030030804081705C177E0FDC80880000480
${ue_utra_capabilities_LTE736}    813FF40200189040B82E0BBF868C4000
@{Delete_Neighbour_Relation}
...  delete:LNADJ.*
...  delete:LNREL.*
...  delete:LNHO.*
...  delete:MOPR.*
...  delete:LNCEL-1:moPrMappingList
@{deltaSCFC_setup}
...  LNBTS-1:actCSFBRedir=Enabled
...  LNBTS-1:actEmerCallRedir=Enabled
...  LNBTS-1:actRedirect=enabled
...  LNBTS-1:actHOtoWcdma=true
...  LNBTS-1:actCsfbPsHoToUtra=true
...  LNBTS-1:actSelMobPrf=true
...  LNBTS-1:actFlexQCIARPPMProfiles=true
...  LNBTS-1/LNBTS_FDD-0:actIMSEmerSessR9=true
...  LNBTS-1:tS1RelPrepU=5000
...  LNCEL-1:furtherPlmnIdL:mcc=555
...  LNCEL-1:furtherPlmnIdL:mnc=10
...  LNCEL-1:furtherPlmnIdL:mncLength=2
...  LNCEL-1:furtherPlmnIdL:autoRemovalAllowed=false
...  LNCEL-1:furtherPlmnIdL:cellReserve=Not Reserved
...  LNBTS-1/MODPR-0:autoAdapt=false
...  LNBTS-1/MODPR-0:autoAdaptIMLB=false
...  LNBTS-1/MODPR-0:idleLBPercentageOfUes=0
...  LNBTS-1/MODPR-0:idleLBPercCaUe=0
...  LNBTS-1/MODPR-0:targetSelMethod=SIB_based
...  LNBTS-1/MODPR-0:freqLayListLte=300,1400
...  LNBTS-1/MODPR-0:freqLayListSrvccWcdma=9842,1192
...  LNBTS-1/MODPR-0:freqLayListPsHoWcdma=10592,9692,9842
...  LNBTS-1/MODPR-0:freqLayListCsfbNormWcdma=10592,9692,9842
...  LNBTS-1/MODPR-0:freqLayListCsfbHighWcdma=10592,9692,9842
...  LNBTS-1/MODPR-0/MODRED-0:redirRAT=utraFDD
...  LNBTS-1/MODPR-0/MODRED-0:addGsmSIToRedirMsg=both
...  LNBTS-1/MODPR-0/MODRED-0:addUtranSIToRedirMsg=both
...  LNBTS-1/MODPR-0/MODRED-0:csFallBPrio=1
...  LNBTS-1/MODPR-0/MODRED-0:emerCallPrio=2
...  LNBTS-1/MODPR-0/MODRED-0:redirectPrio=1
...  LNBTS-1/MODPR-0/MODRED-0:redirFreqUtra=10600
...  LNBTS-1/MODPR-0/MODRED-1:redirRAT=geran
...  LNBTS-1/MODPR-0/MODRED-1:addGsmSIToRedirMsg=both
...  LNBTS-1/MODPR-0/MODRED-1:addUtranSIToRedirMsg=both
...  LNBTS-1/MODPR-0/MODRED-1:redirGeranBandIndicator=gsm1800
...  LNBTS-1/MODPR-0/MODRED-1:csFallBPrio=2
...  LNBTS-1/MODPR-0/MODRED-1:emerCallPrio=1
...  LNBTS-1/MODPR-0/MODRED-1:redirectPrio=2
...  LNBTS-1/MODPR-0/MODRED-1:redirGeranArfcnStructL:redirGeranArfcnPrio=1
...  LNBTS-1/MODPR-0/MODRED-1:redirGeranArfcnStructL:redirGeranArfcnValue=578
...  LNCEL-1:actDrx=true
...  LNCEL-1:actDrxDuringMeasGap=true
...  LNCEL-1/LNHOW-0:utraCarrierFreq=10592
...  LNCEL-1/LNHOW-1:utraCarrierFreq=9692
...  LNCEL-1/LNHOW-2:utraCarrierFreq=9842
...  LNCEL-1/LNHOW-3:utraCarrierFreq=1192
...  LNCEL-1/LNHOW-0:b1ThresholdCSFBUtraRscp=15
...  LNCEL-1/LNHOW-1:b1ThresholdCSFBUtraRscp=15
...  LNCEL-1/LNHOW-2:b1ThresholdCSFBUtraRscp=15
...  LNCEL-1/LNHOW-3:b1ThresholdCSFBUtraRscp=15
...  LNCEL-1/SIB-0:t301=2000ms
...  LNCEL-1/SIB-0:t311=30000ms
...  LNCEL-1:t304InterRAT=500ms
...  LNCEL-1:t304InterRATGsm=500ms
...  LNBTS-1:tS1RelOvDeltU=1000
...  LNBTS-1:tS1RelOvDeltG=1000
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
...  LNBTS-1/LNADJW-3:srvccHoInd=PSandCS
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
@{deltaSCFC_other}
...  LNBTS-1:actERabModify=true
...  LNBTS-1:actEnhAcAndGbrServices=true
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
...  LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=380
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
...  LNCEL-1/REDRT-4:csFallBPrio=${empty}
...  LNCEL-1/REDRT-4:emerCallPrio=${empty}
...  LNCEL-1/REDRT-5:redirRat=cdma2000HRPD
...  LNCEL-1/REDRT-5:redirectPrio=6
...  LNCEL-1/REDRT-5:redirBandCdma=bc1
...  LNCEL-1/REDRT-5:redirFreqCdma=333
...  LNCEL-1/REDRT-5:csFallBPrio=${empty}
...  LNCEL-1/REDRT-5:emerCallPrio=${empty}
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
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=None
...  LNBTS-1/MODPR-0/MODRED-0:redirFreqUtra=10600
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=allowed
...  LNCEL-1/LNRELW-0:removeAllowed=true
@{deltaSCFC_instance_02}
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=None
...  LNBTS-1/MODPR-0/MODRED-0:redirFreqUtra=10600
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=forbidden
...  LNCEL-1/LNRELW-0:removeAllowed=true
@{deltaSCFC_instance_03}
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=None
...  LNBTS-1/MODPR-0/MODRED-0:redirFreqUtra=10600
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=allowed
...  LNCEL-1/LNRELW-0:removeAllowed=true
@{deltaSCFC_instance_04}
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=None
...  LNBTS-1/MODPR-0/MODRED-0:redirFreqUtra=1192
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=allowed
...  LNCEL-1/LNRELW-0:removeAllowed=true
@{deltaSCFC_instance_05}
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=allowed
...  LNCEL-1/LNRELW-0:removeAllowed=false
...  delete:LNADJW-0
@{revertSCFC_instance_05}
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
@{deltaSCFC_instance_06}
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=NonVoiceOnly
...  LNBTS-1/MODPR-0/MODRED-0:redirFreqUtra=10600
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=allowed
...  LNCEL-1/LNRELW-0:removeAllowed=true
@{deltaSCFC_instance_07}
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=None
...  LNBTS-1/MODPR-0/MODRED-0:redirFreqUtra=10600
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=allowed
...  LNCEL-1/LNRELW-0:removeAllowed=true
@{deltaSCFC_instance_09}
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=None
...  LNBTS-1/MODPR-0/MODRED-0:redirFreqUtra=10600
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=allowed
...  LNCEL-1/LNRELW-0:removeAllowed=true
@{deltaSCFC_instance_10}
...  LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=All
...  LNBTS-1/MODPR-0/MODRED-0:redirFreqUtra=10600
...  LNCEL-1/LNRELW-0:csfbPsHoAllowed=allowed
...  LNCEL-1/LNRELW-0:removeAllowed=true
@{PARAMS_IN_SCF}
...  @{deltaSCFC_setup}
...  @{deltaSCFC_other}
...  @{add_REDRT}
...  @{PARAMS_FOR_PMQAP}
...  @{RIM}
...  @{Delete_Neighbour_Relation}
...  @{Eliminate_Relation_Error}
@{Eliminate_Relation_Error}
...  LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=1
...  LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=-1
...  delete:LNCEL:defaultLnRelGnbCellId
${TTITRACE_FLAG}    ${False}

*** Test Case ***
LTE736_001_Instance_01_CSFB_PSHO_not_executed_due_to_FGI_Bit15_B1_measurement_UE_capability_set_to_disabled_normal_CSFB_redirect_to_MODRED
    [Tags]
    Start RTPM And Delta Commission    delta_file=${deltaSCFC_instance_01}
    Clear Handover Restriction    UE_ID_forbid_rat=1
    UE Attach With Default Bearer QCI_6  uecapability_for_LTE736=${01_FGIbits8_15_10_WCDMA_B1_GSM_DCS_Ue_Capabilities}  UE_ID_FOR_LTE736=1
    Trriger MME S1 Release With Normal    ue_id_for_release=1
    Trriger CSFB PSHO    ue_id_for_csfb_PSHO=1    SERVICE_TYPE=mo-Data
    Execute Uex Command    ue_detach id=1
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
    Update Yaml    UEs/bearer_sets/bearer_set_1/1    qci: 6
    Update Yaml    UEs/bearer_sets/bearer_set_1/7    qci: 8
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
    ...    host_enb: 8
    ...    rnc_id: 5
    ...    lac: 5
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
    ${rnc5_enb8_CELL5}    catenate    - {id: 85, technology: utran, rnc: 5, uarfcn: '10592:9642',  type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 77, rac: 5, pci: '92:1'}
    ${rnc5_enb8_CELL5_LTE}   catenate    - {id: 1, technology: 'lte', tac: 33, pci: '8:2', earfcn: '1400:19400', eci: '0x0000805'}

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
    ...    - id: 8
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.35'
    ...    enb_id: '0x00008'
    ...    x2_peers: none
    ...    cells:
    ...      ${rnc5_enb8_CELL5}
    ...      ${rnc5_enb8_CELL5_LTE}

UE Attach With Default Bearer QCI_6
    [Arguments]  ${uecapability_for_LTE736}  ${UE_ID_FOR_LTE736}=${UE1}  ${spid}=1  ${srvcc_operation_possible}=yes
    # srvcc is not mandatory for this case
    Execute Egate Command    ue_mme_param id=${UE_ID_FOR_LTE736} spid=${spid}
    Execute Egate Command    ue_mme_param id=1 srvcc_operation_possible=${srvcc_operation_possible}
    Execute Egate Command    ue_param id=${UE_ID_FOR_LTE736} srvcc=on
    ${attach_cmd}    catenate    ue_attach id=${UE_ID_FOR_LTE736} cell=1 ue_eutra_capabilities=${uecapability_for_LTE736}
    ...  ue_utra_capabilities=${ue_utra_capabilities_LTE736} attach_type=combined srvcc=true
    Execute Uex Command    ${attach_cmd}

Start RTPM And Delta Commission
    [Arguments]    ${delta_file}
    Start Rtpm Counter
    Delta Commission Parameters And Wait Cells Onair    ${delta_file}

Clear Handover Restriction
    [Arguments]    ${forbid_rat}=no_rat_restriction    ${UE_ID_forbid_rat}=1
    Execute Egate Command    ho_restriction_list clear id=1
    Execute Egate Command    ho_restriction_list clear id=2
    Execute Egate Command
    ...  ue_mme_param id=${UE_ID_forbid_rat} forbid_rat=${forbid_rat} lte_ho_restrictions=off la_ho_restrictions=off ho_restriction_list_id=no

Trriger MME S1 Release With Normal
    [Arguments]    ${ue_id_for_release}    ${cause_nas}=normal_release
#    Expect Message Flow
#    ...    UE_${ue_id_for_release}:RRC_RRCConnectionRelease ( releaseCause eq "other")
#    ...    MME_1:S1AP_UEContextReleaseComplete
#    ...    alias=s1_release_flow    overall_timeout=60
    Execute Egate Command    ue_s1_ctx_release id=${ue_id_for_release} cause_nas=${cause_nas}    UEContextReleaseComplete
#    Flow Occurred As Expected    alias=s1_release_flow

Trriger CSFB PSHO
    [Arguments]    ${ue_id_for_csfb_PSHO}    ${SERVICE_TYPE}
    #    Can't set mme_param to RN_cs_fallback_triggered here due to recover is unavailable for case requirement
    #    Iphy Execute Ue Command Without Kargs    mme_param id=1 ue_ctx_release_cause=RN_cs_fallback_triggered
    ${no_rrc_reconfig_check}    catenate
    ...    rrcConnectionReconfiguration is present
    Expect Message Will Not Occur
        ...    UE_${ue_id_for_csfb_PSHO}:RRC_RRCConnectionReconfiguration ( ${no_rrc_reconfig_check} )
        ...    alias=no_rrc_reconfig_check    overall_timeout=60
    Expect Message Flow
    ...    MME_1:S1AP_InitialUEMessage ( value contains ( RRC-Establishment-Cause eq "mo-Data" ) )
    ...    UE_${ue_id_for_csfb_PSHO}:RRC_RRCConnectionRelease ( redirectedCarrierInfo contains ( utra-FDD eq 10600 ) )
    ...    MME_1:S1AP_UEContextReleaseRequest ( value contains ( radioNetwork eq "cs-fallback-triggered" ) )
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=csfb_psho_flow    overall_timeout=60
    Execute Uex Command  ue_csfb id=${ue_id_for_csfb_PSHO} cause=${SERVICE_TYPE} ran=utra
    Flow Occurred As Expected    alias=csfb_psho_flow
    Flow Not Occurred For Message    alias=no_rrc_reconfig_check
    #    Iphy Execute Ue Command Without Kargs    mme_param id=1 ue_ctx_release_cause=MISC_CauseMisc_unspecified


# Below kw keep for debug in the future.
#Modify Lua
#    FOR    ${ue_id_number}    IN RANGE    1    11
#        Set Bearer In Lua    bearer_id=1    ue=${ue_id_number}    default=on    qci=6    ip=1.7.11.1
#        ...    priority=8    preemption=on    vulnerability=on    trf_type=internal
#        Set Bearer In Lua    bearer_id=7    ue=${ue_id_number}    qci=8
#    END
#    Set Enb In Lua    enb_id=4    enb_type=simulated    plmn=262:03    enb_id_macro=0x00004    s1=10.0.1.31    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Enb In Lua    enb_id=5    enb_type=simulated    plmn=262:03    enb_id_macro=0x00005    s1=10.0.1.32    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Enb In Lua    enb_id=6    enb_type=simulated    plmn=262:03    enb_id_macro=0x00006    s1=10.0.1.33    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Enb In Lua    enb_id=7    enb_type=simulated    plmn=262:03    enb_id_macro=0x00007    s1=10.0.1.34    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Enb In Lua    enb_id=8    enb_type=simulated    plmn=262:03    enb_id_macro=0x00008    s1=10.0.1.35    edamon_ip=127.0.0.1
#    ...    edamon_port=10000    x2_peers=none
#    Set Cell In Lua    cell_id=1    enb_id=4    tac=33    pci=4:1    proxy=:2154    eci=0x0000401
#    ...    earfcn=1400:19400
#    Set Cell In Lua    cell_id=1    enb_id=5    tac=33    pci=5:2    proxy=:2155    eci=0x0000502
#    ...    earfcn=1400:19400
#    Set Cell In Lua    cell_id=1    enb_id=6    tac=33    pci=6:0    proxy=:2156    eci=0x0000603
#    ...    earfcn=1400:19400
#    Set Cell In Lua    cell_id=1    enb_id=7    tac=33    pci=7:1    proxy=:2157    eci=0x0000704
#    ...    earfcn=1400:19400
#    Set Cell In Lua    cell_id=1    enb_id=8    tac=33    pci=8:2    proxy=:2158    eci=0x0000805
#    ...    earfcn=1400:19400
#    Set Utran Rnc In Lua    utran_rnc_id=1    host_enb_id=4    rnc_id=1    plmn=262:03    lac=1
#    Set Utran Rnc In Lua    utran_rnc_id=2    host_enb_id=5    rnc_id=1    plmn=262:03    lac=1
#    Set Utran Rnc In Lua    utran_rnc_id=3    host_enb_id=6    rnc_id=2    plmn=262:03    lac=2
#    Set Utran Rnc In Lua    utran_rnc_id=4    host_enb_id=7    rnc_id=3    plmn=262:03    lac=3
#    Set Utran Rnc In Lua    utran_rnc_id=5    host_enb_id=8    rnc_id=5    plmn=262:03    lac=5
#    Set Utran Cell In Lua    utran_cell_id=1    rnc_id=1    uarfcn=10592:9642    pci=110    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=1    rac=1
#    Set Utran Cell In Lua    utran_cell_id=2    rnc_id=1    uarfcn=9692:9292    pci=220    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=2    rac=1
#    Set Utran Cell In Lua    utran_cell_id=3    rnc_id=2    uarfcn=9842:9442    pci=230    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=3    rac=2
#    Set Utran Cell In Lua    utran_cell_id=4    rnc_id=3    uarfcn=1192:967    pci=340    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=4    rac=3
#    Set Utran Cell In Lua    utran_cell_id=5    rnc_id=5    uarfcn=10592:9642    pci=277    type=FDD    shared_plmn_utran=262:03
#    ...    cell_identity_utran=77    rac=5
#
#Enable Handover Restriction
#    [Arguments]    ${forbid_rat}=geran    ${ho_restriction_list_id}=1    ${UE_ID_forbid_rat}=1
#    ${V_1}  catenate
#    ...  ho_restriction_list equiv_plmn=555:10 equiv_plmn=262:04 ta_plmn=262:03 tacs=124,4901 ta_plmn=222:22 tacs=21,22 la_plmn=262:58 lacs=11,12
#    ...  la_plmn=888:10 lacs=44,22 restrict_nr_access=on id=1
#    Iphy Execute Ue Command Without Kargs    ${V_1}
#    ${V_2}  catenate
#    ...  ho_restriction_list equiv_plmn=555:10 equiv_plmn=262:04 ta_plmn=262:03 tacs=124,4901 ta_plmn=222:22 tacs=21,22 la_plmn=262:03 lacs=1,12
#    ...  la_plmn=555:10 lacs=4,22 restrict_nr_access=on id=2
#    Iphy Execute Ue Command Without Kargs    ${V_2}
#    ${V_3}  catenate  ue_mme_param id=${UE_ID_forbid_rat} forbid_rat=${forbid_rat} lte_ho_restrictions=on la_ho_restrictions=on
#    ...  ho_restriction_list_id=${ho_restriction_list_id}
#    Iphy Execute Ue Command Without Kargs    ${V_3}
#
#Trriger CSFB PSHO With Emergancy
#    [Arguments]  ${ue_id_for_csfb_psho_rrcest}  ${ue_id_for_csfb_psho_em}  ${ue_id_for_csfb_psho_reset}  ${CSFB_psho_check_em}=CSFB to UTRA FDD
#    Iphy Execute Ue Command Without Kargs    ue_param id=${ue_id_for_csfb_psho_rrcest} establishment_cause=emergency
#    Trriger CSFB PSHO  ue_id_for_csfb_PSHO=${ue_id_for_csfb_psho_em}  SERVICE_TYPE=mo  priority=on  wait_string_for_check=${CSFB_psho_check_em}
#    Iphy Execute Ue Command Without Kargs    ue_param id=${ue_id_for_csfb_psho_reset} reset
#
#Trriger B1 Report UTRAN
#    [Arguments]    ${ue_id_for_B1}    ${wait_string_for_B1}=rrcConnectionRelease
#    Iphy Execute Ue Command Without Kargs  ue_measurement_send meas_id=1 id=${ue_id_for_B1} allow_mobility srsrp=55 srsrq=20 phycell_id=110 nrscp=61
#    ...  ${wait_string_for_B1}
#
#Revert Delta Parameter
#    [Arguments]    ${delta_file}
#    Delta Commission Parameters    ${delta_file}
#    Cells Should Be OnAir    wait_sib=5s
#
#Recover Env And Test Teardown
#    [Arguments]    ${UE_ID_FOR_LTE736}=${UE1}
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_mme_param id=${UE_ID_FOR_LTE736} reset
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_param id=${UE_ID_FOR_LTE736} reset
#    Common Test Teardown And Stop Capture Logs
#
#Revert Param And Test Teardown
#    [Arguments]    ${UE_ID_FOR_LTE736}=${UE1}    ${delta_file_revert}=${EMPTY}
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_mme_param id=${UE_ID_FOR_LTE736} reset
#    Run Keyword and Ignore Error    Iphy Execute Ue Command Without Kargs    ue_param id=${UE_ID_FOR_LTE736} reset
#    Revert Delta Parameter    delta_file=${delta_file_revert}
#    Common Test Teardown And Stop Capture Logs
