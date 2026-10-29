*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-Tingjian.Mao
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008311    release-5G23R3
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{NRREL}
...    @{8290_enable}
...    @{8311_Overheating_enable}

@{NRREL}
...    NRCELL-3/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-12:gNbId=1
...    NRCELL-3/NRREL-12:gNbIdLength=22
...    NRCELL-3/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-12:removeNotAllowed=false
...    NRCELL-3/NRREL-12:lcrId=12
...    NRCELL-3/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-12:sCellOperationalMode=dlOnly
...    NRBTS-1/NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRBTS-1/NRCELL-12:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRBTS-1/NRCELL-12:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRBTS-1/NRCELL-12:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRBTS-1/NRCELL-4:a2MeasSCellRelEnabled=rsrp
...    NRBTS-1/NRCELL-4:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRBTS-1/NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
...    NRBTS-1/NRCELL-4:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=5
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=20
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms100
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=20
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms100
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=5
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=5
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:removeNotAllowed=false
...    NRCELL-12/NRREL-4:lcrId=4
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlOnly
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=85
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa

@{8311_Overheating_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRCELL-12:dlSCellConfigLevel=5
...    NRCELL-12:dlSCellConfigLevelNum=10
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-3:sCellDeactivationTimerGNB=ms1280
...    NRCELL:sCellInactivityReleaseTimer=30
...    NRBTS:caBackoffTimerUeOh=30
...    NRBTS:timerPostOverheating=10
...    NRBTS:actOverheatingAssistance=true
...    NRBTS:timerOverheatIndProhibit=0s
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1

@{actSCellReleaseForInactiveSCell to disabled}
...    NRBTS:actSCellReleaseForInactiveSCell=disabled

@{actSCellReleaseForInactiveSCell to enabled}
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1

@{sCellInactivityReleaseTimer to 0S}
...    NRCELL:sCellInactivityReleaseTimer=0

@{sCellInactivityReleaseTimer to 30S}
...    NRCELL:sCellInactivityReleaseTimer=30

${SA_Capa_Support_Overheating}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11
...    C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F1
...    8E7CC31E50B0381C3C17003FF001C00FFC00110001C0AE3E236B04610D04083E50480AAD931561439F11C78C00000000000000000040E1E02
...    7FFC00001FFF00000110001C00F78789A001C4100000216020541E14000711800000858158788C001C41000006160561E1400071040000085
...    8158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E268007118
...    00388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E14000711800
...    388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602086A0BB07C28913639F0E14489B1CF870A
...    244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF8112040
...    81B1CF811204081B1CF811204081B1CF810A040D8E7C00170F18C6318C6318C6318C61E8260078005038280381804A00E000C0480080C07C1
...    20040000000200000401000000008000010040000100200000C01000008008000050040020080200800006004000038020010000000400004
...    002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA068200
...    0012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202
...    000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405
...    E02540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C020180304040300
...    60100C018402004008080600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C
...    8D8E0E8F909293139414951697A0A1C168

*** Test Cases ***
CB008311-ET-C009_2CC_TF_SA_Starting_DL_buffer_monitoring_for_SCell_Addition_is_delayed_after_due_to_UE_OH_interacting_with_A2_scell_release
    [Documentation]
    ...    1. This scenario describes If an SCell has been deactivated due to UE overheating for longer than the
    ...       sCellInactivityReleaseTimer, the gNB releases the SCell. If the gNB receives an A1 measurement report
    ...       for SCell Addition with entry condition,the The gNB delays configuration of DL buffer monitoring for
    ...       SCell Addition while the based on the NTBTS.caBackoffTimerUeOh timer is running setting.This applies only
    ...       for SA mode.
    ...    2. Configuration:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=100MHz
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n78 nr_arfcn=648000:648000 gscn=8000 chBw=100MHz
    ...    Cell id=3 gnb=1 pci=17:1 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz
    ...    Cell id=4 gnb=1 pci=17:2 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n71 nr_arfcn=136100:126900 gscn=1584 chBw=20MHz
    ...    Configure CA Relations:Cell3-Cell12
    ...    sCellAdditionMethod:blind
    ...    3. Test Case Steps:
    ...        1) UE attaches to the TDD Cell3 with high DL non-GBR data rate and configures the SCell_cell12 to the UE
    ...        2) UE is in overheating state. the gNB deactivates the Scell FDD CELL12. before sCellInactivityReleaseTimer
    ...           expired, UE send A2 for scell release success.
    ...        3) UE send A1 MR and 2CC success.
    ...        4) UE is in overheating state again,after sCellInactivityReleaseTimer expired.caBackoffTimerUeOh unexpired
    ...           UE has recovered from overheating,UE send A1 MR with entry condition,then with leaving condition,
    ...           then with entry condition,3 consecutive MRs
    ...        5) after caBackoffTimerUeOh expire,The gNB re-activates DL buffer monitoring for SCell Addition.
    ...        6) SA UE Deregister From gNB.
    [Tags]    QC_279063    C009    CA_LABEL-TF(80MHz_TDD_n41+10MHz_FDD_n71)    AP_REG
    UE Attach and TF 2CC success
    Trigger 2CC successfully using A1 after UE recovers from overheating
    Trigger 2CC successfully using A1 after the caBackoffTimerUeOh times out
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_C009${/}a2a.ini    wait_string=UEContextRelease::10

