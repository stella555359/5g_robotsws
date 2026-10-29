*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CIT    CDRT    team-DevHZ5_SG2
...    owner-xianjiao.xie    release-5G20A    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../../../resources/DevHZ5_resource.robot

Documentation    Suite description
...   author:      Yuhua Zhu
...   contact:     yuhua.zhu@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     CB0012207


*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC002478_case001}
...    @{amf2}
...    @{xn_gnbcontroll}
...    @{NRADJGNB_0}
...    @{XNLINK_0}
...    @{params_Update_maxNumOfNgRanConfigUpdRetries_and_ngSetupRespTmr}
...    @{PARAMS_FOR_CA}

#7101 alarm: gNB CpCell configuration update failure, when Ran Conf Update By AMF is ignore,
#...    the fault will raised, not test point here,so excluded it
@{FAULTS_EXCLUDED_CHECKING}    7101    7523

@{5GC002478_case001}
...    @{feature740flag_enable}
...    @{Ue_retention_enable}
...    @{RecovBeforeBarringTimer}
...    @{NGCellDeactDelayTimer}

@{PARAMS_FOR_CA}
...    NRBTS/NRDU-1:carrierAggregationSupportList=none
...    NRBTS:caConfigurationSupportFr2SA=8CCDL_4CCUL
...    NRBTS:actCarrierAggregationFr2SA=true
...    NRBTS:maxNumScellsDlFr2SA=7
...    NRBTS:maxNumScellsUlFr2SA=3
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL-1:sCellOnlyFr2Sa=false
...    NRCELL-2:actProactUlSchedulingEnh=allUes
...    NRCELL-3:actProactUlSchedulingEnh=allUes
...    NRCELL-4:actProactUlSchedulingEnh=allUes
...    NRCELL-5:actProactUlSchedulingEnh=disabled
...    NRCELL-6:actProactUlSchedulingEnh=disabled
...    NRCELL-7:actProactUlSchedulingEnh=disabled
...    NRCELL-8:actProactUlSchedulingEnh=disabled
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{amf2}
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.9
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true

@{xn_gnbcontroll}
...    MRBTS-1/NRBTS-1:actIncXn=true
...    MRBTS-1/NRBTS-1:actConflictConfiguration=true

@{NRADJGNB_0}
...    NRADJGNB-10:administrativeState=Unlocked
...    NRADJGNB-10:gNodeBId=35
...    NRADJGNB-10:gNbIdLength=22
...    NRADJGNB-10:xnLinkRef=10
...    NRADJGNB-10:gnbPlmn:mcc=311
...    NRADJGNB-10:gnbPlmn:mnc=489
...    NRADJGNB-10:gnbPlmn:mncLength=3

@{XNLINK_0}
...    XNLINK-10:cPlaneIpAddr=10.0.1.122


@{feature740flag_enable}
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true

@{Ue_retention_enable}
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=true
@{RecovBeforeBarringTimer}
...    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=30
@{NGCellDeactDelayTimer}
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=60

#8CC UEcapa with percc 5 allcc10
${SA_Capa_8T_percc_5_allcc10}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C01
...    1306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C00580
...    38FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C008710418414123F7F20419000D03001600E3F1C5A
...    2400C0020100801A00A401081D001430000A81D003080021004004101170001501403678F2E01B3C78A1FB410000BD00F8009000C0026810
...    168240500603009401800180F80324A00C0000000000392500E008020080200802008021802DE2B74A008200800000000082018020080200
...    80000802AF54576A05A01F00340A00028400530022002000089000004000000480000200000000010008010020010040082A14A20B0C6E74
...    1B300480

@{8DL4UL_expect_regexp}
...    pcid:50, scellIdx:0] configure_0_1
...    pcid:51, scellIdx:1] configure_0_1
...    pcid:52, scellIdx:2] configure_0_1
...    pcid:53, scellIdx:3] configure_0_1
...    pcid:50, scellIdx:0] configure_1_1
...    pcid:51, scellIdx:1] configure_1_1
...    pcid:52, scellIdx:2] configure_1_1
...    pcid:53, scellIdx:3] configure_1_1
...    pcid:54, scellIdx:4] configure_1_1
...    pcid:55, scellIdx:5] configure_1_1
...    pcid:56, scellIdx:6] configure_1_1
...    pcid:57, scellIdx:7] configure_1_1
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 3 activated successfully at airphone
...    SCellIndex 4 activated successfully at airphone
...    SCellIndex 5 activated successfully at airphone
...    SCellIndex 6 activated successfully at airphone
...    SCellIndex 7 activated successfully at airphone


