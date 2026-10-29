# #*** Settings ***
# #Suite Setup          SISO Common Suite Setup
# #Suite Teardown       SISO Common Suite Teardown
# #Test Setup
# #Test Teardown
# #Test Timeout         70min
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
# #[1]5GC000740_B_06_all_actvie_NG-C_links_with_all_AMFs_be_locked_with_SA_cell
# #    [Documentation]
# #    ...    *****************
# #    ...    - [TEST PURPOSE] The purpose of this test case is to check NG-C link status after lock all AMF
# #    ...    ******************
# #    ...    History of changes
# #    ...    ******************
# #    ...    - 2020.05.29   https://jiradc.int.net.nokia.com/browse/WESTLAKE-xxxx       - Created
# #    ...    *******************
# #    [Tags]    OWNER_lei.6.wang@nokia-sbell.com    CIT_TRUNK   SBTS00   CRT_22R2   CRT_22R3   CIT_22R4
# #    [Setup]   SISO Common Test Setup
# #    [Teardown]    Run Keywords    Recover all NG-C links to unlocked    AND    case teardown
# #    ...    AND   CI_interface.Common Case Teardown
# #    "Step1" SiteReset and check gNB is onair
# #    "Step2" Lock all NG-C links by judging ways via WebUI
# #    "Step3" Check all NG-C links inactive
# #    "Step4" Check all locked counters via WebUI
# #    "Step5" Check gNB still onair and cell barred
# #
# #*** Keywords ***
# #