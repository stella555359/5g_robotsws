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
...    @{LNCEL_BTS}
...    @{HO}
...    @{518}
...    @{1231}
...    @{2611}
@{8931}
...    LNBTS:actQciArpToDscpMarking=true
...    LNBTS:qciTab8:dscpProfIdx=2
...    LNBTS:qciTab2:dscpProfIdx=1
...    LNBTS:qciTab66:dscpProfIdx=2
...    LNBTS:qciTabOperator:dscpProfIdx=2
...    LNBTS:qciTab1:dscpProfIdx=1
...    LNBTS/DSCPPR-1:dscpMarking:arpValueStop=4|dscpValue=0
...    LNBTS/DSCPPR-1:dscpMarking:arpValueStart=0|dscpValue=0
...    LNBTS/DSCPPR-1:dscpMarking:arpValueStop=7|dscpValue=63
...    LNBTS/DSCPPR-1:dscpMarking:arpValueStart=5|dscpValue=63
...    LNBTS/DSCPPR-1:dscpMarking:arpValueStop=15|dscpValue=44
...    LNBTS/DSCPPR-1:dscpMarking:arpValueStart=8|dscpValue=44
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStop=4|dscpValue=1
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStart=0|dscpValue=1
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStop=7|dscpValue=62
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStart=5|dscpValue=62
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStop=15|dscpValue=43
...    LNBTS/DSCPPR-2:dscpMarking:arpValueStart=8|dscpValue=43

@{2611}
...    LNBTS/LNBTS_FDD-0:actPubSafetyBearers=true
...    LNCEL:inactivityTimerPubSafety=1000

@{HO}
...    LNBTS:actSelMobPrf=false
...    LNBTS/MODPR-0:freqLayListLte=1400,1700
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1700

@{LNCEL_BTS}
...    LNBTS:actLteNrDualConnectivity=false
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNBTS:actIfHo=enabled
...    LNBTS:actSelMobPrf=false
...    LNBTS/MODPR-0:autoAdapt=false
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-2/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-2/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1700
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19700
...    LNCEL-1:threshold1=75
...    LNCEL-2:threshold1=76
${eutra_cap_wo_gap}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB529D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFED800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C28040300E803C00000180000008
${ue_capability}        SEPARATOR=
...    D59809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00
...    000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D0
...    0000001BFBFFEC800801C2E4000000016BA0000000808E2740400000820001080002180004400008A0001180002380004800009200012800025
...    80004C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000
...    003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A0000
...    0001D00000000E800000007400000003A0000000141000000D3A00000000000000000000000000000000000000000000000000000000000202

${Disable_8931}    LNBTS:actQciArpToDscpMarking=false
@{518}    LNBTS:actOperatorQCI=true
@{1231}    LNBTS:actOperatorQCIGBR=true
${UTE_WIRESHARK_FLAG}    ${True}

*** Test Cases ***
CB008931-SR-A-B1_ET_01_01_DSCP_marking_based_on_QCI_and_ARP_during_Initial_Context_Setup
    [Documentation]    ICS UE1 with QCI8 ARP7 DSCP=62, QCI2 ARP1 DSCP=0, QCI66 ARP4 DSCP=1
    ...    ICS UE2 with QCI8 and QCI254 ARP15 DSCP=43
    [Tags]
    Start To Capture Eth3 Wireshark Log
    Attach UE    ue_id=1
    Start Traffic for UE1 QCI8 QCI2 QCI66
    QCI8 QCI2 QCI66 Bearers for UE1 DSCP should be 62 and 0 and 1
    Attach UE    ue_id=2
    Start Traffic for UE2 QCI254
    QCI254 Bearer for UE2 DSCP should be 43
    Stop To Capture Eth3 Wireshark Log

