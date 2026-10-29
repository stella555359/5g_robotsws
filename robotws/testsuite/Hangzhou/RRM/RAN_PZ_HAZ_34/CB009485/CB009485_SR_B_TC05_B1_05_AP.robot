*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
...    A1based CA config
...    [Configuration]:
...        GNBID         CELLID    band          nrarfcn    gscn    ssbFrequency    phycell_id
...    GNB-2(id=1)       CELL-1     n71    134980:127180    1589          127210            60
...                      CELL-2     n41           518598    6483          518670            50
...                      CELL-3     n71    133780:124580    1555          124370            61
Suite Setup       Common Suite Setup And Setup Airphone Env And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS26R1    tl-CLOUD_5G_I_LO_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot


*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    7314
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
...    0x890004=0
...    0x890003=0

${SYSCOM_FLAG}    ${True}

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

@{PCell2_3CC_CA}
...    pcid:60, scellIdx:1] configure_1_1
...    pcid:61, scellIdx:2] configure_1_1
...    scellIdx:[1-2]\\] configure_0_1    #One UL SCell
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

${ueReleaseRecord_F}    nsetapx.CuVendorExtensionRecordDataType == 0

*** Test Cases ***
CB009485_SR_B_TC05_B1_05 Verify gNB-CU UE Release Trace Record is reported for the release of UE when state from CONNECTED to IDLE Transition
    [Documentation]    This case covers the following user scenario
    ...    USCB009485-B#EC06-ALT2: USStateTransition-H#EC4: CONNECTED to IDLE Transition – Protocol Errors (F1/E1/NG)
    ...    USCB009485-B#EC06: RRC CONNECTED TO IDLE TRANSITION –  Failure - Timeout in gNB-CU for F1/E1/NG Interface Release procedure
    # USCB009485-B#EC06-ALT2 (MSC 5G_CP_OTH_1375)
    log to console    ===== case1: USCB009485-B#EC06-ALT2 (MSC 5G_CP_OTH_1375) ====
    start to capture wireshark log    case1
    log to console    step1: attach UE1 to gnb2 cell1, add 3cc dl 2cc ul
    UE Attach And Waiting L3 Call OK    ue_id=1
    UE Send A1 To Trigger Scell Addition And Verify throughput    ue_id=1

    log to console    step2: make amf send NGAP: UE CONTEXT RELEASE COMMAND with wrong AMF-UE-NGAP-ID
    execute egate command    amf_ue_ctx_release_param id=1 ue=1 action=ap_id_exception nth=1
    execute egate command    ue_ng_ctx_release id=1 cause=NAS_normal_release    UE1: IS IDLE
    Release UEs    ue_id=1    # no ueReleaseRecord when deregister idle UE
    ${ueReleaseRecord_c1}    create list
    ...        ueReleaseRecord/data-r1/trigger=amf
    ...        ueReleaseRecord/data-r1/reason=other
    ...        ueReleaseRecord/data-r1/ueCtxReleaseReqSendTime=not_existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime=not_existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime=not_existing
    ...        ueReleaseRecord/data-r1/rrcReleaseSendTime=existing
    ...        ueReleaseRecord/data-r1/redirectionType=not_existing
    download and check wireshark fields    tag=case1
    ...                                    filter=${ueReleaseRecord_F}
    ...                                    check_fields=${ueReleaseRecord_c1}

    # USCB009485-B#EC06-ALT2 (MSC MSC 5G_CP_OTH_1384)
    log to console    \n===== case2: USCB009485-B#EC06-ALT2 (MSC 5G_CP_OTH_1384) ====
    start to capture wireshark log    case2
    log to console    step1: attach UE2 to gnb2 cell1, add 3cc dl 2cc ul
    UE Attach And Waiting L3 Call OK    ue_id=2
    UE Send A1 To Trigger Scell Addition    ue_id=2

    log to console    step2: wait UE idle and make AMF respond UE CONTEXT RELEASE REQUEST with ERROR INDICATION
    execute egate command    amf_ue_ctx_release_param id=1 ue=2 action=error_indication nth=1
    execute egate command    set_log flush    UE2: IS IDLE    timeout=60
    ${ueReleaseRecord_c2_c3_c4}    create list
    ...        ueReleaseRecord/data-r1/trigger=gNB
    ...        ueReleaseRecord/data-r1/reason=ueInactivity
    ...        ueReleaseRecord/data-r1/ueCtxReleaseReqSendTime=existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime=not_existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime=not_existing
    ...        ueReleaseRecord/data-r1/rrcReleaseSendTime=existing
    ...        ueReleaseRecord/data-r1/redirectionType=not_existing
    download and check wireshark fields    tag=case2
    ...                                    filter=${ueReleaseRecord_F}
    ...                                    check_fields=${ueReleaseRecord_c2_c3_c4}
    Release UEs    ue_id=2

    # Gnb triggered idle + amf ngap id exception
    log to console    \n===== case3: Gnb triggered idle + amf ngap id exception ====
    start to capture wireshark log    case3
    log to console    step1: attach UE3 to gnb2 cell1, add 3cc dl 2cc ul
    UE Attach And Waiting L3 Call OK    ue_id=3
    UE Send A1 To Trigger Scell Addition    ue_id=3

    log to console    step2: wait UE idle and make AMF send UEContextReleaseCommand with wrong UE-NGAP-ID
    execute egate command    amf_ue_ctx_release_param id=1 ue=3 action=ap_id_exception nth=1
    execute egate command    set_log flush    UE3: IS IDLE    timeout=60
    download and check wireshark fields    tag=case3
    ...                                    filter=${ueReleaseRecord_F}
    ...                                    check_fields=${ueReleaseRecord_c2_c3_c4}
    Release UEs    ue_id=3

    # USCB009485-B#EC06
    log to console    \n===== case4: USCB009485-B#EC06 ====
    start to capture wireshark log    case4
    log to console    step1: attach UE4 to gnb2 cell1, add 3cc dl 2cc ul
    UE Attach And Waiting L3 Call OK    ue_id=4
    UE Send A1 To Trigger Scell Addition    ue_id=4

    log to console    step2: wait UE idle and make AMF not send UEContextReleaseCommand after receiving UEContextReleaseRequest
    execute egate command    amf_ue_ctx_release_param id=1 ue=4 action=no_response nth=1
    execute egate command    set_log flush    UE4: IS IDLE    timeout=60
    download and check wireshark fields    tag=case4
    ...                                    filter=${ueReleaseRecord_F}
    ...                                    check_fields=${ueReleaseRecord_c2_c3_c4}
    Release UEs    ue_id=4

    # multiple UEs and one UE idle and ngreset
    log to console    \n===== case5: multiple UEs and ngap reset ====
    start to capture wireshark log    case5
    log to console    step1: attach UE5 and UE6 to gnb2 cell1, add 3cc dl 2cc ul
    UE Attach And Waiting L3 Call OK    ue_id=5
    UE Send A1 To Trigger Scell Addition    ue_id=5
    sleep    2s    # UE5 and UE6 will not enter into idle at same time
    UE Attach And Waiting L3 Call OK    ue_id=6
    UE Send A1 To Trigger Scell Addition    ue_id=6

    log to console    step2: wait UE5 InactivityTimerSA expired and make AMF send NGReset after receiving UEContextReleaseRequest
    execute egate command    amf_ue_ctx_release_param id=1 ue=5 action=send_concurrent_msg msg=ng_reset nth=1
    sleep    30s    # UE5, UE6 released but still show active state due to AP issue
    ${ueReleaseRecord_c5}    create list
    ...        ueReleaseRecord/data-r1/trigger=gNB,amf
    ...        ueReleaseRecord/data-r1/reason=ueInactivity,ueBulkRelease
    ...        ueReleaseRecord/data-r1/ueCtxReleaseReqSendTime/seconds=[RE].*
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime=not_existing
    ...        ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime=not_existing
    ...        ueReleaseRecord/data-r1/rrcReleaseSendTime=not_existing
    ...        ueReleaseRecord/data-r1/redirectionType=not_existing
    download and check wireshark fields    tag=case5
    ...                                    filter=${ueReleaseRecord_F}
    ...                                    check_fields=${ueReleaseRecord_c5}
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Start TCE
    Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/3cells_1T2F    ue_count=10
    Start TCE    ${TCE_PORT}

