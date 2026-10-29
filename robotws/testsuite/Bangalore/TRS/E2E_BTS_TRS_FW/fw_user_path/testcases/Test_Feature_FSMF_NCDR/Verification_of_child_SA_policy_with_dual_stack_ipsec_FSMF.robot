*** Settings ***


Documentation

...		[Procedure]	"CDRT_04572591_With_Dynamic_Inner_IP"
...		[Date]		"16-04-2025"
...		[Author]	"Meghana J"
...		[Feature_ID]	"SR001941"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/../resources/Common_Ipsec_Rekeying.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Setup Oamops
Suite Teardown     Teardown Oamops

*** Test Cases ***
[1]Verification_of_child_SA_policy_with_dual_stack_ipsec_FSMF
    Preconditions
    Send traffic and verify packets
	IPSEC and Strongswan Configuration
    Verify IPSec Status ESTABLISHED
	Get IKE ID Value Before Rekeying
	Verify IPSec Status after CMP Initialization
	Verify ESP SPI Before and After Rekeying
	Verify IKE and ESP SPI Before and After Rekeying
	Verify IKE ID After Rekeying
	Run Keyword And Ignore Error    Verify Alarm      prev_alarms=${expected_alarms}     check_unexpected_alarms=${True}

*** Keywords ***
Preconditions
	Perform Commissioning       scf_file=${base_scf_dynamic_inner_IP}   verify_bts_status=False     timeout=400     alias=default
	Sleep	300
    Call Setup      lte=IPSEC_config:data   parallel=${False}    verify_attach=${False}       attach=${False}
	Verify BTS status   should_be_onair=${True}

Perform Recommissioning with Dynamic Inner IP configuration
	Perform Recommissioning        type=delta      delta_file=${IPSEC}       skip_parameter_relation_errors=${True}      timeout=300

Preconditions_1
	Run    sudo cp ${IPSEC_CONF} ${BACKUP_PATH}
	Run    sudo mv ${IPSEC_CONF_WITH_UNIQUE_ID} ${IPSEC_CONF}
	Sleep	40

Verify Ipsec Tunnels Status
#    [Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel    query=get list ${ike_sa_l_moc_path}
    FOR    ${ike_tunnel}   IN      @{parent_tunnel_moc_list}
    ${parent_tunnel_stateInfo}=     Get From Dictionary         dictionary=${ike_tunnel}    key=stateInfo
    ${parent_tunnel_proceduralState}=    Get From Dictionary        dictionary=${parent_tunnel_stateInfo}   key=proceduralState
    Should Be True  '${parent_tunnel_proceduralState}'=='Established'
    END

    @{child_tunnel_moc_list} =      Query Admin Infomodel   query=get list ${ipsec_sa_l_moc_path}
    FOR    ${child_tunnel}    IN       @{child_tunnel_moc_list}
    ${child_tunnel_stateInfo}=      Get From Dictionary         dictionary=${child_tunnel}  key=stateInfo
    ${child_tunnel_proceduralState}=        Get From Dictionary     dictionary=${child_tunnel_stateInfo}    key=proceduralState
    Should Be True  '${child_tunnel_proceduralState}'=='Installed'
    END


IPSEC and Strongswan Configuration
    Perform Recommissioning     type=param      rat=lte      param_path=IPSECC-1:ipSecEnabled    operation=update    value=true  timeout=300
    Sleep   60
    Run         sudo ipsec restart
    sleep       120


    Certificate Configure    operation=install_certificate    cert_file=${valid_ipsec_cert}     cert_type=BtsTrustChain     cert_format=P12
    ...     password=${valid_ipsec_cert_password}
    sleep     60
#    ----------- 04572591 implementation -----
    Verify Ipsec Tunnels Status
    Certificate Configure       operation=install_cmp_certificate       key_pool_type=RSA       timeout=300
    sleep     60
    Run    sudo ipsec restart
    Sleep   60
    Verify Ipsec Tunnels Status

    Perform Recommissioning     type=param      rat=lte      param_path=IPSECC-1:ipSecEnabled    operation=update    value=false  timeout=300
    Sleep   60

    Perform Recommissioning     type=param      rat=lte      param_path=IPSECC-1:ipSecEnabled    operation=update    value=true  timeout=300
    Sleep   60

