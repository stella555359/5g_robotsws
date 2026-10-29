*** Settings ***
Documentation
...		[Author]     		        "Mansi"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "19-10-2023"
...		[Feature_ID] 		        "CB008828"

*** Keywords ***
Verify NG and XN Link Status
	[Arguments]      ${operators}
	${amfs}=     Evaluate      ${operators}*2
	Verify NG link Status      ${amfs}
	Verify Xn link Status      ${operators}

Verify Messages in wireshark for 20 Slices
	[Arguments]      ${pcap_file}    ${operators}
	Get NGC IPv4 Address     ${operators}
    Get NGC IPv6 Address     ${operators}
	Get XNC IPv4 Address     ${operators}
	FOR   ${index}   IN RANGE   0   ${operators}
	      ${ngc_ipv4}=    Get From List    ${NGC_IPv4_List}    ${index}
	      ${xnc_ipv4}=    Get From List    ${XNC_IPv4_List}    ${index}
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngap_20_slices_ipv4
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_xnap_20_slices_ipv4
	END

	FOR   ${index}   IN RANGE   0   ${operators}
	      ${ngc_ipv6}=    Get From List    ${NGC_IPv6_List}    ${index}
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngap_20_slices_ipv6
    END

Verify Messages in wireshark for 2000 Slices
    [Arguments]      ${pcap_file}    ${operators}
	Get NGC IPv4 Address     ${operators}
    Get NGC IPv6 Address     ${operators}
	Get XNC IPv4 Address     ${operators}
	FOR   ${index}   IN RANGE   0   ${operators}
	      ${ngc_ipv4}=    Get From List    ${NGC_IPv4_List}    ${index}
	      ${xnc_ipv4}=    Get From List    ${XNC_IPv4_List}    ${index}
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngap_2000_slices_ipv4
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_xnap_2000_slices_ipv4
	END

	FOR   ${index}   IN RANGE   0   ${operators}
	      ${ngc_ipv6}=    Get From List    ${NGC_IPv6_List}    ${index}
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngap_2000_slices_ipv6
	END

Verify RAN Configuration Update for NG and XN
    [Arguments]      ${pcap_file}    ${operators}
	Get NGC IPv4 Address     ${operators}
    Get NGC IPv6 Address     ${operators}
	Get XNC IPv4 Address     ${operators}
	FOR   ${index}   IN RANGE   0   ${operators}
	      ${ngc_ipv4}=    Get From List    ${NGC_IPv4_List}    ${index}
	      ${xnc_ipv4}=    Get From List    ${XNC_IPv4_List}    ${index}
	      ${ngc_ipv6}=    Get From List    ${NGC_IPv6_List}    ${index}
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngranconfig_update_v4
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngranconfig_update_v6
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngranconfig_update_ack_v4
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngranconfig_update_ack_v6
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_xnranconfig_update_v4
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_xnranconfig_update_ack_v4
	END

Verify No RAN Configuration Update for NG and XN
	[Arguments]      ${pcap_file}    ${operators}
	Get NGC IPv4 Address     ${operators}
    Get NGC IPv6 Address     ${operators}
	Get XNC IPv4 Address     ${operators}
	FOR   ${index}   IN RANGE   0   ${operators}
	      ${ngc_ipv4}=    Get From List    ${NGC_IPv4_List}    ${index}
	      ${xnc_ipv4}=    Get From List    ${XNC_IPv4_List}    ${index}
	      ${ngc_ipv6}=    Get From List    ${NGC_IPv6_List}    ${index}
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngnoranconfig_update_v4
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngnoranconfig_update_v6
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngnoranconfig_update_ack_v4
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_ngnoranconfig_update_ack_v6
          Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_xnnoranconfig_update_v4
	      Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_xnnoranconfig_update_ack_v4
	END

