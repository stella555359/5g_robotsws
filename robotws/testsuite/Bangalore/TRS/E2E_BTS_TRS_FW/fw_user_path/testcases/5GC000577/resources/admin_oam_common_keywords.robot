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

Get 5G SCTP Status IPV4
	[Documentation]		This keyword checks the SCTP Status for 5G
	[Arguments]		${alias}=default    ${status}=status
	${5g_type}= 	Get Parameter		rat=5g		param_path=${5g_gnbcutype}	alias=${alias}
	Run Keyword If		'NSA' == '${5g_type}'		Get 5G NSA NG-C Status IPV4 	alias=${alias}    status=${status}
	Run Keyword If		'SA' == '${5g_type}'		Get 5G SA NG-C Status IPV4	alias=${alias}    status=${status}
	Set Suite Variable		${5g_type}		${5g_type}

Get 5G SCTP Status IPV6
	[Documentation]		This keyword checks the SCTP Status for 5G
	[Arguments]		${alias}=default    ${status}=status
	${5g_type}= 	Get Parameter		rat=5g		param_path=${5g_gnbcutype}	alias=${alias}
	Run Keyword If		'NSA' == '${5g_type}'		Get 5G NSA NG-C Status IPV6 	alias=${alias}    status=${status}
	Run Keyword If		'SA' == '${5g_type}'		Get 5G SA NG-C Status IPV6	alias=${alias}    status=${status}
	Set Suite Variable		${5g_type}		${5g_type}

Get MME Status IPV4
	[Documentation]		This keyword reads the value for MME status for IPV4 addresses
	[Arguments]    ${status}=status    ${count}=count
	:FOR	${mme_index}	IN RANGE    0    ${count}
	\   Continue For Loop If		':' in "//LNMME_A-"${mme_index}":ipAddrPrim or ':' in "//LNMME_A-"${mme_index}":ipAddrSec"
    \   ${state}=            Query Admin Infomodel query=get param "//LNMME_A-"${mme_index}":s1LinkStatus"
    \   Exit For Loop If    "//LNMME_A-"${mme_index}":ipAddrPrim"!='None and "//LNMME_A-"${mme_index}":ipAddrSec"!='None
    \   Run Keyword If    'pass' in ${status}    Should be equal     ${state}        available
    \   Run Keyword If    'fail' in ${status}    Should be equal     ${state}        unavailable

Get MME Status IPV6
	[Documentation]		This keyword reads the value for MME status for IPV6 addresses
	[Arguments]    ${status}=status    ${count}=count
	:FOR	${mme_index}	IN RANGE    0    ${count}
	\   Continue For Loop If		'.' in "//LNMME_A-"${mme_index}":ipAddrPrim or '.' in "//LNMME_A-"${mme_index}":ipAddrSec"
    \   ${state}=            Query Admin Infomodel query=get param "//LNMME_A-"${mme_index}":s1LinkStatus"
    \   Exit For Loop If    "//LNMME_A-"${mme_index}":ipAddrPrim"!='None and "//LNMME_A-"${mme_index}":ipAddrSec"!='None
    \   Run Keyword If    'pass' in ${status}    Should be equal     ${state}        available
    \   Run Keyword If    'fail' in ${status}    Should be equal     ${state}        unavailable

Get ADJ_ENB Status IPV4
	[Documentation]		This keyword reads the value for adjacent eNB status for IPV4 addresses
	[Arguments]    ${status}=status    ${count}=count
	:FOR	${adj_enb_index}	IN RANGE    0    ${count}
	\   Continue For Loop If		':' in "//LNADJ_A-"${adj_enb_index}":cPlaneIpAddr
    \   ${state}=            Query Admin Infomodel query=get param "//LNADJ_A-"${adj_enb_index}":x2LinkStatus"
    \   Exit For Loop If    "//LNADJ_A-"${adj_enb_index}":cPlaneIpAddr"!='None
    \   Run Keyword If     'pass' in ${status}    Should be equal     ${state}        available
    \   Run Keyword If     'fail' in ${status}    Should be equal     ${state}        unavailable

