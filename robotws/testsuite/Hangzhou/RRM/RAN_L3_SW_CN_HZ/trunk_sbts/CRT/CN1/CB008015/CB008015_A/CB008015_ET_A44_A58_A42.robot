*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BLLL_AP_LOO
...    team-DevHZ5_SG2    owner-baijie.zhu    release-5G22R2    CB008015    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CB008015}
...    @{5GC001390}
...    @{CB006138}

@{5GC001390}
...    NRBTS/NRDU-1:actInterNumerologyCa=true

@{CB006138}
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}

${CA_support_list}
...    ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa

@{CB008015}
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actK1Opt=intra-gNB

...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:actCDrx=true
...    NRCELL-11/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-3:nrDcAllowed=false
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:nrDcAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:nrDcAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
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
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:nrDcAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518910
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:nrDcAllowed=false
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:nrDcAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-2:nrDcAllowed=false
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-3:nrDcAllowed=false
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:nrDcAllowed=false
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-12:actAperCsi=true
...    NRBTS-1/NRCELL:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-13:actAperCsi=true
...    NRBTS-1/NRCELL-11:actAperCsi=true
...    NRCELL-1:msg1FrequencyStart=19
...    NRCELL-2:msg1FrequencyStart=19
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=12
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=13

@{PARAMS_TO_MODIFY_8015_A44}
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=35
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=121
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=24
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{PARAMS_TO_MODIFY_8015_A44_Recover}
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms

@{PARAMS_TO_MODIFY_8015_A58}
...    NRCELL-12:weightForSCellSelection=30
...    NRCELL-1:weightForSCellSelection=40
...    NRCELL-2:weightForSCellSelection=90
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=20

@{DELTA_PARAS_A58_C12_35_121}
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=35
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=121
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

@{DELTA_PARAS_A58_C12_35_111}
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=35
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

@{PARAMS_TO_MODIFY_8015_A42}
...    NRCELL-2:maxNumOfSCellAlloc=1
...    NRCELL-2:actAperCsi=true
...    NRCELL-1:maxNumOfSCellAlloc=1
...    NRCELL-12:weightForSCellSelection=30
...    NRCELL-2:weightForSCellSelection=90
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11:weightForSCellSelection=20

&{CELLS_CARRIER_FREQ}
...    1=518910
...    2=633216
...    11=424090
...    12=126750
...    13=427970

*** Test Cases ***
CB008015-ET-A44 A_B6_A1 measurement of P_SCell based SCell change based on RSRP when actAperCsi True in pcell and change in scell change
    [Documentation]
    ...    1. The purpose of this test case is to verify A1 measurement of P(S)Cell based SCell change for SA call - RSRP
    ...       UE 81: support n66+n71, n71+n41, n66+n41, n66+n78, n41+n78, n71+n78, n66+n66+n71 CA (FullCap)
    ...       Final selection order in cell 1 > cell 2 > (cell 12 + cell 13) > cell 13 > cell 12
    ...    2. Test Case Steps:
    ...         Step 1. SA UE-81 attach to cell 12
    ...                 A1 is triggered, a1ThresholdSCellAddSsbRsrpFDD < rsrp value < a1ThresholdSCellAddSsbRsrpTDD
    ...         Expected Result: SA UE add CELL 11 and CELL 13 for FDD-FDD 3CC CA.
    ...         Step 2. A1 is triggered, rsrp value > a1ThresholdSCellAddSsbRsrpTDD
    ...         Expected Result: SA UE-1 will trigger SCell change,
    ...                          cell 11 and cell 13 are removed and cell 2 is added as SCell for FDD-FR1 TDD 2CC CA,
    ...         Step 3. Trigger A2 Measurementreport, Scell release.
    [Tags]    QC_128172    CB008015-A44
    Delta Commission Parameters    ${PARAMS_TO_MODIFY_8015_A44}
    UE Attach and Start L3 Call
    Scell_11_13 Added Based On A1 Rsrp Higher than FDD But Lower Than TDD
    Scell_1 Added Based On A1 Rsrp Higher Than TDD Threshold
    Delta Commission Parameters    ${PARAMS_TO_MODIFY_8015_A44_Recover}

