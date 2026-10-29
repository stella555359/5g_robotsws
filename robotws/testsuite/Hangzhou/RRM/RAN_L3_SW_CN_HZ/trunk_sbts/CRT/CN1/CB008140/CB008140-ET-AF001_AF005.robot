*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...               release-SBTS23R3    owner-dandan.chen    team-Jazz    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    4
${numofmaxue}    14
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True} 
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB1_A2_for_NRCELL_1}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_for_NRCELL_11}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
#...    NRDU-1:interNodeUplaneIpConfig:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB

...    NRBTS:actMeasBasedSCellAdditionSa=disabled
...    NRDU-1:actConnectedModeMobilityCA=false
...    NRDU-1:actInterNumerologyCa=true

@{PARAMS_FOR_GNB1}
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
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
...    NRBTS/NRADJNRCELL-3:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-3:gNbId=2
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=3
...    NRBTS/NRADJNRCELL-3:nrarfcn=653400
...    NRBTS/NRADJNRCELL-3:physCellId=52
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-4:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-4:fiveGsTac=200
...    NRBTS/NRADJNRCELL-4:gNbId=2
...    NRBTS/NRADJNRCELL-4:gNbIdLength=22
...    NRBTS/NRADJNRCELL-4:lcrId=4
...    NRBTS/NRADJNRCELL-4:nrarfcn=648000
...    NRBTS/NRADJNRCELL-4:physCellId=53
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-4:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=2
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=2
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=153400
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=2
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-3:lcrId=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
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
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-11:gNbId=2
...    NRCELL-1/NRREL-11:gNbIdLength=22
...    NRCELL-1/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-11:lcrId=11
...    NRCELL-1/NRREL-11:removeNotAllowed=false
...    NRCELL-1/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-12:gNbId=2
...    NRCELL-1/NRREL-12:gNbIdLength=22
...    NRCELL-1/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-12:lcrId=12
...    NRCELL-1/NRREL-12:removeNotAllowed=false
...    NRCELL-1/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-12:gnbPlmn:mncLength=3
@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-3:sCellDeactivationTimerGNB=infinity
...    NRCELL-4:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-3:weightForSCellSelection=10
...    NRCELL-4:weightForSCellSelection=30
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=60
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
#...    NRCELL-11:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing

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
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:ssbFrequency=663360
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=1
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:ssbFrequency=657984
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77

@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{GNB2_CA_for_NRCELL_11}
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11:actVoNR=false
#...    NRCELL-11:nrCellType=4DL4UL
...    NRCELL-11:a1MeasSCellAddEnabled=none
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=2
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-11:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=60|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL-11:a2MeasSCellRelEnabled=none
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=10|a2TimeToTriggerSCellRelSsbRsrq=0ms

@{GNB1_A2_for_NRCELL_1}
...    NRCELL-1:a2MeasSCellRelEnabled=none
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=5120ms
...    NRCELL-1:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=35|a2TimeToTriggerSCellRelSsbRsrq=5120ms

@{GNB2_DRB10_RLCUM}
...    MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    NRBTS-2/NRDRB-10:rlcMode=RLC_UM
...    NRBTS-2/NRDRB-10:nrDrbRlcUmDN=MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1

@{GNB2_DRB10_RLCUM_rollback}
...    NRBTS-2/NRDRB-10:rlcMode=RLC_AM

@{Ext_Gnb_csiReportPeriodicity}
...    MRBTS-1/NRBTS-2/NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots20

@{Ext_Gnb_csiReportPeriodicity_rollback}
...    MRBTS-1/NRBTS-2/NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots320

#@{RD_Counters_Check_AF001_GNB2}
#...    IGNB_CA_ATT_SA_REL=1

@{PM_Counters_Check_AF001_GNB2}
...    NRCELL-11:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=2
...    NRCELL-11:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=1
...    NRCELL-11:NCAC:${IGNB_CA_ATT_SA_REL}=1

@{PM_Counters_Check_AF001_GNB1}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=0

#@{RD_Counters_Check_priGNB_AF005}
#...    IGNB_CA_ATT_1_SCELL_SA=1
#...    IGNB_CA_ATT_SA_REJ=1

#@{RD_Counters_Check_extGNB_AF005}
#...    IGNB_CA_ADD_REQ_SA_NRADJ=1
#...    IGNB_CA_SCELL_ADMI_REQ_SA=1
#...    IGNB_CA_SCELL_ADMI_SUCC_SA=1
#...    IGNB_CA_ADD_REQ_SA_REJ_NRADJ=1

