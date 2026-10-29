*** Settings ***
Documentation	This is a common keyword repository for OAM operations.

*** Keywords ***

Read 5G IPv4 IPv6 Mplane Parameters
	[Arguments]		${alias}=default
	${5g_type}= 	Get Parameter		rat=5g		param_path=${5g_gnbcutype}	alias=${alias}
	Run Keyword If		'NSA' == '${5g_type}'		Read 5G NSA IPv4 IPv6 Mplane Parameters	alias=${alias}
	Set Suite Variable		${5g_type}		${5g_type}

Read 5G IPv4 IPv6 Parameters
	[Arguments]		${alias}=default
	${5g_type}= 	Get Parameter		rat=5g		param_path=${5g_gnbcutype}	alias=${alias}
	Run Keyword If		'NSA' == '${5g_type}'		Read 5G NSA IPv4 IPv6 Parameters	alias=${alias}
	Run Keyword If		'SA' == '${5g_type}'		Read 5G SA IPv4 IPv6 Parameters		alias=${alias}
	Set Suite Variable		${5g_type}		${5g_type}

Read 5G IPv4 Parameters
	[Arguments]		${alias}=default
	${5g_type}= 	Get Parameter		rat=5g		param_path=${5g_gnbcutype}		alias=${alias}
	Run Keyword If		'NSA' == '${5g_type}'		Read 5G NSA IPv4 Parameters		alias=${alias}
	Run Keyword If		'SA' == '${5g_type}'		Read 5G SA IPv4 Parameters		alias=${alias}
	Set Suite Variable		${5g_type}		${5g_type}

Read 5G IPv6 Parameters
	[Arguments]		${alias}=default
	${5g_type}= 	Get Parameter		rat=5g		param_path=${5g_gnbcutype}		alias=${alias}
	Run Keyword If		'NSA' == '${5g_type}'		Read 5G NSA IPv6 Parameters		alias=${alias}
	Run Keyword If		'SA' == '${5g_type}'		Read 5G SA IPv6 Parameters		alias=${alias}
	Set Suite Variable		${5g_type}		${5g_type}

Read 5G NSA IPv4 IPv6 Mplane Parameters
	[Arguments]		${alias}=default
	Read 5G NSA IPv4 Mplane Parameters		alias=${alias}
	Read 5G NSA IPv6 Mplane Parameters		alias=${alias}

Read 5G NSA IPv4 IPv6 Parameters
	[Arguments]		${alias}=default
	Read 5G NSA IPv4 Parameters		alias=${alias}
	Read 5G NSA IPv6 Parameters		alias=${alias}

Read 5G SA IPv4 IPv6 Parameters
	[Arguments]		${alias}=default
	Read 5G SA IPv4 Parameters		alias=${alias}
	Read 5G SA IPv6 Parameters		alias=${alias}

Read LTE IPv4 IPv6 Parameters
	[Arguments]		${alias}=default
	Read LTE IPv4 Parameters		alias=${alias}
	Read LTE IPv6 Parameters		alias=${alias}

Read WCDMA IPv4 IPv6 Parameters
	[Arguments]		${alias}=default
	Read WCDMA IPv4 Parameters		alias=${alias}
	Read WCDMA IPv6 Parameters		alias=${alias}

Read GSM IPv4 IPv6 Parameters
	[Arguments]		${alias}=default
	Read GSM IPv4 Parameters		alias=${alias}
	Read GSM IPv6 Parameters		alias=${alias}

Read 5G NSA IPv4 Mplane Parameters
    [Arguments]     ${alias}=default
    ${5g_mplane1_ipv4}=     Get Parameter       rat=5g      param_path=${5g_nsa_mplane1_ipv4_moc_path}      alias=${alias}
    Set Suite Variable      ${5g_mplane1_ipv4}      ${5g_mplane1_ipv4}

