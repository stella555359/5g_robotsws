*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env And IP added for simGNB
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-L3CN1_SG14    owner-jiangping.cao    release-5G23R3     CB008140-DD    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
@{FAULTS_EXCLUDED_CHECKING}
...    4707
@{PARAMS_IN_SWCONFIG}
...    ${DisableL2PS_XPU_monitoring}=0
${DisableL2PS_XPU_monitoring}    0x580647
@{PARAMS_IN_SCF}
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRCELL-2:nrarfcn=663400
...    NRCELL-2:gscnOrSsPbchArfcn=8159
...    NRBTS-1:actFdmScheduling=true
...    @{8140CA}

@{8140CA}
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.141
...    NRBTS:actMeasBasedSCellAdditionSa=disabled
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=1
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:weightForIgnbCaSelection=1
...    NRCELL-1:actK1Opt=intraAndInter-gNB
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:actK1Opt=intraAndInter-gNB
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterGnbCa=DLOnly
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRBTS/SNSSAI-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:actCarrierAggregation=true
...    NRCELL-1:allowUnsuppBcOrBcs=accept unknown BCSs
...    NRCELL-2:allowUnsuppBcOrBcs=accept unknown BCSs
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-2:pucchModeSelect=longPucch
...    @{NRADJGNB_NRADJNRCELL}
...    @{XPAP}


@{NRADJGNB_NRADJNRCELL}
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:gNodeBIdCtrl=gnbControlled
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=2
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=0
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=11
...    NRBTS/NRADJNRCELL-1:nrarfcn=368400
...    NRBTS/NRADJNRCELL-1:physCellId=60
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:gNbId=2
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlOnly

@{XPAP}
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:localNeDN=MRBTS-1/NRBTS-1
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpAssocMaxRetrans=7
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpDscp=46
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpHeartbeatInterval=20
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpMaxPayloadSize=1395
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpRtoMax=30000
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpRtoMin=1000
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpSackDelay=200
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpSackFreq=2
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:sctpWaitTimeInitSeqRetry=240
...    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1:udpDscp=18
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:ipAddress=10.0.1.141
...    MRBTS/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1:remoteNeType=GNB

${ue_id}    1

${CB008140_N_Capa_Support_2CC_3CC_n3_n28_n41_n77}    SEPARATOR=
...    e9a09000575f5a13160003c320016093170019c3d09009b20c39f30c7942c0e098040623809dc6c06c0d608c21a08107482c036b64c558d0e
...    7c471e819f604f8c48e3c873ea39f30c7942c0e070f05c00ffc0070005f000540001c0a836016b04610d04083c4160195b262ac4873ec09f1
...    1c78c48e3c873ea39f30c7942c0e070f09fd8000007f6000000540001c0aa36266b04610d04083a4160185b262a88873e238f11c7a067d813
...    e31cf9863ca1607038782e007fe003801ff8002a0000e0541b06f582308682041e20b00cad931562439f11c7b027c62471e439f51cf9863ca
...    1607038784fff800003ffe000002a0000e0551b137582308680000100b00c2d926544439f11c79063d033ec09f00e7cc31e50b0381c3c17aa
...    aaaaa9eaaaaaaa1500007004961e26000713000000058158b898001c4c000e260000010b02b17008003098061300004160563e01000606c0c
...    260184c0001858158b8040018020303600040b02b1f00800300c0606c0c26800142c0ac5c02000c0d8184c0003058158780400184c0003858
...    15878040018020004058158783600181b000485815878040018060005058158780c00181b0005858158b80400180603036000c0b02b0f06c0
...    038980000342c0ac5c4c000c26018020007058158f89800184c030040606c001e160562e2600060080c0d800402c0ac7c4d000c0101806030
...    3600110b0201200dc0068099000a02688a03a4250a244d8e7c38912244d8e7c38912244d8e7c38d1224489b1cf871224489b1cf871a244891
...    3639f0e2448913639f0e14489b1cf870a244d8e7c3851226c73e1c28913639f0e14489b1cf871224489b1cf870a244d8e7c38912244d8e7c3
...    8d1224489b1cf871224489b1cf871a2448913639f0c06c486318c6318c6318c6318c6307a09801e00140e0a00e0601280380030120020301f
...    048010000000080040000001000006008000010040000100200000c0100000800800005004002008020080000600400003802001000000040
...    0004002000024010000060080000a004000058020010240900400006019ca9aca9ac14ac0cac19ac15aca5bc99bc05ac0dac04ac08ac1da06
...    82000012ca4a080000cb29302000032ca48080001cb29202000092ca48080002cb293020000d2ca48080003cb29202000112ca48080004cb2
...    9202000152ca48080005cb29282000192ca480800018b292019a55574aaaa9545d2a8aa0b154162a83455298aa4d154062a8145526aaa0f14
...    2405e02540a05028140a05028140a05028140a05028140a050011080801002020040088040080101002004040080110080600a02004008080
...    100230100c014040300501002004040080110080800a02020028080b01630100c01804030050100c018040080110080600a02018028080100
...    210100c014040080108080600a02018028404030060100c018202018030080600a10100c014040300510080600a02018030080600a10100c0
...    18040080110080100202004008080600a30100200404008010100c014040300510080100202018030080600c30100200404030050100c0180
...    4030051aa1f000102030406070a0b0c0d101112131418191b1c1d1f2125262728292a2d2f414182d

${DU-to-CU-RRCInfo}    SEPARATOR=
...    100200c0000100c1400302000e00c240020100


