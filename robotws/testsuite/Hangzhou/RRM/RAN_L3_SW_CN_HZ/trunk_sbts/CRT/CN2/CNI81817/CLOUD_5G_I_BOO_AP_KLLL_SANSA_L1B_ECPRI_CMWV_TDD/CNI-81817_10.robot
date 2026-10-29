*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CNI-81817    release-SBTS22R4
...    STATE_CONFIGURED
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{basic_modification}
...    @{case_01_modification}

@{basic_modification}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-5:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-3
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-6:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-7:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-4
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-8:resourceDN=${EMPTY}


...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-5:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-6:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-7:resourceDN=${EMPTY}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:antlDN=MRBTS-1/EQM-1/APEQM-1/RMOD-5/ANTL-2
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-8:resourceDN=${EMPTY}

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-11:nrCellType=4DL4UL
...    NRCELL-11:nrarfcn=633372

...    NRCELL-12/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-12:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-12:nrCellType=4DL4UL

...    NRCELL-3:chBw=60MHz
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:nrCellType=4DL2UL
...    NRCELL-4:chBw=40MHz
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:gscnOrSsPbchArfcn=6573
...    NRCELL-4:nrCellType=4DL2UL
...    NRCELL-4:nrarfcn=526020
...    NRCELL-11/NRREL-10:lcrId=3
...    NRCELL-3/NRREL-10:lcrId=11
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-10:sCellOperationalMode=dlOnly
...    BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=42
@{case_01_modification}
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS:actAllowedBcListMrdcPrioBcSel=true
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:handoverAllowedSA=allowed
#...    NRCELL-11/NRREL-10:lcrId=4
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-10:gNbId=1
...    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:handoverAllowedSA=allowed
#...    NRCELL-3/NRREL-10:lcrId=4
...    NRCELL-3/NRREL-10:nrDcAllowed=false
...    NRCELL-3/NRREL-10:removeNotAllowed=false
...    NRCELL-3/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3

@{case_10_modification}
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=40
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=50
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-3/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-3:a1MeashoEnabled=rsrp
...    NRCELL-3:a2MeashoEnabled=rsrp
...    NRCELL-3:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-3:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL-3:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms128
...    NRCELL-3:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-3:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=56
...    NRCELL-3:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms128
...    NRCELL-3/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:a4MeasEnDcSteeringEnabled=none
...    NRCELL-3/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-3/NRHOIF-1:a4MeasNrDcEnabled=none
...    NRCELL-3/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-3/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=125050
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-3/NRHOIF-1:thresholdPCellSwitchTargetRsrq=60
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

${UE_Capa_For_ue_92}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406
...    D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10
...    480CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A41
...    2030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240
...    656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E007BC3C4D000E208000010B010
...    2A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001
...    C4100000A160561E14000713400003058158B89A001C41000E140000040B02B1713400388C001C46000004160562E140007104
...    00388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A000388C001C46000004160562E
...    2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D02EC1F0A244D8E7C3851226C73E1C2891363
...    9F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E0
...    44810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E06012803
...    80030120020301F048010000000080000100400001002000014010000040080000300400002002000014010008020080200001
...    80100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6F2A2F266B036B032
...    F286B296B266B016B036B012B022B07681A0800004B29282000032CA4A0800014B29282000072CA4A0800024B292820000B2CA
...    4A0800034B292820000F2CA4A0800044B29282000132CA4A0800054B29282000172CA4A0800064B29282000062CA4A066955DD2
...    ABBA4D774A2EA82DD703B6A835D529BAA4D75406EA814D526BAA0F742405E02540A05028140A05028140A05028140A05028140A
...    05000608080600C02004008404008020100C018402004008080600C02018030404030060100C018402004008080600C02004008
...    804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951
...    697A0A0C1680

${UE_Capa_For_ue_92_eutra}    SEPARATOR=
...    A11FF83BC6C04019699B4100E140000010B1102F1B010068201C28000E140000020B1102F13010068201C28082006162205E46
...    0200CB4CDA08070A00038500000102C040BC8C04019699B4100E140006118000A160205E460200CB4CDA08060A00E230000060
...    B0102F1B0100682018280388C00001C2C040804808D00A001C041809A26802E41E24E8913639F0E24E8913639F0E24E8913639
...    F0E24E8913639F0E24E8912639F469D1224498E7D127448931CF80681C6318C6318300E2000080404008020100200860001008
...    0004020001008080100430000804000201010040080401002100004020001008080200440600804010080201004020C0100802
...    010040200804180201004020080401008380200500200A008014020040700400A0040140080280300640200804010081004020
...    08040802010040206010024010020300C01A01C0310080201004020401008020102008040100818020050040080C0380680600
...    C3020080401008100402008040C010028040080601C034030060

