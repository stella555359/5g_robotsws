*** Settings ***
Documentation
...            [Author]         "Madhu Chinthakindi"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"


Resource        ${CURDIR}/common_keywords.robot

*** Variables ***
@{bfdObjects_dict_list}
@{bfdAll}
${bfd_a_moc_path}    //BFD_A-
${bfdgrp_a_moc_path}    //BFDGRP_A-
${trigger_moc_path}    //TRIGGER_A-
${trigger_state_moc_path}    //TRIGGER_R-1
${vlan_moc_path}    //VLANIF_A-
${ipif_ipv4_a_moc_path}      //IPIF_A-*/IPADDRESSV4_A-*
${trigger_oam_path}    //TRIGGER_L-*

@{temp2}

*** Keywords ***
GetBFDFirwallChain
   [Documentation]		This keywrod *is to get firewall rules on bts board ${ip} if for ipversion ,${SrcIpAddr} is source ip and ${DestIpAddr}
   ...  destination ip
   [Arguments]      ${ip}      ${SrcIpAddr}        ${DestIpAddr}
   Setup Remote Access	remote_device=bts       alias=firewall
   ${packetCount}=       Run Keyword If             '${rule_type}'=='nftlist'      Remote Command Execute
   ...   command=nft list ruleset | grep -i "${ip} saddr { ${DestIpAddr} } ${ip} daddr { ${SrcIpAddr} }" | awk -F ' ' '{print $16}'
   ...    alias=firewall
   #${packetCount}=       Run Keyword If             '${rule_type}'=='iptables'  and  '${ip}'=='ip'     Remote Command Execute
   #...   command=iptables -nvL BFD_CHAIN  | grep -i  ${DestIpAddr}  | grep -i  ${SrcIpAddr}  | awk -F  '{print $1}'          alias=firewall
   #${packetCount}=       Run Keyword If             '${rule_type}'=='iptables'  and  '${ip}'=='ip6'    Remote Command Execute
   #...   command=ip6tables -nvL BFD_CHAIN  | grep -i  ${DestIpAddr} | grep -i  ${SrcIpAddr}  |  awk -F  '{print $1}'          alias=firewall
   Should Be True       ${packetCount}>0
   [Teardown]    Teardown Remote Access        alias=firewall

GetactFastIpReroutingStatus
   [Documentation]		This keywrod is to get fipr feature flag enable status
   &{actFastIpRerouting} =      Query Admin Infomodel    query=get object ${actFastIpRerouting_status}
   ${actFastIpReroutingStatus}=         Get From Dictionary    dictionary=${actFastIpRerouting}    key=actFastIpRerouting
   Set Suite Variable       ${actFastIpReroutingStatus}

GetTriggerOamIds
	&{dict_tigger_Oam}=    	Create Dictionary
	@{triggerOamObjects_dict_list} =    Query Admin Infomodel   	 query=get list ${trigger_oam_path}
	FOR    ${dict}    IN    @{triggerOamObjects_dict_list}
     	${TriigerOamIDmoc}=    Get From Dictionary    dictionary=${dict}    key=dist_name
    	@{TriigerOamIDmocStripped}=			Split String From Right     string=${TriigerOamIDmoc}     separator=-
    	${TriigerOamID}=			Set Variable     ${TriigerOamIDmocStripped}[-1]
    	${TriigerrealID}=    Get From Dictionary    dictionary=${dict}    key=id
    	${TriigerrealID}=    Convert to String		${TriigerrealID}
     	Set To Dictionary    ${dict_tigger_Oam}    	${TriigerrealID}=${TriigerOamID}
    	Set Suite Variable		${dict_tigger_Oam}		${dict_tigger_Oam}
    # 	Set Suite Variable		${finalTrigerStatus}		${finalTrigerStatus}
    # 	Exit For Loop if     ${finalTriigerID} == ${triggerindexvar}
    END


