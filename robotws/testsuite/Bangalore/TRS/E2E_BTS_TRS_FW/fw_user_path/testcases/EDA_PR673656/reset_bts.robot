*** Settings ***
Documentation
    ...     [Procedure]             "BTS Site Reset with 25 times iteration"
    ...     [Date]                  "09-01-2023"
    ...     [Author]                "POOJA"
    ...     [Maintenance]           "TRS I & V Tools Bangalore Team"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [Feature_ID]            "SMTRS-28284"
    ...     [Requirement ID]        "EDA:PR673656"
    ...     [Validation_Status]     "Validated"
    ...     [Validated_TestLine]    "2205"


Resource    ../resources/common_keywords.robot
Resource    resources/kw.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown        Teardown Oamops

*** Test Cases ***
[1][1.0] BTS Site Reset with 25 times iteration for All HWs

	Start Syslog	${CURDIR}	background_syslog.txt
	${pre_reset_alarms}=	Verify Alarm	alarm_type=active
	${pre_reset_length}=	Get Length	${pre_reset_alarms}
	${pre_alarm_faultids}=	Create List
	${pre_alarm_faultids}=	Create fault id List	${pre_reset_alarms}
	FOR	${j}	IN RANGE	${reset_try}
		Wait Until Keyword Succeeds	2x	100s	Reset Bts
        Sleep    60
		Delete File Addons	${CURDIR}	${vnc_ip}
	${post_reset_alarms}=	Verify Alarm	alarm_type=active
	${post_reset_length}=	Get Length	${post_reset_alarms}
	${post_alarm_faultids}=	Create List
	${post_alarm_faultids}=	Create fault id List	${post_reset_alarms}
	${alarms_post_reset}=	Fault list after reset	${pre_alarm_faultids}	${post_alarm_faultids}
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    Sleep   20
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
    Sleep   20
    END
    Suite Teardown1
