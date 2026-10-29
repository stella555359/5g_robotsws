# #*** Settings ***
# #Suite Setup          SISO Common Suite Setup
# #Suite Teardown       SISO Common Suite Teardown
# #Test Setup
# #Test Teardown
# #Test Timeout         60min
# #
# #Resource             Resource/5GC000740_common_KW.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# #
# #Documentation
# #...    Author: jackie.ji
# #...    Contact: jackie.ji@nokia-sbell.com
# #...    Squad group: SG_05
# #...    Feature 5GC000740-B in 5G20A program
# #
# #Force Tags         5G20A
# #...    PY36
# #
# #*** Variables ***
# #
# #*** Test Cases ***
# #[1]5GC000740_D_01_B2_NGAP_RAN_Configuration_update_successfully_with_multi_AMFs_in_SA_cell
# #    [Documentation]
# #    ...    *****************
# #    ...    - [TEST PURPOSE] The purpose of this test case is to check TAC can add successfully
# #    ...    ******************
# #    ...    History of changes
# #    ...    ******************
# #    ...    - 2020.06.15   https://jiradc.int.net.nokia.com/browse/WESTLAKE-xxxx       - Created
# #    ...    *******************
# #    [Tags]    OWNER_lei.6.wang@nokia-sbell.com    CIT_TRUNK   SBTS00   CRT_22R2   CRT_22R3   CIT_22R4
# #    [Setup]   SISO Common Test Setup
# #    [Teardown]    Run Keywords    Delete trackingarea object to recovery    AND    case teardown
# #    ...    AND   CI_interface.Common Case Teardown
# #    "Step1" Login WebEM and check gNB is onair
# #    "Step2" Add trackingarea object via WebUI
# #    "Step3" Check trackingarea add success
# #
# #*** Keywords ***
# #