#    Perform Recommissioning     type=delta    delta_file=${Disable_Ipsec}    timeout=600
#    sleep    15
#    Perform Recommissioning     type=delta    delta_file=${Enable_Ipsec}    timeout=600
    Run    sudo ipsec restart
    sleep    60
    Verify Ipsec Tunnels Status
    Certificate Configure       operation=cmp_update_key       key_pool_type=RSA       timeout=300
    sleep    10
    Run    sudo ipsec restart
    sleep    60
    Verify Ipsec Tunnels Status
#-------------------------04572591 END ---------------


Verify IPSec Status after CMP Initialization
	Certificate Configure	operation=install_cmp_certificate	timeout=120
	Sleep	100
	Perform Recommissioning		type=param		param_path=IPSECC-1:ipSecEnabled	operation=update	value=false		timeout=60
	Sleep	10
	Verify IPSec Status NO_STATE
	Perform Recommissioning		type=param		param_path=IPSECC-1:ipSecEnabled	operation=update	value=true		timeout=60
	Sleep	30
	Verify IPSec Status ESTABLISHED
	Certificate Configure	operation=cmp_update_key	timeout=120

Verify IPSec Status NO_STATE
    ${ikep_list}=    Query Admin Infomodel    query=get list //IKEP_R-1    timeout=30
    ${length}=       Get Length    ${ikep_list}
    Log    Total IKEP instances: ${length}

    FOR    ${item}    IN    @{ikep_list}
        ${state}=     Get From Dictionary    ${item}    ikePeerState
        Should Be Equal    ${state}    ${EXPECTED_STATE}
    END

Verify IPSec Status ESTABLISHED
    ${ikep_list}=    Query Admin Infomodel    query=get list //IKEP_R-1    timeout=30
    ${length}=       Get Length    ${ikep_list}
    Log    Total IKEP instances: ${length}

    FOR    ${item}    IN    @{ikep_list}
        ${state}=     Get From Dictionary    ${item}    ikePeerState
        Should Be Equal    ${state}    ${IKEP_State}
    END

Update IKE Max Lifetime
	Perform Recommissioning		type=param_path		param_path=IKEP-1:ikeMaxLifeTime	operation=update	value=3600	timeout=90
	Perform Recommissioning		type=param_path		param_path=IKEP-2:ikeMaxLifeTime	operation=update	value=3600	timeout=90

Verify IKE and ESP SPI Before and After Rekeying
	Get IKE SPI Value Before Rekeying
	Get ESP SPI value before Rekeying
	Sleep	${max_val}
	Verify IKE SPI After Rekeying
	Verify ESP SPI After Rekeying

Update SA Max Lifetime
	Perform Recommissioning		type=param_path		param_path=IPSECP-1:saMaxLifeTime		operation=update	value=300	timeout=90
	Perform Recommissioning		type=param_path		param_path=IPSECP-2:saMaxLifeTime		operation=update	value=300	timeout=90

Verify ESP SPI Before and After Rekeying
#    FOR    ${i}    IN RANGE    1    9
		Get ESP SPI value before Rekeying
		Sleep    ${max_val_esp}
#		Verify ERekeyingSP SPI After
#        Verify IKE SPI After Rekeying
        Verify ESP SPI After Rekeying

#    END

Send traffic and verify packets
    Traffic Capture Start         capture_device=vm_eth3_interface      alias=ipsec_packets
    Configure UE      lte=IPSEC_config:data     command=ue_attach id=1 cell=1
    Sleep   5
    Configure UE      lte=IPSEC_config:data     command=trf_data_start ue=1 dir=dl protocol=udp Mbps=150
    Sleep   5
    Configure UE      lte=IPSEC_config:data     command=trf_data_start ue=1 dir=ul protocol=udp Mbps=150
    Sleep   60

#    Sleep   60
    ${Wireshark_file} =      Traffic Capture Stop        alias=ipsec_packets

    Point A Traffic capture and verify
#    Point B Traffic capture and verify for ESP Packets


Point A Traffic capture and verify
#    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=True   timeout=120
    sleep   60

    ${filename_A}=  Traffic Capture Stop   mode=file    timeout=100

    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=UL_Traffic_check1
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}     analysis=DL_Traffic_check1

Point B Traffic capture and verify for ESP Packets
#    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=True   timeout=120

    sleep   60

    ${filename_A}=  Traffic Capture Stop   mode=file    timeout=100

    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=ESP
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}     analysis=ESP