GetTriggerStatus
   [Documentation]		This keywrod is to get bfd trigger status from board
   [Arguments]      ${triggerindexvar}
   #Setup Remote Access		remote_device=bts     alias=triggerStatus
   ${triggerStatus_old}=        Remote Command Execute
   ...   command=/opt/trs/bin/trs-trigger-d execute showBfdStates | grep "BFD ${triggerindexvar}" | awk '{print $5}'       alias=triggerStatus

   #Run Keyword If       ${triggerStatus_old} == 1      Status True
   #...      ELSE      Status False
   #[Teardown]    Teardown Remote Access            alias=triggerStatus
   GetTriggerOamIds

   ${GetOamTiggerIds}=    Get From Dictionary    dictionary=${dict_tigger_Oam}    key=${triggerindexvar}
   ${GetOamTiggerIds}=    Convert to Integer		${GetOamTiggerIds}
   @{triggerObjects_dict_list} =    Query Admin Infomodel   	 query=get list ${trigger_state_moc_path}
   FOR    ${dict}    IN    @{triggerObjects_dict_list}
    	${TriigerIDmoc}=    Get From Dictionary    dictionary=${dict}    key=dist_name
   	    @{TriigerIDmocStripped}=			Split String From Right     string=${TriigerIDmoc}     separator=/TRIGGER_R-1
   	    @{TriigerID}=			Split String From Right     string=@{TriigerIDmocStripped}[0]     separator=-
   	    ${finalTriigerID}=			Set Variable     @{TriigerID}[-1]
    	${finalTrigerStatus}=    Get From Dictionary    dictionary=${dict}    key=state
   	    ${finalTrigerStatus}=    Convert to String		${finalTrigerStatus}
   #	${result}=		Should Be Equal As Strings    ${finalTrigerStatus}     TRUE
   #	Run Keyword If       ${result} == 'PASS'      Status True
   #	...      ELSE      Status False
   	    Set Suite Variable		${finalTriigerID}		${finalTriigerID}
    	Set Suite Variable		${finalTrigerStatus}		${finalTrigerStatus}
    	Exit For Loop if     ${finalTriigerID} == ${GetOamTiggerIds}
   END


verify trigger state
   [Documentation]		This keywrod is to verify trigger status
   [Arguments]      ${trigger}      ${status}
   GetTriggerStatus	${trigger}
   Should Be Equal As Strings 		    ${finalTrigerStatus}	    ${status}       ignore_case=True

Status True
   ${triggerStatus}=    set variable    ${TRUE}
   Set Suite Variable        ${triggerStatus}
Status False
   ${triggerStatus}=    set variable    ${FALSE}
   Set Suite Variable        ${triggerStatus}
GetTriggerCount
   [Documentation]		This keywrod is to get bfd trigger count
    @{triggerObjects_dict_list} =    Query Admin Infomodel    query=get list ${trigger_moc_path}*
#   *
    ${triggerCount}=    Get Length    ${triggerObjects_dict_list}
    Set Suite Variable     ${triggerCount}

#GetTriggerDetails
#   [Documentation]		This keywrod is to get trigger details.Arg ${triggerindexvar}is the trigger index value which to be verify
#   [Arguments]      ${triggerindexvar}
#   &{triggerObjects_dict} =    Query Admin Infomodel    query=get object ${trigger_moc_path}${triggerindexvar}
#   @{bfdDNListVar}=    Get From Dictionary    dictionary=${triggerObjects_dict}    key=itemList
#   @{bfdDNList}=			Split String From Right		string=${bfdDNListVar}[1]	    separator=,
#   @{bfdDNitems}=			Split String From Right		string=@{bfdDNList}[1]	    separator=:
#   @{bfdDN}=			Split String From Right     string=@{bfdDNitems}[1]     separator=}
#   ${bfdSrcDN}=			Set Variable     @{bfdDN}[0]
#   @{triggerbfdindexList}=			Split String From Right     string=${bfdSrcDN}     separator=BFD_A-
#   ${triggerbfdindex_old}=			Set Variable     @{triggerbfdindexList}[-1]
#   @{triggerbfdindex_old}=			Split String From Right     string=${triggerbfdindex_old}     separator='
#   ${triggerbfdindex}=			Set Variable     @{triggerbfdindex_old}[0]
#   Set Suite Variable       ${bfdSrcDN}
#   Set Suite Variable       ${triggerbfdindex}