@{params_lock_cells}
...    NRCELL:administrativeState=Locked
#...    NRCELL-2:administrativeState=Locked

@{params_unlock_cells}
...    NRCELL:administrativeState=Unlocked
#...    NRCELL-2:administrativeState=Unlocked

${ue_id}    1
${ue_id2}    31

${maxNumOfNgRanConfigUpdRetries}    7
${ngSetupRespTmr}    1
${TIME_OF_SENDING_RAN_CONF_UPD_MESSAGES}    8

@{params_Update_maxNumOfNgRanConfigUpdRetries_and_ngSetupRespTmr}
...    MRBTS-1/NRBTS-1:maxNumOfNgRanConfigUpdRetries=${maxNumOfNgRanConfigUpdRetries}
...    MRBTS-1/NRBTS-1:ngSetupRespTmr=${ngSetupRespTmr}



@{PM_Counters_CIT001_638}
...    MRBTS-1/NRBTS-1:NNGCB:${NG_CU_RAN_CONFIG_UPD_NO_RSP}=8

@{PM_Counters_CIT001}
...    MRBTS-1/NRBTS-1:NXNCB:${XN_RESET_REQUEST_SENT}=1
...    MRBTS-1/NRBTS-1:NXNCB:${XN_RESET_RESPONSE_RECEIVED}=1
#...    MRBTS-1/NRBTS-1:NXNCB:${XN_SHUTDOWN_DETECTED}=1
#...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_FAIL_LOCKED}=1
#...    MRBTS-1/NRBTS-1:NXNCB:${XN_SHUTDOWN_LOCKED}=2
...    MRBTS-1/NRBTS-1:NXNCB:${XN_RESET_OPER}=1
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_REQUEST_SENT}=3
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_RESPONSE_RECEIVED}=3
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_REQUEST_RECEIVED}=1
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_RESPONSE_SENT}=1
#...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_FAIL_MAX_XN}=1
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SHUTDOWN_NO_GNB_CELL}=3
#...    MRBTS-1/NRBTS-1:NXNCB:${XN_NGRAN_CONF_UPDATE_SENT}=4
#...    MRBTS-1/NRBTS-1:NXNCB:${XN_NGRAN_CONF_UPDATE_ACK_RCVD}=4


${XN_SETUP_REQUEST_SENT}    M55126C00035     #Number of outgoing XN SETUP request sent to neighboring gNB
${XN_SETUP_RESPONSE_RECEIVED}    M55126C00005     #This counter measures the number of successful Xn SETUP procedures.
${XN_SETUP_REQUEST_RECEIVED}    M55126C00003     #This counter measures the number of incoming Xn SETUP requests received from neighboring gNB.
${XN_SETUP_RESPONSE_SENT}    M55126C00004     #Number of successful Xn SETUP procedures (number of Xn SETUP responses sent to neighboring gNB)
${XN_RESET_REQUEST_SENT}    M55126C00012     #Number of XN RESET request sent to remote gNB
${XN_RESET_RESPONSE_RECEIVED}    M55126C00013     #Number of successful outgoing Xn RESET procedures (number of Xn RESET responses received by gNB)
#${XN_SHUTDOWN_DETECTED}    M55126C00002     #Number of SCTP shutdowns detected by SCTP layer on an Xn link
#${XN_SETUP_FAIL_LOCKED}    M55126C00024     #Number of unsuccessful Xn SETUP procedures due to lock
#${XN_SHUTDOWN_LOCKED}    M55126C00008     #Number of SCTP shutdowns due to locked remote gNB
${XN_RESET_OPER}    M55126C00026     #This counter provides the number of Xn reset procedures triggered due to operator action.
#${XN_SETUP_FAIL_MAX_XN}    M55126C00021     #Number of unsuccessful Xn SETUP procedures due to max number of Xn link supported
${XN_SHUTDOWN_NO_GNB_CELL}    M55126C00016     #Number of SCTP shutdowns due to no more gNB cells corresponding to the remote gNB NRADJGNB is deleted
${XN_NGRAN_CONF_UPDATE_SENT}    M55126C00029     #Number of Xn NG-RAN Node Configuration Updates sent by gNB
#Number of successful outgoing Xn NG-RAN Node Configuration Updates (number of Xn NG-RAN Node Configuration Update Acknowledge received by gNB)
${XN_NGRAN_CONF_UPDATE_ACK_RCVD}    M55126C00030

