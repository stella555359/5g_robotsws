*** Settings ***
Documentation
...            [Author]         "Nandini R"
...            [Maintenance]    "TRS VRF BLR2 Bangalore Team"

Library         SeleniumLibrary
Resource		${CURDIR}/../../resources/common_keywords.robot

*** Keywords ***
Revert credentials at the End
	Setup Oamops        dut=vcu_cran12		username=toor4nsn		password=A-Za-z0-9!#$%&'()*+,-.;=?@[]_~/
	Perform Recommissioning	    dut=vcu_cran12	type=delta      delta_file=${Password_History_Length_0_vDU}		timeout=400
	Update Local User Account	dut=vcu_cran12	username=toor4nsn		password=A-Za-z0-9!#$%&'()*+,-.;=?@[]_~/
	...		new_username=Nemuadmin		new_password=${default_password}
	Teardown Oamops     dut=vcu_cran12

	Setup Oamops        dut=vdu_cran12		username=toor4nsn		password=A-Za-z0-9!#$%&'()*+,-.;=?@[]_~/
	Perform Recommissioning	    dut=vdu_cran12	type=delta      delta_file=${Password_History_Length_0_vDU}		timeout=400
	Update Local User Account	dut=vdu_cran12	username=toor4nsn		password=A-Za-z0-9!#$%&'()*+,-.;=?@[]_~/
	...		new_username=Nemuadmin		new_password=${default_password}
	Teardown Oamops     dut=vdu_cran12

Check Nemuadmin password enhancement
	[Arguments]		${dut}
	${pwd_list}		create list		Nokia123_Nemuadmin		Nokia123_nemuadmin		Nokia123_NEMUADMIN		Nokia123_nimdaumeN
	...		Nokia123_nimdaumen		Nokia123_NIMDAUMEN
	FOR		${new_password}    IN		@{pwd_list}
		Run Keyword And Expect Error	*Change password failed(The password contains the user name in some form)*
		...		Update Local User Account	dut=${dut}	username=Nemuadmin		password=${default_password}		new_password=${new_password}
	END
	Run Keyword And Expect Error	*Change password failed(The password is the same as the old one)*
	...		Update Local User Account	dut=${dut}	username=Nemuadmin		password=${default_password}		new_password=${default_password}