GetTriggerDetails
   [Documentation]		This keywrod is to get trigger details.Arg ${triggerindexvar}is the trigger index value which to be verify
   [Arguments]      ${triggerindexvar}
   &{triggerObjects_dict} =    Query Admin Infomodel    query=get object ${trigger_moc_path}${triggerindexvar}
   @{bfdDNListVar}=    Get From Dictionary    dictionary=${triggerObjects_dict}    key=itemList

   #@{bfdDNList}=			Split String From Right		string=${bfdDNListVar}[1]	    separator=,

   #@{bfdDNitems}=			Split String From Right		string=@{bfdDNList}[0]	    separator=:
   #@{bfdDN}=			Split String From Right     string=@{bfdDNitems}[1]     separator=}
   ${bfdDNList}=			Get From Dictionary 		dictionary=${bfdDNListVar}[0]	    key=itemDN

   ${bfdSrcDN}=			Set Variable     ${bfdDNList}
   @{triggerbfdindexList}=			Split String From Right     string=${bfdSrcDN}     separator=BFD_A-
   ${triggerbfdindex_old}=			Set Variable     @{triggerbfdindexList}[-1]
   @{triggerbfdindex_old}=			Split String From Right     string=${triggerbfdindex_old}     separator='
   ${triggerbfdindex}=			Set Variable     @{triggerbfdindex_old}[0]
   Set Suite Variable       ${bfdSrcDN}
   Set Suite Variable       ${triggerbfdindex}

GetBFDCount
   [Documentation]		This keywrod is to get number of bfds configured
    @{bfdObjects_dict_list} =    Query Admin Infomodel    query=get list ${bfd_a_moc_path}*
#   *
    ${BfdCount}=    Get Length    ${bfdObjects_dict_list}
    Set Suite Variable     ${BfdCount}

GetBFDIds
   [Documentation]		This keywrod is to get all  cnfigured bfds ids
    @{bfdindex_list}=   Create List
    FOR    ${bfdindex}    IN RANGE    1    17
       ${output}=         Run Keyword And Return Status     Query Admin Infomodel    query=get object ${bfd_a_moc_path}${bfdindex}
       Run Keyword If     ${output} == True     Append To List	    ${bfdindex_list}    ${bfdindex}
    END
    Set Suite Variable     ${bfdindex_list}

GetTriggerIds
   [Documentation]		This keywrod is to get all  cnfigured trigger ids
    @{triggerids_list}=   Create List
    FOR    ${triggerindexid}    IN RANGE    1    17
       ${output}=         Run Keyword And Return Status     Query Admin Infomodel    query=get object ${trigger_moc_path}${triggerindexid}
       Run Keyword If     ${output} == True     Append To List	    ${triggerids_list}    ${triggerindexid}
    END
    Set Suite Variable     ${triggerids_list}

GetVlanID
   [Documentation]		This keywrod is to get VLAN ID of configured BFD. Arg ${ipAddrDN} is BFD source ip address
   [Arguments]         ${ipAddrDN}=${bfdSrcIpAddrDN}
   @{bfdSrcIpAddrDN_list}=         Split string     string=${ipAddrDN}        separator=/
   ${IPIF}=			Set Variable     @{bfdSrcIpAddrDN_list}[-2]
   ${bfdSrcIpAddrDN_dict} =    Query Admin Infomodel    query=get object //${IPIF}
   ${interfaceDN}=      Get From Dictionary    dictionary=${bfdSrcIpAddrDN_dict}    key=interfaceDN
   @{interfaceDN_list}=         Split string     string=${interfaceDN}        separator=-
   ${vlanid}=			Set Variable     @{interfaceDN_list}[-1]
   @{vlanid_old}=			Split String From Right     string=${vlanid}     separator='
   ${vlanindex}=			Set Variable     @{vlanid_old}[0]
   ${vlanDetail_dict} =    Query Admin Infomodel    query=get object ${vlan_moc_path}${vlanindex}
   ${vlanid}=         Get From Dictionary    dictionary=${vlanDetail_dict}    key=vlanId
   Set Suite Variable       ${vlanid}       ${vlanid}

