*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BLLL_AP_LOO
...    owner-baijie.zhu    owner-jianfen.shen    team-SG2    release-5G22R2    CB008015
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F
${CA_support_list}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Nsa

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
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:actK1Opt=intra-gNB

...    NRCELL-1:msg1FrequencyStart=19
...    NRCELL-2:msg1FrequencyStart=19
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=12
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=13

...    NRCELL-11/NRREL:sCellAdditionMethod=covBasedA1
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

...    NRCELL-12/NRREL:sCellAdditionMethod=covBasedA1
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

...    NRBTS-1/NRCELL-13:maxNumOfSCellAlloc=1
...    NRCELL-13/NRREL:sCellAdditionMethod=covBasedA1
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

...    NRBTS-1/NRCELL-1:maxNumOfSCellAlloc=1
...    NRCELL-1/NRREL:sCellAdditionMethod=covBasedA1
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

...    NRCELL-2/NRREL:sCellAdditionMethod=covBasedA1
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

@{Set_sCellAddition_Blind}
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind

${ue_id_81}    81
${ue_id_83}    83
${ue_id_85}    85

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970

*** Test Cases ***
CB008015-ET-A35_A_B5_A1 scell selection based on diff weighted scell bw and cell load when fdd cell bw higher than tdd cell
    [Documentation]
    ...    1. The purpose of this test case is to check SCell selection based on differ weight and cellload for SA call.
    ...       PRE-REQ-UE 85: support n66+n66+n71 CA Cell 11/Cell 12/Cell 13
    ...       PRE-REQ-UE 83: support n71+n41; n66+n41 CA Cell 1/Cell 11
    ...       UE 81: support n66+n71; n71+n41; n66+n41; n66+n78; n41+n78; n71+n78; n66+n66+n71 CA
    ...      final order: (Cell 11+ cell 13) > cell 1 > cell 2 = cell 13 > cell 11
    ...          Limited_maxNumOfSCellAlloc = {'NRBTS-1/NRCELL-13': {'maxNumOfSCellAlloc': '1'},
    ...                                       'NRBTS-1/NRCELL-1': {'maxNumOfSCellAlloc': '1'}}
    ...    2. Test Case Steps:
    ...         a. Pre-requested UEs are attached in cell 11. And blind SCell addition is triggered
    ...         Expected Results:: Cell 12 and cell 13 added as scell for Cell 11 for PRE-REQ-UE 85
    ...                 Cell 1 is added as scell for cell 11 for PRE-REQ-UE 83.
    ...         b. SA UE-81 attach to cell 12,and covBasedA1 SCell addition is trigged
    ...         Expected Results:Cell 2 added as scell for Cell 12 for SA UE-81
    ...         order: (Cell 11+ cell 13[UE85]) > cell 1[UE83] > cell 2 = cell 13[UE85] > cell 11
    ...         c. Release the call and lock cell 2, make a new call.
    ...            rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE-81
    ...                covBasedA1 SCell addition is triggered for SA UE-81
    ...         Expected Results:: Cell 11 is added as scell for SA UE-81
    ...         order: (Cell 11+ cell 13[UE85]) > cell 1[UE83] > cell 2[locked] = cell 13[UE85] > cell 11
    ...         d. Release the call, make a new call.
    ...            rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD but lower than a1ThresholdSCellAddSsbRsrpTDD for SA UE-81
    ...            covBasedA1 SCell addition is triggered for SA UE-81
    ...         Expected Results: Cell 11 is added as scell for SA UE-81
    ...         order: (Cell 11+ cell 13[UE85]) > cell 1[UE83] > cell 2[locked] = cell 13[UE85] > cell 11
    ...         e. Release the call and Release PRE-REQ-UE-83 call
    ...            make a new call.covBasedA1 SCell addition is triggered for SA UE-1
    ...         Expected Results: Cell 1 is added as scell for SA UE-81
    ...         order: (Cell 11+ cell 13[UE85]) > cell 1 > cell 2[locked] = cell 13[UE85] > cell 11
    ...         f. release the call for SA UE-85. and Pre-requested UE-83 are attached in cell 11.
    ...         Expected Results: Cell 1 is added as scell for PRE-REQ-UE 83
    ...         g. Release PRE-REQ-UE-85 call
    ...            make a new call.covBasedA1 SCell addition is triggered for SA UE-81
    ...         Expected Results: Cell 11 and cell 13 added as scell for SA UE-81
    ...         order: (Cell 11+ cell 13) > cell 1[UE83] > cell 2[locked] = cell 13 > cell 11
    ...         h. release the call for SA UE-81 and PRE-REQ-UE 85 are attached in cell 11.
    ...         Expected Results:Cell 12 and cell 13 added as scell for PRE-REQ-UE 85
    [Tags]    CB008015-A35    QC_128169
    [Timeout]    2 hours
    Delta Commission Parameters    ${Set_sCellAddition_Blind}
    SCell Addition Based On blind Method
    SCell Addition Based On covBasedA1 Method
    SCell Addition Based On blind and covBasedA1 Interaction
    Unlock Cell2 And Release All UEs