#${RECREATE_WIRESHARK_FLAG}  ${False}
*** Test Cases ***

CNI-81817_ID_10_NSA_Intra-gNB_PSCell_change_T_F_to_F_T
    [Documentation]
    ...    1. This user scenario porpuse is to enhance band combination selection algorithm used for FR1 cell attached UEs.
    ...    2. Configuration
    ...    configuration on BTS
    ...    a.FR1 TDD cells are configured with frequency NRF1 and NRF2 in band n41 with 60MHz and 40MHz bandwidths respectively,
    ...    4L DL MIMO, and they are non-contiguous.
    ...    b.NRF1 cell has NRCELL-cellDepType set to NSA or both
    ...    c. NRF3 is configured as SCell of NRF1 cell via NRREL object with scellAdditionMethod set to "1"(covBasedA1)
    ...    and NRBTS/NRCELL/a1MeasSCellAddEnabled is set to '1' (rsrp)
    ...    d.FR1 FDD cell is configured with frequency NRF3 in band n71 with 20MHz 4L DL MIMO
    ...    e.NRF3 cell has NRCELL-cellDepType set to NSA or both
    ...    f.NRF2 Is configured as SCell of NRF3 cell via NRREL object with scellAdditionMethod set to "0"(blind)
    ...    g.CA is enabled
    ...    3. Test Case Steps:
    ...    a.UE attach and set specific allowed_bc_list_mrdc.
    ...    b.UE detach.
    [Tags]    QC_199654    owner-niya.ma
    OnlineParamChange    ${case_10_modification}
    Update UE capa    ue_id=92    SA_Capa_perUE_Full=${UE_Capa_For_ue_92}    eutra_nr_capa=${UE_Capa_For_ue_92_eutra}
    UE Attach And Set Allowed Band Combination List    ue_id=92    target_gnb=2    target_cells=3    bearer_id=2
    Trigger A1 Event    ue_id=92    carrierfreq=508110    phycell_id=60    rsrp=120
    Trigger A2_ho Event    ue_id=92    carrierfreq=508110    phycell_id=60    rsrp=30
    Trigger A3 Event    ue_id=92    carrierfreq=125050    srsrp=11    phycell_id=60    nrsrp=78
    UE Detach    ue_id=92
    Check Wireshark Log    ${CURDIR}${/}a2a_CNI81817_10${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none    ${eutra_nr_capa}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} ue_eutra_nr_capabilities=${eutra_nr_capa}
    Execute Egate Command    ${cmd}

UE Attach And Set Allowed Band Combination List
    [Arguments]    ${ue_id}=92    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=1:1|4:1|4:4|4:3|5:2|6:1|6:2|4:2|5:1|2:1|3:1|7:1|7:2
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity
    Send And Verify Nsa Throuput

Verify Throuput
    [Arguments]    ${ue_id}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throughput}/1000>9
    Should Be True    ${ul_throughput}/1000>9

Send And Verify Nsa Throuput
    [Arguments]    ${ue_id}=92    ${sleep_time}=10s
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=10    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UE ${ue_id}: UDP UL
    Verify Throuput    ${ue_id}    ${sleep_time}

UE Detach
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

Trigger A1 Event
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycell_id}    ${rsrp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrp}
    Execute Egate Command    ${cmd}
    Send And Verify Nsa Throuput

Trigger A2 Event
    [Arguments]    ${ue_id}    ${carrierfreq}    ${scell}    ${scell_rsrp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell} scell_rsrp=${scell_rsrp}
    Execute Egate Command    ${cmd}
    Send And Verify Nsa Throuput

Trigger A2_ho Event
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycell_id}    ${rsrp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${rsrp}
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    Execute Egate Command    ${cmd}
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    Send And Verify Nsa Throuput

Trigger A3 Event
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycell_id}    ${srsrp}    ${nrsrp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=${srsrp} phycell_id=${phycell_id} nrsrp_nr=${nrsrp}
    Execute Egate Command    ${cmd}    Successfully reconfigured dual connectivity
    Send And Verify Nsa Throuput

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
