*** Settings ***
Documentation
...    author: Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CNI116303/resources/test_specific_keywords.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CNI116303/resources/test_specific_keywords.py
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CNI116303/resources/test_specific_keywords.py

Force Tags      CA_VRF_WRO2
Test Teardown   Test Teardown

*** Test Cases ***
[1]CNI-116303_B1_Measurement_Report_Handing_With_Unknown_PCI_NG_Allowed
    [Setup]    Test Setup    all_objects_removal=${TRUE}
    CNI-116303_B1_Measurement_Report_Handing_With_Unknown_PCI_NG_Allowed

[1]CNI-116303_B2_Measurement_Report_Handing_With_Unknown_PCI_NG_Not_Allowed
    [Setup]    Test Setup    all_objects_removal=${TRUE}
    CNI-116303_B2_Measurement_Report_Handing_With_Unknown_PCI_NG_Not_Allowed

[1]CNI-116303_B2_Alt1_Measurement_Report_Handing_With_Known_PCI_NG_Not_Allowed
    [Setup]    Test Setup    all_objects_removal=${TRUE}
    CNI-116303_B2_Alt1_Measurement_Report_Handing_With_Known_PCI_NG_Not_Allowed
