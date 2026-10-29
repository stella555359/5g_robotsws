*** Settings ***
Documentation
...		[Author]     		        "Shankar Kumar"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "15:09:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB009019"
...     [Validated_TestLine]        "KVM65-TRSIV-TL003_ASIM"
...		[Procedure]   		        "CB009019_TCP MSS_CB009019"
...     [Precondition]              "ASIM Combo hardware is required"
...     [Config]    	            "CRLH-1 param should be configured in SCF"
...     [Function_Hash_Tags]        "ECDSA, RSA, Certificates, CMP Configuration"


Variables       ta_e2e_bts_trs_fw
Library         Process
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB009019_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Test Cases ***
[1]TRS_Disabling and Online modification of TCP MSS Clamping for User Plane traffic IPv4_IPv6 for gNB (SA)_CB009019_ASIB
    Add Vlan Interface on Vm
    Add Simulated Ips
    Perform Recommissioning        type=delta     delta_file=${TCP_MSS}      skip_parameter_relation_errors=${True}
    ...     timeout=600     alias=default
    Run wgate and Check bts for onair
    Make SA call and verify MSS value
    Call Teardown   5g=device3:data
    Run     sudo killall edaemon egate
    Make NSA call and verify MSS value
    Call Teardown   lte=device4:data
    Check iperf process and killall
    Run     sudo killall edaemon egate
    Change MSS value and verify it
    Run wgate and Check bts for onair
    Check iperf process and killall
    Block Cell      rat=nr
    Sleep    120
    Unblock Cell    rat=nr
    Sleep    120
    Make SA call and verify MSS changed value
    Check iperf process and killall
    Run     sudo killall edaemon egate
    [TEARDOWN]    Keyword to Run at end

*** Keywords ***
Run wgate and Check bts for onair
    Traffic capture start           capture_device=vm_eth3_interface 		alias=ngap_s1ap
    Block Cell  	rat=nr
    Sleep	 120
    Unblock Cell    rat=nr
    Call Setup      5g=device3:data   parallel=${False}    verify_attach=${False}   attach=${False}   timeout=300
    Sleep    120
    ${pcap_file}=       Traffic capture stop	  alias=ngap_s1ap
    Verify NGAP Messages      ${pcap_file}
    Verify S1AP Messages      ${pcap_file}
    Sleep    60
    Verify Alarm     faultid=${fault_id}   should_exist=${False}
    Sleep    60
	Wait Until Keyword Succeeds	10 min	30 sec	Verify Bts Status 	should_be_onair=${True}


Enable TCP MSS flag for 5g
	Perform Recommissioning        type=delta	  delta_file=${9019_delta_tcpmss_clamping}  skip_parameter_relation_errors=${True}
	...	timeout=300
	Sleep  	60

Attach UE with operator specific qci and send ul dl traffic with iperf
    [Arguments]          ${operator}
	Attach UE with operator specific qci and send ul dl traffic
	Run Keyword If 		${operator}==1 		Start iperf command for UL and DL
	sleep	100

Start iperf command for UL and DL
	Start iperf server
	Initiate UL traffic & Collect iperf logs
	Initiate DL traffic & Collect iperf logs
	Stop iperf server

Make SA call and verify MSS value
    Traffic capture start           capture_device=vm_eth3_interface        alias=ngap_gtp
    Attach UE with operator specific qci and send ul traffic 	${operator}      ${profile}
    Check iperf process and killall
    Start iperf for server
    Start iperf for client for UL
    sleep  5
    Start iperf for client for DL
    ${pcap_file}=       Traffic capture stop      alias=ngap_gtp
    Verify MSS value for SA
    Stop iperf server

Make NSA call and verify MSS value
    Reset Bts            should_be_onair=${False}
    Execute command on GNB       reboot
    Traffic capture start           capture_device=vm_eth3_interface        alias=ngap_gtp
    Attach UE_NSA
    Check iperf process and killall
    Start iperf for server
    Start iperf for client for UL NSA
    Start iperf for client for DL NSA
    ${pcap_file}=       Traffic capture stop      alias=ngap_gtp
    Verify MSS value for NSA
    Stop iperf server
    [Teardown]  Check iperf process and killall

Make SA call and verify MSS changed value
    Traffic capture start           capture_device=vm_eth3_interface        alias=ngap_gtp_modify
    Attach UE with operator specific qci and send ul traffic	${operator}      ${profile}
    Check iperf process and killall
    ${pcap_file}=       Traffic capture stop      alias=ngap_gtp_modify
    Verify wireshark MSS value changes for SA
    Stop iperf server