GetBFDDetails
   [Documentation]		This keywrod is to BFD detais of given BFD id. Arg ${bfdindexvar} is BFD ID to be verify
   [Arguments]         ${bfdindexvar}
   ${bfdObjects_dict} =    Query Admin Infomodel    query=get object ${bfd_a_moc_path}${bfdindexvar}
   ${bfdSrcIpAddrDN}=    Get From Dictionary    dictionary=${bfdObjects_dict}    key=bfdSrcIpAddrDN
   ${bfdSrcIpAddr}=    Get Parameter    param_path=${bfdSrcIpAddrDN}:localIpAddr
   ${bfdDestIpAddr}=    Get From Dictionary    dictionary=${bfdObjects_dict}    key=bfdDestIpAddr
   ${bfdDscp}=    Get From Dictionary    dictionary=${bfdObjects_dict}    key=bfdDscp
   ${bfdSrcUdpPort}=    Get From Dictionary    dictionary=${bfdObjects_dict}    key=bfdSrcUdpPort
   ${bfdActivationStatus}=    Get From Dictionary    dictionary=${bfdObjects_dict}    key=bfdActivation
   ${bfdAdminUpStatus}=    Get From Dictionary    dictionary=${bfdObjects_dict}    key=bfdAdminUp
   ${bfdDetectMult}=    Get From Dictionary    dictionary=${bfdObjects_dict}    key=bfdDetectMult
   ${bfdType}=    Get From Dictionary    dictionary=${bfdObjects_dict}    key=bfdType
   ${desMinTxInt}=    Get From Dictionary    dictionary=${bfdObjects_dict}    key=desMinTxInt
   ${reqMinRxInt}=    Get From Dictionary    dictionary=${bfdObjects_dict}    key=reqMinRxInt
   Set Suite Variable       ${bfdSrcIpAddr}
   Set Suite Variable       ${bfdDestIpAddr}
   Set Suite Variable       ${bfdDscp}
   Set Suite Variable       ${bfdSrcUdpPort}
   Set Suite Variable       ${bfdActivationStatus}
   Set Suite Variable       ${bfdAdminUpStatus}
   Set Suite Variable       ${bfdDetectMult}
   Set Suite Variable       ${bfdType}
   Set Suite Variable       ${desMinTxInt}
   Set Suite Variable       ${reqMinRxInt}
   Set Suite Variable       ${bfdSrcIpAddrDN}

Get_BFD_Src_IPs
   [Documentation]		This keywrod is to get BFD source ip address
   GetBFDIds
   @{bfdSrcAddr_list}=   Create List
   FOR    ${value}    IN    @{bfdindex_list}
       GetBFDDetails      ${value}
       Append To List	    ${bfdSrcAddr_list}    ${bfdSrcIpAddr}
   END
   Set Suite Variable      ${bfdSrcAddr_list}    ${bfdSrcAddr_list}
   ${l2_capture_filter_bfdSrcAddr_ips}=	Set Variable	host @{bfdSrcAddr_list}[0]
   FOR    ${bfdIpAdr}    IN    @{bfdSrcAddr_list}
   	 ${l2_capture_filter_bfdSrcAddr_ips}=	Set Variable	${l2_capture_filter_bfdSrcAddr_ips} or host ${bfdIpAdr}
   END
   Set Suite Variable       ${bfdSrcAddr_list}
   Set Suite Variable       ${l2_capture_filter_bfdSrcAddr_ips}


