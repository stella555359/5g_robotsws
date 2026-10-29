*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO    team-SG2
...               owner-xiuli.song    5GC000732    release-SBTS19A
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000732_Base}
...    @{CELL1112}
...    @{NRDU}
...    @{CELL1}
...    @{NRREL}

@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actLteNrDss=false
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actChannelMapVal=Disabled

@{CELL1112}
...    NRBTS-1/NRCELL-11:msg1FrequencyStart=12
...    NRBTS-1/NRCELL-11:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-11:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-11:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-11:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-11:a2MeasSCellRelEnabled=rsrp


...    NRBTS-1/NRCELL-12:msg1FrequencyStart=13
...    NRBTS-1/NRCELL-12:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-12:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-12:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-12:pucchF3MaxCodeRate=zeroDot08

@{NRDU}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=1 beam
@{CELL1}
...    NRBTS-1/NRCELL-1:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-2:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-11:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-12:actK1Opt=intra-gNB
...    NRBTS-1/NRCELL-1:type0CoresetConfigurationIndex=10
...    NRBTS-1/NRCELL-1:type0SearchSpaceConfigurationIndex=5
...    NRBTS-1/NRCELL-1:actBeamforming=true
...    NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_1
...    NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    NRBTS-1/NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRBTS-1/NRCELL-1:nrCellType=4DL2UL
...    NRBTS-1/NRCELL-1:periodicCsiAcquisition:csirsPower=6
...    NRBTS-1/NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRBTS-1/NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=4
...    NRBTS-1/NRCELL-1:actAperCsi=true
...    NRBTS-1/NRCELL-1:actCDrx=true
...    NRBTS-1/NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxLongCycle=80ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxOnDurationTimer=20ms
...    NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS-1/NRCELL-1:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-1:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-1:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-1:pucchF3MaxCodeRate=zeroDot08
...    NRBTS-1/NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRBTS-1/NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRBTS-1/NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRBTS-1/NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRBTS-1/NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRBTS-1/NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms


@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:nrDcAllowed=false
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:sCellPrio=1
...    NRCELL-1/NRREL-2:sCellPrio=2
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:nrDcAllowed=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E639F28581C130080C4700FB8D85181AC1184
...    341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE000580
...    0702A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001
...    FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C
...    17003FF001C00FFC000B000E0571F11B582308682041F280C2AB64C55850E7C471E300000000000000000000
...    007809FC0000007F00000002C003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388
...    200000C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E2080071040000285815878500
...    01C4D00000C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B850001C41000E23
...    0000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E2300071180000
...    1058158B89A001C46000E140000040B02B0F11800388C00000C2C0803808D00A2026C041074BB07C28913639
...    F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF81120
...    4081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1FF811204081B1CF810A040D8E7C001
...    70F18C6318C6318C6318C61E8260078005038280381803A01C0018090010180F824008000000040000080200
...    00000100000200800002004000018020000100100000A008004010040100000C008000070040020000000800
...    0080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B593
...    3580B581B58095811583B40D04000025949410000196525040000A5949010000396524040001259490100005
...    96524040001A594901000079652404000225949010000996524040002A5949010000B9652504000325949010
...    0003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28282F012A050281
...    40A05028140A05028140A05028140A0502800304040300601002004202004010080600C20100200404030060
...    100C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086
...    A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40
${CA_support_list}
...    ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa
@{PM_Counters_Check}
...    ${RRC_REESTAB_RECONF_FAILURE_DU}=1
...    NRCELL-1:${RRC_REESTAB_RECONF_FAILURE}=1
...    NRCELL-1:${REESTAB_ACC_RECONF_FAIL}=1
...    ${REESTAB_ACC_RECONF_FAIL_DU}=1
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=1
...    NRCELL-1:${DL_RLC_VOL_TX_L_QOS_GRP_06}>0

