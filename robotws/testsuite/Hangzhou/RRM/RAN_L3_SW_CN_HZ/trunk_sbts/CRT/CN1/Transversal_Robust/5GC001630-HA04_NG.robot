*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    team-PZ3_7
...    owner-jun.15.zhang    release-5G20A    5GC001630
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{RanSharing_HO}    @{NRADJGNB}    @{NRADJNRCELL}    @{NRREL}    @{NRHOIF}    @{XNLINK}
...    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}    @{Others}

@{RanSharing_HO}
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000
...    NRBTS:suppCnPartialAdNgHo=true
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=5
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=20
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms100
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=5
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=60
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRCELL:measGapSelectionSA=favourUeThroughput

@{NRADJGNB}
...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNodeBId=35
...    NRADJGNB-3:gNbIdLength=22
...    delete:NRADJGNB-3:xnLinkRef
...    NRADJGNB-3:gnbPlmn:mcc=311
...    NRADJGNB-3:gnbPlmn:mnc=402
...    NRADJGNB-3:gnbPlmn:mncLength=3
...    NRADJGNB-5:administrativeState=Unlocked
...    NRADJGNB-5:gNodeBId=36
...    NRADJGNB-5:gNbIdLength=22
...    NRADJGNB-5:xnLinkRef=5
...    NRADJGNB-5:gnbPlmn:mcc=311
...    NRADJGNB-5:gnbPlmn:mnc=403
...    NRADJGNB-5:gnbPlmn:mncLength=3

@{NRADJNRCELL}
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=402
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:fiveGsTac=0
...    NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_2}
...    NRADJNRCELL-2:cellDepType=SA
...    NRADJNRCELL-2:gNbId=36
...    NRADJNRCELL-2:lcrId=2
...    NRADJNRCELL-2:nrarfcn=648000
...    NRADJNRCELL-2:physCellId=48
...    NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRADJNRCELL-2:gnbPlmn:mnc=403
...    NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:fiveGsTac=0
...    NRADJNRCELL-2/ADJ_NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_3}

@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=402
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:gNbId=36
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=403
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:handoverAllowedSA=XnHoNotAllowed

@{NRHOIF}
...    NRCELL/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL/NRHOIF-1:cellDepType=SA
...    NRCELL/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRCELL/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-1:ssbFrequency=648096
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

@{XNLINK}
...    XNLINK-5:cPlaneIpAddr=10.0.1.124

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3
...    NRPLMN-3:mcc=311
...    NRPLMN-3:mnc=403
...    NRPLMN-3:mncLength=3

@{NRPLMNSET_SA_NSA}
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST_1}

@{SNSSAI}
...    delete:SNSSAI-1:sd
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST_1}

@{TRACKINGAREA}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

@{Others}
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled

${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1
${NRPLMNDNLIST_2}    MRBTS-1/NRBTS-1/NRPLMN-2
${NRPLMNDNLIST_3}    MRBTS-1/NRBTS-1/NRPLMN-3

${NG_HO_PREP_ATT_SRC_IEF}    M55125C07501
${NG_HO_PREP_ATT_SRC_IAF}    M55125C07502
${NG_HO_RES_ALC_ATT_TRG}    M55125C07503
${NG_HO_RES_ALC_SUCC_TRG}    M55125C07504
${NG_HO_PREP_SUCC_SRC}    M55125C07512
${NG_HO_EXEC_ATT_SRC_IEF}    M55125C07513
${NG_HO_EXEC_ATT_SRC_IAF}    M55125C07514
${NG_HO_EXEC_NOTIFY_TRG}    M55125C07520
${NG_HO_EXEC_SUCC_SRC_IEF}    M55125C07522
${NG_HO_EXEC_SUCC_SRC_IAF}    M55125C07523

@{NG_HO_Counters}
...    NRCELL-1:${NG_HO_PREP_ATT_SRC_IEF}=1
...    NRCELL-1:${NG_HO_PREP_ATT_SRC_IAF}=2
...    NRCELL-1:${NG_HO_PREP_SUCC_SRC}=3
...    NRCELL-1:${NG_HO_EXEC_ATT_SRC_IEF}=1
...    NRCELL-1:${NG_HO_EXEC_ATT_SRC_IAF}=2
...    NRCELL-1:${NG_HO_EXEC_SUCC_SRC_IEF}=1
...    NRCELL-1:${NG_HO_EXEC_SUCC_SRC_IAF}=2
...    NRCELL-2:${NG_HO_EXEC_NOTIFY_TRG}=5
...    NRCELL-2:${NG_HO_RES_ALC_ATT_TRG}=5
...    NRCELL-2:${NG_HO_RES_ALC_SUCC_TRG}=5

#Capa from trunk\2GNB_LO_AP_LO_CONF\fddtdd_sansa_cmwv\6cells_gnb1_2T_gnb2_2T2F
${UE_Capa}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482C036B64C558D0E7C471E819F604F8C48E3C873EA3
...    9F30C7942C0E070F05C00FFC0070005F000540001C0A836016B04610D04083C4160195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F6000000540
...    001C0AA36266B04610D04083A4160185B262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8002A0000E0541B06F582308682041E20B00CAD9315624
...    39F11C7B027C62471E439F51CF9863CA1607038784FFF800003FFE000002A0000E0551B137582308680000100B00C2D926544439F11C79063D033EC09F00E7CC31E50B0381C3
...    C17AAAAAAA9EAAAAAAA1500007004961E26000713000000058158B898001C4C000E260000010B02B17008003098061300004160563E01000606C0C260184C0001858158B8040
...    018020303600040B02B1F00800300C0606C0C26800142C0AC5C02000C0D8184C0003058158780400184C000385815878040018020004058158783600181B0004858158780400
...    18060005058158780C00181B0005858158B80400180603036000C0B02B0F06C0038980000342C0AC5C4C000C26018020007058158F89800184C030040606C001E160562E2600
...    060080C0D800402C0AC7C4D000C01018060303600110B0201200DC0068099000A02688A03A4250A244D8E7C38912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF
...    871A2448913639F0E2448913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A244D8E7C38912244D8E7C38D1224489B1CF8712
...    24489B1CF871A2448913639F0C06C486318C6318C6318C6318C6307A09801E00140E0A00E0601280380030120020301F04801000000008004000000100000600800001004000
...    0100200000C01000008008000050040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14A
...    C0CAC19AC15ACA5BC99BC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29302000032CA48080001CB29202000092CA48080002CB293020000D2CA48080003CB292020001
...    12CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A0
...    5028140A05028140A05028140A05028140A050011080801002020040088040080101002004040080110080600A02004008080100230100C01404030050100200404008011008
...    0800A02020028080B01630100C01804030050100C018040080110080600A02018028080100210100C014040080108080600A02018028404030060100C018202018030080600A
...    10100C014040300510080600A02018030080600A10100C018040080110080100202004008080600A30100200404008010100C014040300510080100202018030080600C30100
...    200404030050100C01804030051AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

*** Test Cases ***
5GC001630-ET-HA04_Verify_Successful_inter-gNB_HO_for_SA_user_in_shared_gNB_with_PLMN_change_IWK_NG_HO
    [Documentation]
    ...    1. UE with standard slice can trigger inter-gnb HO to different PLMN CELL no matter MRL
    ...    2. AMF1: TAC200, PLMN1 SNSSAI-1, PLMN2 SNSSAI-1, PLMN3 SNSSAI-1
    ...       TAC200: SNSSAI-1
    ...       SNSSAI-1: PLMN1, standard slice
    ...       real gNB2 CELL1: PLMN1 SNSSAI-1
    ...       sim gNB3 CELL1: PLMN2 SNSSAI-1
    ...       sim gNB5 CELL2: PLMN3 SNSSAI-1
    ...       UE1/UE2/UE3: PLMN1
    ...       UE4: PLMN2
    ...       UE5: PLMN3
    ...    3. Test Case Steps:
    ...       a. UE1/UE2/UE3 register on real gnb cell1; do traffic
    ...       b. UE1 HO from real gNB to sim gNB3 Cell1 trigger by A3
    ...       c. UE2 HO from real gNB to sim gNB3 Cell1 trigger by A5
    ...       d. UE3 HO from real gNB to sim gNB5 Cell2 trigger by A2/A3
    ...       e. UE4 HO from sim gNB3 to real gNB Cell2 trigger by A3
    ...       f. UE5 HO from sim gNB5 to real gNB Cell2 trigger by A2/A3
    ...    4. Expected Results:
    ...       a. UEs register successful and traffic should be ok
    ...       b. UE1 trigger different PLMN CELL intra Freq NG HO due to no XN link and HO back, update the relevant counter
    ...       c. UE2 trigger different PLMN CELL intra Freq NG HO due to no XN link and HO back, update the relevant counter
    ...       d. UE3 trigger different PLMN CELL inter Freq NG HO due to XN link HO not allowed and HO back, update the relevant counter
    ...       e. UE4 trigger different PLMN CELL intra Freq NG HO due to no XN link, update the relevant counter
    ...       f. UE5 trigger different PLMN CELL inter Freq NG HO due to XN link HO not allowed, update the relevant counter
    [Tags]    QC_47193
    Check XN Link To Sim GNB5 Is UP
    Clear Counter Files    wait=${False}
    UE Attach And Waiting L3 Call OK    ue_id=1
    UE Trigger Intra-Frequency Inter-gnb HO To Sim gNB3 Cell1    ue_id=1    event_type=A3
    UE Trigger Intra-Frequency Inter-gnb HO To Real gNB2 Cell2 By A3    ue_id=1
    UE Attach And Waiting L3 Call OK    ue_id=2
    UE Trigger Intra-Frequency Inter-gnb HO To Sim gNB3 Cell1    ue_id=2    event_type=A5
    UE Trigger Intra-Frequency Inter-gnb HO To Real gNB2 Cell2 By A3    ue_id=2
    UE Attach And Waiting L3 Call OK    ue_id=3
    UE Trigger Inter-Frequency Inter-gnb HO To Sim gNB5 Cell2    ue_id=3
    UE Trigger Inter-Frequency Inter-gnb HO To Real gNB2 Cell2    ue_id=3
    Add UE History Information List
    UE Attach And Waiting L3 Call OK    ue_id=4
    UE Trigger Intra-Frequency Inter-gnb HO To Real gNB2 Cell2 By A3    ue_id=4
    UE Attach And Waiting L3 Call OK    ue_id=5
    UE Trigger Inter-Frequency Inter-gnb HO To Real gNB2 Cell2    ue_id=5
    Release Ues    ue_type=all
    Check Counters    ${NG_HO_Counters}

*** Keywords ***
Modify Cfg
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:402 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.122 nssai=0x1:0xFFFFFF amf=1 plmnList=311:402
    Update Cfg    ${set_gnb3}
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:403 ng=10.0.1.125 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xFFFFFF amf=1 plmnList=311:403
    Update Cfg    ${set_gnb5}
    ${set_gnb5_cell2}    catenate    set_cell id=2 gnb=5 pci=16:0 tac=0 nrci=0x02 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=648000:648000
    ...    gscn=8000 mandatory_for_activation=off
    Update Cfg    ${set_gnb5_cell2}
    Update Cfg    gnb_make_plmnset plmn_set_id=1 dual_conn=off gnb=3 cell=1 tac=0 plmn_id_list=311:402
    Update Cfg    gnb_set_nwslice_per_plmn gnb=3 cell=1 plmn_set_id=1 plmn=311:402 nssai=0x01:0xFFFFFF
    Update Cfg    gnb_make_plmnset plmn_set_id=2 dual_conn=off gnb=5 cell=2 tac=0 plmn_id_list=311:403
    Update Cfg    gnb_set_nwslice_per_plmn gnb=5 cell=2 plmn_set_id=2 plmn=311:403 nssai=0x01:0xFFFFFF
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false sib1_period=40 measEvent=A3 sa_ho=ng_based
    Update Cfg    gnb_param id=5 xn_listening_socket=on send_xn_setup=false sib1_period=160 sa_ho=ng_based
    ${set_ue4}    catenate    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F 
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645403 
    ...    mode=nr enb=3 cell=1
    Update Cfg    ${set_ue4}
    ${set_ue5}    catenate    set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:403:0000:0:0:021645404
    ...    mode=nr enb=5 cell=2
    Update Cfg    ${set_ue5}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${UE_Capa}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${UE_Capa}
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489,311:402,311:403
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF amf=1 default=on ue=all

Check XN Link To Sim GNB5 Is UP
    object should exist    XNLINK-5:xnLinkStatus=available

Add UE History Information List
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:402|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=1 action=commit    committed
    Execute Egate Command    ue_enb_param id=4 ue_history_list=1
    Execute Egate Command    ue_history_information_list_add_ngran id=2 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=2 cell_type=large nrcgi=311:403|0x02 gnb_id=5 time_ue_stayed_in_cell=99
    Execute Egate Command    ue_history_information_list id=2 action=commit    committed
    Execute Egate Command    ue_enb_param id=5 ue_history_list=2

UE Attach And Waiting L3 Call OK
    [Arguments]    ${ue_id}=1
    SA UE Register And PDU Setup    ue_id=${ue_id}
    Traffic Should Be OK    ue_id=${ue_id}    type=sa

SA UE Register And PDU Setup
    [Arguments]    ${ue_id}=1    ${enb_id}=2    ${cell_id}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    #Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${ue_id}    QoS Routing Table

UE Trigger Intra-Frequency Inter-gnb HO To Sim gNB3 Cell1
    [Arguments]    ${ue_id}=1    ${source_carrierfreq}=636576    ${event_type}=A3
    BuiltIn.Log    UE${ue_id} Trigger Intra-Frequency Inter-gnb HO To sim gnb Cell1...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${source_carrierfreq}    event_type=${event_type}
    ${cmd_HO}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=${event_type} srsrp_nr=25 phycell_id=381 nrsrp_nr=85
    Execute Egate Command    ${cmd_HO}    pass_regexp=Inter-eNB handover from EXT_ENB-2.* to ENB-3.* performed

UE Trigger Inter-Frequency Inter-gnb HO To Sim gNB5 Cell2
    [Arguments]    ${ue_id}=1    ${source_carrierfreq}=636576    ${target_carrierfreq}=648096
    BuiltIn.Log    UE${ue_id} Trigger Intra-Frequency Inter-gnb HO To sim gnb Cell1...    console=${True}
    Trigger UE With A2 Measurement Report    ue_id=${ue_id}    carrierfreq=${source_carrierfreq}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${target_carrierfreq}    event_type=A3
    ${cmd_HO}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=48 nrsrp_nr=80
    Execute Egate Command    ${cmd_HO}    pass_regexp=Inter-eNB handover from EXT_ENB-2.* to ENB-5.* performed

Trigger UE With A2 Measurement Report
    [Arguments]    ${ue_id}=1    ${carrierfreq}=636576
    BuiltIn.Log    UE${ue_id} Send A2 Measurement Report...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfiguration    timeout=20s

UE Trigger Intra-Frequency Inter-gnb HO To Real gNB2 Cell2 By A3
    [Arguments]    ${ue_id}=1    ${source_carrierfreq}=636576
    BuiltIn.Log    UE${ue_id} Trigger Intra-Frequency Inter-gnb HO To Real gNB2 Cell1 By A3...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${source_carrierfreq}    event_type=A3
    ${cmd_HO}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A3 srsrp_nr=25 phycell_id=51 nrsrp_nr=85
    Execute Egate Command    ${cmd_HO}    pass_regexp=Inter-eNB handover from ENB-3.* to EXT_ENB-2.* performed

UE Trigger Inter-Frequency Inter-gnb HO To Real gNB2 Cell2
    [Arguments]    ${ue_id}=1    ${source_carrierfreq}=648096    ${target_carrierfreq}=636576
    BuiltIn.Log    UE${ue_id} Trigger Inter-Frequency Inter-gnb HO To Real gNB2 Cell1...    console=${True}
    Trigger UE With A2 Measurement Report    ue_id=${ue_id}    carrierfreq=${source_carrierfreq}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${target_carrierfreq}    event_type=A3
    ${cmd_HO}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80
    Execute Egate Command    ${cmd_HO}    pass_regexp=Inter-eNB handover from ENB-5.* to EXT_ENB-2.* performed