@{PM_Counters_Check_priGNB_AF005}
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=1
...    NRCELL-1:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=0
...    NRCELL-1:NCAC:${IGNB_CA_ATT_1_SCELL_SA}=1
...    NRCELL-1:NCAC:${IGNB_CA_ATT_SA_REJ}=1

@{PM_Counters_Check_extGNB_AF005}
...    NRCELL-3:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_NRADJ}=1
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_REQ_SA}=1
...    NRCELL-3:RSACU:${IGNB_CA_SCELL_ADMI_SUCC_SA}=1
...    NRBTS-1:ADJNB:${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}=1

${IGNB_CA_ATT_1_SCELL_SA}    M55118C11001
${IGNB_CA_ATT_SA_REL}    M55118C11008
${IGNB_CA_ATT_SA_REJ}    M55118C11007
${IGNB_CA_ADD_REQ_SA_REJ_NRADJ}    M55175C00002

${IGNB_CA_ADD_REQ_SA_NRADJ}    M55175C00001
${IGNB_CA_SCELL_ADMI_REQ_SA}    M55138C03501
${IGNB_CA_SCELL_ADMI_SUCC_SA}    M55138C03502

${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
#This counter is updated on the SCell if an SCell was requested which is newly added in the SCell-ToBeSetupMod-List IE
#as part of F1AP: UE CONTEXT MODIFICATION REQUEST or F1AP: UE CONTEXT SETUP REQUEST (in case of Inter gNB CA) messages
#received by the DU during SCell Addition and SCell Change procedures.

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
#This counter is updated on the PCell if exactly 1 SCell was requested which is newly added in the
#SCell-ToBeSetupMod-List IE as part of F1AP: UE CONTEXT MODIFICATION REQUEST messages received by the DU during SCell
#Addition and SCell Change procedures.

${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
#This counter is updated on the PCell if exactly 1 SCell was admitted which is newly added as part of F1AP: UE CONTEXT
#MODIFICATION REQUEST messages received by the DU during SCell Addition and SCell Change procedures.

*** Test Cases ***
CB008140-ET-AF001_Inter-gNB_FT_CA_Blind_Scell_addition_Failure_cause_no_CA_eligible_DRB_in_prime_gNB
    [Documentation]
    ...    [purpose]: The purpose of this case is to verify When single PDU session mapped to DRB with RLC UM is
    ...    established for 5G-UE , inter-gNB CA SCell addition for a SA UE context having one candidate SCell only in
    ...    an ext-gNB will fail due to rejection in preparation phase (no-CA-eligible-DRB-found) from prime-gNB-DU.
    ...    [Configuration]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140-AF
    ...    [Test Case Steps]:
    ...         a.make a normal SA CA_FT ue
    ...         b.make a normal SA CA_FT ue, but scell add failed
    ...    [Expected Results]:
    ...         a.CA_FT UE work normally
    ...         b.CA_FT UE, but scell add failed as no-CA-eligible-DRB-found
    [Tags]    QC_217446    dandchen    AF001
    Clear Counter Files
    Clear Counter Files GNB2
    Make Normal CA SA UE
    Make CA UE call but scell add fail
    Check Counters    ${PM_Counters_Check_AF001_GNB1}
    Check Counters GNB2    ${PM_Counters_Check_AF001_GNB2}
    Check WireShark Log    ${CURDIR}${/}A2A_AF_001${/}a2a.ini    wait_string=UEContextRelease::4
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_AF_001${/}a2a_gnb2.ini    wait_string=UEContextRelease::20
    Check userstop cause shall be correct
    [Teardown]    Common Test Teardown And Stop Capture Logs for AF001

CB008140-ET-AF005_Inter-gNB_TT_CA_Blind_Scell_addition_Failure_cause_failed_to_allocate_specific_DU_resources_in_ext_gNB
    [Documentation]
    ...    [purpose]: The purpose of this case is to verify WWhen all of available resources are already allocated,
    ...    inter-gNB CA SCell addition for a SA UE context having one candidate SCell only in an ext-gNB will fail due
    ...    to failure of allocating specific CSI-RS resources in target ext-gNB-DU.
    ...    [Configuration]: 2 classical cmWave gNb
    ...    [Cover Feature]: CB008140-AF
    ...    [Test Case Steps]:
    ...         a.make 13 UE to use all PUCCH resource of ext gnb nrcell3
    ...         b.make 14th UE on ext gnb nrcell3 should be fail
    ...         c.make CA ue on priGNB Nrcell1, no scell added
    ...    [Expected Results]:
    ...         a.13 UEs added successful
    ...         b.the 14th UE added failed
    ...         b.CA_TT UE, but scell add failed as no-radio-resources-available
    [Tags]    QC_217449    dandchen    AF005
    Delta Commission Parameters GNB2    ${Ext_Gnb_csiReportPeriodicity}
    Clear Counter Files
    Clear Counter Files GNB2
    Make Multi SA UE On Ext Gnb Nrcell3
    Make SA UE-14 On Ext Gnb Nrcell3 should be failed as RRC Reject
    Make CA UE call but scell add fail for AF005
    Check Counters    ${PM_Counters_Check_priGNB_AF005}
    Check Counters GNB2    ${PM_Counters_Check_extGNB_AF005}
    Check WireShark Log    ${CURDIR}${/}A2A_AF_005${/}a2a.ini    wait_string=UEContextRelease::10
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_AF_005${/}a2a_gnb2.ini    wait_string=UEContextRelease::4
    [Teardown]    Common Test Teardown And Stop Capture Logs for AF005

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
#    Setup 2Airphone Env    fddtdd_sansa_cmwv/L1B/6cells_gnb1_2T_gnb2_2T2F
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2T_gnb2_2T2F

Common Test Teardown And Stop Capture Logs for AF001
    Delta Commission Parameters GNB2    ${GNB2_DRB10_RLCUM_rollback}
    Make Normal CA SA UE
    Common Test Teardown And Stop Capture Logs

Common Test Teardown And Stop Capture Logs for AF005
    Release All UEs On Ext Gnb
    Delta Commission Parameters GNB2    ${Ext_Gnb_csiReportPeriodicity_rollback}
    Common Test Teardown And Stop Capture Logs

Release All UEs On Ext Gnb
    FOR    ${i}    IN RANGE    ${2}    ${numofmaxue}
        UE Deregister From gNB    ${i}
    END

Make Multi SA UE On Ext Gnb Nrcell3
    FOR    ${i}    IN RANGE    ${2}    ${numofmaxue}
        Sa Ue Attach    ${i}    ${i}    3    3
        Setup pdu session for nonCA ue    ${i}    ${i}
    END

Make SA UE-14 On Ext Gnb Nrcell3 should be failed as RRC Reject
    Sa Ue Attach    14    14    3    3    RRC Reject

Setup pdu session for nonCA ue
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    INITIAL CONTEXT SETUP RESPONSE

Check userstop cause shall be correct
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}gnb2${/}wireshark.pcap    itf_l2_ps_user_UserStopReq_t.cause == 3
    should be equal As Numbers    ${number}    1

Make Normal CA SA UE
    Sa Ue Attach    1    1    3    11
    Setup pdu session with scell add blind
    Send And Verify Throuput    1    20
    UE Deregister From gNB    1

Make CA UE call but scell add fail
    Delta Commission Parameters GNB2    ${GNB2_DRB10_RLCUM}
    Sa Ue Attach    1    1    3    11
    Setup pdu session with no scelladd
    Send And Verify Throuput for no scell UE    1    20    60
    UE Deregister From gNB    1

Make CA UE call but scell add fail for AF005
    Sa Ue Attach    1    1    2    1
    Setup pdu session with no scelladd
    Send And Verify Throuput for no scell UE    1    20    140
    UE Deregister From gNB    1

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2
    ...    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session with scell add blind
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    sCellIndex 1

Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=1    ${gateway}=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    fail_regexp=sCellIndex 1

Send And Verify Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pscell    sleep_time=30s

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000>220
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>280
    Should Be True    ${ul_throughput}/1000>8

Send And Verify Throuput for no scell UE
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s    ${expect_dl_TP}=60
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pscell for no scell UE    sleep_time=30s    expect_dl_TP=${expect_dl_TP}

Verify Throuput on Pscell for no scell UE
    [Arguments]    ${ue_id}=1    ${sleep_time}=30s    ${expect_dl_TP}=60
    sleep    ${sleep_time}
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${expect_dl_TP}
    Should Be True    ${ul_throughput}/1000>8

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=on
