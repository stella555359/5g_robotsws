*** Settings ***
Documentation
...    author: Baijie Zhu
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_N41_gnb2_2T2F_AHLOA
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_[LO][LO]_AP_[LOO]
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    6450

#TDD: n41 n78 FDD: n66 n71
#2CC CA_n66A-n71A CA_n41A-n71A CA_n66A-n78A CA_n41A-n78A CA_n41A-n66A CA_n71A-n78A CA_n71(2A)
#3CC CA_n41A-n66A-n71A CA_n41A-n66A-n78A CA_n41A-n66(2A) CA_n41A-n71(2A) CA_n66(2A)-n71A CA_n66A-n71(2A) CA_n66A-n71A-n78A
#delete: n71(2A)-n78a
#${SA_Capa_PerFR_2CC_3CC_N41_N66_N78_N71}
${SA_Capa_perFR_Full}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C
...    790E7D473E618F28581C0E1E0B801FF800E007FE00088000E0541B107582308682041E2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FFF00
...    0007FFC0000044000702A8D89BAC1184341020E90480B2D931543439F11C7A067D813E31CF9863CA16070387817003FF001C00FFC00110001C0A836236B04610D040
...    83E5048092D931541439F11C78C00000000000040E1E04FFF800003FFE00000220003801CF0F10400388C0000002C040BC3C28000E230000010B0102F170A0003882
...    001C46000004160205E2E20800713400385000000C2C040BC3C28000E268000040B0102E0F0A00038820000142C040BC3C41000E230000060B0102F0F10400389A00
...    001C2C040BC5C28000E2080071040000405808178B850001C46000E230000090B0102F17104003882001C46000014160205E2E20800711800388C00002C2C040BC3C
...    46000E2680000C0B0102F1710400388C001C4D00001A16020401C0468051013602086A0AF07428913639F0E14489B1CF871224489B1CF871224489B1CF870A244D8E
...    7C3851226C73E1C28913639F0E14489B1CF871224489B1CF871224489B1CF871224489B1CF871224489B1CF870A244D8E7C38912244D8E7C300150E18C6318C6318C
...    6318DE8260078007038280381804A00E000C0480080C07C010040000000200000401606D654D0041000009652504000065949401503AAA55542401200340A000D080
...    801002020040084040100201002004402008010080100202004008804008010100400804010020808020040200801040401002010020042020040080801002101002
...    004040100210080200402004008080100220100400804008010100200440200400808010020200400880400801010020040400801080801002020080108040080101
...    00200404010021AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

@{SCell1_11_Add}
...    pcid:60, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{SCell1_12_Add}
...    pcid:61, scellIdx:1
...    SCellIndex 1 activated successfully at airphone

@{SCell2_12_Add}
...    pcid:61, scellIdx:2
...    SCellIndex 2 activated successfully at airphone

@{2SCell_Add}
...    pcid:60, scellIdx:1
...    pcid:61, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

${pdu_id}    1
${gw_id}    1

