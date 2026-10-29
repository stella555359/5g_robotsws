*** Settings ***
Documentation
...  author:  Piotr Brzezicki, Marcin Wachacki
...  contact: piotr.brzezicki@nokia.com, marcin.wachacki@nokia.com
...  description: Test Cases for CB008367-SR-C-ST_RRM CCE split improvement.

Resource    ./resources/suite_specific_keywords.robot

Suite Setup    CB008367 Suite Setup

*** Test Cases ***
CB008367-C_101_#B.1_UE1_Large_BWP_UE2_PS_BWP
    [Setup]    CB008367 Test Setup   scf_path=${CB008367_C101_SCF}
    Register 2 UEs in SA cell
    Start data transfer for UEs that UE1 is in Large BWP and UE2 in PS BWP
    Collect syslog for short time and verify that CCE split is not enabled in 2 dedicated BWPs
    Wait until PM Counter interval and check that M55335C02016/M55335C02011 is 0
    Enable CB008367 feature
    Collect syslog for short time and verify that CCE split is enabled in Large BWP
    Stop and verify data transfers for 2 UEs
    Wait until PM Counter interval and check that M55335C02016/M55335C02011 larger than 0
    [Teardown]    CB008367-C101 Test Teardown
