*** Settings ***
Documentation
...    author: Bartosz Kozlowski, Palina Krasnova
...    contact: bartosz.1.kozlowski@nokia.com, palina.krasnova@nokia.com

Resource     resources/test_specific_keywords.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    resources/test_constants.py

Suite Setup      Common Suite Setup
Suite Teardown   Common Suite Teardown

Test Setup       Common Preconditions
Test Teardown    Common Postconditions

*** Test Cases ***
[1]5G23R1_6878_RRM_001
    [Documentation]
    ...    NSA Long PUCCH for FR1-TDD and CB006878
    CB006878_RRM_Common    ue_alias=${UE_ALIAS_NSA}    ue_caps=${NSA_UE_CAPS}

[1]5G23R1_6878_RRM_002
    [Documentation]
    ...    SA Long PUCCH for FR1-TDD and CB006878
    CB006878_RRM_Common    ue_alias=${UE_ALIAS_SA}    ue_caps=${SA_UE_CAPS}

[1]23R1_8392_RRM_2
    [Documentation]
    ...    Suspend and Un-suspend Load-Based Reduced TX Paths Power Saving
    CB008392_RRM_Common

[1]23R3_9409_CP_007
    [Documentation]
    ...    Verify that only PCell send TCP Boost PUGs in CA case
    CB009409_RRM_Common
