*** Settings ***
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB011036_CB0101037/resources/keywords.resource
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/energy_monitoring.robot

*** Keywords ***
[1]CB011036_CB010137_Test_Case_Activation_MIMO_Muting
    [Documentation]    Test Case covers secarios from TBA QC Instance.
    Perform SCF Commissioning CB011036_CB010137
    Start initial energy efficiency monitoring
    Avtivate DSS Power sainvg
    Setup and start cplane logs
    Wait for energy cell energy saving satus
    Stop initial energy efficiency monitoring
    Start final energy efficiency monitoring
    Stop cplane logs
    Convert and check cplane messages
    Check alarms after cell reached power saving
    Stop final energy efficiency monitoring and compare values
