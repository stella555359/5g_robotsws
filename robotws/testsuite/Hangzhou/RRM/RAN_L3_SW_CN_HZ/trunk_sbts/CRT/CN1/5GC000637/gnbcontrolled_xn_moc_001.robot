*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CRT    team-DevHZ5_SG2
...    owner-yuhua.zhu    release-5G20A    CLOUD_5G_I_LO_AP_LO
Resource    ../../../../resources/DevHZ5_resource.robot

Documentation    Suite description
...   author:      Yuhua Zhu
...   contact:     yuhua.zhu@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     5GC000637

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC002478_case001}
...    @{amf2}
...    @{xn_gnbcontroll}
...    @{NRADJGNB}
...    @{XNLINK}
...    @{params_Update_maxNumOfNgRanConfigUpdRetries_and_ngSetupRespTmr}
#...    @{PARAMS_FOR_CA}

#7101 alarm: gNB CpCell configuration update failure, when Ran Conf Update By AMF is ignore,
#...    the fault will raised, not test point here,so excluded it
@{FAULTS_EXCLUDED_CHECKING}    7101    7523    7306    7311

@{5GC002478_case001}
...    @{feature740flag_enable}
...    @{Ue_retention_enable}
...    @{RecovBeforeBarringTimer}
...    @{NGCellDeactDelayTimer}


@{amf2}
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.9
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true

@{xn_gnbcontroll}
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true
...    NRBTS:maxNumXnLinks=10
...    NRBTS:xnLinkReestabTmr=60
...    NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=disabled

@{NRADJGNB}
...    NRADJGNB-1:administrativeState=Locked
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=489
...    NRADJGNB-1:gnbPlmn:mncLength=3

...    NRADJGNB-2:administrativeState=Locked
...    NRADJGNB-2:gNodeBId=39
...    NRADJGNB-2:gNodeBIdCtrl=gnbControlled
...    NRADJGNB-2:gNbIdLength=22
...    NRADJGNB-2:xnLinkRef=2
...    NRADJGNB-2:gnbPlmn:mcc=311
...    NRADJGNB-2:gnbPlmn:mnc=489
...    NRADJGNB-2:gnbPlmn:mncLength=3

...    NRADJGNB-3:administrativeState=Unlocked
...    NRADJGNB-3:gNodeBId=34
...    NRADJGNB-3:gNodeBIdCtrl=oamControlled
...    NRADJGNB-3:gNbIdLength=22
...    NRADJGNB-3:xnLinkRef=3
...    NRADJGNB-3:gnbPlmn:mcc=311
...    NRADJGNB-3:gnbPlmn:mnc=489
...    NRADJGNB-3:gnbPlmn:mncLength=3

...    NRADJGNB-4:administrativeState=Locked
...    NRADJGNB-4:gNodeBId=38
...    NRADJGNB-4:gNodeBIdCtrl=oamControlled
...    NRADJGNB-4:gNbIdLength=22
...    NRADJGNB-4:xnLinkRef=4
...    NRADJGNB-4:gnbPlmn:mcc=311
...    NRADJGNB-4:gnbPlmn:mnc=489
...    NRADJGNB-4:gnbPlmn:mncLength=3

...    NRADJGNB-5:administrativeState=Locked
...    NRADJGNB-5:gNodeBId=33
...    NRADJGNB-5:gNodeBIdCtrl=oamControlled
...    NRADJGNB-5:gNbIdLength=22
#...    NRADJGNB-5:xnLinkRef=5
...    NRADJGNB-5:gnbPlmn:mcc=311
...    NRADJGNB-5:gnbPlmn:mnc=489
...    NRADJGNB-5:gnbPlmn:mncLength=3



@{XNLINK}
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    XNLINK-1:cPlaneIpAddrCtrl=gnbControlled

...    XNLINK-2:cPlaneIpAddr=10.0.1.124
...    XNLINK-2:cPlaneIpAddrCtrl=oamControlled

...    XNLINK-3:cPlaneIpAddr=10.0.1.244
...    XNLINK-3:cPlaneIpAddrCtrl=gnbControlled

...    XNLINK-4:cPlaneIpAddr=10.0.1.129
...    XNLINK-4:cPlaneIpAddrCtrl=oamControlled


