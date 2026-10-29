*** Settings ***
Documentation
    ...     [Procedure]             "The test case is to verify 48hr stability for transport features with configuration changes and calls enabled
    ...      as part of PET Testing"
    ...     [Date]                  "20-08-25"
    ...     [Author]                "Shivani Patil"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "TWAMP","BFD","Certificates"
    ...     [Feature_ID]            "PET"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "5G-1234"
    ...     [Config]                "No BFD configurations should have the preloaded scf as BFD configuration are created by delta for this case"

Resource        ${CURDIR}/resources/common_keywords_PET.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Library         ${CURDIR}/resources/egate_library.py

Suite Setup        Setup Oamops
Suite Teardown        Teardown Oamops

*** Test Cases ***
[1] ASIK_PET_Verification_of_Maximum BFD sessions, TWAMP and Certificates
    Load base scf
    Verify RMOD is up
    Load Max Certificates
    Enable IPsec and Validate
    Configure Maximum BFD and BFDGRPs
    Validation for BFD
    Enable TWAMP
    Validation for TWAMP
    Enable SoE and Verify
    Enabled SBR and Validate
    Verify high throughput
    Verify Call Stability
    Stop Calls
    Verify BTS Status      should_be_onair=${True}     rat=5g
    [Teardown]      Revert configuration
