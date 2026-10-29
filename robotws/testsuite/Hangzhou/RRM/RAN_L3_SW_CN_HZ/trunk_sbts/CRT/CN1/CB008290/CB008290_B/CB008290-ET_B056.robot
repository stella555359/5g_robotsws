*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-liupei.fang
...    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    CB008290    release-5G23R1
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    maxNumPucchF3PCSIPerSlotL1Pool =1    maxNumOfUserL2Pool=100    guaranteedResourceRatioPerCell=50


@{PARAMS_IN_SCF}
...    @{PARAMS_IN_BOO_4T2F_8PIPES}
...    @{NRREL}
...    @{8847_enable}
...    @{8290_enable}
...    @{beamforming_enable}



@{beamforming_enable}
...    NRCELL-1:actDlSrsBm=false
...    NRCELL-1:actUlSrsBm=false
...    NRCELL-4:actDlSrsBm=false
...    NRCELL-4:actUlSrsBm=false
...    NRCELL-1:actBeamforming=true
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-4:numberOfRxBeamforming=4Rx
...    NRCELL:nrCellType=4DL4UL
...    NRCELL-1:beamSet:leftEdgeAngle=60
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-1:beamSet:rightEdgeAngle=60
...    NRCELL-4:actBeamforming=true
...    MRBTS-1/NRBTS-1/NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-4:beamSet:leftEdgeAngle=60
...    NRCELL-4:beamSet:lowerEdgeAngle=120
...    NRCELL-4:beamSet:rightEdgeAngle=60
...    NRCELL-4:beamSet:upperEdgeAngle=60
...    NRCELL-2:actBeamforming=false
...    NRCELL-2:beamSet:basicBeamSet=beamSet_1
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-11:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-2:numberOfRxBeamforming=2Rx
...    NRCELL-3:numberOfRxBeamforming=2Rx
...    NRCELL-11:numberOfRxBeamforming=2Rx
...    NRCELL-12:numberOfRxBeamforming=2Rx
...    NRCELL-3:actBeamforming=false
...    NRCELL-3:beamSet:basicBeamSet=beamSet_1
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    MRBTS-1/NRBTS-1/NRCELLGRP-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELLGRP-2:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRDU-1:actNonBfAndBfCa=true
...    delete:NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1
...    delete:NRCELL-2:periodicCsiAcquisition:maxCsirsNumber
...    delete:NRCELL-2:periodicCsiAcquisition:csirsPower
...    delete:NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1
...    delete:NRCELL-3:periodicCsiAcquisition:maxCsirsNumber
...    delete:NRCELL-3:periodicCsiAcquisition:csirsPower



@{8847_enable}
...    NRBTS:actBbPoolTddFr1=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRCELL:maxNumOfUsersPerNRCell=30
...    NRCELL:maxNumOfCaUsersNRCell=30
...    NRCELL:maxNumOfUsersPerCell=30
...    NRCELL:maxNumOfRrcSA=30
...    NRCELL:maxNumOfSCellAlloc=30
...    NRCELL:srPeriodicity=slots20
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots320

@{NRREL}
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:lcrId=3
...    NRCELL-1/NRREL-10:sCellPrio=1
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=4
...    NRCELL-1/NRREL-1:sCellPrio=2
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL:actK1Opt=intra-gNB


@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA

...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1HysteresisSCellAddSsbRsrq=0|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a1MeasSCellAddSsbRsrq:a1ThresholdSCellAddSsbRsrq=30|a1TimeToTriggerSCellAddSsbRsrq=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3:weightForSCellSelection=50
...    NRCELL-4:weightForSCellSelection=50
...    NRCELL-3:actCDrx=true
...    NRCELL-4:actCDrx=true
...    NRCELL-1:actCDrx=true



@{OnlineParamChange_B056}
...    NRCELL-1:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-3:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-4:a6MeasSCellSwapEnabled=rsrq





