*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    CRT    CLOUD_R4LAPO_CUS
...               team-CN3ET    owner-lixia.zhou,ying.shang    release-SBTS23R2
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{8931}
...    @{2611}
...    @{518}
...    @{1231}

@{8931}
...    LNBTS:actQciArpToDscpMarking=true
...    LNBTS:qciTab8:dscpProfIdx=1
...    LNBTS:qciTab2:dscpProfIdx=1
...    LNBTS:qciTab2:dscp=62
...    LNBTS/DSCPPR-1:dscpMarking:arpValueStop=15|dscpValue=0
...    LNBTS/DSCPPR-1:dscpMarking:arpValueStart=10|dscpValue=0
...    LNBTS/DSCPPR-1:dscpMarking:arpValueStop=9|dscpValue=1
...    LNBTS/DSCPPR-1:dscpMarking:arpValueStart=8|dscpValue=1
...    LNBTS:qciTab70:dscpProfIdx=2
...    LNBTS:qciTab70:dscp=63
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStop=15|dscpValue=2
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStart=8|dscpValue=2
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStop=7|dscpValue=3
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStart=6|dscpValue=3
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStop=5|dscpValue=4
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStart=4|dscpValue=4
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStop=3|dscpValue=5
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStart=2|dscpValue=5
...    LNBTS:qciTab70:rlcProfIdx=1
...    LNBTS:qciTab66:dscpProfIdx=2
@{2611}
...    LNBTS/LNBTS_FDD-0:actPubSafetyBearers=true
...    LNCEL:inactivityTimerPubSafety=1000

@{518}
...    LNBTS:actOperatorQCI=true
...    LNBTS:qciTabOperator:dscpProfIdx=2
@{1231}    LNBTS:actOperatorQCIGBR=true
@{7897}
...    LNBTS:actIncNumOperatorQci=true
...    LNBTS:qciTabOperator:resType=nonGBR|qci=98
@{modify_operator_to_GBR_qci128}
...    LNBTS:qciTabOperator:lcgid=2
...    LNBTS:qciTabOperator:resType=GBR|qci=128
...    LNBTS:qciTabOperator:gbrOverbookingFactor=0
${ue_capability}    SEPARATOR=
...    D59809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A0
...    0000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000
...    003A00000001D00000001BFBFFEC800801C2E4000000016BA0000000808E2740400000820001080002180004400008A00011800023
...    8000480000920001280002580004C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B600
...    01740002F00006D0000FE003A7400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000
...    003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074
...    00000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A0000000141000000D3A0000
...    0000000000000000000000000000000000000000000000000000000202
${UTE_WIRESHARK_FLAG}    ${True}
*** Test Cases ***
CB008931-SR-A-B3_ET_01_01_DSCP_marking_based_on_QCI_and_ARP_during_E-RAB_Modify_procedure
    [Tags]
    [Documentation]    ICS non-GBR bearer QCI8 ARP15 DSCP0.
    ...    Modify non-GBR bearer from QCI8 to QCI70,(QCI70,ARP15,DSCP=2)
    ...    Modify non-GBR bearer from matched ARP15 to matched ARP7,(QCI70,ARP7,DSCP=3)
    ...    Modify non-GBR bearer from matched ARP7 to non matched ARP1,(QCI70,ARP1,DSCP=legacy 63)
    ...    Modify non-GBR bearer from non matched ARP1 to matched ARP4,(QCI70,ARP4,DSCP=4)
    ...    Add GBR bearer QCI2 ARP15 DSCP0
    ...    Modify GBR bearer from matched ARP15 to non matched QCI7,(QCI70,ARP7,DSCP=legacy 62)
    ...    Modify GBR bearer from non matched ARP7 to matched QCI8,(QCI70,ARP8,DSCP=1)
    Start To Capture Eth3 Wireshark Log
    Attach UE and Start traffic for QCI8    ue_id=1
    Modify default bearer QCI8 to QCI70 and DSCP should be 2
    Modify default bearer ARP priority to 7 and DSCP should be 3
    Modify default bearer ARP priority to 1 and DSCP should be 63
    Modify default bearer ARP priority to 4 and DSCP should be 4
    Add QCI2 Bearer and Start traffic for QCI2    ue_id=1
    Modify QCI2 Bearer ARP priority to 7 and DSCP should be 62
    Modify QCI2 Bearer ARP priority to 8 and DSCP should be 1
    Stop To Capture Eth3 Wireshark Log

