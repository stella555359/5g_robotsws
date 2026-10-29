*** Settings ***
Documentation
...		[Author]     		        "Pranitha"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "16:09:2025"
...		[Feature_ID] 		        "PET"

*** Variables ***
@{MME_IP_List}
@{LTE_C_IP_List}
@{LTE_U_IP_List}
@{SGW_IP_List}
@{LNADJ_IP_List}

*** Keywords ***
Verify S1 link status
	[Arguments]          ${operators}=1
	FOR   ${operator}   IN RANGE   0    ${operators}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${S1_status}=       Query Admin Infomodel    query=get object ${mme_moc_path}-${operator_str}
		   ${s1_link_status}=     Get From Dictionary     dictionary=${S1_status}      key=s1LinkStatus
          Should Be Equal		${s1_link_status}		available
    END

Verify X2 link status
	[Arguments]        ${start_index}=0     ${stop_index}=1
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

Get LNADJ IP Address
	[Arguments]         ${start_index}=0     ${stop_index}=1
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

Attach LTE UE with operator and send ul dl traffic
	[Arguments]          ${operator}       ${profile}
	${ue_id}=       Evaluate       0+${operator}
	${plmn_index}=     Evaluate       ${operator}-1
	${throughput}=     Evaluate      2000*${operator}
    Configure UE      lte=${profile}:data     command=ue_attach id=${ue_id} cell=11
	sleep  5
    Configure UE      lte=${profile}:data     command=trf_data_start ue=${ue_id} dir=ul Mbps=500 protocol=udp
    sleep   5
    Configure UE      lte=${profile}:data     command=trf_data_start ue=${ue_id} dir=dl Mbps=500 protocol=udp
    sleep   5

Stop traffic and detach LTE UE
	[Arguments]          ${operator}       ${profile}
	${ue_id}=       Evaluate       0+${operator}
	Configure UE      lte=${profile}:data     command=ue_detach id=${ue_id}
	sleep  10
	[TEARDOWN]    Keyword to Run at end


Attach UE with operator specific qci and send ul dl traffic for 5g
    [Arguments]          ${operator}
	${size}=      Evaluate      1000*${operator}
	Configure UE       5g=device4:data   command=ue_register  id=${operator}  profile=${operator}
    sleep  10
	Configure UE       5g=device4:data   command=set_pdu_param  ue=${operator}   pdu=${operator}  trf_type=internal
    sleep  10
    Configure UE       5g=device4:data   command=ue_pdu_session_setup  pdu=${operator}  ue=${operator}  nwslice=${operator}  gw=${operator}
    sleep  10
    Configure UE       5g=device4:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=175
    sleep  5
    Configure UE       5g=device4:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=175
    sleep  5
	Configure UE       5g=device4:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=175
    sleep  5
    Configure UE       5g=device4:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=175
    sleep  5
	Configure UE       5g=device4:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=175
    sleep  5
    Configure UE       5g=device4:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=175
    sleep  5
	Configure UE       5g=device4:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=175
    sleep  5
    Configure UE       5g=device4:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=175
    sleep  5
	Configure UE       5g=device4:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=100
	sleep  5
	Configure UE       5g=device4:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=ul   mbps=175
    sleep  5
	Configure UE       5g=device4:data   command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=ul   mbps=50
	sleep  5

Stop traffic and detach UE for 5g
    [Arguments]          ${operator}
	Configure UE       5g=device4:data   command=ue_pdu_session_release  ue=${operator}    pdu=${operator}
    Sleep   50
    Configure UE       5g=device4:data   command=ue_deregister  id=${operator}  ue_deregister_type=switch_off
    Sleep   10