*** Settings ***
Documentation
...   author: Adam Kropiwnicki
...   contact: adam.kropiwnicki@nokia.com

Resource   ./resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

*** Test Cases ***
[1][1.0] CB009427_A_Activation_and_deactivation_of_Adaptive_UL BLER_from_WebEM
    [Setup]       Setup CB009427
    [1][1.0]_CB009427_A_Activation_and_deactivation_of_Adaptive_UL_BLER_from_WebEM
    [Teardown]   Teardown CB009427
