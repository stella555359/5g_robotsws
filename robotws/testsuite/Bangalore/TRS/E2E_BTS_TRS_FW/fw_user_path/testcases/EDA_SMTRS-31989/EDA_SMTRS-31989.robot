*** Settings ***
Documentation
    ...     [Procedure]             "The test case is to validate binding of mplane application address after online
    ...     odification and connectivity check"
    ...     [Date]                  "16-12-23"
    ...     [Author]                "Nethra M"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "ApplicationIP, EDA"
    ...     [Feature_ID]            "EDA_SMTRS-31989"
    ...     [Validation_status]     "Validated"
    ...     [Validated_TestLine]    "5555"


variables       ta_e2e_bts_trs_fw
Resource     ${CURDIR}/../resources/common_keywords.robot
Resource     ${CURDIR}/../resources/admin_oam_common_keywords.robot
Resource     ${CURDIR}/../resources/Admin_Common_Library.robot


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops
Test Timeout    5 minutes


*** Test Cases ***
[1]EDA_Jira_SMTRS-31989_PR737336:Regression scenario enhancement for online modification on Application ips
    Perform Commissioning   scf_file=${Base_config}    verify_bts_status=False      timeout=600       alias=default
    BuiltIn.Sleep   100
    Verify ping test success    ${remote1}  ${source1}
    Modify Application IP's
    Verify ping test success    ${remote1}     ${source2}
    Setup Oamops


*** Keywords ***
Modify Application IP's
    Perform Recommissioning     type=delta      delta_file=${modify_application_ip}     timeout=300
    Sleep   200
