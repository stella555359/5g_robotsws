*** Settings ***
Documentation
...	[Procedure]				"[1]CB005896_SBTS_Common_Traffic_Limitation_Level_Change"
...	[Date]					"29-12-2021"
...	[Author]				"Boban Mathew"
...	[Feature_ID] 			"CB005896"
...	[Maintenance]			"TRS I & V Tools Bangalore Team"
...	[Funtion_Hash_Tags] 	"Traffic Guard"
...	[DELTA_FILE_DEPENDENCY] "Traffic Guard Enbaling and Disabling from ESMSIM"
...	[Validated_TestLine] 	"CLOUD_5G_I_MO_AP_LO"
...	[Config_Comments] 		"LTE configurations with IPSEC"
...	[Precondition] 			"BTS should be integrated to EMSSIM"
...	[QC_Path]               "QC_Path in Test Plan"
...	[QC_ID]					"QC_ID in Test Lab for reporting"



Resource	${CURDIR}/resources/Common_CB005896.robot


Force Tags      CA_E2ET_BTSTRSPZ        SBTS00      SBTS22R3     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT		CLOUD_5G_I_MO_AP_LO

Suite Setup		Run Keywords	Suite Setup Preconditions
...             AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...             AND		Teardown Oamops


***Test Cases***
[1][1.0] TRS_CB005896_ASIM_Traffic limitation level change (SBTS)
    Get System Module HW Variant
	Change iptrafficlim
	Reset Bts   should_be_onair=False
	Sleep	300
	Perform Call Setup Based On HW Variant
	Sleep	60
	Start Calls Based On HW Variant
	Start emssim configuration
	Enable Traffic Guard using EMSSIM
	teardown Emssim
	${Alarm_list}=	Verify Alarm	faultid=${faultnum}	should_exist=${True}
	VerifyAlarmSupp		${Alarm_list}
	Pm Counters Start	analysis=IPVOL_counters		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
	Verify PM Counters	analysis=IPVOL_counters		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
	Stop Calls Based On HW Variant
	${Alarm_list}=	Verify Alarm	faultid=${faultnum} 	should_exist=${True}
	VerifyAlarmSuppBeforeReset		${Alarm_list}
	Reset Bts   should_be_onair=False
	Sleep	300
	${Alarm_list}=	Verify Alarm	faultid=${faultnum} 	should_exist=${True}
	VerifyAlarmSuppAfterReset		${Alarm_list}
	LimitRateVerification
	Start Calls Based On HW Variant
	Pm Counters Start	analysis=IPVOL_counters		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
	Verify PM Counters	analysis=IPVOL_counters		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
	Start emssim configuration
	Disabling Traffic Guard using EMSSIM
	Sleep	60
	teardown Emssim
	Verify Alarm	faultid=${faultnum} 	should_exist=${False}
	Pm Counters Start	analysis=IPVOL_counters_nodrop		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
	Verify PM Counters	analysis=IPVOL_counters_nodrop		counter_analysis_file=${counter_analysis_file_name}	pm_interval=15
	Stop Calls Based On HW Variant
	Reset Bts   should_be_onair=False
	Sleep	300
	Start emssim configuration
	Enable Traffic Guard using EMSSIM
	${Alarm_list}=	Verify Alarm	faultid=${faultnum} 	should_exist=${True}
	VerifyAlarmSuppAfterReset		${Alarm_list}
	Disabling Traffic Guard using EMSSIM
	[Teardown]		Keywords To Run At End

