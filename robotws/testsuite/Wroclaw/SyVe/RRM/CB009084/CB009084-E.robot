*** Settings ***
Documentation
...  feature 9084
...
...  author/contact: krzysztof.1.wrobel@nokia.com

Library     testsuite.Wroclaw.SyVe.RRM.CB009084.CB009084E
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Test Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                           Prepare Base Feature Test Line

Test Teardown    Run Keywords    Stop Downlink Traffic
...                              Detach All Ues
...                              Cleanup Ue Traffic Files
...                              Collect Logs

*** Test Cases ***
CB009084_TC_E01_Slice_aware_scheduler_with_DSS_enabled_FDD_FDM_ON
    Add scout external execution id to the reporting portal
    Attach All Ues
    Start Dl Tcp Traffic
    Verify Pm Counters
    Perform Delta For New Quota Values
    Verify Pm Counters For New Quota Values
