*** Settings ***
Documentation
...		[Author]     		        "Nupur"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "15:10:2022"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB006557"
...     [Validated_TestLine]        "KVM87-TRSIV-TL001"
...		[Procedure]   		        "SR002750_TRS_Commissioning_SgNB_with_Dual_Stack_for_all_the_RATs"
...     [Precondition]              "ASIM + ABIO with Airphone hardware is required"
...     [Config_Comments]           "Maximum IP and VLAN Configuration"
...     [Function_Hash_Tags]        "SA 6 Operator RAN Sharing, Dual Stack, verify 6 operator call with Airphone"

Resource        ${CURDIR}/resources/CB010712_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Variables ***
${profile}          Single_IP_LTE_NR_v6
${routes}           ${CURDIR}/resources/asim_single_ipv6.sh
***Test Cases***
[1]TRS_Commissioning SgNB with single IP for all the RATs_IPv6_SR002750
    Add Interfaces on VM
    Perform Commissioning       scf_file=${Configuration_3791_scf_basic}   verify_bts_status=False     timeout=600
    Sleep    240
    Perform Recommissioning     type=delta    delta_file=${Configuration_delta_Single_IP_LTE_NR_v6}      timeout=300
    Sleep   150
    Get IP Address
    Verify NGAP and S1AP Messages
    Verify NG link Status      10
    Verify S1 link Status
    Trigger and Verify Random Shared IPv6 call with Handover    1   10   3
    [TEARDOWN]    Keyword to Run at end

*** Keywords ***
Add Interfaces on VM
    Delete Interfaces
	Run     sh ${routes}

Verify NGAP and S1AP Messages
    Traffic capture start           capture_device=l2_wireshark 		alias=ngap_s1ap
	Call Setup      5g=${profile}:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep    120
    ${pcap_file}=       Traffic capture stop	  alias=ngap_s1ap
    Verify NGAP Messages      ${pcap_file}   6
    Verify S1AP Messages	  ${pcap_file}
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=ngap_s1ap

Get IP Address
    Get AMF IP Address       10
    Get MME IP Address       1
    Get NG-U IP Address      1
    Get NG-C IP Address      1
    Get LTE-C IP Address     1
    Get NRADJ IP Address     10

Verify NGAP Messages
	[Arguments]        ${pcap_file}    ${operators}=1
	FOR   ${operator}   IN RANGE   0   ${operators}
	    ${ngcplane_ip}=	Get from List     ${NGC_IP_List}       0
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

Make SA Call and Verify for each Operator
	[Arguments]      ${operators}=1

	FOR  ${index}   IN RANGE   0   ${operators}
	    ${operator}=     Evaluate      ${index}+1
	    ${operator_str}=	   Convert To String	    ${operator}
		Traffic capture start           capture_device=l2_wireshark 		alias=slice_${operator_str}
	    Attach UE with operator specific qci and send ul dl traffic      ${operator}      ${profile}
	    Stop traffic and detach UE          ${operator}       ${profile}
	 	${pcap_file}=       Traffic capture stop	  alias=slice_${operator_str}
		${ngcplane_ip}=	Get from List     ${NGC_IP_List}       0
	    ${nguplane_ip}=	Get from List     ${NGU_IP_List}       0
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