Read 5G NSA IPv4 Parameters
	[Documentation]		This keyword reads the configured value for 5G NSA IPv4 UC Plane.
	[Arguments]		${alias}=default

	${5g_cplane1_ipv4}= 	Get Parameter		rat=5g		param_path=${5g_nsa_cplane1_ipv4_moc_path}		alias=${alias}
	${5g_uplane1_ipv4}= 	Get Parameter		rat=5g		param_path=${5g_nsa_uplane1_ipv4_moc_path}		alias=${alias}

	${5g_nsa_xnlink_cplane_ipv4}=	Query Admin Infomodel	query=get param ${5g_nsa_xnlink_cplane_ipv4_moc_path}		alias=${alias}
	${xnlink_cplane_ipv4_list}=	Get Dictionary Values	${5g_nsa_xnlink_cplane_ipv4}

	FOR	${xnlink_cplane_ipv4_dict}	IN	@{xnlink_cplane_ipv4_list}
		${xnlink_cplane_ipv4}=		Get Dictionary Values	${xnlink_cplane_ipv4_dict}
		@{xnlink_cp_ipv4_list}=		Convert To List		@{xnlink_cplane_ipv4}[0]
		${xnlink_cplane_ipv4_0}=	Set Variable If		'.' in @{xnlink_cp_ipv4_list}		@{xnlink_cplane_ipv4}[0]
		Exit For Loop If    '${xnlink_cplane_ipv4_0}'!='None'
	END


	Set Suite Variable		${5g_cplane1_ipv4}		${5g_cplane1_ipv4}
	Set Suite Variable		${xnlink_cplane_ipv4_0}			${xnlink_cplane_ipv4_0}
	Set Suite Variable		${5g_uplane1_ipv4}		${5g_uplane1_ipv4}

Read 5G SA IPv4 Parameters
	[Documentation]		This keyword reads the configured value for 5G SA IPv4 UC Plane.
	[Arguments]		${alias}=default

	${5g_cplane1_ipv4}= 	Get Parameter		rat=5g		param_path=${5g_sa_cplane1_ipv4_moc_path}		alias=${alias}
	${5g_uplane1_ipv4}= 	Get Parameter		rat=5g		param_path=${5g_sa_uplane1_ipv4_moc_path}		alias=${alias}

	${5g_sa_amf_ipv4}=	Query Admin Infomodel	query=get param ${5g_sa_amf_ipv4_moc_path}		alias=${alias}
	${amf_ipv4_list}=	Get Dictionary Values	${5g_sa_amf_ipv4}

	FOR	${amf_ipv4_dict}	IN	@{amf_ipv4_list}
		${amf_ipv4}=		Get Dictionary Values	${amf_ipv4_dict}
		@{amf_ipv4_ip_list}=		Convert To List		@{amf_ipv4}[0]
		${amf_ipv4_0}=	Set Variable If		'.' in @{amf_ipv4_ip_list}		@{amf_ipv4}[0]
		Exit For Loop If    '${amf_ipv4_0}'!='None'
	END

	Set Suite Variable		${5g_cplane1_ipv4}		${5g_cplane1_ipv4}
	Set Suite Variable		${amf_ipv4_0}			${amf_ipv4_0}
	Set Suite Variable		${5g_uplane1_ipv4}		${5g_uplane1_ipv4}

Read LTE IPv4 Parameters
	[Documentation]		This keyword reads the configured value for LTE IPv4 UC Plane.
	[Arguments]		${alias}=default

	${lte_cplane1_ipv4}= 	Get Parameter		rat=lte			param_path=${lte_cplane1_ipv4_moc_path}		alias=${alias}
	${mme_ipv4_0}= 			Get Parameter		rat=lte			param_path=${lte_mme_ipv4_moc_path}		alias=${alias}
	${lte_uplane1_ipv4}= 	Get Parameter		rat=lte			param_path=${lte_uplane1_ipv4_moc_path}		alias=${alias}

	Set Suite Variable		${lte_cplane1_ipv4}	${lte_cplane1_ipv4}
	Set Suite Variable		${mme_ipv4_0}		${mme_ipv4_0}
	Set Suite Variable		${lte_uplane1_ipv4}	${lte_uplane1_ipv4}

