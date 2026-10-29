*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CIT    CLOUD_5G_I_BOO_AP_LOO
...     owner-cathy.mao    team-SG2    release-5G22R2    CB008015    CB007873
Resource    ../../../../resources/DevHZ5_resource.robot


*** Variables ***
${CA_support_list}    ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Nsa,

@{Golden_Change_BOO}
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=100
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=1
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity


@{PARAMS_IN_SCF}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:actCDrx=true
...    NRCELL:sMeasConfigSsbRsrp=0
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a1MeashoEnabled=rsrp
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoEnabled=rsrp
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-11:absThreshSsbRsrpConsolidation=0
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=0
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=518910
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=${EMPTY}
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=${EMPTY}
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=${EMPTY}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=11
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=60
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=65
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    MRBTS-1/NRBTS-1/NRCELL-11:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasPCellSwitchEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=75
...    MRBTS-1/NRBTS-1/NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    @{Golden_Change_BOO}


${ScellAdditionMethod_A1}    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1

@{Pcell_Switch_To_F11T1}
...    SCellIndex 9 activated successfully
...    sCellToReleaseList
...    physCellId 50
...    physCellId 60

@{Pcell_Switch_To_T1T2}
...    SgNB Modification Confirm
...    sCellToReleaseList
...    physCellId 50
...    physCellId 51

@{set_gap_a2}
...    Sending SgNB Modification Confirm
...    measGapConfig setup
...    drx-Config release : NULL


@{Endc_Blind_Ca}
...    Sending SgNB Modification Confirm
...    Successfully reconfigured dual connectivity
...    SCellIndex 9 activated successfully
...    physCellId 60
...    physCellId 50

@{A1_Add_Fdd_Scell_11}
...    SCellIndex 9 activated successfully
...    sCellToAddModList
...    physCellId 60




&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970

&{CELLS_PHY}
...     1=50
...     2=51
...     11=60
...     12=61
...     13=62

@{PM_Counters}
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=${3+${${loop_time}-1}*2}
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=0
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=${2+${${loop_time}-1}*1}
...    NRCELL-12:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=0
...    NRCELL-13:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=0
...    NRCELL-14:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=0
...    NRCELL-1:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}=0
...    NRCELL-2:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}=0
...    NRCELL-11:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}=${1+${loop_time}-1}
...    NRCELL-12:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}=0
...    NRCELL-13:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}=0
...    NRCELL-14:NRANS:${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}=0
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=${3+${${loop_time}-1}*2}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=${2+${loop_time}-1}
...    NRCELL-12:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-13:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-14:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=${3+${${loop_time}-1}*2}
...    NRCELL-2:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=${2+${loop_time}-1}
...    NRCELL-12:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-13:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-14:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=${2+${loop_time}-1}
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=${2+${loop_time}-1}
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=${1+${loop_time}-1}
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=0
...    NRCELL-13:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=0
...    NRCELL-14:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=${3+${${loop_time}-1}*2}
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=${2+${loop_time}-1}
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-13:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-14:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=${3+${${loop_time}-1}*2}
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=${2+${loop_time}-1}
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-13:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-14:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=0
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=${3+${${loop_time}-1}*2}
...    NRCELL-2:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=${2+${loop_time}-1}
...    NRCELL-12:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0
...    NRCELL-13:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0
...    NRCELL-14:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=0
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>=${10*${3+${${loop_time}-1}*2}}
...    NRCELL-2:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}=0
...    NRCELL-11:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>=${10*${2+${loop_time}-1}}
...    NRCELL-12:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}=0
...    NRCELL-13:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}=0
...    NRCELL-14:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}=0
...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>=60
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>=30
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>=60
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL}=0
...    NRCELL-13:NCAC:${UE_SCELL_1_CONF_SCELL_DL}=0
...    NRCELL-14:NCAC:${UE_SCELL_1_CONF_SCELL_DL}=0
...    NRCELL-1:NCADU:${PSCELL_UE_1_ACT_SCELL_DL}>=60
...    NRCELL-2:NCADU:${PSCELL_UE_1_ACT_SCELL_DL}=0
...    NRCELL-11:NCADU:${PSCELL_UE_1_ACT_SCELL_DL}>=60
...    NRCELL-12:NCADU:${PSCELL_UE_1_ACT_SCELL_DL}=0
...    NRCELL-13:NCADU:${PSCELL_UE_1_ACT_SCELL_DL}=0
...    NRCELL-14:NCADU:${PSCELL_UE_1_ACT_SCELL_DL}=0
...    NRCELL-1:NCADU:${MAX_PSCELL_UE_1_ACT_SCELL_DL}>=1
...    NRCELL-2:NCADU:${MAX_PSCELL_UE_1_ACT_SCELL_DL}=0
...    NRCELL-11:NCADU:${MAX_PSCELL_UE_1_ACT_SCELL_DL}>=1
...    NRCELL-12:NCADU:${MAX_PSCELL_UE_1_ACT_SCELL_DL}=0
...    NRCELL-13:NCADU:${MAX_PSCELL_UE_1_ACT_SCELL_DL}=0
...    NRCELL-14:NCADU:${MAX_PSCELL_UE_1_ACT_SCELL_DL}=0
...    NRCELL-1:NCADU:${SCELL_ACTIVATIONS}=${2+${loop_time}-1}
...    NRCELL-2:NCADU:${SCELL_ACTIVATIONS}=${2+${loop_time}-1}
...    NRCELL-11:NCADU:${SCELL_ACTIVATIONS}=${1+${loop_time}-1}
...    NRCELL-12:NCADU:${SCELL_ACTIVATIONS}=0
...    NRCELL-13:NCADU:${SCELL_ACTIVATIONS}=0
...    NRCELL-14:NCADU:${SCELL_ACTIVATIONS}=0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=${2+${loop_time}-1}
...    NRCELL-2:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=${2+${loop_time}-1}
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=${1+${loop_time}-1}
...    NRCELL-12:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0
...    NRCELL-13:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0
...    NRCELL-14:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=0