Get ADJ_ENB Status IPV6
	[Documentation]		This keyword reads the value for adjacent eNB status for IPV6 addresses
	[Arguments]    ${status}=status    ${count}=count
	:FOR	${adj_enb_index}	IN RANGE    0    ${count}
	\   Continue For Loop If		'.' in "//LNADJ_A-"${adj_enb_index}":cPlaneIpAddr
    \   ${state}=            Query Admin Infomodel query=get param "//LNADJ_A-"${adj_enb_index}":x2LinkStatus"
    \   Exit For Loop If    "//LNADJ_A-"${adj_enb_index}":cPlaneIpAddr"!='None
    \   Run Keyword If    'pass' in ${status}    Should be equal     ${state}        available
    \   Run Keyword If    'fail' in ${status}    Should be equal     ${state}        unavailable

Get ADJ_GNB Status IPV4
	[Documentation]		This keyword reads the value for adjacent gNB status for IPV4 addresses
	[Arguments]    ${status}=status    ${count}=count
	:FOR	${adj_enb_index}	IN RANGE    0    ${count}
	\   Continue For Loop If		':' in "//LNADJGNB_A-"${adj_enb_index}":cPlaneIpAddr
    \   ${state}=            Query Admin Infomodel query=get param "//LNADJGNB_A-"${adj_enb_index}":x2ToGnbLinkStatus"
    \   Exit For Loop If    "//LNADJGNB_A-"${adj_enb_index}":cPlaneIpAddr"!='None
    \   Run Keyword If    'pass' in ${status}    Should be equal     ${state}        available
    \   Run Keyword If    'fail' in ${status}    Should be equal     ${state}        unavailable

Get ADJ_GNB Status IPV6
	[Documentation]		This keyword reads the value for adjacent gNB status for IPV4 addresses
	[Arguments]    ${status}=status    ${count}=count
	:FOR	${adj_enb_index}	IN RANGE    0    ${count}
	\   Continue For Loop If		'.' in "//LNADJGNB_A-"${adj_enb_index}":cPlaneIpAddr
    \   ${state}=            Query Admin Infomodel query=get param "//LNADJGNB_A-"${adj_enb_index}":x2ToGnbLinkStatus"
    \   Exit For Loop If    "//LNADJGNB_A-"${adj_enb_index}":cPlaneIpAddr"!='None
    \   Run Keyword If    'pass' in ${status}    Should be equal     ${state}        available
    \   Run Keyword If    'fail' in ${status}    Should be equal     ${state}        unavailable

Get LTE SCTP Status IPV4
	[Documentation]		This keyword checks the SCTP Status for LTE for IPv4 addresses
	[Arguments]		${alias}=default    ${status}=status
	Get MME Status IPV4 	alias=${alias}    status=${status}    count=${mme_count}
	Get ADJ_ENB Status IPV4 	alias=${alias}    status=${status}    count=${adj_enb_count}
	Get ADJ_GNB Status IPV4 	alias=${alias}    status=${status}    count=${adj_gnb_count}

Get WCDMA SCTP Status IPV4
	[Documentation]		This keyword checks the SCTP Status for WCDMA for IPV4 addresses
	[Arguments]    ${status}=status
	Run Keyword If    'pass' in ${status}    Verify Alarm	faultid=${wcdma_failure_alarm}    should_exist=${False}
	Run Keyword If    'fail' in ${status}    Verify Alarm	faultid=${wcdma_failure_alarm}    should_exist=${True}

Get GSM SCTP Status IPV4
	[Documentation]		This keyword checks the SCTP Status for GSM for IPv4 addresses
	[Arguments]    ${status}=status
	Run Keyword If    'pass' in ${status}    Verify Alarm	faultid=${gsm_failure_alarm}    should_exist=${False}
	Run Keyword If    'fail' in ${status}    Verify Alarm	faultid=${gsm_failure_alarm}    should_exist=${True}

