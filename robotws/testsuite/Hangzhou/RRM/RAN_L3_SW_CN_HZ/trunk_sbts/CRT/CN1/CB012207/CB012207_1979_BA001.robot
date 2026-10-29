*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CRT    RAN_5G    RAN_5G_TDD    5GC001979    Owner_yuhua.zhu   pz3_07  
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00
Resource     ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS:maxParallelXnSetup=3
...    NRBTS:actIncXn=true
...    NRBTS:maxNumXnLinks=2
...    NRBTS:xnLinkReestabTmr=60
...    NRBTS:actConflictConfiguration=false
...    NRBTS:maxNumXnSetupRetry=3
...    NRBTS:retryXnSetupTmr=20
...    NRBTS:xnNgRanCfUpNbInfoBackOffTmr=0
...    NRBTS:xnNgRanCfUpRdmDelayTmr=0
...    NRBTS:actNgcFlexSaMode=true
...    @{PARAMS_FOR_CA}


@{add_NRADJgNB_and_XNlink}
...    NRADJGNB-10:administrativeState=Unlocked
...    NRADJGNB-10:gNodeBId=35
...    NRADJGNB-10:gNodeBIdCtrl=oamControlled
...    NRADJGNB-10:gNbIdLength=22
...    NRADJGNB-10:xnLinkRef=10
...    NRADJGNB-10:gnbPlmn:mcc=311
...    NRADJGNB-10:gnbPlmn:mnc=489
...    NRADJGNB-10:gnbPlmn:mncLength=3
...    XNLINK-10:cPlaneIpAddr=10.0.1.122
...    XNLINK-10:cPlaneIpAddrCtrl=oamControlled

@{add_2ndNRADJgNB_and_XNlink}
...    NRBTS:maxNumXnLinks=1
...    NRADJGNB-2:administrativeState=Unlocked
...    NRADJGNB-2:gNodeBId=36
...    NRADJGNB-2:gNodeBIdCtrl=oamControlled
...    NRADJGNB-2:gNbIdLength=22
...    NRADJGNB-2:xnLinkRef=2
...    NRADJGNB-2:gnbPlmn:mcc=311
...    NRADJGNB-2:gnbPlmn:mnc=489
...    NRADJGNB-2:gnbPlmn:mncLength=3
...    XNLINK-2:cPlaneIpAddr=10.0.1.124
...    XNLINK-2:cPlaneIpAddrCtrl=oamControlled

@{PARAMS_FOR_CA}
...    NRBTS/NRDU-1:carrierAggregationSupportList=none
...    NRBTS:caConfigurationSupportFr2SA=8CCDL_4CCUL
...    NRBTS:actCarrierAggregationFr2SA=true
...    NRBTS:maxNumScellsDlFr2SA=7
...    NRBTS:maxNumScellsUlFr2SA=3
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL-1:sCellOnlyFr2Sa=false
...    NRCELL-2:actProactUlScheduling=true
...    NRCELL-3:actProactUlScheduling=true
...    NRCELL-4:actProactUlScheduling=true
...    NRCELL-5:actProactUlScheduling=false
...    NRCELL-6:actProactUlScheduling=false
...    NRCELL-7:actProactUlScheduling=false
...    NRCELL-8:actProactUlScheduling=false
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{BA001_disableactincxn}
...    NRBTS:actIncXn=false

@{BA001_actincxn}
...    NRBTS:maxNumXnLinks=1
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true

@{BA001_parameter_update_recover}
...    NRBTS:maxNumXnLinks=1
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true

${FAULTS_EXCLUDED_CHECKING}    7311

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


@{PM_Counters_BA001}
...    MRBTS-1/NRBTS-1:NXNCB:${XN_RESET_REQUEST_SENT}=2
...    MRBTS-1/NRBTS-1:NXNCB:${XN_RESET_RESPONSE_RECEIVED}=2
#...    MRBTS-1/NRBTS-1:NXNCB:${XN_SHUTDOWN_DETECTED}=1
#...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_FAIL_LOCKED}=1
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SHUTDOWN_LOCKED}=2
...    MRBTS-1/NRBTS-1:NXNCB:${XN_RESET_OPER}=2
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_REQUEST_SENT}=7
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_RESPONSE_RECEIVED}=3
...    MRBTS-1/NRBTS-1:NXNCB:${XN_SETUP_FAIL_MAX_XN}=1

