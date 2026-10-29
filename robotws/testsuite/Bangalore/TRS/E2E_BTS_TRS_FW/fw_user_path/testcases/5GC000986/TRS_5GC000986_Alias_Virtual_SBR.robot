*** Settings ***
Documentation
    ...     [Procedure]             "The test case is to verify Fast IP re routing with Virtual and Alias along with
    ...                              source based routing Configurations"
    ...     [Date]                  "27-05-21"
    ...     [Author]                "Shivani Patil"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "FIPR","BFD"
    ...     [Feature_ID]            "5GC000986"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "420"
	...     [Config]    			"gNB should configured Alias IP configuration and Virtual IP configuration"



Variables         ta_e2e_bts_trs_fw
Resource         ${CURDIR}/../resources/Common_BFD.robot
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
TRS_5GC000986_Verification_of_FIPR_Virtual, Alias and SBR Configurations
	[Documentation]		This test case verify FIPR with Alias and Virtual IP configuration
	Verify FIPR with Alais IP configuration
    Verify FIPR with Virtual IP configuration
	[Teardown]	Run Keyword and Ignore Error		Terminate Testcase

*** Keywords ***

Verify FIPR with Alais IP configuration
	 Perform Commissioning 	 scf_file=${scf_alias_configuration} 	 timeout=600		verify_bts_status=False  	timeout=300
  	 Sleep   900
	 Read BFD Details
	 Get Primary and Secondary BFDs from SBR
	 Configure Switch	device=l2switch		command_profile=add_alias_routes
 	 Verify Fast IP Rerouting
	 [Teardown]	Run Keyword and Ignore Error		Configure Switch	device=l2switch		command_profile=del_alias_routes

Verify FIPR with virtual IP configuration
	 Perform Commissioning 	 scf_file=${scf_virtual_configuration} 	 timeout=600		verify_bts_status=False  	timeout=300      alias=default
	 Sleep   900
	 Read BFD Details
	 Get Primary and Secondary BFDs from SBR
	 Configure Switch	device=l2switch		command_profile=add_virtual_routes
     Verify Fast IP Rerouting
	 [Teardown]	Run Keyword and Ignore Error		Configure Switch	device=l2switch		command_profile=del_virtual_routes

Read BFD Details
    GetBFDCount
    Get_BFD_Src_IPs
	GetTriggerCount
	GetTriggerIds

Terminate Testcase
	Run Keyword And Ignore Error	Bring Up Primary Session
	Run Keyword And Ignore Error	Bring Up Secondary Session
	Run Keyword And Ignore Error	Stop ping

Validation Of All Trigger Status
	 FOR    ${temp}    IN     @{triggerids_list}
        GetTriggerDetails	${temp}
	  	GetTriggerStatus	${temp}
	  	Should be Equal		${triggerStatus}	${TRUE}
	 END

Get Primary and Secondary BFDs from SBR
   ${iprt_dict} = 	Query Admin Infomodel		query=get object ${rtpol_moc_path}
   ${routingPolicies_list}=	Get From Dictionary	${iprt_dict} 	key=routingPolicies
   ${routingPolicies_list_len}=		Get Length		${routingPolicies_list}

   FOR 	${item}	IN RANGE	0	${routingPolicies_list_len}
   	 ${routingPolicies_list_item}=	Get From List	${routingPolicies_list}	${item}
   	 ${routingTableDN}=	Get From Dictionary	${routingPolicies_list_item} 	key=routingTableDN
   	 ${srcIpAddress}=	Get From Dictionary	${routingPolicies_list_item} 	key=srcIpAddress
   	 ${orderNumber}=	Get From Dictionary	${routingPolicies_list_item} 	key=orderNumber
   	 Set Suite Variable     ${routingTableDN}
   	 Set Suite Variable     ${srcIpAddress}
   	 Set Suite Variable     ${orderNumber}
   	 Get routig table details
   	 Run Keyword If     '${orderNumber}'== '1'    update routing polocy as primary
   	 Run Keyword If     '${orderNumber}'== '2'    update routing polocy as secondary
   END



Get routig table details
   ${iprt_dict} = 	Query Admin Infomodel		query=get object ${routingTableDN}
   ${route_list}=	Get From Dictionary	${iprt_dict} 	key=staticRoutes
   ${route_list_len}=		Get Length		${route_list}

   FOR 	${item}	IN RANGE	0	${route_list_len}
   	 ${route_list_item}=	Get From List	${route_list}	${item}
   	 ${dest_ip}=	Get From Dictionary	${route_list_item} 	key=destIpAddr
   	 ${gw_ip}=	Get From Dictionary	${route_list_item} 	key=gateway
   	 ${trigger_dn}=	Get From Dictionary	${route_list_item} 	key=triggerDN
   	 ${preSrcIpv4Addr}=	Get From Dictionary	${route_list_item} 	key=preSrcIpv4Addr
   	 @{trigger_list}=         Split String From Right     string=${trigger_dn}	    separator=-
   	 ${trigger_id}=         Set Variable        @{trigger_list}[-1]
   	 GetTriggerDetails      ${trigger_id}
   	 Set Suite variable      ${triggerbfdindex_${item}}      ${triggerbfdindex}
     GetBFDIndex
   	 GetBFDDetails  			${bfdIndex}
   	 GetVlanID
   	 Set Suite Variable     ${dest_ip}
   	 Set Suite Variable     ${gw_ip}
   	 Set Suite Variable     ${trigger_dn}
     Set Suite Variable     ${vlanid_${item}}           ${vlanid}
   	 Set Suite Variable     ${preSrcIpv4Addr_${item}}        ${preSrcIpv4Addr}
   	 Set Suite Variable     ${trigger_id}
   END