${ExtDu-to-PrimeDu-RrcInfo}    SEPARATOR=
...    0044002880a360631078d167cb80042cdb40000019b193e8a81d29c028806b010a02190a20860c23286d9220064401b90018000080b290202
...    51003c0200240400498118140d484362194088512f08e54140188aa88008c00609d5000708879400e0402188001c221e38005c0c045100038
...    443c7000b8200862000708878e08170501144000e110f1c1020800000286181018202c0e0ba000e5000000001002000c04803305c00300800
...    0000280059f10082320400000000002800554d80800800000013d0050a51451e52853253c5463857ffc

*** Test Cases ***
CB008140-DD005_ET_Verify_gnb_on_reception_error_indication_for_igNB_CA_modification_request_scell_addition
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       Handling the error indication message for igNB CA modification request during scell addition at the primary gnb
    ...    2. Test Case Steps:
    ...         a.set error indication for igNB CA modification request
    ...         b.UE attach to NRCELL-2
    ...         c.trigger blind scell (nrcell-11) of simgnb
     [Tags]     QC_258359    DD005
    Precondition for CA to sim gNB4 Parameter
    Set sim gNB4 Parameter for igNB CA modification request
    SA UE attach with blind addition
    Check Wireshark Log    ${CURDIR}${/}A2A_DD_005${/}a2a.ini    wait_string=UEContextRelease::13

*** Keywords ***
Common Suite Setup And Setup Airphone Env And IP added for simGNB
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_2N77_AEQU_AEQK

Perform Steps After Onair
    Get Correct Xp XgU Version

Get Correct Xp XgU Version
    ${IgNBCAXpProtocol_Version}    Get Xp Version
    ${IgNBCAXgUProtocol_Version}    Get Xgu Version
    Set Suite Variable    ${IgNBCAXpVersion}    ${IgNBCAXpProtocol_Version}
    Set Suite Variable    ${IgNBCAXgUVersion}    ${IgNBCAXgUProtocol_Version}

Precondition for CA to sim gNB4 Parameter
    Execute Egate Command    sim_trace enb=4 protocol=xn on
    Execute Egate Command    enb_xp_param xp_peers=2 id=4
     ...     pass_regexp=GNB-4: XpAP Link with GNB-2.*is up    timeout=100    sleep_time=10
    ${cmd1}    catenate    gnb_cell_param gnb=4 id=11 Cell_BWP_List=3,4,5,6 cell_Available=yes
    ...    weightForSCellSelection=50 lteNrDssMode=lteNrDssModeNone
    Execute Egate Command    ${cmd1}
	${cmd2}    catenate    gnb_param id=4 bwp_profile_id=54 bwp_profile_type=dedicated
    ...    act_multiple_dedicated_bwps=no location_bw_ul=1:0 location_bw_dl=1:1 Inter_gNB_CA_Allowed=yes
    ...    CellLoadReportingPeriodicity=000 IgNBCAXpProtocolVersion=${IgNBCAXpVersion}
    ...    IgNBCAXgUProtocolVersion=${IgNBCAXgUVersion}
    Execute Egate Command    ${cmd2}
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2
    ...    pass_regexp=IgNBCAConfigurationUpdateIndication
    ${cmd3}    catenate    ignb_ca_addition_param gnb_id=4 DU-to-CU-RRCInfo=${DU-to-CU-RRCInfo}
    ...    ExtDu-to-PrimeDu-RrcInfo=${ExtDu-to-PrimeDu-RrcInfo}
    Execute Egate Command    ${cmd3}

Set sim gNB4 Parameter for igNB CA modification request
    Execute Egate Command    ignb_ca_modification_param action=error_ind gnb_id=4

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${CB008140_N_Capa_Support_2CC_3CC_n3_n28_n41_n77}
    ${gNB1}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=$GNB_S1U_ADDR x2=$GNB_X2_ADDR:36422
    ...    ng=$GNB2_NG_ADDR gnb_id=0x01:22 daemon=$SERVER_IP:$EDAEMON_PORT xn=$GNB2_XN_ADDR x2_peers=none amf=1-3
    ...    plmnList=311:489 nssai=0x1:0xd143a5 xp=10.0.1.2:32742 xpu=10.0.1.2:32742 xp_management=on
    Update Cfg    ${gNB1}
    ${gNB_cell2}    catenate    set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x02 tdd_cell=on gscn=8159
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=663400:663400 mandatory_for_activation=off
    Update Cfg    ${gNB_cell2}
    ${sim_gNB4}    catenate    set_gnb id=4 type=simulated plmn=311:489 xn=10.0.1.141 ng=10.0.1.140 gnb_id=0x02:22
    ...    daemon=$SERVER_IP:$DAEMON_PORT x2_peers=none amf=1 nssai=0x1:0xd143a5 xp=10.0.1.141:32742
    ...    xpu=10.0.1.141:32742 xp_management=on
    Update Cfg    ${sim_gNB4}
    Update Cfg    gnb_param id=4 send_xn_setup=false sib1_period=40 xn_listening_socket=on
    ${simgNB4_cell11}    catenate    set_cell id=11 gnb=4 pci=20:0 tac=0 nrci=0x0B tdd_cell=off proxy=10.0.1.140:9999
    ...    nr_arfcn=349400:368400 gscn=4605 nr_scs=15kHz bs_channel_bandwidth=10MHz
    Update Cfg    ${simgNB4_cell11}

SA UE attach with blind addition
    [Arguments]    ${ue_id}=1    ${target_cells}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    UE1: IS IDLE
