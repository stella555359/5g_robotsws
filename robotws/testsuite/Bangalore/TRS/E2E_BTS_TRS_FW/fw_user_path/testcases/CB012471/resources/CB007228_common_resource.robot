*** Settings ***
Documentation
     ...    [Procedure] "The test case is planned to validate automatic X2, Xn Ipsec tunnel addition & removal by ANR
     ...                  procedure, with same & different ipsec template for dedicated GNB collapsed"
     ...    [Date] "2-07-2022"
     ...    [Author] "Shadab"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Feature_ID] "CB007228"
     ...    [Validation_status] "Validated"
     ...    [Validated_TestLine] "TL006"
     ...    [Commissioning_comment] "This script requires 5G SA configuration with IPSEC Enabled "
Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot
Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot

*** Variables ***
@{xn_multiple_localIpAddress}
@{xn_multiple_remoteIpAddress}
${i}=      0
${xn_outer_ip_remote}       10.0.3.4

***Keywords***
Test run complete
        Run Keyword And Ignore Error    Call Teardown     lte=device1_for_x2_conn:data
        Run         sudo killall egate edaemon

Read parameter values
        ${lte_v4_cplane_ip}=       Get Parameter   param_path=${lte_cplane_v4_moc_path}
        Set Suite Variable       ${lte_v4_cplane_ip}
        ${lte_v6_cplane_ip}=       Get Parameter   param_path=${lte_cplane_v6_moc_path}
        Set Suite Variable       ${lte_v6_cplane_ip}
        ${lte_v4_uplane_ip}=       Get Parameter   param_path=${lte_uplane_v4_moc_path}
        Set Suite Variable       ${lte_v4_uplane_ip}
        ${lte_v6_uplane_ip}=       Get Parameter   param_path=${lte_uplane_v6_moc_path}
        Set Suite Variable       ${lte_v6_uplane_ip}
        ${lte_v4_cplane_ip_neigh}=       Get Parameter   param_path=${lte_cplane_v4_moc_path}     alias=remote
        Set Suite Variable       ${lte_v4_cplane_ip_neigh}
        ${lte_v6_cplane_ip_neigh}=       Get Parameter   param_path=${lte_cplane_v6_moc_path}      alias=remote
        Set Suite Variable       ${lte_v6_cplane_ip_neigh}
        ${lte_v4_uplane_ip_neigh}=     Get Parameter   param_path=${lte_uplane_v4_moc_path}     alias=remote
        Set Suite Variable       ${lte_v4_uplane_ip_neigh}
        ${lte_v6_uplane_ip_neigh}=     Get Parameter   param_path=${lte_uplane_v6_moc_path}       alias=remote
        Set Suite Variable       ${lte_v6_uplane_ip_neigh}
        ${lnmme_v4}=     Get Parameter   param_path=${lnmme_v4_moc_path}
        Set Suite Variable       ${lnmme_v4}
        ${lnmme_v6}=     Get Parameter   param_path=${lnmme_v6_moc_path}
        Set Suite Variable       ${lnmme_v6}

Get Ipsec Tunnels Status
	@{parent_tunnel_moc_list} = 	Query Admin Infomodel		query=get list ${ike_sa_l_moc_path}
	FOR 	${ike_tunnel}	IN 	@{parent_tunnel_moc_list}
		${parent_tunnel_stateInfo}=	Get From Dictionary		dictionary=${ike_tunnel}		key=stateInfo
		${parent_tunnel_proceduralState}=	Get From Dictionary		dictionary=${parent_tunnel_stateInfo}
                ...    key=proceduralState
		Should Be True	'${parent_tunnel_proceduralState}'=='Established'
    END

	@{child_tunnel_moc_list} = 	Query Admin Infomodel		query=get list ${ipsec_sa_l_moc_path}
	FOR 	${child_tunnel}	IN 	@{child_tunnel_moc_list}
		${child_tunnel_stateInfo}=	Get From Dictionary		dictionary=${child_tunnel}		key=stateInfo
		${child_tunnel_proceduralState}=	Get From Dictionary		dictionary=${child_tunnel_stateInfo}
                ...    key=proceduralState
		Should Be True	'${child_tunnel_proceduralState}'=='Installed'
    END