Validation for BTS Security Administrator
	[Arguments]		${dut}
	Update Local User Account	username=BTSSecurity	dut=${dut}		active_status=active
	${pwd_list}   create list   Nokia123_BTSsecurity   Nokia123_btsSecurity   Nokia123_BTSsECURITY    Nokia123_ytiruceSstb
    ...    Nokia123_YTIRUCEsSTB
	FOR		${new_password}    IN		@{pwd_list}
		Run Keyword And Expect Error	*Change password failed(The password contains the user name in some form)*
		...		Update Local User Account	dut=${dut}		username=BTSSecurity	new_password=${new_password}
	END
	Run Keyword And Expect Error	*Change password failed(The password contains more than 1 same characters consecutively)*
	...		Update Local User Account	username=BTSSecurity	dut=${dut}		new_password=Nokia123_btssecurity
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 lowercase letters)*
	...		Update Local User Account	username=BTSSecurity	dut=${dut}		new_password=NOKIA123_BTSSECURITY
	Run Keyword And Expect Error	*Change password failed(The password contains less than 2 digits)*
	...		Update Local User Account	username=BTSSecurity	dut=${dut}		new_password=ytiruceSSTB
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 uppercase letters)*
	...		Update Local User Account	username=BTSSecurity	dut=${dut}		new_password=nokia123_ytirucesstb
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 non-alphanumeric characters)*
	...		Update Local User Account	username=BTSSecurity	dut=${dut}		new_password=Nokia123YTIRUCESSTB
	Run Keyword And Expect Error	*Change password failed(The password contains more than 1 same characters consecutively)*
	...		Update Local User Account	username=BTSSecurity	dut=${dut}		new_password=Nokia123_YTIRUCESSTB
	Run Keyword And Expect Error	*Change password failed(The password is shorter than 8 characters)*
	...		Update Local User Account	dut=${dut}	username=BTSSecurity		new_password=Nsn@12
	Run Keyword And Expect Error	*Change password failed(The password contains invalid characters)*
	...		Update Local User Account	username=BTSSecurity	dut=${dut}		new_password=Nokia_{`}_123
	Update Local User Account	username=BTSSecurity	dut=${dut}		new_password=A-Za-z0-9!#$%&'()*+,-.;=?@[]_~/
	Run Keyword And Expect Error	*Change password failed(The password is the same as the old one)*
	...		Update Local User Account	dut=${dut}	username=BTSSecurity		new_password=A-Za-z0-9!#$%&'()*+,-.;=?@[]_~/
	Update Local User Account	dut=${dut}	username=BTSSecurity	active_status=deactive

Create new User
	[Arguments]		${dut}
	Update Local User Account	dut=${dut}	username=Nemuadmin		password=${default_password}		new_username=toor4nsn
	Setup Oamops        dut=${dut}		username=toor4nsn		alias=new_user
	Run Keyword And Expect Error	*Change password failed(The password contains less than 2 digits)*
	...		Update Local User Account	dut=${dut}	username=toor4nsn		password=${default_password}		new_password=toor4nsn
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 lowercase letters)*
	...		Update Local User Account	dut=${dut}	username=toor4nsn		password=${default_password}		new_password=NOKIA123_TOOR4NSN
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 uppercase letters)*
	...		Update Local User Account	dut=${dut}	username=toor4nsn		password=${default_password}		new_password=nokia123_nsn4root
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 non-alphanumeric characters)*
	...		Update Local User Account	dut=${dut}	username=toor4nsn		password=${default_password}		new_password=Nokia123NSN4ROOT
	Run Keyword And Expect Error	*Change password failed(The password contains more than 1 same characters consecutively)*
	...		Update Local User Account	dut=${dut}	username=toor4nsn		password=${default_password}		new_password=Toor4nsn_123
	Run Keyword And Expect Error	*Change password failed(The password is shorter than 8 characters)*
	...		Update Local User Account	dut=${dut}	username=toor4nsn		password=${default_password}		new_password=Nsn@12
	Run Keyword And Expect Error	*Change password failed(The password contains invalid characters)*
	...		Update Local User Account	dut=${dut}	username=toor4nsn		password=${default_password}		new_password=Nokia_<>"_123"
	Update Local User Account	dut=${dut}	username=toor4nsn		password=${default_password}	new_password=A-Za-z0-9!#$%&'()*+,-.;=?@[]_~/
	Teardown Oamops     dut=${dut}		alias=new_user

Validation for BTS Application User
	[Arguments]		${dut}
	Update Local User Account	dut=${dut}	username=BTSApplication		active_status=active
	${pwd_list}		create list		Nokia123_BTSAPplication		Nokia123_btsapPlication		Nokia123_BTSAPpLICATION
	...		Nokia123_NOITACILPpASTB		Nokia123_noitacilpPastb
	FOR		${new_password}    IN		@{pwd_list}
		Run Keyword And Expect Error	*Change password failed(The password contains the user name in some form)*
		...		Update Local User Account	dut=${dut}		username=BTSApplication	new_password=${new_password}
	END
	Run Keyword And Expect Error	*Change password failed(The password contains more than 1 same characters consecutively)*
	...		Update Local User Account	username=BTSApplication		dut=${dut}		new_password=Nokia123_BTSApplication
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 lowercase letters)*
	...		Update Local User Account	username=BTSApplication		dut=${dut}		new_password=NOKIA123_BTSAPPLICATION
	Run Keyword And Expect Error	*Change password failed(The password contains less than 2 digits)*
	...		Update Local User Account	username=BTSApplication		dut=${dut}		new_password=noitacilppASTB
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 uppercase letters)*
	...		Update Local User Account	username=BTSApplication		dut=${dut}		new_password=nokia123_noitacilppastb
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 non-alphanumeric characters)*
	...		Update Local User Account	username=BTSApplication		dut=${dut}		new_password=Nokia123NOITACILPPASTB
	Run Keyword And Expect Error	*Change password failed(The password contains more than 1 same characters consecutively)*
	...		Update Local User Account	username=BTSApplication		dut=${dut}		new_password=Nokia123_NOITACILPPASTB
	Run Keyword And Expect Error	*Change password failed(The password is shorter than 8 characters)*
	...		Update Local User Account	username=BTSApplication		dut=${dut}		new_password=Nsn@12
	Run Keyword And Expect Error	*Change password failed(The password contains invalid characters)*
	...		Update Local User Account	username=BTSApplication		dut=${dut}		new_password=Nokia_^:_123
	Update Local User Account	username=BTSApplication		dut=${dut}		new_password=A-Za-z0-9!#$%&'()*+,-.;=?@[]_~/
	Run Keyword And Expect Error	*Change password failed(The password is the same as the old one)*
	...		Update Local User Account	dut=${dut}	username=BTSApplication		new_password=A-Za-z0-9!#$%&'()*+,-.;=?@[]_~/
	Update Local User Account	dut=${dut}	username=BTSApplication	active_status=deactive

Validation for BTS Read only user
	[Arguments]		${dut}
	Update Local User Account	dut=${dut}	username=BTSRead	active_status=active
	${pwd_list}		create list		Nokia123_BTSRead	Nokia123_btsread	Nokia123_BTSREAD	Nokia123_daeRSTB
	...		Nokia123_daerstb		Nokia123_DAERSTB
	FOR		${new_password}    IN		@{pwd_list}
		Run Keyword And Expect Error	*Change password failed(The password contains the user name in some form)*
		...		Update Local User Account	dut=${dut}		username=BTSRead	new_password=${new_password}
	END
	Run Keyword And Expect Error	*Change password failed(The password contains the user name in some form)*
	...		Update Local User Account	username=BTSRead		dut=${dut}		new_password=Nokia123_BTSRead
	Run Keyword And Expect Error	*Change password failed(The password contains more than 1 same characters consecutively)*
	...		Update Local User Account	username=BTSRead		dut=${dut}		new_password=Nokia1123_daeRSTB
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 lowercase letters)*
	...		Update Local User Account	username=BTSRead		dut=${dut}		new_password=NOKIA123_BTSREAD
	Run Keyword And Expect Error	*Change password failed(The password contains less than 2 digits)*
	...		Update Local User Account	username=BTSRead		dut=${dut}		new_password=Nokia_daeRSTB
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 uppercase letters)*
	...		Update Local User Account	username=BTSRead		dut=${dut}		new_password=nokia123_daerstb
	Run Keyword And Expect Error	*Change password failed(The password contains less than 1 non-alphanumeric characters)*
	...		Update Local User Account	username=BTSRead		dut=${dut}		new_password=Nokia123DAERSTB
	Run Keyword And Expect Error	*Change password failed(The password is shorter than 8 characters)*
	...		Update Local User Account	dut=${dut}	username=BTSRead		new_password=Nsn@12
	Run Keyword And Expect Error	*Change password failed(The password contains invalid characters)*
	...		Update Local User Account	username=BTSRead		dut=${dut}		new_password=Nokia_{|}_123
	Update Local User Account	username=BTSRead		dut=${dut}		new_password=A-Za-z0-9!#$%&'()*+,-.;=?@[]_~/
	Run Keyword And Expect Error	*Change password failed(The password is the same as the old one)*
	...		Update Local User Account	dut=${dut}	username=BTSRead		new_password=A-Za-z0-9!#$%&'()*+,-.;=?@[]_~/
	Update Local User Account	dut=${dut}	username=BTSRead	active_status=deactive

Login to RANNIC
	Setup Remote Access     remote_device=rannic_ssh_device		root_user=toor4nsn 		root_private_key=/home/ute/mybtskey
    ...     root_user_param_path=SECADM-1:rootUserPublicKeys
	Sleep		30

Change the service account password
	[Documentation]        This test case keyword is to change service account password
	[Arguments]			${VDU_USERNAME}=serviceuser		${VDU_PASSWORD}=Test@123			${VDU_NEW_PASSWORD}=Nokia@123
	Update Service Account Password      username=${VDU_USERNAME}       password=${VDU_PASSWORD}     new_password=${VDU_NEW_PASSWORD}
	...         dut=vdu_cran12
	${VDU_PASSWORD}    Set Variable    ${VDU_NEW_PASSWORD}
	Set Suite Variable      ${VDU_PASSWORD}

Enable ssh tunnel
	[Documentation]        This test case keyword is to activate the ssh tunnel
	Config Ssh Tunnel      dist_name=${tunnel_dist}     operation=enable     timeout=100    dut=vdu_cran12
	Sleep     30
	${state}=   Get Ssh Tunnel Config     ssh_mode_type=RNICMOD     timeout=30      dut=vdu_cran12
	${tunnel_details}=     Get From Dictionary      ${state}      details
	Should Not Be Empty     ${tunnel_details}

Disable ssh tunnel
	[Documentation]        This test case keyword is to activate the ssh tunnel
	Config Ssh Tunnel      dist_name=${tunnel_dist}     operation=disable     timeout=100    dut=vdu_cran12
	Sleep     30
	${state}=   Get Ssh Tunnel Config     ssh_mode_type=RNICMOD     timeout=30      dut=vdu_cran12
	${tunnel_details}=     Get From Dictionary      ${state}      details
	Should Be Empty     ${tunnel_details}

Check ICMP Echo Ignore Broadcasts
	${output}=      Remote Command Execute      command=sysctl net.ipv4.icmp_echo_ignore_broadcasts
	Should Contain		${output}		net.ipv4.icmp_echo_ignore_broadcasts = 1

Check Disable ICMP Routing Redirects
	${output}=      Remote Command Execute      command=sysctl net.ipv4.conf.all.accept_redirects
	Should Contain		${output}		net.ipv4.conf.all.accept_redirects = 0
	${output}=      Remote Command Execute      command=sysctl net.ipv6.conf.all.accept_redirects
	Should Contain		${output}		net.ipv6.conf.all.accept_redirects = 0
	${output}=      Remote Command Execute      command=sysctl net.ipv4.conf.all.send_redirects
	Should Contain		${output}		net.ipv4.conf.all.send_redirects = 0

Check Memory Protection Settings
	${output}=      Remote Command Execute      command=sysctl -q kernel.randomize_va_space
	Should Contain		${output}		kernel.randomize_va_space = 2

Check Ip Source Routing
	${output}=      Remote Command Execute      command=sysctl net.ipv4.conf.all.accept_source_route
	Should Contain		${output}		net.ipv4.conf.all.accept_source_route = 0

Check Ip Forwarding
	${output}=      Remote Command Execute      command=sysctl net.ipv4.conf.all.forwarding
	Should Contain		${output}		net.ipv4.conf.all.forwarding = 1
	${output}=      Remote Command Execute      command=sysctl net.ipv4.conf.all.mc_forwarding
	Should Contain		${output}		net.ipv4.conf.all.mc_forwarding = 0

Check RANNIC System Accounts
	${output}=      Remote Command Execute      command=cat /etc/passwd|awk -F ":" '{print $1}'|sort
	${output_list}		Evaluate	"""${output}""".splitlines()	modules=sys
	Log		${output_list}
	Sort List	${PASSWD_WHITE_LIST}
	Run Keyword And Ignore Error	Lists Should Be Equal		${output_list}		${PASSWD_WHITE_LIST}
	List Should Contain Sub List	${PASSWD_WHITE_LIST}	${output_list}

Find Writeable Files
	${output}=      Remote Command Execute      command=find / -xdev -type f -perm -0002 -print
	Should Be Empty		${output}

Find Writeable Directories
	${output}=      Remote Command Execute      command=find / -xdev -type d -perm -0002 -a ! -perm -1000 -print
	Should Be Empty		${output}

Check Whether Root Files Writable By Others
	${output}=      Remote Command Execute
    ...     command=find -type d -path /proc -o -path /sys -prune -o -type f -user root -perm -o=w -print 2>/dev/null
	Should Be Empty		${output}

Find Orphaned Files
	${output}=      Remote Command Execute      command=find / -xdev -type f -prune -o -nouser -o -nogroup -print 2>/dev/null
	Should Be Empty		${output}

Check Permission for Passwd and Group file
	${permission}=      Remote Command Execute      command=stat -c "%a" /etc/passwd
	Should Be True		${permission} <= 644
	${permission}=      Remote Command Execute      command=stat -c "%a" /etc/group
	Should Be True		${permission} <= 644

Check Permission for Shadow and Gshadow file
	${permission}=		Remote Command Execute      command=stat -c "%a" /etc/shadow
	Should Be True		${permission} <= 400
	${permission}=      Remote Command Execute      command=stat -c "%a" /etc/gshadow
	Should Be True		${permission} <= 400

Check SUID/GID Bit Set File
	${output}=      Remote Command Execute      command=find / \\( -perm /4000 -o -perm /2000 \\) -type f 2>/dev/null
	${output_list}    Evaluate    """${output}""".splitlines()    modules=sys
    Log    ${output_list}
    Sort List    ${SUID_GID_FILE_LIST}
    Run Keyword And Ignore Error	Lists Should Be Equal    ${output_list}    ${SUID_GID_FILE_LIST}
	List Should Contain Sub List	${SUID_GID_FILE_LIST}	${output_list}

Check Default Permission by Umask
	${output}=      Remote Command Execute      command=umask
	Should Contain Any		${output}		022		027		077

Lock Account and verify Alarm
	[Arguments]		${dut}		${user}=Nemuadmin
	${Mplane_IP}=		Set Variable If		'${dut}'=='vdu_cran12'		${vDU_Mplane_IP}	${vCU_Mplane_IP}
	Login to webem		${Mplane_IP}	${user}		${default_password}45
	Sleep	60
	Run Keyword And Expect Error	*AuthenticationFailed*
	...		Setup Oamops		dut=${dut}		username=${user}	new_password=${default_password}		alias=acc_lock
	Verify Alarm	dut=${dut}		faultid=61642
	Sleep	60
	Setup Oamops		dut=${dut}		username=${user}	new_password=${default_password}		alias=acc_lock
	Verify Alarm	dut=${dut}		faultid=61642		should_exist=${False}		alias=acc_lock
	Teardown Oamops		dut=${dut}		alias=acc_lock

Login to webem
	[Arguments]		${ip}	${username}		${password}
	Open Browser	https://${ip}		Chrome
	Sleep	5
	Click Button	Advanced
	Sleep	2
	Click Link		proceed-link
	Sleep	2
	Input Text		login-username		${username}
	Input Text		login-password		${password}
	Click Button	Log In
	Sleep	5
	Click Button	Log In
	Sleep	5
	Click Button	Log In
	Sleep	5
	Close Browser

Collect initial Audit Log
	[Arguments]		${dut}
	Setup Remote Access		remote_device=${dut}.ocp
	Sleep	10
	${logserver_pod}=		Execute Interactive Remote Command		command=kubectl get pods -n ${namespace}
	Sleep	5
	${logserver_pod}=		Execute Interactive Remote Command
	...		command=kubectl get pods -n ${namespace} | grep logservice | cut -d ' ' -f 1 > logserver.txt
	Get File From Remote Host		logserver.txt		/tmp/logserver.txt
	${logserver_pod}	Run		cat /tmp/logserver.txt
	Set Suite Variable		${logserver_pod}		${logserver_pod}
	Execute Interactive Remote Command
	...		command=kubectl exec -it -n ${namespace} ${logserver_pod} -c ctr-logstorageserver -- cat ${audit_log} > ${initial_audit_log}
	Get File From Remote Host		${initial_audit_log}	${initial_audit_log_VM}
	${previous_log_end}		Run		cat ${initial_audit_log_VM} | tail -1 | cut -d ' ' -f 1
	Set Suite Variable		${previous_log_end}		${previous_log_end}
	[Teardown]		Teardown Remote Access

Collect Latest Audit Log
	[Arguments]		${dut}
	Setup Remote Access		remote_device=${dut}.ocp
	Sleep	10
	Execute Interactive Remote Command		command=
	Sleep	5
	Execute Interactive Remote Command
	...		command=kubectl exec -it -n ${namespace} ${logserver_pod} -c ctr-logstorageserver -- cat ${audit_log} > ${latest_audit_log}
	Get File From Remote Host		${latest_audit_log}		${latest_audit_log_VM}
	${line_num}=		Run		grep -n "${previous_log_end}" ${latest_audit_log_VM} | cut -d: -f1
	Run		sed -i '1,${line_num}d' ${latest_audit_log_VM}
	Set Suite Variable		${latest_audit_log_VM}		${latest_audit_log_VM}
	[Teardown]		Teardown Remote Access

Verify Audit Log Events
    [Arguments]     ${cloud_variant}
	${output}		Run		cat ${latest_audit_log_VM}
	Should Match Regexp		${output}		${Log_print}.*operation.*Login.*username.*Nemuadmin.*${Login_print}
	Should Match Regexp		${output}		${Log_print}.*operation.*Login.*username.*BTSSecurity.*${Login_print}
	Should Match Regexp		${output}		${Log_print}.*operation.*Login.*username.*BTSApplication.*${Login_print}
	Should Match Regexp		${output}		${Log_print}.*operation.*Login.*username.*BTSRead.*${Login_print}

	Should Match Regexp		${output}		${Validate_plan}
	Should Match Regexp		${output}		${Activate_plan}.*MRBTS-1/MNL-1/MNLENT-1/MPLANENW-1.*oamTls.*:.*forced.*
	Should Match Regexp		${output}		${Activate_plan}.*MRBTS-1/MNL-1/MNLENT-1/MPLANENW-1.*oamTls.*:.*off.*

	Should Match Regexp		${output}		.*operation.*Login.*username.*Nemuadmin.*${Auth_failed}
	Should Match Regexp		${output}		.*operation.*Login.*username.*Nemuadmin.*${Acc_lock}
	Should Match Regexp		${output}		.*operation.*Login.*username.*BTSSecurity.*${Auth_failed}
	Should Match Regexp		${output}		.*operation.*Login.*username.*BTSSecurity.*${Acc_lock}
	Should Match Regexp		${output}		.*operation.*Login.*username.*BTSApplication.*${Auth_failed}
	Should Match Regexp		${output}		.*operation.*Login.*username.*BTSApplication.*${Acc_lock}
	Should Match Regexp		${output}		.*operation.*Login.*username.*BTSRead.*${Auth_failed}
	Should Match Regexp		${output}		.*operation.*Login.*username.*BTSRead.*${Acc_lock}

	Should Match Regexp		${output}		${Log_print}.*operation.*Logout.*username.*Nemuadmin.*${Logout_print}
	Should Match Regexp		${output}		${Log_print}.*operation.*Logout.*username.*BTSSecurity.*${Logout_print}
	Should Match Regexp		${output}		${Log_print}.*operation.*Logout.*username.*BTSApplication.*${Logout_print}
	Should Match Regexp		${output}		${Log_print}.*operation.*Logout.*username.*BTSRead.*${Logout_print}

	Run Keyword If		'${cloud_variant}'=='vcu'	Should Match Regexp		${output}
	...		${Log_print}.*operation.*Trigger reset operation.*username.*Nemuadmin.*
	Run Keyword If		'${cloud_variant}'=='vdu'	Should Match Regexp		${output}
	...		${Activate_plan}.*${RMOD_moc}.*:.*Locked.*${NRCEL_moc}.*:.*Locked.*
	Run Keyword If		'${cloud_variant}'=='vdu'	Should Match Regexp		${output}
	...		${Activate_plan}.*${RMOD_moc}.*:.*Unlocked.*${NRCEL_moc}.*:.*Unlocked.*