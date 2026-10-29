*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-DevHZ5_SG2    owner-keyun.ma    release-5G22R3    CB008015    CB006138    5GC001390
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{5GC001765_CB007877}    @{CB008015}    @{5GC001390}
...    @{CB006138}    @{long_pucch_parameter}    @{GSCN_param}    @{consistency_param}    @{CA_Basic}
...    NRCELL:actCDrx=true
...    NRBTS-1:actExtN77Support=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
${PM_COUNTER_INTERVAL}    5min
${PM_debug_print}    0x340002
${PM_debug_specific}    0x340006
@{PARAMS_IN_SWCONFIG}
...    ${PM_debug_print}=1
...    ${PM_debug_specific}=55139
@{GSCN_param}
...    NRCELL-1:gscnOrSsPbchArfcn=7840
...    NRCELL-2:gscnOrSsPbchArfcn=7870
...    NRCELL-11:gscnOrSsPbchArfcn=5300
...    NRCELL-12:gscnOrSsPbchArfcn=1592
@{5GC001765_CB007877}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actHoOptimizationCa=true
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=65
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35
@{CB008015}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS:sCellMeasCycle=sf320
...    NRCELL:actK1Opt=intra-gNB

...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:ssbFrequency=127450

...    NRCELL-11/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-2:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-2:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-2:a5MeasEnabled=none
...    NRCELL-11/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=77
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-2:ssbFrequency=632736

@{5GC001390}    NRBTS/NRDU-1:actInterNumerologyCa=true
@{CA_Basic}
...    NRBTS-1:cipherPrefL:nea0=9
...    NRCELL:primaryPathMaxQueueingDelay=10
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS-1:sCellActivationMethod=blind
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actCarrierAggregation=true
...    NRBTS-1:caConfigurationSupport=2CCDL_2CCUL
...    NRCELL:sCellDeactivationTimerGNB=infinity
@{CB006138}
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=120
...    NRCELL-2:a2MeasPCellSwitchEnabled=none
...    NRCELL-11:a2MeasPCellSwitchEnabled=none
...    NRCELL-12:a2MeasPCellSwitchEnabled=none
@{long_pucch_parameter}
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL:pucchModeSelect=longPucch
@{consistency_param}


