*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010215
...   author: Marek Bodziony
...   contact: marek.bodziony@nokia.com

Resource    ./CB010215_keywords.robot

Force Tags    STATE_SW_UPLOADED    CRT    PY36

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...                 prefix_tag=CB010215
Suite Teardown      Common Suite Teardown

*** Test Cases ***
[1][2.0] CB010215_Online_parameter_modification_on_Rel5
    [Setup]     Run keywords
    ...         Common Preconditions with watching alarms
    ...         Change param 'allowTrafficConcentration' to true for Rel5
    Deactivate uDTX while Traffic Concentration enabled and expect validation error on Rel5
    Change param 'allowTrafficConcentration' to false for Rel5
    Change param 'actMicroDtx' to false for Rel5
    [Teardown]  Run keywords
    ...         Change param 'actMicroDtx' to true for Rel5
    ...         Common Postconditions with watching alarms

[1][2.0] CB010215_Online_parameter_modification_with_CRG_on_Rel5
    [Setup]     Run keywords
    ...         Common Preconditions with watching alarms
    ...         Enable Cell Resource Groups for Rel5
    Activate Traffic Concentration while uDTX enabled and CRG configured and expect validation error on Rel5
    Change param 'actMicroDtx' to false for Rel5
    [Teardown]  Run keywords
    ...         Disable Cell Resource Groups for Rel5
    ...         Change param 'actMicroDtx' to true for Rel5
    ...         Common Postconditions with watching alarms