Get NGC IPv4 Address
    [Arguments]      ${operators}
	${nrbts_dict} =    Query Admin Infomodel    query=get list ${nrbts_path}
	${ngcplane_dict}=    Get From Dictionary    dictionary=${nrbts_dict}[0]    key=ngCplane
	FOR   ${index}   IN RANGE   0   ${operators}
	  	   ${ngcplane_v4}=    Get From Dictionary    dictionary=${ngcplane_dict}[${index}]    key=ipV4AddressDN1
	      ${ngc_ipv4}=		Query Admin Infomodel    query=get param ${ngcplane_v4}:localIpAddr
	      Append to List      ${NGC_IPv4_List}      ${ngc_ipv4}
	END

Get NGC IPv6 Address
    [Arguments]      ${operators}
	${nrbts_dict} =    Query Admin Infomodel    query=get list ${nrbts_path}
	${ngcplane_dict}=    Get From Dictionary    dictionary=${nrbts_dict}[0]    key=ngCplane
	FOR   ${index}   IN RANGE   0   ${operators}
	  	  ${ngcplane_v6}=    Get From Dictionary    dictionary=${ngcplane_dict}[${index}]    key=ipV6AddressDN1
	      ${ngc_ipv6}=		Query Admin Infomodel    query=get param ${ngcplane_v6}:localIpAddr
	      Append to List      ${NGC_IPv6_List}      ${ngc_ipv6}
	END

Get XNC IPv4 Address
    [Arguments]      ${operators}
	${nrbts_dict} =    Query Admin Infomodel    query=get list ${nrbts_path}
	${xncplane_dict}=    Get From Dictionary    dictionary=${nrbts_dict}[0]    key=xnCplane
    FOR   ${index}   IN RANGE   0   ${operators}
	  	   ${xncplane_v4}=    Get From Dictionary    dictionary=${xncplane_dict}[${index}]    key=ipV4AddressDN1
	      ${xnc_ipv4}=		Query Admin Infomodel    query=get param ${xncplane_v4}:localIpAddr
	      Append to List      ${XNC_IPv4_List}      ${xnc_ipv4}
	END

Get NG and XN IP Address
    ${nrbts_dict} =    Query Admin Infomodel    query=get list ${nrbts_path}
	${ngcplane_dict}=    Get From Dictionary    dictionary=${nrbts_dict}[0]    key=ngCplane
	${ngcplane_v4}=    Get From Dictionary    dictionary=${ngcplane_dict}[0]    key=ipV4AddressDN1
	${ngc_ipv4}=		Query Admin Infomodel    query=get param ${ngcplane_v4}:localIpAddr
	${ngcplane_v6}=    Get From Dictionary    dictionary=${ngcplane_dict}[0]    key=ipV6AddressDN1
	${ngc_ipv6}=		Query Admin Infomodel    query=get param ${ngcplane_v6}:localIpAddr

	${nguplane_dict}=    Get From Dictionary    dictionary=${nrbts_dict}[0]    key=ngUplane
	${nguplane_v4}=    Get From Dictionary    dictionary=${nguplane_dict}[0]    key=ipV4AddressDN1
	${ngu_ipv4}=		Query Admin Infomodel    query=get param ${nguplane_v4}:localIpAddr
	${nguplane_v6}=    Get From Dictionary    dictionary=${nguplane_dict}[0]    key=ipV6AddressDN1
	${ngu_ipv6}=		Query Admin Infomodel    query=get param ${nguplane_v6}:localIpAddr

	${xncplane_dict}=    Get From Dictionary    dictionary=${nrbts_dict}[0]    key=xnCplane
	${xncplane_v4}=    Get From Dictionary    dictionary=${xncplane_dict}[0]    key=ipV4AddressDN1
	${xnc_ipv4}=		Query Admin Infomodel    query=get param ${xncplane_v4}:localIpAddr
	Set Suite Variable     ${ngc_ipv4}   ${ngc_ipv4}
	Set Suite Variable     ${ngc_ipv6}   ${ngc_ipv6}
	Set Suite Variable     ${ngu_ipv4}   ${ngu_ipv4}
	Set Suite Variable     ${ngu_ipv6}   ${ngu_ipv6}
	Set Suite Variable     ${xnc_ipv4}   ${xnc_ipv4}

