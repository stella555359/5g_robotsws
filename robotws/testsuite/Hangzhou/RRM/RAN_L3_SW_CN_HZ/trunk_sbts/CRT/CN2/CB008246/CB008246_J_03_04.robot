*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-xiaobo.ma
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    CB008246    release-SBTS24R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS:actFullPlmnList=true
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{PDCP_outoforder}
...    @{8246_related_modification}
...    @{8246_G_related_modification}
...    @{8246_H_related_modification}
...    @{8246_J_256QAM}

@{PDCP_outoforder}
...    NRBTS:actServiceAwarePDCPConfig=true
...    NRDRB_PDCP:outOfOrderDeliveryDl=true
...    NRDRB_PDCP:outOfOrderDeliveryUl=true

@{8246_related_modification}
...    NRCELL-2:actLAForHiReliab=true
...    NRCELL-2:actCceSplit=false
...    NRCELL-2:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL-2:pdschHrLaConfig:dllaDeltaCqiMaxHR=150
...    NRCELL-2:pdschHrLaConfig:dllaDeltaCqiMinHR=-150
...    NRCELL-2:pdschHrLaConfig:dllaDeltaCqiStepdownHR=20
...    NRCELL-2:pdschHrLaConfig:dllaIniDeltaCqiHR=-30
...    NRCELL-2:pdschHrLaConfig:dllaIniMcsHR=3
...    NRCELL-2:scalingStepdownHREnabled=true
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=1
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverMcsThresh64qamLowSE=11
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerRecoverPeriod=30
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=1
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qamLowSE=2
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePercentage=50
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutagePeriod=20
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qam=5
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverMcsThresh64qamLowSE=11
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPercentage=60
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerRecoverPeriod=30
...    NRBTS/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
...    NRBTS/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDU-1:carrierAggregationSupportList=none
...    NRBTS/NRDRB-2:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-2:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1

@{8246_G_related_modification}
...    NRBTS/NRPDSCHHRLA-1:dllaBlerTargetHR=1
...    NRBTS/NRPDSCHHRLA-1:scalFactorForHRGbrDl=200
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dllaBlerTargetHR=3
...    NRBTS/NRPDSCHHRLA-2:scalFactorForHRGbrDl=110
...    NRBTS/NRPMRNL-1:miNrUlHarqOne=5min
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK1HR=28
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK2HR=28
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK3HR=28
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamLowSERANK4HR=28
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK1HR=28
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK2HR=28
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK3HR=28
...    NRCELL-2:pdschHrLaConfig:dllaMcsMax64qamRANK4HR=28
...    NRBTS/BWP_PROFILE-3/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-4/PDCCH-1:dciDedicatedAggregationLevelHR=AL4

@{8246_H_related_modification}
...    NRCELL-2:puschHrLaConfig:iniDeltaSinrHR=-50
...    NRCELL-2:puschHrLaConfig:ullaDeltaSinrMaxHR=150
...    NRCELL-2:puschHrLaConfig:ullaDeltaSinrMinHR=-300
...    NRCELL-2:puschHrLaConfig:ullaDeltaSinrStepdownHR=20
...    NRCELL-2:puschHrLaConfig:ullaIniMcsHR=0
...    NRCELL-2:puschHrLaConfig:ullaMcsMax64qamLowSERANK1HR=28
...    NRCELL-2:puschHrLaConfig:ullaMcsMax64qamLowSERANK2HR=28
...    NRCELL-2:puschHrLaConfig:ullaMcsMax64qamRANK1HR=28
...    NRCELL-2:puschHrLaConfig:ullaMcsMax64qamRANK2HR=28
...    NRCELL-2:puschHrLaConfig:ullaSinrOffsetHR=0
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh=500
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh=4000
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh64qam=7000
...    NRBTS/NRPUSCHHRLA-1:ullaBlerTargetHR=10
...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=110
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh=500
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh64qam=1000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPeriod=30
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh=4000
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh64qam=7000
...    NRBTS/NRPUSCHHRLA-2:ullaBlerTargetHR=10
...    NRBTS/BWP_PROFILE-3/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-4/PDCCH-1:alSelection=static

@{8246_J_256QAM}
...    NRCELL-2:actDl256Qam=true
...    NRCELL-2:actUl256Qam=true
...    NRBTS:actMultiDrbNSA=true

${UE_Capa_Support_HRLA_256QAM}    SEPARATOR=
...    EDA0B000575F5A13160003C320016093170019C3D09009B26C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B
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

${UE_Eutra_NR_Capabilities}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820000
...    002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00A001C0
...    41809A1E80B907893A244D8E7C3893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C73E01A0718C63
...    18C60C02080002010100200804030061000040202004008080600C3000080404030060100C018040300610000402020040100801004000000
...    00