GetBFDGRPDetails
   [Documentation]		This keywrod is to BFDGRP detais of given BFDGRP id. Arg ${bfdgrpindexvar} is BFDGRP ID to be verify
   [Arguments]      ${bfdgrpindexvar}
   ${bfdgrpObjects_dict} =    Query Admin Infomodel    query=get object ${bfdgrp_a_moc_path}${bfdgrpindexvar}
   ${bfdgrpSrcIpAddrDN}=    Get From Dictionary    dictionary=${bfdgrpObjects_dict}    key=bfdSrcIpAddrDN
   ${bfdgrpSrcIpAddr}=    Get Parameter    param_path=${bfdgrpSrcIpAddrDN}:localIpAddr
   ${bfdgrpDestIpAddr}=    Get From Dictionary    dictionary=${bfdgrpObjects_dict}    key=bfdDestIpAddr
   ${bfdgrpDscp}=    Get From Dictionary    dictionary=${bfdgrpObjects_dict}    key=bfdDscp
   ${bfdgrpSrcUdpPort}=    Get From Dictionary    dictionary=${bfdgrpObjects_dict}    key=bfdSrcUdpPort
   ${bfdgrpActivationStatus}=    Get From Dictionary    dictionary=${bfdgrpObjects_dict}    key=bfdActivation
   ${bfdgrpAdminUpStatus}=    Get From Dictionary    dictionary=${bfdgrpObjects_dict}    key=bfdAdminUp
   ${bfdgrpDetectMult}=    Get From Dictionary    dictionary=${bfdgrpObjects_dict}    key=bfdDetectMult
   ${bfdgrpType}=    Get From Dictionary    dictionary=${bfdgrpObjects_dict}    key=bfdType
   ${desMinTxInt}=    Get From Dictionary    dictionary=${bfdgrpObjects_dict}    key=desMinTxInt
   ${reqMinRxInt}=    Get From Dictionary    dictionary=${bfdgrpObjects_dict}    key=reqMinRxInt
   Set Suite Variable       ${bfdgrpSrcIpAddr}
   Set Suite Variable       ${bfdgrpDestIpAddr}
   Set Suite Variable       ${bfdgrpDscp}
   Set Suite Variable       ${bfdgrpSrcUdpPort}
   Set Suite Variable       ${bfdgrpActivationStatus}
   Set Suite Variable       ${bfdgrpAdminUpStatus}
   Set Suite Variable       ${bfdgrpDetectMult}
   Set Suite Variable       ${bfdgrpType}
   Set Suite Variable       ${desMinTxInt}
   Set Suite Variable       ${reqMinRxInt}


GetBFDGRPCount
   [Documentation]		This keywrod is to get bfdgroup cuont
    @{bfdgrpObjects_dict_list} =    Query Admin Infomodel    query=get list ${bfdgrp_a_moc_path}*
#   *
    ${BfdGrpCount}=    Get Length    ${bfdgrpObjects_dict_list}
    Set Suite Variable     ${BfdGrpCount}

GetBFDGRPIds
   [Documentation]		This keywrod is to get all  cnfigured BFDGRP ids
    @{bfdgrpindex_list}=   Create List
    FOR    ${bfdgrpindex}    IN RANGE    1    17
       ${output}=         Run Keyword And Return Status     Query Admin Infomodel    query=get object ${bfdgrp_a_moc_path}${bfdgrpindex}
       Run Keyword If     ${output} == True     Append To List	    ${bfdgrpindex_list}    ${bfdgrpindex}
    END
    Set Suite Variable     ${bfdgrpindex_list}


