*** Settings ***
Documentation	This is a common keyword repository for calls operations.

*** Keywords ***
Make IPv4 5G Data Call
	Call Setup	5g=device_1:data	parallel=${False}   verify_attach=${False}
	Call Start	5g=device_1:data	profile=5g_udp_ul
	Call Start	5g=device_1:data	profile=5g_udp_dl
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	5g=device_1:data		profile=5g_udp_ul
	...		AND		Run Keyword And Ignore Error	Call Stop	5g=device_1:data		profile=5g_udp_dl
	...		AND		Run Keyword And Ignore Error	Call Teardown	5g=device_1:data

Make IPv4 LTE Data Call
	Call Setup	lte=device_1:data	parallel=${False}
	Call Start	lte=device_1:data	profile=lte_udp_ul
	Call Start	lte=device_1:data	profile=lte_udp_dl
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	lte=device_1:data		profile=lte_udp_ul
	...		AND     Run Keyword And Ignore Error	Call Stop	lte=device_1:data		profile=lte_udp_dl
	...		AND     Run Keyword And Ignore Error	Call Teardown	lte=device_1:data

Make IPv4 WCDMA Data Call
	Call Setup	wcdma=device_1:data	parallel=${False}
	Call Start	wcdma=device_1:data	profile=wcdma_udp_ul
	Call Start	wcdma=device_1:data	profile=wcdma_udp_dl
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	wcdma=device_1:data		profile=wcdma_udp_ul
	...		AND		Run Keyword And Ignore Error	Call Stop	wcdma=device_1:data		profile=wcdma_udp_dl
	...		AND		Run Keyword And Ignore Error	Call Teardown	wcdma=device_1:data

Make IPv4 GSM Data Call
	Call Setup	gsm=device_1:data	parallel=${False}
	Call Start	gsm=device_1:data	profile=gsm_udp_ul
	Call Start	gsm=device_1:data	profile=gsm_udp_dl
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	gsm=device_1:data		profile=gsm_udp_ul
	...		AND		Run Keyword And Ignore Error	Call Stop	gsm=device_1:data		profile=gsm_udp_dl
	...		AND		Run Keyword And Ignore Error	Call Teardown	gsm=device_1:data

Make IPv4 WCDMA Voice Call
	Call Setup	wcdma=device_1:voice	parallel=${False}
	Call Start	wcdma=device_1:voice
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	wcdma=device_1:voice
	...		AND		Run Keyword And Ignore Error	Call Teardown	wcdma=device_1:voice

Make IPv4 GSM Voice Call
	Call Setup	gsm=device_1:voice	parallel=${False}
	Call Start	gsm=device_1:voice
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	gsm=device_1:voice
	...		AND		Run Keyword And Ignore Error	Call Teardown	gsm=device_1:voice


Make IPv6 5G Data Call
	Call Setup	5g=device_1_ipv6:data	parallel=${False}    verify_attach=${False}     ipv4_or_6=ipv6
	Call Start	5g=device_1_ipv6:data	profile=5g_udp_ul    iperf_device=ipv6_server
	Call Start	5g=device_1_ipv6:data	profile=5g_udp_dl    iperf_device=ipv6_server
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	5g=device_1_ipv6:data		profile=5g_udp_ul
	...             iperf_device=ipv6_server
	...		AND		Run Keyword And Ignore Error	Call Stop	5g=device_1_ipv6:data		profile=5g_udp_dl    iperf_device=ipv6_server
	...		AND		Run Keyword And Ignore Error	Call Teardown	5g=device_1_ipv6:data

Make IPv6 LTE Data Call
	Call Setup	lte=device_1_ipv6:data	parallel=${False}    ipv4_or_6=ipv6
	Call Start	lte=device_1_ipv6:data	profile=lte_udp_ul    iperf_device=ipv6_server
	Call Start	lte=device_1_ipv6:data	profile=lte_udp_dl    iperf_device=ipv6_server
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	lte=device_1_ipv6:data		profile=lte_udp_ul
	...            iperf_device=ipv6_server
	...		AND		Run Keyword And Ignore Error	Call Stop	lte=device_1_ipv6:data		profile=lte_udp_dl    iperf_device=ipv6_server
	...		AND		Run Keyword And Ignore Error	Call Teardown	lte=device_1_ipv6:data    ipv4_or_6=ipv6

Make IPv6 WCDMA Data Call
	Call Setup	wcdma=device_1_ipv6:data	parallel=${False}    ipv4_or_6=ipv6
	Call Start	wcdma=device_1_ipv6:data	profile=wcdma_udp_ul    iperf_device=ipv6_server
	Call Start	wcdma=device_1_ipv6:data	profile=wcdma_udp_dl    iperf_device=ipv6_server
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	wcdma=device_1_ipv6:data		profile=wcdma_udp_ul
	...           iperf_device=ipv6_server
	...		AND		Run Keyword And Ignore Error	Call Stop	wcdma=device_1_ipv6:data		profile=wcdma_udp_dl    iperf_device=ipv6_server
	...		AND		Run Keyword And Ignore Error	Call Teardown	wcdma=device_1_ipv6:data    ipv4_or_6=ipv6

