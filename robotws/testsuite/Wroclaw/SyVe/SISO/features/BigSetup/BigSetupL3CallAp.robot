*** Settings ***
Documentation
...  Feature BIG_SETUP
...
...  author/contact: jakub.szymczakiewicz@nokia.com

Library         testsuite.Wroclaw.SyVe.SISO.features.BigSetup.ResBigSetup

Test Teardown    Run Keywords         Dl traffic on airphone ues is stopped
                               ...    Ul traffic on airphone ues is stopped
                               ...    Airphone ues are detached
                               ...    Cleanup the setup and collect logs if the test fails

*** Test Cases ***
BIG_SETUP_L3CALL_AIRPHONE
    Given Airphone ues are attached
    When Dl traffic on airphone ues is started
    And Ul traffic on airphone ues is started
    Then Dl traffic stats on airphone ues are checked
    And Ul traffic stats on airphone ues are checked
