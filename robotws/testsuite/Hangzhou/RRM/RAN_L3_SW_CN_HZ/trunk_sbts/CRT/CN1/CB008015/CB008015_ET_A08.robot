*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_BLLL_AP_LOO
...     owner-selena.ye    team-SG2    release-5G22R2    CB008015    SBTS00
Resource    ../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}    @{5GC001390}    @{CB006138}    @{CB008015}

@{5GC001390}    NRDU-1:actInterNumerologyCa=true
@{CB006138}
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}
${CA_SUPPORT_LIST}    ca_Fr1Tdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa
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

@{DELTA_PARAS_A08}
...    NRCELL:a1MeasSCellAddEnabled=rsrqCombined

&{CELLS_CARRIER_FREQ}
...     1=518910
...     2=633216
...     11=424090
...     12=126750
...     13=427970

*** Test Cases ***
CB008015-ET-A08_A_B3_A1 scell selection based on different scell bandwidth when a1MeasSCellAddEnabled equl rsrqCombined_1
    [Documentation]
    ...    1. The purpose of this test case is to SCell selection based on SCell bandwidth for SA call
    ...       UE 81: support n66+n71;n71+n41;n66+n41;n66+n78;n41+n78;n71+n78;n66+n66+n71 CA.
    ...       SCell(s) selection order:Cell 1 > Cell 2 > (Cell 11+ Cell 13) > cell 13 > cell 11.
    ...    2. Test Case Steps:
    ...         step1. pre-requested UE-111 to pre-requested UE-120 make NSA calls to cell 2.
    ...         Expected Results:
    ...               SCell(s) selection order:Cell 1 > (Cell 11+ Cell 13) > cell 13 > cell 11 > Cell 2.
    ...         step2. Make SA UE-81 attach to cell 12 , start data transfer , check A1 meas config in RRC Reconfig.
    ...         step3. A1 measurement report based SCell addition is triggered,
    ...               rsrq > a1ThresholdSCellAddSsbRsrq,
    ...               rsrp > a1ThresholdSCellAddSsbRsrpTDD.
    ...         Expected Results: Cell1 is added as scell.
    ...         step4. Release the UE-81 and lock cell 1, make a new call again with PDU session for data transferring.
    ...         step5. A1 measurement report based SCell addition is triggered,
    ...               rsrq > a1ThresholdSCellAddSsbRsrq,
    ...               rsrp > a1ThresholdSCellAddSsbRsrpTDD for SA UE-1.
    ...         Expected Results: Cell 11 and cell 13 are added as scells.
    ...         step6. lock cell11 CELL13 through shutting down, trigger A2 scell Release.
    ...         step7. Release the call.
    ...         step8. All cells are unlocked.make a new call again with PDU session for data transferring.
    ...                check A1 meas config in RRC Reconfig.
    ...         step9. A1 measurement report based SCell addition is triggered,
    ...               rsrq > a1ThresholdSCellAddSsbRsrq,
    ...               a1ThresholdSCellAddSsbRsrpTDD > rsrp > a1ThresholdSCellAddSsbRsrpFDD.
    ...         Expected Results: Cell 11 and cell 13 are added as scells.
    ...         step10. A2 scell Release trigger AND Release the call
    ...         step11. All cells are unlocked.make a new call again with PDU session for data transferring.
    ...         step12. A1 measurement report based SCell addition is triggered,
    ...                rsrq > a1ThresholdSCellAddSsbRsrq,
    ...                rsrp < a1ThresholdSCellAddSsbRsrpFDD.
    ...          Expected Results: There is no SCell can be added..
    ...         step13. release the call for SA UE-1.
	[Tags]  QC_128159
    OnlineParamChange    ${DELTA_PARAS_A08}
    Pre-UE attach to NSA calls and SA UE Attach to Cell
    scell_1 added Based On high RsrpTDD and Rsrq
    Release UE_81 and lock cell_1 and register UE_81
    Scell_11_13 Added Based On high RsrpTDD and Rsrq
    Shutdown Cell_11_13 and Release scell_11_13 and Release call
    unlock all cells and register UE_81
    Scell_11_13 Added Based On high Rsrq and mid Rsrp
    release scell_11_13 and Release call and register UE_81
    No scell added basd on high Rsrq and low Rsrp
    Release all UEs

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    ${UE111}    catenate
    ...    set_ue simulated id=111 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645500
    ${UE112}    catenate
    ...    set_ue simulated id=112 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645501
    ${UE113}    catenate
    ...    set_ue simulated id=113 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645502
    ${UE114}    catenate
    ...    set_ue simulated id=114 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645503
    ${UE115}    catenate
    ...    set_ue simulated id=115 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645504
    ${UE116}    catenate
    ...    set_ue simulated id=116 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645505
    ${UE117}    catenate
    ...    set_ue simulated id=117 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645506
    ${UE118}    catenate
    ...    set_ue simulated id=118 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645507
    ${UE119}    catenate
    ...    set_ue simulated id=119 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645508
    ${UE120}    catenate
    ...    set_ue simulated id=120 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645509
    Update Cfg    ${UE111}
    Update Cfg    ${UE112}
    Update Cfg    ${UE113}
    Update Cfg    ${UE114}
    Update Cfg    ${UE115}
    Update Cfg    ${UE116}
    Update Cfg    ${UE117}
    Update Cfg    ${UE118}
    Update Cfg    ${UE119}
    Update Cfg    ${UE120}
    Update Cfg    ue_param id=111 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ue_param id=112 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ue_param id=113 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ue_param id=114 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ue_param id=115 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ue_param id=116 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ue_param id=117 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ue_param id=118 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ue_param id=119 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ue_param id=120 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    set_bearer id=2 ue=111 qci=9 pdn=1 ip=4.7.254.210 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=112 qci=9 pdn=1 ip=4.7.254.211 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=113 qci=9 pdn=1 ip=4.7.254.212 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=114 qci=9 pdn=1 ip=4.7.254.213 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=115 qci=9 pdn=1 ip=4.7.254.214 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=116 qci=9 pdn=1 ip=4.7.254.215 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=117 qci=9 pdn=1 ip=4.7.254.216 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=118 qci=9 pdn=1 ip=4.7.254.217 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=119 qci=9 pdn=1 ip=4.7.254.218 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=120 qci=9 pdn=1 ip=4.7.254.219 default=on trf_type=internal


OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}

Pre-UE attach to NSA calls and SA UE Attach to Cell
    Pre-UE attach to NSA calls
    SA UE Attach To Cell    12

Pre-UE attach to NSA calls
    FOR    ${UE_ID}    IN RANGE    111    121
        Nsa Attach Ue ${UE_ID}
    END

Nsa Attach Ue ${UE_ID}
    Execute Egate Command    ue_attach id=${UE_ID}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=2 bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA

SA UE Attach To Cell
    [Arguments]    ${cell_id}    ${pdu_id}=1    ${gw_id}=1    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1    QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=1
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=100 trf_id=1
    ...    pass_regexp=UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=3
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=4
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=5
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Check Pcell triffice    ${pdu_id}

scell_1 added Based On high RsrpTDD and Rsrq
    Start RRC Log    A08_scell_blind
    Triggered Scell Addition by A1 Event    12    120    120
    Rrc Should Contain    sCellToAddModList    physCellId 50
    Verify Throuput    400

Release UE_81 and lock cell_1 and register UE_81
    Release call
    lock cell1
    SA UE Attach to Cell    12

Scell_11_13 Added Based On high RsrpTDD and Rsrq
    Start RRC Log    A08_scell_blind
    Triggered Scell Addition by A1 Event    12    120    120
    Rrc Should Contain    sCellToAddModList    physCellId 60    physCellId 62
    Verify Throuput with two scell    270

Shutdown Cell_11_13 and Release scell_11_13 and Release call
    Shutdown Cell    11
    Shutdown Cell    13
    Release Scell    1    11
    Release Scell    2    13
    Release call

Shutdown Cell
    [Arguments]    ${number}
    Delta Commission Parameters    MRBTS-1/NRBTS-1/NRCELL-${number}:administrativeState=Shutting Down

cell state should be Locked
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-11:administrativeState=Locked
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-13:administrativeState=Locked

unlock all cells and register UE_81
    Wait Until Keyword Succeeds    120s    10s    cell state should be Locked
    Unlock Cell1
    Unlock Cell11
    Unlock Cell13
    SA UE Attach to Cell    12

Scell_11_13 Added Based On high Rsrq and mid Rsrp
    Start RRC Log    A08_scell_blind
    Triggered Scell Addition by A1 Event    12    100    120
    Rrc Should Contain    sCellToAddModList    physCellId 60    physCellId 62
    Verify Throuput with two scell    270

release scell_11_13 and Release call and register UE_81
    Release Scell    1    11
    Release Scell    2    13
    Release call
    SA UE Attach to Cell    12

No scell added basd on high Rsrq and low Rsrp
    No Scell Addition by A1 Event    12    81    20    120

Release all UEs
    Release call
    FOR    ${UE_ID}    IN RANGE    111    121
        NSA UE detach    ${UE_ID}
    END

No Scell Addition by A1 Event
    [Arguments]    ${pcell_id}    ${ue_id}=81    ${rsrp}=100    ${rsrq}=10
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    fail_regexp=rrcReconfiguration

Check Pcell triffice
    [Arguments]    ${pdu_id}    ${ue_id}=81
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5

Triggered Scell Addition by A1 Event
    [Arguments]    ${pcell_id}    ${srsrp_nr}    ${srsrq_nr}    ${ue_id}=81
    ${carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${pcell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A1
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...                      activated successfully at airphone

Release Scell
    [Arguments]    ${scell_idx}    ${scell_id}    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${scell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_idx} scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList

Verify Throuput
    [Arguments]    ${target_dl_throuput}=135    ${pdu_id}=1     ${scell_idx}=1    ${ue_id}=81    ${sleep_time}=30s
    sleep    ${sleep_time}    sleep for Tput stable
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_idx}
    ...    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0
    ...    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 > 0
    Should Be True    ${scell_tput}/1000 + ${pcell_tput}/1000>${target_dl_throuput}

Verify Throuput with two scell
    [Arguments]    ${target_dl_throuput}=135    ${ue_id}=81    ${pdu_id}=1    ${sleep_time}=30s
    sleep    ${sleep_time}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0
    ...    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 > 0
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    Should Be True    ${scell1_tput}/1000 + ${scell2_tput}/1000 + ${pcell_tput}/1000>${target_dl_throuput}

Release call
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off        UE${ue_id}: detached

NSA UE detach
    [Arguments]    ${ue_id}=111
    Execute Egate Command    ue_detach id=${ue_id}        UE${ue_id}: detached