Choose algorithm and establish tunnel
	[Arguments]		${Algorithm_PFS_File}		${PFS_Flag}
	${RandomChossenIkeEncryption}=			Evaluate	random.choice(@{IKEEncryptionLList})	random
	Remove Values From List		${IKEEncryptionLList}		${RandomChossenIkeEncryption}
	${RandomChossenIkeAuthentication}=		Evaluate	random.choice(@{IKEAuthnenticationLList})	random
	Remove Values From List		${IKEAuthnenticationLList}		${RandomChossenIkeAuthentication}
	${RandomChossenESPEncryption}=			Evaluate	random.choice(@{ESPEncryptionMethod})	random
	Remove Values From List		${ESPEncryptionMethod}		${RandomChossenESPEncryption}
	${RandomChossenESPAuthentication}=		Evaluate	random.choice(@{ESPAuthenticationMethod})	random
	Remove Values From List		${ESPAuthenticationMethod}		${RandomChossenESPAuthentication}
	${RandomChosenDHAlgorithm}=			Evaluate	random.choice(@{IKEDHGroupList})	random
	Remove Values From List		${IKEDHGroupList}	${RandomChosenDHAlgorithm}
	${RandomPFSDHGroup}=	Evaluate	random.choice(@{PFSDHGroupList})	random
	Set Suite Variable		${RandomChossenIkeEncryption}		${RandomChossenIkeEncryption}
	Set Suite Variable		${RandomChossenIkeAuthentication}	${RandomChossenIkeAuthentication}
	Set Suite Variable		${RandomChossenESPEncryption}		${RandomChossenESPEncryption}
	Set Suite Variable		${RandomChossenESPAuthentication}	${RandomChossenESPAuthentication}
	Set Suite Variable		${RandomChosenDHAlgorithm}			${RandomChosenDHAlgorithm}
	Set Suite Variable 		${RandomPFSDHGroup}		${RandomPFSDHGroup}
	Run     cp ${Algorithm_PFS_File} ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenIkeEncryption}}/${RandomChossenIkeEncryption}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenIkeAuthentication}}/${RandomChossenIkeAuthentication}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenESPEncryption}}/${RandomChossenESPEncryption}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenESPAuthentication}}/${RandomChossenESPAuthentication}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChosenDHAlgorithm}}/${RandomChosenDHAlgorithm}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{PFS_Flag}}/${PFS_Flag}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomPFSDHGroup}}/${RandomPFSDHGroup}/g' ${Algorithm_Delta}
	Perform Recommissioning		type=delta		delta_file=${Algorithm_Delta}
    Sleep   60
	Enable Ipsec on Admin
	Enable Ipsec on SecureGW
    Sleep   60
#    Disable Ipsec on Admin


Get IKE SPI Value Before Rekeying
	${IKE_SPI_I_BeforeRekey}=       Create List
	${IKE_SPI_R_BeforeRekey}=       Create List
	${IKE_lifetime_list}=        Create List

	FOR    ${i}   IN RANGE     1   10
	${ikeMaxLifeTime}=		Get Parameter		param_path=IKEP-${i}:ikeMaxLifeTime
	Append To List      ${IKE_lifetime_list}     ${ikeMaxLifeTime}
    END
	FOR    ${i}   IN   @{Combination_1_Policy_List}
	   ${index}=       Get index from List    ${Combination_1_Policy_List}        ${i}
	   ${sa_lifetime}=     Get From List       ${IKE_lifetime_list}     ${index}
	   Set Suite Variable      ${sa_lifetime}      ${sa_lifetime}
	   Execute command on ENodeB       ipsec statusall | grep "IKEv2 SPI" | grep conn${i}
	   @{ipsec_status}=    Split String        ${stdout}
	   ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     3
	   ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     4
	   Append To List      ${IKE_SPI_I_BeforeRekey}        ${initiator_IKEv2_SPI}
	   Append To List      ${IKE_SPI_R_BeforeRekey}        ${responder_IKEv2_SPI}
	   ${max_val}=     Evaluate    ${sa_lifetime}-${rekey_margin}
    END
	Set Suite Variable      ${IKE_SPI_I_BeforeRekey}        ${IKE_SPI_I_BeforeRekey}
	Set Suite Variable      ${IKE_SPI_R_BeforeRekey}        ${IKE_SPI_R_BeforeRekey}
	Set Suite Variable      ${max_val}      ${max_val}