@{fault}
...    NRADJGNB-10:administrativeState=Unlocked
...    NRADJGNB-10:gNodeBId=40
...    NRADJGNB-10:gNodeBIdCtrl=gnbControlled
...    NRADJGNB-10:gNbIdLength=22
...    NRADJGNB-10:xnLinkRef=10
...    NRADJGNB-10:gnbPlmn:mcc=311
...    NRADJGNB-10:gnbPlmn:mnc=489
...    NRADJGNB-10:gnbPlmn:mncLength=3
...    XNLINK-10:cPlaneIpAddr=10.0.1.143
...    XNLINK-10:cPlaneIpAddrCtrl=oamControlled

@{feature740flag_enable}
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true

@{Ue_retention_enable}
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=true
@{RecovBeforeBarringTimer}
...    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=30
@{NGCellDeactDelayTimer}
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=60

@{params_lock_cells}
...    NRCELL:administrativeState=Locked
#...    NRCELL-2:administrativeState=Locked

@{params_unlock_cells}
...    NRCELL:administrativeState=Unlocked
#...    NRCELL-2:administrativeState=Unlocked

${maxNumOfNgRanConfigUpdRetries}    7
${ngSetupRespTmr}    1
${TIME_OF_SENDING_RAN_CONF_UPD_MESSAGES}    8

@{params_Update_maxNumOfNgRanConfigUpdRetries_and_ngSetupRespTmr}
...    MRBTS-1/NRBTS-1:maxNumOfNgRanConfigUpdRetries=${maxNumOfNgRanConfigUpdRetries}
...    MRBTS-1/NRBTS-1:ngSetupRespTmr=${ngSetupRespTmr}

@{PM_Counters}
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_REQUEST_SENT}=2
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_RESPONSE_RECEIVED}=1
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_REQUEST_RECEIVED}=5
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_RESPONSE_SENT}=4
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_FAIL_LOCKED}=1
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SHUTDOWN_LOCKED}=1

${XN_SETUP_REQUEST_SENT}    M55126C00035     #Number of outgoing XN SETUP request sent to neighboring gNB
${XN_SETUP_RESPONSE_RECEIVED}    M55126C00005     #This counter measures the number of successful Xn SETUP procedures.
${XN_SETUP_REQUEST_RECEIVED}    M55126C00003     #This counter measures the number of incoming Xn SETUP requests received from neighboring gNB.
${XN_SETUP_RESPONSE_SENT}    M55126C00004     #Number of successful Xn SETUP procedures (number of Xn SETUP responses sent to neighboring gNB)
${XN_RESET_REQUEST_SENT}    M55126C00012     #Number of XN RESET request sent to remote gNB
${XN_RESET_RESPONSE_RECEIVED}    M55126C00013     #Number of successful outgoing Xn RESET procedures (number of Xn RESET responses received by gNB)
#${XN_SHUTDOWN_DETECTED}    M55126C00002     #Number of SCTP shutdowns detected by SCTP layer on an Xn link
${XN_SETUP_FAIL_LOCKED}    M55126C00024     #Number of unsuccessful Xn SETUP procedures due to lock
${XN_SHUTDOWN_LOCKED}    M55126C00008     #Number of SCTP shutdowns due to locked remote gNB
${XN_RESET_OPER}    M55126C00026     #This counter provides the number of Xn reset procedures triggered due to operator action.
#${XN_SETUP_FAIL_MAX_XN}    M55126C00021     #Number of unsuccessful Xn SETUP procedures due to max number of Xn link supported
${XN_SHUTDOWN_NO_GNB_CELL}    M55126C00016   #Number of SCTP shutdowns due to no more gNB cells corresponding to the remote gNB NRADJGNB is deleted
${XN_NGRAN_CONF_UPDATE_SENT}    M55126C00029     #Number of Xn NG-RAN Node Configuration Updates sent by gNB
#Number of successful outgoing Xn NG-RAN Node Configuration Updates (number of Xn NG-RAN Node Configuration Update Acknowledge received by gNB)
${XN_NGRAN_CONF_UPDATE_ACK_RCVD}    M55126C00030
${XN_ERROR_INDICATION_SENT}    M55126C00014     #Incremented when XnAP Error Indication is sent by gNB.


${NG_CU_RAN_CONFIG_UPD_NO_RSP}    M55119C00024     #The number of No RSP for RAN configuration Update
#@{FAULTS_EXCLUDED_CHECKING}    7306    7311


