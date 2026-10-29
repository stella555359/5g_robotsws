*** Settings ***
Documentation
...	[Procedure]				"[1]CB005896_SBTS_FSMF_Traffic_Limitation_Level_Change"
...	[Date]					"29-12-2021"
...	[Author]				"Boban Mathew"
...	[Feature_ID] 			"CB005896"
...	[Maintenance]			"TRS I & V Tools Bangalore Team"
...	[Funtion_Hash_Tags] 	"Traffic Guard"
...	[DELTA_FILE_DEPENDENCY] "Traffic Guard Enbaling and Disabling from ESMSIM"
...	[Validated_TestLine] 	"CLOUD_5G_I_KL_AP_LO"
...	[Config_Comments] 		"LTE configurations with IPSEC"
...	[Precondition] 			"BTS should be integrated to EMSSIM"
...	[QC_Path]               "QC_Path in Test Plan"
...	[QC_ID]					"QC_ID in Test Lab for reporting"

Resource	${CURDIR}/resources/Common_CB005896.robot

Force Tags      CA_E2ET_BTSTRSPZ        SBTS00      SBTS22R2     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT		CLOUD_5G_I_KL_AP_LO

Suite Setup		Run Keywords	Suite Setup Preconditions
...             AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...             AND		Teardown Oamops

***Test Cases***

[1][1.0] TRS_CB005896_ASIK_BTS upgrade with Traffic Guard Enabled (5G Classical BTS)
    Get System Module HW Variant
	Change iptrafficlim_upd
	Reset Bts   should_be_onair=False
	Sleep    450
    Perform Call Setup Based On HW Variant
	Sleep    30
    Start Calls Based On HW Variant
	Start emssim configuration
	Enable Traffic Guard using EMSSIM
	${Alarm_list}=	Verify Alarm	faultid=${faultnum}	should_exist=${True}
	VerifyAlarmSupp		${Alarm_list}
	Pm Counters Start	analysis=IPVOL_counters		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
	Verify PM Counters	analysis=IPVOL_counters		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
    Stop Calls Based On HW Variant
	Software Upgrade
	Sleep    300
	Verify Alarm	faultid=${faultnum}	should_exist=${False}
    Start Calls Based On HW Variant
	Sleep    120
	Pm Counters Start	analysis=IPVOL_counters_nodrop		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
	Verify PM Counters	analysis=IPVOL_counters_nodrop		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
    Stop Calls Based On HW Variant
	Inactive State Verification
    ${mplane_ipv4}=     Get Parameter   param_path=${mplane_ipv4_ip_moc}
	setup oamops    bts_host=${mplane_ipv4}    alias=rollback_mplane
	Rollback Software	alias=rollback_mplane	timeout=600
	Sleep    300
	Verify Alarm	faultid=${faultnum}	should_exist=${True}
    Start Calls Based On HW Variant
	Pm Counters Start	analysis=IPVOL_counters		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
	Verify PM Counters	analysis=IPVOL_counters		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
    Stop Calls Based On HW Variant
	[Teardown]		Keywords To Run At End

