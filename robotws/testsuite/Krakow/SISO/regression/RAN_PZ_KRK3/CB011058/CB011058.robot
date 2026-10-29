*** Settings ***
Documentation
...   Test suite for regression testing of feature CB011058 Enhanced PDL Validation Service to support HW validation
...   author: Marek Bodziony (marek.bodziony@nokia.com)
...   contact: Piotr Suski (piotr.suski@nokia.com)

Resource    ./resources/CB011058_keywords.robot

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
Suite Teardown      Common Suite Teardown

*** Test Cases ***
[1][3.0] CB011058_01-Static_HW_properties_pre-validation_for_ASiR_in_MantaRay_NM
    [Setup]     Run keywords
    ...         Common Preconditions with watching alarms
    ...         Setup for MantaRay srnclab
    ...         Prepare SW package with PDL plugin and upload to MantaRay

    ${valid_scf}=     Save SCF without errors
    ${invalid_scf}=    Prepare SCF with errors     scf_path=${valid_scf}
    Validate and activate SCF without errors via WebEM and expect success    SCF_without_errors=${valid_scf}
    @{scf_validation_err}=  Validate SCF with errors via WebEM and expect failure       scf_with_errors=${invalid_scf}
    ${valid_raml}    ${invalid_raml} =     Prepare RAML files and import to MantaRay     scf=${valid_scf}    scf_with_errors=${invalid_scf}
    Validate RAML plan without errors in MantaRay and expect success    raml_without_errors=${valid_raml}
    @{raml_validation_err}=  Validate RAML plan with errors in MantaRay and expect failure       raml_with_errors=${invalid_raml}
    Check if SCF and RAML validation errors are the same    scf_errors=@{scf_validation_err}    raml_errors=@{raml_validation_err}

    [Teardown]    Run keywords
    ...     Remove RAML plan from MantaRay     plan_to_remove=${valid_raml}
    ...     AND     Remove RAML plan from MantaRay     plan_to_remove=${invalid_raml}
    ...     AND     Remove SW package with PDL plugin from MantaRay
    ...     AND     Teardown for MantaRay
    ...     AND     Common Postconditions with watching alarms
