# #*** Settings ***
# #Suite Setup          SISO Common Suite Setup
# #Suite Teardown       SISO Common Suite Teardown
# #Test Setup
# #Test Teardown
# #Test Timeout         80min
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
# #Force Tags
# #...    PY36
# #
# #*** Variables ***
# #
# #*** Test Cases ***
# #[1]5GC000740_A_02_Only_Main_AMF_SCTP_association_establishment_when_actNgcFlexSaMode_set_as_false
# #    [Documentation]
# #    ...    *****************
# #    ...    - [TEST PURPOSE] The purpose of this test case is to check NG-C link status after make all AMF links down
# #    ...    ******************
# #    ...    History of changes
# #    ...    ******************
# #    ...    - 2020.05.28   https://jiradc.int.net.nokia.com/browse/WESTLAKE-xxxx       - Created
# #    ...    *******************
# #    [Tags]    OWNER_lei.6.wang@nokia-sbell.com     CIT_TRUNK   SBTS00   CIT_22R4
# #    [Setup]   SISO Common Test Setup
# #    [Teardown]    Run Keywords    Recover setting and check another link active    AND    case teardown
# #    ...    AND   CI_interface.Common Case Teardown
# #    "Step1" Login WebEM and check gNB is onair
# #    "Step2" Modify actNgcFlexSaMode value to false
# #    "Step3" Check main NG-C link active and another inactive
# #
# #*** Keywords ***
# #