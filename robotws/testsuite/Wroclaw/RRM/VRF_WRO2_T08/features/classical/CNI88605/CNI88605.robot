*** Settings ***
Documentation
...   author: Adam Kropiwnicki
...   contact: adam.kropiwnicki@nokia.com

Library    taf.ue
Resource   ./resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Suite Setup   CNI Suite Setup
Suite Teardown   CNI Suite Teardown

*** Test Cases ***
[1]CNI_88605_Enable_Element_Impact_Check
    [Setup]   CNI Test Setup
    [1]CNI_88605_Enable_Element_Impact_Check
    [Teardown]   CNI Test Teardown

