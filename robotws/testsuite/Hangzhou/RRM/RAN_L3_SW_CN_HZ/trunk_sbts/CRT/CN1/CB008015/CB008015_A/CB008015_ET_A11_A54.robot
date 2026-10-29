*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BLLL_AP_LOO
...    owner-baijie.zhu    owner-jing.5.wang    team-SG2    release-5G22R2    CB008015
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F

@{PARAMS_IN_SCF}
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true

...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true

...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}

...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:actCDrx=true

...    NRREL:sCellAdditionMethod=covBasedA1

...    NRBTS-1/NRCELL-13:actAperCsi=true
...    NRBTS-1/NRCELL-12:actAperCsi=true
...    NRBTS-1/NRCELL-11:actAperCsi=true

...    NRCELL:pucchModeSelect=longPucch

...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0
...    NRCELL-12:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=111
...    NRCELL-12:a1MeasSCellAddSsbRsrq:a1TimeToTriggerSCellAddSsbRsrq=320ms

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

...    NRCELL-12/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:lcrId=2
...    NRCELL-12/NRREL-4:removeNotAllowed=false
...    NRCELL-12/NRREL-4:nrDcAllowed=false
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3

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

...    NRCELL-11/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:lcrId=2
...    NRCELL-11/NRREL-4:removeNotAllowed=false
...    NRCELL-11/NRREL-4:nrDcAllowed=false
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3

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

...    NRCELL-13/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-4:gNbId=1
...    NRCELL-13/NRREL-4:gNbIdLength=22
...    NRCELL-13/NRREL-4:lcrId=2
...    NRCELL-13/NRREL-4:removeNotAllowed=false
...    NRCELL-13/NRREL-4:nrDcAllowed=false
...    NRCELL-13/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-4:gnbPlmn:mncLength=3

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

${CA_support_list}    ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa

@{2T4F_MixedMode_CA_A1ScellAddition}
...    NRCELL-12:a1MeasSCellAddEnabled=rsrqCombined
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=111
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=31

@{CA_A1ScellAddition_LOAD_BACK}
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111

@{2T4F_MixedMode_CA_Blind}
...    NRBTS-1:actMeasBasedSCellAdditionSa=disabled
...    NRBTS-1:actMeasBasedSCellAdditionNsa=false
...    NRCELL:a2MeasSCellRelEnabled=none
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind

@{CA_Blind_LOAD_BACK}
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1

${ue_id}    81

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970

*** Test Cases ***
CB008015-ET-A11_A_B3_A1 scell selection based on different scell bw when SsbRsrpFDD configure higher than RsrpTDD
    [Documentation]
    ...    1. The purpose of this test case is to verify
    ...       SCell selection based on SCell bandwidth for SA call - Mixed mode of FDD-FR1 TDD CA and FDD-FDD CA
    ...       Precondition:
    ...       SCell Selection order is configured as:
    ...       Cell 1 > Cell 2 > (Cell 11+ Cell 13) > cell 13 > cell 11
    ...       the NRCELL. a1MeasSCellAddEnabled is set as 5("rsrqCombined").
    ...    2. Test Case Steps:
    ...     a. UE1 attach to cell12 ,trigger A1 measurementreport
    ...        (rsrp > a1ThresholdSCellAddSsbRsrpFDD and rsrq > a1ThresholdSCellAddSsbRsrq),
    ...        release ue
    ...     b. Lock cell1, UE1 attach to cell12 ,trigger A1 measurementreport
    ...        (rsrp > a1ThresholdSCellAddSsbRsrpFDD and rsrq > a1ThresholdSCellAddSsbRsrq),
    ...        release ue
    ...     c. Unlock cell1, UE1 attach to cell12 ,trigger A1 measurementreport
    ...        (a1ThresholdSCellAddSsbRsrpTDD < rsrp < a1ThresholdSCellAddSsbRsrpFDD
    ...        and rsrq > a1ThresholdSCellAddSsbRsrq),
    ...        release ue
    ...     d. Lock cell1, UE1 attach to cell12 ,trigger A1 measurementreport
    ...        (a1ThresholdSCellAddSsbRsrpTDD < rsrp < a1ThresholdSCellAddSsbRsrpFDD
    ...        and rsrq > a1ThresholdSCellAddSsbRsrq),
    ...        trigge A2 measurementreport,release ue
    ...     e. unlock cell1, UE1 attach to cell12 ,trigger A1 measurementreport
    ...        (rsrp < a1ThresholdSCellAddSsbRsrpTDD and rsrq > a1ThresholdSCellAddSsbRsrq),
    ...        release ue
    ...    3. Expected Results:
    ...       a,c cell 1 was selected additon to setup CA
    ...       b,d cell 2 was selected additon to setup CA
    ...       e no cell was selected
    [Tags]    CB008015-A11    QC_128160
    [Timeout]    2 hours
    Delta Commission Parameters    ${2T4F_MixedMode_CA_A1ScellAddition}
    SCell_1 addition based on A1 RSRP higher than Threshold for both TDD and FDD
    Lock Cell1
    SCell_2 addition based on A1 RSRP higher than Threshold for both TDD and FDD
    Unlock Cell1
    SCell_1 addition based on A1 RSRP between Threshold for TDD and FDD
    Lock Cell1
    SCell_2 addition based on A1 RSRP between Threshold for TDD and FDD
    Unlock Cell1
    No Scell addtion based on A1 RSRP lower than Threshold for TDD
    [Teardown]    Recover Param and Common Test Teardown    ${CA_A1ScellAddition_LOAD_BACK}

