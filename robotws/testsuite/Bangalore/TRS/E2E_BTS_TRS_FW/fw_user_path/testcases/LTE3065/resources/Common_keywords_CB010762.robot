*** Settings ***
Documentation
...		[Author]     		        "Pranitha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "19:05:2021"
...		[Feature_ID] 		        "SR001395"

*** Variables ***
@{MME_IP_List}
@{LTE_C_IP_List}
@{LTE_U_IP_List}
@{SGW_IP_List}
@{LNADJ_IP_List}
@{QCI_IP_LIST}

*** Keywords ***
Verify S1 link status
	[Arguments]          ${operators}=10
	FOR   ${operator}   IN RANGE   0    ${operators}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${S1_status}=       Query Admin Infomodel    query=get object ${mme_moc_path}-${operator_str}
		   ${s1_link_status}=     Get From Dictionary     dictionary=${S1_status}      key=s1LinkStatus
          Should Be Equal		${s1_link_status}		available
    END

Verify S1 link status for ipv6
	[Arguments]          ${operators}=10
	FOR   ${operator}   IN RANGE   0    ${operators}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${S1_status}=       Query Admin Infomodel    query=get object ${mme_moc_path}-${operator_str}
		   ${s1_link_status}=     Get From Dictionary     dictionary=${S1_status}      key=s1LinkStatus
    	      Should Be Equal		${s1_link_status}		available
	END

Verify S1 link status for ipv4
	FOR   ${operator}   IN RANGE   10    19
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${S1_status}=       Query Admin Infomodel    query=get object ${mme_moc_path}-${operator_str}
		   ${s1_link_status}=     Get From Dictionary     dictionary=${S1_status}      key=s1LinkStatus
    	      Should Be Equal		${s1_link_status}		available
	END

Verify X2 link status
	[Arguments]        ${start_index}=30     ${stop_index}=40
	FOR   ${operator}   IN RANGE   ${start_index}    ${stop_index}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${x2_status}=       Query Admin Infomodel    query=get object ${lnadj_path}-${operator_str}
		   ${x2_link_status}=     Get From Dictionary     dictionary=${x2_status}      key=x2LinkStatus
          Should Be Equal		${x2_link_status}		available
    END

Get IP Version
	[Arguments]        ${ip}
	${contains}=  Evaluate   ":" in """${ip}"""
	Run Keyword IF      '${contains}'=='True'       Set Suite Variable      ${version}    ipV6
    ...    ELSE       	Set Suite Variable      ${version}    ipV4

Get MME IP Address
	[Arguments]          ${index}=1

	FOR   ${operator}   IN RANGE   0   ${index}
		${mme_dict}=      Query Admin Infomodel    query=get object ${mme_path}-${operator}
    	${mme_ip}=       Get From Dictionary       ${mme_dict}    ipAddrPrim
	    Append To List    ${MME_IP_List}    ${mme_ip}
	END


Get LTE-C IP Address
 	[Arguments]        ${IP_Version}     ${index}=1
	FOR   ${operator}   IN RANGE   0   ${index}
		${LTE_C_IP}=      Get Parameter      param_path=TRSNW-${operator}:cPlane:${IP_Version}AddressDN1:localIpAddr
		Append to List     ${LTE_C_IP_List}      ${LTE_C_IP}
    END

Get LTE-U IP Address
 	[Arguments]        ${IP_Version}     ${index}=1
	FOR   ${operator}   IN RANGE   0   ${index}
		${LTE_U_IP}=      Get Parameter      param_path=TRSNW-${operator}:uPlane:${IP_Version}AddressDN1:localIpAddr
		Append to List     ${LTE_U_IP_List}      ${LTE_U_IP}
    END

Get LTE-C IP Address Secondary
 	[Arguments]        ${IP_Version}     ${index}=1
	FOR   ${operator}   IN RANGE   0   ${index}
		${LTE_C_IP}=      Get Parameter      param_path=TRSNW-${operator}:cPlane:${IP_Version}AddressDN2:localIpAddr
		Append to List     ${LTE_C_IP_List_Secondary}      ${LTE_C_IP}
		Set Suite Variable	${LTE_C_IP_List_Secondary}	${LTE_C_IP_List_Secondary}
	END

