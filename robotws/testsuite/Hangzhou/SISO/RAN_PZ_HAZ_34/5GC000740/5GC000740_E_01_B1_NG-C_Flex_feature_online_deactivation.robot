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
# #...    Author: jeffrey.shi
# #...    Contact: jeffrey.shi@nokia-sbell.com
# #...    Squad group: SG_05
# #...    Feature 5GC000740-C in 5G20A program
# #
# #Force Tags         5G20A
# #...    PY36
# #
# #*** Variables ***
# #
# #*** Test Cases ***
# #[1]5GC000740_E_01_B1_NG-C_Flex_feature_online_deactivation
# #    [Documentation]
# #    ...    *****************
# #    ...    - [TEST PURPOSE] The purpose of this test case is to check NG-C link status after make all AMF links down
# #    ...    ******************
# #    ...    History of changes
# #    ...    ******************
# #    ...    - 2020.05.28   https://jiradc.int.net.nokia.com/browse/WESTLAKE-xxxx       - Created
# #    ...    *******************
# #    [Tags]    OWNER_lei.6.wang@nokia-sbell.com    CIT_TRUNK   SBTS00   CRT_22R2   CRT_22R3   CIT_22R4
# #    [Setup]   SISO Common Test Setup
# #    [Teardown]    Run Keywords    Resume actNgcFlexSaMode back to true    AND    case teardown
# #    ...    AND   CI_interface.Common Case Teardown
# #    "Step1" SiteReset and check gNB is onair
# ##    "Step2" Do L3 call with main-AMF and non-main-AMF
# #    "Step3" Modify actNgcFlexSaMode value to false
# #    "Step4" Check actNgcFlexSaMode modified success
# #    "Step5" check NGC_link Main-AMF maintained and non-main-AMF released
# ##    "Step6" L3 call with Main-AMF maintained and with non-main-AMF released
# #
# #*** Keywords ***
# #