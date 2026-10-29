*** Settings ***
Documentation
...    author:  keyun ma
...    contact: keyun.ma@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_N41_gnb2_2T2F_AHLOA
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_[LO][LO]_AP_[LOO]
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${TTITRACE_FLAG}    ${True}
${GNB_BIP_FLAG}    ${True}
${GNB_BIP_SIZE}    5000
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

#SYSLOG output severity prints (0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable)
@{PARAMS_IN_SWCONFIG}    0x1003F=1    0x10040=1    0x10041=1    0x1002A=1    0x4F0214=0    0x590072=1    0x66001b=1
...    0x890001=0    0x890002=0    0x890003=1    0x890004=1    0x890005=0    0x890006=0    0x890008=0    0x57000B = 0xFFFFFFFF
#"0x1003F=1"   # ERadCcs_AaSysLogInputLevel,0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
#"0x10040=1"   # ERadCcs_AaSysLogOutputLevel
#"0x10041=1"   # OutputMode,0=none 1=all 2=udp 3=sic 4=standard output 5=local 6=remote 7=not valid
#"0x1002A=1"   # EMIL, AaTrace used flag:0=not used, 1=used, 2=used only (ignore configuration messages)
#"0x4F0214=0"  # ignore HWF file information in gNB
#"0x590072=1"  # CP_RT
#"0x66001b=1"  # CP_NRT
#"0x890001=0"  # CP_NB log level
#"0x890002=0"  # CP_SB log level
#"0x890003=1"  # CP_UE log level
#"0x890004=1"  # CP_CL log level
#"0x890005=0"  # CP_IF log level
#"0x890006=0"  # CP_SCTP log level
#"0x890008=0"  # CP_E2 log level

@{FAULTS_EXCLUDED_CHECKING}
...    6450

#TDD: n41 n78  FDD: n66 n71
#2CC CA_n66A-n71A CA_n41A-n71A CA_n66A-n78A CA_n41A-n78A CA_n41A-n66A CA_n71A-n78A  CA_n71(2A)
#3CC CA_n41A-n66A-n71A CA_n41A-n66A-n78A CA_n41A-n66(2A) CA_n41A-n71(2A) CA_n66(2A)-n71A  CA_n66A-n71(2A) CA_n66A-n71A-n78A
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

@{A1_expect}
...    pcid:60, scellIdx:1
...    pcid:61, scellIdx:2
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

${DELTA_PARAS_FOR_GNB3}
...    NRBTS:actSliceAwareAdmissionCtrl=true
${DELTA_PARAS_1_FOR_GNB3}
...    NRBTS:actSliceAwareAdmissionCtrl=false

*** Test Cases ***
CB008195-ET-F005_E001_Verify_succesful_inter_gNB_SCell_Addition_in_case_static_cell_limits_check_resources_are_assigned_within_common_pool
    [Documentation]
    ...    1. Config:
    ...       set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01  tdd_cell=on  band=n41 chBw=100MHz nr_arfcn=513300:513300 gscn=6480
    ...       set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02  tdd_cell=on  band=n41 chBw=40MHz  nr_arfcn=510000:510000 gscn=6345
    ...       set_cell id=3 gnb=3 pci=17:1 tac=200 nrci=0x03  tdd_cell=on  band=n77 chBw=100MHz nr_arfcn=653400:653400 gscn=8072
    ...       set_cell id=4 gnb=3 pci=17:2 tac=200 nrci=0x04  tdd_cell=on  band=n77 chBw=40MHz  nr_arfcn=648000:648000 gscn=8000
    ...       set_cell id=11 gnb=3 pci=20:0 tac=200 nrci=0x0B tdd_cell=off band=n71 chBw=10MHz  nr_arfcn=134200:125020 gscn=1562
    ...       set_cell id=12 gnb=3 pci=20:1 tac=200 nrci=0x0C tdd_cell=off band=n71 chBw=10MHz  nr_arfcn=136620:127420 gscn=1592
    ...       note: full commission with NRBTS:actSliceAwareAdmissionCtrl=false
    ...    2. Test Case Steps:
    ...       Step1: ue1 attach to cell-1 succeed ( one RG2 dedicated resource in CELL-1)
    ...       Step2: Trigger Scell Addition by A1 for ue1, SCELL-11+SCELL-12(one RG2 common resource in CELL-11+CELL-12)
    ...       Step3: online change NRBTS:actSliceAwareAdmissionCtrl=true
    ...       Step4: ue2 attach to cell-12 failed ( no resource 10-7-1-1-1=0)
    ...       Step5: online change NRBTS:actSliceAwareAdmissionCtrl=false
    ...       Step6: ue2 attach to cell-12 succeed
    ...       Step7: ue3 without pdu attach to cell-12 succeed
    ...       Step8: online change NRBTS:actSliceAwareAdmissionCtrl=true
    ...       Step9: ue4 attach to cell-1 succeed ( one RG1 dedicated resource in CELL-1)
    ...       Step10: Trigger Scell Addition by A1 for ue3, SCELL-11+SCELL-12(one RG1 dedicated resource in CELL-11+CELL-12)
    ...    3. Expected Results:
    [Tags]    F005    E001
    Setup X2 Link To gNBs
    Clear Counter Files BTS2
    SA UE Attach    ue_id=1    gnb=2    cell_id=1    nwslice=2
    UE Send A1 To Trigger Scell Addition    ue_id=1
    Delta Commission Parameters BTS2    ${DELTA_PARAS_FOR_GNB3}
    SA UE Attach Failed    ue_id=2    gnb=3    cell_id=12    nwslice=2
    Delta Commission Parameters BTS2    ${DELTA_PARAS_1_FOR_GNB3}
    SA UE Attach again   ue_id=2    gnb=3    cell_id=12    nwslice=2
    SA UE Attach without PDU    ue_id=3    gnb=3    cell_id=12
    Delta Commission Parameters BTS2    ${DELTA_PARAS_FOR_GNB3}
    Pdu setup for UE    ue_id=3    nwslice=3
    SA UE Attach    ue_id=4    gnb=2    cell_id=1    nwslice=3
    UE Send A1 To Trigger Scell Addition Failed    ue_id=4
    Release UEs    ue_type=all
    Check Counters BTS2    ${PM_Counters_Check_ET_F005}    wait=true