${NG_CU_RAN_CONFIG_UPD_NO_RSP}    M55119C00024     #The number of No RSP for RAN configuration Update

*** Test Cases ***
5GSW-CP-CIT001_CIT002_EDA02170167
	[Documentation]
    ...    1. This case merged 3 cases: CIT001, CIT002 and EDA02170167
    ...     5GSW-CP-CIT001_Verify_Classical_NSA_TDD_cmWave_lock_then_unlock_cell_from_webEM_is_successful
    ...     5GSW-CP-CIT002_Verify_Classical_SA_TDD_cmWave_lock_then_unlock_cell_from_webEM_is_successful
    ...     5GSW_CP_EDA02170167_Verify_Classical_NSA_TDD_cmWave_lock_then_unlock_cell_from_webEM_is_successful
    ...     https://jiradc.ext.net.nokia.com/browse/FIVEGSWCN2ETEDA-212
    ...     5GC000638_D_if_counter_NG_CU_RAN_CONFIG_UPD_NO_RSP_is_incremented_properly
    ...     merge CIT005, add loop=5 for SA and NSA call
	[Tags]  QC_18265
	Clear Counter files
    Start To Capture Wireshark Log
	Lock Unlock Cells and NG link
	Lock Unlock Cells and Xn link
	Check Counters    ${PM_Counters_CIT001}
	check wireshark log    ${CURDIR}${/}a2a_CIT001${/}a2a.ini    wait_string=GNBCUConfigurationUpdateAcknowledge
	#5GC000638_D_M55119C00024

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env  tl_type=tdd_sa_mmwv/FS/8cells_8T_8DL_4UL_ecpri

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
    #---------------------------------------------------------------------------------------------------
    # GNB CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    ${cmd_1}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2
    ...    gnb_id=0x76C daemon=10.0.2.1:22222 xn=10.0.1.2 x2_peers=none amf=1-3 plmnList=311:489 nssai=0x1:0xd143a5
    Update Cfg    ${cmd_1}
	#sim gnb3
    ${set_gnb3}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb3}
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
	#sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${set_gnb5}
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=on send_xn_setup=true
    #---------------------------------------------------------------------------------------------------
    # add CIT005
    #---------------------------------------------------------------------------------------------------
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.0.4 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.0.6 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

Lock Unlock Cells and Xn link
    All link avaiable and Cells on air
	SA and NSA call should be successful
	Lock Cells and Xn Link then Unlock Xn and Cells
	All link avaiable and Cells on air
	SA and NSA call should be successful
	Remove Xn and Add Xn by GNB controll
	All link avaiable and Cells on air
	#SA and NSA call should be successful
	Trigger NSA Call and SA Call by Five Times

Setup Xn and all links and Cells On Air
    #Execute Egate Command    enb_x2_link_up enb=1 target=2    GNB-3: XnAP Link with GNB-2
	Wait Until Keyword Succeeds    20 min    10 sec    All link avaiable and Cells on air

All link avaiable and Cells on air
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Active
	Object Should Exist    SERVEDAMF-2:ngLinkStatus=Active
	Object Should Exist    XNLINK:xnLinkStatus=available
	#Object Should Exist    LTEENB:x2LinkStatus=available

Remove Xn and Add Xn by GNB controll
    ${params_delete_Xn}    create list    delete:NRADJGNB-10    delete:XNLINK-10
	Delta Commission Parameters    ${params_delete_Xn}
	Execute Egate Command    gnb_xn_link_up gnb=5 target=2    GNB-5: XnAP Link with GNB-2

Remove Xn and Add Xn by OAM controll
    ${params_delete_Xn}    create list    delete:NRADJGNB-10    delete:XNLINK-10
	Delta Commission Parameters    ${params_delete_Xn}
	${params_add_Xn}    create list    ${NRADJGNB_0}    ${XNLINK_0}
	Delta Commission Parameters    ${params_add_Xn}

