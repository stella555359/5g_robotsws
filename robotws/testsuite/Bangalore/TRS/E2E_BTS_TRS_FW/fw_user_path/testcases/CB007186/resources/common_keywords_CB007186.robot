*** Settings ***
Documentation
...     [Author]        	"Megha H D"
...     [Maintenance]   	"TRS I & V Tools Bangalore Team"
variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../../resources/common_Cloud_keywords.robot

*** Keywords ***
Collect logs in cloud
    Run Keywords    Setup Oamops    dut=vcu_7186      alias=default   AND     Collect Snapshot
    ...     dut=vcu_7186  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
    ...      dut=vcu_7186     alias=default
    Run Keywords    Setup Oamops    dut=vdu_7186	alias=default   AND     Collect Snapshot
    ...     dut=vdu_7186	operation_timeout=600   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
    ...      dut=vdu_7186	alias=default

Triger CMP IR to install certificates
    [Arguments]     ${keypoolType}      ${dut}
    Setup Oamops    dut=${dut}      alias=${dut}
    Certificate Configure   dut=${dut}     operation=restore_vendor_certificate  alias=${dut}
    Sleep   60
    Certificate Configure   dut=${dut}     operation=set_certificate_automatic_management
    ...     reference_number=16092  preshared_key=this_is_very_secret   key_pool_type=${keypoolType}   alias=${dut}
    Sleep   60
    Setup Remote Access    remote_device=${dut}.ocp     alias=${dut}
    Execute Interactive Remote Command     command=${oam_pod_name_${dut}}     alias=${dut}
    Execute Interactive Remote Command     command=${collect_pcap_${dut}}      alias=${dut}
    Sleep   20
    Certificate Configure   dut=${dut}    operation=install_cmp_certificate     timeout=300
    ...     key_pool_type=${keypoolType}  alias=${dut}
    Sleep   120
    Execute Interactive Remote Command     command=exit     alias=${dut}
    Copy From Cluster To VM	${dut}
    Run Keyword If  '${keypoolType}'=='RSA'      Rename pcap     ${changed_name_${dut}}
    Run Keyword If  '${keypoolType}'=='ECDSA'     Rename pcap     ${changed_name_ecdsa_${dut}}
    Teardown Remote Access  alias=${dut}

Verify cmp status
	[Arguments]     ${cmp_cmpecdsa_r_moc_path}	${CMP_CMPECDSA}	${dut}
	Setup Oamops    dut=${dut}	alias=${dut}
    	${Backup_fqdn}=	Get Current Plan File	include_runtime_data=${True}	path=/home/ute/FQDN.xml	dut=${dut}
	...		alias=${dut}
	Set Suite Variable      ${Backup_fqdn}    ${Backup_fqdn}
	Verify cmp certificate state	${cmp_cmpecdsa_r_moc_path}	${dut}
	Fetch cmpServerIpAddr	${CMP_CMPECDSA}
	Fetch cmpServerFQDN	${CMP_CMPECDSA}
	Fetch cmpServerRole	${CMP_CMPECDSA}

Verify cmp certificate state
	[Arguments]     ${cmp_cmpecdsa_r_moc_path}	${dut}
	${CMP_state}=     Get Parameter     param_path=${cmp_cmpecdsa_r_moc_path}	dut=${dut}	alias=${dut}
	Should Be Equal     ${CMP_state}       CMP_InitializationOK

Fetch cmpServerFQDN
	[Arguments]     ${CMP_CMPECDSA}
        ${cmpServerFQDN}=
	...	Get Elements Texts  ${Backup_fqdn}	xpath=.//managedObject[@distName="${CERTHENT}/${CMP_CMPECDSA}"]//p[@name="cmpServerFQDN"]
	Set Suite Variable      ${cmpServerFQDN}    ${cmpServerFQDN}
	${FQDN}     Create list    cmp-it-1-v4.telcoblr.nsn-rdnet.net   cmp-it-1-v4.telcoblr.nsn-rdnet.net
	Set Suite Variable  ${FQDN}
       	Should Be Equal     ${cmpServerFQDN}       ${FQDN}

Fetch cmpServerIpAddr
	[Arguments]     ${CMP_CMPECDSA}
        ${cmpServerIpAddr}=
	...	Get Elements Texts  ${Backup_fqdn}      xpath=.//managedObject[@distName="${CERTHENT}/${CMP_CMPECDSA}"]//p[@name="cmpServerIpAddr"]
	Set Suite Variable      ${cmpServerIpAddr}    ${cmpServerIpAddr}
	${CMPServer_ips}     Create list   ${CMPServer_IP}  ${CMPServer_IP1}
	Set Suite Variable  ${CMPServer_ips}
       	Should Be Equal     ${cmpServerIpAddr}       ${CMPServer_ips}

