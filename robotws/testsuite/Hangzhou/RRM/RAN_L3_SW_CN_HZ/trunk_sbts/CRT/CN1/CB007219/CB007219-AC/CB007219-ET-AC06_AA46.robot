*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD 
...    owner-christine.chen    release-SBTS24R3    team-CN1ET
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_GNB1}
...    NRCELL:type0CoresetConfigurationIndex=3
...    NRBTS:actMfbiNrCaSupportFr1=true

...    NRCELL-1:chBw=100MHz
...    NRCELL-1:gscnOrSsPbchArfcn=7993
...    NRCELL-1:nrarfcn=647444
...    NRCELL-2:chBw=100MHz
...    NRCELL-2:gscnOrSsPbchArfcn=7850
...    NRCELL-2:nrarfcn=633720

...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRSYSINFO_PROFILE-2/NRIAFIM-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2

...    NRCELL-1:freqBandIndicatorNR=77

...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    NRCELL-2:freqBandIndicatorNR=77

...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=78

...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78

...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=0|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-3:fiveGsTac=200
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=640828
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1

...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=636666
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:freqBandIndicatorNR=78
...    NRBTS/NRADJNRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1

...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly

...    NRCELL-1/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-4:gNbId=2
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-4:lcrId=4
...    NRCELL-1/NRREL-4:removeNotAllowed=false
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlOnly

...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms

@{PARAMS_FOR_GNB2}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRCELL-3:chBw=100MHz
...    NRCELL-3:gscnOrSsPbchArfcn=7924
...    NRCELL-3:nrarfcn=640828
...    NRCELL-3:freqBandIndicatorNR=78

...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-1
...    NRCELL-3:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-2/NRMULTIBANDINFO_PROFILE-2

...    NRCELL-4:chBw=100MHz
...    NRCELL-4:gscnOrSsPbchArfcn=7880
...    NRCELL-4:nrarfcn=636666
...    NRCELL-4:freqBandIndicatorNR=78

...    NRCELL-4:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-1
...    NRCELL-4:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-2/NRMULTIBANDINFO_PROFILE-2

...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=78
...    NRBTS/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77

...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-2/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-2/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:resourceDN
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:resourceDN
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:resourceDN

...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=647444
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-2

...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=633720
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-2

...    NRCELL-3:weightForSCellSelection=80

...    NRBTS:actExt2N77Support=true
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled

@{PARAMS_FOR_OTHERS}
...    NRBTS:actBcsCheck=disabled
...    NRBTS:actExt2N77Support=true    #n77E_Canada
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:suppCnPartialAdNgHo=true
...    NRBTS:actConflictConfiguration=true


...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=2
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1
...    NRCELL:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL:nrCellType=4DL4UL
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=39
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms128
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=1
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms160
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:maxNumScellsDlFr1=4
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actIncXn=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRDU-1:carrierAggregationSupportList=${CAlist}
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd

@{online_modify_for_AA46_gnb1}
...    NRBTS:actExt2N77Support=false
...    NRBTS:actMfbiNrCaSupportFr1=false
...    NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRADJNRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-3:gNbId=2
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-2/NRREL-3:lcrId=3
...    NRCELL-2/NRREL-3:removeNotAllowed=false
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-2/NRHOIF-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-2/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-3:freqBandIndicatorNR=77
...    NRCELL-2/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-2/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-3:ssbFrequency=640800
...    NRCELL-2/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-2/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-2/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRBTS:actInterGnbRREPreparedCell=true
...    NRBTS:rrcReestabTypeSA=sameGNB

@{online_modify_for_AA46_gnb2}
...    NRBTS:actExt2N77Support=false
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRCELL-3:freqBandIndicatorNR=77
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-2
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-11:gNbId=2
...    NRCELL-3/NRREL-11:gNbIdLength=22
...    NRCELL-3/NRREL-11:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-3/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-11:removeNotAllowed=false
...    NRCELL-3/NRREL-11:lcrId=11
...    NRCELL-3/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-11:sCellOperationalMode=dlOnly
...    NRBTS:actInterGnbRREPreparedCell=true
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:lcrId=2
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-3/NRHOIF-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-2
...    NRCELL-3/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-2:freqBandIndicatorNR=77
...    NRCELL-3/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-3/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-3/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-3/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-2:ssbFrequency=633696
...    NRCELL-3/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2
...    NRCELL-3/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-3/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-3:measGapSelectionSA=favourUeThroughput


