*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout         80min

Resource             Resource/5GC000740_common_KW.robot

Documentation
...    Author: shasha.liu
...    Contact: shasha.liu@nokia-sbell.com
...    Squad group: SG_05
...    Feature 5GC000740-C in 5G20A program

Force Tags         5G20A
...    PY36

*** Variables ***

*** Test Cases ***
[1]5GC000740_E_01_B1_NG-C_Flex_feature_online_deactivation
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check NG-C link status after make all AMF links down
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2020.05.28   https://jiradc.int.net.nokia.com/browse/WESTLAKE-xxxx       - Created
    ...    *******************
    [Tags]    OWNER_lei.6.wang@nokia-sbell.com    CIT_TRUNK
    [Setup]   SISO Coam Test Setup
    [Teardown]    Run Keywords    Resume actNgcFlexSaMode back to true    AND   Selenium Logout And Close Browser
    ...    AND   SISO Coam Test Teardown
    "Step1" Login WebEM and check NG-C links
    "Step3" Modify actNgcFlexSaMode value to false
    "Step4" Check actNgcFlexSaMode modified success
    "Step5" check NGC_link Main-AMF maintained and non-main-AMF released

[1]5GC000740_D_01_B2_NGAP_RAN_Configuration_update_successfully_with_multi_AMFs_in_SA_cell
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check TAC can add successfully
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2020.06.15   https://jiradc.int.net.nokia.com/browse/WESTLAKE-xxxx       - Created
    ...    *******************
    [Tags]    OWNER_lei.6.wang@nokia-sbell.com    CIT_TRUNK
    [Setup]   SISO Coam Test Setup
    [Teardown]    Run Keywords    Delete trackingarea object to recovery    AND   Selenium Logout And Close Browser
    ...    AND   SISO Coam Test Teardown
    "Step1" Login WebEM and check gNB is onair
    "Step2" Add trackingarea object via WebUI
    "Step3" Check trackingarea add success

[1]5GC000740_C_9_B14_NG-C_links_unlocked_with_all_AMFs_SA
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check NG-C link status after make all AMF links down
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2020.05.28   https://jiradc.int.net.nokia.com/browse/WESTLAKE-xxxx       - Created
    ...    *******************
      [Tags]    OWNER_lei.6.wang@nokia-sbell.com    CIT_TRUNK
    [Setup]   SISO Coam Test Setup
    [Teardown]    run keywords    Selenium Logout And Close Browser    SISO Coam Test Teardown
    "Step1" Login WebEM and check NG-C links
    "Step2" Lock all NG-C links via WebUI
    "Step3" Check all NG-C links inactive
    "Step4" unLock all NG-C links via WebUI
    "Step5" Check all NG-C links active
    #"Step6" make SA call

[1]5GC000740_B_06_all_actvie_NG-C_links_with_all_AMFs_be_locked_with_SA_cell
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check NG-C link status after lock all AMF
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2020.05.29   https://jiradc.int.net.nokia.com/browse/WESTLAKE-xxxx       - Created
    ...    *******************
    [Tags]    OWNER_lei.6.wang@nokia-sbell.com    CIT_TRUNK
    [Setup]   SISO Coam Test Setup
    [Teardown]    Run Keywords    Recover all NG-C links to unlocked    AND   Selenium Logout And Close Browser
    ...    AND   SISO Coam Test Teardown
    "Step1" Login WebEM and check NG-C links
    "Step2" Lock all NG-C links by judging ways via WebUI
    "Step3" Check all NG-C links inactive
    "Step4" Check all locked counters via WebUI
    "Step5" Check gNB still onair and cell barred

[1]5GC000740_A_02_Only_Main_AMF_SCTP_association_establishment_when_actNgcFlexSaMode_set_as_false
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check NG-C link status after make all AMF links down
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2020.05.28   https://jiradc.int.net.nokia.com/browse/WESTLAKE-xxxx       - Created
    ...    *******************
    [Tags]    OWNER_lei.6.wang@nokia-sbell.com     CIT_TRUNK
    [Setup]   SISO Coam Test Setup
    [Teardown]    Run Keywords    Recover setting and check another link active    AND   Selenium Logout And Close Browser
    ...    AND   SISO Coam Test Teardown
    "Step1" Login WebEM and check gNB is onair
    "Step2" Modify actNgcFlexSaMode value to false
    "Step3" Check main NG-C link active and another inactive

[1][2.0] 5GC000740_A_01_NG-C_SCTP_associations_establishment_and_handling_between_one_gNB_and_several _AMFs
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check NG-C link status after make all AMF links down
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2020.05.28   https://jiradc.int.net.nokia.com/browse/WESTLAKE-xxxx       - Created
    ...    *******************
    [Tags]    OWNER_lei.6.wang@nokia-sbell.com    CIT_TRUNK
    [Setup]   SISO Coam Test Setup
    [Teardown]    run keywords    Recover all links up via WebUI and SSH   AND   Selenium Logout And Close Browser
    ...   AND   SISO Coam Test Teardown
    ${fault_list}    Create List    7304
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    "Step1" Login WebEM and check gNB is onair
    "Step2" Make all NG-C links down via SSH
    "Step3" Check all NG-C links inactive
    "Step4" Make all NG-C links up via SSH
    "Step5" Check all NG-C links active

*** Keywords ***
