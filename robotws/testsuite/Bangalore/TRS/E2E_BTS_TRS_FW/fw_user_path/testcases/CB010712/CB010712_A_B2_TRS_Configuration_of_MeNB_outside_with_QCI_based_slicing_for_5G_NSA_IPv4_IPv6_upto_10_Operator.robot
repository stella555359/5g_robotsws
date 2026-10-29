*** Settings ***
Documentation
...		[Author]     		        "Shreya C"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "20:05:2024"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB010712, CB006450"
...     [Validated_TestLine]        "KVM80-TRSIV-TL001"
...		[Procedure]   		        "CB010712_A_B2_TRS_Configuration_of_MeNB_outside_with_QCI_based_slicing_for_5G_NSA_IPv4_IPv6_upto_10_Operator"
...     [Precondition]              "ASOF hardware is required with Airphone"
...     [Config_Comments]           "TRS_Configuration_of_MeNB_outside_with_QCI_based_slicing_for_5G_NSA_IPv4_IPv6_upto_10_Operator"
...     [Function_Hash_Tags]        "NSA 10 Operator RAN Sharing, QCI Based Slicing"


Resource        ${CURDIR}/resources/CB010712_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Variables **
${profile}         MeNB_inside_NSA_Slice
${routes}          ${CURDIR}/resources/asof_qci_nsa_slice.sh
***Test Cases***
[1]CB010712_A_B2_TRS_Configuration_of_MeNB_outside_with_QCI_based_slicing_for_5G_NSA_IPv4_IPv6_upto_10_Operator
    Add Interfaces on VM
	Perform Commissioning       scf_file=${Configuration_scf_ASOF_basic}   verify_bts_status=False     timeout=480    alias=default
    Sleep       180
    Perform Recommissioning     type=delta    delta_file=${Configuration_delta_NSA_QCI_Slice_10OP}      timeout=300
    Sleep       180
	Get IP Address
    Verify NGAP and S1AP Messages
	Verify NG link Status      20
	Verify S1 link Status      2
	Set UE Capabilities for NSA UEs       2001   2020
    Trigger and Verify Random NSA Slice Call
    [TEARDOWN]    Keyword to Run at end

*** Keywords ***
Set UE Capabilities for NSA UEs
	[Arguments]        ${start_ue}=1    ${end_ue}=1
	${eutra_cap_cmd}=     Catenate    ue_param id=${start_ue}..${end_ue} ue_eutra_capabilities=${ue_eutra_cap}
	Configure UE       lte=${profile}:data  command=${eutra_cap_cmd}
	${ne_cap_cmd}=     Catenate    ue_param id=${start_ue}..${end_ue} ue_nr_capabilities=${ue_nr_cap}
	Configure UE       lte=${profile}:data  command=${ne_cap_cmd}
	${eutra_nr_cap_cmd}=     Catenate    ue_param id=${start_ue}..${end_ue} ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
	Configure UE       lte=${profile}:data  command=${eutra_nr_cap_cmd}

Trigger and Verify Random NSA Slice Call
	${slice_list}=    Evaluate    random.sample(range(1, 20), 4)    random
	FOR  ${slice}  IN   @{slice_list}
	    ${ue_id}=     Evaluate     2000+${slice}
	    Get NSA Slice Parameters     ${slice}
	    ${cell_id}=   Set Variable If    1<=${slice}<=8    11
	    ...     9<=${slice}<=14       12
		...     15<=${slice}<=20      13
	    ${nr_cell}=   Set Variable If    1<=${slice}<=12    50
	    ...     13<=${slice}<=20       51
		${sgw_id}=   Set Variable If    1<=${slice}<=10    1
	    ...     11<=${slice}<=20       2
		Traffic capture start           capture_device=l2_wireshark 		alias=slice_${slice}_call
	    Attach NSA UE with dedicated bearer and send ul dl traffic for slice call   ${ue_id}    ${plmn}   ${sgw_id}   ${cell_id}  ${qci}  ${nr_cell}
	    Detach NSA UE     ${ue_id}
	    ${pcap_file}=       Traffic capture stop	  alias=slice_${slice}_call
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=qci_modification       filter_file_name=${traffic_filter_file_name}
	    Run Keyword If     ${sgw_id}==2       Verify IPv6 NSA Slice Traffic    ${pcap_file}    ${s1uplane_ipv6}   ${qci}
		...     ELSE       Verify IPv4 NSA Slice Traffic       ${pcap_file}    ${s1uplane_ipv4}    ${qci}
    END
    [TEARDOWN]       Run Keyword and Ignore Error       Traffic capture stop	  alias=slice_${slice}_call

