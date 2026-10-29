*** Settings ***
Documentation
    ...     [Procedure]             "BTS Startup time"
    ...     [Date]                  "31-07-2024"
    ...     [Author]                "Sahana TC"
    ...     [Maintenance]           "TRS I & V Tools Bangalore Team"
    ...     [QC_Path]               "Root\Test_Sets\24R3\New_Features\VRF_BLR2\BB_TRS_VRF_ST\CNI-94932 -Introduce dedicated systemd target for LFS
    ...                              readiness"
    ...     [Feature_ID]            "CNI-94932"
    ...     [Requirement ID]        "RPREQ_9077, OM_GEN_SFS_PERF_CAP.30331, OM_GEN_SFS_PERF_CAP.31424[, OM_GEN_SFS_PERF_CAP.31473, OM_GEN_SFS_PERF
    ...                              _CAP.30278"
    ...     [Validation_Status]     "Validated"
    ...     [Validated_TestLine]    "2213"


Resource    ../resources/common_keywords.robot
Resource    resources/CNI_94932_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown        Teardown Oamops


*** Variables ***

${index}                    1
${length}                   5


*** Test Cases ***
[1]TC02_CNI-94932_Verify BTS startup time after site and unit resets

    ${pre_reset_alarms}=    Verify Alarm    alarm_type=active
    ${pre_reset_length}=    Get Length  ${pre_reset_alarms}
    ${pre_alarm_faultids}=    Create List
    ${pre_alarm_faultids}=    Create fault id List    ${pre_reset_alarms}

	FOR	  ${index}    IN RANGE    ${length}
        Start Syslog    ${CURDIR}   background_syslog.txt
        Reset Bts
        Verify_BTS_startup_time
    END

	${post_reset_alarms}=	Verify Alarm	alarm_type=active
    ${post_reset_length}=	Get Length	${post_reset_alarms}
	${post_alarm_faultids}=	Create List
	${post_alarm_faultids}=	Create fault id List	${post_reset_alarms}
	${alarms_post_reset}=	Fault list after reset	${pre_alarm_faultids}	${post_alarm_faultids}