CB008311-ET-C019_2CC_FT_SA_On_Line_modification_of_SCell_Release_parameters_SCell_Release_due_to_inactivity
    [Documentation]
    ...    1. This scenario describes gNB behavior the operator modifies the NRBTS.actSCellReleaseForInactiveSCell parameter
    ...       or NRBTS/NRCELL.sCellInactivityReleaseTimer parameter on-line.
    ...    2. Configuration:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=100MHz
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n78 nr_arfcn=648000:648000 gscn=8000 chBw=100MHz
    ...    Cell id=3 gnb=1 pci=17:1 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz
    ...    Cell id=4 gnb=1 pci=17:2 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n71 nr_arfcn=136100:126900 gscn=1584 chBw=20MHz
    ...    Configure CA Relations:Cell12-Cell4
    ...    sCellAdditionMethod:covBasedA1
    ...    3. Test Case Steps:
    ...        1) UE is in 2CC FT CA success,Online changes the NRBTS.actSCellReleaseForInactiveSCell to disabled
    ...        2) Stop Scell DL non-GBR data rate,check scell release when sCellInactivityReleaseTimers expire(30s)
    ...        3) The second time UE is in 2CC,Stop Scell DL non-GBR data rate,chenck no scell release
    ...        4) high DL data rate for ue,Online changes the NRBTS.actSCellReleaseForInactiveSCell to timer_based_Fr1
    ...        5) Stop Scell DL non-GBR data rate,check no scell release,then A2 release scell
    ...        6) The third time UE is in 2CC,Stop Scell DL non-GBR data rate,check scell release when sCellInactivityReleaseTimers
    ...           expire(30s)
    ...        7) The fourth time UE is in 2CC,Online changes the NRBTS.sCellInactivityReleaseTimer to 0s
    ...        8) Stop Scell DL non-GBR data rate,check scell release when sCellInactivityReleaseTimers expire(30s)
    ...        9) The fifth time UE is in 2CC,Online changes the NRBTS.sCellInactivityReleaseTimer to 30s
    ...        10) Stop Scell DL non-GBR data rate,check no scell release
    ...        11) SA UE Deregister From gNB.
    [Tags]    QC_279053    C019    CA_LABEL-FT(20MHz_FDD_n71+80MHz_TDD_n41)    AP_REG
    UE Attach and FT 2CC success
    Online changes the actSCellReleaseForInactiveSCell to disabled
    Online changes the actSCellReleaseForInactiveSCell to enabled
    Online changes the sCellInactivityReleaseTimer to 0S
    Online changes the sCellInactivityReleaseTimer to 30S
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_C019${/}a2a.ini    wait_string=UEContextRelease::10

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_Support_Overheating}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir


UE is in overheating state
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=0    pass_regexp=deactivated
    sleep    5s    #Wait for scell to deactivate, the flow of traffic falls back

Sa Ue Attach
    [Arguments]    ${ue_id}=81    ${cell_id}=3    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=81
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=QoS Routing Table
    ...    fail_regexp=sCellIndex 1

SA UE Attach To NRcell 3
    [Arguments]    ${ue_id}=81
    Sa Ue Attach    ue_id=${ue_id}
    Setup pdu session with no scelladd    ue_id=${ue_id}

Send Throuput High DL data
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    sleep    20s    #sleep for stable traffic

Send Throuput High DL data FDD
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=50 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=100 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=100 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=20 trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

stop Throuput on secll and check RRC Complete
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=1 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=2 dir=dl
    wait until keyword succeeds    2 min    5 sec    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=3 dir=dl
    ...    pass_regexp=rrcReconfigurationComplete

