*** Settings ***
Documentation
...		[Author]     			"Pranitha"
...		[Maintenance]			"TRS I & V Tools Bangalore Team"
...		[Config]				"SA+NSA+LTE Dual uplane Ransharing with IPSEC Configuration"
...		[Date] 					"****"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]					"QC_ID in Test Lab for reporting"
...		[Feature_ID] 			"CB007158"
...		[Funtion_Hash_Tags] 	"Dual_Uplane"
...		[Validated_TestLine] 	"KVM08_TRSIV_TL0004"
...     [Validation_status]     "Validated"
...		[Procedure]   			"Configure with SA+NSA Dual uplane, IPSEC Configuration"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
#Resource	    ${CURDIR}/resources/SR002750_common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Test Cases ***
[1]CB007158-B Configure dual U-plane addresses with Backup_Ipsec Single operator
	Perform Recommissioning        type=delta     delta_file=${Scf_Ipsec_7158}     timeout=300
	Sleep  180
	Restore all Certificate
	Install ipsec certificate
	Sleep  100
	Check Dpd alarms
	Sleep   60
	Call Setup      5g=${profile}:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep    120
	Verify NG link Status for Dual Stack 6 Operator
	Check ipsec tunnel status
	Make primary tunnels down and verify tunnel status
	Verify Dpd and ipsec switchover Alarm
	Make SA Call and Verify for 6 Operator with ipsec      ipV4
	Restore primary tunnels and verify tunnel status

*** Keywords ***
Restore all Certificate
	certificate configure          operation=restore_vendor_certificate
	Sleep   10
	certificate configure          operation=delete_cert        all_certs=${True}
	Sleep   10

Install ipsec certificate
	Certificate Configure    operation=install_certificate     cert_file=${Cert_file}    cert_type=${BtsTrustChain}
	...     cert_format=${cert_format}	password=${Cert_Password}
	Sleep   80

Check Dpd alarms
	Verify Alarm		faultid=${faultid_dpd}		should_exist=${False}

Check ipsec tunnel status
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


Make primary tunnels down and verify tunnel status
	Run     sudo ip link set dev eth3.${vlan} down
	Run	sudo ip addr del ${ip_v4} brd ${brd} dev eth3.${vlan}
	Run     sudo ip addr del ${ip_v6} dev eth3.${vlan}
    Run     sudo ip link del link eth3 name eth3.${vlan} type vlan id ${vlan}

	Run     sudo ip link set dev eth3.${vlan_ipv6} down
	Run     sudo ip addr del ${ip} brd ${brd_v6} dev eth3.${vlan_ipv6}
	Run     sudo ip addr del ${ipv6} dev eth3.${vlan_ipv6}
	Run     sudo ip link del link eth3 name eth3.${vlan_ipv6} type vlan id ${vlan_ipv6}

	Run Keyword and Ignore Error  	Check ipsec tunnel status

Verify Dpd and ipsec switchover Alarm
	Wait Until Keyword Succeeds    1 min    30 		Verify Alarm		faultid=${faultid_dpd}
	Wait Until Keyword Succeeds    5 min    30 		Verify Alarm		faultid=${faultid_switchover}
	...	occurrences=4

Restore primary tunnels and verify tunnel status
	Run      sudo ip link add link eth3 name eth3.${vlan} type vlan id ${vlan}
	Run      sudo ip addr add ${ip_v4} brd ${brd} dev eth3.${vlan}
	Run      sudo ip link set dev eth3.${vlan} up

	Run      sudo ip link add link eth3 name eth3.${vlan_ipv6} type vlan id ${vlan_ipv6}
	Run      sudo ip addr add ${ip} brd ${brd_v6} dev eth3.${vlan_ipv6}
	Run      sudo ip link set dev eth3.${vlan_ipv6} up

	Run      sudo ip addr add ${ip_v6} dev eth3.${vlan}
	Run      sudo ip addr add ${ipv6} dev eth3.${vlan_ipv6}

	Wait Until Keyword Succeeds    5 min    30      Verify Alarm	faultid=${faultid_dpd}   should_exist=${False}
	Sleep 	 300
	Check ipsec tunnel status

Make SA Call and Verify for 6 Operator with ipsec
	[Arguments]      ${IP_Version}
	Sleep  30
	FOR  ${operator}   IN RANGE   1   7
         ${operator_str}= 	Convert To String	${operator}
		 Set Suite Variable      ${operator}        ${operator}
	     Set Suite Variable      ${operator_str}        ${operator_str}
	     Run Keyword If   '${IP_Version}' == 'ipV6'    set suite variable     ${AMF}    6
	     ...     ELSE      set suite variable     ${AMF}    0
	     ${served_amf}=    	Evaluate       ${operator}+${AMF}
	 	 Traffic capture start           capture_device=l2_wireshark 		alias=slice_${operator_str}_${IP_Version}
         Traffic Capture Start	capture_device=oam_device	mode=file	 measurement_point=NE_Terminated
         ...	  uplane_capturing=True	    alias=point_A_${operator_str}_${IP_Version}
#	     Attach UE with operator specific qci and send ul dl traffic      ${operator}      ${profile}
#	     Stop traffic and detach UE          ${operator}      ${profile}
	  	 ${pcap_file}=       Traffic capture stop	  alias=slice_${operator_str}_${IP_Version}
         ${pcap_file}=       Traffic Capture Stop    mode=file   alias=point_A_${operator_str}_${IP_Version}
#	     Get AMF IP Address      ${served_amf}
#	     Get NG-U IP Address     ${operator}           ${IP_Version}
	     ${ip_len}=      Evaluate      1000*${operator}
	     Analyse Pcap        pcap_filename=${pcap_file}        analysis=SA_call_ul_${IP_Version}
	     ...	filter_file_name=${traffic_filter_file_name}
	     Analyse Pcap        pcap_filename=${pcap_file}        analysis=SA_call_dl_${IP_Version}
	     ...	filter_file_name=${traffic_filter_file_name}
         Sleep    30
    END

Verify NG link Status for Dual Stack 6 Operator
	FOR   ${operator}   IN RANGE   1   13
	      ${operator_str}=	   Convert To String	    ${operator}
          ${NG_status}=       Query Admin Infomodel    query=get object ${amf_moc_path}-${operator_str}
		  ${ng_link_status}=     Get From Dictionary     dictionary=${NG_status}      key=ngLinkStatus
          Should Be Equal		${ng_link_status}		Active
    END

Keyword to Run at end
    Run     sudo killall edaemon egate
