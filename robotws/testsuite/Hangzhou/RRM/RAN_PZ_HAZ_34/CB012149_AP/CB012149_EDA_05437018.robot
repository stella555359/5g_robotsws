*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia.com
...    squad group: VRF_HAZ_T03
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        tl-CLOUD_5G_I_LPQ_AP_LOO    release-24R3
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${SYSCOM_FLAG}    true
${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_2T4F
${Cell1_ssbFrequency}    518430
${Cell2_ssbFrequency}    636576
${Cell13_ssbFrequency}    430830
${Cell11_ssbFrequency}    423850
${Cell12_ssbFrequency}    126990
${Cell_1_TDD_PCI}    50
${Cell_2_TDD_PCI}    51
${Cell_11_FDD_PCI}    60
${Cell_12_FDD_PCI}    61
${Cell_13_FDD_PCI}    62
${Cell_14_FDD_PCI}    63
${6CC_UE_capa}    SEPARATOR=
...    E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E02771B0A303582308682041D211001B5B262AC
...    6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE003801FF8003640001C006CAAAA8AAAA80A83620EB04610D04083C4220
...    032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FFE00000FFF800000D80000702A8D89BAC1184341020E908800C2D9315
...    44439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B20000E00365FFFE5FFFE0551B133582308682041D21100185B
...    262A88873E238F11C7A067D813E31CF9863CA1607038782E007FE003801FF8003640001C006CBFFFCBFFFC0AE3E236B04610D04083E50880
...    0AAD931561439F11C78C0000000000000000000001E027FFC00001FFF000001B00000E0033C3C28000C26800002C040BC5C28000E2080071
...    180000085808178F850001C41000C2301C4600000416020562E1400061040E208000010B02B2F0A0003882001C41000E23000711800389A0
...    000182C0ACDC28000E20800710400388C001C46000E230007134000038581007011A014404D808236C000C818100800C0020050001800005
...    830C6318C667208C270785000184D0001858081040600408C258B850001C41000E230000080B02100300204612CBC28000E2080061180E23
...    000710400389A0000142C08A00030820442A30966E1400061040E20800711800388C001C46000E268000040B023000030840413200F41F00
...    078005038280381804A00E000C0480080C07C050040000000200000401000004008000030040000200200001405E54560A5E54DE0EDA5568
...    2D00C1000009652404000065949010000296525040000E5949003F2A82B82C37CAACBA0D143C00BC04A8140A05028140A05028140A050281
...    40A05028140A0010103002006004008180100300200440600400C008010300400A008010180200500400860600400C008010300400A00801
...    018020050040080C0100280200410300200E00C0181801003006004C0600401C008030300400A00801018020050040080C01002802004060
...    08014010020300400A008010180100700200CA0600401C008030300400A00801018020050040080C0100280200406008014010020300200E
...    00401940C0280180500206018014030020300C00A018010180600500C0080C030028060040601400C0280130180500300A0040C030028060
...    0406018014030020300C00A018010180600500C0080C020028040040601400C028011008010060200801008010063543E00020406080C0E1
...    416181A2022242628303236383A3E424A4C4E5052545A5E828305A
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
${RRC_RECONF_ADD1ULSCELL_ATT_SA}    M55118C10001
${RRC_RECONF_ADD1ULSCELL_SUCC_SA}    M55118C10002
${A2MEAS_REL1ULSCELL_ATT_SA}    M55118C10003
${A2MEAS_REL1ULSCELL_SUCC_SA}    M55118C10004
${SCELL_SWAP_1_ATT_SA}    M55118C10501
${SCELL_SWAP_1_SUCC_SA}    M55118C10502
${SCELL_CHANGE_ATT_SA}    M55118C06506    # need to add a note that SCell swaps are excluded
${SCELL_CHANGE_SUCC_SA}    M55118C06507    # need to add a note that SCell swaps are excluded
${ACC_NUM_UL_TX_SW_OP1_UE_CAP}    M55181C00010    # CB008698 counter
${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}    M55118C00053
${DEN_1_SEC_SAMPLE}    M55118C00054
${AVG_NUM_UE_DENOM}    M55181C00003
${SUM_SA_UE_FULL_PWR_FR1}    M55114C01501
${SUM_SA_UE_FULL_PWR1_FR1}    M55114C01502
${SUM_SA_UE_FULL_PWR2_FR1}    M55114C01503
${DENOM_UE_FULL_PWR_FR1}    M55114C01505
${MAX_SA_UES_FULL_PWR_FR1}    M55156C00001
${MAX_SA_UES_FULL_PWR1_FR1}    M55156C00002
${MAX_SA_UES_FULL_PWR2_FR1}    M55156C00003
@{Counters_Check}
...    NRCELL-1:${ACC_NUM_UL_TX_SW_OP1_UE_CAP}>1
...    NRCELL-1:${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}>1
...    NRCELL-1:${DEN_1_SEC_SAMPLE}>1
...    NRCELL-1:${DEN_1_SEC_SAMPLE}<=660
...    NRCELL-1:${AVG_NUM_UE_DENOM}>1
...    NRCELL-1:${AVG_NUM_UE_DENOM}<=660
...    NRCELL-1:${SUM_SA_UE_FULL_PWR_FR1}=0
...    NRCELL-1:${SUM_SA_UE_FULL_PWR1_FR1}=0
...    NRCELL-1:${SUM_SA_UE_FULL_PWR2_FR1}=0
...    NRCELL-1:${DENOM_UE_FULL_PWR_FR1}=0
...    NRCELL-1:${MAX_SA_UES_FULL_PWR_FR1}=0
...    NRCELL-1:${MAX_SA_UES_FULL_PWR1_FR1}=0
...    NRCELL-1:${MAX_SA_UES_FULL_PWR2_FR1}=0
...    NRCELL-13:${ACC_NUM_UL_TX_SW_OP1_UE_CAP}>1
...    NRCELL-13:${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}>1
...    NRCELL-13:${DEN_1_SEC_SAMPLE}>1
...    NRCELL-13:${DEN_1_SEC_SAMPLE}<=660
...    NRCELL-13:${AVG_NUM_UE_DENOM}>1
...    NRCELL-13:${AVG_NUM_UE_DENOM}<=660
...    NRCELL-11:${ACC_NUM_UL_TX_SW_OP1_UE_CAP}>1
...    NRCELL-11:${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}>1
...    NRCELL-11:${DEN_1_SEC_SAMPLE}>1
...    NRCELL-11:${DEN_1_SEC_SAMPLE}<=660
...    NRCELL-11:${AVG_NUM_UE_DENOM}>1
...    NRCELL-11:${AVG_NUM_UE_DENOM}<=660
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-13:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-11:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-2:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-13:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-14:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-11:NCAC:${A2MEAS_REL1ULSCELL_ATT_SA}=1
...    NRCELL-11:NCAC:${A2MEAS_REL1ULSCELL_SUCC_SA}=1
...    NRCELL-13:NCAC:${A2MEAS_REL1ULSCELL_ATT_SA}=1
...    NRCELL-13:NCAC:${A2MEAS_REL1ULSCELL_SUCC_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=1
...    NRCELL-13:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=2
...    NRCELL-13:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=2
...    NRCELL-11:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=1
...    NRCELL-11:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=1
...    NRCELL-13:${SCELL_SWAP_1_ATT_SA}=2
...    NRCELL-13:${SCELL_SWAP_1_SUCC_SA}=2
...    NRCELL-13:${SCELL_CHANGE_ATT_SA}=1
...    NRCELL-13:${SCELL_CHANGE_SUCC_SA}=1
...    NRCELL-11:${SCELL_CHANGE_ATT_SA}=1
...    NRCELL-11:${SCELL_CHANGE_SUCC_SA}=1
${filter_pdusessionsetup_response}    ngap.procedureCode == 29
${filter_rrcreconfigurationcomplete}    (nr-rrc.c1 == 1) && (f1ap.procedureCode == 13)

*** Test Cases ***
CB012149_EDA_05437018
    log to console    step1: online enable CB012149,CB009059 and CB009189
    start to capture wireshark log    1_delta
    delta commission parameters    ${DELTA_EDA}
    cells should be onair
    stop capture wireshark log    1_delta

    log to console    step2: attach UE to FDD cell13 and start traffic
    start to capture wireshark log    2_attach_5cc
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-13    ue_id=1    ue_capa=${6CC_UE_capa}
    Send And Verify Throughput    ue_id=1

    log to console    step3: report A1 to tigger ultxswitch 5CC:62+50+51*+60+61
    Send A1 report to trigger ultxswitch 5CC on FDD Cell-13
    ${wireshark_log_path}   stop_wireshark_log_after_filter_found    2_attach_5cc    ${filter_rrcreconfigurationcomplete}    times=2
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=itf_l2_ps_user_usermodifyreq
    ...                       check_fields=perSrConfig_item_0/periodicity=sl80,sl80    #one for ICS, the other for scell addition
    ...                       packet_num=all

    log to console    step4: start VONR, scell released and SR change from sl80 to sl20
    log to console    ...... check sr in itf_l2_ps_user_usermodifyreq(CPRT to L2PS) and rrcReconfiguration(CPRT to UE) should be same
    start to capture wireshark log    3_vonr_setup
    Start VONR call And Check Scell Released    ue_id=1
    start vonr traffc    ue_id=1
    Verify Throughput    ue_id=1
    ${wireshark_log_path}   stop_wireshark_log_after_filter_found    3_vonr_setup    ${filter_pdusessionsetup_response}    times=2
    run keyword and continue on failure
    ...    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=itf_l2_ps_user_usermodifyreq
    ...                       check_fields=perSrConfig_item_0/periodicity=sl20,sl20    # one for vonr, one for scell release
    ...                       packet_num=all
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=nr-rrc.c1 == 0    # rrcReconfiguration
    ...                       check_fields=pucch-Config/setup/SchedulingRequestResourceConfig/periodicityAndOffset=sl20
    ...                       packet_num=all

    log to console    step5: release VONR, SR change back
    start to capture wireshark log    4_vonr_release
    stop vonr traffc and release vonr    ue_id=1
    ${wireshark_log_path}   stop_wireshark_log_after_filter_found    4_vonr_release    ${filter_rrcreconfigurationcomplete}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=itf_l2_ps_user_usermodifyreq
    ...                       check_fields=perSrConfig_item_0/periodicity=sl80
    ...                       packet_num=all
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=nr-rrc.c1 == 0    # rrcReconfiguration
    ...                       check_fields=pucch-Config/setup/SchedulingRequestResourceConfig/periodicityAndOffset=sl80
    ...                       packet_num=all
    active ue count should be    ue_num=1

*** Keywords ***

Modify Cfg
    update cfg    set_qosflow id=1 5qi=6 default=on
    update cfg    set_qosflow id=5 5qi=5 ue=all
    update cfg    set_qosflow id=6 5qi=1 ue=all

Start BTS With Specified Config Files
    Common Suite Setup And Setup Airphone Env    tl_type=${GNB_CONFIG}
    Execute Egate Command    gnb_param id=3 sib1_period=3000
    Execute Egate Command    ib_enb_cell_disp enb=3 cell=1
    Set UE Parameters Before Register

Set UE Parameters Before Register
    set UE history info    ue_id=1    history_id=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=1 pdu=2 trf_type=internal

set UE history info
    [Arguments]    ${ue_id}=1    ${history_id}=1
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=${history_id} action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=${history_id}
    Execute Egate Command    ue_enb_param id=2 ue_history_list=${history_id}

Scell A2 report to trigger Scell Release
    [Arguments]    ${ue_id}=31    ${carrierfreq}=${Cell2_ssbFrequency}    ${scell_id}=2    ${pass_regexp}=rrcReconfigurationComplete
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} scell=${scell_id} scell_rsrp=20 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    pass_regexp=${pass_regexp}
    Should Contain    ${ret1}    sCellToReleaseList

Detach UE
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-13
    [Arguments]    ${ue_id}    ${ue_capa}
    execute egate command    qosflow_modify qos_flow=1 default=on
    execute egate command    smf_param id=1 reset
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=13
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Send A2 A3 report to trigger intra-gnb handover to FDD cell-13 from cell-1 and check normal 5CC
    [Arguments]    ${ue_id}=1
    UE Report InterFrequency A2 event    ue_id=${ue_id}    carrierfreq=${Cell1_ssbFrequency}
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    ...    pcid:${Cell_11_FDD_PCI}, scellIdx:3
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:4
    UE Report InterFrequency A3 event and check no ultxswitch    ue_id=${ue_id}    carrierfreq=${Cell13_ssbFrequency}    phycell_id=62
    ...    pass_regexp=${expect_output}
    Verify Throughput When 4 Scells

UE Report InterFrequency A2 event
    [Arguments]    ${ue_id}=1    ${carrierfreq}=${Cell1_ssbFrequency}    ${srsrp_nr}=34    ${srsrq_nr}=20    ${a2_thres}=36
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    ...    event_type=A2    measho_type=RSRP    threshold=${a2_thres}
    ${ret3}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    pass_regexp=eventA3

UE Report InterFrequency A3 event and check no ultxswitch
    [Arguments]    ${ue_id}=1    ${carrierfreq}=${Cell1_ssbFrequency}    ${srsrp_nr}=34    ${srsrq_nr}=20
    ...    ${phycell_id}=61    ${nrsrp_nr}=75    ${nrsrq_nr}=75    ${pass_regexp}=rrcReconfigurationComplete
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A3 srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    ${ret3}=    Execute Egate Command
    ...    ${command}
    ...    pass_regexp=${pass_regexp}
    Should Not Contain    ${ret3}    uplinkTxSwitchingOption-r16 switchedUL

Send A1 report to trigger Scell Addition with RSRP
    [Arguments]    ${ue_id}=1    ${cell_freq}=${Cell13_ssbFrequency}    ${rsrp}=61    ${pass_regexp}=rrcReconfigurationComplete
    Start rrc log    RSRP${rsrp}_scell_add_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=${rsrp} ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=${pass_regexp}
    Get RRC log

Send A1 report to trigger ultxswitch 5CC on FDD Cell-13
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    ...    pcid:${Cell_11_FDD_PCI}, scellIdx:3
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:4
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Send A1 report to trigger Scell Addition with RSRP    ue_id=1    cell_freq=${Cell13_ssbFrequency}    rsrp=64
    ...    pass_regexp=${expect_output}
    Verify Throughput When 4 Scells

Send And Verify Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=6 mbps=10    UE ${ue_id}: UDP UL
    Verify Throughput

Verify Throughput When 2 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=3
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch

Throughput Check
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=1    ${sleep_time}=15s    ${CC_num}=4
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    run keyword and ignore error    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Should Be True    ${ul_throughput}>0
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${alldl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
    END
    run keyword and ignore error    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}
    Should Be True    ${alldl_tput}>0


Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=40    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    run keyword and ignore error    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    run keyword and ignore error    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    Should Be True    ${dl_throughput}>0
    Should Be True    ${ul_throughput}>0

Verify Throughput When 4 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=5
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex-3

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    # Cells Should Be Onair    check_sib=${False}
    Sleep    1 min

Trigger Pcell Change From FDD Cell-13 To FDD Cell-11
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}=None    ${ue_id}=1    ${log_id}=1
    Start rrc log    scell_addition_UE${ue_id}_${log_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} event=A1 meas_id=${measid} srsrp_nr=11 srsrq_nr=11 scell=${scell_index}
    ...    scell_rsrp=127 scell_rsrq=127
    ${ret5}=    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Get RRC log

