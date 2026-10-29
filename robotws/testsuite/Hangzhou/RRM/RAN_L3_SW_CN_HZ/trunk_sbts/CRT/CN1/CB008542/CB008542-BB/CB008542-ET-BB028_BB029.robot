*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET    owner-zora.wang  release-5G22R3    CB008542
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    2
${DEBUG_LOG_LEVEL}    4
@{PARAMS_IN_SCF}
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actFdmScheduling=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-11:actCDrx=true
...    NRCELL-1:actCDrx=true
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
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
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
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
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=64ms
...    NRCELL-1:weightForSCellSelection=100
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=4
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=40
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=80ms
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=5
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
${CA_support_list}  ca_Fr1Tdd_Fdd_Nsa,ca_Fdd_Fr1Tdd_Nsa

@{OnlineParam_BB028}
...    NRCELL-11:actCDrx=true
...    NRBTS:srb3SupportEnabled=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11:a2MeasSCellRelEnabled=none

@{OnlineParam_BB029}
...    NRCELL-11:actCDrx=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRBTS:srb3SupportEnabled=true
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{PM_Counters_Check_BB029}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-11:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=2
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:${ATT_A2_IADU_HO_EX_NSA_PLMN}=1
...    NRCELL-1:${SUC_A2_IADU_HO_EX_NSA_PLMN}=1
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
${ATT_A2_IADU_HO_EX_NSA_PLMN}    M55145C04023
#A2 Intra-gNB Intra-DU HO exec att for NSA via MeNB or SRB3 per PLMN-ID
${SUC_A2_IADU_HO_EX_NSA_PLMN}    M55145C04024
#A2 Intra-gNB Intra-DU HO exec succ for NSA via MeNB or SRB3 per PLMN-ID