stop Throuput on secll
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=1 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=2 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=3 dir=dl

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=100    ${scell_dl}=20    ${ul}=10    ${pcell_id}=0    ${scell_id}=1
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-1 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${pcell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

trigger A2 MR to release scell
    [Arguments]    ${ue_id}=81    ${cellfreq}=126750
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A2 scell=1 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=rrcReconfigurationComplete
    sleep    10s    #sleep for stable traffic

Verify no Throuput in Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=30    ${ul}=10    ${pcell_id}=0    ${scell_id}=1
    sleep    3s    #sleep for sCellInactivityReleaseTimer non-timeout
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=current
    wait until keyword succeeds    2 min    5 sec    Should Be True    ${scell1_tput}/1000 == 0
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger A1 MR to ScellAdd unsuccess
    [Arguments]    ${event_type}=A1    ${carrierfreq}=508110    ${srsrp_nr}=90    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=measurementReport

Trigger A1 MR to ScellAdd success
    [Arguments]    ${event_type}=A1    ${carrierfreq}=508110    ${srsrp_nr}=90    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=SCellIndex 1 activated successfully at airphone
    sleep    5s    #sleep for stable traffic

Verify no Scell
    [Arguments]    ${ue_id}=81    ${Tput_dl}=100    ${Tput_ul}=10
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-1 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

UE Attach and TF 2CC success
    SA UE Attach To NRcell 3
    Trigger A1 MR to ScellAdd unsuccess
    Send Throuput High DL data
    Verify Throuput on Pscell and Scell

Trigger 2CC successfully using A1 after UE recovers from overheating
    UE is in overheating state
    trigger A2 MR to release scell
    Trigger A1 MR to ScellAdd success
    Verify Throuput on Pscell and Scell

Trigger 2CC successfully using A1 after the caBackoffTimerUeOh times out
    UE is in overheating state
    sleep    30s    #Wait for sCellInactivityReleaseTimers expire
    Verify no Scell
    Trigger A1 MR to ScellAdd unsuccess
    Trigger A1 MR to ScellAdd unsuccess    srsrp_nr=70
    Trigger A1 MR to ScellAdd success
    Verify Throuput on Pscell and Scell

UE Attach and FT 2CC success
    Sa Ue Attach    cell_id=12
    Setup pdu session with no scelladd    ue_id=81
    Trigger A1 MR to ScellAdd unsuccess    carrierfreq=126750
    Send Throuput High DL data FDD
    Verify Throuput on Pscell and Scell    pcell_dl=70    scell_dl=80

Online changes the actSCellReleaseForInactiveSCell to disabled
    OnlineParamChange    ${actSCellReleaseForInactiveSCell to disabled}
    stop Throuput on secll and check RRC Complete
    Trigger A1 MR to ScellAdd unsuccess    carrierfreq=126750
    Send Throuput High DL data FDD
    Verify Throuput on Pscell and Scell    pcell_dl=70    scell_dl=80
    stop Throuput on secll
    sleep    30s    #wait for sCellInactivityReleaseTimers expire
    Verify no Throuput in Scell
    Send Throuput High DL data FDD
    Verify Throuput on Pscell and Scell    pcell_dl=70    scell_dl=80

Online changes the actSCellReleaseForInactiveSCell to enabled
    OnlineParamChange    ${actSCellReleaseForInactiveSCell to enabled}
    stop Throuput on secll
    sleep    30s    #wait for sCellInactivityReleaseTimers expire
    Verify no Throuput in Scell
    trigger A2 MR to release scell    cellfreq=508110
    Trigger A1 MR to ScellAdd unsuccess    carrierfreq=126750
    Send Throuput High DL data FDD
    Verify Throuput on Pscell and Scell    pcell_dl=70    scell_dl=80
    stop Throuput on secll and check RRC Complete

Online changes the sCellInactivityReleaseTimer to 0S
    Trigger A1 MR to ScellAdd unsuccess    carrierfreq=126750
    Send Throuput High DL data FDD
    Verify Throuput on Pscell and Scell    pcell_dl=70    scell_dl=80
    OnlineParamChange    ${sCellInactivityReleaseTimer to 0S}
    stop Throuput on secll and check RRC Complete

Online changes the sCellInactivityReleaseTimer to 30S
    Trigger A1 MR to ScellAdd unsuccess    carrierfreq=126750
    Send Throuput High DL data FDD
    Verify Throuput on Pscell and Scell    pcell_dl=70    scell_dl=80
    OnlineParamChange    ${sCellInactivityReleaseTimer to 30S}
    stop Throuput on secll
    sleep    30s    #wait for sCellInactivityReleaseTimers expire
    Verify no Throuput in Scell