*** Test Cases ***
CB008195-ET-B026_Verify Su SA GBR DRB ad m-cell pooled res check with both maxNumOfGBRL2Pool and maxNumOfDRBL2Pool in D pool when inter gnb HO
    [Documentation]
    ...    1. Config:
    ...    [Configuration]:
    ...       set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on band=n41 chBw=100MHz nr_arfcn=513300:513300 gscn=6480
    ...       set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on band=n41 chBw=40MHz nr_arfcn=510000:510000 gscn=6345
    ...       set_cell id=3 gnb=3 pci=17:1 tac=200 nrci=0x03 tdd_cell=on band=n77 chBw=100MHz nr_arfcn=653400:653400 gscn=8072
    ...       set_cell id=4 gnb=3 pci=17:2 tac=200 nrci=0x04 tdd_cell=on band=n77 chBw=40MHz nr_arfcn=648000:648000 gscn=8000
    ...       set_cell id=11 gnb=3 pci=20:0 tac=200 nrci=0x0B tdd_cell=off band=n71 chBw=10MHz nr_arfcn=134200:125020 gscn=1562
    ...       set_cell id=12 gnb=3 pci=20:1 tac=200 nrci=0x0C tdd_cell=off band=n71 chBw=10MHz nr_arfcn=136620:127420 gscn=1592
    ...       SA UE1: PLMN 1, nwslice 1
    ...       NSA UE31: PLMN 1
    ...       GNB1: maxNumOfRrcConUEsPerDU=60, maxNumOfRrcSA=100, maxNumOfUsersPerCell=100, maxNumOfUsersPerNRCell=100
    ...       Cell1 RG1: minQuota=2, maxQuota=20
    ...       Cell1 RG2: minQuota=10, maxQuota=80
    ...       Cell1 UE Context: RG1 [2,20] RG2 [10,80] (maxNumOfUsersPerNRCell*RGQuota)
    ...       Cell1 DU limit: RG1 [2,12] RG2 [10,48] (maxNumOfRrcConUEsPerDU*RGQuota)
    ...    2. Test Case Steps:
    ...       Step1: UE1 attach to gnb 2 cell1.
    ...       Step2: UE2 attach to gnb 3 cell3 and add scell blindly
    ...       Step3: UE3 attach to gnb 3 cell3 to occupy DU 1 common resource.
    ...    3. Expected Results:
    ...       Step1: UE1 attach successfully.
    ...       Step2: UE2 attach successfully and adds cell11 and cell12 as scells.
    ...              Note: In intra-gnb CA, scell addtion will not increase count of ueContextPerDu
    ...       Step3: UE3 attach to gnb 3 cell3 successfully.
    [Tags]    F008
    Setup X2 Link To gNBs
    Clear Counter Files For 2GNB
    UE SA Attach To Target Cell with traffic    cell_id=1    ue_id=1    nwslice=1    addqosflow=4    dlmbps=10    ulmbps=1
    FOR    ${num}    IN RANGE    0    6
        InterGNB InterFreq HO From GNB1_NRCELL-1 to GNB2_NRCELL-3
        InterGNB InterFreq HO From GNB2_NRCELL-3 to GNB1_NRCELL-1
    END
    Check Counters For 2GNB    PM_Counters_GNB1=${PM_Counters_ET03_GNB1}    PM_Counters_GNB2=${PM_Counters_ET03_GNB2}

*** Keywords ***
Modify Cfg
    Update Cfg Param    set_amf_region id=1 plmn=311:489,311:406,460:002
    Update Cfg Param    set_gnb id=2 plmnList=311:489,311:406,460:002
    Update Cfg Param    set_gnb id=3 plmnList=311:489,311:406,460:002
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=6 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf_region_id=1 plmn_list=311:489,311:406,460:002
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 default=off ue=all amf_region_id=1 plmn_list=311:489,311:406,460:002
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=2000 gfbr_dl=2000 mfbr_ul=20000 mfbr_dl=20000 qos_flow_type=gbr ue=all

Setup X2 Link To gNBs
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up
    Execute Egate Command    enb_x2_link_up enb=1 target=3    is up

SA UE Attach
    [Arguments]    ${ue_id}=1    ${gnb}=2    ${cell_id}=1    ${nwslice_id}=1    ${gw}=1
    BuiltIn.Log    SA UE${ue_id} Attach To Cell${cell_id}...    console=${True}
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perFR_Full}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${gnb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice_id} gw=${gw}    pass_regexp=QoS Routing Table    timeout=20s
    ...    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=1
    ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue:${ue_id}

SA UE Attach Failed
    [Arguments]    ${ue_id}=1    ${gnb}=2    ${cell_id}=1    ${nwslice_id}=1    ${gw}=1
    BuiltIn.Log    SA UE${ue_id} Attach To Cell${cell_id} Failed...    console=${True}
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perFR_Full}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${gnb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice_id} gw=${gw}    pass_regexp=RAN radio resources not available
    ...    timeout=20s    sleep_time=2

UE Attach And Blind Scell Addition
    [Arguments]    ${ue_id}=1    ${gnb}=2    ${cell_id}=1    ${nwslice_id}=1    ${gw}=1    ${Blind_expect}=${SCell1_11_Add}
    BuiltIn.Log    UE${ue_id} Attach To Cell${cell_id} And Blind Scell Addition...    console=${True}
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${CB008950_Capa_5CC_n41_n66_n66_n71_n77}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${gnb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice_id} gw=${gw}    pass_regexp=${blind_expect}    timeout=20s
    ...    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=1
    ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue:${ue_id}

UE Send A1 To Trigger Scell Addition Failed
    [Arguments]    ${ue_id}=1
    BuiltIn.Log    SA UE${ue_id} Send A1 To Trigger Scell Addition Fail...    console=${True}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=518430    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    fail_regexp=SCellIndex .* activated successfully at airphone    timeout=20s    sleep_time=2

UE Send A1 To Trigger Scell Addition
    [Arguments]    ${ue_id}=1    ${A1_expect}=${2SCell_Add}
    BuiltIn.Log    SA UE${ue_id} Send A1 To Trigger Scell Addition...    console=${True}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=518430    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${A1_expect}    timeout=20s    sleep_time=2

