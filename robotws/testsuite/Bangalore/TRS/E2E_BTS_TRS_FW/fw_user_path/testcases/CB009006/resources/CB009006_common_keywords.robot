*** Settings ***
Documentation     [Procedure] "CB009006-CR_Verification_of_Cplane_and_Uplane_DSCP_tagging_vCU_and_vDU"
...               [Date] "Date of creation 01-05-2024"
...               [Author] "Pranitha"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB009006-C"
...               [Funtion_Hash_Tags] "Cloud RAN Troubleshooting"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] VCU/VDU

Resource        ${CURDIR}/../../resources/common_keywords.robot
Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot


*** Keywords ***
Configure remote syslog server and verify
	[Arguments]			${CLOUD}
	Traffic capture start           capture_device=l2_wireshark 		alias=${CLOUD}
	Run Keyword if	${CLOUD}==vDU	Perform Recommissioning    type=delta      delta_file=${CB009006_external_server}
    ...     skip_parameter_relation_errors=${True}		timeout=300     dut=cbts    alias=vdu
	Sleep	30
	Run Keyword if	${CLOUD}==vCU	Perform Recommissioning    type=delta      delta_file=${CB009006_external_server}
    ...     skip_parameter_relation_errors=${True}		timeout=300     dut=cbts    alias=vcu
	Sleep	30
	${pcap_file}=		Traffic capture stop	  alias=${CLOUD}
	set suite variable 		${pcap_file}		${pcap_file}
	Verify external server connection ip with bts
	Verify external server connection role with bts
	Verify external server connection status with bts
	Verify Wireshark
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=${CLOUD}

modify uplane tracing and verify dscp
	[Arguments]			${CLOUD}
	Traffic capture start           capture_device=l2_wireshark 		alias=${CLOUD}
	Call Setup      5g=Profile:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4   timeout=300
	${pcap_file1}=		Traffic capture stop	  alias=${CLOUD}
	Analyse Pcap      pcap_filename=${pcap_file}      analysis=dscp_uplane     filter_file_name=${traffic_filter_file_name}

modify cplane tracing and verify dscp
	[Arguments]			${CLOUD}
	Traffic capture start           capture_device=l2_wireshark 		alias=${CLOUD}
	Call Setup      5g=Profile:data      parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4   timeout=300
	${pcap_file1}=		Traffic capture stop	  alias=${CLOUD}
	Analyse Pcap      pcap_filename=${pcap_file}      analysis=dscp_cplane     filter_file_name=${traffic_filter_file_name}

Verify external server connection ip with bts
    ${ext_server_ip}=       Query Admin Infomodel    query=get object ${trblcadm_path}
    ${ext_link_ip}=     Get From Dictionary     dictionary=${ext_server_ip}      key=ipAddr
    Should Be Equal		${ext_link_ip}		${server_ip}

Verify external server connection role with bts
	${ext_server_role}=       Query Admin Infomodel    query=get object ${trblcadm_path}
    ${ext_link_role}=     Get From Dictionary     dictionary=${ext_server_role}      key=ipAddr
    Should Be Equal		${ext_link_role}		${ACTIVE}

Verify external server connection status with bts
	${ext_server_status}=       Query Admin Infomodel    query=get object ${trblcadm_path}
    ${ext_link_status}=     Get From Dictionary     dictionary=${ext_server_status}      key=ipAddr
    Should Be Equal		${ext_link_status}		${true}

Verify Wireshark
	Analyse Pcap      pcap_filename=${pcap_file}      analysis=ext_attach_request     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap      pcap_filename=${pcap_file}      analysis=ext_attach_response     filter_file_name=${traffic_filter_file_name}