${ue_nr_capabilities}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D47
...    3E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F60000004400
...    0702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0AE3E236B04610D04083E50480AAD931561439
...    F11C78C00000000000000000040E1E027FFC00001FFF00000110001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E14000710400
...    000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000082C0AC5C280
...    00E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C00
...    1C46000006160401C0468051013602086A0BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081
...    B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280381804A00E000C04
...    80080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802001000000040000400200002401000006
...    0080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202
...    000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B15
...    4162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C
...    02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F9092
...    93139414951697A0A0C168


${pdu_id}    1
${nwslice}    1
@{SA_UE_list}
...    1
...    2
...    3
...    4
...    5
...    6
...    7
...    8
...    9
...    10
...    11
...    12
...    13
...    14



@{non-CA_ue_list}
...    16
...    17





*** Test Cases ***
CB008290-ET-B056_Verify_no_scell_swap_performed_due_to_pcell_L1_resources_limitation_TT_IWK_UE_pooling
    [Documentation]
    ...    1. This user scenario Verify successful scell swap TT IWK UE pooling with UEPooling
    ...    2. Configuration:
    ...        set maxNumPucchF3PCSIPerSlotL1Pool to 1 and maxNumOfUserL2Pool to 100 and guaranteedResourceRatioPerCell set 50:
    ...        cell-3 and cell-4 in same loki, they belong to same L1 pool and L2 pool:
    ...        cell4: guaranteedCommonPCSICapacityCell_with beamforming =
    ...        roundup( NRCELL/maxNumOfUsersPerNRCell* (guaranteedResourceRatioPerCell /100) ) * maxNumOfPCSIPerNonCAUE * (320/csiReportPeriodicity)
    ...           =30*50%*2*320/320=30
    ...        cell3: guaranteedCommonPCSICapacityCell_without beamforming =
    ...        roundup( NRCELL/maxNumOfUsersPerNRCell* (guaranteedResourceRatioPerCell /100) ) * maxNumOfPCSIPerNonCAUE * (320/csiReportPeriodicity)
    ...          =30*50%*1*320/320=15
    ...        totally capacityPool =maxNumPucchF3PCSIPerSlotL1Pool*320*Uplink Share=320*2/10(uplinkshare)=64
    ...        guaranteedResource per cell: 30    15
    ...        shared NR user number resource: 64-30-15=19
    ...    3. Test Case Steps:
    ...         a. start 15 CA UEs and 2 non-CA UEs register on cell-1 and UE occupy resource(used 15*(2+1)+2*2=45+4=49,
    ...            including guaranteedResource with 30 and 19 shared resource ,left no shared resource)
    ...            Expected Result:
    ...              a.UE registers successfully on cell-1
    ...              b.PDU session is setup successfully
    ...              c. Cell-3 is selected as scell for 15 CA UEs.
    ...              d. check RRC reconfiguration:
    ...                 A1 for Scell add ,A6 on Cell-3 are setup
    ...              e. 2 non-CA UEs setup successfully on cell-1
    ...         b. send A6MR to trigger Scell swap from cell-3 to cell-4.
    ...            Expected Result:
    ...              a. scell swap from Cell-3 to cell-4 failed due to no resource
    ...              b. check syslog and all L1 resource occupied
    ...         c. 2Used UEs A2 scell release,release 2 resource
    ...         d. send A6MR to trigger Scell swap on UE 15 from scell cell-3 to cell-4 again
    ...            Expected Result:
    ...              a. scell swap from Cell-3 to cell-4 sucessfully
    ...              b. check syslog and all L1 resource occupied
    ...         e. send A6MR to trigger Scell swap on UE 15 from scell cell-4 to cell-3 back
    ...            Expected Result:
    ...              a.scell swap should should successfully
    ...         f. UE deregister should be successfully.
    [Tags]    owner-liupei.fang    B056    QC_220591
    OnlineParamChange    ${OnlineParamChange_B056}
    multi SA CA UEs register and do traffic    ${SA_UE_list}
    multi SA UEs register and do traffic      ${non-CA_ue_list}
    Trigger ScellSwap should failed    event_type=A6    carrierfreq=508110    scell_id=1    ue_id=15    phycell_id=53
    Trigger scellrelease    event_type=A2    carrierfreq=508110    scell_index=1    ue_id=1
    Trigger scellrelease    event_type=A2    carrierfreq=508110    scell_index=1    ue_id=2
    Trigger ScellSwap should be successfully    event_type=A6     carrierfreq=508110    scell_id=1    ue_id=15    phycell_id=53
    Verify Throuput on Pscell and Scell      scell_id=2
    Trigger ScellSwap should be successfully    event_type=A6    carrierfreq=508110    scell_id=2    ue_id=15    phycell_id=52
    Verify Throuput on Pscell and Scell       scell_id=1
    multi SA UEs deregister    ${SA_UE_list}    ${non-CA_ue_list}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B056${/}a2a.ini    wait_string=UEContextReleaseComplete::68