Get LTE-U IP Address Secondary
    [Arguments]        ${IP_Version}     ${index}=2
    FOR   ${operator}   IN RANGE   0   ${index}
       ${LTE_U_IP_secondary}=      Get Parameter      param_path=TRSNW-${operator}:uPlane:${IP_Version}AddressDN2:localIpAddr
       Append to List     ${LTE_U_IP_List_secondary}      ${LTE_U_IP_secondary}
    END

Get LNADJ IP Address
	[Arguments]         ${start_index}=30     ${stop_index}=40
	FOR   ${operator}   IN RANGE   ${start_index}    ${stop_index}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${lnadj_dict}=       Query Admin Infomodel    query=get object ${lnadj_path}-${operator_str}
	      ${lnadj_ip}=     Get From Dictionary     dictionary=${lnadj_dict}      key=cPlaneIpAddr
	      Append to List     ${LNADJ_IP_List}      ${lnadj_ip}
    END

Get SGW IP Address
	[Arguments]          ${operator}=1
	FOR   ${index}   IN RANGE   0    ${operator}
	     ${gtpu_dict}=     Query Admin Infomodel    query=get object ${gtpu_path}
	     ${sgw_list}=      Get From Dictionary       ${gtpu_dict}     sgwIpAddressList
	     ${sgw_dict}=      Get From List      ${sgw_list}            ${index}
	     ${sgw_ip}=       Get From Dictionary     ${sgw_dict}        sgwIpAddress
	     Append to List     ${SGW_IP_List}      ${sgw_ip}
	END

Delete IP List Address
	FOR     ${ip}    IN    @{MME_IP_List}
    	Remove values from list    ${MME_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{LTE_C_IP_List}
    	Remove values from list    ${LTE_C_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{LTE_U_IP_List}
    	Remove values from list    ${LTE_U_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{LNADJ_C_IP_List}
    	Remove values from list    ${NRADJ_C_IP_List}    ${ip}
    END

Delete Interfaces
	${IPv4}=     Run    ip -4 addr show eth3 | grep -i "global" | awk '{print $2}'
	@{IPv4_list}=     Split String      ${IPv4}
	Delete IP Interface from eth3     ${IPv4_list}
	${IPv6}=     Run   ip -6 addr show eth3 | grep -i "scope global" | awk '{print $2}'
	@{IPv6_list}=     Split String      ${IPv6}
	Delete IP Interface from eth3     ${IPv6_list}
	${vlan}=   Run   ip a s | grep "@eth3" | awk '{print $2}'
	${vlan}=    Remove String    ${vlan}   @eth3:
	@{Vlan_list}=     Split String      ${vlan}
	Delete Vlan Interface of eth3    ${Vlan_list}

Delete IP Interface from eth3
    [Arguments]      ${IP_list}
	FOR   ${IP}  IN   @{IP_list}
		Run     sudo ip a delete ${IP} dev eth3
	END

Delete Vlan Interface of eth3
    [Arguments]      ${Vlan_list}
	FOR   ${vlanid}  IN   @{Vlan_list}
	   Run    sudo ip link delete dev ${vlanid}
	END

Attach LTE UE with operator and send ul dl traffic
	[Arguments]          ${operator}       ${device1}     ${cell}
	${ue_id}=       Evaluate       0+${operator}
	${plmn_index}=     Evaluate       ${operator}-1
	${HO_id}=		Evaluate       ${operator}-1
	${throughput}=     Evaluate      2000*${operator}
	Configure UE      lte=${device1}:data     command=ue_attach id=${ue_id}
	...		 cell=${HO_cell}[${HO_id}] selected_plmn=${operator_plmn}[${plmn_index}]
	sleep  2
	Configure UE      lte=${device1}:data     command=ue_ho id=${ue_id} cell=${cell}
	sleep  1


Stop traffic and detach LTE UE
	[Arguments]          ${operator}       ${profile}
	${ue_id}=       Evaluate       0+${operator}
	Configure UE      lte=${profile}:data     command=ue_detach id=1
	sleep  10