*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_MP_AP_LOOO    team-CN1ET
...    owner-jia.pan    release-SBTS24R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${CaSup}    ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

${rdMaxActiveIncomingCaRelFlexSCellSelect}    0x89006C
${rdMaxActiveOutgoingCaRelFlexSCellSelect}    0x89006D

@{PARAMS_IN_SWCONFIG}    ${rdMaxActiveIncomingCaRelFlexSCellSelect}=3    ${rdMaxActiveOutgoingCaRelFlexSCellSelect}=6

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_other}
...    @{PARAMS_FOR_NRCELL1}
...    @{NativeBand_BWP}
...    NRCELL:maxNumOfSCellAlloc=1

@{PARAMS_FOR_NRCELL1}
...    NRCELL-1:maxNumScellsDlFr1=4
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-5:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-5:gNbId=1
...    NRCELL-1/NRREL-5:gNbIdLength=22
...    NRCELL-1/NRREL-5:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-5:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-5:lcrId=5
...    NRCELL-1/NRREL-5:nrDcAllowed=false
...    NRCELL-1/NRREL-5:removeNotAllowed=false
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-5:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-5:isRplCellForPSCell=true
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=1
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:nrDcAllowed=false
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-11:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-11:isRplCellForPSCell=true
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=1
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:nrDcAllowed=false
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-12:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:isRplCellForPSCell=true
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-15:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-15:gNbId=1
...    NRCELL-1/NRREL-15:gNbIdLength=22
...    NRCELL-1/NRREL-15:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-15:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-15:lcrId=15
...    NRCELL-1/NRREL-15:nrDcAllowed=false
...    NRCELL-1/NRREL-15:removeNotAllowed=false
...    NRCELL-1/NRREL-15:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-15:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-15:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-15:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-15:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-15:isRplCellForPSCell=true
...    NRCELL-1/NRREL-19:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-19:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-19:gNbId=1
...    NRCELL-1/NRREL-19:gNbIdLength=22
...    NRCELL-1/NRREL-19:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-19:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-19:lcrId=19
...    NRCELL-1/NRREL-19:nrDcAllowed=false
...    NRCELL-1/NRREL-19:removeNotAllowed=false
...    NRCELL-1/NRREL-19:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-19:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-19:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-19:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-19:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-19:isRplCellForPSCell=true
...    NRCELL-1/NRREL-20:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-20:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-20:gNbId=1
...    NRCELL-1/NRREL-20:gNbIdLength=22
...    NRCELL-1/NRREL-20:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-20:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-20:lcrId=20
...    NRCELL-1/NRREL-20:nrDcAllowed=false
...    NRCELL-1/NRREL-20:removeNotAllowed=false
...    NRCELL-1/NRREL-20:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-20:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-20:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-20:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-20:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-20:isRplCellForPSCell=true
...    NRCELL-1/NRREL-5:sCellPrio=1
...    NRCELL-1/NRREL-15:sCellPrio=3
...    NRCELL-1/NRREL-11:sCellPrio=2
...    NRCELL-1/NRREL-12:sCellPrio=12
...    NRCELL-1/NRREL-19:sCellPrio=19
...    NRCELL-1/NRREL-20:sCellPrio=20
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms

@{PARAMS_FOR_other}
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:srbInactivityTimerSA=60
...    NRCELL:filterCoeffSsbRsrq=fc4
...    NRBTS/NRSCTP-1:sctpProfile:sctpRtoInit=30000
...    NRBTS:actMfbiNrCaSupportFr1=true
...    NRBTS:actMultiFrequencyBandIndicatorNRSupport=true
...    NRCELL:actEnhMultipleDedicatedBWPs=true
...    NRBTS:actMfbiNrCaMeasConfResolv=false
...    NRBTS:actMultipleDedicatedBWPs=true
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=1
...    NRBTS/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=1
...    NRCELL:actDlRbgRandomization=disabled
...    NRCELL:timingAdvanceOffset=n25600
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40

@{PARAMS_FOR_CA}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CaSup}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:maxNumScellsUl=2
...    NRCELL:actK1Opt=intra-gNB

@{PARAMS_FOR_8950}
...    NRCELL-6:maxNumOfSCellAlloc=4
...    NRBTS:actFlexSCellSelectFr1=true

