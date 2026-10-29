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
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}
...    @{NRREL}
...    @{8290_enable}
...    @{2426_enable}
...    @{784_EC_enable}
...    @{8232 HPA_call_enable}


@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=10    guaranteedResourceRatioPerCell=20

@{784_EC_enable}
...    MRBTS-1/NRBTS-1/NRDU-1:numOfDrbsReservForEmergency=4
...    NRBTS:timerXnDataFwdGuard=2000
...    NRCELL-12:actVoNR=true
...    NRCELL-12:arpPrioEmergencyCall=2
...    NRCELL-12:actEmergencyCall=true
...    NRCELL-12:actEnhancedVoNR=true
...    NRCELL-12:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-12:emergencyCallLimServ=true
...    NRCELL-12:maxGBRTrafficLimit=80
...    NRCELL-12:emergencyCallFails=true
...    NRCELL-12:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-12:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-12/NRREDRT-1:redirFreqEutra=39750
...    NRCELL-12/NRREDRT-1:redirRat=eutra
...    NRCELL-12/NRREDRT-1:redirPrio=5
...    NRCELL-12:numOfRadioResReservForEmergency=1

...    NRCELL-14:actVoNR=true
...    NRCELL-14:arpPrioEmergencyCall=2
...    NRCELL-14:actEmergencyCall=true
...    NRCELL-14:actEnhancedVoNR=true
...    NRCELL-14:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL-14:emergencyCallLimServ=true
...    NRCELL-14:maxGBRTrafficLimit=80
...    NRCELL-14:emergencyCallFails=true
...    NRCELL-14:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-14:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-14/NRREDRT-1:redirFreqEutra=39750
...    NRCELL-14/NRREDRT-1:redirRat=eutra
...    NRCELL-14/NRREDRT-1:redirPrio=5
...    NRCELL-14:numOfRadioResReservForEmergency=1

...    delete:NRCELL-12/NRREDRT-1:redirSsbScs
...    delete:NRCELL-14/NRREDRT-1:redirSsbScs



@{2426_enable}
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1:fddNrCellConfigTradeoff=max cells
...    NRCELL:maxNumOfNrDcSnUsers=10
...    NRCELL:maxNumOfUsersPerNRCell=10
...    NRCELL:maxNumOfCaUsersNRCell=10
...    NRCELL:maxNumOfUsersPerCell=10
...    NRCELL:maxNumOfRrcSA=10
...    NRCELL:maxNumOfSCellAlloc=10
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
...    NRCELL-1/NRREL-10:lcrId=12
...    NRCELL-1/NRREL-10:sCellPrio=1
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=14
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
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRCELL-12:actCDrx=true
...    NRCELL-14:actCDrx=true
...    NRCELL-1:actCDrx=true




@{8232 HPA_call_enable}
...    NRCELL-12:actPriorityAccess=true
...    NRCELL-14:actPriorityAccess=true
...    NRBTS:applyPriorityAccess=HPA
...    NRBTS/NRPRIOACC_PROFILE-1:nrPlmnIdx=1
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=8
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=6
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax=4
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin=1
...    NRCELL-12:tPageCorrInt=3000
...    NRCELL-12:raPrioritizationForAI=MPS
...    NRCELL-12:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-12:powerRampingStep=dB2
...    NRCELL-12:pagingPrioLevelPaMax=1
...    NRCELL-12:pagingPrioLevelPaMin=1
...    NRCELL-12:numOfRadioResReservForPa=1
...    NRCELL-14:tPageCorrInt=3000
...    NRCELL-14:raPrioritizationForAI=MPS
...    NRCELL-14:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-14:powerRampingStep=dB2
...    NRCELL-14:pagingPrioLevelPaMax=1
...    NRCELL-14:pagingPrioLevelPaMin=1
...    NRCELL-14:numOfRadioResReservForPa=1

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-12:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-12:type0CoresetConfigurationIndex=8
...    MRBTS-1/NRBTS-1/NRCELL-14:gscnOrSsPbchArfcn=1592
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnDl=127420
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136620
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-14:type0CoresetConfigurationIndex=8


@{OnlineParamChange_B055}
...    NRCELL-1:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-12:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-14:a6MeasSCellSwapEnabled=rsrq


