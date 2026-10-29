*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...               team-SG2    owner-huibo.miao    release-5G21B    CB007873-F
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA_Common_Config}
...    @{CFRA}
...    @{non-srb3}
...    @{DRX}
...    @{A3_A5}
...    @{F042_precondition}
...    @{CELL11_CELL-1}

@{F042_precondition}
...    NRBTS:actInterMeNBMobility=true

@{CA_Common_Config}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
...    NRDU-1:actConnectedModeMobilityCA=true

@{CFRA}
...    NRCELL:cbraPreamblesPerSsb=n60

@{non-srb3}
...    NRBTS:srb3SupportEnabled=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9

@{DRX}
...    NRCELL-11:actCDrx=true
...    NRCELL-12:actCDrx=true

@{A3_A5}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:rsrpThresholdSSB=11
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:sMeasConfigSsbRsrp=1

@{CELL11_CELL-1}
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly

@{PM_Counters_Check_F042}
...    NRCELL-11:${RRC_RECONF_1_SCELL_DL_ATT}=3
...    NRCELL-11:${RRC_RECONF_1_SCELL_DL_SUCC}=3
...    NRCELL-11:${SGNB_DU_SCELL_1_ADMISSION_REQ}=3
...    NRCELL-11:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=3
...    NRCELL-11:${SGNB_DU_NSA_ADMISSION_REQ}=3
...    NRCELL-11:${SGNB_DU_NSA_ADMISSION_SUCC}=3
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_REQ}=3
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_SUCC}=3
...    NRCELL-11:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-11:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-11:${SGNB_SCELL_ADMISSION_UNSUCC}=0

${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035

${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C
...    790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD800
...    0007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00110001C0AE3E236B04610
...    D04083E50480AAD931561439F11C78C0000000000000000000001E027F0000001FC000000110001C00F78789A001C4100000216020541E1400071180000085815878
...    8C001C41000006160561E14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B17134003882001C280000
...    08160562E26800711800388C0000082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C46000004160562E140007118003
...    88C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C0468051013602086A0BB07C28913639F0E14489B1CF870A244D8E7C3851226C73E1
...    C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040
...    D8E7C00170F18C6318C6318C6318C61E8260078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C0100000
...    8008000050040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC1
...    5ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112
...    CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E0
...    2540A05028140A05028140A05028140A05028140A05000608080600C02004008404008020100C018402004008080600C02018030404030060100C018402004008080
...    600C02004008804030060100C018040300608080100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

${Capa_LTE}    SEPARATOR=
...    A11FF82B84C0C03850001C46000000122205C160601C46000002022205C160601828000104888170785000184600018488817080071340038820000002444080
...    2808D00A00189A007105893A24ED8E7C3853A76C0000449D1276C000044036000002408100160518C63180C01880002010100200804030060800040202018030
...    40002010100200020200401008060000

*** Test Cases ***
CB007873-5G-ET-F042_Verify_interMeNB_intrafreq_handover_without_sgnb_change
    [Documentation]    This case will test InterMeNB intrafreq HO without SRB3 with CFRA with DRX
    ...    Case steps:
    ...    1.Setup CA successfully based on NSA l3 call without SRB3
    ...    2.do interMeNB intrafreq HO without sgnb change from ENB1 cell1 to ENB11 cell1
    ...    3.do interMeNB intrafreq HO back without sgnb change from ENB11 cell1 to ENB1 cell1
    ...    counter:The counters SGNB_SCELL_1_ADMISSION_(REQ|SUCC) are handled by CU (CP_CL), and SGNB_DU_SCELL_1_ADMISSION_(REQ|SUCC) 
    ...            are handled by DU (CP-RT). What happened is that during the inter-MeNB handovers without SgNB change admission 
    ...            control was triggered in CP_RT but was not triggered in CP_CL. Hence, from the perspective of CP_CL, the only 
    ...            admission control was during the initial NSA setup, but from the perspective of CP_RT there was admission control 
    ...            during the handovers.

    [Tags]    QC_89205
    Clear Counter files
    Setup X2 lINK and Allowed ENDC on with eNB11    enb_id=11
    Ue Attach To Cell and Initial Endc Blind Ca
    Trigger InterMeNB InterCell HO without SCGChange    ue_id=91    enb_id=11    cell_id=1
    Trigger InterMeNB InterCell HO without SCGChange    ue_id=91    enb_id=1    cell_id=1
    Check Counters    ${PM_Counters_Check_F042}
    Check Wireshark Log    ${CURDIR}${/}a2a_F042${/}a2a_wireshark.ini    wait_string=UEContextRelease::4
    UE Detach From GNB

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    ${V2}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127 x2u=10.0.1.137
    ...    type=simulated x2_peers=none
    ${V3}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000
    ...    mandatory_for_activation=off
    Update Cfg    ${V2}
    Update Cfg    ${V3}
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14

Setup X2 lINK and Allowed ENDC on with eNB11
    [Arguments]    ${enb_id}=1    ${cell_id}=1
    Execute Egate Command    enb_x2_link_up enb=${enb_id} target=2    pass_regexp=ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_cell_param enb=${enb_id} id=${cell_id} allow_endc=on

Trigger InterMeNB InterCell HO without SCGChange
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1
    ${ret}=    Execute Egate Command
    ...    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=${enb_id} cell=${cell_id}
    ...    Sending SgNB Modification Confirm
    Should Contain    ${ret}    Inter-eNB handover
    Should Contain    ${ret}    SCellIndex 9 activated successfully
    Verify Throuput

Ue Attach To Cell and Initial Endc Blind Ca
    Execute Egate Command    ue_change_location id=91 cell=1 enb=1
    UE Attach To Enb Cell1    ue_id=91
    Initial Endc And Blind Ca    ue_id=91    target_gnb=2    target_cells=11    bearer_id=2
    Send And Verify Throuput

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial Endc And Blind Ca
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    SCellIndex 9 activated successfully
    Should Contain    ${ret1}    SCellIndex 9 activated successfully

Send And Verify Throuput
    Execute Egate Command    data_trf_start ue=91 id=2 dir=dl mbps=100 trf_id=2    UE 91: UDP DL
    Execute Egate Command    data_trf_start ue=91 id=2 dir=ul mbps=10    UE 91: UDP UL
    Verify Throuput    sleep_time=30s

Verify Throuput
    [Arguments]    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000 > 0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=91    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000 > 0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9           
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=91    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>90

UE Detach From GNB
  [Arguments]    ${expect_string}=${EMPTY}
  Execute Egate Command    ue_detach id=91    ${expect_string}