NSA UE Attach And Setup ENDC
    [Arguments]    ${ue_id}=31    ${target_gnb}=2    ${target_cells}=11
    NSA UE Attach    ue_id=${ue_id}
    NSA UE Setup ENDC    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}

NSA UE Attach And Setup ENDC Failed
    [Arguments]    ${ue_id}=31    ${target_gnb}=2    ${target_cells}=11
    NSA UE Attach    ue_id=${ue_id}
    NSA UE Setup ENDC Failed    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}

NSA UE Attach
    [Arguments]    ${ue_id}=31
    BuiltIn.Log    NSA UE${ue_id} Attach...    console=${True}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

NSA UE Setup ENDC
    [Arguments]    ${ue_id}=31    ${target_gnb}=2    ${target_cells}=11
    BuiltIn.Log    NSA UE${ue_id} Setup ENDC To Cell${target_cells}...    console=${True}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=2 type=split_scg
    ...    UE${ue_id}: Proxy \\(eNB ${target_gnb} cell ${target_cells}\\) reported successful RA    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl trf_id=1 mbps=1
    ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue:${ue_id}

NSA UE Setup ENDC Failed
    [Arguments]    ${ue_id}=31    ${target_gnb}=2    ${target_cells}=11
    BuiltIn.Log    NSA UE Setup ENDC To Cell${target_cells} Failed...    console=${True}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=2 type=split_scg
    ...    no-radio-resources-available    sleep_time=2

Clear Counter Files For 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files BTS2

Check Counters For 2GNB
    [Arguments]    ${PM_Counters_GNB1}=${PM_Counters_F006_GNB1}    ${PM_Counters_GNB2}=${PM_Counters_F006_GNB2}
    BuiltIn.Log    Check Counters For GNB1...    console=${True}
    Run Keyword And Continue On Failure    Check Counters    ${PM_Counters_GNB1}
    BuiltIn.Log    Check Counters For GNB2...    console=${True}
    Check Counters BTS2    ${PM_Counters_GNB2}

UE SA Attach To Target Cell with traffic
    [Arguments]    ${cell_id}=1    ${ue_id}=1    ${pcell_dl}=0    ${nwslice}=1    ${addqosflow}=4    ${dlmbps}=50    ${ulmbps}=10
#    ${Set_AMF_Send_CNAI_In_UE_ICS}    catenate
#    ...    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
#    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
#    Execute Egate Command    ${Set_AMF_Send_CNAI_In_UE_ICS}
    Execute Egate Command    amf_mobility_restriction_list_param id=1 equiv_plmn=311:406 sa_plmn=311:489
    Execute Egate Command    amf_ue_ics_param id=1 ue=all mobility_restriction_list_id=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perFR_Full}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${addqosflow}
    Send Throuput    ue_id=${ue_id}   dlmbps=${dlmbps}    ulmbps=${ulmbps}
    Verify Throuput on Pcell    pcell_dl=${pcell_dl}

Send Throuput
    [Arguments]    ${ue_id}=1    ${dlmbps}=150    ${ulmbps}=20
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=2 dir=dl mbps=${dlmbps} trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=2 dir=ul mbps=${ulmbps} trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=1    ${pcell_dl}=60    ${ul}=0    ${qfi}=2
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pdsch
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Trigger InterGNB InterFreq HO and back ten Times
    FOR    ${num}    IN RANGE    0    4
        InterGNB InterFreq HO From GNB1_NRCELL-1 to GNB2_NRCELL-3
        InterGNB InterFreq HO From GNB2_NRCELL-3 to GNB1_NRCELL-1
    END

InterGNB InterFreq HO From GNB1_NRCELL-1 to GNB2_NRCELL-3
    [Arguments]    ${ue_id}=1
        ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=518430    event_type=A2
        Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=25
        ...    pass_regexp=rrcReconfigurationComplete
        ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=125050    event_type=A3
        ${a3_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=55
        ...    phycell_id=60 nrsrp_nr=80
        Execute Egate Command    ${a3_cmd}    pass_regexp=Inter-eNB handover from EXT_ENB

InterGNB InterFreq HO From GNB2_NRCELL-3 to GNB1_NRCELL-1
    [Arguments]    ${ue_id}=1
        ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=125050    event_type=A2
        Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=25
        ...    pass_regexp=rrcReconfigurationComplete
        ${measid}    get nr meas id for specific type and frequency    ue_id=${ue_id}    carrierfreq=518430    event_type=A3
        ${a3_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=55
        ...    phycell_id=50 nrsrp_nr=80
        Execute Egate Command    ${a3_cmd}    pass_regexp=Inter-eNB handover from EXT_ENB