*** Test Cases ***
gnbcontrolled_xn_moc_001
	[Documentation]
    ...    1. This case merged 3 cases: CIT001, CIT002 and EDA02170167
    ...     5GSW-CP-CIT001_Verify_Classical_NSA_TDD_cmWave_lock_then_unlock_cell_from_webEM_is_successful
    ...     5GSW-CP-CIT002_Verify_Classical_SA_TDD_cmWave_lock_then_unlock_cell_from_webEM_is_successful
    ...     5GSW_CP_EDA02170167_Verify_Classical_NSA_TDD_cmWave_lock_then_unlock_cell_from_webEM_is_successful
    ...     https://jiradc.ext.net.nokia.com/browse/FIVEGSWCN2ETEDA-212
    ...     5GC000638_D_if_counter_NG_CU_RAN_CONFIG_UPD_NO_RSP_is_incremented_properly
    ...     merge CIT005, add loop=5 for SA and NSA call
	[Tags]  QC_47223
	Clear Counter files
	Start To Capture Wireshark Log    error_indication
	GnbSim3 send XNSetupRequest to GNB
	Unlock NRADJNGB-2
	GNBSim5 send XNSetup Request to GNB
	Unlock NRADJNGB-4
	GNBSim7 send XNSetupRequest to GNB
	stop_capture_wireshark_log
	check_num_of_wireshark_as_excepted    ${SAVE LOG DIRECTORY}${/}wireshark_error_indication.pcap   xnap.procedureCode == 21@1
	Check Counters    ${PM_Counters}
	SCTP drop
	fault 7306 and 7311

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    #---------------------------------------------------------------------------------------------------
    # 5GCN CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    Update Cfg    set_amf_region id=1 tac_list=7627107,100,788,200,258,0 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=7627107,100,788,200,258,0 plmn=311:489
    Update Cfg    set_amf_region id=3 tac_list=7627107,100,788,200,258,0 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.9:38412 region=2 set_id=2 pointer=2
	Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.10:38412 region=3 set_id=2 pointer=2
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
	Update Cfg    amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    set_upf id=1 daemon=10.0.2.1:22222 type=simulated addr=1.2.4.1/24 ngu=10.0.1.1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=off
    Update Cfg    amf_ng_setup_param id=2 relative_capacity=100
	Update Cfg    amf_ng_setup_param id=3 relative_capacity=100
    Update Cfg    set_backup_amf main=1 backup_amfs=2
    Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=1-6 amf=1-3
	Update Cfg    set GNB5_NG_ADDR="10.0.1.126"
	Update Cfg    set GNB5_XN_ADDR="10.0.1.127"
	Update Cfg    set GNB6_NG_ADDR="10.0.1.128"
	Update Cfg    set GNB6_XN_ADDR="10.0.1.129"
	Update Cfg    set GNB7_NG_ADDR="10.0.1.137"
	Update Cfg    set GNB7_XN_ADDR="10.0.1.138"
	Update Cfg    set GNB8_NG_ADDR="10.0.1.140"
	Update Cfg    set GNB8_XN_ADDR="10.0.1.141"
	Update Cfg    set GNB9_NG_ADDR="10.0.1.142"
	Update Cfg    set GNB9_XN_ADDR="10.0.1.143"
	Update Cfg    set PROXY_SERVER4_IP="10.0.2.93"
	Update Cfg    set PROXY_SERVER4_IP="10.0.2.94"
    #---------------------------------------------------------------------------------------------------
    # GNB CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    ${cmd_1}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2
    ...    gnb_id=0x76C daemon=10.0.2.1:22222 xn=10.0.1.2 x2_peers=none amf=1-3 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${cmd_1}
	#sim gnb3
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=50:1 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3}
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=true
	#sim gnb4
    ${set_gnb4}    catenate    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    ${set_gnb4_cell1}    catenate    set_cell id=1 gnb=4 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb4}
    Update Cfg    ${set_gnb4_cell1}
    Update Cfg    gnb_param id=4 xn_listening_socket=on send_xn_setup=true
	#sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.126 gnb_id=0x22:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.127 nssai=0x1:0xd143a5 amf=1
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=50:2 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb5}
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=on send_xn_setup=true
	#sim gnb6
    ${set_gnb6}    catenate    set_gnb id=6 type=simulated plmn=311:489 ng=10.0.1.128 gnb_id=0x21:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.129 nssai=0x1:0xd143a5 amf=1
    ${set_gnb6_cell1}    catenate    set_cell id=1 gnb=6 pci=51:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.93:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb6}
    Update Cfg    ${set_gnb6_cell1}
    Update Cfg    gnb_param id=6 xn_listening_socket=on send_xn_setup=true
	#sim gnb7
    ${set_gnb7}    catenate    set_gnb id=7 type=simulated plmn=311:489 ng=10.0.1.137 gnb_id=0x20:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.138 nssai=0x1:0xd143a5 amf=1
    ${set_gnb7_cell1}    catenate    set_cell id=1 gnb=7 pci=51:1 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.94:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb7}
    Update Cfg    ${set_gnb7_cell1}
    Update Cfg    gnb_param id=7 xn_listening_socket=on send_xn_setup=true

    #sim gnb8
    ${set_gnb8}    catenate    set_gnb id=8 type=simulated plmn=311:489 ng=10.0.1.140 gnb_id=0x25:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.141 nssai=0x1:0xd143a5 amf=1
    ${set_gnb8_cell1}    catenate    set_cell id=1 gnb=8 pci=52:1 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.95:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb8}
    Update Cfg    ${set_gnb8_cell1}
    Update Cfg    gnb_param id=8 xn_listening_socket=on send_xn_setup=true

	#sim gnb9
    ${set_gnb9}    catenate    set_gnb id=9 type=simulated plmn=311:489 ng=10.0.1.142 gnb_id=0x28:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.143 nssai=0x1:0xd143a5 amf=1
    ${set_gnb9_cell1}    catenate    set_cell id=1 gnb=9 pci=53:1 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.96:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb9}
    Update Cfg    ${set_gnb9_cell1}
    Update Cfg    gnb_param id=9 xn_listening_socket=on send_xn_setup=false
    #---------------------------------------------------------------------------------------------------
    # add CIT005
    #---------------------------------------------------------------------------------------------------
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.0.4 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.0.6 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