CB008015-ET-A54_A_B9_Multiple UE cases for SA call_FDD cell is pcell and scell of F-F and Pcell of F-T
    [Documentation]
    ...    1. The purpose of this test case is to verify
    ...       US CB008015-A_B9: Multiple UE cases for SA call - Mixed mode of FDD-FR1 TDD CA and FDD-FDD CA
    ...       Precondition:
    ...       SCell Selection order is configured as:
    ...       Cell 1 > Cell 2 > (Cell 11+ Cell 13) > cell 13 > cell 11
    ...       sCellAdditionMethod is blind
    ...       Cell1 N41
    ...       Cell2 N78
    ...       Cell11 n66
    ...       Cell12 n71
    ...       Cell13 N66
    ...       UE 82: support n66+n66+n71 CA
    ...       UE 83: support n66+n66+n71 CA
    ...       UE 84: support n71+n41;n66+n41 CA
    ...       UE 85: support n71+n78;n66+n78 CA
    ...       UE 91: support full capability CA
    ...    2. Test Case Steps:
    ...       a.SA call UE82 attach to cell11
    ...       b.SA call UE83 attach to cell12
    ...       c.SA call UE84 attach to cell11
    ...       d.SA call UE85 attach to cell11
    ...       e.NSA call UE91 attach to cell11
    ...    3. Expected Results:
    ...       a,cell 12,13 selected as SCell
    ...       b,cell 11,13 selected as SCell
    ...       c,cell 1 selected as SCell
    ...       d,cell 2 selected as SCell
    ...       e.cell 1 selected as SCell
    [Tags]    CB008015-A54    QC_128174
    [Timeout]    2 hours
    Delta Commission Parameters    ${2T4F_MixedMode_CA_Blind}
    SA call UE82 attach to cell11
    SA call UE83 attach to cell12
    SA call UE84 attach to cell11
    SA call UE85 attach to cell11
    NSA call UE91 attach to cell11
    [Teardown]    Recover Param and Common Test Teardown    ${CA_Blind_LOAD_BACK}

*** Keywords ***
Modify Cfg
    ${UE83}    catenate
    ...    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc    sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645483 enb=2 cell=11 mode=nr
    ${UE84}    catenate
    ...    set_ue simulated id=84 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645484 enb=2 cell=11 mode=nr
    ${UE85}    catenate
    ...    set_ue simulated id=85 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645485 enb=2 cell=11 mode=nr
    Update Cfg    ${UE83}
    Update Cfg    ${UE84}
    Update Cfg    ${UE85}
    Update Cfg    ue_param id=82 ue_nr_capabilities=${Capa_FDD3}
    Update Cfg    ue_param id=83 ue_nr_capabilities=${Capa_FDD3}
    Update Cfg    ue_param id=84 ue_nr_capabilities=${Capa_FT2CC}
    Update Cfg    ue_param id=85 ue_nr_capabilities=${Capa_FT2CC1}

