*** Settings ***
Documentation     [Procedure] "CB008267_Common_keywords_file"
...               [Date] "Date of creation 03-07-2023"
...               [Author] "Mansi"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB008267"
...               [Funtional_Hash_Tags] "TLS,ARP,GARP,ICMP"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] ASIM ans ASIA
...               [Validation Date] 20-06-2023



Resource        ${CURDIR}/../../resources/common_keywords.robot

*** Keywords ***
Check Proxy ARP is disabled
    FOR    ${file}    IN    @{files_list2}
        Setup Remote Access     remote_device=bts     timeout=30     alias=default
        ${stdout}=      Remote Command Execute       command=cat ${file}
        Should Contain     ${stdout}      0
        Teardown Remote Access     alias=default
    END

Check Gratuitous ARP messaging is disabled
    FOR    ${file}    IN    @{files_list3}
        Setup Remote Access     remote_device=bts     timeout=30     alias=default
        ${stdout}=      Remote Command Execute       command=cat ${file}
        Should Contain     ${stdout}      0
        Teardown Remote Access     alias=default
    END

Get LMP Interface MAC
    Setup Remote Access    remote_device=bts
    ${stdout}       Remote Command Execute      command=ifconfig ethlmp0 | grep ether
    @{list}=    Split String    ${stdout}
    Log     @{list}[1]
    Set Suite Variable          ${ethlmp_mac}    @{list}[1]
    [Teardown]      Teardown remote Access

Analyse pcap for parp and garp
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_garp_res_analysis
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_parp_req_analysis
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_parp_res_analysis
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_garp_req_analysis

Check ICMP broadcasting is disabled
    Execute command on GNB       cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
    Run Keyword If      '''${stdout}'=='0'''   Execute command on GNB    echo 1 > ICMP_echo_ignore

Check network product doesn't respond to the ICMP broadcast ping
	Execute command on gNB         ping ${broadcast_ip} -b -c 5
	Should Contain     ${stdout}     100% packet loss

Check ICMP broadcasting is enabled and getting response for ICMP broadcast ping
    Execute command on GNB       echo 0 > ICMP_echo_ignore
    Should Be Empty       ${stdout}
    Execute command on GNB   ping ${broadcast_ip} -b -c 5
    Should Contain        ${stdout}          5 packets transmitted, 5 received

Check IP multicast handling is disabled
	Perform Recommissioning        type=delta      delta_file=${basic_configuration_v6}
	...    timeout=400     skip_parameter_relation_errors=${False}
    Run     sudo ip a a fc00::0003:0001/120 dev eth3
	Fetch Ingress Rules From Board

Fetch Ingress Rules From Board
	[Documentation]		This keyword checks for the user defined runtime argument ${rule_type} and calls different keywords accordingly.
	Run Keyword If		'${rule_type}'=='nftlist'	Fetch Ingress Rules From NFTLIST And Verify
	Run Keyword If		'${rule_type}'=='iptables'	Fetch Ingress Rules From IPTABLES And Verify

Perform software upgrade
    ${Active_SW_version}    ${passive_SW_version}=  Get Sw Version
     Setup Remote Access     remote_device=bts
     ${build_version}=       Remote Command Execute
     ...    command=cd /ffs/run/; ls -ltr | grep -i TargetBD | head -1 | awk '{print $9}' | cut -c -39 | cut -d_ -f 2-6
     Set Suite Variable      ${build_version}
    [Teardown]      Teardown remote Access
    @{active_release}=      Split String From Right     ${Active_SW_version}            _       max_split=2
     Run Keyword If  '${active_release[0]}' == 'SBTS23R4_ENB_9999'        Perform Software Download And Update    wft_profile=sbtstrunk_00
     ...    timeout=1600		        ELSE    Perform Software Download And Update    wft_profile=branch_SBTS23R3    timeout=1600
     Sleep  300