${RRC_REESTAB_RECONF_FAILURE_DU}       M55127C00501
${RRC_REESTAB_RECONF_FAILURE}    M55124C00503
${REESTAB_ACC_RECONF_FAIL}    M55124C00510
${REESTAB_ACC_RECONF_FAIL_DU}    M55127C00510
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516
${DL_RLC_VOL_TX_L_QOS_GRP_06}    M55310C01006
${ReconfigurationFailure}    reconfigurationFailure
${ue_id}    81
${gw_id}    1
${carrierfreq}    518910
${carrierfreq1}    127450
*** Test Cases ***
5GC000732-ET-F092_CB006138-ET-AD026_Interworking_with_5GC2200_with_A-CSI_on_Pcell_during_SCell_addition
    [Documentation]
    ...    1. This user scenario validates the successful UE configuration in SA option 2 mode with 3CC CA
    ...    enabled in TDD PCell and 5GC002200 enabled in TDD PCell and DRX enabled in TDD PCell.
    ...    And add RRE to check RRE will not effect with this configuration
    ...    2. UE CAPA: band 41+ band71 +band 71
    ...                band 41: nr-rrc.supportedBandCombinationList_v1540->
    ...                         nr-rrc.maxNumberSimultaneousNZP_CSI_RS_ActBWP_AllCC=8
    ...                         totalnumberportsimultaneousNZP-CSI-RS-ActBWP-AllCC=256
    ...                         nr-rrc.csi_RS_IM_ReceptionForFeedback_element->
    ...                         nr-rrc.maxNumberSimultaneousNZP_CSI_RS_PerCC=8
    ...                         totalnumberportsimultaneousNZP-CSI-RS-perCC=64
    ...    2. Test Case Steps:
    ...             Step1: Before UE Attach prepare
    ...             Step2: Attach UE for waiting L3 call OK
    ...             Step3: Before A1basedScelladd
    ...             Step4: Trigger scell addition if not blind
    ...             Step5: After UE Attach prepare
    ...             Step6: verify scell added as expect
    ...             Step7: Trigger A2 and Release one Scell
    ...             Step8: Add step for RRE and check RRE successfully
    ...             Step9: Trigger A1 and Add scell should successfully
    ...             Step10: check scell's traffic and iE
    ...             Step11: Dettach All
    ...    3. Check counters:
    ...      RRC_REESTAB_RECONF_FAILURE_DU: If reestablishmentCause IE is reconfigurationFailure(Counter ID: M55127C00501)
    ...      RRC_REESTAB_RECONF_FAILURE: If reestablishmentCause IE is reconfigurationFailure(Counter ID: M55124C00503)
    ...      Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure(M55124C00510)
    ...      Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure (M55127C00510)
    ...      Number of RRC reconfiguration successful in RRC reestablishment procedure (M55124C00516)
    ...      M55118C07001 EPmCounterId_5G_UE_PCELL_2_CONF_SCELL_DL_SA
    ...      M55118C07002 EPmCounterId_5G_UE_SCELL_2_CONF_SCELL_DL_SA
    ...      DL RLC data PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006)
    [Tags]        QC_165752    F092
    Ue Register And Pdu Session Setup
    Trigger ScellAdd basedA1
    Trigger ScellRel basedA2
    Trigger RRC Reestablish    cell_id=1
    Trigger ScellAdd basedA1
    Check Counters    ${PM_Counters_Check}
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T_8pipes

Modify Cfg
    Update Cfg    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}

Trigger RRC Reestablish
    [Arguments]    ${cell_id}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${ReconfigurationFailure}
    ...    NR RRC Reestablishment sucessfully completed    timeout=20s
    Verify Throughput

Ue Register And Pdu Session Setup
    Clear Counter Files
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1    pass_regexp=location
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table
    Send Throuput

Trigger ScellAdd basedA1
    Start RRC Log    ScellAdd
    ${meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    event_type=A1    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=30
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Rrc Should Contain    sCellToAddModList    physCellId 60
    Verify Throughput

Trigger ScellRel basedA2
    Start RRC Log    ScellRel
    ${meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    event_type=A2    carrierfreq=${carrierfreq1}
    ${cmd}    Catenate    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A2 scell=1 srsrp_nr=10
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Rrc Should Contain    servCellId 1    physCellId 60
    Verify Throughput

Send Throuput
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=100    UE 81: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=100    UE 81: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=100    UE 81: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=100    UE 81: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=5 mbps=100    UE 81: UDP UL

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=60    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