Verify Calls
#	[Arguments]		${alias_suffix}

      Block       operation=Cell       rat=LTE
      Sleep   120
      Unblock     operation=Cell       rat=LTE
      Traffic Capture Start        capture_device=oam_device    mode=file              measurement_point=Transport_Interface
      ...    uplane_capturing=True        timeout=120            alias=pointA
      Make Call For x2 connection
      ${capture_X2_Conn}=       Traffic Capture Stop    capture_device=oam_device    mode=file     timeout=180     alias=pointA
      Set Suite Variable       ${capture_X2_Conn}

Verify Calls for IPSEC
#	[Arguments]		${alias_suffix}

      Block       operation=Cell       rat=LTE
      Sleep   120
      Unblock     operation=Cell       rat=LTE
      Sleep   400
      Traffic Capture Start     capture_device=oam_device        mode=file       measurement_point=NE_Terminated
      ...    uplane_capturing=True       timeout=300     alias=pointA
      Traffic Capture Start    capture_device=lmp_pc_all_interface     timeout=180       alias=lmp_capture
      Make Call For x2 connection
      ${capture_X2_Conn}=       Traffic Capture Stop    capture_device=oam_device    mode=file     timeout=300     alias=pointA
      ${capture_X2_Conn}=        Traffic Capture Stop    capture_device=lmp_pc_all_interface     timeout=180     alias=lmp_capture
      Set Suite Variable       ${capture_X2_Conn}
      Sleep    300

Make Call For x2 connection
        Call Setup     lte=device1_for_x2_conn:data    parallel=${False}    attach=${False}      verify_attach=${false}    timeout=600
        Sleep   80
        Block       operation=Cell       rat=LTE
        Sleep   60
        Unblock     operation=Cell       rat=LTE
        Sleep   10
#        Configure UE       lte=device1_for_x2_conn:data     command=ue_detach id=1
#        Sleep   10
        Configure UE       lte=device1_for_x2_conn:data     command=ue_rrc_reconf_param id=1 if_contains=purpose with_value=reportStrongestCells
        ...    action=measurement_send phycell_id=13 nrsrp=97 nrsrq=34 earfcn=43000 strongest=eutra son=true ecgi=311:489|0x7CB0B tac=124
        Sleep   10
        Configure UE       lte=device1_for_x2_conn:data       command=ue_attach id=1 cell=11
        Sleep   10
        Configure UE       lte=device1_for_x2_conn:data       command=ue_measurement_send id=1 event=A3 srsrp=60 srsrq=15 phycell_id=13
        ...    nrsrp=90 nrsrq=34
        Sleep   250

Analyse Pcap SON Transport Messages
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_s1ap_ENB_Configuration_Transfer
        ...    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_s1ap_MME_Configuration_Transfer
        ...    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_X2ap_Setup_request    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_X2ap_Setup_responce    filter_file_name=${traffic_filter_file_name}

Analyse Pcap SON Transport Messages After FAF
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_s1ap_ENB_Configuration_Transfer
        ...    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_s1ap_MME_Configuration_Transfer_after_faf
        ...    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_X2ap_Setup_request_FAF    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_X2ap_Setup_responce_FAF    filter_file_name=${traffic_filter_file_name}

Analyse Pcap SON Transport Messages For Dualstack Disabled
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_s1ap_ENB_Configuration_Transfer_neigh_dualstack_disable
        ...    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_s1ap_MME_Configuration_Transfer_neigh_dualstack_disable
        ...    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_X2ap_Setup_request_FAF    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_X2ap_Setup_request_FAF    filter_file_name=${traffic_filter_file_name}

Analyse Pcap SON Transport Messages 3US
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_s1ap_ENB_Configuration_Transfer
        ...    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_s1ap_MME_Configuration_Transfer
        ...    filter_file_name=${traffic_filter_file_name}