Trigger PCell change From FDD Cell-13 to FDD Cell-11 and check ultxswitch 5CC CA
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:3
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:4
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Trigger PCell change From FDD Cell-13 to FDD Cell-11    ue_id=1    cellfreq=${Cell11_ssbFrequency}
    ...    scell_index=3    pass_regexp=${expect_output}
    Verify Throughput When 4 Scells

Trigger Pcell Change
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}=rrcReconfigurationComplete    ${ue_id}=1    ${log_id}=1
    Start rrc log    scell_addition_UE${ue_id}_${log_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} event=A1 meas_id=${measid} srsrp_nr=11 srsrq_nr=11 scell=${scell_index}
    ...    scell_rsrp=127 scell_rsrq=127
    ${ret5}=    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Get RRC log

Trigger Scell Swap By A6
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycell_id}=51    ${scell_id}=1    ${pass_regexp}=rrcReconfigurationComplete
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A6
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A6 srsrp_nr=59 ssinr_nr=59 srsrq_nr=32
    ...    phycell_id=${phycell_id} nrsrp_nr=65 nsinr_nr=65 nrsrq_nr=32 scell=${scell_id} scell_rsrp=56 scell_rsrq=11
    Execute Egate Command    ${cmd}
    ...    pass_regexp=${pass_regexp}