...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:filterCoeffSsbRsrq=fc4
@{deltacommission_17}
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a1MeashoEnabled=rsrp
...    NRCELL-12:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-12:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-12:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a2MeashoEnabled=rsrp
...    NRCELL-12:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=2
...    NRCELL-12:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-12:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a2MeashoSsbRsrq:a2HysteresishoSsbRsrq=2
...    NRCELL-12:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=31
...    NRCELL-12:a2MeashoSsbRsrq:a2TimeToTriggerhoSsbRsrq=ms480
...    delete:NRCELL-11/NRREL-1
...    delete:NRCELL-11/NRREL-3
${CA_support_list}  ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa
${SA_Capa_perUE_Full}  SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C007FC007001FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E007BC3C4C000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A000388
...    20000042C0AC3C4C000E230000010B02B17118003882001C4100000A160561E26000713000003058158B898001C41000E140000040B02B171
...    3000388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B898001C41000E230000020B02B170A0
...    00388C001C46000004160562E2600071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D0AEC1F0A244D8E7C385122
...    6C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C7
...    3E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C631800C07A09801E00140E0A00E060128038003
...    0120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E008004
...    00000010000100080000900400001802000028010000160080040902401000018063266B2A6B052B032B066B056B296B266B016B036B012B0
...    22B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B2920
...    2000132CA480800054B29202000172CA4A0800064B29202000062CA480629355526AAA55174AA2A82C55058AA0D154A62A93455018AA05154
...    9AAA83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100210100200804030061008010020201803008
...    0600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A2
...    022242628303236383A3E424A4C4E5052545A5E828305A
${nr_capability_with_extendbandCA}  SEPARATOR=
...    E1A000000147580303000049A3000481A12006201A0130080C4700AA0D899AC31843418A8107CA090145B262A85813E439F40478C73E618F28
...    581C0E1E09C0013C0070004F0004C000381506C46D618C21A0C54083E5048092D931541439F60478C73E618F28581C0E1E04FE0000003F8000
...    000260001C008B800006E0F1180038980000002405F8000000050788C00184600008083A81C46040004120E00A02640460041E844203851A06
...    C93E1C20D8E7C3806C73E1800A02300603D04C00E000A070500703009801C001E0F8046400000032000000D900010080200172A6B036B03280
...    40800003AE928200002EBA4808000100000005A555540E2981902403201140A05028140A050281400020818020050020040C00801802004101
...    0040080401000000803006316080882848C00EAAAAAAAA40
${ue_eutra_nr_capabilitiesCA}  SEPARATOR=
...    BD1BF073058180711800000018062B000060400C1001830030300E260000010300C260601C46000C260000C0C03058180713400001818060B0
...    200E2600000203014260601C46000E26000004090758581807118100028485C01003808D01344C001E8380000000004403639F0E01B1CF8624
...    5E280A1000080404008012B8008020100402008040100802010040200804010080201004020080401008020100802010040200804000000201
...    004020000000000020100000000000000002010040200804010080000004020080400000000000402000000000000000040200804010080201
...    0040200000010080201004020000000000000000402000000000000000000000804E0010100402004040080800000020200404000000000002
...    020000000000000000201008020080401008020100402008040100802010040200804010080201004040100801010000000404008080000002
...    020000000000010100000000000080802010020200404000000101002020000000000010100202000000000001010000000000000000101380
...    080401008020100000008040100800000040200000000000201000000000001008020100402000000100802010000000804000000000004020
...    000000000020080401008020100402008040100802010040200804010080201004020080402008040100800000040200804000000201000000
...    080400000020100000000000100800000000000804E00101002020040400808010100000004040080801010000000000008080000002020040
...    400808010100202000000080801010020200000000000101000000040400808010100202004040000001010020200404000000000002020000
...    00080401008020100402008040100802010040200804010080201004020080401008020100402008040200B800804008080000002020040400
...    000000000000004040000000000000000000010080101000000040400808000000000000000080800000000000000000000201002020000000
...    808010100000000000000001010000000000000000000004020040400000010100202004040000000000020200000008080101000000000000
...    00001010000000404E200400C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801801003002006004
...    00C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600
...    400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008018010030020060
...    04008800020101002004040080108000802020040088000201010040080400801080004020200C0100
${nr_capability_with_extendoutbandCA}  SEPARATOR=
...    E1A000000147580303000049A3000481A12006201A0130080C4700AA0D899AC31843418A8107CA090145B262A85813E439F40478C73E618F28
...    581C0E1E09C0013C0070004F0004C000381506C46D618C21A0C54083E5048092D931541439F60478C73E618F28581C0E1E04FE0000003F8000
...    000260001C008B800006E0F1180038980000002405F8000000050788C00184600008083A81C46040004120E00A02640460041E804203851A06
...    C93E1C20D8E7C3806C73E1800A0233D04C00E000A070500703009801C001E0F8046400000032000000D900010080200172A6B036B032804080
...    0003AE928200002EBA4808000100000005A555540E2981902403201140A05028140A050281400020818020050020040C008018020041010040
...    080401000000803006316080882848C00EAAAAAAAA40


${GNB_SCELL_1_ADMI_REQ_SA}    M55138C01501
${GNB_SCELL_1_ADMI_SUCC_SA}    M55138C01502
${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508

${SCELL_CHANGE_ATT_SA}    M55118C06506
${SCELL_CHANGE_SUCC_SA}    M55118C06507


@{PM_Counters_Check_case19}
...    NRCELL-11:RSACU:${GNB_SCELL_1_ADMI_REQ_SA}=2
...    NRCELL-11:RSACU:${GNB_SCELL_1_ADMI_SUCC_SA}=2

...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_REQ_SA}=1
...    NRCELL-12:RSADU:${GNB_DU_SCELL_ADMI_SUCC_SA}=1

...    NRCELL-11:RSADU:${GNB_DU_SCELL_1_ADMI_REQ_SA}=2
...    NRCELL-11:RSADU:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=2

