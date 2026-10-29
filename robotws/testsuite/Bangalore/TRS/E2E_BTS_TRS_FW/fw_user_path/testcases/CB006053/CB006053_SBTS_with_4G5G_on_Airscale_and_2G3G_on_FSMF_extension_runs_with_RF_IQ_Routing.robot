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

Force Tags	CLOUD_F_IPSEC	CA_E2ET_BTSTRSPZ	SBTS00	SBTS22R1	RAN_4G	RAN_4G_FDD	QCD_MN_RAN	QCP_RAN_VRF	CRT


Suite Setup                     Pre-conditions for testsuite
Suite Teardown                   Post-conditions for testteardown

***Test Cases***
[1]CB006053_SBTS with 4G+5G on Airscale and 2G+3G on FSMF extension runs with RF + IQ Routing
	Perform Commissioning		scf_file=${CB006053_scfc}	verify_bts_status=${false}		timeout=900
	Sleep	300
	Wait Until Keyword succeeds	10min	1min	Verify All Link Status
	Poweroff secondary bts and check LTE and 5G is up
	PowerON SecondaryBTS and verify BTS
	[Teardown]	Poweron_BTS	RRB2	${RRB2['SecondaryBTSPortID']}



***Keywords***
Poweroff secondary bts and check LTE and 5G is up
	PowerOff SecondaryBTS and check Primary bts login is successful
	Sleep	300
	Verify 5G LTE and WCDMA

PowerOff SecondaryBTS and check Primary bts login is successful
	Poweroff_BTS	RRB2	${RRB2['SecondaryBTSPortID']}
	Run keyword and Expect Error	*	Setup Oamops	dut=chained_bts  	alias=secondary
	Change Ssh Access
	Check SSH Login		Primarybts

PowerON SecondaryBTS and verify BTS
	Poweron_BTS	RRB2	${RRB2['SecondaryBTSPortID']}
	Sleep	120
	Wait Until Keyword succeeds	15min	2min	Verify All Link Status

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
	Sleep	60
	[Teardown]	Teardown Remote Access

Check SSH Login
	[Arguments]     ${bts}
	Setup Remote Access		remote_device=${bts}
	Remote Command Execute		command=cd /ffs/run/config
	[Teardown]	Teardown Remote Access

PowerON both BTS
	Poweron_BTS	RRB1	${RRB1['PrimaryBTSPortID']}
	Poweron_BTS	RRB2	${RRB2['SecondaryBTSPortID']}

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

Verify 5G LTE and WCDMA
	Wait Until Keyword succeeds	5min	1min	Verify wcdma link is down
	Verify the NG link status
	Verify the S1 link status

Verify the NG link status
	[Documentation]		This Keyword is used to verify nglink status
	${ngLink_Status}=   Get Elements Texts	${Current_Backup_SCF}     ${ngLink_param_path}
	${Max_Range}=	Get Length		${ngLink_Status}
	FOR	${i}	IN RANGE	1	${Max_Range}+1
		${NG_status_moc}=	Query Admin Infomodel	query=get object ${amf_moc_path}-${i}
		${ng_link}=	Get From Dictionary		dictionary=${NG_status_moc}		key=ngLinkStatus
		Should Be Equal		${ng_link}	Active
	END

Verify the S1 link status
	[Documentation]		This Keyword is used to verify s1link status
	${s1Link}=   Get Elements Texts	${Current_Backup_SCF}     ${s1Link_param_path}
	${Max_Range}=	Get Length		${s1Link}
	FOR	${i}	IN RANGE	0	${Max_Range}
		${S1_status_moc}=	Query Admin Infomodel	query=get object ${mme_moc_path}-${i}
		${s1_link_status}=	Get From Dictionary		dictionary=${S1_status_moc}		key=s1LinkStatus
		Should Be Equal		${s1_link_status}	available
	END

Run at end
	PowerON both BTS