${XN_SETUP_REQUEST_SENT}    M55126C00035     #Number of outgoing XN SETUP request sent to neighboring gNB
${XN_SETUP_RESPONSE_RECEIVED}    M55126C00005     #This counter measures the number of successful Xn SETUP procedures.
${XN_RESET_REQUEST_SENT}    M55126C00012     #Number of XN RESET request sent to remote gNB
${XN_RESET_RESPONSE_RECEIVED}    M55126C00013     #Number of successful outgoing Xn RESET procedures (number of Xn RESET responses received by gNB)
#${XN_SHUTDOWN_DETECTED}    M55126C00002     #Number of SCTP shutdowns detected by SCTP layer on an Xn link
#${XN_SETUP_FAIL_LOCKED}    M55126C00024     #Number of unsuccessful Xn SETUP procedures due to lock
${XN_SHUTDOWN_LOCKED}    M55126C00008     #Number of SCTP shutdowns due to locked remote gNB
${XN_RESET_OPER}    M55126C00026     #Number of unsuccessful Xn RESET procedures due to operator action
${XN_SETUP_FAIL_MAX_XN}    M55126C00021     #Number of unsuccessful Xn SETUP procedures due to max number of Xn link supported

#M55126C00025	Number of unsuccessful XN SETUP procedure (other)	XN_SETUP_FAIL_OTHER	Number of unsuccessful Xn SETUP procedures due to other reasons
#M55126C00026	Number of unsuccessful XN RESET initiated by operator	XN_RESET_OPER	Number of unsuccessful Xn RESET procedures due to operator action

#8CC UEcapa with percc 5 allcc10
${SA_Capa_8T_percc_5_allcc10}    SEPARATOR=
...    E1A25000574F7603564803C4280058084400090020C008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F20020301262C01
...    1306E41280634DA0004040140601CCE00F42B4070378E3087000A8F3F1436011FB660AA40078F0021C4106115028FDFC8106400340C00580
...    38FC71689003000804020068029150AD00DE38C21C002A3CFC50D8047ED982A9001E3C008710418414123F7F20419000D03001600E3F1C5A
...    2400C0020100801A00A401081D001430000A81D003080021004004101170001501403678F2E01B3C78A1FB410000BD00F8009000C0026810
...    168240500603009401800180F80324A00C0000000000392500E008020080200802008021802DE2B74A008200800000000082018020080200
...    80000802AF54576A05A01F00340A00028400530022002000089000004000000480000200000000010008010020010040082A14A20B0C6E74
...    1B300480


@{admin_state}    Unlocked    Locked
${TL_TYPE}    golden-l1bypass_tdd_sa_cmwv-1cell
${DIST_NAME}        MRBTS-1/NRBTS-1
${DIST_NAME_NRCELL}    MRBTS-1/NRBTS-1/NRCELL-1

${pcapfilter}    xnap.procedureCode == 17 and ip.src == 10.0.1.2 and xnap.id == 75
${XnAP_FILTER}    xnap
${CpNbXnLinkInfoUpdateRequired}     PROTOBUF:messages::cp_nb::CpNbXnLinkInfoUpdateRequired
${cpnb_log}    runtime_cp_nb\.log
${NetworkPlanUpdateIndication}    MULTI:messages::oam::NetworkPlanUpdateIndication
${string_tmptime}    {split($2,a,"[-T:.]");b\=mktime(a[1]" "a[2]" "a[3]" "a[4]" "a[5]" "a[6]);print b}

${pcap_file}    /tmp/gnb-0-any-tcpdump/gnb-0-any-tcpdump.pcap

*** Test Cases ***
5GC001979-ET-BA001_Verify_XnSetupRequest_repetition_with_retryXnSetupTmr_when_receive_XnSetupFailure
    [Documentation]    The purpose of this test case is to check Verify
    ...    XnSetupRequest repetition with retryXnSetupTmr when receive XnSetupFailure
    [Tags]    5G20A    5G20B    5GC001979-BA    BA001    QC_18264
    #[Setup]    CP Common Test Setup
	Clear Counter files
    OAM control setup one xnlink
	#SA UE Register and PDU Setup
	#Send And Verify Throuput
	UE attach and Scell added blindly     ue_id=1    CC_num=8    UE_Capabilities=${SA_Capa_8T_percc_5_allcc10}
    Disable actincxn and incoming xnsetupfailure
    #Start Tcpdump common
    #lock unlock NRADJGNB on real gnb to trigger xnsetuprequest
    #Check Xn is unavailable
	Check XN still unavailable after lock unlock NRADJGNB
	Check XN still available after lock unlock NRADJGNB
	OAM control setup another xnlink
    #Check wireshark xnsetupfailure contain timetowait v10s
	Check Counters    ${PM_Counters_BA001}
	check wireshark log    ${CURDIR}${/}a2a_BA001${/}a2a.ini
	#Teardown for 5GC001979    Restore_params=${BA001_parameter_update_recover}
   #[Teardown]    Run Keyword And Ignore Error    Recovery

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sa_mmwv/FS/8cells_8T_8DL_4UL_ecpri