Verify Supported Slices on AMF
	[Arguments]      ${expected_slices}
    ${amfs}=    Get length    ${expected_slices}
	FOR   ${index}   IN RANGE   0   ${amfs}
	      ${amf}=     Evaluate      ${index}+1
	      ${amf_str}=	   Convert To String	    ${amf}
	      ${snssai_status}=       Query Admin Infomodel    query=get object ${amf_moc_path}-${amf_str}
	      ${snssai_count}=     Get From Dictionary     dictionary=${snssai_status}      key=snssaiAMFList
	      ${count}=    Get length    ${snssai_count}
          Should be Equal     ${count}    ${expected_slices}[${index}]
    END

Verify Extended Slices on AMF
	[Arguments]      ${expected_slices}
    ${amfs}=    Get length    ${expected_slices}
	FOR   ${index}   IN RANGE   0   ${amfs}
	      ${amf}=     Evaluate      ${index}+1
	      ${amf_str}=	   Convert To String	    ${amf}
	      ${snssai_status}=       Query Admin Infomodel    query=get object ${amf_moc_path}-${amf_str}
	      ${snssai_count}=     Get From Dictionary     dictionary=${snssai_status}      key=extendedSnssaiAMFList
	      ${count}=    Get length    ${snssai_count}
          Should be Equal     ${count}    ${expected_slices}[${index}]
    END

Verify NG link Status
	[Arguments]          ${amfs}=1
	${index}=     Evaluate      ${amfs}+1
	FOR   ${amf}   IN RANGE   1   ${index}
	      ${amf_str}=	   Convert To String	    ${amf}
	      ${NG_status}=       Query Admin Infomodel    query=get object ${amf_moc_path}-${amf_str}
		  ${ng_link_status}=     Get From Dictionary     dictionary=${NG_status}      key=ngLinkStatus
          Should Be Equal		${ng_link_status}		Active
    END

Verify Xn link Status
	[Arguments]          ${nradjs}=1
	${index}=     Evaluate      ${nradjs}+1
	FOR   ${nradj}   IN RANGE   1   ${index}
	      ${nradj_str}=	   Convert To String	    ${nradj}
	      ${Xn_status}=      Query Admin Infomodel    query=get object ${Xn_link_path}-${nradj_str}
          ${Xn_link_status}=       Get From Dictionary     ${Xn_status}      xnLinkStatus
          Should Be Equal    ${Xn_link_status}      available
    END

Add and Verify NRTRS Profile for 2000 Network Slices
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface
	...    uplane_capturing=${True}    timeout=120   alias=point_B_2000
    Perform Recommissioning   type=delta    delta_file=${add_NRTRS_Profile_2000}     timeout=600
	Sleep    120
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_2000
	Verify NG and XN Link Status		1
	Verify All Network Slice Status
	Verify No RAN Configuration Update for NG and XN      ${Point_B_Capture}		1

Select Random Slices for Calls
	${slice_list}=    Evaluate    random.sample(range(1, 2000), 3)    random
	Set Suite Variable      ${slice_list}     ${slice_list}

Enable and Verify 2000 Network Slices without NRTRS Profile
	Traffic capture start           capture_device=vm_eth3_interface 		alias=point_B_2000
    Perform Recommissioning   type=delta    delta_file=${add_2000_slices_without_NRTRS}     timeout=600
	Sleep    120
    ${Point_B_Capture}=   Traffic capture stop	  alias=point_B_2000
	Verify NG and XN Link Status		1
	Verify All Network Slice Status
	Verify RAN Configuration Update for NG and XN    ${Point_B_Capture}		1

Verify Random Network Slice Status
	[Arguments]          ${start_slice}    ${end_slice}      ${expected_status}=enabled
	${slice_list}=    Evaluate    random.sample(range(${start_slice}, ${end_slice}), 19)    random
	FOR     ${slice}    IN    @{slice_list}
	     ${slice_str}=     Convert To String	    ${slice}
	     ${slice_status}=        Query Admin Infomodel       query=get object ${snssai_moc_path}-${slice_str}
         ${status}=      Get From Dictionary     dictionary=${slice_status}      key=operationalState
         Should Be Equal     ${status}       ${expected_status}
    END