...    NRCELL-2/NRREL-6:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-6:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-6:gNbId=1
...    NRCELL-2/NRREL-6:gNbIdLength=22
...    NRCELL-2/NRREL-6:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-6:handoverAllowedSARedCap=forbidden
...    NRCELL-2/NRREL-6:lcrId=6
...    NRCELL-2/NRREL-6:nrDcAllowed=false
...    NRCELL-2/NRREL-6:removeNotAllowed=false
...    NRCELL-2/NRREL-6:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-6:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-6:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-6:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-6:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-6:isRplCellForPSCell=true
...    NRCELL-1/NRREL-21:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-21:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-21:gNbId=1
...    NRCELL-1/NRREL-21:gNbIdLength=22
...    NRCELL-1/NRREL-21:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-21:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-21:lcrId=21
...    NRCELL-1/NRREL-21:nrDcAllowed=false
...    NRCELL-1/NRREL-21:removeNotAllowed=false
...    NRCELL-1/NRREL-21:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-21:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-21:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-21:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-21:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-21:isRplCellForPSCell=true
...    NRCELL-1/NRREL-21:sCellPrio=8
...    NRCELL-1/NRREL-6:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-6:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-6:gNbId=1
...    NRCELL-1/NRREL-6:gNbIdLength=22
...    NRCELL-1/NRREL-6:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-6:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-6:lcrId=6
...    NRCELL-1/NRREL-6:nrDcAllowed=false
...    NRCELL-1/NRREL-6:removeNotAllowed=false
...    NRCELL-1/NRREL-6:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-6:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-6:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-6:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-6:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-6:isRplCellForPSCell=true
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-13:gNbId=1
...    NRCELL-1/NRREL-13:gNbIdLength=22
...    NRCELL-1/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-13:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-13:lcrId=13
...    NRCELL-1/NRREL-13:nrDcAllowed=false
...    NRCELL-1/NRREL-13:removeNotAllowed=false
...    NRCELL-1/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-13:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-13:isRplCellForPSCell=true
...    NRCELL-1/NRREL-17:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-17:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-17:gNbId=1
...    NRCELL-1/NRREL-17:gNbIdLength=22
...    NRCELL-1/NRREL-17:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-17:handoverAllowedSARedCap=forbidden
...    NRCELL-1/NRREL-17:lcrId=17
...    NRCELL-1/NRREL-17:nrDcAllowed=false
...    NRCELL-1/NRREL-17:removeNotAllowed=false
...    NRCELL-1/NRREL-17:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-17:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-17:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-17:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-17:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-17:isRplCellForPSCell=true
...    NRCELL-1/NRREL-17:sCellPrio=4
...    NRCELL-1/NRREL-6:sCellPrio=7
...    NRCELL-22/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-22/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-22/NRREL-1:gNbId=1
...    NRCELL-22/NRREL-1:gNbIdLength=22
...    NRCELL-22/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-22/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-22/NRREL-1:lcrId=1
...    NRCELL-22/NRREL-1:nrDcAllowed=false
...    NRCELL-22/NRREL-1:removeNotAllowed=false
...    NRCELL-22/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-22/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-22/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-22/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-22/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-22/NRREL-1:isRplCellForPSCell=true
...    NRCELL-1/NRREL-13:sCellPrio=13

...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-2:lcrId=6
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:isRplCellForPSCell=true

...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-12/NRREL-2:lcrId=6
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:isRplCellForPSCell=true

...    NRCELL-16/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-16/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-16/NRREL-2:gNbId=1
...    NRCELL-16/NRREL-2:gNbIdLength=22
...    NRCELL-16/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-16/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-16/NRREL-2:lcrId=6
...    NRCELL-16/NRREL-2:nrDcAllowed=false
...    NRCELL-16/NRREL-2:removeNotAllowed=false
...    NRCELL-16/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-16/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-16/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-16/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-16/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-16/NRREL-2:isRplCellForPSCell=true