Verify IKE SPI After Rekeying
    ${index}=   Set Variable        0
    FOR    ${i}    IN   @{Combination_1_Policy_List}
       Execute command on ENodeB       ipsec statusall | grep "IKEv2 SPI" | grep conn${i}
       @{ipsec_status}=    Split String        ${stdout}
       ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     3
       ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     4
       Should Not Be Equal As Strings      ${initiator_IKEv2_SPI}      ${IKE_SPI_I_BeforeRekey}[${index}]
       Should Not Be Equal As Strings      ${responder_IKEv2_SPI}      ${IKE_SPI_R_BeforeRekey}[${index}]
       ${index}=   Evaluate    ${index}+1
    END

Get ESP SPI value before Rekeying
    ${ESP_SPI_InitiatorList_Before_rekeying}=    Create List
    ${ESP_SPI_ResponderList_Before_rekeying}=    Create List

    ${max_val_esp}=    Set Variable    ${sa_lifetime}
    Set Suite Variable    ${max_val_esp}

    FOR    ${i}    IN    @{Combination_1_Policy_List}
        Execute command on ENodeB    ipsec statusall | grep "ESP SPI" | grep conn${i}
        @{ipsec_status}=    Split String    ${stdout}
        ${initiator_ESP_SPI}=    Get From List    ${ipsec_status}    7
        ${responder_ESP_SPI}=    Get From List    ${ipsec_status}    8
        Append To List    ${ESP_SPI_InitiatorList_Before_rekeying}    ${initiator_ESP_SPI}
        Append To List    ${ESP_SPI_ResponderList_Before_rekeying}    ${responder_ESP_SPI}
    END

    Set Suite Variable    @{ESP_SPI_InitiatorList_Before_rekeying}
    Set Suite Variable    @{ESP_SPI_ResponderList_Before_rekeying}


Verify ESP SPI After Rekeying
    Set Suite Variable      ${index}    0
    FOR    ${i}    IN      @{Combination_1_Policy_List}
       Execute command on ENodeB   ipsec statusall | grep "ESP SPI" | grep conn${i}
       @{ipsec_status}=        Split String    ${stdout}
       ${initiator_ESP_SPI}=       Get From List   ${ipsec_status}     7
       ${responder_ESP_SPI}=   Get From List   ${ipsec_status}     8
       Should Not Be Equal As Strings      ${initiator_ESP_SPI}        ${ESP_SPI_InitiatorList_Before_rekeying}[${index}]
       Should Not Be Equal As Strings      ${responder_ESP_SPI}        ${ESP_SPI_ResponderList_Before_rekeying}[${index}]
       ${index}=   Evaluate    ${index}+1
       Set Suite Variable  ${index}    ${index}
    END

Get IKE ID Value Before Rekeying
	@{IKE_request_ID_BeforeRekey}=       Create List

	FOR    ${i}   IN   @{Combination_1_Policy_List}
	   ${index}=       Get index from List    ${Combination_1_Policy_List}        ${i}
	   Execute command on ENodeB   ipsec statusall | grep "IKEv2 SPI" | grep conn${i}
#	   Execute command on ENodeB	ipsec statusall | grep "conn${i}" | sed -n 's/^\(conn[^{]*{[0-9]*}\)/\1/p'
	   @{ipsec_status}=    Split String        ${stdout}
	   ${IKE_ID_BeforeRekey}=         Get From List       ${ipsec_status}	0
	   ${conn}=    Remove String    ${IKE_ID_BeforeRekey}    :
	   Append To List      ${IKE_request_ID_BeforeRekey}        ${IKE_ID_BeforeRekey}
    END
	Set Suite Variable      @{IKE_request_ID_BeforeRekey}        @{IKE_request_ID_BeforeRekey}

Verify IKE ID After Rekeying
    ${index}=   Set Variable        0
    FOR    ${i}    IN   @{Combination_1_Policy_List}
       Execute command on ENodeB   ipsec statusall | grep "IKEv2 SPI" | grep conn${i}
       @{ipsec_status}=    Split String        ${stdout}
       ${IKE_ID_AfterRekey}=         Get From List       ${ipsec_status}	0
	   ${conn}=    Remove String    ${IKE_ID_AfterRekey}    :
       Should Not Be Equal As Strings      ${IKE_ID_AfterRekey}      ${IKE_request_ID_BeforeRekey}[${index}]
       ${index}=   Evaluate    ${index}+1
    END


