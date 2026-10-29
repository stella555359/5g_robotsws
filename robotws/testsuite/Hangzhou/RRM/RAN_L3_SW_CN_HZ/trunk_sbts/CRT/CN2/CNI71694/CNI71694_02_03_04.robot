*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-ying.yao
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CNI71694    release-SBTS22R2
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F
${BTS_STARTUP_RETRY}    5
@{PARAMS_IN_SCF}
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:actCDrx=true

...    NRCELL-1:actCaAwarePsCellSelectionFr1=true
...    NRCELL-1:msg1FrequencyStart=15
...    NRCELL-1:actK1Opt=intra-gNB
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=80
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=80ms
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:absThreshSsbRsrpConsolidation=80
...    NRCELL-1:sMeasConfigSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
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
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
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
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:actCDrx=true

...    NRCELL-2:msg1FrequencyStart=15
...    NRCELL-2:actK1Opt=intra-gNB    #23R1 dedicated
...    NRCELL-2:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-2:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=80ms
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2:filterCoeffSsbRsrp=fc4
...    NRCELL-2:absThreshSsbRsrpConsolidation=80
...    NRCELL-2:sMeasConfigSsbRsrp=20
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a1MeashoEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-11:a2MeashoEnabled=rsrp
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:actCDrx=true

...    NRCELL-11:actCaAwarePsCellSelectionFr1=true
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-11:actK1Opt=intra-gNB    #23R1 dedicated
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=80
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=80ms
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11:filterCoeffSsbRsrp=fc4
...    NRCELL-11:absThreshSsbRsrpConsolidation=80
...    NRCELL-11:sMeasConfigSsbRsrp=20
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
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
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=${EMPTY}
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=${EMPTY}
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=${EMPTY}
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
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:actCDrx=true

...    NRCELL-12:actCaAwarePsCellSelectionFr1=true
...    NRCELL-12:msg1FrequencyStart=11
...    NRCELL-12:actK1Opt=intra-gNB    #23R1 dedicated
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=80
...    NRCELL-12:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=80ms
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-12:filterCoeffSsbRsrp=fc4
...    NRCELL-12:absThreshSsbRsrpConsolidation=80
...    NRCELL-12:sMeasConfigSsbRsrp=20
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-3:lcrId=1
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13:a1MeasSCellAddEnabled=rsrp
...    NRCELL-13:a2MeasSCellRelEnabled=rsrp
...    NRCELL-13:a3MeasEnabled=rsrp
...    NRCELL-13:actCDrx=true

...    NRCELL-13:msg1FrequencyStart=13
...    NRCELL-13:actK1Opt=intra-gNB    #23R1 dedicated
...    NRCELL-13:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=80ms
...    NRCELL-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13:filterCoeffSsbRsrp=fc4
...    NRCELL-13:absThreshSsbRsrpConsolidation=80
...    NRCELL-13:sMeasConfigSsbRsrp=20
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    NRCELL-14:a1MeasSCellAddEnabled=rsrp
...    NRCELL-14:a2MeasSCellRelEnabled=rsrp
...    NRCELL-14:a3MeasEnabled=rsrp
...    NRCELL-14:actCDrx=true

...    NRCELL-14:msg1FrequencyStart=14
...    NRCELL-14:actK1Opt=intra-gNB    #23R1 dedicated
...    NRCELL-14:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=80ms
...    NRCELL-14:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-14:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-14:filterCoeffSsbRsrp=fc4
...    NRCELL-14:absThreshSsbRsrpConsolidation=80
...    NRCELL-14:sMeasConfigSsbRsrp=20
...    NRCELL-14:measGapSelectionSA=favourUeThroughput
...    @{bandwidth_configuration}
...    @{GSCN_param}
@{GSCN_param}
...    NRCELL-1:gscnOrSsPbchArfcn=6486
...    NRCELL-2:gscnOrSsPbchArfcn=7845
...    NRCELL-11:gscnOrSsPbchArfcn=5300
...    NRCELL-12:gscnOrSsPbchArfcn=1584
...    NRCELL-13:gscnOrSsPbchArfcn=5350
...    NRCELL-14:gscnOrSsPbchArfcn=1575
@{bandwidth_configuration}
...    NRCELL-1:chBw=60MHz
...    NRCELL-2:chBw=50MHz
...    NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=126120
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=135280
${CA_support_list}    ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa
@{Deltacommission01}
...    NRCELL-1:actCaAwarePsCellSelectionFr1=true
...    NRCELL-11:actCaAwarePsCellSelectionFr1=true
...    NRCELL-12:actCaAwarePsCellSelectionFr1=true
...    NRCELL-2:actCaAwarePsCellSelectionFr1=false
...    NRCELL-13:actCaAwarePsCellSelectionFr1=false
...    NRCELL-14:actCaAwarePsCellSelectionFr1=false
@{Deltacommission02}
...    NRCELL-1:actCaAwarePsCellSelectionFr1=false
@{Deltacommission03}
...    NRCELL-11:actCaAwarePsCellSelectionFr1=true
...    NRCELL-12:actCaAwarePsCellSelectionFr1=true
@{Deltacommission04}
...    NRCELL-11:actCaAwarePsCellSelectionFr1=false
@{Deltacommission05}
...    NRCELL-11:actCaAwarePsCellSelectionFr1=true

