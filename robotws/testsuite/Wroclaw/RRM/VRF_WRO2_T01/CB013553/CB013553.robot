*** Settings ***
Documentation
...  Author:        Tomasz Mozola
...  Contact:       tomasz.mozola@nokia.com, pawel.bicz@nokia.com
...  Feature owner: Pawel Bicz
...  Description:   None

Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/Suite_repository.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB013553/resources/tests_13553.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot


Force Tags        CA_VRF_WRO2   CRT

Suite Setup       Suite Setup for CB013553


*** Test Cases ***
CB013553-A-B7_TDD_FR1_FDD_UL_2TX_switching_peak_throughput_with_PUSCH_mapping_type_A_Real_HW
    [Setup]     Test Setup for CB013553
    CB013553-A-B7_TDD_FR1_FDD_UL_2TX_switching_peak_throughput_with_PUSCH_mapping_type_A_Real_HW
    [Teardown]  Test Teardown for CB013553

CB013553-B-B2_FDD_TDD_FR1_UL_2TX_switching_SCell_addition_and_Release_Real_HW
    [Setup]     Test Setup for CB013553
    CB013553-B-B2_FDD_TDD_FR1_UL_2TX_switching_SCell_addition_and_Release_Real_HW
    [Teardown]  Test Teardown for CB013553

CB013553-D_IWK8_Stepwise_SCell_Addition_DL+UL_SCell_with_R17_UL_Tx_Switching_Option1
    [Setup]     Test Setup for CB013553       if_Sub_D=${TRUE}
    CB013553-D_IWK8_Stepwise_SCell_Addition_DL+UL_SCell_with_R17_UL_Tx_Switching_Option1
    [Teardown]  Test Teardown for CB013553    recomm=${TRUE}