Fetch cmpServerRole
	[Arguments]     ${CMP_CMPECDSA}
        ${cmpServerRole}=
	...	Get Elements Texts  ${Backup_fqdn}      xpath=.//managedObject[@distName="${CERTHENT}/${CMP_CMPECDSA}"]//p[@name="cmpServerRole"]
	Set Suite Variable      ${cmpServerRole}    ${cmpServerRole}
	${cmpServer_Role}     Create list   ACTIVE  BACKUP
	Set Suite Variable  ${cmpServer_Role}
       	Should Be Equal     ${cmpServerRole}       ${cmpServer_Role}

Copy From Cluster To VM
    [Arguments]     ${dut}
    Setup Remote Access    remote_device=${dut}.ocp     alias=conn28
    Execute Interactive Remote Command     command=${Clusterpath_${dut}}     alias=conn28
    Execute Interactive Remote Command     command=${copy_to_vm_${dut}}    exit_prompt= password:  alias=conn28
    Execute Interactive Remote Command     command=UTE.debian12  exit_prompt=$   alias=conn28
    Teardown Remote Access      alias=conn28

Rename pcap
    [Arguments]     ${renamed_pcap}
    Setup Remote Access    remote_device=remote_device_1    alias=conn30
    Execute Interactive Remote Command     command=${renamed_pcap}  alias=conn30
    Teardown Remote Access      alias=conn30

Verify CMP packets
    [Arguments]     ${filename}		${dut}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_ir_${dut}
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_accept_${dut}
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_certconf_${dut}
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_cmp_pkiconf_${dut}
    ...     filter_file_name=${traffic_filter_file_name}

Perform initialize cert without fqdn
	[Arguments]     ${dut}
	Setup Oamops    dut=${dut}	alias=${dut}
	Perform Recommissioning    dut=${dut}  type=delta  delta_file=${cmpserver_ipv4}    timeout=400     alias=${dut}
	Triger CMP IR to install certificates	RSA     ${dut}
	Verify runtime cmp parameter value without fqdn	${cmp_r_moc_path}	CMP_R-1		${dut}
	Perform Recommissioning    dut=vcu_7186  type=delta  delta_file=${cmpecdsaserver_ip}    timeout=400     alias=${dut}
	Triger CMP IR to install certificates	ECDSA     ${dut}
	Verify runtime cmp parameter value without fqdn	${cmpecdsa_r_moc_path}	CMPECDSA_R-1	${dut}

Verify runtime cmp parameter value without fqdn
	[Arguments]     ${cmp_cmpecdsa_r_moc_path}	${CMP_CMPECDSA}		${dut}
	${Backup_file}=	Get Current Plan File	include_runtime_data=${True}	path=/home/ute/CMPserverIP.xml	dut=${dut}	alias=${dut}
	${cmpServerIpAddr}=
	...	Get Elements Texts  ${Backup_file}      xpath=.//managedObject[@distName="${CERTHENT}/${CMP_CMPECDSA}"]//p[@name="cmpServerIpAddr"]
	Set Suite Variable      ${cmpServerIpAddr}    ${cmpServerIpAddr}
	Should Be Empty	${cmpServerIpAddr}
	Verify cmp certificate state	${cmp_cmpecdsa_r_moc_path}	${dut}

Configure cmpserver with fqdn
	[Arguments]     ${dut}
	Setup Oamops    dut=${dut}      alias=${dut}
	Perform Recommissioning    dut=${dut}  type=delta  delta_file=${cmpserver_fqdn}    timeout=300     alias=${dut}
	Sleep	120
	Perform Recommissioning    dut=${dut}  type=delta  delta_file=${cmpecdsaserver_fqdn}    timeout=300     alias=${dut}
	Sleep	60
    Teardown Oamops     dut=${dut}     alias=${dut}

Configure cmpserver with ipv6 fqdn
	[Arguments]     ${dut}
	Setup Oamops    dut=${dut}      alias=${dut}
	Perform Recommissioning    dut=${dut}  type=delta  delta_file=${cmpserver_ipv6fqdn}    timeout=400     alias=${dut}
	Sleep	60
	Certificate Configure   dut=${dut}    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=RSA  alias=${dut}
	Sleep	90
	${CMP_state}=     Get Parameter     param_path=${cmp_r_moc_path}	dut=${dut}	alias=${dut}
	Should Be Equal     ${CMP_state}       CMP_InitializationFailed
	Perform Recommissioning    dut=${dut}  type=delta  delta_file=${cmpecdsaserver_ipv6fqdn}    timeout=400     alias=${dut}
	Sleep	30
	Certificate Configure   dut=${dut}     operation=restore_vendor_certificate  alias=${dut}
	Sleep   30
	Certificate Configure   dut=${dut}    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=ECDSA  alias=${dut}
	Sleep	90
	${CMPECDSA_state}=     Get Parameter     param_path=${cmpecdsa_r_moc_path}	dut=${dut}	alias=${dut}
	Should Be Equal     ${CMPECDSA_state}       CMP_InitializationFailed
    Teardown Oamops     dut=${dut}     alias=${dut}

Trigger oampod reset
	[Arguments]      ${dut}
	Setup Remote Access    remote_device=${dut}.ocp     alias=${dut}
	Execute Interactive Remote Command     command=kubectl delete pod po-oamext-0 -n trs-cran5     alias=${dut}
	Sleep   300
