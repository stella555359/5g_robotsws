*** Settings ***
Documentation
...		[Author]     		        "Nupur"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "15:11:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB006557"
...     [Validated_TestLine]        "KVM87-TRSIV-TL001"
...		[Procedure]   		        "SR002750_TRS_Commissioning_SgNB_with_Dual_Stack_for_all_the_RATs"
...     [Precondition]              "ASIM + ABIO with Airphone hardware is required"
...     [Config_Comments]           "Maximum IP and VLAN Configuration"
...     [Function_Hash_Tags]        "SA 6 Operator RAN Sharing, Dedicated VLAN, verify 6 operator call with Airphone"

Resource        ${CURDIR}/resources/CB010712_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Variables ***
${profile}          Dedicated_Vlan_LTE_NR_HO_IPv4
${routes}           ${CURDIR}/resources/asim_dedicated_vlan.sh
***Test Cases***
[1][1.0] TRS_SR002750_Commissioning_SgNB_with_Dedicated_VLAN_of_NG-U_and_NG-C_Ips_and_Dedicated_VLAN_of_Xn-U_and_Xn-C_Ips_for_each_Operator_IPv4_IPv6
    Add Interfaces on VM
	Perform Commissioning       scf_file=${Configuration_3791_scf_basic}   verify_bts_status=False     timeout=600
    Sleep    240
    Perform Recommissioning     type=delta    delta_file=${Configuration_delta_Dedicated_VLAN_v4}      timeout=300
    Sleep   150
    Get IP Address
    Verify NGAP and XNAP Messages
	Verify NG link Status      10
	Verify Xn link Status      10
	Verify S1 link Status
    Trigger and Verify Random IPv4 call with Handover    1   10   3
	Run  	sudo killall edaemon egate
    Perform IPv6 Configuration for AMF and MME
	Verify NGAP and XNAP Messages
	Verify NG link Status      10
	Verify S1 link Status
    Verify Xn link Status      10
    Trigger and Verify Random IPv6 call with Handover   1   10   3
    [TEARDOWN]    Keyword to Run at end


*** Keywords ***
Add Interfaces on VM
    Delete Interfaces
	Run     sh ${routes}

Get IP Address
    Get AMF IP Address       10
    Get NG-U IP Address      10
    Get NG-C IP Address      10
    Get NRADJ IP Address     10

Perform IPv6 Configuration for AMF and MME
	Perform Recommissioning		type=delta	  delta_file=${Delta_IPv6_MME_AMF}      timeout=300
	Reset      operation=reset_bts             should_be_onair=False
	Sleep    360
	Perform Recommissioning		type=delta	  delta_file=${Delta_IPv6_XN}      timeout=300
	Set Suite Variable      ${profile}     Dedicated_Vlan_LTE_NR_HO_IPv6
	Delete IP List Address
	Get IP Address

Verify NGAP and XNAP Messages
    Traffic capture start           capture_device=l2_wireshark 		alias=ngap_s1ap
	Call Setup      5g=${profile}:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep    120
    ${pcap_file}=       Traffic capture stop	  alias=ngap_s1ap
    Verify NGAP Messages      ${pcap_file}   10
	Verify XnAP Messages      ${pcap_file}   10
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=ngap_s1ap

Verify NGAP Messages
	[Arguments]        ${pcap_file}    ${operators}=1
	FOR   ${operator}   IN RANGE   0   ${operators}
	    ${ngcplane_ip}=	Get from List     ${NGC_IP_List}       ${operator}
		${amf_ip}=		Get from List     ${AMF_IP_List}       ${operator}
	    Get IP Version      ${amf_ip}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=ngap_setup_${version}         filter_file_name=${traffic_filter_file_name}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=ngap_response_${version}      filter_file_name=${traffic_filter_file_name}
    END

Verify S1AP Messages
	[Arguments]        ${pcap_file}    ${operators}=1
	FOR   ${operator}   IN RANGE   0   ${operators}
	    ${lte_cplane_ip}=	Get from List     ${LTE_C_IP_List}       0
		${mme_ip}=		Get from List     ${MME_IP_List}       0
	    Get IP Version      ${mme_ip}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=s1ap_setup_${version}         filter_file_name=${traffic_filter_file_name}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=s1ap_response_${version}      filter_file_name=${traffic_filter_file_name}
    END

Verify XnAP Messages
	[Arguments]        ${pcap_file}    ${operators}=1
	FOR   ${operator}   IN RANGE   0   ${operators}
	    ${nradj_cplane_ip}=	Get from List     ${NRADJ_C_IP_List}        ${operator}
		${ngcplane_ip}=	Get from List     ${NGC_IP_List}       ${operator}
	    Get IP Version      ${ngcplane_ip}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=xnap_setup_${version}         filter_file_name=${traffic_filter_file_name}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=xnap_response_${version}      filter_file_name=${traffic_filter_file_name}
    END

Make SA Call and Verify for each Operator
	[Arguments]      ${operators}=1

	FOR  ${index}   IN RANGE   0   ${operators}
	    ${operator}=     Evaluate      ${index}+1
	    ${operator_str}=	   Convert To String	    ${operator}
		Traffic capture start           capture_device=l2_wireshark 		alias=slice_${operator_str}
	    Attach UE with operator specific qci and send ul dl traffic      ${operator}      ${profile}
	    Stop traffic and detach UE          ${operator}       ${profile}
	 	${pcap_file}=       Traffic capture stop	  alias=slice_${operator_str}
		${ngcplane_ip}=	Get from List     ${NGC_IP_List}      ${index}
	    ${nguplane_ip}=	Get from List     ${NGU_IP_List}      ${index}
	    ${amf_ip}=		Get from List     ${AMF_IP_List}       ${index}
	    Get IP Version      ${amf_ip}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_ue_attach_${version}    filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_pdu_${version}          filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_ul_${version}      filter_file_name=${traffic_filter_file_name}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_dl_${version}      filter_file_name=${traffic_filter_file_name}
	    Sleep    30
    END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=slice_${operator_str}

Keyword to Run at end
    Run     sudo killall edaemon egate
	Delete Interfaces