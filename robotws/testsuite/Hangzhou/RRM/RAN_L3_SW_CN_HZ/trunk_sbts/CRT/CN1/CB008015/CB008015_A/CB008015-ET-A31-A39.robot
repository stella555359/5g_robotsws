*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_BLLL_AP_LOO
...     owner-selena.ye    team-SG2    release-5G22R2    CB008015
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}    @{5GC001390}    @{CB006138}    @{CB008015}

@{5GC001390}    NRDU-1:actInterNumerologyCa=true
@{CB006138}
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
${CA_SUPPORT_LIST}    ca_Fr1Tdd_Nsa, ca_Fdd_Fr1Tdd_Sa, ca_Fr1Tdd_Sa, ca_Fr1Tdd_Fdd_Sa, ca_Fdd_Fdd, ca_Fdd_Fr1Tdd_Nsa

@{CB008015}
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
...    NRCELL-11/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL:sCellAdditionMethod=covBasedA1
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
...    NRBTS-1/NRCELL:pucchModeSelect=longPucch

...    NRCELL-1:msg1FrequencyStart=19
...    NRCELL-2:msg1FrequencyStart=19
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=12
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=13

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970

@{DELTA_PARAS_A31}
...    NRCELL-12:weightForSCellSelection=30
...    NRCELL-2:weightForSCellSelection=90
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-1:weightForSCellSelection=40
...    NRCELL-11:weightForSCellSelection=20
...    NRCELL-12:a1MeasSCellAddEnabled=rsrpCombined

@{DELTA_PARAS_A31_recover}
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp

@{DELTA_PARAS_A39}
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRCELL-12:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min

...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

...    NRCELL-12/NRHOIF-2:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-2:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-2:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-12/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-2:ssbFrequency=633216
...    NRCELL-12/NRHOIF-2:a4MeasEnDcSteeringEnabled=none
...    NRCELL-12/NRHOIF-2:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-12/NRHOIF-2:a4MeasNrDcEnabled=none
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160


*** Test Cases ***
CB008015-ET-A31_A_B4_A1 scell selection based on different weighted scell bandwidth when a1MeasSCellAddEnabled as rsrpCombined
    [Documentation]
    ...    1. The purpose of this test case is to check SCell selection based on weighted SCell bandwidth for SA call
    ...       - mixed Mode of FDD-FR1 TDD CA and FDD-FDD CA.
    ...       UE 81: support n66+n71; n71+n41; n66+n41; n66+n78; n41+n78; n71+n78; n66+n66+n71 CA (FullCap)
    ...       Final selection order in cell 2 > cell 1 > (cell 11 + cell 13) > cell 13 > cell 12
    ...    2. Test Case Steps:
    ...         Precondition: NRCELL-12: a1MeasSCellAddEnabled: rsrpCombined
    ...         Step 1. SA UE-81 attach to cell 12 , start data transfer
    ...                 A1 is triggered, rsrp value > a1ThresholdSCellAddSsbRsrpTDD
    ...                 Release the call and lock cell 2.
    ...         Expected Result: cell2 is added as FDD-FR1 TDD 2CC CA.
    ...         Step 2. SA UE-81 make a new call again.
    ...                 A1 is triggered, rsrp value > a1ThresholdSCellAddSsbRsrpTDD
    ...                 Release the call and unlock Cell 2.
    ...         Expected Result: cell1 is added as FDD-FR1 TDD 2CC CA.
    ...         Step 3. SA UE-81 make a new call again.
    ...                 A1 is triggered, a1ThresholdSCellAddSsbRsrpFDD < rsrp value < a1ThresholdSCellAddSsbRsrpTDD
    ...                 A2 scell Release trigger
    ...                 release the call for SA UE-1
    ...         Expected Result: cell11+cell13 is added as FDD-FR1 FDD 3CC CA.
    ...         Step 4. SA UE-81 make a new call again.
    ...                 A1 is triggered, rsrq value < a1ThresholdSCellAddSsbRsrq,
    ...                 a1ThresholdSCellAddSsbRsrpFDD < rsrp value < a1ThresholdSCellAddSsbRsrpTDD
    ...         Expected Result: no scell added.
    [Tags]    QC_128167    CB008015-A31
    Delta Commission Parameters     ${DELTA_PARAS_A31}
    SA UE1 Attach to cell12 add scell_2 by A1 rsrp value higher than TDD
    SA UE1 Attach to cell12 add scell_1 by A1 rsrp value higher than TDD
    SA UE1 Attach to cell12 add scell_11_13 by A1 rsrp value between TDD and FDD
    SA UE1 Attach to cell12 no scell added by A1 lower rsrq value and rsrp between TDD and FDD
    Delta Commission Parameters     ${DELTA_PARAS_A31_recover}