*** Test Cases ***
CNI_71694_2_4F2T_PSCell_selection_enabling_of_cells
    [Documentation]
    ...    This case can use the same commission as the one of the previous case.
    [Tags]    QC_151755
    OnlineParamChange    ${Deltacommission01}
    Perform NSA Attach Tdd C1 as PCell And Select Tdd C2 as SCell    ue_id=91
    Send And Verify Throuput    ue_id=91    send_dl=70    send_ul=10    sleep_time=20s
    Perform UE Detach    ue_id=91
    OnlineParamChange    ${Deltacommission02}
    Perform NSA Attach Fdd C11 as PCell And Select Tdd C2 as SCell    ue_id=91
    Send And Verify Throuput    ue_id=91    send_dl=70    send_ul=10    sleep_time=20s
    Perform UE Detach    ue_id=91
    Check RRC Log    ${CURDIR}${/}a2a_CNI71694_02${/}a2a.ini
    Check Wireshark Log    ${CURDIR}${/}a2a_CNI71694_02${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CNI_71694_3_4F2T_PSCell_selection_enabling_of_cells_FDD
    [Documentation]
    ...    This case can use the same commission as the one of the previous case.
    [Tags]    QC_151754
    OnlineParamChange    ${Deltacommission03}
    Perform NSA Attach Fdd C11 as PCell And Select Tdd C2 as SCell    ue_id=91
    Send And Verify Throuput    ue_id=91    send_dl=70    send_ul=10    sleep_time=20s
    Perform UE Detach    ue_id=91
    OnlineParamChange    ${Deltacommission04}
    Perform NSA Attach Fdd C12 as PCell And Select Tdd C1 as SCell    ue_id=91
    Send And Verify Throuput    ue_id=91    send_dl=70    send_ul=10    sleep_time=20s
    Perform UE Detach    ue_id=91
    Check RRC Log    ${CURDIR}${/}a2a_CNI71694_03${/}a2a.ini
    Check Wireshark Log    ${CURDIR}${/}a2a_CNI71694_03${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CNI_71694_4_4F2T_PSCell_selection_enabling_of_cells_UE_Capability_impact
    [Documentation]
    ...    This case can use the same commission as the one of the previous case.
    [Tags]    QC_217637
    OnlineParamChange    ${Deltacommission01}
    Perform NSA Attach Fdd C12 as PCell And Select Tdd C1 as SCell    ue_id=95
    Send And Verify Throuput    ue_id=95    send_dl=70    send_ul=10    sleep_time=20s
    Perform UE Detach    ue_id=95
    OnlineParamChange    ${Deltacommission04}
    Perform NSA Attach Fdd C12 as PCell And Select Tdd C1 as SCell    ue_id=95
    Send And Verify Throuput    ue_id=95    send_dl=70    send_ul=10    sleep_time=20s
    Perform UE Detach    ue_id=95
    OnlineParamChange    ${Deltacommission05}
    Perform NSA Attach Tdd C2 as PCell And Select Tdd C1 as SCell    ue_id=92
    Send And Verify Throuput    ue_id=92    send_dl=70    send_ul=10    sleep_time=20s
    Perform UE Detach    ue_id=92
    Check RRC Log    ${CURDIR}${/}a2a_CNI71694_04${/}a2a.ini
    Check Wireshark Log    ${CURDIR}${/}a2a_CNI71694_04${/}a2a.ini    wait_string=UEContextReleaseComplete::6

*** Keywords ***
Modify Cfg
  Update Cfg
   ...    set_cell id=14 gnb=2 pci=21:0 tac=0 nrci=0x0E tdd_cell=off proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=135280:126120 gscn=1575

  ${UE_CAP_95}    catenate    SEPARATOR=
    ...    ue_param id=95 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=A11FF81BC4C
    ...    0C03850001C46000000162205E160601C4D000002162205E160601C41000004160204024046805000E020C04D130009A071274489B1CF87
    ...    0A744D8E7C3853A24C73E018021000040202004010080600C1000080404008020800040202018030
  Update Cfg    ${UE_CAP_95}

  ${UE_CAP_92}    catenate    SEPARATOR=
    ...    ue_param id=92 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=A11FF823C2C
    ...    0C038500000002C440BC2C0C0389A0000002C440BC2C0C038820000042C040BC2C0C0388C0000082C040804808D00A001C041809A260017
    ...    41214E89B1CF870A744D8E7C3853A24C73E853A24C73E03004100008040400802080004020201803040002010100C018
  Update Cfg    ${UE_CAP_92}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Perform NSA Attach Tdd C1 as PCell And Select Tdd C2 as SCell
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command
     ...    enb_ue_dc_start ue=${ue_id} target_gnb=2 target_cells=1,2,11,12,13,14 bearer=2 type=split_scg
     ...    pass_regexp=Successfully reconfigured dual connectivity    timeout=60

    ${c1_arfcnSsbPbch}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/NRCELL-1:arfcnSsbPbch
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency
     ...    ue_id=${ue_id}    carrierfreq=${c1_arfcnSsbPbch}    event_type=A1
    Execute Egate Command
     ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} index=0 nrs_result=30:30:30 event=A1 srsrp_nr=120
     ...    pass_regexp=SgNB Modification Confirm    timeout=60

Perform UE Detach
    [Arguments]    ${ue_id}=91
    Log To Console    ---Detach UE ${ue_id}---
    Execute Egate Command    ue_detach id=${ue_id}    detached

Perform NSA Attach Fdd C12 as PCell And Select Tdd C1 as SCell
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command
     ...    enb_ue_dc_start ue=${ue_id} target_gnb=2 target_cells=1,2,11,12,13,14 bearer=2 type=split_scg
     ...    pass_regexp=Successfully reconfigured dual connectivity    timeout=60

    ${c12_arfcnSsbPbch}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/NRCELL-12:arfcnSsbPbch
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency
     ...    ue_id=${ue_id}    carrierfreq=${c12_arfcnSsbPbch}    event_type=A1
    Execute Egate Command
     ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} index=0 nrs_result=30:30:30 event=A1 srsrp_nr=120
     ...    pass_regexp=SgNB Modification Confirm    timeout=60