#        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_X2ap_Setup_request_3us    filter_file_name=${traffic_filter_file_name}
#        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_X2ap_Setup_responce_3us    filter_file_name=${traffic_filter_file_name}

Analyse Pcap SON Transport Messages for IPV6
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_s1ap_ENB_Configuration_Transfer
        ...    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_s1ap_MME_Configuration_Transfer_IPV6
        ...    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_X2ap_Setup_request    filter_file_name=${traffic_filter_file_name}
        Analyse Pcap    pcap_filename=${capture_X2_Conn}   analysis=verify_X2ap_Setup_responce    filter_file_name=${traffic_filter_file_name}

Analyse Pcap for IPSECTLA Messages
        Analyse Pcap    pcap_filename=${ipsec_capture}   analysis=verify_IPSECTLA_after_FAF    filter_file_name=${traffic_filter_file_name}

Check X2 Link Available
	${x2link_status_moc}=	Query Admin Infomodel		query=get object ${x2_link_moc}
	Log   	${xnlink_status_moc}
	${xnlink_status}=	Get From Dictionary	    ${xnlink_status_moc}	xnLinkStatus
	Should Be Equal	${xnlink_status}	available
    Log to console     Xn Link Is Available

Get xn Mesh Tunnel Details
#   @{trafficSelectorList_content}=     Get From Dictionary     dictionary=${secpol_a_moc_path}        key=trafficSelectorList
#	:FOR    ${trafficSelectorItem}  IN  @{trafficSelectorList_content}
#    \   ${secpol_moc} = 	Query Admin Infomodel		query=get object ${secpol_a_moc_path}:localIpAddr       alias=remote
#    \   Should Be True  '${secpol_a_moc_path}'=='${xn_remote_ip}'
    ${secpol_moc} = 	Query Admin Infomodel		query=get object ${secpol_a_moc_path} is
    ...     [trafficSelectorList[?].remoteIpAddress=${xncplane_inner_ip_remote}]
#    ${secpol_moc} =    Query Admin Infomodel       query=get object ${secpol_a_moc_path} is [trafficSelectorList[?].remoteIpAddress=10.0.3.3
   	@{trafficSelectorList_content}=		Get From Dictionary		dictionary=${secpol_moc}	key=trafficSelectorList

	FOR 	${trafficSelectorItem}	IN 	@{trafficSelectorList_content}
		${x2_localIpAddress}=	Get From Dictionary		dictionary=${trafficSelectorItem}		key=localIpAddress
        Set Suite Variable       ${x2_localIpAddress}
       ${policy_anchor}=   Get From Dictionary     dictionary=${trafficSelectorItem}       key=policyAnchor     ###check its gnb controlled
#       Should Not Be Empty         ${policy_anchor}
		Append To List	${xn_multiple_localIpAddress}    ${x2_localIpAddress}
		${remoteIpAddress}=	Get From Dictionary		dictionary=${trafficSelectorItem}		key=remoteIpAddress
       Set Suite Variable       ${remoteIpAddress}
		Append To List	${xn_multiple_remoteIpAddress}    ${remoteIpAddress}
    END
	Set Suite Variable 	${xn_multiple_localIpAddress} 		${xn_multiple_localIpAddress}
	Set Suite Variable 	${xn_multiple_remoteIpAddress} 		${xn_multiple_remoteIpAddress}

	${ikePDN}=	Get From Dictionary		dictionary=${secpol_moc}		key=ikePDN
	${ipSecPDN}=	Get From Dictionary		dictionary=${secpol_moc}		key=ipSecPDN

	${ike_moc} = 	Query Admin Infomodel		query=get object ${ikePDN}
	${localTunnelEndpointDN}=	Get From Dictionary		dictionary=${ike_moc}		key=localTunnelEndpointDN
	${localTunnelEndpoint}=	Get Parameter	param_path=${localTunnelEndpointDN}:localIpAddr
	${remoteTunnelEndpoint}=	Get From Dictionary		dictionary=${ike_moc}		key=remoteTunnelEndpoint
	${ikeEncryptionMethod}=	Get From Dictionary		dictionary=${ike_moc}		key=ikeEncryptionMethod

