*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-CN1ET   owner-jolin.fan   release-5G22R3    CB008542
Resource  ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_STARTUP_RETRY}    2
${DEBUG_LOG_LEVEL}    4
${cell_id}    1
${CA_support_list}    ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa
@{PARAMS_IN_SCF}
...    NRBTS:actFdmScheduling=true
...    NRBTS:actLteNrDss=false
...    NRBTS:sCellActivationMethod=blind
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-12:pucchModeSelect=longPucch
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{OnlineParam_BB026}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-13:a3MeasEnabled=rsrp
...    NRCELL-14:a3MeasEnabled=rsrp

@{OnlineParam_BB027}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=false
...    NRCELL-1:actCDrx=true
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=6
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=36
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=5
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-1/NRHOIF-1:ssbFrequency=126750
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=0
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=0
...    NRCELL-1:a3MeasEnabled=none
...    NRCELL-12:a3MeasEnabled=none

@{PM_Counters_Check_BB027}
...    NRCELL-1:NRANS:M55145C04023=1
...    NRCELL-1:NRANS:M55145C04024=1
...    NRCELL-1:RACCU:M55114C00021=1
...    NRCELL-1:RACCU:M55114C00028=1
...    NRCELL-1:RACDU:M55115C00008=1
...    NRCELL-1:RACDU:M55115C00015=1
...    NRCELL-1:NCAC:M55118C04000>0
...    NRCELL-1:NCAC:M55118C02000=1
...    NRCELL-1:NCAC:M55118C03000=1
...    NRCELL-12:RACDU:M55115C00006=1
...    NRCELL-12:RACDU:M55115C00007=1
...    NRCELL-12:NCAC:M55118C05000>0

*** Test Cases ***
CB008542-ET-BB026_Verify_NSA_TFCA_MeasObjectNR_for_Scell_Frequency_is_configured_in_Blind_Scell_Addition_IE_when_other_meas_is_configured
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      5G_CP_IF_RRC_3011,measObjectNR for SCell frequency must be included if SCell is configured at the UE.
    ...    2.Test Case Steps:
    ...         a. CA NSA UE91 attach to NR Cell 1, scell 12 added successfully
    ...         b. HO A3 MR configured successfully
    ...         c. Start traffic and throuput is ok
    [Tags]    QC_164099   BB026    jifan
	Delta Commission Parameters    ${OnlineParam_BB026}
	Clear Counter Files
	NSA CA UE attach and Start L3 Call    91    ${cell_id}
	Stop Traffic And Detach Ue    91
	Check Wireshark Logs    BB026

CB008542-ET-BB027_NSA_TFCA_DRX_A2based_PSCell_change_succ_without_SRB3_nonCA_target
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios: US CB008542-BB#B7: PSCell A2 based PSCell change for NSA call
    ...        FT CA: config cell-12 as cell-1 scell.(covBasedA1)
    ...    2. Test Case Steps:
    ...         a. CA NSA UE91 attach to NR Cell 1
    ...         b. Start traffic and throuput is ok
    ...         c. trigger A1 MR and add scell cell-12 successfully
    ...         d. trigger A2 MR and PSCell change successfully
    ...         e. check counters
    ...            M55145C04023 ATT_A2_IADU_HO_EX_NSA_PLMN
    ...             The number of A2 based inter-frequency Intra-gNB Intra-DU HO execution attempts for NSA via MeNB or via SRB3 per PLMN-ID.
    ...            M55145C04024 SUC_A2_IADU_HO_EX_NSA_PLMN
    ...             The number of successful A2 based inter-frequency Intra-gNB Intra-DU HO executions for NSA via MeNB or via SRB3 per PLMN-ID.
    ...            M55114C00021 SGNB_SCELL_1_ADMISSION_REQ: The number of radio admission requests for 1 Scell.
    ...            M55114C00028 SGNB_SCELL_1_ADMISSION_SUCC: The number of successful radio admissions for 1 Scell additions.
    ...            M55115C00006 SGNB_DU_SCELL_ADMISSION_REQ: The number of radio admission requests for the Scell.
    ...            M55115C00007 SGNB_DU_SCELL_ADMISSION_SUCC: The number of successful radio admissions for the Scell.
    ...            M55115C00008 SGNB_DU_SCELL_1_ADMISSION_REQ: The number of radio admission requests for 1 Scell.
    ...            M55115C00015 SGNB_DU_SCELL_1_ADMISSION_SUCC: The number of successful radio admissions for 1 Scell additions.
    ...            M55118C02000 RRC_RECONF_1_SCELL_DL_ATT: RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode.
    ...            M55118C03000 RRC_RECONF_1_SCELL_DL_SUCC: Successful RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode.
    ...            M55118C04000 UE_PSCELL_1_CONF_SCELL_DL:
    ...             Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in DL.
    ...            M55118C05000 UE_SCELL_1_CONF_SCELL_DL:
    ...             Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in DL
	[Tags]    QC_164100   BB027    jifan
	Delta Commission Parameters    ${OnlineParam_BB027}
	Clear Counter Files
	NSA CA UE attach and Start L3 Call    91    ${cell_id}
	Add Scell according to config    91    carrierfreq=518910
    Trigger A2 based PSCell change    91    carrierfreq=518910
	Stop Traffic And Detach Ue    91
	Check Counters    ${PM_Counters_Check_BB027}
	Check Wireshark Logs    BB027

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

NSA CA UE Attach and Start L3 Call
    [Arguments]    ${ue_id}=91    ${cell_id}=1
    NSA UE attach    ${ue_id}    ${cell_id}
    Start traffic and verify throuput of Pcell

NSA UE attach
    [Arguments]    ${ue_id}=91    ${target_cells}=1
    Execute Egate Command    debug_log level=4
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${cmd}    catenate    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    Execute Egate Command    ${cmd}    successful RA

Add Scell according to config
    [Arguments]    ${ue_id}=91    ${carrierfreq}=518910
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A1 srsrp_nr=120
	...    pass_regexp=SCellIndex 9 activated successfully
    Verify throuput on Pcell and Scell For BB027

Trigger A2 based PSCell change
    [Arguments]    ${ue_id}=91    ${carrierfreq}=424090
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=0 srsrq_nr=0 scell=9 scell_rsrp=115 scell_rsrq=95
    ...    pass_regexp=Successfully reconfigured dual connectivity
    Verify throuput on Scell For BB027    sleep_time=30s

Check Wireshark Logs
    [Arguments]    ${case_id}=BB027
    check wireshark log    ${CURDIR}${/}a2a_${case_id}${/}a2a.ini

Stop Traffic And Detach Ue
    [Arguments]    ${ue_id}=91
    UE Detach From GNB    ${ue_id}
    Stop Traffic    ${ue_id}

Stop Traffic
    [Arguments]    ${ue_id}=91
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped

UE Detach From GNB
    [Arguments]    ${ue_id}=91    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=${ue_id}    ${expect_string}

Start traffic and verify throuput of Pcell
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
	Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UE ${ue_id}: UDP UL
    Verify throuput on Pcell For BB027    sleep_time=30s

Verify throuput on Pcell For BB027
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>250
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9.5

Verify throuput on Pcell and Scell For BB027
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 250
    sleep    10s
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 98
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9.5

Verify throuput on Scell For BB027
    [Arguments]    ${ue_id}=91    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>98
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9.5