SCTP drop
    Start To Capture Wireshark Log    sctp_drop
	gNB control to setup xnlink    8    7    available
	Check NRADJNGB and XN link status    8    gnbControlled    37    7
	Wait Until Keyword Succeeds    60s    2s    Object Should Exist    XNLINK-7:cPlaneIpAddrCtrl=gnbControlled
	execute command on enb    iptables -A INPUT -s 10.0.1.141 -j DROP
	Sleep    60s
	Wait Until Keyword Succeeds    120s    2s    Object Should Not Exist    NRADJGNB-8:xnLinkRef=7
	Wait Until Keyword Succeeds    120s    2s    Object Should Not Exist    XNLINK-7:cPlaneIpAddr=10.0.1.141
	execute command on enb    iptables -t filter -F INPUT
	Sleep    60s
	gNB control to setup xnlink    8    8    available
	Check NRADJNGB and XN link status    9    gnbControlled    37    8
	Wait Until Keyword Succeeds    60s    2s    Object Should Exist    XNLINK-8:cPlaneIpAddrCtrl=gnbControlled

fault 7306 and 7311
    Start To Capture Wireshark Log    fault
    delta commission parameters    ${fault}
    Check NRADJNGB and XN link status    10    gnbControlled    40    10
	Wait Until Keyword Succeeds    60s    2s    Object Should Exist    XNLINK-10:cPlaneIpAddrCtrl=oamControlled
    execute command on enb    iptables -A INPUT -s 10.0.1.143 -j DROP
	Wait Until Keyword Succeeds    300s    2s    Check Alarm 7306 and 7311 Raised
	Delta Commission Parameters    delete:NRADJGNB-10
	Wait Until Keyword Succeeds    60s    2s    Object Should Not Exist    NRADJGNB-10:xnLinkRef=10
	Wait Until Keyword Succeeds    300s    2s    Check Alarm 7306 and 7311 cleared

Check Alarm 7306 and 7311 Raised
    #${fault_7306}    create list    fault_id=7306
    #fm fault should be raised    ${fault_7306}

	${fault_7306}    set variable    7306
    ${fault_7311}    set variable    7311
    ${orignal_active_alarm_list}    Get Current Active Faultid
	${active_alarm_list}=    Evaluate    [item['fault_id'] for item in ${orignal_active_alarm_list}]
    should contain any    ${Active_alarm_list}    ${fault_7306}    ${fault_7311}

Check Alarm 7306 and 7311 cleared
    #${fault_7306}    create list    fault_id=7306
    #fm fault should be cleared    ${fault_7306}

    ${fault_7306}    set variable    7306
    ${fault_7311}    set variable    7311
    ${orignal_active_alarm_list_cleared}    Get Current Active Faultid
	${active_alarm_list_cleared}=    Evaluate    [item['fault_id'] for item in ${orignal_active_alarm_list_cleared}]
    should not contain any    ${active_alarm_list_cleared}    ${fault_7306}    ${fault_7311}