Verify IKE Algorithm
	FOR    ${i}     IN     @{Combination_1_Policy_List}
		Execute command on ENodeB		ipsec statusall | grep "IKE proposal" | grep conn${i}
		${IKE_Authentication_enB}=		Get From Dictionary		${IKEAuthenticationDict}	${RandomChossenIkeAuthentication}
		Should Match Regexp			'${stdout}'			${IKE_Authentication_enB}
		${IKE_Encryption_enB}=		Get From Dictionary		${IKEEncryptionDict}	${RandomChossenIkeEncryption}
		Should Match Regexp			'${stdout}'		${IKE_Encryption_enB}
#		@{ipsec_status}=	Split String	${stdout}		/
#		${IKE_Status_List}=		Get From List		${ipsec_status}		0
#		${IKE_Enc_List_2}=		Split String	${IKE_Status_List}
#		${IKE_Enc}=		Get From List	${IKE_Enc_List_2}	3
#		${Ike_ENC_enB}=		Get From Dictionary		${IKEEncryptionDict}	${IKE_Enc}
#		Run Keyword And Ignore Error	should_be_equal_as_strings		${Ike_ENC_enB}		${RandomChossenIkeEncryption}
#		${IKE_Auth}=		Get From List		${ipsec_status}		1
#		${Ike_AUTH_enB}=		Get From Dictionary		${IKEAuthenticationDict}		${IKE_Auth}
#		Run Keyword And Ignore Error	should_be_equal_as_strings		${Ike_AUTH_enB}		${RandomChossenIkeAuthentication}
#		${IKE_DH}=		Get From List		${ipsec_status}			3
#		${IKE_DH_enB}=		Get From Dictionary		${IKEDHGroupDict}		${IKE_DH}
#		Run Keyword And Ignore Error	should_be_equal_as_strings		${IKE_DH_enB}		${RandomChosenDHAlgorithm}
	END

Verify ESP Algorithm
	FOR    ${i}     IN     @{Combination_1_Policy_List}
		Execute command on ENodeB    ipsec statusall | grep conn${i}
    	${ESP_Algorithm_Line}=    Get Line    ${stdout}   -1
		${ESP_Encryption_Algorithm_enB}=        Get From Dictionary     ${ESPEncryptionDict}    ${RandomChossenESPEncryption}
        Should Match Regexp     '${ESP_Algorithm_Line}'       ${ESP_Encryption_Algorithm_enB}
		${ESP_Authentication_Algorithm_enB}=	Get From Dictionary 	${ESPAuthenticationDict}	${RandomChossenESPAuthentication}
		Should Match Regexp  	 	'${ESP_Algorithm_Line}'		${ESP_Authentication_Algorithm_enB}
#		@{ESP_Algorithm_List}=	Split String	${ESP_Algorithm_Line}
#		${ESP_Algorithms}=		Get From List	${ESP_Algorithm_List}		1
#		${ESP_Algorithms_Array}=	Split String	${ESP_Algorithms}		/
#		${ESP_Encryption_Algorithm}=	Get From List	${ESP_Algorithms_Array}		0
#		${ESP_Authentication_Algorithm}=	Get From List	${ESP_Algorithms_Array}		1
#		${ESP_Encryption_Algorithm_enB}=		Get From Dictionary		${ESPEncryptionDict}		${ESP_Encryption_Algorithm}
#		${ESP_Authentication_Algorithm_enB}=	Get From Dictionary		${ESPAuthenticationDict}		${ESP_Authentication_Algorithm}
#		Run Keyword And Ignore Error	Should Be Equal As Strings		${ESP_Encryption_Algorithm_enB}		${RandomChossenESPEncryption}
#		Run Keyword And Ignore Error	Should Be Equal As Strings		${ESP_Authentication_Algorithm_enB}		${RandomChossenESPAuthentication}
    END