SCell_1 addition based on A1 RSRP higher than Threshold for both TDD and FDD
    [Arguments]    ${ue_id}=81    ${rrc_log_tag}=A11_SCell_1_Higher
    UE Attach and Start L3 Call    ue_id=${ue_id}    cell_id=12    pdu_gw_id=1
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}
    Check Scell Number    ue_id=${ue_id}
    Rrc Should Contain    sCellToAddModList    physCellId 50
    Verify Throuput
    Release Scell    1    ue_id=${ue_id}
    UE Detach    ue_id=${ue_id}

SCell_2 addition based on A1 RSRP higher than Threshold for both TDD and FDD
    [Arguments]    ${ue_id}=81    ${rrc_log_tag}=A11_SCell_2_Higher
    UE Attach and Start L3 Call    ue_id=${ue_id}    cell_id=12    pdu_gw_id=2
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}
    Check Scell Number    ue_id=${ue_id}
    Rrc Should Contain    sCellToAddModList    physCellId 51
    Verify Throuput    pdu_id=2
    Release Scell    2    ue_id=${ue_id}
    UE Detach    ue_id=${ue_id}

SCell_1 addition based on A1 RSRP between Threshold for TDD and FDD
    [Arguments]    ${ue_id}=81    ${rrc_log_tag}=A11_SCell_1_Between
    UE Attach and Start L3 Call    ue_id=${ue_id}    cell_id=12    pdu_gw_id=3
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}    rsrp=100    rsrq=120    scell_num=1
    Check Scell Number    ue_id=${ue_id}
    Rrc Should Contain    sCellToAddModList    physCellId 50
    Verify Throuput    pdu_id=3
    Release Scell    1    ue_id=${ue_id}
    UE Detach    ue_id=${ue_id}

SCell_2 addition based on A1 RSRP between Threshold for TDD and FDD
    [Arguments]    ${ue_id}=81    ${rrc_log_tag}=A11_SCell_2_Between
    UE Attach and Start L3 Call    ue_id=${ue_id}    cell_id=12    pdu_gw_id=4
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ue_id=${ue_id}    rsrp=100    rsrq=120    scell_num=1
    Check Scell Number    ue_id=${ue_id}
    Rrc Should Contain    sCellToAddModList    physCellId 51
    Verify Throuput    pdu_id=4
    Release Scell    2    ue_id=${ue_id}
    UE Detach    ue_id=${ue_id}

No Scell addtion based on A1 RSRP lower than Threshold for TDD
    [Arguments]    ${ue_id}=81    ${rrc_log_tag}=A11_No_SCell
    UE Attach and Start L3 Call    ue_id=${ue_id}    cell_id=12    pdu_gw_id=5
    No Scell Addition by A1 Event    ue_id=${ue_id}
    Check Scell Number    ue_id=${ue_id}    expected_scell_num=0
    UE Detach    ue_id=${ue_id}

UE Attach and Start L3 Call
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_gw_id}
    ${ret}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}    location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...                      pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} dir=dl mbps=150
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} dir=ul mbps=10
    ...                      pass_regexp=UE${ue_id}: Started Uplink Internal traffic

Triggered Scell Addition by A1 Event
    [Arguments]    ${ue_id}    ${rsrp}=120    ${rsrq}=120    ${scell_num}=1
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency
    ...           ${ue_id}    carrierfreq=${pcell_carrier_freq}    event_type=A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully

No Scell Addition by A1 Event
    [Arguments]    ${ue_id}    ${rsrp}=25    ${rsrq}=120
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency
    ...           ${ue_id}    carrierfreq=${pcell_carrier_freq}    event_type=A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    fail_regexp=rrcReconfiguration

Check Scell Number
    [Arguments]    ${ue_id}    ${expected_scell_num}=1
    ${meas_obj}     Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES
    ${meas_data}    Parse Nr Ue Meas Cfg    ${meas_obj}
    ${meas_obj_num}    Get Length      ${meas_data['nr_measurment_objects']}
    ${real_scell_num}    Evaluate    ${meas_obj_num}-1
    Should Be Equal As Integers     ${expected_scell_num}    ${real_scell_num}