${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${ATT_A1_IF_INTRA_DU_HO_NSA_MNB}    M55145C02005
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000
${PSCELL_UE_1_ACT_SCELL_DL}    M55316C03001
${MAX_PSCELL_UE_1_ACT_SCELL_DL}    M55316C05001
${SCELL_ACTIVATIONS}    M55316C09000
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006


${loop_time}    3

*** Test Cases ***
5GSW_CP_CIT033_Classical_NSA_CA_of_Scell_Addition_PscellSwitch_ScellRelease_HO_and_loopback_successful
    [Documentation]
    ...    1. The purpose of this test case is to check F+T,T+T,T+F covBasedA1 NSA CA,
    ...    Scell Addition,PscellSwitch,ScellRelease,HO.
    ...    2.expect result for each step:
    ...      a.Make NSA UE91 attach to simulated ENB 1 cell1
    ...      b.Setup Endc with gNB cell11 and Setup blind F+T CA with Scell on gNB cell1
    ...      c.InterFreq HO From FDD_Cell_11 To TDD_Cell_1
    ...      d.Trigger A1 With Higher Rsrp To Add TDD_Scell_2 For TDD_Cell_1
    ...      e.Release TDD_Scell_2
    ...      f.Trigger A1 With Lower Rsrp To Add FDD_Scell_11 For TDD_Cell_1
    ...      g.Change NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
    ...      h.Trigger A2 Pcell Switch From T1F11 To F11T1
    ...      i.Trigger A1 Pcell Switch From F11T1 To T1T2
    ...      j.Repeate steps e-i
    ...      k.check wireshark
    ...      l.check counter
    ...      m.stop traffic and ue derigester sucessful
    ...    note: TDD as Pcell only A2 for pcell change
    [Tags]    QC_47237
    [Timeout]     60 min
    Ue Attach To Cell and Initial Endc Blind Ca
    InterFreq HO From Cell_11 To Cell_1
    Trigger A1 With Higher Rsrp To Add Tdd_Scell_2 For Cell_1
    Release Scell    scell_idx=9    scell=2
    Trigger A1 With Lower Rsrp To Add Fdd_Scell_11 For Cell_1
    Delta Commission Parameters    ${ScellAdditionMethod_A1}
    A2 Pcell Switch From T1F11 To F11T1
    A1 Pcell Switch From F11T1 To T1T2
    Repeat Above Steps If Need
    Check WireShark Log    ${CURDIR}${/}a2a_CIT033${/}a2a.ini
         ...    wait_string=UEContextModificationResponse::124
    Check Counters    ${PM_Counters}
    UE Detach From GNB

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

UE Detach From GNB
  [Arguments]    ${expect_string}=${EMPTY}
  Execute Egate Command    ue_detach id=91    ${expect_string}

Repeat Above Steps If Need
    Repeat Keyword    ${${loop_time}-1}    Case Repetive Steps

Case Repetive Steps
    Release Scell    scell_idx=9    scell=2
    Trigger A1 With Lower Rsrp To Add Fdd_Scell_11 For Cell_1
    Delta Commission Parameters    ${ScellAdditionMethod_A1}
    A2 Pcell Switch From T1F11 To F11T1
    A1 Pcell Switch From F11T1 To T1T2

Ue Attach To Cell and Initial Endc Blind Ca
    Execute Egate Command    ue_change_location id=91 cell=1 enb=1
    UE Attach To Enb Cell1    ue_id=91
    Start RRC Log    UE_initial_ENDC_Blind_Ca
    Initial Endc And Blind Ca    ue_id=91    target_gnb=2    target_cells=11    bearer_id=2
    Send And Verify Throuput
    Get RRC Log

InterFreq HO From Cell_11 To Cell_1
    [Arguments]    ${source_cell}=11    ${target_cell}=1
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${source_cell}
    Set MeasurementGap and Initial A2 Event    carrierfreq=${carrier_freq}
    ${HO_Target_carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${target_cell}
    ${target_phycell_id}     Get From Dictionary    ${CELLS_PHY}    ${target_cell}
    Initial InterFreA3 Ho    carrierfreq=${HO_Target_carrier_freq}    phycell_id=${target_phycell_id}

Trigger A1 With Higher Rsrp To Add Tdd_Scell_2 For Cell_1
    [Arguments]    ${pcell}=1    ${ue_id}=91
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=120
    ...    pass_regexp=SCellIndex 9 activated successfully
    Should Contain    ${ret1}    physCellId 51
    Verify Throuput

Trigger A1 With Lower Rsrp To Add Fdd_Scell_11 For Cell_1
    [Arguments]    ${pcell}=1    ${ue_id}=91
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=80 ssinr_nr=59 srsrq_nr=80
    ...    pass_regexp=${A1_Add_Fdd_Scell_11}    timeout=20s
    Verify Throuput

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial Endc And Blind Ca
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    pass_regexp=${Endc_Blind_Ca}    timeout=20s


Send And Verify Throuput
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=2    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=3    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=4    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=5    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=6    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=ul mbps=10    UE 91: UDP UL
    Verify Throuput    sleep_time=30s

Verify Throuput
    [Arguments]    ${sleep_time}=15s
    sleep    ${sleep_time}
    Execute Egate Command    ue_disp
    ${ret0}    Execute Egate Command    ue_stats_nr id=91 scell=8-10 type=pdsch    pass_regexp=Average
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>360

Set MeasurementGap and Initial A2 Event
    [Arguments]    ${carrierfreq}    ${ue_id}=91
    Execute Egate Command    ue_enb_param id=91 measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=${set_gap_a2}    timeout=20s


Initial InterFreA3 Ho
    [Arguments]    ${carrierfreq}    ${phycell_id}    ${ue_id}=91
    Execute Egate Command    ue_enb_param id=91 measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${ret1}    sCellToReleaseList

A2 Pcell Switch From T1F11 To F11T1
    [Arguments]    ${pcell}=1    ${ue_id}=91
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    1
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    ${pcell_switch_by_A2}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
     ...    srsrp_nr=11 srsrq_nr=11 scell=9 scell_rsrp=120 scell_rsrq=120
    ${ret1}=    Execute Egate Command    ${pcell_switch_by_A2}
    ...    pass_regexp=${Pcell_Switch_To_F11T1}    timeout=20s
    Verify Throuput


A1 Pcell Switch From F11T1 To T1T2
    [Arguments]    ${scell}=1    ${ue_id}=91
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${scell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    ${pcell_switch_by_A1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=0 srsrq_nr=0
     ...    scell=9 scell_rsrp=120 scell_rsrq=120
    ${ret1}=    Execute Egate Command    ${pcell_switch_by_A1}
    ...    pass_regexp=${Pcell_Switch_To_T1T2}    timeout=20s
    Verify Throuput

Release Scell
    [Arguments]    ${scell_idx}    ${scell}    ${ue_id}=91
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${scell}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_idx} scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList
