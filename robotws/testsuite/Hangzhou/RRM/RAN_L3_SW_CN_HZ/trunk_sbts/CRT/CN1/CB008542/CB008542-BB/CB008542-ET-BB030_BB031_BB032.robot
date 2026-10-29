*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET    owner-jia.pan    release-5G22R3    CB008542
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    2
${DEBUG_LOG_LEVEL}    4
${cell_id}    1
@{PARAMS_IN_SCF}
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actFdmScheduling=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:actCDrx=true
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:pucchModeSelect=longPucch
...    NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-2:nrarfcn=518586
...    NRCELL-11:pucchModeSelect=longPucch
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=2
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=10
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=10
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=65
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=75
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=40ms
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=6
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=51
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=80ms
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=5
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:actSlowPrbPooling=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRBTS/NRDU-1:flexibleCAMode=NumberCellAmount
...    CABINET-1/BBMOD-1:fddNrCellConfigTradeoff=max cells
...    NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=127420
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136620
...    NRCELL-14:gscnOrSsPbchArfcn=1592
...    NRCELL-11:maxNumPdschAllocationPerSlot=6
...    NRCELL-12:maxNumPdschAllocationPerSlot=6
...    NRCELL-13:maxNumPdschAllocationPerSlot=6
...    NRCELL-14:maxNumPdschAllocationPerSlot=6
...    NRCELL-11:maxNumPuschAllocationPerSlot=6
...    NRCELL-12:maxNumPuschAllocationPerSlot=6
...    NRCELL-13:maxNumPuschAllocationPerSlot=6
...    NRCELL-14:maxNumPuschAllocationPerSlot=6
...    NRCELL-13:type0CoresetConfigurationIndex=6
...    NRCELL-14:type0CoresetConfigurationIndex=6
${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa,ca_Fdd_Fr1Tdd_Nsa

@{OnlineParam_BB030}
...    NRBTS:srb3SupportEnabled=false
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=2 beams
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=518910
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrp=20
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=64ms
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=4
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=40
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=80ms
...    NRCELL-1:weightForSCellSelection=100
...    NRCELL-2:weightForSCellSelection=40
...    NRCELL-1:a1MeashoEnabled=none
...    NRCELL-1:a2MeashoEnabled=none
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none

@{OnlineParam_BB031}
...    NRBTS:srb3SupportEnabled=true
...    NRCELL-1:a1MeashoEnabled=none
...    NRCELL-1:a2MeashoEnabled=none
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    delete:NRCELL-11/NRREL-10
...    delete:NRCELL-11/NRHOIF-1

@{OnlineParam_BB032}
...    delete:NRCELL-11/NRREL-10
...    delete:NRCELL-11/NRHOIF-1
...    NRBTS:srb3SupportEnabled=false
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=39
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=5
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64

@{PM_Counters_Check_BB030}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-11:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:${ATT_A2_IADU_HO_EX_NSA_PLMN}=1
...    NRCELL-1:${SUC_A2_IADU_HO_EX_NSA_PLMN}=1

@{PM_Counters_Check_BB031}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-11:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:${ATT_A2_IADU_HO_EX_NSA_PLMN}=1
...    NRCELL-1:${SUC_A2_IADU_HO_EX_NSA_PLMN}=1

@{PM_Counters_Check_BB032}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-11:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:${ATT_A2_IADU_HO_EX_NSA_PLMN}=1
...    NRCELL-1:${SUC_A2_IADU_HO_EX_NSA_PLMN}=1
${ATT_A2_IADU_HO_EX_NSA_PLMN}    M55145C04023
#A2 Intra-gNB Intra-DU HO exec att for NSA via MeNB or SRB3 per PLMN-ID
${SUC_A2_IADU_HO_EX_NSA_PLMN}    M55145C04024
#A2 Intra-gNB Intra-DU HO exec succ for NSA via MeNB or SRB3 per PLMN-ID
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
#The number of radio admission requests for 1 Scell
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
#The number of successful radio admissions for 1 Scell additions.
${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
#RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
#Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
#Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
#The number of radio admission requests for 1 Scell
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
#The number of successful radio admissions for 1 Scell additions.
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
#The number of radio admission requests for the Scell
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
#The number of successful radio admissions for the Scell
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000
#Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL

*** Test Cases ***
CB008542-ET-BB030_NSA_TFCA_DRX_A2based_PSCell_change_succ_without_SRB3_covBaseA1_multi_FTCA_target_Scell_Autoadded
    [Documentation]
    ...    1. The purpose of this test case is to check A2 based PSCell change without SRB3 covBaseA1 multi_FTCA.
    ...        cell selection combination:
    ...        TF: config cell-11 as cell-1 scell.(covBasedA1)
    ...        FT: config cell-1 as cell-11 scell.(covBasedA1)(Select)
    ...        FT: config cell-2 as cell-11 scell.(covBasedA1)
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 attach to NR Cell 1 and trigger traffic.
    ...         b. trigger A1 measurement report for scell adding(Cell11).
    ...         c. trigger A2 measurement report for pcell changing(Cell1 to Cell11).
    ...         d. trigger A1 measurement report for pcell changing(Cell11 to Cell1).
    ...         e. UE detach
    ...    3. Expected Results:
    ...         Step a: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on wireshark log:
    ...                 physCellId = 50
    ...                 ResourceSetToAddModList = 2
    ...                 resourceToAddModList = 18
    ...                 measIdToAddModList = 1
    ...                 eventId == 0
    ...                 rsrp = 75
    ...                 drx-Config = 1
    ...         Step b: A1 triggered successfully,cell11 is added as scell. Traffic share on scell.
    ...                 IE: on wireshark log:
    ...                 sCellIndex = 9
    ...                 physCellId = 60
    ...                 resourceToAddModList = 1
    ...                 measIdToRemoveList = 1
    ...                 measIdToAddModList = 2
    ...                 eventId = 1
    ...                 rsrp = 70
    ...                 eventId = 1
    ...                 rsrp = 35
    ...         Step c: A2 triggered successfully,cell11 is changed as pcell. cell1 is selected as scell.
    ...                 Scell addition triggered, as measurement report of RSRP higher than a1ThresholdSCellAddSsbRsrp,
    ...                 it is used for Scell addition directly. Traffic share on scell.
    ...                 IE: on wireshark log:
    ...                 sCellIndex = 9
    ...                 physCellId = 60
    ...                 physCellId = 50
    ...                 ResourceSetToAddModList = 3
    ...                 resourceToAddModList =13
    ...                 measIdToRemoveList = 2
    ...                 measIdToAddModList = 2
    ...                 eventId = 0
    ...                 rsrp = 40
    ...                 eventId = 1
    ...                 rsrp = 50
    ...                 drx-Config = 0
    ...         Step d: A1 triggered successfully,cell1 is changed as pcell.Scell is not added as measurement
    ...                 report of RSRP lower than a1ThresholdSCellAddSsbRsrp
    ...                 Traffic share on scell.
    ...                 IE: on wireshark log:
    ...                 physCellId = 50
    ...                 ResourceSetToAddModList = 2
    ...                 resourceToAddModList = 18
    ...                 measIdToRemoveList = 2
    ...                 measIdToAddModList = 1
    ...                 eventId = 0
    ...                 rsrp = 75
    ...                 drx-Config = 1
    ...         Step e: A1 triggered successfully,cell11 is added as scell. Traffic share on scell.
    ...                 IE: on wireshark log:
    ...                 sCellIndex = 9
    ...                 physCellId = 60
    ...                 resourceToAddModList = 1
    ...                 measIdToRemoveList = 1
    ...                 measIdToAddModList = 2
    ...                 eventId = 1
    ...                 rsrp = 70
    ...                 eventId = 1
    ...                 rsrp = 35
    ...         Step e: UE is released successfully.
	[Tags]    QC_164103    BB030    owner-jia.pan
    Delta Commission Parameters    ${OnlineParam_BB030}
	Clear Counter Files
	NSA CA UE Attach To Cell and A1scelladd and A2pscellchange without SRB3 multi FTCA Scell Autoadded  91    ${cell_id}
	Stop Traffic And Detach Ue
	Check Wireshark Logs  BB030
	Check Counters    ${PM_Counters_Check_BB030}

CB008542-ET-BB031_NSA_TFCA_DRX_A2based_PSCell_change_succ_with_SRB3_covBaseA1_FTCA_target_Scell_unFulfillAuto_A1_trigger
    [Documentation]
    ...    1. The purpose of this test case is to check A2 based PSCell change with SRB3 covBaseA1 FTCA.
    ...        cell selection combination:
    ...        TF: config cell-11 as cell-1 scell.(covBasedA1)
    ...        FT: config cell-2 as cell-11 scell.(covBasedA1)
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 attach to NR Cell 1 and trigger traffic.
    ...         b. trigger A1 measurement report for scell adding(Cell11).
    ...         c. trigger A2 measurement report for pcell changing(Cell1 to Cell11).
    ...         d. trigger A1 measurement report for scell adding(Cell2).
    ...         e. UE detach
    ...    3. Expected Results:
    ...         Step a: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on wireshark log:
    ...                 physCellId = 50
    ...                 ResourceSetToAddModList = 2
    ...                 resourceToAddModList = 18
    ...                 measIdToAddModList = 1
    ...                 eventId == 0
    ...                 rsrp = 75
    ...                 drx-Config = 1
    ...                 srb-Identity = 3
    ...         Step b: A1 triggered successfully,cell11 is added as scell. Traffic share on scell.
    ...                 IE: on wireshark log:
    ...                 sCellIndex = 9
    ...                 physCellId = 60
    ...                 resourceToAddModList = 1
    ...                 measIdToRemoveList = 1
    ...                 measIdToAddModList = 2
    ...                 eventId = 1
    ...                 rsrp = 70
    ...                 eventId = 1
    ...                 rsrp = 35
    ...         Step c: A2 triggered successfully,cell11 is changed as pcell.
    ...                 IE: on wireshark log:
    ...                 physCellId = 60
    ...                 ResourceSetToAddModList = 2
    ...                 resourceToAddModList =10
    ...                 measIdToRemoveList = 2
    ...                 measIdToAddModList = 1
    ...                 eventId = 0
    ...                 rsrp = 75
    ...                 drx-Config = 0
    ...         Step d: A1 triggered successfully,cell2 is added as scell. Traffic share on scell.
    ...                 IE: on wireshark log:
    ...                 sCellIndex = 9
    ...                 physCellId = 51
    ...                 ResourceSetToAddModList = 2
    ...                 resourceToAddModList =3
    ...                 measIdToRemoveList = 1
    ...                 measIdToAddModList = 1
    ...                 eventId = 1
    ...                 rsrp = 51
    ...         Step e: UE is released successfully.
	[Tags]    QC_164104    BB031    owner-jia.pan
    Delta Commission Parameters    ${OnlineParam_BB031}
	Clear Counter Files
	NSA CA UE Attach To Cell and A1scelladd and A2pscellchange with SRB3 FTCA Scell A1 trigger  91    ${cell_id}
	Stop Traffic And Detach Ue
	Check Wireshark Logs  BB031
	Check Counters    ${PM_Counters_Check_BB031}

CB008542-ET-BB032_NSA_TFCA_DRX_A2MG_A2based_PSCell_change_succ_without_SRB3_blind_FTCA_target
    [Documentation]
    ...    1. The purpose of this test case is to check A2 based PSCell change with MG.
    ...        cell selection combination:
    ...        TF: config cell-11 as cell-1 scell.(covBasedA1)
    ...        FT: config cell-2 as cell-11 scell.(blind)
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 attach to NR Cell 1 and trigger traffic,Drx setup.
    ...         b. trigger A1 measurement report for scell adding(Cell11).
    ...         c. trigger Measurementgap, gap setup, Drx release.
    ...         d. trigger A2 measurement report for pcell changing(Cell1 to Cell11).MG release.
    ...         e. UE detach
    ...    3. Expected Results:
    ...         Step a: NSA UE91 call setup successfully. traffic is ok.
    ...                 IE: on wireshark log:
    ...                 physCellId = 50
    ...                 ResourceSetToAddModList = 2
    ...                 resourceToAddModList = 18
    ...                 measIdToAddModList = 2
    ...                 eventId == 0
    ...                 rsrp = 75
    ...                 eventId == 1
    ...                 rsrp = 34
    ...                 drx-Config = 1
    ...         Step b: A1 triggered successfully,cell11 is added as scell. Traffic share on scell.
    ...                 IE: on wireshark log:
    ...                 sCellIndex = 9
    ...                 physCellId = 60
    ...                 resourceToAddModList = 1
    ...                 measIdToRemoveList = 1
    ...                 measIdToAddModList = 2
    ...                 eventId = 1
    ...                 rsrp = 70
    ...                 eventId = 1
    ...                 rsrp = 35
    ...         Step c: A2 measurement Gap triggered successfully
    ...                 IE: on wireshark log:
    ...                 measIdToRemoveList = 1
    ...                 measIdToAddModList = 4
    ...                 eventId = 0
    ...                 rsrp = 39
    ...                 eventId = 2
    ...                 rsrp = 20
    ...                 drx-Config = 0
    ...         Step d: A2 triggered successfully,cell11 is changed as pcell.
    ...                 IE: on wireshark log:
    ...                 physCellId = 60
    ...                 sCellIndex = 9
    ...                 physCellId = 51
    ...                 ResourceSetToAddModList = 3
    ...                 resourceToAddModList =13
    ...                 measIdToRemoveList = 4
    ...         Step e: UE is released successfully.
	[Tags]    QC_164105    BB032    owner-jia.pan
    Delta Commission Parameters    ${OnlineParam_BB032}
	Clear Counter Files
	NSA CA UE Attach To Cell and A1scelladd and A2pscellchange with MG  91    ${cell_id}
	Stop Traffic And Detach Ue
	Check Wireshark Logs  BB032
	Check Counters    ${PM_Counters_Check_BB032}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

NSA CA UE Attach To Cell and A1scelladd and A2pscellchange without SRB3 multi FTCA Scell Autoadded
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    NSA UE attach    ${ue_id}    ${cell_id}
    Send Traffic
    Verify Throuput on Pscell TDD
    Add Scell By A1
    Verify Throuput on Pscell TDD and Scell FDD
    Pscell change without SRB3 multi FTCA Scell Autoadded by A2
    Verify Throuput on Pscell FDD and Scell TDD
    Pscell change by A1
    Add Scell By A1
    Verify Throuput on Pscell TDD

NSA CA UE Attach To Cell and A1scelladd and A2pscellchange with SRB3 FTCA Scell A1 trigger
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    NSA UE attach    ${ue_id}    ${cell_id}
    Send Traffic
    Verify Throuput on Pscell TDD
    Add Scell By A1
    Verify Throuput on Pscell TDD and Scell FDD
    Pscell change with SRB3 FTCA Scell A1 trigger by A2
    Verify Throuput on Pscell FDD
    Add Scell By A1    ${ue_id}    424090
    Verify Throuput on Pscell FDD and Scell TDD

NSA CA UE Attach To Cell and A1scelladd and A2pscellchange with MG
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    NSA UE attach    ${ue_id}    ${cell_id}
    Send Traffic
    Verify Throuput on Pscell TDD
    Add Scell By A1
    Verify Throuput on Pscell TDD and Scell FDD
    Pscell change with MG
    Verify Throuput on Pscell FDD and Scell TDD

NSA UE attach
    [Arguments]    ${ue_id}=91    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA

Add Scell By A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=120
    Execute Egate Command    ${cmd}    SCellIndex 9 activated successfully

Pscell change without SRB3 multi FTCA Scell Autoadded by A2
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=0 srsrq_nr=0 scell=9
    ...    scell_rsrp=115 scell_rsrq=35
    Execute Egate Command    ${cmd}    SCellIndex 9 activated successfully

Pscell change with SRB3 FTCA Scell A1 trigger by A2
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=0 srsrq_nr=0 scell=9
    ...    scell_rsrp=40 scell_rsrq=40
    Execute Egate Command    ${cmd}    successful RA

Pscell change with MG
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${cmd}    catenate    ue_enb_param id=${ue_id} measurement_gap=gp0:19 gap_trigger=gnb_triggered
    Execute Egate Command    ${cmd}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    Execute Egate Command    ${cmd}    Successfully reconfigured dual connectivity
    ${cmd}    catenate    ue_enb_param id=${ue_id} measurement_gap=off
    Execute Egate Command    ${cmd}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=0 srsrq_nr=0 scell=9
    ...  scell_rsrp=40 scell_rsrq=40
    Execute Egate Command    ${cmd}    SCellIndex 9 activated successfully

Pscell change by A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=35 srsrq_nr=35 scell=9
    ...  scell_rsrp=50 scell_rsrq=50
    Execute Egate Command    ${cmd}    Successfully reconfigured dual connectivity

Check Wireshark Logs
    [Arguments]    ${case_id}=BB030
    check wireshark log    ${CURDIR}${/}a2a_${case_id}${/}a2a.ini

Stop Traffic And Detach Ue
    UE Detach From GNB
    Stop Traffic

Stop Traffic
    Execute Egate Command    trf_data_stop ue=91    pass_regexp=Traffic was stopped

UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=91    ${expect_string}

Send Traffic
    [Arguments]    ${ue_id}=91
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=110 trf_id=4    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=110 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UE ${ue_id}: UDP UL

Verify Throuput on Pscell TDD
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 300
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000 > 5

Verify Throuput on Pscell FDD
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 55
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000 > 5

Verify Throuput on Pscell TDD and Scell FDD
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 300
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 55
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000 > 5

Verify Throuput on Pscell FDD and Scell TDD
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 55
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 300
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000 > 5
