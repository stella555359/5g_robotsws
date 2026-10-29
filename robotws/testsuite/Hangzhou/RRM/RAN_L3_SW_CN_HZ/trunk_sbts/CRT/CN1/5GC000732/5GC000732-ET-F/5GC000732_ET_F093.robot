*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags      QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...    owner-liupei.fang    owner-shelly.song    team-SG2    release-SBTS22R2    5GC000732
...    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000732_Base}

${carrierfreq}    508110

@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actLteNrDss=false
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true

...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_SUPPORT_LIST}

...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=95
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms





...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:lcrId=12
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:nrDcAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:lcrId=11
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:nrDcAllowed=false
...    NRCELL-3/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3



...    NRBTS-1/NRCELL-3:actCDrx=true
...    NRBTS-1/NRCELL-3:drxProfile1:drxInactivityTimer=40ms
...    NRBTS-1/NRCELL-3:drxProfile1:drxLongCycle=80ms
...    NRBTS-1/NRCELL-3:drxProfile1:drxOnDurationTimer=20ms
...    NRBTS-1/NRCELL-3:drxProfile1:drxRetransTimerDl=16slot
...    NRBTS-1/NRCELL-3:drxProfile1:drxRetransTimerUl=16slot
...    NRBTS-1/NRCELL-3:pucchF3ModulationScheme=pi2bpsk
...    NRBTS-1/NRCELL-3:pucchModeSelect=longPucch
...    NRBTS-1/NRCELL-3:actPrachMultiplexing=true
...    NRBTS-1/NRCELL-11:weightForSCellSelection=45
...    NRBTS-1/NRCELL-12:weightForSCellSelection=45

...    NRBTS/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS/NRPMRNL-1:miNrRelReportCu=disabled

...    NRCELL-3:actBeamforming=true
...    NRCELL-3:beamSet:basicBeamSet=beamSet_4
...    NRCELL-3:beamSet:leftEdgeAngle=60
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-3:beamSet:rightEdgeAngle=60
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=4 beams
...    NRCELL-3:actK1Opt=intra-gNB
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-12:actK1Opt=intra-gNB

${CA_SUPPORT_LIST}    ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa

@{PM_Counters_Check}
...    NRDU-1:${RRC_REESTAB_RECONF_FAILURE_DU}=1
...    NRCELL-3:${RRC_REESTAB_RECONF_FAILURE}=1
...    NRCELL-3:${REESTAB_ACC_RECONF_FAIL}=1
...    NRDU-1:${REESTAB_ACC_RECONF_FAIL_DU}=1
...    NRCELL-3:${REESTAB_RRCRECONFIG_SUCC}=1

${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501
${REESTAB_ACC_RECONF_FAIL_DU}    M55127C00510
${RRC_REESTAB_RECONF_FAILURE}    M55124C00503
${REESTAB_ACC_RECONF_FAIL}    M55124C00510
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516

${ReconfigurationFailure}    reconfigurationFailure

#this UE capblity include maxNumbersimultaneousNZP-CSI-RS-ActBWP-AllCC=8 The purpose is to test that there is no problem in adding scell
${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC118434102
...    0E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E608F28581C0E1E0B801FF800E000BE0005800702A0D883
...    AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000B000E0
...    551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000B
...    000E0571F11B582308682041F280C2AB64C55850E7C471E300000000000000000000007809FC0000007F00000002C
...    003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B
...    02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E26800710400385000
...    00102C0AC5C4D000E23000711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562
...    E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C46000E140000040B02B0F11800388C
...    00000C2C0803808D00A2026C041074BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E24
...    48913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF81120408
...    1B04F811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280381803A01C0018090010
...    180F82400800000004000008020000000100000200800002004000018020000100100000A008004010040100000C0
...    080000700400200000008000080040000480200000C010000140080000B004002048120080000C033953595358295
...    8195833582B594B5933580B581B58095811583B40D04000025949410000196525040000A594901000039652404000
...    125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003
...    259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28282F012A050
...    28140A05028140A05028140A05028140A0502800304040300601002004202004010080600C2010020040403006010
...    0C018202018030080600C201002004040300601002004402018030080600C0201803040400802010020086A87C000
...    4080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

*** Test Cases ***
5GC000732-ET-F093_CB006138-ET-AD032_Pcell_CSI-RS_is_upgraded_after_FDD_SCell_is_released_TFF
    [Documentation]    The purpose of this test case is to verify only one scell can be added as UE capa CSIRS NOT enough
    ...    Case steps:
    ...    1.Attach UE for waiting L3 call OK on TDD CELL-52
    ...    2.Trigger scell add coverbaseA1 TDD+FDD+FDD:phycel:52+60+61
    ...    3.Add step for RRE and check RRE successfully
    ...    4.Trigger A1 and Add scell should successfully
    ...    5.verify scell added as expect
    ...    6.check traffic
    [Tags]    QC_170363    F093
    Clear Counter Files    false
    Ue Register And Pdu Session Setup At TDD Cell-3
    Trigger ScellAdd basedA1
    Trigger RRC Reestablish with cause Then ScellAdd    ${ReconfigurationFailure}
    Check Counters    ${PM_Counters_Check}
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_F093${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_4T2F

Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full}

Trigger RRC Reestablish with cause Then ScellAdd
    [Arguments]    ${cause}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=81 gnb=2 cell=3 cause=${cause}
    ...    NR RRC Reestablishment sucessfully completed    timeout=20s
    Trigger ScellAdd basedA1 After Reestablish
    Verify Throughput

Ue Register And Pdu Session Setup At TDD Cell-3
    [Arguments]    ${ue_id}=81
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=3
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=QoS Routing Table
    Send Throuput

Trigger ScellAdd basedA1
    [Arguments]    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    event_type=A1    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=100
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Trigger ScellAdd basedA1 After Reestablish
    [Arguments]    ${ue_id}=81
    ${cmd}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A1 srsrp_nr=100 srsrq_nr=100
    ...    pass_regexp=rrcReconfigurationComplete

Send Throuput
    [Arguments]    ${ue_id}=81
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=100    UE 81: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=100    UE 81: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=100    UE 81: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=100    UE 81: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=5 mbps=100    UE 81: UDP UL

Verify Throughput
    [Arguments]    ${Tput_dl}=80    ${Tput_ul}=10    ${sleep_time}=15s
    [Documentation]    verify Tput in scell is not 0
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=81    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=81 scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}