*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_BLLL_AP_LOO
...     owner-selena.ye    team-SG2    release-5G22R2    CB008015    SBTS00
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{5GC001390}    @{CB006138}    @{CB008015}

@{5GC001390}    NRDU-1:actInterNumerologyCa=true
@{CB006138}
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
${CA_SUPPORT_LIST}    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa

@{CB008015}
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

...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=518910
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-1:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:tiltOffset=0
...    NRBTS-1/NRCELL-1:maxNumOfUsersPerCell=1
...    NRCELL-2/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRCELL-2:actK1Opt=intra-gNB
...    NRCELL-11/NRREL:sCellAdditionMethod=covBasedA1
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
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
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
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:removeNotAllowed=false
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
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
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

...    NRCELL-13/NRREL:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-2:removeNotAllowed=false
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
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3

...    MRBTS-1/NRBTS-1/BWP_PROFILE-3:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    MRBTS-1/NRBTS-1/BWP_PROFILE-3:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    MRBTS-1/NRBTS-1/BWP_PROFILE-4:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS-1:actInterMeNBMobility=true

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

@{DELTA_PARAS_AB05_1}
...    NRBTS-1/NRCELL-1:maxNumOfUsersPerCell=0

@{DELTA_PARAS_AB05_2}
...    NRBTS-1/NRCELL-1:maxNumOfUsersPerCell=1

*** Test Cases ***
CB008015-ET-AB05_AB_B1_NSA A1 scell addtion based on load cell and different bandwidth
    [Documentation]
    ...    1. The purpose of this test case is to check SCell selection based on weighted SCell bandwidth and cell load for NSA call.
    ...       UE 93: support n66+n71;n71+n41;n66+n41;n66+n78; n41+n78;n71+n78;n66+n66+n71 CA.
    ...       SCell(s) selection order:Cell 1 > Cell 2. (NSA only support T+T and F+T, does not support 3CCs or FDD type Scell)
    ...    2. Test Case Steps:
    ...         step1. set maxNumOfUsersPerCell=0 for Cell=1, then cell=1 can't be added as Scell.
    ...         step2. Attach NSA UE-93 to the LTE cell and initiates EN-DC toward the NR Cell 2, UE do intra-eNB HO,
    ...                MeNB initiated SgNB Modification procedure with PSCell change to FDD Cell12 and allowedBC-List
    ...                has F+T CA combination. start data transfer. in this step, no Scell is added, only do intra-eNB
    ...                HO with ue_enb_endc_param id=93 candidate_cells_mn_hex_for_menb_ho=0907BC7821E8
    ...         step3. check A1 meas config in RRC Reconfig.
    ...         step4. A1 measurement report based SCell addition is triggered,
    ...                rsrp > a1ThresholdSCellAddSsbRsrpTDD
    ...         Expected Results:
    ...                NSA UE-93 will add cell 2 for FDD-FR1 TDD 2CC CA.
    ...         step5. Release UE-93 call, then set maxNumOfUsersPerCell=1 for Cell=1, curently Cell=1 can be added as Scell.
    ...                attach NSA UE-93 to the LTE cell and initiates EN-DC toward the NR.
    ...         Expected Results:
    ...                SCell(s) selection order: Cell 1 > Cell 2 .
    ...         step6. A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for NSA UE-1.
    ...         Expected Results:
    ...                NSA UE-93 will add cell 1 for FDD-FR1 TDD 2CC CA.
    ...         step7. Release the call.
    ...         step8. set maxNumOfUsersPerCell=0 for Cell=1, so Cell=1 can not be added as Scell.
    ...                SCell(s) selection order: Cell 2 .
    ...         step9. Attach NSA UE-93 to the LTE cell and initiates EN-DC toward the NR cell 12, lock cell2.
    ...         step10. A1 measurement report based SCell addition is triggered,
    ...                 a1ThresholdSCellAddSsbRsrpTDD> rsrp > a1ThresholdSCellAddSsbRsrpFDD
    ...         Expected Results:
    ...                There is no SCell can be added for NSA UE-93.
	[Tags]    QC_104970    AB05
    Setup X2 link
    OnlineParamChange     ${DELTA_PARAS_AB05_1}
    Scell_2 Added Based On high Rsrp
    OnlineParamChange     ${DELTA_PARAS_AB05_2}
    Scell_1 Added Based On high Rsrp
    OnlineParamChange     ${DELTA_PARAS_AB05_1}
    lock Cell2
    No Scell Added Based On Low Rsrp

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    ${Update_Cfg_1}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=4:1 tac=222 proxy=10.0.2.1:12220|10.0.2.1:8890 earfcn=2510:20510
    ...    mapped_earfcn=6050:24050 mandatory_for_activation=off
    ${Update_Cfg_2}    catenate
    ...    set_cell id=3 enb=1 eci=0x1234603 pci=4:2 tac=222 proxy=10.0.2.1:12221|10.0.2.1:8891 earfcn=150:18150
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}