*** Keywords ***
Modify Cfg
    ${UE83}    catenate
    ...    set_ue simulated id=${ue_id_83} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645483 enb=2 cell=11 mode=nr
    ${UE85}    catenate
    ...    set_ue simulated id=${ue_id_85} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645485 enb=2 cell=11 mode=nr
    Update Cfg    ${UE83}
    Update Cfg    ${UE85}
    Update Cfg    ue_param id=${ue_id_81} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Update Cfg    ue_param id=${ue_id_83} ue_nr_capabilities=${Capa_FT2CC}
    Update Cfg    ue_param id=${ue_id_85} ue_nr_capabilities=${Capa_FDD3}

Change UE Location
    [Arguments]    ${ue_id}    ${target_cell}
    ${return1}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}    location
    Should Contain Any    ${return1}    location updated    already there

UE Detach And Change Location
    [Arguments]    ${ue_id}    ${target_cell}
    UE Detach    ${ue_id}
    Change UE Location    ${ue_id}    ${target_cell}

SCell Addition Based On blind Method
    Step_a1_SCell_1 Addition For UE83
    Step_a2_SCell_12 And SCell_13 Addition For UE85

SCell Addition Based On covBasedA1 Method
    SCell_2 Addition based on A1 RSRP higher than Threshold for both TDD and FDD For UE81
    SCell_11 Addition based on A1 RSRP higher than Threshold for both TDD and FDD For UE81
    SCell_11 Addition based on A1 RSRP between Threshold for TDD and FDD For UE81
    SCell_1 Addition after Release UE83 and based on A1 RSRP higher than Threshold for both TDD and FDD For UE81

SCell Addition Based On blind and covBasedA1 Interaction
    SCell_1 Addition after Release UE85 and based on blind For UE83
    SCell_11 And SCell_13 Addition based on A1 RSRP higher than Threshold for both TDD and FDD For UE81
    SCell_12 And SCell_13 Addition after Release UE81 and based on blind For UE85

Step_a1_SCell_1 Addition For UE83
    [Arguments]    ${ue_id}=${ue_id_83}    ${rrc_log_tag}=Step_a1_SCell_1_Blind
    Change UE Location    ${ue_id}    11
    Start RRC Log    ${rrc_log_tag}
    UE Attach and Start L3 Call    ${ue_id}
    Rrc Should Contain    sCellToAddModList    physCellId 50

Step_a2_SCell_12 And SCell_13 Addition For UE85
    [Arguments]    ${ue_id}=${ue_id_85}    ${rrc_log_tag}=Step_a2_SCell_12_13_Blind
    Change UE Location    ${ue_id}    11
    Start RRC Log    ${rrc_log_tag}
    UE Attach and Start L3 Call    ${ue_id}
    Rrc Should Contain    sCellToAddModList    physCellId 61    physCellId 62

SCell_2 Addition based on A1 RSRP higher than Threshold for both TDD and FDD For UE81
    [Arguments]    ${ue_id}=${ue_id_81}    ${rrc_log_tag}=Step_b_SCell_2_Higher
    Change UE Location    ${ue_id}    12
    UE Attach and Start L3 Call    ${ue_id}
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ${ue_id}    rsrp=112    rsrq=0    scell_num=1
    Check Scell Number    ${ue_id}    expected_scell_num=1
    Rrc Should Contain    sCellToAddModList    physCellId 51
    Release Scell    ${ue_id}    2