Get Primary and Secondary BFDs for ipv4
   [Documentation]		This keywrod is to get primary and secondary bfd session path details for ipv4
   ${iprt_dict} = 	Query Admin Infomodel		query=get object ${iprt_moc_path}
   ${route_list}=	Get From Dictionary	${iprt_dict} 	key=staticRoutes
   ${route_list_len}=		Get Length		${route_list}

   FOR 	${item}	IN RANGE	0	${route_list_len}
   	    ${route_list_item}=	Get From List	${route_list}	${item}
   	    ${dest_ip}=	Get From Dictionary	${route_list_item} 	key=destIpAddr
   	    ${gw_ip}=	Get From Dictionary	${route_list_item} 	key=gateway
   	    ${trigger_dn}=	Get From Dictionary	${route_list_item} 	key=triggerDN
   	    ${preference}=	Get From Dictionary	${route_list_item} 	key=preference
   	    Set Suite Variable     ${dest_ip}
   	    Set Suite Variable     ${gw_ip}
   	    Set Suite Variable     ${trigger_dn}
    	Set Suite Variable     ${preference}
   	    Run Keyword If     '${trigger_dn}'!= 'None'    Verify BFD Session Details
   END

Get Primary and Secondary BFDs for ipv6
   [Documentation]		This keywrod is to get primary and secondary bfd session path details for ipv6
   ${iprt_dict} = 	Query Admin Infomodel		query=get object ${iprtv6_moc_path}
   ${route_list}=	Get From Dictionary	${iprt_dict} 	key=staticIpv6Routes
   ${route_list_len}=		Get Length		${route_list}

   FOR 	${item}	IN RANGE	0	${route_list_len}
        ${route_list_item}=	Get From List	${route_list}	${item}
        ${dest_ip}=	Get From Dictionary	${route_list_item} 	key=destIpv6Addr
  	    ${gw_ip}=	Get From Dictionary	${route_list_item} 	key=gatewayIpv6Addr
   	    ${trigger_dn}=	Get From Dictionary	${route_list_item} 	key=triggerDN
   	    ${preference}=	Get From Dictionary	${route_list_item} 	key=preference
   	    Set Suite Variable     ${dest_ip}
   	    Set Suite Variable     ${gw_ip}
   	    Set Suite Variable     ${trigger_dn}
   	    Set Suite Variable     ${preference}
   	    Run Keyword If     '${trigger_dn}'!= 'None'    Verify BFD Session Details
   END

GetBFDIndex
   [Documentation]		This keywrod is to get BFD index of given source bfdDN
   @{bfd_list}=         Split String From Right     string=${bfdSrcDN}	    separator=-
   ${bfdIndex}=         Set Variable        @{bfd_list}[-1]
   @{bfd_list}=         Split String From Right     string=${bfdIndex}	    separator='
   ${bfdIndex}=         Set Variable        @{bfd_list}[0]
   Set Suite Variable       ${bfdIndex}


Verify BFD Session Details
   [Documentation]		This keywrod is to get BFD session of primary and secondary routing details
   @{trigger_list}=         Split String From Right     string=${trigger_dn}	    separator=-
   ${trigger_id}=         Set Variable        @{trigger_list}[-1]
   GetTriggerDetails        ${trigger_id}
   Set Suite Variable      ${trigger_id}
   Run Keyword If       ${preference}==1         Update Primary route details
   Run Keyword If       ${preference}==2         Update Secondary route details

Update Primary route details
   [Documentation]		This keywrod is to get BFD session of primary routing details
   ${primary_trigger_id}=          Set Variable        ${trigger_id}
   ${primary_bfd_id}=          Set Variable        ${triggerbfdindex}
   GetBFDDetails     ${primary_bfd_id}
   ${primary_bfd_remote_ip}=          Set Variable        ${bfdDestIpAddr}
   ${primary_bfd_source_ip}=          Set Variable        ${bfdSrcIpAddr}
   Set Suite Variable      ${primary_trigger_id}
   Set Suite Variable      ${primary_bfd_id}
   Set Suite Variable      ${primary_bfd_remote_ip}
   Set Suite Variable      ${primary_bfd_source_ip}

Update Secondary route details
   [Documentation]		This keywrod is to get BFD session of secondary routing details
   ${secondary_trigger_id}=          Set Variable        ${trigger_id}
   ${secondary_bfd_id}=          Set Variable        ${triggerbfdindex}
   GetBFDDetails     ${secondary_bfd_id}
   ${secondary_bfd_remote_ip}=          Set Variable        ${bfdDestIpAddr}
   ${secondary_bfd_source_ip}=          Set Variable        ${bfdSrcIpAddr}
   Set Suite Variable      ${secondary_trigger_id}
   Set Suite Variable      ${secondary_bfd_id}
   Set Suite Variable      ${secondary_bfd_remote_ip}
   Set Suite Variable      ${secondary_bfd_source_ip}