Trigger Scell Swap By A6 from FDD Cell-12 to FDD Cell-14
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_14_FDD_PCI}, scellIdx:5
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Trigger Scell Swap By A6    ue_id=1    carrierfreq=${Cell12_ssbFrequency}    phycell_id=63    scell_id=4
    ...    pass_regexp=${expect_output}

Trigger Scell Swap By A6 from FDD Cell-12 to FDD Cell-14 check no UlTxswitch
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_14_FDD_PCI}, scellIdx:5
    Trigger Scell Swap By A6    ue_id=1    carrierfreq=${Cell12_ssbFrequency}    phycell_id=63    scell_id=4
    ...    pass_regexp=${expect_output}

Trigger Scell Addition By A1
    [Arguments]    ${ue_id}    ${srsrp_nr}    ${carrierfreq}=${Cell13_ssbFrequency}    ${pass_regexp}=rrcReconfigurationComplete
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=${pass_regexp}

Trigger Scell Addition By A1 Check no Ultxswitch
    [Arguments]    ${ue_id}    ${srsrp_nr}    ${carrierfreq}=${Cell13_ssbFrequency}    ${pass_regexp}=rrcReconfigurationComplete
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=${srsrp_nr} ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=${pass_regexp}
    Should Not Contain    ${ret}    uplinkTxSwitchingOption-r16 switchedUL