#	Set Suite Variable 	${x2_localTunnelEndpoint} 		${localTunnelEndpoint}
#	Set Suite Variable 	${x2_remoteTunnelEndpoint} 	${remoteTunnelEndpoint}
#	Set Suite Variable 	${x2_ikeEncryptionMethod} 		${ikeEncryptionMethod}
#	Get Xn Tunnels Status

Get xn Mesh Tunnel Details Neighbour
    ${secpol_moc} =     Query Admin Infomodel       query=get object ${secpol_a_moc_path} is
    ...    [trafficSelectorList[?].localIpAddress=${xncplane_inner_ip_remote}]          alias=remote
#    ${secpol_moc} =     Query Admin Infomodel       query=get object ${secpol_a_moc_path} is
    ...    [trafficSelectorList[?].localIpAddress=10.0.3.3]          alias=remote
    @{trafficSelectorList_content}=     Get From Dictionary     dictionary=${secpol_moc}        key=trafficSelectorList

    FOR    ${trafficSelectorItem}  IN  @{trafficSelectorList_content}
       ${x2_localIpAddress}=   Get From Dictionary     dictionary=${trafficSelectorItem}       key=localIpAddress
       Set Suite Variable       ${x2_localIpAddress}
       Append To List  ${xn_multiple_localIpAddress}    ${x2_localIpAddress}
       ${remoteIpAddress}=     Get From Dictionary     dictionary=${trafficSelectorItem}       key=remoteIpAddress
       Set Suite Variable       ${remoteIpAddress}
       Append To List  ${xn_multiple_remoteIpAddress}    ${remoteIpAddress}
    END
    Set Suite Variable  ${xn_multiple_localIpAddress}       ${xn_multiple_localIpAddress}
    Set Suite Variable  ${xn_multiple_remoteIpAddress}      ${xn_multiple_remoteIpAddress}

    ${ikePDN}=  Get From Dictionary     dictionary=${secpol_moc}        key=ikePDN
    ${ipSecPDN}=    Get From Dictionary     dictionary=${secpol_moc}        key=ipSecPDN

    ${ike_moc} =    Query Admin Infomodel       query=get object ${ikePDN}      alias=remote
    ${localTunnelEndpointDN}=   Get From Dictionary     dictionary=${ike_moc}       key=localTunnelEndpointDN
    ${localTunnelEndpoint}=     Get Parameter   param_path=${localTunnelEndpointDN}:localIpAddr     alias=remote
    ${remoteTunnelEndpoint}=    Get From Dictionary     dictionary=${ike_moc}       key=remoteTunnelEndpoint
    ${ikeEncryptionMethod}=     Get From Dictionary     dictionary=${ike_moc}       key=ikeEncryptionMethod

#    Set Suite Variable  ${x2_localTunnelEndpoint}       ${localTunnelEndpoint}
#    Set Suite Variable  ${x2_remoteTunnelEndpoint}  ${remoteTunnelEndpoint}
#    Set Suite Variable  ${x2_ikeEncryptionMethod}       ${ikeEncryptionMethod}
#    Get Xn Tunnels Status     remote

Get xn Mesh Tunnel Details_org
    ${secpol_moc_DN} =     Query Admin Infomodel       query=get object ${secpol_a_moc_path} is
    ...   [trafficSelectorList[?].remoteIpAddress=${10.0.3.4}]
    Set Suite Variable       ${secpol_moc_DN}
#    ${secpolDN_im_moc_name_temp}=          Replace String Using Regexp     string=${secpol_moc_DN}
    ...     pattern=${pattern_to_replace_in_moc}        replace_with=${EMPTY}
