*** Settings ***
Documentation
...		[Author]     			"Santoshkumar"
...		[Maintenance]			"TRS I & V Tools Bangalore Team"
...		[Date] 					"05:10:2023"
...		[QC_Path]               "QC_Path in Test Plan"
...		[QC_ID]					"QC_ID in Test Lab for reporting"
...		[Feature_ID] 			"NCDR"
...		[Procedure]   			"IPSEC_NCDR_INV"
...     [Validated_TestLine]    "IV_BLR_TL001"
...     [Precondition]          "ASIB+ABIL+ABIA"
...     [Config_Comments]       ""

Variables       ta_e2e_bts_trs_fw
Library		ute_fsmaccess
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Library          SSHLibrary

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Variables ***
${counters_analysis}     ${CURDIR}/resources/counters_analysis.json

*** Test Cases ***

[1]IPSEC_NCDR_with_verification_of_calls
    Perform Commissioning       scf_file=${basic_1}        verify_bts_status=False         timeout=600         alias=default
    Sleep   420
    Perform Recommissioning		type=delta		delta_file=${update_647}		skip_parameter_relation_errors=${True}		timeout=300
    Sleep   300
	Run		sudo ipsec restart
    Sleep   600
    Verify Ipsec Tunnels Status
    Sleep   300


    Setup Remote Access     remote_device=bts     timeout=30     alias=default
    ${no_tunnel}=       Remote Command Execute      command=ipsec status | grep INSTALLED | wc -l
    Sleep   50
    Set Suite Variable     ${no_tunnel}
    Teardown Remote Access     alias=default
    Log    ${no_tunnel}


    Call Setup      5g=kbk_plain:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4
    Sleep    100
    Perform Recommissioning		type=delta		delta_file=${update_10}		skip_parameter_relation_errors=${True}		timeout=300
    Sleep	600
    Verify Ipsec Tunnels Status
    Start SA Calls

    Setup Remote Access     remote_device=bts     timeout=30     alias=default
    ${no_tunnel}=       Remote Command Execute      command=ipsec status | grep INSTALLED | wc -l
    Sleep   50
    Set Suite Variable     ${no_tunnel}
    Teardown Remote Access     alias=default
    Log    ${no_tunnel}

    Traffic Capture Start        capture_device=oam_device    mode=file		measurement_point=NE_Terminated
    ...    uplane_capturing=True		timeout=120  	alias=capture_fileD
	Sleep   600
    Run Keyword And Ignore Error    Verify Alarm        	faultid=61641
    ${filename_2no_pwd}=   Traffic Capture Stop		mode=file		alias=capture_fileD		timeout=120
    Stop SA Calls

    Perform Recommissioning     type=delta      delta_file=${delta_false}     skip_parameter_relation_errors=${True}      timeout=300
    Sleep   300
    Verify Ipsec Tunnels Status

    Counter analysis
    Verify the counters

    Setup Remote Access     remote_device=bts     timeout=30     alias=default
    ${no_tunnel}=       Remote Command Execute      command=ipsec status | grep INSTALLED | wc -l
    Sleep   50
    Set Suite Variable     ${no_tunnel}
    Teardown Remote Access     alias=default
    Log    ${no_tunnel}

    Perform Recommissioning     type=delta      delta_file=${update_10}     skip_parameter_relation_errors=${True}      timeout=300
    Sleep   300
    Verify Ipsec Tunnels Status


    Setup Remote Access     remote_device=bts     timeout=30     alias=default
    ${no_tunnel}=       Remote Command Execute      command=ipsec status | grep INSTALLED | wc -l
    Sleep   50
    Set Suite Variable     ${no_tunnel}
    Teardown Remote Access     alias=default
    Log    ${no_tunnel}

    Counter analysis
    Verify the counters
    Sleep   50

	Collect Snapshot		timeout=900
	Collect Im Snapshot		timeout=120

*** Keywords ***
Verify Ipsec Tunnels Status
    [Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel	query=get list ${ike_sa_l_moc_path}	alias=${dut}
    FOR    ${ike_tunnel}	IN      @{parent_tunnel_moc_list}
     	${parent_tunnel_stateInfo}=     Get From Dictionary	dictionary=${ike_tunnel}	key=stateInfo
     	${parent_tunnel_proceduralState}=    Get From Dictionary	dictionary=${parent_tunnel_stateInfo}	key=proceduralState
     	Should Be True	'${parent_tunnel_proceduralState}'=='Established'
    END

    @{child_tunnel_moc_list} =      Query Admin Infomodel	query=get list ${ipsec_sa_l_moc_path}	alias=${dut}
    FOR    ${child_tunnel}    IN       @{child_tunnel_moc_list}
    	${child_tunnel_stateInfo}=      Get From Dictionary	dictionary=${child_tunnel}	key=stateInfo
     	${child_tunnel_proceduralState}=        Get From Dictionary	dictionary=${child_tunnel_stateInfo}	key=proceduralState
     	Should Be True	'${child_tunnel_proceduralState}'=='Installed'
    END

Counter analysis
    [Documentation]        This test case keyword is to start the counter
    PM Counters Start       analysis=verify_counters      counters_analysis=${counters_analysis}


Verify the counters
    [Documentation]        This test case keyword is to verify counter and ue stats
    Verify PM Counters      analysis=verify_counters      counters_analysis=${counters_analysis}


Start SA Calls
    Configure UE    5G=kbk_plain:data        command=ue_register        id=1        profile=1
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=ue_pdu_session_setup        pdu=1        gw=1         ue=1
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start         ue=1         pdu=1        qfi=1        dir=dl        mbps=20
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start        ue=1        pdu=1        qfi=1         dir=ul         mbps=20
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=1    pdu=1    qfi=1    dir=dl    trf_id=1     protocol=udp    mbps=175
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=1    pdu=1    qfi=1    dir=dl    trf_id=2     protocol=tcp    mbps=175
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=1    pdu=1    qfi=1    dir=dl    trf_id=3     protocol=udp    mbps=175
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=1    pdu=1    qfi=1    dir=dl    trf_id=4     protocol=tcp    mbps=175
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=1    pdu=1    qfi=1    dir=dl    trf_id=5     protocol=udp    mbps=75
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=1    pdu=1    qfi=1    dir=ul    trf_id=1     protocol=tcp    mbps=175
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_start    ue=1    pdu=1    qfi=1    dir=ul    trf_id=2     protocol=udp    mbps=75

Stop SA Calls
    Configure UE    5G=kbk_plain:data        command=ue_pdu_session_release         ue=1        pdu=1
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_stop        ue=1        dir=dl
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=trf_data_stop        ue=1        dir=ul
    Sleep   20
    Configure UE    5G=kbk_plain:data        command=ue_deregister        id=1        ue_deregister_type=switch_off
