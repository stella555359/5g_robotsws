*** Settings ***
Documentation
...            [Author]         "Mansi"

Resource        ${CURDIR}/../../resources/common_keywords.robot
Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot

*** Keywords ***
Fluctuate Backhaul link and verify lte calls
    FOR    ${i}    IN RANGE    1    11
	    Backhaul link fluctuation
	    Call Setup      lte=lte_data:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4
	    verify calls for LTE
    END

Fluctuate Backhaul link and verify 5G calls
    FOR    ${i}    IN RANGE    1    11
	    Backhaul link fluctuation
	    Call Setup      5g=5g_nr:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4
	    verify calls for 5G
    END

Backhaul link fluctuation
    Configure Switch    link1    shutdown_te_interface
    Sleep	10
    Verify Ping Should Fail    10.0.1.2
    Configure Switch    link1    noshutdown_te_interface
    Verify Ping Should Pass    10.0.1.2

Verify Ping Should Fail
    [Arguments]    ${ip}
    ${rc}    ${out}=    Run And Return Rc And Output    ping -c 5 ${ip}
    Log    ${out}
    Should Not Be Equal As Integers    ${rc}    0

Verify Ping Should Pass
    [Arguments]    ${ip}
    ${rc}    ${out}=    Run And Return Rc And Output    ping -c 10 ${ip}
    Log    ${out}
    Should Be Equal As Integers    ${rc}    0

verify calls for 5G
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=True    timeout=120
    Start SA Calls
    Sleep	60
    Stop SA calls
    ${Point_A_Capture}=   Traffic Capture Stop      mode=file       timeout=120
    ${ngap_UL}=		Analyse Pcap    pcap_filename=${Point_A_Capture}        analysis=ngap_UL
    ${ngap_DL}=		Analyse Pcap    pcap_filename=${Point_A_Capture}        analysis=ngap_DL

Start SA Calls
    Configure UE    5g=5g_nr:data        command=ue_register        id=1        profile=1
    Sleep   3
    Configure UE    5g=5g_nr:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
    Sleep   3
    Configure UE    5g=5g_nr:data        command=ue_pdu_session_setup        pdu=1        gw=1         ue=1
    Sleep   3
    Configure UE    5g=5g_nr:data        command=trf_data_start         ue=1         pdu=1        qfi=1        dir=dl        mbps=20
    Sleep   3
    Configure UE    5g=5g_nr:data        command=trf_data_start        ue=1        pdu=1        qfi=1         dir=ul         mbps=20

Stop SA calls
    Configure UE    5g=5g_nr:data        command=ue_pdu_session_release         ue=1        pdu=1
    Sleep   3
    Configure UE    5g=5g_nr:data        command=trf_data_stop        ue=1        dir=dl
    Sleep   3
    Configure UE    5g=5g_nr:data        command=trf_data_stop        ue=1        dir=ul
    Sleep   3
    Configure UE    5g=5g_nr:data        command=ue_deregister        id=1        ue_deregister_type=switch_off

verify calls for LTE
    Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=True    timeout=120
    Start LTE Calls
    Sleep	60
    ${Point_A_Capture}=   Traffic Capture Stop      mode=file       timeout=120
    ${Verify_s1ap_packets}=		Analyse Pcap    pcap_filename=${Point_A_Capture}        analysis=Verify_s1ap_packets
    ${gtp_UL}=		Analyse Pcap    pcap_filename=${Point_A_Capture}        analysis=gtp_UL
    ${gtp_DL}=		Analyse Pcap    pcap_filename=${Point_A_Capture}        analysis=gtp_DL

Start LTE Calls
    Configure UE    lte=lte_data:data    command=ue_attach id=12 cell=12
    Sleep   3
    Configure UE    lte=lte_data:data    command=trf_data_start ue=12 dir=ul Mbps=20 protocol=udp
    Sleep   3
    Configure UE    lte=lte_data:data    command=trf_data_start ue=12 dir=dl Mbps=20 protocol=udp
    Sleep   3

Stop LTE calls
    Configure UE    lte=lte_data:data        command=ue_detach id=12

Precondition
    ${pid}=    Run     ps -ef |grep Nemuadmin |grep -iv grep |awk -F" " '{print $2}'
    Run     sudo kill -9 ${pid}

Checking the Alarm Status
	[Arguments]		${FAULT_ID}		${alarm}
	Verify Alarm		faultid=${FAULT_ID}		rat=lte		should_exist=${alarm}	occurrences=1	  check_unexpected_alarms=${false}

LMP_PORT Alarm should exit
	Checking the Alarm Status	${LMP}	True

Changing service account
    [Arguments]    ${param_path}    ${value}    ${fault_id}    ${alarm}

    Perform Recommissioning
    ...    type=param
    ...    rat=lte
    ...    param_path=${param_path}
    ...    operation=update
    ...    value=${value}
    ...    timeout=300

    Sleep    60

    Checking the Alarm Status
    ...    ${fault_id}
    ...    ${alarm}

Verify the SSH and R&D status on IMS
	[Arguments]		${status}
	${state}=     Query Admin Infomodel       query=get object //SECADM_R-*
	Log To console	${state}
	${values}=		Get From Dictionary		${state}	${status}

Change credentials of Using with credentials
    [Arguments]
    ...    ${admin_username}
    ...    ${admin_password}
    ...    ${new_username}
    ...    ${new_password}
    ...    ${old_username}
    ...    ${old_password}
    ...    ${account_type}

    Setup Oamops
    ...    dut=bts
    ...    username=${admin_username}
    ...    password=${admin_password}

    User Account Manage
    ...    operation=manage_local_user_account
    ...    new_username=${new_username}
    ...    new_password=${new_password}
    ...    old_username=${old_username}
    ...    old_password=${old_password}
    ...    account_type=${account_type}

    Teardown Oamops
    Sleep    10s

    Setup Oamops
    ...    dut=bts
    ...    bts_port=443
    ...    username=${new_username}
    ...    password=${new_password}
    ...    use_ssl=True

    Checking the Alarm Status    ${LMP}    True
    Teardown Oamops

    Setup Oamops
    ...    bts_host=${plain_mplane_ip}
    ...    bts_port=443
    ...    username=${new_username}
    ...    password=${new_password}
    ...    use_ssl=True

    Teardown Oamops


Verify with different credentials
    Change credentials of Using with credentials
    ...    Nemuadmin
    ...    nemuuser
    ...    btssec
    ...    Btsec@123
    ...    nemuuser
    ...    BtsSecurity
    ...    BTSSecurity

    Change credentials of Using with credentials
    ...    Nemuadmin
    ...    nemuuser
    ...    btsapp
    ...    Btsap@123
    ...    nemuuser
    ...    BtsApplication
    ...    BTSApplication

    Change credentials of Using with credentials
    ...    Nemuadmin
    ...    nemuuser
    ...    btsread
    ...    Btsrea@123
    ...    nemuuser
    ...    BtsRead
    ...    BTSRead