Get LTE SCTP Status IPV6
	[Documentation]		This keyword checks the SCTP Status for LTE for IPv6 addresses
	[Arguments]		${alias}=default    ${status}=status
	Get MME Status IPV4 	alias=${alias}    status=${status}    count=${mme_count}
	Get ADJ_ENB Status IPV4 	alias=${alias}    status=${status}    count=${adj_enb_count}
	Get ADJ_GNB Status IPV4    status=${status}    count=${adj_gnb_count}

Get WCDMA SCTP Status IPV6
	[Documentation]		This keyword checks the SCTP Status for WCDMA for IPV6 addresses
	[Arguments]    ${status}=status
	Run Keyword If    'pass' in ${status}    Verify Alarm	faultid=${wcdma_failure_alarm}    should_exist=${False}
	Run Keyword If    'fail' in ${status}    Verify Alarm	faultid=${wcdma_failure_alarm}    should_exist=${True}

Get GSM SCTP Status IPV6
	[Documentation]		This keyword checks the SCTP Status for GSM for IPv6 addresses
	[Arguments]    ${status}=status
	Run Keyword If    'pass' in ${status}    Verify Alarm	faultid=${gsm_failure_alarm}    should_exist=${False}
	Run Keyword If    'fail' in ${status}    Verify Alarm	faultid=${gsm_failure_alarm}    should_exist=${True}

Get 5G X2 Status IPV4
	[Documentation]		This keyword reads the value for 5G X2 status for IPV4 addresses
	[Arguments]
    Log      "Need to implement"

#	:FOR	${5g_nsa_enb_index}	IN RANGE    0    ${count}
#	\   Continue For Loop If		':' in "//LTEENB_A-"${5g_nsa_enb_index}":ipAddr"
#    \   ${state}=            Query Admin Infomodel query=get param "//LTEENB_A-"${5g_nsa_enb_index}":x2LinkStatus"
#    \   Exit For Loop If    "//LTEENB_A-"${5g_nsa_enb_index}":ipAddr"!='None'
#    \   Run Keyword If 'pass' in ${status}    Should be equal     ${state}        available
#    \   Run Keyword If 'fail' in ${status}    Should be equal     ${state}        unavailable

Get 5G XN Status IPV4
	[Documentation]		This keyword reads the value for 5G XN status for IPV4 addresses
	[Arguments]    ${status}=status    ${count}=count
	:FOR	${5g_nsa_gnb_index}	IN RANGE    0    ${count}
	\   Continue For Loop If		':' in "//XNLINK_A-"${5g_nsa_gnb_index}":cPlaneIpAddr"
    \   ${state}=            Query Admin Infomodel     query=get param "//XNLINK_A-"${5g_nsa_gnb_index}":xnLinkStatus"
    \   Exit For Loop If    "//XNLINK_A-"${5g_nsa_gnb_index}":cPlaneIpAddr"!='None'
    \   Run Keyword If    'pass' in ${status}    Should be equal     ${state}        Active
    \   Run Keyword If    'fail' in ${status}    Should be equal     ${state}        Inactive

Get 5G X2 Status IPV6
	[Documentation]		This keyword reads the value for 5G NSA X2 status for IPV6 addresses
	[Arguments]    ${status}=status    ${count}=count
	:FOR	${5g_nsa_enb_index}	IN RANGE    0    ${count}
	\   Continue For Loop If		'.' in "//LTEENB_A-"${5g_nsa_enb_index}":ipAddr"
    \   ${state}=            Query Admin Infomodel query=get param "//LTEENB_A-"${5g_nsa_enb_index}":x2LinkStatus"
    \   Exit For Loop If    "//LTEENB_A-"${5g_nsa_enb_index}":ipAddr"!='None'
    \   Run Keyword If    'pass' in ${status}    Should be equal     ${state}        available
    \   Run Keyword If    'fail' in ${status}    Should be equal     ${state}        unavailable

