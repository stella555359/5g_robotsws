***Settings ***
Documentation
    ...     [Procedure]             "EDA_26705"
    ...     [Date]                  "31-08-2025"
    ...     [Author]                "Sahana TC"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "ROBUSTNESS"
    ...     [Feature_ID]            "SMTRS-26705"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-2205"

variables     ta_e2e_bts_trs_fw
Resource      ${CURDIR}/../resources/common_keywords.robot
Resource      ${CURDIR}/resources/common_26705.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown        Teardown Oamops

*** Variables ***
${index}                    1
${length}                   30

*** Test Cases ***
[1][1.0] SMTRS_26705_Multiple BBMOD Reset while sending user plane traffic

	[Documentation]		This test case validates fault 6450 when BBMOD is rest multiple times and when user plane traffic is ongoing
    Perform Commissioning       scf_file=${EDA_26705_scf}   verify_bts_status=${True}     timeout=300     alias=default
    BBMOD Reset
    [Teardown]    Roll Back