Verify IPv4 NSA Slice Traffic
    [Arguments]        ${pcap_file}     ${s1uplane_ipv4}   ${qci}
	Set Suite Variable      ${s1uplane}     ${s1uplane_ipv4}
	Set Suite Variable      ${qci}     ${qci}
	Analyse Pcap        pcap_filename=${pcap_file}        analysis=nsa_call_ul_ipV4       filter_file_name=${traffic_filter_file_name}

Verify IPv6 NSA Slice Traffic
    [Arguments]        ${pcap_file}     ${s1uplane_ipv6}   ${qci}
	Set Suite Variable      ${s1uplane}     ${s1uplane_ipv6}
	Set Suite Variable      ${qci}     ${qci}
	Analyse Pcap        pcap_filename=${pcap_file}        analysis=nsa_call_ul_ipV6       filter_file_name=${traffic_filter_file_name}

Get NSA Slice Parameters
	[Arguments]        ${slice}
	${nrnwlice_dict}=      Query Admin Infomodel    query=get object //NRNWSLICE_NSA_A-${slice}
	${qci_list}=     Get From Dictionary     dictionary=${nrnwlice_dict}      key=operatorSpecificQCIList
	${qci}=     Get From List    ${qci_list}      0
	${s1uplane_dict}=     Get From Dictionary     dictionary=${nrnwlice_dict}      key=s1Uplane
	${s1uplane_moc}=   Get From Dictionary     dictionary=${s1uplane_dict}      key=ipV4AddressDN1
    ${s1uplane_ipif}=   Query Admin Infomodel     query=get object ${s1uplane_moc}
    ${s1uplane_ipv4}=    Get From Dictionary      ${s1uplane_ipif}      localIpAddr
	${s1uplane_moc}=   Get From Dictionary     dictionary=${s1uplane_dict}      key=ipV6AddressDN1
    ${s1uplane_ipif}=   Query Admin Infomodel     query=get object ${s1uplane_moc}
    ${s1uplane_ipv6}=    Get From Dictionary      ${s1uplane_ipif}      localIpAddr
	${PLMN_DN}=       Get From Dictionary     dictionary=${nrnwlice_dict}      key=nrPlmnDN
	Get PLMN details      ${PLMN_DN}
	Set Suite Variable       ${s1uplane_ipv4}     ${s1uplane_ipv4}
    Set Suite Variable       ${s1uplane_ipv6}     ${s1uplane_ipv6}
    Set Suite Variable       ${qci}     ${qci}

Get PLMN details
    [Arguments]        ${PLMN_DN}
	${plmn_moc}=   Query Admin Infomodel     query=get object ${PLMN_DN}
	${mcc}=    Get From Dictionary      ${plmn_moc}      mcc
	${mnc}=    Get From Dictionary      ${plmn_moc}      mnc
	${plmn} =   Catenate       ${mcc}:${mnc}
	Set Suite Variable       ${plmn}   ${plmn}

Get IP Address
	Get MME IP Address       2
	Get AMF IP Address       20
	Get NG-C IP Address      10
	Get LTE-C IP Address      1

Add Interfaces on VM
	Delete Interfaces
	Run     sh ${routes}

Verify NGAP and S1AP Messages
	Verify Alarm     faultid=7305   severity=critical     should_exist=True    occurrences=20
	Verify Alarm     faultid=6202   should_exist=True    occurrences=2
    Traffic capture start           capture_device=l2_wireshark 		alias=ngap_s1ap
	Call Setup      lte=${profile}:data   	parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep    240
    ${pcap_file}=       Traffic capture stop	  alias=ngap_s1ap
    Verify NGAP Messages      ${pcap_file}   20
    Verify S1AP Messages	  ${pcap_file}   2
	Verify Alarm     faultid=7305   should_exist=${False}
	Verify Alarm     faultid=6202   should_exist=${False}
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
	    ${lte_cplane_ip}=	Get from List     ${LTE_C_IP_List}       ${operator}
		${mme_ip}=		Get from List     ${MME_IP_List}       ${operator}
	    Get IP Version      ${mme_ip}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=s1ap_setup_${version}         filter_file_name=${traffic_filter_file_name}
		Analyse Pcap        pcap_filename=${pcap_file}        analysis=s1ap_response_${version}      filter_file_name=${traffic_filter_file_name}
    END

Keyword to Run at end
    Run     sudo killall edaemon egate
	Delete Interfaces