@{PM_Counters_Check_BB028}
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-1:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-1:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-1:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-1:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-11:RACCU:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-11:NCAC:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-11:NCAC:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_REQ}=1
...    NRCELL-11:RACDU:${SGNB_DU_SCELL_ADMISSION_SUCC}=1
...    NRCELL-11:NCAC:${UE_SCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:${ATT_A2_IADU_HO_EX_NSA_PLMN}=1
...    NRCELL-1:${SUC_A2_IADU_HO_EX_NSA_PLMN}=1

*** Test Cases ***
CB008542-ET-BB028_NSA_TFCA_DRX_A2based_PSCell_change_succ_without_SRB3_blind_FTCA_target_DRX
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         US CB008542-BB#B7: PSCell A2 based PSCell change for NSA call
    ...        This user scenario describes the gNB behavior, when a UE, for which FR1-TDD - FDD carrier aggregation
    ...       has been configured in addition to A2 measurement on PSCell, sends an A2 measurement report for PSCell
    ...       and gNB performs intra-DU inter-frequency PSCell change to the currently configured SCell for the UE,
    ...         and SCell is added on the target cell based on the configuration during or after HO.
    ...    2. Test Case Steps:
    ...         a. NSA UE91 attach to NR Cell 1
    ...         b. trigger A1 MR to add scell FDD CELL-11
    ...         c. send A2 measurement report to trigger Intra-DU PSCell change
    ...         d. all ue detach
    ...    3. Expected Results:
    ...         a. NSA UE91 attach to NR Cell 1
    ...                IE: on message: SgNBAdditionRequestAcknowledge
    ...                spCellConfigCommon.physCellId = 50
    ...                BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceSetToAddModList = 2 items
    ...                BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceToAddModList = 18 items
    ...                eventId.eventA1.a1-Threshold.rsrp = 75
    ...                drx-Config = 1
    ...         Step b: FDD scell added. Traffic share on scell.
    ...                 IE: on RRC:
    ...                 sCellIndex=9  and  physCellId = 60
    ...                 BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceToAddModList = 1 item
    ...                 eventA2.a2-Threshold.rsrp = 35 and eventA2.a2-Threshold.rsrp = 70
    ...         Step c: A2 triggered successfully, and PSCell changes to cell 11
    ...                 IE: on RRC:
    ...                 spCellConfigCommon.physCellId = 60 and sCellIndex=9
    ...                 BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceToAddModList = 13 items
    ...                 BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceSetToAddModList = 3 items
    ...                 BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceToReleaseList = 19 items
    ...                 drx-Config = 1  and sCellConfigCommon.physCellId = 50
    ...         Step d: ALL call can be released successfully.
	[Tags]    QC_164101    BB028    zora
	Delta Commission Parameters    ${OnlineParam_BB028}
	Clear Counter Files
	NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2PSCellChange and blind scelladd
	Stop Traffic And Detach Ue
	Check Counters    ${PM_Counters_Check_BB028}
	Check Wireshark    BB028

CB008542-ET-BB029_NSA_TFCA_DRX_A2based_PSCell_change_Loop_succ_with_SRB3_covBasedA1_FTCA_target_Scell_A1_trigger
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...         US CB008542-BB#B7: PSCell A2 based PSCell change for NSA call
    ...        This user scenario describes the gNB behavior, when a UE, for which FR1-TDD - FDD carrier aggregation
    ...       has been configured in addition to A2 measurement on PSCell, sends an A2 measurement report for PSCell
    ...       and gNB performs intra-DU inter-frequency PSCell change to the currently configured SCell for the UE,
    ...         and SCell is added on the target cell based on the configuration during or after HO.
    ...    2. Test Case Steps:
    ...         a. NSA UE91 attach to NR Cell 1
    ...         b. trigger A1 MR to add scell FDD CELL-11
    ...         c. send A2 measurement report to trigger Intra-DU PSCell change
    ...         d. trigger A1 MR to add scell TDD CELL-1
    ...         e. send A1 measurement report to trigger PSCell change
    ...         f. all ue detach
    ...    3. Expected Results:
    ...         a. NSA UE91 attach to NR Cell 1
    ...                IE: on message: SgNBAdditionRequestAcknowledge
    ...                spCellConfigCommon.physCellId = 50
    ...                BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceSetToAddModList = 2 items
    ...                BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceToAddModList = 18 items
    ...                eventId.eventA1.a1-Threshold.rsrp = 75
    ...             drx-Config = 1 and SRB-ToAddMod.srb-Identity = 3
    ...         Step b: FDD scell added. Traffic share on scell.
    ...                 IE: on RRC:
    ...                 sCellIndex=9  and  physCellId = 60
    ...                 BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceToAddModList = 1 item
    ...                 eventA2.a2-Threshold.rsrp = 35 and eventA2.a2-Threshold.rsrp = 70
    ...         Step c: A2 triggered successfully, and PSCell changes to cell 11
    ...                 IE: on RRC:
    ...                 spCellConfigCommon.physCellId = 60
    ...                 BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceToAddModList = 10 items
    ...                 BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceSetToAddModList = 2 items
    ...                 BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceToReleaseList = 19 items
    ...                 eventId.eventA1.a1-Threshold.rsrp = 75 and drx-Config = 0
    ...         Step d: TDD scell added. Traffic share on scell.
    ...                 sCellIndex=9  and  physCellId = 50
    ...                 BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceToAddModList = 3 items
    ...                 BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceSetToAddModList = 2 items
    ...                 eventA1.a1-Threshold.rsrp = 40 and eventA2.a2-Threshold.rsrp = 50
    ...         Step e: A1 triggered successfully, and PSCell changes to cell 1
    ...                spCellConfigCommon.physCellId = 50 and eventA1.a1-Threshold.rsrp = 75
    ...                BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceSetToAddModList = 2 items
    ...                BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceToAddModList = 18 items and drx-Config = 1
    ...         Step f: FDD scell added. Traffic share on scell.
    ...                 IE: on RRC:
    ...                 sCellIndex=9  and  physCellId = 60
    ...                 BWP-Uplink.bwp-Dedicated.pucch-Config.setup.resourceToAddModList = 1 item
    ...                 eventA2.a2-Threshold.rsrp = 35 and eventA2.a2-Threshold.rsrp = 70
    ...         Step g: ALL call can be released successfully.
	[Tags]    QC_164102    BB029    zora
	Delta Commission Parameters    ${OnlineParam_BB029}
	Clear Counter Files
	NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2PSCellChange
	Initial covBaseA1 scelladd after a2PSCellChange and a1PSCellChange
	Stop Traffic And Detach Ue
	Check Counters    ${PM_Counters_Check_BB029}
	Check Wireshark

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2PSCellChange
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    NSA UE attach    ${ue_id}    ${cell_id}
    Send trffic
    Verify Throuput on Pscell cell1
    Add gNB Cell As Scell By A1
    Verify Throuput on Pscell cell1 and Scell cell11
    PSCell change By A2
    Verify Throuput on Pscell cell11

NSA CA UE Attach To Cell and Initial covBaseA1 scelladd and a2PSCellChange and blind scelladd
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    NSA UE attach    ${ue_id}    ${cell_id}
    Send trffic
    Verify Throuput on Pscell cell1
    Add gNB Cell As Scell By A1
    Verify Throuput on Pscell cell1 and Scell cell11
    PSCell change By A2
    Verify Throuput on Pscell cell11 and Scell cell1

Initial covBaseA1 scelladd after a2PSCellChange and a1PSCellChange
    Add gNB Cell As Scell By A1    carrierfreq=424090
    Verify Throuput on Pscell cell11 and Scell cell1
    Pscell change by A1
    Verify Throuput on Pscell cell1
    Add gNB Cell As Scell By A1
    Verify Throuput on Pscell cell1 and Scell cell11

NSA UE attach
    [Arguments]    ${ue_id}=91    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA

Add gNB Cell As Scell By A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A1 srsrp_nr=100
    ...    pass_regexp=SCellIndex 9 activated successfully

PSCell change By A2
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=0 srsrq_nr=0 scell=9
    ...    scell_rsrp=115 scell_rsrq=35
    Execute Egate Command    ${cmd}    pass_regexp=Sending SgNB Modification Confirm

Pscell change by A1
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=35 srsrq_nr=35 scell=9
    ...  scell_rsrp=50 scell_rsrq=50
    Execute Egate Command    ${cmd}    pass_regexp=Sending SgNB Modification Confirm

Check Wireshark
    [Arguments]    ${case_id}=BB029
    check wireshark log    ${CURDIR}${/}a2a_${case_id}${/}a2a.ini

Stop Traffic And Detach Ue
    UE Detach From GNB
    Stop Traffic

Stop Traffic
    Execute Egate Command    trf_data_stop ue=91    pass_regexp=Traffic was stopped

UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=91    ${expect_string}

Send trffic
    [Arguments]    ${case_id}=BB029    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UE ${ue_id}: UDP UL

Verify Throuput on Pscell cell1
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>300
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>6

Verify Throuput on Pscell cell11
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>50
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>6

Verify Throuput on Pscell cell1 and Scell cell11
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 300
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 60
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>6

Verify Throuput on Pscell cell11 and Scell cell1
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 50
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 300
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>6

