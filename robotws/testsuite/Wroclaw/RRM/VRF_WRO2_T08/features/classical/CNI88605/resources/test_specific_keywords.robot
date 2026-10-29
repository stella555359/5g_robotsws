*** Settings ***
Documentation
...   author: Adam Kropiwnicki
...   contact: adam.kropiwnicki@nokia.com

Library    taf.ue
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T08.features.classical.CNI88605.resources.CNI88605    WITH NAME   CNI

*** Keywords ***
CNI Suite Setup
    CNI.Suite Setup
    CNI.Backup SCF

CNI Suite Teardown
    CNI.Suite Teardown

CNI Test Setup
    CNI.Test Setup
    CNI.Determine Relevant DRB ID
    CNI.Setup Log Collectors
    CNI.Create SCF Reverting Delta
    CNI.Set dlDataSplitBufferBuildUpThreshold To Zero

CNI Test Teardown
    CNI.Collect Test Logs
    CNI.Test Teardown

[1]CNI_88605_Enable_Element_Impact_Check
    CNI.Set dlAllowMinDelayLinkXxCalib   false
    Verify Feature   false
    CNI.Set dlAllowMinDelayLinkXxCalib   true
    Verify Feature   true

Verify Feature
    [Arguments]   ${link_xx_calib_value}
    CNI.Attach With Btslog   ${link_xx_calib_value}
    ${logs}=   CNI.Run TPUT With Logs   ${link_xx_calib_value}
    CNI.Detach UE
    CNI.Verify Tput   ${logs}  ${link_xx_calib_value}
