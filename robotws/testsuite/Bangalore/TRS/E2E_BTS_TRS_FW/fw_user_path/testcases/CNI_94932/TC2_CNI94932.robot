*** Settings ***
Documentation
    ...     [Procedure]             "BTS Startup time"
    ...     [Date]                  "31-07-2024"
    ...     [Author]                "Prajwal"
    ...     [Maintenance]           "TRS I & V Tools Bangalore Team"
    ...     [QC_Path]               "Root\Test_Sets\24R3\New_Features\VRF_BLR2\BB_TRS_VRF_ST\CNI-94932 -Introduce dedicated systemd
    ...                             target for LFS readiness"
    ...     [Feature_ID]            "CNI-94932"
    ...     [Requirement ID]        "RPREQ_9077, OM_GEN_SFS_PERF_CAP.30331, OM_GEN_SFS_PERF_CAP.31424[, OM_GEN_SFS_PERF_CAP.31473,
    ...                             OM_GEN_SFS_PERF_CAP.30278"
    ...     [Validation_Status]     "Validated"
    ...     [Validated_TestLine]    "2205"

Resource    ${CURDIR}/../resources/common_keywords.robot
Resource    ${CURDIR}/resources/CNI_94932_keywords.robot

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown        Teardown Oamops

*** Test Cases ***
[1]TC02_CNI-94932_Verify BTS startup time after site and unit resets
    ${pre_reset_alarms}=    Verify Alarm    alarm_type=active
    ${pre_reset_length}=    Get Length  ${pre_reset_alarms}
    ${pre_alarm_faultids}=    Create List
    ${pre_alarm_faultids}=    Create fault id List    ${pre_reset_alarms}
    FOR    ${j}    IN RANGE    1
        Start Syslog    ${CURDIR}   background_syslog.txt
        Wait Until Keyword Succeeds    3    100s    Reset Bts
        Verify_BTS_startup_time
    END
    ${post_reset_alarms}=    Verify Alarm    alarm_type=active
    ${post_reset_length}=    Get Length  ${post_reset_alarms}
    ${post_alarm_faultids}=    Create List
    ${post_alarm_faultids}=    Create fault id List    ${post_reset_alarms}
    ${alarms_post_reset}=    Fault list after reset  ${pre_alarm_faultids}   ${post_alarm_faultids}
