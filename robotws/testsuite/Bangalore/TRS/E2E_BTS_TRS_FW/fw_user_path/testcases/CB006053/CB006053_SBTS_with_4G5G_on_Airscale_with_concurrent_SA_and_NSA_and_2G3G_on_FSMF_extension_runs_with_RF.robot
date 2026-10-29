*** Settings ***
Documentation
...			[Procedure]					"CB006053_SBTS with 4G+5G on Airscale and 2G+3G on FSMF extension"
...			[Date]						"26-08-2021"
...			[Author]					"Megha"
...			[Feature_ID]				"CB006053"
...			[Maintenance]				"TRS I & V Tools Bangalore Team"
...			[Funtion_Hash_Tags]			"checking SSH , SOAM&LOAM and concurrent SA and NSA verification"
...			[DELTA_FILE_DEPENDENCY]		".ssh_port_disable.json,ssh_port_enable.json"
...			[Validated_TestLine]		"3290"
...			[Config_Comments]			"SBTS is configured with 5G, 4G, 3G and 2G"
...			[Precondition]				"SBTS should be configured with 5G(SAand NSA), 4G, 3G and 2G"


Resource        ${CURDIR}/../resources/common_keywords.robot

Force Tags      CLOUD_F    CA_VRF_BLR2        SBTS00        SBTS24R2    SBTS24R3      QCD_MN_RAN       QCP_RAN_VRF        CRT


Suite Setup                     Pre-conditions for testsuite
Suite Teardown                   Post-conditions for testteardown

***Test Cases***
[1]CB006053_SBTS with 4G+5G on Airscale with concurrent SA and NSA and 2G+3G on FSMF extension runs with RF
	Perform Commissioning		scf_file=${CB006053_scfc}	verify_bts_status=${false}	timeout=900
	Setup Oamops	dut=chained_bts		alias=secondary
	Change Ssh Access	enable=${True}
	Check SSH Login		Primarybts
	PowerOff PrimaryBTS and check Secondary bts login is successful
	Run keyword and Expect Error	SSHException*	Check SSH Login		Primarybts
	PowerON PrimaryBTS and verify BTS
	[Teardown]	Run at end


***Keywords***
PowerOff PrimaryBTS and check Secondary bts login is successful
	Poweroff_BTS	RRB1		${RRB1['PrimaryBTSPortID']}
	Wait Until Keyword Succeeds		5 minute	1 minute	Change Ssh Access	enable=${True}		alias=secondary
	Check SSH Login		Secondarybts
	sleep  30
	Change Ssh Access	enable=${False}		alias=secondary
	sleep  60
	Run keyword and Expect Error	*SSHClientException: No existing session	Check SSH Login		Secondarybts
	Change Ssh Access	enable=${True}		alias=secondary
	Run keyword and Expect Error	*	Setup Oamops	alias=primary

PowerON PrimaryBTS and verify BTS
	Poweron_BTS	RRB1	${RRB1['PrimaryBTSPortID']}
	Sleep	120
	Check SSH Login		Primarybts
	Wait Until Keyword succeeds	10min	1min	Verify All Link Status

PowerOff SecondaryBTS and check Primary bts login is successful
	Poweroff_BTS	RRB2	${RRB2['SecondaryBTSPortID']}
	Run keyword and Expect Error	*	Setup Oamops	dut=chained_bts  	alias=secondary
	Change Ssh Access
	Check SSH Login		Primarybts

PowerON both BTS
	Poweron_BTS	RRB1	${RRB1['PrimaryBTSPortID']}
	Poweron_BTS	RRB2	${RRB2['SecondaryBTSPortID']}

Check SSH Login
	[Arguments]     ${bts}
	Setup Remote Access		remote_device=${bts}
	Remote Command Execute		command=cd /ffs/run/config
	[Teardown]	Teardown Remote Access

PowerON SecondaryBTS and verify BTS
	Poweron_BTS	RRB2	${RRB2['SecondaryBTSPortID']}
	Wait Until Keyword succeeds	15min	5min	Verify Bts Status

Poweroff_BTS
	[Arguments]     ${RRB}	${port}
	Setup Remote Access		remote_device=${RRB}
	Remote Command Execute		command=gpio write ${port}s 0
	Sleep	120
	[Teardown]	Teardown Remote Access