@{online_recover_for_AA46_gnb1}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRADJNRCELL-3:freqBandIndicatorNR=78
...    NRADJNRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    delete:NRCELL-2/NRREL-3
...    NRBTS:actInterFreqHoSA=false
...    delete:NRCELL-2/NRHOIF-3
...    delete:NRCELL-2:measGapSelectionSA
...    NRBTS:actInterGnbRREPreparedCell=false
...    NRBTS:rrcReestabTypeSA=deactivated

@{online_recover_for_AA46_gnb2}
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRCELL-3:freqBandIndicatorNR=78
...    NRCELL-3:nrConnectModeProfileDN=MRBTS-1/NRBTS-2/NRCONNECTMODE_PROFILE-1
...    NRCELL-3:a1MeasSCellAddEnabled=none
...    delete:NRCELL-3/NRREL-11
...    NRBTS:actInterGnbRREPreparedCell=false
...    NRBTS:rrcReestabTypeSA=deactivated
...    NRBTS:actInterFreqHoSA=false
...    delete:NRCELL-3:measGapSelectionSA
...    delete:NRCELL-3/NRHOIF-2
...    delete:NRCELL-3/NRREL-2

@{online_disable_7219}
...    NRBTS:actMfbiNrCaSupportFr1=false

${N77_N78_and_N77(3A)_and_N77_N77C_and_N77D_extend_Canada}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D801AC1184341020F1068032B64C55890E
...    7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A83620EB04610D04083E5068032B64C55890E7C471EC09
...    F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF
...    9863CA16070387817003FF001C00FFC00170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F0
...    2E007FE003801FF8002E000070015E1E2600061340000160205E1E2080071300000085808178B898001C4C000E260000020B0102F0F13000
...    389810400C2C040BC1C4C0C300816020401C000800501320268BA011E81614489B1CF870A244D8E7C38912244D8E7C3851226C73E1C089B1
...    CF86005828C6318C00102F417001E00140E0A00E0601280380030120020301F02401000000008000010040000100200000C0100000800800
...    0050040000300200001C0100100E0380E0080040701C076065606D64C564CD652D60C5606D654D0241000009652504000065949410000296
...    525040000E594941000049652504000165949410000696525040001E5949410080701C0796525040101C079652501D40EAA81E5526AAA4D9
...    54A72A8355503CAA55942C009001A05000204040400801010000202008010080500A201010020040400801010020202020040080A0140010
...    120246A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${N77(3A)_and_N77_N77C_and_N77D_extend_Canada}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700EA0D801AC1184341020F1068032B64C55890E7
...    D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0A83620EB04610D04083E5068032B64C55890E7C471EC09F1
...    891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001C0AA36266B04610D04083A41A00B2D931543439F11C7A067D813E31CF986
...    3CA16070387817003FF001C00FFC00170000381546C25D608C21A0810748340165B262A86873E238F40CFB027C639F30C7942C0E070F02E00
...    7FE003801FF8002E000070015E1E2600060940000160205E1E2080071300000085808178B898001C4C000E260000020B0102F0F1300038981
...    0400C2C040BC1C4C0C300816020401C000800501320268BA011E81614489B1CF870A244D8E7C38912244D8E7C3851226C73E1C089B1CF8600
...    5828C6318C00102F417001E00140E0A00E0601280380030120020301F02401000000008000010040000100200000C01000008008000050040
...    000300200001C0100100E0380E0080040701C076065606D64C564CD652D60C5606D654D024100000965250400006594941000029652504000
...    0E594941000049652504000165949410000696525040001E5949410080701C0796525040101C079652501D40EAA81E5526AAA4D954A72A835
...    5503CAA55942C009001A05000204040400801010000202008010080500A201010020040400801010020202020040080A0140010120246A87C
...    0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