Get the combination from conf file in enB
	Enable Ipsec On Bts
	Sleep 	60
	Execute command on ENodeB		cp /etc/ipsec.conf /tmp/ipsec.conf
	Setup Enb Fsm Access
	File Should Exist On Enb		/tmp/ipsec.conf
	Disable Ipsec On Bts
	Sleep 	30
	Get Enb File	/tmp/ipsec.conf   /home/ute/bts_ipsec.conf
	${ike_value}=	Run		awk '/ike=/' /home/ute/bts_ipsec.conf | sed -n '2p'
	${esp_value}=	Run		awk '/esp=/' /home/ute/bts_ipsec.conf | sed -n '1p'
	Run 	sed -i 's/\bike=.*$/${ike_value}/' ${SECGW_CONF}
	Run 	sudo sed -i 's/esp=.*/${esp_value}/g' ${SECGW_CONF}
	Teardown Enb Fsm Access

Check for IKE rekeying values on eNB according to rekeymargin and rekeyfuzz values
	@{IKE_SPI_InitiatorList_Before_rekeying}=		Create List
	@{IKE_SPI_ResponderList_Before_rekeying}=		Create List
	@{IKE_rekeying_time}=		Create List
	@{sa_lifetime_list}=		Create List

	FOR    ${i}   IN RANGE		1	5
		${a}=	Get Element Text      ${target_file}
        ... .//managedObject[@distName="MRBTS-1/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-${i}"]//p[@name="ikeMaxLifeTime"]
		Append To List		${sa_lifetime_list}		${a}
    END
	${policy_number}=		Create List		50	60	70

	FOR    ${i}   IN   @{policy_number}
		${index}=       Get index from List    ${policy_number}        ${i}
		${sa_lifetime}=		Get From List		${sa_lifetime_list}		${index}
		Set Suite Variable		${sa_lifetime}		${sa_lifetime}

		Execute command on ENodeB		ipsec statusall | grep "IKEv2 SPI" | grep conn${i}
		@{ipsec_status}=	Split String		${stdout}

		${initiator_IKEv2_SPI}= 		Get From List		${ipsec_status}		3
		${responder_IKEv2_SPI}= 		Get From List		${ipsec_status}		4
		${rekeying_time}= 		Get From List		${ipsec_status}		-2
		${time_format}=			Get From List		${ipsec_status}		-1
		Set Suite Variable		${rekeying_time}		${rekeying_time}
		Append To List		${IKE_SPI_InitiatorList_Before_rekeying}		${initiator_IKEv2_SPI}
		Append To List		${IKE_SPI_ResponderList_Before_rekeying}		${responder_IKEv2_SPI}
		Append To List		${IKE_rekeying_time}		${rekeying_time}

		Run Keyword If 		'${time_format}' == 'minutes'		Check IKE Rekeying time on eNB in Seconds		ELSE
        ... Check IKE Rekeying time on eNB in hours
	END
	Set Suite Variable		@{IKE_SPI_InitiatorList_Before_rekeying}		@{IKE_SPI_InitiatorList_Before_rekeying}
	Set Suite Variable		@{IKE_SPI_ResponderList_Before_rekeying}		@{IKE_SPI_ResponderList_Before_rekeying}
	Set Suite Variable		@{IKE_rekeying_time}		@{IKE_rekeying_time}

Check IKE Rekeying time on eNB in Seconds
	${max_val}=     Evaluate    ${sa_lifetime}-${rekey_margin}-${sleep}
	${min_val}=     Evaluate        ${sa_lifetime}-(${rekey_margin}+${rekey_margin}*${rekeyfuzz}/100)-${sleep}
	${rekeying_time}=     Evaluate        ${rekeying_time}*60
	Should Be True		${rekeying_time} > ${min_val}
	Should Be True		${rekeying_time} <= ${max_val} + 60

Check IKE Rekeying time on eNB in hours
	${rekeying_hour_value}=			Evaluate		${sa_lifetime}/3600
	Should Be True		${rekeying_time} == ${rekeying_hour_value}-1

Check for IKE rekeying '${index}'
	@{IKE_SPI_InitiatorList_After_rekeying}=		Create List
	@{IKE_SPI_ResponderList_After_rekeying}=		Create List

	${policy_number}=		Create List		50	60	70
    ${number}=		Get From List		${policy_number}		${index}

	Execute command on ENodeB		ipsec statusall | grep "IKEv2 SPI" | grep conn${number}
	@{ipsec_status}=	Split String		${stdout}
	${rekeying_time}= 		Get From List		${ipsec_status}		-2

	${Sleep_time}=		Evaluate		${rekeying_time}*60
	Sleep		${Sleep_time}
	Sleep		60

	Execute command on ENodeB		ipsec statusall | grep "IKEv2 SPI" | grep conn${number}
	@{ipsec_status}=	Split String		${stdout}
	${initiator_IKEv2_SPI}= 		Get From List		${ipsec_status}		3
	${responder_IKEv2_SPI}= 		Get From List		${ipsec_status}		4

	Should Not Be Equal As Strings		${initiator_IKEv2_SPI}		@{IKE_SPI_InitiatorList_Before_rekeying}[${index}]
	Should Not Be Equal As Strings		${responder_IKEv2_SPI}		@{IKE_SPI_ResponderList_Before_rekeying}[${index}]