Make IPv6 GSM Data Call
	Call Setup	gsm=device_1_ipv6:data	parallel=${False}    ipv4_or_6=ipv6
	Call Start	gsm=device_1_ipv6:data	profile=gsm_udp_ul    iperf_device=ipv6_server
	Call Start	gsm=device_1_ipv6:data	profile=gsm_udp_dl    iperf_device=ipv6_server
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	gsm=device_1_ipv6:data		profile=gsm_udp_ul
	...             iperf_device=ipv6_server
	...		AND		Run Keyword And Ignore Error	Call Stop	gsm=device_1_ipv6:data		profile=gsm_udp_dl    iperf_device=ipv6_server
	...		AND		Run Keyword And Ignore Error	Call Teardown	gsm=device_1_ipv6:data    ipv4_or_6=ipv6

Make IPv6 WCDMA Voice Call
	Call Setup	wcdma=device_1_ipv6:voice	parallel=${False}    ipv4_or_6=ipv6
	Call Start	wcdma=device_1_ipv6:voice
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	wcdma=device_1_ipv6:voice
	...		AND		Run Keyword And Ignore Error	Call Teardown	wcdma=device_1_ipv6:voice    ipv4_or_6=ipv6

Make IPv6 GSM Voice Call
	Call Setup	gsm=device_1_ipv6:voice		parallel=${False}    ipv4_or_6=ipv6
	Call Start	gsm=device_1_ipv6:voice
	Sleep	120
	[Teardown]		Run Keywords	Run Keyword And Ignore Error	Call Stop	gsm=device_1_ipv6:voice
	...		AND		Run Keyword And Ignore Error	Call Teardown	gsm=device_1_ipv6:voice    ipv4_or_6=ipv6

Make One Rat Call
	[Documentation]		This keyword defines value for source(source_ip) and destination(uplane_ip) ip for the traffic profile
	...                in testline config to use.

	[Arguments]		${rat}		${ip_version}

	Run Keyword If		'5g' in ${rat} and '${ip_version}'=='ipv4'	Make IPv4 5G Data Call
	Run Keyword If		'lte' in ${rat} and '${ip_version}'=='ipv4'	Make IPv4 LTE Data Call
	Run Keyword If		'wcdma' in ${rat} and '${ip_version}'=='ipv4'	Make IPv4 WCDMA Data Call
	Run Keyword If		'gsm' in ${rat} and '${ip_version}'=='ipv4'	Make IPv4 GSM Voice Call

	Run Keyword If		'5g' in ${rat} and '${ip_version}'=='ipv6'	Make IPv6 5G Data Call
	Run Keyword If		'lte' in ${rat} and '${ip_version}'=='ipv6'	Make IPv6 LTE Data Call
	Run Keyword If		'wcdma' in ${rat} and '${ip_version}'=='ipv6'	Make IPv6 WCDMA Data Call
	Run Keyword If		'gsm' in ${rat} and '${ip_version}'=='ipv6'	Make IPv6 GSM Voice Call

Make All RAT Calls
    Run Keyword If      'SRAN_5G' in ${rat_env}     Call Setup	5g=device_1:data    lte=device_1:data	wcdma=device_1:data
    ...                 gsm=device_1:voice	 parallel=${True}
    Run Keyword If      'SRAN' in ${rat_env}     Call Setup	 lte=device_1:data	wcdma=device_1:data	gsm=device_1:voice	parallel=${True}
    Run Keyword If      'SRAN_5G' in ${rat_env}     Call Start	5g=device_1:data	profile=5g_udp_ul
	Run Keyword If      'SRAN_5G' in ${rat_env}     Call Start	5g=device_1:data	profile=5g_udp_dl
	Call Start	lte=device_1:data	profile=lte_udp_ul
	Call Start	lte=device_1:data	profile=lte_udp_dl
	Call Start	wcdma=device_1:data	profile=wcdma_udp_ul
	Call Start	wcdma=device_1:data	profile=wcdma_udp_dl
	Call Start	gsm=device_1:voice
	Sleep	100
	[Teardown]	End Calls

End Calls
    Run Keyword If      'SRAN_5G' in ${rat_env}     Run Keyword And Ignore Error	    Call Stop	5g=device_1:data		profile=5g_udp_ul
    Run Keyword If      'SRAN_5G' in ${rat_env}     Run Keyword And Ignore Error	    Call Stop	5g=device_1:data		profile=5g_udp_dl
	Run Keyword And Ignore Error		Call Stop	lte=device_1:data		profile=lte_udp_ul
	Run Keyword And Ignore Error		Call Stop	lte=device_1:data		profile=lte_udp_dl
	Run Keyword And Ignore Error		Call Stop	wcdma=device_1:data		profile=wcdma_udp_ul
	Run Keyword And Ignore Error		Call Stop	wcdma=device_1:data		profile=wcdma_udp_dl
	Run Keyword And Ignore Error		Call Stop	gsm=device_1:voice
    Run Keyword If      'SRAN_5G' in ${rat_env} Run Keyword And Ignore Error    Call Teardown	5g=device_1:data    lte=device_1:data
    ...                 wcdma=device_1:data gsm=device_1:voice  parallel=${True}
    Run Keyword If      'SRAN' in ${rat_env} Run Keyword And Ignore Error   Call Teardown	lte=device_1:data   wcdma=device_1:data
    ...                gsm=device_1:voice  parallel=${True}