...    NRCELL-11:NCAC:${SCELL_CHANGE_SUCC_SA}=1
...    NRCELL-11:NCAC:${SCELL_CHANGE_ATT_SA}=1

...    NRCELL-11:NCAC:${UE_PCELL_1_CONF_SCELL_DL_SA}>=1
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_DL_SA}>=1


*** Test Cases ***
CNI-75210-A-B3_17_Verify_Classical_NSA_FDDTDD_blind SCell addition with extended n77 3450 to 3550MHz configured as candidate Scell
    [Documentation]
    ...    The purpose of this test case is to check SCell with NR frequency from extended n77 (3450-3550MHz) addition is performed
    ...    at UE context setup without any measurements on PCell or SCell when a UE initiate a context setup during ENDC mode
    [Tags]    responsible_tester-huabao.jiang
    Set xn gnb link up
    delta commission parameters    ${deltacommission_17}
    Cells Should Be Onair    check_sib=${False}
    DOD UE Attach and establish EN-DC    91    12    ${nr_capability_with_extendbandCA}    retvalue=SCellIndex 9 activated successfully
    Non-DOD UE Attach and establish EN-DC    92    12    ${nr_capability_with_extendoutbandCA}
    ...    retvalue=SCellIndex 9 activated successfully
    check wireshark log    ${CURDIR}${/}a2a_case17${/}a2a.ini

*** Keywords ***
Set xn gnb link up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    enb_cell_param enb=1 allow_endc=on
    Execute Egate Command    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Execute Egate Command    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14

DOD UE Attach and establish EN-DC
    [Arguments]    ${ue_id}=31    ${target_cell}=11   ${ue_nr_capabilities}=${nr_capability_with_extendband}    ${retvalue}=${EMPTY}
    ${v1}    catenate
    ...    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilitiesCA}
    Execute Egate Command    ${v1}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg    ${retvalue}

Non-DOD UE Attach and establish EN-DC
    [Arguments]    ${ue_id}=31    ${target_cell}=11   ${ue_nr_capabilities}=${nr_capability_with_extendband}    ${retvalue}=${EMPTY}
    ${v2}    catenate
    ...    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilitiesCA}
    Execute Egate Command    ${v2}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    fail_regexp=${retvalue}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N77_2N71_2N66

Modify Cfg
    ${V2}    catenate
    ...    ue_param id=1 ue_nr_capabilities=${SA_Capa_perUE_Full}
    ${V3}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400
    ...    enb=2 cell=1 mode=nr
    Update Cfg    ${V2}
    Update Cfg    ${V3}

Ue Register And Pdu Session Setup At FDD Cell-11
    Execute Egate Command    ue_location_change id=1 enb=2 cell=11
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table

Send And Verify Throughput
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 mbps=100    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=2 mbps=100    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=3 mbps=100    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=4 mbps=100    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=1 pdu=1 qfi=1 dir=ul trf_id=5 mbps=100    UE 1: UDP UL
    Verify Throughput

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=40    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Trigger FDD Scell Addition Of Cell-12 With Rsrp Via A1 Event
    [Documentation]    Only add 1 FDD Scell in NRREL within NRCELL-11
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A1 srsrp_nr=32 ssinr_nr=59 srsrq_nr=120
    ...    pass_regexp=SCellIndex 1 activated successfully
    Should Contain    ${ret1}    physCellId 61
    Should Not Contain    ${ret1}    SCellIndex 2
    Verify Throughput    Tput_dl=120    Tput_ul=10
    Execute Egate Command    ue_disp

Trigger Scell Change From FDD Cell-12 To TDD Cell-1
    Start RRC Log     Scell_Change_F12_to_T1_A1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=424090    event_type=A1
    ${ret4}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${measid} event=A1 srsrp_nr=120 srsrq_nr=120
    ...    pass_regexp=SCellIndex 2 activated successfully
    Should Contain    ${ret4}    physCellId 50
    Should Contain    ${ret4}    sCellToReleaseList
    Check RRC log    ${CURDIR}${/}a2a_case19${/}Scell_Change_F12_to_T1_A1.ini
    Verify Throughput    Tput_dl=180    Tput_ul=10
    Execute Egate Command    ue_disp