Bring Down Primary Session
   [Documentation]		This keywrod is to bringdown bfd session
   Setup Remote Access		remote_device=bts         alias=primary_down
   GetBFDDetails        ${primary_bfd_id}
   ${output}=     Run Keyword And Return Status     Should Contain      ${bfdDestIpAddr}	:
   Run Keyword If     ${output} == True      Remote Command Execute		command=ip6tables -I INPUT -s ${bfdDestIpAddr}/128 -j DROP
   ...   alias=primary_down
   Run Keyword If     ${output} == False     Remote Command Execute		command=iptables -I INPUT -s ${bfdDestIpAddr}/32 -j DROP
   ...    alias=primary_down
   #Execute Command On Enb    iptables -I INPUT -s ${bfdDestIpAddr}/32 -j DROP           alias=primary_down
   [Teardown]    Teardown Remote Access        alias=primary_down

Bring Up Primary Session
   [Documentation]		This keywrod is to bringup bfd session
   Setup Remote Access		remote_device=bts         alias=primary_up
   GetBFDDetails        ${primary_bfd_id}
   ${output}=     Run Keyword And Return Status     Should Contain      ${bfdDestIpAddr}	:
   Run Keyword If     ${output} == True     Remote Command Execute		command=ip6tables -D INPUT -s ${bfdDestIpAddr}/128 -j DROP
   ...    alias=primary_up
   Run Keyword If     ${output} == False    Remote Command Execute		command=iptables -D INPUT -s ${bfdDestIpAddr}/32 -j DROP
   ...     alias=primary_up
   #Execute Command On Enb    iptables -D INPUT -s ${bfdDestIpAddr}/32 -j DROP       alias=primary_up
   [Teardown]    Teardown Remote Access         alias=primary_up

Bring Down Secondary Session
   [Documentation]		This keywrod is to bringdown bfd session
   Setup Remote Access		remote_device=bts     alias=secondary_down
   GetBFDDetails        ${secondary_bfd_id}
   ${output}=     Run Keyword And Return Status     Should Contain      ${bfdDestIpAddr}	:
   Run Keyword If     ${output} == True     Remote Command Execute		command=ip6tables -I INPUT -s ${bfdDestIpAddr}/128 -j DROP
   ...     alias=secondary_down
   Run Keyword If     ${output} == False     Remote Command Execute		command=iptables -I INPUT -s ${bfdDestIpAddr}/32 -j DROP
   ...    alias=secondary_down
   #Execute Command On Enb    iptables -I INPUT -s ${bfdDestIpAddr}/32 -j DROP           alias=secondary_down
   [Teardown]    Teardown Remote Access             alias=secondary_down

Bring Up Secondary Session
   [Documentation]		This keywrod is to bringup bfd session
   Setup Remote Access		remote_device=bts         alias=secondary_up
   GetBFDDetails        ${secondary_bfd_id}
   ${output}=     Run Keyword And Return Status     Should Contain      ${bfdDestIpAddr}	:
   Run Keyword If     ${output} == True     Remote Command Execute		command=ip6tables -D INPUT -s ${bfdDestIpAddr}/128 -j DROP
   ...    alias=secondary_up
   Run Keyword If     ${output} == False     Remote Command Execute		command=iptables -D INPUT -s ${bfdDestIpAddr}/32 -j DROP
   ...   alias=secondary_up
   #Execute Command On Enb    iptables -D INPUT -s ${bfdDestIpAddr}/32 -j DROP       alias=secondary_up
   [Teardown]    Teardown Remote Access           alias=secondary_up


Start Ping Test
   [Documentation]		This keywrod is to start ping communication
   [Arguments]      ${dest}=${dest_ip}
    Run     python ping_test.py ${dest}