@{NativeBand_BWP}
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-3
...    NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-3
...    NRBTS/NRCONNECTMODE_PROFILE-2:multiFreqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=77
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=78
...    NRBTS/NRMULTIBANDINFO_PROFILE-2:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=78
...    NRBTS/NRCONNECTMODE_PROFILE-3:multiFreqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=1|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=41
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrBandPriority=2|freqBandIndicatorNR=38
...    NRBTS/NRMULTIBANDINFO_PROFILE-3:nrMultibandInfoList:nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1|freqBandIndicatorNR=38
...    NRCELL-6:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-2
...    NRCELL-6:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-2
...    NRCELL-1:actEnhMultipleDedicatedBWPs=true
...    NRCELL-6:actEnhMultipleDedicatedBWPs=true
...    NRBTS/BWP_PROFILE-5:bwpType=dedicated
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-5:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|duration=9
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=10|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|duration=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=11|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|duration=3
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=120
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-5/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n133
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-77:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRCELL-6:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7
...    NRCELL-6:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-77
...    NRCELL-6:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5
...    NRCELL-2:gscnOrSsPbchArfcn=6276
...    NRCELL-3:gscnOrSsPbchArfcn=6372
...    NRCELL-4:gscnOrSsPbchArfcn=6276
...    NRCELL-5:gscnOrSsPbchArfcn=8054
...    NRCELL-6:gscnOrSsPbchArfcn=8009
...    NRCELL-2:nrarfcn=510306
...    NRCELL-4:nrarfcn=510306
...    NRCELL-2:msg1FrequencyStart=20
...    NRCELL-3:msg1FrequencyStart=20
...    NRCELL-4:msg1FrequencyStart=20
...    NRCELL-5:msg1FrequencyStart=20
...    NRCELL-6:msg1FrequencyStart=20

...    NRBTS/BWP_PROFILE-17:bwpType=initial
...    NRBTS/BWP_PROFILE-17:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-17:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-17:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-17:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-17/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=1
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-17/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=3
...    NRBTS/BWP_PROFILE-18:bwpType=dedicated
...    NRBTS/BWP_PROFILE-18:locationAndBandwidthDl:cRbSizeDl=n106
...    NRBTS/BWP_PROFILE-18:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-18:locationAndBandwidthUl:cRbSizeUl=n106
...    NRBTS/BWP_PROFILE-18:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-18/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n4|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-18/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-19:bwpType=dedicated
...    NRBTS/BWP_PROFILE-19:locationAndBandwidthDl:cRbSizeDl=n51
...    NRBTS/BWP_PROFILE-19:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-19:locationAndBandwidthUl:cRbSizeUl=n51
...    NRBTS/BWP_PROFILE-19:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-19/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=9
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=11
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=4
...    NRBTS/BWP_PROFILE-19/PDSCH-1:pdschRat0RbgConfig=config1
...    NRCELL-1:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-17
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-18
...    NRCELL-1:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-19
...    NRCELL-1:chBw=40MHz
...    NRCELL-1:nrarfcn=519000
...    NRCELL-1:gscnOrSsPbchArfcn=6462
...    NRCELL-1:type0CoresetConfigurationIndex=10
...    NRCELL-1:msg1FrequencyStart=20

...    NRCELL-13/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-15/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-15/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-13:actEnhMultipleDedicatedBWPs=true
...    NRCELL-15:actEnhMultipleDedicatedBWPs=true
...    NRCELL-15:msg1FrequencyStart=20
...    NRCELL-13:msg1FrequencyStart=20
...    NRCELL-13:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-16
...    NRCELL-13:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-27
...    NRCELL-13:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-88
...    NRCELL-15:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-16
...    NRCELL-15:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-27
...    NRCELL-15:cellBwpList:cellBwpId=2|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-88
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthDl:cRbSizeDl=n52
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-16:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-16/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=3
...    NRBTS/BWP_PROFILE-16/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    NRBTS/BWP_PROFILE-27:bwpType=dedicated
...    NRBTS/BWP_PROFILE-27:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-27:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-27:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-27/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=7|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=8|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-27/PDSCH-1:pdschRat0RbgConfig=config1
...    NRBTS/BWP_PROFILE-88:bwpType=dedicated
...    NRBTS/BWP_PROFILE-88:locationAndBandwidthDl:cRbSizeDl=n52
...    NRBTS/BWP_PROFILE-88:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-88:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-88/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=9
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=10
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=11
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=12|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=13|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-88/PDSCH-1:pdschRat0RbgConfig=config1

