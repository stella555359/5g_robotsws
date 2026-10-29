*** Settings ***
Documentation
...    author: Yan Suzhen
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup        Common Suite Setup And Setup Airphone Env And Start TCE
Suite Teardown     Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup         Common Test Setup And Start To Capture Logs
Test Teardown      Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R3    tl-CLOUD_5G_I_LO_AP_LO
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    0x5A0609=1    #L2-HI rdDebugPcmdNrt
...    0x5A0610=1    #L2-HI rdDebugPcmdRt
...    0x5B0609=1    #L2-HI rdDebugPcmdNrt
...    0x5B0610=1    #L2-HI rdDebugPcmdRt
...    0x57000E=1    #enable L2-LO NRT PCMD debug logs
...    0x58057a=4    #L2-PS rdFeatureFlagBitmapLevel 4DEBUG
...    0x58057b=8    #L2-PSrdFeatureFlagBitmap0 8PF_METRIC
...    0x580582=3    #L2-PSrdFeatureFlagBitmap7 3RAT1_ALLOC
...    0x58057f=0x10000000     #L2-PSrdFeatureFlagBitmap4

${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/3cells_1T2F
#FR1 TDD: n41 n78, FDD: n66 n71
#2CC CA_n66A-n78A CA_n41A-n71A CA_n66A-n71A CA_n41A-n66A CA_n71A-n78A CA_n41A-n78A CA_n71(2A)
#3CC CA_n66(2A)-n71A CA_n41A-n66A-n78A CA_n41A-n66A-n71A CA_n41A-n66(2A) CA_n66A-n71A-n78A CA_n41A-n71(2A) CA_n41A-n71A-n78A
${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01F71B0A303582308682041D211001B5B262AC6873E238F40CFB027C62471E439F
...    51CF9863CA1607038782E007FE0038002F8003A00000E0541B107582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F600000
...    07400001C0AA3626EB04610D04083A4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0007400001C0A836236B04610D04083C4220032B
...    64C55890E7C471EC09F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000E800003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000
...    C2C0AC3C28000E208000010B02B0F13400388C0000042C0AC5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E230007
...    11800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C46000E1
...    40000040B02B0F11800388C00000C2C0803808D00A2026C0411D4001760F851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F0
...    22408103639F022408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF8002E1E318C6318C6318C6318C3D08C000F000A
...    070500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A008004010040100000C0080000700400200000008
...    000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000196525040
...    000A594901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240334A
...    AAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E28780178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080
...    40300610080100602018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A202
...    2242628303236383A3E424A4C4E5052545A5E828305A

@{PCell1_3CC_CA}
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:61, scellIdx:2] configure_1_1
...    scellIdx:[1-2]\\] configure_0_1    #One UL SCell
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

${DUBearerRecord}     nsetapx.DuVendorExtensionRecordDataType == 13
@{BearerRecord_Feilds}
...    bearerRecord/data-r2/trigger=ctxSetup
...    bearerRecord/data-r2/setupBearers=1 item
...    bearerRecord/data-r2/setupBearers/DuBearerDataSetupItem/drb-Id=4
...    bearerRecord/drbLevelQos/nonDynamicFiveQiDescriptor/fiveQi=6
...    bearerRecord/drbLevelQos/arp/priorityLevel=15
...    bearerRecord/drbLevelQos/arp/preemptionCapability=shallNotTriggerPreemption
...    bearerRecord/drbLevelQos/arp/preemptionVulnerability=preemptable
...    bearerRecord/drbLevelQos/pduSessionId=1
...    bearerRecord/snssai/sst=01
...    bearerRecord/snssai/sd=d143a5
...    bearerRecord/qosFlowsMappedToBearer=1 item
...    bearerRecord/DuQosFlowMappedToBearerItem/qfi=1
...    bearerRecord/DuQosFlowMappedToBearerItem/fiveQi=6
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/priorityLevel=15
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/preemptionCapability=shallNotTriggerPreemption
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/preemptionVulnerability=preemptable
...    bearerRecord/DuQosFlowMappedToBearerItem/pduSessionId=1

