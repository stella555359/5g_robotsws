*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-Tingjian.Mao
...    CLOUD_5G_I_BOO_AP_LOO    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${AP_UDPLOG_LEVEL}    1

${SOS_REPORT_STARTUP_1_FLAG}    pass:True,fail:True
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_FOR_5GC000772}
...    @{PARAMS_FOR_5GC002060}
...    @{PARAMS_FOR_5GC000884}
...    @{PARAMS_FOR_5GC001118_CB007797}
...    @{PARAMS_FOR_5GC001729}
...    @{8290_enable}
...    @{NRREL_for_NRCELL-3}
...    @{PARAMS_IN_BOO_4T2F_8PIPES}
...    @{same frequency}
...    @{ParamChange_B038}

@{NRREL_for_NRCELL-3}
...    NRCELL-3:freqBandIndicatorNR=77
...    NRCELL-3/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-4:gNbId=1
...    NRCELL-3/NRREL-4:gNbIdLength=22
...    NRCELL-3/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-4:removeNotAllowed=false
...    NRCELL-3/NRREL-4:lcrId=4
...    NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-4:sCellPrio=2
...    NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:sCellPrio=1
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-1:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-1:type0CoresetConfigurationIndex=12
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7840
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=633000
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:type0CoresetConfigurationIndex=12
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7912
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=639666
...    MRBTS-1/NRBTS-1/NRCELL-3:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-3:type0CoresetConfigurationIndex=12
...    MRBTS-1/NRBTS-1/NRCELL-3:gscnOrSsPbchArfcn=7981
...    MRBTS-1/NRBTS-1/NRCELL-3:nrarfcn=646334
...    MRBTS-1/NRBTS-1/NRCELL-4:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-4:type0CoresetConfigurationIndex=12
...    MRBTS-1/NRBTS-1/NRCELL-4:gscnOrSsPbchArfcn=7840
...    MRBTS-1/NRBTS-1/NRCELL-4:nrarfcn=633000

@{ParamChange_B038}
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-3:nrCellType=4DL4UL
...    delete:NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1
...    delete:NRCELL-3:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-3:periodicCsiAcquisition:maxCsirsNumber
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-4:nrCellType=4DL4UL
...    delete:NRCELL-4:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1
...    delete:NRCELL-4:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-4:periodicCsiAcquisition:maxCsirsNumber
...    NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=1
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-3:numberOfRxBeamforming=4Rx
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-4:numberOfRxBeamforming=4Rx
...    NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

@{8290_enable}
...    NRCELL:actK1Opt=intra-gNB
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actNonBfAndBfCa=true
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA
...    NRCELL-1:measGapSelectionSA=balancedChoice
...    NRCELL:actCDrx=false

...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=infinity
...    NRCELL:reportIntervalA6MeasSCellSwap=ms1024
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=5|a2TimeToTriggerSCellRelSsbRsrq=480ms
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-3:weightForSCellSelection=50
...    NRCELL-4:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-2:actProactUlScheduling=false
...    NRCELL-3:actProactUlScheduling=false
...    NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-2:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-3:pucchF3ModulationScheme=pi2bpsk
...    NRCELL-4:pucchF3ModulationScheme=pi2bpsk