#    @{secpolDN_im_moc_path_splits}=        Split String From Right     string=${secpolDN_im_moc_name_temp}    separator=/
#    ${xn_secpolDN_moc_id}=     Set Variable    @{ikePDN_im_moc_path_splits}[-1]

    @{trafficSelectorList_content}=     Get From Dictionary     dictionary=${secpol_moc_DN}        key=trafficSelectorList

    :FOR    ${trafficSelectorItem}  IN  @{trafficSelectorList_content}
    \   ${x2_localIpAddress}=   Get From Dictionary     dictionary=${trafficSelectorItem}       key=localIpAddress
    \   Set Suite Variable       ${x2_localIpAddress}
    \   ${policy_anchor}=   Get From Dictionary     dictionary=${trafficSelectorItem}       key=policyAnchor     ###check its gnb controlled
    \   Should Not Be Empty         ${policy_anchor}
    \   Append To List  ${xn_multiple_localIpAddress}    ${x2_localIpAddress}
    \   ${remoteIpAddress}=     Get From Dictionary     dictionary=${trafficSelectorItem}       key=remoteIpAddress
    \   Set Suite Variable       ${remoteIpAddress}
    \   Append To List  ${xn_multiple_remoteIpAddress}    ${remoteIpAddress}

    Set Suite Variable  ${xn_multiple_localIpAddress}       ${xn_multiple_localIpAddress}
    Set Suite Variable  ${xn_multiple_remoteIpAddress}      ${xn_multiple_remoteIpAddress}

    ${ikePDN}=  Get From Dictionary     dictionary=${secpol_moc}        key=ikePDN
#    ${ikePDN_im_moc_name_temp}=          Replace String Using Regexp     string=${ikePDN}     pattern=${pattern_to_replace_in_moc}
    ...    replace_with=${EMPTY}
#    @{ikePDN_im_moc_path_splits}=        Split String From Right     string=${ikePDN_im_moc_name_temp}    separator=/
#    ${xn_ikePDN_moc_id}=     Set Variable    @{ikePDN_im_moc_path_splits}[-1]
    ${ipSecPDN}=    Get From Dictionary     dictionary=${secpol_moc}        key=ipSecPDN
#    ${ipSecPDN_im_moc_name_temp}=          Replace String Using Regexp     string=${ipSecPDN}     pattern=${pattern_to_replace_in_moc}
     ...        replace_with=${EMPTY}
#    @{ipSecPDN_im_moc_path_splits}=        Split String From Right     string=${ipSecPDN_im_moc_name_temp}    separator=/
#    ${xn_ipSecPDN_moc_id}=     Set Variable    @{ipSecPDN_im_moc_path_splits}[-1]

    ${ike_moc} =    Query Admin Infomodel       query=get object ${ikePDN}
    ${localTunnelEndpointDN}=   Get From Dictionary     dictionary=${ike_moc}       key=localTunnelEndpointDN
    ${localTunnelEndpoint}=     Get Parameter   param_path=${localTunnelEndpointDN}:localIpAddr
    ${remoteTunnelEndpoint}=    Get From Dictionary     dictionary=${ike_moc}       key=remoteTunnelEndpoint
    ${ikeEncryptionMethod}=     Get From Dictionary     dictionary=${ike_moc}       key=ikeEncryptionMethod

    Set Suite Variable  ${x2_localTunnelEndpoint}       ${localTunnelEndpoint}
    Set Suite Variable  ${x2_remoteTunnelEndpoint}  ${remoteTunnelEndpoint}
    Set Suite Variable  ${x2_ikeEncryptionMethod}       ${ikeEncryptionMethod}

    Get Xn Tunnels Status