CB008015-ET-A58_A_B10_Online modification of a1ThresholdSCellAddSsbRsrpTDD
    [Documentation]
    ...    1. The purpose of this test case is to verify Online modification of parameter
    ...       UE 81: support n66+n71, n71+n41, n66+n41, n66+n78, n41+n78, n71+n78, n66+n66+n71 CA (FullCap)
    ...       Final selection order in (cell 11+ cell 13) > cell 1 > cell 2 = cell 13 >cell 11
    ...    2. Test Case Steps:
    ...         Step 1. SA UE-81 attach to cell 12 , VONR call setup successfully
    ...                 A1 is triggered, a1ThresholdSCellAddSsbRsrpFDD < rsrp value < a1ThresholdSCellAddSsbRsrpTDD
    ...         Expected Result: SA UE add CELL 11 and CELL 13 for FDD-FDD 3CC CA.
    ...         Step 2. Online modify a1ThresholdSCellAddSsbRsrpTDD to a higher value(121).
    ...         Step 3. A1 is triggered, rsrp value > a1ThresholdSCellAddSsbRsrpTDD based on the old configuration for SA UE-81.
    ...         Expected Result: No SCell change is triggered.
    ...         Step 4. Online modify a1ThresholdSCellAddSsbRsrpTDD to a lower value(111).
    ...         Step 5. A1 is triggered, rsrp value > a1ThresholdSCellAddSsbRsrpTDD based on the old configuration for SA UE-81.
    ...         Expected Result: Scell change triggered to cell 2.
    ...         Step 5. Trigger A2 Measurementreport, Scell release.
    [Tags]    QC_128179    CB008015-A58
    Delta Commission Parameters    ${PARAMS_TO_MODIFY_8015_A58}
    UE Attach and Start L3 Call
    Scell_11_13 Added Based On A1 Rsrp Higher than FDD But Lower Than TDD
    No SCell Change By Trigger A1 After Online Modify A1 RsrpTDD To Higher Value
    Scell_2 Changed By Trigger A1 After Online Modify A1 RsrpTDD To Lower Value

CB008015-ET-A42_A_B6_A1 measurement of P_SCell based SCell change based on RSRP and different load when actAperCsi true no change to cell change
    [Documentation]
    ...    1. The purpose of this test case is to check SCell selection based on weighted SCell bandwidth and cell load for SA call.
    ...       Cell1 N41
    ...       Cell2 N78
    ...       Cell11 N66
    ...       Cell12 N71
    ...       Cell13 N66
    ...       UE 81: support n66+n71, n71+n41, n66+n41, n66+n78, n41+n78, n71+n78, n66+n66+n71 CA
    ...       UE 83: support n71+n41;n66+n41
    ...       UE 84: support n71+n78;n66+n78
    ...       Final weight order in cell1 > cell2 > (cell11 + cell13) > cell13 > cell11
    ...       the NRCELL. a1MeasSCellAddEnabled is set as rsrp
    ...       maxNumOfSCellAlloc on cell1,cell2 is 1
    ...    2. Test Case Steps:
    ...         a. Pre-requested UE83 and UE84 are attached in cell 11. And blind SCell addition to cell1 is triggered.
    ...            Those two UEs make cell 1 and cell 2 cannot be added as SCell for other UEs.
    ...         b. SA UE-81 attached in cell 12, start data transfer
    ...         c. A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD but lower than
    ...            a1ThresholdSCellAddSsbRsrpTDD for SA UE-1
    ...         d. A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE-1
    ...         e. Release UE83, make a new call again with PDU session for data transferring.
    ...         f. A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE-1
    ...         g. SCell change is triggered and Cell1 is selected as new Scell
    ...         h. A2 scell Release trigger
    ...         i. release the call for SA UE-81
    ...    3. Expected Results:
    ...         Step c: Cell 11+Cell13 is added as SCell.
    ...         Step d: no SCell change.gNB
    ...         Step f: SCell change successfully.
    [Tags]    QC_128171    CB008015-A42
    Delta Commission Parameters    ${PARAMS_TO_MODIFY_8015_A42}
    SA UE 83 Attach At FDD Cell-11 And TDD Scell 1 Blind Addition
    SA UE 84 Attach At FDD Cell-11 And TDD Scell 2 Blind Addition
    UE Attach and Start L3 Call
    Scell_11_13 Added Based On A1 Rsrp Higher than FDD But Lower Than TDD
    No SCell Change Based On A1 Rsrp Higher Than TDD Threshold
    SA UE 83 Release And Scell_1 Added Based On A1 Rsrp Higher Than TDD Threshold

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    ${UE81}    catenate
    ...    set_ue simulated id=81 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645481 enb=2 cell=12 mode=nr
    ${UE83}    catenate
    ...    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645483 enb=2 cell=11 mode=nr
    ${UE84}    catenate
    ...    set_ue simulated id=84 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645485 enb=2 cell=11 mode=nr
    Update Cfg    ${UE81}
    Update Cfg    ${UE83}
    Update Cfg    ${UE84}
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full}
    Update Cfg    ue_param id=83 ue_nr_capabilities=${Capa_FT2CC}
    Update Cfg    ue_param id=84 ue_nr_capabilities=${Capa_FT2CC1}