...    NRCELL-17:actEnhMultipleDedicatedBWPs=true
...    NRCELL-17:msg1FrequencyStart=20
...    NRCELL-17:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4|cellBwpId=0
...    NRCELL-17:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-47|cellBwpId=1
...    NRCELL-17:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-48|cellBwpId=2
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbSizeDl=n52
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-4:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-47:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-47:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-48:bwpType=dedicated
...    NRBTS/BWP_PROFILE-48:locationAndBandwidthDl:cRbSizeDl=n52
...    NRBTS/BWP_PROFILE-48:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-48:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-48/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=9
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=78
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=10|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=0
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=11|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|coresetId=1
...    NRBTS/BWP_PROFILE-48/PDSCH-1:pdschRat0RbgConfig=config1

${UL}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4701BB8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC007003FF0005C8000E00365FFFE5FFFE0541B10758636869315020F2CA4D1
...    068032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000B90001C006D2AAA92AAA80AA3626EB04610D040
...    83A41A00B2D931543439F11C7A067D813E31CF9863CA16070387817003FF001C00FFC00170000381506C18D608CA1A0810796526CA0D00656
...    C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000001720003800DA555525555015C6C25D608C21A0810748340
...    1B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE003801FF8002E0000702A8D899AC1184341020E906802CB64C
...    550D0E7C471E819F604F8C73E618F28581C0E1E05C00FFC007003FF0005C0000E0541B11B582308682041F28340195B262AC4873E238F604F
...    8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000005C0000E00A3C3C41000E230000000B0102F0F09400389A0000042C040BC5C2800
...    0E2080071180000105808178F830001C41000E20800711800001858087EF0F0A000389A0000102C040B83C28000E208000050B0102F0F1040
...    0388C0000182C040BC3C41000E268000070B0102F170A0003882001C41000010160205E2E14000711800388C0000242C040BC5C41000E2080
...    071180000505808178B882001C46000E2300000B0B0102F0F11800389A0000302C040BC7C18000E20800711800388C0000342C044FBC7C410
...    00E2600071300038980000382C040BC5C41000E2680071340000785808178F882001C41000E2680071340000805808140385000004400F1F0
...    60003830001C41000E2300000D0B0102F27104003882001C46000E14000713000009058081009011A014404D808301305D004040C290A244D
...    8E7C3851226C73E1C4891226C73E1C68912244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C38912244D8E7
...    C38912244D8E7C38912244D8E7C3851226C73E1C68912244D8E7C38D1224489B1CF871224489B1CF871A2448913639F0E01B0C3811A040810
...    3639F0E4408102040D9EFCB074506318C6318C6318C6318C6318C7A0B800F000A070500703009401C0018090010180F818008000000040000
...    08020000080100000600800004004000028020000180100000E0080000800400004802000028010000160080000C033829793979197933783
...    3783178337953793379293A2978393A5140B06000000600018000101801060000806000180003018000600010060001800050180006000180
...    6000180007018000600020060001800090180006000280600018000B0180002FC160BE4F45F2382F91C17C1A0BE0D05F0682F95417C960BE8
...    B45F07827A54002C009001A05000904140080180A013016028140080180A013016028202010020080200420100600C04008010100200460A0
...    0400C0500980B0140A00400C0500980B0140A00400C0500980B0140A00400C0500980B01410100600C0401002080803006020040084040200
...    401002004202004008080200420100600C04008010100200440200C0180801002020040088140080180A013016028140080180A0130160281
...    40080180A01301602840A00400C0500980B0140A00400C0500980B0140A00400C0500980B014101002004040100218280100301402602C050
...    280100301402602C050280100301402602C050280100301402602C050C0C0080180700206020014010020300600E024018180300701200C40
...    201C008080900602024018C04038010100E00404048030101200C00200C0190140080180A013016028140080180A013016028140080180A01
...    3016028140180380C01701A030140100280C01701A0306A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD0
...    5060B4