Verify Network Slice Status
    [Arguments]          ${start_slice}=1    ${end_slice}=1      ${slice_status}=enabled
	${Slice_status_list}=        Query Admin Infomodel       query=get list //SNSSAI_R-*
	${start_index}=     Evaluate      ${start_slice}-1
	FOR     ${slice}    IN RANGE    ${start_index}   ${end_slice}
	     ${Slice_status_moc}=       Get From List       ${Slice_status_list}     ${slice}
	     ${status}=      Get From Dictionary     dictionary=${Slice_status_moc}      key=operationalState
         Should Be Equal     ${status}       ${slice_status}
    END

Add NRTRS Profiles for Enabled Slices
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=${True}
	...    timeout=120   alias=point_B_nrtrs
    Perform Recommissioning   type=delta    delta_file=${add_NRTRS_profile}     timeout=600
	Sleep    60
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_nrtrs
	Verify NG and XN Link Status		1
	Verify All Network Slice Status
	Verify No RAN Configuration Update for NG and XN    ${Point_B_Capture}		1

Perform and Verify Random Slice Calls without NRTRS Profile
	[Arguments]         ${slice_list}
	Perform Recommissioning   type=delta    delta_file=${enable_IPv4_AMF}      timeout=120
	Sleep   60
	Perform and Verify IPv4 Slice call without NRTRS Profile     ${slice_list}

	Perform Recommissioning   type=delta    delta_file=${enable_IPv6_AMF}      timeout=120
	Sleep   60
	Perform and Verify IPv6 Slice call without NRTRS Profile     ${slice_list}
	Perform Recommissioning   type=delta    delta_file=${enable_IPv4_IPv6_AMF}      timeout=120