${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D
...    473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F6000000
...    44000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0AE3E236B04610D04083E50480AAD931
...    561439F11C78C00000000000000000040E1E027FFC00001FFF00000110001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E140
...    00710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C000008
...    2C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E2300070A000002
...    058158788C001C46000006160401C0468051013602086A0BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF81120408
...    1B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280
...    381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C0100000800800005004002008020080000600400003802001000000040000
...    4002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000
...    052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A5
...    5574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A05000608080600C0200400840400802
...    0100C018402004008080600C02018030404030060100C018402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606
...    880889098A0C0C8D8E0E8F909293139414951697A0A0C168



${pdu_id}    1
${nwslice}    1
@{SA_UE_list}
...    82
...    83
...    84
...    85

*** Test Cases ***
CB008290-ET-B055_Verify_no_scell_swap_performed_due_to_scell_L2_resources_limitation_TF_IWK_UE_pooling_with_EC_and_HPA_enabled
    [Documentation]
    ...    1. This user scenario Verify successful scell swap TF IWK UE pooling with EC and HPA enabled
    ...    2. Configuration:
    ...        set maxNumOfUserL2Pool to 10 and guaranteedResourceRatioPerCell set 20
    ...        cell-12 and cell-14 in same loki, they belong to same L1 pool and L2 pool:
    ...        guaranteedResource per cell: 2    2
    ...        EC call resource per cell: 1    1
    ...        HPA call resource per cell: 1    1
    ...        shared NR user number resource: 10-4-2-2=2

    ...    2. Test Case Steps:
    ...         a. start 4 UEs register and UE occupy scell FDD1(cell-14),used 2 guaranteedResource and 2 shared resource ,no free shared resource
    ...         b. start 1 UEs register and PDU session setup on TDD(cell-1)
    ...         c. Send A1MR to trigger Scell addition.
    ...         d. send A6MR to trigger Scell swap from cell-12 to cell-14.
    ...            Expected result: scell swap should failed
    ...         e. release one UE which is attach on cell-14
    ...         f. send A6MR to trigger Scell swap from cell-12 to cell-14 again
    ...            Expected result: scell swap should successful
    ...         f. UE deregister should be successfully.
    [Tags]    owner-liupei.fang    B055    QC_222584
    OnlineParamChange    ${OnlineParamChange_B055}
    multi SA UEs register and do traffic    ${SA_UE_list}
    CA UEs register and do traffic
    Trigger ScellSwap should failed
    Verify Throuput on Pscell and Scell    ue_id=81
    UE Deregister From gNB    85
    Trigger ScellSwap should be successfully
    Verify Throuput on Pscell and Scell    ue_id=81    scell_id=2
    Deregister UEs    ue_id_start=81    ue_id_end_before=84
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008290B055${/}a2a.ini    wait_string=UEContextReleaseComplete::16

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F_2N41_2N71_2N66

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}=14    ${ue_id}=81    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=${nwslice}    QoS Routing Table

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic


Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=50    ${scell_dl}=60    ${ul}=8    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger ScellAdd
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=80    ${srsrq_nr}=50    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete


Trigger ScellSwap should failed
    [Arguments]    ${event_type}=A6    ${carrierfreq}=127450    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=63
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    fail_regexp=rrcReconfigurationComplete

Trigger ScellSwap should be successfully
    [Arguments]    ${event_type}=A6    ${carrierfreq}=127450    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=81    ${scell_id}=1
    ...    ${phycell_id}=63
   ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete



multi SA UEs register and do traffic
    [Arguments]    ${ue_list}
    FOR    ${ue_id}    IN    @{ue_list}
         Update UE capa    ${SA_Capa_perUE_Full}    ue_id=${ue_id}
         UE Attach To Target Cell    ue_id=${ue_id}
         Traffic Should Be OK    ue_id=${ue_id}    type=sa

    END


Deregister UEs
    [Arguments]    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
    END

CA UEs register and do traffic
    [Arguments]     ${ue_id}=81
    Update UE capa    ${SA_Capa_perUE_Full}    ue_id=${ue_id}
    UE Attach To Target Cell    cell_id=1    ue_id=${ue_id}
    Send Throuput
    Trigger ScellAdd
    Verify Throuput on Pscell and Scell    ue_id=${ue_id}




