*** Settings ***
Documentation
...     [Author]        "Shivani Patil"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case covers basic check for cold reset on vDU"
...     [Date]      "10-08-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "302522"
...     [Funtion_Hash_Tags] "TRS - Solution"
...     [Feature_ID]            "CNI93885"
...     [Requirement ID]    "OAM_REQ_TRSSEC_919"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "5562"
...     [Config]    "This testcase needs basic scf to check reset"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_5GvDU-TL5562.xml"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_cni98335_vdu.robot


Suite Setup     Setup Precondition on vdu
Suite Teardown  Setup Postcondition on vdu


*** Test Cases ***
[1]TC01_CNI98335_Cold_Reset_Scenario_on_vDU_NFTR
    Loading SCF
    Verify pod status before reset
    Check with process kill option
    Verify pod status during reset
    Sleep    100
    Verify pod status after reset

[1]TC03_CNI98335_Warm_Reset_Scenario_on_vDU_NFTR
    Loading SCF
    Verify pod status before reset
    Perform warm reset from WebEM
    Sleep    90
    Verify pod status after reset