Modify Cfg
    Update Cfg Param    set_cell id=3 gnb=2 pci=20:1 nr_arfcn=133780:124580 gscn=1555
    FOR    ${id}    IN RANGE    1    11
        Update Cfg    ue_param id=${id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    END

UE Attach And Waiting L3 Call OK
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful    timeout=20s
    ...    sleep_time=5

UE Start Trf
    [Documentation]
    ...    Max Throughput For each Cell:
    ...    NRCELLGRP      NRCELL      DL tput       UL tput
    ...    NRCELLGRP-0    NRCELL-1    92.2 Mbps     67.2 Mbps
    ...    NRCELLGRP-1    NRCELL-2    131.8 Mbps    34.0 Mbps
    ...    NRCELLGRP-2    NRCELL-3    92.6 Mbps     67.2 Mbps
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1    pass_regexp=UDP DL TRF
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2    pass_regexp=UDP DL TRF
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=40 trf_id=3    pass_regexp=UDP UL TRF
    Show Scell PDSCH And PUSCH Throughput    ue_id=${ue_id}
    Verify Throughput No CA    ue_id=${ue_id}

Show Scell PDSCH And PUSCH Throughput
    [Arguments]    ${ue_id}=1
    sleep    15s    #wait trf stable
    Execute Egate Command    bearer_stats ue=${ue_id} pdu=1 qfi=1 dir=dl    Average data rate
    Execute Egate Command    bearer_stats ue=${ue_id} pdu=1 qfi=1 dir=ul    Average data rate
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0-3] *0 *0 *0 *0

Verify Throughput CA
    [Arguments]    ${ue_id}=1    ${maxDLindex}=3    ${maxULindex}=2    ${dl}=270    ${ul}=36
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
    ${dl_throughput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Send A1 To Trigger Scell Addition And Verify throughput
    [Arguments]    ${ue_id}=1    ${carrierfreq}=127210    ${A1_CA}=${PCell1_3CC_CA}    ${maxULindex}=2    ${ul}=36
    UE Start Trf    ue_id=${ue_id}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${A1_CA}    timeout=20s
    Show Scell PDSCH And PUSCH Throughput    ue_id=${ue_id}
    Verify Throughput CA    ue_id=${ue_id}    maxULindex=${maxULindex}    ul=${ul}

UE Send A1 To Trigger Scell Addition
    [Arguments]    ${ue_id}=1    ${carrierfreq}=127210    ${A1_CA}=${PCell1_3CC_CA}
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ...    threshold=RSRP\ 31
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=${A1_CA}    timeout=20s

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}    ${times}=1
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}    ${times}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all