@{BearerRecord_Failtosetup_Feilds}
...    bearerRecord/data-r2/trigger=ctxSetup
...    bearerRecord/data-r2/failedToSetupBearers=1 item
...    bearerRecord/data-r2/failedToSetupBearers/DuBearerDataFailedToSetupItem-r2/drb-Id=4
...    failedToSetupBearers/drbLevelQos/nonDynamicFiveQiDescriptor/fiveQi=6
...    failedToSetupBearers/drbLevelQos/arp/priorityLevel=15
...    failedToSetupBearers/drbLevelQos/arp/preemptionCapability=shallNotTriggerPreemption
...    failedToSetupBearers/drbLevelQos/arp/preemptionVulnerability=preemptable
...    failedToSetupBearers/drbLevelQos/pduSessionId=1
...    failedToSetupBearers/snssai/sst=01
...    failedToSetupBearers/snssai/sd=d143a5
...    failedToSetupBearers/qosFlowsMappedToBearer=1 item
...    failedToSetupBearers/DuQosFlowMappedToBearerItem/qfi=1
...    failedToSetupBearers/DuQosFlowMappedToBearerItem/fiveQi=6
...    failedToSetupBearers/DuQosFlowMappedToBearerItem/arp/priorityLevel=15
...    failedToSetupBearers/DuQosFlowMappedToBearerItem/arp/preemptionCapability=shallNotTriggerPreemption
...    failedToSetupBearers/DuQosFlowMappedToBearerItem/arp/preemptionVulnerability=preemptable
...    failedToSetupBearers/DuQosFlowMappedToBearerItem/pduSessionId=1

@{maxNum_limit}
...    NRDU-1:maxNumOfRrcConUEsPerDU=0

*** Test Cases ***
CB009485_SR_A_TC28_B3_07_Verify gNB-DU reports Bearer Trace Record during Bearer Setup after unsuccessful Inter-gNB HO
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify USCB009485-A#EC21: Monitoring PCMD content related to CB009485 for DU Bearer Trace Record
    ...    during Bearer Setup after unsuccessful Inter-gNB HO (Xn based)
    ...    2. [Configuration]:
    ...        GNBID         CELLID    band          nrarfcn    gscn    ssbFrequency    phycell_id
    ...    GNB-2(id=1)       CELL-1     n71    134980:127180    1589          127210            60
    ...                      CELL-2     n41           518598    6483          518670            50
    ...                      CELL-3     n71    133780:124580    1555          124370            61
    ...    sim-GNB(id=35)    CELL-1     n41           508020    6351          508110            60
    ...    sim-GNB(id=36)    CELL-2     n71    136680:127460    1594          127490            50
    ...    3. Test Case Steps:
    ...        1.UE3 attach to CELL-1
    ...        2.UE Send A1 To Trigger Scell Addition And Add SCells
    ...        3.Trigger inter-RAT NG  HO  from CELL1 to simgnb 1-CELL11 and receive handover cancel during procedure.
    ...        4.Check PCMD records works properly.
    ...    4. Expected Results:
    ...        1.UE1 attached successfully and traffic is statable.
    ...        2.Scell add successfully.
    ...        3.Handover fails due to handover cancel.
    ...        4.DU Bearer Trace Record generated with IE Failed to setup
    [Tags]    TC07    CA_LABEL-TFF(20MHz_TDD_n41+10MHz_FDD_n71)
    UE Attach And Waiting L3 Call OK    ue_id=3    tag=Attach
    UE Send A1 To Trigger Scell Addition And Add SCell    ue_id=3
    UE Trigger Inter-Frequency Inter-gnb HO To Sim gNB Cell1    ue_id=3
    Delta Commission Parameters    ${maxNum_limit}
    UE Trigger HO From Sim gNB Cell1 To Real gNB Cell1 and expect failed    ue_id=3    tag=Handoverfail

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Start TCE
    Common Suite Setup And Setup Airphone Env    tl_type=${TL_TYPE_PATH}    ue_count=4
    run keyword if   ${DEBUG}==${True}    Perform Steps After Onair