Get xn Mesh Tunnel Details Neighbour org
    ${secpol_moc_DN_neigh} =     Query Admin Infomodel       query=get object ${secpol_a_moc_path} is
    ...    [trafficSelectorList[?].localIpAddress=${xncplane_inner_ip_remote}]          alias=remote
    Set Suite Variable       ${secpol_moc_DN_neigh}
    ${secpolDN_im_moc_name_temp_neigh}=          Replace String Using Regexp     string=${secpol_moc_DN_neigh}
    ...    pattern=${pattern_to_replace_in_moc}        replace_with=${EMPTY}
    @{secpolDN_im_moc_path_splits_neigh}=        Split String From Right     string=${secpolDN_im_moc_name_temp_neigh}    separator=/
    ${xn_secpolDN_moc_id_neigh}=     Set Variable    @{ikePDN_im_moc_path_splits_neigh}[-1]

    @{trafficSelectorList_content}=     Get From Dictionary     dictionary=${secpol_moc_DN_neigh}        key=trafficSelectorList

    :FOR    ${trafficSelectorItem}  IN  @{trafficSelectorList_content}
    \   ${x2_localIpAddress}=   Get From Dictionary     dictionary=${trafficSelectorItem}       key=localIpAddress
    \   Set Suite Variable       ${x2_localIpAddress}
    \   Append To List  ${xn_multiple_localIpAddress}    ${x2_localIpAddress}
    \   ${remoteIpAddress}=     Get From Dictionary     dictionary=${trafficSelectorItem}       key=remoteIpAddress
    \   Set Suite Variable       ${remoteIpAddress}
    \   Append To List  ${xn_multiple_remoteIpAddress}    ${remoteIpAddress}

    Set Suite Variable  ${xn_multiple_localIpAddress}       ${xn_multiple_localIpAddress}
    Set Suite Variable  ${xn_multiple_remoteIpAddress}      ${xn_multiple_remoteIpAddress}

    ${ikePDN}=  Get From Dictionary     dictionary=${secpol_moc}        key=ikePDN
    ${ikePDN_im_moc_name_temp_neigh}=          Replace String Using Regexp     string=${ikePDN}     pattern=${pattern_to_replace_in_moc}
    ...    replace_with=${EMPTY}
    @{ikePDN_im_moc_path_splits_neigh}=        Split String From Right     string=${ikePDN_im_moc_name_temp_neigh}    separator=/
    ${xn_ikePDN_moc_id_neigh}=     Set Variable    @{ikePDN_im_moc_path_splits_neigh}[-1]
    ${ipSecPDN}=    Get From Dictionary     dictionary=${secpol_moc}        key=ipSecPDN
    ${ipSecPDN_im_moc_name_temp_neigh}=          Replace String Using Regexp     string=${ipSecPDN}     pattern=${pattern_to_replace_in_moc}
    ...    replace_with=${EMPTY}
    @{ipSecPDN_im_moc_path_splits_neigh}=        Split String From Right     string=${ipSecPDN_im_moc_name_temp}    separator=/
    ${xn_ipSecPDN_moc_id_neigh}=     Set Variable    @{ipSecPDN_im_moc_path_splits_neigh}[-1]

    ${ipSecPDN}=    Get From Dictionary     dictionary=${secpol_moc}        key=ipSecPDN

    ${ike_moc} =    Query Admin Infomodel       query=get object ${ikePDN}      alias=remote
    ${localTunnelEndpointDN}=   Get From Dictionary     dictionary=${ike_moc}       key=localTunnelEndpointDN
    ${localTunnelEndpoint}=     Get Parameter   param_path=${localTunnelEndpointDN}:localIpAddr     alias=remote
    ${remoteTunnelEndpoint}=    Get From Dictionary     dictionary=${ike_moc}       key=remoteTunnelEndpoint
    ${ikeEncryptionMethod}=     Get From Dictionary     dictionary=${ike_moc}       key=ikeEncryptionMethod

    Set Suite Variable  ${x2_localTunnelEndpoint}       ${localTunnelEndpoint}
    Set Suite Variable  ${x2_remoteTunnelEndpoint}  ${remoteTunnelEndpoint}
    Set Suite Variable  ${x2_ikeEncryptionMethod}       ${ikeEncryptionMethod}

    Get Xn Tunnels Status     remote

Verify X2 Link Status
    [Arguments]     ${alias}=default
    @{lnadj_moc_list} =     Query Admin Infomodel       query=get list ${lnadj_moc_path}       timeout=30    alias=${alias}
    FOR    ${lnadj_moc}    IN  @{lnadj_moc_list}
       ${x2_target_cplane_ip}=     Get From Dictionary     dictionary=${lnadj_moc}     key=cPlaneIpAddr
       ${x2_link_status}=     Get From Dictionary     dictionary=${lnadj_moc}     key=x2LinkStatus
       Should Be Equal      ${x2_link_status}    available
       Log to console     X2 Link Is Available