${N3_N77_and_N3_N78}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C0000E0541B00B582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000170000381546C4DD608C21A0810748340165B262A86873E238F40CFB027C6
...    39F30C7942C0E070F02E007FE003801FF8002E0000702A0D831AC1184341020F941A00CAD931562439F11C7B027C62471E439F51CF9863CA1
...    607038784FFF800003FFE000002E0000702B8D84BAC1184341020E9068036B64C558D0E7C471E819F604F8C48E3C873EA39F30C7942C0E070
...    F05C00FFC007003FF0005C0000E0551B133582308682041D20D00596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0B801FF800E007F
...    E000B80001C0A836236B04610D04083E5068032B64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B80001
...    C002707898001C0200000A160205E1E01000713400003858081007011A014404D80822E8003602851226C73E1C28913639F0C00E043183D05
...    C0078005038280381804A00E000C0480080C07C07004000000020000040100000400800003004000020020000140100000C0080000701D819
...    59535951591B58335831581B595340704000025949410000196525040000A594941000039652504000125949410000596525040001A594941
...    000079652501D40EAA955552AAAA479541B2A8355503CAA55942C009001A05000684040080101002004202010020080200420100400804008
...    0101002004402014028080700E02020040404018030100400820200C018080100210100801004008010808010020200801080401002010020
...    04040080110080200402004008080100220100200404008010100200440200400808010020200400840400801010040086060180340280503
...    00200600400818010030020040C040088020043543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

@{UEattach_for_AC06_UE1}
...    pcid:52, scellIdx:1
...    pcid:50, scellIdx:0
...    freqBandIndicatorNR 78
...    SCellIndex 1 activated successfully at airphone

@{UEattach_for_AC06_UE2}
...    pcid:53, scellIdx:1
...    pcid:50, scellIdx:0
...    freqBandIndicatorNR 77
...    SCellIndex 1 activated successfully at airphone

@{UE_register_and_A1_configured}
...    QoS Routing Table
...    eventA1

@{HO_from_cell1-2_to_cell2-3}
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 77
...    gapUE release
...    reestablishmentCause handoverFailure
...    NR RRC Reestablishment sucessfully completed
...    rrcReconfigurationComplete
...    a1-Threshold rsrp : 60

@{HO_from_cell1-2_to_cell2-3_with_n78}
...    pcid:52, scellIdx:0
...    freqBandIndicatorNR 78
...    gapUE release
...    reestablishmentCause handoverFailure
...    NR RRC Reestablishment sucessfully completed
...    rrcReconfigurationComplete

@{CA_cell2-3_cell2_11}
...    rrcReconfigurationComplete
...    pcid:60, scellIdx:1
...    pcid:52, scellIdx:0
...    SCellIndex 1 activated successfully

@{HO_from_cell2-3_to_cell1-2}
...    pcid:51, scellIdx:0
...    freqBandIndicatorNR 78
...    gapUE release
...    reestablishmentCause handoverFailure
...    NR RRC Reestablishment sucessfully completed
...    rrcReconfigurationComplete

@{MG_n78_N77}
...    freqBandIndicatorNR 78
...    freqBandIndicatorNR 77
...    a1-Threshold rsrp : 39
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete

@{MG_N77}
...    freqBandIndicatorNR 77
...    a1-Threshold rsrp : 39
...    a3-Offset rsrp : 20
...    gapUE setup
...    rrcReconfigurationComplete

@{UEattach_for_AA46}
...    QoS Routing Table
...    freqBandIndicatorNR 78

@{PM_Counters_Check_AA46_gnb1}
...    NRCELL-2:${GNB_SA_ADMISSION_MFBI_REQ}=2
...    NRCELL-2:${GNB_SA_ADMISSION_MFBI_SUCC}=2
...    NRCELL-2:${GNB_SA_DU_ADMISSION_MFBI_REQ}=2
...    NRCELL-2:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=2
...    NRDU-1:${RRC_REESTAB_HO_FAILURE_DU}=1
...    NRCELL-2:${RRC_REESTAB_HO_FAILURE}=1
...    NRCELL-2:${REESTAB_ACC_HO_FAIL}=1
...    NRCELL-2:${EGNB_REEST_ACC_HO_FAIL}=1
...    NRDU-1:${REESTAB_ACC_HO_FAIL_DU}=1
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1
...    NRCELL-2:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=1
...    NRCELL-2:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=1

