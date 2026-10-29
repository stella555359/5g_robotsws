*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB008246    release-SBTS24R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS-1:actMultiDrbNSA=true
...    @{HO_flag}
...    @{intra_freq_intra_DU_TDD}
...    @{pscell_change_configuration}
...    @{8246_related_param}

@{HO_flag}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true

@{intra_freq_intra_DU_TDD}
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=0
...    NRCELL:sMeasConfigSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=8
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=2
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11/NRREL-1:gNbId=3
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=3
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2/NRREL-1:gNbId=3
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=3
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{pscell_change_configuration}
...    NRBTS:tDCoverall=10000
...    NRBTS:timerX2UeProcGuard=15000
...    NRBTS/NRADJNRCELL-1:cellDepType=NSA
...    NRBTS/NRADJNRCELL-1:gNbId=3
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=3
...    NRBTS/NRADJNRCELL-1:nrarfcn=518580
...    NRBTS/NRADJNRCELL-1:physCellId=381
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    delete:NRBTS/NRADJNRCELL-1:freqBandIndicatorNR

@{8246_related_param}
...    NRBTS/BWP_PROFILE-1/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-2/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRCELL-11:actLAForHiReliab=true
...    NRCELL-11:scalingStepdownHREnabled=true
...    NRCELL-11:pdschHrLaConfig:dllaDeltaCqiStepdownHR=2000
...    NRCELL-11:puschHrLaConfig:ullaDeltaSinrStepdownHR=2000
...    NRBTS/NRDRB-6:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
...    NRBTS/NRDRB-6:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-6:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRPDCCHHRLA-1:pdcchHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=1
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110

${UE_Capa_For_ue_92}    SEPARATOR=
...    EDA09000575F5A13160003C320016093170019C3D09009B26C39F30C7942C0E088040623807DC2C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A05883AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA1626EB04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381502C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
...    0381C3C27FFC00001FFF00000130000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A000388
...    20000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040B02B171
...    3400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B02B170A0
...    00388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D02EC1F0A244D8E7C385122
...    6C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C7
...    3E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09801E00140E0A00E0601280380030120
...    02030140000000001200400C1F048010000000080000100400000002000004010000040080000300400002002000014010008020080200001
...    80100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B26
...    6B016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2C
...    A480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A
...    93455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100210100200804030061008
...    0100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406
...    080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

${UE_Capa_For_ue_92_eutra}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000
...    002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C0
...    41809A1E80B907893A244D8E7C3893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C73E01A0718C63
...    18C60C02080002010100200804030061000040202004008080600C3000080404030060100C018040300610000402020040100801004000000
...    00

