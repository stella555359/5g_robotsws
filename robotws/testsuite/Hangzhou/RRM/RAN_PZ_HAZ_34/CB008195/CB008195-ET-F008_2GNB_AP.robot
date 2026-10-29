*** Settings ***
Documentation
...    author: Susana Yan
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup 2Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_gnb1_2T_N41_gnb2_2T2F_AHLOA
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_[LO][LO]_AP_[LOO]
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    6450
${PM_COUNTER_INTERVAL}    15min
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

*** Test Cases ***
CB008195-ET-F008_Verify unsuccessful inter-gnb SCell Addition
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
    ...       GNB2: maxNumOfRrcConUEsPerDU=40, maxNumOfRrcSA=100, maxNumOfUsersPerCell=100, maxNumOfUsersPerNRCell=100
    ...       TDD RG1: minQuota=2, maxQuota=20
    ...       TDD RG2: minQuota=10, maxQuota=80
    ...       FDD RG1: minQuota=1, maxQuota=40
    ...       FDD RG2: minQuota=20, maxQuota=60
    ...       Cell3 UE Context: RG1 [2,20] RG2 [10,80] (maxNumOfUsersPerNRCell*RGQuota)
    ...       Cell11 UE Context: RG1 [1,40] RG2 [20,60] (maxNumOfUsersPerNRCell*RGQuota)
    ...       Cell12 UE Context: RG1 [1,40] RG2 [20,60] (maxNumOfUsersPerNRCell*RGQuota)
    ...       SUM(Cell_minQuota)=2+10+1+20+1+20=54 >maxNumOfRrcConUEsPerDU
    ...       Scaling factor=maxNumOfRrcConUEsPerDU40/SUM(Cell_minQuota)54=0.740
    ...       Cell3: 2+10=12    ==>2*0.740=1    10*0.740=7    ==>UE count RG1 [1,4] RG2 [7, 11]
    ...       Cell11: 1+20=21    ==>1*0.740=0    20**0.740=14    ==>UE count RG1 [0,4] RG2 [14,18]
    ...       Cell12: 1+20=21    ==>1*0.740=0    20**0.740=14    ==>UE count RG1 [0,4] RG2 [14,18]
    ...       COMMON=maxNumOfRrcConUEsPerDU40-1-7-0-14-0-14=4
    ...    2. Test Case Steps:
    ...       Step1: UE1 attach to gnb 2 cell1.
    ...       Step2: UE2 attach to gnb 3 cell3 and add scell blindly
    ...       Step3: UE3 attach to gnb 3 cell3 to occupy DU 1 common resource.
    ...       Step4: UE31 attach to gnb 3 cell11 to occupy DU 1 common resource.
    ...       Step5: UE1 trigger A1 scell addition to occupy DU 1 common resource.
    ...       Step6: UE4 attach to gnb 3 cell11.
    ...       Step7: UE6 attach to gnb 2 cell1.
    ...       Step8: UE6 trigger A1 scell addition to occupy DU 1 common resource.
    ...       Step9: UE5 attach to gnb 3 cell11.
    ...       Step10: Release UE5 and Online modify to remove RG resource of SNSSAI-1 for Profile2
    ...       Step11: UE5 reattach to gnb 3 cell11.
    ...       Step12: Online modify to add RG resource of SNSSAI-1 for Profile2 to RG1.
    ...       Step13: NSA UE32 attach to gnb 3 cell12.
    ...       Step14: Check counter when bypassRgLimits is disabled.
    ...       Step15: Online Change bypassRgLimits to 1 (UE context resources)
    ...       Step16: UE33 attach to gnb 3 cell11.
    ...       Step17: UE7 attach to gnb2 cell1 and trigger A1 scell addition
    ...       Step18: UE8 attach to gnb3 cell3 and trigger blind scell addition
    ...    3. Expected Results:
    ...       Step1: UE1 attach successfully.
    ...       Step2: UE2 attach successfully and adds cell11 and cell12 as scells.
    ...              Note: In intra-gnb CA, scell addtion will not increase count of ueContextPerDu
    ...       Step3: UE3 attach to gnb 3 cell3 successfully.
    ...       Step4: UE31 attach to gnb 3 cell11 successfully.
    ...       Step5: UE1 add cell11 and cell12 as scells successfully.
    ...       Step6: UE4 attach to gnb 3 cell11 successfully.
    ...       Step7: UE6 attach successfully.
    ...       Step8: UE6 fail to add cell11 and cell12 as scells due to run out of DU common resource.
    ...       Step9: UE5 attach to gnb 3 cell11 failed due to run out of DU common resource.
    ...       Step10: Release UE5 successfully.
    ...               not: After SNSSAI-1 remove, the resource would go to default RG2 for SA PLMN-1
    ...       Step11: UE5 reattach to gnb 3 cell11 successfully.
    ...       Step12: Online modify success.
    ...       Step13: NSA UE31 attach to gnb 3 cell12 failed due to run out of DU common resource.
    ...       Step14: UEs release successfully.
    ...       Step11: UE5 reattach to gnb 3 cell11 successfully.
    ...       Step12: Online modify success.
    ...       Step13: NSA UE31 attach to gnb 3 cell12 failed due to run out of DU common resource.
    ...       Step14: Counter as expected.
    ...       Step15: Online Change successfully.
    ...       Step16: UE33 attach to gnb 3 cell11 successfully.
    ...       Step17: UE7 attach to gnb2 cell1 successfylly, and scell 3_11, 3_12 add successfully.
    ...       Step18: UE8 attach to gnb3 cell3 and scell 3_11 add successfully.
    [Tags]    F008    E006    E007    J019    J021
    Setup X2 Link To gNBs
    Clear Counter Files For 2GNB