Lock Cells and Xn Link then Unlock Xn and Cells
    Delta Commission Parameters    ${params_lock_cells}
	Delta Commission Parameters    NRADJGNB-10:administrativeState=Locked
	Delta Commission Parameters    NRADJGNB-10:administrativeState=Unlocked
    Delta Commission Parameters    ${params_unlock_cells}

Setup X2 and all links and Cells On Air
    #Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
	Wait Until Keyword Succeeds    20 min    10 sec    All link avaiable and Cells on air

Lock Unlock Cells and NG link
	Lock Cells and Lock NG Link SERVEDAMF2 then Remove SERVEDAMF2
	Add SERVEDAMF2 with locked state and new ip
	Unlock NG Link SERVEDAMF2 and Unlock Cells
	SA and NSA call should be successful
	Lock Cells and Lock NG Link SERVEDAMF2 then Remove SERVEDAMF2
	Add SERVEDAMF2 with locked state and old ip
	Unlock NG Link SERVEDAMF2 and Unlock Cells
	SA and NSA call should be successful

Lock Cells and Lock NG Link SERVEDAMF2 then Remove SERVEDAMF2
    Delta Commission Parameters    ${params_lock_cells}
	Delta Commission Parameters    SERVEDAMF-2:administrativeState=Locked
	Delta Commission Parameters    delete:SERVEDAMF-2

Add SERVEDAMF2 with locked state and new ip
    Delta Commission Parameters    SERVEDAMF-2:amfIPAddress=10.0.1.10

Unlock NG Link SERVEDAMF2 and Unlock Cells
	Delta Commission Parameters    SERVEDAMF-2:administrativeState=Unlocked
	Delta Commission Parameters    ${params_unlock_cells}
	Sleep    300s    #EDA has this step
	Setup X2 and all links and Cells On Air

Add SERVEDAMF2 with locked state and old ip
    Delta Commission Parameters    SERVEDAMF-2:amfIPAddress=10.0.1.9

SA and NSA call should be successful
    #sa ue register and pdu setup    ue_id=1
    #Traffic Should Be OK    ue_id=1    type=sa
    #nsa ue register    ue_id=31
	#Traffic Should Be OK    ue_id=31    type=nsa
	UE attach and Scell added blindly     ue_id=1    CC_num=8    UE_Capabilities=${SA_Capa_8T_percc_5_allcc10}
	release ues    ue_type=all

Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${Tput_expect}=80    ${CC_num}=2    ${type}=pdsch
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=${type}    pass_regexp=Average
    ${all_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}    ${type}
        ${all_tput}    Evaluate    ${all_tput}+${cell_tput}
	END
    Should Be True    ${all_tput}/1000 > ${Tput_expect}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0    ${type}=pdsch
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=${type}    rate_type=ave
    Should Be True    ${scell_tput}/1000 > 0

UE attach and Scell added blindly
    [Arguments]    ${ue_id}=1    ${CC_num}=8    ${UE_Capabilities}=${SA_Capa_8T_percc_5_allcc10}    ${expect_regexp}=${8DL4UL_expect_regexp}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilities}
    ${Last_RAN_UE_NGAP_ID}    SA CA UE Setup PDU Session And Check CA Addition Successfully    ue_id=${ue_id}    expect_regexp=${expect_regexp}
    Set Test Variable    \${Last_RAN_UE_NGAP_ID}
    Traffic Send    ue_id=${ue_id}
    sleep    60s    sleep for Tput stable
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=810    CC_num=${CC_num}    type=pdsch
    Check Throughput with Type    ue_id=${ue_id}    Tput_expect=310    CC_num=4    type=pusch

SA CA UE Setup PDU Session And Check CA Addition Successfully
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${expect_regexp}=${EMPTY}
    [Return]    ${RAN_UE_NGAP_ID[0]}
    Sa CA UE Register    ue_id=${ue_id}    gnb_id=2    cell_id=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    ${output}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_regexp}
    ${RAN_UE_NGAP_ID}    Get Regexp Matches    ${output}    RAN_UE_NGAP_ID\=(\\d+)    1