CB008015-ET-A39_A_B6_A1 measurement of PCell based SCell change based on RSRP when actAperCsi False in pcell
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       A1 measurement of P(S)Cell based SCell change for SA call - RSRP
    ...    2. Test Case Steps:
    ...         Step 1: Make SA UE-1 attach to cell 12.
    ...         Step 2: A1 measurement report based SCell addition is triggered, rsrp value higher than
    ...                 a1ThresholdSCellAddSsbRsrpFDD but lower than a1ThresholdSCellAddSsbRsrpTDD for SA UE-1
    ...         Step 3: A1 measurement report based SCell addition is triggered, rsrp value higher than
    ...                 a1ThresholdSCellAddSsbRsrpTDD for SA UE-1
    ...         Step 4: inter frequency intra gnb HO to cell2 trigger
    ...         Step 5: release the call for SA UE-1
    ...    3. Expected Results:
    ...         Step 1: SA call setup successfully and configure A1 measurement for SCell addition with
    ...                 threshold for FDD(lower threshold).
    ...         Step 2: SA UE-1 will add cell 11 and cell 13 for FDD-FDD 3CC CA.A1 measurement for SCell addition
    ...                 is reconfigured for SA UE with higher threshold.
    ...         Step 3: SA UE-1 will trigger SCell change, cell 11 and cell 13 are removed and cell 1 is added
    ...                 as SCell for FDD-FR1 TDD 2CC CA
    ...         Step 4: scell release successfully.HO successfully.
    ...         Step 5: ue release successfully.
    [Tags]    CB008015-A39
    Delta Commission Parameters     ${DELTA_PARAS_A39}
    SA UE Attach to cell12    5    5
    add scell_11_13 by A1 rsrp value between TDD and FDD    90    120
    add scell_1 by A1 rsrp value higher than TDD    120    110
    Inter fre intra gnb HO to Cell2
    Release call    5

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

SA UE1 Attach to cell12 add scell_2 by A1 rsrp value higher than TDD
    Start RRC Log    A31_scell_2
    SA UE Attach To Cell12    1    1
    Triggered Scell Addition by A1 Event    120    125    1
    Rrc Should Contain    sCellToAddModList    physCellId 51
    Check Scell triffic
    Release call    1
    Lock Cell2

SA UE1 Attach to cell12 add scell_1 by A1 rsrp value higher than TDD
    [Arguments]    ${srsrp_nr}=120    ${srsrq_nr}=125
    Start RRC Log    A31_scell_1
    SA UE Attach To Cell12    2    2
    Triggered Scell Addition by A1 Event    ${srsrp_nr}    ${srsrq_nr}    1
    Rrc Should Contain    sCellToAddModList    physCellId 50
    Check Scell triffic
    Release call    2
    Unlock Cell2

SA UE1 Attach to cell12 add scell_11_13 by A1 rsrp value between TDD and FDD
    [Arguments]    ${srsrp_nr}=90    ${srsrq_nr}=125
    Start RRC Log    A31_scell_11_13
    SA UE Attach To Cell12    3    3
    Triggered Scell Addition by A1 Event    ${srsrp_nr}    ${srsrq_nr}    2
    Rrc Should Contain    sCellToAddModList    physCellId 60    physCellId 62
    Check Scell triffic
    Check Scell triffic    2
    Release Scell    1    11
    Release Scell    2    13
    Release call    3

SA UE1 Attach to cell12 no scell added by A1 lower rsrq value and rsrp between TDD and FDD
    SA UE Attach To Cell12    4    4
    No Scell Addition by A1 Event    90    25
    Release call    4

add scell_11_13 by A1 rsrp value between TDD and FDD
    [Arguments]    ${srsrp_nr}=90    ${srsrq_nr}=120
    Start RRC Log    A29_scell
    Triggered Scell Addition by A1 Event    ${srsrp_nr}    ${srsrq_nr}    2
    Rrc Should Contain    sCellToAddModList    physCellId 60    physCellId 62
    Check Scell triffic
    Check Scell triffic    2

add scell_1 by A1 rsrp value higher than TDD
    [Arguments]    ${srsrp_nr}=120    ${srsrq_nr}=110
    Start RRC Log    A29_scell
    Triggered Scell Addition by A1 Event    ${srsrp_nr}    ${srsrq_nr}    3
    Rrc Should Contain    sCellToAddModList    physCellId 50
    Check Scell triffic    3

Inter fre intra gnb HO to Cell2
    Set MeasurementGap and Initial A2 Event
    Initial InterFreA3 Ho    51

SA UE Attach To Cell12
    [Arguments]    ${pdu_id}    ${gw_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=12
    Execute Egate command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=1
    Check Pcell triffice    ${pdu_id}

Check Pcell triffice
    [Arguments]    ${pdu_id}    ${ue_id}=81
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5

Triggered Scell Addition by A1 Event
    [Arguments]    ${srsrp_nr}    ${srsrq_nr}    ${scell_index}    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    pass_regexp=SCellIndex ${scell_index} activated successfully

No Scell Addition by A1 Event
    [Arguments]    ${srsrp_nr}    ${srsrq_nr}    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    fail_regexp=rrcReconfiguration

Release Scell
    [Arguments]    ${scell_index}    ${scell_id}    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${scell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList

Release call
    [Arguments]    ${pdu_id}    ${ue_id}=81
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off     UE${ue_id}: detached

Check Scell triffic
    [Arguments]    ${scell_idx}=1    ${ue_id}=81
    sleep    10s    sleep for Tput stable
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_idx}
        ...    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

Set MeasurementGap and Initial A2 Event
    Execute Egate Command    ue_enb_param id=81 measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     12
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    eventId eventA3

Initial InterFreA3 Ho
    [Arguments]    ${phycell_id}
    Execute Egate Command    ue_meas_cfg_disp id=81 meas_obj_type=nr
    Execute Egate Command    ue_enb_param id=81 measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     2
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.2 performed
