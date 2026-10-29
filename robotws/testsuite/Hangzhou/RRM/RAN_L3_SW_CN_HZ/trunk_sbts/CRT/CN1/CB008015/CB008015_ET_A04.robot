*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    RAN_5G    CLOUD_5G_I_BLLL_AP_LOO
...    team-DevHZ5_SG2    owner-nanxiao.ge    release-5G22R2    CB008015
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{CB008015}    @{5GC001390}    @{CB006138}    @{BLL_AP_LOO}

@{5GC001390}    NRBTS/NRDU-1:actInterNumerologyCa=true
@{CB006138}
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
${CA_support_list}    ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa

@{BLL_AP_LOO}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1

@{CB008015}
...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_5_1
...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:tiltOffset=0
...    NRBTS-1/NRCELL-1:actBeamforming=true
...    NRBTS-1/NRCELL-1:nrCellType=4DL2UL
...    NRBTS-1/NRCELL-2:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-2:beamSet:basicBeamSet=beamSet_5_1
...    NRBTS-1/NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRBTS-1/NRCELL-2:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-2:beamSet:tiltOffset=0
...    NRBTS-1/NRCELL-2:actBeamforming=true
...    NRBTS-1/NRCELL-2:nrCellType=4DL2UL
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB

...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRBTS-1/NRCELL:pucchModeSelect=longPucch
...    NRDU-1:actConnectedModeMobilityCA=true

...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:removeNotAllowed=false

...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=518910
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none

...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:removeNotAllowed=false

...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actFdmScheduling=true

...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=6 beams
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=6 beams

...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:removeNotAllowed=false

...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:removeNotAllowed=false

...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none

...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none

${ue_id}    81

${cell1_lock}     NRCELL-1:administrativeState=Locked
${cell2_lock}     NRCELL-2:administrativeState=Locked
${cell1_unlock}    NRCELL-1:administrativeState=Unlocked
${cell2_unlock}    NRCELL-2:administrativeState=Unlocked

*** Test Cases ***
CB008015-ET-A04_A_B3_Blind scell selection based on different scell bandwidth_Paging
    [Documentation]
    ...    1. The purpose of this test case is to check SCell selection based on SCell bandwidth for SA call.
    ...       UE 81: support n66_n71；n71_n41；n66_n41；n66_n78; n41_n78；n71_n78；n66_n66_n71 CA
    ...       bandwidth of SCell(s) combinations:Cell 1 > Cell 2 > (Cell 11+ Cell 13) > cell 13 > cell 11
    ...    2. Test Case Steps:
    ...         a. SA UE-1 paged in cell 12, start data transfer.
    ...         b. Blind SCell addition is triggered for SA UE-1 based on UE supported band combination.
    ...         c. Release the call and lock cell 1, make a new call again with PDU session for data transferring.
    ...         d. Blind SCell addition is triggered for SA UE-1 based on UE supported band combination.
    ...         e. Release the call and lock cell 2, make a new call again with PDU session for data transferring.
    ...         f. Blind SCell addition is triggered for SA UE-1 based on UE supported band combination.
    ...         g. Release the call and unlock Cell 1 and Cell 2.
    ...    3. Expected Results:
    ...         Step b:Cell 1 is added as SCell.
    ...         Step d:Cell 2 is added as SCell.
    ...         Step f:Cell 11 and cell13 are added as SCell.
    [Tags]    QC_128157
    [Timeout]    2 hours
    SA UE 81 paged in FDD Cell-12
    Delta Commission Parameters    ${cell1_lock}
    SA UE 81 Blind At FDD Cell-12
    Delta Commission Parameters    ${cell2_lock}
    SA UE 81 Blind At FDD Cell-12 again
    Delta Commission Parameters    ${cell1_unlock}
    Delta Commission Parameters    ${cell2_unlock}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full}

SA UE 81 paged in FDD Cell-12
    [Arguments]    ${ue_id}=${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    Initial Context Setup Successful
    Execute Egate Command    ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release
    ...    pass_regexp=UE CONTEXT RELEASE COMPLETE
    Execute Egate Command    amf_paging_param id=1 default_drx=128
    ${ret1}=    Execute Egate Command    amf_paging_start id=1 ue=${ue_id}
    ...    pass_regexp=activated successfully at airphone
    should contain    ${ret1}    PagingProcedure is in progress
    should contain    ${ret1}    physCellId 50
    should contain    ${ret1}    SCellIndex 1 activated successfully at airphone
    Release Ues    ue_type=sa    ue_id=${ue_id}

SA UE 81 Blind At FDD Cell-12
    [Arguments]    ${ue_id}=${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    activated successfully at airphone
    Should Contain    ${ret1}    physCellId 51
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone
    Release Ues    ue_type=sa    ue_id=${ue_id}

SA UE 81 Blind At FDD Cell-12 again
    [Arguments]    ${ue_id}=${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    activated successfully at airphone
    Should Contain    ${ret1}    physCellId 60
    Should Contain    ${ret1}    physCellId 62
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone
    Should Contain    ${ret1}    SCellIndex 2 activated successfully at airphone