${n38A-n66A-n78A}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809506C41D618DA1A4C54083CB2934412032B64C5
...    5890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF80000089000E003695554955540551B137582308682041D2090165B2
...    62A86873E238F40CFB027C639F30C7942C0E070F02E007FE003801FF80022000381506C18D608CA1A0810796526CA090195B262AC4873E238
...    F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC00000448007001B4AAAA4AAAA02B8D84BAC1184341020E90480DAD931563439F1
...    1C7A067D813E31238F21CFA8E7CC31E50B0381C3C17003FF001C00FFC00110001C0A836236B04610D04083E50480CAD931562439F11C7B027
...    C62471E439F51CF9863CA1607038784FFF800003FFE000002200038028F0F10400388C0000002C040BC3C25000E268000010B0102F1709400
...    3882001C46000004160205E3E0C0007104003882001C4600000616021FBC3C25000E268000040B0102E0F0940038820000142C040BC3C4100
...    0E230000060B0102F0F10400389A00001C2C040BC5C25000E2080071040000405808178B84A001C46000E230000090B0102F1710400388200
...    1C46000014160205E2E20800711800388C00002C2C040BC3C46000E2680000C0B0102F1F060003882001C46000E2300000D0B0113EF1F1040
...    03898001C4C000E2600000E0B0102F1710400389A001C4D00001E160205E3E20800710400389A001C4D00002016020500E12800011003C7C1
...    8000E0C000710400388C0000342C040BC5C41000E12800713400009058081009011A014404D80830130350808185214489B1CF870A244D8E7
...    C38912244D8E7C38D1224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF871224489B1CF871224489B1CF8
...    71224489B1CF870A244D8E7C38D1224489B1CF871A2448913639F0E2448913639F0E344891226C73E1C03618702340810206C73E1C8810204
...    081B3DF960E8A0C6318C6318C6318C6318C6318F413003C00281C1401C0C02500700060240040603E06002000000010000020080000200400
...    0018020000100100000A0080000600400003802000020010000120080000A004000058020000300CE0A5E4E5E465E46DE0CDE0C5E0CDE54DE
...    4CDE4A4E8A5E0E4E94502C1800000180006000040600418000201801060000C060001800040180006000140600018000601800060001C0600
...    01800080180006000240600018000A01800060002C060000BF0582F93D17C8E8BE4705F0682F83417C1A0BE5505F2582FA2D17C1E09E95000
...    9004800D028004820A00400C0500980B0140A00400C0500980B014101008010040100210080300602004008080100230500200602804C0580
...    A0500200602804C0580A0500200602804C0580A0500200602804C0580A0808030060200801040401803010020042020100200801002101002
...    004040100210080300602004008080100220100600C04008010100200440A00400C0500980B0140A00400C0500980B0140A00400C0500980B
...    01420500200602804C0580A0500200602804C0580A0500200602804C0580A08080100202008010C140080180A013016028140080180A01301
...    6028140080180A013016028140080180A01301602860600400C038010301000A008010180300701200C0C0180380900620100E00404048030
...    101200C60201C008080700202024018080900600100600C40A00400C0500980B0140A00C01C0600B80D0180A0080140600B80D0183543E000
...    20406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

@{scell_alternative_band}
...    pcid:55, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    freqBandIndicatorNR 78

@{no_ca_pcell_alternative_band}
...    freqBandIndicatorNR 66
...    QoS Routing Table

@{ca_pcell_alternative_band}
...    pcid:55, scellIdx:1] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    freqBandIndicatorNR 78

@{pcell_alternative_band}
...    PDU SESSION ID-1 setup/reestablishment complete
...    searchSpaceId 13
...    freqBandIndicatorNR 38

@{pcell_native_band}
...    PDU SESSION ID-1 setup/reestablishment complete
...    searchSpaceId 13
...    freqBandIndicatorNR 41

@{5DL2UL_expect_regexp_UE1}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:55, scellIdx:1] configure_1_1
...    pcid:62, scellIdx:2] configure_0_1
...    pcid:62, scellIdx:2] configure_1_1
...    pcid:64, scellIdx:3] configure_1_1
...    pcid:66, scellIdx:4] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    freqBandIndicatorNR 77
...    searchSpaceId 13

@{3DL_expect_regexp_UE2}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:55, scellIdx:1] configure_1_1
...    pcid:60, scellIdx:2] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    freqBandIndicatorNR 78
...    searchSpaceId 13

${scell5}
...    pcid:54, scellIdx:1

${noscell21}
...    pcid:70, scellIdx:2

