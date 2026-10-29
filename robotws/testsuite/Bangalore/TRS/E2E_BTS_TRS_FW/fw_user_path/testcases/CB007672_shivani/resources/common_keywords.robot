*** Settings ***
Documentation
...     [Author]            "Punith K"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers ipsec failure counter verification for vdu and vcu with certificate"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]             "TRS_CB010465_5GC002215_ipsec_failure_counterVerification_for_vdu_and_vcu"
...     [Funtion_Hash_Tags]     "TRS - Security"
...     [Feature_ID]            "CB010465"
...     [Requirement ID]        ""
...     [Validation_Status] "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]            "This testcase needs basic scf with ipsec configuration"

*** Keywords ***
Pre-conditions for testsuite
    Suite Setup Preconditions
    Setup Oamops

Post-conditions for testteardown
    Teardown Oamops
    Suite Teardown Postconditions