Perform NSA Attach Fdd C11 as PCell And Select Tdd C2 as SCell
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command
     ...    enb_ue_dc_start ue=${ue_id} target_gnb=2 target_cells=1,2,11,12,13,14 bearer=2 type=split_scg
     ...    pass_regexp=Successfully reconfigured dual connectivity    timeout=60
    ${c11_arfcnSsbPbch}    Get Scf Parameter Value    MRBTS-1/NRBTS-1/NRCELL-11:arfcnSsbPbch
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${c11_arfcnSsbPbch}    event_type=A1
    Execute Egate Command
     ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} index=0 nrs_result=30:30:30 event=A1 srsrp_nr=120
     ...    pass_regexp=SgNB Modification Confirm    timeout=60

Perform NSA Attach Tdd C2 as PCell And Select Tdd C1 as SCell
    [Arguments]    ${ue_id}=92
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command
     ...    enb_ue_dc_start ue=${ue_id} target_gnb=2 target_cells=1,2,11,12,13,14 bearer=2 type=split_scg
     ...    pass_regexp=Successfully reconfigured dual connectivity    timeout=60
    Execute Egate Command
     ...    ue_measurement_send_nr id=${ue_id} meas_id=1 index=0 nrs_result=30:30:30 event=A1 srsrp_nr=120
     ...    pass_regexp=meas_id=1 not found    timeout=60

Send And Verify Throuput
    [Arguments]    ${ue_id}=91    ${send_dl}=70    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=${send_dl}    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=${send_ul}    UE ${ue_id}: UDP UL
    Verify Throuput    ue_id=${ue_id}    send_dl=${send_dl}    send_ul=${send_ul}

Verify Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=20s    ${send_dl}=70    ${send_ul}=10
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${send_dl}*0.6
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${send_ul}*0.6