Modify Cfg
    #---------------------------------------------------------------------------------------------------
    # 5GCN CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    Update Cfg    set_amf_region id=1 tac_list=7627107,100,788,200,258,0 plmn=311:489	
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    set_upf id=1 daemon=10.0.2.1:22222 type=simulated addr=1.2.4.1/24 ngu=10.0.1.1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=off
    #Update Cfg    set_backup_amf main=1 backup_amfs=2
    Update Cfg    set_nwslice id=1 snssai=0x01:13714341 default=on ue=1-6 amf=1
    #---------------------------------------------------------------------------------------------------
    # GNB CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    ${cmd_1}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.112 x2=10.0.1.2:36422 ng=10.0.1.2
    ...    gnb_id=0x76C daemon=10.0.2.1:22222 xn=10.0.1.2 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5
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


OAM control setup one xnlink
    Wait Until Keyword Succeeds    60s    2s    Object Should Not Exist    XNLINK:xnLinkStatus=available
    Execute Egate Command    gnb_param id=3 send_xn_setup=false
    OnlineParamChange    ${add_NRADJgNB_and_XNlink}
	Wait Until Keyword Succeeds    120s    2s    Object Should Exist    XNLINK:xnLinkStatus=available
	
OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

SA UE Register and PDU Setup
    [Arguments]    ${ue_id}=1    ${cmd_pdu_regexp}=QoS Routing Table
	Execute Egate Command    ue_change_location id=${ue_id} cell=1 enb=2
    Execute Egate Command    ue_register id=${ue_id} nwslice=1    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_regexp}

Check Throughput with Type
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_expect}=80    ${CC_num}=2    ${type}=pdsch
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
    [Arguments]    ${ue_id}=1    ${wait_timer}=0.5    ${cell_id}=1    ${gnb_id}=2    ${expect_regexp}=${EMPTY}
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


Verify Throuput
    [Arguments]    ${Tput_dl}=8    ${Tput_ul}=8    ${sleep_time}=60s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10
    Verify Throuput

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


Disable actincxn and incoming xnsetupfailure
    BuiltIn.Log    Set parameter for BA001 and xnsetupfailure condition...     console=${True}
	OnlineParamChange    ${BA001_disableactincxn}
    #Update SCF parameter    dist_name=${DIST_NAME}    parameter=retryXnSetupTmr    value=20    timeout=60
    #Update SCF parameter    dist_name=${DIST_NAME}    parameter=actIncXn    value=false    timeout=60
    Execute Egate Command        gnb_xn_setup_param id=3 reset
	#Sleep 60s
    ${cmd1}    Catenate    gnb_xn_setup_param id=3 action=force_failure nth=1 ntimes=4 time_to_wait=v10s
    ...    cause=CauseProtocol_unspecified
    Execute Egate Command    ${cmd1}

Check XN still unavailable after lock unlock NRADJGNB
    Delta Commission Parameters    NRADJGNB-10:administrativeState=Locked
	Delta Commission Parameters    NRADJGNB-10:administrativeState=Unlocked
    Object Should Exist    XNLINK-10:xnLinkStatus=unavailable
	Sleep    100s

Check XN still available after lock unlock NRADJGNB
    Execute Egate Command        gnb_xn_setup_param id=5 reset
	Delta Commission Parameters    NRADJGNB-10:administrativeState=Locked
	Delta Commission Parameters    NRADJGNB-10:administrativeState=Unlocked
    Object Should Exist    XNLINK-10:xnLinkStatus=available
	#To check reset happen again while XN is available after lock NRADJGNB
	Delta Commission Parameters    NRADJGNB-10:administrativeState=Locked
	Delta Commission Parameters    NRADJGNB-10:administrativeState=Unlocked
    Object Should Exist    XNLINK-10:xnLinkStatus=available

OAM control setup another xnlink
    #Execute Egate Command    gnb_param id=5 send_xn_setup=false
	#OnlineParamChange    ${add_2ndNRADJgNB_and_XNlink}
	OnlineParamChange    ${BA001_actincxn}
	Execute Egate Command    gnb_xn_link_up gnb=5 target=2 xn_link_addr=10.0.1.2
	Wait Until Keyword Succeeds    120s    2s    Object Should Not Exist    XNLINK-2:xnLinkStatus=unavailable

Teardown for 5GC001979
    [Arguments]    ${Restore_params}
    OnlineParamChange    ${Restore_params}
    Common Test Teardown And Stop Capture Logs