*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_4T2F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Trigger scellrelease
    [Arguments]    ${event_type}=A2    ${carrierfreq}=508110    ${scell_index}=1    ${ue_id}=1
    ...    ${scell_rsrp}=10    ${scell_rsrq}=61    ${threshold}=34
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}    threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} event=${event_type} meas_id=${meas_id} srsrp_nr=50 srsrq_nr=50
    ...    scell=${scell_index} scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}=1    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=${nwslice}    QoS Routing Table

Send Throuput
    [Arguments]    ${ue_id}=15
    FOR    ${trf_id}    IN RANGE    2    10
            Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=${trf_id}    UE ${ue_id}: UDP DL
    END
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic



Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=15    ${traffic_dl}=1000    ${ul}=9    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    ${total_dl_tput}    Evaluate    ${scell1_tput}+${scell0_tput}
    Should Be True    ${total_dl_tput}/1000>${traffic_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}



UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=100    ${srsrq_nr}=100    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete



Trigger ScellSwap should failed
    [Arguments]    ${event_type}=A6    ${carrierfreq}=127450    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81
    ...    ${scell_id}=1    ${phycell_id}=53
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=rrcReconfigurationComplete


Trigger ScellSwap should be successfully
    [Arguments]    ${event_type}=A6    ${carrierfreq}=508110    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=53
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20
    ...    phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete



multi SA CA UEs register and do traffic
    [Arguments]    ${ue_list}
    FOR    ${ue_id}    IN    @{ue_list}
         Update UE capa    SA_Capa_perUE_Full=${ue_nr_capabilities}    ue_id=${ue_id}
         UE Attach To Target Cell    ue_id=${ue_id}
         Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
         Trigger ScellAdd    ue_id=${ue_id}    carrierfreq=632736
         Traffic Should Be OK    ue_id=${ue_id}    type=sa
    END
    Update UE capa    SA_Capa_perUE_Full=${ue_nr_capabilities}    ue_id=15
    UE Attach To Target Cell    ue_id=15
    Execute Egate Command    ue_meas_cfg_disp id=15
    Trigger ScellAdd    ue_id=15    carrierfreq=632736
    Send Throuput
    Verify Throuput on Pscell and Scell



multi SA UEs register and do traffic
    [Arguments]    ${non-CA_ue_list}
    FOR    ${ue_id}    IN    @{non-CA_ue_list}
         Update UE capa    SA_Capa_perUE_Full=${ue_nr_capabilities}    ue_id=${ue_id}
         UE Attach To Target Cell    ue_id=${ue_id}
         Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
         Traffic Should Be OK    ue_id=${ue_id}    type=sa
    END


multi SA UEs deregister
    [Arguments]    ${ue_list}    ${non-CA_ue_list}
    FOR    ${ue_id}    IN    @{ue_list}
         UE Deregister From gNB    ${ue_id}
    END
    FOR    ${ue_id}    IN    @{non-CA_ue_list}
         UE Deregister From gNB    ${ue_id}
    END