*** Test Cases ***
CB008246_K29_NSA_PScell_Change_FF_FAF_Activated_Pcell_Scell_After_nonGBR_HRDRB_Setup_Alt1
    [Documentation]
    ...    1.Description
    ...    This user scenario validates the high reliability DRBs interworking with Carrier aggregation in DL for NSA 3x
    ...    UE. While UE is configured with at least one HR nonGBR DRB (regardless of other DRBs), gNB may configure UE
    ...    with CA, but will add only SCell(s), which support HR. gNB will transmit the HR nonGBR DRB data with high reliability
    ...    over the PSCell and SCell(s).
    ...    2.Configuration
    ...    a.NSA, pcell FDD, scell FDD.
    ...    b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...    c.qci9 is associated with NRPDSCHHRLA profile.
    ...    d.UE support Dl-64QAM-MCS-TableAlt.
    ...    3.Test Steps
    ...    a.UE attach to target cell via ICS, HR qci9 is setup via PDU.
    ...    b.BR qci6 is setup via bearer setup.
    ...    c.pscell change from cell11 to simcell 381,then pscell change from simcell381 to cell11.
    ...    d.ue detach.
    ...    4.Check Points
    ...    a.HR DRB shall be setup on PCell, qam64LowSE is set in mcstable of PDSCH-Config and PUSCH-Config in rrcReconfiguration.
    ...    b.in step b, BR DRB is setup on Pcell, mcstable of PDSCH-Config and PUSCH-Config is absent in rrcReconfiguration.
    ...    c.pscell change to cell381 and change back to cell11 again.qam64LowSE is set in mcstable of PDSCH-Config and PUSCH-Config
    ...    in rrcReconfiguration.
    [Tags]    QC_324851    owner-chunlan.yang
    Update UE capa    ue_id=91    SA_Capa_perUE_Full=${UE_Capa_For_ue_92}    eutra_nr_capa=${UE_Capa_For_ue_92_eutra}
    Set UE Parameters Before Attach
    UE Attach And Set Allowed Band Combination List    ue_id=91    target_gnb=2    target_cells=11    bearer_id=2
    Bearer Setup    ue_id=91    bearer_id=4    regexp=Successfully reconfigured dual connectivity
    Pscell Change    ue_id=91    carrierfreq_1=424090    carrierfreq_2=424090    event_id=A3    phycell_id_1=381    phycell_id_2=60
    ...    regexp=mcs-Table qam64LowSE    bearer_id=4
    UE Detach    ue_id=91
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008246_K_29${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none    ${eutra_nr_capa}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} ue_eutra_nr_capabilities=${eutra_nr_capa}
    Execute Egate Command    ${cmd}

Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=2 ue=91 qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal
    Update Cfg    set_bearer id=3 ue=91 qci=5 pdn=1
    Update Cfg    set_bearer id=4 ue=91 qci=6 pdn=1
    Update Cfg    set_bearer id=5 ue=91 qci=7 pdn=1
    Update Cfg    set_bearer id=6 ue=91 qci=8 pdn=1
    Update Cfg    set_bearer id=7 ue=91 qci=70 pdn=1

    Update Cfg    gnb_set id=3 s1u=10.0.1.122 plmn=311:489 gnb_id=0x3 type=simulated daemon=10.0.2.1:22222 x2=10.0.1.122:36422 x2_peers=none
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    ${cell_381}    Catenate    set_cell id=3 gnb=3 tac=200 pci=127:0 proxy=10.0.2.1:12221|10.0.2.1:8891 nrci=0x1 nr_arfcn=344000:424000
    ...    gscn=5300 tdd_cell=off mandatory_for_activation=off

    Update Cfg    ${cell_381}
    ${enb}    Catenate    set_enb id=1 plmn=311:489 s1=10.0.1.121 enb_id_macro=0x12346 daemon=10.0.2.1:22222 x2=10.0.1.12 x2u=10.0.1.136
    ...    type=simulated x2_peers=none
    Update Cfg    ${enb}
    ${gnb2}    Catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 gnb_id=0x2:22 x2=10.0.1.2:36422 x2_peers=none ng=10.0.1.2
    ...    xn=10.0.1.2 amf=1 nssai=0x1:0xd143a5
    Update Cfg    ${gnb2}

UE Attach And Set Allowed Band Combination List
    [Arguments]    ${ue_id}=91    ${target_gnb}=2    ${target_cells}=11    ${bearer_id}=4
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=1:1|4:1|4:4|4:3|5:2|6:1|6:2|4:2|5:1|2:1|3:1|7:1|7:2
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity
    Send And Verify Nsa Throuput

Set UE Parameters Before Attach
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=1 target=3    ENB-1: X2AP Link with GNB-3

Verify Throuput
    [Arguments]    ${ue_id}    ${bearer_id}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throughput}/1000>9
    Should Be True    ${ul_throughput}/1000>9

Send And Verify Nsa Throuput
    [Arguments]    ${ue_id}=91    ${bearer_id}=2    ${sleep_time}=10s
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=dl mbps=10    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=ul mbps=10    UE ${ue_id}: UDP UL
    Verify Throuput    ${ue_id}    ${bearer_id}    ${sleep_time}

UE Detach
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

Pscell Change
    [Arguments]    ${ue_id}    ${carrierfreq_1}    ${carrierfreq_2}    ${event_id}    ${phycell_id_1}    ${phycell_id_2}    ${regexp}    ${bearer_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq_1}    event_type=${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_id} srsrp_nr=20 phycell_id=${phycell_id_1} nrsrp_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq_2}    event_type=${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_id} srsrp_nr=20 phycell_id=${phycell_id_2} nrsrp_nr=80
    ${retvalue}    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity
    Should Contain    ${retvalue}    ${regexp}
    Verify Throuput    ue_id=${ue_id}    bearer_id=${bearer_id}    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    bearer_id=2    sleep_time=10s

Bearer Setup
    [Arguments]    ${ue_id}    ${bearer_id}    ${regexp}
    Execute Egate Command    bearer_add ue=${ue_id} id=${bearer_id} filter=0 precedence=0    PGW-initiated Bearer Creation
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=${bearer_id} by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...     ${regexp}
    Send And Verify Nsa Throuput    ue_id=${ue_id}    bearer_id=${bearer_id}    sleep_time=10s
