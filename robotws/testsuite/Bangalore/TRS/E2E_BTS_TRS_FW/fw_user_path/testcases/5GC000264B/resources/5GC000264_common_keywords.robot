*** Settings ***
Documentation
Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot
Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot

***Keywords***
Verify Ipsec tunnels
	Get Mplane Tunnel Endpoints
	Get UCplane Tunnel Endpoints

Get Mplane IP
	${mplane_local_DN}=		Get Parameter		param_path=MPLANENW-1:mPlaneIpv4AddressDN
	${Mplane_IP}=		Get Parameter		param_path=${mplane_local_DN}:localIpAddr
	Set Suite Variable		${Mplane_IP}

Verify Current Mplane DSCP value from wireshark
	Get Mplane Tunnel Endpoints
	${dscp_value}=		Get Parameter		param_path=MPLANENW-1:mPlaneDscp
    Should Be Equal As Integers  ${dscp_value}  34
	Analyse Pcap	pcap_filename=${Wireshark_file}		analysis=Verify_MPLANE_DSCP

Verify Current Mplane DSCP value from wireshark after mod
    Get Mplane Tunnel Endpoints
    ${dscp_value}=      Get Parameter       param_path=MPLANENW-1:mPlaneDscp
    Analyse Pcap    pcap_filename=${Wireshark_file}     analysis=Verify_MPLANE_DSCP

Modify Mplane dscp value
	[Arguments]		${mplane_dscp_value}
	Perform Recommissioning		type=param		param_path=MPLANENW-1:mPlaneDscp	operation=update	value=${mplane_dscp_value}		timeout=120
	Sleep	30
	Check mPlaneDscp value		${mplane_dscp_value}

Check mPlaneDscp value
	[Arguments]		${mplane_dscp_value}
	${dscp_value}=		Get Parameter		param_path=MPLANENW-1:mPlaneDscp
	Should Be Equal		${mplane_dscp_value}		${dscp_value}

Verify Current IKE DSCP value from wireshark
	Get Mplane Tunnel Endpoints
	${dscp_value}=		Get Parameter		param_path=IPSECC-1:ikeDscp
    Should Be Equal As Integers  ${dscp_value}  46
	Analyse Pcap	pcap_filename=${Wireshark_file}		analysis=Verify_IKE_DSCP

Verify Current IKE DSCP value from wireshark after mod
    Get Mplane Tunnel Endpoints
    ${dscp_value}=      Get Parameter       param_path=IPSECC-1:ikeDscp
    Analyse Pcap    pcap_filename=${Wireshark_file}     analysis=Verify_IKE_DSCP

Modify IKE dscp value
	[Arguments]		${ike_dscp_value}
	Perform Recommissioning		type=param		param_path=IPSECC-1:ikeDscp			operation=update	value=${ike_dscp_value}		timeout=120
	Sleep	30
	Check ikeDscp value		${ike_dscp_value}

Check ikeDscp value
	[Arguments]		${ike_dscp_value}
	${dscp_value}=		Get Parameter		param_path=IPSECC-1:ikeDscp
	Should Be Equal		${ike_dscp_value}		${dscp_value}

Verify IPSEC Security Association on eNB
	[Arguments]		${policy}=${Ipsec_policy}		${Enb_IP}=192.168.255.129
	FOR	${i}	IN		@{policy}
    		Execute command on ENodeB		ipsec status | grep conn${i}		${Enb_IP}
			Should Match Regexp		${stdout}	.*ESTABLISHED.*
			Should Match Regexp		${stdout}	.*INSTALLED.*
    END

Analyse IKE & Mplane Dscp value
	Traffic Capture Start	capture_device=bts		alias=dscp_L2_pcap
    Verify IPSEC Security Association on eNB    Enb_IP=${Mplane_IP}
    Sleep    60
	${Wireshark_file}=		Traffic Capture Stop	alias=dscp_L2_pcap
	Set Suite variable		${Wireshark_file}
	Verify Current Mplane DSCP value from wireshark after mod
    Verify Current IKE DSCP value from wireshark after mod

Get Mplane Tunnel Endpoints
	${mplane_local_DN}=		Get Parameter		param_path=IKEP-1:localTunnelEndpointDN
	${Local_IP}=		Get Parameter		param_path=${mplane_local_DN}:localIpAddr
	${Remote_IP}=	Get Parameter		param_path=IKEP-1:remoteTunnelEndpoint
	${status}=		Run Keyword And Return Status	Should Contain		${Local_IP}		:
	${IP_type}=		Set Variable If		${status}	ipv6	ip
	Set Suite Variable		${Local_IP}
	Set Suite Variable		${Remote_IP}
	Set Suite Variable		${IP_type}

Get UCplane Tunnel Endpoints
	${UCplane_local_DN}=	Get Parameter		param_path=IKEP-2:localTunnelEndpointDN
	${Local_IP}=	Get Parameter		param_path=${UCplane_local_DN}:localIpAddr
	${Remote_IP}=	Get Parameter		param_path=IKEP-2:remoteTunnelEndpoint
	${status}=		Run Keyword And Return Status	Should Contain		${Local_IP}		:
	${IP_type}=		Set Variable If		${status}	ipv6	ip
	Set Suite Variable		${Local_IP}
	Set Suite Variable		${Remote_IP}
	Set Suite Variable		${IP_type}

Keywords To Run At End
	Run Keyword And Ignore Error	Traffic Capture Stop	alias=Ipsec_L2_pcap
	Run Keyword And Ignore Error	Traffic Capture Stop	alias=dscp_L2_pcap
#	Run Keyword And Expect Error	AdminApiProcedureFailureException*		Perform Recommissioning		type=param
#    ...    param_path=IPSECC-1:ipSecEnabled	operation=update	value=false		timeout=200