Modify Cfg
    Update Cfg Param    set_cell id=3 gnb=2 pci=20:1 nr_arfcn=133780:124580 gscn=1555
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    ${set_gnb4}    catenate    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb4}
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=20:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=508020:508020
    ...    gscn=6351 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    ${set_gnb4_cell2}    catenate    set_cell id=2 gnb=4 pci=16:2 tac=200 nrci=0x02 tdd_cell=off proxy=10.0.2.91:9999 nr_arfcn=136680:127460
    ...    gscn=1594 mandatory_for_activation=off
    Update Cfg    ${set_gnb4_cell2}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${SA_Capa_perUE_Full}

Perform Steps After Onair
    Start TCE    ${TCE_PORT}
    Execute Egate Command    gnb_param id=3 xn_listening_socket=on send_xn_setup=true sa_ho=xn_based
    Execute Egate Command    gnb_param id=4 xn_listening_socket=on send_xn_setup=true sa_ho=xn_based
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    #build XN setup
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2    #build XN setup
    Add UE History Information List

Add UE History Information List
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=96
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x02 gnb_id=4 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    Execute Egate Command    ue_history_information_list id=1 action=commit

UE Attach And Waiting L3 Call OK
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${tag}=Attach
    ...    ${filter}=${DUBearerRecord}    ${check_fields}=${BearerRecord_Feilds}
    BuiltIn.Log    UE${ue_id} Attach And Waiting L3 Call OK...    console=${True}
    Start To Capture Wireshark Log    ${tag}
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful    timeout=20s
    ...    sleep_time=5
    UE Start Trf    ue_id=${ue_id}
    download and check wireshark fields    tag=${tag}
    ...                                    filter=${filter}
    ...                                    check_fields=${check_fields}

UE Send A1 To Trigger Scell Addition And Add SCell
    [Arguments]    ${ue_id}=3   ${carrierfreq}=127210    ${A1_CA}=${PCell1_3CC_CA}    ${maxULindex}=2    ${ul}=36    ${tag}=UE3_PCELL1_CA
    BuiltIn.Log    UE${ue_id} Send A1 To Trigger Scell Addition And Add SCell...    console=${True}
    Start To Capture Wireshark Log    ${tag}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${A1_CA}    timeout=20s
    Show Scell PDSCH And PUSCH Throughput    ue_id=${ue_id}
    Verify Throughput CA    ue_id=${ue_id}    maxULindex=${maxULindex}    ul=${ul}
    sleep    60s    #wait to get enough trace msg
    [Teardown]    Stop Capture Wireshark Log

UE Trigger Inter-Frequency Inter-gnb HO To Sim gNB Cell1
    [Arguments]    ${ue_id}=1    ${source_carrierfreq}=127210    ${target_carrierfreq}=508110
    BuiltIn.Log    UE${ue_id} Trigger Intra-Frequency Inter-gnb HO To sim gnb Cell1...    console=${True}
    Start To Capture Wireshark Log    HO_To_Sim_gNB
    Trigger UE With A2 Measurement Report    ue_id=${ue_id}    carrierfreq=${source_carrierfreq}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${target_carrierfreq}    event_type=A3
    ${cmd_HO}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=60 nrsrp_nr=80
    Execute Egate Command    ${cmd_HO}    pass_regexp=Inter-eNB handover from EXT_ENB-2.* to ENB-3.* performed
    sleep    5s    #wait trace session in source cell be cleared
    Execute Egate Command    ue_disp    pass_regexp=Configured UEs
    [Teardown]    Stop Capture Wireshark Log

Trigger UE With A2 Measurement Report
    [Arguments]    ${ue_id}=1    ${carrierfreq}=127210
    BuiltIn.Log    UE${ue_id} Send A2 Measurement Report...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfiguration    timeout=20s