Scell_1 Added Based On A1 Rsrp Higher Than TDD Threshold
    [Arguments]    ${rrc_log_tag}=scell_1
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition By A1 Event    scell_num=3
    Check Scell Number    expected_scell_num=1
    Rrc Should Contain    sCellToAddModList    physCellId 50
    UE Detach

Scell_2 Added Based On A1 Rsrp Higher Than TDD Threshold
    [Arguments]    ${rrc_log_tag}=scell_2
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition By A1 Event    scell_num=3
    Check Scell Number    expected_scell_num=1
    Rrc Should Contain    sCellToAddModList    physCellId 51
    UE Detach

SA UE 83 Release And Scell_1 Added Based On A1 Rsrp Higher Than TDD Threshold
    [Arguments]    ${rrc_log_tag}=scell_1
    UE Detach    ue_id=83
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition By A1 Event    scell_num=3
    Check Scell Number    expected_scell_num=1
    Rrc Should Contain    sCellToAddModList    physCellId 50
    UE Detach

No SCell Change Based On A1 Rsrp Higher Than TDD Threshold
    No Scell Addition by A1 Event    srsrp_nr=120    srsrq_nr=120

Scell_11_13 Added Based On A1 Rsrp Higher Than FDD But Lower Than TDD
    [Arguments]    ${rrc_log_tag}=scell_11_13
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    rsrp=40    rsrq=20    scell_num=2
    Check Scell Number    expected_scell_num=2
    Rrc Should Contain    sCellToAddModList    physCellId 60    physCellId 62

UE Attach and Start L3 Call
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1    ${cell}=12
    ${ret}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell}    location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...    pass_regexp=QoS Routing Table
    Check Traffic

Check Traffic
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5

Triggered Scell Addition By A1 Event
    [Arguments]    ${ue_id}=81    ${rsrp}=120    ${rsrq}=110    ${scell_num}=2
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully

No Scell Addition by A1 Event
    [Arguments]    ${srsrp_nr}=121    ${srsrq_nr}=110    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    fail_regexp=rrcReconfiguration

SA UE 83 Attach At FDD Cell-11 And TDD Scell 1 Blind Addition
    [Arguments]    ${ue_id}=83
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    activated successfully at airphone
    Should Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    physCellId 50
    Should Not Contain    ${ret1}    SCellIndex 2
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone

SA UE 84 Attach At FDD Cell-11 And TDD Scell 2 Blind Addition
    [Arguments]    ${ue_id}=84
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    activated successfully at airphone
    Should Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    physCellId 51
    Should Not Contain    ${ret1}    SCellIndex 2
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone

Check Scell Number
    [Arguments]    ${ue_id}=81    ${expected_scell_num}=1
    ${meas_obj}    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...    fail_regexp=no NR MEASUREMENT IDENTITIES
    ${meas_data}    Parse Nr Ue Meas Cfg    ${meas_obj}
    ${meas_obj_num}    Get Length    ${meas_data['nr_measurment_objects']}
    ${real_scell_num}    Evaluate    ${meas_obj_num}-1
    Should Be Equal As Integers    ${expected_scell_num}    ${real_scell_num}

No SCell Change By Trigger A1 After Online Modify A1 RsrpTDD To Higher Value
    Delta Commission Parameters    ${DELTA_PARAS_A58_C12_35_121}
    No Scell Addition by A1 Event

Scell_2 Changed By Trigger A1 After Online Modify A1 RsrpTDD To Lower Value
    Delta Commission Parameters    ${DELTA_PARAS_A58_C12_35_111}
    Scell_2 Added Based On A1 Rsrp Higher Than TDD Threshold

UE Detach
   [Arguments]    ${ue_id}=81
   Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off
   ...    pass_regexp=UE${ue_id}: detached



