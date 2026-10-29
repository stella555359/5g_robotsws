*** Settings ***
Documentation
...  Feature CVR
...
...  author/contact: jakub.szymczakiewicz@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.CVR.ResCvr

Test Setup       Prepare environment
Test Teardown    Cleanup the setup and collect logs if the test fails

*** Test Cases ***
CVR_002_CB006449_N78+N78_TDD_DL+UL_CA
    Given Testline is commissioned and on air
    And Ue is attached
    When Ue traffic is started
    Then Cell aggregation is verified
    And Bwp switching is verified
    And Ue traffic is stopped
    And Counters are updated