GnbSim3 send XNSetupRequest to GNB
    #[Arguments]    ${NRADJGNB_id}=1    ${xnLinkStatus}=available
    #...    ${gNodeBIdCtrl}=oamControlled    ${gNodeBId}=35    ${xnLinkRef}=1
    Unlock NRADJNGB    1
    Object Should Exist    XNLINK-1:xnLinkStatus=unavailable
    gNB control to setup xnlink    3    1    available
    Check NRADJNGB and XN link status    1    gnbControlled    36    1

Unlock NRADJNGB-2
    #[Arguments]    ${NRADJGNB_id}=1    ${gNodeBIdCtrl}=oamControlled    ${gNodeBId}=35    ${xnLinkRef}=1
    Unlock NRADJNGB    2
    #Check NRADJNGB and XN link status    2    oamControlled    35    2
    Check NRADJNGB and XN link status    6    gnbControlled    35    2
    Wait Until Keyword Succeeds    60s    2s    Object Should Not Exist    NRADJGNB-2:xnLinkRef=2
    Wait Until Keyword Succeeds    60s    2s    Object Should Not Exist    NRADJGNB-2:gnbPlmn:mcc=311

GNBSim5 send XNSetup Request to GNB
    #[Arguments]    ${NRADJGNB_id}=1    ${xnLinkStatus}=available
    #...    ${gNodeBIdCtrl}=oamControlled    ${gNodeBId}=35    ${xnLinkRef}=1
    gNB control to setup xnlink    5    5    available
    Check NRADJNGB and XN link status    3    gnbControlled    34    5
    Wait Until Keyword Succeeds    60s    2s    Object Should Not Exist    XNLINK-3:cPlaneIpAddr=10.0.1.244
    Wait Until Keyword Succeeds    60s    2s    Object Should Not Exist    XNLINK-3:xnLinkStatus=available
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    XNLINK-5:cPlaneIpAddr=10.0.1.127

Unlock NRADJNGB-4
    #[Arguments]    ${NRADJGNB_id}=1    ${gNodeBIdCtrl}=oamControlled    ${gNodeBId}=35    ${xnLinkRef}=1
    Unlock NRADJNGB    4
    Check NRADJNGB and XN link status    4    oamControlled    38    4
    #Check NRADJNGB and XN link status    5    oamControlled    33    4
    #Wait Until Keyword Succeeds    65s    2s    Object Should Not Exist    NRADJGNB-4:xnLinkRef=4

GNBSim7 send XNSetupRequest to GNB
    gNB control to setup xnlink    7    6    available
    Check NRADJNGB and XN link status    7    gnbControlled    32    6
    Wait Until Keyword Succeeds    60s    2s    Object Should Exist    XNLINK-6:cPlaneIpAddr=10.0.1.138

Unlock NRADJNGB
    [Arguments]    ${NRADJGNB_id}=1
	Delta Commission Parameters    NRADJGNB-${NRADJGNB_id}:administrativeState=Unlocked
    #Object Should Exist    XNLINK:xnLinkStatus=${xnLinkStatus}

gNB control to setup xnlink
    [Arguments]    ${gnb_id}=1    ${XNLINK_id}=1    ${xnLinkStatus}=available
	Execute Egate Command    gnb_xn_link_up gnb=${gnb_id} target=2 xn_link_addr=10.0.1.2
    #OnlineParamChange    ${add_2ndNRADJgNB_and_XNlink}
	#@OnlineParamChange    ${BA001_parameter_update_recover}
	Wait Until Keyword Succeeds    120s    2s    Object Should Exist    XNLINK-${XNLINK_id}:xnLinkStatus=${xnLinkStatus}

Check NRADJNGB and XN link status
    [Arguments]    ${NRADJGNB_id}=1    ${gNodeBIdCtrl}=oamControlled    ${gNodeBId}=35    ${xnLinkRef}=1
	Wait Until Keyword Succeeds    120s    2s    Object Should Exist    NRADJGNB-${NRADJGNB_id}:gNodeBIdCtrl=${gNodeBIdCtrl}
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist    NRADJGNB-${NRADJGNB_id}:gNodeBId=${gNodeBId}
    Wait Until Keyword Succeeds    120s    2s    Object Should Exist    NRADJGNB-${NRADJGNB_id}:gNodeBIdCtrl=${gNodeBIdCtrl}
	Wait Until Keyword Succeeds    120s    2s    Object Should Exist    NRADJGNB-${NRADJGNB_id}:xnLinkRef=${xnLinkRef}