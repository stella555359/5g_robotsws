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
# #[1][2.0] 5GC000740_A_01_NG-C_SCTP_associations_establishment_and_handling_between_one_gNB_and_several _AMFs
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
# #    [Teardown]    Run Keywords    Recover all links up via WebUI and SSH    AND    case teardown
# #    ...    AND   CI_interface.Common Case Teardown
# #    "Step1" Login WebEM and check gNB is onair
# #    "Step2" Make all NG-C links down via SSH
# #    "Step3" Check all NG-C links inactive
# #    "Step4" Make all NG-C links up via SSH
# #    #"Step5" Check all NG-C links active
# #
# #*** Keywords ***
# #