#    GNB3 cell11 attach/scell addition fail check failure as DU maxquota exceed.
    SA UE Attach    ue_id=1    gnb=2    cell_id=1
    UE Attach And Blind Scell Addition    ue_id=2    gnb=3    cell_id=3    Blind_expect=${SCell1_11_Add}      #DU Cell1_used1
    SA UE Attach    ue_id=3    gnb=3    cell_id=11                                                            #DU Cell11_used1(COMMON)
    NSA UE Attach And Setup ENDC    ue_id=31    target_gnb=3    target_cells=11                               #DU Cell11_used2(COMMON)
    UE Send A1 To Trigger Scell Addition    ue_id=1    A1_expect=${2SCell_Add}                                #DU Cell11_used3(COMMON)
    SA UE Attach    ue_id=4    gnb=3    cell_id=11                                                            #DU Cell11_used4(COMMON)
    SA UE Attach    ue_id=6    gnb=2    cell_id=1
    UE Send A1 To Trigger Scell Addition Failed    ue_id=6                                                    #RG1 COMMON_no_resource, no scell add
    SA UE Attach Failed    ue_id=5    gnb=3    cell_id=11                                                     #RG1 COMMON_no_resource, attach fail
    Release UEs    ue_type=sa    ue_id=5
    Delta Commission Parameters BTS2    ${DELTA_PARAS_RemoveRGNetworkResource}
    SA UE Attach    ue_id=5    gnb=3    cell_id=11                                                            #default RG2 assign with avail resource
    Delta Commission Parameters BTS2    ${DELTA_PARAS_AddRGNetworkResource}
    NSA UE Attach And Setup ENDC Failed    ue_id=32    target_gnb=3    target_cells=12                        #RG1 COMMON_no_resource, attach fail
    Check Counters For 2GNB    PM_Counters_GNB1=${PM_disable_bypassRgLimits_GNB1}    PM_Counters_GNB2=${PM_disable_bypassRgLimits_GNB2}
#    GNB3 cell11 attach/scell addition success as bypassRgLimits for UE context.
    Online Change bypassRgLimits to UE context resources
    NSA UE Attach And Setup ENDC     ue_id=33    target_gnb=3    target_cells=12
    SA UE Attach    ue_id=7    gnb=2    cell_id=1
    UE Send A1 To Trigger Scell Addition    ue_id=7    A1_expect=${2SCell_Add}
    UE Attach And Blind Scell Addition    ue_id=8    gnb=3    cell_id=3    Blind_expect=${SCell1_12_Add}
    Release UEs    ue_type=all





*** Keywords ***
Modify Cfg
    Update Cfg Param    set_amf_region id=1 plmn=311:489,311:406
    Update Cfg Param    set_gnb id=2 plmnList=311:489,311:406
    Update Cfg Param    set_gnb id=3 plmnList=311:489,311:406
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=5 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=6 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=7 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    ue_param id=8 ue_nr_capabilities=${SA_Capa_perFR_Full}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf_region_id=1 plmn_list=311:489,311:406
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 default=off ue=all amf_region_id=1 plmn_list=311:489,311:406
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=all amf_region_id=1 plmn_list=311:489

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
    ...    timeout=20s

UE Attach And Blind Scell Addition
    [Arguments]    ${ue_id}=1    ${gnb}=2    ${cell_id}=1    ${nwslice_id}=1    ${gw}=1    ${Blind_expect}=${SCell1_11_Add}
    BuiltIn.Log    UE${ue_id} Attach To Cell${cell_id} And Blind Scell Addition...    console=${True}
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${CB008950_Capa_5CC_n41_n66_n66_n71_n77}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${gnb} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice_id} gw=${gw}    pass_regexp=${blind_expect}    timeout=20s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=1
    ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue:${ue_id}

UE Send A1 To Trigger Scell Addition Failed
    [Arguments]    ${ue_id}=1
    BuiltIn.Log    SA UE${ue_id} Send A1 To Trigger Scell Addition Fail...    console=${True}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=518430    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    fail_regexp=SCellIndex .* activated successfully at airphone    timeout=20s

UE Send A1 To Trigger Scell Addition
    [Arguments]    ${ue_id}=1    ${A1_expect}=${2SCell_Add}
    BuiltIn.Log    SA UE${ue_id} Send A1 To Trigger Scell Addition...    console=${True}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=518430    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${A1_expect}    timeout=20s

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
    ...    UE${ue_id}: Proxy \\(eNB ${target_gnb} cell ${target_cells}\\) reported successful RA
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl trf_id=1 mbps=1
    ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue:${ue_id}

NSA UE Setup ENDC Failed
    [Arguments]    ${ue_id}=31    ${target_gnb}=2    ${target_cells}=11
    BuiltIn.Log    NSA UE Setup ENDC To Cell${target_cells} Failed...    console=${True}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=2 type=split_scg
    ...    no-radio-resources-available

Clear Counter Files For 2GNB
    Clear Counter Files    ${False}
    Clear Counter Files BTS2

Check Counters For 2GNB
    [Arguments]    ${PM_Counters_GNB1}=${PM_Counters_F006_GNB1}    ${PM_Counters_GNB2}=${PM_Counters_F006_GNB2}
    BuiltIn.Log    Check Counters For GNB1...    console=${True}
    Run Keyword And Continue On Failure    Check Counters    ${PM_Counters_GNB1}
    BuiltIn.Log    Check Counters For GNB2...    console=${True}
    Check Counters BTS2    ${PM_Counters_GNB2}

Online Change bypassRgLimits to UE context resources
    Delta Commission Parameters    ${DELTA_PARAS_enablebypassRg}
    Delta Commission Parameters BTS2    ${DELTA_PARAS_enablebypassRg2}