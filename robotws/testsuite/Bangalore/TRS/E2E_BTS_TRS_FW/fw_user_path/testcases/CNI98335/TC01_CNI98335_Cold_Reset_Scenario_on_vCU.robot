*** Settings ***
Documentation
...     [Author]        "Shivani Patil"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case covers basic check for cold reset on vCU"
...     [Date]      "10-08-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "302523"
...     [Funtion_Hash_Tags] "TRS - Solution"
...     [Feature_ID]            "CNI93885"
...     [Requirement ID]    "OAM_REQ_TRSSEC_919"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "5562"
...     [Config]    "This testcase needs basic scf to check reset"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_5GvCU-TL5562.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_cni98335_vcu.robot

Suite Setup     Setup Preconditions for vcu
Suite Teardown  Setup Postconditions for vcu


*** Test Cases ***
[1]TC01_CNI98335_Cold_Reset_Scenario_on_vCU_NFTR
    Loading SCF
    Read the pods name
    Verify the pods status
    Check with process kill option
    Sleep   90
    Read the pods name
    Verify the pods status

[1]TC04_CNI98335_Warm_Reset_Scenario_on_vCU_NFTR
    Loading SCF
    Perform warm reset from WebEM
    Sleep      100
    Read the pods name
    Verify the pods status