@{PM_Counters_Check_AA46_gnb2}
...    NRCELL-3:${GNB_SA_ADMISSION_MFBI_REQ}=1
...    NRCELL-3:${GNB_SA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-3:${GNB_SA_DU_ADMISSION_MFBI_REQ}=1
...    NRCELL-3:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=1
...    NRDU-1:${RRC_REESTAB_HO_FAILURE_DU}=2
...    NRCELL-3:${RRC_REESTAB_HO_FAILURE}=2
...    NRCELL-3:${REESTAB_ACC_HO_FAIL}=2
...    NRCELL-3:${EGNB_REEST_ACC_HO_FAIL}=2
...    NRDU-1:${REESTAB_ACC_HO_FAIL_DU}=2
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    NRCELL-3:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_REQ}=1
...    NRCELL-3:${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}=1

${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501    #The number of radio admission requests for SA user where admission is requested on the alter band.
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502    #Number of admitted radio admission requests for SA user where admission is done on the alter band.
${GNB_SA_DU_ADMISSION_MFBI_REQ}    M55139C02001    #This counter provides the number of radio admission requests with MFBI for the SA user.
#The counter is updated to the PCell on DU.
${GNB_SA_DU_ADMISSION_MFBI_SUCC}    M55139C02002    #This counter provides the number of radio-admitted UEs for the SA user using the alternative
#band.The counter is updated to the PCell on DU.
${GNB_SA_HO_ADMISSION_MFBI_REQ}    M55138C00503    #radio admission HO requests for SA user where admission is requested on the alternative band.
${GNB_SA_HO_ADMISSION_MFBI_SUCC}    M55138C00504    #admitted HO radio admissions for SA user where admission is done on the alternative band.
${GNB_SA_DU_HO_ADMISS_MFBI_REQ}    M55139C02005    #The number of radio admission HO requests on alternative band for SA users.
${GNB_SA_DU_HO_ADMISS_MFBI_SUCC}    M55139C02006    #The number of radio admitted HO radio resources on alternative band for SA users.
${RRC_REESTAB_HO_FAILURE_DU}    M55127C00502    #Number of RRC Re-establishment Request caused by handover failure
${RRC_REESTAB_HO_FAILURE}    M55124C00504    #Number of RRC Re-establishment Request caused by handover failure
${REESTAB_ACC_HO_FAIL}    M55124C00511    #Number of accepted RRC Re-establishment when reestablishment cause is handover failure
${EGNB_REEST_ACC_HO_FAIL}    M55124C00003    #Successful RRC Re-establishments due to handover failure during incoming inter-gNB handover
${REESTAB_ACC_HO_FAIL_DU}    M55127C00511    #Number of accepted RRC Re-establishment when reestablishment cause is handover failure 

*** Test Cases ***
CB007219-ET-AC06_Successful_SA_inter-gNB_CA_setup_with_contiguous_frequencies_in_N78_and_N77_extended_with_PCell_in_N77_extended
    [Documentation]
    ...    This user scenario describes the successful setup of CA, when in the list of cells to be aggregated, there is at least one MFBI cell
    ...    configured with native band n78 is contiguous with another cell configured with native band as n77 extended for Canada, where the cell
    ...    with n77 extended band is the PCell. USCB007219-AC#B2.2, USCB007219-AC#B2.3.
    ...    [Configuration]:
    ...    CB008140 is enabled, NRBTS/actBcsCheck is disabled, CB010378:NRBTS.actExt2N77Support=true
    ...    CB007219:NRBTS/actMfbiNrCaSupportFr1 is set to "true", 5GC001416:NRBTS/actMultiFrequencyBandIndicatorNRSupport=true
    ...    Cell configuration: 
    ...                        gnb1                  gnb2
    ...                        cell1_1    cell1_2    cell2_3     cell2_4        cell2_11    cell2_12
    ...    Technology type     TDD        TDD        TDD         TDD            FDD    FDD
    ...    Frequency           F0         F1         F4          F5             F6    F7
    ...    chbw                100        100        100         100            10    15
    ...    Small BWP
    ...    DL MIMO Layers      4L         4L         4L          4L             4L    4L
    ...    Native band      n77E Canada    n77       n78        n78            n3    n28
    ...    Alternative band    n78        n78        n77         n77
    ...    Cell1_1 operates in the frequency range of 3650MHz<= F5 <=3980MHz.
    ...    cell1_1 and cell2_3 are contiguous,cell2_3 and cell2_4 are not contiguous with F1>F4>F5.
    ...    UE1 capability: cell1_1+cell2_3+cell2_4, A1 scell addition. Cell2_3 offers better weighted channel bandwidth than Cell2_4.
    ...    5G-UE indicates support of the higher extended band 77 in Canada,the capability UE-NR-Capability->RF-Parameters->extendedBand-n77-2-r17.
    ...    BC#1: n77A_78A    N77    n78    only n77 supports UL CA for BC#1
    ...    FSEI#1:DL MIMO layers    4L    4L
    ...    DL ChBw (MHz)    100    100
    ...    BC#2: n77(3A)    N77    N77    N77
    ...    FSEI#1:DL MIMO layers    4L    4L    4L
    ...    DL ChBw (MHz)    100    100    100
    ...    BC#3: n77A_n77C    N77    n77    n77
    ...    FSEI#1:DL MIMO layers    4L    4L    4L
    ...    DL ChBw (MHz)    100    100    100
    ...    BC#4: n77D    N77    N77    N77
    ...    FSEI#1:DL MIMO layers    4L    4L    4L
    ...    DL ChBw (MHz)    100    100    100
    ...    UE2 capability: the same as UE1. UE does not support band n78 and BC#1.
    ...    2.Test Case Steps:
    ...         a. attach UE1 to cell1_1 and trigger A1 for scell addition. Start DL/UL traffic.
    ...         b. attach UE2 to cell1_1 and trigger A1 for scell addition. Start DL/UL traffic.
    ...    3.Expectation:
    ...         a. cell2_3 is added as scell with n78. cell 1_1 is in n77. BC#1(00:00) is selected.
    ...         b. cell2_4 is added as scell with n77. cell 1_1 is in n77. BC#2(00:02) is selected.
    [Tags]    QC_341317    christine.chen    AC06    CA_LABEL-TT(100MHZ_TDD_n77+100MHZ_TDD_n78)    CA_LABEL-TT(100MHZ_TDD_n77+100MHZ_TDD_n77)
    Update UE capa for AC06
    UE attach cell1 and trigger A1 scelladd    ${UEattach_for_AC06_UE1}    ue_id=1
    UE attach cell1 and trigger A1 scelladd    ${UEattach_for_AC06_UE2}    ue_id=2
    Check Wireshark Log    ${CURDIR}${/}A2A_AC06${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    
CB007219-ET-AA46_Verify CB007219 Interaction with RRC-Reestablishment to a prepared gNB during inter-gNB HO
    [Documentation]
    ...    This user scenario describes the interaction of CB007219 with CB008574 when the target PCell is configured with native
    ...    and alternative bands and the UE supports both bands
    ...    [Configuration]:
    ...    cell1_2: 100MHz native n77, alternative n78
    ...    cell2_3: 100MHz native n77, alternative n78
    ...    cell2_11: 20MHz n3
    ...    UE1 capability: cell2_3+cell2_11, A1 scell addition.
    ...    BC#1: n3A-n77A    n3    N77
    ...    DL FSEI#1:    DL MIMO layers    2L    2L
    ...    DL ChBw (MHz)    20    100
    ...    UL FSEI#1:    UL MIMO layers    2L    2L
    ...    UL ChBw (MHz)    20    100
    ...    BC#2: n3A-n78A    N3    N78
    ...    DL FSEI#2:    DL MIMO layers    2L    4L
    ...    DL ChBw (MHz)    20    100    
    ...    UL FSEI#2:    UL MIMO layers    2L    2L
    ...    UL ChBw (MHz)    20    100
    ...    Test Case Steps:
    ...    a. UE attach to cell1_2, n78 is selected as 7219 disabled and n78 supports higher throughput than n77.
    ...    b. trigger inter-gnb inter-freq HO from cell1_2 to cell2_3 with RRE. RRE to cell2_3 successfully and
    ...    n77 is selected as native band will be selected when 7219 enabled.
    ...    c. trigger A1 for scell addition. cell2_11 is added as scell.
    ...    d. trigger inter-gnb inter-freq HO from cell2_3 to cell1_2 with RRE. RRE to cell1_2 successfully and
    ...    n78 is selected as 7219 disabled and n78 supports higher throughput than n77.
    ...    e. online disable 7219 in gnb2.
    ...    f. trigger inter-gnb inter-freq HO from cell1_2 to cell2_3 with RRE. RRE to cell2_3 successfully and
    ...    n78 is selected as 7219 disabled and n78 supports higher throughput than n77. no A1 for scell addition configured.
    [Tags]    QC_341729    jiadan.wu    AA46    CA_LABEL-TF(100MHZ_TDD_n77+20MHZ_FDD_n3)
    Clear Counter Files for 2GNB
    Online ParamChange AA46
    UE attach to cell1-2 and check traffic
    Inter-gnb inter-freq HO with RRE from cell1-2 to cell2-3
    Inter-gnb inter-freq HO with RRE from cell2-3 to cell1-2
    OnlineParamChange_gNB2    ${online_disable_7219}
    Inter-gnb inter-freq HO with RRE from cell1-2 to cell2-3 with n78
    Check Counters for AA46
    [Teardown]    AA46_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env     tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F_AEQE    ue_count=15

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=${N66_N77_and_N66_N78}    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Update UE capa for AC06
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${N77_N78_and_N77(3A)_and_N77_N77C_and_N77D_extend_Canada}
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${N77(3A)_and_N77_N77C_and_N77D_extend_Canada}

Check Traffic
    [Arguments]     ${ue_id}=1    ${cell_num}=1    ${min_dl_tput}=120    ${min_ul_tput}=8
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         Should Be True    ${scell_tput}/1000 > 10
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${min_dl_tput}
    Should Be True    ${ul_throuput}/1000 > ${min_ul_tput}

Send Throughput
    [Arguments]    ${ue_id}=1    ${times}=3
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=${I}    UE ${ue_id}: UDP DL
    END

Ue register and pdu setup and A1 is configure
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${enb}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${UE_register_and_A1_configured}

Trigger MR scelladd
    [Arguments]    ${scell_added_log}    ${ue_id}=1    ${carrierfreq}=647424
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${scell_added_log}

UE attach cell1 and trigger A1 scelladd
    [Arguments]    ${scell_added_log}    ${ue_id}=1
    Ue register and pdu setup and A1 is configure    ue_id=${ue_id}
    Trigger MR scelladd    ${scell_added_log}    ue_id=${ue_id}
    Send Throughput    ue_id=${ue_id}    times=7
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=${ue_id}    cell_num=2    min_dl_tput=840
    Release Ues    ue_type=all

OnlineParamChange_gNB1
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

OnlineParamChange_gNB2
    [Arguments]    ${Online_Param}
    Delta Commission Parameters gnb2    ${Online_Param}
    Cells Should Be Onair GNB2

Online ParamChange AA46
    OnlineParamChange_gNB1    ${online_modify_for_AA46_gnb1}
    OnlineParamChange_gNB2    ${online_modify_for_AA46_gnb2}

AA46_Teardown
    Release UEs    ue_type=all
    OnlineParamChange_gNB1    ${online_recover_for_AA46_gnb1}
    OnlineParamChange_gNB2    ${online_recover_for_AA46_gnb2}
    Common Test Teardown And Stop Capture Logs

Ue register and pdu session setup
    [Arguments]    ${UEattach}=${UEattach_for_AA46}    ${ue_id}=1    ${cell_id}=1    ${SA_Capa_perUE_Full}=${N3_N77_and_N3_N78}
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_perUE_Full}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${UEattach}

Trigger A2 measurement report
    [Arguments]    ${ue_id}    ${carrierfreq}    ${pass_check}=rrcReconfigurationComplete
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=10 srsrq_nr=10
    ...    pass_regexp=${pass_check}

Inter-gNB HO with A3 from TDD cell1-2 to TDD cell2-3 with RRE
    [Arguments]    ${Ho}=${HO_from_cell1-2_to_cell2-3}    ${ue_id}=1    ${carrierfreq}=640800    ${Target_phycell_id}=52
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${nr_rrc_reconf_param}    catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish gnb=3 cell=3
    ...    crnti=source cause=handoverFailure delay=1000 nth=1
    ${Inter_gNB_HO}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=100 nrsrq_nr=100
    Execute Egate Command    ${nr_rrc_reconf_param}
    Execute Egate Command    ${Inter_gNB_HO}    pass_regexp=${Ho}

Inter-gNB HO with A3 from TDD cell1-2 to TDD cell2-3 with RRE with error check
    [Arguments]    ${Ho}=${HO_from_cell1-2_to_cell2-3}    ${ue_id}=1    ${carrierfreq}=640800    ${Target_phycell_id}=52
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${nr_rrc_reconf_param}    catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish gnb=3 cell=3
    ...    crnti=source cause=handoverFailure delay=1000 nth=1
    ${Inter_gNB_HO}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=100 nrsrq_nr=100
    Execute Egate Command    ${nr_rrc_reconf_param}
    ${ret}    Execute Egate Command    ${Inter_gNB_HO}    pass_regexp=${Ho}
    should not contain    ${ret}    eventA1

Inter-gNB HO with A3 from TDD cell2-3 to TDD cell1-2 with RRE
    [Arguments]    ${Ho}=${HO_from_cell1-2_to_cell2-3}    ${ue_id}=1    ${carrierfreq}=633696    ${Target_phycell_id}=51
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${nr_rrc_reconf_param}    catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish gnb=2 cell=2
    ...    crnti=source cause=handoverFailure delay=1000 nth=1
    ${Inter_gNB_HO}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=100 nrsrq_nr=100
    Execute Egate Command    ${nr_rrc_reconf_param}
    Execute Egate Command    ${Inter_gNB_HO}    pass_regexp=${Ho}

Clear Counter Files for 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files GNB2    ${False}

Check Counters for AA46
    Check Counters    ${PM_Counters_Check_AA46_gnb1}
    Check Counters GNB2    ${PM_Counters_Check_AA46_gnb2}

UE attach to cell1-2 and check traffic
    Ue register and pdu session setup    cell_id=2    UEattach=${UEattach_for_AA46}
    Send Throughput    ue_id=1    times=6
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    cell_num=1    min_dl_tput=600

Inter-gnb inter-freq HO with RRE from cell1-2 to cell2-3
    Trigger A2 measurement report    ue_id=1    carrierfreq=633696    pass_check=${MG_n78_N77}
    Inter-gNB HO with A3 from TDD cell1-2 to TDD cell2-3 with RRE    Ho=${HO_from_cell1-2_to_cell2-3}
    Trigger MR scelladd    ${CA_cell2-3_cell2_11}    ue_id=1    carrierfreq=640800
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    cell_num=2    min_dl_tput=480

Inter-gnb inter-freq HO with RRE from cell2-3 to cell1-2
    Trigger A2 measurement report    ue_id=1    carrierfreq=640800    pass_check=${MG_N77}
    Inter-gNB HO with A3 from TDD cell2-3 to TDD cell1-2 with RRE    Ho=${HO_from_cell2-3_to_cell1-2}
    Wait Until Keyword Succeeds    30s    5s    Check Traffic    ue_id=1    cell_num=1    min_dl_tput=600

Inter-gnb inter-freq HO with RRE from cell1-2 to cell2-3 with n78
    Trigger A2 measurement report    ue_id=1    carrierfreq=633696    pass_check=${MG_n78_N77}
    Inter-gNB HO with A3 from TDD cell1-2 to TDD cell2-3 with RRE with error check    Ho=${HO_from_cell1-2_to_cell2-3_with_n78}