Get 5G XN Status IPV6
	[Documentation]		This keyword reads the value for 5G NSA XN status for IPV6 addresses
	[Arguments]    ${status}=status    ${count}=count
	:FOR	${5g_nsa_gnb_index}	IN RANGE    0    ${count}
	\   Continue For Loop If		'.' in "//XNLINK_A-"${5g_nsa_gnb_index}":cPlaneIpAddr"
    \   ${state}=            Query Admin Infomodel query=get param "//XNLINK_A-"${5g_nsa_gnb_index}":xnLinkStatus"
    \   Exit For Loop If    "//XNLINK_A-"${5g_nsa_gnb_index}":cPlaneIpAddr"!='None'
    \   Run Keyword If    'pass' in ${status}    Should be equal     ${state}        Active
    \   Run Keyword If    'fail' in ${status}    Should be equal     ${state}        Inactive

Get 5G AMF Status IPV4
	[Documentation]		This keyword reads the value for 5G AMF status for IPV4 addresses
	[Arguments]    ${status}=status

	${state}=	Query Admin Infomodel	query=get param ${5g_sa_amf_status_path}		alias=${alias}
    Run Keyword IF      ${status}=='active'    Should be equal     ${state}        Active
    Run Keyword If      ${status}=='inactive'    Should be equal     ${state}        Inactive
#   New changes
#    ${5g_sa_amf_ips_list}=   Query Admin Infomodel   query=get param ${5g_sa_amf_ipv4_moc_path}        alias=${alias}
#    log     ${5g_sa_amf_ips_list}

Get 5G AMF Status IPV6
	[Documentation]		This keyword reads the value for 5G AMF status for IPV6 addresses
	[Arguments]    ${status}=status

	${state}=	Query Admin Infomodel	query=get param ${5g_sa_amf_status_path}		alias=${alias}
    Run Keyword IF      ${status}=='active'    Should be equal     ${state}        Active
    Run Keyword If      ${status}=='inactive'    Should be equal     ${state}        Inactive
#   New changes
#    ${5g_sa_amf_ips_list}=   Query Admin Infomodel   query=get param ${5g_sa_amf_ipv4_moc_path}        alias=${alias}
#    log     ${5g_sa_amf_ips_list}

#Get 5G AMF Status IPV6
#	[Documentation]		This keyword reads the value for 5G AMF status for IPV6 addresses
#	[Arguments]		${alias}=default    ${status}=status    ${count}=count
#	:FOR	${5g_sa_amf_ngc_index}	IN RANGE    0    ${count}
#	\   Continue For Loop If		'.' IN "//SERVEDAMF_A-"${5g_sa_amf_ngc_index}":amfIPAddress"
#    \   ${state}=            Query Admin Infomodel query=get param "//SERVEDAMF_A-"${5g_sa_amf_ngc_index}":ngLinkStatus"
#    \   Exit For Loop If    "//SERVEDAMF_A-"${5g_sa_amf_ngc_index}":amfIPAddress"!='None'
#    \   Run Keyword If    'pass' in ${status}    Should be equal     ${state}        Active
#    \   Run Keyword If    'fail' in ${status}    Should be equal     ${state}        Inactive

Get 5G SA NG-C Status IPV4
	[Documentation]		This keyword reads the value for 5G SA NG-C Status for IPv4 address
	[Arguments]		${alias}=default    ${status}=status
    Get 5G AMF Status IPV4 	alias=${alias}    status=${status}    count=${amf_count}
#	Get 5G X2 Status IPV4 	alias=${alias}    status=${status}    count=${sa_enb_count}
#	Get 5G XN Status IPV4 	alias=${alias}    status=${status}    count=${sa_gnb_count}