@{D013_PM_Counters_Check}
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_ADMISSION_MFBI_SUCC}=1
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_DU_ADMISSION_MFBI_SUCC}=1
...    NRCELL-6:${UE_SCELL_2_CONF_SCELL_DL_SA}>0
...    NRCELL-11:${UE_SCELL_2_CONF_SCELL_DL_SA}>0

...    NRCELL-6:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-13:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-15:${UE_SCELL_4_CONF_SCELL_DL_SA}>0
...    NRCELL-17:${UE_SCELL_4_CONF_SCELL_DL_SA}>0

${GNB_SA_ADMISSION_MFBI_REQ}    M55138C00501    #This counter provides the number of radio admission requests for the SA user, where admission is
#requested on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_ADMISSION_MFBI_SUCC}    M55138C00502    #This counter provides the number of admitted radio admission requests for the SA user,
#where admission is done on the alternative band.The counter is updated to the PCell on CU.
${GNB_SA_DU_ADMISSION_MFBI_REQ}    M55139C02001    #This counter provides the number of radio admission requests with MFBI for the SA user.
#The counter is updated to the PCell on DU.
${GNB_SA_DU_ADMISSION_MFBI_SUCC}    M55139C02002    #This counter provides the number of radio-admitted UEs for the SA user using the alternative
#band.The counter is updated to the PCell on DU.
${UE_SCELL_2_CONF_SCELL_DL_SA}    M55118C07002
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as an SCell with 2 configured SCells
#in DL in SA mode. The counter is pegged in the secondary cell.
${UE_SCELL_4_CONF_SCELL_DL_SA}    M55118C07510
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as an SCell with 4 configured SCells
#in DL in SA mode. The counter is pegged in the secondary cell.