Verify PFS DH Algorithm to be same as opted in BTS
	${PFSDHGroupDict}			Create Dictionary	DH2=MODP_1024		DH14=MODP_2048		DH19=ECP_256		DH20=ECP_384
	FOR    ${i}     IN     @{Combination_1_Policy_List}
		${status}=     Run     sudo ipsec statusall | grep conn${i}
    	${ESP_Algorithm_Line}=    Get Line    ${status}   -2
		${PFS_DH_Algorithm_enB}=	Get From Dictionary		${PFSDHGroupDict}		${RandomPFSDHGroup}
		Should Match Regexp 		'${ESP_Algorithm_Line}'		${PFS_DH_Algorithm_enB}
#		@{ESP_Algorithm_List}=	Split String	${ESP_Algorithm_Line}
#		${ESP_Algorithms}=		Get From List	${ESP_Algorithm_List}		1
#		${ESP_Algorithms_Array}=	Split String	${ESP_Algorithms}		/
#		${PFS_DH_Algorithm}=	Get From List	${ESP_Algorithms_Array}		2
#		${PFS_DH_Algorithm_enB}=		Get From Dictionary		${PFSDHGroupDict}		${PFS_DH_Algorithm}
#		Should Be Equal As Strings		${PFS_DH_Algorithm_enB}		${RandomPFSDHGroup}
    END

Change Ipsec conf file in VM to enable PFS
    [Arguments]     ${ESP_value}=${Ipsec_Conf_with_PFS}
	Run 	sudo sed -i 's/esp=.*/${ESP_value}/g' ${SECGW_CONF}
    Run     sudo ipsec restart

Choose GCM/GMAC for IKE and establish tunnel
    [Arguments]     ${Algorithm_PFS_File}   ${PFS_Flag}
    ${RandomGCM}=   Evaluate    random.choice(@{IKE_GCM_List})  random
    ${RandomChossenIkeEncryption}=      Catenate    SEPARATOR=_     ENC         ${RandomGCM}
    ${RandomChossenIkeAuthentication}=      Catenate    SEPARATOR=_     AUTH            ${RandomGCM}
    Set Suite variable      ${RandomChossenIkeAuthentication}    ${RandomChossenIkeAuthentication}
    Set Suite variable      ${RandomChossenIkeEncryption}    ${RandomChossenIkeEncryption}
    ${RandomChossenESPEncryption}=          Evaluate    random.choice(@{ESPEncryptionMethod})   random
    Remove Values From List     ${ESPEncryptionMethod}      ${RandomChossenESPEncryption}
    Set Suite variable      ${RandomChossenESPEncryption}    ${RandomChossenESPEncryption}
    ${RandomChossenESPAuthentication}=      Evaluate    random.choice(@{ESPAuthenticationMethod})   random
    Remove Values From List     ${ESPAuthenticationMethod}      ${RandomChossenESPAuthentication}
    ${RandomChosenDHAlgorithm}=         Evaluate    random.choice(@{IKEDHGroupList})    random
    Remove Values From List     ${IKEDHGroupList}   ${RandomChosenDHAlgorithm}
    Run Keyword If      '${RandomChossenESPEncryption}' == 'ENC_AES_GCM_ICV16_128'      Set Suite Variable       ${RandomChossenESPAuthentication}
    ... AUTH_AES_GCM_ICV16_128
    ...         ELSE IF     '${RandomChossenESPEncryption}' == 'ENC_AES_GCM_ICV16_256'      Set Suite Variable       ${RandomChossenESPAuthentication}
    ... AUTH_AES_GCM_ICV16_256
    ...         ELSE IF     '${RandomChossenESPEncryption}' == 'ENC_AES_GMAC_128'           Set Suite Variable      ${RandomChossenESPAuthentication}
    ... AUTH_AES_GMAC_128
    ...         ELSE IF     '${RandomChossenESPEncryption}' == 'ENC_AES_GMAC_256'           Set Suite Variable      ${RandomChossenESPAuthentication}
    ... AUTH_AES_GMAC_256
    ...         ELSE        Set Suite Variable      ${RandomChossenESPAuthentication}     ${RandomChossenESPAuthentication}

    ${RandomPFSDHGroup}=    Evaluate    random.choice(@{PFSDHGroupList})    random
    Set Suite variable      ${RandomPFSDHGroup}  ${RandomPFSDHGroup}
    Run     cp ${Algorithm_PFS_File} ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenIkeEncryption}}/${RandomChossenIkeEncryption}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenIkeAuthentication}}/${RandomChossenIkeAuthentication}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenESPEncryption}}/${RandomChossenESPEncryption}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenESPAuthentication}}/${RandomChossenESPAuthentication}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChosenDHAlgorithm}}/${RandomChosenDHAlgorithm}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{PFS_Flag}}/${PFS_Flag}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomPFSDHGroup}}/${RandomPFSDHGroup}/g' ${Algorithm_Delta}
    Perform Recommissioning     type=delta      delta_file=${Algorithm_Delta}
    Enable Ipsec on SecureGW
    Enable Ipsec on Admin