Stepwise Release All TDD Scell and Trigger Scell change to normal 3CC CA
    ${expect_output1}    Create List
    ...    rrcReconfigurationComplete
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1    pass_regexp=${expect_output1}
    ${expect_output2}    Create List
    ...    rrcReconfigurationComplete
    ...    uplinkTxSwitching-r16 release : NULL
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell2_ssbFrequency}    scell_id=2    pass_regexp=${expect_output2}
    ${expect_output3}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    Trigger Scell Addition By A1 Check no Ultxswitch    ue_id=1    srsrp_nr=65    carrierfreq=${Cell11_ssbFrequency}    pass_regexp=${expect_output3}

Stepwise Release All TDD Scell and Trigger Scell change to ultxswitch 3CC CA
    ${expect_output1}    Create List
    ...    rrcReconfigurationComplete
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=1    pass_regexp=${expect_output1}
    ${expect_output2}    Create List
    ...    rrcReconfigurationComplete
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${Cell2_ssbFrequency}    scell_id=2    pass_regexp=${expect_output2}
    ${expect_output3}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Trigger Scell Addition By A1    ue_id=1    srsrp_nr=91    carrierfreq=${Cell13_ssbFrequency}    pass_regexp=${expect_output3}
    Verify Throughput When 2 Scells