Get 5G SA NG-C Status IPV6
	[Documentation]		This keyword reads the value for 5G SA NG-C Status for IPv6 address
	[Arguments]		${alias}=default    ${status}=status

    Get 5G AMF Status IPV6 	alias=${alias}    status=${status}    count=${amf_count}
#	Get 5G X2 Status IPV6 	alias=${alias}    status=${status}    count=${sa_enb_count}
#	Get 5G XN Status IPV6 	alias=${alias}    status=${status}    count=${sa_gnb_count}

Get 5G NSA NG-C Status IPV4
	[Documentation]		This keyword reads the value for 5G NSA (Adjacent eNB and adjacent gNB status) for IPV4 addresses
	[Arguments]		${alias}=default    ${status}=status
	Get 5G X2 Status IPV4 	alias=${alias}    status=${status}    count=${nsa_enb_count}
	Get 5G XN Status IPV4 	alias=${alias}    status=${status}    count=${nsa_gnb_count}

Get 5G NSA NG-C Status IPV6
	[Documentation]		This keyword reads the value for 5G NSA (Adjacent eNB and adjacent gNB status) Status for IPV6 addresses
	[Arguments]		${alias}=default    ${status}=status
	Get 5G NSA X2 Status IPV6 	alias=${alias}    status=${status}    count=${nsa_enb_count}
	Get 5G NSA XN Status IPV6 	alias=${alias}    status=${status}    count=${nsa_gnb_count}

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

#	${5g_nsa_xnlink_cplane_ipv4}=	Query Admin Infomodel	query=get param ${5g_nsa_xnlink_cplane_ipv4_moc_path}		alias=${alias}
	${xnlink_cplane_ipv4_list}=	Get Dictionary Values	${5g_nsa_xnlink_cplane_ipv4}

	:FOR	${xnlink_cplane_ipv4_dict}	IN	@{xnlink_cplane_ipv4_list}
	\	${xnlink_cplane_ipv4}=		Get Dictionary Values	${xnlink_cplane_ipv4_dict}
	\	@{xnlink_cp_ipv4_list}=		Convert To List		@{xnlink_cplane_ipv4}[0]
	\	${xnlink_cplane_ipv4_0}=	Set Variable If		'.' in @{xnlink_cp_ipv4_list}		@{xnlink_cplane_ipv4}[0]
	\	Exit For Loop If    '${xnlink_cplane_ipv4_0}'!='None'

	Set Suite Variable		${5g_cplane1_ipv4}		${5g_cplane1_ipv4}
	Set Suite Variable		${xnlink_cplane_ipv4_0}			${xnlink_cplane_ipv4_0}
	Set Suite Variable		${5g_uplane1_ipv4}		${5g_uplane1_ipv4}

Read 5G SA IPv4 Parameters
	[Documentation]		This keyword reads the configured value for 5G SA IPv4 UC Plane.
	[Arguments]		${alias}=default

	${5g_cplane1_ipv4}= 	Get Parameter		rat=5g		param_path=${5g_sa_cplane1_ipv4_moc_path}		alias=${alias}
	${5g_uplane1_ipv4}= 	Get Parameter		rat=5g		param_path=${5g_sa_uplane1_ipv4_moc_path}		alias=${alias}

	${5g_sa_amf_ipv4}=	Query Admin Infomodel	query=get param ${5g_sa_amf_ipv4_moc_path}		alias=${alias}
#	${amf_ipv4_list}=	Get Dictionary Values	${5g_sa_amf_ipv4}

#Badri Commented
#	${amf_ipv4_list}=	Get Dictionary Values	${5g_sa_amf_ipv4}