update routing polocy as primary
   ${primary_trigger_id}=          Set Variable        ${trigger_id}
   ${primary_bfd_id}=          Set Variable        ${triggerbfdindex_0}
   ${primary_bfd_remote_ip}=          Set Variable        ${bfdDestIpAddr}
   ${primary_bfd_source_ip}=          Set Variable        ${bfdSrcIpAddr}
   ${primary_vlanId}=          Set Variable        ${vlanid_0}
   Set Suite Variable      ${primary_trigger_id}
   Set Suite Variable      ${primary_bfd_id}
   Set Suite Variable      ${primary_bfd_remote_ip}
   Set Suite Variable      ${primary_bfd_source_ip}
   Set Suite Variable      ${primary_vlanId}

update routing polocy as secondary
   ${secondary_trigger_id}=          Set Variable        ${trigger_id}
   ${secondary_bfd_id}=          Set Variable        ${triggerbfdindex_1}
   ${secondary_bfd_remote_ip}=          Set Variable        ${bfdDestIpAddr}
   ${secondary_bfd_source_ip}=          Set Variable        ${bfdSrcIpAddr}
   ${secondary_vlanId}=          Set Variable        ${vlanid_1}
   Set Suite Variable      ${secondary_trigger_id}
   Set Suite Variable      ${secondary_bfd_id}
   Set Suite Variable      ${secondary_bfd_remote_ip}
   Set Suite Variable      ${secondary_bfd_source_ip}
   Set Suite Variable      ${secondary_vlanId}

Start Ping Test with source IP
    [Arguments]     ${source_ip}
	Run     python sbr_ping_test.py ${source_ip} ${dest_ip}



Add souce and target ips to wireshark list
    [Arguments]     ${source_ip}
    ${l2_capture_filter_bfdSrcAddr_ips}=	Set Variable	${l2_capture_filter_bfdSrcAddr_ips} or host ${source_ip}
	${l2_capture_filter_bfdSrcAddr_ips}=	Set Variable	${l2_capture_filter_bfdSrcAddr_ips} or host ${dest_ip}
	Set Suite Variable       ${l2_capture_filter_bfdSrcAddr_ips}

verify packets on primary
	Traffic Capture Start    capture_device=l2_wireshark    alias=primary4_path
	sleep 		5
	${pcap_name}=	Traffic Capture Stop		alias=primary4_path
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=primaryv4_path_remote_ip_echo    filter_file_name=${traffic_filer_file_name}
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=primaryv4_path_remote_ip_reply    filter_file_name=${traffic_filer_file_name}
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=no_secondaryv4_path_remote_ip   filter_file_name=${traffic_filer_file_name}
	[Teardown]		Run Keyword And Ignore Error	Traffic Capture Stop		alias=primary4_path

verify packets on secondary
	Traffic Capture Start    capture_device=l2_wireshark    alias=secondary4_path
	sleep 		5
	${pcap_name}=	Traffic Capture Stop		alias=secondary4_path
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=secondaryv4_path_remote_ip_echo    filter_file_name=${traffic_filer_file_name}
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=secondaryv4_path_remote_ip_reply    filter_file_name=${traffic_filer_file_name}
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=no_primaryv4_path_remote_ip   filter_file_name=${traffic_filer_file_name}
	[Teardown]		Run Keyword And Ignore Error	Traffic Capture Stop		alias=secondary4_path

Verify Fast IP Rerouting
	Start Ping Test with source IP      ${preSrcIpv4Addr_0}
	Validation Of All Trigger Status
	Add souce and target ips to wireshark list      ${preSrcIpv4Addr_0}
	verify packets on primary
	Bring Down Primary Session
	Sleep 		5
    Stop ping
    Start Ping Test with source IP      ${preSrcIpv4Addr_1}
	verify packets on secondary
    Stop ping
	Bring Up Primary Session
    Start Ping Test with source IP      ${preSrcIpv4Addr_0}
	sleep 		5
	verify packets on primary
	Bring Down Secondary Session
	sleep 		5
	verify packets on primary
    Stop ping
    Start Ping Test with source IP      ${preSrcIpv4Addr_0}
	Bring Up Secondary Session
	sleep 		5
	verify packets on primary
	Stop ping
	Verify success rate
    [Teardown]      Run Keyword And Ignore Error        Stop ping