Trigger PCell change from FDD Cell-11 to TDD Cell-1 and check ultxswitch 5CC CA
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_11_FDD_PCI}, scellIdx:2
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:3
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:4
    ...    uplinkTxSwitchingOption-r16 switchedUL
    Trigger PCell change    ue_id=1    cellfreq=${Cell1_ssbFrequency}
    ...    scell_index=1    pass_regexp=${expect_output}
    Verify Throughput When 4 Scells


Send A1 report to trigger 5CC on FDD Cell-13
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    ...    pcid:${Cell_11_FDD_PCI}, scellIdx:3
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:4
#    ...    uplinkTxSwitchingOption-r16 switchedUL
    Send A1 report to trigger Scell Addition with RSRP    ue_id=1    cell_freq=${Cell13_ssbFrequency}    rsrp=64
    ...    pass_regexp=${expect_output}
    Verify Throughput When 4 Scells

Start VONR call And Check Scell Released
    [Arguments]    ${ue_id}=1
    execute egate command    qosflow_modify qos_flow=5 default=on
    execute egate command    smf_param additional_qosflows_to_activate=6 id=1
    ${pass_regexp}    Create List
    ...    Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    ...    Created FiveQi:Qfi mapping fiveQi 1 qfi 2
    ...    sCellToReleaseList
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:0
    ${out}    execute egate command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=1    pass_regexp=${pass_regexp}
    should not contain    ${out}    scellIdx:1


start vonr traffc
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=2 dir=dl trf_id=1 kbps=20    EGATE>
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=2 qfi=2 dir=ul trf_id=2 kbps=20    EGATE>
    sleep    20
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=2    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=2    qfi=2    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}>0
    Should Be True    ${ul_throughput}>0


stop vonr traffc and release vonr
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_stop ue=${ue_id} pdu=2 qfi=2 dir=dl trf_id=1    Stopped Downlink Internal traffic
    Execute Egate Command    data_trf_stop ue=${ue_id} pdu=2 qfi=2 dir=ul trf_id=2    Stopping Uplink Internal traffic
    sleep    5s
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2 by=ue    pass_regexp=Successfully released PDU Session with ID 2
