***Settings ***

Documentation
...     [Procedure]             "The test case performs BTS software upgrade and 25 times BTS Reset"
...     [Date]                  "26-10-2022"
...     [Author]                "Punith"
...     [Feature_ID]            ""
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Funtion_Hash_Tags]     "E2LINK_RIC"
...     [Validated_TestLine]    "ASIA"
...     [Precondition]          "BTS should be operational and configured state"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"

Force Tags          CLOUD_F_IPSEC   CA_VRF_TRS    SBTS00  SBTS22R1    RAN_4G  RAN_4G_FDD  QCD_MN_RAN  QCP_RAN_VRF   CRT

variables       ta_e2e_bts_trs_fw
Resource         ${CURDIR}/../resources/common_keywords.robot
Resource         ${CURDIR}/resources/Test_case_keywords.robot

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

*** Test Cases ***
[1][1.0] BTS Site Reset with 25 times iteration for All HWs
    Verify Bts Status    should_be_onair=${True}      timeout=120
    Perform Software Download And Update       package=${profile}      activate_sw=true      update_timeout=220
	#log	${EXECDIR}
	#Start Syslog	${CURDIR}	background_syslog.txt
	${pre_reset_alarms}=	Verify Alarm	alarm_type=active
	${pre_reset_length}=	Get Length	${pre_reset_alarms}
	${pre_alarm_faultids}=	Create List
	${pre_alarm_faultids}=	Create fault id List	${pre_reset_alarms}
	FOR	${j}	IN RANGE	25
		Wait Until Keyword Succeeds	2x	100s	Reset Bts   should_be_onair=${True}
        ${post_reset_alarms}=   Verify Alarm    alarm_type=active
        ${post_reset_length}=   Get Length  ${post_reset_alarms}
        ${post_alarm_faultids}=     Create List
        ${post_alarm_faultids}=     Create fault id List        ${post_reset_alarms}
        ${alarms_post_reset}=   Fault list after reset      ${pre_alarm_faultids}       ${post_alarm_faultids}
    	#Delete File Addons	${CURDIR}
		#Write	ls
		#${prompt}=	Read Until Prompt	$
		#${value}=	Should Match Regexp	${prompt}	disconnect.\\*
	END
	${post_reset_alarms}=	Verify Alarm	alarm_type=active
	${post_reset_length}=	Get Length	${post_reset_alarms}
	${post_alarm_faultids}=	Create List
	${post_alarm_faultids}=	Create fault id List	${post_reset_alarms}
	${alarms_post_reset}=	Fault list after reset	${pre_alarm_faultids}	${post_alarm_faultids}
	#[Teardown]	Suite Teardown1
#Delete File Addons  ${CURDIR}