Read WCDMA IPv4 Parameters
	[Documentation]		This keyword reads the configured value for WCDMA IPv4 UC Plane.
	[Arguments]		${alias}=default

	${wcdma_cplane1_ipv4}= 	Get Parameter		rat=wcdma		param_path=${wcdma_cplane1_ipv4_moc_path}		alias=${alias}
	${rnc_ip_dict} = 		Query Admin Infomodel	query=get object ${wcdma_rnc_ipv4_moc_path}		alias=${alias}
	${rnc_ipv4}=			Get From Dictionary	dictionary=${rnc_ip_dict}		key=ipAddress
	${wcdma_uplane1_ipv4}= 	Get Parameter		rat=wcdma		param_path=${wcdma_uplane1_ipv4_moc_path}		alias=${alias}

	Set Suite Variable		${wcdma_cplane1_ipv4}		${wcdma_cplane1_ipv4}
	Set Suite Variable		${rnc_ipv4}			${rnc_ipv4}
	Set Suite Variable		${wcdma_uplane1_ipv4}		${wcdma_uplane1_ipv4}

Read GSM IPv4 Parameters
	[Documentation]		This keyword reads the configured value for GSM IPv4 UC Plane.
	[Arguments]		${alias}=default

	${gsm_cplane1_ipv4}=	Get Parameter		rat=gsm		param_path=${gsm_cplane1_ipv4_moc_path}		alias=${alias}
	${bsc_ipv4}=			Get Parameter		rat=gsm		param_path=${gsm_bsc_ipv4_moc_path}		alias=${alias}
	${gsm_uplane1_ipv4}=	Get Parameter		rat=gsm		param_path=${gsm_uplane1_ipv4_moc_path}		alias=${alias}

	Set Suite Variable		${gsm_cplane1_ipv4}		${gsm_cplane1_ipv4}
	Set Suite Variable		${bsc_ipv4}			${bsc_ipv4}
	Set Suite Variable		${gsm_uplane1_ipv4}		${gsm_uplane1_ipv4}

Read 5G NSA IPv6 Mplane Parameters
    [Arguments]     ${alias}=default
    ${5g_mplane1_ipv6}=     Get Parameter       rat=5g      param_path=${5g_nsa_mplane1_ipv6_moc_path}      alias=${alias}
    Set Suite Variable      ${5g_mplane1_ipv6}      ${5g_mplane1_ipv6}

Read 5G NSA IPv6 Parameters
	[Documentation]		This keyword reads the configured value for 5G NSA IPv6 UC Plane.
	[Arguments]		${alias}=default

	${5g_cplane1_ipv6}= 	Get Parameter		rat=5g		param_path=${5g_nsa_cplane1_ipv6_moc_path}		alias=${alias}
	${5g_uplane1_ipv6}= 	Get Parameter		rat=5g		param_path=${5g_nsa_uplane1_ipv6_moc_path}		alias=${alias}

	${5g_nsa_xnlink_cplane_ipv6}=	Query Admin Infomodel	query=get param ${5g_nsa_xnlink_cplane_ipv6_moc_path}		alias=${alias}
	${xnlink_cplane_ipv6_list}=	Get Dictionary Values	${5g_nsa_xnlink_cplane_ipv6}

	FOR	${xnlink_cplane_ipv6_dict}	IN	@{xnlink_cplane_ipv6_list}
		${xnlink_cplane_ipv6}=		Get Dictionary Values	${xnlink_cplane_ipv6_dict}
		@{xnlink_cp_ipv6_list}=		Convert To List		@{xnlink_cplane_ipv6}[0]
		${xnlink_cplane_ipv6_0}=	Set Variable If		':' in @{xnlink_cp_ipv6_list}		@{xnlink_cplane_ipv6}[0]
		Exit For Loop If    '${xnlink_cplane_ipv6_0}'!='None'
	END

	Set Suite Variable		${5g_uplane1_ipv6}		${5g_uplane1_ipv6}
	Set Suite Variable		${xnlink_cplane_ipv6_0}			${xnlink_cplane_ipv6_0}
	Set Suite Variable		${5g_cplane1_ipv6}		${5g_cplane1_ipv6}

Read 5G SA IPv6 Parameters
	[Documentation]		This keyword reads the configured value for 5G SA IPv6 UC Plane.
	[Arguments]		${alias}=default

	${5g_cplane1_ipv6}= 	Get Parameter		rat=5g		param_path=${5g_sa_cplane1_ipv6_moc_path}		alias=${alias}