Sa CA UE Register
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${gnb_id}
    Execute Egate Command    ue_register id=${ue_id}    sleep_time=${wait_timer}    pass_regexp=NG RM Registered

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${SA_Capa_perUE_Full}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

Traffic Send
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=175    UE ${ue_id}: UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=9 mbps=175    UE ${ue_id}: UDP UL

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_id}    QoS Routing Table

nsa ue register
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    reported successful RA

LOOP Five Times
    FOR    ${index}    IN RANGE    0    5
        ${ue1}    Evaluate    ${ue_id}+${index}
        #sa ue register and pdu setup    ${ue1}
        #traffic should be ok    ue_id=${ue1}    type=SA
		#Detach UEs    ${ue1}
		UE attach and Scell added blindly     ue_id=${ue1}    CC_num=8    UE_Capabilities=${SA_Capa_8T_percc_5_allcc10}
	    Detach UEs    ${ue1}
        #${ue2}    Evaluate    ${ue_id2}+${index}
        #nsa ue attach successful    ${ue2}
        #traffic should be ok    ${ue2}    type=NSA
        #Detach UEs    ${ue2}    ${ue1}
    END

Trigger NSA Call and SA Call by Five Times
    FOR    ${num}    IN RANGE    0    5
       LOOP Five Times
    END

nsa ue attach successful
    [Arguments]    ${id}    ${target_cells}=1    ${cmd_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg    ${cmd_regexp}

Detach UEs
    [Arguments]    ${id2}
    Execute Egate Command    ue_deregister id=${id2} ue_deregister_type=switch_off    Received UE Context Release Complete
    #Execute Egate Command    ue_detach id=${id2}    UE IS OFF
    sleep    5s

5GC000638_D_M55119C00024
    BuiltIn.Log    Begin to test 5GC000638_D_M55119C00024...     console=${True}
	Clear Counter files
    Delete AMF-2
	#Update maxNumOfNgRanConfigUpdRetries and ngSetupRespTmr
	Start To Capture Wireshark Log    638
	Ignore Ran Conf Update By AMF
	Lock Single Cell_1
	Lock Single Cell_2
	Unlock Single Cell_1
	sleep    ${TIME_OF_SENDING_RAN_CONF_UPD_MESSAGES}     Waiting for Ran_Conf_Update
	Check Counters    ${PM_Counters_CIT001_638}
	#check wireshark log    ${CURDIR}${/}a2a_M55119C00024${/}a2a.ini
	Alarm Rasied with fault_7101
	Unlock Single Cell_2

Delete AMF-2
    BuiltIn.Log    Delete AMF2...     console=${True}
    Delta Commission Parameters    delete:SERVEDAMF-2

Update maxNumOfNgRanConfigUpdRetries and ngSetupRespTmr
    BuiltIn.Log    Update maxNumOfNgRanConfigUpdRetries=7 and ngSetupRespTmr=1...     console=${True}
    Delta Commission Parameters    ${params_Update_maxNumOfNgRanConfigUpdRetries_and_ngSetupRespTmr}

Ignore Ran Conf Update By AMF
    BuiltIn.Log    Ignore Ran Conf Update By AMF...    console=${True}
    Execute Egate Command    amf_ran_config_update_param id=1 action=ignore ntimes=indefinite

Lock Single Cell_1
    BuiltIn.Log    Lock Single Cell_1.. .    console=${True}
    Delta Commission Parameters    NRCELL-1:administrativeState=Locked

Lock Single Cell_2
    BuiltIn.Log    Lock Single Cell_2...     console=${True}
    Delta Commission Parameters    NRCELL-2:administrativeState=Locked

Unlock Single Cell_1
    BuiltIn.Log    Unlock Single Cell_1...     console=${True}
    Delta Commission Parameters    NRCELL-1:administrativeState=Unlocked

Unlock Single Cell_2
    BuiltIn.Log    Unlock Single Cell_2...     console=${True}
    Delta Commission Parameters    NRCELL-2:administrativeState=Unlocked

Alarm Rasied with fault_7101
    Sleep    10s    #maxNumOfNgRanConfigUpdRetries * ngSetupRespTmr
    Wait Until Keyword Succeeds    60s    2s    FM Fault Should Be Raised    fault_id=7101