*** Test Cases ***
CB008950-ET-D013-FR1_SA_CA_MFBI_incoming-outgoing_does_not_exceed_the_CU_diff_scellprioritylimit_intragNB 
    [Documentation]
    ...    1. This user scenario validates that gNB does not execute the SCell swap if the target SCell 
    ...    would exceed the limit of active incoming CA relations
    ...    2. Configuration
    ...         gNBs host following cells:
    ...                Cell-1 Cell-3 Cell-2/4 Cell-5 Cell-6 Cell-11/12 Cell-13 Cell-14 Cell-15/16 Cell-17/18/19/20 Cell-21/22
    ...    Technology    TDD    TDD    TDD    TDD    FDD    FDD        FDD    FDD        FDD        FDD            FDD
    ...          Band    n41    n41    n41    n77    n77    n66        n66    n66        n66        n71            n71
    ...    Alternativeband    n38                     n78
    ...           Pci    50     52     51/53    54    55    60/61      62      63      64/65      66/67/68/69      70/71
    ...     Bandwidth    40     100    100      100    100    10       15     20        15        15                10
    ...     Small bwp    20                            50              10               10            
    ...    Arfcn    519000    517800    510306 656000 650000 424000    425100 424380 432000        126000        128420
    ...    maxNumOfUsersPerNRCell    all cells are 275
    ...    maxNumOfSCellAlloc        all cells are 250
    ...    weightForSCellSelection    all cells are 50
    ...    Precondition:
    ...    Cell1 have 8 nrrels:cell4,cell5,cell11,cell12,cell15,cell19,cell20,cell21
    ...    2. Test Case Steps:
    ...           a. UE1 attach to cell-1(PCI50), setup PDU session
    ...           b. Enable CB008950 featrue and add three NRRELs(Cell-6, Cell-13 and Cell-17) of Cell1
    ...              and one NRREL Cell1 of Cell22
    ...           c. UE1 start traffic and trigger A1 CA scell addition
    ...           d. UE2 attach to cell-1(PCI50), setup PDU session
    ...           e. UE2 start traffic and trigger A1 CA scell addition
    ...           f. UE3 attach to cell11(PCI60).
    ...           g. UE4 attach to cell12(PCI61).
    ...           h. UE5 attach to cell16(PCI65) and trigger A1 to setup CA.
    ...           i. Release UE3 and attach to UE5 trigger A1 to setup CA again.
    ...           j. UE6 attach to cell1(PCI50) and trigger A1 to setup CA.
    ...    4. Expected Results:
    ...           a. UE1 PDU session setup successfully
    ...           b. Enable CB008950 featrue and NRRELs added successfully
    ...           c. UE1 traffic to be as expect and trigger A1 CA scell(cell1(PCI50)+cell6(PCI55)/13(PCI62)/15(PCI64)/17(PCI66)) 
    ...              addition successfully
    ...              CELL6 incoming number is 1(CELL1)
    ...              CELL1 outgoing number is 4(CELL6/13/15/17)
    ...           d. UE2 PDU session setup successfully
    ...           e. UE2 traffic to be as expect and trigger A1 CA scell(cell1(PCI50)+cell6(PCI55)/11(PCI60)) addition successfully
    ...              CELL6 incoming number is 1(CELL1)
    ...              CELL1 outgoing number is 5(CELL6/13/15/17/11)
    ...           f. UE3 CA(cell11(PCI60)+cell6(PCI55)) is setup
    ...              CELL6 incoming number is 2(CELL1/60)
    ...              CELL1 outgoing number is 5(CELL6/13/15/17/11)
    ...           g. UE4 CA(cell12(PCI61)+cell6(PCI55)) is setup
    ...              CELL6 incoming number is 3(CELL1/60/61)
    ...              CELL1 outgoing number is 5(CELL6/13/15/17/11)
    ...           h. UE5 CA(cell16+cell6) is not setup due to rdMaxActiveIncomingCaRelFlexSCellSelect is 3
    ...              CELL6 incoming number is 3(CELL1/60/61)
    ...              CELL1 outgoing number is 5(CELL6/13/15/17/11)
    ...           i. UE5 CA(cell16(PCI65)+cell6(PCI55)) is setup because UE3 is released
    ...              CELL6 incoming number is 3(CELL1/65/61)
    ...              CELL1 outgoing number is 5(CELL6/13/15/17/11)
    ...           j. UE6 CA(cell1(PCI50)+cell5(PCI54)) is setup,cell21(PCI70)is not added as scell due to 
    ...              rdMaxActiveOutgoingCaRelFlexSCellSelect is 6
    ...              CELL6 incoming number is 3(CELL1/65/61)
    ...              CELL1 outgoing number is 6(CELL6/13/15/17/11/5)
    [Tags]    D013    QC_347884    CA_LABEL-TTFFF(20Mhz_n41_50Mhz_n77_10Mhz_n66_10Mhz_n66_15M_n71)    CA_LABEL-TTFFF(20Mhz_n38_50Mhz_n78_10Mhz_n66)
    Clear Counter Files    wait=${False}
    UE attach and No Scell added    UE_Capabilitie=${UL}
    OnlineParamChange    ${PARAMS_FOR_8950}
    UE Check Throughput And trigger A1 CA Scell Addition 5CC
    UE attach and No Scell added    ue_id=2    UE_Capabilitie=${n38A-n66A-n78A}    expect=${pcell_alternative_band}
    UE Check Throughput And trigger A1 CA Scell Addition 3CC
    CELL6 incoming exceed
    CELL1 outgoing exceed	
    Check Counters    ${D013_PM_Counters_Check}

