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
[1]TC03_CNI-94932_Verify BTS startup time after SW upgrade and downgrade
    Perform Software Download And Update        package=auto        wft_profile=${Build1}        activate_sw=true        timeout=1800
    ...        wait_for_bts_to_be_ready=360        timeout=1800
    Verify Bts Status       should_be_onair=True        rat=5g        timeout=60
    Start Syslog    ${CURDIR}   background_syslog.txt
    Perform Commissioning    scf_file=${base_scf}    wait_for_onair_status=400    alias=default
    Verify_BTS_startup_time
    Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=history
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    Rollback Software       verify_bts_status=true      is_config_reset=false       timeout=240
    Sleep    360
    Verify Bts Status       should_be_onair=True        rat=5g        timeout=60
    Start Syslog    ${CURDIR}   background_syslog.txt
    Perform Commissioning    scf_file=${base_scf}    wait_for_onair_status=400    alias=default
    Verify_BTS_startup_time
    Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=history
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