CB008931-SR-A-B1_ET_03_01_DSCP_marking_during_incoming_intra_eNB_HO
    [Documentation]    inta eNB HO will not effect DSCP
    ...    Online change actQciArpToDscpMarking from true to false will not affect existed bearer DSCP
    ...    Modify bitrate will not affect existed bearer DSCP
    ...    Following created bearer DSCP will be affected
    ...    Following intra HO will not affect existed bearer DSCP
    [Tags]
    Start To Capture Eth3 Wireshark Log
    UE3 Attach to eNB1 Cell2
    Trigger Intra-Enb Inter-Cell handover    ue_id=3    enb_id=1    cell_id=1
    Start Traffic for UE3 QCI2 and DSCP should be 0
    Online change actQciArpToDscpMarking
    Modify QCI2 Bearer bitrate and Check DSCP
    Created QCI1 bearer and Check DSCP
    Trigger Intra-Enb Inter-Cell handover    ue_id=3    enb_id=1    cell_id=2
    QCI2 Bearer DSCP should keep 0
    Stop To Capture Eth3 Wireshark Log

*** Keywords ***

Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, priority: 7, preemption: 1, vulnerability: 1, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 2, preprovisioned: on, filter: 5, precedence: 5, priority: 1, preemption: 1, vulnerability: 1,
    ...        gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...     - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...     - {qci: 98, priority: 6, preemption: 1, vulnerability: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, delay: 100, pdn: 1}
    ...     - {qci: 128, priority: 4, preemption: 1, vulnerability: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, delay: 100, pdn: 1}
    ...     - {qci: 66, preprovisioned: on, filter: 5, precedence: 6, priority: 4, preemption: 1, vulnerability: 1,
    ...        gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...     - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...     - {qci: 254, gbr: no, preprovisioned: on, filter: 5, precedence: 6, preemption: 1, vulnerability: 1, priority: 15, delay: 100, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/1    capability: ${ue_capability}
    Update Yaml    UEs/UE_sets/2    capability: ${ue_capability}
    Update Yaml    UEs/UE_sets/3    capability: ${ue_capability}

Start To Capture Eth3 Wireshark Log
    Run Keyword    Execute Cmd On PC
    ...    sudo tcpdump -i eth3 -s0 -vvv -w ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap>& tmp_3.txt&

Stop To Capture Eth3 Wireshark Log
    ${tshark_pid}    get_linux_process_id    tcpdump    ute_wireshark_eth3_8931
    kill_linux_process    ${tshark_pid}

Start To Capture Eth3 Wireshark Log for QCI2
    ${tshark_pid}    get_linux_process_id    tcpdump    ute_wireshark_eth3_8931
    kill_linux_process    ${tshark_pid}
    Run Keyword    Execute Cmd On PC
    ...    sudo tcpdump -i eth3 -s0 -vvv -w ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931_1.pcap>& tmp_31.txt&

Attach UE
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_attach id=${ue_id} cell=1

Start Traffic for UE1 QCI8 QCI2 QCI66
    Execute Uex Command    trf_data_start ue=1 dir=ul protocol=udp qci=8 Mbps=1 duration=600 trf_id=1
    Execute Uex Command    trf_data_start ue=1 dir=ul protocol=udp qci=2 Mbps=1 duration=600 trf_id=1
    Execute Uex Command    trf_data_start ue=1 dir=ul protocol=udp qci=66 Mbps=1 duration=600 trf_id=1

QCI8 QCI2 QCI66 Bearers for UE1 DSCP should be 62 and 0 and 1
    Wait for wireshark log collection
    ${dscp_62}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap
    ...    udp and ip.dsfield.dscp == 62
    ${dscp_0}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap
    ...    udp and ip.dsfield.dscp == 0
    ${dscp_1}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap
    ...    udp and ip.dsfield.dscp == 1
    Should Be True    ${dscp_62}>1
    Should Be True    ${dscp_0}>1
    Should Be True    ${dscp_1}>1
    ${dscp_others}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap
    ...    udp and ip.dsfield.dscp != 62 and ip.dsfield.dscp != 0 and ip.dsfield.dscp != 1
    should be equal As Numbers    ${dscp_others}    0

Start Traffic for UE2 QCI254
    Execute Uex Command    trf_data_start ue=2 dir=ul protocol=udp qci=254 Mbps=1 duration=600 trf_id=1

QCI254 Bearer for UE2 DSCP should be 43
    Wait for wireshark log collection
    ${dscp_43}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap
    ...    udp and ip.dsfield.dscp == 43
    Should Be True    ${dscp_43}>1
    ${dscp_others}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap
    ...    udp and ip.dsfield.dscp != 62 and ip.dsfield.dscp != 0 and ip.dsfield.dscp != 1 and ip.dsfield.dscp != 43
    should be equal As Numbers    ${dscp_others}    0

UE3 Attach to eNB1 Cell2
    Execute Uex Command    ue_attach id=3 cell=2 ue_eutra_capabilities=${eutra_cap_wo_gap}

Trigger Intra-Enb Inter-Cell handover
    [Arguments]    ${cell_id}    ${ue_id}=1    ${enb_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq ${cell_id}))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ho_flow1    overall_timeout=30
    Execute Uex Command    ue_ho id=${ue_id} enb=${enb_id} cell=${cell_id}
    Flow Occurred As Expected    alias=ho_flow1

Start Traffic for UE3 QCI2 and DSCP should be 0
    Execute Uex Command    trf_data_start ue=3 dir=ul protocol=udp qci=2 Mbps=1 duration=600 trf_id=1
    Wait traffic packet modified
    ${dscp_0}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap
    ...    udp and ip.dsfield.dscp == 0
    Should Be True    ${dscp_0}>1
    ${dscp_others}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap
    ...    udp and ip.dsfield.dscp != 0
    should be equal As Numbers    ${dscp_others}    0

Online change actQciArpToDscpMarking
    Delta Commission Parameters    ${Disable_8931}

Modify QCI2 Bearer bitrate and Check DSCP
    Modify QCI2 Bearer bitrate to 42    ue_id=3     bearer_id=3    gbr_dl=42
    Wait for wireshark log collection
    ${dscp_others}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap
    ...    udp and ip.dsfield.dscp != 0
    should be true    ${dscp_others}<2


Created QCI1 bearer and Check DSCP
    Add QCI1 Bearer    ue_id=3    bearer_id=2
    Start Traffic for UE3 QCI1 and DSCP should be legacy 46

Start Traffic for UE3 QCI1 and DSCP should be legacy 46
    Execute Uex Command    trf_data_start ue=3 dir=ul protocol=udp qci=1 Mbps=1 duration=600 trf_id=1
    Wait traffic packet modified
    ${dscp_46}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap
    ...    udp and ip.dsfield.dscp == 46
    Should Be True    ${dscp_46}>1
    ${dscp_others}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931.pcap
    ...    udp and ip.dsfield.dscp != 0 and ip.dsfield.dscp != 46
    should be equal As Numbers    ${dscp_others}    0

QCI2 Bearer DSCP should keep 0
    Execute Uex Command    trf_data_stop ue=3 qci=1 trf_id=1
    Start To Capture Eth3 Wireshark Log for QCI2
    Wait for wireshark log collection
    ${dscp_0}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931_1.pcap
    ...    udp and ip.dsfield.dscp == 0
    Should Be True    ${dscp_0}>1
    ${dscp_others}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/ute_wireshark_eth3_8931_1.pcap
    ...    udp and ip.dsfield.dscp != 0 and syscom
    should be equal As Numbers    ${dscp_others}    0

Modify QCI2 Bearer bitrate to 42
    [Arguments]    ${ue_id}=1    ${bearer_id}=1    ${gbr_dl}=40
    Execute Egate Command    bearer_mod ue=${ue_id} id=${bearer_id} gbr_dl=${gbr_dl}    pass_regexp=has been modified

Add QCI1 Bearer
    [Arguments]    ${ue_id}=1    ${bearer_id}=1
    Execute Egate Command    bearer_add ue=${ue_id} id=${bearer_id} filter=2 precedence=2    created

Wait traffic packet modified
    sleep    10

Wait for wireshark log collection
    sleep    5