*** Keywords ***
Modify Cfg
    ${C_1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 
    ...    nr_arfcn=519000:519000 gscn=6462 mandatory_for_activation=off
    ${C_2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 
    ...    nr_arfcn=510306:510306 gscn=6276 mandatory_for_activation=off
    ${C_3}    catenate
    ...    set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 
    ...    nr_arfcn=517800:517800 gscn=6372 mandatory_for_activation=off
    ${C_4}    catenate
    ...    set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 
    ...    nr_arfcn=510306:510306 gscn=6276 mandatory_for_activation=off
    ${C_5}    catenate
    ...    set_cell id=5 gnb=2 pci=18:0 tac=200 nrci=0x05 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 
    ...    nr_arfcn=656000:656000 gscn=8054 mandatory_for_activation=off
    ${C_6}    catenate
    ...    set_cell id=6 gnb=2 pci=18:1 tac=200 nrci=0x06 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 
    ...    nr_arfcn=650000:650000 gscn=8009 mandatory_for_activation=off
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    ${C_3}
    Update Cfg    ${C_4}
    Update Cfg    ${C_5}
    Update Cfg    ${C_6}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/18cells_6T12F
	
CELL6 incoming exceed
    UE attach and Scell added    
    UE attach and Scell added    ue_id=4    cell_id=12
    UE attach and Scell added    ue_id=5    cell_id=16    expect=${no_ca_pcell_alternative_band}
    UE Send A1 Trigger Scell Addition and no CA    ue_id=5    cellfreq=431790    expect_regexp=${ca_pcell_alternative_band}
    UE Deregister From gNB    ue_id=3
    UE Send A1 Trigger Scell Addition    ue_id=5    cellfreq=431790    expect_regexp=${ca_pcell_alternative_band}

CELL1 outgoing exceed
    SA CA UE Setup PDU Session Successfully    ue_id=6    pcell=QoS Routing Table
    UE Send A1 Trigger Scell Addition and CELL21 not added   

UE Send A1 Trigger Scell Addition and CELL21 not added
    [Arguments]    ${ue_id}=6    ${cellfreq}=516990    ${expect_pass}=${scell5}    ${expect_fail}=${noscell21}    
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${expect_pass}    fail_regexp=${expect_fail}

UE attach and No Scell added
    [Arguments]    ${ue_id}=1    ${UE_Capabilitie}=${n41A-n66(2A)-n71A-n77A}    ${expect}=${pcell_native_band}	
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilitie}
    SA CA UE Setup PDU Session Successfully    ue_id=${ue_id}    pcell=${expect}

UE attach and Scell added
    [Arguments]    ${ue_id}=3    ${cell_id}=11    ${UE_Capabilitie}=${n38A-n66A-n78A}    ${expect}=${scell_alternative_band}	
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilitie}
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=${cell_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect}

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=NG RM Registered

SA CA UE Setup PDU Session Successfully
    [Arguments]    ${ue_id}=1    ${pcell}=${pcell_native_band}    ${wait_timer}=0.5 
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pcell}

UE Send A1 Trigger Scell Addition
    [Arguments]    ${ue_id}    ${cellfreq}    ${expect_regexp}=${5DL2UL_expect_regexp_UE1}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    pass_regexp=${expect_regexp}
	
UE Send A1 Trigger Scell Addition and no CA
    [Arguments]    ${ue_id}    ${cellfreq}    ${expect_regexp}=${5DL2UL_expect_regexp_UE1}
    ${meas_id}=    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=52
    ...    fail_regexp=${expect_regexp}

Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=25    UE ${ue_id}: UDP UL

Traffic Send for 3cc
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=10    UE ${ue_id}: UDP UL

UE Check Throughput And trigger A1 CA Scell Addition 5CC
    [Arguments]    ${ue_id}=1    ${expect_regexp}=${5DL2UL_expect_regexp_UE1}
    Traffic Send   
    UE Send A1 Trigger Scell Addition    ue_id=${ue_id}    cellfreq=516990    expect_regexp=${expect_regexp}
    sleep    15s    sleep for Tput stable
    Check DLThroughput 5cc
	
UE Check Throughput And trigger A1 CA Scell Addition 3CC
    [Arguments]    ${ue_id}=2    ${expect_regexp}=${3DL_expect_regexp_UE2}
    Traffic Send for 3cc    ue_id=${ue_id}   
    UE Send A1 Trigger Scell Addition    ue_id=${ue_id}    cellfreq=516990    expect_regexp=${expect_regexp}
    sleep    15s    sleep for Tput stable
    Check DLThroughput 3cc    ue_id=${ue_id}

Check DLThroughput 5cc
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_expect}=700    ${CC_num}=5    ${type}=pdsch
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check UE2    ${ue_id}    ${id}    ${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
	END
    Should Be True    ${all_tput}/1000 > ${Tput_expect}
    ${PcellUL_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${PcellUL_tput}/1000 > 8
    ${UL_tput2}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=2    type=pusch    rate_type=ave
    ${total_ul}    Evaluate    ${PcellUL_tput}+${UL_tput2}
    Should Be True    ${total_ul}/1000 > 22
	
Check DLThroughput 3cc
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_expect}=270    ${CC_num}=3    ${type}=pdsch
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check UE2    ${ue_id}    ${id}    ${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
    END
    Should Be True    ${all_tput}/1000 > ${Tput_expect}
    ${PcellUL_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${PcellUL_tput}/1000 > 8

Scell Throughput Check UE2
    [Arguments]    ${ue_id}=1    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${SA_Capa_perUE_Full}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
