*** Settings ***
Documentation
...		[Author]     			"Nandini R"
...		[Maintenance]			"TRS I & V Tools Bangalore Team"
...		[Config]				"5G"
...		[Date] 					"10-06-2021"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]					"QC_ID in Test Lab for reporting"
...		[Feature_ID] 			"5GC000264"
...		[Funtion_Hash_Tags] 	"IPSEC"
...		[Validated_TestLine] 	"1-2-UTE5GASIK001"
...     [Validation_status]     "Validated"
...		[Procedure]   			"Configure IPSEC, verify BTS OnAir status. Check current dscp for ike, oam and modify"

Resource		${CURDIR}/resources/5GC000264_common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown        Teardown Oamops

*** Test Cases ***
[1]5GC000264_A_13_ipsec_dscp
#Step1:
    Perform Commissioning       scf_file=${5GC000264_Ipsec_SCF}   verify_bts_status=True     timeout=400
	Sleep   60
	Get Mplane IP
#Step2:
	Traffic Capture Start	capture_device=bts		alias=Ipsec_L2_pcap
	Run Keyword And Ignore Error		Perform Recommissioning		type=param
    ...     param_path=IPSECC-1:ipSecEnabled	operation=update	value=true		timeout=120
	Verify IPSEC Security Association on eNB	Enb_IP=${Mplane_IP}
	${Wireshark_file}=		Traffic Capture Stop	alias=Ipsec_L2_pcap
	Set Suite variable		${Wireshark_file}
	Verify Bts Status
	Verify Ipsec tunnels
	Verify Current Mplane DSCP value from wireshark
    Verify Current IKE DSCP value from wireshark

#step3:
	${new_dscp_mplane}=	Evaluate	random.choice(range(0, 64))		random
	${new_dscp_ike}=	Evaluate	random.choice(range(0, 64))		random
	Modify Mplane dscp value		${new_dscp_mplane}
    Modify IKE dscp value       ${new_dscp_ike}
    Analyse IKE & Mplane Dscp value
	Execute command on ENodeB		reboot
	Sleep	600
	Wait Until Keyword Succeeds		10mins	30sec	Verify Bts Status
	Check mplaneDscp value		${new_dscp_mplane}
    Check ikeDscp value     ${new_dscp_ike}
	[Teardown]		Keywords To Run At End