#       Should Be True       '${x2_target_cplane_ip}'=='fc01::2' OR '${x2_target_cplane_ip}'=='fc00::2'
       Run Keyword If    '${alias}' == 'default'
        ...    Should Be True       '${x2_target_cplane_ip}' == 'fc01::2'       alias=${alias}
        ...    ELSE IF    '${alias}' == 'remote'
        ...     Should Be True      '${x2_target_cplane_ip}' == 'fc00::2'       alias=${alias}
#        ...    ELSE IF    '${alias}' == 'default'
#        ...     Should Be True      '${x2_target_cplane_ip}' == '10.0.1.2'      alias=${alias}
#        ...    ELSE IF    '${alias}' == 'remote'
#        ...     Should Be True      '${x2_target_cplane_ip}' == '10.0.7.2'       alias=${alias}
#        ELSE    '${x2_target_cplane_ip}'=='10.0.7.2'
    END

Verify X2 Link Status after FAF
    [Arguments]     ${alias}=default
    @{lnadj_moc_list} =     Query Admin Infomodel       query=get list ${lnadj_moc_path}       timeout=30    alias=${alias}
    FOR    ${lnadj_moc}    IN  @{lnadj_moc_list}
       ${x2_target_cplane_ip}=     Get From Dictionary     dictionary=${lnadj_moc}     key=cPlaneIpAddr
       ${x2_link_status}=     Get From Dictionary     dictionary=${lnadj_moc}     key=x2LinkStatus
       Should Be Equal      ${x2_link_status}    available
       Log to console     X2 Link Is Available
       Run Keyword If    '${alias}' == 'default'
       ...     Should Be True      '${x2_target_cplane_ip}' == '10.0.7.2'      alias=${alias}
       ...    ELSE IF    '${alias}' == 'remote'
        ...     Should Be True      '${x2_target_cplane_ip}' == '10.0.1.2'       alias=${alias}
    END

Trigger Xnlink Breakdown
        Perform Recommissioning        type=delta      delta_file=tmp_CB7228_delta_xnlink_breakdown.xml     timeout=600
        ...    skip_parameter_relation_errors=${True}
        Sleep   200
        Verify Xn Link Status For Removal
#        Verify Xn Link Status For Removal     remote

Verifying xn Mesh Deletion
        Removal Of Xn Tunnels In Src
        Removal Of Xn Tunnels In Neighbour

Removal Of Xn Tunnels In Src
        Run Keyword and Expect Error       *${expected_error}*       Query Admin Infomodel     query=get object ${xn_ikePDN_moc_id}
        Run Keyword and Expect Error       *${expected_error}*       Query Admin Infomodel     query=get object ${xn_ipSecPDN_moc_id}
        Run Keyword and Expect Error       *${expected_error}*       Query Admin Infomodel     query=get object ${xn_secpolDN_moc_id}

Removal Of Xn Tunnels In Neighbour
         Run Keyword and Expect Error       *${expected_error}*       Query Admin Infomodel     query=get object ${xn_ikePDN_moc_id_remote}
         ...     alias=remote
        Run Keyword and Expect Error       *${expected_error}*       Query Admin Infomodel     query=get object ${xn_ipSecPDN_moc_id_remote}
        ...    alias=remote
        Run Keyword and Expect Error       *${expected_error}*       Query Admin Infomodel     query=get object ${xn_secpolDN_moc_id_remote}
        ...    alias=remote

Verify X2 Link Status unavailable
    [Arguments]     ${alias}=default
    @{lnadj_moc_list} =     Query Admin Infomodel       query=get list ${lnadj_moc_path}       timeout=30    alias=${alias}
    FOR    ${lnadj_moc}    IN  @{lnadj_moc_list}
       ${x2_target_cplane_ip}=     Get From Dictionary     dictionary=${lnadj_moc}     key=cPlaneIpAddr
       ${x2_link_status}=     Get From Dictionary     dictionary=${lnadj_moc}     key=x2LinkStatus
       Should Be Equal      ${x2_link_status}    unavailable
    END