Release Scell
    [Arguments]    @{scell_list}    ${ue_id}
    ${scell_index}    set variable    1
    FOR    ${scell}    IN    @{scell_list}
        ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${scell}
        ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${carrier_freq}    A2
        ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
        ...    scell=${scell_index} scell_rsrp=20 scell_rsrq=20
        Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList
        ${scell_index}    evaluate    ${scell_index}+1
    END

UE Detach
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ...    pass_regexp=UE${ue_id}: detached

SA call UE82 attach to cell11
    [Arguments]    ${ue_id}=82    ${rrc_log_tag}=A54_SCell_12_13
    Start RRC Log    ${rrc_log_tag}
    UE Attach and Start L3 Call    ue_id=${ue_id}    cell_id=11    pdu_gw_id=6
    Rrc Should Contain    sCellToAddModList    physCellId 61    physCellId 62
    Verify Throuput with two scell    ue_id=${ue_id}    pdu_id=6
    UE Detach    ue_id=${ue_id}

SA call UE83 attach to cell12
    [Arguments]    ${ue_id}=83    ${rrc_log_tag}=A54_SCell_11_13
    Start RRC Log    ${rrc_log_tag}
    UE Attach and Start L3 Call    ue_id=${ue_id}    cell_id=12    pdu_gw_id=7
    Rrc Should Contain    sCellToAddModList    physCellId 60    physCellId 62
    Verify Throuput with two scell    ue_id=${ue_id}    pdu_id=7
    UE Detach    ue_id=${ue_id}

SA call UE84 attach to cell11
    [Arguments]    ${ue_id}=84    ${rrc_log_tag}=A54_SCell_1
    Start RRC Log    ${rrc_log_tag}
    UE Attach and Start L3 Call    ue_id=${ue_id}    cell_id=11    pdu_gw_id=8
    Rrc Should Contain    sCellToAddModList    physCellId 50
    Verify Throuput    ue_id=${ue_id}    pdu_id=8
    UE Detach    ue_id=${ue_id}

SA call UE85 attach to cell11
    [Arguments]    ${ue_id}=85    ${rrc_log_tag}=A54_SCell_2
    Start RRC Log    ${rrc_log_tag}
    UE Attach and Start L3 Call    ue_id=${ue_id}    cell_id=11    pdu_gw_id=9
    Rrc Should Contain    sCellToAddModList    physCellId 51
    Verify Throuput    ue_id=${ue_id}    pdu_id=9
    UE Detach    ue_id=${ue_id}

NSA call UE91 attach to cell11
    [Arguments]    ${ue_id}=91    ${rrc_log_tag}=A54_SCell_1_NSA
    Start RRC Log    ${rrc_log_tag}
    NSA UE Attach and Start L3 Call    ue_id=${ue_id}    cell_id=11
    Rrc Should Contain    sCellToAddModList    physCellId 50
    Verify Throuput with NSA    ue_id=${ue_id}
    NSA UE Detach    ue_id=${ue_id}

NSA UE Attach and Start L3 Call
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...                      reported successful RA
    Execute Egate Command    trf_data_start id=2 ue=${ue_id} dir=dl mbps=150 trf_id=1
    ...                      pass_regexp=UE ${ue_id}: UDP DL TRF:.*150.0 M
    Execute Egate Command    trf_data_start id=2 ue=${ue_id} dir=ul mbps=10 trf_id=2
    ...                      pass_regexp=UE ${ue_id}: UDP UL TRF:.*10.0 M

NSA UE Detach
   [Arguments]    ${ue_id}
   Execute Egate Command    ue_detach id=${ue_id}    detached

Recover Param and Common Test Teardown
    [Arguments]     ${origin_params}
    Delta Commission Parameters     ${origin_params}
    Common Test Teardown And Stop Capture Logs

Verify Throuput
    [Arguments]    ${scell_idx}=1    ${ue_id}=81    ${pdu_id}=1    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for Tput stable
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_idx}
        ...    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>135

Verify Throuput with two scell
    [Arguments]    ${ue_id}    ${pdu_id}    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for Tput stable
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0
    ...    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 > 0
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    Should Be True    ${scell1_tput}/1000 + ${scell2_tput}/1000 + ${pcell_tput}/1000>135

Verify Throuput with NSA
    [Arguments]    ${ue_id}    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throughput}/1000>135
    Should Be True    ${ul_throughput}/1000>9
