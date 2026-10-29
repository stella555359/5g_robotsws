*** Settings ***
Documentation
              ...   Tests that
              ...   The main functionality of this test is to check if the m
              ...   QC_NAME:
              ...   Author:
              ...   -----------------------------------------------------------------------------
Library    taf.sbts.oam.coam.admin
Library    taf.nms.netact
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
Library		SSHLibrary
Library		Collections
Library		String
Library		OperatingSystem


*** Variables ***
${cmwas_node}		10.41.148.99
${netact_dn}		srnclab1027lbwas.srnblr.nsn-rdnet.net
${user}				omc
${password}			Medsql!_1893
#${mrbts_id}			2520
${LOG_DIR}  		${OUTPUTDIR}/LOG
${ENB_LMP_IP}  		192.168.255.129
${mrbts_id}			-1


*** Keywords ***
TC_CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration_from_active_to_passive_partition
    [Documentation]    Short description.
    Step1: Precondition
    Step 2: Raise critical Alarm and Copy To Passive With Health Check
	Step 3: Raise Major Alarm and Copy To Passive With Health Check
	Step 4: Raise Minor Alarm and Copy To Passive With Health Check

Step1: Precondition
    [Documentation]    Short description.
	set test variable  ${mrbts_id}    ${BTS_INFO.ID}
	Log To Console	CB007335
	Precondition Netact with TAF For CB007335
	#Setup Admin For Alias
	Update Template SCF
	No Critical Or Major Fault Is Active
	Log to console with time CB007335	Precondition is OK, ready to start.

Step 2: Raise critical Alarm and Copy To Passive With Health Check
    [Documentation]    Short description.
	Log to console with time CB007335	Raise critical Alarm and Copy To Passive With Health Check
    Raise Critical Alarm
	Fault 1400 Should Be Raised With Servity Critical
	Copy To Passive With Health Check
	${reslut}=	Get Result Of Copy To Passive
	Should Not Be True	'${reslut}'=='success'
	Fault 4564 Should Be Raised With Servity Minor
	Cancel Fault 1400
	Copy To Passive With Health Check
	${reslut}=	Get Result Of Copy To Passive
	Should Be True	'${reslut}'=='success'
	Fault 4564 Should Be Canceled
	No Critical Or Major Fault Is Active
	Log to console with time CB007335		Raise critical Alarm and Copy To Passive With Health Check complete

Step 3: Raise Major Alarm and Copy To Passive With Health Check
    [Documentation]    Short description.
	Log to console with time CB007335	Raise Major Alarm and Copy To Passive With Health Check
	Raise Major Alarm
	Fault 1400 Should Be Raised With Servity Major
	Copy To Passive With Health Check
	${reslut}=	Get Result Of Copy To Passive
	Should Not Be True	'${reslut}'=='success'
	Fault 4564 Should Be Raised With Servity Minor
	Cancel Fault 1400
	Copy To Passive With Health Check
	${reslut}=	Get Result Of Copy To Passive
	Should Be True	'${reslut}'=='success'
	Fault 4564 Should Be Canceled
	No Critical Or Major Fault Is Active
	Log to console with time CB007335		Raise Major Alarm and Copy To Passive With Health Check complete

Step 4: Raise Minor Alarm and Copy To Passive With Health Check
    [Documentation]    Short description.
	Log to console with time CB007335		Raise Minor Alarm and Copy To Passive With Health Check
	Raise Minor Alarm
	Fault 1400 Should Be Raised With Servity Minor
	${sw_copy_start}=  Get current date
    set test variable    ${sw_copy_start}
	Copy To Passive With Health Check
	${reslut}=	Get Result Of Copy To Passive
	Should Be True	'${reslut}'=='success'
	${sw_copy_end}=  Get current date
    set test variable    ${sw_copy_end}
    set test variable    ${copy_expected_time}   360
    Operation_KPI_Check    ${sw_copy_end}    ${sw_copy_start}    ${copy_expected_time}    COPY_SW_FROM_ACTIVE_TO_PASSIVE_BTS_KPI
	Fault 4564 Should not Be Raised
	Cancel Fault 1400
	No Critical Or Major Fault Is Active
	Log to console with time CB007335		Raise Minor Alarm and Copy To Passive With Health complete

Setup Admin For Alias
    [Documentation]  Setups taf.sbts.oam.coam.admin library on given alias.
    [Arguments]  ${alias}=default
	Log to console with time CB007335  Setting up taf.sbts.oam.coam.admin with alias ${alias}
    taf.sbts.oam.coam.admin.setup admin
        ...  bts_host=${ENB_LMP_IP}
        ...  bts_port=443
        ...  admin_api_log_dir=${LOG_DIR}/admin_logs/
        ...  alias=${alias}

    [Teardown]  run keyword if  '${KEYWORD STATUS}'=='FAIL'  taf.sbts.oam.coam.admin.Teardown Admin  alias=${alias}

