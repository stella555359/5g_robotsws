*** Settings ***
Documentation
...		[Author]     		        "Nupur"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "19:05:2024"
...		[Feature_ID] 		        "CB010712"

Resource          ${CURDIR}/../../resources/common_keywords.robot

*** Variables ***
@{AMF_IP_List}
@{MME_IP_List}
@{NGU_IP_List}
@{NGC_IP_List}
@{LTE_C_IP_List}
@{LTE_U_IP_List}
@{NRADJ_C_IP_List}
@{X2C_IP_List}
@{S1U_IP_List}
*** Keywords ***
Attach NSA UE with dedicated bearer and send ul dl traffic for slice call
    [Arguments]          ${ue_id}        ${plmn}    ${sgw_id}=1    ${cell_id}=11    ${qci}=128    ${nr_cell}=50
	Execute Cmd On Egate       lte=${profile}:data      cmd=ue_mme_param id=${ue_id} sgw_id=${sgw_id}
	sleep  5
	Configure UE       lte=${profile}:data  command=ue_attach id=${ue_id} enb=1 cell=${cell_id} selected_plmn=${plmn} scg_ul_dist_percent=100
    sleep  5
	Configure UE       lte=${profile}:data  command=bearer_add ue=${ue_id} qci=${qci}
    sleep  5
    Configure UE       lte=${profile}:data
	...  command=ue_measurement_send event=B1_NR id=${ue_id} phycell_id=${nr_cell} srsrp=97 srsrq=34 nrsrp=97 nrsrq=30 nsinr=0
    sleep  5
    Configure UE       lte=${profile}:data  command=trf_data_start ue=${ue_id} dir=ul protocol=udp Mbps=1 stats=true qci=${qci}
	sleep  30

Detach NSA UE
    [Arguments]          ${ue_id}
	Configure UE       lte=${profile}:data  command=ue_detach id=${ue_id}

Delete Vlan Interface of eth3
    [Arguments]      ${Vlan_list}
	FOR   ${vlanid}  IN   @{Vlan_list}
	   Run    sudo ip link delete dev ${vlanid}
    END

Attach DC UE to outside MeNB and send ul dl traffic
	[Arguments]        ${profile}    ${ue}     ${sgw}     ${target_cell}
	Configure UE       5g=${profile}:data  command=ue_mme_param    id=${ue}    sgw_id=${sgw}
    sleep  5
	Configure UE       5g=${profile}:data  command=ue_attach   id=${ue}
    sleep  15
    Configure UE       5g=${profile}:data  command=enb_ue_dc_start    ue=${ue}    target_gnb=2   target_cells=${target_cell}   bearer=2
	...    type=split_scg
    sleep  10
    Configure UE       5g=${profile}:data  command=trf_data_start   ue=${ue}   id=2   dir=ul   trf_id=1  kbps=2000
    sleep  10
    Configure UE       5g=${profile}:data  command=trf_data_start   ue=${ue}   id=2   dir=dl   trf_id=1  kbps=2000
    sleep  10

Stop traffic and detach DC UE
	[Arguments]       ${profile}    ${ue}
	Configure UE       5g=${profile}:data  command=ue_detach    id=${ue}
    sleep  10

Attach UE with operator specific qci and send ul traffic
    [Arguments]          ${operator}       ${profile}    ${slice}
	Configure UE       5g=${profile}:data  command=ue_register  id=${operator}  profile=${operator}
    sleep  5
	Configure UE       5g=${profile}:data  command=set_pdu_param  ue=${operator}   pdu=${operator}  trf_type=internal
    sleep  5
    Configure UE       5g=${profile}:data  command=ue_pdu_session_setup  pdu=${operator}  ue=${operator}  nwslice=${slice}  gw=${operator}
    sleep  5
    Configure UE       5g=${profile}:data  command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=ul   mbps=20
    sleep  10

Attach UE with operator specific qci and send dl traffic
    [Arguments]          ${operator}       ${profile}     ${slice}
	Configure UE       5g=${profile}:data  command=ue_register  id=${operator}  profile=${operator}
    sleep  5
	Configure UE       5g=${profile}:data  command=set_pdu_param  ue=${operator}   pdu=${operator}  trf_type=internal
    sleep  5
    Configure UE       5g=${profile}:data  command=ue_pdu_session_setup  pdu=${operator}  ue=${operator}  nwslice=${slice}  gw=${operator}
    sleep  5
    Configure UE       5g=${profile}:data  command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=20
    sleep  10