Scell_2 Added Based On high Rsrp
    UE Attach and establish EN-DC    2
    UE intra eNB HO
    Triggered Scell Addition by A1 Event    120    51
    Check Scell triffic
    Release Scell    93    2
    Release call

Scell_1 Added Based On high Rsrp
    UE Attach and establish EN-DC    12
    Triggered Scell Addition by A1 Event    120    50
    Check Scell triffic
    Release Scell    93    1
    Release call

No Scell Added Based On Low Rsrp
    UE Attach and establish EN-DC    12
    No Scell Addition by A1 Event    100
    Release call

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}

Setup X2 link
    Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=is up
    Execute Egate Command    enb_cell_param enb=11 id=1 allow_endc=on
    Execute Egate Command    enb_cell_param enb=1 id=1 allow_endc=on
    Execute Egate Command    enb_x2_link_up enb=11 target=2    pass_regexp=is up
    Execute Egate Command    enb_timer T_RELOCprepTimeout=10000 T_IntraMenbHoDelay=10000
    Execute Egate Command    set_pdu_param ue=93 pdu=1 trf_type=internal

UE Attach
    [Arguments]    ${ue_id}=93
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE

Establish EN-DC
    [Arguments]    ${target_cell}    ${ue_id}=93
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Proxy \\(eNB 2 cell ${target_cell}\\) reported successful RA

Send Throuput
    [Arguments]    ${ue_id}=93    ${pdu_id}=1    ${Tput}=5
    Execute Egate Command    trf_data_start id=2 ue=93 dir=dl mbps=150 trf_id=1
    ...    pass_regexp=UE ${ue_id}: UDP DL TRF
    Execute Egate Command    trf_data_start id=2 ue=93 dir=ul mbps=20 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP UL TRF

UE Attach and establish EN-DC
    [Arguments]    ${target_cell}    ${ue_id}=93
    UE Attach    ${ue_id}
    Establish EN-DC    ${target_cell}    ${ue_id}
    Send Throuput    ${ue_id}

UE intra eNB HO
    [Arguments]    ${ue_id}=93
    Execute Egate Command    ue_enb_endc_param id=93 candidate_cells_mn_hex_for_menb_ho=0907BC7821E8
    sleep    10s
    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=11 cell=1
    ...    Intra-SGW X2 Handover \\(eNB 1 -> eNB 11\\) completed
    sleep    10s
    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=1 cell=1
    ...    Intra-SGW X2 Handover \\(eNB 11 -> eNB 1\\) completed


Triggered Scell Addition by A1 Event
    [Arguments]    ${srsrp_nr}    ${scell_pci}=51    ${ue_id}=93    ${rrc_log_tag}=AB05_scell_A1
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    Start RRC Log    ${rrc_log_tag}
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=0
    ...                      activated successfully at airphone
    Rrc Should Contain    sCellToAddModList    physCellId ${scell_pci}

Check Scell triffic
    [Arguments]    ${scell_idx}=9    ${ue_id}=93
    sleep    10s
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_idx}
        ...    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0


No Scell Addition by A1 Event
    [Arguments]    ${srsrp_nr}    ${ue_id}=93
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     12
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=0
    ...    fail_regexp=rrcReconfiguration

Release Scell
    [Arguments]    ${ue_id}=93    ${scell_id}=2
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${scell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=9 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList

Release call
    [Arguments]    ${ue_id}=93
    Execute Egate Command    ue_disp
    Execute Egate Command    ue_detach id=${ue_id}    UE IS OFF