*** Test Cases ***
CB008246_J03_04_NSA_BR_setup_ICS_then_add_HR_DRB_PDU_session_modification_256QAM
    [Documentation]
    ...    1.Description
    ...    This user scenario validates the gNB behaviour for the setup and release of one or more non-GBR High
    ...    Reliability and one or more non-GBR Basic Reliability DRBs and data transmission in DL/UL.
    ...    2.Configuration
    ...      a.SA,FDD.
    ...      b.Configured Link Adaptation High Reliability feature: NRBTS/NRCELL.actLAForHiReliab=true.
    ...      c.Default drb 5QI6 & 5QI7 are associated with NRPDSCHHRLA profile.
    ...      d.UE support 256QAM.
    ...    3.Test Steps
    ...      a.UE Attach To Target Cell via NSA and two bear.
   ...      b.UE detach.
    ...    4.Check Points
    ...      a.xxxxxxxxxx
    [Tags]    QC_322315    owner-xiaobo.ma
    Update UE capa    ue_id=91-95    SA_Capa_perUE_Full=${UE_Capa_Support_HRLA_256QAM}    ue_eutra_nr_capabilities=${UE_Eutra_NR_Capabilities}
    UE Attach To Target Cell via NSA    ue_id=91    cell_id=2    bearer_id=2
    UE Attach To Target Cell Two Bear    ue_id=92    cell_id=2    b_id=3    bearer_id=2,3

    Bearer Setup    ue_id=91
    Send And Verify Nsa Throuput    ue_id=91    bearer_id=2    sleep_time=10s    send_dl=50    send_ul=30
    Send And Verify Nsa Throuput    ue_id=92    bearer_id=2    sleep_time=10s    send_dl=50    send_ul=30

    Bearer Release    ue=91    id=3
    Bearer Release    ue=92    id=3
    UE Deregister From eNB     ue_id=91
    UE Deregister From eNB     ue_id=92


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none    ${ue_eutra_nr_capabilities}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Execute Egate Command    ${cmd}

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=4000 gfbr_dl=10000 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6 default=on
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8

    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=2 ue=91 qci=9 pdn=1 ip=4.7.254.209 default=on trf_type=internal
    Update Cfg    set_bearer id=3 ue=91 qci=5 pdn=1
    Update Cfg    set_bearer id=4 ue=91 qci=6 pdn=1
    Update Cfg    set_bearer id=5 ue=91 qci=7 pdn=1
    Update Cfg    set_bearer id=6 ue=91 qci=8 pdn=1
    Update Cfg    set_bearer id=7 ue=91 qci=70 pdn=1
    Update Cfg    set_bearer id=2 ue=92 qci=9 pdn=1 ip=4.7.254.210 default=on trf_type=internal
    Update Cfg    set_bearer id=3 ue=92 qci=5 pdn=1
    Update Cfg    set_bearer id=4 ue=92 qci=6 pdn=1

    ${enb}    Catenate    set_enb id=1 plmn=311:489 s1=10.0.1.121 enb_id_macro=0x12346 daemon=10.0.2.1:22222 x2=10.0.1.12 x2u=10.0.1.136
    ...    type=simulated x2_peers=none
    Update Cfg    ${enb}
    ${gnb2}    Catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 gnb_id=0x2:22 x2=10.0.1.2:36422 x2_peers=none ng=10.0.1.2
    ...    xn=10.0.1.2 amf=1 nssai=0x1:0xd143a5
    Update Cfg    ${gnb2}

UE Attach To Target Cell via NSA
    [Arguments]    ${ue_id}    ${cell_id}    ${bearer_id}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${ret1}=    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=${bearer_id} type=split_scg
    ...     successful
    Should Contain    ${ret1}    mcs-Table qam256
    Should Contain    ${ret1}    cqi-Table table2

UE Attach To Target Cell Two Bear
    [Arguments]    ${ue_id}    ${cell_id}    ${b_id}    ${bearer_id}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    bearer_add ue=${ue_id} id=${b_id} filter=0 precedence=0    PGW-initiated Bearer Creation
    ${ret1}=    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=${bearer_id} type=split_scg
    ...     successful
    Should Contain    ${ret1}    mcs-Table qam64LowSE
    Should Contain    ${ret1}    cqi-Table table1

Bearer Setup
    [Arguments]    ${ue_id}
    Execute Egate Command    bearer_add ue=${ue_id} id=3 filter=0 precedence=0    PGW-initiated Bearer Creation
    ${ret1}=    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=3 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...     Successfully reconfigured dual connectivity
    Should Contain    ${ret1}    cqi-Table table1
    Should Contain    ${ret1}    mcs-Table qam64LowSE

Bearer Release
    [Arguments]    ${ue}    ${id}
    ${cmd}    Set Variable
    ...    enb_ue_dc_modify ue=${ue} bearer_to_release=${id} by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ${ret1}=    Execute Egate Command  ${cmd}
    Should Contain    ${ret1}    cqi-Table table2
    Should Contain    ${ret1}    mcs-Table qam256

UE Deregister From eNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

Send And Verify Nsa Throuput
    [Arguments]    ${ue_id}=91    ${bearer_id}=2    ${sleep_time}=10s    ${send_dl}=10    ${send_ul}=10
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=dl mbps=${send_dl}    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=ul mbps=${send_ul}    UE ${ue_id}: UDP UL
    Verify NSA Throuput    ${ue_id}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}    ${bearer_id}

Verify NSA Throuput
    [Arguments]    ${ue_id}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}    ${bearer_id}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=ul    dc_cell_group=all    rate_type=ave

    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

