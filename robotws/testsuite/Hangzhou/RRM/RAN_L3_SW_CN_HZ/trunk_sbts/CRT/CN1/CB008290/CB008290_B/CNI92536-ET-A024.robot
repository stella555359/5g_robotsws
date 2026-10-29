*** Settings ***
Documentation
...    author: Yan Susana
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-CN1_SG14    owner-susana.yan
...    CLOUD_5G_I_BOO_AP_LOO    CNI-92536    release-5G23R3
...    STATE_CONFIGURED    RAN_5G    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_IPHY_XML}
...    GeneralSettings:l3Timeout=30

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRCELL:actAperCsi=true
...    @{NRREL}
...    @{8290_enable}
...    @{PARAMS_FOR_5GC000772}
...    @{PARAMS_FOR_5GC002060}
...    @{PARAMS_FOR_5GC000884}
...    @{PARAMS_FOR_5GC001118_CB007797}
...    @{PARAMS_FOR_5GC001729}
...    @{bw}
...    @{CNI-92536}

@{NRREL}
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:nrRelId=1
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellPrio=2
...    delete:NRCELL-2/NRREL-1:sCellOperationalMode
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:lcrId=4
...    NRCELL-2/NRREL-2:nrRelId=2
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellPrio=1
...    delete:NRCELL-2/NRREL-2:sCellOperationalMode
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly

@{8290_enable}
...    NRDU-1:actNonBfAndBfCa=true
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actDl256Qam=false
...    NRCELL:actK1Opt=intra-gNB
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
...    NRCELL-4:weightForSCellSelection=50
...    NRCELL-3:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-1:actProactUlSchedulingEnh=disabled
...    NRCELL-2:actProactUlSchedulingEnh=disabled
...    NRCELL-3:actProactUlSchedulingEnh=disabled
...    NRCELL-4:actProactUlSchedulingEnh=disabled

@{bw}
...    MRBTS-1/NRBTS-1/NRCELL-1:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7912
...    MRBTS-1/NRBTS-1/NRCELL-3:chBw=40MHz
...    MRBTS-1/NRBTS-1/NRCELL-3:gscnOrSsPbchArfcn=7981
...    MRBTS-1/NRBTS-1/NRCELL-4:chBw=40MHz
...    NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

@{drx}
...    NRCELL:actCDrx=true
...    MRBTS-1/NRBTS-1/NRCELL-1:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4
...    MRBTS-1/NRBTS-1/NRCELL-2:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-5
...    MRBTS-1/NRBTS-1/NRCELL-4:nonGbrNrDrxDN=MRBTS-1/NRBTS-1/NRDRX-6
...    NRCELL:actCDrx=true
...    NRDRX-4:drxInactivityTimer=80ms
...    NRDRX-4:drxLongCycle=20ms
...    NRDRX-4:drxOnDurationTimer=4ms
...    NRDRX-4:drxRetransTimerDl=16slot
...    NRDRX-4:drxRetransTimerUl=16slot

...    NRDRX-5:drxInactivityTimer=80ms
...    NRDRX-5:drxLongCycle=20ms
...    NRDRX-5:drxOnDurationTimer=2ms
...    NRDRX-5:drxRetransTimerDl=16slot
...    NRDRX-5:drxRetransTimerUl=16slot

...    NRDRX-6:drxInactivityTimer=80ms
...    NRDRX-6:drxLongCycle=20ms
...    NRDRX-6:drxOnDurationTimer=6ms
...    NRDRX-6:drxRetransTimerDl=16slot
...    NRDRX-6:drxRetransTimerUl=16slot

@{CNI-92536}
...    @{drx}
...    NRCELL-1:actPciBasedCsiImRandomization=true
...    NRCELL-2:actPciBasedCsiImRandomization=true
...    NRCELL-4:actPciBasedCsiImRandomization=true
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-4:dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-3:nrCellType=4DL4UL
...    NRCELL-4:nrCellType=4DL4UL
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-4:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-2/NRREL-1:sCellPrio=2
...    NRCELL-2/NRREL-2:sCellPrio=1