Choose GCM/GMAC for ESP and establish tunnel
    [Arguments]     ${Algorithm_File}       ${PFS_Flag}

    ${RandomGCM}=   Evaluate    random.choice(@{ESP_GCM_Method})    random
    ${RandomChossenESPAuthentication}=      Catenate    SEPARATOR=_     AUTH            ${RandomGCM}
    ${RandomChossenESPEncryption}=      Catenate    SEPARATOR=_     ENC         ${RandomGCM}
    Set Suite variable      ${RandomChossenESPAuthentication}    ${RandomChossenESPAuthentication}
    Set Suite variable      ${RandomChossenESPEncryption}    ${RandomChossenESPEncryption}
    ${RandomChossenIkeEncryption}=          Evaluate    random.choice(@{GCM_IKEEncryptionLList})    random
    Remove Values From List     ${IKEEncryptionLList}       ${RandomChossenIkeEncryption}
    ${RandomChossenIkeAuthentication}=      Evaluate    random.choice(@{GCM_IKEAuthnenticationLList})   random
    Remove Values From List     ${IKEAuthnenticationLList}      ${RandomChossenIkeAuthentication}
    Set Suite variable      ${RandomChossenIkeEncryption}    ${RandomChossenIkeEncryption}
    ${RandomChosenDHAlgorithm}=         Evaluate    random.choice(@{IKEDHGroupList})    random
    Remove Values From List     ${IKEDHGroupList}   ${RandomChosenDHAlgorithm}
    ${RandomPFSDHGroup}=    Evaluate    random.choice(@{PFSDHGroupList})    random
    Set Suite variable      ${RandomPFSDHGroup}  ${RandomPFSDHGroup}
    Run Keyword If      '${RandomChossenIkeEncryption}' == 'ENC_AES_GCM_ICV16_128'      Set Suite Variable       ${RandomChossenIkeAuthentication}
    ... AUTH_AES_GCM_ICV16_128
    ...         ELSE IF     '${RandomChossenIkeEncryption}' == 'ENC_AES_GCM_ICV16_256'          Set Suite Variable
    ... ${RandomChossenIkeAuthentication}       AUTH_AES_GCM_ICV16_256
    ...         ELSE        Set Suite Variable      ${RandomChossenIkeAuthentication}     ${RandomChossenIkeAuthentication}

    Run     cp ${Algorithm_File} ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenIkeEncryption}}/${RandomChossenIkeEncryption}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenIkeAuthentication}}/${RandomChossenIkeAuthentication}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenESPEncryption}}/${RandomChossenESPEncryption}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenESPAuthentication}}/${RandomChossenESPAuthentication}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChosenDHAlgorithm}}/${RandomChosenDHAlgorithm}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{PFS_Flag}}/${PFS_Flag}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomPFSDHGroup}}/${RandomPFSDHGroup}/g' ${Algorithm_Delta}
    Perform Recommissioning     type=delta      delta_file=${Algorithm_Delta}
    Enable Ipsec on SecureGW
    Enable Ipsec on Admin