Fetch Ingress Rules From NFTLIST And Verify
	[Documentation]		This keyword fetches firewall rules for all IPv4 and IPv6 types Ingress traffic using nft list command. \n
	...		If any rule is not present, the keyword will fail.

	Setup Remote Access		remote_device=bts
	${file_permission_output}=		Remote Command Execute		command=nft list chain inet filter ICMP_INGRESS
	Log	   ${file_permission_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter INGRESS_ECHO_RESPONSE
	Log	   ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter INGRESS_DEST_UNREACHABLE
	Log	   ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter INGRESS_ECHO_REQUEST
	Log	   ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter INGRESS_TIME_EXCEEDED
	Log	   ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter INGRESS_PARAMETER_PROBLEM
	Log	   ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter V6INGRESS_DEST_UNREACHABLE
	Log	   ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter V6INGRESS_PACKET_2BIG
	Log	   ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter V6INGRESS_TIME_EXCEEDED
	Log	   ${icmp_vmap_ingress_output}
	${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter V6INGRESS_PARAMETER_PROBLEM
	Log	   ${icmp_vmap_ingress_output}
    ${icmp_vmap_ingress_output}=       Remote Command Execute
    ...     command=nft list chain inet filter V6INGRESS_ECHO_REQUEST | grep -i "limit rate 25/second burst 8 packets"
	Log	   ${icmp_vmap_ingress_output}
    ${icmp_vmap_ingress_output}=		Remote Command Execute		command=nft list chain inet filter V6INGRESS_ECHO_RESPONSE
	Log	   ${icmp_vmap_ingress_output}
	${icmpv6_mld_ingress_output}=	Remote Command Execute		command=nft list chain inet filter INGRESS_MLD_CHAIN
	Log	   ${icmpv6_mld_ingress_output}
	${icmpv6_ndp_ingress_output}=	Remote Command Execute		command=nft list chain inet filter INGRESS_NDP_CHAIN
	Log	   ${icmpv6_ndp_ingress_output}
	[Teardown]		Teardown Remote Access

Fetch Ingress Rules From IPTABLES And Verify
	[Documentation]		This keyword fetches firewall rules for all IPv4 and IPv6 types Ingress traffic using iptables command.
	...		If any rule is not present, the keyword will fail.
	Setup Remote Access		remote_device=bts
	${icmp_ingress_output}=		Remote Command Execute		command=iptables -nvL ICMP_INGRESS
	Log	   ${icmp_ingress_output}
	${icmpv6_ingress_output}=	Remote Command Execute		command=ip6tables -nvL ICMPV6_INGRESS
	Log	   ${icmpv6_ingress_output}
	${icmpv6_mldv6_ingress_output}=	Remote Command Execute		command=ip6tables -nvL MLDV6_INGRESS
	Log 	${icmpv6_mldv6_ingress_output}
	${icmpv6_ndpv6_ingress_output}=	Remote Command Execute		command=ip6tables -nvL NDPV6_INGRESS
	Log 	${icmpv6_ndpv6_ingress_output}
	[Teardown]		Teardown Remote Access

Change credentials of user Using '${new_username}' '${new_password}' '${old_username}' '${old_password}' '${account_type}'
     User Account Manage     operation=manage_local_user_account   new_username=${new_username}
     ...    new_password=${new_password}    old_username=${old_username}    old_password=${old_password}   account_type=${account_type}
     User Account Manage     operation=change_account_state      account_type=${account_type}    enable=${True}

Enable Restricted Access
    Setup Oamops       dut=bts     alias=conn
    Perform Recommissioning     type=param      rat=common     param_path=${web_server_enable_moc}  operation=update
     ...        value=true     timeout=300           alias=default
    Perform Recommissioning     type=param      rat=common     param_path=${web_server_timer_moc}  operation=update
    ...     value=60     timeout=60              alias=default
    Sleep   60

Check for duplicate login and perform recommissioning and expect error
    Run Keyword And Expect Error       *${sessionId_invalid}*       Perform Recommissioning     type=param      rat=common
    ...     param_path=${web_server_enable_moc}  operation=update    value=true     timeout=300           alias=conn
     Teardown Oamops        alias=conn

Check for login as Administrator
    [Arguments]     ${admin}		${dut}     ${conn}
    Log       ${admin}
    Run Keyword And Expect Error       *${sessionId_invalid}*              Setup Oamops      dut=${dut}     alias=${conn}
    Run Keyword And Expect Error        *${key_error}*                      Teardown Oamops	dut=${dut}        alias=${conn}

Disable Restricted Access
    Perform Recommissioning     type=param      rat=common     param_path=${web_server_enable_moc}
    ...     operation=update    value=false     timeout=300           alias=default

Enable Restricted Access using mplane
    Setup Oamops       dut=mplane     alias=mplanelogin
    Perform Recommissioning     type=param      rat=common     param_path=${web_server_enable_moc}  operation=update
     ...        value=true     timeout=300           alias=mplanelogin
    Perform Recommissioning     type=param      rat=common     param_path=${web_server_timer_moc}  operation=update
    ...     value=60     timeout=60              alias=mplanelogin
    Sleep   60

Disable Restricted Access using mplane
    Perform Recommissioning     type=param      rat=common     param_path=${web_server_enable_moc}
    ...     operation=update    value=false     timeout=300           alias=mplanelogin

SSH Login should Pass
	Setup Remote Access    remote_device=bts
    [Teardown]		Teardown remote Access

Check SSH Login
	Setup Remote Access		remote_device=${bts}
	Remote Command Execute		command=cd /ffs/run/config
	[Teardown]	Teardown Remote Access

Changing idle timer fails due to Below range
    ${timer}   Evaluate  random.randrange(-200000,-1)    random
	Run Keyword and expect error        *VALUE_IS_TOO_SMALL*            Perform Recommissioning     type=param  rat=lte
	...     param_path=SECADM-1:sshSessionIdleTimer       operation=update    value=${timer}    timeout=200

Changing idle timer fails due to out of range
    ${timer}   Evaluate    random.randrange(86401,221000)    random
    Run Keyword and expect error        *VALUE_IS_TOO_BIG*            Perform Recommissioning     type=param  rat=lte
    ...     param_path=SECADM-1:sshSessionIdleTimer       operation=update    value=${timer}    timeout=200


Changing delay timer fails due to Below range
    ${timer}   Evaluate     random.randrange(-1000,-1)    random
    Run Keyword and expect error        *VALUE_IS_TOO_SMALL*            Perform Recommissioning     type=param  rat=lte
    ...     param_path=SECADM-1:sshSessionLoginDelayTimer       operation=update    value=${timer}    timeout=200

Changing delay timer fails due to out of range
    ${timer}   Evaluate     random.randrange(61,1000)     random
    Run Keyword and expect error        *VALUE_IS_TOO_BIG*            Perform Recommissioning     type=param  rat=lte
    ...     param_path=SECADM-1:sshSessionLoginDelayTimer       operation=update    value=${timer}    timeout=200

Check Autologout
    [Arguments]     ${timer}
    Setup Remote Access  remote_device=bts    alias=default
    sleep   ${timer}
    Run Keyword And Expect Error       *${socket_error}*   Execute Interactive Remote Command  command=${command}   alias=default
    Teardown Remote Access      alias=default

Check Autologout with file open and data transfer
    [Arguments]     ${timer}
    Setup Remote Access  remote_device=bts    alias=default
    sleep   ${timer}
    Run Keyword And Expect Error       *${socket_error}*   Execute Interactive Remote Command  command=${command}   alias=default
    Teardown Remote Access      alias=default
    Setup Remote Access  remote_device=bts    alias=default
    Execute Interactive Remote Command  command= ${command2}   alias=default
    sleep   ${timer}
    Execute Interactive Remote Command  command=${command}   alias=default
    Teardown Remote Access      alias=default
    Perform Recommissioning     type=param      rat=common     param_path=${sessionidletimer}  operation=update    value=20
    ...       timeout=300      alias=default
    ${date}=    Get Current Date
    Sleep   15
    Setup Remote Access  remote_device=bts    alias=default
    @{cmd_1}=  Create List  scp_cmd
    ${cmd_2}=  Get Config Variable  ${cmd_1}
    Execute Interactive Remote Command  command=${cmd_2}  alias=default
    Execute Interactive Remote Command  command=yes     alias=default
    Execute Interactive Remote Command  command=ute     prompt=>      wait_for_prompt=${True}     alias=default
    ${date1}=   Get Current Date
    @{list1}=    Split String    ${date1}
    @{list}=    Split String    ${date}
    Log     @{list}[1]
    ${time}=    Subtract Time From Time     @{list1}[1]    @{list}[1]
    Should Be True  '${time}'>'20'
    Teardown Remote Access      alias=default

Enable Ethernet Port Security
    Setup Oamops       dut=bts     alias=conn
    Perform Recommissioning     type=param      rat=common     param_path=${SOE_path}  operation=update
     ...        value=true     timeout=300           alias=default
    Sleep   60

Disable Ethernet Port Security
    Perform Recommissioning     type=param      rat=common     param_path=${SOE_path}  operation=update
     ...        value=false     timeout=300           alias=default

Ethernet Port Security is Disabled alarm should not be present
    Verify Alarm		faultid=4654		should_exist=${False}		alias=default

Ethernet Port Security is Disabled alarm should be present
    Verify Alarm		faultid=4654		alias=default

Perform Software Rollback
     Rollback Software   timeout=300