Cancel Fault 1400
    [Documentation]    Short description.
	upload and provision scf to site	${CURDIR}/02_05_plan_files/	CB007335_del_EAC_IN.xml
	Fault 1400 Should Be Canceled

Get active alarms
    [Documentation]    Short description.
	${alarms}=	taf.sbts.oam.coam.admin.get_alarms	connection=default

Delete COPYSWTOPASSIVEREQ MO In SCF
    [Documentation]    Short description.
	${objs}=	taf.sbts.oam.coam.admin.Get Managed Objects		COPYSWTOPASSIVERES_R
	Log List	${objs}
	${is_contain}=		Run Keyword And Return Status	Should Not Be Empty		${objs}
	Run Keyword If	${is_contain}==${TRUE}		upload and provision scf to site	${CURDIR}/02_05_plan_files/	CB007335_del_COPYSWTOPASSIVEREQ.xml
	${objs}=	taf.sbts.oam.coam.admin.Get Managed Objects		COPYSWTOPASSIVERES_R
	Log List	${objs}
	${is_contain}=		Run Keyword And Return Status	Should Be Empty		${objs}

Update Template SCF
	[Documentation]	Update MRBTS ID in emplate SCFs
	Log to console with time CB007335	Update template SCFs: ${CURDIR}/02_05_plan_files/*.xml
	${conf}=	taf.sbts.oam.coam.admin.get_scf		connection=default
	${matchs}=	Get Regexp Matches		${conf}		distName="MRBTS-(\\d+)"		1
	${mrbts_id}=	Set Variable	${matchs[0]}
	Set Test Variable	${mrbts_id}
	Log to console with time CB007335	MRBTS ID: ${mrbts_id}
	${cmd}=	Set Variable	sed -i "s/MRBTS-\\([0-9]\\+\\)/MRBTS-${mrbts_id}/g" ${CURDIR}/02_05_plan_files/*.xml
	${out}=		Run		${cmd}
	Log to console with time CB007335	Update template SCFs complete!

Fault ${fault_id} Should Be Raised With Servity ${servity}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${fault_id}: <description>
    ...        ${servity}: <description>
	${alarms}=	taf.sbts.oam.coam.admin.get_alarms	connection=default
	${alarm_status}=		Set Variable	${FALSE}
	FOR 	${alarm}	IN	@{alarms}
		Log Dictionary		${alarm}
		${alarm_status}=	Set Variable If		'${alarm['faultSeverity']}' == '${servity}' and '${alarm['faultId']}' == '${faultId}'		${TRUE}		${FALSE}
		Exit For Loop If	${alarm_status}==${TRUE}
	END
	Run Keyword If	${alarm_status}==${FALSE}	Log To Console	Fault ${faultId} with ${servity} not proper raised
	Should Be True	${alarm_status}==${TRUE}

Fault ${fault_id} Should Be Canceled
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${fault_id}: <description>
	${alarms}=	taf.sbts.oam.coam.admin.get_alarms	connection=default
	${alarm_is_active}=		Set Variable	${FALSE}
	FOR 	${alarm}	IN	@{alarms}
		Log Dictionary		${alarm}
		${alarm_is_active}=	Set Variable If		'${alarm['faultId']}' == '${faultId}'	${TRUE}		${FALSE}
		Exit For Loop If	${alarm_is_active}==${TRUE}
	END
	Run Keyword If	${alarm_is_active}==${TRUE}	Log To Console	Fault ${faultId} not proper canceled
	Should Be True	${alarm_is_active}==${FALSE}

Fault ${fault_id} Should Not Be Raised
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${fault_id}: <description>
	${alarms}=	taf.sbts.oam.coam.admin.get_alarms	connection=default
	${alarm_is_active}=		Set Variable	${FALSE}
	FOR 	${alarm}	IN	@{alarms}
		Log Dictionary		${alarm}
		${alarm_is_active}=	Set Variable If		'${alarm['faultId']}' == '${faultId}'	${TRUE}		${FALSE}
		Exit For Loop If	${alarm_is_active}==${TRUE}
	END
	Run Keyword If	${alarm_is_active}==${TRUE}	Log To Console	Fault ${faultId} is active
	Should Be True	${alarm_is_active}==${FALSE}

No Critical Or Major Fault Is Active
    [Documentation]    Short description.
	${alarms}=	taf.sbts.oam.coam.admin.get_alarms	connection=default
	${critical_alarm_is_active}=		Set Variable	${FALSE}
	FOR 	${alarm}	IN	@{alarms}
		Log Dictionary		${alarm}
		${critical_alarm_is_active}=	Set Variable If		'${alarm['faultSeverity']}' == 'Critical' or '${alarm['faultSeverity']}' == 'Major'		${TRUE}		${FALSE}
		Exit For Loop If	${critical_alarm_is_active}==${TRUE}
	END
	Run Keyword If	${critical_alarm_is_active}==${TRUE}	Log To Console	Critical Or Major Fault Is Active
	Should Be True	${critical_alarm_is_active}==${FALSE}
	Log to console with time CB007335	No Critical Or Major Fault Is Active :)

Log to console with time CB007335
    [Documentation]  Keyword display,log output with time.
    [Arguments]  ${output}
	${year}  ${month}  ${day}  ${hour}  ${min}	${sec}=  Get Time  format=year,month,day,hour,min,sec
    #@{time}=  Get Time  hour min sec  NOW
    #${time_now}=  Catenate  SEPARATOR=:  @{time}[0]  @{time}[1]  @{time}[2]
	${time_now}=	Set Variable	${year}-${month}-${day} ${hour}:${min}:${sec}
    Log  ${time_now} | ${output}  console=True

Precondition Netact with TAF For CB007335
    [Documentation]    Short description.
    Run keyword and ignore error        Postcondition Netact with TAF
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${web_url}=    taf.nms.netact.Detect Web Url
    taf.nms.netact.Add Web Url    ${web_url}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
	taf.nms.netact.upload_configuration	PLMN-PLMN/MRBTS-${mrbts_id}

upload and provision scf to site
	[Arguments]		${path}		${file}
	[Documentation]    kw for upload ${path}/${file} to netact then upload and provision scf to network
	Upload SCF To NetAct	${path}		${file}
	taf.nms.netact.Import Configuration		file_name=${file_name}		plan_name=${file_name}	ui_values=${TRUE}	verbose=${TRUE}
	taf.nms.netact.provision_plan	plan_name=${file_name}
	SSHLibrary.Start Command	rm /var/opt/oss/global/racops/import/${file_name}

Raise Critical Alarm
    [Documentation]    Short description.
	upload and provision scf to site	${CURDIR}/02_05_plan_files/	CB007335_del_EAC_IN.xml
	upload and provision scf to site	${CURDIR}/02_05_plan_files/	CB007335_critical_alarm.xml

Raise Major Alarm
    [Documentation]    Short description.
	upload and provision scf to site	${CURDIR}/02_05_plan_files/	CB007335_del_EAC_IN.xml
	upload and provision scf to site	${CURDIR}/02_05_plan_files/	CB007335_major_alarm.xml

Raise Minor Alarm
    [Documentation]    Short description.
	upload and provision scf to site	${CURDIR}/02_05_plan_files/	CB007335_del_EAC_IN.xml
	upload and provision scf to site	${CURDIR}/02_05_plan_files/	CB007335_minor_alarm.xml

Copy To Passive Without Health Check
    [Documentation]    Short description.
	Delete COPYSWTOPASSIVEREQ MO In SCF
	upload and provision scf to site	${CURDIR}/02_05_plan_files/	CB007335_copy_to_passive_without_health_check.xml
	wait until keyword succeeds		15min	10s		Copy To Passive Complete

Copy To Passive With Health Check
    [Documentation]    Short description.
	Delete COPYSWTOPASSIVEREQ MO In SCF
	upload and provision scf to site	${CURDIR}/02_05_plan_files/	CB007335_copy_to_passive_with_health_check.xml
	wait until keyword succeeds		15min	10s		Copy To Passive Complete

Copy To Passive Complete
    [Documentation]    Short description.
	${objs}=	taf.sbts.oam.coam.admin.Get Managed Objects		COPYSWTOPASSIVERES_R
	Log List	${objs}
	Should Not Be Empty		${objs}

Get Result Of Copy To Passive
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${reslut}: <description>
	sleep    3s
	${objs}=	taf.sbts.oam.coam.admin.Get Managed Objects		COPYSWTOPASSIVERES_R
	${reslut}=	Set Variable	${objs}[0][parameters][result]
	[RETURN]	${reslut}

Get Initial Alarms
    [Documentation]    Short description.
    ${tmp}=    Admin Get Alarm
    Set Suite Variable    ${INITIAL_ALARMS_ENB}    ${tmp}
    Log to Console    ${INITIAL_ALARMS_ENB}

Check If OnAir Before Test
    [Documentation]    Short description.
    Admin Check If OnAir

Check If OnAir After Test
    [Documentation]    Short description.
    Admin Check If OnAir
