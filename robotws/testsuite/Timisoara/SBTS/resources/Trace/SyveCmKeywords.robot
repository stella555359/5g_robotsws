*** Settings ***
Documentation     [PURPOSE] Netact cm General keywords
Library		SSHLibrary
Library		XML
Library		taf.nms.netact
Library		Collections
Library		String


*** Variables ***
${plan_info}
${parameter}


*** Keywords ***
Setup For CM Resource
    [Documentation]    Short description.
	${lab}=		Fetch From Left		${netact}[SDV_WEBSPHERE_CLUSTER_FQDN]   .
	${lab}=		Replace String		${lab}	lbwas	${EMPTY}
	${lab}=		Convert To Upper Case	${lab}
	Setup NetAct
	Clear plans in CM
	taf.nms.netact.upload_configuration	PLMN-PLMN/MRBTS-${mrbts_id}		alias=netact_allias
	${bts_ip}	${eutraCelId}=	Get Mplane IP And eutraCelId From SCF	${mrbts_id}		${lnbts_id}		${lncel_id}
	Set suite Variable	${bts_ip}
	Set suite Variable	${eutraCelId}
	${BTS_scf_initial}=	Export Actual Configuration	${mrbts_id}
	${xml}=	Run		cat ${BTS_scf_initial} | sed "s/PLMN-PLMN\\///g"
	Should Not Contain	${xml}	PLMN-PLMN
	Run		sed -i "s/PLMN-PLMN\\///g" ${BTS_scf_initial}
	Set suite Variable	${BTS_scf_initial}
	${para}=		Create Dictionary		actCellTraceWithIMSI=true
	${plan_info}=	Create Dictionary	scf_distName=MRBTS-10673/LNBTS-10673
	...     mo_id=PLMN-PLMN/MRBTS-10673/LNBTS-10673		parameter=${para}
	Log		${plan_info}
	Set suite Variable  ${plan_info}

Setup NetAct
    [Documentation]    Short description.
	taf.nms.netact.Add Web URL		${netact}[SDV_WEBSPHERE_CLUSTER_FQDN]
	...     ${netact}[SDV_DESKTOP_ADMIN_USER]	${netact}[SDV_DESKTOP_ADMIN_PASSWORD]	    alias=netact_allias
	taf.nms.netact.Add Node    cmwas	${netact}[SDV_WEBSPHERE_APPSERVER_PRIMARY_IP]
	...     ${netact}[SDV_DESKTOP_ADMIN_USER]	${netact}[SDV_DESKTOP_ADMIN_PASSWORD]	    alias=netact_allias

Generate Plan Name
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${name}: <description>
    ${mrbts_id}=  Should Match Regexp  ${MRBTS_DN}  \\d+
    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}-${month}-${day}_${hour}-${min}
    Should Be String  MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable  ${name}  MRBTS-${mrbts_id}_${timestamp}
    [RETURN]    ${name}

Create MTRACE
    [Documentation]    Short description.
    Set Test Variable   ${trace_reference}			630637
    ${plan_name}=   Generate Plan Name
    ${actConf}=	taf.nms.netact.get_actual_configuration	alias=netact_allias
	${obj}=			taf.nms.netact.get_managed_object		${actConf}		${MRBTS_DN}/LNBTS-${lnbts_id} 	alias=netact_allias
	Log		${obj}
	Log		${obj.meta_class}
	Log		${obj.meta_version}
    ${plan}=     taf.nms.netact.create_plan_configuration  ${plan_name}    alias=netact_allias
    taf.nms.netact.create_managed_object
        ...     plan=${plan}    meta_class=NOKLTE:MTRACE
        ...     meta_version=${obj.meta_version}   mo_id=${MRBTS_DN}/LNBTS-${lnbts_id}/CTRLTS-1/MTRACE-0
        ...     operation=create      alias=netact_allias
        ...     eutranTraceIdMcc=262	eutranTraceIdMnc=03	traceId=${trace_reference}	trcRecSessionRef=65535
        ...     cellTrcMode=true	tceIpAddress=10.97.91.1	traceRrcSetting=0	traceS1Setting=0	traceX2Setting=0
        ...     actPCMDReporting=false  actUeThroughputMR=false     cellMaxActiveUEsTraced=60   cellTaTracing=false
        ...     jobType=1   maxBufferingTime=2000   tceCellTracePortNum=49151
    taf.nms.netact.Provision Plan		plan_name=${plan_name}		dist_names=${MRBTS_DN}	    backup_plan_name=${plan_name}_backup
    ...     create_backup_plan=${True}		provisioning_operation=activate	    alias=netact_allias