SCell_11 Addition based on A1 RSRP higher than Threshold for both TDD and FDD For UE81
    [Arguments]    ${ue_id}=${ue_id_81}    ${rrc_log_tag}=Step_c_SCell_11_Higher
    UE Detach And Change Location    ${ue_id}    12
    Lock Cell2
    UE Attach and Start L3 Call    ${ue_id}
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ${ue_id}    rsrp=112    rsrq=0    scell_num=1
    Check Scell Number    ${ue_id}    expected_scell_num=1
    Rrc Should Contain    sCellToAddModList    physCellId 60
    Release Scell    ${ue_id}    11

SCell_11 Addition based on A1 RSRP between Threshold for TDD and FDD For UE81
    [Arguments]    ${ue_id}=${ue_id_81}    ${rrc_log_tag}=Step_d_SCell_11_Between
    UE Detach And Change Location    ${ue_id}    12
    UE Attach and Start L3 Call    ${ue_id}
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ${ue_id}    rsrp=34    rsrq=0    scell_num=1
    Check Scell Number    ${ue_id}    expected_scell_num=1
    Rrc Should Contain    sCellToAddModList    physCellId 60
    Release Scell    ${ue_id}    11

SCell_1 Addition after Release UE83 and based on A1 RSRP higher than Threshold for both TDD and FDD For UE81
    [Arguments]    ${ue_id}=${ue_id_81}    ${rrc_log_tag}=Step_e_SCell_1_Higher
    UE Detach And Change Location    ${ue_id}    12
    UE Detach And Change Location    ${ue_id_83}    11
    UE Attach and Start L3 Call    ${ue_id}
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ${ue_id}    rsrp=112    rsrq=0    scell_num=1
    Check Scell Number    ${ue_id}    expected_scell_num=1
    Rrc Should Contain    sCellToAddModList    physCellId 50
    Release Scell    ${ue_id}    1
    UE Detach And Change Location    ${ue_id}    12

SCell_1 Addition after Release UE85 and based on blind For UE83
    [Arguments]    ${ue_id}=${ue_id_83}    ${rrc_log_tag}=Step_f_SCell_1_blind
    UE Detach And Change Location    ${ue_id_85}    11
    Start RRC Log    ${rrc_log_tag}
    UE Attach and Start L3 Call    ${ue_id}
    Rrc Should Contain    sCellToAddModList    physCellId 50

SCell_11 And SCell_13 Addition based on A1 RSRP higher than Threshold for both TDD and FDD For UE81
    [Arguments]    ${ue_id}=${ue_id_81}    ${rrc_log_tag}=Step_g_SCell_11_13_Higher
    UE Attach and Start L3 Call    ${ue_id}
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    ${ue_id}    rsrp=112    rsrq=0    scell_num=2
    Check Scell Number    ${ue_id}    expected_scell_num=2
    Rrc Should Contain    sCellToAddModList    physCellId 60    physCellId 62
    Release Scell    ${ue_id}    11    13

SCell_12 And SCell_13 Addition after Release UE81 and based on blind For UE85
    [Arguments]    ${ue_id}=${ue_id_85}    ${rrc_log_tag}=Step_h_SCell_12_13_Blind
    UE Detach And Change Location    ${ue_id_81}    12
    Start RRC Log    ${rrc_log_tag}
    UE Attach and Start L3 Call    ${ue_id}
    Rrc Should Contain    sCellToAddModList    physCellId 61    physCellId 62

UE Attach and Start L3 Call
    [Arguments]    ${ue_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    ...                      pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=5
    ...                      pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 dir=ul mbps=5
    ...                      pass_regexp=UE${ue_id}: Started Uplink Internal traffic

Triggered Scell Addition by A1 Event
    [Arguments]    ${ue_id}    ${rsrp}    ${rsrq}    ${scell_num}
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency
    ...           ${ue_id}    carrierfreq=${pcell_carrier_freq}    event_type=A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully

Check Scell Number
    [Arguments]    ${ue_id}    ${expected_scell_num}
    ${meas_obj}     Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...     fail_regexp=no NR MEASUREMENT IDENTITIES
    ${meas_data}    Parse Nr Ue Meas Cfg    ${meas_obj}
    ${meas_obj_num}    Get Length      ${meas_data['nr_measurment_objects']}
    ${real_scell_num}    Evaluate    ${meas_obj_num}-1
    Should Be Equal As Integers     ${expected_scell_num}    ${real_scell_num}

Release Scell
    [Arguments]    ${ue_id}      @{scell_list}
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
   ...                     pass_regexp=UE${ue_id}: detached

Unlock Cell2 And Release All UEs
    Unlock Cell2
    Release Ues    ue_type=all

