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


Resource    ${CURDIR}/../resources/common_keywords.robot
Resource    ${CURDIR}/resources/CNI_94932_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown        Teardown Oamops

*** Variables ***

${index}                    1
${length}                   20

*** Test Cases ***
[1]TC01_CNI-94932_Verify BTS startup time after full commissioning
    Start Syslog	${CURDIR}	background_syslog.txt
    Configure Switch    device=l3switch    command_profile=dynamic_lag
    sleep   20
    Perform Commissioning    scf_file=${base_scf_freefrance_cust}    wait_for_onair_status=400    timeout=900    alias=default
    Verify_BTS_startup_time
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