Teardown NetAct
    [Documentation]    Short description.
	Log	Teardown netact
	taf.nms.netact.Clean All	alias=netact_allias

Get Latest Operation Status
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${status}: <description>
    ...        ${latest_operation_history}: <description>
	${feedback}=	taf.nms.netact.get_detailed_operations_history		operations_count=1
	...     dist_names=PLMN-PLMN/MRBTS-${mrbts_id}		alias=netact_allias
	${latest_operation_history}		Set Variable	${feedback}[0]
	Log		${feedback}
	${matchs}=		Get Regexp Matches		${latest_operation_history}		Status: (\\w+)      1
	${status}=		Set Variable	${matchs}[0]
	Should Be True		'${status}'=='Finished' or '${status}'=='Failed'
	[RETURN]	${status}	${latest_operation_history}

Latest Operation Should be Successful
    [Documentation]    Short description.
	${status}	${latest_operation_history}=	wait until keyword succeeds		120s		2s
	...     Get Latest Operation Status
	Log To Console		Latest provision ${status}.
	Run Keyword If		'${status}'=='Failed'
	...		Log To Console		${latest_operation_history}
	Should Be True	'${status}'=='Finished'

Import the plan with Ui Values
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${local_dir}: <description>
    ...        ${file_name}: <description>
	[Arguments]		${local_dir}=../traceConfig/	${file_name}=${EMPTY}
	${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
	${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
	ta_netact_cm_operations.Import Plan		local_dir=${local_dir}		file_name=${file_name}
	...     plan_name=${name}		ui_values=${True}

TC parameters check
    [Documentation]    Short description.
    Log  TC parameters check started  console=True
    ${same_values}=  Run Keyword And Return Status  ta_netact_cm_operations.Check Actual Configuration Parameters
    ...  dist_name=${plan_info['mo_id']}  &{plan_info['parameter']}
    Set Test Variable  ${same_values}
    Run Keyword If  ${same_values}
    ...  Log  Paras check failed: Parameters values to be provisioned are identical to the existing ones!  level=WARN
    ...  ELSE  Log  TC parameters successfully checked  console=True

Create and edit plan SyVe
    [Documentation]
    ...  Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    # Log  Step ${index}: Create and edit plan SyVe  console=True
    ${mrbts_id}=  Should Match Regexp  ${MRBTS_DN}  \\d+
    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}-${month}-${day}_${hour}-${min}
    Should Be String  MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable  ${name}  MRBTS-${mrbts_id}_${timestamp}

    ${plan}=  SyveCmKeywords.NetAct Create And Edit Plan		name=${name}
    ...     description=Automation SyVe for MRBTS-${mrbts_id}
	...	mo_id=${plan_info['mo_id']}		scf_distName=${plan_info['scf_distName']}
	...	parameter=&{plan_info['parameter']}
    Set Test Variable  ${plan}
    Set Test Variable  ${mrbts_id}

NetAct Create And Edit Plan
	[Arguments]	${name}	    ${description} 	${mo_id}	${scf_distName}		${parameter}	${operation}=UPDATE
	[Documentation]	Create and edit plan
	Log		${scf_distName}
	${actConf}=	taf.nms.netact.get_actual_configuration	alias=netact_allias
	${obj}=			taf.nms.netact.get_managed_object		${actConf}		${mo_id}	alias=netact_allias
	Log		${obj}
	Log		${obj.meta_class}
	Log		${obj.meta_version}
	${conf}=		taf.nms.netact.create_plan_configuration	${name}		${description}	alias=netact_allias
	${keys}=    Get Dictionary Keys    ${parameter}
	${parameter_name}=  set Variable    ${keys}[0]
	${values}=   Get Dictionary Values    ${parameter}
	${parameter_value}=  set Variable    ${values}[0]
	${MO}=	taf.nms.netact.create_managed_object	${conf}		${obj.meta_class}	${obj.meta_version}
	...     ${mo_id}	${operation}  	netact_allias	${parameter_name}=${parameter_value}
	taf.nms.netact.provision_plan		${name}		${MRBTS_DN}	backup_plan_name=${name}_backup
	...     create_backup_plan=${True}		provisioning_operation=activate	alias=netact_allias

Export the plan SyVe
    [Documentation]    Short description.
    NetAct Export Plan  local_dir=${Test Results Dir}/NetActLogs
    ...     file_name=${name}.xml  dist_names=${MRBTS_DN}  plan_name=${name}
    ...  operation_type=plan

Provision the plan SyVe
    [Documentation]    Short description.
	taf.nms.netact.provision_plan		${name}		${MRBTS_DN}	backup_plan_name=${name}_backup
	...     create_backup_plan=${True}		provisioning_operation=activate	alias=netact_allias

Export Actual Configuration
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${mrbts_id}: <description>
    ...        ${local_dir}: <description>
    ...
    ...    Returns:
    ...        ${local_dir}${name}.xml: <description>
	[Arguments]		${mrbts_id}		${local_dir}=/tmp/
	${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
	${name}=	Set Variable	MRBTS-${mrbts_id}_${timestamp}
	SSHLibrary.Switch Connection 	DEFAULT
	${cmd}=  Catenate    SEPARATOR=${SPACE}
	...     racclimx.sh -DN PLMN-PLMN/MRBTS-${mrbts_id} -UIValues true -useQualifiedClassAbbreviation true
	...     -includeSiteInfo false -v -type actual -fileFormat RAML2 -op Export -outputFile
	...     /d/oss/global/var/racops/export/${name}.xml
	Start Command		${cmd}
	${output}=		Read Command Output
	Log		${output}
	Should Contain	${output}	Status received: Finished
	SSHLibrary.Get File	/d/oss/global/var/racops/export/${name}.xml		${local_dir}${name}.xml
	[RETURN]	${local_dir}${name}.xml

Get Mplane IP And eutraCelId From SCF
	[Documentation]		Get Mplane IP From SCF which is export from NetAct.
	[Arguments]		${mrbts_id}		${lnbts_id}		${lncel_id}
	${scf_path}=	Export Actual Configuration	${mrbts_id}
	Set Suite Variable	${scf_path}
	${root} =	Parse XML	${scf_path}
	Should Be Equal	${root.tag}	raml
	${obj}=	Get Element		${root}		cmData/managedObject[@class="com.nokia.srbts:MRBTS"]
	${distName}=		XML.Get Element Attribute	${obj}	distName
	${mrbts_id_scf}=	Fetch From Right	${distName}		-
	Should Be True		'${mrbts_id_scf}'=='${mrbts_id}'
	${MPLANENW_obj}=		Get Element			${root}
	...     cmData/managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]
	${status}=	Run Keyword And Return Status	Element Should Exist
	...     ${MPLANENW_obj}		p[@name="mPlaneIpv4AddressDN"]
	${mPlaneIpvxAddressDN}=	Run Keyword If	${status}==${TRUE}
							...	Get Element Text	${MPLANENW_obj}		p[@name="mPlaneIpv4AddressDN"]
							...	ELSE	Get Element Text	${MPLANENW_obj}		p[@name="mPlaneIpv6AddressDN"]
	${IPADDRESS_obj}=	Get Element			${root}
	...     cmData/managedObject[@distName="PLMN-PLMN/${mPlaneIpvxAddressDN}"]
	${localIpAddr}=	Get Element Text			${IPADDRESS_obj}			p[@name="localIpAddr"]
	${lncel_obj}=	Get Element		${root}
	...     cmData/managedObject[@distName="PLMN-PLMN/MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${lncel_id}"]
	${eutraCelId}=	Get Element Text			${lncel_obj}			p[@name="eutraCelId"]
	[RETURN]	${localIpAddr}	${eutraCelId}

Get Mplane IP And eutraCelId From SCF Taf
	[Documentation]		Get Mplane IP From SCF which is export from NetAct.
	[Arguments]		${mrbts_id}		${lnbts_id}		${lncel_id}
	${scf_path}=	export configuration	${mrbts_id}
	Set test Variable	${scf_path}
	${root} =	Parse XML	${scf_path}
	Should Be Equal	${root.tag}	raml
	${obj}=	Get Element		${root}		cmData/managedObject[@class="com.nokia.srbts:MRBTS"]
	${distName}=		XML.Get Element Attribute	${obj}	distName
	${mrbts_id_scf}=	Fetch From Right	${distName}		-
	Should Be True		'${mrbts_id_scf}'=='${mrbts_id}'
	${MPLANENW_obj}=		Get Element			${root}
	...     cmData/managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]
	${status}=	Run Keyword And Return Status	Element Should Exist
	...     ${MPLANENW_obj}		p[@name="mPlaneIpv4AddressDN"]
	${mPlaneIpvxAddressDN}=	Run Keyword If	${status}==${TRUE}
							...	Get Element Text	${MPLANENW_obj}		p[@name="mPlaneIpv4AddressDN"]
							...	ELSE	Get Element Text	${MPLANENW_obj}		p[@name="mPlaneIpv6AddressDN"]
	${IPADDRESS_obj}=	Get Element			${root}
	...     cmData/managedObject[@distName="PLMN-PLMN/${mPlaneIpvxAddressDN}"]
	${localIpAddr}=	Get Element Text			${IPADDRESS_obj}			p[@name="localIpAddr"]
	${lncel_obj}=	Get Element		${root}
	...     cmData/managedObject[@distName="PLMN-PLMN/MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${lncel_id}"]
	${eutraCelId}=	Get Element Text			${lncel_obj}			p[@name="eutraCelId"]
	[RETURN]	${localIpAddr}	${eutraCelId}