*** Test Cases ***
CNI-92536-ET-A024_Verify_IntraGnb_CA_Scell_CSIRS_Allocate_Successfully_With_actPciBasedCsiImRandomization_as_true_DRX_On_When_Perform_Scell_Swap
    [Documentation]
    ...    1. This user scenario describes the successful scell's CSIRS allocation when actPciBasedCsiImTandomization as true
    ...    while perform A6 scell swap for TT CA.
    ...    2. Configuration
    ...         a. cell1, cell2 and cell4 is in same band, cell1 and cell4 with same ssbfrequency F1, cell2 is with another ssbfrequency F2.
    ...         b. NRREL configured as below for cell2 as Pcell
    ...           TDD PCell(cell2) (F2) -- NRCELL/NRREL configuration for CA
    ...           SCell Frequency    SCell swap candidates (NRREL.sCellAdditionMethod)    Priority (NRREL.sCellPrio)
    ...              F1-TDD                     SCell1                                      2
    ...                                         SCell4                                      1
    ...    3. Test Case Steps:
    ...         a. Online change CNI92536 needed parameters.
    ...            actPciBasedCsiImRandomization=true
    ...            actCdrx=true, dlmimode of scells=4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...         b. UE registers and PDU session is setup successfully on cell 2.
    ...         c. Start traffic and check traffic
    ...         d. UE sends A1 measurement for SCell4 Addition, check traffic.
    ...         e. UE sends A6 measurement for SCell1 swap and check traffic.
    ...         f. UE sends A6 measurement for SCell4 swap and check traffic.
    ...         g. release scell1.
    ...         h. UE deregister
    ...     4. Expect result:
    ...          a. Parameters online change successfully.
    ...          b. UE registers and PDU session is setup successfully, drx setup sucessfully
    ...             note: drxonduration timer is 2ms and offset is 0.5ms in this case, thus slot 1-4 is on duration.
    ...          c. traffic is ok
    ...          d. UE is successfully configured with TDD PCell and TDD SCell4 as SCell,
    ...             TDD SCell4 is configured with UE specific CSI-RS (p4) on drx duration (slot 2).
    ...          e. scell swap to scell1 successfully.
    ...             TDD SCell1 is configured with UE specific CSI-RS (p4) on drx duration(slot 2).
    ...          f. scell swap to scell4 successfully.
    ...             TDD SCell4 is configured with UE specific CSI-RS (p4) on drx duration(slot 2).
    ...          g. scell1 releases successfully
    ...          h. UE deregister is successfully.
    [Tags]    QC_302890    owner-susana.yan    CNI92536A024
    UE attach and scell add    phycell_id=53    scell_dl=370
    Scell Swap 10 times    scell1_phyid=53    scell2_phyid=50    scell_dl_1=370    scell_dl_2=370
    A2 event trigger scell release
    Release ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_CNI92536A024${/}a2a.ini    wait_string=UEContextRelease::12


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_4N78_2N71

UE attach and scell add
    [Arguments]    ${phycell_id}=50    ${scell_dl}=200
    UE Attach To Target Cell    cell_id=2    ue_id=81
    Send Throughput    ue_id=81
    Verify Throughput on Pscell    ue_id=81
    Trigger MR    event_type=A1    carrierfreq=639648    srsrp_nr=100    srsrq_nr=50    ue_id=81    phycell_id=${phycell_id}
    Verify Throughput on Pscell and Scell    ue_id=81    scell_dl=${scell_dl}

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}=81    ${pdu_id}=1    ${gw_id}=1    ${nwslice}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Send Throughput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL

Verify Throughput on Pscell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=370    ${ul}=9    ${pdu_id}=1
    sleep    15s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throughput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=370    ${scell_dl}=370    ${ul}=9    ${scell_id}=1    ${pdu_id}=1
    sleep    15s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Trigger MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=639648    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=82    ${phycell_id}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    @{expectedScellAddStr}    create list    rrcReconfigurationComplete    physCellId ${phycell_id}    activated successfully at airphone
    Execute Egate Command    ${cmd}    pass_regexp=${expectedScellAddStr}

Trigger ScellSwap
    [Arguments]    ${event_type}=A6    ${carrierfreq}=632736    ${nrsrp_nr}=50    ${nrsrq_nr}=50    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=50
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Scell Swap 10 times
    [Arguments]    ${scell1_phyid}=50    ${scell2_phyid}=53    ${scell_dl_1}=200    ${scell_dl_2}=200
    FOR    ${index}    IN RANGE    0    5
        Trigger ScellSwap    scell_id=1    phycell_id=${scell2_phyid}
        Verify Throughput on Pscell and Scell    scell_dl=${scell_dl_1}    scell_id=2
        Trigger ScellSwap    scell_id=2    phycell_id=${scell1_phyid}
        Verify Throughput on Pscell and Scell    scell_dl=${scell_dl_2}    scell_id=1
    END

A2 event trigger scell release
    [Arguments]    ${ue_id}=81    ${carrierfreq}=632736    ${scell_id}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=20
    ...    pass_regexp=(rrcReconfigurationComplete|sCellToReleaseList)    timeout=20s