Attach UE with operator specific qci and send ul dl traffic
    [Arguments]          ${operator}       ${profile}     ${slice}
	Configure UE       5g=${profile}:data  command=ue_register  id=${operator}  profile=${operator}
    sleep  5
	Configure UE       5g=${profile}:data  command=set_pdu_param  ue=${operator}   pdu=${operator}  trf_type=internal
    sleep  5
    Configure UE       5g=${profile}:data  command=ue_pdu_session_setup  pdu=${operator}  ue=${operator}  nwslice=${slice}  gw=${operator}
    sleep  5
    Configure UE       5g=${profile}:data  command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=ul   mbps=20
    sleep  1
    Configure UE       5g=${profile}:data  command=trf_data_start  ue=${operator}  pdu=${operator}    qfi=1   dir=dl   mbps=20
    sleep  10

Verify NG link Status
	[Arguments]          ${operators}=1
	${index}=     Evaluate      ${operators}+1
	FOR   ${operator}   IN RANGE   1   ${index}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${NG_status}=       Query Admin Infomodel    query=get object ${amf_moc_path}-${operator_str}
		   ${ng_link_status}=     Get From Dictionary     dictionary=${NG_status}      key=ngLinkStatus
          Should Be Equal		${ng_link_status}		Active
    END

Verify Xn link Status
	[Arguments]          ${operators}=1
	${index}=     Evaluate      ${operators}+1
	FOR   ${operator}   IN RANGE   1   ${index}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${Xn_status}=      Query Admin Infomodel    query=get object ${Xn_link_path}-${operator_str}
          ${Xn_link_status}=       Get From Dictionary     ${Xn_status}      xnLinkStatus
          Should Be Equal    ${Xn_link_status}      available
    END

Verify S1 link Status
	[Arguments]          ${operators}=1
	FOR   ${operator}   IN RANGE   0   ${operators}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${S1_status}=      Query Admin Infomodel    query=get object ${mme_moc_path}-${operator_str}
          ${S1_link_status}=       Get From Dictionary     ${S1_status}      s1LinkStatus
          Should Be Equal    ${S1_link_status}      available
    END

Stop traffic and detach UE
    [Arguments]          ${operator}       ${profile}
	Configure UE       5g=${profile}:data  command=ue_pdu_session_release  ue=${operator}    pdu=${operator}
    Sleep   50
    Configure UE       5g=${profile}:data  command=ue_deregister  id=${operator}  ue_deregister_type=switch_off
	Sleep   5

Get IP Version
	[Arguments]        ${ip}
	${contains}=  Evaluate   ":" in """${ip}"""
	Run Keyword IF      '${contains}'=='True'       Set Suite Variable      ${version}    ipV6
    ...    ELSE       	Set Suite Variable      ${version}    ipV4

Get AMF IP Address
	[Arguments]          ${operator}=1

	${index}=    Evaluate      ${operator}+1
	FOR   ${operator}   IN RANGE   1   ${index}
	    ${amf_dict}=      Query Admin Infomodel    query=get object ${amf_path}-${operator}
        ${amf_ip}=       Get From Dictionary       ${amf_dict}    amfIPAddress
	    Append To List    ${AMF_IP_List}    ${amf_ip}
    END

Get MME IP Address
	[Arguments]          ${index}=1

	FOR   ${operator}   IN RANGE   0   ${index}
		${mme_dict}=      Query Admin Infomodel    query=get object ${mme_path}-${operator}
    	${mme_ip}=       Get From Dictionary       ${mme_dict}    ipAddrPrim
	    Append To List    ${MME_IP_List}    ${mme_ip}
    END