Update Parameter From NetAct
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${parameter_name}: <description>
    ...        ${parameter_value}: <description>
    ...        ${scf_dist_name}: <description>
	[Arguments]		${parameter_name}	${parameter_value}		${scf_dist_name}
	Log	${plan_info}
	Remove From Dictionary	${plan_info}	parameter
	${parameter}=	Create Dictionary	${parameter_name}=${parameter_value}
	Set To Dictionary	${plan_info}	parameter	${parameter}
	Remove From Dictionary	${plan_info}	mo_id
	Set To Dictionary	${plan_info}	mo_id	PLMN-PLMN/${scf_dist_name}
	Remove From Dictionary	${plan_info}	scf_distName
	Set To Dictionary	${plan_info}	scf_distName	${scf_dist_name}
	Log	${plan_info}
	Create and edit plan SyVe
	Provision the plan SyVe

Clear plans in CM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${keyword}: <description>
	[Arguments]		${keyword}=TV
	${script}=  Set Variable    /opt/oss/NSN-cmplatform/bin/ractoolsmx.sh
    ${output}=      SSHLibrary.execute command     ${script} -confmgr -list -plan | grep ${keyword} | awk -F ' ' '{print $3}'
	${status}=  Run Keyword And Return Status	Should Be Empty		${output}
	Return From Keyword If		${status}==${TRUE}
	Log To Console		Clear Plans created by Trace Viewer in CM Editor
	${config_ids}=	Replace String	${output}	\n	${SPACE}
	${output}=      SSHLibrary.execute command    ${script} -confmgr -remove -safe -plan ${config_ids}
	Log		${output}
    ${output}=    SSHLibrary.execute command    ${script} -confmgr -list -plan | grep ${keyword}
	Log		${output}
	Should Be Empty		${output}