Stop ping
   [Documentation]		This keywrod is to stop ping communication and to verify packet loss
   Setup Remote Access		remote_device=bts         alias=ping_stop
   Remote Command Execute		command=killall -9 ping         alias=ping_stop
   #Execute Command On Enb       killall -9 traceroute   alias=ping_stop
   ${ping_result} =     Remote Command Execute		command=cat /user/toor4nsn/ping_details.txt        alias=ping_stop
   Should Contain       ${ping_result}      ttl
   #Log        ${ping_result}
   Set Suite Variable       ${ping_result}
   [Teardown]    Teardown Remote Access		alias=ping_stop

Stop trace
   [Documentation]		This keywrod is to stop trace
   Setup Remote Access		remote_device=bts         alias=trace_stop
   Run Keyword And Ignore Error     Remote Command Execute		command=killall -9 traceroute   alias=trace_stop
   ${trace_result} =     Remote Command Execute		command=cat /user/toor4nsn/traceroute_out.log        alias=trace_stop
   Set Suite Variable       ${trace_result}
   [Teardown]    Teardown Remote Access        alias=trace_stop

Verify success rate
   [Documentation]		This keywrod is to verify packet loss
    [Arguments]      ${result}=${ping_result}
    @{result}=      Split To Lines        ${ping_result}
    ${ActualRecievedPackets}=     Get Length     ${result}
    ${LastPacket}=     Set Variable     @{result}[-1]
    @{line_list}=         Split string     string=${LastPacket}        separator=
    @{icmp_packet}=         Split string     string=@{line_list}[4]        separator==
    @{Total_Packets}=         Split string     string=@{icmp_packet}[-1]        separator==
    ${Total_Packets}=         Convert To integer    @{Total_Packets}[-1]
    ${success_rate_decimal}=        Evaluate        ${ActualRecievedPackets}/${Total_Packets}
    ${success_rate}=        Evaluate        ${success_rate_decimal}*100
    #*
    Should be True          ${success_rate}==100
    Set Suite Variable      ${ActualRecievedPackets}
    Set Suite Variable      ${Total_Packets}
    Set Suite Variable      ${success_rate}

verify trace
   [Documentation]		This keywrod is to verify trace
   [Arguments]      ${bfd_remote_ip}
   Run     python trace_route.py ${dest_ip}
   sleep   5
   Stop trace
   @{result_line}=      Split To Lines        ${trace_result}
   @{result}=         Split string     string=@{result_line}[1]     separator=
   Should be True          @{result}[0]==1
   Should be True          '@{result}[1]'=='${bfd_remote_ip}'
   # log      @{result}[0]
   # log      @{result}[1]
   # log      @{result}[2]


   	#SSHLibrary.Open connection    	host=${enb_host}		alias=loginBts
	#${Loginstatus}=	   Run Keyword And Return Status    SSHLibrary.Login    username=${enb_username} 		password=${enb_password}
    #${output}=       SSHLibrary.Execute Command		traceroute ${dest_ip}
    #${status}      ${output}=       Run Keyword And Ignore Error    SSHLibrary.Execute Command
    #...   traceroute ${dest_ip} | grep -i "${bfd_remote_ip}" | awk '{print $1}' > /user/toor4nsn/traceroute_out.log
    #...  alias=loginBts      timeout=10
    #${output} =         SSHLibrary.Execute Command      cat /user/toor4nsn/traceroute_out.log


   #Setup Enb Fsm Access             alias=traceroute
   #${output} =     Execute Command On Enb		traceroute ${dest_ip} | grep -i "${bfd_remote_ip}" | awk '{print $1}'           alias=traceroute
   #...        timeout=5
   #${output} =     Execute Command On Enb		traceroute ${dest_ip}       alias=traceroute     timeout=100
   #${output} =     Execute Command On Enb		traceroute ${dest_ip}       alias=traceroute
   #Should be True          ${output}==1
   #[Teardown]    SSHLibrary.Close Connectio