Get NG-U IP Address
 	[Arguments]          ${index}=1

	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${nguplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=ngUplane
	FOR   ${operator}   IN RANGE   0   ${index}
		${nguplane_add}=   Get from list       ${nguplane_list}        ${operator}
		${nguplane_moc}=    Get From Dictionary     ${nguplane_add}       ipV4AddressDN1
		${nguplane_ipif}=   Query Admin Infomodel     query=get object ${nguplane_moc}
		${nguplane_ip}=    Get From Dictionary      ${nguplane_ipif}      localIpAddr
		Append To List    ${NGU_IP_List}    ${nguplane_ip}
    	${nguplane_moc}=    Get From Dictionary     ${nguplane_add}       ipV6AddressDN1
		${nguplane_ipif}=   Query Admin Infomodel     query=get object ${nguplane_moc}
		${nguplane_ip}=    Get From Dictionary      ${nguplane_ipif}      localIpAddr
		Append To List    ${NGU_IP_List}    ${nguplane_ip}
    END

Get NG-C IP Address
 	[Arguments]          ${index}=1

	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${ngcplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=ngCplane

	FOR   ${operator}   IN RANGE   0   ${index}
		${ngcplane_add}=   Get from list       ${ngcplane_list}        ${operator}
		${ngcplane_moc}=    Get From Dictionary     ${ngcplane_add}       ipV4AddressDN1
    	${ngcplane_ipif}=   Query Admin Infomodel     query=get object ${ngcplane_moc}
		${ngcplane_ip}=    Get From Dictionary      ${ngcplane_ipif}      localIpAddr
		Append To List    ${NGC_IP_List}    ${ngcplane_ip}
    	${ngcplane_moc}=    Get From Dictionary     ${ngcplane_add}       ipV6AddressDN1
		${ngcplane_ipif}=   Query Admin Infomodel     query=get object ${ngcplane_moc}
		${ngcplane_ip}=    Get From Dictionary      ${ngcplane_ipif}      localIpAddr
		Append To List    ${NGC_IP_List}    ${ngcplane_ip}
    END

Get S1-U IP Address
 	[Arguments]          ${index}=1

	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${s1uplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=s1Uplane

	FOR   ${operator}   IN RANGE   0   ${index}
		${s1uplane_add}=   Get from list       ${s1uplane_list}        ${operator}
		${s1uplane_moc}=    Get From Dictionary     ${s1uplane_add}       ipV4AddressDN1
		${s1uplane_ipif}=   Query Admin Infomodel     query=get object ${s1uplane_moc}
		${s1uplane_ip}=    Get From Dictionary      ${s1uplane_ipif}      localIpAddr
		Append To List    ${S1U_IP_List}    ${s1uplane_ip}
    	${s1uplane_moc}=    Get From Dictionary     ${s1uplane_add}       ipV6AddressDN1
		${s1uplane_ipif}=   Query Admin Infomodel     query=get object ${s1uplane_moc}
		${s1uplane_ip}=    Get From Dictionary      ${s1uplane_ipif}      localIpAddr
		Append To List    ${S1U_IP_List}    ${s1uplane_ip}
    END

Get X2-C IP Address
 	[Arguments]          ${index}=1

	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${x2cplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=x2Cplane

	FOR   ${operator}   IN RANGE   0   ${index}
		${x2cplane_add}=   Get from list       ${x2cplane_list}        ${operator}
		${x2cplane_moc}=    Get From Dictionary     ${x2cplane_add}       ipV4AddressDN1
		${x2cplane_ipif}=   Query Admin Infomodel     query=get object ${x2cplane_moc}
		${x2cplane_ip}=    Get From Dictionary      ${x2cplane_ipif}      localIpAddr
		Append To List    ${X2C_IP_List}    ${x2cplane_ip}
    	${x2cplane_moc}=    Get From Dictionary     ${x2cplane_add}       ipV6AddressDN1
		${x2cplane_ipif}=   Query Admin Infomodel     query=get object ${x2cplane_moc}
		${x2cplane_ip}=    Get From Dictionary      ${x2cplane_ipif}      localIpAddr
		Append To List    ${X2C_IP_List}    ${x2cplane_ip}
    END

Get NRADJ IP Address
 	[Arguments]         ${operators}=1
	${index}=     Evaluate      ${operators}+1
	FOR   ${operator}   IN RANGE   1   ${index}
       ${nradj_cplane}=    Query Admin Infomodel    query=get object ${Xn_link_path_A}-${operator}
	   ${nradj_cplane_ip}=       Get From Dictionary     ${nradj_cplane}     cPlaneIpAddr
	   Append To List    ${NRADJ_C_IP_List}    ${nradj_cplane_ip}
    END

Get LTE-C IP Address
 	[Arguments]        ${index}=1

	FOR   ${operator}   IN RANGE   0   ${index}
		${LTE_C_IP}=      Get Parameter      param_path=TRSNW-${operator}:cPlane:ipV4AddressDN1:localIpAddr
		Append to List     ${LTE_C_IP_List}      ${LTE_C_IP}
		${LTE_C_IP}=      Get Parameter      param_path=TRSNW-${operator}:cPlane:ipV6AddressDN1:localIpAddr
		Append to List     ${LTE_C_IP_List}      ${LTE_C_IP}
    END

Trigger and Verify Random SA IPsec IPv4 call
    [Arguments]       ${start}=1      ${end}=1     ${operators}=1
	${operator_list}=    Evaluate    random.sample(range(${start}, ${end}), ${operators})    random
	Traffic capture start           capture_device=oam_device   mode=file   measurement_point=NE_Terminated    uplane_capturing=${True}
	...    timeout=120   alias=operator_IPv4
	FOR   ${operator}   IN     @{operator_list}
	    Attach UE with operator specific qci and send ul dl traffic      ${operator}     ${profile}      ${operator}
	    Stop traffic and detach UE          ${operator}       ${profile}
	END
	${pcap_file}=       Traffic capture stop	  mode=file   alias=operator_IPv4
	FOR   ${operator}   IN     @{operator_list}
	    ${index}=     Evaluate     ${operator}*2-2
	    ${nguplane_ip}=    Get from List      ${NGU_IP_List}     ${index}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_ul_ipV4
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_dl_ipV4
	END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	 mode=file   alias=operator_IPv4

Trigger and Verify Random SA IPsec IPv6 call
    [Arguments]       ${start}=1      ${end}=1     ${operators}=1
	${operator_list}=    Evaluate    random.sample(range(${start}, ${end}), ${operators})    random
	Traffic capture start       capture_device=oam_device   mode=file   measurement_point=NE_Terminated    uplane_capturing=${True}    timeout=120
	...   	alias=operator_IPv6
	FOR   ${operator}   IN     @{operator_list}
	    Attach UE with operator specific qci and send ul dl traffic      ${operator}     ${profile}     ${operator}
	    Stop traffic and detach UE          ${operator}       ${profile}
	END
	${pcap_file}=       Traffic capture stop	 mode=file   alias=operator_IPv6
	FOR   ${operator}   IN     @{operator_list}
	    ${index}=     Evaluate     ${operator}*2-1
	    ${nguplane_ip}=    Get from List      ${NGU_IP_List}     ${index}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_ul_ipV6
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_dl_ipV6
	END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	 mode=file   alias=operator_IPv6

Trigger and Verify Random SA IPv4 call
    [Arguments]       ${start}=1      ${end}=1     ${operators}=1
	${operator_list}=    Evaluate    random.sample(range(${start}, ${end}), ${operators})    random
	Traffic capture start           capture_device=oam_device   mode=file   measurement_point=Transport_Interface    uplane_capturing=${True}
	...    timeout=120   alias=operator_IPv4
	FOR   ${operator}   IN     @{operator_list}
	    Attach UE with operator specific qci and send ul dl traffic      ${operator}     ${profile}      ${operator}
	    Stop traffic and detach UE          ${operator}       ${profile}
	END
	${pcap_file}=       Traffic capture stop	  mode=file   alias=operator_IPv4
	FOR   ${operator}   IN     @{operator_list}
	    ${index}=     Evaluate     ${operator}*2-2
	    ${nguplane_ip}=    Get from List      ${NGU_IP_List}     ${index}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_ul_ipV4
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_dl_ipV4
	END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	 mode=file   alias=operator_IPv4

Trigger and Verify Random SA IPv6 call
    [Arguments]       ${start}=1      ${end}=1     ${operators}=1
	${operator_list}=    Evaluate    random.sample(range(${start}, ${end}), ${operators})    random
	Traffic capture start       capture_device=oam_device   mode=file   measurement_point=Transport_Interface    uplane_capturing=${True}
	...    timeout=120 	alias=operator_IPv6
	FOR   ${operator}   IN     @{operator_list}
	    Attach UE with operator specific qci and send ul dl traffic      ${operator}     ${profile}     ${operator}
	    Stop traffic and detach UE          ${operator}       ${profile}
	END
	${pcap_file}=       Traffic capture stop	 mode=file   alias=operator_IPv6
	FOR   ${operator}   IN     @{operator_list}
	    ${index}=     Evaluate     ${operator}*2-1
	    ${nguplane_ip}=    Get from List      ${NGU_IP_List}     ${index}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_ul_ipV6
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_dl_ipV6
	END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	 mode=file   alias=operator_IPv6

Trigger and Verify Random NSA IPsec call
	[Arguments]       ${start}=1      ${end}=1     ${operators}=1
	${operator_list}=    Evaluate    random.sample(range(${start}, ${end}), ${operators})    random
	Traffic capture start       capture_device=oam_device   mode=file   measurement_point=NE_Terminated    uplane_capturing=${True}    timeout=120
	...   	alias=operator_NSA
	FOR   ${operator}   IN     @{operator_list}
	      ${ue}=     Evaluate     ${operator}+20
	      ${target_cell}=    Set Variable If    1<=${operator}<=3     1
	      ...     4<=${operator}<=6       2
	      Attach DC UE to outside MeNB and send ul dl traffic   ${profile}   ${ue}     ${ue}     ${target_cell}
	      Stop traffic and detach DC UE        ${profile}    ${ue}
	END
    ${pcap_file}=       Traffic capture stop	 mode=file   alias=operator_NSA
	FOR   ${operator}   IN     @{operator_list}
	      ${index}=     Set Variable If
          ...      ${operator}==1     0
    	  ...      ${operator}==2     4
		  ...      ${operator}==3     8
		  ...      ${operator}==4     12
		  ...      ${operator}==5     16
		  ...      ${operator}==6     18
	    ${s1uplane_ip}=    Get from List      ${S1U_IP_List}     ${index}
	    Get IP Version       ${s1uplane_ip}
        Analyse Pcap        pcap_filename=${pcap_file}        analysis=nsa_call_ul_${version}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=nsa_call_dl_${version}
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

Handover UE to Neighbouring gNB
    [Arguments]          ${operator}    ${profile}     ${nrcell_id}
	Configure UE    5g=${profile}:data    command=ue_measurement_send_nr     id=${operator}    meas_id=1    event=A3    srsrp_nr=1   srsrq_nr=11
	...    phycell_id=${nrcell_id}   nrsrp_nr=60   nrsrq_nr=60
    Sleep   15

Verify X2 link Status
	[Arguments]          ${operators}=1
	FOR   ${operator}   IN RANGE   0   ${operators}
	      ${operator_str}=	   Convert To String	    ${operator}
	      ${X2_status}=      Query Admin Infomodel    query=get object //LTEENB_R-${operator_str}
          ${X2_link_status}=       Get From Dictionary     ${X2_status}      x2LinkStatus
          Should Be Equal    ${X2_link_status}      available
	END

Get AMF Multihome IP Address
	[Arguments]          ${operator}=1

	${index}=    Evaluate      ${operator}+1
	FOR   ${operator}   IN RANGE   1   ${index}
	   ${amf_dict}=      Query Admin Infomodel    query=get object ${amf_path}-${operator}
       ${amf_ip}=       Get From Dictionary       ${amf_dict}    amfIPAddressSec
	   Append To List    ${AMF_IP2_List}    ${amf_ip}
	END

Get NG-C Secondary IP Address
	[Arguments]          ${index}=1

	${nrbts_dict}=    Query Admin Infomodel    query=get object ${nrbts_path}
	${ngcplane_list}=    Get From Dictionary     dictionary=${nrbts_dict}      key=ngCplane

	FOR   ${operator}   IN RANGE   0   ${index}
		${ngcplane_add}=   Get from list       ${ngcplane_list}        ${operator}
		${ngcplane_moc}=    Get From Dictionary     ${ngcplane_add}       ipV4AddressDN2
		${ngcplane_ipif}=   Query Admin Infomodel     query=get object ${ngcplane_moc}
		${ngcplane_ip}=    Get From Dictionary      ${ngcplane_ipif}      localIpAddr
		Append To List    ${NGC_IP2_List}    ${ngcplane_ip}
    	${ngcplane_moc}=    Get From Dictionary     ${ngcplane_add}       ipV6AddressDN2
		${ngcplane_ipif}=   Query Admin Infomodel     query=get object ${ngcplane_moc}
		${ngcplane_ip}=    Get From Dictionary      ${ngcplane_ipif}      localIpAddr
		Append To List    ${NGC_IP2_List}    ${ngcplane_ip}
	END

Verify NR-SA Slice Status
    [Arguments]          ${slices}=1
    ${index}=     Evaluate      ${slices}+1
    FOR   ${slice}   IN RANGE   1   ${index}
          ${slice_str}=     Convert To String        ${slice}
          ${slice_status}=       Query Admin Infomodel    query=get object ${snssai_path}-${slice_str}
          ${slice_op_status}=     Get From Dictionary     dictionary=${slice_status}      key=operationalState
          Should Be Equal       ${slice_op_status}       enabled
    END

Get LTE-U IP Address
 	[Arguments]         ${index}=1

	FOR   ${operator}   IN RANGE   0   ${index}
		${LTE_U_IP}=      Get Parameter      param_path=TRSNW-${operator}:uPlane:ipV4AddressDN1:localIpAddr
		Append to List     ${LTE_U_IP_List}      ${LTE_U_IP}
		${LTE_U_IP}=      Get Parameter      param_path=TRSNW-${operator}:uPlane:ipV6AddressDN1:localIpAddr
		Append to List     ${LTE_U_IP_List}      ${LTE_U_IP}
    END

Delete IP List Address
	FOR     ${ip}    IN    @{AMF_IP_List}
    	Remove values from list    ${AMF_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{MME_IP_List}
    	Remove values from list    ${MME_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{NGU_IP_List}
    	Remove values from list    ${NGU_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{NGC_IP_List}
    	Remove values from list    ${NGC_IP_List}    ${ip}
    END

    FOR     ${ip}    IN    @{LTE_C_IP_List}
    	Remove values from list    ${LTE_C_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{LTE_U_IP_List}
    	Remove values from list    ${LTE_U_IP_List}    ${ip}
    END

	FOR     ${ip}    IN    @{NRADJ_C_IP_List}
    	Remove values from list    ${NRADJ_C_IP_List}    ${ip}
    END

Trigger and Verify Random IPv4 call with Handover
    [Arguments]       ${start}=1      ${end}=1     ${operators}=1
	${operator_list}=    Evaluate    random.sample(range(${start}, ${end}), ${operators})    random
	FOR   ${operator}   IN     @{operator_list}
	    ${index}=     Evaluate     ${operator}*2-2
	    ${index2}=     Evaluate     ${operator}-1
	    ${nrcell_id}=       Evaluate     51+${operator}
	    Traffic capture start           capture_device=l2_wireshark 		alias=operator_${operator}
	    Attach UE with operator specific qci and send ul dl traffic      ${operator}     ${profile}      ${operator}
        Handover UE to Neighbouring gNB	   ${operator}    ${profile}     ${nrcell_id}
	    Stop traffic and detach UE          ${operator}       ${profile}
	    ${pcap_file}=       Traffic capture stop	  alias=operator_${operator}
	    ${nguplane_ip}=    Get from List      ${NGU_IP_List}     ${index}
        ${amf_ip}=      Get from List      ${AMF_IP_List}	   ${index}
	    ${xnc_ip}=     Get from List     ${NRADJ_C_IP_List}      ${index2}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_ul_ipV4
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_dl_ipV4
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_handover_request_ipV4
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_handover_ack_ipV4
     END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator}

Trigger and Verify Random IPv6 call with Handover
    [Arguments]       ${start}=1      ${end}=1     ${operators}=1
	${operator_list}=    Evaluate    random.sample(range(${start}, ${end}), ${operators})    random
	FOR   ${operator}   IN     @{operator_list}
	    ${index}=     Evaluate     ${operator}*2-1
	    ${index2}=     Evaluate     ${operator}-1
	    ${nrcell_id}=       Evaluate     51+${operator}
	    ${slice}=     Set Variable If    1<=${operator}<=6    ${operator}
         ...     7<=${operator}<=10       7
	    Traffic capture start           capture_device=l2_wireshark 		alias=operator_${operator}
	    Attach UE with operator specific qci and send ul dl traffic      ${operator}     ${profile}     ${slice}
        Handover UE to Neighbouring gNB	   ${operator}    ${profile}     ${nrcell_id}
	    Stop traffic and detach UE          ${operator}       ${profile}
	    ${pcap_file}=       Traffic capture stop	  alias=operator_${operator}
	    ${nguplane_ip}=    Get from List      ${NGU_IP_List}     ${index}
        ${amf_ip}=      Get from List      ${AMF_IP_List}	   ${index}
	    ${xnc_ip}=     Get from List     ${NRADJ_C_IP_List}      ${index2}
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_ul_ipV6
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=sa_call_dl_ipV6
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_handover_request_ipV6
	    Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_handover_ack_ipV6
    END
	[TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop	  alias=operator_${operator}

Delete IP Interface from eth3
    [Arguments]      ${IP_list}
	FOR   ${IP}  IN   @{IP_list}
		Run     sudo ip a delete ${IP} dev eth3
    END