${SA_Capa_Support_B038}    SEPARATOR=
...    E9A09000575F5A13160003C328016008000004000045AF0093170019C3D09009B20C19F21CF942C0E098040623807DC6C4CC0D608C21A0810
...    7482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E639F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E209015
...    5B262AC0852E31238F21CFA8E7CC31E50B0381C3C09FD8000007F600000044000702A8D89BAC1184341020E9048082D931540439F1867C833
...    E50B0381C3C017003FF001C00FFC00110001C0AE3E236B04610D04083E50480AAD931561238F11C78C00000031E438F0000040E1E027FFC00
...    001FFF00000110001C01078789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400071040000085815878
...    9A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C
...    0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C00
...    00082C0AC5C4D000E2300070A000002058158788C001C46000006160563E26000713400389A001C4D00000E160401C0468099013602086B0C
...    908428913639F0E14489B1CF870A244D8E7C3851226C73E1C2891362130E2448913639F0E14081B1CF811204081B1CF811204081B1CF81120
...    4081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C08D0204081B14B86191018C6318C6318C6318C630
...    10107043406200040018000D018800100060003406200040018000C018800100060003406200040018000D028880010006000340620004001
...    8000D028880010006000340A2200040018000D028880010006000340A2200040018000D028880010006000340A2200040018000D028880010
...    0060003406200040018000D038888001000600001E8260078005038280381804A00E000C0480080C07C120040000000200000401000000008
...    000010040000100200000C01000008008000050040020080200800006004000038020010000000400004002000024010000060080000A0040
...    00058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA
...    48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192
...    CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A0502
...    8140A05028140A05000708080600C02004008404008020100C018402004008080600C02018030404030060100C018402004008080600C0200
...    4008804030060100C018040300608080100402004010C0400802010020080400802010020086A87C0004080C10181C282C30344044484C506
...    0646C70747C8494989CA0A4A8B4BD05060B40

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB008290-ET-B038_Verify_scell_CSI-RS_downgrade_and_remaining_scell_resource_unchanged_during_scell_swap_TTT_per-band_combination_capability_check
    [Documentation]
    ...    1. This user scenario during SCell Swap, the target TDD SCell requires fewer CSI-RS resources than the current
    ...     serving cell to be swapped Even though the limit of the UE's per-band combination CSI-RS capability is not reached,
    ...     the gNB does not modify the CSI-RS resources of the other serving cells that remain configured after the swap
    ...    2. Configuration:
    ...       TDD PCell F1-Cell3 NRCELL/NRREL configuration for CA
    ...       SCell Frequency SCell (NRREL.sCellAdditionMethod) SCell Priority(NRREL.sCellPrio)
    ...       F2-TDD    SCell1 (SCell configured,A6 configured)    1
    ...                 SCell4 (swap candidate)                    2
    ...       F3-TDD    SCell2 (SCell configured,A6 configured)    1
    ...       NRBTS.actSCellSwapFr1 is set to a6BasedSa
    ...       FDD Cell11, FDD cell12, TDD cell1, TDD cell2, TDD cell3, TDD cell4
    ...       TDD Cell1 and Cell2 have the same bandwidth.
    ...       TDD Cell1/Cell4 configure to same frequency, TDD Cell2 configure to another frequency.
    ...       Configure CA Relations: Cell3-Cell1, Cell3-Cell2, Cell3-cell4
    ...       TDD SCell1 is configured to the UE with 4 CSI-RS resource.
    ...       TDD Pcell3 is configured ot the UE with 1 CSI-RS resources.
    ...       aCSI is enabled in pcell
    ...       For TDD PScell3 and SCell1:
    ...         NRBTS/NRCELL/dlMimoMode = 70
    ...       For TDD SCell2 and TDD SCell4
    ...         NRBTS/NRCELL/dlMimoMode = 60
    ...      UE capabilities for the TDD SCell band:
    ...         MIMO-ParametersPerBand ::CSI-RS-IM-ReceptionForFeedback
    ...         maxConfigNumberNZP-CSI-RS-PerCC 4
    ...         maxConfigNumberPortsAcrossNZP-CSI-RS-PerCC 64
    ...         maxConfigNumberCSI-IM-PerCC 4
    ...         maxNumberSimultaneousNZP-CSI-RS-PerCC 4
    ...         totalNumberPortsSimultaneousNZP-CSI-RS-PerCC 64
    ...      supportedCSI-RS-ResourceList of MIMO-ParametersPerBand::CodebookParameters::type1::singlePanel includes the following item:
    ...        SupportedCSI-RS-Resource
    ...          maxNumberTxPortsPerResource 8
    ...          maxNumberResourcesPerBand 8
    ...          totalNumberTxPortsPerBand 64
    ...      Additionally, there is no item in the singlePanel lists with maxNumberTxPortsPerResource>8 or the item with
    ...         maxNumberTxPortsPerResource>8 has less maxNumberResourcesPerBand;
    ...      UE-NR-Capability::rf-Parameters::supportedBandListNR (BandNR)::
    ...        mimo-ParametersPerBand::csi-ReportFramework :
    ...         simultaneousCSI-ReportsPerCC 4
    ...      UE capability for the gNB selected band combination:
    ...         RF-Parameters::SupportedBandCombinationList-v1540::
    ...         BandCombination-v1540::CA-ParametersNR-v1540::
    ...         csi-RS-IM-ReceptionForFeedbackPerBandComb
    ...         maxNumberSimultaneousNZP-CSI-RS-ActBWP-AllCC 6
    ...         totalNumberPortsSimultaneousNZP-CSI-RS-ActBWP-AllCC 48
    ...      RF-Parameters::SupportedBandCombinationList-v1540::BandCombination-v1540::CA-ParametersNR-v1540
    ...         simultaneousCSI-ReportsAllCC 8
    ...    3. Test Case Steps:
    ...        a.Attach UE-81 to the TDD NR cell3 and setup non-GBR SA call
    ...          TDD cell2 and higher priority TDD cell1 addition successfully(TTT),
    ...          Scell activated successfully, Aggregate UE peak DL/UL throughput on PCell and SCell can reach
    ...          the expected value. A6 meas configed to UE, A2 meas for scell release configured
    ...              aCSI is not configured to the UE.
    ...              TDD PCell3 is currently configured to the UE with 1 CSI-RS resource.
    ...              TDD SCell1 is currently configured to the UE with 4 CSI-RS resource.
    ...              TDD SCell2 is currently configured to the UE with 1 CSI-RS resource.
    ...       b.A6 (Cell1 to Cell4) scell swap trigger successfully and traffic is OK for all serving cells
    ...              A2 for Scell release ,A6 on Cell3 are release.
    ...              After the SCell Swap, SCell4 is configured with 1 CSI-RS.
    ...              CSI-RS resources for SCell2 are unchanged.
    ...       c.send A2MR to trigger Scell2 release,the CSI-RS resources for SCell4 and pcell are unchanged.
    ...       d.A6 (Cell4 to Cell1) scell swap trigger successfully and traffic is OK for all serving cells
    ...              After the SCell Swap, SCell1 is configured with 4 CSI-RS.
    ...              CSI-RS resources for pcell is unchanged.
    ...       e.A6 (Cell1 to Cell4) scell swap trigger successfully and traffic is OK for all serving cells
    ...              After the SCell Swap, SCell4 is configured with 1 CSI-RS.
    ...              CSI-RS resources for pcell is unchanged.
    ...       f. repeat 5 times for step d~e
    ...       g. UE is released successully.
    [Tags]    QC_223964    owner-Tingjian.Mao    B038
    Update UE capa    ${SA_Capa_Support_B038}    81
    UE attach and scell add 3CC
    Trigger ScellSwap    carrierfreq=632736    phycell_id=53
    Verify Throuput on Pscell and Scell for 3CC    scell_id_1=3
    A2 scell release
    ScellSwap twice
    ScellSwap Repeat 5 times
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B038${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_4N78_2N71

UE attach and scell add 3CC
    [Arguments]    ${cell_id}=3    ${ue_id}=81    ${carrierfreq}=646272
    UE Attach To Target Cell    cell_id=${cell_id}    ue_id=${ue_id}
    Send Throuput    ue_id=${ue_id}
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell    ue_id=${ue_id}
    Trigger MR    event_type=A1    carrierfreq=${carrierfreq}    srsrp_nr=100    srsrq_nr=100    ue_id=${ue_id}
    Wait Until Keyword Succeeds    60s    10s    Verify Throuput on Pscell and Scell for 3CC    ue_id=${ue_id}

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=75 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=75 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=75 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=7    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=75 trf_id=8    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=9    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=75 trf_id=10    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=11    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=75 trf_id=12    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=13    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=75 trf_id=14    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=15    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=75 trf_id=16    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=100 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${ul}=8
    sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl}=60    ${ul}=8    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell for 3CC
    [Arguments]    ${ue_id}=81    ${pcell_dl}=60    ${scell_dl1}=60    ${scell_dl2}=60    ${ul}=8    ${scell_id_1}=1    ${scell_id_2}=2
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id_1}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl1}
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id_2}    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > ${scell_dl2}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=638496    ${nrsrp_nr}=60    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=63
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

A2 scell release
    [Arguments]    ${event_type}=A2    ${carrierfreq}=639648    ${ue_id}=81    ${scell_id}=2
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    scell=${scell_id} scell_rsrp=40
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Verify Throuput on Pscell and Scell    scell_id=3

ScellSwap twice
    Trigger ScellSwap    carrierfreq=632736    scell_id=3    phycell_id=50
    Verify Throuput on Pscell and Scell
    Trigger ScellSwap    carrierfreq=632736    phycell_id=53
    Verify Throuput on Pscell and Scell    scell_id=2

ScellSwap Repeat
    Trigger ScellSwap    carrierfreq=632736    scell_id=2    phycell_id=50
    Verify Throuput on Pscell and Scell
    Trigger ScellSwap    carrierfreq=632736    phycell_id=53
    Verify Throuput on Pscell and Scell    scell_id=2

ScellSwap Repeat 5 times
    ScellSwap Repeat
    ScellSwap Repeat
    ScellSwap Repeat
    ScellSwap Repeat
    ScellSwap Repeat

Trigger MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
