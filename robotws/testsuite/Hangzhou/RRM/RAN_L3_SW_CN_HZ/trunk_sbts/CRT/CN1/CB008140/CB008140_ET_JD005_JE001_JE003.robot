*** Settings ***
Documentation    Suite documentation
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN1_SG14
...    owner-jun.15.zhang    release-SBTS23R3    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SNAPSHOT_FLAG}     pass:True,fail:True
${SOS_REPORT_FLAG}     pass:True,fail:True
${GNB_BIP_FLAG}    ${True}
${GNB_BIP_SIZE}    5000
${SOS_REPORT_STARTUP_1_FLAG}    pass:True,fail:True
@{FAULTS_EXCLUDED_CHECKING}
...    7108
...    7109

#Case based on CB008140_ET_BC002.robot

${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

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
...    NRCELL-2:nrarfcn=660000
...    NRCELL-2:gscnOrSsPbchArfcn=8124
...    NRBTS-1:actFdmScheduling=true
...    @{8140CA}

@{8140CA}
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.141
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:maxNumScellsDl=3
...    NRBTS:maxNumScellsUl=1
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:weightForIgnbCaSelection=1
...    NRCELL-1:a1MeasSCellAddEnabled=rsrp
...    NRCELL-1:actK1Opt=intraAndInter-gNB
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:a1MeasSCellAddEnabled=rsrp
...    NRCELL-2:actK1Opt=intraAndInter-gNB
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterGnbCa=DLOnly
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS:actCarrierAggregation=true
...    NRCELL-1:allowUnsuppBcOrBcs=accept unknown BCSs
...    NRCELL-2:allowUnsuppBcOrBcs=accept unknown BCSs
...    NRCELL-1:pucchModeSelect=longPucch
...    NRCELL-2:pucchModeSelect=longPucch

...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=85
...    NRCELL-1:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=85
...    NRCELL-2:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    @{NRADJGNB_NRADJNRCELL}
...    @{XPAP}

@{NRADJGNB_NRADJNRCELL}
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
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
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
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

@{LOCK_NRADJGNB2_ADMINISTRATIVESTATE}
...    NRBTS/NRADJGNB-2:administrativeState=Locked

@{UNLOCK_NRADJGNB2_ADMINISTRATIVESTATE}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked

@{DEL_XNLINK}
...    delete:NRBTS/NRADJGNB-2:xnLinkRef

@{ADD_XNLINK}
...    NRBTS/NRADJGNB-2:xnLinkRef=2

#hexstring can be copied from CB008140-ET-BB002
${DU-to-CU-RRCInfo}    SEPARATOR=
...    100200c0000100c1400302000e00c240020100

${ExtDu-to-PrimeDu-RrcInfo}    SEPARATOR=
...    0044002880a360631078d167cb80042cdb40000019b193e8a81d29c028806b010a02190a20860c23286d9220064401b90018000080b290202
...    51003c0200240400498118140d484362194088512f08e54140188aa88008c00609d5000708879400e0402188001c221e38005c0c045100038
...    443c7000b8200862000708878e08170501144000e110f1c1020800000286181018202c0e0ba000e5000000001002000c04803305c00300800
...    0000280059f10082320400000000002800554d80800800000013d0050a51451e52853253c5463857ffc

*** Test Cases ***
CB008140-ET-JD005_Fault 7329 raised when igNB CA XN setup failure and clear
    [Documentation]
    ...    The fault 7329 raise and clear based on IGNB CA XN link setup failure and recover.
    ...    Fault below checked by this case:
    ...    7329 Inter-gNB CA Xn communication failure
    ...    [Configuration]:
    ...    Cell id=2  gnb=2 pci=16:2 tac=200 tdd_cell=on  band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz SCellWeight=40 Cellid=0x4001
    ...    Cell id=11 gnb=4 pci=20:0 tac=200 tdd_cell=off band=n3  nr_arfcn=349400:368400 gscn=4605 chBw=10MHz  SCellWeight=40 Cellid=0x800b/32779
    ...    UE1 inter gNB2 Cell2 + gNB4 Cell11 TF 2CC CA
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session Setup On Cell1_2, trigger A1 to Add SCells, and then release.
    ...         b: Drop Xn and make error indication
    ...         c. UE1 Register And PDU Session Setup On Cell1_2, trigger A1 to Add SCells, and then release.
    ...         d. Recover Xn
    ...         e. UE1 Register And PDU Session Setup On Cell1_2, trigger A1 to Add SCells, and then release.
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful, Add Cell2_11 as Scells for 2CC, UE release finish OK.
    ...         Step b: Xn drop and re-setup fail, alarm with fault 7329 raised
    ...         Step c: UE1 Register And PDU Session Setup Successful, Not Add Scells for igNB CA, UE release finish OK.
    ...         Step d: Xn drop and re-setup success, alarm with fault 7329 cleared
    ...         Step e: UE1 Register And PDU Session Setup Successful, Add Cell2_11 as Scells for 2CC, UE release finish OK.
    [Tags]     QC_278858    JD005    CA_LABEL-TF (100MHz_tDD_n77 + 10MHz_FDD_n3)
    Set Sim gNB ignb CA Addition Param
    UE Register And Setup PDU Session And A1 To Trigger Sim gNB Scell Addition
    Drop XN And Make Error Indication And Trigger XN Setup
    UE Register And Setup PDU Session And A1 To Trigger No Scell Addition
    Drop XN And Trigger XN Setup
    UE Register And Setup PDU Session And A1 To Trigger Sim gNB Scell Addition
    Check WireShark Log    ${CURDIR}${/}A2A_JD_005${/}a2a.ini    wait_string=IgNBCAReleaseRequestAcknowledge::2

CB008140-ET-JE001_Unsuccessful IGNB CA XP link setup then Fault 7331 raised And IGNB CA XP link setup recover then Fault 7331 cleared
    [Documentation]
    ...    The fault 7331 raise and clear based on IGNB CA XP link setup failure and recover.
    ...    Fault below checked by this case:
    ...    62003 Transport layer connection lost in XP interface
    ...    7331 Inter-gNB CA Xp communication failure
    ...    [Configuration]:
    ...    Cell id=2  gnb=2 pci=16:2 tac=200 tdd_cell=on  band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz SCellWeight=40 Cellid=0x4001
    ...    Cell id=11 gnb=4 pci=20:0 tac=200 tdd_cell=off band=n3  nr_arfcn=349400:368400 gscn=4605 chBw=10MHz  SCellWeight=40 Cellid=0x800b/32779
    ...    UE1 inter gNB2 Cell2 + gNB4 Cell11 TF 2CC CA
    ...    2.Test Case Steps:
    ...         a. Delta Commission To Setup XN XP
    ...         b: Trigger XP Setup With Sim GNB XP Ignore
    ...         c. Clear Sim GNB XP Ignore
    ...         d. UE1 Register And PDU Session Setup On Cell1_2, trigger A1 to Add SCells, and then release.
    ...    3. Expected Results:
    ...         Step a: XN link is available
    ...         Step b: XP setup with XpConnectionStatus unavailable, alarm with fault 7331 raised
    ...         Step c: XpConnectionStatusNotification with XpConnectionStatus available, alarm with fault 7331 cleared
    ...         Step d: UE1 Register And PDU Session Setup Successful, Add Cell2_11 as Scells for 2CC, UE release finish OK.
    [Tags]     QC_47095    JE001    JE003    CA_LABEL-TF (100MHz_tDD_n77 + 10MHz_FDD_n3)
    Delta Commission To Remove XN XP
    Delta Commission To Setup XN And Trigger XP Setup With Sim GNB XP Ignore And Check Alarm
    Clear XP Ignore And Trigger XP Setup And Check Alarm
    #UE Register And Setup PDU Session And A1 To Trigger Sim gNB Scell Addition
    #Check WireShark Log    ${CURDIR}${/}A2A_JE_001${/}a2a.ini    wait_string=IgNBCAReleaseRequestAcknowledge

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_2N77_AEQU_AEQK    ue_count=1

Modify Cfg
    Update Cfg    sim_trace enb=4 protocol=xp,xn,xpu on
    Update Cfg    ue_param id=1 ue_nr_capabilities=${CB008140_GG_Capa_2CC_3CC_4CC_n3_n28_n77_n78}
    ${gNB1}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=$GNB_S1U_ADDR x2=$GNB_X2_ADDR:36422 ng=$GNB2_NG_ADDR
    ...    gnb_id=0x01:22 daemon=$SERVER_IP:$EDAEMON_PORT xn=$GNB2_XN_ADDR x2_peers=none amf=1-3
    ...    plmnList=311:489 nssai=0x1:0xd143a5 xp=10.0.1.2:32742 xpu=10.0.1.2:32742 xp_management=on
    Update Cfg    ${gNB1}
    ${gNB_cell2}    catenate    set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x02 tdd_cell=on
    ...    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=660000:660000 gscn=8124 mandatory_for_activation=off
    Update Cfg    ${gNB_cell2}
    ${sim_gNB4}    catenate    set_gnb id=4 type=simulated plmn=311:489 xn=10.0.1.141 ng=10.0.1.140 gnb_id=0x02:22
    ...    daemon=$SERVER_IP:$DAEMON_PORT x2_peers=none amf=1 nssai=0x1:0xd143a5 xp=10.0.1.141:32742 xpu=10.0.1.141:32742 xp_management=on
    Update Cfg    ${sim_gNB4}
    Update Cfg    gnb_param id=4 send_xn_setup=false sib1_period=40 xn_listening_socket=on
    ${simgNB4_cell11}    catenate    set_cell id=11 gnb=4 pci=20:0 tac=0 nrci=0x0B tdd_cell=off proxy=10.0.2.90:9999
    ...    nr_arfcn=349400:368400 gscn=4605 nr_scs=15kHz bs_channel_bandwidth=10MHz
    Update Cfg    ${simgNB4_cell11}

Perform Steps After Onair
    Get Correct Xp XgU Version

Get Correct Xp XgU Version
    ${IgNBCAXpProtocol_Version}    Get Xp Version
    ${IgNBCAXgUProtocol_Version}    Get Xgu Version
    Set Suite Variable    ${IgNBCAXpVersion}    ${IgNBCAXpProtocol_Version}
    Set Suite Variable    ${IgNBCAXgUVersion}    ${IgNBCAXgUProtocol_Version}

Set Sim gNB ignb CA Addition Param
    Execute Egate Command    sim_trace enb=4 protocol=xn on
    Execute Egate Command    enb_xp_param xp_peers=2 id=4
    ...    pass_regexp=GNB-4: XpAP Link with GNB-2.*is up    timeout=100    sleep_time=10
    ${cmd1}    catenate    gnb_cell_param gnb=4 id=11 Cell_BWP_List=3,4,5,6 cell_Available=yes
    ...    weightForSCellSelection=50 lteNrDssMode=lteNrDssModeNone
    Execute Egate Command    ${cmd1}
    #${cmd2}    catenate    gnb_param id=4 bwp_profile_id=54 bwp_profile_type=dedicated
    #...    act_multiple_dedicated_bwps=no location_bw_ul=1:0 location_bw_dl=1:1  Inter_gNB_CA_Allowed=yes    CellLoadReportingPeriodicity=000
    #...    IgNBCAXpProtocolVersion=${IgNBCAXpVersion} IgNBCAXgUProtocolVersion=${IgNBCAXgUVersion}
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    IgNBCAConfigurationUpdateIndication
    ${cmd3}    catenate    ignb_ca_addition_param gnb_id=4 DU-to-CU-RRCInfo=${DU-to-CU-RRCInfo}
    ...    ExtDu-to-PrimeDu-RrcInfo=${ExtDu-to-PrimeDu-RrcInfo}
    Execute Egate Command    ${cmd3}

UE Register And Setup PDU Session And A1 To Trigger Sim gNB Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=QoS Routing Table    timeout=20s
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=663360    event_type=A1
    ...    threshold=RSRP\ 75
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    pass_regexp=sCellIndex 1    timeout=20s    sleep_time=5
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    pass_regexp=UE1: detached

UE Register And Setup PDU Session And A1 To Trigger No Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${gateway}    pass_regexp=QoS Routing Table    timeout=20s
    ${ScellAdd_A1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=663360    event_type=A1
    ...    threshold=RSRP\ 75
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${ScellAdd_A1} event=A1 srsrp_nr=115 srsrq_nr=40
    ...    fail_regexp=sCellIndex 1    timeout=5s
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    pass_regexp=UE1: detached

Drop XN And Make Error Indication And Trigger XN Setup
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Execute Egate Command    ignb_ca_setup_param id=4 action=error_ind
    Execute Egate Command    link_drop link=xn by=gnb:4 to=gnb:2 msg_type=shutdown
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=unavailable
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Sleep    60s    #igNBCaXnSetupRespTmr
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Raised    fault_id=7329

Drop XN And Trigger XN Setup
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Execute Egate Command    ignb_ca_setup_param id=4 reset
    Execute Egate Command    link_drop link=xn by=gnb:4 to=gnb:2 msg_type=shutdown
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=unavailable
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    FM Fault Should Be Cleared    fault_id=7329
    Sleep    60s    #wait Xp setup
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    IgNBCAConfigurationUpdateIndication

Delta Commission To Remove XN XP
    Execute Egate Command    enb_xp_param xp_peers=2 id=4
    ...    pass_regexp=GNB-4: XpAP Link with GNB-2.*is up    timeout=100    sleep_time=10
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available
    Delta Commission Parameters    ${LOCK_NRADJGNB2_ADMINISTRATIVESTATE}
    Delta Commission Parameters    ${DEL_XNLINK}
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=unavailable
    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available
    Delta Commission Parameters    ${UNLOCK_NRADJGNB2_ADMINISTRATIVESTATE}

Delta Commission To Setup XN And Trigger XP Setup With Sim GNB XP Ignore And Check Alarm
    Delta Commission Parameters    ${ADD_XNLINK}
    Execute Egate Command    enb_xp_param id=4 ignore_xp=on
    Execute Egate Command    link_drop link=xp by=gnb:4 to=gnb:2 msg_type=shutdown
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=unavailable
    FM Fault Should Be Raised    fault_id=62003
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Sleep    60s    #cpif:XnService start scheduling igNBCaXpAvailabilityWaitTimer: 60s. Timeout and report interGnbCaXpCommunicationFailureAl
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Raised    fault_id=7331

Clear XP Ignore And Trigger XP Setup And Check Alarm
    Object Should Exist    MRBTS-1/NRBTS-1/XNLINK-2:xnLinkStatus=available
    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=unavailable
    Execute Egate Command    enb_xp_param ignore_xp=off id=4
	${cmd2}    catenate    gnb_param id=4 bwp_profile_id=1 bwp_profile_type=powersaving
    ...    act_multiple_dedicated_bwps=yes location_bw_ul=1:2 location_bw_dl=3:4  Inter_gNB_CA_Allowed=yes    CellLoadReportingPeriodicity=000
    ...    IgNBCAXpProtocolVersion=15 IgNBCAXgUProtocolVersion=1
    Execute Egate Command    ${cmd2}
    Execute Egate Command    ignb_ca_configuration_update_indication_send id=4 target=2    IgNBCAConfigurationUpdateIndication
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    MRBTS-1/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE_R-1:xpLinkStatus=available
    FM Fault Should Be Cleared    fault_id=62003
    FM Fault Should Be Cleared    fault_id=7331