*** Keywords ***
Setup Xn and all links and Cells On Air
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up
    Execute Egate Command    enb_x2_link_up enb=1 target=3    is up
    Wait Until Keyword Succeeds    20 min    10 sec    All link avaiable and Cells on air

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=all amf=1

Setup X2 Link To gNBs
    Execute Egate Command    enb_x2_link_up enb=1 target=2    is up
    Execute Egate Command    enb_x2_link_up enb=1 target=3    is up

SA UE Attach
    [Arguments]    ${ue_id}=1    ${gnb}=2    ${cell_id}=1    ${nwslice}=2    ${gw}=1
    BuiltIn.Log    SA UE${ue_id} Attach...    console=${True}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${gnb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gw}
    ...    pass_regexp=QoS Routing Table    timeout=20s


SA UE Attach without PDU
    [Arguments]    ${ue_id}=1    ${gnb}=2    ${cell_id}=1
    BuiltIn.Log    SA UE${ue_id} Attach...    console=${True}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${gnb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE

Pdu setup for UE
    [Arguments]    ${ue_id}=1    ${nwslice}=2
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=1
    ...    pass_regexp=cause RAN radio resources not available    timeout=20s

SA UE Attach again
    [Arguments]    ${ue_id}=1    ${gnb}=2    ${cell_id}=1    ${nwslice}=2    ${gw}=1
    BuiltIn.Log    SA UE${ue_id} Attach...    console=${True}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    Execute Egate Command    ue_change_location id=${ue_id} enb=${gnb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gw}
    ...    pass_regexp=QoS Routing Table    timeout=20s
SA UE Attach Failed
    [Arguments]    ${ue_id}=1    ${gnb}=2    ${cell_id}=1    ${nwslice}=2    ${gw}=1
    BuiltIn.Log    SA UE${ue_id} Attach...    console=${True}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${gnb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gw}
    ...    pass_regexp=cause RAN radio resources not available

UE Send A1 To Trigger Scell Addition Fail
    [Arguments]    ${ue_id}=1
    BuiltIn.Log    SA UE${ue_id} Send A1 To Trigger Scell Addition Fail...    console=${True}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=518430    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    fail_regexp=SCellIndex 1 activated successfully at airphone    timeout=20s

UE Send A1 To Trigger Scell Addition
    [Arguments]    ${ue_id}=1
    BuiltIn.Log    SA UE${ue_id} Send A1 To Trigger Scell Addition...    console=${True}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=518430    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${A1_expect}    timeout=20s

UE Send A1 To Trigger Scell Addition Failed
    [Arguments]    ${ue_id}=1
    BuiltIn.Log    SA UE${ue_id} Send A1 To Trigger Scell Addition...    console=${True}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=518430    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    fail_regexp=${A1_expect}    timeout=20s