#	:FOR	${amf_ipv4_dict}	IN	@{amf_ipv4_list}
#	\	${amf_ipv4}=		Get Dictionary Values	${amf_ipv4_dict}
#	\	@{amf_ipv4_ip_list}=		Convert To List		@{amf_ipv4}[0]
#	\	${amf_ipv4_0}=	Set Variable If		'.' in @{amf_ipv4_ip_list}		@{amf_ipv4}[0]
#	\	Exit For Loop If    '${amf_ipv4_0}'!='None'

	Set Suite Variable		${5g_cplane1_ipv4}		${5g_cplane1_ipv4}
#	Set Suite Variable		${amf_ipv4_0}			${amf_ipv4_0}
	Set Suite Variable		${amf_ipv4_0}			${5g_sa_amf_ipv4}
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

	:FOR	${xnlink_cplane_ipv6_dict}	IN	@{xnlink_cplane_ipv6_list}
	\	${xnlink_cplane_ipv6}=		Get Dictionary Values	${xnlink_cplane_ipv6_dict}
	\	@{xnlink_cp_ipv6_list}=		Convert To List		@{xnlink_cplane_ipv6}[0]
	\	${xnlink_cplane_ipv6_0}=	Set Variable If		':' in @{xnlink_cp_ipv6_list}		@{xnlink_cplane_ipv6}[0]
	\	Exit For Loop If    '${xnlink_cplane_ipv6_0}'!='None'

	Set Suite Variable		${5g_uplane1_ipv6}		${5g_uplane1_ipv6}
	Set Suite Variable		${xnlink_cplane_ipv6_0}			${xnlink_cplane_ipv6_0}
	Set Suite Variable		${5g_cplane1_ipv6}		${5g_cplane1_ipv6}

#Read 5G SA IPv6 Parameters

	${5g_cplane1_ipv6}= 	Get Parameter		rat=5g		param_path=${5g_sa_cplane1_ipv6_moc_path}		alias=${alias}
	${5g_uplane1_ipv6}= 	Get Parameter		rat=5g		param_path=${5g_sa_uplane1_ipv6_moc_path}		alias=${alias}

	${5g_sa_amf_ipv6}=	Query Admin Infomodel	query=get param ${5g_sa_amf_ipv6_moc_path}		alias=${alias}
#	${amf_ipv6_list}=	Get Dictionary Values	${5g_sa_amf_ipv6}

Read 5G SA IPv6 Parameters
	[Documentation]		This keyword reads the configured value for 5G SA IPv6 UC Plane.
	[Arguments]		${alias}=default

	${5g_cplane1_ipv6}= 	Get Parameter		rat=5g		param_path=${5g_sa_cplane1_ipv6_moc_path}		alias=${alias}
#	${amf_ipv6_0}=			Get Parameter		rat=5g		param_path=${5g_sa_amf_ipv6_moc_path}
	${5g_uplane1_ipv6}= 	Get Parameter		rat=5g		param_path=${5g_sa_uplane1_ipv6_moc_path}		alias=${alias}

	${5g_sa_amf_ipv6}=	Query Admin Infomodel	query=get param ${5g_sa_amf_ipv6_moc_path}		alias=${alias}
#Badri changed
#	${amf_ipv6_list}=	Get Dictionary Values	${5g_sa_amf_ipv6}

#	:FOR	${amf_ipv6_dict}	IN	@{amf_ipv6_list}
#	\	${amf_ipv6}=		Get Dictionary Values	${amf_ipv6_dict}
#	\	@{amf_ipv6_ip_list}=		Convert To List		@{amf_ipv6}[0]
#	\	${amf_ipv6_0}=	Set Variable If		':' in @{amf_ipv6_ip_list}		@{amf_ipv6}[0]
#	\	Exit For Loop If    '${amf_ipv6_0}'!='None'

	Set Suite Variable		${5g_uplane1_ipv6}		${5g_uplane1_ipv6}
#	Set Suite Variable		${amf_ipv6_0}			${amf_ipv6_0}
	Set Suite Variable		${amf_ipv6_0}			${5g_sa_amf_ipv6}
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