Poweron_BTS
	[Arguments]     ${RRB}	${port}
	Setup Remote Access		remote_device=${RRB}
	Remote Command Execute		command=gpio write ${port}s 1
	Sleep	120
	[Teardown]	Teardown Remote Access

Check Rnd Port Status on Primary and Secondary BTS when enabled
	${reference_value}=		Query Admin Infomodel		query=get object ${secadm_runtime_moc}
	${status_1}=			Get From Dictionary		dictionary=${reference_value}	key=servicePortStatus
	sleep  30
	Should Be Equal		${status_1}	enabled
	sleep  30
	${reference_value}=		Query Admin Infomodel		query=get object ${secadm_runtime_moc}		alias=secondary
	${status_1}=			Get From Dictionary		dictionary=${reference_value}		key=servicePortStatus
	sleep  30
	Should Be Equal   ${status_1}     enabled

Check Rnd Port Status on Primary and Secondary BTS when disabled
	${reference_value}=		Query Admin Infomodel		query=get object ${secadm_runtime_moc}
	${status_1}=			Get From Dictionary		dictionary=${reference_value}		key=servicePortStatus
	sleep  30
	Should Be Equal   ${status_1}     disabled
	sleep  30
	${reference_value}=       Query Admin Infomodel    query=get object ${secadm_runtime_moc}     alias=secondary
	${status_1}=     Get From Dictionary     dictionary=${reference_value}      key=servicePortStatus
	sleep  30
	Should Be Equal   ${status_1}     disabled

Check Rnd Port Status on Secondary BTS when enabled
	sleep  120
	${reference_value}=		Query Admin Infomodel		query=get object ${secadm_runtime_moc}	alias=secondary
	${status_1}=			Get From Dictionary		dictionary=${reference_value}	key=servicePortStatus
	sleep  30
	Should Be Equal		${status_1}		enabled

Verify All Link Status
	[Documentation]		This Keyword is used to verify X2, wcdma and NG link status
	Generate Scf	target_file=${Current_Backup_SCF}	export_type=configurationAndRuntimeObjects
	Verify the X2 link status
	Verify the NG link status
	Verify the S1 link status
	Verify wcdma link status

Verify the X2 link status
	[Documentation]		This Keyword is used to verify X2link status
	${X2_status_moc}=	Query Admin Infomodel	query=get object ${x2_moc_path}
	${x2_link_status}=	Get From Dictionary		dictionary=${X2_status_moc}		key=x2ToGnbLinkStatus
	Should Be Equal		${x2_link_status}	available


Verify wcdma link status
	${WCDMA_status}=    Get Element Text     ${Current_Backup_SCF}     .//managedObject[@distName="MRBTS-3290/WNBTS-1"]/p[@name="operationalState"]
	Should Be Equal		${WCDMA_status}		onAir

Verify wcdma link is down
	Generate Scf	target_file=${Current_Backup_SCF}	export_type=configurationAndRuntimeObjects
	${WCDMA_status}=    Get Element Text     ${Current_Backup_SCF}     .//managedObject[@distName="MRBTS-3290/WNBTS-1"]/p[@name="operationalState"]
	Should not be Equal		${WCDMA_status}		onAir

Verify the NG link status
	[Documentation]		This Keyword is used to verify nglink status
	${ngLink_Status}=   Get Elements Texts	${Current_Backup_SCF}     ${ngLink_param_path}
	${Max_Range}=	Get Length		${ngLink_Status}
	FOR	${i}	IN RANGE	1	${Max_Range}+1
		${NG_status_moc}=	Query Admin Infomodel	query=get object ${amf_moc_path}-${i}
		${ng_link_state}=	Get From Dictionary		dictionary=${NG_status_moc}		key=ngLinkStatus
		Should Be Equal		${ng_link_state}	Active
	END

Verify the S1 link status
	[Documentation]		This Keyword is used to verify s1link status
	${s1Link_Status}=   Get Elements Texts	${Current_Backup_SCF}     ${s1Link_param_path}
	${Max_Range}=	Get Length		${s1Link_Status}
	FOR	${i}	IN RANGE	0	${Max_Range}
		${S1_status_moc}=	Query Admin Infomodel	query=get object ${mme_moc_path}-${i}
		${s1_link_state}=	Get From Dictionary		dictionary=${S1_status_moc}		key=s1LinkStatus
		Should Be Equal		${s1_link_state}	available
	END

Run at end
	PowerON both BTS
	Teardown Oamops		alias=secondary