UE Start Trf
    [Documentation]
    ...    Max Throughput For each Cell:
    ...    NRCELLGRP      NRCELL      DL tput       UL tput
    ...    NRCELLGRP-0    NRCELL-1    92.2 Mbps     67.2 Mbps
    ...    NRCELLGRP-1    NRCELL-2    131.8 Mbps    34.0 Mbps
    ...    NRCELLGRP-2    NRCELL-3    92.6 Mbps     67.2 Mbps
    [Arguments]    ${ue_id}=1
    BuiltIn.Log    UE${ue_id} Start Trf...    console=${True}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    pass_regexp=UDP DL TRF
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    pass_regexp=UDP DL TRF
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=40 trf_id=3    pass_regexp=UDP UL TRF
    Show Scell PDSCH And PUSCH Throughput    ue_id=${ue_id}
    Verify Throughput No CA    ue_id=${ue_id}

Show Scell PDSCH And PUSCH Throughput
    [Arguments]    ${ue_id}=1
    BuiltIn.Log    Show Scell PDSCH And PUSCH Throughput...    console=${True}
    sleep    15s    #wait trf stable
    Execute Egate Command    bearer_stats ue=${ue_id} pdu=1 qfi=1 dir=dl    Average data rate
    Execute Egate Command    bearer_stats ue=${ue_id} pdu=1 qfi=1 dir=ul    Average data rate
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0

Verify Throughput CA
    [Arguments]    ${ue_id}=1    ${maxDLindex}=3    ${maxULindex}=2    ${dl}=270    ${ul}=36
    BuiltIn.Log    Verify Throughput CA...    console=${True}
    ${dl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${maxDLindex}
        ${sid}    convert to string    ${id}
        ${result}    ${scell_tput}    Run Keyword And Ignore Error    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${sid}
        ...    type=pdsch    rate_type=ave
        Continue For Loop If    '${result}' == 'FAIL'
        Should Be True    ${scell_tput}/1000 > 0
        ${dl_tput}    Evaluate    ${dl_tput}+${scell_tput}
    END
    Should Be True    ${dl_tput}/1000>${dl}
    ${ul_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${maxULindex}
        ${sid}    convert to string    ${id}
        ${result}    ${scell_tput}    Run Keyword And Ignore Error    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${sid}
        ...    type=pusch    rate_type=ave
        Continue For Loop If    '${result}' == 'FAIL'
        Should Be True    ${scell_tput}/1000 > 0
        ${ul_tput}    Evaluate    ${ul_tput}+${scell_tput}
    END
    Should Be True    ${ul_tput}/1000>${ul}

Verify Throughput No CA
    [Arguments]    ${ue_id}=1    ${dl}=80    ${ul}=27
    BuiltIn.Log    Verify Throughput No CA...    console=${True}
    ${dl_throughput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Trigger HO From Sim gNB Cell1 To Real gNB Cell1 and expect failed
    [Arguments]    ${ue_id}=1    ${source_carrierfreq}=508110    ${target_carrierfreq}=127210    ${tag}=Handoverfail
    ...    ${filter}=${DUBearerRecord}    ${check_fields}=${BearerRecord_Failtosetup_Feilds}
    BuiltIn.Log    UE${ue_id} Trigger HO From Sim gNB Cell1 To Real gNB Cell1 And RRE Fallback To Real gNB Cell1...    console=${True}
    Start To Capture Wireshark Log    tag=${tag}
    Trigger UE With A2 Measurement Report    ue_id=${ue_id}    carrierfreq=${source_carrierfreq}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${target_carrierfreq}    event_type=A3
    ${cmd_HO}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=60 nrsrp_nr=80
    Execute Egate Command    ${cmd_HO}    pass_regexp=Handover canceled
    download and check wireshark fields    tag=${tag}
    ...                                    filter=${filter}
    ...                                    check_fields=${check_fields}

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all