CB008931-SR-A-B2_ET_02_01_DSCP_marking_for_different_types_of_operator_specified_bearers_which_cross_with_LTE518_LTE1231_LTE7897
    [Documentation]    non GBR Operator Bearer QCI254,ARP15,DSCP=2
    ...    non GBR IncNumOperator Bearer QCI98 ARP6 DSCP3
    ...    GBR Operator Bearer QCI128,ARP4,DSCP=4
    ...    GBR PubSafe Operator Bearer QCI66,ARP3,DSCP=5
    [Tags]
    Start To Capture Eth3 Wireshark Log
    Attach UE and Add QCI254 Bearer    ue_id=2
    Start traffic for UE2 QCI254 nonGBR and DSCP should be 2
    Add QCI98 Bearer    ue_id=2
    Start traffic for UE2 QCI98 nonGBR and DSCP should be 3
    Add QCI128 Bearer    ue_id=2
    Start traffic for UE2 QCI128 GBR and DSCP should be 4
    Add PubSafe QCI66 Bearer    ue_id=2
    Start traffic for UE2 QCI66 GBR and DSCP should be 5
    Stop To Capture Eth3 Wireshark Log

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1, trf_type: internal}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...     - {qci: 70, priority: 14, preemption: 1, vulnerability: 1, pdn: 1}
    ...     - {qci: 8, default: on, pdn: 2, trf_type: internal}
    ...     - {qci: 98, priority: 6, preemption: 1, vulnerability: 1, gbr: no, delay: 100, pdn: 1}
    ...     - {qci: 128, priority: 4, preemption: 1, vulnerability: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, delay: 100, pdn: 1}
    ...     - {qci: 66, priority: 3, preemption: 1, vulnerability: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 254, priority: 15, gbr: no, delay: 100, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/1    capability: ${ue_capability}
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    capability: ${ue_capability}

Start To Capture Eth3 Wireshark Log
    Run Keyword    Execute Cmd On PC
    ...    sudo tcpdump -i eth3 -s0 -vvv -w ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap>& tmp_3.txt&

Stop To Capture Eth3 Wireshark Log
    ${tshark_pid}    get_linux_process_id    tcpdump    ute_wireshark_eth3_8931
    kill_linux_process    ${tshark_pid}

Modify qci
    [Arguments]    ${ue_id}=1    ${bearer_id}=1    ${qci}=1
    Execute Egate Command    bearer_mod ue=${ue_id} id=${bearer_id} qci=${qci}    pass_regexp=has been modified

Attach UE and Add QCI254 Bearer
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_attach id=${ue_id} cell=1
    Execute Egate Command    bearer_add ue=${ue_id} id=9 filter=9 precedence=9    created

Attach UE and Start traffic for QCI8
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_attach id=${ue_id} cell=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=ul protocol=udp qci=8 Mbps=1 duration=600 trf_id=1

Modify ARP priority
    [Arguments]    ${ue_id}=1    ${bearer_id}=8    ${priority}=10
    Execute Egate Command    bearer_mod ue=${ue_id} id=${bearer_id} priority=${priority} vulnerability=off preemption=off
    ...    has been modified

Add QCI128 Bearer
    [Arguments]    ${ue_id}
    Delta Commission Parameters    ${modify_operator_to_GBR_qci128}
    Execute Egate Command    bearer_add ue=${ue_id} id=7 filter=11 precedence=11    created

Add QCI98 Bearer
    [Arguments]    ${ue_id}
    Delta Commission Parameters    ${7897}
    Execute Egate Command    bearer_add ue=${ue_id} id=6 filter=10 precedence=10    created

Add QCI2 Bearer and Start traffic for QCI2
    [Arguments]    ${ue_id}
    Execute Egate Command    bearer_add ue=${ue_id} id=3 filter=3 precedence=3    created
    Execute Uex Command    trf_data_start ue=${ue_id} dir=ul protocol=udp qci=2 Mbps=1 duration=600 trf_id=1

Add PubSafe QCI66 Bearer
    [Arguments]    ${ue_id}    ${by}=pgw
    Execute Egate Command    bearer_add ue=${ue_id} id=8 filter=1 precedence=2 by=${by}    created

Check Dscp should exist and not exist
    [Arguments]    ${dscp_exist}    ${dscp_not_exist}
    ${dscp_count}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap    ${dscp_exist}
    Should Be True    ${dscp_count}>1
    ${dscp_others_count}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap    ${dscp_not_exist}
    should be equal As Numbers    ${dscp_others_count}    0

Modify default bearer QCI8 to QCI70 and DSCP should be 2
    Modify qci    ue_id=1    bearer_id=1    qci=70
    Wait traffic packet modified
    ${dscp1}    catenate    udp and ip.dsfield.dscp == 2
    ${dscp2}    catenate    udp and ip.dsfield.dscp != 2 and ip.dsfield.dscp != 0
    Check Dscp should exist and not exist    dscp_exist=${dscp1}    dscp_not_exist=${dscp2}

Modify default bearer ARP priority to 7 and DSCP should be 3
    Modify arp priority    ue_id=1    bearer_id=1    priority=7
    Wait traffic packet modified
    ${dscp1}    catenate    udp and ip.dsfield.dscp == 3
    ${dscp2}    catenate    udp and ip.dsfield.dscp != 2 and ip.dsfield.dscp != 3 and ip.dsfield.dscp != 0
    Check Dscp should exist and not exist    dscp_exist=${dscp1}    dscp_not_exist=${dscp2}

Modify default bearer ARP priority to 1 and DSCP should be 63
    Modify arp priority    ue_id=1    bearer_id=1    priority=1
    Wait traffic packet modified
    ${dscp1}    catenate    udp and ip.dsfield.dscp == 63
    ${dscp2}    catenate    udp and ip.dsfield.dscp != 2 and ip.dsfield.dscp != 3 and ip.dsfield.dscp != 63 and ip.dsfield.dscp != 0
    Check Dscp should exist and not exist    dscp_exist=${dscp1}    dscp_not_exist=${dscp2}

Modify default bearer ARP priority to 4 and DSCP should be 4
    Modify arp priority    ue_id=1    bearer_id=1    priority=4
    Wait traffic packet modified
    ${dscp1}    catenate    udp and ip.dsfield.dscp == 4
    ${dscp2}    catenate
    ...    udp and ip.dsfield.dscp != 2 and ip.dsfield.dscp != 3 and ip.dsfield.dscp != 63 and ip.dsfield.dscp != 4 and ip.dsfield.dscp != 0
    Check Dscp should exist and not exist    dscp_exist=${dscp1}    dscp_not_exist=${dscp2}

Modify QCI2 Bearer ARP priority to 7 and DSCP should be 62
    Modify arp priority    ue_id=1    bearer_id=3    priority=7
    Wait traffic packet modified
    ${dscp1}    catenate    udp and ip.dsfield.dscp == 62
    ${dscp2}    catenate
    ...    udp and ip.dsfield.dscp !=2 and ip.dsfield.dscp !=3 and ip.dsfield.dscp !=63 and ip.dsfield.dscp !=4 and ip.dsfield.dscp !=0
    ...    and ip.dsfield.dscp != 62
    Check Dscp should exist and not exist    dscp_exist=${dscp1}    dscp_not_exist=${dscp2}

Modify QCI2 Bearer ARP priority to 8 and DSCP should be 1
    Modify arp priority    ue_id=1    bearer_id=3    priority=8
    Wait traffic packet modified
    ${dscp1}    catenate    udp and ip.dsfield.dscp == 1
    ${dscp2}    catenate
    ...    udp and ip.dsfield.dscp != 2 and ip.dsfield.dscp != 3 and ip.dsfield.dscp != 63 and ip.dsfield.dscp != 4 and ip.dsfield.dscp != 0 and
    ...    ip.dsfield.dscp != 62 and and ip.dsfield.dscp != 1
    Check Dscp should exist and not exist    dscp_exist=${dscp1}    dscp_not_exist=${dscp2}

Start traffic for UE2 QCI254 nonGBR and DSCP should be 2
    Execute Uex Command    trf_data_start ue=2 dir=ul protocol=udp qci=254 Mbps=1 duration=600 trf_id=1
    Wait traffic packet modified
    ${dscp1}    catenate    udp and ip.dsfield.dscp == 2
    ${dscp2}    catenate    udp and ip.dsfield.dscp != 2
    Check Dscp should exist and not exist    dscp_exist=${dscp1}    dscp_not_exist=${dscp2}

Start traffic for UE2 QCI98 nonGBR and DSCP should be 3
    Execute Uex Command    trf_data_start ue=2 dir=ul protocol=udp qci=98 Mbps=1 duration=600 trf_id=1
    Wait traffic packet modified
    ${dscp1}    catenate    udp and ip.dsfield.dscp == 3
    ${dscp2}    catenate    udp and ip.dsfield.dscp != 3 and and ip.dsfield.dscp != 2
    Check Dscp should exist and not exist    dscp_exist=${dscp1}    dscp_not_exist=${dscp2}

Start traffic for UE2 QCI128 GBR and DSCP should be 4
    Execute Uex Command    trf_data_start ue=2 dir=ul protocol=udp qci=128 Mbps=1 duration=600 trf_id=1
    Wait traffic packet modified
    ${dscp1}    catenate    udp and ip.dsfield.dscp == 4
    ${dscp2}    catenate    udp and ip.dsfield.dscp != 3 and and ip.dsfield.dscp != 2 and and ip.dsfield.dscp != 4
    Check Dscp should exist and not exist    dscp_exist=${dscp1}    dscp_not_exist=${dscp2}

Start traffic for UE2 QCI66 GBR and DSCP should be 5
    Execute Uex Command    trf_data_start ue=2 dir=ul protocol=udp qci=66 Mbps=1 duration=600 trf_id=1
    Wait traffic packet modified
    ${dscp1}    catenate    udp and ip.dsfield.dscp == 5
    ${dscp2}    catenate    udp and ip.dsfield.dscp != 3 and and ip.dsfield.dscp != 2 and and ip.dsfield.dscp != 4 and ip.dsfield.dscp != 3
    Check Dscp should exist and not exist    dscp_exist=${dscp1}    dscp_not_exist=${dscp2}

Wait traffic packet modified
    sleep    3s