Perform and Verify IPv4 Slice call without NRTRS Profile
    [Arguments]		${slice_list}
	${len}=    Get Length    ${slice_list}
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated    uplane_capturing=${True}
	...    timeout=120   alias=point_A_IPv4
	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
        ${slice}=    Convert To String	    ${ue_id}
        Attach UE and Send UL DL Traffic     ${ue_id}
	    Trigger Handover for UE	       ${ue_id}
	    Detach UE and Stop Traffic    ${ue_id}
    END
    ${Point_A_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_A_IPv4
	Get NG and XN IP Address

	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
	    Get Slice Differentiator     ${ue_id}
	    Get NGU IP from Slice       ${ue_id}
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_pdu_request_with_sd_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_ul_slice_call_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_dl_slice_call_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_handover_request_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_handover_ack_v4
	END

Perform and Verify IPv6 Slice call without NRTRS Profile
	[Arguments]		${slice_list}
	${len}=    Get Length    ${slice_list}
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated    uplane_capturing=${True}
	...    timeout=120   alias=point_A_IPv6
	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
        ${slice}=    Convert To String	    ${ue_id}
        Attach UE and Send UL DL Traffic     ${ue_id}      1000
	    Detach UE and Stop Traffic    ${ue_id}
	END
    ${Point_A_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_A_IPv6
	Get NG and XN IP Address

	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
	    Get Slice Differentiator     ${ue_id}
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_pdu_request_with_sd_v6
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_ul_slice_call_v6
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_dl_slice_call_v6
	END

Perform and Verify Random Slice Calls with NRTRS Profile
	[Arguments]         ${slice_list}
	Perform Recommissioning   type=delta    delta_file=${enable_IPv4_AMF}      timeout=120
	Sleep   60
	Perform and Verify IPv4 Slice call with NRTRS Profile     ${slice_list}

	Perform Recommissioning   type=delta    delta_file=${enable_IPv6_AMF}      timeout=120
	Sleep   60
	Perform and Verify IPv6 Slice call with NRTRS Profile     ${slice_list}
	Perform Recommissioning   type=delta    delta_file=${enable_IPv4_IPv6_AMF}      timeout=120

Perform and Verify IPv4 Slice call with NRTRS Profile
	[Arguments]		${slice_list}
	${len}=    Get Length    ${slice_list}
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated    uplane_capturing=${True}
	...    timeout=120   alias=point_A_nrtrs_IPv4
	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
        ${slice}=    Convert To String	    ${ue_id}
        Attach UE and Send UL DL Traffic     ${ue_id}
	    Trigger Handover for UE	       ${ue_id}
	    Detach UE and Stop Traffic    ${ue_id}
	END
    ${Point_A_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_A_nrtrs_IPv4
	Get NG and XN IP Address

	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
	    Get Slice Differentiator     ${ue_id}
	    Get NGU IP from Slice       ${ue_id}
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_pdu_request_with_sd_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_ul_slice_call_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_dl_slice_call_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_handover_request_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_handover_ack_v4
	END

Perform and Verify IPv6 Slice call with NRTRS Profile
	[Arguments]		${slice_list}
	${len}=    Get Length    ${slice_list}
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated    uplane_capturing=${True}
	...    timeout=120   alias=point_A_nrtrs_IPv6
	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
        ${slice}=    Convert To String	    ${ue_id}
        Attach UE and Send UL DL Traffic     ${ue_id}      1000
	    Detach UE and Stop Traffic    ${ue_id}
	END
    ${Point_A_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_A_nrtrs_IPv6
	Get NG and XN IP Address

	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
	    Get Slice Differentiator     ${ue_id}
        Get NGU IP from Slice       ${ue_id}
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_pdu_request_with_sd_v6
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_ul_slice_call_v6
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_dl_slice_call_v6
	END

Verify All Network Slice Status
    [Arguments]         ${slice_status}=enabled
	${Slice_status_list}=        Query Admin Infomodel       query=get list //SNSSAI_R-*
	FOR     ${slice}    IN  @{Slice_status_list}
	     ${status}=      Get From Dictionary     dictionary=${slice}      key=operationalState
         Should Be Equal     ${status}       ${slice_status}
    END

Verify IPSEC Status
    [Arguments]      ${IKEP_State}
    ${ikep_list}=    Query Admin Infomodel    query=get list //IKEP_R-1   timeout=30
    FOR   ${item}  IN  @{ikep_list}
        ${state}=    Get From Dictionary   ${item}    ikePeerState
        Should be Equal   ${state}    ${IKEP_State}
    END

Perform and Verify Random Calls with XN Handover
	Perform Recommissioning   type=delta    delta_file=${enable_IPv4_AMF}      timeout=60
	Sleep   60
	${slice_list}=    Evaluate    random.sample(range(1, 2000), 6)    random
	Perform and Verify IPv4 Slice call with Handover     ${slice_list}

    Perform Recommissioning   type=delta    delta_file=${enable_IPv6_AMF}      timeout=60
	Sleep   60
	${slice_list}=    Evaluate    random.sample(range(1, 2000), 6)    random
	Perform and Verify IPv6 Slice call with Handover    ${slice_list}
	Perform Recommissioning   type=delta    delta_file=${enable_IPv4_IPv6_AMF}      timeout=120

Generate Random Slices for Ransharing
	@{slice_list}=    Create List
	${slice_id}=		Evaluate	random.choice(range(1, 500))  random
	Append to List      ${slice_list}      ${slice_id}
	${slice_id}=		Evaluate	random.choice(range(501, 800))  random
	Append to List      ${slice_list}      ${slice_id}
	${slice_id}=		Evaluate	random.choice(range(801, 1100))  random
	Append to List      ${slice_list}      ${slice_id}
	${slice_id}=		Evaluate	random.choice(range(1101, 1400))  random
	Append to List      ${slice_list}      ${slice_id}
	${slice_id}=		Evaluate	random.choice(range(1401, 1700))  random
	Append to List      ${slice_list}      ${slice_id}
	${slice_id}=		Evaluate	random.choice(range(1701, 2000))  random
	Append to List      ${slice_list}      ${slice_id}
	Set Suite Variable      ${slice_list}     ${slice_list}

Perform and Verify Random Calls with Ransharing
	Perform Recommissioning   type=delta    delta_file=${enable_IPv4_ransharing_AMF}      timeout=120
	Sleep   60
	Generate Random Slices for Ransharing
	Perform and Verify IPv4 Slice call for Ransharing      ${slice_list}
	Perform Recommissioning   type=delta    delta_file=${enable_IPv6_ransharing_AMF}      timeout=120
	Sleep   60
	Generate Random Slices for Ransharing
	Perform and Verify IPv6 Slice call for Ransharing      ${slice_list}

Perform and Verify IPv4 Slice call for Ransharing
	[Arguments]		${slice_list}
	${len}=    Get Length    ${slice_list}
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface    uplane_capturing=${True}
	...    timeout=120   alias=point_B_IPv4
	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
        ${slice}=    Convert To String	    ${ue_id}
        Attach UE and Send UL DL Traffic     ${ue_id}
	    Detach UE and Stop Traffic    ${ue_id}
	END
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_IPv4

	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
	    Get Slice Differentiator     ${ue_id}
	    Get NGU IP from Slice       ${ue_id}
	    ${ngc_ipv4}=     Get from List     ${NGC_IPv4_List}   ${index}
        Analyse Pcap        pcap_filename=${Point_B_Capture}        analysis=verify_pdu_request_with_sd_v4
	    Analyse Pcap        pcap_filename=${Point_B_Capture}        analysis=verify_ul_slice_call_v4
	    Analyse Pcap        pcap_filename=${Point_B_Capture}        analysis=verify_dl_slice_call_v4
	END

Perform and Verify IPv6 Slice call for Ransharing
	[Arguments]		${slice_list}
	${len}=    Get Length    ${slice_list}
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface    uplane_capturing=${True}
	...    timeout=120   alias=point_B_IPv6
	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
        ${slice}=    Convert To String	    ${ue_id}
        Attach UE and Send UL DL Traffic     ${ue_id}     1000
	    Detach UE and Stop Traffic    ${ue_id}
	END
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_IPv6

	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
	    Get Slice Differentiator     ${ue_id}
	    Get NGU IP from Slice       ${ue_id}
	    ${ngc_ipv6}=     Get from List     ${NGC_IPv6_List}   ${index}
        Analyse Pcap        pcap_filename=${Point_B_Capture}        analysis=verify_pdu_request_with_sd_v6
	    Analyse Pcap        pcap_filename=${Point_B_Capture}        analysis=verify_ul_slice_call_v6
	    Analyse Pcap        pcap_filename=${Point_B_Capture}        analysis=verify_dl_slice_call_v6
	    Sleep   30
	END

Perform and Verify IPv4 Slice call with Handover
    [Arguments]		${slice_list}
	${len}=    Get Length    ${slice_list}
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated    uplane_capturing=${True}
	...    timeout=120   alias=point_A_IPv4
	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
        ${slice}=    Convert To String	    ${ue_id}
        Attach UE and Send UL DL Traffic     ${ue_id}
	    Trigger Handover for UE	       ${ue_id}
	    Detach UE and Stop Traffic    ${ue_id}
	END
    ${Point_A_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_A_IPv4
	Get NG and XN IP Address

	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
	    Get Slice Differentiator     ${ue_id}
	    Get NGU IP from Slice       ${ue_id}
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_pdu_request_with_sd_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_ul_slice_call_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_dl_slice_call_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_handover_request_v4
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_handover_ack_v4
	END

Attach UE and Send UL DL Traffic
	[Arguments]		${ue_id}       ${size}=1438
	Configure UE    5g=${call_profile}:data    command=set_pdu_param      ue=${ue_id}     pdu=1   trf_type=internal
	Sleep   5
    Configure UE    5g=${call_profile}:data    command=ue_register    id=${ue_id}    profile=1
    Sleep   2
    Configure UE    5g=${call_profile}:data    command=ue_pdu_session_setup       pdu=1   gw=1    ue=${ue_id}     nwslice=${ue_id}
    Sleep   3
    Configure UE    5g=${call_profile}:data    command=trf_data_start     ue=${ue_id}     pdu=1   qfi=1   dir=dl  trf_id=1
    ...    mbps=175   packets=2000   size=${size}
	Sleep   3
    Configure UE    5g=${call_profile}:data    command=trf_data_start     ue=${ue_id}     pdu=1   qfi=1   dir=ul  trf_id=1
    ...    mbps=175   packets=2000   size=${size}
	Sleep   15

Trigger Handover for UE
	[Arguments]		${ue_id}
	Configure UE    5g=${call_profile}:data    command=ue_measurement_send_nr     id=${ue_id}    meas_id=1    event=A3
	...    srsrp_nr=1   srsrq_nr=11   phycell_id=52   nrsrp_nr=60   nrsrq_nr=60
	Sleep   15

Detach UE and Stop Traffic
	[Arguments]		${ue_id}
	Configure UE    5g=${call_profile}:data    command=ue_pdu_session_release  ue=${ue_id}    pdu=1
    Sleep   30
    Configure UE    5g=${call_profile}:data    command=ue_deregister   id=${ue_id}    ue_deregister_type=switch_off

Perform and Verify IPv6 Slice call with Handover
	[Arguments]		${slice_list}
	${len}=    Get Length    ${slice_list}
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated    uplane_capturing=${True}
	...    timeout=120   alias=point_A_IPv6
	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
        ${slice}=    Convert To String	    ${ue_id}
        Attach UE and Send UL DL Traffic     ${ue_id}       1000
	    Detach UE and Stop Traffic    ${ue_id}
	END
    ${Point_A_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_A_IPv6
	Get NG and XN IP Address

	FOR   ${index}   IN RANGE   0   ${len}
	    ${ue_id}=      Get from List     ${slice_list}   ${index}
	    Get Slice Differentiator     ${ue_id}
	    Get NGU IP from Slice       ${ue_id}
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_pdu_request_with_sd_v6
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_ul_slice_call_v6
	    Analyse Pcap        pcap_filename=${Point_A_Capture}        analysis=verify_dl_slice_call_v6
	END

Get Slice Differentiator
	[Arguments]		${slice}
    ${slice_status_moc}=        Query Admin Infomodel      query=get object ${snssai_path}-${slice}
	${slice_diff}=      Get From Dictionary     dictionary=${slice_status_moc}      key=sd
	Set Suite Variable     ${slice_diff}   ${slice_diff}

Get NGU IP from Slice
	[Arguments]		${slice}
    ${slice_status_moc}=        Query Admin Infomodel      query=get object ${snssai_path}-${slice}
	${trs_profile_dn}=      Get From Dictionary     dictionary=${slice_status_moc}      key=trsProfileDN
	${trs_profile}=        Query Admin Infomodel      query=get object ${trs_profile_dn}
	${nguplane_dn}=      Get From Dictionary     dictionary=${trs_profile}      key=ngUplane
	${ipv4_dn}=      Get From Dictionary     dictionary=${nguplane_dn}      key=ipV4AddressDN1
	${ipv6_dn}=      Get From Dictionary     dictionary=${nguplane_dn}      key=ipV6AddressDN1
	${ngu_ipv4}=		Query Admin Infomodel    query=get param ${ipv4_dn}:localIpAddr
	${ngu_ipv6}=		Query Admin Infomodel    query=get param ${ipv6_dn}:localIpAddr
	Set Suite Variable     ${ngu_ipv4}   ${ngu_ipv4}
	Set Suite Variable     ${ngu_ipv6}   ${ngu_ipv6}

Add 2000 Network Slices on AMF and verify
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=${True}
	...    timeout=120   alias=point_B_AMF
	Configure UE    5g=${call_profile}:data    command=amf_config_update    id=1    plmn_list=311:489    starting_snssai=0x01:0xD143A5
	...    number_of_slices=1024 slice_support_list=true plmn_list=311:489 starting_snssai=0x01:0xD147A5
	...    number_of_slices=976 slice_support_list=false
	Sleep       30
	Configure UE    5g=${call_profile}:data    command=amf_config_update    id=2    plmn_list=311:489    starting_snssai=0x01:0xD143A5
	...    number_of_slices=1024 slice_support_list=true plmn_list=311:489 starting_snssai=0x01:0xD147A5
	...    number_of_slices=976 slice_support_list=false
	Sleep       30
	${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_AMF
	Get NG and XN IP Address
	Analyse Pcap        pcap_filename=${Point_B_Capture}        analysis=verify_amf_config_update_ipv4
	Analyse Pcap        pcap_filename=${Point_B_Capture}        analysis=verify_amf_config_update_ack_ipv4
	Analyse Pcap        pcap_filename=${Point_B_Capture}        analysis=verify_amf_config_update_ipv6
	Analyse Pcap        pcap_filename=${Point_B_Capture}        analysis=verify_amf_config_update_ack_ipv6

Modify Tracking Area and Verify Slices
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=${True}
	...    timeout=120   alias=point_B_tracking_area
	Perform Recommissioning   type=delta    delta_file=${delta_change_trackingarea}     timeout=300
	Sleep     120
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_tracking_area
	Verify RAN Configuration Update for NG and XN    ${Point_B_Capture}		1
	Verify All Network Slice Status

Modify NRTRS Profile in SNSSAI
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=${True}
	...    timeout=120   alias=point_B_NRTRS
	Perform Recommissioning   type=delta    delta_file=${modify_NRTRS_Profile}     timeout=300
	${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_NRTRS
	Verify No RAN Configuration Update for NG and XN      ${Point_B_Capture}		1

Delete NRTRS Profile in SNSSAI
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=${True}
	...    timeout=120   alias=point_B_NRTRS_delete
	Perform Recommissioning   type=delta    delta_file=${delete_NRTRS_Profile}     timeout=300
	${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_NRTRS_delete
	Verify No RAN Configuration Update for NG and XN      ${Point_B_Capture}		1

Verify 1500 Network slices with Onair
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}
	...    timeout=120   alias=point_B_1500
    Call Setup      5g=${call_profile}:data  parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4
    Sleep       200
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_1500
    Verify NG and XN Link Status		1
    Verify Network Slice Status			1     1500    enabled

Enable and Verify 2000 Network Slices
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}
	...    timeout=120   alias=point_B_2000
    Perform Recommissioning   type=delta    delta_file=${delta_500_slice}     timeout=300
	Sleep    120
    ${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_2000
	Verify NG and XN Link Status		1
	Verify Network Slice Status        1     2000    enabled
	Verify RAN Configuration Update for NG and XN    ${Point_B_Capture}		1

Delete Disbled Network Slices and Verify
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}
	...    timeout=120   alias=point_B_delta_delete
	Perform Recommissioning   type=delta    delta_file=${delete_disabled_slices}     timeout=300
    Sleep       120
	${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_delta_delete
    Verify Network Slice Status        1     1800    enabled
	Verify No RAN Configuration Update for NG and XN    ${Point_B_Capture}		1

Lock 1900 Network Slices and Verify
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}
	...    timeout=120   alias=point_B_locked
	Perform Recommissioning   type=delta    delta_file=${lock_1900_slices}     timeout=300
    Sleep   120
	${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_locked
	Verify RAN Configuration Update for NG and XN    ${Point_B_Capture}		1
	Verify Random Network Slice Status      ${lock_start_slice}      ${lock_end_slice}       disabled

Unlock 1900 Network Slices and Verify
	Traffic capture start           capture_device=vm_eth3_interface 		alias=point_B_unlocked
	Perform Recommissioning   type=delta    delta_file=${unlock_1900_slices}     timeout=300
	Sleep   120
	${Point_B_Capture}=   Traffic capture stop	  alias=point_B_unlocked
	Verify RAN Configuration Update for NG and XN    ${Point_B_Capture}		1
	Verify All Network Slice Status

Delete 100 Enabled Slices and Verify
	Traffic Capture Start   capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=${True}
	...    timeout=120   alias=point_B_delete
	Perform Recommissioning   type=delta    delta_file=${delete_300_slices}     timeout=300
	Sleep   120
	${Point_B_Capture}=   Traffic Capture Stop      mode=file       timeout=120     alias=point_B_delete
	Verify RAN Configuration Update for NG and XN    ${Point_B_Capture}		1
	Verify All Network Slice Status