#	${amf_ipv6_0}=			Get Parameter		rat=5g		param_path=${5g_sa_amf_ipv6_moc_path}
	${5g_uplane1_ipv6}= 	Get Parameter		rat=5g		param_path=${5g_sa_uplane1_ipv6_moc_path}		alias=${alias}

	${5g_sa_amf_ipv6}=	Query Admin Infomodel	query=get param ${5g_sa_amf_ipv6_moc_path}		alias=${alias}
	${amf_ipv6_list}=	Get Dictionary Values	${5g_sa_amf_ipv6}

	FOR	${amf_ipv6_dict}	IN	@{amf_ipv6_list}
		${amf_ipv6}=		Get Dictionary Values	${amf_ipv6_dict}
		@{amf_ipv6_ip_list}=		Convert To List		@{amf_ipv6}[0]
		${amf_ipv6_0}=	Set Variable If		':' in @{amf_ipv6_ip_list}		@{amf_ipv6}[0]
		Exit For Loop If    '${amf_ipv6_0}'!='None'
	END

	Set Suite Variable		${5g_uplane1_ipv6}		${5g_uplane1_ipv6}
	Set Suite Variable		${amf_ipv6_0}			${amf_ipv6_0}
	Set Suite Variable		${5g_cplane1_ipv6}		${5g_cplane1_ipv6}

Read LTE IPv6 Parameters
	[Documentation]		This keyword reads the configured value for LTE IPv6 UC Plane.
	[Arguments]		${alias}=default

	${lte_cplane1_ipv6}= 	Get Parameter		rat=lte			param_path=${lte_cplane1_ipv6_moc_path}		alias=${alias}
	${mme_ipv6_0}= 			Get Parameter		rat=lte			param_path=${lte_mme_ipv6_moc_path}		alias=${alias}
	${lte_uplane1_ipv6}= 	Get Parameter		rat=lte			param_path=${lte_uplane1_ipv6_moc_path}		alias=${alias}

	Set Suite Variable		${lte_cplane1_ipv6}	${lte_cplane1_ipv6}
	Set Suite Variable		${mme_ipv6_0}		${mme_ipv6_0}
	Set Suite Variable		${lte_uplane1_ipv6}	${lte_uplane1_ipv6}

Read WCDMA IPv6 Parameters
	[Documentation]		This keyword reads the configured value for WCDMA IPv6 UC Plane.
	[Arguments]		${alias}=default

	${wcdma_cplane1_ipv6}= 	Get Parameter		rat=wcdma		param_path=${wcdma_cplane1_ipv6_moc_path}		alias=${alias}
	${rnc_ip_dict} = 		Query Admin Infomodel	query=get object ${wcdma_rnc_ipv6_moc_path}		alias=${alias}
	${rnc_ipv6}=			Get From Dictionary	dictionary=${rnc_ip_dict}		key=ipAddressV6
	${wcdma_uplane1_ipv6}= 	Get Parameter		rat=wcdma		param_path=${wcdma_uplane1_ipv6_moc_path}		alias=${alias}

	Set Suite Variable		${wcdma_cplane1_ipv6}		${wcdma_cplane1_ipv6}
	Set Suite Variable		${rnc_ipv6}			${rnc_ipv6}
	Set Suite Variable		${wcdma_uplane1_ipv6}		${wcdma_uplane1_ipv6}

Read GSM IPv6 Parameters
	[Documentation]		This keyword reads the configured value for GSM IPv6 UC Plane.
	[Arguments]		${alias}=default

	${gsm_cplane1_ipv6}=	Get Parameter		rat=gsm		param_path=${gsm_cplane1_ipv6_moc_path}		alias=${alias}
	${bsc_ipv6}=			Get Parameter		rat=gsm		param_path=${gsm_bsc_ipv6_moc_path}		alias=${alias}
	${gsm_uplane1_ipv6}=	Get Parameter		rat=gsm		param_path=${gsm_uplane1_ipv6_moc_path}		alias=${alias}

	Set Suite Variable		${gsm_cplane1_ipv6}		${gsm_cplane1_ipv6}
	Set Suite Variable		${bsc_ipv6}			${bsc_ipv6}
	Set Suite Variable		${gsm_uplane1_ipv6}		${gsm_uplane1_ipv6}
